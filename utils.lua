function clamp(value, minimum, maximum)
	if value < minimum then value = minimum end
	if value > maximum then value = maximum end

	return value
end

function round(number, digits)
    local power = 10^(digits or 0)
    return math.floor((number * power) + 0.5) / power
end

function getRGBA(colour, alpha)
    local c = {unpack(colour)}

    table.insert(c, 4, alpha)
    return c
end

function assertTableKeys(root, ...)
    for i, key in ipairs(arg) do
        if root[key] == nil then return false end

        root = root[key]
    end

    return true
end

function addToDebugTable(target, value)
    if not G_DEV then
        return
    end

    table.insert(target, value)
end

function dPrint(msg)
    if not G_DEV then
        return
    end

    DebugPrint(msg)
end

function dWatch(name, variable)
    if not G_DEV then
        return
    end

    DebugWatch(name, variable)
end

function getAimPos()
	local camera_transform = GetCameraTransform()
	local camera_center = TransformToParentPoint(camera_transform, Vec(0, 0, -150))

    local direction = VecSub(camera_center, camera_transform.pos)
    local distance = VecLength(direction)
	direction = VecNormalize(direction)

	local hit, hit_distance = QueryRaycast(camera_transform.pos, direction, distance)

	if hit then
		camera_center = TransformToParentPoint(camera_transform, Vec(0, 0, -hit_distance))
		distance = hit_distance
	end

	return camera_center, hit, distance
end

function getMousePosInWorld(set_distance)
    local dist = 200
    if set_distance ~= nil then dist = set_distance end

	local camera_transform = GetCameraTransform()
    local m_pos_x, m_pos_y = STATES_TACMARK.mouse_pos[1], STATES_TACMARK.mouse_pos[2]
    if m_pos_x == nil or m_pos_y == nil then
        m_pos_x = UiCenter()
        m_pos_y = UiMiddle()
    end

    local direction = UiPixelToWorld(m_pos_x, m_pos_y)

    local hit_position = VecAdd(camera_transform.pos, VecScale(direction, dist))

    local hit, hit_distance = QueryRaycast(camera_transform.pos, direction, dist)
    if not hit then
        hit, hit_distance = QueryRaycast(camera_transform.pos, direction, 500)
    end

	if hit then
        hit_position = VecAdd(camera_transform.pos, VecScale(direction, hit_distance))
    end

	return hit_position, hit, hit_distance
end

function drawCircle(position, radius, points, colour)
    if not (radius > 0) then
        return
    end

    points = points or 16
    colour = colour or getRGBA(COLOUR["red"], 0.8)

    local step = (math.pi * 2) / points

    local theta = 0
    local point_x = position[1] + radius * math.cos(theta)
    local point_y = position[2]
    local point_z = position[3] - radius * math.sin(theta)

    repeat
        theta = theta + step

        local new_point_x = position[1] + radius * math.cos(theta)
        local new_point_z = position[3] - radius * math.sin(theta)

        DrawLine(Vec(point_x, point_y, point_z), Vec(new_point_x, point_y, new_point_z),  colour[1], colour[2], colour[3], colour[4])

        point_x = new_point_x
        point_z = new_point_z

    until (theta > math.pi * 2)
end

function objectNew(new, base_object)
    local base = objectCopy(base_object)
    for key, value in pairs(new) do
        base[key] = value
    end

    return base
end

function objectCopy(object)
    local copy
    if type(object) == 'table' then
        copy = {}
        for key, value in pairs(object) do
            copy[objectCopy(key)] = objectCopy(value)
        end
        setmetatable(copy, objectCopy(getmetatable(object)))
    else
        copy = object
    end
    return copy
end

function getRecursiveMaterialsInRaycast(pos, pos_new, hit_pos, shell_radius, materials, shapes, depth)
    if depth < 0 or depth == nil then
        dPrint("Max depth reached.")
        return materials, hit_pos, true
    end

    for index, shape in pairs(shapes) do
        QueryRejectShape(shape)
    end

    QueryRequire('large')
    QueryRequire("physical")
    local hit, distance, normal, shape = QueryRaycast(pos, VecNormalize(VecSub(pos_new, pos)), VecLength(VecSub(pos_new, pos), shell_radius))
    if not hit then
        return materials, hit_pos, false
    end

    table.insert(shapes, shape)

    local position_hit = VecAdd(pos, VecScale(VecNormalize(VecSub(pos_new, pos)), distance))
    addToDebugTable(DEBUG_POSITIONS, {position_hit, COLOUR["white"]})
    local material = GetShapeMaterialAtPosition(shape, (position_hit))

    table.insert(materials, material)
    table.insert(hit_pos, VecCopy(position_hit))

    dPrint("Hit shape with material '"..material.."'")
    return getRecursiveMaterialsInRaycast(pos, pos_new, hit_pos, shell_radius, materials, shapes, depth - 1)
end