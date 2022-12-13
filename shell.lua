local function draw_sprite(self, pos)
    local rotation = QuatEuler(0, self.heading, 90 + self.pitch)

    local look_at = QuatLookAt(self.position, GetCameraTransform().pos)
    local lx, ly, lz = GetQuatEuler(look_at)
    -- lx = clamp(lx, -15, 15)
    -- lz = clamp(lz, -15, 15)
    look_at = QuatEuler(0, -ly, 0)

    rotation = QuatRotateQuat(rotation, look_at)

    local transform_pos = Transform(pos, rotation)
    local transform_pos_90 = Transform(pos, QuatRotateQuat(rotation, QuatAxisAngle(Vec(0, 1, 0), 90)))

    DrawSprite(self.sprite.img, transform_pos_90, self.sprite.width, (self.sprite.width * self.sprite.scaling_factor), 0.4, 0.4, 0.4, 1, true, false) -- Second
    DrawSprite(self.sprite.img, transform_pos, self.sprite.width, (self.sprite.width * self.sprite.scaling_factor), 0.4, 0.4, 0.4, 1, true, false)
end

local function trigger_secondary(self, parameters, detonate)
    local isDetonated = true

    if assertTableKeys(parameters, "trigger_height") then
        if not detonate then isDetonated = false end

        if parameters.trigger_height < self.distance_ground then
            return isDetonated
        end

        self.secondary.active = true
        self.secondary.inertia = self.vel_current

        self.vel_current = Vec(-0.1, -1, 0.02)

        if assertTableKeys(parameters, "trigger_sound") then
            local volume = 90
            if assertTableKeys(parameters, "trigger_sound_volume") then
                volume = parameters.trigger_sound_volume
            end

            PlaySound(parameters.trigger_sound, self.position, volume)
        end

        ParticleReset()

        if assertTableKeys(parameters, "particle_radius") then
            ParticleRadius(parameters.particle_radius)
        else
            ParticleRadius(2)
        end

        ParticleAlpha(1.0, 0.0, "smooth", 0.05, 0.9)
        ParticleStretch(0)

        local particle_origin = VecAdd(self.position, Vec(0, self.sprite.width * self.sprite.scaling_factor, 0))

        SpawnParticle(particle_origin, Vec(-0.1, 0, 0.02), 20)
    end

    if assertTableKeys(parameters, "trigger_detonate") then
        isDetonated = false

        if detonate then
            self.secondary.active = true
            self.vel_current = Vec(0, 0, 0)
        end
    end

    return isDetonated
end

local function tick_frag(self, index, pos, frag_size, frag_dist, rot, halt)
    FRAG_STATS[1] = FRAG_STATS[1] + 1
    local rotation
    if rot then
        rotation = QuatCopy(rot)
    else
        local rot_y = 360 * math.random()
        local rot_z = (179 * math.random()) - 89.5
        rotation = QuatEuler(0, rot_y, rot_z)
    end

    local transform = Transform(pos, rotation)

    local position_new = TransformToParentPoint(transform, Vec(((frag_dist - 5) + (math.random() * 10)), 0, 0))
    local transform_new = Transform(position_new, transform.rot)

    local hit, hit_distance = QueryRaycast(pos, VecNormalize(VecSub(position_new, pos)), VecLength(VecSub(position_new, pos)))

    local function check_hit()
        if not hit then return false end

        local hit_pos = VecAdd(pos, VecScale(VecNormalize(VecSub(position_new, pos)), hit_distance))

        if hit_distance >= 1 or halt then
            if math.random() < 0.66 then
                ParticleReset()
                SpawnParticle(hit_pos, Vec(-0.15, 0, 0.05), (3 - (2.5 * math.random())))
            end

            local rand_frag_size = frag_size * (1.0 - (math.random() * 0.50))
            MakeHole(hit_pos, rand_frag_size * 3, rand_frag_size * 2, rand_frag_size)

            if not CONFIG_getConfValue("G_FRAGMENTATION_DEBUG") then return true end

            local point_colour = COLOUR["white"]
            if halt then
                point_colour = COLOUR["yellow"]
            end

            addToDebugTable(DEBUG_POSITIONS, {hit_pos, point_colour})
            addToDebugTable(DEBUG_LINES, {pos, hit_pos, getRGBA(COLOUR["white"], 0.5)})
            FRAG_STATS[2] = FRAG_STATS[2] + 1

            return true
        end

        local new_rotation = QuatRotateQuat(QuatCopy(rotation), QuatEuler(0, 0, 180))
        -- dPrint("Frag #"..index.." hit too close ("..hit_distance..") in: "..table.concat(rotation, ",").." | out: "..table.concat(new_rotation, ","))
        if CONFIG_getConfValue("G_FRAGMENTATION_DEBUG") then
            addToDebugTable(DEBUG_POSITIONS, {hit_pos, getRGBA(COLOUR["red"], 0.2)})
            FRAG_STATS[4] = FRAG_STATS[4] + 1
        end

        tick_frag(self, index, VecCopy(pos), frag_size, frag_dist, new_rotation, true)
    end

    if check_hit() then return end

    if CONFIG_getConfValue("G_FRAGMENTATION_DEBUG") then
        addToDebugTable(DEBUG_LINES, {pos, transform_new.pos, getRGBA(COLOUR["red"], 0.1)})
        FRAG_STATS[3] = FRAG_STATS[3] + 1
    end
