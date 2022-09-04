STATES_TACMARK = {
    enabled = false,

    screen = nil,

    mouse_pos = {},
    camera_transform = nil
}

function getPlayerPos()
    return VecCopy(GetPlayerCameraTransform().pos)
end

function getCameraTransform(pos_original, set_offset, set_rot)
    local offset = set_offset or Vec(0, 0, 0)
    local rot = set_rot or QuatEuler(-90, 0, 0)

    return Transform(VecAdd(pos_original, offset), rot)
end

function tactical_init()
    if STATES_TACMARK.camera_transform == nil then
        STATES_TACMARK.camera_transform = getCameraTransform(getPlayerPos(), Vec(0, 100, 0))
    end
    return UiGetScreen()
end

function tactical_tick(delta)
    local pos_translate = Vec(0, 0, 0)
    local translate = 50
    if InputDown("w") then pos_translate[3] = pos_translate[3] - 1 end
    if InputDown("a") then pos_translate[1] = pos_translate[1] - 1 end
    if InputDown("s") then pos_translate[3] = pos_translate[3] + 1 end
    if InputDown("d") then pos_translate[1] = pos_translate[1] + 1 end
    if InputDown("r") then pos_translate[2] = pos_translate[2] - 1 end
    if InputDown("f") then pos_translate[2] = pos_translate[2] + 1 end
    if InputDown("shift") then translate = translate * 2 end
    if InputDown("ctrl") then translate = translate * 0.33 end

    DebugWatch("Translate", pos_translate[1].." "..pos_translate[2].." "..pos_translate[3])

    local set_offset_x = VecScale(Vec(translate, 0, 0), pos_translate[1])
    local set_offset_y = VecScale(Vec(0, translate, 0), pos_translate[2])
    local set_offset_z = VecScale(Vec(0, 0, translate), pos_translate[3])

    local set_offset = VecAdd(set_offset_x, set_offset_y)
    set_offset = VecAdd(set_offset, set_offset_z)
    set_offset = VecScale(set_offset, delta)

    DebugWatch("Set Offset", set_offset)

    local camera_transform_new = getCameraTransform(STATES_TACMARK.camera_transform.pos, set_offset)
    STATES_TACMARK.camera_transform = camera_transform_new

    SetCameraTransform(camera_transform_new, 90)
end

function tactical_draw(screen)
    if not IsScreenEnabled(screen) then SetScreenEnabled(screen, true) end
    SetPlayerScreen(screen)

    UiPush()
        UiMakeInteractive()
        UiPush()
            STATES_TACMARK.mouse_pos = {UiGetMousePos()}
            local m_pos = STATES_TACMARK.mouse_pos

            dWatch("Mouse Position", "{"..m_pos[1]..", "..m_pos[2].."}")
            dWatch("Direction", UiPixelToWorld(m_pos[1], m_pos[2]))
        UiPop()

        UiPush()
            local x, y, dist = UiWorldToPixel(GetPlayerPos())

            local rect_size = 10
            rect_size = clamp(rect_size * (1 * (100 / dist)), 10, 30)

            local rect_player_w, rect_player_h = rect_size, rect_size

            UiTranslate(x - (rect_player_w / 2), y - (rect_player_h / 2))
            UiColor(1, 1, 1, 1)
            UiRect(rect_player_w, rect_player_h)
        UiPop()

        hit_pos, hit, distance = getMousePosInWorld()

        if not hit then
            return
        end

        drawCircle(hit_pos, STATES.shell_inaccuracy, 32, COLOUR["yellow_dark"])

        if not InputPressed(CONFIG_getConfValue("KEYBIND_PRIMARY_FIRE")) then
            return
        end

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

        shell.destination = hit_pos

        fire_shell(shell)

        DebugPrint("Hit! Distance from camera: "..distance)

        addToDebugTable(DEBUG_POSITIONS, {hit_pos, COLOUR["white"]})
        addToDebugTable(DEBUG_LINES, {STATES_TACMARK.camera_transform.pos, hit_pos, COLOUR["red"]})
    UiPop()
end