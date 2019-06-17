
local PopupManager = class("PopupManager")
local path = "gamehall/res/common/"
local Z_ORDER = 1000

PopupManager.DEFAULT_SHOW_ANIMATION1 = {startStates={setColor=nb.c3b(0,0,0)},transitionFunc="tintTo",transitionArgs={time = 0.3, color=nb.c3b(255,255,255)}}
PopupManager.DEFAULT_SHOW_ANIMATION2 = {startStates={["scale"]=0.5},transitionFunc="scaleTo",transitionArgs={time = 0.3, scale = 1, easing="BACKOUT"}}
PopupManager.DEFAULT_SHOW_ANIMATION3 = {startStates={["scale"]=0.01},transitionFunc="scaleTo",transitionArgs={time = 0.3, scale = 1, easing="BACKOUT"}}
PopupManager.DEFAULT_SHOW_ANIMATION4 = {startStates={setPositionY=display.sheight*3/2},transitionFunc="moveTo",transitionArgs={time = 0.3, y = display.sheight/2, easing="BACKOUT"}}

PopupManager.DEFAULT_HIDE_ANIMATION1 = {startStates=nil,transitionFunc="scaleTo",transitionArgs={time = 0.3, scale = 0.5, easing="BACKIN"}}
PopupManager.DEFAULT_HIDE_ANIMATION2 = {startStates=nil,transitionFunc="tintTo",transitionArgs={time = 0.2, color=nb.c3b(0,0,0)}, 
                                        endStates={setOpacity=255},endFunc="fadeTo",endArgs={time = 0.2, opacity=0}}
PopupManager.DEFAULT_HIDE_ANIMATION3 = {startStates={setOpacity=255},transitionFunc="fadeTo",transitionArgs={time = 0.3, opacity=50}}
PopupManager.DEFAULT_HIDE_ANIMATION4 = {startStates=nil,transitionFunc="moveTo",transitionArgs={time = 0.3, y = display.sheight*3/2, easing="BACKOUT"}}

function PopupManager:ctor()
    -- 数据容器
    self.popupStack_ = {}

    -- 视图容器
    self.container_ = display.newNode()
    self.container_:retain()
    self.container_:enableNodeEvents()
    self.container_.nodeCleanup_ = true
    self.container_.onCleanup = handler(self, function (obj)
        -- 移除模态
        if obj.modal_ then
            obj.modal_:removeFromParent()
            obj.modal_ = nil
        end

        -- 移除所有弹框
        for k, popupData in pairs(obj.popupStack_) do
            if popupData.popup and popupData.popup:getParent() ~= nil then
                popupData.popup:removeFromParent()
            end
            obj.popupStack_[k] = nil
        end
        self.zOrder_ = 2
    end)

    self.viewEffectBg_ = display.newScale9Sprite(path.."common_view_effect_bg.png", 0, 0, nb.size(display.width, display.height))
            :pos(display.cx, display.cy)
            :addTo(self.container_)
            :hide()
    -- zOrder
    self.zOrder_ = 2
end

