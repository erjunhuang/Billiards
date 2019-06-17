local PageView = class("PageView",function()
	return ccui.PageView:create()
end)


function PageView:ctor(itemClass,...)
	self.itemClass_ = itemClass
	self.args_ = {...}
	
end

function PageView:setData(datas)
	if not datas then
		return
	end
	self.datas_ = datas
	self:removeAllPages()
	for i,v in ipairs(datas) do
		local item = self.itemClass_.new(i)
		item:setOwner(self)
		item:setData(v)
		self:addPage(item)
	end
end



function PageView:getData()
	return self.datas_
end






return PageView