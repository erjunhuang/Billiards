--[[
core.HttpService.POST({mod="friend",act="list"},
    function(data) 
    end,
    function(errCode[, response])
    end)
    TODO 取消请求功能
]]


-- 
local HttpService = {}
local logger = core.Logger.new("HttpService")
HttpService.defaultURL = ""
HttpService.defaultParams = {}

HttpService.requestId_ = 1
HttpService.requests = {}
HttpService.defaultTimeout = 10000


HttpService.timeoutReqs = {}

HttpService.defaultExtra = 
{
	header = 
	{
		["Content-Type"] = "application/x-www-form-urlencoded"
	},
	timeout = 10000,
	responseType = nb.XMLHTTPREQUEST_RESPONSE_STRING
}




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
        local tparams = {}
        table.merge(tparams,HttpService.defaultParams)
        table.merge(tparams,params)
        return tparams
    else
        return clone(HttpService.defaultParams)
    end
end

local except = {"header"}
local setXhrExtra = function(xhr,extra)
    if(xhr and extra)then
        if(extra.header) then
            for key,v in pairs(extra.header) do
                xhr:SetRequestHeader(key,extra.header[key])
            end
        end
        --other
        -- for k,v in pairs(extra) do
        --     if not except[k] then
        --         xhr[k] = extra[k]
        --     end

        -- end
        xhr.timeout  = (extra.timeout or HttpService.defaultTimeout);
        
    end
end



local function request_(method, url, addDefaultParams, params, resultCallback, errorCallback,extra)
    -- method: Delete,Get,Head,Post,Put 

    local requestId = HttpService.requestId_
    -- logger:debugf("[%d] Method=%s URL=%s defaultParam=%s params=%s", requestId, method, url, json.encode(addDefaultParams), json.encode(params))

    local cs_co = cs_coroutine.start(function(trequestId,tmethod, turl, taddDefaultParams, tparams, tresultCallback, terrorCallback,textra)
        print('coroutine a started000',turl)
        print('coroutine a started',trequestId,tmethod, turl, taddDefaultParams, tparams, tresultCallback, terrorCallback,textra)
        tparams = tparams or {}
        local allParams
        if (taddDefaultParams) then
            allParams = HttpService.cloneDefaultParams(tparams);
        else
            allParams = tparams;
        end
        local uhr
        if tmethod == "POST" then
            local paramStr = ""
            local _WWWForm = WWWForm()
            for key,v in pairs(allParams) do
                if(paramStr ~="")then
                    paramStr = paramStr .. "&";
                end

                 paramStr = paramStr .. (tostring(key) .. "=" .. (tostring(allParams[key])));
                 _WWWForm:AddField(key,v)
            end

            local modAndAct = ""
            if params.mod and params.act then
                modAndAct = string.format("[%s_%s]", params.mod, params.act)
            end

            if params.method then
                modAndAct = string.format("[%s]", params.method)
            end

            -- logger:debugf("[%s][%s][%s]%s %s", requestId, method, url, modAndAct, json.encode(allParams))

            uhr = UnityWebRequest.Post(turl,_WWWForm)

        elseif tmethod == "GET" then
            uhr = UnityWebRequest.Get(turl)
        elseif tmethod == "DELETE" then
            uhr = UnityWebRequest.Delete(turl)
        elseif tmethod == "PUT" then
            uhr = UnityWebRequest.Put(turl)
        end


 

        print("setXhrExtra000",uhr,turl)
        setXhrExtra(uhr,textra or HttpService.defaultExtra)
        coroutine.yield(uhr:SendWebRequest())

        print("setXhrExtra1111",uhr,uhr.isNetworkError,uhr.isHttpError)
        if uhr.isNetworkError or uhr.isHttpError then
            if terrorCallback ~= nil then
                terrorCallback(uhr.responseCode, uhr.error)
            end
            return
        end

        local code = uhr.responseCode

        print("responseCode",code)

        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            logger:debugf("[%d] code=%s", trequestId, code)
            if terrorCallback ~= nil then
                terrorCallback(code)
            end
            return
        end

        --downloadProgress
        local response = uhr.downloadHandler.text

        print("response:",uhr,turl,response)

        -- if string.len(response) <= 10000 then
            logger:debugf("[%d] response=%s", trequestId, response)
        -- end
        -- logger:debugf("[%d] response=%s", requestId, response)
        if tresultCallback ~= nil then
            tresultCallback(response)
        end

    end,requestId,method, url, addDefaultParams, params, resultCallback, errorCallback,extra)

    return requestId
