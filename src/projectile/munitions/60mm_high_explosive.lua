Projectiles.defineProjectile("60mm_high_explosive", PROJECTILE_DEFAULT_BEHAVIOURS, function()
    ---@type ProjectileDefinition
    return {
        props = {
            munition_class = "60mm",
            munition_type = "High Explosive",
            weight = 2.73,
            muzzle_velocity = 827 / 2,
            explosive_yield = 1.5,
            hole_sizes = {
                soft = 35,
                medium = 15,
                hard = 3,
            },
            sprite = {
                handle = LoadSprite("MOD/assets/img/60mm_HE.png"),
                aspect_ratio = 4.08,
                width = 0.06 * 2,
            },
            sounds = {
                fire = LoadSound("MOD/assets/snd/60mm_fire.ogg", 100),
                whistle = LoadLoop("MOD/assets/snd/60mm_whistle.ogg", 100),
            },
            penetration = {
                -- Trivial materials
                foliage = {
                    absorb_percentage = 0.02,
                    minimum_energy = 10,
                    chance_to_terminate = 0,
                },
                snow = {
                    absorb_percentage = 0.03,
                    minimum_energy = 20,
                    chance_to_terminate = 0,
                },

                -- Soft materials
                dirt = {
                    absorb_percentage = 0.10,
                    minimum_energy = 100,
                    chance_to_terminate = 0.05,
                },
                glass = {
                    absorb_percentage = 0.10,
                    minimum_energy = 150,
                    chance_to_terminate = 0.05,
                },
                plastic = {
                    absorb_percentage = 0.20,
                    minimum_energy = 150,
                    chance_to_terminate = 0.02,
                },
                wood = {
                    absorb_percentage = 0.40,
                    minimum_energy = 150,
                    chance_to_terminate = 0.50,
                },
                plaster = {
                    absorb_percentage = 0.50,
                    minimum_energy = 175,
                    chance_to_terminate = 0.70,
                },

                -- Medium materials
                concrete = {
                    absorb_percentage = 0.80,
                    minimum_energy = 1000,
                    chance_to_terminate = 0.95,
                },
                brick = {
                    absorb_percentage = 0.70,
                    minimum_energy = 1000,
                    chance_to_terminate = 0.95,
                },
                metal = {
                    absorb_percentage = 0.90,
                    minimum_energy = 1250,
                    chance_to_terminate = 1,
                },

                -- Hard materials
                masonry = {
                    absorb_percentage = 1,
                    minimum_energy = 3500,
                    chance_to_terminate = 1,
                },
                heavymetal = {
                    absorb_percentage = 1,
                    minimum_energy = 9999,
                    chance_to_terminate = 1,
                },

                -- Indestructible materials
                rock = {
                    absorb_percentage = 1,
                    minimum_energy = 9999,
                    chance_to_terminate = 1,
                },

                -- Null material
                default = {
                    absorb_percentage = 1,
                    minimum_energy = 9999,
                    chance_to_terminate = 1,
                },
            },
        },
    }
end)
