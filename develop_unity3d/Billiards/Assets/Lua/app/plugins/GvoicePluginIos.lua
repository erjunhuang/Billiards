local PluginIosBase = import(".PluginIosBase")
local GvoicePluginIos = class("GvoicePluginIos",PluginIosBase)

local GCloudLanguage = 
{
	China       = 0,
    Korean      = 1,
    English     = 2,
    Japanese    = 3,
}


local GCloudVoiceMode = 
{
	RealTime = 0, -- realtime mode for TeamRoom or NationalRoom
	Messages= 1,     -- voice message mode
	Translation= 2,  -- speach to text mode
    RSTT= 3, -- real-time speach to text mode
	HIGHQUALITY =4 , --high quality realtime voice, will cost more network traffic
}

local GCloudVoiceMemberRole = 
{
	
    Anchor = 1, -- member who can open microphone and say
    Audience = 2,   -- member who can only hear anchor's voice
       
}

local GCloudVoiceErrno = 
{
	GCLOUD_VOICE_SUCC           = 0,
		
		--common base err
		GCLOUD_VOICE_PARAM_NULL = 0x1001,	--4097, some param is null
		GCLOUD_VOICE_NEED_SETAPPINFO = 0x1002,	--4098, you should call SetAppInfo first before call other api
		GCLOUD_VOICE_INIT_ERR = 0x1003,	--4099, Init Erro
		GCLOUD_VOICE_RECORDING_ERR = 0x1004,		--4100, now is recording, can't do other operator
		GCLOUD_VOICE_POLL_BUFF_ERR = 0x1005,	--4101, poll buffer is not enough or null 
		GCLOUD_VOICE_MODE_STATE_ERR = 0x1006,	--4102, call some api, but the mode is not correct, maybe you shoud call SetMode first and correct
		GCLOUD_VOICE_PARAM_INVALID = 0x1007,	--4103, some param is null or value is invalid for our request, used right param and make sure is value range is correct by our comment 
		GCLOUD_VOICE_OPENFILE_ERR = 0x1008, --4104, open a file err
		GCLOUD_VOICE_NEED_INIT = 0x1009, --4105, you should call Init before do this operator
		GCLOUD_VOICE_ENGINE_ERR = 0x100A, --4106, you have not get engine instance, this common in use c# api, but not get gcloudvoice instance first
		GCLOUD_VOICE_POLL_MSG_PARSE_ERR = 0x100B, --4107, this common in c# api, parse poll msg err
		GCLOUD_VOICE_POLL_MSG_NO = 0x100C, --4108, poll, no msg to update


		--realtime err
		GCLOUD_VOICE_REALTIME_STATE_ERR = 0x2001, --8193, call some realtime api, but state err, such as OpenMic but you have not Join Room first
		GCLOUD_VOICE_JOIN_ERR = 0x2002, --8194, join room failed
		GCLOUD_VOICE_QUIT_ROOMNAME_ERR = 0x2003,	--8195, quit room err, the quit roomname not equal join roomname
		GCLOUD_VOICE_OPENMIC_NOTANCHOR_ERR = 0x2004,--8196, open mic in bigroom,but not anchor role


		--message err
		GCLOUD_VOICE_AUTHKEY_ERR = 0x3001, --12289, apply authkey api error
		GCLOUD_VOICE_PATH_ACCESS_ERR = 0x3002, --12290, the path can not access ,may be path file not exists or deny to access
		GCLOUD_VOICE_PERMISSION_MIC_ERR = 0x3003,	--12291, you have not right to access micphone in android
		GCLOUD_VOICE_NEED_AUTHKEY = 0x3004,		--12292,you have not get authkey, call ApplyMessageKey first
		GCLOUD_VOICE_UPLOAD_ERR = 0x3005,	--12293, upload file err
		GCLOUD_VOICE_HTTP_BUSY = 0x3006,	--12294, http is busy,maybe the last upload/download not finish.
		GCLOUD_VOICE_DOWNLOAD_ERR = 0x3007,	--12295, download file err
		GCLOUD_VOICE_SPEAKER_ERR = 0x3008, --12296, open or close speaker tve error
		GCLOUD_VOICE_TVE_PLAYSOUND_ERR = 0x3009, --12297, tve play file error
        GCLOUD_VOICE_AUTHING = 0x300a, -- 12298, Already in applying auth key processing

		GCLOUD_VOICE_INTERNAL_TVE_ERR = 0x5001,		--20481, internal TVE err, our used
		GCLOUD_VOICE_INTERNAL_VISIT_ERR = 0x5002,	--20482, internal Not TVE err, out used
		GCLOUD_VOICE_INTERNAL_USED = 0x5003, --20483, internal used, you should not get this err num
        
        GCLOUD_VOICE_BADSERVER = 0x06001, -- 24577, bad server address,should be "udp:--capi.xxx.xxx.com"
        
        GCLOUD_VOICE_STTING =  0x07001, -- 28673, Already in speach to text processing
}


