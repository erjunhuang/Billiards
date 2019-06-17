local LoadCityControl = class("LoadCityControl")

local instance

function LoadCityControl:getInstance()
    instance = instance or LoadCityControl.new()
    return instance
end

function LoadCityControl:ctor()
    self.logger = core.Logger.new("LoadCityControl")
    self.schedulerPool_ = core.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end



function LoadCityControl:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadGamesConfigCallback_ = callback
    self:loadConfig_()
end


function LoadCityControl:loadConfig_()

    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            core.cacheFile(self.url_ or "", function(result, content,filePath)
                self.isConfigLoading_ = false
                if result == "success" then
                    
                    --dump(content,"content====")

                    local tempDatas = json.decode(content)
                    if tempDatas then
                        self.isConfigLoaded_ = true
                        self.isConfigLoading_ = false

                        self:preDealGamesData(tempDatas)
                        self.__cityData = tempDatas
                        --dump(self.__cityData,"self.__cityData",10)

                       -- dump(self.__gamesData.roomlist,"self.__gamesData.gamelist")
                        if self.loadGamesConfigCallback_ then
                            self.loadGamesConfigCallback_(true, self.__cityData)
                        end

                    else

                        if game.Bugly then
                            game.Bugly.reportLog("LoadCityControl:loadConfig_", "json.decode fail")
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
                           if self.loadGamesConfigCallback_ then
                                self.loadGamesConfigCallback_(false)
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
                       if self.loadGamesConfigCallback_ then
                            self.loadGamesConfigCallback_(false)
                        end
                    end
                end
            end, "configs")
        elseif self.isConfigLoaded_ then
             if self.loadGamesConfigCallback_ then
                self.loadGamesConfigCallback_(true, self.__cityData)
            end
        end
    end

    loadConfigFunc()

end



function LoadCityControl:cancel()
    if self.loadGamesConfigCallback_ then
        self.loadGamesConfigCallback_ = nil
    end
end

function LoadCityControl:isConfigLoaded()

	return self.isConfigLoaded_
end

function LoadCityControl:isConfigLoading()
    return self.isConfigLoading_
end


function LoadCityControl:getCitysData()
	return self.__cityData
end

function LoadCityControl:getCityByCityId(cityId)
    if not cityId then return nil end
    if not self.__cityData then return nil end

    for k,v in pairs(self.__cityData) do
        if type(v) == "table" and type(v._child) == "table" then
            for kk,vv in pairs(v._child) do
                if checkint(cityId) == checkint(vv.id) then
                    return vv
                end
            end
        end
    end

    return nil

end

--local DEFAUT_CITY = "长沙市"

function LoadCityControl:getCityByCityName(cityName)
    --if not cityName then return nil end
    if not self.__cityData then return nil end

    for k,v in pairs(self.__cityData) do
        if type(v) == "table" and type(v._child) == "table" then
            for kk,vv in pairs(v._child) do
                if (cityName) == (vv.title) then
                    return vv
                end
            end
        end
    end

    --没有找到,返回默认城市，长沙市
    -- for k,v in pairs(self.__cityData) do
    --     for kk,vv in pairs(v._child) do
    --         if (vv.title) == DEFAUT_CITY then
    --             return vv
    --         end
    --     end
    -- end

    return nil
end

function LoadCityControl:getProvinceByName(proName)
    if not self.__cityData then return nil end
    for k,v in pairs(self.__cityData) do
        if (proName) == (v.title) then
            return v
        end
    end
end

function LoadCityControl:getProvinceById(proId)
    if not self.__cityData then return nil end
    for k,v in pairs(self.__cityData) do
        if checkint(proId) == checkint(v.id) then
            return v
        end
    end
end




function LoadCityControl:preDealGamesData(data)
	-- local roomList = data.roomlist
 --    if roomList then
 --        for k,v in pairs(roomList) do
 --            local gameID = k
 --            local itemList = v
 --            for i=1,#itemList do
 --                itemList[i].gameID = gameID
 --            end

 --            table.sort(itemList,function(t1,t2)
 --                return checkint(t1.basechip) < checkint(t2.basechip)
 --            end)

 --        end
 --    end

end

function LoadCityControl:getGameByGameId(id)
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

function LoadCityControl:getGamesByGameType(ctype)
	-- if not self.__gamesData then
	-- 	return 
	-- end
	-- for _,gameType in pairs(self.__gamesData.gamelist) do
	-- 	if gameType.ctype == ctype then
	-- 		return gameType.games
	-- 	end
	-- end
end

function LoadCityControl:getRoomDatasByGameid(id)
	-- if not self.__gamesData then
	-- 	return 
	-- end
	-- for k,rooms in pairs(self.__gamesData.roomlist) do
	-- 	if tonumber(k) == tonumber(id) then
	-- 		return rooms
	-- 	end
	-- end
end


function LoadCityControl:getGameTypeByIndex(idx)
    -- if not self.__gamesData then
    --     return 
    -- end
    -- if idx < 1 or idx > #self.__gamesData.gamelist then
    --     return
    -- end
    -- return self.__gamesData.gamelist[idx]
end

function LoadCityControl:getRoomDatasByGameidAndLevel(id, level)
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



function LoadCityControl:getQuickPlayRoom(gameid,money)
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



function LoadCityControl:getSubGamelist()
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


return LoadCityControl

