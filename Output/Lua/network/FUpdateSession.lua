--filename: FUpdateSession.lua
--author: lidengfeng
--email: libyyu@qq.com
--time: 2017/2/19
--comment: 游戏更新处理类
local FNetwork = require "network.FNetwork"
local l_instance = nil
local FUpdateSession = FLua.Class("FUpdateSession", FNetwork)
do
	function FUpdateSession:_ctor()
		self.m_netName = "UpdateSession"
		self.m_DirInfo = nil
		self.m_isDone = false
	end
	function FUpdateSession.Instance()
		if not l_instance then
			l_instance = FUpdateSession.new()
		end
		return l_instance
	end

	function FUpdateSession:OnConnected()
		FNetwork.OnConnected(self)
		local msg = message_common_pb.DirInfo()
		self:SendPB(msg)
	end

	function FUpdateSession:OnGameData(buffer)
        local bytes = buffer:ReadBytes()
		--warn("FUpdateSession:OnGameData", GameUtil.ToHexString(bytes,","))
		local msg = self:BytesToMessage(LuaHelper.BytesToLuaString(bytes))
		self.m_DirInfo = msg.version
		self.m_isDone = true
	end

	function FUpdateSession:OnDisconnect(reason, err_msg)
		FNetwork.OnDisconnect(self, reason, err_msg)
		self.m_isDone = true
	end

	function FUpdateSession:IsDone()
		return self.m_isDone
	end
end

return FUpdateSession