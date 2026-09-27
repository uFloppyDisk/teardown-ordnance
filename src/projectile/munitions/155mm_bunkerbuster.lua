Projectiles.defineProjectile("155mm_bunkerbuster", PROJECTILE_DEFAULT_BEHAVIOURS, function()
    ---@type ProjectileDefinition
    return {
        props = {
            munition_class = "155mm",
            munition_type = "Bunkerbuster",
            weight = 43.2,
            muzzle_velocity = 827 / 2,
            explosive_yield = 4,
            hole_sizes = {
                soft = 50,
                medium = 35,
                hard = 20,
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
            penetration = {
                -- Trivial materials
                foliage = {
                    absorb_percentage = 0.02,
                    minimum_energy = 0,
                    chance_to_terminate = 0,
                },
                snow = {
                    absorb_percentage = 0.03,
                    minimum_energy = 0,
                    chance_to_terminate = 0,
                },

                -- Soft materials
                dirt = {
                    absorb_percentage = 0.10,
                    minimum_energy = 0,
                    chance_to_terminate = 0,
                },
                glass = {
                    absorb_percentage = 0.10,
                    minimum_energy = 50,
                    chance_to_terminate = 0,
                },
                plastic = {
                    absorb_percentage = 0.20,
                    minimum_energy = 50,
                    chance_to_terminate = 0,
                },
                wood = {
                    absorb_percentage = 0.40,
                    minimum_energy = 50,
                    chance_to_terminate = 0,
                },
                plaster = {
                    absorb_percentage = 0.50,
                    minimum_energy = 50,
                    chance_to_terminate = 0,
                },

                -- Medium materials
                concrete = {
                    absorb_percentage = 0.80,
                    minimum_energy = 1000,
                    chance_to_terminate = 0.15,
                },
                brick = {
                    absorb_percentage = 0.70,
                    minimum_energy = 900,
                    chance_to_terminate = 0.15,
                },
                metal = {
                    absorb_percentage = 0.90,
                    minimum_energy = 1000,
                    chance_to_terminate = 0.20,
                },

                -- Hard materials
                masonry = {
                    absorb_percentage = 1,
                    minimum_energy = 1500,
                    chance_to_terminate = 0.20,
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
