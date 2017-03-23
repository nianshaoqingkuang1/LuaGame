local FUpdateSession = require "network.FUpdateSession"
local SLAXML = require "lib.SLAXML.slaxdom"
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

        local version_path = "Configs/local-version.xml"
        local content = ReadFileContent(version_path)
        print(content)
    end
    function FGameUpdate:Finish()
        self.m_UpdateFinished = true
    end

    local function parseVersion(content)
        local doc = SLAXML:dom(content)
        print(doc.root.attr.name)
        print (doc.root.el[1].name)
        return doc
    end

    function FGameUpdate:Run()
        self:Init()
        self.m_UpdateFinished = false
        local c = coroutine.create(function()
            print ("检查更新中。。。")
            self.m_UpdateSession:ConnectTo("127.0.0.1", 8002)

            Yield(WaitUntil(function()return self.m_UpdateSession:IsDone() end))
            self.m_UpdateSession:FinishWorking()
            
            if not self.m_UpdateSession.m_DirInfo or #self.m_UpdateSession.m_DirInfo == 0 then
                warn("获取更新失败。。。")
            else
                local doc = parseVersion(self.m_UpdateSession.m_DirInfo) 
                print (doc)
            end
            self:Finish()
        end)
        coroutine.resume(c)
    end

    function FGameUpdate:IsFinished()
        return self.m_UpdateFinished
    end
end

return FGameUpdate