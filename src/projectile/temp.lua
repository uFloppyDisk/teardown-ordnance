Projectiles.defineProjectile("test_projectile", PROJECTILE_DEFAULT_BEHAVIOURS, function(typeName)
    DebugPrint("Defining " .. typeName)

    ---@type ProjectileDefinition
    return {
        props = {
            munition_class = "T.E.S.T",
            munition_type = "Test Projectile",
            sprite = {
                handle = LoadSprite("MOD/assets/img/m31a1.png"),
                width = 1,
                aspect_ratio = 4.2,
            },
            sounds = {
                fire = LoadSound("MOD/assets/snd/155mm_fire.ogg", 100),
                whistle = {
                    LoadLoop("MOD/assets/snd/155mm_whistle_1.ogg", 100),
                    LoadLoop("MOD/assets/snd/155mm_whistle_2.ogg", 100),
                    LoadLoop("MOD/assets/snd/155mm_whistle_3.ogg", 100),
                },
            },
            explosiveYield = 4,
            makeHoleSizes = {
                soft = 50,
                medium = 50,
                hard = 50,
            },
        },
    }
end)
