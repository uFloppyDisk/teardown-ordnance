local TIME = 0
local INTERVAL = 600

local SCREEN_SAFE_BOUND_THICKNESS = 2
local SCREEN_MARGIN = { x = 75, y = 50 }

---@diagnostic disable-next-line: lowercase-global
function init()
end

---@diagnostic disable-next-line: lowercase-global
function tick()
    TIME = TIME + 1

    SetToolTransform(Transform(Vec(0, 0, -0.5), QuatEuler(90, 0, 0)))
end

---@diagnostic disable-next-line: lowercase-global
function draw()
    local tlx, tly, brx, bry = UiGetCurrentWindow()
    local width = brx - tlx
    local height = bry - tly

    local rad = TIME % INTERVAL / INTERVAL * math.pi * 2

    UiColor(0, 1, 0, 0.25 + math.sin(rad) * 0.25)
    UiRect(width, height)

    UiPush()
    UiTranslate(SCREEN_MARGIN.x, SCREEN_MARGIN.y)

    UiPush()
    UiColor(1, 1, 1, 1)

    local bound_length = height / 6
    for i = 1, 4, 1 do
        local dim = i % 2 == 0 and height or width
        local margin = i % 2 == 0 and SCREEN_MARGIN.y or SCREEN_MARGIN.x

        UiRect(bound_length, SCREEN_SAFE_BOUND_THICKNESS)
        UiRect(SCREEN_SAFE_BOUND_THICKNESS, bound_length)
        UiTranslate(dim - margin * 2, 0)
        UiRotate(-90)
    end
    UiPop()

    UiPop()
end
