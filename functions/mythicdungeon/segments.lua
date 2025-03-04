
local Details = _G.Details
local addonName, Details222 = ...
local detailsFramework = DetailsFramework
local _

local GetTime = GetTime
local GetInstanceInfo = GetInstanceInfo
local time = time
local C_ChallengeMode = C_ChallengeMode
local InCombatLockdown = InCombatLockdown

local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")
--[[
    all mythic segments have:
        .is_mythic_dungeon_segment = true
        .is_mythic_dungeon_run_id = run id from details.profile.mythic_dungeon_id
--]]

local DetailsMythicPlusFrame = _G["DetailsMythicPlusFrame"]

--empty
function Details222.MythicPlus.OnMythicDungeonFinished(encounterID, encounterName)end

function Details222.MythicPlus.OnBossDefeated(encounterID, encounterName)
    local currentCombat = Details:GetCurrentCombat()

    --add the mythic dungeon info to the combat
    currentCombat.is_mythic_dungeon = {
        StartedAt = Details.MythicPlus.StartedAt, --the start of the run
        EndedAt = time(), --when the boss got killed
        SegmentID = Details.MythicPlus.SegmentID, --segment number within the dungeon
        EncounterID = encounterID,
        EncounterName = encounterName or Loc["STRING_UNKNOW"],
        RunID = Details.mythic_dungeon_id,
        ZoneName = Details.MythicPlus.DungeonName,
        MapID = Details.MythicPlus.DungeonID,
        OverallSegment = false,
        Level = Details.MythicPlus.Level,
        EJID = Details.MythicPlus.ejID,
        SegmentType = DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS,
        SegmentName = (encounterName or Loc["STRING_UNKNOW"]) .. " (" .. string.lower(_G["BOSS"]) .. ")"
    }

    local mythicLevel = C_ChallengeMode.GetActiveKeystoneInfo()
    local mPlusTable = currentCombat.is_mythic_dungeon

    --logs
    Details222.MythicPlus.LogStep("BossDefeated | key level: | " .. mythicLevel .. " | " .. (mPlusTable.EncounterName or "") .. " | " .. (mPlusTable.ZoneName or ""))

    --check if need to merge the trash for this boss
    if (Details.mythic_plus.merge_boss_trash and not Details.MythicPlus.IsRestoredState) then
        --store on an table all segments which should be merged
        local segmentsToMerge = DetailsMythicPlusFrame.TrashMergeScheduled or {}

        --table with all past semgnets
        local segmentsTable = Details:GetCombatSegments()

        --iterate among segments
        for i = 1, 25 do --from the newer combat to the oldest
            ---@type combat
            local pastCombat = segmentsTable[i]
            --does the combat exists
            if (pastCombat and not pastCombat._trashoverallalreadyadded) then
                --is the combat a mythic segment from this run?
                local bIsMythicSegment, SegmentID = pastCombat:IsMythicDungeon()
                if (bIsMythicSegment and SegmentID == Details.mythic_dungeon_id) then
                    local combatType = pastCombat:GetCombatType()
                    if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH or combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE) then
                        table.insert(segmentsToMerge, pastCombat)
                    else
                    end
                else
                end
            else
            end
        end

        --add encounter information
        segmentsToMerge.EncounterID = encounterID
        segmentsToMerge.EncounterName = encounterName
        segmentsToMerge.PreviousBossKilledAt = Details.MythicPlus.PreviousBossKilledAt

        --reduce this boss encounter time from the trash lenght time, since the boss doesn't count towards the time spent cleaning trash
        segmentsToMerge.LastBossKilledAt = time() - currentCombat:GetCombatTime()

        DetailsMythicPlusFrame.TrashMergeScheduled = segmentsToMerge

        if (DetailsMythicPlusFrame.DevelopmentDebug) then
            print("Details!", "BossDefeated() > not in combat, merging trash now")
        end
        --merge the trash clean up
        DetailsMythicPlusFrame.MergeTrashCleanup()
    end
