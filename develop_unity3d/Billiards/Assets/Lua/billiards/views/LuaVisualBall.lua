local Texture2DUtils = import(".Texture2DUtils")

local GameObject = CS.UnityEngine.GameObject
local Transform = CS.UnityEngine.Transform
local SpriteRenderer = CS.UnityEngine.SpriteRenderer
local Color32 = CS.UnityEngine.Color32
local Texture2D = CS.UnityEngine.Texture2D
local TextureFormat = CS.UnityEngine.TextureFormat
local Vector2 = CS.UnityEngine.Vector2
local Vector3 = CS.UnityEngine.Vector3
local Sprite = CS.UnityEngine.Sprite
local Rect = CS.UnityEngine.Rect
local BilliardsTool = CS.Billiards.BilliardsTool


local LuaVisualBall = class("LuaVisualBall")

function LuaVisualBall:ctor(tableManager, logicalBall, parentTransform)

    self.__tableManager = tableManager
    self:__bindLogicalBall(logicalBall)

    local billiardsConfig = self:getBilliardsConfig()

    local typeSpriteRenderer = typeof(SpriteRenderer)
    local pixelsPerUnit = billiardsConfig.PIXELS_PER_UNIT

    self.__ballNode = GameObject()
    self.__ballNode.name = "luaBallNode" .. self.__id
    local nodeTransform = self.__ballNode.transform
    nodeTransform:SetParent(parentTransform)

    self.__ballView = GameObject()
    self.__ballView.transform:SetParent(nodeTransform)
    self.__ballViewRenderer = self.__ballView:AddComponent(typeSpriteRenderer)
    self.__ballView.name = "luaBall".. self.__id
    self.__ballView.transform.localPosition = Vector3(0, 0, billiardsConfig.BALL_LAYER)

    self.__shadowView = GameObject()
    self.__shadowView.transform:SetParent(nodeTransform)
    self.__shadowViewRenderer = self.__shadowView:AddComponent(typeSpriteRenderer)
    self.__shadowView.name = "luaBallShadow" .. self.__id
    local shadowTexturre2D = self:getBilliardsBallData().__shadowTexture2D
    self.__shadowViewRenderer.sprite = Sprite.Create(shadowTexturre2D,
        Rect(0.0, 0.0, shadowTexturre2D.width, shadowTexturre2D.height),
        Vector2(0.5, 0.5), pixelsPerUnit)
    self.__shadowView.transform.localScale = Vector3(1.4, 1.4, 1.4)
    self.__shadowView.transform.localPosition = Vector3(0, 0, billiardsConfig.SHADOW_LAYER)

    self.__highLightView = GameObject()
    self.__highLightView.transform:SetParent(nodeTransform)
    self.__highLightViewRenderer = self.__highLightView:AddComponent(typeSpriteRenderer)
    self.__highLightView.name = "luaBallHighLight" .. self.__id
    local highLightTexture2D = self:getBilliardsBallData().__highlightTexture2D
    self.__highLightViewRenderer.sprite = Sprite.Create(highLightTexture2D,
        Rect(0.0, 0.0, highLightTexture2D.width, highLightTexture2D.height),
        Vector2(0.5, 0.5), pixelsPerUnit)
    self.__highLightView.transform.localPosition = Vector3(0, 0, billiardsConfig.HIGHLIGHT_LAYER)

    local textureWidth = math.ceil(self.__radius * 2 + 1)
    self.__ballTexture2DWidth = textureWidth
    self.__ballTexture2DHeight = textureWidth
    self.__ballTexture2D = Texture2D(textureWidth, textureWidth, TextureFormat.ARGB32, false)
    self.__ballViewRenderer.sprite = Sprite.Create(self.__ballTexture2D,
        Rect(0.0, 0.0, textureWidth, textureWidth), Vector2(0.5, 0.5), pixelsPerUnit)
    self.__ballTextureColor32Buffer = self.__ballTexture2D:GetPixels32()
    self.__ballColor32Table = {}

    -- 半径的平方
    self.__radiusSquared = self.__radius * self.__radius
    self.__alphaValue = (self.__radius - 1) * (self.__radius - 1)
    self.__alphaParent = 0x0100 / (self.__radiusSquared - self.__alphaValue)
end

function LuaVisualBall:getBilliardsConfig()
    return self.__tableManager:getBilliardsConfig()
end

function LuaVisualBall:getBilliardsBallData()
    return self.__tableManager:getBilliardsBallData()
end

function LuaVisualBall:getBilliardsTableData()
    return self.__tableManager:getBilliardsTableData()
end


--- 绑定LuaLogicalBall于此LuaVisualBall
function LuaVisualBall:__bindLogicalBall(logicalBall)
    self.__logicalBall = logicalBall
    -- 半径
    self.__radius = self.__logicalBall.__radius
    -- id
    self.__id = self.__logicalBall.__id

    local billiardsBallData = self:getBilliardsBallData()
    self.__srcColor32Data = billiardsBallData:getBallColor32Data(self.__logicalBall.__typeIndex)
    self.__srcWidth = billiardsBallData.__maskTexture2D.width
    self.__srcHeight = billiardsBallData.__maskTexture2D.height
