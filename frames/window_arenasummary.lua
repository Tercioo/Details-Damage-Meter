
---@type details
local Details = Details
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework
local _

Details222.ArenaSummary = {
    arenaData = {},
}


--PVPMatchResults.content
--PVPMatchResults.content.earningsContainer
--PVPMatchResults.content.earningsContainer.rewardsContainer .items [GetChildren | Button] child={.Icon .IconBorder .IconOverlay .IconOverlay2 .Count .SpecIcon .SpecRing .link?ItemLink}
--PVPMatchResults.content.earningsContainer.progressContainer .honor{.button{.Ring .Icon .CircleMask} .text .legacyButton} .conquest{.button{.Ring .Icon .CircleMask} .text .legacyButton} .rating{.button{.Icon .RankingShadow .Ranking(fontstring)} .text}
--PVPMatchResults.buttonContainer.requeueButton
--PVPMatchResults.buttonContainer.leaveButton
--PVPMatchResults.header (fontstring VICTORY or DEFEAT)

---@class details : table
---@field zone_type string the type of the current zone, e.g. "arena", "raid", "dungeon", "scenario"
---@field arena_debug boolean
---@field arena_data_headers table
---@field arena_data_compressed table
---@field arena_data_index_selected number which dataset is showing in the arena scoreboard

---@class arena_playerinfo : table
---@field name string
---@field role string
---@field class string
---@field spec number
---@field guid string
---@field isFriendly boolean
---@field killingBlows killingblow[]
---@field dps number
---@field hps number
---@field realTimeDps table<number>
---@field realTimePeakDamage number
---@field totalDamage number
---@field totalDamageTaken number
---@field totalHeal number
---@field totalHealTaken number
---@field totalDispels number
---@field totalInterrupts number
---@field totalInterruptsCasts number
---@field totalCrowdControlCasts number
---@field damageDoneBySpells table
---@field healingDoneBySpells table
---@field dispelWhat table<string, number>
---@field interruptWhat table<string, number>
---@field crowdControlSpells table<string, number>
---@field honorableKills number
---@field deaths number
---@field honorGained number
---@field faction number --0 for horde, 1 for alliance
---@field className string --name of the class, e.g. "Priest"
---@field classToken string --token of the class, e.g. "PRIEST"
---@field rating number --current rating of the player
---@field ratingChange number --rating change after the match
---@field prematchMMR number --MMR before the match
---@field mmrChange number --MMR change after the match
---@field postmatchMMR number --MMR after the match
---@field talentSpec string --talent spec of the player, e.g. "None"
---@field honorLevel number --honor level of the player
---@field roleAssigned string --role assigned to the player, e.g. "NONE"
---@field stats table --table with the stats of the player

---@class arenasummary : table
---@field Lines arenaline[]
---@field arenaData table
---@field LoopTicker timer
---@field DeathHook boolean
---@field window frame
---@field OpenWindow fun(): frame
---@field NewPlayer fun(actorObject: actor, isFriendly: boolean, unitId: string)
---@field OnArenaStart fun()
---@field OnArenaEnd fun()
---@field CompressArena fun(arenaData: table): table --compresses the arena data to be saved in the Details.arena_data_compressed table
---@field CreateWindow fun(): frame --creates the arena summary window
---@field SetFontSettings fun() --sets the font settings for the arena summary window

local tickerId = 1

local ArenaSummary = Details222.ArenaSummary
ArenaSummary.CurrentArenaData = nil --this variable is used to store the current arena data being displayed in the arena summary window

function Details:OpenArenaSummaryWindow()
    return ArenaSummary.OpenWindow()
end

function ArenaSummary.OpenWindow()
    if (not ArenaSummary.window) then
        ArenaSummary.window = ArenaSummary.CreateWindow()
    end

    if (not ArenaSummary.window:IsShown()) then
        ArenaSummary.window:Show()
    end

    ArenaSummary.window.RequeueButton:Enable()

    --refresh the scroll area
    ArenaSummary.window.ArenaPlayersScroll:RefreshScroll()
end

local makePlayerTable = function(unitName, thisData)
    local playerTable = {
        name = unitName,
        role = thisData.role or "NONE",
        class = thisData.class or "UNKNOWN",
        guid = thisData.guid or "",
        isFriendly = thisData.isFriendly or false,
        killingBlows = {},
        dps = 0, --the average dps for this player
        hps = 0, --the average hps for this player
        realTimeDps = {}, --this table stores an array of numbers with the real time dps values per second
        realTimePeakDamage = 0, --the peak damage done in real time

        totalDispels = 0,
        totalInterrupts = 0,
        totalInterruptsCasts = 0,
        totalCrowdControlCasts = 0,
        dispelWhat = {},
        interruptWhat = {},
        crowdControlSpells = 0,
    }
    return playerTable
end

function ArenaSummary.NewPlayer(actorObject, isFriendly, unitId)
    if (ArenaSummary.LoopTicker and not ArenaSummary.LoopTicker:IsCancelled()) then
        if (isFriendly) then
            if (not Details222.ArenaSummary.arenaData.combatData.groupMembers[actorObject.nome]) then
                local thisData = Details.arena_table[actorObject.nome]
                thisData.isFriendly = true
                thisData.guid = UnitGUID(unitId) or ""
                thisData.class = select(2, UnitClass(actorObject.nome)) or "UNKNOWN"
                Details222.ArenaSummary.arenaData.combatData.groupMembers[actorObject.nome] = makePlayerTable(actorObject.nome, thisData)

                local realTimeDps = Details222.ArenaSummary.arenaData.combatData.groupMembers[actorObject.nome].realTimeDps
                --initialize the real time dps array from 1 to the index of tickerId
                for i = 1, tickerId do
                    realTimeDps[i] = 0
                end
            end
        else
            if (not Details222.ArenaSummary.arenaData.combatData.groupMembers[actorObject.nome]) then
                local thisData = {
                    role = "NONE",
                    isFriendly = false,
                    guid = UnitGUID(unitId) or "",
                    class = select(2, UnitClass(unitId)) or "UNKNOWN"
                }
                Details222.ArenaSummary.arenaData.combatData.groupMembers[actorObject.nome] = makePlayerTable(actorObject.nome, thisData)

                local realTimeDps = Details222.ArenaSummary.arenaData.combatData.groupMembers[actorObject.nome].realTimeDps
                --initialize the real time dps array from 1 to the index of tickerId
                for i = 1, tickerId do
                    realTimeDps[i] = 0
                end
            end
        end
    end
end

--details isn't closing the arena combat when the arena ends

