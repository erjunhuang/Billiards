local HallSocketCmd = import(".HallSocketCmd")
local scheduler = require("misc.scheduler")
local GameHttp = import(".GameHttp")

local HallCommonSocketProcesser = class("HallCommonSocketProcesser",core.SocketProcesser)
function HallCommonSocketProcesser:ctor()
	HallCommonSocketProcesser.super.ctor(self)
end



function HallCommonSocketProcesser:onSocketConnected(packetInfo)
	self:login()
	return packetInfo
end


function HallCommonSocketProcesser:onSocketConnectFail(packetInfo)
	return packetInfo
end



function HallCommonSocketProcesser:onSocketHeartTimeOut(packetInfo)
	return packetInfo
end

function HallCommonSocketProcesser:onSocketLoginTimeOut(packetInfo)
	return packetInfo
end

function HallCommonSocketProcesser:getTid()

	if self.__socket then
		local info = {}
		info.ver = 1
		info.level = 101
		self.__socket:sendMsg(HallSocketCmd.CLI_GET_TID,info)
	end

end

function HallCommonSocketProcesser:login()

	if self.__loginTimeoutHandle then
        scheduler.unscheduleGlobal(self.__loginTimeoutHandle)
        self.__loginTimeoutHandle = nil
    end
    self.__loginTimeoutHandle = scheduler.performWithDelayGlobal(function()       
        self.__loginTimeoutHandle = nil
        print("登录超时")
        self:onReceivePacket(HallSocketCmd.SERVER_LOGIN_TIME_OUT,{})
        self.__socket:closeSocket()
    end, 5)

 print("HallCommonSocketProcesser:login")
	if self.__socket then
		local info = {}
		info.uid = game.userData["aUser.mid"]

		dump(info.uid,"HallCommonSocketProcesser:login")
		info.sessionkey = "3"
		dump(info,"login:info")
		self.__socket:sendMsg(HallSocketCmd.CLI_LOGIN,info)
	end
end


function HallCommonSocketProcesser:getTid()

	if self.__socket then
		local info = {}
		info.v = "1"
		self.__socket:sendMsg(HallSocketCmd.CLI_GET_TID,info)
	end

end

function HallCommonSocketProcesser:onLoginSuccess(packetInfo)

	-- self:getTid()

	if self.__loginTimeoutHandle then
        scheduler.unscheduleGlobal(self.__loginTimeoutHandle)
        self.__loginTimeoutHandle = nil
    end

	local ret = packetInfo.ret
	local isInTable = checkint(packetInfo.intable)

	if isInTable > 0 then
    	if isInTable == 1 then
    		if packetInfo.tid then
				print("登录: TABLEID= "..packetInfo.tid)
				-- core.DataProxy:setData(game.dataKeys.TABLE_ID,packetInfo.tid)
		 		-- core.DataProxy:setData(game.dataKeys.GAME_ID,packetInfo.gameID)
		 		-- core.DataProxy:setData(game.dataKeys.CURRENT_HALL_VIEW, 2)
		 		-- core.DataProxy:setData(game.dataKeys.GAME_LEVEL,checkint(packetInfo.level))
		 		scheduler.performWithDelayGlobal(
		 			function()
		 				-- game.gameManager:startGame(packetInfo.gameID)
		 				SceneManager.LoadScene("Billiard",SceneManagement.LoadSceneMode.Single);
		 			end,0.1
		 		)
			end
    	elseif isInTable == 2 then

    	end
    	
    end 

	

	dump(packetInfo,"HallCommonSocketProcesser:onLoginSuccess")
	do return end
	if self.__loginTimeoutHandle then
        scheduler.unscheduleGlobal(self.__loginTimeoutHandle)
        self.__loginTimeoutHandle = nil
    end

    local isInTable = packetInfo.isInTable
    local isInMatch = packetInfo.isInMatch

    if isInTable > 0 then
    	if isInTable == 1 then
    		if packetInfo.gameID and packetInfo.tid then
				print("登录: gameID= "..packetInfo.gameID.." TABLEID= "..packetInfo.tid)
				core.DataProxy:setData(game.dataKeys.TABLE_ID,packetInfo.tid)
		 		core.DataProxy:setData(game.dataKeys.GAME_ID,packetInfo.gameID)
		 		core.DataProxy:setData(game.dataKeys.CURRENT_HALL_VIEW, 2)
		 		core.DataProxy:setData(game.dataKeys.GAME_LEVEL,checkint(packetInfo.level))
		 		scheduler.performWithDelayGlobal(
		 			function()
		 				game.gameManager:startGame(packetInfo.gameID)
		 			end,0.1
		 		)
			end
    	elseif isInTable == 2 then

    	end
    	
    end 

    if isInMatch > 0 then


    end


	return packetInfo
