local LoadLevelControl =  class("LoadLevelControl")
local instance

function LoadLevelControl:getInstance()
    instance = instance or LoadLevelControl.new()
    return instance
end

function LoadLevelControl:ctor()
    self.requestId_ = 0
    self.requests_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LoadLevelControl:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadLevelConfigCallback_ = callback
    self:loadConfig_()
end


-- {"Lv2","博定新手",29,"20个道具"}  等级，称号，经验，奖励
function LoadLevelControl:processLevelData(jsonData)

    local ret = {}
    local itemData
    local lv
    for k,v in pairs(jsonData) do
        itemData = {}
        lv = string.sub(v[1],3)
        itemData.level = tonumber(lv)
        itemData.title = v[2] or ""
        itemData.exp = tonumber(v[3])
        itemData.reward = v[4] or ""
        table.insert(ret,itemData)
    end


    local lastExp = 0
    local t
    for i = #ret, 1, -1 do
        t = ret[i]
        t.needExp = lastExp > t.exp and lastExp - t.exp or 0
        lastExp = t.exp
    end



    return ret
end

function LoadLevelControl:loadConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true

        core.cacheFile(self.url_ or nk.userData.LEVEL_JSON or "", function(result, content)
            self.isConfigLoading_ = false
            if result == "success" then

                self.isConfigLoaded_ = true
                if not self.levelData_ then
                    self.levelConfigData_ = json.decode(content)
                    if self.levelConfigData_ == nil then
                        print("level  配置错误!!")
                    else
                        self.levelData_ = self:processLevelData(self.levelConfigData_)
                    end
                end

                if self.levelData_ then

                    for k, v in pairs(self.requests_) do
                        local called = false
                        -- for i=1,#self.levelData_ do
                            if v.getType then
                                v.called = true
                                if v.callback then
                                    v.callback(self.levelData_, v.dealFun((v.exp or v.level or v.title), self.levelData_))
                                end
                               
                                self.requests_[k] = nil
                                -- break;
                                -- self[getType](v.exp or v.level,v.callback)
                            end
                    end
                end
                if self.loadLevelConfigCallback_ then
                    self.loadLevelConfigCallback_(true, self.levelData_)
                end
            else
                if self.loadLevelConfigCallback_ then
                    self.loadLevelConfigCallback_(false)
                end
            end
        end, "level")
    elseif self.isConfigLoaded_ then
         if self.loadLevelConfigCallback_ then
            self.loadLevelConfigCallback_(true, self.levelData_)
        end
    end
end

function LoadLevelControl:cancel(requestId)
    self.requests_[requestId] = nil
end


--根据等级获得称号
function LoadLevelControl:getTitleByLevel(level, callback)
    local dealFun = 
    function(tlevel,levelData)
        local t
        for i=1,#levelData do
            t = levelData[i]
            if tonumber(t.level) == tonumber(tlevel) then
                return t.title
            end
        end
    end


    if self.isConfigLoaded_ then
        if self.levelData_ then
            local title = dealFun(level,self.levelData_);
            return title;
        end
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {level=level, callback=callback, getType = "getTitleByLevel",dealFun = dealFun}
        self:loadConfig_()

        return "",self.requestId_
    end
end


--根据经验获得等级
function LoadLevelControl:getLevelByExp(exp,callback)
    local dealFun = function(texp, levelData)
        local t
        for i=1,#levelData do
            t = levelData[i]
            if tonumber(t.exp) == tonumber(texp) then
                return i
            elseif tonumber(t.exp) > tonumber(texp) then
                local j
                if i - 1 < 1 then
                    j = 1
                else
                    j =  i - 1
                end

                return j
            end
        end

        return #levelData
    end


    if self.isConfigLoaded_ then
        if self.levelData_ then
            return dealFun(exp,self.levelData_)
        end
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {exp=exp, callback=callback, getType = "getLevelByExp", dealFun = dealFun}
        self:loadConfig_()
        return 1, self.requestId_
    end

end



--根据经验获得称号
function LoadLevelControl:getTitleByExp(exp,callback)

    local dealFun = function(texp)
        local level = self:getLevelByExp(exp)
        return self:getTitleByLevel(level)
    end

    if self.levelData_ then
        return dealFun(exp)
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {exp=exp, callback=callback,getType = "getTitleByExp",dealFun = dealFun}
        self:loadConfig_()
        return "",self.requestId_
    end
    
end

--根据经验值获得经验值升级进度 
--@return  进度百分比,升级已获得经验，升级总经验
function LoadLevelControl:getLevelUpProgress(exp,callback)    
    local dealFun = function(texp, levelData)
        local tlevel = self:getLevelByExp(texp)
        local nextLevel = (tlevel + 1 <= #levelData and tlevel + 1 or #levelData)
        if tlevel == nextLevel then
            return 0, 0, 0
        else
            local progress = texp - levelData[tlevel].exp
            local all = levelData[tlevel].needExp
            return progress / all, progress, all
        end
    end

    if self.levelData_ then
        return dealFun(exp, self.levelData_)
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {exp=exp, callback=callback,getType = "getLevelUpProgress",dealFun = dealFun}
        self:loadConfig_()

        return 0,0,0,self.requestId_
    end 
end

function LoadLevelControl:getLevelConfigData()
    return self.levelConfigData_
end


function LoadLevelControl:isConfigLoaded()
    return self.isConfigLoaded_
end


return LoadLevelControl