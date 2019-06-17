-- local http = game.http
-- local logger = core.Logger.new("GameHttp")
-- local appconfig = require("appconfig")
local GameHttp = {}


function GameHttp.cancel(requestId)
  http.cancel(requestId)
end


function GameHttp.setSessionKey(sesskey)
    http.setSessionKey(sesskey)
end

function GameHttp.login(loginType, sitemid, access_token,sesskey, extern, resultCallback, errorCallback,extGame)
	  print("sitemid",sitemid)
    print("loginType",loginType)
    local deviceInfo = game.Native:getDeviceInfo()
    local gameparams = {
       sig_sitemid = sitemid,
       -- mac         = game.Native:getMacAddr(), --移动终端设备号 
       -- apkVer      = BM_UPDATE.VERSION, --游戏版本号，如"4.0.1","4.2.1" 
       -- sdkVer      = '1.0.0', --移动终端设备操作系统， 例如 "android_4.2.1"， "ios_4.1"
       -- net         = deviceInfo.networkType, --移动终端联网接入方式，例如 "wifi(1)", "2G(2)", "3G(3)", "4G(4)", "离线(-1)"。
       -- simOperatorName = deviceInfo.simNum, --移动终端设备所使用的网络运营商,如"电信"，"移动"，"联通" 
        -- machineType = deviceInfo.deviceModel, --移动终端设备机型.如："iphone 4s TD", "mi 2S", "IPAD mini 2" 
       -- pixel = string.format("%d*%d", display.width, display.height),--移动终端设备屏幕尺寸大小，如“1024*700”      
       -- idfa = game.Native:getIDFA() , -- 设备标识 --android 为设备ID，IOS为IDFA
       access_token = access_token,
    }  

    if extGame then
      table.merge(gameparams,extGame)
    end



    local sig = nb.utils_.md5(http.shJoins(gameparams,0))
    gameparams.sig = sig

    local params = 
    {
    	appid = appconfig.appid,
    	gameParam = json.encode(gameparams),
    	lmode = loginType,
      sesskey = sesskey,
      version = require("app.manager.GameManager").getInstance():getGameVersion(GameType.HALL),
      gameid = 0,
      extern = extern,
	}  


  -- dump(params,"login_params")


    local NewUpdateMgr = import("gamehall.src.update.NewUpdateMgr")
    if NewUpdateMgr then
        local appVersion = NewUpdateMgr.getInstance():getAppVersion() or params.version
        params.appVersion = appVersion
    end

  
  return http.postUrl(appconfig.indexUrl, params, 
        function(data) 
            local retData = json.decode(data) 
            if type(retData) == "table" and retData.code and retData.code == 1 then                
                http.toOneDimensionalTable(retData.data)                
                typeFilter(retData.data, {
                    [tostring] = {'aUser.mavatar', 'aUser.memail', 'aUser.sitemid'},
                    [tonumber] = {
                        'aUser.lid', 'aUser.mid', 'aUser.mlevel', 
                        'aUser.mltime', 'aUser.win',  'aUser.lose','aUser.money', 'aUser.sitmoney', 
                        'isCreate', 'isFirst', 'mid', 'aUser.exp'
                    }
                })
                retData.data.uid = retData.data.mid

                if DEBUG > 4 then
                    dump(retData.data, "retData.data")
                end
                http.setSessionKey(retData.data.sesskey)
                http.setLoginType(loginType)
                http.setDefaultURL(appconfig.gatewayUrl)
                if resultCallback then
                   resultCallback(retData.data) 
                end

                -- game.userDefault:setStringForKey(game.cookieKeys.SERVER_LOGIN_URL .. (device.platform), BM_UPDATE.LOGIN_URL)
                
            else
                
                if not retData then
                    logger:error("json parse error")
                    if errorCallback then
                       errorCallback({errorCode = 1}) 
                    end
                    
                else
                    if errorCallback then
                        errorCallback({errorCode = retData.code})
                    end
                    
                end
            end
        end, 
        function(errCode,errMsg)
            local errorData = {}
            if errCode ~= nil then
                errorData.errorCode = errCode
            end

            if errMsg ~= nil then
                errorData.errMsg = errMsg
            end

            if errorCallback then
                errorCallback(errorData)
            end

        end)
end


function GameHttp.gameLoad(resultCallback,errorCallback)
    return http.request_("GameServer.gameLoad",{},resultCallback,errorCallback)
end