end

--after each boss fight, if enalbed on settings, create an extra segment with all trash segments from the boss just killed
--this function does not have agency over what segments to merge, it just receives a list of segments to merge
function DetailsMythicPlusFrame.MergeTrashCleanup()
    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("Details!", "MergeTrashCleanup() > running", DetailsMythicPlusFrame.TrashMergeScheduled and #DetailsMythicPlusFrame.TrashMergeScheduled)
    end

    local segmentsToMerge = DetailsMythicPlusFrame.TrashMergeScheduled

    --table exists and there's at least one segment
    if (segmentsToMerge and segmentsToMerge[1]) then
        Details222.MythicPlus.LogStep("MergeTrashCleanup started.")

        --the first segment is the segment where all other trash segments will be added
        local masterSegment = segmentsToMerge[1]

        --get the current combat just created and the table with all past segments
        local newCombat = masterSegment
        local totalTime = newCombat:GetCombatTime()
        local startDate, endDate = "", ""
        local lastSegment

        --add segments
        for i = 2, #segmentsToMerge do --segment #1 is the host
            local pastCombat = segmentsToMerge[i]
            newCombat = newCombat + pastCombat
            totalTime = totalTime + pastCombat:GetCombatTime()

            newCombat:CopyDeathsFrom(pastCombat, true)

            --tag this combat as already added to a boss trash overall
            pastCombat._trashoverallalreadyadded = true

            if (endDate == "") then
                local _, whenEnded = pastCombat:GetDate()
                endDate = whenEnded
            end
            lastSegment = pastCombat
        end

        --get the date where the first segment started
        if (lastSegment) then
            startDate = lastSegment:GetDate()
        end

        local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()

        --tag the segment as mythic overall segment
        newCombat.is_mythic_dungeon = {
            StartedAt = segmentsToMerge.PreviousBossKilledAt, --start of the mythic run or when the previous boss got killed
            EndedAt = segmentsToMerge.LastBossKilledAt, --the time() when encounter_end got triggered
            SegmentID = "trashoverall",
            RunID = Details.mythic_dungeon_id,
            TrashOverallSegment = true,
            ZoneName = Details.MythicPlus.DungeonName,
            MapID = instanceMapID,
            Level = Details.MythicPlus.Level,
            EJID = Details.MythicPlus.ejID,
            EncounterID = segmentsToMerge.EncounterID,
            EncounterName = segmentsToMerge.EncounterName or Loc ["STRING_UNKNOW"],
            SegmentType = DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH,
            SegmentName = (segmentsToMerge.EncounterName or Loc ["STRING_UNKNOW"]) .. " (" .. string.lower(Loc["STRING_SEGMENTS_LIST_TRASH"]) .. ")",
        }

        newCombat.is_challenge = true
        newCombat.is_mythic_dungeon_segment = true
        newCombat.is_mythic_dungeon_run_id = Details.mythic_dungeon_id

        --set the segment time / using a sum of combat times, this combat time is reliable
        newCombat:SetStartTime(GetTime() - totalTime)
        newCombat:SetEndTime(GetTime())
        --set the segment date
        newCombat:SetDate(startDate, endDate)

        if (DetailsMythicPlusFrame.DevelopmentDebug) then
            print("Details!", "MergeTrashCleanup() > finished merging trash segments.", Details.tabela_vigente, Details.tabela_vigente.is_boss)
        end

        --delete all segments that were merged
        local segmentsTable = Details:GetCombatSegments()
        for segmentId = #segmentsTable, 1, -1 do
            local segment = segmentsTable[segmentId]
            if (segment and segment._trashoverallalreadyadded) then
                table.remove(segmentsTable, segmentId)
            end
        end

        for i = #segmentsToMerge, 1, -1 do
            table.remove(segmentsToMerge, i)
        end

        --call the segment removed event to notify third party addons
        Details:SendEvent("DETAILS_DATA_SEGMENTREMOVED")

        --update all windows
        Details:InstanceCallDetailsFunc(Details.FadeHandler.Fader, "IN", nil, "barras")
        Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse)
        Details:InstanceCallDetailsFunc(Details.AtualizaSoloMode_AfertReset)
        Details:InstanceCallDetailsFunc(Details.ResetaGump)
        Details:RefreshMainWindow(-1, true)
    else
        Details222.MythicPlus.LogStep("MergeTrashCleanup | no segments to merge.")
    end
