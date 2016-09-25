local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local select = select
local floor = floor

local GetNumGroupMembers = GetNumGroupMembers
local ItemUpgradeInfo = LibStub ("LibItemUpgradeInfo-1.0")
local LibGroupInSpecT = LibStub ("LibGroupInSpecT-1.1")

function _detalhes:UpdateGears()
	
	_detalhes:UpdateParser()
	_detalhes:UpdateControl()
	_detalhes:UpdateCombat()
	
end

------------------------------------------------------------------------------------------------------------
--> chat hooks

	_detalhes.chat_embed = _detalhes:CreateEventListener()
	_detalhes.chat_embed.startup = true
	
	_detalhes.chat_embed.hook_settabname = function (frame, name, doNotSave)
		if (not doNotSave) then
			if (_detalhes.chat_tab_embed.enabled and _detalhes.chat_tab_embed.tab_name ~= "") then
				if (_detalhes.chat_tab_embed_onframe == frame) then
					_detalhes.chat_tab_embed.tab_name = name
					_detalhes:DelayOptionsRefresh (_detalhes:GetInstance(1))
				end
			end
		end
	end
	_detalhes.chat_embed.hook_closetab = function (frame, fallback)
		if (_detalhes.chat_tab_embed.enabled and _detalhes.chat_tab_embed.tab_name ~= "") then
			if (_detalhes.chat_tab_embed_onframe == frame) then
				_detalhes.chat_tab_embed.enabled = false
				_detalhes.chat_tab_embed.tab_name = ""
				_detalhes.chat_tab_embed_onframe = nil
				_detalhes:DelayOptionsRefresh (_detalhes:GetInstance(1))
				_detalhes.chat_embed:ReleaseEmbed()
			end
		end
	end
	hooksecurefunc ("FCF_SetWindowName", _detalhes.chat_embed.hook_settabname)
	hooksecurefunc ("FCF_Close", _detalhes.chat_embed.hook_closetab)
	
	function _detalhes.chat_embed:SetTabSettings (tab_name, is_enabled, is_single)
	
		local current_enabled_state = _detalhes.chat_tab_embed.enabled
		local current_name = _detalhes.chat_tab_embed.tab_name
	
		tab_name = tab_name or _detalhes.chat_tab_embed.tab_name
		if (is_enabled == nil) then
			is_enabled = _detalhes.chat_tab_embed.enabled
		end
		if (is_single == nil) then
			is_single = _detalhes.chat_tab_embed.single_window
		end
		
		_detalhes.chat_tab_embed.tab_name = tab_name or ""
		_detalhes.chat_tab_embed.enabled = is_enabled
		_detalhes.chat_tab_embed.single_window = is_single
		
		if (current_name ~= tab_name) then
			--> rename the tab on chat frame
			local ChatFrame = _detalhes.chat_embed:GetTab (current_name)
			if (ChatFrame) then
				FCF_SetWindowName (ChatFrame, tab_name, false)
			end
		end
		
		if (is_enabled) then
			--> was disabled, so we need to save the current window positions.
			if (not current_enabled_state) then
				local window1 = _detalhes:GetInstance (1)
				if (window1) then
					window1:SaveMainWindowPosition()
					if (window1.libwindow) then
						local pos = window1:CreatePositionTable()
						_detalhes.chat_tab_embed.w1_pos = pos
					end
				end
				local window2 = _detalhes:GetInstance (2)
				if (window2) then
					window2:SaveMainWindowPosition()
					if (window2.libwindow) then
						local pos = window2:CreatePositionTable()
						_detalhes.chat_tab_embed.w2_pos = pos
					end
				end
			end
			
			--> need to make the embed
			_detalhes.chat_embed:DoEmbed()
		else
			--> need to release the frame
			if (current_enabled_state) then
				_detalhes.chat_embed:ReleaseEmbed()
			end
		end
	end
	
	function _detalhes.chat_embed:CheckChatEmbed (is_startup)
		if (_detalhes.chat_tab_embed.enabled) then
			_detalhes.chat_embed:DoEmbed (is_startup)
		end
	end
	
	--dom 
