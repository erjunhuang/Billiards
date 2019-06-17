local Texture2DUtils = import("..views.Texture2DUtils")

local Application = CS.UnityEngine.Application
local UnityWebRequest = CS.UnityEngine.Networking.UnityWebRequest
local UnityWebRequestTexture = CS.UnityEngine.Networking.UnityWebRequestTexture
local DownloadHandlerTexture = CS.UnityEngine.Networking.DownloadHandlerTexture
local Color32 = CS.UnityEngine.Color32
local Array = CS.System.Array
local Type = CS.System.Type

local streamingAssetsPath = Application.streamingAssetsPath
local ballStreamingResPath = streamingAssetsPath .. "/res/ball/"

local BilliardsBallData = class("BilliardsBallData")

BilliardsBallData.COLOR = {
    LIGHT_BLUE = 0xEEECD3, -- 浅蓝

    BLACK = 0x231509,
    LIGHT_GREEN = 0xFFC600,
    MID_GREEN = 0x2944B5,
    DARK_GREEN = 0xDB1313,
    DARK_DARK_GREEN = 0x63116D,
    GREEN = 0xFF6000,
    DARK_DARK_BLUE = 0x414208,
    BLUE = 0x650E00,
}

BilliardsBallData.VFX_HIGHLIGHT = ballStreamingResPath .. "vfx_ball_highlight.png"
BilliardsBallData.VFX_SHADOW = ballStreamingResPath .. "vfx_ball_shadow.png"
BilliardsBallData.BALL_NUMBER = ballStreamingResPath .. "ball_number.png"
BilliardsBallData.BALL_MASK = ballStreamingResPath .. "ball_mask.png"

function BilliardsBallData:ctor(tableManager)
    self.__tableManager = tableManager

    -- 球数
    self.__ballCount = self:getBilliardsConfig().BALL_COUNT
    -- 球半径
    self.__radius = self:getBilliardsConfig().BALL_RADIUS

    self.__backColor = self.COLOR.LIGHT_BLUE
    self.__black = self.COLOR.BLACK
    self.__colors = {
        self.COLOR.LIGHT_GREEN,
        self.COLOR.MID_GREEN,
        self.COLOR.DARK_GREEN,
        self.COLOR.DARK_DARK_GREEN,
        self.COLOR.GREEN,
        self.COLOR.DARK_DARK_BLUE,
        self.COLOR.BLUE,
        self.COLOR.BLACK,
    }

    --- 颜色数据
    self.__colorDatas = nil

    --- Texture2D
    self.__maskTexture2D = nil
    self.__numberTexture2D = nil
    self.__highlightTexture2D = nil
    self.__shadowTexture2D = nil

    --- loadTextures函数结果判断的标志位
    self.__isLoadTexturesFinished = false
    self.__isLoadTexturesSuccessed = false

    --- 存放Color32[]的引用
    -- 改为存放{a,r,g,b}的表的引用，表下标从0开始，为了兼容以前的C#数组下标
    self.__colorDatasTable = {}
end

function BilliardsBallData:getBilliardsConfig()
    return self.__tableManager:getBilliardsConfig()
end

function BilliardsBallData:getBilliardsBallData()
    return self.__tableManager:getBilliardsBallData()
end

function BilliardsBallData:getBilliardsTableData()
    return self.__tableManager:getBilliardsTableData()
end

--- coroutine
function BilliardsBallData:loadTextures()
    print("BilliardsBallData:loadTextures start")
    self.__isLoadTexturesFinished = false
    self.__isLoadTexturesSuccessed = false

    self.__maskTexture2D = self:__loadTexture(self.BALL_MASK)
    self.__numberTexture2D = self:__loadTexture(self.BALL_NUMBER)
    self.__highlightTexture2D = self:__loadTexture(self.VFX_HIGHLIGHT)
    self.__shadowTexture2D = self:__loadTexture(self.VFX_SHADOW)

    if self.__maskTexture2D and self.__numberTexture2D and self.__highlightTexture2D and self.__shadowTexture2D then
        print("BilliardsBallData:loadTextures finished successfully")

        self.__isLoadTexturesFinished = true
        self.__isLoadTexturesSuccessed = true
    else
        print("BilliardsBallData:loadTextures finished unsuccessfully")
    end
