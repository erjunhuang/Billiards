
local scheduler = require("misc.scheduler")
local PowerSlider = import(".views.PowerSlider")
local BilliardsConfig = import(".config.BilliardsConfig")
local BilliardsBallData = import(".model.BilliardsBallData")
local BilliardsTableData = import(".model.BilliardsTableData")
local LuaCollisionEngine = import(".collision.LuaCollisionEngine")
local LuaCueViewController = import(".views.LuaCueViewController")

local LuaNumber2D = import(".math.LuaNumber2D")
local LuaRectangle = import(".math.LuaRectangle")
local LuaLogicalBall = import(".views.LuaLogicalBall")
local BallBagView = import(".views.BallBagView")

local SetBallView = import(".views.SetBallView")


local MoveWhiteBallView = import(".views.MoveWhiteBallView")

local Vector3 = CS.UnityEngine.Vector3
local DateTime = CS.System.DateTime
local DOTween = CS.DG.Tweening.DOTween

local TableManager = class("TableManager")

function TableManager:ctor(ctx)
    local scene = ctx.scene

    self.__billiardsConfig = BilliardsConfig
    self.__billiardsBallData = BilliardsBallData.new(self)
    self.__billiardsTableData = BilliardsTableData.new(self)

	self._ballMaskBitmap = scene._ballMaskBitmap
	self._ballNumberBitmap = scene._ballNumberBitmap
	self._ballShadowBitmap = scene._ballShadowBitmap
	self._hightLigthBitmap = scene._hightLigthBitmap

	self.leftTop = scene.leftTop
	self.rightTop = scene.rightTop
	self.leftBottom = scene.leftBottom
	self.rightBottom = scene.rightBottom
	self.ballLayer = scene.ballLayer
	self.cueView = scene.cueView
	self.cuelinePre = scene.cuelinePre

    self.__tableTipView = scene.tableTipView
    self.__setBallView = SetBallView.new(ctx,scene.setBallView)

    self.__ballBag = BallBagView.new(ctx, scene.ballBag)



    self.__cueAngleBtn = scene.cueAngleBtn

    self.__cueAngleBtn:GetComponent("Button").onClick:AddListener(handler(self,self.onShowSetBallView))

    self.__moveWhiteBallView = MoveWhiteBallView.new(ctx,scene.handView)
    self.__moveWhiteBallView:onCallback(handler(self,self.onMoveWhiteBallCallback))

    self.__powerSlider = PowerSlider.new(scene.powerSlider)
    self.__powerSlider:setOnValueChangedCallback(handler(self,self.onPowerSliderChange))
    self.__powerSlider:setOnPointerUpCallback(handler(self,self.onPowerSliderPointerUp))
    self.__powerSlider:setOnPointerDownCallback(handler(self,self.onPowerSliderPointerDown))

    self.__ballLayerTransform = self.ballLayer:GetComponent(typeof(Transform))

    self.__velocity = LuaNumber2D.new(0, 0)
    --- 优化到Lua层
    self.__tableRect = LuaRectangle.new(table.unpack(self.__billiardsConfig.TABLE_RECT))
    self.__isMouseDown = false
    --发球区域
    self.__tableBreadRect = LuaRectangle.new(table.unpack(self.__billiardsConfig.TABLE_BREAK_RECT))

    -- self:initTable()

    nb.bind(self,"touch")
    self:addTouchListener(handler(self,self.onTouch))

    self.__isLuaCollisionEngineRunning = false

    -- --test--

    cs_coroutine.start(function()
        self.__billiardsBallData:loadTextures()
        self.__billiardsBallData:initColorDatas()

        self.__billiardsTableData:initVertices(self.__billiardsConfig.TABLE_POINTS)
        self.__billiardsTableData:initPocketPoints(self.__billiardsConfig.POCKET_POS)
        self.__billiardsTableData:initBalls(self.__ballLayerTransform)

        self:setupLuaCollisionEngine()
        self:setupLuaBallsPosition()
        self:setupLuaViews()
        self:initLuaTable()

        self:startLuaLogicUpdateLoop()
    end)

    self.__broadCueLineVec3 = Vector3(0,0,0)
end


