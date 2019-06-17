
local GameHttp = import("..net.GameHttp")

local LoadAllGameControl = class("LoadAllGameControl")

local instance

function LoadAllGameControl:getInstance()
    instance = instance or LoadAllGameControl.new()
    return instance
end

function LoadAllGameControl:ctor()
    self.logger = core.Logger.new("LoadAllGameControl")
    self.schedulerPool_ = core.SchedulerPool.new()

    self.isGettingUrl_ = false
    self.getUrlRetryTimes_ = 3

    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false

    -- 回调表{obj:callback}
    self.loadGamesConfigCallbacks_ = {}
end

function LoadAllGameControl:__callback(result, data)
    local tmpCallbacks = self.loadGamesConfigCallbacks_
    for obj, callback in pairs(tmpCallbacks) do
        callback(obj, result, data)
    end
    self.loadGamesConfigCallbacks_ = {}
end

function LoadAllGameControl:loadConfig(obj, callback, reload)

    if obj then
        self.loadGamesConfigCallbacks_[obj] = callback
    end

    local loadUrlFunc
    loadUrlFunc = function()
        if self.__configUrl then
            self:onGetConfigUrl(true, self.__configUrl)
        else
            self.isGettingUrl_ = true
            self.__getPrivateUrlReqId=GameHttp.getAllGameList(function(data)
                self.__getPrivateUrlReqId = nil
                self.__configUrl = data
                --print("获取全国地址成功")
                dump(data,"data")
                self:onGetConfigUrl(true,data)
            end,function(errData)
               -- print("获取全国地址失败")
                self.__getPrivateUrlReqId = nil

                self.getUrlRetryTimes_ = self.getUrlRetryTimes_ - 1
                if self.getUrlRetryTimes_ > 0 then
                    self.schedulerPool_:delayCall(function()
                        loadUrlFunc()
                    end, 2)
                else
                   self:onGetConfigUrl(false,nil)
                end
            end)
        end
    end

    --优先使用登录接口传的 urls.allGame,
    self.__configUrl = game and game.userData and game.userData["urls.allGame"] or nil


    if not self.__configUrl then
        if self.isGettingUrl_ then
            if self.getUrlRetryTimes_ < 3 then
                -- 更新重试次数
                self.getUrlRetryTimes_ = 3
            end
        else
            loadUrlFunc()
        end
    else
        if reload then
            self.__configUrl = nil
            loadUrlFunc()
        else
            self:onGetConfigUrl(true,self.__configUrl)
        end

    end
end

function LoadAllGameControl:onGetConfigUrl(succ,url)
    print("onGetConfigUrl",succ,url)
    self.isGettingUrl_ = false
    if succ then
        self:loadConfig_()
    else
        self:__callback(false)
    end
end

--[[
"<var>" = {
    "game_icon"       = "http://qqhnghcdn.ode.cn/staticres/images/icon/hongzhongmajiang.png"
    "game_id"         = "10051"
    "game_name"       = "全国--红中麻将"
    "game_type"       = "3"
    "game_type_title" = "麻将"
    "pkg_name"        = "hongzhongmj"
    "game_runtype"    = "native"   游戏运行环境 nil/native:内部app web:内部webview  ext_native:外部app ext_web:外部web
    
    -- H5游戏扩展字段，可选
    game_resolution = {1280,720}
    game_orientation = 1   1:横屏 2:竖屏
    game_autoscale   = "FIXED_WIDTH_HEIGHT"  适配方式
}
]]

--运行环境
--game_runtype native:内部app web:内部webview  ext_native:外部app ext_web:外部web
function LoadAllGameControl:initGameAndPkg_(data)
    if not data then return end
    print("LoadAllGameControl:initGameAndPkg_(", data, ")")
    for k, v in ipairs(data) do
        local game_id = checkint(v.game_id)
        local run_type = v.game_runtype
        local pkg_name = v.pkg_name

        --只初始化runtype为navite的子游戏
        if (not run_type or run_type == "native" )and pkg_name then
            game.gameManager:initPkgName(game_id, pkg_name)
            game.gameManager:initGame(game_id)
        end
        
    end
end

