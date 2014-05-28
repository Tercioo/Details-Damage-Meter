--File Revision: 1
--Last Modification: 07/04/2014
-- Change Log:
	-- 07/04/2014: File Created.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> On Details! Load:
	--> load default keys into the main object

function _detalhes:ApplyBasicKeys()

	--> we are not in debug mode
		self.debug = false

	--> who is
		self.playername = UnitName ("player")
		self.playerserial = UnitGUID ("player")
		
	--> player faction and enemy faction
		self.faction = UnitFactionGroup ("player")
		if (self.faction == PLAYER_FACTION_GROUP[0]) then --> player is horde
			self.faction_against = PLAYER_FACTION_GROUP[1] --> ally
		elseif (self.faction == PLAYER_FACTION_GROUP[1]) then --> player is alliance
			self.faction_against = PLAYER_FACTION_GROUP[0] --> horde
		end
		
		self.zone_type = nil
		_detalhes.temp_table1 = {}
		
	--> combat
		self.encounter = {}
		self.in_combat = false
		self.combat_id = 0

	--> instances (windows)
		self.solo = self.solo or nil 
		self.raid = self.raid or nil 
		self.opened_windows = 0
		
		self.default_texture = [[Interface\AddOns\Details\images\bar4]]
		self.default_texture_name = "Details D'ictum"

		self.tooltip_max_targets = 3
		self.tooltip_max_abilities = 3
		self.tooltip_max_pets = 1

		self.class_coords_version = 1
		self.class_colors_version = 1
		
		self.school_colors = {
			[1] = {1.00, 1.00, 0.00},
			[2] = {1.00, 0.90, 0.50},
			[4] = {1.00, 0.50, 0.00},
			[8] = {0.30, 1.00, 0.30},
			[16] = {0.50, 1.00, 1.00},
			[32] = {0.50, 0.50, 1.00},
			[64] = {1.00, 0.50, 1.00},
			["unknown"] = {0.5, 0.75, 0.75, 1}
		}
		
	--> load default profile keys
		for key, value in pairs (_detalhes.default_profile) do 
			if (type (value) == "table") then
				local ctable = table_deepcopy (value)
				self [key] = ctable
			else
				self [key] = value
			end
		end
	
	--> end
		return true

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> On Details! Load:
	--> check if this is a first run, reset, or just load the saved data.

function _detalhes:LoadGlobalAndCharacterData()

	--> check and build the default container for character database
		if (not _detalhes_database) then
			_detalhes_database = table_deepcopy (_detalhes.default_player_data)
		end
		
		if (_detalhes_global and not _detalhes_global.profile_pool) then
			_detalhes_global.profile_pool = {}
		end
		
		for key, value in pairs (_detalhes.default_player_data) do 
		
			--> check if key exists
			if (_detalhes_database [key] == nil) then
				if (type (value) == "table") then
					_detalhes_database [key] = table_deepcopy (_detalhes.default_player_data [key])
				else
					_detalhes_database [key] = value
				end
			end
			
			--> copy the key from saved table to details object
			if (type (value) == "table") then
				_detalhes [key] = table_deepcopy (_detalhes_database [key])
			else
				_detalhes [key] = value
			end
			
		end
	
	--> check and build the default container for account database
		if (not _detalhes_global) then
			_detalhes_global = table_deepcopy (_detalhes.default_global_data)
		end
		
		for key, value in pairs (_detalhes.default_global_data) do 
		
			--> check if key exists
			if (_detalhes_global [key] == nil) then
				if (type (value) == "table") then
					_detalhes_global [key] = table_deepcopy (_detalhes.default_global_data [key])
				else
					_detalhes_global [key] = value
				end
			end
			
			--> copy the key from saved table to details object
			if (type (value) == "table") then
				_detalhes [key] = table_deepcopy (_detalhes_global [key])
			else
				_detalhes [key] = value
			end
			
		end
		
	--> end
		return true
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> On Details! Load:
	--> load previous saved combat data

function _detalhes:LoadCombatTables()

	--> if isn't nothing saved, build a new one
		if (not _detalhes_database.tabela_historico) then
			_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
			_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
			_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
		else

	--> build basic containers
		-- segments
		_detalhes.tabela_historico = _detalhes_database.tabela_historico or _detalhes.historico:NovoHistorico()
		-- overall
		_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
		-- pets
		_detalhes.tabela_pets = _detalhes.container_pets:NovoContainer()
		if (_detalhes_database.tabela_pets) then
			_detalhes.tabela_pets.pets = _detalhes_database.tabela_pets
		end
		
	--> if the core revision was incremented, reset all combat data
		if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < _detalhes.realversion) then
			--> details was been hard upgraded
			_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
			_detalhes.tabela_pets = _detalhes.container_pets:NovoContainer()
			_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
			_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
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
		
	--> need refresh for all containers
		for _, container in ipairs (_detalhes.tabela_overall) do 
			container.need_refresh = true
		end
		for _, container in ipairs (_detalhes.tabela_vigente) do 
			container.need_refresh = true
		end
	
	--> erase combat data from the database
		_detalhes_database.tabela_vigente = nil
		_detalhes_database.tabela_historico = nil
		_detalhes_database.tabela_pets = nil
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> On Details! Load:
	--> load the saved config on the addon

