Projectiles.defineProjectile("test_projectile", function(typeName)
    DebugPrint("Defining " .. typeName)

    ---@type ProjectileDefinition
    return {
        props = {
            sprite = {
                handle = LoadSprite("MOD/assets/img/m31a1.png"),
                width = 1,
                aspect_ratio = 4.2,
            },
            sounds = {
                fire = LoadSound("MOD/assets/snd/155mm_fire.ogg", 100),
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
