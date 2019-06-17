local scheduler = require("misc.scheduler")
local SeatView = class("SeatView")


function SeatView:ctor(ctx,index,view)
	self.__ctx = ctx
	self.__view = view
	self.__index = idx
	self.__nameTxt = view.transform:Find("nameTxt"):GetComponent("Text")
	self.__progress = view.transform:Find("progress"):GetComponent("Image")

	print("SeatView:ctor",index,view)
	print("SeatView:ctor-nameTxt",self.__nameTxt)
	print("SeatView:ctor-progress",self.__progress)


	self.__balls = {}
	for i = 1,7 do
		self.__balls[i] = view.transform:Find("ball" .. i):GetComponent("Image")
	end

end


function SeatView:setBalls(tb)
	print("SeatView:setBalls",json.encode(tb))
	local sheet = self.__ctx.scene.infoBallSheet
	print("SeatView:setBalls",sheet)
	if sheet then
		for i,v in ipairs(self.__balls) do
			local ballno = tb[i]
			if ballno then
				self.__balls[i].enabled = true
				print("SeatView:sheet",string.format("ball_%s",ballno),sheet.spriteCount,sheet:GetSprite(string.format("ball_%s",ballno)))
				self.__balls[i].sprite = sheet:GetSprite(string.format("ball_%s",ballno))
			else
				self.__balls[i].enabled = false
			end
		end
	end
end



function SeatView:setData(data)
	dump(data,"SeatView-setData")
	self.userdata_ = data
	self:setBalls({})
	if data then
		self.__nameTxt.text = (data.userInfo.name or "")
	else
		self.__nameTxt.text = ""
	end
end

function SeatView:getData()
	return self.userdata_
end

function SeatView:isEmpty()
    return not self.userdata_
end


function SeatView:startCounter(time)
	print("SeatView:startCounter",time)
	self:stopCounter()
	self.__progress.enabled = true
	self.__currentTime = 0
	self.__totalTime = time
	self.__counterHander = scheduler.scheduleUpdateGlobal(self.onCounterUpdate,self)
	
end


function SeatView:onCounterUpdate(deltaTime, unscaledDeltaTime)

	-- print("SeatView:onCounterUpdate",deltaTime, unscaledDeltaTime)
	self.__currentTime = self.__currentTime + deltaTime

	local rate = self.__currentTime/self.__totalTime
	local color
	if rate >= 0 and rate <0.5 then
		color = Color.green
	elseif rate >= 0.5 and rate <0.75 then
		color = Color.yellow
	elseif rate >= 0.75 and rate <=1 then
		color = Color.red
	end

	self.__progress:GetComponent("Image").fillAmount = (1-checknumber(rate))
	self.__progress.color = color

	if self.__currentTime > self.__totalTime then
		self:stopCounter()
	end

end


function SeatView:stopCounter( ... )

	-- print("SeatView:stopCounter000")
	if self.__counterHander then
		scheduler.unscheduleGlobal(self.__counterHander)
		self.__counterHander = nil
	end
-- print("SeatView:stopCounter111111",self.__progress)
	self.__progress.enabled = false
	-- print("SeatView:stopCounter22222")
end


function SeatView:reset( ... )
	self:setBalls({})
end



return SeatView