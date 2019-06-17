
local LoadGamesControl =import("app.util.LoadGamesControl")

-- local install = import("install")

local ScreenOrientationManager = import(".ScreenOrientationManager")



--@brief 游戏类型，此处只枚举了大厅使用到的id，子游戏则根据其gameid进行跳转即可
GameType = 
{
    HALL                = 100;          -- 大厅
};

------------------------子游戏gameConfig配置映射表-----------------------

--@brief 游戏版本号映射表
--@note 对应字段 _gameVersion eg-> _gameVersion = 10
local GameVersionMap = {};

--@brief 游戏名称映射表
--@note 对应字段 _gameName eg-> _gameName = "斗地主"
local GameNameMap = {};

--@brief 游戏CommonResPath映射表
local GameCommonResPathMap = {}

--@brief 游戏CommonResPath映射表
local GameResPathMap = {}

--@brief 大厅游戏顶部icon映射表
--@note 对应字段 _gameHallTitle eg-> _gameHallTitle = "games/magu/hall_title.png"
local GameHallTitleMap = {};

--@brief 游戏文件加载映射表 
--@note 对应字段 _LoadCommonFiles & _LoadGameFiles
local GameLoadFileFun = {};

--@brief 游戏分辨率映射表
--@note 对应字段 _gameResolution eg-> _gameResolution = {1280, 720}
local GameResolutionMap = {
    [GameType.HALL] = {1280, 720};
}


--FIXED_WIDTH_HEIGHT:默认CONFIG_SCREEN_AUTOSCALE = FIXED_WIDTH
-- if framesize.width/framesize.height >= CONFIG_SCREEN_WIDTH / CONFIG_SCREEN_HEIGHT then
--     CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
--     return {autoscale = CONFIG_SCREEN_AUTOSCALE}
-- else
--     CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
--     return {autoscale = CONFIG_SCREEN_AUTOSCALE}
-- end

--FIXED_HEIGHT_WIDTH 默认CONFIG_SCREEN_AUTOSCALE = FIXED_HEIGHT
-- if framesize.width/framesize.height >= CONFIG_SCREEN_WIDTH / CONFIG_SCREEN_HEIGHT then
--     CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
--     return {autoscale = CONFIG_SCREEN_AUTOSCALE}
-- else
--     CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
--     return {autoscale = CONFIG_SCREEN_AUTOSCALE}
-- end

--SHOW_ALL

local GameAutoscaleMap = {
    [GameType.HALL] = display.getFitAutoScale("SHOW_ALL"),
}

--@brief 游戏是否竖屏 0:横屏 1:竖屏
--@note 对应字段 _gameVerticalScreen eg-> _gameVerticalScreen = 0;
local GameVerticalScreen = {}

--@brief 游戏是否使用新框架，1：新，0：旧  eg-> gameid:1
--@note 对应字段 _gameDependFrame eg-> _gameDependFrame = 1
local GameDependFrame = {}

--@brief 游戏所依赖的大厅版本号
--@note 对应字段 _gameDependHallMinVersion eg-> _gameDependHallMinVersion = 700
local GameDependHallMinVersion = {};

--@brief 游戏自定义界面配置表
--[[
    @note 对应字段 _gameCustomView
    包含字段 _roomLevelListView -> 对应游戏场次列表自定义界面的路径
    包含字段 _privateRoomParamSetView -> 对应游戏私人房自定义界面的路径
    包含字段 _privateRoomEnterView -> 对应私人房搜索房间后进入房间弹框界面
    包含字段 _gameLevelTab -> 对应游戏选场界面顶部TAB控件

    eg: _gameCustomView = {
        _roomLevelListView = "games/magu/maguGameLevelListView";
        _privateRoomParamSetView = "games/magu/maguCustomParamSetView";
        _privateRoomEnterView = "hall/privateRoom/widget/privateRoomEnterViewCommon";
        _gameLevelTab =  "games/magu/gameLevelTab";
    };
--]]
local GameCustomView = {}

--@brief 游戏自定义数据类
--[[
    @note 对应字段 _gameCustomConfig  大厅只做缓存，具体需要哪些字段由游戏控制
    目前已知字段 _customPlayerInfoHandler  用于登录时扩展传给server的参数
]]
local GameCustomConfig = {}




local _Scenes = {}
local _ScenesMap = {}

local GameManager = class("GameManager")


GameManager.getInstance = function()
    if not GameManager.s_instance then
        GameManager.s_instance = GameManager.new()
    end
    return GameManager.s_instance
end



GameManager.eScreenCallback = {
    Game = 1,
    Scene = 2,
    Module = 3,
    PopScene = 4,
}


function GameManager:ctor()
	self.m_apkVersion = ""; --版本号

    self.m_gameInitStatus = {}; --游戏初始化状态映射表
    self.m_gamesPlayableConfig = {}; --大厅对应的游戏可玩版本号
    self.m_gamePackagePathMap = { --游戏路径配置 eg-> gameid:"games/gamePkgName"
        [GameType.HALL] = "gamehall";
    };

    self.m_curGameId = 0; --当前所在游戏的id
    self.m_lastGameId = 0; --刚才所在游戏的id

    self:initGame(GameType.HALL)
    -- self:requestGameList()
end

function GameManager:initGames(data)
    
    if data and #data > 0 then
        for _,v in ipairs(data) do
            self:initPkgName(checkint(v.gameid),v.pkgName)
            self:initGame(checkint(v.gameid))
        end
    end
end

function GameManager:checkDirEnd(dirPath)
    if not dirPath then
        return nil
    end
    local endchar = string.sub(dirPath, -1)
    if endchar == "/" or endchar == "\\" then
        return dirPath
    else 
        return dirPath .. "/"
    end
