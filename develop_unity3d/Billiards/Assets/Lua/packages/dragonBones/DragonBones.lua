-- local factory = db.CCFactory:getFactory()
local factory = db.CCFactory:getInstance()
local scheduler = require("cocos.framework.scheduler")
-- factory:setArmaturePath(nb.FileUtils:getInstance():getWritablePath() .. "updates/res/armatures/")
-- factory:setArmaturePath("res/armatures/")

local DragonBones = {}

DragonBones.START = "start";
DragonBones.LOOP_COMPLETE = "loopComplete";
DragonBones.COMPLETE = "complete";
DragonBones.FADE_IN = "fadeIn";
DragonBones.FADE_IN_COMPLETE = "fadeInComplete";
DragonBones.FADE_OUT = "fadeOut";
DragonBones.FADE_OUT_COMPLETE = "fadeOutComplete";
DragonBones.FRAME_EVENT = "frameEvent";
DragonBones.SOUND_EVENT = "soundEvent";

function DragonBones.new(param)
	assert(param, "DragonBones.new need param")
	assert(param.datafile, "DragonBones.new need param.datafile")
	assert(param.texturefile, "DragonBones.new need param.texturefile")

	local datafile = param.datafile
	local dragonBonesName = param.dragonBonesName
	local texturefile = param.texturefile
	local animname = param.animname
	local armature = param.armature
	local removeSelf = param.removeSelf and true or false
	local complete = param.complete
	local loopComplete = param.loopComplete
	local times = param.times or 1
	local skinName = param.skinName
	local doClean = param.doClean == nil and true  or param.doClean
	dump(param,"param db")
	factory:loadDragonBonesData(datafile,dragonBonesName)
	factory:loadTextureAtlasData(texturefile,dragonBonesName)

	local armatureDisplay = factory:buildArmatureDisplay(armature,dragonBonesName,skinName)

	print("armatureDisplay",armatureDisplay)
	if armatureDisplay then

		armatureDisplay:enableNodeEvents()
		armatureDisplay.playNextFrame = function(self,anim,time)
			anim = anim or animname
			time = time or times
			self.__schedulerHandler = scheduler.performWithDelayGlobal(function ( ... )
				--下一帧在执行
				self.animState = self:getAnimation():play(anim, time);
			end,0.01)
		end

		armatureDisplay.play = function(self,anim,time)
			anim = anim or animname
			time = time or times
			self.animState = self:getAnimation():play(anim, time);
		end

		armatureDisplay.stop = function(self)
			if self.__schedulerHandler then
				scheduler.unscheduleGlobal(self.__schedulerHandler)
				self.__schedulerHandler = nil
			end
			-- if self.animState then
				-- self.animState:stop()
			-- end
			self:getAnimation():reset()
		end

		armatureDisplay.reset = function(self)
			if self.__schedulerHandler then
				scheduler.unscheduleGlobal(self.__schedulerHandler)
				self.__schedulerHandler = nil
			end
			self:getAnimation():reset()
		end

	end

	if armatureDisplay then
		if removeSelf or complete then
			armatureDisplay:getEventDispatcher():setEnabled(true);
			armatureDisplay:addEvent(DragonBones.COMPLETE,function()
				print("complete",complete,"removeSelf",removeSelf)
				if complete then
					complete()
				end

				if removeSelf then
					armatureDisplay:performWithDelay(function( ... )
						armatureDisplay:removeSelf()
						
						-- factory:removeDragonBonesData((dataname or datafile),true)
						-- factory:removeTextureAtlasData((texturename or texturefile),true)
					end,0.1)
				end
			end)
			-- return armatureDisplay
		end

		if loopComplete then
			armatureDisplay:getEventDispatcher():setEnabled(true);
			armatureDisplay:addEvent(DragonBones.LOOP_COMPLETE,function()
				print("loopComplete",loopComplete)
				if loopComplete then
					loopComplete()
				end
			end)
		end

		armatureDisplay.onCleanup = function(self)
			self:reset()
			factory:removeDragonBonesData(dragonBonesName,doClean)
			factory:removeTextureAtlasData(dragonBonesName,doClean)
			armatureDisplay = nil
		end

	end
	

	return armatureDisplay
