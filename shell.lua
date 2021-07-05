function shellNew(new)
    local base = shellCopy(DEFAULT_SHELL)
    for key, value in pairs(new) do
        base[key] = value
    end

    return base
end

function submunitionNew(new)
    local base = shellCopy(DEFAULT_SUBMUNITION)
    for key, value in pairs(new) do
        base[key] = value
    end

    return base
end

function shellCopy(object)
    local copy
    if type(object) == 'table' then
        copy = {}
        for key, value in pairs(object) do
            copy[shellCopy(key)] = shellCopy(value)
        end
        setmetatable(copy, shellCopy(getmetatable(object)))
    else
        copy = object
    end
    return copy
end

function shellDraw(self, pos)
    local rotation = QuatRotateQuat(QuatLookAt(self.position, GetCameraTransform().pos), QuatAxisAngle(Vec(0,0,1), 180))
    local transform_pos = Transform(pos, rotation)

    DrawSprite(self.sprite.img, transform_pos, self.sprite.width, (self.sprite.width * self.sprite.scaling_factor), 0.4, 0.4, 0.4, 1, true, false)
end

function shellTriggerSecondary(self, parameters)
    if assertTableKeys(parameters, "trigger_height") then
        if parameters.trigger_height < self.distance_ground then
            return
        end

        self.secondary.active = true
        self.vel_current = Vec(-0.1, -1, 0.02)

        if assertTableKeys(parameters, "trigger_sound") then
            PlaySound(parameters.trigger_sound, self.position, 90)
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
end

