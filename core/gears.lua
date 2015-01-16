local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local UnitName = UnitName
local select = select
local floor = floor

local GetNumGroupMembers = GetNumGroupMembers

function _detalhes:UpdateGears()
	
	_detalhes:UpdateParser()
	_detalhes:UpdateControl()
	_detalhes:UpdateCombat()
	
end

function _detalhes:TrackSpecsNow (track_everything)

	local spelllist = _detalhes.SpecSpellList
	
	if (not track_everything) then
		for _, actor in _detalhes.tabela_vigente[1]:ListActors() do
			if (actor:IsPlayer()) then
				for spellid, spell in pairs (actor:GetSpellList()) do
					if (spelllist [spell.id]) then
						actor.spec = spelllist [spell.id]
						_detalhes.cached_specs [actor.serial] = actor.spec
						break
					end
				end
			end
		end

		for _, actor in _detalhes.tabela_vigente[2]:ListActors() do
			if (actor:IsPlayer()) then
				for spellid, spell in pairs (actor:GetSpellList()) do
					if (spelllist [spell.id]) then
						actor.spec = spelllist [spell.id]
						_detalhes.cached_specs [actor.serial] = actor.spec
						break
					end
				end
			end
		end
	else
		local combatlist = {}
		for _, combat in ipairs (_detalhes.tabela_historico.tabelas) do
			tinsert (combatlist, combat)
		end
		tinsert (combatlist, _detalhes.tabela_vigente)
		tinsert (combatlist, _detalhes.tabela_overall)
		
		for _, combat in ipairs (combatlist) do
			for _, actor in combat[1]:ListActors() do
				if (actor:IsPlayer()) then
					for spellid, spell in pairs (actor:GetSpellList()) do
						if (spelllist [spell.id]) then
							actor.spec = spelllist [spell.id]
							_detalhes.cached_specs [actor.serial] = actor.spec
							break
						end
					end
				end
			end

			for _, actor in combat[2]:ListActors() do
				if (actor:IsPlayer()) then
					for spellid, spell in pairs (actor:GetSpellList()) do
						if (spelllist [spell.id]) then
							actor.spec = spelllist [spell.id]
							_detalhes.cached_specs [actor.serial] = actor.spec
							break
						end
					end
				end
			end
		end
	end
	
end

function _detalhes:ResetSpecCache (forced)

	local isininstance = IsInInstance()
	
	if (forced or (not isininstance and not _detalhes.in_group)) then
		table.wipe (_detalhes.cached_specs)
		
		if (_detalhes.track_specs) then
			local my_spec = GetSpecialization()
			if (type (my_spec) == "number") then
				local spec_number = GetSpecializationInfo (my_spec)
				if (type (spec_number) == "number") then
					local pguid = UnitGUID (_detalhes.playername)
					if (pguid) then
						_detalhes.cached_specs [pguid] = spec_number
					end
				end
			end
		end
	
	elseif (_detalhes.in_group and not isininstance) then
		table.wipe (_detalhes.cached_specs)
		
		if (_detalhes.track_specs) then
			if (IsInRaid()) then
				local c_combat_dmg = _detalhes.tabela_vigente [1]
				local c_combat_heal = _detalhes.tabela_vigente [2]
				for i = 1, GetNumGroupMembers(), 1 do
					local name = GetUnitName ("raid" .. i, true)
					local index = c_combat_dmg._NameIndexTable [name]
					if (index) then
						local actor = c_combat_dmg._ActorTable [index]
						if (actor and actor.grupo and actor.spec) then
							_detalhes.cached_specs [actor.serial] = actor.spec
						end
					else
						index = c_combat_heal._NameIndexTable [name]
						if (index) then
							local actor = c_combat_heal._ActorTable [index]
							if (actor and actor.grupo and actor.spec) then
								_detalhes.cached_specs [actor.serial] = actor.spec
							end
						end
					end
				end
			end
		end
	end
	
end

function _detalhes:SetWindowUpdateSpeed (interval, nosave)
	if (not interval) then
		interval = _detalhes.update_speed
	end
	
	if (not nosave) then
		_detalhes.update_speed = interval
	end
	
	_detalhes:CancelTimer (_detalhes.atualizador)
	_detalhes.atualizador = _detalhes:ScheduleRepeatingTimer ("AtualizaGumpPrincipal", interval, -1)
end

function _detalhes:SetUseAnimations (enabled, nosave)
	if (enabled == nil) then
		enabled = _detalhes.use_row_animations
	end
	
	if (not nosave) then
		_detalhes.use_row_animations = enabled
	end
	
	_detalhes.is_using_row_animations = enabled
