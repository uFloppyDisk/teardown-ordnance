local SIZE_BASE = 36
local SIZE_SMALL = 24

---Draw keybind hint with label
---@param bind string | string[]
---@param label? string
---@param size? "base" | "sm"
function KeybindHint(bind, label, size)
    bind = type(bind) == "string" and { bind } or bind
    size = size or "base"

    local size_target = SIZE_BASE
    if size == "sm" then
        size_target = SIZE_SMALL
    end

    FdUiContainer(function()
        local are_previous_pressed = true
        for _, b in ipairs(bind) do
            local _, _, icon = InputIcon(b, size_target, { true, false }, are_previous_pressed)
            are_previous_pressed = are_previous_pressed and icon.is_pressed
        end
        if label then
            UiPush()
            UiAlign("left middle")
            UiTranslate(8, 0)
            UiText(label, true)
            UiPop()
        end
    end, { label == nil, label ~= nil })
end
