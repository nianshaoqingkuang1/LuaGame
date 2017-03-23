--filename: FLogicSession.lua
--author: lidengfeng
--email: libyyu@qq.com
--time: 2017/2/19
--comment: 游戏逻辑网络处理类
local FNetwork = require "network.FNetwork"
local l_instance = nil
local FLogicSession = FLua.Class("FLogicSession", FNetwork)
do
	function FLogicSession:_ctor()
		self.m_UserInfo = nil
		self.m_netName = "LogicSession"
	end
	function FLogicSession.Instance()
		if not l_instance then
			l_instance = FLogicSession.new()
		end
		return l_instance
	end

	function FLogicSession:ConnectTo(ip,port,name,passwd)
		self.m_UserInfo = {name=name,passwd=passwd,}
		FNetwork.ConnectTo(self,ip,port)
	end

	function FLogicSession:OnConnected()
		FNetwork.OnConnected(self)
		local name = self.m_UserInfo.name
		local passwd = self.m_UserInfo.passwd
		local msg = Share_Common.Stuff_Account()
		--msg.type_t = Share_Common.Proto_Stuff_Account
		msg.UserName = name
		msg.PassWord = passwd
		self:SendPB(msg)
	end

	function FLogicSession:OnGameData(buffer)
		warn("FLogicSession:OnGameData",buffer)
		local id = buffer:ReadShort()
		local FPBHelper = require "pb.FPBHelper"
		local pb_class = FPBHelper.GetPbClass(id)
		if pb_class then
			local msg = pb_class()
			msg:ParseFromString(buffer:ReadBytesString())
			FireEvent(FPBHelper.GetPbName(pb_class),msg)
			warn("Receive PB:",pb_class,msg)
		else
			warn("unknow msg id:"..id)
		end
	end

	function FLogicSession:OnDisconnect(err_code, err_msg)
		local content = err_code == 0 and StringReader.Get(2) or StringReader.Get(1)
		MsgBox(self,content,reason,MsgBoxType.MBBT_OKCANCEL,function(_,ret)
			if ret == MsgBoxRetT.MBRT_OK then
				self:Connect()
			else
				local FLoadingUI = require "ui.FLoadingUI"
				FLoadingUI.Instance():ShowPanel(true)
			end
		end)
	end
end

return FLogicSession