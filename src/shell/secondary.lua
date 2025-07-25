function PhysBodyTick(body)
    if not IsHandleValid(body.handle) then return true end

    local disp_manage = {
        ["IN"] = PhysBodyIncendiaryTick,
        ["SM"] = PhysBodySmokeTick,
        ["frag"] = PhysBodyFragTick,
    }

    if not FdAssertTableKeys(disp_manage, body.type) then return false end

    local shapes = GetBodyShapes(body.handle)
    return disp_manage[body.type](shapes, body)
end

function PhysBodyCleanup()
    for i, body in ipairs(BODIES) do
        if not body.valid then
            FdLog("Removing body " .. body.handle)
            table.remove(BODIES, i)
        end
    end
end

function ShellSecInit(self, parameters, detonate)
    local isDetonated = true

    if FdAssertTableKeys(parameters, "trigger_height") then
        if not detonate then isDetonated = false end

        if parameters.trigger_height < self.distance_ground then
            return isDetonated
        end

        self.secondary.active = true
        self.secondary.inertia = VecCopy(self.vel_current)

        self.vel_current = Vec(-0.1, -1, 0.02)

        if FdAssertTableKeys(parameters, "trigger_sound") then
            local volume = 90
            if FdAssertTableKeys(parameters, "trigger_sound_volume") then
                volume = parameters.trigger_sound_volume
            end

            PlaySound(parameters.trigger_sound, self.position, volume)
        end

        ParticleReset()

        if FdAssertTableKeys(parameters, "particle_radius") then
            ParticleRadius(parameters.particle_radius)
        else
            ParticleRadius(2)
        end

        ParticleAlpha(1.0, 0.0, "smooth", 0.05, 0.9)
        ParticleStretch(0)

        local particle_origin = VecAdd(self.position, Vec(0, self.sprite.width * self.sprite.scaling_factor, 0))

        SpawnParticle(particle_origin, G_VEC_WIND, 20)
    end

    if FdAssertTableKeys(parameters, "trigger_detonate") then
        isDetonated = false

        if detonate then
            self.secondary.active = true
            self.vel_current = Vec(0, 0, 0)
        end
    end

    return isDetonated
end

function ShellSecTick(self, delta, variant)
    if self.secondary.timer <= 0 then return true end

    local disp_tick_secondary = {
        ["SM"] = ShellSecTickSmoke,
        ["PF"] = ShellSecTickFlare,
        ["CL"] = ShellSecTickCluster,
        ["IN"] = ShellSecTickIncendiary,
        ["M31A1"] = ShellSecTickM31A1,
    }

    local success, result = pcall(disp_tick_secondary[variant.id], self, delta, variant)

    if not success then
        FdLog("An error occurred while calling shell secondary tick function:\n\t\t" .. result)
        return true
    end

    if result == true then return true end

    self.secondary.timer = self.secondary.timer - delta
    return false
end
