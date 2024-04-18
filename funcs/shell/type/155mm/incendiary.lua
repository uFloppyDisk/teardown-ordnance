function tick_secondary_incendiary(self, delta, variant)
    local function init_sub()
        -- self.secondary.inertia = VecScale(self.secondary.inertia, 0.5)
        self.secondary.submunitions = {}

        local amount_submunitions = CONFIG_getConfValue("SHELL_SEC_CLUSTER_BOMBLET_AMOUNT") or 50
        for i = 1, amount_submunitions, 1 do
            local rotation = QuatEuler(0, math.random() * 360, math.random() * -160 + 80)
            local transform = Transform(self.position, rotation)

            local sub = objectNew({
                active = true,
                brightness = 2,
                transform = TransformCopy(transform),
                velocity = Vec(math.random() * 20 + 35, 0, 0),
                ignite_delay = math.random() * 0.1,
                smoke_radius = math.random() * 0.7 + 0.1,
            }, DEFAULT_SUBMUNITION)

            local vel_to_sub = TransformToLocalVec(sub.transform, VecNormalize(self.secondary.inertia))
            vel_to_sub = VecScale(vel_to_sub, VecLength(self.secondary.inertia))
            sub.velocity = VecAdd(sub.velocity, vel_to_sub)

            table.insert(self.secondary.submunitions, sub)
        end

        PointLight(self.position, 1, 0.706, 0.42, 600)

        dWatch("SUBMUNITIONS(amount)", #self.secondary.submunitions)
    end

    local function tick_sub(sub)
        local timer_ratio = self.secondary.timer / variant.secondary.timer
        local timer_elapsed = variant.secondary.timer - self.secondary.timer

        local gravity = math.abs(G_VEC_GRAVITY[2])
        local world_down = TransformToLocalVec(sub.transform, Vec(0, -1, 0))

        sub.velocity = VecAdd(sub.velocity, VecScale(world_down, gravity * delta))

        local velocity_magnitude = VecLength(sub.velocity)
        local drag_magnitude = 0.0125 * velocity_magnitude * velocity_magnitude
        local drag_vector = VecNormalize(VecScale(sub.velocity, -1))

        sub.velocity = VecAdd(sub.velocity, VecScale(drag_vector, drag_magnitude * delta))

        local position_new = TransformToParentPoint(sub.transform, VecScale(sub.velocity, delta))
        local transform_new = Transform(position_new, sub.transform.rot)

        if IsPointInWater(position_new) then return nil end

        local hit, hit_distance, normal = QueryRaycast(sub.transform.pos,
            VecNormalize(VecSub(position_new, sub.transform.pos)), VecLength(VecSub(position_new, sub.transform.pos)))
        if not hit then
            if timer_ratio < 0.5 then return nil end -- If WP has been deployed for too long without hitting anything, extinguish it

            addToDebugTable(DEBUG_LINES, { sub.transform.pos, transform_new.pos, getRGBA(COLOUR["orange"], 0.15) })

            ParticleReset()
            ParticleRadius(0.3, 0.1, "smooth")
            ParticleAlpha(1, 0, "smooth")
            ParticleStretch(1)
            ParticleCollide(0.01)
            ParticleColor(
                1, 1, 1,
                1, 0.706, 0.42
            )

            step = 1 / 5
            cur = 0
            repeat
                cur = cur + step

                local lerp_pos = VecLerp(sub.transform.pos, transform_new.pos, cur)

                ParticleEmissive(100 * cur)
                SpawnParticle(lerp_pos, Vec(0, 0, 0), 0.1)
            until cur >= 1

            PointLight(sub.transform.pos, getUnpackedRGBA({ 1, 0.706, 0.42 }, sub.brightness))

            if timer_ratio < 0.75 then return transform_new end -- Stop particle trail after some time

            ParticleReset()
            ParticleAlpha(1, 0, "smooth")
            ParticleColor(1, 1, 1, 1, 1, 1)
            ParticleStretch(1)
            ParticleCollide(0, 0.1, "linear", 0.5)

            local step = 1 / (math.floor(mapToRange(velocity_magnitude, 50, 150, 1, 5)))
            local cur = 0
            repeat
                local rand_radius = (sub.smoke_radius - (math.random() * (sub.smoke_radius / 2))) *
                    clamp(mapToRange(timer_elapsed, 0, 0.25, 0.4, 1), 0, 1)
                ParticleRadius(rand_radius, rand_radius, "smooth", 0, 0)

                local pos = VecLerp(sub.transform.pos, transform_new.pos, cur)

                SpawnParticle(pos, G_VEC_WIND, math.random() * 10 + (clamp(timer_elapsed, 0, 1) * 20))

                cur = cur + step
            until cur >= 1

            return transform_new
        end

        local position_hit = VecAdd(sub.transform.pos,
            VecScale(VecNormalize(VecSub(position_new, sub.transform.pos)), hit_distance))

        addToDebugTable(DEBUG_LINES, { sub.transform.pos, position_hit, COLOUR["orange"] })
        addToDebugTable(DEBUG_POSITIONS, { position_hit, COLOUR["white"] })

        ParticleReset()
        ParticleAlpha(0.5, 0.0, "smooth", 0.05, 0.5)
        ParticleStretch(0)
        ParticleCollide(0, 0.1, "constant", 0.2)

        local step = 1 / 1
        local cur = 0
        repeat
            local radius = math.random() * 2 + 1
            ParticleRadius(radius, radius + 4.5, "smooth", 0, 0.8)

            SpawnParticle(position_hit, G_VEC_WIND, math.random() * 30 + 20)

            cur = cur + step
        until cur >= 1

        if math.random() > 0 then
            MakeHole(position_hit, 0.5, 0.25, 0.125, false)
        end

        local transform_spawn = Transform(VecLerp(position_hit, sub.transform.pos, 0.25), sub.rotation)

        sub.body = Spawn("MOD/assets/white_phosphorus.xml", transform_spawn)[2]
        table.insert(BODIES, {
            valid = true,
            created_at = ELAPSED_TIME,
            type = "IN",
            handle = sub.body
        })

        SetBodyDynamic(sub.body, true)
        SetBodyActive(sub.body, true)

        SpawnFire(position_hit)
        SpawnFire(transform_spawn.pos)

        -- TODO - Introduce more bounce variation when surface normal closely matches submunition approach direction (i.e. when shells fall at a 90 degree angle)
        local direction = VecNormalize(VecSub(position_hit, sub.transform.pos))
        local reflected_direction = VecSub(direction, VecScale(normal, VecDot(normal, direction) * 2))
        reflected_direction = VecLerp(reflected_direction, normal, math.random() * 0.5)

        local velocity_wp = VecLength(sub.velocity) * (math.random() * 0.08 + 0.02)

        -- Reduce WP velocity if reflected direction is too close to normal
        velocity_wp = velocity_wp *
            clamp(mapToRange(VecLength(VecSub(reflected_direction, normal)), 0, 0.5, 0.25, 1), 0.25, 1)

        local cross_direction = VecCross(normal, reflected_direction)
        if math.random() < 0.5 then
            cross_direction = VecSub(cross_direction, VecScale(cross_direction, 2))
        end
        local send_direction = VecNormalize(VecLerp(reflected_direction, cross_direction, math.random() * 0.4))

        SetBodyVelocity(sub.body, VecScale(send_direction, velocity_wp))

        if math.random() > 0.66 then
            ParticleCollide(0)

            ParticleRadius(5, 7, "linear")
            SpawnParticle(VecLerp(position_hit, sub.transform.pos, 0.1), G_VEC_WIND, math.random() * 40 + 30)

            ParticleRadius(4, 1, "linear")
            ParticleColor(1, 0.82, 0.639)
            ParticleEmissive(1, 0, "linear", 0, 1)
            SpawnParticle(VecLerp(position_hit, sub.transform.pos, 0.1), G_VEC_WIND, 0.1)

            PointLight(VecLerp(position_hit, sub.transform.pos, 0.1), 1, 0.733, 0.471, math.random() * 200 + 150)
        end

        step = 1 / 5
        cur = 0
        repeat
            QueryRejectBody(sub.body)
            hit, point, normal, shape = QueryClosestPoint(transform_spawn.pos, 5)
            if not hit then break end

            addToDebugTable(DEBUG_POSITIONS, { point, COLOUR["orange"] })
            SpawnFire(point)

            QueryRejectShape(shape)

            cur = cur + step
        until cur >= 1

        return nil
    end

    if self.secondary.timer < 0 then return true end

    if not assertTableKeys(self, "secondary", "submunitions") then
        init_sub()
    end

    if #self.secondary.submunitions == 0 then return true end

    for index, sub in ipairs(self.secondary.submunitions) do
        if sub.active then
            local transform_new = tick_sub(sub)

            sub.transform = transform_new

            if transform_new == nil then
                sub.active = false
            end
        end
    end

    dWatch("SUBMUNITIONS(amount)", #self.secondary.submunitions)
end
