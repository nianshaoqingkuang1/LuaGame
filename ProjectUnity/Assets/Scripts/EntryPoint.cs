using UnityEngine;
using System.Collections;
using SLua;
using System.IO;
using FGame;
using System;
using System.Collections.Generic;

public class EntryPoint : PersistentSingleton<EntryPoint>
{
    public string EntryLuaScript = string.Empty;
	public LuaSvrFlag SrvFlag = LuaSvrFlag.LSF_BASIC;
    public LogUtil.LogLevel logLevel = LogUtil.LogLevel.Info;
 
    private LuaSvr lua = null;

    IEnumerator onReStart(Action cb)
    {
        yield return new WaitForEndOfFrame();
        if (null != cb)
            cb();
        yield return new WaitForEndOfFrame();
        Cleanup();
        yield return new WaitForEndOfFrame();
        if (null != lua)
        { lua.Close(); lua = null; }
        yield return new WaitForEndOfFrame();
        DG.Tweening.DOTween.KillAll(true);
        DG.Tweening.DOTween.ClearCachedTweens();
        DG.Tweening.DOTween.Clear(true);
        yield return new WaitForEndOfFrame();
        GameObject[] allObj = Transform.FindObjectsOfType<GameObject>();
        for (int i=0;i<allObj.Length;++i)
        {
            if(allObj[i] != gameObject)
            {
                GameObject.Destroy(allObj[i]);
            }
        }
        yield return new WaitForEndOfFrame();
        RunApp();
    }

    public void ReStart(Action cb)
    {
        StartCoroutine(onReStart(cb));
    }

    void RunApp()
    {
		SetupPath();
        SetupEnvironment();
        SetupLua();
    }

    void SetupEnvironment()
    {
        LogUtil.loglevel = logLevel;
        LogUtil.AttachUnityLogHandle();
        LogFile.Instance.Init();        
    }

    void SetupPath()
    {
		LogUtil.Log("dataPath:" + Application.dataPath);
		LogUtil.Log("resBasePath:" + GameUtil.BaseStreamAssetPath);
        LogUtil.Log("AssetRoot:" + GameUtil.AssetRoot);
        LogUtil.Log("AssetsPath:" + GameUtil.AssetPath);
        LogUtil.Log("LuaPath:" + GameUtil.LuaPath);
        LogUtil.Log("PckPath:" + GameUtil.SepPath);
		LogUtil.Log("TempPath:" + Application.temporaryCachePath);
    }

    void SetupLua()
    {
        LuaState.loaderDelegate = loadLuaFile;
        lua = new LuaSvr();
        lua.init(null, () =>
        {
            if (string.IsNullOrEmpty(EntryLuaScript))
                return;
			lua.start(EntryLuaScript);
        }, SrvFlag);        
    }
		
    byte[] loadLuaFile(string f)
    {
        string luafilepath = GameUtil.MakePathForLua(f);
        try
        {
            FileStream fs = File.Open(luafilepath, FileMode.Open);
            long length = fs.Length;
            byte[] bytes = new byte[length];
            fs.Read(bytes, 0, bytes.Length);
            fs.Close();

            return bytes;
        }
        catch (Exception)
        {
            return null;
        }
    }

    protected override void Awake()
    {
        base.Awake();
        RunApp();
    }
#if TEST_EASYSOCKET
    SuperSocket.ClientEngine.FTestSuperSocket testSocket;
#endif
    // Use this for initialization
    void Start () {
#if TEST_EASYSOCKET
        testSocket = new SuperSocket.ClientEngine.FTestSuperSocket();
        testSocket.ConnectTo("127.0.0.1", 3001);
#endif
    }

    // Update is called once per frame
    void Update () {

	}

    void Cleanup()
    {
        LogUtil.DetachUnityLogHandle();
        LogFile.Instance.UnInit();
    }

    protected override void OnDestroy()
    {
        Cleanup();
        base.OnDestroy();
    }

    void OnApplicationPause()
    {
        if (null == lua || null == lua.luaState)
            return;
        LuaState l = lua.luaState;
        LuaFunction func = l.getFunction("OnApplicationPause");
        if (null != func)
        {
            func.call();
            func.Dispose();
        }
        else
        {
            //LogUtil.Log("OnApplicationPause");
        }
    }

    void OnApplicationQuit()
    {
        if (null == lua || null == lua.luaState)
            return;
        LuaState l = lua.luaState;
        LuaFunction func = l.getFunction("OnApplicationQuit");
        if (null != func)
        {
            func.call();
            func.Dispose();
        }
        else
        {
            //LogUtil.Log("OnApplicationQuit");
        }
    }
}
