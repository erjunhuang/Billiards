local LuaMath = import("..math.LuaMath")
local LuaCollision = import(".LuaCollision")
local LuaCollisionData = import(".LuaCollisionData")
local LuaRectangle = import("..math.LuaRectangle")


local LuaCollisionEngine = class("LuaCollisionEngine")

function LuaCollisionEngine:ctor(tableManager)
    self.__tableManager = tableManager
    self.__luaCollision = LuaCollision.new()

    --- 桌子的逻辑矩形区域
    self.__tableRect = nil
    --- 桌子的内接矩形区域，用于过滤 球与边、球与点碰撞的情况
    self.__innerTableRect = nil

    --- 所有逻辑球
    self.__logicalBalls = {}
    --- 所有球带判定点
    self.__pocketPoints = {}
    --- 所有球桌顶点
    self.__vertices = {}

    --- 碰撞相关
    self.__allCollisionList = {}
    self.__curTimeCollisionList = {}
end

function LuaCollisionEngine:initWithLuaType(tableRect, logicalBallList, pocketPointList, vertexList)
    local billiardsConfig = self:getBilliardsConfig()
    local collisionDetectionGap = billiardsConfig.COLLISION_DETECTION_GAP
    local ballRadius = billiardsConfig.BALL_RADIUS

    self.__tableRect = tableRect
    local innerGap = ballRadius + collisionDetectionGap
    self.__innerTableRect = LuaRectangle.new(tableRect.x + innerGap, tableRect.y + innerGap,
        tableRect.width - 2 * innerGap, tableRect.height - 2 * innerGap)

    self.__logicalBalls = {}
    for i, logicalBall in ipairs(logicalBallList) do
        table.insert(self.__logicalBalls, logicalBall)
    end

    self.__pocketPoints = {}
    for i, pocketPoint in ipairs(pocketPointList) do
        table.insert(self.__pocketPoints, pocketPoint)
    end

    self.__vertices = {}
    for i, vertex in ipairs(vertexList) do
        table.insert(self.__vertices, vertex)
    end
end

function LuaCollisionEngine:getLuaCollision()
    return self.__luaCollision
end

function LuaCollisionEngine:getBilliardsConfig()
    return self.__tableManager:getBilliardsConfig()
end

function LuaCollisionEngine:getBilliardsBallData()
    return self.__tableManager:getBilliardsBallData()
end

function LuaCollisionEngine:getBilliardsTableData()
    return self.__tableManager:getBilliardsTableData()
end

--- 更新所有游戏中的球的角速度和线速度
function LuaCollisionEngine:updateAllVelocity(time)
    local isMove = false
    for i, logicalBall in ipairs(self.__logicalBalls) do
        if logicalBall:isInPlay() then
            if logicalBall:isSpinning() then
                logicalBall:rotate(time)
                isMove = true
            end
            self.__luaCollision:updateVelocity(logicalBall, time)
        end
    end
    return isMove
end

function LuaCollisionEngine:runBallCollision(time)
    local t = time
    local isMove = false
    while t > self.__luaCollision.MIN do
        local collisionT = t
        local collisionDataList = self:findTableFirstCollisionBall(t) or {}
        local length = #collisionDataList
        if length > 0 then
            local collisitionData = collisionDataList[1]
            collisionT = collisitionData.__time
        end

        for i, logicalBall in ipairs(self.__logicalBalls) do
            if logicalBall:isInPlay() and logicalBall:isMovingOrSpinning() then
                logicalBall:move(collisionT)
                if (not isMove) and logicalBall:isMoving() then
                    isMove = true
                end
            end
        end

        if length > 0 then
            local collisitionData = collisionDataList[1]
            self:turnCollision(collisitionData)
        end

        t = t - collisionT
    end

    isMove = self:updateAllVelocity(time) or isMove
    return isMove
end

function LuaCollisionEngine:turnCollision(collisionData)
    local ballA = self.__logicalBalls[collisionData.__ballA]
    local collisionType = collisionData.__collisionType

    if collisionType == collisionData.COLLISION_TYPE.BALL_AND_BALL then
        local ballB = self.__logicalBalls[collisionData.__ballB]
        self.__luaCollision:ballBallCollision(ballA, ballB)
    else
        self.__luaCollision:ballLineCollision(ballA, LuaMath.getAngle(collisionData.__x, collisionData.__y))
    end
