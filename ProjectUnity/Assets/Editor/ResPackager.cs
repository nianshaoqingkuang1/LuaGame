#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityLog = UnityEngine.Debug;

public class ExInputWindow : EditorWindow
{
    static ExInputWindow window;
    static string szLabelTitle;
    static string szInput;
    static System.Action<string> cb;
    public static void Open(System.Action<string> _cb,string _szLabelTitle = "Input",string _szInput = "")
    {
        cb = _cb;
        szLabelTitle = _szLabelTitle;
        szInput = _szInput;
        window = EditorWindow.GetWindowWithRect<ExInputWindow>(new Rect(Screen.width / 2, Screen.height / 2, 260, 50));
        window.title = "InputWindow";
        window.ShowPopup();
    }
    void OnDestroy()
    {
        window = null;
    }

    void OnGUI()
    {
        GUI.Label(new Rect(20,12,40,20),szLabelTitle);
        szInput = GUI.TextField(new Rect(60,10,150,24),szInput);
        if(GUI.Button(new Rect(215,10,40,24),"Enter"))
        {
            window.Close();
            if (cb != null)
            {
                cb(szInput);
            }           
        }
    }
}

public class Packager {
        
	[MenuItem("Pack Assets/步骤1.打包AssetBundle", false, 11)]
	public static void ExportAllAssets()
	{
		string dst_path = Application.dataPath + "/../../Output/StreamingAssets";

		BuildTarget target = EditorUserBuildSettings.activeBuildTarget;
		UnityLog.Log(string.Format("打包资源到目录:{0},平台:{1}", dst_path, target.ToString()));

		if (!Directory.Exists(dst_path))
			Directory.CreateDirectory(dst_path);

		BuildPipeline.BuildAssetBundles(dst_path, BuildAssetBundleOptions.None, target);

		AssetDatabase.Refresh();
		UnityLog.Log("AssetBundle打包完成");
	}

	[MenuItem("Pack Assets/步骤2.打成一个Zip包", false, 12)]
	public static void PackUnityRes()
	{
		string dst_res = Application.dataPath +  "/res_base/StreamingAssets/data.zip";

		string src_res = GetResourceSrcPath();

		string src_export = src_res;
		//剔除manifest        
		foreach (string filename in Directory.GetFiles(src_export, "*.manifest", SearchOption.AllDirectories))
		{
			File.Delete(filename);
		}
		UnZipUtil.XSharpUnZip.ZipDirectory(dst_res, src_export, UnZipUtil.XSharpUnZip._password);

		UnityLog.Log("Zip包自作完成,path=" + dst_res);
		AssetDatabase.Refresh();
	}


