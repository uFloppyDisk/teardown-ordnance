local MOUSE_MOVE_THRESHOLD = 3
local MOUSE_MOVE_MAGNITUDE = 10
local DAMPENED_RANGE = 255
local DAMPENED_DURATION = 0.2

local INPUTS = {
    ["lmb"] = { type = "mouse", img = UI_IMAGE.MOUSE_PRIMARY },
    ["rmb"] = { type = "mouse", img = UI_IMAGE.MOUSE_SECONDARY },
    ["mmb"] = { type = "mouse", img = UI_IMAGE.MOUSE_MIDDLE },
    ["scroll"] = { type = "mouse", img = UI_IMAGE.MOUSE_PLATE },
    ["mousemove"] = { type = "mouse", img = UI_IMAGE.MOUSE_PLATE },
    ["mousedx"] = { type = "mouse", img = UI_IMAGE.MOUSE_PLATE },
    ["mousedy"] = { type = "mouse", img = UI_IMAGE.MOUSE_PLATE },
    ["_default"] = { type = "key", img = UI_IMAGE.KEY_IDLE },
}

local dampened = {
    scroll = 0,
    dx = 0,
    dy = 0,
}

local function getScaledDimensions(dim, scale)
    if dim == nil then return {} end
    return { x = (dim.x or dim[1]) * scale, y = (dim.y or dim[2]) * scale }
end

local function directionMagnitude(n1, n2)
    return VecLength(VecAdd(Vec(n1, 0, 0), Vec(0, n2, 0)))
end

local function hasDirection(n1, n2)
    return directionMagnitude(n1, n2) ~= 0
end

local function dampenValue(key, value, max, min_magnitude)
    max = max or 1
    min_magnitude = (min_magnitude ~= nil and min_magnitude) or 0

    if math.abs(value) <= min_magnitude then return end

    dampened[key] = FdClamp(value / max * DAMPENED_RANGE, -DAMPENED_RANGE, DAMPENED_RANGE)
    SetValueInTable(dampened, key, 0, "linear", DAMPENED_DURATION)
end

local function dampenedToScale(key)
    return dampened[key] / DAMPENED_RANGE
end

