

local Panel = class("Panel",nb.load("mvc").ViewBase)

Panel.SIZE_SMALL = {} 
Panel.SIZE_NORMAL = {750, 480}
Panel.SIZE_LARGE = {}
Panel.COLOR_NORMAL = nb.c3b(15,109,181)
function Panel:ctor(size)
    if size then
        self.__width, self.__height = size[1], size[2]
    end
    -- self.__width, self.__height = size[1], size[2]
    Panel.super.ctor(self)
    -- self.background_ = display.newScale9Sprite("#common_panel_bg.png", 0, 0, nb.size(self.width_, self.height_)):addTo(self)
    -- self.background_:setTouchEnabled(true)
    -- self.background_:setTouchSwallowEnabled(true)
    -- self.backgroundTex_ = display.newTilesSprite("repeat/panel_repeat_tex.png", nb.rect(0, 0, self.width_ - 3, self.height_ - 3))
    --     :pos(-(self.width_ - 3) * 0.5, -(self.height_ - 3) * 0.5)
    --     :addTo(self)
    -- 默认的弹窗管理
    self.__popupManager = game.PopupManager
end

function Panel:addCloseBtn()
    -- if not self.closeBtn_ then
    --     self.closeBtn_ = nb.ui.UIPushButton.new({normal = "#common_panel_close_btn_up.png", pressed="#common_panel_close_btn_down.png"})
    --         :pos(self.width_ * 0.5 - 15, self.height_ * 0.5 - 22)
    --         :onButtonClicked(function() 
    --                 self:onClose()
    --                 game.SoundManager:playSound(2)
    --             end)
    --         :addTo(self, 9)
    -- end
end


function Panel:backClosable()
    return false
end

function Panel:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation, animationArgs, ingoreKind)
    if not self.__popupManager then
        -- 容错处理   防止没有调父类方法
        self.__popupManager = game.PopupManager
    end
    nb.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);
    game.PopupManager:addPopup(self, isModal ~= false, isCentered ~= false, closeWhenTouchModel ~= false, useShowAnimation ~= false, animationArgs, ingoreKind)
    return self
end

function Panel:hidePanel_(...)
    nb.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);
    self.__popupManager:removePopup(self,...)
    return self
end
function Panel:onClose(...)
    self:hidePanel_(...)
end

return Panel