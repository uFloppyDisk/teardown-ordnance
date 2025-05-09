---@class (exact) SubCluster : Submunition
---@field index number

---Initialize submunitions
---@param self Shell
local function subInit(self)
    self.secondary.submunitions = {}

    local amount_submunitions = CfgGetValue("SHELL_SEC_CLUSTER_BOMBLET_AMOUNT") or 50
    for i = 1, amount_submunitions, 1 do
        local rotation = QuatEuler(0, math.random() * 360, math.random() * -160 + 80)
        local transform = Transform(self.position, rotation)

        ---@type SubCluster
        local sub = FdObjectNew({
            index = i,
            transform = TransformCopy(transform),
            velocity = Vec(math.random() * 10 + 5, 0, 0)
        }, DEFAULT_SUBMUNITION)

        local vel_to_sub = TransformToLocalVec(sub.transform, VecNormalize(self.secondary.inertia))
        vel_to_sub = VecScale(vel_to_sub, VecLength(self.secondary.inertia))
        sub.velocity = VecAdd(sub.velocity, vel_to_sub)

        table.insert(self.secondary.submunitions, sub)
    end
end

---Tick submunitions
---@param self SubCluster
---@param delta number
---@param sprite number
local function subTick(self, delta, sprite)
    local gravity = math.abs(G_VEC_GRAVITY[2])
    local world_down = TransformToLocalVec(self.transform, Vec(0, -1, 0))

    self.velocity = VecAdd(self.velocity, VecScale(world_down, gravity * delta))

    local position_new = TransformToParentPoint(self.transform, VecScale(self.velocity, delta))
    local transform_new = Transform(position_new, self.transform.rot)

    local look_rotation = QuatRotateQuat(QuatLookAt(self.transform.pos, GetCameraTransform().pos),
        QuatAxisAngle(Vec(0, 0, 1), 180))
    local draw_pos = Transform(self.transform.pos, look_rotation)
    DrawSprite(sprite, draw_pos, 0.0635, 0.0635, 0.4, 0.4, 0.4, 1, true, false)

    local hit, hit_distance = QueryRaycast(self.transform.pos, VecNormalize(VecSub(position_new, self.transform.pos)),
        VecLength(VecSub(position_new, self.transform.pos)))
    if not hit then
        FdAddToDebugTable(DEBUG_LINES, { self.transform.pos, transform_new.pos, FdGetRGBA(COLOUR["orange"], 0.15) })

        return transform_new
    end

    local position_hit = VecAdd(self.transform.pos,
        VecScale(VecNormalize(VecSub(position_new, self.transform.pos)), hit_distance))

    FdAddToDebugTable(DEBUG_LINES, { self.transform.pos, position_hit, COLOUR["orange"] })
    FdAddToDebugTable(DEBUG_POSITIONS, { position_hit, COLOUR["white"] })

    -- Random roll if submunition is a dud
    if CfgGetValue("G_SIMULATE_UXO") and math.random(100) <= 2 then
        FdLog("Submunition at index " .. self.index .. " is a dud.")
        MakeHole(position_hit, 0.5, 0.1, 0, false)

        return nil
    end

    Explosion(position_hit, 1)
    MakeHole(position_hit, 3, 1.3, 0.5, false)

    ParticleReset()
    ParticleRadius(1, 2.5, "smooth", 0, 0.2)
    ParticleAlpha(0.5, 0.0, "smooth", 0.05, 0.5)
    ParticleStretch(0)
    ParticleCollide(0)

    SpawnParticle(position_hit, G_VEC_WIND, math.random() * 7 + 3)

    return nil
end

---Cluster shell tick entrypoint
---@param self Shell
---@param delta number
---@param _ any
function ShellSecTickCluster(self, delta, _)
    local sprite = LoadSprite("MOD/assets/img/" .. "bomblet" .. ".png")

    --    local sounds = {
    --        "155mm_shell_cluster_submunition_explode_01",
    --        "155mm_shell_cluster_submunition_explode_02",
    --    }

    if self.secondary.timer < 0 then
        self.state = SHELL_STATE.DETONATED
        self.secondary.active = false
        return
    end

    if not FdAssertTableKeys(self, "secondary", "submunitions") then
        subInit(self)
    end

    if #self.secondary.submunitions == 0 then
        self.state = SHELL_STATE.DETONATED
        self.secondary.active = false
        return
    end

    for index, sub in ipairs(self.secondary.submunitions) do
        ---@cast sub SubCluster
        local transform_new = subTick(sub, delta, sprite)

        sub.transform = transform_new

        if transform_new == nil then
            table.remove(self.secondary.submunitions, index)
        end
    end
end
