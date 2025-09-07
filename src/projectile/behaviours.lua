---@type { [string]: ProjectileBehaviour }
ProjectileBehaviour = {}

ProjectileBehaviour.HasPhysics = {
    afterInit = function(projectile)
        if not projectile.transform then
            projectile.transform = Transform(projectile.destination, Quat())
        end

        if not projectile.velocity then
            projectile.velocity = Vec()
        end
    end,
    beforeUpdate = function(projectile)
        projectile._cache.previous_transform = TransformCopy(projectile.transform)
    end,
    onUpdate = function(projectile, _, dt)
        if projectile.state ~= SHELL_STATE.ACTIVE then
            return
        end

        local physics_iterations = G_PHYSICS_ITERATIONS
        local iter_delta = dt / physics_iterations

        for _ = 0, physics_iterations, 1 do
            projectile.velocity = VecAdd(projectile.velocity, VecScale(G_VEC_GRAVITY, iter_delta))
            projectile.transform.pos = VecAdd(projectile.transform.pos, VecScale(projectile.velocity, iter_delta))
        end

        FdAddToDebugTable(DEBUG_LINES, {
            projectile._cache.previous_transform.pos,
            projectile.transform.pos,
            { 0, 1, 0, 0.5 },
        })
    end,
    afterUpdate = function(projectile)
        if projectile.state ~= SHELL_STATE.ACTIVE then
            return
        end

        if projectile.age > PROJECTILE_MAX_AGE then
            DebugPrint("Projectile expired due to age")
            projectile.state = SHELL_STATE.NONE
        end
    end,
}

ProjectileBehaviour.HasBallistics = {
    onInit = function(projectile, props)
        local destination = projectile.destination
        local velocity = props.muzzle_velocity or PROJECTILE_DEFAULT_MUZZLE_VELOCITY
        local heading = projectile._initial.attack.heading
        local pitch = projectile._initial.attack.pitch

        local solved_transform, solved_velocity = ProjectileUtil.solveKinematicsAtApex(
            destination,
            velocity,
            heading,
            pitch,
            projectile._initial.timeToDestination
        )

        projectile.transform = solved_transform
        projectile.velocity = solved_velocity
    end,
    afterUpdate = function(projectile)
        if projectile.state ~= SHELL_STATE.ACTIVE then
            return
        end

        local current_distance = VecLength(VecSub(projectile.transform.pos, projectile.destination))
        if
            projectile._cache.distance_to_destination ~= nil
            and current_distance > projectile._cache.distance_to_destination
            and current_distance > PROJECTILE_MAX_OVERSHOOT
        then
            DebugPrint("Projectile expired due to overshoot")
            projectile.state = SHELL_STATE.NONE
            return
        end

        projectile._cache.distance_to_destination = current_distance
    end,
}

ProjectileBehaviour.HasImpactFuze = {
    onUpdate = function(projectile, props)
        if projectile.state ~= SHELL_STATE.ACTIVE then
            return
        end
        if not projectile.transform or not projectile._cache.previous_transform then
            return
        end

        local hit, detonate_position =
            ProjectileUtil.hitscan(projectile.transform, projectile._cache.previous_transform)
        if hit then
            local pos = detonate_position --[[@as TVec]]
            ProjectileUtil.detonate(pos, props.explosive_yield, props.hole_sizes)
            projectile.state = SHELL_STATE.DETONATED
        end
    end,
}

ProjectileBehaviour.HasSprite = {
    onTick = function(projectile, props)
        if projectile.state ~= SHELL_STATE.ACTIVE then
            return
        end

        local per_tick_position = ProjectileUtil.calculatePerTickPosition(
            projectile.transform.pos,
            projectile._cache.previous_transform.pos,
            projectile.age,
            projectile._cache.update_time
        )
        local heading = projectile._initial.attack.heading
        local pitch = projectile._initial.attack.pitch
        ProjectileUtil.drawSprite(props.sprite, per_tick_position, heading, pitch)
    end,
}

