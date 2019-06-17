
local scheduler = require("misc.scheduler")
local PowerSlider = import(".views.PowerSlider")
local BilliardsConfig = import(".config.BilliardsConfig")
local BilliardsBallData = import(".model.BilliardsBallData")
local BilliardsTableData = import(".model.BilliardsTableData")
local LuaCollisionEngine = import(".collision.LuaCollisionEngine")
-- local LuaCueViewController = import(".views.LuaCueViewController")

local SetBallView = import(".views.SetBallView")





local MoveWhiteBallView = import(".views.MoveWhiteBallView")



local TableData = CS.Billiards.TableData

local LogicalBall = CS.Billiards.LogicalBall
local VisualBall = CS.Billiards.VisualBall
local BallData = CS.Billiards.BallData
local Number2D = CS.Billiards.Number2D
local Matrix3D = CS.Billiards.Matrix3D
local Number3D = CS.Billiards.Number3D
local Rectangle = CS.Billiards.Rectangle
local CollisionEngine = CS.Billiards.CollisionEngine
local Collision = CS.Billiards.Collision

local CueViewController = import(".CueViewController")

local TableManager = class("TableManager")

function TableManager:ctor(ctx)
    local scene = ctx.scene

    self.__billiardsConfig = BilliardsConfig
    self.__billiardsBallData = BilliardsBallData.new(self)
    self.__billiardsTableData = BilliardsTableData.new(self)

    self._time = 0

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



    self.__cueAngleBtn = scene.cueAngleBtn

    self.__cueAngleBtn:GetComponent("Button").onClick:AddListener(handler(self,self.onShowSetBallView))

    self.__moveWhiteBallView = MoveWhiteBallView.new(ctx,scene.handView)
    self.__moveWhiteBallView:onCallback(handler(self,self.onMoveWhiteBallCallback))


    



    self.__powerSlider = PowerSlider.new(scene.powerSlider)
    self.__powerSlider:setOnValueChangedCallback(handler(self,self.onPowerSliderChange))
    self.__powerSlider:setOnPointerUpCallback(handler(self,self.onPowerSliderPointerUp))
    self.__powerSlider:setOnPointerDownCallback(handler(self,self.onPowerSliderPointerDown))

    self.ballLayerTransform = self.ballLayer:GetComponent(typeof(Transform))

    self.__velocity = Number2D(0, 0)
    --- TODO: 可以优化到Lua层
    self.__tableRect = Rectangle(table.unpack(self.__billiardsConfig.TABLE_RECT))

    --发球区域
    self.__tableBreadRect = Rectangle(table.unpack(self.__billiardsConfig.TABLE_BREAK_RECT))

	TableData.BallData_BallMaskTextureClass = self._ballMaskBitmap;
    TableData.BallData_ballNumberClass = self._ballNumberBitmap;
    TableData.ScaleX = (self.rightTop.transform.position.x - self.leftTop.transform.position.x) / self.__billiardsConfig.WIDTH;
    TableData.ScaleY = -(self.leftTop.transform.position.y - self.leftBottom.transform.position.y) / self.__billiardsConfig.HEIGHT;
    TableData.BallLayer = self.ballLayer;
    TableData.ShadowBitmapClass = self._ballShadowBitmap;
    TableData.HighlightClass = self._hightLigthBitmap;

    self:initTable()

   

    nb.bind(self,"touch")
    self:addTouchListener(handler(self,self.onTouch))

    -- --test--
    self:setCueEnable(false,false,false)

    -- cs_coroutine.start(function()
    --     self.__billiardsBallData:loadTextures()
    --     self.__billiardsBallData:initColorDatas()

    --     self.__billiardsTableData:initVertices(self.__billiardsConfig.TABLE_POINTS)
    --     self.__billiardsTableData:initPocketPoints(self.__billiardsConfig.POCKET_POS)
    --     -- TODO:
    --     self.__billiardsTableData:initBalls(TableData.BallLayer:GetComponent(typeof(Transform)))

    --     self:setupLuaCollisionEngine()
    --     self:setupLuaBallsPosition()
    --     self:setupLuaViews()
    -- end)



    self.__broadCueLineVec3 = Vector3(0,0,0)
end




function TableManager:onShowSetBallView( ... )
    self.__setBallView:showView()
end



function TableManager:setMoveWhiteBallEnable(enable,isBreak)
     self.__moveWhiteBallView:setEnabled(true,self.__guideBall,isBreak)
