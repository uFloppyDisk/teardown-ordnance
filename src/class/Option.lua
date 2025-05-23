OPTION = {
    type = "textbutton",
    mapping = nil,
    name = "Button",

    value_unit = nil,
    value_digits = 0,
    value_min = 0,
    value_max = 1,
    value = nil,

    value_display_factor = 0,
    value_display_exp = 0,

    width = 100,
    height = 30
}

function OPTION:new(o)
    local object = o or {}
    setmetatable(object, self)
    self.__index = self

    return object
end

function OPTION:getRegValue()
    return CfgGetValue(self.mapping)
end

function OPTION:setRegValue(value)
    return CfgSetValue(self.mapping, value)
end
