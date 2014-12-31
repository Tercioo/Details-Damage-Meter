-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> global name declaration
  
		_ = nil
		_detalhes = LibStub("AceAddon-3.0"):NewAddon("_detalhes", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "NickTag-1.0")
		_detalhes.build_counter = 340 --it's 340 for release
		_detalhes.userversion = "v3.6.14b"
		_detalhes.realversion = 55 --core version
		_detalhes.version = _detalhes.userversion .. " (core " .. _detalhes.realversion .. ")"

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialization stuff

do 

	local _detalhes = _G._detalhes

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

--[[
|cFFFFFF00v3.6.14b (|cFFFFCC00Jan 01, 2015|r|cFFFFFF00)|r:\n\n
|cFFFFFF00-|r Added custom display 'My Spells' which shows your spells in the window.\n\n
|cFFFFFF00-|r Added new custom display: Health Potion & Stone.\n\n
|cFFFFFF00-|r Added overkill on death's tooltip.\n\n
|cFFFFFF00-|r Created custom spells for Twin Ogron's Pulverize. Now it has 3 spells one for each wave.\n\n
|cFFFFFF00-|r Created custom spells for Ko'ragh Overflowing Energy. Now it has 2 spells one for when the ball is catched and other when it reaches the ground and explodes.\n\n
|cFFFFFF00-|r Changed healing multistrike to use the same format as damage done.\n\n
|cFFFFFF00-|r Few improvements on Tiny Threat plugin: color gradient green-red is fixed, texts and bar texture now correctly uses the window settings.\n\n
|cFFFFFF00-|r Damage Taken by Spell won't show pets in its tooltip any more.\n\n
|cFFFFFF00-|r Enemies display won't show any more mirror images and spirit link totems.\n\n
|cFFFFFF00-|r Enemies's tooltip now only show players and show all players instead of only 6.\n\n
|cFFFFFF00-|r Few cooldowns shown as raid wide now shows as personal cooldowns.\n\n
|cFFFFFF00-|r Fixed dispell tagets on dispell's tooltip.\n\n
|cFFFFFF00-|r Fixed 'First Hit' raid tool.\n\n
|cFFFFFF00-|r Fixed 'Open Options Panel' from interface panel.\n\n

|cFFFFFF00v3.6.7 (|cFFFFCC00Dec 24, 2014|r|cFFFFFF00)|r:\n\n
|cFFFFFF00-|r Added Fast Dps/Hps Updates, enable in on Rows: Advanced -> Fast Updates.\n\n
|cFFFFFF00-|r Added custom spell for Mirror Images Fireball and Frostbolt.\n\n
|cFFFFFF00-|r Added new skin: 'ElvUI Style II'.\n\n
|cFFFFFF00-|r Added Observer channel for Raid Tools, it only reports the cooldown/interrupt/death to you in your chat window.\n\n
|cFFFFFF00-|r Added new plugin: Raid Check: it tracks raid members checking food, flask and pre-potions usage.\n\n
|cFFFFFF00-|r Changed DPS display, now it shows onyl the player's Dps and the Dps difference between him and the top ranked.\n\n
|cFFFFFF00-|r Changed Overheal display, now its percentage shows the player's overheal percent.\n\n
|cFFFFFF00-|r Player Detail Window now shows the amount of multistrike on normal and critical hits.\n\n
|cFFFFFF00-|r Removed skin: 'ElvUI Frame Style BW'.\n\n
|cFFFFFF00-|r The tooltip for Scale option under options panel, now shows the real value for the scale.\n\n
|cFFFFFF00-|r Fixed a problem where multistrike was counting towards critical strike amount.\n\n
|cFFFFFF00-|r Fixed death display's report where it was't showing any death.\n\n
|cFFFFFF00-|r Fixed a small issue with Encounter Details plugin where sometimes gets a error right after a boss encounter.\n\n
|cFFFFFF00-|r Fixed bugs on sending messages to chat for Raid Tools.\n\n
--]]

	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v3.6.14b (|cFFFFCC00Jan 01, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added custom display 'My Spells' which shows your spells in the window.\n\n|cFFFFFF00-|r Added new custom display: Health Potion & Stone.\n\n|cFFFFFF00-|r Added overkill on death's tooltip.\n\n|cFFFFFF00-|r Created custom spells for Twin Ogron's Pulverize. Now it has 3 spells one for each wave.\n\n|cFFFFFF00-|r Created custom spells for Ko'ragh Overflowing Energy. Now it has 2 spells one for when the ball is catched and other when it reaches the ground and explodes.\n\n|cFFFFFF00-|r Changed healing multistrike to use the same format as damage done.\n\n|cFFFFFF00-|r Few improvements on Tiny Threat plugin: color gradient green-red is fixed, texts and bar texture now correctly uses the window settings.\n\n|cFFFFFF00-|r Damage Taken by Spell won't show pets in its tooltip any more.\n\n|cFFFFFF00-|r Enemies display won't show any more mirror images and spirit link totems.\n\n|cFFFFFF00-|r Enemies's tooltip now only show players and show all players instead of only 6.\n\n|cFFFFFF00-|r Few cooldowns shown as raid wide now shows as personal cooldowns.\n\n|cFFFFFF00-|r Fixed dispell tagets on dispell's tooltip.\n\n|cFFFFFF00-|r Fixed 'First Hit' raid tool.\n\n|cFFFFFF00-|r Fixed 'Open Options Panel' from interface panel.\n\n|cFFFFFF00v3.6.8 (|cFFFFCC00Dec 24, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added Fast (i mean, really fast) Dps/Hps update rate, its option is under Rows: Advanced -> Fast Updates.\n\n|cFFFFFF00-|r Created a custom spell for Mirror Image's Fireball and Frostbolt, with that Player Detail window distinguishes spells from the player and images.\n\n|cFFFFFF00-|r Added new skin: 'ElvUI Style II'.\n\n|cFFFFFF00-|r Added Observer mode for Raid Tools: report cooldown/interrupt/death of entire raid only to you in your chat window.\n\n|cFFFFFF00-|r Added new plugin 'Raid Check': tracks raid members checking food, flask and pre-potions usage.\n\n|cFFFFFF00-|r Changed DPS display, now it shows onyl the player's Dps and the Dps difference between him and the top ranked.\n\n|cFFFFFF00-|r Changed Overheal display, now its percentage shows the player's overheal percent.\n\n|cFFFFFF00-|r Player Detail Window now shows the amount of multistrike on normal and critical hits.\n\n|cFFFFFF00-|r Removed skin: 'ElvUI Frame Style BW'.\n\n|cFFFFFF00-|r The tooltip for Scale option under options panel, now shows the real value for the scale.\n\n|cFFFFFF00-|r Fixed Imperator Mar'gok's adds damage taken.\n\n|cFFFFFF00-|r Fixed a problem where multistrike was counting towards critical strike amount.\n\n|cFFFFFF00-|r Fixed death display's report where it was't showing any death.\n\n|cFFFFFF00-|r Fixed a small issue with Encounter Details plugin where sometimes gets a error right after a boss encounter.\n\n|cFFFFFF00-|r Fixed bugs on sending messages to chat for Raid Tools.\n\n\n\n|cFFFFFF00v3.5.1 (|cFFFFCC00Dec 16, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed few accuracy on miss spells.\n\n|cFFFFFF00v3.5.0 (|cFFFFCC00Dec 14, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed tooltip for Auras and Voidzones, now shows sorted by damage and time.\n\n|cFFFFFF00-|r More fixes for Korgath encounter on Highmaul.\n\n|cFFFFFF00-|r Added slash commands: 'reset' 'config'.\n\n|cFFFFFF00-|r Spell bars on Player Details Window now is painted with the spell spellschool color.\n\n|cFFFFFF00-|r Multistrike doesn't count any more for spell's Minimal Damage.\n\n|cFFFFFF00-|r Resource display got an tooltip which shows what resource is and resource gained per minute.\n\n|cFFFFFF00-|r Clicking on report button when the report window is already open, make it close.\n\n|cFFFFFF00v3.4.7 (|cFFFFCC00Dec 11, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Advanced Death Logs plugin got updates on Endurance Player Value and few bug fixes.\n\n|cFFFFFF00-|r Max Window Amount options can new be set to 1, before the minimum was 3.\n\n|cFFFFFF00-|r Fixed a problem with friendly fire tooltip where sometimes it wasn't showing up.\n\n|cFFFFFF00-|r Fixed cooldowns tooltip which wasn't showing rounded numbers (49.99 instead of 50).\n\n|cFFFFFF00-|r Fixed Warrior's Shield Block which wasn't being count as a cooldown.\n\n|cFFFFFF00-|r Fixed a problem where sometimes when a hunter pull and reset the boss right after, was causing segments to merge.\n\n|cFFFFFF00v3.4.4 (|cFFFFCC00Dec 05, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed a issue with Ko'Ragh boss on Highmaul raid.\n\n|cFFFFFF00-|r Few changes on Bookmark panel.\n\n|cFFFFFF00v3.4.3 (|cFFFFCC00Dec 02, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Removed 'Simple Gray' skin.\n\n|cFFFFFF00-|r Addde new skin: 'Forced Square'.\n\n|cFFFFFF00-|r 'Default Skin' got renamed to 'WoW Interface'.\n\n|cFFFFFF00v3.4.2 (|cFFFFCC00Dec 01, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed a bug with menu desaturation where erase and close buttons stay colored after clicking on it.\n\n|cFFFFFF00-|r Fixed stretch where sometimes after release the window, all exceeded bars shows up and fade in again.\n\n|cFFFFFF00-|r Fixed a bug with the +- buttons on the window's scale option.\n\n|cFFFFFF00-|r Fixed the border for sub menus on mode menu.\n\n|cFFFFFF00v3.4.0 (|cFFFFCC00Nov 29, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed custom displays ignoring 'target' setted.\n\n|cFFFFFF00-|r Fixed plugins showing its icon even when auto hide menus is enabled.\n\n|cFFFFFF00-|r .Updates slash command 'worldboss' now it shows Draenor bosses.\n\n|cFFFFFF00v3.3.0 (|cFFFFCC00Nov 25, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added 3D models for the bars in the window. The options are at Appearance -> Rows: Advanced.\n\n|cFFFFFF00-|r Now when showing custom displays, clicking on a bar report what is shown on bar's tooltip.\n\n|cFFFFFF00-|r More fixes for dungeon bosses identification.\n\n|cFFFFFF00-|r Fixed a tooltip bug with Debuff Uptime and Aura & Voidzone displays.\n\n|cFFFFFF00-|r Fixed Player Details Window for friendly fire and damage taken.\n\n|cFFFFFF00-|r Fixed Molten Core Raid Finder version where all bosses was considered trash segments.\n\n|cFFFFFF00v3.2.4 (|cFFFFCC00Nov 19, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r More fixes for dungeon bosses recognition.\n\n|cFFFFFF00-|r Fixes for few errors during combat parser.\n\n|cFFFFFF00v3.2.3 (|cFFFFCC00Nov 18, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed Monk's Stagger ability which was counting as damage done.\n\n|cFFFFFF00-|r Added WoD dungeon information, this fixes dungeon bosses being assigned as 'trash cleanup'.\n\n|cFFFFFF00-|r Added more information on API.txt document (is in Details! root folder).\n\n|cFFFFFF00v3.2.1 (|cFFFFCC00Nov 14, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Custom Displays updated to track WoD potions.\n\n|cFFFFFF00-|r Added Feedback panel at options panel."

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
			_detalhes:Msg ("|cffb0b0b0you can always reset the addon running the command '/details reinstall' if it does fail to load after being updated.|r")
		end
		_detalhes:ScheduleTimer ("WelcomeMsgLogon", 8)
	
	--> key binds
		--> header
			_G ["BINDING_HEADER_Details"] = "Details!"
		--> keys
			_G ["BINDING_NAME_DETAILS_RESET_SEGMENTS"] = "Reset Segments"
			_G ["BINDING_NAME_DETAILS_SCROLL_UP"] = "Scroll Up All Windows"
			_G ["BINDING_NAME_DETAILS_SCROLL_DOWN"] = "Scroll Down All Windows"
	
end