function shellTick(self, delta)
    dWatch("Flight Time", self.flight_time)

    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    if self.state == SHELL_STATES.in_flight then
        if self.flight_time <= 0 then
            self.state = SHELL_STATES.active
        end

        self.flight_time = self.flight_time - delta
    end

    if self.secondary.active then
        if variant.id == "PF" then
            if self.secondary.timer >= 0 then
                self.secondary.intensity = clamp((self.secondary.intensity + (5 * math.random(-1, 1))), 950, 1050)

                local timer_ratio = self.secondary.timer / variant.secondary.timer
                if (timer_ratio) <= 0.15 then
                    self.secondary.intensity = self.secondary.intensity * ((timer_ratio) / 0.15)
                end

                dWatch("shell(SECONDARY_INTENSITY)", self.secondary.intensity)

                PointLight(self.position, 1, 1, 1, self.secondary.intensity)

                if math.random() > 0.5 then
                    ParticleReset()
                    ParticleRadius(0.3 * math.random())
                    ParticleAlpha(1.0, 0.0, "smooth", 0.05, 0.5)
                    ParticleStretch(0)

                    local particle_origin = VecAdd(self.position, Vec(0, (self.sprite.width * self.sprite.scaling_factor), 0))
                    self.secondary.particle_spread[1] = clamp(self.secondary.particle_spread[1] + (0.04 * math.random(-1, 1)), -0.5, 0.5)
                    self.secondary.particle_spread[3] = clamp(self.secondary.particle_spread[3] + (0.04 * math.random(-1, 1)), -0.5, 0.5)

                    SpawnParticle(VecAdd(particle_origin, self.secondary.particle_spread), Vec(-0.15, 0, 0.05), 20)
                end

                self.secondary.timer = self.secondary.timer - delta
            else
                self.state = SHELL_STATES.detonated
                self.secondary.active = false
            end
        end

        if variant.id == "CL" then
            if self.secondary.timer >= 0 then
                if not assertTableKeys(self, "secondary", "submunitions") then
                    self.secondary.submunitions = {}

                    local amount_submunitions = GetInt('savegame.mod.shells.secondary.cluster_bomblet_amount') or 50
                    for i = 1, amount_submunitions, 1 do
                        local rotation = QuatEuler(0, math.random() * 360, math.random() * -80)
                        local transform = Transform(self.position, rotation)

                        local sub = submunitionNew({
                            transform = TransformCopy(transform),
                            velocity = Vec(math.random() * 7 + 5, 0, 0)
                        })

                        table.insert(self.secondary.submunitions, sub)
                    end

                    dWatch("SUBMUNITIONS(amount)", #self.secondary.submunitions)
                end

                if #self.secondary.submunitions == 0 then
                    self.state = SHELL_STATES.detonated
                    self.secondary.active = false
                end

                local sprite = LoadSprite("MOD/img/".."bomblet"..".png")

                local sounds = {
                    "155mm_shell_cluster_submunition_explode_01",
                    "155mm_shell_cluster_submunition_explode_02",
                }

                for index, sub in ipairs(self.secondary.submunitions) do
                    local gravity = math.abs(G_VEC_GRAVITY[2])
                    local world_down = TransformToLocalVec(sub.transform, Vec(0, -1, 0))

                    sub.velocity = VecAdd(sub.velocity, VecScale(world_down, gravity * delta))

                    local position_new = TransformToParentPoint(sub.transform, VecScale(sub.velocity, delta))
                    local transform_new = Transform(position_new, sub.transform.rot)

                    addToDebugTable(DEBUG_LINES, {sub.transform.pos, transform_new.pos, {1, 0.6, 0.2}})

                    local hit, hit_distance = QueryRaycast(sub.transform.pos, VecNormalize(VecSub(position_new, sub.transform.pos)), VecLength(VecSub(position_new, sub.transform.pos)))

                    if hit then
                        local position_hit = VecAdd(sub.transform.pos, VecScale(VecNormalize(VecSub(position_new, sub.transform.pos)), hit_distance))

                        if GetBool("savegame.mod.simulate_dud") and math.random(100) <= 2 then
                            dPrint("Submunition at index "..index.." is a dud.")
                            MakeHole(position_hit, 0.5, 0.1, 0, false)
                        else
                            Explosion(position_hit, 0.9)
                            MakeHole(position_hit, 2, 1, 0.3, false)

                            ParticleReset()
                            ParticleRadius(1, 2.5, "smooth", 0, 0.2)
                            ParticleAlpha(0.5, 0.0, "smooth", 0.05, 0.5)
                            ParticleStretch(0)
                            ParticleCollide(0)

                            SpawnParticle(position_hit, Vec(-0.1, 0.03, 0.02), math.random() * 7 + 3)

                            if math.random() > 0.7 then
                                local sound = LoadSound("MOD/snd/"..sounds[math.random(#sounds)]..".ogg")
                                PlaySound(sound, position_hit, math.random() * 2 + 8)
                            end
                        end

                        table.remove(self.secondary.submunitions, index)
                    else
                        local look_rotation = QuatRotateQuat(QuatLookAt(sub.transform.pos, GetCameraTransform().pos), QuatAxisAngle(Vec(0,0,1), 180))
                        local draw_pos = Transform(sub.transform.pos, look_rotation)
                        DrawSprite(sprite, draw_pos, 0.0635, 0.0635, 0.4, 0.4, 0.4, 1, true, false)

                        sub.transform = transform_new
                    end
                end

                self.secondary.timer = self.secondary.timer - delta
            else
                self.state = SHELL_STATES.detonated
                self.secondary.active = false
            end
        end
    end

    if self.state == SHELL_STATES.active then
        local trigger_detonation = false
        local position_detonation = nil

        self.distance_ground = VecLength(VecSub(self.position, self.destination))
        dWatch("Distance to Ground", self.distance_ground)

        -- Mark shell for deletion as the shell has gone out of bounds. Shell starts at <y>1000
        if (self.distance_ground > 2000) then
            self.state = SHELL_STATES.detonated
            return
        end

        -- Check if shell has a secondary state and that the secondary has not been activated yet;
        -- if so, check various trigger conditions
        if (assertTableKeys(variant, "secondary") and not self.secondary.active) then
            shellTriggerSecondary(self, variant.secondary)
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
            self.vel_current = VecAdd(self.vel_current, (VecScale(G_VEC_GRAVITY, delta)))

            ParticleReset()
            ParticleRadius(0.2)
            ParticleStretch(1.0)
            SpawnParticle(VecAdd(self.position, Vec(0, self.sprite.width * self.sprite.scaling_factor, 0)), Vec(0, -1, 0), 0.1)

            shellDraw(self, self.position)
        end

        -- Stop increasing kinetic energy after first hit
        if not self.hit_once then
            self.kinetic_energy = clamp((values.weight * math.pow(math.abs(self.vel_current[2]), 2)) / 1000, 0, 5000)
        end

        dWatch("shell(CURRENT VELOCITY)", self.vel_current)
        dWatch("shell(KINETIC ENERGY)", self.kinetic_energy)

        -- Predicted position after the current tick
        local position_new = VecAdd(self.position, VecScale(self.vel_current, delta))

        if self.secondary.active and self.hit_once then
            return
        end

        -- Hit detection and ballistics system
        local shell_radius = self.sprite.width / 2
        QueryRequire('large')
        QueryRequire("physical")
        local hit, hit_distance, normal, shape_initial = QueryRaycast(self.position, VecNormalize(VecSub(position_new, self.position)), VecLength(VecSub(position_new, self.position), shell_radius))
        if hit and not trigger_detonation then
            addToDebugTable(DEBUG_POSITIONS, {self.position, {1, 1, 0}})
            addToDebugTable(DEBUG_LINES, {self.position, position_new, {1, 0.2, 0.2}})
            dPrint("Hit detected.")

            self.hit_once = true

            if self.secondary.active then
                self.vel_current = Vec(0, 0, 0)
                return
            end

            local position_initial_hit = VecAdd(self.position, VecScale(VecNormalize(VecSub(position_new, self.position)), hit_distance))
            addToDebugTable(DEBUG_POSITIONS, {position_initial_hit, {1, 1, 1}})

            -- Guard clause: Check if ballistics is disabled to halt expensive computation
            if not GetBool("savegame.mod.simulate_ballistics") then
                shellDetonate(self, position_initial_hit)
                return
            end

            local material_initial = GetShapeMaterialAtPosition(shape_initial, (position_initial_hit))
            dPrint("Initial material is '"..material_initial.."'")

            -- Perform recursive check for materials encountered during this tick
            local hit_materials, hit_positions, reached_max_depth = getRecursiveMaterialsInRaycast(self.position, position_new, { position_initial_hit }, shell_radius, { material_initial }, { shape_initial }, 3)
            if hit_positions ~= nil then position_detonation = hit_positions[#hit_positions] else position_detonation = position_initial_hit end

            if reached_max_depth then
                shellDetonate(self, position_detonation)
                return
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

                if self.kinetic_energy >= pen_values.min_energy then
                    if (math.random() * 100) < pen_values.chance then
                        dPrint("Material '"..material.."' triggered detonation. (Unlucky roll)")
                        position_detonation = hit_positions[index]
                        trigger_detonation = true
                    else
                        dPrint("Material '"..material.."' was too weak to trigger detonation.")
                        -- self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * (MAT_PEN[material].absorb / 100))
                        self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * 1)
                        MakeHole(hit_positions[index], shell_radius + 1, shell_radius + 0.5, shell_radius, false)
                    end
                else
                    dPrint("Material '"..material.."' triggered detonation. (energy below threshold)")
                    position_detonation = hit_positions[index]
                    trigger_detonation = true
                end
            end

            -- QueryRaycast in the opposite direction to check if bottom material is impenetrable. Fixes fringe QueryRejectShape edge case.
            if not trigger_detonation then
                hit, hit_distance, normal, shape_initial = QueryRaycast(position_new, VecNormalize(VecSub(self.position, position_new)), VecLength(VecSub(self.position, position_new), shell_radius))
                position_initial_hit = VecAdd(position_new, VecScale(VecNormalize(VecSub(self.position, position_new)), hit_distance))
                if hit then
                    local bottom_material = GetShapeMaterialAtPosition(shape_initial, (position_initial_hit))
                    dPrint("Bottom material detected as '"..bottom_material.."'")
                    if bottom_material == "rock" or bottom_material == "none" then
                        dPrint("Bottom material is impenetrable")
                        trigger_detonation = true
                    end
                end
            end

            dPrint("-------------")
        end

        if trigger_detonation then
            shellDetonate(self, position_detonation)
            return
        end

        self.vel_previous = VecCopy(self.vel_current)
        self.position = position_new
    end
end

function shellDetonate(self, pos)
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    self.state = SHELL_STATES.detonated

    addToDebugTable(DEBUG_POSITIONS, {pos, {1, 0.2, 0.2}})

    if GetBool("savegame.mod.simulate_dud") and math.random(100) <= 2 then
        MakeHole(pos, 5, 2, 1, false)
        return
    end

    local hole = variant.size_makehole
    MakeHole(pos, hole[1], hole[2], hole[3], false)

    if variant.size_explosion > 0 then
        Explosion(pos, variant.size_explosion)
    end
end

function shellFire(self)
    DEBUG_POSITIONS = {}
    DEBUG_LINES = {}

    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    dPrint("--- Firing shell ("..values.name..") ---")

    if assertTableKeys(variant, "secondary", "timer") then
        self.secondary.timer = variant.secondary.timer
    end

    if self.inaccuracy > 0 then
        local rotation = QuatEuler(0, 360 * math.random(), 0)
        local distance = Vec(self.inaccuracy * math.random(), 0, 0)

        local transform = Transform(VecCopy(self.destination), rotation)
        self.destination = TransformToParentPoint(transform, distance)
    end

    self.position = VecAdd(self.destination, Vec(0, 1000, 0))
    -- self.position = VecAdd(self.destination, Vec(0, 2, 0))

    self.state = SHELL_STATES.in_flight
    if self.flight_time < 0.2 then
        self.state = SHELL_STATES.active
    end

    local snd_fire = LoadSound("MOD/snd/"..values.sounds.fire..".ogg")
    PlaySound(snd_fire, VecAdd(GetPlayerPos(), Vec(100, 0, 100)), 20)
end