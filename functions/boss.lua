
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
		---@type details_encounterinfo
		local encounterInfo = Details:GetEncounterInfo(encounterName)
		if (not encounterInfo) then
			--Details:Msg("did not find encounter info for: " .. (encounterName or "no-name") .. ".")
			--print(debugstack())
			return "", 32, 20, 0, 1, 0, 1
		end
		return encounterInfo.creatureIcon, 32, 20, 0, 1, 0, 0.9
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
		return raidData
	end
	function Details222.EJCache.GetInstanceDataByInstanceId(instanceId)
		local raidData = Details222.EJCache.CacheRaidData_ByInstanceId[instanceId]
		return raidData
	end
	function Details222.EJCache.GetInstanceDataByMapId(mapId)
		local raidData = Details222.EJCache.CacheRaidData_ByMapId[mapId]
		return raidData
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
		return Details222.EJCache.CacheRaidData_ByInstanceName[instanceName]
	end
	function Details222.EJCache.GetDungeonDataByInstanceId(instanceId)
		return Details222.EJCache.CacheRaidData_ByInstanceId[instanceId]
	end
	function Details222.EJCache.GetDungeonDataByMapId(instanceId)
		return Details222.EJCache.CacheRaidData_ByMapId[instanceId]
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core

	function Details:InstallEncounter(InstanceTable)
		Details.EncounterInformation[InstanceTable.id] = InstanceTable
		return true
	end
end
