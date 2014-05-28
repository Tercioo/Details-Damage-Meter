--[[this file save the data when player logout and load data and player login back again]]

local _detalhes = 		_G._detalhes

function _detalhes:SaveData()

	if (_G._detalhes_saver) then
		return
	end

	_detalhes:SaveDataOnLogout()
end

function _detalhes:SaveDataOnLogout()

if (true) then
	return
end

if (_detalhes.wipe_full_config) then
	_detalhes_global = nil
	_detalhes_database = nil
	return
end

--> cleanup tables
	_detalhes:PrepareTablesForSave()

--> get data

-- On Character
	
	--> nicktag cache
	_detalhes_database.nick_tag_cache = _detalhes.nick_tag_cache
	_detalhes_database.only_pvp_frags = _detalhes.only_pvp_frags
	
	--> minimap
	_detalhes_database.minimap = _detalhes.minimap
	
	--> plugin data
	_detalhes_database.plugin_database = _detalhes.plugin_database
	
	--> save instances (windows)
		_detalhes_database.tabela_instancias = _detalhes.tabela_instancias
		_detalhes_database.class_icons_small = _detalhes.class_icons_small
		_detalhes_database.class_coords = _detalhes.class_coords
		_detalhes_database.class_colors = _detalhes.class_colors
	--> character info
		_detalhes_database.character_data = _detalhes.character_data
	--> options data
		--window size
		_detalhes_database.max_window_size = _detalhes.max_window_size
		_detalhes_database.new_window_size = _detalhes.new_window_size
		_detalhes_database.window_clamp = _detalhes.window_clamp
		--> text sizes
		_detalhes_database.font_sizes = _detalhes.font_sizes
		_detalhes_database.ps_abbreviation = _detalhes.ps_abbreviation
		-- max segments
		_detalhes_database.segments_amount = _detalhes.segments_amount
		_detalhes_database.segments_amount_to_save = _detalhes.segments_amount_to_save
		_detalhes_database.instances_amount = _detalhes.instances_amount
		_detalhes_database.clear_ungrouped = _detalhes.clear_ungrouped
		_detalhes_database.clear_graphic = _detalhes.clear_graphic
		-- row animation
		_detalhes_database.use_row_animations = _detalhes.use_row_animations
		_detalhes_database.animate_scroll = _detalhes.animate_scroll
		_detalhes_database.use_scroll = _detalhes.use_scroll
		-- death log
		_detalhes_database.deadlog_limit = _detalhes.deadlog_limit
		-- report
		_detalhes_database.report_lines = _detalhes.report_lines
		_detalhes_database.report_to_who = _detalhes.report_to_who
		-- colors
		_detalhes_database.default_bg_color = _detalhes.default_bg_color
		_detalhes_database.default_bg_alpha = _detalhes.default_bg_alpha
		-- fades
		_detalhes_database.row_fade_in = _detalhes.row_fade_in
		_detalhes_database.windows_fade_in = _detalhes.windows_fade_in
		_detalhes_database.row_fade_out = _detalhes.row_fade_out
		_detalhes_database.windows_fade_out = _detalhes.windows_fade_out
		-- modes
		_detalhes_database.solo = _detalhes.solo
		_detalhes_database.tank = _detalhes.raid
		-- switch
		_detalhes_database.switch = {}
		_detalhes_database.switch.slots = _detalhes.switch.slots
		_detalhes_database.switch.table = _detalhes.switch.table
		-- capture
		_detalhes_database.capture_real = _detalhes.capture_real
		_detalhes_database.cloud_capture = _detalhes.cloud_capture
		_detalhes_database.minimum_combat_time = _detalhes.minimum_combat_time
	--> combat data
		-- segments table
		_detalhes_database.tabela_historico = _detalhes.tabela_historico
		-- combat id
		_detalhes_database.combat_id = _detalhes.combat_id
		-- modes
		_detalhes_database.SoloTables = {}
		_detalhes_database.RaidTables = {}
		--> precisa pegar o nome do plugin
		if (_detalhes.SoloTables.Mode) then
			_detalhes_database.SoloTables.Mode = _detalhes.SoloTables.Mode
			if (_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode]) then
				_detalhes_database.SoloTables.LastSelected = _detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].real_name
			end
		end
		if (_detalhes.RaidTables.Mode) then
			_detalhes_database.RaidTables.Mode = _detalhes.RaidTables.Mode
			if (_detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode]) then
				_detalhes_database.RaidTables.LastSelected = _detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode].real_name
			end
		end
	--> buff data
		_detalhes.Buffs:SaveBuffs()
		
	--> customs
		_detalhes_database.custom = _detalhes.custom
		
	--> version
		_detalhes_database.last_realversion = _detalhes.realversion --> core number
		_detalhes_database.last_version = _detalhes.userversion --> version

