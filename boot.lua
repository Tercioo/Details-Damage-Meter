-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> global name declaration

		_ = nil
		_detalhes = LibStub("AceAddon-3.0"):NewAddon("_detalhes", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "NickTag-1.0")
		_detalhes.build_counter = 439 --it's 439 for release
		_detalhes.userversion = "v3.8.5"
		_detalhes.realversion = 58 --core version
		_detalhes.version = _detalhes.userversion .. " (core " .. _detalhes.realversion .. ")"

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialization stuff

do 

	local _detalhes = _G._detalhes
	
	_detalhes.resize_debug = {}

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

--[[
|cFFFFFF00v3.8.5 (|cFFFFCC00Jan 21, 2015|r|cFFFFFF00)|r:\n\n
|cFFFFFF00-|r Added Segments shortcut menu pressing Shift + Right click .\n\n
|cFFFFFF00-|r Fixed avoidance panel on Player Details Window where sometimes was giving errors.\n\n
|cFFFFFF00-|r Fixed priest shadow and holy detection.\n\n
|cFFFFFF00-|r Fixed blood and unholy spec icons.\n\n
|cFFFFFF00-|r Improved specialization detection in order to try detect spec changes.\n\n
|cFFFFFF00-|r Fixed an issue with 'Always Show me' feature where it was showing the player on Enemies display.\n\n
|cFFFFFF00-|r Testing LibWindow-1.1.\n\n
--]]