local GCloudVoiceCompleteCode = 
{
		GV_ON_JOINROOM_SUCC = 1,	--join room succ
		GV_ON_JOINROOM_TIMEOUT= 2,  --join room timeout
		GV_ON_JOINROOM_SVR_ERR= 3,  --communication with svr occur some err, such as err data recv from svr
		GV_ON_JOINROOM_UNKNOWN= 4, --reserved, our internal unknow err

		GV_ON_NET_ERR= 5,  --net err,may be can't connect to network

		GV_ON_QUITROOM_SUCC= 6, --quitroom succ, if you have join room succ first, quit room will alway return succ

		GV_ON_MESSAGE_KEY_APPLIED_SUCC= 7,  --apply message authkey succ
		GV_ON_MESSAGE_KEY_APPLIED_TIMEOUT= 8,		--apply message authkey timeout
		GV_ON_MESSAGE_KEY_APPLIED_SVR_ERR= 9,  --communication with svr occur some err, such as err data recv from svr
		GV_ON_MESSAGE_KEY_APPLIED_UNKNOWN= 10,  --reserved,  our internal unknow err

        GV_ON_UPLOAD_RECORD_DONE= 11,  --upload record file succ
        GV_ON_UPLOAD_RECORD_ERROR= 12,  --upload record file occur error
        GV_ON_DOWNLOAD_RECORD_DONE= 13,	--download record file succ
        GV_ON_DOWNLOAD_RECORD_ERROR= 14,	--download record file occur error

        GV_ON_STT_SUCC= 15, -- speech to text successful
        GV_ON_STT_TIMEOUT= 16, -- speech to text with timeout
        GV_ON_STT_APIERR= 17, -- server's error
        
        GV_ON_RSTT_SUCC= 18, -- speech to text successful
        GV_ON_RSTT_TIMEOUT= 19, -- speech to text with timeout
        GV_ON_RSTT_APIERR= 2, -- server's error
        
		GV_ON_PLAYFILE_DONE= 21,  --the record file played end
        
        GV_ON_ROOM_OFFLINE= 22, -- Dropped from the room
        GV_ON_UNKNOWN= 23,
}


GvoicePluginIos.GCloudVoiceCompleteCode = GCloudVoiceCompleteCode
GvoicePluginIos.GCloudVoiceErrno = GCloudVoiceErrno
GvoicePluginIos.GCloudVoiceMemberRole = GCloudVoiceMemberRole
GvoicePluginIos.GCloudVoiceMode = GCloudVoiceMode
GvoicePluginIos.GCloudLanguage = GCloudLanguage


