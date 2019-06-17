
local consts = import("..config.consts")
local SVR_GAME_STATUS = consts.SVR_GAME_STATUS
local logger = core.Logger.new("GameModel")
local GameModel = {}


function GameModel.new(...)
    local inst = {}
    local dataTb = {}
    local function get(table, key)
        return GameModel[key] or dataTb[key]
    end
    local function set(table, key, value)
        dataTb[key] = value
    end
    local function clear(self)
        local newdataTb = {}
        for k, v in pairs(dataTb) do
            if type(v) == "function" then
                newdataTb[k] = v
            end
        end
        dataTb = newdataTb
        return self
    end
    inst.clear = clear
    local mt = {__index = get, __newindex = set}
    setmetatable(inst, mt)
    if inst.ctor then
        inst:ctor(...)
    end
    return inst
end

function GameModel:ctor()
    print("GameModel:ctor")
    self.playerList = {}
    self.isSelfInGame_ = false  
    self.selfSeatId_ = -1  
end

function GameModel:isPrivateRoom()
     return (self.roomType == const.ROOM_TYPE.PRIVATE)
end
-- 获取自己的座位id
function GameModel:selfSeatId()
    return self.selfSeatId_ or -1
end

-- 获取自己
function GameModel:selfSeatData()
   return self.mySeatData_
end

--获取整个座位列表
function GameModel:getPlayerList()
    return self.playerList or {}
end

-- 是否是自己
function GameModel:isSelf(uid)

    return game.userData.mid == uid
end



 

--座位转换
--将服务器座位转化为客户端UI座位号 1-4
--转化之前，必须保证自己的服务器座位有值
function GameModel:getClientSeatNum(serverId)
    -- if self.selfSeatId_~=nil and serverId~=nil then
    print("GameModel:getClientSeatNum",serverId,self.selfSeatId_,(( serverId - self.selfSeatId_ + 2 ) % 2 + 1))
        return ( serverId - self.selfSeatId_ + 2 ) % 2 + 1
    -- end
end
--获取自己全部手牌
function GameModel:getMyHandCards()
    return self.myHandCards
end 
--克隆手牌
function GameModel:cloneHandCards()
    local result = {}
    if self.myHandCards then
        for i=1,#self.myHandCards do
            table.insert(result,self.myHandCards[i])
        end
    end
    return result
end

function GameModel:findSeatByUid(uid)
    if self.playerList~=nil then
        for k,v in pairs(self.playerList) do
            if v.userId == uid then
                return v
            end
        end
    end
end

function GameModel:findSeatBySeatId(seatId)
    if self.playerList~=nil then
        for k,v in pairs(self.playerList) do
            if v.seatId == seatId then
                return v
            end
        end
    end
end

-- 是否正在游戏
function GameModel:isSelfInGame()
    return  self.isSelfInGame_
end


function GameModel:initWithLoginSuccessPack(info)

    local tinfo = {}

    self.isSelfInGame_ = false  -- 是否在游戏中
    self.selfSeatId_ = -1

    self.__lastBallsResult = {}

    -- tinfo.lastOutCode = self.outCode_
    -- -- self.outCode_ =info.loginCode
    -- self.outCode_ = -1

    -- self.roomInfo_ = info.roomInfo

    -- self.totalRound=info.totalRound
    -- self.currentRound=info.currentRound
    -- self.creatorId=info.creatorId
    -- self.roomCode=info.roomCode
    -- self.privateStatus=info.privateStatus
    -- self.privateModes=info.privateModes

    self.playerList = {}

    for k,v in pairs(info.players) do
        local player = clone(v)
        player.isSelf = self:isSelf(player.userId)
        if player.isSelf == true then
            self.mySeatData_ = player
            -- if checkint(player.isPlay) > 0 then
            --     self.isSelfInGame_ = true
            -- end
            self.selfSeatId_ = player.seatId
        end

        player.ballColor = 0

        self.playerList[player.seatId] = player
    end
   
    return tinfo
end


function GameModel:onBroadUserReady(info)
    local player = self:findSeatByUid(info.uid)
    if player then
        player.isReady = true
    end
end

function GameModel:onBroadUserLogin(player)
    if not player then return end

    player.isSelf = self:isSelf(player.userId)
    player.ballColor = 0
    if self.playerList~=nil then
        self.playerList[player.seatId] = player
    end
     
    return player
