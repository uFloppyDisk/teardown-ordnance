---@alias ProjectileHandlerKeyOrKeys ProjectileHandlerKey|ProjectileHandlerKey[]
---
---@type Projectile[]
__PROJECTILES = {}
---@type { [string]: ProjectileProps }
__PROJECTILES_TYPES = {}
---@type { [string]: function }
__PROJECTILES_HANDLERS = {}

local function generateHandlerId(typeName, ...)
    return typeName .. ":" .. table.concat(..., ".")
end

Projectiles = {}

function Projectiles.getTypes()
    return __PROJECTILES_TYPES
end

function Projectiles.getPropsByType(typeName)
    local props = __PROJECTILES_TYPES[typeName]
    if props == nil then
        error(string.format("Cannot get props for type '%s'; Does not exist", typeName))
        return {}
    end

    return props
end

---comment
---@param typeName string
---@param ... ProjectileHandlerKeyOrKeys
---@return function
function Projectiles.getHandler(typeName, ...)
    local keys = ...
    if type(keys) ~= "table" then
        keys = { keys }
    end

    return __PROJECTILES_HANDLERS[generateHandlerId(typeName, keys)] or function() end
end

---comment
---@param typeName string
---@param keys ProjectileHandlerKey[]
---@param handler? function
---@param default? function
function Projectiles.setHandler(typeName, keys, handler, default)
    if type(handler) ~= "function" then
        handler = default
    end

    if type(handler) ~= "function" then
        return
    end

    __PROJECTILES_HANDLERS[generateHandlerId(typeName, keys)] = handler
end

function Projectiles.createHandlerGetter(typeName)
    ---@type fun(...: ProjectileHandlerKeyOrKeys): function
    return function(...)
        return Projectiles.getHandler(typeName, ...)
    end
end

function Projectiles.createHandlerSetter(typeName)
    ---@type fun(...: ProjectileHandlerKeyOrKeys): nil
    return function(...)
        return Projectiles.setHandler(typeName, ...)
    end
end

---comment
---@param typeName string
---@param definitionGenerator ProjectileDefinitionGenerator
function Projectiles.defineProjectile(typeName, definitionGenerator)
    if __PROJECTILES_TYPES[typeName] ~= nil then
        error(string.format("Cannot define new projectile with type '%s'; Already exists", typeName))
        return
    end

    local def = definitionGenerator(typeName)
    __PROJECTILES_TYPES[typeName] = def.props or {}

    local setHandler = Projectiles.createHandlerSetter(typeName)
    setHandler({ "onInit" }, def.onInit, ProjectileBehaviour.defaultInit)
    setHandler({ "onTick" }, def.onTick, ProjectileBehaviour.defaultTick)
    setHandler({ "onUpdate" }, def.onUpdate, ProjectileBehaviour.defaultUpdate)
    setHandler({ "onDetonate" }, def.onDetonate, ProjectileBehaviour.defaultDetonate)

    setHandler({ "afterInit" }, def.afterInit, ProjectileBehaviour.defaultAfterInit)

    setHandler({ "beforeTick" }, def.beforeTick, ProjectileBehaviour.defaultBeforeTick)
    setHandler({ "afterTick" }, def.afterTick)

    setHandler({ "beforeUpdate" }, def.beforeUpdate, ProjectileBehaviour.defaultBeforeUpdate)
    setHandler({ "afterUpdate" }, def.afterUpdate, ProjectileBehaviour.defaultAfterUpdate)
end

---comment
---@param typeName string
---@param initialValues ProjectileInitialValues
function Projectiles.init(typeName, initialValues)
    if __PROJECTILES_TYPES[typeName] == nil then
        error(string.format("Cannot instantiate a projectile of type '%s'; Does not exist", typeName))
        return
    end

    local projectile = {
        _initial = initialValues,
        _cache = {},
        type = typeName,
        age = 0,
        state = initialValues.state or SHELL_STATE.ACTIVE,
        destination = ProjectileUtil.calcDeviation(initialValues.requested_destination, initialValues.deviation),
    }

    local props = Projectiles.getPropsByType(typeName)

    local skipInit = false
    skipInit = Projectiles.getHandler(typeName, "onInit")(projectile, props)
    if skipInit then
        return
    end

    skipInit = Projectiles.getHandler(typeName, "afterInit")(projectile, props)
    if skipInit then
        return
    end

    table.insert(__PROJECTILES, projectile)
end

function Projectiles.tick(dt)
    DebugWatch("Projectiles", tostring(#__PROJECTILES))
    for _, projectile in ipairs(__PROJECTILES) do
        local handler = Projectiles.createHandlerGetter(projectile.type)
        local props = Projectiles.getPropsByType(projectile.type)

        local _ = (function()
            local skipTick = false
            skipTick = handler("beforeTick")(projectile, props, dt)
            if skipTick then
                return
            end

            projectile.age = projectile.age + dt

            skipTick = handler("onTick")(projectile, props, dt)
            if skipTick then
                return
            end

            handler("afterTick")(projectile, props, dt)
        end)()
    end
end

function Projectiles.update(dt)
    for index, projectile in ipairs(__PROJECTILES) do
        local handler = Projectiles.createHandlerGetter(projectile.type)
        local props = Projectiles.getPropsByType(projectile.type)

        local _ = (function()
            projectile._cache.previous_transform = TransformCopy(projectile.transform)

            local skipUpdate = false
            skipUpdate = handler("beforeUpdate")(projectile, props, dt)
            if skipUpdate then
                return
            end

            skipUpdate = handler("onUpdate")(projectile, props, dt)
            if skipUpdate then
                return
            end

            projectile._cache.update_delta = dt
            projectile._cache.update_time = projectile.age

            handler("afterUpdate")(projectile, props, dt)
        end)()

        if projectile.state == SHELL_STATE.NONE or projectile.state == SHELL_STATE.DETONATED then
            DebugPrint(string.format("Removing %s projectile at index %d...", projectile.type, index))
            table.remove(__PROJECTILES, index)
        end
    end
end
