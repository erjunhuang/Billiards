

--[[
    各平台差异化样式，请通过Dialog.setTheme设置，避免修改Dialog代码
--]]

local Panel = import(".Panel")
local Dialog = class("Dialog", Panel)
Dialog.FIRST_BTN_CLICK  = 1
Dialog.SECOND_BTN_CLICK = 2
Dialog.CLOSE_BTN_CLICK  = 3


local DEFAULT_THEME = 
{
    bgImg = {img = "gamehall/res/common/common_panel_bg2.png",scale9 = true,capInsets = nb.rect(240,228,250,120)},
    titleTxt = {font = "gamehall/res/fonts/FZHei-B01S.TTF",fsize = 35,color = nb.c3b(253,237,202), outline = {nb.c4b(36,27,77,150), 2}},
    contentTxt = {font = nil,fsize = 26, color = nb.c3b(0xff,0xff,0xff), outline = nil },
    firstBtn = {imgs = {"gamehall/res/common/new_common_tip_btn_norBg.png","gamehall/res/common/new_common_tip_btn_norBg.png"},font = "gamehall/res/fonts/FZHei-B01S.TTF",fsize = 32,color=nb.c3b(0x2c,0x23,0x1f),outline = {nb.c4b(0xff,0xff,0xd8,100), 2},titlePos = nb.p(0,0)},  
    secondBtn = {imgs = {"gamehall/res/common/new_common_tip_btn_selBg.png","gamehall/res/common/new_common_tip_btn_selBg.png"},font = "gamehall/res/fonts/FZHei-B01S.TTF",fsize = 32,color = nb.c3b(0x2c,0x23,0x1f),outline = {nb.c4b(0xff,0xff,0xd8,100), 2},titlePos = nb.p(0,0)},
    closeBtn = {img = "gamehall/res/common/common_panel_close_btn2.png"},
    bgSize = nb.size(540,400),
    padding = 32,
    topHeight = 70,
    topPadding = 34,
    contentTopPadding=20,
    btnTopPadding=10,
    btnBottomPadding= 30,
    btnHeight = 86,
}


function Dialog.setTheme(theme)
    if type(theme) == "table" then

        print("Dialog.setTheme")
        table.merge(DEFAULT_THEME,theme)
    end
end

