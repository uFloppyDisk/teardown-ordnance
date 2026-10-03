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
            projectile.transform.pos = VecCopy(pos)
            projectile.state = SHELL_STATE.DETONATED
        end
    end,
}

ProjectileBehaviour.HasFragmentation = function()
    local PHYSICAL_FRAG_SPAWN_CHANCE = CfgGetValue("PHYSICAL_FRAGMENTATION_SPAWN_CHANCE")
    local PHYSICAL_FRAG_TTL = 40
    local PHYSICAL_FRAG_ORIGIN_LERP = 0.5
    local PHYSICAL_FRAG_BBR_LUMINOSITY_BASE = 0.25
    local PHYSICAL_FRAG_VELOCITY_BASE = 100
    local PHYSICAL_FRAG_VELOCITY_VARI = 150

    ---@param shapes number[]
    ---@param colour TColour|nil
    local function setLightColourInShapes(shapes, colour)
        colour = colour or { 0, 0, 0, 0 }
        for _, shape in ipairs(shapes) do
            SetShapeEmissiveScale(shape, colour[4])
            for _, light in ipairs(GetShapeLights(shape)) do
                SetLightColor(light, FdGetUnpackedRGBA(colour))
            end
        end
    end

    ---@param shapes number[]
    ---@param kelvin number
    ---@param luminosity? number
    ---@return boolean
    local function setShapesBlackbodyRadiation(shapes, kelvin, luminosity)
        local bbr = BLACKBODY[kelvin]
        if not bbr then
            setLightColourInShapes(shapes, nil)
            return false
        end

        setLightColourInShapes(shapes, FdGetRGBA(bbr, luminosity or 1))
        return true
    end

    ---@param source_pos TVec
    ---@param source_dist number
    ---@param check_dist number
    ---@param shape number
    ---@return TVec
    local function solveFragOrigin(source_pos, source_dist, check_dist, shape)
        source_pos = VecCopy(source_pos)
        QueryRequire("large")
        local _, distance = QueryRaycast(VecAdd(VecCopy(source_pos), Vec(0, check_dist, 0)), Vec(0, -1, 0), check_dist)

        local dist_diff = FdRound(distance, 4) - source_dist
        FdLog("Diff 1/2: " .. source_dist .. " / " .. distance)
        FdLog("Diff: " .. dist_diff)

        if dist_diff ~= 0 then
            FdLog("Using differential calculation")
            return VecAdd(source_pos, Vec(0, source_dist + (check_dist - (dist_diff * 0.95)), 0))
        end

        FdLog("Using shape bounds calculation")
        local bounds_min, bounds_max = GetShapeBounds(shape)
        local bounds_size = VecSub(bounds_max, bounds_min)
        return VecAdd(source_pos, Vec(0, math.abs(bounds_size[2]), 0))
    end

    local function createFragment(projectile, pos, frag_size, frag_dist, rotation, halt)
        local function checkHit(candidate_rotation)
            local transform = Transform(pos, candidate_rotation)
            local position_new = TransformToParentPoint(transform, Vec((frag_dist - 5) + (math.random() * 10), 0, 0))
            local transform_new = Transform(position_new, transform.rot)
            local delta = VecSub(position_new, pos)
            local hit, hit_distance = QueryRaycast(pos, VecNormalize(delta), VecLength(delta))
            if not hit then
                return false, transform_new
            end

            local new_rotation = QuatRotateQuat(QuatCopy(candidate_rotation), QuatEuler(0, 0, 180))
            local hit_pos = VecAdd(pos, VecScale(VecNormalize(delta), hit_distance))

            if hit_distance < 1 and not halt then
                if CfgGetValue("G_FRAGMENTATION_DEBUG") then
                    FdAddToDebugTable(DEBUG_POSITIONS, { hit_pos, FdGetRGBA(COLOUR["red"], 0.2) })
                    FRAG_STATS[4] = FRAG_STATS[4] + 1
                end
                return createFragment(projectile, VecCopy(pos), frag_size, frag_dist, new_rotation, true)
            end

            if math.random() < 0.66 then
                ParticleReset()
                SpawnParticle(hit_pos, Vec(-0.15, 0, 0.05), 3 - (2.5 * math.random()))
            end

            local rand_frag_size = frag_size * (1.0 - (math.random() * 0.50))
            MakeHole(hit_pos, rand_frag_size * 3, rand_frag_size * 2, rand_frag_size)

            if CfgGetValue("G_FRAGMENTATION_DEBUG") then
                local point_colour = halt and COLOUR["yellow"] or COLOUR["white"]
                FdAddToDebugTable(DEBUG_POSITIONS, { hit_pos, point_colour })
                FdAddToDebugTable(DEBUG_LINES, { pos, hit_pos, FdGetRGBA(COLOUR["white"], 0.5) })
                FRAG_STATS[2] = FRAG_STATS[2] + 1
            end
            return true, transform_new
        end

        FRAG_STATS[1] = FRAG_STATS[1] + 1
        rotation = rotation or QuatEuler(0, 360 * math.random(), (179 * math.random()) - 89.5)
        local hit_final, line_end = checkHit(rotation)
        if hit_final then
            return true, line_end
        end

        if CfgGetValue("G_SPAWN_PHYSICAL_FRAGMENTATION") and math.random() < PHYSICAL_FRAG_SPAWN_CHANCE then
            local frag_variant = math.ceil(math.random() * 3)
            ---@type ManagedBodyWithTtl
            local frag = {
                valid = true,
                created_at = ELAPSED_TIME,
                type = "frag",
                handle = Spawn(
                    "MOD/assets/vox/frag" .. frag_variant .. ".xml",
                    Transform(VecLerp(projectile.transform.pos, line_end.pos, PHYSICAL_FRAG_ORIGIN_LERP), line_end.rot)
                )[1],
                shouldHandle = true,
                ttl = PHYSICAL_FRAG_TTL,
                kelvin = math.random(10, 27) * 100,
            }
            table.insert(BODIES, frag)

            SetBodyVelocity(
                frag.handle,
                VecScale(
                    VecNormalize(TransformToParentVec(line_end, Vec(1, 0, 0))),
                    math.random() * PHYSICAL_FRAG_VELOCITY_VARI + PHYSICAL_FRAG_VELOCITY_BASE
                )
            )
            SetBodyAngularVelocity(frag.handle, Vec(math.random() * 30, math.random() * 30, 0))

            local is_emissive =
                setShapesBlackbodyRadiation(GetBodyShapes(frag.handle), frag.kelvin, PHYSICAL_FRAG_BBR_LUMINOSITY_BASE)
            if not is_emissive then
                frag.kelvin = nil
            end
        end

        if CfgGetValue("G_FRAGMENTATION_DEBUG") then
            FdAddToDebugTable(DEBUG_LINES, { pos, line_end.pos, FdGetRGBA(COLOUR["red"], 0.1) })
            FRAG_STATS[3] = FRAG_STATS[3] + 1
        end
        return false, line_end
    end

    return {
        id = "HasFragmentation",
        requires = { "HasPhysics" },

        onInit = function(projectile, _, helpers)
            helpers.initBehaviourCache(projectile)
            helpers.setCacheValue(projectile, "is_fragmented", false)
        end,
        afterUpdate = function(projectile, props, helpers)
            local is_fragmented = helpers.getCache(projectile, "is_fragmented")
            if projectile.state ~= SHELL_STATE.DETONATED or is_fragmented.value then
                return
            end
            is_fragmented.value = true

            if (props.explosive_yield or 0) < 0.5 or not CfgGetValue("G_SIMULATE_FRAGMENTATION") then
                return
            end

            local frag_amount = CfgGetValue("SHELL_FRAGMENTATION_AMOUNT") or 250
            local frag_size = (CfgGetValue("SHELL_FRAGMENTATION_SIZE") or 20) / 100
            local frag_distance = props.hole_sizes.soft / 2
            local pos = projectile.transform.pos

            if CfgGetValue("G_FRAGMENTATION_DEBUG") then
                FdWatch("Frag Size", frag_size)
                FdWatch("Frag Dist", frag_distance)
            end

            local check_dist = 0.5
            QueryRequire("large")
            local hit, distance, _, shape = QueryRaycast(pos, Vec(0, 1, 0), check_dist)
            local frag_origin = hit and solveFragOrigin(pos, distance, check_dist, shape) or pos

            for _ = 1, frag_amount do
                createFragment(projectile, frag_origin, frag_size, frag_distance)
            end

            if CfgGetValue("G_FRAGMENTATION_DEBUG") then
                FdLog("--- FRAGMENTATION STATS ---")
                FdLog(FRAG_STATS[2] .. " - hit")
                FdLog(FRAG_STATS[3] .. " - missed")
                FdLog(FRAG_STATS[4] .. " - redirected")
                FdLog("-------------")
                FdLog(
                    "TOTAL: "
                        .. FRAG_STATS[1]
                        .. " - "
                        .. FRAG_STATS[4]
                        .. " redirected = "
                        .. (FRAG_STATS[1] - FRAG_STATS[4])
                        .. ")"
                )
            end
        end,
    }
