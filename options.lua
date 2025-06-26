---@diagnostic disable:undefined-global
---@diagnostic disable:exp-in-action
#include "src/utils.lua"
#include "src/configmanager.lua"
#include "src/constants.lua"
#include "src/class/Option.lua"
---@diagnostic enable:undefined-global
---@diagnostic enable:exp-in-action

MENU = {
    spacing_tab = 25,
    spacing_option = 20,
    option = {
        vertical_space = 10,
    },
    offset_rect_correction = -8,
    offset_option_slider = {-5, -7}
}

-- #region Components

local function drawSlider(option)
    local value = option:getRegValue()
    local range = option.value_max - option.value_min
    value = (value - option.value_min) / (range)

    UiPush()
        UiAlign("left")
        UiTranslate(MENU.spacing_option, MENU.offset_rect_correction)
        UiRect(option.width, 3)
        UiTranslate(MENU.offset_option_slider[1], MENU.offset_option_slider[2])

        value = UiSlider("ui/common/dot.png", "x", value * option.width, 0.0, option.width) / option.width
        value = FdRound((value * range + option.value_min), option.value_digits)

    UiPop()

    option.value = value
    option:setRegValue(value)

    return value
end

local function drawButton(option)
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

local function wrapOption(option)
    UiAlign("right")
    UiText("|")
    UiPush()
        UiTranslate(MENU.spacing_option * -1, 0)
        UiText(option.name)
    UiPop()
end

local function wrapSlider(option)
    UiPush()
        wrapOption(option)
        local value = drawSlider(option)

        if option.value_display_exp > 1 then
            value = option.value_display_exp ^ value
        elseif option.value_display_factor > 1 then
            value = value * option.value_display_factor
        end

        UiAlign("left")
        UiTranslate(option.width + (MENU.spacing_option * 2), 0);
        UiText(value.." "..option.value_unit);
    UiPop()
end

local function wrapButton(option, draw_function)
    local func = draw_function or drawButton
    UiPush()
        wrapOption(option)
        func(option)
    UiPop()
end

local function drawButtonKeybinding(option)
    UiPush()
        UiAlign("left")
        UiTranslate(MENU.spacing_option, 0)
        UiButtonHoverColor(1, 1, 0.5)
        local display_value = CONFIG_KEYBIND_FRIENDLYNAMES[option:getRegValue()] or option:getRegValue()
        local display_width, display_height = UiGetTextSize(display_value)
        if UiTextButton(display_value, display_width, display_height) then
            STATES.set_keybind.target = option
            STATES.set_keybind.active = true
        end
    UiPop()

    return option.value
end

local function renderTextButton(option)
    if option.variant then
        if option.variant == "keybinding" then
            wrapButton(option, drawButtonKeybinding)
            return
        end
    end

    wrapButton(option)
end

local function renderSlider(option)
    wrapSlider(option)
end

local function renderSectionBreak(option)
    UiPush()
        UiAlign("center")
        local width = UiText(option.name, true)
        UiTranslate(0, -(MENU.spacing_option / 1.5))
        UiRect(MENU.spacing_tab + width, 2)
    UiPop()
end

local function modalSetKey(option)
    UiBlur(0.5)
    UiPush()
        local margins = {}
        margins.x0, margins.y0, margins.x1, margins.y1 = UiSafeMargins()

        local box = {
            width = (margins.x1 - margins.x0) / 4,
            height = (margins.y1 - margins.y0) / 5
        }

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
                UiText("Set Keybind", true)

                UiFont("regular.ttf", 28)

                local _, spacing_height = UiGetTextSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
                UiTranslate(0, spacing_height)

                UiWordWrap(box.width - 30)

                UiText("Keybind setting for:", true)

                UiPush()
                    UiFont("bold.ttf", 28)
                    _, spacing_height = UiGetTextSize(option.name)
                    UiText(option.name)
                UiPop()

                UiTranslate(0, spacing_height)

                UiText("Press Enter/Return to cancel.", true)
                if STATES.set_keybind.msg_error_duplicate_bind then
                    UiPush()
                        UiColor(1, 0.3, 0.3, 1)
                        UiText("Duplicate bind. Please try another key.", true)
                    UiPop()
                end

                local input = InputLastPressedKey()

                -- Ad lib loop to enable use of break for flow control
                while string.len(input) > 0 do
                    if input == "return" or input == "esc" then
                        STATES.set_keybind.active = false
                        STATES.set_keybind.target = nil
                        STATES.set_keybind.msg_error_duplicate_bind = false
                        break
                    end

                    if input == CfgGetValue(option.mapping) then
                        STATES.set_keybind.active = false
                        STATES.set_keybind.target = nil
                        STATES.set_keybind.msg_error_duplicate_bind = false
                        break
                    end

                    if CfgCheckConflict(G_CONFIG_KEYBINDS_ROOT, input) then
                        STATES.set_keybind.msg_error_duplicate_bind = true
                        break
                    end

                    CfgSetValue(option.mapping, input)
                    STATES.set_keybind.active = false
                    STATES.set_keybind.target = nil
                    STATES.set_keybind.msg_error_duplicate_bind = false
                    break
                end
        UiModalEnd()
    UiPop()
