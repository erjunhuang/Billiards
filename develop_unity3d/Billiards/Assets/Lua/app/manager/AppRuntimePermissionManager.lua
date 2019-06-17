--- 增加一个运行时权限管理类，待实现
local AppRuntimePermissionManager = class("AppRuntimePermissionManager")

local s_instance = nil
function AppRuntimePermissionManager.getInstance()
	if not s_instance then
		s_instance = AppRuntimePermissionManager.new()
	end
	return s_instance
end

AppRuntimePermissionManager.ANDROID_DANGEROUS_PERMISSIONS = {
	RECORD_AUDIO = "android.permission.RECORD_AUDIO",
}

--- Lua请求码从40000开始
AppRuntimePermissionManager.ANDROID_PERMISSION_REQUEST_CODES = {
	RECORD_AUDIO = 40000,
}

--- 提供简写
AppRuntimePermissionManager.adp = AppRuntimePermissionManager.ANDROID_DANGEROUS_PERMISSIONS
AppRuntimePermissionManager.apr = AppRuntimePermissionManager.ANDROID_PERMISSION_REQUEST_CODES

function AppRuntimePermissionManager:ctor()
end

local PERMISSION_NAME_SEPERATOR = ","

local innerAndroidCall = function(javaClassName, javaMethodName, javaParams, javaMethodSig)
	if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                print(string.format("call %s failed, -1 不支持的参数类型或返回值类型", tostring(javaMethodName)))
            elseif ret == -2 then
                print(string.format("call %s failed, -2 无效的签名", tostring(javaMethodName)))
            elseif ret == -3 then
                print(string.format("call %s failed, -3 没有找到指定的方法", tostring(javaMethodName)))
            elseif ret == -4 then
                print(string.format("call %s failed, -4 Java 方法执行时抛出了异常", tostring(javaMethodName)))
            elseif ret == -5 then
                print(string.format("call %s failed, -5 Java 虚拟机出错", tostring(javaMethodName)))
            elseif ret == -6 then
                print(string.format("call %s failed, -6 Java 虚拟机出错", tostring(javaMethodName)))
            end
        end
        return ok, ret
    else
        print(string.format("call %s failed, not in android platform", tostring(javaMethodName)))
        return false, nil
    end
end

---------------------------------------------------------Android端接口 start------------------------------------------------------------

--- 判断运行时是否具备某个特定权限
-- @param permissionName 某一特定安卓权限字符串，可到官网文档查询：https://developer.android.com/reference/android/Manifest.permission.html
-- @return true 或者 false，异常为nil
function AppRuntimePermissionManager:hasPermissionInAndroid(permissionName)
	if type(permissionName) == "string" then
		local ok, ret = innerAndroidCall("org.ode.cocoslib.core.functions.RuntimePermissionFunction", 
			"hasPermission", 
			{permissionName}, 
			"(Ljava/lang/String;)Z")
		if ok then
			print("AppRuntimePermissionManager:hasPermissionInAndroid(", permissionName, ") => ", ret)
			return ret
		end
	end
	return nil
end

--- 判断运行时是否具备某些特定权限
-- @param permissionNamesTab 权限名称数组{a,b,c,d}
-- @return {权限名称：true或false}的表，异常为nil
function AppRuntimePermissionManager:hasPermissionsInAndroid(permissionNamesTab)
	if type(permissionName) == "table" then
		local permissionNamesStr = table.concat(permissionNamesTab,PERMISSION_NAME_SEPERATOR)
		local ok, ret = innerAndroidCall("org.ode.cocoslib.core.functions.RuntimePermissionFunction", 
			"hasPermissions", 
			{permissionNamesStr}, 
			"(Ljava/lang/String;)Ljava/lang/String;")
		if ok then
			local tab = json.decode(ret);
			dump(tab, "AppRuntimePermissionManager:hasPermissionsInAndroid => result:")
			return tab
		end
	end
	return nil
end

--- 请求运行时权限
-- @param permissionNamesTab 权限名称数组{a,b,c,d}
-- @param androidRequestCode 请求code，要求唯一且不能与其他请求码冲突
-- @param callback 回调函数，参数格式为(是否调用成功true或false，请求code， {权限名称：是否获得权限true或false}表)
-- @return 无
function AppRuntimePermissionManager:requestPermissionsInAndroid(permissionNamesTab, androidRequestCode, callback)
	if type(permissionNamesTab) == "table" and type(callback) == "function" then
		local permissionNamesStr = table.concat(permissionNamesTab,PERMISSION_NAME_SEPERATOR)
		local innerCallback = function(retStr)
			local retTab = json.decode(retStr)
			if retTab then
				local code = retTab.requestCode
				local result = retTab.result
				print("AppRuntimePermissionManager:requestPermissionsInAndroid => code:", code)
				dump(result, "AppRuntimePermissionManager:requestPermissionsInAndroid => result:")
				callback(true, code, result)
			end
		end
		local ok, ret = innerAndroidCall("org.ode.cocoslib.core.functions.RuntimePermissionFunction", 
			"requestPermissions", 
			{permissionNamesStr, androidRequestCode, innerCallback},
			"(Ljava/lang/String;II)V")
		if not ok then
			callback(false, nil, nil)
		end
	end
end
---------------------------------------------------------Android端接口 end------------------------------------------------------------

if game.isFullVersionNewer(game.getAppVersion(), "1.0.10", true) then
--对外接口
function AppRuntimePermissionManager:hasAudioPermissionInIos()
	local ok,authStatus = false,0
	if device.platform == "ios" then
		ok,authStatus = luaoc.callStaticMethod("PermissionsManager","isopenAudioPermission",nil)
	end
	return authStatus
end

function AppRuntimePermissionManager:requestSettingPermissionWithKey(authStatus,key)
	if device.platform == "ios" then
		luaoc.callStaticMethod("PermissionsManager","requestSettingPermissionWithKey",{authStatus = authStatus,key = key})
	end
end
end-- end game.isFullVersionNewer(game.getAppVersion(), "1.0.10", true)

return AppRuntimePermissionManager