    [MenuItem("Assets/Bundle Name/Attach", false, 15)]
    public static void SetAssetBundleName()
    {
        System.Action<string> cb = (str) =>
        {
            string name = str;
			if (!string.IsNullOrEmpty(name) && !name.EndsWith(FGame.Manager.ResourceManager.assetExt))
				name = name + FGame.Manager.ResourceManager.assetExt;

            Object[] SelectedAsset = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);

            AssetImporter import = null;
            foreach (Object s in SelectedAsset)
            {
                string sp = AssetDatabase.GetAssetPath(s);
                string abName = sp.ToLower().Replace("\\", "/");//.Replace("assets/", "");
               
                import = AssetImporter.GetAtPath(sp);
				import.assetBundleName = name!=null ? name : abName + FGame.Manager.ResourceManager.assetExt;
            }
            AssetDatabase.Refresh();
        };
        //ExInputWindow.Open(cb);     
        cb(null);   
    }

    [MenuItem("Assets/Bundle Name/Detah", false, 16)]
    public static void ClearAssetBundleName()
    {
        Object[] SelectedAsset = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);

        AssetImporter import = null;
        foreach (Object s in SelectedAsset)
        {
            import = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(s));
            import.assetBundleName = null;
        }
        AssetDatabase.Refresh();
    }

    static void _CreateAssetBunldesMain(string targetPath)
    {
#if !UNITY_5
        Object[] SelectedAsset = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        foreach (Object obj in SelectedAsset)
        {
            if (BuildPipeline.BuildAssetBundle(obj, null, (targetPath + obj.name + ".assetbundle").ToLower(), BuildAssetBundleOptions.CollectDependencies))
            {
                UnityLog.Log(obj.name + "is build success.");
            }
            else
            {
                UnityLog.Log(obj.name + "is build failure.");
            }
        }
        AssetDatabase.Refresh();
#else
        System.Action<string> cb = (str) =>
        {
            string name = str;
			if (!string.IsNullOrEmpty(name) && !name.EndsWith(FGame.Manager.ResourceManager.assetExt))
				name = name + FGame.Manager.ResourceManager.assetExt;
			name = name != null ? name : FGame.Manager.ResourceManager.assetDir + FGame.Manager.ResourceManager.assetExt;
            Object[] SelectedAsset = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
            HashSet<string> assetList = new HashSet<string>();
            //Dictionary<string, HashSet<string>> allBundles = new Dictionary<string, HashSet<string>>();
            foreach (Object obj in SelectedAsset)
            {
                string assetPath = AssetDatabase.GetAssetPath(obj);
                //AssetImporter import = AssetImporter.GetAtPath(assetPath);
                //if (!string.IsNullOrEmpty(import.assetBundleName))
                //{
                //    if (allBundles.ContainsKey(import.assetBundleName))
                //        allBundles[import.assetBundleName].Add(assetPath);
                //    else
                //        allBundles.Add(import.assetBundleName, new HashSet<string>() { assetPath });
                //}

                assetList.Add(assetPath);
            }
            List<string> tempList = new List<string>();
            tempList.AddRange(assetList);
            string[] buildList = tempList.ToArray();// AssetDatabase.GetDependencies(tempList.ToArray());
            AssetBundleBuild build = new AssetBundleBuild();
            build.assetBundleName = name;
            build.assetNames = buildList;
            
            BuildAssetBundleOptions options = BuildAssetBundleOptions.DeterministicAssetBundle |
                                          BuildAssetBundleOptions.UncompressedAssetBundle;
            BuildPipeline.BuildAssetBundles(targetPath, new AssetBundleBuild[] { build }, options, EditorUserBuildSettings.activeBuildTarget);
            AssetDatabase.Refresh();
            UnityLog.Log(name + "is build success.");
        };
        ExInputWindow.Open(cb);
#endif
    }

    [MenuItem("Assets/Create AssetBunldes Main")]
    static void CreateAssetBunldesMain()
    {
        string dst_path = EditorUtility.OpenFolderPanel("Build Assets ", "Assets/StreamingAssets/", "");
        if (dst_path.Length == 0)
            return;

        dst_path += "/StreamingAssets/" + GameUtil.GetPlatformFolderForAssetBundles()+ "/StreamingAssets/";
        if (!Directory.Exists(dst_path))
            Directory.CreateDirectory(dst_path);
        _CreateAssetBunldesMain(dst_path);
    }
    
    static string GetLuaSrcPath()
    {
        string appPath = Application.dataPath.ToLower();
        return appPath.Replace("assets", "") + "../Output/Lua/";
    }
    static string GetResourceSrcPath()
    {
        string appPath = Application.dataPath.ToLower();
        return appPath.Replace("assets", "") + "../Output/";
    }

    public static void cleanMeta(string path)
    {
        string[] names = Directory.GetFiles(path);
        string[] dirs = Directory.GetDirectories(path);
        foreach (string filename in names)
        {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta"))
            {
                File.Delete(@filename);
            }

            foreach (string dir in dirs)
            {
                cleanMeta(dir);
            }
        }
    }

    static void CopyDirTo(string src,string dst,bool delete = false)
    {
        string[] fileTempList = Directory.GetFiles(src, "*.*", SearchOption.AllDirectories);
        foreach(string s in fileTempList)
        {
            if (!s.EndsWith(".meta"))
            {
                string fileName = s.Replace(src, "");
                string outFile = Path.Combine(dst, fileName);
                string dir_path = Path.GetDirectoryName(outFile);
                if (!Directory.Exists(dir_path))
                    Directory.CreateDirectory(dir_path);
                File.Copy(s, outFile,true);

                if(delete)
                {
                    File.Delete(s);
                }
            }
        }
    }
}
#endif