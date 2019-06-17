--[[
    全局上下文
]]

game = game or {}

-- 设置元表
local mt = {}
mt.__index = function (t, k)
    if k == "userData" then
        return core.DataProxy:getData(game.dataKeys.USER_DATA)
    elseif k == "runningScene" then
        return SceneManager.GetActiveScene();
    end
end
setmetatable(game, mt)

import(".util.functions").exportMethods(game)

-- 常量设置
-- game.widthScale = display.width / CONFIG_SCREEN_WIDTH
-- game.heightScale = display.height / CONFIG_SCREEN_HEIGHT

-- game.config = import(".config")


-- game.userDefault = import(".util.UserDefault").getInstance()
-- data keys
-- game.dataKeys = import(".keys.DATA_KEYS")
-- game.cookieKeys = import(".keys.COOKIE_KEYS")

-- event names
-- game.eventNames = import(".keys.EVENT_NAMES")

-- event tags
-- game.eventTags = import(".keys.EVENT_TAGS")


-- game.IsoManager = import(".manager.IsoManager")

-- http
-- game.http = import(".net.HttpRequest")
-- game.http.init()

-- Server
game.server = import("gamehall.net.HallSocket").getInstance()

-- 声音管理类
-- game.SoundManager = import(".manager.SoundManager").new()

-- 弹框管理类
-- game.PopupManager = import(".manager.PopupManager").new()


--登录管理类

-- game.LoginManager = import(".manager.LoginManager").new()

-- 顶部消息管理类
-- game.TopTipManager = import(".manager.TopTipManager").new()

-- game.MarqueeTipManager = import(".manager.MarqueeTipManager").new()

-- 屏幕中央消息管理
-- game.CenterTipManager = import(".manager.CenterTipManager").new()

--公共调度器
-- game.schedulerPool = core.SchedulerPool.new()

-- game.screenOrientationManager = import(".manager.ScreenOrientationManager").getInstance()

-- game.AllRooms = import("app.util.LoadAllRoomsControl").getInstance()
-- game.Goods = import("app.util.LoadGoodsControl").new()
-- game.Chats = import("app.util.LoadChatContentsControl").new()
-- game.Private = import("app.util.LoadPrivateDataControl").new()
-- game.Citys = import("app.util.LoadCityControl").getInstance()
-- game.AllGames = import("app.util.LoadAllGameControl").getInstance()
-- game.ShareUrls = import("app.util.LoadShareUrlsController").getInstance()

-- game.DirtyWordFilter = core.DirtyWordFilter.new()

-- game.gameManager = import(".manager.GameManager").getInstance()

game.base     = import(".base.init")

-- 公共UI
-- game.ui = import(".ui.init")


-- if game.isFullVersionNewer(game.getAppVersion(), "1.0.5", true) then --app版本号1.0.5及以后才有底层代码,appVersion为三位
--     --Android运行时权限
--     game.AppRuntimePermissionManager = import(".manager.AppRuntimePermissionManager").getInstance()

--     if device.platform == "android" then
--         --Android截屏检测
--         game.ScreenShotDetector = import("app.plugins.ScreenShotDetectorPluginAndroid").new()
--         game.ScreenShotDetector:registerScreenShotDetectorCallback()
--         game.XianLiao = import("gamehall.src.core.app.plugins.XianLiaoPluginAndroid").new()

--     elseif device.platform == "ios" then
--         --iOS截屏检测
--         game.ScreenShotDetector = import("app.plugins.ScreenShotDetectorPluginIOS").new()
--         game.ScreenShotDetector:registerScreenShotDetectorCallback()

--         game.XianLiao = import("gamehall.src.core.app.plugins.XianLiaoPluginIos").new()
--     end
-- end

-- if game.isFullVersionNewer(game.getAppVersion(), "1.0.10", true) then --app版本号1.0.10及以后才有底层代码,appVersion为三位
--     --语音模块
--     if device.platform == "android" then
--         game.Push = import("app.plugins.XGPushPluginAndroid").new()
--     elseif device.platform == "ios" then
--         game.Push = import("app.plugins.XGPushPluginIos").new()
--     end

-- end


-- --判断是否新语音
-- if device.platform == "android" or device.platform == "ios" then
--     local vResult, vAudio = pcall(require, "paiyou_amr")
--     if vResult and vAudio then
--         game.VoiceManager = import(".manager.VoiceManager").getInstance()
--     end
-- end



-- if game.isFullVersionNewer(game.getAppVersion(), "1.0.14", true) then --app版本号1.0.14及以后才有底层代码,appVersion为三位

--     if device.platform == "android" then
--         game.ChuiNiu = import("app.plugins.ChuiNiuPluginAndroid").new()
--     elseif device.platform == "ios" then
--         game.ChuiNiu = import("app.plugins.ChuiNiuPluginIos").new()
--     end

