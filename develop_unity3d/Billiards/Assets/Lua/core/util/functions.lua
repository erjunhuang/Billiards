
-- require("lfs")

local socket = require "socket"

local functions = {}

function functions.getTime()
    return socket.gettime()
end

function functions.isFileExist(path)
    return path and nb.FileUtils:getInstance():isFileExist(path)
end

function functions.isDirExist(path)
    local success, msg = lfs.chdir(path)
    return success
end
 
function functions.mkdir(path)
    -- dump("mkdir " .. path)
    if not functions.isDirExist(path) then
        local prefix = ""
        if string.sub(path, 1, 1) == device.directorySeparator then
            prefix = device.directorySeparator
        end
        local pathInfo = string.split(path, device.directorySeparator)
        local i = 1
        while(true) do
            if i > #pathInfo then
                break
            end
            local p = string.trim(pathInfo[i] or "")
            if p == "" or p == "." then
                table.remove(pathInfo, i)
            elseif p == ".." then
                if i > 1 then
                    table.remove(pathInfo, i)
                    table.remove(pathInfo, i - 1)
                    i = i - 1
                else
                    return false
                end
            else
                i = i + 1
            end
        end
        for i = 1, #pathInfo do
            local curPath = prefix .. table.concat(pathInfo, device.directorySeparator, 1, i) .. device.directorySeparator
            if not functions.isDirExist(curPath) then
                --print("mkdir " .. curPath)
                local succ, err = lfs.mkdir(curPath)
                if not succ then 
                    -- dump("mkdir " .. path .. " failed, " .. err)
                    return false
                end
            else
                --print(curPath, "exists")
            end
        end
    end
    -- dump("done mkdir " .. path)
    return true
end
 
