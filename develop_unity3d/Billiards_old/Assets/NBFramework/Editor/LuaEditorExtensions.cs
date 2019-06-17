using UnityEngine;
using System.Collections;
using System.IO;
using UnityEditor;
using System;

namespace NBFramework.Editor {

    public class LuaEditorExtensions {

        /// <summary>
        /// 从源目录拷贝到目标目录
        /// </summary>
        /// <param name="sourceDir"></param>
        /// <param name="destDir"></param>
        /// <param name="extraNameFunc">(destDir, relativePath) => destPath</param>
        /// <param name="searchPattern"></param>
        /// <param name="searchOption"></param>
        public static void CopyFiles(string sourceDir, string destDir, Func<string, string, string> extraNameFunc, string searchPattern = "*", SearchOption searchOption = SearchOption.AllDirectories) {
            if (!Directory.Exists(sourceDir)) {
                return;
            }

            sourceDir = sourceDir.Replace('\\', '/');
            var filePaths = Directory.GetFiles(sourceDir, searchPattern, searchOption);

            int len = sourceDir.Length;

            if (sourceDir[len - 1] == '/') {
                --len;
            }

            foreach (string filePath in filePaths)
            {
                string srcPath = filePath.Replace('\\', '/');
                string relativePath = srcPath.Remove(0, len);
                string destPath;
                if (extraNameFunc != null) {
                    destPath = extraNameFunc(destDir, relativePath);
                } else {
                    destPath = Path.Combine(destDir, relativePath).Replace('\\', '/');
                }
                Directory.CreateDirectory(Path.GetDirectoryName(destPath));
                File.Copy(srcPath, destPath, true);
            }
            
        }

        [MenuItem("NBFramework/Lua/Clear all Lua files", false, 10)]
        public static void ClearAllLuaFiles() {
            string osPath = Application.streamingAssetsPath + "/" + LuaConst.OS_DIR_NAME;
            if (Directory.Exists(osPath))
            {
                string[] files = Directory.GetFiles(osPath, "Lua*.unity3d");

                for (int i = 0; i < files.Length; i++)
                {
                    File.Delete(files[i]);
                }
            }

            string osLuaPath = osPath + "/" + LuaConst.LUA_DIR_NAME;

            if (Directory.Exists(osLuaPath))
            {
                Directory.Delete(osLuaPath, true);
            }

            string luaPath = Application.streamingAssetsPath + "/" + LuaConst.LUA_DIR_NAME;
            if (Directory.Exists(luaPath))
            {
                Directory.Delete(luaPath, true);
            }

            string tempPath = Application.dataPath + "/temp";
            if (Directory.Exists(tempPath)) {
                Directory.Delete(tempPath, true);
            }

            string persistentLuaPath = Application.persistentDataPath + "/" + LuaConst.OS_DIR_NAME + "/" + LuaConst.LUA_DIR_NAME;
            if (Directory.Exists(persistentLuaPath)) {
                Directory.Delete(persistentLuaPath, true);
            }
            AssetDatabase.Refresh();
        }

        [MenuItem("NBFramework/Lua/Clear Resources Directory", false, 11)]
        public static void ClearResourcesDirectory() {
            string resourcesDir = Path.Combine(Application.dataPath, "Resources");
            if (Directory.Exists(resourcesDir)) {
                Directory.Delete(resourcesDir, true);
            }
            AssetDatabase.Refresh();
        }

        [MenuItem("NBFramework/Lua/Copy Lua files into Resources", false, 1)]
        public static void CopyLuaFilesIntoResources() {
            string dest = Path.Combine(Path.Combine(Application.dataPath, "Resources"), LuaConst.LUA_DIR_NAME);
            CopyFiles(LuaConst.LUA_FRAMEWORK_DIR, dest, (string destDir, string relativePath) => string.Format("{0}/{1}.txt", destDir, relativePath), "*.lua");
            CopyFiles(LuaConst.LUA_DEVELOPMENT_DIR, dest, (string destDir, string relativePath) => string.Format("{0}/{1}.txt", destDir, relativePath), "*.lua");
            AssetDatabase.Refresh();
        }
    }
}