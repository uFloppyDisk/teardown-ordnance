local TIME = 0
local INTERVAL = 600

---@diagnostic disable-next-line: lowercase-global
function init()
end

---@diagnostic disable-next-line: lowercase-global
function tick()
    TIME = TIME + 1

    SetToolTransform(Transform(Vec(0, -0.2, -0.6), QuatEuler(45, 0, 0)))

    local tool_body = GetToolBody()

    local shapes = GetBodyShapes(tool_body)
    DrawShapeOutline(shapes[2], 1, 0, 0, 1)
end

---@diagnostic disable-next-line: lowercase-global
function draw()
    local rad = TIME % INTERVAL / INTERVAL * math.pi * 2

    UiColor(math.sin(rad), math.sin(rad + math.pi * 0.66), math.sin(rad + math.pi * 1.33), 0.25)
    UiRect(100, 100)
end
