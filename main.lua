#version 2
---@diagnostic disable:exp-in-action
---@diagnostic disable:undefined-global
---
#include "src/load.lua"
#include "src/server/load.lua"
---
---@diagnostic enable:exp-in-action
---@diagnostic enable:undefined-global

ELAPSED_TIME = 0

SHELLS = {}
BODIES = {}
---@type Shell[]
QUICK_SALVO = {}

DEBUG_LINES = {}
DEBUG_POSITIONS = {}

DEFAULT_ENVIRONMENT = {}
DEFAULT_POSTPROCESSING = {}

PLAYER_LOCK_TRANSFORM = nil

-- total, hit, miss, redirected
FRAG_STATS = {
    0, 0, 0, 0
}

-- #region Main

G_DEV = CfgGetValue("G_DEBUG_MODE") or false

---@diagnostic disable-next-line: lowercase-global
function init()
    if CfgInit() then
        FdLog("Restoring configuration defaults...")
        CfgReset()
    else
        FdLog("Config exists and is complete.")
    end
end

---@diagnostic disable-next-line: lowercase-global
function tick(delta)
    ELAPSED_TIME = ELAPSED_TIME + delta

    for i, body in ipairs(BODIES) do
        if body.valid == true and PhysBodyTick(body) then
            body.valid = false
        end

        local ttl = body.ttl or 20
        if body.valid == true and (ELAPSED_TIME - body.created_at) > ttl then
            Delete(body.handle)
            body.valid = false
        end

        if not body.valid then
            table.remove(BODIES, i)
        end
    end

    for _, shell in ipairs(SHELLS) do
        local values = SHELL_VALUES[shell.type]
        local variant = values.variants[shell.variant]

        if (shell.secondary.active and variant.secondary.draw) or not shell.secondary.active then
            ShellDrawSprite(shell)
        end

        if variant.id == "PF" then
            if shell.secondary.active then
                PointLight(shell.position, 1, 1, 1, shell.secondary.intensity)
            end
        end
    end
end

---@diagnostic disable-next-line: lowercase-global
function update(delta)
    -- Run shell tick for each shell not detonated, remove shell if detonated
    for i, shell in ipairs(SHELLS) do
        ShellTick(shell, delta)

        if shell.state == SHELL_STATE.DETONATED then
            FdLog("Shell " .. i .. " detonated. Removing...")
            table.remove(SHELLS, i)
        end
    end

    local shells_length = #SHELLS
    if shells_length < G_MAX_SHELLS then return end

    local trim_amount = shells_length - G_MAX_SHELLS
    FdLog("Removing " .. trim_amount .. " shells from table...")

    for _ = 1, trim_amount do
        table.remove(SHELLS, 1)
    end
end

-- #endregion Main