end

function DetailsMythicPlusFrame.MergeSegmentsOnEnd() --~merge
    --at the end of a mythic run, if enable on settings, merge all the segments from the mythic run into only one
    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("Details!", "MergeSegmentsOnEnd() > starting to merge mythic segments.", "InCombatLockdown():", InCombatLockdown())
    end

    Details222.MythicPlus.LogStep("MergeSegmentsOnEnd started | creating the overall segment at the end of the run.")

    --create a new combat to be the overall for the mythic run
    Details222.StartCombat()

    --get the current combat just created and the table with all past segments
    ---@type combat
    local newCombat = Details:GetCurrentCombat()
    local segmentsTable = Details:GetCombatSegments()

    newCombat.is_challenge = true
    newCombat.is_mythic_dungeon_segment = true
    newCombat.is_mythic_dungeon_run_id = Details.mythic_dungeon_id

    local timeInCombat = 0
    local startDate, endDate = "", ""
    local lastSegment
    local totalSegments = 0

    --copy deaths occured on all segments to the new segment, also sum the activity combat time
    if (Details.mythic_plus.reverse_death_log) then
        for i = 1, 40 do --copy the deaths from the first segment to the last one
            local thisCombat = segmentsTable[i]
            if (thisCombat and thisCombat.is_mythic_dungeon_run_id == Details.mythic_dungeon_id) then
                newCombat:CopyDeathsFrom(thisCombat, true)
                timeInCombat = timeInCombat + thisCombat:GetCombatTime()
            end
        end
    else
        for i = 40, 1, -1 do --copy the deaths from the last segment to the new segment
            local thisCombat = segmentsTable[i]
            if (thisCombat) then
                if (thisCombat.is_mythic_dungeon_run_id == Details.mythic_dungeon_id) then
                    newCombat:CopyDeathsFrom(thisCombat, true)
                    timeInCombat = timeInCombat + thisCombat:GetCombatTime()
                end
            end
        end
    end

    local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()

    --tag the segment as mythic overall segment
    ---@type mythicdungeoninfo
    newCombat.is_mythic_dungeon = {
        StartedAt = Details.MythicPlus.StartedAt, --the start of the run
        EndedAt = Details.MythicPlus.EndedAt, --the end of the run
        WorldStateTimerStart = Details222.MythicPlus.WorldStateTimerStartAt,
        WorldStateTimerEnd = Details222.MythicPlus.WorldStateTimerEndAt,
        RunTime = Details222.MythicPlus.time, --this is the time that discounted the deaths penalty
        TotalTime = Details222.MythicPlus.ElapsedTime, --this is the total time of the run
        TimeInCombat = timeInCombat,
        SegmentID = "overall", --segment number within the dungeon
        RunID = Details.mythic_dungeon_id,
        OverallSegment = true,
        ZoneName = Details.MythicPlus.DungeonName,
        EJID = Details.MythicPlus.ejID,
		MapID = Details222.MythicPlus.MapID,
		Level = Details222.MythicPlus.Level,
		OnTime = Details222.MythicPlus.OnTime,
		KeystoneUpgradeLevels = Details222.MythicPlus.KeystoneUpgradeLevels,
		PracticeRun = Details222.MythicPlus.PracticeRun,
		OldDungeonScore = Details222.MythicPlus.OldDungeonScore,
		NewDungeonScore = Details222.MythicPlus.NewDungeonScore,
		IsAffixRecord = Details222.MythicPlus.IsAffixRecord,
		IsMapRecord = Details222.MythicPlus.IsMapRecord,
		PrimaryAffix = Details222.MythicPlus.PrimaryAffix,
		IsEligibleForScore = Details222.MythicPlus.IsEligibleForScore,
		UpgradeMembers = Details222.MythicPlus.UpgradeMembers,
		TimeLimit = Details222.MythicPlus.TimeLimit,
		DungeonName = Details222.MythicPlus.DungeonName,
		DungeonID = Details222.MythicPlus.DungeonID,
		DungeonTexture = Details222.MythicPlus.Texture,
		DungeonBackgroundTexture = Details222.MythicPlus.BackgroundTexture,
        SegmentType = DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL,
        SegmentName = Details.MythicPlus.DungeonName .. " +" .. (Details222.MythicPlus.Level or 2),
    }

    --add all boss segments from this run to this new segment
    for i = 1, 40 do --from the newer combat to the oldest
        local thisCombat = segmentsTable[i]
        if (thisCombat and thisCombat.is_mythic_dungeon_run_id == Details.mythic_dungeon_id) then
            local canAddThisSegment = true
            if (Details.mythic_plus.make_overall_boss_only) then
                if (not thisCombat.is_boss) then
                    --canAddThisSegment = false --disabled
                end
            end

            if (canAddThisSegment) then
                newCombat = newCombat + thisCombat
                totalSegments = totalSegments + 1

                if (DetailsMythicPlusFrame.DevelopmentDebug) then
                    print("MergeSegmentsOnEnd() > adding time:", thisCombat:GetCombatTime(), thisCombat.is_boss and thisCombat.is_boss.name)
                end

                if (endDate == "") then
                    local _, whenEnded = thisCombat:GetDate()
                    endDate = whenEnded
                end
                lastSegment = thisCombat
            end
        end
    end

    --get the date where the first segment started
    if (lastSegment) then
        startDate = lastSegment:GetDate()
    end

    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("Details!", "MergeSegmentsOnEnd() > totalTime:", timeInCombat, "startDate:", startDate)
    end

    newCombat.total_segments_added = totalSegments
    newCombat.is_mythic_dungeon_run_id = Details.mythic_dungeon_id

    --check if both values are valid, this can get invalid if the player leaves the dungeon before the timer ends or the game crashes
    if (type(Details222.MythicPlus.time) == "number") then
        newCombat.run_time = Details222.MythicPlus.time
        newCombat.elapsed_time = Details222.MythicPlus.ElapsedTime
        Details222.MythicPlus.LogStep("GetChallengeCompletionInfo() Found, Time: " .. Details222.MythicPlus.time)

    elseif (newCombat.is_mythic_dungeon.WorldStateTimerEnd and newCombat.is_mythic_dungeon.WorldStateTimerStart) then
        local runTime = newCombat.is_mythic_dungeon.WorldStateTimerEnd - newCombat.is_mythic_dungeon.WorldStateTimerStart
        newCombat.run_time = Details222.MythicPlus.time
        Details222.MythicPlus.LogStep("World State Timers is Available, Run Time: " .. runTime .. "| start:" .. newCombat.is_mythic_dungeon.WorldStateTimerStart .. "| end:" .. newCombat.is_mythic_dungeon.WorldStateTimerEnd)
    else
        newCombat.run_time = timeInCombat
        Details222.MythicPlus.LogStep("GetChallengeCompletionInfo() and World State Timers not Found, Activity Time: " .. timeInCombat)
    end

    newCombat:SetStartTime(GetTime() - timeInCombat)
    newCombat:SetEndTime(GetTime())
    Details222.MythicPlus.LogStep("Activity Time: " .. timeInCombat)

    --set the segment time and date
    newCombat:SetDate(startDate, endDate)

    --immediatly finishes the segment just started
    Details:SairDoCombate()
    newCombat.is_mythic_dungeon_segment = true

    --update all windows
    Details:InstanceCallDetailsFunc(Details.FadeHandler.Fader, "IN", nil, "barras")
    Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse)
    Details:InstanceCallDetailsFunc(Details.AtualizaSoloMode_AfertReset)
    Details:InstanceCallDetailsFunc(Details.ResetaGump)
    Details:RefreshMainWindow(-1, true)

    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("Details!", "MergeSegmentsOnEnd() > finished merging segments.")
        print("Details!", "MergeSegmentsOnEnd() > all done, check in the segments list if everything is correct, if something is weird: '/details feedback' thanks in advance!")
    end

    local lower_instance = Details:GetLowerInstanceNumber()
    if (lower_instance) then
        local instance = Details:GetInstance(lower_instance)
        if (instance) then
            local func = {function() end}
            instance:InstanceAlert ("Showing Mythic+ Run Segment", {[[Interface\AddOns\Details\images\icons]], 16, 16, false, 434/512, 466/512, 243/512, 273/512}, 6, func, true)
        end
    end

    local bHasObject = false
    Details:SendEvent("COMBAT_MYTHICPLUS_OVERALL_READY", bHasObject, newCombat)
