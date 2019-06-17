local ScreenOrientationManager = class("ScreenOrientationManager")

--屏幕方向
ScreenOrientationManager.SCREEN_ORIENTATION = {
    LANDSCAPE = 1; --横屏
    PORTRAIT = 2;  --竖屏
}

ScreenOrientationManager.s_instance = nil

ScreenOrientationManager.getInstance = function()
    if not ScreenOrientationManager.s_instance then
        ScreenOrientationManager.s_instance = ScreenOrientationManager.new()
    end
    return ScreenOrientationManager.s_instance
end

-- 安卓是异步的，iOS是同步的，win32是模拟的
-- 安卓使用的时候要注意避免出现连续多次触发，或者是在触发转屏时马上触发获取屏幕方向
function ScreenOrientationManager:ctor()
	self.mCurScreenOrientation = ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE
end

function ScreenOrientationManager:getCurScreenOrientation()
	-- return self.mCurScreenOrientation
	if device.platform == "windows" then

	elseif device.platform == "android" then

	elseif device.platform == "ios" then

	end
	print("ScreenOrientationManager:getCurScreenOrientation() => ", self.mCurScreenOrientation)
	return self.mCurScreenOrientation
end


--设置分辨率
--autoscele:
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

function ScreenOrientationManager:__setAutoscaleOrResolution(width, height,autoscale)

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


-- designSize = {width = xxx, height = xxx}
function ScreenOrientationManager:changeScreenOrientation(orientation, designSize,autoscale, callback)
	
	local innerCallback = function(resultTab)
		if designSize and autoscale then
			self:__setAutoscaleOrResolution(designSize.width,designSize.height,autoscale)
		end
		
		if type(callback) == "function" then
			callback(resultTab)
		end
	end

	local director = nb.Director:getInstance()
	local glView = director:getOpenGLView()

	if device.platform == "windows" or device.platform == "mac" then
		-- win32下模拟一个类似的接口
		local resultTab = {}
		resultTab.result = true
		resultTab.orientation = orientation
		resultTab.last_orientation = self.mCurScreenOrientation
		local frameSize = glView:getFrameSize()
		glView:setFrameSize(frameSize.height, frameSize.width)

		self.mCurScreenOrientation = orientation
		innerCallback(resultTab)
    elseif device.platform == "android" then
    	-- 测试用
    	orientation = game.Native:getCurrentScreenOrientation()
		print("current orientation == ", orientation)
    	if orientation == ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE then
    		orientation = ScreenOrientationManager.SCREEN_ORIENTATION.PORTRAIT
    	else
    		orientation = ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE
    	end


    	game.Native:changeScreenOrientation(orientation, function(jsonStr)
			print("changeScreenOrientation callback jsonStr = ", jsonStr)
			local frameSize = glView:getFrameSize()
			glView:setFrameSize(frameSize.height, frameSize.width)

			local resultTab = json.decode(jsonStr)
			-- android 就当全是成功了
			resultTab.result = true

			self.mCurScreenOrientation = resultTab.orientation
			innerCallback(resultTab)
		end)
    elseif device.platform == "ios" then
    	-- 测试用
    	orientation = game.Native:getCurrentScreenOrientation()
    	print("current orientation == ", orientation)
    	if orientation == ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE then
    		orientation = ScreenOrientationManager.SCREEN_ORIENTATION.PORTRAIT
    	else
    		orientation = ScreenOrientationManager.SCREEN_ORIENTATION.LANDSCAPE
    	end

    	local resultTab = game.Native:changeScreenOrientation(orientation)
    	if resultTab then
    		local frameSize = glView:getFrameSize()
			glView:setFrameSize(frameSize.height, frameSize.width)
    		self.mCurScreenOrientation = resultTab.orientation
    		innerCallback(resultTab)
    	end
    end
end

return ScreenOrientationManager