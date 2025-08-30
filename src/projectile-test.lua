#include "utils.lua"
#include "shell/main.lua"
#include "projectile-defaults.lua"

---@class ProjectileAttack
---@field heading number Heading degrees [0, 360]
---@field pitch number Pitch degrees wrt XZ-plane (<=90)
---
---@class ProjectileSprite
---@field handle number LoadSprite handle
---@field width number 
---@field aspect_ratio number Aspect ratio wrt sprite width

---@class ProjectileInitialValues
---@field destination TVec Resolved projectile destination
---@field attack ProjectileAttack
---@field timeToDestination number Time in seconds to reach destination
---@field state? SHELL_STATE Initial shell state
---
---@class (exact) Projectile
---@field _initial ProjectileInitialValues
---@field _cache { [string]: any }
---@field type string
---@field age number
---@field state SHELL_STATE
---@field transform TTransform
---@field velocity TVec
---
---@class ProjectileProps
---@field muzzleVelocity number Muzzle velocity or top speed during ascent in m/s
---@field sprite ProjectileSprite

---@alias ProjectileInitFn fun(projectile: Projectile, props: ProjectileProps): Projectile
---@alias ProjectileAfterInitFn ProjectileInitFn
---
---@alias ProjectileTickFn fun(projectile: Projectile, props: ProjectileProps, dt: number): nil
---@alias ProjectileBeforeTickFn ProjectileTickFn
---@alias ProjectileAfterTickFn ProjectileTickFn
---
---@alias ProjectileUpdateFn fun(projectile: Projectile, props: ProjectileProps, dt: number): nil
---@alias ProjectileBeforeUpdateFn ProjectileUpdateFn
---@alias ProjectileAfterUpdateFn ProjectileUpdateFn

---@class (exact) ProjectileDefinition
---@field props ProjectileProps
---@field init? ProjectileInitFn
---@field afterInit? ProjectileAfterInitFn
---@field tick? ProjectileTickFn
---@field beforeTick? ProjectileBeforeTickFn
---@field afterTick? ProjectileAfterTickFn
---@field update? ProjectileUpdateFn
---@field beforeUpdate? ProjectileBeforeUpdateFn
---@field afterUpdate? ProjectileAfterUpdateFn
---
---@alias ProjectileDefinitionGenerator fun(typeName: string): ProjectileDefinition


---@type Projectile[]
__PROJECTILES = {}
---@type { [string]: ProjectileProps }
__PROJECTILES_TYPES = {}
---@type { [string]: function }
__PROJECTILES_HANDLERS = {}

local function generateHandlerId(typeName, ...)
    return typeName .. ":" .. table.concat(..., ".")
end

local function getHandler(typeName, ...)
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
local function setHandler(typeName, keys, handler, default)
    if type(handler) ~= "function" then
        handler = default
    end

    if type(handler) ~= "function" then
        return
    end

    __PROJECTILES_HANDLERS[generateHandlerId(typeName, keys)] = handler
end

---@type ProjectileInitFn
local function defaultInitFn(projectile, props)
    local destination = projectile._initial.destination
    local velocity = props.muzzleVelocity or PROJECTILE_DEFAULT_MUZZLE_VELOCITY

    -- -- Uncomment following lines to hold projectile for testing
    -- projectile.transform.pos = VecAdd(VecCopy(destination), Vec(0, 2, 0))
    -- return

    local heading_radians = math.rad((projectile._initial.attack.heading + 90) % 360)
    local heading_x = math.sin(heading_radians)
    local heading_z = math.cos(heading_radians)
    local heading_vec = Vec(heading_x, 0, heading_z)

    local pitch_radians = math.rad(projectile._initial.attack.pitch)

    local velocity_horizontal = velocity * math.cos(pitch_radians)
    local velocity_vertical = velocity * math.sin(pitch_radians)
    local velocity_vec = VecScale(heading_vec, velocity_horizontal)

    -- Flight Time Calculation
    local eta_from_apogee = (velocity * math.sin(pitch_radians)) / math.abs(G_VEC_GRAVITY[2])

    -- ETA compensation
    local at_time = projectile._initial.timeToDestination
    if at_time >= eta_from_apogee then
        -- self.flight_time = at_time - eta_from_apogee -- TODO: implement inactive flight time
        at_time = eta_from_apogee
    end

    local xz_at_time = VecAdd(VecScale(velocity_vec, at_time), VecCopy(destination))
    local y_at_time = -0.5 * (math.abs(G_VEC_GRAVITY[2]) * (at_time * at_time)) -- -1/2gt^2
    y_at_time = y_at_time + (velocity_vertical * at_time) + destination[2]    -- + (vy0)t + y0

    projectile.transform = Transform(Vec(xz_at_time[1], y_at_time, xz_at_time[3]))
    projectile.velocity = Vec(-velocity_vec[1], -velocity_vertical - (G_VEC_GRAVITY[2] * at_time), -velocity_vec[3])

    return projectile
