local scheduler = require(nb.PACKAGE_NAME .. ".scheduler")
local VoiceManager =  class("VoiceManager")
local dir = device.writablePath .. "cache/voice/"
local instance
function VoiceManager.getInstance( )
	if not instance then
		instance = VoiceManager.new()
	end
	return instance
end

function VoiceManager:ctor( )
	nb.bind(self,"event")
	core.mkdir(dir)
	if device.platform == "windows" then
		return
	end

	local result, audio = pcall(require, "paiyou_amr")
	if result then
		self.audio = audio
	else
		self.audio = nil
	end
    if not self.audio then
        error("paiyou_amr is nil")
    end
    self.audio.audio_create()

    self.updateHandle = scheduler.scheduleGlobal(function()
    	if self.audio.onUpdate then
	        self.audio.onUpdate()
	    end
    end, 0.1)
end

--filepath是文件的保存路径，绝对路径
--最大录制10s
function VoiceManager:startRecord()
	local filepath = dir.. game.userData["aUser.mid"].. "_" .. os.time()
	print("VoiceManager:startRecord", filepath)
	if not self.audio then 
		io.writefile(filepath, "Win32.filepath:"..filepath, "w+b")
		return filepath
	end
    self.audio.startRecord(filepath)
    local handler
    handler = scheduler.performWithDelayGlobal(function ( ... )
    	if self._currentRecord == handler then
    		self:stopRecord()
    		self._currentRecord = nil
    	end
    end, 10)
    self._currentRecord = handler
    return filepath
end

--结束当前录制任务，文件会保存在filepath
function VoiceManager:stopRecord()
	print("VoiceManager:stopRecord")
	if not self.audio or not self._currentRecord then return end
    self.audio.stopRecord()
    if self._currentRecord then
    	scheduler.unscheduleGlobal(self._currentRecord)
    	self._currentRecord = nil
    end
end

--取消录制
function VoiceManager:cancelRecord()
	print("VoiceManager:cancelRecord")
	if not self.audio then return end
    self.audio.cancelRecord();
    if self._currentRecord then
    	scheduler.unscheduleGlobal(self._currentRecord)
    	self._currentRecord = nil
    end
end

--播放filepath下的音频
function VoiceManager:startTrack(filepath)
	print("VoiceManager:startTrack")
	if not self.audio then 
		local content = io.readfile(filepath)
		print("VoiceManager:startTrack content:", content)
		return content
	end
    self.audio.startTrack(filepath)
end

--停止播放
function VoiceManager:stopTrack()
	print("VoiceManager:stopTrack")
	if not self.audio then return end
    self.audio.stopTrack();
end

--是否在播放
function VoiceManager:isPlaying()
	if not self.audio then return end
	print("VoiceManager:isPlaying:" .. self.audio.trackState())
    return self.audio.trackState() == 0
end


function VoiceManager:dispose()
	if not self.audio then return end
	if self.updateHandle then
	    scheduler.unscheduleGlobal(self.updateHandle)
	end
	self:clearCache()
	self.audio.stopRecord()
    self.audio.audio_destroy()
    self.audio = nil
end

--清除路径下语音文件
function VoiceManager:clearCache()
	core.rmdir(dir)
	core.mkdir(dir)
end


--事件回调,
local eventmap = {
	[1] = "EVENT_TRACK_COMPLETED", --播放完成
	[2] = "EVENT_RECORD_COMPLETED", --录制完成 arg:文件时长
	[3] = "EVENT_RECORD_CANCEL", --取消录制 
	[5] = "EVENT_RECORD_VOLUME", --声音状态 arg:录制时声音大小
} 

function nb.exports.audio_event_callback(event, arg)
	print("audio_event_callback", event, arg)
    game.VoiceManager:dispatchEvent({name= eventmap[event], arg = arg})
end

VoiceManager.eventMap = eventmap

return VoiceManager