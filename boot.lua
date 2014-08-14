-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> global name declaration
 
		_ = nil
		_detalhes = LibStub("AceAddon-3.0"):NewAddon("_detalhes", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "NickTag-1.0")

		_detalhes.build_counter = 32 --it's 36 for release
		_detalhes.userversion = "v1.22.2"
		_detalhes.realversion = 25
		_detalhes.version = _detalhes.userversion .. " (core " .. _detalhes.realversion .. ")"

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialization stuff

do 

	local _detalhes = _G._detalhes
	
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	
	--[[
|cFFFFFF00a1.22.0 (|cFFFFCC00Ago 10, 2014|r|cFFFFFF00)|r:\n\n
|cFFFFFF00-|r Added support for hotcorners.\n\n
|cFFFFFF00-|r Few improvements on report for Deaths and Spells over Player Detail Window.\n\n
|cFFFFFF00-|r Added option for disable window groups.\n\n
|cFFFFFF00-|r Added option for select the icon pack to use, also added black white icon pack.\n\n
|cFFFFFF00-|r Fixed many bugs involving skins and profiles, thing should run more smooth now.\n\n
|cFFFFFF00-|r Plugin Time Attack now correctly saves the attempt when pressing the big save button.\n\n

	--]]

	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00a1.22.2 (|cFFFFCC00Ago 14, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Few improvements on report for Deaths and Spells over Player Detail Window.\n\n|cFFFFFF00-|r Added option for disable window groups.\n\n|cFFFFFF00-|r Added option for select the icon pack to use, also added black white icon pack.\n\n|cFFFFFF00-|r Fixed many bugs involving skins and profiles, thing should run more smooth now.\n\n|cFFFFFF00-|r Plugin Time Attack now correctly saves the attempt when pressing the big save button.\n\n|cFFFFFF00-|r Added support for hotcorners.\n\n|cFFFFFF00v1.21.4 (|cFFFFCC00Ago 9, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added Shaman's Ancestral Guidance on cooldowns list |cFF999999(thanks @skmzarn-mmochampion forum)|r.\n\n|cFFFFFF00-|r Added a profile selection screen when Details! are running for the first time on a character.\n\n|cFFFFFF00-|r Added Menu Text Size option over miscellaneous section on options panel |cFF999999(thanks @ Revi-mmochampion forum)|r.\n\n|cFFFFFF00-|r Fixed a bug over Healing Player Details Window where pets wasn't being shown |cFF999999(thanks @Mystery2012-mmochampion forum)|r.\n\n|cFFFFFF00-|r Fixed issue with summoning pets with unknown owners where it was breaking the summon of all the others pets. |cFF999999(thanks @ThunderLost-curse website)|r.\n\n|cFFFFFF00-|r Hot Corners isn't no more a part of Details!, instead of that, Hot Corner is now a standalone addon which needs to be installed separately for who wants to use it.\n\n|cFFFFFF00-|r Skin data is now stored inside the profiles, many code parts got rewrite, still may have few bugs but it's more reliable then before.\n\n|cFFFFFF00-|r Rework on Auras and Voidzones: now shows damage, dps and percentage. Also its tooltip got fixes and now shows the correct damage done to players.\n\n|cFFFFFF00-|r Tooltip for Enemies now shows damage taken from players |cFF999999(thanks @Arieth-mmochampion forum)|r.\n\n|cFFFFFF00-|r Right clicking a real-time enemy bar, makes it back to Enemies display instead of show Bookmark panel |cFF999999(thanks @Arieth-mmochampion forum)|r.\n\n|cFFFFFF00-|r Tank comparison from previous segment now uses the same percentage method from player comparison panel.\n\n|cFFFFFF00-|r Fix bug with the slash command 'show' where was ignoring the window limit set on options panel |cFF999999(thanks @Castiel-US-Azralon realm)|r.\n\n|cFFFFFF00-|r Fixed few bugs with scroll bars, including scrolls on dropdown menu and player detail window |cFF999999(thanks @Revi-mmochampion forum)|r.\n\n|cFFFFFF00v1.20.2 (|cFFFFCC00Aug 1, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added a option under Miscellaneous section to provide spell link instead of spell name for helpful spells when reporting a death |cFF999999(thanks @skmzarn-mmochampion forum)|r.\n\n|cFFFFFF00-|r Improvements done on how deaths are handled, now latest events before death will be more precise.\n\n|cFFFFFF00-|r Implemented Damage Taken from environment like lava, gravity, etc.\n\n|cFFFFFF00-|r Added Warlock's Fire and Brimstone spell on customized spells.\n\n|cFFFFFF00-|r Added dwarf racial Stone Form on cooldown list |cFF999999(thanks @Mystery2012-mmochampion forum)|r.\n\n|cFFFFFF00-|r Bookmark now are shared between all characters.\n\n|cFFFFFF00-|r Fixed few inconsistencies with trash recognition.\n\n|cFFFFFF00-|r Fixed Cloud Capture where sometimes it wasn't sharing.\n\n|cFFFFFF00-|r Fixed report where it wasn't sharing for guild and raid when the player name box were empty.\n\n|cFFFFFF00-|r Report box now also saves the position and the last channel used to report |cFF999999(thanks @skmzarn-mmochampion forum)|r.\n\n|cFFFFFF00-|r You Are Not Prepared plugin now have tooltips for spells and its window auto opens after a boss encounter.\n\n|cFFFFFF00-|r Advanced Death Logs plugin got full rewrite (and still are in development).\n\n|cFFFFFF00v1.19.0 - v1.19.1 - v1.19.2 (|cFFFFCC00Jul 21, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Details! is now able to be translated by its community for all supported languages through Curse Forge Web Site:\n\n|cFFFFFF00http://wow.curseforge.com/addons/details/localization/|r\n\n|cFFFFFF00-|r Slash commands now are multi language, accepting both english and the localized language.\n\n|cFFFFFF00-|r Added Data Broker for: Combat Time, Player Dps and Player Hps.\n\n|cFFFFFF00-|r Rework on plugins: Timeline, You Are Not Prepared, Tiny Threat, Encounter Details. All those plugins got a options panel and few improvaments.\n\n|cFFFFFF00-|r Trash segments won't be saved anymore.\n\n|cFFFFFF00-|r Added support for plugins options.\n\n|cFFFFFF00-|r Revamp on Deaths report lines, adding links for harmful spells and changing the text order |cFF999999(thanks @skmzarn-mmochampion forum)|r.\n\n|cFFFFFF00-|r Modified the percentage used on Comparison panel |cFF999999(thanks @Mystery2012-mmochampion forum)|r.\n\n|cFFFFFF00-|r Fixed the Raid Dps and Hps data exported by Data Broker |cFF999999(thanks @Arieth-mmochampion forum)|r.\n\n|cFFFFFF00v1.18.4 - v1.18.5 - v1.18.6 (|cFFFFCC00Jul 13, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added option to customize the bar left text.\n\n|cFFFFFF00-|r Added option for show or hide bar placement number.\n\n|cFFFFFF00-|r Spell icon is shown in the bar when the enemy character is a environment spell type.\n\n|cFFFFFF00-|r Changed the non-player enemy icon (monsters).\n\n|cFFFFFF00-|r Fixed bug on flex performance profile |cFF999999(thanks @skmzarn-mmochampion forum)|r.\n\n|cFFFFFF00-|r Added new version tracker which should alert you when a newer Details! version is found.\n\n|cFFFFFF00-|r Added Enemy Damage Taken by clicking with middle mouse button over a enemy bar (enemies display).\n\n|cFFFFFF00-|r Added import/export for saved skins and custom displays created.\n\n|cFFFFFF00-|r Small changes on ElvUI Frame Style skin (need reaply).\n\n|cFFFFFF00-|r Fixed the death recognition for bosses, now it should show the correct color over segments menu.\n\n|cFFFFFF00-|r Fixed Dps inacuracy when plyaing solo (no party or raid group).\n\n|cFFFFFF00-|r Fixed the duration time of buffs applied before the pull, like pre-potions.\n\n|cFFFFFF00v1.17.5 (|cFFFFCC00Jun 30, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Shortcut panel is now known as Bookmarks and a revamp has done on its panel.\n\n|cFFFFFF00-|r NickTag now doesnt check anymore if a received nickname from other guild member is invalid.\n\n|cFFFFFF00-|r Healthstone now is considered a cooldown.\n\n|cFFFFFF00-|r Few improvements on Default Skin, Minimalistic Skin and ElvUI Frame Style Skin.\n\n|cFFFFFF00-|r Revamp on Image Editor, many bugs solves and now it is usable.\n\n|cFFFFFF00-|r 'Hide' slash command now hides all opened windows; 'Show', open all closed windows and 'New' create a new window.\n\n|cFFFFFF00-|r Added Devotion Aura, Rallying Cry as cooldowns.\n\n|cFFFFFF00-|r Added options for lock, unlock, break snap, close, reopen and create new window.\n\n|cFFFFFF00-|r Added a options panel for HotCorners, access it through options button or slash hotcorner command.\n\n|cFFFFFF00-|r Added 'Logos' and 'Raid & Dungeons' sections for Wallpapers. \n\n|cFFFFFF00-|r Added a option to load a image from the computer to use as wallpaper.\n\n|cFFFFFF00-|r Fixed the percent issue with Healing Done and HPS while in combat.\n\n|cFFFFFF00-|r Fixed non-combat switch by role where changing role wasnt changing the shown attribute.\n\n|cFFFFFF00-|r Fixed 'While in Combat' hiding schema |cFF999999(thanks @skmzarn-mmochampion forum)|r.\n\n|cFFFFFF00-|r Fixed several bugs on Interact Auto Transparency.\n\n|cFFFFFF00-|r Fixed the report window alert when opening the report window and it already is opened |cFF999999(thanks @Rasstapp-mmochampion forum)|r.\n\n|cFFFFFF00-|r Fixed the gap between last row created and the end of the window.\n\n|cFFFFFF00-|r Fixed all tooltips bugs on Wallpaper Section on Options Panel.\n\n|cFFFFFF00a1.17.0 (|cFFFFCC00Jun 21, 2014|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Support for Custom Displays has been rewrited, to access the new panel go to Sword Menu -> Custom -> Create New Display.\n\n|cFFFFFF00-|r Added a custom display for show potion usage.\n\n|cFFFFFF00-|r Fixed a bug where the player pet wasnt being tracked after logon in the game. This bug was affecting directly classes with pets playing out of a raid group."
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
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> functions
	
	_detalhes.empty_function = function() end
	
	--> register textures and fonts for shared media
		local SharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
		SharedMedia:Register ("statusbar", "Details D'ictum", [[Interface\AddOns\Details\images\bar4]])
		SharedMedia:Register ("statusbar", "Details Vidro", [[Interface\AddOns\Details\images\bar4_vidro]])
		SharedMedia:Register ("statusbar", "Details D'ictum (reverse)", [[Interface\AddOns\Details\images\bar4_reverse]])
		SharedMedia:Register ("statusbar", "Details Serenity", [[Interface\AddOns\Details\images\bar_serenity]])
		SharedMedia:Register ("background", "Details Ground", [[Interface\AddOns\Details\images\background]])
		SharedMedia:Register ("border", "Details BarBorder 1", [[Interface\AddOns\Details\images\border_1]])
		SharedMedia:Register ("border", "Details BarBorder 2", [[Interface\AddOns\Details\images\border_2]])
	
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
				print ("|cffffaeae" .. self.__name .. "|r |cffcc7c7c(plugin)|r: " .. _string, arg1 or "", arg2 or "", arg3 or "", arg4 or "")
			else
				print (Loc ["STRING_DETAILS1"] .. _string, arg1 or "", arg2 or "", arg3 or "", arg4 or "")
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
