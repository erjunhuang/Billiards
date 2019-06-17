
local isSucc,struct = pcall(require,"struct");
Socket = import(".SocketNew")



local SocketReader = import(".SocketReader")
local SocketWriter = import(".SocketWriter")
local SocketProcesser = import(".SocketProcesser")
local SocketBase = class("SocketBase")

function SocketBase:ctor(name,sockHeader,netEndian)
    -- print("SocketBase:ctor",name,sockHeader,netEndian)
    self.__socket = self:createSocket(name,sockHeader,netEndian);
    self.__socket:setEvent(handler(self,self.onSocketEvent));

    self.__socketReaders = {};
    self.__socketWriters = {};
    self.__socketProcessers = {};
    self.__commonSocketReaders = {};
    self.__commonSocketWriters = {};
    self.__commonSocketProcessers = {};

    self.shouldConnect_ = false
    self.isConnected_ = false
    self.isConnecting_ = false
    self.isProxy_ = false
    self.isPaused_ = false
    self.delayPackCache_ = nil
    self.retryLimit_ = 4

    self.__name = name

    self.heartBeatSchedulerPool_ = core.SchedulerPool.new()
    self.logger_ = core.Logger.new(name)

end


function SocketBase:openSocket(host, port, retryConnectWhenFailure)
    -- print(host, port, retryConnectWhenFailure)
    self.retryConnectWhenFailure_ = retryConnectWhenFailure
    self.shouldConnect_ = true
    self.__host = self.__host or host
    self.__port = self.__port or port
    if not self.__host or not self.__port then
        return
    end
    if self:isConnected() then
        self.logger_:debug("isConnected true")
    elseif self.isConnecting_ then
        self.logger_:debug("isConnecting true")
    else
        self.__socket:disconnect(true)
        self.isConnecting_ = true       
        self.logger_:debugf("direct connect to %s:%s", self.__host, self.__port)
        self.__socket:connect(self.__host, self.__port, false)
        
    end
end

function SocketBase:closeSocket(noEvent)
    print("closeSocket========")
    self.shouldConnect_ = false
    self.isConnecting_ = false
    self.isConnected_ = false
    
    self.isPaused_ = false
    self.delayPackCache_ = nil
    self.retryLimit_ = 4

    -- self.__host = nil
    -- self.__port = nil
    self:unscheduleHeartBeat()
    self.__socket:disconnect(noEvent)
end

function SocketBase:setOption(opt,value)
    if self.__socket then
        self.__socket:setOption(opt,value)
    end
end

function SocketBase:isConnected()
    return self.isConnected_
end

function SocketBase:isConnecting()
    return self.isConnecting_
end

function SocketBase:pause()
    self.isPaused_ = true
    self.logger_:debug("paused event dispatching")
end

function SocketBase:resume()
    self.isPaused_ = false
    self.logger_:debug("resume event dispatching")
    if self.delayPackCache_ and #self.delayPackCache_ > 0 then
        for i, v in ipairs(self.delayPackCache_) do
            self:onReceivePacket(v.cmd,v.info)
        end
        self.delayPackCache_ = nil
    end
end

function SocketBase:sendMsg(cmd,info)
    local packetId = self:writeBegin(self.__socket,cmd);
    -- print("sendMsg --- packetId",packetId)
    self:writePacket(self.__socket,packetId,cmd,info);
    self:writeEnd(packetId);
    return true;
end

function SocketBase:createSocket()
    error("Derived class must implement this function")
end


function SocketBase:writeBegin(socket, cmd)
    error("Derived class must implement this function");
end


function SocketBase:writePacket(socket, packetId, cmd, info)
    for k,v in pairs(self.__socketWriters) do
        if v:writePacket(socket,packetId,cmd,info) then
            return true;
        end
    end

    for k,v in pairs(self.__commonSocketWriters) do
        if v:writePacket(socket,packetId,cmd,info) then
            return true;
        end
    end

    return false;
end

function SocketBase:readPacket(socket, packetId, cmd)
    print(string.format("SocketBase:readPacket packetId:%d, cmd:0x%02x", packetId, cmd))
    local packetInfo = nil; 

    for k,v in pairs(self.__socketReaders) do
        local packetInfo =  v:readPacket(socket,packetId,cmd);
        if packetInfo then
            return packetInfo;
        end
    end

    for k,v in pairs(self.__commonSocketReaders) do
        local packetInfo =  v:readPacket(socket,packetId,cmd);
        if packetInfo then
            return packetInfo;
        end
    end

    return packetInfo;
end

function SocketBase:parseMsg(packetId)
    local cmd = self:readBegin(packetId);
    local info = self:readPacket(self.__socket,packetId,cmd);
    self:readEnd(packetId);
    return cmd,info;
end

function SocketBase:writeEnd(packedId)
    -- print("SocketBase:writeEnd",packedId)
    local ret = self.__socket:writeEnd(packedId);
    return ret
    
end


