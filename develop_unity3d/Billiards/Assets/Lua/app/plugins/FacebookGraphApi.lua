
local logger = core.Logger.new("FacebookGraphApi")
local FacebookGraphApi = {}
local accessToken = nil
local tokenExptime = nil

function FacebookGraphApi.setAccessToken(token)
    accessToken = token
end

function FacebookGraphApi.setTokenExptime(exptime)
    tokenExptime = exptime
end

function FacebookGraphApi.graphRequest(method, params, resultCallback, errorCallback)
    if accessToken == nil then
        logger:error("accessToken is nil!!!")
        errorCallback()
        return 
    end

    local allParams = {
        access_token = accessToken,
        method = "get",
        format = "json",
        pretty = 0       
    }

    table.merge(allParams, params)
    local paramsStr = ""
    for k,v in pairs(allParams) do
        paramsStr = paramsStr .. k .. "=" .. v .. "&"
    end
    paramsStr = paramsStr .. "suppress_http_code=1"
    core.HttpService.GET_URL("https://graph.facebook.com/v2.3"..method.."?"..paramsStr, {}, resultCallback, errorCallback)
end

function FacebookGraphApi.getId(resultCallback, errorCallback)
    FacebookGraphApi.graphRequest("/me", {fields = "id"}, resultCallback, errorCallback)
end

function FacebookGraphApi.exportMethods(target)
    for k, v in pairs(FacebookGraphApi) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

return FacebookGraphApi