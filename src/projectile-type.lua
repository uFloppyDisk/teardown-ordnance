Projectiles.defineProjectile("test_projectile", function(typeName)
    DebugPrint("Defining " .. typeName)
    return {
        afterTick = function(projectile, _)
            DebugPrint(string.format("afterTick: %s %d", projectile.type, projectile.age))
        end
    }
end)