function PopupManager:onModalTouch_(touch,event)
    -- 获取最上层的弹框
    local popupData = self.popupStack_[#self.popupStack_]

    local location = touch:getLocation()
    local eventCode = event:getEventCode()

    if popupData and popupData.popup and popupData.popup.isAniming then
        return
    end

    if eventCode == nb.EventCode.ENDED  or eventCode == nb.EventCode.CANCELLED then
        if popupData and popupData.popup and popupData.closeWhenTouchModel then
            -- game.SoundManager:playSound(game.SoundManager.CLOSE_BUTTON)
            self:removePopup(popupData.popup)
        end
    end

    
end

-- 添加一个弹框
-- useShowAnimation 是否播放动画
-- animationArgs 动画参数
-- ingoreKinds是否忽略相同类型的弹框(true:可以弹多个同一类型的弹框)
function PopupManager:addPopup(popup, isModal, isCentered, closeWhenTouchModel, useShowAnimation, animationArgs, ingoreKind)

    local hasSameKing,oldIdx = self:hasSameKindPopup(popup)
    if not ingoreKind and hasSameKing then
        if popup.onCleanup then
            popup:onCleanup()
        end
        local oldPopupData = table.remove(self.popupStack_,oldIdx)
        oldPopupData.closeWhenTouchModel = closeWhenTouchModel
        oldPopupData.isModal = isModal
        if oldPopupData and oldPopupData.popup then
            table.insert(self.popupStack_,oldPopupData)
            -- oldPopupData.popup:setLocalZOrder(self.zOrder_)
            -- if isModal then
            --     self.modal_:setLocalZOrder(oldPopupData.popup:getLocalZOrder() - 1)
            -- end
            self:adjustZorder()
            self:adjustModalZorder()
        end
        return
    end

    if isModal == nil then isModal = true end
    if isCentered == nil then isCentered = true end
    animationArgs = animationArgs or PopupManager.DEFAULT_SHOW_ANIMATION2
    if not isModal then
        closeWhenTouchModel = false
    elseif closeWhenTouchModel == nil then
        closeWhenTouchModel = true
    end

    -- 添加模态
    if isModal and not self.modal_ then
        self.modal_ = display.newScale9Sprite(path.."common_view_effect_bg1.png", 0, 0, nb.size(display.width, display.height))
            :pos(display.cx, display.cy)
            :opacity(210)
            :addTo(self.container_)
            :setCascadeOpacityEnabled(true)
        nb.bind(self.modal_,"touch")
        :setTouchEnabled(true)
        :addTouchListener(handler(self,self.onModalTouch_))

    end

    -- 居中弹框
    if isCentered then
        popup:pos(display.cx, display.cy)
    end

    -- 添加至场景
    if self:hasPopup(popup) then
        self:removePopup(popup)
    end
    table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})
    if useShowAnimation ~= false then
        if animationArgs.startStates then   
            for func, params in pairs(animationArgs.startStates) do
                popup[func](popup, type(params) == "table" and table.unpack(params) or params)
            end
        end
        if animationArgs.transitionFunc then
            local params = clone(animationArgs.transitionArgs)
            popup.isAniming = true
            if popup.onShowed then
                params.onComplete = function() popup.isAniming = false;popup:onShowed() end
                transition[animationArgs.transitionFunc](popup,params)
            else
                params.onComplete = function() popup.isAniming = false end
                transition[animationArgs.transitionFunc](popup,params)
            end
        end
    end
    popup:addTo(self.container_, self.zOrder_)
    self.zOrder_ = self.zOrder_ + 2
    if not self.container_:getParent() then
        self.container_:addTo(game.runningScene, Z_ORDER)
        self.viewEffectBg_:hide()
    end
    
    self:adjustZorder()

    -- 更改模态的zOrder
    if isModal then
        -- self.modal_:setLocalZOrder(popup:getLocalZOrder() - 1)
        self:adjustModalZorder()
    end

    if popup.onShowPopup then
        popup:onShowPopup()
    end

end

-- 移除指定弹框
-- useHideAnimation true or false 是否播放动画
-- animationArgs动画参数
function PopupManager:removePopup(popup,useHideAnimation,animationArgs)
    if popup then
        animationArgs = animationArgs or PopupManager.DEFAULT_HIDE_ANIMATION1
        -- 从场景移除，删除数据
        self.zOrder_ = self.zOrder_ - 2
        -- if self.zOrder_ < 2 then
        --     self.zOrder_ = 2
        -- end
        local removePopupFunc = function()
            popup:removeFromParent()
            -- self.zOrder_ = self.zOrder_ - 2
            local bool, index = self:hasPopup(popup)
            table.remove(self.popupStack_, index)

            self:adjustZorder()

            if #self.popupStack_ == 0 then
                if self.modal_ then
                    self.modal_:removeFromParent()
                    self.modal_ = nil
                end
                
                if animationArgs.endFunc then
                    for func,params in pairs(animationArgs.endStates) do
                        self.viewEffectBg_[func](self.viewEffectBg_,params)
                    end
                    self.viewEffectBg_:show()
                    local params = clone(animationArgs.endArgs)
                    params.onComplete = function()
                            self.viewEffectBg_:hide()
                            self.container_:removeFromParent()
                        end
                    transition[animationArgs.endFunc](self.viewEffectBg_, params)
                else
                    self.container_:removeFromParent()
                end
            else

                --更改模态的zOrder
                local needModal = self:adjustModalZorder()
                -- for i=#self.popupStack_,1,-1 do
                --     local popupData = self.popupStack_[i]
                --     if popupData and popupData.isModal then
                --         needModal = true
                --         self.modal_:setLocalZOrder(popupData.popup:getLocalZOrder() - 1)
                --         break
                --     end
                -- end

                if not needModal then
                    if self.modal_ then
                        self.modal_:removeFromParent()
                        self.modal_ = nil
                    end
                end

                -- 更改模态的zOrder
                -- local needModal = false
                -- for _, popupData in pairs(self.popupStack_) do
                --     if popupData.isModal then
                --         needModal = true
                --         self.modal_:setLocalZOrder(popupData.popup:getLocalZOrder() - 1)
                --         break
                --     end
                -- end
                -- if not needModal then
                --     if self.modal_ then
                --         self.modal_:removeFromParent()
                --         self.modal_ = nil
                --     end
                -- end
            end

            
        end

        if useHideAnimation ~= false then
            -- 有动画
            if animationArgs.startStates then
                for func, params in pairs(animationArgs.startStates) do
                    popup[func](popup, type(params) == "table" and table.unpack(params) or params)
                end
            end
            if animationArgs.transitionFunc then
                local position = popup:convertToNodeSpace(nb.p(0, 0))
                local layer = display.newLayer(nb.c4b(0,0,0,0))
                :addTo(popup)
                :pos(position.x, position.y)
                nb.bind(layer,"touch"):setTouchEnabled(true)
                local params = clone(animationArgs.transitionArgs)
                if popup.onRemovePopup then
                    params.onComplete = function() popup:onRemovePopup(removePopupFunc) end
                    transition[animationArgs.transitionFunc](popup,params)
                else
                    params.onComplete = function() removePopupFunc() end
                    transition[animationArgs.transitionFunc](popup,params)
                end
            end
        else
            -- 无动画
            if popup.onRemovePopup then
                popup:onRemovePopup(removePopupFunc)
            else
                removePopupFunc()
            end
        end
    end
