local SIZE_BASE = 36
local SIZE_SMALL = 24

local GAP_BETWEEN = 12

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
        local plus_pos = {}
        local scale = 0

        for index, current_bind in ipairs(bind) do
            local w, _, icon = InputIcon(current_bind, size_target, { true, false }, are_previous_pressed)
            if index ~= #bind then UiTranslate(GAP_BETWEEN, 0) end

            are_previous_pressed = are_previous_pressed and icon.is_pressed
            if index > 1 then table.insert(plus_pos, w) end
            scale = math.max(scale, icon.scale)
        end

        UiPush()
        UiAlign("center middle")
        UiFont("bold.ttf", 56 * scale)
        UiColor(1, 1, 1)
        UiTranslate(GAP_BETWEEN / 2, 0)
        for i = #plus_pos, 1, -1 do
            UiTranslate(-plus_pos[i] - GAP_BETWEEN, 0)
            UiText("+")
        end
        UiPop()

        if label then
            UiPush()
            UiAlign("left middle")
            UiTranslate(8, 0)
            UiText(label, true)
            UiPop()
        end
    end, { label == nil, label ~= nil })
end
