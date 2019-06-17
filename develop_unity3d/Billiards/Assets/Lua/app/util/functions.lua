
-- local scheduler = require(nb.PACKAGE_NAME .. "misc.scheduler")
-- local const = import("app.games.gamecommon.config.const")
local functions = {}

function functions.getCardDesc(handCard)
    if handCard then
        local value = bit.band(handCard, 0x0F)
        local variety = bit.band(handCard, 0xF0)       

        local p = ""
        if variety == 0x0 then
            p = "梅花"
        elseif variety == 0x10 then
            p = "方块"
        elseif variety == 0x20 then
            p = "红桃"
        elseif variety == 0x30 then
            p = "黑桃"
        end

        if value >= 2 and value <= 10 then
            p = p .. value
        elseif value == 11 then
            p = p .. "J"
        elseif value == 12 then
            p = p .. "Q"
        elseif value == 13 then
            p = p .. "K"
        elseif value == 1 then
            p = p .. "A"
        end

        if p == "" then
            return "无"
        else
            return p
        end
    else
        return "无"
    end
end

function functions.cacheKeyWordFile()
    if not functions.keywords then
        core.cacheFile(game.userData['urls.keyword'], function(result, content)
            if result == "success" then
                functions.keywords = json.decode(content)
            end
        end, "keywordfilter")
    end
end

function functions.keyWordFilter(message, replaceWord)
    local replaceWith = replaceWord or "**"
    if not functions.keywords then
        functions.cacheKeyWordFile()
    else
        local searchMsg = string.lower(message)
        for i,v in pairs(functions.keywords) do
            local keywords = string.lower(v)
            local limit = 50
            while true do
                limit = limit - 1
                if limit <= 0 then
                    break
                end
                local s, e = string.find(searchMsg, keywords)
                if s and s > 0 then
                    searchMsg = string.sub(searchMsg, 1, s - 1) .. replaceWith ..string.sub(searchMsg, e + 1)
                    message = string.sub(message, 1, s - 1) .. replaceWith .. string.sub(message, e + 1)
                else
                    break
                end
            end
        end
    end
    return message
end

function functions.badNetworkToptip()
    game.TopTipManager:showTopTip(core.LangUtil.getText("COMMON", "BAD_NETWORK"))
end

function functions.getUserInfo(noicon, default)
    local userInfo = nil
    if default ~= true then
        userInfo = {
            -- icon = game.userData['aUser.icon'], 
            name = game.userData['aUser.name'],
            uid = game.userData["aUser.mid"],
            -- sex = game.userData["aUser.sex"],
            -- ip  = game.userData.ip,
            -- longitude = game.userData["aUser.longitude"],
            -- latitude = game.userData["aUser.latitude"],
            -- isGps = game.userData["aUser.isGps"] or "0",
            -- tmy = appconfig.appid or 10
        }
        
    else
        userInfo = {
            icon = "", 
            name = T("游戏玩家"),
            sex = 1,
            ip  = game.userData.ip,
        }
    end
    if noicon then
        userInfo.icon = ""
    end
    dump(userInfo,"init userInfo")
    return userInfo 
end