function TableManager:initLuaTable( ... )
    self:setCueEnable(false,false,false)
    self:callGameControllerFunc("sendLogin")
end


function TableManager:setupLuaBallsPositionByBallsInfo(ballsInfo)
    
    
    for _,v in ipairs( ballInfo) do
        if v.ballno == 0 then
            local cueBall = self.__billiardsTableData.__cueBall
            cueBall.__position:reset(v.wx, v.wy)
            cueBall:stopMovingAndSpinning()
            cueBall:setState(cueBall.STATE.IN_PLAY)
            cueBall:updateVisualBall()

        else
            local nonCueLogicalBallTable = self.__billiardsTableData.__nonCueLogicalBallTable
            for index, ball in ipairs(nonCueLogicalBallTable) do
                if v.res == 2 then
                    if ball.__num == v.ballno then
                        ball.__position:reset(v.wx, v.wy)
                        ball.__w.x = 100 * math.random()
                        ball.__w.y = 100 * math.random()
                        ball.__w.z = 100 * math.random()
                        ball:rotate()
                        ball:stopMovingAndSpinning()
                        ball:setState(ball.STATE.IN_PLAY)
                        ball:updateVisualBall()
                    end  


                elseif v.res == 1 then
                    if ball.__num == v.ballno then
                        -- ball.__position:reset(v.wx, v.wy)
                        -- ball.__w.x = 100 * math.random()
                        -- ball.__w.y = 100 * math.random()
                        -- ball.__w.z = 100 * math.random()
                        ball:rotate()
                        ball:stopMovingAndSpinning()
                        ball:setState(ball.STATE.DROP_INTO_POCKET)
                        -- ball:updateVisualBall()
                        self:playBallRollInPocketAnim(ball)
                    end  

                end
 
            end

        end

    end

    
end





function TableManager:onShowSetBallView( ... )
    self.__setBallView:showView()
end

function TableManager:setMoveWhiteBallEnable(enable,isBreak)
    print("TableManager:setMoveWhiteBallEnable",enable,isBreak)
     self.__moveWhiteBallView:setEnabled(enable,self.__billiardsTableData.__cueBall,isBreak)
end

function TableManager:setCueEnable(enable,touchable,needLine,flag)
    -- print("TableManager:setCueEnable",enable,touchable,needLine,flag)
    enable = enable or false
    touchable = touchable or false
    self:setTouchEnabled(touchable)
    if enable then
        self.__luaCueViewController:showAll()
    else
        self.__luaCueViewController:hideAll()
    end

    if needLine then
        self.__luaCueViewController:showLine()
        if flag then
            local nextBall = self:findFirstBallInPlayByFlag(flag)
            if nextBall then
                local nextBallPosX, nextBallPosY = self.__billiardsTableData:screenToLogic(nextBall.__position.x,nextBall.__position.y)
                self.__luaCueViewController:updateAim(checknumber(nextBallPosX),checknumber(nextBallPosY), self.__billiardsTableData.__cueBall, self.__billiardsTableData.__allLogicalBallTable) 
            else
                 self.__luaCueViewController:updateAim(0, 0, self.__billiardsTableData.__cueBall, self.__billiardsTableData.__allLogicalBallTable)

            end
        end
    else
        self.__luaCueViewController:hideLine()
    end
end

-- 1:全色 2：花色 3：所有
function TableManager:findFirstBallInPlayByFlag(color)
    local ballGroup
    if color == 1 then
        ballGroup = {1,2,3,4,5,6,7,8}

    elseif color == 2 then
        ballGroup = {9,10,11,12,13,14,15,8}
    else 
        ballGroup = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    end

    local allLogicalBallTable = self.__billiardsTableData.__allLogicalBallTable
    local len = #allLogicalBallTable;-- int

    local ball; -- LogicalBall
    local index = 1;-- int
    while (index <= len) do
        ball = allLogicalBallTable[index];
        if table.indexof(ballGroup,ball.__num) then
            return ball
        end
        index = index + 1;
    end

    return ball
end



