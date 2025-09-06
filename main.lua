#include "src/load.lua"

ELAPSED_TIME = 0

SHELLS = {}
BODIES = {}
---@type Shell[]
QUICK_SALVO = {}

DEBUG_LINES = {}
DEBUG_POSITIONS = {}

DEFAULT_ENVIRONMENT = {}
DEFAULT_POSTPROCESSING = {}

PLAYER_LOCK_TRANSFORM = nil

-- total, hit, miss, redirected
FRAG_STATS = {
    0, 0, 0, 0
}

-- #region functions

---@param display DISPLAY_STATE
local function drawQuicksalvoMarkers(display)
    if display == DISPLAY_STATE.HIDDEN then return end

    local queue_length = #QUICK_SALVO
    if queue_length <= 0 then return end

    for i = 1, queue_length do
        local shell = QUICK_SALVO[i]

        if display == DISPLAY_STATE.MINIMAL then
            local pos = VecAdd(shell.destination, Vec(0, 0.03, 0))
            FdDrawCircle(pos, 0.2, 8, COLOUR["red"])
        else
            FdDrawShellImpactGizmo(
                { shell.destination, shell.heading, shell.pitch },
                shell.inaccuracy, 32, COLOUR["red"], 2, true
            )
        end
    end
end

-- #endregion functions

-- #region Main

---@diagnostic disable-next-line: lowercase-global
function init()
    RegisterTool("ordnance", "Ordnance [FD]", "MOD/assets/vox/radio.xml")
    SetBool("game.tool.ordnance.enabled", true)

    if CfgInit() then
        FdLog("Restoring configuration defaults...")
        CfgReset()
    else
        FdLog("Config exists and is complete.")
    end

    G_DEV                    = CfgGetValue("G_DEBUG_MODE") or false
    G_QUICK_SALVO_DELAY      = CfgGetValue("G_QUICK_SALVO_DELAY") or 0.5
    G_PHYSICS_ITERATIONS     = 2 ^ (CfgGetValue("G_PHYSICS_ITERATIONS") or 4)
    DEFAULT_SHELL.eta        = CfgGetValue("G_TIME_OF_FLIGHT")
    DEFAULT_SHELL.inaccuracy = CfgGetValue("G_SHELL_INACCURACY")

    DELAYS                   = {
        quick_salvo = G_QUICK_SALVO_DELAY
    }

    KEYBINDS                 = {
        ["KEYBIND_TACTICAL_TOGGLE"] = CfgGetValue("KEYBIND_TACTICAL_TOGGLE"),
        ["KEYBIND_CYCLE_SHELLS"] = CfgGetValue("KEYBIND_CYCLE_SHELLS"),
        ["KEYBIND_CYCLE_VARIANTS"] = CfgGetValue("KEYBIND_CYCLE_VARIANTS"),
        ["KEYBIND_ADJUST_ATTACK"] = CfgGetValue("KEYBIND_ADJUST_ATTACK"),
        ["KEYBIND_ADJUST_INACCURACY"] = CfgGetValue("KEYBIND_ADJUST_INACCURACY"),
        ["KEYBIND_GENERAL_CANCEL"] = CfgGetValue("KEYBIND_GENERAL_CANCEL"),
        ["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"] = CfgGetValue("KEYBIND_TOGGLE_QUICKSALVO_MARKERS"),
    }

    UI_HELPERS               = {
        player_camera = nil,
        shell_telemetry = {
            combined_transform = nil,
            arrow_pitch_pos = nil,
            arrow_heading_pos = nil
        }
    }

    SND_UI                   = {}
    SND_UI["select"]         = LoadSound("MOD/assets/snd/menu_select.ogg")
    SND_UI["cancel"]         = LoadSound("MOD/assets/snd/menu_cancel.ogg")
    SND_UI["salvo_mark"]     = LoadSound("MOD/assets/snd/salvo_mark.ogg")

    FdUiLoadImageMetadata()

    ResetToDefaultState()

    if G_DEV then SetPlayerSpawnTool("ordnance") end
end