end

function HallCommonSocketProcesser:onLoginError(packetInfo)
	dump(packetInfo,"HallCommonSocketProcesser:onLoginError")
	if packetInfo.ret == 1 then
		--sessionkey 错误
		GameHttp.getNewSesssKey(function(data)
			local sesskey = data.sesskey or ""
			game.userData.sesskey = sesskey
			GameHttp.setSessionKey(sesskey)
			self:login()
		end,function()
			-- body
		end)
	end
end



function HallCommonSocketProcesser:onGetTableId(packetInfo)
	dump(packetInfo,"HallCommonSocketProcesser:onGetTableId")


	

 	-- core.DataProxy:setData(game.dataKeys.TABLE_ID,packetInfo.tableId)
 	-- core.DataProxy:setData(game.dataKeys.GAME_LEVEL,packetInfo.gameLevel)
 	-- core.DataProxy:setData(game.dataKeys.GAME_ID,packetInfo.gameID)
 	-- print("DataProxy",core.DataProxy:getData(game.dataKeys.TABLE_ID))

 	return packetInfo
end

function HallCommonSocketProcesser:onPrivateRoomErr(packetInfo)
	--游戏发生错误
	dump(packetInfo,"cmd：0x1714")
	game.AlertDlg:ShowTip({msg=game.getPrivateRoomErr(packetInfo.errorCode)})
	return packetInfo
end

function HallCommonSocketProcesser:onClubPrivateRoomErr(packetInfo)
	--游戏发生错误
	dump(packetInfo,"cmd：0x171D")
	-- errorCode==16 弹窗加入俱乐部
	game.AlertDlg:ShowTip({msg=game.getPrivateRoomErr(packetInfo.errorCode)})
	if packetInfo.errorCode == 16 then
		packetInfo.clubId = game.clubID826(packetInfo.clubId)
		require("gamehall.src.module.club.joinDlg.InviteJoinClubDlg").new(packetInfo.clubId):showDlg()
	end
	return packetInfo
end

function HallCommonSocketProcesser:onClubKickOutUser(packetInfo)
	--俱乐部踢人
	dump(packetInfo,"cmd: 0x5002")	
	scheduler.performWithDelayGlobal(function( ... )
		game.AlertDlg:ShowTip({msg='你被踢了!'})
	end,0.2)
	return packetInfo
end

function HallCommonSocketProcesser:onCreateRoomSucc(packetInfo)
	print("私人房创建成功,直接切换至房间")
	if checkint(packetInfo.precreate) == 0 then
		core.DataProxy:setData(game.dataKeys.TABLE_ID,packetInfo.tableId)
		core.DataProxy:setData(game.dataKeys.GAME_ID,packetInfo.gameID)
		core.DataProxy:setData(game.dataKeys.SELECT_GAME_ID,packetInfo.gameID)
		core.DataProxy:setData(game.dataKeys.GAME_LEVEL,-1) --私人房
		game.gameManager:startGame(packetInfo.gameID)
	end
	return packetInfo
end
function HallCommonSocketProcesser:onJoinRoomSucc(packetInfo)

	print("私人房加入成功,直接切换至房间")
	core.DataProxy:setData(game.dataKeys.TABLE_ID,packetInfo.tableId)
	core.DataProxy:setData(game.dataKeys.GAME_ID,packetInfo.gameID)
	core.DataProxy:setData(game.dataKeys.GAME_LEVEL,-1) --私人房

    return packetInfo
end


function HallCommonSocketProcesser:onJoinRoomSuccOld(packetInfo)
	print("私人房加入成功旧的,直接切换至房间")
	core.DataProxy:setData(game.dataKeys.TABLE_ID,packetInfo.tableId)
	core.DataProxy:setData(game.dataKeys.GAME_ID,packetInfo.gameID)
	core.DataProxy:setData(game.dataKeys.GAME_LEVEL,-1) --私人房
	return packetInfo
end

