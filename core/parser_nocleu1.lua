
---@type details
local Details = Details
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@class blizzparser : eventlistener
---@field InCombat boolean
---@field ParserFrame frame

local debug = false
local L = {}

local debugMode = false
local debugTime = GetTime()
local debugTexts = {}

local printDebug = function(...)
    if debugMode then
        print("|cFFFFFF22Details!Debug:", ...)
    end
end


local CONST_MAX_DAMAGEMETER_TYPES = 0

if Enum and Enum.DamageMeterType then
    for k, v in pairs(Enum.DamageMeterType) do
        if (v > CONST_MAX_DAMAGEMETER_TYPES) then
            CONST_MAX_DAMAGEMETER_TYPES = v
        end
    end
end

local combatStartTime = 0 --GetTime()
local combatEndTime = 0 --GetTime()

--store sessionIds already added to Details!
local storedSessionIds = {}
--store information about a stored session
---@type table<number, sessioncache>
local sessionCache

local arenaSessionIdStart = 0
local battlegroundSessionIdStart = 0

local spellContainerClass = Details.container_habilidades
local containerUtilityType = Details.container_type.CONTAINER_MISC_CLASS

local bRegenIsDisabled = false --based on the event REGEN_DISABLED/REGEN_ENABLED
local bPlayerInCombat = false --based on the event PLAYER_IN_COMBAT_CHANGED

local targetGUID

local restrictionFlag = 0x0

local onPvpMatch = false
local sessionIdAtArenaStart = 0

local latestEncounterSessionId = 0

---@class encounterdata : table
---@field encounterId number
---@field encounterName string
---@field difficultyId number
---@field startTime number
---@field zoneName string
---@field zoneType string
---@field zoneMapId number
---@field sessionId number?
---@field instanceType string
---@field endTime number?
---@field endStatus number?
---@field kill boolean?
---@field difficultyName string?

Details.PvPPlayers = {}

---@class sessionmythicplus : table
---@field startTime number
---@field endTime number?
---@field startUnixTime number
---@field endUnixTime number?
---@field startDate string
---@field endDate string?
---@field sessionId number the session id the client was when the mythic+ started
---@field level number
---@field mapId number
---@field isActive boolean whether the mythic+ is currently active or completed

---@type sessionmythicplus
local mythicPlusInfo = {
    startTime = 0,
    endTime = 0,
    startUnixTime = 0,
    endUnixTime = 0,
    startDate = "",
    endDate = "",
    sessionId = 0,
    level = 0,
    mapId = 0,
    isActive = false,
}

local currentZoneType = "none"

---@class bparser : table
---@field InSecretLockdown fun():boolean
---@field ShowTooltip fun(instance:instance, instanceLine:detailsline)
---@field IsDamageMeterSwapped fun():boolean
---@field GetDamageMeterTypeFromDisplay fun(mainDisplay:number, subDisplay:number):number
---@field ToggleDamageMeterSwap fun() : boolean return value is true if swapped, false if not swapped
---@field UpdateDamageMeterSwap fun()
---@field ChangeSegment fun(blzWindow:blzwindow, sessionType:damagemeter_session_type|nil, sessionId:number|nil)
---@field HideTooltip_Hook fun(instanceLine:detailsline, mouse:string)
---@field ShowTooltip_Hook fun(instanceLine:detailsline, mouse:string)
---@field UpdateDamageMeterAppearance fun(blzWindow:blzwindow)
---@field UpdateAllDamageMeterWindowsAppearance fun()
---@field SetSessionCache fun(t:table)
---@field WipeStoredSessionIds fun()
---@field IsServerSideSessionOpen fun(sessionId:number?):boolean if the sessionId is nil, checks the current session
---@field WaitServerDropCombat fun(callback:function)
---@field ResetServerDM fun()

local debugFrame = CreateFrame("frame", "DetailsParserDebugFrame2", UIParent)

local _print = print
local print = function(...)
    if debug then
        _print(...)
    end
end

--local print = _G.print

local restrictionFlags

if Enum.AddOnRestrictionType then
    restrictionFlags = {
        [Enum.AddOnRestrictionType.Combat]        = 0x1,
        [Enum.AddOnRestrictionType.Encounter]     = 0x2,
        [Enum.AddOnRestrictionType.ChallengeMode] = 0x4,
        [Enum.AddOnRestrictionType.PvPMatch]      = 0x8,
        [Enum.AddOnRestrictionType.Map]           = 0x10,
    }
end

---@type bparser
local bParser = Details222.BParser

--tooltip settings
local tooltipAmountOfLines = 20
local tooltipLineHeight = 20
local tooltipFontStringPadding = 6 --space between each font string horizontally
local tooltipPadding = 1 --space between each line
local cantStartUpdater = false
local updaterTicker = nil

function bParser.InSecretLockdown()
    return bRegenIsDisabled
end

local isInEncounter = function()
    return IsEncounterInProgress and IsEncounterInProgress()
end

local latestSessionOpened

function bParser.GetPlayerTargetGUID()
    return targetGUID
end

local isSessionIdStored = function(sessionId)
    return storedSessionIds[sessionId] == true
end
local storeSessionId = function(sessionId)
    storedSessionIds[sessionId] = true
end
local wipeStoredSessionIds = function()
    if storedSessionIds then
        table.wipe(storedSessionIds)
    end
    if sessionCache then
        table.wipe(sessionCache)
    end
end
bParser.WipeStoredSessionIds = wipeStoredSessionIds

local getSessionCombatTime = function(sessionId)
    local session = sessionCache[sessionId]
    if session then
        local startTime = session.startTime
        local endTime = session.endTime or GetTime()
        return endTime - startTime
    end
    return 0
end
local removeFromSessionCache = function(sessionId)
    sessionCache[sessionId] = nil
end

local getSessionStartAndEndTime = function(sessionId)
    local info = sessionCache[sessionId]
    if info then
        return info.startTime, info.endTime
    end
    return 0, 0
end

local getAmountOfSessions = function()
    return #C_DamageMeter.GetAvailableCombatSessions()
end

local getCurrentSessionId = function()
    ---@type damagemeter_availablecombat_session[]
    local sessions = C_DamageMeter.GetAvailableCombatSessions()
    if #sessions > 0 then
        return sessions[#sessions].sessionID
    end
    return 0
end

local getDetailsSegmentIdFromSession = function(sessionId)
    ---@type damagemeter_availablecombat_session[]
    local sessions = C_DamageMeter.GetAvailableCombatSessions()
    for i = 1, #sessions do
        if sessions[i].sessionID == sessionId then
           local thisSessionName = sessions[i].name
           local thisSessionId = sessions[i].sessionID
           return thisSessionName .. thisSessionId
        end
    end
end

--debug function
local showActiveRestrictions = function()
    local stateCombat = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Combat)
    local stateEncounter = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Encounter)
    local stateChallengeMode = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.ChallengeMode)
    local pvp = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.PvPMatch)
    local map = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Map)
    --print("(debug) Restrictions:", stateCombat, stateEncounter, stateChallengeMode, pvp, map)
end

local doesSessionExists = function(sessionId)
    ---@type damagemeter_availablecombat_session[]
    local sessions = C_DamageMeter.GetAvailableCombatSessions()
    for i = 1, #sessions do
        if sessions[i].sessionID == sessionId then
            return true
        end
    end
    return false
end

---@class sessioncache : table
---@field startTime number
---@field endTime number?
---@field startUnixTime number
---@field endUnixTime number?
---@field startDate string
---@field endDate string?
---@field sessionId number
---@field added boolean?
---@field detailsId string?
---@field sessionName string?
---@field encounterId number?
---@field encounterName string?
---@field encounterData encounterdata?

local getSession = function(sessionId)
    return sessionCache[sessionId]
end

local createAndAddSession = function(sessionId)
    local session = getSession(sessionId)
    if not session then
        ---@type sessioncache
        local newSession = {
            startTime = GetTime(),
            startUnixTime = time(),
            startDate = date("%H:%M:%S"),
            sessionId = sessionId,
            added = false,
            detailsId = getDetailsSegmentIdFromSession(sessionId),
        }
        sessionCache[sessionId] = newSession
        return newSession
    else
        return session
        --[[
        local timeNow = time()
        if session.startUnixTime+15 < timeNow then
            session.startTime = GetTime()
            session.startUnixTime = timeNow
            session.startDate = date("%H:%M:%S")
            session.added = false
            session.detailsId = getDetailsSegmentIdFromSession(sessionId)
            return true
        end
        --]]
    end
end

local getSessions = function()
    return sessionCache
end

local StopUpdaterAndClearWindow

---@type table<number, guid>
local guidCache = {}

---@class details222
---@field DLC12_Combat_Data table

local lastReset = GetTime()
local resetOriginal = C_DamageMeter and C_DamageMeter.ResetAllCombatSessions
local ResetAllCombatSessions = function()
    --print("(debug) reseting Damage Meter data", debugstack())
    resetOriginal()
    latestEncounterSessionId = 0
    latestSessionOpened = nil
end

if C_DamageMeter then
    C_DamageMeter.ResetAllCombatSessions = function()
        --details reset its data first and than reset the blz data
        if lastReset+1 < GetTime() then
            Details:ResetSegmentData()
            lastReset = GetTime()
        end
    end
end

local waitServerCallbacks = {}
local waitServerTicker

local tickerFunc = function(tickerObject)
    if InCombatLockdown() then
        return
    end

    local stateCombat = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Combat)
    if stateCombat > 0 then
        return
    end

    local isSessionOpen = bParser.IsServerSideSessionOpen()
    if not isSessionOpen then
        if waitServerTicker then
            waitServerTicker:Cancel()
            waitServerTicker = nil
        end

        for _, thisCallback in ipairs(waitServerCallbacks) do
            thisCallback()
        end

        table.wipe(waitServerCallbacks)

        return true
    end
end