end

-- 移除所有弹框
function PopupManager:removeAllPopup()
    self.container_:removeFromParent()
end

-- Determines if a popup is contained in popup stack
function PopupManager:hasPopup(popup)
    for i, popupData in ipairs(self.popupStack_) do
        if popupData.popup == popup then
            return true, i
        end
    end
    return false, 0
end



 --修正层级
function PopupManager:adjustZorder( ... )
    for i,v in ipairs(self.popupStack_) do
        if v and v.popup and v.popup:getLocalZOrder() ~= i*2 then
            v.popup:setLocalZOrder(i*2)
        end
    end
end


 --修正层级
function PopupManager:adjustModalZorder()
    --更改模态的zOrder
    local needModal = false
    for i=#self.popupStack_,1,-1 do
        local popupData = self.popupStack_[i]
        if popupData and popupData.isModal then
            needModal = true
            self.modal_:setLocalZOrder(popupData.popup:getLocalZOrder() - 1)
            break
        end
    end

    return needModal
end

--是否有同一个相同类型的弹框
function PopupManager:hasSameKindPopup(popup)
    for i, popupData in ipairs(self.popupStack_) do
        if popupData.popup.__cname == popup.__cname then
            return true, i
        end
    end
    return false,0
end

function PopupManager:getKindPopup(popup)
    for i, popupData in ipairs(self.popupStack_) do
        if popupData.popup.__cname == popup.__cname then
            return popupData.popup
        end
    end
    return nil
end

-- Determines if a popup is the top-most pop-up.
function PopupManager:isTopLevelPopUp(popup)
    if self.popupStack_[#self.popupStack_].popup == popup then
        return true
    else
        return false
    end
end


function PopupManager:hasSameKindPopupCls(popupCls)
    for i, popupData in ipairs(self.popupStack_) do
        if popupData.popup.__cname == popupCls.__cname then
            return true, i
        end
    end
    return false,0
end


function PopupManager:removeTopPopupIf()
    if #self.popupStack_ > 0 then
        local p = self.popupStack_[#self.popupStack_]
        local backClosable = (p.popup.backClosable) and p.popup:backClosable()
        if p.closeWhenTouchModel or backClosable then
            self:removePopup(p.popup)
        end
        return true
    end
    return false
end

function PopupManager:removeAfterPopupByIndex(index)
    if #self.popupStack_ > 0 and index < #self.popupStack_ then
        for i=#self.popupStack_,index,-1 do
            local p = self.popupStack_[i]
            local backClosable = (p.popup.backClosable) and p.popup:backClosable()
            if p.closeWhenTouchModel or backClosable then
                self:removePopup(p.popup)
            end
        end
    end
end

function PopupManager:dispose()
    if self.container_:getParent() then
        self.container_:removeSelf()
    end
    self.container_:release()
    self.container_ = nil

end

return PopupManager