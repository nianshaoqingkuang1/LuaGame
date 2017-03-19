local FUpdateSession = require "network.FUpdateSession"
local FGameUpdate = FLua.Class("FGameUpdate")
local l_instance = nil
do
    function FGameUpdate:_ctor()
        self.m_UpdateSession = nil
        self.m_UpdateFinished = false
    end
    function FGameUpdate.Instance()
        if not l_instance then
            l_instance = FGameUpdate.new()
        end
        return l_instance
    end
    function FGameUpdate:Init()
        self.m_UpdateSession = FUpdateSession.Instance()
        self.m_UpdateSession:InitNetwork()
    end
    function FGameUpdate:Finish()
    end

    function FGameUpdate:Run()
        self:Init()
        local c = coroutine.create(function()
            print ("检查更新中。。。")
            self.m_UpdateSession:ConnectTo("127.0.0.1", 8002)
            --while not self.m_UpdateSession:IsDone() do
            --    Yield(WaitForSeconds(0))
            --    print ("检查更新中。。。")
            --end
            Yield(WaitUntil(function()return self.m_UpdateSession:IsDone() end))
            self.m_UpdateFinished = true
            if not self.m_UpdateSession.m_DirInfo or #self.m_UpdateSession.m_DirInfo == 0 then
                warn("获取更新失败。。。")
            else
                warn("最新配置:", self.m_UpdateSession.m_DirInfo)
            end
        end)
        coroutine.resume(c)
    end
    function FGameUpdate:IsFinished()
        return self.m_UpdateFinished
    end
end

return FGameUpdate