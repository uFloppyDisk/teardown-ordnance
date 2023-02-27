local function tick_secondary_smoke(self, delta, variant)
    local timer_ratio = self.secondary.timer / variant.secondary.timer

    local velocity = 2.5

    -- Temp settings stockpile
    -- ParticleGravity(1, 0, 'linear', 0.2)

    local function doIgnitedWP()
        ParticleReset()

        ParticleCollide(0)

        ParticleColor(1, 0.1718, 0)
        ParticleAlpha(1, 0, 'linear', 0, 0)
        ParticleEmissive(10)

        local particle_cfg = {
            VecCopy(self.position),
            VecCopy(self.secondary.velocity),
            0.33
        }

        local i = 6
        repeat
            local radius = variant.secondary.radius * mapToRange(math.random(), 0, 1, 0.3, 1)
            ParticleRadius(radius / 2, radius, 'linear', 0.1, 0.1)

            SpawnParticle(unpack(particle_cfg))

            i = i - 1
        until i <= 0

        ParticleColor(1, 1, 1)
        ParticleEmissive(0)
        ParticleRadius(variant.secondary.radius, variant.secondary.radius, "linear", 0, 0.01)
        SpawnParticle(self.position, G_VEC_WIND, variant.secondary.timer)
    end

    local function doBodyPrimary(radius)
        radius = radius or variant.secondary.radius

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
            ParticleRadius(radius / mapToRange(math.random(), 0, 1, 1.1, 1.7), radius, 'linear', 0.02)
            SpawnParticle(unpack(particle_cfg))
        end
    end

    local function doMushroomHead(range, radius, angles, offset_distance)
        range = range or velocity
        radius = radius or (variant.secondary.radius / 2)
        angles = angles or {0, 0}
        offset_distance = offset_distance or 0

        local position_original = VecCopy(self.position)
        if offset_distance > 0 then
            local rot = QuatEuler(0, angles[2], 0)
            local transform = Transform(position_original, rot)
            position_original = TransformToParentPoint(transform, Vec(offset_distance, 0, 0))
        end

        ParticleReset()

        ParticleType("plain")

        ParticleRadius(radius, radius * 1.5, "linear", 0.05, 0.2)
        ParticleCollide(0)
        ParticleGravity(-range / variant.secondary.timer)

        ParticleColor(1, 1, 1)

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

            addToDebugTable(DEBUG_POSITIONS, {position_spawn, getRGBA(COLOUR["red"])})
            addToDebugTable(DEBUG_LINES, {position_original, position_spawn, getRGBA(COLOUR["red"])})

            ParticleRotation(0.8, 0)
            if (i >= (instances / 2)) then
                ParticleRotation(-0.8, 0)
            end

            local j = 2
            for _ = 0, j, 1 do
                SpawnParticle(position_spawn, particle_cfg[2], particle_cfg[3])
            end
        end
    end

    if not assertTableKeys(self.secondary, "init") then
        self.secondary.init = true
        self.secondary.velocity = VecAdd(Vec(0, velocity, 0), G_VEC_WIND)

        PointLight(self.position, 1, 0.5447, 0.2005, 100)

        doIgnitedWP()
        doBodyPrimary()

        doMushroomHead()

        local heads = 10
        for i = 1, heads, 1 do
            local range = velocity * (i / heads)
            local size = variant.secondary.radius / mapToRange(math.random(), 0, 1, 2, 4)
            local pitch = math.random() * 40
            local heading = math.random() * 360
            local distance = math.random() * 5

            doMushroomHead(range, size, {pitch, heading}, distance)
        end
    end

    if math.random() > 0.95 then
        doBodyPrimary(variant.secondary.radius * mapToRange(math.random(), 0, 1, 0.1, 0.33))
    end
end

