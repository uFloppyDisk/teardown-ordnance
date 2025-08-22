G_DEV = false
G_VEC_GRAVITY = Vec(0, -39.2, 0)
G_VEC_WIND = Vec(-0.15, 0.03, 0.06)

G_MAX_SHELLS = 100
G_QUICK_SALVO_DELAY = 0

G_CONFIG_ROOT = "savegame.mod.config"
G_CONFIG_KEYBINDS_ROOT = G_CONFIG_ROOT .. ".keybind"
G_CONFIG_KEYBINDS_TAC = G_CONFIG_KEYBINDS_ROOT .. ".tactical"

-- #region Colours

---@type { [string]: TColour }
COLOUR = {
    ["white"]       = { 1, 1, 1, 1 },
    ["red"]         = { 1, 0.2, 0.2, 1 },
    ["yellow"]      = { 1, 1, 0, 1 },
    ["yellow_dark"] = { 1, 0.8, 0, 1 },
    ["orange"]      = { 1, 0.6, 0.2, 1 },
    ["green"]       = { 0.2, 1, 0.2, 1 },
}

-- Source: http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html
---@type { [number]: TColour}
BLACKBODY = {
    [1000] = { 1.0000, 0.0401, 0.0000 },
    [1100] = { 1.0000, 0.0631, 0.0000 },
    [1200] = { 1.0000, 0.0860, 0.0000 },
    [1300] = { 1.0000, 0.1085, 0.0000 },
    [1400] = { 1.0000, 0.1303, 0.0000 },
    [1500] = { 1.0000, 0.1515, 0.0000 },
    [1600] = { 1.0000, 0.1718, 0.0000 },
    [1700] = { 1.0000, 0.1912, 0.0000 },
    [1800] = { 1.0000, 0.2097, 0.0000 },
    [1900] = { 1.0000, 0.2272, 0.0000 },
    [2000] = { 1.0000, 0.2484, 0.0061 },
    [2100] = { 1.0000, 0.2709, 0.0153 },
    [2200] = { 1.0000, 0.2930, 0.0257 },
    [2300] = { 1.0000, 0.3149, 0.0373 },
    [2400] = { 1.0000, 0.3364, 0.0501 },
    [2500] = { 1.0000, 0.3577, 0.0640 },
    [2600] = { 1.0000, 0.3786, 0.0790 },
    [2700] = { 1.0000, 0.3992, 0.0950 },
    [2800] = { 1.0000, 0.4195, 0.1119 },
    [2900] = { 1.0000, 0.4394, 0.1297 },
    [3000] = { 1.0000, 0.4589, 0.1483 },
    [3100] = { 1.0000, 0.4781, 0.1677 },
    [3200] = { 1.0000, 0.4970, 0.1879 },
    [3300] = { 1.0000, 0.5155, 0.2087 },
    [3400] = { 1.0000, 0.5336, 0.2301 },
    [3500] = { 1.0000, 0.5515, 0.2520 },
    [3600] = { 1.0000, 0.5689, 0.2745 },
    [3700] = { 1.0000, 0.5860, 0.2974 },
    [3800] = { 1.0000, 0.6028, 0.3207 },
    [3900] = { 1.0000, 0.6193, 0.3444 },
    [4000] = { 1.0000, 0.6354, 0.3684 },
    [4100] = { 1.0000, 0.6511, 0.3927 },
    [4200] = { 1.0000, 0.6666, 0.4172 },
    [4300] = { 1.0000, 0.6817, 0.4419 },
    [4400] = { 1.0000, 0.6966, 0.4668 },
    [4500] = { 1.0000, 0.7111, 0.4919 },
    [4600] = { 1.0000, 0.7253, 0.5170 },
    [4700] = { 1.0000, 0.7392, 0.5422 },
    [4800] = { 1.0000, 0.7528, 0.5675 },
    [4900] = { 1.0000, 0.7661, 0.5928 },
    [5000] = { 1.0000, 0.7792, 0.6180 },
    [5100] = { 1.0000, 0.7919, 0.6433 },
    [5200] = { 1.0000, 0.8044, 0.6685 },
    [5300] = { 1.0000, 0.8167, 0.6937 },
    [5400] = { 1.0000, 0.8286, 0.7187 },
    [5500] = { 1.0000, 0.8403, 0.7437 },
    [5600] = { 1.0000, 0.8518, 0.7686 },
    [5700] = { 1.0000, 0.8630, 0.7933 },
    [5800] = { 1.0000, 0.8740, 0.8179 },
    [5900] = { 1.0000, 0.8847, 0.8424 },
    [6000] = { 1.0000, 0.8952, 0.8666 },
    [6100] = { 1.0000, 0.9055, 0.8907 },
    [6200] = { 1.0000, 0.9156, 0.9147 },
    [6300] = { 1.0000, 0.9254, 0.9384 },
    [6400] = { 1.0000, 0.9351, 0.9619 },
    [6500] = { 1.0000, 0.9445, 0.9853 },
}

