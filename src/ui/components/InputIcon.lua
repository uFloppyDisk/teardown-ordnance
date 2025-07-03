local INPUTS = {
    ["lmb"] = { type = "mouse", img = UI_IMAGE.MOUSE_PRIMARY },
    ["rmb"] = { type = "mouse", img = UI_IMAGE.MOUSE_SECONDARY },
    ["mmb"] = { type = "mouse", img = UI_IMAGE.MOUSE_MIDDLE },
    ["scroll"] = { type = "mouse", img = UI_IMAGE.MOUSE_PLATE },
    ["_default"] = { type = "key", img = UI_IMAGE.KEY_IDLE },
}

local function getScaledDimensions(dim, scale)
    if dim == nil then return {} end
    return { x = (dim.x or dim[1]) * scale, y = (dim.y or dim[2]) * scale }
end

local KEY = function(icon)
    local size = getScaledDimensions(icon.img.size, icon.scale)
    local slice = getScaledDimensions(icon.img.slice, icon.scale)

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
    UiImageBox(icon.img.src, w, h, slice.x, slice.y)

    UiPush()
    UiTextLineSpacing(0)
    UiTranslate(slice.x + 3, -10 * icon.scale)
    UiFont("bold.ttf", math.floor(math.max(10, 36 * icon.scale)))
    UiColor(0, 0, 0, 1)
    UiText(icon.label, false)
    UiPop()

    UiPop()
end

local MOUSE = function(icon)
    local img_plate = UI_IMAGE.MOUSE_PLATE
    local img_button = icon.img
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
---@return table
---@nodiscard
local function getInputFnType(bind)
    local function typeToFn(t)
        return ({
            ["key"] = KEY,
            ["mouse"] = MOUSE,
        })[t] or KEY
    end

    for input, def in pairs(INPUTS) do
        if input == bind then
            return typeToFn(def.type), def
        end
    end

    return typeToFn(INPUTS["_default"].type), INPUTS["_default"]
end

---Draw input icon image with press state
---@param key string
---@param size? number 1:1 size in pixels (minimum size if 9-slice)
---@param translate? boolean | [boolean, boolean]
---@return number Key icon width
---@return number Key icon height
function InputIcon(key, size, translate)
    local bind = CfgGetKeybind(key)
    local Icon, def = getInputFnType(bind)

    local icon = {
        scale = (size or def.img.size[2]) / def.img.size[2],
        label = CfgGetKeyFriendlyName(key) or key,
        bind = bind,
        is_pressed = InputDown(bind),
        img = def.img,
    }

    local w, h = FdUiContainer(function()
        UiAlign("left middle")

        UiTextUniformHeight(true)
        UiTextShadow(0, 0, 0, 0, 0)

        UiColor(1, 1, 1, 1)

        UiBeginFrame()
        Icon(icon)
        local fw, fh = UiEndFrame()

        UiFrameOccupy(fw, fh)
    end, translate)

    return w, h
end
