#import "utils.lua"

---@class (exact) Projectile
---@field type string
---@field age number

---@alias ProjectileInitFn fun(projectile: Projectile): Projectile
---@alias ProjectileAfterInitFn ProjectileInitFn
---
---@alias ProjectileTickFn fun(projectile: Projectile, dt: number): nil
---@alias ProjectileBeforeTickFn ProjectileTickFn
---@alias ProjectileAfterTickFn ProjectileTickFn

---@class (exact) ProjectileGeneratorSchema
---@field init? ProjectileInitFn
---@field tick? ProjectileTickFn
---@field afterInit? ProjectileAfterInitFn
---@field afterTick? ProjectileAfterTickFn
---@field beforeTick? ProjectileBeforeTickFn
---
---@alias ProjectileGenerator fun(typeName: string): ProjectileGeneratorSchema


---@type Projectile[]
__PROJECTILES = {}
---@type string[]
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


Projectiles = {}

function Projectiles.getTypes()
    return __PROJECTILES_TYPES
end

---comment
---@param typeName string
---@param projectileGenerator ProjectileGenerator
function Projectiles.defineProjectile(typeName, projectileGenerator)
    if __PROJECTILES_TYPES[typeName] ~= nil then
        error(string.format("Cannot define new projectile with type '%s'; Already exists", typeName))
        return
    end

    local def = projectileGenerator(typeName)
    __PROJECTILES_TYPES[typeName] = typeName

    setHandler(typeName, { "afterInit" }, def.afterInit)
    setHandler(typeName, { "beforeTick" }, def.beforeTick)
    setHandler(typeName, { "afterTick" }, def.afterTick)

    setHandler(typeName, { "init" }, def.init, function(projectile)
        projectile.type = typeName
        projectile.age = 0
        return projectile
    end)
    setHandler(typeName, { "tick" }, def.tick, function(projectile, dt)
        projectile.age = projectile.age + dt
    end)
end

function Projectiles.init(typeName)
    if __PROJECTILES_TYPES[typeName] == nil then
        error(string.format("Cannot instantiate a projectile of type '%s'; Does not exist", typeName))
        return
    end

    local projectile = getHandler(typeName, "init")({})
    getHandler(projectile.type, "afterInit")(projectile)

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