end

local function detonate(self, pos)
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    self.position = VecCopy(pos)

    if not (assertTableKeys(variant, "secondary")) or trigger_secondary(self, variant.secondary, true) then
        self.state = shell_states.DETONATED
    end

    addToDebugTable(DEBUG_POSITIONS, {pos, COLOUR["red"]})

    if CONFIG_getConfValue("G_SIMULATE_UXO") and math.random(100) <= 2 then
        MakeHole(pos, 5, 2, 1, false)
        return
    end

    local hole = variant.size_makehole
    MakeHole(pos, hole[1], hole[2], hole[3], false)

    if variant.size_explosion > 0 then
        Explosion(pos, variant.size_explosion)

        if variant.size_explosion < 0.5 then
            return
        end

        if not CONFIG_getConfValue("G_SIMULATE_FRAGMENTATION") then
            return
        end

        local FRAG_AMOUNT = CONFIG_getConfValue("SHELL_FRAGMENTATION_AMOUNT") or 250
        local FRAG_SIZE = (CONFIG_getConfValue("SHELL_FRAGMENTATION_SIZE") or 20) / 100
        local FRAG_DISTANCE = variant.size_makehole[1] / 2

        if CONFIG_getConfValue("G_FRAGMENTATION_DEBUG") then
            dWatch("Frag Size", FRAG_SIZE)
            dWatch("Frag Dist", FRAG_DISTANCE)
        end

        local frag_pos = pos

        local check_dist = 0.5
        QueryRequire('large')
        local hit, dist1, _, shape1 = QueryRaycast(frag_pos, Vec(0, 1, 0), check_dist)
        if hit then
            local dist2
            QueryRequire('large')
            hit, dist2 = QueryRaycast(VecAdd(VecCopy(frag_pos), Vec(0, check_dist, 0)), Vec(0, -1, 0), check_dist)

            local dist_diff = round(dist2, 4) - dist1
            dPrint("Diff 1/2: "..dist1.." / "..dist2)
            dPrint("Diff: "..dist_diff)
            if dist_diff ~= 0 then
                dPrint("Using differential calculation")
                frag_pos = VecAdd(pos, Vec(0, dist1 + (check_dist - (dist_diff * 0.95)), 0))
            else
                dPrint("Using shape bounds calculation")
                local bounds_min, bounds_max = GetShapeBounds(shape1)
                local bounds_size = VecSub(bounds_max, bounds_min)

                frag_pos = VecAdd(pos, Vec(0, math.abs(bounds_size[2]), 0))
            end
        end

        for i = 1, FRAG_AMOUNT, 1 do
            tick_frag(self, i, frag_pos, FRAG_SIZE, FRAG_DISTANCE)
        end

        if CONFIG_getConfValue("G_FRAGMENTATION_DEBUG") then
            dPrint("--- FRAGMENTATION STATS ---")
            dPrint(FRAG_STATS[2].." - hit")
            dPrint(FRAG_STATS[3].." - missed")
            dPrint(FRAG_STATS[4].." - redirected")
            dPrint("-------------")
            dPrint("TOTAL: "..FRAG_STATS[1].." - "..FRAG_STATS[4].." redirected = "..(FRAG_STATS[1] - FRAG_STATS[4])..")")
        end
    end
end

