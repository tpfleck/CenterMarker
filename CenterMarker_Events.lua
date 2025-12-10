local addon = CenterMarker

local events = CreateFrame("Frame")

local function reevaluateCombatLog(event, ...)
    if addon.combatLog then
        addon.combatLog.evaluate(event, ...)
    end
end

local function refreshSettings()
    addon.applySettings()
end

local eventHandlers = {
    ADDON_LOADED = function(_, arg1)
        if arg1 ~= addon.name then
            return
        end
        CenterMarkerDB = addon.normalizeDB(CenterMarkerDB)
        addon.applySettings()
        if addon.combatLog then
            addon.combatLog.bootstrap()
        end
    end,
    PLAYER_ENTERING_WORLD = function(event, ...)
        refreshSettings()
        reevaluateCombatLog(event, ...)
    end,
    ZONE_CHANGED_NEW_AREA = function(event, ...)
        refreshSettings()
        reevaluateCombatLog(event, ...)
    end,
    PLAYER_DIFFICULTY_CHANGED = function(event, ...)
        refreshSettings()
        reevaluateCombatLog(event, ...)
    end,
    CHALLENGE_MODE_START = function(event, ...)
        refreshSettings()
        reevaluateCombatLog(event, ...)
    end,
    START_TIMER = function(event, ...)
        refreshSettings()
        reevaluateCombatLog(event, ...)
    end,
    NAME_PLATE_UNIT_ADDED = function(_, unit)
        if unit == "player" then
            addon.updateAnchor()
        end
    end,
    NAME_PLATE_UNIT_REMOVED = function(_, unit)
        if unit == "player" then
            addon.updateAnchor()
        end
    end,
    PLAYER_TARGET_CHANGED = addon.updateAnchor,
    PLAYER_REGEN_DISABLED = refreshSettings,
    PLAYER_REGEN_ENABLED = refreshSettings,
    PLAYER_ENTER_COMBAT = refreshSettings,
    PLAYER_LEAVE_COMBAT = refreshSettings,
}

for event in pairs(eventHandlers) do
    events:RegisterEvent(event)
end

events:SetScript("OnEvent", function(_, event, ...)
    local handler = eventHandlers[event]
    if handler then
        handler(event, ...)
    end
end)
