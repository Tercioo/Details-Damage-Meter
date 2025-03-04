
local Details = 		_G.Details
local addonName, Details222 = ...
local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
---@framework
local detailsFramework = DetailsFramework
local _



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--storage stuff ~storage

---@class details_storage_unitresult : table
---@field total number
---@field itemLevel number
---@field classId number

---@class details_encounterkillinfo : table
---@field guild guildname
---@field time unixtime
---@field date date
---@field elapsed number
---@field HEALER table<actorname, details_storage_unitresult>
---@field servertime unixtime
---@field DAMAGER table<actorname, details_storage_unitresult>

---@class details_bosskillinfo : table
---@field kills number
---@field wipes number
---@field time_fasterkill number
---@field time_fasterkill_when unixtime
---@field time_incombat number
---@field dps_best number
---@field dps_best_when unixtime
---@field dps_best_raid number
---@field dps_best_raid_when unixtime

---@class details_storage : table
---@field VERSION number the database version
---@field normal table<encounterid, details_encounterkillinfo[]>
---@field heroic table<encounterid, details_encounterkillinfo[]>
---@field mythic table<encounterid, details_encounterkillinfo[]>
---@field mythic_plus table
---@field saved_encounters table
---@field totalkills table<string, table<encounterid, details_bosskillinfo>>

---@alias details_raid_difficulties
---| "normal"
---| "heroic"
---| "mythic"
---| "raidfinder"

---@class details_storage_feature : table
---@field diffNames string[] {"normal", "heroic", "mythic", "raidfinder"}
---@field OpenRaidStorage fun():details_storage
---@field HaveDataForEncounter fun(difficulty:string, encounterId:number, guildName:string|boolean):boolean
---@field GetBestFromGuild fun(difficulty:string, encounterId:number, role:role, dps:boolean, guildName:string):actorname, details_storage_unitresult, details_encounterkillinfo
---@field GetUnitGuildRank fun(difficulty:string, encounterId:number, role:role, guildName:guildname, unitName:actorname):number?, details_storage_unitresult?, details_encounterkillinfo?
---@field GetBestFromPlayer fun(difficulty:string, encounterId:number, role:role, dps:boolean, playerName:actorname):details_storage_unitresult, details_encounterkillinfo
---@field DBGuildSync fun()

local CONST_ADDONNAME_DATASTORAGE = "Details_DataStorage"

local diffNumberToName = Details222.storage.DiffIdToName

local createStorageTables = function()
	local storageDatabase = DetailsDataStorage

	if (not storageDatabase and Details.CreateStorageDB) then
		storageDatabase = Details:CreateStorageDB()
		if (not storageDatabase) then
			return
		end

	elseif (not storageDatabase) then
		return
	end

	return storageDatabase
end

---@return details_storage?
function Details222.storage.OpenRaidStorage()
	--check if the storage is already loaded
	if (not C_AddOns.IsAddOnLoaded(CONST_ADDONNAME_DATASTORAGE)) then
		local loaded, reason = C_AddOns.LoadAddOn(CONST_ADDONNAME_DATASTORAGE)
		if (not loaded) then
			return
		end
	end

	--get the storage table
	local savedData = DetailsDataStorage

	if (not savedData and Details.CreateStorageDB) then
		savedData = Details:CreateStorageDB()
		if (not savedData) then
			return
		end

	elseif (not savedData) then
		return
	end

	return savedData
end

---check if there is data for a specific encounter and difficulty, if a guildName is passed, check if there is data for the guild
---@param difficulty string
---@param encounterId number
---@param guildName string|boolean
---@return boolean bHasData
function Details222.storage.HaveDataForEncounter(difficulty, encounterId, guildName)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()
	if (not savedData) then
		return false
	end

	difficulty = diffNumberToName[difficulty] or difficulty

	if (guildName and type(guildName) == "boolean") then
		guildName = GetGuildInfo("player")
	end

	---@type table<encounterid, details_encounterkillinfo[]>
	local encountersTable = savedData[difficulty]
	if (encountersTable) then
		local allEncountersStored = encountersTable[encounterId]
		if (allEncountersStored) then
			--didn't requested a guild name, so just return 'we have data for this encounter'
			if (not guildName) then
				return true
			end

			--data for a specific guild is requested, check if there is data for the guild
			for index, encounterKillInfo in ipairs(allEncountersStored) do
				if (encounterKillInfo.guild == guildName) then
					return true
				end
			end
		end
	end

	return false
end

