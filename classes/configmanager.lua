#include "utils.lua"

G_CONFIG_REGISTRY = "savegame.mod.version_config"

CONFIG = {
    version = 1,
    incompatible = true
}

function CONFIG_init()
    if not HasKey(G_CONFIG_REGISTRY) then
        return true
    end

    local current_version = GetInt(G_CONFIG_REGISTRY)
    if current_version == nil then return true end

    if CONFIG.incompatible and not(current_version == CONFIG.version) then
        return true
    end

    if not CONFIG_checkIntegrity() then return true end

    return false
end

function CONFIG_getConfValue(obj_or_key)
    local objConf = obj_or_key
    if type(objConf) == "string" then
        objConf = CONFIG_VARIABLES[objConf]
        if objConf == nil then return nil end
    end

    local func = nil
    if objConf.value_type == nil then return nil end
    if objConf.value_type == "boolean" then func = GetBool end
    if objConf.value_type == "int" then func = GetInt end
    if objConf.value_type == "float" then func = GetFloat end
    if objConf.value_type == "string" then func = GetString end

    return func(objConf.variable)
end

function CONFIG_setConfValue(obj_or_key, value)
    local objConf = obj_or_key
    if type(objConf) == "string" then
        objConf = CONFIG_VARIABLES[objConf]
        if objConf == nil then return nil end
    end

    local func = nil
    if objConf.value_type == nil then return nil end
    if objConf.value_type == "boolean" then func = SetBool end
    if objConf.value_type == "int" then func = SetInt end
    if objConf.value_type == "float" then func = SetFloat end
    if objConf.value_type == "string" then func = SetString end

    return func(objConf.variable, value)
end

function CONFIG_checkIntegrity()
    for key, conf in pairs(CONFIG_VARIABLES) do
        if not HasKey(conf.variable) then
            dPrint("Could not find variable '"..conf.variable.."'")
            return false
        end
    end

    return true
end

function CONFIG_reset(no_restore)
    ClearKey("savegame.mod")

    if no_restore then
        dPrint("Config has been cleared.")
        return
    end

    for key, conf in pairs(CONFIG_VARIABLES) do
        CONFIG_setConfValue(conf, conf.value_default)
    end

    SetInt(G_CONFIG_REGISTRY, CONFIG.version)

    dPrint("Config has been reset.")
end