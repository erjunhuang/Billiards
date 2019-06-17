local CMD = 
{
    SERVER_COMMAND_CONNECTED = 0x99999, --连接成功        
    SERVER_COMMAND_CLOSE     = 0x99998, --连接关闭
    SERVER_COMMAND_CLOSED    = 0x99997,
    SERVER_COMMAND_OFFLINE   = 0x99996, -- 网络不可用


    SERVER_CONNECT_FAILURE   = 0x99996,
    SERVER_HEART_TIME_OUT    = 0x99995,
    SERVER_SVR_ERROR         = 0x99994,
    SERVER_LOGIN_TIME_OUT    = 0x99993,

    SVR_LOGIN                = 0x0201, --登录大厅成功
    SVR_GET_TID              = 0x0301, --回应分配房间
    SVR_LOGIN_ERR            = 0x1703, --登录大厅失败
    SVR_CREATE_ROOM_SUCC     = 0x1711, --回应创建私人房
    SVR_JOIN_ROOM_SICC 	     = 0x1727, --回应加入私人房(新版2018.07.18)
    SVR_PRIVATE_ROOM_ERR     = 0x1714, --私人房错误
    SVR_CLUB_OPERATE_ERR     = 0x171D, --俱乐部私人房操作失败

    SVR_JOIN_ROOM_SICC_OLD   = 0x1712, --兼容(2018.07.24)

    CLI_LOGIN                = 0x0201,  --登录大厅
    CLI_GET_TID              = 0x0301,  --获取分配房间
    CLI_CREATE_ROOM          = 0x1711,	--请求创建私人房
    CLI_JOIN_ROOM	         = 0x1727,  --请求进入私人房(新版2018.07.18)
    C2GATE_REPORT_IP         = 0x1733,  --同步用户IP
    SVR_BROAD_MUTIL_USER     = 0x4011, --PHP全服广播

    SVR_BROAD_SINGLE_SINGLE  = 0x400E, --PHP单播

    SVR_UPDATE_DATA          = 0x1819, --服务器更新数据

    CLISVR_HEART_BEAT        = 0x0101, --server心跳包

    SVR_DOUBLE_LOGIN         = 0x0043, --用户重复登录

    SVR_CLUB_KICK_USER       = 0x5002, --俱乐部踢出玩家

}



return CMD