function server.init()
    FdLog("Server Init")

    RegisterTool("ordnance", "Ordnance [FD]", "MOD/assets/vox/radio.xml")
    SetBool("game.tool.ordnance.enabled", true)

    G_PHYSICS_ITERATIONS = 2 ^ (CfgGetValue("G_PHYSICS_ITERATIONS") or 4)

    if G_DEV then
        SetPlayerSpawnTool("ordnance")
    end
end