end

--[[
    POST到默认的URL，并附加默认参数
]]
function HttpService.POST(params, resultCallback, errorCallback,extra)
    return request_("POST", HttpService.defaultURL, true, params, resultCallback, errorCallback,extra)
end

--[[
    GET到默认的URL，并附加默认参数
]]
function HttpService.GET(params, resultCallback, errorCallback,extra)
    return request_("GET", HttpService.defaultURL, true, params, resultCallback, errorCallback,extra)
end

--[[
    POST到指定的URL，该调用不附加默认参数，如需默认参数,params应该使用HttpService.cloneDefaultParams初始化
]]
function HttpService.POST_URL(url, params, resultCallback, errorCallback,extra)
    return request_("POST", url, true, params, resultCallback, errorCallback,extra)
end

--[[
    GET到指定的URL，该调用不附加默认参数，如需默认参数,params应该使用HttpService.cloneDefaultParams初始化
]]
function HttpService.GET_URL(url, params, resultCallback, errorCallback,extra)
    return request_("GET", url, false, params, resultCallback, errorCallback,extra)
end

-- {
--     fileFieldName="filepath",
--     filePath=device.writablePath.."screen.jpg",
--     contentType="Image/jpeg",
--     extra={
--         act"=upload,
--         submit=upload,
--     }
-- }
function HttpService.UPLOAD_FILE(url, params,resultCallback, errorCallback)
    assert(params or params.fileFieldName or params.filePath, "Need file params!")
    local BOUNDARY = "----------------------------78631b43218d";
    local NEWLINE = "\r\n";
    local function postFormFile(key, filePath)
        local filename = core.getFileName(filePath)
        local file_data = nb.FileUtils:getInstance():getDataFromFile(filePath)
        local sb =""
        sb =sb .. ("--");
        sb =sb .. (BOUNDARY);
        sb =sb .. (NEWLINE);
        sb =sb .. ("Content-Disposition: form-data; ");
        sb =sb .. ("name=\"");
        sb =sb .. (key);
        sb =sb .. ("\"; ");
        sb =sb .. ("filename=\"");
        sb =sb .. (filename);
        sb =sb .. ("\"");
        sb =sb .. (NEWLINE);
        sb =sb .. ("Content-Type: application/octet-stream");
        sb =sb .. (NEWLINE);
        sb =sb .. (NEWLINE);
        sb =sb .. file_data;
        sb =sb .. (NEWLINE);
        return sb;
    end

    local function postFormContent(key,val)
        local sb =""
        sb =sb .. ("--");
        sb =sb .. (BOUNDARY);
        sb =sb .. (NEWLINE);
        sb =sb .. ("Content-Disposition: form-data; name=\"");
        sb =sb .. (key);
        sb =sb .. ("\"");
        sb =sb .. (NEWLINE);
        sb =sb .. (NEWLINE);
        sb =sb .. (val);
        sb =sb .. (NEWLINE);
        return sb
    end

    local function postFormEnd( ... )
        local sb = ""
        sb =sb .. ("--");
        sb =sb .. (BOUNDARY);
        sb =sb .. ("--");
        sb =sb .. (NEWLINE);
        return sb
    end

    local contentType = (params.contentType or "application/octet-stream")
    local boundaryData = ""
    if params.extra then
        contentType = "multipart/form-data"
        for k,v in pairs(params.extra) do
            boundaryData = boundaryData .. postFormContent(k,v) 
        end
    end

    boundaryData = boundaryData .. postFormFile(params.fileFieldName,params.filePath)
    boundaryData = boundaryData .. postFormEnd()

    local contentType = contentType .. ("; boundary=" .. BOUNDARY);
    local header = {["Content-Type"] = contentType}
    
    -- print("boundaryData",boundaryData)
    return request_("POST", url, false, {}, resultCallback, errorCallback,{header = header,rawData = boundaryData})
end

--[[
    取消指定id的请求
]]
function HttpService.CANCEL(requestId)
    if requestId and HttpService.timeoutReqs[requestId] then
        scheduler.unscheduleGlobal(HttpService.timeoutReqs[requestId])
        HttpService.timeoutReqs[requestId] = nil
    end

    if requestId and HttpService.requests[requestId] then
        HttpService.requests[requestId]:abort()
        HttpService.requests[requestId] = nil
    end
end

return HttpService