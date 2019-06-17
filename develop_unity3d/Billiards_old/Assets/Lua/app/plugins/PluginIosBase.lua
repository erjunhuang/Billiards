local PluginIosBase = class("PluginIosBase")

function PluginIosBase:ctor(name,nativeClass)
	self.__name = name or "PluginIosBase"
	self.__nativeClass = nativeClass
	self.__logger = core.Logger.new(self.__name)
end



function PluginIosBase:call_(ocMethodName, ocParams)
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod(self.__nativeClass, ocMethodName, ocParams)
		return ok,ret
	else
		self.__logger:debugf("call %s failed, not in ios platform", ocMethodName)
        return false, nil
	end
end

return PluginIosBase