function functions.rmdir(path)
    -- dump("rmdir " .. path)
    if functions.isDirExist(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        --print("remove file ", curDir)
                        os.remove(curDir)
                    end
                end
            end
            --print("rmdir ", path)
            local succ, des = lfs.rmdir(path)
            if not succ then 
                -- dump("remove dir " .. path .. " failed, " .. des) 
            end
            return succ
        end
        _rmdir(path)
    end
    -- dump("done rmdir " .. path)
    return true
end

function functions.readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

function functions.removeFile(path)
    io.writefile(path, "")
    if device.platform == "windows" then
        os.execute("del " .. string.gsub(path, '/', '\\'))
    else
        os.execute("rm " .. path)
    end
end

function functions.checkFile(fileName, cryptoCode)
    if not io.exists(fileName) then
        return false
    end

    local data=functions.readFile(fileName)
    if data==nil then
        return false
    end

    if cryptoCode=="nil" or cryptoCode == "" or cryptoCode == nil then
        return true
    end
    local ms = crypto.md5file(fileName)
    if ms==cryptoCode then
        return true
    end

    return false
end

function functions.checkDirOK( path )
    local oldpath = lfs.currentdir()
    -- dump("old path------> "..oldpath)
    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        -- dump("path check OK------> "..path)
        return true
    end

    if lfs.mkdir(path) then
        -- dump("path create OK------> "..path)
        return true
    end
end

--获取APP版本号
function  functions.getAppVersion()
    local ok, version
    if device.platform == "android" then
        ok, version = luaj.callStaticMethod("com/boyaa/cocoslib/core/functions/GetAppVersionFunction", "apply", {}, "()Ljava/lang/String;")
        if ok then
            return version
        end
    elseif device.platform == "ios" then
        ok, version = luaoc.callStaticMethod("LuaOCBridge", "getAppVersion", nil)
        if ok then
            return version
        end
    end
end

function functions.getVersionNum(version, num)
    local versionNum = 0
    if version then
        local list = string.split(version, ".")
        for i = 1, 4 do
            if num and num > 0 and i > num then
                break
            end
            if list[i] then
                versionNum = versionNum  + tonumber(list[i]) * (100 ^ (4 - i))
            end
        end
    end
    return versionNum
end


function functions.cacheFile(url, callback, dirName)
    local dirPath = device.writablePath .. "cache" .. device.directorySeparator ..  (dirName or "tmpfile") .. device.directorySeparator
    local hash = nb.utils_.md5(url)
    local filePath = dirPath .. hash
    local requestId
    print("cacheFile filePath", filePath)
    if functions.mkdir(dirPath) then
        if io.exists(filePath) then
            print("cacheFile io exists", filePath)
            callback("success", io.readfile(filePath),filePath)
        else
            print("cacheFile url", url)
            requestId = core.HttpService.GET_URL(url, {}, function(data)
                io.writefile(filePath, data, "w+b")
                callback("success", data,filePath)
            end,
            function()
                callback("fail",{},filePath)
            end)
        end
    end

    return requestId
end

function functions.cacheTable(name, table,dirName)
    dirName = dirName or "data"
    local dirPath = device.writablePath .. "cache" .. device.directorySeparator ..  dirName .. device.directorySeparator
    local filePath = dirPath .. name
    if functions.mkdir(dirPath) then
        if type(table) ~= "table" then
            local ret = nil
            if io.exists(filePath) then                
                local tmp = io.readfile(filePath) 
                ret = json.decode(tmp)             
            end
            return ret
        else    
            local data = json.encode(table)
            if data then
                io.writefile(filePath, data, "w+b")
            end
        end
    end
end

-- 遍历table，释放CCObject
local releaseHelper
releaseHelper = function (obj)
    if type(obj) == "table" then
        for k, v in pairs(obj) do
            releaseHelper(v)
        end
    elseif type(obj) == "userdata" then
        obj:release()
    end
end
functions.objectReleaseHelper = releaseHelper

function functions.formatBigNumber(num)
    local len  = string.len(tostring(num))
    local temp = tonumber(num)
    local ret
    if len >= 13 then
        temp = temp / 1000000000000;
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "T"
    elseif len >= 10 then
        temp = temp / 1000000000;
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "B"
    elseif len >= 7 then
        temp = temp / 1000000;
       ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "M"
    elseif len >= 5 then
        temp = temp / 1000;
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "K"
    else
        return tostring(temp)
    end

    if string.find(ret, "%.") then
        while true do
            local len = string.len(ret)
            local c = string.sub(ret, len - 1, string.len(ret) - 1)
            if c == "." then
                ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                break
            else
                c = tonumber(c)
                if c == 0 then
                    ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                else
                    break
                end
            end
        end
    end

    return ret
end

function functions.formatNumberWithSplit(num)
    return string.formatnumberthousands(num)
end

function functions.getVersionNum(version, num)
    local versionNum = 0
    if version then
        local list = string.split(version, ".")
        for i = 1, 4 do
            if num and num > 0 and i > num then
                break
            end
            if list[i] then
                versionNum = versionNum  + tonumber(list[i]) * (100 ^ (4 - i))
            end
        end
    end
    return versionNum
end


function functions.rangeInDefined(current,min,max)
     return math.max(min, current) == math.min(current, max);
end

-- @param tag:格式标志, 1:显示格式-> 分:秒 2:格式-> 时：分：秒 3：->xx天
function functions.formatTimeStamp(tag, timeStamp)
    -- body
    local timeRetTable = {
        day = 0,
        hour = 0,
        min = 0,
        sec = 0
    }

    local getformatTimeTableByTag = {
        [1] = function(timeIntvel)
            -- body

            if timeIntvel <= 0 then
                --todo
                -- dump("wrong timeStamp!")
                return timeRetTable
            end

            local mins = math.floor(timeIntvel / 60)
            local secs = timeIntvel % 60
            timeRetTable.min = mins
            timeRetTable.sec = secs

            return timeRetTable
        end,

        [2] = function(timeIntvel)
            -- body
            if timeIntvel <= 0 then
                --todo
                -- dump("wrong timeStamp!")
                return timeRetTable
            end

            local hours = math.floor(timeIntvel / (60 * 60))
            local mins = math.floor((timeIntvel - hours * 60 * 60) / 60)
            local secs = (timeIntvel - hours * 60 * 60) % 60
            timeRetTable.hour = hours
            timeRetTable.min = mins
            timeRetTable.sec = secs

            return timeRetTable
        end,

        [3] = function(timeIntvel)
            -- body
            if timeIntvel <= 0 then
                --todo
                -- dump("wrong timeStamp!")
                return timeRetTable
            end

            local days = math.floor(timeIntvel / (60 * 60 * 24))
            local hours = math.floor((timeIntvel - days * 60 * 60 * 24) / (60 * 60))
            local mins = math.floor((timeIntvel - days * 60 * 60 * 24 - hours * 60 * 60) / 60)
            local secs = (timeIntvel - days * 60 * 60 * 24 - hours * 60 * 60) % 60
            timeRetTable.day = days
            timeRetTable.hour = hours
            timeRetTable.min = mins
            timeRetTable.sec = secs

            return timeRetTable
        end

        -- 待新的需求添加 xx月 或 xx年
    }

    return getformatTimeTableByTag[tag](timeStamp)
end

functions.exportMethods = function(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

function orderedPairs(t)
    local cmpMultitype = function(op1, op2)
        local type1, type2 = type(op1), type(op2)
        if type1 ~= type2 then --cmp by type
            return type1 < type2
        elseif type1 == "number" and type2 == "number"
            or type1 == "string" and type2 == "string" then
            return op1 < op2 --comp by default
        elseif type1 == "boolean" and type2 == "boolean" then
            return op1 == true
        else
            return tostring(op1) < tostring(op2) --cmp by address
        end
    end

    local genOrderedIndex = function(t)
        local orderedIndex = {}
        for key in pairs(t) do
            table.insert( orderedIndex, key )
        end
        table.sort( orderedIndex, cmpMultitype ) --### CANGE ###
        return orderedIndex
    end

    local orderedIndex = genOrderedIndex( t );
    local i = 0;
    return function(t)
        i = i + 1;
        if orderedIndex[i] then
            return orderedIndex[i],t[orderedIndex[i]];
        end
    end,t, nil;
end



function table.isEmpty(tb)
    if tb and type(tb)=="table" then 
        return next(tb)==nil;  
    end
    return true;
end


local mime =  require "mime.core"
function functions.encodeBase64(plaintext)
    plaintext = tostring(plaintext)
    return mime.b64(plaintext)
end

function functions.decodeBase64(ciphertext)
    ciphertext = tostring(ciphertext)
    return mime.unb64(ciphertext)
end

nb.exports.Base64 = {decode = functions.decodeBase64,encode = functions.encodeBase64}

--获取文件名
function functions.getFileName(filename)
    local fn_flag = string.find(filename, "\\")

    if fn_flag then
        return string.match(filename, ".+\\([^\\]*%.%w+)$") 
    end

    fn_flag = string.find(filename, "/")
    if fn_flag then
        return string.match(filename, ".+/([^/]*%.%w+)$")
    end

    return filename

end

--获取扩展名
function getFileExtension(str)
    return str:match(".+%.(%w+)$")
end



return functions