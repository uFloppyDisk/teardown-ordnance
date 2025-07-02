local MOUSE_INPUTS = {
    ["lmb"] = UI_IMAGE.MOUSE_PRIMARY,
    ["rmb"] = UI_IMAGE.MOUSE_SECONDARY,
    ["mmb"] = UI_IMAGE.MOUSE_MIDDLE,
    ["scroll"] = UI_IMAGE.MOUSE_PLATE,
}

local function getScaledDimensions(dim, scale)
    if dim == nil then return {} end
    return { x = dim.x or dim[1] * scale, y = dim.y or dim[2] * scale }
end

local KEY = function(icon, _)
    local img = UI_IMAGE.KEY_IDLE
    local size = getScaledDimensions(img.size, icon.scale)
    local slice = getScaledDimensions(img.slice, icon.scale)

    local text_width, text_height = UiGetTextSize(icon.label)
    local w = string.len(icon.label) == 1 and size.x or
        math.max(size.x, text_width + slice.x * 2)
    local h = string.len(icon.label) == 1 and size.y or
        math.max(size.y, text_height + slice.y * 2)

    UiPush()
    UiColor(0, 0, 0, 0)
    UiRect(w, h)
    UiColor(0, 0, 0, 0.5)
    UiTranslate(2, 2)
    UiRoundedRect(w, h, 3)
    UiPop()

    UiPush()

    UiFrameSkipItem(true)
    if icon.is_pressed then UiTranslate(1, 1) end
    UiImageBox(img.src, w, h, slice.x, slice.y)

    UiPush()
    UiAlign("left middle")
    UiTranslate(slice.x * 0.6, -6 * icon.scale)
    UiColor(0, 0, 0, 1)
    UiText(icon.label, false)
    UiPop()

    UiPop()
end

local MOUSE = function(icon, bind)
    local img_plate = UI_IMAGE.MOUSE_PLATE
    local img_button = MOUSE_INPUTS[bind]
    local img_shadow = UI_IMAGE.MOUSE_SHADOW

    local img_plate_size = getScaledDimensions(img_plate.size, icon.scale)
    local img_button_size = getScaledDimensions(img_button.size, icon.scale)
    local img_shadow_size = getScaledDimensions(img_shadow.size, icon.scale)

    UiPush()
    UiColor(0, 0, 0, 0)
    UiRect(img_plate_size.x, img_plate_size.y)
    UiPop()

    UiPush()
    UiFrameSkipItem(true)

    UiPush()
    UiTranslate(2, 2)
    UiImageBox(img_shadow.src, img_shadow_size.x, img_shadow_size.y, 0, 0)
    UiPop()

    UiPush()
    if icon.is_pressed then UiTranslate(1, 1) end
    UiImageBox(img_plate.src, img_plate_size.x, img_plate_size.y, 0, 0)

    if icon.is_pressed then UiColor(FdGetUnpackedRGBA(COLOUR["red"])) end
    UiImageBox(img_button.src, img_button_size.x, img_button_size.y, 0, 0)
    UiPop()

    UiPop()
end

---Return appropriate UI draw function and type name for input type
---@param bind string
---@return function
---@return string
---@nodiscard
local function getInputFnType(bind)
    for value, _ in pairs(MOUSE_INPUTS) do
        if value == bind then return MOUSE, "mouse" end
    end

    return KEY, "key"
end

---Draw input icon image with press state
---@param key string
---@param scale? number Size multiple of icon resolution
---@param translate? boolean | [boolean, boolean]
---@return number Key icon width
---@return number Key icon height
function InputIcon(key, scale, translate)
    local bind = CfgGetKeybind(key)

    local icon = {
        scale = scale or 1,
        label = CfgGetKeyFriendlyName(key) or key,
        is_pressed = InputDown(bind),
    }

    local Icon, _ = getInputFnType(bind)

    local w, h = FdUiContainer(function()
        UiAlign("left middle")

        UiFont("bold.ttf", math.floor(math.max(10, 28 * icon.scale)))
        UiTextUniformHeight(true)
        UiTextShadow(0, 0, 0, 0, 0)

        UiColor(1, 1, 1, 1)

        UiBeginFrame()
        Icon(icon, bind)
        local fw, fh = UiEndFrame()

        UiFrameOccupy(fw, fh)
    end, translate)

    return w, h
end