function TableManager:getInPlayBallsByColor(color)
    -- print("TableManager:getInPlayBallsByColor000",color)
    local ballGroup
    if color == 1 then
        ballGroup = {1,2,3,4,5,6,7,8}
    elseif color == 2 then
        ballGroup = {9,10,11,12,13,14,15,8}
    else 
        ballGroup = {}
    end

    local allLogicalBallTable = self.__billiardsTableData.__allLogicalBallTable
    local len = #allLogicalBallTable
    local outBalls = {}
    local ball; -- LogicalBall
    local index = 1;-- int

    while (index <= len) do
        ball = allLogicalBallTable[index];
        if (ball.__state == LuaLogicalBall.STATE.IN_PLAY) then
            if table.indexof(ballGroup,ball.__num) then
                table.insert(outBalls,ball.__num)
            end
        end
        index = index + 1;
    end

    return outBalls
end

function TableManager:initGameInfo(isSelfInGame)
    self.isSelfInGame_ = isSelfInGame
end

function TableManager:reset()
    -- self.isSelfInGame_ = false
    self:setCueEnable(false,false,false)
    self:setMoveWhiteBallEnable(false,false)
    self.__powerSlider:setEnabled(false)
    self.__ballBag:reset()
end

--[[
    在玩：1、轮到自己击球，

    观战: 1、不监听触摸事件，有击球数据就启动
--]]

function TableManager:onMoveWhiteBallCallback(touchPhase,touchPosition)
    if touchPhase == "Began" then
        --隐藏杆和瞄准线

    elseif touchPhase == "Ended" then
        --显示杆和瞄准线

        local cueBall = self.__billiardsTableData.__cueBall
        if cueBall then
            local info = {}
            info.wx = cueBall.__position.x
            info.wy = cueBall.__position.y
            info.wz = cueBall.__position.z
            self:callGameControllerFunc("sendWhiteBallPos",info)
        end
    end
end

function TableManager:onPowerSliderChange(value)
    -- print("TableManager:onPowerSliderChange => ", value)

    self.__luaCueViewController:doBeatPowerAction(value, self.__billiardsTableData.__cueBall)
end

function TableManager:onPowerSliderPointerUp(pointerEventData)
    local value = self.__powerSlider:getCurrentValue()
    -- print("TableManager:onPowerSliderPointerUp => ", pointerEventData, "value => ", value)
    if value > 0 then
        -- TODO: 把球打出去
        local currentVelocity = self.__luaCueViewController:getLogicVelocity()

        -- currentVelocity:CopyTo(self.__velocity)
        self.__velocity:reset(currentVelocity.x, currentVelocity.y)
        -- self.__velocity:Normalise()
        self:BeatCueBall(value*200)
        self.__luaTime = 0;
        self:changeLuaCollisionEngineRunState(true);
        self:setCueEnable(false,false,false)
    else
        -- self:resetCueLocalPosition()
    end
end

function TableManager:onPowerSliderPointerDown(pointerEventData)
    -- print("TableManager:onPowerSliderPointerDown => ", pointerEventData)
end


function TableManager:onTouch(touchPhase,position,touchType)
    -- print("SimpleTouch",touchPhase,position,touchType)
    if touchPhase == "Began" then
        self:onMouseDown(position)
    elseif touchPhase == "Moved" then
        self:onMouseMove(position)
    elseif touchPhase == "Ended" then
        self:onMouseUp(position)
    end
end

function TableManager:onMouseMove(touchPosition)
    local logicCoordX, logicCoordY = self:getLogicPositionByTouchPosition(touchPosition)
    if self.__tableRect:containsPoint(logicCoordX, logicCoordY) then
        if self.__isMouseDown then
            self:updateCueViewLine(touchPosition)
            self:sendCueLineData(touchPosition)
        end
    end
end


function TableManager:onMouseDown(touchPosition)
    local logicCoordX, logicCoordY = self:getLogicPositionByTouchPosition(touchPosition)
    if self.__tableRect:containsPoint(logicCoordX, logicCoordY) then
        self.__isMouseDown = true
        self:updateCueViewLine(touchPosition)
        self:sendCueLineData(touchPosition)
    end
end


function TableManager:onMouseUp(touchPosition)
    self.__isMouseDown = false
    local logicCoordX, logicCoordY = self:getLogicPositionByTouchPosition(touchPosition)
    if self.__tableRect:containsPoint(logicCoordX, logicCoordY) then
        self:sendCueLineData(touchPosition)
    end
    