function SocketBase:readBegin(packedId)
    return self.__socket:readBegin(packedId);
end

function SocketBase:readEnd(packedId)
    self.__socket:readEnd(packedId);
end

function SocketBase:reconnect_()
    self.__socket:disconnect(true)
    self.retryLimit_ = self.retryLimit_ - 1
    local isRetrying = true    
    if self.retryLimit_ > 0 or self.retryConnectWhenFailure_ then
        self.isConnecting_ = true
        self:onReconnnecting()
        self.__socket:connect(self.__host, self.__port, false)
    else
        isRetrying = false
        self.isConnecting_ = false
    end    
    return isRetrying
end

--process packet functions
function SocketBase:onSocketServerPacket(packetId)
    local cmd,info = SocketBase.parseMsg(self,packetId);
    if cmd == self.heartBeatCommand_ then
        if self.heartBeatTimeoutId_ then
            self:onHeartBeatReceived_()
        end
    else
        if self.isPaused_ then
            if not self.delayPackCache_ then
                self.delayPackCache_ = {}
            end
            self.delayPackCache_[#self.delayPackCache_ + 1] = {cmd = cmd,info = info}
            self.logger_:debugf("%s paused cmd:%x", self.__name,cmd)
        else
            self.logger_:debugf("%s dispatching cmd:%x", self.name_, cmd)
            self:onReceivePacket(cmd,info) --debug 的时候不用pcall
            -- local ret, errMsg = pcall(function() self:onReceivePacket(cmd,info) end)
            -- if errMsg then
            --     self.logger_:errorf("%s dispatching cmd:%x error %s", self.__name, cmd, errMsg)
            -- end            
        end

    end

end


function SocketBase:onHeartBeatReceived_()
    -- print("onHeartBeatReceived_=======")
    local delaySeconds = core.getTime() - self.heartBeatPackSendTime_
    if self.heartBeatTimeoutId_ then
        self.heartBeatSchedulerPool_:clear(self.heartBeatTimeoutId_)
        self.heartBeatTimeoutId_ = nil
        self.heartBeatTimeoutCount_ = 0
        self:onHeartBeatReceived(delaySeconds)
        -- self.logger_:debug("heart beat received", delaySeconds)
    else
        self.logger_:debug("timeout heart beat received", delaySeconds)
    end
end


function SocketBase:onSocketConnected()
    self.isConnected_ = true
    self.isConnecting_ = false
    self.heartBeatTimeoutCount_ = 0

    self.retryLimit_ = 4
    self:onAfterConnected()
end


function SocketBase:onSocketError()
    self.isConnected_ = false
    self.__socket:disconnect(true)
    self.logger_:debug("data error ...")    
    if not self:reconnect_() then       
        self:onAfterDataError()
        -- self:dispatchEvent({name=SocketBase.EVT_ERROR})
    end
end


function SocketBase:onSocketConnectFailed()
    self.isConnected_ = false
    self.isConnecting_ = false
    self.logger_:debug("connect failure ...")    
    if not self:reconnect_() then        
        self:onAfterConnectFailure()
    end

end

function SocketBase:onSocketClosed()
    self.isConnected_ = false
    self:unscheduleHeartBeat()
    if self.shouldConnect_ then
        if not self:reconnect_() then
            self:onAfterConnectFailure()
            -- self:dispatchEvent({name=SocketBase.EVT_CONNECT_FAIL})
            self.logger_:debug("closed and reconnect fail")
        else
            self.logger_:debug("closed and reconnecting")
        end
    else
        self.logger_:debug("closed and do not reconnect")
        -- self:dispatchEvent({name=SocketBase.EVT_CLOSED})
        self:onAfterClosed()
    end

end

function SocketBase:onSocketClose()
    self.isConnected_ = false
    self:unscheduleHeartBeat()
    self:onAfterClose()
end



function SocketBase:onReceivePacket(cmd,info)
    for k,v in pairs(self.__socketProcessers) do
        local info =  v:onReceivePacket(cmd,info);
        if info then
            return info;
        end
    end

    for k,v in pairs(self.__commonSocketProcessers) do
        local info = v:onReceivePacket(cmd,info);
        if info then
            for k,v in pairs(self.__socketProcessers) do
                if v:onCommonCmd(cmd,info) then
                    break;
                end
            end
            return;
        end
    end

    return false;
end


function SocketBase:onSocketEvent(eventType, param)
    if eventType == Socket.SocketConnected then
        -- print("eventSocket SocketConnected");
        self:onSocketConnected();
    elseif eventType == Socket.SocketConnectFailure then
        -- print("eventSocket SocketConnectFailure");
        self:onSocketConnectFailed();
    elseif eventType == Socket.SocketRecvPacket then
        -- print("eventSocket SocketRecvPacket");
        self:onSocketServerPacket(param);
    elseif eventType == Socket.SocketError then
        -- print("eventSocket SocketError");
        self:onSocketError(param);
    elseif eventType == Socket.SocketClose then
        -- print("eventSocket SocketClose");
        self:onSocketClose(param);
    elseif eventType == Socket.SocketClosed then
        -- print("eventSocket SocketClosed");
        self:onSocketClosed(param);
    end
end


function SocketBase:addSocketReader(socketReader)
    self:addSocketHandler(self.__socketReaders,SocketReader,socketReader);
end

function SocketBase:addSocketWriter(socketWriter)
    self:addSocketHandler(self.__socketWriters,SocketWriter,socketWriter);
end

function SocketBase:addSocketProcesser(socketProcesser)
    local ret = self:addSocketHandler(self.__socketProcessers,SocketProcesser,socketProcesser);
    if ret then
        socketProcesser:setSocket(self);
    end
end

function SocketBase:removeSocketReader(socketReader)
    self:removeSocketHandler(self.__socketReaders,socketReader);
end

function SocketBase:removeSocketWriter(socketWriter)
    self:removeSocketHandler(self.__socketWriters,socketWriter);
end

function SocketBase:removeSocketProcesser(socketProcesser)
    self:removeSocketHandler(self.__socketProcessers,socketProcesser);
end

function SocketBase:addCommonSocketReader(socketReader)
    self:addSocketHandler(self.__commonSocketReaders,SocketReader,socketReader);
end

function SocketBase:addCommonSocketWriter(socketWriter)
    self:addSocketHandler(self.__commonSocketWriters,SocketWriter,socketWriter);
end

function SocketBase:addCommonSocketProcesser(socketProcesser)
    local ret = self:addSocketHandler(self.__commonSocketProcessers,SocketProcesser,socketProcesser);
    if ret then
        socketProcesser:setSocket(self);
    end
end

function SocketBase:removeCommonSocketReader(socketReader)
    self:removeSocketHandler(self.__commonSocketReaders,socketReader);
end

function SocketBase:removeCommonSocketWriter(socketWriter)
    self:removeSocketHandler(self.__commonSocketWriters,socketWriter);
end

function SocketBase:removeCommonSocketProcesser(socketProcesser)
    self:removeSocketHandler(self.__commonSocketProcessers,socketProcesser);
end


function SocketBase:addSocketHandler(vtable,valueType,value)
    if value and (not iskindof(value,valueType.__cname)) then
        error("add error type to gamesocket");
    end

    if self:checkExist(vtable,value) then
        return false;
    end

    table.insert(vtable,1,value);
    return true;
end



function SocketBase:removeSocketHandler (vtable,value)
    local index = self:getIndex(vtable,value);
    if index ~= -1 then
        table.remove(vtable,index);
        return true;
    end

    return false;
end

function SocketBase:getIndex (vtable,value)
    for k,v in pairs(vtable or {}) do 
        if v == value then
            return k;
        end
    end

    return -1;
end

function SocketBase:checkExist(vtable,value)
    return self:getIndex(vtable,value) ~= -1;
end


function SocketBase:scheduleHeartBeat(command, interval, timeout)
    self.heartBeatCommand_ = command
    self.heartBeatTimeout_ = timeout
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerPool_:clearAll()
    self.heartBeatSchedulerPool_:loopCall(handler(self, self.onHeartBeat_), interval)
end

function SocketBase:unscheduleHeartBeat()
    self.heartBeatCommand_ = nil
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerPool_:clearAll()
end


function SocketBase:onHeartBeat_()
    local packetId = self:writeBegin(self.__socket,self.heartBeatCommand_)
    self:writeEnd(packetId)

    if packetId then
        if self.heartBeatTimeoutId_ then
            self.heartBeatSchedulerPool_:clear(self.heartBeatTimeoutId_)
            self.heartBeatTimeoutId_ = nil
        end
        
        self.heartBeatPackSendTime_ = core.getTime()
        self.heartBeatTimeoutId_ = self.heartBeatSchedulerPool_:delayCall(handler(self, self.onHeartBeatTimeout_), self.heartBeatTimeout_)
    end
    return true
end



function SocketBase:onHeartBeatTimeout_()
    self.heartBeatTimeoutId_ = nil
    self.heartBeatTimeoutCount_ = (self.heartBeatTimeoutCount_ or 0) + 1
    self:onHeartBeatTimeout(self.heartBeatTimeoutCount_)
    self.logger_:debug("heart beat timeout", self.heartBeatTimeoutCount_)
end

function SocketBase:onHeartBeatTimeout(timeoutCount)
    self.logger_:debug("not implemented method onHeartBeatTimeout")
end


function SocketBase:onHeartBeatReceived(delaySeconds)
    self.logger_:debug("not implemented method onHeartBeatReceived")
end


function SocketBase:onAfterConnected()

end


function SocketBase:onAfterConnectFailure()

end



function SocketBase:onAfterClose()

end


function SocketBase:onAfterClosed()
end



function SocketBase:onAfterDataError()

end


function SocketBase:onReconnnecting()

end


return SocketBase



