local SeatView = import(".views.SeatView")
local SeatManager = class("SeatManager")

function SeatManager:ctor( ... )
	-- body
end


function SeatManager:createNodes(controller)
	print("createNodes")
	local scene = self.scene
	self.playerList_ = {}

	local infoView = scene.infoView

	local seatView = nil
	for i=1,2,1 do
		local viewName = string.format("infoBar%s",i)
		local view = infoView.transform:Find(viewName)
		print("createNodes",view)
		seatView = SeatView.new(self.ctx,i,view)
		print("createNodes",seatView)
		self.playerList_[i] = seatView
		print("createNodes",seatView)
	end

end


function SeatManager:initSeats()
	local model = self.model
	print("initSeats000")
	local playerList = model:getPlayerList()
	print("initSeats222")
	for k,v in pairs(playerList) do
		local clientSeatId = model:getClientSeatNum(v.seatId)
		print("initSeats333",v.seatId,clientSeatId)
		self.playerList_[clientSeatId]:setData(v)
		print("initSeats444",v.seatId,clientSeatId)
		
	end
end


function SeatManager:setBalls(seatId,balls)
	print("SeatManager:setBalls",seatId,json.encode(balls))
	local model = self.model
	local playerList = model:getPlayerList()
	local clientSeatId = model:getClientSeatNum(seatId)
	self.playerList_[clientSeatId]:setBalls(balls)
end

function SeatManager:addPlayer(data)
	local model = self.model
	local clientSeatId = model:getClientSeatNum(data.seatId)
	self.playerList_[clientSeatId]:setData(data)
	-- self.playerList_[clientSeatId]:show()
end

function SeatManager:removePlayer(seatId)
	local model = self.model
	local clientSeatId = model:getClientSeatNum(seatId)
	-- self.playerList_[clientSeatId]:hide()
	self.playerList_[clientSeatId]:setData()
end



function SeatManager:startCounter(uid,time)
	print("SeatManager:startCounter000",uid)

	print(self,"self")
	local model = self.model
	print("SeatManager:startCounter222222",model)

	self:stopAllCounter()
	print("SeatManager:startCounter33333333",model)

	print("SeatManager:startCounter4444444444",uid)

	local player = model:findSeatByUid(uid)
	print("SeatManager:startCounter55555555555",player.seatId)
	if player and player.seatId and player.seatId > -1 then
		local clientSeatId = model:getClientSeatNum(player.seatId)
		self.playerList_[clientSeatId]:startCounter(time)
	end
end

function SeatManager:stopAllCounter()
	for _,v in pairs(self.playerList_) do
		v:stopCounter()
	end
end



function SeatManager:reset( ... )
	self:stopAllCounter()
	for _,v in pairs(self.playerList_) do
		v:setBalls({})
	end
end

function SeatManager:dispose( ... )
	-- body
end


return SeatManager