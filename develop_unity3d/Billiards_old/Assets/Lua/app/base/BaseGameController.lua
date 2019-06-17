local BaseGameSocketProcesser = import(".BaseGameSocketProcesser")
local BaseGameSocketWriter = import(".BaseGameSocketWriter")
local BaseGameSocketReader = import(".BaseGameSocketReader")
local BaseGameSocketCmd = import(".BaseGameSocketCmd")

local CAnimManager = import("..AnimManager")

local BaseController = import(".BaseController")
local BaseGameController = class("BaseGameController")

local PACKET_PROC_FRAME_INTERVAL = 2

BaseGameController.SOCKET_LOOP_TYPE_NORMAL = 1
BaseGameController.SOCKET_LOOP_TYPE_DELAY = 2

function BaseGameController:ctor(scene)
    BaseGameController.super.ctor(self,scene)
    self.packetCache_ = {}
    self:init()
end


function BaseGameController:init( ... )
	local ctx = {}
    ctx.gameController = self
    ctx.scene = self.__scene
    ctx.schedulerPool = core.SchedulerPool.new()
    ctx.sceneSchedulerPool = core.SchedulerPool.new()
    ctx.gameSchedulerPool = core.SchedulerPool.new()
    ctx.cAnimManager = CAnimManager.new()

    ctx.export(self)
    ctx.export(ctx.cAnimManager)

end


--启动socket事件循环
function BaseGameController:startSocketLoop(cmdTb,isBoard,loopType)


	if loopType == BaseGameController.SOCKET_LOOP_TYPE_DELAY then


	else


	end
	
	self.__needSockLoop = true
	cmdTb = cmdTb or {}
	self.__startCmd = nil
    self.__endCmd = nil
	if isBoard then
		local startCmd = table.remove(cmdTb,1)
		local endCmd = table.remove(cmdTb,#cmdTb)
		self.__startCmd = startCmd
		self.__endCmd = endCmd
	end

	self.__filterCmds = cmdTb

    self.packetCache_ = {}
    self.frameNo_ = 1

    self.ctx.sceneSchedulerPool:loopCall(handler(self, self.onEnterFrame_), 1 / 30)
    self.ctx.sceneSchedulerPool:loopCall(function()
        nb.Director:getInstance():getTextureCache():removeUnusedTextures()
        return not self.isDisposed_
    end, 60)
end



function BaseGameController:onConnected_()
    self.packetCache_ = {}
end

function BaseGameController:onPacketReceived_(cmd,packet)
    print("BaseGameController:onPacketReceived_")


    table.insert(self.packetCache_, packet)
end


function BaseGameController:processPacket_(cmd,pack)
    self:handleSocketCmd(cmd,pack)
end


function BaseGameController:onEnterFrame_(dt)
    if #self.packetCache_ > 0 then
        if #self.packetCache_ == 1 then
            self.frameNo_ = 1
            local pack = table.remove(self.packetCache_, 1)
            self:processPacket_(pack)
        else
            --先检查并干掉累计的超过一局的包
            local removeFromIdx = 0
            local removeEndIdx = 0
            for i, v in ipairs(self.packetCache_) do
                if v.cmd == self.__endCmd then
                    if removeFromIdx == 0 then
                        removeFromIdx = i + 1 --这里从结束包的下一个开始干掉
                    else
                        removeEndIdx = i --到最后一个结束包
                    end
                end
            end
            if removeFromIdx ~= 0 and removeEndIdx ~= 0 then
                print("!=!=!=! THROW AWAY PACKET FROM " .. removeFromIdx .. " to " .. removeEndIdx)
                --干掉超过一局的包，但是要保留坐下站起包，以保证座位数据正确
                local keepPackets = {}
                for i = removeFromIdx, removeEndIdx do
                    local pack = table.remove(self.packetCache_, removeFromIdx)
                    if table.indexof(self.__filterCmds,pack.cmd) then
                        keepPackets[#keepPackets + 1] = pack
                        pack.fastForward = true
                    end
                end
                if #keepPackets > 0 then
                    table.insertto(self.packetCache_, keepPackets, removeFromIdx)
                end
            end
            self.frameNo_ = self.frameNo_ + 1
            if self.frameNo_ > PACKET_PROC_FRAME_INTERVAL then
                self.frameNo_ = 1
                local pack = table.remove(self.packetCache_, 1)
                self:processPacket_(pack)
            end
        end
    end
    return true
end



function BaseController:handleSocketCmd(cmd,...)
	if not self.s_socketCmdFuncMap[cmd] then
		print("Not such socket cmd in current controller");
		return;
	end

	if self.__needSockLoop then


	else

	end

	return self.s_socketCmdFuncMap[cmd](self,...);
end

function BaseGameController:dispose()
    BaseGameController.super.dispose(self)
    self.isDisposed_ = true
    self.cAnimManager:dispose()
    self.ctx.schedulerPool:clearAll()
    self.ctx.sceneSchedulerPool:clearAll()
    self.ctx.gameSchedulerPool:clearAll()
end






return BaseGameController