--获取游戏列表
function GameHttp.getGameList(resultCallback,errorCallback)
    return http.request_("GameServer.getGameList",{},resultCallback,errorCallback)
end

--获取房间列表
function GameHttp.getRoomList(gameid,resultCallback,errorCallback)
  return http.request_("Room.getRoomList",{},resultCallback,errorCallback,{gameid = gameid})
end

--获取转盘数据
function GameHttp.luckyBigWheel(resultCallback,errorCallback)
  return http.request_("Activity.luckyBigWheel",{},resultCallback,errorCallback)
end

--领取转盘奖励
--@param data
-- {
--   qq_vip_type = 0/1/2, --0不是qqvip，1qq_vip，2qq_svip
--   start_up_type = 0/1/2,--0普通启动，1qq游戏中心启动，2微信游戏中心启动
-- }
function GameHttp.startLottery(data,resultCallback,errorCallback)
  return http.request_("Activity.startLottery",data,resultCallback,errorCallback)
end

--获取商城的数据
function GameHttp.getGoodsList(resultCallback,errorCallback)
   return http.request_("Goods.getGoodsListBySid",{},resultCallback,errorCallback)
end


--获取商城列表版本号
function GameHttp:getGoodsVersion(resultCallback,errorCallback)
  return http.request_("Goods.getLatestGoodsVersion",{},resultCallback,errorCallback)
end

--获取个人信息数据
function GameHttp.getUserByMid (resultCallback,errorCallback)
  return http.request_("Member.getUserByMid",{},resultCallback,errorCallback)
end

-- {“appid”: “10000”,“name”: “隔壁老王”,“msex”: “男”,“micon”: “头像”,“memail”: “11@126.com”,“mphone”: “13743215678”} 
--修改个人信息数据
function GameHttp.updateMinfo (name,sex,resultCallback,errorCallback)
  return http.request_("Member.updateMinfo",{name=name,sex = sex},resultCallback,errorCallback)
end

--获取救济金数据
function GameHttp.getReliefCfg (resultCallback,errorCallback)
    return http.request_("Activity.getReliefCfg",{},resultCallback,errorCallback)
end

--修改救济金数据
function GameHttp.getReliefFund (resultCallback,errorCallback)
  return http.request_("Activity.getReliefFund",{},resultCallback,errorCallback)
end

--获取公告数据
function GameHttp.getNoticeList (resultCallback,errorCallback)
   
    return  http.request_("Notice.getNoticeList",{},resultCallback,errorCallback)
end


--获取用户读取公告数据
 function GameHttp.readNotice (noticeId,resultCallback,errorCallback)
   
    return  http.request_("Notice.readNotice",{noticeId=noticeId},resultCallback,errorCallback)
end

 
--获取邮件数据
 function GameHttp.getEmaillList(resultCallback,errorCallback)
   
    return  http.request_("Message.getMessageList",{},resultCallback,errorCallback)
end
 
 --用户删除邮件消息
 function GameHttp.deleteMessages(arrIds,resultCallback,errorCallback)
   
    return  http.request_("Message.deleteMessages",{arrIds=arrIds},resultCallback,errorCallback)
end

 --用户删除邮件消息
 function GameHttp.deleteMessages(arrIds,resultCallback,errorCallback)
   
    return  http.request_("Message.deleteMessages",{arrIds=arrIds},resultCallback,errorCallback)
end

 --用户领取消息奖励
 function GameHttp.receiveEmailMessage (messageid,resultCallback,errorCallback)
   
    return  http.request_("Message.receiveMessage",{messageid=messageid},resultCallback,errorCallback)
end
 

--活动Activity.getActivityList 
--@param data
-- {
--   qq_vip_type = 0/1/2, --0不是qqvip，1qq_vip，2qq_svip
--   start_up_type = 0/1/2,--0普通启动，1qq游戏中心启动，2微信游戏中心启动
-- }
function GameHttp.getActivityList(data,resultCallback,errorCallback )
  return  http.request_("Activity.getActivityList",data,resultCallback,errorCallback)
end

--领取活动奖励 Activity.receiveActivityReward
function GameHttp.receiveActivityReward(id,resultCallback,errorCallback )
  return  http.request_("Activity.receiveActivityReward",{id=id},resultCallback,errorCallback)
end

--获取签到信息Dailylogin.getDailyLoginData 
function GameHttp.getDailyLoginData(resultCallback,errorCallback )
  return  http.request_("Dailylogin.getDailyLoginData",{},resultCallback,errorCallback)
