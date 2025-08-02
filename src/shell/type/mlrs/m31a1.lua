---@class (exact) SubM31A1 : Submunition
---@field active boolean
---@field age number
---@field delay number
---@field index integer

local MISSILE_DELAY_BETWEEN = 0.7
local MISSILE_AMOUNT_PER = 6
local MISSILE_MAX_OFFSET_DISTANCE = 50

local ENGINE_EMISSION_COLOUR = BLACKBODY[2500]
local ENGINE_EMISSION_INTENSITY = 25
local ENGINE_EMISSION_FADEIN = 0.2
local ENGINE_EMISSION_FADEOUT_START_AGE = 2.2
local ENGINE_EMISSION_FADEOUT = 0.7

---Initialize submunitions
---@param self Shell
local function subInit(self)
    self.secondary.submunitions = {}

    for index = 1, MISSILE_AMOUNT_PER, 1 do
        local rotation = QuatEuler(0, 360 * math.random(), 0)
        local distance = Vec(MISSILE_MAX_OFFSET_DISTANCE * math.random(), 0, 0)

        local transform = Transform(
            TransformToParentPoint(
                Transform(VecCopy(self.position), rotation),
                distance
            ),
            rotation
        )

        ---@type SubIncendiary
        local sub = FdObjectNew({
            index = index,
            active = false,
            age = 0,
            delay = (index - 1) * MISSILE_DELAY_BETWEEN,
            transform = TransformCopy(transform),
            velocity = Vec(0, 0, 0),
        }, DEFAULT_SUBMUNITION)

        local vel_to_sub = TransformToLocalVec(sub.transform, VecNormalize(self.secondary.inertia))
        vel_to_sub = VecScale(vel_to_sub, VecLength(self.secondary.inertia))
        sub.velocity = VecAdd(sub.velocity, vel_to_sub)

        table.insert(self.secondary.submunitions, sub)
    end

    FdWatch("SUBMUNITIONS(amount)", #self.secondary.submunitions)
end

---Tick submunitions
---@param self SubM31A1
---@param delta number
---@param variant any
---@return boolean continue
---@return TTransform? new_transform
local function subTick(self, delta, variant)
    self.age = self.age + delta

    local gravity = math.abs(G_VEC_GRAVITY[2])
    local world_down = TransformToLocalVec(self.transform, Vec(0, -1, 0))

    self.velocity = VecAdd(self.velocity, VecScale(world_down, gravity * delta))

    local position_new = TransformToParentPoint(self.transform, VecScale(self.velocity, delta))
    local transform_new = Transform(position_new, self.transform.rot)

    local hit, hit_distance = QueryRaycast(self.transform.pos, VecNormalize(VecSub(position_new, self.transform.pos)),
        VecLength(VecSub(position_new, self.transform.pos)))
    if not hit then
        FdAddToDebugTable(DEBUG_LINES, { self.transform.pos, transform_new.pos, FdGetRGBA(COLOUR["orange"], 0.15) })

        local emission_fadein = FdClamp(self.age / ENGINE_EMISSION_FADEIN, 0, 1)
        local emission_fadeout = 1 -
            FdClamp((self.age - ENGINE_EMISSION_FADEOUT_START_AGE) / ENGINE_EMISSION_FADEOUT, 0, 1)

        local emission_intensity = math.min(emission_fadein, emission_fadeout) * ENGINE_EMISSION_INTENSITY

        PointLight(
            self.transform.pos,
            ENGINE_EMISSION_COLOUR[1],
            ENGINE_EMISSION_COLOUR[2],
            ENGINE_EMISSION_COLOUR[3],
            emission_intensity
        )

        return true, transform_new
    end

    local position_hit = VecAdd(self.transform.pos,
        VecScale(VecNormalize(VecSub(position_new, self.transform.pos)), hit_distance))

    FdAddToDebugTable(DEBUG_LINES, { self.transform.pos, position_hit, COLOUR["orange"] })
    FdAddToDebugTable(DEBUG_POSITIONS, { position_hit, COLOUR["white"] })

    -- Random roll if submunition is a dud
    if CfgGetValue("G_SIMULATE_UXO") and math.random(100) <= 2 then
        FdLog("Submunition at index " .. self.index .. " is a dud.")
        MakeHole(position_hit, 0.5, 0.1, 0, false)

        return false, nil
    end

    Explosion(position_hit, variant.size_explosion)

    local weak, median, strong = unpack(variant.size_makehole)
    MakeHole(position_hit, weak, median, strong, false)

    return false, nil
end

---M31A1 entrypoint
---@param self Shell
---@param delta number
---@param variant any
function ShellSecTickM31A1(self, delta, variant)
    if self.secondary.timer < 0 then return true end

    if not FdAssertTableKeys(self, "secondary", "submunitions") then
        subInit(self)
    end

    if #self.secondary.submunitions == 0 then return true end

    for index, sub in ipairs(self.secondary.submunitions) do
        ---@cast sub SubM31A1
        local _ = (function()
            if not sub.active and sub.delay <= 0 then
                sub.active = true
            end

            if not sub.active then
                sub.delay = sub.delay - delta
                return
            end

            local continue, transform_new = subTick(sub, delta, variant)
            if not continue then
                table.remove(self.secondary.submunitions, index)
                return
            end

            sub.transform = transform_new
        end)()
    end

    FdWatch("SUBMUNITIONS(amount)", #self.secondary.submunitions)
    return false
end
