local FUpdateSession = require "network.FUpdateSession"
local SLAXML = require "lib.SLAXML.slaxdom"
local FGameUpdate = FLua.Class("FGameUpdate")
local l_instance = nil
do
    local function parseVersion(content)
        local doc = SLAXML:dom(content)
        if not doc then return nil end
        local root = doc.root
        if not root then return nil end
        local result = {}
        result.project_name = root.attr.name
        local versioninfo = doc.root.el[1]
        result.program_version = versioninfo.attr.program_version
        result.resource_version = versioninfo.attr.resource_version
        result.resource_update = versioninfo.attr.resource_update
        result.skip_resourceupdate = versioninfo.attr.skip_resourceupdate
        result.package_url = versioninfo.attr.package_url

        return result
    end

    local function compareVersionString(versionA,versionB)
        local va = versionA:split(".")
        local vb = versionB:split(".")
        local localV1,localV2,localV3 = tonumber(va[1]),tonumber(va[2]),tonumber(va[3])
        local remoteV1,remoteV2,remoteV3 = tonumber(vb[1]),tonumber(vb[2]),tonumber(vb[3])
        if localV1 < remoteV1 then return -1 end
        if localV1 > remoteV1 then return 1 end
        if localV2 < remoteV2 then return -1 end
        if localV2 > remoteV2 then return 1 end
        if localV3 < remoteV3 then return -1 end
        if localV3 > remoteV3 then return 1 else
        return 0 end
    end

    function FGameUpdate:_ctor()
        self.m_UpdateSession = nil
        self.m_UpdateFinished = false
        self.m_LoaclVersion = nil
        self.m_RemoteVersion = nil
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
        self.m_LoaclVersion = parseVersion(content)
        if not self.m_LoaclVersion then
            error("can not get local-version.xml",1)
        end
    end

    function FGameUpdate:Run()
        self:Init()
        self.m_UpdateFinished = false
        local c = coroutine.create(function()
            self:UpdateDirCoroutine()
        end)
        coroutine.resume(c)
    end

    function FGameUpdate:UpdateDirCoroutine()
        print ("检查更新中。。。")
        self.m_UpdateSession:InitNetwork()
        self.m_UpdateSession:ConnectTo("127.0.0.1", 8002)

        Yield(WaitUntil(function()return self.m_UpdateSession:IsDone() end))
        self.m_UpdateSession:Close()

        if not self.m_UpdateSession.m_DirInfo or #self.m_UpdateSession.m_DirInfo == 0 then
            warn("获取更新失败。。。")
            MsgBox(self,StringReader.Get(5),"update",MsgBoxType.MBBT_OK,function(_,ret)
                if ret == MsgBoxRetT.MBRT_OK then
                    local c = coroutine.create(function()
                        self:UpdateDirCoroutine()
                    end)
                    coroutine.resume(c)
                end
            end)
        else
            self.m_RemoteVersion = parseVersion(self.m_UpdateSession.m_DirInfo) 
            self:UpdateCoroutineWithVersion()
        end
    end

    function FGameUpdate:UpdateCoroutineWithVersion()
        if not self.m_RemoteVersion then
            MsgBox(self,StringReader.Get(6),"update",MsgBoxType.MBT_INFO)
        elseif self.m_LoaclVersion.project_name ~= self.m_RemoteVersion.project_name then
            MsgBox(self,StringReader.Get(7),"update",MsgBoxType.MBT_INFO)
        elseif compareVersionString(self.m_LoaclVersion.resource_version, self.m_RemoteVersion.resource_version) < 0 then
            warn("localversion:",self.m_LoaclVersion.resource_version, "remote-version",self.m_RemoteVersion.resource_version)
            MsgBox(self,StringReader.Get(8),"update",MsgBoxType.MBBT_OKCANCEL,function(_,ret)
                if ret == MsgBoxRetT.MBRT_OK then
                    warn("准备下载更新资源")
                    self:Finish()
                end
            end)
            --self:Finish()
        end
    end

    function FGameUpdate:Finish()
        self.m_UpdateSession:FinishWorking()
        self.m_UpdateFinished = true
    end

    function FGameUpdate:IsFinished()
        return self.m_UpdateFinished
    end
end

return FGameUpdate