
---@type details
local Details = _G.Details

---@type detailsframework
local detailsFramework = DetailsFramework

local _
local addonName, Details222 = ...

local combatClass = Details.combate
local segmentClass = Details.historico
local bitBand = bit.band
local wipe = table.wipe

local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")

---@type petcontainer
local petContainer = Details222.PetContainer

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--API

--reset only the overall data
function Details:ResetSegmentOverallData()
	return segmentClass:ResetOverallData()
end

--erase all combat data stored
function Details:ResetSegmentData()
	return segmentClass:ResetAllCombatData()
end

--returns the current active segment
function Details:GetCurrentCombat()
	return Details.tabela_vigente
end

function Details:SetCurrentCombat(combatObject)
	Details.tabela_vigente = combatObject
end

function Details:GetOverallCombat()
	return Details.tabela_overall
end

---return a combat object for the given segment identifier
---@param self details
---@param combat any
---@return combat|nil
function Details:GetCombat(combat)
	if (not combat) then
		return Details:GetCurrentCombat()

	elseif (type(combat) == "number") then
		if (combat == -1) then --overall
			return Details:GetOverallCombat()

		elseif (combat == 0) then --current
			return Details:GetCurrentCombat()
		else
			local segmentsTable = Details:GetCombatSegments()
			return segmentsTable[combat]
		end

	elseif (type(combat) == "string") then
		if (combat == "overall") then
			return Details:GetOverallCombat()

		elseif (combat == "current") then
			return Details:GetCurrentCombat()
		end
	end

	return nil
end

---get a unique combat id and check if exists a combat with this id
---@param uniqueCombatId number
---@return boolean bExistsCombat
function Details:DoesCombatWithUIDExists(uniqueCombatId)
	local segmentsTable = Details:GetCombatSegments()

	for segmentId, combatObject in ipairs(segmentsTable) do
		if (combatObject.combat_counter == uniqueCombatId) then
			return true
		end
	end

	return false
end

---get a unique combat id and return the combat object
---@param uniqueCombatId number
---@return combat|boolean combatObject
function Details:GetCombatByUID(uniqueCombatId)
	local segmentsTable = Details:GetCombatSegments()

	for segmentId, combatObject in ipairs(segmentsTable) do
		if (combatObject.combat_counter == uniqueCombatId) then
			return combatObject
		end
	end

	return false
end

---remove a segment from the segments table
---@param segmentIndex number
---@return boolean, combat
function Details:RemoveSegment(segmentIndex)
	assert(type(segmentIndex) == "number", "Usage: Details:RemoveSegment(segmentIndex: number)")

	local segmentsTable = Details:GetCombatSegments()
	local segmentRemoved = table.remove(segmentsTable, segmentIndex)
	return segmentRemoved ~= nil, segmentRemoved
end

---remove a combat from the segments list by it's combat object
---@param combatObject any
---@return boolean, combat|nil
function Details:RemoveSegmentByCombatObject(combatObject)
	if (combatObject) then
		local segmentsTable = Details:GetCombatSegments()
		for i = 1, #segmentsTable do
			if (segmentsTable[i] == combatObject) then
				local combatObjectRemoved = table.remove(segmentsTable, i)
				return true, combatObjectRemoved
			end
		end
	end
	return false
end

--returns a private table containing all stored segments
function Details:GetCombatSegments()
	return Details.tabela_historico.tabelas
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--internal

function Details222.GuessSpecSchedules.ClearSchedules()
	for i = 1, #Details222.GuessSpecSchedules.Schedules do
		local schedule = Details222.GuessSpecSchedules.Schedules[i]
		if (schedule) then
			Details:CancelTimer(schedule)
		end
	end
	wipe(Details222.GuessSpecSchedules.Schedules)
end

function segmentClass:CreateNewSegmentDatabase()
	local newSegmentDatabase = {tabelas = {}}
	setmetatable(newSegmentDatabase, segmentClass)
	return newSegmentDatabase
end