--limit:九人场还是五人场
--tab:哪个选项卡：对应以前初级，中级，高级
function functions.getRoomDatasByLimitAndTab(limit,tab)

   dump("getRoomDatasByLimitAndTab-limit:" .. limit .. " tab:" .. tab)
    local tb = core.DataProxy:getData(game.dataKeys.TABLE_CONF)
    local tempTb = {}
    for group,v in pairs(tb) do
        dump(group,"getRoomDatasByLimitAndTab-group")
        if group == limit then
            for tabGroup,vv in pairs(v) do
                dump(tabGroup,"getRoomDatasByLimitAndTab-tabGroup")
                if tabGroup == tab then
                    for __,data in pairs(vv) do
                        local temp = {}
                        temp.roomType = tonumber(data[1])
                        temp.blind = tonumber(data[2])
                        temp.minBuyIn = tonumber(data[3])
                        temp.maxBuyIn = tonumber(data[4])
                        temp.limit = tonumber(data[5])
                        temp.online = tonumber(data[6])
                        temp.fee = tonumber(data[7])
                        temp.sendChips=string.split(data[8],",") or {1,10,50,500}
                        temp.roomGroup = tonumber(__)
                        temp.recmax = tonumber(data[9])  -- 场次推荐最大资产值
                        temp.slot = string.split(data[10],",") or {40,120,300}
                        temp.exprDiscount = tonumber(data[11])  -- 付费表情折扣率

                        if data[12] then
                            local quickRateGroup = string.split(data[12],":")
                            for i,v in ipairs(quickRateGroup) do
                                local tempRate = string.split(v,",")
                                local desRate = {}
                                for __,vv in ipairs(tempRate) do
                                    table.insert(desRate,tonumber(vv))
                                end
                                quickRateGroup[i]  = desRate

                            end
                            temp.quickRateGroup = quickRateGroup
                        end
                        temp.enterLimit = tonumber(data[13])--房间入场门槛值

                        temp.fast = string.split(data[17],",") --快速开始上下限

                        --选场场次引导动画资产范围
                        if data[18] then
                            guideTb = string.split(data[18],",")
                            temp.roomGuideRange = {min = tonumber(guideTb[1]),max = tonumber(guideTb[2])}
                        end

                        -- 房间内引导资产下一场次阀值
                        temp.roomGroupNext = tonumber(data[19])
                        temp.rType = tonumber(data[20]) or 1  --房间类型，普通筹码场，还是现金币场

                        table.insert(tempTb,temp)

                    end
                    break
                end

            end
            break
        end 
    end

    return tempTb

end

-- 获取荷官小费
function functions.getRoomDataByLevel(level)
    local tb = core.DataProxy:getData(game.dataKeys.TABLE_CONF)
    local temp
    for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___,vv in pairs(v) do
                if (tonumber(vv[1])) == (tonumber(level)) then
                    temp = {}
                    temp.roomType = tonumber(vv[1])
                    temp.blind = tonumber(vv[2])
                    temp.minBuyIn = tonumber(vv[3])
                    temp.maxBuyIn = tonumber(vv[4])
                    temp.limit = tonumber(vv[5])
                    temp.online = tonumber(vv[6])
                    temp.fee = tonumber(vv[7])
                    temp.sendChips=string.split(vv[8],",") or {1,10,50,500}
                    temp.roomGroup = tonumber(__)
                    temp.recmax = tonumber(vv[9])  -- 场次推荐最大资产值
                    temp.slot = string.split(vv[10],",") or {40,120,300}
                    temp.exprDiscount = tonumber(vv[11])  -- 付费表情折扣率

                    if vv[12] then
                        local quickRateGroup = string.split(vv[12],":")
                        for i,v in ipairs(quickRateGroup) do
                            local tempRate = string.split(v,",")
                            local desRate = {}
                            for __,vv in ipairs(tempRate) do
                                table.insert(desRate,tonumber(vv))
                            end
                            quickRateGroup[i]  = desRate

                        end
                        temp.quickRateGroup = quickRateGroup
                    end
                    temp.enterLimit = tonumber(vv[13])--房间入场门槛值

                    temp.fast = string.split(vv[17],",") --快速开始上下限

                    --选场场次引导动画资产范围
                    if vv[18] then
                        guideTb = string.split(vv[18],",")
                        temp.roomGuideRange = {min = tonumber(guideTb[1]),max = tonumber(guideTb[2])}
                    end

                    -- 房间内引导资产下一场次阀值
                    temp.roomGroupNext = tonumber(vv[19])
                    temp.rType = tonumber(vv[20]) or 1  --房间类型，普通筹码场，还是现金币场
                    temp.isAllIn = tonumber(vv[21]) or 0 --是否开启all in
                    return temp
                end
            end
            
        end 
    end
    return temp
end


--根据用户资产范围获取推荐房间
function functions.getRoomLevelByMoney2(money)
    local tb = core.DataProxy:getData(game.dataKeys.TABLE_CONF)
    local firstData = nil --找不到场次就返回最小场次

     for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___,vv in pairs(v) do
               local roomType = vv[20]
               if not firstData and roomType == 1 then firstData = tonumber(vv[1]) end
               if money >= checkint(vv[9]) and roomType == 1 then
                    local fast  = string.split(vv[17],",")
                    local min = checkint(fast[1])
                    local max = checkint(fast[2])

                    if money >= min and (money < max or max == 0 ) then
                        
                         return tonumber(vv[1])
                    end

               end
            end
            
        end 
    end

    return firstData
