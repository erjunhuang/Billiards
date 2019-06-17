



if type(DEBUG) ~= "number" then DEBUG = 0 end

local CURRENT_MODULE_NAME = ... or "init"

nb = nb or {}
nb.PACKAGE_NAME = ""--string.sub(CURRENT_MODULE_NAME, 1, -6)

require "misc.functions"
list = require "misc.list"
Time = require "unityengine.Time"
require "unityengine.shortapi"
require "misc.event"
require "misc.Timer"
require "misc.package_support"
require "misc.utf8"

printInfo("")
printInfo("# DEBUG                        = " .. DEBUG)
printInfo("#")

local rapidjson = require("misc.json")
json = rapidjson

cs_coroutine = require("misc.cs_coroutine")

nb.register("event", require("components.event"))
nb.register("touch", require("components.touch"))
 -- export global variable
local __g = _G
nb.exports = {}
setmetatable(nb.exports, {
    __newindex = function(_, name, value)
        rawset(__g, name, value)
    end,

    __index = function(_, name)
        return rawget(__g, name)
    end
})

-- disable create unexpected global variable
function nb.disable_global()
    setmetatable(__g, {
        __newindex = function(_, name, value)
            error(string.format("USE \" nb.exports.%s = value \" INSTEAD OF SET GLOBAL VARIABLE", name), 0)
        end
    })
end

function nb.enable_global()
    setmetatable(__g, {
        __newindex = function(_, name, value)
            rawset(__g, name, value)
        end
    })
end