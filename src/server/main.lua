function server.init()
    FdLog("Server Init")

    RegisterTool("ordnance", "Ordnance [FD]", "MOD/assets/vox/radio.xml")
    SetBool("game.tool.ordnance.enabled", true)

    G_PHYSICS_ITERATIONS = 2 ^ (CfgGetValue("G_PHYSICS_ITERATIONS") or 4)

    server.state = {
        elapsedTime = 0,
    }

    if G_DEV then
        SetPlayerSpawnTool("ordnance")
    end
end

function server.tick(delta)
    server.state.elapsedTime = server.state.elapsedTime + delta

    FdWatch("state(ENABLED)", STATES.enabled)
    FdWatch("state(QUICK SALVO)", STATES.quicksalvo.enabled)
    FdWatch("option(FLIGHT_TIME)", CfgGetValue("G_TIME_OF_FLIGHT"))
    FdWatch("option(PHYSICS ITERATIONS)", G_PHYSICS_ITERATIONS)
    FdWatch("Shells", #SHELLS)
    FdWatch("Salvo", #QUICK_SALVO)
    FdWatch("BODIES", #BODIES)
    FdWatch("SERVER Elapsed Time", server.state.elapsedTime)
end

function server.update() end
