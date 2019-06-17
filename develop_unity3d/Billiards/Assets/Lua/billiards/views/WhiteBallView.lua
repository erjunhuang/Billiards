local LuaMath = import("..math.LuaMath")

local EventTrigger = CS.UnityEngine.EventSystems.EventTrigger
local EventTriggerType = CS.UnityEngine.EventSystems.EventTriggerType
local RectTransformUtility = CS.UnityEngine.RectTransformUtility

local Vector2 = CS.UnityEngine.Vector2
local Vector3 = CS.UnityEngine.Vector3

--- 击球点
local WhiteBallView = class("WhiteBallView")

function WhiteBallView:ctor(ctx, view)
    self.__view = view
    self.__viewTransform = view:GetComponent("RectTransform")
    self.__cross = view.transform:Find("cross")

    self.__radius = 193
    -- -1到0到1的值，用于代表击球点位于球面的比例
    self.__valueX = 0
    self.__valueY = 0

    self.__radiusSquared = self.__radius * self.__radius

    self.__ballEventTrigger = self.__view:GetComponent("EventTrigger")
    self.__crossEventTrigger = self.__cross:GetComponent("EventTrigger")

    local dragEntry = EventTrigger.Entry()
    dragEntry.eventID = EventTriggerType.Drag
    dragEntry.callback:AddListener(handler(self, self.onCrossDrag))

    local downEntry = EventTrigger.Entry()
    downEntry.eventID = EventTriggerType.PointerDown
    downEntry.callback:AddListener(handler(self, self.onPointerDown))

    local clickEntry = EventTrigger.Entry()
    clickEntry.eventID = EventTriggerType.PointerClick
    clickEntry.callback:AddListener(handler(self, self.onSelfClick))

    self.__crossEventTrigger.triggers:Add(dragEntry)

    self.__ballEventTrigger.triggers:Add(dragEntry)
    self.__ballEventTrigger.triggers:Add(downEntry)
    self.__ballEventTrigger.triggers:Add(clickEntry)
end

function WhiteBallView:setOnValueChangeCallback(callback)
    self.__valueChangeCb = callback
end

function WhiteBallView:getCurrentXYValue()
    return self.__valueX, self.__valueY
end

--- 重置击球点
function WhiteBallView:resetHittingPoint()
    self:__updateCrossPositionAndCallback(Vector2(0, 0))
end

function WhiteBallView:onSelfClick(...)
    print("WhiteBallView:onSelfClick")
    if not self.__active and self.__activeCallback then
        self.__activeCallback("whiteBall")
    end
end

function WhiteBallView:setActive(value)
    self.__active = value
    if value then
        self.__viewTransform.localScale = Vector3(1, 1, 1)
        self.__viewTransform.anchoredPosition = Vector2(0, 0)
    else
        -- local parentBg = self.__viewTransform.parent:GetComponent("Image")
        local x = 350
        local y = -250
        self.__viewTransform.localScale = Vector3(0.3, 0.3, 0.3)
        self.__viewTransform.anchoredPosition = Vector2(x, y)
    end
end

function WhiteBallView:setOnActiveCallback(callback)
    self.__activeCallback = callback
end

function WhiteBallView:getBallInfo()
    local info = {}
    local anchoredPosition = self.__cross:GetComponent("RectTransform").anchoredPosition
    info.ax = anchoredPosition.x
    info.ay = anchoredPosition.y
    info.az = anchoredPosition.z

    return info
end

function WhiteBallView:onCrossDrag(pointerEventData)
    local rect = self.__view:GetComponent("RectTransform")
    local isSucc, localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(
        rect,
        pointerEventData.position,
        pointerEventData.enterEventCamera
    )
    if self.__active and isSucc then
        if (localPos.x * localPos.x + localPos.y * localPos.y) > self.__radiusSquared then
            local angle = LuaMath.getAngle(localPos.x, localPos.y)
            localPos.x = math.cos(angle) * self.__radius
            localPos.y = math.sin(angle) * self.__radius
        end

        self:__updateCrossPositionAndCallback(localPos)
    end
end

function WhiteBallView:onPointerDown(pointerEventData)
    local rect = self.__view:GetComponent("RectTransform")
    local isSucc, localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(
        rect,
        pointerEventData.position,
        pointerEventData.enterEventCamera
    )
    if self.__active and isSucc then
        if (localPos.x * localPos.x + localPos.y * localPos.y) <= self.__radiusSquared then
            self:__updateCrossPositionAndCallback(localPos)
        end
    end
end

function WhiteBallView:__updateCrossPositionAndCallback(localPosVector2)
    self.__cross:GetComponent("RectTransform").anchoredPosition = localPosVector2
    if self.__valueChangeCb then
        self.__valueX = localPosVector2.x / self.__radius
        self.__valueY = localPosVector2.y / self.__radius
        self.__valueChangeCb(self.__valueX, self.__valueY)
    end
end

return WhiteBallView
