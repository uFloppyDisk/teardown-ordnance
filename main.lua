#include "constants.lua"
---@diagnostic disable-next-line: exp-in-action
#include "funcs/shell/main.lua"
---@diagnostic disable-next-line: exp-in-action
#include "tactical.lua"

ELAPSED_TIME = 0

SHELLS = {}
BODIES = {}
QUICK_SALVO = {}

DEBUG_LINES = {}
DEBUG_POSITIONS = {}

DEFAULT_ENVIRONMENT = {}
DEFAULT_POSTPROCESSING = {}

PLAYER_LOCK_TRANSFORM = nil


-- #region Main

function init()
    RegisterTool("ordnance", "Ordnance", "MOD/vox/lasergun.vox")
    SetBool("game.tool.ordnance.enabled", true)

    if CONFIG_init() then
        dPrint("Restoring configuration defaults...")
        CONFIG_reset()
    else
        dPrint("Config exists and is complete.")
    end

    G_DEV = CONFIG_getConfValue("G_DEBUG_MODE") or false
    G_QUICK_SALVO_DELAY = CONFIG_getConfValue("G_QUICK_SALVO_DELAY") or 0.5
    DEFAULT_SHELL.flight_time = CONFIG_getConfValue("G_FLIGHT_TIME")
    DEFAULT_SHELL.inaccuracy = CONFIG_getConfValue("G_SHELL_INACCURACY")

    -- total, hit, miss, redirected
    FRAG_STATS = {
        0, 0, 0, 0
    }

    STATES = {
        enabled = false,
        fire = false,

        selected_shell = 1,
        selected_variant = 1,
        selected_attack_angle = 90,
        selected_attack_heading = 90,

        input_attack_invert = false,

        shell_inaccuracy = CONFIG_getConfValue("G_SHELL_INACCURACY"),

        quicksalvo = {
            enabled = false,
            markers = qs_display.VISIBLE,
        },

        tactical = {
            enabled = false,

            mouse_pos = {},
            hitscan = {
                hit = false,
                pos = Vec(),
                dist = nil
            },
            camera_settings = {
                camera_transform = nil,
                target_camera_fov = nil,
                current_camera_fov = nil
            },
            camera_defaults = {}
        },
    }

    DELAYS = {
        quick_salvo = G_QUICK_SALVO_DELAY
    }

    KEYBINDS = {
        ["KEYBIND_TACTICAL_TOGGLE"] = CONFIG_getConfValue("KEYBIND_TACTICAL_TOGGLE"),
        ["KEYBIND_CYCLE_SHELLS"] = CONFIG_getConfValue("KEYBIND_CYCLE_SHELLS"),
        ["KEYBIND_CYCLE_VARIANTS"] = CONFIG_getConfValue("KEYBIND_CYCLE_VARIANTS"),
        ["KEYBIND_ADJUST_ATTACK"] = CONFIG_getConfValue("KEYBIND_ADJUST_ATTACK"),
        ["KEYBIND_ADJUST_INACCURACY"] = CONFIG_getConfValue("KEYBIND_ADJUST_INACCURACY"),
        ["KEYBIND_GENERAL_CANCEL"] = CONFIG_getConfValue("KEYBIND_GENERAL_CANCEL"),
        ["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"] = CONFIG_getConfValue("KEYBIND_TOGGLE_QUICKSALVO_MARKERS"),
    }

    UI_HELPERS = {
        player_camera = nil,
        shell_telemetry = {
            combined_transform = nil,
            arrow_pitch_pos = nil,
            arrow_heading_pos = nil
        }
    }

    SND_UI = {}
    SND_UI["select"]                = LoadSound("MOD/snd/menu_select.ogg")
    SND_UI["cancel"]                = LoadSound("MOD/snd/menu_cancel.ogg")
    SND_UI["salvo_mark"]            = LoadSound("MOD/snd/salvo_mark.ogg")
end

