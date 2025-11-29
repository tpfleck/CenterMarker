local addonName = ...

CenterMarker = CenterMarker or {}
local addon = CenterMarker

addon.name = addonName

addon.defaults = {
    enabled = true,
    size = 12,
    alpha = 1,
    placeOffset = -20,
    showCondition = "always",
    shape = "plus",
    color = { r = 1, g = 0.82, b = 0 },
    autoCombatLogEnabled = true,
    autoCombatLogAnnounce = true,
}

function addon.ensureDefaults(db, template)
    if type(db) ~= "table" then
        db = {}
    end

    for key, value in pairs(template) do
        if db[key] == nil then
            db[key] = value
        end
    end

    return db
end

function addon.ensureColor(db)
    if type(db.color) ~= "table" then
        db.color = { r = addon.defaults.color.r, g = addon.defaults.color.g, b = addon.defaults.color.b }
    else
        db.color.r = db.color.r or addon.defaults.color.r
        db.color.g = db.color.g or addon.defaults.color.g
        db.color.b = db.color.b or addon.defaults.color.b
    end
end

function addon.ensureOffset(db)
    if type(db.placeOffset) ~= "number" then
        db.placeOffset = addon.defaults.placeOffset
    end
end

function addon.ensureCondition(db)
    local valid = { always = true, combat = true, nocombat = true }
    if not valid[db.showCondition] then
        db.showCondition = addon.defaults.showCondition
    end
end

function addon.ensureShape(db)
    local valid = { plus = true, x = true, dot = true, asterisk = true, bullet = true }
    if not valid[db.shape] then
        db.shape = addon.defaults.shape
    end
end

function addon.ensureCombatLogSettings(db)
    if type(db.autoCombatLogEnabled) ~= "boolean" then
        db.autoCombatLogEnabled = addon.defaults.autoCombatLogEnabled
    end
    if type(db.autoCombatLogAnnounce) ~= "boolean" then
        db.autoCombatLogAnnounce = addon.defaults.autoCombatLogAnnounce
    end
end

function addon.clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end
    return value
end

function addon.getAddonVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
    elseif GetAddOnMetadata then
        return GetAddOnMetadata(addonName, "Version") or ""
    elseif GetAddOnInfo then
        local _, _, _, _, _, version = GetAddOnInfo(addonName)
        return version or ""
    end
    return ""
end
