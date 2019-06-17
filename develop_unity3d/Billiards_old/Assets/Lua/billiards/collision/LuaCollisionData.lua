local LuaCollisionData = class("LuaCollisionData")

--- 碰撞类型
LuaCollisionData.COLLISION_TYPE = {
    -- 球球碰撞
    BALL_AND_BALL = 0,
    -- 球边碰撞
    BALL_AND_EDGE = 1,
    -- 球点碰撞
    BALL_AND_POINT = 2,
}

function LuaCollisionData:ctor(collisionType, ballA, ballB, time, x, y)
    --- 碰撞类型
    self.__collisionType = collisionType or self.COLLISION_TYPE.BALL_AND_BALL
    --- 起碰球索引
    self.__ballA = ballA or 0
    --- 被碰球索引
    self.__ballB = ballB or 0
    --- 发生碰撞所需的时间
    self.__time = time or 0
    --- 球点碰撞、球线碰撞才有效的值
    self.__x = x or 0
    --- 球点碰撞、球线碰撞才有效的值
    self.__y = y or 0
end

return LuaCollisionData