-- 	/run _detalhes.chat_embed:SetTabSettings ("Dano", true, false)
-- 	/run _detalhes.chat_embed:SetTabSettings (nil, false, false)
--	/dump _detalhes.chat_tab_embed.tab_name

	function _detalhes.chat_embed:DelayedChatEmbed (is_startup)
		_detalhes.chat_embed.startup = nil
		_detalhes.chat_embed:DoEmbed()
	end

	function _detalhes.chat_embed:DoEmbed (is_startup)
		if (_detalhes.chat_embed.startup and not is_startup) then
			if (_detalhes.AddOnStartTime + 5 < GetTime()) then
				_detalhes.chat_embed.startup = nil
			else
				return
			end
		end
		if (is_startup) then
			return _detalhes.chat_embed:ScheduleTimer ("DelayedChatEmbed", 5)
		end
		local tabname = _detalhes.chat_tab_embed.tab_name
		
		if (_detalhes.chat_tab_embed.enabled and tabname ~= "") then
			local ChatFrame, ChatFrameTab, ChatFrameBackground = _detalhes.chat_embed:GetTab (tabname)
			
			if (not ChatFrame) then
				FCF_OpenNewWindow (tabname)
				ChatFrame, ChatFrameTab, ChatFrameBackground = _detalhes.chat_embed:GetTab (tabname)
			end
			
			if (ChatFrame) then
				for index, t in pairs (ChatFrame.messageTypeList) do
					ChatFrame_RemoveMessageGroup (ChatFrame, t)
					ChatFrame.messageTypeList [index] = nil
				end
			
				_detalhes.chat_tab_embed_onframe = ChatFrame
			
				if (_detalhes.chat_tab_embed.single_window) then
					--> only one window
					local window1 = _detalhes:GetInstance (1)
					
					window1:UngroupInstance()
					window1.baseframe:ClearAllPoints()
					
					window1.baseframe:SetParent (ChatFrame)
					window1.rowframe:SetParent (window1.baseframe)
					window1.rowframe:ClearAllPoints()
					window1.rowframe:SetAllPoints()
					
					local y_up = window1.toolbar_side == 1 and -20 or 0
					local y_down = (window1.show_statusbar and 14 or 0) + (window1.toolbar_side == 2 and 20 or 0)
					
					window1.baseframe:SetPoint ("topleft", ChatFrameBackground, "topleft", 0, y_up)
					window1.baseframe:SetPoint ("bottomright", ChatFrameBackground, "bottomright", 0, y_down)
					
					window1:LockInstance (true)
					window1:SaveMainWindowPosition()
					
					local window2 = _detalhes:GetInstance (2)
					if (window2 and window2.baseframe) then
						if (window2.baseframe:GetParent() == ChatFrame) then
							--> need to detach
							_detalhes.chat_embed:ReleaseEmbed (true)
						end
					end

				else
					--> window #1 and #2
					local window1 = _detalhes:GetInstance (1)
					local window2 = _detalhes:GetInstance (2)
					if (not window2) then
						window2 = _detalhes:CriarInstancia()
					end
					
					window1:UngroupInstance()
					window2:UngroupInstance()
					window1.baseframe:ClearAllPoints()
					window2.baseframe:ClearAllPoints()
					
					window1.baseframe:SetParent (ChatFrame)
					window2.baseframe:SetParent (ChatFrame)
					window1.rowframe:SetParent (window1.baseframe)
					window2.rowframe:SetParent (window2.baseframe)

					window1:LockInstance (true)
					window2:LockInstance (true)
					
					local statusbar_enabled1 = window1.show_statusbar
					local statusbar_enabled2 = window2.show_statusbar

					table.wipe (window1.snap); table.wipe (window2.snap)
					window1.snap [3] = 2; window2.snap [1] = 1;
					window1.horizontalSnap = true; window2.horizontalSnap = true
					
					local y_up = window1.toolbar_side == 1 and -20 or 0
					local y_down = (window1.show_statusbar and 14 or 0) + (window1.toolbar_side == 2 and 20 or 0)
					
					local width = ChatFrameBackground:GetWidth() / 2
					local height = ChatFrameBackground:GetHeight() - y_down + y_up
					
					window1.baseframe:SetSize (width, height)
					window2.baseframe:SetSize (width, height)
					
					window1.baseframe:SetPoint ("topleft", ChatFrameBackground, "topleft", 0, y_up)
					window2.baseframe:SetPoint ("topright", ChatFrameBackground, "topright", 0, y_up)
				
					window1:SaveMainWindowPosition()
					window2:SaveMainWindowPosition()
					
				--	/dump ChatFrame3Background:GetSize()
