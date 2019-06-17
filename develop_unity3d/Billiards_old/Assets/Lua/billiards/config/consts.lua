local consts = {}

consts.SVR_GAME_STATUS = {}
-- 0牌局已结束 1下注中 2等待用户获取第3张牌
local states = consts.SVR_GAME_STATUS
states.READY_TO_START         = 1 --准备等待开始
states.TURN_HIT_BALL 	     = 2 --等待用户获取第3张牌
states.GAME_OVER    = 3 --结算