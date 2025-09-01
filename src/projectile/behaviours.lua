ProjectileBehaviour = {}

---@type ProjectileInitFn
function ProjectileBehaviour.defaultInit(projectile, props)
    ProjectileBehaviour.stageProjectile(projectile, props)
end

---@type ProjectileAfterInitFn
function ProjectileBehaviour.defaultAfterInit(projectile, props)
    if FdAssertTableKeys(props, "sounds", "fire") then
        FdPlayDistantSound(props.sounds.fire, {
            heading = projectile._initial.attack.heading,
            use_random_pitch = true,
        })
    end
end

---@type ProjectileBeforeTickFn
function ProjectileBehaviour.defaultBeforeTick(projectile)
    if projectile.state ~= SHELL_STATE.ACTIVE then
        return true
    end
end

---@type ProjectileBeforeUpdateFn
function ProjectileBehaviour.defaultBeforeUpdate(projectile)
    if projectile.state ~= SHELL_STATE.ACTIVE then
        return true
    end
end

---@type ProjectileTickFn
function ProjectileBehaviour.defaultTick(projectile, props)
    local per_tick_position = ProjectileUtil.calculatePerTickPosition(projectile)
    local heading = projectile._initial.attack.heading
    local pitch = projectile._initial.attack.pitch
    ProjectileUtil.drawSprite(props.sprite, per_tick_position, heading, pitch)
end

---@type ProjectileUpdateFn
function ProjectileBehaviour.defaultUpdate(projectile, props, dt)
    if projectile.transform == nil or projectile.velocity == nil then
        return true
    end

    ProjectileBehaviour.stepPhysics(projectile, dt)

    local hit, detonate_position = ProjectileUtil.hitscan(projectile)
    if hit then
        projectile._cache.detonate_position = detonate_position
        Projectiles.getHandler(projectile.type, "onDetonate")(projectile, props)
    end

    FdAddToDebugTable(DEBUG_LINES, {
        projectile._cache.previous_transform.pos,
        projectile.transform.pos,
        { 0, 1, 0, 0.5 },
    })
end

---@type ProjectileAfterUpdateFn
function ProjectileBehaviour.defaultAfterUpdate(projectile)
    local current_distance = VecLength(VecSub(projectile.transform.pos, projectile._initial.destination))
    if
        projectile._cache.distance_to_destination ~= nil
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
function ProjectileBehaviour.defaultDetonate(projectile, props)
    local detonate_at = projectile._cache.detonate_position or projectile.transform.pos

    DebugPrint("Detonating projectile")
    DebugPrint(detonate_at)

    FdAddToDebugTable(DEBUG_POSITIONS, { detonate_at, COLOUR["red"] })

    projectile.state = SHELL_STATE.DETONATED

    local hole = props.makeHoleSizes or {}
    MakeHole(detonate_at, hole.soft or 0, hole.medium or 0, hole.hard or 0, false)

    if not props.explosiveYield or props.explosiveYield <= 0 then
        return
    end
    Explosion(detonate_at, props.explosiveYield)
end

---comment
---@param projectile Projectile
---@param props ProjectileProps
function ProjectileBehaviour.stageProjectile(projectile, props)
    local destination = projectile._initial.destination
    local velocity = props.muzzleVelocity or PROJECTILE_DEFAULT_MUZZLE_VELOCITY
    local heading = projectile._initial.attack.heading
    local pitch = projectile._initial.attack.pitch

    -- -- Uncomment following lines to hold projectile for testing
    -- projectile.transform.pos = VecAdd(VecCopy(destination), Vec(0, 2, 0))
    -- projectile.velocity = Vec(0, 0, 0)
    -- return projectile

    local solved_transform, solved_velocity, actual_flight_time = ProjectileUtil.solveKinematicsAtApex(
        destination,
        velocity,
        heading,
        pitch,
        projectile._initial.timeToDestination
    )

    projectile.transform = solved_transform
    projectile.velocity = solved_velocity

    if projectile._initial.timeToDestination > actual_flight_time then
        projectile._cache.flightTimeDelay = projectile._initial.timeToDestination - actual_flight_time
    end
end

function ProjectileBehaviour.stepPhysics(projectile, dt)
    local physics_iterations = G_PHYSICS_ITERATIONS
    local iter_delta = dt / physics_iterations

    for _ = 0, physics_iterations, 1 do
        projectile.velocity = VecAdd(projectile.velocity, VecScale(G_VEC_GRAVITY, iter_delta))
        projectile.transform.pos = VecAdd(projectile.transform.pos, VecScale(projectile.velocity, iter_delta))
    end
end
