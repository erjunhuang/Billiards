local PluginIosBase = import(".PluginIosBase")
local AmapPluginIos = class("AmapPluginIos",PluginIosBase)

local AMapLocationMode = 
{
	Battery_Saving = 0,
	Device_Sensors = 0,
	Hight_Accuracy = 0,
}

function AmapPluginIos:ctor()
	AmapPluginIos.super.ctor(self,"AmapPluginIos","AmapBridge")
end


function AmapPluginIos:init()

	print(debug.traceback("", 3))
	if not self.isInit_ then
		self:call_("setAmapNotify", {listener = handler(self,self.onAmapNotify)})
		--test--
		self:initLocation()
		-- self:startLocation()
		self.isInit_ = true
	end
	
end

function AmapPluginIos:getLocationInfo()
	if not game.userData["aUser.mid"] then
		return
	end


	local retryLimit = 30
    game.Amap:startLocation(function ( etype,jsonObj )
    	if retryLimit < 0 then
    		game.Amap:stopLocation()
    		return
    	end
    	if etype =="ok" then
            if jsonObj.accuracy then
            	if jsonObj.city then
	            	if checkint(jsonObj.accuracy) > 0 and checkint(jsonObj.accuracy) <= 70 then
	            		game.Amap:stopLocation()
	            	end
	            end 
            else
            	if jsonObj.city then
	            	--多定位几次
	            	if retryLimit < 25 then
			    		game.Amap:stopLocation()
			    	end
	            end 
            end   
	    else

	    end
	    retryLimit = retryLimit - 1
    end)
end


function AmapPluginIos:onAmapNotify(jsonObj)
	if not jsonObj then
		return 
	end

	local atype = jsonObj.atype
	if atype == "location" then
		self:handleLocation(jsonObj)

	end

end

function AmapPluginIos:handleLocation(jsonObj)
	dump(jsonObj,"handleLocation")
	local etype = jsonObj.etype

	if etype =="ok" then
        dump(jsonObj,"etype-jsonObj++++++",5)
        game.userData["aUser.longitude"] = jsonObj.longitude
        game.userData["aUser.latitude"] = jsonObj.latitude
        game.userData["aUser.gpsCode"] = 0
        game.userData["aUser.isGps"] = "1"

        if jsonObj.accuracy then
        	if jsonObj.city then
            	game.userData["aUser.province"] = jsonObj.province
            	game.userData["aUser.city"] = jsonObj.city
            	local formattedAddress = ""..tostring( jsonObj.province or "")..tostring( jsonObj.city or "" )..tostring(jsonObj.district or "")..tostring( jsonObj.street or "" )
            	-- if jsonObj.formattedAddress then
            	-- 	formattedAddress = jsonObj.formattedAddress
            	-- end
            	game.userData["aUser.formattedAddress"] = formattedAddress
            end 
        else
        	if jsonObj.city then
            	game.userData["aUser.province"] = jsonObj.province
            	game.userData["aUser.city"] = jsonObj.city

            	local formattedAddress = ""..tostring( jsonObj.province or "")..tostring( jsonObj.city or "" )..tostring(jsonObj.district or "")..tostring( jsonObj.street or "" )
            	-- if jsonObj.formattedAddress then
            	-- 	formattedAddress = jsonObj.formattedAddress
            	-- end
            	game.userData["aUser.formattedAddress"] = formattedAddress
            end 
        end   
    else
     	game.userData["aUser.formattedAddress"] = "定位失败"
        local errCode = jsonObj and jsonObj.errCode or 1001
        game.userData["aUser.gpsCode"] = errCode
    	game.userData["aUser.isGps"] = "0"
    end


	if self.locationCallback_ then
		self.locationCallback_(etype,jsonObj)
	end
end


function AmapPluginIos:calculateLineDistance(slatitude,slongitude,elatitude,elongitude)
	print("AmapPluginIos:calculateLineDistance",tostring(slatitude),tostring(slongitude),tostring(elatitude),tostring(elongitude) )
	local ok, ret = self:call_("calculateLineDistance", {slatitude = slatitude,slongitude=slongitude,elatitude=elatitude,elongitude=elongitude})
	if ok then
		return ret
	end
	return 0
end


function AmapPluginIos:initLocation()
	self:call_("initLocation",{appKey = appconfig.amapAppKey})
	
end


--销毁定位
function AmapPluginIos:destroyLocation()
	self:call_("destroyLocation")
end


function AmapPluginIos:startLocation(callback)
	self.locationCallback_ = callback
	self:call_("startLocation")
end


function AmapPluginIos:stopLocation(doClean)
	self:call_("stopLocation")
	if doClean then
		self.locationCallback_  = nil
	end
end

function AmapPluginIos:cancelCallback( ... )
	self.locationCallback_  = nil
end

return AmapPluginIos