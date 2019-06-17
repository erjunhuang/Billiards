local PluginAndroidBase = import(".PluginAndroidBase")

local XianLiaoPluginAdapter = class("XianLiaoPluginAdapter",PluginAndroidBase)

local APPID = appconfig.wxAppid
local CHECK_SIGN = true

XianLiaoPluginAdapter.SCENE = 
{
	XLSceneSession = 0,
	XLSceneTimeline = 1,
	XLSceneFavorite = 2
}

local SCENE = XianLiaoPluginAdapter.SCENE

function XianLiaoPluginAdapter:ctor()
	self:init()
end



function XianLiaoPluginAdapter:init()
	print("XianLiaoPluginAdapter:init")
end


function XianLiaoPluginAdapter:login(callback,scope,state)
	local scope = scope or "snsapi_userinfo"
	local state = state or "wx_login"
	self.loginCallback_ = callback
	print(self.loginCallback_,"self.loginCallback_")

	local code = "ToEOiZi21Ju2Wgv14Jl6uQ=="
	local data = 
	{
		wtype = "login",
		country = "china",
		lang = "zh",
		url = "",
		etype = "ok",
		code = code

	}

	self:onWeChatResp(json.encode(data))
end


function XianLiaoPluginAdapter:shareText(text,scene,callback)
	-- text = text or ""
	-- scene = scene or SCENE.WXSceneSession
	-- self.shareTextCallback_ = callback
	-- self:call_("shareText",{text,scene},"(Ljava/lang/String;I)V")
end

function XianLiaoPluginAdapter:shareImg(path,scene,callback)
	-- path = path or ""
	-- scene = scene or SCENE.WXSceneSession
	-- self.shareImgCallback_ = callback
	-- self:call_("shareImg",{path,scene},"(Ljava/lang/String;I)V")
end

function XianLiaoPluginAdapter:shareMusic(url,title,des,thumbImg,scene,callback)
	-- url = url or ""
	-- title = title or ""
	-- des = des or ""
	-- thumbImg = thumbImg or ""
	-- scene = scene or SCENE.WXSceneSession
	-- self.shareMusicCallback_ = callback
	-- self:call_("shareMusic",{url,title,des,thumbImg,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
end


function XianLiaoPluginAdapter:shareVideo(url,title,des,thumbImg,scene,callback)
	-- url = url or ""
	-- title = title or ""
	-- des = des or ""
	-- thumbImg = thumbImg or ""
	-- scene = scene or SCENE.WXSceneSession
	-- self.shareVideoCallback_ = callback
	-- self:call_("shareVideo",{url,title,des,thumbImg,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
end

function XianLiaoPluginAdapter:shareWebPage(url,title,des,thumbImg,scene,callback)
	-- url = url or ""
	-- title = title or ""
	-- des = des or ""
	-- thumbImg = thumbImg or ""
	-- scene = scene or SCENE.WXSceneSession
	-- print("shareWebPage",url,title,des,thumbImg,scene)
	-- self.shareWebPageCallback_ = callback
	-- self:call_("shareWebPage",{url,title,des,thumbImg,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
end

function XianLiaoPluginAdapter:shareAppData(title,des,thumbImg,extInfo,filePath,scene,callback)
	-- title = title or ""
	-- des = des or ""
	-- thumbImg = thumbImg or ""
	-- extInfo = extInfo or ""
	-- filePath = filePath or ""
	-- scene = scene or SCENE.WXSceneSession
	-- self.shareAppDataCallback_ = callback
	-- self:call_("shareAppData",{title,des,thumbImg,extInfo,filePath,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
end



function XianLiaoPluginAdapter:onWeChatReq(jsonStr)
	
end


function XianLiaoPluginAdapter:onWeChatResp(jsonStr)
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
	end
end

function XianLiaoPluginAdapter:onHandleShare(jsonObj)
	print("XianLiaoPluginAdapter:onHandleShare",self.loginCallback_)
	local stype = jsonObj.stype
end


function XianLiaoPluginAdapter:onHandleLogin(jsonObj)
	print("XianLiaoPluginAdapter:onHandleLogin",self.loginCallback_)
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




return XianLiaoPluginAdapter