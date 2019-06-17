local IsoManager = class("IsoManager")

local IsoPath = "gamehall.src.iso"

function IsoManager:ctor()
	
end


function IsoManager:setIsoPath(isoPath)
	IsoPath = isoPath or IsoPath
end


function IsoManager:getIso(name)
	local fileName  = IsoPath .. "." .. name
	local isSuccess ,result = pcall(require,fileName);
    if not isSuccess then
        print("getIso is fail , fileName:",fileName)
        return nil
    end
    return result
end


function IsoManager:getIsoSingleInstance(name,...)
	local fileName  = IsoPath .. "." .. name
	local isSuccess ,result = pcall(require,fileName);
    if not isSuccess then
        print("getIsoSingleInstance is fail , fileName:",fileName)
        return nil
    end
    
    if result.getInstance and type(result.getInstance) == "function" then
        return result.getInstance(...)
    else
        return nil
    end
end


function IsoManager:getIsoInstance(name,...)
    local fileName  = IsoPath .. "." .. name
    local isSuccess ,result = pcall(require,fileName);
    if not isSuccess then
        print("getIsoInstance is fail , fileName:",fileName)
        return nil
    end
    
    return result.new(...)
end






return IsoManager