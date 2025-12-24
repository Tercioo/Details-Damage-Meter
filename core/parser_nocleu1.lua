
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

local combatStartTime = 0 --GetTime()
local combatEndTime = 0 --GetTime()
local combatTime = 0
local combatStartDate = ""
local combatEndDate = ""

local spellContainerClass = Details.container_habilidades
local containerUtilityType = Details.container_type.CONTAINER_MISC_CLASS
local bIsInCombat = false

if (detailsFramework.IsAddonApocalypseWow()) then
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
        elseif (sessionType == DAMAGE_METER_SESSIONPARAMETER_SEGMENT) then
            return C_DamageMeter.GetCombatSessionSourceFromID(sessionID, damageMeterType, sourceGUID)
        end
        return {maxAmount = 0, combatSpells = {}}
    end

    local addSegment = function()
        if debug then
            print("Running addSegment()", GetTime())
        end

        ---@type damagemeter_combat_session[]
        local sessions = C_DamageMeter.GetAvailableCombatSessions()
        ---@type number
        local currentSegment = #sessions

        Details222.StartCombat()

        ---@type combat
        local currentCombat = Details:GetCurrentCombat()

        local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
        local healingContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_HEAL)
        local utilityContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_MISC)

        --here: detect the combat type and set it to newCombat
        --here: calculate the combatTime, startTime, endTime, startDate, endDate

        --pull deathlog data and parse it

        local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()

        --what has been processed:
        --damage done 0, 1
        --healing done 2, 3
        --damage taken 7
        --heal absorbs 4
        --interrupts 5
        --dispels 6