--ARENA TICKER
local arenaTicker = function(tickerObject)
    local currentCombat = Details:GetCurrentCombat()
    local combatTime = currentCombat:GetCombatTime()

    --iterate among the arena players and update their data
    for unitName, playerData in pairs(Details222.ArenaSummary.arenaData.combatData.groupMembers) do
        -- Update playerData with new information
        local damageActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, unitName)
        if (damageActorObject) then
            playerData.dps = damageActorObject.total / combatTime
        end
        local healingActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_HEAL, unitName)
        if (healingActorObject) then
            playerData.hps = healingActorObject.total / combatTime
        end

        local currentDPS = Details.CurrentDps.GetCurrentDps(playerData.guid) or 0
        playerData.realTimeDps[#playerData.realTimeDps + 1] = currentDPS
        if (currentDPS > playerData.realTimePeakDamage) then
            playerData.realTimePeakDamage = currentDPS
        end
    end

    Details222.ArenaSummary.arenaData.dampening = C_Commentator.GetDampeningPercent()

    tickerId = tickerId + 1
end

function ArenaSummary.OnArenaStart() --~start
    if (Details.arena_debug) then
        print("ARENA STARTED!!", "elapsed time:", "date:", date("%Y-%m-%d %H:%M:%S", time()), time())
    end

    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()

    Details222.ArenaSummary.arenaData = {
        combatData = {
            groupMembers = {},
        },
        arenaName = name,
        arenaMapId = instanceID,
        startTime = time(),
        dampening = 0,
        combatId = Details:GetCurrentCombat():GetCombatUID(),
    }

    if (not ArenaSummary.DeathHook) then --~death ~dead ~kill
        local onDeathEvent = function(_, token, time, sourceGUID, sourceName, sourceFlags, targetGUID, targetName, targetFlags, playerDeathTable, lastCooldown, combatElapsedTime, maxHealth)
            if (Details.zone_type ~= "arena") then
                return
            end

            --when a death occurs, get the deathTable and examin it to get the player which did the most amount of damage
            --[=[
                playerDeathTable = {
                    eventsBeforePlayerDeath, --table
                    time, --number unix time
                    thisPlayer.nome, --string player name
                    thisPlayer.classe, --string player class
                    maxHealth, --number max health
                    minutes .. "m " .. seconds .. "s", --time of death as string
                    ["dead"] = true,
                    ["last_cooldown"] = thisPlayer.last_cooldown,
                    ["dead_at"] = combatElapsedTime,
                    ["spec"] = thisPlayer.spec,
                }
            --]=]

            local eventsBeforePlayerDeath = playerDeathTable[1]
            local damageSum = {}
            for i = 1, #eventsBeforePlayerDeath do
                local event = eventsBeforePlayerDeath[i]
                local evType, spellId, amount, eventTime, heathPercent, sourceName, absorbed, spellSchool, friendlyFire, overkill, criticalHit, crushing = Details:UnpackDeathEvent(event)
                if (evType == true) then --is a damage event
                    if (Details222.ArenaSummary.arenaData.combatData.groupMembers[sourceName]) then
                        damageSum[sourceName] = (damageSum[sourceName] or 0) + amount
                    end
                end
            end

            --goal is to iterate among the damageSum table and find the player with the most damage
            local orderedTable = {}
            for sourceName, damage in pairs(damageSum) do
                orderedTable[#orderedTable + 1] = {name = sourceName, damage = damage}
            end
            table.sort(orderedTable, function(a, b)
                return a.damage > b.damage
            end)

            local mostDamagePlayer = orderedTable[1]

            if (mostDamagePlayer) then
                local playerData = Details222.ArenaSummary.arenaData.combatData.groupMembers[mostDamagePlayer.name]
                local killingBlows = playerData.killingBlows
                local thisKillingBlow = {
                    enemyName = targetName,
                    damageByPlayers = orderedTable
                }
                killingBlows[#killingBlows + 1] = thisKillingBlow

                if (Details.arena_debug) then
                    print("ADDED a KILL for player", mostDamagePlayer.name, "with damage:", mostDamagePlayer.damage)
                end
            end
        end

        Details:InstallHook(DETAILS_HOOK_DEATH, onDeathEvent)

        ArenaSummary.DeathHook = true
    end

    ---@class killingblowdamage : table
    ---@field name string who caused the damage
    ---@field damage number how much damage was done by this player

    ---@class killingblow : table
    ---@field enemyName string
    ---@field damageByPlayers killingblowdamage[] --table with the player name as key and the damage done as value

    --data already existing:
        --Details.arena_table [unitName] = {role = role}
        --Details.arena_enemies[enemyName] = "arena" .. i

        --Details.savedTimeCaptures table[] -> {timeDataName, callbackFunc, matrix, author, version, icon, bIsEnabled, do_not_save = no_save})
        --"Your Team Damage"
        --"Enemy Team Damage"
        --"Your Team Healing"
        --"Enemy Team Healing"

    --the aknoladge of other players in arena players can be done after the match starts due to hidden players

    --1. create a table for each player in the arena
    for unitName, data in pairs(Details.arena_table) do
        if (unitName ~= UNKNOWN) then
            --print("ArenaSummary: Adding player " .. unitName)
            local thisData = detailsFramework.table.copy({}, data)
            thisData.isFriendly = true
            thisData.guid = UnitGUID(unitName) or ""
            thisData.class = select(2, UnitClass(unitName)) or "UNKNOWN"
            Details222.ArenaSummary.arenaData.combatData.groupMembers[unitName] = makePlayerTable(unitName, thisData)
            --print("arena friendly:", unitName)
        end
    end

    --2. create a table for each enemy in the arena
    for enemyName, unitId in pairs(Details.arena_enemies) do
        --print("ArenaSummary: Adding enemy " .. enemyName)
        local thisData = {
            role = "NONE",
            isFriendly = false,
            guid = UnitGUID(unitId) or "",
            class = select(2, UnitClass(unitId)) or "UNKNOWN"
        }
        Details222.ArenaSummary.arenaData.combatData.groupMembers[enemyName] = makePlayerTable(enemyName, thisData)

        --print("arena enemy:", enemyName)
    end

    --signature: NewLooper(time: number, callback: function, loopAmount: number, loopEndCallback: function?, checkPointCallback: function?, ...: any): timer
    local time = 1
    local loopAmount = 0 --0 means infinite
    local loopEndCallback = function() end --called when the loop ends

    tickerId = 1
    ArenaSummary.LoopTicker = detailsFramework.Schedules.NewLooper(time, arenaTicker, loopAmount, loopEndCallback)
end

---@param actorObject actordamage
function ArenaSummary.GetPlayerDamageSpells(actorObject)
    local spellsUsed = actorObject:GetActorSpells()
    local damageSpells = {}
    for _, spellTable in pairs(spellsUsed) do
        table.insert(damageSpells, {spellTable.id, spellTable.total})
    end
    table.sort(damageSpells, function(a, b) return a[2] > b[2] end)
    return damageSpells
end

---@param actorObject actorheal
function ArenaSummary.GetPlayerHealingSpells(actorObject)
    local spellsUsed = actorObject:GetActorSpells()
    local healingSpells = {}
    for _, spellTable in pairs(spellsUsed) do
        table.insert(healingSpells, {spellTable.id, spellTable.total})
    end
    table.sort(healingSpells, function(a, b) return a[2] > b[2] end)
    return healingSpells
end

function ArenaSummary.OnArenaEnd() --~end
    if (ArenaSummary.LoopTicker) then
        ArenaSummary.LoopTicker:Cancel()
    end

    local combat = Details:GetCurrentCombat()
    local combatTime = combat:GetCombatTime()
    if (Details.arena_debug) then
        print("ARENA ENDED!!", "elapsed time:", combatTime, "date:", date("%Y-%m-%d %H:%M:%S", time()), "/run Details:OpenArenaSummaryWindow()")
    end

    local damageContainer = combat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
    for index, actor in damageContainer:ListActors() do
        if (actor:IsPlayer()) then
            --print("arena damage actor:", actor.nome, actor.classe)
        end
    end

    local currentCombat = Details:GetCurrentCombat()
    local combatTime = currentCombat:GetCombatTime()

    local actorContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)



    --player and arena information
	local teamInfos = {
		C_PvP.GetTeamInfo and C_PvP.GetTeamInfo(0) or {},
		C_PvP.GetTeamInfo and C_PvP.GetTeamInfo(1) or {},
	}

    --dumpt(C_PvP.GetTeamInfo(0))

    Details222.ArenaSummary.arenaData.combatData.teamInfos = teamInfos
    Details222.ArenaSummary.arenaData.isArenaSkirmish = IsArenaSkirmish()
    Details222.ArenaSummary.arenaData.isRatedSoloShuffle = C_PvP.IsRatedSoloShuffle and C_PvP.IsRatedSoloShuffle() or false
    Details222.ArenaSummary.arenaData.isFactionalMatch = C_PvP.IsMatchFactional and C_PvP.IsMatchFactional() or false
    Details222.ArenaSummary.arenaData.isBrawlSoloShuffle = C_PvP.IsBrawlSoloShuffle and C_PvP.IsBrawlSoloShuffle() or false
    Details222.ArenaSummary.arenaData.isBrawlSoloRBG = C_PvP.IsBrawlSoloRBG and C_PvP.IsBrawlSoloRBG() or false
    Details222.ArenaSummary.arenaData.isSoloShuffle = C_PvP.IsSoloShuffle and C_PvP.IsSoloShuffle() or false
    Details222.ArenaSummary.arenaData.playerScoreInfo = C_PvP.GetScoreInfoByPlayerGuid and C_PvP.GetScoreInfoByPlayerGuid(UnitGUID("player")) or 0
    Details222.ArenaSummary.arenaData.doesMatchOutcomeAffectRating = C_PvP.DoesMatchOutcomeAffectRating and C_PvP.DoesMatchOutcomeAffectRating() or false
    Details222.ArenaSummary.arenaData.statColumns = C_PvP.GetMatchPVPStatColumns and C_PvP.GetMatchPVPStatColumns() or {}

    local personalRatedInfo = C_PvP.GetPVPActiveMatchPersonalRatedInfo and C_PvP.GetPVPActiveMatchPersonalRatedInfo()
    if (personalRatedInfo) then
        Details222.ArenaSummary.arenaData.playerPersonalRatedInfo = personalRatedInfo
    end

    --player rewards
    Details222.ArenaSummary.arenaData.playerRewards = {}
    if (C_PvP.GetPostMatchItemRewards) then
        for k, item in pairs(C_PvP.GetPostMatchItemRewards()) do
            ---@cast item pvppostmatchitemreward
            table.insert(Details222.ArenaSummary.arenaData.playerRewards, item)
        end
    end

    if (C_PvP.GetPostMatchCurrencyRewards) then
        for k, currency in pairs(C_PvP.GetPostMatchCurrencyRewards()) do
            ---@cast currency pvppostmatchcurrencyreward
            table.insert(Details222.ArenaSummary.arenaData.playerRewards, currency)
        end
    end

    --iterate among the arena players and update their data
    for unitName, playerInfo in pairs(Details222.ArenaSummary.arenaData.combatData.groupMembers) do
        -- Update playerInfo with new information
        ---@type actordamage
        local damageActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, unitName)
        if (damageActorObject) then
            playerInfo.dps = damageActorObject.total / combatTime
            playerInfo.totalDamage = damageActorObject.total
            playerInfo.totalDamageTaken = damageActorObject.damage_taken
            playerInfo.damageDoneBySpells = ArenaSummary.GetPlayerDamageSpells(damageActorObject)
        end

        ---@type actorheal
        local healingActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_HEAL, unitName)
        if (healingActorObject) then
            playerInfo.hps = healingActorObject.total / combatTime
            playerInfo.totalHeal = healingActorObject.total
            playerInfo.totalHealTaken = healingActorObject.healing_taken
            playerInfo.healingDoneBySpells = ArenaSummary.GetPlayerHealingSpells(healingActorObject)
        end

        pcall(function()

        -- Reduce realTimeDps table size if combatTime > 240 seconds (4 minutes)
        if playerInfo.realTimeDps and #playerInfo.realTimeDps > 240 then
            local original = playerInfo.realTimeDps
            local reduced = {}
            local factor = math.ceil(#original / 240)
            for i = 1, 240 do
                local startIdx = (i - 1) * factor + 1
                local endIdx = math.min(i * factor, #original)
                local sum, sumSq, count = 0, 0, 0
                for j = startIdx, endIdx do
                    local val = original[j]
                    sum = sum + val
                    sumSq = sumSq + val * val
                    count = count + 1
                end
                if count > 0 then
                    local mean = sum / count
                    local variance = (sumSq / count) - (mean * mean)
                    local stddev = math.sqrt(math.max(variance, 0))
                    reduced[i] = mean + stddev
                else
                    reduced[i] = 0
                end
            end
            playerInfo.realTimeDps = reduced
            playerInfo.originalRealTimeDps = original
        end

        end)

        playerInfo.spec = Details:GetSpecFromSerial(playerInfo.guid)
        playerInfo.ilevel = Details:GetItemLevelFromGuid(playerInfo.guid) or 0

        --print("groupMembers IT -> UName:", unitName, playerInfo.guid, playerInfo.spec, playerInfo.ilevel)

        if (UnitIsUnit(unitName, "player")) then
            local playerGUID = UnitGUID("player")
            ---@type pvpscoreinfo
            local localPlayerScoreInfo = C_PvP.GetScoreInfoByPlayerGuid and C_PvP.GetScoreInfoByPlayerGuid(playerGUID) or {}
            if (localPlayerScoreInfo) then
                --playerInfo.killingBlows = localPlayerScoreInfo.killingBlows or 0
                playerInfo.guid = localPlayerScoreInfo.guid or "NONE"
                playerInfo.honorableKills = localPlayerScoreInfo.honorableKills or 0
                playerInfo.deaths = localPlayerScoreInfo.deaths or 0
                playerInfo.honorGained = localPlayerScoreInfo.honorGained or 0
                playerInfo.faction = localPlayerScoreInfo.faction or 0
                playerInfo.className = localPlayerScoreInfo.className or "Priest"
                playerInfo.classToken = localPlayerScoreInfo.classToken or "PRIEST"
                playerInfo.rating = localPlayerScoreInfo.rating or 0
                playerInfo.ratingChange = localPlayerScoreInfo.ratingChange or 0
                playerInfo.prematchMMR = localPlayerScoreInfo.prematchMMR or 0
                playerInfo.mmrChange = localPlayerScoreInfo.mmrChange or 0
                playerInfo.postmatchMMR = localPlayerScoreInfo.postmatchMMR or 0
                playerInfo.talentSpec = localPlayerScoreInfo.talentSpec or "None"
                playerInfo.honorLevel = localPlayerScoreInfo.honorLevel or 0
                playerInfo.roleAssigned = localPlayerScoreInfo.roleAssigned or "NONE"
                playerInfo.stats = localPlayerScoreInfo.stats or {}
            end

        elseif (playerInfo.guid) then
            ---@type pvpscoreinfo
            local localPlayerScoreInfo = C_PvP.GetScoreInfoByPlayerGuid and C_PvP.GetScoreInfoByPlayerGuid(playerInfo.guid) or {}
            --print("UName:", unitName, playerInfo.guid, localPlayerScoreInfo)
            if (localPlayerScoreInfo) then
                --playerInfo.killingBlows = localPlayerScoreInfo.killingBlows or 0
                playerInfo.guid = localPlayerScoreInfo.guid or "NONE"
                playerInfo.honorableKills = localPlayerScoreInfo.honorableKills or 0
                playerInfo.deaths = localPlayerScoreInfo.deaths or 0
                playerInfo.honorGained = localPlayerScoreInfo.honorGained or 0
                playerInfo.faction = localPlayerScoreInfo.faction or 0
                playerInfo.className = localPlayerScoreInfo.className or "Priest"
                playerInfo.classToken = localPlayerScoreInfo.classToken or "PRIEST"
                playerInfo.rating = localPlayerScoreInfo.rating or 0
                playerInfo.ratingChange = localPlayerScoreInfo.ratingChange or 0
                playerInfo.prematchMMR = localPlayerScoreInfo.prematchMMR or 0
                playerInfo.mmrChange = localPlayerScoreInfo.mmrChange or 0
                playerInfo.postmatchMMR = localPlayerScoreInfo.postmatchMMR or 0
                playerInfo.talentSpec = localPlayerScoreInfo.talentSpec or "None"
                playerInfo.honorLevel = localPlayerScoreInfo.honorLevel or 0
                playerInfo.roleAssigned = localPlayerScoreInfo.roleAssigned or "NONE"
                playerInfo.stats = localPlayerScoreInfo.stats or {}
            end
        else
            --print("unit without guid:", unitName)
        end

        local ccTotal = 0
        local ccUsed = {}

        if (Details:GetCoreVersion() < 166) then
            local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
            if (openRaidLib) then
                for spellName, casts in pairs(currentCombat:GetCrowdControlSpells(unitName)) do
                    local spellInfo = C_Spell.GetSpellInfo(spellName)
                    local spellId = spellInfo and spellInfo.spellID or openRaidLib.GetCCSpellIdBySpellName(spellName)
                    if (spellId ~= 197214) then
                        ccUsed[spellName] = casts
                        ccTotal = ccTotal + casts
                    end
                end
            end
        else
            --at 166, Details! now uses the spellId instead of the spellName for crowd controls
            for spellId, casts in pairs(currentCombat:GetCrowdControlSpells(unitName)) do
                if (spellId ~= 197214) then
                    ccUsed[spellId] = casts
                    ccTotal = ccTotal + casts
                end
            end
        end

        ---@type actorutility
        local utilityActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_MISC, unitName)
        if (utilityActorObject) then
            playerInfo.totalDispels = utilityActorObject.dispell
            playerInfo.totalInterrupts = utilityActorObject.interrupt
            playerInfo.totalInterruptsCasts = currentCombat:GetInterruptCastAmount(unitName)
            playerInfo.totalCrowdControlCasts = ccTotal
            playerInfo.dispelWhat = detailsFramework.table.copy({}, utilityActorObject.dispell_oque or {})
            playerInfo.interruptWhat = detailsFramework.table.copy({}, utilityActorObject.interrompeu_oque or {})
            playerInfo.crowdControlSpells = ccUsed
        end
    end

    Details222.ArenaSummary.arenaData.endTime = time()

    local arenaDataCompressed = Details.arena_data_compressed

    local factionIndex = GetBattlefieldArenaFaction and GetBattlefieldArenaFaction() --0 for horde, 1 for alliance
    --couldn't find much documentation about custom victory, assuming is custom games and shuffles.
    local victoryStatID = C_PvP.GetCustomVictoryStatID and C_PvP.GetCustomVictoryStatID() or 0
    local hasNoWinner = victoryStatID > 0 and not (C_PvP.IsRatedSoloShuffle and C_PvP.IsRatedSoloShuffle())

    --0: PVP_SCOREBOARD_MATCH_COMPLETE, 1: PVP_MATCH_VICTORY, 2: PVP_MATCH_DEFEAT, 3: PVP_MATCH_DRAW

    local winnerStatus = 0

    if (not hasNoWinner) then
        local enemyFactionIndex = (factionIndex + 1) % 2
        local winner = C_PvP.GetActiveMatchWinner and C_PvP.GetActiveMatchWinner()

        if (winner == factionIndex) then
            winnerStatus = 1 --win
        elseif (winner == enemyFactionIndex) then
            winnerStatus = 2 --loss
        else
            winnerStatus = 3 --draw
        end
    end

    local scoresTable = {}
    local scores = GetNumBattlefieldScores and GetNumBattlefieldScores() or 0
    --print("GetNumBattlefieldScores():", scores)
    for index = 1, scores do
        scoresTable[index] = C_PvP.GetScoreInfo and C_PvP.GetScoreInfo(index) or {}
    end

    local thisArenaData = {
        scoresTable = scoresTable,
        combatId = Details222.ArenaSummary.arenaData.combatId,
        arenaName = Details222.ArenaSummary.arenaData.arenaName,
        arenaMapId = Details222.ArenaSummary.arenaData.arenaMapId,
        startTime = Details222.ArenaSummary.arenaData.startTime,
        endTime = Details222.ArenaSummary.arenaData.endTime,
        dampening = Details222.ArenaSummary.arenaData.dampening,
        combatData = Details222.ArenaSummary.arenaData.combatData,
        playerName = UnitName("player"),
        playerClass = select(2, UnitClass("player")),
        playerGuid = UnitGUID("player"),
        winnerStatus = winnerStatus, --0: no winner, 1: win, 2: loss, 3: draw
        factionIndex = factionIndex, --0 for horde, 1 for alliance
        teamInfos = teamInfos,
        isArenaSkirmish = IsArenaSkirmish and IsArenaSkirmish() or false,
        isRatedSoloShuffle = C_PvP.IsRatedSoloShuffle and C_PvP.IsRatedSoloShuffle() or false,
        isFactionalMatch = C_PvP.IsMatchFactional and C_PvP.IsMatchFactional() or false,
        isBrawlSoloShuffle = C_PvP.IsBrawlSoloShuffle and C_PvP.IsBrawlSoloShuffle() or false,
        isBrawlSoloRBG = C_PvP.IsBrawlSoloRBG and C_PvP.IsBrawlSoloRBG() or false,
        isSoloShuffle = C_PvP.IsSoloShuffle and C_PvP.IsSoloShuffle() or false,
        playerScoreInfo = C_PvP.GetScoreInfoByPlayerGuid and C_PvP.GetScoreInfoByPlayerGuid(GetPlayerGuid()) or {},
        doesMatchOutcomeAffectRating = C_PvP.DoesMatchOutcomeAffectRating and C_PvP.DoesMatchOutcomeAffectRating() or false,
        statColumns = C_PvP.GetMatchPVPStatColumns and C_PvP.GetMatchPVPStatColumns() or {},
        playerRewards = Details222.ArenaSummary.arenaData.playerRewards,
        playerPersonalRatedInfo = Details222.ArenaSummary.arenaData.playerPersonalRatedInfo,
    }

    local thisArenaDataCompressed = ArenaSummary.CompressArena(thisArenaData)

    table.insert(arenaDataCompressed, 1, thisArenaDataCompressed)

    local thisArenaHeader = {
        combatId = Details222.ArenaSummary.arenaData.combatId,
        arenaName = Details222.ArenaSummary.arenaData.arenaName,
        arenaMapId = Details222.ArenaSummary.arenaData.arenaMapId,
        startTime = Details222.ArenaSummary.arenaData.startTime,
        endTime = Details222.ArenaSummary.arenaData.endTime,
        playerName = UnitName("player"),
        playerClass = select(2, UnitClass("player")),
        playerGuid = UnitGUID("player"),
        groupMembers = {},
        winnerStatus = winnerStatus, --0: no winner, 1: win, 2: loss, 3: draw
    }

    for unitName, playerData in pairs(Details222.ArenaSummary.arenaData.combatData.groupMembers) do
        thisArenaHeader.groupMembers[unitName] = playerData.class
    end

    table.insert(Details.arena_data_headers, 1, thisArenaHeader)
    --print("ARENA HEADER ADDED amount:", #Details.arena_data_headers)
end

--PVPMatchResults.content.earningsContainer.rewardsContainer.items
--PVPMatchResults.content.earningsContainer.progressContainer.honor.button
--PVPMatchResults.content.earningsContainer.progressContainer.conquest.button

function ArenaSummary.CreateWindow() --~create
    local posY = -35
    local maxLines = 10
    local lineHeight = 22
    local windowWidth = 900
    local windowHeight = 550
    local scrollWidth = windowWidth - 32
    local scrollHeight = 306

    local backdrop_color = {.2, .2, .2, 0.2}
    local backdrop_color_on_enter = {.8, .8, .8, 0.4}

    local window = detailsFramework:CreateSimplePanel(UIParent, windowWidth, windowHeight, "Arena Summary by Details!")
    window:SetPoint("center", UIParent, "center", 0, 0)
    window:SetFrameStrata("HIGH")
    window:SetFrameLevel(10)

    window:SetFrameStrata("DIALOG")

    detailsFramework:ApplyStandardBackdrop(window)

    local arenaInfoText = window:CreateFontString("$parentArenaInfoText", "overlay", "GameFontNormal")
    arenaInfoText:SetText("")
    arenaInfoText:SetPoint("top", window, "top", 0, posY)
    window.ArenaInfoText = arenaInfoText
    detailsFramework:SetFontSize(arenaInfoText, 18)

    local arenaOutcomeText = window:CreateFontString("$parentArenaOutcomeText", "overlay", "GameFontNormal")
    arenaOutcomeText:SetText("")
    arenaOutcomeText:SetPoint("top", arenaInfoText, "bottom", 0, -10)
    detailsFramework:SetFontSize(arenaOutcomeText, 20)
    window.ArenaOutcomeText = arenaOutcomeText

    posY = posY - 128

    --header
		local headerTable = {
			{text = "", width = 22}, --1
			{text = "Name", width = 120}, --2
			{text = "Kills", width = 60}, --3
			{text = "Peak Dps", width = 90}, --4
			{text = "Dps", width = 60}, --5
            {text = "Hps", width = 60}, --6
            {text = "Dispels", width = 60}, --7
            {text = "Interrupts", width = 70}, --8
            {text = "CCs", width = 70}, --9
		}

        local headerTableHash = {
            ["Icon"] = headerTable[1],
            ["PlayerName"] = headerTable[2],
            ["KillingBlows"] = headerTable[3],
            ["PeakDamage"] = headerTable[4],
            ["Dps"] = headerTable[5],
            ["Hps"] = headerTable[6],
            ["Dispels"] = headerTable[7],
            ["Interrupts"] = headerTable[8],
            ["CrowdControlSpells"] = headerTable[9],
        }

		local headerOptions = {
			padding = 2,
		}

		local header = detailsFramework:CreateHeader(window, headerTable, headerOptions) --~header
		header:SetPoint("topleft", window, "topleft", 5, posY)

    --create a scroll area for the lines
        local refreshFunc = function(self, data, offset, totalLines) --~refresh

			for i = 1, totalLines do
				local index = i + offset

                ---@type arena_playerinfo
				local playerData = data[index]

				if (playerData) then
					local line = self:GetLine(i)

                    line.actorName = playerData.name
                    line.playerInfo = playerData

                    --set the data for the line
                    local iconTexture, iconLeft, iconTop, iconRight, iconBottom
                    local unitSpec = playerData.spec

                    --print(playerData.name, "spec:", unitSpec, "class:", playerData.class, playerData.realTimePeakDamage)

                    if (unitSpec and unitSpec > 20) then
                        iconTexture, iconLeft, iconRight, iconTop, iconBottom = Details:GetSpecIcon(unitSpec, false)
                    else
                        iconLeft, iconRight, iconTop, iconBottom, iconTexture = detailsFramework:GetClassTCoordsAndTexture(playerData.class)
                    end

                    local peakDamage = playerData.realTimePeakDamage

                    line.Icon.Icon:SetTexture(iconTexture)
                    line.Icon.Icon:SetTexCoord(iconLeft, iconRight, iconTop, iconBottom)

                    local playerNameWithOutRealm = detailsFramework:RemoveRealmName(playerData.name)
                    line.PlayerName.Text:SetText(playerNameWithOutRealm)

                    line.KillingBlows.Text:SetText(#playerData.killingBlows)
                    line.KillingBlows.value = #playerData.killingBlows

                    line.PeakDamage.Text:SetText(Details:Format(peakDamage))
                    line.PeakDamage.value = peakDamage

                    line.Dps.Text:SetText(Details:Format(playerData.dps))
                    line.Dps.value = playerData.dps

                    line.Hps.Text:SetText(Details:Format(playerData.hps))
                    line.Hps.value = playerData.hps

                    local totalDispels = playerData.totalDispels or 0
                    local totalInterrupts = playerData.totalInterrupts or 0
                    local totalCrowdControlCasts = playerData.totalCrowdControlCasts or 0

                    line.Dispels.Text:SetText(floor(totalDispels))
                    line.Dispels.value = totalDispels

                    line.Interrupts.Text:SetText(floor(totalInterrupts))
                    line.Interrupts.value = totalInterrupts

                    line.CrowdControlSpells.Text:SetText(floor(totalCrowdControlCasts))
                    line.CrowdControlSpells.value = totalCrowdControlCasts

                    --line.Rating.Text:SetText(playerData.rating)
                    --line.CrowdControlSpells.Text:SetText(table.concat(detailsFramework.table.keys(playerData.crowdControlSpells), ", ") or "None")

                    if (playerData.isFriendly) then
                        line:SetBackdropColor(0.2, 0.8, 0.2, 0.2) --green for friendly players
                    else
                        line:SetBackdropColor(0.8, 0.2, 0.2, 0.2) --red for enemies
                    end
                end
            end
        end

        local lineOnEnter = function(self) --~onenter
            local r, g, b, a = self:GetBackdropColor()
            self:SetBackdropColor(r, g, b, a + 0.2) --increase the alpha to make it more visible
        end

        local lineOnLeave = function(self) --~onleave
            local r, g, b, a = self:GetBackdropColor()
            self:SetBackdropColor(r, g, b, a - 0.2) --decrease the alpha to make it less visible
        end

        local tooltips = {
            ---@param line arenaline
            ---@param button arenaline_button
            Icon = function(line, button)
                return false
            end,

            ---@param line arenaline
            ---@param button arenaline_button
            PlayerName = function(line, button)
                return false
            end,

            ---@param line arenaline
            ---@param button arenaline_button
            KillingBlows = function(line, button)
                local playerInfo = line.playerInfo
                local killingBlows = playerInfo.killingBlows
                for i = 1, #killingBlows do
                    local thisKillingBlow = killingBlows[i]
                    local enemyName = thisKillingBlow.enemyName
                    local damageByPlayers = thisKillingBlow.damageByPlayers
                    GameCooltip:AddLine("Enemy:", detailsFramework:RemoveRealmName(enemyName))

                    local enemyPlayerInfo = ArenaSummary.GetPlayerInfoFromCurrentSelectedArenaData(enemyName)
                    if (enemyPlayerInfo) then
                        --specId
                        local specId = enemyPlayerInfo.spec
                        if (specId and specId > 20) then
                            local specIcon, left, right, top, bottom = Details:GetSpecIcon(specId, false)
                            GameCooltip:AddIcon(specIcon, 1, 2, 18, 18, left, right, top, bottom)
                        else
                            --class icon
                            local left, right, top, bottom, classIcon = detailsFramework:GetClassTCoordsAndTexture(enemyPlayerInfo.class)
                            GameCooltip:AddIcon(classIcon, 1, 2, 18, 18, left, right, top, bottom)
                        end
                    end

                    GameCooltip:AddLine("")

                    for j = 1, #damageByPlayers do
                        local playerDamage = damageByPlayers[j]
                        local damagerPlayerInfo = ArenaSummary.GetPlayerInfoFromCurrentSelectedArenaData(playerDamage.name)
                        if (damagerPlayerInfo) then
                            GameCooltip:AddLine(detailsFramework:RemoveRealmName(playerDamage.name), Details:Format(playerDamage.damage))
                            --specId
                            local specId = damagerPlayerInfo.spec
                            if (specId and specId > 20) then
                                local specIcon, left, right, top, bottom = Details:GetSpecIcon(specId, false)
                                GameCooltip:AddIcon(specIcon, 1, 1, 18, 18, left, right, top, bottom)
                            else
                                --class icon
                                local left, right, top, bottom, classIcon = detailsFramework:GetClassTCoordsAndTexture(damagerPlayerInfo.class)
                                GameCooltip:AddIcon(classIcon, 1, 1, 18, 18, left, right, top, bottom)
                            end
                        else
                            GameCooltip:AddLine(detailsFramework:RemoveRealmName(playerDamage.name), Details:Format(playerDamage.damage))
                        end
                    end
                end

                return true
            end,

            ---@param line arenaline
            ---@param button arenaline_button
            PeakDamage = function(line, button)
                return false
            end,

            ---@param line arenaline
            ---@param button arenaline_button
            Dps = function(line, button)
                local playerInfo = line.playerInfo
                local damageBySpells = playerInfo.damageDoneBySpells
                for i = 1, #damageBySpells do
                    local spellId, damage = damageBySpells[i][1], damageBySpells[i][2]
                    local spellInfo = C_Spell.GetSpellInfo(spellId)
                    if (spellInfo) then
                        GameCooltip:AddLine(spellInfo.name, Details:Format(damage))
                        GameCooltip:AddIcon(spellInfo.iconID, 1, 1, 18, 18, .1, .9, .1, .9)
                    end

                    if (i == 5) then
                        break
                    end
                end

                return true
            end,

            ---@param line arenaline
            ---@param button arenaline_button
            Hps = function(line, button)
                local playerInfo = line.playerInfo
                local healingBySpells = playerInfo.healingDoneBySpells
                for i = 1, #healingBySpells do
                    local spellId, healing = healingBySpells[i][1], healingBySpells[i][2]
                    if (healing > 0) then
                        local spellInfo = C_Spell.GetSpellInfo(spellId)
                        if (spellInfo) then
                            GameCooltip:AddLine(spellInfo.name, Details:Format(healing))
                            GameCooltip:AddIcon(spellInfo.iconID, 1, 1, 18, 18, .1, .9, .1, .9)
                        end
                    end

                    if (i == 5) then
                        break
                    end
                end

                return true
            end,

            ---@param line arenaline
            ---@param button arenaline_button
            Dispels = function(line, button)
            end,

            ---@param line arenaline
            ---@param button arenaline_button
            Interrupts = function(line, button)
            end,

            ---@param line arenaline
            ---@param button arenaline_button
            CrowdControl = function(line, button)
            end,
        }

        local emptyFunction = function() end

        function ArenaSummary.SetFontSettings()
            for i = 1, #ArenaSummary.Lines do
                local line = ArenaSummary.Lines[i]
                for j = 1, #line.Buttons do
                    local button = line.Buttons[j]
                    detailsFramework:SetFontSize(button.Text, 10)
                end
            end
        end

        ---@class arenaline_button : df_button
        ---@field Icon texture
        ---@field Text fontstring
        ---@field type string
        ---@field value number

        local buttonOnEnter = function(self)
            local button = self:GetObject()
            local type = button.type

            if (button.value == 0) then
                return --no tooltip for this button
            end

            local tooltipFunc = tooltips[type]
            if (tooltipFunc) then
                GameCooltip:Preset(2)
                GameCooltip:SetOwner(self, "bottom", "top", 0, 5)
                local line = button:GetParent()
                if (tooltipFunc(line, button)) then
                    GameCooltip:Show()
                end
            end
        end

        local buttonOnLeave = function(self)
            GameCooltip:Hide()
        end

        --this button is used to give a tooltip when the player hover over the value
        local createLineColumnButton = function(line, name)
            --local button = CreateFrame("button", "$parentColumnButton" .. name, line, "BackdropTemplate")
            local callbackParam1 = name
            ---@type arenaline_button
            local button = detailsFramework:CreateButton(line, emptyFunction, 100, 20, "", callbackParam1, nil, nil, nil, "$parent" .. name)
            button.type = name
            button.value = 0

            --icon
            local icon = button:CreateTexture("$parentIcon", "overlay")
            icon:SetSize(lineHeight - 2, lineHeight - 2)
            icon:SetPoint("left", button.widget, "left", 2, 0)
            button.Icon = icon

            --text
			local text = line:CreateFontString("$parentText", "overlay", "GameFontNormal")
            text:SetPoint("left", button.widget, "left", 2, 0)
            button.Text = text

            button:SetScript("OnEnter", buttonOnEnter)
            button:SetScript("OnLeave", buttonOnLeave)
            button:SetPropagateMouseMotion(true)

            return button
        end

        ---@class arenaline : button
        ---@field Buttons arenaline_button[]
        ---@field actorName string
        ---@field playerInfo arena_playerinfo

        ArenaSummary.Lines = {}

        local createLineFunc = function(self, index)
			local line = CreateFrame("button", "$parentLine" .. index, self,"BackdropTemplate")
			line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(lineHeight+1)) - 1)
			line:SetSize(scrollWidth - 2, lineHeight)

            ArenaSummary.Lines[index] = line

            line.Buttons = {}

			line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor(unpack(backdrop_color))

			-- ~createline --~line
			detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

			line:SetScript("OnEnter", lineOnEnter)
			line:SetScript("OnLeave", lineOnLeave)

			--icon
			local icon = createLineColumnButton(line, "Icon")
            icon:SetWidth(headerTableHash.Icon.width - 2)

			--player name
            local playerName = createLineColumnButton(line, "PlayerName")
            playerName:SetWidth(headerTableHash.PlayerName.width - 2)

            --final hits
            local killingBlows = createLineColumnButton(line, "KillingBlows")
            killingBlows:SetWidth(headerTableHash.KillingBlows.width - 2)

            --peak damage
            local peakDamage = createLineColumnButton(line, "PeakDamage")
            peakDamage:SetWidth(headerTableHash.PeakDamage.width - 2)

            --dps
            local dps = createLineColumnButton(line, "Dps")
            dps:SetWidth(headerTableHash.Dps.width - 2)

            --hps
            local hps = createLineColumnButton(line, "Hps")
            hps:SetWidth(headerTableHash.Hps.width - 2)

            --peak healing
            local dispels = createLineColumnButton(line, "Dispels")
            dispels:SetWidth(headerTableHash.Dispels.width - 2)

            --interrupts
            local interrupts = createLineColumnButton(line, "Interrupts")
            interrupts:SetWidth(headerTableHash.Interrupts.width - 2)

            --crowd control spells
            local ccs = createLineColumnButton(line, "CrowdControlSpells")
            ccs:SetWidth(headerTableHash.CrowdControlSpells.width - 2)

            --rating
            --local rating = createLineColumnButton(line, "Rating")

            line.Buttons[#line.Buttons+1] = icon
            line.Buttons[#line.Buttons+1] = playerName
            line.Buttons[#line.Buttons+1] = killingBlows
            line.Buttons[#line.Buttons+1] = peakDamage
            line.Buttons[#line.Buttons+1] = dps
            line.Buttons[#line.Buttons+1] = hps
            line.Buttons[#line.Buttons+1] = dispels
            line.Buttons[#line.Buttons+1] = interrupts
            line.Buttons[#line.Buttons+1] = ccs
            --line.Buttons[#line.Buttons+1] = rating

            line:AddFrameToHeaderAlignment(icon)
            line:AddFrameToHeaderAlignment(playerName)
            line:AddFrameToHeaderAlignment(killingBlows)
            line:AddFrameToHeaderAlignment(peakDamage)
            line:AddFrameToHeaderAlignment(dps)
            line:AddFrameToHeaderAlignment(hps)
            line:AddFrameToHeaderAlignment(dispels)
            line:AddFrameToHeaderAlignment(interrupts)
            line:AddFrameToHeaderAlignment(ccs)
            --line:AddFrameToHeaderAlignment(rating)

            line:AlignWithHeader(header, "left")

            line.Icon = icon
            line.PlayerName = playerName
            line.KillingBlows = killingBlows
            line.PeakDamage = peakDamage
            line.Dps = dps
            line.Hps = hps
            line.Dispels = dispels
            line.Interrupts = interrupts
            line.CrowdControlSpells = ccs
            --line.Rating = rating

            return line
        end

        local arenaPlayersScroll = detailsFramework:CreateScrollBox(window, "$parentScroll", refreshFunc, {}, scrollWidth, scrollHeight, maxLines, lineHeight)
        arenaPlayersScroll:SetPoint("topleft", header, "bottomleft", 0, -5)
        window.ArenaPlayersScroll = arenaPlayersScroll

        detailsFramework:ReskinSlider(arenaPlayersScroll)

        function ArenaSummary.SetSelectedArenaIndex(index)
            Details.arena_data_index_selected = index
            arenaPlayersScroll:RefreshScroll()
        end

        function ArenaSummary.GetSelectedArenaIndex()
            return Details.arena_data_index_selected or 1
        end

        ---@param playerName string
        ---@return arena_playerinfo?
        function ArenaSummary.GetPlayerInfoFromCurrentSelectedArenaData(playerName)
            local arenaData = ArenaSummary.CurrentArenaData

            if (not arenaData) then
                --print("ArenaSummary: No arena data found.")
                return nil
            end

            local playersInTheArena = arenaData.combatData.groupMembers
            if (not playersInTheArena) then
                --print("ArenaSummary: No players found in the arena data.")
                return nil
            end

            return playersInTheArena[playerName]
        end

        function arenaPlayersScroll:RefreshScroll()
            local playersData = {}

            local index = Details.arena_data_index_selected or 1
            index = 1

            local arenaData = ArenaSummary.UncompressArena(index)
            ArenaSummary.CurrentArenaData = arenaData

            --dumpt(arenaData)

            if (not arenaData) then
                --print("ArenaSummary: No arena data found for index " .. Details.arena_data_index_selected)
                return
            end

            local playersInTheArena = arenaData.combatData.groupMembers
            --iterate through the players in the arena and create lines for them
            for unitName, playerData in pairs(playersInTheArena) do
                playersData[#playersData+1] = playerData
            end

            arenaPlayersScroll:SetData(playersData)
            arenaPlayersScroll:Refresh()

            local elapsedTime = arenaData.endTime - arenaData.startTime
            window.ArenaInfoText:SetText(arenaData.arenaName .. " ".. detailsFramework:IntegerToTimer(elapsedTime) .. " - " .. arenaData.dampening .. "% Dampening")

--print("arenaData.winnerStatus", arenaData.winnerStatus)
--dumpt(arenaData)

            window.ArenaOutcomeText:SetText(PVP_SCOREBOARD_MATCH_COMPLETE or "Match Completed")
            if (arenaData.winnerStatus == 1) then
                window.ArenaOutcomeText:SetText(PVP_MATCH_VICTORY or "VICTORY")
            elseif (arenaData.winnerStatus == 2) then
                window.ArenaOutcomeText:SetText(PVP_MATCH_DEFEAT or "DEFEAT")
            elseif (arenaData.winnerStatus == 3) then
                window.ArenaOutcomeText:SetText(PVP_MATCH_DRAW or "DRAW")
            end
        end

		--create lines
		for i = 1, maxLines do
			arenaPlayersScroll:CreateLine(createLineFunc)
		end

        --queue as team button
        local requeueButton = detailsFramework:CreateButton(window, function(self)
            self:Disable()
            RequeueSkirmish()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        end, 140, 20, "Queue as Team")
        requeueButton:SetPoint("bottom", window, "bottom", -100, 10)
        requeueButton.fontsize = 12
        requeueButton:SetTemplate("OPAQUE_DARK")
        window.RequeueButton = requeueButton

        --leave button
        local leaveButton = detailsFramework:CreateButton(window, function()
            if (IsInLFDBattlefield()) then
                ConfirmOrLeaveLFGParty()
            else
                ConfirmOrLeaveBattlefield()
            end

            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        end, 140, 20, "Leave Arena")
        leaveButton:SetPoint("bottom", window, "bottom", 100, 10)
        leaveButton.fontsize = 12
        leaveButton:SetTemplate("OPAQUE_DARK")
        window.LeaveButton = leaveButton

    return window
end

function ArenaSummary.UncompressArena(headerIndex)
    assert(type(headerIndex) == "number", "UncompressedArena(headerIndex): headerIndex must be a number.")
    assert(C_EncodingUtil, "C_EncodingUtil is nil")

    local compressedArenas = Details.arena_data_compressed
    --print("##:", #compressedArenas, "headerIndex:", headerIndex)

    local arenaData = compressedArenas[headerIndex]
    if (not arenaData) then
        print("not found arenaData for headerIndex: " .. headerIndex)
        return nil
    end

    local dataDecoded = C_EncodingUtil.DecodeBase64(arenaData)
    if (not dataDecoded) then
        print("UncompressedRun(headerIndex): C_EncodingUtil.DecodeBase64 failed")
        return nil
    end

    local dataDecompressed = C_EncodingUtil.DecompressString(dataDecoded, Enum.CompressionMethod.Deflate)
    if (not dataDecompressed) then
        print("UncompressedRun(headerIndex): C_EncodingUtil.DecompressString failed")
        return nil
    end

    local arenaInfo = C_EncodingUtil.DeserializeCBOR(dataDecompressed)
    if (not arenaInfo) then
        print("UncompressedRun(headerIndex): C_EncodingUtil.DeserializeCBOR failed")
        return nil
    end

    return arenaInfo
end

function ArenaSummary.CompressArena(arenaData)
    if (not arenaData) then
        --private.log("CompressRun: arenaData is nil")
        return false
    end

    assert(C_EncodingUtil, "C_EncodingUtil is nil")

    local dataSerialized = C_EncodingUtil.SerializeCBOR(arenaData)
    if (not dataSerialized) then
        --private.log("CompressRun: C_EncodingUtil.SerializeCBOR failed")
        return false
    end

    local dataCompressed = C_EncodingUtil.CompressString(dataSerialized, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
    if (not dataCompressed) then
        --private.log("CompressRun: C_EncodingUtil.CompressString failed")
        return false
    end

    local dataEncoded = C_EncodingUtil.EncodeBase64(dataCompressed)
    if (not dataEncoded) then
        --private.log("CompressRun: C_EncodingUtil.EncodeBase64 failed")
        return false
    end

    return dataEncoded
end