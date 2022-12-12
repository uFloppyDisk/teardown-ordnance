function clamp(value, minimum, maximum)
	if value < minimum then value = minimum end
	if value > maximum then value = maximum end

	return value
end

function round(number, digits)
    local power = 10^(digits or 0)
    return math.floor((number * power) + 0.5) / power
end

function mapToRange(input, in_start, in_end, out_start, out_end)
    return out_start + (input - in_start) * (out_end - out_start) / (in_end - in_start)
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

function setEnvProps(env)
    for k, v in pairs(env) do
        SetEnvironmentProperty(k, unpack(v))
    end
end

function setPostProcProps(pp)
    for k, v in pairs(pp) do
        SetPostProcessingProperty(k, unpack(v))
    end
end

function VecEqual(vec, vec2)
    local vecToCompare = VecCopy(vec)

    if vecToCompare[1] ~= vec2[1] then return false end
    if vecToCompare[2] ~= vec2[2] then return false end
    if vecToCompare[3] ~= vec2[3] then return false end

    return true
end

function getPlayerTransform()
    local current_transform = GetPlayerCameraTransform()
    return Transform(VecCopy(current_transform.pos), current_transform.rot)
end

function getCameraTransform(transform, set_offset, set_rot, rot_absolute)
    local offset = set_offset or Vec(0, 0, 0)
    local rot = set_rot or QuatEuler(-90, 0, 0)
    rot_absolute = rot_absolute or true

    if not rot_absolute then
        rot = QuatRotateQuat(transform.rot, rot)
    end

    return Transform(VecAdd(transform.pos, offset), rot)
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
    position = position or Vec(0, 0, 0)
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

    local iter = 0
    repeat
        theta = theta + step

        local new_point_x = position[1] + radius * math.cos(theta)
        local new_point_z = position[3] - radius * math.sin(theta)

        local pos_start, pos_end = Vec(point_x, point_y, point_z), Vec(new_point_x, point_y, new_point_z)
        DrawLine(pos_start, pos_end, colour[1], colour[2], colour[3], colour[4])

        if iter % 2 == 0 then
            DebugLine(pos_start, pos_end, unpack(colour))
        end

        point_x = new_point_x
        point_z = new_point_z
        iter = iter + 1
    until (theta > math.pi * 2)
end

function drawHeading(transform, length, colour)
    if not (length > 0) then
        return
    end

    colour = colour or getRGBA(COLOUR["red"], 0.8)

    local pos_end = TransformToParentPoint(transform, Vec(length, 0, 0))
    DrawLine(transform.pos, pos_end, unpack(colour))
    DebugLine(transform.pos, pos_end, unpack(colour))

    return pos_end
end

function drawPitchHeadingLine(transform, length, colour, lines)
    transform = transform or Transform(Vec(0, 0, 0), QuatEuler(0, 0, 0))
    length = length or 1
    colour = colour or {1, 1, 1, 1}
    lines = lines or 6

    local pos_start = transform.pos
    local pos_end = TransformToParentPoint(transform, Vec(length, 0, 0))
    DrawLine(pos_start, pos_end, unpack(colour))
    DebugLine(transform.pos, pos_end, unpack(colour))

    local pos_horizontal_end = nil
    for i = 1, lines, 1 do
        local vec_interim = VecLerp(pos_start, pos_end, ((1 / lines) * i))

        local vec_interim_end = Vec(vec_interim[1], pos_start[2], vec_interim[3])
        DrawLine(vec_interim, vec_interim_end, unpack(colour))

        if i == lines then
            pos_horizontal_end = vec_interim_end
            DebugLine(vec_interim, vec_interim_end, unpack(colour))
        end
    end

    return pos_end, pos_horizontal_end
end

function drawShellImpactGizmo(telemetry, radius, points, colour, lines)
    telemetry = telemetry or {
        Vec(0, 0, 0), 0, 90
    }
    radius = math.abs(radius)
    colour = colour or COLOUR["yellow_dark"]
    lines = lines or 1

    telemetry[1] = VecAdd(telemetry[1], Vec(0, 0.03, 0))

    local transform_aim_shell_both = Transform(telemetry[1], QuatEuler(0, telemetry[2], telemetry[3]))

    if telemetry[3] == 90 then lines = 0 end
    local pos_pitch_end, pos_heading_end = drawPitchHeadingLine(transform_aim_shell_both, 2.25, colour, lines)

    local transform_aim_shell_heading = Transform(telemetry[1], QuatEuler(0, telemetry[2], 0))

    local length_heading = VecLength(VecSub(telemetry[1], pos_heading_end))
    if radius > length_heading then length_heading = radius end

    if telemetry[3] < 90 then
        drawHeading(transform_aim_shell_heading, length_heading, colour)
    end

    if radius <= 0 then
        return transform_aim_shell_both, pos_pitch_end, pos_heading_end
    end

    points = points or 16

    drawCircle(telemetry[1], radius, points, colour)

    return transform_aim_shell_both, pos_pitch_end, pos_heading_end
