local Number2D = CS.Billiards.Number2D

local LuaCollision = class("LuaCollision")

LuaCollision.DOPE = 0.804
LuaCollision.SLID_FORCE_SIDE = 0.7
--- 滑动力量
LuaCollision.SLID_FORCE = 0.4
--- 滚动力量
LuaCollision.ROLL_FORCE = 0.02
LuaCollision.TURN_I = 2.5
--- 球最小线速度标量
-- 碰撞时间的最小单位
LuaCollision.MIN = 1E-11
-- 碰撞时间的最大单位
LuaCollision.MAX = 366 * 24 * 60 * 60 * 1000
LuaCollision.ROLL_PARENT = 0.285714
LuaCollision.MASS = 980
LuaCollision.BL_COLLISION = 0.54

LuaCollision.SLID_RESISTANCE = LuaCollision.MASS * LuaCollision.SLID_FORCE
LuaCollision.ROLL_RESISTANCE = LuaCollision.MASS * LuaCollision.ROLL_FORCE

function LuaCollision:ctor()

end

function LuaCollision:getAngle(x, y)
    if x == 0 then
        if y >= 0 then
            return math.pi / 2
        else
            return -math.pi / 2
        end
    end

    local angle = math.atan(y / x)
    if x < 0 then
        angle = angle + math.pi
    end
    return angle
end

--[[
二维向量(逆时针)旋转
假设旋转角度为B
正向（逆时针）旋转： 
x1 = x0 * cosB + y0 * sinB
y1 = -x0 * sinB + y0 * cosB
反向（顺时针）旋转：
x1 = x0 * cosB - y0 * sinB
y1 = x0 * sinB + y0 * cosB
TODO: 性能优化
</summary>
<param name="xpos"></param>
<param name="ypos"></param>
<param name="sin">旋转角度的sin值</param>
<param name="cos">旋转角度的cos值</param>
<param name="reverse">是否反向旋转</param>
]]
function LuaCollision:calcRotation(xpos, ypos, sin, cos, reverse)
    local resultPoint = Number2D()
    if reverse then
        -- 顺时针
        resultPoint.x = xpos * cos + ypos * sin
        resultPoint.y = -xpos * sin + ypos * cos
    else
        -- 逆时针
        resultPoint.x = xpos * cos - ypos * sin
        resultPoint.y = xpos * sin + ypos * cos
    end
    return resultPoint
end

function LuaCollision:updateVelocity(ball, time)
    if not ball:isInPlay() or not ball:isMovingOrSpinning() then
        return
    end

    local vpX = -ball.__velocity.x - ball.__w.y * ball.__radius
    local vpY = -ball.__velocity.y + ball.__w.x * ball.__radius
    local vpLen = math.sqrt(vpX * vpX + vpY * vpY)
    local t = self.ROLL_PARENT * vpLen / self.SLID_RESISTANCE

    if t > self.MIN then
        local sildTime = math.min(t, time)
        local velPre = sildTime * self.SLID_RESISTANCE / vpLen
        vpX = vpX * velPre
        vpY = vpY * velPre
        ball.__velocity.x = ball.__velocity.x + vpX
        ball.__velocity.y = ball.__velocity.y + vpY
        ball.__w.x = ball.__w.x - self.TURN_I * vpY / ball.__radius
        ball.__w.y = ball.__w.y + self.TURN_I * vpX / ball.__radius
    end

    if t < time then
        local rollTime = time - t
        local velPre = self.ROLL_RESISTANCE * rollTime / ball.__velocity.Modulo
        ball.__velocity.Scale(math.max(0, 1 - velPre))
        ball.__w.x = ball.__velocity.y / ball.__radius
        ball.__w.y = -ball.__velocity.x / ball.__radius
    end

    local addZ = self.SLID_FORCE / self.TURN_I * self.MASS * time

    if ball.__w.z > 0 then
        ball.__w.z = math.max(0, ball.__w.z - addZ);
    else
        ball.__w.z = math.min(0, ball.__w.z + addZ);
    end
end

--- 返回双值，第一个代表是否合法，如果合法，则第二个代表时间
function LuaCollision:ballBallCollisionTime(ball1, ball2, time)
    local t
    local radiusDist = ball1.__radius + ball1.__radius
    local distPosX = ball1.__position.x - ball2.__position.x
    local distPosY = ball1.__position.y - ball2.__position.y
    local distVelX = ball1.__velocity.x - ball2.__velocity.x
    local distVelY = ball1.__velocity.y - ball2.__velocity.y

    -- 速度标量
    local a = distVelX * distVelX + distVelY * distVelY
    if a < self.MIN then
        return false
    end

    local b = distPosX * distVelX + distPosY * distVelY
    if b >= 0 then
        return false
    end

    local c = distPosX * distPosX + distPosY * distPosY - radiusDist * radiusDist
    local d = b * b - a * c
    if d < 0 then
        return false
    end

    t = (-b - math.sqrt(d)) / a
    if t <= 0 and t > -self.MIN then
        return true, self.MIN
    end
    if (t - self.MIN) > time then
        return false
    end

    return true, t
