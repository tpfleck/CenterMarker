local addon = CenterMarker

local marker = CreateFrame("Frame", "CenterMarkerFrame", UIParent)
marker:SetFrameStrata("TOOLTIP")
marker:SetFrameLevel(99)
marker:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

local plusText = marker:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
plusText:SetPoint("CENTER")
plusText:SetText("+")
plusText:SetTextColor(addon.defaults.color.r, addon.defaults.color.g, addon.defaults.color.b)

addon.marker = marker
addon.plusText = plusText

local function updateAnchor()
    marker:ClearAllPoints()
    local offset = (CenterMarkerDB and tonumber(CenterMarkerDB.placeOffset)) or addon.defaults.placeOffset
    marker:SetPoint("CENTER", UIParent, "CENTER", 0, offset)
end

addon.updateAnchor = updateAnchor

local function getShapeChar()
    local shape = (CenterMarkerDB and CenterMarkerDB.shape) or addon.defaults.shape
    if shape == "x" then
        return "x"
    elseif shape == "dot" or shape == "bullet" then
        return "•"
    elseif shape == "asterisk" then
        return "*"
    end
    return "+"
end

local function playerInCombat()
    if InCombatLockdown and InCombatLockdown() then
        return true
    end
    local inCombat = UnitAffectingCombat and UnitAffectingCombat("player")
    return inCombat and true or false
end

local function shouldShowByCondition()
    local cond = CenterMarkerDB.showCondition
    if cond == "combat" then
        return playerInCombat()
    elseif cond == "nocombat" then
        return not playerInCombat()
    end
    return true
end

function addon.setColor(r, g, b)
    if not CenterMarkerDB then
        return
    end
    CenterMarkerDB.color.r = r
    CenterMarkerDB.color.g = g
    CenterMarkerDB.color.b = b
    addon.applySettings()
end

function addon.applySettings()
    CenterMarkerDB = addon.ensureDefaults(CenterMarkerDB, addon.defaults)
    addon.ensureColor(CenterMarkerDB)
    addon.ensureOffset(CenterMarkerDB)
    addon.ensureCondition(CenterMarkerDB)
    addon.ensureShape(CenterMarkerDB)
    addon.ensureCombatLogSettings(CenterMarkerDB)
    updateAnchor()

    marker:SetSize(CenterMarkerDB.size, CenterMarkerDB.size)
    marker:SetAlpha(CenterMarkerDB.alpha)
    plusText:SetFont(STANDARD_TEXT_FONT, CenterMarkerDB.size, "OUTLINE")
    plusText:SetText(getShapeChar())
    plusText:SetTextColor(CenterMarkerDB.color.r, CenterMarkerDB.color.g, CenterMarkerDB.color.b, 1)

    if CenterMarkerDB.enabled and shouldShowByCondition() then
        marker:Show()
    else
        marker:Hide()
    end
end
