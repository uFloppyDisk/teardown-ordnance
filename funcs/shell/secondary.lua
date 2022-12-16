local function tick_secondary_smoke(self, delta, variant)
    local timer_ratio = self.secondary.timer / variant.secondary.timer
    local radius = variant.secondary.radius
    -- local radius_master = clamp(radius - (radius * (1 - timer_ratio)), radius - (radius / 3), radius)

    local radius_master = radius
    if timer_ratio < 0.3 then
        radius_master = radius_master - (radius_master * (1 - (timer_ratio / 0.3)))
    end

    -- Smoke plume
    if (timer_ratio > 0.2 and timer_ratio < 0.99) and math.random() > 0.8 then
        ParticleReset()
        ParticleType('plain')
        ParticleAlpha(1, 0, "smooth", 0, 0.95)
        ParticleStretch(1)
        ParticleCollide(0, 1, "easein", 0.1, 1)

        local segments = 8;
        for i = 0, 360, (360 / segments) do
            if math.random() > 0.9 then
                break
            end

            local particle_radius1 = math.random() * 0.5
            local particle_radius2 = (math.random() * 0.2) + particle_radius1
            ParticleRadius(particle_radius1, particle_radius2, "easein", 0.02, 0.95)

            local rand_gravity = math.random() * 0.05
            ParticleGravity(0, rand_gravity, "linear", 0, 1)

            local rotation = QuatEuler(0, (i + (math.random() * (360 / segments))), 0)
            local transform = Transform(self.position, rotation)

            local vel_rand = math.random() * 0.2
            local vel = Vec(vel_rand, 0, 0)
            vel = TransformToParentVec(transform, vel)

            local position_spawn = TransformToParentPoint(transform, Vec(radius_master * clamp(1 + math.random(), 1, 1.3), 0, 0))

            SpawnParticle(position_spawn, vel, variant.secondary.timer)
        end
    end

    -- Smoke Body
    if timer_ratio == 1 or math.random() > 0.8 then
        local rotation = QuatEuler(0, 360 * math.random(), 0)
        local distance = Vec((radius_master * 0.8) * math.random(), 0, 0)
        local transform = Transform(VecCopy(self.position), rotation)
        local position_spawn = TransformToParentPoint(transform, distance)

        ParticleReset()
        ParticleType('plain')
        ParticleRadius(radius_master * clamp(math.random(), 0.3, 0.7))
        ParticleAlpha(1, 0, "smooth", 0, 0.8)
        ParticleGravity(0.01)
        -- ParticleStretch(1)
        -- ParticleCollide(0, 1, "easein", 0.1, 1)
        ParticleCollide(0)

        SpawnParticle(position_spawn, Vec(0, 0.02, 0), variant.secondary.timer - (variant.secondary.timer / 4))

        -- High Smoke
        if math.random() > 0.5 then
            rotation = QuatEuler(0, 360 * math.random(), 0)
            distance = Vec((radius_master * 0.2) * math.random(), 0, 0)
            transform = Transform(VecCopy(self.position), rotation)
            position_spawn = TransformToParentPoint(transform, distance)

            ParticleRadius(radius_master * clamp(math.random(), 0.3, 0.5))
            ParticleCollide(0.2)
            SpawnParticle(position_spawn, Vec(0, 0.02, 0), variant.secondary.timer - (variant.secondary.timer / 4))
        end
    end

    -- Smoke Mushroom
    if timer_ratio < 1 and math.random() > 0.9 then
        -- local particle_radius = clamp(radius - (radius * timer_ratio), radius / 2, (radius - (radius / 2.4)))
        local particle_radius = radius - (math.random() * (radius * 0.25))

        ParticleReset()
        ParticleType('plain')
        -- ParticleRadius(particle_radius - (math.random() * (radius / 3)))
        ParticleRadius(particle_radius * 0.9, particle_radius, "easeout", 0.001, 0.99)
        ParticleAlpha(1, 0, "smooth", 0, 0.8)
        ParticleGravity(-0.07)
        ParticleStretch(1)
        -- ParticleCollide(0, 1, "easein", 0.1, 1)
        ParticleCollide(0)

        SpawnParticle(VecAdd(self.position, Vec(0, 0, 0)), Vec(0, radius * 0.2, 0), variant.secondary.timer * 0.5)

        -- Smoke Volume Assist
        -- ParticleRadius(radius * 0.2)
        -- SpawnParticle(VecAdd(self.position, Vec(0, 0, 0)), Vec(0, radius * 0.02, 0), variant.secondary.timer)
    end