-- On Account

	_detalhes_global = _detalhes_global or {}

	--> profiles
	_detalhes_global.__profiiles = _detalhes.__profiiles

	--> skins
	_detalhes_global.savedStyles = _detalhes.savedStyles
	_detalhes_global.standard_skin = _detalhes.standard_skin
	_detalhes_global.got_first_run = true
	--max segments
	_detalhes_global.segments_amount = _detalhes.segments_amount
	_detalhes_global.segments_amount_to_save = _detalhes.segments_amount_to_save
	_detalhes_global.segments_panic_mode = _detalhes.segments_panic_mode
	-- animations
	_detalhes_global.use_row_animations = _detalhes.use_row_animations
	_detalhes_global.animate_scroll = _detalhes.animate_scroll
	-- scrollbar
	_detalhes_global.use_scroll = _detalhes.use_scroll
	-- core
	_detalhes_global.clear_ungrouped = _detalhes.clear_ungrouped
	_detalhes_global.update_speed = _detalhes.update_speed
	_detalhes_global.time_type = _detalhes.time_type
	_detalhes_global.memory_threshold = _detalhes.memory_threshold
	_detalhes_global.memory_ram = _detalhes.memory_ram
	_detalhes_global.remove_realm_from_name = _detalhes.remove_realm_from_name
	_detalhes_global.trash_concatenate = _detalhes.trash_concatenate
	_detalhes_global.trash_auto_remove = _detalhes.trash_auto_remove
	
	_detalhes_global.SpellOverwriteUser = _detalhes.SpellOverwriteUser
	
	--tutorial
	_detalhes_global.tutorial = _detalhes.tutorial
	
	--profiles
	_detalhes_global.__profiiles = _detalhes.__profiiles
	
	return true

end

local force_reset = function()
	print ("Check Point: Force reset.")
	_detalhes.tabela_instancias = {}
	_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
	_detalhes.tabela_pets = _detalhes.container_pets:NovoContainer()
	_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
	_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
	_detalhes_database = {}
	return
end

function _detalhes:LoadData()

