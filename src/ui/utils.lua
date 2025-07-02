UI_IMAGE = {
    KEY_IDLE = {
        src = "img/ui/key_idle.png",
        slice = { x = 12.5, y = 8 },
        padding = 8,
    }
}

function FdUiLoadImageMetadata()
    for key, value in pairs(UI_IMAGE) do
        UI_IMAGE[key].size = { UiGetImageSize(value.src) }
    end
end

local function normalizeTranslateAxis(translate)
    if translate == true then
        translate = { true, true }
    elseif translate == false then
        translate = { false, false }
    end

    return translate or { true, false }
end

---Draw key icon image
---@param bind string
---@param scale? number Size multiple of icon resolution
---@param translate? boolean | [boolean, boolean]
---@return number Key icon width
---@return number Key icon height
function FdUiKeyIcon(bind, scale, translate)
    scale = scale or 1
    local img = UI_IMAGE.KEY_IDLE

    local label = CfgGetKeyFriendlyName(bind) or bind
    local size = { x = img.size[1] * scale, y = img.size[2] * scale }
    local slice = { x = img.slice.x * scale, y = img.slice.y * scale }
    local is_pressed = InputDown(CfgGetKeybind(bind))

    local w, h = FdUiContainer(function()
        UiAlign("left middle")

        UiFont("bold.ttf", math.floor(math.max(10, 28 * scale)))
        UiTextUniformHeight(true)
        UiTextShadow(0, 0, 0, 0, 0)

        UiColor(1, 1, 1, 1)

        local text_width, text_height = UiGetTextSize(label)
        local w = string.len(label) == 1 and size.x or
            math.max(size.x, text_width + img.slice.x * 2)
        local h = string.len(label) == 1 and size.y or
            math.max(size.y, text_height + img.slice.y * 2)

        UiBeginFrame()

        UiPush()
        UiColor(0, 0, 0, 0)
        UiRect(w, h)
        UiColor(0, 0, 0, 0.5)
        UiTranslate(2, 2)
        UiRoundedRect(w, h, 3)
        UiPop()

        UiPush()

        UiFrameSkipItem(true)
        if is_pressed then UiTranslate(1, 1) end
        UiImageBox(img.src, w, h, img.slice.x, img.slice.y)

        UiPush()
        UiAlign("left middle")
        UiTranslate(slice.x, -6 * scale)
        UiColor(0, 0, 0, 1)
        UiText(label, false)
        UiPop()

        UiPop()

        local fw, fh = UiEndFrame()

        UiFrameOccupy(fw, fh)
    end, translate)

    return w, h
end

---@param children table<function> | function
---@param translate? boolean | [boolean, boolean]
---@return number Width
---@return number Height
function FdUiContainer(children, translate)
    if type(children) ~= "table" then
        children = { children }
    end

    translate = normalizeTranslateAxis(translate)

    UiPush()
    UiBeginFrame()

    for _, child in ipairs(children) do
        child()
    end

    local w, h = UiEndFrame()
    UiPop()
    if translate[1] then UiTranslate(w, 0) end
    if translate[2] then UiTranslate(0, h) end

    return w, h
end
