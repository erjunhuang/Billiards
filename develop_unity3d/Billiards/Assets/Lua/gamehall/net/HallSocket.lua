local GameHttp = import(".GameHttp")
local ServerConfig = import(".ServerConfig")
local scheduler = require("misc.scheduler")

local HallCommonSocketProcesser = import(".HallCommonSocketProcesser")
local HallCommonSocketReader = import(".HallCommonSocketReader")
local HallCommonSocketWriter = import(".HallCommonSocketWriter")

--网络上报相关 start--------
local netStatusTb = {}
local netCalCount = 12
local netMoniterOpen = false

--网络上报相关 end--------

local HallSocketCmd = import(".HallSocketCmd")

local PACKET_PROC_FRAME_INTERVAL = 2
local HallSocket = class("HallSocket",core.SocketBase)

function HallSocket.getInstance()
	if not HallSocket.s_instance then 
        HallSocket.s_instance = HallSocket.new("HallSocket",core.Protocols.HS_NEW,true);
	end
	return HallSocket.s_instance;
end

function HallSocket:ctor(socketName,sockHeader,netEndian)
	print("HallSocket:ctor",socketName,sockHeader,netEndian)
	HallSocket.super.ctor(self,socketName,sockHeader,netEndian)


	self.__commonProcesser = HallCommonSocketProcesser.new()
    self.__commonWriter = HallCommonSocketWriter.new()
    self.__commonReader = HallCommonSocketReader.new()

    self:addCommonSocketReader(self.__commonReader);
    self:addCommonSocketWriter(self.__commonWriter);
    self:addCommonSocketProcesser(self.__commonProcesser);
end

function HallSocket:createSocket(socketName,sockHeader,netEndian)
	return core.Socket.new(socketName,sockHeader,netEndian)
end

function HallSocket:openSocket(host, port, retryConnectWhenFailure)
    HallSocket.super.openSocket(self,host, port, retryConnectWhenFailure or false)
end


function HallSocket:writeBegin(socket, cmd)
	local packetId = socket:writeBegin(cmd);
    return packetId;
end

function HallSocket:isConnected( ... )
    
    if self.heartBeatCommand_ then
        local packetId = self:writeBegin(self.__socket,self.heartBeatCommand_)
        if packetId then
            local ret = self:writeEnd(packetId)
            return (type(ret) == "number")
        else
            return self.isConnected_
        end
    else
        return self.isConnected_
    end

end



function HallSocket:sendMsg(cmd,info)

    if cmd == HallSocketCmd.CLI_JOIN_ROOM then
        self:joinRoom(info)
        return 
    end
    local packetId = self:writeBegin(self.__socket,cmd);
    self:writePacket(self.__socket,packetId,cmd,info);
    local ret = self:writeEnd(packetId);
    if not ret then
        print("sending packet when socket is not connected")
        if self.__host and self.__port then
            -- if (not self:isConnected()) and (not self:isConnecting()) then
                if not self:reconnect_() then        
                    self:onAfterConnectFailure()
                end
            -- end
        end
    end
    -- if self:isConnected() then
    -- local packetId = self:writeBegin(self.__socket,cmd);
    -- self:writePacket(self.__socket,packetId,cmd,info);
    --     self:writeEnd(packetId);
    --     return true;
    -- else
    --     print("sending packet when socket is not connected")
    --     if self.__host and self.__port then
    --         if (not self:isConnected()) and (not self:isConnecting()) then
                
    --             if not self:reconnect_() then        
    --                 self:onAfterConnectFailure()
    --             end
    --     end
    -- end
                
    -- end  
end


function HallSocket:__innerSendMsg(cmd,info)
    local packetId = self:writeBegin(self.__socket,cmd);
    self:writePacket(self.__socket,packetId,cmd,info);
    local ret = self:writeEnd(packetId);
    if not ret then
        print("sending packet when socket is not connected")
        if self.__host and self.__port then
            -- if (not self:isConnected()) and (not self:isConnecting()) then
                if not self:reconnect_() then        
                    self:onAfterConnectFailure()
                end
            -- end
            end
        end
    end



