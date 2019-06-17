

local util = require 'xlua.util'

--- TODO: 改为，先从GameObject里查找CoroutineRunner对象并获取对应的MonoBehaviour，如果没有，再创建
local gameobject = CS.UnityEngine.GameObject('LuaCoroutineRunner')
CS.UnityEngine.Object.DontDestroyOnLoad(gameobject)
local cs_coroutine_runner = gameobject:AddComponent(typeof(CS.LuaInterface.LuaCoroutineRunner))

return {
    start = function(...)
	    return cs_coroutine_runner:StartCoroutine(util.cs_generator(...))
	end;

	stop = function(coroutine)
	    cs_coroutine_runner:StopCoroutine(coroutine)
	end
}