--[[
					_detalhes.move_janela_func (window1.baseframe, true, window1)
					_detalhes.move_janela_func (window1.baseframe, false, window1)
					_detalhes.move_janela_func (window2.baseframe, true, window2)
					_detalhes.move_janela_func (window2.baseframe, false, window2)
--]]
				end
			end
		end
	end
	
	function _detalhes.chat_embed:ReleaseEmbed (second_window)
		--> release
		local window1 = _detalhes:GetInstance (1)
		local window2 = _detalhes:GetInstance (2)
		
		if (second_window) then
			window2.baseframe:ClearAllPoints()
			window2.baseframe:SetParent (UIParent)
			window2.rowframe:SetParent (UIParent)
			window2.baseframe:SetPoint ("center", UIParent, "center", 200, 0)
			window2.rowframe:SetPoint ("center", UIParent, "center", 200, 0)
			window2:LockInstance (false)
			window2:SaveMainWindowPosition()
			
			local previous_pos = _detalhes.chat_tab_embed.w2_pos
			if (previous_pos) then
				window2:RestorePositionFromPositionTable (previous_pos)
			end
			return
		end
		
		window1.baseframe:ClearAllPoints()
		window1.baseframe:SetParent (UIParent)
		window1.rowframe:SetParent (UIParent)
		window1.baseframe:SetPoint ("center", UIParent, "center")
		window1.rowframe:SetPoint ("center", UIParent, "center")
		window1:LockInstance (false)
		window1:SaveMainWindowPosition()
		
		local previous_pos = _detalhes.chat_tab_embed.w1_pos
		if (previous_pos) then
			window1:RestorePositionFromPositionTable (previous_pos)
		end
		
		if (not _detalhes.chat_tab_embed.single_window and window2) then
			window2.baseframe:ClearAllPoints()
			window2.baseframe:SetParent (UIParent)
			window2.rowframe:SetParent (UIParent)
			window2.baseframe:SetPoint ("center", UIParent, "center", 200, 0)
			window2.rowframe:SetPoint ("center", UIParent, "center", 200, 0)
			window2:LockInstance (false)
			window2:SaveMainWindowPosition()
			
			local previous_pos = _detalhes.chat_tab_embed.w2_pos
			if (previous_pos) then
				window2:RestorePositionFromPositionTable (previous_pos)
			end
		end
	end
	
	function _detalhes.chat_embed:GetTab (tabname)
		tabname = tabname or _detalhes.chat_tab_embed.tab_name
		for i = 1, 20 do
			local tabtext = _G ["ChatFrame" .. i .. "TabText"]
			if (tabtext) then
				if (tabtext:GetText() == tabname) then
					return _G ["ChatFrame" .. i], _G ["ChatFrame" .. i .. "Tab"], _G ["ChatFrame" .. i .. "Background"], i
				end
			end
		end
	end
	
--[[
	--create a tab on chat
	--FCF_OpenNewWindow(name)
	--rename it? perhaps need to hook
	--FCF_SetWindowName(chatFrame, name, true)    --FCF_SetWindowName(3, "DDD", true)
	--/run local chatFrame = _G["ChatFrame3"]; FCF_SetWindowName(chatFrame, "DDD", true)

	--FCF_SetWindowName(frame, name, doNotSave)
	--API SetChatWindowName(frame:GetID(), name); -- set when doNotSave is false

	-- need to store the chat frame reference
	-- hook set window name and check if the rename was on our window

	--FCF_Close
	-- ^ when the window is closed
--]]

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
--> storage stuff ~storage

--global database
_detalhes.storage = {}

function _detalhes.storage:OpenRaidStorage()
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

	return db
end

function _detalhes.storage:GetBestFromPlayer (diff, encounter_id, role, playername)
	local db = _detalhes.storage:OpenRaidStorage()
	
	local best
	local onencounter
	
	if (not role) then
		role = "damage"
	end
	role = string.lower (role)
	if (role == "damager") then
		role = "damage"
	elseif (role == "healer") then
		role = "healing"
	end
	
	local table = db [diff]
	if (table) then
		local encounters = table [encounter_id]
		if (encounters) then
			for index, encounter in ipairs (encounters) do
				local player = encounter [role] and encounter [role] [playername]
				if (player) then
					if (best) then
						if (player[1] > best[1]) then
							onencounter = encounter
							best = player
						end
					else
						onencounter = encounter
						best = player
					end
				end
			end
		end
	end
	
	return best, onencounter
