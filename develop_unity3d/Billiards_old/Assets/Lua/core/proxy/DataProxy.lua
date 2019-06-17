
--[[
    全局数据代理
    注意：设置数据时若启用了proxy，getData获取到的相应dataTable是一个空的代理表，无法遍历。
    真实数据位于getmetatable(dataTable)的__index键。
]]

local DataProxy = class("DataProxy")

function DataProxy:ctor()
    self.__dataPool        = {}
    self.__keyHandler      = {}
    self.__propertyHandler = {}
    self.__nextHandleIndex = 0
    self.__withProxy = false
end

--  设置一个data，如果withProxy为true，则跟踪data的更新操作
function DataProxy:setData(key, data, withProxy)
    local localPairs      = pairs;
    local dataPool        = self.__dataPool
    local keyHandler      = self.__keyHandler
    local propertyHandler = self.__propertyHandler

    self.__withProxy = withProxy
    -- 设置data
    if withProxy then
        if type(data) == "table" then
            local proxyTable = {}
            local metaTable  = {
                __index    = data, 
                __newindex = function (_, property, value)
                    -- 设置某个属性的value
                    data[property] = value;

                    -- 执行相应的处理函数
                    if propertyHandler[key] and propertyHandler[key][property] then
                        for _, handler in localPairs(propertyHandler[key][property]) do
                            handler(value)
                        end
                    end
                end
            }
            setmetatable(proxyTable, metaTable)
            dataPool[key] = proxyTable

            -- 执行相应的处理函数
            if propertyHandler[key] then
                for property, handlerTable in localPairs(propertyHandler[key]) do
                    for _, handler in localPairs(handlerTable) do
                        handler(data[property])
                    end
                end
            end
        else
            if DEBUG > 1 then
                printInfo("data must be a table with proxy")
            end
            dataPool[key] = data
        end
    else
        dataPool[key] = data
    end

    -- 执行相应的处理函数
    if keyHandler[key] then
        for _, handler in localPairs(keyHandler[key]) do
            handler(data);
        end
    end

    return dataPool[key]
end

function DataProxy:cacheData(key)
    local cacheData = {}
    local data = self:getData(key)
    if data then
        if not self.__withProxy then            
            cacheData.data = data
            cacheData._withProxy_ = false
            core.cacheTable(key, cacheData)            
        else
            cacheData.data = getmetatable(data).__index
            cacheData._withProxy_ = true
            core.cacheTable(key, cacheData)
        end
    end
end

-- 获取一个data
function DataProxy:getData(key)
    if self.__dataPool[key] ~= nil then
        return self.__dataPool[key]
    else
        local cacheData = core.cacheTable(key)
        if type(cacheData) == "table" then
            local withProxy = cacheData._withProxy_
            cacheData._withProxy_ = nil
            self:setData(key, cacheData.data, withProxy)
            return cacheData.data
        else
            return nil
        end        
    end    
end

-- 判断是否存在一个data
function DataProxy:hasData(key)
    return self.__dataPool[key] ~= nil or false
end

-- 为一个data设置观察处理函数
function DataProxy:addDataObserver(key, handler)
    local keyHandler = self.__keyHandler

    if not keyHandler[key] then
        keyHandler[key] = {}
    end
    self.__nextHandleIndex = self.__nextHandleIndex + 1
    local handle = tostring(self.__nextHandleIndex)
    keyHandler[key][handle] = handler

    if self.__dataPool[key] ~= nil then
        handler(self.__dataPool[key])
    end

    return handle
end

-- 移除特定handle的观察处理函数
function DataProxy:removeDataObserver(key, handleToRemove)
    local keyHandler = self.__keyHandler

    if (keyHandler[key]) then
        for handle, _ in pairs(keyHandler[key]) do
            if handle == handleToRemove then
                keyHandler[key][handleToRemove] = nil
                return true
            end
        end
    end

    return false
end

-- 为一个data的property设置观察处理函数
function DataProxy:addPropertyObserver(key, property, handler)
    local propertyHandler = self.__propertyHandler

    if not propertyHandler[key] then
        propertyHandler[key] = {}
    end

    if not propertyHandler[key][property] then
        propertyHandler[key][property] = {}
    end

    self.__nextHandleIndex = self.__nextHandleIndex + 1
    local handle = tostring(self.__nextHandleIndex)
    propertyHandler[key][property][handle] = handler

    if self.__dataPool[key] ~= nil then
        handler(self.__dataPool[key][property])
    end

    return handle
end

-- 移除特定handle的观察处理函数
function DataProxy:removePropertyObserver(key, property, handleToRemove)
    local propertyHandler = self.__propertyHandler

    if propertyHandler[key] and propertyHandler[key][property] then
        for handle, _ in pairs(propertyHandler[key][property]) do
            if handle == handleToRemove then
                propertyHandler[key][property][handleToRemove] = nil
                return true
            end
        end
    end

    return false
end

-- 通知property改变
function DataProxy:notifyPropertyChange(key, property)
    local propertyHandler = self.__propertyHandler
    if propertyHandler[key] and propertyHandler[key][property] and self.__dataPool[key] then
        for _, handler in pairs(propertyHandler[key][property]) do
            handler(self.__dataPool[key][property])
        end
    end
end

-- 清理一个data，保留handler
function DataProxy:clearData(key)
    if self:hasData(key) then
        local localPairs      = pairs;
        local keyHandler      = self.__keyHandler
        local propertyHandler = self.__propertyHandler

        -- data置为nil
        self.__dataPool[key] = nil

        -- 执行相应的处理函数
        if keyHandler[key] then
            for _, handler in localPairs(keyHandler[key]) do
                handler(nil)
            end
        end

        if propertyHandler[key] then
            for _, handlerTable in localPairs(propertyHandler[key]) do
                for _, handler in localPairs(handlerTable) do
                    handler(nil)
                end
            end
        end

        return true
    else
        return false
    end
end

return DataProxy.new()