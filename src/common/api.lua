---Player request to fire shell
---@param playerId number
---@param shellDef ShellDefinition
function server.requestFireShell(playerId, shellDef)
    local values = SHELL_VALUES[shellDef.type]
    local variant = values.variants[shellDef.variant]

    local shell_whistle = values.sounds.whistle
    if type(values.sounds.whistle) == "table" then
        local rand = math.random(#values.sounds.whistle)
        shell_whistle = values.sounds.whistle[rand]
    end

    local shell_sprite = values.sprite
    if FdAssertTableKeys(variant, "sprite") then
        shell_sprite = variant.sprite
    end

    ---@type Shell
    local shell = FdObjectNew({
        ownerId = playerId,
        type = shellDef.type,
        variant = shellDef.variant,
        inaccuracy = shellDef.inaccuracy,
        pitch = shellDef.pitch,
        heading = shellDef.heading,
        sprite = shell_sprite,
        snd_whistle = LoadLoop("MOD/assets/snd/" .. shell_whistle .. ".ogg"),
    }, DEFAULT_SHELL)

    FdLog("TODO: Fire shell")
end

---Send request to server to fire shell
---@param shellDef ShellDefinition
function client.requestFireShell(shellDef)
    ---@diagnostic disable-next-line:redundant-parameter
    ServerCall("server.requestFireShell", GetLocalPlayer(), shellDef)
end
