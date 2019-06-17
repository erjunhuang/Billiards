local PluginAndroidBase = import(".PluginAndroidBase")
local QQPluginAndroid = class("QQPluginAndroid",PluginAndroidBase)

local logger

function QQPluginAndroid:ctor()
	QQPluginAndroid.super.ctor(self,"QQPluginAndroid")
	logger = self.__logger
	self.__onLoginCallback = handler(self,self.onLoginCallback_)
	
end



function QQPluginAndroid:login(callback)
	self.__loginCallback = callback
	self:call_("login", {}, "()V")
end



function QQPluginAndroid:onLoginCallback_()
	
end




return QQPluginAndroid