---find the best unit from a specific role from a specific guild in a specific encounter and difficulty
---check all encounters saved for the guild and difficulty and return the unit with the best performance
---@param difficulty string
---@param encounterId number
---@param role role
---@param dps boolean?
---@param guildName string
---@return boolean|string playerName
---@return boolean|details_storage_unitresult storageUnitResult
---@return boolean|details_encounterkillinfo encounterKillInfo
function Details222.storage.GetBestFromGuild(difficulty, encounterId, role, dps, guildName)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return false, false, false
	end

	if (not guildName) then
		guildName = GetGuildInfo("player")
	end

	if (not guildName) then
		if (Details.debug) then
			Details:Msg("(debug) GetBestFromGuild() guild name invalid.")
		end
		return false, false, false
	end

	local best = 0
	local bestDps = 0
	local bestEncounterKillInfo
	local bestUnitName
	local bestStorageResultTable

	if (not role) then
		role = "DAMAGER"
	end

	---@type table<encounterid, details_encounterkillinfo[]>
	local encountersTable = savedData[difficulty]
	if (encountersTable) then
		local allEncountersStored = encountersTable[encounterId]
		if (allEncountersStored) then
			for index, encounterKillInfo in ipairs(allEncountersStored) do
				if (encounterKillInfo.guild == guildName) then
					---@type table<actorname, details_storage_unitresult>
					local unitListFromRole = encounterKillInfo[role]
					if (unitListFromRole) then
						for unitName, storageUnitResult in pairs(unitListFromRole) do
							if (dps) then
								if (storageUnitResult.total / encounterKillInfo.elapsed > bestDps) then
									bestDps = storageUnitResult.total / encounterKillInfo.elapsed
									bestUnitName = unitName
									bestEncounterKillInfo = encounterKillInfo
									bestStorageResultTable = storageUnitResult
								end
							else
								if (storageUnitResult.total > best) then
									best = storageUnitResult.total
									bestUnitName = unitName
									bestEncounterKillInfo = encounterKillInfo
									bestStorageResultTable = storageUnitResult
								end
							end
						end
					end
				end
			end
		end
	end

	return bestUnitName, bestStorageResultTable, bestEncounterKillInfo
end

---find and return the rank position of a unit among all other players guild
---the rank is based on the biggest total amount of damage or healing (role) done in a specific encounter and difficulty
---@param difficulty string
---@param encounterId number
---@param role role
---@param unitName actorname
---@param dps boolean?
---@param guildName guildname
---@return number? positionIndex
---@return details_storage_unitresult? storageUnitResult
---@return details_encounterkillinfo? encounterKillInfo
function Details222.storage.GetUnitGuildRank(difficulty, encounterId, role, unitName, dps, guildName)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return
	end

	if (not guildName) then
		guildName = GetGuildInfo("player")
	end

	if (not guildName) then
		if (Details.debug) then
			Details:Msg("(debug) GetBestFromGuild() guild name invalid.")
		end
		return
	end

	if (not role) then
		role = "DAMAGER"
	end

	---@class details_storage_unitscore : table
	---@field total number
	---@field persecond number
	---@field storageUnitResult details_storage_unitresult?
	---@field encounterKillInfo details_encounterkillinfo?
	---@field unitName actorname?

	---@type table<actorname, details_storage_unitscore>
	local unitScores = {}

	---@type table<encounterid, details_encounterkillinfo[]>
	local encountersTable = savedData[difficulty]
	if (encountersTable) then
		local allEncountersStored = encountersTable[encounterId]
		if (allEncountersStored) then
			for index, encounterKillInfo in ipairs(allEncountersStored) do
				if (encounterKillInfo.guild == guildName) then
					local roleTable = encounterKillInfo[role]
					for thisUnitName, storageUnitResult in pairs(roleTable) do
						---@cast storageUnitResult details_storage_unitresult
						if (not unitScores[thisUnitName]) then
							unitScores[thisUnitName] = {
								total = 0,
								persecond = 0,
								unitName = thisUnitName,
							}
						end

						--in this part the code is searching what is the performance of each unit in
						--all encounters saved for the guild in the specific difficulty and role

						local total = storageUnitResult.total
						local persecond = total / encounterKillInfo.elapsed

						if (dps) then
							if (persecond > unitScores[thisUnitName].persecond) then
								unitScores[thisUnitName].total = total
								unitScores[thisUnitName].persecond = total / encounterKillInfo.elapsed
								unitScores[thisUnitName].storageUnitResult = storageUnitResult
								unitScores[thisUnitName].encounterKillInfo = encounterKillInfo
							end
						else
							if (total > unitScores[thisUnitName].total) then
								unitScores[thisUnitName].total = total
								unitScores[thisUnitName].persecond = total / encounterKillInfo.elapsed
								unitScores[thisUnitName].storageUnitResult = storageUnitResult
								unitScores[thisUnitName].encounterKillInfo = encounterKillInfo
							end
						end
					end
				end
			end

			--if the unit requested in the function parameter is not in the unitScores table, return
			if (not unitScores[unitName]) then
				return
			end

			local sortedResults = {}
			for playerName, playerTable in pairs(unitScores) do
				playerTable[1] = playerTable.total
				playerTable[2] = playerTable.persecond
				tinsert(sortedResults, playerTable)
			end

			table.sort(sortedResults, dps and Details.Sort2 or Details.Sort1)

			for positionIndex = 1, #sortedResults do
				if (sortedResults[positionIndex].unitName == unitName) then
					local result = {positionIndex, sortedResults[positionIndex].storageUnitResult, sortedResults[positionIndex].encounterKillInfo}
					Details:Destroy(unitScores)
					Details:Destroy(sortedResults)
					return unpack(result)
				end
			end
		end
	end
    return nil, nil, nil