end

function TableManager:setCueEnable(enable,touchable,needLine,flag)
    -- print("TableManager:setCueEnable",enable,touchable,needLine,flag)
    enable = enable or false
    touchable = touchable or false
    self:setTouchEnabled(touchable)
    if enable then
        self.__cueViewController:ShowAll()
    else
        self.__cueViewController:HideAll()
    end

    if needLine then
        self.__cueViewController:ShowLine()
        if flag then
            local nextBall = self:findFirstBallInPlayByFlag(flag)
            -- print(nextBall,"nextBall",checknumber(nextBall.position.x),checknumber(nextBall.position.y))
            -- print("nextBall000",nextBall.number,"!----!",checknumber(nextBall.position.x),checknumber(nextBall.position.y))
            if nextBall then
                local nextBallPos = TableData.LogicToScreen(nextBall.position.x,nextBall.position.y)
                 self.__cueViewController:UpdateAim(checknumber(nextBallPos.x),checknumber(nextBallPos.y),self.__guideBall, self.__tableData.AllBallArr);
            else
                 self.__cueViewController:UpdateAim(0, 0, self.__guideBall, self.__tableData.AllBallArr);
            end
        end
        
    else
        self.__cueViewController:HideLine()
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
    local len = self.__tableData.AllBallArr.Count;-- int

    -- print("findFirstBallInPlayByFlag-len",len)

    local ball; -- LogicalBall
    local index = 0;-- int
    while (index < len) do
        ball = self.__tableData.AllBallArr[index];
        -- print("findFirstBallInPlayByFlag-len",index,ball.number)
        if table.indexof(ballGroup,ball.number) then
            return ball
        end
        index = index + 1;
    end


 -- print("findFirstBallInPlayByFlag",flag,(ball and ball.number or -1))
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
    local len = self.__tableData.AllBallArr.Count;-- int
    local outBalls = {}
    local ball; -- LogicalBall
    local index = 0;-- int

    -- print("TableManager:getInPlayBallsByColor1111",color,len,index)

    while (index < len) do
        ball = self.__tableData.AllBallArr[index];
        -- print("TableManager:getInPlayBallsByColor2222-index",index,ball.needRender,ball.state,ball.number)

        if (ball.state == LogicalBall.nSTATE_IN_PLAY) then
            if table.indexof(ballGroup,ball.number) then
                table.insert(outBalls,ball.number)
            end
        end
        index = index + 1;
    end

    return outBalls
end



function TableManager:initTable()

	self.__startVelocity = 0
	self._isRunning = false

	self.__schedulePool = core.SchedulerPool.new()

	self.__tableData = TableData()
	self.__tableData:InitBalls()
	self.__guideBall = self.__tableData.GuideBall;
	self.__collisionEngine = CollisionEngine();
	self.__collisionEngine:Init(self.__tableData.AllBallArr, self.__tableData.PocketPoints, self.__tableData.Vertexs);
	self.__cueViewController = CueViewController.new(self, self.cuelinePre, self.__collisionEngine, self.cueView);
    -- self:SetBallPos()
    self:setupBallsPosition()

end



function TableManager:initGameInfo(isSelfInGame)
    self.isSelfInGame_ = isSelfInGame
end

function TableManager:reset()
    -- self.isSelfInGame_ = false
    self:stopUpdateLoop()
    self:setCueEnable(false,false,false)
    self:setMoveWhiteBallEnable(false,false)
    self.__powerSlider:setEnabled(false)
end

--[[
    在玩：1、轮到自己击球，

    观战: 1、不监听触摸事件，有击球数据就启动
--]]


function TableManager:getLogicPositionByTouchPosition(touchPosition)
    -- print("getLogicPositionByTouchPosition",touchPosition.x,touchPosition.y)
    local worldPos = Camera.main:ScreenToWorldPoint(touchPosition);--Vector3
    local localPos = self.ballLayerTransform:InverseTransformPoint(worldPos);--Vector3
    local logicCoord = TableData.ScreenToLogic(localPos.x, localPos.y);--Number2D
    return logicCoord;
end



function TableManager:onMoveWhiteBallCallback(touchPhase,touchPosition)
    if touchPhase == "Began" then
        --隐藏杆和瞄准线

    elseif touchPhase == "Ended" then
        --显示杆和瞄准线
        if self.__guideBall then
            local info = {}
            info.wx = self.__guideBall.position.x
            info.wy = self.__guideBall.position.y
            info.wz = self.__guideBall.position.z

            self:callGameControllerFunc("sendWhiteBallPos",info)

        end
    end
