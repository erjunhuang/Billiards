
local CommonSignalIndicator = import("gamehall.src.module.common.views.CommonSignalIndicator")

local CommonTipManager = class("CommonTipManager")

local scheduler = require(nb.PACKAGE_NAME .. ".scheduler")
local DEFAULT_STAY_TIME = 3
local X_GAP = 100
local Y_GAP = 0
local TIP_HEIGHT = 72
local LABEL_X_GAP = 16
local ICON_SIZE = 56
local LABEL_ROLL_VELOCITY = 80
local BG_CONTENT_SIZE = nb.size(display.width - X_GAP * 2, TIP_HEIGHT)
local Z_ORDER = 1001

function CommonTipManager:ctor()
    -- 视图容器
    self.container_ = display.newNode()
    self.container_:retain()
    self.container_:enableNodeEvents()
    self.container_.onCleanup = handler(self, function (obj)
       
        if self.commonSignalIndicator_ then
            self.commonSignalIndicator_:removeFromParent()
            self.commonSignalIndicator_ = nil
        end
    end)

end


function CommonTipManager:playReconnectingAnim(isconnecting,str)
    str = str or ""
    if isconnecting then
        if not self.container_:getParent() then
            self.container_:pos(display.cx, display.cy):addTo(game.runningScene, Z_ORDER)
        end

        if not self.commonSignalIndicator_ then
            self.commonSignalIndicator_  = CommonSignalIndicator.new()
                                           
                                            :addTo(self.container_)
        end
        self.commonSignalIndicator_:showNetWordTips(str)
    else
        if self.commonSignalIndicator_ then
            self.commonSignalIndicator_:removeFromParent()
            self.commonSignalIndicator_ = nil
        end

        if self.container_:getParent() then
            self.container_:removeFromParent()
        end

    end

end

function CommonTipManager:dispose()
    if self.container_:getParent() then
        self.container_:removeSelf()
    end
    self.container_:release()
    self.container_ = nil
end


return CommonTipManager