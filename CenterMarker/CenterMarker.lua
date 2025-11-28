local addonName = ...

local defaults = {
    enabled = true,
    size = 12, -- desired default scale/size
    alpha = 1,
    placeOffset = -20, -- vertical offset from screen center
    showCondition = "always", -- always | combat | nocombat
    shape = "plus", -- plus | x | dot | asterisk
    color = { r = 1, g = 0.82, b = 0 },
}

local function ensureDefaults(db, template)
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

local function ensureColor(db)
    if type(db.color) ~= "table" then
        db.color = { r = defaults.color.r, g = defaults.color.g, b = defaults.color.b }
    else
        db.color.r = db.color.r or defaults.color.r
        db.color.g = db.color.g or defaults.color.g
        db.color.b = db.color.b or defaults.color.b
    end
end

local function ensureOffset(db)
    if type(db.placeOffset) ~= "number" then
        db.placeOffset = defaults.placeOffset
    end
end

local function ensureCondition(db)
    local valid = { always = true, combat = true, nocombat = true }
    if not valid[db.showCondition] then
        db.showCondition = defaults.showCondition
    end
end

local function ensureShape(db)
    local valid = { plus = true, x = true, dot = true, asterisk = true, bullet = true }
    if not valid[db.shape] then
        db.shape = defaults.shape
    end
end

local marker = CreateFrame("Frame", "CenterMarkerFrame", UIParent)
marker:SetFrameStrata("TOOLTIP")
marker:SetFrameLevel(99)
marker:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

local plusText = marker:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
plusText:SetPoint("CENTER")
plusText:SetText("+")
plusText:SetTextColor(1, 0.82, 0) -- warm yellow tint

local applySettings -- forward declaration so closures see the local reference

local function updateAnchor()
    marker:ClearAllPoints()
    local offset = (CenterMarkerDB and tonumber(CenterMarkerDB.placeOffset)) or defaults.placeOffset
    local xOffset = 0

    marker:SetPoint("CENTER", UIParent, "CENTER", xOffset, offset)
end

local function setColor(r, g, b)
    CenterMarkerDB.color.r = r
    CenterMarkerDB.color.g = g
    CenterMarkerDB.color.b = b
    applySettings()
end

local function getShapeChar()
    if CenterMarkerDB.shape == "x" then
        return "x"
    elseif CenterMarkerDB.shape == "dot" or CenterMarkerDB.shape == "bullet" then
        return "•"
    elseif CenterMarkerDB.shape == "asterisk" then
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
    return true -- always
end

applySettings = function()
    if not CenterMarkerDB then
        return
    end
    ensureColor(CenterMarkerDB)
    ensureOffset(CenterMarkerDB)
    ensureCondition(CenterMarkerDB)
    ensureShape(CenterMarkerDB)
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

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end
    return value
end

local function printHelp()
    print("|cffFFD200CenterMarker|r commands:")
    print("/cm           - Open config panel")
    print("/cm toggle    - Show or hide the marker")
    print("/cm size <px> - Set size (8-256)")
    print("/cm alpha <0-1> - Set opacity (0 to 1)")
    print("/cm help      - Show these commands")
end

local function getAddonVersion()
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

