local SIZE_BASE = 0.7
local SIZE_SMALL = 0.55

---Draw keybind hint with label
---@param bind string
---@param label? string
---@param size? "base" | "sm"
function KeybindHint(bind, label, size)
    size = size or "base"

    local scale = SIZE_BASE
    if size == "sm" then
        scale = SIZE_SMALL
    end

    FdUiContainer(function()
        FdUiKeyIcon(CfgGetKeyFriendlyName(bind), scale)
        if label then
            UiTranslate(8, 8 * scale)
            UiText(label, true)
        end
    end, { label == nil, label ~= nil })
end
