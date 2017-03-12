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
	end
	function FUpdateSession.Instance()
		if not l_instance then
			l_instance = FUpdateSession.new()
		end
		return l_instance
	end

	function FUpdateSession:OnConnected()
		FNetwork.OnConnected(self)
		local buffer = NewByteBuffer()
		buffer:WriteBytesString("Hello\n")
		local bytes = buffer:ToBytes()
		buffer:Close()
        self:Send(bytes)
	end

	function FUpdateSession:OnGameData(buffer)
        local bytes = buffer:ReadBytes()
        warn("bytes", bytes)
		warn("FUpdateSession:OnGameData", LuaHelper.BytesToString(bytes))
	end

	function FUpdateSession:OnDisconnect(reason, err_msg)
		FNetwork.OnDisconnect(self, reason, err_msg)
		local content = reason == "broken" and StringReader.Get(1) or StringReader.Get(2)
		MsgBox(self,content,reason,MsgBoxType.MBBT_OKCANCEL,function(_,ret)
			if ret == MsgBoxRetT.MBRT_OK then
				self:Connect()
			end
		end)
	end
end

return FUpdateSession