end

--领取连续签到奖励Dailylogin.rewardDailyLogin
function GameHttp.receiveDailyLoginReward(resultCallback,errorCallback )
  return  http.request_("Dailylogin.rewardDailyLogin",{},resultCallback,errorCallback)
end

function GameHttp.getGameBtnInfo(gameids,resultCallback,errorCallback)
  dump(gameids,"gameids")
  return http.request_("Room.getHallRoomInformation",{aGameids = gameids},resultCallback,errorCallback)
end

function GameHttp.getRoomPlayer(gameid,resultCallback,errorCallback)
  return http.request_("Room.getGameidPlayNum",{},resultCallback,errorCallback,{gameid = gameid})
end

function GameHttp.getGameidsPlayNum(gameids,resultCallback,errorCallback)
  return http.request_("Room.getGameidsPlayNum", {gameids = gameids},resultCallback,errorCallback)
end


--钻石兑换金币 diamondExchangeMoney 
function GameHttp.diamondExchangeMoney(goodid, resultCallback,errorCallback )
  return  http.request_("Payment.diamondExchangeMoney",{goodid = goodid},resultCallback,errorCallback)
end

--钻石兑换房卡 Payment.diamondExchangeCard 
function GameHttp.diamondExchangeCard(goodid, resultCallback,errorCallback )
  return  http.request_("Payment.diamondExchangeCard",{goodid = goodid},resultCallback,errorCallback)
end

--反馈上报
function GameHttp.sendFeedback(content,token,resultCallback,errorCallback)

 local gameparams = {
       sitemid = sitemid,
       mac         = "",--"" game.Native:getMacAddr(), --移动终端设备号 
       access_token = token,
       content = content,
     }

    local params = 
    {
      appid = appconfig.appid,
      gameParam = json.encode(gameparams),
      lmode = loginType,
      sesskey = sesskey,
      version = game.gameManager:getGameVersion(GameType.HALL),
      gameid = 0,
    }

    params.method = "FeedBack.reportData"
    return http.postUrl(appconfig.feedBackUrl, params, resultCallback,errorCallback)
end

--获取私人房列表下载地址
function GameHttp.getPrivateList(resultCallback,errorCallback)
    return  http.request_("Room.getRoomListUrl",{type=2},resultCallback,errorCallback)
end

--生成支付订单
function GameHttp.genPayOrder(params,resultCallback,errorCallback)
    return  http.request_("Payment.callPayOrder",params,resultCallback,errorCallback)
end


--请求发货
function GameHttp.callClientPayment(params,resultCallback,errorCallback)
    return  http.request_("Payment.sendOutGoods",params,resultCallback,errorCallback)
end

--上报
function GameHttp.report(params,resultCallback,errorCallback)
    return  http.request_("Reporting.tencentReportingData",params,resultCallback,errorCallback)
end

--获取周胜榜
function GameHttp.getRank(params,resultCallback,errorCallback)
  return  http.request_("Statistic.getRank",params,resultCallback,errorCallback)
end



function GameHttp.getRankWinNum(params,resultCallback,errorCallback)
  params = params or {}
  params["start"] = params["start"] or 0
  params["end"] = params["end"] or 100
  return  http.request_("Ranking.getRankingByWinPlay",params,resultCallback,errorCallback)
end

function GameHttp.getRankWinMoney(params,resultCallback,errorCallback)
  params = params or {}
  params["start"] = params["start"] or 0
  params["end"] = params["end"] or 100
  return  http.request_("Ranking.getRankingByWinMoney",params,resultCallback,errorCallback)
end


--上报腾讯(___)
function GameHttp.report_test(url,params,cookie,resultCallback,errorCallback)
    local extra = {
      header = {
        ["Cookie"] = cookie,
      }
    }
    return  http.postUrl(url, params, resultCallback, errorCallback,extra)
end


function GameHttp.getNewSesssKey(resultCallback,errorCallback)
  return  http.request_("GameServer.getNewSesskey",{},resultCallback,errorCallback)
end

--是否首冲
function GameHttp.isFirtPay(resultCallback,errorCallback)
  return  http.request_("GameServer.isFirtPay",{},resultCallback,errorCallback)
end
--获取私人房战绩
function GameHttp.getAccountsList(resultCallback,errorCallback)
  return http.request_("Privateroom.getPrivateAccountsList",{},resultCallback,errorCallback)
