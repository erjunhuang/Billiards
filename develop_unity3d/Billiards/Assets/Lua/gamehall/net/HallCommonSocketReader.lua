local HallSocketCmd = import(".HallSocketCmd")

local lpb = require "pb"
local pbConf = import(".pb.ProtoConfig")


local HallCommonSocketReader = class("HallCommonSocketReader",core.SocketReader)

function HallCommonSocketReader:ctor()
	HallCommonSocketReader.super.ctor(self)
end


function HallCommonSocketReader:readProto(packetId,cmd)
	local buf = self.__socket:readBinary(packetId);

	print("readProto",cmd,buf)
	local proto = pbConf.getProto("S2C", cmd);
	local info = lpb.decode(proto,buf)
	
	dump(json.encode(info), "GameSocketReader:readProto-------------------", cmd)
	return info;
end



function HallCommonSocketReader:onUserDoubleLogin(packetId)
	local info = {}
	
	return info
end

HallCommonSocketReader.s_severCmdFunMap = 
{
	[HallSocketCmd.SVR_LOGIN] = HallCommonSocketReader.readProto,
	[HallSocketCmd.SVR_GET_TID] = HallCommonSocketReader.readProto,
	

}

return HallCommonSocketReader