local WhiteBallView = class("WhiteBallView")

function WhiteBallView:ctor(ctx,view)
	self.__view = view
	self.__viewTransform = view:GetComponent("RectTransform")
    self._cross = view.transform:Find("cross")
	-- self._radius
	self._radius = 193--self._ball:GetComponent("RectTransform").rect.width / 2;
	self._radiusX2 = self._radius * self._radius;

	print("self._radius",self._radius)
	print("self._radiusX2",self._radiusX2)


    self.__ballEventTrigger = self.__view:GetComponent("EventTrigger")
    self.__crossEventTrigger = self._cross:GetComponent("EventTrigger")
    -- print("cuePowerSlider eventTrigger => ", self.__eventTrigger)

    local dragEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
    dragEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.Drag
    dragEntry.callback:AddListener(handler(self, self.onCrossDrag))

    local downEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
    downEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerDown
    downEntry.callback:AddListener(handler(self, self.onPointerDown))

    local clickEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
    clickEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerClick
    clickEntry.callback:AddListener(handler(self, self.onSelfClick))


    self.__crossEventTrigger.triggers:Add(dragEntry)
    self.__ballEventTrigger.triggers:Add(downEntry)
    self.__ballEventTrigger.triggers:Add(clickEntry)


    -- self:setActive(false)

end


function WhiteBallView:onValueChange(callback)
   self.__valueChangeCb = callback
end


function WhiteBallView:onSelfClick( ... )

  print("WhiteBallView:onSelfClick")
   if not self.__active and self.__activeCallback then
    self.__activeCallback("whiteBall")
   end
end




function WhiteBallView:setActive(value)
  self.__active = value
  if value then
    self.__viewTransform.localScale = Vector3(1,1,1)
    self.__viewTransform.anchoredPosition = Vector2(0,0)
  else

    -- local parentBg = self.__viewTransform.parent:GetComponent("Image")
    local x = 350
    local y = -250
    self.__viewTransform.localScale = Vector3(0.3,0.3,0.3)
    self.__viewTransform.anchoredPosition = Vector2(x,y)
  end

end

function WhiteBallView:onActiveCallback(callback)
   self.__activeCallback = callback
end



function WhiteBallView:getBallInfo()
    local info = {}
    local anchoredPosition = self._cross:GetComponent("RectTransform").anchoredPosition
    info.ax = anchoredPosition.x
    info.ay = anchoredPosition.y
    info.az = anchoredPosition.z

    return info
end


function WhiteBallView:onCrossDrag(pointerEventData)
    local rect = self.__view:GetComponent("RectTransform")
   local isSucc,localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(rect,pointerEventData.position,pointerEventData.enterEventCamera)
   if self.__active and isSucc then
     if ((localPos.x * localPos.x + localPos.y * localPos.y) < self._radiusX2) then
         self._cross:GetComponent("RectTransform").anchoredPosition = localPos;
        if self.__valueChangeCb then
           self.__valueChangeCb(localPos.x,localPos.y)
        end
     end
   end
end


function WhiteBallView:onPointerDown(pointerEventData)
   local rect = self.__view:GetComponent("RectTransform")
   local isSucc,localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(rect,pointerEventData.position,pointerEventData.enterEventCamera)
   if self.__active and isSucc then
     if ((localPos.x * localPos.x + localPos.y * localPos.y) < self._radiusX2) then
         self._cross:GetComponent("RectTransform").anchoredPosition = localPos;
        if self.__valueChangeCb then
          self.__valueChangeCb(localPos.x,localPos.y)
        end
     end
   end
end



return WhiteBallView