end

function _detalhes:HavePerformanceProfileEnabled()
	return _detalhes.performance_profile_enabled
end

_detalhes.PerformanceIcons = {
	["RaidFinder"] = {icon = [[Interface\PvPRankBadges\PvPRank15]], color = {1, 1, 1, 1}},
	["Raid15"] = {icon = [[Interface\PvPRankBadges\PvPRank15]], color = {1, .8, 0, 1}},
	["Raid30"] = {icon = [[Interface\PvPRankBadges\PvPRank15]], color = {1, .8, 0, 1}},
	["Mythic"] = {icon = [[Interface\PvPRankBadges\PvPRank15]], color = {1, .4, 0, 1}},
	["Battleground15"] = {icon = [[Interface\PvPRankBadges\PvPRank07]], color = {1, 1, 1, 1}},
	["Battleground40"] = {icon = [[Interface\PvPRankBadges\PvPRank07]], color = {1, 1, 1, 1}},
	["Arena"] = {icon = [[Interface\PvPRankBadges\PvPRank12]], color = {1, 1, 1, 1}},
	["Dungeon"] = {icon = [[Interface\PvPRankBadges\PvPRank01]], color = {1, 1, 1, 1}},
}

function _detalhes:CheckForPerformanceProfile()
	
	local type = _detalhes:GetPerformanceRaidType()
	
	local profile = _detalhes.performance_profiles [type]
	
	if (profile and profile.enabled) then
		_detalhes:SetWindowUpdateSpeed (profile.update_speed, true)
		_detalhes:SetUseAnimations (profile.use_row_animations, true)
		_detalhes:CaptureSet (profile.damage, "damage")
		_detalhes:CaptureSet (profile.heal, "heal")
		_detalhes:CaptureSet (profile.energy, "energy")
		_detalhes:CaptureSet (profile.miscdata, "miscdata")
		_detalhes:CaptureSet (profile.aura, "aura")
		
		if (not _detalhes.performance_profile_lastenabled or _detalhes.performance_profile_lastenabled ~= type) then
			_detalhes:InstanceAlert (Loc ["STRING_OPTIONS_PERFORMANCE_PROFILE_LOAD"] .. type, {_detalhes.PerformanceIcons [type].icon, 14, 14, false, 0, 1, 0, 1, unpack (_detalhes.PerformanceIcons [type].color)} , 5, {_detalhes.empty_function})
		end
		
		_detalhes.performance_profile_enabled = type
		_detalhes.performance_profile_lastenabled = type
	else
		_detalhes:SetWindowUpdateSpeed (_detalhes.update_speed)
		_detalhes:SetUseAnimations (_detalhes.use_row_animations)
		_detalhes:CaptureSet (_detalhes.capture_real ["damage"], "damage")
		_detalhes:CaptureSet (_detalhes.capture_real ["heal"], "heal")
		_detalhes:CaptureSet (_detalhes.capture_real ["energy"], "energy")
		_detalhes:CaptureSet (_detalhes.capture_real ["miscdata"], "miscdata")
		_detalhes:CaptureSet (_detalhes.capture_real ["aura"], "aura")
		_detalhes.performance_profile_enabled = nil
	end
	
end

function _detalhes:GetPerformanceRaidType()

	local name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()

	if (type == "none") then
		return nil
	end
	
	if (type == "pvp") then
		if (maxPlayers == 40) then
			return "Battleground40"
		elseif (maxPlayers == 15) then
			return "Battleground15"
		else
			return nil
		end
	end
	
	if (type == "arena") then
		return "Arena"
	end

	if (type == "raid") then
		--mythic
		if (difficulty == 15) then
			return "Mythic"
		end
		
		--raid finder
		if (difficulty == 7) then
			return "RaidFinder"
		end
		
		--flex
		if (difficulty == 14) then
			if (GetNumGroupMembers() > 15) then
				return "Raid30"
			else
				return "Raid15"
			end
		end
		
		--normal heroic
		if (maxPlayers == 10) then
			return "Raid15"
		elseif (maxPlayers == 25) then
			return "Raid30"
		end
	end
	
	if (type == "party") then
		return "Dungeon"
	end
	
	return nil
end

local background_tasks = {}
local task_timers = {
	["LOW"] = 30,
	["MEDIUM"] = 18,
	["HIGH"] = 10,
}