function LoadAllGameControl:loadConfig_()

    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            core.cacheFile(self.__configUrl or "", function(result, content,filePath)
                self.isConfigLoading_ = false
                if result == "success" then
                    
                    -- dump(content,"content====")
                    local tempDatas = json.decode(content)
                    --校验
                    if tempDatas then
                        self.isConfigLoaded_ = true
                        self.isConfigLoading_ = false


                        self:preDealGamesData(tempDatas)
                        self:initGameAndPkg_(tempDatas)
                        

                        self.__allGameData = tempDatas
                        -- 用于查找是否所有游戏中有这个游戏
                        self.__allContainedGamesData = {}
                        for k,v in ipairs(self.__allGameData) do
                            local gameid = tonumber(v.game_id)
                            if gameid then
                                self.__allContainedGamesData[gameid] = v
                            end
                        end
                        dump(self.__allGameData,"self.__allGameData",10)

                        self:__callback(true, self.__allGameData)

                    else

                        if game.Bugly then
                            game.Bugly.reportLog("LoadAllGameControl:loadConfig_", "json.decode fail")
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
                            self:__callback(false)
                        end

                        end

                    
                else
                    self.logger:debug("loadConfigFunc failed => " .. json.encode(jsn))
                    self.isConfigLoaded_ = false
                    self.isConfigLoading_ = false

                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        self.schedulerPool_:delayCall(function()
                            loadConfigFunc()
                        end, 2)
                    else
                        self:__callback(false)
                    end
                end
            end, "configs")
        elseif self.isConfigLoaded_ then
            self:__callback(true, self.__allGameData)
        end
    end

    loadConfigFunc()

end

function LoadAllGameControl:cancelAll()
    self.loadGamesConfigCallbacks_ = {}
end

function LoadAllGameControl:cancel(obj)
    if obj then
        self.loadGamesConfigCallbacks_[obj] = nil
    end
end

function LoadAllGameControl:isConfigLoaded()

	return self.isConfigLoaded_
end

function LoadAllGameControl:isConfigLoading()
    return self.isConfigLoading_
end

function LoadAllGameControl:getAllGamesData()
	return self.__allGameData
end

--根据传入的ids返回多个gameData
function LoadAllGameControl:getGamesDataByIds(ids)
    if type(ids) ~= "table" or not self.__allGameData then
        return {}
    end
    local tb = {}
    for _,v in ipairs(ids) do
        for __,vv in ipairs(self.__allGameData) do
            if tonumber(vv.game_id) == v then
                table.insert(tb,vv)
                break
            end
        end
    end

    return tb

end

-- 是否全部游戏中有这个游戏
function LoadAllGameControl:isGameContained(gameid)
    print("LoadAllGameControl:isGameContained(", gameid, ")")
    gameid = tonumber(gameid)
    if self.__allContainedGamesData and gameid then 
        return self.__allContainedGamesData[gameid]
    end
    return nil
end

-- 获取游戏的数据，如果没传key则返回整个数据表，否则，返回对应项
function LoadAllGameControl:getGameDataByGameId(gameid, key)
    print("LoadAllGameControl:getGameData(", gameid, key, ") => ", self.__allGameData)
    gameid = tonumber(gameid)
    if self.__allGameData and gameid then
        local tmpData = nil
        for k,v in ipairs(self.__allGameData) do
            if tonumber(v.game_id) == gameid then
                tmpData = v
                break
            end
        end

        if tmpData then
            if key then
                return tmpData[key]
            else
                return tmpData
            end
        end
    end
    return nil
end

--获取对应gameid的游戏类型
function LoadAllGameControl:getGameTypeByGameId(gameid)
    if not gameid then return nil end
    if not self.__allGameData then return nil end
    for k,v in pairs(self.__allGameData) do
        if tonumber(v.game_id) == tonumber(gameid) then
            return tonumber( v.game_type )
        end
    end
    return nil
end
--获取游戏名称
function LoadAllGameControl:getGameNameByGameId(gameid)
    if not gameid then return "" end
    if not self.__allGameData then return "" end
    for k,v in pairs(self.__allGameData) do
        if tonumber(v.game_id) == tonumber(gameid) then
            return  v.game_name 
        end
    end
    return ""
end


--获取对应gameid的游戏类型  bArray:是否数组形式返回
function LoadAllGameControl:getAllGameTypes(bArray)
    local gtypes = {}
    if self.__allGameData then
        for k,v in pairs(self.__allGameData) do
            if not gtypes[checkint(v.game_type)] then
                gtypes[checkint(v.game_type)] = {game_type = v.game_type,type_title = v.game_type_title}
            end
            
        end

    end

    if bArray then
        gtypes = table.values(gtypes)
    end
    return gtypes
