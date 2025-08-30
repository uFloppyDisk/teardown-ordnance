Projectiles.defineProjectile("test_projectile", function(typeName)
    DebugPrint("Defining " .. typeName)
    return {
        props = {
            sprite = {
                handle = LoadSprite("MOD/assets/img/m31a1.png"),
                width = 1,
                aspect_ratio = 4.2,
            },
        },
        afterTick = function(projectile, _)
            DebugPrint(string.format("afterTick: %s %f", projectile.type, projectile.age))
            DebugPrint(projectile.transform)
            DebugPrint(projectile.velocity)
        end
    }
end)
