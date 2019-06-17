
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using NBFramework;
namespace NBFramework
{
    public abstract class NBGame : MonoBehaviour, IAppEntry
    {
        protected bool isPaused = false;

        /// <summary>
        /// NBGame 单例引用对象
        /// </summary>
        public static NBGame Instance { get; private set; }

        /// <summary>
        /// Module/Manager of Lua 
        /// </summary>
        public LuaModule LuaModule { get; private set; }

        /// <summary>
        /// Create Module, with new some class inside
        /// </summary>
        /// <returns></returns>
        protected virtual IList<IModule> CreateModules()
        {
            return new List<IModule>
            {
                LuaModule,
            };
        }

        /// <summary>
        /// Unity `Awake`
        /// </summary>
        protected virtual void Awake()
        {
            GameObject.DontDestroyOnLoad(this.gameObject);
            Instance = this;
            LuaModule = LuaModule.Instance;
            AppEngine.New(gameObject, this, CreateModules());
        }

        /// <summary>
        /// Before NBFramework init modules
        /// </summary>
        /// <returns></returns>
        public abstract IEnumerator OnBeforeInit();

        /// <summary>
        /// After NBFramework inited all module, make the game start!
        /// </summary>
        /// <returns></returns>
        public abstract IEnumerator OnGameStart();


        protected void OnDestroy()
        {
            Destroy();
        }

        protected void OnApplicationQuit()
        {
            Destroy();
        }

        protected virtual void OnApplicationFocus(bool hasFocus)
        {
            isPaused = !hasFocus;
        }

        protected virtual void OnApplicationPause(bool pauseStatus)
        {
            isPaused = pauseStatus;
        }


        public virtual void Destroy()
        {

        }

    }
}
