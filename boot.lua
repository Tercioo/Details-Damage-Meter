-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> global name declaration
  
		_ = nil
		_detalhes = LibStub("AceAddon-3.0"):NewAddon("_detalhes", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "NickTag-1.0")
		_detalhes.build_counter = 158 --it's 171 for release
		_detalhes.userversion = "a3.0.1"
		_detalhes.realversion = 39
		_detalhes.version = _detalhes.userversion .. " (core " .. _detalhes.realversion .. ")"

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialization stuff

do 

	local _detalhes = _G._detalhes

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

--[[
|cFFFFFF00v3.0.1 (|cFFFFCC00Oct 29, 2014|r|cFFFFFF00)|r:\n\n
|cFFFFFF00-|r Continuing the changes on internal structures. Now Energies displays got modifications.\nThese changes makes the addon 0.4% faster and near 4% less memory heavily.\n\n
--]]

	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v3.0.1 (|cFFFFCC00Oct 29, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Continuing the changes on internal structures. Now Energies displays got modifications.\nThese changes makes the addon 0.4% faster and near 4% less memory heavily.\n\n|cFFFFFF00a3.0.0 (|cFFFFCC00Oct 26, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r We are changing the way Details! store its data. By now damage and healing had their structure changed.\n\nThese changes are reducing the memory usage by 35% and Cpu usage by 2%.\n\nAt the and of all modifications we hope reach 50% less memory.\n\nThis version is a alpha version, so, if you find malfunctions or lua errors, please report to us.\n\n|cFFFFFF00v2.2.3 (|cFFFFCC00Oct 26, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed the healing done problem with Priest's Spirit of Redemption.\n\n|cFFFFFF00-|r Fixed avoidance by absorb when the hit missed was a multistrike hit.\n\n|cFFFFFF00-|r Fixed a script time out problem when erasing data while in combat.\n\n|cFFFFFF00-|r Fixed bug with interrupt tooltip when the player have a pet.\n\n|cFFFFFF00v2.2.1 (|cFFFFCC00Oct 22, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed the gap between the button and its menu which sometimes traveling the mouse between them was activating tooltips from window's bars.\n\n|cFFFFFF00-|r Fixed an annoying menu blink when the window was near the right side of the screen.\n\n|cFFFFFF00-|r Fixed the stretch grab which was over other windows even with the 'stretch always on top' option disabled.\n\n|cFFFFFF00-|r Few fixes on healing done from absorbs.\n\n|cFFFFFF00v2.1.6 (|cFFFFCC00Oct 21, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed death's tooltip which wasn't respecting tooltip's configuration set on options panel.\n\n|cFFFFFF00-|r Now when the window is close to the top of the screen, menus will anchor on bottom side of the menu icons.\n\n|cFFFFFF00-|r Added micro displays options on Window Settings bracket.\n\n|cFFFFFF00-|r Fixed the problem with bar's custom texts.\n\n|cFFFFFF00-|r Lua functions inside custom texts, Chart Data scripts and Custom Displays scripts are now protected calls and won't break the addon functionality if an error occurs. Unfortunately we still doesn't have a documentation for Details! API.\n\n|cFFFFFF00-|r Fixed an incomum bug with tank avoidance tables.\n\n|cFFFFFF00-|r Tiny Threat: added option to use class colors instead of green-to-red colors.\n\n|cFFFFFF00-|r Added option to enable shadows on toolbar's buttons.\n\n|cFFFFFF00-|r Added option to set the specing between each button on toolbar.\n\n|cFFFFFF00-|r Finally we merged the left and right menus into only one with 6 icons.\n\n|cFFFFFF00-|r Removed window button and added a new option bracket to manage windows under Mode Menu.\n\n|cFFFFFF00-|r Few changes on 'Default Skin', 'Minimalistic', 'Simple Gray' and 'ElvUI Frame Style BW' (need reaply).\n\n|cFFFFFF00- Important:|r If the menus is out of the position, just reaply the skin.\n\nv2.0.15 (|cFFFFCC00Oct 15, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed tooltips where sometimes it wans't showing at all.\n\n|cFFFFFF00-|r Fixed the healing done amount on Malkorok encounter.\n\nv2.0.14 (|cFFFFCC00Oct 14, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added pre-potion recognition for WoD pots.\n\n|cFFFFFF00-|r Added spell list for Blackrock Foundry encounters.\n\n|cFFFFFF00-|r Added mouse wheel scroll speed option.\n\n|cFFFFFF00-|r Added support for healing multistrike and damage multistrike.\n\n|cFFFFFF00-|r Added a Change Log button on Options Panel.\n\n|cFFFFFF00-|r When the windows is locked, trying to move the window through toolbar will stretch it instead.\n\n|cFFFFFF00-|r Renamed overheal for shields, now its called 'shield wasted'.\n\n|cFFFFFF00-|r Fine tuning on healing done, should have high accuracy now.\n\n|cFFFFFF00-|r Encounter Details plugin now supports Highmaul and Blackrock Foundry.\n\n|cFFFFFF00-|r New class cooldowns and spells recognition.\n\n|cFFFFFF00-|r Fixed few bugs on comparison panel and avoidance panel.\n\n|cFFFFFF00-|r Fixed encounter recognition, now it should show the encounter name over segments menu.\n\n|cFFFFFF00-|r Fixed Graphic part of Encounter Details Plugin, now he draws more accurately.\n\n|cFFFFFF00v1.29.3 (|cFFFFCC00Oct 11, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an addon crash bug when clicking directly on the sword button.\n\n|cFFFFFF00-|r Removed Flat Skin, added new skin: Serenity.\n\n|cFFFFFF00-|r Fixed many issues with bar animations.\n\n|cFFFFFF00-|r Fixed combat encounter start if the player already is in combat when the boss is pulled.\n\n|cFFFFFF00-|r Fixed wheel scroll when sometimes it move very slow or doesn't move the bars at all.\n\n|cFFFFFF00-|r Added option 'Always Show Me' which when enabled and you aren't at the top ranked players shown in the window, it forces to show you in the last bar.\n\n|cFFFFFF00-|r Added option 'First Hit' which when enabled show who did the first struck in the combat (normally is who pulled the boss).\n\n|cFFFFFF00-|r Added a panel to change class colors.\n\n|cFFFFFF00v1.28.3 (|cFFFFCC00Oct 04, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added support for plugin descriptions on options panel.\n\n|cFFFFFF00-|r Added scale option.\n\n|cFFFFFF00-|r Added a Change Log button on Options Panel.\n\n|cFFFFFF00-|r Added option to use the same profile on all characters without asking.\n\n|cFFFFFF00-|r Added a shortcut color button on main panel on Options Panel.\n\n|cFFFFFF00-|r Added auto erase/ask to erase options.\n\n|cFFFFFF00-|r Bars now highlight when hover over.\n\n|cFFFFFF00-|r Fixed problem with drag the window when the toolbar is on the bottom side.\n\n|cFFFFFF00v1.27.0 (|cFFFFCC00Set 27, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Minimalistic skin is now the old minimalistic v2.\n\n|cFFFFFF00-|r Minimalistic v2 got a new texture, little more darker.\n\n|cFFFFFF00-|r Few tweaks to make more easy making groups of windows.\n\n|cFFFFFF00-|r Bookmark now accepts more than two columns.\n\n|cFFFFFF00v1.26.3 (|cFFFFCC00Set 18, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Changed the way to set the broker text to be more customizable.\n\n|cFFFFFF00-|r Fixed the problem with custom display report.\n\n|cFFFFFF00-|r Added tutorial and a config panel for bookmarks.\n\n|cFFFFFF00-|r Added option for choose the format type of data broker's text.\n\n|cFFFFFF00-|r Changed few icons on damage done tooltip.\n\n|cFFFFFF00-|r Fixed the class color on texts for healing attribute.\n\n|cFFFFFF00-|r Added options for change the tooltip border's size, color and texture."

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetails!:|r "

	--> startup
		_detalhes.initializing = true
		_detalhes.enabled = true
		_detalhes.__index = _detalhes
		_detalhes._tempo = time()
		_detalhes.debug = false
		_detalhes.opened_windows = 0
		
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
		_detalhes.listener:RegisterEvent ("PLAYER_LOGOUT")
		_detalhes.listener:SetFrameStrata ("LOW")
		_detalhes.listener:SetFrameLevel (9)
		_detalhes.listener.FrameTime = 0
	
		_detalhes.overlay_frame = _CreateFrame ("Frame", nil, _UIParent)
		_detalhes.overlay_frame:SetFrameStrata ("TOOLTIP")
	
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
