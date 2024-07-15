G_CONFIG_REGISTRY = "savegame.mod.version_config"

CONFIG = {
    version = 1,
    incompatible = true
}

function CfgInit()
    if not HasKey(G_CONFIG_REGISTRY) then
        return true
    end

    local current_version = GetInt(G_CONFIG_REGISTRY)
    if current_version == nil then return true end

    if CONFIG.incompatible and not(current_version == CONFIG.version) then
        return true
    end

    if not CfgCheckIntegrity() then return true end

    return false
end

---Get config value based on TConfigMapping or string reference
---@param obj_or_key TConfigMapping | string
---@return any
function CfgGetValue(obj_or_key)
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

    if func == nil then return nil end

    return func(objConf.variable)
end

---Set config value based on TConfigMapping or string reference
---@param obj_or_key TConfigMapping | string
---@return nil
function CfgSetValue(obj_or_key, value)
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

    if func == nil then return nil end

    return func(objConf.variable, value)
end

---Check whether config is missing one or more definitions in user storage
---@return boolean # False if test not passed 
function CfgCheckIntegrity()
    for _, conf in pairs(CONFIG_VARIABLES) do
        if not HasKey(conf.variable) then
            FdLog("Could not find variable '"..conf.variable.."'")
            return false
        end
    end

    return true
end

---Reset config to defaults (or clear completely)
---@param no_restore? boolean Whether to clear config without restoring defaults
function CfgReset(no_restore)
    ClearKey("savegame.mod")

    if no_restore then
        FdLog("Config has been cleared.")
        return
    end

    for _, conf in pairs(CONFIG_VARIABLES) do
        CfgSetValue(conf, conf.value_default)
    end

    SetInt(G_CONFIG_REGISTRY, CONFIG.version)

    FdLog("Config has been reset.")
end
