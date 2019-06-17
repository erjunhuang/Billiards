
--简单缩放按钮，待完善
local ColorButton = class("ColorButton")

--swallow 是否吞噬
--enableMulClick 是否允许多次点击
function ColorButton:ctor(img,swallow,enableMulClick)
	swallow = (swallow == nil) and true or swallow 
	self.__swallow = swallow
	self.__enableMulClick = enableMulClick == nil and false or enableMulClick

	self.__image = img
	self.__image:setTouchEnabled(true)
	self.__image:setSwallowTouches(swallow)
	self.__image:addTouchEventListener(handler(self,self.onTouchEvent))
	self.__image:addClickEventListener(handler(self,self.onClickEvent))

end

function ColorButton:enableMulClick(enableMulClick)
	self.__enableMulClick = enableMulClick == nil and false or enableMulClick
	return self
end

function ColorButton:getNode()
	return self.__image
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
			self.delayAction_ = self.__image:performWithDelay(function( ... )
				self.__image:stopAction(self.delayAction_)
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
	self.__orgScale = self.__image:getScale() or 1
	self.__touchCallback = callback
	return self
end

function ColorButton:onClick(callback)
	self.__orgScale = self.__image:getScale() or 1
	self.__clickCallback = callback
	return self
end

function ColorButton:show()
	self.__image:show()
	return self
end

function ColorButton:hide()
	self.__image:hide()
	return self
end


return ColorButton