end

function GameManager:requestGameList()
    local gameUrl = nb.UserDefault:getInstance():getStringForKey("gameUrl")
    if gameUrl and gameUrl ~= "" then
        LoadGamesControl.getInstance():loadConfig(gameUrl,function(isSuccess,datas)
            if isSuccess and datas then
                local subGames = LoadGamesControl.getInstance():getSubGamelist()
                self:setGamelist(subGames)
            end
        end)
    end
    
end


function GameManager:setGamelist(datas)
    if not datas then
        return
    end
    
    for _,v in pairs(datas) do
        self:initPkgName(checkint(v.id),v.clientpath)
        self:initGame(checkint(v.id))
    end
end


function GameManager:__log( ... )
	print(...)
end


function GameManager:startPopScene(orientation, resolution,gameid,autoscale)
    if self.m_screenOrienChanging then
        --调用原生切换屏幕方向期间，不允许调用切换场景，否则会导致加载顺序和屏幕切换时机错误，导致界面显示错误
        --一般情况下都是为了防止房间内多次调用切换到大厅引发问题
        self:__log("startChangeScene", "the screen orientation is changing YOU MUST WAIT THE OPERATTION FINISH!!!!!!!!!");
        return;
    end
   
    orientation = orientation or ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE;
    resolution = resolution or {1280, 720};
    autoscale = autoscale or display.getFitAutoScale("SHOW_ALL")

    local temp = { 
        typ = GameManager.eScreenCallback.PopScene,
        resolution = resolution,
        orientation = orientation,
        autoscale = autoscale
    };

    if checkint(gameid) > 0 then
        orientation = self:getGameVerticalScreen(gameid)
        resolution = self:getGameResolution(gameid)
        autoscale = self:getGameAutoscale(gameid)
        temp.resolution = resolution
        temp.autoscale = autoscale
    end

    local curScreenOrien = ScreenOrientationManager.getInstance():getCurScreenOrientation()
    if curScreenOrien ~= orientation then
        self.m_enterGameCache = temp;
        self:__changeScreenOrien(orientation)
    else
        self:__setAutoscaleOrResolution(resolution[1], resolution[2],autoscale);
        self:__popScene(temp)
    end

end


function GameManager:__popScene(temp)
   nb.Director:getInstance():popScene()
end


function GameManager:startChangeScene(sceneIdOrFile, orientation, resolution, autoscale,isPushScene,transitionType, time, more, ...)

    local sceneFile
    local sceneId = tonumber(sceneIdOrFile)
    if not sceneId then
        sceneFile = sceneIdOrFile
    end
    
    if self.m_screenOrienChanging then
        --调用原生切换屏幕方向期间，不允许调用切换场景，否则会导致加载顺序和屏幕切换时机错误，导致界面显示错误
        --一般情况下都是为了防止房间内多次调用切换到大厅引发问题
        self:__log("startChangeScene", "the screen orientation is changing YOU MUST WAIT THE OPERATTION FINISH!!!!!!!!!");
        return;
    end
   
    orientation = orientation or ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE;
    resolution = resolution or {1280, 720};
    autoscale = autoscale or display.getFitAutoScale("SHOW_ALL")

    local temp = { 
        typ = GameManager.eScreenCallback.Scene,
        sceneId = sceneId,
        args = {...},
        resolution = resolution,
        isPushScene = isPushScene,
        transitionType = transitionType,
        time = time,
        more = more,
        sceneFile = sceneFile,
        autoscale = autoscale
    };

    local curScreenOrien = ScreenOrientationManager.getInstance():getCurScreenOrientation()
    if curScreenOrien ~= orientation then
        self.m_enterGameCache = temp;
        self:__changeScreenOrien(orientation)
    else
        self:__setAutoscaleOrResolution(resolution[1], resolution[2],autoscale);
        self:__enterScene(temp)
    end
end

function GameManager:__enterScene(temp)
    self:__log("__enterScene", " data = ", temp);

    local sceneId = temp.sceneId
    local isPushScene = temp.isPushScene
    local transitionType = temp.transitionType
    local more = temp.more
    local time = temp.time
    local args = temp.args
    local tSceneFile = temp.sceneFile

    local sceneFile = tSceneFile or _ScenesMap[sceneId][2]
    self:showScene(sceneFile,gameid,isPushScene,transitionType,time,more,table.unpack(args))
end



--大厅和模块之间的跳转接口
function GameManager:startEnterModule(gameid,isPushScene,transitionType, time, more, ...)

    gameid = tonumber(gameid)
    if not gameid then
        return
    end

    if self.m_screenOrienChanging then
        self:__log("startEnterModule", "the screen orientation is changing YOU MUST WAIT THE OPERATTION FINISH!!!!!!!!!");
        return;
    end

    local checkMulArgs = {...}
    self:__startGameOrModule(GameManager.eScreenCallback.Game, self.__enterModule, gameid, isPushScene,transitionType, time, more, table.unpack(checkMulArgs));
end

function GameManager:__enterModule(temp)
    self:__log("__enterModule", " data = ", temp);

    local gameid = temp.gameid
    local scene = temp.scene
    local isPushScene = temp.isPushScene
    local transitionType = temp.transitionType
    local more = temp.more
    local time = temp.time
    local args = temp.args

    -- if (not self:isInRoom()) or (gameid ~= self:getLastGameId()) then 
        -- 先清除游戏内包含的文件，防止游戏间的冲突
        -- self:clearGameRequiredPath(self:getLastGameId())
        self:__loadFiles(gameid, false);
    -- end


    local isInHall = (gameid == GameType.HALL) and true or false;
    self:setIsInRoom(false);
    self:setIsInModule(not isInHall);
    self:setCurGameId(gameid);
    if (gameid ~= GameType.HALL) then
       
    else
       
    end

    local sceneFile = _ScenesMap[scene][2]
    self:showScene(sceneFile,gameid,isPushScene,transitionType,time,more,table.unpack(args))