--[[
	if (true) then --> DEBUG, force empty data
	return force_reset()
end --]]

	local _detalhes_database = _G._detalhes_database
	
	if (_detalhes_database) then
	
	----------------------------------------------------------------------------------------
	--> fora dos profiles
	----------------------------------------------------------------------------------------
	
		--> nicktag cache
			_detalhes.nick_tag_cache = _detalhes_database.nick_tag_cache or {}
			_detalhes:NickTagSetCache (_detalhes.nick_tag_cache)
			
		--> plugin data
			_detalhes.plugin_database = _detalhes_database.plugin_database

		--> character info
			_detalhes.character_data = _detalhes_database.character_data

		--> build basic containers
			_detalhes.tabela_historico = _detalhes_database.tabela_historico or _detalhes.historico:NovoHistorico() -- segments
			_detalhes.tabela_overall = _detalhes.combate:NovaTabela() -- overall
			_detalhes.tabela_pets = _detalhes_database.tabela_pets or _detalhes.container_pets:NovoContainer() -- pets
			
		--> version
			_detalhes.last_realversion = _detalhes_database.last_realversion or _detalhes.realversion --> core
			_detalhes.last_version = _detalhes_database.last_version or "v1.0.0" --> version
			
			if (_detalhes.last_realversion < _detalhes.realversion) then
				--> details was been hard upgraded
				_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
				_detalhes.tabela_pets = _detalhes.container_pets:NovoContainer()
				_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
				_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
			end
			
			if (_detalhes.last_version ~= _detalhes.userversion) then
				_detalhes.is_version_first_run = true
			end
		
		--> re-build all indexes and metatables
			_detalhes:RestauraMetaTables()

		--> get last combat table
			local historico_UM = _detalhes.tabela_historico.tabelas[1]
			
			if (historico_UM) then
				_detalhes.tabela_vigente = historico_UM --> significa que elas eram a mesma tabela, então aqui elas se tornam a mesma tabela
			else
				_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
			end
			
			_detalhes.combat_id = _detalhes_database.combat_id
			
	----------------------------------------------------------------------------------------
	--> estão nos profiles
	----------------------------------------------------------------------------------------
	
		--> minimap
			_detalhes.minimap = _detalhes_database.minimap
		--> PvP
			_detalhes.only_pvp_frags = _detalhes_database.only_pvp_frags

		--> instances (windows)

			_detalhes.tabela_instancias = _detalhes_database.tabela_instancias or {}
			_detalhes.class_icons_small = _detalhes_database.class_icons_small
			_detalhes.class_coords = _detalhes_database.class_coords
			_detalhes.class_colors = _detalhes_database.class_colors

			if (_detalhes_database.SoloTables) then
				if (_detalhes_database.SoloTables.Mode) then
					_detalhes.SoloTables.Mode = _detalhes_database.SoloTables.Mode
					_detalhes.SoloTables.LastSelected = _detalhes_database.SoloTables.LastSelected
				else
					_detalhes.SoloTables.Mode = 1
				end
			end
			
			if (_detalhes_database.RaidTables) then
				if (_detalhes_database.RaidTables.Mode) then
					_detalhes.RaidTables.Mode = _detalhes_database.RaidTables.Mode
					_detalhes.RaidTables.LastSelected = _detalhes_database.RaidTables.LastSelected
				else
					_detalhes.RaidTables.Mode = 1
				end
			end
			
		--> load options data
			--window size
			_detalhes.max_window_size = _detalhes_database.max_window_size
			_detalhes.new_window_size = _detalhes_database.new_window_size
			_detalhes.window_clamp = _detalhes_database.window_clamp
			-- max segments
			_detalhes.segments_amount = _detalhes_database.segments_amount
			_detalhes.instances_amount = _detalhes_database.instances_amount
			_detalhes.clear_ungrouped = _detalhes_database.clear_ungrouped
			_detalhes.clear_graphic = _detalhes_database.clear_graphic
			--> text sizes
			_detalhes.font_sizes = _detalhes_database.font_sizes
			_detalhes.ps_abbreviation = _detalhes_database.ps_abbreviation
			-- row animation
			_detalhes.use_row_animations = _detalhes_database.use_row_animations
			_detalhes.animate_scroll = _detalhes_database.animate_scroll
			_detalhes.use_scroll = _detalhes_database.use_scroll
			-- death log
			_detalhes.deadlog_limit = _detalhes_database.deadlog_limit
			-- report
			_detalhes.report_lines = _detalhes_database.report_lines
			_detalhes.report_to_who = _detalhes_database.report_to_who
			-- colors
			_detalhes.default_bg_color = _detalhes_database.default_bg_color
			_detalhes.default_bg_alpha = _detalhes_database.default_bg_alpha
			-- fades
			_detalhes.row_fade_in = _detalhes_database.row_fade_in
			_detalhes.windows_fade_in = _detalhes_database.windows_fade_in
			_detalhes.row_fade_out = _detalhes_database.row_fade_out
			_detalhes.windows_fade_out = _detalhes_database.windows_fade_out
			-- modes
			_detalhes.solo = _detalhes_database.solo
			_detalhes.raid = _detalhes_database.tank
			-- switch
			if (_detalhes_database.switch) then 
				_detalhes.switch.slots = _detalhes_database.switch.slots
				_detalhes.switch.table = _detalhes_database.switch.table
			end

		--> buffs
			_detalhes.savedbuffs = _detalhes_database.savedbuffs
			_detalhes.Buffs:BuildTables()
			
		--> customs
			_detalhes.custom = _detalhes_database.custom

		--> need refresh for all containers
			for _, container in ipairs (_detalhes.tabela_overall) do 
				container.need_refresh = true
			end
			for _, container in ipairs (_detalhes.tabela_vigente) do 
				container.need_refresh = true
			end
			
			_detalhes_database.tabela_vigente = nil
			_detalhes_database.tabela_historico = nil
			_detalhes_database.tabela_pets = nil

	else
		_detalhes.tabela_instancias = {}
		_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
		_detalhes.tabela_pets = _detalhes.container_pets:NovoContainer()
		_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
		_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
		_detalhes_database = {}
	end
	
	-- capture
	_detalhes.capture_real = _detalhes_database and _detalhes_database.capture_real or {
		["damage"] = true,
		["heal"] = true,
		["energy"] = false,
		["miscdata"] = true,
		["aura"] = true,
		["spellcast"] = true,
	}

	if (_detalhes.capture_real.spellcast == nil) then
		_detalhes.capture_real.spellcast = true
	end
	
	_detalhes.capture_current = {}
	for captureType, captureValue in pairs (_detalhes.capture_real) do 
		_detalhes.capture_current [captureType] = captureValue
	end
	
	_detalhes.cloud_capture = _detalhes_database.cloud_capture
	_detalhes.minimum_combat_time = _detalhes_database.minimum_combat_time
	