-- #endregion

-- #region Enums

---@enum DISPLAY_STATE
DISPLAY_STATE = {
    HIDDEN = 0,
    VISIBLE = 1,
    MINIMAL = 2,
}

---@enum SHELL_STATE
SHELL_STATE = {
    NONE = -1,
    QUEUED = 0,
    IN_FLIGHT = 1,
    ACTIVE = 2,
    DETONATED = 3
}

-- #endregion

-- #region Config Definitions

CONFIG_KEYBIND_FRIENDLYNAMES = {
    ["esc"]        = "Escape",
    ["tab"]        = "Tab",
    ["lmb"]        = "Left Mouse",
    ["rmb"]        = "Right Mouse",
    ["mmb"]        = "Middle Mouse",
    ["uparrow"]    = "Up Arrow",
    ["downarrow"]  = "Down Arrow",
    ["leftarrow"]  = "Left Arrow",
    ["rightarrow"] = "Right Arrow",
    ["backspace"]  = "Backspace",
    ["alt"]        = "Alt",
    ["delete"]     = "Delete",
    ["home"]       = "Home",
    ["end"]        = "End",
    ["pgup"]       = "Page Up",
    ["pgdown"]     = "Page Down",
    ["insert"]     = "Insert",
    ["space"]      = "Spacebar",
    ["shift"]      = "Shift",
    ["ctrl"]       = "Control",
    ["return"]     = "Enter/Return",
}

