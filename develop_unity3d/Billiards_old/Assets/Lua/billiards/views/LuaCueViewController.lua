local LuaLogicalBall = import(".LuaLogicalBall")
local LuaMath = import("..math.LuaMath")
local LuaNumber2D = import("..math.LuaNumber2D")

local GameObject = CS.UnityEngine.GameObject
local Vector3 = CS.UnityEngine.Vector3
local Color = CS.UnityEngine.Color
local Quaternion = CS.UnityEngine.Quaternion

local LuaCueViewController = class('LuaCueViewController')

LuaCueViewController.BALL_POINTS = 20

function LuaCueViewController:ctor(tableManager, linePre, cueView)
    self.__tableManager = tableManager

    self.__cueBallX = 0
    self.__cueBallY = 0
    self.__targetBallX = 0
    self.__targetBallY = 0

    self.__velocityPosA = LuaNumber2D.new()
    self.__velocityPosB = LuaNumber2D.new()
    self.__posB = LuaNumber2D.new()
    self.__endP = LuaNumber2D.new()
    self.__startP = LuaNumber2D.new()

    self.__lineRendererPre = linePre

    local billiardsConfig = self:getBilliardsConfig()

    local cueViewTransform = cueView:GetComponent('Transform')
    local line = GameObject.Instantiate(linePre, cueViewTransform.parent)
    self.__lineLineRenderer = line:GetComponent('LineRenderer')
    self.__lineLineRenderer.useWorldSpace = false
    line:GetComponent('Transform').localPosition = Vector3(0, 0, billiardsConfig.AIM_LAYER)

    line = GameObject.Instantiate(linePre, cueViewTransform.parent)
    self.__ballLineRenderer = line:GetComponent('LineRenderer')
    self.__ballLineRenderer.useWorldSpace = false
    line:GetComponent('Transform').localPosition = Vector3(0, 0, billiardsConfig.AIM_LAYER)

    line = GameObject.Instantiate(linePre, cueViewTransform.parent)
    self.__reboundLineLineRenderer = line:GetComponent('LineRenderer')
    self.__reboundLineLineRenderer.useWorldSpace = false
    line:GetComponent('Transform').localPosition = Vector3(0, 0, billiardsConfig.AIM_LAYER)

    self.__cueView = cueView
    self.__cueViewTransform = cueViewTransform

    self.__lineLineRenderer.positionCount = 2
    self.__lineLineRenderer.startColor = Color.white
    self.__lineLineRenderer.endColor = Color.white
    self.__lineLineRenderer.startWidth = 0.02
    self.__lineLineRenderer.endWidth = 0.02

    self.__ballLineRenderer.positionCount = self.BALL_POINTS
    self.__ballLineRenderer.startColor = Color.white
    self.__ballLineRenderer.endColor = Color.white
    self.__ballLineRenderer.startWidth = 0.02
    self.__ballLineRenderer.endWidth = 0.02

    self.__reboundLineLineRenderer.positionCount = 3
    self.__reboundLineLineRenderer.startColor = Color.white
    self.__reboundLineLineRenderer.endColor = Color.white
    self.__reboundLineLineRenderer.startWidth = 0.03
    self.__reboundLineLineRenderer.endWidth = 0.03

    self.__targetBall = LuaLogicalBall.new(self.__tableManager)
    self.__cueBall = LuaLogicalBall.new(self.__tableManager)
    self.__guideBall = LuaLogicalBall.new(self.__tableManager)
    self.__aimBall = nil -- 是否存在目标球

    self.__logicVelocity = LuaNumber2D.new(0, 0)
end

function LuaCueViewController:getBilliardsConfig()
    return self.__tableManager:getBilliardsConfig()
end

function LuaCueViewController:getBilliardsBallData()
    return self.__tableManager:getBilliardsBallData()
end

function LuaCueViewController:getBilliardsTableData()
    return self.__tableManager:getBilliardsTableData()
end

function LuaCueViewController:getLuaCollisionEngine()
    return self.__tableManager:getLuaCollisionEngine()
end

function LuaCueViewController:getLogicVelocity()
    return self.__logicVelocity
end

