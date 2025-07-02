local function normalizeTranslateAxis(translate)
    if translate == true then
        translate = { true, true }
    elseif translate == false then
        translate = { false, false }
    end

    return translate or { true, false }
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
