local LoadChatContentsControl = class("LoadChatContentsControl")

local instance

function LoadChatContentsControl:getInstance()
    instance = instance or LoadChatContentsControl.new()
    return instance
end

function LoadChatContentsControl:ctor()
    self.logger = core.Logger.new("LoadChatContentsControl")
    self.schedulerPool_ = core.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end



function LoadChatContentsControl:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadChatConfigCallback_ = callback
    self:loadConfig_()
end


function LoadChatContentsControl:loadConfig_()

    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            core.cacheFile(self.url_ or "", function(result, content,filePath)
                self.isConfigLoading_ = false
                if result == "success" then
                    

                    local chatData = json.decode(content)
                    if chatData then
                        self.isConfigLoaded_ = true
                        self.isConfigLoading_ = false

                        self.__chatData = chatData
                        if self.loadChatConfigCallback_ then
                            self.loadChatConfigCallback_(true, self.__chatData)
                        end

                    else
                        if game.Bugly then
                            game.Bugly.reportLog("LoadChatContentsControl:loadConfig_", "json.decode fail")
                        end
                        
                        self.logger:debug("loadConfigFunc failed => ")
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
                self.loadChatConfigCallback_(true, self.__chatData)
            end
        end
    end

    loadConfigFunc()

end


function LoadChatContentsControl:cancel()
    if self.loadChatConfigCallback_ then
        self.loadChatConfigCallback_ = nil
    end
end

function LoadChatContentsControl:isConfigLoaded()

	return self.isConfigLoaded_
end

function LoadChatContentsControl:isConfigLoading()
    return self.isConfigLoading_
end


function LoadChatContentsControl:getChatData()
	return self.__chatData
end


function LoadChatContentsControl:getChatDataByGameId(key)
    if not self.__chatData then
        return 
    end
    -- 是否含有其他形式的key
    -- 默认为GameId
    -- 带有方言：{GameId}.fangyan
    if self.__chatData[key] then
        return self.__chatData[key]
    else
        -- 没有方言key 返回默认gameId的原本内容
        local gameId = string.split(key, ".")[1]
        return self.__chatData[gameId]
    end
end


function LoadChatContentsControl:preDealGamesData(data)
	-- body

end


return LoadChatContentsControl

