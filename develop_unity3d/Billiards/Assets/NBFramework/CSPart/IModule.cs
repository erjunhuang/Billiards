using System;
using System.Collections;

namespace NBFramework
{
    /// <summary>
    /// NBFramework's Module must has IEnumerator Init method
    /// </summary>
    public interface IModule
    {
        /// <summary>
        /// Async Initialization
        /// </summary>
        /// <returns></returns>
        IEnumerator Init();

        /// <summary>
        /// the progress of the initialize operation
        /// </summary>
        double InitProgress { get; }
    }

}