function HallCommonSocketProcesser:onBroadSinglelUser(packetInfo)
	-- local info
	-- if not packetInfo or not packetInfo.msg then
	-- 	info = json.decode(packetInfo) 
	-- end
	-- return info
	local info = json.decode(packetInfo.msg)
	if not info then
		return
	end
	dump(info,"0x7850")
	local content_type = info.type
	-- diamond 钻石
	-- money 游戏币
	if content_type == 2 then
		if info.content then 	
			if info.content.type ==1 then 
			 	game.userData["aUser.diamond"] = info.content.num
			elseif info.content.type ==2 then
				game.userData["aUser.money"] = info.content.num
			elseif info.content.type ==3 then
				game.userData["aUser.card"] = info.content.num
			elseif info.content.type ==4 then
				game.userData["aUser.monthcard"] = info.content.etime
			end
		end
	elseif content_type == 1 then

	elseif content_type == 4 then
		-- 俱乐部列表刷新
		core.EventCenter:dispatchEvent({name = game.eventNames.REFRESH_CLUB_LIST})
	elseif content_type == 9 then
		-- 俱乐部申请消息
		core.EventCenter:dispatchEvent({name = game.eventNames.RECIEVE_NEW_CLUB_APPLY})
		game.SoundManager:playBGMForGame("gamehall/res/audio/%s/msg.%s")
	elseif content_type == 13 then
		-- 通过或者拒绝刷新申请消息
		core.EventCenter:dispatchEvent({name = game.eventNames.RECIEVE_NEW_CLUB_APPLY})
	elseif content_type == 10 then
		
		if checkint(info.addDiamond) > 0 and checkint(info.diamond) >= checkint(info.addDiamond) then
			-- game.userData["aUser.diamond"] = checkint(info.diamond)
		elseif checkint(info.addMoney) > 0 and checkint(info.money) >= checkint(info.addMoney) then
			-- game.userData["aUser.money"] = checkint(info.money)
		end
	elseif content_type == 12 then
		-- 俱乐部转让
		core.EventCenter:dispatchEvent({name = game.eventNames.REFRESH_CLUB_LIST})
	elseif content_type == 14 then
		-- 更新转盘次数
		core.EventCenter:dispatchEvent({name = game.eventNames.REFRESH_ROTARY_COUNT})
	elseif content_type == 15 then
		-- 弹出被邀请人界面 (通过id邀请用户进入该俱乐部)
		local data = info.content
		local dlg = require("gamehall.src.module.club.clubInviteForId.ClubInviteFromIdDlg")
		if game.PopupManager:hasSameKindPopup(dlg)then
			core.EventCenter:dispatchEvent({name = game.eventNames.REFRESH_ID_BEINVITE_VIEW , data = data})
		else
			dlg.new(data):showDlg()
		end
	end
	return info
end


-- 0x400E：类型 1 大厅走马灯 2 修改金币或钻石 3 信息红点 4刷新俱乐部列表 5踢用户出俱乐部 6俱乐部禁赛 7俱乐部领取爱心推送给创建者 8俱乐部-收回爱心
-- 0x4011：类型 1 大厅走马灯 2 修改金币或钻石 3广播加入俱乐部邀请玩牌 4广播俱乐部解散
function HallCommonSocketProcesser:onBroadMutilUser(packetInfo)
	-- local info
	-- if not packetInfo or not packetInfo.msg then
	-- 	info = json.decode(packetInfo) 
	-- end	
	local info = json.decode(packetInfo.msg)
	-- dump(info,"0x7852")
	if not info then
		return
	end
	local content_type = info.type
	local content_str = info.content
	if content_type == 1 then
	    -- core.DataProxy:getData(game.dataKeys.NOTICE_DATA)["msg"] =content_str["msg"]
	    if game and game.MarqueeTipManager then
	    	game.MarqueeTipManager:showTip(content_str["msg"])
		end
	elseif content_type == 4 then
		-- 俱乐部列表刷新
		core.EventCenter:dispatchEvent({name = game.eventNames.REFRESH_CLUB_LIST})

	elseif content_type == 10 then
		if self.__socket and type(self.__socket.setNewServerHost) == "function" then
			local tser = content_str.server
			local isHighDefense = (checkint(tser) == 1) and true or false
			self.__socket:setNewServerHost(isHighDefense)
			self.__socket:closeSocket()
			scheduler.performWithDelayGlobal(function( ... )
				self.__socket:openSocket()
			end,0.2)
			
		end
	elseif content_type == 8 then
		-- 俱乐部打烊
		core.EventCenter:dispatchEvent({name = game.eventNames.REFRESH_CLUB_LIST})

	elseif content_type == 9 then
		-- 俱乐部开启
		core.EventCenter:dispatchEvent({name = game.eventNames.REFRESH_CLUB_LIST})

	end

	return info