end


function DragonBones.removeDataByName(dragonBonesName)
	factory:removeDragonBonesData(dragonBonesName,true)
	factory:removeTextureAtlasData(dragonBonesName,true)
end

-- factory:setArmaturePath(nb.FileUtils:getInstance():getWritablePath() .. G_WRITABLE_EXTENSION_PACKAGE_NAME .. "/updates/res/armatures/")
-- factory:setArmaturePath("res/armatures/")

--[[
@param:
	{
		dataname = "Demon",
		armature = "Armature",
		bonesname = "Demon",
		animname = "dead", (string or table)
		times = 1, --默认是1
		removeSelf = true, --全部次数动画完成后是否移除
		complete = function, --全部次数动画完成回调
		loopComplete = function, --每次动画完成回调
	}


-- 动作速度提升为两倍
-- node:setTimeScale(2)
-- node:setFrameEventListener(function(eventName, armatureName, animationName)
-- 		print(eventName, armatureName, animationName)
-- end)

]]
-- function DragonBones:ctor(param)
-- 	self:enableNodeEvents()
-- 	self.param = param
-- 	factory:loadDataByName(param.dataname) --removeDataByName
-- 	local node = factory:buildArmatureDisplay(param.armature, param.bonesname)
-- 	node:addTo(self)
-- 	node:setAnimationEventListener(function(eventType, armatureName, animationName)
-- 		--print("animationEvent", eventType, armatureName, animationName)
-- 		if eventType == "complete" then
-- 			if param.complete then
-- 				param.complete(self)
-- 			end
-- 			if param.removeSelf then
-- 				self:removeSelf()
-- 			end
-- 		elseif eventType == "loopComplete" then
-- 			if param.loopComplete then
-- 				param.loopComplete(self)
-- 			end
-- 		end
-- 	end)
-- 	self.actionNode = node
-- end

-- function DragonBones:setTimeScale(speed)
-- 	if self.actionNode then
-- 		self.actionNode:setTimeScale(speed)
-- 	end
-- end

-- --开始播放
-- function DragonBones:play(anim, times)
-- 	local param = self.param
-- 	if type(param.animname) == "string" then
-- 		anim = anim or param.animname
-- 	elseif type(param.animname) == "table" then
-- 		anim = anim or param.animname[1]
-- 	end
-- 	times = times or param.times
-- 	-- self.animState = self.actionNode:getAnimation():play(anim, times or 1)
-- 	self.actionNode:getAnimation():play(anim, times or 1)
-- end

-- function DragonBones:reset()
-- 	if self.actionNode then
-- 		self.actionNode:getAnimation():reset()
-- 	end
-- end

--停止播放
-- function DragonBones:stop(anim)
-- 	-- if self.animState then
-- 	-- 	self.animState:stop()
-- 	-- end
-- 	local param = self.param
-- 	if type(param.animname) == "string" then
-- 		anim = anim or param.animname
-- 	elseif type(param.animname) == "table" then
-- 		anim = anim or param.animname[1]
-- 	end
-- 	if self.actionNode then
-- 		self.actionNode:getAnimation():stop(anim)
-- 	end
-- end

-- function DragonBones:onCleanup( ... )
-- 	print("DragonBones:onCleanup:" .. self.param.dataname)
-- 	self:reset()
-- 	self.actionNode:dispose()
-- 	self.actionNode = nil
--     factory:removeDragonBonesData(self.param.dataname, false);
--     factory:removeTextureAtlasData(self.param.dataname, false);
	-- local fullpath ={
	-- 	nb.FileUtils:getInstance():getWritablePath() .. G_WRITABLE_EXTENSION_PACKAGE_NAME .. "/updates/res/armatures/" .. self.param.dataname  .."_tex.png",
	-- 	"armatures/" .. self.param.dataname  .."_tex.png"
	-- }
	-- for i, path in ipairs(fullpath) do
	-- 	if nb.FileUtils:getInstance():isFileExist(path) then
	-- 		nb.Director:getInstance():getTextureCache():removeTextureForKey(path) 
	-- 		return
	-- 	end
	-- end
-- end


return DragonBones