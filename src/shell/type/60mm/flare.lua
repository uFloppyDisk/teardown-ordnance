---Flare shell tick entrypoint
---@param self Shell
---@param delta number
---@param variant any
function ShellSecTickFlare(self, delta, variant)
    self.position = VecAdd(self.position, VecScale(self.vel_current, delta))

    if QueryRaycast(self.position, Vec(0, -1, 0), 0.02) then
        self.vel_current = Vec(0, 0, 0)
    end

    local timer_ratio = self.secondary.timer / variant.secondary.timer
    local intensity = FdClamp((self.secondary.intensity + (math.random(10, 20) * math.random(-1, 1))), 900, 1100)

    if IsPointInWater(self.position) then
        intensity = intensity * 0.5
    end

    if math.random() <= 0.04 then
        intensity = intensity * 0.9
    end

    if timer_ratio <= 0.15 then
        intensity = intensity * ((timer_ratio) / 0.15)
    end

    self.secondary.intensity = intensity
    FdWatch("shell(SECONDARY_INTENSITY)", self.secondary.intensity)

    if timer_ratio <= 0.02 then return end
    if math.random() <= 0.5 then return end

    -- Spawn smoke particles
    ParticleReset()
    ParticleRadius(0.3 * math.random(), 0, 'easeout', 0, 0.5)
    ParticleAlpha(1.0, 0.0, "linear", 0.05, 0.5)
    ParticleStretch(0)

    local particle_origin = VecAdd(self.position, Vec(0, (self.sprite.width * self.sprite.scaling_factor), 0))
    self.secondary.particle_spread[1] = FdClamp(self.secondary.particle_spread[1] + (0.04 * math.random(-1, 1)), -0.5,
        0.5)
    self.secondary.particle_spread[3] = FdClamp(self.secondary.particle_spread[3] + (0.04 * math.random(-1, 1)), -0.5,
        0.5)

    SpawnParticle(VecAdd(particle_origin, self.secondary.particle_spread), Vec(-0.15, 0.08, 0.05), 7 + (13 * timer_ratio))
end