---@type { [string]: TConfigMapping }
CONFIG_VARIABLES = {
    ["G_DEBUG_MODE"] = {
        variable = G_CONFIG_ROOT .. ".debug_mode",

        value_type = "boolean",
        value_default = false
    },
    ["G_SIMULATE_BALLISTICS"] = {
        variable = G_CONFIG_ROOT .. ".simulate_ballistics",

        value_type = "boolean",
        value_default = true
    },
    ["G_PHYSICS_ITERATIONS"] = {
        variable = G_CONFIG_ROOT .. ".physics_iterations",

        value_type = "int",
        value_default = 4
    },
    ["G_SIMULATE_UXO"] = {
        variable = G_CONFIG_ROOT .. ".simulate_uxo",

        value_type = "boolean",
        value_default = false
    },
    ["G_TIME_OF_FLIGHT"] = {
        variable = G_CONFIG_ROOT .. ".time_of_flight",

        value_type = "float",
        value_default = 3.0
    },
    ["G_SHELL_INACCURACY"] = {
        variable = G_CONFIG_ROOT .. ".shell_inaccuracy",

        value_type = "float",
        value_default = 5.0
    },
    ["G_QUICK_SALVO_DELAY"] = {
        variable = G_CONFIG_ROOT .. ".quick_salvo_delay",

        value_type = "float",
        value_default = 0.5
    },
    ["G_SIMULATE_FRAGMENTATION"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.enabled",

        value_type = "boolean",
        value_default = true
    },
    ["G_SPAWN_PHYSICAL_FRAGMENTATION"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.physical_frag",

        value_type = "boolean",
        value_default = true
    },
    ["PHYSICAL_FRAGMENTATION_SPAWN_CHANCE"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.physical_frag.spawn_chance",

        value_type = "float",
        value_default = 0.2
    },
    ["G_FRAGMENTATION_DEBUG"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.debug_mode",

        value_type = "boolean",
        value_default = false
    },
    ["SHELL_SEC_CLUSTER_BOMBLET_AMOUNT"] = {
        variable = G_CONFIG_ROOT .. ".shells.secondary.cluster_bomblet_amount",

        value_type = "int",
        value_default = 50
    },
    ["SHELL_FRAGMENTATION_AMOUNT"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.amount",

        value_type = "int",
        value_default = 250
    },
    ["SHELL_FRAGMENTATION_SIZE"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.size",

        value_type = "int",
        value_default = 20
    },
    ["TACTICAL_POSTPROCESSING_TOGGLE"] = {
        variable = G_CONFIG_ROOT .. ".tactical.postprocessing",

        value_type = "boolean",
        value_default = true
    },
    ["TACTICAL_SHELL_LABELS_TOGGLE"] = {
        variable = G_CONFIG_ROOT .. ".tactical.shell_labels",

        value_type = "boolean",
        value_default = true
    },
    ["TACTICAL_DEFAULT_CAMERA_FOV"] = {
        variable = G_CONFIG_ROOT .. ".tactical.camera_fov",

        value_type = "int",
        value_default = 75
    },
    ["TACTICAL_DRAW_GRID_TOGGLE"] = {
        variable = G_CONFIG_ROOT .. ".tactical.draw_grid",

        value_type = "boolean",
        value_default = true
    },

    --------------------------------------
    -- Keybindings
    --------------------------------------

    -- Global
    ["KEYBIND_CYCLE_SHELLS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".cycle_shells",

        value_type = "string",
        value_default = "B"
    },
    ["KEYBIND_CYCLE_VARIANTS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".cycle_variants",

        value_type = "string",
        value_default = "N"
    },
    ["KEYBIND_ADJUST_ATTACK"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".adjust_attack",

        value_type = "string",
        value_default = "G"
    },
    ["KEYBIND_ADJUST_INACCURACY"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".adjust_inaccuracy",

        value_type = "string",
        value_default = "Z"
    },
    ["KEYBIND_ADJUST_DELAY"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".adjust_delay",

        value_type = "string",
        value_default = "X"
    },
    ["KEYBIND_GENERAL_CANCEL"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".cancel",

        value_type = "string",
        value_default = "C"
    },
    ["KEYBIND_TOGGLE_QUICKSALVO"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".toggle_quicksalvo",

        value_type = "string",
        value_default = "rmb"
    },
    ["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".quicksalvo.toggle_markers",

        value_type = "string",
        value_default = "J"
    },
    ["KEYBIND_PRIMARY_FIRE"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".primary_fire",

        value_type = "string",
        value_default = "lmb"
    },

    -- Tactical Mode
    ["KEYBIND_TACTICAL_TOGGLE"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".toggle",

        value_type = "string",
        value_default = "M"
    },
    ["KEYBIND_TACTICAL_CENTER_PLAYER"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".center_player",

        value_type = "string",
        value_default = "H"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Z_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.z_negative",

        value_type = "string",
        value_default = "W"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Z_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.z_positive",

        value_type = "string",
        value_default = "S"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_X_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.x_negative",

        value_type = "string",
        value_default = "A"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_X_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.x_positive",

        value_type = "string",
        value_default = "D"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Y_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.y_negative",

        value_type = "string",
        value_default = "R"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Y_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.y_positive",

        value_type = "string",
        value_default = "F"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_MOD_FAST"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.mod_fast",

        value_type = "string",
        value_default = "shift"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_MOD_SLOW"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.mod_slow",

        value_type = "string",
        value_default = "ctrl"
    },
}

