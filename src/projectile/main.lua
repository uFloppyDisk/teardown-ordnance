---@type Projectile[]
__PROJECTILES = {}
---@type { [string]: ProjectileProps }
__PROJECTILES_TYPES = {}
---@type { [string]: function }
__PROJECTILES_HANDLERS = {}

local function generateHandlerId(typeName, ...)
    return typeName .. ":" .. table.concat(..., ".")
end

---@type ProjectileInitFn
local function defaultInitFn(projectile, props)
    ProjectileBehaviour.stageProjectile(projectile, props)

    return projectile
end

---@type ProjectileAfterInitFn
local function defaultAfterInitFn(projectile, props)
    if FdAssertTableKeys(props, "sounds", "fire") then
        FdPlayDistantSound(props.sounds.fire, {
            heading = projectile._initial.attack.heading,
            use_random_pitch = true,
        })
    end
    return projectile
end

---@type ProjectileTickFn
local function defaultTickFn(projectile, props)
    if projectile.state ~= SHELL_STATE.ACTIVE then return end

    local per_tick_position = ProjectileUtil.calculatePerTickPosition(projectile)
    local heading = projectile._initial.attack.heading
    local pitch = projectile._initial.attack.pitch
    ProjectileUtil.drawSprite(props.sprite, per_tick_position, heading, pitch)
end

---@type ProjectileUpdateFn
local function defaultUpdateFn(projectile, props, dt)
    if projectile.transform == nil or projectile.velocity == nil then
        return
    end
    if projectile.state ~= SHELL_STATE.ACTIVE then return end

    ProjectileBehaviour.stepPhysics(projectile, dt)

    local hit, detonate_position = ProjectileUtil.hitscan(projectile)
    if hit then
        projectile._cache.detonate_position = detonate_position
        Projectiles.getHandler(projectile.type, "onDetonate")(projectile, props)
    end

    FdAddToDebugTable(DEBUG_LINES, {
        projectile._cache.previous_transform.pos,
        projectile.transform.pos,
        { 0, 1, 0, 0.5 }
    })
end

---@type ProjectileAfterUpdateFn
local function defaultAfterUpdateFn(projectile)
    local current_distance = VecLength(VecSub(projectile.transform.pos, projectile._initial.destination))
    if projectile._cache.distance_to_destination ~= nil
        and current_distance > projectile._cache.distance_to_destination
        and current_distance > PROJECTILE_MAX_OVERSHOOT
    then
        DebugPrint("Projectile expired due to overshoot")
        projectile.state = SHELL_STATE.NONE
    else
        projectile._cache.distance_to_destination = current_distance
    end

    if projectile.age > PROJECTILE_MAX_AGE then
        DebugPrint("Projectile expired due to age")
        projectile.state = SHELL_STATE.NONE
    end
end

---@type ProjectileDetonateFn
local function defaultDetonateFn(projectile, props)
    local detonate_at = projectile._cache.detonate_position or projectile.transform.pos

    DebugPrint("Detonating projectile")
    DebugPrint(detonate_at)

    FdAddToDebugTable(DEBUG_POSITIONS, { detonate_at, COLOUR["red"] })

    projectile.state = SHELL_STATE.DETONATED

    local hole = props.makeHoleSizes or {}
    MakeHole(
        detonate_at,
        hole.soft or 0,
        hole.medium or 0,
        hole.hard or 0,
        false
    )

    if not props.explosiveYield or props.explosiveYield <= 0 then return end
    Explosion(detonate_at, props.explosiveYield)
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

function Projectiles.getHandler(typeName, ...)
    local keys = ...
    if type(keys) ~= "table" then
        keys = { keys }
    end

    return __PROJECTILES_HANDLERS[generateHandlerId(typeName, keys)] or function() end
end

---comment
---@param typeName string
---@param keys string[]
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
    return function(...)
        return Projectiles.getHandler(typeName, ...)
    end
end

function Projectiles.createHandlerSetter(typeName)
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
    setHandler({ "init" }, def.init, defaultInitFn)
    setHandler({ "tick" }, def.tick, defaultTickFn)
    setHandler({ "update" }, def.update, defaultUpdateFn)
    setHandler({ "onDetonate" }, def.onDetonate, defaultDetonateFn)

    setHandler({ "afterInit" }, def.afterInit, defaultAfterInitFn)

    setHandler({ "beforeTick" }, def.beforeTick)
    setHandler({ "afterTick" }, def.afterTick)

    setHandler({ "beforeUpdate" }, def.beforeUpdate)
    setHandler({ "afterUpdate" }, def.afterUpdate, defaultAfterUpdateFn)
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
        state = initialValues.state or SHELL_STATE.ACTIVE
    }

    local props = Projectiles.getPropsByType(typeName)

    Projectiles.getHandler(typeName, "init")(projectile, props)
    Projectiles.getHandler(typeName, "afterInit")(projectile, props)

    table.insert(__PROJECTILES, projectile)
end

function Projectiles.tick(dt)
    DebugWatch("Projectiles", tostring(#__PROJECTILES))
    for _, projectile in ipairs(__PROJECTILES) do
        local handler = Projectiles.createHandlerGetter(projectile.type)
        local props = Projectiles.getPropsByType(projectile.type)

        handler("beforeTick")(projectile, props, dt)

        projectile.age = projectile.age + dt

        handler("tick")(projectile, props, dt)
        handler("afterTick")(projectile, props, dt)
    end
end

function Projectiles.update(dt)
    for index, projectile in ipairs(__PROJECTILES) do
        local handler = Projectiles.createHandlerGetter(projectile.type)
        local props = Projectiles.getPropsByType(projectile.type)

        projectile._cache.previous_transform = TransformCopy(projectile.transform)

        handler("beforeUpdate")(projectile, props, dt)
        handler("update")(projectile, props, dt)

        projectile._cache.update_delta = dt
        projectile._cache.update_time = projectile.age

        handler("afterUpdate")(projectile, props, dt)

        if projectile.state == SHELL_STATE.NONE
            or projectile.state == SHELL_STATE.DETONATED
        then
            DebugPrint(string.format("Removing %s projectile at index %d...", projectile.type, index))
            table.remove(__PROJECTILES, index)
        end
    end
end
