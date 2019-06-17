
local LuaNumber3D = class("LuaNumber3D")

-- TODO: 其他需要用到的功能，用到的时候再添加
function LuaNumber3D:ctor(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
end

function LuaNumber3D:reset(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0

    return self
end

function LuaNumber3D:lengthSquared()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function LuaNumber3D:length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function LuaNumber3D:normalize()
    local length = self:length()

    self.x = self.x / length
    self.y = self.y / length
    self.z = self.z / length
    return self
end

function LuaNumber3D:clone()
    return LuaNumber3D.new(self.x, self.y, self.z)
end

function LuaNumber3D:copyFrom(anotherLuaNumber3D)
    self.x = anotherLuaNumber3D.x
    self.y = anotherLuaNumber3D.y
    self.z = anotherLuaNumber3D.z
    return self
end

function LuaNumber3D:copyTo(anotherLuaNumber3D)
    anotherLuaNumber3D.x = self.x
    anotherLuaNumber3D.y = self.y
    anotherLuaNumber3D.z = self.z
    return anotherLuaNumber3D
end

function LuaNumber3D:getDebugMsg()
    return "LuaNumber3D[x = "..tostring(self.x)..", y = "..tostring(self.y)..", z = "..tostring(self.z).."]"
end

return LuaNumber3D