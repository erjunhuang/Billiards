local PluginAndroidBase = import(".PluginAndroidBase")

local ChuiNiuPluginAndroid = class("ChuiNiuPluginAndroid",PluginAndroidBase)


function ChuiNiuPluginAndroid:ctor()
	ChuiNiuPluginAndroid.super.ctor(self,"ChuiNiuPluginAndroid","org.ode.cocoslib.chuiniu.ChuiNiuBridge")
	self:init()
end



function ChuiNiuPluginAndroid:init()


	if not appconfig.cnChat or not appconfig.cnChat.appId  or not appconfig.cnChat.appSecret then
		return
	end

	print("ChuiNiuPluginAndroid:init:",appconfig.cnChat.appId,appconfig.cnChat.appSecret)
	self:call_("init",{appconfig.cnChat.appId,appconfig.cnChat.appSecret},"(Ljava/lang/String;Ljava/lang/String;)V")

	self.onChuiNiuRespHandler_ = handler(self,self.onChuiNiuResp)
	self:call_("setChuiNiuResp", {self.onChuiNiuRespHandler_}, "(I)V")
end



function ChuiNiuPluginAndroid:isChuiNiuAppInstalled( ... )
	-- body
end



function ChuiNiuPluginAndroid:openWeChatApp( ... )
	local succ,result = self:call_("openWXApp",{},"()Z")
	if not succ or not result then
		return false
	else
		return result
	end
end


function ChuiNiuPluginAndroid:login(callback)
	self.loginCallback_ = callback
	print(self.loginCallback_,"self.loginCallback_")
	self:call_("login",{},"()V")
end


function ChuiNiuPluginAndroid:shareText(text,callback,url)
	local des = text or ""
	local backinfo =  ""
	local title = appconfig.appName
	url = url or ""
	local extra = ""
	self.currentShareType_ = "text"
	self.shareTextCallback_ = callback
	self:call_("shareText",{url,title,des,backinfo,extra},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")

end

function ChuiNiuPluginAndroid:shareImg(path,title,des,thumbImg,extra,callback)
	path = path or ""
	title = title or appconfig.appName
	des = des or ""
	thumbImg = thumbImg or ""
	extra = extra or ""

	self.currentShareType_ = "image"
	self.shareImgCallback_ = callback
	self:call_("shareImg",{path,title,des,thumbImg,extra},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end



function ChuiNiuPluginAndroid:shareRoom(url,title,des,backinfo,extra,callback)
	url = url or ""
	title = title or ""
	des = des or ""
	backinfo = backinfo or ""
	extra = extra or ""

	self.shareRoomCallback_ = callback
	self.currentShareType_ = "room"
	self:call_("shareRoom",{url,title,des,backinfo,extra},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function ChuiNiuPluginAndroid:shareWebPage(url,title,des,backinfo,extra,callback)
	url = url or ""
	title = title or ""
	des = des or ""
	backinfo = backinfo or ""
	extra = extra or ""
	print("shareWebPage",url,title,des,backinfo,extra,callback)
	self.shareWebPageCallback_ = callback
	self.currentShareType_ = "webPage"

	-- local isNetImg = string.find(thumbImg,"http://") or string.find(thumbImg,"https://")
	-- if not isNetImg then
		self:call_("shareWebPage",{url,title,des,backinfo,extra},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
	-- else
	-- 	local function callShareFunc(cdownImgPath,curl,ctitle,cdes,cthumbImg,cscene)
	-- 		self:call_("shareWebPage",{curl,ctitle,cdes,cdownImgPath,cscene},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
	-- 	end

	-- 	self:loadNetImg(thumbImg,callShareFunc,url,title,des,thumbImg,scene)
	-- end
end

function ChuiNiuPluginAndroid:makePurchase(callback,partnerId,prepayId,packageValue,nonceStr,timeStamp,sign,extData)
	-- print("partnerId",partnerId,"prepayId",prepayId,"packageValue",packageValue,"nonceStr",nonceStr,"timeStamp",timeStamp,"sign",sign,"extData",extData)
	-- partnerId = partnerId or ""
	-- prepayId = prepayId or ""
	-- packageValue = packageValue or ""
	-- nonceStr = nonceStr or ""
	-- timeStamp = timeStamp or os.time()
	-- sign = sign or ""
	-- extData = extData or ""

	-- self.makePurchaseCallback_ = callback
	-- self:call_("makePurchase",{APPID,partnerId,prepayId,packageValue,nonceStr,timeStamp,sign,extData},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end



function ChuiNiuPluginAndroid:loadNetImg(url,callback,...)
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

function ChuiNiuPluginAndroid:onChuiNiuResp(jsonStr)
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
	elseif ctype == "pay" then
		-- self:onHandlePay(jsonObj)
	elseif ctype == "appResp" then
		self:onHandleAppResp(jsonObj)
	end
end


function ChuiNiuPluginAndroid:onHandleShare(jsonObj)
	print("WeChatPluginIos:onHandleShare")
	local stype = jsonObj.stype
	local errStr = jsonObj.errStr
	local stype = jsonObj.stype
	local status = jsonObj.status  --onSuccess成功，onFailure 失败
	local message = jsonObj.message --0为成功 其它值为失败；

	local sresult = (status == "onSuccess" or tonumber(message) == 0) and "ok" or "fail"

	print(self.currentShareType_,"self.currentShareType_")

	if self.currentShareType_ == "text" then
		if self.shareTextCallback_ then
			self.shareTextCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "image" then
		if self.shareImgCallback_ then
			self.shareImgCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "room" then
		if self.shareRoomCallback_ then
			self.shareRoomCallback_(jsonObj)
		end
	elseif self.currentShareType_ == "webPage" then
		if self.shareWebPageCallback_ then
			self.shareWebPageCallback_(jsonObj)
		end
	end

end

function ChuiNiuPluginAndroid:onHandlePay(jsonObj)
	if self.makePurchaseCallback_ then
		self.makePurchaseCallback_(jsonObj)
	end
end


function ChuiNiuPluginAndroid:onHandleAppResp(jsonObj)
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


function ChuiNiuPluginAndroid:onHandleLogin(jsonObj)
	print("ChuiNiuPluginAndroid:onHandleLogin",self.loginCallback_)
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




return ChuiNiuPluginAndroid