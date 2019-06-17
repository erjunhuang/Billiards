local PluginAndroidBase = import(".PluginAndroidBase")

local ChuiNiuPluginAdapter = class("ChuiNiuPluginAdapter",PluginAndroidBase)

local APPID = appconfig.wxAppid
local CHECK_SIGN = true

ChuiNiuPluginAdapter.SCENE = 
{
	WXSceneSession = 0,
	WXSceneTimeline = 1,
	WXSceneFavorite = 2,
}

local SCENE = ChuiNiuPluginAdapter.SCENE

function ChuiNiuPluginAdapter:ctor()
	self:init()
end



function ChuiNiuPluginAdapter:init()
	print("ChuiNiuPluginAdapter:init")
end


function ChuiNiuPluginAdapter:login(callback,scope,state)
	local scope = scope or "snsapi_userinfo"
	local state = state or "wx_login"
	self.loginCallback_ = callback
	print(self.loginCallback_,"self.loginCallback_")

	-- local code = "0111sVii0TYqYl1CdKfi0EmRii01sVig"
	local code = "0218Pr8S0MsDha2Poi6S0ukD8S08Pr8c"
	local data = 
	{
		wtype = "login",
		country = "china",
		lang = "zh",
		url = "",
		etype = "ok",
		code = code

	}

	self:onChuiNiuResp(json.encode(data))
end


function ChuiNiuPluginAdapter:shareText(text,scene,callback)
	-- text = text or ""
	-- scene = scene or SCENE.WXSceneSession
	-- self.shareTextCallback_ = callback
	-- self:call_("shareText",{text,scene},"(Ljava/lang/String;I)V")
end

function ChuiNiuPluginAdapter:shareImg(path,title,des,thumbImg,extra,callback)
	print("ChuiNiuPluginAdapter:shareImg",path,title,des,thumbImg,extra,callback)
	-- path = path or ""
	-- scene = scene or SCENE.WXSceneSession
	-- self.shareImgCallback_ = callback
	-- self:call_("shareImg",{path,scene},"(Ljava/lang/String;I)V")
end




function ChuiNiuPluginAdapter:shareRoom(url,title,des,thumbImg,scene,callback)

end

function ChuiNiuPluginAdapter:shareWebPage(url,title,des,thumbImg,scene,callback)
	-- url = url or ""
	-- title = title or ""
	-- des = des or ""
	-- thumbImg = thumbImg or ""
	-- scene = scene or SCENE.WXSceneSession
	-- print("shareWebPage",url,title,des,thumbImg,scene)
	-- self.shareWebPageCallback_ = callback
	-- self:call_("shareWebPage",{url,title,des,thumbImg,scene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
end





function ChuiNiuPluginAdapter:onWeChatReq(jsonStr)
	
end


function ChuiNiuPluginAdapter:onChuiNiuResp(jsonStr)
	local jsonObj = json.decode(jsonStr)
	if not jsonObj then
		return
	end
	local ctype = jsonObj.ctype
	print(ctype,"ctype",tostring(ctype == "login"))
	dump(jsonObj,"onChuiNiuResp")
	if ctype == "login" then
		self:onHandleLogin(jsonObj)
	elseif ctype == "share" then
		self:onHandleShare(jsonObj)
	end
end

function ChuiNiuPluginAdapter:onHandleShare(jsonObj)
	print("ChuiNiuPluginAdapter:onHandleShare",self.loginCallback_)
	local stype = jsonObj.stype
end


function ChuiNiuPluginAdapter:onHandleLogin(jsonObj)
	print("ChuiNiuPluginAdapter:onHandleLogin",self.loginCallback_)

	if self.loginCallback_ then
		self.loginCallback_(etype,jsonObj)
	end


end




return ChuiNiuPluginAdapter