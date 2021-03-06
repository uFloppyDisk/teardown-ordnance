#include "constants.lua"
#include "shell.lua"

SHELLS_prev_length = 0
SHELLS = {}
QUICK_SALVO = {}

DEBUG_LINES = {}
DEBUG_POSITIONS = {}

-- #region Main

function fire_shell(shell)
    shellFire(shell)
    table.insert(SHELLS, shell)
end

function init()
    RegisterTool("ordnance", "Ordnance", "MOD/vox/lasergun.vox")
    SetBool("game.tool.ordnance.enabled", true)

    if CONFIG_init() then
        dPrint("Restoring configuration defaults...")
        CONFIG_reset()
    else
        dPrint("Config exists and is complete.")
    end

    G_DEV = CONFIG_getConfValue("G_DEBUG_MODE")
    G_QUICK_SALVO_DELAY = CONFIG_getConfValue("G_QUICK_SALVO_DELAY")
    DEFAULT_SHELL.flight_time = CONFIG_getConfValue("G_FLIGHT_TIME")
    DEFAULT_SHELL.inaccuracy = CONFIG_getConfValue("G_SHELL_INACCURACY")

    STATES = {
        enabled = false,
        fire = false,
        quick_salvo = false,
        selected_shell = 1,
        selected_variant = 1,

        shell_inaccuracy = CONFIG_getConfValue("G_SHELL_INACCURACY")
    }

    DELAYS = {
        quick_salvo = G_QUICK_SALVO_DELAY
    }

    KEYBINDS = {
        ["KEYBIND_CYCLE_SHELLS"] = CONFIG_getConfValue("KEYBIND_CYCLE_SHELLS"),
        ["KEYBIND_CYCLE_VARIANTS"] = CONFIG_getConfValue("KEYBIND_CYCLE_VARIANTS"),
        ["KEYBIND_ADJUST_INACCURACY"] = CONFIG_getConfValue("KEYBIND_ADJUST_INACCURACY"),
        ["KEYBIND_GENERAL_CANCEL"] = CONFIG_getConfValue("KEYBIND_GENERAL_CANCEL"),
    }

    SND_UI = {}
    SND_UI["select"]                = LoadSound("MOD/snd/menu_select.ogg")
    SND_UI["cancel"]                = LoadSound("MOD/snd/menu_cancel.ogg")
    SND_UI["salvo_mark"]            = LoadSound("MOD/snd/salvo_mark.ogg")
end