function GvoicePluginIos:ctor()
	GvoicePluginIos.super.ctor(self,"GvoicePluginIos","GvoiceBridge")
	local eventDispatcher = nb.Director:getInstance():getEventDispatcher()
    self.customListenerBg_ = nb.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
                                handler(self, self.onAppEnterBackground))
    eventDispatcher:addEventListenerWithFixedPriority(self.customListenerBg_, 1)
    self.customListenerFg_ = nb.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
                                handler(self, self.onAppEnterForeground))
    eventDispatcher:addEventListenerWithFixedPriority(self.customListenerFg_, 1)
	self:call_("SetGvoiceNotify", {listener = handler(self,self.onGvoiceNotify)})

	local appID = appconfig.gvoiceInfo and appconfig.gvoiceInfo.appID or "gcloud.test"
	local appKey = appconfig.gvoiceInfo and appconfig.gvoiceInfo.appKey or "test_key"

	--删除录音目录
	local basePath = device.writablePath .. "gvoice" .. device.directorySeparator
	core.rmdir(basePath)
	core.mkdir(basePath)

	-- local appID = "gcloud.test"
	-- local appKey = "test_key"
	local openID = tostring(os.time())

	print("init",self:Init(appID,appKey,openID))
	print("SetMode",self:SetMode(GCloudVoiceMode.Messages))

	self:StartPoll()


	self.applyMsgCallbackTb_ = {}
	self.downloadRecordCallbackTb_ = {}
	self.uploadRecordedCallbackTb_ = {}
	self.playRecordedCallbackTb_ = {}





end

--玩家唯一标识
function GvoicePluginIos:Init(appID,appKey,openID)
	local ok, ret = self:call_("Init",{appID=appID,appKey=appKey,openID=openID})
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:StartPoll()
	local ok, ret = self:call_("StartPoll")
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:GetFileParam(filePath)
	local ok, ret = self:call_("GetFileParam",{filePath=filePath})
	if ok then
		return ret
	end
	return nil
end


function GvoicePluginIos:Resume()
	local ok, ret = self:call_("Resume")
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:Pause()
	local ok, ret = self:call_("Pause")
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:getRecordFilePath(prefix)
	prefix = prefix or ""
	local basePath = device.writablePath .. "gvoice" .. device.directorySeparator
	core.mkdir(basePath)
	return basePath .. prefix .. os.time() .. ".dat"
end



--离线语音 start---
function GvoicePluginIos:ApplyMessageKey(msTimeout,callback)
	self.applyMsgCallbackTb_[callback] = callback

	if self.isApplyKey_ then
		self:OnApplyMessageKey({code = GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SUCC})
		return GCloudVoiceErrno.GCLOUD_VOICE_SUCC
	end

	msTimeout = msTimeout or 10000
	local ok, ret = self:call_("ApplyMessageKey",{msTimeout=msTimeout})
	if ok then
		return ret
	end

	return nil
end

function GvoicePluginIos:SetMode(mode)
	local ok, ret = self:call_("SetMode",{mode=mode})
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:SpeechToText(fileId,msTimeout,language)
	msTimeout = msTimeout or 10000
	local ok, ret = self:call_("SpeechToText",{fileId=fileId,msTimeout=msTimeout,language=language})
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:StartRecording(filePath)
	filePath = filePath or self:getRecordFilePath()
	local ok, ret = self:call_("StartRecording",{filePath=filePath})
	if ok then
		return filePath,ret
	end
	return filePath,nil
end

function GvoicePluginIos:StopRecording()
	local ok, ret = self:call_("StopRecording")
	print("stopRecording",ok,ret)
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:UploadRecordedFile(filePath,msTimeout,callback)
	self.uploadRecordedCallback_ = callback
	msTimeout = msTimeout or 10000
	local ok, ret = self:call_("UploadRecordedFile",{filePath=filePath,msTimeout=msTimeout})
	if ok and ret == GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		local md5code = nb.utils_.md5(filePath)
		self.uploadRecordedCallbackTb_[md5code] = callback
	end
	if ok then
		return ret
	end
	return nil
	
end

function GvoicePluginIos:DownloadRecordedFile(fileID,downloadFilePath,callback,msTimeout)
	self.downloadRecordCallback_ = callback
	msTimeout = msTimeout or 10000
	downloadFilePath = downloadFilePath or self:getRecordFilePath()
	local ok, ret = self:call_("DownloadRecordedFile",{fileID=fileID,downloadFilePath=downloadFilePath,msTimeout=msTimeout})
	if ok and ret == GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		local md5code = nb.utils_.md5(fileID)
		self.downloadRecordCallbackTb_[md5code] = callback
	end
	if ok then
		return downloadFilePath,ret
	end
	return downloadFilePath,nil
