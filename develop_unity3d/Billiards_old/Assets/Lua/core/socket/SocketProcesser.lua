local SocketProcesser = class("SocketProcesser");

function SocketProcesser:ctor(controller)
	self.__controller = controller;
end 

function SocketProcesser:setSocket(socketManager)
	self.__socket = socketManager;
end

function SocketProcesser:onReceivePacket (cmd,packetInfo)
    if self.s_severCmdEventFuncMap[cmd] then
        local info = self.s_severCmdEventFuncMap[cmd](self,packetInfo,cmd);
        return info or {};
    end
    return nil;
end

function SocketProcesser:onCommonCmd(cmd,...)
	if self.s_commonCmdHandlerFuncMap[cmd] then
        local info = self.s_commonCmdHandlerFuncMap[cmd](self,...);
        return info;
    end
    return false;
end

SocketProcesser.s_severCmdEventFuncMap = {
	
};

SocketProcesser.s_commonCmdHandlerFuncMap = {
	
};


return SocketProcesser