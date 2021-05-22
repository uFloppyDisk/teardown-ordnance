#include "shell.lua"

-- #region Constants

G_DEV = false
G_VEC_GRAVITY = Vec(0, -39.2, 0)
-- G_VEC_GRAVITY = Vec(0, 0, 0)

G_MAX_SHELLS = 100

-- #endregion Constants

-- #region Main

shells = {}

function clamp(value, minimum, maximum)
	if value < minimum then 
        value = minimum 
    end

	if value > maximum then 
        value = maximum
    end

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

function init()
    RegisterTool("ordnance", "Ordnance", "MOD/vox/lasergun.vox")
    SetBool("game.tool.ordnance.enabled", true)

    g_tool_enabled = false
    g_state_fire = false

    img_sprites = {}
    img_sprites["155mm_he"] = LoadSprite("MOD/img/155mm_he.png")

    snd_menu = {}
    snd_menu["select"] = LoadSound("MOD/snd/select.ogg")

    snd_shell = {}
    snd_shell["60mm_fire"]          = LoadSound("MOD/snd/fire_60mm.ogg")
    snd_shell["155mm_fire_close"]   = LoadSound("MOD/snd/fire_155mm_close.ogg")
    snd_shell["155mm_fire_far"]     = LoadSound("MOD/snd/fire_155mm_far.ogg")
end

function GetAimPos()
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
    for i, shell in ipairs(shells) do
        shell:tick(delta)

        if shell.detonated then
            print("Shell "..i.." detonated. Removing...")
            table.remove(shells, i)
        end
	end

    if GetPlayerVehicle() ~= 0 then
        return
    end

	if GetString("game.player.tool") == "ordnance" then
        g_tool_enabled = true

        if InputPressed("C") then
			PlaySound(snd_menu["select"], GetPlayerPos(), 0.4)
		end

        g_state_fire = InputPressed("lmb")

        if g_state_fire then
            print("Firing shell...")

            local rand = math.random(3)
            local rand_snd = "155mm_whistle_"..tostring(rand)
            watch("Whistle", rand_snd)
            local shell = Shell:new(nil, nil, img_sprites["155mm_he"], LoadLoop("MOD/snd/"..rand_snd..".ogg"))
            destination = GetAimPos()
            shell:setDest(destination)

            PlaySound(snd_shell["155mm_fire_far"], VecAdd(GetPlayerPos(), Vec(100, 0, 100)), 20)
            shell:fire()
            table.insert(shells, shell)
        end
	else
        g_tool_enabled = false
	end
end


function update()
    local shells_length = getTableLength(shells)
    watch("Shells", shells_length)
    if shells_length > G_MAX_SHELLS then
        local trim_amount = shells_length - G_MAX_SHELLS
        print("Removing "..trim_amount.." shells from table...")

        for i=1, trim_amount do
            table.remove(shells, 1)
        end
    end
end


function draw()
    if not(g_tool_enabled) or GetPlayerVehicle() ~= 0 then
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
            UiText("Left Mouse: Fire 155mm shell")
            -- UiTranslate(0, 30)
            -- UiText("Right-Click: Plane-view")
        UiPop()
    UiPop()
end

-- #endregion Main