local function tick_secondary_parachuted_flare(self, delta, variant)
    self.position = VecAdd(self.position, VecScale(self.vel_current, delta))

    if QueryRaycast(self.position, Vec(0, -1, 0), 0.02) then
        self.vel_current = Vec(0, 0, 0)
    end

    local timer_ratio = self.secondary.timer / variant.secondary.timer
    self.secondary.intensity = clamp((self.secondary.intensity + (math.random(10, 20) * math.random(-1, 1))), 900, 1100)

    if IsPointInWater(self.position) then
        self.secondary.intensity = self.secondary.intensity * 0.5
    end

    if math.random() <= 0.04 then
        self.secondary.intensity = self.secondary.intensity * 0.9
    end

    if timer_ratio <= 0.15 then
        self.secondary.intensity = self.secondary.intensity * ((timer_ratio) / 0.15)
    end

    dWatch("shell(SECONDARY_INTENSITY)", self.secondary.intensity)

    if timer_ratio <= 0.02 then return end
    if math.random() <= 0.5 then return end

    -- Spawn smoke particles
    ParticleReset()
    ParticleRadius(0.3 * math.random(), 0, 'easeout', 0, 0.5)
    ParticleAlpha(1.0, 0.0, "linear", 0.05, 0.5)
    ParticleStretch(0)

    local particle_origin = VecAdd(self.position, Vec(0, (self.sprite.width * self.sprite.scaling_factor), 0))
    self.secondary.particle_spread[1] = clamp(self.secondary.particle_spread[1] + (0.04 * math.random(-1, 1)), -0.5, 0.5)
    self.secondary.particle_spread[3] = clamp(self.secondary.particle_spread[3] + (0.04 * math.random(-1, 1)), -0.5, 0.5)

    SpawnParticle(VecAdd(particle_origin, self.secondary.particle_spread), Vec(-0.15, 0.08, 0.05), 7 + (13 * timer_ratio))
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

        SpawnParticle(position_hit, G_VEC_WIND, math.random() * 7 + 3)

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

        local hit, hit_distance, normal = QueryRaycast(sub.transform.pos, VecNormalize(VecSub(position_new, sub.transform.pos)), VecLength(VecSub(position_new, sub.transform.pos)))
        if not hit then
            if timer_ratio < 0.5 then return nil end -- If WP has been deployed for too long without hitting anything, extinguish it

            addToDebugTable(DEBUG_LINES, {sub.transform.pos, transform_new.pos, getRGBA(COLOUR["orange"], 0.15)})

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

            PointLight(sub.transform.pos, getUnpackedRGBA({1, 0.706, 0.42}, sub.brightness))

            if timer_ratio < 0.75 then return transform_new end -- Stop particle trail after some time

            ParticleReset()
            ParticleAlpha(1, 0, "smooth")
            ParticleColor(1, 1, 1, 1, 1, 1)
            ParticleStretch(1)
            ParticleCollide(0, 0.1, "linear", 0.5)

            local step = 1 / (math.floor(mapToRange(velocity_magnitude, 50, 150, 1, 5)))
            local cur = 0
            repeat
                local rand_radius = (sub.smoke_radius - (math.random() * (sub.smoke_radius / 2))) * clamp(mapToRange(timer_elapsed, 0, 0.25, 0.4, 1), 0, 1)
                ParticleRadius(rand_radius, rand_radius, "smooth", 0, 0)

                local pos = VecLerp(sub.transform.pos, transform_new.pos, cur)

                SpawnParticle(pos, G_VEC_WIND, math.random() * 10 + (clamp(timer_elapsed, 0, 1) * 20))

                cur = cur + step
            until cur >= 1

            return transform_new
        end

        local position_hit = VecAdd(sub.transform.pos, VecScale(VecNormalize(VecSub(position_new, sub.transform.pos)), hit_distance))

        addToDebugTable(DEBUG_LINES, {sub.transform.pos, position_hit, COLOUR["orange"]})
        addToDebugTable(DEBUG_POSITIONS, {position_hit, COLOUR["white"]})

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

        local cross_direction = VecCross(normal, reflected_direction)
        if math.random() < 0.5 then
            cross_direction = VecSub(cross_direction, VecScale(cross_direction, 2))
        end
        local send_direction = VecNormalize(VecLerp(reflected_direction, cross_direction, math.random() * 0.4))

        SetBodyVelocity(sub.body, VecScale(send_direction, VecLength(sub.velocity) * (math.random() * 0.08 + 0.02)))

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

            addToDebugTable(DEBUG_POSITIONS, {point, COLOUR["orange"]})
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

function manage_bodies(body)
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

        addToDebugTable(DEBUG_POSITIONS, {pos_fire, COLOUR["orange"]})
        SpawnFire(pos_fire)
    end

    if not IsHandleValid(body.handle) then return true end

    local disp_manage = {
        ["IN"] = manage_incendiary
    }

    local shapes = GetBodyShapes(body.handle)
    return disp_manage[body.type](shapes)
end

function manage_bodies_cleanup()
    for i, body in ipairs(BODIES) do
        if not body.valid then
            dPrint("Removing body "..body.handle)
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