end

function functions.getRoomLevelByCash(cash)
    local tb = core.DataProxy:getData(game.dataKeys.TABLE_CONF)
    local temp = {}
     for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___,vv in pairs(v) do
               local roomType = vv[20]
               -- if roomType == 2 then
               --   return tonumber(vv[1])
               -- end
               if cash >= checkint(vv[9]) and roomType == 2 then
                    local fast  = string.split(vv[17],",")
                    local min = checkint(fast[1])
                    local max = checkint(fast[2])
                    if cash >= min and (cash <= max or max == 0 ) then
                        
                         return tonumber(vv[1])
                    end

               end
            end
            
        end 
    end
   
end



function functions.getRoomLevelByMoney(money)
    local tb = core.DataProxy:getData(game.dataKeys.TABLE_CONF)
    -- local temp = {}
    -- dump(tb, "TABLE_CONF : ===================", 6)
    for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___,vv in pairs(v) do
               if money <= tonumber(vv[5]) or tonumber(vv[5]) == 0 then
                    return tonumber(vv[1])
               end
            end
            
        end 
    end
end

function functions.getRoomLevelMinByMoney(money)
    -- body

    local tb = core.DataProxy:getData(game.dataKeys.TABLE_CONF)
    for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___, vv in pairs(v) do
                if money <= tonumber(vv[4]) or tonumber(vv[4]) == 0 then
                    --todo
                    return tonumber(vv[1])
                end
            end
        end 
    end
end

function functions.getGuideChipRoomLevelByMoney(money)
    local tb = core.DataProxy:getData(game.dataKeys.TABLE_CONF)
    for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___, vv in pairs(v) do
                --筹码场里找
                if (1 == vv[20]) and vv[18] then
                    guideTb = string.split(vv[18],",")
                    local min = checkint(guideTb[1])
                    local max = checkint(guideTb[2])

                    if money >= min and (money < max or max == 0)then
                        return vv[1],vv
                    end
                end

                
            end
        end 
    end
    return nil,nil
end

function functions.subStr2TbByWidth(font, size, text, width)
    if not game or not game.Native then

        return {text}
    end
    local tb = {}
    local orgText = text
    local orgLen =  string.utf8len(text)
    local tempLen = 0
    local tempStr = ""
    local remainStr = orgText
    local len = 0
    repeat
        tempStr = game.Native:getFixedWidthText(font, size, remainStr, width)
        tempLen = string.utf8len(tempStr)
        len = len + tempLen
        table.insert(tb,tempStr)
        remainStr = string.utf8sub(orgText,len+1)
     
    until(len >= orgLen)

    return tb

end

-- function functions.serverTableIDToClientTableID(table_id)
--     local server_id = table_id
--     -- 右移16位为server_id
--     bit.brshift(server_id, 16)
--     local real_table_id = table_id
--     bit.band(0x0000ffff, real_table_id)
    
--     return tostring(server_id) .. tostring(real_table_id)
-- end

-- -- 规定前3位为server_id (table_id_str为玩家输入ID)
-- function functions.clientTableIDToServerTableID(table_id_str)
--     local len = string.len(table_id_str)    
--     -- 异常 输入的只能为数字什么的判断
--     if len <= 3 then
--         --return error!!
--         return
--     end
--     local server_str = string.sub(table_id_str, 1, 4)
--     local real_table_id_str = string.sub(table_id_str, 4, len)
    
--     local server_id = tonumber(server_str)
--     local real_table_id = tonumber(real_table_id_str)
--     bit.blshift(server_id, 16)
--     return  server_id + real_table_id
-- end

-- 清除登录缓存 --
-- 待加入清除 game.cookieKeys.LOGIN_SESSKEY 的方式(需用到tinyXml2 库进行xml遍历操作)
function functions.clearLoginCache()
    game.userDefault:setStringForKey(game.cookieKeys.LAST_LOGIN_TYPE, "")
    game.userDefault:setStringForKey(game.cookieKeys.FACEBOOK_ACCESS_TOKEN, "")
    -- game.userDefault:setStringForKey(game.cookieKeys.LOGIN_SESSKEY .. game.userData["aUser.sitemid"], "")

    -- local isCacheFileExist = game.userDefault:isXMLFileExist()
    -- local defaultCacheFilePath = game.userDefault:getXMLFilePath()

    game.userDefault:flush()
