---@class Event
---@field name string

EVENT = {
    CHANGE_SHELL = {},
    CHANGE_VARIANT = {},
}

_EVENT_LISTENERS = {}

---Trigger an event
---@param event Event
---@param args string
function FdTriggerEvent(event, args)
    TriggerEvent(event.name, args)
end

---Register an event listener
---@param event Event
---@param fn function Listener function
---@return function deregister Callback to deregister event listener
function FdRegisterEventListener(event, fn)
    local index = _EVENT_LISTENERS[event.name] or 0
    local id = event.name .. "_" .. index

    _G[id] = fn
    _EVENT_LISTENERS[event.name] = index + 1
    RegisterListenerTo(event.name, id)

    return function()
        UnregisterListener(event.name, id)
    end
end

---Generate event definitions
---@param obj table Object with hierarchical event skeletons
---@param current_key string Event key at this level of hierarchy
---@return boolean is_event
local function generateEventDefs(obj, current_key)
    if type(obj) ~= "table" then return false end

    local has_event_children = false
    for key, value in pairs(obj) do
        local next_key = string.lower(current_key .. "." .. key)

        has_event_children = generateEventDefs(value, next_key) or has_event_children
    end

    if not has_event_children then
        obj["name"] = current_key
    end

    return true
end

generateEventDefs(EVENT, "ordnance")