end

--this function merges trash segments after all bosses of the mythic dungeon are defeated
--happens when the group finishes all bosses but don't complete the trash requirement
function DetailsMythicPlusFrame.MergeRemainingTrashAfterAllBossesDone()
    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("Details!", "MergeRemainingTrashAfterAllBossesDone() > running, #segments: ", #DetailsMythicPlusFrame.TrashMergeScheduled2, "trash overall table:", DetailsMythicPlusFrame.TrashMergeScheduled2_OverallCombat)
    end

    Details222.MythicPlus.LogStep("running MergeRemainingTrashAfterAllBossesDone.")

    local segmentsToMerge = DetailsMythicPlusFrame.TrashMergeScheduled2
    local latestBossTrashMergedCombat = DetailsMythicPlusFrame.TrashMergeScheduled2_OverallCombat

    --needs to merge, add the total combat time, set the date end to the date of the first segment
    local totalTime = 0
    local startDate, endDate = "", ""

    --add segments
    for i, pastCombat in ipairs(segmentsToMerge) do
        latestBossTrashMergedCombat = latestBossTrashMergedCombat + pastCombat
        if (DetailsMythicPlusFrame.DevelopmentDebug) then
            print("MergeRemainingTrashAfterAllBossesDone() >  segment added")
        end
        totalTime = totalTime + pastCombat:GetCombatTime()

        --tag this combat as already added to a boss trash overall
        pastCombat._trashoverallalreadyadded = true

        if (endDate == "") then --get the end date of the first index only
            local _, whenEnded = pastCombat:GetDate()
            endDate = whenEnded
        end
    end

    --set the segment time / using a sum of combat times, this combat time is reliable
    local startTime = latestBossTrashMergedCombat:GetStartTime()
    latestBossTrashMergedCombat:SetStartTime (startTime - totalTime)
    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("MergeRemainingTrashAfterAllBossesDone() > total combat time:", totalTime)
    end

    --set the segment date
    startDate = latestBossTrashMergedCombat:GetDate()
    latestBossTrashMergedCombat:SetDate(startDate, endDate)
    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("MergeRemainingTrashAfterAllBossesDone() > new end date:", endDate)
    end

    local mythicDungeonInfo = latestBossTrashMergedCombat:GetMythicDungeonInfo()

    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("MergeRemainingTrashAfterAllBossesDone() > elapsed time before:", mythicDungeonInfo.EndedAt - mythicDungeonInfo.StartedAt)
    end

    mythicDungeonInfo.StartedAt = mythicDungeonInfo.StartedAt - (Details.MythicPlus.EndedAt - Details.MythicPlus.PreviousBossKilledAt)

    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("MergeRemainingTrashAfterAllBossesDone() > elapsed time after:", mythicDungeonInfo.EndedAt - mythicDungeonInfo.StartedAt)
    end

    --remove trash segments from the segment history after the merge
    local removedCurrentSegment = false
    local segmentsTable = Details:GetCombatSegments()
    for _, pastCombat in ipairs(segmentsToMerge) do
        for i = #segmentsTable, 1, -1 do
            local segment = segmentsTable[i]
            if (segment == pastCombat) then
                --remove the segment
                if (Details:GetCurrentCombat() == segment) then
                    removedCurrentSegment = true
                end
                table.remove(segmentsTable, i)
                break
            end
        end
    end

    for i = #segmentsToMerge, 1, -1 do
        table.remove(segmentsToMerge, i)
    end

    if (removedCurrentSegment) then
        --find another current segment
        segmentsTable = Details:GetCombatSegments()
        Details:SetCurrentCombat(segmentsTable[1])

        if (not Details:GetCurrentCombat()) then
            --assuming there's no segment from the dungeon run
            Details222.StartCombat()
            Details:EndCombat()
        end

        --update all windows
        Details:InstanceCallDetailsFunc(Details.FadeHandler.Fader, "IN", nil, "barras")
        Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse)
        Details:InstanceCallDetailsFunc(Details.AtualizaSoloMode_AfertReset)
        Details:InstanceCallDetailsFunc(Details.ResetaGump)
        Details:RefreshMainWindow(-1, true)
    end

    Details222.MythicPlus.LogStep("delete_trash_after_merge | concluded")
    Details:SendEvent("DETAILS_DATA_SEGMENTREMOVED")

    DetailsMythicPlusFrame.TrashMergeScheduled2 = nil
    DetailsMythicPlusFrame.TrashMergeScheduled2_OverallCombat = nil

    if (DetailsMythicPlusFrame.DevelopmentDebug) then
        print("Details!", "MergeRemainingTrashAfterAllBossesDone() > done merging")
    end
