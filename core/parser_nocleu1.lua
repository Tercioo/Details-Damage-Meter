
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

local printDebug = function(...)
    if debugMode then
        print("|cFFFFFF22Details!Debug:", ...)
    end
end

local combatStartTime = 0 --GetTime()
local combatEndTime = 0 --GetTime()

--store sessionIds already added to Details!
local storedSessionIds = {}
--store information about a stored session
---@type table<number, sessioncache>
local sessionCache

local spellContainerClass = Details.container_habilidades
local containerUtilityType = Details.container_type.CONTAINER_MISC_CLASS

local bRegenIsDisabled = false --based on the event REGEN_DISABLED/REGEN_ENABLED
local bPlayerInCombat = false --based on the event PLAYER_IN_COMBAT_CHANGED

local targetGUID

local restrictionFlag = 0x0

local onPvpMatch = false
local sessionIdAtArenaStart = 0

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

local print = function(...)
    if debug then
        Details:Msg(...)
    end
end

local print = _G.print

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

function bParser.InSecretLockdown()
    return bRegenIsDisabled
end

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

local getSessionStartAndEndTime = function(sessionId)
    local info = sessionCache[sessionId]
    if info then
        return info.startTime, info.endTime
    end
    return 0, 0
end

local getCurrentSessionId = function()
    ---@type damagemeter_availablecombat_session[]
    local sessions = C_DamageMeter.GetAvailableCombatSessions()
    if #sessions > 0 then
        return sessions[#sessions].sessionID
    end
    return 0
end

local getSessionDetailsId = function(sessionId)
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
            detailsId = getSessionDetailsId(sessionId),
        }
        sessionCache[sessionId] = newSession
    else
        local timeNow = time()
        if session.startUnixTime+60 < timeNow then
            session.startTime = GetTime()
            session.startUnixTime = timeNow
            session.startDate = date("%H:%M:%S")
            session.added = false
            session.detailsId = getSessionDetailsId(sessionId)
        end
    end
end

local getSessions = function()
    return sessionCache
end

---@class details222
---@field DLC12_Combat_Data table



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
    Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse)
    Details:RefreshMainWindow(-1, true)
    Details:InstanceCall(doTrick)
end

local scheduledUpdateObject
function bParser.DoUpdateOnDetails()
    scheduledUpdateObject = nil
    doUpdate()
    C_Timer.After(Details.update_speed+0.03, doUpdate)
end

---@param sessionId number
---@return boolean hasSources
local hasSources = function(sessionId)
    ---@type damagemeter_combat_session
    local blzDamageContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone)
    local damageActorList = blzDamageContainer.combatSources
    return #damageActorList > 0
end

---@return boolean
local doYouHaveASecret = function()
    local sessionId = getCurrentSessionId()
    ---@type damagemeter_combat_session
    local blzDamageContainer = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone)
    local damageActorList = blzDamageContainer.combatSources

    if #damageActorList > 0 then
        for i = 1, #damageActorList do
            ---@type damagemeter_combat_source
            local source = damageActorList[i]
            local sourceName = source.name
            local sourceGUID = source.sourceGUID
            local amountDone = source.totalAmount
            local classFile = source.classFilename

            if issecretvalue(sourceName) or issecretvalue(sourceGUID) or issecretvalue(amountDone) or issecretvalue(classFile) then
                return true
            end
        end
    end

    return false
end

local waitSecretDropTimer
local startWaitSecretDropTimer = function()
    if waitSecretDropTimer then
        waitSecretDropTimer:Cancel()
        waitSecretDropTimer = nil
    end

    if not waitSecretDropTimer then
        waitSecretDropTimer = C_Timer.NewTicker(0.3, function(timerObject)
            if InCombatLockdown() then
                return
            end

            local stateCombat = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Combat)
            if stateCombat > 0 then
                return
            end

            local hasSecret = doYouHaveASecret()
            local isFreeToGo = not hasSecret

            if not isFreeToGo then
                return
            end

            --local stateChallengeMode = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.ChallengeMode)
            --!need to check for m+ plus restrictions

            local _, instanceType = GetInstanceInfo()
            if (instanceType == "arena") then
                local pvpMode = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Map)
                if pvpMode > 0 then
                    printDebug("arena is restricted by map.")
                    --isFreeToGo = false --!change to true in releases
                end
            end

            if isFreeToGo then
                timerObject:Cancel()
                waitSecretDropTimer = nil
                L.ParseSegments()
            end
        end)
    end
