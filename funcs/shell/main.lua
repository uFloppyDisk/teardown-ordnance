#include "secondary.lua"

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

local function tick_frag(self, index, pos, frag_size, frag_dist, rot, halt)
    local function check_hit(rotation)
        local transform = Transform(pos, rotation)
        local position_new = TransformToParentPoint(transform, Vec(((frag_dist - 5) + (math.random() * 10)), 0, 0))
        local transform_new = Transform(position_new, transform.rot)

        local hit, hit_distance = QueryRaycast(pos, VecNormalize(VecSub(position_new, pos)), VecLength(VecSub(position_new, pos)))
        if not hit then
            return false, transform_new
        end

        local new_rotation = QuatRotateQuat(QuatCopy(rotation), QuatEuler(0, 0, 180))
        local hit_pos = VecAdd(pos, VecScale(VecNormalize(VecSub(position_new, pos)), hit_distance))

        if hit_distance < 1 and not halt then
            if CONFIG_getConfValue("G_FRAGMENTATION_DEBUG") then
                addToDebugTable(DEBUG_POSITIONS, {hit_pos, getRGBA(COLOUR["red"], 0.2)})
                FRAG_STATS[4] = FRAG_STATS[4] + 1
            end

            return tick_frag(self, index, VecCopy(pos), frag_size, frag_dist, new_rotation, true)
        end

        if math.random() < 0.66 then
            ParticleReset()
            SpawnParticle(hit_pos, Vec(-0.15, 0, 0.05), (3 - (2.5 * math.random())))
        end

        local rand_frag_size = frag_size * (1.0 - (math.random() * 0.50))
        MakeHole(hit_pos, rand_frag_size * 3, rand_frag_size * 2, rand_frag_size)

        if not CONFIG_getConfValue("G_FRAGMENTATION_DEBUG") then
            return true
        end

        local point_colour = COLOUR["white"]
        if halt then
            point_colour = COLOUR["yellow"]
        end

        addToDebugTable(DEBUG_POSITIONS, {hit_pos, point_colour})
        addToDebugTable(DEBUG_LINES, {pos, hit_pos, getRGBA(COLOUR["white"], 0.5)})
        FRAG_STATS[2] = FRAG_STATS[2] + 1

        return true
    end

    FRAG_STATS[1] = FRAG_STATS[1] + 1

    local rotation = QuatCopy(rot)
    if rot == nil then
        local rot_y = 360 * math.random()
        local rot_z = (179 * math.random()) - 89.5
        rotation = QuatEuler(0, rot_y, rot_z)
    end

    hit_final, line_end = check_hit(rotation)

    if hit_final then return true end

    if CONFIG_getConfValue("G_FRAGMENTATION_DEBUG") then
        if line_end == nil then return false end

        addToDebugTable(DEBUG_LINES, {pos, line_end.pos, getRGBA(COLOUR["red"], 0.1)})
        FRAG_STATS[3] = FRAG_STATS[3] + 1
    end

    return false
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

local function tick_active(self, delta)
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    self.distance_ground = VecLength(VecSub(self.position, self.destination))
    dWatch("Distance to Target", self.distance_ground)

    -- TODO - More intelligent out of bounds detection
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

    local velocity_new = VecCopy(self.vel_current)
    local position_new = VecCopy(self.position)

    -- Provide default behaviours until secondary is active
    if (self.secondary.active and variant.secondary.draw) or not self.secondary.active then
        -- TODO: Option to change iteration amount
        local iterations = 16
        local iter_delta = delta / iterations

        -- Calculation of gravity's effect on shell velocity and position over N iterations
        for _ = 0, iterations, 1 do
            velocity_new = VecAdd(velocity_new, VecScale(G_VEC_GRAVITY, iter_delta))
            position_new = VecAdd(position_new, VecScale(velocity_new, iter_delta))
        end

        self.vel_current = VecCopy(velocity_new)

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
        self.kinetic_energy = clamp((values.weight * math.pow(math.abs(VecLength(self.vel_current)), 2)) / 1000, 0, 5000)
    end

    dWatch("shell(CURRENT VELOCITY)", self.vel_current)
    dWatch("shell(KINETIC ENERGY)", self.kinetic_energy)

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

    self.position = VecCopy(position_new)
end

local function shell_play_sound_fire(self)
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    local snd_pos = Vec(100, 0, 100)
    if self.pitch < 90 then
        local length = VecLength(snd_pos)

        local transform = Transform(Vec(0, 0, 0), QuatEuler(0, self.heading, 0))
        snd_pos = TransformToParentVec(transform, VecScale(Vec(1, 0, 0), length))
    end

    local snd_fire = LoadSound("MOD/snd/"..values.sounds.fire..".ogg")
    PlaySound(snd_fire, VecAdd(GetCameraTransform().pos, snd_pos), 20)
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

    addToDebugTable(DEBUG_POSITIONS, {self.destination, getRGBA(COLOUR["green"])})

    local height_offset = 0
    if variant.id == "PF" then
        height_offset = variant.secondary.trigger_height
    end

    height_offset = height_offset + 1.20 -- Manual adjustment for accuracy

    -- TODO - Use muzzle velocity based on shell/gun fired
    local velocity = 827 / 2
    if assertTableKeys(values, "muzzle_velocity") then
        velocity = values.muzzle_velocity
    end

    local pitch_in_rad = math.rad(self.pitch)

    -- Flight Time Calculation
    local eta_from_origin = (2 * velocity * math.sin(pitch_in_rad)) / math.abs(G_VEC_GRAVITY[2])
    local eta_from_apogee = (velocity * math.sin(pitch_in_rad)) / math.abs(G_VEC_GRAVITY[2])

    local velocity_horizontal, velocity_vertical = velocity * math.cos(pitch_in_rad), velocity * math.sin(pitch_in_rad)

    local heading_in_rad = math.rad((self.heading + 90) % 360)
    local heading_x = math.sin(heading_in_rad)
    local heading_z = math.cos(heading_in_rad)

    local heading_3d = Vec(heading_x, 0, heading_z)
    local velocity_3d = VecScale(heading_3d, velocity_horizontal)

    -- ETA compensation
    -- TODO: Option to change ETA time
    local at_time = 3
    if at_time >= eta_from_apogee then
        self.flight_time = at_time - eta_from_apogee
        at_time = eta_from_apogee
    end

    local x_at_t = VecAdd(VecScale(velocity_3d, at_time), VecCopy(self.destination))
    local y_at_t = -0.5 * (math.abs(G_VEC_GRAVITY[2]) * (at_time*at_time)) -- -1/2gt^2
    y_at_t = y_at_t + (velocity_vertical * at_time) + self.destination[2] -- + (vy0)t + y0

    self.position = Vec(x_at_t[1], y_at_t, x_at_t[3])
    -- self.position = VecAdd(VecCopy(self.destination), Vec(0, 2, 0)) -- Testing
    self.vel_current = Vec(-velocity_3d[1], -velocity_vertical - (G_VEC_GRAVITY[2] * at_time), -velocity_3d[3])

    if self.flight_time <= 0 then
        self.state = shell_states.ACTIVE
        shell_play_sound_fire(self)
        return
    end

    self.state = shell_states.IN_FLIGHT

    shell_play_sound_fire(self)
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
        local finished = tick_secondary(self, delta, variant)
        if finished then
            self.state = shell_states.DETONATED
            self.secondary.active = false
        end
    end

    if self.state == shell_states.ACTIVE then
        tick_active(self, delta)
    end
end

-- #endregion