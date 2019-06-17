
local LuaOCBridge = class("LuaOCBridge")
local logger = core.Logger.new("LuaOCBridge")

function LuaOCBridge:ctor()
end

function LuaOCBridge:vibrate(time)
    luaoc.callStaticMethod("LuaOCBridge", "vibrate")
end

function LuaOCBridge:getIDFA()
    local ok, r = luaoc.callStaticMethod("LuaOCBridge", "getiOSIDFA", nil)
    return ok and r or 'getiOSIDFA_nil'
end

function LuaOCBridge:getFixedWidthText(fontName, fontSize, text, fixedWidth)
    local ok, fixedString = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getFixedWidthText",
        {
            text = text,
            fixedWidth = fixedWidth,
            fontName = fontName,
            fontSize = fontSize,
        }
    )
    if ok then
        return fixedString
    else
        return text
    end
end


function LuaOCBridge:getNetworkType()
    local ok, ret = luaoc.callStaticMethod("LuaOCBridge", "getInternetConnectionStatus")
    if ok then
        return ret
    end
    return nil
end


function LuaOCBridge:getLoginToken()
    local openUdid = game.userDefault:getStringForKey("OPEN_UDID")
    if not openUdid or openUdid == "" then
        openUdid = self:getOpenUDID()
        game.userDefault:setStringForKey("OPEN_UDID", openUdid)
        game.userDefault:flush()
    end
    local is_dev = false
    if is_dev then
        return core.encodeBase64("C6:6A:B7:61:7E:C7".."*huasonggamehall")
    else
        return core.encodeBase64(openUdid .. "*huasonggamehall")
    end
end


function LuaOCBridge:getOpenUDID()
    local ok, openUdid = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getOpenUDID", nil)

    print("getOpenUDID ok:",ok," openUdid:",openUdid)
    if ok then
        return openUdid
    else
        return ""
    end
end

function LuaOCBridge:getAppVersion()
    local ok, version = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getAppVersion", nil)
    if ok then
        return version
    else
        return "1.0.0"
    end
end

function LuaOCBridge:getAppBundleId()
    local ok, bundleId = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getAppBundleId", nil)
    if ok then
        return bundleId
    else
        return ""
    end
end


function LuaOCBridge:getDeviceInfo()
    local ok, deviceInfo = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getDeviceInfo", nil)
    if ok then
        return json.decode(deviceInfo)
    else
        return {}
    end
end

function LuaOCBridge:getMacAddr()
    return nil
end

function LuaOCBridge:isAppInstalled(packageName)

    packageName = packageName or ""
    return false,nil
end

function LuaOCBridge:setClipboardText(content)
    content = content or ""
    luaoc.callStaticMethod("LuaOCBridge", "setClipboardText", {
        content = content
    })
end

function LuaOCBridge:getPasteboardText(callback)
    if game.isFullVersionNewer(game.getAppVersion(), "1.0.7", true) then
        local ok, text = luaoc.callStaticMethod("LuaOCBridge", "getPasteboardText")
        if ok then
           callback(text)
        end
    end
end

function LuaOCBridge:openLocation()
    luaoc.callStaticMethod("LuaOCBridge", "openLocation")
end


function LuaOCBridge:openApplicationSettings()
    local cur_version_num = game.getVersionNum(game.getAppVersion() or "1.0.0")
    local need_version = game.getVersionNum("1.0.12")
    if cur_version_num >= need_version then
        local ok, ret = luaoc.callStaticMethod(
        "LuaOCBridge",
        "openApplicationSettings", nil)
        if ok then
            return true,ret
        end
        return false,nil
    end
    return false,nil

end




function LuaOCBridge:getManifestInformations( ... )
    local ok, result = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getManifestInformations", nil)
    if ok then
        local jObj = json.decode(result)
        local tb = {}
        tb.packageName = jObj.bundleId
        tb.versionName = jObj.shortVersion   --1.0.0
        tb.appName = jObj.appName
        tb.versionCode = jObj.buildVersion   --1.0.0.xxxx
        return tb
    else
        return {}
    end
end

-- 1为横屏
-- 2为竖屏
function LuaOCBridge:changeScreenOrientation(toOrientation)
    print("LuaOCBridge:changeScreenOrientation(", toOrientation, ")")
    local ok, result = luaoc.callStaticMethod("LuaOCBridge", "changeScreenOrientation", {orientation = toOrientation})
    if ok then
        local jsonTab = json.decode(result)
        --[[
        jsonTab.result 是否成功
        jsonTab.orientation 要改变的屏幕方向
        jsonTab.last_orientation 改变前的屏幕方向
        ]]
        dump(jsonTab, "LuaOCBridge:changeScreenOrientation => ")
        return jsonTab
    end
end

-- 1为横屏
-- 2为竖屏
function LuaOCBridge:getCurrentScreenOrientation()
    print("LuaOCBridge:getCurrentScreenOrientation()")
    local ok, orientation = luaoc.callStaticMethod("LuaOCBridge", "getCurrentScreenOrientation", nil)
    if ok then
        print("LuaOCBridge:getCurrentScreenOrientation => ", orientation)
        return orientation
    end
end


--检测若干签名信息
function LuaOCBridge:checkCodeSignInfo(teamId,bundleId,applicationId)
    teamId = teamId or ""
    bundleId = bundleId or ""
    applicationId = applicationId or ""

    local ok, result = luaoc.callStaticMethod(
        "LuaOCBridge",
        "checkCodeSignInfo",
        {
            teamId = teamId,
            bundleId = bundleId,
            applicationId = applicationId
        }
    )
    if ok then
        return true,result
    else
        return false,nil
    end
end


function LuaOCBridge:pickFromCamera(callback,needCrop,cropOption)
    local cur_version_num = game.getVersionNum(game.getAppVersion() or "1.0.0")
    local need_version = game.getVersionNum("1.0.15")
    if cur_version_num >= need_version then
        cropOption = cropOption or {}
        needCrop = needCrop or false

        local callOCArgs = {callback = callback,needCrop=needCrop}
        
        if needCrop then
            local defaultOption = 
            {
                maxWidth = 250,
                maxHeight = 250,
                
            }
            if type(cropOption) == "table" then
                table.merge(defaultOption,cropOption)
            end

            table.merge(callOCArgs,defaultOption)
        end

        local ok, ret = luaoc.callStaticMethod("LuaOCBridge", "pickFromCammer", callOCArgs)
        if ok then
            return true,ret
        end
        return false,nil
    else
        return false,"old_version"
    end
    return false,nil
end

function LuaOCBridge:pickFromGallery(callback,needCrop,cropOption)
    local cur_version_num = game.getVersionNum(game.getAppVersion() or "1.0.0")
    local need_version = game.getVersionNum("1.0.15")
    if cur_version_num >= need_version then
        needCrop = needCrop or false
        cropOption = cropOption or {}


        local callOCArgs = {callback = callback,needCrop=needCrop}
        
        if needCrop then
            local defaultOption = 
            {
                maxWidth = 250,
                maxHeight = 250,
                
            }
            if type(cropOption) == "table" then
                table.merge(defaultOption,cropOption)
            end

            table.merge(callOCArgs,defaultOption)
        end
        
        local ok, ret = luaoc.callStaticMethod("LuaOCBridge", "pickFromGallery", callOCArgs)
        if ok then
            return true,ret
        end
        return false,nil
    end
    return false,nil
end



return LuaOCBridge