end


function GameModel:onBroadUserColor(info)

    dump(info,"GameModel:onBroadUserColor000")
    for i,v in ipairs(info.colors) do
        local player = self:findSeatByUid(v.uid)
        player.ballColor = v.color
        print("GameModel:onBroadUserColor111",v.uid,player.ballColor)
    end
end

function GameModel:onBroadUserHitBall(info)
    
end

function GameModel:onBroadUserTurn(info)
    local player = self:findSeatByUid(info.uid)
    player.ballColor = info.color --0-任意颜色 1-单色 2-双色
    player.ballFlag = info.flag -- 0-正常打球 1-自由球

    return info
end

function GameModel:isMyTurnHitBall( ... )
    if self.turnPlayInfo_ then
        return self:isSelf(self.turnPlayInfo_.uid)
    end
    return false
end


function GameModel:onGameStart(info)
    self.isSelfInGame_ = false
    if self.selfSeatId_ > 0 then
        self.isSelfInGame_ = true
    end

    

    for _,v in pairs(self.playerList) do
        v.ballColor = 0
    end
end



function GameModel:onBroadGameOverPack(info)
    self.isSelfPlayingGame_= false
    local gameOverPlayerList = {}
    if info.userAccounts then
        for k,v in pairs(info.userAccounts) do
            local playerInfo = v
            local player = self:findSeatBySeatId(playerInfo.seatId)
            --修改变化的金币,更改状态
            if player~=nil then
                player.money=playerInfo.points  --总积分
                player.isPlay=1
                player.iswin = playerInfo.iswin
                player.currPoints = playerInfo.currPoints -- 当局积分
                player.isAi = 0
                 table.insert(gameOverPlayerList,player)
            end
        end

    end
    return gameOverPlayerList
end

--重连
function GameModel:onUserReconnect(info)
    
    dump("GameModel:onUserReconnect",info)


    for _,v in pairs(self.playerList) do
        v.ballColor = 0
    end


    self.__lastBallsResult = {}
    if info.gameStatus == SVR_GAME_STATUS.MAKE_COLOR or info.gameStatus == SVR_GAME_STATUS.HIT_BALL then
        --未开始，或者确认花色阶段未发球，则没球位置信息
        self.__lastBallsResult = (type(info.ballsInfo) == "table" and info.ballsInfo or {})

        if self.selfSeatId_ > 0 then
            self.isSelfInGame_ = true
        end

    end

    if info.colors then
        for i,v in ipairs(info.colors) do
            local player = self:findSeatByUid(v.uid)
            player.ballColor = v.color  
        end
    end
end



function GameModel:onSendHitBallResult(ballRes)
    self.__lastBallsResult = ballRes
end


function GameModel:onBroadAutoPack(info)
    if self:isSelf(info.userId) then
         self.myAutoStatus = info.status 
    end
    for k,v in pairs(self.playerList) do
        if v.seatId == info.seatId then
            v.isAi = info.status
        end
    end
   
end


--获取我的托管状态
function GameModel:getAutoStatus()
    return self.myAutoStatus or 0
end





--设置用户的重连状态
function GameModel:setUserReconnectStatus(userId, isconnect)
    if not self.__reconnectStatus then
        self.__reconnectStatus = {}
    end
    self.__reconnectStatus[userId] = isconnect
end

--检查一个用户是否是重连
function GameModel:isUserReconnect(userId)
    if not self.__reconnectStatus then
        self.__reconnectStatus  = {} 
    end
    return self.__reconnectStatus[userId]
end


--获取最大玩家数和已有玩家信息
function GameModel:getMaxNumAndCurPlayerInfo( ... )
    local maxnum = GameConfig.maxPerson or 0

    local curnum = 0
    if self.playerList then
        curnum = table.nums(self.playerList)
    end
    local playNames = {}
    if self.playerList~=nil then
        for k,v in pairs(self.playerList) do
            if v and v.userInfo and v.userInfo.name then
                table.insert(playNames,v.userInfo.name)
            end
        end
    end
   return maxnum,curnum,playNames
end



function GameModel:getInTablePlayerIds( ... )
    local ret = {}
    for _, player in pairs(self.playerList) do
        table.insert(ret, player.userId or 0)
    end
    return ret
end


return GameModel