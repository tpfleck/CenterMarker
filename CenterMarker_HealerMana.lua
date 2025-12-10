local addon = CenterMarker

local healerMana = {}
addon.healerMana = healerMana

local manaPowerType = (Enum and Enum.PowerType and Enum.PowerType.Mana) or 0

local function ensureDB()
    CenterMarkerDB = addon.normalizeDB(CenterMarkerDB)
    return CenterMarkerDB
end

local function getPosition()
    local db = ensureDB()
    return db.healerManaPosition or addon.defaults.healerManaPosition
end

local function isLocked()
    local db = ensureDB()
    return db.healerManaLocked and true or false
end

local display = CreateFrame("Frame", "CenterMarkerHealerManaFrame", UIParent)
display:SetFrameStrata("MEDIUM")
display:SetSize(80, 32)
display:Hide()
display:SetMovable(true)
display:EnableMouse(true)
display:RegisterForDrag("LeftButton")
display:SetScript("OnDragStart", function(self)
    if isLocked() then
        return
    end
    self:StartMoving()
end)

local function savePosition()
    if isLocked() then
        return
    end
    local db = ensureDB()
    local pos = db.healerManaPosition
    local point, _, relativePoint, x, y = display:GetPoint()
    pos.point = point
    pos.relativePoint = relativePoint
    pos.x = math.floor((x or 0) + 0.5)
    pos.y = math.floor((y or 0) + 0.5)
end

display:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    savePosition()
end)

local value = display:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
value:SetPoint("CENTER", display, "CENTER", 0, 0)
value:SetJustifyH("CENTER")
value:SetText("--%")

local trackedUnit

local function applyPosition()
    local pos = getPosition()
    display:ClearAllPoints()
    display:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 0, pos.y or 0)
end

local function applyLockState()
    local locked = isLocked()
    display:StopMovingOrSizing()
    display:SetMovable(not locked)
    display:EnableMouse(not locked)
    if locked then
        display:RegisterForDrag()
    else
        display:RegisterForDrag("LeftButton")
    end
end

local function isEnabled()
    local db = ensureDB()
    return db.healerManaEnabled and true or false
end

local function isFiveManParty()
    if IsInRaid and IsInRaid() then
        return false
    end
    if not IsInGroup or not IsInGroup() then
        return false
    end
    local members = GetNumGroupMembers and GetNumGroupMembers() or 0
    return members > 0 and members <= 5
end

local function findHealerUnit()
    if not isFiveManParty() then
        return nil
    end

    local units = { "player", "party1", "party2", "party3", "party4" }
    for _, unit in ipairs(units) do
        if UnitExists(unit) and UnitGroupRolesAssigned(unit) == "HEALER" then
            return unit
        end
    end
    return nil
end

local function getManaPercent(unit)
    if not unit or not UnitExists(unit) then
        return nil
    end
    if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        return 0
    end

    if UnitPowerPercent then
        local ok, percent = pcall(UnitPowerPercent, unit, manaPowerType, true, true)
        if ok and percent ~= nil then
            return percent
        end
        ok, percent = pcall(UnitPowerPercent, unit, manaPowerType)
        if ok and percent ~= nil then
            return percent
        end
    end
    return nil
end

local function applyStyle()
    local db = ensureDB()
    local color = db.healerManaColor or addon.defaults.healerManaColor
    value:SetTextColor(color.r or 1, color.g or 1, color.b or 1)
    local size = db.healerManaFontSize or addon.defaults.healerManaFontSize
    value:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
end

local function updateMana()
    if not trackedUnit then
        display:Hide()
        return
    end
    local percent = getManaPercent(trackedUnit)

    if percent ~= nil then
        local okString, text = pcall(tostring, percent)
        if okString and text then
            local suffix = ""
            local okFind, hasPercent = pcall(function()
                return text:find("%%")
            end)
            if not (okFind and hasPercent) then
                suffix = "%"
            end
            value:SetText(text .. suffix)
            display:Show()
            return
        end
    end

    value:SetText("--%")
    display:Show()
end

local function refreshTrackedUnit()
    if not isEnabled() then
        trackedUnit = nil
        display:Hide()
        return
    end

    local healer = findHealerUnit()
    trackedUnit = healer

    if not trackedUnit then
        display:Hide()
        return
    end

    applyLockState()
    applyPosition()
    applyStyle()
    updateMana()
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        if arg1 == trackedUnit then
            updateMana()
        end
        return
    end
    refreshTrackedUnit()
end)

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
eventFrame:RegisterEvent("ROLE_CHANGED_INFORM")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
eventFrame:RegisterEvent("UNIT_MAXPOWER")
eventFrame:RegisterEvent("UNIT_DISPLAYPOWER")

function healerMana.refresh()
    refreshTrackedUnit()
end

function healerMana.applyPosition()
    applyPosition()
    refreshTrackedUnit()
end

function healerMana.savePosition()
    savePosition()
end

function healerMana.applyLockState()
    applyLockState()
end

refreshTrackedUnit()