end

function functions.clearMyHeadImgCache()
    local mIcon = game.userData["aUser.micon"]
    if mIcon then
        --todo
        local imgurl = nil
        if string.find(mIcon, "facebook") then
            if string.find(mIcon, "?") then
                imgurl = mIcon .. "&width=100&height=100"
            else
                imgurl = mIcon .. "?width=100&height=100"
            end
        end

        if string.len(mIcon) > 0 then
            --todo
            local hash = nb.utils_.md5(imgurl)
            local path = device.writablePath .. "cache" .. device.directorySeparator .. "headpics" .. device.directorySeparator .. hash
            -- dump("path :" .. path)
            if core.isFileExist(path) then
                dump("File Exist! To Remove.")
                local tex = nb.Director:getInstance():getTextureCache():addImage(path)
                if tex then
                    --删除缓存
                    nb.Director:getInstance():getTextureCache():removeTexture(tex)
                    tex = nil
                end
                os.remove(path)
            end     
        end
    else
        dump("error in aUser.micon!")
    end
end


function functions.str2CharTb(str)
    
    local tb = {}
    if str then
        local len = string.len(str)
        for i = 1,len do
            tb[i] = string.sub(str,i,1)
        end
    end
    
    return tb

end


function functions.formatLocalMoney(money,isfloor)
    money = checkint(money)
    local flag  = (money < 0) and "-" or ""
    money = math.abs(money)

   if money < 10000 then
        return flag .. money
    elseif money >= 10000 and money < 100000000 then
        if money%10000 ==0 or isfloor == true then
            return flag .. math.floor(money/10000) .. T("万")
        else
            return flag .. string.format( "%.1f", money/10000) .. T("万")
        end
    elseif money >= 100000000 and money < 100000000000 then
        if money%100000000 ==0 or isfloor == true then
            return flag .. math.floor(money/100000000) .. T("亿")
        else
            return flag .. string.format( "%.1f", money/100000000) .. T("亿")
        end
    else
        if money%100000000000 ==0 or isfloor == true then
            return flag .. math.floor(money/100000000000) .. T("千亿")
        else
            return flag .. string.format( "%.1f", money/100000000000) .. T("千亿")
        end
    end
end

-- numlen 一个数字的宽度
-- unitlen 一个单位的宽度
-- widthlimit 限制宽度
function functions.formatLocalMoneyForHeadView(money, isfloor, numlen, unitlen, widthlimit)
    -- 此处参数根据文字图集取得
    numlen = numlen or 9
    unitlen = unitlen or 14
    widthlimit = widthlimit or 74
    money = checknumber(money)
    local flag  = (money < 0) and "-" or ""
    money = math.abs(money)
    local num, unit = 0, ""
    if money < 10000 then
        num, unit = money, ""
    else
        money = checkint(money)
        if money >= 10000 and money < 100000000 then
            if money%10000 ==0 or isfloor == true then
                num, unit = math.floor(money/10000), T("万")
            else
                num, unit = string.format( "%.1f", money/10000),T("万")
            end
        elseif money >= 100000000 and money < 100000000000 then
            if money%100000000 ==0 or isfloor == true then
                returnum, unit = math.floor(money/100000000),T("亿")
            else
                num, unit = string.format( "%.1f", money/100000000),T("亿")
            end
        else
            if money%100000000000 ==0 or isfloor == true then
                num, unit = math.floor(money/100000000000), T("千亿")
            else
                num, unit = string.format( "%.1f", money/100000000000),T("千亿")
            end
        end
        
    end
    

    if numlen and unitlen and widthlimit then
        local unitnum = string.utf8len(unit)
        local numnum = string.utf8len(tostring(num))
        local diffwidth = numlen * numnum + unitlen * unitnum - widthlimit
        -- print("unitnum = ",unitnum)
        -- print("numnum = ",numnum)
        -- print("diffwidth = ",diffwidth)
        if diffwidth <= 0 then
            -- 没有超过长度限制，啥都不干
        else
            local integral, fractional = math.modf(num)
            if fractional == 0 then
                -- 没有小数，啥都不干
            else
                -- 缩减小数点位数
                local multi = math.ceil(diffwidth / numlen)
                -- print("multi = ",multi)
                -- 小数点算1，小数点后有3
                if multi >= 3 then
                    num = integral
                else
                    local n = 3 - multi
                    num = integral + math.floor(fractional * math.pow(10, n)) * math.pow(0.1,n)
                end
            end
        end
    end

    -- print("num, unit = ", num, unit)
    return flag .. num .. unit
