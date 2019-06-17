local WhiteBallView = import(".WhiteBallView")
local TieBarView = import(".TieBarView")

--- 击球点与高低杆组合
local SetBallView = class("SetBallView")

function SetBallView:ctor(ctx,view)
	self.__view = view
	self.__ctx = ctx
	local tiebarView = view.transform:Find("tiebarView")
	self.__tieBarView = TieBarView.new(ctx,tiebarView)
	local whiteBallView = view.transform:Find("whiteBallView")
	self.__whiteBallView = WhiteBallView.new(ctx,whiteBallView)

	self.__tieBarView:setOnActiveCallback(handler(self,self.onActiveCb))
	self.__whiteBallView:setOnActiveCallback(handler(self,self.onActiveCb))

	self.__tieBarView:setActive(false)
	self.__whiteBallView:setActive(true)

	self.__whiteBallView:setOnValueChangeCallback(handler(self, self.__onHittingPointValueChange))
	self.__tieBarView:setOnValueChangeCallback(handler(self, self.__onHittingAngleValueChange))

	self.__viewEventTrigger = self.__view:GetComponent("EventTrigger")

	local downEntry = CS.UnityEngine.EventSystems.EventTrigger.Entry()
    downEntry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerDown
    downEntry.callback:AddListener(handler(self, self.onPointerDown))

    self.__viewEventTrigger.triggers:Add(downEntry)


end



function SetBallView:onPointerDown(pointerEventData)
   self:hideView()
end


function SetBallView:onActiveCb(ctype)
	if ctype == "tieBar" then
		self.__tieBarView:setActive(true)
		self.__whiteBallView:setActive(false)
	elseif ctype == "whiteBall" then
		self.__tieBarView:setActive(false)
		self.__whiteBallView:setActive(true)
	end
end

function SetBallView:__onHittingPointValueChange(valueX, valueY)
	print("SetBallView:__onHittingPointValueChange => ", valueX, valueY)
	local radius = 30
	local cueAngleBtn = self.__ctx.scene.cueAngleBtn
	local cross = cueAngleBtn.transform:Find("cross")
	cross:GetComponent("RectTransform").anchoredPosition = Vector2(radius * valueX, radius * valueY)
end

function SetBallView:__onHittingAngleValueChange(value)
	print("SetBallView:__onHittingAngleValueChange => ", value)
end


function SetBallView:showView()
	self.__view.gameObject:SetActive(true)
	self.__tieBarView:setActive(false)
	self.__whiteBallView:setActive(true)
end

function SetBallView:hideView( ... )
	self.__view.gameObject:SetActive(false)
end




return SetBallView