end


--- 找出在给定时间内最早发生的碰撞列表
function LuaCollisionEngine:findTableFirstCollisionBall(time)
    self.__allCollisionList = {}
    self.__curTimeCollisionList = {}
    local minTime
    for i, logicalBall in ipairs(self.__logicalBalls) do
        if logicalBall:isInPlay() then
            local collisionData = self:findFirstCollisionBall(logicalBall, time)
            if collisionData then
                if (not minTime) or collisionData.__time < minTime then
                    minTime = collisionData.__time
                end
                table.insert(self.__allCollisionList, collisionData)
            end
        end
    end

    if minTime and #self.__allCollisionList > 0 then
        for i, collisionData in ipairs(self.__allCollisionList) do
            if collisionData.__time == minTime then
                table.insert(self.__curTimeCollisionList, collisionData)
            end
        end
    end


    return self.__curTimeCollisionList
end

function LuaCollisionEngine:findFirstCollisionBall(logicalBall, time)
    local billiardsConfig = self:getBilliardsConfig()
    local NEAR_POCKET_DETECTION_GAP_SQUARED = billiardsConfig.NEAR_POCKET_DETECTION_GAP_SQUARED
    local DROP_IN_POCKET_DETECTION_GAP_SQUARED = billiardsConfig.DROP_IN_POCKET_DETECTION_GAP_SQUARED

    local shortTime = time
    local xStart
    local xEnd
    local yStart
    local yEnd

    local collisionData

    if logicalBall:isInPlay() then
        -- 只遍历此球id之后的，因为之前id的球会包含一次对此球的碰撞检测
        for i = logicalBall.__id + 1, #self.__logicalBalls, 1 do
            local anotherBall = self.__logicalBalls[i]
            if anotherBall:isInPlay() then
                local isLegal, t = self.__luaCollision:ballBallCollisionTime(logicalBall, anotherBall, shortTime)
                if isLegal and t < shortTime then
                    --- 找出与其他所有球发生碰撞的最短时间
                    collisionData = LuaCollisionData.new(LuaCollisionData.COLLISION_TYPE.BALL_AND_BALL,
                        logicalBall.__id, anotherBall.__id, t)
                    shortTime = t
                end
            end
        end

        if logicalBall.__velocity.x > 0 then
            xStart = logicalBall.__position.x
            xEnd = logicalBall.__position.x + logicalBall.__velocity.x * time
        else
            xStart = logicalBall.__position.x + logicalBall.__velocity.x * time
            xEnd = logicalBall.__position.x
        end

        if logicalBall.__velocity.y > 0 then
            yStart = logicalBall.__position.y
            yEnd = logicalBall.__position.y + logicalBall.__velocity.y * time
        else
            yStart = logicalBall.__position.y + logicalBall.__velocity.y * time
            yEnd = logicalBall.__position.y
        end

        -- local radius = logicalBall.__radius + COLLISION_DETECTION_GAP

        --- 球在内矩形和外矩形范围之间时，才检测对边和点的碰撞
        -- if xStart < self.__tableRect.left + radius or xEnd > self.__tableRect.right - radius or
            -- yStart < self.__tableRect.bottom + radius or yEnd > self.__tableRect.top - radius then
        --- 判断球的运动轨迹是否会与内接判断矩形相交，如果相交，才检测球与便和球与点的碰撞
        if xStart < self.__innerTableRect.left or xEnd > self.__innerTableRect.right or
            yStart < self.__innerTableRect.bottom or yEnd > self.__innerTableRect.top then
            for i, pocketPoint in ipairs(self.__pocketPoints) do
                local xdist = pocketPoint.x - logicalBall.__position.x
                local ydist = pocketPoint.y - logicalBall.__position.y

                local pocketDistSquared = xdist * xdist + ydist * ydist

                -- 入袋检测
                if pocketDistSquared < NEAR_POCKET_DETECTION_GAP_SQUARED then
                    -- 给球一个向球袋移动的速度修正（目的是让球被“吸”进去，更容易进洞）
                    logicalBall.__velocity:add(xdist * 40 * time, ydist * 40 * time)
                    if pocketDistSquared < DROP_IN_POCKET_DETECTION_GAP_SQUARED then
                        logicalBall:setState(logicalBall.STATE.DROP_INTO_POCKET)
                        logicalBall.__pocketId = i
                        logicalBall:stopMovingAndSpinning()
                    end

                    break
                end
            end

            for i = 1, #self.__vertices, 1 do
                local startPoint = self.__vertices[i]
                local endIndex = (i + 1 <= #self.__vertices) and i + 1 or 1
                local endPoint = self.__vertices[endIndex]

                local isLegal, t = self.__luaCollision:ballLineCollisionTime(logicalBall, startPoint, endPoint, shortTime)

                if isLegal and t < shortTime then
                    collisionData = LuaCollisionData.new(LuaCollisionData.COLLISION_TYPE.BALL_AND_EDGE,
                        logicalBall.__id, -1, t, endPoint.x - startPoint.x, endPoint.y - startPoint.y)
                    shortTime = t
                end

                local vertex = self.__vertices[i]
                isLegal, t = self.__luaCollision:ballPointCollisionTime(logicalBall, vertex, shortTime)
                if isLegal and t < shortTime then
                    local xVel = logicalBall.__position.x - vertex.x
                    local yVel = vertex.y - logicalBall.__position.y

                    collisionData = LuaCollisionData.new(LuaCollisionData.COLLISION_TYPE.BALL_AND_POINT,
                        logicalBall.__id, -1, t, yVel, xVel)
                    shortTime = t
                end
            end
        end

        return collisionData
    end
end

function LuaCollisionEngine:findFirstLineOrPointCollisionBall(logicalBall, time)
    local collisionData = nil

    if logicalBall:isInPlay() then
        local xStart, xEnd, yStart, yEnd

        if logicalBall.__velocity.x > 0 then
            xStart = logicalBall.__position.x
            xEnd = logicalBall.__position.x + logicalBall.__velocity.x * time
        else
            xStart = logicalBall.__position.x + logicalBall.__velocity.x * time
            xEnd = logicalBall.__position.x
        end

        if logicalBall.__velocity.y > 0 then
            yStart = logicalBall.__position.y
            yEnd = logicalBall.__position.y + logicalBall.__velocity.y * time
        else
            yStart = logicalBall.__position.y + logicalBall.__velocity.y * time
            yEnd = logicalBall.__position.y
        end

        --- 判断球的运动轨迹是否会与内接判断矩形相交，如果相交，才检测球与便和球与点的碰撞
        if xStart < self.__innerTableRect.left or xEnd > self.__innerTableRect.right or
            yStart < self.__innerTableRect.bottom or yEnd > self.__innerTableRect.top then

            local shortTime = time

            for i = 1, #self.__vertices, 1 do
                local startPoint = self.__vertices[i]
                local endIndex = (i + 1 <= #self.__vertices) and i + 1 or 1
                local endPoint = self.__vertices[endIndex]

                local isLegal, t = self.__luaCollision:ballLineCollisionTime(logicalBall, startPoint, endPoint, shortTime)

                if isLegal and t < shortTime then
                    collisionData = LuaCollisionData.new(LuaCollisionData.COLLISION_TYPE.BALL_AND_EDGE,
                        logicalBall.__id, -1, t, endPoint.x - startPoint.x, endPoint.y - startPoint.y)
                    shortTime = t
                end

                local vertex = self.__vertices[i]
                isLegal, t = self.__luaCollision:ballPointCollisionTime(logicalBall, vertex, shortTime)
                if isLegal and t < shortTime then
                    local xVel = logicalBall.__position.x - vertex.x
                    local yVel = vertex.y - logicalBall.__position.y

                    collisionData = LuaCollisionData.new(LuaCollisionData.COLLISION_TYPE.BALL_AND_POINT,
                        logicalBall.__id, -1, t, yVel, xVel)
                    shortTime = t
                end
            end
        end
    end

    return collisionData
end

return LuaCollisionEngine