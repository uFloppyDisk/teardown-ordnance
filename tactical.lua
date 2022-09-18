STATES_TACMARK = {
    enabled = false,

    screen = nil,

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
}

CAMERA_CURRENT_FOV = nil

function tactical_init()
    if STATES_TACMARK.camera_settings.camera_transform == nil then
        STATES_TACMARK.camera_settings.camera_transform = getCameraTransform(getPlayerTransform(), Vec(0, 100, 0), QuatEuler(-90, 0, 0))
        CAMERA_CURRENT_FOV = CONFIG_getConfValue("TACTICAL_DEFAULT_CAMERA_FOV") or 75
        STATES_TACMARK.camera_settings.target_camera_fov = CAMERA_CURRENT_FOV
        STATES_TACMARK.camera_settings.current_camera_fov = CAMERA_CURRENT_FOV

        STATES_TACMARK.camera_defaults = {unpack(STATES_TACMARK.camera_settings)}
    end

    if CONFIG_getConfValue("TACTICAL_POSTPROCESSING_TOGGLE") then
        SetPostProcessingProperty("saturation", 0.9)
        SetPostProcessingProperty("colorbalance", 1, 1.75, 0.75)
    end

    SetEnvironmentProperty("fogParams", 0, 0, 0, 0)
    SetEnvironmentProperty("fogColor", 0, 0, 0)
    SetEnvironmentProperty("snowamount", 0, 0)
    SetEnvironmentProperty("snowdir", 0, 0, 0, 0)

    return UiGetScreen()
end

function tactical_tick(delta)
    local pos_translate = Vec(0, 0, 0)

    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Z_NEG")) then pos_translate[3] = pos_translate[3] - 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_X_NEG")) then pos_translate[1] = pos_translate[1] - 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Z_POS")) then pos_translate[3] = pos_translate[3] + 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_X_POS")) then pos_translate[1] = pos_translate[1] + 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Y_NEG")) then pos_translate[2] = pos_translate[2] - 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Y_POS")) then pos_translate[2] = pos_translate[2] + 1 end

    if not VecEqual(pos_translate, Vec(0, 0, 0)) then
        pos_translate = VecNormalize(pos_translate)
    end

    local translate = 50 * (STATES_TACMARK.camera_settings.current_camera_fov / 75)
    local rotate = 50
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_MOD_FAST")) then
        translate = translate * 2
        rotate = rotate * 2
    end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_MOD_SLOW")) then
        translate = translate * 0.33
        rotate = rotate * 0.33
    end

    dWatch("Translate", pos_translate[1].." "..pos_translate[2].." "..pos_translate[3])
    dWatch("Camera Position", STATES_TACMARK.camera_settings.camera_transform.pos)

    if pos_translate[2] > 0 and STATES_TACMARK.camera_settings.camera_transform.pos[2] >= (GetPlayerPos()[2] + 200) then
        pos_translate[2] = 0
    end

    if pos_translate[2] < 0 and STATES_TACMARK.camera_settings.camera_transform.pos[2] < (GetPlayerPos()[2] + 20) then
        pos_translate[2] = 0
    end

    local set_offset_x = pos_translate[1] * translate
    local set_offset_y = pos_translate[2] * 50
    local set_offset_z = pos_translate[3] * translate

    local set_offset = VecScale(Vec(set_offset_x, set_offset_y, set_offset_z), delta)

    dWatch("Set Offset", set_offset)

    local rot_rotate = 0
    if InputDown("q") then rot_rotate = rot_rotate + 1 end
    if InputDown("e") then rot_rotate = rot_rotate - 1 end

    local set_rotate = rotate * rot_rotate
    set_rotate = set_rotate * delta
    set_rotate = QuatEuler(0, 0, set_rotate)

    local camera_transform_new = getCameraTransform(STATES_TACMARK.camera_settings.camera_transform, set_offset)

    STATES_TACMARK.camera_settings.camera_transform = camera_transform_new

    if not InputDown(CONFIG_getConfValue("KEYBIND_ADJUST_INACCURACY")) then
        if InputValue("mousewheel") ~= 0 then
            local offset = -5 * InputValue("mousewheel")
            STATES_TACMARK.camera_settings.target_camera_fov = clamp(STATES_TACMARK.camera_settings.target_camera_fov + offset, 25, 120)
            SetValue("CAMERA_CURRENT_FOV", STATES_TACMARK.camera_settings.target_camera_fov, "linear", 0.15)
        end
    end

    if InputPressed(CONFIG_getConfValue("KEYBIND_TACTICAL_CENTER_PLAYER")) then
        camera_transform_new.pos = VecAdd(GetPlayerPos(), Vec(0, 100, 0))
        local reset_fov = CONFIG_getConfValue("TACTICAL_DEFAULT_CAMERA_FOV") or 75
        SetValue("CAMERA_CURRENT_FOV", reset_fov, "easeout", 0.3)
        STATES_TACMARK.camera_settings.target_camera_fov = reset_fov
    end

    STATES_TACMARK.camera_settings.current_camera_fov = CAMERA_CURRENT_FOV

    SetCameraTransform(camera_transform_new, STATES_TACMARK.camera_settings.current_camera_fov)
