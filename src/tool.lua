#include "constants.lua"
#include "shared/events.lua"

local TIME = 0
local INTERVAL = 600

local SCREEN_MARGIN = { x = 75, y = 50 }

local SELECTED_SHELL = 1
local SELECTED_VARIANT = 1

---@diagnostic disable-next-line: lowercase-global
function init()
    FdRegisterEventListener(EVENT.CHANGE_SHELL, function(id)
        SELECTED_SHELL = tonumber(id)
    end)

    FdRegisterEventListener(EVENT.CHANGE_VARIANT, function(id)
        SELECTED_VARIANT = tonumber(id)
    end)
end

---@diagnostic disable-next-line: lowercase-global
function tick()
    TIME = TIME + 1

    SetToolTransform(Transform(Vec(0, 0, -0.5), QuatEuler(90, 0, 0)))
end

---@diagnostic disable-next-line: lowercase-global
function draw()
    UiPush()
    UiTranslate(SCREEN_MARGIN.x, SCREEN_MARGIN.y)

    do
        local tlx, tly, brx, bry = UiGetCurrentWindow()
        local width = brx - tlx
        local height = bry - tly

        UiWindow(width - SCREEN_MARGIN.x * 2, height - SCREEN_MARGIN.y * 2)
    end

    local rad = TIME % INTERVAL / INTERVAL * math.pi * 2
    local tlx, tly, brx, bry = UiGetCurrentWindow()
    local width = brx - tlx
    local height = bry - tly

    UiColor(0, 1, 0, 0.25 + math.sin(rad) * 0.25)
    UiRect(width, height)

    UiPush()
    UiTranslate(UiCenter(), SCREEN_MARGIN.y / 2)
    UiAlign("center top")
    UiFont("bold.ttf", 36)
    UiColor(1, 1, 1, 1)
    UiText(SHELL_VALUES[SELECTED_SHELL].name, true)
    UiText(SHELL_VALUES[SELECTED_SHELL].variants[SELECTED_VARIANT].name, true)
    UiPop()

    UiPop()
end
