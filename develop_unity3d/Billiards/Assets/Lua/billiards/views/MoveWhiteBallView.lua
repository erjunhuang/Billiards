local MoveWhiteBallView = class("MoveWhiteBallView")

function MoveWhiteBallView:ctor(ctx,view)
	self.__handview = view
	self.__ctx = ctx
	nb.bind(self,"touch")
	self:addTouchListener(handler(self,self.onTouch))
	self.__handviewPos = Vector3(0,0,0)
    self.__handview:SetActive(false)

    self.__normalImg = view.transform:Find("nomalImg")
    self.__displayImg = view.transform:Find("displayImg")



end

function MoveWhiteBallView:setEnabled(enabled,guideball,isBreak)
	self.__guideball = guideball
    self.__isBreak = isBreak
	self:setTouchEnabled(enabled)
end

function MoveWhiteBallView:onTouch(touchPhase,position,touchType)

    print("onTouch",touchPhase,position,touchType)
    if touchPhase == "Began" then
        self:onMouseDown(position)
    elseif touchPhase == "Moved" then
        self:onMouseMove(position)
    elseif touchPhase == "Ended" then
        self:onMouseUp(position)
    end
end

function MoveWhiteBallView:onMouseMove(touchPosition)
    if self.__downPos then
        local localCoord  = self:getLocalPositionByTouchPosition(touchPosition)
        local logicCoordX, logicCoordY = self:getLogicPositionByTouchPosition(touchPosition)
        if self.__isBreak then

            self.__displayImg.gameObject:SetActive(false)

            if self:checkCanMoveBallInBreakRect(touchPosition) then
                self.__handviewPos.x = localCoord.x
                self.__handviewPos.y = localCoord.y
                self.__handviewPos.z = -0.9

                self.__handview.transform.localPosition = self.__handviewPos

                self.__guideball.position.x = logicCoordX
                self.__guideball.position.y = logicCoordY
                self.__guideball:UpdateVisualBall()
            end

        else

            local canMove,disableType = self:checkCanMoveBallInTableRect(touchPosition)
            if  canMove then
                self.__displayImg.gameObject:SetActive(false)
                self.__handviewPos.x = localCoord.x
                self.__handviewPos.y = localCoord.y
                self.__handviewPos.z = -0.9

                self.__handview.transform.localPosition = self.__handviewPos

                self.__guideball.position.x = logicCoord.x
                self.__guideball.position.y = logicCoord.y
                self.__guideball:UpdateVisualBall()
            else

                
                if disableType == "table" then
                    self.__displayImg.gameObject:SetActive(false)
                elseif disableType == "ball" then
                    self.__displayImg.gameObject:SetActive(true)
                    self.__handviewPos.x = localCoord.x
                    self.__handviewPos.y = localCoord.y
                    self.__handviewPos.z = -0.9

                    self.__handview.transform.localPosition = self.__handviewPos

                    self.__guideball.position.x = logicCoord.x
                    self.__guideball.position.y = logicCoord.y
                    self.__guideball:UpdateVisualBall()
                end
                
            end
        end
    end
end


--isBreak  true:发球阶段，只在发球区域可摆球
--         false：任意球，牌桌内可摆球
function MoveWhiteBallView:checkCanMoveBallInTableRect(touchPosition)
    local logicCoordX, logicCoordY = self:getLogicPositionByTouchPosition(touchPosition)
    

    local ballArrExceptWhite = self.__ctx.tableManager.__tableData.BallArrExceptWhite
    local tableRect = self.__ctx.tableManager.__tableRect
    local len = ballArrExceptWhite.Count;
    local guideRadius = self.__guideball.radius

    -- local tableBreakRect = self.__ctx.tableManager.__tableBreadRect

    --先判断是否在桌子范围内
     if not tableRect:ContainsPoint(logicCoordX-guideRadius, logicCoordY-guideRadius) or not tableRect:ContainsPoint(logicCoordX+guideRadius, logicCoordY+guideRadius) then
        return false,"table"
     end

    local ball; -- LogicalBall
    local ballPos
    local index = 0;-- int
    while (index < len) do
        ball = ballArrExceptWhite[index];
        ballPos = ball.position

        if (logicCoordX+guideRadius > ballPos.x - guideRadius) and ( logicCoordX-guideRadius < ballPos.x + guideRadius) and 
        (logicCoordY+guideRadius > ballPos.y - guideRadius) and ( logicCoordY-guideRadius < ballPos.y + guideRadius) then
            return false,"ball"
        end
        index = index + 1;
    end


    return true

