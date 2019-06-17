using System;
using UnityEngine;

namespace NBFramework {

    /// <summary>
    /// 有无参构造函数的单例抽象类
    /// </summary>
    /// <typeparam name="T">引用类型，有无参构造函数</typeparam>
    public class AbstractSingleton<T>: ISingletonCallback where T:class, new()
    {
        private static T s_Instance;
        public static T Instance {
            get {
                if (s_Instance == null) {
                    s_Instance = Activator.CreateInstance<T>();
                    (s_Instance as AbstractSingleton<T>).OnInitInstance();
                }
                return s_Instance;
            }
        }

        public static T GetInstance() {
            return Instance;
        }

        public static void ReleaseInstance() {
            if (s_Instance != null) {
                (s_Instance as AbstractSingleton<T>).OnReleaseInstance();
                s_Instance = null;
            }
        }

        public virtual void OnInitInstance() {

        }

        public virtual void OnReleaseInstance() {

        }
    }

}