end


---find and return the best result from a specific unit in a specific encounter and difficulty
---@param difficulty string
---@param encounterId number
---@param role role
---@param unitName actorname
---@param dps boolean?
---@return details_storage_unitresult? storageUnitResult
---@return details_encounterkillinfo? encounterKillInfo
function Details222.storage.GetBestFromPlayer(difficulty, encounterId, role, unitName, dps)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return
	end

	---@type details_storage_unitresult
	local bestStorageUnitResult
	---@type details_encounterkillinfo
	local bestEncounterKillInfo
	local topPerSecond

	if (not role) then
		role = "DAMAGER"
	end

	local encountersTable = savedData[difficulty]
	if (encountersTable) then
		local allEncountersStored = encountersTable[encounterId]
		if (allEncountersStored) then
			for index, encounterKillInfo in ipairs(allEncountersStored) do
				local storageUnitResult = encounterKillInfo[role] and encounterKillInfo[role] [unitName]
				if (storageUnitResult) then
					if (bestStorageUnitResult) then
						if (dps) then
							if (storageUnitResult.total/encounterKillInfo.elapsed > topPerSecond) then
								bestEncounterKillInfo = encounterKillInfo
								bestStorageUnitResult = storageUnitResult
								topPerSecond = storageUnitResult.total/encounterKillInfo.elapsed
							end
						else
							if (storageUnitResult.total > bestStorageUnitResult.total) then
								bestEncounterKillInfo = encounterKillInfo
								bestStorageUnitResult = storageUnitResult
							end
						end
					else
						bestEncounterKillInfo = encounterKillInfo
						bestStorageUnitResult = storageUnitResult
						topPerSecond = storageUnitResult.total/encounterKillInfo.elapsed
					end
				end
			end
		end
	end

	return bestStorageUnitResult, bestEncounterKillInfo
end

--network
function Details222.storage.DBGuildSync()
	Details:SendGuildData("GS", "R")
end

local hasEncounterByEncounterSyncId = function(savedData, encounterSyncId)
	local minTime = encounterSyncId - 120
	local maxTime = encounterSyncId + 120

	for difficultyId, encounterIdTable in pairs(savedData or {}) do
		if (type(encounterIdTable) == "table") then
			for dungeonEncounterID, encounterTable in pairs(encounterIdTable) do
				for index, encounter in ipairs(encounterTable) do
					--check if the encounter fits in the timespam window
					if (encounter.time >= minTime and encounter.time <= maxTime) then
						return true
					end
					if (encounter.servertime) then
						if (encounter.servertime >= minTime and encounter.servertime <= maxTime) then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

local recentRequestedIDs = {}
local hasRecentRequestedEncounterSyncId = function(encounterSyncId)
	local minTime = encounterSyncId - 120
	local maxTime = encounterSyncId + 120

	for requestedID in pairs(recentRequestedIDs) do
		if (requestedID >= minTime and requestedID <= maxTime) then
			return true
		end
	end
end

local allowedBossesCached = nil
local getBossIdsForCurrentExpansion = function() --need to check this!
	if (allowedBossesCached) then
		return allowedBossesCached
	end

	--make a list of raids and bosses that belong to the current expansion
	local _, bossInfoTable = Details:GetExpansionBossList()
	local allowedBosses = {}

	for bossId, bossTable in pairs(bossInfoTable) do
		---@cast bossTable details_bossinfo
		allowedBosses[bossTable.dungeonEncounterID] = true
		allowedBosses[bossTable.journalEncounterID] = true
		allowedBosses[bossId] = true
	end

	allowedBossesCached = allowedBosses
	return allowedBosses
end

function Details:IsBossIdFromCurrentExpansion(bossId)
	local bIsCurrentExp = Details222.EJCache.IsCurrentContent(bossId)
	return bIsCurrentExp
end

function Details:IsZoneIdFromCurrentExpansion(zoneId)
	local bIsCurrentExp = Details222.EJCache.IsCurrentContent(zoneId)
	return bIsCurrentExp
end

