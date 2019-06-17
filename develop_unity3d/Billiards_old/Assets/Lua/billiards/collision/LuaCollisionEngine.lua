local LuaCollision = import(".LuaCollision")
local LuaCollisionData = import(".LuaCollisionData")


local LuaCollisionEngine = class("LuaCollisionEngine")

function LuaCollisionEngine:ctor()
    self.__luaCollision = LuaCollision.new()

    --- TODO:
    self.__tableRect = nil

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

-- function LuaCollisionEngine:initWithCSharpType(tableRect, logicalBallList, pocketPointList, vertexList)
--     self.__tableRect = tableRect

--     self.__logicalBalls = {}
--     for i = 0, logicalBallList.Count - 1, 1 do
--         table.insert(self.__logicalBalls, logicalBallList[i])
--     end

--     self.__pocketPoints = {}
--     for i = 0, pocketPointList.Count - 1, 1 do
--         table.insert(self.__pocketPoints, pocketPointList[i])
--     end

--     self.__vertices = {}
--     for i = 0, vertexList.Count - 1, 1 do
--         table.insert(self.__vertices, vertexList[i])
--     end
-- end

function LuaCollisionEngine:initWithLuaType(tableRect, logicalBallList, pocketPointList, vertexList)
    self.__tableRect = tableRect

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

function LuaCollisionEngine:getAngle(x, y)
    self.__luaCollision:getAngle(x, y)
end

function LuaCollisionEngine:getLuaCollision()
    return self.__luaCollision
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

    if collisionType == LuaCollisionData.BALL_AND_BALL then
        local ballB = self.__logicalBalls[collisionData.__ballB]
        self.__luaCollision:ballBallCollision(ballA, ballB)
    else
        self.__luaCollision:ballLineCollision(ballA, self.__luaCollision:getAngle(collisionData.__x, collisionData.__y))
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
    local shortTime = time
    local xStart = 0
    local xEnd = 0
    local yStart = 0
    local yEnd = 0

    local collisionData

    if logicalBall:isInPlay() then
        -- 只遍历此球id之后的，因为之前id的球会包含一次对此球的碰撞检测
        for i = logicalBall.__id + 1, #self.__logicalBalls, 1 do
            local anotherBall = self.__logicalBalls[i]
            if anotherBall:isInPlay() then
                local isLegal, t = self.__luaCollision:ballBallCollisionTime(logicalBall, anotherBall, shortTime)
                if isLegal and t < shortTime then
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

        local radius = logicalBall.__radius + 2

        if xStart < self.__tableRect.left + radius or xEnd > self.__tableRect.right - radius or 
            yStart < self.__tableRect.top + radius or yEnd > self.__tableRect.bottom - radius then
            for i, pocketPoint in ipairs(self.__pocketPoints) do
                local xdist = pocketPoint.x - logicalBall.__position.x
                local ydist = pocketPoint.y - logicalBall.__position.y

                local pocketDistSquared = xdist * xdist + ydist * ydist

                -- 入袋检测
                if pocketDistSquared < 225 then
                    -- 给球一个向球袋移动的速度修正（目的是让球被“吸”进去，更容易进洞）
                    logicalBall.__velocity:Add(xdist * 40 * time, ydist * 40 * time)
                    if pocketDistSquared < 100 then
                        logicalBall:setState(logicalBall.STATE.IN_POCKET)
                        logicalBall.__pocketId = i
                        logicalBall:stopMovingAndSpinning()
                    end

                    break
                end
            end

            for i = 1, #self.__vertices, 1 do
                local startPoint = self.__vertices[i]
                local endIndex = (i + 1 <= len) and i + 1 or 1
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

return LuaCollisionEngine