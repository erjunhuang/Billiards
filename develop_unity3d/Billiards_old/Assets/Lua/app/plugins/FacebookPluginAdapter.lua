
local FacebookPluginAdapter = class("FacebookPluginAdapter")
local apki = 0
function FacebookPluginAdapter:ctor()
    self.schedulerPool_ = core.SchedulerPool.new()
    self.cacheData_ = {}   
end

function FacebookPluginAdapter:login(callback)
    self.loginCallback_ = callback
    local sso = false
    local function loginResult()
        if self.loginCallback_ then

            local result = nil
            
            -- local result1 = "CAAU3r9BIvEIBALFaiEYwtFyXgEBDj1JdnZCmwYDYVQqhtGzMqSnCHaim3lxw1cLt3pffcgMYZB0R6VgvtKCpjo7YEMgUt3fropP4FnUnGkmPySCnjrZCdfn2ttOOxJ49EY5M6AGtJ4OSZBPtFEG0DDkNSRJYDKfzSuAIdURQqwLXMUGC6QKziwrZAtM1hLNhBb62mUZCyY0QZDZD"  -- Unused
            -- local result2 = "CAAU3r9BIvEIBALFaiEYwtFyXgEBDj1JdnZCmwYDYVQqhtGzMqSnCHaim3lxw1cLt3pffcgMYZB0R6VgvtKCpjo7YEMgUt3fropP4FnUnGkmPySCnjrZCdfn2ttOOxJ49EY5M6AGtJ4OSZBPtFEG0DDkNSRJYDKfzSuAIdURQqwLXMUGC6QKziwrZAtM1hLNhBb62mUZCyY0QZDZD"  -- Unused
            -- apki = apki + 1
            -- result = result1
            -- if apki % 2 == 0 then
            --     result = result2
            -- end

            result = "EAAGtnrf8V5YBAC9lSMpP5mgbX2J5TylZC7ZCA6hA22ydLzROBkZBJ8ZBo6LeeocoDhc9QiEcUypPEH4DVzhcMQx56eECuVNLfi9mjwZAU7bJT1em6IClA1wbfdNPbY0NsIOPDBQZBTaMQkMhD4AxMILebqpyaos6gzZBJexWAPy4EcKD1L1FD4nljc3qZAo21NkKQtbHIpGNnK1QbZAidDp96WRolBQEg5ekZD"  -- Mine
            local success = (result ~= "canceled" and result ~= "failed")
            if self.loginCallback_ then
                self.loginCallback_(success, result)
            end
        end
    end
    if sso then
        self.schedulerPool_:delayCall(loginResult, 1)
    else
        loginResult()
    end
end

function FacebookPluginAdapter:updateAppRequest()
end

function FacebookPluginAdapter:getInvitableFriends(callback)
    if callback then
        callback(true, {
                {name="a1",url=""},{name="a2",url="",id=2},{name="a3",url="",id=2},{name="a4",url="",id=2},{name="a5",url=""},
                {name="a6",url=""},{name="a7",url=""},{name="a8",url=""},{name="a9",url=""},{name="a10",url=""},
                {name="a11",url=""},{name="a12",url=""},{name="a13",url=""},{name="a14",url=""},{name="a15",url=""},
                {name="a16",url=""},{name="a17",url=""},{name="a18",url=""},{name="a19",url=""},{name="a20",url=""},
                {name="a21",url=""},{name="a22",url=""},{name="a23",url=""},{name="a24",url=""},{name="a25",url=""},
                {name="a26",url=""},{name="a27",url=""},{name="a28",url=""},{name="a29",url=""},{name="a30",url=""},
                {name="a31",url=""},{name="a32",url=""},{name="a33",url=""},{name="a34",url=""},{name="a35",url=""},
                {name="a36",url=""},{name="a37",url=""},{name="a38",url=""},{name="a39",url=""},{name="a1=40",url=""},
                {name="a41",url=""},{name="a42",url=""},{name="a43",url=""},{name="a44",url=""},{name="a45",url=""},
                {name="a46",url=""},{name="a47",url=""},{name="a48",url=""},{name="a49",url=""},{name="a50",url=""},
                {name="a51",url=""},{name="a52",url=""},{name="a53",url=""},{name="a54",url=""},{name="a55",url=""},
            })
    end
end


function FacebookPluginAdapter:sendInvites( ... )
    do return end
end

function FacebookPluginAdapter:logout()
    self.cacheData_ = {}
end

function FacebookPluginAdapter:shareFeed(params, callback)
    print("shareFeed ", json.encode(params))
end

return FacebookPluginAdapter