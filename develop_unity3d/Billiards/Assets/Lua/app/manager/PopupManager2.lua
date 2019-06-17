-- --[[flag_standard  多个实例,每个调用  onCreate
-- 	flag_singleTop  顶部相同实例只有一个,每次调用onNewIntent,没有则创建一个调用onCreate
-- 	flag_clearTop    查找同类实例并删除同类型以上实例(包括自己)，重新创建实例调用 onCreate
-- 	flag_clearTop|flag_singleTop    查找同类实例并删除同类型以上实例，实例调用 onNewIntent
-- 	flag_clearTask  删除堆栈所有实例,栈底只有自己调用onCreate
-- 	flag_clearTask|flag_singleTop  删除堆栈所有实例,栈底只有自己调用onNewIntent
-- 	flag_clearTop|flag_singleTop    查找同类实例并删除同类型以上实例，实例调用 onNewIntent
-- 	flag_newTask 新堆栈(需要传新堆栈名字,暂不支持)
-- --]]

-- local flag_standard = 0x01
-- local flag_singleTop = 0x02
-- local flag_clearTop = 0x03
-- local flag_clearTask = 0x04


-- local Z_ORDER = 1000



-- local PopupManager = class("PopupManager")

-- function PopupManager:ctor()
--     -- 数据容器
--     self.popupStack_ = {}

--     -- zOrder
--     self.zOrder_ = 2

--     -- 视图容器
--     self.container_ = display.newNode()
--     self.container_:retain()
--     self.container_:enableNodeEvents()
--     self.container_:onNodeEvent("cleanup",handler(self,self.onContainerCleanup))

-- end


-- function PopupManager:onContainerCleanup()
-- 	if self.modal_ then
-- 	    self.modal_:removeFromParent()
-- 	    self.modal_ = nil
-- 	end

-- 	-- 移除所有弹框
-- 	for k, popupData in pairs(self.popupStack_) do
-- 	    if popupData.popup and popupData.popup:getParent() ~= nil then
-- 	        popupData.popup:removeFromParent()
-- 	    end
-- 	    self.popupStack_[k] = nil
-- 	end
-- 	self.zOrder_ = 2
-- end


-- function PopupManager:onModalTouch_(touch,event)
--     -- 获取最上层的弹框
--     local popupData = self.popupStack_[#self.popupStack_]

--     local location = touch:getLocation()
--     local eventCode = event:getEventCode()

--     if popupData and popupData.popup and popupData.popup.isAniming then
--         return
--     end

--     if eventCode == nb.EventCode.ENDED  or eventCode == nb.EventCode.CANCELLED then
--         if popupData and popupData.popup and popupData.closeWhenTouchModel then
--             self:removePopup(popupData.popup)
--         end
--     end
-- end



-- function PopupManager:addPopup(popupCls, isModal, isCentered, closeWhenTouchModel,useShowAnimation,flag)

-- 	flag = flag or flag_singleTop


-- 	if isModal == nil then isModal = true end
--     if isCentered == nil then isCentered = true end
--     if not isModal then
--         closeWhenTouchModel = false
--     elseif closeWhenTouchModel == nil then
--         closeWhenTouchModel = true
--     end

--     -- 添加模态
--     if isModal and not self.modal_ then
--         self.modal_ = display.newScale9Sprite("gamehall/res/common/modal_texture.png", 0, 0, nb.size(display.width, display.height))
--             :pos(display.cx, display.cy)
--             :addTo(self.container_)
--         self.modal_:setTouchEnabled(true)
--         self.modal_:addNodeEventListener(nb.NODE_TOUCH_EVENT, handler(self, self.onModalTouch_))
--     end

    

--     if flag == flag_standard then
--     	local popup = popupCls.new() 
--     	if type(popup.onCreate) == "function" then
--     		popup:onCreate()
--     	end
--     	table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})