end


function LoadAllGameControl:getGameTypesByGameids(gameids,bArray)
    local gtypes = {}
    for i,v in ipairs(gameids) do
        local gamedata = self:getGameDataByGameId(v)
        if gamedata then
            if not gtypes[checkint(gamedata.game_type)] then
                gtypes[checkint(gamedata.game_type)] = {game_type = gamedata.game_type,type_title = gamedata.game_type_title}
            end
        end
        
    end

    if bArray then
        gtypes = table.values(gtypes)
    end
    return gtypes
end


-- function LoadAllGameControl:getCityByCityId(cityId)
--     if not cityId then return nil end
--     if not self.__allGameData then return nil end

--     for k,v in pairs(self.__allGameData) do
--         for kk,vv in pairs(v._child) do
--             if checkint(cityId) == checkint(vv.id) then
--                 return vv
--             end
--         end
--     end

--     return nil

-- end








function LoadAllGameControl:preDealGamesData(data)
    if data then
        --未配置game_runtype字段的默认填充为navite
        table.walk(data,function(v,k)
            if v and (v.game_runtype == nil or v.game_runtype == "") then
                v.game_runtype = "native"
            end
        end)
    end
end

function LoadAllGameControl:getGameByGameId(id)
    -- if not self.__gamesData then
    --     return 
    -- end
    -- for _,gameType in pairs(self.__gamesData.gamelist) do
    --     for __,game in pairs(gameType.games) do
    --         if tonumber(game.id) == tonumber(id) then
    --             return game
    --         end
    --     end
        
    -- end
end

function LoadAllGameControl:getGamesByGameType(ctype)
	if not self.__allGameData then
		return {} 
	end

    ctype = checkint(ctype)
    local tGames = {}
	for _,v in pairs(self.__allGameData) do
        local g_type = checkint(v.game_type)
        local c_type = checkint
        if g_type == ctype then
            tGames[checkint(v.game_id)] = v
        end
	end

    return tGames
end


function LoadAllGameControl:getH5RecommendGames()
    local tempDatas = {}
    if self.__allGameData then
        local tmpData = nil
        for k,v in ipairs(self.__allGameData) do
            if v.game_runtype == "web" and checkint(v.game_recommend) == 1 then
                table.insert(tempDatas,v)
            end
        end
    end
    return tempDatas

end

function LoadAllGameControl:getRoomDatasByGameid(id)
	-- if not self.__gamesData then
	-- 	return 
	-- end
	-- for k,rooms in pairs(self.__gamesData.roomlist) do
	-- 	if tonumber(k) == tonumber(id) then
	-- 		return rooms
	-- 	end
	-- end
end


-- function LoadAllGameControl:getGameTypeByIndex(idx)
--     -- if not self.__gamesData then
--     --     return 
--     -- end
--     -- if idx < 1 or idx > #self.__gamesData.gamelist then
--     --     return
--     -- end
--     -- return self.__gamesData.gamelist[idx]
-- end

function LoadAllGameControl:getRoomDatasByGameidAndLevel(id, level)
    -- if not self.__gamesData then
    --     return 
    -- end
    -- for k,rooms in pairs(self.__gamesData.roomlist) do
    --     if tonumber(k) == tonumber(id) then
    --         for i, room in ipairs(rooms) do
    --             if tonumber(room.id) == tonumber(level) then
    --                 return room
    --             end
    --         end
    --     end
    -- end
end



function LoadAllGameControl:getQuickPlayRoom(gameid,money)
    -- local rooms = self:getRoomDatasByGameid(gameid)
    -- local fdata
    -- for _,v in ipairs(rooms) do
    --     if money <= checkint(v.maxin) then
    --         fdata = v
    --         break
    --     end
    -- end

    -- if not rooms then
    --     return 
    -- end

    -- for _,v in ipairs(rooms) do
    --     if money >= checkint(v.minin) then
    --         fdata = v
    --         break
    --     end
    -- end

    -- if not fdata then
    --     fdata = rooms[#rooms]
    -- end

    -- return fdata
end



function LoadAllGameControl:getSubGamelist()
    -- if not self.__gamesData then
    --     return 
    -- end

    -- local subGames = {}

    -- for _,gameType in pairs(self.__gamesData.gamelist) do
    --     for __,game in pairs(gameType.games) do
    --         table.insert(subGames,game)
    --     end
        
    -- end

    -- return subGames
end


return LoadAllGameControl