end


function MoveWhiteBallView:checkCanMoveBallInBreakRect(touchPosition)
	local logicCoordX, logicCoordY = self:getLogicPositionByTouchPosition(touchPosition)
    
    
	local ballArrExceptWhite = self.__ctx.tableManager.__tableData.BallArrExceptWhite
	-- local tableRect = self.__ctx.tableManager.__tableRect
	local len = ballArrExceptWhite.Count;
	local guideRadius = self.__guideball.radius
    local tableBreakRect = self.__ctx.tableManager.__tableBreadRect

    --先判断是否在桌子发球范围内
     if not tableBreakRect:ContainsPoint(logicCoordX-guideRadius, logicCoordY-guideRadius) or not tableBreakRect:ContainsPoint(logicCoordX+guideRadius, logicCoordY+guideRadius) then
        return false
     end

    
    return true

end


function MoveWhiteBallView:onMouseDown(touchPosition)
    local logicCoordX, logicCoordY = self:getLogicPositionByTouchPosition(touchPosition)
    local localCoord  = self:getLocalPositionByTouchPosition(touchPosition)

    print("localCoord",localCoord.x,localCoord.y)
    self._downPos = localCoord;

    local guidePos = self.__guideball.position
    local guideRadius = self.__guideball.radius

    print("localCoord",logicCoordX, logicCoordY ,guidePos.x,guidePos.y,guideRadius)

    if (logicCoordX > guidePos.x - guideRadius) and ( logicCoordX < guidePos.x + guideRadius) and 
    	(logicCoordY > guidePos.y - guideRadius) and ( logicCoordY < guidePos.y + guideRadius) then
    	print("MoveWhiteBallView:onMouseDown",localCoord.x,localCoord.y)

        self.__handview:SetActive(true)
    	self.__handviewPos.x = localCoord.x
    	self.__handviewPos.y = localCoord.y
    	self.__handviewPos.z = -0.9
 		self.__handview.transform.localPosition = self.__handviewPos

 		self.__downPos = localCoord
        self.__oldGuidePos = {x = guidePos.x,y = guidePos.y}

        self.__displayImg.gameObject:SetActive(false)



        self:notifyCallback("Began",touchPosition)
    end

end


function MoveWhiteBallView:onMouseUp(touchPosition)
    self.__downPos = nil;
    self.__handview:SetActive(false)


    if not self:checkCanMoveBallInTableRect(touchPosition) then
        local oldGuidePos = self.__oldGuidePos
        self.__guideball.position.x = oldGuidePos.x
        self.__guideball.position.y = oldGuidePos.y
        self.__guideball:UpdateVisualBall()
    end

    self.__oldGuidePos = nil


    self:notifyCallback("Ended",touchPosition)
end



function MoveWhiteBallView:notifyCallback(touchPhase,touchPosition)

    do return end
    if self.__callback then
        self.__callback(touchPhase,touchPosition)
    end
end

function MoveWhiteBallView:getLogicPositionByTouchPosition(touchPosition)
    -- print("MoveWhiteBallView:getLogicPositionByTouchPosition")
    return self.__ctx.tableManager:getLogicPositionByTouchPosition(touchPosition)
end

function MoveWhiteBallView:getLocalPositionByTouchPosition(touchPosition)
    -- print("MoveWhiteBallView:getLocalPositionByTouchPosition")
    return self.__ctx.tableManager:getLocalPositionByTouchPosition(touchPosition)
end





function MoveWhiteBallView:onCallback(callback)
    self.__callback = callback
end





return MoveWhiteBallView