---@type { [number]: TConfigOption }
CONFIG_OPTIONS = {
    {
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_SIMULATE_BALLISTICS"],
        name = "Simulate Ballistics [BETA]"
    },
    {
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_SIMULATE_UXO"],
        name = "Simulate Dud Rate (2%)"
    },
    {
        type = "slider",
        mapping = CONFIG_VARIABLES["G_TIME_OF_FLIGHT"],
        name = "Shell Time of Flight",

        value_unit = "second(s)",
        value_digits = 1,

        value_min = 1.5,
        value_max = 30
    },
    {
        type = "slider",
        mapping = CONFIG_VARIABLES["G_SHELL_INACCURACY"],
        name = "Shell Inaccuracy",

        value_unit = "meter(s)",
        value_digits = 1,

        value_min = 0,
        value_max = 50
    },
    {
        type = "slider",
        mapping = CONFIG_VARIABLES["G_QUICK_SALVO_DELAY"],
        name = "Delay between shells (Quick Salvo)",

        value_unit = "second(s)",
        value_digits = 2,

        value_min = 0.1,
        value_max = 5
    },
    {
        type = "slider",
        mapping = CONFIG_VARIABLES["SHELL_SEC_CLUSTER_BOMBLET_AMOUNT"],
        name = "Bomblets per cluster shell",

        value_unit = "bomblet(s)",

        value_min = 5,
        value_max = 100
    },
    {
        category = "fragmentation",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_SIMULATE_FRAGMENTATION"],
        name = "Simulate Fragmentation"
    },
    {
        category = "fragmentation",
        type = "slider",
        mapping = CONFIG_VARIABLES["SHELL_FRAGMENTATION_AMOUNT"],
        name = "Amount per shell",

        value_unit = "",

        value_min = 50,
        value_max = 1000
    },
    {
        category = "fragmentation",
        type = "slider",
        mapping = CONFIG_VARIABLES["SHELL_FRAGMENTATION_SIZE"],
        name = "Frag Size",

        value_unit = "cm",

        value_min = 10,
        value_max = 100
    },
    {
        category = "fragmentation",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_SPAWN_PHYSICAL_FRAGMENTATION"],
        name = "Physical Fragmentation"
    },
    {
        category = "fragmentation",
        type = "slider",
        mapping = CONFIG_VARIABLES["PHYSICAL_FRAGMENTATION_SPAWN_CHANCE"],
        name = "Phys. Fragment Spawn Chance",

        value_unit = "%",
        value_display_factor = 100,

        value_min = 0.05,
        value_max = 1,
        value_digits = 2,
    },
    {
        category = "tactical",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["TACTICAL_POSTPROCESSING_TOGGLE"],
        name = "Enable Postprocessing"
    },
    {
        category = "tactical",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["TACTICAL_SHELL_LABELS_TOGGLE"],
        name = "Enable Shell Labels"
    },
    {
        category = "tactical",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["TACTICAL_DRAW_GRID_TOGGLE"],
        name = "Draw Grid"
    },
    {
        category = "tactical",
        type = "slider",
        mapping = CONFIG_VARIABLES["TACTICAL_DEFAULT_CAMERA_FOV"],
        name = "Default Camera FOV",

        value_unit = "",
        value_digits = 0,

        value_min = 25,
        value_max = 120
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_CYCLE_SHELLS"],
        name = "Cycle Shells"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_CYCLE_VARIANTS"],
        name = "Cycle Variants"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_ADJUST_ATTACK"],
        name = "Adjust Shell Pitch/Heading (Hold)"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_ADJUST_INACCURACY"],
        name = "Adjust Inaccuracy (Hold)"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_ADJUST_DELAY"],
        name = "Adjust Quick Salvo per-shell delay (Hold)"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"],
        name = "Toggle Quick Salvo Marker Visibility"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_GENERAL_CANCEL"],
        name = "Cancel"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TOGGLE_QUICKSALVO"],
        name = "Toggle/Launch Quick Salvo"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_PRIMARY_FIRE"],
        name = "Fire/Mark Shell"
    },
    {
        category = "keybind",
        type = "section_break",
        name = "Tactical Mode Keybinds"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TOGGLE"],
        name = "Toggle Tactical Mode"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_CENTER_PLAYER"],
        name = "Center Player"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Z_NEG"],
        name = "Move North"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Z_POS"],
        name = "Move South"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_X_NEG"],
        name = "Move West"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_X_POS"],
        name = "Move East"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Y_POS"],
        name = "Elevation Up"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Y_NEG"],
        name = "Elevation Down"
    },
    {
        category = "advanced",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_DEBUG_MODE"],
        name = "Debug Mode"
    },
    {
        category = "advanced",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_FRAGMENTATION_DEBUG"],
        name = "Debug Fragmentation"
    },
    {
        category = "advanced",
        type = "slider",
        mapping = CONFIG_VARIABLES["G_PHYSICS_ITERATIONS"],
        name = "Physics Iterations",
        value_unit = "iteration(s)",

        value_min = 0,
        value_max = 6,

        value_display_exp = 2
    },
}

