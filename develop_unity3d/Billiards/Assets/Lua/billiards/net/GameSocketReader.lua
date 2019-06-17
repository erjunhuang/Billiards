local GameSocketCmd = import(".GameSocketCmd")

local GameSocketReader = class("GameSocketReader",core.SocketReader)
local lpb = require "pb"
local pbConf = import(".pb.ProtoConfig")

function GameSocketReader:ctor()
	GameSocketReader.super.ctor(self)
end


function GameSocketReader:readProto(packetId,cmd)
	local buf = self.__socket:readBinary(packetId);

	print("readProto000",cmd)
	local proto = pbConf.getProto("S2C", cmd);
	local info = lpb.decode(proto,buf)
	print(json.encode(info), "GameSocketReader:readProto-------------------", cmd,os.time())
	return info;
end


GameSocketReader.s_severCmdFunMap = 
{
	[GameSocketCmd.LOGIN_GAME] = GameSocketReader.readProto,
	[GameSocketCmd.BROADCAST_USER_HIT_BALL] = GameSocketReader.readProto,
	[GameSocketCmd.BROADCAST_USER_TURN] = GameSocketReader.readProto,
	[GameSocketCmd.BROADCAST_USER_READY] = GameSocketReader.readProto,
	[GameSocketCmd.BROADCAST_USER_LOGIN_GAME]= GameSocketReader.readProto,
	[GameSocketCmd.CMD_C2GAMESER_CURLINE]= GameSocketReader.readProto,
	[GameSocketCmd.BROADCAST_USER_COLORS] = GameSocketReader.readProto,
	[GameSocketCmd.CMD_C2GAMESER_BROAD_WHITEBALL] = GameSocketReader.readProto,
	[GameSocketCmd.BROADCAST_USER_LOGOUT_GAME] = GameSocketReader.readProto,
	[GameSocketCmd.CMD_C2GAMESER_RECONNECT] = GameSocketReader.readProto,
		
}

return GameSocketReader