
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local _detalhes = 		_G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
	local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
	local _tempo = time()
	local _
	local addonName, Details222 = ...
	local detailsFramework = DetailsFramework

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers
	local _math_max = math.max --lua local
	local ipairs = ipairs --lua local
	local pairs = pairs --lua local
	local bitBand = bit.band --lua local

	local GetInstanceInfo = GetInstanceInfo --wow api local
	local UnitExists = UnitExists --wow api local
	local UnitGUID = UnitGUID --wow api local
	local GetTime = GetTime

	local IsAltKeyDown = IsAltKeyDown
	local IsShiftKeyDown = IsShiftKeyDown
	local IsControlKeyDown = IsControlKeyDown

	local atributo_damage = Details.atributo_damage --details local
	local atributo_heal = Details.atributo_heal --details local
	local atributo_energy = Details.atributo_energy --details local
	local atributo_misc = Details.atributo_misc --details local
	local atributo_custom = Details.atributo_custom --details local
	local breakdownWindowFrame = Details.BreakdownWindowFrame --details local

	local UnitGroupRolesAssigned = DetailsFramework.UnitGroupRolesAssigned

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants
	local modo_GROUP = Details.modos.group
	local modo_ALL = Details.modos.all
	local class_type_dano = Details.atributos.dano
	local OBJECT_TYPE_PETS = 0x00003000

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--details api functions
	---for a number to the current selected abbreviation
	---@param number number
	---@return string
	function Details:Format(number)
		return Details.ToKFunctions[Details.ps_abbreviation](nil, number)
	end

	--try to find the opponent of last fight, can be called during a fight as well
	function Details:FindEnemy()
		local ZoneName, InstanceType, DifficultyID, _, _, _, _, ZoneMapID = GetInstanceInfo()
		local in_instance = IsInInstance() --garrison returns party as instance type.

		if ((InstanceType == "party" or InstanceType == "raid") and in_instance) then
			if (InstanceType == "party") then
				if (Details:GetBossNames (Details.zone_id)) then
					return Loc ["STRING_SEGMENT_TRASH"]
				end
			else
				return Loc ["STRING_SEGMENT_TRASH"]
			end
		end

		for _, actor in ipairs(Details.tabela_vigente[class_type_dano]._ActorTable) do

			if (not actor.grupo and not actor.owner and not actor.nome:find("[*]") and bitBand(actor.flag_original, 0x00000060) ~= 0) then --0x20+0x40 neutral + enemy reaction
				for name, _ in pairs(actor.targets) do
					if (name == Details.playername) then
						return actor.nome
					else
						local _target_actor = Details.tabela_vigente (class_type_dano, name)
						if (_target_actor and _target_actor.grupo) then
							return actor.nome
						end
					end
				end
			end

		end

		for _, actor in ipairs(Details.tabela_vigente[class_type_dano]._ActorTable) do

			if (actor.grupo and not actor.owner) then
				for target_name, _ in pairs(actor.targets) do
					return target_name
				end
			end

		end

		return Loc ["STRING_UNKNOW"]
	end

	-- try get the current encounter name during the encounter
	local boss_found_not_registered = function(t, ZoneName, ZoneMapID, DifficultyID)
		local boss_table = {
			index = 0,
			name = t[1],
			encounter = t[1],
			zone = ZoneName,
			mapid = ZoneMapID,
			diff = DifficultyID,
			diff_string = select(4, GetInstanceInfo()),
			ej_instance_id = t[5],
			id = t[2],
			bossimage = t[4],
			unixtime = time(),
		}

		Details.tabela_vigente.is_boss = boss_table
	end

	local boss_found = function(index, name, zone, mapid, diff, encounterid)
		local mapID = C_Map.GetBestMapForUnit ("player")
		local ejid
		if (mapID) then
			ejid = DetailsFramework.EncounterJournal.EJ_GetInstanceForMap (mapID)
		end

		if (not mapID) then
			--print("Details! exeption handled: zone has no map")
			return
		end

		if (ejid == 0) then
			ejid = Details:GetInstanceEJID()
		end

		local boss_table = {
			index = index,
			name = name,
			encounter = name,
			zone = zone,
			mapid = mapid,
			diff = diff,
			diff_string = select(4, GetInstanceInfo()),
			ej_instance_id = ejid,
			id = encounterid,
			unixtime = time(),
		}

		if (not Details:IsRaidRegistered(mapid) and Details.zone_type == "raid") then
			local boss_list = Details:GetCurrentDungeonBossListFromEJ()
			if (boss_list) then
				local ActorsContainer = Details.tabela_vigente[class_type_dano]._ActorTable
				if (ActorsContainer) then
					for index, Actor in ipairs(ActorsContainer) do
						if (not Actor.grupo) then
							if (boss_list[Actor.nome]) then
								Actor.boss = true
								boss_table.bossimage = boss_list[Actor.nome][4]
								break
							end
						end
					end
				end
			end
		end

		Details.tabela_vigente.is_boss = boss_table

		if (Details.in_combat and not Details.leaving_combat) then

			--catch boss function if any
			local bossFunction, bossFunctionType = Details:GetBossFunction (ZoneMapID, BossIndex)
			if (bossFunction) then
				if (bitBand(bossFunctionType, 0x1) ~= 0) then --realtime
					Details.bossFunction = bossFunction
					Details.tabela_vigente.bossFunction = Details:ScheduleTimer("bossFunction", 1)
				end
			end

			if (Details.zone_type ~= "raid") then
				local endType, endData = Details:GetEncounterEnd (ZoneMapID, BossIndex)
				if (endType and endData) then

					if (Details.debug) then
						Details:Msg("(debug) setting boss end type to:", endType)
					end

					Details.encounter_end_table.type = endType
					Details.encounter_end_table.killed = {}
					Details.encounter_end_table.data = {}

					if (type(endData) == "table") then
						if (Details.debug) then
							Details:Msg("(debug) boss type is table:", endType)
						end
						if (endType == 1 or endType == 2) then
							for _, npcID in ipairs(endData) do
								Details.encounter_end_table.data [npcID] = false
							end
						end
					else
						if (endType == 1 or endType == 2) then
							Details.encounter_end_table.data [endData] = false
						end
					end
				end
			end
		end

		--we the boss was found during the combat table creation, we must postpone the event trigger
		if (not Details.tabela_vigente.IsBeingCreated) then
			Details:SendEvent("COMBAT_BOSS_FOUND", nil, index, name)
			Details:CheckFor_SuppressedWindowsOnEncounterFound()
		end

		return boss_table
	end

	function Details:ReadBossFrames()

		if (Details.tabela_vigente.is_boss) then
			return --no need to check
		end

		if (Details.encounter_table.name) then
			local encounter_table = Details.encounter_table
			return boss_found (encounter_table.index, encounter_table.name, encounter_table.zone, encounter_table.mapid, encounter_table.diff, encounter_table.id)
		end

		for index = 1, 5, 1 do
			if (UnitExists("boss"..index)) then
				local guid = UnitGUID("boss"..index)
				if (guid) then
					local serial = Details:GetNpcIdFromGuid (guid)

					if (serial) then

						local ZoneName, _, DifficultyID, _, _, _, _, ZoneMapID = GetInstanceInfo()

						local BossIds = Details:GetBossIds (ZoneMapID)
						if (BossIds) then
							local BossIndex = BossIds [serial]

							if (BossIndex) then
								if (Details.debug) then
									Details:Msg("(debug) boss found:",Details:GetBossName (ZoneMapID, BossIndex))
								end

								return boss_found (BossIndex, Details:GetBossName (ZoneMapID, BossIndex), ZoneName, ZoneMapID, DifficultyID)
							end
						end
					end
				end
			end
		end
	end

	--try to get the encounter name after the encounter (can be called during the combat as well)
	function Details:FindBoss (noJournalSearch)

		if (Details.encounter_table.name) then
			local encounter_table = Details.encounter_table
			return boss_found (encounter_table.index, encounter_table.name, encounter_table.zone, encounter_table.mapid, encounter_table.diff, encounter_table.id)
		end

		local ZoneName, InstanceType, DifficultyID, _, _, _, _, ZoneMapID = GetInstanceInfo()
		local BossIds = Details:GetBossIds (ZoneMapID)

		if (BossIds) then
			local BossIndex = nil
			local ActorsContainer = Details.tabela_vigente [class_type_dano]._ActorTable

			if (ActorsContainer) then
				for index, Actor in ipairs(ActorsContainer) do
					if (not Actor.grupo) then
						local serial = Details:GetNpcIdFromGuid (Actor.serial)
						if (serial) then
							BossIndex = BossIds [serial]
							if (BossIndex) then
								Actor.boss = true
								return boss_found (BossIndex, Details:GetBossName (ZoneMapID, BossIndex), ZoneName, ZoneMapID, DifficultyID)
							end
						end
					end
				end
			end
		end

		noJournalSearch = true --disabling the scan on encounter journal

		if (not noJournalSearch) then
			local in_instance = IsInInstance() --garrison returns party as instance type.
			if ((InstanceType == "party" or InstanceType == "raid") and in_instance) then
				local boss_list = Details:GetCurrentDungeonBossListFromEJ()
				if (boss_list) then
					local ActorsContainer = Details.tabela_vigente [class_type_dano]._ActorTable
					if (ActorsContainer) then
						for index, Actor in ipairs(ActorsContainer) do
							if (not Actor.grupo) then
								if (boss_list [Actor.nome]) then
									Actor.boss = true
									return boss_found_not_registered (boss_list [Actor.nome], ZoneName, ZoneMapID, DifficultyID)
								end
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
			local combatObject = segmentsTable[i]
			if (combatObject.is_boss) then
				table.insert(resultTable, 1, combatObject.is_boss.id)
			end
		end

		return resultTable
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--internal functions
-- Details.statistics = {container_calls = 0, container_pet_calls = 0, container_unknow_pet = 0, damage_calls = 0, heal_calls = 0, absorbs_calls = 0, energy_calls = 0, pets_summons = 0}
	function Details:StartCombat(...)
		return Details:EntrarEmCombate (...)
	end

	-- ~start ~inicio ~novo �ovo
	function Details:EntrarEmCombate (...)
		if (Details.debug) then
			Details:Msg("(debug) |cFFFFFF00started a new combat|r|cFFFF7700", Details.encounter_table and Details.encounter_table.name or "")
			local from = debugstack(2, 1, 0)
			print("from:", from)
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
		local newCombatObject = Details.combate:NovaTabela(true, Details.tabela_overall, combatCounter, ...)
		Details.tabela_vigente = newCombatObject
		--flag this combat as being created
		newCombatObject.IsBeingCreated = true

		--flag Details! as 'in combat'
		Details.in_combat = true

		newCombatObject:seta_data(Details._detalhes_props.DATA_TYPE_START) --seta na tabela do combate a data do inicio do combate -- setup time data

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
		Details.container_pets:BuscarPets()

		Details:Destroy(Details.cache_damage_group)
		Details:Destroy(Details.cache_healing_group)

		local bFromCombatStart = true
		Details:UpdateParserGears(bFromCombatStart)

		--get all buff already applied before the combat start
		Details:CatchRaidBuffUptime("BUFF_UPTIME_IN")
		Details:CatchRaidDebuffUptime("DEBUFF_UPTIME_IN")
		Details:UptadeRaidMembersCache()

		--Details222.TimeCapture.StartCombatTimer(Details.tabela_vigente)

		--we already have boss information? build .is_boss table
		if (Details.encounter_table.id and Details.encounter_table ["start"] >= GetTime() - 3 and not Details.encounter_table ["end"]) then
			local encounter_table = Details.encounter_table
			--boss_found will trigger "COMBAT_BOSS_FOUND" event, but at this point of the combat creation is safe to send it
			boss_found (encounter_table.index, encounter_table.name, encounter_table.zone, encounter_table.mapid, encounter_table.diff, encounter_table.id)
		else
			--if we don't have this infor right now, lets check in few seconds dop
			if (Details.EncounterInformation [Details.zone_id]) then
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

		if (Details.in_group and Details.cloud_capture) then
			if (Details:IsInInstance() or Details.debug) then
				if (not Details:CaptureIsAllEnabled()) then
					Details:ScheduleSendCloudRequest()
					--if (Details.debug) then
					--	Details:Msg("(debug) requesting a cloud server.")
					--end
				end
			else
				--if (Details.debug) then
				--	Details:Msg("(debug) isn't inside a registred instance", Details:IsInInstance())
				--end
			end
		else
			--if (Details.debug) then
			--	Details:Msg("(debug) isn't in group or cloud is turned off", Details.in_group, Details.cloud_capture)
			--end
		end

		--hide / alpha / switch in combat
		for index, instancia in ipairs(Details.tabela_instancias) do
			if (instancia.ativa) then
				instancia:CheckSwitchOnCombatStart (true)
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
		Details:CheckForTextTimeCounter (true)

		--stop bar testing if any
		Details:StopTestBarUpdate()
	end

	function Details:DelayedSyncAlert()
		local lower_instance = Details:GetLowerInstanceNumber()
		if (lower_instance) then
			lower_instance = Details:GetInstance(lower_instance)
			if (lower_instance) then
				if (not lower_instance:HaveInstanceAlert()) then
					lower_instance:InstanceAlert (Loc ["STRING_EQUILIZING"], {[[Interface\COMMON\StreamCircle]], 22, 22, true}, 5, {function() end})
				end
			end
		end
	end

	function Details:ScheduleSyncPlayerActorData()
		if ((IsInGroup() or IsInRaid()) and (Details.zone_type == "party" or Details.zone_type == "raid")) then
			--do not sync if in battleground or arena
			Details:SendCharacterData()
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
		end

		if (Details.tabela_vigente.bIsClosed) then
			return
		end
		Details.tabela_vigente.bIsClosed = true

		if (Details.tabela_vigente.__destroyed) then
			Details:Msg("a deleted combat was found during combat end, please report this bug on discord:")
			Details:Msg("combat destroyed by:", Details.tabela_vigente.__destroyedBy)
		end

		--flag the addon as 'leaving combat'
		Details.leaving_combat = true
		--save the unixtime of the latest combat end
		Details.last_combat_time = _tempo

		Details:CatchRaidBuffUptime("BUFF_UPTIME_OUT")
		Details:CatchRaidDebuffUptime("DEBUFF_UPTIME_OUT")
		Details:CloseEnemyDebuffsUptime()

		Details222.GuessSpecSchedules.ClearSchedules()

		--Details222.TimeCapture.StopCombat() --it did not start

		--check if this isn't a boss and try to find a boss in the segment
		if (not Details.tabela_vigente.is_boss) then

			--if this is a mythic+ dungeon, do not scan for encounter journal boss names in the actor list
			Details:FindBoss()

			--still didn't find the boss
			if (not Details.tabela_vigente.is_boss) then
				local ZoneName, _, DifficultyID, _, _, _, _, ZoneMapID = GetInstanceInfo()
				local findboss = Details:GetRaidBossFindFunction (ZoneMapID)
				if (findboss) then
					local BossIndex = findboss()
					if (BossIndex) then
						boss_found (BossIndex, Details:GetBossName (ZoneMapID, BossIndex), ZoneName, ZoneMapID, DifficultyID)
					end
				end
			end
		end

		Details:OnCombatPhaseChanged() --.PhaseData is nil here on alpha-32

		if (Details.tabela_vigente.bossFunction) then
			Details:CancelTimer(Details.tabela_vigente.bossFunction)
			Details.tabela_vigente.bossFunction = nil
		end

		--stop combat ticker
		Details:StopCombatTicker()

		--lock timers
		Details.tabela_vigente:LockActivityTime()

		--get waste shields
		if (Details.close_shields) then
			Details:CloseShields (Details.tabela_vigente)
		end

		--salva hora, minuto, segundo do fim da luta
		Details.tabela_vigente:seta_data (Details._detalhes_props.DATA_TYPE_END)
		Details.tabela_vigente:seta_tempo_decorrido()

		--drop last events table to garbage collector
		Details.tabela_vigente.player_last_events = {}

		--flag instance type
		local _, InstanceType = GetInstanceInfo()
		Details.tabela_vigente.instance_type = InstanceType

		if (not Details.tabela_vigente.is_boss and bIsFromEncounterEnd and type(bIsFromEncounterEnd) == "table") then
			local encounterID, encounterName, difficultyID, raidSize, endStatus = unpack(bIsFromEncounterEnd)
			if (encounterID) then
				local ZoneName, InstanceType, DifficultyID, DifficultyName, _, _, _, ZoneMapID = GetInstanceInfo()

				local mapID = C_Map.GetBestMapForUnit ("player")

				if (not mapID) then
					mapID = 0
				end

				local ejid = DetailsFramework.EncounterJournal.EJ_GetInstanceForMap (mapID)

				if (ejid == 0) then
					ejid = Details:GetInstanceEJID()
				end
				local _, boss_index = Details:GetBossEncounterDetailsFromEncounterId (ZoneMapID, encounterID)

				Details.tabela_vigente.is_boss = {
					index = boss_index or 0,
					name = encounterName,
					encounter = encounterName,
					zone = ZoneName,
					mapid = ZoneMapID,
					diff = DifficultyID,
					diff_string = DifficultyName,
					ej_instance_id = ejid or 0,
					id = encounterID,
					unixtime = time()
				}
			end
		end

		--tag as a mythic dungeon segment, can be any type of segment, this tag also avoid the segment to be tagged as trash
		local mythicLevel = C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo()
		if (mythicLevel and mythicLevel >= 2) then
			Details.tabela_vigente.is_mythic_dungeon_segment = true
			Details.tabela_vigente.is_mythic_dungeon_run_id = Details.mythic_dungeon_id
		end

		--send item level after a combat if is in raid or party group
		C_Timer.After(1, Details.ScheduleSyncPlayerActorData)

		--if this segment isn't a boss fight
		if (not Details.tabela_vigente.is_boss) then

			if (Details.tabela_vigente.is_pvp or Details.tabela_vigente.is_arena) then
				Details:FlagActorsOnPvPCombat()
			end

			if (Details.tabela_vigente.is_arena) then
				Details.tabela_vigente.enemy = "[" .. ARENA .. "] " ..  Details.tabela_vigente.is_arena.name
			end

			local in_instance = IsInInstance() --garrison returns party as instance type.
			if ((InstanceType == "party" or InstanceType == "raid") and in_instance) then
				if (InstanceType == "party") then
					if (Details.tabela_vigente.is_mythic_dungeon_segment) then --setted just above
						--is inside a mythic+ dungeon and this is not a boss segment, so tag it as a dungeon mythic+ trash segment
						local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
						Details.tabela_vigente.is_mythic_dungeon_trash = {
							ZoneName = zoneName,
							MapID = instanceMapID,
							Level = Details.MythicPlus.Level,
							EJID = Details.MythicPlus.ejID,
						}
					else
						--tag the combat as trash clean up
						Details.tabela_vigente.is_trash = true
					end
				else
					Details.tabela_vigente.is_trash = true
				end
			else
				if (not in_instance) then
					if (Details.world_combat_is_trash) then
						Details.tabela_vigente.is_world_trash_combat = true
					end
				end
			end

			if (not Details.tabela_vigente.enemy) then
				local enemy = Details:FindEnemy()

				if (enemy and Details.debug) then
					Details:Msg("(debug) enemy found", enemy)
				end

				Details.tabela_vigente.enemy = enemy
			end

			if (Details.debug) then
			--	Details:Msg("(debug) forcing equalize actors behavior.")
			--	Details:EqualizeActorsSchedule (Details.host_of)
			end

			Details:FlagActorsOnCommonFight() --fight_component
		else

			--this segment is a boss fight
			if (not InCombatLockdown() and not UnitAffectingCombat("player")) then

			else
				--Details.schedule_flag_boss_components = true
			end

			--calling here without checking for combat since the does not ran too long for scripts
			Details:FlagActorsOnBossFight()

			local boss_id = Details.encounter_table.id

			if (bossKilled) then
				Details.tabela_vigente.is_boss.killed = true

				--add to storage
				if (not InCombatLockdown() and not UnitAffectingCombat("player") and not Details.logoff_saving_data) then
					local successful, errortext = pcall(Details.Database.StoreEncounter)
					if (not successful) then
						Details:Msg("error occurred on Details.Database.StoreEncounter():", errortext)
					end
				else
					Details.schedule_store_boss_encounter = true
				end

				Details:SendEvent("COMBAT_BOSS_DEFEATED", nil, Details.tabela_vigente)

				Details:CheckFor_TrashSuppressionOnEncounterEnd()
			else
				Details:SendEvent("COMBAT_BOSS_WIPE", nil, Details.tabela_vigente)

				--add to storage
				if (not InCombatLockdown() and not UnitAffectingCombat("player") and not Details.logoff_saving_data) then
					local successful, errortext = pcall(Details.Database.StoreWipe)
					if (not successful) then
						Details:Msg("error occurred on Details.Database.StoreWipe():", errortext)
					end
				else
					Details.schedule_store_boss_encounter_wipe = true
				end

			end

			Details.tabela_vigente.is_boss.index = Details.tabela_vigente.is_boss.index or 1

			Details.tabela_vigente.enemy = Details.tabela_vigente.is_boss.encounter

			if (Details.tabela_vigente.instance_type == "raid") then

				Details.last_encounter2 = Details.last_encounter
				Details.last_encounter = Details.tabela_vigente.is_boss.name

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
					Details.tabela_vigente:SetStartTime (Details.encounter_table.start)
				end
				Details.tabela_vigente:SetEndTime (Details.encounter_table ["end"] or GetTime())
			end

			--encounter boss function
			local bossFunction, bossFunctionType = Details:GetBossFunction (Details.tabela_vigente.is_boss.mapid or 0, Details.tabela_vigente.is_boss.index or 0)
			if (bossFunction) then
				if (bitBand(bossFunctionType, 0x2) ~= 0) then --end of combat
					if (not Details.logoff_saving_data) then
						local successful, errortext = pcall(bossFunction, Details.tabela_vigente)
						if (not successful) then
							Details:Msg("error occurred on Encounter Boss Function:", errortext)
						end
					end
				end
			end

			if (Details.tabela_vigente.instance_type == "raid") then
				--schedule captures off

				Details:CaptureSet (false, "damage", false, 15)
				Details:CaptureSet (false, "energy", false, 15)
				Details:CaptureSet (false, "aura", false, 15)
				Details:CaptureSet (false, "energy", false, 15)
				Details:CaptureSet (false, "spellcast", false, 15)

				if (Details.debug) then
					Details:Msg("(debug) freezing parser for 15 seconds.")
				end
			end

			--schedule sync
			Details:EqualizeActorsSchedule (Details.host_of)
			if (Details:GetEncounterEqualize (Details.tabela_vigente.is_boss.mapid, Details.tabela_vigente.is_boss.index)) then
				Details:ScheduleTimer("DelayedSyncAlert", 3)
			end
		end

		if (Details.solo) then
			--debuffs need a checkup, not well functional right now
			Details.CloseSoloDebuffs()
		end

		local tempo_do_combate = Details.tabela_vigente:GetCombatTime()

		---@type combat
		local invalidCombat

		local segmentsTable = Details:GetCombatSegments()

		--to force discard, the segmentsTable must have at least on segment
		local bShouldForceDiscard = Details222.discardSegment and segmentsTable[1] and true

		local zoneName, zoneType = GetInstanceInfo()
		if (not bShouldForceDiscard and (zoneType == "none" or tempo_do_combate >= Details.minimum_combat_time or not segmentsTable[1])) then
			--combat accepted
			Details.tabela_historico:AddCombat(Details.tabela_vigente) --move a tabela atual para dentro do hist�rico
			if (Details.tabela_vigente.is_boss) then
				if (IsInRaid()) then
					local cleuID = Details.tabela_vigente.is_boss.id
					local diff = Details.tabela_vigente.is_boss.diff
					if (cleuID and diff == 16) then -- 16 mythic
						local raidData = Details.raid_data

						--get or build mythic raid data table
						local mythicRaidData = raidData.mythic_raid_data
						if (not mythicRaidData) then
							mythicRaidData = {}
							raidData.mythic_raid_data = mythicRaidData
						end

						--get or build a table for this cleuID
						mythicRaidData [cleuID] = mythicRaidData [cleuID] or {wipes = 0, kills = 0, best_try = 1, longest = 0, try_history = {}}
						local cleuIDData = mythicRaidData [cleuID]

						--store encounter data for plugins and weakauras
						if (Details.tabela_vigente:GetCombatTime() > cleuIDData.longest) then
							cleuIDData.longest = Details.tabela_vigente:GetCombatTime()
						end

						if (Details.tabela_vigente.is_boss.killed) then
							cleuIDData.kills = cleuIDData.kills + 1
							cleuIDData.best_try = 0
							table.insert(cleuIDData.try_history, {0, Details.tabela_vigente:GetCombatTime()})
							--print("KILL", "best try", cleuIDData.best_try, "amt kills", cleuIDData.kills, "wipes", cleuIDData.wipes, "longest", cleuIDData.longest)
						else
							cleuIDData.wipes = cleuIDData.wipes + 1
							if (Details.boss1_health_percent and Details.boss1_health_percent < cleuIDData.best_try) then
								cleuIDData.best_try = Details.boss1_health_percent
								table.insert(cleuIDData.try_history, {Details.boss1_health_percent, Details.tabela_vigente:GetCombatTime()})
							end
							--print("WIPE", "best try", cleuIDData.best_try, "amt kills", cleuIDData.kills, "wipes", cleuIDData.wipes, "longest", cleuIDData.longest)
						end
					end
				end
				--
			end

			--the combat is valid, see if the user is sharing data with somebody
			if (Details.shareData) then
				local zipData = Details:CompressData (Details.tabela_vigente, "comm")
				if (zipData) then
					print("has zip data")
				end
			end

		else
			--combat denied: combat did not pass the filter and cannot be added into the segment history
			--rewind the data set to the first slot in the segments table
			showTutorialForDiscardedSegment()

			--change the current combat to the latest combat available in the segment table
			invalidCombat = Details.tabela_vigente
			Details.tabela_vigente = segmentsTable[1]

			--if it rewinds to an already erased combat, then create a new combat
			if (Details.tabela_vigente.__destroyed) then
				Details.tabela_vigente = Details.combate:NovaTabela(nil, Details.tabela_overall)
			end

			if (Details.tabela_vigente:GetStartTime() == 0) then
				Details.tabela_vigente:SetStartTime(GetTime())
				Details.tabela_vigente:SetEndTime(GetTime())
			end

			Details.tabela_vigente.resincked = true
			Details:InstanceCallDetailsFunc(Details.AtualizarJanela)

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

		Details:Destroy(Details.tabela_vigente.PhaseData.damage_section)
		Details:Destroy(Details.tabela_vigente.PhaseData.heal_section)
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

		--do not wipe the encounter table if is in the argus encounter ~REMOVE on 8.0
		if (Details.encounter_table and Details.encounter_table.id ~= 2092) then
			Details:Destroy(Details.encounter_table)
		else
			if (Details.debug) then
				Details:Msg("(debug) in argus encounter, cannot wipe the encounter table.")
			end
		end

		Details:InstanceCall(Details.CheckPsUpdate)

		if (invalidCombat) then
			Details:SendEvent("COMBAT_INVALID")
			Details:SendEvent("COMBAT_PLAYER_LEAVE", nil, invalidCombat)
		else
			Details:SendEvent("COMBAT_PLAYER_LEAVE", nil, Details.tabela_vigente)
		end

		Details:CheckForTextTimeCounter()
		Details.StoreSpells()
		Details:RunScheduledEventsAfterCombat()

		--issue: invalidCombat will be just floating around in memory if not destroyed
	end --end of leaving combat function

	function Details:GetPlayersInArena()
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
		Details:Destroy(_detalhes.arena_enemies)

		for i = 1, enemiesAmount do
			local enemyName = Details:GetFullName("arena" .. i)
			if (enemyName) then
				_detalhes.arena_enemies[enemyName] = "arena" .. i
			end
		end
	end

	--attempt to get the arena unitId for an actor
	--this function is called from containerActors while reading the actor flag and parser when managing deathlog
	function Details:GuessArenaEnemyUnitId(unitName)
		for i = 1, 5 do
			local unitId = "arena" .. i
			local enemyName = Details:GetFullName(unitId)
			if (enemyName == unitName) then
				_detalhes.arena_enemies[enemyName] = unitId
				return unitId
			end
		end
	end

	local string_arena_enemyteam_damage = [[
		local combat = Details:GetCombat("current")
		local total = 0

		for _, actor in combat[1]:ListActors() do
			if (actor.arena_enemy) then
				total = total + actor.total
			end
		end

		return total
	]]

	local string_arena_myteam_damage = [[
		local combat = Details:GetCombat("current")
		local total = 0

		for _, actor in combat[1]:ListActors() do
			if (actor.arena_ally) then
				total = total + actor.total
			end
		end

		return total
	]]

	local string_arena_enemyteam_heal = [[
		local combat = Details:GetCombat("current")
		local total = 0

		for _, actor in combat[2]:ListActors() do
			if (actor.arena_enemy) then
				total = total + actor.total
			end
		end

		return total
	]]

	local string_arena_myteam_heal = [[
		local combat = Details:GetCombat("current")
		local total = 0

		for _, actor in combat[2]:ListActors() do
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

		--registra os gr�ficos
		Details:TimeDataRegister ("Your Team Damage", string_arena_myteam_damage, nil, "Details!", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)
		Details:TimeDataRegister ("Enemy Team Damage", string_arena_enemyteam_damage, nil, "Details!", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)

		Details:TimeDataRegister ("Your Team Healing", string_arena_myteam_heal, nil, "Details!", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)
		Details:TimeDataRegister ("Enemy Team Healing", string_arena_enemyteam_heal, nil, "Details!", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)

		Details.lastArenaStartTime = GetTime()

		--inicia um novo combate
		Details:EntrarEmCombate()

		--sinaliza que esse combate � arena
		Details.tabela_vigente.arena = true
		Details.tabela_vigente.is_arena = {name = Details.zone_name, zone = Details.zone_name, mapid = Details.zone_id}

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

		--CHAT_MSG_BG_SYSTEM_NEUTRAL - "The Arena battle has begun!""
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

		Details:TimeDataUnregister ("Your Team Damage")
		Details:TimeDataUnregister ("Enemy Team Damage")

		Details:TimeDataUnregister ("Your Team Healing")
		Details:TimeDataUnregister ("Enemy Team Healing")

		Details:SendEvent("COMBAT_ARENA_END")

		--reset the update speed, as it could have changed when the arena started.
		Details:SetWindowUpdateSpeed(Details.update_speed)
	end

	local validSpells = {
		[220893] = {class = "ROGUE", spec = 261, maxPercent = 0.075, container = 1, commID = "MISSDATA_ROGUE_SOULRIP"},
		--[11366] = {class = "MAGE", spec = 63, maxPercent = 0.9, container = 1, commID = "MISSDATA_ROGUE_SOULRIP"},
	}

	function Details:CanSendMissData()
		if (not IsInRaid() and not IsInGroup()) then
			return
		end
		local _, playerClass = UnitClass("player")
		local specIndex = DetailsFramework.GetSpecialization()
		local playerSpecID
		if (specIndex) then
			playerSpecID = DetailsFramework.GetSpecializationInfo(specIndex)
		end

		if (playerSpecID and playerClass) then
			for spellID, t in pairs(validSpells) do
				if (playerClass == t.class and playerSpecID == t.spec) then
					Details:SendMissData (spellID, t.container, Details.network.ids [t.commID])
				end
			end
		end
		return false
	end

	function Details:SendMissData (spellID, containerType, commID)
		local combat = Details.tabela_vigente
		if (combat) then
			local damageActor = combat (containerType, Details.playername)
			if (damageActor) then
				local spell = damageActor.spells:GetSpell (spellID)
				if (spell) then
					local data = {
						[1] = containerType,
						[2] = spellID,
						[3] = spell.total,
						[4] = spell.counter
					}

					if (Details.debug) then
						Details:Msg("(debug) sending miss data packet:", spellID, containerType, commID)
					end

					Details:SendRaidOrPartyData (commID, data)
				end
			end
		end
	end

	function Details.HandleMissData (playerName, data)
		local combat = Details.tabela_vigente

		if (Details.debug) then
			Details:Msg("(debug) miss data received from:", playerName, "spellID:", data [2], data [3], data [4])
		end

		if (combat) then
			local containerType = data[1]
			if (type(containerType) ~= "number" or containerType < 1 or containerType > 4) then
				return
			end

			local damageActor = combat (containerType, playerName)
			if (damageActor) then
				local spellID = data[2] --a spellID has been passed?
				if (not spellID or type(spellID) ~= "number") then
					return
				end

				local validateSpell = validSpells [spellID]
				if (not validateSpell) then --is a valid spell?
					return
				end

				--does the target player fit in the spell requirement on OUR end?
				local class, spec, maxPercent = validateSpell.class, validateSpell.spec, validateSpell.maxPercent
				if (class ~= damageActor.classe or spec ~= damageActor.spec) then
					return
				end

				local total, counter = data[3], data[4]
				if (type(total) ~= "number" or type(counter) ~= "number") then
					return
				end

				if (total > (damageActor.total * maxPercent)) then
					return
				end

				local spellObject = damageActor.spells:PegaHabilidade (spellID, true)
				if (spellObject) then
					if (spellObject.total < total and total > 0 and damageActor.nome ~= Details.playername) then
						local difference = total - spellObject.total
						if (difference > 0) then
							spellObject.total = total
							spellObject.counter = counter
							damageActor.total = damageActor.total + difference

							combat [containerType].need_refresh = true

							if (Details.debug) then
								Details:Msg("(debug) miss data successful added from:", playerName, data [2], "difference:", difference)
							end
						end
					end
				end
			end
		end
	end

	function Details:MakeEqualizeOnActor (player, realm, receivedActor)
		if (true) then --disabled for testing
			return
		end
	end

	function Details:EqualizePets()
		--check for pets without owner
		for _, actor in ipairs(Details.tabela_vigente[1]._ActorTable) do
			--have flag and the flag tell us he is a pet
			if (actor.flag_original and bit.band(actor.flag_original, OBJECT_TYPE_PETS) ~= 0) then
				--do not have owner and he isn't on owner container
				if (not actor.owner and not Details.tabela_pets.pets [actor.serial]) then
					Details:SendPetOwnerRequest (actor.serial, actor.nome)
				end
			end
		end
	end

	function Details:EqualizeActorsSchedule (host_of)

		--store pets sent through 'needpetowner'
		Details.sent_pets = Details.sent_pets or {n = time()}
		if (Details.sent_pets.n+20 < time()) then
			Details:Destroy(Details.sent_pets)
			Details.sent_pets.n = time()
		end

		--pet equilize disabled on details 1.4.0
		--Details:ScheduleTimer("EqualizePets", 1+math.random())

		--do not equilize if there is any disabled capture
		--if (Details:CaptureIsAllEnabled()) then
			Details:ScheduleTimer("EqualizeActors", 2+math.random()+math.random() , host_of)
		--end
	end

	function Details:EqualizeActors (host_of)

		--Disabling the sync. Since WoD combatlog are sent between player on phased zones during encounters.
		if (not host_of or true) then --full disabled for testing
			return
		end

		if (Details.debug) then
			Details:Msg("(debug) sending equilize actor data")
		end

		local damage, heal, energy, misc

		if (host_of) then
			damage, heal, energy, misc = Details:GetAllActors("current", host_of)
		else
			damage, heal, energy, misc = Details:GetAllActors("current", Details.playername)
		end

		if (damage) then
			damage = {damage.total or 0, damage.damage_taken or 0, damage.friendlyfire_total or 0}
		else
			damage = {0, 0, 0}
		end

		if (heal) then
			heal = {heal.total or 0, heal.totalover or 0, heal.healing_taken or 0}
		else
			heal = {0, 0, 0}
		end

		if (energy) then
			energy = {energy.mana or 0, energy.e_rage or 0, energy.e_energy or 0, energy.runepower or 0}
		else
			energy = {0, 0, 0, 0}
		end

		if (misc) then
			misc = {misc.interrupt or 0, misc.dispell or 0}
		else
			misc = {0, 0}
		end

		local data = {damage, heal, energy, misc}

		--envia os dados do proprio host pra ele antes
		if (host_of) then
			Details:SendRaidDataAs (Details.network.ids.CLOUD_EQUALIZE, host_of, nil, data)
			Details:EqualizeActors()
		else
			Details:SendRaidData (Details.network.ids.CLOUD_EQUALIZE, data)
		end

	end

	function Details:FlagActorsOnPvPCombat()
		for class_type, container in ipairs(Details.tabela_vigente) do
			for _, actor in ipairs(container._ActorTable) do
				actor.pvp_component = true
			end
		end
	end

	function Details:FlagActorsOnBossFight()
		for class_type, container in ipairs(Details.tabela_vigente) do
			for _, actor in ipairs(container._ActorTable) do
				actor.boss_fight_component = true
			end
		end
	end

	local fight_component = function(energy_container, misc_container, name)
		local on_energy = energy_container._ActorTable [energy_container._NameIndexTable [name]]
		if (on_energy) then
			on_energy.fight_component = true
		end
		local on_misc = misc_container._ActorTable [misc_container._NameIndexTable [name]]
		if (on_misc) then
			on_misc.fight_component = true
		end
	end

	function Details:FlagActorsOnCommonFight()
		local damage_container = Details.tabela_vigente [1]
		local healing_container = Details.tabela_vigente [2]
		local energy_container = Details.tabela_vigente [3]
		local misc_container = Details.tabela_vigente [4]

		local mythicDungeonRun = Details.tabela_vigente.is_mythic_dungeon_segment

		for class_type, container in ipairs({damage_container, healing_container}) do

			for _, actor in ipairs(container._ActorTable) do

				if (mythicDungeonRun) then
					actor.fight_component = true
				end

				if (actor.grupo) then
					if (class_type == 1 or class_type == 2) then
						for target_name, amount in pairs(actor.targets) do
							local target_object = container._ActorTable [container._NameIndexTable [target_name]]
							if (target_object) then
								target_object.fight_component = true
								fight_component (energy_container, misc_container, target_name)
							end
						end
						if (class_type == 1) then
							for damager_actor, _ in pairs(actor.damage_from) do
								local target_object = container._ActorTable [container._NameIndexTable [damager_actor]]
								if (target_object) then
									target_object.fight_component = true
									fight_component (energy_container, misc_container, damager_actor)
								end
							end
						elseif (class_type == 2) then
							for healer_actor, _ in pairs(actor.healing_from) do
								local target_object = container._ActorTable [container._NameIndexTable [healer_actor]]
								if (target_object) then
									target_object.fight_component = true
									fight_component (energy_container, misc_container, healer_actor)
								end
							end
						end
					end
				end
			end

		end
	end

	function Details:AtualizarJanela (instancia, _segmento)
		if (_segmento) then --apenas atualizar janelas que estejam mostrando o segmento solicitado
			if (_segmento == instancia.segmento) then
				instancia:TrocaTabela(instancia, instancia.segmento, instancia.atributo, instancia.sub_atributo, true)
			end
		else
			if (instancia.modo == modo_GROUP or instancia.modo == modo_ALL) then
				instancia:TrocaTabela(instancia, instancia.segmento, instancia.atributo, instancia.sub_atributo, true)
			end
		end
	end

	function Details:PostponeInstanceToCurrent (instance)
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
				return Details:TrocaSegmentoAtual (instance)
			else
				return
			end
		end
		if (instance.is_interacting and instance.last_interaction < _tempo) then
			instance.last_interaction = _tempo
		end
		instance._postponing_current = Details:ScheduleTimer("PostponeInstanceToCurrent", 1, instance)
	end

	function Details:TrocaSegmentoAtual (instancia, is_encounter)
		if (instancia.segmento == 0 and instancia.baseframe and instancia.ativa) then

			if (not is_encounter) then
				if (instancia.is_interacting) then
					if (not instancia.last_interaction or instancia.last_interaction < _tempo) then
						instancia.last_interaction = _tempo or time()
					end
				end

				if ((instancia.last_interaction and (instancia.last_interaction+3 > Details._tempo)) or (DetailsReportWindow and DetailsReportWindow:IsShown()) or (Details.BreakdownWindowFrame:IsShown())) then
					--postpone
					instancia._postponing_current = Details:ScheduleTimer("PostponeInstanceToCurrent", 1, instancia)
					return
				end
			end

			--print("==> Changing the Segment now! - control.lua 1220")

			instancia.last_interaction = _tempo - 4 --pode setar, completou o ciclo
			instancia._postponing_current = nil
			instancia.showing = Details.tabela_vigente
			instancia:ResetaGump()
			Details.FadeHandler.Fader(instancia, "in", nil, "barras")
		end
	end

	function Details:SetTrashSuppression (n)
		assert(type(n) == "number", "SetTrashSuppression expects a number on index 1.")
		if (n < 0) then
			n = 0
		end
		Details.instances_suppress_trash = n
	end
	function Details:CheckFor_SuppressedWindowsOnEncounterFound()
		for _, instance in Details:ListInstances() do
			if (instance.ativa and instance.baseframe and (not instance.last_interaction or instance.last_interaction > _tempo) and instance.segmento == 0) then
				Details:TrocaSegmentoAtual (instance, true)
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
		GameCooltip:AddLine (Loc ["STRING_CLICK_REPORT_LINE1"], Loc ["STRING_CLICK_REPORT_LINE2"])
		GameCooltip:AddStatusBar (100, 1, 0, 0, 0, 0.8)
	end

	function Details:AddTooltipBackgroundStatusbar (side, value, useSpark, statusBarColor)
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

		useSpark = true
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
			GameCooltip:AddStatusBar (value, 1, r, g, b, a, useSpark, {value = 100, color = {rBG, gBG, bBG, aBG}, texture = [[Interface\AddOns\Details\images\bar_serenity]]})

		else
			GameCooltip:AddStatusBar (value, 2, unpack(Details.tooltip.bar_color))
		end
	end

	function Details:AddTooltipHeaderStatusbar (r, g, b, a)
		local r, g, b, a, statusbarGlow, backgroundBar = unpack(Details.tooltip.header_statusbar)
		GameCooltip:AddStatusBar (100, 1, r, g, b, a, statusbarGlow, backgroundBar, "Skyline")
	end

-- /run local a,b=Details.tooltip.header_statusbar,0.3;a[1]=b;a[2]=b;a[3]=b;a[4]=0.8;

	function Details:AddTooltipSpellHeaderText (headerText, headerColor, amount, iconTexture, L, R, T, B, separator, iconSize)
		if (separator and separator == true) then
			GameCooltip:AddLine ("", "", nil, nil, 1, 1, 1, 1, 8)
			return
		end

		if (type(iconSize) ~= "number") then
			iconSize = 14
		end

		if (Details.tooltip.show_amount) then
			GameCooltip:AddLine (headerText, "x" .. amount .. "", nil, headerColor, 1, 1, 1, .4, Details.tooltip.fontsize_title)
		else
			GameCooltip:AddLine (headerText, nil, nil, headerColor, nil, Details.tooltip.fontsize_title)
		end

		if (iconTexture) then
			GameCooltip:AddIcon (iconTexture, 1, 1, iconSize, iconSize, L or 0, R or 1, T or 0, B or 1)
		end
	end

	local bgColor, borderColor = {0, 0, 0, 0.8}, {0, 0, 0, 0} --{0.37, 0.37, 0.37, .75}, {.30, .30, .30, .3}

	function Details:FormatCooltipForSpells()
		local GameCooltip = GameCooltip

		GameCooltip:Reset()
		GameCooltip:SetType ("tooltip")

		GameCooltip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar_background_dark_withline]])

		GameCooltip:SetOption("TextSize", Details.tooltip.fontsize)
		GameCooltip:SetOption("TextFont",  Details.tooltip.fontface)
		GameCooltip:SetOption("TextColor", Details.tooltip.fontcolor)
		GameCooltip:SetOption("TextColorRight", Details.tooltip.fontcolor_right)
		GameCooltip:SetOption("TextShadow", Details.tooltip.fontshadow and "OUTLINE")

		GameCooltip:SetOption("LeftBorderSize", -5)
		GameCooltip:SetOption("RightBorderSize", 5)
		GameCooltip:SetOption("RightTextMargin", 0)
		GameCooltip:SetOption("VerticalOffset", 9)
		GameCooltip:SetOption("AlignAsBlizzTooltip", true)
		GameCooltip:SetOption("AlignAsBlizzTooltipFrameHeightOffset", -8)
		GameCooltip:SetOption("LineHeightSizeOffset", 4)
		GameCooltip:SetOption("VerticalPadding", -4)

		GameCooltip:SetBackdrop(1, Details.cooltip_preset2_backdrop, bgColor, borderColor)
	end

	function Details:BuildInstanceBarTooltip (frame)
		local GameCooltip = GameCooltip
		Details:FormatCooltipForSpells()
		GameCooltip:SetOption("MinWidth", _math_max (230, self.baseframe:GetWidth()*0.98))

		local myPoint = Details.tooltip.anchor_point
		local anchorPoint = Details.tooltip.anchor_relative
		local x_Offset = Details.tooltip.anchor_offset[1]
		local y_Offset = Details.tooltip.anchor_offset[2]

		if (Details.tooltip.anchored_to == 1) then

			GameCooltip:SetHost (frame, myPoint, anchorPoint, x_Offset, y_Offset)
		else
			GameCooltip:SetHost (DetailsTooltipAnchor, myPoint, anchorPoint, x_Offset, y_Offset)
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
				local avatar = NickTag:GetNicknameTable(object.serial, true)
				if (avatar and not Details.ignore_nicktag) then
					if (avatar[2] and avatar[4] and avatar[1]) then
						GameCooltip:SetBannerImage(1, 1, avatar [2], 80, 40, avatarPoint, avatarTexCoord, nil) --overlay [2] avatar path
						GameCooltip:SetBannerImage(1, 2, avatar [4], 200, 55, backgroundPoint, avatar [5], avatar [6]) --background
						GameCooltip:SetBannerText(1, 1, (not Details.ignore_nicktag and avatar[1]) or object.nome, textPoint, avatarTextColor, 14, SharedMedia:Fetch("font", Details.tooltip.fontface)) --text [1] nickname
					end
				end
			end

			GameCooltip:ShowCooltip()
		end
	end

	function Details.gump:UpdateTooltip (whichRowLine, esta_barra, instancia)
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

	function Details:EndRefresh (instancia, total, combatTable, showing)
		Details:HideBarsNotInUse(instancia, showing)
	end

	function Details:HideBarsNotInUse(instancia, showing)
		--primeira atualiza��o ap�s uma mudan�a de segmento -- verifica se h� mais barras sendo mostradas do que o necess�rio
		--------------------
			if (instancia.v_barras) then
				--print("mostrando", instancia.rows_showing, instancia.rows_created)
				for barra_numero = instancia.rows_showing+1, instancia.rows_created do
					Details.FadeHandler.Fader(instancia.barras[barra_numero], "in")
				end
				instancia.v_barras = false

				if (instancia.rows_showing == 0 and instancia:GetSegment() == -1) then -- -1 overall data
					if (not instancia:IsShowingOverallDataWarning()) then
						local tutorial = Details:GetTutorialCVar("OVERALLDATA_WARNING1") or 0
						if ((type(tutorial) == "number") and (tutorial < 60)) then
							Details:SetTutorialCVar ("OVERALLDATA_WARNING1", tutorial + 1)
							instancia:ShowOverallDataWarning (true)
						end
					end
				else
					if (instancia:IsShowingOverallDataWarning()) then
						instancia:ShowOverallDataWarning (false)
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
			--[[return]] atributo_damage:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)

		elseif (self.atributo == 2) then --heal
			--[[return]] atributo_heal:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)

		elseif (self.atributo == 3) then --energy
			--[[return]] atributo_energy:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)

		elseif (self.atributo == 4) then --outros
			--[[return]] atributo_misc:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)

		elseif (self.atributo == 5) then --ocustom
			--[[return]] atributo_custom:RefreshWindow(self, combatObject, bForceRefresh, nil, needRefresh)
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
					if (actorObject and not actorObject.__destroyed) then
						return actorObject:MontaInfo() --MontaInfo a nil value
					else
						Details:Msg("Invalid actor object on breakdown window.")
						if (actorObject.__destroyed) then
							Details:Msg("Invalidation Reason:", actorObject.__destroyedBy)
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
		local panel = _G.DetailsEraseDataConfirmation
		if (not panel) then
			panel = CreateFrame("frame", "DetailsEraseDataConfirmation", UIParent, "BackdropTemplate")
			panel:SetSize(400, 85)
			panel:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16,
			edgeFile = [[Interface\AddOns\Details\images\border_2]], edgeSize = 12})
			panel:SetPoint("center", UIParent)
			panel:SetBackdropColor(0, 0, 0, 0.4)

			DetailsFramework:ApplyStandardBackdrop(panel)

			panel:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					panel:Hide()
				end
			end)

			--[=[
				create 3 options
				- overall data only
				- current data only
				- both

			--=]=]

			local text = Details.gump:CreateLabel(panel, Loc ["STRING_OPTIONS_CONFIRM_ERASE"], nil, nil, "GameFontNormal")
			text:SetPoint("center", panel, "center")
			text:SetPoint("top", panel, "top", 0, -10)

			local no = Details.gump:CreateButton(panel, function() panel:Hide() end, 90, 20, Loc ["STRING_NO"])
			no:SetPoint("bottomleft", panel, "bottomleft", 30, 10)
			no:InstallCustomTexture (nil, nil, nil, nil, true)

			local yes = Details.gump:CreateButton(panel, function() panel:Hide(); Details.tabela_historico:ResetAllCombatData() end, 90, 20, Loc ["STRING_YES"])
			yes:SetPoint("bottomright", panel, "bottomright", -30, 10)
			yes:InstallCustomTexture (nil, nil, nil, nil, true)
		end

		panel:Show()
	end

	function Details:CheckForAutoErase (mapid)
		if (Details.last_instance_id ~= mapid) then
			Details.tabela_historico:ResetOverallData()

			if (Details.segments_auto_erase == 2) then --ask to erase
				Details:ScheduleTimer("AutoEraseConfirm", 1)

			elseif (Details.segments_auto_erase == 3) then
				--erase
				Details.tabela_historico:ResetAllCombatData()
			end
		else
			if (_tempo > Details.last_instance_time + 21600) then --6 hours
				if (Details.segments_auto_erase == 2) then
					--ask
					Details:ScheduleTimer("AutoEraseConfirm", 1)
				elseif (Details.segments_auto_erase == 3) then
					--erase
					Details.tabela_historico:ResetAllCombatData()
				end
			end
		end

		Details.last_instance_id = mapid
		Details.last_instance_time = _tempo
		--Details.last_instance_time = 0 --debug
	end

	function Details:UpdateControl()
		_tempo = Details._tempo
	end

