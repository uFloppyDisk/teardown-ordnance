#include "shell.lua"

-- #region Constants

G_DEV = GetBool("savegame.mod.debug_mode")
G_VEC_GRAVITY = Vec(0, -39.2, 0)
-- G_VEC_GRAVITY = Vec(0, 0, 0)

G_MAX_SHELLS = 100
G_QUICK_SALVO_DELAY = GetFloat("savegame.mod.quick_salvo_delay") or 0.5

-- #endregion Constants

-- #region Main

SHELLS_prev_length = 0
SHELLS = {}
QUICK_SALVO = {}

function clamp(value, minimum, maximum)
	if value < minimum then value = minimum end
	if value > maximum then value = maximum end

	return value
end

function getTableLength(t)
    local count = 0

    for _ in pairs(t) do count = count + 1 end
    return count
end

function print(msg)
    if not G_DEV then
        return
    end

    DebugPrint(msg)
end

function watch(name, variable)
    if not G_DEV then
        return
    end

    DebugWatch(name, variable)
end

function fire_shell(shell)
    Shell_fire(shell)
    table.insert(SHELLS, shell)
end

function init()
    RegisterTool("ordnance", "Ordnance", "MOD/vox/lasergun.vox")
    SetBool("game.tool.ordnance.enabled", true)

    STATES = {
        enabled = false,
        fire = false,
        quick_salvo = false
    }

    DELAYS = {
        quick_salvo = G_QUICK_SALVO_DELAY
    }

    IMG_SPRITES = {}
    IMG_SPRITES["155mm_he"]         = LoadSprite("MOD/img/155mm_he.png")

    SND_MENU = {}
    SND_MENU["select"]              = LoadSound("MOD/snd/menu_select.ogg")
    SND_MENU["cancel"]              = LoadSound("MOD/snd/menu_cancel.ogg")

    SND_SHELL = {}
    SND_SHELL["salvo_mark"]         = LoadSound("MOD/snd/salvo_mark.ogg")
    SND_SHELL["60mm_fire"]          = LoadSound("MOD/snd/fire_60mm.ogg")
    SND_SHELL["155mm_fire_close"]   = LoadSound("MOD/snd/fire_155mm_close.ogg")
    SND_SHELL["155mm_fire_far"]     = LoadSound("MOD/snd/fire_155mm_far.ogg")
end

function getAimPos()
	local camera_transform = GetCameraTransform()
	local camera_center = TransformToParentPoint(camera_transform, Vec(0, 0, -150))

    local direction = VecSub(camera_center, camera_transform.pos)
    local distance = VecLength(direction)
	local direction = VecNormalize(direction)

	local hit, hit_distance = QueryRaycast(camera_transform.pos, direction, distance)

	if hit then
		camera_center = TransformToParentPoint(camera_transform, Vec(0, 0, -hit_distance))
		distance = hit_distance
	end

	return camera_center, hit, distance
end

