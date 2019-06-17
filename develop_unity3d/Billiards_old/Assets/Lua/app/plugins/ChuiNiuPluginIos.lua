local PluginIosBase = import(".PluginIosBase")

local ChuiNiuPluginIos = class("ChuiNiuPluginIos",PluginIosBase)

local APPID = appconfig.wxAppid
local CHECK_SIGN = true

ChuiNiuPluginIos.SCENE = 
{
	WXSceneSession = 0,
	WXSceneTimeline = 1,
	WXSceneFavorite = 2,
}


local SCENE = ChuiNiuPluginIos.SCENE

function ChuiNiuPluginIos:ctor()
	ChuiNiuPluginIos.super.ctor(self,"ChuiNiuPluginIos","ChuiNiuBridge")
	self:init()
end


function ChuiNiuPluginIos:init()
	if not appconfig.cnChat or not appconfig.cnChat.appId  or not appconfig.cnChat.appSecret then
		return
	end

	print("ChuiNiuPluginIos:init")
	self:call_("init",{appId=appconfig.cnChat.appId,appSecret=appconfig.cnChat.appSecret})
	self:call_("setChuiNiuResp", {listener = handler(self,self.onChuiNiuResp)})
end

function ChuiNiuPluginIos:openWeChatApp( ... )
	local succ,result = self:call_("openWXApp")
	if not succ or not result then
		return false
	else
		return result
	end
end


function ChuiNiuPluginIos:login(callback,scope,state)
	self.loginCallback_ = callback
	print(self.loginCallback_,"self.loginCallback_")
	self:call_("login")
end


function ChuiNiuPluginIos:shareText(text,callback,url)
	self.shareTextCallback_ = callback
	local title = appconfig.appName
	local des = text or ""
	local backinfo =  ""
	local extra= ""
	local url = url or ""
	-- thumbImg = thumbImg or ""
	local thumbImg = ""  --http

	self.shareTextCallback_ = callback
	self.currentShareType_ = "text"
	self:call_("shareText",{url=url,title=title,des=des,backinfo=backinfo,extra=extra,thumbImg=thumbImg})
	
end

function ChuiNiuPluginIos:shareImg(path,title,des,thumbImg,extra,callback)
	path = path or ""
	title = title or appconfig.appName
	des = des or ""
	thumbImg = thumbImg or ""
	extra = extra or ""

	self.shareImgCallback_ = callback
	self.currentShareType_ = "image"
	self:call_("shareImg",{path = path,title=title,des = des,extra =extra,thumbImg = thumbImg})
end


function ChuiNiuPluginIos:shareRoom(url,title,des,backinfo,extra,callback)
	url = url or ""
	title = title or appconfig.appName
	des = des or ""
	backinfo = backinfo or ""
	extra = extra or ""
	-- thumbImg = thumbImg or ""
	local thumbImg = ""  --http

	self.shareRoomCallback_ = callback
	self.currentShareType_ = "room"
	self:call_("shareRoom",{url=url,title=title,des=des,backinfo=backinfo,extra=extra,thumbImg=thumbImg})
end

function ChuiNiuPluginIos:shareWebPage(url,title,des,backinfo,extra,callback)
	url = url or ""
	title = title or ""
	des = des or ""
	backinfo = backinfo or ""
	extra = extra or ""
	-- thumbImg = thumbImg or ""
	local thumbImg = ""  --http

	self.shareWebPageCallback_ = callback
	self.currentShareType_ = "webPage"
	
	-- local isNetImg = string.find(thumbImg,"http://") or string.find(thumbImg,"https://")
	-- if not isNetImg then
		self:call_("shareWebPage",{url=url,title=title,des=des,backinfo=backinfo,extra=extra})
	-- else
	-- 	local function callShareFunc(cdownImgPath,curl,ctitle,cdes,cthumbImg,cbackinfo,cextra)
	-- 		self:call_("shareWebPage",{url=curl,title=ctitle,des=cdes,thumbImg=cdownImgPath,backinfo=cbackinfo,extra=cextra})
	-- 	end

	-- 	self:loadNetImg(thumbImg,callShareFunc,url,title,des,thumbImg,scene)
	-- end

end


function ChuiNiuPluginIos:shareExtMsg(dict)
	if not dict or table.nums(dict) <= 0 then
		return
	end
	-- url = url or ""
	-- title = title or appconfig.appName
	-- des = des or ""
	-- backinfo = backinfo or ""
	-- extra = extra or ""
	-- thumbImg = thumbImg or ""
	-- local thumbImg = ""  --http

	self.shareRoomCallback_ = callback
	self.currentShareType_ = "extMsg"
	self:call_("shareExMsg",dict)
end



function ChuiNiuPluginIos:loadNetImg(url,callback,...)
	if not url or url == "" or not callback then
		return
	end
	local args = {...}
	local tcallback = function(success, sprite,path)
		if success and callback then
			if callback then
				callback(path,table.unpack(args))
			end
	    else
	    	if callback then
				callback("",table.unpack(args))
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


function ChuiNiuPluginIos:onChuiNiuResp(jsonObj)
	dump(jsonObj,"ChuiNiuPluginIos:onChuiNiuResp")
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
	elseif ctype == "pay" then
		-- self:onHandlePay(jsonObj)
	elseif ctype == "appResp" then
		self:onHandleAppResp(jsonObj)
	end
end

function ChuiNiuPluginIos:onHandleAppResp(jsonObj)
	local backinfo = jsonObj.backinfo
	local roomToken = json.decode(backinfo)
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


function ChuiNiuPluginIos:onHandleShare(jsonObj)
	print("ChuiNiuPluginIos:onHandleShare")
	local stype = jsonObj.stype
	local errStr = jsonObj.errStr
	local stype = jsonObj.stype

	local sresult = jsonObj.sresult  -- ok,cancal,fail

	print(self.currentShareType_,"self.currentShareType_")

	if self.currentShareType_ == "text" then
		if self.shareTextCallback_ then
			self.shareTextCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "image" then
		if self.shareImgCallback_ then
			self.shareImgCallback_(jsonObj)
		end
	elseif self.currentRoomType_ == "room" then
		if self.shareRoomCallback_ then
			self.shareRoomCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "webPage" then
		if self.shareWebPageCallback_ then
			self.shareWebPageCallback_(jsonObj)
		end
	end

end

function ChuiNiuPluginIos:onHandlePay(jsonObj)
	if self.makePurchaseCallback_ then
		self.makePurchaseCallback_(jsonObj)
	end
end

function ChuiNiuPluginIos:onHandleLogin(jsonObj)
	local accessToken = jsonObj.accessToken
	local openId = jsonObj.openId
	local refreshToken = jsonObj.refreshToken
	local etype = "fail"--jsonObj.etype

	if accessToken and accessToken ~= "" and openId and openId ~= "" and refreshToken and refreshToken ~= "" then
		etype = "ok"
	end

	if self.loginCallback_ then
		self.loginCallback_(etype,jsonObj)
	end


end





return ChuiNiuPluginIos