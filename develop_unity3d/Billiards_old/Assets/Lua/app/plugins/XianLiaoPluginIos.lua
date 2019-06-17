local PluginIosBase = import(".PluginIosBase")

local XianLiaoPluginIos = class("XianLiaoPluginIos",PluginIosBase)

local APPID = appconfig.xlAppid
XianLiaoPluginIos.SCENE = 
{
	XLSceneSession = 0,
	XLSceneTimeline = 1,
	XLSceneFavorite = 2,
}


local SCENE = XianLiaoPluginIos.SCENE

function XianLiaoPluginIos:ctor()
	XianLiaoPluginIos.super.ctor(self,"XianLiaoPluginIos","XianLiaoBridge")
	self:init()
end


function XianLiaoPluginIos:init()
	print("XianLiaoPluginIos:init")
	self:call_("init",{appID=APPID})
	self:call_("setXianLiaoResp", {listener = handler(self,self.onXianLiaoResp)})
	self:call_("setXianLiaoReq", {listener = handler(self,self.onXianLiaoReq)})
end

function XianLiaoPluginIos:login(callback,scope,state)
	local state = state or "xl_login"
	self.loginCallback_ = callback
	print(self.loginCallback_,"self.loginCallback_")
	self:call_("login",{state=state})
end


function XianLiaoPluginIos:shareText(text,scene,callback)
	text = text or ""
	scene = scene or SCENE.XLSceneSession
	self.shareTextCallback_ = callback
	self:call_("shareText",{text = text,scene=scene})
end

function XianLiaoPluginIos:shareImg(path,scene,callback,thumbImg)
	path = path or ""
	thumbImg = thumbImg or path or "share.jpg"
	scene = scene or SCENE.XLSceneSession
	thumbImg = thumbImg
	self.shareImgCallback_ = callback
	self:call_("shareImg",{path = path,scene=scene,thumbImg = thumbImg})
end



function XianLiaoPluginIos:shareAppData(title,des,thumbImg,roomId,roomToken,androidUrl,iosUrl,callback,scene)
	title = title or ""
	des = des or ""
	thumbImg = thumbImg or ""
	roomId = roomId or "-"
	roomToken = roomToken or "-"
	androidUrl = androidUrl or ""
	iosUrl = iosUrl or ""
	scene = scene or SCENE.XLSceneSession

	-- local isNetImg = string.find(thumbImg,"http://") or string.find(thumbImg,"https://")
	-- if not isNetImg then
		self:call_("shareAppData",{title=title,des=des,thumbImg=thumbImg,roomId=roomId,roomToken=roomToken,scene=scene,androidUrl=androidUrl,iosUrl=iosUrl})
	-- else
	-- 	local function callShareFunc(cdownImgPath,ctitle,cdes,croomId,croomToken,candroidUrl,ciosUrl,cthumbImg,cscene)
	-- 		self:call_("shareAppData",{title=ctitle,des=cdes,thumbImg=cdownImgPath,roomId=croomId,roomToken=croomToken,scene=cscene,androidUrl=candroidUrl,iosUrl=ciosUrl})
	-- 	end

	-- 	self:loadNetImg(thumbImg,callShareFunc,title,des,roomId,roomToken,androidUrl,iosUrl,thumbImg,scene)
	-- end

	print("shareAppData",title,des,thumbImg,roomId,roomToken,androidUrl,iosUrl,callback,scene)
	self.shareAppDataCallback_ = callback
end





function XianLiaoPluginIos:loadNetImg(url,callback,...)
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




function XianLiaoPluginIos:onXianLiaoReq(jsonObj)
	print("XianLiaoPluginIos:onXianLiaoReq")
end

function XianLiaoPluginIos:onXianLiaoResp(jsonObj)
	dump(jsonObj,"XianLiaoPluginIos:onXianLiaoResp")
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


function XianLiaoPluginIos:onHandleShareApp(jsonObj)
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


function XianLiaoPluginIos:onHandleShare(jsonObj)
	print("XianLiaoPluginIos:onHandleShare",self.loginCallback_)
	local stype = jsonObj.stype
end

function XianLiaoPluginIos:onHandleLogin(jsonObj)
	print("XianLiaoPluginIos:onHandleLogin",self.loginCallback_)
	local country = jsonObj.country
	local lang = jsonObj.lang
	local state = jsonObj.state
	local url = jsonObj.url
	local etype = jsonObj.etype
	local code = jsonObj.code
	if self.loginCallback_ then
		self.loginCallback_(etype,jsonObj)
	end

end





return XianLiaoPluginIos