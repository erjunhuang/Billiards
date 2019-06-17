--
-- Author: tony
-- Date: 2014-07-30 14:21:29
--
local LuaBridgeAdapter = {}

local mtable = {
    __index = function(table, key)
        if LuaBridgeAdapter[key] then
            return LuaBridgeAdapter[key]
        else
            return function(...)
                local params = {...}
                for i, v in ipairs(params) do
                    params[i] = tostring(v)
                end
                print("CALL FUNCTION " .. key, unpack(params))
            end
        end
    end,
    __newindex = function(table, key, value)
        error("invalid set data to LuaBridgeAdapter")
    end
}

function LuaBridgeAdapter:getFixedWidthText(font, size, text, width)
    return text
end

function LuaBridgeAdapter:getLoginToken(isDebug)
    if isDebug then
        math.newrandomseed()
        return core.encodeBase64("C4:6A:B7:61:7D:"..string.format("%02x", math.random(0x0, 0xff)).."*huasonggamehall")
    end
    math.randomseed(os.time())
    local t = math.random(1,9)
    return core.encodeBase64("33:5C:A2:A2:4D:D2" .."*huasonggamehall")
end

function LuaBridgeAdapter:pickImage(callback)
    callback(false, "error")
end

function LuaBridgeAdapter:getChannelId()
    return "test"
end

function LuaBridgeAdapter:getDeviceInfo()
    return {deviceId = "deviceId", deviceName = "deviceName", deviceModel = "deviceModel", 
        installInfo = "installInfo", cpuInfo = "cpuInfo", ramSize = "ramSize", simNum = "simNum", networkType = "networkType",location = "location"}
end

function LuaBridgeAdapter:getMacAddr()
    return "getMacAddr"
end

function LuaBridgeAdapter:isAppInstalled(packageName)
    packageName = packageName or ""
    
    local packInfo = {}
    packInfo.flag = "true"
    packInfo.firstInstallTime = "1435561512693"
    packInfo.lastUpdateTime = "1435561512153"
    
    return false, packInfo
    
end

function LuaBridgeAdapter:launchApp(packageName)
    return true
end

return setmetatable({}, mtable)