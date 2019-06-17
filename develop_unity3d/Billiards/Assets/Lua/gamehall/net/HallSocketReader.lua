local HallSocketReader = class("HallSocketReader",core.SocketReader)

function HallSocketReader:ctor( ... )
	HallSocketReader.super.ctor(self)
end



HallSocketReader.s_severCmdFunMap = 
{

}

return HallSocketReader