end

function GvoicePluginIos:PlayRecordedFile(downloadFilePath,callback)
	local ok, ret = self:call_("PlayRecordedFile",{downloadFilePath=downloadFilePath})
	if ok and ret == GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		local md5code = nb.utils_.md5(downloadFilePath)
		self.playRecordedCallbackTb_[md5code] = callback
	end
	if ok then
		return ret
	end
	return nil
end


function GvoicePluginIos:StopPlayFile()
	local ok, ret = self:call_("StopPlayFile")
	if ok then
		return ret
	end
	return nil
end

--离线语音 end---


--实时语音 start-- 未安待续
function GvoicePluginIos:JoinTeamRoom(roomName,msTimeout)
	msTimeout = msTimeout or 10000
	local ok, ret = self:call_("JoinTeamRoom",{roomName=roomName,msTimeout=msTimeout})
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:JoinNationalRoom(roomName,role,msTimeout)
	msTimeout = msTimeout or 10000
	local ok, ret = self:call_("JoinNationalRoom",{roomName=roomName,role=role,msTimeout=msTimeout})
	if ok then
		return ret
	end
	return nil
end


function GvoicePluginIos:QuitRoom(roomName,msTimeout)
	msTimeout = msTimeout or 10000
	local ok, ret = self:call_("QuitRoom",{roomName=roomName,msTimeout=msTimeout})
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:OpenMic()
	local ok, ret = self:call_("OpenMic")
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:CloseMic( ... )
	local ok, ret = self:call_("CloseMic")
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:OpenSpeaker( ... )
	local ok, ret = self:call_("OpenSpeaker")
	if ok then
		return ret
	end
	return nil
end

function GvoicePluginIos:CloseSpeaker( ... )
	local ok, ret = self:call_("CloseSpeaker")
	if ok then
		return ret
	end
	return nil
end

--实时语音 end--


function GvoicePluginIos:onGvoiceNotify(jsonObj)
	dump(jsonObj,"onGvoiceNotify")
	if not jsonObj then
		return
	end
	local gtype = jsonObj.gtype
	if gtype == "OnApplyMessageKey" then
		self:OnApplyMessageKey(jsonObj)
	elseif gtype == "OnDownloadFile" then
		self:OnDownloadFile(jsonObj)
	elseif gtype == "OnJoinRoom" then
		self:OnJoinRoom(jsonObj)
	elseif gtype == "OnMemberVoice" then
		self:OnMemberVoice(jsonObj)
	elseif gtype == "OnPlayRecordedFile" then
		self:OnPlayRecordedFile(jsonObj)
	elseif gtype == "OnQuitRoom" then
		self:OnQuitRoom(jsonObj)
	elseif gtype == "OnRecording" then
		self:OnRecording(jsonObj)
	elseif gtype == "OnSpeechToText" then
		self:OnSpeechToText(jsonObj)
	elseif gtype == "OnStatusUpdate" then
		self:OnStatusUpdate(jsonObj)
	elseif gtype == "OnStreamSpeechToText" then
		self:OnStreamSpeechToText(jsonObj)
	elseif gtype == "OnUploadFile" then
		self:OnUploadFile(jsonObj)
	elseif gtype == "OnInit" then

	end

end


-- 接口：void OnJoinRoom(GCloudVoiceCompleteCode code, char *roomName, int memberID)
-- 参数：code: 加入房间的结果 enum GcloudVoiceCompleteCode
-- {
-- GV_ON_JOINROOM_SUCC, -- 加入房间成功
-- GV_ON_JOINROOM_TIMEOUT, -- 加入房间超时
-- GV_ON_JOINROOM_FAIL, -- 加入房间其他错误
-- };
-- roomName: 加入房间的名字 memberID： 成员的ID
-- 返回值：无

function GvoicePluginIos:OnJoinRoom(code,roomName,memberID)
	-- body
