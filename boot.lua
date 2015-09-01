-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> global name declaration
 
		_ = nil
		_detalhes = LibStub("AceAddon-3.0"):NewAddon("_detalhes", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "NickTag-1.0")
		_detalhes.build_counter = 1601 --it's 1601 for release
		_detalhes.userversion = "v4.0a"
		_detalhes.realversion = 74 --core version
		_detalhes.version = _detalhes.userversion .. " (core " .. _detalhes.realversion .. ")"
		Details = _detalhes

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialization stuff

do 

	local _detalhes = _G._detalhes

	_detalhes.resize_debug = {}

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

--[[
|cFFFFFF00v3.19.0 (|cFFFFCC00Aug 21, 2015|r|cFFFFFF00)|r:\n\n
|cFFFFFF00-|r Updated Details! Framework.\n\n
|cFFFFFF00-|r Added option in order to change the bar orientation.\n\n
|cFFFFFF00-|r Added an option to make the menus on title bar work with clicks instead of hovering over them.\n\n
|cFFFFFF00-|r Fixed death display tooltip, wasn't respecting the font and size set on options panel.\n\n
|cFFFFFF00-|r Improvements on our support for Arena battles.\n\n
|cFFFFFF00-|r Fixed some issues on the Player Detail Window.\n\n
|cFFFFFF00-|r Healing for battleground enemies is now placed on healing done instead of enemy healing done.\n\n

--]]