function _detalhes:RegisterBackgroundTask (name, func, priority, ...)

	assert (type (self) == "table", "RegisterBackgroundTask 'self' must be a table.")
	assert (type (name) == "string", "RegisterBackgroundTask param #1 must be a string.")
	if (type (func) == "string") then
		assert (type (self [func]) == "function", "RegisterBackgroundTask param #2 function not found on main object.")
	else
		assert (type (func) == "function", "RegisterBackgroundTask param #2 expect a function or function name.")
	end
	
	priority = priority or "LOW"
	priority = string.upper (priority)
	if (not task_timers [priority]) then
		priority = "LOW"
	end

	if (background_tasks [name]) then
		background_tasks [name].func = func
		background_tasks [name].priority = priority
		background_tasks [name].args = {...}
		background_tasks [name].args_amt = select ("#", ...)
		background_tasks [name].object = self
		return
	else
		background_tasks [name] = {func = func, lastexec = time(), priority = priority, nextexec = time() + task_timers [priority] * 60, args = {...}, args_amt = select ("#", ...), object = self}
	end
end

function _detalhes:UnregisterBackgroundTask (name)
	background_tasks [name] = nil
end

function _detalhes:DoBackgroundTasks()
	if (_detalhes:GetZoneType() ~= "none" or _detalhes:InGroup()) then
		return
	end
	
	local t = time()
	
	for taskName, taskTable in pairs (background_tasks) do 
		if (t > taskTable.nextexec) then
			if (type (taskTable.func) == "string") then
				taskTable.object [taskTable.func] (taskTable.object, unpack (taskTable.args, 1, taskTable.args_amt))
			else
				taskTable.func (unpack (taskTable.args, 1, taskTable.args_amt))
			end

			taskTable.nextexec = random (30, 120) + t + (task_timers [taskTable.priority] * 60)
		end
	end
end

_detalhes.background_tasks_loop = _detalhes:ScheduleRepeatingTimer ("DoBackgroundTasks", 120)

local store_instances = {
	[1205] = true, --Blackrock Foundry
	[1228] = true, --Highmaul
	--[1136] = true, --SoO
}

