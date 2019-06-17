--- Lua实现的三阶矩阵
local LuaMatrix3D = class("LuaMatrix3D")

function LuaMatrix3D:ctor()
    self:reset()
end

function LuaMatrix3D:reset()
    self.n11 = 1
    self.n22 = 1
    self.n33 = 1

    self.n12 = 0
    self.n13 = 0
    self.n21 = 0
    self.n23 = 0
    self.n31 = 0
    self.n32 = 0

    return self
end

function LuaMatrix3D:multiplyMatrix3D(anotherMatrix3D)
    local tn12 = self.n11 * anotherMatrix3D.n12 + self.n12 * anotherMatrix3D.n22 + self.n13 * anotherMatrix3D.n32
    local tn11 = self.n11 * anotherMatrix3D.n11 + self.n12 * anotherMatrix3D.n21 + self.n13 * anotherMatrix3D.n31
    local tn13 = self.n11 * anotherMatrix3D.n13 + self.n12 * anotherMatrix3D.n23 + self.n13 * anotherMatrix3D.n33
    local tn21 = self.n21 * anotherMatrix3D.n11 + self.n22 * anotherMatrix3D.n21 + self.n23 * anotherMatrix3D.n31
    local tn22 = self.n21 * anotherMatrix3D.n12 + self.n22 * anotherMatrix3D.n22 + self.n23 * anotherMatrix3D.n32
    local tn23 = self.n21 * anotherMatrix3D.n13 + self.n22 * anotherMatrix3D.n23 + self.n23 * anotherMatrix3D.n33
    local tn31 = self.n31 * anotherMatrix3D.n11 + self.n32 * anotherMatrix3D.n21 + self.n33 * anotherMatrix3D.n31
    local tn32 = self.n31 * anotherMatrix3D.n12 + self.n32 * anotherMatrix3D.n22 + self.n33 * anotherMatrix3D.n32
    local tn33 = self.n31 * anotherMatrix3D.n13 + self.n32 * anotherMatrix3D.n23 + self.n33 * anotherMatrix3D.n33

    self.n11 = tn11
    self.n12 = tn12
    self.n13 = tn13
    self.n21 = tn21
    self.n22 = tn22
    self.n23 = tn23
    self.n31 = tn31
    self.n32 = tn32
    self.n33 = tn33

    return self
end

function LuaMatrix3D:rotateMatrix(number3DPoint, angle)
    local x = number3DPoint.x
    local y = number3DPoint.y
    local z = number3DPoint.z
    local nCos = math.cos(angle)
    local nSin = math.sin(angle)
    local scos = 1 - nCos
    local sxy = x * y * scos
    local syz = y * z * scos
    local sxz = x * z * scos
    local sz = nSin * z
    local sy = nSin * y
    local sx = nSin * x
    self.n11 = nCos + x * x * scos
    self.n12 = -sz + sxy
    self.n13 = sy + sxz
    self.n21 = sz + sxy
    self.n22 = nCos + y * y * scos
    self.n23 = -sx + syz
    self.n31 = -sy + sxz
    self.n32 = sx + syz
    self.n33 = nCos + z * z * scos

    return self
end

function LuaMatrix3D:copyTo(anotherMatrix3D)
    anotherMatrix3D.n11 = self.n11
    anotherMatrix3D.n12 = self.n12
    anotherMatrix3D.n13 = self.n13
    anotherMatrix3D.n21 = self.n21
    anotherMatrix3D.n22 = self.n22
    anotherMatrix3D.n23 = self.n23
    anotherMatrix3D.n31 = self.n31
    anotherMatrix3D.n32 = self.n32
    anotherMatrix3D.n33 = self.n33

    return anotherMatrix3D
end

function LuaMatrix3D:copyFrom(anotherMatrix3D)
    self.n11 = anotherMatrix3D.n11
    self.n12 = anotherMatrix3D.n12
    self.n13 = anotherMatrix3D.n13
    self.n21 = anotherMatrix3D.n21
    self.n22 = anotherMatrix3D.n22
    self.n23 = anotherMatrix3D.n23
    self.n31 = anotherMatrix3D.n31
    self.n32 = anotherMatrix3D.n32
    self.n33 = anotherMatrix3D.n33

    return self
end

function LuaMatrix3D:clone()
    local newMatrix3D = LuaMatrix3D.new()
    newMatrix3D.copyFrom(self)
    return newMatrix3D
end

return LuaMatrix3D