end



function TableManager:onPowerSliderChange(value)
    -- print("TableManager:onPowerSliderChange => ", value)

    self.__cueViewController:doBeatPowerAction(value, self.__guideBall)
end

function TableManager:onPowerSliderPointerUp(pointerEventData)
    local value = self.__powerSlider:getCurrentValue()
    -- print("TableManager:onPowerSliderPointerUp => ", pointerEventData, "value => ", value)
    if value > 0 then
        -- TODO: 把球打出去
        local currentVelocity = self.__cueViewController:getLogicVelocity()

        currentVelocity:CopyTo(self.__velocity)
        -- self.__velocity:Normalise()
        self:BeatCueBall(value*200)
        self._time = 0;
        self:ChangeRunState(true);
        self:setCueEnable(false,false,false)
        self:startUpdateLoop()

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
    local logicCoord = self:getLogicPositionByTouchPosition(touchPosition)
    if self.__tableRect:ContainsPoint(logicCoord.x, logicCoord.y) then
        if self._downPos then
            self:updateCueViewLine(touchPosition)
            self:sendCueLineData(touchPosition)
        end
    end
end


function TableManager:onMouseDown(touchPosition)
    local logicCoord = self:getLogicPositionByTouchPosition(touchPosition)
    if self.__tableRect:ContainsPoint(logicCoord.x, logicCoord.y) then
        self._downPos = logicCoord;
        self:sendCueLineData(touchPosition)
    end
end



function TableManager:startUpdateLoop()
    local scheduler = require("misc.scheduler")
    self:stopUpdateLoop()
    self.__schedulerHandle = scheduler.scheduleUpdateGlobal(function()
        self:onEngineUpdate()
    end,{})
end

function TableManager:stopUpdateLoop()
    if self.__schedulerHandle then
        scheduler.unscheduleGlobal(self.__schedulerHandle)
        self.__schedulerHandle = nil
    end
end

function TableManager:onBroadWhiteBallPos(info)
    if self.__guideBall then
        self.__guideBall.position.x = info.wx
        self.__guideBall.position.y = info.wy
        self.__guideBall.position.z = info.wz
        self.__guideBall:updateVisualBall()
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
    local localPos = self.ballLayerTransform:InverseTransformPoint(self.__broadCueLineVec3);--Vector3
    -- local logicCoord = TableData.ScreenToLogic(localPos.x, localPos.y);--Number2D

     -- self:updateCueViewLine(touchPosition)
     -- local localPos = self:getLocalPositionByTouchPosition(touchPosition)
    self.__cueViewController:UpdateAim(localPos.x, localPos.y, self.__guideBall, self.__tableData.AllBallArr);
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

function TableManager:onMouseUp(touchPosition)
    self._downPos = nil;
end

function TableManager:onEngineUpdate()
    if self._isRunning then
        self:StartEngine();
    else
        self:stopUpdateLoop()
        self:reportBallResult()
    end
end

function TableManager:reportBallResult()
    local balltb = {}
    local len = self.__tableData.AllBallArr.Count;-- int
    local ball; -- LogicalBall
    local index = 0;-- int
    while (index < len) do
        ball = self.__tableData.AllBallArr[index];
        local ballInfo = {}
        ballInfo.ballno = checknumber(ball.number)
        ballInfo.wx = checknumber(ball.position.x)
        ballInfo.wy = checknumber(ball.position.y)
        ballInfo.res = (ball.state == LogicalBall.nSTATE_IN_POCKET) and 1 or 2
        table.insert(balltb,ballInfo)
        index = index + 1;
    end

     self:callGameControllerFunc("sendHitBallResult",balltb)

end

function TableManager:StartEngine()
    local curTime = DateTime.Now.Ticks -- long
    if (self._time == 0) then
        self._time = curTime
        return
    end

    local _local2 = (((curTime - self._time) / 10000000.0)); -- double
    local tmp = 0;-- double
    while (_local2 > tmp) do
        self:RunOneStep();
        tmp = tmp + self.__billiardsConfig.TIME;
    end
    self._time = curTime;

    local len = self.__tableData.AllBallArr.Count;-- int
    local ball; -- LogicalBall
    local index = 0;-- int
    while (index < len) do
        ball = self.__tableData.AllBallArr[index];
        if (ball.needRender == true) then
            if (ball.state == LogicalBall.nSTATE_IN_PLAY) then
                ball:UpdateVisualBall()
            end
        end
        ball.needRender = false;
        index = index + 1;
    end
