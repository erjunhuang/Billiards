local UrlImage = class("UrlImage",function()
	return display.newNode()
end)

function UrlImage:ctor(defaultImg,tsize)
	self:enableNodeEvents()
	self.__imgLoaderId = game.ImageLoader:nextLoaderId()
	self.__tsize = tsize
	self.__defaultImg = defaultImg
	self.__image = display.newSprite(defaultImg):addTo(self)
	-- print("~~~~~~~~~~~UrlImage:ctor", tostring(self.__image == nil), defaultImg)
	-- print(debug.traceback("", 2))
	local imgSize = self.__image:getContentSize()
	if tsize then
		self:size(tsize.width,tsize.height)
	end
	
	self:addjustSize(self.__image,imgSize.width,imgSize.height)

end

function UrlImage:setImageLoadCallback(callback)
	self.__callback = callback
end

function UrlImage:getSprite()
	return self.__image
end

function UrlImage:addjustSize(target,orgW,orgH)
	if not self.__tsize then
		return
	end
	if target then
		target:setScaleX(self.__tsize.width / orgW)
    	target:setScaleY(self.__tsize.height / orgH)
	end
end

function UrlImage:loadUrl(url,urlType)
	-- print("UrlImage:loadUrl==",url)
	urlType = urlType or game.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
	game.ImageLoader:loadAndCacheImage(
        self.__imgLoaderId, 
        url, 
        handler(self, self.onImageLoadComplete_), 
        urlType
    )
end

function UrlImage:setDefaultImg(img,stype)
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


function UrlImage:onImageLoadComplete_(success, sprite,path)
	print(success,"UrlImage:onImageLoadComplete_")
	if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        if self.__image then
        	self.__image:setTexture(tex)
	        self.__image:setTextureRect(nb.rect(0, 0, texSize.width, texSize.height))
	        self:addjustSize(self.__image,texSize.width, texSize.height)
        end
    end
    if self.__callback then
    	self.__callback(success, sprite,path)
    end
end

function UrlImage:cancel()
	if self.__imgLoaderId then
		game.ImageLoader:cancelJobByLoaderId(self.__imgLoaderId)
		self.__imgLoaderId = nil
	end
end

function UrlImage:onCleanup()
	if self:getReferenceCount() <= 1 then
		-- delete前
		self:cancel()
	end
end

return UrlImage