end

-- 参数：code: 加入房间的结果 enum GcloudVoiceCompleteCode

-- {
-- GV_ON_JOINROOM_SUCC, -- 加入房间成功
-- GV_ON_JOINROOM_TIMEOUT, -- 加入房间超时
-- GV_ON_JOINROOM_FAIL, -- 加入房间其他错误
-- };
-- roomName: 加入房间的名字
-- 返回值：无
function GvoicePluginIos:OnQuitRoom(code,roomName)
	-- body
end


-- 参数： filePath： 文件存储的位置，与send的时候一致 fileID： 文件唯一标示的ID code: 如果出错时候的错误码
-- 返回值：无
function GvoicePluginIos:OnUploadFile(jsonObj)
	local code = jsonObj.code
	local filePath = jsonObj.filePath
	local fileID = jsonObj.fileID

	local md5code = nb.utils_.md5(filePath)
	if self.uploadRecordedCallbackTb_[md5code] then
		self.uploadRecordedCallbackTb_[md5code](code,filePath,fileID)
		self.uploadRecordedCallbackTb_[md5code] = nil
	end
end

-- 参数： code: 如果出错时候的错误码 filePath: 播放的文件的位置
-- 返回值：无
function GvoicePluginIos:OnPlayRecordedFile(jsonObj)
	local code = jsonObj.code
	local filePath = jsonObj.filePath

	local md5code = nb.utils_.md5(filePath)
	if self.playRecordedCallbackTb_[md5code] then
		self.playRecordedCallbackTb_[md5code](code,filePath)
		self.playRecordedCallbackTb_[md5code] = nil
	end
end

-- 参数： filePath： 文件存储的位置，与down的时候一致 fileID： 文件唯一标示的ID code: 如果出错时候的错误码
-- 返回值：无
function GvoicePluginIos:OnDownloadFile(jsonObj)
	local code = jsonObj.code
	local filePath = jsonObj.filePath
	local fileID = jsonObj.fileID
	local md5code = nb.utils_.md5(fileID)

	if self.downloadRecordCallbackTb_[md5code] then
		self.downloadRecordCallbackTb_[md5code](code,filePath,fileID)
		self.downloadRecordCallbackTb_[md5code] = nil
	end
end

-- 参数：code: 如果出错时候的错误码
-- 返回值：无
function GvoicePluginIos:OnApplyMessageKey(jsonObj)
	local code = jsonObj.code
	if not self.isApplyKey_ and code == GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SUCC then
		self.isApplyKey_ = true
	end

	print("lua-OnApplyMessageKey" ,code,tostring(self.applyMsgCallback_ == nil) )

	for k,v in pairs(self.applyMsgCallbackTb_) do
		v(code)
	end
	self.applyMsgCallbackTb_ = {}
	
end


--实时
-- 参数：members: 成员及状态，格式为 memberID,status,memberID,status 成对出现，status值为 0：从发声变成 没有发声 1： 从不发生变成发声 2： 从发声再发声 length: member的个数，2就是member数组的长度。
-- 返回值：无
function GvoicePluginIos:onMemberVoice(jsonObj)
	local members = jsonObj.members
	local length = jsonObj.length
	-- body
end


function GvoicePluginIos:onAppEnterBackground()
	self:StopRecording()
	self:StopPlayFile()
end

function GvoicePluginIos:onAppEnterForeground()

end


function GvoicePluginIos:cancelAll( ... )
	self.applyMsgCallbackTb_ = {}
	self.downloadRecordCallbackTb_ = {}
	self.uploadRecordedCallbackTb_ = {}
	self.playRecordedCallbackTb_ = {}
end


function GvoicePluginIos:dispose( ... )
	local eventDispatcher = nb.Director:getInstance():getEventDispatcher()
	eventDispatcher:removeEventListener(self.customListenerFg_)
	eventDispatcher:removeEventListener(self.customListenerBg_)
	self.customListenerBg_ = nil
	self.customListenerFg_ = nil
end


return GvoicePluginIos