end


--大厅和房间之间的跳转接口
function GameManager:startGame(gameid,...)

    gameid = tonumber(gameid)
    if not gameid then
        return
    end
    if gameid == self:getCurGameId() then
        return
    end

    local checkMulArgs = {...}
    local function __showGameDownloadDialog(gameid, handler)
        local NewGameDownloadDialog = import("gamehall.src.module.downloadgame.NewGameDownloadDialog")
        NewGameDownloadDialog.new(false, gameid, handler):showPanel_()
    end

    local function __showGameUpdateDialog(gameid, handler)
        local NewGameDownloadDialog = import("gamehall.src.module.downloadgame.NewGameDownloadDialog")
        NewGameDownloadDialog.new(true, gameid, handler):showPanel_()
    end

    local function __startGameWrapper()
        if self.m_screenOrienChanging then
            self:__log("startGame", "the screen orientation is changing YOU MUST WAIT THE OPERATTION FINISH!!!!!!!!!")
            return
        end

        self:__startGameOrModule(GameManager.eScreenCallback.Game, self.__enterGame, gameid, false, transitionType, time, more,table.unpack(checkMulArgs))
    end

    local function __downloadGame()
        local DownloadProgressDialog = import("gamehall.src.module.downloadgame.DownloadProgressDialog")
            DownloadProgressDialog.new(gameid, __startGameWrapper):show()
    end

    local NewUpdateMgr = import("gamehall.src.update.NewUpdateMgr")

    if NewUpdateMgr.getInstance():isAssetsManagerExDownloading(gameid) then
        __downloadGame()
        return
    end

    -- 验证是否未安装
    if not self:isGameInstalled(gameid) then
        __showGameDownloadDialog(gameid, __downloadGame)
        return
    end

    -- 验证是否已更新
    local isUpdated = NewUpdateMgr.getInstance():isGameUpdated(gameid)
    print("GameManager:startGame => isGameUpdated: ", isUpdated)
    if isUpdated then
        __startGameWrapper()
        return
    end

    local shouldUpdateCallback = function()
        __showGameUpdateDialog(gameid, function()
                local DownloadProgressDialog = import("gamehall.src.module.downloadgame.DownloadProgressDialog")
                DownloadProgressDialog.new(gameid, __startGameWrapper):show()
            end)
    end
    local noUpdateCallback = function()
        __startGameWrapper()
    end

    NewUpdateMgr.getInstance():checkGameVersionCacheOrShowCheckGameUpdateDialog(gameid, shouldUpdateCallback, noUpdateCallback)
end

function GameManager:clearGameRequiredPath(gameid)
    -- body
end

function GameManager:__enterGame(temp)
    self:__log("__enterGame", " data = ", temp);

    local gameid = temp.gameid;
    local scene = temp.scene;
    local isPushScene = temp.isPushScene;
    local time = temp.time
    local more = temp.more
    local args = temp.args
    local transitionType = temp.transitionType

    -- 同一个房间内重连，不需要重新加载资源，否则会导致全局表被重置，导致游戏异常！！！
    -- 从一个游戏房间跳到另一个游戏房间需重新加载资源
    -- 从大厅进游戏需要重新加载资源
    if (not self:isInRoom()) or (gameid ~= self:getLastGameId()) then 
        --先清除游戏内包含的文件，防止游戏间的冲突
        self:clearGameRequiredPath(self:getLastGameId())
        -- self:__loadFiles(gameid, false);
    end
    --暂时先放出来
    self:__loadFiles(gameid, false);

    local isInHall = (gameid == GameType.HALL) and true or false;
    -- self:__setFPS(isInHall);
    self:setIsInModule(false);
    self:setIsInRoom(not isInHall);

    self:setCurGameId(gameid);
    if (gameid ~= GameType.HALL) then
       
    else
        
    end

    local sceneFile = _ScenesMap[scene][2]
    self:showScene(sceneFile,gameid,isPushScene,transitionType,time,more,table.unpack(args))

    if game.Bugly then
        if game.Bugly.Tags then
            game.Bugly.setTag(checkint(game.Bugly.Tags.Crash))
        end
        game.Bugly.removeUserValue("gameVer")
        game.Bugly.removeUserValue("gameid")
        game.Bugly.addUserValue("gameVer",GameVersionMap[gameid])
        game.Bugly.addUserValue("gameid",(gameid or "0"))
    end
end



function GameManager:showScene(sceneFile,gameid,isPushScene,transitionType, time, more,...)
    print("showScene===",sceneFile)
    app:enterScene(sceneFile,isPushScene,transitionType, time, more,...)
end


function GameManager:initGame(gameid)
    gameid = checkint(gameid)
	self:__log("initGame", "gameid = ", gameid);

    if self.m_gameInitStatus[gameid] then
        self:__log("initGame", "this game has inited");
        return;
    end
    
    self:__parseGameConfig(gameid, false);
end


--更新完毕后，重新初始化游戏
function GameManager:reInitGame(gameid)
    if not gameid then
        return;
    end

    self:__log("reInitGame", "gameid = ", gameid);
    self:__resetGameStatus(gameid);
    self:__parseGameConfig(gameid, true);
end


function GameManager:__resetGameStatus(gameid)
    if not gameid then
        return;
    end

    GameVersionMap[gameid]=nil
    GameNameMap[gameid]=nil
    GameCommonResPathMap[gameid]=nil
    GameResPathMap[gameid] = nil
    GameHallTitleMap[gameid]=nil
    GameResolutionMap[gameid] = nil
    GameVerticalScreen[gameid] = nil
    GameDependFrame[gameid] = nil
    GameLoadFileFun[gameid] = nil
    GameCustomView[gameid] = nil
    GameDependHallMinVersion[gameid] = nil
