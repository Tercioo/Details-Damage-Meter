
do

	local Details = _G.Details
	local addonName, Details222 = ...
	Details.EncounterInformation = {}
	local ipairs = ipairs --lua local
	local detailsFramework = DetailsFramework

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--details api functions

	--return if the player is inside a raid supported by details
	function Details:IsInInstance()
		local _, _, _, _, _, _, _, zoneMapID = GetInstanceInfo()
		if (Details.EncounterInformation [zoneMapID]) then
			return true
		else
			return false
		end
	end

	--return the full table with all data for the instance
	function Details:GetRaidInfoFromEncounterID (encounterID, encounterEJID)
		for id, raidTable in pairs(Details.EncounterInformation) do
			if (encounterID) then
				local ids = raidTable.encounter_ids2 --combatlog
				if (ids) then
					if (ids [encounterID]) then
						return raidTable
					end
				end
			end
			if (encounterEJID) then
				local ejids = raidTable.encounter_ids --encounter journal
				if (ejids) then
					if (ejids [encounterEJID]) then
						return raidTable
					end
				end
			end
		end
	end

	--return the ids of trash mobs in the instance
	function Details:GetInstanceTrashInfo (mapid)
		return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].trash_ids
	end

	function Details:GetInstanceIdFromEncounterId (encounterId)
		for id, instanceTable in pairs(Details.EncounterInformation) do
			--combatlog encounter id
			local ids = instanceTable.encounter_ids2
			if (ids) then
				if (ids[encounterId]) then
					return id
				end
			end
			--encounter journal id
			local ids_ej = instanceTable.encounter_ids
			if (ids) then
				if (ids_ej[encounterId]) then
					return id
				end
			end
		end
	end

	--return the boss table using a encounter id
	function Details:GetBossEncounterDetailsFromEncounterId (mapid, encounterid)
		if (not mapid) then
			local bossIndex, instance
			for id, instanceTable in pairs(Details.EncounterInformation) do
				local ids = instanceTable.encounter_ids2
				if (ids) then
					bossIndex = ids [encounterid]
					if (bossIndex) then
						instance = instanceTable
						break
					end
				end
			end

			if (instance) then
				local bosses = instance.encounters
				if (bosses) then
					return bosses [bossIndex], instance
				end
			end

			return
		end

		local bossindex = Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounter_ids and Details.EncounterInformation [mapid].encounter_ids [encounterid]
		if (bossindex) then
			return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounters [bossindex], bossindex
		else
			local bossindex = Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounter_ids2 and Details.EncounterInformation [mapid].encounter_ids2 [encounterid]
			if (bossindex) then
				return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounters [bossindex], bossindex
			end
		end
	end

	--return the EJ boss id
	function Details:GetEncounterIdFromBossIndex (mapid, index)
		return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounter_ids and Details.EncounterInformation [mapid].encounter_ids [index]
	end

	--return the table which contain information about the start of a encounter
	function Details:GetEncounterStartInfo (mapid, encounterid)
		local bossindex = Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounter_ids and Details.EncounterInformation [mapid].encounter_ids [encounterid]
		if (bossindex) then
			return Details.EncounterInformation [mapid].encounters [bossindex] and Details.EncounterInformation [mapid].encounters [bossindex].encounter_start
		end
	end

	--generic boss find function
	function Details:GetRaidBossFindFunction (mapid)
		return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].find_boss_encounter
	end

	--return if the boss need sync
	function Details:GetEncounterEqualize (mapid, bossindex)
		return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounters [bossindex] and Details.EncounterInformation [mapid].encounters [bossindex].equalize
	end

	--return the boss table with information about name, adds, spells, etc
	function Details:GetBossDetails (mapid, bossindex)
		return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounters [bossindex]
	end

	--return a table with all names of boss enemies
	function Details:GetEncounterActors (mapid, bossindex)

	end

	--return a table with spells id of specified encounter
	function Details:GetEncounterSpells (mapid, bossindex)
		local encounter = Details:GetBossDetails (mapid, bossindex)
		local habilidades_poll = {}
		if (encounter.continuo) then
			for index, spellid in ipairs(encounter.continuo) do
				habilidades_poll [spellid] = true
			end
		end
		local fases = encounter.phases
		if (fases) then
			for fase_id, fase in ipairs(fases) do
				if (fase.spells) then
					for index, spellid in ipairs(fase.spells) do
						habilidades_poll [spellid] = true
					end
				end
			end
		end
		return habilidades_poll
	end

	--return a table with all boss ids from a raid instance
	function Details:GetBossIds (mapid)
		return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].boss_ids
	end

	function Details:InstanceIsRaid (mapid)
		return Details:InstanceisRaid (mapid)
	end
	function Details:InstanceisRaid (mapid)
		return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].is_raid
	end

	--return a table with all encounter names present in raid instance
	function Details:GetBossNames(mapId)
		return Details.EncounterInformation[mapId] and Details.EncounterInformation[mapId].boss_names
	end

	--return the encounter name
	function Details:GetBossName(mapid, bossindex)
		return Details.EncounterInformation[mapid] and Details.EncounterInformation[mapid].boss_names[bossindex]
	end

	--same thing as GetBossDetails, just a alias
	function Details:GetBossEncounterDetails (mapid, bossindex)
		return Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounters [bossindex]
	end

	---return a textureId, width, height, left, right, top, bottom coords
	---@param encounterName string
	---@return any
	---@return width
	---@return height
	---@return number
	---@return number
	---@return number
	---@return number
	function Details:GetBossEncounterTexture(encounterName)
		assert(type(encounterName) == "string", "bad argument #1 to 'GetBossEncounterTexture' (string expected, got " .. type(encounterName) .. ")")
		encounterName = string.lower(encounterName)

		if (Details.boss_icon_cache[encounterName]) then
			return Details.boss_icon_cache[encounterName], 32, 20, 0, 1, 0, 0.9
		end

		local EJ_GetInstanceByIndex = EJ_GetInstanceByIndex or function(instanceIndex, bIsRaidInstance) return nil end
		local EJ_GetEncounterInfoByIndex = EJ_GetEncounterInfoByIndex or function(index, instanceID) return nil end
		local EJ_GetCreatureInfo = EJ_GetCreatureInfo or function(index, bossId) return nil end

		---@type boolean
		local bIsRaidInstance = true

		---starts on DragonIsles world bosses > Vault of Incarnates > Aberrus, The Shadowed Crucible
		---could go to 10 for less maintenance
		---@type number
		local maxInstancesInCurrentPath = 3
		for instanceIndex = 1, maxInstancesInCurrentPath do
			local instanceID = EJ_GetInstanceByIndex(instanceIndex, bIsRaidInstance)
			if (instanceID) then
				detailsFramework.EncounterJournal.EJ_SelectInstance(instanceID)
				--we don't know how many bosses are in the instance, so we'll just loop through them all
				for i = 1, 20 do
					local name, description, bossID, rootSectionID, link, journalInstanceID, dungeonEncounterID, UiMapID = EJ_GetEncounterInfoByIndex(i, instanceID)
					--print(name, bossID)
					if (name) then
						name = name:lower()
						if (name == encounterName) then
							local id, creatureName, creatureDescription, displayInfo, iconImage = EJ_GetCreatureInfo(1, bossID)
							Details.boss_icon_cache[encounterName] = iconImage
							return iconImage, 32, 20, 0, 1, 0, 0.9
						end
					else
						--no more bosses in this instance, go to the next one
						break
					end
				end
			end
		end

		return ""
	end

	function Details:GetEncounterInfoFromEncounterName (EJID, encountername)
		DetailsFramework.EncounterJournal.EJ_SelectInstance (EJID) --11ms per call
		for i = 1, 20 do
			local name = DetailsFramework.EncounterJournal.EJ_GetEncounterInfoByIndex (i, EJID)
			if (not name) then
				return
			end
			if (name == encountername or name:find(encountername)) then
				return i, DetailsFramework.EncounterJournal.EJ_GetEncounterInfoByIndex (i, EJID)
			end
		end
	end

	--return the wallpaper for the raid instance
	function Details:GetRaidBackground (mapid)
		local bosstables = Details.EncounterInformation [mapid]
		if (bosstables) then
			local bg = bosstables.backgroundFile
			if (bg) then
				return bg.file, unpack(bg.coords)
			end
		end
	end
	--return the icon for the raid instance
	function Details:GetRaidIcon (mapid, ejID, instanceType)
		local raidIcon = Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].icon
		if (raidIcon) then
			return raidIcon
		end

		if (ejID and ejID ~= 0) then
			local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = DetailsFramework.EncounterJournal.EJ_GetInstanceInfo (ejID)
			if (name) then
				if (instanceType == "party") then
					return loreImage --bgImage
				elseif (instanceType == "raid") then
					return loreImage
				end
			end
		end

		return nil
	end

	function Details:GetBossIndex (mapid, encounterCLID, encounterEJID, encounterName)
		local raidInfo = Details.EncounterInformation [mapid]
		if (raidInfo) then
			local index = raidInfo.encounter_ids2 [encounterCLID] or raidInfo.encounter_ids [encounterEJID]
			if (not index) then
				for i = 1, #raidInfo.boss_names do
					if (raidInfo.boss_names [i] == encounterName) then
						index = i
						break
					end
				end
			end
			return index
		end
	end

	--return the boss icon
	function Details:GetBossIcon (mapid, bossindex)
		if (Details.EncounterInformation [mapid]) then
			local line = math.ceil (bossindex / 4)
			local x = ( bossindex - ( (line-1) * 4 ) )  / 4
			return x-0.25, x, 0.25 * (line-1), 0.25 * line, Details.EncounterInformation [mapid].icons
		end
	end

	--return the boss portrit
	function Details:GetBossPortrait(mapid, bossindex, encounterName, ejID)
		if (mapid and bossindex) then
			local haveIcon = Details.EncounterInformation [mapid] and Details.EncounterInformation [mapid].encounters [bossindex] and Details.EncounterInformation [mapid].encounters [bossindex].portrait
			if (haveIcon) then
				return haveIcon
			end
		end

		if (encounterName and ejID and ejID ~= 0) then
			local index, name, description, encounterID, rootSectionID, link = Details:GetEncounterInfoFromEncounterName (ejID, encounterName)

			if (index and name and encounterID) then
				local id, name, description, displayInfo, iconImage = DetailsFramework.EncounterJournal.EJ_GetCreatureInfo (1, encounterID)
				if (iconImage) then
					return iconImage
				end
			end
		end

		return nil
	end

	--return a list with names of adds and bosses
	function Details:GetEncounterActorsName (EJ_EncounterID)
		--code snippet from wowpedia
		local actors = {}
		local stack, encounter, _, _, curSectionID = {}, DetailsFramework.EncounterJournal.EJ_GetEncounterInfo (EJ_EncounterID)

		if (not curSectionID) then
			return actors
		end

		repeat
			local title, description, depth, abilityIcon, displayInfo, siblingID, nextSectionID, filteredByDifficulty, link, startsOpen, flag1, flag2, flag3, flag4 = DetailsFramework.EncounterJournal.EJ_GetSectionInfo (curSectionID)
			if (displayInfo ~= 0 and abilityIcon == "") then
				actors [title] = {model = displayInfo, info = description}
			end
			table.insert(stack, siblingID)
			table.insert(stack, nextSectionID)
			curSectionID = table.remove (stack)
		until not curSectionID

		return actors
	end

	function Details:GetInstanceEJID(mapId)
		mapId = mapId or select(8, GetInstanceInfo())
		if (mapId) then
			local instanceInfo = Details.EncounterInformation[mapId]
			if (instanceInfo) then
				return instanceInfo.ej_id or 0
			end
		end
		return 0
	end

	function Details:GetCurrentDungeonBossListFromEJ()
		local mapID = C_Map.GetBestMapForUnit ("player")

		if (not mapID) then
			return
		end

		local instanceId = DetailsFramework.EncounterJournal.EJ_GetInstanceForMap(mapID)

		if (instanceId and instanceId ~= 0) then
			if (Details.encounter_dungeons[instanceId]) then
				return Details.encounter_dungeons[instanceId]
			end

			DetailsFramework.EncounterJournal.EJ_SelectInstance(instanceId)
			local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = DetailsFramework.EncounterJournal.EJ_GetInstanceInfo(instanceId)

			local bossList = {
				[instanceId] = {name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link}
			}

			for i = 1, 20 do
				local encounterName, description, encounterID, rootSectionID, link = DetailsFramework.EncounterJournal.EJ_GetEncounterInfoByIndex(i, instanceId)
				if (encounterName) then
					for o = 1, 6 do
						local id, creatureName, creatureDescription, displayInfo, iconImage = DetailsFramework.EncounterJournal.EJ_GetCreatureInfo(o, encounterID)
						if (id) then
							bossList[creatureName] = {encounterName, encounterID, creatureName, iconImage, instanceId}
						else
							break
						end
					end
				else
					break
				end
			end

			Details.encounter_dungeons[instanceId] = bossList
			return bossList
		end
	end

	function Details:IsRaidRegistered(mapId)
		return Details.EncounterInformation[mapId] and true
	end

	--this cache is local and isn't shared with other components of the addon
	local expansionBossList_Cache = {build = false}

	function Details:GetExpansionBossList() --~bosslist - load on demand from gears-gsync and statistics-valid boss for exp
		if (expansionBossList_Cache.build) then
			return expansionBossList_Cache.bossIndexedTable, expansionBossList_Cache.bossInfoTable, expansionBossList_Cache.raidInfoTable
		end

		local bossIndexedTable = {}
		local bossInfoTable = {} --[bossId] = bossInfo
		local raidInfoTable = {}

		--check if can load the adventure guide on demand
		if (not EncounterJournal_LoadUI) then
			return bossIndexedTable, bossInfoTable, raidInfoTable

		--don't load if details! isn't full loaded
		elseif (not Details.AddOnStartTime) then
			return bossIndexedTable, bossInfoTable, raidInfoTable

		--don't load at login where other addons are still getting their stuff processing
		elseif (Details.AddOnStartTime + 10 > GetTime()) then
			return bossIndexedTable, bossInfoTable, raidInfoTable
		end

		for instanceIndex = 10, 2, -1 do
			local raidInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID = EJ_GetInstanceByIndex(instanceIndex, true)
			if (raidInstanceID) then
				--EncounterJournal_DisplayInstance(raidInstanceID)
				EJ_SelectInstance(raidInstanceID)

				raidInfoTable[raidInstanceID] = {
					raidName = instanceName,
					raidIcon = buttonImage1,
					raidIconCoords = {0.01, .67, 0.025, .725},
					raidIconSize = {70, 36},
					raidIconTexture = buttonImage2,
					raidIconTextureCoords = {0, 1, 0, 0.95},
					raidIconTextureSize = {70, 36},
					raidIconLore = loreImage,
					raidIconLoreCoords = {0, 1, 0, 0.95},
					raidIconLoreSize = {70, 36},
					raidMapID = dungeonAreaMapID,
					raidEncounters = {},
				}

				for i = 20, 1, -1 do
					local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, UiMapID = EJ_GetEncounterInfoByIndex(i, raidInstanceID)
					if (name) then
						local id, creatureName, creatureDescription, displayInfo, iconImage = EJ_GetCreatureInfo(1, journalEncounterID)
						local thisbossIndexedTable = {
							bossName = name,
							journalEncounterID = journalEncounterID,
							bossRaidName = instanceName,
							bossIcon = iconImage,
							bossIconCoords = {0, 1, 0, 0.95},
							bossIconSize = {70, 36},
							instanceId = raidInstanceID,
							uiMapId = UiMapID,
							instanceIndex = instanceIndex,
							journalInstanceId = journalInstanceID,
							dungeonEncounterID = dungeonEncounterID,
						}
						bossIndexedTable[#bossIndexedTable+1] = thisbossIndexedTable
						bossInfoTable[journalEncounterID] = thisbossIndexedTable
					end
				end
			end
		end

		expansionBossList_Cache.bossIndexedTable = bossIndexedTable
		expansionBossList_Cache.bossInfoTable = bossInfoTable
		expansionBossList_Cache.raidInfoTable = raidInfoTable
		expansionBossList_Cache.build = true

		C_Timer.After(0.5, function()
			if (EncounterJournal_ResetDisplay) then
				EncounterJournal_ResetDisplay(nil, "none")
			end
		end)

		return bossIndexedTable, bossInfoTable, raidInfoTable
	end

	function Details222.EJCache.GetInstanceData(...)
		for i = 1, select("#", ...) do
			local value = select(i, ...)
			local instanceData = Details222.EJCache.GetInstanceDataByName(value) or Details222.EJCache.GetInstanceDataByInstanceId(value) or Details222.EJCache.GetInstanceDataByMapId(value)
			if (instanceData) then
				return instanceData
			end
		end
	end

	function Details222.EJCache.GetEncounterDataFromInstanceData(instanceData, ...)
		if (not instanceData) then
			if (Details.debug) then
				Details:Msg("GetEncounterDataFromInstanceData expects instanceData on first parameter.")
			end
		end

		for i = 1, select("#", ...) do
			local value = select(i, ...)
			if (value) then
				local encounterData = instanceData.encountersArray[value]
				if (encounterData) then
					return encounterData
				end

				encounterData = instanceData.encountersByName[value]
				if (encounterData) then
					return encounterData
				end

				encounterData = instanceData.encountersByDungeonEncounterId[value]
				if (encounterData) then
					return encounterData
				end

				encounterData = instanceData.encountersByJournalEncounterId[value]
				if (encounterData) then
					return encounterData
				end
			end
		end
	end

	function Details222.EJCache.GetInstanceDataByName(instanceName)
		local raidData = Details222.EJCache.CacheRaidData_ByInstanceName[instanceName]
		local dungeonData = Details222.EJCache.CacheDungeonData_ByInstanceName[instanceName]
		return raidData or dungeonData
	end
	function Details222.EJCache.GetInstanceDataByInstanceId(instanceId)
		local raidData = Details222.EJCache.CacheRaidData_ByInstanceId[instanceId]
		local dungeonData = Details222.EJCache.CacheDungeonData_ByInstanceId[instanceId]
		return raidData or dungeonData
	end
	function Details222.EJCache.GetInstanceDataByMapId(mapId)
		local raidData = Details222.EJCache.CacheRaidData_ByMapId[mapId]
		local dungeonData = Details222.EJCache.CacheDungeonData_ByMapId[mapId]
		return raidData or dungeonData
	end

	function Details222.EJCache.GetRaidDataByName(instanceName)
		return Details222.EJCache.CacheRaidData_ByInstanceName[instanceName]
	end
	function Details222.EJCache.GetRaidDataByInstanceId(instanceId)
		return Details222.EJCache.CacheRaidData_ByInstanceId[instanceId]
	end
	function Details222.EJCache.GetRaidDataByMapId(instanceId)
		return Details222.EJCache.CacheRaidData_ByMapId[instanceId]
	end

	function Details222.EJCache.GetDungeonDataByName(instanceName)
		return Details222.EJCache.CacheDungeonData_ByInstanceName[instanceName]
	end
	function Details222.EJCache.GetDungeonDataByInstanceId(instanceId)
		return Details222.EJCache.CacheDungeonData_ByInstanceId[instanceId]
	end
	function Details222.EJCache.GetDungeonDataByMapId(instanceId)
		return Details222.EJCache.CacheDungeonData_ByMapId[instanceId]
	end

	function Details222.EJCache.MakeCache()
		Details222.EJCache.CacheRaidData_ByInstanceId = {}
		Details222.EJCache.CacheRaidData_ByInstanceName = {} --this is localized name
		Details222.EJCache.CacheRaidData_ByMapId = {} --retrivied from GetInstanceInfo()

		Details222.EJCache.CacheDungeonData_ByInstanceId = {}
		Details222.EJCache.CacheDungeonData_ByInstanceName = {}
		Details222.EJCache.CacheDungeonData_ByMapId = {}

		--exit this function if is classic wow using DetailsFramework
		if (DetailsFramework.IsClassicWow()) then
			return
		end

		if (not EncounterJournal_LoadUI) then
			return
		end

		--todo generate encounter spells cache

		--delay the cache createation as it is not needed right away
		--createEJCache() will check if encounter journal is loaded, if not it will load it and then create the cache
		local createEJCache = function()
			--[[hooksecurefunc("EncounterJournal_OpenJournalLink", Details222.EJCache.OnClickEncounterJournalLink)]]

			---iterate among all raid instances, by passing true in the second argument of EJ_GetInstanceByIndex, indicates to the API we want to get raid instances
			---@type boolean
			local bGetRaidInstances = true

			---returns the number of valid encounter journal tier indices
			---@type number
			local tierAmount = EJ_GetNumTiers()

			---returns the currently active encounter journal tier index
			---@type number
			local currentTier = EJ_GetCurrentTier()

			---increment this each expansion
			---@type number
			local currentTierId = 10 --maintenance | 10 is "Dragonflight"

			---is the id of where it shows the mythic+ dungeons available for the season
			---can be found in the adventure guide in the dungeons tab > dropdown
			---@type number
			local currentMythicPlusTierId = 11 --maintenance | 11 is "Current Season"

			---maximum amount of raid tiers in the expansion
			---@type number
			local maxAmountOfRaidTiers = 10

			---maximum amount of dungeons in the expansion
			---@type number
			local maxAmountOfDungeons = 20

			---the index of the first raid tier in the expansion, ignoring the first tier as it is open world bosses
			---@type number
			local raidTierStartIndex = 2

			---max amount of bosses which a raid tier can have
			---@type number
			local maxRaidBosses = 20

			do --get raid instances data
				--EncounterJournalRaidTab:Click()
				--EncounterJournal_TierDropDown_Select(_, 10) --select Dragonflight
				EJ_SelectTier(currentTierId)

				for instanceIndex = maxAmountOfRaidTiers, raidTierStartIndex, -1 do
					local journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID = EJ_GetInstanceByIndex(instanceIndex, bGetRaidInstances)

					if (journalInstanceID) then
						--tell the encounter journal to display the raid instance by the instanceId
						--EncounterJournal_DisplayInstance(journalInstanceID)
						EJ_SelectInstance(journalInstanceID)

						--build a table with data of the raid instance
						local instanceData = {
							name = instanceName,
							mapId = dungeonAreaMapID,
							bgImage = bgImage,
							instanceId = journalInstanceID,

							encountersArray = {},
							encountersByName = {},
							encountersByDungeonEncounterId = {},
							encountersByJournalEncounterId = {},

							icon = buttonImage1,
							iconSize = {70, 36},
							iconCoords = {0.01, .67, 0.025, .725},

							iconLore = loreImage,
							iconLoreSize = {70, 36},
							iconLoreCoords = {0, 1, 0, 0.95},

							iconTexture = buttonImage2,
							iconTextureSize = {70, 36},
							iconTextureCoords = {0, 1, 0, 0.95},
						}

						--cache the raidData on different tables using different indexes
						Details222.EJCache.CacheRaidData_ByInstanceId[journalInstanceID] = instanceData
						Details222.EJCache.CacheRaidData_ByInstanceName[instanceName] = instanceData
						Details222.EJCache.CacheRaidData_ByMapId[dungeonAreaMapID] = instanceData

						for encounterIndex = 1, maxRaidBosses do
							local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, UiMapID = EJ_GetEncounterInfoByIndex(encounterIndex, journalInstanceID)

							if (name) then
								local encounterData = {
									name = name,
									mapId = dungeonAreaMapID,
									uiMapId = UiMapID,
									dungeonEncounterId = dungeonEncounterID,
									journalEncounterId = journalEncounterID,
									journalInstanceId = journalInstanceID,
								}

								local journalEncounterCreatureId, creatureName, creatureDescription, creatureDisplayID, iconImage, uiModelSceneID = EJ_GetCreatureInfo(1, journalEncounterID)
								if (journalEncounterCreatureId) then
									encounterData.creatureName = creatureName
									encounterData.creatureIcon = iconImage
									encounterData.creatureId = journalEncounterCreatureId
									encounterData.creatureDisplayId = creatureDisplayID
									encounterData.creatureUIModelSceneId = uiModelSceneID
								end

								instanceData.encountersArray[#instanceData.encountersArray+1] = encounterData
								instanceData.encountersByName[name] = encounterData
								instanceData.encountersByDungeonEncounterId[dungeonEncounterID] = encounterData
								instanceData.encountersByJournalEncounterId[journalEncounterID] = encounterData
							end
						end
					end
				end
			end

			do --get current expansion dungeon instances data and mythic+ data
				bGetRaidInstances = false

				--get mythic+ dungeon data
				EJ_SelectTier(currentMythicPlusTierId)

				for instanceIndex = maxAmountOfDungeons, 1, -1 do
					local journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID = EJ_GetInstanceByIndex(instanceIndex, bGetRaidInstances)
					if (journalInstanceID) then
						EJ_SelectInstance(journalInstanceID)

						--build a table with data of the raid instance
						local instanceData = {
							name = instanceName,
							mapId = dungeonAreaMapID,
							bgImage = bgImage,
							instanceId = journalInstanceID,

							encountersArray = {},
							encountersByName = {},
							encountersByDungeonEncounterId = {},
							encountersByJournalEncounterId = {},

							icon = buttonImage1,
							iconSize = {70, 36},
							iconCoords = {0.01, .67, 0.025, .725},

							iconLore = loreImage,
							iconLoreSize = {70, 36},
							iconLoreCoords = {0, 1, 0, 0.95},

							iconTexture = buttonImage2,
							iconTextureSize = {70, 36},
							iconTextureCoords = {0, 1, 0, 0.95},
						}

						--cache the raidData on different tables using different indexes
						Details222.EJCache.CacheDungeonData_ByInstanceId[journalInstanceID] = instanceData
						Details222.EJCache.CacheDungeonData_ByInstanceName[instanceName] = instanceData
						Details222.EJCache.CacheDungeonData_ByMapId[dungeonAreaMapID] = instanceData

						--iterate among all encounters of the dungeon instance
						for encounterIndex = 1, 20 do
							local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, UiMapID = _G.EJ_GetEncounterInfoByIndex(encounterIndex, journalInstanceID)

							if (name) then
								local encounterData = {
									name = name,
									mapId = dungeonAreaMapID,
									uiMapId = UiMapID,
									dungeonEncounterId = dungeonEncounterID,
									journalEncounterId = journalEncounterID,
									journalInstanceId = journalInstanceID,
								}

								local journalEncounterCreatureId, creatureName, creatureDescription, creatureDisplayID, iconImage, uiModelSceneID = EJ_GetCreatureInfo(1, journalEncounterID)
								if (journalEncounterCreatureId) then
									encounterData.creatureName = creatureName
									encounterData.creatureIcon = iconImage
									encounterData.creatureId = journalEncounterCreatureId
									encounterData.creatureDisplayId = creatureDisplayID
									encounterData.creatureUIModelSceneId = uiModelSceneID
								end

								instanceData.encountersArray[#instanceData.encountersArray+1] = encounterData
								instanceData.encountersByName[name] = encounterData
								instanceData.encountersByDungeonEncounterId[dungeonEncounterID] = encounterData
								instanceData.encountersByJournalEncounterId[journalEncounterID] = encounterData
							end
						end
					end
				end

				--get current expansion dungeons data
				EJ_SelectTier(currentTierId)

				for instanceIndex = 20, 1, -1 do
					local journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID = EJ_GetInstanceByIndex(instanceIndex, bGetRaidInstances)

					if (journalInstanceID and not Details222.EJCache.CacheDungeonData_ByInstanceId[journalInstanceID]) then
						--tell the encounter journal to display the dungeon instance by the instanceId
						EJ_SelectInstance(journalInstanceID)

						--build a table with data of the raid instance
						local instanceData = {
							name = instanceName,
							mapId = dungeonAreaMapID,
							bgImage = bgImage,
							instanceId = journalInstanceID,

							encountersArray = {},
							encountersByName = {},
							encountersByDungeonEncounterId = {},
							encountersByJournalEncounterId = {},

							icon = buttonImage1,
							iconSize = {70, 36},
							iconCoords = {0.01, .67, 0.025, .725},

							iconLore = loreImage,
							iconLoreSize = {70, 36},
							iconLoreCoords = {0, 1, 0, 0.95},

							iconTexture = buttonImage2,
							iconTextureSize = {70, 36},
							iconTextureCoords = {0, 1, 0, 0.95},
						}

						--cache the raidData on different tables using different indexes
						Details222.EJCache.CacheDungeonData_ByInstanceId[journalInstanceID] = instanceData
						Details222.EJCache.CacheDungeonData_ByInstanceName[instanceName] = instanceData
						Details222.EJCache.CacheDungeonData_ByMapId[dungeonAreaMapID] = instanceData

						--iterate among all encounters of the dungeon instance
						for encounterIndex = 1, 20 do
							local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, UiMapID = _G.EJ_GetEncounterInfoByIndex(encounterIndex, journalInstanceID)
							if (name) then

								local encounterData = {
									name = name,
									mapId = dungeonAreaMapID,
									uiMapId = UiMapID,
									dungeonEncounterId = dungeonEncounterID,
									journalEncounterId = journalEncounterID,
									journalInstanceId = journalInstanceID,
								}

								local journalEncounterCreatureId, creatureName, creatureDescription, creatureDisplayID, iconImage, uiModelSceneID = EJ_GetCreatureInfo(1, journalEncounterID)
								if (journalEncounterCreatureId) then
									encounterData.creatureName = creatureName
									encounterData.creatureIcon = iconImage
									encounterData.creatureId = journalEncounterCreatureId
									encounterData.creatureDisplayId = creatureDisplayID
									encounterData.creatureUIModelSceneId = uiModelSceneID
								end

								instanceData.encountersArray[#instanceData.encountersArray+1] = encounterData
								instanceData.encountersByName[name] = encounterData
								instanceData.encountersByDungeonEncounterId[dungeonEncounterID] = encounterData
								instanceData.encountersByJournalEncounterId[journalEncounterID] = encounterData
							end
						end
					end
				end
			end

			--reset the dungeon journal to the default state
			C_Timer.After(0.5, function()
				if (EncounterJournal_ResetDisplay) then
					EncounterJournal_ResetDisplay(nil, "none")
				end
			end)
		end

		--todo: should run one second after the player_login event or entering_world | 2023-12-05: already executing on the player_login event
		C_Timer.After(1, function()
			if (not EncounterJournal_LoadUI) then
				return
			end
			createEJCache()
		end)
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core

	function Details:InstallEncounter(InstanceTable)
		Details.EncounterInformation[InstanceTable.id] = InstanceTable
		return true
	end
end
