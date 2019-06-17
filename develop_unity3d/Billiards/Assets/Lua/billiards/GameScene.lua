local GameController = import("billiards.GameController")
local GameScene = class("GameScene",game.base.BaseScene)
function GameScene:ctor(uibridge,injectionsTable)
	
	print("uibridge",uibridge)
	
  	-- print(injectionsTable,"injectionsTable")
  	for k,v in pairs(injectionsTable) do
  		-- print("injectionsTable:",k,v)
  		self[k] = v
  	end

  	GameScene.super.ctor(self,"GameScene",GameController.new(self))

	local bWidth = self._ballMaskBitmap.width
    local bHeight = self._ballMaskBitmap.height

    print("bWidth:",bWidth,"bHeight:",bHeight)


     self:createNodes()
    self.__controller:createNodes()

	-- self.__uibridge = uibridge
	-- self.__uiTable = uibridge.gameObject
	-- self.__name = name

end


function GameScene:createNodes( ... )
	-- body
end


function GameScene:onDestroy()
	print("GameScene:onDestroy")

	if self.__controller then
		self.__controller:dispose()
	end
end


return GameScene