end

-- #endregion Components

-- #region Menus

local function renderMasthead(font_reg, font_selected)
    local function renderTab(index)
        local menu = CONFIG_MENUS[index]
        UiPush()
            if index == STATES.menu then
                UiFont(font_selected.type, font_selected.size)
                UiText(menu.title)
            else
                if UiTextButton(menu.title, menu.button_width, menu.button_height) then
                    STATES.menu = index
                end
            end
        UiPop()

        UiTranslate(menu.button_width + MENU.spacing_tab, 0)
    end

    local function renderMiddle(offsets)
        UiPush()
            UiAlign("left")
            UiTranslate((offsets[2] / 2) * -1, 0)

            local index = math.floor(#CONFIG_MENUS / 2) + 1
            renderTab(index)
        UiPop()
    end

    local function renderLeftSide(offsets)
        local total_translation = offsets[1]
        if offsets[2] > 0 then
            total_translation = total_translation + (MENU.spacing_tab * math.floor(#CONFIG_MENUS / 2))
            total_translation = total_translation + (offsets[2] / 2)
        else
            total_translation = total_translation + (MENU.spacing_tab * (#CONFIG_MENUS / 2))
        end

        total_translation = total_translation * -1

        UiPush()
            UiTranslate(total_translation, 0)
            for index = 1, #CONFIG_MENUS / 2, 1 do
                renderTab(index)
            end
        UiPop()

        if offsets[2] > 0 then
            renderMiddle(offsets)
        end
    end

    local function renderRightSide(offsets)
        local total_translation = MENU.spacing_tab / 2
        local amount_menus_right = #CONFIG_MENUS / 2 + 1
        if offsets[2] > 0 then
            total_translation = total_translation + (offsets[2] / 2)
            amount_menus_right = math.floor(#CONFIG_MENUS / 2) + 2
        end

        UiPush()
            UiTranslate(total_translation, 0)
            for index = amount_menus_right, #CONFIG_MENUS, 1 do
                renderTab(index)
            end
        UiPop()
    end

    UiFont(font_reg.type, font_reg.size)
    local masthead_offsets = { 0, 0, 0 }
    local max_line_width = MENU.spacing_tab * (#CONFIG_MENUS - 1)
    for index, menu in ipairs(CONFIG_MENUS) do
        UiPush()
            UiFont(font_selected.type, font_selected.size)
            local line_width, _ = UiGetTextSize(menu.title)
            max_line_width = max_line_width + line_width
        UiPop()
        UiPush()
            if index == STATES.menu then
                UiFont(font_selected.type, font_selected.size)
            end
            local width, height = UiGetTextSize(menu.title)
        UiPop()
        CONFIG_MENUS[index].button_width = width
        CONFIG_MENUS[index].button_height = height

        if (#CONFIG_MENUS % 2 == 0) then
            if (index <= (#CONFIG_MENUS / 2)) then
                masthead_offsets[1] = masthead_offsets[1] + width
            else
                masthead_offsets[3] = masthead_offsets[3] + width
            end
        else
            if (index == (math.floor(#CONFIG_MENUS / 2) + 1)) then
                masthead_offsets[2] = width
            elseif (index < (#CONFIG_MENUS / 2)) then
                masthead_offsets[1] = masthead_offsets[1] + width
            else
                masthead_offsets[3] = masthead_offsets[3] + width
            end
        end
    end

    UiPush()
        UiAlign("left")
        UiButtonHoverColor(0.7, 0.7, 0.7, 1)
        UiButtonPressDist(0, 4)
        renderLeftSide(masthead_offsets)
        renderRightSide(masthead_offsets)
    UiPop()


    UiPush()
        UiFont(font_selected.type, font_selected.size)
        local _, vertical_space = UiGetTextSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
    UiPop()

    UiTranslate(0, vertical_space - (vertical_space / 3))

    local line_height = 2
    UiRect(max_line_width, line_height)

    UiTranslate(0, (15 + line_height) * 2)
end

local function renderOption(option)
    if option.type == "textbutton" then renderTextButton(option) end
    if option.type == "slider" then renderSlider(option) end
    if option.type == "section_break" then renderSectionBreak(option) end

    UiTranslate(0, option.height + MENU.option.vertical_space)
end

local function renderMenu()
    local filter = CONFIG_MENUS[STATES.menu].filter

    UiPush()
        UiTranslate(UiCenter(), 100)
        UiAlign("center middle")

        -- Title
        UiFont("bold.ttf", 48)
        UiText("Ordnance Configuration", true)
        UiTranslate(0, 15)

        -- Menu masthead
        renderMasthead({type = "regular.ttf", size = 32}, {type = "bold.ttf", size = 32})

        -- Options
        UiFont("regular.ttf", 28)

        if filter == "advanced" then
            UiPush()
                UiFont("bold.ttf", 24)
                UiColor(FdGetUnpackedRGBA(COLOUR["red"]))

                local text = "WARNING: The following options are not intended for most users;\nChange at your own risk!"
                local _, height = UiGetTextSize(text)

                UiText(text)
            UiPop()

            UiTranslate(0, height + 20)
        end

        for _, option in ipairs(OPTIONS) do
            if option.category == filter or (filter == nil and option.category == "") then
                renderOption(option)
            end
        end

        UiTranslate(0, 30)

        UiFont("bold.ttf", 28)

        if filter == "keybind" then
            UiPush()
                UiFont("bold.ttf", 20)
                UiButtonHoverColor(1, 0.3, 0)

                local width, height = UiGetTextSize("Restore Defaults")
                if UiTextButton("Restore Defaults", width, height) then
                    for _, option in ipairs(OPTIONS) do
                        if option.category == "keybind" and option.mapping then
                            CfgSetValue(option.mapping, option.mapping.value_default)
                        end
                    end
                end
            UiPop()

            UiTranslate(0, height + 20)
        end

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
end

local function reset(force_reset)
    UiBlur(0.5)
    UiPush()
        local margins = {}
        margins.x0, margins.y0, margins.x1, margins.y1 = UiSafeMargins()

        local box = {}
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
                        CfgReset()
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
                            CfgReset()
                            OPTIONS = {}

                            Menu()
                            return
                        end

                        if STATES.confirm_reset == 1 then
                            for _, option in ipairs(OPTIONS) do
                                if option.mapping then option:setRegValue(option.mapping.value_default) end
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

-- #region Main

---@diagnostic disable-next-line:lowercase-global
function init()
    STATES = {
        menu = 1,
        set_keybind = {
            active = false,
            target = nil,
            msg_error_duplicate_bind = false,
        },
        confirm_reset = 0
    }

    if CfgInit() then
        STATES.confirm_reset = 3
    end

    OPTIONS = {}
    for _, data in ipairs(CONFIG_OPTIONS) do
        local option = OPTION:new(data)

        table.insert(OPTIONS, option)
    end
end

---@diagnostic disable-next-line:lowercase-global
function draw()
    if InputDown("ctrl") and InputDown("alt") and InputPressed("C") then
        CfgReset(true)
        OPTIONS = {}
        Menu()
        return
    end

    if InputDown("shift") and InputPressed("C") then
        STATES.confirm_reset = 2
    end

    renderMenu()

    if STATES.set_keybind.active then
        modalSetKey(STATES.set_keybind.target)
    end

    if STATES.confirm_reset > 0 then
        if STATES.confirm_reset == 3 then reset(true) else reset() end
    end
end

-- #endregion
