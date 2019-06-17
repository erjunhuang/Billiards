local LoadAllRoomsControl = class("LoadAllRoomsControl")

local instance

function LoadAllRoomsControl:getInstance()
    instance = instance or LoadAllRoomsControl.new()
    return instance
end

function LoadAllRoomsControl:ctor()
    self.logger = core.Logger.new("LoadAllRoomsControl")
    self.schedulerPool_ = core.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LoadAllRoomsControl:loadConfig(url, callback,reLoad)

    --test--
    -- local testJson = [[{"10059":[{"id":"101","gameid":"10059","roomname":"\u521d\u7ea7\u573a","basechip":"600","waittime":"0","playtime":"10","num":"4","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512633219"},{"id":"102","gameid":"10059","roomname":"\u4e2d\u7ea7\u573a","basechip":"3000","waittime":"0","playtime":"10","num":"4","fee":"1000","minin":"30000","maxin":"-1","quickin":"30000","dealerfee":"0","flag":"0","time":"1512633246"},{"id":"103","gameid":"10059","roomname":"\u9ad8\u7ea7\u573a","basechip":"10000","waittime":"0","playtime":"10","num":"4","fee":"3000","minin":"100000","maxin":"-1","quickin":"100000","dealerfee":"0","flag":"0","time":"1512633287"}],"10051":[{"id":"101","gameid":"10051","roomname":"\u521d\u7ea7\u573a","basechip":"600","waittime":"0","playtime":"10","num":"4","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512633326"},{"id":"102","gameid":"10051","roomname":"\u4e2d\u7ea7\u573a","basechip":"3000","waittime":"0","playtime":"10","num":"4","fee":"1000","minin":"30000","maxin":"-1","quickin":"30000","dealerfee":"0","flag":"0","time":"1512633365"},{"id":"103","gameid":"10051","roomname":"\u9ad8\u7ea7\u573a","basechip":"10000","waittime":"0","playtime":"10","num":"4","fee":"3000","minin":"100000","maxin":"-1","quickin":"100000","dealerfee":"0","flag":"0","time":"1512633391"}],"10064":[{"id":"101","gameid":"10064","roomname":"\u521d\u7ea7\u573a","basechip":"300","waittime":"0","playtime":"10","num":"3","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512632072"},{"id":"102","gameid":"10064","roomname":"\u4e2d\u7ea7\u573a","basechip":"1500","waittime":"0","playtime":"10","num":"3","fee":"1000","minin":"30000","maxin":"-1","quickin":"30000","dealerfee":"0","flag":"0","time":"1512633071"},{"id":"103","gameid":"10064","roomname":"\u9ad8\u7ea7\u573a","basechip":"5000","waittime":"0","playtime":"10","num":"3","fee":"3000","minin":"100000","maxin":"-1","quickin":"100000","dealerfee":"0","flag":"0","time":"1512632106"}],"10058":[{"id":"101","gameid":"10058","roomname":"\u521d\u7ea7\u573a","basechip":"800","waittime":"0","playtime":"10","num":"4","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512633441"},{"id":"102","gameid":"10058","roomname":"\u4e2d\u7ea7\u573a","basechip":"4000","waittime":"0","playtime":"10","num":"4","fee":"1000","minin":"30000","maxin":"-1","quickin":"30000","dealerfee":"0","flag":"0","time":"1512633463"},{"id":"103","gameid":"10058","roomname":"\u9ad8\u7ea7\u573a","basechip":"20000","waittime":"0","playtime":"10","num":"4","fee":"3000","minin":"100000","maxin":"-1","quickin":"100000","dealerfee":"0","flag":"0","time":"1512633507"}],"10060":[{"id":"101","gameid":"10060","roomname":"\u521d\u7ea7\u573a","basechip":"800","waittime":"0","playtime":"10","num":"3","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512631985"},{"id":"102","gameid":"10060","roomname":"\u4e2d\u7ea7\u573a","basechip":"4000","waittime":"0","playtime":"10","num":"3","fee":"1000","minin":"30000","maxin":"-1","quickin":"30000","dealerfee":"0","flag":"0","time":"1512633012"},{"id":"103","gameid":"10060","roomname":"\u9ad8\u7ea7\u573a","basechip":"20000","waittime":"0","playtime":"10","num":"3","fee":"3000","minin":"100000","maxin":"-1","quickin":"100000","dealerfee":"0","flag":"0","time":"1512632035"}],"10052":[{"id":"101","gameid":"10052","roomname":"\u521d\u7ea7\u573a","basechip":"200","waittime":"0","playtime":"10","num":"3","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512631764"},{"id":"102","gameid":"10052","roomname":"\u4e2d\u7ea7\u573a","basechip":"1500","waittime":"0","playtime":"10","num":"3","fee":"1000","minin":"30000","maxin":"-1","quickin":"30000","dealerfee":"0","flag":"0","time":"1512631830"},{"id":"103","gameid":"10052","roomname":"\u9ad8\u7ea7\u573a","basechip":"5000","waittime":"0","playtime":"10","num":"3","fee":"3000","minin":"100000","maxin":"-1","quickin":"100000","dealerfee":"0","flag":"0","time":"1512631897"}],"10063":[{"id":"101","gameid":"10063","roomname":"\u521d\u7ea7\u573a","basechip":"300","waittime":"0","playtime":"10","num":"3","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512632145"},{"id":"102","gameid":"10063","roomname":"\u4e2d\u7ea7\u573a","basechip":"1500","waittime":"0","playtime":"10","num":"3","fee":"1000","minin":"30000","maxin":"-1","quickin":"30000","dealerfee":"0","flag":"0","time":"1512632266"},{"id":"103","gameid":"10063","roomname":"\u9ad8\u7ea7\u573a","basechip":"5000","waittime":"0","playtime":"10","num":"3","fee":"3000","minin":"100000","maxin":"-1","quickin":"100000","dealerfee":"0","flag":"0","time":"1512632303"}],"10057":[{"id":"101","gameid":"10057","roomname":"\u521d\u7ea7\u573a","basechip":"600","waittime":"0","playtime":"10","num":"4","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512633542"},{"id":"102","gameid":"10057","roomname":"\u4e2d\u7ea7\u573a","basechip":"3000","waittime":"0","playtime":"10","num":"4","fee":"1000","minin":"30000","maxin":"-1","quickin":"30000","dealerfee":"0","flag":"0","time":"1512633570"},{"id":"103","gameid":"10057","roomname":"\u9ad8\u7ea7\u573a","basechip":"10000","waittime":"0","playtime":"10","num":"4","fee":"3000","minin":"100000","maxin":"-1","quickin":"100000","dealerfee":"0","flag":"0","time":"1512633590"}]}]]
    -- local testData = json.decode(testJson)
    -- self:preDealRoomsData(testData)
    -- self.__roomsData = testData
    -- self.isConfigLoaded_ = true
    -- self.isConfigLoading_ = false
    -- if callback then
    --     callback(true,testData)
    -- end

    -- do return end
    if self.url_ ~= url or reLoad then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadRoomsConfigCallback_ = callback
    self:loadConfig_()
