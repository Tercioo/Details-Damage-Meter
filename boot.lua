-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> global name declaration

		_ = nil
		_detalhes = LibStub("AceAddon-3.0"):NewAddon("_detalhes", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "NickTag-1.0")
		_detalhes.build_counter = 5985
		_detalhes.userversion = "v8.0.1." .. _detalhes.build_counter
		_detalhes.realversion = 131 --core version
		_detalhes.version = _detalhes.userversion .. " (core " .. _detalhes.realversion .. ")"
		_detalhes.BFACORE = 131
		Details = _detalhes
		
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialization stuff

do 

	local _detalhes = _G._detalhes

	_detalhes.resize_debug = {}

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

--[[
|cFFFFFF00v8.0.1.5985.131 (|cFFFFCC00July 17th, 2018|r|cFFFFFF00)|r:\n\n
|cFFFFFF00-|r Added 'Auto Run Code' module.\n\n
|cFFFFFF00-|r Added 'Plater Nameplates' integration.\n\n
|cFFFFFF00-|r Weakauras integration with the Create Aura panel got great improvements.\n\n
|cFFFFFF00-|r Many options has been renamed or moved from groups for better organization .\n\n
|cFFFFFF00-|r Several skins got some revamp for 2018.\n\n
|cFFFFFF00-|r Default settings for Arenas and Battlegrounds got changes and the experience should be more smooth now.\n\n
|cFFFFFF00-|r .\n\n
--]]
--
	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v8.0.1.5985.131 (|cFFFFCC00July 17th, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added 'Auto Run Code' module.\n\n|cFFFFFF00-|r Added 'Plater Nameplates' integration.\n\n|cFFFFFF00-|r Weakauras integration with the Create Aura panel got great improvements.\n\n|cFFFFFF00-|r Many options has been renamed or moved from groups for better organization .\n\n|cFFFFFF00-|r Several skins got some revamp for 2018.\n\n|cFFFFFF00-|r Default settings for Arenas and Battlegrounds got changes and the experience should be more smooth now.\n\n|cFFFFFF00v7.3.5.5559.130 (|cFFFFCC00April 13th, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added slash commands: /details 'softtoggle' 'softshow' 'softhide'. Use them to manipulate the window visibility while using auto hide.\n\n|cFFFFFF00-|r Mythic dungeon graphic window won't show up if the user leaves the dungeon before completing it.\n\n|cFFFFFF00v7.3.5.5529.130 (|cFFFFCC00April 06th, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added minimize button on the mythic dungeon run chart.\n\n|cFFFFFF00-|r Added API calls: Details:ResetSegmentOverallData() and Details:ResetSegmentData().\n\n|cFFFFFF00v7.3.5.5499.130 (|cFFFFCC00Mar 30th, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added outline option for the right text.\n\n|cFFFFFF00v7.3.5.5469.130 (|cFFFFCC00Mar 23th, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed a few things on the mythic dungeon chart.\n\n|cFFFFFF00v7.3.5.5424.129 (|cFFFFCC00Mar 10th, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added macro support to open plugins. Example:\n /run Details:OpenPlugin ('Time Line')\n\n|cFFFFFF00v7.3.5.5351.129 (|cFFFFCC00Feb 26rd, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added a damage chart for mythic dungeon runs, it shows at the of the run. You may disable it at the Streamer Settings.\n\n|cFFFFFF00v7.3.5.5231.128 (|cFFFFCC00Feb 02nd, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an issue with wasted shield absorbs where the wasted amount was subtracting the total healing done.\n\n|cFFFFFF00v7.3.5.5221.128 (|cFFFFCC00Jan 26th, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Warlock mana from Life Tap won't show up any more under mana regen, this makes easy to see Soul Shard gain.\n\n|cFFFFFF00v7.3.2.5183.128 (|cFFFFCC00Jan 12th, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r The new bar animation is now applied to all users by default.\n\n|cFFFFFF00-|r Fixed an issue with the threat plugin where sometimes it was triggering errors.\n\n|cFFFFFF00v7.3.2.5175.128 (|cFFFFCC00Jan 03rd, 2018|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r ElvUI skins should have now a more good looking scrollbar.\n\n|cFFFFFF00-|r When starting to edit a custom display, the code window now clear the code from the previous display.\n\n|cFFFFFF00v7.3.2.5154.128 (|cFFFFCC00Dec 22th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r API and Create Aura windows are now attached to the new plugin window.\n\n|cFFFFFF00v7.3.2.5101.128 (|cFFFFCC00Dec 15th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Moving the custom display window to the new plugins window.\n\n|cFFFFFF00-|r Major layout changes on the Encounter Details plugin window.\n\n|cFFFFFF00v7.3.2.4919.128 (|cFFFFCC00Dec 08th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an issue with the statistics sharing among guild members.\n\n|cFFFFFF00-|r Fixed an issue with Argus encounter where two segments were created.\n\n|cFFFFFF00-|r Fixed aura type images on the Create Aura Panel.\n\n|cFFFFFF00-|r Create Aura Panel can now be closed with Right Click.\n\n|cFFFFFF00-|r Framework updated to r60, plugins should be more stable now.\n\n|cFFFFFF00v7.3.0.4830.126 (|cFFFFFF00v7.3.2.4836.126 (|cFFFFCC00Nov 21th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Removed some tutorial windows popups.\n\n|cFFFFCC00Oct 21th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed opening windows when streamer settings > no alerts is enabled.\n\n|cFFFFFF00v7.3.0.4823.126 (|cFFFFCC00Oct 09th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added new options section: Streamer Settings, focused on adjustments for streamers and youtubers.\n\n|cFFFFFF00-|r Animations now always run at the same speed regardless the framerate.\n\n|cFFFFFF00-|r Click-To-Open menus now close the menu if the menu is already open.\n\n|cFFFFFF00v7.3.0.4723.126 (|cFFFFCC00Set 22th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed overall dungeon segments being added to overall data.\n\n|cFFFFFF00v7.3.0.4705.126 (|cFFFFCC00Set 19th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed damage taken tooltip for Brewmaster Monk where sometimes the tooltip didn't open.\n\n|cFFFFFF00-|r Fixed overall data on mythic dungeon not adding trash segments even with the option enabled on the options panel.\n\n|cFFFFFF00-|r Fixed the guild selection dropdown reseting everytime the Guild Rank window is opened.\n\n|cFFFFFF00v7.3.0.4677.126 (|cFFFFCC00Set 10th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r During mythic dungeons, the trash segments will be merged into a new segment at the end of the boss encounter (instead of merging on the fly while cleaning up).\n\n|cFFFFFF00v7.3.0.4615.125 (|cFFFFCC00Set 09th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Setting up the dungeon stuff as opt-in for early adopters while we continue to make improvements on the system.\n\n|cFFFFFF00v7.3.0.4586.125 (|cFFFFCC00Set 08th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Formating mythic+ dungeon segments, each segment should count the boss trash + boss fight.\n\n|cFFFFFF00-|r At the end of the mythic+ dungeon, it should create a new segment adding up all segments described above.\n\n|cFFFFFF00v7.3.0.4499.124 (|cFFFFCC00Set 05th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added an option to always show all players when using the standard mode. Option under PvP/PvE bracket on the options panel.\n\n|cFFFFFF00-|r Added a setting to exclude healing done lines from the death log below a certain healing amount. This options is also under PvP/PvE bracket.\n\n|cFFFFFF00-|r Fixed the guild selection on the ranking panel.\n\n|cFFFFFF00v7.3.0.4467.124 (|cFFFFCC00August 29th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Damage or Healing record for the encounter should be printed on chat on the boss pull.\nUse /run Details.announce_damagerecord.enabled = false; to disable.\n\n|cFFFFFF00v7.2.5.4437.124 (|cFFFFCC00August 21th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added healing done cap for death log. Use /run Details.deathlog_healingdone_min = 10000\n\n|cFFFFFF00-|r Fixed an issue where the alpha from the fixed bar color was used even when this option was disabled.\n\n|cFFFFFF00v7.2.5.4436.124 (|cFFFFCC00August 17th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Attempt to fix the issue where the window doesn't update after entering a raid or reseting data.\n\n|cFFFFFF00v7.2.5.4434.124 (|cFFFFCC00August 10th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added buttons to create an aura at Aura tab on the Player Details window.\n\n|cFFFFFF00-|r Fixes and improvements on the damage rank panel.\n\n|cFFFFFF00-|r Best damage or healing for the player on the current boss encounter is now shown on the spec icon tooltip.\n\n|cFFFFFF00-|r Major revamp on the aura creation panel.\n\n|cFFFFFF00v7.2.5.4369.124 (|cFFFFCC00August 1st, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Details! can now track debuff applications (stack) and refreshes.\n\n|cFFFFFF00-|r Added new tab on Player Detail Window called 'Auras', you can see your buffs and debuffs from there.\n\n|cFFFFFF00-|r Death log now show debuff applications.\n\n|cFFFFFF00v7.2.5.4275.123 (|cFFFFCC00July 18th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed some issues with tooltiops popup when the user press SHIFT.\n\n|cFFFFFF00-|r Now is possible to change the bar durating when selecting Cast Start trigger on Details! Forge.\n\n|cFFFFFF00-|r Kil'Jaeden adds should be consolidated into only one actor instead of having one for each player targeted.\n\n|cFFFFFF00v7.2.5.4236.122 (|cFFFFCC00July 05th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r The alert to open the raid ranking after a boss kill, is now shown for 10 seconds (down from 40).\n\n|cFFFFFF00-|r Added a report button on the raid ranking panel and boss are sort alphabetically.\n\n|cFFFFFF00-|r Fixed some issues on the combatlog introduced on the wow patch 7.2.5 where sometimes the source of an event has no name.\n\n|cFFFFFF00-|r Ticket #209, fixed more issues with the comparison panel where are pets involved.\n\n|cFFFFFF00v7.2.5.4201.121 (|cFFFFCC00June 26th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed Monk Stagger where it was only shown on the friendly fire and not under the Damage Taken display.\n\n|cFFFFFF00-|r Added Forge and Ranking options on the main menu (orange cogwheel).\n\n|cFFFFFF00v7.2.5.4102.121 (|cFFFFCC00June 22th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Details! Forge has updated and now is more usder friendly.\n\n|cFFFFFF00-|r Fixed an issue with player buff uptime where sometimes some buffs wans't showing in the tooltip.\n\n|cFFFFFF00v7.2.5.3968.120 (|cFFFFCC00June 20th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r New Death Recap implemented! replaces the default from Blizzard and can be configured at Options > Raid Tools.\n\n|cFFFFFF00-|r New Guild Damage and Heal rank on '/details ranking' panel.\n\n|cFFFFFF00-|r Added a Guild Sync button on the Details! Ranking Panel.\n\n|cFFFFFF00-|r Added Custom display 'Damage on Shields', useful for encounter like Maiden of Vigilance where there's big shields to be removed and you want to know who is doing more damage to it.\n\n|cFFFFFF00-|r Added Heal Absorbed display under Heal bracket.\n\nHeal Absorb are the heal denied by abilities such like DK's Necrotic Strike or raid boss Sisters of the Moon 'Embrace of the Eclipse' ability.\nThe tooltip of this display shows which players got heal denied, which abilities absorbed the heal, which abilities tried to heal but got the heal denied.\n\n|cFFFFFF00-|r Added Alternate Power display under Energy bracket, it shows the total of alternate power gain from each player, useful for encounters such as Demonic Inquisition.\n\n|cFFFFFF00-|r 'First Hit' message after pulling a boss, now also shows who the boss is targeting (almost always is who pulled).\n\n|cFFFFFF00-|r Raid Dps {rdps} and Hps {rhps} can now be used on the Broker Data Feed..\n\n|cFFFFFF00-|r Fixed an issue with Chromie from the scenario 'The Deaths of Chromie' where she wasn't being shown on the meter.\n\n|cFFFFFF00-|r Fixed Paladin 'Light of the Martyr' damage to self.\n\n|cFFFFFF00-|r Ticket #198 'Script Error' Fixed.\n\n|cFFFFFF00v7.2.0.3703.119 (|cFFFFCC00May 29th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an error while killing low level mobs with warrior class.\n\n|cFFFFFF00v7.2.0.3693.118 (|cFFFFCC00May 25th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fury Warrior shouldn't be assigned as Protection any more.\n\n|cFFFFFF00-|r Some parser fixes.\n\n|cFFFFFF00v7.2.0.3673.118 (|cFFFFCC00May 09th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Ticket #187: Fixed an issue when comparing hunter pets on the player detail window.\n\n|cFFFFFF00-|r Ticket #189 #186: Fixed a taint issue for some classes when using friendly nameplates on.\n\n|cFFFFFF00v7.2.0.3512.116 (|cFFFFCC00April 27th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Havoc Demon Hunter: your fury energy is being shown under Mana Restored (don't ask me why, the combat log is telling us it's mana).\n\n|cFFFFFF00-|r Pets now are shown on damage tooltips.\n\n|cFFFFFF00-|r Pets are now also shown on the comparison panel.\n\n|cFFFFFF00v7.2.0.3474.116 (|cFFFFCC00April 20th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Plugin: Raid Check > added some food buffs which wasn't being tracked.\n\n|cFFFFFF00v7.2.0.3467.116 (|cFFFFCC00April 07th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fix for the custom display window where apply and cancel buttons where over the edit window.\n\n|cFFFFFF00-|r Fix for an issue on editing a bookmark.\n\n|cFFFFFF00v7.1.5.3459.116 (|cFFFFCC00Mar 21th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an issue on dynamic overall data where it wasn't showing DPS.\n\n|cFFFFFF00-|r Fixed an issue with Apply, Save and Cancel buttons when editing a custom display.\n\n|cFFFFFF00-|r Removed the Damage and Healing presets for custom displays, now is only possible create custom displays by scripting them.\n\n|cFFFFFF00v7.1.5.3431.116 (|cFFFFCC00Mar 15th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an issue with bar orientation right to left where fixed bar color isn't working.\n\n|cFFFFFF00-|r The nickname field now use FrizQuadrataTT font and shall be compatible with Cyrillic.\n\n|cFFFFFF00v7.1.5.3418.116 (|cFFFFCC00Mar 1st, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Ticket #167 fix: Light of the Martyr self-damage now does reduce the healing done (following WCL method).\n\n|cFFFFFF00-|r Ticket #169 fix: Damage Prevented is now working for new segments.\n\n|cFFFFFF00-|r Fixed an issue where sometimes BeastMaster's Hati pet wasn't detected correctly.\n\n|cFFFFFF00v7.1.5.3369.116 (|cFFFFCC00Feb 07th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added custom display 'Dynamic Overall Damage' for mythic dungeons.\n\n|cFFFFFF00-|r Fix for Ticket #168: 'Auto Hide While [Not] Inside Instance is broken'.\n\n|cFFFFFF00-|r The bar truncate frame 'DetailsLeftTextAntiTruncate' is now created on Details! load instead on demand.\n\n|cFFFFFF00v7.1.5.3315.116 (|cFFFFCC00Jan 23th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Ticket #162: 'no Monochrome font' available, added an experimental slash command: /run _detalhes:UseOutline ('MONOCHROME').\n\n|cFFFFFF00-|r Ticket #158: 'no elapsed time shown on report to chat', added the elapsed time when reporting a segment.\n\n|cFFFFFF00-|r Ticket #164: 'error when browsing segments', an attempt to fix the problem has been made.\n\n|cFFFFFF00v7.1.5.3305.116 (|cFFFFCC00Jan 15th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Another fix for mythic dungeons overall data reset (thanks Tharai @ Curseforge).\n\n|cFFFFFF00-|r Fix for spec detection on PvP Arenas  (thanks Pas06 @ Curseforge).\n\n|cFFFFFF00v7.1.0.3276.115 (|cFFFFCC00Jan 08th, 2017|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed the overall data not reseting when starting a new mythic+ dungeon.\n\n|cFFFFFF00v7.1.0.3266.115 (|cFFFFCC00Dec 29th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fixed an issue with overall data not updating correctly at the end of the combat.\n\n|cFFFFFF00-|r Added a tutorial line on the window when the user access overall data.\n\n|cFFFFFF00v7.1.0.3236.115 (|cFFFFCC00Dec 19th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Integration with BigWigs should be working okay now.\n\n|cFFFFFF00v7.1.0.3231.115 (|cFFFFCC00Dec 15th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Disabled the link with BigWigs to avoid the 'RegisterMessage' error on every login.\n\n|cFFFFFF00v7.1.0.3229.115 (|cFFFFCC00Dec 09th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r When a window is locked, resize grips shouldn't be enabled messing with bar mouse over.\n\n|cFFFFFF00v7.0.3.3222.115 (|cFFFFCC00November 28th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Added Unstable Affliction to common spells with the same name.\n\n|cFFFFFF00-|r Fixed few issues with built-in plugins.\n\n|cFFFFFF00v7.0.3.3202.115 (|cFFFFCC00November 08th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Weakauras creator from the Encounter Details plugin and '/details forge' shall work correctly now with Trials of Valor.\n\n|cFFFFFF00-|r Raid history should now be recording your Trials of Valor kills.\n\n|cFFFFFF00-|r Added Trials of Valor raid info, good luck and have fun!.\n\n|cFFFFFF00v7.0.3.3201.115 (|cFFFFCC00November 04th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Fix for Paladin holy icon.\n\n|cFFFFFF00-|r Fix for Rogue outlaw icon.\n\n|cFFFFFF00-|r Fixed misc displays with bar sorted by ascending order.\n\n|cFFFFFF00-|r Fix for '/details show' command while the window is on auto hide.\n\n|cFFFFFF00v7.0.3.3114.115 (|cFFFFCC00October 26th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r Encounter Details (plugin): tooltip tutorial is now clamped to screen and its close button should be visible.\n\n|cFFFFFF00-|r Raid Check (plugin): now also works on dungeons.\n\n|cFFFFFF00-|r Added Potion of the Prolongued Power to the tracker.\n\n|cFFFFFF00v7.1.0.3097.115 (|cFFFFCC00October 25th, 2016|r|cFFFFFF00)|r:\n\n|cFFFFFF00-|r renamed 'report history' to 'latest reports'.\n\n|cFFFFFF00-|r attempt to make all Details! users on the party or raid to track rogue's akaari's soul."

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetails!:|r "

	--> startup
		_detalhes.initializing = true
		_detalhes.enabled = true
		_detalhes.__index = _detalhes
		_detalhes._tempo = time()
		_detalhes.debug = false
		_detalhes.debug_chr = false
		_detalhes.opened_windows = 0
		_detalhes.last_combat_time = 0
		
	--> containers
		--> armazenas as fun��es do parser - All parse functions 
			_detalhes.parser = {}
			_detalhes.parser_functions = {}
			_detalhes.parser_frame = CreateFrame ("Frame")
			_detalhes.pvp_parser_frame = CreateFrame ("Frame")
			_detalhes.parser_frame:Hide()
		--> quais raides devem ser guardadas no hist�rico
			_detalhes.InstancesToStoreData = { --> mapIDs
				[1712] = true, --Antorus, the Burning Throne
				--[1676] = true, --Tomb of Sargeras
				--[1648] = true, --Trial of Valor
				--[1530] = true, --Nighthold
				--[1520] = true, --Emerald Nightmare
				--[1448] = true, --Hellfire Citadel
				--[1205] = true, --Blackrock Foundry
				--[1228] = true, --Highmaul
				--[1136] = true, --SoO
			}
		--> armazena os escudos - Shields information for absorbs
			_detalhes.escudos = {}
		--> armazena as fun��es dos frames - Frames functions
			_detalhes.gump = _G ["DetailsFramework"]
			function _detalhes:GetFramework()
				return self.gump
			end
			GameCooltip = GameCooltip2
		--> anima��es dos icones
			_detalhes.icon_animations = {
				load = {
					in_use = {},
					available = {},
				},
			}
		--> armazena as fun��es para inicializa��o dos dados - Metatable functions
			_detalhes.refresh = {}
		--> armazena as fun��es para limpar e guardas os dados - Metatable functions
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
			_detalhes.cache_npc_ids = {}
		--> cache de specs
			_detalhes.cached_specs = {}
			_detalhes.cached_talents = {}
		--> ignored pets
			_detalhes.pets_ignored = {}
			_detalhes.pets_no_owner = {}
			_detalhes.pets_players = {}
		--> armazena as skins dispon�veis para as janelas
			_detalhes.skins = {}
		--> armazena os hooks das fun��es do parser
			_detalhes.hooks = {}
		--> informa��es sobre a luta do boss atual
			_detalhes.encounter_end_table = {}
			_detalhes.encounter_table = {}
			_detalhes.encounter_counter = {}
			_detalhes.encounter_dungeons = {}
		--> informa��es sobre a arena atual
			_detalhes.arena_table = {}
			_detalhes.arena_info = {
				[562] = {file = "LoadScreenBladesEdgeArena", coords = {0, 1, 0.29296875, 0.9375}}, -- Circle of Blood Arena
				[617] = {file = "LoadScreenDalaranSewersArena", coords = {0, 1, 0.29296875, 0.857421875}}, --Dalaran Arena
				[559] = {file = "LoadScreenNagrandArenaBattlegrounds", coords = {0, 1, 0.341796875, 1}}, --Ring of Trials
				[980] = {file = "LoadScreenTolvirArena", coords = {0, 1, 0.29296875, 0.857421875}}, --Tol'Viron Arena
				[572] = {file = "LoadScreenRuinsofLordaeronBattlegrounds", coords = {0, 1, 0.341796875, 1}}, --Ruins of Lordaeron
				[1134] = {file = "LoadingScreen_Shadowpan_bg", coords = {0, 1, 0.29296875, 0.857421875}}, -- Tiger's Peak
				--> legion, thanks @pas06 on curse forge for the mapIds
				[1552] = {file = "LoadingScreen_ArenaValSharah_wide", coords = {0, 1, 0.29296875, 0.857421875}}, -- Ashmane's Fall
				[1504] = {file = "LoadingScreen_BlackrookHoldArena_wide", coords = {0, 1, 0.29296875, 0.857421875}}, --Black Rook Hold 
				
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
			--_detalhes.default_skin_to_use = "Minimalistic"
			_detalhes.default_skin_to_use = "Minimalistic"
			_detalhes.instance_title_text_timer = {}
		--> player detail skin
			_detalhes.playerdetailwindow_skins = {}
		
		--> auto run code
		_detalhes.RunCodeTypes = {
			{Name = "On Initialization", Desc = "Run code when Details! initialize or when a profile is changed.", Value = 1, ProfileKey = "on_init"},
			{Name = "On Zone Changed", Desc = "Run code when the zone where the player is in has changed (e.g. entered in a raid).", Value = 2, ProfileKey = "on_zonechanged"},
			{Name = "On Enter Combat", Desc = "Run code when the player enters in combat.", Value = 3, ProfileKey = "on_entercombat"},
			{Name = "On Leave Combat", Desc = "Run code when the player left combat.", Value = 4, ProfileKey = "on_leavecombat"},
			{Name = "On Spec Change", Desc = "Run code when the player has changed its specialization.", Value = 5, ProfileKey = "on_specchanged"},
		}
		
		--> tooltip
			_detalhes.tooltip_backdrop = {
				bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]], 
				edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], 
				tile = true,
				edgeSize = 16, 
				tileSize = 16, 
				insets = {left = 3, right = 3, top = 4, bottom = 4}
			}
			_detalhes.tooltip_border_color = {1, 1, 1, 1}
			_detalhes.tooltip_spell_icon = {file = [[Interface\CHARACTERFRAME\UI-StateIcon]], coords = {36/64, 58/64, 7/64, 26/64}}
			--_detalhes.tooltip_target_icon = {file = [[Interface\CHARACTERFRAME\UI-StateIcon]], coords = {36/64, 58/64, 7/64, 26/64}}
		
		--> icons
			_detalhes.attribute_icons = [[Interface\AddOns\Details\images\atributos_icones]]
			function _detalhes:GetAttributeIcon (attribute)
				return _detalhes.attribute_icons, 0.125 * (attribute - 1), 0.125 * attribute, 0, 1
			end
			
		--> colors
			_detalhes.default_backdropcolor = {.094117, .094117, .094117, .8}
			_detalhes.default_backdropbordercolor = {0, 0, 0, 1}
			
	--> Plugins
	
		--> plugin templates
	
		_detalhes.gump:NewColor ("DETAILS_PLUGIN_BUTTONTEXT_COLOR", 0.9999, 0.8196, 0, 1)
	
		_detalhes.gump:InstallTemplate ("button", "DETAILS_PLUGINPANEL_BUTTON_TEMPLATE", 
			{
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {0, 0, 0, .5},
				backdropbordercolor = {0, 0, 0, .5},
				onentercolor = {0.3, 0.3, 0.3, .5},
			}
		)
		_detalhes.gump:InstallTemplate ("button", "DETAILS_PLUGINPANEL_BUTTONSELECTED_TEMPLATE", 
			{
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {0, 0, 0, .5},
				backdropbordercolor = {1, 1, 0, 1},
				onentercolor = {0.3, 0.3, 0.3, .5},
			}
		)
		
		_detalhes.gump:InstallTemplate ("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE", 
			{
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {1, 1, 1, .5},
				backdropbordercolor = {0, 0, 0, 1},
				onentercolor = {1, 1, 1, .9},
				textcolor = "DETAILS_PLUGIN_BUTTONTEXT_COLOR",
				textsize = 10,
				width = 120,
				height = 20,
			}
		)
		_detalhes.gump:InstallTemplate ("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE", 
			{
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {1, 1, 1, .5},
				backdropbordercolor = {1, .7, 0, 1},
				onentercolor = {1, 1, 1, .9},
				textcolor = "DETAILS_PLUGIN_BUTTONTEXT_COLOR",
				textsize = 10,
				width = 120,
				height = 20,
			}
		)	
	
		_detalhes.PluginsGlobalNames = {}
		_detalhes.PluginsLocalizedNames = {}
		
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
		--[[global]] DETAILS_HEALTH_POTION_LIST = {
			[188016] = true, --Ancient Healing Potion
			[188018] = true, --Ancient Rejuvenation Potion
			[6262] = true, --warlock's healthstone
		}
		--[[global]] DETAILS_HEALTH_POTION_ID = 188016
		--[[global]] DETAILS_REJU_POTION_ID = 188018	
	
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
			["DEMONHUNTER"] = true,
		}
		_detalhes.classstring_to_classid = {
			["WARRIOR"] = 1,
			["PALADIN"] = 2,
			["HUNTER"] = 3,
			["ROGUE"] = 4,
			["PRIEST"] = 5,
			["DEATHKNIGHT"] = 6,
			["SHAMAN"] = 7,
			["MAGE"] = 8,
			["WARLOCK"] = 9,
			["MONK"] = 10,
			["DRUID"] = 11,
			["DEMONHUNTER"] = 12,
		}
		_detalhes.classid_to_classstring = {
			[1] = "WARRIOR",
			[2] = "PALADIN",
			[3] = "HUNTER",
			[4] = "ROGUE",
			[5] = "PRIEST",
			[6] = "DEATHKNIGHT",
			[7] = "SHAMAN",
			[8] = "MAGE",
			[9] = "WARLOCK",
			[10] = "MONK",
			[11] = "DRUID",
			[12] = "DEMONHUNTER",
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
		_detalhes.PlayerDetailsWindow = _detalhes.janela_info
		
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
--> plugin defaults
	--> backdrop
	_detalhes.PluginDefaults = {}
	
	_detalhes.PluginDefaults.Backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
	insets = {left = 1, right = 1, top = 1, bottom = 1}}
	_detalhes.PluginDefaults.BackdropColor = {0, 0, 0, .6}
	_detalhes.PluginDefaults.BackdropBorderColor = {0, 0, 0, 1}
	
	function _detalhes.GetPluginDefaultBackdrop()
		return _detalhes.PluginDefaults.Backdrop, _detalhes.PluginDefaults.BackdropColor, _detalhes.PluginDefaults.BackdropBorderColor
	end


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
		SharedMedia:Register ("border", "1 Pixel", [[Interface\Buttons\WHITE8X8]])
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
