local PluginIosBase = import(".PluginIosBase")

--- iOS检测截屏功能的Lua端封装&通信接口
-- iOS和Android 接口保持一致
local ScreenShotDetectorPluginIOS = class("ScreenShotDetectorPluginIOS", PluginIosBase)

-- core.EventCenter:dispatchEvent 广播事件字符串 "SCREEN_SHOT_DETECTED_EVENT"
ScreenShotDetectorPluginIOS.BROADCAST_EVENT_NAME = "SCREEN_SHOT_DETECTED_EVENT"

function ScreenShotDetectorPluginIOS:ctor()
	ScreenShotDetectorPluginIOS.super.ctor(self,"ScreenShotDetectorPluginIOS","ScreenShotDetectorBridge")
end

--- 设置Objective-C -> Lua 的监听回调（Objective-C同一时间只有一个回调）
function ScreenShotDetectorPluginIOS:registerScreenShotDetectorCallback()
	self.mLuaHandler = handler(self,self.onScreenShotDetected)
	self:call_("registerScreenShotDetectorCallback", {listener = self.mLuaHandler})
end

--- 注销Objective-C -> Lua 的监听回调
function ScreenShotDetectorPluginIOS:releaseScreenShotDetectorCallback()
	self:call_("releaseScreenShotDetectorCallback")
end


--- 设置Objective-C -> Lua 的回调函数，私有
-- Objective-C层并不会返回有用path，仅用于与Android参数结构统一
function ScreenShotDetectorPluginIOS:onScreenShotDetected(retTab)
	print("ScreenShotDetectorPluginIOS:onScreenShotDetected: ", jsonStr)
	retTab = retTab or {}
	local path = retTab.path
	if path == "" then
		path = nil
	end

	self:onBroadcastResultInLua(path)
end

--- Lua广播给Lua，私有
function ScreenShotDetectorPluginIOS:onBroadcastResultInLua(path)
    print("ScreenShotDetectorPluginIOS:onBroadcastResultInLua(", path, ")")
	core.EventCenter:dispatchEvent({name = self.BROADCAST_EVENT_NAME, data = {path = path}})
end

return ScreenShotDetectorPluginIOS