ProjectileBehaviour.HasSounds = function()
    local WHISTLE_VOLUME = 100
    local WHISTLE_MIN_VELOCITY = 100
    local WHISTLE_MAX_DISTANCE_TO_GROUND = 500

    local function getValue(projectile, event_name)
        return projectile._cache.sounds[event_name]
    end

    local function setValue(projectile, event_name, value)
        projectile._cache.sounds[event_name] = value
    end

    ---@type ProjectileBehaviourFuncs
    return {
        onInit = function(projectile, props)
            projectile._cache.sounds = {}

            local elected_whistle = props.sounds.whistle
            if elected_whistle ~= nil then
                if type(elected_whistle) == "table" then
                    elected_whistle = elected_whistle[math.random(1, #elected_whistle)]
                end

                setValue(projectile, "elected_whistle", elected_whistle)
                DebugPrint(string.format("Elected whistle sound %d", elected_whistle))
            end
        end,
        onTick = function(projectile, props)
            if projectile.state ~= SHELL_STATE.ACTIVE then
                return
            end

            if not getValue(projectile, "fire") and FdAssertTableKeys(props, "sounds", "fire") then
                FdPlayDistantSound(props.sounds.fire, {
                    heading = projectile._initial.attack.heading,
                    use_random_pitch = true,
                })

                setValue(projectile, "fire", true)
            end

            local elected_whistle = getValue(projectile, "elected_whistle")
            if elected_whistle and VecLength(projectile.velocity) > WHISTLE_MIN_VELOCITY then
                local distance_ground = VecLength(VecSub(projectile.transform.pos, projectile.destination))

                if distance_ground < WHISTLE_MAX_DISTANCE_TO_GROUND then
                    DebugWatch("whistle", "playing")
                    PlayLoop(elected_whistle, projectile.transform.pos, WHISTLE_VOLUME)
                else
                    DebugWatch("whistle", "waiting")
                end
            end
        end,
    }
end

ProjectileBehaviour.IsQueueable = function()
    local function getValue(projectile, event_name)
        return projectile._cache.queue[event_name]
    end

    local function setValue(projectile, event_name, value)
        projectile._cache.queue[event_name] = value
    end

    ---@type ProjectileBehaviourFuncs
    return {
        onInit = function(projectile)
            projectile._cache.queue = {}
            setValue(projectile, "wait", true)
            setValue(projectile, "delay", projectile._initial.delay)
        end,
        beforeTick = function(projectile, _, dt)
            if projectile.state ~= SHELL_STATE.QUEUED then
                return
            end

            if InputPressed(CfgGetValue("KEYBIND_GENERAL_CANCEL")) and STATES.quicksalvo.enabled then
                projectile.state = SHELL_STATE.NONE
                return true
            end

            local wait = getValue(projectile, "wait")
            if STATES.quicksalvo.enabled and wait then
                return
            end

            setValue(projectile, "wait", false)
            setValue(projectile, "delay", getValue(projectile, "delay") - dt)
            if getValue(projectile, "delay") <= 0 then
                projectile.state = SHELL_STATE.ACTIVE
                return
            end

            return true
        end,
        onTick = function(projectile)
            if projectile.state ~= SHELL_STATE.QUEUED then
                return
            end

            local destination = projectile._initial.requested_destination
            local heading = projectile._initial.attack.heading
            local pitch = projectile._initial.attack.pitch
            local deviation = projectile._initial.deviation

            ProjectileUtil.drawSalvoMarker(destination, {
                display = STATES.quicksalvo.markers,
                deviation = deviation,
                heading = heading,
                pitch = pitch,
            })
        end,
        onDraw = function(projectile, props)
            if STATES.tactical.enabled and projectile.state == SHELL_STATE.QUEUED then
                ProjectileUtil.drawSalvoInfo(
                    props,
                    projectile._initial.requested_destination,
                    getValue(projectile, "delay"),
                    {
                        display = STATES.quicksalvo.markers,
                        wait = getValue(projectile, "wait"),
                    }
                )
            end
        end,
    }
end

---@type ProjectileBehaviour[]
PROJECTILE_DEFAULT_BEHAVIOURS = {
    ProjectileBehaviour.HasPhysics,
    ProjectileBehaviour.HasBallistics,
    ProjectileBehaviour.IsQueueable,
    ProjectileBehaviour.HasImpactFuze,
    ProjectileBehaviour.HasSprite,
    ProjectileBehaviour.HasSounds,
}
