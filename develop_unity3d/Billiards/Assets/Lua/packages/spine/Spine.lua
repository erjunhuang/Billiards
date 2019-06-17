
require "cocos.spine.SpineConstants"

local Spine = {}


function Spine.new(param)
	local datafile = param.datafile
	local texturefile = param.texturefile
	local scale = param.scale or 1

	local removeSelf = param.removeSelf and true or false
	local complete = param.complete
	local loopComplete = param.loopComplete

	local skeletonNode = sp.SkeletonAnimation:create(datafile, texturefile, scale)
	if skeletonNode then

		-- skeletonNode.play = function(self,track,anim,loop)
		-- 	anim = anim or animname
		-- 	loop = loop or loop
		-- 	loop = loop or false
		-- 	self:setAnimation(track,anim, loop);
		-- end

		-- skeletonNode.stop = function(self,track)
		-- 	self:clearTrack()
		-- end

		-- skeletonNode.stopAll = function(self)
		-- 	self:clearTracks()
		-- end



		-- skeletonNode:enableNodeEvents()
		-- if removeSelf or complete then
		-- 	skeletonNode:registerSpineEventHandler(function (event)
		-- 		--animation
		--       print(string.format("[spine] %d complete: %d", 
		--                               event.trackIndex,
		--                               event.loopCount))

		--       	if complete then
		-- 			complete(event)
		-- 		end

		-- 		if removeSelf then
		-- 			skeletonNode:performWithDelay(function( ... )
		-- 				skeletonNode:removeSelf()
		-- 			end,0.1)
		-- 		end

		--   end, sp.EventType.ANIMATION_COMPLETE)

		-- end

		-- if loopComplete then
		-- 	skeletonNode:registerSpineEventHandler(function (event)
		-- 		--animation
		--       print(string.format("[spine] %d complete: %d", 
		--                               event.trackIndex,
		--                               event.loopCount))

		--       	if loopComplete then
		-- 			loopComplete(event)
		-- 		end

		--   end, sp.EventType.ANIMATION_COMPLETE)

		-- end

		-- skeletonNode.onCleanup = function(self)
			
		-- end

	end
	return skeletonNode
end


return Spine