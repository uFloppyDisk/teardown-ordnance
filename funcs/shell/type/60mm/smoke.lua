function tick_secondary_smoke(self, delta, variant)
    local timer_ratio = self.secondary.timer / variant.secondary.timer

    local velocity = 1.25

    local function init_sub()
        self.secondary.submunitions = {}

        local amount_submunitions = FdRound((CfgGetValue("SHELL_SEC_CLUSTER_BOMBLET_AMOUNT") or 50))
        local pitch = { min = 10, max = 80 }
        local pitch_ratio_min = pitch.min / pitch.max

        local position_origin = VecAdd(self.position, Vec(0, 0.2, 0))
        for i = 1, amount_submunitions, 1 do
            local random_pitch = FdMapToRange(math.random(), 0, 1, pitch.min, pitch.max)
            local rotation = QuatEuler(0, math.random() * 360, random_pitch)
            local transform = Transform(position_origin, rotation)

            local sub = FdObjectNew({
                transform = TransformCopy(transform),
                velocity = Vec(FdMapToRange(math.random(), 0, 1, 10, 25), 0, 0)
            }, DEFAULT_SUBMUNITION)

            FdAddToDebugTable(DEBUG_POSITIONS, { transform.pos, FdGetRGBA(COLOUR["white"]) })
            FdAddToDebugTable(DEBUG_LINES, { position_origin, transform.pos, FdGetRGBA(COLOUR["white"]) })

            local vel_to_sub = TransformToLocalVec(sub.transform, VecNormalize(self.secondary.inertia))
            vel_to_sub = VecScale(vel_to_sub, VecLength(self.secondary.inertia))
            sub.velocity = VecAdd(sub.velocity, vel_to_sub)

            sub.body = Spawn("MOD/assets/white_phosphorus_small.xml", transform)[2]
            table.insert(BODIES, {
                valid = true,
                created_at = ELAPSED_TIME,
                type = "SM",
                handle = sub.body,
                ttl = FdMapToRange(math.random(), 0, 1, 0.3, 2) * FdClamp(FdMapToRange(
                    random_pitch / pitch.max,
                    pitch_ratio_min, 0.8,
                    1, 0.01
                ), 0.01, 1)
            })

            SetBodyDynamic(sub.body, true)
            SetBodyActive(sub.body, true)

            SetBodyVelocity(
                sub.body,
                VecScale(
                    VecNormalize(TransformToParentVec(sub.transform, Vec(1, 0, 0))),
                    VecLength(sub.velocity) * FdClamp(FdMapToRange(
                        random_pitch / pitch.max,
                        0.5, 1,
                        0.5, 4
                    ), 0.5, 4)
                )
            )
        end
    end

    local function doIgnitedWP()
        ParticleReset()

        ParticleCollide(0)

        ParticleColor(1, 0.1718, 0)
        ParticleAlpha(1, 0, 'linear', 0, 0)
        ParticleEmissive(10)

        local particle_cfg = {
            VecCopy(self.position),
            VecCopy(self.secondary.velocity),
            0.45
        }

        local i = 6
        repeat
            local radius = variant.secondary.radius * FdMapToRange(math.random(), 0, 1, 0.3, 1)
            ParticleRadius(radius / 2, radius, 'linear', 0.1, 0.1)

            SpawnParticle(unpack(particle_cfg))

            i = i - 1
        until i <= 0

        ParticleColor(1, 1, 1)
        ParticleEmissive(0)
        ParticleRadius(variant.secondary.radius, variant.secondary.radius, "linear", 0, 0.01)
        SpawnParticle(self.position, G_VEC_WIND, variant.secondary.timer)
    end

    local function doBodyPrimary(radius, offset)
        radius = radius or variant.secondary.radius
        offset = offset or Vec(0, 0, 0)

        ParticleReset()

        ParticleCollide(0)

        ParticleColor(1, 1, 1)
        ParticleAlpha(1, 0, 'linear', 0, 0)

        local particle_cfg = {
            VecCopy(self.position),
            VecCopy(G_VEC_WIND),
            self.secondary.timer
        }

        for i = 0, 6, 1 do
            ParticleRadius(radius / FdMapToRange(math.random(), 0, 1, 1.1, 1.7), radius, 'linear', 0.02)
            SpawnParticle(unpack(particle_cfg))
        end
    end

    local function doMushroomHead(range, radius, angles, offset_position, offset_distance)
        range = range or velocity
        radius = radius or (variant.secondary.radius / 2)
        angles = angles or { 0, 0 }
        offset_position = offset_position or Vec(0, 0, 0)
        offset_distance = offset_distance or 0

        local position_original = VecAdd(VecCopy(self.position), offset_position)
        if offset_distance > 0 then
            local rot = QuatEuler(0, angles[2], 0)
            local transform = Transform(position_original, rot)
            position_original = TransformToParentPoint(transform, Vec(offset_distance, 0, 0))
        end

        ParticleReset()

        ParticleType("plain")

        ParticleRadius(radius, radius * 1.5, "linear", 0.005, 0.2)
        ParticleCollide(0)
        ParticleGravity(-range / variant.secondary.timer)

        ParticleColor(1, 1, 1)
        -- ParticleAlpha(1, 0, 'linear', 0, 0.995)

        local particle_cfg = {
            VecCopy(position_original),
            VecAdd(Vec(0, range, 0), G_VEC_WIND),
            self.secondary.timer
        }

        local instances = 6
        for i = 1, instances, 1 do
            local deg = 360 * (i / instances)
            local rot = QuatEuler(0, deg, angles[1] * -(math.cos(math.rad(deg - angles[2]))))
            local transform = Transform(position_original, rot)
            local position_spawn = TransformToParentPoint(transform, Vec((radius / 2), 0, 0))

            FdAddToDebugTable(DEBUG_POSITIONS, { position_spawn, FdGetRGBA(COLOUR["red"]) })
            FdAddToDebugTable(DEBUG_LINES, { position_original, position_spawn, FdGetRGBA(COLOUR["red"]) })

            local par_rot = 0.6 * (range / velocity)
            ParticleRotation(par_rot, 0)
            if (i >= (instances / 2)) then
                ParticleRotation(-par_rot, 0)
            end

            local j = 2
            for _ = 0, j, 1 do
                SpawnParticle(position_spawn, particle_cfg[2], particle_cfg[3])
            end
        end
    end

    -- Initialize smoke effects
    if not FdAssertTableKeys(self.secondary, "init") then
        self.secondary.init = true
        self.secondary.velocity = VecAdd(Vec(0, velocity, 0), G_VEC_WIND)

        PointLight(self.position, 1, 0.5447, 0.2005, 100)

        init_sub()

        doIgnitedWP()
        doBodyPrimary()

        doMushroomHead(nil, nil, nil, Vec(0, 6, 0))

        local heads = 10
        for i = 1, heads, 1 do
            local range = velocity * (i / heads)
            local size = variant.secondary.radius / FdMapToRange(math.random(), 0, 1, 2, 4)
            local pitch = math.random() * 40
            local heading = math.random() * 360
            local distance = math.random() * 5

            doMushroomHead(range, size, { pitch, heading }, nil, distance)
        end
    end

    if timer_ratio < 0.10 then return end

    if math.random() > 0.96 then
        doBodyPrimary(variant.secondary.radius * FdMapToRange(math.random(), 0, 1, 0.1, 0.5) * timer_ratio)
    end
end

function manage_smoke(shapes, body)
    if IsShapeBroken(shapes[1]) then return true end

    local bound_x, bound_y = GetBodyBounds(body.handle)
    local pos = VecLerp(bound_x, bound_y, 0.5)
    local velocity = GetBodyVelocity(body.handle)
    PointLight(pos, 1, 0.4668, 0.1229, 0.7)

    if IsPointInWater(pos) then return false end

    if not IsBodyActive(body.handle) then
        if math.random() > 0.05 then return false end
    end

    -- SpawnFire(pos)

    do
        ParticleReset()

        local radius = FdMapToRange(math.random(), 0, 1, 0.05, 0.2)
        if math.random() > 0.8 then radius = radius * FdMapToRange(math.random(), 0, 1, 1.5, 5) end
        ParticleRadius(radius / 2, radius * (FdMapToRange(math.random(), 0, 1, 1, 1.5)), "linear")

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

            SpawnParticle(spawn_pos, G_VEC_WIND, FdMapToRange(math.random(), 0, 1, 5, 30))
        end
    end

    if math.random() > 0.05 then return false end
    return false
end

