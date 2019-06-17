

local MagicPatterns = "[%(%)%.%%%+%-%*%?%[%]%^%$]"
local DirtyWordFilter = class("DirtyWordFilter")

function DirtyWordFilter:ctor()
	 self.logger = core.Logger.new("DirtyWordFilter")

	self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    self.schedulerPool_ = core.SchedulerPool.new()

end


function DirtyWordFilter:loadConfigByUrl(url,callback)
	print("DirtyWordFilter:loadConfigByUrl -- url:" .. (url or "nil"))
	if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    if not self.url_ then
    	return
    end
    self.loadGiftConfigCallback_ = callback
    self:loadConfig_()
end

function DirtyWordFilter:loadConfigByTable(dirtyWordLib)
	if type(dirtyWordLib) == "table" then
		print("DirtyWordFilter:loadConfigByTable -- ")
		self.dirtyWordLib_ = dirtyWordLib
		self.dealMagicWords(self.dirtyWordLib_)
		self:sortWords(self.dirtyWordLib_)
		self.isConfigLoading_ = false
		self.isConfigLoaded_ = true
	end
end

function DirtyWordFilter:isReady()
	return (self.isConfigLoaded_ == true)
end

function DirtyWordFilter:loadConfig_()
	local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            core.cacheFile(self.url_ or game.userData["urls.dirtylibUrl"], function(result, content,filePath)
                self.isConfigLoading_ = false
                if result == "success" then
                    local tempDatas = json.decode(content)
                    if type(tempDatas) == "table" then
                        self.isConfigLoaded_ = true
                        self.isConfigLoading_ = false
                        self.dirtyWordLib_ = tempDatas
		                self:dealMagicWords(self.dirtyWordLib_)
		                self:sortWords(self.dirtyWordLib_)
		                if self.loadGiftConfigCallback_ then
		                    self.loadGiftConfigCallback_(true, self.dirtyWordLib_)
		                end
                    else

                        if game.Bugly then
                            game.Bugly.reportLog("DirtyWordFilter:loadConfig_", "json.decode fail")
                        end
                        
                        self.logger:debug("loadConfigFunc failed => ")

                        self.isConfigLoaded_ = false
                        self.isConfigLoading_ = false

                        --删除缓存
                        if filePath and core.isFileExist(filePath) then
                            nb.FileUtils:getInstance():removeFile(filePath)
                        end

                        retryLimit = retryLimit - 1
                        if retryLimit > 0 then
                            self.schedulerPool_:delayCall(function()
                                loadConfigFunc()
                            end, 2)
                        else
                           if self.loadGiftConfigCallback_ then
                                self.loadGiftConfigCallback_(false)
                            end
                        end

                    end
                    
                else
                    self.logger:debug("loadConfigFunc failed => ")
                    self.isConfigLoaded_ = false
                    self.isConfigLoading_ = false

                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        self.schedulerPool_:delayCall(function()
                            loadConfigFunc()
                        end, 2)
                    else
                       if self.loadGiftConfigCallback_ then
                            self.loadGiftConfigCallback_(false)
                        end
                    end
                end
            end, "dirtylib")
        elseif self.isConfigLoaded_ then
             if self.loadGiftConfigCallback_ then
                self.loadGiftConfigCallback_(true, self.dirtyWordLib_)
            end
        end
    end

    loadConfigFunc()

end


function DirtyWordFilter:sortWords(tb)
	print("DirtyWordFilter:sortWords -- ")
	table.sort(tb, function(word1,word2)
		return string.utf8len(word1) > string.utf8len(word2)
	end )
end

function DirtyWordFilter:dealMagicWords(tb)
	for i,v in ipairs(tb) do
		tb[i] = string.gsub(v,MagicPatterns,"%%%1")
	end
end

--outStr,hasDirty
function DirtyWordFilter:runFilter(inStr)
	local outStr = inStr or ""
	local hasDirty = false
	if not outStr or outStr == "" then
		return outStr,hasDirty
	end

	if not self:isReady() then
		return outStr,hasDirty
	end
	
	for i,v in ipairs(self.dirtyWordLib_) do
		if v and v ~= "" then
			outStr = string.gsub(outStr,v,"**");
			--print_string("word: " .. v ..  " tempstr: " .. str);
		end
	end

	hasDirty = (outStr ~= inStr)
	return outStr,hasDirty;
end


return DirtyWordFilter
