SHELL_VALUES = {
    [1] = {
        name = "155mm Howitzer",
        caliber = "155mm",
        types = {
            HE = {
                size_explosion = 4,
                size_makehole = {50, 20, 5}
            }
        },
        sprite = {
            img = "155mm_HE",
            scaling_factor = 5.33,
            width = 0.155 * 2
        },
        sounds = {
            whistle = {
                "155mm_whistle_1",
                "155mm_whistle_2",
                "155mm_whistle_3"
            },
            fire = "155mm_fire"
        }
    },
    [2] = {
        name = "60mm Mortar",
        caliber = "60mm",
        types = {
            HE = {
                size_explosion = 1.5,
                size_makehole = {35, 15, 3}
            }
        },
        sprite = {
            img = "60mm_HE",
            scaling_factor = 4.08,
            width = 0.06 * 2
        },
        sounds = {
            whistle = "60mm_whistle",
            fire = "60mm_fire"
        }
    }
}

DEFAULT_SHELL = {
    active = false,
    queued = false,
    in_flight = false,
    detonated = false,

    type = 1,
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
    local values = SHELL_VALUES[self.type]
    local rotation = QuatRotateQuat(QuatLookAt(self.position, GetCameraTransform().pos), QuatAxisAngle(Vec(0,0,1), 180))
    local transform_pos = Transform(pos, rotation)

    local width = values.sprite.width
    local height = values.sprite.width * values.sprite.scaling_factor

    DrawSprite(self.sprite, transform_pos, width, height, 0.4, 0.4, 0.4, 1, true, false)
end

function Shell_tick(self, delta)
    watch("Flight Time", self.flight_time)

    local values = SHELL_VALUES[self.type]

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

            local hole = values.types.HE.size_makehole
            MakeHole(position_hit, hole[1], hole[2], hole[3])
            Explosion(position_hit, values.types.HE.size_explosion)
        end

        ParticleReset()
        ParticleRadius(0.2)
        ParticleStretch(1.0)
        SpawnParticle(VecAdd(self.position, Vec(0, values.sprite.width * values.sprite.scaling_factor, 0)), Vec(0, -1, 0), 0.1)

        Shell_draw(self, self.position)
        self.position = position_new
    end
end

function Shell_fire(self)
    local values = SHELL_VALUES[self.type]

    print("Firing shell ("..values.name..")")

    if self.inaccuracy > 0 then
        local original = VecCopy(self.destination)
        local rotation = QuatEuler(0, 360 * math.random(), 0)
        local distance = Vec(self.inaccuracy * math.random(), 0, 0)

        local transform = Transform(original, rotation)
        self.destination = TransformToParentPoint(transform, distance)
    end

    self.position = VecAdd(self.destination, Vec(0, 1000, 0))
    -- self.position = VecAdd(self.destination, Vec(0, 2, 0))

    -- Shell_draw(self, self.position)
    self.in_flight = true

    local snd_fire = LoadSound("MOD/snd/"..values.sounds.fire..".ogg")
    PlaySound(snd_fire, VecAdd(GetPlayerPos(), Vec(100, 0, 100)), 20)
end