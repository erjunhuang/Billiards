

local LuaJavaBridge = class("LuaJavaBridge")
local logger = core.Logger.new("LuaJavaBridge")

function LuaJavaBridge:ctor()
end

function LuaJavaBridge:call_(javaClassName, javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
            elseif ret == -2 then
                logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
            elseif ret == -3 then
                logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
            elseif ret == -4 then
                logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
            elseif ret == -5 then
                logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
            elseif ret == -6 then
                logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
            end
        end
        return ok, ret
    else
        logger:debugf("call %s failed, not in android platform", javaMethodName)
        return false, nil
    end
end

-- 20171107新增接口，为了版本兼容，暂时先不要调用
-- 获取Android应用(自身)的描述信息
function LuaJavaBridge:getManifestInformations()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/ManifestFunction", 
        "getManifestInformations", {}, "()Ljava/lang/String;")
    local infos = {}
    if ok then
        local tmp = json.decode(ret)
        if tmp and type(tmp) == "table" then
            infos = tmp
        end
    end
    -- String packageName
    -- int versionCode
    -- String versionName
    -- long lastUpdateTime
    -- String appName
    logger.debug(infos)
    return infos
end

-- 改变界面的横竖状态
--[[
    public static final int ORIENTATION_UNKNOWN = 0;
    public static final int ORIENTATION_LANDSCAPE = 1;
    public static final int ORIENTATION_PORTRAIT = 2;
    public static final int ORIENTATION_SENSOR_LANDSCAPE = 3;
    public static final int ORIENTATION_SENSOR_PORTRAIT = 4;
]]
LuaJavaBridge.ORIENTATION = {}
LuaJavaBridge.ORIENTATION.ORIENTATION_UNKNOWN = 0
LuaJavaBridge.ORIENTATION.ORIENTATION_LANDSCAPE = 1
LuaJavaBridge.ORIENTATION.ORIENTATION_PORTRAIT = 2
LuaJavaBridge.ORIENTATION.ORIENTATION_SENSOR_LANDSCAPE = 3
LuaJavaBridge.ORIENTATION.ORIENTATION_SENSOR_PORTRAIT = 4
function LuaJavaBridge:changeScreenOrientation(toOrientation, callback)
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/OrientationFunction",
        "changeScreenOrientation", {toOrientation, callback}, "(II)V")
end

--[[
    获取当前的屏幕方向，注意设置屏幕方向是异步的，获取屏幕方向是同步的
    使用的时候需要注意可能由于多线程导致的问题（虽然概率很低）
    另外，安卓原生只能返回：
    LuaJavaBridge.ORIENTATION.ORIENTATION_UNKNOWN = 0 -- 对应安卓端的UnDefine
    LuaJavaBridge.ORIENTATION.ORIENTATION_LANDSCAPE = 1
    LuaJavaBridge.ORIENTATION.ORIENTATION_PORTRAIT = 2
]]
function LuaJavaBridge:getCurrentScreenOrientation()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/OrientationFunction",
        "getCurrentScreenOrientation", {}, "()I")
    if ok then
        return ret
    end
    return LuaJavaBridge.ORIENTATION.ORIENTATION_UNKNOWN
end

-- 20171107新增接口，为了版本兼容，暂时先不要调用
-- 安装apk，安装前请先移动到apkdownloads目录
function LuaJavaBridge:installApk(apkPath)
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/APKFunction",
        "installApk", {apkPath}, "(Ljava/lang/String;)V")
    return ok
end

-- 20171109新增接口，为了版本兼容，暂时先不要调用
-- 获取未安装的apk的信息
function LuaJavaBridge:getAPKInformations(apkPath)
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/APKFunction",
        "getAPKInformations", {apkPath}, "(Ljava/lang/String;)Ljava/lang/String;")
    local infos = {}
    if ok then
        local tmp = json.decode(ret)
        if tmp and type(tmp) == "table" then
            infos = tmp
        end
    end
    -- String packageName
    -- String versionName
    -- int versionCode
    logger.debug(infos)
    return infos
end


--[[/**
 * @param patchPath 差分包绝对路径
 * @param desApkPath 生成的apk的绝对路径
 * @return 1:仅仅调用API成功，具体以回调结果ret为准  ret: 1:成功 other:失败
 */]]
 -- 20171109新增接口，为了版本兼容，暂时先不要调用
function LuaJavaBridge:genApk(patchPath,desApkPath,callback)
    print("LuaJavaBridge:genApk")
    if type(callback) ~= "function" then return end
    local ok, ret = self:call_("org/ode/cocoslib/patchupdate/PatchUpdateBridge", "genApk", {patchPath,desApkPath,callback}, "(Ljava/lang/String;Ljava/lang/String;I)I")
    print("LuaJavaBridge:genApk:" .. tostring(od) .. tostring(ret))
end

function LuaJavaBridge:getNetworkType()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetInternetConnectionStatus", "getInternetConnectionStatus", {}, "()I")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:openLocation()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/OpenSettingFunction", "openSetting", {}, "()I")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:getMac()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetMacFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:getMacAddr()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetMacFunction", "getMacAddr", {}, "()Ljava/lang/String;")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:vibrate(time)
    time = time or 500 --0.5秒就行
    self:call_("org/ode/cocoslib/core/functions/GetDeviceInfoFunction", "vibrate", {time}, "(I)V")
end

function LuaJavaBridge:getFixedWidthText(font, size, text, width)
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetFixedWidthTextFunction", "apply", {font or "", size or 20, text or "", width or device.display.widthInPixels}, "(Ljava/lang/String;ILjava/lang/String;I)Ljava/lang/String;")
    if ok then
        return ret or ""
    end
    return ""
end

