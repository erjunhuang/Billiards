
--[[
    通用声音进入游戏预加载，不需释放
    房间声音进入房间预加载，退出房间释放
]]

local SoundManager = class("SoundManager")
local platform = "mp3" --去除ogg音效支持
local ClickSoundConfig = {
    [1] = "gamehall/res/audio/%s/button_click1.%s", --点击
    [2] = "gamehall/res/audio/%s/button_click2.%s", --关闭
    [3] = "gamehall/res/audio/%s/button_click3.%s", --取消
    [4] = "gamehall/res/audio/%s/button_click4.%s", --电梯叮叮叮
    [5] = "gamehall/res/audio/%s/gift.%s", --撒金币
}


function SoundManager:ctor()
    local lastVoice = nb.UserDefault:getInstance():getFloatForKey("VOICE_PERCENT",50)
    local lastMusic = nb.UserDefault:getInstance():getFloatForKey("MUSIC_PERCENT",50)
    self:updateSoundVolume(lastVoice)
    self:updateMusicVolume(lastMusic)
end

--预加载
function SoundManager:preload(soundName)
    audio.preloadSound(string.format(soundName, platform, platform))
end

function SoundManager:unload(soundName)
    audio.unloadSound(string.format(soundName, platform, platform))
end

function SoundManager:getFormatSoundPath(soundName, expath)
    local path = ""
    if expath == "common" then --common音效
        path = game.gameManager:getCurrentGameCommonResPath() .. "audio/%s/" .. soundName .. ".%s"
    elseif expath == nil then --游戏内音效(eg:douniu6p/res/audio/mp3/addCard.mp3, soundName:addCard)
        path = game.gameManager:getCurrentGameResPath() .. "audio/%s/" .. soundName .. ".%s"
    elseif type(expath) == "string" then --expath 左右不用带 /eg:hongzhongmj/res/MJ/audio/mp3/addCard.mp3, soundName:card_click, expath:MJ)
        path = game.gameManager:getCurrentGameResPath() .. expath .."/audio/%s/" .. soundName .. ".%s"
    end

    return string.format(path, platform, platform)
end

--音效(播放公共音效)
function SoundManager:playSound(soundName, expath, loop)
    if self.volume_sound <= 0 then return end
    if soundName == nil then
        return audio.playSound(string.format(ClickSoundConfig[1], platform, platform), loop or false)
    elseif type(soundName) == "number" then
        return audio.playSound(string.format(ClickSoundConfig[soundName], platform, platform), loop or false)
    else--游戏内音效
        return audio.playSound(self:getFormatSoundPath(soundName, expath), loop or false)
    end
end


function SoundManager:playSoundDirect(soundName,loop)
    audio.playSound(soundName, loop or false)
end

--音效(播放可能带有方言的音效,请自行理解)
function SoundManager:playSoundWithLocalism(soundName, expath, loop)
    if self.volume_sound <= 0 then return end
    local gameId = core.DataProxy:getData(game.dataKeys.GAME_ID)
    local lang = nb.UserDefault:getInstance():getStringForKey(string.format("LANGUAGE_%s", gameId))
    local path = ""
    if expath == nil then
        path = "audio/%s/" .. soundName .. ".%s"
    elseif type(expath) == "string" then
        path = expath .."/audio/%s/" .. soundName .. ".%s"
    end
    print("SoundManager:playSoundWithLocalism", tostring(lang))
    
    if not lang or lang == "" then  --默认语言设置
        local game_language = game.AllGames:getGameDataByGameId(gameId, "game_language")
        --方言选项为PutonghuaDefault时 表示该游戏有方言但是默认普通话
        --方言选项为FangyanDefault时 表示该游戏有方言没有普通话 但是音频文件路径是放在普通话下
        if game_language and game_language ~= "" and game_language ~= "PutonghuaDefault" and game_language ~= "FangyanDefault" then
            --方言
            local tmp = game.gameManager:getCurrentGameResPath() .. "localism/" .. path
            print("SoundManager:playSoundWithLocalism tmp", string.format(tmp, platform, platform))
            if nb.FileUtils:getInstance():isFileExist(string.format(tmp, platform, platform)) then
                path = tmp
            else
                path = game.gameManager:getCurrentGameResPath() .. path
            end
            print("SoundManager:playSoundWithLocalism path", tostring(path))
            --优化方案 第一次进来发觉有方言就默认方言 然后存储起来 下次就走lang不为空的部分(方言),防止每次都查游戏是否有方言
            nb.UserDefault:getInstance():setStringForKey(string.format("LANGUAGE_%s",gameId), game_language)  
        else
            --普通话
            path = game.gameManager:getCurrentGameResPath() .. path
            print("SoundManager:playSoundWithLocalism path", tostring(path))
            nb.UserDefault:getInstance():setStringForKey(string.format("LANGUAGE_%s",gameId), "Putonghua")  
        end
    elseif lang=="Putonghua" then   --普通话
        path = game.gameManager:getCurrentGameResPath() .. path
        print("SoundManager:playSoundWithLocalism path", tostring(path))
    else                            --方言
        local tmp = game.gameManager:getCurrentGameResPath() .. "localism/" .. path
        print("SoundManager:playSoundWithLocalism tmp", string.format(tmp, platform, platform))
        if nb.FileUtils:getInstance():isFileExist(string.format(tmp, platform, platform)) then
            path = tmp
        else
            path = game.gameManager:getCurrentGameResPath() .. path
        end
        print("SoundManager:playSoundWithLocalism path", tostring(path))
    end
     
    return audio.playSound(string.format(path, platform, platform), loop or false)