function LuaCueViewController:drawLine(vstart, vend)
    self.__lineLineRenderer.positionCount = 2
    self.__ballLineRenderer.positionCount = self.BALL_POINTS
    local billiardsTableData = self:getBilliardsTableData()
    local billiardsConfig = self:getBilliardsConfig()
    local startX, startY = billiardsTableData:logicToScreen(vstart.x, vstart.y)
    local endX, endY = billiardsTableData:logicToScreen(vend.x, vend.y)
    self.__lineLineRenderer:SetPosition(0, Vector3(startX, startY, billiardsConfig.AIM_LAYER))
    self.__lineLineRenderer:SetPosition(1, Vector3(endX, endY, billiardsConfig.AIM_LAYER))
    local vec0
    local n = self.BALL_POINTS - 1
    for i = 0, n - 1, 1 do
        local x = math.cos((360 * (i + 1) / n) * LuaMath.DEGREE_TO_RADIAN) * billiardsConfig.BALL_RADIUS + vend.x
        local y = math.sin((360 * (i + 1) / n) * LuaMath.DEGREE_TO_RADIAN) * billiardsConfig.BALL_RADIUS + vend.y
        local screenX, screenY = billiardsTableData:logicToScreen(x, y)
        local vector = Vector3(screenX, screenY, billiardsConfig.AIM_LAYER)
        if i == 0 then
            vec0 = vector
        end

        self.__ballLineRenderer:SetPosition(i, vector)
    end

    self.__ballLineRenderer:SetPosition(self.BALL_POINTS - 1, vec0)
end

function LuaCueViewController:drawReboundLine(velocityPosA, velocityPosB, dend, draw)
    if draw then
        local billiardsTableData = self:getBilliardsTableData()
        local billiardsConfig = self:getBilliardsConfig()
        -- 画出来的两条线段看起来有点像切断了一样
        self.__reboundLineLineRenderer.positionCount = 3
        --母球回弹方向球心位置
        local x, y = billiardsTableData:logicToScreen(velocityPosA.x, velocityPosA.y)
        self.__reboundLineLineRenderer:SetPosition(0, Vector3(x, y, billiardsConfig.AIM_LAYER))
        --母球碰撞点球心位置
        x, y = billiardsTableData:logicToScreen(dend.x, dend.y)
        self.__reboundLineLineRenderer:SetPosition(1, Vector3(x, y, billiardsConfig.AIM_LAYER))
        --被碰球回弹方向球心位置
        x, y = billiardsTableData:logicToScreen(velocityPosB.x, velocityPosB.y)
        self.__reboundLineLineRenderer:SetPosition(2, Vector3(x, y, billiardsConfig.AIM_LAYER))
    else
        self.__reboundLineLineRenderer.positionCount = 0
    end
end

function LuaCueViewController:showAll()
    self.__lineLineRenderer.enabled = true
    self.__ballLineRenderer.enabled = true
    self.__reboundLineLineRenderer.enabled = true
    self.__cueView:GetComponent('Renderer').enabled = true
end

function LuaCueViewController:hideAll()
    self.__lineLineRenderer.enabled = false
    self.__ballLineRenderer.enabled = false
    self.__reboundLineLineRenderer.enabled = false
    self.__cueView:GetComponent('Renderer').enabled = false
end

function LuaCueViewController:showLine()
    self.__lineLineRenderer.enabled = true
    self.__ballLineRenderer.enabled = true
    self.__reboundLineLineRenderer.enabled = true
end

function LuaCueViewController:hideLine()
    self.__lineLineRenderer.enabled = false
    self.__ballLineRenderer.enabled = false
    self.__reboundLineLineRenderer.enabled = false
end

function LuaCueViewController:doBeatPowerAction(value, cueLogicalBall)
    local screenX, screenY = self:getBilliardsTableData():logicToScreen(cueLogicalBall.__position.x, cueLogicalBall.__position.y)
    local position = Vector3(screenX, screenY, self:getBilliardsConfig().CUE_LAYER)
    self.__cueViewTransform.localPosition = position
    -- TODO: 伸缩比例需要重新计算
    self.__cueViewTransform.position = self.__cueViewTransform.up * value * -1 + self.__cueViewTransform.position
end

