local TableManager = import(".TableManager")
local GameModel = import(".model.GameModel")
local GameSocketCmd = import(".net.GameSocketCmd")
local GameSocketProcesser = import(".net.GameSocketProcesser")
local GameSocketReader = import(".net.GameSocketReader")
local GameSocketWriter = import(".net.GameSocketWriter")
local SeatManager = import(".SeatManager")
local AnimManager = import(".AnimManager")

local GameController = class("GameController",game.base.BaseController)

function GameController:ctor(scene)
	print("GameController:ctor", tostring(scene == nil))

    GameController.super.ctor(self,scene)

	self:init()
	
end


function GameController:init( ... )
	local ctx = {}
    ctx.gameController = self
    ctx.scene = self.__scene
    ctx.model = GameModel.new(ctx)

    ctx.tableManager = TableManager.new(ctx)
    ctx.seatManager = SeatManager.new(ctx)
    ctx.animManager = AnimManager.new(ctx)

    ctx.export = function(target)
        if target ~= ctx.model then
            target.ctx = ctx
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then
                    target[k] = v
                end
            end
        else
            rawset(target, "ctx", ctx)
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then
                    rawset(target, k, v)
                end
            end
        end
        return target
    end

    ctx.export(self)
    ctx.export(ctx.model)
    ctx.export(ctx.tableManager)
    ctx.export(ctx.seatManager)
    ctx.export(ctx.animManager)
end



function GameController:createNodes( ... )
	self.seatManager:createNodes(self)
    self.tableManager:createNodes(self)


    --test
    self:sendLogin()


end


function GameController:addSocketTools()
    print("GameController:addSocketTools")

    self.__socket = game.server

    GameController.super.addSocketTools(self)

    if self.__socket then
        self.__gameSocketProcesser = GameSocketProcesser.new(self)
        self.__gameSocketReader = GameSocketReader.new()
        self.__gameSocketWriter = GameSocketWriter.new()

        self.__socket:addSocketReader(self.__gameSocketReader)
        self.__socket:addSocketWriter(self.__gameSocketWriter)
        self.__socket:addSocketProcesser(self.__gameSocketProcesser)
    end


    
end


function GameController:removeSocketTools()
    GameController.super.removeSocketTools(self)
    if self.__socket then
        self.__socket:removeSocketReader(self.__gameSocketReader)
        self.__socket:removeSocketWriter(self.__gameSocketWriter)
        self.__socket:removeSocketProcesser(self.__gameSocketProcesser)
        self.__gameSocketReader = nil
        self.__gameSocketWriter = nil
        self.__gameSocketProcesser = nil
    end
end


function GameController:send2serv(cmd,info)
    if self.__socket then
         self.__socket:sendMsg(cmd,info)
    end
end


function GameController:sendLogin()
    local userinfo = game.getUserInfo()
    self:send2serv(GameSocketCmd.LOGIN_GAME,{userinfo = json.encode(userinfo)})
end

function GameController:sendHitBall(info)
    self:send2serv(GameSocketCmd.USER_HIT_BALL,info)

    --击球后隐藏倒计时
    self.seatManager:stopAllCounter()
end

function GameController:sendCueLineData(info)
    self:send2serv(GameSocketCmd.CMD_C2GAMESER_CURLINE,info)
end


function GameController:sendWhiteBallPos(info)
    self:send2serv(GameSocketCmd.CMD_C2GAMESER_BROAD_WHITEBALL,info)
end


function GameController:onBroadCueLineData(info)
    -- dump(info,"onBroadCueLineData")

    self.tableManager:onBroadCueLine(info)
end


function GameController:sendHitBallResult(info)
    local model = self.model
    local lastBallResult = model.__lastBallsResult

    print("sendHitBallResult000",json.encode(lastBallResult))
    print("sendHitBallResult111",json.encode(info))
    local newInfo = {}
    newInfo.res = {}

     print("sendHitBallResult22222",#lastBallResult,#info)
    if lastBallResult then
        if #lastBallResult > 0 then
            for i, v in ipairs(info) do
                for _, vv in ipairs(lastBallResult) do
                    if v.ballno == vv.ballno and v.res == 1  and vv.res == 2 then
                        table.insert(newInfo.res,v)
                    end
                end
            end
        else
            print("sendHitBallResult22222",#lastBallResult)
            for i, v in ipairs(info) do
                if v.res == 1 then
                    table.insert(newInfo.res,v)
                end
            end
        end  
    end
     model:onSendHitBallResult(info)

     print(json.encode(newInfo),"GameController:sendHitBallResult")
    self:send2serv(GameSocketCmd.REPORT_HIT_BALL_RESULT,newInfo)

    --上报后--更新顶部显示面板--
    self:updateSeatBallColorView()
end


function GameController:onBroadUserTurn(pack)
    local model = self.model
    model:onBroadUserTurn(pack)
    local player = model:findSeatByUid(pack.uid)
    self.tableManager:setMoveWhiteBallEnable(false,false)

    if player.isSelf then
        self.tableManager:setIsMyTure(true,checkint(pack.color))
        self.animManager:showTableTips("轮到你击球啦")
        --自己挪白球
        if pack.flag == 1 then
            --犯规
            self.tableManager:setMoveWhiteBallEnable(true,false)
        elseif pack.flag == 2 then
            --发球
            self.tableManager:setMoveWhiteBallEnable(true,true)
        end
    else
        self.tableManager:setIsMyTure(false,checkint(pack.color))
        self.animManager:hideTableTips()
         -- self.animManager:showTableTips("轮到你击球啦")
    end

    self.seatManager:startCounter(pack.uid,pack.restime)



end


function GameController:onBroadUserHitBall(pack)
    -- body
    local model = self.model
    model:onBroadUserHitBall(pack)
    dump(pack,"GameController:onBroadUserHitBall")
    self.tableManager:onBeatCueBall(pack)
    --击球后隐藏倒计时
    self.seatManager:stopAllCounter()
end


function GameController:onBroadUserColor(pack)
    local model = self.model
    model:onBroadUserColor(pack)

    self:updateSeatBallColorView()
    
end

function GameController:updateSeatBallColorView()
    local model = self.model
    local playerList = model:getPlayerList()
    if playerList then
        for _,v in pairs(playerList) do
            local ballColor = checkint(v.ballColor)
            local balls = self.tableManager:getInPlayBallsByColor(ballColor)
            
            --如果还有全色或花色球，则不显示8号球
            if #balls > 1 then
                table.removebyvalue(balls,8)
            end
            self.seatManager:setBalls(v.seatId,balls)
        end
    end
end


function GameController:onBroadWhiteBallPos(pack)
    self.tableManager:onBroadWhiteBallPos(pack)
end

function GameController:onBroadUserReady(pack)
    -- body
     local model = self.model
     model:onBroadUserReady(pack)
end

function GameController:onBroadUserLogin(pack)
    -- body
     local model = self.model
     local player = model:onBroadUserLogin(pack)
     self.seatManager:addPlayer(player)
end


function GameController:onLoginGame(pack)
     local model = self.model
    local tinfo =  model:initWithLoginSuccessPack(pack)

    dump(pack,"GameController:onLoginGame")
    self.seatManager:initSeats()
    self:reset()
end

function GameController:onGameStart(pack)
    local model = self.model
    local tinfo =  model:onGameStart(pack)
    self:reset()
end



function GameController:reset( ... )
    self.seatManager:reset()
    self.tableManager:reset()
    self.animManager:reset()

end


function GameController:dispose( ... )
    GameController.super.dispose(self)
    self.tableManager:dispose()
    self.seatManager:dispose()
    self.animManager:dispose()
end



return GameController