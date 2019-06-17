local PluginAndroidBase = import(".PluginAndroidBase")

local XianLiaoPluginAndroid = class("XianLiaoPluginAndroid",PluginAndroidBase)

local APPID = appconfig.xlAppid

local CHECK_SIGN = true

XianLiaoPluginAndroid.SCENE = 
{
	XLSceneSession = 0,
	XLSceneTimeline = 1,
	XLSceneFavorite = 2,
}

local SCENE = XianLiaoPluginAndroid.SCENE

function XianLiaoPluginAndroid:ctor()
	XianLiaoPluginAndroid.super.ctor(self,"XianLiaoPluginAndroid","org.ode.cocoslib.xianliao.XianLiaoBridge")
	self:init()
end



function XianLiaoPluginAndroid:init()
	print("XianLiaoPluginAndroid:init:",APPID)
	self:call_("init",{APPID},"(Ljava/lang/String;)V")

	self.onXianLiaoRespHandler_ = handler(self,self.onXianLiaoResp)
	self.onXianLiaoReqHandler_ = handler(self,self.onXianLiaoReq)

	self:call_("setXianLiaoResp", {self.onXianLiaoRespHandler_}, "(I)V")
	self:call_("setXianLiaoReq", {self.onXianLiaoReqHandler_}, "(I)V")
end


function XianLiaoPluginAndroid:login(callback,state)
	local state = state or "none"
	self.loginCallback_ = callback
	print(self.loginCallback_,"self.loginCallback_")
	self:call_("login",{state},"(Ljava/lang/String;)V")
end


function XianLiaoPluginAndroid:shareText(text,scene,callback)
	text = text or ""
	scene = scene or SCENE.XLSceneSession
	self.shareTextCallback_ = callback
	self:call_("shareText",{text,scene},"(Ljava/lang/String;I)V")
end

function XianLiaoPluginAndroid:shareImg(path,scene,callback)
	path = path or ""
	scene = scene or SCENE.XLSceneSession
	self.shareImgCallback_ = callback
	self:call_("shareImg",{path,scene},"(Ljava/lang/String;I)V")
end

function XianLiaoPluginAndroid:shareAppData(title,des,thumbImg,roomId,roomToken,androidUrl,iosUrl,callback,scene)
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	scene = scene or SCENE.XLSceneSession
	roomId = roomId or "-"
	roomToken = roomToken or "-"
	androidUrl = androidUrl or ""
	iosUrl = iosUrl or ""
	print("shareAppData",title,des,thumbImg,scene,roomId,roomToken,androidUrl,iosUrl)
	self.shareAppCallback_ = callback

	local isNetImg = string.find(thumbImg,"http://") or string.find(thumbImg,"https://")
	if not isNetImg then
		self:call_("shareAppData",{title,des,roomId,roomToken,androidUrl,iosUrl,thumbImg,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
	else
		local function callShareFunc(cdownImgPath,ctitle,cdes,croomId,croomToken,candroidUrl,ciosUrl,cthumbImg,cscene)
			self:call_("shareAppData",{ctitle,cdes,croomId,croomToken,candroidUrl,ciosUrl,cdownImgPath,cscene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
		end

		self:loadNetImg(thumbImg,callShareFunc,title,des,roomId,roomToken,androidUrl,iosUrl,thumbImg,scene)
	end
end


function XianLiaoPluginAndroid:loadNetImg(url,callback,...)
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



function XianLiaoPluginAndroid:onXianLiaoReq(jsonStr)
	
end


function XianLiaoPluginAndroid:onXianLiaoResp(jsonStr)
	local jsonObj = json.decode(jsonStr)
	if not jsonObj then
		return
	end
	local wtype = jsonObj.wtype
	print(wtype,"wtype",tostring(wtype == "login"))
	dump(jsonObj,"onXianLiaoResp")
	if wtype == "login" then
		self:onHandleLogin(jsonObj)
	elseif wtype == "share" then
		self:onHandleShare(jsonObj)
	elseif wtype == "shareApp" then
		self:onHandleShareApp(jsonObj)
	end
end

function XianLiaoPluginAndroid:onHandleShare(jsonObj)
	print("XianLiaoPluginAndroid:onHandleShare",self.loginCallback_)
	local stype = jsonObj.stype
end

function XianLiaoPluginAndroid:onHandleShareApp(jsonObj)
	print("XianLiaoPluginAndroid:onHandleInvite",self.loginCallback_)
	local roomToken = jsonObj.roomToken
	local roomId = jsonObj.roomId

	roomToken = json.decode(roomToken)
	if not roomToken then
		return
	end

	local makeUrl = "gamehall://ode.cn?"
	if roomToken.atype == "game" then
		local roomId = roomToken.roomId 
		makeUrl = makeUrl .. string.format("type=%s&table=%s",2,roomId)
	elseif roomToken.atype == "club" then
		local cid = roomToken.cid
		local roomId = roomToken.roomId
		makeUrl = makeUrl .. string.format("type=%s&clubId=%s",3,cid)
	elseif roomToken.atype == "playback" then
		local mid = roomToken.mid
		local playback = roomToken.playback
		local gameid = roomToken.gameid
		makeUrl = makeUrl .. string.format("type=%s&clubId=%s",4,cid)
	end

	if game.GameNative then
		local tjobj = {}
		tjobj.data = makeUrl
		game.GameNative:handleOpenUrl(tjobj)
	end
end



function XianLiaoPluginAndroid:onHandleLogin(jsonObj)
	print("XianLiaoPluginAndroid:onHandleLogin",self.loginCallback_)
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




return XianLiaoPluginAndroid