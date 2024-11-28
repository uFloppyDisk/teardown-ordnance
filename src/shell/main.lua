---Draw shell sprite
---@param self any
function ShellDrawSprite(self)
    local rotation = QuatEuler(0, self.heading, 90 + self.pitch)

    local look_at = QuatLookAt(self.position, GetCameraTransform().pos)
    local _, ly, _ = GetQuatEuler(look_at)
    look_at = QuatEuler(0, -ly, 0)

    rotation = QuatRotateQuat(rotation, look_at)

    local transform_pos = Transform(self.position, rotation)
    local transform_pos_90 = Transform(self.position, QuatRotateQuat(rotation, QuatAxisAngle(Vec(0, 1, 0), 90)))

    DrawSprite(self.sprite.img, transform_pos_90, self.sprite.width, (self.sprite.width * self.sprite.scaling_factor), 0.4, 0.4, 0.4, 1, true, false) -- Second
    DrawSprite(self.sprite.img, transform_pos, self.sprite.width, (self.sprite.width * self.sprite.scaling_factor), 0.4, 0.4, 0.4, 1, true, false)
end

---Calculate origin of fragmentation to prevent level geometry from absorbing it all
---@param source_pos vector_t
---@param source_dist number
---@param check_dist number
---@param shape shape_handle Shape handle for shape bounds calculation
---@return vector_t
local function solveFragOrigin(source_pos, source_dist, check_dist, shape)
    source_pos = VecCopy(source_pos)
    QueryRequire('large')
    local _, distance = QueryRaycast(VecAdd(VecCopy(source_pos), Vec(0, check_dist, 0)), Vec(0, -1, 0), check_dist)

    local dist_diff = FdRound(distance, 4) - source_dist
    FdLog("Diff 1/2: "..source_dist.." / "..distance)
    FdLog("Diff: "..dist_diff)

    if dist_diff ~= 0 then
        FdLog("Using differential calculation")
        return VecAdd(source_pos, Vec(0, source_dist + (check_dist - (dist_diff * 0.95)), 0))
    end

    FdLog("Using shape bounds calculation")
    local bounds_min, bounds_max = GetShapeBounds(shape)
    local bounds_size = VecSub(bounds_max, bounds_min)

    return VecAdd(source_pos, Vec(0, math.abs(bounds_size[2]), 0))
end

local function shellFragTick(self, index, pos, frag_size, frag_dist, rot, halt)
    local function checkHit(rotation)
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
            if CfgGetValue("G_FRAGMENTATION_DEBUG") then
                FdAddToDebugTable(DEBUG_POSITIONS, {hit_pos, FdGetRGBA(COLOUR["red"], 0.2)})
                FRAG_STATS[4] = FRAG_STATS[4] + 1
            end

            return shellFragTick(self, index, VecCopy(pos), frag_size, frag_dist, new_rotation, true)
        end

        if math.random() < 0.66 then
            ParticleReset()
            SpawnParticle(hit_pos, Vec(-0.15, 0, 0.05), (3 - (2.5 * math.random())))
        end

        local rand_frag_size = frag_size * (1.0 - (math.random() * 0.50))
        MakeHole(hit_pos, rand_frag_size * 3, rand_frag_size * 2, rand_frag_size)

        if not CfgGetValue("G_FRAGMENTATION_DEBUG") then
            return true
        end

        local point_colour = COLOUR["white"]
        if halt then
            point_colour = COLOUR["yellow"]
        end

        FdAddToDebugTable(DEBUG_POSITIONS, {hit_pos, point_colour})
        FdAddToDebugTable(DEBUG_LINES, {pos, hit_pos, FdGetRGBA(COLOUR["white"], 0.5)})
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

    local hit_final, line_end = checkHit(rotation)

    if hit_final then return true end

    if CfgGetValue("G_FRAGMENTATION_DEBUG") then
        if line_end == nil then return false end

        FdAddToDebugTable(DEBUG_LINES, {pos, line_end.pos, FdGetRGBA(COLOUR["red"], 0.1)})
        FRAG_STATS[3] = FRAG_STATS[3] + 1
    end

    return false
end