function tick(delta)
    dWatch("state(ENABLED)", STATES.enabled)
    dWatch("state(FIRE)", STATES.fire)
    dWatch("state(QUICK SALVO)", STATES.quick_salvo)
    dWatch("state(SELECTED SHELL)", STATES.selected_shell)
    dWatch("state(SELECTED VARIANT)", STATES.selected_variant)
    dWatch("option(FLIGHT_TIME)", CONFIG_getConfValue("G_FLIGHT_TIME"))
    dWatch("option(SHELL_INACCURACY)", STATES.shell_inaccuracy)
    dWatch("Shells", #SHELLS)
    dWatch("Salvo", #QUICK_SALVO)

    if (SHELLS_prev_length ~= #SHELLS) then
        SHELLS_prev_length = #SHELLS
    end

    local queue_length = #QUICK_SALVO
    if queue_length > 0 then
        for i=1, queue_length do
            local shell = QUICK_SALVO[i]
            DrawLine(shell.destination, VecAdd(shell.destination, Vec(0, 5, 0)), 1, 0, 0, 0.8)
            drawCircle(shell.destination, shell.inaccuracy, 32)
        end
    end

    for i, shell in ipairs(SHELLS) do
        shellTick(shell, delta)

        if shell.state == SHELL_STATES.detonated then
            dPrint("Shell "..i.." detonated. Removing...")
            table.remove(SHELLS, i)
        end
	end

    if G_DEV then
        if #DEBUG_POSITIONS > 0 then
            for i, item in pairs(DEBUG_POSITIONS) do
                DebugCross(item[1], item[2][1], item[2][2], item[2][3], 1)
            end
        end

        if #DEBUG_LINES > 0 then
            for i, item in pairs(DEBUG_LINES) do
                DebugLine(item[1], item[2], item[3][1], item[3][2], item[3][3], 1)
            end
        end
    end

    if not STATES.quick_salvo and #QUICK_SALVO > 0 then
        DELAYS.quick_salvo = DELAYS.quick_salvo - delta

        if DELAYS.quick_salvo < 0 then
            local salvo_shell = table.remove(QUICK_SALVO, 1)
            fire_shell(salvo_shell)
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

    -- User change shell inaccuracy event
    if InputDown(CONFIG_getConfValue("KEYBIND_ADJUST_INACCURACY")) then
        SetBool("game.input.locktool", true)

        if InputValue("mousewheel") ~= 0 then
            local offset = 0.5 * InputValue("mousewheel")
            STATES.shell_inaccuracy = clamp(STATES.shell_inaccuracy + offset, 0, 50)
        end
    else
        SetBool("game.input.locktool", false)
    end

    drawCircle(getAimPos(), STATES.shell_inaccuracy, 32, COLOUR["yellow_dark"])

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

        PlaySound(SND_UI["select"], GetPlayerPos(), 0.6)
    end

    -- User cycling selected shell variant event
    if InputPressed(CONFIG_getConfValue("KEYBIND_CYCLE_VARIANTS")) then
        if #SHELL_VALUES[STATES.selected_shell].variants <= 1 then
            PlaySound(SND_UI["cancel"], GetPlayerPos(), 0.4)
        else
            STATES.selected_variant = (STATES.selected_variant % #SHELL_VALUES[STATES.selected_shell].variants) + 1
            PlaySound(SND_UI["select"], GetPlayerPos(), 0.6)
        end
    end

    -- User cancel quick salvo planning event
    if InputPressed(CONFIG_getConfValue("KEYBIND_GENERAL_CANCEL")) and STATES.quick_salvo then
        QUICK_SALVO = {}
        PlaySound(SND_UI["cancel"], GetPlayerPos(), 0.4)

        STATES.quick_salvo = false
    end

    -- User toggling quick salvo event
    if InputPressed(CONFIG_getConfValue("KEYBIND_TOGGLE_QUICKSALVO")) then
        STATES.quick_salvo = not STATES.quick_salvo
        PlaySound(SND_UI["select"], GetPlayerPos(), 0.6)

        if not STATES.quick_salvo and #QUICK_SALVO > 0 then
            fire_shell(table.remove(QUICK_SALVO, 1))
        end
    end

    STATES.fire = InputPressed(CONFIG_getConfValue("KEYBIND_PRIMARY_FIRE"))

    -- User fire event
    if STATES.fire then
        local values = SHELL_VALUES[STATES.selected_shell]
        local variant = values.variants[STATES.selected_variant]

        local shell_whistle = values.sounds.whistle;
        if type(values.sounds.whistle) == "table" then
            local rand = math.random(#values.sounds.whistle)
            shell_whistle = values.sounds.whistle[rand]
        end

        dWatch("Whistle", shell_whistle)

        local shell_sprite = values.sprite
        if assertTableKeys(variant, "sprite") then
            shell_sprite = variant.sprite
        end

        -- Instantiate shell
        local shell = objectNew({
            type = STATES.selected_shell,
            variant = STATES.selected_variant,
            inaccuracy = STATES.shell_inaccuracy,
            sprite = shell_sprite,
            snd_whistle = LoadLoop("MOD/snd/"..shell_whistle..".ogg")
        }, DEFAULT_SHELL)

        shell.destination = getAimPos()

        -- Fire shell manually and return
        if not STATES.quick_salvo then
            fire_shell(shell)
            return
        end

        -- Queue shell in quick salvo
        shell.state = SHELL_STATES.queued
        table.insert(QUICK_SALVO, shell)

        PlaySound(SND_UI["salvo_mark"], GetPlayerPos(), 0.4)
    end
end


function update()
    local shells_length = #SHELLS
    if shells_length > G_MAX_SHELLS then
        local trim_amount = shells_length - G_MAX_SHELLS
        dPrint("Removing "..trim_amount.." shells from table...")

        for i=1, trim_amount do
            table.remove(SHELLS, 1)
        end
    end
end

function draw()
    if not STATES.enabled or GetPlayerVehicle() ~= 0 then
        return
    end

    local values = SHELL_VALUES[STATES.selected_shell]

    UiPush()
        UiTranslate(80, UiMiddle() + UiMiddle() / 2)
        UiColor(0.4, 0.4, 0.4)
        UiAlign("left")
        UiFont("regular.ttf", 26)
        UiTextShadow(0, 0, 0, 1, 1, 1)

        UiPush()
            UiColor(1, 1, 1)
            UiText("<"..KEYBINDS["KEYBIND_CYCLE_SHELLS"].."> | Cycle shells ["..values.name.."]", true)
            UiText("<"..KEYBINDS["KEYBIND_CYCLE_VARIANTS"].."> | Cycle variants ["..values.variants[STATES.selected_variant].name.."]", true)
            UiText("Hold <"..KEYBINDS["KEYBIND_ADJUST_INACCURACY"].."> + <Scroll> | Change shell inaccuracy ["..STATES.shell_inaccuracy.." meter(s)]", true)

            if not(STATES.quick_salvo) then
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