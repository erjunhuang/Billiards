local GameSocketCmd = import(".GameSocketCmd")
local GameSocketProcesser = class("GameSocketProcesser",core.SocketProcesser)

function GameSocketProcesser:ctor(controller)
	GameSocketProcesser.super.ctor(self,controller)
end

local function __formatPlayer(pbPlayer)
	local player = {}
	player.seatId = pbPlayer.seatid
	player.userId = pbPlayer.uid
	player.isReady = ((pbPlayer.isReady == 1) and true or false)
	player.userInfo = json.decode(pbPlayer.userinfo)
	player.money = pbPlayer.money

	return player
end

local function __formatPlayers(pbPlayers)
	local players = {}
	for i,v in ipairs(pbPlayers) do
		local player = __formatPlayer(pbPlayers[i])
		table.insert(players,player)
	end

	return players
end




function GameSocketProcesser:onLoginGame(packetInfo)
	local info = {}
	-- info.loginCode = packetInfo.loginCode
	-- info.mySeatId = packetInfo.mySeatId

	-- local roomInfo = packetInfo.roomInfo
	-- info.deskFees = roomInfo.deskFees
	-- info.baseChip = roomInfo.baseChip
	-- info.roomLevel = roomInfo.roomLevel
	-- info.roomType = roomInfo.roomType
	-- info.totalRound = roomInfo.totalRound
	-- info.currentRound = roomInfo.currentRound
	-- info.creatorId = roomInfo.creatorId
	-- info.roomCode = roomInfo.roomCode
	-- info.privateStatus = roomInfo.privateStatus
	-- info.privateModel = roomInfo.privateModes
	
	dump(packetInfo,"0x1801 login succ")
	info.players = __formatPlayers(packetInfo.users)
	self.__controller:onLoginGame(info)
	return info
end
function GameSocketProcesser:onBroadUserLogin(packetInfo)
	local info = __formatPlayer(packetInfo.userdata)
	dump(info,"0x1814其他玩家登录")
	self.__controller:onBroadUserLogin(info)
	return info
end
function GameSocketProcesser:onBroadUserReady(packetInfo)
	-- local info = {}
	-- info.userId = packetInfo.userId
	-- info.seatId = packetInfo.seatId
	-- dump(info,"1806 player ready ")
	self.__controller:onBroadUserReady(packetInfo)
	return info
end
function GameSocketProcesser:onGameStart(packetInfo)
	-- local info = {}
	-- info.cards = packetInfo.cards--玩家的牌列表
	-- info.kingSeat = packetInfo.kingSeat--//大王的座位id
	-- info.totalRound = packetInfo.totalRound
	-- info.currentRound = packetInfo.currentRound
	dump(packetInfo,"游戏开始")
	self.__controller:onGameStart(packetInfo)
	return info
end

function GameSocketProcesser:broadcast_client_show_or_hide_info( packetInfo )
	local info = {}
	info.id   = packetInfo.id  
	info.showType   = packetInfo.showType  
	dump(info,"显示或者隐藏客户端的某些内容")
	self.__controller:broadcast_client_show_or_hide_info(info)
	return info
end

function GameSocketProcesser:notifyUserOperate(packetInfo )
	local info = {}
	info.seatId = packetInfo.seatId 
	info.userId = packetInfo.userId 
	info.opCode = packetInfo.opCode 
	info.time = packetInfo.time 
	info.opStep = packetInfo.opStep
	dump(info,"通知玩家操作码")
	self.__controller:notifyUserOperate(info)
end

function GameSocketProcesser:broadUserOperate( packetInfo )
	local info = {}
	info.seatId = packetInfo.seatId 
	info.userId = packetInfo.userId 
	info.opCode = packetInfo.opCode 
	info.zhuangSeatId =packetInfo.zhuangSeatId
	info.spCode = packetInfo.spCode
	dump(info,"广播玩家操作码")
	self.__controller:broadUserOperate(info)
end

local function __formatZhuangXianInfo(info)	--同步庄闲家信息
	local lists = {}
	-- for i=1,#info do
		local player = {}
		player.score = info.score
		player.winMul = info.winMul
		player.loseMul= info.loseMul
		player.isDou = info.isDou
		table.insert(lists,player)
	-- end
	return lists
end
function GameSocketProcesser:broadSYCZhuangXianInfo( packetInfo )
	local info = {}
	info.zhuangInfo = __formatZhuangXianInfo(packetInfo.zhuangInfo )  
	info.xianInfo = __formatZhuangXianInfo(packetInfo.xianInfo )  
	dump(info,"广播同步庄闲信息")
	self.__controller:broadSYCZhuangXianInfo(info)
