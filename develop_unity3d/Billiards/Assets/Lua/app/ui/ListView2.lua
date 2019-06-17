local ListView = class("ListView")
function ListView:ctor(listView,itemClass)
	self.listView_ = listView
	self.itemClass_ = itemClass



end


function ListView:getNode( ... )
	return self.listView_
end

function ListView:setItemsMargin(margin)
	if self.listView_ then
		self.listView_:setItemsMargin(margin)
	end
end


function ListView:addEventListener(callback)
	if not callback then
		return
	end
	if self.listView_ then
		self.listView_:addEventListener(callback)
	end
end



function ListView:setData(datas)
	if not datas then
		return

	end

	self.listView_:removeAllChildren()
		for i,v in ipairs(datas) do
			local item = self.itemClass_.new(i)
			item:setOwner(self)
			item:setData(v)
			item:setCascadeOpacityEnabled(true)
			item:setCascadeColorEnabled(true)
			self.listView_:addChild(item)
		end

	self.listView_:requestDoLayout()
	
end

return ListView



