#import "utils.lua"

---@class ProjectileInitialValues
---@field destination TVec Resolved projectile destination
---@field state? SHELL_STATE Initial shell state
---
---@class (exact) Projectile
---@field _initial ProjectileInitialValues
---@field type string
---@field age number
---@field state SHELL_STATE
---
---@class (exact) ActiveProjectile : Projectile
---@field transform TTransform
---@field velocity TVec
---
---@class ProjectileProps
---@field muzzleVelocity number Muzzle velocity or top speed during ascent in m/s

---@alias ProjectileInitFn fun(projectile: Projectile): Projectile
---@alias ProjectileAfterInitFn ProjectileInitFn
---
---@alias ProjectileTickFn fun(projectile: ActiveProjectile, dt: number): nil
---@alias ProjectileBeforeTickFn ProjectileTickFn
---@alias ProjectileAfterTickFn ProjectileTickFn

---@class (exact) ProjectileDefinition
---@field props ProjectileProps
---@field init? ProjectileInitFn
---@field tick? ProjectileTickFn
---@field afterInit? ProjectileAfterInitFn
---@field afterTick? ProjectileAfterTickFn
---@field beforeTick? ProjectileBeforeTickFn
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
local function defaultInitFn(projectile)
    projectile.age = 0
    projectile.state = projectile._initial.state or SHELL_STATE.ACTIVE

    return projectile
end

---@type ProjectileTickFn
local function defaultTickFn(projectile, dt)
    projectile.age = projectile.age + dt

    local gravity = math.abs(G_VEC_GRAVITY[2])
    local world_down = TransformToLocalVec(projectile.transform, Vec(0, -1, 0))

    projectile.velocity = VecAdd(projectile.velocity, VecScale(world_down, gravity * dt))

    local position_new = TransformToParentPoint(projectile.transform, VecScale(projectile.velocity, dt))
    projectile.transform = Transform(position_new, projectile.transform.rot)
end


Projectiles = {}

function Projectiles.getTypes()
    return __PROJECTILES_TYPES
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
    __PROJECTILES_TYPES[typeName] = def.props

    setHandler(typeName, { "init" }, def.init, defaultInitFn)
    setHandler(typeName, { "tick" }, def.tick, defaultTickFn)

    setHandler(typeName, { "afterInit" }, def.afterInit)
    setHandler(typeName, { "beforeTick" }, def.beforeTick)
    setHandler(typeName, { "afterTick" }, def.afterTick)
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
        type = typeName
    }

    getHandler(typeName, "init")(projectile)
    getHandler(typeName, "afterInit")(projectile)

    table.insert(__PROJECTILES, projectile)
end

function Projectiles.tick(dt)
    DebugWatch("Projectiles", tostring(#__PROJECTILES))
    for _, projectile in ipairs(__PROJECTILES) do
        getHandler(projectile.type, "beforeTick")(projectile, dt)
        getHandler(projectile.type, "tick")(projectile, dt)
        getHandler(projectile.type, "afterTick")(projectile, dt)
    end
end