end
function GameSocketProcesser:onStartOutCard(packetInfo)
	local info = {}
	info.userId = packetInfo.userId
	info.time = packetInfo.time
	info.isNewTurn=packetInfo.isNewTurn
	dump(info,"开始出牌")
	self.__controller:onStartOutCardSucc(info)
end

local function __formatCardAttribute(cardInfo)
	local info = {}
	info.group_type = cardInfo.group_type				--牌 类型,  炸弹, 普通牌
	info.count = cardInfo.count 			--副类型, 同花顺, 对, 三张 等等
	info.first_card_col = cardInfo.first_card_col 		--第一个牌值的大小 , 如顺子45678, 则选4
	info.huase = cardInfo.huase 						--花色, 混色, 桃心梅方
	return info
end

function GameSocketProcesser:onOutCard(packetInfo)
	local info = {}
	info.retCode = packetInfo.retCode		--出牌成功或失败,0:失败 1:成功
	info.userId = packetInfo.userId   		---玩家id
	info.seatId = packetInfo.seatId     	--座位id
	info.cards = packetInfo.cards    	--出的牌
	info.cardAttribute =__formatCardAttribute(packetInfo.cardAttribute)  --组合类型
	info.zhuangScore=packetInfo.zhuangScore
	info.xianScore=packetInfo.xianScore 			 
	-- info.compareValue = packetInfo.compareValue   --组合中最小的价值
	info.nextUserId = packetInfo.nextUserId    --下一个出牌的人
	info.opCode = packetInfo.opCode			-- 0:不要，8:要
	info.isNewTurn = packetInfo.isNewTurn		--是否新一轮 true false
	info.time = packetInfo.time
	info.currPoolScore = packetInfo.currPoolScore 	--当前分池里的分数
	info.currPoolScoreCards = packetInfo.currPoolScoreCards --当前分池里的牌
	info.isWin = packetInfo.isWin				--出牌人是否赢了true false
	info.spCode = packetInfo.spCode
	info.zhuangScoreCards  = packetInfo.zhuangScoreCards  --庄家的得分牌
	info.xianScoreCards   = packetInfo.xianScoreCards   --闲家的得分牌
	dump(info,"广播出牌")
	self.__controller:onBroadOutCardSucc(info)
end

function GameSocketProcesser:notify_user_outcard_opreate( packetInfo )
	dump(packetInfo,"通知用户出牌操作码111",100)
	local info = {}
	info.opCode  = packetInfo.opCode 
	info.time     = packetInfo.time    
	self.__controller:notify_user_outcard_opreate(info)
	dump(info,"通知用户出牌操作码")
end
function GameSocketProcesser:onUserLoginOut(packetInfo)
	local info = {}
	info.userId = packetInfo.userId
	info.seatId = packetInfo.seatId
	info.outCode = packetInfo.logoutCode
	dump(info,"玩家退出")
	self.__controller:onUserLoginOutSucc(info)
end
local function __formatGameOverList(list)
	local lists = {}
	for i=1,#list do
		local player = {}
		local pbPlayer = list[i]
		player.userId = pbPlayer.userID		--用户id
		player.totalPoint = pbPlayer.totalPoint 			 
		player.winPoint = pbPlayer.winPoint 			 
		player.remainCards = pbPlayer.remainCards 
		player.scoreCards = pbPlayer.scoreCards 	
		player.isWin = pbPlayer.isWin 	
		player.isZhuang = pbPlayer.isZhuang 	
		player.isKing = pbPlayer.isKing 	
		player.place = pbPlayer.place 		
		player.chaoScore = pbPlayer.chaoScore 		  
		player.userInfo = pbPlayer.userInfo--用户信息
		player.cardScore =pbPlayer.cardScore
		player.isCreator = pbPlayer.isCreator
		player.yaoChui = pbPlayer.yaoChui
		player.yaoBao = pbPlayer.yaoBao
		player.yaoDou = pbPlayer.yaoDou
		player.outCardRecords = pbPlayer.outCardRecords
		table.insert(lists,player)
	end
	return lists
end

function GameSocketProcesser:onBroadGameOver(packetInfo)
	local info = {}
	info.settleData= __formatGameOverList(packetInfo.settleData)

	info.zhuangIsDou =packetInfo.zhuangIsDou
	info.xianIsDou= packetInfo.xianIsDou
	info.isTouXiangOver = packetInfo.isTouXiangOver
	info.isZhuangSurrender = packetInfo.isZhuangSurrender
	info.isLastRound = packetInfo.isLastRound
	dump(info,"游戏结束",3)
	self.__controller:onGameOverSucc(info)
end