end

function TableManager:onBroadWhiteBallPos(info)

     local cueBall = self.__billiardsTableData.__cueBall
        -- cueBall.__position:reset(self.__billiardsConfig.CUE_BALL_POS[1], self.__billiardsConfig.CUE_BALL_POS[2])
    if cueBall then
        cueBall.__position.x = info.wx
        cueBall.__position.y = info.wy
        cueBall.__position.z = info.wz
        cueBall:updateVisualBall()
    end
end



function TableManager:onBroadCueLine(touchWorldPosition)
    -- local worldPos = Camera.main:ScreenToWorldPoint(touchPosition);--Vector3
    -- if not self.__cueLineDataTb then
    --     self.__cueLineDataTb = {}
    -- end

    -- table.insert(self.__cueLineDataTb,touchWorldPosition)


    -- if not self.__cueAnimHandle and #self.__cueLineDataTb > 0 then
    --    self.__cueAnimHandle = scheduler.scheduleUpdateGlobal(function()

    --         if #self.__cueLineDataTb <= 0 then
    --             if self.__cueAnimHandle then
    --                 scheduler.unscheduleGlobal(self.__cueAnimHandle)
    --                 self.__cueAnimHandle = nil
    --             end
    --         else
    --             local tdata = table.remove(self.__cueLineDataTb,1)
                self:showCueLineByUpdate(touchWorldPosition)
    --         end
            
    --     end,{})
    -- end
end


function TableManager:setIsMyTure(myTurn,color)
    if myTurn then
        self:setCueEnable(true,true,true,checkint(color))
        self.__powerSlider:setEnabled(true)
    else
         self:setCueEnable(true,false,true,checkint(color))
         self.__powerSlider:setEnabled(false)
    end
end


function TableManager:showCueLineByUpdate(touchWorldPosition)
    self.__broadCueLineVec3.x = touchWorldPosition.wx
    self.__broadCueLineVec3.y = touchWorldPosition.wy
    self.__broadCueLineVec3.z = touchWorldPosition.wz
    local localPos = self.__ballLayerTransform:InverseTransformPoint(self.__broadCueLineVec3);--Vector3

    self.__luaCueViewController:updateAim(localPos.x, localPos.y, self.__billiardsTableData.__cueBall, self.__billiardsTableData.__allLogicalBallTable)

end



function TableManager:sendCueLineData(touchPosition)

    local worldPos = Camera.main:ScreenToWorldPoint(touchPosition);--Vector3
    local info = {}
    info.wx = (worldPos.x or 0)
    info.wy = (worldPos.y or 0)
    info.wz = (worldPos.z or 0)

    self:callGameControllerFunc("sendCueLineData",info)
end



function TableManager:callGameControllerFunc(funcName,...)
    if self.gameController and type(self.gameController[funcName]) == "function" then
        self.gameController[funcName](self.gameController,...)
    end
end

function TableManager:reportBallResult()
    local balltb = {}
    local ball; -- LogicalBall
    local index = 1;-- int

    local allLogicalBallTable = self.__billiardsTableData.__allLogicalBallTable
    local len = #allLogicalBallTable

    while (index <= len) do
        ball = allLogicalBallTable[index];
        local ballInfo = {}
        ballInfo.ballno = checknumber(ball.__num)
        ballInfo.wx = checknumber(ball.__position.x)
        ballInfo.wy = checknumber(ball.__position.y)
        ballInfo.res = (ball:isDropIntoPocket()) and 1 or 2
        table.insert(balltb,ballInfo)
        index = index + 1;
    end

     self:callGameControllerFunc("sendHitBallResult",balltb)

end


function TableManager:updateCueViewLine(touchPosition)
    local localPos = self:getLocalPositionByTouchPosition(touchPosition)
    self.__luaCueViewController:updateAim(localPos.x, localPos.y, self.__billiardsTableData.__cueBall, self.__billiardsTableData.__allLogicalBallTable)
end

function TableManager:getLogicPositionByTouchPosition(touchPosition)
    local worldPos = Camera.main:ScreenToWorldPoint(touchPosition);--Vector3
    local localPos = self.__ballLayerTransform:InverseTransformPoint(worldPos);--Vector3
    local logicCoordX, logicCoordY = self.__billiardsTableData:screenToLogic(localPos.x, localPos.y)
    return logicCoordX, logicCoordY
