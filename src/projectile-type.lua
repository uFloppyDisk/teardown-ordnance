Projectiles.defineProjectile("test_projectile", function(name)
    DebugPrint("Defining this mf")
    return {
        init = function()
            DebugPrint("Overwritten init function for " .. name)
        end
    }
end)