end

--- in coroutine
function BilliardsBallData:__loadTexture(filepath)
    print("BilliardsBallData:__loadTexture loading:", filepath)
    local request = UnityWebRequestTexture.GetTexture(filepath)
    coroutine.yield(request:SendWebRequest())
    local texture2D = nil
    if request.isDone then
        local error = request.error
        if not error then
            texture2D = DownloadHandlerTexture.GetContent(request)
            print("load texture [".. filepath.."] succeed!")
        end
    end
    return texture2D
end

function BilliardsBallData:isLoadTexturesFinished()
    return self.__isLoadTexturesFinished
end

function BilliardsBallData:isLoadTexturesSuccessed()
    return self.__isLoadTexturesSuccessed
end

-- --- 反射创建Color32[length]的C#数组
-- -- TODO: 此方法无法用
-- -- Type.GetType("UnityEngine.Color32") 返回nil，不知道为啥
-- function BilliardsBallData:__createCSharpColor32Array(length)
--     local csArray = Array.CreateInstance(Type.GetType("UnityEngine.Color32"), length)
--     return csArray
-- end

-- -- 为了创建Color32[]数组的曲线救国方式，先创建List<Color32>，再转为Color32[]
-- function BilliardsBallData:__createCSharpColor32List(length)
--     local ListColor32 = CS.System.Collections.Generic.List(CS.UnityEngine.Color32)
--     if length then
--         local listObj = ListColor32(length)
--         for i = 1, length, 1 do
--             listObj:Add(Color32())
--         end
--         return listObj
--     else
--         return ListColor32()
--     end
-- end

--- 初始化用于渲染的Color32[]数据
function BilliardsBallData:initColorDatas()
    if not self.__isLoadTexturesSuccessed then
        print("must __loadTexture first")
        return
    end

    local bWidth = self.__maskTexture2D.width
    local bHeight = self.__maskTexture2D.height

    print("bWidth => ", bWidth, "bHeight => ", bHeight)

    local inColor32Array = self.__maskTexture2D:GetPixels32()
    local numColor32Array = self.__numberTexture2D:GetPixels32()

    local numWidth = self.__numberTexture2D.width
    local numHeight = self.__numberTexture2D.height

    for typeIndex = 0, self.__ballCount - 1, 1 do
        -- local outColor32Array = self:__createCSharpColor32Array(bWidth * bHeight)
        --- TODO: 此处是曲线救国，因为没法通过Array.CreateInstance创建数组
        -- local outColor32List = self:__createCSharpColor32List(bWidth * bHeight)
        -- local outColor32Array = outColor32List:ToArray()
        local outColor32Table = {}

        self:__calcColorData(typeIndex, outColor32Table, inColor32Array, bWidth, bHeight, numColor32Array, numWidth, numHeight)

        self.__colorDatasTable[typeIndex] = outColor32Table
    end
end

--- x, y是从上往下  从左往右
-- unity Pixels32数组索引 是从下往上 从左往右 暂时做个转换
function BilliardsBallData:__calcPixelIndex(x, y, width, height)
    return Texture2DUtils.calcPixelIndex(x, y, width, height)
end

--- Color32 转无符号整型，格式为argb
function BilliardsBallData:__color32ToUint(color32)
    if type(color32) == "table" and color32.uint then
        return color32.uint
    end
    return Texture2DUtils.color32ToUint(color32)
end

function BilliardsBallData:__calcColor32(color32Table, colorIndex, uintColor)
    local color32 = color32Table[colorIndex] or {}
    -- print("color32=>", color32)
    color32.a = (uintColor >> 24) & 0xFF
    color32.r = (uintColor >> 16) & 0xFF
    color32.g = (uintColor >> 8) & 0xFF
    color32.b = (uintColor) & 0xFF
    color32.uint = uintColor
    color32Table[colorIndex] = color32