local function tick_secondary(self, delta, variant)
    if self.secondary.timer < 0 then
        self.state = shell_states.DETONATED
        self.secondary.active = false
        return
    end

    local timer_ratio = self.secondary.timer / variant.secondary.timer

    local function tick_secondary_smoke()
        local radius = variant.secondary.radius
        -- local radius_master = clamp(radius - (radius * (1 - timer_ratio)), radius - (radius / 3), radius)

        local radius_master = radius
        if timer_ratio < 0.3 then
            radius_master = radius_master - (radius_master * (1 - (timer_ratio / 0.3)))
        end

        -- Smoke plume
        if (timer_ratio > 0.2 and timer_ratio < 0.99) and math.random() > 0.8 then
            ParticleReset()
            ParticleType('plain')
            ParticleAlpha(1, 0, "smooth", 0, 0.95)
            ParticleStretch(1)
            ParticleCollide(0, 1, "easein", 0.1, 1)

            local segments = 8;
            for i = 0, 360, (360 / segments) do
                if math.random() > 0.9 then
                    break
                end

                local particle_radius1 = math.random() * 0.5
                local particle_radius2 = (math.random() * 0.2) + particle_radius1
                ParticleRadius(particle_radius1, particle_radius2, "easein", 0.02, 0.95)

                local rand_gravity = math.random() * 0.05
                ParticleGravity(0, rand_gravity, "linear", 0, 1)

                local rotation = QuatEuler(0, (i + (math.random() * (360 / segments))), 0)
                local transform = Transform(self.position, rotation)

                local vel_rand = math.random() * 0.2
                local vel = Vec(vel_rand, 0, 0)
                vel = TransformToParentVec(transform, vel)

                local position_spawn = TransformToParentPoint(transform, Vec(radius_master * clamp(1 + math.random(), 1, 1.3), 0, 0))

                SpawnParticle(position_spawn, vel, variant.secondary.timer)
            end
        end

        -- Smoke Body
        if timer_ratio == 1 or math.random() > 0.8 then
            local rotation = QuatEuler(0, 360 * math.random(), 0)
            local distance = Vec((radius_master * 0.8) * math.random(), 0, 0)
            local transform = Transform(VecCopy(self.position), rotation)
            local position_spawn = TransformToParentPoint(transform, distance)

            ParticleReset()
            ParticleType('plain')
            ParticleRadius(radius_master * clamp(math.random(), 0.3, 0.7))
            ParticleAlpha(1, 0, "smooth", 0, 0.8)
            ParticleGravity(0.01)
            -- ParticleStretch(1)
            -- ParticleCollide(0, 1, "easein", 0.1, 1)
            ParticleCollide(0)

            SpawnParticle(position_spawn, Vec(0, 0.02, 0), variant.secondary.timer - (variant.secondary.timer / 4))

            -- High Smoke
            if math.random() > 0.5 then
                rotation = QuatEuler(0, 360 * math.random(), 0)
                distance = Vec((radius_master * 0.2) * math.random(), 0, 0)
                transform = Transform(VecCopy(self.position), rotation)
                position_spawn = TransformToParentPoint(transform, distance)

                ParticleRadius(radius_master * clamp(math.random(), 0.3, 0.5))
                ParticleCollide(0.2)
                SpawnParticle(position_spawn, Vec(0, 0.02, 0), variant.secondary.timer - (variant.secondary.timer / 4))
            end
        end

        -- Smoke Mushroom
        if timer_ratio < 1 and math.random() > 0.9 then
            -- local particle_radius = clamp(radius - (radius * timer_ratio), radius / 2, (radius - (radius / 2.4)))
            local particle_radius = radius - (math.random() * (radius * 0.25))

            ParticleReset()
            ParticleType('plain')
            -- ParticleRadius(particle_radius - (math.random() * (radius / 3)))
            ParticleRadius(particle_radius * 0.9, particle_radius, "easeout", 0.001, 0.99)
            ParticleAlpha(1, 0, "smooth", 0, 0.8)
            ParticleGravity(-0.07)
            ParticleStretch(1)
            -- ParticleCollide(0, 1, "easein", 0.1, 1)
            ParticleCollide(0)

            SpawnParticle(VecAdd(self.position, Vec(0, 0, 0)), Vec(0, radius * 0.2, 0), variant.secondary.timer * 0.5)

            -- Smoke Volume Assist
            -- ParticleRadius(radius * 0.2)
            -- SpawnParticle(VecAdd(self.position, Vec(0, 0, 0)), Vec(0, radius * 0.02, 0), variant.secondary.timer)
        end
    end

    local function tick_secondary_parachuted_flare()
        self.secondary.intensity = clamp((self.secondary.intensity + (5 * math.random(-1, 1))), 950, 1050)

        if timer_ratio <= 0.15 then
            self.secondary.intensity = self.secondary.intensity * ((timer_ratio) / 0.15)
        end

        dWatch("shell(SECONDARY_INTENSITY)", self.secondary.intensity)

        PointLight(self.position, 1, 1, 1, self.secondary.intensity)

        if math.random() <= 0.5 then return end

        -- Spawn smoke particles
        ParticleReset()
        ParticleRadius(0.3 * math.random())
        ParticleAlpha(1.0, 0.0, "smooth", 0.05, 0.5)
        ParticleStretch(0)

        local particle_origin = VecAdd(self.position, Vec(0, (self.sprite.width * self.sprite.scaling_factor), 0))
        self.secondary.particle_spread[1] = clamp(self.secondary.particle_spread[1] + (0.04 * math.random(-1, 1)), -0.5, 0.5)
        self.secondary.particle_spread[3] = clamp(self.secondary.particle_spread[3] + (0.04 * math.random(-1, 1)), -0.5, 0.5)

        SpawnParticle(VecAdd(particle_origin, self.secondary.particle_spread), Vec(-0.15, 0, 0.05), 20)
    end

    local function tick_secondary_cluster()
        local sprite = LoadSprite("MOD/img/".."bomblet"..".png")

        local sounds = {
            "155mm_shell_cluster_submunition_explode_01",
            "155mm_shell_cluster_submunition_explode_02",
        }

        local function init_submunitions()
            self.secondary.submunitions = {}

            local amount_submunitions = CONFIG_getConfValue("SHELL_SEC_CLUSTER_BOMBLET_AMOUNT") or 50
            for i = 1, amount_submunitions, 1 do
                local rotation = QuatEuler(0, math.random() * 360, math.random() * -160 + 80)
                local transform = Transform(self.position, rotation)

                local sub = objectNew({
                    transform = TransformCopy(transform),
                    velocity = Vec(math.random() * 10 + 5, 0, 0)
                }, DEFAULT_SUBMUNITION)

                local vel_to_sub = TransformToLocalVec(sub.transform, VecNormalize(self.secondary.inertia))
                vel_to_sub = VecScale(vel_to_sub, VecLength(self.secondary.inertia))
                sub.velocity = VecAdd(sub.velocity, vel_to_sub)

                table.insert(self.secondary.submunitions, sub)
            end

            dWatch("SUBMUNITIONS(amount)", #self.secondary.submunitions)
        end

        local function tick_sub(sub)
            local gravity = math.abs(G_VEC_GRAVITY[2])
            local world_down = TransformToLocalVec(sub.transform, Vec(0, -1, 0))

            sub.velocity = VecAdd(sub.velocity, VecScale(world_down, gravity * delta))

            local position_new = TransformToParentPoint(sub.transform, VecScale(sub.velocity, delta))
            local transform_new = Transform(position_new, sub.transform.rot)

            addToDebugTable(DEBUG_LINES, {sub.transform.pos, transform_new.pos, COLOUR["orange"]})

            local look_rotation = QuatRotateQuat(QuatLookAt(sub.transform.pos, GetCameraTransform().pos), QuatAxisAngle(Vec(0, 0, 1), 180))
            local draw_pos = Transform(sub.transform.pos, look_rotation)
            DrawSprite(sprite, draw_pos, 0.0635, 0.0635, 0.4, 0.4, 0.4, 1, true, false)

            local hit, hit_distance = QueryRaycast(sub.transform.pos, VecNormalize(VecSub(position_new, sub.transform.pos)), VecLength(VecSub(position_new, sub.transform.pos)))
            if hit then return transform_new end

            local position_hit = VecAdd(sub.transform.pos, VecScale(VecNormalize(VecSub(position_new, sub.transform.pos)), hit_distance))

            -- Random roll if submunition is a dud
            if CONFIG_getConfValue("G_SIMULATE_UXO") and math.random(100) <= 2 then
                dPrint("Submunition at index "..index.." is a dud.")
                MakeHole(position_hit, 0.5, 0.1, 0, false)

                return nil
            end

            Explosion(position_hit, 1)
            MakeHole(position_hit, 3, 1.3, 0.5, false)

            ParticleReset()
            ParticleRadius(1, 2.5, "smooth", 0, 0.2)
            ParticleAlpha(0.5, 0.0, "smooth", 0.05, 0.5)
            ParticleStretch(0)
            ParticleCollide(0)

            SpawnParticle(position_hit, Vec(-0.1, 0.03, 0.02), math.random() * 7 + 3)

            return nil
        end


        if self.secondary.timer < 0 then
            self.state = shell_states.DETONATED
            self.secondary.active = false
            return
        end

        if not assertTableKeys(self, "secondary", "submunitions") then
            init_submunitions()
        end

        if #self.secondary.submunitions == 0 then
            self.state = shell_states.DETONATED
            self.secondary.active = false
            return
        end

        for index, sub in ipairs(self.secondary.submunitions) do
            local transform_new = tick_sub(sub)

            sub.transform = transform_new

            if transform_new == nil then
                table.remove(self.secondary.submunitions, index)
            end
        end
    end

    local disp_tick_secondary = {
        ["SM"] = tick_secondary_smoke,
        ["PF"] = tick_secondary_parachuted_flare,
        ["CL"] = tick_secondary_cluster,
    }

    disp_tick_secondary[variant.id]()

    self.secondary.timer = self.secondary.timer - delta
end

local function tick_active(self, delta)
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    self.distance_ground = VecLength(VecSub(self.position, self.destination))
    dWatch("Distance to Target", self.distance_ground)

    -- Mark shell for deletion as the shell has gone out of bounds.
    if (self.distance_ground > 5000) then
        self.state = shell_states.DETONATED
        return
    end

    -- Check if shell has a secondary state and that the secondary has not been activated yet;
    -- if so, check various trigger conditions
    if (assertTableKeys(variant, "secondary") and not self.secondary.active) then
        trigger_secondary(self, variant.secondary)
    end

    -- Shell whistle logic
    if not variant.silent and VecLength(self.vel_current) > 100 and (self.distance_ground < 500) then
        local distance_player = VecLength(VecSub(self.position, GetPlayerPos()))
        local volume = clamp(150 - (clamp(distance_player, 0, 500) / 5), 0, 100)
        dWatch("Volume", volume)
        PlayLoop(self.snd_whistle, self.position, 100)
    end

    -- Provide default behaviours until secondary is active
    if (self.secondary.active and variant.secondary.draw) or not self.secondary.active then
        self.vel_current = VecAdd(self.vel_current, (VecScale(G_VEC_GRAVITY, delta))) -- Calculation of gravity's effect on shell velocity

        ParticleReset()
        ParticleRadius(0.2)
        ParticleStretch(1.0)

        local dist = self.sprite.width * self.sprite.scaling_factor
        local veln = VecNormalize(self.vel_current)
        local vx, vy, vz = dist * veln[1], dist * veln[2], dist * veln[3]
        SpawnParticle(VecAdd(self.position, Vec(vx, vy, vz)), Vec(0, 0, 0), 0.2)

        draw_sprite(self, self.position)
    end

    -- Stop increasing kinetic energy after first hit
    if not self.hit_once then
        self.kinetic_energy = clamp((values.weight * math.pow(math.abs(self.vel_current[2]), 2)) / 1000, 0, 5000)
        -- TODO: Change energy calculation to use whole velocity vector
    end

    dWatch("shell(CURRENT VELOCITY)", self.vel_current)
    dWatch("shell(KINETIC ENERGY)", self.kinetic_energy)

    -- Predicted position after the current tick
    local position_new = VecAdd(self.position, VecScale(self.vel_current, delta))

    addToDebugTable(DEBUG_LINES, {self.position, position_new, {0, 1, 0, 0.5}})

    if self.secondary.active and self.hit_once then
        return
    end

    -- Hit detection and ballistics system
    local shell_radius = self.sprite.width / 2
    QueryRequire('large')
    QueryRequire("physical")
    local hit, hit_distance, normal, shape_initial = QueryRaycast(self.position, VecNormalize(VecSub(position_new, self.position)), VecLength(VecSub(position_new, self.position)), shell_radius)

    ---@return boolean|nil detonate Detonation state
    ---@return table|nil position Position to trigger detonation at.
    local function check_detonate()
        if not hit then return false end
        -- if trigger_detonation then return true end

        local shell_radius = self.sprite.width / 2

        addToDebugTable(DEBUG_POSITIONS, {self.position, COLOUR["yellow"]})
        addToDebugTable(DEBUG_LINES, {self.position, position_new, COLOUR["red"]})
        dPrint("Hit detected.")

        self.hit_once = true

        if self.secondary.active then
            self.vel_current = Vec(0, 0, 0)
            return
        end

        local position_initial_hit = VecAdd(self.position, VecScale(VecNormalize(VecSub(position_new, self.position)), hit_distance))
        addToDebugTable(DEBUG_POSITIONS, {position_initial_hit, COLOUR["white"]})

        -- Guard clause: Check if ballistics is disabled to halt expensive computation
        if not CONFIG_getConfValue("G_SIMULATE_BALLISTICS") then
            detonate(self, position_initial_hit)
            return true, position_initial_hit
        end

        local material_initial = GetShapeMaterialAtPosition(shape_initial, (position_initial_hit))
        dPrint("Initial material is '"..material_initial.."'")

        -- Perform recursive check for materials encountered during this tick
        local hit_materials, hit_positions, reached_max_depth = getMaterialsInRaycastRecursive(self.position, position_new, { position_initial_hit }, shell_radius, { material_initial }, { shape_initial }, 3)
        if hit_positions ~= nil then
            position_detonation = hit_positions[#hit_positions]
        else
            position_detonation = position_initial_hit
            trigger_detonation = true
        end

        if reached_max_depth or trigger_detonation then
            detonate(self, position_detonation)
            return true, position_detonation
        end

        -- Iterate over all materials found in recursive QueryRaycast and determine outcome based on penetration values
        for index, material in pairs(hit_materials) do
            if trigger_detonation then break end

            dPrint("Material at index "..index.." is '"..material.."'")

            -- Pull penetration values for material, default if not found
            local pen_values = MAT_PEN[material]
            if pen_values == nil then
                dPrint("Material not found in penetration table. Defaulting...")
                pen_values = MAT_PEN["default"]
            end

            -- Pull penetration values for the specific shell variant
            pen_values = pen_values[variant.id] or pen_values["HE"]

            if self.kinetic_energy < pen_values.min_energy then
                dPrint("Material '"..material.."' triggered detonation. (energy below threshold)")
                return true, hit_positions[index]
            end

            if (math.random() * 100) < pen_values.chance then
                dPrint("Material '"..material.."' triggered detonation. (Unlucky roll)")
                return true, hit_positions[index]
            end

            dPrint("Material '"..material.."' was too weak to trigger detonation.")
            -- self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * (MAT_PEN[material].absorb / 100))
            self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * 1)
            MakeHole(hit_positions[index], shell_radius + 1, shell_radius + 0.5, shell_radius, false)
        end

        -- QueryRaycast in the opposite direction to check if bottom material is impenetrable. Fixes fringe QueryRejectShape edge case.
        hit, hit_distance, normal, shape_initial = QueryRaycast(position_new, VecNormalize(VecSub(self.position, position_new)), VecLength(VecSub(self.position, position_new), shell_radius))
        position_initial_hit = VecAdd(position_new, VecScale(VecNormalize(VecSub(self.position, position_new)), hit_distance))

        if not hit then return false end

        local bottom_material = GetShapeMaterialAtPosition(shape_initial, (position_initial_hit))
        dPrint("Bottom material detected as '"..bottom_material.."'")

        if bottom_material ~= "rock" and bottom_material ~= "none" then
            return false
        end

        dPrint("Bottom material is impenetrable")
        return true, position_initial_hit
    end

    local trigger_detonation, pos_detonation = check_detonate()

    if trigger_detonation then
        detonate(self, pos_detonation)
        return
    end

    self.vel_previous = VecCopy(self.vel_current)
    self.position = position_new
