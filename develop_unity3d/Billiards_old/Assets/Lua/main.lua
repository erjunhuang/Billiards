

local __G__TRACKBACK__ = function(msg)
     local msg_s = debug.traceback(msg, 3)
     print(msg_s)
     return msg_s
 end






 local function loadBaseModule()
   -- local socket = require 'socket' 
   -- print(socket.gettime())

   print("loadBaseModule")
    require "config"
    require "nbinit"
    require("core.init")

    require("appentry")

    -- local scheduler = require(nb.PACKAGE_NAME .. ".scheduler")
    -- scheduler.scheduleUpdateGlobal(function( ... )
    --   -- body
    --   print("scheduleUpdateGlobal","0000")
    -- end,{})
    -- local server = import("gamehall.net.HallSocket").getInstance()
    -- server:openSocket("192.168.1.158",11020,true)

    --test
     --SceneManager.LoadScene("Billiard",SceneManagement.LoadSceneMode.Additive);

    -- nb.exports.appconfig = require("appconfig")

    -- local a 
    -- a = cs_coroutine.start(function()
     
    --  local m_webRequest = CS.UnityEngine.Networking.UnityWebRequest.Get("http://www.baidu.com")

    -- coroutine.yield(m_webRequest:SendWebRequest())

    -- CS.UnityEngine.Debug.Log("responseCode" .. m_webRequest.downloadedBytes);

    -- for k,v in pairs(m_webRequest) do
    --   print("k:",k,"v:",v)
    -- end




    -- print("Download",m_webRequest.downloadHandler.text)

    -- ("Download Error:" + m_webRequest.error)

    -- cs_coroutine.stop(a)
    --   print('coroutine a stoped')
  -- end)


--   core.HttpService.GET_URL("http://www.baidu.com", {}, function ( ... )
--         -- body
--         print("11111111111")
--     end, function( ... )
--         -- body
--         print("22222222222222")
--     end)

--   core.HttpService.GET_URL("http://192.168.1.158/game/game/first.php", {}, function ( ... )
--        print("3333333333")
--     end, function( ... )
--         -- body
--         print("444444444444")
--     end)


-- local ttt = {appVersion="1.0.0",appid=10,hallVersion="1.0.0.0",games="",time=1553859002,demo=1,lastLoginMid=10213}


--   core.HttpService.POST_URL("http://192.168.1.158/game/game/first.php", ttt, function ( ... )
--         print("5555555555555")
--     end, function( ... )
--         -- body
--         print("66666666666666")
--     end)


  
end



local function main()
	print("main")

	loadBaseModule()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end