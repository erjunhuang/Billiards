local LoadPropsControl =  class("LoadPropsControl")
local instance

function LoadPropsControl:getInstance()
    instance = instance or LoadPropsControl.new()
    return instance
end

function LoadPropsControl:ctor()
    self.requestId_ = 0
    self.requests_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end
function LoadPropsControl:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadPropsConfigCallback_ = callback
    self:loadConfig_()
end
function LoadPropsControl:loadConfig_()


	local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            core.cacheFile(self.url_ or game.userData.PROPS_JSON, function(result, content,filePath)
                if result == "success" then

                    local propsConfigData = json.decode(content)
                    if propsConfigData then
                        self.isConfigLoaded_ = true
                        self.isConfigLoading_ = false

                        self.propsConfigData_ = propsConfigData

                        if self.loadPropsConfigCallback_ then
                            self.loadPropsConfigCallback_(true, self.propsConfigData_)
                        end

                    else

                        if game.Bugly then
                            game.Bugly.reportLog("LoadPropsControl:loadConfig_", "json.decode fail:".. tostring(content))
                        end
                        
                        self.logger:debug("loadConfigFunc failed => " )
                        self.isConfigLoaded_ = false
                        self.isConfigLoading_ = false

                        --删除缓存
                        if core.isFileExist(filePath) then
                            nb.FileUtils:getInstance():removeFile(filePath)
                        end

                        retryLimit = retryLimit - 1
                        if retryLimit > 0 then
                            self.schedulerPool_:delayCall(function()
                                loadConfigFunc()
                            end, 2)
                        else
                           if self.loadPropsConfigCallback_ then
                                self.loadPropsConfigCallback_(false)
                            end
                        end

                    end


                    
                else
                    self.logger:debug("loadConfigFunc failed => ")
                    self.isConfigLoaded_ = false
                    self.isConfigLoading_ = false

                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        self.schedulerPool_:delayCall(function()
                            loadConfigFunc()
                        end, 2)
                    else
                       if self.loadPropsConfigCallback_ then
                            self.loadPropsConfigCallback_(false)
                        end
                    end
                end
            end, "props")
        elseif self.isConfigLoaded_ then
             if self.loadPropsConfigCallback_ then
                self.loadPropsConfigCallback_(true, self.propsConfigData_)
            end
        end
    end

    loadConfigFunc()

end

function LoadPropsControl:getPropDataByPnid(pnid)
	local pdata = nil
	if self.propsConfigData_ then
		for i=1,#self.propsConfigData_ do
			local itemdata = self.propsConfigData_[i]
			if tonumber(pnid) == tonumber(itemdata.pnid) then
				pdata = itemdata
			end
		end
	end
	return pdata
end
function LoadPropsControl:cancel(requestId)
    self.requests_[requestId] = nil
end
return LoadPropsControl