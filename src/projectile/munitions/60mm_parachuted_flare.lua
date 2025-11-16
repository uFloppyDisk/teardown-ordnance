local FLARE_TIME_TO_LIVE = 30
local FLARE_COLOUR = { 1, 1, 1 }
local FLARE_TRIGGER_SOUND_VOLUME = 90

local FLARE_INTENSITY_BASE = 1000
local FLARE_INTENSITY_DECAY_TIME = 0.15
local FLARE_INTENSITY_FLICKER_CHANCE = 0.04
local FLARE_INTENSITY_FLICKER_SCALE = 0.9
local FLARE_INTENSITY_IN_WATER_SCALE = 0.5
local FLARE_INTENSITY_STEP_MIN = 10
local FLARE_INTENSITY_STEP_MAX = 20
local FLARE_INTENSITY_RANGE_MIN = FLARE_INTENSITY_BASE - 100
local FLARE_INTENSITY_RANGE_MAX = FLARE_INTENSITY_BASE + 100

local SMOKE_PLUME_LIFETIME_BASE = 7
local SMOKE_PLUME_LIFETIME_MULT = 13
local SMOKE_PLUME_VELOCITY = Vec(-0.15, 0.08, 0.05)
local SMOKE_PLUME_CHANCE_TO_SPAWN = 0.5
local SMOKE_PLUME_STOP_SPAWN_TIME = 0.02

local SMOKE_PLUME_SPREAD_RANGE = 0.5
local SMOKE_PLUME_SPREAD_OFFSET = 0.04

local SMOKE_PLUME_RADIUS_EASING = "easeout"
local SMOKE_PLUME_RADIUS_FADEIN = 0.3
local SMOKE_PLUME_RADIUS_FADEIN_TIME = 0
local SMOKE_PLUME_RADIUS_FADEOUT = 0
local SMOKE_PLUME_RADIUS_FADEOUT_TIME = 0.5

local SMOKE_PLUME_ALPHA_EASING = "linear"
local SMOKE_PLUME_ALPHA_FADEIN = 0.3
local SMOKE_PLUME_ALPHA_FADEIN_TIME = 0
local SMOKE_PLUME_ALPHA_FADEOUT = 0
local SMOKE_PLUME_ALPHA_FADEOUT_TIME = 0.5