end

function BilliardsBallData:__calcColorData(typeIndex, outColor32Table, inColor32Array, bWidth, bHeight, numColor32Array, numWidth, numHeight)
    local xIndex = 0
    local yIndex = 0
    if typeIndex == 0 then
        -- 母球
        while yIndex < bHeight do
            xIndex = 0
            while xIndex < bWidth do
                local colorIndex = self:__calcPixelIndex(xIndex, yIndex, bWidth, bHeight)
                local color = 0xFFFFFFFF
                local radius = (xIndex - bWidth / 2) * (xIndex - bWidth / 2) + (yIndex - bHeight / 2) * (yIndex - bHeight / 2)
                if radius < 10 then
                    color = 0xFF990033
                end
                self:__calcColor32(outColor32Table, colorIndex, color)
                xIndex = xIndex + 1
            end
            yIndex = yIndex + 1
        end
    else
        -- 其他球
        -- 是否为双色球
        local isDualColoredBall = typeIndex > 8
        local color = self.__colors[(typeIndex - 1) % #self.__colors + 1]
        local pixDeep
        local pixDeep2
        local pix1
        local pix2

        -- 算底色
        while yIndex < bHeight do
            xIndex = 0
            while xIndex < bWidth do
                local colorIndex = self:__calcPixelIndex(xIndex, yIndex, bWidth, bHeight)
                local color32 = inColor32Array[colorIndex]
                local colorU = self:__color32ToUint(color32)

                if isDualColoredBall then
                    -- 双色球
                    pixDeep = (colorU & 0xFF00) >> 8
                else
                    -- 单色球
                    pixDeep = colorU & 0xFF
                end
                pixDeep2 = 0xFF - pixDeep
                pix1 = ((pixDeep * (color & 0xFF00FF) & 0xFF00FF00) >> 8) + (((pixDeep2 * (self.__backColor & 0xFF00FF)) & 0xFF00FF00) >> 8)
                pix2 = ((pixDeep * (color & 0xFF00) >> 8) & 0xFF00) + (((pixDeep2 * (self.__backColor & 0xFF00)) >> 8) & 0xFF00)
                -- 添加alpha位
                local outColor = (pix1 | pix2) | 0xFF000000
                self:__calcColor32(outColor32Table, colorIndex, outColor)

                xIndex = xIndex + 1
            end

            yIndex = yIndex + 1
        end

        -- 加上数字
        local numPos = math.modf((bWidth - numWidth) / 2)
        local xPos = 0
        local yPos = (typeIndex - 1) * numWidth

        yIndex = 0
        while yIndex < numWidth do
            xIndex = 0
            while xIndex < numWidth do
                local colorIndex = self:__calcPixelIndex(xIndex + numPos, yIndex + numPos, bWidth, bHeight)
                local color32 = outColor32Table[colorIndex]
                local bpix = self:__color32ToUint(color32)
                local numColorIndex = self:__calcPixelIndex(xIndex + xPos, yIndex + yPos, numWidth, numHeight)
                local numColor32 = numColor32Array[numColorIndex]

                pixDeep = self:__color32ToUint(numColor32) & 0xFF
                pixDeep2 = 0xFF - pixDeep
                pix1 = (((pixDeep * (self.__black & 0xFF00FF)) & 0xFF00FF00) >> 8) + (((pixDeep2 * (bpix & 0xFF00FF)) & 0xFF00FF00) >> 8)
                pix2 = (((pixDeep * (self.__black & 0xFF00)) >> 8) & 0xFF00) + (((pixDeep2 * (bpix & 0xFF00)) >> 8) & 0xFF00)
                -- 添加alpha位
                local outColor = (pix1 | pix2) | 0xFF000000

                self:__calcColor32(outColor32Table, colorIndex, outColor)

                xIndex = xIndex + 1
            end
            yIndex = yIndex + 1
        end

    end
end

function BilliardsBallData:getBallColor32Data(typeIndex)
    return self.__colorDatasTable[typeIndex]
end

return BilliardsBallData