end

--does not do the merge, just scheduling, the merger is on the function above
function Details222.MythicPlus.MergeTrashAfterLastBoss()
    local segmentsToMerge = {}
    --table with all past segments
    local segmentsTable = Details:GetCombatSegments()

    for i = 1, #segmentsTable do
        local pastCombat = segmentsTable[i]
        --does the combat exists

        if (pastCombat and not pastCombat._trashoverallalreadyadded and pastCombat:GetCombatTime() > 5) then
            --is the last boss?
            if (pastCombat.is_boss) then
                break
            end

            --is the combat a mythic segment from this run?
            local bIsMythicSegment, SegmentID = pastCombat:IsMythicDungeon()
            if (bIsMythicSegment and SegmentID == Details.mythic_dungeon_id) then
                local combatType = pastCombat:GetCombatType()
                if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH or combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE) then
                    table.insert(segmentsToMerge, pastCombat)
                    if (DetailsMythicPlusFrame.DevelopmentDebug) then
                        print("MythicDungeonFinished() > found after last boss combat")
                    end
                end
            end
        end
    end

    if (#segmentsToMerge > 0) then
        if (DetailsMythicPlusFrame.DevelopmentDebug) then
            print("Details!", "MythicDungeonFinished() > found ", #segmentsToMerge, "segments after the last boss")
        end

        --find the latest trash overall
        segmentsTable = Details:GetCombatSegments()
        local latestTrashOverall
        for i = 1, #segmentsTable do
            local pastCombat = segmentsTable[i]
            if (pastCombat and pastCombat.is_mythic_dungeon) then
                local combatType = pastCombat:GetCombatType()
                if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH) then
                    latestTrashOverall = pastCombat
                    break
                end
            end
        end

        if (latestTrashOverall) then
            --stores the segment table and the trash overall segment to use on the merge
            DetailsMythicPlusFrame.TrashMergeScheduled2 = segmentsToMerge
            DetailsMythicPlusFrame.TrashMergeScheduled2_OverallCombat = latestTrashOverall

            if (DetailsMythicPlusFrame.DevelopmentDebug) then
                print("Details!", "MythicDungeonFinished() > not in combat, merging last pack of trash now")
            end

            DetailsMythicPlusFrame.MergeRemainingTrashAfterAllBossesDone()
        end
    end
end