CONFIG_MENUS = {
    [1] = {
        title = "Global",
        filter = nil
    },
    [2] = {
        title = "Fragmentation",
        filter = "fragmentation"
    },
    [3] = {
        title = "Tactical",
        filter = "tactical"
    },
    [4] = {
        title = "Keybindings",
        filter = "keybind"
    },
    [5] = {
        title = "Advanced",
        filter = "advanced"
    }
}

-- #endregion

-- #region Ballistics

MAT_PEN = {
    -- Soft materials
    ["foliage"] = {
        absorb = 2,
        ["HE"] = {
            min_energy = 10,
            chance = 0
        },
        ["BB"] = {
            min_energy = 0,
            chance = 0
        },
    },
    ["snow"] = {
        absorb = 3,
        ["HE"] = {
            min_energy = 20,
            chance = 0
        },
        ["BB"] = {
            min_energy = 0,
            chance = 0
        },
    },
    ["dirt"] = {
        absorb = 10,
        ["HE"] = {
            min_energy = 100,
            chance = 5
        },
        ["BB"] = {
            min_energy = 0,
            chance = 0
        },
    },
    ["glass"] = {
        absorb = 10,
        ["HE"] = {
            min_energy = 150,
            chance = 5
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0
        },
    },
    ["plastic"] = {
        absorb = 20,
        ["HE"] = {
            min_energy = 150,
            chance = 2
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0
        },
    },
    ["wood"] = {
        absorb = 40,
        ["HE"] = {
            min_energy = 150,
            chance = 50
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0
        },
    },
    ["plaster"] = {
        absorb = 50,
        ["HE"] = {
            min_energy = 175,
            chance = 70
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0
        },
    },

    -- Medium materials
    ["concrete"] = {
        absorb = 80,
        ["HE"] = {
            min_energy = 1000,
            chance = 95
        },
        ["BB"] = {
            min_energy = 1000,
            chance = 15
        },
    },
    ["brick"] = {
        absorb = 70,
        ["HE"] = {
            min_energy = 1000,
            chance = 95
        },
        ["BB"] = {
            min_energy = 900,
            chance = 15
        },
    },
    ["metal"] = {
        absorb = 90,
        ["HE"] = {
            min_energy = 1250,
            chance = 100
        },
        ["BB"] = {
            min_energy = 1000,
            chance = 20
        },
    },

    -- Hard materials
    ["masonry"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 3500,
            chance = 100
        },
        ["BB"] = {
            min_energy = 1500,
            chance = 20
        },
    },
    ["heavymetal"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 9999,
            chance = 100
        },
        ["BB"] = {
            min_energy = 9999,
            chance = 100
        },
    },

    -- Indestructible materials
    ["rock"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 9999,
            chance = 100
        },
        ["BB"] = {
            min_energy = 9999,
            chance = 100
        },
    },

    -- Null material
    ["default"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 9999,
            chance = 100
        },
        ["BB"] = {
            min_energy = 9999,
            chance = 100
        },
    }
}

-- #endregion

-- #region Shell Values