end


function LoadAllRoomsControl:loadConfig_()

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

                        self:preDealRoomsData(tempDatas)
                        self.__roomsData = tempDatas
                        -- dump(self.__roomsData,"self.__roomsData",10)

                       -- dump(self.__roomsData.roomlist,"self.__roomsData.gamelist")
                        if self.loadRoomsConfigCallback_ then
                            self.loadRoomsConfigCallback_(true, self.__roomsData)
                        end

                    else
                        if game.Bugly then
                            game.Bugly.reportLog("LoadAllRoomsControl:loadConfig_", "json.decode fail")
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
                           if self.loadRoomsConfigCallback_ then
                                self.loadRoomsConfigCallback_(false)
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
                       if self.loadRoomsConfigCallback_ then
                            self.loadRoomsConfigCallback_(false)
                        end
                    end
                end
            end, "configs")
        elseif self.isConfigLoaded_ then
             if self.loadRoomsConfigCallback_ then
                self.loadRoomsConfigCallback_(true, self.__roomsData)
            end
        end
    end

    loadConfigFunc()

end



function LoadAllRoomsControl:cancel()
    if self.loadRoomsConfigCallback_ then
        self.loadRoomsConfigCallback_ = nil
    end
end

function LoadAllRoomsControl:isConfigLoaded()

	return self.isConfigLoaded_
