using NBFramework;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace NBFramework.LuaUIExtensions
{

    [System.Serializable]
    public class Injection
    {
        public string name;
        public UnityEngine.Object value;
    }

    public class UILuaBridge : MonoBehaviour
    {
        public string luaPath;
        public Injection[] injections;
        private LuaTable _luaTable;
        void Awake()
        {
            UnityEngine.Debug.Log("billiards/BilliardsTable"+ luaPath);
            if (luaPath != null && !luaPath.Equals(""))
            {
                var luaModule = NBGame.Instance.LuaModule;
                var scriptReturn = luaModule.DoFile(luaPath);
                if (scriptReturn == null)
                {
                    return;
                }

                LuaTable tempTable = scriptReturn[0] as LuaTable;

                LuaTable injectionsTable = luaModule.ENV.NewTable();

                foreach (var injection in injections)
                {
                    injectionsTable.Set(injection.name, injection.value);
                }
   
                var newFuncObj = tempTable.Get<LuaFunction>("new");

                if (newFuncObj != null)
                {
                    var newTableObj = (newFuncObj as LuaFunction).Call(this, injectionsTable);
                    _luaTable = newTableObj[0] as LuaTable;
                }
                else
                {
                    _luaTable = tempTable;
                }
            }
        }

        void OnDestroy()
        {
            var funcObj = _luaTable.Get<LuaFunction>("onDestroy");

            if (funcObj != null)
            {
                (funcObj as LuaFunction).Call(_luaTable);
            }
        }
    }
}


