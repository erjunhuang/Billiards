local consts = {}

consts.SVR_GAME_STATUS = {}
-- 0牌局已结束 1下注中 2等待用户获取第3张牌
local states = consts.SVR_GAME_STATUS
states.READY_TO_START         = 1 --准备等待开始
states.MAKE_COLOR 	     = 2 --确认花色
states.HIT_BALL    = 3 --确认花色后击球中


return consts