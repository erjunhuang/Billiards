using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using NBFramework;

public class Game : NBGame
{
    protected override IList<IModule> CreateModules()
    {
        var modules = base.CreateModules();

        // TIP: Add Your Custom Module here
        //modules.Add(new Module());
        return modules;
    }

    public override IEnumerator OnBeforeInit()
    {
        // Do Nothing
        yield break;
    }

    public override IEnumerator OnGameStart()
    {
        yield return null;
        LuaModule.LoadMainLuaFiles();
    }

}