end

function TableManager:RunOneStep()
    -- print("TableManager:RunOneStep000000",isRunning)
    local isRunning = self.__collisionEngine:RunBallCollision(self.__billiardsConfig.TIME);
    -- print("TableManager:RunOneStep11111",isRunning)
        self:ChangeRunState(isRunning);
    local len = self.__tableData.AllBallArr.Count;
    local ball;
    local index = 0;
    while (index < len) do
        ball = self.__tableData.AllBallArr[index];
        if (ball.state == LogicalBall.nSTATE_IN_PLAY) then
            if (ball.IsMovingOrSpinning) then
                ball.needRender = true;
            end
        elseif ball.state == LogicalBall.nSTATE_IN_POCKET then
            self:HideVisualBall(ball)
        end
        index = index + 1;
    end
end

function TableManager:updateCueViewLine(touchPosition)
    local localPos = self:getLocalPositionByTouchPosition(touchPosition)
    self.__cueViewController:UpdateAim(localPos.x, localPos.y, self.__guideBall, self.__tableData.AllBallArr);
end

function TableManager:getLogicPositionByTouchPosition(touchPosition)
    local worldPos = Camera.main:ScreenToWorldPoint(touchPosition);--Vector3
    local localPos = self.ballLayerTransform:InverseTransformPoint(worldPos);--Vector3
    local logicCoord = TableData.ScreenToLogic(localPos.x, localPos.y);--Number2D
    return logicCoord;
end

function TableManager:getLocalPositionByTouchPosition(touchPosition)

    -- print("TableManager:getLocalPositionByTouchPosition")
    
    local worldPos = Camera.main:ScreenToWorldPoint(touchPosition);--Vector3
    local localPos = self.ballLayerTransform:InverseTransformPoint(worldPos);--Vector3
    return localPos
end

function TableManager:BeatCueBall(startVelocity)
	--double x, double y, double startVelocity
    -- self.__guideBall.velocity:Normalise();

    -- print("TableManager:BeatCueBall self.__velocity => x =", self.__velocity.x, ", y =", self.__velocity.y, "startVelocity =", startVelocity)

    local beatRadian = 0; -- double
    self.__guideBall.velocity = self.__velocity
    self.__velocity:Normalise()
    local force = startVelocity -- double
    local forwardForce = force * math.cos(beatRadian) -- double

    local downForce = force * math.sin(beatRadian)

    self.__guideBall.velocity:MultiplyEq((forwardForce * self.__billiardsConfig.START_VELOCITY));

    --Number2D angle = this._cueAngle.getValue();       -- 获取击球位置
    local angle = Number2D();                    -- 获取击球位置	Number2D
    local wx = ((-(self.__velocity.y) * angle.y) * force) + (self.__velocity.x) * downForce * angle.x;
    local wy = ((self.__velocity.x * angle.y) * force) + (self.__velocity.y) * downForce * angle.x;
    local wz = -forwardForce * angle.x * 2;
    local vx = self.__guideBall.velocity.x
    local vy = self.__guideBall.velocity.y

    self.__guideBall.w.x = wx
    self.__guideBall.w.y = wy
    self.__guideBall.w.z = wz
    self.__guideBall.state = LogicalBall.nSTATE_IN_PLAY;

    -- print("self.__guideBall.w => [x=", self.__guideBall.w.x, ", y=", self.__guideBall.w.y, ", z=", self.__guideBall.w.z, "]")
    -- print("self.__guideBall.velocity => [x=", self.__guideBall.velocity.x, ", y=", self.__guideBall.velocity.y, "]")
    -- print("self.__guideBall.state => ", self.__guideBall.state)

    -- self._time = 0;
    -- self:ChangeRunState(true);
    -- do return end


    --同步
    -- print("BeatCueBall",self.gameController.sendHitBall)

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

    if self.__guideBall then

        dump(info,"onBeatCueBall")
        self.__guideBall.w.x = wx
        self.__guideBall.w.y = wy
        self.__guideBall.w.z = wz
        self.__guideBall.state = LogicalBall.nSTATE_IN_PLAY;
        self.__guideBall.velocity.x = vx;
        self.__guideBall.velocity.y = vy;
        self._time = 0;
        self:ChangeRunState(true);
        self:startUpdateLoop()
    end

    self:setCueEnable(false,false,false)