function LuaCueViewController:updateAim(mouseX, mouseY, cueLogicalBall, onTableBalls)

    local billiardsConfig = self:getBilliardsConfig()
    local billiardsTableData = self:getBilliardsTableData()

    local guideX = cueLogicalBall.__position.x
    local guideY = cueLogicalBall.__position.y
    local mouseLogicCoordX, mouseLogicCoordY = billiardsTableData:screenToLogic(mouseX, mouseY)

    local ballScreenCoordX, ballScreenCoordY = billiardsTableData:logicToScreen(cueLogicalBall.__position.x, cueLogicalBall.__position.y)

    local angle = LuaMath.getAngle((mouseLogicCoordX - guideX), -(mouseLogicCoordY - guideY))
    self.__logicVelocity.x = mouseLogicCoordX - guideX
    self.__logicVelocity.y = mouseLogicCoordY - guideY


    self.__cueViewTransform.localPosition = Vector3(ballScreenCoordX, ballScreenCoordY, billiardsConfig.CUE_LAYER)

    self.__cueViewTransform.rotation = Quaternion.Euler(Vector3(0, 0, (angle * 180 / math.pi - 90)))

    self.__guideBall.__position.x = cueLogicalBall.__position.x
    self.__guideBall.__position.y = cueLogicalBall.__position.y
    self.__guideBall.__id = cueLogicalBall.__id
    self.__targetBall:reset()
    self.__targetBall:setState(self.__targetBall.STATE.IN_PLAY)
    self.__cueBall:reset()
    self.__cueBall:setState(self.__cueBall.STATE.IN_PLAY)

    local len  -- int
    self.__aimBall = nil
    self.__startP.x = self.__guideBall.__position.x
    self.__startP.y = self.__guideBall.__position.y
    self.__guideBall.__velocity.x = (mouseLogicCoordX - self.__guideBall.__position.x)
    self.__guideBall.__velocity.y = (mouseLogicCoordY - self.__guideBall.__position.y)
    self.__guideBall:setState(self.__guideBall.STATE.IN_PLAY)

    self.__guideBall.__velocity:Normalise()

    local luaCollision = self:getLuaCollisionEngine():getLuaCollision()

    local collisionData = self:getLuaCollisionEngine():findFirstCollisionBall(self.__guideBall, luaCollision.MAX)

    if collisionData then
        self.__endP.x = self.__guideBall.__position.x + self.__guideBall.__velocity.x * collisionData.__time

        self.__endP.y = self.__guideBall.__position.y + self.__guideBall.__velocity.y * collisionData.__time

        if collisionData.__collisionType == collisionData.COLLISION_TYPE.BALL_AND_BALL then
            local ballA = onTableBalls[collisionData.__ballA]
            local ballB = onTableBalls[collisionData.__ballB]

            self.__posB.x = ballB.__position.x
            self.__posB.y = ballB.__position.y

            self.__targetBall.__position.x = ballB.__position.x
            self.__targetBall.__position.y = ballB.__position.y

            self.__cueBall.__velocity.x = self.__guideBall.__velocity.x
            self.__cueBall.__velocity.y = self.__guideBall.__velocity.y

            self.__cueBall.__position.x = self.__endP.x
            self.__cueBall.__position.y = self.__endP.y
            luaCollision:ballBallCollision(self.__cueBall, self.__targetBall)
            self.__cueBallX = self.__cueBall.__velocity.x
            self.__cueBallY = self.__cueBall.__velocity.y
            self.__targetBallX = self.__targetBall.__velocity.x
            self.__targetBallY = self.__targetBall.__velocity.y

            local velX = ballA.__velocity.x - ballB.__velocity.x
            local velY = ballA.__velocity.y - ballB.__velocity.y
            len = math.modf(10 + ((20 * math.max((250 - math.sqrt(((velX * velX) + (velY * velY)))), 0)) / 250))
            self.__targetBall.__velocity:MultiplyEq(len)
            self.__cueBall.__velocity:MultiplyEq(len)
            self.__velocityPosA.x = self.__endP.x + self.__cueBall.__velocity.x
            self.__velocityPosA.y = self.__endP.y + self.__cueBall.__velocity.y
            self.__velocityPosB.x = self.__posB.x + self.__targetBall.__velocity.x
            self.__velocityPosB.y = self.__posB.y + self.__targetBall.__velocity.y
            self.__aimBall = ballB
        end
    end

    local start = Vector3(self.__startP.x, self.__startP.y, billiardsConfig.AIM_LAYER)
    local enda = Vector3(self.__endP.x, self.__endP.y, billiardsConfig.AIM_LAYER)
    self:drawLine(start, enda)
    local draw = self.__aimBall ~= nil and true or false
    self:drawReboundLine(self.__velocityPosA, self.__velocityPosB, enda, draw)
end

return LuaCueViewController