function bParser.WaitServerDropCombat(callback)
    detailsFramework.table.addunique(waitServerCallbacks, callback)
    debugTexts[#debugTexts+1] = {left = "WaitServerDropCombat", right = "add", time = GetTime(), date = date("%H:%M:%S")}

    --immediately
    local isSessionClosed = tickerFunc()
    if isSessionClosed then
        return
    end

    --start ticker
    if not waitServerTicker then
        waitServerTicker = C_Timer.NewTicker(.3, tickerFunc)
    end
end

Details222.DLC12_Combat_Data = {
    nextSegment = 0,
    combatData = {},
}

local prototype = {
    name = "",
    guid = "",
    class = "",
    damage = 0,
    healing = 0,
    absorbs = 0,
    interrupts = 0,
    dispels = 0,
    damageTaken = 0,
    dps = 0,
    hps = 0,
    aps = 0,
    ips = 0,
    dips = 0,
    dtps = 0,
    isPlayer = false,
    spells = {},
}

local buildPlayerData = function(data, sessionID)
    for damageMeterType = 0, 7 do
        ---@type damagemeter_combat_session
        local session = C_DamageMeter.GetCombatSessionFromID(sessionID, damageMeterType)
        local players = session.combatSources

        for i = 1, #players do
            ---@type damagemeter_combat_source
            local source = players[i]

            local thisData = data[source.name]
            if not thisData then
                thisData = detailsFramework.table.copy({}, prototype)
                data[source.name] = thisData
            end

            thisData.name = source.name
            thisData.guid = source.sourceGUID
            thisData.class = source.classFilename
            thisData.isPlayer = source.isLocalPlayer

                if (damageMeterType == Enum.DamageMeterType.DamageDone) then
                thisData.damage = source.totalAmount
                thisData.dps = source.amountPerSecond

            elseif (damageMeterType == Enum.DamageMeterType.HealingDone) then
                thisData.healing = source.totalAmount
                thisData.hps = source.amountPerSecond

            elseif (damageMeterType == Enum.DamageMeterType.Absorbs) then
                thisData.absorbs = source.totalAmount
                thisData.aps = source.amountPerSecond

            elseif (damageMeterType == Enum.DamageMeterType.Interrupts) then
                thisData.interrupts = source.totalAmount
                thisData.ips = source.amountPerSecond

            elseif (damageMeterType == Enum.DamageMeterType.Dispels) then
                thisData.dispels = source.totalAmount
                thisData.dips = source.amountPerSecond

            elseif (damageMeterType == Enum.DamageMeterType.DamageTaken) then
                thisData.damageTaken = source.totalAmount
                thisData.dtps = source.amountPerSecond
            end
        end
    end

    return data
end

--    C_DamageMeter.SetSegmentsToManual(true)
--    C_DamageMeter.StartSegment()
--    C_DamageMeter.StopSegment()

---@param sessionType damagemeter_session_parameter
---@param sessionID damagemeter_session_type|segmentid
---@param damageMeterType damagemeter_type
---@param sourceGUID guid
---@return damagemeter_unit_spells sourceSpells
local getSourceSpells = function(sessionType, sessionID, damageMeterType, sourceGUID)
    if (sessionType == DAMAGE_METER_SESSIONPARAMETER_TYPE) then
        return C_DamageMeter.GetCombatSessionSourceFromType(sessionID, damageMeterType, sourceGUID)
    elseif (sessionType == DAMAGE_METER_SESSIONPARAMETER_ID) then
        return C_DamageMeter.GetCombatSessionSourceFromID(sessionID, damageMeterType, sourceGUID)
    end
    return {maxAmount = 0, combatSpells = {}}
end

---@param instance instance
local doTrick = function(instance) --~trick
    local mainDisplay, subDisplay = instance:GetDisplay()
    local segmentId = nil
    local modeId = nil
    local quick = true
    if (mainDisplay == DETAILS_ATTRIBUTE_DAMAGE) then
        instance:SetDisplay(segmentId, DETAILS_ATTRIBUTE_HEAL, DETAILS_SUBATTRIBUTE_HEALDONE, modeId, quick)
        instance:SetDisplay(segmentId, DETAILS_ATTRIBUTE_DAMAGE, subDisplay, modeId, quick)
    elseif (mainDisplay == DETAILS_ATTRIBUTE_HEAL) then
        instance:SetDisplay(segmentId, DETAILS_ATTRIBUTE_DAMAGE, DETAILS_SUBATTRIBUTE_DAMAGEDONE, modeId, quick)
        instance:SetDisplay(segmentId, DETAILS_ATTRIBUTE_HEAL, subDisplay, modeId, quick)
    end
end

local doUpdate = function()
    Details.no_fade_animation = true
    Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse)
    Details:RefreshMainWindow(-1, true)
    Details:InstanceCall(doTrick)
    Details.no_fade_animation = false
end

local scheduledUpdateObject
function bParser.DoUpdateOnDetails()
    scheduledUpdateObject = nil
    doUpdate()
    C_Timer.After(Details.update_speed+0.03, doUpdate)
end

---@param sessionId number
---@return boolean hasSources
---@return number amountOfSources
local hasSources = function(sessionId)
    ---@type damagemeter_combat_session
    local blzDamageContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone)
    if #blzDamageContainer.combatSources > 0 then
        return true, #blzDamageContainer.combatSources
    end

    ---@type damagemeter_combat_session
    local blzHealContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.HealingDone)
    if #blzHealContainer.combatSources > 0 then
        return true, #blzHealContainer.combatSources
    end

    return false, 0
end

local doesSessionHasSources = function(session)

end

local containerIsOpen = function(sessionId, combatType)
    ---@type damagemeter_combat_session
    local damageMeterContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, combatType)
    local actorList = damageMeterContainer.combatSources
    if #actorList > 0 then
        for i = 1, #actorList do
            ---@type damagemeter_combat_source
            local source = actorList[i]
            local sourceName = source.name
            local sourceGUID = source.sourceGUID
            local amountDone = source.totalAmount
            local classFile = source.classFilename

            if issecretvalue(sourceName) or issecretvalue(sourceGUID) or issecretvalue(amountDone) or issecretvalue(classFile) then
                return true, issecretvalue(sourceName) and "name " or " ", issecretvalue(sourceGUID) and "guid " or " ", issecretvalue(amountDone) and "amountDone " or " ", issecretvalue(classFile) and "class " or " "
            end
        end
    end
end

---@return boolean
---@return string|nil nameField
---@return string|nil guidField
---@return string|nil amountDoneField
---@return string|nil classField
local isServerSideSessionOpen = function(sessionId)
    if sessionId then
        for combatType = 0, CONST_MAX_DAMAGEMETER_TYPES do
            local isSecret, nameSecret, guidSecret, amountDoneSecret, classSecret = containerIsOpen(sessionId, combatType)
            if isSecret then
                return true, nameSecret, guidSecret, amountDoneSecret, classSecret
            end
        end
    else
        local currentSessionId = getCurrentSessionId()
        for thisSession = currentSessionId, currentSessionId-2, -1 do
            if thisSession > 0 then
                for combatType = 0, CONST_MAX_DAMAGEMETER_TYPES do
                    local isSecret, nameSecret, guidSecret, amountDoneSecret, classSecret = containerIsOpen(thisSession, combatType)
                    if isSecret then
                        return true, nameSecret, guidSecret, amountDoneSecret, classSecret
                    end
                end
            end
        end
    end

    return false, " ", " ", " ", " "
end
bParser.IsServerSideSessionOpen = isServerSideSessionOpen
--isso = isServerSideSessionOpen


local sessionsWithSecrets = {}
local waitSecretDropTimer

local cancelWaitSecretDropTimer = function()
    if waitSecretDropTimer then
        waitSecretDropTimer:Cancel()
        waitSecretDropTimer = nil
        wipe(sessionsWithSecrets)
    end
end

local removeSessionFromWaitList = function(sessionId)
    sessionsWithSecrets[sessionId] = nil
    if not next(sessionsWithSecrets) then
        cancelWaitSecretDropTimer()
    end
end

local startWaitSecretDropTimer = function(sessionId)
    sessionsWithSecrets[sessionId] = true

    if waitSecretDropTimer then
        return
    end

    waitSecretDropTimer = C_Timer.NewTicker(1, function(timerObject)
        if InCombatLockdown() then
            return
        end

        local stateCombat = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Combat)
        if stateCombat > 0 then
            return
        end

        for sessionIdWithSecret in pairs(sessionsWithSecrets) do
            local hasSecret = isServerSideSessionOpen(sessionIdWithSecret)
            local isFreeToGo = not hasSecret

            if isFreeToGo then
                --showActiveRestrictions()

                removeSessionFromWaitList(sessionIdWithSecret)
                --local stateChallengeMode = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.ChallengeMode)
                --!need to check for m+ plus restrictions
                L.ParseSegments(sessionIdWithSecret)
            else
                --showActiveRestrictions()
            end

            if not next(sessionsWithSecrets) then
                cancelWaitSecretDropTimer()
            end
        end
    end)
end



