local PowerSlider = class("PowerSlider")

function PowerSlider:ctor(view)
	self.__view = view

	-- print("PowerSlider",view)
	self.__slider = self.__view:GetComponent("Slider")
	self.__slider.onValueChanged:AddListener(handler(self,self.onValueChanged))

	self.__eventTrigger = self.__view:GetComponent("EventTrigger")
	-- print("cuePowerSlider eventTrigger => ", self.__eventTrigger)

	local upEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
	upEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerUp
	upEntry.callback:AddListener(handler(self, self.onPointerUp))

	local downEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
	downEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerDown
	downEntry.callback:AddListener(handler(self, self.onPointerDown))

	self.__eventTrigger.triggers:Add(upEntry)
	self.__eventTrigger.triggers:Add(downEntry)

end


function PowerSlider:setEnabled(enabled)
	self.__slider.gameObject:SetActive(enabled)
end

function PowerSlider:getCurrentValue()
	return self.__slider.value
end

function PowerSlider:setOnPointerUpCallback(callback)
	self.__onPointerUpCallback = callback
end

function PowerSlider:onPointerUp(pointerEventData)
	if self.__onPointerUpCallback then
		self.__onPointerUpCallback(pointerEventData)
	end
end

function PowerSlider:setOnPointerDownCallback(callback)
	self.__onPointerDownCallback = callback
end

function PowerSlider:onPointerDown(pointerEventData)
	if self.__onPointerDownCallback then
		self.__onPointerDownCallback(pointerEventData)
	end
end

function PowerSlider:setOnValueChangedCallback(callback)
	self.__onValueChangedCallback = callback
end

function PowerSlider:onValueChanged(...)
	if self.__onValueChangedCallback then
		self.__onValueChangedCallback(self.__slider.value)
	end
end

return PowerSlider
