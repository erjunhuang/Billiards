
local channel = require("channel")

local ChannelConfig = 
{
	------------------------------------------------------牌友---------------------------------------------------------------------
	[10] = 
	{
		["device"] = "android",
		["appid"] = 10,
		["name"] = "牌友棋牌",
		["lang"] = "zh_CN",
		["wxAppid"] = "wxdb92011c4d13b2f7",
		["localServerUrl"] = "http://192.168.1.158/game/game/first.php",
		["localPublishServerUrl"] = "http://192.168.1.158/gamerelease/game/first.php",
		["onlineServerUrl"] = 
		{
			"http://qg.ode.cn/game/first.php",
			"http://qgbk.ode.cn/game/first.php",
			"http://qgios.ode.cn/game/first.php",
		},
		["onlineTestServerUrl"] = "http://qgtest.ode.cn/game/first.php",
		["buglyAppid"] = "875afd10ab",
		["gvoiceInfo"] = {appID = "1721988055",appKey="49283384a6722e513e2b54d7f869bc79"},
		["amapAppKey"] = "bd6e9c085d8dddce59da71187dbabeb8",
		["xlAppid"] = "R10Z4KeesxekETT0",
		["cnChat"] = {appId = "cn74479dbb0a434d",appSecret = "72fe6962d65f496a824353971c7183c"},
		["wxShareAppids"] = 
		{
			{name="竹报平安",appid="wx2de3e82d62570ab4",appSec="d8f44b60d2a71eeb28548df5687d008c"},
			{name="凤凰来仪",appid="wx8e0bb7d7b3382d6b",appSec="2df1de1da8f29732b73a60be432aad63"},
			{name="景星庆云",appid="wx5765e95cfddd897f",appSec="b8386b3722611d5b0822fa64ca835aba"},
			{name="三阳开泰",appid="wx5e65cc8ab53acbc1",appSec="e3b728bb7f0e82b34f9c5cd27e1d38b0"},
			{name="福地洞天",appid="wx421435a98ca1e31c",appSec="6ead49cf51bbe2f947ca30c7181b55ab"},
			{name="迎吉",appid="wxa297b1fc6af9b0d2",appSec="831dbbaa593910947bd22a9f90f871a5"},
			{name="赵公元帅",appid="wx9b9ce4a5d0c72ec1",appSec="9668982aacdc09f466061973687c49f5"},
			{name="接天禄",appid="wx8f9f2ab62248db38",appSec="5727d1a165c8082e7c7d6a2b7405098e"},
			
		},
		["hbpayMini"] = {name = "海贝小程序",wxappid = "wx54f060d241817a38",miniappid = "gh_5464122359e4"}

	},
	[1010] = 
	{
		["device"] = "ios",
		["appid"] = 1010,
		["name"] = "牌友棋牌",
		["lang"] = "zh_CN",
		["wxAppid"] = "wxdb92011c4d13b2f7",
		["localServerUrl"] = "http://192.168.1.158/game/game/first.php",
		["localPublishServerUrl"] = "http://192.168.1.158/gamerelease/game/first.php",
		["onlineServerUrl"] = 
		{
			"http://qg.ode.cn/game/first.php",
			"http://qgbk.ode.cn/game/first.php",
			"http://qgios.ode.cn/game/first.php",
		},
		-- ["onlineServerUrl"] = {"http://qgios.ode.cn/game/first.php"},
		["onlineTestServerUrl"] = "http://qgtest.ode.cn/game/first.php",
		["gvoiceInfo"] = {appID = "1721988055",appKey="49283384a6722e513e2b54d7f869bc79"},
		["buglyAppid"] = "2e8553130d",
		["amapAppKey"] = "ddf8510b6af671548491f41bec01d12a",
		["xlAppid"] = "R10Z4KeesxekETT0",
		["cnChat"] = {appId = "cn74479dbb0a434d",appSecret = "72fe6962d65f496a824353971c7183c"},
		["newPkgCfg"]=
		{
			bundleId = "org.ode.pyqp",
			wxAppid = "wxa6c82066d8908116",
			amapAppKey = "85704fc7f23ce5b5aa7cdc819853fcc2",
			isnew = 1,
		},
		["wxShareAppids"] = 
		{
			{name="竹报平安",appid="wx2de3e82d62570ab4",appSec="d8f44b60d2a71eeb28548df5687d008c"},
			{name="凤凰来仪",appid="wx8e0bb7d7b3382d6b",appSec="2df1de1da8f29732b73a60be432aad63"},
			{name="景星庆云",appid="wx5765e95cfddd897f",appSec="b8386b3722611d5b0822fa64ca835aba"},
			{name="三阳开泰",appid="wx5e65cc8ab53acbc1",appSec="e3b728bb7f0e82b34f9c5cd27e1d38b0"},
			{name="福地洞天",appid="wx421435a98ca1e31c",appSec="6ead49cf51bbe2f947ca30c7181b55ab"},
			{name="迎吉",appid="wxa297b1fc6af9b0d2",appSec="831dbbaa593910947bd22a9f90f871a5"},
			{name="赵公元帅",appid="wx9b9ce4a5d0c72ec1",appSec="9668982aacdc09f466061973687c49f5"},
			{name="接天禄",appid="wx8f9f2ab62248db38",appSec="5727d1a165c8082e7c7d6a2b7405098e"},

		}	
	},
	[2010] = 
	{
		["device"] = "ios",
		["appid"] = 2010,
		["name"] = "牌友棋牌",
		["lang"] = "zh_CN",
		["wxAppid"] = "wxdb92011c4d13b2f7",
		["localServerUrl"] = "http://192.168.1.158/game/game/first.php",
		["localPublishServerUrl"] = "http://192.168.1.158/gamerelease/game/first.php",
		["onlineServerUrl"] = {"http://qg.ode.cn/game/first.php","http://qgios.ode.cn/game/first.php"},
		["onlineTestServerUrl"] = "http://qgtest.ode.cn/game/first.php",
		["gvoiceInfo"] = {appID = "1721988055",appKey="49283384a6722e513e2b54d7f869bc79"},
		["buglyAppid"] = "2e8553130d",
		["amapAppKey"] = "ddf8510b6af671548491f41bec01d12a",
		["xlAppid"] = "R10Z4KeesxekETT0",
		["cnChat"] = {appId = "cn74479dbb0a434d",appSecret = "72fe6962d65f496a824353971c7183c"}
	},
}


return ChannelConfig[channel]