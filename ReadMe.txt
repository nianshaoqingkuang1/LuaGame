public delegate void UnityLogDelegate(LogType logType,string log);

[DllImport(“FengEngine”)
public extern static void FLua_InitLog(UnityLogDelegate func);

[AOT.MonoPInvokeCallback(typeof(UnityLogDelegate))]
private void onUnityLog(LogType logType,string log)
{
}

//NOTE:
//初次checkout,请用update-submodule更新外链Arts和ShareCode