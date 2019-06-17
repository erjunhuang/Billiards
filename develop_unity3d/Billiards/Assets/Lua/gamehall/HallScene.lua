local HallController = import("gamehall.HallController")
local HallScene = class("HallScene",game.base.BaseScene)

function HallScene:ctor(uibridge,injectionsTable,viewType,action)

	if injectionsTable then
		for k,v in pairs(injectionsTable) do
	  		-- print("injectionsTable:",k,v)
	  		self[k] = v
	  	end
	end
	
	HallScene.super.ctor(self,"HallScene",HallController.new(self))


	if self.joinRoomBtn then
		self.joinRoomBtn:GetComponent("Button").onClick:AddListener(function()
			print("clicked  joinRoomBtn")


			self.__controller:getTableId()

			
		end)
	end

	if self.joinRoomBtn2 then
		self.joinRoomBtn2:GetComponent("Button").onClick:AddListener(function()
			print("clicked  joinRoomBtn2")


			self.__controller:onGetTableId()

			
		end)
	end

	
end

return HallScene