end




function GameManager:__parseGameConfig(gameid, isReInit)
    gameid = tonumber(gameid)
    self:__log("__parseGameConfig", "gameid = ", gameid, "isReInit = ", isReInit);
    if not gameid or gameid <= 0 then
        self:__log("__parseGameConfig", "illegal gameid");
        return;
    end

    if not self.m_gamePackagePathMap[gameid] then
        return
    end

    local gamePkg= self.m_gamePackagePathMap[gameid] .. ".src";

    print("gamePkg00",gamePkg)

    if gamePkg == nil or gamePkg =="" then
        self:__log("__parseGameConfig", "gamePkg is null");
        return;
    end

    local fileName=gamePkg .. ".GameConfig";
    if isReInit then
        --如果是reInit，则需要重新加载此文件
        package.loaded[fileName] = nil;
        -- 清除已加载lua代码模块记录
        for k,v in pairs(package.loaded) do
            if string.match(k,"^" .. gamePkg .. "%.") then
                print("clearGameLoadedPackage => ", k)
                package.loaded[k] = nil
            end
        end
        -- dump(package.loaded, "__parseGameConfig, isReInit, gameConfig", 1)

        -- 清一层C++全路径缓存
        nb.FileUtils:getInstance():purgeCachedEntries()
    end
    
    local isSuccess ,result = pcall(require,fileName);

    print("fileName",fileName)
    if not isSuccess then
        self:__log("__parseGameConfig", "load GameConfig failed, please check GameConfig file of the subgame: ", result);
        return;
    end


    local GameConfig = result

    if gamePkg == nil or gamePkg =="" then
        self:__log("__parseGameConfig", "gamePkg is null");
        return;
    end

    -- dump(GameConfig,"GameConfig")
    if (not GameConfig.GamePath) or (not GameConfig.res_path) or (not GameConfig.src_path)  then
        self:__log("__parseGameConfig", "GamePath、res_path、src_path must not be nil");
        return;
    end

    if (gameid ~= GameType.HALL) and ((not GameConfig.CommonSrcPath) or (not GameConfig.CommonResPath)) then
        self:__log("__parseGameConfig eath Game", "CommonSrcPath、CommonResPath must not be nil");
        return;
    end

    if not GameVersionMap[gameid] then
        GameVersionMap[gameid]=GameConfig.gameVersion;
    end

    if not self:isGamePlayable(gameid) then
        --如果版本不兼容，则不继续往下走
        self:__log("__parseGameConfig", "this game isn't playable");
        self:__resetGameConfigVariable();
        return;
    end

    self.m_gameInitStatus[gameid]=true;

    if GameConfig.initGameFun then
        GameConfig.initGameFun(isReInit);
    end

    if not GameNameMap[gameid] then
        GameNameMap[gameid]=GameConfig.gameName;
    end

    if not GameCommonResPathMap[gameid] then
        GameCommonResPathMap[gameid] = self:checkDirEnd(GameConfig.CommonResPath)
    end

    if not GameResPathMap[gameid] then
        GameResPathMap[gameid] = self:checkDirEnd(GameConfig.res_path)
    end

    if not GameHallTitleMap[gameid] then
        GameHallTitleMap[gameid] = GameConfig.gameHallTitle ;
    end

    if not GameResolutionMap[gameid] then
        GameResolutionMap[gameid] = GameConfig.gameResolution; --eg:{1280, 800}
    end

    if not GameAutoscaleMap[gameid] then
        GameAutoscaleMap[gameid] = GameConfig.gameAutoscale
    end

    if not GameVerticalScreen[gameid] then
        GameVerticalScreen[gameid] = GameConfig.gameVerticalScreen;
    end

    if not GameCustomView[gameid] then
        GameCustomView[gameid] = GameConfig.gameCustomView;
    end

    if not GameCustomConfig[gameid] then
        GameCustomConfig[gameid] = GameConfig.gameCustomConfig;
    end

    if not GameDependFrame[gameid] then 
        GameDependFrame[gameid] = GameConfig.gameDependFrame;
    end 

    if not GameDependHallMinVersion[gameid] then
        GameDependHallMinVersion[gameid] = GameConfig.gameDependHallMinVersion;
    end


    -- HallFeatureManager.getInstance():setGameSupportFeatureConfig(gameid, GameConfig.gameSupportFeatureConfig);

    self:__log("__parseGameConfig", "_gameVersion = ", GameVersionMap[gameid],
                                    "_gameVerticalScreen = ", GameVerticalScreen[gameid], 
                                    "_gameResolution = ", GameResolutionMap[gameid],
                                    "_gameCustomView = ", GameCustomView[gameid],
                                    "_gameCustomConfig = ", GameCustomView[gameid],
                                    "_gameDependHallMinVersion = ", GameDependHallMinVersion[gameid]);

    if not GameLoadFileFun[gameid] and (GameConfig.LoadCommonFiles or GameConfig.LoadGameFiles) then
        --{commonLoadFun, gameLoadFun}
        GameLoadFileFun[gameid] = {};
        GameLoadFileFun[gameid].commonLoadFun = GameConfig.LoadCommonFiles
        GameLoadFileFun[gameid].gameLoadFun = GameConfig.LoadGameFiles
    end

    if isReInit then
        self:__setAutoOrResolutionByGameId(gameid); --设置游戏分辨率，防止游戏初始化控件位置时出问题
        self:__loadFiles(gameid, true);
        self:__setAutoOrResolutionByGameId(GameType.HALL);--还原到大厅分辨率
    end

    if GameConfig.dependApkVersion then
        self.m_apkVersion = GameConfig.dependApkVersion; --只有 hall gameConfig才会有
    end

    --将gameConfig中的状态copy到stateMachine中去
    for k,v in pairs(GameConfig.scenes) do
        local key = k .. v
        _Scenes[key]=v;
    end

    for k,v in pairs(GameConfig.scenesMap) do
        _ScenesMap[k]=v;
    end

    self:__resetGameConfigVariable();
