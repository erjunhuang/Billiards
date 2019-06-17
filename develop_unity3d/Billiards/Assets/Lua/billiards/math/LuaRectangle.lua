local LuaRectangle = class("LuaRectangle")

--- 此处原本是bottom远离原点，top 接近原点
-- 改为bottom接近原点，top 远离原点
function LuaRectangle:ctor(x, y, width, height)
    self:setXYWidthHeight(x, y, width, height)
end

function LuaRectangle:setXYWidthHeight(x, y, width, height)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 0
    self.height = height or 0

    self.left = self.x
    self.right = self.left + self.width
    self.bottom = self.y
    self.top = self.bottom + self.height
end

function LuaRectangle:containsPoint(x, y)
    return x > self.left and x < self.right and y > self.bottom and y < self.top
end

return LuaRectangle