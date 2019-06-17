local LuaMath = {}

--- 角度转弧度
LuaMath.DEGREE_TO_RADIAN = 0.0174532925199433
--- 弧度转角度
LuaMath.RADION_TO_DEGREE = 57.2957795130823

LuaMath.getAngle = function(x, y)
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

return LuaMath