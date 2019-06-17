
local HttpService = {}
local logger = core.Logger.new("HttpService")
HttpService.defaultURL = ""
HttpService.defaultParams = {}

HttpService.requestId_ = 1
HttpService.requests = {}

function HttpService.getDefaultURL()
    return HttpService.defaultURL
end

function HttpService.setDefaultURL(url)
    HttpService.defaultURL = url
end

function HttpService.clearDefaultParameters()
    HttpService.defaultParams = {}
end

function HttpService.setDefaultParameter(key, value)
    HttpService.defaultParams[key] = value;
end

function HttpService.cloneDefaultParams(params)
    if params ~= nil then
        table.merge(params, HttpService.defaultParams)
        return params
    else
        return clone(HttpService.defaultParams)
    end
end

local function request_(method, url, addDefaultParams, params, resultCallback, errorCallback)
    local requestId = HttpService.requestId_
    logger:debugf("[%d] Method=%s URL=%s defaultParam=%s params=%s", requestId, method, url, json.encode(addDefaultParams), json.encode(params))
    --代理回调
    local function onRequestFinished(evt)
        if evt.name ~= "progress" and evt.name ~= "cancelled" then
            local ok = (evt.name == "completed")
            local request = evt.request
            HttpService.requests[requestId] = nil

            if not ok then
                -- 请求失败，显示错误代码和错误消息
                logger:debugf("[%d] errCode=%s errmsg=%s", requestId, request:getErrorCode(), request:getErrorMessage())
                if errorCallback ~= nil then
                    errorCallback(request:getErrorCode(), request:getErrorMessage())
                end
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                logger:debugf("[%d] code=%s", requestId, code)
                if errorCallback ~= nil then
                    errorCallback(code)
                end
                return
            end

            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            -- todo:better,string太长了打日志报错
            if string.len(response) <= 10000 then
                logger:debugf("[%d] response=%s", requestId, response)
            end
            -- logger:debugf("[%d] response=%s", requestId, response)
            if resultCallback ~= nil then
                resultCallback(response)
            end
        end
    end
    -- 创建一个请求，并以 指定method发送数据到服务端HttpService.cloneDefaultParams初始化
    local request = network.createHTTPRequest(onRequestFinished, url, method)
    HttpService.requests[requestId] = request
    HttpService.requestId_ = HttpService.requestId_ + 1
    local allParams
    if addDefaultParams then
        allParams = HttpService.cloneDefaultParams()
        dump(allParams,"allParams===")
         dump(params,"params===")
        table.merge(allParams, params)
        dump(allParams,"merge-params===")
    else
        allParams = params
    end
    
    -- 加入参数
    for k, v in pairs(allParams) do
        if method == "GET" then
            request:addGETValue(tostring(k), tostring(v))
        else
            request:addPOSTValue(tostring(k), tostring(v))
        end
    end
    local modAndAct = ""
    if params.mod and params.act then
        modAndAct = string.format("[%s_%s]", params.mod, params.act)
    end

    if params.method then
        modAndAct = string.format("[%s]", params.method)
    end

    logger:debugf("[%s][%s][%s]%s %s", requestId, method, url, modAndAct, json.encode(allParams))
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()

    return requestId
end

--[[
    POST到默认的URL，并附加默认参数
]]
function HttpService.POST(params, resultCallback, errorCallback)
    return request_("POST", HttpService.defaultURL, true, params, resultCallback, errorCallback)
end

--[[
    GET到默认的URL，并附加默认参数
]]
function HttpService.GET(params, resultCallback, errorCallback)
    return request_("GET", HttpService.defaultURL, true, params, resultCallback, errorCallback)
end

--[[
    POST到指定的URL，该调用不附加默认参数，如需默认参数,params应该使用HttpService.cloneDefaultParams初始化
]]
function HttpService.POST_URL(url, params, resultCallback, errorCallback)
    print("POST_URL======",url, params, resultCallback, errorCallback)
    return request_("POST", url, false, params, resultCallback, errorCallback)
end

--[[
    GET到指定的URL，该调用不附加默认参数，如需默认参数,params应该使用HttpService.cloneDefaultParams初始化
]]
function HttpService.GET_URL(url, params, resultCallback, errorCallback)
    return request_("GET", url, false, params, resultCallback, errorCallback)
end

--[[
    取消指定id的请求
]]
function HttpService.CANCEL(requestId)
    if requestId and HttpService.requests[requestId] then
        HttpService.requests[requestId]:cancel()
        HttpService.requests[requestId] = nil
    end
end

return HttpService