end

-- 获取游戏GameConfig.CommonResPath中配置的路径
function GameManager:getCurrentGameCommonResPath()
    if self.m_curGameId == GameType.HALL then
        return ""
    end
    return GameCommonResPathMap[self.m_curGameId] or ""
end

-- 获取游戏GameConfig.res_path中配置的路径
function GameManager:getCurrentGameResPath()
    if self.m_curGameId == GameType.HALL then
        return ""
    end
    return GameResPathMap[self.m_curGameId] or ""
end


--设置游戏分辨率
function GameManager:__setAutoOrResolutionByGameId(gameid)
    local resolution = self:getGameResolution(gameid);
    local autoscale = self:getGameAutoscale(gameid)
    if not table.isEmpty(resolution) then
        self:__setAutoscaleOrResolution(resolution[1], resolution[2],autoscale);
    end
end

--设置分辨率
function GameManager:__setAutoscaleOrResolution(width, height,autoscale)

    -- print("__setAutoscaleOrResolution",width,height) --暂时屏蔽
    local autoscaleTb = string.split(autoscale,"_")
    local autoscale_1 = autoscale
    local autoscale_2 = autoscale
    if #autoscaleTb >= 3 then
        autoscale_1 = string.format("%s_%s",autoscaleTb[1],autoscaleTb[2])
        autoscale_2 = string.format("%s_%s",autoscaleTb[1],autoscaleTb[3])
    end
    CONFIG_SCREEN_AUTOSCALE = autoscale_1
    local newDesign = {
            width = width,
            height = height,
            autoscale = CONFIG_SCREEN_AUTOSCALE,
            callback = function(framesize)
                if framesize.width/framesize.height >= CONFIG_SCREEN_WIDTH / CONFIG_SCREEN_HEIGHT then
                    CONFIG_SCREEN_AUTOSCALE = autoscale_2
                    return {autoscale = CONFIG_SCREEN_AUTOSCALE}
                else
                    CONFIG_SCREEN_AUTOSCALE = autoscale_1
                    return {autoscale = CONFIG_SCREEN_AUTOSCALE}
                end
            end,
        }

    display.setAudoScaleWithCurrentFrameSize(newDesign)
end




function GameManager:__startGameOrModule(typ, func, gameid,isPushScene,transitionType, time, more,...)
    gameid = tonumber(gameid)
    if not gameid then
        return
    end
	self:initGame(gameid);

    local bFind = false;
    for k,v in pairs(_Scenes) do
        if v == gameid then

            local temp = { 
                typ = typ,
                gameid = gameid,
                scene =  _Scenes[k],
                args = {...},
                isPushScene = isPushScene,
                transitionType = transitionType,
                time = time,
                more = more,
                resolution = self:getGameResolution(gameid),
                autoscale = self:getGameAutoscale(gameid),
            };

            local gameScreenOrien = self:getGameVerticalScreen(gameid);
            local curScreenOrien = ScreenOrientationManager.getInstance():getCurScreenOrientation();

            self:__log("__startGameOrModule", "gameScreenOrien , curScreenOrien = ", gameScreenOrien, curScreenOrien);
            if curScreenOrien ~= gameScreenOrien then
                --如果屏幕方向不同，则调用原生切换方向
                self.m_enterGameCache = temp;
                self:__changeScreenOrien(gameScreenOrien)
            else
                self:__log("__startGameOrModule", "the orientation is same curScreenOrien");
                
                --屏幕方向相同，则直接进入房间
                self:__setAutoOrResolutionByGameId(gameid);--设置分辨率
                func(self, temp);
            end    

            bFind = true;
            break;
        end
    end

    if not bFind then
        self:__log("__startGameOrModule", "don't find state, please check subgame GameConfig file and confirm gameid equal stateid, stateid = ", gameid, "  States = ", States);
    end
end




function GameManager:__changeScreenOrien(orientation)
    -- ScreenOrientationManager.getInstance():setCurScreenOrientation(orientation)
    self:__log("__changeScreenOrien", "start call changeScreenOrientation orientation = ", orientation);
    self.m_screenOrienChanging = true

    ScreenOrientationManager.getInstance():changeScreenOrientation( orientation == ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE,nil,nil,handler(self,self.onChangeScreenOrientationCallBack))

end


--屏幕方向切换完成回调
GameManager.onChangeScreenOrientationCallBack = function( self, flag, info )
    self.m_screenOrienChanging = false;

    if table.isEmpty(self.m_enterGameCache) then
        self:__log("onChangeScreenOrientationCallBack", "empty self.m_enterGameCache");
        return;
    end

    self:__log("onChangeScreenOrientationCallBack", "width = ", display.sizeInPixels.width,
                                                    "height = ", display.sizeInPixels.height,
                                                    "self.m_enterGameCache = ", self.m_enterGameCache);
    
    local temp = self.m_enterGameCache;
    self.m_enterGameCache = {};

    self:__setAutoscaleOrResolution(temp.resolution[1], temp.resolution[2],temp.autoscale);

    if temp.typ == GameManager.eScreenCallback.Scene then
        self:__enterScene(temp);
    elseif temp.typ == GameManager.eScreenCallback.Game then
        self:__enterGame(temp);
    elseif temp.typ == GameManager.eScreenCallback.Module then
        self:__enterModule(temp);
    elseif temp.typ == GameManager.eScreenCallback.PopScene then
        self:__popScene(temp)
    end
