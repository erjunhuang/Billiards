local ScaleButton = class("ScaleButton",function(img)
	if string.byte(img) == 35 then
		return ccui.ImageView:create(string.sub(img, 2), 1)
	else
		return ccui.ImageView:create(img)
	end
end)

ScaleButton.SCALE_TYPE_SMALL = 1
ScaleButton.SCALE_TYPE_BIG = 2 

--swallow 是否吞噬
--scale 缩放系数
--enableMulClick 是否允许多次点击
function ScaleButton:ctor(img,scale,swallow,enableMulClick)
	swallow = (swallow == nil) and true or swallow
	self.__swallow = swallow
	self.__scale = scale or 1.1
	self.__enableMulClick = enableMulClick == nil and false or enableMulClick

	self.scaleType = ScaleButton.SCALE_TYPE_BIG
	if self.__scale < 1 then
		self.scaleType = ScaleButton.SCALE_TYPE_SMALL
	end
	self:setTouchEnabled(true)
	self:setSwallowTouches(swallow)
	self:addTouchEventListener(handler(self,self.onTouchEvent))
	self:addClickEventListener(handler(self,self.onClickEvent))
end

function ScaleButton:enableMulClick(enableMulClick)
	self.__enableMulClick = enableMulClick == nil and false or enableMulClick
	return self
end


function ScaleButton:onClickEvent(sender)
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

function ScaleButton:onTouchEvent(sender, eventType)
	local w = sender
	if eventType == ccui.TouchEventType.began then
		transition.scaleTo(w, {scale = self.__scale, time = 0.1})
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		transition.scaleTo(w, {scale = self.__orgScale, time = 0.1})
	end
	if self.__touchCallback then
		self.__touchCallback(sender,eventType)
	end
end

function ScaleButton:onTouch(callback)
	self.__orgScale = self:getScale() or 1
	self.__touchCallback = callback
	return self
end

function ScaleButton:onClick(callback)
	self.__orgScale = self:getScale() or 1
	self.__clickCallback = callback
	return self
end

return ScaleButton