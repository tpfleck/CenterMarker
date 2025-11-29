local addon = CenterMarker
local defaults = addon.defaults

local configFrame

local function createConfigFrame()
    CenterMarkerDB = addon.ensureDefaults(CenterMarkerDB, defaults)
    addon.ensureColor(CenterMarkerDB)
    addon.ensureOffset(CenterMarkerDB)
    addon.ensureCondition(CenterMarkerDB)
    addon.ensureShape(CenterMarkerDB)
    addon.ensureCombatLogSettings(CenterMarkerDB)

    local frame = CreateFrame("Frame", "CenterMarkerConfigFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 300)
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
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.08, 0.9)
    frame:SetBackdropBorderColor(0.3, 0.6, 1, 0.8)

    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(0.2, 0.6, 1, 0.8)
    accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    accent:SetHeight(6)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -14)
    frame.title:SetText(string.format("CenterMarker by Hubbs | Version %s", addon.getAddonVersion()))

    local close = CreateFrame("Button", nil, frame)
    close:SetSize(18, 18)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    close:SetNormalFontObject("GameFontHighlight")
    close:SetText("x")
    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    local tabMain = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    tabMain:SetSize(120, 24)
    tabMain:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -34)
    tabMain:SetText("CM Options")

    local tabUnrelated = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    tabUnrelated:SetSize(140, 24)
    tabUnrelated:SetPoint("LEFT", tabMain, "RIGHT", 6, 0)
    tabUnrelated:SetText("Cool Stuff")

    local mainControls = {}
    local unrelatedControls = {}

    local function toggleTab(active)
        if active == "main" then
            tabMain:Disable()
            tabUnrelated:Enable()
            for _, ctrl in ipairs(mainControls) do
                ctrl:Show()
            end
            for _, ctrl in ipairs(unrelatedControls) do
                ctrl:Hide()
            end
        else
            tabMain:Enable()
            tabUnrelated:Disable()
            for _, ctrl in ipairs(mainControls) do
                ctrl:Hide()
            end
            for _, ctrl in ipairs(unrelatedControls) do
                ctrl:Show()
            end
        end
    end

    tabMain:SetScript("OnClick", function()
        toggleTab("main")
    end)
    tabUnrelated:SetScript("OnClick", function()
        toggleTab("unrelated")
    end)

    local enableCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -70)
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

    local dropdownOffset = 140

    local shapeDropdown = CreateFrame("Frame", "CenterMarkerShapeDropdown", frame, "UIDropDownMenuTemplate")
    shapeDropdown:SetPoint("LEFT", shapeLabel, "LEFT", dropdownOffset, -2)
    UIDropDownMenu_SetWidth(shapeDropdown, 170)

    local function setShape(value)
        CenterMarkerDB.shape = value
        UIDropDownMenu_SetSelectedValue(shapeDropdown, value)
        addon.applySettings()
    end

    UIDropDownMenu_Initialize(shapeDropdown, function(_, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(btn)
            setShape(btn.value)
        end

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
    conditionDropdown:SetPoint("LEFT", conditionLabel, "LEFT", dropdownOffset, -2)
    UIDropDownMenu_SetWidth(conditionDropdown, 170)

    local function setCondition(value)
        CenterMarkerDB.showCondition = value
        UIDropDownMenu_SetSelectedValue(conditionDropdown, value)
        addon.applySettings()
    end

    UIDropDownMenu_Initialize(conditionDropdown, function(_, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(btn)
            setCondition(btn.value)
        end

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
    feetOffsetBox:SetNumeric(false)
    feetOffsetBox:SetPoint("LEFT", feetOffsetLabel, "RIGHT", 12, 0)
    feetOffsetBox:SetPoint("CENTER", feetOffsetLabel, "CENTER", 0, 0)
    feetOffsetBox:SetJustifyH("CENTER")

    mainControls = {
        enableCheck,
        colorLabel,
        swatch,
        swatchTexture,
        shapeLabel,
        shapeDropdown,
        conditionLabel,
        conditionDropdown,
        sizeLabel,
        slider,
        _G[slider:GetName() .. "Low"],
        _G[slider:GetName() .. "High"],
        _G[slider:GetName() .. "Text"],
        track,
        thumb,
        editBox,
        alphaLabel,
        alphaSlider,
        _G[alphaSlider:GetName() .. "Low"],
        _G[alphaSlider:GetName() .. "High"],
        _G[alphaSlider:GetName() .. "Text"],
        alphaTrack,
        alphaThumb,
        alphaEdit,
        feetOffsetLabel,
        feetOffsetBox,
    }

    local unrelatedHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    unrelatedHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -70)
    unrelatedHeader:SetText("Cool Stuff")

    local autoLogToggle = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    autoLogToggle:SetPoint("TOPLEFT", unrelatedHeader, "BOTTOMLEFT", 0, -12)
    autoLogToggle.Text:SetText("Enable Auto Combat Logging")

    local autoLogText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    autoLogText:SetPoint("TOPLEFT", autoLogToggle, "BOTTOMLEFT", 4, -6)
    autoLogText:SetText("Turns /combatlog on in raids and Mythic+ automatically.")

    unrelatedControls = { unrelatedHeader, autoLogToggle, autoLogText }

    slider:SetScript("OnValueChanged", function(_, value)
        CenterMarkerDB.size = addon.clamp(math.floor(value + 0.5), 8, 256)
        addon.applySettings()
        editBox:SetNumber(CenterMarkerDB.size)
    end)

    local function applyBoxValue()
        local value = tonumber(editBox:GetText())
        if value then
            CenterMarkerDB.size = addon.clamp(math.floor(value + 0.5), 8, 256)
            slider:SetValue(CenterMarkerDB.size)
            addon.applySettings()
        else
            editBox:SetNumber(CenterMarkerDB.size)
        end
    end

    editBox:SetScript("OnEnterPressed", applyBoxValue)
    editBox:SetScript("OnEditFocusLost", applyBoxValue)

    enableCheck:SetScript("OnClick", function(self)
        CenterMarkerDB.enabled = self:GetChecked()
        addon.applySettings()
    end)

    alphaSlider:SetScript("OnValueChanged", function(_, value)
        CenterMarkerDB.alpha = addon.clamp(value, 0, 1)
        addon.applySettings()
        alphaEdit:SetText(string.format("%.2f", CenterMarkerDB.alpha))
    end)

    local function applyAlphaBox()
        local value = tonumber(alphaEdit:GetText())
        if value then
            CenterMarkerDB.alpha = addon.clamp(value, 0, 1)
            alphaSlider:SetValue(CenterMarkerDB.alpha)
            addon.applySettings()
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
            addon.setColor(r, g, b)
            swatchTexture:SetColorTexture(r, g, b, 1)
        end

        local function restoreColor()
            local r, g, b = table.unpack(prev)
            addon.setColor(r, g, b)
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
            addon.applySettings()
        else
            feetOffsetBox:SetText(tostring(CenterMarkerDB.placeOffset or defaults.placeOffset))
        end
    end

    feetOffsetBox:SetScript("OnEnterPressed", applyFeetOffset)
    feetOffsetBox:SetScript("OnEditFocusLost", applyFeetOffset)

    local function resizeToContent()
        local top = frame:GetTop()
        local bottom = feetOffsetBox:GetBottom()
        if autoLogText:GetBottom() then
            bottom = math.min(bottom, autoLogText:GetBottom())
        end
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
        autoLogToggle:SetChecked(CenterMarkerDB.autoCombatLogEnabled)
        resizeToContent()
        toggleTab("main")
    end)

    autoLogToggle:SetScript("OnClick", function(self)
        CenterMarkerDB.autoCombatLogEnabled = self:GetChecked()
        if addon.combatLog then
            addon.combatLog.evaluate("CONFIG_TOGGLE")
        end
    end)

    return frame
end

function addon.toggleConfigFrame()
    if not configFrame then
        configFrame = createConfigFrame()
    end

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end
