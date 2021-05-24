Shell = {}

function Shell:new(type, flight_time, sprite, snd_whistle, position, vel_initial, vel_current, vel_direction)
    local object = {
        active = false,
        queued = false,
        in_flight = false,
        detonated = false,

        type = type or 1,
        flight_time = flight_time or (1.0001 * GetFloat("savegame.mod.flight_time")),

        sprite = sprite,
        snd_whistle = snd_whistle,

        destination = Vec(0, 0, 0),
        position = position or Vec(0, 0, 0),
        vel_initial = vel_initial or Vec(0, 0, 0),
        vel_current = vel_current or Vec(0, 0.001, 0),
        vel_direction = vel_direction or Vec(0, 0, 0)
    }

    setmetatable(object, self)
    self.__index = self

    return object
end

function Shell:setDest(pos)
    self.destination = pos
end

function Shell:draw(pos)
    local rotation = QuatRotateQuat(QuatLookAt(self.position, GetCameraTransform().pos), QuatAxisAngle(Vec(0,0,1), 180))
    local transform_pos = Transform(pos, rotation)
    DrawSprite(self.sprite, transform_pos, 0.3, 1.59, 0.4, 0.4, 0.4, 1, true, false)
end

function Shell:tick(delta)
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

            if math.random(100) <= 2 then
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

        self:draw(self.position)
        self.position = position_new
    end
end

function Shell:fire()
    print("Firing shell...")
    local y = 1000 + math.random(25)
    self.position = VecAdd(self.destination, Vec(0, y, 0))

    self:draw(self.position)
    self.in_flight = true

    PlaySound(SND_SHELL["155mm_fire_far"], VecAdd(GetPlayerPos(), Vec(100, 0, 100)), 20)
end