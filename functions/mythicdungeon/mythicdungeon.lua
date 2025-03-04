
local Details = _G.Details
local DF = _G.DetailsFramework
local addonName, Details222 = ...
local _

local time = time
local C_Timer = _G.C_Timer
local unpack = _G.unpack
local GetTime = _G.GetTime

local GetInstanceInfo = _G.GetInstanceInfo

local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

--data for the current mythic + dungeon
Details.MythicPlus = {
    RunID = 0,
}

local mythicDungeonFrames = Details222.MythicPlus.Frames
local mythicDungeonCharts = Details:CreateEventListener()
Details222.MythicPlus.Charts.Listener = mythicDungeonCharts

-- ~mythic ~dungeon
local DetailsMythicPlusFrame = _G.CreateFrame("frame", "DetailsMythicPlusFrame", UIParent)
DetailsMythicPlusFrame.DevelopmentDebug = false

--disabling the mythic+ feature if the user is playing in wow classic
if (not DF.IsTimewalkWoW()) then
    DetailsMythicPlusFrame:RegisterEvent("CHALLENGE_MODE_START")
    DetailsMythicPlusFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    DetailsMythicPlusFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    DetailsMythicPlusFrame:RegisterEvent("ENCOUNTER_END")
    DetailsMythicPlusFrame:RegisterEvent("START_TIMER")
end

function Details222.MythicPlus.LogStep(log)
    local today = date("%d/%m/%y %H:%M:%S")
    table.insert(Details.mythic_plus_log, 1, today .. "|" .. log)
    tremove(Details.mythic_plus_log, 50)
end

function DetailsMythicPlusFrame.BossDefeated(this_is_end_end, encounterID, encounterName, difficultyID, raidSize, endStatus) --hold your breath and count to ten
    --this function is called right after defeat a boss inside a mythic dungeon
    --it comes from details! control leave combat
    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("Details!", "BossDefeated() > boss defeated | SegmentID:", Details.MythicPlus.SegmentID, " | mapID:", Details.MythicPlus.DungeonID)
    end

    --local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
    Details222.MythicPlus.OnBossDefeated(encounterID, encounterName) --data capture

    --increase the segment number for the mythic run
    Details.MythicPlus.SegmentID = Details.MythicPlus.SegmentID + 1

    --register the time when the last boss has been killed (started a clean up for the next trash)
    Details.MythicPlus.PreviousBossKilledAt = time()

    --update the saved table inside the profile
    Details:UpdateState_CurrentMythicDungeonRun(true, Details.MythicPlus.SegmentID, Details.MythicPlus.PreviousBossKilledAt)
end

--this function is called 2 seconds after the event COMBAT_MYTHICDUNGEON_END
function DetailsMythicPlusFrame.MythicDungeonFinished(bFromZoneLeft)
    if (DetailsMythicPlusFrame.IsDoingMythicDungeon) then
        if (DetailsMythicPlusFrame.DevelopmentDebug) then
            print("Details!", "MythicDungeonFinished() > the dungeon was a Mythic+ and just ended.")
        end

        DetailsMythicPlusFrame.IsDoingMythicDungeon = false
        Details.MythicPlus.Started = false
        Details.MythicPlus.EndedAt = time()-1.9

        Details:UpdateState_CurrentMythicDungeonRun()

        --at this point, details! should not be in combat, but if something triggered a combat start, just close the combat right away
        if (Details.in_combat) then
            if (DetailsMythicPlusFrame.DevelopmentDebug) then
                print("Details!", "MythicDungeonFinished() > was in combat, calling SairDoCombate():", InCombatLockdown())
            end
            Details:SairDoCombate()
            Details222.MythicPlus.LogStep("MythicDungeonFinished() | Details was in combat.")
        end

        --check if there is trash segments after the last boss. need to merge these segments with the trash segment of the last boss
        local bCanMergeBossTrash = Details.mythic_plus.merge_boss_trash
        Details222.MythicPlus.LogStep("MythicDungeonFinished() | merge_boss_trash = " .. (bCanMergeBossTrash and "true" or "false"))

        --check if there's trash after the last boss, if does, merge it with the trash of the last boss defeated
        if (bCanMergeBossTrash and not Details.MythicPlus.IsRestoredState) then -- and not bFromZoneLeft
            --is the current combat not a boss fight?
            --this mean a combat was opened after the last boss of the dungeon was killed
            if (not Details.tabela_vigente.is_boss and Details.tabela_vigente:GetCombatTime() > 5) then
                if (DetailsMythicPlusFrame.DevelopmentDebug) then
                    print("Details!", "MythicDungeonFinished() > the last combat isn't a boss fight, might have trash after bosses done.")
                end
                Details222.MythicPlus.MergeTrashAfterLastBoss()
            end
        end

        --merge segments
        if (Details.mythic_plus.make_overall_when_done and not Details.MythicPlus.IsRestoredState) then -- and not bFromZoneLeft
            if (DetailsMythicPlusFrame.DevelopmentDebug) then
                print("Details!", "MythicDungeonFinished() > not in combat, creating overall segment now")
            end
            DetailsMythicPlusFrame.MergeSegmentsOnEnd()
        end

        Details.MythicPlus.IsRestoredState = nil

		--the run is valid, schedule to open the chart window
		Details.mythic_plus.delay_to_show_graphic = 1
        if (not bFromZoneLeft) then
		    C_Timer.After(Details.mythic_plus.delay_to_show_graphic, mythicDungeonFrames.ShowEndOfMythicPlusPanel)
        end

        --shutdown parser for a few seconds to avoid opening new segments after the run ends
        if (not bFromZoneLeft) then
            Details:CaptureSet(false, "damage", false, 15)
            Details:CaptureSet(false, "energy", false, 15)
            Details:CaptureSet(false, "aura", false, 15)
            Details:CaptureSet(false, "energy", false, 15)
            Details:CaptureSet(false, "spellcast", false, 15)
        end
    end
