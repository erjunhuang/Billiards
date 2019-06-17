local PluginAndroidBase = import(".PluginAndroidBase")

local WeChatPluginAndroid = class("WeChatPluginAndroid",PluginAndroidBase)

local APPID = appconfig.wxAppid

local CHECK_SIGN = true

WeChatPluginAndroid.SCENE = 
{
	WXSceneSession = 0,
	WXSceneTimeline = 1,
	WXSceneFavorite = 2,
}

local SCENE = WeChatPluginAndroid.SCENE

function WeChatPluginAndroid:ctor()
	WeChatPluginAndroid.super.ctor(self,"WeChatPluginAndroid","org.ode.cocoslib.wechat.WeChatBridge")
	self:init()
end



function WeChatPluginAndroid:init()
	print("WeChatPluginAndroid:init:",APPID)
	self:setAppid()
	self.onWeChatRespHandler_ = handler(self,self.onWeChatResp)
	self.onWeChatReqHandler_ = handler(self,self.onWeChatReq)

	self:call_("setWeChatResp", {self.onWeChatRespHandler_}, "(I)V")
	self:call_("setWeChatReq", {self.onWeChatReqHandler_}, "(I)V")
end


function WeChatPluginAndroid:setAppid(itype)
	-- do self:call_("init",{APPID,CHECK_SIGN},"(Ljava/lang/String;Z)V") return end
	if self:isSupportShareDiff() and itype == "share" then
		local wxshareid = game.getRandomWxShareId()
		self:call_("init",{wxshareid,CHECK_SIGN},"(Ljava/lang/String;Z)V")
	else
		self:call_("init",{APPID,CHECK_SIGN},"(Ljava/lang/String;Z)V")
	end
end

function WeChatPluginAndroid:isSupportShareDiff( ... )
	if not game or type(game.getVersionNum) ~= "function" then
		return false
	end

	local cur_version_num = game.getVersionNum(game.getAppVersion() or "1.0.0")
    local need_version = game.getVersionNum("1.0.16")
    if cur_version_num >= need_version then
    	return true
    else
    	return false
    end
end

function WeChatPluginAndroid:openWeChatApp( ... )
	local succ,result = self:call_("openWXApp",{},"()Z")
	if not succ or not result then
		return false
	else
		return result
	end
end


function WeChatPluginAndroid:login(callback,scope,state)
	self:setAppid()
	local scope = scope or "snsapi_userinfo"
	local state = state or "wx_login"
	self.loginCallback_ = callback
	print(self.loginCallback_,"self.loginCallback_")
	self:call_("login",{scope,state},"(Ljava/lang/String;Ljava/lang/String;)V")
end


function WeChatPluginAndroid:shareText(text,scene,callback)
	self:setAppid("share")  
	text = text or ""
	scene = scene or SCENE.WXSceneSession
	self.currentShareType_ = "text"
	self.shareTextCallback_ = callback
	self:call_("shareText",{text,scene},"(Ljava/lang/String;I)V")
end

function WeChatPluginAndroid:shareImg(path,scene,callback)
	self:setAppid("share")
	path = path or ""
	scene = scene or SCENE.WXSceneSession
	self.currentShareType_ = "image"
	self.shareImgCallback_ = callback
	self:call_("shareImg",{path,scene},"(Ljava/lang/String;I)V")
end

