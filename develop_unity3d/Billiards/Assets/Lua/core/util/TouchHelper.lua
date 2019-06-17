
local TouchHelper = class("TouchHelper")


function TouchHelper:ctor(target, callback,swallow,inNode)
    self.callback_ = callback
    self.target_ = target
    self.inNode_ = (inNode == nil) and true or inNode
    self.swallow_ = (swallow == nil) and true or swallow

    self.touchEnabled_ = false
    self:setTouchEnabled(true)
end


function TouchHelper:setTouchEnabled(enable)
    if self.touchEnabled_ == enable then
        return
    end
    self.touchEnabled_ = enable
    if self.touchEnabled_ then
        self.listener_ = nb.EventListenerTouchOneByOne:create()
        self.listener_:setSwallowTouches(self.swallow_)
        self.listener_:registerScriptHandler(handler(self,self.onTouch),nb.Handler.EVENT_TOUCH_BEGAN )
        self.listener_:registerScriptHandler(handler(self,self.onTouch),nb.Handler.EVENT_TOUCH_MOVED )
        self.listener_:registerScriptHandler(handler(self,self.onTouch),nb.Handler.EVENT_TOUCH_ENDED )
        self.listener_:registerScriptHandler(handler(self,self.onTouch),nb.Handler.EVENT_TOUCH_CANCELLED )
        local eventDispatcher = self.target_:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(self.listener_, self.target_)

    else
        local eventDispatcher = self.target_:getEventDispatcher()
        eventDispatcher:removeEventListener(self.listener_)
        self.listener_ = nil
    end

end


function TouchHelper:onTouch(touch,event)
    local location = touch:getLocation()
    local eventCode = event:getEventCode()
    local isTouchInNode = self:isTouchInNode(location,self.target_)
    if eventCode == nb.EventCode.BEGAN then
        local isVisible = self.target_:isVisible()
        local isAncestorsVisible = self:isAncestorsVisible(self.target_)
        if not isVisible or not isAncestorsVisible then
            return false
        end
        if self.inNode_ and not isTouchInNode then
            return false
        end
        self.isTouching_ = true
        self:notifyTarget(touch,event)
        return true
    elseif not self.isTouching_ then
        return false
    elseif eventCode == nb.EventCode.MOVED then

        self:notifyTarget(touch,event,isTouchInNode)
    elseif eventCode == nb.EventCode.ENDED  or eventCode == nb.EventCode.CANCELLED then
        self.isTouching_ = false
        self:notifyTarget(touch,event,isTouchInNode)
    end
end



function TouchHelper:isTouchInNode(pt, node)
    local s = node:getContentSize()
    local rect
    if s.width == 0 or s.height == 0 then
        rect = nb.utils_:getCascadeBoundingBox(node)
    else
        pt = node:convertToNodeSpace(pt)
        rect = nb.rect(0, 0, s.width, s.height)
    end

    if nb.rectContainsPoint(rect, pt) then
        return true
    end
    return false
end


function TouchHelper:isAncestorsVisible(node)
    if not node then
        return true
    end

    local parent = node:getParent()
    if parent and not parent:isVisible() then
        return false
    end

    return self:isAncestorsVisible(parent)
end


function TouchHelper:notifyTarget(touch,event, ...)
    if self.callback_ then
        self.callback_(touch,event, ...)
    end
end

return TouchHelper