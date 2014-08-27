local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )


local GetNumGroupMembers = GetNumGroupMembers

function _detalhes:UpdateGears()
	
	_detalhes:UpdateParser()
	_detalhes:UpdateControl()
	_detalhes:UpdateCombat()
	
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
		--if (difficulty == 15) then
		--	return "Mythic"
		--end
		
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
