Projectiles.defineProjectile("155mm_high_explosive", PROJECTILE_DEFAULT_BEHAVIOURS, function()
    ---@type ProjectileDefinition
    return {
        props = {
            munition_class = "155mm",
            munition_type = "High Explosive",
            muzzle_velocity = 827 / 2,
            explosive_yield = 4,
            hole_sizes = {
                soft = 50,
                medium = 20,
                hard = 5,
            },
            sprite = {
                handle = LoadSprite("MOD/assets/img/155mm_HE.png"),
                aspect_ratio = 5.33,
                width = 0.155 * 2,
            },
            sounds = {
                fire = LoadSound("MOD/assets/snd/155mm_fire.ogg", 100),
                whistle = {
                    LoadLoop("MOD/assets/snd/155mm_whistle_1.ogg", 100),
                    LoadLoop("MOD/assets/snd/155mm_whistle_2.ogg", 100),
                    LoadLoop("MOD/assets/snd/155mm_whistle_3.ogg", 100),
                },
            },
        },
    }
end)
