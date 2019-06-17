using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using XLua;

public class LuaLooper : MonoBehaviour
{

	public  LuaEnv luaEnv;

    LuaFunction luaUpdate = null;
    LuaFunction luaLateUpdate = null;
    LuaFunction  luaFixedUpdate = null;



    // Start is called before the first frame update
    void Start()
    {
        try
        {
            luaUpdate = luaEnv.Global.Get<LuaFunction>("Update");
	        luaLateUpdate = luaEnv.Global.Get<LuaFunction>("LateUpdate");
	        luaFixedUpdate = luaEnv.Global.Get<LuaFunction>("FixedUpdate");

        }
        catch (Exception e)
        {
            Destroy(this);
            throw e;
        } 
    }

    // Update is called once per frame
    void Update()
    {
        if(luaUpdate != null)
        {
        	try
            {
                luaUpdate.Call(Time.deltaTime, Time.unscaledDeltaTime);
            }
            catch (Exception ex)
            {
                // Logger.LogError("luaUpdate err : " + ex.Message + "\n" + ex.StackTrace);
            }
        }
    }

    void LateUpdate()
    {

        if(luaLateUpdate != null)
        {
        	try
            {
                luaLateUpdate.Call();
            }
            catch (Exception ex)
            {
                // Logger.LogError("luaUpdate err : " + ex.Message + "\n" + ex.StackTrace);
            }
        }
    }

    void FixedUpdate()
    {
    	if(luaFixedUpdate != null)
        {
        	try
            {
                luaFixedUpdate.Call(Time.fixedDeltaTime);
            }
            catch (Exception ex)
            {
                // Logger.LogError("luaUpdate err : " + ex.Message + "\n" + ex.StackTrace);
            }
        }
    }


    public void Destroy()
    {
    	if(luaEnv != null)
    	{
    		luaUpdate = null;
    		luaLateUpdate = null;
    		luaFixedUpdate = null;
    		luaEnv = null;
    	}
    	
    }

    void OnDestroy()
    {
        if (luaEnv != null)
        {
            Destroy();
        }
    }


}