end

--- 返回双值，第一个代表是否合法，如果合法，则第二个代表时间
function LuaCollision:ballLineCollisionTime(ball, pStart, pEnd, time)
    local lenX = pEnd.x - pStart.x
    local lenY = pEnd.y - pStart.y
    -- TODO: 此除原本是Math.Atan2(lenY, lenX)
    local angle = self:getAngle(lenX, lenY)
    local cos = math.cos(angle)
    local sin = math.sin(angle)

    local velBall = self:calcRotation(ball.__velocity.x, ball.__velocity.y, sin, cos, true)

    if velBall.y <= 0 then
        return false
    end

    local startP = self:calcRotation(pStart.x, pStart.y, sin, cos, true)

    local ballPos = self:calcRotation(ball.__position.x, ball.__position.y, sin, cos, true)

    if ballPos.y + ball.__radius > startP.y then
        return false
    end

    local dis = ballPos.y - startP.y + ball.__radius
    local t = -dis / velBall.y
    if t > time then
        return false
    end

    local upPX = ballPos.x + t * velBall.x
    local endP = self:calcRotation(pEnd.x, pEnd.y, sin, cos, true)
    if upPX < startP.x or upPX > endP.x then
        return false
    end
    return true, t
end

--- 返回双值，第一个代表是否合法，如果合法，则第二个代表时间
function LuaCollision:ballPointCollisionTime(ball, point, time)
    local velocityLen = ball.__velocity.x * ball.__velocity.x + ball.__velocity.y * ball.__velocity.y
    local lenX = point.x - ball.__position.x
    local lenY = point.y - ball.__position.y
    local b = -ball.__velocity.x * lenX - ball.__velocity.y * lenY
    local len = lenX * lenX + lenY * lenY
    local a = velocityLen
    local bSquared = b * b
    local rSquared = ball.__radius * ball.__radius
    if (-bSquared / a + len) >= rSquared then
        return false
    end
    local t = (-b - math.sqrt(bSquared - a * (len - rSquared))) / velocityLen
    if t <= self.MIN or (t - self.MIN) > time then
        return false
    end
    return true, t
end


-- 球与球发生碰撞后两球线速度的变化
function LuaCollision:ballBallCollision(ball1, ball2)
    local lenX = ball2.__position.x - ball1.__position.x
    local lenY = ball2.__position.y - ball1.__position.y
    -- TODO: 此处原本是Math.Atan2(lenY, lenX)
    local angle = self:getAngle(lenX, lenY)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    local vel0 = self:calcRotation(ball1.__velocity.x, ball1.__velocity.y, sin, cos, true)
    local vel1 = self:calcRotation(ball2.__velocity.x, ball2.__velocity.y, sin, cos, true)
    local vxTotal = vel0.x - vel1.x
    vel0.x = vel1.x
    vel1.x = vxTotal + vel0.x
    local vel0F = self:calcRotation(vel0.x, vel0.y, sin, cos, false)
    local vel1F = self:calcRotation(vel1.x, vel1.y, sin, cos, false)
    ball1.__velocity.x = vel0F.x
    ball1.__velocity.y = vel0F.y
    ball2.__velocity.x = vel1F.x
    ball2.__velocity.y = vel1F.y
end

--- 球与边发生碰撞
-- 球与点发生碰撞走的也是这个函数
function LuaCollision:ballLineCollision(ball, angle)
    local cosA = math.cos(-angle)
    local sinA = math.cos(-angle)
    local velocityX = ball.__velocity.x * cosA - ball.__velocity.y * sinA
    local velocityY = ball.__velocity.x * sinA + ball.__velocity.y * cosA

    local angleX = ball.__w.x * cosA - ball.__w.y * sinA
    local angleY = ball.__w.x * sinA + ball.__w.y * cosA
    angleX = angleX - velocityY * self.BL_COLLISION / ball.__radius

    local angleZ = velocityX - ball.__w.z * ball.__radius
    local absZ = math.abs(angleZ)
    local minZ = math.min((absZ / self.TURN_I), self.SLID_FORCE_SIDE * self.SLID_FORCE_SIDE * math.abs(velocityY))
    local addZ = (absZ == 0) and 0 or (-angleZ * minZ) / absZ
    velocityX = velocityX + addZ
    ball.__w.z = ball.__w.z - (self.TURN_I * addZ) / ball.__radius
    velocityY = -velocityY * self.DOPE

    ball.__velocity.x = cosA * velocityX + sinA * velocityY
    ball.__velocity.y = -sinA * velocityX + cosA * velocityY

    ball.__w.x = cosA * angleX + sinA * angleY
    ball.__w.y = -sinA * angleX + cosA * angleY
end

return LuaCollision