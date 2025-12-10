local addonName = ...

CenterMarker = CenterMarker or {}
local addon = CenterMarker

addon.name = addonName

addon.defaults = {
    enabled = true,
    size = 32,
    alpha = 1,
    placeOffset = -10,
    showCondition = "always",
    shape = "plus",
    color = { r = 1, g = 0.82, b = 0 },
    autoCombatLogEnabled = true,
    autoCombatLogAnnounce = true,
    healerManaEnabled = true,
    healerManaPosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 220 },
    healerManaColor = { r = 0.55, g = 0.78, b = 1 },
    healerManaFontSize = 24,
    healerManaLocked = false,
}

addon.limits = {
    size = { min = 1, max = 256, step = 1 },
    alpha = { min = 0, max = 1, step = 0.05 },
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
    if db.showCondition == "encounter" then
        db.showCondition = "instance"
    elseif db.showCondition == "noencounter" then
        db.showCondition = "noinstance"
    end

    local valid = { always = true, combat = true, nocombat = true, instance = true, noinstance = true }
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

function addon.ensureHealerManaSettings(db)
    if type(db.healerManaEnabled) ~= "boolean" then
        db.healerManaEnabled = addon.defaults.healerManaEnabled
    end

    if type(db.healerManaPosition) ~= "table" then
        db.healerManaPosition = {}
    end

    local pos = db.healerManaPosition
    local defaults = addon.defaults.healerManaPosition
    pos.point = pos.point or defaults.point
    pos.relativePoint = pos.relativePoint or defaults.relativePoint
    pos.x = tonumber(pos.x) or defaults.x
    pos.y = tonumber(pos.y) or defaults.y

    if type(db.healerManaColor) ~= "table" then
        db.healerManaColor = {}
    end
    local c = db.healerManaColor
    local dc = addon.defaults.healerManaColor
    c.r = tonumber(c.r) or dc.r
    c.g = tonumber(c.g) or dc.g
    c.b = tonumber(c.b) or dc.b

    if type(db.healerManaFontSize) ~= "number" then
        db.healerManaFontSize = addon.defaults.healerManaFontSize
    end

    if type(db.healerManaLocked) ~= "boolean" then
        db.healerManaLocked = addon.defaults.healerManaLocked
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

function addon.normalizeDB(db)
    db = addon.ensureDefaults(db, addon.defaults)
    addon.ensureColor(db)
    addon.ensureOffset(db)
    addon.ensureCondition(db)
    addon.ensureShape(db)
    addon.ensureCombatLogSettings(db)
    addon.ensureHealerManaSettings(db)
    return db
end

local instanceTypes = {
    party = true, -- 5-man dungeon (including follower dungeons)
    raid = true,
    scenario = true,
    pvp = true,
    arena = true,
}

function addon.isPlayerInCombat()
    if InCombatLockdown and InCombatLockdown() then
        return true
    end
    local inCombat = UnitAffectingCombat and UnitAffectingCombat("player")
    return inCombat and true or false
end

function addon.isPlayerInInstance()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then
        return false
    end
    return instanceTypes[instanceType] and true or false
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
