local PluginAndroidBase = import(".PluginAndroidBase")
local HallModuleIso = import("gamehall.src.iso.HallModuleIso")
local GameNavitePluginAndroid = class("GameNavitePluginAndroid",PluginAndroidBase)
local HallSocketCmd 


function GameNavitePluginAndroid:ctor()
	GameNavitePluginAndroid.super.ctor(self,"GameNavitePluginAndroid","org.ode.cocoslib.gamenative.GameNativeBridge")
	self:init()
end

function GameNavitePluginAndroid:init()
	self.init_ = true
	self.onGameNativeNotifyHandler_ = handler(self,self.onGameNativeNotify)
	self:call_("setGameNaviteNotify", {self.onGameNativeNotifyHandler_}, "(I)V")
	self:call_("init",{},"()V")

	self:startNetNotify()
	self:startNotificationBatteryLevel()
end 

function GameNavitePluginAndroid:startNetNotify()
	self:call_("startNetNotify",{},"()V")
end

function GameNavitePluginAndroid:stopNetNotify()
	self:call_("stopNetNotify",{},"()V")
end

function GameNavitePluginAndroid:startNotificationBatteryLevel()
	self:call_("startNotificationBatteryLevel",{},"()V")
end

function GameNavitePluginAndroid:stopNotificationBatteryLevel()
	self:call_("stopNotificationBatteryLevel",{},"()V")
end

function GameNavitePluginAndroid:onGameNativeNotify(jsonStr)
	local jsonObj = json.decode(jsonStr)
	dump(jsonObj,"onGameNativeNotify jsonObj")
	if not jsonObj then
		return
	end
	local gtype = jsonObj.gtype
	if gtype == "handleOpenUrl" then
		self:handleOpenUrl(jsonObj)
	elseif gtype == "networkChange" then
		self:networkChange(jsonObj)
	elseif gtype == "BatteryLevelChange" then
		self:BatteryLevelChange(jsonObj)
	end
end

function GameNavitePluginAndroid:BatteryLevelChange(jsonObj)
	local level = jsonObj.level
	core.DataProxy:setData(game.dataKeys.BATTERY_LEVEL, level)
end


function GameNavitePluginAndroid:networkChange(jsonObj)
	local state = jsonObj.state
	if state == 0 then
		--无网络
		print("切换网络-无网络")
	elseif state == 1 then
		--wifi
		print("切换网络-wifi")
	elseif state == 2 then
		--mobile
		print("切换网络-mobile")
	end

	if core and core.EventCenter and game and game.eventNames then
		core.EventCenter:dispatchEvent({name = game.eventNames.NETWORK_CHANGE, data = {state = state}})
	end
end

function GameNavitePluginAndroid:handleOpenUrl(jsonObj)
	dump(jsonObj,"handleOpenUrl jsonObj")
	local function getParam(data, matchstr)
		local tabStr = string.match(data,matchstr)
		print("handleOpenUrl-getParam: ",tabStr)
		if not tabStr then
			return
		end
		local tb = string.split(tabStr,"=")
		if not tb then
			return
		end
		dump(tb,"handleOpenUrl-tb===")
		return tb[2]
	end

	local function checknumber(num, len)
		num = checkint(num)
		local numstr = tostring(num)
		return num > 0 and string.len(numstr) == len 
	end

	local data = jsonObj.data
	local type = checkint(getParam(data, "type=%d+"))
	if type == 2 then --私人房房号
		local tid = getParam(data, "table=%d+")
		if checknumber(tid,  6) then
			self:setTableId(tid)
		end
	elseif type == 4 then --回放码
		local innerid = getParam(data, "playback=[0-9a-zA-Z]+")
		local mid = checkint(getParam(data, "mid=%d+"))
		local gameid = checkint(getParam(data, "gameid=%d+"))
		if not innerid or not mid or not gameid then
			return
		end
		local data = {innerid=innerid,mid=mid,gameid=gameid}
		--为了防止不在场景收不到事件
		core.DataProxy:setData(game.dataKeys.PLAY_BACK_DATA,data)
		core.EventCenter:dispatchEvent({name = game.eventNames.PLAY_BACK_DATA, data = data})
	elseif type == 3 then --俱乐部
		local clubid = getParam(data, "clubId=%d+")
		local tableNum = getParam(data, "tableNum=%d+")
		local roomCode = getParam(data, "roomCode=%d+")
		if clubid then
			self:setClubId(clubid, tableNum,roomCode)
		end
	elseif type == 6 then -- 回放录像弹框
		local videoCode = getParam(data, "videoCode=[0-9a-zA-Z]+")
		if videoCode then
			self:setVideoCode(videoCode)
		end
	elseif type == 11 then
		--heibeipay miniprogram
		local tokenId  = getParam(data, "token_id=[0-9a-zA-Z]+")
		local orderSn  = getParam(data, "orderSn=[0-9a-zA-Z]+")
	elseif type == 12 then
		local clubid = getParam(data, "clubId=%d+")
		if clubid then
			self:setClubId(clubid)
		end
	end