SHELL_VALUES = {
    [1] = {
        name = "155mm Howitzer",
        caliber = "155mm",
        weight = 43.2,
        muzzle_velocity = 827 / 2,
        variants = {
            {
                id = "HE",
                name = "High Explosive",
                silent = false,
                size_explosion = 4,
                size_makehole = { 50, 20, 5 }
            },
            {
                id = "BB",
                name = "Bunkerbuster",
                silent = false,
                size_explosion = 4,
                size_makehole = { 50, 35, 20 }
            },
            {
                id = "CL",
                name = "Cluster",
                silent = true,
                size_explosion = 0,
                size_makehole = { 0.1, 0, 0 },
                secondary = {
                    timer = 10,
                    trigger_sound = LoadSound("MOD/assets/snd/155mm_shell_cluster_secondary_trigger.ogg"),
                    trigger_sound_volume = 900,
                    trigger_height = 450,
                    particle_radius = 10
                }
            },
            {
                id = "IN",
                name = "Incendiary",
                silent = true,
                size_explosion = 0,
                size_makehole = { 0.1, 0, 0 },
                secondary = {
                    timer = 10,
                    trigger_sound = LoadSound("MOD/assets/snd/155mm_shell_cluster_secondary_trigger.ogg"),
                    trigger_sound_volume = 900,
                    trigger_height = 100,
                    particle_radius = 10
                }
            }
        },
        sprite = {
            img = LoadSprite("MOD/assets/img/" .. "155mm_HE" .. ".png"),
            scaling_factor = 5.33,
            width = 0.155 * 2
        },
        sounds = {
            whistle = {
                "155mm_whistle_1",
                "155mm_whistle_2",
                "155mm_whistle_3"
            },
            fire = "155mm_fire"
        }
    },
    [2] = {
        name = "60mm Mortar",
        caliber = "60mm",
        weight = 2.73,
        variants = {
            {
                id = "HE",
                name = "High Explosive",
                silent = false,
                size_explosion = 1.5,
                size_makehole = { 35, 15, 3 }
            },
            {
                id = "PF",
                name = "Parachuted Flare",
                sprite = {
                    img = LoadSprite("MOD/assets/img/" .. "60mm_ILL" .. ".png"),
                    scaling_factor = 5.25,
                    width = 0.06 * 2
                },
                silent = true,
                size_explosion = 0,
                size_makehole = { 0.1, 0, 0 },
                secondary = {
                    timer = 30,
                    trigger_sound = LoadSound("MOD/assets/snd/60mm_ILL_secondary_pop_distant.ogg"),
                    trigger_height = 75
                }
            },
            {
                id = "SM",
                name = "Smoke",
                silent = false,
                size_explosion = 0.1,
                size_makehole = { 2, 1, 0.5 },
                secondary = {
                    timer = 30,
                    radius = 10,
                    trigger_detonate = true
                }
            }
        },
        sprite = {
            img = LoadSprite("MOD/assets/img/" .. "60mm_HE" .. ".png"),
            scaling_factor = 4.08,
            width = 0.06 * 2
        },
        sounds = {
            whistle = "60mm_whistle",
            fire = "60mm_fire"
        }
    },
    [3] = {
        name = "MLRS",
        caliber = "",
        weight = 90.71,
        muzzle_velocity = 413,
        variants = {
            {
                id = "M31A1",
                name = "GMLRS-U M31A1",
                silent = false,
                size_explosion = 4,
                size_makehole = { 50, 20, 5 },
                secondary = {
                    timer = 30,
                    trigger_height = 10000,
                    sounds = {
                        fire = "mlrs_m31a1_fire"
                    },
                }
            },
        },
        sprite = {
            img = LoadSprite("MOD/assets/img/155mm_HE.png"),
            scaling_factor = 4.08,
            width = 0.06 * 2
        },
        sounds = {
            whistle = {
                "155mm_whistle_1",
                "155mm_whistle_2",
                "155mm_whistle_3"
            },
            fire = "155mm_fire"
        }
    },
}

---@class (exact) Shell
---@field state SHELL_STATE
---@field secondary { active: boolean, timer: number, intensity: number, particle_spread: TVec, inertia: TVec, submunitions: Submunition[]?, [any]: any }
---@field type number
---@field variant number
---@field flight_time number
---@field inaccuracy number
---@field destination TVec|nil
---@field eta TVec|nil
---@field pitch number
---@field heading number
---@field position TVec|nil
---@field vel_previous TVec|nil
---@field vel_current TVec|nil
---@field kinetic_energy number
---@field hit_once boolean
---@field sprite number|nil
---@field snd_whistle number|nil
---@field delay? number
DEFAULT_SHELL = {
    state = SHELL_STATE.NONE,

    secondary = {
        active = false,
        timer = 0,
        intensity = 1000,
        particle_spread = Vec(0, 0, 0),
        inertia = Vec(0, 0, 0),
    },

    type = 1,
    variant = 1,
    flight_time = 0,
    inaccuracy = 0,

    destination = nil,
    eta = nil,
    pitch = 90,
    heading = 0,

    position = nil,

    vel_previous = nil,
    vel_current = nil,

    kinetic_energy = 0,

    hit_once = false,

    sprite = nil,
    snd_whistle = nil,
}

---@class (exact) Submunition
---@field transform TTransform|nil
---@field velocity TVec|nil
DEFAULT_SUBMUNITION = {
    transform = nil,
    velocity = nil
}

---@class ManagedBody
---@field created_at number
---@field handle number
---@field type string
---@field valid boolean
---@field [any] any

-- #endregion
