---@type Projectile[]
__PROJECTILES = {}
---@type { [string]: ProjectileProps }
__PROJECTILES_TYPES = {}
---@type { [string]: function }
__PROJECTILES_HANDLERS = {}

---@type ProjectileHandlerKey[]
local HOOK_TYPES = {
    "afterInit",
    "afterTick",
    "afterUpdate",
    "beforeInit",
    "beforeTick",
    "beforeUpdate",
    "onDraw",
    "onInit",
    "onTick",
    "onUpdate",
}

---@type { [string]: boolean }
local HOOK_TYPE_SET = {}

for _, hook_name in ipairs(HOOK_TYPES) do
    HOOK_TYPE_SET[hook_name] = true
end

---Insert an id into the ready queue while preserving the original behaviour order.
---@param queue string[]
---@param id string
---@param order_index { [string]: integer }
local function insertByOriginalOrder(queue, id, order_index)
    for index, queued_id in ipairs(queue) do
        if order_index[id] < order_index[queued_id] then
            table.insert(queue, index, id)
            return
        end
    end

    table.insert(queue, id)
end

---Resolve behaviour dependencies using Kahn's topological sorting algorithm.
---@param behaviours ProjectileBehaviourDefinition[]
---@return ProjectileBehaviourDefinition[]
local function topologicalSortBehaviours(behaviours)
    ---@type { [string]: ProjectileBehaviourDefinition }
    local behaviours_by_id = {}
    ---@type { [string]: integer }
    local order_index = {}
    ---@type { [string]: string[] }
    local dependants_by_id = {}
    ---@type { [string]: integer }
    local dependency_count = {}

    for index, behaviour in ipairs(behaviours) do
        local id = behaviour.id

        if type(id) ~= "string" then
            error(string.format("Projectile behaviour at index %d has no id", index))
        end

        if behaviours_by_id[id] ~= nil then
            error(string.format("Duplicate projectile behaviour id '%s'", id))
        end

        behaviours_by_id[id] = behaviour
        order_index[id] = index
        dependants_by_id[id] = {}
        dependency_count[id] = 0
    end

    for _, behaviour in ipairs(behaviours) do
        local id = behaviour.id --[[@as string]]
        local seen_dependencies = {}

        for _, required_id in ipairs(behaviour.requires or {}) do
            if seen_dependencies[required_id] then
                error(string.format("Behaviour '%s' lists dependency '%s' more than once", id, required_id))
            end

            seen_dependencies[required_id] = true

            if behaviours_by_id[required_id] == nil then
                error(string.format("Behaviour '%s' requires missing behaviour '%s'", id, required_id))
            end

            table.insert(dependants_by_id[required_id], id)
            dependency_count[id] = dependency_count[id] + 1
        end
    end

    local ready = {}

    for _, behaviour in ipairs(behaviours) do
        local id = behaviour.id --[[@as string]]

        if dependency_count[id] == 0 then
            insertByOriginalOrder(ready, id, order_index)
        end
    end

    local sorted = {}

    while #ready > 0 do
        local id = table.remove(ready, 1)
        table.insert(sorted, behaviours_by_id[id])

        for _, dependant_id in ipairs(dependants_by_id[id]) do
            dependency_count[dependant_id] = dependency_count[dependant_id] - 1

            if dependency_count[dependant_id] == 0 then
                insertByOriginalOrder(ready, dependant_id, order_index)
            end
        end
    end

    if #sorted ~= #behaviours then
        error("Circular dependency detected between projectile behaviours")
    end

    return sorted
end

---@type { [string]: integer }
local shell_values_class_lookup = {}

---comment
---@param type_name string
---@param hook_name string
---@return string
local function generateHandlerId(type_name, hook_name)
    return type_name .. ":" .. hook_name
end

---Bind scoped helpers to a lifecycle handler.
---@param handler function
---@param helpers ProjectileThisHelpers|ProjectileBehaviourHelpers
---@return function
local function createScopedHandler(handler, helpers)
    return function(projectile, props, ...)
        return handler(projectile, props, helpers, ...)
    end
end

Projectiles = {}

function Projectiles.getTypes()
    return __PROJECTILES_TYPES
end

function Projectiles.getProjectiles()
    return __PROJECTILES
end

function Projectiles.removeProjectile(index)
    table.remove(__PROJECTILES, index)
end

