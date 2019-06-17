
local pokerUI = {}


pokerUI.Panel               = import(".Panel")
pokerUI.Dialog              = import(".Dialog")
pokerUI.Juhua               = import(".Juhua")

pokerUI.ScaleButton = import(".ScaleButton")
pokerUI.ColorButton = import(".ColorButton")
pokerUI.UrlImage = import(".UrlImage")
pokerUI.HeadView = import(".HeadView")
-- pokerUI.XRLEditBox = import(".XRLEditBox")

pokerUI.ScaleButton2 = import(".ScaleButton2")
pokerUI.ColorButton2 = import(".ColorButton2")
pokerUI.ListView = import(".ListView")
pokerUI.ListView2 = import(".ListView2")
pokerUI.ListItem = import(".ListItem")
pokerUI.PageView2 = import(".PageView2")
pokerUI.PageItem = import(".PageItem")
pokerUI.RichTextEx = import(".RichTextEx")
pokerUI.MargueeWidget = import(".MargueeWidget")

-- if device.platform == "ios" then
-- 	if game.isFullVersionNewer(game.getAppVersion(), "1.0.15", true) then
-- 		ccui.TextField = import(".XRLEditBox")
-- 	end
-- end

-- 添加点击声效
function buttonHandler(obj, method)
    return function(...)
        game.SoundManager:playSound(1)
        return method(obj, ...)
    end
end

-- 添加点击声效
function closeButtonHandler(obj, method)
    return function(...)
        game.SoundManager:playSound(2)
        return method(obj, ...)
    end
end

-- 添加点击声效
function cancelButtonHandler(obj, method)
    return function(...)
        game.SoundManager:playSound(3)
        return method(obj, ...)
    end
end

return pokerUI
