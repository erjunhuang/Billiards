local fontsPath = "gamehall/res/fonts/FZHei-B01S.TTF"
local RichTextEx = import(".RichTextEx")

local MargueeWidget = class("MargueeWidget", function()
    return display.newNode()
end)

MargueeWidget.VERTICAL = 1 -- 垂直滚动播放(从下到上)
MargueeWidget.HORIZONTAL = 2 -- 水平滚动播放(从右到左)
local WIDTH, HEIGHT = 0, 0

-- 跑馬燈
function MargueeWidget:ctor(contentSize, type)
    WIDTH, HEIGHT = contentSize.width, contentSize.height
    self.bigStencil_ = display.newDrawNode()
    self.bigStencil_:drawPolygon(
        {
            nb.p(-WIDTH * 0.5, -HEIGHT * 0.5),
            nb.p(-WIDTH * 0.5, HEIGHT * 0.5),
            nb.p(WIDTH * 0.5, HEIGHT * 0.5),
            nb.p(WIDTH * 0.5, -HEIGHT * 0.5)
        },
        4,
        nb.c4f(1, 1, 1, 1),
        1,
        nb.c4f(1, 1, 1, 1)
    )
    self.bigStencil_:retain()

    -- 裁剪容器
    self.clipNode_ = nb.ClippingNode:create():addTo(self)

    self.clipNode_:setStencil(self.bigStencil_)

    -- self.txt_ = display.newTTFLabel({text = "", size = 28, align = nb.TEXT_ALIGNMENT_RIGHT,color = nb.c3b(0xff,0xfb,0xed),font=fontsPath})
    -- :addTo(self.clipNode_)

    self.txt_ = RichTextEx:create(28, nb.c3b(0xff, 0xfb, 0xed))
    self.txt_:setDefaultFont(fontsPath)
	self.txt_:addTo(self.clipNode_)

    if type == MargueeWidget.VERTICAL then
        -- 靠左显示
        self.txt_:setAnchorPoint(0, 1)
    else
        self.txt_:setAnchorPoint(1, 0.5)
    end

    self.__isLoop = false -- 是否循环播放
    self.loopMsg = {} -- 消息队列
    self.currIndex = 0 -- 当前播放消息的索引
    self.isPlay = false -- 是否播放中
end

function MargueeWidget:setLoop(flag)
    self.__isLoop = flag
end

function MargueeWidget:setTxtStyle(style)
    if style.color then
        self.txt_:setTextColor(style.color)
    end
    if style.size then
        self.txt_:setFontSize(style.size)
    end
    if style.font then
        self.txt_:setDefaultFont(style.font)
    end
end

function MargueeWidget:addTips(msgs)
    for _, msg in ipairs(msgs) do
        table.insert(self.loopMsg, msg)
    end

    if not self.isPlay then
        self:playAmin()
    end
end

function MargueeWidget:playAmin()
    if #self.loopMsg <= 0 then
        self.isPlay = false
        return
    end
    if self.currIndex >= #self.loopMsg then
        if self.__isLoop then
            -- 循环播放
            self.currIndex = 0
        else
            -- 播放结束
            self.isPlay = false
            return
        end
    end
    self.isPlay = true
    self.currIndex = self.currIndex + 1
    local msg = self.loopMsg[self.currIndex]

	self.txt_:setText(msg):pos(-WIDTH / 2, -HEIGHT / 2)
	self.txt_:formatText()
	local txtSz = self.txt_:getContentSize()

	local function moveCB()
		self.txt_:moveBy({x = 0, y = (HEIGHT + txtSz.height) / 2, time = 0.5, delay = 1.5, onComplete = handler(self, self.playAmin)})
	end

	self.txt_:moveBy({x = 0, y = (HEIGHT + txtSz.height) / 2, time = 0.5, onComplete = moveCB})
end

function MargueeWidget:reset()
    self:stopAnim()
    self.currIndex = 0
    self.loopMsg = {}
end

function MargueeWidget:stopAnim()
    self.txt_:stopAllActions()
    self.txt_:setText("")
end

return MargueeWidget
