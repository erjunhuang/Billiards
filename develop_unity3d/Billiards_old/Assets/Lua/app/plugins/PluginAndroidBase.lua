local PluginAndroidBase = class("PluginAndroidBase")

function PluginAndroidBase:ctor(name,nativeClass)
	self.__name = name or "PluginAndroidBase"
	self.__nativeClass = nativeClass
	self.__logger = core.Logger.new(self.__name)
end




function PluginAndroidBase:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(self.__nativeClass, javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                self.__logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
            elseif ret == -2 then
                self.__logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
            elseif ret == -3 then
                self.__logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
            elseif ret == -4 then
                self.__logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
            elseif ret == -5 then
                self.__logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
            elseif ret == -6 then
                self.__logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
            end
        end
        return ok, ret
    else
        self.__logger:debugf("call %s failed, not in android platform", javaMethodName)
        return false, nil
    end
end



return PluginAndroidBase