end

function TableManager:getLocalPositionByTouchPosition(touchPosition)

    -- print("TableManager:getLocalPositionByTouchPosition")
    local worldPos = Camera.main:ScreenToWorldPoint(touchPosition);--Vector3
    local localPos = self.__ballLayerTransform:InverseTransformPoint(worldPos);--Vector3
    return localPos
end

function TableManager:BeatCueBall(startVelocity)
	--double x, double y, double startVelocity
    -- self.__guideBall.velocity:Normalise();

    -- print("TableManager:BeatCueBall self.__velocity => x =", self.__velocity.x, ", y =", self.__velocity.y, "startVelocity =", startVelocity)


    local cueBall = self.__billiardsTableData.__cueBall

    local beatRadian = 0; -- double
    self.__velocity:normalize()
    cueBall.__velocity:reset(self.__velocity.x, self.__velocity.y)
    
    local force = startVelocity -- double
    local forwardForce = force * math.cos(beatRadian) -- double

    local downForce = force * math.sin(beatRadian)

    cueBall.__velocity:multiply(forwardForce * self.__billiardsConfig.START_VELOCITY)

    local angle = LuaNumber2D.new()                    -- 获取击球位置
    local wx = -(self.__velocity.y) * angle.y * force + self.__velocity.x * downForce * angle.x;
    local wy = self.__velocity.x * angle.y * force + self.__velocity.y * downForce * angle.x;
    local wz = -forwardForce * angle.x * 2;
    local vx = cueBall.__velocity.x
    local vy = cueBall.__velocity.y

    cueBall.__w.x = wx
    cueBall.__w.y = wy
    cueBall.__w.z = wz
    cueBall:setState(cueBall.STATE.IN_PLAY)

    local info = {}
    info.wx = wx
    info.wy = wy
    info.wz = wz
    info.vx = vx
    info.vy = vy
    self:callGameControllerFunc("sendHitBall",info)

end

function TableManager:onBeatCueBall(info)
    -- body

    local wx = checknumber(info.wx)
    local wy = checknumber(info.wy)
    local wz = checknumber(info.wz)
    local vx = checknumber(info.vx)
    local vy = checknumber(info.vy)

    local cueBall = self.__billiardsTableData.__cueBall

    if cueBall then

        dump(info,"onBeatCueBall")
        cueBall.__w:reset(wx,wy,wz)
        cueBall:setState(cueBall.STATE.IN_PLAY)
        cueBall.__velocity:reset(vx,vy)
        self.__luaTime = 0
        self:changeLuaCollisionEngineRunState(true)
    end

    self:setCueEnable(false,false,false)
end

--- 进洞隐藏球
function TableManager:hideVisualBall(logicBall)
    if logicBall and logicBall.__visualBall then
        local visualBall = logicBall.__visualBall
        visualBall.__ballView:SetActive(false)
        visualBall.__shadowView:SetActive(false)
        visualBall.__highLightView:SetActive(false)
        logicBall.__needRender = false;
    end
end

function TableManager:createNodes( ... )
	-- body
end


function TableManager:showTableTips(str)
    if self.__tableTipView then
        str = str or ""
        local tipTxt = self.__tableTipView.transform:Find("tipTxt")
        tipTxt.text = str
    end
end

function TableManager:dispose( ... )
    self:removeTouchListener(true)
end


-------------------------------------------------Lua实现start------------------------------------------
--- 设置lua球的起始位置
function TableManager:getBilliardsConfig()
    return self.__billiardsConfig
end

function TableManager:getBilliardsBallData()
    return self.__billiardsBallData
end

function TableManager:getBilliardsTableData()
    return self.__billiardsTableData
end

function TableManager:getLuaCollisionEngine()
    return self.__luaCollisionEngine
end

