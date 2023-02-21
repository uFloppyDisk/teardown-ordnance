#include "classes/configmanager.lua"

G_DEV = false
G_VEC_GRAVITY = Vec(0, -39.2, 0)
G_VEC_WIND = Vec(-0.4, 0.03, 0.07)

G_MAX_SHELLS = 100
G_QUICK_SALVO_DELAY = 0

G_CONFIG_ROOT = "savegame.mod.config"
G_CONFIG_KEYBINDS_ROOT = G_CONFIG_ROOT..".keybind"
G_CONFIG_KEYBINDS_TAC = G_CONFIG_KEYBINDS_ROOT..".tactical"

---@enum shell_states
shell_states = {
    QUEUED = 0,
    IN_FLIGHT = 1,
    ACTIVE = 2,
    DETONATED = 3
}

-- #region Colours

COLOUR = {
    ["white"]           = {1, 1, 1, 1},
    ["red"]             = {1, 0.2, 0.2, 1},
    ["yellow"]          = {1, 1, 0, 1},
    ["yellow_dark"]     = {1, 0.8, 0, 1},
    ["orange"]          = {1, 0.6, 0.2, 1},
    ["green"]           = {0.2, 1, 0.2, 1},
}

-- #endregion

-- #region Enums

---@enum qs_display
qs_display = {
    HIDDEN = 0,
    VISIBLE = 1,
    MINIMAL = 2,
}

-- #endregion

-- #region Config Definitions

CONFIG_KEYBIND_FRIENDLYNAMES = {
    ["esc"]         = "Escape",
    ["tab"]         = "Tab",
    ["lmb"]         = "Left Mouse",
    ["rmb"]         = "Right Mouse",
    ["mmb"]         = "Middle Mouse",
    ["uparrow"]     = "Up Arrow",
    ["downarrow"]   = "Down Arrow",
    ["leftarrow"]   = "Left Arrow",
    ["rightarrow"]  = "Right Arrow",
    ["backspace"]   = "Backspace",
    ["alt"]         = "Alt",
    ["delete"]      = "Delete",
    ["home"]        = "Home",
    ["end"]         = "End",
    ["pgup"]        = "Page Up",
    ["pgdown"]      = "Page Down",
    ["insert"]      = "Insert",
    ["space"]       = "Spacebar",
    ["shift"]       = "Shift",
    ["ctrl"]        = "Control",
    ["return"]      = "Enter/Return",
}

