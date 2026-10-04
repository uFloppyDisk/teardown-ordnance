local M31A1_DUD_CHANCE = 0.02
local M31A1_ENGINE_COLOUR = BLACKBODY[2500]
local M31A1_ENGINE_INTENSITY = 25
local M31A1_ENGINE_FADE_IN = 0.2
local M31A1_ENGINE_FADE_OUT_START_AGE = 2.2
local M31A1_ENGINE_FADE_OUT = 0.7

local M31A1_SPRITE = {
    handle = LoadSprite("MOD/assets/img/m31a1.png"),
    aspect_ratio = 4.2,
    width = 1,
}

Projectiles.defineProjectile("mlrs_m31a1_warhead", {
    ProjectileBehaviour.Expires,
    ProjectileBehaviour.HasPhysics,
    ProjectileBehaviour.HasSprite,
    ProjectileBehaviour.HasSounds,
}, function()
    ---@type ProjectileDefinition
    return {
        selectable = false,
        props = {
            munition_class = "MLRS",
            munition_type = "GMLRS-U M31A1 Warhead",
            max_age = 30,
            sprite = M31A1_SPRITE,
            sounds = {
                fire = LoadSound("MOD/assets/snd/mlrs_m31a1_fire.ogg"),
            },
            explosive_yield = 4,
            hole_sizes = {
                soft = 50,
                medium = 20,
                hard = 5,
            },
        },
        onTick = function(projectile, props)
            if projectile.state ~= SHELL_STATE.ACTIVE then
                return
            end

            local emission_fade_in = FdClamp(projectile.age / M31A1_ENGINE_FADE_IN, 0, 1)
            local emission_fade_out = 1
                - FdClamp(
                    (projectile.age - M31A1_ENGINE_FADE_OUT_START_AGE) / M31A1_ENGINE_FADE_OUT,
                    0,
                    1
                )
            local emission_intensity =
                math.min(emission_fade_in, emission_fade_out) * M31A1_ENGINE_INTENSITY

            local travel_direction = VecNormalize(projectile.velocity)
            local engine_offset = VecAdd(
                projectile.transform.pos,
                VecScale(travel_direction, -props.sprite.width * props.sprite.aspect_ratio / 2)
            )
            PointLight(
                engine_offset,
                M31A1_ENGINE_COLOUR[1],
                M31A1_ENGINE_COLOUR[2],
                M31A1_ENGINE_COLOUR[3],
                emission_intensity
            )
        end,
        onUpdate = function(projectile, props)
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

            local position = VecAdd(position_previous, VecScale(direction, hit_distance))
            FdAddToDebugTable(DEBUG_LINES, { position_previous, position, COLOUR["orange"] })
            FdAddToDebugTable(DEBUG_POSITIONS, { position, COLOUR["white"] })
            projectile.transform.pos = VecCopy(position)

            if CfgGetValue("G_SIMULATE_UXO") and math.random() <= M31A1_DUD_CHANCE then
                MakeHole(position, 0.5, 0.1, 0, false)
                projectile.state = SHELL_STATE.DETONATED
                return
            end

            ProjectileUtil.detonate(position, props.explosive_yield, props.hole_sizes)
            projectile.state = SHELL_STATE.DETONATED
        end,
    }
end)

Projectiles.defineProjectile("mlrs_m31a1", {
    ProjectileBehaviour.Expires,
    ProjectileBehaviour.HasPhysics,
    ProjectileBehaviour.HasBallistics,
    ProjectileBehaviour.IsQueueable,
    ProjectileBehaviour.DeploysSubmunitions,
}, function()
    ---@type ProjectileDefinition
    return {
        props = {
            munition_class = "MLRS",
            munition_type = "GMLRS-U M31A1",
            weight = 90.71,
            muzzle_velocity = 413,
            sprite = M31A1_SPRITE,
            submunitions = {
                projectile_type = "mlrs_m31a1_warhead",
                count = 6,
                trigger_height = 10000,
                delay_between_spawns = 0.7,
                spawn_offset_radius = 50,
                spread_velocity_min = 0,
                spread_velocity_max = 0,
                spread_pitch_min = 0,
                spread_pitch_max = 0,
            },
        },
    }
end)
