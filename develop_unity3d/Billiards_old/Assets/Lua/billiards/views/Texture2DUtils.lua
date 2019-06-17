--- 一些跟Texture2D相关的工具方法
local Texture2DUtils = {
    --- Color32 转无符号整型，格式为argb
    color32ToUint = function(color32)
        local r, g, b, a = color32.r, color32.g, color32.b, color32.a
        return (a << 24) + (r << 16) + (g << 8) + b
    end,

    --- x, y是从上往下  从左往右
    -- unity Pixels32数组索引 是从下往上 从左往右 暂时做个转换
    calcPixelIndex = function(x, y, width, height)
        local index = (height - y - 1) * width + x
        return index
    end,
}

return Texture2DUtils