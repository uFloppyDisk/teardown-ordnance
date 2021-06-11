function clamp(value, minimum, maximum)
	if value < minimum then value = minimum end
	if value > maximum then value = maximum end

	return value
end

function print(msg)
    if not G_DEV then
        return
    end

    DebugPrint(msg)
end

function watch(name, variable)
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
	local direction = VecNormalize(direction)

	local hit, hit_distance = QueryRaycast(camera_transform.pos, direction, distance)

	if hit then
		camera_center = TransformToParentPoint(camera_transform, Vec(0, 0, -hit_distance))
		distance = hit_distance
	end

	return camera_center, hit, distance
end

function draw_circle(position, radius, points, colour)
    if not(radius > 0) then
        return
    end

    points = points or 16
    colour = colour or {1, 0, 0, 0.8}

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