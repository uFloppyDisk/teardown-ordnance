Projectiles.defineProjectile("test_projectile", function(typeName)
    DebugPrint("Defining " .. typeName)
    return {
        afterTick = function(projectile, _)
            DebugPrint(string.format("afterTick: %s %f", projectile.type, projectile.age))
            DebugPrint(projectile.transform)
            DebugPrint(projectile.velocity)
        end
    }
end)
