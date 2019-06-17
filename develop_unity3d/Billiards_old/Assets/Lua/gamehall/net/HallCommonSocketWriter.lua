local HallSocketCmd = import(".HallSocketCmd")

local lpb = require "pb"
local pbConf = import(".pb.ProtoConfig")

local HallCommonSocketWriter = class("HallCommonSocketWriter",core.SocketWriter)

function HallCommonSocketWriter:ctor()
	HallCommonSocketWriter.super.ctor(self)
end

function HallCommonSocketWriter:writeProto(packetId,info,cmd)

    -- dump(cmd, "HallCommonSocketWriter:writeProto111111111:"..HallSocketCmd.info[cmd])
    -- dump(info, "HallCommonSocketWriter:writeProto222222222")

	local proto = pbConf.getProto("C2S", cmd);

	print("writeProto",proto,json.encode(info))
	local buf = lpb.encode(proto,info)
	print("buf000",lpb.tohex(buf))
	print("Base64",Base64.encode("dsfadfasfa"))
	print("NBTool",NBTool.Base64Encode("dsfadfasfa"))
	local lbuf = lpb.decode(proto,buf)
	dump(json.encode(lbuf),"writeProto000")
	print("writeProto",buf,cmd)
	self.__socket:writeBinary(packetId,buf)
end


HallCommonSocketWriter.s_clientCmdFunMap = 
{
	[HallSocketCmd.CLI_LOGIN] = HallCommonSocketWriter.writeProto,
	[HallSocketCmd.CLI_GET_TID] = HallCommonSocketWriter.writeProto,

}



return HallCommonSocketWriter