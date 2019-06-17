local LuaLogicalBall = import("..views.LuaLogicalBall")
local LuaVisualBall = import("..views.LuaVisualBall")

local Number2D = CS.Billiards.Number2D

local BilliardsTableData = class("BilliardsTableData")

function BilliardsTableData:ctor(tableManager)
    self.__tableManager = tableManager

    --- 桌子顶点Lua表
    self.__verticesTable = nil
    --- 球袋判定点Lua表
    self.__pocketPointsTable = nil

    --- 全逻辑球Lua表
    self.__allLogicalBallTable = nil
    --- 除母球之外的全逻辑球Lua表
    self.__nonCueLogicalBallTable = nil
    --- 母球引用
    self.__cueBall = nil

    local pixelsPerUnit = self:getBilliardsConfig().PIXELS_PER_UNIT

    --- x轴和y轴的伸缩系数
    self.__scaleX = 1 / pixelsPerUnit
    self.__scaleY = -1 / pixelsPerUnit
end

function BilliardsTableData:getBilliardsConfig()
    return self.__tableManager:getBilliardsConfig()
end

function BilliardsTableData:getBilliardsBallData()
    return self.__tableManager:getBilliardsBallData()
end

function BilliardsTableData:getBilliardsTableData()
    return self.__tableManager:getBilliardsTableData()
end

--- 初始化球桌物理顶点
function BilliardsTableData:initVertices(verticesPositionsTable)
    verticesPositionsTable = verticesPositionsTable or self:getBilliardsConfig().TABLE_POINTS

    self.__verticesTable = {}
    for i, positionTable in ipairs(verticesPositionsTable) do
        local pos = Number2D(positionTable[1], positionTable[2])
        table.insert(self.__verticesTable, pos)
    end
end

--- 初始化球袋判定点
function BilliardsTableData:initPocketPoints(pocketPositionsTable)
    pocketPositionsTable = pocketPositionsTable or self:getBilliardsConfig().POCKET_POS

    self.__pocketPointsTable = {}
    for i, positionTable in ipairs(pocketPositionsTable) do
        local pos = Number2D(positionTable[1], positionTable[2])
        table.insert(self.__pocketPointsTable, pos)
    end
end

--- 初始化球
-- @param parentTransform 球要添加到的GameObject的transform
function BilliardsTableData:initBalls(parentTransform)

    self.__allLogicalBallTable = {}
    self.__nonCueLogicalBallTable = {}


    local ballCount = self:getBilliardsConfig().BALL_COUNT
    for i = 1, ballCount, 1 do
        local typeIndex = (i - 1) > 14 and 14 or (i - 1)
        local id = i
        local logicalBall = LuaLogicalBall.new(self.__tableManager, typeIndex, id)

        local visualBall = LuaVisualBall.new(self.__tableManager, logicalBall, parentTransform)
        logicalBall:bindVisualBall(visualBall)

        table.insert(self.__allLogicalBallTable, logicalBall)
        if typeIndex ~= 0 then
            table.insert(self.__nonCueLogicalBallTable, logicalBall)
        else
            self.__cueBall = logicalBall
        end
    end
end

function BilliardsTableData:screenToLogic(x, y)
    return x / self.__scaleX, y / self.__scaleY
end

function BilliardsTableData:logicToScreen(x, y)
    return x * self.__scaleX, y * self.__scaleY
end

function BilliardsTableData:screenToLogicX(x)
    return x / self.__scaleX
end

function BilliardsTableData:logicToScreenX(x)
    return  x * self.__scaleX
end

function BilliardsTableData:screenToLogicY(y)
    return y / self.__scaleY
end

function BilliardsTableData:logicToScreenY(y)
    return y * self.__scaleY
end

return BilliardsTableData