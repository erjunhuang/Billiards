local ListItem = class("ListItem",function()
	return ccui.Layout:create()
end)


function ListItem:ctor(index)
	self.index_ = index
end




function ListItem:setData(data)
	self.data_ = data
end


function ListItem:getData(...)
	return self.data_ or {}
end

function ListItem:setOwner(owner)
	self.owner_ = owner
end



return ListItem