end
--根据gameid获取私人房战绩
function GameHttp.getAccountsByGameid(gameid,resultCallback,errorCallback)
  return http.request_("Privateroom.getPrivateAccountsListByGameid",{pgameid = gameid},resultCallback,errorCallback)
end
--获取单轮战绩
function GameHttp.getRoundBill(list,resultCallback,errorCallback)
  --list = {150535747701547,150535749301547}
  return http.request_("Privateroom.getPrivateTableList",{innerids = list},resultCallback,errorCallback)
end

--获取整局战绩
function GameHttp.getVideoCodeList(videoCode,resultCallback,errorCallback)
  return http.request_("Privateroom.getVideoCodeList",{videoCode = videoCode},resultCallback,errorCallback)
end

--获取回放数据
function GameHttp.getPlayback(innerid,resultCallback,errorCallback )
  return http.request_("Privateroom.getPrivateTableOne",{innerid = innerid},resultCallback,errorCallback)
  -- body Privateroom.getPrivateTableOne
end

--牌局分享
function GameHttp.shareSettlement(innerid,resultCallback,errorCallback)
    return  http.request_("Privateroom.shareSettlement",{innerid=innerid},resultCallback,errorCallback)
end

-- 代开房
function GameHttp.proxyCreateRoom(gameid, arrConf, resultCallback, errorCallback)
    return http.request_("Privateroom.createPrivateRooms", {pgameid=gameid, arrConf=arrConf}, resultCallback, errorCallback)
end

--获取支付列表
function GameHttp.getPaymentConfig(inhouse,resultCallback,errorCallback)
    inhouse = inhouse or false
    return http.request_("Payment.getAllPayList",{inhouse = inhouse},resultCallback,errorCallback)
end

--开一局，判断是否微信群的用户
function GameHttp.checkKaiyijuJoinRoom(code,resultCallback,errorCallback)
    return http.request_("Privateroom.checkKaiyijuJoinRoom",{code=code},resultCallback,errorCallback)
end

function GameHttp.reportNetLog(content)
    return http.request_("GameServer.insertNetworkLog",{content = content})
end
--获取游戏列表
function GameHttp.getGameListByCityId(cityId,resultCallback,errorCallback)
    return http.request_("GameRegion.getRegionGame",{region_id = cityId},resultCallback,errorCallback)
end
--获取代理列表
function GameHttp.getAgentsListByGameId(gameid,resultCallback,errorCallback)
    return http.request_("Buscooperation.getAgentList",{game_id = gameid},resultCallback,errorCallback)
end
--获取玩家填写的身份证信息
function GameHttp.getIDCard(resultCallback,errorCallback)
  return http.request_("Realnameauth.getAuthInfo",{},resultCallback,errorCallback)
end
--用户填写身份证信息
function GameHttp.sendIDCard(name,idcard,resultCallback,errorCallback)
  return http.request_("Realnameauth.dealAuth",{name = name , code = idcard},resultCallback,errorCallback)
end
--获取最新游戏列表
function GameHttp.getAllGameList(resultCallback, errorCallback)
  return http.request_("SubGame.getTypeGameUrl",{},resultCallback,errorCallback)
end

--获取公告
function GameHttp.getAnnouncement(gameid,resultCallback, errorCallback)
  return http.request_("SubGame.getAnnouncement",{game_id=gameid},resultCallback,errorCallback)
end

--分享有奖
function GameHttp.getShareGiveConfig(resultCallback, errorCallback)
  return http.request_("ShareGive.getConfig",{},resultCallback,errorCallback)
end

--分享成功
function GameHttp.shareWxFriends(resultCallback, errorCallback)
  return http.request_("ShareGive.shareWxFriends",{},resultCallback,errorCallback)
end

--批量获取用户
--[[
  "可用type"
  mid	  用户ID
  name	名字
  icon	头像地址
  money	游戏币
  sex	  性别
]]--}

function GameHttp.getUserInfoByIds(data,resultCallback,errorCallback)
    local requestData = {
      mids = table.concat(data.mids,","),
      type = table.concat(data.types,","),
      cid = data.cid,
    }
  return http.request_("User.getUserInfoByIds",requestData,resultCallback,errorCallback)
end

--俱乐部邀请
--cid	int	俱乐部id
--tableid	int	桌子ID（6位的）
function GameHttp.inviteClubMembers(cid,box,roomCode,tableNum,resultCallback,errorCallback,gameName)
  return http.request_("Club.shareInvitationPlay",{cid=cid,box=box,tableid=roomCode,tableNumber=tableNum,gameName = gameName},resultCallback,errorCallback)