end




-- 初始化游戏包名
function GameManager:initPkgName(gameid,pkgName)
    print("initPkgName: ", gameid, pkgName)
    self.m_gamePackagePathMap[gameid] = pkgName;--初始化packageMap
end

-- 获取游戏包名
function GameManager:getPkgName(gameid)
    gameid = checkint(gameid)
    local pkgName = self.m_gamePackagePathMap[gameid]
    return pkgName
end

-- 获取游戏版本号
function GameManager:getGameVersion(gameid)
    gameid = checkint(gameid)
    return GameVersionMap[gameid] or nil;
end

-- 判断游戏是否安装
function GameManager:isGameInstalled(gameid)
    gameid = checkint(gameid)
    local result = false
    if GameVersionMap[gameid] then
        result = true
    end
    dump(GameVersionMap,"GameVersionMap")
    print("GameManager:isGameInstalled(", gameid, ") returns", result)
    return result
end

--[[
获取私人房游戏玩法配置表
]]
function GameManager:getGameModesConfig(gameid)
    print("GameManager:getGameModesConfig(",gameid,")")
    gameid = checkint(gameid)
    local config = {}
    if not gameid then
        return config
        
    end
    -- 已经安装了此游戏
    if self:getGameVersion(gameid) then
        -- 是否用的install.lua中的路径
        local gamePkgPath = self.m_gamePackagePathMap[gameid]
        if (not gamePkgPath) or gamePkgPath == "" or type(gamePkgPath) ~= "string" then
            return config
        end
 
        local gamePkg = gamePkgPath.. ".src"
        local cfgFile = gamePkg .. ".GameConfig"

        local isSuccess, gameConfig = pcall(require, cfgFile)
        print(string.format("load GameConfig[%s] %s", cfgFile, isSuccess and "success" or "failed"))
     
        if not isSuccess then
            -- 没有require对应game的GameConfig.lua成功
            return config
        end

        local privateModesPath = gameConfig.privateModesPath
        if privateModesPath then
            local isSuccess, gameModes = pcall(require, privateModesPath)
            print(string.format("load PrivateModes[%s] %s", privateModesPath, isSuccess and "success" or "failed"))
            if not isSuccess or not gameModes then
                -- 没有require对应game的PrivateModes.lua成功
                return config
            end
            config = gameModes
        end
    end
    return config
end

--[[
    获取私人房游戏玩法完整描述字符串
    优先查找私人房玩法配置表gameroot/config/PrivateModes.lua中的字段
]]
function GameManager:getGameModesWholeDescription(gameid, selectedModes, separator,filterTb)
    gameid = checkint(gameid)
    print("GameManager:getGameModesWholeDescription(",gameid, selectedModes, separator,tostring(json.encode(filterTb)),")")
    local modesTab = nil
    if type(selectedModes) == "string" then
        modesTab = json.decode(selectedModes) or {}
    elseif type(selectedModes) == "table" then
        modesTab = selectedModes
    else
        return ""
    end

    if filterTb then
        for _,fv in pairs(filterTb) do
            modesTab[fv] = nil
        end
    end

    -- 默认分隔符为全角顿号
    separator = separator or "、"
    local config = self:getGameModesConfig(gameid).PRIVATE_INFOMATION or {}
    local desc = ""
    local isFirst = true
    for k, v in pairs(modesTab) do
        local tmp = config[k]
        local tmpStr = nil
        if type(tmp) == "table" then
            if type(v) == "table" and table.nums(v) > 0 then
                tmpStr = ""
                for _,tv in pairs(v) do
                    tmpStr = tmpStr .. separator .. tmp[tv]
                end
                
            else
                tmpStr = tmp[v]
            end
            
        elseif type(tmp) == "string" then
            tmpStr = string.format(tmp, v)
        end
        if tmpStr then
            if isFirst then
                desc = desc .. tostring(tmpStr)
                isFirst = false
            else
                desc = desc .. separator .. tostring(tmpStr)
            end
        end
    end
    return desc
end

-- function GameManager:getPrivateGameRule(gameid, selectedModes)
--     print("GameManager:getPrivateGameRule(", gameid, selectedModes, ")")
--     local modesTab = {}
--     if type(selectedModes) == "string" then
--         modesTab = json.decode(selectedModes) or {}
--     elseif type(selectedModes) == "table" then
--         modesTab = selectedModes
--     end

--     gameid = tonumber(gameid) or 0

--     local gameRule = ""
--     local config = self:getGameModesConfig(gameid)
--     if type(config.getPrivateGameRule) == "function" then
--         print("call onfig.getPrivateGameRule()")
--         gameRule = config.getPrivateGameRule(modesTab) or ""
--     end
--     if gameRule == "" and type(config.PRIVATE_ROOM_RULE) == "string" then
--         gameRule = config.PRIVATE_ROOM_RULE
--         print("use config.PRIVATE_ROOM_RULE")
--     end

--     if gameRule == "" then
--         -- 兼容旧版本代码
--         local defaultRule = require("app.games.gamecommon.config.const").PRIVATE_ROOM_RULE
--         if type(defaultRule) == "table" then
--             if type(defaultRule[gameid]) == "table" and type(defaultRule[gameid][1]) == "string" then
--                 gameRule = defaultRule[gameid][1]
--             elseif type(defaultRule[gameid]) == "string" then
--                 gameRule = defaultRule[gameid]
--             end
--         end
--     end

--     return gameRule
-- end

