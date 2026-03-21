G_CONFIG_ROOT = "savegame.mod.config"
G_CONFIG_KEYBINDS_ROOT = G_CONFIG_ROOT .. ".keybind"
G_CONFIG_KEYBINDS_TAC = G_CONFIG_KEYBINDS_ROOT .. ".tactical"

CONFIG_KEYBIND_FRIENDLYNAMES = {
    ["esc"] = "Escape",
    ["tab"] = "Tab",
    ["lmb"] = "Left Mouse",
    ["rmb"] = "Right Mouse",
    ["mmb"] = "Middle Mouse",
    ["uparrow"] = "Up Arrow",
    ["downarrow"] = "Down Arrow",
    ["leftarrow"] = "Left Arrow",
    ["rightarrow"] = "Right Arrow",
    ["backspace"] = "Backspace",
    ["alt"] = "Alt",
    ["delete"] = "Delete",
    ["home"] = "Home",
    ["end"] = "End",
    ["pgup"] = "Page Up",
    ["pgdown"] = "Page Down",
    ["insert"] = "Insert",
    ["space"] = "Spacebar",
    ["shift"] = "Shift",
    ["ctrl"] = "Control",
    ["return"] = "Enter/Return",
}

---@type { [string]: TConfigMapping }
CONFIG_VARIABLES = {
    ["G_DEBUG_MODE"] = {
        variable = G_CONFIG_ROOT .. ".debug_mode",

        value_type = "boolean",
        value_default = false,
    },
    ["G_SIMULATE_BALLISTICS"] = {
        variable = G_CONFIG_ROOT .. ".simulate_ballistics",

        value_type = "boolean",
        value_default = true,
    },
    ["G_PHYSICS_ITERATIONS"] = {
        variable = G_CONFIG_ROOT .. ".physics_iterations",

        value_type = "int",
        value_default = 4,
    },
    ["G_SIMULATE_UXO"] = {
        variable = G_CONFIG_ROOT .. ".simulate_uxo",

        value_type = "boolean",
        value_default = false,
    },
    ["G_TIME_OF_FLIGHT"] = {
        variable = G_CONFIG_ROOT .. ".time_of_flight",

        value_type = "float",
        value_default = 3.0,
    },
    ["G_SHELL_INACCURACY"] = {
        variable = G_CONFIG_ROOT .. ".shell_inaccuracy",

        value_type = "float",
        value_default = 5.0,
    },
    ["G_QUICK_SALVO_DELAY"] = {
        variable = G_CONFIG_ROOT .. ".quick_salvo_delay",

        value_type = "float",
        value_default = 0.5,
    },
    ["G_SIMULATE_FRAGMENTATION"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.enabled",

        value_type = "boolean",
        value_default = true,
    },
    ["G_SPAWN_PHYSICAL_FRAGMENTATION"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.physical_frag",

        value_type = "boolean",
        value_default = true,
    },
    ["PHYSICAL_FRAGMENTATION_SPAWN_CHANCE"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.physical_frag.spawn_chance",

        value_type = "float",
        value_default = 0.2,
    },
    ["G_FRAGMENTATION_DEBUG"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.debug_mode",

        value_type = "boolean",
        value_default = false,
    },
    ["SHELL_SEC_CLUSTER_BOMBLET_AMOUNT"] = {
        variable = G_CONFIG_ROOT .. ".shells.secondary.cluster_bomblet_amount",

        value_type = "int",
        value_default = 50,
    },
    ["SHELL_FRAGMENTATION_AMOUNT"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.amount",

        value_type = "int",
        value_default = 250,
    },
    ["SHELL_FRAGMENTATION_SIZE"] = {
        variable = G_CONFIG_ROOT .. ".fragmentation.size",

        value_type = "int",
        value_default = 20,
    },
    ["TACTICAL_POSTPROCESSING_TOGGLE"] = {
        variable = G_CONFIG_ROOT .. ".tactical.postprocessing",

        value_type = "boolean",
        value_default = true,
    },
    ["TACTICAL_SHELL_LABELS_TOGGLE"] = {
        variable = G_CONFIG_ROOT .. ".tactical.shell_labels",

        value_type = "boolean",
        value_default = true,
    },
    ["TACTICAL_DEFAULT_CAMERA_FOV"] = {
        variable = G_CONFIG_ROOT .. ".tactical.camera_fov",

        value_type = "int",
        value_default = 75,
    },
    ["TACTICAL_DRAW_GRID_TOGGLE"] = {
        variable = G_CONFIG_ROOT .. ".tactical.draw_grid",

        value_type = "boolean",
        value_default = true,
    },

    --------------------------------------
    -- Keybindings
    --------------------------------------

    -- Global
    ["KEYBIND_CYCLE_SHELLS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".cycle_shells",

        value_type = "string",
        value_default = "B",
    },
    ["KEYBIND_CYCLE_VARIANTS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".cycle_variants",

        value_type = "string",
        value_default = "N",
    },
    ["KEYBIND_ADJUST_ATTACK"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".adjust_attack",

        value_type = "string",
        value_default = "G",
    },
    ["KEYBIND_ADJUST_INACCURACY"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".adjust_inaccuracy",

        value_type = "string",
        value_default = "Z",
    },
    ["KEYBIND_ADJUST_DELAY"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".adjust_delay",

        value_type = "string",
        value_default = "X",
    },
    ["KEYBIND_GENERAL_CANCEL"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".cancel",

        value_type = "string",
        value_default = "C",
    },
    ["KEYBIND_TOGGLE_QUICKSALVO"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".toggle_quicksalvo",

        value_type = "string",
        value_default = "rmb",
    },
    ["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".quicksalvo.toggle_markers",

        value_type = "string",
        value_default = "J",
    },
    ["KEYBIND_PRIMARY_FIRE"] = {
        variable = G_CONFIG_KEYBINDS_ROOT .. ".primary_fire",

        value_type = "string",
        value_default = "lmb",
    },

    -- Tactical Mode
    ["KEYBIND_TACTICAL_TOGGLE"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".toggle",

        value_type = "string",
        value_default = "M",
    },
    ["KEYBIND_TACTICAL_CENTER_PLAYER"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".center_player",

        value_type = "string",
        value_default = "H",
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Z_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.z_negative",

        value_type = "string",
        value_default = "W",
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Z_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.z_positive",

        value_type = "string",
        value_default = "S",
    },
    ["KEYBIND_TACTICAL_TRANSLATE_X_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.x_negative",

        value_type = "string",
        value_default = "A",
    },
    ["KEYBIND_TACTICAL_TRANSLATE_X_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.x_positive",

        value_type = "string",
        value_default = "D",
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Y_NEG"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.y_negative",

        value_type = "string",
        value_default = "R",
    },
    ["KEYBIND_TACTICAL_TRANSLATE_Y_POS"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.y_positive",

        value_type = "string",
        value_default = "F",
    },
    ["KEYBIND_TACTICAL_TRANSLATE_MOD_FAST"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.mod_fast",

        value_type = "string",
        value_default = "shift",
    },
    ["KEYBIND_TACTICAL_TRANSLATE_MOD_SLOW"] = {
        variable = G_CONFIG_KEYBINDS_TAC .. ".translate.mod_slow",

        value_type = "string",
        value_default = "ctrl",
    },
}

