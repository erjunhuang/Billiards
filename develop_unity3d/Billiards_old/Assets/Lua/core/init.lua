-- 框架代码
-- require("framework.init")

-- 兼容lua string.format 对boolean不支持, 而luajit支持boolean
-- do
--   local strformat = string.format
--   function string.format(format, ...)
--     local args = {...}
--     local match_no = 1
--     for pos, type in string.gmatch(format, "()%%.-(%a)") do
--       if type == 's' then
--         args[match_no] = tostring(args[match_no])
--       end

--       match_no = match_no + 1
--     end

--     return strformat(format, table.unpack(args, 1, select('#', ...)))
--   end
-- end

local CURRENT_MODULE_NAME = ...

local core            = core or {}
_G.core               = core
core.PACKAGE_NAME     = string.sub(CURRENT_MODULE_NAME, 1, -6)
core.Logger           = import(".util.Logger")
--语言包函数
core.HttpService      = import(".http.HttpService")
-- core.ImageLoader      = import(".http.ImageLoader")
-- core.EventCenter      = import(".event.EventCenter")
-- core.DataProxy        = import(".proxy.DataProxy")
-- core.I18n             = import(".i18n.I18nUtil")
-- core.ObjectPool       = import(".util.ObjectPool")
core.SchedulerPool    = import(".util.SchedulerPool")
core.SocketBase       = import(".socket.SocketBase")
core.Protocols        = import(".socket.Protocols")
core.SocketReader     = import(".socket.SocketReader")
core.SocketWriter     = import(".socket.SocketWriter")
core.SocketProcesser  = import(".socket.SocketProcesser")
-- core.DirtyWordFilter  = import(".util.DirtyWordFilter")

--初始化全局T函数
-- local i18n = nb.load("i18n")
-- T = i18n.T


-- local isSucc,struct = pcall(require,"struct")
-- if isSucc and type(struct) ~= "nil" then
    core.Socket = import(".socket.SocketNew")
-- else
    -- pcall(require,"pack")
--     core.Socket = import(".socket.Socket")
-- end

import(".util.functions").exportMethods(core)

return core
