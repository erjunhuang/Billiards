local CMD = 
{

    LOGIN_GAME           = 0x0401, --登录游戏 请求和返回 c2s s2c
    USER_READY           = 0x0402, --准备 请求 c2s
    BROADCAST_USER_READY = 0x0403, --广播用户准备 s2c
    BROADCAST_GAME_START = 0x0404,--广播游戏开始 s2c

    USER_HIT_BALL = 0x0405,--上报白球击球数据
    BROADCAST_USER_HIT_BALL= 0x0406,--广播用户击球数据
    REPORT_HIT_BALL_RESULT = 0x0407, --上报击球结果
    BROADCAST_GAME_OVER  = 0x0408, --广播游戏结束
    BROADCAST_USER_TURN = 0x0409, --广播轮到谁击球
    BROADCAST_USER_LOGIN_GAME = 0x040A,--广播用户登录
    CMD_C2GAMESER_CURLINE = 0x040B,--广播瞄准线

    BROADCAST_USER_COLORS       = 0x040C,  --广播花色确认

    CMD_C2GAMESER_BROAD_WHITEBALL = 0x040D,--发送和广播白球摆放位置


    CMD_C2GAMESER_LOGOUT = 0x040E,--请求退出游戏

    LOGOUT_GAME          = 0x040E, --登出游戏 c2s

    BROADCAST_USER_LOGOUT_GAME  = 0x040F, --广播用户退出(退桌) s2c


    CMD_C2GAMESER_RECONNECT          = 0x0410, --重连数据




    SVR_SEND_CHAT        = 0x1803, -- 聊天（发包，接收广播）
    USER_CHANGE_TRUST           = 0x180D,--玩家托管
    BROADCAST_USER_CHANGE_TRUST = 0x180E, --广播玩家进入托管状态
    BROADCAST_DEAL_CARDS        = 0x1810,--广播发牌 s2c

    GAMESER2C_PLAYER_ONLINE     = 0x181B, --用户上线
    GAMESER2C_PLAYER_OFFLINE    = 0x181C, --用户下线



    USER_OUT_CARD               = 0x1812, --玩家提交出牌操作
    NOTIFY_USER_RECONNECT       = 0x1813, --重连
    
    PRIVATE_GAME_OVER_RESULT    = 0x1816,  --私人房总结算
    SVR_SEND_INTERACTION_PROP   = 0x1817, -- 发送互动道具（发包，接受广播）

    CLE_SEND_DISS_ROOM          = 0x1713,--玩家申请解散
    CLE_SEND_DISS_ROOM_CONFIRM  = 0x1717,--其他玩家确认是否解散(发起人除外)
    BROAD_DISS_ROOM_RESULT      = 0x1715,-- 广播解散房间结果
    BROAD_DISS_PLAYER_STATUS    = 0x1716,--广播解散私人房玩家确认状态
    BORAD_PRIVATE_CURRENT_ROUND = 0x1718,--广播当前轮(私人房)
    BROADCAST_RRIVATE_RESULT    = 0x190D, --广播私人房结算
     

    NOTIFY_USER_OPERATE             = 0x1901, -- 通知用户操作 s2c
    USER_OPERATE                    = 0x1902, -- 用户提交操作 c2s
    BROADCAST_USER_OPERATE          = 0x1903, -- 广播用户操作s2c
    BROADCAST_TO_OUT_CARD           = 0x1904, --广播开始出牌
    BROADCAST_USER_OUT_CARD_RESULT  = 0x1905, --广播玩家出牌结果
    BROADCAST_SYC_ZHUANG_XIAN_INFO = 0x1906, --同步庄闲信息
    NOTIFY_USER_OUTCARD_OPERATE    = 0x1907, --通知用户出牌操作码 s2c

    BROADCAST_CLIENT_SHOW_OR_HIDE_INFO = 0x19FF, --广播客户端显示或者隐藏信息


    BROADCAST_LUA_ERROR = 0x4004;--lua报错


}


return CMD