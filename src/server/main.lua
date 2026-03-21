local UPDATE_RATE = 1 / 10

function server.init()
    FdLog("Server Init")

    RegisterTool("ordnance", "Ordnance [FD]", "MOD/assets/vox/radio.xml")
    SetBool("game.tool.ordnance.enabled", true)

    shared.debug = {
        _target = 1,
    }

    shared.config = {
        physicsIterations = 2 ^ (CfgGetValue("G_PHYSICS_ITERATIONS") or 4),
    }

    shared.state = {
        ---@type Shell[]
        shells = {},
    }

    server.state = {
        elapsedTime = 0,
        nextUpdate = 0,
        shells = {
            nextId = 0,
            ---@type Shell[]
            _shells = {},
        },
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
    FdWatch("option(PHYSICS ITERATIONS)", shared.config.physicsIterations)

    FdWatch("SERVER Elapsed Time", server.state.elapsedTime)
    FdWatch("SERVER Shells", #server.state.shells._shells)

    if #server.state.shells._shells > 0 then
        shared.debug._target = #server.state.shells._shells
        FdWatch("SERVER Value test", server.state.shells._shells[shared.debug._target].position)
        ClientCall(0, "client.debug")
    end
end

function server.update(delta)
    -- Run shell tick for each shell not detonated, remove shell if detonated
    for i, shell in ipairs(server.state.shells._shells) do
        ShellTick(shell, delta)

        if shell.state == SHELL_STATE.DETONATED then
            FdLog("Shell " .. i .. " detonated. Removing...")
            table.remove(server.state.shells._shells, i)
        end
    end

    local shells_length = #server.state.shells._shells
    if shells_length > G_MAX_SHELLS then
        local trim_amount = shells_length - G_MAX_SHELLS
        FdLog("Removing " .. trim_amount .. " shells from table...")

        for _ = 1, trim_amount do
            table.remove(server.state.shells._shells, 1)
        end
    end

    if server.state.nextUpdate <= server.state.elapsedTime then
        for _, shell in ipairs(server.state.shells._shells) do
            local id = shell._id
            if shared.state.shells[id] then
                shared.state.shells[id] = FdObjectCopy(shell)
            end
        end

        server.state.nextUpdate = server.state.elapsedTime + UPDATE_RATE
    end
end