local function detonate(self, pos)
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    self.position = VecCopy(pos)

    if not (FdAssertTableKeys(variant, "secondary")) or ShellSecInit(self, variant.secondary, true) then
        self.state = SHELL_STATE.DETONATED
    end

    FdAddToDebugTable(DEBUG_POSITIONS, {pos, COLOUR["red"]})

    if CfgGetValue("G_SIMULATE_UXO") and math.random(100) <= 2 then
        MakeHole(pos, 5, 2, 1, false)
        return
    end

    local hole = variant.size_makehole
    MakeHole(pos, hole[1], hole[2], hole[3], false)

    if variant.size_explosion <= 0 then return end

    Explosion(pos, variant.size_explosion)

    if variant.size_explosion < 0.5 then return end
    if not CfgGetValue("G_SIMULATE_FRAGMENTATION") then return end

    local FRAG_AMOUNT = CfgGetValue("SHELL_FRAGMENTATION_AMOUNT") or 250
    local FRAG_SIZE = (CfgGetValue("SHELL_FRAGMENTATION_SIZE") or 20) / 100
    local FRAG_DISTANCE = variant.size_makehole[1] / 2

    if CfgGetValue("G_FRAGMENTATION_DEBUG") then
        FdWatch("Frag Size", FRAG_SIZE)
        FdWatch("Frag Dist", FRAG_DISTANCE)
    end

    local check_dist = 0.5

    QueryRequire('large')
    local hit, distance, _, shape = QueryRaycast(pos, Vec(0, 1, 0), check_dist)

    local frag_origin = pos
    if hit then
        frag_origin = solveFragOrigin(pos, distance, check_dist, shape)
    end

    for i = 1, FRAG_AMOUNT, 1 do
        shellFragTick(self, i, frag_origin, FRAG_SIZE, FRAG_DISTANCE)
    end

    if CfgGetValue("G_FRAGMENTATION_DEBUG") then
        FdLog("--- FRAGMENTATION STATS ---")
        FdLog(FRAG_STATS[2].." - hit")
        FdLog(FRAG_STATS[3].." - missed")
        FdLog(FRAG_STATS[4].." - redirected")
        FdLog("-------------")
        FdLog("TOTAL: "..FRAG_STATS[1].." - "..FRAG_STATS[4].." redirected = "..(FRAG_STATS[1] - FRAG_STATS[4])..")")
    end
end