function _detalhes:LoadConfig()

	--> profile
	
		--> instances
		_detalhes.tabela_instancias = _detalhes_database.tabela_instancias or {}
		--> plugins data
		_detalhes.plugin_database = _detalhes_database.plugin_database or {}
		
		_detalhes:ReativarInstancias()
		
		--> fix for the 500
			if (_detalhes_database.active_profile == "") then
				--> é a primeira vez que este character usa profiles,  precisa copiar as keys existentes
				local current_profile_name = _detalhes:GetCurrentProfileName()
				_detalhes:GetProfile (current_profile_name, true)
				_detalhes:SaveProfileSpecial()
			end
	
		--> load profile and active instances
		local current_profile_name = _detalhes:GetCurrentProfileName()
		_detalhes:GetProfile (current_profile_name, true)
		
		_detalhes:ApplyProfile (current_profile_name, true)
	
	--> startup
	
		--> set the nicktag cache host
			_detalhes:NickTagSetCache (_detalhes_database.nick_tag_cache)
			
		--> count data
			_detalhes:CountDataOnLoad()
			
		
		--> solo e raid plugin
			if (_detalhes_database.SoloTablesSaved) then
				if (_detalhes_database.SoloTablesSaved.Mode) then
					_detalhes.SoloTables.Mode = _detalhes_database.SoloTablesSaved.Mode
					_detalhes.SoloTables.LastSelected = _detalhes_database.SoloTablesSaved.LastSelected
				else
					_detalhes.SoloTables.Mode = 1
				end
			end
			
			--if (_detalhes_database.RaidTablesSaved) then
			
				--for id, instance in ipairs (_detalhes.tabela_instancias) do
				--	if (instance.modo == _detalhes._detalhes_props["MODO_RAID"]) then
				--		_detalhes:AlteraModo (instance, _detalhes._detalhes_props["MODO_GROUP"])
				--	end
				--end
			
				--if (_detalhes_database.RaidTablesSaved.Mode) then
				--	_detalhes.RaidTables.Mode = _detalhes_database.RaidTablesSaved.Mode
				--	_detalhes.RaidTables.LastSelected = _detalhes_database.RaidTablesSaved.LastSelected
				--else
				--	_detalhes.RaidTables.Mode = 1
				--end
			--end
		
		--> switch tables
			_detalhes.switch.slots = _detalhes_database.switchSaved.slots
			_detalhes.switch.table = _detalhes_database.switchSaved.table
		
		--> last boss
			_detalhes.last_encounter = _detalhes_database.last_encounter
		
		--> buffs
			_detalhes.savedbuffs = _detalhes_database.savedbuffs
			_detalhes.Buffs:BuildTables()
		
		--> custom
			_detalhes.custom = _detalhes_global.custom
		
		--> initialize parser
			_detalhes.capture_current = {}
			for captureType, captureValue in pairs (_detalhes.capture_real) do 
				_detalhes.capture_current [captureType] = captureValue
			end

		--> initialize spell cache
			_detalhes:ClearSpellCache() 
			
		--> version first run
			if (not _detalhes_database.last_version or _detalhes_database.last_version ~= _detalhes.userversion) then
				_detalhes.is_version_first_run = true
			end
			
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> On Details! Load:
	--> count logons, tutorials, etc

function _detalhes:CountDataOnLoad()
	
	--> basic
		if (not _detalhes_global.got_first_run) then
			_detalhes.is_first_run = true
		end
		
	--> tutorial
		self.tutorial = self.tutorial or {}
		
		self.tutorial.logons = self.tutorial.logons or 0
		self.tutorial.logons = self.tutorial.logons + 1
		
		self.tutorial.unlock_button = self.tutorial.unlock_button or 0
		self.tutorial.version_announce = self.tutorial.version_announce or 0
		self.tutorial.main_help_button = self.tutorial.main_help_button or 0
		self.tutorial.alert_frames = self.tutorial.alert_frames or {false, false, false, false, false, false}
		
		self.tutorial.main_help_button = self.tutorial.main_help_button + 1
		
		self.character_data = self.character_data or {logons = 0}
		self.character_data.logons = self.character_data.logons + 1

end