
local LoginManager = class("LoginManager")

LoginManager.LOGIN_TYPE_QQ = "QQ"
LoginManager.LOGIN_TYPE_WECHAT = "WECHAT"
LoginManager.LOGIN_TYPE_GUEST = "GUEST"
LoginManager.LOGIN_TYPE_SHELL = "SHELL"
LoginManager.LOGIN_TYPE_XIANLIAO = "XIANLIAO"
LoginManager.LOGIN_TYPE_PHONENUMBER = "PHONENUMBER"
LoginManager.LOGIN_TYPE_FACEBOOK = "FACEBOOK"
LoginManager.LOGIN_TYPE_CHUINIU = "CHUINIU"


LoginManager.LOGIN_MODE_QQ = 1
LoginManager.LOGIN_MODE_WECHAT = 4
LoginManager.LOGIN_MODE_GUEST = 3
LoginManager.LOGIN_MODE_SHELL = 4
LoginManager.LOGIN_MODE_XIANLIAO = 6
LoginManager.LOGIN_MODE_PHONENUMBER = 8
LoginManager.LOGIN_MODE_FACEBOOK = 9
LoginManager.LOGIN_MODE_CHUINIU = 10

local GameHttp = import("..net.GameHttp")
function LoginManager:ctor()
	self.schedulerPool_ = core.SchedulerPool.new()
	self.logger_ = core.Logger.new("LoginManager")
end

function LoginManager:login(loginType,resultCallback,errorCallback,...)
	if self.__isLogining then
		return 
	end

	if	loginType == LoginManager.LOGIN_TYPE_GUEST then
		self:startGuestLogin(...)
	elseif loginType == LoginManager.LOGIN_TYPE_WECHAT then
		self:startWeChatLogin(...)
	elseif loginType ==  LoginManager.LOGIN_TYPE_QQ then
		self:startQQLogin(...)
	elseif loginType ==  LoginManager.LOGIN_TYPE_SHELL then
		self:startShellLogin(...)
	elseif loginType ==  LoginManager.LOGIN_TYPE_XIANLIAO then
		self:startXianLiaoLogin(...)
	elseif loginType == LoginManager.LOGIN_TYPE_PHONENUMBER then
		self:startPhoneNumberLogin(...)
	elseif loginType == LoginManager.LOGIN_TYPE_FACEBOOK then
		self:startFacebookLogin(...)
	elseif loginType == LoginManager.LOGIN_TYPE_CHUINIU then
		self:startChuiNiuLogin(...)
	end

	self.__resultCallback = resultCallback
	self.__errorCallback = errorCallback
	self.__isLogining = true
end

function LoginManager:startGuestLogin(isDebug,token)
	self.logger_:debugf("startGuestLogin %s %s",isDebug,token)
	if isDebug then
		if token then
			token = core.encodeBase64(token .."*huasonggamehall") 
		else
			token = game.Native:getLoginToken(isDebug)
		end
	else
		if token then
			token = core.encodeBase64(token .."*huasonggamehall")
		else
			token = game.Native:getLoginToken()
		end
	end
	self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_GUEST,token,nil,nil,nil,
        handler(self, self.onLoginSucc_), 
        handler(self, self.onLoginError_)
    )
end

function LoginManager:onLoginSucc_(data)

	dump(data,"onLoginSucc_")
    self.__loginCfgReqId = nil
    
	self.__isLogining = false

	self.__isLogined = true
	self:processUserData(data)


    core.DataProxy:setData(game.dataKeys.USER_DATA, data, true)

    game.userDefault:setStringForKey(game.cookieKeys.LOGIN_SESSKEY, data.sesskey)

	if self.__resultCallback then
		self.__resultCallback(data)
	end
end




function LoginManager:processUserData(userData)
	userData.GAMES_JSON = userData["urls.roomlistUrl"]

end


function LoginManager:logout()
	self.__isLogining = false
	self.__isLogined = false
end


function LoginManager:isLogined( )
	return  self.__isLogined
end



function LoginManager:onLoginError_(errData)
    self.__loginCfgReqId = nil

	self.__isLogining = false
 
 	self.__isLogined = false
	if self.__errorCallback then
		self.__errorCallback(errData)
	end