end

function DetailsMythicPlusFrame.MythicDungeonStarted()
    --flag as a mythic dungeon
    DetailsMythicPlusFrame.IsDoingMythicDungeon = true

    --this counter is individual for each character
    Details.mythic_dungeon_id = Details.mythic_dungeon_id + 1

    local mythicLevel = C_ChallengeMode.GetActiveKeystoneInfo()
    local zoneName, _, _, _, _, _, _, currentZoneID = GetInstanceInfo()

    local mapID = C_Map.GetBestMapForUnit("player")

    if (not mapID) then
        return
    end

    local ejID = Details:GetInstanceEJID(mapID)

    --setup the mythic run info
    Details.MythicPlus.Started = true
    Details.MythicPlus.DungeonName = zoneName
    Details.MythicPlus.DungeonID = currentZoneID

    --Details:Msg("(debug) mythic dungeon start time: ", time()+9.7, "time now:", time(), "diff:", time()+9.7-time())

    Details.MythicPlus.StartedAt = time()+9.7 --there's the countdown timer of 10 seconds
    Details.MythicPlus.EndedAt = nil --reset
    Details.MythicPlus.SegmentID = 1
    Details.MythicPlus.Level = mythicLevel
    Details.MythicPlus.ejID = ejID
    Details.MythicPlus.PreviousBossKilledAt = time()

    Details:SaveState_CurrentMythicDungeonRun(Details.mythic_dungeon_id, zoneName, currentZoneID, time()+9.7, 1, mythicLevel, ejID, time())

    local name, groupType, difficultyID, difficult = GetInstanceInfo()
    if (groupType == "party" and Details.overall_clear_newchallenge) then
        Details.historico:ResetOverallData()
        Details:Msg("the overall data has been reset.") --localize-me

        if (Details.debug) then
            Details:Msg("(debug) timer is for a mythic+ dungeon, overall has been reseted.")
        end
    end

    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("Details!", "MythicDungeonStarted() > State set to Mythic Dungeon, new combat starting in 10 seconds.")
    end
end

function DetailsMythicPlusFrame.OnChallengeModeStart()
    --is this a mythic dungeon?
    local _, _, difficultyID, _, _, _, _, currentZoneID = GetInstanceInfo()

    if (difficultyID == 8) then
        --start the dungeon on Details!
        DetailsMythicPlusFrame.MythicDungeonStarted()
        Details222.MythicPlus.LogStep("OnChallengeModeStart()")
    else
        --print("D! mythic dungeon was already started!")
        --from zone changed
        local mythicLevel = C_ChallengeMode.GetActiveKeystoneInfo()
        local zoneName, _, _, _, _, _, _, currentZoneID = GetInstanceInfo()

        if (not Details.MythicPlus.Started and Details.MythicPlus.DungeonID == currentZoneID and Details.MythicPlus.Level == mythicLevel) then
            Details.MythicPlus.Started = true
            Details.MythicPlus.EndedAt = nil
            Details.mythic_dungeon_currentsaved.started = true
            DetailsMythicPlusFrame.IsDoingMythicDungeon = true
            --print("D! mythic dungeon was NOT already started! debug 2")
        end
    end
