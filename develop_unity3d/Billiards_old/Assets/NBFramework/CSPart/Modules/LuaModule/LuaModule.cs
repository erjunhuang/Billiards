
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using NBFramework;
using XLua;
using XLua.LuaDLL;


namespace NBFramework
{
    [LuaCallCSharp]
    public class LuaModule : IModule
    {
        private readonly LuaEnv _luaEnv;
        public LuaEnv ENV
        {
            get
            {
                return _luaEnv;
            }
        }
        public static LuaModule Instance = new LuaModule();

        public bool IsInited { get; private set; }

        private double _initProgress = 0;

        public double InitProgress { get { return _initProgress; } }

        protected LuaLooper _loop = null;

        /// <summary>
        /// 是否开启缓存模式，默认true，首次执行将把执行结果table存起来；在非缓存模式下，也可以通过编辑器的Reload来进行强制刷新缓存
        /// 对实时性重载要求高的，可以把开关设置成false，长期都进行Lua脚本重载，理论上会消耗额外的性能用于语法解析
        /// 
        /// 一般的脚本语言，如Python, NodeJS中，其import, require关键字都会对加载过的模块进行缓存(包括Lua原生的require)；如果不缓存，要注意状态的保存问题
        /// 该值调用频繁，就不放ini了
        /// </summary>
        public static bool CacheMode = false;

        /// <summary>
        /// Import result object caching
        /// </summary>
        Dictionary<string, object> _importCache = new Dictionary<string, object>();

        protected LuaModule()
        {
            _luaEnv = new LuaEnv();

        }

        public object[] DoString(string chunk, string chunkName = "LuaModule.cs")
        {

            byte[] buffer = Encoding.UTF8.GetBytes(chunk);

            return _luaEnv.DoString(buffer, chunkName);

        }

        public object[] DoString(byte[] chunk, string chunkName = "LuaState.cs")
        {
            return _luaEnv.DoString(chunk, chunkName);

        }

        byte[] LoadFileBuffer(string fileName)
        {

            byte[] buffer = LuaFileUtils.Instance.ReadFile(fileName);

            if (buffer == null)
            {
                string error = string.Format("cannot open {0}: No such file or directory", fileName);
                error += LuaFileUtils.Instance.FindFileError(fileName);
                throw new LuaException(error);
            }

            return buffer;
        }

        string LuaChunkName(string name)
        {
            if (LuaConst.openLuaDebugger)
            {
                name = LuaFileUtils.Instance.FindFile(name);
            }

            return "@" + name;
        }

        public object[] DoFile(string fileName)
        {
            byte[] buffer = LoadFileBuffer(fileName);
            fileName = LuaChunkName(fileName);

            return DoString(buffer, fileName);
        }

        public byte[] DefaultCustomLoader(ref string filename)
        {
            return LoadFileBuffer(filename);
        }
        
        /// <summary>
        /// Clear all imported cache
        /// </summary>
        public void ClearAllCache()
        {
            _importCache.Clear();
        }

        /// <summary>
        /// Clear dest lua script cache
        /// </summary>
        /// <param name="uiLuaPath"></param>
        /// <returns></returns>
        public bool ClearCache(string uiLuaPath)
        {
            return _importCache.Remove(uiLuaPath);
        }

        public void InitPackagePath()
        {
            LuaTable lpackage = _luaEnv.Global.Get<LuaTable>("package");
            string searchpaths = lpackage.Get<string>("path");
            string[] paths = searchpaths.Split(';');

            for (int i = 0; i < paths.Length; i++)
            {
                if (!string.IsNullOrEmpty(paths[i]))
                {
                    string path = paths[i].Replace('\\', '/');
                    LuaFileUtils.Instance.AddSearchPath(path);
                }
            }

        }

        string ToPackagePath(string path)
        {

            path = path.Replace('\\', '/');
            if (path.Length > 0 && !path.EndsWith("/"))
            {
                path += "/";
            }

            path += "?.lua";

            return path;
        }

        public void AddSearchPath(string fullPath)
        {
            if (!Path.IsPathRooted(fullPath))
            {
                throw new LuaException(fullPath + " is not a full path");
            }

            fullPath = ToPackagePath(fullPath);
            LuaFileUtils.Instance.AddSearchPath(fullPath);
        }

        public void RemoveSeachPath(string fullPath)
        {
            if (!Path.IsPathRooted(fullPath))
            {
                throw new LuaException(fullPath + " is not a full path");
            }

            fullPath = ToPackagePath(fullPath);
            LuaFileUtils.Instance.RemoveSearchPath(fullPath);
        }


        private void InitLuaPath()
        {
            InitPackagePath();

            if (!LuaFileUtils.Instance.beZip)
            {
#if UNITY_EDITOR
                if (!Directory.Exists(LuaConst.luaDir))
                {
                    string msg = string.Format("luaDir path not exists: {0}, configer it in LuaConst.cs", LuaConst.luaDir);
                    throw new LuaException(msg);
                }

                AddSearchPath(LuaConst.xluaDir); 
                AddSearchPath(LuaConst.nbluaDir);
                AddSearchPath(LuaConst.luaDir);
#endif
                if (LuaFileUtils.Instance.GetType() == typeof(LuaFileUtils))
                {
                    AddSearchPath(LuaConst.luaResDir);
                }
            }
        }

        private void OpenLibs()
        {
            //TODO 如果有新加入的库，加入进去
            // _luaEnv.AddBuildin("",);
        }

        private void OpenBaseLuaLibs()
        {
            DoFile("nbinit");
        }

        protected virtual LuaFileUtils InitLoader()
        {
            _luaEnv.AddLoader(DefaultCustomLoader);
            return LuaResLoader.Instance;
        }

        public IEnumerator Init()
        {
            InitLoader();
            InitLuaPath();
            OpenLibs();
            OpenBaseLuaLibs();
            yield return null;

            IsInited = true;
        }

        public virtual void LoadMainLuaFiles()
        {
            OnLoadFinished();
        }

        protected virtual void OnLoadFinished()
        {
            StartLooper();
            StartMain();
        }

        protected virtual void StartMain()
        {
            DoFile("main");
        }

        protected void StartLooper()
        {
            var gameObject = NBGame.Instance.gameObject;
            _loop = gameObject.AddComponent<LuaLooper>();
            _loop.luaEnv = _luaEnv;
        }
    }
}
