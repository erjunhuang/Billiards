namespace NBFramework
{
    public interface ISingletonCallback {
        /// <summary>
        /// 创建单例对象后初始化时
        /// </summary>
        void OnInitInstance();
        
        /// <summary>
        /// 销毁单例对象前
        /// </summary>
        void OnReleaseInstance();
    }
}