--	
	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v3.8.5 (|cFFFFCC00Jan 22, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added Segments shortcut menu pressing Shift + Right click .\n\n|cFFFFFF00-|r Fixed avoidance panel on Player Details Window where sometimes was giving errors.\n\n|cFFFFFF00-|r Fixed priest shadow and holy detection.\n\n|cFFFFFF00-|r Fixed blood and unholy spec icons.\n\n|cFFFFFF00-|r Improved specialization detection in order to try detect spec changes.\n\n|cFFFFFF00-|r Fixed an issue with 'Always Show Me' feature where it was showing the player on Enemies display.\n\n|cFFFFFF00-|r Testing LibWindow-1.1.\n\n|cFFFFFF00v3.8.1 (|cFFFFCC00Jan 17, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Plugin Vanguard: got full rewrite and now it is more easy to use.\n\n|cFFFFFF00-|r Plugin TimeAttack: fixed problem where sometimes required a reload to start a new time.\n\n|cFFFFFF00-|r Plugin Damage the Game!: fixed a problem where sometimes the time didn't started after level 2.\n\n|cFFFFFF00-|r Added specialization icons.\n\n|cFFFFFF00-|r Fixed Auto-Hide where it wasn't hiding the wallpaper of the window.\n\n|cFFFFFF00-|r Added 'Editing Group' check box on option panel, when enabled, settings changed also are modified on all windows in the group.\n\n|cFFFFFF00-|r Changing window's skin, doesn't change any more settings not related with appearance, for example, Auto-Hide, Switches.\n\n|cFFFFFF00-|r Custom display 'Health Potion & Stone' now also track Healing Tonic.\n\n|cFFFFFF00-|r Custom display 'Damage Taken by Spell' now tracks more spells and also melee hits.\n\n|cFFFFFF00-|r Menus now uses 'Friz Quadrata TT' font as default, also added an option to change it on options panel -> miscellaneous.\n\n|cFFFFFF00-|r 'Switch to Current' feature now switches all windows which have this option enabled.\n\n|cFFFFFF00-|r The message telling to use '/details reinstall' now only shows if a problem happen during the addon load process.\n\n|cFFFFFF00-|r Segments Saved option now can be set to 25, up from 5.\n\n|cFFFFFF00-|r Attempt to fix the bug with the monk spell 'Storm, Earth, and Fire'.\n\n|cFFFFFF00-|r Fixed 'Icon Pick' panel.\n\n|cFFFFFF00-|r Fixed bug when reporting friendly fire through player detail window.\n\n|cFFFFFF00-|r Fixed bug with report window where sometimes it was reporting on a wrong channel.\n\n|cFFFFFF00v3.7.1 (|cFFFFCC00Jan 08, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Plugin 'Damage Rank': is now called 'Damage, the Game!' and had its levels adjusted for WoD.\n\n|cFFFFFF00-|r Plugin 'Tiny Threat': fixed player name where it was showing the realm name too.\n\n|cFFFFFF00-|r Plugin 'Vanguard': fixed frame details (clicking on a bar) shown behind the Vanguard panel.\n\n|cFFFFFF00-|r Plugin 'Vanguard': fixed a problem when clicking with right button wasn't opening the bookmark panel.\n\n|cFFFFFF00-|r Plugin 'Vanguard': incoming heals now count shield amount on the player too.\n\n|cFFFFFF00-|r Plugin 'Vanguard' Known Bug: incoming damage and melee vs avoidance seems to be inaccurate by now, we need more time to study and fix it.\n\n|cFFFFFF00-|r Added Twins Ogron's Charge as custom spells, one for the charge by him self and other for the copies (mythic only).\n\n|cFFFFFF00-|r Added option panel for Raid Check plugin.\n\n|cFFFFFF00-|r Added key bindings for open a window, close a window and select a bookmark.\n\n|cFFFFFF00-|r Added 'CTRL + RightClick' closes a window.\n\n|cFFFFFF00-|r Fixed wallpaper transparency after releasing the window from a stretch.|cFFFFFF00-|r Fixed few issues when using class text colors.\n\n|cFFFFFF00-|r Fixed characters name outside instances, now it replaces the realm name with a * and show the complete name on tooltip.\n\n|cFFFFFF00-|r Fixed damage mitigation on damage taken, this affects only specific classes like monk tank.\n\n|cFFFFFF00-|r Fixed auto erase poping up when the player enters on its garrison.\n\n|cFFFFFF00-|r Fixed combat on garrison training dummies which was being marked as Trash Segment.\n\n|cFFFFFF00-|r Fixed command /details disable, wasn't disabling the capture of cooldowns.\n\n|cFFFFFF00-|r Fixed a problem with fast dps/hps when the window is in a empty segment.\n\n|cFFFFFF00-|r Fixed an issue using bookmark panel where it wasn't changing the display when the window is in a plugin mode.\n\n|cFFFFFF00-|r Fixed a bug when bars isn't using class colors on Frags, Auras & Void Zones, Resources and Deaths.\n\n|cFFFFFF00-|r Fixed bar animations when 'Sort Direction' is set to bottom.\n\n|cFFFFFF00-|r Fixed the spam 'you are not in a guild' when checking for new versions.\n\n|cFFFFFF00-|r Fixed translations for Auto Hide Settings bracket under options panel.\n\n|cFFFFFF00-|r Fixed Auto Hide -> Mouse Interaction tool where wans't able to work okey during combat.\n\n|cFFFFFF00v3.6.14b (|cFFFFCC00Jan 01, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added custom display 'My Spells' which shows your spells in the window.\n\n|cFFFFFF00-|r Added new custom display: Health Potion & Stone.\n\n|cFFFFFF00-|r Added overkill on death's tooltip.\n\n|cFFFFFF00-|r Created custom spells for Twin Ogron's Pulverize. Now it has 3 spells one for each wave.\n\n|cFFFFFF00-|r Created custom spells for Ko'ragh Overflowing Energy. Now it has 2 spells one for when the ball is catched and other when it reaches the ground and explodes.\n\n|cFFFFFF00-|r Changed healing multistrike to use the same format as damage done.\n\n|cFFFFFF00-|r Few improvements on Tiny Threat plugin: color gradient green-red is fixed, texts and bar texture now correctly uses the window settings.\n\n|cFFFFFF00-|r Damage Taken by Spell won't show pets in its tooltip any more.\n\n|cFFFFFF00-|r Enemies display won't show any more mirror images and spirit link totems.\n\n|cFFFFFF00-|r Enemies's tooltip now only show players and show all players instead of only 6.\n\n|cFFFFFF00-|r Few cooldowns shown as raid wide now shows as personal cooldowns.\n\n|cFFFFFF00-|r Fixed dispell tagets on dispell's tooltip.\n\n|cFFFFFF00-|r Fixed 'First Hit' raid tool.\n\n|cFFFFFF00-|r Fixed 'Open Options Panel' from interface panel.\n\n|cFFFFFF00v3.6.8 (|cFFFFCC00Dec 24, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added Fast (i mean, really fast) Dps/Hps update rate, its option is under Rows: Advanced -> Fast Updates.\n\n|cFFFFFF00-|r Created a custom spell for Mirror Image's Fireball and Frostbolt, with that Player Detail window distinguishes spells from the player and images.\n\n|cFFFFFF00-|r Added new skin: 'ElvUI Style II'.\n\n|cFFFFFF00-|r Added Observer mode for Raid Tools: report cooldown/interrupt/death of entire raid only to you in your chat window.\n\n|cFFFFFF00-|r Added new plugin 'Raid Check': tracks raid members checking food, flask and pre-potions usage.\n\n|cFFFFFF00-|r Changed DPS display, now it shows onyl the player's Dps and the Dps difference between him and the top ranked.\n\n|cFFFFFF00-|r Changed Overheal display, now its percentage shows the player's overheal percent.\n\n|cFFFFFF00-|r Player Detail Window now shows the amount of multistrike on normal and critical hits.\n\n|cFFFFFF00-|r Removed skin: 'ElvUI Frame Style BW'.\n\n|cFFFFFF00-|r The tooltip for Scale option under options panel, now shows the real value for the scale.\n\n|cFFFFFF00-|r Fixed Imperator Mar'gok's adds damage taken.\n\n|cFFFFFF00-|r Fixed a problem where multistrike was counting towards critical strike amount.\n\n|cFFFFFF00-|r Fixed death display's report where it was't showing any death.\n\n|cFFFFFF00-|r Fixed a small issue with Encounter Details plugin where sometimes gets a error right after a boss encounter.\n\n|cFFFFFF00-|r Fixed bugs on sending messages to chat for Raid Tools.\n\n\n\n|cFFFFFF00v3.5.1 (|cFFFFCC00Dec 16, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed few accuracy on miss spells.\n\n|cFFFFFF00v3.5.0 (|cFFFFCC00Dec 14, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed tooltip for Auras and Voidzones, now shows sorted by damage and time.\n\n|cFFFFFF00-|r More fixes for Korgath encounter on Highmaul.\n\n|cFFFFFF00-|r Added slash commands: 'reset' 'config'.\n\n|cFFFFFF00-|r Spell bars on Player Details Window now is painted with the spell spellschool color."

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetails!:|r "

	--> startup
		_detalhes.initializing = true
		_detalhes.enabled = true
		_detalhes.__index = _detalhes
		_detalhes._tempo = time()
		_detalhes.debug = false
		_detalhes.opened_windows = 0
		_detalhes.last_combat_time = 0
		
	--> containers
		--> armazenas as funções do parser - All parse functions 
			_detalhes.parser = {} 
			_detalhes.parser_functions = {}
			_detalhes.parser_frame = CreateFrame ("Frame", nil, _UIParent)
			_detalhes.parser_frame:Hide()
		--> armazena os escudos - Shields information for absorbs
			_detalhes.escudos = {} 
		--> armazena as funções dos frames - Frames functions
			_detalhes.gump = {} 
			function _detalhes:GetFramework()
				return self.gump
			end
		--> armazena as funções para inicialização dos dados - Metatable functions
			_detalhes.refresh = {} 
		--> armazena as funções para limpar e guardas os dados - Metatable functions
			_detalhes.clear = {} 
		--> armazena a config do painel de fast switch
			_detalhes.switch = {} 
		--> armazena os estilos salvos
			_detalhes.savedStyles = {}
		--> armazena quais atributos possue janela de atributos - contain attributes and sub attributos wich have a detailed window (left click on a row)
			_detalhes.row_singleclick_overwrite = {} 
		--> report
			_detalhes.ReportOptions = {}
		--> armazena os buffs registrados - store buffs ids and functions
			_detalhes.Buffs = {} --> initialize buff table
		-->  cache de grupo
			_detalhes.cache_damage_group = {}
			_detalhes.cache_healing_group = {}
		--> cache de specs
			_detalhes.cached_specs = {}
		--> ignored pets
			_detalhes.pets_ignored = {}
			_detalhes.pets_no_owner = {}
		--> armazena as skins disponíveis para as janelas
			_detalhes.skins = {}
		--> armazena os hooks das funções do parser
			_detalhes.hooks = {}
		--> informações sobre a luta do boss atual
			_detalhes.encounter_end_table = {}
			_detalhes.encounter_table = {}
		--> informações sobre a arena atual
			_detalhes.arena_table = {}
			_detalhes.arena_info = {
				[562] = {file = "LoadScreenBladesEdgeArena", coords = {0, 1, 0.29296875, 0.9375}}, -- Circle of Blood Arena
				[617] = {file = "LoadScreenDalaranSewersArena", coords = {0, 1, 0.29296875, 0.857421875}}, --Dalaran Arena
				[559] = {file = "LoadScreenNagrandArenaBattlegrounds", coords = {0, 1, 0.341796875, 1}}, --Ring of Trials
				[980] = {file = "LoadScreenTolvirArena", coords = {0, 1, 0.29296875, 0.857421875}}, --Tol'Viron Arena
				[572] = {file = "LoadScreenRuinsofLordaeronBattlegrounds", coords = {0, 1, 0.341796875, 1}}, --Ruins of Lordaeron
				[1134] = {file = "LoadingScreen_Shadowpan_bg", coords = {0, 1, 0.29296875, 0.857421875}}, -- Tiger's Peak
				--"LoadScreenOrgrimmarArena", --Ring of Valor 
			}
		--> armazena instancias inativas
			_detalhes.unused_instances = {}
			
			function _detalhes:GetArenaInfo (mapid)
				local t = _detalhes.arena_info [mapid]
				if (t) then
					return t.file, t.coords
				end
			end
			
		--> tooltip
			_detalhes.tooltip_backdrop = {
				bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]], 
				--bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], 
				edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], 
				tile = true,
				edgeSize = 16, 
				tileSize = 16, 
				insets = {left = 3, right = 3, top = 4, bottom = 4}
			}
			_detalhes.tooltip_border_color = {1, 1, 1, 1}
			_detalhes.tooltip_spell_icon = {file = [[Interface\CHARACTERFRAME\UI-StateIcon]], coords = {36/64, 58/64, 7/64, 26/64}}
			--_detalhes.tooltip_target_icon = {file = [[Interface\CHARACTERFRAME\UI-StateIcon]], coords = {36/64, 58/64, 7/64, 26/64}}
		
		
	--> Plugins
		--> raid -------------------------------------------------------------------
			--> general function for raid mode plugins
				_detalhes.RaidTables = {} 
			--> menu for raid modes
				_detalhes.RaidTables.Menu = {} 
			--> plugin objects for raid mode
				_detalhes.RaidTables.Plugins = {} 
			--> name to plugin object
				_detalhes.RaidTables.NameTable = {} 
			--> using by
				_detalhes.RaidTables.InstancesInUse = {} 
				_detalhes.RaidTables.PluginsInUse = {} 

		--> solo -------------------------------------------------------------------
			--> general functions for solo mode plugins
				_detalhes.SoloTables = {} 
			--> maintain plugin menu
				_detalhes.SoloTables.Menu = {} 
			--> plugins objects for solo mode
				_detalhes.SoloTables.Plugins = {} 
			--> name to plugin object
				_detalhes.SoloTables.NameTable = {} 
		
		--> toolbar -------------------------------------------------------------------
			--> plugins container
				_detalhes.ToolBar = {}
			--> current showing icons
				_detalhes.ToolBar.Shown = {}
				_detalhes.ToolBar.AllButtons = {}
			--> plugin objects
				_detalhes.ToolBar.Plugins = {}
			--> name to plugin object
				_detalhes.ToolBar.NameTable = {}
				_detalhes.ToolBar.Menu = {}
		
		--> statusbar -------------------------------------------------------------------
			--> plugins container
				_detalhes.StatusBar = {}
			--> maintain plugin menu
				_detalhes.StatusBar.Menu = {} 
			--> plugins object
				_detalhes.StatusBar.Plugins = {} 
			--> name to plugin object
				_detalhes.StatusBar.NameTable = {} 

	--> constants
		_detalhes._detalhes_props = {
			DATA_TYPE_START = 1,	--> Something on start
			DATA_TYPE_END = 2,	--> Something on end

			MODO_ALONE = 1,	--> Solo
			MODO_GROUP = 2,	--> Group
			MODO_ALL = 3,		--> Everything
			MODO_RAID = 4,	--> Raid
		}
		_detalhes.modos = {
			alone = 1, --> Solo
			group = 2,	--> Group
			all = 3,	--> Everything
			raid = 4	--> Raid
		}

		_detalhes.divisores = {
			abre = "(",	--> open
			fecha = ")",	--> close
			colocacao = ". " --> dot
		}
		
		_detalhes.role_texcoord = {
			DAMAGER = "72:130:69:127",
			HEALER = "72:130:2:60",
			TANK = "5:63:69:127",
			NONE = "139:196:69:127",
		}
		
		_detalhes.player_class = {
			["HUNTER"] = true,
			["WARRIOR"] = true,
			["PALADIN"] = true,
			["SHAMAN"] = true,
			["MAGE"] = true,
			["ROGUE"] = true,
			["PRIEST"] = true,
			["WARLOCK"] = true,
			["DRUID"] = true,
			["MONK"] = true,
			["DEATHKNIGHT"] = true,
		}
		
		local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details")
		
		_detalhes.segmentos = {
			label = Loc ["STRING_SEGMENT"]..": ", 
			overall = Loc ["STRING_TOTAL"], 
			overall_standard = Loc ["STRING_OVERALL"],
			current = Loc ["STRING_CURRENT"], 
			current_standard = Loc ["STRING_CURRENTFIGHT"],
			past = Loc ["STRING_FIGHTNUMBER"] 
		}
		
		_detalhes._detalhes_props["modo_nome"] = {
				[_detalhes._detalhes_props["MODO_ALONE"]] = Loc ["STRING_MODE_SELF"], 
				[_detalhes._detalhes_props["MODO_GROUP"]] = Loc ["STRING_MODE_GROUP"], 
				[_detalhes._detalhes_props["MODO_ALL"]] = Loc ["STRING_MODE_ALL"],
				[_detalhes._detalhes_props["MODO_RAID"]] = Loc ["STRING_MODE_RAID"]
		}
		
		--[[global]] DETAILS_MODE_SOLO = 1
		--[[global]] DETAILS_MODE_RAID = 4
		--[[global]] DETAILS_MODE_GROUP = 2
		--[[global]] DETAILS_MODE_ALL = 3

		_detalhes.icones = {
			--> report window
			report = { 
					up = "Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon",
					down = "Interface\\ItemAnimations\\MINIMAP\\TRACKING\\Profession",
					disabled = "Interface\\ItemAnimations\\MINIMAP\\TRACKING\\Profession",
					highlight = nil
				}
		}
	
		_detalhes.missTypes = {"ABSORB", "BLOCK", "DEFLECT", "DODGE", "EVADE", "IMMUNE", "MISS", "PARRY", "REFLECT", "RESIST"} --> do not localize-me

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> frames
	
	local _CreateFrame = CreateFrame --api locals
	local _UIParent = UIParent --api locals
	
	--> Info Window
		_detalhes.janela_info = _CreateFrame ("Frame", "Details_JanelaInfo", _UIParent)

	--> Event Frame
		_detalhes.listener = _CreateFrame ("Frame", nil, _UIParent)
		_detalhes.listener:RegisterEvent ("ADDON_LOADED")
		_detalhes.listener:SetFrameStrata ("LOW")
		_detalhes.listener:SetFrameLevel (9)
		_detalhes.listener.FrameTime = 0
	
		_detalhes.overlay_frame = _CreateFrame ("Frame", nil, _UIParent)
		_detalhes.overlay_frame:SetFrameStrata ("TOOLTIP")
	
	--> Pet Owner Finder
		_CreateFrame ("GameTooltip", "DetailsPetOwnerFinder", nil, "GameTooltipTemplate")
		
		
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> functions
	
	_detalhes.empty_function = function() end
	
	--> register textures and fonts for shared media
		local SharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
		--default bars
		SharedMedia:Register ("statusbar", "Details D'ictum", [[Interface\AddOns\Details\images\bar4]])
		SharedMedia:Register ("statusbar", "Details Vidro", [[Interface\AddOns\Details\images\bar4_vidro]])
		SharedMedia:Register ("statusbar", "Details D'ictum (reverse)", [[Interface\AddOns\Details\images\bar4_reverse]])
		--flat bars
		SharedMedia:Register ("statusbar", "Details Serenity", [[Interface\AddOns\Details\images\bar_serenity]])
		SharedMedia:Register ("statusbar", "BantoBar", [[Interface\AddOns\Details\images\BantoBar]])
		SharedMedia:Register ("statusbar", "Skyline", [[Interface\AddOns\Details\images\bar_skyline]])
		--window bg and bar border
		SharedMedia:Register ("background", "Details Ground", [[Interface\AddOns\Details\images\background]])
		SharedMedia:Register ("border", "Details BarBorder 1", [[Interface\AddOns\Details\images\border_1]])
		SharedMedia:Register ("border", "Details BarBorder 2", [[Interface\AddOns\Details\images\border_2]])
		--misc fonts
		SharedMedia:Register ("font", "Oswald", [[Interface\Addons\Details\fonts\Oswald-Regular.otf]])
		SharedMedia:Register ("font", "Nueva Std Cond", [[Interface\Addons\Details\fonts\NuevaStd-Cond.otf]])
		SharedMedia:Register ("font", "Accidental Presidency", [[Interface\Addons\Details\fonts\Accidental Presidency.ttf]])
		SharedMedia:Register ("font", "TrashHand", [[Interface\Addons\Details\fonts\TrashHand.TTF]])
		SharedMedia:Register ("font", "Harry P", [[Interface\Addons\Details\fonts\HARRYP__.TTF]])
		SharedMedia:Register ("font", "FORCED SQUARE", [[Interface\Addons\Details\fonts\FORCED SQUARE.ttf]])
	
	--> global 'vardump' for dump table contents over chat panel
		function vardump (t)
			if (type (t) ~= "table") then
				return
			end
			for a,b in pairs (t) do 
				print (a,b)
			end
		end
		
	--> global 'table_deepcopy' copies a full table	
		function table_deepcopy (orig)
			local orig_type = type(orig)
			local copy
			if orig_type == 'table' then
				copy = {}
				for orig_key, orig_value in next, orig, nil do
					copy [table_deepcopy (orig_key)] = table_deepcopy (orig_value)
				end
			else
				copy = orig
			end
			return copy
		end
	
	--> delay messages
		function _detalhes:DelayMsg (msg)
			_detalhes.delaymsgs = _detalhes.delaymsgs or {}
			_detalhes.delaymsgs [#_detalhes.delaymsgs+1] = msg
		end
		function _detalhes:ShowDelayMsg()
			if (_detalhes.delaymsgs and #_detalhes.delaymsgs > 0) then
				for _, msg in ipairs (_detalhes.delaymsgs) do 
					print (msg)
				end
			end
			_detalhes.delaymsgs = {}
		end
	
	--> print messages
		function _detalhes:Msg (_string, arg1, arg2, arg3, arg4)
			if (self.__name) then
				--> yes, we have a name!
				print ("|cffffaeae" .. self.__name .. "|r |cffcc7c7c(plugin)|r: " .. (_string or ""), arg1 or "", arg2 or "", arg3 or "", arg4 or "")
			else
				print (Loc ["STRING_DETAILS1"] .. (_string or ""), arg1 or "", arg2 or "", arg3 or "", arg4 or "")
			end
		end
		
	--> welcome
		function _detalhes:WelcomeMsgLogon()
			_detalhes:Msg ("you can always reset the addon running the command |cFFFFFF00'/details reinstall'|r if it does fail to load after being updated.")
		end
		_detalhes.failed_to_load = _detalhes:ScheduleTimer ("WelcomeMsgLogon", 20)
	
	--> key binds
		--> header
			_G ["BINDING_HEADER_Details"] = "Details!"
			_G ["BINDING_HEADER_DETAILS_KEYBIND_SEGMENTCONTROL"] = Loc ["STRING_KEYBIND_SEGMENTCONTROL"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_SCROLLING"] = Loc ["STRING_KEYBIND_SCROLLING"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_WINDOW_CONTROL"] = Loc ["STRING_KEYBIND_WINDOW_CONTROL"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_BOOKMARK"] = Loc ["STRING_KEYBIND_BOOKMARK"]

		--> keys
			_G ["BINDING_NAME_DETAILS_RESET_SEGMENTS"] = Loc ["STRING_KEYBIND_RESET_SEGMENTS"]
			_G ["BINDING_NAME_DETAILS_SCROLL_UP"] = Loc ["STRING_KEYBIND_SCROLL_UP"]
			_G ["BINDING_NAME_DETAILS_SCROLL_DOWN"] = Loc ["STRING_KEYBIND_SCROLL_DOWN"]
	
			_G ["BINDING_NAME_DETAILS_REOPEN_WINDOW1"] = format (Loc ["STRING_KEYBIND_REOPEN_WINDOW"], 1)
			_G ["BINDING_NAME_DETAILS_REOPEN_WINDOW2"] = format (Loc ["STRING_KEYBIND_REOPEN_WINDOW"], 2)
			_G ["BINDING_NAME_DETAILS_REOPEN_WINDOW3"] = format (Loc ["STRING_KEYBIND_REOPEN_WINDOW"], 3)
			_G ["BINDING_NAME_DETAILS_REOPEN_WINDOW4"] = format (Loc ["STRING_KEYBIND_REOPEN_WINDOW"], 4)
			_G ["BINDING_NAME_DETAILS_REOPEN_WINDOW5"] = format (Loc ["STRING_KEYBIND_REOPEN_WINDOW"], 5)
			
			_G ["BINDING_NAME_DETAILS_CLOSE_WINDOW1"] = format (Loc ["STRING_KEYBIND_CLOSE_WINDOW"], 1)
			_G ["BINDING_NAME_DETAILS_CLOSE_WINDOW2"] = format (Loc ["STRING_KEYBIND_CLOSE_WINDOW"], 2)
			_G ["BINDING_NAME_DETAILS_CLOSE_WINDOW3"] = format (Loc ["STRING_KEYBIND_CLOSE_WINDOW"], 3)
			_G ["BINDING_NAME_DETAILS_CLOSE_WINDOW4"] = format (Loc ["STRING_KEYBIND_CLOSE_WINDOW"], 4)
			_G ["BINDING_NAME_DETAILS_CLOSE_WINDOW5"] = format (Loc ["STRING_KEYBIND_CLOSE_WINDOW"], 5)
			
			_G ["BINDING_NAME_DETAILS_BOOKMARK1"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 1)
			_G ["BINDING_NAME_DETAILS_BOOKMARK2"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 2)
			_G ["BINDING_NAME_DETAILS_BOOKMARK3"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 3)
			_G ["BINDING_NAME_DETAILS_BOOKMARK4"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 4)
			_G ["BINDING_NAME_DETAILS_BOOKMARK5"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 5)
			_G ["BINDING_NAME_DETAILS_BOOKMARK6"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 6)
			_G ["BINDING_NAME_DETAILS_BOOKMARK7"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 7)
			_G ["BINDING_NAME_DETAILS_BOOKMARK8"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 8)
			_G ["BINDING_NAME_DETAILS_BOOKMARK9"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 9)
			_G ["BINDING_NAME_DETAILS_BOOKMARK10"] = format (Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 10)
			
end
