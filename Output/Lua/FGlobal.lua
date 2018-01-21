import "UnityEngine"

ResourceManager = FGame.ResourceManager
NetworkManager = FGame.NetworkManager
ByteBuffer = FGame.ByteBuffer
LuaBehaviour = FGame.LuaBehaviour

GameObject = UnityEngine.GameObject
Vector2 = UnityEngine.Vector2
Vector3 = UnityEngine.Vector3
Quaternion = UnityEngine.Quaternion

function OnUnityLog(t,str)
	local game = require "game.FGame"
	game.Instance():OnUnityLog(t,str)
	--theGame:OnUnityLog(t,str)
end

function OnHotKeyCodeMap()
	return {
		KeyCode.Tab,
		KeyCode.Escape,
		KeyCode.UpArrow,
		KeyCode.DownArrow,
		KeyCode.RightArrow,
		KeyCode.LeftArrow,
		KeyCode.Return,
	}
end

function OnHotKeyInput( key, down )
	local KeyCode = UnityEngine.KeyCode
	if key == KeyCode.Tab and down then
		theGame:ToggleConsole()
	elseif key == KeyCode.Escape then
		theGame:ForceCloseConsole()
	elseif key == KeyCode.UpArrow then
		print(".........")
		if theGame.m_HostPlayer then
			theGame.m_HostPlayer:Play("Run",UnityEngine.WrapMode.Loop)
		end
	elseif key == KeyCode.DownArrow then
		if theGame.m_HostPlayer then
			theGame.m_HostPlayer:Play("Skill",UnityEngine.WrapMode.Once)
		end
	elseif key == KeyCode.RightArrow and down then
		if theGame.m_HostPlayer then
			theGame.m_HostPlayer:Play("Skill",UnityEngine.WrapMode.Once)
		end
	elseif key == KeyCode.Return then
		if theGame.m_HostPlayer then
			theGame.m_HostPlayer:Play("Idle",UnityEngine.WrapMode.Loop)
		end
	end
end

function AsyncLoad(assetBundleName,assetName,cb)
	if type(assetName) ~= "string" then
		error(("argument #%d expected string, but got %s"):format(2, type(assetName)))
	end
	local FAssetBundleUtil = require "utility.FAssetBundleUtil"
	FAssetBundleUtil.Instance():AsyncLoad(assetBundleName,{assetName},function(objs)
		cb(objs[1])
	end)
end

function AsyncLoadArray(assetBundleName, assetNames, cb)
	if type(assetName) ~= "table" then
		error(("argument #%d expected table, but got %s"):format(2, type(assetName)))
	end
	local FAssetBundleUtil = require "utility.FAssetBundleUtil"
	FAssetBundleUtil.Instance():AsyncLoad(assetBundleName,assetNames,cb)
end

function UnloadAssetBundle(assetBundleName,unload)
	local FAssetBundleUtil = require "utility.FAssetBundleUtil"
	FAssetBundleUtil.Instance():UnloadAssetBundle(assetBundleName,unload)
end

function MsgBox(hwnd,content,title,mask,click_cb)
	local FMsgBoxMan = require "manager.FMsgBoxMan"
	FMsgBoxMan.Instance():ShowMsgBox(hwnd,content,title,mask,click_cb)
end

function AddEvent(obj, ...)
	theGame.m_LogicEvent:AddEvent(obj,...)
end

function DelEvent(obj,...)
	theGame.m_LogicEvent:DelEvent(obj,...)
end

function FireEvent(eventname,...)
	theGame.m_LogicEvent:Fire(eventname,...)
end

function NewGameObject(name)
	if type(name) == "string" then
		return GameObject(name)
	elseif not name then
		return GameObject()
	else
		error("constructor GameObject param 1 is expected nil or string")
	end
end

function Instantiate(go,name)
	local obj = UnityEngine.Object.Instantiate(go)
	if type(name) == "string" then
		obj.name = name
	end
	return obj
end

function DestroyObject(go)
	UnityEngine.Object.Destroy(go)
end

function DontDestroyOnLoad(go)
	UnityEngine.Object.DontDestroyOnLoad(go)
end

function Table2String(tab)
    local str = {}
    local function internal(tab, str, indent)
        for k,v in pairs(tab) do
            if type(v) == "table" then
                table.insert(str, indent.."["..tostring(k).."]="..":\n")
                internal(v, str, indent..' ')
            else
                table.insert(str, indent..tostring(k).."="..tostring(v).."\n")
            end
        end
    end

    internal(tab, str, '')
    return table.concat(str, '')
end

function PrintTable(t)
	local str = Table2String(t)
	print(str)
end

function string:split(sep)
	local sep, fields = sep or ",", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) table.insert(fields, c) end)
	return fields
end

function NewByteBuffer(data)
	if not data then
		return ByteBuffer()
	else
		return ByteBuffer(data)
	end
end

function ReadFileContent(filename)
	local buff
	if GameUtil.CanSepAssets and GameUtil.IsAssetFileExists(GameUtil.SepPath.."/"..filename) then
		buff = GameUtil.ReadAssetFile(GameUtil.SepPath.."/"..filename)
	elseif GameUtil.IsAssetFileExists(GameUtil.AssetRoot.."/"..filename) then
		buff = GameUtil.ReadAssetFile(GameUtil.AssetRoot.."/"..filename)
	else
		buff = GameUtil.ReadAssetFile(GameUtil.BaseStreamAssetPath.."/res_base/"..filename)
	end
	if buff then
		return LuaHelper.BytesToLuaString(buff)
	else
		return nil
	end
end
