local addon = CenterMarker

local combatLog = {}
addon.combatLog = combatLog

local function ensureDB()
    CenterMarkerDB = addon.normalizeDB(CenterMarkerDB)
    return CenterMarkerDB
end

local difficultyRules = {
    { enabled = false, label = "Always on", match = function() return true end },
    {
        enabled = true,
        label = "Mythic+ Dungeon",
        match = function(info, eventName)
            return eventName == "CHALLENGE_MODE_START" or (info.instanceType == "party" and info.difficultyID == 8)
        end,
    },
    { enabled = true, label = "Mythic Raid", match = function(info) return info.instanceType == "raid" and info.difficultyID == 16 end },
    { enabled = true, label = "Heroic Raid", match = function(info) return info.instanceType == "raid" and info.difficultyID == 15 end },
    { enabled = true, label = "Normal Raid", match = function(info) return info.instanceType == "raid" and info.difficultyID == 14 end },
    { enabled = false, label = "Raid Finder", match = function(info) return info.instanceType == "raid" and info.difficultyID == 17 end },
    {
        enabled = false,
        label = "Normal Dungeon",
        match = function(info)
            return info.instanceType == "party" and info.difficultyID == 1 and info.maxPlayers == 5
        end,
    },
    {
        enabled = false,
        label = "Heroic Dungeon",
        match = function(info)
            return info.instanceType == "party" and info.difficultyID == 2 and info.maxPlayers == 5
        end,
    },
    {
        enabled = false,
        label = "Mythic Dungeon",
        match = function(info)
            return info.instanceType == "party" and info.difficultyID == 23 and info.maxPlayers == 5
        end,
    },
    {
        enabled = false,
        label = "Timewalker Dungeon",
        match = function(info)
            return info.instanceType == "party" and info.difficultyID == 24 and info.maxPlayers == 5
        end,
    },
    { enabled = false, label = "Scenario", match = function(info) return info.instanceType == "scenario" end },
    {
        enabled = false,
        label = "Legacy Raid",
        match = function(info)
            local d = info.difficultyID
            local legacy = d == 3 or d == 4 or d == 5 or d == 6 or d == 7 or d == 9
            return info.instanceType == "raid" and legacy
        end,
    },
}

local function readInstanceInfo()
    local name, instanceType, difficultyID, difficultyName, maxPlayers, _, _, mapID, instanceGroupSize = GetInstanceInfo()
    return {
        name = name or "",
        instanceType = instanceType,
        difficultyID = difficultyID or 0,
        difficultyName = difficultyName or "",
        maxPlayers = maxPlayers or 0,
        instanceGroupSize = instanceGroupSize or 0,
        mapID = mapID or 0,
    }
end

local function shouldLog(eventName, info)
    for _, rule in ipairs(difficultyRules) do
        if rule.enabled and rule.match(info, eventName) then
            return true, rule.label
        end
    end
    return false
end

local function announce(enabled, reason)
    local db = ensureDB()
    if not db.autoCombatLogAnnounce then
        return
    end
    local frame = DEFAULT_CHAT_FRAME or ChatFrame1
    if not frame then
        return
    end
    local stateLabel = enabled and "ON" or "OFF"
    local suffix = reason and (" (" .. reason .. ")") or ""
    frame:AddMessage(string.format("|cffFFD200CenterMarker|r auto combat logging %s%s", stateLabel, suffix))
end

local function setLogging(enabled, reason)
    if combatLog.active == enabled then
        return
    end
    LoggingCombat(enabled)
    combatLog.active = enabled
    announce(enabled, reason)
end

function combatLog.evaluate(eventName)
    local db = ensureDB()
    combatLog.active = LoggingCombat() and true or false

    if not db.autoCombatLogEnabled then
        if combatLog.active then
            setLogging(false, "disabled")
        end
        return
    end

    local info = readInstanceInfo()
    local logThis, reason = shouldLog(eventName, info)

    if logThis then
        setLogging(true, reason or info.difficultyName or info.name)
    else
        setLogging(false, "left instance")
    end
end

function combatLog.bootstrap()
    ensureDB()
    combatLog.active = LoggingCombat() and true or false
    combatLog.evaluate("PLAYER_ENTERING_WORLD")
end
