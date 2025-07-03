local SIZE_BASE = 36
local SIZE_SMALL = 24

---Draw keybind hint with label
---@param bind string
---@param label? string
---@param size? "base" | "sm"
function KeybindHint(bind, label, size)
    size = size or "base"

    local size_target = SIZE_BASE
    if size == "sm" then
        size_target = SIZE_SMALL
    end

    FdUiContainer(function()
        InputIcon(bind, size_target)
        if label then
            UiPush()
            UiAlign("left middle")
            UiTranslate(8, 0)
            UiText(label, true)
            UiPop()
        end
    end, { label == nil, label ~= nil })
end
