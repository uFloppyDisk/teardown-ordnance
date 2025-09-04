ProjectileUtil = {}

---comment
---@param destination TVec
---@param targetVelocity number
---@param heading number
---@param pitch number
---@param requestedFlightTime? number Requested projectile flight time
---@return TTransform transform Solved transform at apex
---@return TVec velocity Solved velocity at apex (usually, near-zero vertical velocity)
---@return number timeUntilDestination Actual time until destination
function ProjectileUtil.solveKinematicsAtApex(destination, targetVelocity, heading, pitch, requestedFlightTime)
    local heading_radians = math.rad((heading + 90) % 360)
    local heading_x = math.sin(heading_radians)
    local heading_z = math.cos(heading_radians)
    local heading_vec = Vec(heading_x, 0, heading_z)

    local pitch_radians = math.rad(pitch)

    local velocity_horizontal = targetVelocity * math.cos(pitch_radians)
    local velocity_vertical = targetVelocity * math.sin(pitch_radians)
    local velocity_vec = VecScale(heading_vec, velocity_horizontal)

    local apex_time = (targetVelocity * math.sin(pitch_radians)) / math.abs(G_VEC_GRAVITY[2])
    local time = apex_time
    if requestedFlightTime ~= nil and requestedFlightTime <= apex_time then
        time = requestedFlightTime
    end

    local xz_at_time = VecAdd(VecScale(velocity_vec, time), VecCopy(destination))
    local y_at_time = -0.5 * (math.abs(G_VEC_GRAVITY[2]) * (time * time)) -- -1/2gt^2
    y_at_time = y_at_time + (velocity_vertical * time) + destination[2] -- + (vy0)t + y0

    local solvedTransform = Transform(Vec(xz_at_time[1], y_at_time, xz_at_time[3]))
    local solvedVelocity = Vec(-velocity_vec[1], -velocity_vertical - (G_VEC_GRAVITY[2] * time), -velocity_vec[3])

    return solvedTransform, solvedVelocity, time
end

---comment
---@param current_pos TVec
---@param previous_pos TVec
---@param current_time number
---@param previous_time? number
---@return TVec
function ProjectileUtil.calculatePerTickPosition(current_pos, previous_pos, current_time, previous_time)
    if previous_time == nil then
        return current_pos
    end

    local lerp = (current_time - previous_time) / PROJECTILE_UPDATE_DELTA
    local pos = VecLerp(previous_pos, current_pos, lerp)

    return pos
end

---comment
---@param sprite ProjectileSprite
---@param position TVec
---@param heading number
---@param pitch number
function ProjectileUtil.drawSprite(sprite, position, heading, pitch)
    local fake_shell = {
        heading = heading,
        pitch = pitch,
        position = position,
        sprite = {
            img = sprite.handle,
            width = sprite.width,
            scaling_factor = sprite.aspect_ratio,
        },
    }
    ShellDrawSprite(fake_shell)
end

---comment
---@param current_transform TTransform
---@param previous_transform TTransform
---@return boolean
---@return TVec|nil
function ProjectileUtil.hitscan(current_transform, previous_transform)
    local position_difference = VecSub(current_transform.pos, previous_transform.pos)

    QueryRequire("large")
    QueryRequire("physical")
    local hit, hit_distance, _, _ =
        QueryRaycast(current_transform.pos, VecNormalize(position_difference), VecLength(position_difference))
    if hit then
        local detonate_position =
            VecAdd(current_transform.pos, VecScale(VecNormalize(position_difference), hit_distance))

        return hit, detonate_position
    end

    return false, nil
end

---comment
---@param origin TVec
---@param deviationMetres? number
---@return TVec
function ProjectileUtil.calcDeviation(origin, deviationMetres)
    if deviationMetres == nil or deviationMetres <= 0 then
        return origin
    end

    local rotation = QuatEuler(0, 360 * math.random(), 0)
    local offset_vec = Vec(deviationMetres * math.random(), 0, 0)

    local transform = Transform(VecCopy(origin), rotation)
    return TransformToParentPoint(transform, offset_vec)
end

---comment
---@param pos TVec Explosion origin
---@param yield? number Explosion size
---@param hole_sizes? ProjectileMakeHoleSizes
function ProjectileUtil.detonate(pos, yield, hole_sizes)
    FdAddToDebugTable(DEBUG_POSITIONS, { pos, COLOUR["red"] })

    local hole = hole_sizes or {}
    MakeHole(pos, hole.soft or 0, hole.medium or 0, hole.hard or 0, false)

    if not yield or yield <= 0 then
        return
    end

    Explosion(pos, yield)
end

---@class DrawSalvoMarkerOptions
---@field deviation? number
---@field heading? number
---@field pitch? number
---@field display? DISPLAY_STATE

---comment
---@param destination TVec
---@param options DrawSalvoMarkerOptions
function ProjectileUtil.drawSalvoMarker(destination, options)
    local display = options.display or DISPLAY_STATE.HIDDEN
    local deviation = options.deviation or 0
    local heading = options.heading or 0
    local pitch = options.pitch or 90

    local colour = COLOUR["red"]

    if display == DISPLAY_STATE.HIDDEN then
        return
    end

    if display == DISPLAY_STATE.MINIMAL then
        local offset = Vec(0, 0.03, 0) -- Offset shapes to prevent Z-fighting
        local pos = VecAdd(destination, offset)
        local width = 0.2
        local vertices = 8
        FdDrawCircle(pos, width, vertices, colour)
    else
        local vertices = 32
        local lines = 2
        local is_quick_salvo = true
        FdDrawShellImpactGizmo({ destination, heading, pitch }, deviation, vertices, colour, lines, is_quick_salvo)
    end
end
