local addon = CenterMarker

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
events:RegisterEvent("CHALLENGE_MODE_START")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_ENTER_COMBAT")
events:RegisterEvent("PLAYER_LEAVE_COMBAT")

events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addon.name then
        CenterMarkerDB = addon.ensureDefaults(CenterMarkerDB, addon.defaults)
        addon.ensureCombatLogSettings(CenterMarkerDB)
        addon.applySettings()
        if addon.combatLog then
            addon.combatLog.bootstrap()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        addon.applySettings()
        if addon.combatLog then
            addon.combatLog.evaluate(event)
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_DIFFICULTY_CHANGED" or event == "CHALLENGE_MODE_START" then
        if addon.combatLog then
            addon.combatLog.evaluate(event)
        end
    elseif (event == "NAME_PLATE_UNIT_ADDED" or event == "NAME_PLATE_UNIT_REMOVED") and arg1 == "player" then
        addon.updateAnchor()
    elseif event == "PLAYER_TARGET_CHANGED" then
        addon.updateAnchor()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTER_COMBAT" or event == "PLAYER_LEAVE_COMBAT" then
        addon.applySettings()
    end
end)
