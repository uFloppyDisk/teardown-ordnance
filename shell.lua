DEFAULT_SHELL = {
    active = false,
    queued = false,
    in_flight = false,
    detonated = false,

    type = "155mm",
    flight_time = GetFloat("savegame.mod.flight_time"),
    inaccuracy = GetFloat("savegame.mod.shell_inaccuracy"),

    sprite = nil,
    snd_whistle = 1,

    destination = nil,
    position = nil,
    vel_initial = nil,
    vel_current = nil,
    vel_direction = nil
}

function Shell_new(new)
    local base = Shell_copy(DEFAULT_SHELL)
    for key, value in pairs(new) do
        base[key] = value
    end

    return base
end

function Shell_copy(object)
    local copy
    if type(object) == 'table' then
        copy = {}
        for key, value in pairs(object) do
            copy[Shell_copy(key)] = Shell_copy(value)
        end
        setmetatable(copy, Shell_copy(getmetatable(object)))
    else
        copy = object
    end
    return copy
end

function Shell_draw(self, pos)
    local rotation = QuatRotateQuat(QuatLookAt(self.position, GetCameraTransform().pos), QuatAxisAngle(Vec(0,0,1), 180))
    local transform_pos = Transform(pos, rotation)
    DrawSprite(self.sprite, transform_pos, 0.3, 1.59, 0.4, 0.4, 0.4, 1, true, false)
end

function Shell_tick(self, delta)
    watch("Flight Time", self.flight_time)
    if self.in_flight then
        self.flight_time = self.flight_time - delta

        if self.flight_time <= 0 then
            self.in_flight = false
            self.active = true
        end
    end

    if self.active then
        self.distance_ground = VecLength(VecSub(self.position, self.destination))
        local distance_player = VecLength(VecSub(self.position, GetPlayerPos()))
        watch("Distance to Ground", self.distance_ground)

        if (self.distance_ground > 2000) then
            self.detonated = true
            self.active = false
            return
        end

        if (self.distance_ground < 500) then
            local volume = clamp(150 - (clamp(distance_player, 0, 500) / 5), 0, 100)
            watch("Volume", volume)
            PlayLoop(self.snd_whistle, self.position, 100)
        end

        self.vel_current = VecAdd(self.vel_current, (VecScale(G_VEC_GRAVITY, delta)))
        local position_new = VecAdd(self.position, VecScale(self.vel_current, delta))
        local hit, distance = QueryRaycast(self.position, VecNormalize(VecSub(position_new, self.position)), VecLength(VecSub(position_new, self.position)))
        if hit then
            position_hit = VecAdd(self.position, VecScale(VecNormalize(VecSub(position_new, self.position)), distance))

            self.detonated = true
            self.active = false

            if GetBool("savegame.mod.simulate_dud") and math.random(100) <= 2 then
                MakeHole(position_hit, 5, 2, 1)
                return
            end

            MakeHole(position_hit, 50, 20, 5)
            Explosion(position_hit, 4)
        end

        ParticleReset()
        ParticleRadius(0.2)
        ParticleStretch(1.0)
        SpawnParticle(VecAdd(self.position, Vec(0, -0.79, 0)), Vec(0, -1, 0), 0.1)

        Shell_draw(self, self.position)
        self.position = position_new
    end
end

function Shell_fire(self)
    print("Firing shell...")

    local pos_x = 0
    local pos_z = 0

    if self.inaccuracy > 0 then
        local magnitude = self.inaccuracy
        pos_x = magnitude * math.random() * (math.random() >= 0.5 and 1 or -1)
        pos_z = magnitude * math.random() * (math.random() >= 0.5 and 1 or -1)
        print("Shell inaccuracy is greater than 0. Sending shell to coord offset X "..pos_x.." Z "..pos_z)
    end

    self.position = VecAdd(self.destination, Vec(pos_x, 1000, pos_z))
    -- self.position = VecAdd(self.destination, Vec(0, 2, 0))

    Shell_draw(self, self.position)
    self.in_flight = true

    PlaySound(SND_SHELL["155mm_fire_far"], VecAdd(GetPlayerPos(), Vec(100, 0, 100)), 20)
end