Projectiles.defineProjectile("60mm_parachuted_flare", {
    ProjectileBehaviour.HasPhysics,
    ProjectileBehaviour.HasBallistics,
    ProjectileBehaviour.IsQueueable,
    ProjectileBehaviour.HasImpactFuze,
    ProjectileBehaviour.HasSprite,
    ProjectileBehaviour.HasSounds,
}, function()
    ---@enum FLARE_STATE
    local FLARE_STATE = {
        PRIMED = 0,
        LIT = 1,
        EXTINGUISHED = 2,
    }

    local FLARE_SOUND_POP = LoadSound("MOD/assets/snd/60mm_ILL_secondary_pop_distant.ogg")

    ---@type ProjectileDefinition
    return {
        props = {
            munition_class = "60mm",
            munition_type = "Parachuted Flare",
            muzzle_velocity = 827 / 2,
            explosive_yield = 0,
            hole_sizes = {
                soft = 0.1,
                medium = 0,
                hard = 0,
            },
            sprite = {
                handle = LoadSprite("MOD/assets/img/60mm_ILL.png"),
                aspect_ratio = 5.25,
                width = 0.06 * 2,
            },
            sounds = {
                whistle = LoadSound("MOD/assets/snd/60mm_whistle.ogg", 100),
                fire = LoadSound("MOD/assets/snd/60mm_fire.ogg", 100),
            },
        },
        beforeInit = function(projectile)
            projectile._initial.requested_destination = VecAdd(projectile._initial.requested_destination, Vec(0, 40, 0))
            projectile._cache.flare = {
                state = FLARE_STATE.PRIMED,
                ttl = FLARE_TIME_TO_LIVE,
                intensity = FLARE_INTENSITY_BASE,
                smoke = {
                    spread = Vec(),
                },
            }

            FdAddToDebugTable(DEBUG_POSITIONS, { projectile._initial.requested_destination, FdGetRGBA(COLOUR["red"]) })
        end,
        afterInit = function(projectile)
            FdAddToDebugTable(DEBUG_POSITIONS, { projectile.destination, FdGetRGBA(COLOUR["yellow"]) })
        end,
        onUpdate = function(projectile, _, dt)
            if projectile._cache.flare.state == FLARE_STATE.PRIMED then
                local current_distance = VecLength(VecSub(projectile.transform.pos, projectile.destination))
                if current_distance < 10 then
                    projectile._cache.flare.state = FLARE_STATE.LIT
                    PlaySound(FLARE_SOUND_POP, projectile.transform.pos, FLARE_TRIGGER_SOUND_VOLUME)
                end
            end

            if projectile._cache.flare.state == FLARE_STATE.LIT then
                projectile.velocity = G_VEC_WIND
                projectile._cache.flare.ttl = projectile._cache.flare.ttl - dt
                if projectile._cache.flare.ttl < 0 then
                    projectile._cache.flare.state = FLARE_STATE.EXTINGUISHED
                    projectile.state = SHELL_STATE.DETONATED
                end
            end
        end,
        onTick = function(projectile, props)
            if projectile._cache.flare.state ~= FLARE_STATE.LIT then
                return
            end

            local ttl_ratio = projectile._cache.flare.ttl / FLARE_TIME_TO_LIVE

            local per_tick_position = ProjectileUtil.calculatePerTickPosition(
                projectile.transform.pos,
                projectile._cache.previous_transform.pos,
                projectile.age,
                projectile._cache.update_time
            )

            local intensity = projectile._cache.flare.intensity

            do
                intensity = FdClamp(
                    (
                        projectile._cache.flare.intensity
                        + (math.random(FLARE_INTENSITY_STEP_MIN, FLARE_INTENSITY_STEP_MAX) * math.random(-1, 1))
                    ),
                    FLARE_INTENSITY_RANGE_MIN,
                    FLARE_INTENSITY_RANGE_MAX
                )
            end

            if IsPointInWater(per_tick_position) then
                intensity = intensity * FLARE_INTENSITY_IN_WATER_SCALE
            end

            if math.random() <= FLARE_INTENSITY_FLICKER_CHANCE then
                intensity = intensity * FLARE_INTENSITY_FLICKER_SCALE
            end

            if ttl_ratio <= FLARE_INTENSITY_DECAY_TIME then
                intensity = intensity * (ttl_ratio / FLARE_INTENSITY_DECAY_TIME)
            end

            projectile._cache.flare.intensity = intensity
            PointLight(per_tick_position, FLARE_COLOUR[1], FLARE_COLOUR[2], FLARE_COLOUR[3], intensity)

            -- Smoke effects
            if ttl_ratio <= SMOKE_PLUME_STOP_SPAWN_TIME then
                return
            end

            if math.random() >= SMOKE_PLUME_CHANCE_TO_SPAWN then
                return
            end

            ParticleReset()
            ParticleRadius(
                SMOKE_PLUME_RADIUS_FADEIN * math.random(),
                SMOKE_PLUME_RADIUS_FADEOUT,
                SMOKE_PLUME_RADIUS_EASING,
                SMOKE_PLUME_RADIUS_FADEIN_TIME,
                SMOKE_PLUME_RADIUS_FADEOUT_TIME
            )
            ParticleAlpha(
                SMOKE_PLUME_ALPHA_FADEIN,
                SMOKE_PLUME_ALPHA_FADEOUT,
                SMOKE_PLUME_ALPHA_EASING,
                SMOKE_PLUME_ALPHA_FADEIN_TIME,
                SMOKE_PLUME_ALPHA_FADEOUT_TIME
            )
            ParticleStretch(0)

            local particle_origin =
                VecAdd(per_tick_position, Vec(0, (props.sprite.width * props.sprite.aspect_ratio), 0))
            projectile._cache.flare.smoke.spread[1] = FdClamp(
                projectile._cache.flare.smoke.spread[1] + (SMOKE_PLUME_SPREAD_OFFSET * math.random(-1, 1)),
                -SMOKE_PLUME_SPREAD_RANGE,
                SMOKE_PLUME_SPREAD_RANGE
            )
            projectile._cache.flare.smoke.spread[3] = FdClamp(
                projectile._cache.flare.smoke.spread[3] + (SMOKE_PLUME_SPREAD_OFFSET * math.random(-1, 1)),
                -SMOKE_PLUME_SPREAD_RANGE,
                SMOKE_PLUME_SPREAD_RANGE
            )

            SpawnParticle(
                VecAdd(particle_origin, projectile._cache.flare.smoke.spread),
                SMOKE_PLUME_VELOCITY,
                SMOKE_PLUME_LIFETIME_BASE + (SMOKE_PLUME_LIFETIME_MULT * ttl_ratio)
            )
        end,
    }
end)
