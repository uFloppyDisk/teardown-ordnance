G_DEV = GetBool("savegame.mod.debug_mode")
G_VEC_GRAVITY = Vec(0, -39.2, 0)

G_MAX_SHELLS = 100
G_QUICK_SALVO_DELAY = GetFloat("savegame.mod.quick_salvo_delay") or 0.5

SHELL_STATES = {
    queued = 0,
    in_flight = 1,
    active = 2,
    detonated = 3
}

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
                    trigger_height = 150
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
                    trigger_height = 75
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
    flight_time = GetFloat("savegame.mod.flight_time"),
    inaccuracy = GetFloat("savegame.mod.shell_inaccuracy"),

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