---remote call RoS
---get the server time of each encounter defeated by the guild
---@return servertime[]
function Details222.storage.GetIDsToGuildSync()
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return {}
	end

	local myGuildName = GetGuildInfo("player")
	if (not myGuildName) then
		return {}
	end
	--myGuildName = "Patifaria"

	---@type servertime[]
	local encounterSyncIds = {}
	local allowedBosses = getBossIdsForCurrentExpansion()

	--build the encounter synchronized ID list
	for i, diffName in ipairs(Details222.storage.DiffNames) do
		---@type table<encounterid, details_encounterkillinfo>
		local encountersTable = savedData[diffName]

		for dungeonEncounterID, allEncountersStored in pairs(encountersTable) do
			if (allowedBosses[dungeonEncounterID]) then
				for index, encounterKillInfo in ipairs(allEncountersStored) do
					if (encounterKillInfo.servertime) then
						if (myGuildName == encounterKillInfo.guild) then
							tinsert(encounterSyncIds, encounterKillInfo.servertime)
						end
					end
				end
			end
		end
	end

	if (Details.debug) then
		Details:Msg("(debug) [RoS-EncounterSync] sending " .. #encounterSyncIds .. " IDs.")
	end

	return encounterSyncIds
end

--local call RoC - received the encounterSyncIds - need to know which fights is missing
---@param encounterSyncIds servertime[]
function Details222.storage.CheckMissingIDsToGuildSync(encounterSyncIds)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return
	end

	if (type(encounterSyncIds) ~= "table") then
		if (Details.debug) then
			Details:Msg("(debug) [RoS-EncounterSync] RoC encounterSyncIds isn't a table.")
		end
		return
	end

	--store the IDs which need to be sync
	local requestEncounterSyncIds = {}

	--check missing IDs
	for index, encounterSyncId in ipairs(encounterSyncIds) do
		if (not hasEncounterByEncounterSyncId(savedData, encounterSyncId)) then
			if (not hasRecentRequestedEncounterSyncId(encounterSyncId)) then
				tinsert(requestEncounterSyncIds, encounterSyncId)
				recentRequestedIDs[encounterSyncId] = true
			end
		end
	end

	if (Details.debug) then
		Details:Msg("(debug) [RoC-EncounterSync] RoS found " .. #requestEncounterSyncIds .. " encounters out dated.")
	end

	return requestEncounterSyncIds
end

--remote call RoS - build the encounter list from the encounterSyncIds
---@param encounterSyncIds servertime[]
function Details222.storage.BuildEncounterDataToGuildSync(encounterSyncIds)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return
	end

	if (type(encounterSyncIds) ~= "table") then
		if (Details.debug) then
			Details:Msg("(debug) [RoS-EncounterSync] IDsList isn't a table.")
		end
		return
	end

	local amtToSend = 0
	local maxAmount = 0

	---@type table<string, table<number, details_encounterkillinfo[]>>[]
	local encounterList = {}

	---@type table<raid_difficulty_eng_name_lowercase, table<encounterid, details_encounterkillinfo[]>>
	local currentTable = {}

	tinsert(encounterList, currentTable)

	if (Details.debug) then
		Details:Msg("(debug) [RoS-EncounterSync] the client requested " .. #encounterSyncIds .. " encounters.")
	end

	for index, encounterSyncId in ipairs(encounterSyncIds) do
		for difficulty, encountersTable in pairs(savedData) do
			---@cast encountersTable details_encounterkillinfo[]
			if (Details222.storage.DiffNamesHash[difficulty]) then --this ensures that the difficulty is valid
				for dungeonEncounterID, allEncountersStored in pairs(encountersTable) do
					for index, encounterKillInfo in ipairs(allEncountersStored) do
						---@cast encounterKillInfo details_encounterkillinfo
						if (encounterSyncId == encounterKillInfo.time or encounterSyncId == encounterKillInfo.servertime) then --the time here is always exactly
							--send this encounter
							currentTable[difficulty] = currentTable[difficulty] or {}
							currentTable[difficulty][dungeonEncounterID] = currentTable[difficulty][dungeonEncounterID] or {}

							tinsert(currentTable[difficulty][dungeonEncounterID], encounterKillInfo)

							amtToSend = amtToSend + 1
							maxAmount = maxAmount + 1

							if (maxAmount == 3) then
								currentTable = {}
								tinsert(encounterList, currentTable)
								maxAmount = 0
							end
						end
					end
				end
			end
		end
	end

	if (Details.debug) then
		Details:Msg("(debug) [RoS-EncounterSync] sending " .. amtToSend .. " encounters.")
	end

	--the resulting table is a table with subtables, each subtable has a maximum of 3 encounters on indexes 1, 2 and 3
	--resulting in
	--{
	--	{[raid_difficulty_eng_name_lowercase][encounterid] = {details_encounterkillinfo, details_encounterkillinfo, details_encounterkillinfo}},
	--  {[raid_difficulty_eng_name_lowercase][encounterid] = {details_encounterkillinfo, details_encounterkillinfo, details_encounterkillinfo}}
	--}
	return encounterList
end

--local call RoC - add the fights to the client db
function Details222.storage.AddGuildSyncData(data, source)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return
	end

	if (not data or type(data) ~= "table") then
		if (Details.debug) then
			Details:Msg("(debug) [RoC-AddGuildSyncData] data isn't a table.")
		end
		return
	end

	local addedAmount = 0
	Details.LastGuildSyncReceived = GetTime()
	local allowedBosses = getBossIdsForCurrentExpansion()

	---@cast data raid_difficulty_eng_name_lowercase, table<encounterid, details_encounterkillinfo[]>

	for difficulty, encounterIdTable in pairs(data) do
		---@cast encounterIdTable table<encounterid, details_encounterkillinfo[]>

		if (Details222.storage.DiffNamesHash[difficulty] and type(encounterIdTable) == "table") then
			for dungeonEncounterID, allEncountersStored in pairs(encounterIdTable) do
				if (type(dungeonEncounterID) == "number" and type(allEncountersStored) == "table" and allowedBosses[dungeonEncounterID]) then
					for index, encounterKillInfo in ipairs(allEncountersStored) do
						--validate the encounter
						if (type(encounterKillInfo.servertime) == "number" and type(encounterKillInfo.time) == "number" and type(encounterKillInfo.guild) == "string" and type(encounterKillInfo.date) == "string" and type(encounterKillInfo.HEALER) == "table" and type(encounterKillInfo.elapsed) == "number" and type(encounterKillInfo.DAMAGER) == "table") then
							--check if this encounter already has been added from another sync
							if (not hasEncounterByEncounterSyncId(savedData, encounterKillInfo.servertime)) then
								savedData[difficulty] = savedData[difficulty] or {}
								savedData[difficulty][dungeonEncounterID] = savedData[difficulty][dungeonEncounterID] or {}
								tinsert(savedData[difficulty][dungeonEncounterID], encounterKillInfo)

								if (_G.DetailsRaidHistoryWindow and _G.DetailsRaidHistoryWindow:IsShown()) then
									_G.DetailsRaidHistoryWindow:Refresh()
								end

								addedAmount = addedAmount + 1
							else
								if (Details.debug) then
									Details:Msg("(debug) [RoC-AddGuildSyncData] received a duplicated encounter table.")
								end
							end
						else
							if (Details.debug) then
								Details:Msg("(debug) [RoC-AddGuildSyncData] received an invalid encounter table.")
							end
						end
					end
				end
			end
		end
	end

	if (Details.debug) then
		Details:Msg("(debug) [RoC-AddGuildSyncData] added " .. addedAmount .. " to database.")
	end

	if (_G.DetailsRaidHistoryWindow and _G.DetailsRaidHistoryWindow:IsShown()) then
		_G.DetailsRaidHistoryWindow:UpdateDropdowns()
		_G.DetailsRaidHistoryWindow:Refresh()
	end
end

---@param difficulty string
---@return encounterid[]
function Details222.storage.ListEncounters(difficulty)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return {}
	end

	if (not difficulty) then
		return {}
	end

	---@type encounterid[]
	local resultTable = {}

	local encountersTable = savedData[difficulty]
	if (encountersTable) then
		for dungeonEncounterID in pairs(encountersTable) do
			tinsert(resultTable, dungeonEncounterID)
		end
	end

	return resultTable
end

---@param difficulty string
---@param dungeonEncounterID encounterid
---@param role role
---@param unitName actorname
---@return details_storage_unitresult[]
function Details222.storage.GetUnitData(difficulty, dungeonEncounterID, role, unitName)
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return {}
	end

	assert(type(unitName) == "string", "unitName must be a string.")
	assert(type(dungeonEncounterID) == "number", "dungeonEncounterID must be a string.")

	---@type details_storage_unitresult[]
	local resultTable = {}

	---@type details_encounterkillinfo[]
	local encountersTable = savedData[difficulty]
	if (encountersTable) then
		local allEncountersStored = encountersTable[dungeonEncounterID]
		if (allEncountersStored) then
			for i = 1, #allEncountersStored do
				---@type details_encounterkillinfo
				local encounterKillInfo = allEncountersStored[i]
				local playerData = encounterKillInfo[role][unitName]
				if (playerData) then
					tinsert(resultTable, playerData)
				end
			end
		end
	end

	return resultTable
end

---return a table with all encounters saved for a specific guild in a specific difficulty for a specific encounter
---@param difficulty string
---@param dungeonEncounterID encounterid
---@param guildName guildname
---@return details_encounterkillinfo[]
function Details222.storage.GetEncounterData(difficulty, dungeonEncounterID, guildName)
	---@type details_storage?
	local savedData = Details222.storage.OpenRaidStorage()

	if (not savedData) then
		return
	end

	local encountersTable = savedData[difficulty]

	assert(encountersTable, "Difficulty not found. Use: normal, heroic or mythic.")
	assert(type(dungeonEncounterID) == "number", "dungeonEncounterID must be a number.")

	---@type details_encounterkillinfo[]
	local allEncountersStored = encountersTable[dungeonEncounterID]

	local resultTable = {}

	if (not allEncountersStored) then
		return resultTable
	end

	for i = 1, #allEncountersStored do
		local encounterKillInfo = allEncountersStored[i]
		if (encounterKillInfo.guild == guildName) then
			tinsert(resultTable, encounterKillInfo)
		end
	end

	return resultTable
end

---load the storage addon when the player leave combat, this function is also called from the parser when the player has its regen enabled
function Details.ScheduleLoadStorage()
	--check first if the storage is already loaded
	if (C_AddOns.IsAddOnLoaded(CONST_ADDONNAME_DATASTORAGE)) then
		Details.schedule_storage_load = nil
		Details222.storageLoaded = true
		return
	end

	if (InCombatLockdown() or UnitAffectingCombat("player")) then
		if (Details.debug) then
			print("|cFFFFFF00Details! storage scheduled to load (player in combat).")
		end
		--load when the player leave combat
		Details.schedule_storage_load = true
		return
	else
		if (not C_AddOns.IsAddOnLoaded(CONST_ADDONNAME_DATASTORAGE)) then
			local bSuccessLoaded, reason = C_AddOns.LoadAddOn(CONST_ADDONNAME_DATASTORAGE)
			if (not bSuccessLoaded) then
				if (Details.debug) then
					print("|cFFFFFF00Details! Storage|r: can't load storage, may be the addon is disabled.")
				end
				return
			end
			createStorageTables()
		end
	end

	if (C_AddOns.IsAddOnLoaded(CONST_ADDONNAME_DATASTORAGE)) then
		Details.schedule_storage_load = nil
		Details222.storageLoaded = true
		if (Details.debug) then
			print("|cFFFFFF00Details! storage loaded.")
		end
	else
		if (Details.debug) then
			print("|cFFFFFF00Details! fail to load storage, scheduled once again.")
		end
		Details.schedule_storage_load = true
	end
end

function Details.GetStorage()
	return DetailsDataStorage
end

--this function is used on the breakdown window to show ranking and on the main window when hovering over the spec icon
--if the storage is not loaded, it will try to load it even if the player is in combat
function Details.OpenStorage()
	--if the player is in combat, this function return false, if failed to load by other reason it returns nil
	--check if the storage is already loaded
	if (not C_AddOns.IsAddOnLoaded(CONST_ADDONNAME_DATASTORAGE)) then
		--can't open it during combat
		if (InCombatLockdown() or UnitAffectingCombat("player")) then
			if (Details.debug) then
				print("|cFFFFFF00Details! Storage|r: can't load storage due to combat.")
			end
			return false
		end

		local loaded, reason = C_AddOns.LoadAddOn(CONST_ADDONNAME_DATASTORAGE)
		if (not loaded) then
			if (Details.debug) then
				print("|cFFFFFF00Details! Storage|r: can't load storage, may be the addon is disabled.")
			end
			return
		end

		local savedData = createStorageTables()

		if (savedData and C_AddOns.IsAddOnLoaded(CONST_ADDONNAME_DATASTORAGE)) then
			Details222.storageLoaded = true
		end

		return DetailsDataStorage
	else
		return DetailsDataStorage
	end
end

Details.Database = {}

--this function is called on storewipe and storeencounter
---@return details_storage?
function Details.Database.LoadDB()
	--check if the storage is not loaded yet and try to load it
	if (not C_AddOns.IsAddOnLoaded(CONST_ADDONNAME_DATASTORAGE)) then
		local loaded, reason = C_AddOns.LoadAddOn(CONST_ADDONNAME_DATASTORAGE)
		if (not loaded) then
			if (Details.debug) then
				print("|cFFFFFF00Details! Storage|r: can't save the encounter, couldn't load DataStorage, may be the addon is disabled.")
			end
			return
		end
	end

	--get the storage table
	local savedData = _G.DetailsDataStorage

	if (not savedData and Details.CreateStorageDB) then
		savedData = Details:CreateStorageDB()
		if (not savedData) then
			if (Details.debug) then
				print("|cFFFFFF00Details! Storage|r: can't save the encounter, couldn't load DataStorage, may be the addon is disabled.")
			end
			return
		end

	elseif (not savedData) then
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: can't save the encounter, couldn't load DataStorage, may be the addon is disabled.")
		end
		return
	end

	return savedData
end

---@param savedData details_storage
function Details.Database.GetBossKillsDB(savedData)
	return savedData.totalkills
end

---@param combat combat?
function Details.Database.StoreWipe(combat)
	if (not combat) then
		combat = Details:GetCurrentCombat()
	end

	if (not combat) then
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: combat not found.")
		end
		return
	end

	local name, type, zoneDifficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()

	if (not Details:IsZoneIdFromCurrentExpansion(mapID) and not Details222.storage.IsDebug) then
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: instance not allowed.") --again
		end
		return
	end

	local bossInfo = combat:GetBossInfo()
	local dungeonEncounterID = bossInfo and bossInfo.id

	if (not dungeonEncounterID) then
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: encounter ID not found.")
		end
		return
	end

	--get the difficulty
	local _, difficulty = combat:GetDifficulty()

	--load database
	---@type details_storage?
	local savedData = Details.Database.LoadDB()
	if (not savedData) then
		return
	end

	if (IsInRaid()) then
		--total kills in a boss on raid or dungeon
		local totalKillsDataBase = Details.Database.GetBossKillsDB(savedData)

		totalKillsDataBase[difficulty] = totalKillsDataBase[difficulty] or {}
		totalKillsDataBase[difficulty][dungeonEncounterID] = totalKillsDataBase[difficulty][dungeonEncounterID] or {
			kills = 0,
			wipes = 0,
			time_fasterkill = 0,
			time_fasterkill_when = 0,
			time_incombat = 0,
			dps_best = 0,
			dps_best_when = 0,
			dps_best_raid = 0,
			dps_best_raid_when = 0
		}

		local bossData = totalKillsDataBase[difficulty][dungeonEncounterID]
		bossData.wipes = bossData.wipes + 1
	end
end

---@param combat combat
function Details.Database.StoreEncounter(combat)
	--stop execution if the expansion isn't retail
	if (not detailsFramework:IsDragonflightAndBeyond()) then
		return
	end

	combat = combat or Details:GetCurrentCombat()

	if (not combat) then
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: combat not found.")
		end
		return
	end

	local name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()

	--Details:IsZoneIdFromCurrentExpansion(select(8, GetInstanceInfo()))

	if (not Details:IsZoneIdFromCurrentExpansion(mapID) and not Details222.storage.IsDebug) then
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: instance not allowed.")
		end
		return
	end

	local encounterInfo = combat:GetBossInfo()
	local encounterId = encounterInfo and encounterInfo.id

	if (not encounterId) then
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: encounter ID not found.")
		end
		return
	end

	--get the difficulty
	local diffId, diffName = combat:GetDifficulty()
	if (Details.debug) then
		print("|cFFFFFF00Details! Storage|r: difficulty identified:", diffId, diffName)
	end

	if (not diffId or not diffName) then
		return
	end

	if (diffName == "mythicdungeon") then
		local completionInfo = C_ChallengeMode.GetChallengeCompletionInfo()
		local mapChallengeModeID = completionInfo.mapChallengeModeID
		local mythicLevel = completionInfo.level

		if (not mythicLevel and not mapChallengeModeID) then
			return
		end
	end

	if (diffName == "mythicdungeon") then
		--not yet
		return
	end

	--database
	---@type details_storage?
	local savedData = Details.Database.LoadDB()
	if (not savedData) then
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: Details.Database.LoadDB() FAILED!")
		end
		return
	end

	--[=[
		savedData[mythic] = {
			[encounterId] = { --indexed table
				[1] = {
					DAMAGER = {
						[actorname] = details_storage_unitresult
					},
					HEALER = {
						[actorname] = details_storage_unitresult
					},
					date = date("%H:%M %d/%m/%y"),
					time = time(),
					servertime = GetServerTime(),
					elapsed = combat:GetCombatTime(),
					guild = guildName,
				}
			}
		}
	--]=]

	---@type combattime
	local elapsedCombatTime = combat:GetCombatTime()

	---@type table<encounterid, details_encounterkillinfo[]>
	local encountersTable = savedData[diffName]
	if (not encountersTable) then
		Details:Msg("encountersTable not found, diffName:", diffName)
		savedData[diffName] = {}
		encountersTable = savedData[diffName]
	end

	---@type details_encounterkillinfo[]
	local allEncountersStored = encountersTable[encounterId]
	if (not allEncountersStored) then
		encountersTable[encounterId] = {}
		allEncountersStored = encountersTable[encounterId]
	end

	--total kills in a boss on raid or dungeon
	local totalkillsTable = Details.Database.GetBossKillsDB(savedData)

	--store total kills on this boss
	--if the player is facing a raid boss
	if (IsInRaid()) then
		totalkillsTable[encounterId] = totalkillsTable[encounterId] or {}
		totalkillsTable[encounterId][diffName] = totalkillsTable[encounterId][diffName] or {
			kills = 0,
			wipes = 0,
			time_fasterkill = 1000000,
			time_fasterkill_when = 0,
			time_incombat = 0,
			dps_best = 0, --player best dps
			dps_best_when = 0, --when the player did the best dps
			dps_best_raid = 0,
			dps_best_raid_when = 0
		}

		---@type details_bosskillinfo
		local bossData = totalkillsTable[encounterId][diffName]
		---@type combattime
		local encounterElapsedTime = elapsedCombatTime

		--kills amount
		bossData.kills = bossData.kills + 1

		--best time
		if (encounterElapsedTime < bossData.time_fasterkill) then
			bossData.time_fasterkill = encounterElapsedTime
			bossData.time_fasterkill_when = time()
		end

		--total time in combat
		bossData.time_incombat = bossData.time_incombat + encounterElapsedTime

		--player best dps
		---@actor
		local playerActorObject = combat(DETAILS_ATTRIBUTE_DAMAGE, Details.playername)
		if (playerActorObject) then
			local playerDps = playerActorObject.total / encounterElapsedTime
			if (playerDps > bossData.dps_best) then
				bossData.dps_best = playerDps
				bossData.dps_best_when = time()
			end
		end

		--raid best dps
		local raidTotalDamage = combat:GetTotal(DETAILS_ATTRIBUTE_DAMAGE, nil, true)
		local raidDps = raidTotalDamage / encounterElapsedTime
		if (raidDps > bossData.dps_best_raid) then
			bossData.dps_best_raid = raidDps
			bossData.dps_best_raid_when = time()
		end
	end

	--check for heroic and mythic
	if (Details222.storage.IsDebug or Details222.storage.DiffNamesHash[diffName]) then
		--check the guild name
		local match = 0
		local guildName = GetGuildInfo("player")
		local raidSize = GetNumGroupMembers() or 0

		local cachedRaidUnitIds = Details222.UnitIdCache.Raid

		if (not Details222.storage.IsDebug) then
			if (guildName) then
				for i = 1, raidSize do
					local gName = GetGuildInfo(cachedRaidUnitIds[i]) or ""
					if (gName == guildName) then
						match = match + 1
					end
				end

				if (match < raidSize * 0.75) then
					if (Details.debug) then
						print("|cFFFFFF00Details! Storage|r: can't save the encounter, need at least 75% of players be from your guild.")
					end
					return
				end
			else
				if (Details.debug) then
					print("|cFFFFFF00Details! Storage|r: player isn't in a guild.")
				end
				return
			end
		else
			guildName = "Test Guild"
		end

		---@type details_encounterkillinfo
		local combatResultData = {
			DAMAGER = {},
			HEALER = {},
			date = date("%H:%M %d/%m/%y"),
			time = time(),
			servertime = GetServerTime(),
			elapsed = elapsedCombatTime,
			guild = guildName,
		}

		local damageContainer = combat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		local healingContainer = combat:GetContainer(DETAILS_ATTRIBUTE_HEAL)

		for i = 1, GetNumGroupMembers() do
			local role = UnitGroupRolesAssigned(cachedRaidUnitIds[i])

			if (UnitIsInMyGuild(cachedRaidUnitIds[i])) then
				if (role == "DAMAGER" or role == "TANK") then
					local playerName = Details:GetFullName(cachedRaidUnitIds[i])
					local _, _, class = Details:GetUnitClassFull(playerName)

					local damagerActor = damageContainer:GetActor(playerName)
					if (damagerActor) then
						local guid = UnitGUID(cachedRaidUnitIds[i])

						---@type details_storage_unitresult
						local unitResultInfo = {
							total = floor(damagerActor.total),
							itemLevel = Details:GetItemLevelFromGuid(guid),
							classId = class or 0
						}
						combatResultData.DAMAGER[playerName] = unitResultInfo
					end

				elseif (role == "HEALER") then
					local playerName = Details:GetFullName(cachedRaidUnitIds[i])
					local _, _, class = Details:GetUnitClassFull(playerName)

					local healingActor = healingContainer:GetActor(playerName)
					if (healingActor) then
						local guid = UnitGUID(cachedRaidUnitIds[i])

						---@type details_storage_unitresult
						local unitResultInfo = {
							total = floor(healingActor.total),
							itemLevel = Details:GetItemLevelFromGuid(guid),
							classId = class or 0
						}
						combatResultData.HEALER[playerName] = unitResultInfo
					end
				end
			end
		end

		--add the encounter data
		tinsert(allEncountersStored, combatResultData)
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: combat data added to encounter database.")
		end

		local playerRole = UnitGroupRolesAssigned("player")
		---@type details_storage_unitresult, details_encounterkillinfo
		local bestRank, encounterKillInfo = Details222.storage.GetBestFromPlayer(diffName, encounterId, playerRole, Details.playername, true) --get dps or hps

		if (bestRank and encounterKillInfo) then
			local registeredBestTotal = bestRank and bestRank.total or 0
			local registeredBestPerSecond = registeredBestTotal / encounterKillInfo.elapsed

			local currentPerSecond = 0
			if (playerRole == "DAMAGER" or playerRole == "TANK") then
				---@actor
				local playerActorObject = damageContainer:GetActor(Details.playername)
				if (playerActorObject) then
					currentPerSecond = playerActorObject.total / elapsedCombatTime
				end
			elseif (playerRole == "HEALER") then
				---@actor
				local playerActorObject = healingContainer:GetActor(Details.playername)
				if (playerActorObject) then
					currentPerSecond = playerActorObject.total / elapsedCombatTime
				end
			end

			if (registeredBestPerSecond > currentPerSecond) then
				if (not Details.deny_score_messages) then
					print(Loc ["STRING_DETAILS1"] .. format(Loc ["STRING_SCORE_NOTBEST"], Details:ToK2(currentPerSecond), Details:ToK2(registeredBestPerSecond), encounterKillInfo.date, bestRank[2]))
				end
			else
				if (not Details.deny_score_messages) then
					print(Loc ["STRING_DETAILS1"] .. format(Loc ["STRING_SCORE_BEST"], Details:ToK2(currentPerSecond)))
				end
			end
		end

		local lowerInstanceId = Details:GetLowerInstanceNumber()
		if (lowerInstanceId) then
			local instanceObject = Details:GetInstance(lowerInstanceId)
			if (instanceObject) then
				if (playerRole == "TANK") then
					playerRole = "DAMAGER"
				end

				local raidName = GetInstanceInfo()
				local func = {Details.OpenRaidHistoryWindow, Details, raidName, encounterId, diffName, playerRole, guildName}
				local icon = {[[Interface\PvPRankBadges\PvPRank08]], 16, 16, false, 0, 1, 0, 1}
				if (not Details.deny_score_messages) then
					instanceObject:InstanceAlert(Loc ["STRING_GUILDDAMAGERANK_WINDOWALERT"], icon, Details.update_warning_timeout, func, true)
				end
			end
		end
	else
		if (Details.debug) then
			print("|cFFFFFF00Details! Storage|r: raid difficulty must be heroic or mythic.")
		end
	end
end