end

--make an event listener to sync combat data
DetailsMythicPlusFrame.EventListener = Details:CreateEventListener()
DetailsMythicPlusFrame.EventListener:RegisterEvent("COMBAT_ENCOUNTER_START")
DetailsMythicPlusFrame.EventListener:RegisterEvent("COMBAT_ENCOUNTER_END")
DetailsMythicPlusFrame.EventListener:RegisterEvent("COMBAT_PLAYER_ENTER")
DetailsMythicPlusFrame.EventListener:RegisterEvent("COMBAT_PLAYER_LEAVE")
DetailsMythicPlusFrame.EventListener:RegisterEvent("COMBAT_MYTHICDUNGEON_START")
DetailsMythicPlusFrame.EventListener:RegisterEvent("COMBAT_MYTHICDUNGEON_END")
DetailsMythicPlusFrame.EventListener:RegisterEvent("COMBAT_MYTHICPLUS_OVERALL_READY")

function DetailsMythicPlusFrame.EventListener.OnDetailsEvent(contextObject, event, ...)
    --these events triggers within Details control functions, they run exactly after details! creates or close a segment
    if (event == "COMBAT_PLAYER_ENTER") then


    elseif (event == "COMBAT_PLAYER_LEAVE") then
        --ignore the event if ignoring mythic dungeon special treatment
        if (Details.streamer_config.disable_mythic_dungeon) then
            return
        end

        if (DetailsMythicPlusFrame.IsDoingMythicDungeon) then
            local combatObject = ...

            if (combatObject.is_boss) then
                if (not combatObject.is_boss.killed) then
                    local encounterName = combatObject.is_boss.encounter
                    local zoneName = combatObject.is_boss.zone
                    local mythicLevel = C_ChallengeMode.GetActiveKeystoneInfo()

                    local currentCombat = Details:GetCurrentCombat()

                    --just in case the combat get tagged as boss fight
                    combatObject.is_boss = nil

                    --tag the combat as mythic dungeon trash
                    local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()

                    ---@type mythicdungeoninfo
                    local mythicPlusInfo = {
                        ZoneName = Details.MythicPlus.DungeonName or zoneName,
                        MapID = Details.MythicPlus.DungeonID or instanceMapID,
                        Level = Details.MythicPlus.Level,
                        EJID = Details.MythicPlus.ejID,
                        RunID = Details.mythic_dungeon_id,
                        StartedAt = time() - currentCombat:GetCombatTime(),
                        EndedAt = time(),
                        SegmentID = Details.MythicPlus.SegmentID, --segment number within the dungeon
                        OverallSegment = false,
                        SegmentType = DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE,
                        SegmentName = (encounterName or Loc["STRING_UNKNOW"]) .. " (" .. string.lower(_G["BOSS"]) .. ")"
                    }

                    combatObject.is_mythic_dungeon = mythicPlusInfo

                    Details222.MythicPlus.LogStep("COMBAT_PLAYER_LEAVE | wiped on boss | key level: | " .. mythicLevel .. " | " .. (encounterName or "") .. " " .. zoneName)
                else
                    DetailsMythicPlusFrame.BossDefeated(false, combatObject.is_boss.id, combatObject.is_boss.name, combatObject.is_boss.diff, 5, 1)
                end
            end

        end

    elseif (event == "COMBAT_ENCOUNTER_START") then
        --ignore the event if ignoring mythic dungeon special treatment
        if (Details.streamer_config.disable_mythic_dungeon) then
            Details222.MythicPlus.LogStep("COMBAT_ENCOUNTER_START | streamer_config.disable_mythic_dungeon is true and the code cannot continue.")
            return
        end

        local encounterID, encounterName, difficultyID, raidSize, endStatus = ...
        --nothing

    elseif (event == "COMBAT_ENCOUNTER_END") then
        --ignore the event if ignoring mythic dungeon special treatment
        if (Details.streamer_config.disable_mythic_dungeon) then
            Details222.MythicPlus.LogStep("COMBAT_ENCOUNTER_END | streamer_config.disable_mythic_dungeon is true and the code cannot continue.")
            return
        end

        local encounterID, encounterName, difficultyID, raidSize, endStatus = ...
        --nothing

    elseif (event == "COMBAT_MYTHICDUNGEON_START") then
        local lowerInstance = Details:GetLowerInstanceNumber()
        if (lowerInstance) then
            lowerInstance = Details:GetInstance(lowerInstance)
            if (lowerInstance) then
                C_Timer.After(3, function()
                    --if (lowerInstance:IsEnabled()) then
                        --todo, need localization
                        --lowerInstance:InstanceAlert("Details!" .. " " .. "Damage" .. " " .. "Meter", {[[Interface\AddOns\Details\images\minimap]], 16, 16, false}, 3, {function() end}, false, true)
                    --end
                end)
            end
        end

        --ignore the event if ignoring mythic dungeon special treatment
        if (Details.streamer_config.disable_mythic_dungeon) then
            return
        end

        --reset spec cache if broadcaster requested
        if (Details.streamer_config.reset_spec_cache) then
            Details:Destroy(Details.cached_specs)
        end

        C_Timer.After(0.25, DetailsMythicPlusFrame.OnChallengeModeStart)

        --debugging
        local mPlusSettings = Details.mythic_plus
        local result = ""
        for key, value in pairs(Details.mythic_plus) do
			if (type(value) ~= "table") then
				result = result .. key .. " = " .. tostring(value) .. " | "
			end
		end

        local mythicLevel = C_ChallengeMode.GetActiveKeystoneInfo()
        local zoneName, _, _, _, _, _, _, currentZoneID = GetInstanceInfo()
		Details222.MythicPlus.LogStep("COMBAT_MYTHICDUNGEON_START | settings: " .. result .. " | level: " .. mythicLevel .. " | zone: " .. zoneName .. " | zoneId: " .. currentZoneID)

    elseif (event == "COMBAT_MYTHICDUNGEON_END") then
        --ignore the event if ignoring mythic dungeon special treatment
        if (Details.streamer_config.disable_mythic_dungeon) then
            Details222.MythicPlus.LogStep("COMBAT_MYTHICDUNGEON_END | streamer_config.disable_mythic_dungeon is true and the code cannot continue.")
            return
        end

        --delay to wait the encounter_end trigger first
        --assuming here the party cleaned the mobs kill objective before going to kill the last boss
        C_Timer.After(2, DetailsMythicPlusFrame.MythicDungeonFinished)

    elseif (event == "COMBAT_MYTHICPLUS_OVERALL_READY") then
        DetailsMythicPlusFrame.SaveMythicPlusStats(...)
    end