end

function LuaVisualBall:updateInPlayVisualPosition()
    local x, y = self:getBilliardsTableData():logicToScreen(self.__logicalBall.__position.x, self.__logicalBall.__position.y)
    self.__ballNode.transform.localPosition = Vector3(x, y, 0)
end

function LuaVisualBall:renderBall()
    -- local billiardsTableData = self:getBilliardsTableData()
    -- local billiardsConfig = self:getBilliardsConfig()
    -- local scaleX = billiardsTableData.__scaleX
    -- local scaleY = billiardsTableData.__scaleY
    -- local x = self.__logicalBall.__position.x * scaleX
    -- local y = self.__logicalBall.__position.y * scaleY

    -- local x, y = billiardsTableData:logicToScreen(self.__logicalBall.__position.x, self.__logicalBall.__position.y)
    -- self.__ballNode.transform.localPosition = Vector3(x, y, 0)
    -- self.__ballView.transform.localPosition = Vector3(x, y, billiardsConfig.BALL_LAYER)
    -- self.__shadowView.transform.localPosition = Vector3(x, y, billiardsConfig.SHADOW_LAYER)
    -- self.__highLightView.transform.localPosition = Vector3(x, y, billiardsConfig.HIGHLIGHT_LAYER)

    self:__calcRenderBall(self.__srcColor32Data, self.__ballColor32Table, self.__logicalBall.__rotation)

    BilliardsTool.SetColor32Array(self.__ballTextureColor32Buffer, self.__ballColor32Table)

    self.__ballTexture2D:SetPixels32(self.__ballTextureColor32Buffer)
    self.__ballTexture2D:Apply(false)
end

function LuaVisualBall:__calcRenderBall(srcColor32Buffer, targetColor32Buffer, rotation, xOffset, yOffset)
    xOffset = xOffset or 0
    yOffset = yOffset or 0

    -- ballMask的宽高一半向下取整
    local sWidth = self.__srcWidth >> 1
    local sHeight = self.__srcHeight >> 1
    local tWidth = self.__ballTexture2DWidth
    local tHeight = self.__ballTexture2DHeight
    local isBack = rotation.n33 >= 0 and 1 or -1
    local xIndex = 0
    local yIndex = 0

    while yIndex < tHeight do
        xIndex = 0
        while xIndex < tWidth do
            -- 相对X
            local xRela = xIndex - self.__radius + xOffset
            -- 相对Y
            local yRela = yIndex - self.__radius + yOffset
            -- 距离
            local dist = xRela * xRela + yRela * yRela

            local pix = 0
            if dist < self.__radiusSquared then
                local iVect = xRela / self.__radius
                local jVect = yRela / self.__radius

                local kVect = math.sqrt(1 - iVect * iVect - jVect * jVect)
                local colorDeep = 64 + math.modf(kVect * 191)
                local xProp = (iVect * rotation.n11 + jVect * rotation.n12 + kVect * rotation.n13) * isBack
                local yProp = iVect * rotation.n21 + jVect * rotation.n22 + kVect * rotation.n23
                local sourceIndex = self:__calcPixelIndex(math.modf(sWidth * (1 + xProp)), math.modf(sHeight * (1 + yProp)),
                    self.__srcWidth, self.__srcHeight)
                pix = srcColor32Buffer[sourceIndex].uint
                pix = ((((pix & 0xFF00FF) * colorDeep) >> 8) & 0xFF00FF) + ((((pix & 0xFF00) * colorDeep) >> 8) & 0xFF00)

                if dist <= self.__alphaValue then
                    pix = 0xFF000000 + pix
                else
                    local deep = math.modf(0x0100 - (dist - self.__alphaValue) * self.__alphaParent)
                    pix = (deep << 24) + pix
                end
            else -- if dist < self.__radiusSquared then

                pix = 0
            end

            local offsetX = (xIndex + tWidth) % tWidth
            local offsetY = (yIndex + tHeight) % tHeight
            local targetIndex = self:__calcPixelIndex(offsetX, offsetY, tWidth, tHeight)

            targetColor32Buffer[targetIndex + 1] = pix
            xIndex = xIndex + 1
        end -- while xIndex < tWidth do
        yIndex = yIndex + 1
    end -- while yIndex < tHeight do
end

--- x, y是从上往下  从左往右
-- unity Pixels32数组索引 是从下往上 从左往右 暂时做个转换
-- 与BilliardsBallData中的同名函数保持一致
function LuaVisualBall:__calcPixelIndex(x, y, width, height)
    return Texture2DUtils.calcPixelIndex(x, y, width, height)
end

return LuaVisualBall