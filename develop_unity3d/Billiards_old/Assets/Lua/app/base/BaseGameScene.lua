local BaseScene = import(".BaseScene")
local BaseGameScene = class("BaseGameScene",BaseScene)


function BaseGameScene:ctor(name,controller)
	assert(controller ~= nil,"controller can not be nil")
	BaseGameScene.super.ctor(self,name,controller)
	nb.bind(self,"event")

	self:createNodes()
	self.__controller:createNodes()

	self:needKeypadEvent(true)

end


function BaseGameScene:onKeypadBackEvent(event)
	BaseGameScene.super.onKeypadBackEvent(self,event)
	self:onBackToLobby()
end

function BaseGameScene:createNodes( ... )
	self.__nodes = {}
	self.__nodes.backgroundNode = display.newNode():addTo(self, 1)  --背景层
	self.__nodes.dealerNode = display.newNode():addTo(self, 2)      -- 荷官层
	self.__nodes.seatNode = display.newNode():addTo(self, 3)        --座位层
    self.__nodes.chipNode = display.newNode():addTo(self, 4)        --金币，筹码层
    self.__nodes.cardNode = display.newNode():addTo(self, 5)        --手牌，扑克层
    self.__nodes.dealCardNode = display.newNode():addTo(self, 6)    --发牌，发牌动画层
    self.__nodes.oprNode = display.newNode():addTo(self, 7)         --操作区层
    self.__nodes.animNode = display.newNode():addTo(self, 8)        --动画层
    self.__nodes.otherNode = display.newNode():addTo(self, 9)       --其他
    self.__nodes.menuNode = display.newNode():addTo(self, 10)       --菜单层
    self.__nodes.topNode = display.newNode():addTo(self, 11)        --顶层
end


--返回
function BaseGameScene:onBackToLobby( ... )
	 
	printInfo("BaseGameScene:onBackToLobby")
	game.gameManager:startGame(GameType.HALL)
end




return BaseGameScene