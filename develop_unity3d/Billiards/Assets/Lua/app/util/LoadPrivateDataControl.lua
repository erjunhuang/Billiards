local GameHttp = import("..net.GameHttp")

local LoadPrivateDataControl = class("LoadPrivateDataControl")
function LoadPrivateDataControl:ctor()
    self.logger = core.Logger.new("LoadPrivateDataControl")
    self.schedulerPool_ = core.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    self.__configUrl = nil
end

-- reload 是否拉取最新url
function LoadPrivateDataControl:loadConfig(callback,reload)
    print("LoadPrivateDataControl:loadConfig",reload)

    self.loadPrivateConfigCallback_ = callback
    local retryLimit = 3
    local loadUrlFunc
    loadUrlFunc = function()
        if not self.__configUrl  then
            self.__getPrivateUrlReqId=GameHttp.getPrivateList(function(data)
                self.__getPrivateUrlReqId = nil
                self.__configUrl = data
                self:onGetConfigUrl(true,data)
            end,function(errData)
                self.__getPrivateUrlReqId = nil

                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        loadUrlFunc()
                    end, 2)
                else
                   self:onGetConfigUrl(false,nil)
                end

            end)
        elseif self.__configUrl then
            self:onGetConfigUrl(true,self.__configUrl)
        end
    end

    if not self.__configUrl then
        loadUrlFunc()
    else
        if reload then
            self.__configUrl = nil
            loadUrlFunc()
        else
            self:onGetConfigUrl(true,self.__configUrl)
        end

    end

end

function LoadPrivateDataControl:onGetConfigUrl(succ,url)
    print("onGetConfigUrl",succ,url)
    if succ then
        self:loadConfig_()
    else
        if self.loadPrivateConfigCallback_ then
            self.loadPrivateConfigCallback_(false)
        end
    end
end


function LoadPrivateDataControl:loadConfig_()

    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            core.cacheFile(self.__configUrl or "", function(result, content,filePath)
                self.isConfigLoading_ = false
                if result == "success" then

                    local tempDatas = json.decode(content)
                    if tempDatas then
                        self.isConfigLoaded_ = true
                        self.isConfigLoading_ = false

                        self:preDealPrivateData(tempDatas)
                        self.privateData_ = tempDatas
                        --dump(self.privateData_,"self.privateData_",10)
                        if self.loadPrivateConfigCallback_ then
                            self.loadPrivateConfigCallback_(true, self.privateData_)
                        end
                    else
                        if game.Bugly then
                            game.Bugly.reportLog("LoadPrivateDataControl:loadConfig_", "json.decode fail:".. tostring(content))
                        end
                        --删除缓存
                        if core.isFileExist(filePath) then
                            nb.FileUtils:getInstance():removeFile(filePath)
                        end
                        

                        self.logger:debug("loadConfigFunc failed => ")

                        self.isConfigLoaded_ = false
                        self.isConfigLoading_ = false

                        retryLimit = retryLimit - 1
                        if retryLimit > 0 then
                            self.schedulerPool_:delayCall(function()
                                loadConfigFunc()
                            end, 2)
                        else
                           if self.loadPrivateConfigCallback_ then
                                self.loadPrivateConfigCallback_(false)
                            end
                        end
                    end

                else
                    self.logger:debug("loadConfigFunc failed => " )
                    self.isConfigLoaded_ = false
                    self.isConfigLoading_ = false

                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        self.schedulerPool_:delayCall(function()
                            loadConfigFunc()
                        end, 2)
                    else
                       if self.loadPrivateConfigCallback_ then
                            self.loadPrivateConfigCallback_(false)
                        end
                    end
                end
            end, "configs")
        elseif self.isConfigLoaded_ then
             if self.loadPrivateConfigCallback_ then
                self.loadPrivateConfigCallback_(true, self.privateData_)
            end
        end
    end

    loadConfigFunc()
end

function LoadPrivateDataControl:isConfigLoaded()
    return self.isConfigLoaded_
end

function LoadPrivateDataControl:isConfigLoading()
    return self.isConfigLoading_
end


function LoadPrivateDataControl:preDealPrivateData(data)
    if not data then return end

	for k,v in pairs(data) do
        v.game_id = checkint(k)
    end

end

function LoadPrivateDataControl:getPrivateData()
    return self.privateData_
end
--通过子游戏gameid获取私人房配置
function LoadPrivateDataControl:getPrivateDataByGameId(gameid)
    if not gameid then
        game.Bugly.reportLog("LoadPrivateDataControl:getPrivateDataByGameId", "gameid:" .. tostring(gameid))
    end
    if not self.privateData_ then 
        game.Bugly.reportLog("LoadPrivateDataControl:getPrivateDataByGameId", "self.privateData_ is nil")
        return nil 
    end
    for k,v in pairs(self.privateData_) do
        if checkint(k) == checkint(gameid) then
            return v
        end
    end
    game.Bugly.reportLog("LoadPrivateDataControl:getPrivateDataByGameId", "self.privateData_ is not nil but dose not contain gameid:" .. tostring(gameid))
    return nil

end


function LoadPrivateDataControl:getPrivateDataByGameIds(gameids,isArray)
    if not self.privateData_ then
        return {}
    end

    local tb = {}

    for i,vv in ipairs(gameids) do
        for k,v in pairs(self.privateData_) do
            local gameid = checkint(k)
             if checkint(vv) == gameid then
                if isArray then
                    table.insert(tb,v)
                else
                    tb[gameid] = v
                end
            end
        end
    end

    return tb
end

function LoadPrivateDataControl:cancel()
    self.loadPrivateConfigCallback_ = nil
end


return LoadPrivateDataControl