end

function drawUIShellImpactGizmo(static, colour, x, y)
    if static == nil then static = false end

    local heading = math.abs(math.ceil((((STATES.selected_attack_heading + 270) % 360) * -1) + 359))

    if static then
        -- TODO: Static UI display
        if x == nil then x = 0 end
        if y == nil then y = 0 end
        if colour == nil then colour = {0, 0, 0, 1} end

        local length = 100
        local pitch = STATES.selected_attack_angle
        local length_base = math.cos(math.rad(pitch)) * length
        local length_vert = math.sin(math.rad(pitch)) * length

        pitch = round(pitch)
        heading = round(heading)

        UiPush()
            UiTranslate(x * 0.7, y * 5)

            UiPush()
                local margins = {5, 5}
                local extra = {0, 0}
                UiTranslate(-margins[1], -(margins[2] + length))

                UiColor(0, 0, 0, 0.1)
                UiRect(length + (margins[1] * 2) + extra[1], length + (margins[2] * 2) + extra[2])
            UiPop()

            UiAlign("left")
            UiFont("regular.ttf", 26)
            UiTextShadow(0, 0, 0, 1, 1, 1)
            UiColor(unpack(getRGBA(colour, 0.5)))

            if pitch ~= 90 then
                UiPush()
                    UiRect(length_base, 3)

                    UiPush()
                        local ui_text_heading = heading.."°"
                        local _, size_y = UiGetTextSize(ui_text_heading)
                        UiTranslate(length_base / 2, size_y + 2)

                        UiAlign('center')
                        UiColor(1, 1, 1, 1)

                        UiText(heading.."°")
                    UiPop()

                    UiPush()
                        UiTranslate(length_base, -length_vert)
                        UiRect(2, length_vert)
                    UiPop()
                UiPop()
            end

            UiPush()
                UiRotate(STATES.selected_attack_angle)

                UiColor(unpack(colour))
                UiRect(length, 5)
            UiPop()

            UiPush()
                local ui_text_pitch = pitch.."°"
                local _, size_y = UiGetTextSize(ui_text_pitch)
                UiTranslate(length_base + 5, -(length_vert - (size_y * 0.8)))

                UiColor(1, 1, 1, 1)
                UiText(pitch.."°")
            UiPop()
        UiPop()

        return
    end

    UiPush()
        UiMakeInteractive()

        if not STATES_TACMARK.enabled then -- TODO: Add text offset based on distance to prevent overcrowding
            UiTranslate(UiWidth() / 2, UiHeight() / 2)

            local ui_pos_root = {UiWorldToPixel(UI_HELPERS.shell_telemetry.combined_transform.pos)}

            if ui_pos_root[3] > 65 then
                UiPop()
                return
            end

            UiAlign("left")
            UiFont("regular.ttf", 26)
            UiTextShadow(0, 0, 0, 2, 1, 1)

            local ui_pos_pitch = {UiWorldToPixel(UI_HELPERS.shell_telemetry.arrow_pitch_pos)}

            UiPush()
                UiTranslate(ui_pos_pitch[1], ui_pos_pitch[2])
                UiText(round(STATES.selected_attack_angle).."°", true)
            UiPop()

            if UI_HELPERS.shell_telemetry.arrow_heading_pos == nil then
                UiPop()
                return
            end

            local ui_pos_heading = nil
            local pos_diff = {100, 100}

            if UI_HELPERS.shell_telemetry.arrow_heading_pos ~= nil then
                ui_pos_heading = {UiWorldToPixel(UI_HELPERS.shell_telemetry.arrow_heading_pos)}
                pos_diff = {math.abs(ui_pos_pitch[1] - ui_pos_heading[1]), math.abs(ui_pos_pitch[2] - ui_pos_heading[2])}
            end

            UiPush()
                if ui_pos_root[3] < 23 then
                    local offset_x, offset_y = 15, -12
                    local size_x, size_y = UiGetTextSize(heading.."°")

                    if pos_diff[1] > size_x or pos_diff[2] > size_y then
                        if ui_pos_heading[1] < 0 then
                            UiAlign('right')
                            offset_x = -offset_x
                        end
                    else
                        offset_y = -offset_y + size_y

                        offset_x = 0
                        UiAlign('center')
                    end

                    UiTranslate(ui_pos_heading[1] + offset_x, ui_pos_heading[2] + offset_y)
                    UiText(heading.."°", true)
                else
                    local offset_extra = mapToRange(ui_pos_root[3], 25, 150, 0, 7)
                    UiTranslate(0, 25 + offset_extra)

                    UiAlign('center')
                    UiText(heading.."°", true)
                end
            UiPop()
        else
            -- TODO: Tactical mark pitch/heading value display
        end
    UiPop()
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

function getMaterialsInRaycastRecursive(pos, pos_new, hit_pos, shell_radius, materials, shapes, depth)
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
    return getMaterialsInRaycastRecursive(pos, pos_new, hit_pos, shell_radius, materials, shapes, depth - 1)
end