local PluginsManager = class("PluginsManager")

local pluginId = 0
local function genPluginId()
	pluginId = pluginId + 1
	return pluginId
end

function PluginsManager:ctor()
	self._plugins = {}
end




-- function PluginsManager:addPlugin(name,)
	
-- end



return PluginsManager