local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local select = select
local floor = floor

local GetNumGroupMembers = GetNumGroupMembers

function _detalhes:UpdateGears()
	
	_detalhes:UpdateParser()
	_detalhes:UpdateControl()
	_detalhes:UpdateCombat()
	
end



------------------------------------------------------------------------------------------------------------

function _detalhes:SetDeathLogLimit (limit)

	if (limit and type (limit) == "number" and limit >= 8) then
		_detalhes.deadlog_events = limit
		
		local combat = _detalhes.tabela_vigente

		local wipe = table.wipe
		for player_name, event_table in pairs (combat.player_last_events) do
			if (limit > #event_table) then
				for i = #event_table + 1, limit do
					event_table [i] = {}
				end
			else
				event_table.n = 1
				for _, t in ipairs (event_table) do
					wipe (t)
				end
			end
		end
		
		_detalhes:UpdateParserGears()
	end
end

------------------------------------------------------------------------------------------------------------

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


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> background tasks


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


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> storage stuff

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
	
	--> check for heroic and mythic
	if (diff == 15 or diff == 16) then --test on raid finder  ' or diff == 17' -- normal mode: diff == 14 or 

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
		
		local diff_storage = db [diff]
		if (not diff_storage) then
			db [diff] = {}
			diff_storage = db [diff]
		end
		
		local encounter_database = diff_storage [encounter_id]
		if (not encounter_database) then
			diff_storage [encounter_id] = {}
			encounter_database = diff_storage [encounter_id]
		end
		
		local this_combat_data = {
			damage = {},
			healing = {},
			date = date ("%H:%M %d/%m/%y"),
			time = time(),
			elapsed = combat:GetCombatTime(),
			guild = guildName,
		}

		local damage_container_hash = combat [1]._NameIndexTable
		local damage_container_pool = combat [1]._ActorTable
		
		local healing_container_hash = combat [2]._NameIndexTable
		local healing_container_pool = combat [2]._ActorTable

		for i = 1, GetNumGroupMembers() do
		
			local role = UnitGroupRolesAssigned ("raid" .. i)
			
			if (role == "DAMAGER") then
				local player_name, player_realm = UnitName ("raid" .. i)
				if (player_realm and player_realm ~= "") then
					player_name = player_name .. "-" .. player_realm
				end
				
				local _, _, class = UnitClass (player_name)
				
				local damage_actor = damage_container_pool [damage_container_hash [player_name]]
				if (damage_actor) then
					local guid = UnitGUID (player_name) or UnitGUID (UnitName ("raid" .. i))
					this_combat_data.damage [player_name] = {floor (damage_actor.total), _detalhes.item_level_pool [guid] and _detalhes.item_level_pool [guid].ilvl or 0, class or 0}
				end
			elseif (role == "HEALER") then
				local player_name, player_realm = UnitName ("raid" .. i)
				if (player_realm and player_realm ~= "") then
					player_name = player_name .. "-" .. player_realm
				end
				
				local _, _, class = UnitClass (player_name)
				
				local heal_actor = healing_container_pool [healing_container_hash [player_name]]
				if (heal_actor) then
					local guid = UnitGUID (player_name) or UnitGUID (UnitName ("raid" .. i))
					this_combat_data.healing [player_name] = {floor (heal_actor.total), _detalhes.item_level_pool [guid] and _detalhes.item_level_pool [guid].ilvl or 0, class or 0}
				end
			end
			
		end
		
		tinsert (encounter_database, this_combat_data)

		print ("|cFFFFFF00Details! Storage|r: encounter saved!")
		
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> inspect stuff

_detalhes.ilevel = {}
local ilvl_core = _detalhes:CreateEventListener()

ilvl_core:RegisterEvent ("GROUP_ONENTER", "OnEnter")
ilvl_core:RegisterEvent ("GROUP_ONLEAVE", "OnLeave")
ilvl_core:RegisterEvent ("COMBAT_PLAYER_ENTER", "EnterCombat")
ilvl_core:RegisterEvent ("COMBAT_PLAYER_LEAVE", "LeaveCombat")
ilvl_core:RegisterEvent ("ZONE_TYPE_CHANGED", "ZoneChanged")

local inspecting = {}
local inspect_frame = CreateFrame ("frame")
inspect_frame:RegisterEvent ("INSPECT_READY")

local two_hand = {
	["INVTYPE_2HWEAPON"] = true,
 	["INVTYPE_RANGED"] = true,
	["INVTYPE_RANGEDRIGHT"] = true,
}

local MAX_INSPECT_AMOUNT = 1
local MIN_ILEVEL_TO_STORE = 580
local LOOP_TIME = 3

function _detalhes:IlvlFromNetwork (player, realm, core, ilvl)
	local guid = UnitGUID (player .. "-" .. realm)
	if (not guid) then
		guid = UnitGUID (player)
		if (not guid) then
			return
		end
	end
	
	_detalhes.item_level_pool [guid] = {name = player, ilvl = ilvl, time = time()}
end

--test on your self:
--/run _detalhes.ilevel:CalcItemLevel ("player", UnitGUID("player"), true)
--/run wipe (_detalhes.item_level_pool)
function ilvl_core:CalcItemLevel (unitid, guid, shout)
	
	if (type (unitid) == "table") then
		shout = unitid [3]
		guid = unitid [2]
		unitid = unitid [1]
	end

	if (CheckInteractDistance (unitid, 1)) then

		--16 = all itens including main and off hand
		local item_amount = 16
		local item_level = 0
		local failed = 0
		
		for equip_id = 1, 17 do
			if (equip_id ~= 4) then --shirt slot
				local item = GetInventoryItemLink (unitid, equip_id)
				if (item) then
					local _, _, _, iLevel, _, _, _, _, equipSlot = GetItemInfo (item)
					if (iLevel and iLevel > 100) then
						item_level = item_level + iLevel
						-- 16 = main hand 17 = off hand
						-- if using a two-hand, ignore the off hand slot
						if (equip_id == 16 and two_hand [equipSlot]) then
							item_amount = 15
							break
						end
					end
				else
					failed = failed + 1
					if (failed > 2) then
						break
					end
				end
			end
		end
		
		local average = item_level / item_amount

		-- register
		if (average > 0) then
			if (shout) then
				_detalhes:Msg (name .. " item level: " .. average)
			end
			
			if (average > MIN_ILEVEL_TO_STORE) then
				local name = _detalhes:GetCLName (unitid)
				_detalhes.item_level_pool [guid] = {name = name, ilvl = average, time = time()}
			end
		end
	end
end
_detalhes.ilevel.CalcItemLevel = ilvl_core.CalcItemLevel

inspect_frame:SetScript ("OnEvent", function (self, event, ...)
	local guid = select (1, ...)
	
	if (inspecting [guid]) then
		local unitid, cancel_tread = inspecting [guid] [1], inspecting [guid] [2]
		inspecting [guid] = nil
		ilvl_core.amt_inspecting = ilvl_core.amt_inspecting - 1
		
		ilvl_core:CancelTimer (cancel_tread)
		
		--> do inspect stuff
		if (unitid) then
			local t = {unitid, guid}
			--ilvl_core:ScheduleTimer ("CalcItemLevel", 0.5, t)
			ilvl_core:ScheduleTimer ("CalcItemLevel", 0.5, t)
			ilvl_core:ScheduleTimer ("CalcItemLevel", 2, t)
			ilvl_core:ScheduleTimer ("CalcItemLevel", 4, t)
			ilvl_core:ScheduleTimer ("CalcItemLevel", 8, t)
		end
	end
end)

function ilvl_core:InspectTimeOut (guid)
	inspecting [guid] = nil
	ilvl_core.amt_inspecting = ilvl_core.amt_inspecting - 1
end

function ilvl_core:GetItemLevel (unitid, guid)
	--> double check
	if (UnitAffectingCombat ("player") or InCombatLockdown()) then
		return
	end
	if (not unitid or not CanInspect (unitid) or not CheckInteractDistance (unitid, 1)) then
		return
	end

	inspecting [guid] = {unitid, ilvl_core:ScheduleTimer ("InspectTimeOut", 12, guid)}
	ilvl_core.amt_inspecting = ilvl_core.amt_inspecting + 1

	NotifyInspect (unitid)
end

local NotifyInspectHook = function (unitid)
	if (IsInRaid() and _detalhes:GetZoneType() == "raid") then
		local guid = UnitGUID (unitid)
		local name = _detalhes:GetCLName (unitid)
		
		if (guid and name and not inspecting [guid]) then
			for i = 1, GetNumGroupMembers() do
				if (name == _detalhes:GetCLName ("raid" .. i)) then
					unitid = "raid" .. i
					break
				end
			end
			
			inspecting [guid] = {unitid, ilvl_core:ScheduleTimer ("InspectTimeOut", 12, guid)}
			ilvl_core.amt_inspecting = ilvl_core.amt_inspecting + 1
		end
	end
end
hooksecurefunc ("NotifyInspect", NotifyInspectHook)

function ilvl_core:Reset()
	ilvl_core.raid_id = 1
	ilvl_core.amt_inspecting = 0
	
	for guid, t in pairs (inspecting) do
		ilvl_core:CancelTimer (t[2])
		inspecting [guid] = nil
	end
end

function ilvl_core:Loop()
	if (ilvl_core.amt_inspecting >= MAX_INSPECT_AMOUNT) then
		return
	end

	local members_amt = GetNumGroupMembers()
	if (ilvl_core.raid_id > members_amt) then
		ilvl_core.raid_id = 1
	end
	
	local unitid = "raid" .. ilvl_core.raid_id
	
	local guid = UnitGUID (unitid)
	if (not guid) then
		ilvl_core.raid_id = ilvl_core.raid_id + 1
		return
	end
	
	if (inspecting [guid]) then
		return
	end

	local ilvl_table = _detalhes.ilevel:GetIlvl (guid)
	if (ilvl_table and ilvl_table.time + 3600 > time()) then
		ilvl_core.raid_id = ilvl_core.raid_id + 1
		return
	end
	
	ilvl_core:GetItemLevel (unitid, guid)
	ilvl_core.raid_id = ilvl_core.raid_id + 1
end

function ilvl_core:EnterCombat()
	if (ilvl_core.loop_process) then
		ilvl_core:CancelTimer (ilvl_core.loop_process)
		ilvl_core.loop_process = nil
	end
end

local can_start_loop = function()
	if (_detalhes:GetZoneType() ~= "raid" or ilvl_core.loop_process or _detalhes.in_combat or not _detalhes.track_item_level) then
		return false
	end
	return true
end

function ilvl_core:LeaveCombat()
	if (can_start_loop()) then
		ilvl_core:Reset()
		ilvl_core.loop_process = ilvl_core:ScheduleRepeatingTimer ("Loop", LOOP_TIME)
	end
end

function ilvl_core:ZoneChanged (zone_type)
	if (can_start_loop()) then
		ilvl_core:Reset()
		ilvl_core.loop_process = ilvl_core:ScheduleRepeatingTimer ("Loop", LOOP_TIME)
	end
end

function ilvl_core:OnEnter()
	if (IsInRaid()) then
		_detalhes:SentMyItemLevel()
	end
	
	if (can_start_loop()) then
		ilvl_core:Reset()
		ilvl_core.loop_process = ilvl_core:ScheduleRepeatingTimer ("Loop", LOOP_TIME)
	end
end

function ilvl_core:OnLeave()
	if (ilvl_core.loop_process) then
		ilvl_core:CancelTimer (ilvl_core.loop_process)
		ilvl_core.loop_process = nil
	end
end

--> ilvl API
function _detalhes.ilevel:IsTrackerEnabled()
	return _detalhes.track_item_level
end
function _detalhes.ilevel:TrackItemLevel (bool)
	if (type (bool) == "boolean") then
		if (bool) then
			_detalhes.track_item_level = true
			if (can_start_loop()) then
				ilvl_core:Reset()
				ilvl_core.loop_process = ilvl_core:ScheduleRepeatingTimer ("Loop", LOOP_TIME)
			end
		else
			_detalhes.track_item_level = false
			if (ilvl_core.loop_process) then
				ilvl_core:CancelTimer (ilvl_core.loop_process)
				ilvl_core.loop_process = nil
			end
		end
	end
end

function _detalhes.ilevel:GetPool()
	return _detalhes.item_level_pool
end

function _detalhes.ilevel:GetIlvl (guid)
	return _detalhes.item_level_pool [guid]
end

function _detalhes.ilevel:GetInOrder()
	local order = {}
	
	for guid, t in pairs (_detalhes.item_level_pool) do
		order [#order+1] = {t.name, t.ilvl or 0, t.time}
	end
	
	table.sort (order, _detalhes.Sort2)
	
	return order
end