local function tickActive(self, delta)
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    self.distance_ground = VecLength(VecSub(self.position, self.destination))
    FdWatch("Distance to Target", self.distance_ground)

    -- TODO - More intelligent out of bounds detection
    -- Mark shell for deletion as the shell has gone out of bounds.
    if (self.distance_ground > 5000) then
        self.state = SHELL_STATE.DETONATED
        return
    end

    -- Check if shell has a secondary state and that the secondary has not been activated yet;
    -- if so, check various trigger conditions
    if (FdAssertTableKeys(variant, "secondary") and not self.secondary.active) then
        ShellSecInit(self, variant.secondary)
    end

    -- Shell whistle logic
    if not variant.silent and VecLength(self.vel_current) > 100 and (self.distance_ground < 500) then
        local distance_player = VecLength(VecSub(self.position, GetPlayerPos()))
        local volume = FdClamp(150 - (FdClamp(distance_player, 0, 500) / 5), 0, 100)
        FdWatch("Volume", volume)
        PlayLoop(self.snd_whistle, self.position, 100)
    end

    local velocity_new = VecCopy(self.vel_current)
    local position_new = VecCopy(self.position)

    -- Provide default behaviours until secondary is active
    if (self.secondary.active and variant.secondary.draw) or not self.secondary.active then
        local physics_iterations = G_PHYSICS_ITERATIONS
        local iter_delta = delta / physics_iterations

        -- Calculation of gravity's effect on shell velocity and position over N iterations
        for _ = 0, physics_iterations, 1 do
            velocity_new = VecAdd(velocity_new, VecScale(G_VEC_GRAVITY, iter_delta))
            position_new = VecAdd(position_new, VecScale(velocity_new, iter_delta))
        end

        self.vel_current = VecCopy(velocity_new)

        if math.abs(VecLength(VecSub(self.position, GetCameraTransform().pos))) < 100 then
            ParticleReset()
            ParticleRadius(0.2, 0)
            ParticleAlpha(0.2)
            ParticleStretch(1.0)

            local iterations = 16
            for i = 1, iterations, 1 do
                local spawn_pos = VecLerp(self.position, position_new, i / iterations)
                SpawnParticle(spawn_pos, G_VEC_WIND, 0.1)
            end
        end
    end

    -- Stop increasing kinetic energy after first hit
    if not self.hit_once then
        self.kinetic_energy = FdClamp((values.weight * math.pow(math.abs(VecLength(self.vel_current)), 2)) / 1000, 0, 5000)
    end

    FdWatch("shell(CURRENT VELOCITY)", self.vel_current)
    FdWatch("shell(KINETIC ENERGY)", self.kinetic_energy)

    FdAddToDebugTable(DEBUG_LINES, {self.position, position_new, {0, 1, 0, 0.5}})

    if self.secondary.active and self.hit_once then
        return
    end

    -- Hit detection and ballistics system
    QueryRequire('large')
    QueryRequire("physical")
    local hit, hit_distance, _, shape_initial = QueryRaycast(self.position, VecNormalize(VecSub(position_new, self.position)), VecLength(VecSub(position_new, self.position)))
    if not hit then
        self.position = VecCopy(position_new)
        return
    end

    FdAddToDebugTable(DEBUG_POSITIONS, {self.position, COLOUR["yellow"]})
    FdAddToDebugTable(DEBUG_LINES, {self.position, position_new, COLOUR["red"]})
    FdLog("Hit detected.")

    self.hit_once = true

    if self.secondary.active then
        self.vel_current = Vec(0, 0, 0)
        return
    end

    ---Solve shell ballistics
    ---@param pos_hit vector_t
    ---@param radius number
    ---@return boolean
    ---@return vector_t?
    local function solveBallistics(pos_hit, radius)
        local trigger_detonation = false
        local material_initial = GetShapeMaterialAtPosition(shape_initial, (pos_hit))
        FdLog("Initial material is '"..material_initial.."'")

        -- Perform recursive check for materials encountered during this tick
        local hit_materials, hit_positions, reached_max_depth = FdGetMaterialsInRaycastRecursive(self.position, position_new, { pos_hit }, radius, { material_initial }, { shape_initial }, 6)

        local position_detonation
        if hit_positions ~= nil then
            position_detonation = hit_positions[#hit_positions]
        else
            position_detonation = pos_hit
            trigger_detonation = true
        end

        if reached_max_depth or trigger_detonation then
            detonate(self, position_detonation)
            return true, position_detonation
        end

        -- Iterate over all materials found in recursive QueryRaycast and determine outcome based on penetration values
        for index, material in pairs(hit_materials) do
            if trigger_detonation then break end

            FdLog("Material at index "..index.." is '"..material.."'")

            -- Pull penetration values for material, default if not found
            local pen_values = MAT_PEN[material]
            if pen_values == nil then
                FdLog("Material not found in penetration table. Defaulting...")
                pen_values = MAT_PEN["default"]
            end

            -- Pull penetration values for the specific shell variant
            pen_values = pen_values[variant.id] or pen_values["HE"]

            if self.kinetic_energy < pen_values.min_energy then
                FdLog("Material '"..material.."' triggered detonation. (energy below threshold)")
                return true, hit_positions[index]
            end

            if (math.random() * 100) < pen_values.chance then
                FdLog("Material '"..material.."' triggered detonation. (Unlucky roll)")
                return true, hit_positions[index]
            end

            FdLog("Material '"..material.."' was too weak to trigger detonation.")
            -- self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * (MAT_PEN[material].absorb / 100))
            self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * 1)
            MakeHole(hit_positions[index], radius + 1, radius + 0.5, radius, false)
        end

        -- QueryRaycast in the opposite direction to check if bottom material is impenetrable. Fixes fringe QueryRejectShape edge case.
        hit, hit_distance, _, shape_initial = QueryRaycast(position_new, VecNormalize(VecSub(self.position, position_new)), VecLength(VecSub(self.position, position_new)), 0)
        local position_initial_hit = VecAdd(position_new, VecScale(VecNormalize(VecSub(self.position, position_new)), hit_distance))

        if not hit then return false end

        local bottom_material = GetShapeMaterialAtPosition(shape_initial, (position_initial_hit))
        FdLog("Bottom material detected as '"..bottom_material.."'")

        if bottom_material ~= "rock" and bottom_material ~= "none" then
            return false
        end

        if #hit_positions == 1 then
            return true, hit_positions[1]
        end

        FdLog("Bottom material is impenetrable")
        return true, position_initial_hit
    end

    local pos_initial_hit = VecAdd(
        self.position,
        VecScale(VecNormalize(VecSub(position_new, self.position)), hit_distance)
    )
    local radius = self.sprite.width / 2

    FdAddToDebugTable(DEBUG_POSITIONS, {pos_initial_hit, COLOUR["white"]})

    local trigger_detonation, pos_detonation

    if not CfgGetValue("G_SIMULATE_BALLISTICS") then
        trigger_detonation = true
        pos_detonation = pos_initial_hit
    else
        trigger_detonation, pos_detonation = solveBallistics(pos_initial_hit, radius)
    end

    if trigger_detonation then
        detonate(self, pos_detonation)
        return
    end

    self.position = VecCopy(position_new)