--加了请求php获取gameid流程
function HallSocket:joinRoom(info)
    if self.__joiningRoom then
        return
    end

    self.__joiningRoom = true
    local retryLimit = 2
    local loadGameInfoFunc
    local tinfo = info
    loadGameInfoFunc = function()
        self.__loadGameInfoReqId=GameHttp.getGameInfoByRoomCode(info.roomCode,function(data)
            self.__loadGameInfoReqId = nil
            if not data or not data.gameid then
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    scheduler.performWithDelayGlobal(function()
                        loadGameInfoFunc()
                    end, 0.1)
                else
                   self.__joiningRoom = false
                   self:__innerJoinRoom(nil,tinfo)
                end
            else
                self.__joiningRoom = false
                self:__innerJoinRoom(data.gameid,tinfo)
            end
            
        end,function(errData)
            self.__loadGameInfoReqId = nil
            retryLimit = retryLimit - 1
            if retryLimit > 0 then
                scheduler.performWithDelayGlobal(function()
                    loadGameInfoFunc()
                end, 0.1)
            else
               self.__joiningRoom = false
               self:__innerJoinRoom(nil,tinfo)
            end

        end) 
    end

    loadGameInfoFunc()
end


function HallSocket:__innerJoinRoom(gameid,tinfo)
    gameid = checkint(gameid)
    local function toJoinRoom( ... )
        self:__innerSendMsg(HallSocketCmd.CLI_JOIN_ROOM,tinfo)
    end
        
    if gameid > 0 then
        self:checkGameInstalled(gameid,toJoinRoom)
    else
        toJoinRoom()
    end
    
end

function HallSocket:checkGameInstalled(gameid,callback)
    --某些时候gameid传的是字符串，强制转换
    gameid = checkint(gameid)
    local isGameContained = game.AllGames:isGameContained(gameid)
    if not isGameContained then
        game.AlertDlg:ShowTip({msg="找不到房间"})
        return
    end
    local function __showGameDownloadDialog(gameid, handler)
        local NewGameDownloadDialog = import("gamehall.src.module.downloadgame.NewGameDownloadDialog")
        NewGameDownloadDialog.new(false, gameid, handler):showPanel_()
    end

    local function __showGameUpdateDialog(gameid, handler)
        local NewGameDownloadDialog = import("gamehall.src.module.downloadgame.NewGameDownloadDialog")
        NewGameDownloadDialog.new(true, gameid, handler):showPanel_()
    end

    local function __startGameWrapper()
        if callback then
            callback(gameid)
        end
    end

    local function __downloadGame()
        local DownloadProgressDialog = import("gamehall.src.module.downloadgame.DownloadProgressDialog")
            DownloadProgressDialog.new(gameid, __startGameWrapper):show()
    end

    local NewUpdateMgr = import("gamehall.src.update.NewUpdateMgr")

    if NewUpdateMgr.getInstance():isAssetsManagerExDownloading(gameid) then
        __downloadGame()
        return
    end

    -- 验证是否未安装
    if not game.gameManager:isGameInstalled(gameid) then
        __showGameDownloadDialog(gameid, __downloadGame)
        return
    end

    -- 验证是否已更新
    local isUpdated = NewUpdateMgr.getInstance():isGameUpdated(gameid)
    print("GameManager:startGame => isGameUpdated: ", isUpdated)
    if isUpdated then
        __startGameWrapper()
        return
    end

    local shouldUpdateCallback = function()
        __showGameUpdateDialog(gameid, function()
                local DownloadProgressDialog = import("gamehall.src.module.downloadgame.DownloadProgressDialog")
                DownloadProgressDialog.new(gameid, __startGameWrapper):show()
            end)
    end
    local noUpdateCallback = function()
        __startGameWrapper()
    end

    NewUpdateMgr.getInstance():checkGameVersionCacheOrShowCheckGameUpdateDialog(gameid, shouldUpdateCallback, noUpdateCallback)
end




