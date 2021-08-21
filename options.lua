#include "constants.lua"
#include "utils.lua"
#include "classes/Option.lua"

MENU = {
    spacing_option = 20,
    offset_rect_correction = -8,
    offset_option_slider = {-5, -7}
}

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
    local range = option.value_max - option.value_min
    value = (value - option.value_min) / (range)

    UiPush()
        UiAlign("left")
        UiTranslate(MENU.spacing_option, MENU.offset_rect_correction)
        UiRect(option.width, 3)
        UiTranslate(MENU.offset_option_slider[1], MENU.offset_option_slider[2])

        value = UiSlider("ui/common/dot.png", "x", value * option.width, 0.0, option.width) / option.width
        value = round((value * range + option.value_min), option.value_digits)

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
        UiButtonHoverColor(1, 1, 0.5)
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

function init()
    STATES = {
        confirm_reset = 0
    }

    if CONFIG:init() then
        STATES.confirm_reset = 3
    end

    OPTIONS = {}
    for index, data in ipairs(CONFIG_OPTIONS) do
        local option = OPTION:new(data)

        table.insert(OPTIONS, option)
    end
end

function draw()
    if InputDown("ctrl") and InputDown("alt") and InputPressed("C") then
        CONFIG:reset(true)
        OPTIONS = {}
        Menu()
        return
    end

    if InputDown("shift") and InputPressed("C") then
        STATES.confirm_reset = 2
    end

    UiPush()
        margins = {}
        margins.x0, margins.y0, margins.x1, margins.y1 = UiSafeMargins()
        UiTranslate(UiCenter(), 250)
        UiAlign("center middle")

        -- Title
        UiFont("bold.ttf", 48)
        UiText("Ordnance Options", true)

        -- Options
        UiFont("regular.ttf", 28)

        for i, option in ipairs(OPTIONS) do
            if option.type == "textbutton" then
                wrapButton(option)
            end

            if option.type == "slider" then
                wrapSlider(option)
            end

            UiTranslate(0, option.height + 20)
        end
        UiTranslate(0, 30)

        UiFont("bold.ttf", 28)

        UiPush()
            UiTranslate(-20, 0)
            UiAlign("right")
            UiButtonHoverColor(1, 0.3, 0)
            if UiTextButton("RESET", 100, 50) then
                STATES.confirm_reset = 1
            end
        UiPop()

        UiPush()
            UiTranslate(15, 0)
            UiAlign("left")
            UiButtonHoverColor(1, 1, 0.5, 1)
            if UiTextButton("BACK", 100, 50) then
                Menu()
            end
        UiPop()
    UiPop()

    if STATES.confirm_reset > 0 then
        if STATES.confirm_reset == 3 then reset(true) else reset() end
    end
end

function reset(force_reset)
    UiBlur(0.5)
    UiPush()
        margins = {}
        margins.x0, margins.y0, margins.x1, margins.y1 = UiSafeMargins()

        box = {}
        if force_reset then
            box = {
                width = (margins.x1 - margins.x0) / 4,
                height = (margins.y1 - margins.y0) / 5
            }
        else
            box = {
                width = (margins.x1 - margins.x0) / 5,
                height = (margins.y1 - margins.y0) / 6
            }
        end

        UiModalBegin()
            UiAlign("center middle")
            UiTranslate(UiCenter(), UiMiddle())

            UiColor(1, 1, 1)
            UiRect(box.width + 5, box.height + 5)

            UiColor(0, 0, 0)
            UiRect(box.width, box.height)

            UiPush()
                UiAlign("center top")
                UiTranslate(0, (box.height / 2 * -1) + box.height / 20)
                UiFont("bold.ttf", 28)
                UiColor(1, 1, 1)
                if force_reset then
                    UiText("NOTICE", true)

                    UiFont("regular.ttf", 28)
                    UiWordWrap(box.width - 30)

                    UiText("This configuration is corrupted or incompatible with the current version.", true)
                    UiText("All values will be reset.")
                else
                    UiText("CONFIRM RESET", true)

                    UiFont("regular.ttf", 28)
                    UiWordWrap(box.width - 30)
                    if STATES.confirm_reset == 2 then
                        UiText("Do you want to DELETE all 'Ordnance' mod registry keys and restore defaults?")
                    else
                        UiText("Are you sure you want to RESET all settings to default values?")
                    end
                end
            UiPop()

            UiAlign("center top")
            UiTranslate(0, (box.height / 2) / 2)

            UiFont("bold.ttf", 28)
            UiColor(1, 1, 1, 1)
            UiButtonHoverColor(1, 1, 0.5, 1)

            if force_reset then
                UiPush()
                    UiAlign("center")

                    if UiTextButton("OK", ((box.width / 2) - 25), (box.height / 5)) then
                        CONFIG:reset()
                        OPTIONS = {}

                        Menu()
                        return
                    end
                UiPop()
            else
                UiPush()
                    UiAlign("right")
                    UiTranslate(((box.width / 2) / 5) * -1, 0)

                    UiButtonHoverColor(1, 0.1, 0.1, 1)
                    if UiTextButton("YES", ((box.width / 2) - 25), (box.height / 5)) then
                        if STATES.confirm_reset == 2 then
                            CONFIG:reset()
                            OPTIONS = {}

                            Menu()
                            return
                        end

                        if STATES.confirm_reset == 1 then
                            for i, option in ipairs(OPTIONS) do
                                option:setRegValue(option.mapping.value_default)
                            end
                        end

                        STATES.confirm_reset = 0
                    end
                UiPop()

                UiPush()
                    UiAlign("left")
                    UiTranslate(((box.width / 2) / 5), 0)

                    if UiTextButton("NO", ((box.width / 2) - 25), (box.height / 5)) then
                        STATES.confirm_reset = 0
                    end
                UiPop()
            end
        UiModalEnd()
    UiPop()
end

-- #endregion