end

local function playFireSound(self)
    local values = SHELL_VALUES[self.type]

    local snd_pos = Vec(100, 0, 100)
    if self.pitch < 90 then
        local length = VecLength(snd_pos)

        local transform = Transform(Vec(0, 0, 0), QuatEuler(0, self.heading, 0))
        snd_pos = TransformToParentVec(transform, VecScale(Vec(1, 0, 0), length))
    end

    local snd_fire = LoadSound("MOD/assets/snd/"..values.sounds.fire..".ogg")
    PlaySound(snd_fire, VecAdd(GetCameraTransform().pos, snd_pos), 20)
end

local function fire(self)
    DEBUG_POSITIONS = {}
    DEBUG_LINES = {}
    FRAG_STATS = {0, 0, 0, 0}

    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    FdLog("--- Firing shell ("..values.name.." ["..variant.name.."]) ---")

    if FdAssertTableKeys(variant, "secondary", "timer") then
        self.secondary.timer = variant.secondary.timer
    end

    if self.inaccuracy > 0 then
        local rotation = QuatEuler(0, 360 * math.random(), 0)
        local distance = Vec(self.inaccuracy * math.random(), 0, 0)

        local transform = Transform(VecCopy(self.destination), rotation)
        self.destination = TransformToParentPoint(transform, distance)
    end

    FdAddToDebugTable(DEBUG_POSITIONS, {self.destination, FdGetRGBA(COLOUR["green"])})

    local height_offset = 0
    if variant.id == "PF" then
        height_offset = variant.secondary.trigger_height
    end

    height_offset = height_offset + 1.20 -- Manual adjustment for accuracy

    -- TODO - Use muzzle velocity based on shell/gun fired
    local velocity = 827 / 2
    if FdAssertTableKeys(values, "muzzle_velocity") then
        velocity = values.muzzle_velocity
    end

    local pitch_in_rad = math.rad(self.pitch)

    -- Flight Time Calculation
    local eta_from_apogee = (velocity * math.sin(pitch_in_rad)) / math.abs(G_VEC_GRAVITY[2])

    local velocity_horizontal, velocity_vertical = velocity * math.cos(pitch_in_rad), velocity * math.sin(pitch_in_rad)

    local heading_in_rad = math.rad((self.heading + 90) % 360)
    local heading_x = math.sin(heading_in_rad)
    local heading_z = math.cos(heading_in_rad)

    local heading_3d = Vec(heading_x, 0, heading_z)
    local velocity_3d = VecScale(heading_3d, velocity_horizontal)

    -- ETA compensation
    local at_time = self.eta
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
        self.state = SHELL_STATE.ACTIVE
        playFireSound(self)
        return
    end

    self.state = SHELL_STATE.IN_FLIGHT

    playFireSound(self)
end


-- #region Shell Control

function ShellInit(shell)
    table.insert(SHELLS, shell)
    fire(shell)
end

function ShellTick(self, delta)
    FdWatch("Flight Time", self.flight_time)

    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    if self.state == SHELL_STATE.IN_FLIGHT then
        if self.flight_time <= 0 then
            self.state = SHELL_STATE.ACTIVE
        end

        self.flight_time = self.flight_time - delta
    end

    if self.secondary.active then
        local finished = ShellSecTick(self, delta, variant)
        if finished then
            self.state = SHELL_STATE.DETONATED
            self.secondary.active = false
        end
    end

    if self.state == SHELL_STATE.ACTIVE then
        tickActive(self, delta)
    end
end

-- #endregion