function HallSocket:onSocketConnected()
    -- self:stopSocketLoop()
    -- self:startSocketLoop()
	HallSocket.super.onSocketConnected(self)
	print("HallSocket:onSocketConnected")
	self:scheduleHeartBeat(HallSocketCmd.CLISVR_HEART_BEAT,10,3)

end


function HallSocket:onHeartBeatReceived(delaySeconds)
     local signalStrength
    if delaySeconds < 0.4 then
        signalStrength = 4
    elseif delaySeconds < 0.8 then
        signalStrength = 3
    elseif delaySeconds < 1.2 then
        signalStrength = 2
    else
        signalStrength = 1
    end
    -- self.heartBeatCount_ = self.heartBeatCount_ + 1
    -- self.heartBeatDelay_ = self.heartBeatDelay_ + delaySeconds
    core.DataProxy:setData(game.dataKeys.SIGNAL_STRENGTH, signalStrength)
    if game and game.CommonTipManager then
        game.CommonTipManager:playReconnectingAnim(false)
    end



    if game and game.userData and game.userData["networklog"] then
        netCalCount = game.userData["networklog"]["num"] or 12
        netMoniterOpen = checkint(game.userData["networklog"]["isopen"]) == 1 and true or false
        print("netCalCount:",netCalCount,"netMoniterOpen:",netMoniterOpen)
        if netMoniterOpen and netStatusTb then
            if #netStatusTb < netCalCount then
                table.insert(netStatusTb,{checknumber(string.format("%.03f",delaySeconds)),os.time()})
            else
                --
                local jstr = json.encode(netStatusTb)
                print("网络检测上报",jstr)
                --上报
                netStatusTb = {}

                self:reportNetStatus(jstr)
            end
        end
    end

    

    -- self:onReceivePacket(HallSocketCmd.CLISVR_HEART_BEAT,{})
    
end


function HallSocket:displse()
	self:removeCommonSocketReader();
	self:removeCommonSocketWriter();
	self:removeCommonSocketProcesser();
	self.__commonProcesser = nil;
    self.__commonWriter = nil;
    self.__commonReader = nil;

end


function HallSocket:onReceivePacket(cmd,info)
    -- if not self.packetCache_ then
    --     self.packetCache_ = {}
    -- end
    -- local pack = {}
    -- pack.cmd = cmd
    -- pack.info = info
    -- table.insert(self.packetCache_, pack)
    if game and game.CommonTipManager then
        game.CommonTipManager:playReconnectingAnim(false)
    end

    -- return true
    return HallSocket.super.onReceivePacket(self,cmd,info)
end



--启动socket事件循环
function HallSocket:startSocketLoop()
    do return end
    self.packetCache_ = {}
    self.frameNo_ = 1
    if not self.schedulerPool_ then
        self.schedulerPool_ = core.SchedulerPool.new()
    end
    
    self.schedulerPool_:loopCall(handler(self, self.onEnterFrame_), 1 / 60)
end

function HallSocket:stopSocketLoop( ... )
    do return end
    self.packetCache_ = {}
    self.frameNo_ = 1
    if self.schedulerPool_ then
        self.schedulerPool_:clearAll()
    end
    
end

function HallSocket:onEnterFrame_(dt)
    if #self.packetCache_ > 0 then
        if #self.packetCache_ == 1 then
            self.frameNo_ = 1
            local pack = table.remove(self.packetCache_, 1)
            self:processPacket_(pack)
        else
            self.frameNo_ = self.frameNo_ + 1
            if self.frameNo_ >= PACKET_PROC_FRAME_INTERVAL then
                self.frameNo_ = 1
                local pack = table.remove(self.packetCache_, 1)
                self:processPacket_(pack)
            end
        end
    end
    return true
end

function HallSocket:processPacket_(pack)
    for k,v in pairs(self.__socketProcessers) do
        local info =  v:onReceivePacket(pack.cmd,pack.info);
        if info then
            return info;
        end
    end

    for k,v in pairs(self.__commonSocketProcessers) do
        local info = v:onReceivePacket(pack.cmd,pack.info);
        if info then
            for k,v in pairs(self.__socketProcessers) do
                if v:onCommonCmd(pack.cmd,info) then
                    break;
                end
            end
            return;
        end
    end