end

function _detalhes.storage:ListDiffs()
	local db = _detalhes.storage:OpenRaidStorage()
	local t = {}
	for diff, _ in pairs (db) do
		tinsert (t, diff)
	end
	return t
end

function _detalhes.storage:ListEncounters (diff)
	local db = _detalhes.storage:OpenRaidStorage()
	
	local t = {}
	if (diff) then
		local table = db [diff]
		if (table) then
			for encounter_id, _ in pairs (table) do
				tinsert (t, {diff, encounter_id})
			end
		end
	else
		for diff, table in pairs (db) do
			for encounter_id, _ in pairs (table) do
				tinsert (t, {diff, encounter_id})
			end
		end
	end
	
	return t
end

function _detalhes.storage:GetPlayerData (diff, encounter_id, playername)
	local db = _detalhes.storage:OpenRaidStorage()

	local t = {}
	assert (type (playername) == "string", "PlayerName must be a string.")

	
	if (not diff) then
		for diff, table in pairs (db) do
			if (encounter_id) then
				local encounters = table [encounter_id]
				if (encounters) then
					for i = 1, #encounters do
						local encounter = encounters [i]
						local player = encounter.healing [playername] or encounter.damage [playername]
						if (player) then
							tinsert (t, player)
						end
					end
				end
			else
				for encounter_id, encounters in pairs (table) do
					for i = 1, #encounters do
						local encounter = encounters [i]
						local player = encounter.healing [playername] or encounter.damage [playername]
						if (player) then
							tinsert (t, player)
						end
					end
				end
			end
		end
	else
		local table = db [diff]
		if (table) then
			if (encounter_id) then
				local encounters = table [encounter_id]
				if (encounters) then
					for i = 1, #encounters do
						local encounter = encounters [i]
						local player = encounter.healing [playername] or encounter.damage [playername]
						if (player) then
							tinsert (t, player)
						end
					end
				end
			else
				for encounter_id, encounters in pairs (table) do
					for i = 1, #encounters do
						local encounter = encounters [i]
						local player = encounter.healing [playername] or encounter.damage [playername]
						if (player) then
							tinsert (t, player)
						end
					end
				end
			end
		end
	end
	
	return t
end

function _detalhes.storage:GetEncounterData (diff, encounter_id, guild)
	local db = _detalhes.storage:OpenRaidStorage()

	if (not diff) then
		return db
	end

	local data = db [diff]
	
	assert (data, "Difficulty not found. Use: 14, 15 or 16.")
	assert (type (encounter_id) == "number", "EncounterId must be a number.")
	
	data = data [encounter_id]
	
	local t = {}

	if (not data) then
		return t
	end
	
	for i = 1, #data do
		local encounter = data [i]
		
		if (guild) then
			if (encounter.guild == guild) then
				tinsert (t, encounter)
			end
		else
			tinsert (t, encounter)
		end
	end
	
	return t
end

