local PluginIosBase = import(".PluginIosBase")
local HallModuleIso = import("gamehall.src.iso.HallModuleIso")
local GameNavitePluginIos = class("GameNavitePluginIos",PluginIosBase)
local HallSocketCmd 


function GameNavitePluginIos:ctor()
	GameNavitePluginIos.super.ctor(self,"GameNavitePluginIos","GameNativeBridge")
	self:init()
end


function GameNavitePluginIos:init()
	self.init_ = true
	self:call_("setGameNativeNotify", {listener = handler(self,self.onGameNativeNotify)})
	self:call_("init")
	self:startNetNotify()
	self:startNotificationBatteryLevel()
end



function GameNavitePluginIos:onGameNativeNotify(jsonObj)
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

function GameNavitePluginIos:startNetNotify()
	self:call_("startNetNotify")
end

function GameNavitePluginIos:startNotificationBatteryLevel()
	self:call_("startNotificationBatteryLevel")
end

function GameNavitePluginIos:stopNotificationBatteryLevel()
	self:call_("stopNotificationBatteryLevel")
end

function GameNavitePluginIos:stopNetNotify(clean)
	if clean then
		self:call_("stopNetNotify")
	end
end


function GameNavitePluginIos:networkChange(jsonObj)
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


function GameNavitePluginIos:setLoginState(state)
	self.isLogined = state
end

function GameNavitePluginIos:BatteryLevelChange( jsonObj )
	local level = jsonObj.level
	core.DataProxy:setData(game.dataKeys.BATTERY_LEVEL, level)
end

function GameNavitePluginIos:handleOpenUrl(jsonObj)
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
		local tid = checkint(getParam(data, "table=%d+"))
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

function GameNavitePluginIos:getVideoCodeId()
	local videoCode = self.videoCode_
	self.videoCode_ = nil
	return videoCode
end

function GameNavitePluginIos:getTableId( ... )
	local tid = self.tableId_
	self.tableId_ = nil
	return tid
end

function GameNavitePluginIos:setTableId(tid)
	if game.server and game.server:isConnected() then

		if not HallSocketCmd then
			local HallSocketCmdIso = game.IsoManager:getIso("HallSocketCmdIso")
			HallSocketCmd = HallSocketCmdIso.getCmd()
		end
	
		game.server:sendMsg(HallSocketCmd.CLI_JOIN_ROOM,{roomCode = tid})
	else
		self.tableId_ = tid
	end
end

function GameNavitePluginIos:getClubId()
	local cid = self.clubId_
	self.clubId_ = nil
	return cid
end

-- 俱乐部中桌子编号
function GameNavitePluginIos:getTableNum()
	local num = self.tableNum_
	self.tableNum_ = nil
	return num
end

-- 俱乐部中桌子房间号
function GameNavitePluginIos:getRoomCode()
	local num = self.roomCode_
	self.roomCode_ = nil
	return num
end

function GameNavitePluginIos:setVideoCode( videoCode )

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

function GameNavitePluginIos:setClubId(cid, tableNum,roomCode)
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

function GameNavitePluginIos:dispose()
	self:stopNotificationBatteryLevel()
	self:stopNetNotify()
end

local timeId = 0
function GameNavitePluginIos:startSystemTimer(timeout,callback)
	timeId = timeId + 1
	self:call_("startSystemTimer",{timeId = timeId,timeout=timeout,callback=callback})
end

function GameNavitePluginIos:stopSystemTimer(timeId)
	self:call_("stopSystemTimer",{timeId=callback})
end



return GameNavitePluginIos