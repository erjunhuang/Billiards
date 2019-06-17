local scheduler = require("misc.scheduler")

local Touch = class("Touch")

local EXPORTED_METHODS = {
    "addTouchListener",
    "removeTouchListener",
    "setTouchEnabled",
    -- "setSwallowTouches",
    -- "setTouchInNode"
}

function Touch:init_()
    self.target_ = nil
    self.listener_ = nil
    self.inNode_ = true
    self.swallow_ = true 
    self.touchEnabled_ = false

    self.beganPos_ = nil
    self.movedPos_ = nil
    self.endedPos_ = nil
end


function Touch:bind(target)
    self:init_()
    nb.setmethods(target, self, EXPORTED_METHODS)
    self.target_ = target
end

function Touch:unbind(target)
    nb.unsetmethods(target, EXPORTED_METHODS)
    self:init_()
end


function Touch:addTouchListener(callback)
	self.callback_ = callback
    return self.target_
end


function Touch:removeTouchListener(doClean)
	self.callback_ = nil
	if doClean then
		self:setTouchEnabled(false)
	end
    return self.target_
end


function Touch:setClipRect(rect)
    self.clipRect_ = rect
end

function Touch:setTouchInNode(inNode)
    self.inNode_ = inNode
    return self.target_
end

function Touch:setSwallowTouches(swallow)
    self.swallow_ = swallow
    if self.listener_ then
        self.listener_:setSwallowTouches(swallow)
    end
    return self.target_
end

function Touch:setTouchEnabled(enable)
    if self.touchEnabled_ == enable then
        return self.target_
    end

    self.touchEnabled_ = enable
    if self.touchEnabled_ then
        self.listener_ = scheduler.scheduleUpdateGlobal(self.onTouchUpdate,self)
    else
        if self.listener_ then
            scheduler.unscheduleGlobal(self.listener_)
            self.listener_ = nil
        end
    end

    return self.target_

end


function Touch:onTouchUpdate()
    if Input.GetMouseButtonDown(0) then
        isTouchIng = true
        touchType = "mouse"

        self.beganPos_ = Input.mousePosition
        self.movedPos_ = self.beganPos_
        self.endedPos_ = self.beganPos_

        self:notifyTarget("Began",self.beganPos_,touchType)
        return
    end

    if Input.touchCount > 0 and (Input.GetTouch(0).phase == TouchPhase.Began)then
        isTouchIng = true
        touchType = "finger"
        self.beganPos_ = Input.GetTouch(0).position
        self.movedPos_ = self.beganPos_
        self.endedPos_ = self.beganPos_

        self:notifyTarget("Began",self.beganPos_,touchType)
        return
    end

    if isTouchIng then
        if touchType == "mouse" then
            if Input.GetMouseButtonUp(0) then
                isTouchIng = false
                touchType = "mouse"
                self.endedPos_ = Input.mousePosition

                self:notifyTarget("Ended",self.endedPos_,touchType)
                return
            end

            local movePos = Input.mousePosition
            if self.movedPos_.x ~= movePos.x or self.movedPos_.y ~= movePos.y or self.movedPos_.z ~= movePos.z then
                self.movedPos_ = movePos
                self:notifyTarget("Moved",self.movedPos_,touchType)
            end
            

        elseif touchType == "finger" then
            local phase = Input.GetTouch(0).phase
            if phase == TouchPhase.Began then
                phase = "Began"

            elseif phase == TouchPhase.Moved then  
                phase = "Moved"

            elseif phase == TouchPhase.Stationary then 
                phase = "Stationary"

            elseif phase == TouchPhase.Ended then 
                phase = "Ended"
            end

            self:notifyTarget(phase,Input.GetTouch(0).position,touchType)
        end
    end

    -- local location = touch:getLocation()
    -- local eventCode = event:getEventCode()
    -- local isTouchInNode = self:isTouchInNode(location,self.target_)
    -- if eventCode == nb.EventCode.BEGAN then
    --     local isVisible = self.target_:isVisible()
    --     local isAncestorsVisible = self:isAncestorsVisible(self.target_)
    --     local isClippingParentContainsPoint = self:isClippingParentContainsPoint(self.target_)
    --     if not isVisible or not isAncestorsVisible or not isClippingParentContainsPoint then
    --         return false
    --     end
    --     if self.inNode_ and not isTouchInNode then
    --         return false
    --     end
    --     self.isTouching_ = true
    --     self:notifyTarget(touch,event,isTouchInNode)
    --     return true
    -- elseif not self.isTouching_ then
    --     return false
    -- elseif eventCode == nb.EventCode.MOVED then

    --     self:notifyTarget(touch,event,isTouchInNode)
    -- elseif eventCode == nb.EventCode.ENDED  or eventCode == nb.EventCode.CANCELLED then
    --     self.isTouching_ = false
    --     self:notifyTarget(touch,event,isTouchInNode)
    -- end
end



function Touch:isTouchInNode(pt, node)
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


function Touch:isAncestorsVisible(node)
    if not node then
        return true
    end

    local parent = node:getParent()
    if parent and not parent:isVisible() then
        return false
    end

    return self:isAncestorsVisible(parent)
end


function Touch:isClippingParentContainsPoint(pt,node)
    if not node then
        return true
    end

    if not self.clipRect_ then
        return true
    end

    if nb.rectContainsPoint(self.clipRect_, pt) then
        return true
    end

    return false

end


function Touch:notifyTarget(touchPhase,position,touchType, ...)
    if self.callback_ then
        self.callback_(touchPhase,position,touchType, ...)
    end
end

return Touch



