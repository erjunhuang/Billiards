local PluginIosBase = import(".PluginIosBase")

local WeChatPluginIos = class("WeChatPluginIos",PluginIosBase)

local APPID = appconfig.wxAppid
local CHECK_SIGN = true

WeChatPluginIos.SCENE = 
{
	WXSceneSession = 0,
	WXSceneTimeline = 1,
	WXSceneFavorite = 2,
}


local SCENE = WeChatPluginIos.SCENE

function WeChatPluginIos:ctor()
	WeChatPluginIos.super.ctor(self,"WeChatPluginIos","WeChatBridge")
	self:init()
end


function WeChatPluginIos:init()
	print("WeChatPluginIos:init")
	self:setAppid()
	self:call_("setWeChatResp", {listener = handler(self,self.onWeChatResp)})
	self:call_("setWeChatReq", {listener = handler(self,self.onWeChatReq)})
end

function WeChatPluginIos:openWeChatApp( ... )
	local succ,result = self:call_("openWXApp")
	if not succ or not result then
		return false
	else
		return result
	end
end

function WeChatPluginIos:setAppid(itype)
	-- do self:call_("init",{appID=APPID}) return end
	if itype == "share" then
		local wxshareid = game.getRandomWxShareId()
		self:call_("init",{appID=wxshareid})
	else
		self:call_("init",{appID=APPID})
	end
end


function WeChatPluginIos:login(callback,scope,state)
	self:setAppid()
	local scope = scope or "snsapi_userinfo"
	local state = state or "wx_login"
	self.loginCallback_ = callback
	print(self.loginCallback_,"self.loginCallback_")
	self:call_("login",{scope = scope,state=state})
end


function WeChatPluginIos:shareText(text,scene,callback)
	self:setAppid("share")
	text = text or ""
	scene = scene or SCENE.WXSceneSession
	self.shareTextCallback_ = callback
	self.currentShareType_ = "text"
	self:call_("shareText",{text = text,scene=scene})
end

function WeChatPluginIos:shareImg(path,scene,callback,thumbImg)
	self:setAppid("share")
	path = path or ""
	thumbImg = thumbImg or path or "share.jpg"
	scene = scene or SCENE.WXSceneSession
	thumbImg = thumbImg
	self.shareImgCallback_ = callback
	self.currentShareType_ = "image"
	self:call_("shareImg",{path = path,scene=scene,thumbImg = thumbImg})
end

function WeChatPluginIos:shareMusic(url,title,des,thumbImg,scene,callback)
	self:setAppid("share")
	url = url or ""
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	musicUrl = musicUrl or ""
	scene = scene or SCENE.WXSceneSession
	self.shareMusicCallback_ = callback
	self.currentShareType_ = "music"
	self:call_("shareMusic",{url=url,title=title,des=des,thumbImg=thumbImg,scene=scene})
end


function WeChatPluginIos:shareVideo(url,title,des,thumbImg,scene,callback)
	self:setAppid("share")
	url = url or ""
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	scene = scene or SCENE.WXSceneSession
	self.shareVideoCallback_ = callback
	self.currentShareType_ = "video"
	self:call_("shareVideo",{url=url,title=title,des=des,thumbImg=thumbImg,scene=scene})
end

function WeChatPluginIos:shareWebPage(url,title,des,thumbImg,scene,callback)
	self:setAppid("share")
	url = url or ""
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	scene = scene or SCENE.WXSceneSession
	self.shareWebPageCallback_ = callback
	self.currentShareType_ = "webPage"
	
	local isNetImg = string.find(thumbImg,"http://") or string.find(thumbImg,"https://")
	if not isNetImg then
		self:call_("shareWebPage",{url=url,title=title,des=des,thumbImg=thumbImg,scene=scene})
	else
		local function callShareFunc(cdownImgPath,curl,ctitle,cdes,cthumbImg,cscene)
			self:call_("shareWebPage",{url=curl,title=ctitle,des=cdes,thumbImg=cdownImgPath,scene=cscene})
		end

		self:loadNetImg(thumbImg,callShareFunc,url,title,des,thumbImg,scene)
	end

end

function WeChatPluginIos:shareAppData(title,des,thumbImg,extInfo,filePath,scene,callback)
	self:setAppid("share")
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	extInfo = extInfo or ""
	filePath = filePath or ""
	url = url or ""
	scene = scene or SCENE.WXSceneSession
	self.shareAppDataCallback_ = callback
	self.currentShareType_ = "app"
	self:call_("shareAppData",{title=title,des=des,thumbImg=thumbImg,extInfo=extInfo,filePath=filePath,scene=scene})
end


function WeChatPluginIos:makePurchase(callback,partnerId,prepayId,packageValue,nonceStr,timeStamp,sign,extData)
	print("partnerId",partnerId,"prepayId",prepayId,"packageValue",packageValue,"nonceStr",nonceStr,"timeStamp",timeStamp,"sign",sign,"extData",extData)
	self:setAppid()
	partnerId = partnerId or ""
	prepayId = prepayId or ""
	packageValue = packageValue or ""
	nonceStr = nonceStr or ""
	timeStamp = tostring(timeStamp or os.time())
	sign = sign or ""
	extData = extData or ""

	self.makePurchaseCallback_ = callback
	self:call_("makePurchase",{appId = APPID,partnerId=partnerId,prepayId=prepayId,packageValue=packageValue,nonceStr=nonceStr,timeStamp=timeStamp,sign=sign,extData=extData})
end



function WeChatPluginIos:loadNetImg(url,callback,...)
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




function WeChatPluginIos:onWeChatReq(jsonObj)
	print("WeChatPluginIos:onWeChatReq")
end

function WeChatPluginIos:onWeChatResp(jsonObj)
	dump(jsonObj,"WeChatPluginIos:onWeChatResp")
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


function WeChatPluginIos:onHandleShare(jsonObj)
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

function WeChatPluginIos:onHandlePay(jsonObj)
	if self.makePurchaseCallback_ then
		self.makePurchaseCallback_(jsonObj)
	end
end

function WeChatPluginIos:onHandleLogin(jsonObj)
	print("WeChatPluginIos:onHandleLogin",self.loginCallback_)
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





return WeChatPluginIos