---comment
---@param projectile ProtoProjectile
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
---@param behaviours ProjectileBehaviour[]
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

    ---@type ProjectileBehaviourDefinition[]
    local resolved_behaviours = {}

    for _, behaviour in ipairs(behaviours) do
        ---@type ProjectileBehaviour
        local resolved = behaviour
        if type(resolved) == "function" then
            resolved = resolved(def.props)
        end

        table.insert(resolved_behaviours, resolved)
    end

    for _, behaviour in ipairs(topologicalSortBehaviours(resolved_behaviours)) do
        local helpers = CreateProjectileBehaviourHelpers(behaviour.id)

        for name, handler in pairs(behaviour) do
            if HOOK_TYPE_SET[name] then
                if type(hooks_by_type[name]) ~= "table" then
                    hooks_by_type[name] = {}
                end

                table.insert(hooks_by_type[name], createScopedHandler(handler, helpers))
            end
        end
    end

    local projectile_helpers = CreateProjectileThisHelpers(type_name)
    for _, name in ipairs(HOOK_TYPES) do
        if def[name] then
            if hooks_by_type[name] == nil then
                hooks_by_type[name] = {}
            end
            table.insert(hooks_by_type[name], createScopedHandler(def[name], projectile_helpers))
        end
    end

    for name, hooks in pairs(hooks_by_type) do
        Projectiles.setHandler(type_name, name, function(...)
            local success = nil
            local skip = false

            for _, hook in ipairs(hooks) do
                local skip_or_error = nil
                success, skip_or_error = pcall(hook, ...)
                if not success then
                    FdLog(
                        string.format(
                            '[ERROR]: Caught error while executing "%s" %s handler: %s',
                            type_name,
                            name,
                            skip_or_error --[[@as string]]
                        )
                    )
                end

                skip = skip or skip_or_error == true
            end

            return skip
        end)
    end

    if def.selectable == false then
        return
    end

    local props = def.props

    -- Insert projectile info into legacy shell picker for the time being
    local _ = (function()
        local shell_value_index = shell_values_class_lookup[props.munition_class]
        if not shell_value_index then
            local munition_class = {
                name = props.munition_class,
                variants = {},
            }

            table.insert(SHELL_VALUES, munition_class)
            shell_values_class_lookup[munition_class.name] = #SHELL_VALUES
        end

        local variant = {
            id = type_name,
            name = props.munition_type,
        }

        shell_value_index = shell_values_class_lookup[props.munition_class]
        table.insert(SHELL_VALUES[shell_value_index].variants, variant)
    end)()
end

---comment
---@param type_name string
---@param initial_values ProjectileInitialValues
---@return Projectile?
function Projectiles.init(type_name, initial_values)
    if __PROJECTILES_TYPES[type_name] == nil then
        error(string.format("Cannot instantiate a projectile of type '%s'; Does not exist", type_name))
        return
    end

    local projectile = {
        _initial = initial_values,
        _cache = {
            _behaviours = {},
            _this = {},
        },
        type = type_name,
        transform = initial_values.transform and TransformCopy(initial_values.transform) or nil,
        velocity = initial_values.velocity and VecCopy(initial_values.velocity) or nil,
    }

    local props = Projectiles.getProjectileProps(projectile)

    local skip = false
    skip = Projectiles.getHandler(type_name, "beforeInit")(projectile, props)
    if skip then
        return
    end

    projectile.age = projectile.age or 0
    projectile.state = projectile.state or initial_values.state or SHELL_STATE.ACTIVE
    projectile.destination =
        ProjectileUtil.calcDeviation(initial_values.requested_destination, initial_values.deviation)

    skip = Projectiles.getHandler(type_name, "onInit")(projectile, props)
    if skip then
        return
    end

    skip = Projectiles.getHandler(type_name, "afterInit")(projectile, props)
    if skip then
        return
    end

    table.insert(__PROJECTILES, projectile)
    return projectile
end

---Spawn a projectile from explicit world-space kinematics.
---@param type_name string
---@param spawn_values ProjectileSpawnValues
---@return Projectile?
function Projectiles.spawn(type_name, spawn_values)
    return Projectiles.init(type_name, {
        attack = {
            heading = 0,
            pitch = 0,
        },
        requested_destination = VecCopy(spawn_values.transform.pos),
        state = spawn_values.state or SHELL_STATE.ACTIVE,
        timeToDestination = 0,
        transform = TransformCopy(spawn_values.transform),
        velocity = VecCopy(spawn_values.velocity),
    })
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

function Projectiles.draw(projectile)
    local props = Projectiles.getProjectileProps(projectile)
    local handler = Projectiles.createHandlerGetter(projectile.type)

    handler("onDraw")(projectile, props)
end