end


-- 拒绝或加入俱乐部
function GameHttp.updateClubInvite(data,resultCallback,errorCallback)
	return http.request_("Club.updateClubInvite",{cid = data.cid,state=data.state,cmid=data.cmid},resultCallback,errorCallback)
end


--展示邀请页
function GameHttp.getInviteCodeInfo(resultCallback,errorCallback)
  return http.request_("Invite.showInvitePage", {},resultCallback,errorCallback)
end

--提交绑定邀请人
function GameHttp.postInviteCode(code,resultCallback,errorCallback)
  return http.request_("Invite.submitInvite", {fmid=code},resultCallback,errorCallback)
end

--------------转盘--------------
--大转盘展示数据
function GameHttp.getRotaryInfo(resultCallback,errorCallback)
  return http.request_("Turntable.showTurntable", {},resultCallback,errorCallback)
end

--抽取奖品
function GameHttp.getRotaryReward(resultCallback,errorCallback)
  return http.request_("Turntable.receiveTurntable", {},resultCallback,errorCallback)
end

--获取个人中奖记录
function GameHttp.getRotaryRecord(resultCallback,errorCallback)
  return http.request_("Turntable.getTurntableLogByMid", {},resultCallback,errorCallback)
end

--获取贡献详情记录
function GameHttp.getRotaryContributeRecord(resultCallback,errorCallback)
  return http.request_("Turntable.getTurntableNumLog", {},resultCallback,errorCallback)
end

--获取大转盘可转次数
function GameHttp.getRotaryCount(resultCallback,errorCallback)
  return http.request_("Turntable.getTurntableNum", {},resultCallback,errorCallback)
end

--分享回调
function GameHttp.postRotaryShareResult(resultCallback,errorCallback)
  return http.request_("ShareGive.shareTurntable", {},resultCallback,errorCallback)
end


function GameHttp.getGameInfoByRoomCode(roomCode,resultCallback,errorCallback)
  return http.request_("GameServer.getGameidByRoomid", {roomid = roomCode},resultCallback,errorCallback)
end



--升级引导
function GameHttp.getUdpGuideInfo(resultCallback,errorCallback)
  return http.request_("GameServer.updateVersionConfig", {},resultCallback,errorCallback)

end

--H5活动
function GameHttp.getH5ActivityInfo(resultCallback,errorCallback)
  return http.request_("Activity.yqsIsOpen", {},resultCallback,errorCallback)
end
--------------------------------


--根据区域id和游戏id
function GameHttp.getAgentListV2(game_id,area_id,resultCallback,errorCallback)
  return http.request_("Buscooperation.getAreaBusCooperation", {area_id = area_id,game_id = game_id},resultCallback,errorCallback)
end


--代理后台入口
function GameHttp.getAgentSysInfo(resultCallback,errorCallback)
  return http.request_("Login.agentLogin", {},resultCallback,errorCallback)
end

--上传
function GameHttp.uploadFile(url, params, resultCallback, errorCallback)
  return http.uploadFile(url, params, resultCallback, errorCallback)
end

--更新吉祥物url
function GameHttp.updateMyCardUrl(url,state,resultCallback,errorCallback)
  return http.request_("User.updateUploadPic", {picurl=url,state = state},resultCallback,errorCallback)
end

function GameHttp.setMyCardInUse(state,resultCallback,errorCallback)
  return http.request_("User.updateUploadPicState", {state = state},resultCallback,errorCallback)
end


function GameHttp.getMyCardInfo(resultCallback,errorCallback)
  return http.request_("User.getUploadPic", {},resultCallback,errorCallback)
end

--手机绑定
function GameHttp.bindAccoutByPhone(phone,code,password,resultCallback,errorCallback)
  return http.request_("Mobile.phoneBinding", {phone = phone,verify_code = code,password = password},resultCallback,errorCallback)
end

function GameHttp.bindAccoutGetCode(phone,resultCallback,errorCallback)
  return http.request_("Mobile.sendCode", {phone = phone},resultCallback,errorCallback)
end



function GameHttp.translate2shortlink(origlink,resultCallback,errorCallback)
  return http.request_("Privateroom.getShortUrl", {url = origlink},resultCallback,errorCallback)
end


function GameHttp.getShareUrls(resultCallback,errorCallback)
  return http.request_("GameServer.getShareUrlList",{},resultCallback,errorCallback)
end


return GameHttp