end

local cancelWaitSecretDropTimer = function()
    if waitSecretDropTimer then
        waitSecretDropTimer:Cancel()
        waitSecretDropTimer = nil
    end
end

---@param parameterType any
---@param session sessioncache
---@param bIsUpdate boolean|nil
local addSegment = function(parameterType, session, bIsUpdate)
    local sessionId = session.sessionId
    if not sessionId then
        dumpt(session)
    end

    --get all sessions
    ---@type damagemeter_availablecombat_session[]
    local sessions = C_DamageMeter.GetAvailableCombatSessions()
    if #sessions > 0 then
        for i = 1, #sessions do
            local thisSession = sessions[i]
            local thisSessionId = thisSession.sessionID
            if thisSessionId == sessionId then
                printDebug("adding segment name:", thisSession.name, GetTime(), thisSession.durationSeconds)
            end
        end
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
        currentCombat = Details:GetCombatWithSessionId(sessionId)
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

    local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
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

            --PAREI AQUI, SOURCE.NAME IS SECRET, MAS NAO PEGOU O SECRET ALI EM CIMA QUANDO CHECOU O FIRST PLAYER?
            --adicionei um iterator pra ver se todos os players estao sem segredos

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
        currentCombat.combatSessionId = sessionId
        storeSessionId(sessionId)
    end

    return true
end

