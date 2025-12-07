local addon = CenterMarker

local limits = addon.limits

local function printHelp()
    print("|cffFFD200CenterMarker|r commands:")
    print("/cm           - Open config panel")
    print(string.format("/cm size <%d-%d> - Set size", limits.size.min, limits.size.max))
    print(string.format("/cm alpha <%.1f-%.1f> - Set opacity", limits.alpha.min, limits.alpha.max))
    print("/cm kb        - Open keybind menu")
    print("/cm cdm       - Open Cooldown Manager settings")
    print("/cm toggle    - Show or hide the marker")
    print("/cm help      - Show these commands")
end

addon.printHelp = printHelp

local function toggleEnabled()
    CenterMarkerDB.enabled = not CenterMarkerDB.enabled
    addon.applySettings()
    print("CenterMarker: " .. (CenterMarkerDB.enabled and "shown" or "hidden"))
end

local function setSize(rest)
    local value = tonumber(rest)
    if not value then
        print(string.format("CenterMarker: size expects a number (%d-%d), e.g. /cm size 80", limits.size.min, limits.size.max))
        return
    end
    CenterMarkerDB.size = addon.clamp(math.floor(value + 0.5), limits.size.min, limits.size.max)
    addon.applySettings()
    print("CenterMarker size set to " .. CenterMarkerDB.size .. "px")
end

local function setAlpha(rest)
    local value = tonumber(rest)
    if not value then
        print(string.format("CenterMarker: alpha expects %.1f-%.1f, e.g. /cm alpha 0.5", limits.alpha.min, limits.alpha.max))
        return
    end
    CenterMarkerDB.alpha = addon.clamp(value, limits.alpha.min, limits.alpha.max)
    addon.applySettings()
    print("CenterMarker opacity set to " .. CenterMarkerDB.alpha)
end

local function openKeybindMenu()
    if InCombatLockdown and InCombatLockdown() then
        print("CenterMarker: cannot open keybinds in combat.")
        return
    end

    if not QuickKeybindFrame and QuickKeybindFrame_LoadUI then
        QuickKeybindFrame_LoadUI()
    end

    if QuickKeybindFrame then
        ShowUIPanel(QuickKeybindFrame)
        return
    end

    if not KeyBindingFrame and KeyBindingFrame_LoadUI then
        KeyBindingFrame_LoadUI()
    end

    if KeyBindingFrame then
        ShowUIPanel(KeyBindingFrame)
        return
    end

    print("CenterMarker: unable to open the keybind menu.")
end

local function openCooldownManagerSettings()
    if CooldownViewerSettings and CooldownViewerSettings.Show then
        CooldownViewerSettings:Show()
        return
    end

    print("CenterMarker: Cooldown Manager settings are unavailable.")
end

local handlers = {
    toggle = toggleEnabled,
    size = setSize,
    alpha = setAlpha,
    kb = openKeybindMenu,
    cdm = openCooldownManagerSettings,
    help = printHelp,
    ["?"] = printHelp,
}

SLASH_CENTERMARKER1 = "/centermarker"
SLASH_CENTERMARKER2 = "/cm"

SlashCmdList.CENTERMARKER = function(msg)
    CenterMarkerDB = addon.normalizeDB(CenterMarkerDB)
    local command, rest = msg:match("^(%S+)%s*(.*)$")
    command = command and command:lower() or ""

    if command == "" then
        addon.toggleConfigFrame()
        return
    end

    local handler = handlers[command]
    if handler then
        handler(rest)
    else
        print("CenterMarker: unknown command. Use /cm help for options.")
    end
end
