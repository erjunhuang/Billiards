
local CMD = import("..HallSocketCmd")
local GDProto = import(".NetProto")
local protoPath = "gamehall.net.pb.NetProto"
local lpb = require "pb"

local default = { pb = protoPath, pkg = "hallpb", msg = ""}

local ProtoConfig = {}

ProtoConfig.C2S = {}
ProtoConfig.C2S[CMD.CLI_LOGIN] = "LoginHallReq"
ProtoConfig.C2S[CMD.CLI_GET_TID] = "AllocReq"



-- ------------------------------------------------------
ProtoConfig.S2C = {}

ProtoConfig.S2C[CMD.SVR_LOGIN] = "LoginHallAck"
ProtoConfig.S2C[CMD.SVR_GET_TID] = "AllocAck"


ProtoConfig.pbFile = {}


function ProtoConfig.getProto(flag, cmd)

    print("getProto",flag, cmd)
    local proto = nil;
    local message = ProtoConfig[flag][cmd];
    if not message then 
        error(string.format('unknow cmd : 0x%02x',cmd));
        return 
    end

     print("getProto",message)

    local tab = {};
    if type(message) == "string" then
        tab = clone(default);
        tab.msg = message;
    else
        tab = message;
    end

    print(Base64.decode("dddd"),"decode")
    print("getProto",tab.pb,ProtoConfig.pbFile[tab.pb])
    if ProtoConfig.pbFile[tab.pb] == nil then
        local buffer = require(tab.pb)
        print("getProto",lpb.load(buffer))
        ProtoConfig.pbFile[tab.pb]  = lpb.load(buffer);
    end

    return tab.pkg .. "." .. tab.msg
end

return ProtoConfig