end

local playerLeftDungeonZoneTimer_Callback = function()
    if (DetailsMythicPlusFrame.IsDoingMythicDungeon) then
        local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo()
        if (currentZoneID ~= Details.MythicPlus.DungeonID) then
            Details222.MythicPlus.LogStep("ZONE_CHANGED_NEW_AREA | player has left the dungeon and Details! finished the dungeon because of that.")

            --send mythic dungeon end event
            Details:SendEvent("COMBAT_MYTHICDUNGEON_END") --on leave dungeon

            --finish the segment
            DetailsMythicPlusFrame.BossDefeated(true)

            --finish the mythic run
            DetailsMythicPlusFrame.MythicDungeonFinished(true)

            DetailsMythicPlusFrame.ZoneLeftTimer = nil
        end
    end
end

DetailsMythicPlusFrame:SetScript("OnEvent", function(_, event, ...)
    if (event == "START_TIMER") then
        --DetailsMythicPlusFrame.LastTimer = GetTime()

    elseif (event == "ZONE_CHANGED_NEW_AREA") then
        if (DetailsMythicPlusFrame.IsDoingMythicDungeon) then
            if (DetailsMythicPlusFrame.DevelopmentDebug) then
                print("Details!", event, ...)
                print("Zone changed and is Doing Mythic Dungeon")
            end

            --ignore the event if ignoring mythic dungeon special treatment
            if (Details.streamer_config.disable_mythic_dungeon) then
                Details222.MythicPlus.LogStep("ZONE_CHANGED_NEW_AREA | streamer_config.disable_mythic_dungeon is true and the code cannot continue.")
                return
            end

            local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo()
            if (currentZoneID ~= Details.MythicPlus.DungeonID) then
                if (DetailsMythicPlusFrame.DevelopmentDebug) then
                    print("Zone changed and the zone is different than the dungeon")
                end

                --player left the dungeon zone, start a timer to check if the player will return to the dungeon
                if (DetailsMythicPlusFrame.DevelopmentDebug) then
                    print("Details!", "ZONE_CHANGED_NEW_AREA | player left the dungeon zone, return to dungeon timer started.")
                end

                --check if the timer already exists, if does, ignore this event
                if (DetailsMythicPlusFrame.ZoneLeftTimer and not DetailsMythicPlusFrame.ZoneLeftTimer:IsCancelled()) then
                    return
                end

                DetailsMythicPlusFrame.ZoneLeftTimer = C_Timer.NewTimer(40, playerLeftDungeonZoneTimer_Callback)
            end
        end
    end
end)

