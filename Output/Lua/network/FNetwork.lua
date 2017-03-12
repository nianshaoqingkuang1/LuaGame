--filename: FNetwork.lua
--author: lidengfeng
--email: libyyu@qq.com
--time: 2017/2/19
--comment: 网络处理基础类
local FNetwork = FLua.Class("FNetwork")
do
	function FNetwork:_ctor(name)
		self.m_GoNetwork = nil
		self.m_Network = nil
		self.m_status = "broken"
		self.m_netName = name
	end

	function FNetwork:InitNetwork()
		self.m_GoNetwork = NewGameObject(self.m_netName)
		self.m_Network = self.m_GoNetwork:AddComponent(NetworkManager)
		self.m_Network:SetMsgHandle(self)
		DontDestroyOnLoad(self.m_GoNetwork)
	end

	function FNetwork:Connect()
		if self:isConnected() then
			warn(self.m_netName ..".Connect: Already Connected, Can not link again.")
			return
		elseif self.m_status == "connecting" then
			warn(self.m_netName .. ".Connect: Now is connecting, please waiting.")
			return
		end
		warn(self.m_netName .. ".Connect To " .. self.m_ip .. ":" .. self.m_port )
		self.m_status = "connecting"
		self.m_Network:ConnectTo(self.m_ip,self.m_port)
	end

	function FNetwork:ConnectTo(ip,port)
		self.m_ip = ip
		self.m_port = port
		self:Connect()
	end

	function FNetwork:isConnected()
		return self.m_status == "connected" and self.m_Network and not self.m_Network.isNil and self.m_Network.IsConnected
	end

	function FNetwork:Close()
		self.m_Network:Close()
		self.m_status = "broken"
	end

	function FNetwork:Release()
		self:Close()
		DestroyObject(self.m_GoNetwork)
		self.m_GoNetwork = nil
		self.m_Network = nil
	end

	function FNetwork:Ping(ip)
		self.m_Network:Ping(ip)
	end

	function FNetwork:Send(bytes)
		return self.m_Network:SendMessage(bytes)
	end

	function FNetwork:SendPB(pb_msg)
		local FPBHelper = require "pb.FPBHelper"
		local pb_class = pb_msg:GetMessage()
		local id = FPBHelper.GetPbId(pb_class)
		if id then
			local msgbuf = pb_msg:SerializeToString();
			local count = self.m_Network:SendPbMessage(msgbuf)
		    warn("send bytes-count:",count, ", content:", pb_msg)

		    local buffer = NewByteBuffer()
		    buffer:WriteBytesString(msgbuf)
		    local bytes = buffer:ToBytes()
		    buffer:Close()
		    buffer = NewByteBuffer(bytes)
		    bytes = buffer:ReadBytes()
		    buffer:Close()
		    warn("Send bytes:", GameUtil.ToBytesString(bytes, ","))
		else
			warn("Can not GetPbId pb_class:",pb_class)
		end
	end

	function FNetwork:OnConnected()
		warn(self.m_netName .. ".OnConnected")
		self.m_status = "connected"
	end

	function FNetwork:OnTimeout()
		warn(self.m_netName .. ".OnTimeout")
		self.m_status = "broken"
		local content = StringReader.Get(3)
		MsgBox(self,content,"timeout",MsgBoxType.MBBT_OKCANCEL,function(_,ret)
			if ret == MsgBoxRetT.MBRT_OK then
				self:Connect()
			end
		end)
	end

	function FNetwork:OnDisconnect(reason, err_msg)
		warn(self.m_netName .. ".OnDisconnect reason="..reason .. ",err_msg="..err_msg)
		self.m_status = reason
	end

	function FNetwork:OnPing(buffer)
		local text = buffer:ReadString()
		warn(text)
	end

	function FNetwork:OnReceiveMessage(protocal,buffer)
		warn(self.m_netName .. ".OnReceiveMessage", protocal, buffer)
		local Protocal = FGame.Protocal
		if protocal == Protocal.Connect then
			self:OnConnected()
		elseif protocal == Protocal.Exception then
			self:OnDisconnect("broken", buffer:ReadString())
		elseif protocal == Protocal.Disconnect then
			self:OnDisconnect("disconnect", buffer:ReadString())
		elseif protocal == Protocal.Timeout then
			self:OnTimeout()
		elseif protocal == Protocal.Ping then
			self:OnPing(buffer)
		elseif protocal == Protocal.GameData then
			self:OnGameData(buffer)
		end
	end

	function FNetwork:OnGameData(buffer)
	end
end

return FNetwork