end

local formatType = 
{
    ["zh"] = {
        ["万"] = "W",
        ["亿"] = "Y",
        -- ["千亿"] = "QY",
         ["."] = "D"
    }
}

function functions.formatLocalMoneyImg(str,ftype)
    local unitTb = formatType[ftype]
    if not unitTb then
        return str
    end

    local tstr = str
    for k,v in pairs(unitTb) do
        local tk = k
        if k == "." then
            tk = "%."
        end
        tstr = string.gsub(tstr,tostring(tk),unitTb[k])
        
    end
    return tstr
    
end


function functions.exportMethods(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end


--qq_vip_type = 0/1/2, --0不是qqvip，1qq_vip，2qq_svip
function functions.getQQVipType()
    local vipInfo = core.DataProxy:getData(game.dataKeys.QQ_VIP_DATA) or {}
    local qq_vip_type = 0
    if vipInfo.is_qq_svip == 1 then
        qq_vip_type = 2 
    elseif vipInfo.is_qq_vip == 1 then
        qq_vip_type = 1
    end
    return qq_vip_type
end

--start_up_type = 0/1/2,--0普通启动，1qq游戏中心启动，2微信游戏中心启动
function functions.getStartUpType()
    local startType = core.DataProxy:getData(game.dataKeys.START_UP_DATA) or ""
    local start_up_type = 0
    if startType == "sq_gamecenter" then
        start_up_type = 1
    end
    return start_up_type
end

--生成一张本地图片（大小是全屏大小）
--@param node 节点（必须传）
--saveToFile 是异步操作，但是不支持回调 只能延迟
-- function functions.genLocalImage(node, callback, filename, param)
--     if not node then return end
--     if not filename or filename == "" then
--         filename = string.format("share_%s.jpg",os.time())
--     end
--     local genImgDir = "genLocalImage"
--     local genRootDir = device.writablePath .. genImgDir .. device.directorySeparator
--     local genRelativeFilePath = genImgDir .. device.directorySeparator .. filename
--     local fullpath = genRootDir .. filename

--     core.mkdir(genRootDir)

--     local function onCacheChanged(path) 
--         require("lfs")
--         local fileDic = {}
--         local fileIdx = {}
--         local MAX_FILE_NUM = 3
--         for file in lfs.dir(path) do
--             if file ~= "." and file ~= ".." then
--                 local f = path.. device.directorySeparator ..file
--                 local attr = lfs.attributes(f)
--                 -- assert(type(attr) == "table")
--                 if type(attr) == "table" then
--                     if attr.mode ~= "directory" then
--                         fileDic[attr.access] = f
--                         fileIdx[#fileIdx + 1] = attr.access
--                     end
--                 end
--             end
--         end
--         if #fileIdx > MAX_FILE_NUM then
--             table.sort(fileIdx)
--             repeat
--                 local file = fileDic[fileIdx[1]]
--                 print("remove file -> " .. file)
--                 os.remove(file)
--                 table.remove(fileIdx, 1)
--             until #fileIdx <= MAX_FILE_NUM
--         end
--     end

    
--     local rect = {}
--     if node.getContentSize then
--         rect = node:getContentSize()
--     end
--     if not rect or rect.width<=0 or rect.height<=0 then
--         rect = nb.utils_:getCascadeBoundingBox(node)
--     end
--     if param and param.x and param.y then
--         rect.x =  param.x
--         rect.y =  param.y
--     else
--         rect.x = 0
--         rect.y = 0
--     end

--     if param and param.width and param.height then
--         rect.width = param.width
--         rect.height = param.height
--     end
--     local renderTexture = nb.RenderTexture:create(rect.width, rect.height, nb.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,  gl.DEPTH24_STENCIL8_OES)
--     renderTexture:setKeepMatrix(true)
--     local fullRect = nb.rect(0, 0, display.width, display.height)

--     -- 是否超出屏幕
--     local isOverScreen = param and param.isOverScreen or false
--     if isOverScreen then
--         local openGLView = nb.Director:getInstance():getOpenGLView()
--         local originPolicy = openGLView:getResolutionPolicy()
--         local originSize = openGLView:getDesignResolutionSize()
--         openGLView:setDesignResolutionSize(rect.width,rect.height,originPolicy)
--         fullRect = nb.rect(0, 0, rect.width, rect.height)
--         renderTexture:setVirtualViewport(nb.p(rect.x, rect.y),fullRect,fullRect)
    
--         renderTexture:beginWithClear(0,0,0,0)
--         node:visit()
--         renderTexture:endToLua()
    
--         openGLView:setDesignResolutionSize(originSize.width,originSize.height,originPolicy)
--     else
--         renderTexture:setVirtualViewport(nb.p(rect.x, rect.y),fullRect,fullRect)
--         renderTexture:beginWithClear(0,0,0,0)
--         node:visit()
--         renderTexture:endToLua()
--     end
    

--     print("genLocalImage",type(renderTexture.saveToFile2))
--     local ret = false
--     if type(renderTexture.saveToFile2) == "function" then
--         --新接口
--         local function onSaveImgCallback(tpath)
--             print("onSaveImgCallback",tpath,fullpath)
--             if (not tolua.isnull(node)  and callback) then
--                 callback(true,fullpath,tpath)
--             end
--             onCacheChanged(genRootDir)
--         end

--         ret =  renderTexture:saveToFile2(genRelativeFilePath, nb.IMAGE_FORMAT_JPEG, false,onSaveImgCallback)
--         print("functions.genLocalImage-new ret:%s, path:%s", tostring(ret), fullpath)
--         nb.Director:getInstance():getTextureCache():removeTextureForKey(fullpath)  

--     else
--         --老接口
--         ret =  renderTexture:saveToFile(genRelativeFilePath, nb.IMAGE_FORMAT_JPEG, false)
--         print("functions.genLocalImage-old ret:%s, path:%s", tostring(ret), fullpath)
--         nb.Director:getInstance():getTextureCache():removeTextureForKey(fullpath)  
--         if node and node.performWithDelay and callback then
--             scheduler.performWithDelayGlobal(function ( ... )
--                 if not tolua.isnull(node) then
--                     callback(ret, fullpath)
--                 end
--                 onCacheChanged(genRootDir)
--             end,1)
--         end


--     end
    
--     return ret
-- end

--生成一张截屏（全屏）
--jpg图片
function functions.genScreenShot(callback)
    local filename = nb.utils_.md5(os.time()) .. ".jpg"
    nb.utils:captureScreen(function (succeed, outputFile)
        if callback then
            callback(succeed, outputFile)
        end
    end, filename)
end

function functions.limitStrLength(str,num)
    str = str or ""
    num  = num or string.utf8len(str)
    if string.utf8len(str) > num then
        return   string.utf8sub(str,1,num) .. ".."
    else
        return   string.utf8sub(str,1,num) 
    end
end


function functions.getFixedWidthText(font, size, text, width, noPoint)
    local ret = text
    text = text or ""
    local tf = ccui.Text:create()
    -- tf:ignoreContentAdaptWithSize(true)
    size = size or 24
    tf:setFontSize(size)
    if font then
        tf:setFontName(font)
    end
    
    local len = string.utf8len(text)
    local endIdx = len
    for i=1,len do
        local s = string.utf8sub(text,1,i)
        tf:setString(s)
        local sz = tf:getContentSize()
        if sz.width > width then
            endIdx = i
            break
        end
    end

    tf = nil

    if endIdx < len then
        ret = string.utf8sub(text,1,(endIdx-2))
        if not noPoint then
            ret = ret .. ".."
        end
    end
    
    return ret
end

function functions.limitTextLenth(str,limit)
    local limit = limit * 2
    local count = 0
    local result = ""

    if string.utf8len(str) <= 2 then
        return str
    end

    for i=1,string.utf8len(str), 1 do
        local s = string.utf8sub(str,i,i)
        if string.len(s) > 1 then
            count = count + 2
        else
            count = count + 1
        end

        if count > limit then
            result = result .. ".."
            break
        end
        result = result .. s
    end

    return result 
end

function functions.getPkgName(curModuleName)
    local tb = string.split(curModuleName,".")
    table.remove(tb,#tb)
    return table.concat(tb,".")
    
end


function functions.getGameModuleByName(tmodule,curModule,defaultResult)
    local isSucc,result = pcall(import,tmodule,curModule)
    if isSucc then
        return result
    else
        return defaultResult or nil

    end
end

--获取机器人虚拟ID
function functions.getRobotVirId(uid)
    uid = checkint(uid)
    if uid <10000 then
        return uid+10000
    else
        return uid
    end
end


--- 判断version1的完整版本号是否大于version2的完整版本号
-- 没有version1，返回false
-- 没有version2，返回true
-- 位数不同，返回false
-- orEqual 为true时判断大于等于，为false时判断大于
function functions.isFullVersionNewer(version1, version2, orEqual)
    local NewUpdateMgr = require("gamehall.src.update.NewUpdateMgr")
    return NewUpdateMgr.getInstance():isFullVersionNewer(version1, version2, orEqual)
end

--- 判断version1的Lua版本号是否大于version2的Lua版本号
-- 没有version1，返回false
-- 没有version2，返回true
-- 位数不同，返回false
-- 前三位不等返回false
-- 最后只比较最后一位,如果version1的大于version2的，则返回true，否则返回false（只判断可以用于Lua更新的情况）
-- orEqual 为true时判断大于等于，为false时判断大于
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!此接口已过时，更新只判断isFullVersionNewer!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
function functions.isLuaVersionNewer(version1, version2, orEqual)
    local NewUpdateMgr = require("gamehall.src.update.NewUpdateMgr")
    return NewUpdateMgr.getInstance():isLuaVersionNewer(version1, version2, orEqual)
end

--- 获取应用版本号，安卓获取versionName，iOS获取shortVersion，Win32暂时固定1.0.0
function functions.getAppVersion()
    local NewUpdateMgr = require("gamehall.src.update.NewUpdateMgr")
    return NewUpdateMgr.getInstance():getAppVersion()
end

--- 获取应用的构建版本，恒为字符串，android为versionCode，iOS为buildVersion
function functions.getAppBuildVersion()
    local NewUpdateMgr = require("gamehall.src.update.NewUpdateMgr")
    return NewUpdateMgr.getInstance():getAppBuildVersion()
end

--获取某天0点的时间戳
function functions.getDay0Time(time)
    time = time or os.time()
    local tab = os.date("*t", time)
    tab.hour = 0
    tab.min = 0
    tab.sec = 0
    return os.time(tab)
end

--客户端检测的选项状态
function functions.getSelfCheckStatusInfo(extra,encode)
    local statusObj = 
    {
        gps = checkint(game.userData["aUser.isGps"]),
        gpsCode = checkint(game.userData["aUser.gpsCode"])
    }

    if extra then
        for k,v in pairs(extra) do
            statusObj[k] = v
        end
    end

    if encode then
        return json.encode(statusObj)
    else
        return statusObj
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
                versionNum = versionNum  + checkint(list[i]) * (100 ^ (4 - i))
            end
        end
    end
    return versionNum
end


--判断是否ios inhouse 包
function functions.isIosInhouseApp( ... )
    if device.platform == "ios" then
        --目前只有一个账号，暂时固定teamId判断
        local teamId = "APWS8UXGF6"
        if game and game.Native and game.Native.checkCodeSignInfo then
            local ok,result = game.Native:checkCodeSignInfo(teamId)
            if ok then
                result = json.decode(result)
                if result and checkint(result.teamId) == 1 then
                    return true
                end
            end
            return false
        end
    else
        return false
    end

    return false
end



function functions.hidePhoneNumber(phone)
    phone = tostring(phone)
    if string.len(phone) ~= 11 then
        return phone
    end

    return (string.sub(phone,1,3) .. "****" .. string.sub(phone,-4,-1))
end




return functions
