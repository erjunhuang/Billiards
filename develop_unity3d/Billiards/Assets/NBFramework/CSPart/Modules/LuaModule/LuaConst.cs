using UnityEngine;

public static class LuaConst
{
    public static string luaDir = Application.dataPath + "/Lua";                //lua逻辑代码目录
    public static string xluaDir = Application.dataPath + "/XLua/Resources";        //XLua lua文件目录
    public static string nbluaDir = Application.dataPath + "/NBFramework/LuaPart";        //XLua lua文件目录




#if UNITY_STANDALONE
    public static string osDir = "Win";
#elif UNITY_ANDROID
    public static string osDir = "Android";            
#elif UNITY_IPHONE
    public static string osDir = "iOS";        
#else
    public static string osDir = "";        
#endif

    public static string luaResDir = string.Format("{0}/{1}/Lua", Application.persistentDataPath, osDir);      //手机运行时lua文件下载目录    

#if UNITY_EDITOR_WIN || UNITY_STANDALONE_WIN    
    public static string zbsDir = "D:/ZeroBraneStudio/lualibs/mobdebug";        //ZeroBraneStudio目录       
#elif UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
	public static string zbsDir = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/mobdebug";
#else
    public static string zbsDir = luaResDir + "/mobdebug/";
#endif    

    public static bool openLuaSocket = true;            //是否打开Lua Socket库
    public static bool openLuaDebugger = false;         //是否连接lua调试器


    public static readonly string OS_DIR_NAME =
#if UNITY_STANDALONE_WIN
        "Win";
#elif UNITY_STANDALONE_OSX
        "Mac";
#elif UNITY_ANDROID
        "Android";
#elif UNITY_IPHONE
        "iOS";
#else
        "";
#endif


    /// <summary>
    /// 开发时的业务Lua代码路径
    /// </summary>
    public static readonly string LUA_DEVELOPMENT_DIR = string.Format("{0}/{1}", Application.dataPath, LUA_DIR_NAME);

    /// <summary>
    /// 开发时的框架Lua代码路径
    /// </summary>
    public static readonly string LUA_FRAMEWORK_DIR = Application.dataPath + "/NBFramework/LuaPart";

    /// <summary>
    /// 项目发布后的外存中的Lua路径/热更新路径
    /// </summary>
    public static readonly string LUA_PERSISTENT_DIR = string.Format("{0}/{1}", Application.persistentDataPath, LUA_DIR_NAME);

    /// <summary>
    /// 随包发布运行时的Lua资源路径(Android除外)
    /// </summary>
    public static readonly string LUA_STREAMING_ASSETS_DIR = string.Format("{0}/{1}", Application.streamingAssetsPath, LUA_DIR_NAME);

    /// <summary>
    /// Lua
    /// </summary>
    public static readonly string LUA_DIR_NAME = "Lua";
	
	public static readonly string TXT_EXT = ".txt";
    public static readonly string LUA_EXT = ".lua";
    public static readonly string LUA_TXT_EXT = LUA_EXT + TXT_EXT;
		
}