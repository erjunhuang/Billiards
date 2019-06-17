local HttpRequest = {}

local logger = core.Logger.new("HttpRequest")
local http = core.HttpService

function HttpRequest.shJoins(data,isSig)
    local str = "[";
    local key = {};
    local sig = 0;

    if data == nil then
        str = str .. "]";
        return str;
    end

    for i,v in pairs(data) do
        table.insert(key,i);
    end
    table.sort(key);
    for k=1,table.maxn(key) do
        sig = isSig;
        local b = key[k];
        if sig ~= 1 and string.sub(b,1,4) == "sig_" then
            sig = 1;
        end
        local obj = data[b];
        local oType = type(obj);
        local s = "";
        if sig == 1 and oType ~= "table" then
            str = string.format("%s&%s=%s",str.."",b,obj);
        end
        if oType == "table" then
            str = string.format("%s%s=%s",str.."",b,HttpRequest.shJoins(obj,sig));
        end
    end
    str = str .. "]";
    return str;
end

-- 多维数组转一维数组
function HttpRequest.toOneDimensionalTable(table, prefix, root)
    if prefix == nil then
        prefix = ""
        root = table
    end
    for k,v in pairs(clone(table)) do               
        local rootkey = k
        if prefix ~= "" then
            rootkey = prefix.."."..k
        end

        if type(v) == "table" then
            if #v == 0 then --是kv数组
                HttpRequest.toOneDimensionalTable(v, rootkey, root)
                if prefix == "" then
                    root[k] = nil
                end
            end
        else
            if prefix ~= "" then
                root[rootkey] = v
            end
        end
    end  

end

-- 类型批量转换
function typeFilter(table, types)
    for func,keys in pairs(types) do
        for _,key in ipairs(keys) do
            if table[key] ~= nil then
                table[key] = func(table[key])
            end
        end
    end
end

function HttpRequest.init(defaultParam)
    http.clearDefaultParameters()
    http.setDefaultParameter("appid",appconfig.appid)
    -- http.setDefaultParameter("version", require("app.manager.GameManager").getInstance():getGameVersion(GameType.HALL))
    http.setDefaultParameter("sesskey", "")
    http.setDefaultParameter("gameid", 0)
    http.setDefaultParameter("lmode", 3)
    http.setDefaultParameter("demo", appconfig.phpdemo)
    http.setDefaultParameter("isnew", appconfig.isnew)
end


function HttpRequest.setLoginType(lmode)
    http.setDefaultParameter("lmode", lmode)
    return lmode
end

function HttpRequest.setSessionKey(key)
    http.setDefaultParameter("sesskey", key)  
end

function HttpRequest.getDefaultURL()
    return http.getDefaultURL()
end

function HttpRequest.setDefaultURL(url)
    print("HttpRequest.setDefaultURL",url)
    http.setDefaultURL(url)
end

function HttpRequest.request_(method, param, resultCallback, errorCallback,extParam)

    dump(extParam,"HttpRequest.request_ extParam")
    param = param or {}
    local sig = nb.utils_.md5(HttpRequest.shJoins(param,0))
    param.sig = sig

    local reqParam = {method = method, gameParam = json.encode(param)}
     if extParam then
        for k,v in pairs(extParam) do
            reqParam[k] = v
        end
    end
    local id
    id = http.POST(reqParam, 
        function(data)
            HttpRequest.eraseId(method, id)
            -- dump(data, "data :=============")
            local retData = json.decode(data)
            if type(retData) == "table" and retData.code and retData.code == 1 then
                if retData.data then
                    if DEBUG > 4 then
                        dump(retData.data, "retData.data",10)
                    end
                end
                if resultCallback then
                    if IS_RELEASE == true then
                        pcall(resultCallback,retData.data)
                    else
                        resultCallback(retData.data)
                    end
                end                
                
            else
                if not retData then
                    logger:error("json parse error")
                    if errorCallback then
                        if IS_RELEASE == true then
                            pcall(errorCallback,{errorCode = 1})
                        else
                            errorCallback({errorCode = 1})
                        end
                    end
                else
                    if errorCallback then
                        if IS_RELEASE == true then
                            pcall(errorCallback,{errorCode = retData.code,retData = retData})
                        else
                            errorCallback({errorCode = retData.code,retData = retData})
                        end
                    end
                    
                end
            end
        end, function(errCode,errMsg)
            HttpRequest.eraseId(method, id)
            local errorData = {}
            if errCode ~= nil then
                errorData.errorCode = errCode
            end

            if errMsg ~= nil then
                errorData.errMsg = errMsg
            end

            if errorCallback then
                if IS_RELEASE == true then
                    pcall(errorCallback,errorData)
                else
                    errorCallback(errorData)
                end
            end

        end)

    HttpRequest.pushId(method, id)
    return id
end

function HttpRequest.post(params, resultCallback, errorCallback,extra)
    return http.POST(params, resultCallback, errorCallback,extra)
end

function HttpRequest.get(params, resultCallback, errorCallback,extra)
    return http.GET(params, resultCallback, errorCallback,extra)
end


function HttpRequest.postUrl(url, params, resultCallback, errorCallback,extra)
    return http.POST_URL(url,params, resultCallback, errorCallback,extra)
end


function HttpRequest.getUrl(url, params, resultCallback, errorCallback,extra)
    return http.GET_URL(url,params,resultCallback, errorCallback,extra)
end


function HttpRequest.uploadFile(url, params, resultCallback, errorCallback)
    return http.UPLOAD_FILE(url,params,resultCallback, errorCallback)
end


--用来取消多个同类请求
HttpRequest.id_table = {}

function HttpRequest.pushId(key, requestId)
    if type(key) == "string" and requestId then
        if not HttpRequest.id_table[key] then
            HttpRequest.id_table[key] = {}
        end
        HttpRequest.id_table[key][requestId] = requestId
    end
end

function HttpRequest.eraseId(key, requestId)
    if type(key) == "string" and requestId then
        if HttpRequest.id_table[key] then
            HttpRequest.id_table[key][requestId] = nil
        end
    end
end

function HttpRequest.cancel(requestId)
    if not requestId then return end
    -- http.CANCEL(requestId)
    local findkey
    for key, id_map in pairs(HttpRequest.id_table) do
        if id_map[requestId] == requestId then --找到同类请求
            for _, id in pairs(id_map) do
                http.CANCEL(id)
            end
            findkey = key
            break
        end
    end
    if findkey then
        HttpRequest.id_table[findkey] = nil
    end
end



return HttpRequest



