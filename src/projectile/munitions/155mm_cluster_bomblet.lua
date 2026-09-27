local BOMBLET_DUD_CHANCE = 0.02
local BOMBLET_EXPLOSIVE_YIELD = 1
local BOMBLET_HOLE_SIZES = {
    soft = 3,
    medium = 1.3,
    hard = 0.5,
}

Projectiles.defineProjectile("155mm_cluster_bomblet", {
    ProjectileBehaviour.Expires,
    ProjectileBehaviour.HasPhysics,
}, function()
    ---@type ProjectileDefinition
    return {
        selectable = false,
        props = {
            munition_class = "155mm",
            munition_type = "Cluster Bomblet",
            max_age = 10,
            sprite = {
                handle = LoadSprite("MOD/assets/img/bomblet.png"),
                aspect_ratio = 1,
                width = 0.0635,
            },
        },
        onTick = function(projectile, props)
            if projectile.state ~= SHELL_STATE.ACTIVE then
                return
            end

            local look_rotation = QuatRotateQuat(
                QuatLookAt(projectile.transform.pos, GetCameraTransform().pos),
                QuatAxisAngle(Vec(0, 0, 1), 180)
            )
            local draw_transform = Transform(projectile.transform.pos, look_rotation)
            DrawSprite(
                props.sprite.handle,
                draw_transform,
                props.sprite.width,
                props.sprite.width,
                0.4,
                0.4,
                0.4,
                1,
                true,
                false
            )
        end,
        onUpdate = function(projectile)
            if projectile.state ~= SHELL_STATE.ACTIVE then
                return
            end

            local position_previous = projectile._cache.previous_transform.pos
            local position_current = projectile.transform.pos
            local position_delta = VecSub(position_current, position_previous)
            local distance = VecLength(position_delta)
            if distance <= 0 then
                return
            end

            local direction = VecNormalize(position_delta)
            QueryRequire("large")
            QueryRequire("physical")
            local hit, hit_distance = QueryRaycast(position_previous, direction, distance)
            if not hit then
                FdAddToDebugTable(
                    DEBUG_LINES,
                    { position_previous, position_current, FdGetRGBA(COLOUR["orange"], 0.15) }
                )
                return
            end

            local position_hit = VecAdd(position_previous, VecScale(direction, hit_distance))
            FdAddToDebugTable(DEBUG_LINES, { position_previous, position_hit, COLOUR["orange"] })
            FdAddToDebugTable(DEBUG_POSITIONS, { position_hit, COLOUR["white"] })

            if CfgGetValue("G_SIMULATE_UXO") and math.random() <= BOMBLET_DUD_CHANCE then
                MakeHole(position_hit, 0.5, 0.1, 0, false)
                projectile.state = SHELL_STATE.DETONATED
                return
            end

            ProjectileUtil.detonate(position_hit, BOMBLET_EXPLOSIVE_YIELD, BOMBLET_HOLE_SIZES)

            ParticleReset()
            ParticleRadius(1, 2.5, "smooth", 0, 0.2)
            ParticleAlpha(0.5, 0.0, "smooth", 0.05, 0.5)
            ParticleStretch(0)
            ParticleCollide(0)
            SpawnParticle(position_hit, G_VEC_WIND, math.random() * 7 + 3)

            projectile.state = SHELL_STATE.DETONATED
        end,
    }
end)
