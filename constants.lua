#include "classes/configmanager.lua"

G_DEV = false
G_VEC_GRAVITY = Vec(0, -39.2, 0)

G_MAX_SHELLS = 100
G_QUICK_SALVO_DELAY = 0

G_CONFIG_KEYBINDS_ROOT = "savegame.mod.config.keybind"

SHELL_STATES = {
    queued = 0,
    in_flight = 1,
    active = 2,
    detonated = 3
}

-- #region Colours

COLOUR = {
    ["white"]           = {1, 1, 1, 1},
    ["red"]             = {1, 0.2, 0.2, 1},
    ["yellow"]          = {1, 1, 0, 1},
    ["yellow_dark"]     = {1, 0.8, 0, 1},
    ["orange"]          = {1, 0.6, 0.2, 1}
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
        variable = "savegame.mod.config.debug_mode",

        value_type = "boolean",
        value_default = false
    },
    ["G_SIMULATE_BALLISTICS"] = {
        variable = "savegame.mod.config.simulate_ballistics",

        value_type = "boolean",
        value_default = true
    },
    ["G_SIMULATE_UXO"] = {
        variable = "savegame.mod.config.simulate_uxo",

        value_type = "boolean",
        value_default = false
    },
    ["G_FLIGHT_TIME"] = {
        variable = "savegame.mod.config.flight_time",

        value_type = "float",
        value_default = 0.0
    },
    ["G_SHELL_INACCURACY"] = {
        variable = "savegame.mod.config.shell_inaccuracy",

        value_type = "float",
        value_default = 5.0
    },
    ["G_QUICK_SALVO_DELAY"] = {
        variable = "savegame.mod.config.quick_salvo_delay",

        value_type = "float",
        value_default = 0.5
    },
    ["SHELL_SEC_CLUSTER_BOMBLET_AMOUNT"] = {
        variable = "savegame.mod.config.shells.secondary.cluster_bomblet_amount",

        value_type = "int",
        value_default = 50
    },
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
    ["KEYBIND_PRIMARY_FIRE"] = {
        variable = G_CONFIG_KEYBINDS_ROOT..".primary_fire",

        value_type = "string",
        value_default = "lmb"
    },
}

CONFIG_OPTIONS = {
    {
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_DEBUG_MODE"],
        name = "Debug Mode"
    },
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
        mapping = CONFIG_VARIABLES["G_FLIGHT_TIME"],
        name = "Flight Time",
        value_unit = "second(s)",

        value_min = 0,
        value_max = 25
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
        mapping = CONFIG_VARIABLES["KEYBIND_ADJUST_INACCURACY"],
        name = "Adjust Inaccuracy In-game (Hold)"
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_GENERAL_CANCEL"],
        name = "Cancel"
    },
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
}

CONFIG_MENUS = {
    [1] = {
        title = "Global",
        filter = nil
    },
    [2] = {
        title = "Keybindings",
        filter = "keybind"
    },
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
                    trigger_height = 150,
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
            {
                id = "SM",
                name = "Smoke",
                silent = false,
                size_explosion = 0.1,
                size_makehole = {2, 1, 0.5},
                secondary = {
                    timer = 30,
                    radius = 6,
                    trigger_detonate = true
                }
            }
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
    },

    type = 1,
    variant = 1,
    flight_time = 0,
    inaccuracy = 0,

    destination = nil,
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