end



function LoginManager:startQQLogin()
	
end




function LoginManager:startWeChatLogin(tcode,sesskey,scope,state)
	if not tcode or tcode == "" or not sesskey or sesskey == "" then
		if game.WeChat then
			game.WeChat:login(handler(self,self.onWeChatLoginResp),scope,state)
		end
	else
		local token = core.encodeBase64(tcode .."*huasonggamehall")
		self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_WECHAT,token,nil,sesskey,nil,
	        handler(self, self.onLoginSucc_), 
	        handler(self, self.onLoginError_),
	        {weixinCode = tcode}
	    )
	end

	
end


function LoginManager:checkNeedBindXianliao(wxstate)
	if not wxstate or wxstate == "" or wxstate == "xl_" then
		return false
	end

	if (string.len(wxstate) > 3) and (string.sub(wxstate,1,3) == "xl_") then
		local xltoken = string.sub(wxstate,4)
		return true,xltoken
	end

	return false
end

function LoginManager:checkNeedBindChuiniu(wxstate)
	if not wxstate or wxstate == "" or wxstate == "cn_" then
		return false
	end

	if (string.len(wxstate) > 3) and (string.sub(wxstate,1,3) == "cn_") then
		local cntoken = string.sub(wxstate,4)
		return true,cntoken
	end

	return false
end


function LoginManager:onFacebookLoginResp(success, result)
	self.logger_:debugf("LoginManager:onFacebookLoginResp-%s",result)
	if success then
        -- local tokenData = json.decode(result)
        if result then
            if type(result) == "string" then
                --兼容旧版和IOS
                local jobj = {ptype = "FACEBOOK",token = result}
				local jstr = json.encode(jobj) or ""
				game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TOKEN,jstr)
				local token = core.encodeBase64(result .."*huasonggamehall")
				self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_FACEBOOK,token,nil,nil,nil,
			        handler(self, self.onLoginSucc_), 
			        handler(self, self.onLoginError_),
			        {fbToken = token}
			    )
            end

        end
        
    else
        if result == "canceled" then
            self:onLoginError_({errorCode = -200})
        else
     		self:onLoginError_({errorCode = -201})
        end
    end
end


function LoginManager:onWeChatLoginResp(etype,jsonObj)
	self.logger_:debugf("LoginManager:onWeChatLoginResp-%s",etype)
	if etype == "ok" then
		local country = jsonObj.country
		local lang = jsonObj.lang
		local state = jsonObj.state
		local url = jsonObj.url
		local etype = jsonObj.etype
		local code = jsonObj.code

		local needBindXl,xltoken = self:checkNeedBindXianliao(state)
		local needBindCn,cntoken = self:checkNeedBindChuiniu(state)

		if self.isPhoneNumberBindingWechat then
			-- 手机号注册绑定微信
			self.isPhoneNumberBindingWechat = false
			local dataCache = self.phoneNumberBindingWechatDataCache
			self.phoneNumberBindingWechatDataCache = nil

			local phone = dataCache.phone
			local password = dataCache.password
			local verify_code = dataCache.verify_code
			local token = core.encodeBase64((tostring(phone) or "") .."*huasonggamehall")

			game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TYPE, "PHONENUMBER")
			self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_PHONENUMBER,token,nil,nil,nil,
		        handler(self, self.onLoginSucc_), 
		        handler(self, self.onLoginError_),
		        {phone = phone, password = password, verify_code=verify_code, phone_reg=1, weixinCode = code}
		    )
			return
		end

		if not needBindXl and not needBindCn then
			local jobj = {ptype = "WECHAT",token = code}
			local jstr = json.encode(jobj) or ""
			game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TOKEN,jstr)
			local token = core.encodeBase64(code .."*huasonggamehall")
			self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_WECHAT,token,nil,nil,nil,
		        handler(self, self.onLoginSucc_), 
		        handler(self, self.onLoginError_),
		        {weixinCode = code}
		    )

		else
			-- local jobj = {ptype = "XIANLIAO",token = xlcode}
			-- local jstr = json.encode(jobj) or ""
			-- game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TOKEN,jstr)
			if needBindXl then
				game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TYPE, "XIANLIAO")
				local token = core.encodeBase64(xltoken .."*huasonggamehall")
				self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_XIANLIAO,token,nil,nil,nil,
			        handler(self, self.onLoginSucc_), 
			        handler(self, self.onLoginError_),
			        {weixinCode = code,xianliaoToken = xltoken}
			    )

			elseif needBindCn then
				game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TYPE, "CHUINIU")
				local decodeCnToken = string.urldecode((cntoken or ""))
				decodeCnToken = core.decodeBase64(cntoken)
				if decodeCnToken then
					local cntokenTb = string.split(decodeCnToken,"|")
					if type(cntokenTb) == "table" and #cntokenTb == 3 then
						local openId = cntokenTb[1]
						local accessToken = cntokenTb[2]
						local refreshToken = cntokenTb[3]
						local token = core.encodeBase64(openId .."*huasonggamehall")
						self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_CHUINIU,token,nil,nil,nil,
					        handler(self, self.onLoginSucc_), 
					        handler(self, self.onLoginError_),
					        {weixinCode = code,chuiniuToken = string.urldecode((cntoken or ""))}
					    )

					end
					
				end
				
			end
			
		end
		
	elseif etype == "cancel" then
		self.__isLogining = false
		
		self:onLoginError_({errorCode = -100})
		
	elseif etype == "denied" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -101})
	elseif etype == "unsupport" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -102})
	elseif etype == "unknown" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -103})
	else
		self.__isLogining = false
		self:onLoginError_({errorCode = -104})
	end
