

local ColorButton = class("ColorButton",function(img)
	if string.byte(img) == 35 then
		return ccui.ImageView:create(string.sub(img, 2), 1)
	else
		return ccui.ImageView:create(img)
	end

end)


--swallow 是否吞噬
--enableMulClick 是否允许多次点击
function ColorButton:ctor(img,swallow,enableMulClick)
	swallow = (swallow == nil) and true or swallow 
	self.__swallow = swallow
	self.__enableMulClick = enableMulClick == nil and false or enableMulClick

	self:setTouchEnabled(true)
	self:setSwallowTouches(swallow)
	self:addTouchEventListener(handler(self,self.onTouchEvent))
	self:addClickEventListener(handler(self,self.onClickEvent))

end

function ColorButton:enableMulClick(enableMulClick)
	self.__enableMulClick = enableMulClick == nil and false or enableMulClick
	return self
end

function ColorButton:onClickEvent(sender)
	if self.__enableMulClick then
		if self.__clickCallback then
			self.__clickCallback(sender)
		end
		return 
	else
		--响应第一次
		if not self.delayAction_ then
			if self.__clickCallback then
				self.__clickCallback(sender)
			end
			self.delayAction_ = self:performWithDelay(function( ... )
				self:stopAction(self.delayAction_)
				self.delayAction_ = nil
			end,0.2)
		end
	end
end

function ColorButton:onTouchEvent(sender, eventType)
	local w = sender
	if eventType == ccui.TouchEventType.began then
		w:setColor(nb.c3b(128,128,128))
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		w:setColor(nb.c3b(255,255,255))
	end
	if self.__touchCallback then
		self.__touchCallback(sender,eventType)
	end
end

function ColorButton:onTouch(callback)
	self.__orgScale = self:getScale() or 1
	self.__touchCallback = callback
	return self
end

function ColorButton:onClick(callback)
	self.__orgScale = self:getScale() or 1
	self.__clickCallback = callback
	return self
end


return ColorButton