function WeChatPluginAndroid:shareMusic(url,title,des,thumbImg,scene,callback)
	self:setAppid("share")
	url = url or ""
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	scene = scene or SCENE.WXSceneSession
	self.currentShareType_ = "music"
	self.shareMusicCallback_ = callback
	self:call_("shareMusic",{url,title,des,thumbImg,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
end


function WeChatPluginAndroid:shareVideo(url,title,des,thumbImg,scene,callback)
	self:setAppid("share")
	url = url or ""
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	scene = scene or SCENE.WXSceneSession
	self.shareVideoCallback_ = callback
	self.currentShareType_ = "video"
	self:call_("shareVideo",{url,title,des,thumbImg,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
end

function WeChatPluginAndroid:shareWebPage(url,title,des,thumbImg,scene,callback)
	self:setAppid("share")
	url = url or ""
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	scene = scene or SCENE.WXSceneSession
	print("shareWebPage",url,title,des,thumbImg,scene)
	self.shareWebPageCallback_ = callback
	self.currentShareType_ = "webPage"

	local isNetImg = string.find(thumbImg,"http://") or string.find(thumbImg,"https://")
	if not isNetImg then
		self:call_("shareWebPage",{url,title,des,thumbImg,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")

	else
		local function callShareFunc(cdownImgPath,curl,ctitle,cdes,cthumbImg,cscene)
			self:call_("shareWebPage",{curl,ctitle,cdes,cdownImgPath,cscene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
		
		end

		self:loadNetImg(thumbImg,callShareFunc,url,title,des,thumbImg,scene)
	end
end

function WeChatPluginAndroid:shareAppData(title,des,thumbImg,extInfo,filePath,scene,callback)
	self:setAppid("share")
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	extInfo = extInfo or ""
	filePath = filePath or ""
	scene = scene or SCENE.WXSceneSession
	self.shareAppDataCallback_ = callback
	self.currentShareType_ = "app"
	self:call_("shareAppData",{title,des,thumbImg,extInfo,filePath,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
	
end



function WeChatPluginAndroid:makePurchase(callback,partnerId,prepayId,packageValue,nonceStr,timeStamp,sign,extData)
	self:setAppid()
	print("partnerId",partnerId,"prepayId",prepayId,"packageValue",packageValue,"nonceStr",nonceStr,"timeStamp",timeStamp,"sign",sign,"extData",extData)
	partnerId = partnerId or ""
	prepayId = prepayId or ""
	packageValue = packageValue or ""
	nonceStr = nonceStr or ""
	timeStamp = timeStamp or os.time()
	sign = sign or ""
	extData = extData or ""

	self.makePurchaseCallback_ = callback
	self:call_("makePurchase",{APPID,partnerId,prepayId,packageValue,nonceStr,timeStamp,sign,extData},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end


function WeChatPluginAndroid:launchMiniProgram(userName,path)
	self:call_("launchMiniProgram",{userName,path},"(Ljava/lang/String;Ljava/lang/String;)V")
end



function WeChatPluginAndroid:loadNetImg(url,callback,...)
	if not url or url == "" or not callback then
		return
	end
	local args = {...}
	local tcallback = function(success, sprite,path)
		if success and callback then
			if callback then
				callback(path,unpack(args))
			end
	    else
	    	if callback then
				callback("",unpack(args))
			end
	    end
	end

	local imgLoaderId = game.ImageLoader:nextLoaderId()
	local urlType = game.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
	game.ImageLoader:loadAndCacheImage(
        imgLoaderId, 
        url, 
        tcallback, 
        urlType
    )

end



function WeChatPluginAndroid:onWeChatReq(jsonStr)
	
end


function WeChatPluginAndroid:onWeChatResp(jsonStr)
	local jsonObj = json.decode(jsonStr)
	if not jsonObj then
		return
	end
	local wtype = jsonObj.wtype
	print(wtype,"wtype",tostring(wtype == "login"))
	dump(jsonObj,"onWeChatResp")
	if wtype == "login" then
		self:onHandleLogin(jsonObj)
	elseif wtype == "share" then
		self:onHandleShare(jsonObj)
	elseif wtype == "pay" then
		self:onHandlePay(jsonObj)
	end
end


function WeChatPluginAndroid:onHandleShare(jsonObj)
	print("WeChatPluginIos:onHandleShare")
	local stype = jsonObj.stype
	local errStr = jsonObj.errStr
	local stype = jsonObj.stype

	print(self.currentShareType_,"self.currentShareType_")

	if self.currentShareType_ == "text" then
		if self.shareTextCallback_ then
			self.shareTextCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "image" then
		if self.shareImgCallback_ then
			self.shareImgCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "video" then
		if self.shareVideoCallback_ then
			self.shareVideoCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "music" then
		if self.shareMusicCallback_ then
			self.shareMusicCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "app" then
		if self.shareAppDataCallback_ then
			self.shareAppDataCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "webPage" then
		if self.shareWebPageCallback_ then
			self.shareWebPageCallback_(jsonObj)
		end
	end

end

function WeChatPluginAndroid:onHandlePay(jsonObj)
	if self.makePurchaseCallback_ then
		self.makePurchaseCallback_(jsonObj)
	end
end


function WeChatPluginAndroid:onHandleLogin(jsonObj)
	print("WeChatPluginAndroid:onHandleLogin",self.loginCallback_)
	local country = jsonObj.country
	local lang = jsonObj.lang
	local state = jsonObj.state
	local url = jsonObj.url
	local etype = jsonObj.etype
	local code = jsonObj.code

	-- if etype == "ok" then
	-- 	if self.loginCallback_ then
	-- 		self.loginCallback_(etype,code,state,lang,country,url)
	-- 	end
	-- elseif etype == "cancel" then

	-- elseif etype == "denied" then

	-- elseif etype == "unsupport" then

	-- elseif etype == "unknown" then

	-- end

	if self.loginCallback_ then
		self.loginCallback_(etype,jsonObj)
	end


end




return WeChatPluginAndroid