-- 获取已安装的游戏帮助配置（们）
function GameManager:getInstalledGameHelpConfigs()
    local installedGameIds = self:getInstalledGames()

    local gameHelpConfigs = {}

    for _,gameid in ipairs(installedGameIds) do
        if gameid then
            local gameHelpCfg = self:getInstalledGameHelpConfigByGameId(gameid)
            gameHelps[gameid] = gameHelpCfg
        end
    end
    return gameHelpConfigs
end

-- 获取对应gameid的游戏帮助配置
function GameManager:getInstalledGameHelpConfigByGameId(gameid)
    print("GameManager:getInstalledGameHelpConfigByGameId(", gameid, ")")
    gameid = tonumber(gameid)
    local config = {}
    if not gameid then
        return config
    end

    if not self:getGameVersion(gameid) then
        return config
    end

    local isPathFromInstall = false
    local gamePkgPath = self.m_gamePackagePathMap[gameid]
    dump(self.m_gamePackagePathMap)

    if type(gamePkgPath) ~= "string" then
        -- 没有找到路径
        return config
    end

    local gamePkg = gamePkgPath ..".src"
    local cfgFile = gamePkg .. ".GameConfig"

    local isSuccess, gameConfig = pcall(require, cfgFile)

    if not isSuccess then
        -- 没有require对应game的GameConfig.lua成功
        return config
    end

    -- 如果没有找到，默认是config.GameHelps
    local gameHelpsPath = gameConfig.gameHelpsPath or "config.GameHelps"
    print("gameHelpsPath = "..gameHelpsPath)
    if gameHelpsPath then
        local firstChar = string.sub(gameHelpsPath, 1, 1)
        if firstChar == "." then
            gameHelpsPath = gamePkg .. gameHelpsPath
        else
            gameHelpsPath = gamePkg .. "." .. gameHelpsPath
        end

        local isSuccess, gameHelps = pcall(require, gameHelpsPath)
        print(string.format("load GameHelps[%s] %s", gameHelpsPath, isSuccess and "success" or "failed"))
        if not isSuccess or type(gameHelps) ~= "table" then
            -- 没有require对应game的GameHelps.lua成功
            return config
        end
        config = clone(gameHelps)
        config.gamePkgPath = gamePkgPath
    end

    return config
end


function GameManager:getGameSettingDlg(gameid)
    gameid = checkint(gameid)

    if not self:getGameVersion(gameid) then
        return nil
    end

    if self:getGameVersion(gameid) then
        -- 是否用的install.lua中的路径
        local gamePkgPath = self.m_gamePackagePathMap[gameid]
        if (not gamePkgPath) or gamePkgPath == "" or type(gamePkgPath) ~= "string" then
            return nil
        end
 
        local gamePkg = gamePkgPath.. ".src"
        local cfgFile = gamePkg .. ".GameConfig"

        local isSuccess, gameConfig = pcall(require, cfgFile)
        print(string.format("load GameConfig[%s] %s", cfgFile, isSuccess and "success" or "failed"))
     
        if not isSuccess then
            -- 没有require对应game的GameConfig.lua成功
            return nil
        end

        local SettingPath = gameConfig.SettingPath
        if SettingPath then
            return SettingPath
        end

        local CommonSrcPath = gameConfig.CommonSrcPath
        if not CommonSrcPath then
            return nil
        end

        return CommonSrcPath .. ".dialog.RoomSettingDlg"

    end
    return nil
end

--[[
返回值，若成功，返回
gameConfig对应gameid的游戏的gameConfig内容
gamePkg对应gameid的游戏的相对于app的包路径
cfgFile对应gameid的游戏的gameConfig的包路径

否则返回nil
]]
function GameManager:getGameConfigAndPathByGameId(gameid)
    print("GameManager:getGameConfigAndPath(", gameid ,")")
    gameid = tonumber(gameid)
    if not gameid then
        return
    end

    if not self:getGameVersion(gameid) then
        return
    end

    local isPathFromInstall = false
    local gamePkgPath = self.m_gamePackagePathMap[gameid]

    if type(gamePkgPath) ~= "string" then
        -- 没有找到路径
        return
    end

    local gamePkg = gamePkgPath..".src"
    local cfgFile = gamePkg .. ".GameConfig"
    local isSuccess, gameConfig = pcall(require, cfgFile)

    if isSuccess then
        -- 没有require对应game的GameConfig.lua成功
        return gameConfig, gamePkg, cfgFile
    end
    return
end

function GameManager:getInstalledGames()
    local tb = {}
    for k,v in pairs(self.m_gamePackagePathMap) do
        local gameid = tonumber(k)
        if gameid and gameid ~= GameType.HALL and self:getGameVersion(gameid) then
            table.insert(tb,gameid)
        end

    end
    return tb
end

-- 随包安装的游戏，无法删除
function GameManager:getInnerInstalledGames()
    if not self.mInnerInstalledGames then
        local tb = {}
        for k,v in pairs(self.m_gamePackagePathMap) do
            local gameid = tonumber(k)
            if gameid and gameid ~= GameType.HALL and self:getGameVersion(gameid) then
                local gameConfig = "paiyou/" .. v .. "/src/GameConfig.lua"

                if device.platform == "android" then
                    -- 如果是android，則需要拼接至apk的assets層
                    gameConfig = "assets/" .. gameConfig
                end

                local isDirExistInAssets = nb.FileUtils:getInstance():isFileExist(gameConfig)
                print("isDirectoryExist?",isDirExitInAssets,gameConfig)
                if isDirExistInAssets then
                    table.insert(tb,gameid)
                else
                    gameConfig = gameConfig .. "c" -- 判断 luac 的情况
                    isDirExistInAssets = nb.FileUtils:getInstance():isFileExist(gameConfig)
                    print("isDirectoryExist?",isDirExitInAssets,gameConfig)
                    if isDirExistInAssets then
                        table.insert(tb,gameid)
                    end
                end
            end
        end
        self.mInnerInstalledGames = tb
    end
    return self.mInnerInstalledGames