function _detalhes:StoreEncounter (combat)

	combat = combat or _detalhes.tabela_vigente
	
	if (not combat) then
		return
	end

	local name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
	
	if (not store_instances [mapID]) then
		return
	end
	
	local boss_info = combat:GetBossInfo()
	local encounter_id = boss_info and boss_info.id
	
	if (not encounter_id) then
		return
	end
	
	local diff = combat:GetDifficulty()
	
	--> check for heroic mode
	if (diff == 5 or diff == 6 or diff == 15) then --test on raid finder  or diff == 7 or diff == 17
	
		local role = UnitGroupRolesAssigned ("player")
		if (role ~= "DAMAGER" and role ~= "HEALER") then
			return
		end
	
		--> check if the storage is already loaded
		if (not IsAddOnLoaded ("Details_DataStorage")) then
			local loaded, reason = LoadAddOn ("Details_DataStorage")
			if (not loaded) then
				return
			end
		end
		
		--> get the storage table
		local db = DetailsDataStorage
		
		if (not db and _detalhes.CreateStorageDB) then
			db = _detalhes:CreateStorageDB()
			if (not db) then
				return
			end
		elseif (not db) then
			return
		end
		
		local self_database = db.SELF_STORAGE
		
		if (not self_database) then
			--> outdate database?
			return
		end
		
		local heroic_branch = self_database ["HEROIC"]
		if (not heroic_branch) then
			heroic_branch = {}
			self_database ["HEROIC"] = heroic_branch
		end
		
		--> heroic database: numeric table with combats
		local encounter_database = heroic_branch [encounter_id]
		
		if (not encounter_database) then
			heroic_branch [encounter_id] = {}
			encounter_database = heroic_branch [encounter_id]
		end
		
		--> get player data
		local t = {
			total = 0,
			spells = {},
		}
		
		if (role == "DAMAGER") then
			
			local player = combat (1, _detalhes.playername)
			
			if (player) then
				t.total = player.total
				for spellid, spell in pairs (player.spells._ActorTable) do
					t.spells [spellid] = spell.total
				end
			end
			
		elseif (role == "HEALER") then
			local player = combat (2, _detalhes.playername)
			if (player) then
				t.total = player.total
				for spellid, spell in pairs (player.spells._ActorTable) do
					t.spells [spellid] = spell.total
				end
			end
		end

		if (t.total > 0) then
			local this_combat_data = {
				total = t.total,
				spells = t.spells,
				date = date ("%H:%M %d/%m/%y"),
				time = time(),
				elapsed = combat:GetCombatTime(),
			}
			tinsert (encounter_database, this_combat_data)
		end
		
	--> check for normal mode
	elseif (diff == 3 or diff == 4 or diff == 14) then
	
		local role = UnitGroupRolesAssigned ("player")
		if (role ~= "DAMAGER" and role ~= "HEALER") then
			return
		end
	
		--> check if the storage is already loaded
		if (not IsAddOnLoaded ("Details_DataStorage")) then
			local loaded, reason = LoadAddOn ("Details_DataStorage")
			if (not loaded) then
				return
			end
		end
		
		--> get the storage table
		local db = DetailsDataStorage
		
		if (not db and _detalhes.CreateStorageDB) then
			db = _detalhes:CreateStorageDB()
			if (not db) then
				return
			end
		elseif (not db) then
			return
		end

		local self_database = db.SELF_STORAGE
		
		if (not self_database) then
			--> outdate database?
			return
		end
		
		local normal_branch = self_database ["NORMAL"]
		if (not normal_branch) then
			normal_branch = {}
			self_database ["NORMAL"] = normal_branch
		end
		
		--> heroic database: numeric table with combats
		local encounter_database = normal_branch [encounter_id]
		
		if (not encounter_database) then
			normal_branch [encounter_id] = {}
			encounter_database = normal_branch [encounter_id]
		end
		
		--> get player data
		local t = {
			total = 0,
			spells = {},
			role = role,
		}
		
		if (role == "DAMAGER") then
			local player = combat (1, _detalhes.playername)
			if (player) then
				t.total = player.total
				for spellid, spell in pairs (player.spells._ActorTable) do
					t.spells [spellid] = spell.total
				end
			end
			
		elseif (role == "HEALER") then
			local player = combat (2, _detalhes.playername)
			if (player) then
				t.total = player.total
				for spellid, spell in pairs (player.spells._ActorTable) do
					t.spells [spellid] = spell.total
				end
			end
		end

		if (t.total > 0) then
			local this_combat_data = {
				total = t.total,
				spells = t.spells,
				date = date ("%H:%M %d/%m/%y"),
				time = time(),
				elapsed = combat:GetCombatTime(),
			}
			tinsert (encounter_database, this_combat_data)
		end
	
	--> check if is a mythic encounter and store the mythic encounter
	elseif (difficulty == 16) then
	
		--> check the guild name
		local match = 0
		local guildName = select (1, GetGuildInfo ("player"))
		local raid_size = GetNumGroupMembers() or 0
		
		if (guildName) then
			for i = 1, raid_size do
				local gName = select (1, GetGuildInfo ("raid" .. i)) or ""
				if (gName == guildName) then
					match = match + 1
				end
			end
			
			if (match < raid_size * 0.75) then
				return
			end
		else
			return
		end

		--> check if the storage is already loaded
		if (not IsAddOnLoaded ("Details_DataStorage")) then
			local loaded, reason = LoadAddOn ("Details_DataStorage")
			if (not loaded) then
				return
			end
		end

		--> get the storage table
		local db = DetailsDataStorage
		
		if (not db and _detalhes.CreateStorageDB) then
			db = _detalhes:CreateStorageDB()
			if (not db) then
				return
			end
		elseif (not db) then
			return
		end

		local raid_database = db.RAID_STORAGE
		
		if (not raid_database) then
			db.RAID_STORAGE = {}
			raid_database = db.RAID_STORAGE
		end
		
		--> encounter_database: numeric table with combats
		local encounter_database = raid_database [encounter_id]
		
		if (not encounter_database) then
			raid_database [encounter_id] = {}
			encounter_database = raid_database [encounter_id]
		end
		
		--> get raid members data
		local this_combat_data = {
			damage = {},
			heal = {},
			date = date ("%H:%M %d/%m/%y"),
			time = time(),
			elapsed = combat:GetCombatTime(),
			guild = guildName,
		}
		
		for i = 1, raid_size do
			local player_name, player_realm = UnitName ("raid" .. i)
			if (player_realm and player_realm ~= "") then
				player_name = player_name .. "-" .. player_realm
			end
			
			local damage_actor = combat (1, player_name)
			if (damage_actor) then
				this_combat_data.damage [player_name] = floor (damage_actor.total)
			end
			
			local heal_actor = combat (2, player_name)
			if (heal_actor) then
				this_combat_data.heal [player_name] = floor (heal_actor.total)
			end
		end
		
		tinsert (encounter_database, this_combat_data)
	end
end