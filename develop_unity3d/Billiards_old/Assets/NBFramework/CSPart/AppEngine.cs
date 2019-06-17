

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;

namespace NBFramework
{
    /// <summary>
    /// Entry
    /// </summary>
    public interface IAppEntry
    {
        IEnumerator OnBeforeInit();
        IEnumerator OnGameStart();
    }

    /// <summary>
    /// Cosmos Engine - Unity3D Game Develop Framework
    /// </summary>
    public class AppEngine : MonoBehaviour
    {
        public static bool IsDebugBuild { get; private set; } // cache Debug.isDebugBuild for multi thread

     

        /// <summary>
        /// In Init func has a check if the user has the write privillige
        /// </summary>
        public static bool IsRootUser; // 是否越狱iOS

        public static AppEngine EngineInstance { get; private set; }

        /// <summary>
        /// Read Tab file (CEngineConfig.txt), cache to here
        /// </summary>
        /// <summary>
        /// Modules passed from the CosmosEngine.New function. All your custom game logic modules
        /// </summary>
        public IList<IModule> GameModules { get; private set; }

        /// <summary>
        /// 是否初始化完成
        /// </summary>
        public bool IsInited { get; private set; }

        /// <summary>
        /// AppEngine must be new by static function New(xxx)!
        /// This is a flag to identity whether AddComponent from Unity
        /// </summary>
        private bool _isNewByStatic = false;

        public IAppEntry AppEntry { get; private set; }

        /// <summary>
        /// Engine entry.... all begins from here
        /// </summary>
        public static AppEngine New(GameObject gameObjectToAttach, IAppEntry entry, IList<IModule> modules)
        {
            Debuger.Assert(gameObjectToAttach != null && modules != null);
            AppEngine appEngine = gameObjectToAttach.AddComponent<AppEngine>();
            appEngine._isNewByStatic = true;
            appEngine.GameModules = modules;
            appEngine.AppEntry = entry;

            return appEngine;
        }

        private void Awake()
        {
            IsDebugBuild = Debug.isDebugBuild;

            if (EngineInstance != null)
            {
                Log.Error("Duplicated Instance Engine!!!");
            }

            EngineInstance = this;

            Init();
        }

        void Start()
        {
            Debuger.Assert(_isNewByStatic);
        }

        private void Init()
        {
            IsRootUser = NBTool.HasWriteAccessToFolder(Application.dataPath); // Root User运行时，能穿越沙盒写DataPath, 以此为依据
            if (Debug.isDebugBuild)
            {
                Log.Info("====================================================================================");
                Log.Info("Application.platform = {0}", Application.platform);
                Log.Info("Application.dataPath = {0} , WritePermission: {1}", Application.dataPath, IsRootUser);
                Log.Info("Application.streamingAssetsPath = {0} , WritePermission: {1}",
                    Application.streamingAssetsPath, NBTool.HasWriteAccessToFolder(Application.streamingAssetsPath));
                Log.Info("Application.persistentDataPath = {0} , WritePermission: {1}", Application.persistentDataPath,
                    NBTool.HasWriteAccessToFolder(Application.persistentDataPath));
                Log.Info("Application.temporaryCachePath = {0} , WritePermission: {1}", Application.temporaryCachePath,
                    NBTool.HasWriteAccessToFolder(Application.temporaryCachePath));
                Log.Info("Application.unityVersion = {0}", Application.unityVersion);
                Log.Info("SystemInfo.deviceModel = {0}", SystemInfo.deviceModel);
                Log.Info("SystemInfo.deviceUniqueIdentifier = {0}", SystemInfo.deviceUniqueIdentifier);
                Log.Info("SystemInfo.graphicsDeviceVersion = {0}", SystemInfo.graphicsDeviceVersion);
                Log.Info("====================================================================================");
            }
            StartCoroutine(DoInit());
        }

        /// <summary>
        /// Use Coroutine to initialize the two base modules: Resource & UI
        /// </summary>
        private IEnumerator DoInit()
        {
            yield return null;

            if (AppEntry != null) {
                yield return StartCoroutine(AppEntry.OnBeforeInit());
            }

            yield return StartCoroutine(DoInitModules(GameModules));

            if (AppEntry != null)
            {
                yield return StartCoroutine(AppEntry.OnGameStart());
            }

            IsInited = true;
        }

        private IEnumerator DoInitModules(IList<IModule> modules)
        {
            var startInitTime = 0f;
            var startMem = 0f;
            foreach (IModule initModule in modules)
            {
                if (Debug.isDebugBuild)
                {
                    startInitTime = Time.time;
                    startMem = GC.GetTotalMemory(false);
                }
                yield return StartCoroutine(initModule.Init());
                if (Debug.isDebugBuild)
                {
                    var nowMem = GC.GetTotalMemory(false);
                    Log.Info("Init Module: #{0}# Time:{1}, DiffMem:{2}, NowMem:{3}", initModule.GetType().FullName,
                        Time.time - startInitTime, nowMem - startMem, nowMem);
                }
            }
        }
    }
}