end

---@type ProjectileTickFn
local function defaultTickFn(projectile, props, dt)
    local lerp = (projectile.age - projectile._cache.update_time) / projectile._cache.update_delta
    local pos = VecLerp(projectile._cache.previous_transform.pos, projectile.transform.pos, lerp)

    local fake_shell = {
        heading = projectile._initial.attack.heading,
        pitch = projectile._initial.attack.pitch,
        position = pos,
        sprite = {
            img = props.sprite.handle,
            width = props.sprite.width,
            scaling_factor = props.sprite.aspect_ratio,
        }
    }
    ShellDrawSprite(fake_shell)
end

---@type ProjectileUpdateFn
local function defaultUpdateFn(projectile, _, dt)
    if projectile.transform == nil or projectile.velocity == nil then
        return
    end

    projectile._cache.update_delta = dt
    projectile._cache.update_time = projectile.age
    projectile._cache.previous_transform = TransformCopy(projectile.transform)

    local physics_iterations = G_PHYSICS_ITERATIONS
    local iter_delta = dt / physics_iterations

    -- Calculation of gravity's effect on shell velocity and position over N iterations
    for _ = 0, physics_iterations, 1 do
        projectile.velocity = VecAdd(projectile.velocity, VecScale(G_VEC_GRAVITY, iter_delta))
        projectile.transform.pos = VecAdd(projectile.transform.pos, VecScale(projectile.velocity, iter_delta))
    end

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

    FdAddToDebugTable(DEBUG_LINES, {
        projectile._cache.previous_transform.pos,
        projectile.transform.pos,
        { 0, 1, 0, 0.5 }
    })
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
---@param definitionGenerator ProjectileDefinitionGenerator
function Projectiles.defineProjectile(typeName, definitionGenerator)
    if __PROJECTILES_TYPES[typeName] ~= nil then
        error(string.format("Cannot define new projectile with type '%s'; Already exists", typeName))
        return
    end

    local def = definitionGenerator(typeName)
    __PROJECTILES_TYPES[typeName] = def.props or {}

    setHandler(typeName, { "init" }, def.init, defaultInitFn)
    setHandler(typeName, { "tick" }, def.tick, defaultTickFn)
    setHandler(typeName, { "update" }, def.update, defaultUpdateFn)

    setHandler(typeName, { "afterInit" }, def.afterInit)

    setHandler(typeName, { "beforeTick" }, def.beforeTick)
    setHandler(typeName, { "afterTick" }, def.afterTick)

    setHandler(typeName, { "beforeUpdate" }, def.beforeUpdate)
    setHandler(typeName, { "afterUpdate" }, def.afterUpdate)
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

    getHandler(typeName, "init")(projectile, props)
    getHandler(typeName, "afterInit")(projectile, props)

    table.insert(__PROJECTILES, projectile)
end

function Projectiles.tick(dt)
    DebugWatch("Projectiles", tostring(#__PROJECTILES))
    for _, projectile in ipairs(__PROJECTILES) do
        local props = Projectiles.getPropsByType(projectile.type)

        getHandler(projectile.type, "beforeTick")(projectile, props, dt)

        projectile.age = projectile.age + dt

        getHandler(projectile.type, "tick")(projectile, props, dt)
        getHandler(projectile.type, "afterTick")(projectile, props, dt)
    end
end

function Projectiles.update(dt)
    for index, projectile in ipairs(__PROJECTILES) do
        local props = Projectiles.getPropsByType(projectile.type)

        getHandler(projectile.type, "beforeUpdate")(projectile, props, dt)
        getHandler(projectile.type, "update")(projectile, props, dt)
        getHandler(projectile.type, "afterUpdate")(projectile, props, dt)

        if projectile.state == SHELL_STATE.NONE then
            DebugPrint(string.format("Removing %s projectile at index %d...", projectile.type, index))
            table.remove(__PROJECTILES, index)
        end
    end
end
