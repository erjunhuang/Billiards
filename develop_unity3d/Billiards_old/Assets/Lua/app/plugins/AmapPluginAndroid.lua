local PluginAndroidBase = import(".PluginAndroidBase")
local AmapPluginAndroid = class("AmapPluginAndroid",PluginAndroidBase)


local AMapLocationMode = 
{
	Battery_Saving = 0,
	Device_Sensors = 0,
	Hight_Accuracy = 0,
}


local AmapGpsStatus = 
{
	GPS_STATUS_OK = 0, -- GPS状态正常
	GPS_STATUS_NOGPSPROVIDER = 1, --手机中没有GPS Provider，无法进行GPS定位
	GPS_STATUS_OFF = 2,--GPS关闭，建议开启GPS，提高定位质量
	GPS_STATUS_MODE_SAVING = 3, -- 选择的定位模式中不包含GPS定位，建议选择包含GPS定位的模式，提高定位质量
	GPS_STATUS_NOGPSPERMISSION = 4,--没有GPS定位权限，建议开启gps定位权限
}

function AmapPluginAndroid:ctor()
	AmapPluginAndroid.super.ctor(self,"AmapPluginAndroid","org.ode.cocoslib.amap.AmapBridge")
end


function AmapPluginAndroid:init()
	if not self.isInit_ then
		self.isInit_ = true
		self.onAmapNotifyHandler_ = handler(self,self.onAmapNotify)
		self:call_("setAmapNotify", {self.onAmapNotifyHandler_}, "(I)V")
		self:initLocation()
	end
end

function AmapPluginAndroid:getLocationInfo()
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

--longitude 经度
--latitude  纬度
function AmapPluginAndroid:onAmapNotify(jsonStr)
	print(jsonStr,"onAmapNotify")
	local jsonObj = json.decode(jsonStr)
	if not jsonObj then
		return 
	end

	local atype = jsonObj.atype
	if atype == "location" then
		self:handleLocation(jsonObj)

	end

end

-- succ: "{"atype":"location","etype":"ok","longitude":1.00001,"latitude":1.00001,"gpsStatus":0}"
-- succ: "{"atype":"location","etype":"fail","errCode":0,"errStr":"xxxx","errDetail":"","gpsStatus":2}"
function AmapPluginAndroid:handleLocation(jsonObj)
	local etype = jsonObj.etype

	if etype =="ok" then
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


function AmapPluginAndroid:calculateLineDistance(slatitude,slongitude,elatitude,elongitude)
	local ok, ret = self:call_("calculateLineDistance", {slatitude,slongitude,elatitude,elongitude}, "(FFFF)I")
	if ok then
		return ret
	end
	return 0
end

--构建定位
function AmapPluginAndroid:initLocation()
	self:call_("initLocation", {appconfig.amapAppKey}, "(Ljava/lang/String;)V")
end

--销毁定位
function AmapPluginAndroid:destroyLocation()
	self:call_("destroyLocation", {}, "()V")
end

function AmapPluginAndroid:startLocation(callback)
	self.locationCallback_ = callback
	self:call_("startLocation", {}, "()V")
end


function AmapPluginAndroid:stopLocation(doClean)
	self:call_("stopLocation", {}, "()V")
	if doClean then
		self.locationCallback_  = nil
	end
end

function AmapPluginAndroid:cancelCallback( ... )
	self.locationCallback_  = nil
end


return AmapPluginAndroid