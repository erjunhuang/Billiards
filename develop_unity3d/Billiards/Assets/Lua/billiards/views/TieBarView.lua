local LuaMath = import("..math.LuaMath")

local EventTrigger = CS.UnityEngine.EventSystems.EventTrigger
local EventTriggerType = CS.UnityEngine.EventSystems.EventTriggerType
local RectTransformUtility = CS.UnityEngine.RectTransformUtility

local Vector2 = CS.UnityEngine.Vector2
local Vector3 = CS.UnityEngine.Vector3
local Quaternion = CS.UnityEngine.Quaternion

--- 高低杆
local TieBarView = class("TieBarView")

function TieBarView:ctor(ctx, view)
    print("TieBarView:ctor", view)
    self.__view = view
    self.__viewTransform = view:GetComponent("RectTransform")
    self.__needle = self.__view.transform:Find("needle")
    self.__needleTransform = self.__needle:GetComponent("RectTransform")
    self.__angleTxt = view.transform:Find("angleTxt")

    self.__needleOrigin = view.transform:Find("needleOrigin")

    self.__barBgEventTrigger = self.__view:GetComponent("EventTrigger")
    self.__needleEventTrigger = self.__needle:GetComponent("EventTrigger")

    self.__angleTxt:GetComponent("Text").text = "0°"
    --- 0.0到1.0 对应 0度 到 90度
    self.__value = 0

    local dragEntry = EventTrigger.Entry()
    dragEntry.eventID = EventTriggerType.Drag
    dragEntry.callback:AddListener(handler(self, self.onNeedleDrag))

    local downEntry = EventTrigger.Entry()
    downEntry.eventID = EventTriggerType.PointerDown
    downEntry.callback:AddListener(handler(self, self.onPointerDown))

    local clickEntry = EventTrigger.Entry()
    clickEntry.eventID = EventTriggerType.PointerClick
    clickEntry.callback:AddListener(handler(self, self.onSelfClick))

    self.__needleEventTrigger.triggers:Add(dragEntry)

    self.__barBgEventTrigger.triggers:Add(dragEntry)
    self.__barBgEventTrigger.triggers:Add(downEntry)
    self.__barBgEventTrigger.triggers:Add(clickEntry)
end

function TieBarView:resetHittingAngle()
    self:__updateHittingAngleAndCallback(0)
end

function TieBarView:getCurrentValue()
    return self.__value
end

function TieBarView:onSelfClick(...)
    if not self.__active and self.__activeCallback then
        self.__activeCallback("tieBar")
    end
end

function TieBarView:setActive(value)
    self.__active = value
    if value then
        self.__viewTransform.localScale = Vector3(1, 1, 1)
        self.__viewTransform.anchoredPosition = Vector2(0, 0)
    else
        -- local parentBg = self.__viewTransform.parent:GetComponent("Image")
        local x = -350
        local y = -250
        self.__viewTransform.localScale = Vector3(0.3, 0.3, 0.3)
        self.__viewTransform.anchoredPosition = Vector2(x, y)
    end
end

function TieBarView:setOnActiveCallback(callback)
    self.__activeCallback = callback
end

function TieBarView:getNeedleInfo()
    -- local info = {}
    -- local anchoredPosition = self._cross:GetComponent("RectTransform").anchoredPosition
    -- info.ax = anchoredPosition.x
    -- info.ay = anchoredPosition.y
    -- info.az = anchoredPosition.z
    -- return info
end

function TieBarView:setOnValueChangeCallback(callback)
    self.__valueChangeCb = callback
end

function TieBarView:onNeedleDrag(pointerEventData)
    local rect = self.__needleOrigin:GetComponent("RectTransform")
    local isSucc, localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(
        rect,
        pointerEventData.position,
        pointerEventData.enterEventCamera
    )
    if self.__active and isSucc then
        if localPos.x >=0 and localPos.y < 0 then
            localPos.y = 0
        elseif localPos.x < 0 and localPos.y >= 0 then
            localPos.x = 0
        end

        if localPos.x >= 0 and localPos.y >= 0 then
            local angle = LuaMath.getAngle(localPos.x, localPos.y)
            self:__updateHittingAngleAndCallback(angle)
        end
    end
end

function TieBarView:onPointerDown(pointerEventData)
    local rect = self.__needleOrigin:GetComponent("RectTransform")
    local isSucc, localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(
        rect,
        pointerEventData.position,
        pointerEventData.enterEventCamera
    )
    if self.__active and isSucc then
        if localPos.x >= 0 and localPos.y >= 0 then
            local angle = LuaMath.getAngle(localPos.x, localPos.y)
            self:__updateHittingAngleAndCallback(angle)
        end
    end
end

function TieBarView:__updateHittingAngleAndCallback(angle)
    -- 0 ~ 1 对应0到90度
    self.__value = angle / (math.pi / 2)

    local deg = math.floor(self.__value * 90)

    self.__needleTransform.localRotation = Quaternion.Euler(Vector3(0, 0, deg))
    self.__angleTxt:GetComponent("Text").text = string.format("%s°", deg)

    if self.__valueChangeCb then
        self.__valueChangeCb(self.__value)
    end
end

function TieBarView:show(...)
    self.__view.enable = true
end

function TieBarView:hide(...)
    self.__view.enable = false
end

return TieBarView
