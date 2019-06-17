local PageItem = class("PageItem",function()
	return ccui.Layout:create()
end)


function PageItem:ctor(pageIdx)
	self.pageIdx_ = pageIdx
end


function PageItem:setOwner(owner)
	self.owner_ = owner
end




function PageItem:setData(data)
	
end



return PageItem