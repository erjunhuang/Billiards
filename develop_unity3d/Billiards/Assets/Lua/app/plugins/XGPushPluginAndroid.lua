local PluginAndroidBase = import(".PluginAndroidBase")
local XGPushPluginAndroid = class("XGPushPluginAndroid",PluginAndroidBase)


function XGPushPluginAndroid:ctor()
	XGPushPluginAndroid.super.ctor(self,"XGPushPluginAndroid","org.ode.cocoslib.xingepush.XGPushBridge")
	self:init()
end


function XGPushPluginAndroid:init()

	if not self.isInit_ then
		self:call_("setPushNotify", {handler(self,self.onPushNotify)},"(I)V")
		self:call_("getPushToken",{},"()V")
		self.isInit_ = true
	end
	
end

function XGPushPluginAndroid:onPushNotify(jsonStr)

	print("XGPushPluginAndroid:onPushNotify",jsonStr)
	local jsonObj = json.decode(jsonStr)
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

function XGPushPluginAndroid:handlerUpdateToken(jsonObj)

	dump(jsonObj,"handlerUpdateToken")
	local token = jsonObj.token
	if token and token ~= "" then
	end
end

function XGPushPluginAndroid:handlePushUserInfo(jsonObj)
	dump(jsonObj,"handlePushUserInfo")
	local pfrom = jsonObj.pfrom
	if pfrom == "click" then
		--点击通知栏

	elseif pfrom == "foreground" then
		--游戏运行中，透传


	end
	
end

function XGPushPluginAndroid:handlerPushNothing(jsonObj)
	dump(jsonObj,"handlerPushNothing")
	local pfrom = jsonObj.pfrom

	if pfrom == "click" then
		--点击通知栏,启动或跳转到app
		
	elseif pfrom == "foreground" then
		--游戏运行中，透传


	end

end


return XGPushPluginAndroid