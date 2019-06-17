
local SocketWriter = class("SocketWriter")

function SocketWriter:ctor()
	self.__socket = nil;	-- 操作的套接字
end

function SocketWriter:writePacket(socket, packetId, cmd, info)
	self.__socket = socket;

	if self.s_clientCmdFunMap[cmd] then
		self.s_clientCmdFunMap[cmd](self,packetId,info,cmd);
		return true;
	end

	return false;
end

SocketWriter.s_clientCmdFunMap = {
};



return SocketWriter