local HeadView = class("HeadView",function()
	return display.newNode()
end)


function HeadView:ctor(defaultImg,tsize)
	self:enableNodeEvents()
	self:setCascadeOpacityEnabled(true)
	self:setCascadeColorEnabled(true)
	self.__imgLoaderId = game.ImageLoader:nextLoaderId()
	self.__tsize = tsize
	self.__defaultImg = defaultImg

	self.__image = display.newSprite(defaultImg)
	:addTo(self,2)
	local imgSize = self.__image:getContentSize()

	self:size(tsize.width,tsize.height)

	self:addjustSize(self.__image,imgSize.width,imgSize.height)

end

function HeadView:setMaskImg(filename, x, y, size)
	x = x or 0
	y = y or 0
	self.__maskImg = display.newSprite(filename)
		:addTo(self,1)
		:pos(x,y)
	local maskSize = self.__maskImg:getContentSize()
	if size then
		self:addjustSize(self.__maskImg,maskSize.width,maskSize.height)
	end
	
	return self
end

function HeadView:setBoxImg(filename, x, y,size)
	x = x or 0
	y = y or 0
	self.__boxImg = display.newSprite(filename)
	:addTo(self,2)
	:pos(x,y)

	local boxSize = self.__boxImg:getContentSize()
	if size then
		self:addjustSize(self.__boxImg,boxSize.width,boxSize.height)
	end

	return self
end


function HeadView:addjustSize(target,orgW,orgH)
	if not self.__tsize then
		return
	end
	if target then
		target:setScaleX(self.__tsize.width / orgW)
    	target:setScaleY(self.__tsize.height / orgH)
	end
end



function HeadView:loadUrl(url,urlType)
	if not url or url =="" then
		self:setDefaultImg()
		return
	end
	urlType = urlType or game.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
	game.ImageLoader:loadAndCacheImage(
        self.__imgLoaderId, 
        url, 
        handler(self, self.onImageLoadComplete_), 
        urlType
    )
end


function HeadView:setDefaultImg(img,stype)
	self.__defaultImg = img or self.__defaultImg
	if self.__image and self.__defaultImg and string.len(self.__defaultImg) > 0 then
		if not stype or stype == 0 then
			local tex = nb.Director:getInstance():getTextureCache():addImage(self.__defaultImg)
	        if not tex then
	            return
	        else
		        local texSize = tex:getContentSize()
		        self.__image:setTexture(tex)
		        self.__image:setTextureRect(nb.rect(0, 0, texSize.width, texSize.height))
		        self:addjustSize(self.__image,texSize.width, texSize.height)
	        end
		else
			self.__image:setSpriteFrame(img)

		end
		
	end
end


function HeadView:onImageLoadComplete_(success, sprite)
	if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        if self.__image then
        	self.__image:setTexture(tex)
	        self.__image:setTextureRect(nb.rect(0, 0, texSize.width, texSize.height))
	        self:addjustSize(self.__image,texSize.width, texSize.height)
	        self:setBlend()
        end
    end
end


function HeadView:setBlend()
	if self.__image and self.__maskImg then
        self.__maskImg:setBlendFunc({src = gl.ONE_MINUS_SRC_ALPHA, dst = gl.ONE_MINUS_SRC_COLOR})
        self.__image:setBlendFunc({src = gl.ONE_MINUS_DST_ALPHA, dst = gl.DST_ALPHA})
    end
end


function HeadView:cancel()
	if self.__imgLoaderId then
		game.ImageLoader:cancelJobByLoaderId(self.__imgLoaderId)
	end
end


function HeadView:onCleanup()
	self:cancel()
end


return HeadView