local function createConfigFrame()
    local frame = CreateFrame("Frame", "CenterMarkerConfigFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 300) -- width stays fixed; height adjusts dynamically below
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.08, 0.9)
    frame:SetBackdropBorderColor(0.3, 0.6, 1, 0.8)

    -- Top accent bar
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(0.2, 0.6, 1, 0.8)
    accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    accent:SetHeight(6)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -14)
    frame.title:SetText(string.format("CenterMarker by Hubbs | Version %s", getAddonVersion()))

    local close = CreateFrame("Button", nil, frame)
    close:SetSize(18, 18)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    close:SetNormalFontObject("GameFontHighlight")
    close:SetText("×")
    close:SetScript("OnClick", function() frame:Hide() end)

    local enableCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -52)
    enableCheck.Text:SetText("Enabled")

    local colorLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorLabel:SetPoint("LEFT", enableCheck, "RIGHT", 140, 0)
    colorLabel:SetPoint("CENTER", enableCheck, "CENTER", 0, -1)
    colorLabel:SetText("Color:")

    local swatch = CreateFrame("Button", nil, frame, "BackdropTemplate")
    swatch:SetSize(26, 26)
    swatch:SetPoint("LEFT", colorLabel, "RIGHT", 10, 0)
    swatch:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    swatch:SetBackdropColor(0.05, 0.05, 0.08, 0.8)
    swatch:SetBackdropBorderColor(0.3, 0.6, 1, 0.8)

    local swatchTexture = swatch:CreateTexture(nil, "ARTWORK")
    swatchTexture:SetPoint("TOPLEFT", swatch, "TOPLEFT", 3, -3)
    swatchTexture:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -3, 3)
    swatchTexture:SetColorTexture(CenterMarkerDB.color.r, CenterMarkerDB.color.g, CenterMarkerDB.color.b, 1)

    local shapeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    shapeLabel:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 2, -26)
    shapeLabel:SetText("Marker style:")

    local shapeDropdown = CreateFrame("Frame", "CenterMarkerShapeDropdown", frame, "UIDropDownMenuTemplate")
    shapeDropdown:SetPoint("LEFT", shapeLabel, "RIGHT", 12, -2)
    shapeDropdown:SetPoint("CENTER", shapeLabel, "CENTER", 0, 0)
    UIDropDownMenu_SetWidth(shapeDropdown, 170)

    local function setShape(value)
        CenterMarkerDB.shape = value
        UIDropDownMenu_SetSelectedValue(shapeDropdown, value)
        applySettings()
    end

    UIDropDownMenu_Initialize(shapeDropdown, function(_, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(btn) setShape(btn.value) end

        info.text, info.value = "Plus (+)", "plus"
        UIDropDownMenu_AddButton(info, level)

        info.text, info.value = "X", "x"
        UIDropDownMenu_AddButton(info, level)

        info.text, info.value = "Dot (•)", "dot"
        UIDropDownMenu_AddButton(info, level)

        info.text, info.value = "Asterisk (*)", "asterisk"
        UIDropDownMenu_AddButton(info, level)
    end)

    local conditionLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    conditionLabel:SetPoint("TOPLEFT", shapeLabel, "BOTTOMLEFT", 0, -24)
    conditionLabel:SetText("Show when:")

    local conditionDropdown = CreateFrame("Frame", "CenterMarkerConditionDropdown", frame, "UIDropDownMenuTemplate")
    conditionDropdown:SetPoint("LEFT", conditionLabel, "RIGHT", 16, -2)
    conditionDropdown:SetPoint("CENTER", conditionLabel, "CENTER", 0, 0)
    UIDropDownMenu_SetWidth(conditionDropdown, 170)

    local function setCondition(value)
        CenterMarkerDB.showCondition = value
        UIDropDownMenu_SetSelectedValue(conditionDropdown, value)
        applySettings()
    end

    UIDropDownMenu_Initialize(conditionDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(btn) setCondition(btn.value) end

        info.text, info.value = "Always", "always"
        UIDropDownMenu_AddButton(info, level)

        info.text, info.value = "When in Combat", "combat"
        UIDropDownMenu_AddButton(info, level)

        info.text, info.value = "When not in Combat", "nocombat"
        UIDropDownMenu_AddButton(info, level)
    end)

    local sizeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", conditionLabel, "BOTTOMLEFT", 0, -24)
    sizeLabel:SetText("Size (8-256):")

    local slider = CreateFrame("Slider", "CenterMarkerSizeSlider", frame, "OptionsSliderTemplate")
    slider:SetWidth(200)
    slider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -16)
    slider:SetMinMaxValues(8, 256)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)

    _G[slider:GetName() .. "Low"]:SetText("8")
    _G[slider:GetName() .. "High"]:SetText("256")
    _G[slider:GetName() .. "Text"]:SetText("Marker Size")

    -- Custom slider look
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetColorTexture(0.15, 0.25, 0.35, 0.8)
    track:SetPoint("TOPLEFT", slider, "TOPLEFT", 0, -6)
    track:SetPoint("BOTTOMRIGHT", slider, "BOTTOMRIGHT", 0, 6)

    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
    thumb:SetColorTexture(0.9, 0.9, 1, 1)
    thumb:SetSize(14, 24)
    slider:SetThumbTexture(thumb)

    local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    editBox:SetSize(60, 24)
    editBox:SetAutoFocus(false)
    editBox:SetNumeric(true)
    editBox:SetPoint("LEFT", slider, "RIGHT", 16, 0)
    editBox:SetPoint("CENTER", slider, "CENTER", 0, 0)
    editBox:SetJustifyH("CENTER")

    local alphaLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alphaLabel:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -24)
    alphaLabel:SetText("Alpha (0-1):")

    local alphaSlider = CreateFrame("Slider", "CenterMarkerAlphaSlider", frame, "OptionsSliderTemplate")
    alphaSlider:SetWidth(200)
    alphaSlider:SetPoint("TOPLEFT", alphaLabel, "BOTTOMLEFT", 0, -16)
    alphaSlider:SetMinMaxValues(0, 1)
    alphaSlider:SetValueStep(0.05)
    alphaSlider:SetObeyStepOnDrag(true)

    _G[alphaSlider:GetName() .. "Low"]:SetText("0")
    _G[alphaSlider:GetName() .. "High"]:SetText("1")
    _G[alphaSlider:GetName() .. "Text"]:SetText("Opacity")

    -- Custom alpha slider look (match size slider)
    local alphaTrack = alphaSlider:CreateTexture(nil, "BACKGROUND")
    alphaTrack:SetColorTexture(0.15, 0.25, 0.35, 0.8)
    alphaTrack:SetPoint("TOPLEFT", alphaSlider, "TOPLEFT", 0, -6)
    alphaTrack:SetPoint("BOTTOMRIGHT", alphaSlider, "BOTTOMRIGHT", 0, 6)

    local alphaThumb = alphaSlider:CreateTexture(nil, "ARTWORK")
    alphaThumb:SetTexture("Interface\\Buttons\\WHITE8x8")
    alphaThumb:SetColorTexture(0.9, 0.9, 1, 1)
    alphaThumb:SetSize(14, 24)
    alphaSlider:SetThumbTexture(alphaThumb)

    local alphaEdit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    alphaEdit:SetSize(60, 24)
    alphaEdit:SetAutoFocus(false)
    alphaEdit:SetNumeric(false)
    alphaEdit:SetPoint("LEFT", alphaSlider, "RIGHT", 16, 0)
    alphaEdit:SetPoint("CENTER", alphaSlider, "CENTER", 0, 0)
    alphaEdit:SetJustifyH("CENTER")

    local feetOffsetLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    feetOffsetLabel:SetPoint("TOPLEFT", alphaSlider, "BOTTOMLEFT", 0, -26)
    feetOffsetLabel:SetText("Feet Y-axis offset (px):")

    local feetOffsetBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    feetOffsetBox:SetSize(80, 24)
    feetOffsetBox:SetAutoFocus(false)
    feetOffsetBox:SetNumeric(false) -- allow negatives
    feetOffsetBox:SetPoint("LEFT", feetOffsetLabel, "RIGHT", 12, 0)
    feetOffsetBox:SetPoint("CENTER", feetOffsetLabel, "CENTER", 0, 0)
    feetOffsetBox:SetJustifyH("CENTER")

    slider:SetScript("OnValueChanged", function(_, value)
        CenterMarkerDB.size = clamp(math.floor(value + 0.5), 8, 256)
        applySettings()
        editBox:SetNumber(CenterMarkerDB.size)
    end)

    local function applyBoxValue()
        local value = tonumber(editBox:GetText())
        if value then
            CenterMarkerDB.size = clamp(math.floor(value + 0.5), 8, 256)
            slider:SetValue(CenterMarkerDB.size)
            applySettings()
        else
            editBox:SetNumber(CenterMarkerDB.size)
        end
    end

    editBox:SetScript("OnEnterPressed", applyBoxValue)
    editBox:SetScript("OnEditFocusLost", applyBoxValue)

    enableCheck:SetScript("OnClick", function(self)
        CenterMarkerDB.enabled = self:GetChecked()
        applySettings()
    end)

    alphaSlider:SetScript("OnValueChanged", function(_, value)
        CenterMarkerDB.alpha = clamp(value, 0, 1)
        applySettings()
        alphaEdit:SetText(string.format("%.2f", CenterMarkerDB.alpha))
    end)

    local function applyAlphaBox()
        local value = tonumber(alphaEdit:GetText())
        if value then
            CenterMarkerDB.alpha = clamp(value, 0, 1)
            alphaSlider:SetValue(CenterMarkerDB.alpha)
            applySettings()
        else
            alphaEdit:SetText(string.format("%.2f", CenterMarkerDB.alpha))
        end
    end

    alphaEdit:SetScript("OnEnterPressed", applyAlphaBox)
    alphaEdit:SetScript("OnEditFocusLost", applyAlphaBox)

    local function openColorPicker()
        local prev = { CenterMarkerDB.color.r, CenterMarkerDB.color.g, CenterMarkerDB.color.b }

        local function applyFromPicker()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            setColor(r, g, b)
            swatchTexture:SetColorTexture(r, g, b, 1)
        end

        local function restoreColor()
            local r, g, b = unpack(prev)
            setColor(r, g, b)
            swatchTexture:SetColorTexture(r, g, b, 1)
        end

        if ColorPickerFrame and ColorPickerFrame.SetupColorPickerAndShow then
            local info = {
                r = prev[1],
                g = prev[2],
                b = prev[3],
                swatchFunc = applyFromPicker,
                cancelFunc = restoreColor,
                hasOpacity = false,
            }
            ColorPickerFrame:SetupColorPickerAndShow(info)
        else
            ColorPickerFrame:Hide()
            ColorPickerFrame.hasOpacity = false
            ColorPickerFrame.opacityFunc = nil
            ColorPickerFrame.previousValues = prev
            ColorPickerFrame.func = applyFromPicker
            ColorPickerFrame.cancelFunc = restoreColor
            ColorPickerFrame:SetColorRGB(prev[1], prev[2], prev[3])
            ColorPickerFrame:Show()
        end
    end

    swatch:SetScript("OnClick", openColorPicker)

    local function applyFeetOffset()
        local value = tonumber(feetOffsetBox:GetText())
        if value then
            CenterMarkerDB.placeOffset = value
            applySettings()
        else
            feetOffsetBox:SetText(tostring(CenterMarkerDB.placeOffset or defaults.placeOffset))
        end
    end

    feetOffsetBox:SetScript("OnEnterPressed", applyFeetOffset)
    feetOffsetBox:SetScript("OnEditFocusLost", applyFeetOffset)

    local function resizeToContent()
        local top = frame:GetTop()
        local bottom = feetOffsetBox:GetBottom()
        if top and bottom then
            local padding = 60
            local newHeight = (top - bottom) + padding
            frame:SetHeight(newHeight)
        end
    end

    frame:SetScript("OnShow", function()
        slider:SetValue(CenterMarkerDB.size)
        editBox:SetNumber(CenterMarkerDB.size)
        alphaSlider:SetValue(CenterMarkerDB.alpha)
        alphaEdit:SetText(string.format("%.2f", CenterMarkerDB.alpha))
        swatchTexture:SetColorTexture(CenterMarkerDB.color.r, CenterMarkerDB.color.g, CenterMarkerDB.color.b, 1)
        enableCheck:SetChecked(CenterMarkerDB.enabled)
        UIDropDownMenu_SetSelectedValue(shapeDropdown, CenterMarkerDB.shape)
        UIDropDownMenu_SetSelectedValue(conditionDropdown, CenterMarkerDB.showCondition)
        feetOffsetBox:SetText(tostring(CenterMarkerDB.placeOffset or defaults.placeOffset))
        resizeToContent()
    end)

    return frame
