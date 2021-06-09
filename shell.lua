SHELL_VALUES = {
    [1] = {
        name = "155mm Howitzer",
        caliber = "155mm",
        weight = 43.2,
        variants = {
            {
                id = "HE",
                name = "High Explosive",
                silent = false,
                size_explosion = 4,
                size_makehole = {50, 20, 5}
            },
            {
                id = "BB",
                name = "Bunkerbuster",
                silent = false,
                size_explosion = 4,
                size_makehole = {50, 35, 20},
                -- size_explosion = 0,
                -- size_makehole = {0, 0, 0}
            }
        },
        sprite = {
            img = "155mm_HE",
            scaling_factor = 5.33,
            width = 0.155 * 2
        },
        sounds = {
            whistle = {
                "155mm_whistle_1",
                "155mm_whistle_2",
                "155mm_whistle_3"
            },
            fire = "155mm_fire"
        }
    },
    [2] = {
        name = "60mm Mortar",
        caliber = "60mm",
        weight = 2.73,
        variants = {
            {
                id = "HE",
                name = "High Explosive",
                silent = false,
                size_explosion = 1.5,
                size_makehole = {35, 15, 3}
            },
            {
                id = "PF",
                name = "Parachuted Flare",
                silent = true,
                size_explosion = 0,
                size_makehole = {0.1, 0, 0},
                secondary = {
                    timer = 30,
                    trigger_height = 75
                }
            }
        },
        sprite = {
            img = "60mm_HE",
            scaling_factor = 4.08,
            width = 0.06 * 2
        },
        sounds = {
            whistle = "60mm_whistle",
            fire = "60mm_fire"
        }
    }
}

MAT_PEN = {
    -- Soft materials
    ["foliage"] = {
        absorb = 2,
        ["HE"] = {
            min_energy = 10,
            chance = 0
        },
        ["BB"] = {
            min_energy = 0,
            chance = 0
        },
    },
    ["dirt"] = {
        absorb = 10,
        ["HE"] = {
            min_energy = 100,
            chance = 5
        },
        ["BB"] = {
            min_energy = 0,
            chance = 0
        },
    },
    ["glass"] = {
        absorb = 10,
        ["HE"] = {
            min_energy = 150,
            chance = 5
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0
        },
    },
    ["plastic"] = {
        absorb = 20,
        ["HE"] = {
            min_energy = 150,
            chance = 2
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0
        },
    },
    ["wood"] = {
        absorb = 40,
        ["HE"] = {
            min_energy = 150,
            chance = 50
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0
        },
    },
    ["plaster"] = {
        absorb = 50,
        ["HE"] = {
            min_energy = 175,
            chance = 70
        },
        ["BB"] = {
            min_energy = 50,
            chance = 0
        },
    },

    -- Medium materials
    ["concrete"] = {
        absorb = 80,
        ["HE"] = {
            min_energy = 1000,
            chance = 95
        },
        ["BB"] = {
            min_energy = 1000,
            chance = 15
        },
    },
    ["brick"] = {
        absorb = 70,
        ["HE"] = {
            min_energy = 1000,
            chance = 95
        },
        ["BB"] = {
            min_energy = 900,
            chance = 15
        },
    },
    ["metal"] = {
        absorb = 90,
        ["HE"] = {
            min_energy = 1250,
            chance = 100
        },
        ["BB"] = {
            min_energy = 1000,
            chance = 20
        },
    },

    -- Hard materials
    ["masonry"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 3500,
            chance = 100
        },
        ["BB"] = {
            min_energy = 1500,
            chance = 20
        },
    },
    ["heavymetal"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 5001,
            chance = 100
        },
        ["BB"] = {
            min_energy = 5001,
            chance = 100
        },
    },

    ["default"] = {
        absorb = 100,
        ["HE"] = {
            min_energy = 5001,
            chance = 100
        },
        ["BB"] = {
            min_energy = 5001,
            chance = 100
        },
    }
}

DEFAULT_SHELL = {
    active = false,
    queued = false,
    in_flight = false,
    detonated = false,

    secondary = false,
    secondary_timer = 0,

    hit_once = false,

    type = 1,
    variant = 1,
    flight_time = GetFloat("savegame.mod.flight_time"),
    inaccuracy = GetFloat("savegame.mod.shell_inaccuracy"),

    sprite = nil,
    snd_whistle = 1,

    destination = nil,
    position = nil,

    vel_previous = nil,
    vel_current = nil,

    kinetic_energy = 0
}

