local addon = CenterMarker

local marker = CreateFrame("Frame", "CenterMarkerFrame", UIParent)
marker:SetFrameStrata("LOW")
marker:SetFrameLevel(99)
marker:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

local plusText = marker:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
plusText:SetPoint("CENTER")
plusText:SetText("+")
plusText:SetTextColor(addon.defaults.color.r, addon.defaults.color.g, addon.defaults.color.b)

addon.marker = marker
addon.plusText = plusText

local shapeChars = {
    plus = "+",
    x = "x",
    dot = "\a",
    bullet = "\a",
    asterisk = "*",
}

local function updateAnchor(db)
    marker:ClearAllPoints()
    local offset = (db and tonumber(db.placeOffset)) or addon.defaults.placeOffset
    marker:SetPoint("CENTER", UIParent, "CENTER", 0, offset)
end

local function shouldShowByCondition(db)
    local cond = db.showCondition
    if cond == "combat" then
        return addon.isPlayerInCombat()
    elseif cond == "nocombat" then
        return not addon.isPlayerInCombat()
    end
    return true
end

function addon.setColor(r, g, b)
    CenterMarkerDB = addon.normalizeDB(CenterMarkerDB)
    CenterMarkerDB.color.r = r
    CenterMarkerDB.color.g = g
    CenterMarkerDB.color.b = b
    addon.applySettings()
end

function addon.applySettings()
    CenterMarkerDB = addon.normalizeDB(CenterMarkerDB)
    local db = CenterMarkerDB
    updateAnchor(db)

    marker:SetSize(db.size, db.size)
    marker:SetAlpha(db.alpha)
    plusText:SetFont(STANDARD_TEXT_FONT, db.size, "OUTLINE")
    plusText:SetText(shapeChars[db.shape] or shapeChars.plus)
    plusText:SetTextColor(db.color.r, db.color.g, db.color.b, 1)

    if db.enabled and shouldShowByCondition(db) then
        marker:Show()
    else
        marker:Hide()
    end
end

function addon.updateAnchor()
    CenterMarkerDB = addon.normalizeDB(CenterMarkerDB)
    updateAnchor(CenterMarkerDB)
end
