function manage_bodies(body)
    local function manage_smoke(shapes)
        if IsShapeBroken(shapes[1]) then return true end

        local pos = VecLerp(GetBodyBounds(body.handle), 0.5)
        local velocity = GetBodyVelocity(body.handle)
        PointLight(pos, 1, 0.4668, 0.1229, 0.7)

        if IsPointInWater(pos) then return false end

        if not IsBodyActive(body.handle) then
            if math.random() > 0.05 then return false end
        end

        -- SpawnFire(pos)

        do
            ParticleReset()

            local radius = mapToRange(math.random(), 0, 1, 0.05, 0.2)
            if math.random() > 0.8 then radius = radius * mapToRange(math.random(), 0, 1, 1.5, 5) end
            ParticleRadius(radius / 2, radius * (mapToRange(math.random(), 0, 1, 1, 1.5)), "linear")

            ParticleType("plain")
            ParticleCollide(0)
            ParticleStretch(10)

            local iterations = 4
            for i = 0, iterations, 1 do
                ParticleAlpha(math.random() * 0.6, 0, 'linear', 0, 0.7)

                local spawn_pos = VecLerp(
                    VecAdd(pos, VecScale(velocity, 1 / 60)),
                    VecAdd(pos, VecScale(velocity, -1 / 60)),
                    i / iterations
                )

                SpawnParticle(spawn_pos, G_VEC_WIND, mapToRange(math.random(), 0, 1, 5, 30))
            end
        end

        if math.random() > 0.05 then return false end
    end

    local function manage_incendiary(shapes)
        if IsShapeBroken(shapes[1]) then return true end

        local pos = VecLerp(GetBodyBounds(body.handle), 0.5)
        PointLight(pos, 1, 0.706, 0.42, 10)

        if IsPointInWater(pos) then return false end

        if not IsBodyActive(body.handle) then
            if math.random() > 0.05 then return false end
        end

        SpawnFire(pos)

        if math.random() < 0.20 then
            ParticleReset()

            local radius = math.random() * 0.60 + 0.15
            ParticleRadius(radius, radius + (math.random() * 3), "linear")

            ParticleType("plain")
            ParticleCollide(0)
            ParticleStretch(1)

            SpawnParticle(pos, G_VEC_WIND, math.random() * 10 + 10)
        end

        if math.random() > 0.05 then return false end

        QueryRejectBody(body.handle)
        local hit, pos_fire = QueryClosestPoint(pos, 5)
        if not hit then return false end

        addToDebugTable(DEBUG_POSITIONS, { pos_fire, COLOUR["orange"] })
        SpawnFire(pos_fire)
    end

    if not IsHandleValid(body.handle) then return true end

    local disp_manage = {
        ["IN"] = manage_incendiary,
        ["SM"] = manage_smoke
    }

    local shapes = GetBodyShapes(body.handle)
    return disp_manage[body.type](shapes)
end

function manage_bodies_cleanup()
    for i, body in ipairs(BODIES) do
        if not body.valid then
            dPrint("Removing body " .. body.handle)
            table.remove(BODIES, i)
        end
    end
end

function trigger_secondary(self, parameters, detonate)
    local isDetonated = true

    if assertTableKeys(parameters, "trigger_height") then
        if not detonate then isDetonated = false end

        if parameters.trigger_height < self.distance_ground then
            return isDetonated
        end

        self.secondary.active = true
        self.secondary.inertia = VecCopy(self.vel_current)

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

        SpawnParticle(particle_origin, G_VEC_WIND, 20)
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

function tick_secondary(self, delta, variant)
    if self.secondary.timer <= 0 then return true end

    local disp_tick_secondary = {
        ["SM"] = tick_secondary_smoke,
        ["PF"] = tick_secondary_parachuted_flare,
        ["CL"] = tick_secondary_cluster,
        ["IN"] = tick_secondary_incendiary,
    }

    disp_tick_secondary[variant.id](self, delta, variant)

    -- local success, result = pcall(disp_tick_secondary[variant.id], self, delta, variant)

    -- if not success then
    --     dPrint("Shell secondary handler function is not defined.")
    --     return true
    -- end

    -- if result then return true end

    self.secondary.timer = self.secondary.timer - delta
end
