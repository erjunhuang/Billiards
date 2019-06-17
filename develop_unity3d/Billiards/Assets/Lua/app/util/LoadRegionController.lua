local LoadRegionController = class("LoadRegionController")

local instance

function LoadRegionController:getInstance()
    instance = instance or LoadRegionController.new()
    return instance
end

function LoadRegionController:ctor()
    self.logger = core.Logger.new("LoadRegionController")
    self.schedulerPool_ = core.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end



function LoadRegionController:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadChatConfigCallback_ = callback
    self:loadConfig_()
end


function LoadRegionController:loadConfig_()

    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            core.cacheFile(self.url_ or "", function(result, content,filePath)
                if result == "success" then
                    
                    local RegionData = json.decode(content)
                    if RegionData then
                        self.isConfigLoaded_ = true
                        self.isConfigLoading_ = false

                        self.__RegionData = RegionData

                        if self.loadChatConfigCallback_ then
                            self.loadChatConfigCallback_(true, self.__RegionData)
                        end

                    else

                        
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
                           if self.loadChatConfigCallback_ then
                                self.loadChatConfigCallback_(false)
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
                       if self.loadChatConfigCallback_ then
                            self.loadChatConfigCallback_(false)
                        end
                    end
                end
            end, "configs")
        elseif self.isConfigLoaded_ then
             if self.loadChatConfigCallback_ then
                self.loadChatConfigCallback_(true, self.__RegionData)
            end
        end
    end

    loadConfigFunc()

end


function LoadRegionController:cancel()
    if self.loadChatConfigCallback_ then
        self.loadChatConfigCallback_ = nil
    end
end

function LoadRegionController:isConfigLoaded()

	return self.isConfigLoaded_
end

function LoadRegionController:isConfigLoading()
    return self.isConfigLoading_
end


function LoadRegionController:getRegionData()
	return self.__RegionData
end


function LoadRegionController:preDealGamesData(data)
	-- body

end


return LoadRegionController