end

function tactical_hitscan()
    if not STATES_TACMARK.hitscan.hit then
        return
    end

    if InputPressed(CONFIG_getConfValue("KEYBIND_PRIMARY_FIRE")) then
        dPrint("Hit! Distance from camera: "..STATES_TACMARK.hitscan.dist)

        addToDebugTable(DEBUG_POSITIONS, {STATES_TACMARK.hitscan.pos, COLOUR["white"]})
        addToDebugTable(DEBUG_LINES, {STATES_TACMARK.camera_settings.camera_transform.pos, STATES_TACMARK.hitscan.pos, COLOUR["red"]})
    end

    return STATES_TACMARK.hitscan.pos
end

function tactical_draw(screen)
    function drawGrid(metres, width, depth, opacity)
        local step = metres or 50
        local grid_width, grid_depth = width or 1, depth or 0
        local alpha = opacity or 1

        local ui_width, ui_height = UiWidth(), UiHeight()
        local point_below = Vec(STATES_TACMARK.camera_settings.camera_transform.pos[1], 0, STATES_TACMARK.camera_settings.camera_transform.pos[3])

        local current_point, current_point_inverted = {}, {}
        local wx, wz = math.ceil(point_below[1] / step) * step, math.ceil(point_below[3] / step) * step

        local iter = 1
        repeat
            local step_invert = ((iter * 2) - 1) * step
            local wxi, wzi = wx - step_invert, wz - step_invert

            current_point = {UiWorldToPixel(Vec(wx, grid_depth, wz))}
            current_point[4], current_point[5] = wx, wz

            current_point_inverted = {UiWorldToPixel(Vec(wxi, grid_depth, wzi))}
            current_point_inverted[4], current_point_inverted[5] = wxi, wzi

            UiPush()
                UiColor(0, 0, 0, alpha)
                UiPush()
                    UiTranslate(current_point[1], 0)
                    UiRect(grid_width, ui_height)
                UiPop()
                UiPush()
                    UiTranslate(0, current_point[2])
                    UiRect(ui_width, grid_width)
                UiPop()
                UiPush()
                    UiTranslate(current_point_inverted[1], 0)
                    UiRect(grid_width, ui_height)
                UiPop()
                UiPush()
                    UiTranslate(0, current_point_inverted[2])
                    UiRect(ui_width, grid_width)
                UiPop()
            UiPop()

            wx, wz = wx + step, wz + step
            iter = iter + 1
        until (current_point[1] > ui_width and current_point[2] > ui_height)
    end
    function drawPlayer()
        UiPush()
            local x, y, dist = UiWorldToPixel(GetPlayerPos())

            local rect_size = 10
            rect_size = clamp(rect_size * (1 * (100 / (dist * (STATES_TACMARK.camera_settings.current_camera_fov / 75)))), 10, 30)

            local rect_player_w, rect_player_h = rect_size, rect_size

            UiTranslate(x - (rect_player_w / 2), y - (rect_player_h / 2))
            UiColor(unpack(getRGBA(COLOUR["white"], 1)))
            UiRect(rect_player_w, rect_player_h)
        UiPop()
    end
    function drawCursor()
        if not STATES_TACMARK.hitscan.hit then
            return
        end

        UiPush()
            local x, y, dist = UiWorldToPixel(STATES_TACMARK.hitscan.pos)

            local rect_size = 10
            rect_size = clamp(rect_size * (1 * (100 / (dist * (STATES_TACMARK.camera_settings.current_camera_fov / 75)))), 5, 15)

            local rect_w, rect_h = rect_size, rect_size

            UiTranslate(x - (rect_w / 2), y - (rect_h / 2))
            UiColor(unpack(getRGBA(COLOUR["yellow_dark"], 1)))
            UiRect(rect_w, rect_h)
        UiPop()
    end
    function drawQueuedSalvo()
        if #QUICK_SALVO > 0 then
            for i, shell in ipairs(QUICK_SALVO) do
                local x, y, dist = UiWorldToPixel(shell.destination)
                local rect_size = 10
                rect_size = clamp(rect_size * (1 * (100 / (dist * (STATES_TACMARK.camera_settings.current_camera_fov / 75)))), 5, 15)
                local rect_w, rect_h = rect_size, rect_size

                local shell_type = SHELL_VALUES[shell.type]

                UiPush()
                    UiTranslate(x - (rect_w / 2), y - (rect_h / 2))

                    if CONFIG_getConfValue("TACTICAL_SHELL_LABELS_TOGGLE") then
                        UiPush()
                            UiTranslate(rect_size * 1.33, 0)
                            UiColor(1, 1, 1)
                            UiAlign("left")
                            UiFont("regular.ttf", 18)
                            UiTextShadow(0, 0, 0, 1, 1, 1)

                            UiText(shell_type.name, true)
                            UiText(shell_type.variants[shell.variant].name)
                        UiPop()
                    end

                    UiColor(unpack(getRGBA(COLOUR["red"], 0.75)))
                    UiRect(rect_w, rect_h)
                UiPop()
            end
        end
    end

    if not IsScreenEnabled(screen) then SetScreenEnabled(screen, true) end
    SetPlayerScreen(screen)

    UiPush()
        UiMakeInteractive()
        local margins = {}
        margins.x0, margins.y0, margins.x1, margins.y1 = UiSafeMargins()

        UiPush()
            STATES_TACMARK.mouse_pos = {UiGetMousePos()}
            local m_pos = STATES_TACMARK.mouse_pos

            STATES_TACMARK.hitscan.pos,
            STATES_TACMARK.hitscan.hit,
            STATES_TACMARK.hitscan.dist = getMousePosInWorld()

            dWatch("Mouse Position", "{"..m_pos[1]..", "..m_pos[2].."}")
        UiPop()

        UiPush()
            UiTranslate(80, UiMiddle() / 6)
            UiColor(1, 1, 1)
            UiAlign("left")
            UiFont("regular.ttf", 48)
            UiTextShadow(0, 0, 0, 1, 1, 1)

            UiText("Tactical Ordnance Mode", true)

            UiFont("regular.ttf", 22)
            UiPush()
                UiColor(unpack(COLOUR["white"]))
                UiRect(20, 20)
                UiTranslate(24, 16)
                UiColor(unpack(COLOUR["white"]))
                UiText("Player position")
            UiPop()
            UiTranslate(0, 28)
            UiPush()
                UiColor(unpack(COLOUR["yellow"]))
                UiRect(20, 20)
                UiTranslate(24, 16)
                UiColor(unpack(COLOUR["white"]))
                UiText("Valid target", true)
            UiPop()
            UiTranslate(0, 28)
            UiPush()
                UiColor(unpack(COLOUR["red"]))
                UiRect(20, 20)
                UiTranslate(24, 16)
                UiColor(unpack(COLOUR["white"]))
                UiText("Quick Salvo target", true)
            UiPop()
            UiTranslate(0, 48)

            UiPush()
                UiText(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Z_NEG"))
                UiTranslate(24, 0)
                UiText("|")
                UiTranslate(8, 0)
                UiText(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Z_POS"))
                UiTranslate(16, 0)
                UiText("- Up | Down")
            UiPop()
            UiTranslate(0, 28)
            UiPush()
                UiText(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_X_NEG"))
                UiTranslate(24, 0)
                UiText("|")
                UiTranslate(8, 0)
                UiText(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_X_POS"))
                UiTranslate(16, 0)
                UiText("- Left | Right")
            UiPop()
            UiTranslate(0, 28)
            UiPush()
                UiText(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Y_NEG"))
                UiTranslate(24, 0)
                UiText("|")
                UiTranslate(8, 0)
                UiText(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Y_POS"))
                UiTranslate(16, 0)
                UiText("- Elevation Down | Up")
            UiPop()
            UiTranslate(0, 28)
            UiText(CONFIG_KEYBIND_FRIENDLYNAMES[CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_MOD_FAST")].." - Fast camera", true)
            UiText(CONFIG_KEYBIND_FRIENDLYNAMES[CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_MOD_SLOW")].." - Slow camera", true)
            UiText("Scroll - Camera zoom", true)
            UiText(CONFIG_getConfValue("KEYBIND_TACTICAL_CENTER_PLAYER").." - Center player", true)
        UiPop()

        local unit_fov = mapToRange(CAMERA_CURRENT_FOV, 25, 120, 0, 1)

        drawGrid(10, 1, nil, clamp(mapToRange(unit_fov, 0.35, 0.75, 0.5, 0), 0, 0.5))
        drawGrid(50, 2, nil, 0.5)
        drawPlayer()
        drawCursor()
        drawQueuedSalvo()
    UiPop()
end