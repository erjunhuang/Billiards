local ListView = class("ListView",function()
	return ccui.ListView:create()
end)


function ListView:ctor(itemClass)
	self.itemClass_ = itemClass
end



function ListView:setData(datas)
	if not datas then
		return

	end

	self:removeAllChildren()
	for i,v in ipairs(datas) do
		local item = self.itemClass_.new(i)
		item:setOwner(self)
		item:setData(v)
		item:setCascadeOpacityEnabled(true)
		item:setCascadeColorEnabled(true)
		self:addChild(item)
	end

	self:requestDoLayout()
	
end

return ListView