end

--音效(获取可能带有方言的音效全路径,请自行理解)
function SoundManager:getSoundWithLocalism(soundName, expath, loop)
    local gameId = core.DataProxy:getData(game.dataKeys.GAME_ID)
    local lang = nb.UserDefault:getInstance():getStringForKey(string.format("LANGUAGE_%s", gameId))
    local path = ""
    if expath == nil then
        path = "audio/%s/" .. soundName .. ".%s"
    elseif type(expath) == "string" then
        path = expath .."/audio/%s/" .. soundName .. ".%s"
    end
    
    if not lang or lang == "" then  --默认语言设置
        local game_language = game.AllGames:getGameDataByGameId(gameId, "game_language")
        --方言选项为PutonghuaDefault时 表示该游戏有方言但是默认普通话
        --方言选项为FangyanDefault时 表示该游戏有方言没有普通话 但是音频文件路径是放在普通话下
        if game_language and game_language ~= "" and game_language ~= "PutonghuaDefault" and game_language ~= "FangyanDefault" then
            --方言
            local tmp = game.gameManager:getCurrentGameResPath() .. "localism/" .. path
            if nb.FileUtils:getInstance():isFileExist(string.format(tmp, platform, platform)) then
                path = tmp
            else
                path = game.gameManager:getCurrentGameResPath() .. path
            end
            --优化方案 第一次进来发觉有方言就默认方言 然后存储起来 下次就走lang不为空的部分(方言),防止每次都查游戏是否有方言
            nb.UserDefault:getInstance():setStringForKey(string.format("LANGUAGE_%s",gameId), game_language)  
        else
            --普通话
            path = game.gameManager:getCurrentGameResPath() .. path
            nb.UserDefault:getInstance():setStringForKey(string.format("LANGUAGE_%s",gameId), "Putonghua")  
        end
    elseif lang=="Putonghua" then   --普通话
        path = game.gameManager:getCurrentGameResPath() .. path
    else                            --方言
        local tmp = game.gameManager:getCurrentGameResPath() .. "localism/" .. path
        if nb.FileUtils:getInstance():isFileExist(string.format(tmp, platform, platform)) then
            path = tmp
        else
            path = game.gameManager:getCurrentGameResPath() .. path
        end
    end
    return string.format(path, platform, platform)
end

--游戏内播放bgm
function SoundManager:justPlaySound(fullpath, loop)
    if self.volume_sound <= 0 then return end
    return audio.playSound(fullpath, loop or false)
end

--游戏内播放bgm
function SoundManager:playBGMForGame(bgm, loop)
    local audioID = audio.playMusic(string.format(bgm, platform, platform) , loop or false)
	self:updateMusicVolume(self.volume_music)
    return audioID
    
end


function SoundManager:stopMusic(isReleaseDataOrAudioId)
    audio.stopMusic(isReleaseDataOrAudioId)
end

--音效
function SoundManager:updateSoundVolume(volume)
    self.volume_sound = volume 
    audio.setSoundsVolume(self.volume_sound / 100)
end

--音乐
function SoundManager:updateMusicVolume(volume)
    self.volume_music = volume
    audio.setMusicVolume(self.volume_music / 100)
end

function SoundManager:getSoundsVolume()
    return audio.getSoundsVolume()
end

function SoundManager:getMusicVolume()
    return audio.getMusicVolume()
end


return SoundManager