local function getRecursiveMaterialsInRaycast(pos, pos_new, hit_pos, shell_radius, materials, shapes, depth)
    if depth < 0 or depth == nil then
        print("Max depth reached.")
        return materials, hit_pos, true
    end

    print("Recursing with depth "..depth)
    for index, shape in pairs(shapes) do
        QueryRejectShape(shape)
    end

    QueryRequire('large')
    QueryRequire("physical")
    local hit, distance, normal, shape = QueryRaycast(pos, VecNormalize(VecSub(pos_new, pos)), VecLength(VecSub(pos_new, pos), shell_radius))
    if not hit then
        print("No hits detected in QueryRaycast")
        return materials, hit_pos, false
    end

    table.insert(shapes, shape)

    local position_hit = VecAdd(pos, VecScale(VecNormalize(VecSub(pos_new, pos)), distance))
    table.insert(DEBUG_POSITIONS, {position_hit, {1, 1, 1}})
    local material = GetShapeMaterialAtPosition(shape, (position_hit))

    table.insert(materials, material)
    table.insert(hit_pos, VecCopy(position_hit))

    print("Hit shape with material '"..material.."'")
    return getRecursiveMaterialsInRaycast(pos, pos_new, hit_pos, shell_radius, materials, shapes, depth - 1)
end

function Shell_new(new)
    local base = Shell_copy(DEFAULT_SHELL)
    for key, value in pairs(new) do
        base[key] = value
    end

    return base
end

function Shell_copy(object)
    local copy
    if type(object) == 'table' then
        copy = {}
        for key, value in pairs(object) do
            copy[Shell_copy(key)] = Shell_copy(value)
        end
        setmetatable(copy, Shell_copy(getmetatable(object)))
    else
        copy = object
    end
    return copy
end

function Shell_draw(self, pos)
    local values = SHELL_VALUES[self.type]
    local rotation = QuatRotateQuat(QuatLookAt(self.position, GetCameraTransform().pos), QuatAxisAngle(Vec(0,0,1), 180))
    local transform_pos = Transform(pos, rotation)

    local width = values.sprite.width
    local height = values.sprite.width * values.sprite.scaling_factor

    DrawSprite(self.sprite, transform_pos, width, height, 0.4, 0.4, 0.4, 1, true, false)
end