local function __formatLastTurnInfo(lastTurnInfos)
	local lists = {}
	for i=1,#lastTurnInfos do
		local lastTurnInfo = {}
		local pbLastTurnInfo = lastTurnInfos[i]
		lastTurnInfo.seatId = pbLastTurnInfo.seat
		lastTurnInfo.cards = pbLastTurnInfo.cards
		lastTurnInfo.attribute = __formatCardAttribute(pbLastTurnInfo.attribute)
		lastTurnInfo.op_code = pbLastTurnInfo.op_code
		table.insert(lists,lastTurnInfo)
	end
	return lists
end

--超神重连
function GameSocketProcesser:onUserReconnect(packetInfo)
	local info = {}
	local roomInfo = packetInfo.roomInfo
	info.deskFees = roomInfo.deskFees
	info.baseChip = roomInfo.baseChip
	info.roomLevel = roomInfo.roomLevel
	info.roomType = roomInfo.roomType

	info.totalRound = roomInfo.totalRound
	info.currentRound = roomInfo.currentRound
	info.creatorId = roomInfo.creatorId
	info.roomCode = roomInfo.roomCode
	info.privateStatus = roomInfo.privateStatus
	info.privateModel = roomInfo.privateModes

	
	info.players = __formatPlayers(packetInfo.players)

	info.gameStatus = packetInfo.gameStatus--游戏状态 0:准备，1:叫分 2 出牌
	info.mySeatId = packetInfo.mySeatId
	info.currentSeat = packetInfo.currentSeat	--当前出牌的人
	info.actionTime = packetInfo.actionTime
	info.kingSeatId = packetInfo.kingSeatId
	info.zhuangSeatId = packetInfo.zhuangSeatId
	info.myOpe = packetInfo.myOpe
	info.zhuangXianInfo = packetInfo.zhuangXianInfo
	info.currPoolScoreCards = packetInfo.currPoolScoreCards
	info.currPoolScore = packetInfo.currPoolScore
	info.hasKingOut = packetInfo.hasKingOut
	info.lastTurnInfos = __formatLastTurnInfo(packetInfo.lastTurnInfo) 
	info.isNewTurn = packetInfo.isNewTurn
	info.zhuangScoreCards  = packetInfo.zhuangScoreCards  --庄家的得分牌
	info.xianScoreCards   = packetInfo.xianScoreCards   --闲家的得分牌

	dump(info,"超神重连",4)
	self.__controller:onUserReconnectSucc(info)
end


function GameSocketProcesser:onBroadUserAuto(packetInfo)
	local info = {}
	info.userId = packetInfo.userId
	info.seatId = packetInfo.seatId
	info.status = packetInfo.status --//托管状态1：托管 0：取消托管
	dump(info,"广播托管",4)
	self.__controller:onBroadUserAutoSucc(info)
end

local function __formatPrivateReslutList(result)
	local lists = {}
	for i=1,#result do
		local player = {}
		local pbPlayer = result[i]
		player.uid = pbPlayer.userId
		player.money = pbPlayer.totalScore
		player.isWinner = pbPlayer.isBigWinner==true and 1 or 0
		player.userInfo = pbPlayer.userInfo
		player.winCounts = pbPlayer.winCounts
		player.baopaiCounts = pbPlayer.baopaiCounts
		player.firstCounts = pbPlayer.firstCounts
		table.insert(lists,player)
	end
	return lists
end

function GameSocketProcesser:onBroadCastPrivateReslut(packetInfo )
	dump(packetInfo,"onBroadCastPrivateReslut_packetInfo",10)
	local info = {}
	info.currentRound = packetInfo.currentRound
	info.totalRound = packetInfo.totalRound
	info.totalPlayer = packetInfo.totalPlayer
	info.players =__formatPrivateReslutList(packetInfo.players)
	dump(info,"onBroadCastPrivateReslut",10)
	self.__controller:boradPrivateGameResult(info)
end

function GameSocketProcesser:broadDissRoomResult(packetInfo)
	print("解散房间结果")
	self.__controller:broadDissRoomResult(packetInfo)
end
--广播当前轮次
function GameSocketProcesser:broadRoomCurrentRound(packetInfo)
	local info = {}
	info.totalRound = packetInfo.totalRound
	info.currentRound = packetInfo.currentRound
	dump(info,"0x1718 broad currentRound")
	self.__controller:broadRoomCurrentRound(info)
end
function GameSocketProcesser:broadDissRoomStatus(packetInfo)
	self.__controller:broadDissRoomStatus(packetInfo)
end

function GameSocketProcesser:GAMESER2C_PLAYER_OFFLINE( packetInfo )
	dump(packetInfo,"下线",5)
	self.__controller:broadPlayerOffline(packetInfo)
end

function GameSocketProcesser:GAMESER2C_PLAYER_ONLINE( packetInfo )
	dump(packetInfo,"上线",5)
	self.__controller:broadPlayerOnline(packetInfo)
