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

function ResetToDefaultState()
  STATES = DEFAULT_STATE
end