--

	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v4.0a (|cFFFFCC00Aug 31, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Updated Details! Framework.\n\n|cFFFFFF00-|r Added option in order to change the bar orientation.\n\n|cFFFFFF00-|r Added an option to make the menus on title bar work with clicks instead of hovering over them.\n\n|cFFFFFF00-|r Healing for battleground enemies is now placed on healing done instead of enemy healing done.\n\n|cFFFFFF00-|r Improvements on our support for Arena battles.\n\n|cFFFFFF00-|r Fixed some issues on the Player Detail Window.\n\n|cFFFFFF00-|r Fixed death display tooltip, wasn't respecting the font and size set on options panel.\n\n|cFFFFFF00v3.18.5 (|cFFFFCC00Aug 19, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Improvements on Weakauras creation from Encounter Details plugin.\n\n|cFFFFFF00-|r Improvements on 'Auto Switch to Current' feature. Details! windows are now more responsible about auto changing a segment while the player, for instance, has the report window opened.\n\n|cFFFFFF00-|r Added slash command '/de wipe'. It ends the raid encounter segment and stop capturing data.\nIf you are the raid leader, all other users of Details! will also stop.\nWorks great for players not make damage padding after a wipe call.\n\n|cFFFFFF00-|r Added the  overheal made by pets on tooltip and player details window.\n\n|cFFFFFF00-|r Added an option to disable stretch button and bar highlight.\n\n|cFFFFFF00-|r Disabling nicknames now also disable avatars.\n\n|cFFFFFF00-|r Added 'spinal healing injector' on custom display 'Health Potion & Stone' used.\n\n|cFFFFFF00-|r Fixed title text width when auto-hide menu buttons is enabled.\n\n|cFFFFFF00-|r Fixed item level of timewarped items.\n\n|cFFFFFF00-|r Fixed report for custom display Crowd Control.\n\n|cFFFFFF00-|r Fixed role icons on custom displays.\n\n|cFFFFFF00-|r Fixed an issue with dropdown boxes where wasn't showing all options.\n\n|cFFFFFF00-|r Fixed Ticket #53: background alpha after stretching which wasn't correctly coming back to original color.\n\n|cFFFFFF00-|r Fixed ticket #51: API Call 'GetCombat('overall')' wasn't returning the overall combat object.\n\n|cFFFFFF00-|r Fixed ticket #50: issue opening icon selection frame.\n\n|cFFFFFF00v3.17.12 (|cFFFFCC00Aug 05, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added an option for lock micro displays. When locked they don't interact with mouse or stay on top of menus.\n\n|cFFFFFF00-|r Fixed ticket #49: death display not working correctly with sort direction bottom-to-top.\n\n|cFFFFFF00-|r Fixed an issue with death display where the text wasn't updating their width correctly.\n\n|cFFFFFF00-|r Fixed an issue with energy and miscellaneous displays type not working correctly with bar animations.\n\n|cFFFFFF00-|r Fixed an issue while loading old profiles wans't updating their values for newer versions of the addon.\n\n|cFFFFFF00-|r Fixed an issue with bookmarks panel not opening correctly.\n\n|cFFFFFF00v3.17.10 (|cFFFFCC00Aug 02, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed ticket #47: Title bar font resets with UI reload / relog.\n\n|cFFFFFF00-|r Fixed ticket #46: Icon select panel wasn't opening.\n\n|cFFFFFF00-|r Fixed ticket #45: Windwalker icon for Mistweaver monks.\n\n|cFFFFFF00-|r Fixed issue with vehicles exchanging ownership, e.g. Soulbound Constructor on HFC raid.\n\n|cFFFFFF00v3.17.6 (|cFFFFCC00Jul 16, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Major improvements on the aura tool creation for WeakAuras.\n\n|cFFFFFF00-|r Fixed some issues with spec icons where sometimes it shows four small icons.\n\n|cFFFFFF00-|r Added an option to show a stopwatch on the title text showing the elapsed time of an encounter.\n\n|cFFFFFF00-|r Window title text now shrinks correctly when isn't enough space for it.\n\n|cFFFFFF00-|r For some special cases, left click now open the report window and shift+click shows the tooltip content in the window.\n\n|cFFFFFF00-|r Damage Taken by Spells now are a part of Damage bracket (no more on custom).\n\n|cFFFFFF00-|r Fixed custom functions for the customized bar left text.\n\n|cFFFFFF00-|r Improvements on report text format and also reverse option now works as intended.\n\n|cFFFFFF00-|r Removed the option for report only what is shown in the window.\n\n|cFFFFFF00-|r Added skins for report panel, the skin follow the skin selected for Player Detail Window.\n\n|cFFFFFF00v3.16.0c (|cFFFFCC00Jul 06, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an issue with Encounter Details graphic for Archimonde encounter.\n\n|cFFFFFF00-|r Numbers format on Player Detail Window now respect the format chosen on options panel.\n\n|cFFFFFF00-|r Removed pet icons on Player Detail Window.\n\n|cFFFFFF00-|r Fixed some wrong textures on spec icons.\n\n|cFFFFFF00-|r Improvements on all skins for the Player Detail Window.\n\n|cFFFFFF00v3.15.8b (|cFFFFCC00Jul 01, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Soul Capacitor trinket fix.\n\n|cFFFFFF00-|r Fixed several small bugs from 6.2 patch.\n\n|cFFFFFF00-|r Disabled the special behavior for Tyrant Velhari encounter.\n\n|cFFFFFF00v3.15.7 (|cFFFFCC00Jun 23, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added support for Hellfire Citadel raid.\n\n|cFFFFFF00-|r Added support for custom CLEU parser functions.\n\n|cFFFFFF00-|r Tyrant Velhari encounter now has a custom CLEU parser function for healing where the heal absorbed by Aura of Contempt will count towards overheal and not healing done.\n\n|cFFFFFF00-|r Added support for embed on Chat Tabs.\n\n|cFFFFFF00-|r |cFFAAFFAAPS: We've made an addon for Shadow-Lord Iskar encounter called 'Iskar Assist' check it out|r.\n\n|cFFFFFF00v3.15.5a (|cFFFFCC00Jun 12, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an issue where sometimes tooltips wasn't being shown.\n\n|cFFFFFF00-|r Fixed a problem with overall data where it was using, even on dungoens, the raid-only 30 delay rule.\n\n|cFFFFFF00-|r Fixed an issue with spec detection (now it may detect even faster).\n\n|cFFFFFF00v3.15.5 (|cFFFFCC00Jun 09, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed a problem with auto hide feature not hiding plugins hosted by the window.\n\n|cFFFFFF00-|r Fixed an issue with stretch feature when the anchor button was anchored at the bottom side of the window.\n\n|cFFFFFF00-|r Small interface tweaks on tooltips, bookmark and player detail window.\n\n|cFFFFFF00-|r Custom display 'My Spells' now also show amount of casts and uptime.\n\n|cFFFFFF00-|r Added an extra tooltip for the class icon at the player's bar.\n\n|cFFFFFF00-|r Activity time now has only 3 seconds inactivity tolerance on battlegrounds and arenas.\n\n|cFFFFFF00-|r Effective time will automatically be used when inside a battleground and using sync from the score board.\n\n|cFFFFFF00-|r Added 'hide all' option on the minimap menu.\n\n|cFFFFFF00-|r Added support for battlegrounds.\n\n|cFFFFFF00-|r Added option for disable showing battleground enemies when the window is in group mode.\n\n|cFFFFFF00-|r Added option to disable the sync from battleground score board.\n\n|cFFFFFF00-|r Enemies from a battleground match segment won't be erased when the player logout.\n\n|cFFFFFF00v3.14.4 (|cFFFFCC00May 27, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r TimeLine (plugin): now also shows marks symbolizing the player death.\n\n|cFFFFFF00-|r Added raid history panel. Open it through bookmark or /details history.\n\n|cFFFFFF00-|r Added support for skins for Player Detail Window.\n\n|cFFFFFF00-|r Added report history on report button.\n\n|cFFFFFF00-|r Added key bindings settings for report what is shown on window #1 or #2.\n\n|cFFFFFF00v3.14.0b (|cFFFFCC00May 13, 2015|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Several texture changes for a smaller download size."

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
			_detalhes.parser_frame = CreateFrame ("Frame")
			_detalhes.pvp_parser_frame = CreateFrame ("Frame")
			_detalhes.parser_frame:Hide()
		--> armazena os escudos - Shields information for absorbs
			_detalhes.escudos = {}
		--> armazena as funções dos frames - Frames functions
			_detalhes.gump = _G ["DetailsFramework"]
			function _detalhes:GetFramework()
				return self.gump
			end
			GameCooltip = GameCooltip2
		--> animações dos icones
			_detalhes.icon_animations = {
				load = {
					in_use = {},
					available = {},
				},
			}
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
			_detalhes.cached_talents = {}
		--> ignored pets
			_detalhes.pets_ignored = {}
			_detalhes.pets_no_owner = {}
			_detalhes.pets_players = {}
		--> armazena as skins disponíveis para as janelas
			_detalhes.skins = {}
		--> armazena os hooks das funções do parser
			_detalhes.hooks = {}
		--> informações sobre a luta do boss atual
			_detalhes.encounter_end_table = {}
			_detalhes.encounter_table = {}
			_detalhes.encounter_counter = {}
			_detalhes.encounter_dungeons = {}
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
			function _detalhes:GetArenaInfo (mapid)
				local t = _detalhes.arena_info [mapid]
				if (t) then
					return t.file, t.coords
				end
			end
			_detalhes.battleground_info = {
				[489] = {file = "LoadScreenWarsongGulch", coords = {0, 1, 121/512, 484/512}}, --warsong gulch
				[727] = {file = "LoadScreenSilvershardMines", coords = {0, 1, 251/1024, 840/1024}}, --silvershard mines
				[529] = {file = "LoadscreenArathiBasin", coords = {0, 1, 126/512, 430/512}}, --arathi basin
				[566] = {file = "LoadScreenNetherBattlegrounds", coords = {0, 1, 142/512, 466/512}}, --eye of the storm
				[30] = {file = "LoadScreenPvpBattleground", coords = {0, 1, 127/512, 500/512}}, --alterac valley
				[761] = {file = "LoadScreenGilneasBG2", coords = {0, 1, 281/1024, 878/1024}}, --the battle for gilneas
				[726] = {file = "LoadScreenTwinPeaksBG", coords = {0, 1, 294/1024, 876/1024}}, --twin peaks
				[998] = {file = "LoadScreenValleyofPower", coords = {0, 1, 257/1024, 839/1024}}, --temple of kotmogu
				[1105] = {file = "LoadScreen_GoldRush", coords = {0, 1, 264/1024, 840/1024}}, --deepwind gorge
				[607] = {file = "LoadScreenNorthrendBG", coords = {0, 1, 302/1024, 879/1024}}, --strand of the ancients
				[628] = {file = "LOADSCREENISLEOFCONQUEST", coords = {0, 1, 297/1024, 878/1024}}, --isle of conquest
				--[] = {file = "", coords = {0, 1, 0, 0}}, --
			}
			function _detalhes:GetBattlegroundInfo (mapid)
				local t = _detalhes.battleground_info [mapid]
				if (t) then
					return t.file, t.coords
				end
			end
		--> armazena instancias inativas
			_detalhes.unused_instances = {}
			_detalhes.default_skin_to_use = "Minimalistic"
			_detalhes.instance_title_text_timer = {}
		--> player detail skin
			_detalhes.playerdetailwindow_skins = {}
		
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
		_detalhes.janela_info = _CreateFrame ("Frame", "DetailsPlayerDetailsWindow", _UIParent)

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
	_detalhes.empty_table = {}
	
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
		SharedMedia:Register ("statusbar", "WorldState Score", [[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])
		SharedMedia:Register ("statusbar", "DGround", [[Interface\AddOns\Details\images\bar_background]])
		
		--window bg and bar border
		SharedMedia:Register ("background", "Details Ground", [[Interface\AddOns\Details\images\background]])
		SharedMedia:Register ("border", "Details BarBorder 1", [[Interface\AddOns\Details\images\border_1]])
		SharedMedia:Register ("border", "Details BarBorder 2", [[Interface\AddOns\Details\images\border_2]])
		SharedMedia:Register ("border", "Details BarBorder 3", [[Interface\AddOns\Details\images\border_3]])
		--misc fonts
		SharedMedia:Register ("font", "Oswald", [[Interface\Addons\Details\fonts\Oswald-Regular.otf]])
		SharedMedia:Register ("font", "Nueva Std Cond", [[Interface\Addons\Details\fonts\NuevaStd-Cond.otf]])
		SharedMedia:Register ("font", "Accidental Presidency", [[Interface\Addons\Details\fonts\Accidental Presidency.ttf]])
		SharedMedia:Register ("font", "TrashHand", [[Interface\Addons\Details\fonts\TrashHand.TTF]])
		SharedMedia:Register ("font", "Harry P", [[Interface\Addons\Details\fonts\HARRYP__.TTF]])
		SharedMedia:Register ("font", "FORCED SQUARE", [[Interface\Addons\Details\fonts\FORCED SQUARE.ttf]])
		
		SharedMedia:Register ("sound", "d_gun1", [[Interface\Addons\Details\sounds\sound_gun2.ogg]])
		SharedMedia:Register ("sound", "d_gun2", [[Interface\Addons\Details\sounds\sound_gun3.ogg]])
		SharedMedia:Register ("sound", "d_jedi1", [[Interface\Addons\Details\sounds\sound_jedi1.ogg]])
		SharedMedia:Register ("sound", "d_whip1", [[Interface\Addons\Details\sounds\sound_whip1.ogg]])
	
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
			
			function _detalhes:wipe_combat_after_failed_load()
				_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
				_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
				_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
				_detalhes.tabela_pets = _detalhes.container_pets:NovoContainer()
				_detalhes:UpdateContainerCombatentes()
				
				_detalhes_database.tabela_overall = nil
				_detalhes_database.tabela_historico = nil
				
				_detalhes:Msg ("seems failed to load, please type /reload to try again.")
			end
			_detalhes:ScheduleTimer ("wipe_combat_after_failed_load", 5)
			
		end
		_detalhes.failed_to_load = _detalhes:ScheduleTimer ("WelcomeMsgLogon", 20)
	
	--> key binds
		--> header
			_G ["BINDING_HEADER_Details"] = "Details!"
			_G ["BINDING_HEADER_DETAILS_KEYBIND_SEGMENTCONTROL"] = Loc ["STRING_KEYBIND_SEGMENTCONTROL"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_SCROLLING"] = Loc ["STRING_KEYBIND_SCROLLING"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_WINDOW_CONTROL"] = Loc ["STRING_KEYBIND_WINDOW_CONTROL"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_BOOKMARK"] = Loc ["STRING_KEYBIND_BOOKMARK"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_REPORT"] = Loc ["STRING_KEYBIND_WINDOW_REPORT_HEADER"]

		--> keys
		
			_G ["BINDING_NAME_DETAILS_TOGGLE_ALL"] = Loc ["STRING_KEYBIND_TOGGLE_WINDOWS"]
			
			_G ["BINDING_NAME_DETAILS_RESET_SEGMENTS"] = Loc ["STRING_KEYBIND_RESET_SEGMENTS"]
			_G ["BINDING_NAME_DETAILS_SCROLL_UP"] = Loc ["STRING_KEYBIND_SCROLL_UP"]
			_G ["BINDING_NAME_DETAILS_SCROLL_DOWN"] = Loc ["STRING_KEYBIND_SCROLL_DOWN"]
	
			_G ["BINDING_NAME_DETAILS_REPORT_WINDOW1"] = format (Loc ["STRING_KEYBIND_WINDOW_REPORT"], 1)
			_G ["BINDING_NAME_DETAILS_REPORT_WINDOW2"] = format (Loc ["STRING_KEYBIND_WINDOW_REPORT"], 2)
	
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW1"] = format (Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 1)
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW2"] = format (Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 2)
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW3"] = format (Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 3)
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW4"] = format (Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 4)
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW5"] = format (Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 5)
			
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
