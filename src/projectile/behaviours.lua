---@type { [string]: ProjectileBehaviour }
ProjectileBehaviour = {}

ProjectileBehaviour.HasPhysics = {
    id = "HasPhysics",

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
    onUpdate = function(projectile, _, _, dt)
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
}

ProjectileBehaviour.Expires = {
    id = "Expires",

    afterUpdate = function(projectile, props)
        if projectile.state ~= SHELL_STATE.ACTIVE then
            return
        end

        if projectile.age > (props.max_age or PROJECTILE_MAX_AGE) then
            DebugPrint("Projectile expired due to age")
            projectile.state = SHELL_STATE.NONE
        end
    end,
}

ProjectileBehaviour.HasBallistics = {
    id = "HasBallistics",

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
    id = "HasImpactFuze",
    requires = { "HasPhysics" },

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
    id = "HasSprite",
    requires = { "HasPhysics" },

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

    ---@type ProjectileBehaviourDefinition
    return {
        id = "HasSounds",
        requires = { "HasPhysics" },

        onInit = function(projectile, props, helpers)
            helpers.initBehaviourCache(projectile)

            local elected_whistle = props.sounds.whistle
            if elected_whistle ~= nil then
                if type(elected_whistle) == "table" then
                    elected_whistle = elected_whistle[math.random(1, #elected_whistle)]
                end

                helpers.setValue(projectile, elected_whistle, "elected_whistle")
                DebugPrint(string.format("Elected whistle sound %d", elected_whistle))
            end
        end,
        onTick = function(projectile, props, helpers)
            if projectile.state ~= SHELL_STATE.ACTIVE then
                return
            end

            if not helpers.getValue(projectile, "fire") and FdAssertTableKeys(props, "sounds", "fire") then
                FdPlayDistantSound(props.sounds.fire, {
                    heading = projectile._initial.attack.heading,
                    use_random_pitch = true,
                })

                helpers.setValue(projectile, true, "fire")
            end

            local elected_whistle = helpers.getValue(projectile, "elected_whistle")
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

ProjectileBehaviour.IsQueueable = {
    id = "IsQueueable",

    onInit = function(projectile, _, helpers)
        helpers.initBehaviourCache(projectile)

        helpers.setValue(projectile, true, "wait")
        helpers.setValue(projectile, projectile._initial.delay, "delay")
    end,
    beforeTick = function(projectile, _, helpers, dt)
        if projectile.state ~= SHELL_STATE.QUEUED then
            return
        end

        if InputPressed(CfgGetValue("KEYBIND_GENERAL_CANCEL")) and STATES.quicksalvo.enabled then
            projectile.state = SHELL_STATE.NONE
            return true
        end

        local wait = helpers.getValue(projectile, "wait")
        if STATES.quicksalvo.enabled and wait then
            return
        end

        local delay = helpers.getValue(projectile, "delay")
        helpers.setValue(projectile, false, "wait")
        helpers.setValue(projectile, delay - dt, "delay")
        if helpers.getValue(projectile, "delay") <= 0 then
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
    onDraw = function(projectile, props, helpers)
        local delay = helpers.getValue(projectile, "delay")

        if STATES.tactical.enabled and projectile.state == SHELL_STATE.QUEUED then
            ProjectileUtil.drawSalvoInfo(props, projectile._initial.requested_destination, delay, {
                display = STATES.quicksalvo.markers,
                wait = delay,
            })
        end
    end,
}

ProjectileBehaviour.HasTerminalBallistics = function()
    local MAX_KINETIC_ENERGY = 5000
    local MAX_RAYCAST_DEPTH = 6

    --- Pull penetration values for material, default if not found
    ---@param props ProjectileProps
    ---@param material Material
    ---@return ProjectilePenetration
    local function getPenetrationValues(props, material)
        local values = props.penetration[material]
        if values == nil then
            FdLog("Material not found in penetration table. Defaulting...")
            values = props.penetration["default"] or PROJECTILE_PENETRATION_DEFAULT_MATERIAL
        end

        return values
    end

    ---@param projectile Projectile
    ---@param props ProjectileProps
    ---@param pos TVec
    local function detonate(projectile, props, pos)
        ProjectileUtil.detonate(pos, props.explosive_yield, props.hole_sizes)
        projectile.state = SHELL_STATE.DETONATED
    end

    ---@type ProjectileBehaviourDefinition
    return {
        id = "HasTerminalBallistics",
        requires = { "HasPhysics", "HasBallistics" },

        onInit = function(projectile, _, helpers)
            helpers.initBehaviourCache(projectile)
        end,
        onUpdate = function(projectile, props, helpers)
            if projectile.state ~= SHELL_STATE.ACTIVE then
                return
            end

            local pos = projectile._cache.previous_transform.pos
            local pos_new = projectile.transform.pos
            local pos_delta = VecSub(pos_new, pos)
            local distance = VecLength(pos_delta)
            if distance <= 0 then
                return
            end

            local direction = VecNormalize(pos_delta)

            -- Hit detection and ballistics system
            QueryRequire("large")
            QueryRequire("physical")
            local hit, hit_distance, _, shape_initial = QueryRaycast(pos, direction, distance)

            if not hit then
                return
            end

            local hit_pos = VecAdd(pos, VecScale(direction, hit_distance))
            local radius = props.sprite.width / 2

            FdAddToDebugTable(DEBUG_POSITIONS, { hit_pos, COLOUR["white"] })

            if not CfgGetValue("G_SIMULATE_BALLISTICS") then
                detonate(projectile, props, hit_pos)
                return
            end

            local kinetic_energy = helpers.getValue(projectile, "kinetic_energy")
            if kinetic_energy == nil then
                kinetic_energy = FdClamp(
                    (props.weight * math.pow(math.abs(VecLength(projectile.velocity)), 2)) / 1000,
                    0,
                    MAX_KINETIC_ENERGY
                )
                helpers.setValue(projectile, kinetic_energy, "kinetic_energy")
            end

            local trigger_detonation = false
            local material_initial = GetShapeMaterialAtPosition(shape_initial, hit_pos)
            FdLog("Initial material is '" .. material_initial .. "'")

            -- Perform recursive check for materials encountered during this tick
            local hit_materials, hit_positions, reached_max_depth = FdGetMaterialsInRaycastRecursive(
                pos,
                pos_new,
                { hit_pos },
                radius,
                { material_initial },
                { shape_initial },
                MAX_RAYCAST_DEPTH
            )

            local position_detonation
            if hit_positions ~= nil then
                position_detonation = hit_positions[#hit_positions]
            else
                position_detonation = hit_pos
                trigger_detonation = true
            end

            if reached_max_depth or trigger_detonation then
                detonate(projectile, props, position_detonation)
                return
            end

            -- Iterate over all materials found in recursive QueryRaycast and determine outcome based on penetration values
            for index, material in pairs(hit_materials) do
                if trigger_detonation then
                    break
                end

                FdLog("Material at index " .. index .. " is '" .. material .. "'")

                local pen_values = getPenetrationValues(props, material)

                if kinetic_energy < pen_values.minimum_energy then
                    FdLog("Material '" .. material .. "' triggered detonation. (energy below threshold)")
                    detonate(projectile, props, hit_positions[index])
                    return
                end

                if math.random() < pen_values.chance_to_terminate then
                    FdLog("Material '" .. material .. "' triggered detonation. (Unlucky roll)")
                    detonate(projectile, props, hit_positions[index])
                    return
                end

                FdLog("Material '" .. material .. "' was too weak to trigger detonation.")
                helpers.setValue(
                    projectile,
                    kinetic_energy * (1 - FdClamp(pen_values.absorb_percentage, 0, 1)),
                    "kinetic_energy"
                )
                MakeHole(hit_positions[index], radius + 1, radius + 0.5, radius, false)
            end

            -- QueryRaycast in the opposite direction to check if bottom material is impenetrable. Fixes fringe QueryRejectShape edge case.
            local direction_reverse = VecScale(direction, -1)
            hit, hit_distance, _, shape_initial = QueryRaycast(pos_new, direction_reverse, distance, 0)

            if not hit then
                return
            end

            local position_initial_hit = VecAdd(pos_new, VecScale(direction_reverse, hit_distance))
            local bottom_material = GetShapeMaterialAtPosition(shape_initial, position_initial_hit)
            FdLog("Bottom material detected as '" .. bottom_material .. "'")

            if bottom_material ~= "rock" and bottom_material ~= "none" then
                return
            end

            if #hit_positions == 1 then
                detonate(projectile, props, hit_positions[1])
                return
            end

            FdLog("Bottom material is impenetrable")
            detonate(projectile, props, position_initial_hit)
        end,
    }
end

ProjectileBehaviour.DeploysSubmunitions = function(props)
    local id = "DeploysSubmunitions"

    local manifest = props.submunitions
    if manifest == nil then
        error(string.format("%s requires a submunition manifest", id))
    end

    ---@type ProjectileBehaviourDefinition
    return {
        id = id,
        requires = { "HasPhysics", "HasBallistics" },

        onInit = function(projectile, _, helpers)
            helpers.initBehaviourCache(projectile)
            helpers.setValue(projectile, false, "deployed")
        end,
        onUpdate = function(projectile, projectile_props, helpers)
            if projectile.state ~= SHELL_STATE.ACTIVE or helpers.getValue(projectile, "deployed") then
                return
            end

            local distance_to_destination = VecLength(VecSub(projectile.transform.pos, projectile.destination))
            if distance_to_destination > manifest.trigger_height then
                return
            end

            helpers.setValue(projectile, true, "deployed")

            if manifest.trigger_sound ~= nil then
                PlaySound(manifest.trigger_sound, projectile.transform.pos, manifest.trigger_sound_volume or 90)
            end

            ParticleReset()
            ParticleRadius(manifest.particle_radius or 2)
            ParticleAlpha(1.0, 0.0, "smooth", 0.05, 0.9)
            ParticleStretch(0)

            local particle_origin = VecCopy(projectile.transform.pos)
            if projectile_props.sprite ~= nil then
                particle_origin = VecAdd(
                    particle_origin,
                    Vec(0, projectile_props.sprite.width * projectile_props.sprite.aspect_ratio, 0)
                )
            end
            SpawnParticle(particle_origin, G_VEC_WIND, 20)

            local count = manifest.count
            if manifest.count_config_key ~= nil then
                count = CfgGetValue(manifest.count_config_key) or count
            end

            for _ = 1, count do
                local yaw = math.random() * 360
                local pitch = FdMapToRange(math.random(), 0, 1, manifest.spread_pitch_min, manifest.spread_pitch_max)
                local rotation = QuatEuler(0, yaw, pitch)
                local transform = Transform(VecCopy(projectile.transform.pos), rotation)
                local spread_speed =
                    FdMapToRange(math.random(), 0, 1, manifest.spread_velocity_min, manifest.spread_velocity_max)
                local spread_velocity = TransformToParentVec(transform, Vec(spread_speed, 0, 0))
                local velocity = VecAdd(VecCopy(projectile.velocity), spread_velocity)

                Projectiles.spawn(manifest.projectile_type, {
                    transform = transform,
                    velocity = velocity,
                })
            end

            projectile.state = SHELL_STATE.DETONATED
        end,
    }
end

---@type ProjectileBehaviour[]
PROJECTILE_DEFAULT_BEHAVIOURS = {
    ProjectileBehaviour.Expires,
    ProjectileBehaviour.HasPhysics,
    ProjectileBehaviour.HasBallistics,
    ProjectileBehaviour.IsQueueable,
    ProjectileBehaviour.HasTerminalBallistics,
    ProjectileBehaviour.HasSprite,
    ProjectileBehaviour.HasSounds,
}