end



function GameSocketProcesser:onBroadUserHitBall(packetInfo)
	self.__controller:onBroadUserHitBall(packetInfo)
end

function GameSocketProcesser:onBroadUserTurn(packetInfo)
	self.__controller:onBroadUserTurn(packetInfo)
end

function GameSocketProcesser:onBroadCueLineData(packetInfo)
	self.__controller:onBroadCueLineData(packetInfo)
end


function GameSocketProcesser:onBroadUserColor(packetInfo)
	self.__controller:onBroadUserColor(packetInfo)
end



function GameSocketProcesser:onBroadWhiteBallPos(packetInfo)
	self.__controller:onBroadWhiteBallPos(packetInfo)
end


GameSocketProcesser.s_severCmdEventFuncMap = 
{
	[GameSocketCmd.LOGIN_GAME] = GameSocketProcesser.onLoginGame,


	[GameSocketCmd.BROADCAST_USER_HIT_BALL] = GameSocketProcesser.onBroadUserHitBall,
	[GameSocketCmd.BROADCAST_USER_TURN] = GameSocketProcesser.onBroadUserTurn,
	[GameSocketCmd.BROADCAST_USER_READY] = GameSocketProcesser.onBroadUserReady,
	[GameSocketCmd.BROADCAST_GAME_START]	= GameSocketProcesser.onGameStart,
	[GameSocketCmd.BROADCAST_USER_LOGIN_GAME] = GameSocketProcesser.onBroadUserLogin,
	[GameSocketCmd.CMD_C2GAMESER_CURLINE]= GameSocketProcesser.onBroadCueLineData,
	[GameSocketCmd.BROADCAST_USER_COLORS] = GameSocketProcesser.onBroadUserColor,
	[GameSocketCmd.CMD_C2GAMESER_BROAD_WHITEBALL] = GameSocketProcesser.onBroadWhiteBallPos,


	-- [GameSocketCmd.BROADCAST_USER_READY]	= GameSocketProcesser.onBroadUserReady,
	-- [GameSocketCmd.BROADCAST_GAME_START]	= GameSocketProcesser.onGameStart,
	-- [GameSocketCmd.BROADCAST_USER_LOGOUT_GAME]		= GameSocketProcesser.onUserLoginOut,
	-- [GameSocketCmd.BROADCAST_GAME_OVER]				= GameSocketProcesser.onBroadGameOver,
	-- [GameSocketCmd.NOTIFY_USER_RECONNECT]			= GameSocketProcesser.onUserReconnect,
	-- [GameSocketCmd.BROADCAST_USER_CHANGE_TRUST]		= GameSocketProcesser.onBroadUserAuto,
	-- [GameSocketCmd.PRIVATE_GAME_OVER_RESULT]		= GameSocketProcesser.onBroadCastPrivateReslut,
	-- [GameSocketCmd.BROAD_DISS_ROOM_RESULT]	= GameSocketProcesser.broadDissRoomResult,
	-- [GameSocketCmd.BROAD_DISS_PLAYER_STATUS] = GameSocketProcesser.broadDissRoomStatus,
	-- [GameSocketCmd.BORAD_PRIVATE_CURRENT_ROUND]	= GameSocketProcesser.broadRoomCurrentRound,
	-- [GameSocketCmd.GAMESER2C_PLAYER_OFFLINE] = GameSocketProcesser.GAMESER2C_PLAYER_OFFLINE,
 --    [GameSocketCmd.GAMESER2C_PLAYER_ONLINE] = GameSocketProcesser.GAMESER2C_PLAYER_ONLINE,

	-- [GameSocketCmd.BROADCAST_TO_OUT_CARD]	= GameSocketProcesser.onStartOutCard,
	-- [GameSocketCmd.BROADCAST_USER_OUT_CARD_RESULT]	= GameSocketProcesser.onOutCard,
	-- [GameSocketCmd.NOTIFY_USER_OPERATE]	= GameSocketProcesser.notifyUserOperate,
	-- [GameSocketCmd.BROADCAST_USER_OPERATE]	= GameSocketProcesser.broadUserOperate,
	-- [GameSocketCmd.BROADCAST_SYC_ZHUANG_XIAN_INFO]	= GameSocketProcesser.broadSYCZhuangXianInfo,
	-- [GameSocketCmd.NOTIFY_USER_OUTCARD_OPERATE]	= GameSocketProcesser.notify_user_outcard_opreate,
	-- [GameSocketCmd.BROADCAST_CLIENT_SHOW_OR_HIDE_INFO]	= GameSocketProcesser.broadcast_client_show_or_hide_info,

	 


	 
 

	 
}



return GameSocketProcesser