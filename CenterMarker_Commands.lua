local addon = CenterMarker

local function printHelp()
    print("|cffFFD200CenterMarker|r commands:")
    print("/cm           - Open config panel")
    print("/cm toggle    - Show or hide the marker")
    print("/cm size <px> - Set size (8-256)")
    print("/cm alpha <0-1> - Set opacity (0 to 1)")
    print("/cm help      - Show these commands")
end

addon.printHelp = printHelp

SLASH_CENTERMARKER1 = "/centermarker"
SLASH_CENTERMARKER2 = "/cm"

SlashCmdList.CENTERMARKER = function(msg)
    local command, rest = msg:match("^(%S+)%s*(.*)$")
    command = command and command:lower() or ""

    if command == "" then
        addon.toggleConfigFrame()
    elseif command == "toggle" then
        CenterMarkerDB.enabled = not CenterMarkerDB.enabled
        addon.applySettings()
        print("CenterMarker: " .. (CenterMarkerDB.enabled and "shown" or "hidden"))
    elseif command == "size" then
        local value = tonumber(rest)
        if value then
            CenterMarkerDB.size = addon.clamp(math.floor(value + 0.5), 8, 256)
            addon.applySettings()
            print("CenterMarker size set to " .. CenterMarkerDB.size .. "px")
        else
            print("CenterMarker: size expects a number, e.g. /cm size 80")
        end
    elseif command == "alpha" then
        local value = tonumber(rest)
        if value then
            CenterMarkerDB.alpha = addon.clamp(value, 0, 1)
            addon.applySettings()
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