function Dialog:ctor(args)
    if type(args) == "string" then
        self.messageText_ = args
        self.firstBtnText_ = "取消"--core.LangUtil.getText("COMMON", "CANCEL")
        self.secondBtnText_ = "确认"--core.LangUtil.getText("COMMON", "CONFIRM")
        self.titleText_ = "温馨提示"--core.LangUtil.getText("COMMON", "NOTICE")
    elseif type(args) == "table" then
        self.messageText_ = args.messageText
        self.specialWidth_ = args.specialWidth
        self.specialHeight_ = args.specialHeight
        self.callback_ = args.callback
        self.firstBtnText_ = args.firstBtnText or "取消" --core.LangUtil.getText("COMMON", "CANCEL")
        self.secondBtnText_ = args.secondBtnText or "确认" --core.LangUtil.getText("COMMON", "CONFIRM")
        self.titleText_ = args.titleText or "温馨提示"--core.LangUtil.getText("COMMON", "NOTICE")
        self.noCloseBtn_ = (args.hasCloseButton == false)
        self.noFristBtn_ = (args.hasFirstButton == false)
        self.notCloseWhenTouchModel_ = (args.closeWhenTouchModel == false)
        self.showStandUpTips = (args.showStandUpTips == 1)--此项打开显示一个checkbox,目前为房间站起专用
        self.standUpCallback = args.standUpCallback
    end


    --add by vanfo 我也不想的，无奈先过渡下
    if self.messageText_ == "您的账户在别处登录" then
        self.messageText_ = "网络状况不佳，请重试(1001)"
    end

    -- 设置dialog的尺寸
    local dialogWidth = self.specialWidth_ or DEFAULT_THEME.bgSize.width
    -- 初始化文本cc.c3b(0xff,0xff,0xff)
    local messageLabel = display.newTTFLabel({
            text = self.messageText_,
            color = DEFAULT_THEME.contentTxt.color,
            size = DEFAULT_THEME.contentTxt.fsize,
            align = nb.TEXT_ALIGNMENT_CENTER,
            font= DEFAULT_THEME.contentTxt.font,
            dimensions = nb.size(dialogWidth - 120, 0)
        })
        :pos(0, (DEFAULT_THEME.padding + DEFAULT_THEME.btnHeight - DEFAULT_THEME.topHeight) * 0.5)

    local dialogHeight =  messageLabel:getContentSize().height  + DEFAULT_THEME.topPadding +DEFAULT_THEME.contentTopPadding + DEFAULT_THEME.btnHeight + DEFAULT_THEME.btnTopPadding+DEFAULT_THEME.btnBottomPadding+ DEFAULT_THEME.topHeight
    
    if self.specialHeight_ then
        if dialogHeight < self.specialHeight_ then
            dialogHeight = self.specialHeight_
        end
    else
        if dialogHeight < DEFAULT_THEME.bgSize.height then 
            dialogHeight = DEFAULT_THEME.bgSize.height 
        end
    end
    
    Dialog.super.ctor(self, {dialogWidth, dialogHeight})


    local tContentHeight =  dialogHeight - DEFAULT_THEME.topPadding-DEFAULT_THEME.contentTopPadding -DEFAULT_THEME.btnHeight - DEFAULT_THEME.btnTopPadding-DEFAULT_THEME.btnBottomPadding- DEFAULT_THEME.topHeight
    messageLabel:pos(0,dialogHeight/2-DEFAULT_THEME.topHeight-DEFAULT_THEME.topPadding - DEFAULT_THEME.contentTopPadding - tContentHeight/2)

    if not self.noCloseBtn_ then
        self:addCloseBtn()
    end

    self.background_ = display.newScale9Sprite(DEFAULT_THEME.bgImg.img, 0, 0,
    nb.size(self.__width, self.__height),DEFAULT_THEME.bgImg.capInsets):addTo(self)--nb.rect(75,75,100,100)
    nb.bind(self.background_,"touch"):setTouchEnabled(true)

    -- self.backgroundTitle = display.newScale9Sprite("gamehall/res/common/common_modal_texture.png"
    --     ,0,0,nb.size(self.__width,self.__height)):addTo(self)
    -- :pos(0,self.__height/2 - 74/2 - 8)
    
    -- -- overlay
    -- display.newScale9Sprite("gamehall/res/common/common_panel_bg3.png", 0, 0, nb.size(self.__width - DEFAULT_THEME.padding, self.__height - DEFAULT_THEME.padding * 0.25 - DEFAULT_THEME.topHeight*2.5))
    --     :pos(0, 10)
    --     :addTo(self)
    
    -- 添加标签 --nb.c3b(197,237,255)
    -- display.newTTFLabel({text = self.titleText_, color = nb.c3b(197,237,255),font="gamehall/res/fonts/FZHei-B01S.TTF" , size = 35, align = nb.TEXT_ALIGNMENT_CENTER})
    --     :pos(0, self.__height * 0.5 - DEFAULT_THEME.topHeight * 0.5-10)
    --     :addTo(self)
    --     :enableOutline(nb.c4b(0,23,0,83), 2)

    local titleLabel = display.newTTFLabel({text = self.titleText_, color = DEFAULT_THEME.titleTxt.color,font=DEFAULT_THEME.titleTxt.font , size = DEFAULT_THEME.titleTxt.fsize, align = nb.TEXT_ALIGNMENT_CENTER})
        :pos(0, self.__height * 0.5 - DEFAULT_THEME.topPadding-DEFAULT_THEME.topHeight * 0.5)
        :addTo(self)
    if DEFAULT_THEME.titleTxt.outline then
        titleLabel:enableOutline(table.unpack(DEFAULT_THEME.titleTxt.outline))
    end
        
    messageLabel:addTo(self)

    -- display.newScale9Sprite("gamehall/res/common/common_modal_texture.png", 0, 0, nb.size(dialogWidth - 16, 82), nb.rect(20,0,1,1))
    -- :pos(0, -dialogHeight * 0.5 + 56):addTo(self)

    -- 初始化按钮
    local showFirstBtn = false
    local buttonWidth = 0
    if not self.noFristBtn_ then
        if self.firstBtnText_ then
            showFirstBtn = true
        end
    end
    
    self.secondBtn_ = ccui.Button:create(table.unpack(DEFAULT_THEME.secondBtn.imgs))
        :addTo(self)
        :setTitleText(self.secondBtnText_)
        self.secondBtn_:setUnifySizeEnabled(true)
        self.secondBtn_:setScale9Enabled(true)
        self.secondBtn_:setTitleFontSize(32)
        :setTitleColor(DEFAULT_THEME.secondBtn.color)
        :setTitleFontName(DEFAULT_THEME.secondBtn.font)
        self.secondBtn_:addClickEventListener(buttonHandler(self, self.onSecButtonClick_))

        local label = self.secondBtn_:getTitleRenderer()
        if DEFAULT_THEME.secondBtn.outline then
            label:enableOutline(table.unpack(DEFAULT_THEME.secondBtn.outline))
        end
        
        if DEFAULT_THEME.secondBtn.titlePos then
            label:setPosition(DEFAULT_THEME.secondBtn.titlePos)
        end

       -- self.secondBtn_:scale(0.9)
        -- :onButtonClicked(buttonHandler(self, self.onButtonClick_))
        -- :setButtonLabel("normal", display.newTTFLabel({text = self.secondBtnText_, color = nb.c3b(255,255,255), size = 28, align = nb.TEXT_ALIGNMENT_CENTER}))
        -- :setButtonLabel("pressed", display.newTTFLabel({text = self.secondBtnText_, color = styles.FONT_COLOR.GREY_TEXT, size = 28, align = nb.TEXT_ALIGNMENT_CENTER}))
    if showFirstBtn then
        self.firstBtn_ = ccui.Button:create(table.unpack(DEFAULT_THEME.firstBtn.imgs))
            :addTo(self)
        self.firstBtn_:setUnifySizeEnabled(true)
        self.firstBtn_:setScale9Enabled(true)
        self.firstBtn_:setTitleText(self.firstBtnText_)
        self.firstBtn_:setTitleFontSize(32)
        self.firstBtn_:setTitleColor(DEFAULT_THEME.firstBtn.color)
        :setTitleFontName(DEFAULT_THEME.firstBtn.font)
        self.firstBtn_:addClickEventListener(buttonHandler(self, self.onFirButtonClick_))

        local label = self.firstBtn_:getTitleRenderer()
        if DEFAULT_THEME.firstBtn.outline then
            label:enableOutline(table.unpack(DEFAULT_THEME.firstBtn.outline))
        end
        


        if DEFAULT_THEME.firstBtn.titlePos then
            label:setPosition(DEFAULT_THEME.firstBtn.titlePos)
        end
            -- :onButtonClicked(buttonHandler(self, self.onButtonClick_))
            -- :setButtonLabel("normal", display.newTTFLabel({text = self.firstBtnText_, color = nb.c3b(255,255,255), size = 28, align = nb.TEXT_ALIGNMENT_CENTER}))
            -- :setButtonLabel("pressed", display.newTTFLabel({text = self.firstBtnText_, color = styles.FONT_COLOR.GREY_TEXT, size = 28, align = nb.TEXT_ALIGNMENT_CENTER}))
        buttonWidth = (dialogWidth - 3 * DEFAULT_THEME.padding) * 0.5 - 10
        -- self.firstBtn_:size(buttonWidth, DEFAULT_THEME.btnHeight):pos(-(DEFAULT_THEME.padding + buttonWidth) * 0.5, -dialogHeight * 0.5 + DEFAULT_THEME.padding + DEFAULT_THEME.btnHeight * 0.5)
        -- self.secondBtn_:size(buttonWidth, DEFAULT_THEME.btnHeight):pos((DEFAULT_THEME.padding + buttonWidth) * 0.5, -dialogHeight * 0.5 + DEFAULT_THEME.padding + DEFAULT_THEME.btnHeight * 0.5)
       -- self.firstBtn_:scale(0.9)

        self.firstBtn_:pos(-(DEFAULT_THEME.padding + buttonWidth) * 0.5, -dialogHeight * 0.5 + DEFAULT_THEME.btnBottomPadding + DEFAULT_THEME.btnHeight * 0.5 )
        self.secondBtn_:pos((DEFAULT_THEME.padding + buttonWidth) * 0.5, -dialogHeight * 0.5 + DEFAULT_THEME.btnBottomPadding+ DEFAULT_THEME.btnHeight * 0.5 )
    else
        buttonWidth = 280
        self.secondBtn_:pos(0, -dialogHeight * 0.5 + DEFAULT_THEME.btnBottomPadding+ DEFAULT_THEME.btnHeight * 0.5 )
        -- self.secondBtn_:size(buttonWidth, DEFAULT_THEME.btnHeight):pos(0, -dialogHeight * 0.5 + DEFAULT_THEME.padding + DEFAULT_THEME.btnHeight * 0.5)
    end


    if self.__firstBtn and self.__seconBtn then
        self.__firstBtnPosition = nb.p(self.__firstBtn:getPosition())
        self.__seconBtnPosition = nb.p(self.__seconBtn:getPosition())
    end
    

    if self.showStandUpTips==true then
        -- local selectBtn = nb.ui.UICheckBoxButton.new({off = "#checkbox_button_off_2.png", on = "#checkbox_button_on_2.png"});
        -- selectBtn:setButtonLabel(nb.ui.UILabel.new({text = core.LangUtil.getText("ROOM", "STAND_UP_TIPS"), size = 28,  color = display.COLOR_WHITE}))
        -- selectBtn:setButtonLabelOffset(40, 0)
        -- selectBtn:setButtonLabelAlignment(display.LEFT_CENTER)
        -- selectBtn:align(display.CENTER, -150, -30)
        -- selectBtn:addTo(self)
        -- selectBtn:onButtonClicked(
        --     function(event) 
        --         self.isSelect = selectBtn:isButtonSelected();
        --     end
        -- )
        -- messageLabel:pos(0, (DEFAULT_THEME.padding + DEFAULT_THEME.btnHeight - DEFAULT_THEME.topHeight) * 0.5 + 30)
    else

    end