end


function HallCommonSocketProcesser:onUserDoubleLogin(packetInfo)
	-- game.ui.Dialog.new({
 --        messageText = T("您的账户在别处登录"), 
 --        secondBtnText = T("确定"),
 --        closeWhenTouchModel = false,
 --        hasFirstButton = false,
 --        hasCloseButton = false,
 --        callback = function (type)
 --            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
 --                self:handleLogoutSucc_()
 --            end
 --        end,
 --    }):show()
 --    self:handleLogoutSucc_()

 -- if self.loginTimeoutHandle_ then
 --        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
 --        self.loginTimeoutHandle_ = nil
 --    end    
 	print("HallCommonSocketProcesser.onUserDoubleLogin")
 	if self.__loginTimeoutHandle then
        scheduler.unscheduleGlobal(self.__loginTimeoutHandle)
        self.__loginTimeoutHandle = nil
    end 

    self.__socket:closeSocket(true) --断开socket


    self:reportCallStack()

end
function HallCommonSocketProcesser:onUpdateData(packetInfo)
	dump(packetInfo,"数据更新",4)
	for i=1,#packetInfo do
		local item = packetInfo[i]
		for k,v in pairs(item) do
			if checkint(k) == 9 then--钻石
				game.userData["aUser.diamond"] = v
			elseif checkint(k) == 1 then
				game.userData["aUser.money"] = v
			elseif checkint(k) == 10 then
				game.userData["aUser.card"] = v
			end
		end
	end
end


function HallCommonSocketProcesser:reportCallStack( ... )
    if game and game.userData and checkint(game.userData["reportingLuaError"]) == 1 then
        if buglyReportLuaException then
            buglyReportLuaException("reportUserDoubleLogin",debug.traceback())
        end
    end
    
end

HallCommonSocketProcesser.s_severCmdEventFuncMap = 
{
	[HallSocketCmd.SERVER_COMMAND_CONNECTED] = HallCommonSocketProcesser.onSocketConnected,
	[HallSocketCmd.SERVER_CONNECT_FAILURE]   = HallCommonSocketProcesser.onSocketConnectFail,
	[HallSocketCmd.SERVER_HEART_TIME_OUT] = HallCommonSocketProcesser.onSocketHeartTimeOut,
	[HallSocketCmd.SERVER_LOGIN_TIME_OUT] = HallCommonSocketProcesser.onSocketLoginTimeOut,
	[HallSocketCmd.SVR_LOGIN] = HallCommonSocketProcesser.onLoginSuccess,
	[HallSocketCmd.SVR_GET_TID] = HallCommonSocketProcesser.onGetTableId,
	[HallSocketCmd.SVR_CREATE_ROOM_SUCC]	= HallCommonSocketProcesser.onCreateRoomSucc,
	[HallSocketCmd.SVR_PRIVATE_ROOM_ERR] = HallCommonSocketProcesser.onPrivateRoomErr,
	[HallSocketCmd.SVR_CLUB_OPERATE_ERR] = HallCommonSocketProcesser.onClubPrivateRoomErr,
	[HallSocketCmd.SVR_JOIN_ROOM_SICC]	= HallCommonSocketProcesser.onJoinRoomSucc,
	[HallSocketCmd.SVR_BROAD_MUTIL_USER]    = HallCommonSocketProcesser.onBroadMutilUser,
	[HallSocketCmd.SVR_BROAD_SINGLE_SINGLE] = HallCommonSocketProcesser.onBroadSinglelUser,
	[HallSocketCmd.SVR_DOUBLE_LOGIN] = HallCommonSocketProcesser.onUserDoubleLogin,
	[HallSocketCmd.SVR_LOGIN_ERR] = HallCommonSocketProcesser.onLoginError,
	[HallSocketCmd.SVR_UPDATE_DATA] = HallCommonSocketProcesser.onUpdateData,
	[HallSocketCmd.SVR_JOIN_ROOM_SICC_OLD]	= HallCommonSocketProcesser.onJoinRoomSuccOld,
	[HallSocketCmd.SVR_CLUB_KICK_USER]	= HallCommonSocketProcesser.onClubKickOutUser,
};

return HallCommonSocketProcesser