local UpdateBeat = UpdateBeat


-- dump(UpdateBeat,"UpdateBeat")


local scheduler = {}


function scheduler.scheduleUpdateGlobal(listener,obj)
	local handle = UpdateBeat:CreateListener(listener,obj)
	UpdateBeat:AddListener(handle)	
	print("AddListener555")
	UpdateBeat:Dump()
    return handle
end



function scheduler.unscheduleGlobal(handle)
    UpdateBeat:RemoveListener(handle)
end


function scheduler:performWithDelayGlobal( ... )
	-- body
end


function scheduler:scheduleGlobal( ... )
	-- body
end






return scheduler