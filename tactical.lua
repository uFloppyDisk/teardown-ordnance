STATES_TACMARK = {
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
}

CAMERA_ELEVATION_OFFSET_MAX = 200
CAMERA_ELEVATION_OFFSET_MIN = 20

CAMERA_CURRENT_FOV = nil
CAMERA_DEFAULT_FOV = nil

function tactical_init()
    if STATES_TACMARK.camera_settings.camera_transform == nil then
        STATES_TACMARK.camera_settings.camera_transform = getCameraTransform(getPlayerTransform(), Vec(0, 100, 0), QuatEuler(-90, 0, 0))
        CAMERA_DEFAULT_FOV = CONFIG_getConfValue("TACTICAL_DEFAULT_CAMERA_FOV") or 75
        CAMERA_CURRENT_FOV = CAMERA_DEFAULT_FOV
        STATES_TACMARK.camera_settings.target_camera_fov = CAMERA_CURRENT_FOV
        STATES_TACMARK.camera_settings.current_camera_fov = CAMERA_CURRENT_FOV

        STATES_TACMARK.camera_defaults = {unpack(STATES_TACMARK.camera_settings)}
    end
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

function tactical_tick(delta)
    if CONFIG_getConfValue("TACTICAL_POSTPROCESSING_TOGGLE") then
        SetEnvironmentProperty("sunBrightness", clamp(DEFAULT_ENVIRONMENT["sunBrightness"][1], 0, 1))
        SetEnvironmentProperty("brightness", clamp(DEFAULT_ENVIRONMENT["brightness"][1], 1, 1))
        SetPostProcessingProperty("saturation", 0.9)
        SetPostProcessingProperty("colorbalance", 1, 1.75, 0.75)
    end

    SetEnvironmentProperty("fogParams", 0, 0, 0, 0)
    SetEnvironmentProperty("fogColor", 0, 0, 0)
    SetEnvironmentProperty("snowamount", 0, 0)
    SetEnvironmentProperty("snowdir", 0, 0, 0, 0)
    SetEnvironmentProperty("rain", 0)

    local pos_translate = Vec(0, 0, 0)

    -- Camera up/down/left/right key events
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Z_NEG")) then pos_translate[3] = pos_translate[3] - 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Z_POS")) then pos_translate[3] = pos_translate[3] + 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_X_NEG")) then pos_translate[1] = pos_translate[1] - 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_X_POS")) then pos_translate[1] = pos_translate[1] + 1 end

    -- Camera elevation key events
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Y_NEG")) then pos_translate[2] = pos_translate[2] - 1 end
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_Y_POS")) then pos_translate[2] = pos_translate[2] + 1 end

    -- Camera elevation bounds logic
    local current_camera_z = STATES_TACMARK.camera_settings.camera_transform.pos[2]
    if pos_translate[2] > 0 and current_camera_z >= (GetPlayerPos()[2] + CAMERA_ELEVATION_OFFSET_MAX) then
        pos_translate[2] = 0
    end

    if pos_translate[2] < 0 and current_camera_z < (GetPlayerPos()[2] + CAMERA_ELEVATION_OFFSET_MIN) then
        pos_translate[2] = 0
    end

    if not VecEqual(pos_translate, Vec(0, 0, 0)) then
        pos_translate = VecNormalize(pos_translate)
    end

    -- Translate rate scaling based on zoom level and modifier key events
    local translate_default = 50
    local translate = translate_default * (CAMERA_CURRENT_FOV / 75)
    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_MOD_FAST")) then
        translate = translate * 2
    end

    if InputDown(CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_MOD_SLOW")) then
        translate = translate * 0.33
    end

    dWatch("Translate", pos_translate[1].." "..pos_translate[2].." "..pos_translate[3])
    dWatch("Camera Position", STATES_TACMARK.camera_settings.camera_transform.pos)

    -- User input + modifiers to translate vector
    local set_offset_x = pos_translate[1] * translate
    local set_offset_y = pos_translate[2] * translate_default
    local set_offset_z = pos_translate[3] * translate

    local set_offset = VecScale(Vec(set_offset_x, set_offset_y, set_offset_z), delta)

    dWatch("Set Offset", set_offset)

    -- Set new camera transform based on player input
    local camera_transform_new = getCameraTransform(STATES_TACMARK.camera_settings.camera_transform, set_offset)
    STATES_TACMARK.camera_settings.camera_transform = camera_transform_new

    -- Camera zoom key event
    if not InputDown(CONFIG_getConfValue("KEYBIND_ADJUST_INACCURACY")) then
        if InputValue("mousewheel") ~= 0 then
            local offset = -5 * InputValue("mousewheel")
            STATES_TACMARK.camera_settings.target_camera_fov = clamp(STATES_TACMARK.camera_settings.target_camera_fov + offset, 25, 120)
            SetValue("CAMERA_CURRENT_FOV", STATES_TACMARK.camera_settings.target_camera_fov, "linear", 0.15)
        end
    end

    -- Camera reset key event
    if InputPressed(CONFIG_getConfValue("KEYBIND_TACTICAL_CENTER_PLAYER")) then
        camera_transform_new.pos = VecAdd(GetPlayerPos(), Vec(0, 100, 0))
        local reset_fov = CAMERA_DEFAULT_FOV
        SetValue("CAMERA_CURRENT_FOV", reset_fov, "easeout", 0.3)
        STATES_TACMARK.camera_settings.target_camera_fov = reset_fov
    end

    STATES_TACMARK.camera_settings.current_camera_fov = CAMERA_CURRENT_FOV
    SetCameraTransform(camera_transform_new, STATES_TACMARK.camera_settings.current_camera_fov)
end

local function drawGrid(metres, width, world_depth, opacity)
    if opacity < 0.05 then
        return
    end

    local step = metres or 50
    local grid_width, grid_world_depth = width or 1, world_depth or 0
    local alpha = opacity or 1

    local ui_width, ui_height = UiWidth(), UiHeight()
    local point_below = Vec(STATES_TACMARK.camera_settings.camera_transform.pos[1], 0, STATES_TACMARK.camera_settings.camera_transform.pos[3])

    local current_point, current_point_inverted = {}, {}
    local wx, wz = math.ceil(point_below[1] / step) * step, math.ceil(point_below[3] / step) * step

    local iter = 1
    repeat
        local step_invert = ((iter * 2) - 1) * step
        local wxi, wzi = wx - step_invert, wz - step_invert

        current_point = {UiWorldToPixel(Vec(wx, grid_world_depth, wz))}
        current_point[4], current_point[5] = wx, wz

        current_point_inverted = {UiWorldToPixel(Vec(wxi, grid_world_depth, wzi))}
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

local function drawHUDMarker(pos, initial_rect_size, colour)
    local x, y, dist = UiWorldToPixel(pos)
    local rect_colour = colour or getRGBA(COLOUR["white"], 1)
    local rect_size = initial_rect_size or 10
    rect_size = clamp(rect_size * (1 * (100 / (dist * (CAMERA_CURRENT_FOV / 75)))), 10, 30)

    local rect_w, rect_h = rect_size, rect_size

    UiPush()
        UiTranslate(x - (rect_w / 2), y - (rect_h / 2))
        UiColor(unpack(rect_colour))
        UiRect(rect_w, rect_h)
    UiPop()
end

local function drawPlayer()
    drawHUDMarker(GetPlayerPos())
end

local function drawCursor()
    if not STATES_TACMARK.hitscan.hit then
        return
    end

    drawHUDMarker(STATES_TACMARK.hitscan.pos, 10, COLOUR["yellow_dark"])
end

local function drawQueuedSalvo()
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

function tactical_draw()
    UiPush()
        UiMakeInteractive()
        local margins = {}
        margins.x0, margins.y0, margins.x1, margins.y1 = UiSafeMargins()

        UiPush()
            if not InputDown(CONFIG_getConfValue("KEYBIND_ADJUST_ATTACK")) then
                STATES_TACMARK.mouse_pos = {UiGetMousePos()}
            end

            local m_pos = STATES_TACMARK.mouse_pos

            STATES_TACMARK.hitscan.pos,
            STATES_TACMARK.hitscan.hit,
            STATES_TACMARK.hitscan.dist = getMousePosInWorld()

            dWatch("Mouse Position", "{"..m_pos[1]..", "..m_pos[2].."}")
        UiPop()

        local unit_fov = mapToRange(CAMERA_CURRENT_FOV, 25, 120, 0, 1)

        if CONFIG_getConfValue("TACTICAL_DRAW_GRID_TOGGLE") then
            local world_depth = 0
            if InputDown('space') and STATES_TACMARK.hitscan.hit then
                world_depth = STATES_TACMARK.hitscan.pos[2]
            end

            drawGrid(10, 1, world_depth, clamp(mapToRange(unit_fov, 0.35, 0.75, 0.5, 0), 0, 0.5))
            drawGrid(50, 2, world_depth, 0.5)
        end

        drawPlayer()
        drawCursor()
        drawQueuedSalvo()

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
                UiColor(unpack(COLOUR["yellow_dark"]))
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
            UiText(CONFIG_getConfValue("KEYBIND_TACTICAL_CENTER_PLAYER").." - Center player", true)
            UiText("Scroll - Camera zoom", true)
            UiText(CONFIG_KEYBIND_FRIENDLYNAMES[CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_MOD_FAST")].." - Fast camera", true)
            UiText(CONFIG_KEYBIND_FRIENDLYNAMES[CONFIG_getConfValue("KEYBIND_TACTICAL_TRANSLATE_MOD_SLOW")].." - Slow camera", true)

            if CONFIG_getConfValue("TACTICAL_DRAW_GRID_TOGGLE") then
                UiText("Space (hold) - Snap grid to target elevation")
            end

        UiPop()
    UiPop()
end