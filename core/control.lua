
	local Details = 		_G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
	local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
	local _tempo = time()
	local addonName, Details222 = ...
	---@type detailsframework
	local detailsFramework = DetailsFramework
	local _

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers
	local max = math.max
	local ipairs = ipairs
	local pairs = pairs
	local bitBand = bit.band
	local GetInstanceInfo = GetInstanceInfo
	local UnitExists = UnitExists
	local UnitGUID = UnitGUID
	local GetTime = GetTime
	local IsAltKeyDown = IsAltKeyDown
	local IsShiftKeyDown = IsShiftKeyDown
	local IsControlKeyDown = IsControlKeyDown

	local damageClass = Details.atributo_damage
	local healingClass = Details.atributo_heal
	local resourceClass = Details.atributo_energy
	local utilityClass = Details.atributo_misc
	local customClass = Details.atributo_custom

	local UnitGroupRolesAssigned = DetailsFramework.UnitGroupRolesAssigned

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants
	local groupMode = Details.modos.group
	local everythingMode = Details.modos.all
	local damageAttributeId = Details.atributos.dano

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--details api functions
	---for a number to the current selected abbreviation
	--Details.ps_abbreviation tell the current abbreviation type
	---@param number number
	---@return string
	function Details:Format(number)
		return Details.ToKFunctions[Details.ps_abbreviation](nil, number)
	end

	--try to find the opponent of last fight, can be called during a fight as well
	function Details:FindEnemy()
		local zoneName, instanceType = GetInstanceInfo()
		local bIsInInstance = IsInInstance() --garrison returns party as instance type
		if ((instanceType == "party" or instanceType == "raid") and bIsInInstance) then
			if (instanceType == "party") then
				if (Details:GetBossNames(Details.zone_id)) then
					return Loc ["STRING_SEGMENT_TRASH"]
				end
			else
				return Loc ["STRING_SEGMENT_TRASH"]
			end
		end

		local currentCombat = Details:GetCurrentCombat()
		local playerActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, Details.playername)
		if (playerActorObject) then
			local targets = playerActorObject.targets

			---@type table<actorname, number>[]
			local targetsArray = {}
			for targetName, amount in pairs(targets) do
				table.insert(targetsArray, {targetName, amount})
			end

			--sort the array by amount
			table.sort(targetsArray, Details.Sort2)

			local targetName = targetsArray[1][1]

			if (targetName) then
				return targetName
			end
		end

		---@type actorcontainer
		local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		for _, actor in damageContainer:ListActors() do
			---@cast actor actor
			if (not actor:IsGroupPlayer() and not actor.owner and not actor.nome:find("[*]") and bitBand(actor.flag_original, 0x00000060) ~= 0) then --0x20+0x40 neutral + enemy reaction
				for targetName in pairs(actor.targets) do
					if (targetName == Details.playername) then
						return actor:Name()
					else
						local targetActor = damageContainer:GetActor(targetName)
						if (targetActor and targetActor:IsGroupPlayer()) then
							return actor:Name()
						end
					end
				end
			end
		end

		for _, actor in damageContainer:ListActors() do
			---@cast actor actor
			if (actor:IsGroupPlayer() and not actor.owner) then
				for targetName, _ in pairs(actor.targets) do
					return targetName
				end
			end
		end

		return Loc ["STRING_UNKNOW"]
	end

	--create and set a table in the current combat, this table store information about the boss in the current combat
	local createBossTable = function(t, zoneName, zoneMapID, difficultyID)
		local bossTable = {
			index = 0,
			name = t[1],
			encounter = t[1],
			zone = zoneName,
			mapid = zoneMapID,
			diff = difficultyID,
			diff_string = select(4, GetInstanceInfo()),
			ej_instance_id = t[5],
			id = t[2],
			bossimage = t[4],
			unixtime = time(),
		}

		local currentCombat = Details:GetCurrentCombat()
		currentCombat.is_boss = bossTable
	end

	local foundEncounterInfo = function(index, name, zone, mapId, diff, encounterid)
		local mapID = C_Map.GetBestMapForUnit("player")
		if (not mapID) then
			return
		end

		local encounterJournalId = Details:GetInstanceEJID(mapID, name, encounterid)

		local bossTable = {
			index = index,
			name = name,
			encounter = name,
			zone = zone,
			mapid = mapId,
			diff = diff,
			diff_string = select(4, GetInstanceInfo()),
			ej_instance_id = encounterJournalId,
			id = encounterid,
			unixtime = time(),
		}

		---@type details_encounterinfo
		local encounterInfo = Details:GetEncounterInfo(name)
		if (encounterInfo) then
			bossTable.bossimage = encounterInfo.creatureIcon
		end

		local currentCombat = Details:GetCurrentCombat()
		currentCombat.is_boss = bossTable

		--if the boss wasn't found during the combat creation, send the event
		if (not currentCombat.IsBeingCreated) then
			Details:SendEvent("COMBAT_BOSS_FOUND", nil, index, name)
			Details:CheckFor_SuppressedWindowsOnEncounterFound()
		end

		return bossTable
	end

	function Details:ReadBossFrames()
		---@type combat
		local currentCombat = Details:GetCurrentCombat()

		if (currentCombat:GetBossInfo()) then
			return --the combat already has a bossInfo
		end

		if (Details.encounter_table.name) then
			local encounterID = Details.encounter_table.id
			local encounterName = Details.encounter_table.name
			local zoneName = Details.encounter_table.zone
			local zoneMapID = Details.encounter_table.mapid
			local difficultyID = Details.encounter_table.diff

			local encounterTable = Details.encounter_table
			return foundEncounterInfo(encounterTable.index, encounterName, zoneName, zoneMapID, difficultyID, encounterID)
		end

		for index = 1, #Details222.UnitIdCache.Boss do
			local bossUnitId = Details222.UnitIdCache.Boss[index]
			if (UnitExists(bossUnitId)) then
				local bossGuid = UnitGUID(bossUnitId)
				if (bossGuid) then
					local npcId = Details:GetNpcIdFromGuid(bossGuid)
					if (npcId) then
						local zoneName, _, difficultyID, _, _, _, _, zoneMapID = GetInstanceInfo()
						local bossIds = Details:GetBossIds(zoneMapID)
						if (bossIds) then
							local bossIndex = bossIds[npcId]
							if (bossIndex) then
								if (Details.debug) then
									Details:Msg("(debug) boss found:", Details:GetBossName(zoneMapID, bossIndex))
								end
								return foundEncounterInfo(bossIndex, Details:GetBossName(zoneMapID, bossIndex), zoneName, zoneMapID, difficultyID)
							end
						end
					end
				end
			end
		end
	end

	--try to get the encounter name after the encounter (can be called during the combat as well)
	function Details:FindBoss(noJournalSearch)
		if (Details.encounter_table.name) then
			local encounterTable = Details.encounter_table
			return foundEncounterInfo(encounterTable.index, encounterTable.name, encounterTable.zone, encounterTable.mapid, encounterTable.diff, encounterTable.id)
		end

		---@type combat
		local currentCombat = Details:GetCurrentCombat()
		local zoneName, instanceType, difficultyID, _, _, _, _, zoneMapID = GetInstanceInfo()
		local bossIds = Details:GetBossIds(zoneMapID)

		if (bossIds) then
			---@type actorcontainer
			local damageContainer = currentCombat:GetContainer(damageAttributeId)
			for index, actorObject in damageContainer:ListActors() do
				if (not actorObject:IsGroupPlayer()) then
					local npcId = Details:GetNpcIdFromGuid(actorObject.serial)
					if (npcId) then
						local bossIndex = bossIds[npcId]
						if (bossIndex) then
							actorObject.boss = true
							return foundEncounterInfo(bossIndex, Details:GetBossName(zoneMapID, bossIndex), zoneName, zoneMapID, difficultyID)
						end
					end
				end
			end
		end

		noJournalSearch = true --disabling the scan on encounter journal

		if (not noJournalSearch) then
			local bIsInInstance = IsInInstance() --garrison returns party as instance type.
			if ((instanceType == "party" or instanceType == "raid") and bIsInInstance) then
				local bossList = Details:GetCurrentDungeonBossListFromEJ()
				if (bossList) then
					---@type actorcontainer
					local damageContainer = currentCombat:GetContainer(damageAttributeId)
					for index, actorObject in damageContainer:ListActors() do
						if (not actorObject:IsGroupPlayer()) then
							if (bossList[actorObject:Name()]) then
								actorObject.boss = true
								return createBossTable (bossList [actorObject:Name()], zoneName, zoneMapID, difficultyID)
							end
						end
					end
				end
			end
		end
		return false
	end

	local showTutorialForDiscardedSegment = function()
		--tutorial about the combat time < then 'minimum_combat_time'
		local hasSeenTutorial = Details:GetTutorialCVar("MIN_COMBAT_TIME")
		if (not hasSeenTutorial) then
			local lowerInstanceId = Details:GetLowerInstanceNumber()
			if (lowerInstanceId) then
				---@type instance
				local lowerInstanceObject = Details:GetInstance(lowerInstanceId)
				if (lowerInstanceObject) then
					lowerInstanceObject:InstanceAlert("combat ignored: less than 5 seconds.", {[[Interface\BUTTONS\UI-GROUPLOOT-PASS-DOWN]], 18, 18, false, 0, 1, 0, 1}, 20, {function() Details:Msg("combat ignored: elapsed time less than 5 seconds."); Details:Msg("add '|cFFFFFF00Details.minimum_combat_time = 2;|r' on Auto Run Code to change the minimum time.") end})
					Details:SetTutorialCVar("MIN_COMBAT_TIME", true)
				end
			end
		end
	end

	---return an array of encounter Ids in order of the most recent to the oldest
	function Details:GetEncounterIDInOrder()
		--get the segments table
		local segmentsTable = Details:GetCombatSegments()

		--table which contains the encounter Ids in order of the most recent to the oldest
		local resultTable = {}

		--iterate over the segments table from the most recent to the oldest, check if the combatObject of the segment has is_boss and get the encounter Id from the member is_boss.id
		for i = 1, #segmentsTable do
			---@type combat
			local combatObject = segmentsTable[i]
			if (combatObject.is_boss) then
				table.insert(resultTable, 1, combatObject.is_boss.id)
			end
		end

		return resultTable
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--internal functions
	function Details:StartCombat(...)
		return Details:EntrarEmCombate(...)
	end

	function Details:EntrarEmCombate(...)
		Details:Msg("deprecated path on control.lua")
		print(debugstack())
		return Details222.StartCombat(...)
	end

	-- ~start
	function Details222.StartCombat(...)
		if (Details.debug) then
			Details:Msg("(debug) |cFFFFFF00started a new combat|r|cFFFF7700", Details.encounter_table and Details.encounter_table.name or "")
			--local from = debugstack(2, 1, 0)
			--print("from:", from)
			--DetailsParserDebugFrame:Show()
		end

		local segmentsTable = Details:GetCombatSegments()

		--check if there's a 'current segment in place', if not, re-create the overall data before creating the new segment
		if (not segmentsTable[1]) then
			Details.tabela_overall = Details.combate:NovaTabela()
			Details:InstanceCallDetailsFunc(Details.ResetaGump, nil, -1) --reseta scrollbar, iterators, rodap�, etc
			Details:InstanceCallDetailsFunc(Details.InstanciaFadeBarras, -1) --esconde todas as barras
			Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse) --atualiza o showing
		end

		--get the yet 'current' combat and lock the activity time on all actors
		local pastCombatObject = Details:GetCurrentCombat()
		if (not pastCombatObject.__destroyed) then
			pastCombatObject:LockActivityTime()
		end

		---@type number increate the combat counter by 1
		local combatCounter = Details:GetOrSetCombatId(1)

		--create a new combat object and preplace the current one
		---@type combat
		local newCombatObject = Details.combate:NovaTabela(true, Details.tabela_overall, combatCounter, ...)
		Details:SetCurrentCombat(newCombatObject)

		--flag this combat as being created
		newCombatObject.IsBeingCreated = true

		--flag Details! as 'in combat'
		Details.in_combat = true

		local bSetStartTime = true
		newCombatObject:SetDateToNow(bSetStartTime)

		--set the combat id on the combat object
		newCombatObject.combat_id = combatCounter

		--clear cache
		Details.last_combat_pre_pot_used = nil

		--flags the new combat as pvp or arena match
		Details:FlagNewCombat_PVPState()

		--start the ticker to know if the player is in combat or not
		Details:StartCombatTicker()

		Details:ClearCCPetsBlackList()

		Details:Destroy(Details.encounter_end_table)
		Details:Destroy(Details.pets_ignored)
		Details:Destroy(Details.pets_no_owner)
		Details222.PetContainer.PetScan("CombatStart")

		Details:Destroy(Details.cache_damage_group)
		Details:Destroy(Details.cache_healing_group)

		local bFromCombatStart = true
		Details:UpdateParserGears(bFromCombatStart)

		--retrieve all buffs applied before the combat starts
		C_Timer.After(0.05, function()
			--wait for the initial aura wipe performed by the client in certain situations
			Details:CatchRaidBuffUptime("BUFF_UPTIME_IN")
		end)
		Details:CatchRaidDebuffUptime("DEBUFF_UPTIME_IN")
		Details:UptadeRaidMembersCache()

		--we already have boss information? build .is_boss table
		if (Details.encounter_table.id and Details.encounter_table["start"] >= GetTime() - 3 and not Details.encounter_table["end"]) then
			local encounterTable = Details.encounter_table
			--boss_found will trigger "COMBAT_BOSS_FOUND" event, but at this point of the combat creation is safe to send it
			foundEncounterInfo (encounterTable.index, encounterTable.name, encounterTable.zone, encounterTable.mapid, encounterTable.diff, encounterTable.id)
		else
			--if we don't have this infor right now, lets check in few seconds dop
			if (Details.EncounterInformation[Details.zone_id]) then
				Details:ScheduleTimer("ReadBossFrames", 1)
				Details:ScheduleTimer("ReadBossFrames", 30)
			end
		end

		--if the window is showing current segment, switch it for the new combat
		--also if the window has auto current, jump to current segment
		Details:InstanceCallDetailsFunc(Details.TrocaSegmentoAtual, Details.tabela_vigente.is_boss and true)

		--clear hosts and make the cloud capture stuff
		Details.host_of = nil
		Details.host_by = nil

		--hide / alpha / switch in combat
		for index, instancia in ipairs(Details:GetAllInstances()) do
			if (instancia.ativa) then
				instancia:CheckSwitchOnCombatStart(true)
			end
		end

		Details:InstanceCall(Details.CheckPsUpdate)

		--combat creation is completed, remove the flag
		Details.tabela_vigente.IsBeingCreated = nil

		Details:SendEvent("COMBAT_PLAYER_ENTER", nil, Details.tabela_vigente, Details.encounter_table and Details.encounter_table.id)

		if (Details.tabela_vigente.is_boss) then
			--the encounter was found through encounter_start event
			Details:SendEvent("COMBAT_BOSS_FOUND", nil, Details.tabela_vigente.is_boss.index, Details.tabela_vigente.is_boss.name)
		end

		Details:CheckSwitchToCurrent()
		Details:CheckForTextTimeCounter(true)

		--stop bar testing if any
		Details:StopTestBarUpdate()
	end

	function Details:ScheduleSyncPlayerActorData()
		--do not sync if in battleground or arena
		if ((IsInGroup() or IsInRaid()) and (Details.zone_type == "party" or Details.zone_type == "raid")) then
			--do a random delay
			local delay = RandomFloatInRange(1, 4)
			C_Timer.After(delay, Details.SendCharacterData)
		end
	end

	--alias
	function Details:EndCombat(bossKilled, bIsFromEncounterEnd)
		return Details:SairDoCombate(bossKilled, bIsFromEncounterEnd)
	end

	-- ~end ~leave
	function Details:SairDoCombate(bossKilled, bIsFromEncounterEnd)
		if (Details.debug) then
			Details:Msg("(debug) |cFFFFFF00ended a combat|r|cFFFF7700", Details.encounter_table and Details.encounter_table.name or "")
		else
			DetailsParserDebugFrame:Hide()
		end

		---@type combat
		local currentCombat = Details:GetCurrentCombat()

		Details:SendEvent("COMBAT_PLAYER_LEAVING", nil, currentCombat)

		if (currentCombat.bIsClosed) then
			return
		end
		currentCombat.bIsClosed = true

		if (currentCombat.__destroyed) then
			Details:Msg("a deleted combat was found during combat end, please report this bug on discord:")
			Details:Msg("combat destroyed by:", currentCombat.__destroyedBy)
		end

		--flag the addon as 'leaving combat'
		Details.leaving_combat = true
		--save the unixtime of the latest combat end
		Details.last_combat_time = _tempo

		Details:CatchRaidBuffUptime("BUFF_UPTIME_OUT")
		Details:CatchRaidDebuffUptime("DEBUFF_UPTIME_OUT")
		Details:CloseEnemyDebuffsUptime()
		Details222.AuraScan.CheckForOneHourBuffs()

		Details222.GuessSpecSchedules.ClearSchedules()

		--Details222.TimeCapture.StopCombat() --it did not start

		--check if this isn't a boss and try to find a boss in the segment
		if (not currentCombat.is_boss) then
			--if this is a mythic+ dungeon, do not scan for encounter journal boss names in the actor list
			Details:FindBoss()

			--still didn't find the boss
			if (not currentCombat.is_boss) then
				local zoneName, _, difficultyID, _, _, _, _, zoneMapID = GetInstanceInfo()
				local findboss = Details:GetRaidBossFindFunction(zoneMapID)
				if (findboss) then
					local bossIndex = findboss()
					if (bossIndex) then
						foundEncounterInfo(bossIndex, Details:GetBossName(zoneMapID, bossIndex), zoneName, zoneMapID, difficultyID)
					end
				end
			end
		end

		Details:OnCombatPhaseChanged()

		--stop combat ticker
		Details:StopCombatTicker()

		--lock timers
		currentCombat:LockActivityTime()

		--remove death events that are irrelevant for the death log
		currentCombat:CutDeathEventsByTime()

		--get waste shields
		if (Details.close_shields) then
			Details:CloseShields(currentCombat)
		end

		local bSetStartTime = false
		local bSetEndTime = true
		currentCombat:SetDateToNow(bSetStartTime, bSetEndTime)
		currentCombat:SetEndTime(GetTime())

		--drop player last events table to garbage collector
		currentCombat.player_last_events = {}

		--flag instance type
		local zoneName, instanceType, difficultyID, difficultyName, _, _, _, zoneMapID = GetInstanceInfo()
		currentCombat.instance_type = instanceType

		if (not currentCombat.is_boss and bIsFromEncounterEnd and type(bIsFromEncounterEnd) == "table") then
			local encounterID, encounterName, difficultyID, raidSize, endStatus = unpack(bIsFromEncounterEnd)
			if (encounterID) then
				local mapID = C_Map.GetBestMapForUnit("player")

				if (not mapID) then
					mapID = 0
				end

				local ejid = DetailsFramework.EncounterJournal.EJ_GetInstanceForMap(mapID)
				if (ejid == 0) then
					ejid = Details:GetInstanceEJID()
				end

				local _, boss_index = Details:GetBossEncounterDetailsFromEncounterId(zoneMapID, encounterID)

				currentCombat.is_boss = {
					index = boss_index or 0,
					name = encounterName,
					encounter = encounterName,
					zone = zoneName,
					mapid = zoneMapID,
					diff = difficultyID,
					diff_string = difficultyName,
					ej_instance_id = ejid or 0,
					id = encounterID,
					unixtime = time()
				}
			end
		end

		--tag as a mythic dungeon segment, can be any type of segment, this tag also avoid the segment to be tagged as trash
		local mythicLevel = C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo()
		if (mythicLevel and mythicLevel >= 2) then
			currentCombat.is_mythic_dungeon_segment = true
			currentCombat.is_mythic_dungeon_run_id = Details.mythic_dungeon_id

			if (not currentCombat.is_mythic_dungeon) then
				---@type mythicdungeoninfo
				local mythicPlusInfo = {
					ZoneName = Details.MythicPlus.DungeonName or zoneName,
					MapID = Details.MythicPlus.DungeonID or zoneMapID,
					Level = Details.MythicPlus.Level,
					EJID = Details.MythicPlus.ejID,
					RunID = Details.mythic_dungeon_id,
					StartedAt = time() - currentCombat:GetCombatTime(),
					EndedAt = time(),
					SegmentID = Details.MythicPlus.SegmentID, --segment number within the dungeon
					--default to trash
					SegmentType = DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH,
					SegmentName = "Trash #" .. (Details.MythicPlus.SegmentID or 0), --localize-me
				}
				currentCombat.is_mythic_dungeon = mythicPlusInfo
			end
		end

		--send item level after a combat if is in raid or party group
		C_Timer.After(1, Details.ScheduleSyncPlayerActorData)

		--if this segment isn't a boss fight
		if (not currentCombat.is_boss) then
			--is arena or battleground
			if (currentCombat.is_pvp or currentCombat.is_arena) then
				Details:FlagActorsOnPvPCombat()
			end

			--is arena
			if (currentCombat.is_arena) then
				currentCombat.enemy = "[" .. ARENA .. "] " ..  currentCombat.is_arena.name
			end

			--check if the player is in an instance
			local bInInstance = IsInInstance() --garrison returns party as instance type.
			if ((instanceType == "party" or instanceType == "raid") and bInInstance) then
				--if is not boss and inside a instance of type party or raid: mark the combat as trash
				if (not currentCombat.is_mythic_dungeon) then
					currentCombat.is_trash = true
				end
			else
				if (not bInInstance) then
					if (Details.world_combat_is_trash) then
						currentCombat.is_world_trash_combat = true
					end
				end
			end

			if (not currentCombat.enemy or currentCombat.enemy == Details222.Unknown) then
				local enemyName = currentCombat:FindEnemyName()
				currentCombat.enemy = enemyName
			end

			Details:FlagActorsOnCommonFight()
		else
			--combat is boss encounter
			--calling here without checking for combat since the does not ran too long for scripts
			Details:FlagActorsOnBossFight()

			if (bossKilled) then
				currentCombat.is_boss.killed = true

				--add to storage
				if (not InCombatLockdown() and not UnitAffectingCombat("player") and not Details.logoff_saving_data) then
					local successful, errortext = pcall(Details.Database.StoreEncounter)
					if (not successful) then
						Details:Msg("error occurred on Details.Database.StoreEncounter():", errortext)
					end
				else
					Details.schedule_store_boss_encounter = true
				end

				if (currentCombat.is_mythic_dungeon_segment) then
					currentCombat.is_mythic_dungeon.SegmentType = DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS
					currentCombat.is_mythic_dungeon.SegmentName = (currentCombat.is_boss.name or Loc["STRING_UNKNOW"]) .. " (" .. string.lower(_G["BOSS"]) .. ")"
				end

				Details:SendEvent("COMBAT_BOSS_DEFEATED", nil, currentCombat)
				Details:CheckFor_TrashSuppressionOnEncounterEnd()
			else
				Details:SendEvent("COMBAT_BOSS_WIPE", nil, currentCombat)
				--add to storage
				if (not InCombatLockdown() and not UnitAffectingCombat("player") and not Details.logoff_saving_data) then
					local successful, errortext = pcall(Details.Database.StoreWipe)
					if (not successful) then
						Details:Msg("error occurred on Details.Database.StoreWipe():", errortext)
					end
				else
					Details.schedule_store_boss_encounter_wipe = true
				end

				if (currentCombat.is_mythic_dungeon_segment) then
					currentCombat.is_mythic_dungeon.SegmentType = DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE
					currentCombat.is_mythic_dungeon.SegmentName = (currentCombat.is_boss.name or Loc["STRING_UNKNOW"]) .. " (" .. string.lower(_G["BOSS"]) .. ")"
				end
			end

			currentCombat.is_boss.index = currentCombat.is_boss.index or 1
			currentCombat.enemy = currentCombat.is_boss.encounter

			if (currentCombat.instance_type == "raid") then
				Details.last_encounter2 = Details.last_encounter
				Details.last_encounter = currentCombat.is_boss.name

				if (Details.pre_pot_used) then
					Details.last_combat_pre_pot_used = Details.CopyTable(Details.pre_pot_used)
				end

				if (Details.pre_pot_used and Details.announce_prepots.enabled) then
					Details:Msg(Details.pre_pot_used or "")
					Details.pre_pot_used = nil
				end
			end

			if (bIsFromEncounterEnd) then
				if (Details.encounter_table.start) then
					currentCombat:SetStartTime(Details.encounter_table.start)
				end
				currentCombat:SetEndTime(Details.encounter_table["end"] or GetTime())
			end

			if (currentCombat.instance_type == "raid") then
				Details:CaptureSet(false, "damage", false, 15)
				Details:CaptureSet(false, "energy", false, 15)
				Details:CaptureSet(false, "aura", false, 15)
				Details:CaptureSet(false, "energy", false, 15)
				Details:CaptureSet(false, "spellcast", false, 15)

				if (Details.debug) then
					--Details:Msg("(debug) freezing parser for 15 seconds.")
				end
			end

			--schedule sync
			if (Details:GetEncounterEqualize(currentCombat.is_boss.mapid, currentCombat.is_boss.index)) then
			end
		end

		if (Details.solo) then
			--debuffs need a checkup, not well functional right now
			Details.CloseSoloDebuffs()
		end

		local tempo_do_combate = currentCombat:GetCombatTime()

		---@type combat
		local invalidCombat

		local segmentsTable = Details:GetCombatSegments()

		--to force discard, the segmentsTable must have at least on segment
		local bShouldForceDiscard = Details222.discardSegment and segmentsTable[1] and true

		local zoneName, zoneType = GetInstanceInfo()
		if (not bShouldForceDiscard and (zoneType == "none" or tempo_do_combate >= Details.minimum_combat_time or not segmentsTable[1])) then
			--combat accepted
			Details.tabela_historico:AddCombat(currentCombat) --move a tabela atual para dentro do hist�rico

			currentCombat:StoreTalents()

			if (currentCombat.is_boss) then
				if (IsInRaid()) then
					local cleuID = currentCombat.is_boss.id
					local diff = currentCombat.is_boss.diff
					if (cleuID and diff == 16) then -- 16 mythic
						local raidData = Details.raid_data

						--get or build mythic raid data table
						local mythicRaidData = raidData.mythic_raid_data
						if (not mythicRaidData) then
							mythicRaidData = {}
							raidData.mythic_raid_data = mythicRaidData
						end

						--get or build a table for this cleuID
						mythicRaidData[cleuID] = mythicRaidData[cleuID] or {wipes = 0, kills = 0, best_try = 1, longest = 0, try_history = {}}
						local cleuIDData = mythicRaidData[cleuID]

						--store encounter data for plugins and weakauras
						if (currentCombat:GetCombatTime() > cleuIDData.longest) then
							cleuIDData.longest = currentCombat:GetCombatTime()
						end

						if (currentCombat.is_boss.killed) then
							cleuIDData.kills = cleuIDData.kills + 1
							cleuIDData.best_try = 0
							table.insert(cleuIDData.try_history, {0, currentCombat:GetCombatTime()})
							--print("KILL", "best try", cleuIDData.best_try, "amt kills", cleuIDData.kills, "wipes", cleuIDData.wipes, "longest", cleuIDData.longest)
						else
							cleuIDData.wipes = cleuIDData.wipes + 1
							if (Details.boss1_health_percent and Details.boss1_health_percent < cleuIDData.best_try) then
								cleuIDData.best_try = Details.boss1_health_percent
								table.insert(cleuIDData.try_history, {Details.boss1_health_percent, currentCombat:GetCombatTime()})
							end
							--print("WIPE", "best try", cleuIDData.best_try, "amt kills", cleuIDData.kills, "wipes", cleuIDData.wipes, "longest", cleuIDData.longest)
						end
					end
				end
			end

			--the combat is valid, see if the user is sharing data with somebody
			if (Details.shareData) then
				local zipData = Details:CompressData(currentCombat, "comm")
				if (zipData) then
					print("has zip data")
				end
			end
		else
			--combat denied: combat did not pass the filter and cannot be added into the segment history
			--rewind the data set to the first slot in the segments table
			showTutorialForDiscardedSegment()

			--change the current combat to the latest combat available in the segment table
			invalidCombat = currentCombat
			Details:SetCurrentCombat(segmentsTable[1])
			currentCombat = Details:GetCurrentCombat()

			--if it rewinds to an already erased combat, then create a new combat
			if (currentCombat.__destroyed) then
				Details:SetCurrentCombat(Details.combate:NovaTabela(nil, Details.tabela_overall))
				currentCombat = Details:GetCurrentCombat()
			end

			if (currentCombat:GetStartTime() == 0) then
				currentCombat:SetStartTime(GetTime())
				currentCombat:SetEndTime(GetTime())
			end

			currentCombat.resincked = true
			Details:InstanceCallDetailsFunc(Details.UpdateWindow)

			if (Details.solo) then --code to update "solo" plugins, there's no solo plugins for details! at the moment
				if (Details.SoloTables.CombatID == Details:GetOrSetCombatId()) then --significa que o solo mode validou o combate, como matar um bixo muito low level com uma s� porrada
					if (Details.SoloTables.CombatIDLast and Details.SoloTables.CombatIDLast ~= 0) then --volta os dados da luta anterior
						Details.SoloTables.CombatID = Details.SoloTables.CombatIDLast
					else
						if (Details.RefreshSolo) then
							Details:RefreshSolo()
						end
						Details.SoloTables.CombatID = nil
					end
				end
			end

			Details:GetOrSetCombatId(-1)
		end

		Details222.discardSegment = nil

		Details.host_of = nil
		Details.host_by = nil

		if (Details.cloud_process) then
			Details:CancelTimer(Details.cloud_process)
		end

		Details.in_combat = false
		Details.leaving_combat = false

		Details:Destroy(currentCombat.PhaseData.damage_section)
		Details:Destroy(currentCombat.PhaseData.heal_section)
		Details:Destroy(Details.cache_damage_group)
		Details:Destroy(Details.cache_healing_group)

		Details:UpdateParserGears()

		--hide / alpha in combat
		for index, instance in ipairs(Details.tabela_instancias) do
			if (instance.ativa) then
				if (instance.auto_switch_to_old) then
					instance:CheckSwitchOnCombatEnd()
				end
			end
		end

		Details.pre_pot_used = nil

		--do not wipe the encounter table if is in the argus encounter
		if (Details.encounter_table and Details.encounter_table.id ~= 2092) then
			Details:Destroy(Details.encounter_table)
		else
			if (Details.debug) then
				--Details:Msg("(debug) in argus encounter, cannot wipe the encounter table.")
			end
		end

		Details:InstanceCall(Details.CheckPsUpdate)

		if (invalidCombat) then
			Details:SendEvent("COMBAT_INVALID")
			Details:SendEvent("COMBAT_PLAYER_LEAVE", nil, invalidCombat)
		else
			Details:SendEvent("COMBAT_PLAYER_LEAVE", nil, currentCombat)
		end

		Details:CheckForTextTimeCounter()
		Details.StoreSpells()
		Details:RunScheduledEventsAfterCombat()

		--issue: invalidCombat will be just floating around in memory if not destroyed
	end --end of leaving combat function

	function Details:GetPlayersInArena() --ARENA_OPPONENT_UPDATE
		local aliados = GetNumGroupMembers() -- LE_PARTY_CATEGORY_HOME
		for i = 1, aliados-1 do
			local role = UnitGroupRolesAssigned and UnitGroupRolesAssigned("party" .. i) or "DAMAGER"
			if (role ~= "NONE" and UnitExists("party" .. i)) then
				local unitName = Details:GetFullName("party" .. i)
				Details.arena_table [unitName] = {role = role}
			end
		end

		local role = UnitGroupRolesAssigned and UnitGroupRolesAssigned("player") or "DAMAGER"
		if (role ~= "NONE") then
			local playerName = Details:GetFullName("player")
			Details.arena_table [playerName] = {role = role}
		end

		--enemies
		local enemiesAmount = GetNumArenaOpponentSpecs and GetNumArenaOpponentSpecs() or 5
		Details:Destroy(Details.arena_enemies)

		for i = 1, enemiesAmount do
			local enemyName = Details:GetFullName("arena" .. i)
			if (enemyName) then
				Details.arena_enemies[enemyName] = "arena" .. i
			end
		end
	end

	--attempt to get the arena unitId for an actor
	--this function is called from containerActors while reading the actor flag and parser when managing deathlog
	function Details:GuessArenaEnemyUnitId(unitName)
		for i = 1, #Details222.UnitIdCache.Arena do
			local unitId = Details222.UnitIdCache.Arena[i]
			local enemyName = Details:GetFullName(unitId)
			if (enemyName == unitName) then
				Details.arena_enemies[enemyName] = unitId
				return unitId
			end
		end
	end

	local string_arena_enemyteam_damage = [[
		local combat = Details:GetCurrentCombat()
		local total = 0

		for _, actor in combat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
			if (actor.arena_enemy) then
				total = total + actor.total
			end
		end

		return total
	]]

	local string_arena_myteam_damage = [[
		local combat = Details:GetCurrentCombat()
		local total = 0

		for _, actor in combat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
			if (actor.arena_ally) then
				total = total + actor.total
			end
		end

		return total
	]]

	local string_arena_enemyteam_heal = [[
		local combat = Details:GetCurrentCombat()
		local total = 0

		for _, actor in combat:GetContainer(DETAILS_ATTRIBUTE_HEAL):ListActors() do
			if (actor.arena_enemy) then
				total = total + actor.total
			end
		end

		return total
	]]

	local string_arena_myteam_heal = [[
		local combat = Details:GetCurrentCombat()
		local total = 0

		for _, actor in combat:GetContainer(DETAILS_ATTRIBUTE_HEAL):ListActors() do
			if (actor.arena_ally) then
				total = total + actor.total
			end
		end

		return total
	]]

	function Details:CreateArenaSegment()
		Details:GetPlayersInArena()

		Details.arena_begun = true
		Details.start_arena = nil

		if (Details.in_combat) then
			Details:SairDoCombate()
		end

		--register chart data
		Details:TimeDataRegister("Your Team Damage", string_arena_myteam_damage, nil, "Details!", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)
		Details:TimeDataRegister("Enemy Team Damage", string_arena_enemyteam_damage, nil, "Details!", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)

		Details:TimeDataRegister("Your Team Healing", string_arena_myteam_heal, nil, "Details!", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)
		Details:TimeDataRegister("Enemy Team Healing", string_arena_enemyteam_heal, nil, "Details!", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)

		Details.lastArenaStartTime = GetTime()

		Details222.StartCombat()

		---@type combat
		local currentCombat = Details:GetCurrentCombat()

		--set this combat as an arena segment type
		currentCombat.arena = true
		currentCombat.is_arena = {name = Details.zone_name, zone = Details.zone_name, mapid = Details.zone_id}

		Details:SendEvent("COMBAT_ARENA_START")

		local bOrderDpsByRealTime = Details.CurrentDps.CanSortByRealTimeDps()
		if (bOrderDpsByRealTime) then
			local bNoSave = true
			local nTimeIntervalBetweenUpdates = 0.1
			Details:SetWindowUpdateSpeed(nTimeIntervalBetweenUpdates, bNoSave)
		end
	end

	--return the GetTime() of the current or latest arena match
	function Details:GetArenaStartTime()
		return Details.lastArenaStartTime
	end

	function Details:GetBattlegroundStartTime()
		return Details.lastBattlegroundStartTime
	end

	function Details:StartArenaSegment(...)
		if (Details.debug) then
			Details:Msg("(debug) starting a new arena segment.")
		end

		local _, timeSeconds = select(1, ...)

		if (Details.start_arena) then
			Details:CancelTimer(Details.start_arena, true)
		end

		Details.start_arena = Details:ScheduleTimer("CreateArenaSegment", timeSeconds)
		Details:GetPlayersInArena()
	end

	function Details:EnteredInArena()
		if (Details.debug) then
			Details:Msg("(debug) the player EnteredInArena().")
		end

		Details.arena_begun = false

		Details:GetPlayersInArena()
	end

	function Details:LeftArena()
		if (Details.debug) then
			Details:Msg("(debug) player LeftArena().")
		end

		Details.is_in_arena = false
		Details.arena_begun = false

		if (Details.start_arena) then
			Details:CancelTimer(Details.start_arena, true)
		end

		Details:TimeDataUnregister("Your Team Damage")
		Details:TimeDataUnregister("Enemy Team Damage")

		Details:TimeDataUnregister("Your Team Healing")
		Details:TimeDataUnregister("Enemy Team Healing")

		Details:SendEvent("COMBAT_ARENA_END")

		--reset the update speed, as it could have changed when the arena started.
		Details:SetWindowUpdateSpeed(Details.update_speed)
	end

	function Details:FlagActorsOnPvPCombat()
		---@type combat
		local currentCombat = Details:GetCurrentCombat()
		for containerId = 1, 4 do
			---@type actorcontainer
			local container = currentCombat:GetContainer(containerId)
			for _, actorObject in container:ListActors() do
				actorObject.pvp_component = true
			end
		end
	end

	function Details:FlagActorsOnBossFight()
		---@type combat
		local currentCombat = Details:GetCurrentCombat()
		for containerId = 1, 4 do
			---@type actorcontainer
			local container = currentCombat:GetContainer(containerId)
			for _, actorObject in container:ListActors() do
				actorObject.boss_fight_component = true
			end
		end
	end

	local findAndMarkActorAsFightComponent = function(resourceContainer, utilityContainer, actorName)
		local resourceActor = resourceContainer:GetActor(actorName)
		if (resourceActor) then
			resourceActor.fight_component = true
		end

		local utilityActor = utilityContainer:GetActor(actorName)
		if (utilityActor) then
			utilityActor.fight_component = true
		end
	end

	function Details:FlagActorsOnCommonFight()
		---@type combat
		local currentCombat = Details:GetCurrentCombat()
		local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		local healContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_HEAL)
		local resourceContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_ENERGY)
		local utilityContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_MISC)

		local mythicDungeonRun = currentCombat.is_mythic_dungeon_segment

		for classType, actorContainer in ipairs({damageContainer, healContainer}) do
			for _, actor in actorContainer:ListActors() do
				if (mythicDungeonRun) then
					actor.fight_component = true
				end

				if (actor:IsGroupPlayer()) then
					if (classType == DETAILS_ATTRIBUTE_DAMAGE or classType == DETAILS_ATTRIBUTE_HEAL) then
						for targetName, amount in pairs(actor.targets) do
							local targetObject = actorContainer:GetActor(targetName)
							if (targetObject) then
								targetObject.fight_component = true
								findAndMarkActorAsFightComponent(resourceContainer, utilityContainer, targetName)
							end
						end

						if (classType == DETAILS_ATTRIBUTE_DAMAGE) then
							for damagerName in pairs(actor.damage_from) do
								local targetObject = actorContainer:GetActor(damagerName)
								if (targetObject) then
									targetObject.fight_component = true
									findAndMarkActorAsFightComponent(resourceContainer, utilityContainer, damagerName)
								end
							end

						elseif (classType == DETAILS_ATTRIBUTE_HEAL) then
							for healerName in pairs(actor.healing_from) do
								local targetObject = actorContainer:GetActor(healerName)
								if (targetObject) then
									targetObject.fight_component = true
									findAndMarkActorAsFightComponent(resourceContainer, utilityContainer, healerName)
								end
							end
						end
					end
				end
			end
		end
	end

	function Details:UpdateWindow(instance, segmentId)
		if (segmentId) then
			if (segmentId == instance.segmento) then
				local displayId, subDisplayId = instance:GetDisplay()
				instance:TrocaTabela(instance, instance:GetSegment(), displayId, subDisplayId, true)
			end
		else
			if (instance.modo == groupMode or instance.modo == everythingMode) then
				local displayId, subDisplayId = instance:GetDisplay()
				instance:TrocaTabela(instance, instance:GetSegment(), displayId, subDisplayId, true)
			end
		end
	end

	function Details:PostponeInstanceToCurrent(instance)
		if (
			not instance.last_interaction or
			(
				(instance.ativa) and
				(instance.last_interaction+3 < _tempo) and
				(not DetailsReportWindow or not DetailsReportWindow:IsShown()) and
				(not Details.BreakdownWindowFrame:IsShown())
			)
		) then
			instance._postponing_current = nil
			if (instance.segmento == 0) then
				return Details:TrocaSegmentoAtual(instance)
			else
				return
			end
		end
		if (instance.is_interacting and instance.last_interaction < _tempo) then
			instance.last_interaction = _tempo
		end
		instance._postponing_current = Details:ScheduleTimer("PostponeInstanceToCurrent", 1, instance)
	end

	function Details:TrocaSegmentoAtual(instance, bIsEncounter)
		if (instance.segmento == 0 and instance.baseframe and instance.ativa) then

			if (not bIsEncounter) then
				if (instance.is_interacting) then
					if (not instance.last_interaction or instance.last_interaction < _tempo) then
						instance.last_interaction = _tempo or time()
					end
				end

				if ((instance.last_interaction and (instance.last_interaction+3 > Details._tempo)) or (DetailsReportWindow and DetailsReportWindow:IsShown()) or (Details.BreakdownWindowFrame:IsShown())) then
					--postpone
					instance._postponing_current = Details:ScheduleTimer("PostponeInstanceToCurrent", 1, instance)
					return
				end
			end

			instance.last_interaction = _tempo - 4 --pode setar, completou o ciclo
			instance._postponing_current = nil
			instance.showing = Details.tabela_vigente
			instance:ResetaGump()
			Details.FadeHandler.Fader(instance, "in", nil, "barras")
		end
	end

	function Details:SetTrashSuppression(n)
		assert(type(n) == "number", "SetTrashSuppression expects a number on index 1.")
		if (n < 0) then
			n = 0
		end
		Details.instances_suppress_trash = n
	end

	function Details:CheckFor_SuppressedWindowsOnEncounterFound()
		for _, instance in Details:ListInstances() do
			if (instance.ativa and instance.baseframe and (not instance.last_interaction or instance.last_interaction > _tempo) and instance.segmento == 0) then
				Details:TrocaSegmentoAtual(instance, true)
			end
		end
	end

	function Details:CheckFor_EnabledTrashSuppression()
		if (Details.HasTrashSuppression and Details.HasTrashSuppression > _tempo) then
			self.last_interaction = Details.HasTrashSuppression
		end
	end

	function Details:SetTrashSuppressionAfterEncounter()
		Details:InstanceCall("CheckFor_EnabledTrashSuppression")
	end

	function Details:CheckFor_TrashSuppressionOnEncounterEnd()
		if (Details.instances_suppress_trash > 0) then
			Details.HasTrashSuppression = _tempo + Details.instances_suppress_trash
			--delaying in 3 seconds for other stuff like auto open windows after combat.
			Details:ScheduleTimer("SetTrashSuppressionAfterEncounter", 3)
		end
	end

	---internal GetCombatId() version
	---@param self details
	---@param numberId number|nil if nil, return the current combat id, if 0 resets the id, if a number will add it to the current combat id
	---@return number
	function Details:GetOrSetCombatId(numberId)
		if (numberId == 0) then
			Details.combat_id = 0
		elseif (numberId) then
			Details.combat_id = Details.combat_id + numberId
		end
		return Details.combat_id
	end

	--tooltip fork / search key: ~tooltip
	local avatarPoint = {"bottomleft", "topleft", -3, -4}
	local backgroundPoint = {{"bottomleft", "topleft", 0, -3}, {"bottomright", "topright", 0, -3}}
	local textPoint = {"left", "right", -11, -5}
	local avatarTexCoord = {0, 1, 0, 1}
	local backgroundColor = {0, 0, 0, 0.6}
	local avatarTextColor = {1, 1, 1, 1}

	function Details:AddTooltipReportLineText()
		GameCooltip:AddLine(Loc ["STRING_CLICK_REPORT_LINE1"], Loc ["STRING_CLICK_REPORT_LINE2"])
		GameCooltip:AddStatusBar(100, 1, 0, 0, 0, 0.8)
	end

	function Details:AddTooltipBackgroundStatusbar(side, value, useSpark, statusBarColor)
		Details.tooltip.background [4] = 0.8
		Details.tooltip.icon_size.W = Details.tooltip.line_height
		Details.tooltip.icon_size.H = Details.tooltip.line_height

		--[[spark options
			["SparkTexture"] = true,
			["SparkHeightOffset"] = true,
			["SparkWidthOffset"] = true,
			["SparkHeight"] = true,
			["SparkWidth"] = true,
			["SparkAlpha"] = true,
			["SparkColor"] = true,
			["SparkPositionXOffset"] = true,
			["SparkPositionYOffset"] = true,
		--]]

		useSpark = value ~= 100
		--GameCooltip:SetOption("SparkHeightOffset", 6)
		GameCooltip:SetOption("SparkTexture", [[Interface\Buttons\WHITE8X8]])
		GameCooltip:SetOption("SparkWidth", 1)
		GameCooltip:SetOption("SparkHeight", 20)
		GameCooltip:SetOption("SparkColor", Details.tooltip.divisor_color)
		GameCooltip:SetOption("SparkAlpha", 0.15)
		GameCooltip:SetOption("SparkPositionXOffset", 5)
		--GameCooltip:SetOption("SparkAlpha", 0.3)
		--GameCooltip:SetOption("SparkPositionXOffset", -2)

		value = value or 100

		if (not side) then
			local r, g, b, a = unpack(Details.tooltip.bar_color)
			if (statusBarColor) then
				r, g, b, a = detailsFramework:ParseColors(statusBarColor)
			end
			local rBG, gBG, bBG, aBG = unpack(Details.tooltip.background)
			GameCooltip:AddStatusBar(value, 1, r, g, b, a, useSpark, {value = 100, color = {rBG, gBG, bBG, aBG}, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
		else
			GameCooltip:AddStatusBar(value, 2, unpack(Details.tooltip.bar_color))
		end
	end

	function Details:AddTooltipHeaderStatusbar(r, g, b, a)
		local r, g, b, a, statusbarGlow, backgroundBar = unpack(Details.tooltip.header_statusbar)
		GameCooltip:AddStatusBar(100, 1, r, g, b, a, statusbarGlow, backgroundBar, "Skyline")
	end

-- /run local a,b=Details.tooltip.header_statusbar,0.3;a[1]=b;a[2]=b;a[3]=b;a[4]=0.8;

	function Details:AddTooltipSpellHeaderText(headerText, headerColor, amount, iconTexture, L, R, T, B, separator, iconSize)
		if (separator and separator == true) then
			GameCooltip:AddLine("", "", nil, nil, 1, 1, 1, 1, 8)
			return
		end

		if (type(iconSize) ~= "number") then
			iconSize = 14
		end

		if (Details.tooltip.show_amount) then
			GameCooltip:AddLine(headerText, "x" .. amount .. "", nil, headerColor, 1, 1, 1, .4, Details.tooltip.fontsize_title)
		else
			GameCooltip:AddLine(headerText, nil, nil, headerColor, nil, Details.tooltip.fontsize_title)
		end

		if (iconTexture) then
			GameCooltip:AddIcon(iconTexture, 1, 1, iconSize, iconSize, L or 0, R or 1, T or 0, B or 1)
		end
	end

	local bgColor, borderColor = {0, 0, 0, 0.8}, {0, 0, 0, 0.5} --{0.37, 0.37, 0.37, .75}, {.30, .30, .30, .3}
	local backdrop = {bgFile = [[Interface\AddOns\Details\images\background83.png]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile=true,
	edgeSize = 1, tileSize = 64, insets = {left = 0, right = 0, top = 0, bottom = 0}}

	function Details:FormatCooltipForSpells()
		local GameCooltip = GameCooltip

		GameCooltip:Reset()
		GameCooltip:SetType("tooltip")

		GameCooltip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar_background_dark_withline]])
		--GameCooltip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar_textures\bar_rounded.png]])

		GameCooltip:SetOption("TextSize", Details.tooltip.fontsize)
		GameCooltip:SetOption("TextFont",  Details.tooltip.fontface)
		GameCooltip:SetOption("TextColor", Details.tooltip.fontcolor)
		GameCooltip:SetOption("TextColorRight", Details.tooltip.fontcolor_right)
		GameCooltip:SetOption("TextShadow", Details.tooltip.fontshadow and "OUTLINE")
		GameCooltip:SetOption("TextContour", Details.tooltip.fontcontour)

		GameCooltip:SetOption("LeftBorderSize", -4) --offset between the left border and the left icon, default: 10 + offset
		GameCooltip:SetOption("RightBorderSize", 4) --offset between the right border and the right icon, default: -10 + offset
		GameCooltip:SetOption("TopBorderSize", -1) --offset between the right border and the right icon, default: -10 + offset

		GameCooltip:SetOption("VerticalOffset", 5) --amount of space to offset each line from each other, default: 0, higher values = less space between
		GameCooltip:SetOption("RightTextMargin", 0) --offset between the right text to the right icon, default: -3
		GameCooltip:SetOption("AlignAsBlizzTooltip", false)
		GameCooltip:SetOption("LineHeightSizeOffset", 4)
		GameCooltip:SetOption("VerticalPadding", -4)
		GameCooltip:SetOption("YSpacingMod", -6)
		GameCooltip:SetOption("TooltipFrameHeightOffset", -6)
		--IgnoreButtonAutoHeight is true

		--GameCooltip:SetBackdrop(1, Details.cooltip_preset2_backdrop, bgColor, borderColor)
		GameCooltip:SetBackdrop(1, backdrop, {1, 1, 1, 1}, borderColor)
	end

	function Details:BuildInstanceBarTooltip(frame)
		local GameCooltip = GameCooltip
		Details:FormatCooltipForSpells()
		GameCooltip:SetOption("MinWidth", max(230, self.baseframe:GetWidth()*0.98))

		if (frame.GetActor) then
			local actor = frame:GetActor()
			if (actor) then
				local class = actor.classe
				if (class) then
					local classColor = RAID_CLASS_COLORS[class]
					GameCooltip:SetBackdrop(1, backdrop, classColor, borderColor)
					GameCooltip:SetColor(1, 0, 0, 0, 0.7)
				end
			end
		end

		local myPoint = Details.tooltip.anchor_point
		local anchorPoint = Details.tooltip.anchor_relative
		local x_Offset = Details.tooltip.anchor_offset[1]
		local y_Offset = Details.tooltip.anchor_offset[2]

		if (Details.tooltip.anchored_to == 1) then
			GameCooltip:SetHost(frame, myPoint, anchorPoint, x_Offset, y_Offset)
		else
			GameCooltip:SetHost(DetailsTooltipAnchor, myPoint, anchorPoint, x_Offset, y_Offset)
		end
	end

	---@param self instance
	---@param frame table
	---@param whichRowLine number
	---@param keydown string
	function Details:MontaTooltip(frame, whichRowLine, keydown)
		self:BuildInstanceBarTooltip(frame)

		local GameCooltip = GameCooltip

		local thisLine = self.barras[whichRowLine] --hoverovered line
		local object = thisLine.minha_tabela --the object the line is showing

		--check if the object is valid
		if (not object) then
			return false
		end

		--check for special tooltips
		if (object.dead) then --� uma barra de dead
			return Details:ToolTipDead(self, object, thisLine, keydown) --inst�ncia, [morte], barra

		elseif (object.byspell) then
			return Details:ToolTipBySpell(self, object, thisLine, keydown)

		elseif (object.frags) then
			return Details:ToolTipFrags(self, object, thisLine, keydown)

		elseif (object.boss_debuff) then
			return Details:ToolTipVoidZones(self, object, thisLine, keydown)
		end

		if (not object.ToolTip) then
			if (object.__destroyed) then
				Details:Msg("object:ToolTip() is invalid.", object.__destroyedBy)
				self:ResetWindow()
				self:RefreshWindow(true)
				return
			end
		end

		local bTooltipBuilt = object:ToolTip(self, whichRowLine, thisLine, keydown) --instance, lineId, lineObject, keydown

		if (bTooltipBuilt) then
			if (object.serial and object.serial ~= "") then
				local avatar = NickTag:GetNicknameTable(object:Name(), true)
				if (avatar and not Details.ignore_nicktag) then
					if (avatar[2] and avatar[4] and avatar[1]) then
						GameCooltip:SetBannerImage(1, 1, avatar [2], 80, 40, avatarPoint, avatarTexCoord, nil) --overlay [2] avatar path
						GameCooltip:SetBannerImage(1, 2, avatar [4], 200, 55, backgroundPoint, avatar [5], avatar [6]) --background
						GameCooltip:SetBannerText(1, 1, (not Details.ignore_nicktag and avatar[1]) or object.nome, textPoint, avatarTextColor, 14, SharedMedia:Fetch("font", Details.tooltip.fontface)) --text [1] nickname
					end
				end
			end

			Details:AddRoundedCornerToTooltip()

			GameCooltip:ShowCooltip()

			if (not Details.GameCooltipFrame1Shadow) then
				Details.GameCooltipFrame1Shadow = GameCooltipFrame1:CreateTexture(nil, "background")
				Details.GameCooltipFrame1Shadow:SetTexture([[Interface\AddOns\Details\images\shadow_square.png]], nil, nil, "TRILINEAR")
				GameCooltipFrame1:HookScript("OnHide", function(self)
					Details.GameCooltipFrame1Shadow:Hide()
				end)
			end

			if (Details.tooltip.show_border_shadow) then
				local offset = 1
				if (GameCooltipFrame1:GetHeight() > 200) then
					offset = 4
				elseif (GameCooltipFrame1:GetHeight() > 150) then
					offset = 3
				elseif (GameCooltipFrame1:GetHeight() > 80) then
					offset = 2
				end

				Details.GameCooltipFrame1Shadow:SetPoint("topleft", GameCooltipFrame1, "topleft", -offset, offset)
				Details.GameCooltipFrame1Shadow:SetPoint("bottomright", GameCooltipFrame1, "bottomright", offset, -offset)
				Details.GameCooltipFrame1Shadow:Show()
			else
				Details.GameCooltipFrame1Shadow:Hide()
			end
		end
	end

	function Details:AddRoundedCornerToTooltip()
		if (Details.tooltip.rounded_corner) then
			GameCooltip:ShowRoundedCorner()
		end
	end

	function Details.gump:UpdateTooltip(whichRowLine, esta_barra, instancia)
		if (IsShiftKeyDown()) then
			return instancia:MontaTooltip(esta_barra, whichRowLine, "shift")
		elseif (IsControlKeyDown()) then
			return instancia:MontaTooltip(esta_barra, whichRowLine, "ctrl")
		elseif (IsAltKeyDown()) then
			return instancia:MontaTooltip(esta_barra, whichRowLine, "alt")
		else
			return instancia:MontaTooltip(esta_barra, whichRowLine)
		end
	end

	function Details:EndRefresh(instancia, total, combatTable, showing)
		Details:HideBarsNotInUse(instancia, showing)
	end

	function Details:HideBarsNotInUse(instance, showing)
		if (instance.v_barras) then
			--print("mostrando", instancia.rows_showing, instancia.rows_created)
			for barra_numero = instance.rows_showing+1, instance.rows_created do
				Details.FadeHandler.Fader(instance.barras[barra_numero], "in")
			end
			instance.v_barras = false

			if (instance.rows_showing == 0 and instance:GetSegment() == -1) then -- -1 overall data
				if (not instance:IsShowingOverallDataWarning()) then
					local tutorial = Details:GetTutorialCVar("OVERALLDATA_WARNING1") or 0
					if ((type(tutorial) == "number") and (tutorial < 10)) then
						Details:SetTutorialCVar ("OVERALLDATA_WARNING1", tutorial + 1)
						instance:ShowOverallDataWarning (true)
					end
				end
			else
				if (instance:IsShowingOverallDataWarning()) then
					instance:ShowOverallDataWarning (false)
				end
			end
		end

		return showing
	end

	--call update functions
	function Details:RefreshAllMainWindows(bForceRefresh) --getting deprecated soon
		local combatObject = self.showing

		--the the segment does not have a valid combat, freeze the window
		if (not combatObject) then
			if (not self.freezed) then
				return self:Freeze()
			end
			return
		end

		local needRefresh = combatObject[self.atributo].need_refresh --erro de index nil value
		if (not needRefresh and not bForceRefresh) then
			return
		end

		--measure the cpu time spent on this function
		--local startTime = debugprofilestop()

		if (self.atributo == 1) then --damage
			--[[return]] damageClass:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)

		elseif (self.atributo == 2) then --heal
			--[[return]] healingClass:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)

		elseif (self.atributo == 3) then --energy
			--[[return]] resourceClass:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)

		elseif (self.atributo == 4) then --outros
			--[[return]] utilityClass:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)

		elseif (self.atributo == 5) then --ocustom
			--[[return]] customClass:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)
		end

		--[[if (Details222.Perf.WindowUpdateC) then
			local elapsedTime = debugprofilestop() - startTime
			if (Details222.Perf.WindowUpdate) then
				Details222.Perf.WindowUpdate = Details222.Perf.WindowUpdate + elapsedTime
			end
		end--]]
	end

	--["1"] = "WindowUpdate",
	--["2"] = 308.6662000129,
	function Details:DumpPerf()
		local t = {}
		for name, value in pairs(Details222.Perf) do
			t[#t+1] = {name, value}
		end
		dumpt(t)
	end

	function Details:ForceRefresh() --getting deprecated soon
		self:RefreshMainWindow(true)
	end

	function Details:RefreshAllMainWindowsTemp()
		return Details:RefreshMainWindow(-1)
	end

	local nextBreakdownUpdateAt = 0

	function Details:RefreshMainWindow(instanceObject, bForceRefresh) --getting deprecated soon
		if (not instanceObject or type(instanceObject) == "boolean") then
			bForceRefresh = instanceObject
			instanceObject = self
		end

		if (not bForceRefresh) then
			Details.LastUpdateTick = Details._tempo
		end

		if (instanceObject == -1) then
			--update
			for index, thisInstance in ipairs(Details.tabela_instancias) do
				---@cast thisInstance instance
				if (thisInstance:IsEnabled()) then
					if (thisInstance:GetMode() == DETAILS_MODE_GROUP or thisInstance:GetMode() == DETAILS_MODE_ALL) then
						thisInstance:RefreshData(bForceRefresh)
					end
				end
			end

			--flag windows as no need update next tick
			for index, thisInstance in ipairs(Details.tabela_instancias) do
				if (thisInstance:IsEnabled() and thisInstance.showing) then
					if (thisInstance:GetMode() == DETAILS_MODE_GROUP or thisInstance:GetMode() == DETAILS_MODE_ALL) then
						if (thisInstance.atributo <= 4) then
							thisInstance.showing[thisInstance.atributo].need_refresh = false
						end
					end
				end
			end

			if (not bForceRefresh) then --update player details window if opened
				if (Details.BreakdownWindowFrame:IsShown()) then
					---@type actor
					local actorObject = Details:GetActorObjectFromBreakdownWindow()
					if (actorObject) then
						if (actorObject and not actorObject.__destroyed) then
							if (nextBreakdownUpdateAt < GetTime()) then
								if (Details.in_combat) then
									nextBreakdownUpdateAt = GetTime() + 0.5
								else
									nextBreakdownUpdateAt = GetTime() + 5
								end
								return actorObject:MontaInfo()
							end
						else
							Details:Msg("Invalid actor object on breakdown window.")
							if (actorObject.__destroyed) then
								Details:Msg("Invalidation Reason:", actorObject.__destroyedBy)
							end
						end
					end
				end
			end
			return
		else
			if (not instanceObject.ativa) then
				return
			end
		end

		local currentMode = instanceObject:GetMode()
		if (currentMode == DETAILS_MODE_ALL or currentMode == DETAILS_MODE_GROUP) then
			return instanceObject:RefreshAllMainWindows(bForceRefresh)
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core

	function Details:AutoEraseConfirm()
		local dataEraseConfirmationFrame = _G.DetailsEraseDataConfirmation
		if (not dataEraseConfirmationFrame) then
			dataEraseConfirmationFrame = CreateFrame("frame", "DetailsEraseDataConfirmation", UIParent, "BackdropTemplate")
			dataEraseConfirmationFrame:SetSize(400, 85)
			dataEraseConfirmationFrame:SetPoint("center", UIParent)

			DetailsFramework:AddRoundedCornersToFrame(dataEraseConfirmationFrame, Details.PlayerBreakdown.RoundedCornerPreset)

			local LibWindow = LibStub("LibWindow-1.1")
			LibWindow.RegisterConfig(dataEraseConfirmationFrame, Details.ask_to_erase_frame)
			LibWindow.MakeDraggable(dataEraseConfirmationFrame)
			LibWindow.RestorePosition(dataEraseConfirmationFrame)

			dataEraseConfirmationFrame:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					dataEraseConfirmationFrame:Hide()
				end
			end)

			--[=[
				create 3 options
				- overall data only
				- current data only
				- both
			--]=]

			local text = detailsFramework:CreateLabel(dataEraseConfirmationFrame, Loc ["STRING_OPTIONS_CONFIRM_ERASE"], nil, nil, "GameFontNormal")
			text:SetPoint("center", dataEraseConfirmationFrame, "center")
			text:SetPoint("top", dataEraseConfirmationFrame, "top", 0, -10)

			local noButton = detailsFramework:CreateButton(dataEraseConfirmationFrame, function() dataEraseConfirmationFrame:Hide() end, 90, 20, Loc ["STRING_NO"])
			noButton:SetPoint("bottomleft", dataEraseConfirmationFrame, "bottomleft", 30, 10)

			local yesButton = detailsFramework:CreateButton(dataEraseConfirmationFrame, function() dataEraseConfirmationFrame:Hide(); Details:ResetSegmentData() end, 90, 20, Loc ["STRING_YES"])
			yesButton:SetPoint("bottomright", dataEraseConfirmationFrame, "bottomright", -30, 10)
		end

		dataEraseConfirmationFrame:Show()
	end

	function Details:CheckForAutoErase(mapId)
		if (Details.last_instance_id ~= mapId) then
			Details.tabela_historico:ResetOverallData()

			if (Details.segments_auto_erase == 2) then --ask to erase
				Details:ScheduleTimer("AutoEraseConfirm", 1)

			elseif (Details.segments_auto_erase == 3) then
				--erase
				C_Timer.After(2, function()
					Details:ResetSegmentData()
				end)
			end
		else
			if (_tempo > Details.last_instance_time + 21600) then --6 hours
				if (Details.segments_auto_erase == 2) then
					--ask
					Details:ScheduleTimer("AutoEraseConfirm", 1)
				elseif (Details.segments_auto_erase == 3) then
					--erase
					Details:ResetSegmentData()
				end
			end
		end

		Details.last_instance_id = mapId
		Details.last_instance_time = _tempo
	end

	function Details:UpdateControl()
		_tempo = Details._tempo
	end