end

-- 是否随包安装的游戏
function GameManager:isInnerInstalledGame(gameid)
    gameid = tonumber(gameid)
    local innerInstalledGames = self:getInnerInstalledGames()
    for k, v in ipairs(innerInstalledGames) do
        if v == gameid then
            return true
        end
    end
    return false
end

--获取游戏分辨率
function GameManager:getGameResolution(gameid)
    gameid = checkint(gameid)
    return GameResolutionMap[gameid] or {1280, 720};
end


function GameManager:getGameAutoscale(gameid)
    gameid = checkint(gameid)
    local autoscaleType = type(GameAutoscaleMap[gameid])
    if autoscaleType == "function" then
        return GameAutoscaleMap[gameid]() or display.getFitAutoScale("SHOW_ALL")
    elseif autoscaleType == "string" then
        return GameAutoscaleMap[gameid]
    end
    return display.getFitAutoScale("SHOW_ALL")
end

function GameManager:getGameVerticalScreen(gameid)
    gameid = checkint(gameid)
    return GameVerticalScreen[gameid] or ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE;
end

--获取子游戏框架类型 1:新框架 0：旧框架
function GameManager:getGameDependFrame(gameid)
    gameid = checkint(gameid)
    return GameDependFrame[gameid] or 0;
end

--获取子游戏依赖的大厅最小版本号
function GameManager:getGameDependHallMinVersion(gameid)
    gameid = checkint(gameid)
    return GameDependHallMinVersion[gameid] or 0;
end

--获取大厅支持的游戏最低可玩的版本号
function GameManager:getGamePlayableMinVersion(gameid)
    for k, v in ipairs(self.m_gamesPlayableConfig) do
        if tonumber(v.gameid) ==  tonumber(gameid) then
            return v.ver or 0;
        end
    end

    return 0;
end

--判断游戏是否兼容
--兼容条件 1：子游戏版本号 >= 大厅所依赖的子游戏最小版本号
--         2：大厅版本号 >= 子游戏依赖的大厅版本号
function GameManager:isGamePlayable(gameid)
    gameid = checkint(gameid)
    -- local isGamePlayable = (self:getGameVersion(gameid) >= self:getGamePlayableMinVersion(gameid) )
    --         and ( self:getGameVersion(GameType.HALL) >= self:getGameDependHallMinVersion(gameid) );
    local isGamePlayable = true

    self:__log("isGamePlayable", "gameid = ", gameid, "isGamePlayable = ", isGamePlayable);
    return isGamePlayable;
end

--获取游戏名字
function GameManager:getGameName(gameid)
    gameid = checkint(gameid)
    return GameNameMap[gameid] or "";
end

--获取大厅顶部游戏图标
function GameManager:getGameHallTitleFile(gameid)
    gameid = checkint(gameid)
    return GameHallTitleMap[gameid] or "";
end

--判断游戏是否已经初始化
function GameManager:getInitStatus(gameid)
    gameid = checkint(gameid)
    return self.m_gameInitStatus[gameid];
end

--获取初始化后的游戏列表
function GameManager:getInitedGameIds()
    local gameids = {};
    for id, value in pairs(self.m_gameInitStatus) do
        if value then
            table.insert(gameids, id);
        end
    end
    return gameids;
end

--获取大厅依赖的apkVersion
function GameManager:getHallDependentApkVersion()
    return self.m_apkVersion or "";
end

--获取版本号
function GameManager:getApkVerison()
    return kClientInfo:getApkVersion();
end

--设置是否在模块里面
function GameManager:setIsInModule(isInModule)
    self.m_isInModule = isInModule;
end

--获取是否在模块里面
function GameManager:isInModule()
    return self.m_isInModule;
end

--设置是否在房间内
function GameManager:setIsInRoom(isInRoom)
    self.m_isInRoom = isInRoom;
end

--获取是否在房间内
function GameManager:isInRoom()
    return self.m_isInRoom;
end

--获取是否在大厅
function GameManager:isInHall()
    return (not self.m_isInRoom and not self.m_isInModule);
end

--设置当前游戏id
function GameManager:setCurGameId( gameid)
    gameid = tonumber(gameid);
    if self.m_curGameId == gameid then
        return;
    end

    self.m_lastGameId = self.m_curGameId;
    self.m_curGameId = gameid;
end

--获取当前游戏id
function GameManager:getCurGameId()
    return self.m_curGameId or 0;
end

--设置上一次的游戏id
function GameManager:setLastGameId(gameid)
    gameid = checkint(gameid)
    self.m_lastGameId = gameid;
end

--获取上一次的游戏id
function GameManager:getLastGameId()
    return self.m_lastGameId or 0;
end


--重置游戏gameConfig中的数据，防止游戏间的相互影响
function GameManager:__resetGameConfigVariable()

end


--加载游戏中的文件
function GameManager:__loadFiles(gameid, isUpdate)
    if GameLoadFileFun[gameid] then
        if GameLoadFileFun[gameid] then

            if type(GameLoadFileFun[gameid].commonLoadFun) == "function" then
                GameLoadFileFun[gameid].commonLoadFun();
            end
            
            -- if gameid == GameType.HALL then
            --    
            -- else
            --    
            -- end

            if type(GameLoadFileFun[gameid].gameLoadFun) == "function" then
                GameLoadFileFun[gameid].gameLoadFun(isUpdate);
            end
        end
    end
end

return GameManager