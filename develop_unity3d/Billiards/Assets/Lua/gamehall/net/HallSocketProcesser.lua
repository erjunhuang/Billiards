local HallSocketCmd = import(".HallSocketCmd")

local HallSocketProcesser = class("HallSocketProcesser",core.SocketProcesser)

function HallSocketProcesser:ctor(controller)
	HallSocketProcesser.super.ctor(self,controller)
end

function HallSocketProcesser:onGetTableId(packetInfo)
	dump(packetInfo,"HallSocketProcesser:onGetTableId===")

	self.__controller:handleSocketCmd(HallSocketCmd.SVR_GET_TID,packetInfo)
end


function HallSocketProcesser:onUserDoubleLogin(packetInfo)
	self.__controller:handleSocketCmd(HallSocketCmd.SVR_DOUBLE_LOGIN,packetInfo)
end


function HallSocketProcesser:onSocketConnectFail(packetInfo)
	self.__controller:handleSocketCmd(HallSocketCmd.SERVER_CONNECT_FAILURE,packetInfo)
end


function HallSocketProcesser:onSocketHeartTimeOut(packetInfo)
	self.__controller:handleSocketCmd(HallSocketCmd.SERVER_HEART_TIME_OUT,packetInfo)
end

function HallSocketProcesser:onSocketLoginTimeOut(packetInfo)
	self.__controller:handleSocketCmd(HallSocketCmd.SERVER_LOGIN_TIME_OUT,packetInfo)
end

function HallSocketProcesser:onJoinRoomSucc(packetInfo)
	self.__controller:handleSocketCmd(HallSocketCmd.SVR_JOIN_ROOM_SICC,packetInfo)
end

function HallSocketProcesser:onBroadSinglelUser(info)
	self.__controller:handleSocketCmd(HallSocketCmd.SVR_BROAD_SINGLE_SINGLE, info)
end

function HallSocketProcesser:onBroadMutilUser(packetInfo)
	local type = packetInfo.type
	local content = packetInfo.content
	dump(packetInfo,"HallSocketProcesser:onBroadMutilUser")
	if type == 3 then
		-- 俱乐部牌桌游戏邀请
		core.DataProxy:setData(game.dataKeys.CLUB_INVITE_DATA, content)
	end
	
end


function HallSocketProcesser:onLoginSerSucc(info)
	self.__controller:handleSocketCmd(HallSocketCmd.SVR_LOGIN, info)
end



function HallSocketProcesser:onPrivateRoomErr(info)
	self.__controller:handleSocketCmd(HallSocketCmd.SVR_PRIVATE_ROOM_ERR, info)
end


HallSocketProcesser.s_severCmdEventFuncMap = 
{
	
}


HallSocketProcesser.s_commonCmdHandlerFuncMap = 
{
	[HallSocketCmd.SVR_GET_TID] = HallSocketProcesser.onGetTableId,
	[HallSocketCmd.SVR_DOUBLE_LOGIN] = HallSocketProcesser.onUserDoubleLogin,
	[HallSocketCmd.SERVER_CONNECT_FAILURE]   = HallSocketProcesser.onSocketConnectFail,
	[HallSocketCmd.SERVER_HEART_TIME_OUT] = HallSocketProcesser.onSocketHeartTimeOut,
	[HallSocketCmd.SERVER_LOGIN_TIME_OUT] = HallSocketProcesser.onSocketLoginTimeOut,
	[HallSocketCmd.SVR_JOIN_ROOM_SICC]	= HallSocketProcesser.onJoinRoomSucc,
	[HallSocketCmd.SVR_BROAD_MUTIL_USER] = HallSocketProcesser.onBroadMutilUser,
	[HallSocketCmd.SVR_BROAD_SINGLE_SINGLE] = HallSocketProcesser.onBroadSinglelUser,
	[HallSocketCmd.SVR_LOGIN] = HallSocketProcesser.onLoginSerSucc,
	[HallSocketCmd.SVR_PRIVATE_ROOM_ERR] = HallSocketProcesser.onPrivateRoomErr,
	
}

return HallSocketProcesser