function tick(delta)
    ELAPSED_TIME = ELAPSED_TIME + delta

    dWatch("state(ENABLED)", STATES.enabled)
    dWatch("state(QUICK SALVO)", STATES.quicksalvo.enabled)
    dWatch("option(FLIGHT_TIME)", CONFIG_getConfValue("G_FLIGHT_TIME"))
    dWatch("Shells", #SHELLS)
    dWatch("Salvo", #QUICK_SALVO)

    -- Draw HUD markers for quick salvo shell targets
    draw_quicksalvo_markers(STATES.quicksalvo.markers)

    -- Fire remaining quick salvo shells with delay if currently not in quick salvo mode
    if not STATES.quicksalvo.enabled and #QUICK_SALVO > 0 then
        DELAYS.quick_salvo = DELAYS.quick_salvo - delta

        if DELAYS.quick_salvo < 0 then
            local salvo_shell = table.remove(QUICK_SALVO, 1)
            shell_init(salvo_shell)
            DELAYS.quick_salvo = G_QUICK_SALVO_DELAY
        end
    else
        DELAYS.quick_salvo = G_QUICK_SALVO_DELAY
    end

    if GetPlayerVehicle() ~= 0 then
        STATES.enabled = false
        return
    end

    if not(GetString("game.player.tool") == "ordnance") then
        STATES.enabled = false
        return
    end

    -- -------------------------------
    -- Tool is active and ready to use
    -- -------------------------------

    STATES.enabled = true
    local sound_pos = GetCameraTransform().pos

    draw_debug()

    -- User toggles tactical marking mode
    if InputPressed(CONFIG_getConfValue("KEYBIND_TACTICAL_TOGGLE")) then
        if not STATES.tactical.enabled then
            DEFAULT_ENVIRONMENT["fogcolor"] = {GetEnvironmentProperty("fogcolor")}
            DEFAULT_ENVIRONMENT["fogParams"] = {GetEnvironmentProperty("fogParams")}
            DEFAULT_ENVIRONMENT["snowamount"] = {GetEnvironmentProperty("snowamount")}
            DEFAULT_ENVIRONMENT["snowdir"] = {GetEnvironmentProperty("snowdir")}
            DEFAULT_ENVIRONMENT["sunBrightness"] = {GetEnvironmentProperty("sunBrightness")}
            DEFAULT_ENVIRONMENT["rain"] = {GetEnvironmentProperty("rain")}
            DEFAULT_ENVIRONMENT["brightness"] = {GetEnvironmentProperty("brightness")}
            DEFAULT_ENVIRONMENT["exposure"] = {GetEnvironmentProperty("exposure")}

            DEFAULT_POSTPROCESSING["saturation"] = {GetPostProcessingProperty("saturation")}
            DEFAULT_POSTPROCESSING["colorbalance"] = {GetPostProcessingProperty("colorbalance")}

            tactical_init()
        end

        if STATES.tactical.enabled then
            setEnvProps(DEFAULT_ENVIRONMENT)
            setPostProcProps(DEFAULT_POSTPROCESSING)
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
    if InputDown(CONFIG_getConfValue("KEYBIND_ADJUST_INACCURACY")) then
        SetBool("game.input.locktool", true)

        if InputValue("mousewheel") ~= 0 then
            local value = 0.5
            if STATES.shell_inaccuracy >= 15 then value = 1 end
            if STATES.shell_inaccuracy >= 50 then value = 2.5 end
            if STATES.shell_inaccuracy >= 100 then value = 5 end

            local offset = value * InputValue("mousewheel")
            STATES.shell_inaccuracy = clamp(STATES.shell_inaccuracy + offset, 0, 150)
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
            STATES.selected_attack_angle = clamp(STATES.selected_attack_angle + offset, 20, 90)
        end

        local transform_player_current = GetPlayerCameraTransform()
        transform_player_current.rot = PLAYER_LOCK_TRANSFORM.rot
        SetCameraTransform(transform_player_current, true)
    else
        SetBool("game.input.locktool", false)
    end

    -- User dismiss crash disclaimer
    if InputPressed("K") then
        ClearKey("savegame.mod.crash_disclaimer")
    end

    -- User cycling selected shell spec event
    if InputPressed(CONFIG_getConfValue("KEYBIND_CYCLE_SHELLS")) then
        STATES.selected_shell = (STATES.selected_shell % #SHELL_VALUES) + 1

        if SHELL_VALUES[STATES.selected_shell].variants[STATES.selected_variant] == nil then
            STATES.selected_variant = 1
        end

        PlaySound(SND_UI["select"], sound_pos, 0.6)
    end

    -- User cycling selected shell variant event
    if InputPressed(CONFIG_getConfValue("KEYBIND_CYCLE_VARIANTS")) then
        if #SHELL_VALUES[STATES.selected_shell].variants <= 1 then
            PlaySound(SND_UI["cancel"], sound_pos, 0.4)
        else
            STATES.selected_variant = (STATES.selected_variant % #SHELL_VALUES[STATES.selected_shell].variants) + 1
            PlaySound(SND_UI["select"], sound_pos, 0.6)
        end
    end

    -- User cancel quick salvo planning event
    if InputPressed(CONFIG_getConfValue("KEYBIND_GENERAL_CANCEL")) and STATES.quicksalvo.enabled then
        QUICK_SALVO = {}
        PlaySound(SND_UI["cancel"], sound_pos, 0.4)

        STATES.quicksalvo.enabled = false
    end

    -- User toggling quick salvo event
    if InputPressed(CONFIG_getConfValue("KEYBIND_TOGGLE_QUICKSALVO")) then
        STATES.quicksalvo.enabled = not STATES.quicksalvo.enabled
        PlaySound(SND_UI["select"], sound_pos, 0.6)

        if not STATES.quicksalvo.enabled and #QUICK_SALVO > 0 then
            shell_init(table.remove(QUICK_SALVO, 1))
        end
    end

    if InputPressed(CONFIG_getConfValue("KEYBIND_TOGGLE_QUICKSALVO_MARKERS")) then
        STATES.quicksalvo.markers = (STATES.quicksalvo.markers - 1) % 3
        PlaySound(SND_UI["select"], sound_pos, 0.6)
    end

    local aim_pos = getAimPos()

    -- Check if currently in tactical mode, prevents user from firing if no valid target
    if STATES.tactical.enabled then
        tactical_tick(delta)
        aim_pos = STATES.tactical.hitscan.pos

        -- No valid target
        if not STATES.tactical.hitscan.hit then return end
    end

    UI_HELPERS.shell_telemetry.combined_transform,
    UI_HELPERS.shell_telemetry.arrow_pitch_pos,
    UI_HELPERS.shell_telemetry.arrow_heading_pos =
    drawShellImpactGizmo(
        {
            aim_pos,
            STATES.selected_attack_heading,
            STATES.selected_attack_angle
        },
        STATES.shell_inaccuracy, 64, COLOUR["yellow_dark"], 6
    )

    if not InputPressed(CONFIG_getConfValue("KEYBIND_PRIMARY_FIRE")) then
        return
    end

    -- -------------------------------
    -- User has pressed the fire button
    -- -------------------------------

    local values = SHELL_VALUES[STATES.selected_shell]
    local variant = values.variants[STATES.selected_variant]

    local shell_whistle = values.sounds.whistle;
    if type(values.sounds.whistle) == "table" then
        local rand = math.random(#values.sounds.whistle)
        shell_whistle = values.sounds.whistle[rand]
    end

    local shell_sprite = values.sprite
    if assertTableKeys(variant, "sprite") then
        shell_sprite = variant.sprite
    end

    -- Instantiate shell
    local shell = objectNew({
        type = STATES.selected_shell,
        variant = STATES.selected_variant,
        inaccuracy = STATES.shell_inaccuracy,
        pitch = STATES.selected_attack_angle,
        heading = STATES.selected_attack_heading,
        sprite = shell_sprite,
        snd_whistle = LoadLoop("MOD/snd/"..shell_whistle..".ogg")
    }, DEFAULT_SHELL)

    shell.destination = aim_pos

    -- Fire shell manually
    if not STATES.quicksalvo.enabled then
        shell_init(shell)
        return
    end

    -- Queue shell in quick salvo
    shell.state = shell_states.QUEUED
    table.insert(QUICK_SALVO, shell)

    PlaySound(SND_UI["salvo_mark"], sound_pos, 0.4)
end

function update(delta)
    -- Run shell tick for each shell not detonated, remove shell if detonated
    for i, shell in ipairs(SHELLS) do
        shell_tick(shell, delta)

        if shell.state == shell_states.DETONATED then
            dPrint("Shell "..i.." detonated. Removing...")
            table.remove(SHELLS, i)
        end
	end

    dWatch("BODIES", #BODIES)
    for i, body in ipairs(BODIES) do
        if body.valid == true and manage_bodies(body) then
            body.valid = false
        end

        if body.valid == true and (ELAPSED_TIME - body.created_at) > 20 then
            Delete(body.handle)
            body.valid = false
        end

        if not body.valid then
            table.remove(BODIES, i)
        end
    end

    -- local active_phosphorus = FindBodies('fd_ord_wp', true)
    -- if #active_phosphorus > 0 then
    --     dWatch("ACTIVE WP", true)
    --     dWatch("WP AMOUNT", #active_phosphorus)
    --     for index, body in ipairs(active_phosphorus) do
    --         local point = GetBodyCenterOfMass(body)

    --         ParticleReset()
    --         ParticleRadius(5)
    --         ParticleColor(1, 0, 0)
    --         ParticleEmissive(100)
    --         SpawnParticle(point, Vec(0, 0, 0), 5)
    --     end
    -- end

    local shells_length = #SHELLS
    if shells_length < G_MAX_SHELLS then return end

    local trim_amount = shells_length - G_MAX_SHELLS
    dPrint("Removing "..trim_amount.." shells from table...")

    for i=1, trim_amount do
        table.remove(SHELLS, 1)
    end
end

function draw()
    if not STATES.enabled or GetPlayerVehicle() ~= 0 then
        return
    end

    local values = SHELL_VALUES[STATES.selected_shell]

    if STATES.tactical.enabled then
        tactical_draw()
    end

    if InputDown(KEYBINDS["KEYBIND_ADJUST_ATTACK"]) then
        if not STATES.tactical.enabled then
            drawUIShellImpactGizmo()
        end
    end

    UiPush()
        UiTranslate(80, UiMiddle() + UiMiddle() / 1.85)
        UiColor(0.4, 0.4, 0.4)
        UiAlign("left")
        UiFont("regular.ttf", 26)
        UiTextShadow(0, 0, 0, 1, 1, 1)

        UiPush()
            UiColor(1, 1, 1)
            UiText("<"..KEYBINDS["KEYBIND_TACTICAL_TOGGLE"].."> | Toggle Tactical Mode", true)
            UiText("<"..KEYBINDS["KEYBIND_CYCLE_SHELLS"].."> | Cycle shells ["..values.name.."]", true)
            UiText("<"..KEYBINDS["KEYBIND_CYCLE_VARIANTS"].."> | Cycle variants ["..values.variants[STATES.selected_variant].name.."]", true)
            UiText("Hold <"..KEYBINDS["KEYBIND_ADJUST_ATTACK"].."> + <Move Mouse> | Change shell incoming pitch/heading", true)
            UiText("Hold <"..KEYBINDS["KEYBIND_ADJUST_INACCURACY"].."> + <Scroll> | Change shell inaccuracy ["..STATES.shell_inaccuracy.." meter(s)]", true)

            if not(STATES.quicksalvo.enabled) then
                UiColor(1, 1, 1)
                UiText("<Right Mouse> | Quick Salvo mode: OFF", true)

                UiColor(1, 0.2, 0.2)
                UiText("<Left Mouse> | Fire "..values.name, true)
            else
                if #QUICK_SALVO > 0 then
                    UiColor(1, 0.3, 0.3)
                    UiText("<Right Mouse> | Quick Salvo mode: Launch "..#QUICK_SALVO.." shells", true)
                else
                    UiColor(1, 1, 0.1)
                    UiText("<Right Mouse> | Quick Salvo mode: ON", true)
                end

                UiColor(1, 1, 1)
                UiText("<Left Mouse> | Mark location for salvo", true)
                UiText("<"..KEYBINDS["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"].."> | Toggle Quick Salvo Markers ["..enum_value(qs_display, STATES.quicksalvo.markers).."]", true)

                if #QUICK_SALVO > 0 then
                    UiColor(1, 1, 0.1)
                    UiText("<"..KEYBINDS["KEYBIND_GENERAL_CANCEL"].."> | Cancel salvo", true)
                end
            end

            if HasKey("savegame.mod.crash_disclaimer") then
                UiFont("bold.ttf", 26)
                UiColor(0.3, 1, 0.3)
                UiText("", true)
                UiText("NOTICE: The crash to desktop issue has been resolved. Quicksaving should work as intended. Thank you for your patience.", true)
                UiText("NOTICE: Press 'K' to dismiss and never show this message again.", true)
            end

            UiColor(0.4, 0.4, 0.4)
        UiPop()
    UiPop()
end

-- #endregion Main

-- #region functions

--- Draw debug lines and positions.
function draw_debug()
    if not G_DEV then return end

    if #DEBUG_POSITIONS > 0 then
        for i, item in pairs(DEBUG_POSITIONS) do
            DebugCross(item[1], item[2][1], item[2][2], item[2][3], item[2][4] or 1)
        end
    end

    if #DEBUG_LINES > 0 then
        for i, item in pairs(DEBUG_LINES) do
            DebugLine(item[1], item[2], item[3][1], item[3][2], item[3][3], item[3][4] or 1) -- assertTableKeys(item[3], 4) and item[3][4] or 1)
        end
    end
end

---@param display qs_display
function draw_quicksalvo_markers(display)
    if display == qs_display.HIDDEN then return end

    local queue_length = #QUICK_SALVO
    if queue_length <= 0 then return end

    for i=1, queue_length do
        local shell = QUICK_SALVO[i]

        if display == qs_display.MINIMAL then
            local pos = VecAdd(shell.destination, Vec(0, 0.03, 0))
            drawCircle(pos, 0.2, 8, COLOUR["red"])
        else
            drawShellImpactGizmo(
                {shell.destination, shell.heading, shell.pitch},
                shell.inaccuracy, 32, COLOUR["red"], 2
            )
        end
    end
end

-- #endregion functions