function TableManager:setupLuaBallsPosition()
    local cueBall = self.__billiardsTableData.__cueBall
    cueBall.__position:reset(self.__billiardsConfig.CUE_BALL_POS[1], self.__billiardsConfig.CUE_BALL_POS[2])
    cueBall:stopMovingAndSpinning()
    cueBall:setState(cueBall.STATE.IN_PLAY)
    cueBall:updateVisualBall()

    local nonCueLogicalBallTable = self.__billiardsTableData.__nonCueLogicalBallTable
    for index, ball in ipairs(nonCueLogicalBallTable) do
        local pos = self.__billiardsConfig.NON_CUE_BALL_POSITIONS[index] -- Lua索引
        ball.__position:reset(pos[1], pos[2])

        ball.__w.x = 100 * math.random()
        ball.__w.y = 100 * math.random()
        ball.__w.z = 100 * math.random()

        ball:rotate()
        ball:stopMovingAndSpinning()
        ball:setState(ball.STATE.IN_PLAY)
        ball:updateVisualBall()
    end
end

--- 设置Lua实现的物理引擎
function TableManager:setupLuaCollisionEngine()
    self.__luaCollisionEngine = LuaCollisionEngine.new(self)
    self.__luaCollisionEngine:initWithLuaType(self.__tableRect,
        self.__billiardsTableData.__allLogicalBallTable,
        self.__billiardsTableData.__pocketPointsTable,
        self.__billiardsTableData.__verticesTable
    )
end

function TableManager:setupLuaViews()
    self.__luaCueViewController = LuaCueViewController.new(self, self.cuelinePre, self.cueView)
end

function TableManager:startLuaLogicUpdateLoop()
    self:stopLuaLogicUpdateLoop()
    self.__luaLogicUpdateSchedulerHandler = scheduler.scheduleUpdateGlobal(function()
        self:onLuaLogicUpdate()
    end,{})
end

function TableManager:stopLuaLogicUpdateLoop()
    if self.__luaLogicUpdateSchedulerHandler then
        scheduler.unscheduleGlobal(self.__luaLogicUpdateSchedulerHandler)
        self.__luaLogicUpdateSchedulerHandler = nil
    end
end

function TableManager:onLuaLogicUpdate()
    local curTime = DateTime.Now.Ticks -- long
    if self.__isLuaCollisionEngineRunning then
        self:onRunLuaEngine(curTime)
    end

    self:onLuaBallAnimUpdate(curTime)

    self:__onRenderBalls()
end

function TableManager:__onRenderBalls()
    for i, logicalBall in ipairs(self.__billiardsTableData.__allLogicalBallTable) do
        if logicalBall:isNeedRender() then
            logicalBall:updateVisualBall()
            logicalBall:setNeedRender(false)
        end
    end
end

function TableManager:onLuaBallAnimUpdate(curTime)
    if not self.__luaAnimTime or self.__luaAnimTime == 0 then
        self.__luaAnimTime = curTime
    end

    local duration = (curTime - self.__luaAnimTime) / 10000000

    if duration >= self.__billiardsConfig.TIME then
        self.__luaAnimTime = curTime

        local times = math.modf(duration / self.__billiardsConfig.TIME)

        for i, logicalBall in ipairs(self.__billiardsTableData.__allLogicalBallTable) do
            if logicalBall:isRollingInPocket() and logicalBall:isSpinning() then
                logicalBall:rotate(times)
                logicalBall:setNeedRender(true)
                -- local rotation = logicalBall.__rotation
                -- print("rotation => ", rotation.n11, rotation.n12, rotation.n13, rotation.n21, rotation.n22, rotation.n23, rotation.n31, rotation.n32, rotation.n33)
                -- logicalBall:rotate()
                -- logicalBall:updateVisualBall()
            end
        end
    end
end

function TableManager:onRunLuaEngine(curTime)
    if not self.__luaTime or self.__luaTime == 0 then
        self.__luaTime = curTime
        return
    end

    local duration = (curTime - self.__luaTime) / 10000000

    if duration >= self.__billiardsConfig.TIME then
        local tmpTime = 0

        while duration > tmpTime do
            self:runLuaCollisionEngineOneStep()
            tmpTime = tmpTime + self.__billiardsConfig.TIME
        end

        self.__luaTime = curTime
    end
end