---@type { [number]: TConfigOption }
CONFIG_OPTIONS = {
    {
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_SIMULATE_BALLISTICS"],
        name = "Simulate Ballistics [BETA]",
    },
    {
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_SIMULATE_UXO"],
        name = "Simulate Dud Rate (2%)",
    },
    {
        type = "slider",
        mapping = CONFIG_VARIABLES["G_TIME_OF_FLIGHT"],
        name = "Shell Time of Flight",

        value_unit = "second(s)",
        value_digits = 1,

        value_min = 1.5,
        value_max = 30,
    },
    {
        type = "slider",
        mapping = CONFIG_VARIABLES["G_SHELL_INACCURACY"],
        name = "Shell Inaccuracy",

        value_unit = "meter(s)",
        value_digits = 1,

        value_min = 0,
        value_max = 50,
    },
    {
        type = "slider",
        mapping = CONFIG_VARIABLES["G_QUICK_SALVO_DELAY"],
        name = "Delay between shells (Quick Salvo)",

        value_unit = "second(s)",
        value_digits = 2,

        value_min = 0.1,
        value_max = 5,
    },
    {
        type = "slider",
        mapping = CONFIG_VARIABLES["SHELL_SEC_CLUSTER_BOMBLET_AMOUNT"],
        name = "Bomblets per cluster shell",

        value_unit = "bomblet(s)",

        value_min = 5,
        value_max = 100,
    },
    {
        category = "fragmentation",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_SIMULATE_FRAGMENTATION"],
        name = "Simulate Fragmentation",
    },
    {
        category = "fragmentation",
        type = "slider",
        mapping = CONFIG_VARIABLES["SHELL_FRAGMENTATION_AMOUNT"],
        name = "Amount per shell",

        value_unit = "",

        value_min = 50,
        value_max = 1000,
    },
    {
        category = "fragmentation",
        type = "slider",
        mapping = CONFIG_VARIABLES["SHELL_FRAGMENTATION_SIZE"],
        name = "Frag Size",

        value_unit = "cm",

        value_min = 10,
        value_max = 100,
    },
    {
        category = "fragmentation",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_SPAWN_PHYSICAL_FRAGMENTATION"],
        name = "Physical Fragmentation",
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
        name = "Enable Postprocessing",
    },
    {
        category = "tactical",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["TACTICAL_SHELL_LABELS_TOGGLE"],
        name = "Enable Shell Labels",
    },
    {
        category = "tactical",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["TACTICAL_DRAW_GRID_TOGGLE"],
        name = "Draw Grid",
    },
    {
        category = "tactical",
        type = "slider",
        mapping = CONFIG_VARIABLES["TACTICAL_DEFAULT_CAMERA_FOV"],
        name = "Default Camera FOV",

        value_unit = "",
        value_digits = 0,

        value_min = 25,
        value_max = 120,
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_CYCLE_SHELLS"],
        name = "Cycle Shells",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_CYCLE_VARIANTS"],
        name = "Cycle Variants",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_ADJUST_ATTACK"],
        name = "Adjust Shell Pitch/Heading (Hold)",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_ADJUST_INACCURACY"],
        name = "Adjust Inaccuracy (Hold)",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_ADJUST_DELAY"],
        name = "Adjust Quick Salvo per-shell delay (Hold)",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TOGGLE_QUICKSALVO_MARKERS"],
        name = "Toggle Quick Salvo Marker Visibility",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_GENERAL_CANCEL"],
        name = "Cancel",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TOGGLE_QUICKSALVO"],
        name = "Toggle/Launch Quick Salvo",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_PRIMARY_FIRE"],
        name = "Fire/Mark Shell",
    },
    {
        category = "keybind",
        type = "section_break",
        name = "Tactical Mode Keybinds",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TOGGLE"],
        name = "Toggle Tactical Mode",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_CENTER_PLAYER"],
        name = "Center Player",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Z_NEG"],
        name = "Move North",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Z_POS"],
        name = "Move South",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_X_NEG"],
        name = "Move West",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_X_POS"],
        name = "Move East",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Y_POS"],
        name = "Elevation Up",
    },
    {
        category = "keybind",
        type = "textbutton",
        variant = "keybinding",
        mapping = CONFIG_VARIABLES["KEYBIND_TACTICAL_TRANSLATE_Y_NEG"],
        name = "Elevation Down",
    },
    {
        category = "advanced",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_DEBUG_MODE"],
        name = "Debug Mode",
    },
    {
        category = "advanced",
        type = "textbutton",
        mapping = CONFIG_VARIABLES["G_FRAGMENTATION_DEBUG"],
        name = "Debug Fragmentation",
    },
    {
        category = "advanced",
        type = "slider",
        mapping = CONFIG_VARIABLES["G_PHYSICS_ITERATIONS"],
        name = "Physics Iterations",
        value_unit = "iteration(s)",

        value_min = 0,
        value_max = 6,

        value_display_exp = 2,
    },
}

CONFIG_MENUS = {
    [1] = {
        title = "Global",
        filter = nil,
    },
    [2] = {
        title = "Fragmentation",
        filter = "fragmentation",
    },
    [3] = {
        title = "Tactical",
        filter = "tactical",
    },
    [4] = {
        title = "Keybindings",
        filter = "keybind",
    },
    [5] = {
        title = "Advanced",
        filter = "advanced",
    },
}
