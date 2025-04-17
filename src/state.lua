---@enum (key) StateKeyRef
local keyRef = {
    ["UserShell"] = "selected_shell",
    ["UserVariant"] = "selected_variant",
    ["UserHeading"] = "selected_attack_heading",
    ["UserAngle"] = "selected_attack_angle",
    ["UserAccuracy"] = "shell_inaccuracy",
}

STATES = {
    enabled = false,
    fire = false,

    selected_shell = 1,
    selected_variant = 1,
    selected_attack_angle = 90,
    selected_attack_heading = 90,

    input_attack_invert = false,

    shell_inaccuracy = CfgGetValue("G_SHELL_INACCURACY"),
}

STATES.quicksalvo = {
    enabled = false,
    markers = DISPLAY_STATE.VISIBLE,
}

STATES.tactical = {
    enabled = false,

    mouse_pos = {},
    hitscan = {
        hit = false,
        pos = Vec(),
        dist = nil
    },
    camera_settings = {
        camera_transform = nil,
        target_camera_fov = nil,
        current_camera_fov = nil
    },
    camera_defaults = {}
}

local DEFAULT_STATE = STATES

local function parseKey(key)
    return FdSplitString(key, ".")
end

function ResetToDefaultState()
    STATES = DEFAULT_STATE
end

---Get value from state table
---@param keyOrKeyRef StateKeyRef|string
---@return any
function GetStateValue(keyOrKeyRef)
    local key = keyOrKeyRef
    if keyRef[keyOrKeyRef] ~= nil then key = keyRef[keyOrKeyRef] end

    local path = parseKey(key)

    local head = STATES
    for _, seg in ipairs(path) do
        head = head[seg]

        if head == nil then return nil end
    end

    return head
end