---@param parameterType any
---@param session sessioncache
---@param bIsUpdate boolean|nil
local addSegment = function(parameterType, session, bIsUpdate, detailsId)
    local sessionId = session.sessionId
    if not sessionId then
        dumpt(session)
    end

    ---@type combat
    local currentCombat

    -------DAMAGE DONE
    ---@type damagemeter_combat_session
    local blzDamageContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone)
    local damageActorList = blzDamageContainer.combatSources

    if not bIsUpdate then
        Details222.StartCombat()
        currentCombat = Details:GetCurrentCombat()
    else
        ---@diagnostic disable-next-line: cast-local-type
        currentCombat = Details:GetCombatWithSessionId(detailsId)
        if currentCombat then
            currentCombat.totals[1] = 0
            currentCombat.totals[2] = 0
            currentCombat.totals_grupo[1] = 0
            currentCombat.totals_grupo[2] = 0
            currentCombat.totals[4].interrupt = 0
            currentCombat.totals_grupo[4].interrupt = 0
            currentCombat.totals[4].dispell = 0
            currentCombat.totals_grupo[4].dispell = 0
        else
            Details222.StartCombat()
            currentCombat = Details:GetCurrentCombat()
            bIsUpdate = false
        end
    end

    local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
    local healingContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_HEAL)
    local utilityContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_MISC)

    --pull deathlog data and parse it

    local order = Details:GetOrderNumber()

    for i = 1, #damageActorList do
        ---@type damagemeter_combat_source
        local source = damageActorList[i]

        local sourceName = source.name
        local sourceGUID = source.sourceGUID

        if issecretvalue(sourceName) then
            local stateCombat = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Combat)
            local stateEncounter = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Encounter)
            local stateChallengeMode = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.ChallengeMode)
            local pvp = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.PvPMatch)
            local map = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Map)

            Details:Msg("(2) Value is secret and an error will occur, Restrictions in place:", stateCombat, stateEncounter, stateChallengeMode, pvp, map)
        end

        ---@type actordamage
        local actor = damageContainer:GetOrCreateActor(sourceGUID, sourceName, 0x512, true)

        actor.nome = sourceName
        actor.total = source.totalAmount
        actor.classe = source.classFilename
        actor.last_dps = source.amountPerSecond
        actor.specIcon = source.specIconID
        actor.serial = sourceGUID
        actor.grupo = true

        if source.specIconID and not guidCache[source.specIconID] then
            guidCache[source.specIconID] = sourceGUID
        end

        currentCombat.totals[1] = currentCombat.totals[1] + source.totalAmount
        currentCombat.totals_grupo[1] = currentCombat.totals_grupo[1] + source.totalAmount

        --spells
        local spells = getSourceSpells(parameterType, sessionId, Enum.DamageMeterType.DamageDone, source.sourceGUID)
        for j = 1, #spells.combatSpells do
            local thisSpell = spells.combatSpells[j]
            local bCanCreateSpellIfMissing = true
            local spellTable = actor.spells:GetOrCreateSpell(thisSpell.spellID, bCanCreateSpellIfMissing, "SPELL_DAMAGE")
            spellTable.total = thisSpell.totalAmount
            spellTable.id = thisSpell.spellID
            spellTable.counter = order
            --thisSpell.creatureName
            --thisSpell.combatSpellDetails
        end
    end

    -------DAMAGE TAKEN
    ---@type damagemeter_combat_session
    local blzDamageTakenContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageTaken)
    local damageTakenActorList = blzDamageTakenContainer.combatSources
    for i = 1, #damageTakenActorList do
        ---@type damagemeter_combat_source
        local source = damageTakenActorList[i]

        ---@type actordamage
        local actor = damageContainer:GetOrCreateActor(source.sourceGUID, source.name, 0x512, true)

        actor.nome = source.name
        actor.damage_taken = source.totalAmount
        actor.damage_taken_ps = source.amountPerSecond
        actor.classe = source.classFilename
        actor.last_dps = actor.last_dps
        actor.specIcon = source.specIconID
        actor.serial = source.sourceGUID
        actor.grupo = true
    end

    -------HEALING DONE
    ---@type damagemeter_combat_session
    local blzHealingContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.HealingDone)
    local healingActorList = blzHealingContainer.combatSources
    for i = 1, #healingActorList do
        ---@type damagemeter_combat_source
        local source = healingActorList[i]

        ---@type actorheal
        local actor = healingContainer:GetOrCreateActor(source.sourceGUID, source.name, 0x512, true)

        actor.nome = source.name
        actor.total = source.totalAmount
        actor.classe = source.classFilename
        actor.last_hps = source.amountPerSecond
        actor.specIcon = source.specIconID
        actor.serial = source.sourceGUID
        actor.grupo = true

        currentCombat.totals[2] = currentCombat.totals[2] + source.totalAmount
        currentCombat.totals_grupo[2] = currentCombat.totals_grupo[2] + source.totalAmount

        --spells
        local spells = getSourceSpells(parameterType, sessionId, Enum.DamageMeterType.HealingDone, source.sourceGUID)
        for j = 1, #spells.combatSpells do
            local thisSpell = spells.combatSpells[j]
            local bCanCreateSpellIfMissing = true
            local spellTable = actor.spells:GetOrCreateSpell(thisSpell.spellID, bCanCreateSpellIfMissing, "SPELL_HEAL")
            spellTable.total = thisSpell.totalAmount
            spellTable.id = thisSpell.spellID
            --thisSpell.creatureName
            --thisSpell.combatSpellDetails
            spellTable.counter = order
        end
    end

    -------HEALING ABSORBS
    ---@type damagemeter_combat_session
    local blzHealingAbsorbsContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.Absorbs)
    local healingAbsorbsActorList = blzHealingAbsorbsContainer.combatSources
    for i = 1, #healingAbsorbsActorList do
        ---@type damagemeter_combat_source
        local source = healingAbsorbsActorList[i]

        ---@type actorheal
        local actor = healingContainer:GetOrCreateActor(source.sourceGUID, source.name, 0x512, true)

        actor.nome = source.name
        actor.totalabsorb = source.totalAmount
        actor.totalabsorb_ps = source.amountPerSecond
        actor.classe = source.classFilename
        actor.last_hps = actor.last_hps
        actor.specIcon = source.specIconID
        actor.serial = source.sourceGUID
        actor.grupo = true
    end

    -------INTERRUPTS
    ---@type damagemeter_combat_session
    local blzInterruptsContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.Interrupts)
    local interruptsActorList = blzInterruptsContainer.combatSources
    for i = 1, #interruptsActorList do
        ---@type damagemeter_combat_source
        local source = interruptsActorList[i]

        ---@type actorutility
        local actor = utilityContainer:GetOrCreateActor(source.sourceGUID, source.name, 0x512, true)

        actor.interrupt_cast_overlap = 0
        actor.interrupt_targets = {}
        actor.interrupt_spells = spellContainerClass:CreateSpellContainer(containerUtilityType)
        actor.interrompeu_oque = {}

        actor.nome = source.name
        actor.interrupt = source.totalAmount + Details:GetOrderNumber()
        actor.classe = source.classFilename
        actor.specIcon = source.specIconID
        actor.serial = source.sourceGUID
        actor.grupo = true

        currentCombat.totals[4].interrupt = currentCombat.totals[4].interrupt + 1
        currentCombat.totals_grupo[4].interrupt = currentCombat.totals_grupo[4].interrupt + 1

        --spells
        local spells = getSourceSpells(parameterType, sessionId, Enum.DamageMeterType.Interrupts, source.sourceGUID)
        for j = 1, #spells.combatSpells do
            local thisSpell = spells.combatSpells[j]
            local bCanCreateSpellIfMissing = true
            local spellTable = actor.interrupt_spells:GetOrCreateSpell(thisSpell.spellID, bCanCreateSpellIfMissing, "SPELL_INTERRUPT")
            spellTable.total = thisSpell.totalAmount
            spellTable.id = thisSpell.spellID
            --thisSpell.creatureName
            --thisSpell.combatSpellDetails
            spellTable.counter = order
        end
    end

    -------DISPELS
    ---@type damagemeter_combat_session
    local blzDispelsContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.Dispels)
    local dispelsActorList = blzDispelsContainer.combatSources
    for i = 1, #dispelsActorList do
        ---@type damagemeter_combat_source
        local source = dispelsActorList[i]

        ---@type actorutility
        local actor = utilityContainer:GetOrCreateActor(source.sourceGUID, source.name, 0x512, true)
        actor.dispell_targets = {}
        actor.dispell_spells = spellContainerClass:CreateSpellContainer(containerUtilityType)
        actor.dispell_oque = {}

        actor.nome = source.name
        actor.dispell = source.totalAmount + Details:GetOrderNumber()
        actor.classe = source.classFilename
        actor.specIcon = source.specIconID
        actor.serial = source.sourceGUID
        actor.grupo = true

        currentCombat.totals[4].dispell = currentCombat.totals[4].dispell + 1
        currentCombat.totals_grupo[4].dispell = currentCombat.totals_grupo[4].dispell + 1

        --spells
        local spells = getSourceSpells(parameterType, Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.Dispels, source.sourceGUID)
        for j = 1, #spells.combatSpells do
            local thisSpell = spells.combatSpells[j]
            local bCanCreateSpellIfMissing = true
            local spellTable = actor.dispell_spells:GetOrCreateSpell(thisSpell.spellID, bCanCreateSpellIfMissing, "SPELL_DISPEL")
            spellTable.total = thisSpell.totalAmount
            spellTable.id = thisSpell.spellID
            --thisSpell.creatureName
            --thisSpell.combatSpellDetails
            spellTable.counter = order
        end
    end

    currentCombat:SetDate(session.startDate, session.endDate)
    currentCombat:SetStartTime(session.startTime)
    currentCombat:SetEndTime(session.endTime)
    currentCombat.combatSessionId = detailsId

    local encounterInfo = Details.encounter_table
    local encounterStartTime = encounterInfo and encounterInfo.start or 0 --GetTime()

    local bCombatEnded = false

    if (encounterStartTime > 0) then
        if (detailsFramework.Math.IsNearlyEqual(encounterStartTime, combatStartTime, 2)) then
            currentCombat:SetEndTime(encounterInfo["end"] or combatEndTime)
            if debug then

            end
            if not bIsUpdate then
                Details:SairDoCombate(encounterInfo.kill, {encounterInfo.id, encounterInfo.name, encounterInfo.diff, encounterInfo.size, encounterInfo.end_status})
            end
            bCombatEnded = true
        end
    end

    local _, instanceType = GetInstanceInfo()
    if (instanceType == "arena") then
        currentCombat.secretArena = true
    end

    if not bIsUpdate then
        if not bCombatEnded then
            Details:SairDoCombate()
        end
        storeSessionId(sessionId)
        debugTexts[#debugTexts+1] = {left = "Segment Added:", right = sessionId, time = GetTime(), date = date("%H:%M:%S")}
    else
        debugTexts[#debugTexts+1] = {left = "Segment Updated:", right = sessionId, time = GetTime(), date = date("%H:%M:%S")}
    end

    --encounterData
    local thisEncounterData = session.encounterData
    if thisEncounterData then
        if not currentCombat.is_boss then
            local ejid = DetailsFramework.EncounterJournal.EJ_GetInstanceForMap(thisEncounterData.zoneMapId)
            if (ejid == 0) then
                ejid = Details:GetInstanceEJID()
            end

            currentCombat.is_boss = {
                index = 0,
                name = thisEncounterData.encounterName,
                encounter = thisEncounterData.encounterName,
                zone = thisEncounterData.zoneName,
                mapid = thisEncounterData.zoneMapId,
                diff = thisEncounterData.difficultyId,
                diff_string = thisEncounterData.difficultyName,
                ej_instance_id = ejid or 0,
                id = thisEncounterData.encounterId,
                unixtime = time()
            }

            --encounter data debug:
            --print("(debug) Added Encounter Data to Combat:", sessionId, thisEncounterData.encounterName)
            --print("(debug) encounterData.endTime:", thisEncounterData.endTime)
            --print("(debug) encounterData.endStatus = " .. tostring(thisEncounterData.endStatus))
            --print("(debug) encounterData.kill = " .. tostring(thisEncounterData.kill))

            currentCombat.is_boss.killed = thisEncounterData.kill
        end
    end

    removeSessionFromWaitList(sessionId)

    return true
end

local parseSegments2 = function()
    debugTexts[#debugTexts+1] = {left = "|cFF00FF00Parse Segments!:", right = GetTime(), time = GetTime(), date = date("%H:%M:%S")}

    local parameterType = DAMAGE_METER_SESSIONPARAMETER_ID

    local amountOfSessions = getAmountOfSessions()
    if amountOfSessions == 0 then
        StopUpdaterAndClearWindow()
        return
    end

    local sessions = {}
    for sessionId = 1, amountOfSessions do
        local sessionInfo = getSession(sessionId)
        if sessionInfo and not sessionInfo.added then
            local sessionExists = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone)
            if sessionExists then
                local hasAtLeastOneSource = hasSources(sessionId)
                if hasAtLeastOneSource then
                    --for some reason sessionInfo was nil
                    table.insert(sessions, {sessionId = sessionId, session = sessionInfo, detailsId = getDetailsSegmentIdFromSession(sessionId)})
                end
            end
        else
            debugTexts[#debugTexts+1] = {left = "|cFFFF8888No Session Info in Cache:", right = sessionId, time = GetTime(), date = date("%H:%M:%S")}
        end
    end

    --[=[
    local currentSessionId = getCurrentSessionId()
    local sessions = {}
    for thisSessionId, session in pairs(sessionCache) do
        local thisSession = C_DamageMeter.GetCombatSessionFromID(thisSessionId, Enum.DamageMeterType.DamageDone)
        if thisSession then
            local hasAtLeastOneSource = hasSources(thisSessionId)
            if hasAtLeastOneSource then
                local hasSecret = isServerSideSessionOpen(thisSessionId)
                if not hasSecret then
                    table.insert(sessions, {sessionId = thisSessionId, session = session, detailsId = getDetailsSegmentIdFromSession(thisSessionId)})
                else
                    startWaitSecretDropTimer(thisSessionId)
                end
            end
        end
    end
    --]=]

    table.sort(sessions, function(a, b)
        return a.sessionId < b.sessionId
    end)

    local needUpdate = false

    for i = 1, #sessions do
        local sessionInfo = sessions[i].session
        local thisSessionId = sessions[i].sessionId
        if not sessionInfo.added then
            if (addSegment(parameterType, sessionInfo, false)) then
                needUpdate = true
                sessionInfo.added = true
            else
                debugTexts[#debugTexts+1] = {left = "|cFFFF8800Failed to Add Session:", right = thisSessionId, time = GetTime(), date = date("%H:%M:%S")}
            end
        end
    end

    StopUpdaterAndClearWindow()

    if needUpdate then
        if not scheduledUpdateObject then
            scheduledUpdateObject = C_Timer.After(0, bParser.DoUpdateOnDetails)
        end
    end

    local hasSessionInCache = false
    for thisSessionId, session in pairs(sessionCache) do
        if not session.added then
            debugTexts[#debugTexts+1] = {left = "|cFFFFFFFFHas Session in cache:", right = thisSessionId, time = GetTime(), date = date("%H:%M:%S")}
            hasSessionInCache = true
            break
        else
            removeFromSessionCache(thisSessionId)
        end
    end

    --if not hasSessionInCache then
        Details222.BParser.ResetServerDM()
        wipeStoredSessionIds()
    --end

    C_Timer.After(2, function()
        local checkEmpryBars = function(instance)
            local bars = instance.barras
            for i = 1, #bars do
                local thisBar = bars[i]
                if thisBar:IsShown() then

                    return
                end
            end
        end
    end)

    latestSessionOpened = nil
end

local parseSegments = function() --~parser
    debugTexts[#debugTexts+1] = {left = "|cFF00FF00Parse Segments!:", right = GetTime(), time = GetTime(), date = date("%H:%M:%S")}

    local isDeadOrGhost = UnitIsDeadOrGhost("player")
    if isDeadOrGhost then
        --print("(debug-note)|cFFFFDD00 parseSegments() player is dead or ghost.|r")
    end

    local parameterType = DAMAGE_METER_SESSIONPARAMETER_ID

    ---@type damagemeter_availablecombat_session[]
    local allSessions = C_DamageMeter.GetAvailableCombatSessions()

    local amountOfSessions = #allSessions
    if amountOfSessions == 0 then
        --print("(debug-note)|cFFFF00FF no sessions to parse.|r")
        debugTexts[#debugTexts+1] = {left = "|cFF00FF44No sessions to add:", right = GetTime(), time = GetTime(), date = date("%H:%M:%S")}
        StopUpdaterAndClearWindow()
        return
    end

    local sessions = {}
    for i = amountOfSessions, 1, -1 do
        local availableSessions = allSessions[i]
        local sessionId = availableSessions.sessionID
        local sessionName = availableSessions.name
        local sessionInfo = getSession(sessionId)
        if sessionInfo and not sessionInfo.added then
            sessionInfo.sessionName = sessionName
            sessionInfo.detailsId = getDetailsSegmentIdFromSession(sessionId)

            if not sessionInfo.endTime then
                sessionInfo.endTime = GetTime()
                sessionInfo.endUnixTime = time()
                sessionInfo.endDate = date("%H:%M:%S")
                debugTexts[#debugTexts+1] = {left = "Previous session was open", right = "closed", time = GetTime(), date = date("%H:%M:%S")}
            end

            local hasAtLeastOneSource, amountOfSources = hasSources(sessionId)
            if hasAtLeastOneSource then
                local numGroupMembers = GetNumGroupMembers()
                local canAdd = true
                if numGroupMembers >= 10 then
                    if (amountOfSources <= 2) then
                        canAdd = false
                    end
                end
                if canAdd then
                    local detailsId = getDetailsSegmentIdFromSession(sessionId)
                    if not Details:HasCombatWithSessionId(detailsId) then
                        table.insert(sessions, {sessionId = sessionId, sessionInfo = sessionInfo, detailsId = detailsId, startUnixTime = sessionInfo.startUnixTime})
                    else
                        --session already added, just update the combat
                        table.insert(sessions, {sessionId = sessionId, sessionInfo = sessionInfo, detailsId = detailsId, startUnixTime = sessionInfo.startUnixTime, isUpdate = true})
                    end
                end
            else
                --remove segmentInfo from cache
                --removeFromSessionCache(sessionId)
                debugTexts[#debugTexts+1] = {left = "|cffff4400Session with no sources", right = "discarded", time = GetTime(), date = date("%H:%M:%S")}
            end

        elseif sessionInfo and sessionInfo.added then
            if sessionInfo.sessionId > sessionId-4 then
                --get combat from details which has the detailsId
                local combat = Details:GetCombatWithSessionId(sessionInfo.detailsId)
                if combat then
                    local firstPlayer = combat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)._ActorTable[1]
                    if firstPlayer then
                        --get combat from blz
                        local blzCombat = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone)
                        if blzCombat then
                            local blzFirstPlayer = blzCombat.combatSources[1]
                            if blzFirstPlayer then
                                if floor(firstPlayer.total) ~= floor(blzFirstPlayer.totalAmount) then
                                    --addSegment(parameterType, sessionInfo, true, sessionInfo.detailsId)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(sessions,
    ---@param a sessioncache
    ---@param b sessioncache
    function(a, b)
        return a.startUnixTime < b.startUnixTime
    end)

    local needUpdate = false

    for i = 1, #sessions do
        local sessionInfo = sessions[i].sessionInfo
        local thisSessionId = sessions[i].sessionId
        local detailsId = sessions[i].detailsId
        local encounterName = sessionInfo.encounterData and sessionInfo.encounterData.encounterName or ""
        --print("(debug-note) adding session:", thisSessionId, "encounter:", encounterName)
        if (addSegment(parameterType, sessionInfo, sessionInfo.isUpdate, detailsId)) then
            --print("(debug-note) session added:", thisSessionId)
            needUpdate = true
            sessionInfo.added = true
        else
            debugTexts[#debugTexts+1] = {left = "|cFFFF8800Failed to Add Session:", right = thisSessionId, time = GetTime(), date = date("%H:%M:%S")}
        end
    end

    StopUpdaterAndClearWindow()

    if needUpdate then
        if not scheduledUpdateObject then
        end
    end
    scheduledUpdateObject = C_Timer.After(0, bParser.DoUpdateOnDetails)


    debugTexts[#debugTexts+1] = {left = " ------------------------------", right = "", time = GetTime(), date = ""}

    --wipe session cache
    --wipeStoredSessionIds()

    --[=[
    local hasSessionInCache = false
    for thisSessionId, session in pairs(sessionCache) do
        if not session.added then
            debugTexts[#debugTexts+1] = {left = "|cFFFFFFFFHas Session in cache:", right = thisSessionId, time = GetTime(), date = date("%H:%M:%S")}
            hasSessionInCache = true
            break
        else
            removeFromSessionCache(thisSessionId)
        end
    end

    if not hasSessionInCache then
        --Details222.BParser.ResetServerDM()
    end
    --]=]
end

--guarantee that the serser has no sessions open
local parseSegments1 = function(sessionId)
    local needUpdate = false
    local parameterType = DAMAGE_METER_SESSIONPARAMETER_ID

    --add a specific session, this is used when a session is waiting for secrets to drop
    if sessionId then
        local session = sessionCache[sessionId]
        if not session.added then
            if (addSegment(parameterType, session, false)) then
                needUpdate = true
                session.added = true
                --showActiveRestrictions()
            else
                debugTexts[#debugTexts+1] = {left = "|cFFFF8888Segment Already Added:", right = sessionId, time = GetTime(), date = date("%H:%M:%S")}
            end
        else
            if C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone) then
                if Details:GetCombatWithSessionId(sessionId) then
                    addSegment(parameterType, session, true)
                end
            end
        end
    else
        local currentSessionId = getCurrentSessionId()
        local sessions = {}
        for thisSessionId, session in pairs(sessionCache) do
            local thisSession = C_DamageMeter.GetCombatSessionFromID(thisSessionId, Enum.DamageMeterType.DamageDone)
            if thisSession then
                local hasAtLeastOneSource = hasSources(thisSessionId)
                if hasAtLeastOneSource then
                    local hasSecret = isServerSideSessionOpen(thisSessionId)
                    if not hasSecret then
                        table.insert(sessions, {sessionId = thisSessionId, session = session, detailsId = getDetailsSegmentIdFromSession(thisSessionId)})
                    else
                        startWaitSecretDropTimer(thisSessionId)
                    end
                end
            end
        end

        table.sort(sessions, function(a, b)
            return a.sessionId < b.sessionId
        end)

        for i = 1, #sessions do
            local session = sessions[i].session
            local thisSessionId = sessions[i].sessionId
            if not session.added then
                if (addSegment(parameterType, session, false)) then
                    needUpdate = true
                    session.added = true
                    showActiveRestrictions()
                else
                    debugTexts[#debugTexts+1] = {left = "|cFFFF8888Failed to Add Session:", right = thisSessionId, time = GetTime(), date = date("%H:%M:%S")}
                end
            else
                if currentSessionId-2 <= thisSessionId then
                    if C_DamageMeter.GetCombatSessionFromID(thisSessionId, Enum.DamageMeterType.DamageDone) then
                        if Details:GetCombatWithSessionId(thisSessionId) then
                            addSegment(parameterType, session, true)
                        end
                    end
                end
            end
        end
    end

    if needUpdate then
        if not scheduledUpdateObject then
            scheduledUpdateObject = C_Timer.After(0, bParser.DoUpdateOnDetails)
        end
    end

    local hasSessionInCache = false
    for thisSessionId, session in pairs(sessionCache) do
        if not session.added then
            hasSessionInCache = true
            break
        else
            removeFromSessionCache(thisSessionId)
        end
    end

    if not hasSessionInCache then
        Details222.BParser.ResetServerDM()
    end
end

function bParser.ResetServerDM()
    if detailsFramework.IsAddonApocalypseWow() then
        pcall(function()
            if C_DamageMeter and C_DamageMeter.ResetAllCombatSessions then
                debugTexts[#debugTexts+1] = {left = "|cFFFFFF00Data Reset:", right = GetTime(), time = GetTime(), date = date("%H:%M:%S")}
                ResetAllCombatSessions()
            end
        end)
    end
end

--in regular dungeon, it does not show the boss segment or trash segment.
--segments in the list keepo using the arena icon.

--the number showing the combat time is also 00:00 the entire time.
--left the battlegournd, it is flags as incombat yet. no player name is shown and the dps is modifying so it is running the updater yet.
--it also gave the bar bug where it draws a line extra after the window height

--in raid, it is still using the arena icon
--but the combat time is working in the boss fight
--at the end of the boss, the window is showing nothing and the combat time is still running
--changing segments keep blinking a few bars, it look like it is updating the combat, but blizzard damage meter shows nothing in a new segment?

L.ParseSegments = parseSegments

---@class detailstooltip : button
---@field maxAmount number
---@field ScrollBox df_scrollbox
---@field SetMaxAmount fun(self:detailstooltip, maxAmount:number)


local getTooltipFrame = function() --~tooltip
    ---@type detailstooltip
    local tooltip = _G["DetailsDLC12TooltipFrame"]
    if tooltip then
        return tooltip
    end

    tooltip = CreateFrame("frame", "DetailsDLC12TooltipFrame", UIParent)
    tooltip:Hide()

    tooltip.Background = tooltip:CreateTexture("$parentBackground", "background", nil, -4)
    tooltip.Background:SetColorTexture(.8, .8, .8, 1)
    tooltip.Background:SetAllPoints()

    tooltip.Background2 = tooltip:CreateTexture("$parentBackground2", "background", nil, -5)
    tooltip.Background2:SetColorTexture(0, 0, 0, 0.7)
    tooltip.Background2:SetAllPoints()


    function tooltip:SetMaxAmount(maxAmount)
        self.maxAmount = maxAmount
    end

    tooltip:SetHeight(50)

    --refresh the scroll box lines
    ---@param self df_scrollbox
    ---@param data table an indexed table with subtables holding the data necessary to refresh each line
    ---@param offset number used to know which line to start showing
    ---@param totalLines number of lines shown in the scroll box
    local refresFunc = function(self, data, offset, totalLines)
        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index]
            if (thisData) then
                local line = self:GetLine(i)
                ---@cast line detailstooltipline
                --update the line with the data
                line.SpellName:SetText(thisData.name)
                line.SpellIcon:SetTexture(thisData.icon)
                line.StatusBar:SetMinMaxValues(0, tooltip.maxAmount)
                line.StatusBar:SetValue(thisData.amount)

                --clear font strings
                for j = 1, 6 do
                    local fontString = line.dataFontStrings[j]
                    fontString:SetText("")
                end

                for j = 1, #thisData.texts do
                    local fontString = line.dataFontStrings[j]
                    fontString:SetText(AbbreviateNumbers(thisData.texts[j]))
                end

                line:Show()
            end
        end
    end

    ---@class detailstooltipline : button
    ---@field StatusBar statusbar
    ---@field SpellIcon texture
    ---@field SpellName fontstring
    ---@field Background texture
    ---@field dataFontStrings fontstring[]

    ---this function creates a new line for the scroll box
    ---@param self df_scrollbox
    ---@param index number line index
    ---@return detailstooltipline
    local createLineFunc = function(self, index)
        --create a new line
        ---@type detailstooltipline
        local line = CreateFrame("button", "$parentLine" .. index, self)

        local yPosition = (tooltipLineHeight + tooltipPadding) * (index - 1) * -1
        yPosition = yPosition - 3

        line:SetPoint("topleft", self, "topleft", 2, yPosition)
        line:SetPoint("topright", self, "topright", -2, yPosition)
        line:SetHeight(tooltipLineHeight)

        local statusBar = CreateFrame("statusbar", "$parentStatusBar", line)
        statusBar:SetAllPoints()
        statusBar:SetStatusBarTexture([[Interface\AddOns\Details\images\bar_background_dark_withline]])

        local background = statusBar:CreateTexture("$parentBackground", "background")
        background:SetAllPoints()
        background:SetColorTexture(.5, .5, .5, 1)

        local spellIcon = statusBar:CreateTexture("$parentIcon", "overlay")
        spellIcon:SetPoint("left", statusBar, "left", 1, 0)
        spellIcon:SetSize(tooltipLineHeight, tooltipLineHeight)
        spellIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        --setup the line creating frames, texts and other widgets, they are refreshed in the refresFunc
        local spellName = statusBar:CreateFontString("$parentSpellName", "overlay", "GameFontNormal")
        spellName:SetPoint("left", spellIcon, "right", 2, 0)

        line.dataFontStrings = {}

        for i = 1, 6 do
            local dataFontString = statusBar:CreateFontString("$parentDataFontString" .. i, "overlay", "GameFontNormal")

            if i == 1 then
                dataFontString:SetPoint("right", statusBar, "right", -2, 0)
            else
                dataFontString:SetPoint("right", line.dataFontStrings[i - 1], "left", -tooltipFontStringPadding, 0)
            end

            line.dataFontStrings[i] = dataFontString
        end

        line.StatusBar = statusBar
        line.SpellIcon = spellIcon
        line.SpellName = spellName
        line.Background = background

        return line
    end

    local dataPlaceholder = {}

    local scrollBox = detailsFramework:CreateScrollBox(tooltip, "$parentScrollbox", refresFunc, dataPlaceholder, 1, 1, tooltipAmountOfLines, tooltipLineHeight)
    --used 1 for width and height because we will set the size using anchors
    scrollBox:SetPoint("topleft", tooltip, "topleft", 0, 0)
    scrollBox:SetPoint("bottomright", tooltip, "bottomright", 0, 0)
    --appearance
    detailsFramework:ReskinSlider(scrollBox)

    tooltip.ScrollBox = scrollBox

    --manually create the lines when the createLineFunc is not provided
    for i = 1, tooltipAmountOfLines do
        scrollBox:CreateLine(createLineFunc)
    end

    --call a refresh in the scrollBox
    scrollBox:Refresh()

    local defaultColor = {r=0.5, g=0.5, b=0.5, a=1}

    ---@param self df_scrollbox
    ---@param data addonapoc_tooltipdata
    function scrollBox:RefreshMe(data)
        --refresh the line appearance
        local classColor = RAID_CLASS_COLORS[data.class] or defaultColor
        local r, g, b, a = unpack(Details.tooltip.bar_color)
        local rBG, gBG, bBG, aBG = unpack(Details.tooltip.background)

        local allTooltipLines = self:GetLines()
        for i = 1, #allTooltipLines do
            local line = allTooltipLines[i]
            line.Background:SetColorTexture(0, 0, 0, 0.5) --class color

            --right texts
            for j = 1, #line.dataFontStrings do
                local fontString = line.dataFontStrings[j]
                fontString:SetTextColor(unpack(Details.tooltip.fontcolor_right)) --
                detailsFramework:SetFontSize(fontString, Details.tooltip.fontsize) --
                detailsFramework:SetFontFace(fontString, Details.tooltip.fontface) --
                detailsFramework:SetFontOutline(fontString, Details.tooltip.fontshadow  and "OUTLINE") --
            end

            local fontString = line.SpellName
            fontString:SetTextColor(unpack(Details.tooltip.fontcolor)) --
            detailsFramework:SetFontSize(fontString, Details.tooltip.fontsize) --
            detailsFramework:SetFontFace(fontString, Details.tooltip.fontface) --
            detailsFramework:SetFontOutline(fontString, Details.tooltip.fontshadow  and "OUTLINE")

            line.Background:SetVertexColor(classColor.r, classColor.g, classColor.b, aBG)
            line.StatusBar:GetStatusBarTexture():SetVertexColor(r, g, b, a)
        end

        tooltip.Background:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)

        self:SetData(data)
        self:Refresh()

        self.ScrollBar:Hide()
    end

    return tooltip
end

---@return detailstooltip
function Details:GetTooltip()
    return getTooltipFrame()
end


--~tooltip
---@param instanceLine detailsline
function bParser.ShowTooltip(instance, instanceLine)
    ---@type attributeid, attributeid
    local mainDisplay, subDisplay = instance:GetDisplay()

    --fragile: Handle with care!
    local sourceGUID = instanceLine.secret_SourceGUID
    local actorName = instanceLine.secret_SourceName

    ---@type damagemeter_type
    local damageMeterType = bParser.GetDamageMeterTypeFromDisplay(mainDisplay, subDisplay)
    --local sourceSpells = getSourceSpells(DAMAGE_METER_SESSIONPARAMETER_TYPE, Enum.DamageMeterSessionType.Current, damageMeterType, sourceGUID)

    local blzDamageContainer = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageDone)
    local firstCombatant = blzDamageContainer.combatSources[1]
    --local sourceSpells = C_DamageMeter.GetCombatSessionSourceFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageDone, firstCombatant.sourceGUID)
    local sourceSpells = C_DamageMeter.GetCombatSessionSourceFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageDone, UnitGUID("player"))

    local maxAmount = sourceSpells.maxAmount

    for i = 1, #sourceSpells.combatSpells do
        local spellDetails = sourceSpells.combatSpells[i]
        local spellID = spellDetails.spellID
        local spellAmount = spellDetails.totalAmount
        --local spellPercent = (spellAmount / maxAmount) * 100 --nop

        local spellInfo = C_Spell.GetSpellInfo(spellID)
        GameCooltip:AddLine(spellInfo.name, spellAmount)

        local iconSize = Details.DefaultTooltipIconSize
        local icon_border = Details.tooltip.icon_border_texcoord

        GameCooltip:SetOption("FixedWidth", 200)

        GameCooltip:AddIcon(spellInfo.iconID, nil, nil, iconSize, iconSize, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
        Details:AddTooltipBackgroundStatusbar_Secret(spellAmount, maxAmount)
    end
end

function bParser.HideTooltip_Hook(instanceLine, mouse)
    if not detailsFramework.IsAddonApocalypseWow() then
        return
    end

    local tooltip = Details:GetTooltip()
    tooltip:Hide()
end

--~tooltip
---@param instanceLine detailsline
function bParser.ShowTooltip_Hook(instanceLine, mouse)
    if not detailsFramework.IsAddonApocalypseWow() then
        return
    end

    --[=[
        local blizWindowSrcl = DamageMeterSessionWindow1.ScrollBox
        local window1Src = DamageMeterSessionWindow1.SourceWindow

        local children = {DamageMeterSessionWindow1.ScrollBox.ScrollTarget:GetChildren()}

        local lineIndex = instanceLine.lineIndex

        local blzLine = children[lineIndex]
        blzLine:Click()
        --DamageMeterSessionWindow1:ShowSourceWindow(instanceLine.sourceData)
    --]=]

    if not bParser.InSecretLockdown() then
        return
    end

    local tooltip = Details:GetTooltip()
    tooltip:ClearAllPoints()
    tooltip:SetPoint("bottomleft", instanceLine, "topleft", 0, 3)
    tooltip:SetPoint("bottomright", instanceLine, "topright", 0, 3)

    ---@type attributeid, attributeid
    --local mainDisplay, subDisplay = instance:GetDisplay()

    --fragile: Handle with care!
    --local sourceGUID = instanceLine.secret_SourceGUID
    --local actorName = instanceLine.secret_SourceName

    ---@type damagemeter_type
    --local damageMeterType = bParser.GetDamageMeterTypeFromDisplay(mainDisplay, subDisplay)
    --local sourceSpells = getSourceSpells(DAMAGE_METER_SESSIONPARAMETER_TYPE, Enum.DamageMeterSessionType.Current, damageMeterType, sourceGUID)

    --local blzDamageContainer = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageDone)
    --local firstCombatant = blzDamageContainer.combatSources[1]
    --local sourceSpells = C_DamageMeter.GetCombatSessionSourceFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageDone, UnitGUID("player"))

    local sourceSpells

    local sessionType = instanceLine.sessionType
    local sessionNumber = instanceLine.sessionNumber
    local sessionTypeParam = instanceLine.sessionTypeParam
    local damageMeterType = instanceLine.damageMeterType
    local guid = guidCache[instanceLine.blzSpecIcon]

    if sessionType == DAMAGE_METER_SESSIONPARAMETER_ID then
        --local sourceSpells = C_DamageMeter.GetCombatSessionSourceFromID(sessionNumber, Enum.DamageMeterType.DamageDone, UnitGUID("player")) --waiting blizzard fix this
        sourceSpells = C_DamageMeter.GetCombatSessionSourceFromID(sessionNumber, damageMeterType, guid or UnitGUID("player"))

    elseif (sessionType == DAMAGE_METER_SESSIONPARAMETER_TYPE) then
        --local sourceSpells = C_DamageMeter.GetCombatSessionSourceFromID(sessionTypeParam, Enum.DamageMeterType.DamageDone, actorGUID) --waiting blizzard fix this
        sourceSpells = C_DamageMeter.GetCombatSessionSourceFromType(sessionTypeParam, damageMeterType, guid or UnitGUID("player"))
    end

    ---@type addonapoc_tooltipdata[]
    local tooltipData = {}

    if not sourceSpells then
        ---@type addonapoc_tooltipdata
        local data = {
            name = "No Spells Found",
            icon = "",
            texts = {""},
            amount = 0,
        }

        tooltipData[#tooltipData + 1] = data
        return
    end

    local spellAmount = #sourceSpells.combatSpells

    local maxAmount = sourceSpells.maxAmount

    tooltip:SetMaxAmount(maxAmount)
    tooltip:SetHeight(spellAmount * (tooltipLineHeight+1) + 4)



    for i = 1, spellAmount do
        local spellDetails = sourceSpells.combatSpells[i]
        local spellID = spellDetails.spellID
        local spellAmount = spellDetails.totalAmount
        --local spellPercent = (spellAmount / maxAmount) * 100 --nop

        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if not spellInfo then
            ---@diagnostic disable-next-line: missing-fields
            spellInfo = {
                name = "Unknown Spell",
                iconID = 136243, --question mark
            }
        end

        ---@class addonapoc_tooltipdata
        ---@field name string
        ---@field icon number
        ---@field texts number[]
        ---@field amount number

        ---@type addonapoc_tooltipdata
        local data = {
            name = spellInfo.name,
            icon = spellInfo.iconID,
            texts = {spellAmount},
            amount = spellAmount,
        }

        tooltipData[#tooltipData + 1] = data

        --GameCooltip:AddLine(spellInfo.name, spellAmount)

        --local iconSize = Details.DefaultTooltipIconSize
        --local icon_border = Details.tooltip.icon_border_texcoord

        --GameCooltip:AddIcon(spellInfo.iconID, nil, nil, iconSize, iconSize, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
        --Details:AddTooltipBackgroundStatusbar_Secret(spellAmount, maxAmount)
    end

    tooltipData.class = instanceLine.sourceData.classFilename
    tooltipData.specIcon = instanceLine.sourceData.specIconID

    tooltip.ScrollBox:RefreshMe(tooltipData)
    tooltip:Show()
end

local combatAcknowledgeListener = Details:CreateEventListener()
combatAcknowledgeListener.InCombat = false
combatAcknowledgeListener.ParserFrame = CreateFrame("frame")
if detailsFramework.IsAddonApocalypseWow() then
    combatAcknowledgeListener.ParserFrame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
end
combatAcknowledgeListener.ParserFrame:SetScript("OnEvent", function(self, event, ...)
    --when this event happen, update details! windows (or not)
end)

---@class details
---@field GetFormattedTimeForTitleBar fun(self:instance):string return a formatted string containing the elapsed time of the combat shown in the instance
---@field InstanceCall fun(self:details, function:fun(instance:instance), ...:any?)
---@field GetAllLines fun(self:details):frame[]

---hide all lines in the instance and clearup the secret strings
local clearLineSecrets = function(instance)
    ---@type detailsline[]
    local allInstanceLines = instance.barras --instance:GetAllLines()

    --cleanup all bars
    for i = 1, #allInstanceLines do
        local instanceLine = allInstanceLines[i]
        instanceLine.secret_SourceGUID = nil
        instanceLine.secret_SourceName = nil
    end
end

local abbreviateOptionsDamage =
{
    {
        breakpoint = 1000000000,
        abbreviation = "THIRD_NUMBER_CAP_NO_SPACE",
        significandDivisor = 10000000,
        fractionDivisor = 100,
        --abbreviationIsGlobal = false
    },
    {
        breakpoint = 1000000,
        --abbreviation = "SECOND_NUMBER_CAP_NO_SPACE",
        abbreviation = "M",
        significandDivisor = 10000,
        fractionDivisor = 100,
        abbreviationIsGlobal = false
    },
    {
        breakpoint = 10000,
        --abbreviation = "FIRST_NUMBER_CAP_NO_SPACE",
        abbreviation = "K",
        significandDivisor = 1000,
        fractionDivisor = 1,
        abbreviationIsGlobal = false,
    },
    {
        breakpoint = 1000,
        --abbreviation = "FIRST_NUMBER_CAP_NO_SPACE",
        abbreviation = "K",
        significandDivisor = 100,
        fractionDivisor = 10,
        abbreviationIsGlobal = false,
    },
    {
        breakpoint = 1,
        abbreviation = "",
        significandDivisor = 1,
        fractionDivisor = 1,
        abbreviationIsGlobal = false
    },
}

local abbreviateOptionsDPS =
{
    {
        breakpoint = 1000000000,
        abbreviation = "THIRD_NUMBER_CAP_NO_SPACE",
        significandDivisor = 10000000,
        fractionDivisor = 100,
        abbreviationIsGlobal = false
    },
    {
        breakpoint = 1000000,
        --abbreviation = "SECOND_NUMBER_CAP_NO_SPACE",
        abbreviation = "M",
        significandDivisor = 10000,
        fractionDivisor = 100,
        abbreviationIsGlobal = false
    },
    {
        breakpoint = 1000,
        --abbreviation = "FIRST_NUMBER_CAP_NO_SPACE",
        abbreviation = "K",
        significandDivisor = 100,
        fractionDivisor = 10,
        abbreviationIsGlobal = false,
    },
    {
        breakpoint = 1,
        abbreviation = "",
        significandDivisor = 1,
        fractionDivisor = 1,
        abbreviationIsGlobal = false
    },
}

local abbreviateSettingsDamage
local abbreviateSettingsDPS

if CreateAbbreviateConfig then
    abbreviateSettingsDamage = CreateAbbreviateConfig(abbreviateOptionsDamage)
    abbreviateSettingsDamage = {config = abbreviateSettingsDamage}
    Details.abbreviateOptionsDamage = abbreviateSettingsDamage

    abbreviateSettingsDPS = CreateAbbreviateConfig(abbreviateOptionsDPS)
    abbreviateSettingsDPS = {config = abbreviateSettingsDPS}
    Details.abbreviateOptionsDPS = abbreviateSettingsDPS
end

local tt = GetTime()
local createFakeSources = function()
    local s = {
        maxAmount = 198700,
        combatSources = {
            [1] = {
                classFilename = "MAGE",
                name = "Aazz",
                isLocalPlayer = true,
                amountPerSecond = 1095.5953369141,
                specIconID = 135932,
                totalAmount = 98700,
                sourceGUID = "Player-969-00B07A55"
            }
        }
    }
    return s
end

---update the window in real time
---@param instance instance
local updateWindow = function(instance) --~update
    ---@type attributeid, attributeid
    local mainDisplay, subDisplay = instance:GetDisplay()

    --which data the line will show (total, dps, percent)
    local barsShowData = instance.row_info.textR_show_data
	local barsBrackets = instance:GetBarBracket()
	local barsSeparator = instance:GetBarSeparator()

    ---@type damagemeter_type
    local damageMeterType = bParser.GetDamageMeterTypeFromDisplay(mainDisplay, subDisplay)

    ---@type detailsline[]
    local allInstanceLines = instance.barras --instance:GetAllLines()
    local linesInUse = 0

    --cleanup all bars
    for i = 1, #allInstanceLines do
        local instanceLine = allInstanceLines[i]
        instanceLine:Hide()
        --set the text to empty string
        instanceLine.lineText11:SetText("")
        instanceLine.lineText12:SetText("")
        instanceLine.lineText13:SetText("")
        instanceLine.lineText14:SetText("")
    end

    if (damageMeterType and damageMeterType < 100) then
        ---@type segmentid
        local segmentId = instance:GetSegmentId()

        ---@type damagemeter_combat_session
        local session

        local sessionType, sessionNumber, sessionTypeParam
        --/dump C_DamageMeter.GetCombatSessionFromType(1, 0)

        if segmentId == -1 then
            session = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Overall, damageMeterType)
            sessionType = DAMAGE_METER_SESSIONPARAMETER_TYPE
            sessionTypeParam = Enum.DamageMeterSessionType.Overall

        elseif segmentId == 0 then
            session = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, damageMeterType)

            --if #session.combatSources == 0 then

            --else
                sessionType = DAMAGE_METER_SESSIONPARAMETER_TYPE
                sessionTypeParam = Enum.DamageMeterSessionType.Current
            --end

        else
            --stop the updater
            --StopUpdaterAndClearWindow()
            if (segmentId > 1) then
                --[[
                do return end
                local instanceSegmentId = instance:GetSegmentId()
                if instanceSegmentId ~= segmentId then
                    instance:SetSegment(segmentId)
                end
                ---]]
            end

            ---@type damagemeter_availablecombat_session[]
            local sessions = C_DamageMeter.GetAvailableCombatSessions()
            ---@type number
            local sessionIndex = #sessions - (segmentId - 1)
            ---@type damagemeter_availablecombat_session
            session = sessions[sessionIndex]
            sessionType = DAMAGE_METER_SESSIONPARAMETER_ID
            sessionNumber = sessionIndex
        end

        local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
        local textureFile = SharedMedia:Fetch("statusbar", instance.row_info.texture)
        local textureFile2 = SharedMedia:Fetch("statusbar", instance.row_info.texture_background)
        local overlayTexture = SharedMedia:Fetch("statusbar", instance.row_info.overlay_texture)
        local overlayColor = instance.row_info.overlay_color

        if (session) then
            ---@type damagemeter_combat_source[]
            local combatSources = session.combatSources
            if not combatSources then

                return
            end

            --combatSources = createFakeSources()
            --combatSources = combatSources.combatSources

            local amountOfSources = #combatSources
            local topValue = session.maxAmount
            local segmentName = session.name
            local sessionId = session.sessionID

            for i = 1, amountOfSources do
                ---@type detailsline
                local instanceLine = allInstanceLines[i]
                if (instanceLine) then
                    ---@type damagemeter_combat_source
                    local source = combatSources[i]
                    local updateStatusbarColor = true

                    instanceLine.lineIndex = i
                    instanceLine.sourceData = source
                    instanceLine.sessionType = sessionType
                    instanceLine.sessionNumber = sessionNumber
                    instanceLine.sessionTypeParam = sessionTypeParam
                    instanceLine.damageMeterType = damageMeterType

                    local actorName = source.name --secret
                    local actorGUID = source.sourceGUID --secret
                    local value = source.totalAmount --secret
                    local totalAmountPerSecond = source.amountPerSecond --secret
                    local classFilename = source.classFilename
                    local specIcon = source.specIconID
                    local isPlayer = source.isLocalPlayer

                    instanceLine.blzSpecIcon = source.specIconID
                    instanceLine.secret_SourceGUID = actorGUID
                    instanceLine.secret_SourceName = actorName

                    local _, instanceType = GetInstanceInfo()
                    if instanceType == "arena" then
                        local okey, errortext = pcall(function() --Details.PvPPlayers
                            if UnitName(actorName) == nil then
                                instanceLine.textura:SetVertexColor(detailsFramework:ParseColors(Details.class_colors.ARENA_YELLOW))
                                updateStatusbarColor = false
                            else
                                instanceLine.textura:SetVertexColor(detailsFramework:ParseColors(Details.class_colors.ARENA_GREEN))
                                actorName = UnitName(actorName)
                                updateStatusbarColor = false
                            end
                        end)
                    else
                        actorName = UnitName(actorName)
                    end --~refresh

                    instanceLine.lineText1:SetText(actorName) --left text
                    --instanceLine.lineText11:SetText(actorName) --left text

                    local perCent = nil
                    local ruleToUse = 2 --total dps
                    Details:SimpleFormat(instanceLine.lineText2, instanceLine.lineText3, instanceLine.lineText4, AbbreviateNumbers(value, abbreviateSettingsDamage), AbbreviateNumbers(totalAmountPerSecond, abbreviateSettingsDPS), perCent, ruleToUse)

                    instanceLine.statusbar:SetMinMaxValues(0, topValue, Enum.StatusBarInterpolation.ExponentialEaseOut)
                    instanceLine.statusbar:SetValue(value, Enum.StatusBarInterpolation.ExponentialEaseOut)
                    --apply curve

                    if specIcon then
                        instanceLine.icone_classe:SetTexture(specIcon)
                        instanceLine.icone_classe:SetTexCoord(0.1, .9, .1, .9)
                    else
                        local texture, l, r, t, b = Details:GetClassIcon(classFilename or "UNGROUPPLAYER")
                        instanceLine.icone_classe:SetTexture(texture)
                        instanceLine.icone_classe:SetTexCoord(l, r, t, b)
                    end

                    --instanceLine.textura:SetTexture(textureFile)
                    --instanceLine.background:SetTexture(textureFile2)
                    --instanceLine.overlayTexture:SetTexture(overlayTexture)
                    --instanceLine.overlayTexture:SetVertexColor(unpack(overlayColor))

                    if updateStatusbarColor then
                        local classColor = Details.class_colors[classFilename or "UNGROUPPLAYER"]
                        if (classColor) then
                            instanceLine.textura:SetVertexColor(classColor[1], classColor[2], classColor[3])
                        else
                            instanceLine.textura:SetVertexColor(detailsFramework:ParseColors("brown"))
                        end
                    end

                    linesInUse = linesInUse + 1
                    instanceLine:SetAlpha(1)
                    instanceLine:Show()
                end
            end
        end
    else
        if (damageMeterType and damageMeterType == 100) then
            instance:SetDisplay(DETAILS_ATTRIBUTE_DAMAGE, DETAILS_SUBATTRIBUTE_DAMAGEDONE)
        end
    end
end

local updateOpenWindows = function()
    if not Details:ArePlayersInCombat() then
        StopUpdaterAndClearWindow()
    end
    Details:InstanceCall(updateWindow)--update all opened details! windows with the new data from blizzard damage meter
end

local showFontStringsForPrivateText = function(instance)
    local allInstanceLines = instance.barras

    for i = 1, #allInstanceLines do
        ---@type detailsline
        local line = allInstanceLines[i]
        --clear the regular font string
        --line.lineText1:SetText("")
        --line.lineText2:SetText("")
        --line.lineText3:SetText("")
        --line.lineText4:SetText("")

        --show the secret font strings
        --line.lineText11:SetShown(true)
        --line.lineText12:SetShown(true)
        --line.lineText13:SetShown(true)
        --line.lineText14:SetShown(true)

        line.inCombat = bRegenIsDisabled
    end
end

---@param self instance
function Details:GetFormattedTimeForTitleBar()
    local combat = self:GetCombat()
    local elapsedTime = 0

    if not detailsFramework.IsAddonApocalypseWow() then
        elapsedTime = combat:GetCombatTime()
    else
        local currentSessionId = getCurrentSessionId()
        local segmentId = self:GetSegmentId()

        if segmentId == DETAILS_SEGMENTID_OVERALL then
            if bRegenIsDisabled then
                local thisSessionTime = getSessionCombatTime(currentSessionId)
                elapsedTime = combat:GetCombatTime() + thisSessionTime
            else
                elapsedTime = combat:GetCombatTime()
            end

        elseif segmentId == DETAILS_SEGMENTID_CURRENT then
            if bRegenIsDisabled then
                elapsedTime = getSessionCombatTime(currentSessionId)
            else
                elapsedTime = combat:GetCombatTime()
            end
        else
            elapsedTime = combat:GetCombatTime()
        end
    end

    if elapsedTime > 0 then
        local minutes = math.floor(elapsedTime / 60)
        local seconds = math.floor(elapsedTime % 60)
        local timeString = string.format("%02d:%02d", minutes, seconds)
        return timeString
    end

    return "00:00"
end

local timerUpdateInterval = 1 --time in seconds
local timerUpdateObject = nil
local updateTime = function(timerObject)
    local instance = timerObject.instance
    if instance.attribute_text.show_timer then
        local timeString = instance:GetFormattedTimeForTitleBar()
        if instance:GetSegmentId() ~= DETAILS_SEGMENTID_OVERALL then
            local attributeText = instance:GetInstanceAttributeText() --this return 'damage done'
            timeString = timeString .. " " .. attributeText
            instance:SetTitleBarText(timeString)
        end
    end
end

--this function update the time in settings shown in the window
local startElapsedTimeUpdate = function()
    local lowerInstanceId = Details:GetLowerInstanceNumber()
    if lowerInstanceId then
        local instance = Details:GetInstance(lowerInstanceId)
        if instance then
            if (timerUpdateObject) then
                timerUpdateObject:Cancel()
                timerUpdateObject = nil
            end
            timerUpdateObject = C_Timer.NewTicker(timerUpdateInterval, updateTime)
            timerUpdateObject.instance = instance
        end
    end
end


local startUpdater = function()
    --bParser.MakeAsOverlay()
    --if (bRegenIsDisabled) then
        Details:InstanceCall(showFontStringsForPrivateText)

        startElapsedTimeUpdate()

        --start a ticker that will update opened details! windows every X seconds
        if (not updaterTicker) then
            updaterTicker = C_Timer.NewTicker(Details.update_speed, function()
                updateOpenWindows()
            end)
        end
    --end
end

StopUpdaterAndClearWindow = function()
    if (updaterTicker) then
        updaterTicker:Cancel()
        updaterTicker = nil
        Details:InstanceCall(clearLineSecrets)
    end

    if (timerUpdateObject) then
        timerUpdateObject:Cancel()
        timerUpdateObject = nil
    end
end

local isUpdaterRunning = function()
    return updaterTicker ~= nil
end

local sessionClosureTimer

local startSessionClosureTimer = function()
    if sessionClosureTimer then
        return
    end

    sessionClosureTimer = C_Timer.NewTicker(1, function()
        local isOpen = isServerSideSessionOpen()
        if not isOpen then
            if updaterTicker then
                updaterTicker:Cancel()
                updaterTicker = nil
                doUpdate()
            end
            sessionClosureTimer:Cancel()
            sessionClosureTimer = nil
        end
    end)
end

local checkPlayerInCombatTicker

local stopCheckingNoPlayerInCombat = function()
    if checkPlayerInCombatTicker then
        checkPlayerInCombatTicker:Cancel()
        checkPlayerInCombatTicker = nil
    end
end

local checkNoPlayerInCombat = function()
    if not Details:ArePlayersInCombat() then
        stopCheckingNoPlayerInCombat()
        if not isInEncounter() then
            --well, the combat might have gone
            bParser.WaitServerDropCombat(parseSegments)
        end
    end
end

local startCheckingNoPlayerInCombat = function()
    if checkPlayerInCombatTicker then
        return
    end
    checkPlayerInCombatTicker = C_Timer.NewTicker(0.5, checkNoPlayerInCombat)
end

local combatEventFrame = CreateFrame("frame")
local evTime

--event registration
if detailsFramework.IsAddonApocalypseWow() then
    combatEventFrame:RegisterEvent("PLAYER_IN_COMBAT_CHANGED")
    combatEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    combatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    combatEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    combatEventFrame:RegisterEvent("PLAYER_LOGIN")
    combatEventFrame:RegisterEvent("ENCOUNTER_START")
    combatEventFrame:RegisterEvent("ENCOUNTER_END")
    combatEventFrame:RegisterEvent("DAMAGE_METER_RESET")
    combatEventFrame:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
    combatEventFrame:RegisterEvent("PVP_MATCH_COMPLETE")
    combatEventFrame:RegisterEvent("PVP_MATCH_ACTIVE")
    combatEventFrame:RegisterEvent("PLAYER_DEAD")
    combatEventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    combatEventFrame:RegisterEvent("CHALLENGE_MODE_START")
    combatEventFrame:RegisterEvent("PLAYER_ALIVE")
end

local parserFrame = CreateFrame("frame")
if detailsFramework.IsAddonApocalypseWow() then
    parserFrame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
    --parserFrame:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
end

local sessionIdFromDMCSU = 0
local sessionIdFromDMCSU_Time = 0

parserFrame:SetScript("OnEvent", function(self, event, ...)
    if (event == "DAMAGE_METER_COMBAT_SESSION_UPDATED") then
        local damageMeterType, sessionId = ...
        if sessionId ~= 0 and damageMeterType == Enum.DamageMeterType.DamageDone then
            sessionIdFromDMCSU = sessionId
            sessionIdFromDMCSU_Time = GetTime()
            if not latestSessionOpened or sessionId > latestSessionOpened then
                local existingSession = getSession(sessionId)
                if not existingSession then
                    local sessionCreated = createAndAddSession(sessionId)
                    if sessionCreated then
                        debugTexts[#debugTexts+1] = {left = "SESSION_UPDATED (by Combat Update)", right = sessionId, time = GetTime(), date = date("%H:%M:%S")}
                        latestSessionOpened = sessionId
                    end

                    local previousSessionId = sessionId - 1
                    local previousSession = getSession(previousSessionId)
                    if previousSession then
                        if not previousSession.endTime then
                            previousSession.endTime = GetTime()
                            previousSession.endUnixTime = time()
                            previousSession.endDate = date("%H:%M:%S")
                        end
                    else
                        --no previous session found
                    end --~update

                    if not isUpdaterRunning() then
                        startUpdater()
                        if Details:ArePlayersInCombat() then
                        end
                    end
                end

            elseif (latestSessionOpened and sessionId <= latestSessionOpened) then
                --if is the same session, verify if session was already added
                local thisSession = getSession(sessionId)
                local nextSession = getSession(sessionId+1)
                if (thisSession.added and not nextSession) then
                    thisSession.added = false
                    thisSession.endTime = nil
                    startUpdater()

                    latestSessionOpened = sessionId

                    local combatObject, combatIndex = Details:GetCombatWithSessionId(thisSession.detailsId)
                    if combatObject then
                        Details:RemoveSegment(combatIndex)
                    end
                end
            end
        end

    elseif (event == "DAMAGE_METER_CURRENT_SESSION_UPDATED") then
        local sessionId = getCurrentSessionId()
        local sessionCreated = createAndAddSession(sessionId)

        latestSessionOpened = sessionId
        if sessionCreated then
            debugTexts[#debugTexts + 1] = { left = "SESSION_UPDATED (By New Session)", right = sessionId, time = GetTime() }
        end

        if onPvpMatch then
            if sessionIdAtArenaStart == 0 then
                sessionIdAtArenaStart = sessionId
            end
        end

        if not isUpdaterRunning() then
            startUpdater()
            startSessionClosureTimer()
            if Details:ArePlayersInCombat() then
            end
        end

        local previousSessionId = sessionId - 1
        local previousSession = getSession(previousSessionId)
        if previousSession then
            if not previousSession.endTime then
                previousSession.endTime = GetTime()
                previousSession.endUnixTime = time()
                previousSession.endDate = date("%H:%M:%S")
            end
        else
            --no previous session found
        end
    end
end)

local onEnterPvpArea = function()
    --ResetAllCombatSessions()
    --wipeStoredSessionIds()
    --wipe(sessionsWithSecrets)
    cancelWaitSecretDropTimer()
end

--called on DAMAGE_METER_RESET and DETAILS_DATA_RESET
local onDataReset = function()
    wipeStoredSessionIds()
    if Details:ArePlayersInCombat() then
        local sessionId = getCurrentSessionId()
        if sessionId > 0 then
            createAndAddSession(sessionId)
        end
    end
end

local updateAllRestrictionFlags = function()
    C_Timer.After(1, function()
    restrictionFlag = 0
    for restrictionType, bitToChange in pairs(restrictionFlags) do
            local state = C_RestrictedActions.GetAddOnRestrictionState(restrictionType)
            if state > 0 then
                restrictionFlag = restrictionFlag + bitToChange
            end
        end
    end)
end

combatEventFrame:SetScript("OnEvent", function(mySelf, ev, ...)
    if (ev == "PLAYER_LOGIN") then

    elseif (ev == "PLAYER_ENTERING_WORLD") then
        --print("(debug-event) load screen end")
        cantStartUpdater = true
        --when the player enters the world, check if in combat
        bRegenIsDisabled = UnitAffectingCombat("player")
        C_Timer.After(1, function()
            if not bRegenIsDisabled then
            end
        end)

        local hasSecret = isServerSideSessionOpen()
        if not hasSecret then
            doUpdate()
        end

        if InCombatLockdown() then
            return
        end

        Details:InstanceCall(function(instance)
            local baseFrame = instance.baseframe
            if baseFrame and baseFrame:IsShown() then
                baseFrame.button_stretch:Click()
                C_Timer.After(5, function()
                    --note: revisit this code, why not just calling the functions the stretch button calls.
                    baseFrame.button_stretch:GetScript("OnMouseDown")(baseFrame.button_stretch, "LeftButton")
                    baseFrame.button_stretch:GetScript("OnMouseUp")(baseFrame.button_stretch, "LeftButton")
                end)
            end
        end)

    elseif (ev == "ADDON_RESTRICTION_STATE_CHANGED") then
        local restrictionType, state = ...

        local bitToChange = restrictionFlags[restrictionType]
        if bitToChange then
            if state > 0 then
                restrictionFlag = bit.bor(restrictionFlag, bitToChange)
            else
                restrictionFlag = bit.band(restrictionFlag, bit.bnot(bitToChange))
            end
        end

        if bit.band(restrictionFlag, Enum.AddOnRestrictionType.Combat) == 0 then
            --bParser.WaitServerDropCombat(parseSegments)
        end

        --start-debug
            --local hassecrets = isServerSideSessionOpen()
            --print("(debug-note) |cFFFFBBBBRestriction changed:", hassecrets)
            --showActiveRestrictions() --debug function
        --end-debug

    elseif (ev == "CHALLENGE_MODE_START") then
        --print("(debug-event) CHALLENGE_MODE_START", GetTime())
        mythicPlusInfo.startTime = GetTime()
        mythicPlusInfo.startUnixTime = time()
        mythicPlusInfo.startDate = date("%H:%M:%S")
        mythicPlusInfo.sessionId = getCurrentSessionId()
        mythicPlusInfo.level = C_ChallengeMode.GetActiveKeystoneInfo()
        mythicPlusInfo.mapId = C_ChallengeMode.GetActiveChallengeMapID()
        mythicPlusInfo.isActive = true

    elseif (ev == "CHALLENGE_MODE_COMPLETED") then
        --print("(debug-event) CHALLENGE_MODE_COMPLETED", GetTime())
        mythicPlusInfo.endTime = GetTime()
        mythicPlusInfo.endUnixTime = time()
        mythicPlusInfo.endDate = date("%H:%M:%S")
        mythicPlusInfo.isActive = false
        cantStartUpdater = false

    elseif (ev == "PLAYER_DEAD") then
        local hassecrets = isServerSideSessionOpen()
        --print("(debug-event) |cFFFFBBBBPlayer dead:", hassecrets)

    elseif (ev == "DAMAGE_METER_RESET") then
        wipe(sessionsWithSecrets)
        cancelWaitSecretDropTimer()

    elseif (ev == "PLAYER_IN_COMBAT_CHANGED") then --entered in combat
        local inCombat = ...
        if inCombat then
            bPlayerInCombat = true
            local now = GetTime()

            if (now ~= evTime) then
                if debug then
                end
            end
            evTime = GetTime()
        else
            evTime = GetTime()
            bPlayerInCombat = false
        end

        --start-debug
            --debugTexts[#debugTexts+1] = {left = "PLAYER_IN_COMBAT_CHANGED", right = inCombat and "true" or "false", time = GetTime(), date = date("%H:%M:%S")}
            --local hassecrets = isServerSideSessionOpen()
            --print("(debug-event) |cFFFFBBBBPLAYER_IN_COMBAT_CHANGED:", hassecrets)
        --end-debug

    elseif (ev == "ZONE_CHANGED_NEW_AREA") then
        --print("(debug-event) ZONE_CHANGED_NEW_AREA", GetTime())

        local _, newInstanceType = GetInstanceInfo()

        if currentZoneType ~= "arena" and newInstanceType == "arena" then --joined arena
            arenaSessionIdStart = getCurrentSessionId()
            onEnterPvpArea()

        elseif currentZoneType == "arena" and newInstanceType ~= "arena" then --left arena
            C_Timer.After(2, function()
                onPvpMatch = false
            end)

        elseif currentZoneType ~= "pvp" and newInstanceType == "pvp" then --joined battleground
            onEnterPvpArea()
        end

        latestEncounterSessionId = 0

        currentZoneType = newInstanceType

    elseif (ev == "PVP_MATCH_ACTIVE") then
        --print("(debug-event) PVP_MATCH_ACTIVE", GetTime())

        onPvpMatch = true
        debugTexts[#debugTexts+1] = {left = "PVP_MATCH_ACTIVE", right = "true", time = GetTime(), date = date("%H:%M:%S")}

    elseif (ev == "PVP_MATCH_COMPLETE") then
        --print("(debug-event) PVP_MATCH_COMPLETE", GetTime())
        cantStartUpdater = false
        local _, instanceType = GetInstanceInfo()
        if instanceType == "arena" then
            C_Timer.After(1, function()
                combatEventFrame:GetScript("OnEvent")(combatEventFrame, "PLAYER_REGEN_ENABLED")
            end)
        end

        debugTexts[#debugTexts+1] = {left = "PVP_MATCH_COMPLETE", right = "true", time = GetTime(), date = date("%H:%M:%S")}

    elseif (ev == "PLAYER_ALIVE") then
        --print("(debug-event) PLAYER_ALIVE", GetTime())
        stopCheckingNoPlayerInCombat()

    elseif (ev == "PLAYER_REGEN_ENABLED") then --left the combat ~regen
        --print("(debug-event) PLAYER_REGEN_ENABLED", GetTime())

        debugTexts[#debugTexts+1] = {left = "PLAYER_REGEN_ENABLED", right = "true", time = GetTime(), date = date("%H:%M:%S")}

        local _, instanceType = GetInstanceInfo()

        if isInEncounter() then
            return
        end

        if instanceType == "arena" then
            if not C_PvP.IsMatchComplete() then
                return
            end
        end

        if instanceType == "pvp" then
            if Details:ArePlayersInCombat() then
                return
            end
        end

        if instanceType == "raid" or instanceType == "party" then
            local isDeadOrGhost = UnitIsDeadOrGhost("player")
            if isDeadOrGhost then
                --note: encounter already hasbeen check
                if Details:ArePlayersInCombat() then
                    startCheckingNoPlayerInCombat()
                    return
                end
            end
        end

        local hasSecret = isServerSideSessionOpen()
        if hasSecret then
            bParser.WaitServerDropCombat(parseSegments)
            return
        end

        local sessionId = getCurrentSessionId()
        local session = getSession(sessionId)

        if session then
            session.endTime = GetTime()
            session.endUnixTime = time()
            session.endDate = date("%H:%M:%S")
        else
            --player left combat but no session found
            local combatWithSessionId = Details:GetCombatWithSessionId(sessionId)
            if combatWithSessionId then

            else

            end
        end

        bRegenIsDisabled = false

        if isServerSideSessionOpen() then
            bParser.WaitServerDropCombat(parseSegments)
        else
            parseSegments()
        end

        local now = GetTime()
        if (now ~= evTime) then
            if debug then
            end
        end

    elseif (ev == "PLAYER_REGEN_DISABLED") then --entered in combat
        --print("(debug-event) PLAYER_REGEN_DISABLED", GetTime())

        debugTexts[#debugTexts+1] = {left = "PLAYER_REGEN_DISABLED", right = "true", time = GetTime(), date = date("%H:%M:%S")}

        bRegenIsDisabled = true
        combatStartTime = GetTime()
        evTime = GetTime()

        if not isUpdaterRunning() then
            startUpdater()
        end

        targetGUID = nil
        local currentPlayerTargetGUID = UnitGUID("target")
        if currentPlayerTargetGUID then
            targetGUID = currentPlayerTargetGUID
        end
        --debugTime = GetTime()
        if debug then
            if (bRegenIsDisabled) then
            end
        end

    elseif (ev == "ENCOUNTER_START") then
        --print("(debug-event) ENCOUNTER_START", GetTime())
        local encounterId, encounterName, difficultyId, raidSize = select(1, ...)
        local name, instanceType, _, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceId, instanceGroupSize, LfgDungeonID = GetInstanceInfo()

        local thisEncounterData = {
            encounterId = encounterId,
            encounterName = encounterName,
            difficultyId = difficultyId,
            startTime = GetTime(),
            unixtimeStart = time(),
            zoneName = name,
            zoneType = instanceType,
            zoneMapId = instanceId,
            difficultyName = difficultyName,
            instanceType = instanceType,
        }

        C_Timer.After(1, function()
            if InCombatLockdown() then
                local sessionId = getCurrentSessionId()
                local session = getSession(sessionId)

                if session then
                    thisEncounterData.sessionId = sessionId
                    latestEncounterSessionId = sessionId
                    session.encounterData = thisEncounterData
                    session.encounterId = encounterId
                    session.encounterName = encounterName
                else
                    print("|cFFFF2222Error: Encounter started but no session found!", sessionId)
                end
            end
        end)

        if debug then

        end

    elseif (ev == "ENCOUNTER_END") then
        --print("(debug-event) ENCOUNTER_END", GetTime())
        local encounterId, encounterName, difficultyId, raidSize, endStatus = select(1, ...)

        local isDeadOrGhost = UnitIsDeadOrGhost("player")
        if isDeadOrGhost then
            bParser.WaitServerDropCombat(parseSegments)
        end

        local session = getSession(latestEncounterSessionId)
        latestEncounterSessionId = 0

        if session and session.encounterData then
            session.encounterData.endTime = GetTime()
            session.encounterData.endStatus = endStatus

            if endStatus == 1 then
                session.encounterData.kill = true
            else
                session.encounterData.kill = false
            end
        else
            if session and not session.encounterData then
                print("|cFFFF1111ENCOUNTER_END without session.encounterData.")
            end
        end
    end
end)

local detailsListener = Details:CreateEventListener()

local onEvent = function(event, instance, ...)
    if event == "DETAILS_DATA_RESET" then
        if detailsFramework.IsAddonApocalypseWow() then
            onDataReset()
        end
    end
end

detailsListener:RegisterEvent("DETAILS_DATA_RESET", onEvent)

function bParser.SetSessionCache(t)
    if not detailsFramework.IsAddonApocalypseWow() then
        return
    end

    sessionCache = t

    local availableCombatSessions = C_DamageMeter.GetAvailableCombatSessions()

    local latestSession = availableCombatSessions[#availableCombatSessions]
    if latestSession then
        local latestSessionId = latestSession.sessionID
        for sessionId in pairs(sessionCache) do
            if sessionId > latestSessionId then
                sessionCache[sessionId] = nil
            end
        end
    else
        wipeStoredSessionIds()
    end
end
