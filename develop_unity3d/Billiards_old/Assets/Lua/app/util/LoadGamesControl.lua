local LoadGamesControl = class("LoadGamesControl")

local instance

function LoadGamesControl:getInstance()
    instance = instance or LoadGamesControl.new()
    return instance
end

function LoadGamesControl:ctor()
    self.logger = core.Logger.new("LoadGamesControl")
    self.schedulerPool_ = core.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end



function LoadGamesControl:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadGamesConfigCallback_ = callback
    self:loadConfig_()
end


function LoadGamesControl:loadConfig_()

    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            core.cacheFile(self.url_ or "", function(result, content,filePath)
                self.isConfigLoading_ = false
                if result == "success" then
                    
                    -- dump(content,"content====")

                    local tempDatas = json.decode(content)
                    if tempDatas then
                        self.isConfigLoaded_ = true
                        self.isConfigLoading_ = false

                        self:preDealGamesData(tempDatas)
                        self.__gamesData = tempDatas
                        -- dump(self.__gamesData,"self.__gamesData",10)

                       -- dump(self.__gamesData.roomlist,"self.__gamesData.gamelist")
                        if self.loadGamesConfigCallback_ then
                            self.loadGamesConfigCallback_(true, self.__gamesData)
                        end

                    else

                        if game.Bugly then
                            game.Bugly.reportLog("LoadGamesControl:loadConfig_", "json.decode fail")
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
                self.loadGamesConfigCallback_(true, self.__gamesData)
            end
        end
    end

    loadConfigFunc()

end



function LoadGamesControl:cancel()
    if self.loadGamesConfigCallback_ then
        self.loadGamesConfigCallback_ = nil
    end
end

function LoadGamesControl:isConfigLoaded()

	return self.isConfigLoaded_
end

function LoadGamesControl:isConfigLoading()
    return self.isConfigLoading_
end


function LoadGamesControl:getGamesData()
	return self.__gamesData
end








function LoadGamesControl:preDealGamesData(data)
	local roomList = data.roomlist
    if roomList then
        for k,v in pairs(roomList) do
            local gameID = k
            local itemList = v
            for i=1,#itemList do
                itemList[i].gameID = gameID
            end

            table.sort(itemList,function(t1,t2)
                return checkint(t1.basechip) < checkint(t2.basechip)
            end)

        end
    end

end

function LoadGamesControl:getGameByGameId(id)
    if not self.__gamesData then
        return 
    end
    for _,gameType in pairs(self.__gamesData.gamelist) do
        for __,game in pairs(gameType.games) do
            if tonumber(game.id) == tonumber(id) then
                return game
            end
        end
        
    end
end

function LoadGamesControl:getGamesByGameType(ctype)
	if not self.__gamesData then
		return 
	end
	for _,gameType in pairs(self.__gamesData.gamelist) do
		if gameType.ctype == ctype then
			return gameType.games
		end
	end
end

function LoadGamesControl:getRoomDatasByGameid(id)
	if not self.__gamesData then
		return 
	end
	for k,rooms in pairs(self.__gamesData.roomlist) do
		if tonumber(k) == tonumber(id) then
			return rooms
		end
	end
end


function LoadGamesControl:getGameTypeByIndex(idx)
    if not self.__gamesData then
        return 
    end
    if idx < 1 or idx > #self.__gamesData.gamelist then
        return
    end
    return self.__gamesData.gamelist[idx]
end

function LoadGamesControl:getRoomDatasByGameidAndLevel(id, level)
    if not self.__gamesData then
        return 
    end
    for k,rooms in pairs(self.__gamesData.roomlist) do
        if tonumber(k) == tonumber(id) then
            for i, room in ipairs(rooms) do
                if tonumber(room.id) == tonumber(level) then
                    return room
                end
            end
        end
    end
end



function LoadGamesControl:getQuickPlayRoom(gameid,money)
    local rooms = self:getRoomDatasByGameid(gameid)
    local fdata
    -- for _,v in ipairs(rooms) do
    --     if money <= checkint(v.maxin) then
    --         fdata = v
    --         break
    --     end
    -- end

    if not rooms then
        return 
    end

    for _,v in ipairs(rooms) do
        if money >= checkint(v.minin) then
            fdata = v
            break
        end
    end

    if not fdata then
        fdata = rooms[#rooms]
    end

    return fdata
end



function LoadGamesControl:getSubGamelist()
    if not self.__gamesData then
        return 
    end

    local subGames = {}

    for _,gameType in pairs(self.__gamesData.gamelist) do
        for __,game in pairs(gameType.games) do
            table.insert(subGames,game)
        end
        
    end

    return subGames
end


return LoadGamesControl

