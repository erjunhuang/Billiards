local TieBarView = class("TieBarView")


function TieBarView:ctor(ctx,view)

	print("TieBarView:ctor",view)
	self.__view = view
	self.__viewTransform = view:GetComponent("RectTransform")
    self.__needle = self.__view.transform:Find("needle")
    self.__needleTransform = self.__needle:GetComponent("RectTransform")
    self.__angleTxt = view.transform:Find("angleTxt")

    self.__needleOrigin = view.transform:Find("needleOrigin")
	
    self.__barBgEventTrigger = self.__view:GetComponent("EventTrigger")
    self.__needleEventTrigger = self.__needle:GetComponent("EventTrigger")

    local dragEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
    dragEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.Drag
    dragEntry.callback:AddListener(handler(self, self.onNeedleDrag))


    local downEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
    downEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerDown
    downEntry.callback:AddListener(handler(self, self.onPointerDown))

    self.__needleEventTrigger.triggers:Add(dragEntry)
    self.__barBgEventTrigger.triggers:Add(downEntry)
    self.__angleTxt:GetComponent("Text").text = "0°"


    local clickEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
    clickEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerClick
    clickEntry.callback:AddListener(handler(self, self.onSelfClick))
    self.__barBgEventTrigger.triggers:Add(clickEntry)


end


function TieBarView:onSelfClick( ... )
   if not self.__active and self.__activeCallback then
    self.__activeCallback("tieBar")
   end
end


function TieBarView:setActive(value)
  self.__active = value
  if value then
    self.__viewTransform.localScale = Vector3(1,1,1)
    self.__viewTransform.anchoredPosition = Vector2(0,0)
  else

    -- local parentBg = self.__viewTransform.parent:GetComponent("Image")
    local x = -350
    local y = -250
    self.__viewTransform.localScale = Vector3(0.3,0.3,0.3)
    self.__viewTransform.anchoredPosition = Vector2(x,y)
  end

end

function TieBarView:onActiveCallback(callback)
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


function TieBarView:onValueChange(callback)
   self.__valueChangeCb = callback
end


function TieBarView:onNeedleDrag(pointerEventData)
    local rect = self.__needleOrigin:GetComponent("RectTransform")
   local isSucc,localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(rect,pointerEventData.position,pointerEventData.enterEventCamera)
   if self.__active and isSucc then
   		if localPos.x >=0 and localPos.y >= 0 then
   			local angle = math.atan(localPos.y/localPos.x)
			local deg  = math.floor(angle * 180 / math.pi);
			self.__needleTransform.localRotation = Quaternion.Euler(Vector3(0, 0, deg))

			self.__angleTxt:GetComponent("Text").text = string.format("%s°",deg)
        if self.__valueChangeCb then
          self.__valueChangeCb(deg)
        end

   		end
   end
end


function TieBarView:onPointerDown(pointerEventData)


   local rect = self.__needleOrigin:GetComponent("RectTransform")
   local isSucc,localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(rect,pointerEventData.position,pointerEventData.enterEventCamera)
   if self.__active and isSucc then
       	if localPos.x >=0 and localPos.y >= 0 then
   			local angle = math.atan(localPos.y/localPos.x)
			local deg  = math.floor(angle * 180 / math.pi);


			self.__needleTransform.localRotation = Quaternion.Euler(Vector3(0, 0, deg))
			self.__angleTxt:GetComponent("Text").text = string.format("%s°",deg)

      if self.__valueChangeCb then
          self.__valueChangeCb(deg)
      end

   		end
   end
end




function TieBarView:show( ... )
	self.__view.enable = true
end



function TieBarView:hide( ... )
	self.__view.enable = false
end







return TieBarView