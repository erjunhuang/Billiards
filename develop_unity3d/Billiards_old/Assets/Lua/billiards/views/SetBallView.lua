local WhiteBallView = import(".WhiteBallView")
local TieBarView = import(".TieBarView")

local SetBallView = class("SetBallView")

function SetBallView:ctor(ctx,view)
	self.__view = view
	self.__ctx = ctx
	local tiebarView = view.transform:Find("tiebarView")
	self.__tieBarView = TieBarView.new(ctx,tiebarView)
	local whiteBallView = view.transform:Find("whiteBallView")
	self.__whiteBallView = WhiteBallView.new(ctx,whiteBallView)

	self.__tieBarView:onActiveCallback(handler(self,self.onActiveCb))
	self.__whiteBallView:onActiveCallback(handler(self,self.onActiveCb))

	self.__tieBarView:setActive(false)
	self.__whiteBallView:setActive(true)

	self.__whiteBallView:onValueChange(handler(self,self.onCrossPosSet))

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

function SetBallView:onCrossPosSet(localX,localY)
	local bigRadius = 193
	local smallRadius = 30
	local radio = smallRadius/bigRadius
	local tx = localX * radio
	local ty = localY * radio
	local cueAngleBtn = self.__ctx.scene.cueAngleBtn
	local cross = cueAngleBtn.transform:Find("cross")
	cross:GetComponent("RectTransform").anchoredPosition = Vector2(tx,ty)

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