---comment
---@param combatObject combat
function segmentClass:AddToOverallData(combatObject)
	local zoneName, zoneType = GetInstanceInfo()
	if (zoneType ~= "none" and combatObject:GetCombatTime() <= Details.minimum_overall_combat_time) then
		return
	end

	if (Details.overall_clear_newboss) then
		--only for raids
		if (combatObject.instance_type == "raid" and combatObject.is_boss) then
			if (Details.last_encounter ~= Details.last_encounter2) then
				if (Details.debug) then
					--Details:Msg("(debug) new boss detected 'overall_clear_newboss' is true, cleaning overall data.")
				end

				for index, combat in ipairs(Details:GetCombatSegments()) do
					combat.overall_added = false
				end

				segmentClass:ResetOverallData()
			end
		end
	end

	if (combatObject.overall_added) then
		Details:Msg("error > attempt to add a segment already added > func historico:AddToOverallData()")
		return
	end

	local mythicInfo = combatObject.is_mythic_dungeon
	if (mythicInfo) then
		--do not add overall mythic+ dungeon segments
		if (mythicInfo.TrashOverallSegment) then
			Details:Msg("error > attempt to add a TrashOverallSegment > func historico:AddToOverallData()")
			return

		elseif (mythicInfo.OverallSegment) then
			Details:Msg("error > attempt to add a OverallSegment > func historico:AddToOverallData()")
			return
		end
	end

	---@type combat
	local overallCombat = Details:GetOverallCombat()

	--store the segments added to the overall data
	overallCombat.segments_added = overallCombat.segments_added or {}

	local combatStartDate = combatObject:GetDate()
	local combatName = combatObject:GetCombatName(false, true)
	local combatTime = combatObject:GetCombatTime()
	local combatType = combatObject:GetCombatType()

	table.insert(overallCombat.segments_added, 1, {name = combatName, elapsed = combatTime, clock = combatStartDate, type = combatType})

	if (#overallCombat.segments_added > 40) then
		table.remove(overallCombat.segments_added, 41)
	end

	overallCombat = overallCombat + combatObject
	combatObject.overall_added = true

	if (not overallCombat.overall_enemy_name) then
		overallCombat.overall_enemy_name = combatObject.is_boss and combatObject.is_boss.name or combatObject.enemy
	else
		if (overallCombat.overall_enemy_name ~= (combatObject.is_boss and combatObject.is_boss.name or combatObject.enemy)) then
			overallCombat.overall_enemy_name = "-- x -- x --"
		end
	end

	if (overallCombat.start_time == 0) then
		overallCombat:SetStartTime(combatObject.start_time)
		overallCombat:SetEndTime(combatObject.end_time)
	else
		overallCombat:SetStartTime(combatObject.start_time - overallCombat:GetCombatTime())
		overallCombat:SetEndTime(combatObject.end_time)
	end

	local overallStartDate = overallCombat:GetDate()
	if (overallStartDate == 0) then
		overallCombat:SetDate(combatStartDate or 0)
	end

	overallCombat:SetDateToNow(false, true)
	Details:ClockPluginTickOnSegment()

	for id, instance in Details:ListInstances() do
		if (instance:IsEnabled()) then
			if (instance:GetSegment() == DETAILS_SEGMENTID_OVERALL) then
				instance:ForceRefresh()
			end
		end
	end
end

---return true if the combatObject can be added to the overall data
---@param self details
---@param combatObject table
---@return boolean canAdd
function Details:CanAddCombatToOverall(combatObject)
	--already added
	if (combatObject.overall_added) then
		return false
	end

	local combatType = combatObject:GetCombatType()

	--special cases
	local mythicInfo = combatObject.is_mythic_dungeon
	if (mythicInfo) then
		--do not add overall mythic+ dungeon segments
		if (mythicInfo.TrashOverallSegment) then
			return false

		elseif (mythicInfo.OverallSegment) then
			return false
		end
	end

	--raid boss - flag 0x1
	if (bitBand(Details.overall_flag, 0x1) ~= 0) then
		if (combatObject.is_boss and combatObject:GetInstanceType() == "raid" and not combatObject.is_pvp) then
			if (combatObject:GetCombatTime() >= 30) then
				return true
			end
		end
	end

	--raid trash - flag 0x2
	if (bitBand(Details.overall_flag, 0x2) ~= 0) then
		if (combatObject.is_trash and combatObject:GetInstanceType() == "raid") then
			return true
		end
	end

	--dungeon boss - flag 0x4
	if (bitBand(Details.overall_flag, 0x4) ~= 0) then
		if (combatObject.is_boss and combatObject:GetInstanceType() == "party" and combatType ~= DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND) then
			return true
		end
	end

	--dungeon trash - flag 0x8
	if (bitBand(Details.overall_flag, 0x8) ~= 0) then
		if ((combatObject.is_trash or combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH) and combatObject:GetInstanceType() == "party") then
			return true
		end
	end

	--any combat
	if (bitBand(Details.overall_flag, 0x10) ~= 0) then
		return true
	end

	--is a PvP combat
	if (combatType == DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND or combatType == DETAILS_SEGMENTTYPE_PVP_ARENA) then
		return true
	end

	return false
end

---get the amount of wipes for a guilda in a specific boss and difficulty
---@param guildName string
---@param encounterId number
---@param difficultyId number
---@return number
function Details:GetWipeCounter(guildName, encounterId, difficultyId)
	local guildWipes = Details.boss_wipe_counter[guildName]
	if (guildWipes) then
		local bossWipes = guildWipes[encounterId]
		if (bossWipes) then
			local difficultyWipes = bossWipes[difficultyId]
			if (difficultyWipes) then
				return difficultyWipes
			end
		end
	end
	return 0
end

---return the amount of segments in the segments table that are from the same boss as the combat passed as argument
---@param currentCombat combat
---@return number
local getAmountOfSegmentsInThisBoss = function(currentCombat)
	local segmentsTable = Details:GetCombatSegments()
	local amountOfSegmentsInUse = #segmentsTable
	local amountOfSegmentsInThisBoss = 0

	---@type bossinfo
	local thisCombatBossInfo = currentCombat:GetBossInfo()

	if (thisCombatBossInfo) then
		local currentBossName = thisCombatBossInfo.name
		for i = 1, amountOfSegmentsInUse do
			---@type combat
			local thisCombatObject = segmentsTable[i]
			---@type bossinfo
			local bossInfo = thisCombatObject:GetBossInfo()
			if (bossInfo and bossInfo ~= thisCombatBossInfo) then
				if (bossInfo.name == currentBossName) then
					amountOfSegmentsInThisBoss = amountOfSegmentsInThisBoss + 1
				end
			end
		end
	end

	return amountOfSegmentsInThisBoss
end

---count boss tries and set the value in the combat object
---@param combatToBeAdded combat
local setBossTryCounter = function(combatToBeAdded, segmentsTable, amountSegmentsInUse)
	---@type bossinfo
	local bossInfo = combatToBeAdded:GetBossInfo()
	local bossName = bossInfo and bossInfo.name
	local encounterId = bossInfo and bossInfo.id
	local bossDifficultyId = bossInfo and bossInfo.diff

	if (bossName and encounterId and bossDifficultyId) then
		--account global
		---@type table<guildname, table<encounterid, table<encounterdifficulty, number>>>
		local bossTriesDatabase = Details.boss_wipe_counter

		--to store a wipe 70% of the raid must be from the same guild
		--get the player guild name
		local playerGuildName = GetGuildInfo("player")
		if (playerGuildName) then
			local amountOfPlayersInGroup = GetNumGroupMembers()
			local amountOfPlayersFromGuild = 0

			local cachedRaidUnitIds = Details222.UnitIdCache.Raid
			for i = 1, amountOfPlayersInGroup do
				local unitId = cachedRaidUnitIds[i]
				--get the guild name of the unit
				local unitGuildName = GetGuildInfo(unitId)
				if (unitGuildName and unitGuildName == playerGuildName) then
					amountOfPlayersFromGuild = amountOfPlayersFromGuild + 1
				end
			end

			--check the 70%
			if (amountOfPlayersFromGuild / amountOfPlayersInGroup >= 0.7) then
				--check the elapsed time of the encounter is bigger than the min allowed
				if (combatToBeAdded:GetCombatTime() >= Details.boss_wipe_min_time) then --default 20 seconds
					--check if there is a table for the guild name in the database
					local guildWipes = bossTriesDatabase[playerGuildName]
					if (not guildWipes) then
						guildWipes = {}
						bossTriesDatabase[playerGuildName] = guildWipes
					end

					--check if there is a table for the bossId in the guild table
					local bossWipes = guildWipes[encounterId]
					if (not bossWipes) then
						bossWipes = {}
						guildWipes[encounterId] = bossWipes
					end

					--check if there's a difficulty table inside the boss wipes table
					local difficultyWipes = bossWipes[bossDifficultyId]
					if (not difficultyWipes) then
						difficultyWipes = 0
						bossWipes[bossDifficultyId] = difficultyWipes
					end

					--increment the wipe counter
					bossWipes[bossDifficultyId] = difficultyWipes + 1
					combatToBeAdded.is_boss.try_number = bossWipes[bossDifficultyId]
					--Details:Msg("(testing) wipes on this boss with this guild in this difficulty:", bossWipes[bossDifficultyId])
				end
			end
		end
	end
end

--this function will shutdown all actors from the previous combat from the time machine
local shutDownActorsOnTimeMachine = function(segmentsTable)
	---@type combat
	local previousCombatObject = segmentsTable[1]
	if (previousCombatObject) then
		---@type actorcontainer
		local containerDamage = previousCombatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		---@type actorcontainer
		local containerHeal = previousCombatObject:GetContainer(DETAILS_ATTRIBUTE_HEAL)

		for _, actorObject in containerDamage:ListActors() do
			---@cast actorObject actor
			--clear last events table (death logs)
			actorObject.last_events_table =  nil
			--remove from the time machine
			Details222.TimeMachine.RemoveActor(actorObject)
		end

		for _, actorObject in containerHeal:ListActors() do
			---@cast actorObject actor
			--clear last events table (death logs)
			actorObject.last_events_table =  nil
			--remove from the time machine
			Details222.TimeMachine.RemoveActor(actorObject)
		end
	end
end

---add the combat to the segment table, check adding to overall
---@param combatToBeAdded combat
function Details222.Combat.AddCombat(combatToBeAdded)
	---@type number how many segments the user wants to store
	local maxSegmentsAllowed = Details.segments_amount

	---@type combat[]
	local segmentsTable = Details:GetCombatSegments()

	---@type number amount of segments currently stored
	local amountSegmentsInUse = #segmentsTable

	---@type table<combat, boolean> store references of combat objects removed
	local removedCombats = {}

	---@type bossinfo
	local combatToAdd_BossInfo = combatToBeAdded:GetBossInfo()

	--check if there's a destroyed segment within the segment container
	if (amountSegmentsInUse > 0) then
		for i = 1, amountSegmentsInUse do
			local thisCombatObject = segmentsTable[i]
			if (thisCombatObject.__destroyed) then
				Details:Msg("(debug) container_segments line: 487 (__destroyed combat in segments container)")
			end
		end
	end
	---@end-debug

	---@type boolean
	local bSegmentDestroyed = false

	--check all instances for freeze state
	if (amountSegmentsInUse < maxSegmentsAllowed) then
		--if there's no segment stored, then this as the first segment
		if (amountSegmentsInUse == 0) then
			Details:InstanceCallDetailsFunc(Details.CheckFreeze, amountSegmentsInUse + 1, combatToBeAdded)
		else
			---@type combat
			local oldestCombatObject = segmentsTable[amountSegmentsInUse]
			Details:InstanceCallDetailsFunc(Details.CheckFreeze, amountSegmentsInUse + 1, oldestCombatObject)
		end
	end

	--check if this is a boss wipe and increment the try counter
	if (combatToAdd_BossInfo and not combatToAdd_BossInfo.killed) then
		local bRunOkay, errorText = pcall(setBossTryCounter, combatToBeAdded, segmentsTable, amountSegmentsInUse)
		if (not bRunOkay) then
			Details:Msg("error > failed to set boss try counter > ", errorText)
		end
	end

	--shutdown actors from the previous combat from the time machine
	shutDownActorsOnTimeMachine(segmentsTable)

	---@type boolean user choise to remove trash combats or not
	local bAutoRemoveTrashCombats = Details.trash_auto_remove
	if (bAutoRemoveTrashCombats) then
		---@type combat
		local combatToCheckForTrash = segmentsTable[2]

		if (combatToCheckForTrash) then
			local bIsFromMythicDungeon = combatToCheckForTrash.is_mythic_dungeon_segment
			if (not bIsFromMythicDungeon) then
				local bCombatIsTrash = combatToCheckForTrash.is_trash and not combatToCheckForTrash.is_boss
				local bCombatIsWorldTrash = combatToCheckForTrash.is_world_trash_combat

				if (bCombatIsTrash or bCombatIsWorldTrash) then
					---@type boolean, combat|nil
					local bSegmentRemoved, combatObjectRemoved = Details:RemoveSegmentByCombatObject(combatToCheckForTrash)
					if (bSegmentRemoved and combatObjectRemoved and combatObjectRemoved == combatToCheckForTrash) then
						Details:DestroyCombat(combatObjectRemoved)
						bSegmentDestroyed = true
						--add the combat reference to removed combats table
						removedCombats[combatObjectRemoved] = true
					end
				end
			end
		end
	end

	--update the amount of segments in use in case a segment was removed
	amountSegmentsInUse = #segmentsTable

	--add +1 into the amount of segments in use to count for the combat which will be added at the end of this function
	local amountOfSegmentsInUsePlusOne = amountSegmentsInUse + 1

	--check if the segment table will exceed the amount of segments allowed (user setting)
	if (amountOfSegmentsInUsePlusOne > maxSegmentsAllowed) then
		---@type combat last combat in the segment table
		local combatObjectToBeRemoved = segmentsTable[amountSegmentsInUse]

		---@type boolean, combat|nil
		local bSegmentRemoved, combatObjectRemoved = Details:RemoveSegmentByCombatObject(combatObjectToBeRemoved)
		if (bSegmentRemoved and combatObjectRemoved and combatObjectRemoved == combatObjectToBeRemoved) then
			Details:DestroyCombat(combatObjectRemoved)
			bSegmentDestroyed = true
			--add the combat reference to removed combats table
			removedCombats[combatObjectRemoved] = true
		end
	end

	--update the amount of segments in use in case a segment was removed
	amountSegmentsInUse = #segmentsTable

	--is this inside a raid and the boss isn't killed?
	if (IsInRaid() and Details.zone_type == "raid" and combatToAdd_BossInfo and not combatToAdd_BossInfo.killed) then
		--get the amount of segments in the segmentsTable that are from the same boss and difficulty as the combat to be added
		local bRunOkay2, result = pcall(getAmountOfSegmentsInThisBoss, combatToBeAdded)
		if (not bRunOkay2) then
			Details:Msg("bRunOkay2 Error > failed to get amount of segments in this boss > ", result)
		else
			local segmentRemoveResult = ""
			if (type(result) ~= "number") then
				Details:Msg("result of bRunOkay2 isn't a number | result: ", result, type(result))
			end

			local bRunOkay3, errorText3 = pcall(function()
				local amountOfSegmentsInThisBoss = result --result of getAmountOfSegmentsInThisBoss()

				if (not Details.segments_amount_boss_wipes) then
					Details:Msg("Details.segments_amount_boss_wipes isn't a number, issue with profile? ", type(Details.segments_amount_boss_wipes))
					Details:Msg("on default profile:", Details.default_profile.segments_amount_boss_wipes)
				end

				--is the amount of segments in this boss bigger than the amount of segment wipe allowed?
				--context: segment wipe is when the raid wipes on a boss and the combat is stored in the segments table
				--Details.segments_amount_boss_wipes store the max amount of segment wipes allowed for a boss
				if (amountOfSegmentsInThisBoss > Details.segments_amount_boss_wipes) then --(user setting)
					---@type combat[]
					local allWipeSegmentsInThisBoss = {}
					for i = 1, amountSegmentsInUse do
						---@type combat
						local thisCombatObject = segmentsTable[i]
						local thisCombatBossInfo = thisCombatObject:GetBossInfo()

						--check if this segment has the same name and difficulty as the combat to be added
						if (thisCombatBossInfo and thisCombatBossInfo.name == combatToAdd_BossInfo.name and thisCombatBossInfo.diff == combatToAdd_BossInfo.diff) then
							if (not thisCombatBossInfo.killed) then --if the key killed is false or enexistent, it is a wipe
								table.insert(allWipeSegmentsInThisBoss, thisCombatObject)
							end
						end
					end

					segmentRemoveResult = segmentRemoveResult .. #allWipeSegmentsInThisBoss .. " added|" --debug

					--make sure the the amount of wipes found is bigger than the amount of segment wipes allowed
					if (#allWipeSegmentsInThisBoss > Details.segments_amount_boss_wipes) then
						--sort the table by boss health, the less is the health, the less is the index in the table
						table.sort(allWipeSegmentsInThisBoss, function(a, b) return a:GetBossHealth() < b:GetBossHealth() end)

						--remove the last index in the 'allWipeSegmentsInThisBoss' table, as this segment has the most health of the boss, which means less progress
						---@type combat
						local combatToBeRemoved = allWipeSegmentsInThisBoss[#allWipeSegmentsInThisBoss]
						---@type boolean, combat
						local bSegmentRemoved, combatObjectRemoved = Details:RemoveSegmentByCombatObject(combatToBeRemoved)
						---@cast combatObjectRemoved combat
						if (bSegmentRemoved and combatObjectRemoved and combatObjectRemoved == combatToBeRemoved) then
							--at this point the combat has been removed but not wipped from memory
							segmentRemoveResult = segmentRemoveResult .. "segment removed|" .. combatObjectRemoved:GetBossHealth() .."|"
							Details:DestroyCombat(combatObjectRemoved)
							bSegmentDestroyed = true
							--add the combat reference to removed combats table
							removedCombats[combatObjectRemoved] = true
						end
					end
				end
			end)

			if (not bRunOkay3) then
				Details:Msg("bRunOkay3 Error > ", errorText3)
			else
				if (segmentRemoveResult ~= "") then
					--Details:Msg("(testing)", segmentRemoveResult) --confirming that a segment got removed
				end
			end
		end
	end

	--update the amount of segments in use in case a segment was removed
	amountSegmentsInUse = #segmentsTable

	-- check if there's a destroyed segment within the segment container
	if (amountSegmentsInUse > 0) then
		for i = 1, amountSegmentsInUse do
			local thisCombatObject = segmentsTable[i]
			if (thisCombatObject.__destroyed) then
				Details:Msg("(debug) container_segments line: 651 (__destroyed combat in segments container)")
			end
		end
	end
	---@end-debug

	--insert the combat into the segments table
	table.insert(segmentsTable, 1, combatToBeAdded)

	--check if an instance is showing a combat which was removed
	for instanceId, instanceObject in Details:ListInstances() do
		---@type combat
		local combatObject = instanceObject:GetShowingCombat()
		if (removedCombats[combatObject]) then
			--update the combat the instance uses
			Details:UpdateCombatObjectInUse(instanceObject)
			--reset the window frame
			instanceObject:ResetWindow()
			--refresh the window to show the new combat attributed to it
			local bForceRefresh = true
			instanceObject:RefreshData(bForceRefresh)
		end
	end

	--see if can add the encounter to overall data
	local bCanAddToOverall = Details:CanAddCombatToOverall(combatToBeAdded)

	if (bCanAddToOverall) then
		if (Details.debug) then
			--Details:Msg("(debug) overall data flag match addind the combat to overall data.")
		end
		--add to overall data
		segmentClass:AddToOverallData(combatToBeAdded)
	end

	Details:InstanceCall(function(instanceObject) instanceObject:RefreshCombat() end)

	--update the combat shown on all instances
	Details:InstanceCallDetailsFunc(Details.AtualizaSegmentos_AfterCombat)

	if (bSegmentDestroyed) then
		Details:SendEvent("DETAILS_DATA_SEGMENTREMOVED")
	end

	Details:Destroy(removedCombats)
end


---add the combat to the segment table, check adding to overall
---@param combatObject combat
function segmentClass:AddCombat(combatObject)
	if true then
		return Details222.Combat.AddCombat(combatObject)
	end

	---@type combat[]
	local segmentsTable = Details:GetCombatSegments()
	---@type number
	local maxSegmentsAllowed = Details.segments_amount

	local bSegmentDestroyed = false

	--check all instances for freeze state
	if (#segmentsTable < maxSegmentsAllowed) then --done
		---@type combat
		local oldestCombatObject = segmentsTable[#segmentsTable]
		--if there's no segment stored, then this as the first segment
		if (not oldestCombatObject) then
			oldestCombatObject = combatObject
		end
		Details:InstanceCallDetailsFunc(Details.CheckFreeze, #segmentsTable + 1, oldestCombatObject)
	end

	--add to the first index of the segment table
	--table.insert(segmentsTable, 1, combatObject) --will be added at the end

	--count boss tries
	---@type string
	local bossName = combatObject.is_boss and combatObject.is_boss.name
	if (bossName) then --done
		local tryNumber = Details.encounter_counter[bossName]

		if (not tryNumber) then
			---@type combat
			local previousCombatObject
			for i = 2, #segmentsTable do
				previousCombatObject = segmentsTable[i]
				if (previousCombatObject and previousCombatObject.is_boss and previousCombatObject.is_boss.name and previousCombatObject.is_boss.try_number and previousCombatObject.is_boss.name == bossName and not previousCombatObject.is_boss.killed) then
					tryNumber = previousCombatObject.is_boss.try_number + 1
					break
				end
			end

			if (not tryNumber) then
				tryNumber = 1
			end
		else
			tryNumber = Details.encounter_counter[bossName] + 1
		end

		Details.encounter_counter[bossName] = tryNumber
		combatObject.is_boss.try_number = tryNumber
	end

	--see if can add the encounter to overall data
	local canAddToOverall = Details:CanAddCombatToOverall(combatObject)
	if (canAddToOverall) then
		if (Details.debug) then
			--Details:Msg("(debug) overall data flag match addind the combat to overall data.")
		end
		segmentClass:AddToOverallData(combatObject)
	end

	--erase trash segments
	if (segmentsTable[2]) then
		---@type combat
		local previousCombatObject = segmentsTable[2]
		---@type actorcontainer
		local containerDamage = previousCombatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		---@type actorcontainer
		local containerHeal = previousCombatObject:GetContainer(DETAILS_ATTRIBUTE_HEAL)

		--regular cleanup
		for _, actorObject in containerDamage:ListActors() do
			---@cast actorObject actor
			--clear last events table
			actorObject.last_events_table =  nil
			Details222.TimeMachine.RemoveActor(actorObject)
		end

		for _, actorObject in containerHeal:ListActors() do
			---@cast actorObject actor
			actorObject.last_events_table =  nil
			Details222.TimeMachine.RemoveActor(actorObject)
		end

		if (Details.trash_auto_remove) then
			---@type combat
			local thirdCombat = segmentsTable[3]

			if (thirdCombat and not thirdCombat.is_mythic_dungeon_segment) then
				if ((thirdCombat.is_trash and not thirdCombat.is_boss) or(thirdCombat.is_temporary)) then
					--verify again the time machine
					for _, actorObject in thirdCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
						Details222.TimeMachine.RemoveActor(actorObject)
					end
					for _, actorObject in thirdCombat:GetContainer(DETAILS_ATTRIBUTE_HEAL):ListActors() do
						Details222.TimeMachine.RemoveActor(actorObject)
					end

					--remove
					---@type boolean, combat
					local bSegmentRemoved, combatObjectRemoved = Details:RemoveSegment(3)
					if (bSegmentRemoved) then
						Details:DestroyCombat(combatObjectRemoved)
						bSegmentDestroyed = true
					end
				end
			end
		end
	end

	local segmentsTable = Details:GetCombatSegments()

	--check if the segment table is full
	if (#segmentsTable > maxSegmentsAllowed) then
		---@type combat
		local combatObjectToBeRemoved
		---@type number
		local segmentIdToBeRemoved

		--verify if the last combat is a boss and if there's more bosses with the same bossId in the segment table
		--then check which combat has the least amount of elapsed time and remove it
		--won't remove the latest 3 segments as they are fresh and the player may still look into them
		local bossId = combatObject.is_boss and combatObject.is_boss.id

		---@type combat
		local oldestSegment = segmentsTable[#segmentsTable]
		local oldestBossId = oldestSegment.is_boss and oldestSegment.is_boss.id

		if (Details.zone_type == "raid" and bossId and oldestBossId and bossId == oldestBossId) then
			---@type combat
			local shorterCombatObject
			---@type number
			local shorterSegmentId
			local minTime = 99999

			for segmentId = 4, #segmentsTable do
				---@type combat
				local thisCombatObject = segmentsTable[segmentId]
				if (thisCombatObject.is_boss and thisCombatObject.is_boss.id == bossId and thisCombatObject:GetCombatTime() < minTime and not thisCombatObject.is_boss.killed) then
					shorterCombatObject = thisCombatObject
					shorterSegmentId = segmentId
					minTime = thisCombatObject:GetCombatTime()
				end
			end

			if (shorterCombatObject) then
				combatObjectToBeRemoved = shorterCombatObject
				segmentIdToBeRemoved = shorterSegmentId
			end
		end

		--if couldn't find a boss to remove, then remove the oldest segment
		if (not combatObjectToBeRemoved) then
			combatObjectToBeRemoved = segmentsTable[#segmentsTable]
			segmentIdToBeRemoved = #segmentsTable
		end

		--check time machine
		for _, actorObject in combatObjectToBeRemoved:GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
			Details222.TimeMachine.RemoveActor(actorObject)
		end
		for _, actorObject in combatObjectToBeRemoved:GetContainer(DETAILS_ATTRIBUTE_HEAL):ListActors() do
			Details222.TimeMachine.RemoveActor(actorObject)
		end

		--remove it
		segmentsTable = Details:GetCombatSegments()
		---@type boolean, combat
		local bSegmentRemoved, combatObjectRemoved = Details:RemoveSegment(segmentIdToBeRemoved)
		if (bSegmentRemoved) then
			Details:DestroyCombat(combatObjectRemoved)
			bSegmentDestroyed = true
		end
	end

	--check if there's a destroyed segment within the segment container
	local segments = Details:GetCombatSegments()
	if (#segments > 0) then
		for i = 1, #segments do
			local thisCombatObject = segments[i]
			if (thisCombatObject.__destroyed) then
				Details:Msg("(debug) container_segments line: 419 (__destroyed combat in segments container)")
			end
		end
	end

	Details:InstanceCall(function(instanceObject) instanceObject:RefreshCombat() end)

	--update the combat shown on all instances
	Details:InstanceCallDetailsFunc(Details.AtualizaSegmentos_AfterCombat, self)

	if (bSegmentDestroyed) then
		Details:SendEvent("DETAILS_DATA_SEGMENTREMOVED")
	end
end

---verify if the instance is freezed, if true unfreeze it
---@param instanceObject instance
---@param segmentId number
---@param combatObject combat
function Details:CheckFreeze(instanceObject, segmentId, combatObject)
	if (instanceObject.freezed) then
		if (instanceObject:GetSegmentId() == segmentId) then
			instanceObject:RefreshCombat()
			instanceObject:UnFreeze()
		end
	end
end

function Details:SetOverallResetOptions(resetOnNewBoss, resetOnNewChallenge, resetOnLogoff, resetOnNewPVP)
	if (resetOnNewBoss == nil) then
		resetOnNewBoss = Details.overall_clear_newboss
	end
	if (resetOnNewChallenge == nil) then
		resetOnNewChallenge = Details.overall_clear_newchallenge
	end
	if (resetOnLogoff == nil) then
		resetOnLogoff = Details.overall_clear_logout
	end
	if (resetOnNewPVP == nil) then
		resetOnNewPVP = Details.overall_clear_pvp
	end

	Details.overall_clear_newboss = resetOnNewBoss
	Details.overall_clear_newchallenge = resetOnNewChallenge
	Details.overall_clear_logout = resetOnLogoff
	Details.overall_clear_pvp = resetOnNewPVP
end

function segmentClass:ResetOverallData()
	Details:CloseBreakdownWindow()

	Details:DestroyCombat(Details.tabela_overall)
	Details.tabela_overall = combatClass:NovaTabela()

	for index, instanceObject in ipairs(Details:GetAllInstances()) do
		if (instanceObject:IsEnabled()) then
			local segmentId = instanceObject:GetSegmentId()
			if (segmentId == DETAILS_SEGMENTID_OVERALL) then
				instanceObject:InstanceReset()
				instanceObject:ReajustaGump()
			end
		end
	end

	--stop bar testing if any
	Details:StopTestBarUpdate()
	Details:ClockPluginTickOnSegment()

	Details:SendEvent("DETAILS_DATA_SEGMENTREMOVED")
end

function segmentClass:ResetDataByCombatType(combatType)
	local bIsException = false
	local combatTypesInclusion = {}

	if (combatType == "m+overall") then
		combatType = DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL
		bIsException = true --remove all, except mythic+ overall

	elseif (combatType == "generic") then
		combatTypesInclusion[DETAILS_SEGMENTTYPE_GENERIC] = true
		combatTypesInclusion[DETAILS_SEGMENTTYPE_RAID_TRASH] = true

	elseif (combatType == "battleground") then
		combatTypesInclusion[DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND] = true
	end

	--destroy the overall combat object
	segmentClass:ResetOverallData()

	local bSegmentDestroyed = false
	local segmentsTable = Details:GetCombatSegments()
	---@type table<combat, boolean> store references of combat objects removed
	local removedCombats = {}

	if (bIsException) then --include all except the combatType
		--iterate over all segments and remove those that are not of the combatType
		--go to a minimum of 2 because the first segment is the current segment when the player isn't in combat
		for i = #segmentsTable, 2, -1 do
			---@type combat
			local thisCombatObject = segmentsTable[i]
			if (thisCombatObject:GetCombatType() ~= combatType) then
				---@type boolean, combat|nil
				local combatObjectRemoved = table.remove(segmentsTable, i)
				if (combatObjectRemoved and combatObjectRemoved == thisCombatObject) then
					Details:DestroyCombat(combatObjectRemoved)
					bSegmentDestroyed = true
					--add the combat reference to removed combats table
					removedCombats[combatObjectRemoved] = true
				end
			end
		end
	else
		--iterate over all segments and remove those that are equal to the combatType
		for i = #segmentsTable, 2, -1 do
			---@type combat
			local thisCombatObject = segmentsTable[i]
			if (combatTypesInclusion[thisCombatObject:GetCombatType()]) then
				---@type boolean, combat|nil
				local combatObjectRemoved = table.remove(segmentsTable, i)
				if (combatObjectRemoved and combatObjectRemoved == thisCombatObject) then
					Details:DestroyCombat(combatObjectRemoved)
					bSegmentDestroyed = true
				end
			end
		end
	end

	--safe check, if no segments saved, can cleanup all data
	if (#segmentsTable == 0) then
		--there's no combat left in the segments table
		segmentClass:ResetAllCombatData()
		return
	end

	--check if an instance is showing a combat which was removed
	for instanceId, instanceObject in Details:ListInstances() do
		---@type combat
		local combatObject = instanceObject:GetShowingCombat()
		if (combatObject and combatObject.__destroyed) then
			--update the combat the instance uses
			instanceObject:SetSegmentId(DETAILS_SEGMENTID_CURRENT)
			--reset the window frame
			instanceObject:ResetWindow()
			--refresh the window to show the new combat attributed to it
			local bForceRefresh = true
			instanceObject:RefreshData(bForceRefresh)
		end
	end

	Details:InstanceCall(function(instanceObject) instanceObject:RefreshCombat() end)

	--update the combat shown on all instances
	Details:InstanceCallDetailsFunc(Details.AtualizaSegmentos_AfterCombat)

	Details:UpdateParserGears()

	if (bSegmentDestroyed) then
		Details:SendEvent("DETAILS_DATA_SEGMENTREMOVED")
	end
end

function segmentClass:ResetAllCombatData()
	if (Details:IsInCombat()) then
		Details:EndCombat()
	end

	if (Details.bosswindow) then
		Details.bosswindow:Reset()
	end

	Details222.GuessSpecSchedules.ClearSchedules()

	--stop bar testing if any
	Details:StopTestBarUpdate()
	--close breakdown window
	Details:CloseBreakdownWindow()
	--empty damage class cache tables
	Details.atributo_damage:ClearCacheTables()
	--clear caches
	Details:ClearSpellCache()
	Details:Destroy(Details.ShieldCache)
	Details:Destroy(Details.cache_damage_group)
	Details:Destroy(Details.cache_healing_group)

	petContainer.DoMaintenance()

	Details:ResetSpecCache(true)

	--stop combat ticker
	Details:StopCombatTicker()

	--remove mythic dungeon schedules if any
	Details.schedule_mythicdungeon_trash_merge = nil
	Details.schedule_mythicdungeon_endtrash_merge = nil
	Details.schedule_mythicdungeon_overallrun_merge = nil

	--clear other schedules
	Details.schedule_flag_boss_components = nil
	Details.schedule_store_boss_encounter = nil

	--> handle segments destruction
	do
		---@type combat
		local currentCombat = Details:GetCurrentCombat()

		--handle segments
		local segmentsTable = Details:GetCombatSegments()
		--destroy all combat objects stored in the segments table
		for i = #segmentsTable, 1, -1 do
			---@type combat
			local thisCombatObject = segmentsTable[i]
			--check if the combat is already destroyed
			if (not thisCombatObject.__destroyed) then
				Details:DestroyCombat(thisCombatObject)
			end
		end

		--the current combat when finished will be moved to the first index of "segmentsTable", need the check if the current combat was already destroyed
		if (not currentCombat.__destroyed) then
			Details:DestroyCombat(currentCombat)
		end

		--destroy the overall combat object
		Details:DestroyCombat(Details.tabela_overall)
	end

	--> handle the creation of new combat objects and segment container
	do
		--create new segment container
		Details.tabela_historico = segmentClass:CreateNewSegmentDatabase()
		--create new overall combat object
		Details.tabela_overall = combatClass:NovaTabela() --joga fora a tabela antiga e cria uma nova
		--create a new current combat object
		Details.tabela_vigente = combatClass:NovaTabela(nil, Details.tabela_overall)

		--create new container to store pets
		petContainer.Reset()
		petContainer.PetScan("ResetAllCombatData")
	end

	---@type instance[]
	local allInstances = Details:GetAllInstances()

	for i = 1, #allInstances do
		---@type instance
		local instance = allInstances[i]
		if (instance:IsEnabled()) then
			Details:UpdateCombatObjectInUse(instance)
		end
	end

	--marca o addon como fora de combate
	Details.in_combat = false
	--zera o contador de combates
	Details:GetOrSetCombatId(0)

	--reinicia a time machine
	Details222.TimeMachine.Restart()
	Details:UpdateParserGears()

	if (not InCombatLockdown() and not UnitAffectingCombat("player")) then
		--workarround for the "script run too long" issue while outside the combat lockdown
		local cleargarbage = function()
			collectgarbage()
		end
		local successful, errortext = pcall(cleargarbage)
		if (not successful) then
			if (Details.debug) then
				Details:Msg("couldn't call collectgarbage()")
			end
		end
	else
		Details.schedule_hard_garbage_collect = true
	end

	Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse) -- atualiza o instancia.showing para as novas tabelas criadas
	Details:InstanceCallDetailsFunc(Details.AtualizaSoloMode_AfertReset) -- verifica se precisa zerar as tabela da janela solo mode
	Details:InstanceCallDetailsFunc(Details.ResetaGump) --_detalhes:ResetaGump("de todas as instancias")
	Details:InstanceCallDetailsFunc(Details.FadeHandler.Fader, "IN", nil, "barras")

	Details:RefreshMainWindow(-1) --atualiza todas as instancias

	Details:SendEvent("DETAILS_DATA_RESET", nil, nil)
	Details:SendEvent("DETAILS_DATA_SEGMENTREMOVED")
end

function Details.refresh:r_historico(este_historico)
	setmetatable(este_historico, segmentClass)
	--este_historico.__index = historico
end
