MAT_PEN = {
    -- Soft materials
    ["foliage"] = {
        absorb = 2,
        ["HE"] = {
            min_energy = 10,
            chance = 0,
        },
        ["BB"] = {
            min_energy = 0,
            chance = 0,
        },
    },
    ["snow"] = {
        absorb = 3,
        ["HE"] = {
            min_energy = 20,
            chance = 0,
        },
        ["BB"] = {
            min_energy = 0,
            chance = 0,
        },
    },
    ["dirt"] = {
        absorb = 10,
        ["HE"] = {
            min_energy = 100,
            chance = 5,
        },
        ["BB"] = {
            min_energy = 0,
            chance = 0,
        },
    },
    ["glass"] = {
        absorb = 10,
        ["HE"] = {
            min_energy = 150,
            chance = 5,
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0,
        },
    },
    ["plastic"] = {
        absorb = 20,
        ["HE"] = {
            min_energy = 150,
            chance = 2,
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0,
        },
    },
    ["wood"] = {
        absorb = 40,
        ["HE"] = {
            min_energy = 150,
            chance = 50,
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0,
        },
    },
    ["plaster"] = {
        absorb = 50,
        ["HE"] = {
            min_energy = 175,
            chance = 70,
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0,
        },
    },

    -- Medium materials
    ["concrete"] = {
        absorb = 80,
        ["HE"] = {
            min_energy = 1000,
            chance = 95,
        },
        ["BB"] = {
            min_energy = 1000,
            chance = 15,
        },
    },
    ["brick"] = {
        absorb = 70,
        ["HE"] = {
            min_energy = 1000,
            chance = 95,
        },
        ["BB"] = {
            min_energy = 900,
            chance = 15,
        },
    },
    ["metal"] = {
        absorb = 90,
        ["HE"] = {
            min_energy = 1250,
            chance = 100,
        },
        ["BB"] = {
            min_energy = 1000,
            chance = 20,
        },
    },

    -- Hard materials
    ["masonry"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 3500,
            chance = 100,
        },
        ["BB"] = {
            min_energy = 1500,
            chance = 20,
        },
    },
    ["heavymetal"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 9999,
            chance = 100,
        },
        ["BB"] = {
            min_energy = 9999,
            chance = 100,
        },
    },

    -- Indestructible materials
    ["rock"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 9999,
            chance = 100,
        },
        ["BB"] = {
            min_energy = 9999,
            chance = 100,
        },
    },

    -- Null material
    ["default"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 9999,
            chance = 100,
        },
        ["BB"] = {
            min_energy = 9999,
            chance = 100,
        },
    },
}

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
                size_makehole = { 50, 20, 5 },
            },
            {
                id = "BB",
                name = "Bunkerbuster",
                silent = false,
                size_explosion = 4,
                size_makehole = { 50, 35, 20 },
            },
            {
                id = "CL",
                name = "Cluster",
                silent = true,
                size_explosion = 0,
                size_makehole = { 0.1, 0, 0 },
                secondary = {
                    timer = 10,
                    trigger_sound = 0, --LoadSound("MOD/assets/snd/155mm_shell_cluster_secondary_trigger.ogg"),
                    trigger_sound_volume = 900,
                    trigger_height = 450,
                    particle_radius = 10,
                },
            },
            {
                id = "IN",
                name = "Incendiary",
                silent = true,
                size_explosion = 0,
                size_makehole = { 0.1, 0, 0 },
                secondary = {
                    timer = 10,
                    trigger_sound = 0, --LoadSound("MOD/assets/snd/155mm_shell_cluster_secondary_trigger.ogg"),
                    trigger_sound_volume = 900,
                    trigger_height = 100,
                    particle_radius = 10,
                },
            },
        },
        sprite = {
            img = 0, --LoadSprite("MOD/assets/img/" .. "155mm_HE" .. ".png"),
            scaling_factor = 5.33,
            width = 0.155 * 2,
        },
        sounds = {
            whistle = {
                "155mm_whistle_1",
                "155mm_whistle_2",
                "155mm_whistle_3",
            },
            fire = "155mm_fire",
        },
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
                size_makehole = { 35, 15, 3 },
            },
            {
                id = "PF",
                name = "Parachuted Flare",
                sprite = {
                    img = 0, --LoadSprite("MOD/assets/img/" .. "60mm_ILL" .. ".png"),
                    scaling_factor = 5.25,
                    width = 0.06 * 2,
                },
                silent = true,
                size_explosion = 0,
                size_makehole = { 0.1, 0, 0 },
                secondary = {
                    timer = 30,
                    trigger_sound = 0, --LoadSound("MOD/assets/snd/60mm_ILL_secondary_pop_distant.ogg"),
                    trigger_height = 75,
                },
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
                    trigger_detonate = true,
                },
            },
        },
        sprite = {
            img = 0, --LoadSprite("MOD/assets/img/" .. "60mm_HE" .. ".png"),
            scaling_factor = 4.08,
            width = 0.06 * 2,
        },
        sounds = {
            whistle = "60mm_whistle",
            fire = "60mm_fire",
        },
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
                sprite = {
                    img = 0, --LoadSprite("MOD/assets/img/m31a1.png"),
                    scaling_factor = 4.2,
                    width = 1,
                },
                secondary = {
                    timer = 30,
                    trigger_height = 10000,
                    sounds = {
                        fire = "mlrs_m31a1_fire",
                    },
                },
            },
        },
        sprite = {
            img = 0, --LoadSprite("MOD/assets/img/155mm_HE.png"),
            scaling_factor = 4.08,
            width = 0.06 * 2,
        },
        sounds = {
            whistle = {
                "155mm_whistle_1",
                "155mm_whistle_2",
                "155mm_whistle_3",
            },
            fire = "",
        },
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
    velocity = nil,
}