function Shell_tick(self, delta)
    watch("Flight Time", self.flight_time)

    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    if self.in_flight then
        self.flight_time = self.flight_time - delta

        if self.flight_time <= 0 then
            self.in_flight = false
            self.active = true
        end
    end

    if self.secondary then
        if variant.id == "PF" then
            if self.secondary_timer > 0 then
                local intensity = 1000
                if (self.secondary_timer / variant.secondary.timer) <= 0.15 then
                    intensity = intensity * ((self.secondary_timer / variant.secondary.timer) / 0.15)
                end

                PointLight(self.position, 1, 1, 1, intensity)
                self.secondary_timer = self.secondary_timer - delta
            else
                self.detonated = true
                self.secondary = false
                self.active = false
            end
        end
    end

    if self.active then
        local trigger_detonation = false
        local position_detonation = nil
        local shell_radius = values.sprite.width / 2

        self.distance_ground = VecLength(VecSub(self.position, self.destination))
        watch("Distance to Ground", self.distance_ground)

        if (self.distance_ground > 2000) then
            self.detonated = true
            self.active = false
            return
        end

        if (variant["secondary"] ~= nil) then
            if variant["secondary"]["trigger_height"] ~= nil then
                if self.distance_ground < variant.secondary.trigger_height then
                    self.secondary = true
                    self.vel_current = Vec(0, -1, 0)
                end
            end
        end

        if not variant.silent and VecLength(self.vel_current) > 100 and (self.distance_ground < 500) then
            local distance_player = VecLength(VecSub(self.position, GetPlayerPos()))
            local volume = clamp(150 - (clamp(distance_player, 0, 500) / 5), 0, 100)
            watch("Volume", volume)
            PlayLoop(self.snd_whistle, self.position, 100)
        end

        if not self.secondary then
            self.vel_current = VecAdd(self.vel_current, (VecScale(G_VEC_GRAVITY, delta)))
        end
        if not self.hit_once then
            self.kinetic_energy = clamp((values.weight * math.pow(math.abs(self.vel_current[2]), 2)) / 1000, 0, 5000)
        end

        watch("shell(CURRENT VELOCITY)", self.vel_current)
        watch("shell(KINETIC ENERGY)", self.kinetic_energy)

        local position_new = VecAdd(self.position, VecScale(self.vel_current, delta))

        if self.secondary and self.hit_once then
            return
        end

        QueryRequire('large')
        QueryRequire("physical")
        local hit, distance, normal, shape = QueryRaycast(self.position, VecNormalize(VecSub(position_new, self.position)), VecLength(VecSub(position_new, self.position), shell_radius))
        if hit and not trigger_detonation then
            table.insert(DEBUG_POSITIONS, {self.position, {1, 1, 0}})
            table.insert(DEBUG_LINES, {self.position, position_new, {1, 0.2, 0.2}})
            print("Hit detected.")

            self.hit_once = true

            if self.secondary then
                self.vel_current = Vec(0, 0, 0)
                return
            end

            local position_hit = VecAdd(self.position, VecScale(VecNormalize(VecSub(position_new, self.position)), distance))
            table.insert(DEBUG_POSITIONS, {position_hit, {1, 1, 1}})

            if not GetBool("savegame.mod.simulate_ballistics") then
                Shell_detonate(self, position_hit)
                return
            end

            local initial_material = GetShapeMaterialAtPosition(shape, (position_hit))

            print("Initial material is '"..initial_material.."'")
            local hit_materials, hit_positions, max_depth = getRecursiveMaterialsInRaycast(self.position, position_new, { position_hit }, shell_radius, { initial_material }, { shape }, 3)
            if hit_positions ~= nil then position_detonation = hit_positions[#hit_positions] else position_detonation = position_hit end

            if max_depth then
                Shell_detonate(self, position_detonation)
                return
            end

            for index, material in pairs(hit_materials) do
                if trigger_detonation then break end

                print("Material at index "..index.." is '"..material.."'")

                local pen_values = MAT_PEN[material]
                if pen_values == nil then
                    print("Material not found in penetration table. Defaulting...")
                    pen_values = MAT_PEN["default"]
                end

                pen_values = pen_values[variant.id] or pen_values["HE"]

                if self.kinetic_energy >= pen_values.min_energy then
                    if (math.random() * 100) < pen_values.chance then
                        print("Material '"..material.."' triggered detonation. (Unlucky roll)")
                        position_detonation = hit_positions[index]
                        trigger_detonation = true
                    else
                        print("Material '"..material.."' was too weak to trigger detonation.")
                        -- self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * (MAT_PEN[material].absorb / 100))
                        self.kinetic_energy = self.kinetic_energy - (pen_values.min_energy * 1)
                        MakeHole(hit_positions[index], shell_radius + 1, shell_radius + 0.5, shell_radius, false)
                    end
                elseif self.kinetic_energy < pen_values.min_energy then
                    print("Material '"..material.."' triggered detonation. (energy below threshold)")
                    position_detonation = hit_positions[index]
                    trigger_detonation = true
                end
            end

            if not trigger_detonation then
                hit, distance, normal, shape = QueryRaycast(position_new, VecNormalize(VecSub(self.position, position_new)), VecLength(VecSub(self.position, position_new), shell_radius))
                position_hit = VecAdd(position_new, VecScale(VecNormalize(VecSub(self.position, position_new)), distance))
                if hit then
                    local bottom_material = GetShapeMaterialAtPosition(shape, (position_hit))
                    print("Bottom material detected as '"..bottom_material.."'")
                    if bottom_material == "rock" or bottom_material == "none" then
                        print("Bottom material is impenetrable")
                        trigger_detonation = true
                    end
                end
            end

            print("-------------")
        end

        if trigger_detonation then
            Shell_detonate(self, position_detonation)
            return
        end

        ParticleReset()
        ParticleRadius(0.2)
        ParticleStretch(1.0)
        SpawnParticle(VecAdd(self.position, Vec(0, values.sprite.width * values.sprite.scaling_factor, 0)), Vec(0, -1, 0), 0.1)

        if not self.secondary then
            Shell_draw(self, self.position)
        end

        self.vel_previous = VecCopy(self.vel_current)
        self.position = position_new
    end
end

function Shell_detonate(self, pos)
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    self.detonated = true
    self.active = false

    if GetBool("savegame.mod.simulate_dud") and math.random(100) <= 2 then
        MakeHole(pos, 5, 2, 1, false)
        return
    end

    local hole = variant.size_makehole
    MakeHole(pos, hole[1], hole[2], hole[3], false)
    if variant.size_explosion > 0 then
        Explosion(pos, variant.size_explosion)
    end
    table.insert(DEBUG_POSITIONS, {pos, {1, 0.2, 0.2}})
end

function Shell_fire(self)
    DEBUG_POSITIONS = {}
    DEBUG_LINES = {}
    local values = SHELL_VALUES[self.type]
    local variant = values.variants[self.variant]

    print("--- Firing shell ("..values.name..") ---")

    if variant["secondary"] ~= nil then
        if variant["secondary"]["timer"] ~= nil then
            self.secondary_timer = variant.secondary.timer
        end
    end

    if self.inaccuracy > 0 then
        local original = VecCopy(self.destination)
        local rotation = QuatEuler(0, 360 * math.random(), 0)
        local distance = Vec(self.inaccuracy * math.random(), 0, 0)

        local transform = Transform(original, rotation)
        self.destination = TransformToParentPoint(transform, distance)
    end

    self.position = VecAdd(self.destination, Vec(0, 1000, 0))
    -- self.position = VecAdd(self.destination, Vec(0, 2, 0))

    self.in_flight = true

    local snd_fire = LoadSound("MOD/snd/"..values.sounds.fire..".ogg")
    PlaySound(snd_fire, VecAdd(GetPlayerPos(), Vec(100, 0, 100)), 20)
end