---@param combatObject combat
function DetailsMythicPlusFrame.SaveMythicPlusStats(combatObject)
    local completionInfo = C_ChallengeMode.GetChallengeCompletionInfo()
    local mapChallengeModeID = C_ChallengeMode.GetActiveChallengeMapID()
    local PrimaryAffix = 0
    local upgradeMembers = completionInfo.members
    local mythicLevel = completionInfo.level
    local time = completionInfo.time
    local onTime = completionInfo.onTime
    local keystoneUpgradeLevels = completionInfo.keystoneUpgradeLevels
    local practiceRun = completionInfo.practiceRun
    local isAffixRecord = completionInfo.isAffixRecord
    local isMapRecord = completionInfo.isMapRecord
    local isEligibleForScore = completionInfo.isEligibleForScore
    local oldDungeonScore = completionInfo.oldOverallDungeonScore
    local newDungeonScore = completionInfo.newOverallDungeonScore

    if (mapChallengeModeID) then
        local statName = "mythicdungeoncompletedDF2"

        ---@type table<challengemapid, table>
        local mythicDungeonRuns = Details222.PlayerStats:GetStat(statName)
        if (not mythicDungeonRuns) then
            mythicDungeonRuns = mythicDungeonRuns or {}
        end

        --mythicDungeonRuns [mapChallengeModeID] [mythicLevel]

        ---@class mythicplusrunstats
        ---@field onTime boolean
        ---@field deaths number
        ---@field date number
        ---@field affix number
        ---@field runTime milliseconds
        ---@field combatTime number

        ---@class mythicplusstats
        ---@field completed number
        ---@field totalTime number
        ---@field minTime number
        ---@field history mythicplusrunstats[]

        ---@type table<keylevel, mythicplusstats>
        local statsForDungeon = mythicDungeonRuns[mapChallengeModeID]
        if (not statsForDungeon) then
            statsForDungeon = {}
            mythicDungeonRuns[mapChallengeModeID] = statsForDungeon
        end

        ---@type mythicplusstats
        local statsForLevel = statsForDungeon[mythicLevel]
        if (not statsForLevel) then
            ---@type mythicplusstats
            statsForLevel = {
                completed = 0,
                totalTime = 0,
                minTime = 0,
                history = {},
            }
            statsForDungeon[mythicLevel] = statsForLevel
        end

        statsForLevel.completed = (statsForLevel.completed or 0) + 1
        statsForLevel.totalTime = (statsForLevel.totalTime or 0) + time
        if (not statsForLevel.minTime or time < statsForLevel.minTime) then
            statsForLevel.minTime = time
        end

        statsForLevel.history = statsForLevel.history or {}

        local amountDeaths = C_ChallengeMode.GetDeathCount() or 0

        ---@type mythicplusrunstats
        local runStats = {
            date = _G.time(),
            runTime = math.floor(time/1000),
            onTime = onTime,
            deaths = amountDeaths,
            affix = PrimaryAffix,
            combatTime = combatObject:GetCombatTime(),
        }

        table.insert(statsForLevel.history, runStats)

        Details222.PlayerStats:SetStat("mythicdungeoncompletedDF2", mythicDungeonRuns)
    end
end

