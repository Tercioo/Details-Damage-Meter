--File Revision: 1
--Last Modification: 07/04/2014
-- Change Log:
	-- 07/04/2014: File Created.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Profiles:
	--> return the current profile name
	
function _detalhes:GetCurrentProfileName()

	--> check is have a profile name
		if (_detalhes_database.active_profile == "") then
			local character_key = UnitName ("player") .. "-" .. GetRealmName()
			_detalhes_database.active_profile = character_key
		end
	
	--> end
		return _detalhes_database.active_profile
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Profiles:
	--> create a new profile

function _detalhes:CreateProfile (name)

	if (not name or type (name) ~= "string" or name == "") then
		return false
	end

	--> check if already exists
		if (_detalhes_global.__profiles [name]) then
			return false
		end
		
	--> copy the default table
		local new_profile = table_deepcopy (_detalhes.default_profile)
		new_profile.instances = {}
	
	--> add to global container
		_detalhes_global.__profiles [name] = new_profile
		
	--> end
		return new_profile
	
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Profiles:
	--> return the list os all profiles
	
function _detalhes:GetProfileList()
	
	--> build the table
		local t = {}
		for name, profile in pairs (_detalhes_global.__profiles) do 
			t [#t + 1] = name
		end
	
	--> end
		return t
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Profiles:
	--> delete a profile
	
function _detalhes:EraseProfile (profile_name)
	
	--> erase profile table
		_detalhes_global.__profiles [profile_name] = nil
	
		if (_detalhes_database.active_profile == profile_name) then
		
			local character_key = UnitName ("player") .. "-" .. GetRealmName()
			
			local my_profile = _detalhes:GetProfile (character_key)
			
			if (my_profile) then
				_detalhes:ApplyProfile (character_key, true)
			else
				local profile = _detalhes:CreateProfile (character_key)
				_detalhes:ApplyProfile (character_key, true)
			end
		
		end

	--> end
		return true
end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Profiles:
	--> return the profile table requested
	
function _detalhes:GetProfile (name, create)

	--> get the profile, create and return
		local profile = _detalhes_global.__profiles [name]
		
		if (not profile and not create) then
			return false

		elseif (not profile and create) then
			profile = _detalhes:CreateProfile (name)

		end
	
	--> end
		return profile
end	

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Profiles:
	--> reset the profile
function _detalhes:ResetProfile (profile_name)

	--> get the profile
		local profile = _detalhes:GetProfile (profile_name, true)
		
		if (not profile) then
			return false
		end
	
	--> reset
	
		local instances = profile.instances
		for index, instance in ipairs (instances) do 
			for key, value in pairs (_detalhes.instance_defaults) do
				if (type (value) == "table") then
					instance [key] = table_deepcopy (value)
				else
					instance [key] = value
				end
			end
		end
		
		local profile = table_deepcopy (_detalhes.default_profile)
		profile.instances = instances
		
		_detalhes:ApplyProfile (profile_name, true)
	
	--> end
		return true
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Profiles:
	--> return the profile table requested
	
function _detalhes:ApplyProfile (profile_name, nosave, is_copy)

	--> get the profile
		local profile = _detalhes:GetProfile (profile_name, true)

	--> if the profile doesn't exist, just quit
		if (not profile) then
			_detalhes:Msg ("Profile Not Found.")
			return false
		end
		
	--> always save the previous profile, except if nosave flag is up
		if (not nosave) then
			--> salva o profile ativo no momento
			_detalhes:SaveProfile()
		end

	--> update profile keys before go
		for key, value in pairs (_detalhes.default_profile) do 
			if (profile [key] == nil) then
				if (type (value) == "table") then
					profile [key] = table_deepcopy (_detalhes.default_profile [key])
				else
					profile [key] = value
				end
				
			elseif (type (value) == "table") then
				for key2, value2 in pairs (value) do 
					if (profile [key] [key2] == nil) then
						if (type (value2) == "table") then
							profile [key] [key2] = table_deepcopy (_detalhes.default_profile [key] [key2])
						else
							profile [key] [key2] = value2
						end
					end
				end
				
			end
		end
		
	--> apply the profile values
		for key, _ in pairs (_detalhes.default_profile) do 
			local value = profile [key]

			if (type (value) == "table") then
				local ctable = table_deepcopy (value)
				_detalhes [key] = ctable
			else
				_detalhes [key] = value
			end

		end
		
	--> apply the skin
		
		local saved_skins = profile.instances
		
	--> we need to create instances if the profile have more saved skins then the current amount of instances
		if (#_detalhes.tabela_instancias < #saved_skins) then
			for i = #_detalhes.tabela_instancias+1, #saved_skins do
			
				--> esse inicio precisa ser em silêncio
				
				local new_instance = _detalhes:CreateInstance (true)
				if (not new_instance) then
					break
				end
				
				new_instance:ShutDown()
			end
		end
		
		for index, instance in ipairs (_detalhes.tabela_instancias) do
			
			local this_skin = saved_skins [index]
			
			if (this_skin) then
				if (not instance.iniciada and not _detalhes.initializing) then
					instance:RestauraJanela()
					instance:ApplySavedSkin (this_skin)
					instance:DesativarInstancia()
				elseif (instance.iniciada) then
					instance:ApplySavedSkin (this_skin)
				end
			end
		end
		
	--> end
		
		if (not is_copy) then
			_detalhes.active_profile = profile_name
			_detalhes_database.active_profile = profile_name
			--_detalhes:SaveProfile()
		end
		
		return true	
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Profiles:
	--> return the profile table requested
	
function _detalhes:SaveProfile (saveas)
	
	--> get the current profile
	
		local profile_name
	
		if (saveas) then
			profile_name = saveas
		else
			profile_name = _detalhes:GetCurrentProfileName()
		end
		
		local profile = _detalhes:GetProfile (profile_name, true)

	--> save default keys

		for key, _ in pairs (_detalhes.default_profile) do 
		
			local current_value = _detalhes [key]

			if (type (current_value) == "table") then
				local ctable = table_deepcopy (current_value)
				profile [key] = ctable
			else
				profile [key] = current_value
			end

		end

	--> save skins
		table.wipe (profile.instances)

		for index, instance in ipairs (_detalhes.tabela_instancias) do
			local exported = instance:ExportSkin()
			profile.instances [index] = exported
		end

	--> end
		return profile
end

local default_profile = {

	--> class icons and colors
		class_icons_small = [[Interface\AddOns\Details\images\classes_small]],
		class_coords = {
			["HUNTER"] = {
				0, -- [1]
				0.25, -- [2]
				0.25, -- [3]
				0.5, -- [4]
			},
			["WARRIOR"] = {
				0, -- [1]
				0.25, -- [2]
				0, -- [3]
				0.25, -- [4]
			},
			["ROGUE"] = {
				0.49609375, -- [1]
				0.7421875, -- [2]
				0, -- [3]
				0.25, -- [4]
			},
			["MAGE"] = {
				0.25, -- [1]
				0.49609375, -- [2]
				0, -- [3]
				0.25, -- [4]
			},
			["PET"] = {
				0.25, -- [1]
				0.49609375, -- [2]
				0.75, -- [3]
				1, -- [4]
			},
			["DRUID"] = {
				0.7421875, -- [1]
				0.98828125, -- [2]
				0, -- [3]
				0.25, -- [4]
			},
			["MONK"] = {
				0.5, -- [1]
				0.73828125, -- [2]
				0.5, -- [3]
				0.75, -- [4]
			},
			["DEATHKNIGHT"] = {
				0.25, -- [1]
				0.5, -- [2]
				0.5, -- [3]
				0.75, -- [4]
			},
			["UNKNOW"] = {
				0.5, -- [1]
				0.75, -- [2]
				0.75, -- [3]
				1, -- [4]
			},
			["PRIEST"] = {
				0.49609375, -- [1]
				0.7421875, -- [2]
				0.25, -- [3]
				0.5, -- [4]
			},
			["UNGROUPPLAYER"] = {
				0.5, -- [1]
				0.75, -- [2]
				0.75, -- [3]
				1, -- [4]
			},
			["Alliance"] = {
				0.49609375, -- [1]
				0.7421875, -- [2]
				0.75, -- [3]
				1, -- [4]
			},
			["WARLOCK"] = {
				0.7421875, -- [1]
				0.98828125, -- [2]
				0.25, -- [3]
				0.5, -- [4]
			},
			["ENEMY"] = {
				0, -- [1]
				0.25, -- [2]
				0.75, -- [3]
				1, -- [4]
			},
			["Horde"] = {
				0.7421875, -- [1]
				0.98828125, -- [2]
				0.75, -- [3]
				1, -- [4]
			},
			["PALADIN"] = {
				0, -- [1]
				0.25, -- [2]
				0.5, -- [3]
				0.75, -- [4]
			},
			["MONSTER"] = {
				0, -- [1]
				0.25, -- [2]
				0.75, -- [3]
				1, -- [4]
			},
			["SHAMAN"] = {
				0.25, -- [1]
				0.49609375, -- [2]
				0.25, -- [3]
				0.5, -- [4]
			},
			},
		
		class_colors = {
			["HUNTER"] = {
				0.67, -- [1]
				0.83, -- [2]
				0.45, -- [3]
			},
			["WARRIOR"] = {
				0.78, -- [1]
				0.61, -- [2]
				0.43, -- [3]
			},
			["PALADIN"] = {
				0.96, -- [1]
				0.55, -- [2]
				0.73, -- [3]
			},
			["SHAMAN"] = {
				0, -- [1]
				0.44, -- [2]
				0.87, -- [3]
			},
			["MAGE"] = {
				0.41, -- [1]
				0.8, -- [2]
				0.94, -- [3]
			},
			["ROGUE"] = {
				1, -- [1]
				0.96, -- [2]
				0.41, -- [3]
			},
			["UNKNOW"] = {
				0.2, -- [1]
				0.2, -- [2]
				0.2, -- [3]
			},
			["PRIEST"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
			},
			["WARLOCK"] = {
				0.58, -- [1]
				0.51, -- [2]
				0.79, -- [3]
			},
			["UNGROUPPLAYER"] = {
				0.4, -- [1]
				0.4, -- [2]
				0.4, -- [3]
			},
			["ENEMY"] = {
				0.94117, -- [1]
				0, -- [2]
				0.0196, -- [3]
				1, -- [4]
			},
			["version"] = 1,
			["PET"] = {
				0.3, -- [1]
				0.4, -- [2]
				0.5, -- [3]
			},
			["DRUID"] = {
				1, -- [1]
				0.49, -- [2]
				0.04, -- [3]
			},
			["MONK"] = {
				0, -- [1]
				1, -- [2]
				0.59, -- [3]
			},
			["DEATHKNIGHT"] = {
				0.77, -- [1]
				0.12, -- [2]
				0.23, -- [3]
			},
			["ARENA_ALLY"] = {
				0.2, -- [1]
				1, -- [2]
				0.2, -- [3]
			},
			["ARENA_ENEMY"] = {
				1, -- [1]
				1, -- [2]
				0, -- [3]
			},
			["NEUTRAL"] = {
				1, -- [1]
				1, -- [2]
				0, -- [3]
			},
			},

	--> minimap
		minimap = {hide = false, radius = 160, minimapPos = 220, onclick_what_todo = 1, text_type = 1, HotCornerIgnore = true},
	--> horcorner
		hotcorner_topleft = {hide = false, onclick_what_todo = 1, topleft_quickclick = true, quickclick_what_todo = 2},
		
	--> PvP
		only_pvp_frags = false,

	--> window size
		max_window_size = {width = 480, height = 450},
		new_window_size = {width = 300, height = 95},
		window_clamp = {-8, 0, 21, -14},
		
	--> segments
		segments_amount = 12,
		segments_amount_to_save = 5,
		segments_panic_mode = true,
	--> instances
		instances_amount = 5,
		instances_segments_locked = false,
		
	--> if clear ungroup characters when logout
		clear_ungrouped = true,
	--> if clear graphic data when logout
		clear_graphic = true, 
	
	--> text sizes
		font_sizes = {menus = 10},
		ps_abbreviation = 3,
		total_abbreviation = 2,
	
	--> performance
		use_row_animations = false,
		animate_scroll = false,
		use_scroll = false,
		update_speed = 1,
		time_type = 2,
		memory_threshold = 3,
		memory_ram = 64,
		remove_realm_from_name = true,
		trash_concatenate = false,
		trash_auto_remove = true,
	
	--> death log
		deadlog_limit = 12,
	
	--> report
		report_lines = 5,
		report_to_who = "",
		
	--> colors
		default_bg_color = 0.0941,
		default_bg_alpha = 0.5,
		
	--> fades
		row_fade_in = {"in", 0.2},
		windows_fade_in = {"in", 0.2},
		row_fade_out = {"out", 0.2},
		windows_fade_out = {"out", 0.2},

	--> captures
		capture_real = {
			["damage"] = true,
			["heal"] = true,
			["energy"] = false,
			["miscdata"] = true,
			["aura"] = true,
			["spellcast"] = true,
		},
	
	--> cloud capture
		cloud_capture = true,
		
	--> combat
		minimum_combat_time = 5,
		overall_flag = 0xD,
		overall_clear_newboss = true,
		overall_clear_newchallenge = true,
	
	--> skins
		standard_skin = false,
		skin = "Default Skin",
		profile_save_pos = false,
		
	--> tooltip
		tooltip = {
			fontface = "Friz Quadrata TT", 
			fontsize = 10, 
			fontcolor = {1, 1, 1, 1}, 
			fontshadow = false, 
			background = {.1, .1, .1, .3}, 
			abbreviation = 8, 
			maximize_method = 1, 
			show_amount = false, 
			commands = {},
			
			anchored_to = 1,
			anchor_screen_pos = {507.700, -350.500},
			anchor_point = "bottom",
			anchor_relative = "top",
			anchor_offset = {0, 0},
		},
	
}

_detalhes.default_profile = default_profile

-- aqui fica as propriedades do jogador que não serão armazenadas no profile
local default_player_data = {
	--> current combat number
		combat_id = 0,
	--> nicktag cache
		nick_tag_cache = {},
	--> plugin data
		plugin_database = {},
	--> information about this character
		character_data = {logons = 0},
	--> version
		last_realversion = _detalhes.realversion,
		last_version = "v1.0.0",
	--> profile
		active_profile = "",
	--> plugins tables
		SoloTablesSaved = {},
		RaidTablesSaved = {},
	--> switch tables
		switchSaved = {slots = 6, table = {}},
	--> saved skins
		savedStyles = {},
}

_detalhes.default_player_data = default_player_data

local default_global_data = {

	--> profile pool
		__profiles = {},
		custom = {},
		savedStyles = {},
		savedCustomSpells = {},
		savedTimeCaptures = {},
		tutorial = {
			logons = 0, 
			unlock_button = 0, 
			version_announce = 0, 
			main_help_button = 0, 
			alert_frames = {false, false, false, false, false, false}, 
			bookmark_tutorial = false,
		},
		performance_profiles = {
			["RaidFinder"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Raid15"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Raid30"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Mythic"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Battleground15"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Battleground40"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Arena"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Dungeon"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
		}
}

_detalhes.default_global_data = default_global_data



function _detalhes:SaveProfileSpecial()
	
	--> get the current profile
		local profile_name = _detalhes:GetCurrentProfileName()
		local profile = _detalhes:GetProfile (profile_name, true)

	--> save default keys
		for key, _ in pairs (_detalhes.default_profile) do 

			local current_value = _detalhes_database [key] or _detalhes_global [key] or _detalhes.default_player_data [key] or _detalhes.default_global_data [key]

			if (type (current_value) == "table") then
				local ctable = table_deepcopy (current_value)
				profile [key] = ctable
			else
				profile [key] = current_value
			end

		end

	--> save skins
		table.wipe (profile.instances)

		for index, instance in ipairs (_detalhes.tabela_instancias) do
			local exported = instance:ExportSkin()
			profile.instances [index] = exported
		end

	--> end
		return profile
end