function LuaJavaBridge:getIDFA()
    local deviceInfo = self:getDeviceInfo()
    return deviceInfo.deviceId or self:getMacAddr() or 'android_idfa_nil'
end


function LuaJavaBridge:getAppVersion()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetAppVersionFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret or ""
    end
    return ""
end

function LuaJavaBridge:getAppBundleId()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetAppVersionFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret or ""
    end
    return ""
end

function LuaJavaBridge:getDeviceInfo()
    local deviceInfo = {deviceId = "", deviceModel = "",networkType = ""}
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetDeviceInfoFunction", "apply", {}, "()Ljava/lang/String;")
    print(ok,ret,"LuaJavaBridge:getDeviceInfo")
    if ok and ret ~= "" then
        deviceInfo = json.decode(ret)
    end
    return deviceInfo
end

function LuaJavaBridge:getLoginToken()
    return core.encodeBase64(self:getMac() .. "*huasonggamehall")
end
-- 粘贴到剪贴板
function LuaJavaBridge:setClipboardText(content)
    self:call_("org/ode/cocoslib/core/functions/ClipboardManagerFunction", "apply", {content}, "(Ljava/lang/String;)V")
end

--获取剪切板内容
function LuaJavaBridge:getPasteboardText(callback)
    if game.isFullVersionNewer(game.getAppVersion(), "1.0.7", true) then
        local ok, ret = self:call_("org/ode/cocoslib/core/functions/ClipboardManagerFunction", "getPasteboardText", {function ( txt )
            callback(txt)
        end}, "(I)V")
    end
end

function LuaJavaBridge:isAppInstalled(packageName)
    packageName = packageName or ""
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetPackageInfoFunction", "isAppInstalled", {packageName}, "(Ljava/lang/String;)Ljava/lang/String;")
    if ok then
        if not ret or ret == "" then
            return false,nil
        end
        -- flag: 是否安装查询的应用
        --firstInstallTime: 初次安装时间
        --lastUpdateTime: 最近更新应用时间
        local packInfo = json.decode(ret);
        if not packInfo then
            return false,nil
        end
        return (packInfo.flag == "true" and true or false),packInfo
    

    end
    return false,nil
    
end

-- 返回值
-- nil:未安装 
-- true:成功调用方法
-- false:未成功调用方法
function LuaJavaBridge:launchApp(packageName)
    packageName = packageName or ""
    local isAppInstalled = self:isAppInstalled(packageName)

    if not isAppInstalled then
        return nil
    end

    local ok, ret = self:call_("org/ode/cocoslib/core/functions/GetPackageInfoFunction", "launchApp", {packageName}, "(Ljava/lang/String;)V")
    return ok
end


--应用分身检测
function LuaJavaBridge:isRunInVirtual()
    local ok, ret = self:call_("org/ode/cocoslib/core/functions/CheckVirtualFunction", "isRunInVirtual", {}, "()Z")
    if ok and ret == true then
       return true
    end
    return false
end



function LuaJavaBridge:openApplicationSettings()
    local cur_version_num = game.getVersionNum(game.getAppVersion() or "1.0.0")
    local need_version = game.getVersionNum("1.0.12")
    if cur_version_num >= need_version then
        local ok, ret = self:call_("org/ode/cocoslib/core/functions/OpenSettingFunction", "openApplicationSettings", {}, "()V")
        if ok then
            return true,ret
        end
        return false,nil
    end
    return false,nil
end


function LuaJavaBridge:pickFromCamera(callback,needCrop,cropOption)
    local cur_version_num = game.getVersionNum(game.getAppVersion() or "1.0.0")
    local need_version = game.getVersionNum("1.0.15")
    if cur_version_num >= need_version then
        cropOption = cropOption or {}
        needCrop = needCrop or false
        if needCrop then
            local defaultOption = 
            {
                radio = "radio_square", --radio_origin/radio_square/radio_dynamic
                -- ratioX = 1,
                -- ratioY = 1,
                maxWidth = 250,
                maxHeight = 250,
                format = "radio_jpeg",
                quality = 80,
                hideBtmControls = false,
                freeStyle = false


            }
            if type(cropOption) == "table" then
                table.merge(cropOption,defaultOption)
            end
        end

        cropOption = json.encode(cropOption) or ""
       

        
        local ok, ret = self:call_("org/ode/cocoslib/core/functions/PickImageFunction", "pickFromCammer", {callback,needCrop,cropOption}, "(IZLjava/lang/String;)V")
        if ok then
            return true,ret
        end
        return false,nil
    else
        return false,"old_version"
    end
    return false,nil
end

function LuaJavaBridge:pickFromGallery(callback,needCrop,cropOption)
    local cur_version_num = game.getVersionNum(game.getAppVersion() or "1.0.0")
    local need_version = game.getVersionNum("1.0.15")
    if cur_version_num >= need_version then
        needCrop = needCrop or false
        cropOption = cropOption or {}

        if needCrop then
            local defaultOption = 
            {
                radio = "radio_square", --radio_origin/radio_square/radio_dynamic
                -- ratioX = 1,
                -- ratioY = 1,
                maxWidth = 250,
                maxHeight = 250,
                format = "radio_jpeg",
                quality = 80,
                hideBtmControls = false,
                freeStyle = false


            }
            if type(cropOption) == "table" then
                table.merge(cropOption,defaultOption)
            end
        end

        cropOption = json.encode(cropOption) or ""
        
        local ok, ret = self:call_("org/ode/cocoslib/core/functions/PickImageFunction", "pickFromGallery", {callback,needCrop,cropOption}, "(IZLjava/lang/String;)V")
        if ok then
            return true,ret
        end
        return false,nil
    end
    return false,nil
end



return LuaJavaBridge