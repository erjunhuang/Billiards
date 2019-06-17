local GameSocketCmd = import(".GameSocketCmd")
local GameSocketWriter = class("GameSocketWriter",core.SocketWriter)
local lpb = require "pb"
local pbConf = import(".pb.ProtoConfig")


function GameSocketWriter:ctor()
	GameSocketWriter.super.ctor(self)
end

function GameSocketWriter:writeProto(packetId,info,cmd)
	local proto = pbConf.getProto("C2S", cmd);
	-- print("GameSocketWriter:writeProto",proto)
	if proto and info then
		local buf = lpb.encode(proto,info)
		self.__socket:writeBinary(packetId,buf)
	end
	
end

--登出消息是空
function GameSocketWriter:logout(packetId,info,cmd)

end
--申请解散房间
function GameSocketWriter:sendDissRoom(packetId,info)
	printInfo("GameSocketWriter:sendDissRoom")
	self.__socket:writeByte(packetId,1)
end

--其他玩家确认解散与否 1:同意，2:不同意
function GameSocketWriter:sendDissConfirm(packetId,info)
	printInfo("GameSocketWriter:sendDissConfirm")
	self.__socket:writeByte(packetId,info.isDissRoom)
end
--请求退出房间
function GameSocketWriter:sendLoginOut(packetId,info)
	print("send..loginout.0x1802")
end
GameSocketWriter.s_clientCmdFunMap = 
{
	[GameSocketCmd.LOGIN_GAME] = GameSocketWriter.writeProto,
	[GameSocketCmd.USER_READY] = GameSocketWriter.writeProto,
	[GameSocketCmd.LOGOUT_GAME]	= GameSocketWriter.logout,
	[GameSocketCmd.USER_CHANGE_TRUST]	= GameSocketWriter.writeProto,
	[GameSocketCmd.USER_OUT_CARD]	= GameSocketWriter.writeProto,
	[GameSocketCmd.CLE_SEND_DISS_ROOM]	= GameSocketWriter.sendDissRoom,
	[GameSocketCmd.CLE_SEND_DISS_ROOM_CONFIRM]	= GameSocketWriter.sendDissConfirm,
	[GameSocketCmd.LOGOUT_GAME] = GameSocketWriter.sendLoginOut,
	[GameSocketCmd.REPORT_HIT_BALL_RESULT] = GameSocketWriter.writeProto,

	[GameSocketCmd.USER_HIT_BALL] = GameSocketWriter.writeProto,
	[GameSocketCmd.CMD_C2GAMESER_CURLINE]= GameSocketWriter.writeProto,
	[GameSocketCmd.CMD_C2GAMESER_BROAD_WHITEBALL] = GameSocketWriter.writeProto,
}

return GameSocketWriter