local store_instances = {
	[1448] = true, --Hellfire Citadel
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
				print ("|cFFFFFF00Details! Storage|r: can't save the encounter, need at least 75% of players be from your guild.")
				return
			end
		else
			print ("|cFFFFFF00Details! Storage|r: can't save the encounter, need at least 75% of players be from your guild.")
			return
		end
		
		--> check if the storage is already loaded
		if (not IsAddOnLoaded ("Details_DataStorage")) then
			local loaded, reason = LoadAddOn ("Details_DataStorage")
			if (not loaded) then
				print ("|cFFFFFF00Details! Storage|r: can't save the encounter, couldn't load DataStorage, may be the addon is disabled.")
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
			
			if (role == "DAMAGER" or role == "TANK") then
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
		
		local myrole = UnitGroupRolesAssigned ("player")
		local mybest, onencounter = _detalhes.storage:GetBestFromPlayer (diff, encounter_id, myrole, _detalhes.playername)
		
		--print (myrole, mybest and mybest[1], mybest and mybest[2], mybest and mybest[3], onencounter and onencounter.date)
		
		if (mybest) then
			local d_one = 0
			if (myrole == "DAMAGER" or myrole == "TANK") then
				d_one = combat (1, _detalhes.playername) and combat (1, _detalhes.playername).total
			elseif (myrole == "HEALER") then
				d_one = combat (2, _detalhes.playername) and combat (2, _detalhes.playername).total
			end
			
			if (mybest[1] > d_one) then
				print (Loc ["STRING_DETAILS1"] .. format (Loc ["STRING_SCORE_NOTBEST"], _detalhes:comma_value (d_one), _detalhes:comma_value (mybest[1]), onencounter.date, mybest[2]))
			else
				print (Loc ["STRING_DETAILS1"] .. format (Loc ["STRING_SCORE_BEST"], _detalhes:comma_value (d_one)))
			end
		end
		
		local lower_instance = _detalhes:GetLowerInstanceNumber()
		if (lower_instance) then
			local instance = _detalhes:GetInstance (lower_instance)
			if (instance) then
				local my_role = UnitGroupRolesAssigned ("player")
				if (my_role == "TANK") then
					my_role = "DAMAGER"
				end
				local raid_name = GetInstanceInfo()
				local func = {_detalhes.OpenRaidHistoryWindow, _detalhes, raid_name, encounter_id, diff, my_role, guildName, 2, UnitName ("player")}
				local icon = {[[Interface\AddOns\Details\images\icons]], 16, 16, false, 434/512, 466/512, 243/512, 273/512}
				instance:InstanceAlert ("Boss Defeated, Open History! ", icon, 40, func, true)
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> inspect stuff

_detalhes.ilevel = {}
local ilvl_core = _detalhes:CreateEventListener()
ilvl_core.amt_inspecting = 0
_detalhes.ilevel.core = ilvl_core

ilvl_core:RegisterEvent ("GROUP_ONENTER", "OnEnter")
ilvl_core:RegisterEvent ("GROUP_ONLEAVE", "OnLeave")
ilvl_core:RegisterEvent ("COMBAT_PLAYER_ENTER", "EnterCombat")
ilvl_core:RegisterEvent ("COMBAT_PLAYER_LEAVE", "LeaveCombat")
ilvl_core:RegisterEvent ("ZONE_TYPE_CHANGED", "ZoneChanged")

local inspecting = {}
ilvl_core.forced_inspects = {}

function ilvl_core:HasQueuedInspec (unitName)
	local guid = UnitGUID (unitName)
	if (guid) then
		return ilvl_core.forced_inspects [guid]
	end
end

local inspect_frame = CreateFrame ("frame")
inspect_frame:RegisterEvent ("INSPECT_READY")

local two_hand = {
	["INVTYPE_2HWEAPON"] = true,
 	["INVTYPE_RANGED"] = true,
	["INVTYPE_RANGEDRIGHT"] = true,
}

local MAX_INSPECT_AMOUNT = 1
local MIN_ILEVEL_TO_STORE = 50
local LOOP_TIME = 7

--if the item is an artifact off-hand, get the item level of the main hand
local artifact_offhands = {
	["133959"] = true, --mage fire
	["128293"] = true, --dk frost
	["127830"] = true, --dh havoc
	["128831"] = true, --dh vengeance
	["128859"] = true, --druid feral
	["128822"] = true, --druid guardian
	["133948"] = true, --monk ww
	["133958"] = true, --priest shadow
	["128869"] = true, --rogue assassination
	["134552"] = true, --rogue outlaw
	["128479"] = true, --rogue subtlety
	["128936"] = true, --shaman elemental
	["128873"] = true, --shaman en
	["128934"] = true, --shaman resto
}

--if the artifact has its main piece as the offhand, when scaning the main hand get the ilevel of the off-hand.
local offhand_ismain = {
	["137246"] = true, --warlock demo / spine of thalkiel
	["128288"] = true, --warrior prot / scaleshard
	["128867"] = true, --paladin prot / oathseeker
}

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

--> test
--/run _detalhes.ilevel:CalcItemLevel ("player", UnitGUID("player"), true)
--/run wipe (_detalhes.item_level_pool)
function ilvl_core:CalcItemLevel (unitid, guid, shout)
	
	if (type (unitid) == "table") then
		shout = unitid [3]
		guid = unitid [2]
		unitid = unitid [1]
	end

	if (CheckInteractDistance (unitid, 1)) then

		--> 16 = all itens including main and off hand
		local item_amount = 16
		local item_level = 0
		local failed = 0
		
		for equip_id = 1, 17 do

			if (equip_id ~= 4) then --shirt slot
				local item = GetInventoryItemLink (unitid, equip_id)
				if (item) then
					local _, _, itemRarity, iLevel, _, _, _, _, equipSlot = GetItemInfo (item)
					if (iLevel) then
						
						--local _, _, _, _, _, _, _, _, _, _, _, upgradeTypeID, _, numBonusIDs, bonusID1, bonusID2 = strsplit (":", item)
						--> upgrades handle by LibItemUpgradeInfo-1.0
						--> http://www.wowace.com/addons/libitemupgradeinfo-1-0/

						if (equip_id == 16) then --main hand
							local itemId = select (2, strsplit (":", item))
							--print (itemId, offhand_ismain [itemId], UnitName (unitid))
							--128867 nil Lithedora EmeraldDream
							if (offhand_ismain [itemId]) then
								local offHand = GetInventoryItemLink (unitid, 17)
								if (offHand) then
									local iName, _, itemRarity, offHandILevel, _, _, _, _, equipSlot = GetItemInfo (offHand)
									if (offHandILevel) then
										item = offHand
										iLevel = offHandILevel
									end
								end
							end
							
						elseif (equip_id == 17) then --off-hand
							local itemId = select (2, strsplit (":", item))
							if (artifact_offhands [itemId]) then
								local mainHand = GetInventoryItemLink (unitid, 16)
								if (mainHand) then
									local iName, _, itemRarity, mainHandILevel, _, _, _, _, equipSlot = GetItemInfo (mainHand)
									if (iLevel) then
										item = mainHand
										iLevel = mainHandILevel
									end
								end
							end
						end
						
						if (ItemUpgradeInfo) then
							local ilvl = ItemUpgradeInfo:GetUpgradedItemLevel (item)
							item_level = item_level + (ilvl or iLevel)
						else
							item_level = item_level + iLevel
						end

						--> timewarped
						--[[
						if (upgradeTypeID == "512" and bonusID1 == "615") then
							item_level = item_level + 660
							if (bonusID2 == "656") then
								item_level = item_level + 15
							end
						else
							item_level = item_level + iLevel
						end
						--]]
						
						--> 16 = main hand 17 = off hand
						-->  if using a two-hand, ignore the off hand slot
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
		--print (UnitName (unitid), "ILVL:", average, unitid, "items:", item_amount)
		
		--> register
		if (average > 0) then
			if (shout) then
				_detalhes:Msg (name .. " item level: " .. average)
			end
			
			if (average > MIN_ILEVEL_TO_STORE) then
				local name = _detalhes:GetCLName (unitid)
				_detalhes.item_level_pool [guid] = {name = name, ilvl = average, time = time()}
			end
		end
		
		local spec = GetInspectSpecialization (unitid)
		if (spec and spec ~= 0) then
			_detalhes.cached_specs [guid] = spec
		end
		
--------------------------------------------------------------------------------------------------------
		
		local talents = {}
		for i = 1, 7 do
			for o = 1, 3 do
				local talentID, name, texture, selected, available = GetTalentInfo (i, o, 1, true, unitid)
				if (selected) then
					tinsert (talents, talentID)
					break
				end
			end
		end
		
		if (talents [1]) then
			_detalhes.cached_talents [guid] = talents
			--print (UnitName (unitid), "talents:", unpack (talents))
		end
		
--------------------------------------------------------------------------------------------------------

		if (ilvl_core.forced_inspects [guid]) then
			if (type (ilvl_core.forced_inspects [guid].callback) == "function") then
				local okey, errortext = pcall (ilvl_core.forced_inspects[guid].callback, guid, unitid, ilvl_core.forced_inspects[guid].param1, ilvl_core.forced_inspects[guid].param2)
				if (not okey) then
					_detalhes:Msg ("Error on QueryInspect callback: " .. errortext)
				end
			end
			ilvl_core.forced_inspects [guid] = nil
		end

--------------------------------------------------------------------------------------------------------
		
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

function ilvl_core:ReGetItemLevel (t)
	local unitid, guid, is_forced, try_number = unpack (t)
	return ilvl_core:GetItemLevel (unitid, guid, is_forced, try_number)
end

function ilvl_core:GetItemLevel (unitid, guid, is_forced, try_number)

	--> ddouble check
	if (not is_forced and (UnitAffectingCombat ("player") or InCombatLockdown())) then
		return
	end
	if (not unitid or not CanInspect (unitid) or not CheckInteractDistance (unitid, 1)) then
		if (is_forced) then
			try_number = try_number or 0
			if (try_number > 18) then
				return
			else
				try_number = try_number + 1
			end
			ilvl_core:ScheduleTimer ("ReGetItemLevel", 3, {unitid, guid, is_forced, try_number})
		end
		return
	end

	inspecting [guid] = {unitid, ilvl_core:ScheduleTimer ("InspectTimeOut", 12, guid)}
	ilvl_core.amt_inspecting = ilvl_core.amt_inspecting + 1

	NotifyInspect (unitid)
end

local NotifyInspectHook = function (unitid)
	local unit = unitid:gsub ("%d+", "")
	
	if ((IsInRaid() or IsInGroup()) and (_detalhes:GetZoneType() == "raid" or _detalhes:GetZoneType() == "party")) then
		local guid = UnitGUID (unitid)
		local name = _detalhes:GetCLName (unitid)
		if (guid and name and not inspecting [guid]) then
			for i = 1, GetNumGroupMembers() do
				if (name == _detalhes:GetCLName (unit .. i)) then
					unitid = unit .. i
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

function ilvl_core:QueryInspect (unitName, callback, param1)
	local unitid

	if (IsInRaid()) then
		for i = 1, GetNumGroupMembers() do
			if (GetUnitName ("raid" .. i, true) == unitName) then
				unitid = "raid" .. i
				break
			end
		end
	elseif (IsInGroup()) then
		for i = 1, GetNumGroupMembers()-1 do
			if (GetUnitName ("party" .. i, true) == unitName) then
				unitid = "party" .. i
				break
			end
		end
	else
		unitid = unitName
	end
	
	if (not unitid) then
		return false
	end
	
	local guid = UnitGUID (unitid)
	if (not guid) then
		return false
	elseif (ilvl_core.forced_inspects [guid]) then
		return true
	end
	
	if (inspecting [guid]) then
		return true
	end
	
	ilvl_core.forced_inspects [guid] = {callback = callback, param1 = param1}
	ilvl_core:GetItemLevel (unitid, guid, true)
	
	if (ilvl_core.clear_queued_list) then
		ilvl_core:CancelTimer (ilvl_core.clear_queued_list)
	end
	ilvl_core.clear_queued_list = ilvl_core:ScheduleTimer ("ClearQueryInspectQueue", 60)
	
	return true
end

function ilvl_core:ClearQueryInspectQueue()
	wipe (ilvl_core.forced_inspects)
	ilvl_core.clear_queued_list = nil
end

function ilvl_core:Loop()
	if (ilvl_core.amt_inspecting >= MAX_INSPECT_AMOUNT) then
		return
	end

	local members_amt = GetNumGroupMembers()
	if (ilvl_core.raid_id > members_amt) then
		ilvl_core.raid_id = 1
	end
	
	local unitid
	if (IsInRaid()) then
		unitid = "raid" .. ilvl_core.raid_id
	elseif (IsInGroup()) then
		unitid = "party" .. ilvl_core.raid_id
	else
		return
	end

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
	if ((_detalhes:GetZoneType() ~= "raid" and _detalhes:GetZoneType() ~= "party") or ilvl_core.loop_process or _detalhes.in_combat or not _detalhes.track_item_level) then
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

function _detalhes:GetTalents (guid)
	return _detalhes.cached_talents [guid]
end

function _detalhes:GetSpec (guid)
	return _detalhes.cached_specs [guid]
end

if (LibGroupInSpecT) then
	function _detalhes:LibGroupInSpecT_UpdateReceived (event, guid, unitid, info)
		--> update talents
		local talents = _detalhes.cached_talents [guid] or {}
		local i = 1
		for talentId, _ in pairs (info.talents) do 
			talents [i] = talentId
			i = i + 1
		end
		_detalhes.cached_talents [guid] = talents
		
		--> update spec
		if (info.global_spec_id and info.global_spec_id ~= 0) then
			if (not _detalhes.class_specs_coords [info.global_spec_id]) then
				print ("Details! Spec Id Invalid:", info.global_spec_id, info.name)
			else
				_detalhes.cached_specs [guid] = info.global_spec_id
			end
		end
		
		--print ("LibGroupInSpecT Received from", info.name, info.global_spec_id)
	end
	LibGroupInSpecT.RegisterCallback (_detalhes, "GroupInSpecT_Update", "LibGroupInSpecT_UpdateReceived")
end

