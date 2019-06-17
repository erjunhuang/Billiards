local BaseController = class("BaseController")

function BaseController:ctor(scene)
	print("BaseController:ctor", tostring(scene == nil))
	self.__scene = scene
	self:addSocketTools()

	self.__baseSchedulerPool = core.SchedulerPool.new()


end




function BaseController:onAppEnterBackground()
	print("BaseController:onAppEnterBackground")
end

function BaseController:onAppEnterForeground()
	print("BaseController:onAppEnterForeground")
end


function BaseController:onResignActive()
	print("BaseController:onResignActive")
end

function BaseController:onBecomeActive()
	print("BaseController:onBecomeActive")
end



function BaseController:addSocketTools()
	print("BaseController:addSocketTools")
end

function BaseController:removeSocketTools()
	
end


function BaseController:onEnter()
	-- self.__enterBackHandler = app:addEventListener("APP_ENTER_BACKGROUND_EVENT",handler(self, self.onAppEnterBackground))
 --    self.__enterForeHandler = app:addEventListener("APP_ENTER_FOREGROUND_EVENT",handler(self, self.onAppEnterForeground))

 --    self.__resignActiveHandler = app:addEventListener("APP_RESIGN_ACTIVE_EVENT",handler(self, self.onResignActive))
 --    self.__becomeActiveHandler = app:addEventListener("APP_BECOME_ACTIVE_EVENT",handler(self, self.onBecomeActive))
   
end

function BaseController:onExit()
	print("BaseController:onExit", self.__scene.__name)
	-- app:removeEventListener(self.__enterBackHandler)
 --    app:removeEventListener(self.__enterForeHandler)
 --    self.__enterBackHandler = nil
 --    self.__enterForeHandler = nil

 --    app:removeEventListener(self.__resignActiveHandler)
 --    app:removeEventListener(self.__becomeActiveHandler)
 --    self.__resignActiveHandler = nil
 --    self.__becomeActiveHandler = nil

end



function BaseController:dispose()
	print("BaseController:dispose", self.__scene.__name)
	self.__baseSchedulerPool:clearAll()
	self.isDisposed_ = true
	self:removeSocketTools();
	self.__scene = nil
end


function BaseController:handleSocketCmd(cmd,...)
	if not self.s_socketCmdFuncMap[cmd] then
		print("Not such socket cmd in current controller");
		return;
	end

	return self.s_socketCmdFuncMap[cmd](self,...);
end



BaseController.s_socketCmdFuncMap = {
	
};




return BaseController