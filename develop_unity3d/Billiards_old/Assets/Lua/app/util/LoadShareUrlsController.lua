local GameHttp = import("..net.GameHttp")

local LoadShareUrlsController = class("LoadShareUrlsController")


local instance

function LoadShareUrlsController.getInstance()
    instance = instance or LoadShareUrlsController.new()
    return instance
end



function LoadShareUrlsController:ctor()
    self.logger = core.Logger.new("LoadShareUrlsController")
    self.schedulerPool_ = core.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LoadShareUrlsController:loadConfig(callback)
    self.loadShareUrlsCallback_ = callback
    self:loadConfig_()
end


function LoadShareUrlsController:loadConfig_()
    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            self.__getUrlsReqId=GameHttp.getShareUrls(function(data)
                self.__getUrlsReqId = nil

            	self.isConfigLoaded_ = true
                self.isConfigLoading_ = false

                data = self:preDealUrlsData(data)
                self.urlsData_ = data


                dump("urlsData_",data)
                if self.loadShareUrlsCallback_ then
                    self.loadShareUrlsCallback_(true, self.urlsData_)
                end

            end,function(errData)
                self.__getUrlsReqId = nil
                
            	self.isConfigLoaded_ = false
                self.isConfigLoading_ = false
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        loadConfigFunc()
                    end, 1)
                else
                   if self.loadShareUrlsCallback_ then
                        self.loadShareUrlsCallback_(false)
                    end
                end

            end)
        elseif self.isConfigLoaded_ then
             if self.loadShareUrlsCallback_ then
                self.loadShareUrlsCallback_(true, self.urlsData_)
            end
        end
    end

    loadConfigFunc()

end



function LoadShareUrlsController:cancel()
    if self.loadShareUrlsCallback_ then
        self.loadShareUrlsCallback_ = nil
    end
end

function LoadShareUrlsController:isConfigLoaded()
    return self.isConfigLoaded_
end

function LoadShareUrlsController:isConfigLoading()
    return self.isConfigLoading_
end


function LoadShareUrlsController:preDealUrlsData(data)
	-- body
    local tempTb = {}
    for _,v in ipairs(data) do
        local newKey = "s_" .. v.keyurl
        tempTb[newKey] = v
    end

    if game and game.userData and tempTb["s_download_qr"] then
        game.userData["urls.erweimaUrl"] = tempTb["s_download_qr"].url or ""
    end
    

    return tempTb
end


function LoadShareUrlsController:getUrlsData()
    return self.urlsData_
end



function LoadShareUrlsController:getShareUrlByGameId(gameid)

    if not self.urlsData_ then
        return nil
    end

    local key = "s_" .. gameid

    local tb = self.urlsData_[key] or self.urlsData_["s_100"]
    if not tb then return nil end

    return tb.url

end


return LoadShareUrlsController