local PluginAndroidBase = import(".PluginAndroidBase")

local FacebookPluginAndroid = class("FacebookPluginAndroid",PluginAndroidBase)
local logger = core.Logger.new("FacebookPluginAndroid")

function FacebookPluginAndroid:ctor()
    FacebookPluginAndroid.super.ctor(self,"FacebookPluginAndroid","org.ode.cocoslib.facebook.FacebookBridge")

    self.loginResultHandler_ = handler(self, self.onLoginResult_)
    self.invitableFriendsResultHandler_ = handler(self, self.onInvitableFriendsResult_)
    self.sendInvitesResultHandler_ = handler(self, self.onSendInvitesResult_)
    self.shareFeedResultHandler_ = handler(self, self.onShareFeedResult_)
    self.getRequestIdHandler_ = handler(self, self.onGetRequestIdResult_)
    self.uploadPhotoResultHandler_ = handler(self, self.onUploadPhotoResult_)
    self.getFacebookUserInfoHandler_ = handler(self,self.onGetFacebookUserInfoResult_)

    self:call_("setLoginCallback", {self.loginResultHandler_}, "(I)V")
    self:call_("setInvitableFriendsCallback", {self.invitableFriendsResultHandler_}, "(I)V")
    self:call_("setSendInvitesCallback", {self.sendInvitesResultHandler_}, "(I)V")
    self:call_("setShareFeedResultCallback", {self.shareFeedResultHandler_}, "(I)V")
    self:call_("setGetRequestIdResultCallback", {self.getRequestIdHandler_}, "(I)V")
    self:call_("setUploadPhotoResultCallback", {self.uploadPhotoResultHandler_}, "(I)V")
    self:call_("setGetFacebookUserCallback", {self.getFacebookUserInfoHandler_},"(I)V")

    self.cacheData_ = {}
end

function FacebookPluginAndroid:login(callback)
    self.loginCallback_ = callback
    self:call_("login", {}, "()V")
end

function FacebookPluginAndroid:logout()
    self.cacheData_ = {}
    self:call_("logout", {}, "()V")
end

function FacebookPluginAndroid:getInvitableFriends(inviteLimit, callback)
    self.getInvitableFriendsCallback_ = callback
    if self.cacheData_['getInvitableFriendsCallback_'] == nil then
        self:call_("getInvitableFriends", {inviteLimit}, "(I)V")
    else
        self:onInvitableFriendsResult_(self.cacheData_['getInvitableFriendsCallback_'])
    end
end

function FacebookPluginAndroid:sendInvites(data, toID, title, message, callback)
    self.sendInvitesCallback_ = callback 
    self:call_("sendInvites", {data, toID, title, message}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function FacebookPluginAndroid:shareFeed(params, callback)
    self.shareFeedCallback_ = callback
    self:call_("shareFeed", {json.encode(params)}, "(Ljava/lang/String;)V") 
end

function FacebookPluginAndroid:uploadPhoto(params, callback)
    self.uploadPhotoCallback_ = callback
    self:call_("uploadPhoto", {json.encode(params)}, "(Ljava/lang/String;)V")
end

function FacebookPluginAndroid:updateAppRequest()
    self.updateInviteRetryTimes_ = 3
    self:call_("getRequestId", {}, "()V")
end

function FacebookPluginAndroid:onGetRequestIdResult_(result)
    logger:debugf("onGetRequestIdResult_ %s", result)

    if result == "canceled" or result == "failed" then return end

    result = json.decode(result)
    if result and result.requestData and result.requestId then
        if string.find(result.requestData,"oldUserRecall") ~= nil then
            local localData = string.gsub(result.requestData,"oldUserRecall","")
            

        elseif string.find(result.requestData,"typeMouther")~= nil then
            

        else
            -- local d = {};
            -- d.data = result.requestData;
            -- d.requestid = result.requestId;

            -- game.http.inviteAddMoney(d,function(data)
            --     -- local retData = json.decode(data)
            --     -- if retData and retData.ret and retData.ret == 0 then
            --         -- 删除requestId
            --         self:call_("deleteRequestId", {result.requestId}, "(Ljava/lang/String;)V")
            --     -- end
            -- end,function(errData)
            --     if self.updateInviteRetryTimes_ > 0 then
            --         self:onGetRequestIdResult_(result)
            --         self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
            --     end
            -- end)

           
        end
    end
end

function FacebookPluginAndroid:onShareFeedResult_(result)
    logger:debugf("onShareFeedResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if self.shareFeedCallback_ then
        self.shareFeedCallback_(success, result)
    end
end

function FacebookPluginAndroid:onSendInvitesResult_(result)
    logger:debugf("onSendInvitesResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if success then        
        result = json.decode(result)        
    end
    if self.sendInvitesCallback_ then
        self.sendInvitesCallback_(success, result)
    end
end

function FacebookPluginAndroid:onInvitableFriendsResult_(result)
    logger:debugf("onInvitableFriendsResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if success then
        self.cacheData_['getInvitableFriendsCallback_'] = result
        result = json.decode(result)
    end
    if self.getInvitableFriendsCallback_ then        
        self.getInvitableFriendsCallback_(success, result)
    end
end

function FacebookPluginAndroid:onLoginResult_(result)
    logger:debugf("onLoginResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if success then
        local jsonObj = json.decode(result)
        if jsonObj ~= nil then
            result = jsonObj
        end
        
    end
    if self.loginCallback_ then
        self.loginCallback_(success, result)
    end
end

return FacebookPluginAndroid