end

local function tick_secondary_parachuted_flare(self, delta, variant)
    local timer_ratio = self.secondary.timer / variant.secondary.timer
    self.secondary.intensity = clamp((self.secondary.intensity + (5 * math.random(-1, 1))), 950, 1050)

    if timer_ratio <= 0.15 then
        self.secondary.intensity = self.secondary.intensity * ((timer_ratio) / 0.15)
    end

    dWatch("shell(SECONDARY_INTENSITY)", self.secondary.intensity)

    PointLight(self.position, 1, 1, 1, self.secondary.intensity)

    if math.random() <= 0.5 then return end

    -- Spawn smoke particles
    ParticleReset()
    ParticleRadius(0.3 * math.random())
    ParticleAlpha(1.0, 0.0, "smooth", 0.05, 0.5)
    ParticleStretch(0)

    local particle_origin = VecAdd(self.position, Vec(0, (self.sprite.width * self.sprite.scaling_factor), 0))
    self.secondary.particle_spread[1] = clamp(self.secondary.particle_spread[1] + (0.04 * math.random(-1, 1)), -0.5, 0.5)
    self.secondary.particle_spread[3] = clamp(self.secondary.particle_spread[3] + (0.04 * math.random(-1, 1)), -0.5, 0.5)

    SpawnParticle(VecAdd(particle_origin, self.secondary.particle_spread), Vec(-0.15, 0, 0.05), 20)
end