local parseSegments = function()
    if debug then

    end

    local hasSecret = doYouHaveASecret()
    if hasSecret then
        --debug restriction if there is secret values are found
        --local stateCombat = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Combat)
        --local stateEncounter = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Encounter)
        --local stateChallengeMode = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.ChallengeMode)
        --local pvp = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.PvPMatch)
        --local map = C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Map)
        --Details:Msg("(1) parseSegments => secret found:", stateCombat, stateEncounter, stateChallengeMode, pvp, map)

        startWaitSecretDropTimer()
        return
    end

    cancelWaitSecretDropTimer()

    local parameterType = DAMAGE_METER_SESSIONPARAMETER_ID
    local currentSessionId = getCurrentSessionId()
    local needUpdate = false

    local sessions = {}
    for sessionId, session in pairs(sessionCache) do
        local thisSession = C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone)
        if thisSession then
            local hasAtLeastOneSource = hasSources(sessionId)
            if hasAtLeastOneSource then
                table.insert(sessions, {sessionId = sessionId, session = session, detailsId = getSessionDetailsId(sessionId)})
            end
        end
    end

    table.sort(sessions, function(a, b)
        return a.sessionId < b.sessionId
    end)

    for i = 1, #sessions do
        local session = sessions[i].session
        local sessionId = sessions[i].sessionId
        if not session.added then
            if (addSegment(parameterType, session, false)) then
                --print("(debug) Segment added:", sessionId, sessions[i].detailsId)
                needUpdate = true
                session.added = true
            end
        else
            if currentSessionId-2 <= sessionId then
                if C_DamageMeter.GetCombatSessionFromID(sessionId, Enum.DamageMeterType.DamageDone) then
                    if Details:GetCombatWithSessionId(sessionId) then
                        addSegment(parameterType, session, true)
                        --print("(debug) Segment updated:", sessionId, sessions[i].detailsId)
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
end

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

    if sessionType == DAMAGE_METER_SESSIONPARAMETER_ID then
        --local sourceSpells = C_DamageMeter.GetCombatSessionSourceFromID(sessionNumber, Enum.DamageMeterType.DamageDone, UnitGUID("player")) --waiting blizzard fix this
        sourceSpells = C_DamageMeter.GetCombatSessionSourceFromID(sessionNumber, damageMeterType, UnitGUID("player"))

    elseif (sessionType == DAMAGE_METER_SESSIONPARAMETER_TYPE) then
        --local sourceSpells = C_DamageMeter.GetCombatSessionSourceFromID(sessionTypeParam, Enum.DamageMeterType.DamageDone, actorGUID) --waiting blizzard fix this
        sourceSpells = C_DamageMeter.GetCombatSessionSourceFromType(sessionTypeParam, damageMeterType, UnitGUID("player"))
    end

    if not sourceSpells then

        return
    end

    local spellAmount = #sourceSpells.combatSpells

    local maxAmount = sourceSpells.maxAmount

    tooltip:SetMaxAmount(maxAmount)
    tooltip:SetHeight(spellAmount * (tooltipLineHeight+1) + 4)

    ---@type addonapoc_tooltipdata[]
    local tooltipData = {}

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
            sessionType = DAMAGE_METER_SESSIONPARAMETER_TYPE
            sessionTypeParam = Enum.DamageMeterSessionType.Current

        else
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

                    instanceLine.secret_SourceGUID = actorGUID
                    instanceLine.secret_SourceName = actorName

                    local _, instanceType = GetInstanceInfo()
                    if instanceType == "arena" then
                        local okey, errortext = pcall(function()
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

local updaterTicker = nil
local startUpdater = function()
    --bParser.MakeAsOverlay()
    if (bRegenIsDisabled) then
        Details:InstanceCall(showFontStringsForPrivateText)

        startElapsedTimeUpdate()

        --start a ticker that will update opened details! windows every X seconds
        if (not updaterTicker) then
            updaterTicker = C_Timer.NewTicker(Details.update_speed, function()
                updateOpenWindows()
            end)
        end
    end
end

local stopUpdaterAndClearWindow = function()
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

local combatEventFrame = CreateFrame("frame")
local evTime

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
end

local parserFrame = CreateFrame("frame")
if detailsFramework.IsAddonApocalypseWow() then
    parserFrame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
    parserFrame:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
end

parserFrame:SetScript("OnEvent", function(self, event, ...)
    if (event == "DAMAGE_METER_COMBAT_SESSION_UPDATED") then
        local type, sessionId = ...
        if sessionId ~= 0 then
            local existingSession = getSession(sessionId)
            if not existingSession then
                --print("change session detected:", GetTime(), getSessionDetailsId(sessionId))
                createAndAddSession(sessionId)

                if not isUpdaterRunning() then
                    if Details:ArePlayersInCombat() then
                        startUpdater()
                    end
                end
            end
        end

    elseif (event == "DAMAGE_METER_CURRENT_SESSION_UPDATED") then
        local sessionId = getCurrentSessionId()
        createAndAddSession(sessionId)

        if onPvpMatch then
            if sessionIdAtArenaStart == 0 then
                sessionIdAtArenaStart = sessionId
            end
        end

        --print("|cffff1111new session", GetTime(), getSessionDetailsId(sessionId))

        if not isUpdaterRunning() then
            if Details:ArePlayersInCombat() then
                startUpdater()
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
        --print("restrictionFlag", restrictionFlag)
    end)
end

combatEventFrame:SetScript("OnEvent", function(mySelf, ev, ...)
    if (ev == "PLAYER_LOGIN") then

    elseif (ev == "PLAYER_ENTERING_WORLD") then
        --when the player enters the world, check if in combat
        bRegenIsDisabled = UnitAffectingCombat("player")
        C_Timer.After(1, function()
            if not bRegenIsDisabled then

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

    elseif (ev == "CHALLENGE_MODE_START") then
        --print("CHALLENGE_MODE_START", GetTime())
        mythicPlusInfo.startTime = GetTime()
        mythicPlusInfo.startUnixTime = time()
        mythicPlusInfo.startDate = date("%H:%M:%S")
        mythicPlusInfo.sessionId = getCurrentSessionId()
        mythicPlusInfo.level = C_ChallengeMode.GetActiveKeystoneInfo()
        mythicPlusInfo.mapId = C_ChallengeMode.GetActiveChallengeMapID()
        mythicPlusInfo.isActive = true

    elseif (ev == "CHALLENGE_MODE_COMPLETED") then
        --print("CHALLENGE_MODE_COMPLETED", GetTime())
        mythicPlusInfo.endTime = GetTime()
        mythicPlusInfo.endUnixTime = time()
        mythicPlusInfo.endDate = date("%H:%M:%S")
        mythicPlusInfo.isActive = false

    elseif (ev == "PLAYER_DEAD") then
        --print("PLAYER_DEAD", GetTime())

    elseif (ev == "DAMAGE_METER_RESET") then
        --if bRegenIsDisabled then
        --    bHadDataResetInCombat = true
        --end
        --wipeStoredSessionIds()
        --onDataReset()

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

        if debug then

        end

    elseif (ev == "ZONE_CHANGED_NEW_AREA") then
        local _, newInstanceType = GetInstanceInfo()

        if currentZoneType ~= "arena" and newInstanceType == "arena" then --joined arena
            --sessionIdAtArenaStart = getCurrentSessionId()
            --print("ENTERED ARENA, session at entry:", sessionIdAtArenaStart)

        elseif currentZoneType == "arena" and newInstanceType ~= "arena" then --left arena
            C_Timer.After(2, function()
                onPvpMatch = false
                --sessionIdAtArenaStart = 0
            end)
        end

        currentZoneType = newInstanceType

    elseif (ev == "PVP_MATCH_ACTIVE") then
        --print("PVP_MATCH_ACTIVE", GetTime())
        --sessionIdAtArenaStart = getCurrentSessionId()
        onPvpMatch = true

    elseif (ev == "PVP_MATCH_COMPLETE") then
        --print("PVP_MATCH_COMPLETE", GetTime())

        local _, instanceType = GetInstanceInfo()
        if instanceType == "arena" then
            C_Timer.After(1, function()
                combatEventFrame:GetScript("OnEvent")(combatEventFrame, "PLAYER_REGEN_ENABLED")
            end)
        end

    elseif (ev == "PLAYER_REGEN_ENABLED") then --left the combat ~regen
        --print("PLAYER_REGEN_ENABLED", GetTime())

        local hasSecret = doYouHaveASecret()
        if not hasSecret then
            if debug then
                print("=> regen enabled, doYouHaveASecret() returned false.")
            end
        end

        local _, instanceType = GetInstanceInfo()
        if instanceType == "arena" then
            if not C_PvP.IsMatchComplete() then
                return
            end
        end

        if IsEncounterInProgress and IsEncounterInProgress() then
            return

        elseif InCombatLockdown() then
            return
        end

        if IsInInstance() then
            local isDeadOrGhost = UnitIsDeadOrGhost("player")
            if isDeadOrGhost then
                if Details:ArePlayersInCombat() then
                    return
                end
            end
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

        stopUpdaterAndClearWindow()

        parseSegments()

        local now = GetTime()
        if (now ~= evTime) then
            if debug then

            end
        end

    elseif (ev == "PLAYER_REGEN_DISABLED") then --entered in combat
        --print("PLAYER_REGEN_DISABLED", GetTime())

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

        if debug then

            if (bRegenIsDisabled) then

            end
        end

    elseif (ev == "ENCOUNTER_START") then
        if debug then

        end

    elseif (ev == "ENCOUNTER_END") then
        if debug then

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

    --for i = 1, #availableCombatSessions do
    --    local thisSession = availableCombatSessions[i]
    --    storeSessionId(thisSession.sessionID)
    --end
end


