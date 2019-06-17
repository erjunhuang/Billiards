
local channelInfo = require("channelConfig")
local appconfig = {}
appconfig.firstApiUrl 	= channelInfo.onlineServerUrl
appconfig.firstApiKey 	= "onlineServerUrl"
appconfig.appid         = channelInfo.appid
appconfig.phpdemo		= nil
appconfig.cdnGameUrl 	= nil
appconfig.gatewayUrl 	= nil
appconfig.indexUrl 		= nil
appconfig.feedBackUrl 	= nil
appconfig.sendfeedUrl   = nil
appconfig.hotUpdateUrl	= nil -- 检查更新用
appconfig.agreementUrl	= nil
appconfig.isVerify      = nil

appconfig.wxAppid = channelInfo.wxAppid
appconfig.buglyAppid = channelInfo.buglyAppid
appconfig.gvoiceInfo = channelInfo.gvoiceInfo
appconfig.amapAppKey = channelInfo.amapAppKey
appconfig.xlAppid = channelInfo.xlAppid
appconfig.lang = channelInfo.lang or "zh_CN"
appconfig.channelValue = channelInfo.channelValue or ""
appconfig.appName = channelInfo.name or ""

appconfig.cnChat = channelInfo.cnChat
appconfig.isnew = channelInfo.isnew
appconfig.wxShareAppids = channelInfo.wxShareAppids

appconfig.hallVer = "1.0.0.0"
appconfig.enableHallUpdate = false
appconfig.enableGameUpdate = false

return appconfig