end




--- 进洞隐藏球
function TableManager:HideVisualBall(logicBall)
    if logicBall and logicBall.visualBall then
        local visualBall = logicBall.visualBall
        -- print("HideVisualBall logicBall.number = ", logicBall.number)
        visualBall.view:SetActive(false)
        visualBall.shadowView:SetActive(false)
        visualBall.hightLightView:SetActive(false)
        logicBall.needRender = false;
    end
end

function TableManager:ChangeRunState(isRunning)
    if self._isRunning ~= isRunning then
        if(isRunning == false) then
            -- self.__cueViewController:Show();
            -- self.__cueViewController:UpdateAim(0, 0, self.__guideBall, self.__tableData.AllBallArr);
        else
            -- self.__cueViewController:Hide();
        end
        self._isRunning = isRunning;
    end
end

function TableManager:setupBallsPosition()
    -- 母球
    self.__guideBall.position:Reset(self.__billiardsConfig.CUE_BALL_POS[1], self.__billiardsConfig.CUE_BALL_POS[2])
    self.__guideBall:StopMoving()
    self.__guideBall.velocity.x = 0
    self.__guideBall.velocity.y = 0
    self.__guideBall.state = LogicalBall.nSTATE_IN_PLAY
    self.__guideBall:UpdateVisualBall()

    local CS_UnityEngine_Random = CS.UnityEngine.Random
    -- TODO:
    for index = 1, self.__tableData.BallArrExceptWhite.Count, 1 do
        local ball = self.__tableData.BallArrExceptWhite[index - 1] -- C/C++/C#索引
        local pos = self.__billiardsConfig.NON_CUE_BALL_POSITIONS[index] -- Lua索引
        ball.position:Reset(pos[1], pos[2])

        ball.w.x = 100 * CS_UnityEngine_Random.Range(0.0, 1.0)
        ball.w.y = 100 * CS_UnityEngine_Random.Range(0.0, 1.0)
        ball.w.z = 100 * CS_UnityEngine_Random.Range(0.0, 1.0)
        ball:Rotate()
        ball:StopMoving()
        ball.state = LogicalBall.nSTATE_IN_PLAY
        ball:UpdateVisualBall()
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
    cueBall.__position:Reset(self.__billiardsConfig.CUE_BALL_POS[1], self.__billiardsConfig.CUE_BALL_POS[2])
    cueBall:stopMovingAndSpinning()
    cueBall:setState(cueBall.STATE.IN_PLAY)
    cueBall:updateVisualBall()

    local nonCueLogicalBallTable = self.__billiardsTableData.__nonCueLogicalBallTable
    for index, ball in ipairs(nonCueLogicalBallTable) do
        local pos = self.__billiardsConfig.NON_CUE_BALL_POSITIONS[index] -- Lua索引
        ball.__position:Reset(pos[1], pos[2])

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
    self.__luaCollisionEngine = LuaCollisionEngine.new()
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
    if self.__isLuaEngineRunning then
        self:onRunLuaEngine()
    else
        self:stopUpdateLoop()
end
end

function TableManager:onRunLuaEngine()
    local curTime = DateTime.Now.Ticks -- long
    if not self.__luaTime or self.__luaTime == 0 then
        self.__luaTime = curTime
        return
    end

    local duration = (curTime - self.__luaTime) / 10000000
    local tmpTime = 0

    while duration > tmpTime do
        self:runLuaCollisionEngineOneStep()
        tmpTime = tmpTime + self.__billiardsConfig.TIME
    end

    self.__luaTime = curTime
    for i, logicalBall in ipairs(self.__billiardsTableData.__allLogicalBallTable) do
        if logicalBall:isNeedRender() then
            logicalBall:updateVisualBall()
            logicalBall:setNeedRender(false)
        end
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
        end
        -- TODO: 进洞球处理
    end
end

function TableManager:changeLuaCollisionEngineRunState(isRunning)
    if self.__isLuaEngineRunning ~= isRunning then
        self.__isLuaEngineRunning = isRunning
    end
end


-------------------------------------------------Lua实现end------------------------------------------


return TableManager