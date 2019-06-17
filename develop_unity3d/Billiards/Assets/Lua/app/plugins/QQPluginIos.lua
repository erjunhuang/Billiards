local PluginIosBase = import(".PluginIosBase")

local QQPluginIos = class("QQPluginIos",PluginIosBase)
local logger

function QQPluginIos:ctor()
	QQPluginIos.super.ctor(self,"QQPluginIos")
	logger = self.__logger
end


function QQPluginIos:login(callback)
	self.__loginCallback = callback
	self:call_("login", {})
end




return QQPluginIos