local function tick_secondary_cluster(self, delta, variant)
    local sprite = LoadSprite("MOD/img/".."bomblet"..".png")

    local sounds = {
        "155mm_shell_cluster_submunition_explode_01",
        "155mm_shell_cluster_submunition_explode_02",
    }

    local function init_sub()
        self.secondary.submunitions = {}

        local amount_submunitions = CONFIG_getConfValue("SHELL_SEC_CLUSTER_BOMBLET_AMOUNT") or 50
        for i = 1, amount_submunitions, 1 do
            local rotation = QuatEuler(0, math.random() * 360, math.random() * -160 + 80)
            local transform = Transform(self.position, rotation)

            local sub = objectNew({
                transform = TransformCopy(transform),
                velocity = Vec(math.random() * 10 + 5, 0, 0)
            }, DEFAULT_SUBMUNITION)

            local vel_to_sub = TransformToLocalVec(sub.transform, VecNormalize(self.secondary.inertia))
            vel_to_sub = VecScale(vel_to_sub, VecLength(self.secondary.inertia))
            sub.velocity = VecAdd(sub.velocity, vel_to_sub)

            table.insert(self.secondary.submunitions, sub)
        end

        dWatch("SUBMUNITIONS(amount)", #self.secondary.submunitions)
    end

    local function tick_sub(sub)
        local gravity = math.abs(G_VEC_GRAVITY[2])
        local world_down = TransformToLocalVec(sub.transform, Vec(0, -1, 0))

        sub.velocity = VecAdd(sub.velocity, VecScale(world_down, gravity * delta))

        local position_new = TransformToParentPoint(sub.transform, VecScale(sub.velocity, delta))
        local transform_new = Transform(position_new, sub.transform.rot)

        local look_rotation = QuatRotateQuat(QuatLookAt(sub.transform.pos, GetCameraTransform().pos), QuatAxisAngle(Vec(0, 0, 1), 180))
        local draw_pos = Transform(sub.transform.pos, look_rotation)
        DrawSprite(sprite, draw_pos, 0.0635, 0.0635, 0.4, 0.4, 0.4, 1, true, false)

        local hit, hit_distance = QueryRaycast(sub.transform.pos, VecNormalize(VecSub(position_new, sub.transform.pos)), VecLength(VecSub(position_new, sub.transform.pos)))
        if not hit then
            addToDebugTable(DEBUG_LINES, {sub.transform.pos, transform_new.pos, getRGBA(COLOUR["orange"], 0.15)})

            return transform_new
        end

        local position_hit = VecAdd(sub.transform.pos, VecScale(VecNormalize(VecSub(position_new, sub.transform.pos)), hit_distance))

        addToDebugTable(DEBUG_LINES, {sub.transform.pos, position_hit, COLOUR["orange"]})
        addToDebugTable(DEBUG_POSITIONS, {position_hit, COLOUR["white"]})

        -- Random roll if submunition is a dud
        if CONFIG_getConfValue("G_SIMULATE_UXO") and math.random(100) <= 2 then
            dPrint("Submunition at index "..index.." is a dud.")
            MakeHole(position_hit, 0.5, 0.1, 0, false)

            return nil
        end

        Explosion(position_hit, 1)
        MakeHole(position_hit, 3, 1.3, 0.5, false)

        ParticleReset()
        ParticleRadius(1, 2.5, "smooth", 0, 0.2)
        ParticleAlpha(0.5, 0.0, "smooth", 0.05, 0.5)
        ParticleStretch(0)
        ParticleCollide(0)

        SpawnParticle(position_hit, Vec(-0.1, 0.03, 0.02), math.random() * 7 + 3)

        return nil
    end


    if self.secondary.timer < 0 then
        self.state = shell_states.DETONATED
        self.secondary.active = false
        return
    end

    if not assertTableKeys(self, "secondary", "submunitions") then
        init_sub()
    end

    if #self.secondary.submunitions == 0 then
        self.state = shell_states.DETONATED
        self.secondary.active = false
        return
    end

    for index, sub in ipairs(self.secondary.submunitions) do
        local transform_new = tick_sub(sub)

        sub.transform = transform_new

        if transform_new == nil then
            table.remove(self.secondary.submunitions, index)
        end
    end
end

local function tick_secondary_incendiary(self, delta, variant)
    local function init_sub()
        -- self.secondary.inertia = VecScale(self.secondary.inertia, 0.5)
        self.secondary.submunitions = {}

        local amount_submunitions = CONFIG_getConfValue("SHELL_SEC_CLUSTER_BOMBLET_AMOUNT") or 50
        for i = 1, amount_submunitions, 1 do
            local rotation = QuatEuler(0, math.random() * 360, math.random() * -160 + 80)
            local transform = Transform(self.position, rotation)

            local sub = objectNew({
                transform = TransformCopy(transform),
                velocity = Vec(math.random() * 20 + 10, 0, 0),
                ignite_delay = math.random() * 0.1,
                smoke_radius = math.random() * 1 + 0.5,
            }, DEFAULT_SUBMUNITION)

            local vel_to_sub = TransformToLocalVec(sub.transform, VecNormalize(self.secondary.inertia))
            vel_to_sub = VecScale(vel_to_sub, VecLength(self.secondary.inertia))
            sub.velocity = VecAdd(sub.velocity, vel_to_sub)

            table.insert(self.secondary.submunitions, sub)
        end

        dWatch("SUBMUNITIONS(amount)", #self.secondary.submunitions)
    end

    local function tick_sub(sub)
        local timer_ratio = self.secondary.timer / variant.secondary.timer
        local timer_elapsed = variant.secondary.timer - self.secondary.timer

        local gravity = math.abs(G_VEC_GRAVITY[2])
        local wind = Vec(-0.4, 0.03, 0.07)
        local world_down = TransformToLocalVec(sub.transform, Vec(0, -1, 0))

        sub.velocity = VecAdd(sub.velocity, VecScale(world_down, gravity * delta))
        if VecLength(sub.velocity) > 50 then
            sub.velocity = VecSub(sub.velocity, VecScale(VecNormalize(sub.velocity), 40 * delta))
        end

        local position_new = TransformToParentPoint(sub.transform, VecScale(sub.velocity, delta))
        local transform_new = Transform(position_new, sub.transform.rot)

        if IsPointInWater(position_new) then return nil end

        local hit, hit_distance, normal = QueryRaycast(sub.transform.pos, VecNormalize(VecSub(position_new, sub.transform.pos)), VecLength(VecSub(position_new, sub.transform.pos)))
        if not hit then
            if timer_elapsed < sub.ignite_delay then return transform_new end

            local step = 1 / 5
            local cur = 0
            repeat
                local rand_radius = sub.smoke_radius - (math.random() * 1)
                ParticleReset()
                ParticleRadius(rand_radius, rand_radius, "smooth", 0, 0)
                ParticleAlpha(1, 0, "smooth")
                ParticleColor(1, 1, 1, 1, 1, 1)
                ParticleStretch(1)
                ParticleCollide(1)

                local pos = VecLerp(sub.transform.pos, transform_new.pos, cur)

                SpawnParticle(pos, wind, math.random() * 10 + (clamp(timer_elapsed, 0, 1) * 20))

                -- SpawnParticle(
                --     pos, wind,
                --     math.random()
                --     * clamp(mapToRange(timer_ratio, 0.1, 0.2, 0, 5), 0, 5)
                --     + clamp(mapToRange(timer_ratio, 0, 0.05, 0, 5), 0, 5)
                -- )

                cur = cur + step
            until cur >= 1

            PointLight(sub.transform.pos, getUnpackedRGBA({1, 0.82, 0.639}, 2))
            ParticleReset()
            ParticleRadius(0.1, 1, "smooth")
            ParticleAlpha(1, 0, "smooth")
            ParticleStretch(1)
            ParticleCollide(1)
            ParticleColor(
                1, 0.82, 0.639
                -- 1, 0.706, 0.024
            )
            ParticleEmissive(10, 0, "smooth", 0, 0.5)
            SpawnParticle(sub.transform.pos, wind, 0.25)

            addToDebugTable(DEBUG_LINES, {sub.transform.pos, transform_new.pos, getRGBA(COLOUR["orange"], 0.15)})

            return transform_new
        end

        local position_hit = VecAdd(sub.transform.pos, VecScale(VecNormalize(VecSub(position_new, sub.transform.pos)), hit_distance))

        addToDebugTable(DEBUG_LINES, {sub.transform.pos, position_hit, COLOUR["orange"]})
        addToDebugTable(DEBUG_POSITIONS, {position_hit, COLOUR["white"]})

        local step = 1 / 3
        local cur = 0
        repeat
            local radius = math.random() * 2 + 1
            ParticleReset()
            ParticleRadius(radius, radius + 4.5, "smooth", 0, 0.8)
            ParticleAlpha(0.5, 0.0, "smooth", 0.05, 0.5)
            ParticleStretch(0)
            -- ParticleCollide(0.02)

            SpawnParticle(position_hit, wind, math.random() * 30 + 20)

            cur = cur + step
        until cur >= 1

        local transform_spawn = Transform(VecLerp(position_hit, sub.transform.pos, 0.5), sub.rotation)

        body = Spawn("MOD/assets/white_phosphorus.xml", transform_spawn)[2]

        SetBodyDynamic(body, true)
        SetBodyActive(body, true)

        local direction = VecNormalize(VecCopy(sub.velocity))
        local velocity = VecSub(direction, VecScale(normal, VecDot(normal, direction) * 2))
        SetBodyVelocity(body, VecScale(velocity, 15))
        -- ApplyBodyImpulse(body, transform_spawn.pos, Vec(100, 0, 0))

        SpawnFire(position_hit)
        SpawnFire(transform_spawn.pos)
        PointLight(position_hit, 1, 0.851, 0.714, 100)

        if math.random() > 0.5 then
            MakeHole(position_hit, 0.15, 0.05, 0, false)
        end

        return nil
    end

    if self.secondary.timer < 0 then return true end

    if not assertTableKeys(self, "secondary", "submunitions") then
        init_sub()
    end

    if #self.secondary.submunitions == 0 then return true end

    for index, sub in ipairs(self.secondary.submunitions) do
        local transform_new = tick_sub(sub)

        sub.transform = transform_new

        if transform_new == nil then
            table.remove(self.secondary.submunitions, index)
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
        self.secondary.inertia = self.vel_current

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

        SpawnParticle(particle_origin, Vec(-0.1, 0, 0.02), 20)
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
    if self.secondary.timer < 0 then return true end

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