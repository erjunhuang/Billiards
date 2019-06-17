local SocketReader = class("SocketReader");

function SocketReader:ctor()
	self.__socket = nil;	
end

function SocketReader:readPacket(socket, packetId, cmd)
	self.__socket = socket;

	local packetInfo = nil;
	if self.s_severCmdFunMap[cmd] then
		packetInfo = self.s_severCmdFunMap[cmd](self,packetId,cmd);
	end 
	
	return packetInfo;
end

SocketReader.s_severCmdFunMap = {

};


return SocketReader