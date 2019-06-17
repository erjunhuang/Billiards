
local GetText = import(".Gettext")

local __hash = {}

local _M = {}

local mt = {}
mt.__call = function (t,text, ...)
    local args = {...}
    return string.format(__hash[text] or text, table.unpack(args,1,select('#',...)))
end
setmetatable(_M, mt)


function _M.addMOFromFile(mo_file)
	local tHash = GetText.loadMOFromFile(mo_file)
	if tHash then
		table.merge(__hash,tHash)
	end
end


return _M