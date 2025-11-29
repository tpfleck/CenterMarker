local addon = CenterMarker

local limits = addon.limits

local function printHelp()
    print("|cffFFD200CenterMarker|r commands:")
    print("/cm           - Open config panel")
    print(string.format("/cm size <%d-%d> - Set size", limits.size.min, limits.size.max))
    print(string.format("/cm alpha <%.1f-%.1f> - Set opacity", limits.alpha.min, limits.alpha.max))
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

local handlers = {
    toggle = toggleEnabled,
    size = setSize,
    alpha = setAlpha,
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