end


function Dialog:addCloseBtn()
    if not self.closeBtn_ then
        game.ui.ColorButton.new(DEFAULT_THEME.closeBtn.img)
        :onClick(handler(self,self.onClose))
        :addTo(self,9)
        :pos(self.__width * 0.5-50, self.__height * 0.5-50)
    end

end

function Dialog:addExtNode(extNode)
    if extNode then
        self:addChild(extNode)
    end
    return self
end


--只有创建时有两个按钮的情况生效
function Dialog:isShowFirstBtn(value)
    if self.__firstBtn and self.__seconBtn then
        if value then
            self.__firstBtn:show()
            self.__seconBtn:show()
            self.__firstBtn:setPosition(self.__firstBtnPosition)
            self.__firstBtn:setPosition(self.__seconBtnPosition)
        else
            self.__firstBtn:hide()
            self.__seconBtn:show()
            self.__seconBtn:setPosition(0,self.__seconBtnPosition.y)
        end

    end
   
end


function Dialog:onSecButtonClick_( ... )
    dump("Dialog:onSecButtonClick_")
    if self.callback_ then
        self.callback_(Dialog.SECOND_BTN_CLICK)
    end
    self.callback_ = nil

    if self.hidePanel_ then
        --todo
        self:hidePanel_()
    end
end


function Dialog:onFirButtonClick_( ... )
    dump("Dialog:onFirButtonClick_")
    if self.callback_ then
        self.callback_(Dialog.FIRST_BTN_CLICK)
    end
    self.callback_ = nil

    if self.hidePanel_ then
        --todo
        self:hidePanel_()
    end
end

--这个框可以弹多个
function Dialog:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation, animationArgs, ingoreKind)
    return Dialog.super.showPanel_(self,isModal, isCentered, closeWhenTouchModel, useShowAnimation, animationArgs, true)
end


function Dialog:show()
    if self.notCloseWhenTouchModel_ then
        self:showPanel_(true, true, false, true)
    else
        self:showPanel_()
    end
    return self
end

function Dialog:onRemovePopup(removeFunc)
    if self.callback_ then
        self.callback_(Dialog.CLOSE_BTN_CLICK)
    end
    removeFunc()
end

-- override onClose()
function Dialog:onClose()
    if self.callback_ then
        self.callback_(Dialog.CLOSE_BTN_CLICK)
    end
    self.callback_ = nil
    self:hidePanel_()
end

return Dialog