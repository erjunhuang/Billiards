local PluginAndroidBase = import(".PluginAndroidBase")


local KEYWORDS = 
{
	"screenshot","screen_shot","screen%-shot","screen shot",
	"screencapture","screen_capture","screen%-capture","screen capture",
	"screencap","screen_cap","screen%-cap","screen cap"
}
--- Android检测截屏功能的Lua端封装&通信接口
-- iOS和Android 接口保持一致
local ScreenShotDetectorPluginAndroid = class("ScreenShotDetectorPluginAndroid",PluginAndroidBase)

-- core.EventCenter:dispatchEvent 广播事件字符串 "SCREEN_SHOT_DETECTED_EVENT"
ScreenShotDetectorPluginAndroid.BROADCAST_EVENT_NAME = "SCREEN_SHOT_DETECTED_EVENT"

function ScreenShotDetectorPluginAndroid:ctor()
	ScreenShotDetectorPluginAndroid.super.ctor(self, "ScreenShotDetectorPluginAndroid", "org.ode.cocoslib.screenshotdetector.ScreenShotDetectorBridge")
end

--- 设置Java -> Lua 的监听回调（Java同一时间只有一个回调）
function ScreenShotDetectorPluginAndroid:registerScreenShotDetectorCallback()
	self.mLuaHandler = handler(self,self.onScreenShotDetected)
	self:call_("registerScreenShotDetectorCallback", {self.mLuaHandler}, "(I)V")
end

--- 注销Java -> Lua 的监听回调
function ScreenShotDetectorPluginAndroid:releaseScreenShotDetectorCallback()
	self:call_("releaseScreenShotDetectorCallback", {}, "()V")
end

--- Java回调Lua的回调函数，私有
-- @param jsonStr 返回的json字符串，包含一个path字段，可能有值，该值为截屏保存的路径，也可能没有值（取决于权限），但不论有没有值都代表检测到截屏
function ScreenShotDetectorPluginAndroid:onScreenShotDetected(jsonStr)
	print("ScreenShotDetectorPluginAndroid:onScreenShotDetected: ", jsonStr)
	local jsonTab = json.decode(jsonStr) or {}
	local path = jsonTab.path

	-- 提高截图准确度判断
	-- if self:isScreenShotPath(path) then
		self:onBroadcastResultInLua(path)
	-- end
	
end


function ScreenShotDetectorPluginAndroid:isScreenShotPath(path)
	path = string.lower(path or "")
	for _,v in ipairs(KEYWORDS) do
		if string.find(path,v) then
			return true
		end
	end
	return false
end

--- Lua广播给Lua，私有
-- @param path 截屏保存的路径，也可能没有值（取决于权限），但不论有没有值都代表检测到截屏
function ScreenShotDetectorPluginAndroid:onBroadcastResultInLua(path)
	print("ScreenShotDetectorPluginAndroid:onBroadcastResultInLua(", path, ")")
	core.EventCenter:dispatchEvent({name = self.BROADCAST_EVENT_NAME, data = {path = path}})
end

return ScreenShotDetectorPluginAndroid