function tick(delta)
    watch("state(ENABLED)", STATES.enabled)
    watch("state(FIRE)", STATES.fire)
    watch("state(QUICK SALVO)", STATES.quick_salvo)
    watch("Shells", getTableLength(SHELLS))
    watch("Salvo", getTableLength(QUICK_SALVO))
    watch("shell_default(FLIGHT_TIME)", GetFloat("savegame.mod.flight_time"))

    if (SHELLS_prev_length ~= getTableLength(SHELLS)) then
        print("Shell Object: "..table.concat(Shell, ", "))
        SHELLS_prev_length = getTableLength(SHELLS)
    end

    local queue_length = getTableLength(QUICK_SALVO)
    if queue_length > 0 then
        for i=1, queue_length do
            shell = QUICK_SALVO[i]
            DrawLine(shell.destination, VecAdd(shell.destination, Vec(0, 5, 0)), 1, 0, 0, 0.8)
        end
    end

    for i, shell in ipairs(SHELLS) do
        Shell_tick(shell, delta)

        if shell.detonated then
            print("Shell "..i.." detonated. Removing...")
            table.remove(SHELLS, i)
        end
	end

    if GetPlayerVehicle() ~= 0 then
        return
    end

	if GetString("game.player.tool") == "ordnance" then
        STATES.enabled = true

        if InputPressed("C") and STATES.quick_salvo then
            QUICK_SALVO = {}
			PlaySound(SND_MENU["cancel"], GetPlayerPos(), 0.4)

            STATES.quick_salvo = false
		end

        if InputPressed("rmb") then
            STATES.quick_salvo = not STATES.quick_salvo
            PlaySound(SND_MENU["select"], GetPlayerPos(), 0.6)

            if not STATES.quick_salvo and getTableLength(QUICK_SALVO) > 0 then
                fire_shell(table.remove(QUICK_SALVO, 1))
            end
        end

        if not STATES.quick_salvo and getTableLength(QUICK_SALVO) > 0 then
            DELAYS.quick_salvo = DELAYS.quick_salvo - delta
            
            if DELAYS.quick_salvo < 0 then
                local salvo_shell = table.remove(QUICK_SALVO, 1)
                fire_shell(salvo_shell)
                DELAYS.quick_salvo = G_QUICK_SALVO_DELAY
            end
        end

        STATES.fire = InputPressed("lmb")

        if STATES.fire then
            local rand = math.random(3)
            local rand_snd = "155mm_whistle_"..tostring(rand)
            watch("Whistle", rand_snd)

            -- local shell = Shell.new(nil, nil, IMG_SPRITES["155mm_he"], LoadLoop("MOD/snd/"..rand_snd..".ogg"))
            local shell = Shell_new({
                sprite = IMG_SPRITES["155mm_he"],
                snd_whistle = LoadLoop("MOD/snd/"..rand_snd..".ogg")
            })

            shell.destination = getAimPos()

            if STATES.quick_salvo then
                PlaySound(SND_SHELL["salvo_mark"], GetPlayerPos(), 0.4)
                shell.queued = true
                table.insert(QUICK_SALVO, shell)
            else
                fire_shell(shell)
            end
        end
	else
        STATES.enabled = false
	end
end


function update()
    local shells_length = getTableLength(SHELLS)
    if shells_length > G_MAX_SHELLS then
        local trim_amount = shells_length - G_MAX_SHELLS
        print("Removing "..trim_amount.." shells from table...")

        for i=1, trim_amount do
            table.remove(SHELLS, 1)
        end
    end
end


function draw()
    if not(STATES.enabled) or GetPlayerVehicle() ~= 0 then
        return
    end

    UiPush()
        UiTranslate(80, UiMiddle()+UiMiddle()/2)
        UiColor(0.4, 0.4, 0.4)
        UiAlign("left")
        UiFont("regular.ttf", 26)
        UiTextOutline(0,0,0,1,0.2)

        UiPush()
            UiColor(1, 1, 1)
            if not(STATES.quick_salvo) then
                UiColor(1, 1, 1)
                UiText("<Right Mouse> - Quick Salvo mode: OFF", true)
                
                UiColor(1, 0.3, 0.3)
                UiText("<Left Mouse> - Fire 155mm shell", true)
            else
                if getTableLength(QUICK_SALVO) > 0 then
                    UiColor(1, 0.3, 0.3)
                    UiText("<Right Mouse> - Quick Salvo mode: Launch "..getTableLength(QUICK_SALVO).." shells", true)

                    UiColor(1, 1, 1)
                    UiText("<Left Mouse> - Mark location for salvo", true)

                    UiColor(1, 1, 0.1)
                    UiText("C - Cancel salvo", true)
                else
                    UiColor(1, 1, 0.1)
                    UiText("<Right Mouse> - Quick Salvo mode: ON", true)

                    UiColor(1, 1, 1)
                    UiText("<Left Mouse> - Mark location for salvo", true)
                end
            end
            UiColor(0.4, 0.4, 0.4)
        UiPop()
    UiPop()
end

-- #endregion Main