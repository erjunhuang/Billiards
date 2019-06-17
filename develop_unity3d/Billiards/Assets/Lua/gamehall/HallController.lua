local HallSocketCmd = import(".net.HallSocketCmd")
local HallSocketProcesser = import(".net.HallSocketProcesser")
local HallSocketReader = import(".net.HallSocketReader")
local HallSocketWriter = import(".net.HallSocketWriter")

local HallController = class("HallController",game.base.BaseController)



function HallController:ctor(scene)
	HallController.super.ctor(self,scene)
	local uid = 9998
	game.userData = 
	{
		["aUser.mid"] = uid,
		["aUser.name"] = "test" .. tostring(uid),
		["mid"] = uid
	}

	--test socket--
	game.server:openSocket("192.168.1.158",3335,true)
end



function HallController:addSocketTools()
	HallController.super.addSocketTools(self)
	self.__socket = game.server
	if self.__socket then
		self._hallSocketProcesser = HallSocketProcesser.new(self)
		self._hallSocketReader = HallSocketReader.new()
		self._hallSocketWriter = HallSocketWriter.new()

		self.__socket:addSocketReader(self._hallSocketReader)
		self.__socket:addSocketWriter(self._hallSocketWriter)
		self.__socket:addSocketProcesser(self._hallSocketProcesser)
	end
end



function HallController:removeSocketTools()
	HallController.super.removeSocketTools(self)
	if self.__socket then
		self.__socket:removeSocketReader(self._hallSocketReader)
		self.__socket:removeSocketWriter(self._hallSocketWriter)
		self.__socket:removeSocketProcesser(self._hallSocketProcesser)
	end

end


--游客登录
function HallController:loginWithGuest(isDebug,token)


	game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    game.userDefault:flush()
    game.LoginManager:login(game.LoginManager.LOGIN_TYPE_GUEST,handler(self,self.onLoginSucc_),handler(self,self.onLoginError_),isDebug,token)
    -- self.view_:setLoading(true,nil,"登录中...")
end


function HallController:getTableId( ... )
	-- body
	if self.__socket then
				local info = {}
				info.ver = 1
				info.level = 101
				self.__socket:sendMsg(HallSocketCmd.CLI_GET_TID,info)
			end
end




function HallController:onGetTableId( ... )
	-- body
	SceneManager.LoadScene("Billiard",SceneManagement.LoadSceneMode.Single);
end

function HallController:onLoginSerSucc( ... )
	-- body
end


function HallController:onSocketLoginTimeOut( ... )
	-- body
end


HallController.s_socketCmdFuncMap = {
	-- [HallSocketCmd.SVR_DOUBLE_LOGIN] = HallController.onUserDoubleLogin,
	-- [HallSocketCmd.SERVER_CONNECT_FAILURE]   = HallController.onSocketConnectFail,
	-- [HallSocketCmd.SERVER_HEART_TIME_OUT] = HallController.onSocketHeartTimeOut,
	[HallSocketCmd.SERVER_LOGIN_TIME_OUT] = HallController.onSocketLoginTimeOut,
	-- [HallSocketCmd.SVR_JOIN_ROOM_SICC] = HallController.onJoinRoomSucc,
	[HallSocketCmd.SVR_GET_TID] = HallController.onGetTableId,
	-- [HallSocketCmd.SVR_BROAD_SINGLE_SINGLE] = HallController.onBroadSinglelUser,
	[HallSocketCmd.SVR_LOGIN] = HallController.onLoginSerSucc,
	-- [HallSocketCmd.SVR_PRIVATE_ROOM_ERR] = HallController.onPrivateRoomErr,
};







return HallController