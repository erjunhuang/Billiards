
local CMD = import("..GameSocketCmd")
local GDProto = import(".NetProto")
local protoPath = "billiards.net.pb.NetProto"
local lpb = require "pb"

local default = { pb = protoPath, pkg = "billiardpb", msg = ""}

local ProtoConfig = {}

ProtoConfig.C2S = {}
ProtoConfig.C2S[CMD.LOGIN_GAME] = "LoginGameReq"
ProtoConfig.C2S[CMD.USER_HIT_BALL] = "HitBall"
ProtoConfig.C2S[CMD.REPORT_HIT_BALL_RESULT] = "HitBallRes"
ProtoConfig.C2S[CMD.CMD_C2GAMESER_CURLINE] = "CueData"
ProtoConfig.C2S[CMD.CMD_C2GAMESER_BROAD_WHITEBALL] = "WhiteBallData"


-- ------------------------------------------------------
ProtoConfig.S2C = {}

ProtoConfig.S2C[CMD.LOGIN_GAME] = "LoginGameAck"
ProtoConfig.S2C[CMD.BROADCAST_USER_READY] = "BroadReady"
ProtoConfig.S2C[CMD.BROADCAST_USER_TURN] = "BroadTurn"
ProtoConfig.S2C[CMD.BROADCAST_USER_HIT_BALL] = "HitBall"
ProtoConfig.S2C[CMD.BROADCAST_USER_LOGIN_GAME] = "BroadLoginGame"
ProtoConfig.S2C[CMD.CMD_C2GAMESER_CURLINE] = "CueData"
ProtoConfig.S2C[CMD.BROADCAST_USER_COLORS] = "ColorData"
ProtoConfig.S2C[CMD.CMD_C2GAMESER_BROAD_WHITEBALL] = "WhiteBallData"


ProtoConfig.pbFile = {}


function ProtoConfig.getProto(flag, cmd)

    print("getProto",flag, cmd)
    local proto = nil;
    local message = ProtoConfig[flag][cmd];
    if not message then 
       -- error(string.format('unknow cmd : 0x%02x',cmd));
        return 
    end

     print("getProto000",message)

    local tab = {};
    if type(message) == "string" then
        tab = clone(default);
        tab.msg = message;
    else
        tab = message;
    end
    print("getProto111",tab.pb,ProtoConfig.pbFile[tab.pb])
    if ProtoConfig.pbFile[tab.pb] == nil then
        local buffer = require(tab.pb)
        print("getProto222",lpb.load(buffer))
        ProtoConfig.pbFile[tab.pb]  = lpb.load(buffer);
    end

    return tab.pkg .. "." .. tab.msg
end

return ProtoConfig