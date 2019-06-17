local GameHttp = import("..net.GameHttp")

local LoadGoodsControl = class("LoadGoodsControl")


function LoadGoodsControl:ctor()
    self.logger = core.Logger.new("LoadGoodsControl")
    self.schedulerPool_ = core.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LoadGoodsControl:checkUpdate( ... )
	self.__getGoodsVersionReqId=GameHttp.getGoodsVersion(function(data)
    self.__getGoodsVersionReqId = nil
	end,function(errData)
    self.__getGoodsVersionReqId = nil
	end)
end

function LoadGoodsControl:loadConfig(callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadGoodsConfigCallback_ = callback
    self:loadConfig_()
end


function LoadGoodsControl:loadConfig_()
    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            self.__getGoodsListReqId=GameHttp.getGoodsList(function(data)
                self.__getGoodsListReqId = nil

            	self.isConfigLoaded_ = true
                self.isConfigLoading_ = false

                self.goodsData_ = data
                if self.loadGoodsConfigCallback_ then
                    self.loadGoodsConfigCallback_(true, self.goodsData_)
                end

            end,function(errData)
                self.__getGoodsListReqId = nil
                
            	self.isConfigLoaded_ = false
                self.isConfigLoading_ = false
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        loadConfigFunc()
                    end, 2)
                else
                   if self.loadGoodsConfigCallback_ then
                        self.loadGoodsConfigCallback_(false)
                    end
                end

            end)
        elseif self.isConfigLoaded_ then
             if self.loadGoodsConfigCallback_ then
                self.loadGoodsConfigCallback_(true, self.goodsData_)
            end
        end
    end

    loadConfigFunc()

end



function LoadGoodsControl:cancel()
    if self.loadGoodsConfigCallback_ then
        self.loadGoodsConfigCallback_ = nil
    end
end

function LoadGoodsControl:isConfigLoaded()
    return self.isConfigLoaded_
end

function LoadGoodsControl:isConfigLoading()
    return self.isConfigLoading_
end


function LoadGoodsControl:preDealGamesData(data)
	-- body

end



function LoadGoodsControl:getGoodsData()
    return self.goodsData_
end


return LoadGoodsControl