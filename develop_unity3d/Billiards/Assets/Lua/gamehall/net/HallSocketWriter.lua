local HallSocketWriter = class("HallSocketWriter",core.SocketWriter)

function HallSocketWriter:ctor( ... )
	HallSocketWriter.super.ctor(self)
end


HallSocketWriter.s_clientCmdFunMap = 
{
	
}


return HallSocketWriter