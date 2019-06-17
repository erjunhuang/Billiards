local LuaNumber2D = import("..math.LuaNumber2D")
local LuaNumber3D = import("..math.LuaNumber3D")
local LuaMatrix3D = import("..math.LuaMatrix3D")

local LuaLogicalBall = class("LuaLogicalBall")

LuaLogicalBall.STATE = {
    NONE = 0,
    IN_PLAY = 1,
    DROP_INTO_POCKET = 2,
    ROLLING_IN_POCKET = 3,
    STAY_IN_POCKET = 4,
}

--- 所有LogicalBall 共用的运算缓存
LuaLogicalBall.s_tmpMatrix3D = LuaMatrix3D.new()
--- 所有LogicalBall 共用的运算缓存
LuaLogicalBall.s_tmpNumber3D = LuaNumber3D.new()

function LuaLogicalBall:ctor(tableManager, typeIndex, id, num)
    self.__tableManager = tableManager
    --- 球类型索引
    self.__typeIndex = typeIndex or 0
    --- 球的id
    self.__id = id or 0
    --- 球的编号0-15
    self.__num = num or 0
    --- 球半径
    self.__radius = self:getBilliardsConfig().BALL_RADIUS
    --- 球位置
    self.__position = LuaNumber2D.new()
    --- 球旋转
    self.__rotation = LuaMatrix3D.new()
    --- 球角速度
    self.__w = LuaNumber3D.new()
    --- 球线速度
    self.__velocity = LuaNumber2D.new()
    --- 球的状态
    self.__state = self.STATE.NONE
    --- 球入袋的id
    self.__pocketId = 0
    --- 是否需要被绘制
    self.__needRender = false
end

function LuaLogicalBall:reset()
    self.__position:reset()
    self.__rotation:reset()
    self.__w:reset()
    self.__velocity:reset()
    self.__state = self.STATE.NONE
end

function LuaLogicalBall:setState(state)
    self.__state = state
end

function LuaLogicalBall:setNeedRender(needRender)
    self.__needRender = needRender
end

function LuaLogicalBall:isNeedRender()
    return self.__needRender
end

function LuaLogicalBall:isInPlay()
    return self.__state == self.STATE.IN_PLAY
end

--- 从球桌上到打进洞的状态
function LuaLogicalBall:isDropIntoPocket()
    return self.__state == self.STATE.DROP_INTO_POCKET
end

function LuaLogicalBall:isRollingInPocket()
    return self.__state == self.STATE.ROLLING_IN_POCKET
end

function LuaLogicalBall:isStayInPocket()
    return self.__state == self.STATE.STAY_IN_POCKET
end

function LuaLogicalBall:getBilliardsConfig()
    return self.__tableManager:getBilliardsConfig()
end

function LuaLogicalBall:getBilliardsBallData()
    return self.__tableManager:getBilliardsBallData()
end

function LuaLogicalBall:getBilliardsTableData()
    return self.__tableManager:getBilliardsTableData()
end

--- 绑定LuaVisualBall于此LuaLogicalBall
function LuaLogicalBall:bindVisualBall(visualBall)
    self.__visualBall = visualBall
end

function LuaLogicalBall:updateVisualBall()
    if self.__visualBall then
        if self:isInPlay() then
            self.__visualBall:updateInPlayVisualPosition()
        end

        self.__visualBall:renderBall()
    end
end

function LuaLogicalBall:playRollInPocketAnim(x, y, z)
    if self:isDropIntoPocket() then
        self:setState(self.STATE.ROLLING_IN_POCKET)
    end

    if self:isRollingInPocket() then
        self.__w.x = x or 0
        self.__w.y = y or 0
        self.__w.z = z or 0
    end
end

--- 计算移动
function LuaLogicalBall:move(time)
    time = time or 1
    self.__position.x = self.__position.x + self.__velocity.x * time
    self.__position.y = self.__position.y + self.__velocity.y * time
end

--- 计算旋转
function LuaLogicalBall:rotate(time)
    time = time or 1
    LuaLogicalBall.s_tmpNumber3D:reset()
    LuaLogicalBall.s_tmpNumber3D.x = self.__w.x
    LuaLogicalBall.s_tmpNumber3D.y = self.__w.y
    LuaLogicalBall.s_tmpNumber3D.z = self.__w.z
    local len = LuaLogicalBall.s_tmpNumber3D:length() * time
    LuaLogicalBall.s_tmpNumber3D:normalize()

    LuaLogicalBall.s_tmpMatrix3D:reset()
    LuaLogicalBall.s_tmpMatrix3D:rotateMatrix(LuaLogicalBall.s_tmpNumber3D, len)
    self.__rotation:multiplyMatrix3D(LuaLogicalBall.s_tmpMatrix3D)
end

--- 判断当前球是否在运动（包括位置移动和旋转）
function LuaLogicalBall:isMovingOrSpinning()
    return self:isMoving() or self:isSpinning()
end

--- 判断当前球是否在移动（仅包括位置移动）
function LuaLogicalBall:isMoving()
    return self.__velocity.x ~= 0 or self.__velocity.y ~= 0
end

--- 判断当前球是否在旋转
function LuaLogicalBall:isSpinning()
    return self.__w.x ~= 0 or self.__w.y ~= 0 or self.__w.z ~= 0
end

--- 停止移动
function LuaLogicalBall:stopMoving()
    self.__velocity:reset()
end

--- 停止旋转
function LuaLogicalBall:stopSpinning()
    self.__w:reset()
end

--- 停止旋转和移动
function LuaLogicalBall:stopMovingAndSpinning()
    self:stopMoving()
    self:stopSpinning()
end

return LuaLogicalBall