-- end


-- 原生桥接
-- if device.platform == "android" then
--     game.Native = import(".util.LuaJavaBridge").new()
-- --     game.QQ = import("app.plugins.QQPluginAndroid").new()  
--     game.WeChat =   import("gamehall.src.core.app.plugins.WeChatPluginAndroid").new()
--     game.Gvoice = import("gamehall.src.core.app.plugins.GvoicePluginAndroid").new()

--     -- if IS_OPEN_LOCATION then
--         game.Amap = import("gamehall.src.core.app.plugins.AmapPluginAndroid").new()
--     -- end
    
--     game.Bugly = import(".util.BuglyUtil")
--     game.Bugly.default_init()

--     game.GameNative = import("app.plugins.GameNavitePluginAndroid").new()

-- elseif device.platform == "ios" then
    -- game.Native = import(".util.LuaOCBridge").new()
    -- -- game.QQ = import("app.plugins.QQPluginIos").new()
    -- game.WeChat =   import("gamehall.src.core.app.plugins.WeChatPluginIos").new()
    -- game.Gvoice = import("gamehall.src.core.app.plugins.GvoicePluginIos").new()

    -- -- if IS_OPEN_LOCATION then
    --     game.Amap = import("gamehall.src.core.app.plugins.AmapPluginIos").new()
    -- -- end
    
    -- game.Bugly = import(".util.BuglyUtil")
    -- game.Bugly.default_init()
    -- game.GameNative = import("app.plugins.GameNavitePluginIos").new()

-- else

    -- game.WeChat =   import("gamehall.src.core.app.plugins.WeChatPluginAdapter").new()
    -- game.XianLiao = import("gamehall.src.core.app.plugins.XianLiaoPluginAdapter").new()
    -- game.ChuiNiu = import("gamehall.src.core.app.plugins.WeChatPluginAdapter").new()
    -- game.Native = import(".util.LuaBridgeAdapter")
    -- game.Bugly = import(".util.BuglyUtil")
-- end

-- 加载远程图像
-- game.ImageLoader = core.ImageLoader.new()
-- game.ImageLoader.CACHE_TYPE_USER_HEAD_IMG = "CACHE_TYPE_USER_HEAD_IMG"
-- game.ImageLoader:registerCacheType(game.ImageLoader.CACHE_TYPE_USER_HEAD_IMG, {
--     path = device.writablePath .. "cache" .. device.directorySeparator .. "headpics" .. device.directorySeparator,
--     onCacheChanged = function(path) 
--         require("lfs")
--         local fileDic = {}
--         local fileIdx = {}
--         local MAX_FILE_NUM = 500
--         for file in lfs.dir(path) do
--             if file ~= "." and file ~= ".." then
--                 local f = path.. device.directorySeparator ..file
--                 local attr = lfs.attributes(f)
--                 if type(attr) == "table" then
--                     if attr.mode ~= "directory" then

--                         fileDic[attr.access] = f
--                         fileIdx[#fileIdx + 1] = attr.access
--                     end

--                 end
                
--             end
--         end
--         if #fileIdx > MAX_FILE_NUM then
--             table.sort(fileIdx)
--             repeat
--                 local file = fileDic[fileIdx[1]]
--                 print("remove file -> " .. file)
--                 os.remove(file)
--                 table.remove(fileIdx, 1)
--             until #fileIdx <= MAX_FILE_NUM
--         end
--     end,
-- })

-- game.ImageLoader.CACHE_TYPE_GAMES = "CACHE_TYPE_GAMES"
-- game.ImageLoader:registerCacheType(game.ImageLoader.CACHE_TYPE_GAMES, {
--     path = device.writablePath .. "cache" .. device.directorySeparator .. "games" .. device.directorySeparator,
--     onCacheChanged = function(path) 
--         require("lfs")
--         local fileDic = {}
--         local fileIdx = {}
--         local MAX_FILE_NUM = 100
--         for file in lfs.dir(path) do
--             if file ~= "." and file ~= ".." then
--                 local f = path.. device.directorySeparator ..file
--                 local attr = lfs.attributes(f)
--                 -- assert(type(attr) == "table")
--                 if type(attr) == "table" then
--                     if attr.mode ~= "directory" then
--                         fileDic[attr.access] = f
--                         fileIdx[#fileIdx + 1] = attr.access
--                     end
--                 end
--             end
--         end
--         if #fileIdx > MAX_FILE_NUM then
--             table.sort(fileIdx)
--             repeat
--                 local file = fileDic[fileIdx[1]]
--                 print("remove file -> " .. file)
--                 os.remove(file)
--                 table.remove(fileIdx, 1)
--             until #fileIdx <= MAX_FILE_NUM
--         end
--     end,
-- })


if CC_DISABLE_GLOBAL then
    nb.disable_global()
end

return game
