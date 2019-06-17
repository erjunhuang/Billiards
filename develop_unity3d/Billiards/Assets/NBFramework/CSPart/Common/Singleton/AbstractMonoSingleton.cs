using UnityEngine;

namespace NBFramework
{
    /// <summary>
    /// 继承MonoBehaviour并且出现在Unity3D场景的中的单例抽象类
    /// </summary>
    /// <typeparam name="T">继承此泛型类的类</typeparam>
    public abstract class AbstractMonoSingleton<T> : MonoBehaviour, ISingletonCallback where T : AbstractMonoSingleton<T>
    {
        private static T s_Instance = null;

        public static T Instance
        {
            get
            {
                if (s_Instance == null)
                {
                    s_Instance = GameObject.FindObjectOfType(typeof(T)) as T;
                    if (s_Instance == null)
                    {
                        GameObject go = new GameObject(typeof(T).Name);
                        GameObject.DontDestroyOnLoad(go);
                        s_Instance = go.AddComponent<T>();
                    }
                }

                return s_Instance;
            }
        }

        public static T GetInstance() {
            return Instance;
        }

        public static void ReleaseInstance() {
            if (s_Instance) {
                s_Instance.DestroySelf();
                s_Instance = null;
            }
        }

        protected virtual void Awake() {
            if (s_Instance == null) {
                s_Instance = this as T;
                DontDestroyOnLoad(this.gameObject);
                this.OnInitInstance();
            }
        }

        public void DestroySelf() {
            this.OnReleaseInstance();
            s_Instance = null;
            UnityEngine.Object.Destroy(this.gameObject);
        }

        public virtual void OnInitInstance() {

        }

        public virtual void OnReleaseInstance() {

        }
    }
}