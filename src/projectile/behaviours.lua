ProjectileBehaviour = {}

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

    local solved_transform, solved_velocity, actual_flight_time =
        ProjectileUtil.solveKinematicsAtApex(destination, velocity,
            heading, pitch, projectile._initial.timeToDestination)

    projectile.transform = solved_transform
    projectile.velocity = solved_velocity

    if projectile._initial.timeToDestination > actual_flight_time then
        projectile._cache.flightTimeDelay = projectile._initial.timeToDestination - actual_flight_time
    end
end

function ProjectileBehaviour.calculatePerTickPosition(projectile)
    local lerp = (projectile.age - projectile._cache.update_time) / projectile._cache.update_delta
    local pos = VecLerp(projectile._cache.previous_transform.pos, projectile.transform.pos, lerp)

    projectile._cache.per_tick_position = pos
    return pos
end

function ProjectileBehaviour.stepPhysics(projectile, dt)
    local physics_iterations = G_PHYSICS_ITERATIONS
    local iter_delta = dt / physics_iterations

    for _ = 0, physics_iterations, 1 do
        projectile.velocity = VecAdd(projectile.velocity, VecScale(G_VEC_GRAVITY, iter_delta))
        projectile.transform.pos = VecAdd(projectile.transform.pos, VecScale(projectile.velocity, iter_delta))
    end
end