end

function LoadAllRoomsControl:isConfigLoading()
    return self.isConfigLoading_
end


function LoadAllRoomsControl:getRoomsData()
	return self.__roomsData
end
-- [LUA-print] -         "app_id"      = "10"

-- [LUA-print] -         "basechip"    = "3000"

-- [LUA-print] -         "dealer_fee"  = "0"

-- [LUA-print] -         "fee"         = "1000"

-- [LUA-print] -         "flag"        = "0"

-- [LUA-print] -         "game_id"     = "10051"

-- [LUA-print] -         "id"          = "3"

-- [LUA-print] -         "max_in"      = "0"

-- [LUA-print] -         "min_in"      = "30000"

-- [LUA-print] -         "num"         = "4"

-- [LUA-print] -         "operator"    = "vanfohuang"

-- [LUA-print] -         "play_time"   = "10"

-- [LUA-print] -         "quick_in"    = "30000"

-- [LUA-print] -         "room_name"   = "中级场"

-- [LUA-print] -         "scene_id"    = "102"

-- [LUA-print] -         "status"      = "1"

-- [LUA-print] -         "update_time" = "1515230343"

-- [LUA-print] -         "wait_time"   = "0"

-- "id":"101","gameid":"10059","roomname":"\u521d\u7ea7\u573a","basechip":"600","waittime":"0","playtime":"10","num":"4","fee":"200","minin":"1000","maxin":"-1","quickin":"1000","dealerfee":"0","flag":"0","time":"1512633219"

function LoadAllRoomsControl:preDealRoomsData(roomList)
    if roomList then
        for k,v in pairs(roomList) do
            local gameID = k
            table.sort(v,function(t1,t2)
                return checkint(t1.basechip) < checkint(t2.basechip)
            end)

        end
        --客户端之前引用的变量跟新配置不太一样，来个转换大法
        for k,v in pairs(roomList) do
            for kk,vv in pairs(v) do
                vv.gameid       = vv.game_id
                vv.id           = vv.scene_id
                vv.roomname     = vv.room_name
                vv.waittime     = vv.wait_time
                vv.playtime     = vv.play_time
                vv.minin        = vv.min_in
                vv.maxin        = vv.max_in
                vv.quickin      = vv.quick_in
                vv.dealerfee    = vv.dealer_fee
                vv.time         = vv.update_time 
            end
        end
    end
    
end

function LoadAllRoomsControl:getRoomDatasByGameid(id)
	if not self.__roomsData then
		return 
	end
	for k,rooms in pairs(self.__roomsData) do
		if tonumber(k) == tonumber(id) then
			return rooms
		end
	end
end

function LoadAllRoomsControl:getRoomDatasByGameidAndLevel(id, level)
    if not self.__roomsData then
        return nil
    end
    for k,rooms in pairs(self.__roomsData) do
        if tonumber(k) == tonumber(id) then
            for i, room in ipairs(rooms) do
                if tonumber(room.id) == tonumber(level) then
                    return room
                end
            end
        end
    end
    return nil
end


function LoadAllRoomsControl:getRoomDatasByLevel(level)
    if not self.__roomsData then
        return nil
    end

    local tb = {}
    for k,rooms in pairs(self.__roomsData) do
        -- if tonumber(k) == tonumber(id) then
            for i, room in ipairs(rooms) do
                if tonumber(room.id) == tonumber(level) then
                    table.insert(tb,room)
                end
            end
        -- end
    end
    return tb
end




function LoadAllRoomsControl:getQuickPlayRoom(gameid,money)
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

return LoadAllRoomsControl