function TableManager:runLuaCollisionEngineOneStep()
    local isRunning = self.__luaCollisionEngine:runBallCollision(self.__billiardsConfig.TIME)
    self:changeLuaCollisionEngineRunState(isRunning)
    for i, logicalBall in ipairs(self.__billiardsTableData.__allLogicalBallTable) do
        if logicalBall:isInPlay() then
            if logicalBall:isMovingOrSpinning() then
                logicalBall:setNeedRender(true)
            end
        elseif logicalBall:isDropIntoPocket() then
            -- self:hideVisualBall(logicalBall)
            -- self:showVisualBallInPacketAnim(logicalBall)
            self:playBallRollInPocketAnim(logicalBall)
        end
        -- TODO: 进洞球处理
    end
end

function TableManager:changeLuaCollisionEngineRunState(isRunning)
    if self.__isLuaCollisionEngineRunning ~= isRunning then
        self.__isLuaCollisionEngineRunning = isRunning

        if isRunning then
            self:__onLuaCollisionEngineTurnOn()
        else
            self:__onLuaCollisionEngineTurnOff()
        end
    end
end

--- 碰撞引擎从停止变为运行
function TableManager:__onLuaCollisionEngineTurnOn()
    print("__onLuaCollisionEngineTurnOn")
end

--- 碰撞引擎从运行变为停止
function TableManager:__onLuaCollisionEngineTurnOff()
    print("__onLuaCollisionEngineTurnOff")
    self:reportBallResult()
end

function TableManager:playBallRollInPocketAnim(logicalBall)
    print("TableManager:playBallRollInPocketAnim id => ", logicalBall.__id)

    --白球不进袋
    if logicalBall.__num == 0 then
        return
    end

    logicalBall:setState(logicalBall.STATE.ROLLING_IN_POCKET)
    self.__ballBag:addBall(logicalBall)
    cs_coroutine.start(function(logicalBall)
        local count = self.__ballBag:getInPocketLogicalBallsCount()
        print("inpocketball count => ", count)
        local totalLength = self.__billiardsConfig.IN_POCKET_ROLLING_TOTAL_LENGTH
        local radius = self.__billiardsConfig.BALL_RADIUS

        local visualBall= logicalBall.__visualBall
        local transform = visualBall.__ballNode.transform
        local vector3Array = {}
        local z = self.__billiardsConfig.BALL_IN_BAG_LAYER
        local x, y = self.__billiardsTableData:logicToScreen(self.__billiardsConfig.IN_POCKET_POS_START[1], self.__billiardsConfig.IN_POCKET_POS_START[2])
        transform.localPosition = Vector3(x, y, z)

        x, y = self.__billiardsTableData:logicToScreen(self.__billiardsConfig.IN_POCKET_POS_MID[1], self.__billiardsConfig.IN_POCKET_POS_MID[2])
        table.insert(vector3Array, Vector3(x, y, z))

        -- 1 是两球之间的间隔
        local minusLength = (count - 1) * radius * 2 + (count - 1) * 1

        x, y = self.__billiardsTableData:logicToScreen(self.__billiardsConfig.IN_POCKET_POS_END[1], self.__billiardsConfig.IN_POCKET_POS_END[2] - minusLength)
        table.insert(vector3Array, Vector3(x, y, z))

        local rollingLength = totalLength - minusLength

        local totalTime = rollingLength / totalLength * 4
        local stopTime = 3.8/4 * totalTime

        local moveByPath = transform:DOLocalPath(vector3Array, totalTime):OnWaypointChange(function(index)
            if index == 0 then
                logicalBall:playRollInPocketAnim(0, 0.1, 0)
            elseif index == 1 then
                logicalBall:playRollInPocketAnim(0.1, 0, 0)
            elseif index == 2 then
                -- logicalBall:stopSpinning()
                -- logicalBall:setState(logicalBall.STATE.STAY_IN_POCKET)
            end
            print("OnWaypointChange => ", index)
        end)

        local sequence = DOTween.Sequence()
        sequence:Append(moveByPath)
        sequence:InsertCallback(stopTime, function()
            logicalBall:stopSpinning()
            logicalBall:setState(logicalBall.STATE.STAY_IN_POCKET)
        end)
    end, logicalBall) -- cs_coroutine.start
end

-------------------------------------------------Lua实现end------------------------------------------


return TableManager