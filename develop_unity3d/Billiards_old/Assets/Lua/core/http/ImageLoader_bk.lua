
require("lfs")

local ImageLoader = class("ImageLoader")
local log = core.Logger.new("ImageLoader"):enabled(true)

ImageLoader.CACHE_TYPE_NONE = "CACHE_TYPE_NONE"
ImageLoader.DEFAULT_TMP_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "tmpimg" .. device.directorySeparator

function ImageLoader:ctor()
    self.loadId_ = 0
    self.__cacheConfig = {}
    self.__loadingJobs = {}
    core.rmdir(ImageLoader.DEFAULT_TMP_DIR)
    core.mkdir(ImageLoader.DEFAULT_TMP_DIR)
    self:registerCacheType(ImageLoader.CACHE_TYPE_NONE, {path=ImageLoader.DEFAULT_TMP_DIR})
end

function ImageLoader:registerCacheType(cacheType, cacheConfig)
    self.__cacheConfig[cacheType] =  cacheConfig
    if cacheConfig.path then
        core.mkdir(cacheConfig.path)
    else
        cacheConfig.path = ImageLoader.DEFAULT_TMP_DIR
    end
end

function ImageLoader:clearCache()
    for k, v in pairs(self.__cacheConfig) do
        core.rmdir(v.path)
    end
end

function ImageLoader:nextLoaderId()
    self.loadId_ = self.loadId_ + 1
    return self.loadId_
end

function ImageLoader:loadAndCacheImage(loadId, url, callback, cacheType)
    log:debugf("loadAndCacheImage(%s, %s, %s)", loadId, url, cacheType)
    self:cancelJobByLoaderId(loadId)
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    self:addJob_(loadId, url, self.__cacheConfig[cacheType], callback)
end

function ImageLoader:loadImage(url, callback, cacheType)
    local loadId = self:nextLoaderId()
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    local config = self.__cacheConfig[cacheType]
    log:debugf("loadImage(%s, %s, %s)", loadId, url, cacheType)
    self:addJob_(loadId, url, config, callback)
end

function ImageLoader:cancelJobByUrl_(url)
    local loadingJob = self.__loadingJobs[url]
    if loadingJob then
        loadingJob.callbacks = {}
    end
end

function ImageLoader:cancelJobByLoaderId(loaderId)
    if loaderId then
        for url, loadingJob in pairs(self.__loadingJobs) do
            loadingJob.callbacks[loaderId] = nil
        end
    end
end

function ImageLoader:addJob_(loadId, url, config, callback)
    if (not loadId) or (not url) or (not config) then
        log:debugf("args is nil (%s, %s, %s)", loadId, url, config)
        return
    end
    
    local hash = crypto.md5(url)
    local path = config.path .. hash
    if io.exists(path) then
        log:debugf("file exists (%s, %s, %s)", loadId, url, path)
        lfs.touch(path)
        local tex = nb.Director:getInstance():getTextureCache():addImage(path)
        if not tex then
            os.remove(path)
        elseif callback ~= nil then
            callback(tex ~= nil, nb.Sprite:createWithTexture(tex))
        end
    else
        -- if not url then
        --     --todo
        --     return
        -- end
        local loadingJob = self.__loadingJobs[url]
        if loadingJob then
            log:debugf("job is loading -> %s", url)
            loadingJob.callbacks[loadId] = callback
        else
            log:debugf("start job -> %s", url)
            loadingJob = {}
            loadingJob.callbacks = {}
            loadingJob.callbacks[loadId] = callback
            self.__loadingJobs[url] = loadingJob

            local function onRequestFinished(evt)
                if evt.name ~= "progress" then
                    local ok = (evt.name == "completed")
                    local request = evt.request

                    if not ok then
                        -- 请求失败，显示错误代码和错误消息
                        log:debugf("[%d] errCode=%s errmsg=%s", loadId, request:getErrorCode(), request:getErrorMessage())
                        local values = table.values(loadingJob.callbacks)
                        for i, v in ipairs(values) do
                            if v ~= nil then
                                v(false, request:getErrorCode() .. " " .. request:getErrorMessage())
                            end
                        end
                        self.__loadingJobs[url] = nil
                        return
                    end

                    local code = request:getResponseStatusCode()
                    if code ~= 200 then
                        -- 请求结束，但没有返回 200 响应代码
                        log:debugf("[%d] code=%s", loadId, code)
                        local values = table.values(loadingJob.callbacks)
                        for i, v in ipairs(values) do
                            if v ~= nil then
                                v(false, code)
                            end
                        end
                        self.__loadingJobs[url] = nil
                        return
                    end

                    -- 请求成功，显示服务端返回的内容
                    local content = request:getResponseData()
                    log:debugf("loaded from network, save to file -> %s", path)
                    io.writefile(path, content, "w+b")

                    if core.isFileExist(path) then
                        local tex = nil
                        for k, v in pairs(loadingJob.callbacks) do
                            log:debugf("call callback -> " .. k)
                            if v then
                                if not tex then
                                    lfs.touch(path)
                                    tex = nb.Director:getInstance():getTextureCache():addImage(path)
                                end
                                if not tex then
                                    os.remove(path)
                                else
                                    v(true, nb.Sprite:createWithTexture(tex))
                                end
                            end
                        end
                        if config.onCacheChanged then
                            config.onCacheChanged(config.path)
                        end
                    else
                        log:debug("file not exists -> " .. path)
                    end
                    self.__loadingJobs[url] = nil
                end
            end
            -- 创建一个请求，并以 指定method发送数据到服务端HttpService.cloneDefaultParams初始化
            local request = network.createHTTPRequest(onRequestFinished, url, "GET")
            loadingJob.request = request
            request:start()
        end
    end
end

return ImageLoader