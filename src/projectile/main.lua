---@type Projectile[]
__PROJECTILES = {}
---@type { [string]: ProjectileProps }
__PROJECTILES_TYPES = {}
---@type { [string]: function }
__PROJECTILES_HANDLERS = {}

---@type ProjectileHandlerKey[]
local HOOK_TYPES = {
    "afterInit",
    "afterInit",
    "afterUpdate",
    "beforeTick",
    "beforeUpdate",
    "onInit",
    "onTick",
    "onUpdate",
}

---comment
---@param type_name string
---@param hook_name string
---@return string
local function generateHandlerId(type_name, hook_name)
    return type_name .. ":" .. hook_name
end

Projectiles = {}

function Projectiles.getTypes()
    return __PROJECTILES_TYPES
end

function Projectiles.getProjectiles()
    return __PROJECTILES
end

---comment
---@param projectile Projectile
---@return table
function Projectiles.getProjectileProps(projectile)
    local props = __PROJECTILES_TYPES[projectile.type]
    if props == nil then
        error(string.format("Cannot get props for type '%s'; Does not exist", projectile.type))
        return {}
    end

    return props
end

---comment
---@param type_name string
---@param hook_name ProjectileHandlerKey
---@return function
function Projectiles.getHandler(type_name, hook_name)
    local id = generateHandlerId(type_name, hook_name)
    local handlers = __PROJECTILES_HANDLERS[id]
    if not handlers then
        return function() end
    end

    return handlers
end

---comment
---@param type_name string
---@param hook_name ProjectileHandlerKey
---@param handler? function
function Projectiles.setHandler(type_name, hook_name, handler)
    if type(handler) ~= "function" then
        return
    end

    local id = generateHandlerId(type_name, hook_name)
    __PROJECTILES_HANDLERS[id] = handler
end

function Projectiles.createHandlerGetter(type_name)
    ---@type fun(hook_name: ProjectileHandlerKey): function
    return function(hook_name)
        return Projectiles.getHandler(type_name, hook_name)
    end
end

---comment
---@param type_name string
---@param behaviours ProjectileBehaviourFuncs[]
---@param definitionGenerator ProjectileDefinitionGenerator
function Projectiles.defineProjectile(type_name, behaviours, definitionGenerator)
    if __PROJECTILES_TYPES[type_name] ~= nil then
        error(string.format("Cannot define new projectile with type '%s'; Already exists", type_name))
        return
    end

    local def = definitionGenerator(type_name)
    __PROJECTILES_TYPES[type_name] = def.props or {}

    ---@type { [string]: function[] }
    local hooks_by_type = {}

    for _, behaviour in ipairs(behaviours) do
        ---@type ProjectileBehaviour
        local resolved = behaviour
        if type(resolved) == "function" then
            resolved = resolved(def.props)
        end

        for name, handler in pairs(resolved) do
            if type(hooks_by_type[name]) ~= "table" then
                hooks_by_type[name] = {}
            end

            table.insert(hooks_by_type[name], handler)
        end
    end

    for _, name in ipairs(HOOK_TYPES) do
        if def[name] then
            table.insert(hooks_by_type[name], def[name])
        end
    end

    for name, hooks in pairs(hooks_by_type) do
        Projectiles.setHandler(type_name, name, function(...)
            for _, hook in ipairs(hooks) do
                hook(...)
            end
        end)
    end
end

---comment
---@param type_name string
---@param initial_values ProjectileInitialValues
function Projectiles.init(type_name, initial_values)
    if __PROJECTILES_TYPES[type_name] == nil then
        error(string.format("Cannot instantiate a projectile of type '%s'; Does not exist", type_name))
        return
    end

    local projectile = {
        _initial = initial_values,
        _cache = {},
        type = type_name,
        age = 0,
        state = initial_values.state or SHELL_STATE.ACTIVE,
        destination = ProjectileUtil.calcDeviation(initial_values.requested_destination, initial_values.deviation),
    }

    local props = Projectiles.getProjectileProps(projectile)

    local skip = false
    skip = Projectiles.getHandler(type_name, "onInit")(projectile, props)
    if skip then
        return
    end

    skip = Projectiles.getHandler(type_name, "afterInit")(projectile, props)
    if skip then
        return
    end

    table.insert(__PROJECTILES, projectile)
end

function Projectiles.tick(projectile, dt)
    local props = Projectiles.getProjectileProps(projectile)
    local handler = Projectiles.createHandlerGetter(projectile.type)

    local skip = false
    skip = handler("beforeTick")(projectile, props, dt)
    if skip then
        return
    end

    projectile.age = projectile.age + dt

    skip = handler("onTick")(projectile, props, dt)
    if skip then
        return
    end

    handler("afterTick")(projectile, props, dt)
end

function Projectiles.update(projectile, dt)
    local props = Projectiles.getProjectileProps(projectile)
    local handler = Projectiles.createHandlerGetter(projectile.type)

    local skip = false
    skip = handler("beforeUpdate")(projectile, props, dt)
    if skip then
        return
    end

    skip = handler("onUpdate")(projectile, props, dt)
    if skip then
        return
    end

    projectile._cache.update_delta = dt
    projectile._cache.update_time = projectile.age

    handler("afterUpdate")(projectile, props, dt)
end
