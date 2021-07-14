CONFIG_INFO = {
    version = 1,
    incompatible = true
}

CONFIG = {
    {
        variable = "savegame.mod.debug_mode",

        value_type = "boolean",
        value_default = false
    },
    {
        variable = "savegame.mod.simulate_ballistics",

        value_type = "boolean",
        value_default = true
    },
    {
        variable = "savegame.mod.simulate_dud",

        value_type = "boolean",
        value_default = false
    },
    {
        variable = "savegame.mod.flight_time",

        value_type = "float",
        value_default = 0.0,

        value_min = 0,
        value_max = 25
    },
    {
        variable = "savegame.mod.shell_inaccuracy",

        value_type = "float",
        value_default = 5.0,

        value_min = 0,
        value_max = 50
    },
    {
        variable = "savegame.mod.quick_salvo_delay",

        value_type = "float",
        value_default = 0.5,

        value_min = 0.1,
        value_max = 5
    },
    {
        variable = "savegame.mod.shells.secondary.cluster_bomblet_amount",

        value_type = "int",
        value_default = 50,

        value_min = 5,
        value_max = 100
    },
}

function CONFIG:init()
    if not HasKey('savegame.mod.config.version') then
        self:reset()
    end

    local current_version = GetInt('savegame.mod.config.version')
    if not (current_version == CONFIG_INFO.version) and CONFIG_INFO.incompatible then
        self:reset()
    end
end

function CONFIG:reset()
    SetInt('savegame.mod.config.version', CONFIG_INFO.version)
end