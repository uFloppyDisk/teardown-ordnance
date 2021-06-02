MENU = {
    spacing_option = 20,
    offset_rect_correction = -8,
    offset_option_slider = {-5, -7}
}

-- #region Option Class

OPTION = {
    type = "textbutton",
    variable = nil,
    name = "Button",

    value_type = "boolean",
    value_unit = nil,
    value_digits = 1,
    value_default = nil,
    value_min = 0,
    value_max = 1,
    value = nil,

    width = 100,
    height = 30
}

function OPTION:new (o)
    local object = o or {}
    setmetatable(object, self)
    self.__index = self

    return object
end

function OPTION:getRegValue ()
    local func = nil

    if self.value_type == nil then return nil end
    if self.value_type == "boolean" then func = GetBool end
    if self.value_type == "int" then func = GetInt end
    if self.value_type == "float" then func = GetFloat end
    if self.value_type == "string" then func = GetString end

    return func(self.variable)
end

function OPTION:setRegValue (value)
    local func = nil

    if self.value_type == nil then return nil end
    if self.value_type == "boolean" then func = SetBool end
    if self.value_type == "int" then func = SetInt end
    if self.value_type == "float" then func = SetFloat end
    if self.value_type == "string" then func = SetString end

    return func(self.variable, value)
end

-- #endregion

-- #region Components

function wrapOption(option)
    UiAlign("right")
    UiText("|")
    UiPush()
        UiTranslate(MENU.spacing_option * -1, 0)
        UiText(option.name)
    UiPop()
end

function wrapSlider(option)
    UiPush()
        wrapOption(option)
        local value = drawSlider(option)

        UiAlign("left")
        UiTranslate(option.width + (MENU.spacing_option * 2), 0);
        UiText(value.." "..option.value_unit);
    UiPop()
end

function drawSlider(option)
    local value = option:getRegValue()
    value = (value - option.value_min) / (option.value_max - option.value_min)

    UiPush()
        UiAlign("left")
        UiTranslate(MENU.spacing_option, MENU.offset_rect_correction)
        UiRect(option.width, 3)
        UiTranslate(MENU.offset_option_slider[1], MENU.offset_option_slider[2])

        value = UiSlider("ui/common/dot.png", "x", value * option.width, 0.0, option.width) / option.width
        if option.value_type == "float" then
            value = round((value * (option.value_max - option.value_min) + option.value_min), option.value_digits)
        elseif option.value_type == "int" then
            value = math.floor(value * (option.value_max - option.value_min) + option.value_min)
        end

    UiPop()

    option.value = value
    option:setRegValue(value)

    return value
end

function wrapButton(option)
    UiPush()
        wrapOption(option)
        drawButton(option)
    UiPop()
end

function drawButton(option)
    UiPush()
        UiAlign("left")
        UiTranslate(MENU.spacing_option, 0)
        UiButtonHoverColor(1, 1, 0)
        local value = option:getRegValue()
        if UiTextButton(value, option.width, option.height) then
            option.value = not value
            option:setRegValue(option.value)
        end
    UiPop()

    return value
end

-- #endregion Components

-- #region Main

function reset()
    for i, option in ipairs(OPTIONS) do
        option:setRegValue(option.value_default)
    end
end

function clamp(value, minimum, maximum)
	if value < minimum then value = minimum end
	if value > maximum then value = maximum end

	return value
end

function round(number, digits)
    local power = 10^digits
    return math.floor(number * power) / power
end

function init()
    OPTIONS = {
        OPTION:new({
            type = "textbutton",
            variable = "savegame.mod.debug_mode",
            name = "Debug Mode",

            value_type = "boolean",
            value_default = false,
            value = nil
        }),
        OPTION:new({
            type = "textbutton",
            variable = "savegame.mod.simulate_dud",
            name = "Simulate Dud Rate (2%)",

            value_type = "boolean",
            value_default = false,
            value = nil
        }),
        OPTION:new({
            type = "slider",
            variable = "savegame.mod.flight_time",
            name = "Flight Time",

            value_type = "float",
            value_unit = "second(s)",
            value_default = 0.0,
            value = nil,

            value_min = 0,
            value_max = 25
        }),
        OPTION:new({
            type = "slider",
            variable = "savegame.mod.shell_inaccuracy",
            name = "Shell Inaccuracy",

            value_type = "float",
            value_unit = "meter(s)",
            value_digits = 1,
            value_default = 5.0,
            value = nil,

            value_min = 0,
            value_max = 50
        }),
        OPTION:new({
            type = "slider",
            variable = "savegame.mod.quick_salvo_delay",
            name = "Delay between shells (Quick Salvo)",

            value_type = "float",
            value_unit = "second(s)",
            value_digits = 2,
            value_default = 0.5,
            value = nil,

            value_min = 0.2,
            value_max = 5
        })
    }
end

function draw()
    if InputDown("shift") and InputPressed("C") then
        ClearKey("savegame.mod.crash_disclaimer")
        for i, option in ipairs(OPTIONS) do
            ClearKey(option.variable)
        end
    end

	UiTranslate(UiCenter(), 250)
	UiAlign("center middle")

	-- Title
	UiFont("bold.ttf", 48)
	UiText("Ordnance Options", true)

    -- Options
    UiFont("regular.ttf", 28)
    
    for i, option in ipairs(OPTIONS) do
        if not HasKey(option.variable) then
            option.value = option.value_default
            option:setRegValue(option.value_default)
        end

        if option.type == "textbutton" then
            wrapButton(option)
        end

        if option.type == "slider" then
            wrapSlider(option)
        end

        UiTranslate(0, option.height + 20)
    end
    UiTranslate(0, 30)

    UiButtonHoverColor(1, 0.3, 0)
    if UiTextButton("Reset", 100, 50) then
        reset()
    end
end

-- #endregion
