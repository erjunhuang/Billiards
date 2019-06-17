local UserDefault = class("UserDefault")

local instance

function UserDefault.getInstance()
    instance = instance or UserDefault.new()
    return instance
end


function UserDefault:ctor( ... )
	-- body
end

function UserDefault:setStringForKey(key,value)
	PlayerPrefs.SetString(key, value);
end

function UserDefault:getStringForKey(key,defaultValue)
	defaultValue = defaultValue or ""
	PlayerPrefs.GetString(key, defaultValue);
end


function UserDefault:setFloatForKey(key,value)
	PlayerPrefs.SetFloat(key, value);
end

function UserDefault:getFloatForKey(key,defaultValue)
	defaultValue = defaultValue or 0
	PlayerPrefs.GetFloat(key, defaultValue);
end



function UserDefault:setIntForKey(key,value)
	PlayerPrefs.SetInt(key, value);
end

function UserDefault:getIntForKey(key,defaultValue)
	defaultValue = defaultValue or 0
	PlayerPrefs.GetInt(key, defaultValue);
end


function UserDefault:deleteKey(key)
	PlayerPrefs.DeleteKey(key);
end

function UserDefault:deleteAll()
	PlayerPrefs.DeleteAll();
end

function UserDefault:hasKey(key)
	PlayerPrefs.HasKey(key);
end

function UserDefault:flush()
	PlayerPrefs.Save();
end


return UserDefault