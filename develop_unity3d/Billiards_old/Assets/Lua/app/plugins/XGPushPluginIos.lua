local PluginIosBase = import(".PluginIosBase")
local XGPushPluginIos = class("XGPushPluginIos",PluginIosBase)

function XGPushPluginIos:ctor()
	XGPushPluginIos.super.ctor(self,"XGPushPluginIos","XGPushBridge")
	self:init()
end


function XGPushPluginIos:init()

	if not self.isInit_ then
		self:call_("setPushNotify", {listener = handler(self,self.onPushNotify)})
		self:call_("getPushToken")
		self.isInit_ = true
	end
	
end

function XGPushPluginIos:onPushNotify(jsonObj)
	if not jsonObj then
		return 
	end

	local ptype = jsonObj.ptype
	if ptype == "userInfo" then
		self:handlePushUserInfo(jsonObj)
	elseif ptype == "nothing" then
		self:handlerPushNothing(jsonObj)
	elseif ptype == "updateToken" then
		self:handlerUpdateToken(jsonObj)
	end

end

function XGPushPluginIos:handlerUpdateToken(jsonObj)
	dump(jsonObj,"handlerUpdateToken")
	local token = jsonObj.token
	if token and token ~= "" then
	end
end

function XGPushPluginIos:handlePushUserInfo(jsonObj)
	dump(jsonObj,"handlePushUserInfo")
	local pfrom = jsonObj.pfrom
	if pfrom == "click" then
		--点击通知栏

	elseif pfrom == "foreground" then
		--游戏运行中，透传


	end
	
end

function XGPushPluginIos:handlerPushNothing(jsonObj)
	dump(jsonObj,"handlerPushNothing")
	local pfrom = jsonObj.pfrom

	if pfrom == "click" then
		--点击通知栏

	elseif pfrom == "foreground" then
		--游戏运行中，透传


	end

end




return XGPushPluginIos