end


--壳登录
function LoginManager:startShellLogin(param)
	local token
	if param.loginType == 1 then --qq
		token = core.encodeBase64(param.openId .."*huasonggamehall")
	elseif param.loginType == 2 then --微信
		token = core.encodeBase64(param.unionId .."*huasonggamehall")
	elseif param.loginType == 3 then --游客登录
		token = core.encodeBase64(param.openId .."*huasonggamehall")
	end
	local extern = {}
	for k,v in pairs(param) do
		if k ~= "loginResult"then
			if k == "headUrl" then
				extern[k] = core.encodeBase64(v)
			else
				extern[k] = v
			end
		end
	end
	self.__loginCfgReqId=GameHttp.login(param.loginType,token,param.openKey,nil,json.encode(extern),
        handler(self, self.onLoginSucc_), 
        handler(self, self.onLoginError_)
    )
end


function LoginManager:startXianLiaoLogin(tcode,sesskey)
	if not tcode or tcode == "" or not sesskey or sesskey == "" then
		if game.XianLiao then
			game.XianLiao:login(handler(self,self.onXianLiaoLoginResp))
		end
	else
		local token = core.encodeBase64(tcode .."*huasonggamehall")
		self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_XIANLIAO,token,nil,sesskey,nil,
	        handler(self, self.onLoginSucc_), 
	        handler(self, self.onLoginError_),
	        {xianliaoCode = tcode}
	    )
	end

end


function LoginManager:startChuiNiuLogin(sesskey,openId,accessToken,refreshToken)
	if not openId or openId == "" or not accessToken or accessToken == ""or not refreshToken or refreshToken == "" or not sesskey or sesskey == "" then
		if game.ChuiNiu then
			game.ChuiNiu:login(handler(self,self.onChuiNiuLoginResp))
		end
	else
		local token = core.encodeBase64(openId .."*huasonggamehall")
		local encodeCnToken = core.encodeBase64(string.format("%s|%s|%s",openId,accessToken,refreshToken))
		self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_CHUINIU,token,nil,sesskey,nil,
	        handler(self, self.onLoginSucc_), 
	        handler(self, self.onLoginError_),
	        {chuiniuToken = encodeCnToken}
	    )
	end

end