--     elseif flag == flag_singleTop then
--     	local popupData = self.popupStack_[#self.popupStack_]
--     	local popup = popupData.popup
--     	if popup and iskindof(popup,popupCls.__cname) then
--     		--顶部有同类弹框，复用
--     		if type(popup.onNewInit) == "function" then
--     			popup:onNewInit()
--     		end
--     	else
--     		--顶部没有，则创建新的
--     		popup = popupCls.new() 
-- 	    	if type(popup.onCreate) == "function" then
-- 	    		popup:onCreate()
-- 	    	end
-- 	    	table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})
--     	end
--     elseif flag == flag_clearTop then
--     	local hasCls,idx = self:hasPopupCls(popupCls)
--     	local popup
--     	if hasCls and idx > 0 then
--     		self:removeTopPopupIfByIdx(idx,2)
--     		popup = popupCls.new()
--     		if type(popup.onCreate) == "function" then
-- 	    		popup:onCreate()
-- 	    	end

-- 	    	table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})

--     	else
--     		popup = popupCls.new()
--     		if type(popup.onCreate) == "function" then
-- 	    		popup:onCreate()
-- 	    	end
-- 	    	table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})

--     	end

--     elseif flag == (flag_clearTop|flag_singleTop) then
--     	local hasCls,idx = self:hasPopupCls(popupCls)
--     	if hasCls and idx > 0 then
--     		self:removeTopPopupIfByIdx(idx,1)
--     		local popupData = self.popupStack_[idx].popup
--     		local popup = popupData.popup
--     		if type(popup.onNewInit) == "function" then
-- 	    		popup:onNewInit()
-- 	    	end
--     	else
--     		local popup = popupCls.new()
--     		if type(popup.onCreate) == "function" then
-- 	    		popup:onCreate()
-- 	    	end

-- 	    	table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})
--     	end

--     elseif flag == flag_clearTask then
--     	self:removeTopPopupIfByIdx(1,2)
--     	local popup = popupCls.new()
-- 		if type(popup.onCreate) == "function" then
--     		popup:onCreate()
--     	end

--     	table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})

--     elseif flag == (flag_clearTask|flag_singleTop) then
--     	local hasCls,idx = self:hasPopupCls(popupCls)
--     	if hasCls and idx > 0 then
--     		local popupData = table.remove(self.popupStack_,idx)
--     		self:removeTopPopupIfByIdx(1,2)
--     		popupData.closeWhenTouchModel = closeWhenTouchModel
--     		popupData.isModal = isModal
--     		local popup = popupData.popup
--     		if type(popup.onNewInit) == "function" then
-- 	    		popup:onNewInit()
-- 	    	end

--     		table.insert(self.popupStack_, popupData)
--     	else
--     		self:removeTopPopupIfByIdx(1,2)
--     		local popup = popupCls.new()
--     		if type(popup.onCreate) == "function" then
-- 	    		popup:onCreate()
-- 	    	end
--     		table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})
--     	end

--     end

--     -- 居中弹框
--     if isCentered then
--         popup:pos(display.cx, display.cy)
--     end

--     -- 添加至场景
--     -- if self:hasPopup(popup) then
--     --     self:removePopup(popup)
--     -- end
--     -- table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})
--     -- if useShowAnimation ~= false then
--     --     popup:scale(0.2)
--     --     if popup.onShowed then
--     --         transition.scaleTo(popup, {time = 0.5, easing = "BACKOUT", scale = 1, onComplete=function() popup:onShowed() end})
--     --     else
--     --         transition.scaleTo(popup, {time = 0.5, easing = "BACKOUT", scale = 1})
--     --     end
--     -- end


--     if not popup:getParent()then
--         popup:addTo(self.container_, self.zOrder_)
--     end
    
--     self.zOrder_ = self.zOrder_ + 2
--     if not self.container_:getParent() then
--         self.container_:addTo(game.runningScene, Z_ORDER)
--     end
    
--     -- 更改模态的zOrder
--     if isModal then
--         self.modal_:setLocalZOrder(popup:getLocalZOrder() - 1)
--     end

--     if popup.onShowPopup then
--         popup:onShowPopup()
--     end

-- end


