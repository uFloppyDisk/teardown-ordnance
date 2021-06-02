function draw_circle(position, radius, points)
    if not(radius > 0) then
        return
    end

    points = points or 16

    local step = (math.pi * 2) / points

    local theta = 0
    local point_x = position[1] + radius * math.cos(theta)
    local point_y = position[2]
    local point_z = position[3] - radius * math.sin(theta)

    repeat
        theta = theta + step

        local new_point_x = position[1] + radius * math.cos(theta)
        local new_point_z = position[3] - radius * math.sin(theta)

        DrawLine(Vec(point_x, point_y, point_z), Vec(new_point_x, point_y, new_point_z),  1, 0, 0, 0.8)

        point_x = new_point_x
        point_z = new_point_z

    until (theta > math.pi * 2)
end