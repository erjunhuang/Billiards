require("lfs")

local ImageLoader = class("ImageLoader")
local log = core.Logger.new("ImageLoader"):enabled(true)

ImageLoader.CACHE_TYPE_NONE = "CACHE_TYPE_NONE"
ImageLoader.DEFAULT_TMP_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "tmpimg" .. device.directorySeparator

function ImageLoader:ctor()
    self.loadId_ = 0
    self.cacheConfig_ = {}
    self.loadingJobs_ = {}
    core.rmdir(ImageLoader.DEFAULT_TMP_DIR)
    core.mkdir(ImageLoader.DEFAULT_TMP_DIR)
    self:registerCacheType(ImageLoader.CACHE_TYPE_NONE, {path=ImageLoader.DEFAULT_TMP_DIR})
end

function ImageLoader:registerCacheType(cacheType, cacheConfig)
    self.cacheConfig_[cacheType] =  cacheConfig
    if cacheConfig.path then
        core.mkdir(cacheConfig.path)
    else
        cacheConfig.path = ImageLoader.DEFAULT_TMP_DIR
    end
end

function ImageLoader:clearCache()
    for k, v in pairs(self.cacheConfig_) do
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
    self:addJob_(loadId, url, self.cacheConfig_[cacheType], callback)
end

function ImageLoader:loadImage(url, callback, cacheType)
    local loadId = self:nextLoaderId()
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    local config = self.cacheConfig_[cacheType]
    log:debugf("loadImage(%s, %s, %s)", loadId, url, cacheType)
    self:addJob_(loadId, url, config, callback)
end

function ImageLoader:cancelJobByUrl_(url)
    local loadingJob = self.loadingJobs_[url]
    if loadingJob then
        loadingJob.callbacks = {}
    end
end

function ImageLoader:cancelJobByLoaderId(loaderId)
    if loaderId then
        for url, loadingJob in pairs(self.loadingJobs_) do
            loadingJob.callbacks[loaderId] = nil
        end
    end
end

function ImageLoader:addJob_(loadId, url, config, callback)
    if (not loadId) or (not url) or (not config) then
        log:debugf("args is nil (%s, %s, %s)", loadId, url, config)
        return
    end
    
    local hash = nb.utils_.md5(url)
    local path = config.path .. hash

    local t_tex = nb.Director:getInstance():getTextureCache():getTextureForKey(path)
    if t_tex then
        log:debugf("t_tex exists ( %s, %s)", url, path)
        if callback ~= nil then
            callback(t_tex ~= nil, nb.Sprite:createWithTexture(t_tex),path)
            return
        end

    end


    if io.exists(path) then
        log:debugf("file exists (%s, %s, %s)", loadId, url, path)
        -- lfs.touch(path)
        local tex = nb.Director:getInstance():getTextureCache():addImage(path)
        if not tex then
            os.remove(path)
        elseif callback ~= nil then
            callback(tex ~= nil, nb.Sprite:createWithTexture(tex),path)
        end
    else
        local loadingJob = self.loadingJobs_[url]
        if loadingJob then
            log:debugf("job is loading -> %s", url)
            loadingJob.callbacks[loadId] = callback
        else
            log:debugf("start job -> %s", url)
            loadingJob = {}
            loadingJob.callbacks = {}
            loadingJob.callbacks[loadId] = callback
            self.loadingJobs_[url] = loadingJob

            local request = nb.XMLHttpRequest:new()
            
            local function onReadyStateChanged()
                local readyState = request.readyState
                if readyState == 4 then -- DONE

                    --request.status >= 200 and request.status < 207

                    local code = request.status;
                    local statusText = request.statusText
                    local response = request.response
                    local responseText = request.responseText

                    if code ~= 200 then
                        -- 请求结束，但没有返回 200 响应代码
                        log:debugf("[%d] code=%s", loadId, code)
                        local values = table.values(loadingJob.callbacks)
                        for i, v in ipairs(values) do
                            if v ~= nil then
                                v(false, code)
                            end
                        end
                        self.loadingJobs_[url] = nil
                        return
                    end


                    -- 请求成功，显示服务端返回的内容
                    local content = responseText
                    log:debugf("loaded from network, save to file -> %s", path)
                    io.writefile(path, content, "w+b")

                    if core.isFileExist(path) then
                        lfs.touch(path)
                        local tex = nb.Director:getInstance():getTextureCache():addImage(path)
                        if not tex then
                            os.remove(path)
                        end

                        for k, v in pairs(loadingJob.callbacks) do
                            log:debugf("call callback -> " .. k)
                            if v then
                                v(tex ~= nil, nb.Sprite:createWithTexture(tex),path)
                            end
                        end
                        if config.onCacheChanged then
                            config.onCacheChanged(config.path)
                        end
                    else
                        log:debug("file not exists -> " .. path)
                    end
                    self.loadingJobs_[url] = nil
                    request:unregisterScriptHandler()
                else
                    local code = request.status;
                    local statusText = request.statusText
                    local response = request.response
                    local responseText = request.responseText

                    local values = table.values(loadingJob.callbacks)
                    for i, v in ipairs(values) do
                        if v ~= nil then
                            v(false, code)
                        end
                    end
                    self.loadingJobs_[url] = nil
                        
                end
            end

            
            request.responseType = nb.XMLHTTPREQUEST_RESPONSE_STRING
            request:open("GET", url)
            request:registerScriptHandler(onReadyStateChanged)
            loadingJob.request = request
            request:send()
        end
    end
end

return ImageLoader