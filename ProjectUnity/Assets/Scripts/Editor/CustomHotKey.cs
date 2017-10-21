#if UNITY_EDITOR
using System;
using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
using System.Text;

public class CustomHotKey : MonoBehaviour
{
	[MenuItem("CustomHotKey/ToggleActivie &v")]
	public static void ToggleActive()
	{
		foreach (var obj in Selection.gameObjects)
		{
			obj.SetActive(!obj.activeSelf);
		}
	}

	[MenuItem("CustomHotKey/TogglePause &p")]
	public static void TogglePause()
	{
		EditorApplication.isPaused = !EditorApplication.isPaused;
	}

	[MenuItem("CustomHotKey/SaveProject &s")]
	public static void SaveAssets()
	{
		AssetDatabase.SaveAssets();
		Debug.Log("Project Saved.");
	}

	[MenuItem("CustomHotKey/ApplyPrefab &a")]
	public static void ApplyPrefab()
	{
		foreach (var obj in Selection.gameObjects)
		{
			var prefabParent = PrefabUtility.GetPrefabParent(obj);
			if (prefabParent != null)
                PrefabUtility.ReplacePrefab(PrefabUtility.FindPrefabRoot(obj), prefabParent, ReplacePrefabOptions.ConnectToPrefab);
		}
	}

	[MenuItem("CustomHotKey/Open Containing Folder &o")]
	public static void OpenContainingFolder()
	{
#if UNITY_EDITOR_WIN
		//var path = Path.Combine(Path.Combine(Application.dataPath, ".."), AssetDatabase.GetAssetPath(Selection.activeObject));
        
		//ShowSelectedInExplorer.FilesOrFolders(path);
#else
		Debug.LogWarning("not supported on current platform");
#endif
	}

	//这里有bug
	[MenuItem("Test/Writer")]
	static void Test()
	{
		//写法2
		StreamWriter file = new StreamWriter("1.txt", false, Encoding.UTF8);
		file.WriteLine ("aaa");

		StreamWriter file2 = new StreamWriter("2.txt", false, Encoding.UTF8);
		file2.WriteLine ("bbb");
		file2.Close ();

		file.WriteLine ("ccc");
		file.Close ();

	}
}
#endif