end

local function fire(self)
    DEBUG_POSITIONS = {}
    DEBUG_LINES = {}
    FRAG_STATS = {0, 0, 0, 0}

    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    dPrint("--- Firing shell ("..values.name.." ["..variant.name.."]) ---")

    if assertTableKeys(variant, "secondary", "timer") then
        self.secondary.timer = variant.secondary.timer
    end

    if self.inaccuracy > 0 then
        local rotation = QuatEuler(0, 360 * math.random(), 0)
        local distance = Vec(self.inaccuracy * math.random(), 0, 0)

        local transform = Transform(VecCopy(self.destination), rotation)
        self.destination = TransformToParentPoint(transform, distance)
    end

    local h_offset = 0
    if variant.id == "PF" then
        h_offset = variant.secondary.trigger_height
    end

    local v = 827 / 2
    if assertTableKeys(values, "muzzle_velocity") then
        v = values.muzzle_velocity
    end

    local pitch = math.rad(self.pitch)
    local vx, vy = v * math.cos(pitch), v * math.sin(pitch)
    local hmax = ((vy*vy) / (2 * math.abs(G_VEC_GRAVITY[2]))) + h_offset

    local range = ((v*v) * (2 * math.sin(pitch) * math.cos(pitch))) / math.abs(G_VEC_GRAVITY[2])
    range = range / 2

    local hrad = math.rad((self.heading + 90) % 360)
    local hx = math.sin(hrad)
    local hz = math.cos(hrad)

    local hvec = Vec(hx, 0, hz)

    local rangevec = VecScale(hvec, range)
    self.position = VecAdd(VecCopy(self.destination), Vec(rangevec[1], hmax, rangevec[3]))
    -- self.position = VecAdd(VecCopy(self.destination), Vec(0, 2, 0)) -- Testing

    local velvec = VecScale(hvec, vx)
    self.vel_current = Vec(-velvec[1], 0, -velvec[3])

    self.state = shell_states.IN_FLIGHT
    if self.flight_time < 0.2 then
        self.state = shell_states.ACTIVE
    end

    local snd_fire = LoadSound("MOD/snd/"..values.sounds.fire..".ogg")
    PlaySound(snd_fire, VecAdd(GetCameraTransform().pos, Vec(100, 0, 100)), 20)
