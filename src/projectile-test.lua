#import "utils.lua"

__PROJECTILES = {}
__PROJECTILES_HANDLERS = {}

local function getProjectileHandlers(name)
    if __PROJECTILES_HANDLERS[name] ~= nil then
        return __PROJECTILES_HANDLERS[name]
    end

    __PROJECTILES_HANDLERS[name] = {}
    return __PROJECTILES_HANDLERS[name]
end

local function handlerId(...)
    return table.concat(arg, ".")
end

local function handlerOrDefault(handler, default)
    if not handler or type(handler) == "function" then
        return default
    end

    return handler
end


Projectiles = {}

function Projectiles.defineProjectile(name, projectileGenerator)
    local def = projectileGenerator(name)
    local handlers = getProjectileHandlers(name)

    handlers[handlerId("init")] = handlerOrDefault(def.init, function()
        DebugPrint("Default init handler for '" .. name .. "'")
    end)

    handlers[handlerId("tick")] = handlerOrDefault(def.tick, function()
        DebugPrint(name .. " ticked once")
    end)
end

function Projectiles.tick()
    DebugWatch("Projectiles", #__PROJECTILES)
    DebugWatch("Handlers", #__PROJECTILES_HANDLERS)
    for key, value in pairs(__PROJECTILES_HANDLERS) do
        DebugPrint(key .. ":" .. type(value))
    end
end