CONFIG_VARIABLES = {
    ["G_DEBUG_MODE"] = {
        variable = G_CONFIG_ROOT..".debug_mode",

        value_type = "boolean",
        value_default = false
    },
    ["G_SIMULATE_BALLISTICS"] = {
        variable = G_CONFIG_ROOT..".simulate_ballistics",

        value_type = "boolean",
        value_default = true
    },
    ["G_PHYSICS_ITERATIONS"] = {
        variable = G_CONFIG_ROOT..".physics_iterations",

        value_type = "int",
        value_default = 4
    },
    ["G_SIMULATE_UXO"] = {
        variable = G_CONFIG_ROOT..".simulate_uxo",

        value_type = "boolean",
        value_default = false
    },
    ["G_TIME_OF_FLIGHT"] = {
        variable = G_CONFIG_ROOT..".time_of_flight",

        value_type = "float",
        value_default = 3.0
    },
    ["G_SHELL_INACCURACY"] = {
        variable = G_CONFIG_ROOT..".shell_inaccuracy",

        value_type = "float",
        value_default = 5.0
    },
    ["G_QUICK_SALVO_DELAY"] = {
        variable = G_CONFIG_ROOT..".quick_salvo_delay",

        value_type = "float",
        value_default = 0.5
    },
    ["G_SIMULATE_FRAGMENTATION"] = {
        variable = G_CONFIG_ROOT..".fragmentation.enabled",

        value_type = "boolean",
        value_default = true
    },
    ["G_FRAGMENTATION_DEBUG"] = {
        variable = G_CONFIG_ROOT..".fragmentation.debug_mode",

        value_type = "boolean",
        value_default = false
    },
    ["SHELL_SEC_CLUSTER_BOMBLET_AMOUNT"] = {
        variable = G_CONFIG_ROOT..".shells.secondary.cluster_bomblet_amount",

        value_type = "int",
        value_default = 50
    },
    ["SHELL_FRAGMENTATION_AMOUNT"] = {
        variable = G_CONFIG_ROOT..".fragmentation.amount",

        value_type = "int",
        value_default = 250
    },
    ["SHELL_FRAGMENTATION_SIZE"] = {
        variable = G_CONFIG_ROOT..".fragmentation.size",

        value_type = "int",
        value_default = 20
    },
    ["TACTICAL_POSTPROCESSING_TOGGLE"] = {
        variable = G_CONFIG_ROOT..".tactical.postprocessing",

        value_type = "boolean",
        value_default = true
    },
    ["TACTICAL_SHELL_LABELS_TOGGLE"] = {
        variable = G_CONFIG_ROOT..".tactical.shell_labels",

        value_type = "boolean",
        value_default = true
    },
    ["TACTICAL_DEFAULT_CAMERA_FOV"] = {
        variable = G_CONFIG_ROOT..".tactical.camera_fov",

        value_type = "int",
        value_default = 75
    },
    ["TACTICAL_DRAW_GRID_TOGGLE"] = {
        variable = G_CONFIG_ROOT..".tactical.draw_grid",

        value_type = "boolean",
        value_default = true
    },

    --------------------------------------
    -- Keybindings
    --------------------------------------

    -- Global
    ["KEYBIND_CYCLE_SHELLS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".cycle_shells",

        value_type = "string",
        value_default = "B"
    },
    ["KEYBIND_CYCLE_VARIANTS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".cycle_variants",

        value_type = "string",
        value_default = "N"
    },
    ["KEYBIND_ADJUST_ATTACK"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".adjust_attack",

        value_type = "string",
        value_default = "G"
    },
    ["KEYBIND_ADJUST_INACCURACY"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".adjust_inaccuracy",

        value_type = "string",
        value_default = "Z"
    },
    ["KEYBIND_GENERAL_CANCEL"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".cancel",

        value_type = "string",
        value_default = "C"
    },
    ["KEYBIND_TOGGLE_QUICKSALVO"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".toggle_quicksalvo",

        value_type = "string",
        value_default = "rmb"
    },
    ["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".quicksalvo.toggle_markers",

        value_type = "string",
        value_default = "J"
    },
    ["KEYBIND_PRIMARY_FIRE"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".primary_fire",

        value_type = "string",
        value_default = "lmb"
    },

    -- Tactical Mode
    ["KEYBIND_TACTICAL_TOGGLE"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."toggle",

        value_type = "string",
        value_default = "M"
    },
    ["KEYBIND_TACTICAL_CENTER_PLAYER"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."center_player",

        value_type = "string",
        value_default = "H"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Z_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."translate.z_negative",

        value_type = "string",
        value_default = "W"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Z_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."translate.z_positive",

        value_type = "string",
        value_default = "S"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_X_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."translate.x_negative",

        value_type = "string",
        value_default = "A"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_X_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."translate.x_positive",

        value_type = "string",
        value_default = "D"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Y_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."translate.y_negative",

        value_type = "string",
        value_default = "R"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Y_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."translate.y_positive",

        value_type = "string",
        value_default = "F"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_MOD_FAST"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."translate.mod_fast",

        value_type = "string",
        value_default = "shift"
    },
    ["KEYBIND_TACTICAL_TRANSLATE_MOD_SLOW"] = {
        variable = G_CONFIG_KEYBINDS_TAC.."translate.mod_slow",

        value_type = "string",
        value_default = "ctrl"
    },
}

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
        mapping = CONFIG_VARIABLES["KEYBIND_GENERAL_CANCEL"],
        name = "Cancel"
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
        name = "Tactical: Center Player"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"],
        name = "Toggle Quick Salvo Marker Visibility"
    },
    -- {
    --     category = "keybind",
    --     type = "textbutton",
    --     variant = "keybinding",
    --     mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Z_NEG"],
    --     name = "TAC: Move Up"
    -- },
    -- {
    --     category = "keybind",
    --     type = "textbutton",
    --     variant = "keybinding",
    --     mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Z_POS"],
    --     name = "TAC: Move Down"
    -- },
    -- {
    --     category = "keybind",
    --     type = "textbutton",
    --     variant = "keybinding",
    --     mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_X_NEG"],
    --     name = "TAC: Move Left"
    -- },
    -- {
    --     category = "keybind",
    --     type = "textbutton",
    --     variant = "keybinding",
    --     mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_X_POS"],
    --     name = "TAC: Move Right"
    -- },
    -- {
    --     category = "keybind",
    --     type = "textbutton",
    --     variant = "keybinding",
    --     mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Y_POS"],
    --     name = "TAC: Elevation Up"
    -- },
    -- {
    --     category = "keybind",
    --     type = "textbutton",
    --     variant = "keybinding",
    --     mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Y_NEG"],
    --     name = "TAC: Elevation Down"
    -- },
    -- {
    --     category = "keybind",
    --     type = "textbutton",
    --     variant = "keybinding",
    --     mapping = CONFIG_VARIABLES["KEYBIND_TOGGLE_QUICKSALVO"],
    --     name = "Toggle/Launch Quick Salvo"
    -- },
    -- {
    --     category = "keybind",
    --     type = "textbutton",
    --     variant = "keybinding",
    --     mapping = CONFIG_VARIABLES["KEYBIND_PRIMARY_FIRE"],
    --     name = "Fire/Mark Shell"
    -- },
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

    -- Lazy fix for snow material returning null, old values are commented
    ["default"] = {
        absorb = 0, -- 100
        ["HE"] = {
            min_energy = 0, -- 9999
            chance = 0 -- 100
        },
        ["BB"] = {
            min_energy = 0, -- 9999
            chance = 0 -- 100
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
                size_makehole = {50, 20, 5}
            },
            {
                id = "BB",
                name = "Bunkerbuster",
                silent = false,
                size_explosion = 4,
                size_makehole = {50, 35, 20}
            },
            {
                id = "CL",
                name = "Cluster",
                silent = true,
                size_explosion = 0,
                size_makehole = {0.1, 0, 0},
                secondary = {
                    timer = 10,
                    trigger_sound = LoadSound("MOD/snd/155mm_shell_cluster_secondary_trigger.ogg"),
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
                size_makehole = {0.1, 0, 0},
                secondary = {
                    timer = 10,
                    trigger_sound = LoadSound("MOD/snd/155mm_shell_cluster_secondary_trigger.ogg"),
                    trigger_sound_volume = 900,
                    trigger_height = 100,
                    particle_radius = 10
                }
            }
        },
        sprite = {
            img = LoadSprite("MOD/img/".."155mm_HE"..".png"),
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
                size_makehole = {35, 15, 3}
            },
            {
                id = "PF",
                name = "Parachuted Flare",
                sprite = {
                    img = LoadSprite("MOD/img/".."60mm_ILL"..".png"),
                    scaling_factor = 5.25,
                    width = 0.06 * 2
                },
                silent = true,
                size_explosion = 0,
                size_makehole = {0.1, 0, 0},
                secondary = {
                    timer = 30,
                    trigger_sound = LoadSound("MOD/snd/60mm_ILL_secondary_pop_distant.ogg"),
                    trigger_height = 75
                }
            },
            -- {
            --     id = "SM",
            --     name = "Smoke",
            --     silent = false,
            --     size_explosion = 0.1,
            --     size_makehole = {2, 1, 0.5},
            --     secondary = {
            --         timer = 30,
            --         radius = 6,
            --         trigger_detonate = true
            --     }
            -- }
        },
        sprite = {
            img = LoadSprite("MOD/img/".."60mm_HE"..".png"),
            scaling_factor = 4.08,
            width = 0.06 * 2
        },
        sounds = {
            whistle = "60mm_whistle",
            fire = "60mm_fire"
        }
    }
}

DEFAULT_SHELL = {
    state = -1,

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

DEFAULT_SUBMUNITION = {
    transform = nil,
    velocity = nil
}

-- #endregion