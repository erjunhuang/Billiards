local ServerConfig = {}




ServerConfig.getReorderTb = function(tb)
	local outTb = {}
	for _, v in pairsByKeys(tb) do      
	 	table.insert(outTb,v)
	end
	return outTb
end

ServerConfig.setConfig = function(serverTb)
	--避免php传的非数组，兼容处理下
	serverTb = ServerConfig.getReorderTb(serverTb)
	ServerConfig.serverTb = serverTb
end

ServerConfig.setChatSerConfig = function(serverTb)
	serverTb = ServerConfig.getReorderTb(serverTb)
	ServerConfig.chatServerTb = serverTb
end

ServerConfig.getNormalRandomHost = function()
	if not ServerConfig.serverTb then
		return
	end

	local serverNum = #ServerConfig.serverTb
	local firstHalf = {1,math.floor(serverNum/2)}
	math.randomseed(os.time())
	local idx = math.random(firstHalf[1],firstHalf[2])
	local tser = ServerConfig.serverTb[idx]
	local tserTb = string.split(tser,":")
	return tserTb[1],tserTb[2]
end


ServerConfig.getHighDefenseRandomHost = function( ... )
	if not ServerConfig.serverTb then
		return
	end

	local serverNum = #ServerConfig.serverTb
	local firstHalf = {1,math.floor(serverNum/2)}
	local secondHalf = {firstHalf[2]+1,serverNum}
	math.randomseed(os.time())
	local idx = math.random(secondHalf[1],secondHalf[2])
	local tser = ServerConfig.serverTb[idx]
	local tserTb = string.split(tser,":")
	return tserTb[1],tserTb[2]
end


ServerConfig.getChatNormalRandomHost = function(roomCode)
	if (not ServerConfig.chatServerTb) or (not roomCode) then
		return
	end

	local serverNum = #ServerConfig.chatServerTb
	if serverNum == 0 then
		return
	end
	local idx = roomCode%serverNum
	if idx == 0 then
		idx = serverNum
	end
	local tser = ServerConfig.chatServerTb[idx]
	local tserTb = string.split(tser,":")
	return tserTb[1],tserTb[2]
end




return ServerConfig