end

local configFrame

local function toggleConfigFrame()
    if not configFrame then
        configFrame = createConfigFrame()
    end

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end

SLASH_CENTERMARKER1 = "/centermarker"
SLASH_CENTERMARKER2 = "/cm"

SlashCmdList.CENTERMARKER = function(msg)
    local command, rest = msg:match("^(%S+)%s*(.*)$")
    command = command and command:lower() or ""

    if command == "" then
        toggleConfigFrame()
    elseif command == "toggle" then
        CenterMarkerDB.enabled = not CenterMarkerDB.enabled
        applySettings()
        print("CenterMarker: " .. (CenterMarkerDB.enabled and "shown" or "hidden"))
    elseif command == "size" then
        local value = tonumber(rest)
        if value then
            CenterMarkerDB.size = clamp(math.floor(value + 0.5), 8, 256)
            applySettings()
            print("CenterMarker size set to " .. CenterMarkerDB.size .. "px")
        else
            print("CenterMarker: size expects a number, e.g. /cm size 80")
        end
    elseif command == "alpha" then
        local value = tonumber(rest)
        if value then
            CenterMarkerDB.alpha = clamp(value, 0, 1)
            applySettings()
            print("CenterMarker opacity set to " .. CenterMarkerDB.alpha)
        else
            print("CenterMarker: alpha expects 0-1, e.g. /cm alpha 0.5")
        end
    elseif command == "help" or command == "?" then
        printHelp()
    else
        print("CenterMarker: unknown command. Use /cm help for options.")
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_ENTER_COMBAT")
events:RegisterEvent("PLAYER_LEAVE_COMBAT")
events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        CenterMarkerDB = ensureDefaults(CenterMarkerDB, defaults)
        ensureColor(CenterMarkerDB)
        applySettings()
    elseif event == "PLAYER_ENTERING_WORLD" then
        applySettings()
    elseif (event == "NAME_PLATE_UNIT_ADDED" or event == "NAME_PLATE_UNIT_REMOVED") and arg1 == "player" then
        updateAnchor()
    elseif event == "PLAYER_TARGET_CHANGED" then
        updateAnchor()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTER_COMBAT" or event == "PLAYER_LEAVE_COMBAT" then
        applySettings()
    end
end)