---@diagnostic disable-next-line: lowercase-global
function tick(delta)
    ELAPSED_TIME = ELAPSED_TIME + delta

    for _, projectile in ipairs(Projectiles.getProjectiles()) do
        Projectiles.tick(projectile, delta)
    end

    FdWatch("state(ENABLED)", STATES.enabled)
    FdWatch("state(QUICK SALVO)", STATES.quicksalvo.enabled)
    FdWatch("option(FLIGHT_TIME)", CfgGetValue("G_TIME_OF_FLIGHT"))
    FdWatch("option(PHYSICS ITERATIONS)", G_PHYSICS_ITERATIONS)
    FdWatch("Shells", #SHELLS)
    FdWatch("Salvo", #QUICK_SALVO)
    FdWatch("BODIES", #BODIES)

    if not STATES.quicksalvo.enabled then
        STATES.quicksalvo.delay = 0
    end

    for i, body in ipairs(BODIES) do
        if body.valid == true and PhysBodyTick(body) then
            body.valid = false
        end

        local ttl = body.ttl or 20
        if body.valid == true and (ELAPSED_TIME - body.created_at) > ttl then
            Delete(body.handle)
            body.valid = false
        end

        if not body.valid then
            table.remove(BODIES, i)
        end
    end

    for _, shell in ipairs(SHELLS) do
        local values = SHELL_VALUES[shell.type]
        local variant = values.variants[shell.variant]

        if (shell.secondary.active and variant.secondary.draw) or not shell.secondary.active then
            ShellDrawSprite(shell)
        end

        if variant.id == "PF" then
            if shell.secondary.active then
                PointLight(shell.position, 1, 1, 1, shell.secondary.intensity)
            end
        end
    end

    -- Draw HUD markers for quick salvo shell targets
    drawQuicksalvoMarkers(STATES.quicksalvo.markers)

    -- Fire remaining quick salvo shells with delay if currently not in quick salvo mode
    if not STATES.quicksalvo.enabled and #QUICK_SALVO > 0 then
        DELAYS.quick_salvo = DELAYS.quick_salvo - delta

        if DELAYS.quick_salvo < 0 then
            local salvo_shell = table.remove(QUICK_SALVO, 1)
            ShellInit(salvo_shell)

            local next_shell = QUICK_SALVO[1]
            if next_shell ~= nil then
                DELAYS.quick_salvo = next_shell.delay
            end
        end
    else
        DELAYS.quick_salvo = 0
    end

    if GetPlayerVehicle() ~= 0 then
        STATES.enabled = false
        return
    end

    if not (GetString("game.player.tool") == "ordnance") then
        STATES.enabled = false
        return
    end

    -- -------------------------------
    -- Tool is active and ready to use
    -- -------------------------------

    STATES.enabled = true
    local sound_pos = GetCameraTransform().pos

    SetToolTransform(Transform(Vec(0.2, -0.3, -0.4), QuatEuler(-20, -35, -5)))
    SetToolHandPoseLocalTransform(Transform(Vec(0, 0.08, 0), QuatEuler(0, 180, 0)), nil)

    if G_DEV then
        if #DEBUG_POSITIONS > 0 then
            FdDebugRenderPositions(DEBUG_POSITIONS)
        end

        if #DEBUG_LINES > 0 then
            FdDebugRenderLines(DEBUG_LINES)
        end
    end

    -- User toggles tactical marking mode
    if InputPressed(CfgGetValue("KEYBIND_TACTICAL_TOGGLE")) then
        if not STATES.tactical.enabled then
            DEFAULT_ENVIRONMENT["fogcolor"] = { GetEnvironmentProperty("fogcolor") }
            DEFAULT_ENVIRONMENT["fogParams"] = { GetEnvironmentProperty("fogParams") }
            DEFAULT_ENVIRONMENT["snowamount"] = { GetEnvironmentProperty("snowamount") }
            DEFAULT_ENVIRONMENT["snowdir"] = { GetEnvironmentProperty("snowdir") }
            DEFAULT_ENVIRONMENT["sunBrightness"] = { GetEnvironmentProperty("sunBrightness") }
            DEFAULT_ENVIRONMENT["rain"] = { GetEnvironmentProperty("rain") }
            DEFAULT_ENVIRONMENT["brightness"] = { GetEnvironmentProperty("brightness") }
            DEFAULT_ENVIRONMENT["exposure"] = { GetEnvironmentProperty("exposure") }

            DEFAULT_POSTPROCESSING["saturation"] = { GetPostProcessingProperty("saturation") }
            DEFAULT_POSTPROCESSING["colorbalance"] = { GetPostProcessingProperty("colorbalance") }

            ContextTacticalInit()
        end

        if STATES.tactical.enabled then
            FdSetEnvProps(DEFAULT_ENVIRONMENT)
            FdSetPostProcProps(DEFAULT_POSTPROCESSING)
        end

        STATES.tactical.enabled = not STATES.tactical.enabled
    end

    -- Capture user's current player transform for locking camera
    if InputPressed(KEYBINDS["KEYBIND_ADJUST_ATTACK"]) then
        PLAYER_LOCK_TRANSFORM = GetPlayerTransform(true)

        STATES.input_attack_invert = false

        local heading = STATES.selected_attack_heading
        if not STATES.tactical.enabled then
            local _, py, _ = GetQuatEuler(GetPlayerTransform(true).rot)

            heading = (heading - py) % 360
        end

        if heading < 180 and heading > 0 then
            STATES.input_attack_invert = true
        end
    end

    -- User change pitch/heading event
    if InputReleased(KEYBINDS["KEYBIND_ADJUST_ATTACK"]) then
        local transform_player_current = GetPlayerTransform(true)
        local transform_player_reset = Transform(transform_player_current.pos, PLAYER_LOCK_TRANSFORM.rot)

        local velocity_player_current = GetPlayerVelocity()

        SetPlayerTransform(transform_player_reset, true)
        SetPlayerVelocity(velocity_player_current)
    end

    -- User change shell inaccuracy event
    if InputDown(CfgGetValue("KEYBIND_ADJUST_INACCURACY")) then
        SetBool("game.input.locktool", true)

        if InputValue("mousewheel") ~= 0 then
            local value = 0.5
            if STATES.shell_inaccuracy >= 15 then value = 1 end
            if STATES.shell_inaccuracy >= 50 then value = 2.5 end
            if STATES.shell_inaccuracy >= 100 then value = 5 end

            local offset = value * InputValue("mousewheel")
            STATES.shell_inaccuracy = FdClamp(STATES.shell_inaccuracy + offset, 0, 150)
        end
    elseif InputDown(CfgGetValue("KEYBIND_ADJUST_DELAY")) and STATES.quicksalvo.enabled then
        SetBool("game.input.locktool", true)

        if InputValue("mousewheel") ~= 0 then
            local value = 0.1
            if G_QUICK_SALVO_DELAY >= 4.99 then value = 0.5 end
            if G_QUICK_SALVO_DELAY >= 14.99 then value = 1 end
            if G_QUICK_SALVO_DELAY >= 30 then value = 2 end
            if G_QUICK_SALVO_DELAY >= 60 then value = 5 end

            local offset = value * InputValue("mousewheel")
            G_QUICK_SALVO_DELAY = FdClamp(G_QUICK_SALVO_DELAY + offset, 0, 120)
        end
    elseif InputDown(KEYBINDS["KEYBIND_ADJUST_ATTACK"]) then -- User change heading and angle of attack event
        SetBool("game.input.locktool", true)

        if InputValue("mousedx") ~= 0 then
            local offset = 0.5
            if STATES.input_attack_invert then offset = -offset end

            offset = offset * InputValue("mousedx")
            STATES.selected_attack_heading = (STATES.selected_attack_heading % 360) + offset
        end

        if InputValue("mousedy") ~= 0 then
            local offset = -0.2 * InputValue("mousedy")
            STATES.selected_attack_angle = FdClamp(STATES.selected_attack_angle + offset, 20, 90)
        end

        local transform_player_current = GetPlayerCameraTransform()
        transform_player_current.rot = PLAYER_LOCK_TRANSFORM.rot
        SetCameraTransform(transform_player_current)
    else
        SetBool("game.input.locktool", false)
    end

    -- User dismiss crash disclaimer
    if InputPressed("K") then
        ClearKey("savegame.mod.crash_disclaimer")
    end

    -- User cycling selected shell spec event
    if InputPressed(CfgGetValue("KEYBIND_CYCLE_SHELLS")) then
        STATES.selected_shell = (STATES.selected_shell % #SHELL_VALUES) + 1

        if SHELL_VALUES[STATES.selected_shell].variants[STATES.selected_variant] == nil then
            STATES.selected_variant = 1
        end

        PlaySound(SND_UI["select"], sound_pos, 0.6)
    end

    -- User cycling selected shell variant event
    if InputPressed(CfgGetValue("KEYBIND_CYCLE_VARIANTS")) then
        if #SHELL_VALUES[STATES.selected_shell].variants <= 1 then
            PlaySound(SND_UI["cancel"], sound_pos, 0.4)
        else
            STATES.selected_variant = (STATES.selected_variant % #SHELL_VALUES[STATES.selected_shell].variants) + 1
            PlaySound(SND_UI["select"], sound_pos, 0.6)
        end
    end

    -- User cancel quick salvo planning event
    if InputPressed(CfgGetValue("KEYBIND_GENERAL_CANCEL")) and STATES.quicksalvo.enabled then
        QUICK_SALVO = {}
        PlaySound(SND_UI["cancel"], sound_pos, 0.4)

        STATES.quicksalvo.enabled = false
    end

    -- User toggling quick salvo event
    if InputPressed(CfgGetValue("KEYBIND_TOGGLE_QUICKSALVO")) then
        STATES.quicksalvo.enabled = not STATES.quicksalvo.enabled
        PlaySound(SND_UI["select"], sound_pos, 0.6)
    end

    if InputPressed(CfgGetValue("KEYBIND_TOGGLE_QUICKSALVO_MARKERS")) then
        STATES.quicksalvo.markers = (STATES.quicksalvo.markers - 1) % 3
        PlaySound(SND_UI["select"], sound_pos, 0.6)
    end

    local aim_pos = FdGetAimPos()


    -- Check if currently in tactical mode, prevents user from firing if no valid target
    if STATES.tactical.enabled then
        ContextTacticalTick(delta)
        aim_pos = STATES.tactical.hitscan.pos

        -- No valid target
        if not STATES.tactical.hitscan.hit then return end
    end

    UI_HELPERS.shell_telemetry.combined_transform,
    UI_HELPERS.shell_telemetry.arrow_pitch_pos,
    UI_HELPERS.shell_telemetry.arrow_heading_pos =
        FdDrawShellImpactGizmo(
            {
                aim_pos,
                STATES.selected_attack_heading,
                STATES.selected_attack_angle
            },
            STATES.shell_inaccuracy, 64, COLOUR["yellow_dark"], 6
        )

    if not InputPressed(CfgGetValue("KEYBIND_PRIMARY_FIRE")) then
        return
    end

    -- -------------------------------
    -- User has pressed the fire button
    -- -------------------------------

    local values = SHELL_VALUES[STATES.selected_shell]
    local variant = values.variants[STATES.selected_variant]

    if Projectiles.getTypes()[variant.id] ~= nil then
        local state = STATES.quicksalvo.enabled and SHELL_STATE.QUEUED or SHELL_STATE.ACTIVE

        local delay = 0
        if STATES.quicksalvo.enabled then
            delay = STATES.quicksalvo.delay + G_QUICK_SALVO_DELAY
            STATES.quicksalvo.delay = delay
        end

        Projectiles.init(variant.id, {
            requested_destination = VecCopy(aim_pos),
            deviation = STATES.shell_inaccuracy,
            timeToDestination = DEFAULT_SHELL.eta,
            delay = delay,
            attack = {
                heading = STATES.selected_attack_heading,
                pitch = STATES.selected_attack_angle,
            },
            state = state
        })
    else
        local shell_whistle = values.sounds.whistle;
        if type(values.sounds.whistle) == "table" then
            local rand = math.random(#values.sounds.whistle)
            shell_whistle = values.sounds.whistle[rand]
        end

        local shell_sprite = values.sprite
        if FdAssertTableKeys(variant, "sprite") then
            shell_sprite = variant.sprite
        end

        -- Instantiate shell
        ---@type Shell
        local shell = FdObjectNew({
            type = STATES.selected_shell,
            variant = STATES.selected_variant,
            inaccuracy = STATES.shell_inaccuracy,
            pitch = STATES.selected_attack_angle,
            heading = STATES.selected_attack_heading,
            sprite = shell_sprite,
            snd_whistle = LoadLoop("MOD/assets/snd/" .. shell_whistle .. ".ogg")
        }, DEFAULT_SHELL)

        shell.destination = aim_pos

        -- Fire shell manually
        if not STATES.quicksalvo.enabled then
            ShellInit(shell)
            return
        end

        -- Queue shell in quick salvo
        shell.state = SHELL_STATE.QUEUED
        shell.delay = G_QUICK_SALVO_DELAY
        table.insert(QUICK_SALVO, shell)
    end

    PlaySound(SND_UI["salvo_mark"], sound_pos, 0.4)
end

---@diagnostic disable-next-line: lowercase-global
function update(delta)
    for index, projectile in ipairs(__PROJECTILES) do
        Projectiles.update(projectile, delta)

        if projectile.state == SHELL_STATE.NONE or projectile.state == SHELL_STATE.DETONATED then
            DebugPrint(string.format("Removing %s projectile at index %d...", projectile.type, index))
            table.remove(__PROJECTILES, index)
        end
    end

    -- Run shell tick for each shell not detonated, remove shell if detonated
    for i, shell in ipairs(SHELLS) do
        ShellTick(shell, delta)

        if shell.state == SHELL_STATE.DETONATED then
            FdLog("Shell " .. i .. " detonated. Removing...")
            table.remove(SHELLS, i)
        end
    end

    local shells_length = #SHELLS
    if shells_length < G_MAX_SHELLS then return end

    local trim_amount = shells_length - G_MAX_SHELLS
    FdLog("Removing " .. trim_amount .. " shells from table...")

    for _ = 1, trim_amount do
        table.remove(SHELLS, 1)
    end
end

---@diagnostic disable-next-line: lowercase-global
function draw()
    if not STATES.enabled or GetPlayerVehicle() ~= 0 then
        return
    end

    local values = SHELL_VALUES[STATES.selected_shell]

    if STATES.tactical.enabled then
        ContextTacticalDraw()
    else
        if InputDown(KEYBINDS["KEYBIND_ADJUST_ATTACK"]) then
            FdDrawUIShellImpactGizmo()
        end
    end

    for _, projectile in ipairs(Projectiles.getProjectiles()) do
        Projectiles.draw(projectile)
    end

    FdUiContainer(function()
        UiTranslate(80, UiHeight() - 375)
        UiColor(1, 1, 1)
        UiAlign("left")
        UiFont("regular.ttf", 26)
        UiTextShadow(0, 0, 0, 1, 1, 1)

        FdUiContainer(function()
            KeybindHint("KEYBIND_TACTICAL_TOGGLE", "Toggle Tactical Mode")
            KeybindHint("KEYBIND_CYCLE_SHELLS", "Cycle shells [" .. values.name .. "]")
            KeybindHint("KEYBIND_CYCLE_VARIANTS",
                "Cycle variants [" .. values.variants[STATES.selected_variant].name .. "]")
            KeybindHint({ "KEYBIND_ADJUST_ATTACK", "mousemove" }, "Change shell incoming pitch/heading")
            KeybindHint({ "KEYBIND_ADJUST_INACCURACY", "scroll" },
                "Change shell inaccuracy [" .. STATES.shell_inaccuracy .. " meter(s)]")
        end, { false, true })

        --Secondary action
        FdUiContainer(function()
            if not STATES.quicksalvo.enabled then
                UiColor(FdGetUnpackedRGBA(COLOUR["white"]))
                KeybindHint("KEYBIND_TOGGLE_QUICKSALVO", "Quick Salvo mode: OFF")
                return
            end

            if #QUICK_SALVO <= 0 then
                UiColor(FdGetUnpackedRGBA(COLOUR["yellow"]))
                KeybindHint("KEYBIND_TOGGLE_QUICKSALVO", "Quick Salvo mode: ON")
                return
            end

            UiColor(FdGetUnpackedRGBA(COLOUR["red"]))
            KeybindHint("KEYBIND_TOGGLE_QUICKSALVO", "Quick Salvo mode: Launch " .. #QUICK_SALVO .. " shells")
        end, { false, true })

        --Primary action
        FdUiContainer(function()
            if STATES.quicksalvo.enabled then
                KeybindHint("KEYBIND_PRIMARY_FIRE", "Mark location for salvo")
                return
            end

            UiColor(FdGetUnpackedRGBA(COLOUR["red"]))
            KeybindHint("KEYBIND_PRIMARY_FIRE", "Fire " .. values.name)
        end, { false, true })

        --Quicksalvo actions
        FdUiContainer(function()
            UiColor(1, 1, 1)
            KeybindHint("KEYBIND_TOGGLE_QUICKSALVO_MARKERS",
                "Toggle Quick Salvo Markers [" .. FdGetEnumValue(DISPLAY_STATE, STATES.quicksalvo.markers) .. "]")

            if not STATES.quicksalvo.enabled then return end

            KeybindHint({ "KEYBIND_ADJUST_DELAY", "scroll" },
                "Change shell delay [" .. G_QUICK_SALVO_DELAY .. " second(s)]")

            if #QUICK_SALVO > 0 then
                UiColor(1, 1, 0.1)
                KeybindHint("KEYBIND_GENERAL_CANCEL", "Cancel salvo")
            end
        end, { false, true })
    end, false)

    if HasKey("savegame.mod.crash_disclaimer") then
        UiFont("bold.ttf", 26)
        UiColor(0.3, 1, 0.3)
        UiText("", true)
        UiText(
            "NOTICE: The crash to desktop issue has been resolved. Quicksaving should work as intended. Thank you for your patience.",
            true)
        UiText("NOTICE: Press 'K' to dismiss and never show this message again.", true)
    end
end

-- #endregion Main