end

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

                helpers.setCacheValue(projectile, "elected_whistle", elected_whistle)
                DebugPrint(string.format("Elected whistle sound %d", elected_whistle))
            end
        end,
        onTick = function(projectile, props, helpers)
            if projectile.state ~= SHELL_STATE.ACTIVE then
                return
            end

            local cache_fire = helpers.getCache(projectile, "fire")
            if not cache_fire.value and FdAssertTableKeys(props, "sounds", "fire") then
                FdPlayDistantSound(props.sounds.fire, {
                    heading = projectile._initial.attack.heading,
                    use_random_pitch = true,
                })

                cache_fire.value = true
            end

            local elected_whistle = helpers.getCacheValue(projectile, "elected_whistle")
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

        helpers.setCacheValue(projectile, "wait", true)
        helpers.setCacheValue(projectile, "delay", projectile._initial.delay)
    end,
    beforeTick = function(projectile, _, helpers, dt)
        if projectile.state ~= SHELL_STATE.QUEUED then
            return
        end

        if InputPressed(CfgGetValue("KEYBIND_GENERAL_CANCEL")) and STATES.quicksalvo.enabled then
            projectile.state = SHELL_STATE.NONE
            return true
        end

        local cache_wait = helpers.getCache(projectile, "wait")
        if STATES.quicksalvo.enabled and cache_wait.value then
            return
        end

        local cache_delay = helpers.getCache(projectile, "delay")
        cache_wait.value = false
        cache_delay.value = cache_delay.value - dt
        if cache_delay.value <= 0 then
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
        local delay = helpers.getCacheValue(projectile, "delay")

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
        projectile.transform.pos = VecCopy(pos)
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

            local cache_kinetic_energy = helpers.getCache(projectile, "kinetic_energy")
            if cache_kinetic_energy.value == nil then
                cache_kinetic_energy.value = FdClamp(
                    (props.weight * math.pow(math.abs(VecLength(projectile.velocity)), 2)) / 1000,
                    0,
                    MAX_KINETIC_ENERGY
                )
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

                if cache_kinetic_energy.value < pen_values.minimum_energy then
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
                cache_kinetic_energy.value = cache_kinetic_energy.value
                    * (1 - FdClamp(pen_values.absorb_percentage, 0, 1))
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
            helpers.setCacheValue(projectile, "deployed", false)
        end,
        onUpdate = function(projectile, projectile_props, helpers)
            local cache_deployed = helpers.getCache(projectile, "deployed")
            if projectile.state ~= SHELL_STATE.ACTIVE or cache_deployed.value then
                return
            end

            local distance_to_destination = VecLength(VecSub(projectile.transform.pos, projectile.destination))
            if distance_to_destination > manifest.trigger_height then
                return
            end

            cache_deployed.value = true

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
    ProjectileBehaviour.HasFragmentation,
    ProjectileBehaviour.HasSprite,
    ProjectileBehaviour.HasSounds,
}