end

function HallSocket:onReconnnecting()
    --连接失败，更换端口
    if self.retryLimit_ and self.retryLimit_ < 3 then
        self:setNewServerHost(true)
    else
        self:setNewServerHost(false)
    end
    
    if game and game.CommonTipManager then
        game.CommonTipManager:playReconnectingAnim(true,"网络状况不佳\n正在链接网络")
    end
end


function HallSocket:onAfterConnected()   

    self:onReceivePacket(HallSocketCmd.SERVER_COMMAND_CONNECTED,{})

    -- if game and game.CommonTipManager then
    --     game.CommonTipManager:playReconnectingAnim(false)
    -- end
end


function HallSocket:onAfterClosed()
    if game and game.CommonTipManager then
        game.CommonTipManager:playReconnectingAnim(false)
    end
end

function HallSocket:onAfterClose()
    if game and game.CommonTipManager then
        game.CommonTipManager:playReconnectingAnim(false)
    end
end


function HallSocket:onAfterConnectFailure()
    -- self:onFail_(consts.SVR_ERROR.ERROR_CONNECT_FAILURE)
    self:onReceivePacket(HallSocketCmd.SERVER_CONNECT_FAILURE,{})

    --连接失败，更换端口
    self:setNewServerHost()
    if game and game.CommonTipManager then
        game.CommonTipManager:playReconnectingAnim(false)
    end


end


function HallSocket:setNewServerHost(isHighDefense)
    isHighDefense = (isHighDefense == nil or isHighDefense == true) and true or false

    local tIp,tPort
     --连接失败，更换端口
    if isHighDefense then
        tIp,tPort = ServerConfig.getHighDefenseRandomHost()
    else
        tIp,tPort = ServerConfig.getNormalRandomHost()
    end
    
    if tIp and tPort then
        self.__host = tIp
        self.__port = tPort
    end
    -- self:reportCallStack()
end


function HallSocket:onAfterDataError()
    self:onAfterConnectFailure()
end


function HallSocket:onHeartBeatTimeout(timeoutCount)
    core.DataProxy:setData(game.dataKeys.SIGNAL_STRENGTH, 1)
    if timeoutCount >= 2 then
        -- self:onFail_(consts.SVR_ERROR.ERROR_HEART_TIME_OUT)
        self:onReceivePacket(HallSocketCmd.SERVER_HEART_TIME_OUT,{})
        self:closeSocket(true)
        self:setNewServerHost()
    end


    if game and game.userData and game.userData["networklog"] then
        netMoniterOpen = checkint(game.userData["networklog"]["isopen"]) == 1 and true or false
        print("netCalCount:",netCalCount,"netMoniterOpen:",netMoniterOpen)
        if netMoniterOpen and netStatusTb then
            table.insert(netStatusTb,{-1,os.time()})
            local jstr = json.encode(netStatusTb)
            --上报
            netStatusTb = {}

            self:reportNetStatus(jstr)
        end


    end
    
end

function HallSocket:closeSocket(noEvent,doClean)
    noEvent = (noEvent == nil and true or noEvent)
    HallSocket.super.closeSocket(self,noEvent)
    if doClean then
        self.__port = nil
        self.__host = nil
    end

    -- self:stopSocketLoop()
end

function HallSocket:onFail_(errorCode)   
    -- core.EventCenter:dispatchEvent({name=nk.eventNames.SVR_ERROR, data=errorCode})
end


function HallSocket:reportNetStatus(netInfo)
    if GameHttp then
        GameHttp.reportNetLog(netInfo)
    end
end

function HallSocket:reportIp()   
    self:sendMsg(HallSocketCmd.C2GATE_REPORT_IP,{ip = game.userData.ip})
end



function HallSocket:reportCallStack( ... )
    -- if game and game.userData and checkint(game.userData["reportingLuaError"]) == 1 then
    --     if buglyReportLuaException then
    --         buglyReportLuaException("reportCallStackNew",debug.traceback())
    --     end
    -- end
    
end

return HallSocket