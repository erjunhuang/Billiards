local BaseScene = class("BaseScene")


function BaseScene:ctor(name,controller)
	-- self:enableNodeEvents()
	self.__name = name
	self.__controller = controller
end

function BaseScene:needKeypadEvent(need)
	-- if device.platform == "android" then
	-- 	if need then
	-- 		if not self.__touchLayer then
	-- 			self.__touchLayer = display.newLayer()
	-- 			self:addChild(self.__touchLayer)
	-- 		end

	-- 		local listener = nb.EventListenerKeyboard:create()
 --        	listener:registerScriptHandler(handler(self,self.__onKeypadEvent), nb.Handler.EVENT_KEYBOARD_PRESSED )
	-- 		local eventDispatcher = self.__touchLayer:getEventDispatcher()
 --        	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.__touchLayer)
	        
	--     else
	--     	if self.__touchLayer then
	--     		self.__touchLayer:removeFromParent()
	--     		self.__touchLayer = nil
	--     	end
	-- 	end
		
	-- end
end


function BaseScene:__onKeypadEvent(keyCode, event)
	-- if keyCode == nb.KeyCode.KEY_BACK then
 --        if not game.PopupManager:removeTopPopupIf() then
 --            self:onKeypadBackEvent(event)
 --        end
 --    elseif keyCode == nb.KeyCode.KEY_MENU then
 --        self:onKeypadMenuEvent(event)
 --    else
 --    	self:onKeypadEvent(keyCode, event)
 --    end
end

function BaseScene:onKeypadEvent(keyCode, event)

end


function BaseScene:onKeypadBackEvent(event)
	
end



function BaseScene:onKeypadMenuEvent(event)

end


function BaseScene:onEnter()
	-- self.__controller:onEnter()
end

function BaseScene:onExit()
	-- self.__controller:onExit()
end

function BaseScene:onEnterTransitionFinish()
	-- self.__controller:onEnterTransitionFinish()
end

function BaseScene:onExitTransitionStart()
	-- self.__controller:onExitTransitionStart()
end

function BaseScene:onCleanup()
	print("BaseScene:onCleanup", tostring(self.__name))
	if self.__controller then
		self.__controller:dispose()
	end
end

return BaseScene