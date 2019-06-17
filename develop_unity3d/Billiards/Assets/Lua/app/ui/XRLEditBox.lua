local ccui_TextField = ccui.TextField

local XRLEditBox = class("XRLEditBox",function(...)
	return ccui_TextField:create(...) 
end)

function XRLEditBox:ctor(...)
	self:enableNodeEvents()
	luaoc.callStaticMethod("XRLTextFelid", "startListenTextField", nil)
end

local tmpSetConentStize = nb.Node.setContentSize
function XRLEditBox:setContentSize(size)
	tmpSetConentStize(self,size)
	self:createCover(size)
	return self
end

local tmpSetTextAreaSize = ccui_TextField.setTextAreaSize
function XRLEditBox:setTextAreaSize(size)
	tmpSetTextAreaSize(self,size)
	self:createCover(size)
	return self
end

-- local tmpSetPosition = nb.Node.setPosition
-- function XRLEditBox:setPosition( ... )
-- 	tmpSetPosition(self,...)
-- 	if not tolua.isnull(self.__corver) then
-- 		local size = self:getContentSize()
-- 		local x, y = self:getPosition()
-- 		self.__corver:setPosition(nb.p(x - size.width/2,y))
-- 	end
-- 	return self
-- end


-- local tmpPos= nb.Node.pos
-- function XRLEditBox:pos( ... )
-- 	tmpPos(self,...)
-- 	if not tolua.isnull(self.__corver) then
-- 		local x, y = self:getPosition()
-- 		local size = self:getContentSize()
-- 		self.__corver:setPosition(nb.p(x - size.width/2,y))
-- 	end
-- 	return self
-- end

-- local tt = XRLEditBox.addEventListener
function XRLEditBox:addEventListener( callback )
	self.callback = callback
	return self
end

function XRLEditBox:attachWithIME( ... )
	self:setAttachWithIME(false)
	return self
end

function XRLEditBox:createCover( size )
	if not self.__corver then
		self.__corver = display.newLayer()
		self.__corver:addTo(self)
		local zorder = self:getLocalZOrder()
		self.__corver:setLocalZOrder(zorder)
	end
	
	self.__corver:setContentSize(size)
	-- self.__corver:setPosition(nb.p(size.width/2,size.height/2))
    nb.bind(self.__corver,"touch")
    :setTouchEnabled(true)
    :addTouchListener(function (touch,event,isTouchInSprite )
		local eventType = event:getEventCode()
		if eventType == nb.EventCode.BEGAN then
		   --开始点击
		elseif eventType == nb.EventCode.MOVED then
			--移动
		elseif eventType == nb.EventCode.ENDED  or eventType == nb.EventCode.CANCELLED then
		   --取消或者结束　
			local text = self:getString()
			luaoc.callStaticMethod("XRLTextFelid", "showKeyBoard", {text = text,callback = function ( json )
					local text = json.text
				self:setString(text)
				if self.callback then
					self.callback(self)
				end
			end})
		end
    end)
  	return self
end

function XRLEditBox:onCleanup( ... )
	luaoc.callStaticMethod("XRLTextFelid", "stopListenTextField", nil)
	return self
end

return XRLEditBox