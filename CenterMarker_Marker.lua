local addon = CenterMarker

local marker = CreateFrame("Frame", "CenterMarkerFrame", UIParent)
marker:SetFrameStrata("LOW")
marker:SetFrameLevel(99)
marker:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

-- Render dots with a texture + circular mask so they stay round at large sizes.
local dotTexture = marker:CreateTexture(nil, "OVERLAY")
dotTexture:SetAllPoints(marker)
dotTexture:SetColorTexture(addon.defaults.color.r, addon.defaults.color.g, addon.defaults.color.b, 1)
dotTexture:Hide()

local dotMask = marker:CreateMaskTexture(nil, "BORDER")
dotMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
dotMask:SetAllPoints(marker)
dotTexture:AddMaskTexture(dotMask)
dotMask:Hide()

local plusText = marker:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
plusText:SetPoint("CENTER")
plusText:SetText("+")
plusText:SetTextColor(addon.defaults.color.r, addon.defaults.color.g, addon.defaults.color.b)

addon.marker = marker
addon.plusText = plusText

local shapeChars = {
    plus = "+",
    x = "x",
    dot = "•",
    asterisk = "*",
}

local function fontForShape()
    return STANDARD_TEXT_FONT
end

local circleShapes = { dot = true, bullet = true }

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
    elseif cond == "instance" then
        return addon.isPlayerInInstance()
    elseif cond == "noinstance" then
        return not addon.isPlayerInInstance()
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
    if circleShapes[db.shape] then
        plusText:Hide()
        dotMask:Show()
        dotTexture:SetColorTexture(db.color.r, db.color.g, db.color.b, 1)
        dotTexture:Show()
    else
        dotTexture:Hide()
        dotMask:Hide()
        plusText:SetFont(fontForShape(), db.size, "OUTLINE")
        plusText:SetText(shapeChars[db.shape] or shapeChars.plus)
        plusText:SetTextColor(db.color.r, db.color.g, db.color.b, 1)
        plusText:Show()
    end

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