function LoginManager:startPhoneNumberLogin(sesskey, phoneNumber, password, verificationCode, isForgotPwd)
	local jobj = {ptype = "PHONENUMBER", token = tostring(phoneNumber) or ""}
	local jstr = json.encode(jobj) or ""
	game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TOKEN,jstr)
	game.userDefault:flush()
	local token = core.encodeBase64((tostring(phoneNumber) or "") .."*huasonggamehall")
	if verificationCode then
		if isForgotPwd then
			-- 忘记密码
			self.__loginCfgReqId = GameHttp.login(LoginManager.LOGIN_MODE_PHONENUMBER,token,nil,sesskey,nil,
			        handler(self, self.onLoginSucc_), 
			        handler(self, self.onLoginError_),
			        {phone = phoneNumber, password = password, verify_code = verificationCode, phone_reg = 2}
		        )
		else
			-- 注册
			-- 设一个标志位
			self.isPhoneNumberBindingWechat = true
			self.phoneNumberBindingWechatDataCache = {
				phone = phoneNumber,
				password = password,
				verify_code = verificationCode,
			}
			self:startWeChatLogin()
		end
		
	elseif sesskey then
		-- 用sesskey登录
		-- phone_reg == 0 为登录，1为注册，2为忘记密码
		self.__loginCfgReqId = GameHttp.login(LoginManager.LOGIN_MODE_PHONENUMBER,token,nil,sesskey,nil,
		        handler(self, self.onLoginSucc_), 
		        handler(self, self.onLoginError_),
		        {phone_reg = 0}
	        )
	else
		self.__loginCfgReqId = GameHttp.login(LoginManager.LOGIN_MODE_PHONENUMBER,token,nil,sesskey,nil,
		        handler(self, self.onLoginSucc_), 
		        handler(self, self.onLoginError_),
		        {phone = phoneNumber, password = password, verify_code = verificationCode, phone_reg = 0}
	        )
	end
end



function LoginManager:onChuiNiuLoginResp(etype,jsonObj)
	self.logger_:debugf("LoginManager:onXianLiaoLoginResp-etype:%s",etype)
	if etype == "ok" then
		local accessToken = jsonObj.accessToken
		local openId = jsonObj.openId
		local refreshToken = jsonObj.refreshToken

		local jobj = {ptype = "CHUINIU",accessToken = accessToken,openId=openId,refreshToken=refreshToken}
		local jstr = json.encode(jobj) or ""
		game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TOKEN,jstr)

		local token = core.encodeBase64(openId .."*huasonggamehall")

		local encodeCnToken = core.encodeBase64(string.format("%s|%s|%s",openId,accessToken,refreshToken))
		self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_CHUINIU,token,nil,nil,nil,
	        handler(self, self.onLoginSucc_), 
	        handler(self, self.onLoginError_),
	        {chuiniuToken = encodeCnToken}
	    )
	elseif etype == "cancel" then
		self.__isLogining = false
		
		self:onLoginError_({errorCode = -100})
		
	elseif etype == "denied" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -101})
	elseif etype == "unsupport" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -102})
	elseif etype == "unknown" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -103})
	else
		self.__isLogining = false
		self:onLoginError_({errorCode = -104})
	end
end



function LoginManager:onXianLiaoLoginResp(etype,jsonObj)
	self.logger_:debugf("LoginManager:onXianLiaoLoginResp-etype:%s",etype)
	if etype == "ok" then
		local country = jsonObj.country
		local lang = jsonObj.lang
		local state = jsonObj.state
		local url = jsonObj.url
		local etype = jsonObj.etype
		local code = jsonObj.code

		local jobj = {ptype = "XIANLIAO",token = code}
		local jstr = json.encode(jobj) or ""
		game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TOKEN,jstr)

		local token = core.encodeBase64(code .."*huasonggamehall")

		self.__loginCfgReqId=GameHttp.login(LoginManager.LOGIN_MODE_XIANLIAO,token,nil,nil,nil,
	        handler(self, self.onLoginSucc_), 
	        handler(self, self.onLoginError_),
	        {xianliaoCode = code}
	    )
	elseif etype == "cancel" then
		self.__isLogining = false
		
		self:onLoginError_({errorCode = -100})
		
	elseif etype == "denied" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -101})
	elseif etype == "unsupport" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -102})
	elseif etype == "unknown" then
		self.__isLogining = false
		self:onLoginError_({errorCode = -103})
	else
		self.__isLogining = false
		self:onLoginError_({errorCode = -104})
	end
end



function LoginManager:cancelCallback()
	self.__resultCallback = nil
	self.__errorCallback = nil
end

return LoginManager