local I18nUtil = {}
local lang = {}

function I18nUtil.addLangFile(langFile)
    local  isSucc,tlang = pcall(require,langFile)
    if isSucc and type(tlang) == "table" then
        table.merge(lang,tlang)
    end
    
end

function I18nUtil.addLangTb(tlang)
    if type(tlang) == "table" then
        table.merge(lang,tlang)
    end
end

-- 获取一个指定键值的text
function I18nUtil.getText(primeKey, secKey, ...)
    if not lang then
        return
    end
    assert(primeKey ~= nil and secKey ~= nil, "must set prime key and secondary key")
    if I18nUtil.hasKey(primeKey, secKey) then
        if (type(lang[primeKey][secKey]) == "string") then
            return I18nUtil.formatString(lang[primeKey][secKey], ...)
        else
            return lang[primeKey][secKey]
        end
    else
        return ""
    end
end

-- 判断是否存在指定键值的text
function I18nUtil.hasKey(primeKey, secKey)
    return lang[primeKey] ~= nil and lang[primeKey][secKey] ~= nil
end

-- Formats a String in .Net-style, with curly braces ("{1},{2}").
function I18nUtil.formatString(str, ...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        local output = str
        for i = 1, numArgs do
            local value = select(i, ...)
            output = string.gsub(output, "{" .. i .. "}", value)
        end
        return output
    else
        return str
    end
end

function I18nUtil.compareResource(cn, th, path)
    for k, v in pairs(cn) do
        local found = false
        if th then
            for k1, v1 in pairs(th) do
                if k1 == k then
                    found = true
                    if type(v) == "table" then
                        I18nUtil.compareResource(v, v1, path .. "." ..k)
                    end
                    break;
                end
            end
        end
        if not found then
            print(path .. "." .. k)
        end
    end
end

return I18nUtil