end


-- #region Shell Control

function shell_init(shell)
    table.insert(SHELLS, shell)
    fire(shell)
end

function shell_tick(self, delta)
    dWatch("Flight Time", self.flight_time)

    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    if self.state == shell_states.IN_FLIGHT then
        if self.flight_time <= 0 then
            self.state = shell_states.ACTIVE
        end

        self.flight_time = self.flight_time - delta
    end

    if self.secondary.active then
        tick_secondary(self, delta, variant)
    end

    if self.state == shell_states.ACTIVE then
        tick_active(self, delta)
    end

    -- if self.state == shell_states.ACTIVE then
    --     local trigger_detonation = false
    --     local position_detonation = nil

    --     self.distance_ground = VecLength(VecSub(self.position, self.destination))
    --     dWatch("Distance to Target", self.distance_ground)

    --     -- Mark shell for deletion as the shell has gone out of bounds. Shell starts at <y>1000
    --     if (self.distance_ground > 5000) then
    --         self.state = shell_states.DETONATED
    --         return
    --     end

    --     -- Check if shell has a secondary state and that the secondary has not been activated yet;
    --     -- if so, check various trigger conditions
    --     if (assertTableKeys(variant, "secondary") and not self.secondary.active) then
    --         shell_trigger_secondary(self, variant.secondary)
    --     end

    --     -- Shell whistle logic
    --     if not variant.silent and VecLength(self.vel_current) > 100 and (self.distance_ground < 500) then
    --         local distance_player = VecLength(VecSub(self.position, GetPlayerPos()))
    --         local volume = clamp(150 - (clamp(distance_player, 0, 500) / 5), 0, 100)
    --         dWatch("Volume", volume)
    --         PlayLoop(self.snd_whistle, self.position, 100)
    --     end

    --     -- Provide default behaviours until secondary is active
    --     if (self.secondary.active and variant.secondary.draw) or not self.secondary.active then
    --         self.vel_current = VecAdd(self.vel_current, (VecScale(G_VEC_GRAVITY, delta))) -- Calculation of gravity's effect on shell velocity

    --         ParticleReset()
    --         ParticleRadius(0.2)
    --         ParticleStretch(1.0)

    --         local dist = self.sprite.width * self.sprite.scaling_factor
    --         local veln = VecNormalize(self.vel_current)
    --         local vx, vy, vz = dist * veln[1], dist * veln[2], dist * veln[3]
    --         SpawnParticle(VecAdd(self.position, Vec(vx, vy, vz)), Vec(0, 0, 0), 0.2)

    --         shell_draw_sprite(self, self.position)
    --     end

    --     -- Stop increasing kinetic energy after first hit
    --     if not self.hit_once then
    --         self.kinetic_energy = clamp((values.weight * math.pow(math.abs(self.vel_current[2]), 2)) / 1000, 0, 5000) -- TODO: Change energy calculation to use whole velocity vector
    --     end

    --     dWatch("shell(CURRENT VELOCITY)", self.vel_current)
    --     dWatch("shell(KINETIC ENERGY)", self.kinetic_energy)

    --     -- Predicted position after the current tick
    --     local position_new = VecAdd(self.position, VecScale(self.vel_current, delta))

    --     addToDebugTable(DEBUG_LINES, {self.position, position_new, {0, 1, 0, 0.5}})

    --     if self.secondary.active and self.hit_once then
    --         return
    --     end

    --     -- Hit detection and ballistics system
    --     local shell_radius = self.sprite.width / 2
    --     QueryRequire('large')
    --     QueryRequire("physical")
    --     local hit, hit_distance, normal, shape_initial = QueryRaycast(self.position, VecNormalize(VecSub(position_new, self.position)), VecLength(VecSub(position_new, self.position)), shell_radius)
    --     if hit and not trigger_detonation then
    --         addToDebugTable(DEBUG_POSITIONS, {self.position, COLOUR["yellow"]})
    --         addToDebugTable(DEBUG_LINES, {self.position, position_new, COLOUR["red"]})
    --         dPrint("Hit detected.")

    --         self.hit_once = true

    --         if self.secondary.active then
    --             self.vel_current = Vec(0, 0, 0)
    --             return
    --         end

    --         local position_initial_hit = VecAdd(self.position, VecScale(VecNormalize(VecSub(position_new, self.position)), hit_distance))
    --         addToDebugTable(DEBUG_POSITIONS, {position_initial_hit, COLOUR["white"]})

    --         -- Guard clause: Check if ballistics is disabled to halt expensive computation
    --         if not CONFIG_getConfValue("G_SIMULATE_BALLISTICS") then
    --             shell_detonate(self, position_initial_hit)
    --             return
    --         end

    --         local material_initial = GetShapeMaterialAtPosition(shape_initial, (position_initial_hit))
    --         dPrint("Initial material is '"..material_initial.."'")

    --         -- Perform recursive check for materials encountered during this tick
    --         local hit_materials, hit_positions, reached_max_depth = getMaterialsInRaycastRecursive(self.position, position_new, { position_initial_hit }, shell_radius, { material_initial }, { shape_initial }, 3)
    --         if hit_positions ~= nil then
    --             position_detonation = hit_positions[#hit_positions]
    --         else
    --             position_detonation = position_initial_hit
    --             trigger_detonation = true
    --         end

    --         if reached_max_depth or trigger_detonation then
    --             shell_detonate(self, position_detonation)
    --             return
    --         end

    --         -- Iterate over all materials found in recursive QueryRaycast and determine outcome based on penetration values
    --         for index, material in pairs(hit_materials) do
    --             if trigger_detonation then break end

    --             dPrint("Material at index "..index.." is '"..material.."'")

    --             -- Pull penetration values for material, default if not found
    --             local pen_values = MAT_PEN[material]
    --             if pen_values == nil then
    --                 dPrint("Material not found in penetration table. Defaulting...")
    --                 pen_values = MAT_PEN["default"]
    --             end

    --             -- Pull penetration values for the specific shell variant
    --             pen_values = pen_values[variant.id] or pen_values["HE"]

    --             if self.kinetic_energy >= pen_values.min_energy then
    --                 if (math.random() * 100) < pen_values.chance then
    --                     dPrint("Material '"..material.."' triggered detonation. (Unlucky roll)")
    --                     position_detonation = hit_positions[index]
    --                     trigger_detonation = true
    --                 else
    --                     dPrint("Material '"..material.."' was too weak to trigger detonation.")
    --                     -- self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * (MAT_PEN[material].absorb / 100))
    --                     self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * 1)
    --                     MakeHole(hit_positions[index], shell_radius + 1, shell_radius + 0.5, shell_radius, false)
    --                 end
    --             else
    --                 dPrint("Material '"..material.."' triggered detonation. (energy below threshold)")
    --                 position_detonation = hit_positions[index]
    --                 trigger_detonation = true
    --             end
    --         end

    --         -- QueryRaycast in the opposite direction to check if bottom material is impenetrable. Fixes fringe QueryRejectShape edge case.
    --         if not trigger_detonation then
    --             hit, hit_distance, normal, shape_initial = QueryRaycast(position_new, VecNormalize(VecSub(self.position, position_new)), VecLength(VecSub(self.position, position_new), shell_radius))
    --             position_initial_hit = VecAdd(position_new, VecScale(VecNormalize(VecSub(self.position, position_new)), hit_distance))
    --             if hit then
    --                 local bottom_material = GetShapeMaterialAtPosition(shape_initial, (position_initial_hit))
    --                 dPrint("Bottom material detected as '"..bottom_material.."'")
    --                 if bottom_material == "rock" or bottom_material == "none" then
    --                     dPrint("Bottom material is impenetrable")
    --                     trigger_detonation = true
    --                 end
    --             end
    --         end

    --         dPrint("-------------")
    --     end

    --     if trigger_detonation then
    --         shell_detonate(self, position_detonation)
    --         return
    --     end

    --     self.vel_previous = VecCopy(self.vel_current)
    --     self.position = position_new
    -- end
end

-- #endregion