local setActiveColour = function(mag)
    mag = mag or 1
    local saturation = (1 - 0.2) * FdClamp(mag, 0, 1)
    UiColor(1, 1 - saturation, 1 - saturation, 1)
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
    local img_shadow = UI_IMAGE.MOUSE_SHADOW

    local size = getScaledDimensions(img_plate.size, icon.scale)

    local bound_to_btn =
        icon.bind == "lmb" or
        icon.bind == "rmb" or
        icon.bind == "mmb"
    local bound_to_move =
        icon.bind == "mousemove" or
        icon.bind == "mousedx" or
        icon.bind == "mousedy"
    local bound_to_scroll = icon.bind == "scroll"

    local pre_dx, pre_dy = (function()
        if not bound_to_move then return 0, 0 end

        local dx = InputValue("mousedx")
        local dy = InputValue("mousedy")

        if directionMagnitude(dx, dy) <= MOUSE_MOVE_THRESHOLD then
            return dx, dy
        end

        if dx >= dy then
            return dx, (math.abs(dy) > MOUSE_MOVE_THRESHOLD and dy) or 0
        end

        return (math.abs(dx) > MOUSE_MOVE_THRESHOLD and dx) or 0, dy
    end)()

    dampenValue("dx", pre_dx, MOUSE_MOVE_MAGNITUDE)
    dampenValue("dy", pre_dy, MOUSE_MOVE_MAGNITUDE)

    local dx = dampenedToScale("dx")
    local dy = dampenedToScale("dy")

    UiPush()
    UiColor(0, 0, 0, 0)
    UiRect(size.x, size.y)
    UiPop()

    UiPush()
    UiFrameSkipItem(true)

    local can_be_active = icon.can_be_active
    if can_be_active and bound_to_move then
        UiTranslate(dx * 0.5, dy * 0.5)
    end

    UiPush()
    UiTranslate(2, 2)
    UiImageBox(img_shadow.src, size.x, size.y, 0, 0)
    UiPop()

    UiPush()

    if icon.is_pressed then UiTranslate(1, 1) end
    UiImageBox(img_plate.src, size.x, size.y, 0, 0)

    local _ = (function()
        if not bound_to_btn then return end

        if icon.is_pressed then setActiveColour() end
        UiImageBox(icon.img.src, size.x, size.y, 0, 0)
    end)()

    local _ = (function()
        if not bound_to_move then return end

        local img_move = UI_IMAGE.MOUSE_MOVE_BASE
        local img_move_up = UI_IMAGE.MOUSE_MOVE_UP
        local img_move_down = UI_IMAGE.MOUSE_MOVE_DOWN
        local img_move_left = UI_IMAGE.MOUSE_MOVE_LEFT
        local img_move_right = UI_IMAGE.MOUSE_MOVE_RIGHT

        UiPush()
        if can_be_active then
            setActiveColour(1 - directionMagnitude(dx, dy))
        end
        UiImageBox(img_move.src, size.x, size.y, 0, 0)
        UiPop()

        if icon.bind == "mousemove" or icon.bind == "mousedx" then
            UiImageBox(img_move_left.src, size.x, size.y, 0, 0)
            UiImageBox(img_move_right.src, size.x, size.y, 0, 0)
        end

        if icon.bind == "mousemove" or icon.bind == "mousedy" then
            UiImageBox(img_move_up.src, size.x, size.y, 0, 0)
            UiImageBox(img_move_down.src, size.x, size.y, 0, 0)
        end

        if not can_be_active or not hasDirection(dx, dy) then return end

        UiPush()

        setActiveColour(math.abs(dx))
        if dx ~= 0 then UiImageBox((dx < 0 and img_move_left.src) or img_move_right.src, size.x, size.y, 0, 0) end

        setActiveColour(math.abs(dy))
        if dy ~= 0 then UiImageBox((dy < 0 and img_move_up.src) or img_move_down.src, size.x, size.y, 0, 0) end

        UiPop()
    end)()

    local _ = (function()
        if not bound_to_scroll then return end

        local img_scroll = UI_IMAGE.MOUSE_SCROLL_BASE
        local img_scroll_up = UI_IMAGE.MOUSE_SCROLL_UP
        local img_scroll_down = UI_IMAGE.MOUSE_SCROLL_DOWN

        UiImageBox(img_scroll.src, size.x, size.y, 0, 0)
        UiImageBox(img_scroll_up.src, size.x, size.y, 0, 0)
        UiImageBox(img_scroll_down.src, size.x, size.y, 0, 0)

        if not can_be_active then return end

        dampenValue("scroll", InputValue("mousewheel"), 1)
        if dampened.scroll == 0 then return end

        UiPush()
        setActiveColour(math.abs(dampened.scroll) / DAMPENED_RANGE)

        UiImageBox((dampened.scroll < 0 and img_scroll_down.src) or img_scroll_up.src, size.x, size.y, 0, 0)

        UiPop()
    end)()

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

---Draw input icon image with pressed and active state
---@param key string
---@param size? number 1:1 size in pixels (minimum size if 9-slice)
---@param translate? boolean | [boolean, boolean]
---@param can_be_active? boolean Should input show activity, defaults to true
---@return number Key icon width
---@return number Key icon height
---@return table icon icon data
function InputIcon(key, size, translate, can_be_active)
    if can_be_active == nil then can_be_active = true end
    local bind = CfgGetKeybind(key)
    local Icon, def = getInputFnType(bind)

    local icon = {
        scale = (size or def.img.size[2]) / def.img.size[2],
        label = CfgGetKeyFriendlyName(key) or key,
        bind = bind,
        is_pressed = InputDown(bind),
        can_be_active = can_be_active,
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

    return w, h, icon
end