-- On Account

	local _detalhes_global = _G._detalhes_global

	if (_detalhes_global) then
		--saved styles
		--vardump (_detalhes_global.savedStyles)
		
		_detalhes.__profiiles = _detalhes_global.__profiiles
		
		_detalhes.savedStyles = _detalhes_global.savedStyles or _detalhes.savedStyles
		_detalhes.standard_skin = _detalhes_global.standard_skin
		
		if (not _detalhes_global.got_first_run) then
			_detalhes.is_first_run = true
		end
		--max segments
		_detalhes.segments_amount = _detalhes_global.segments_amount or _detalhes.segments_amount
		_detalhes.segments_amount_to_save = _detalhes_global.segments_amount_to_save or _detalhes.segments_amount_to_save
		_detalhes.segments_panic_mode = _detalhes_global.segments_panic_mode or _detalhes.segments_panic_mode
		-- row animation
		_detalhes.use_row_animations = _detalhes_global.use_row_animations or _detalhes.use_row_animations
		_detalhes.animate_scroll = _detalhes_global.animate_scroll or _detalhes.animate_scroll
		-- scrollbar
		_detalhes.use_scroll = _detalhes_global.use_scroll or _detalhes.use_scroll
		-- core
		_detalhes.clear_ungrouped = _detalhes_global.clear_ungrouped or _detalhes.clear_ungrouped
		_detalhes.update_speed = _detalhes_global.update_speed or _detalhes.update_speed
		_detalhes.time_type = _detalhes_global.time_type or _detalhes.time_type
		_detalhes.memory_threshold = _detalhes_global.memory_threshold
		_detalhes.memory_ram = _detalhes_global.memory_ram
		_detalhes.remove_realm_from_name = _detalhes_global.remove_realm_from_name
		_detalhes.trash_concatenate = _detalhes_global.trash_concatenate
		_detalhes.trash_auto_remove = _detalhes_global.trash_auto_remove
	
		_detalhes.SpellOverwriteUser = _detalhes_global.SpellOverwriteUser or _detalhes.SpellOverwriteUser
		
		--tutorial
		_detalhes.tutorial = _detalhes_global.tutorial
		
		--profiles
		_detalhes.__profiiles = _detalhes_global.__profiiles
		
	else
		_detalhes.is_first_run = true
	end
	
	return true
end


function _detalhes:WipeConfig()
	
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	
	local b = CreateFrame ("button", "DetailsResetConfigButton", UIParent, "OptionsButtonTemplate")
	tinsert (UISpecialFrames, "DetailsResetConfigButton")
	
	b:SetSize (250, 40)
	b:SetText (Loc ["STRING_SLASH_WIPECONFIG_CONFIRM"])
	b:SetScript ("OnClick", function() _detalhes.wipe_full_config = true; ReloadUI(); end)
	b:SetPoint ("center", UIParent, "center", 0, 0)
	
end

local is_exception = {
	["nick_tag_cache"] = true
}

function _detalhes:SaveConfig()

	--> nicktag cache
		--_detalhes.copy_nick_tag = table_deepcopy (_detalhes_database.nick_tag_cache)

	--> cleanup
		_detalhes:PrepareTablesForSave()
		_detalhes_database.tabela_instancias = _detalhes.tabela_instancias
		_detalhes_database.tabela_historico = _detalhes.tabela_historico
		
		local name, ttype, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
		if (ttype == "party" or ttype == "raid") then
			--> salvar container de pet
			_detalhes_database.tabela_pets = _detalhes.tabela_pets.pets
		end
		
		_detalhes:TimeDataCleanUpTemporary()
		
	--> buffs
		_detalhes.Buffs:SaveBuffs()
	
	--> salva o container do personagem
		for key, value in pairs (_detalhes.default_player_data) do
			if (not is_exception [key]) then
				_detalhes_database [key] = _detalhes [key]
			end
		end
	
	--> salva o container das globais
		for key, value in pairs (_detalhes.default_global_data) do
			if (key ~= "__profiles") then
				_detalhes_global [key] = _detalhes [key]
			end
		end

	--> solo e raid mode
		if (_detalhes.SoloTables.Mode) then
			_detalhes_database.SoloTablesSaved = {}
			_detalhes_database.SoloTablesSaved.Mode = _detalhes.SoloTables.Mode
			if (_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode]) then
				_detalhes_database.SoloTablesSaved.LastSelected = _detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].real_name
			end
		end
		
		--if (_detalhes.RaidTables.Mode) then
		--	_detalhes_database.RaidTablesSaved = {}
		--	_detalhes_database.RaidTablesSaved.Mode = _detalhes.RaidTables.Mode
		--	if (_detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode]) then
		--		_detalhes_database.RaidTablesSaved.LastSelected = _detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode].real_name
		--	end
		--end
		_detalhes_database.RaidTablesSaved = nil
		
	--> salva switch tables
		_detalhes_database.switchSaved.slots = _detalhes.switch.slots
		_detalhes_database.switchSaved.table = _detalhes.switch.table
	
	--> last boss
		_detalhes_database.last_encounter = _detalhes.last_encounter
	
	--> last versions
		_detalhes_database.last_realversion = _detalhes.realversion --> core number
		_detalhes_database.last_version = _detalhes.userversion --> version
		_detalhes_global.got_first_run = true
	
end
