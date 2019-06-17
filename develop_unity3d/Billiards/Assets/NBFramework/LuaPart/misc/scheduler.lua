local UpdateBeat = UpdateBeat

local scheduler = {}

function scheduler.scheduleUpdateGlobal(listener,obj)
	local handle = UpdateBeat:CreateListener(listener,obj)
	UpdateBeat:AddListener(handle)	
	UpdateBeat:Dump()
    return handle
end


function scheduler.unscheduleGlobal(handle)
	if not handle then
		return
	end
	if type(handle.Start) == "function" and type(handle.Stop) == "function" then
		--Timer
		handle:Stop()
	else
		UpdateBeat:RemoveListener(handle)
	end
    
end

function scheduler.performWithDelayGlobal(listener, time)
	local handle
    handle = Timer.New(function()
    	handle:Stop()
        listener()
    end, time, 1)
    handle:Start()
    return handle
end

function scheduler.scheduleGlobal(listener, interval)
	local handle
    handle = Timer.New(function()
        listener()
    end, interval, -1)
    handle:Start()
    return handle
end


return scheduler