-- function PopupManager:addJustPopupZorder()
--     for i,v in ipairs(self.popupStack_) do
--        local popup = v.popup
--        popup:setLocalZOrder(i*2) 
--     end
-- end


-- -- 移除指定弹框
-- function PopupManager:removePopup(popup)
-- 	if popup then
--         -- 从场景移除，删除数据
--         local removePopupFunc = function()
--             popup:removeFromParent()
--             self.zOrder_ = self.zOrder_ - 2
--             local bool, index = self:hasPopup(popup)
--             table.remove(self.popupStack_, index)
--             if #self.popupStack_ == 0 then
--                 if self.modal_ then
--                     self.modal_:removeFromParent()
--                     self.modal_ = nil
--                 end
                
--                 self.container_:removeFromParent()
--             else
--                 -- 更改模态的zOrder
--                 local needModal = false
--                 for _, popupData in pairs(self.popupStack_) do
--                     if popupData.isModal then
--                         needModal = true
--                         self.modal_:setLocalZOrder(popupData.popup:getLocalZOrder() - 1)
--                         break
--                     end
--                 end
--                 if not needModal then
--                     self.modal_:removeFromParent()
--                     self.modal_ = nil
--                 end
--             end
--         end
--         if popup.onRemovePopup then
--             popup:onRemovePopup(removePopupFunc)
--         else
--             removePopupFunc()
--         end
--     end

-- end

-- -- 移除所有弹框
-- function PopupManager:removeAllPopup()
--     self.container_:removeFromParent()
-- end

-- -- Determines if a popup is contained in popup stack
-- function PopupManager:hasPopup(popup)
--     for i, popupData in ipairs(self.popupStack_) do
--         if popupData.popup == popup then
--             return true, i
--         end
--     end
--     return false, 0
-- end

-- function PopupManager:hasPopupCls(popupCls)
-- 	for i, popupData in ipairs(self.popupStack_) do
--         if popupData.popup and iskindof(popupData.popup,popupCls.__cname) then
--             return true, i
--         end
--     end
--     return false, 0
-- end

-- -- Determines if a popup is the top-most pop-up.
-- function PopupManager:isTopLevelPopUp(popup)
--     if self.popupStack_[#self.popupStack_].popup == popup then
--         return true
--     else
--         return false
--     end
-- end

-- function PopupManager:removeTopPopupIf()
--     if #self.popupStack_ > 0 then
--         local p = self.popupStack_[#self.popupStack_]
--         local backClosable = (p.popup.backClosable) and p.popup:backClosable()
--         if p.closeWhenTouchModel or backClosable then
--             self:removePopup(p.popup)
--         end
--         return true
--     end
--     return false
-- end


-- function PopupManager:removeTopPopupIfByIdx(idx,flag)
-- 	if not idx  or idx < 1 or idx > #self.popupStack_ then
-- 		return
-- 	end

-- 	if not flag or flag == 1 then
-- 		for i = #self.popupStack_,idx+1,-1 do
-- 			local p = self.popupStack_[i]
-- 	        local backClosable = (p.popup.backClosable) and p.popup:backClosable()
-- 	        -- if p.closeWhenTouchModel or backClosable then
-- 	            self:removePopup(p.popup)
-- 	        -- end
-- 		end

-- 	else
-- 		for i = #self.popupStack_,idx,-1 do
-- 			local p = self.popupStack_[i]
-- 	        local backClosable = (p.popup.backClosable) and p.popup:backClosable()
-- 	        -- if p.closeWhenTouchModel or backClosable then
-- 	            self:removePopup(p.popup)
-- 	        -- end
-- 		end
-- 	end


-- end

-- function PopupManager:removeTopPopupIf()
--     if #self.popupStack_ > 0 then
--         local p = self.popupStack_[#self.popupStack_]
--         local backClosable = (p.popup.backClosable) and p.popup:backClosable()
--         if p.closeWhenTouchModel or backClosable then
--             self:removePopup(p.popup)
--         end
--         return true
--     end
--     return false
-- end




-- return PopupManager