--[=[
["IsDamageMeterAvailable"] = function,
["ResetAllCombatSessions"] = function,
["GetAvailableCombatSessions"] = function,
["GetCombatSessionFromType"] = function,
["GetCombatSessionFromID"] = function,
["GetCombatSessionSourceFromID"] = function,
["GetCombatSessionSourceFromType"] = function,
--]=]

        local order = Details:GetOrderNumber()

        -------DAMAGE DONE
        ---@type damagemeter_combat_session
        local blzDamageContainer = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageDone)
        local damageActorList = blzDamageContainer.combatSources

        for i = 1, #damageActorList do
            ---@type damagemeter_combat_source
            local source = damageActorList[i]

            ---@type actordamage
            local actor = damageContainer:GetOrCreateActor(source.sourceGUID, source.name, 0x512, true)

            actor.nome = source.name
            actor.total = source.totalAmount
            actor.classe = source.classFilename
            actor.last_dps = source.amountPerSecond
            actor.specIcon = source.specIconID
            actor.serial = source.sourceGUID
            actor.grupo = true

            --print("IS SECRET:", issecretvalue(source.totalAmount))
            --print("Damage Source:", source.name, "Amount:", source.totalAmount)

            currentCombat.totals[1] = currentCombat.totals[1] + source.totalAmount
            currentCombat.totals_grupo[1] = currentCombat.totals_grupo[1] + source.totalAmount

            --spells
            local spells = getSourceSpells(DAMAGE_METER_SESSIONPARAMETER_TYPE, Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageDone, source.sourceGUID)
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
        local blzDamageTakenContainer = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageTaken)
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
        local blzHealingContainer = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.HealingDone)
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
            local spells = getSourceSpells(DAMAGE_METER_SESSIONPARAMETER_TYPE, Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.HealingDone, source.sourceGUID)
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
        local blzHealingAbsorbsContainer = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.Absorbs)
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
        local blzInterruptsContainer = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.Interrupts)
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
            local spells = getSourceSpells(DAMAGE_METER_SESSIONPARAMETER_TYPE, Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.Interrupts, source.sourceGUID)
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
        local blzDispelsContainer = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.Dispels)
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
            local spells = getSourceSpells(DAMAGE_METER_SESSIONPARAMETER_TYPE, Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.Dispels, source.sourceGUID)
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

        currentCombat:SetDate(combatStartDate, combatEndDate)
        currentCombat:SetStartTime(combatStartTime)
        currentCombat:SetEndTime(combatEndTime)

        local encounterInfo = Details.encounter_table
        local encounterStartTime = encounterInfo and encounterInfo.start or 0 --GetTime()

        local bCombatEnded = false

        if (encounterStartTime > 0) then
            if (detailsFramework.Math.IsNearlyEqual(encounterStartTime, combatStartTime, 2)) then
                currentCombat:SetEndTime(encounterInfo["end"] or combatEndTime)
                if debug then
                    print("end encounter:", encounterInfo.id, encounterInfo.name, encounterInfo.diff, encounterInfo.size, encounterInfo.end_status)
                end
                Details:SairDoCombate(encounterInfo.kill, {encounterInfo.id, encounterInfo.name, encounterInfo.diff, encounterInfo.size, encounterInfo.end_status})
                bCombatEnded = true
            end
        end

        if not bCombatEnded then
            Details:SairDoCombate()
        end

        --update all windows
        Details:InstanceCallDetailsFunc(Details.FadeHandler.Fader, "IN", nil, "barras")
        Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse)
        Details:InstanceCallDetailsFunc(Details.AtualizaSoloMode_AfertReset)
        Details:InstanceCallDetailsFunc(Details.ResetaGump)
        Details:RefreshMainWindow(-1, true)

        --Details222.DLC12_Combat_Data.nextSegment = Details222.DLC12_Combat_Data.nextSegment + 1

        if (currentSession) then
            local data = {}
            Details222.DLC12_Combat_Data[Details222.DLC12_Combat_Data.nextSegment] = data
            ---@type number
            local sessionID = currentSession.sessionID
            buildPlayerData(data, sessionID)
        end
    end

    local combatAcknowledgeListener = Details:CreateEventListener()
    combatAcknowledgeListener.InCombat = false
    combatAcknowledgeListener.ParserFrame = CreateFrame("frame")
    combatAcknowledgeListener.ParserFrame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
    combatAcknowledgeListener.ParserFrame:SetScript("OnEvent", function(self, event, ...)
        --when this event happen, update details! windows (or not)

    end)

    ---@class details
    ---@field update_speed number
    ---@field InstanceCall fun(self:details, function:fun(instance:instance), ...:any?)
    ---@field GetAllLines fun(self:details):frame[]

    --map mainDisplay to blizzard damage meter data
    local displayMap = {
        [1] = {
            Enum.DamageMeterType.DamageDone, --damage done
            Enum.DamageMeterType.DamageDone, --dps
            Enum.DamageMeterType.DamageTaken, --damage taken
            100, --friendly fire (not supported)
            100, --frags (not supported)
            100, --enemies (not supported)
            100, --void zones (not supported)
            100, --damage taken by spells (not supported)
        },
        [2] = {
            Enum.DamageMeterType.HealingDone, --healing done
            Enum.DamageMeterType.HealingDone, --hps
            Enum.DamageMeterType.Absorbs, --absorbs
            100, --overhealing (not supported)
            100, --healing taken (not supported)
            100, --healing enemy (not supported)
            100, --healing prevented (not supported)
            Enum.DamageMeterType.Absorbs, --healing absorbed
        },
        [3] = {
            100, --resources (not supported)
            100, --mana gained (not supported)
            100, --rage gained (not supported)
            100, --energy gained (not supported)
            100, --runes gained (not supported)
            100, --alternate power gained (not supported)
        },
        [4] = {
            100, --cc breaks
            100, --ress (not supported)
            Enum.DamageMeterType.Interrupts, --interrupts
            Enum.DamageMeterType.Dispels, --dispels
            100, --deaths (not supported)
            100, --dcooldowns (not supported)
            100, --buff uptime (not supported)
            100, --debuff uptime (not supported)

        },
    }

    local clearWindow = function(instance)
        ---@type detailsline[]
        local allInstanceLines = instance.barras --instance:GetAllLines()

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
    end

    ---update the window in real time
    ---@param instance instance
    local updateWindow = function(instance)
        ---@type attributeid, attributeid
        local mainDisplay, subDisplay = instance:GetDisplay()

        ---@type damagemeter_type
        local damageMeterType = displayMap[mainDisplay] and displayMap[mainDisplay][subDisplay]

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

        if (damageMeterType) then
            ---@type segmentid
            local segmentId = instance:GetSegmentId()

            ---@type damagemeter_combat_session
            local session

            if segmentId == -1 then
                session = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Overall, damageMeterType)

            elseif segmentId == 0 then
                session = C_DamageMeter.GetCombatSessionFromType(Enum.DamageMeterSessionType.Current, damageMeterType)
            else
                ---@type damagemeter_combat_session[]
                local sessions = C_DamageMeter.GetAvailableCombatSessions()
                ---@type number
                local sessionIndex = #sessions - (segmentId - 1)
                ---@type damagemeter_combat_session
                session = sessions[sessionIndex]
            end

            local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
            local textureFile = SharedMedia:Fetch("statusbar", instance.row_info.texture)
            local textureFile2 = SharedMedia:Fetch("statusbar", instance.row_info.texture_background)
            local overlayTexture = SharedMedia:Fetch("statusbar", instance.row_info.overlay_texture)
            local overlayColor = instance.row_info.overlay_color

            if (session) then
                ---@type damagemeter_combat_source[]
                local combatSources = session.combatSources
                local amountOfSources = #combatSources

                local topValue = session.maxAmount
                local segmentName = session.name
                local sessionId = session.sessionID

                for i = 1, amountOfSources do
                    ---@type detailsline
                    local instanceLine = allInstanceLines[i]
                    if (instanceLine) then --no bar one, creating on demand?
                        ---@type damagemeter_combat_source
                        local source = combatSources[i]
                        local value = source.totalAmount
                        local totalAmountPerSecond = source.amountPerSecond
                        local actorName = source.name
                        local classFilename = source.classFilename
                        local specIcon = source.specIconID
                        local actorGUID = source.sourceGUID
                        local isPlayer = source.isLocalPlayer

                        instanceLine.lineText11:SetText(actorName)
                        instanceLine.lineText12:SetText(AbbreviateNumbers(value))
                        instanceLine.lineText13:SetText(AbbreviateNumbers(totalAmountPerSecond))
                        instanceLine.lineText14:SetText("?%")

                        instanceLine.statusbar:SetMinMaxValues(0, topValue)
                        instanceLine.statusbar:SetValue(value)

                        instanceLine.icone_classe:SetTexture(specIcon)
                        instanceLine.icone_classe:SetTexCoord(0.1, .9, .1, .9)

                        instanceLine.textura:SetTexture(textureFile)
                        instanceLine.background:SetTexture(textureFile2)
                        instanceLine.overlayTexture:SetTexture(overlayTexture)
                        instanceLine.overlayTexture:SetVertexColor(unpack(overlayColor))

                        local classColor = Details.class_colors[classFilename]
                        if (classColor) then
                            instanceLine.textura:SetVertexColor(classColor[1], classColor[2], classColor[3])
                        else
                            instanceLine.textura:SetVertexColor(detailsFramework:ParseColors("brown"))
                        end

                        linesInUse = linesInUse + 1
                        instanceLine:SetAlpha(1)
                        instanceLine:Show()
                        --detailsFramework:DebugVisibility(instanceLine)
                    else
                        if debug then
                            print("no line", i)
                        end
                        break
                    end
                end
            end

        end
    end

    local updateOpenedWindows = function()
        Details:InstanceCall(updateWindow)--update all opened details! windows with the new data from blizzard damage meter

    end

    local switchWindowFontStrings = function(instance)
        local show = not bIsInCombat
        local allInstanceLines = instance.barras

        for i = 1, #allInstanceLines do
            local line = allInstanceLines[i]
            line.lineText1:SetText("")
            line.lineText2:SetText("")
            line.lineText3:SetText("")
            line.lineText4:SetText("")
            line.lineText11:SetShown(bIsInCombat)
            line.lineText12:SetShown(bIsInCombat)
            line.lineText13:SetShown(bIsInCombat)
            line.lineText14:SetShown(bIsInCombat)
        end
    end

    local updaterTicker = nil
    local startUpdater = function()
        Details:InstanceCall(switchWindowFontStrings, true)

        --start a ticker that will update opened details! windows every X seconds
        if (not updaterTicker) then
            updaterTicker = C_Timer.NewTicker(Details.update_speed, function()
                if (bIsInCombat) then
                    updateOpenedWindows()
                end
            end)
        end
    end

    local stopUpdater = function()
        if (updaterTicker) then
            updaterTicker:Cancel()
            updaterTicker = nil
            Details:InstanceCall(clearWindow)
        end
    end

    local lastCombatChangedEventTime = GetTime()
    local combatEventFrame = CreateFrame("frame")
    local evTime

    combatEventFrame:RegisterEvent("PLAYER_IN_COMBAT_CHANGED")
    combatEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    combatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    combatEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    combatEventFrame:RegisterEvent("PLAYER_LOGIN")
    combatEventFrame:RegisterEvent("ENCOUNTER_START")
    combatEventFrame:RegisterEvent("ENCOUNTER_END")

    combatEventFrame:SetScript("OnEvent", function(mySelf, ev, ...)
        if (ev == "PLAYER_ENTERING_WORLD") then
            --when the player enters the world, check if in combat
            bIsInCombat = UnitAffectingCombat("player")
            C_Timer.After(1, function()
                if not bIsInCombat then
                    --print("NOT IN COMBAT ON ENTERING WORLD")
                    --addSegment() --not sure why this was here.
                end
            end)
            --print("ENTERING WORLD, IN COMBAT:", bIsInCombat)

        elseif (ev == "PLAYER_IN_COMBAT_CHANGED") then --entered in combat
            local inCombat = ...
            if inCombat then
                local now = GetTime()
                if (now ~= evTime) then
                    if debug then
                        print("|cFFFFFF00 GetTime() PRD different from PICC.")
                    end
                end
                evTime = GetTime()
            else
                evTime = GetTime()
            end

            if debug then
                print("PLAYER_IN_COMBAT_CHANGED", GetTime(), inCombat)
            end

        elseif (ev == "PLAYER_REGEN_ENABLED") then --left the combat
            combatEndTime = GetTime()
            combatTime = combatEndTime - combatStartTime
            combatEndDate = date("%H:%M:%S")

            if debug then
                print("PLAYER_REGEN_ENABLED", GetTime())
            end

            bIsInCombat = false
            stopUpdater()
            if debug then
                print("|cFFFFFF00 OUT OF COMBAT")
            end

            --C_Timer.After(1,addSegment)
            addSegment()

            local now = GetTime()
            if (now ~= evTime) then
                if debug then
                    print("|cFFFFFF00 GetTime() PRD different from PICC.")
                end
            end


        elseif (ev == "PLAYER_REGEN_DISABLED") then --entered in combat
            --print(InCombatLockdown(), UnitAffectingCombat("player"), ...)

            --print(lastCombatChangedEventTime , GetTime(), lastCombatChangedEventTime == GetTime())
            --if (lastCombatChangedEventTime == GetTime()) then
            --    return
            --end
            --lastCombatChangedEventTime = GetTime()

            combatStartTime = GetTime()
            combatStartDate = date("%H:%M:%S")

            if debug then
                print("|cFFFFFF00 OUT OF COMBAT")
            end

            evTime = GetTime()

            if (bIsInCombat) then
                if debug then
                    print("|cFFFFFF00 PRD triggered, but bIsInCombat is true.")
                end
            end

            bIsInCombat = true

            startUpdater()

            if debug then
                print("PLAYER_REGEN_DISABLED", GetTime())
            end

        elseif (ev == "ENCOUNTER_START") then
            if debug then
                print("ENCOUNTER_START", GetTime())
            end

        elseif (ev == "ENCOUNTER_END") then
            if debug then
                print("ENCOUNTER_END", GetTime())
            end
        end
    end)

        do return end

        ---@type damagemeter_combat_session[]
        local sessions = C_DamageMeter.GetAvailableCombatSessions()

        --blizzard segments are added at the end of the table
        --this is the oposite of what details! do where new segments are added to the beginning of the table

        ---@type number
        local currentSegment = #sessions
        ---@type damagemeter_combat_session
        local currentSession = sessions[currentSegment]

        if (currentSession) then
            ---@type number
            local sessionID = currentSession.sessionID
            ---@type damagemeter_type
            local damageMeterType = Enum.DamageMeterType.DamageDone

            ---@type damagemeter_combat_session
            local session = C_DamageMeter.GetCombatSessionFromID(sessionID, damageMeterType)

            ---@type combat
            local combat = Details:GetCurrentCombat()

            if (session) then
                ---@type number this is the damage done by the top damager
                local topDamageAmount = session.maxAmount
                ---@type damagemeter_combat_source[]
                local combatSources = session.combatSources

                local amountOfSources = #combatSources
                for i = 1, amountOfSources do
                    ---@type damagemeter_combat_source
                    local source = combatSources[i]
                    ---@type guid
                    local sourceGUID = source.sourceGUID
                    ---@type actorname
                    local actorName = source.name
                    ---@type number
                    local amountDone = source.totalAmount
                    ---@type class
                    local sourceClassFilename = source.classFilename
                    ---@type number
                    local dps = source.amountPerSecond
                    ---@type boolean
                    local isLocalPlayer = source.isLocalPlayer

                    ---@type actorcontainer
                    local damageContainer = combat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

                    ---@type controlflags
                    local sourceFlags = 0x512

                    ---@type actordamage
                    local actor = damageContainer:GetOrCreateActor(sourceGUID, actorName, sourceFlags, true)

                    actor.total = amountDone
                    actor.classe = sourceClassFilename
                    actor.last_dps = dps
                    actor.grupo = true

                    damageContainer.need_refresh = true --set as dirty
                end
            end
        end


    function combatAcknowledgeListener.COMBAT_PLAYER_ENTER()
        --this event is triggered when details! create a new segment

    end

    function combatAcknowledgeListener.COMBAT_PLAYER_LEAVE()
        --this event is triggered when details! ends a segment

    end

    combatAcknowledgeListener:RegisterEvent("COMBAT_PLAYER_ENTER")
    combatAcknowledgeListener:RegisterEvent("COMBAT_PLAYER_LEAVE")

    --PLAYER_IN_COMBAT_CHANGED
    --PLAYER_LEVEL_CHANGED
end

--[=[
local f=CreateFrame("frame")
f:RegisterEvent("PLAYER_IN_COMBAT_CHANGED")
f:SetScript("OnEvent",function(self,ev,...)
    local payload = ...
    if payload == false then
        print("CombatLockdown:",InCombatLockdown(), "AffectingCombat:",UnitAffectingCombat("player"), "EventPayload:",payload) --false, false, false
        local makeError = C_DamageMeter.GetCombatSessionFromType(0,1).combatSources[1].totalAmount+1
        --attempt to perform arithmetic on field 'totalAmount' (a secret value)
    end
end)
--]=]