local LuaMath = import(".LuaMath")


--- 所有angle都是弧度
local LuaNumber2D = class("LuaNumber2D")

function LuaNumber2D.calcCrossProduct(a, b)
    return a.x * b.y - b.x * a.y
end

function LuaNumber2D.calcDotProduct(a, b)
    return a.x * b.x + a.y * b.y
end

function LuaNumber2D:ctor(x, y)
    self.x = x or 0
    self.y = y or 0
end

function LuaNumber2D:reset(x, y)
    self.x = x or 0
    self.y = y or 0
    return self
end

function LuaNumber2D:add(x, y)
    self.x = self.x + x
    self.y = self.y + y
    return self
end

function LuaNumber2D:substract(x, y)
    self.x = self.x - x
    self.y = self.y - y
    return self
end

function LuaNumber2D:multiply(num)
    self.x = self.x * num
    self.y = self.y * num
    return self
end

function LuaNumber2D:divide(num)
    self.x = self.x / num
    self.y = self.y / num
    return self
end

function LuaNumber2D:addNumber2D(anotherLuaNumber2D)
    self.x = self.x + anotherLuaNumber2D.x
    self.y = self.y + anotherLuaNumber2D.y
    return self
end

function LuaNumber2D:substractNumber2D(anotherLuaNumber2D)
    self.x = self.x - anotherLuaNumber2D.x
    self.y = self.y - anotherLuaNumber2D.y
    return self
end

function LuaNumber2D:crossProduct(anotherLuaNumber2D)
    return LuaNumber2D.calcCrossProduct(self, anotherLuaNumber2D)
end

function LuaNumber2D:dotProduct(anotherLuaNumber2D)
    return LuaNumber2D.calcDotProduct(self, anotherLuaNumber2D)
end

function LuaNumber2D:reverse()
    self.x = -self.x
    self.y = -self.y
    return self
end

function LuaNumber2D:clone()
    return LuaNumber2D.new(self.x, self.y)
end

function LuaNumber2D:copyTo(anotherLuaNumber2D)
    anotherLuaNumber2D.x = self.x
    anotherLuaNumber2D.y = self.y
    return anotherLuaNumber2D
end

function LuaNumber2D:copyFrom(anotherLuaNumber2D)
    self.x = anotherLuaNumber2D.x
    self.y = anotherLuaNumber2D.y
    return self
end

function LuaNumber2D:lengthSquared()
    return self.x * self.x + self.y * self.y
end

function LuaNumber2D:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function LuaNumber2D:normalize()
    local length = self:length()
    self.x = self.x / length
    self.y = self.y / length
    return self
end

function LuaNumber2D:angle()
    return LuaMath.getAngle(self.x, self.y)
end

function LuaNumber2D:rotate(angle)
    local x = self.x
    local y = self.y
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    self.x = x * cos - y * sin
    self.y = x * sin + y * cos
    return self
end

function LuaNumber2D:getDebugMsg()
    return "LuaNumber2D[x = "..tostring(self.x)..", y = "..tostring(self.y).."]"
end

return LuaNumber2D