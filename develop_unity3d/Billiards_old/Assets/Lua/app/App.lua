require("config")
require("nbinit")
require "core.init"
require "app.init"

print("load app")
local App = class("App", nb.load("mvc").AppBase)

function App:ctor()
    App.super.ctor(self)
end

function App:run()

    --test
     
   SceneManager.LoadScene("Hall",SceneManagement.LoadSceneMode.Single);
    -- game.gameManager:startGame(GameType.HALL)
end


function App:enterScene(scenePackageName,isPushScene,transitionType, time, more , ...)
    -- local scenePackageName = sceneName
    -- local sceneClass = require(scenePackageName)
    -- local scene = sceneClass.new(...)
    -- if not isPushScene then
    --     display.runScene(scene,transitionType, time, more)
    -- else
    --     display.pushScene(scene,transitionType, time, more)
    -- end

end


function App:onEnterBackground()
	App.super.onEnterBackground(self)
	-- audio.pauseMusic()
end

function App:onEnterForeground()
	App.super.onEnterForeground(self)
	-- audio.resumeMusic()
end


return App