end


function GameNavitePluginAndroid:handlerHaibeiPayMiniprogram(tokenId,orderSn)
	if game and game.WeChat then
		local tpath = string.format("/pages/init/init?token_id=%s",tokenId)
		game.WeChat:launchMiniProgram(tpath)
	end
end


function GameNavitePluginAndroid:getVideoCodeId()
	local videoCode = self.videoCode_
	self.videoCode_ = nil
	return videoCode
end

function GameNavitePluginAndroid:getTableId()
	local tid = self.tableId_
	self.tableId_ = nil
	return tid
end

function GameNavitePluginAndroid:setTableId(tid)

	if not HallSocketCmd then
		local HallSocketCmdIso = game.IsoManager:getIso("HallSocketCmdIso")
		HallSocketCmd = HallSocketCmdIso.getCmd()
	end
	if game.server and game.server:isConnected() then
		game.server:sendMsg(HallSocketCmd.CLI_JOIN_ROOM,{roomCode = tid})
	else
		self.tableId_ = tid
	end
end

function GameNavitePluginAndroid:getClubId()
	local cid = self.clubId_
	self.clubId_ = nil
	return cid
end

-- 俱乐部中桌子编号
function GameNavitePluginAndroid:getTableNum()
	local num = self.tableNum_
	self.tableNum_ = nil
	return num
end

-- 俱乐部中桌子房间号
function GameNavitePluginAndroid:getRoomCode()
	local num = self.roomCode_
	self.roomCode_ = nil
	return num
end

function GameNavitePluginAndroid:setVideoCode( videoCode )

	if not HallSocketCmd then
		local HallSocketCmdIso = game.IsoManager:getIso("HallSocketCmdIso")
		HallSocketCmd = HallSocketCmdIso.getCmd()
	end

	if game.server and game.server:isConnected() then
		HallModuleIso.getInstance():showVideoDlg(videoCode)
	else
		self.videoCode_ = videoCode
	end
end

function GameNavitePluginAndroid:setClubId(cid, tableNum ,roomCode)

	if not HallSocketCmd then
		local HallSocketCmdIso = game.IsoManager:getIso("HallSocketCmdIso")
		HallSocketCmd = HallSocketCmdIso.getCmd()
	end
	if game.server and game.server:isConnected() then
		if tableNum or roomCode then
			HallModuleIso.getInstance():inviteJoinClubView(cid,tableNum,nil,roomCode)
		else
			HallModuleIso.getInstance():inviteJoinClubView(cid,tableNum,nil,roomCode,"dlg")
		end
		
	else
		self.clubId_ = cid
		self.tableNum_ = tableNum
		self.roomCode_ = roomCode
	end
end

function GameNavitePluginAndroid:dispose()
	self:stopNotificationBatteryLevel()
	self:stopNetNotify()
end


local timeId = 0
function GameNavitePluginAndroid:startSystemTimer(timeout,callback)
	timeId = timeId + 1
	self:call_("startSystemTimer",{timeId,timeout,callback},"(III)V")
end

function GameNavitePluginAndroid:stopSystemTimer(timeId)
	self:call_("stopSystemTimer",{timeId},"(I)V")
end



return GameNavitePluginAndroid