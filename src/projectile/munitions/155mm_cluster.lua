Projectiles.defineProjectile("155mm_cluster", {
    ProjectileBehaviour.Expires,
    ProjectileBehaviour.HasPhysics,
    ProjectileBehaviour.HasBallistics,
    ProjectileBehaviour.IsQueueable,
    ProjectileBehaviour.DeploysSubmunitions,
    ProjectileBehaviour.HasImpactFuze,
    ProjectileBehaviour.HasSprite,
    ProjectileBehaviour.HasSounds,
}, function()
    ---@type ProjectileDefinition
    return {
        props = {
            munition_class = "155mm",
            munition_type = "Cluster",
            weight = 43.2,
            muzzle_velocity = 827 / 2,
            explosive_yield = 0,
            hole_sizes = {
                soft = 0.1,
                medium = 0,
                hard = 0,
            },
            sprite = {
                handle = LoadSprite("MOD/assets/img/155mm_HE.png"),
                aspect_ratio = 5.33,
                width = 0.155 * 2,
            },
            sounds = {
                fire = LoadSound("MOD/assets/snd/155mm_fire.ogg", 100),
            },
            submunitions = {
                projectile_type = "155mm_cluster_bomblet",
                count = 50,
                count_config_key = "SHELL_SEC_CLUSTER_BOMBLET_AMOUNT",
                trigger_height = 450,
                trigger_sound = LoadSound("MOD/assets/snd/155mm_shell_cluster_secondary_trigger.ogg"),
                trigger_sound_volume = 900,
                particle_radius = 10,
                spread_velocity_min = 5,
                spread_velocity_max = 15,
                spread_pitch_min = -80,
                spread_pitch_max = 80,
            },
        },
    }
end)
