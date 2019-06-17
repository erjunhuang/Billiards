local Matrix3D = CS.Billiards.Matrix3D
local Number3D = CS.Billiards.Number3D
local Number2D = CS.Billiards.Number2D

local LuaLogicalBall = class("LuaLogicalBall")

LuaLogicalBall.STATE = {
    NONE = 0,
    IN_PLAY = 1,
    IN_POCKET = 2,
}

--- 所有LogicalBall 共用的运算缓存
LuaLogicalBall.s_tmpMatrix3D = Matrix3D()
--- 所有LogicalBall 共用的运算缓存
LuaLogicalBall.s_tmpNumber3D = Number3D()

function LuaLogicalBall:ctor(tableManager, typeIndex, id)
    self.__tableManager = tableManager
    --- 球类型索引
    self.__typeIndex = typeIndex or 0
    --- 球的id
    self.__id = id or 0
    --- 球半径
    self.__radius = self:getBilliardsConfig().BALL_RADIUS
    --- 球位置
    self.__position = Number2D()
    --- 球旋转
    self.__rotation = Matrix3D()
    --- 球角速度
    self.__w = Number3D()
    --- 球线速度
    self.__velocity = Number2D()
    --- 球的状态
    self.__state = self.STATE.NONE
    --- 球入袋的id
    self.__pocketId = 0
    --- 是否需要被绘制
    self.__needRender = false
end

function LuaLogicalBall:reset()
    self.__position:Reset()
    self.__rotation:Reset()
    self.__w:Reset()
    self.__velocity:Reset()
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

function LuaLogicalBall:isInPocket()
    return self.__state == self.STATE.IN_POCKET
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
        self.__visualBall:renderBall()
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
    LuaLogicalBall.s_tmpNumber3D:Reset()
    LuaLogicalBall.s_tmpNumber3D.x = self.__w.x
    LuaLogicalBall.s_tmpNumber3D.y = self.__w.y
    LuaLogicalBall.s_tmpNumber3D.z = self.__w.z
    local len = LuaLogicalBall.s_tmpNumber3D.Modulo * time
    LuaLogicalBall.s_tmpNumber3D:Normalise()

    LuaLogicalBall.s_tmpMatrix3D:Reset()
    LuaLogicalBall.s_tmpMatrix3D:RotationMatrix(LuaLogicalBall.s_tmpNumber3D, len)
    self.__rotation:Multiply(LuaLogicalBall.s_tmpMatrix3D)
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
    self.__velocity:Reset()
end

--- 停止旋转
function LuaLogicalBall:stopSpinning()
    self.__w:Reset()
end

--- 停止旋转和移动
function LuaLogicalBall:stopMovingAndSpinning()
    self:stopMoving()
    self:stopSpinning()
end

return LuaLogicalBall