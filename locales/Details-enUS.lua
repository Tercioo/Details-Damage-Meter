local Loc = LibStub("AceLocale-3.0"):NewLocale("Details", "enUS", true) 
if not Loc then return end 

--------------------------------------------------------------------------------------------------------------------------------------------
	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v1.15.0 - v1.15.3|r:\n\n|cFFFFFF00-|r Damage -> Enemies now also show neutral creatures.\n\n|cFFFFFF00-|r Added support to dungeons, bosses and trash mobs are now recognized.\n\n|cFFFFFF00-|r Added target information for each spell in Player Detail Window.\n\n|cFFFFFF00-|r Added options for change the location of tooltips.\n\n|cFFFFFF00-|r Added options for change the Overall Data functionality.\n\n|cFFFFFF00-|r Added tooltips for lock and detach buttons.\n\n|cFFFFFF00-|r Added new row texture: Details Vidro.\n\n|cFFFFFF00-|r Revamp on death log tooltips.\n\n|cFFFFFF00-|r Improved the visual effect for the instance which current moving window can snap to.\n\n|cFFFFFF00v1.14.5 - 1.14.6\n\n|cFFFFFF00-|r Added option for lock segments display, so, when a segment is chosen, the other windows also change it.\n\n|cFFFFFF00-|r Added option for show the total amount of spells, targets and pets in tooltips.\n\n|cFFFFFF00-|r Finished another revamp on options panel.\n\n|cFFFFFF00-|r Now its possible open more then 1 Raid Plugins at once on diferent windows.\n\n|cFFFFFF00-|r Added a large text editor for make changes on custom texts.\n\n|cFFFFFF00-|r Added new option for enable borders on the bars.\n\n|cFFFFFF00-|r Added Death Barrier as a absorb spell.\n\n|cFFFFFF00-|r Fixed a bug on overheal tooltip where was showing the Hps instead of overheal.\n\n|cFFFFFF00v1.14.0 - v1.14.0b\n\n|cFFFFFF00-|r Added a new tab on options panel for tooltip configuration.\n\n|cFFFFFF00-|r Added a new tab on options panel for broker config.\n\n|cFFFFFF00-|r Added new abbreviation method called comma.\n\n|cFFFFFF00-|r All instances now have a delete button.\n\n|cFFFFFF00-|r Full re-write on the instance, delete and close buttons.\n\n|cFFFFFF00-|r HotCorners now sort icons according with most used.\n\n|cFFFFFF00-|r Few changes on all skins in order to fit on the new right menu buttons.\n\n|cFFFFFF00-|r Added Horde avatars.\n\n|cFFFFFF00-|r Fixed issue where shortcut panel shows below thw windows when its in Dialog strata.\n\n|cFFFFFF00v1.13.8 - v1.13.8a\n\n|cFFFFFF00-|r Fixed issue with Vanguard where it wasn't showing debuffs stacks on the tanks if you are a healer os dps.\n\n|cFFFFFF00-|r Added option for put stretch button on the fullscreen strata which makes it always on top of others frames.\n\n|cFFFFFF00-|r Added background and dialog stratas.\n\n|cFFFFFF00-|r Added option for percentage: follow the combat totals or the first player total.\n\n|cFFFFFF00-|r Added option for show or hide the left buttons on menu bar.\n\n|cFFFFFF00-|r Added option for change the left buttons size in the menu bar.\n\n|cFFFFFF00-|r Added option for delete a instance.\n\n|cFFFFFF00-|r Instance Segment Mini display now is more accuracy about telling the enemy in the segment.\n\n|cFFFFFF00-|r Player Details Window now show all pet abilities instead of just the total pet damage.\n\n|cFFFFFF00-|r Rework done on report texts, now the title is more shorter and also format Dps and Hps numbers.\n\n|cFFFFFF00-|r Simple Gray and again ElvUI skins got some rework.\n\n|cFFFFFF00-|r Lib HotCorner now is data broker based and shows up all broker plugins in the bar.\n\n|cFFFFFF00v1.13.5 / v1.13.5a|r\n\n|cFFFFFF00-|r Added keybinds to reset segments and scroll up/down.\n\n|cFFFFFF00-|r Added Spell Customization options where icon and the name of a spell can be changed.\n\n|cFFFFFF00-|r Added option to change the micro displays side, now it can be shown on the window top side.\n\n|cFFFFFF00-|r Micro Displays, also, should now give less problems and be more dynamic.\n\n|cFFFFFF00-|r Added options to change the transparency when out of combat and out of a group.\n\n|cFFFFFF00-|r Added and Still under development the panel for create data captures for charts.\n\n|cFFFFFF00-|r Fixed a issue with flat skin where the close button was just too big.\n\n|cFFFFFF00v1.13.0|r\n\n|cFFFFFF00-|r Added four more abbreviation types.\n\n|cFFFFFF00-|r Fixed issue where the instance menu wasnt respecting the amount limit of instances.\n\n|cFFFFFF00-|r Added options for cutomize the right text of a row.\n\n|cFFFFFF00-|r Added a option to be able to chance the framestrata of an window.\n\n|cFFFFFF00-|r Added shift, ctrl, alt interaction for rows which shows all spells, targets or pets when pressed.\n\n|cFFFFFF00-|r Fixed a issue where changing the alpha of a window makes it disappear on the next logon.\n\n|cFFFFFF00-|r Added a option for auto transparency to ignore rows.\n\n|cFFFFFF00-|r Added option to be able to set shadow on the attribute text.\n\n|cFFFFFF00-|r Fixed a issue with window snap where disabled statusbar makes a gap between the windows.\n\n|cFFFFFF00-|r Added a hidden menu on the top left corner (experimental).\n\n|cFFFFFF00v1.12.3|r\n\n|cFFFFFF00-|r - Fixed 'Healing Per Second' which wasn't working at all.\n\n|cFFFFFF00-|r - Fixed the percent amount for target of damage done where sometimes it pass 100%.\n\n|cFFFFFF00-|r - Changes on Skins: 'Minimalistic' and 'Elm UI Frame Style'. It's necessary re-apply.\n\n|cFFFFFF00-|r - Added more cooldowns and spells for Monk tank over avoidance panel.\n\n|cFFFFFF00-|r - Player avatar now is also shown on the Player Details window.\n\n|cFFFFFF00-|r - Leaving empty the the icon file box, make details use no icons on bars."

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetails:|r " --> color and details name

	Loc ["STRING_YES"] = "Yes"
	Loc ["STRING_NO"] = "No"
	
	Loc ["STRING_TOP"] = "top"
	Loc ["STRING_BOTTOM"] = "bottom"
	Loc ["STRING_AUTO"] = "auto"
	Loc ["STRING_LEFT"] = "left"
	Loc ["STRING_CENTER"] = "center"
	Loc ["STRING_RIGHT"] = "right"
	
	Loc ["STRING_MINIMAP_TOOLTIP1"] = "|cFFCFCFCFleft click|r: open options panel"
	Loc ["STRING_MINIMAP_TOOLTIP11"] = "|cFFCFCFCFleft click|r: clear all segments"
	Loc ["STRING_MINIMAP_TOOLTIP2"] = "|cFFCFCFCFright click|r: quick menu"
	
	Loc ["STRING_MINIMAPMENU_NEWWINDOW"] = "Create New Window"
	Loc ["STRING_MINIMAPMENU_RESET"] = "Reset"
	Loc ["STRING_MINIMAPMENU_REOPEN"] = "Reopen Window"
	Loc ["STRING_MINIMAPMENU_REOPENALL"] = "Reopen All"
	Loc ["STRING_MINIMAPMENU_UNLOCK"] = "Unlock"
	Loc ["STRING_MINIMAPMENU_LOCK"] = "Lock"
	
	Loc ["STRING_WINDOW_MENU_UNLOCKED"] = "Left menu unlocked, set Menu Pos X > 20 over options panel to lock again."
	
	Loc ["STRING_RESETBUTTON_WRONG_INSTANCE"] = "Warning, reset button isn't in the current editing instance."
	
	Loc ["STRING_INTERFACE_OPENOPTIONS"] = "Open Options Panel"
		
	Loc ["STRING_RIGHTCLICK_TYPEVALUE"] = "right click to type the value"
	Loc ["STRING_TOOOLD"] = "could not be installed because your Details! version is too old."
	Loc ["STRING_TOOOLD2"] = "your Details! version isn't the same."
	Loc ["STRING_CHANGED_TO_CURRENT"] = "Segment changed to current"
	Loc ["STRING_SEGMENT_TRASH"] = "Trash Cleanup"
	Loc ["STRING_VERSION_UPDATE"] = "new version: what's changed? click here"
	Loc ["STRING_NEWS_TITLE"] = "What's New In This Version"
	Loc ["STRING_NEWS_REINSTALL"] = "Found problems after a update? try '/details reinstall' command."
	Loc ["STRING_TIME_OF_DEATH"] = "Death"
	Loc ["STRING_SHORTCUT_RIGHTCLICK"] = "Shortcut Menu (right click to close)"
	
	Loc ["STRING_NO_DATA"] = "data already has been cleaned"
	Loc ["STRING_ISA_PET"] = "This Actor is a Pet"
	Loc ["STRING_EQUILIZING"] = "Sharing encounter data"
	Loc ["STRING_LEFT_CLICK_SHARE"] = "Left click to report."
	
	Loc ["STRING_REPORT_BUTTON_TOOLTIP"] = "Click to open Report Dialog"
	
	Loc ["STRING_LAST_COOLDOWN"] = "last cooldown used"
	Loc ["STRING_NOLAST_COOLDOWN"] = "no cooldown used"
	
	Loc ["STRING_ATACH_DESC"] = "Window #%d attaches with the window #%d."
	Loc ["STRING_DETACH_DESC"] = "Detach windows"
	Loc ["STRING_LOCK_DESC"] = "Lock or unlock the window"
	
	Loc ["STRING_INSTANCE_LIMIT"] = "max instance number has been reached, you can modify this limit on options panel."
	
	Loc ["STRING_PLEASE_WAIT"] = "Please wait"
	Loc ["STRING_UPTADING"] = "updating"
	
	Loc ["STRING_RAID_WIDE"] = "[*] raid wide cooldown"
	
	Loc ["STRING_RIGHTCLICK_CLOSE_SHORT"] = "Right click to close."
	Loc ["STRING_RIGHTCLICK_CLOSE_MEDIUM"] = "Use right click to close this window."
	Loc ["STRING_RIGHTCLICK_CLOSE_LARGE"] = "Click with right mouse button to close this window."

	
	Loc ["STRING_EMPTY_SEGMENT"] = "Empty Segment"
	
	
--> Slash
	Loc ["STRING_COMMAND_LIST"] = "command list"
	
	Loc ["STRING_SLASH_SHOW"] = "show"
	Loc ["STRING_SLASH_SHOW_DESC"] = "open a details window if none."
	
	Loc ["STRING_SLASH_DISABLE"] = "disable"
	Loc ["STRING_SLASH_DISABLE_DESC"] = "turn off all captures of data."
	Loc ["STRING_SLASH_CAPTUREOFF"] = "all captures has been turned off."
	
	Loc ["STRING_SLASH_ENABLE"] = "enable"
	Loc ["STRING_SLASH_ENABLE_DESC"] = "turn on all captures of data."
	Loc ["STRING_SLASH_CAPTUREON"] = "all captures has been turned on."
	
	Loc ["STRING_SLASH_OPTIONS"] = "options"
	Loc ["STRING_SLASH_OPTIONS_DESC"] = "open the options panel."
	
	Loc ["STRING_SLASH_NEW"] = "new"
	Loc ["STRING_SLASH_NEW_DESC"] = "open or reopen a instance."
	
	Loc ["STRING_SLASH_CHANGES"] = "updates"
	Loc ["STRING_SLASH_CHANGES_DESC"] = "shows up the latest changes made on this version."
	
	Loc ["STRING_SLASH_WORLDBOSS"] = "worldboss"
	Loc ["STRING_SLASH_WORLDBOSS_DESC"] = "run a macro showing which boss you killed this week."
	Loc ["STRING_KILLED"] = "Killed"
	Loc ["STRING_ALIVE"] = "Alive"
	
	Loc ["STRING_SLASH_WIPECONFIG"] = "reinstall"
	Loc ["STRING_SLASH_WIPECONFIG_DESC"] = "set Details! configuration to defaults for this character, use this if Details! aren't working properlly."
	Loc ["STRING_SLASH_WIPECONFIG_CONFIRM"] = "Click To Continue With The Reinstall"

--> StatusBar Plugins
	Loc ["STRING_STATUSBAR_NOOPTIONS"] = "This widget doesn't have options."

--> Fights and Segments

	Loc ["STRING_SEGMENT"] = "Segment"
	Loc ["STRING_SEGMENT_LOWER"] = "segment"
	Loc ["STRING_SEGMENT_EMPTY"] = "this segment is empty"
	Loc ["STRING_SEGMENT_START"] = "Start"
	Loc ["STRING_SEGMENT_END"] = "End"
	Loc ["STRING_SEGMENT_ENEMY"] = "Enemy"
	Loc ["STRING_SEGMENT_TIME"] = "Time"
	Loc ["STRING_SEGMENT_OVERALL"] = "Current Segments Overall"
	Loc ["STRING_TOTAL"] = "Total"
	Loc ["STRING_OVERALL"] = "Overall"
	Loc ["STRING_CURRENT"] = "Current"
	Loc ["STRING_CURRENTFIGHT"] = "Current Fight"
	Loc ["STRING_FIGHTNUMBER"] = "Fight #"
	Loc ["STRING_UNKNOW"] = "Unknown"
	Loc ["STRING_AGAINST"] = "against"

--> Custom Window

	Loc ["STRING_CUSTOM_REMOVE"] = "Remove"
	Loc ["STRING_CUSTOM_BROADCAST"] = "Shout"
	Loc ["STRING_CUSTOM_NAME"] = "Custom Name"
	Loc ["STRING_CUSTOM_SPELLID"] = "Spell Id"
	Loc ["STRING_CUSTOM_SOURCE"] = "Source"
	Loc ["STRING_CUSTOM_TARGET"] = "Target"
	Loc ["STRING_CUSTOM_TOOLTIPNAME"] = "Insert here the name of your custom display.\nAllow letters and numbers, minimum of 5 characters and 32 max."
	Loc ["STRING_CUSTOM_TOOLTIPSPELL"] = "Select a boss ability from the menu on the right\nor type the spell name to filter."
	Loc ["STRING_CUSTOM_TOOLTIPSOURCE"] = "Spell source allow (with brackets):\n|cFF00FF00[all]|r: Search for spell in all Actors.\n|cFFFF9900[raid]|r: Search only in your raid or party members.\n|cFF33CCFF[player]|r: Check only you\nAny other text will be considered an spesific Actor name."
	Loc ["STRING_CUSTOM_TOOLTIPTARGET"] = "Insert the ability (player, monster, boss) target name."
	Loc ["STRING_CUSTOM_TOOLTIPNOTWORKING"] = "Ouch, some gnome engineer touched this and broke it =("
	Loc ["STRING_CUSTOM_BROADCASTSENT"] = "Sent"
	Loc ["STRING_CUSTOM_CREATED"] = "The new display has been created."
	Loc ["STRING_CUSTOM_ICON"] = "Icon"
	Loc ["STRING_CUSTOM_CREATE"] = "Create"
	Loc ["STRING_CUSTOM_INCOMBAT"] = "You are in combat."
	Loc ["STRING_CUSTOM_NOATTRIBUTO"] = "No attribute has been selected."
	Loc ["STRING_CUSTOM_SHORTNAME"] = "Name need at least 5 characters."
	Loc ["STRING_CUSTOM_LONGNAME"] = "Name too long, maximum allowed 32 characters."
	Loc ["STRING_CUSTOM_NOSPELL"] = "Spell field cannot be empty."
	Loc ["STRING_CUSTOM_HELP1"] = "When you mouse over the Remove button, a menu is shown asking which one of previously created customs you want to erase.\n\nThe send button shows up a menu for broadcast your custom to your raid group."
	Loc ["STRING_CUSTOM_HELP2"] = "Choose here the attribute type of the spell, if your spell is a Healing spell, you may click on Heal."
	Loc ["STRING_CUSTOM_HELP3"] = "Custom name will be used on Details attribute menu, and also, shown when reporting.\n\nOn spell id field, type some letters to filter spell names, you can also choose a spell from encounter menu on the right.\n\nOver source field, type where Details will serach for the spell, more info at his tooltip."
	Loc ["STRING_CUSTOM_HELP4"] = "You can choose a spell from a raid encounter, mouse over this button and the options will be shown to you."
	Loc ["STRING_CUSTOM_ACCETP_CUSTOM"] = "sent a custom display to you, Do you want add this to your custom library?"

--> Switch Window

	Loc ["STRING_SWITCH_CLICKME"] = "left click me"
	
--> Mode Names

	Loc ["STRING_MODE_GROUP"] = "Group & Raid"
	Loc ["STRING_MODE_ALL"] = "Everything"
	
	Loc ["STRING_MODE_SELF"] = "Plugins: Solo Play"
	Loc ["STRING_MODE_RAID"] = "Plugins: Raid"
	Loc ["STRING_MODE_PLUGINS"] = "plugins"
	
	Loc ["STRING_OPTIONS_WINDOW"] = "Options Panel"
	
--> Wait Messages
	
	Loc ["STRING_NEWROW"] = "waiting refresh..."
	Loc ["STRING_WAITPLUGIN"] = "waiting for\nplugins"
	
--> Cooltip
	
	Loc ["STRING_COOLTIP_NOOPTIONS"] = "no options"

--> Attributes	

	Loc ["STRING_ATTRIBUTE_DAMAGE"] = "Damage"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DONE"] = "Damage Done"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DPS"] = "DPS"
		Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"] = "Damage Taken"
		Loc ["STRING_DAMAGE_TAKEN_FROM"] = "Damage Taken From"
		Loc ["STRING_DAMAGE_TAKEN_FROM2"] = "applied damage with"
		Loc ["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] = "Friendly Fire"
		Loc ["STRING_ATTRIBUTE_DAMAGE_FRAGS"] = "Frags"
		Loc ["STRING_ATTRIBUTE_DAMAGE_ENEMIES"] = "Enemies"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS"] = "Auras & Voidzones"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS_REPORT"] = "Debuff Damage and Uptime"
	
	Loc ["STRING_ATTRIBUTE_HEAL"] = "Heal"
		Loc ["STRING_ATTRIBUTE_HEAL_DONE"] = "Healing Done"
		Loc ["STRING_ATTRIBUTE_HEAL_HPS"] = "HPS"
		Loc ["STRING_ATTRIBUTE_HEAL_OVERHEAL"] = "Overhealing"
		Loc ["STRING_ATTRIBUTE_HEAL_TAKEN"] = "Healing Taken"
		Loc ["STRING_ATTRIBUTE_HEAL_ENEMY"] = "Enemy Healed"
		Loc ["STRING_ATTRIBUTE_HEAL_PREVENT"] = "Damage Prevented"
	
	Loc ["STRING_ATTRIBUTE_ENERGY"] = "Energy"
		Loc ["STRING_ATTRIBUTE_ENERGY_MANA"] = "Mana Restored"
		Loc ["STRING_ATTRIBUTE_ENERGY_RAGE"] = "Rage Generated"
		Loc ["STRING_ATTRIBUTE_ENERGY_ENERGY"] = "Energy Generated"
		Loc ["STRING_ATTRIBUTE_ENERGY_RUNEPOWER"] = "Runic Power Generated"
	
	Loc ["STRING_ATTRIBUTE_MISC"] = "Miscellaneous"
		Loc ["STRING_ATTRIBUTE_MISC_CCBREAK"] = "CC Breaks"
		Loc ["STRING_ATTRIBUTE_MISC_RESS"] = "Ress"
		Loc ["STRING_ATTRIBUTE_MISC_INTERRUPT"] = "Interrupts"
		Loc ["STRING_ATTRIBUTE_MISC_DISPELL"] = "Dispells"
		Loc ["STRING_ATTRIBUTE_MISC_DEAD"] = "Deaths"
		Loc ["STRING_ATTRIBUTE_MISC_DEFENSIVE_COOLDOWNS"] = "Cooldowns"
		Loc ["STRING_ATTRIBUTE_MISC_BUFF_UPTIME"] = "Buff Uptime"
		Loc ["STRING_ATTRIBUTE_MISC_DEBUFF_UPTIME"] = "Debuff Uptime"
		
	Loc ["STRING_ATTRIBUTE_CUSTOM"] = "Custom"

--> Tooltips & Info Box	

	Loc ["STRING_SPELLS"] = "Spells"
	Loc ["STRING_NO_SPELL"] = "no spell has been used"
	Loc ["STRING_TARGET"] = "Target"
	Loc ["STRING_TARGETS"] = "Targets"
	Loc ["STRING_FROM"] = "From"
	Loc ["STRING_PET"] = "Pet"
	Loc ["STRING_PETS"] = "Pets"
	Loc ["STRING_DPS"] = "Dps"
	Loc ["STRING_SEE_BELOW"] = "see below"
	Loc ["STRING_GERAL"] = "General"
	Loc ["STRING_PERCENTAGE"] = "Percentage"
	Loc ["STRING_MEDIA"] = "Media"
	Loc ["STRING_HITS"] = "Hits"
	Loc ["STRING_DAMAGE"] = "Damage"
	Loc ["STRING_NORMAL_HITS"] = "Normal Hits"
	Loc ["STRING_CRITICAL_HITS"] = "Critical Hits"
	Loc ["STRING_MINIMUM"] = "Minimum"
	Loc ["STRING_MAXIMUM"] = "Maximum"
	Loc ["STRING_DEFENSES"] = "Defenses"
	Loc ["STRING_GLANCING"] = "Glancing"
	Loc ["STRING_RESISTED"] = "Resisted"
	Loc ["STRING_ABSORBED"] = "Absorbed"
	Loc ["STRING_BLOCKED"] = "Blocked"
	Loc ["STRING_FAIL_ATTACKS"] = "Attack Failures"
	Loc ["STRING_MISS"] = "Miss"
	Loc ["STRING_PARRY"] = "Parry"
	Loc ["STRING_DODGE"] = "Dodge"
	Loc ["STRING_DAMAGE_FROM"] = "Took damage from"
	Loc ["STRING_HEALING_FROM"] = "Healing received from"
	Loc ["STRING_HEALING_HPS_FROM"] = "HPS received from"
	Loc ["STRING_DAMAGE_DPS_IN"] = "DPS received from"
	Loc ["STRING_PLAYERS"] = "Players"
	
	Loc ["STRING_NO_TARGET_BOX"] = "No Targets Avaliable"
	Loc ["STRING_NO_TARGET"] = "No target found."
	Loc ["STRING_MORE_INFO"] = "See right box for more info."
	
	Loc ["STRING_VOIDZONE_TOOLTIP"] = "Damage and Time:"
	
	Loc ["STRING_HPS"] = "Hps"
	Loc ["STRING_HEAL"] = "Heal"
	Loc ["STRING_HEAL_CRIT"] = "Heal Critical"
	Loc ["STRING_HEAL_ABSORBED"] = "Heal absorbed"
	Loc ["STRING_OVERHEAL"] = "Overheal"
	Loc ["STRING_OVERHEALED"] = "Overhealed"
	Loc ["STRING_"] = ""
	
----------------	
--> BuiltIn Plugins

	Loc ["STRING_PLUGIN_MINSEC"] = "Minutes & Seconds"
	Loc ["STRING_PLUGIN_SECONLY"] = "Seconds Only"
	Loc ["STRING_PLUGIN_TIMEDIFF"] = "Last Combat Difference"
	
	Loc ["STRING_PLUGIN_SEGMENTTYPE_1"] = "Fight #X"
	Loc ["STRING_PLUGIN_SEGMENTTYPE_2"] = "Encounter Name"
	Loc ["STRING_PLUGIN_SEGMENTTYPE_3"] = "Encounter Name Plus Segment"
	
	Loc ["STRING_PLUGIN_TOOLTIP_LEFTBUTTON"] = "Config current plugin"
	Loc ["STRING_PLUGIN_TOOLTIP_RIGHTBUTTON"] = "Choose another plugin"

	Loc ["STRING_PLUGIN_CLOCKTYPE"] = "Clock Type"
	Loc ["STRING_PLUGIN_SEGMENTTYPE"] = "Segment Type"
	
	Loc ["STRING_PLUGIN_DURABILITY"] = "Durability"
	Loc ["STRING_PLUGIN_LATENCY"] = "Latency"
	Loc ["STRING_PLUGIN_GOLD"] = "Gold"
	Loc ["STRING_PLUGIN_FPS"] = "Framerate"
	Loc ["STRING_PLUGIN_TIME"] = "Clock"
	Loc ["STRING_PLUGIN_CLOCKNAME"] = "Encounter Time"
	Loc ["STRING_PLUGIN_PSEGMENTNAME"] = "Instance Segment"
	Loc ["STRING_PLUGIN_PDPSNAME"] = "Raid Dps"
	Loc ["STRING_PLUGIN_THREATNAME"] = "My Threat"
	Loc ["STRING_PLUGIN_PATTRIBUTENAME"] = "Attribute"
	Loc ["STRING_PLUGIN_CLEAN"] = "None"
	
	Loc ["STRING_PLUGINOPTIONS_COMMA"] = "Comma"
	Loc ["STRING_PLUGINOPTIONS_ABBREVIATE"] = "Abbreviate"
	Loc ["STRING_PLUGINOPTIONS_NOFORMAT"] = "None"
	
	Loc ["STRING_PLUGINOPTIONS_TEXTSTYLE"] = "Text Style"
	Loc ["STRING_PLUGINOPTIONS_TEXTCOLOR"] = "Text Color"
	Loc ["STRING_PLUGINOPTIONS_TEXTSIZE"] = "Font Size"
	Loc ["STRING_PLUGINOPTIONS_TEXTALIGN"] = "Text Align"
	
	Loc ["STRING_PLUGINOPTIONS_FONTFACE"] = "Select Font Style"
	Loc ["STRING_PLUGINOPTIONS_TEXTALIGN_X"] = "Text Align X"
	Loc ["STRING_PLUGINOPTIONS_TEXTALIGN_Y"] = "Text Align Y"
	
	Loc ["STRING_OPTIONS_COLORANDALPHA"] = "Color & Alpha"
	Loc ["STRING_OPTIONS_COLORFIXED"] = "Fixed Color"
	Loc ["STRING_OPTIONS_COLOR"] = "Color"
	
	Loc ["STRING_OPTIONS_SIZE"] = "Size"
	Loc ["STRING_OPTIONS_ANCHOR"] = "Side"


	Loc ["ABILITY_ID"] = "ability id"
	
--> Details Instances

	Loc ["STRING_SOLO_SWITCHINCOMBAT"] = "Cannot switch while in combat"
	Loc ["STRING_CUSTOM_NEW"] = "Create New"
	Loc ["STRING_CUSTOM_REPORT"] = "(custom)"
	Loc ["STRING_REPORT"] = "for"
	Loc ["STRING_REPORT_LEFTCLICK"] = "Click to open report dialog"
	Loc ["STRING_REPORT_FIGHT"] = "fight"
	Loc ["STRING_REPORT_LAST"] = "Last" -- >last< 3 fights
	Loc ["STRING_REPORT_FIGHTS"] = "fights" -- last 3 >fights<
	Loc ["STRING_REPORT_LASTFIGHT"] = "last fight"
	Loc ["STRING_REPORT_PREVIOUSFIGHTS"] = "previous fights"
	Loc ["STRING_REPORT_INVALIDTARGET"] = "Whisper target not found"
	Loc ["STRING_REPORT_SINGLE_DEATH"] = "death details of"
	Loc ["STRING_REPORT_SINGLE_COOLDOWN"] = "cooldowns used by"
	Loc ["STRING_REPORT_SINGLE_BUFFUPTIME"] = "buff uptime for"
	Loc ["STRING_REPORT_SINGLE_DEBUFFUPTIME"] = "debuff uptime for"
	Loc ["STRING_NOCLOSED_INSTANCES"] = "There is no closed windows,\nclick to open a new one."
	
--> report frame

	Loc ["STRING_REPORTFRAME_PARTY"] = "Party"
	Loc ["STRING_REPORTFRAME_RAID"] = "Raid"
	Loc ["STRING_REPORTFRAME_GUILD"] = "Guild"
	Loc ["STRING_REPORTFRAME_OFFICERS"] = "Officer Channel"
	Loc ["STRING_REPORTFRAME_WHISPER"] = "Whisper"
	Loc ["STRING_REPORTFRAME_WHISPERTARGET"] = "Whisper Target"
	Loc ["STRING_REPORTFRAME_COPY"] = "Copy & Paste"
	Loc ["STRING_REPORTFRAME_SAY"] = "Say"
	Loc ["STRING_REPORTFRAME_LINES"] = "Lines"
	Loc ["STRING_REPORTFRAME_INSERTNAME"] = "insert player name"
	Loc ["STRING_REPORTFRAME_CURRENT"] = "Current"
	Loc ["STRING_REPORTFRAME_REVERT"] = "Reverse"
	Loc ["STRING_REPORTFRAME_REVERTED"] = "reversed"
	Loc ["STRING_REPORTFRAME_CURRENTINFO"] = "Display only data which are current being shown (if supported)."
	Loc ["STRING_REPORTFRAME_REVERTINFO"] = "Reverse result, showing in ascending order (if supported)."
	Loc ["STRING_REPORTFRAME_WINDOW_TITLE"] = "Create Report"
	Loc ["STRING_REPORTFRAME_SEND"] = "Send"

--> player details frame

	Loc ["STRING_ACTORFRAME_NOTHING"] = "nothing to report"
	Loc ["STRING_ACTORFRAME_REPORTTO"] = "report for"
	Loc ["STRING_ACTORFRAME_REPORTTARGETS"] = "report for targets of"
	Loc ["STRING_ACTORFRAME_REPORTOF"] = "of"
	Loc ["STRING_ACTORFRAME_REPORTAT"] = "at"
	Loc ["STRING_ACTORFRAME_SPELLUSED"] = "All spells used"
	Loc ["STRING_ACTORFRAME_SPELLDETAILS"] = "Spell details"
	Loc ["STRING_MASTERY"] = "Mastery"
	
--> Main Window

	Loc ["STRING_ERASE_IN_COMBAT"] = "Schedule overall wipe after this combat."
	
	Loc ["STRING_LOCK_WINDOW"] = "lock"
	Loc ["STRING_UNLOCK_WINDOW"] = "unlock"
	Loc ["STRING_ERASE"] = "delete"
	Loc ["STRING_ERASE_DATA"] = "Reset All Data"
	Loc ["STRING_ERASE_DATA_OVERALL"] = "Reset Overall Data"
	Loc ["STRING_UNLOCK"] = "Spread out instances\n in this button"
	Loc ["STRING_PLUGIN_NAMEALREADYTAKEN"] = "Details! can't install plugin because his name already has been taken"
	Loc ["STRING_RESIZE_COMMON"] = "Resize\n"
	Loc ["STRING_RESIZE_HORIZONTAL"] = "Resize the width off all\n windows in the cluster"
	Loc ["STRING_RESIZE_VERTICAL"] = "Resize the heigth off all\n windows in the cluster"
	Loc ["STRING_RESIZE_ALL"] = "Freely resize all windows"
	Loc ["STRING_FREEZE"] = "This segment is not available at the moment"
	Loc ["STRING_CLOSEALL"] = "All Details windows are close, Type '/details new' to re-open."
	
	Loc ["STRING_HELP_MENUS"] = "Gear Menu: changes the game mode.\nSolo: tools where you can play by your self.\nGroup: display only actors which make part of your group.\nAll: show everything.\nRaid: assistance tools for raid or pvp groups.\n\nBook Menu: Change the segment, in Details! segments are dynamic and the instances change the displaying encounter data when a fight finishes.\n\nSword Menu: Change the attribute which this instance shown."
	Loc ["STRING_HELP_ERASE"] = "Remove all segments stored."
	Loc ["STRING_HELP_INSTANCE"] = "Click: open a new instance (window).\n\nMouse over: display a menu with all closed instances, you can reopen anyone at any time."
	Loc ["STRING_HELP_STATUSBAR"] = "Statusbar can hold three plugins: one in left, another in the center and right side.\n\nRight click: select another plugin to show.\n\nLeft click: open the options window."
	Loc ["STRING_HELP_SWITCH"] = "Right click: shows up the fast switch panel.\n\nLeft click on a switch option: change the instance (window) attribute.\nRight click: closes switch.\n\nYou can right click over icons to choose another attribute."
	Loc ["STRING_HELP_RESIZE"] = "Resize and lock buttons."
	Loc ["STRING_HELP_STRETCH"] = "Click, hold and pull to stretch the window."
	
	Loc ["STRING_HELP_MODESELF"] = "The self mode plugins are intended to focus only on you. Use the sword menu to choose which plugin you want to use."
	Loc ["STRING_HELP_MODEGROUP"] = "Use this option to display only you or players which are in your group or raid."
	Loc ["STRING_HELP_MODEALL"] = "This mode will show every player, npc, boss with data captured by Details!."
	Loc ["STRING_HELP_MODERAID"] = "The raid mode is the opposite of self mode, this plugins are intended to work with data captured from your group. You can change the plugin on sword menu."
	
--> misc
	
	Loc ["STRING_PLAYER_DETAILS"] = "Player Details"
	Loc ["STRING_MELEE"] = "Melee"
	Loc ["STRING_AUTOSHOT"] = "Auto Shot"
	Loc ["STRING_DOT"] = " (DoT)"
	Loc ["STRING_UNKNOWSPELL"] = "Unknow Spell"
	
	Loc ["STRING_CCBROKE"] = "Crowd Control Removed"
	Loc ["STRING_DISPELLED"] = "Buffs/Debuffs Removed"
	Loc ["STRING_SPELL_INTERRUPTED"] = "Spells interrupted"
	
	
	
-- OPTIONS PANEL -----------------------------------------------------------------------------------------------------------------

	Loc ["STRING_MUSIC_DETAILS_ROBERTOCARLOS"] = "There's no use trying to forget\nFor a long time in your life I will live\nDetails as small of us"

	Loc ["STRING_OPTIONS_COMBATTWEEKS"] = "Combat Tweeks"
	Loc ["STRING_OPTIONS_COMBATTWEEKS_DESC"] = "Behavioral adjustments on how Details! deal with some combat aspects."

	Loc ["STRING_OPTIONS_PROFILE_LOADED"] = "Profile loaded:"
	Loc ["STRING_OPTIONS_PROFILE_FIELDEMPTY"] = "Name field is empty."
	Loc ["STRING_OPTIONS_PROFILE_NOTCREATED"] = "Profile not created."
	Loc ["STRING_OPTIONS_PROFILE_COPYOKEY"] = "Profile successful copied."
	Loc ["STRING_OPTIONS_PROFILE_REMOVEOKEY"] = "Profile successful removed."
	Loc ["STRING_OPTIONS_PROFILE_SELECT"] = "select a profile."
	

	
	Loc ["STRING_OPTIONS_EXTERNALS_TITLE"] = "Externals Widgets"
	Loc ["STRING_OPTIONS_EXTERNALS_TITLE2"] = "This options controls the behavior of many foreign widgets."
	
	Loc ["STRING_OPTIONS_SWITCHINFO"] = "|cFFF79F81 LEFT DISABLED|r  |cFF81BEF7 RIGHT ENABLED|r"
	
	Loc ["STRING_OPTIONS_PICKCOLOR"] = "color"
	Loc ["STRING_OPTIONS_EDITIMAGE"] = "Edit Image"
	
	Loc ["STRING_OPTIONS_PRESETTOOLD"] = "This preset is too old and cannot be loaded at this version of Details!."
	Loc ["STRING_OPTIONS_PRESETNONAME"] = "Give a name to your preset."
	
	Loc ["STRING_OPTIONS_EDITINSTANCE"] = "Editing Instance:"
	Loc ["STRING_OPTIONS_INSTANCES"] = "Instances:"
	
	Loc ["STRING_OPTIONS_INSTANCE_DELETE"] = "Delete"
	Loc ["STRING_OPTIONS_INSTANCE_DELETE_DESC"] = "Remove permanently a instance window.\nYour game screen may reload during the erase process."
	
	Loc ["STRING_OPTIONS_GENERAL"] = "General Settings"
	Loc ["STRING_OPTIONS_APPEARANCE"] = "Appearance"
	Loc ["STRING_OPTIONS_PERFORMANCE"] = "Performance"
	Loc ["STRING_OPTIONS_PLUGINS"] = "Plugins"
	Loc ["STRING_OPTIONS_ADVANCED"] = "Advanced"

	
	Loc ["STRING_OPTIONS_PLUGINS_TOOLBAR_ANCHOR"] = "Toolbar Plugins"
	Loc ["STRING_OPTIONS_PLUGINS_RAID_ANCHOR"] = "Raid Plugins"
	Loc ["STRING_OPTIONS_PLUGINS_SOLO_ANCHOR"] = "Solo Plugins"
	Loc ["STRING_OPTIONS_PLUGINS_NAME"] = "Name"
	Loc ["STRING_OPTIONS_PLUGINS_AUTHOR"] = "Author"
	Loc ["STRING_OPTIONS_PLUGINS_VERSION"] = "Version"
	Loc ["STRING_OPTIONS_PLUGINS_ENABLED"] = "Enabled"
	
	Loc ["STRING_OPTIONS_MINIMAP_ANCHOR"] = "Minimap:"
	Loc ["STRING_OPTIONS_MINIMAP"] = "Show Icon"
	Loc ["STRING_OPTIONS_MINIMAP_DESC"] = "Show or Hide minimap icon."
	Loc ["STRING_OPTIONS_MINIMAP_ACTION"] = "On Click"
	Loc ["STRING_OPTIONS_MINIMAP_ACTION_DESC"] = "Select what to do when the icon on the minimap is clicked with the left mouse button."
	Loc ["STRING_OPTIONS_MINIMAP_ACTION1"] = "Open Options Panel"
	Loc ["STRING_OPTIONS_MINIMAP_ACTION2"] = "Reset Segments"
	
	Loc ["STRING_OPTIONS_HOTCORNER_ANCHOR"] = "Hotcorner:"
	Loc ["STRING_OPTIONS_HOTCORNER"] = "Show button"
	Loc ["STRING_OPTIONS_HOTCORNER_DESC"] = "Show or hide the button over Hotcorner panel."
	Loc ["STRING_OPTIONS_HOTCORNER_ACTION"] = "On Click"
	Loc ["STRING_OPTIONS_HOTCORNER_ACTION_DESC"] = "Select what to do when the button on the Hotcorner bar is clicked with the left mouse button."
	Loc ["STRING_OPTIONS_HOTCORNER_QUICK_CLICK"] = "Enable Quick Click"
	Loc ["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_DESC"] = "Enable oe disable the Quick Click feature for Hotcorners.\n\nQuick button is localized at the further top left pixel, moving your mouse all the way to there, activities the top left hot corner and if clicked an action is performed."
	Loc ["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_FUNC"] = "Quick Click On Click"
	Loc ["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_FUNC_DESC"] = "Select what to do when the Quick Click button on Hotcorner is clicked."
	
	Loc ["STRING_OPTIONS_DATABROKER"] = "Data Broker:"
	Loc ["STRING_OPTIONS_DATABROKER_TEXT"] = "Text"
	Loc ["STRING_OPTIONS_DATABROKER_TEXT_DESC"] = "Select what value is exported for data broker plugins."
	Loc ["STRING_OPTIONS_DATABROKER_TEXT1"] = "Raid DPS"
	Loc ["STRING_OPTIONS_DATABROKER_TEXT2"] = "Raid HPS"
	
	Loc ["STRING_OPTIONS_COMBAT_ALPHA"] = "Modify Type"
	Loc ["STRING_OPTIONS_COMBAT_ALPHA_1"] = "No Changes"
	Loc ["STRING_OPTIONS_COMBAT_ALPHA_2"] = "While In Combat"
	Loc ["STRING_OPTIONS_COMBAT_ALPHA_3"] = "While Out of Combat"
	Loc ["STRING_OPTIONS_COMBAT_ALPHA_4"] = "While Out of a Group"
	Loc ["STRING_OPTIONS_COMBAT_ALPHA_DESC"] = "Select how combat affect the instance transparency.\n\n|cFFFFFF00No Changes|r: Doesn't modify the alpha.\n\n|cFFFFFF00While In Combat|r: When your character enter in a combat, the alpha chosen is applied on the window.\n\n|cFFFFFF00While Out of Combat|r: The alpha is applied whenever your character isn't in combat.\n\n|cFFFFFF00While Out of a Group|r: When you aren't in party or a raid group, the instance assumes the selected alpha.\n\n|cFFFFFF00Important|r: This option overwrite the alpha determined by Auto Transparency feature."
	Loc ["STRING_OPTIONS_HIDECOMBATALPHA"] = "Modify To"
	Loc ["STRING_OPTIONS_HIDECOMBATALPHA_DESC"] = "Changes the transparency to this value when your character matches with the chosen rule.\n\n|cFFFFFF00Zero|r: fully hidden, can't interact within the window.\n\n|cFFFFFF001 - 100|r: not hidden, only the transparency is changed, you can interact with the window."
	
	Loc ["STRING_OPTIONS_AUTO_SWITCH"] = "Auto Switch"
	Loc ["STRING_OPTIONS_AUTO_SWITCH_DESC"] = "When you enter in combat, this window change for the selected attribute or plugin.\n\nLeaving the combat, it switch back."
	
	Loc ["STRING_OPTIONS_PERFORMANCE1"] = "Performance Tweaks"
	Loc ["STRING_OPTIONS_PERFORMANCE1_DESC"] = "This options can help save some cpu usage."
	
	Loc ["STRING_OPTIONS_MEMORYT"] = "Memory Threshold"
	Loc ["STRING_OPTIONS_MEMORYT_DESC"] = "Details! have internal mechanisms to handle memory and try adjust it self within the amount of memory avaliable on your system.\n\nAlso is recommeded keep the amount of segments low on systems with |cFFFFFF002GB|r or less of memory."
	
	Loc ["STRING_OPTIONS_SEGMENTSSAVE"] = "Segments Saved"
	Loc ["STRING_OPTIONS_SEGMENTSSAVE_DESC"] = "This options controls how many segments you wish save between game sesions.\n\nHigh values can make your character logoff take more time\n\nIf you rarelly use the data of last day, it`s high recommeded leave this option in |cFFFFFF001|r."
	
	Loc ["STRING_OPTIONS_PANIMODE"] = "Panic Mode"
	Loc ["STRING_OPTIONS_PANIMODE_DESC"] = "When enabled and you got dropped from the game (by a disconnect, for instance) and you are fighting against a boss encounter, all segments are erased, this make your logoff process faster."
	
	Loc ["STRING_OPTIONS_ANIMATESCROLL"] = "Animate Scroll Bar"
	Loc ["STRING_OPTIONS_ANIMATESCROLL_DESC"] = "When enabled, scrollbar uses a animation when showing up or hiding."
	
	Loc ["STRING_OPTIONS_CLEANUP"] = "Auto Erase Trash Segments"
	Loc ["STRING_OPTIONS_CLEANUP_DESC"] = "When enabled, trash cleanup segments are removed automatically after two others segments."
	
	Loc ["STRING_OPTIONS_PERFORMANCECAPTURES"] = "Data Collector"
	Loc ["STRING_OPTIONS_PERFORMANCECAPTURES_DESC"] = "This options are responsible for analysis and collect combat data."
	
	
	Loc ["STRING_OPTIONS_CDAMAGE"] = "Collect Damage"
	Loc ["STRING_OPTIONS_CHEAL"] = "Collect Heal"
	Loc ["STRING_OPTIONS_CENERGY"] = "Collect Energy"
	Loc ["STRING_OPTIONS_CMISC"] = "Collect Misc"
	Loc ["STRING_OPTIONS_CAURAS"] = "Collect Auras"
	
	Loc ["STRING_OPTIONS_CDAMAGE_DESC"] = "Enable capture of:\n\n- |cFFFFFF00Damage Done|r\n- |cFFFFFF00Damage Per Second|r\n- |cFFFFFF00Friendly Fire|r\n- |cFFFFFF00Damage Taken|r"
	Loc ["STRING_OPTIONS_CHEAL_DESC"] = "Enable capture of:\n\n- |cFFFFFF00Healing Done|r\n- |cFFFFFF00Absorbs|r\n- |cFFFFFF00Healing Per Second|r\n- |cFFFFFF00Overhealing|r\n- |cFFFFFF00Healing Taken|r\n- |cFFFFFF00Enemy Healed|r\n- |cFFFFFF00Damage Prevented|r"
	Loc ["STRING_OPTIONS_CENERGY_DESC"] = "Enable capture of:\n\n- |cFFFFFF00Mana Restored|r\n- |cFFFFFF00Rage Generated|r\n- |cFFFFFF00Energy Generated|r\n- |cFFFFFF00Runic Power Generated|r"
	Loc ["STRING_OPTIONS_CMISC_DESC"] = "Enable capture of:\n\n- |cFFFFFF00Crowd Control Break|r\n- |cFFFFFF00Dispells|r\n- |cFFFFFF00Interrupts|r\n- |cFFFFFF00Resurrection|r\n- |cFFFFFF00Deaths|r"
	Loc ["STRING_OPTIONS_CAURAS_DESC"] = "Enable capture of:\n\n- |cFFFFFF00Buffs Uptime|r\n- |cFFFFFF00Debuffs Uptime|r\n- |cFFFFFF00Void Zones|r\n-|cFFFFFF00 Cooldowns|r"
	
	Loc ["STRING_OPTIONS_CLOUD"] = "Cloud Capture"
	Loc ["STRING_OPTIONS_CLOUD_DESC"] = "When enabled, the data of disabled collectors are collected within others raid members."

	Loc ["STRING_OPTIONS_GENERAL_ANCHOR"] = "General:"
	
	-- options window Display ~1
	Loc ["STRING_OPTIONS_AVATAR_ANCHOR"] = "Identity:"

	Loc ["STRING_OPTIONS_SOCIAL"] = "Social"
	Loc ["STRING_OPTIONS_SOCIAL_DESC"] = "Tell how you want to be known in your guild enviorement."
	Loc ["STRING_OPTIONS_NICKNAME"] = "Nickname"
	Loc ["STRING_OPTIONS_NICKNAME_DESC"] = "Replace your character name.\n\nThe nickname is also broadcasted for guild members and Details! shown it instead of your character name."
	Loc ["STRING_OPTIONS_AVATAR"] = "Choose Avatar"
	Loc ["STRING_OPTIONS_AVATAR_DESC"] = "Avatars is also broadcasted for your guild mates and shown on the top of tooltips when hover over a bar and in the player details window."
	Loc ["STRING_OPTIONS_REALMNAME"] = "Remove Realm Name"
	Loc ["STRING_OPTIONS_REALMNAME_DESC"] = "When enabled, the realm name of character isn't displayed with the name, see the example below:\n\n|cFFFFFF00Disabled|r: Charles-Netherwing\n|cFFFFFF00Enabled|r: Charles"	

	Loc ["STRING_OPTIONS_ANIMATEBARS"] = "Animate Bars"
	Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"] = "Enable animations for all bars."
	
	Loc ["STRING_OPTIONS_WINDOWSPEED"] = "Update Interval"
	Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"] = "Seconds between each update on instances (windows).\n\n|cFFFFFF000.3|r: update about 3 times each second.\n\n|cFFFFFF003.0|r: update once every 3 seconds."
	
	Loc ["STRING_OPTIONS_MAXSEGMENTS"] = "Max. Segments"
	Loc ["STRING_OPTIONS_MAXSEGMENTS_DESC"] = "This option control how many segments you want to maintain.\n\nRecommended value is |cFFFFFF0012|r, but feel free to adjust this number to be comfortable for you.\n\nComputers with |cFFFFFF002GB|r or less memory ram should keep low segments amount, this can help your system overall."
	
	Loc ["STRING_OPTIONS_SCROLLBAR"] = "Scroll Bar"
	Loc ["STRING_OPTIONS_SCROLLBAR_DESC"] = "Enable ou Disable the scroll bar.\n\nBy default, Details! scroll bars are replaced by a mechanism that stretches the window.\n\nThe |cFFFFFF00stretch handle|r is outside over instances button/menu (left of close button)."
	
	Loc ["STRING_OPTIONS_MAXINSTANCES"] = "Max. Instances"
	Loc ["STRING_OPTIONS_MAXINSTANCES_DESC"] = "Limit the number of Details! instances which can be created and the amount displayed on the instance button.\n\nYou can open and re-open instances clicking on the instance button |cFFFFFF00#X|r."
	
	Loc ["STRING_OPTIONS_LOCKSEGMENTS"] = "Segments Locked"
	Loc ["STRING_OPTIONS_LOCKSEGMENTS_DESC"] = "When enabled, changing a segment in any instance does change in all the others instances too."

	Loc ["STRING_OPTIONS_PS_ABBREVIATE"] = "Abbreviation Type"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_DESC"] = "Choose the abbreviation method.\n\n|cFFFFFF00None|r: no abbreviation, the raw number is shown.\n\n|cFFFFFF00ToK I|r: the number is abbreviated showing the fractional-part.\n\n59874 = 59.8K\n520.600 = 520.6K\n19.530.000 = 19.53M\n\n|cFFFFFF00ToK II|r: Is the same as ToK I, but, numbers between one hundred and one million doesn't show fractional-part.\n\n59874 = 59.8K\n520.600 = 520K\n19.530.000 = 19.53M\n\n|cFFFFFF00ToM I|r: Numbers equals or biggest of one million doesn't show the fractional-part.\n\n59874 = 59.8K\n520.600 = 520.6K\n19.530.000 = 19M\n\n|cFFFFFF00Lower|r: The letters K and M are lowercase.\n\n|cFFFFFF00Upper|r: The letter K and M are uppercase."
	
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_NONE"] = "None"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK"] = "ToK I Upper"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK2"] = "ToK II Upper"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK0"] = "ToM I Upper"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOKMIN"] = "ToK I Lower"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK2MIN"] = "ToK II Lower"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK0MIN"] = "ToM I Lower"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_COMMA"] = "Comma"
	
	-- options window Combat ~2
	Loc ["STRING_OPTIONS_PVPFRAGS"] = "Only Pvp Frags"
	Loc ["STRING_OPTIONS_PVPFRAGS_DESC"] = "When enabled, only kills against enemy players count on |cFFFFFF00damage > frags|r display."

	Loc ["STRING_OPTIONS_TIMEMEASURE"] = "Time Measure"
	Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"] = "|cFFFFFF00Activity|r: the timer of each raid member is put on hold if his activity is ceased and back again to count when is resumed, common way of measure Dps and Hps.\n\n|cFFFFFF00Effective|r: used on rankings, this method uses the elapsed combat time for measure the Dps and Hps of all raid members."
	
	Loc ["STRING_OPTIONS_OVERALL_ANCHOR"] = "Overall Data:"
	
	Loc ["STRING_OPTIONS_OVERALL_RAIDBOSS"] = "Raid Bosses"
	Loc ["STRING_OPTIONS_OVERALL_RAIDBOSS_DESC"] = "Segments with raid encounters are added to overall data."
	Loc ["STRING_OPTIONS_OVERALL_RAIDCLEAN"] = "Raid Trash"
	Loc ["STRING_OPTIONS_OVERALL_RAIDCLEAN_DESC"] = "Segments with raid trash mobs cleanup are added to overall data."
	Loc ["STRING_OPTIONS_OVERALL_DUNGEONBOSS"] = "Dungeon Bosses"
	Loc ["STRING_OPTIONS_OVERALL_DUNGEONBOSS_DESC"] = "Segments with dungeon bosses are added to overall data."
	Loc ["STRING_OPTIONS_OVERALL_DUNGEONCLEAN"] = "Dungeon Trash"
	Loc ["STRING_OPTIONS_OVERALL_DUNGEONCLEAN_DESC"] = "Segments with dungeon trash mobs cleanup are added to overall data."
	Loc ["STRING_OPTIONS_OVERALL_ALL"] = "All Segments"
	Loc ["STRING_OPTIONS_OVERALL_ALL_DESC"] = "All segments are added to overall data."
	
	Loc ["STRING_OPTIONS_OVERALL_NEWBOSS"] = "Clear On New Boss"
	Loc ["STRING_OPTIONS_OVERALL_NEWBOSS_DESC"] = "When enabled, overall data is automatically wiped when facing a different raid boss."
	
	Loc ["STRING_OPTIONS_OVERALL_CHALLENGE"] = "Clear On Challenge Mode"
	Loc ["STRING_OPTIONS_OVERALL_CHALLENGE_DESC"] = "When enabled, overall data is automatically wiped when a new challenge mode run begins."
	
	-- options window Row General Settings ~4
	
	Loc ["STRING_OPTIONS_BARS"] = "Bar General Settings"
	Loc ["STRING_OPTIONS_BARS_DESC"] = "This options control the bar appearance."
	
	Loc ["STRING_OPTIONS_ROW_SETTING_ANCHOR"] = "General:"
	
	Loc ["STRING_OPTIONS_BAR_HEIGHT"] = "Height"
	Loc ["STRING_OPTIONS_BAR_HEIGHT_DESC"] = "Increase or decrease the bar height."

	Loc ["STRING_OPTIONS_BARGROW_DIRECTION"] = "Grow Direction"
	Loc ["STRING_OPTIONS_BARGROW_DIRECTION_DESC"] = "The side which the bars start being shown in the window."

	Loc ["STRING_OPTIONS_BARSORT_DIRECTION"] = "Sort Direction"
	Loc ["STRING_OPTIONS_BARSORT_DIRECTION_DESC"] = "Ascending or descending order of bar numbers."
	
	Loc ["STRING_OPTIONS_BAR_SPACING"] = "Spacing"
	Loc ["STRING_OPTIONS_BAR_SPACING_DESC"] = "Increase or decrease the gap size between each row."
	
	Loc ["STRING_OPTIONS_BAR_TEXTURE"] = "Texture"
	Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"] = "This is the texture used on the top of bar.\nThe size is changed according with the percentage."
	
	Loc ["STRING_OPTIONS_BAR_BTEXTURE"] = "Texture"
	Loc ["STRING_OPTIONS_BAR_BTEXTURE_DESC"] = "This texture lies below the top texture, the size is always the same as the window width."
	
	Loc ["STRING_OPTIONS_BAR_BCOLOR"] = "Background Color"
	Loc ["STRING_OPTIONS_BAR_BCOLOR_DESC"] = "Choose the background texture color.\nThis color is ignored if by class slider is actived."
	Loc ["STRING_OPTIONS_BAR_COLOR_DESC"] = "Choose the texture color.\nThis color is ignored if by class slider is actived."

	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"] = "Color By Class"
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"] = "When enabled, the color chosen is ignored and the color of the actor class which is currently showing in the bar is used instead."
	
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2"] = "By Class"
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2_DESC"] = "When enabled, the color chosen is ignored and the color of the actor class which is currently showing in the bar is used instead."
	
	Loc ["STRING_OPTIONS_BAR_ICONFILE"] = "Icon File"
	Loc ["STRING_OPTIONS_BAR_ICONFILE_DESC"] = ".tga file with alpha channel responsable for the class icons\n\nDetails! have bundle three image icon files:\n\n- |cFFFFFF00classes|r\n- |cFFFFFF00classes_small|r\n- |cFFFFFF00classes_small_alpha|r"
	
	Loc ["STRING_OPTIONS_BARSTART"] = "Bar Start After Icon"
	Loc ["STRING_OPTIONS_BARSTART_DESC"] = "When disabled the top texture starts at the icon left side instead of the right (useful with transpant icons)."
	
	Loc ["STRING_OPTIONS_BAR_BACKDROP_ANCHOR"] = "Border:"
	
	Loc ["STRING_OPTIONS_BAR_BACKDROP_ENABLED"] = "Enabled"
	Loc ["STRING_OPTIONS_BAR_BACKDROP_ENABLED_DESC"] = "Enable or disable row borders."
	
	Loc ["STRING_OPTIONS_BAR_BACKDROP_SIZE"] = "Size"
	Loc ["STRING_OPTIONS_BAR_BACKDROP_SIZE_DESC"] = "Increase or decrease the border size."
	
	Loc ["STRING_OPTIONS_BAR_BACKDROP_COLOR"] = "Color"
	Loc ["STRING_OPTIONS_BAR_BACKDROP_COLOR_DESC"] = "Changes the border color."
	
	Loc ["STRING_OPTIONS_BAR_BACKDROP_TEXTURE"] = "Texture"
	Loc ["STRING_OPTIONS_BAR_BACKDROP_TEXTURE_DESC"] = "Changes the border appearance."
	
	-- options window Row Text Settings ~5
	
	Loc ["STRING_OPTIONS_TEXT"] = "Bar Text Settings"
	Loc ["STRING_OPTIONS_TEXT_DESC"] = "This options control the appearance of the instance bar texts."
	
	Loc ["STRING_OPTIONS_TEXTEDITOR_COMMA"] = "Comma"
	Loc ["STRING_OPTIONS_TEXTEDITOR_COMMA_TOOLTIP"] = "Add a comma function call for use inside functions on return values."
	Loc ["STRING_OPTIONS_TEXTEDITOR_TOK"] = "ToK"
	Loc ["STRING_OPTIONS_TEXTEDITOR_TOK_TOOLTIP"] = "Add a abbreviation function call for use inside functions on return values."
	Loc ["STRING_OPTIONS_TEXTEDITOR_COLOR"] = "Color"
	Loc ["STRING_OPTIONS_TEXTEDITOR_COLOR_TOOLTIP"] = "Select the text and then click on the color button to change selected text color."
	Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC"] = "Function"
	Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC_TOOLTIP"] = "Adds a function, functions always have to return a number."
	
	Loc ["STRING_OPTIONS_TEXT_SIZE"] = "Text Size"
	Loc ["STRING_OPTIONS_TEXT_SIZE_DESC"] = "Change the size of both left and right texts."
	
	Loc ["STRING_OPTIONS_TEXT_FONT"] = "Text Font"
	Loc ["STRING_OPTIONS_TEXT_FONT_DESC"] = "Change the font of both left and right texts."
	
	Loc ["STRING_OPTIONS_TEXT_LOUTILINE"] = "Text Shadow"
	Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"] = "Enable or disable the outline for left text."
	
	Loc ["STRING_OPTIONS_TEXT_ROUTILINE"] = "Text Shadow"
	Loc ["STRING_OPTIONS_TEXT_ROUTILINE_DESC"] = "Enable or disable the outline for right text."
	
	Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR"] = "Color By Class"
	Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"] = "When enabled, the color chosen is ignored and the color of the actor class which is currently showing in the bar is used instead."
	
	Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR"] = "Color By Class"
	Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"] = "When enabled, the color chosen is ignored and the color of the actor class which is currently showing in the bar is used instead."
	
	Loc ["STRING_OPTIONS_TEXT_TEXTUREU_ANCHOR"] = "Upper Texture:"
	Loc ["STRING_OPTIONS_TEXT_TEXTUREL_ANCHOR"] = "Lower Texture:"
	
	Loc ["STRING_OPTIONS_TEXT_FIXEDCOLOR"] = "Text Color"
	Loc ["STRING_OPTIONS_TEXT_FIXEDCOLOR_DESC"] = "Change the text color of both left and right texts.\n\nIgnored if |cFFFFFFFFcolor by class|r is enabled."
	
	Loc ["STRING_OPTIONS_TEXT_ROWCOLOR"] = "Color"
	Loc ["STRING_OPTIONS_TEXT_ROWCOLOR2"] = "Color"
	Loc ["STRING_OPTIONS_TEXT_ROWCOLOR_NOTCLASS"] = "By Class"
	
	Loc ["STRING_OPTIONS_TEXT_ROWICONS_ANCHOR"] = "Icons:"
	
	Loc ["STRING_OPTIONS_PERCENT_TYPE"] = "Percentage Type"
	Loc ["STRING_OPTIONS_PERCENT_TYPE_DESC"] = "Changes the percentage method:\n\n|cFFFFFF00Relative Total|r: the percentage shows the actor fraction of total amount made by all raid members.\n\n|cFFFFFF00Relative Top Player|r: the percentage is relative within the amount score of the top player."
	
	Loc ["STRING_OPTIONS_TEXT_LEFT_ANCHOR"] = "Left Text:"
	Loc ["STRING_OPTIONS_TEXT_RIGHT_ANCHOR"] = "Right Text:"

	Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM2"] = ""
	Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM2_DESC"] = "|cFFFFFF00{data1}|r: is the first number passed, generally this number represents the total done.\n\n|cFFFFFF00{data2}|r: is the second number passed, most of the times represents the per second average.\n\n|cFFFFFF00{data3}|r: third number passed, normally is the percentage. \n\n|cFFFFFF00{func}|r: runs a customized Lua function adding its return value to the text.\nExample: \n{func return 'hello azeroth'}\n\n|cFFFFFF00Scape Sequences|r: use to change color or add textures. Search 'UI escape sequences' for more information."
	Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM"] = "Custom Text Enabled"
	Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM_DESC"] = "When enabled, right text is formated following the rules in the box."
	
	-- options window Profiles Settings ~13
	Loc ["STRING_OPTIONS_PROFILES_ANCHOR"] = "Settings:"
	
	Loc ["STRING_OPTIONS_PROFILES_TITLE"] = "Profiles"
	Loc ["STRING_OPTIONS_PROFILES_TITLE_DESC"] = "This options allow you share the same settings between different characters."
	
	Loc ["STRING_OPTIONS_PROFILES_CURRENT"] = "Current Profile:"
	Loc ["STRING_OPTIONS_PROFILES_CURRENT_DESC"] = "This is the name of current actived profile."

	Loc ["STRING_OPTIONS_PROFILES_SELECT"] = "Select Profile"
	Loc ["STRING_OPTIONS_PROFILES_SELECT_DESC"] = "Load a profile, all settings are overwrite by the new profile settings."

	Loc ["STRING_OPTIONS_PROFILES_CREATE"] = "Create Profile"
	Loc ["STRING_OPTIONS_PROFILES_CREATE_DESC"] = "Create a new profile."

	Loc ["STRING_OPTIONS_PROFILES_COPY"] = "Copy Profile From"
	Loc ["STRING_OPTIONS_PROFILES_COPY_DESC"] = "Copy all settings from the selected profile to current profile overwriting all values."

	Loc ["STRING_OPTIONS_PROFILES_ERASE"] = "Remove Profile"
	Loc ["STRING_OPTIONS_PROFILES_ERASE_DESC"] = "Remove the selected profile."

	Loc ["STRING_OPTIONS_PROFILES_RESET"] = "Reset Current Profile"
	Loc ["STRING_OPTIONS_PROFILES_RESET_DESC"] = "Reset all settings of the selected profile to default values."
	
	-- options window Tooltip ~20
	Loc ["STRING_OPTIONS_TOOLTIPS_TITLE"] = "Tooltips"
	Loc ["STRING_OPTIONS_TOOLTIPS_TITLE_DESC"] = "This options controls the appearance of tooltips."
	
	Loc ["STRING_OPTIONS_TOOLTIP_ANCHOR"] = "Settings:"
	Loc ["STRING_OPTIONS_TOOLTIP_ANCHORTEXTS"] = "Texts:"
	
	Loc ["STRING_OPTIONS_TOOLTIPS_FONTFACE"] = "Text Font"
	Loc ["STRING_OPTIONS_TOOLTIPS_FONTFACE_DESC"] = "Choose the font used on tooltip texts."
	Loc ["STRING_OPTIONS_TOOLTIPS_FONTSIZE"] = "Text Size"
	Loc ["STRING_OPTIONS_TOOLTIPS_FONTSIZE_DESC"] = "Increase or decrease the size of tooltip texts"
	Loc ["STRING_OPTIONS_TOOLTIPS_FONTCOLOR"] = "Text Color"
	Loc ["STRING_OPTIONS_TOOLTIPS_FONTCOLOR_DESC"] = "Change the color used on tooltip texts."
	Loc ["STRING_OPTIONS_TOOLTIPS_FONTSHADOW"] = "Text Shadow"
	Loc ["STRING_OPTIONS_TOOLTIPS_FONTSHADOW_DESC"] = "Enable or disable the shadow in the text."
	Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE"] = "Maximize Method"
	Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE_DESC"] = "Select the method used to expand the information shown on the tooltip.\n\n|cFFFFFF00 On Control Keys|r: tooltip box is expanded when Shift, Ctrl or Alt keys is pressed.\n\n|cFFFFFF00 Always Maximized|r: the tooltip always show all information without any amount limitations.\n\n|cFFFFFF00 Only Shift Block|r: the first block on the tooltip is always expanded by default.\n\n|cFFFFFF00 Only Ctrl Block|r: the second block is always expanded by default.\n\n|cFFFFFF00 Only Alt Block|r: the third block is always expanded by default."
	Loc ["STRING_OPTIONS_TOOLTIPS_ABBREVIATION"] = "Abbreviation Type"
	Loc ["STRING_OPTIONS_TOOLTIPS_ABBREVIATION_DESC"] = "Choose how the numbers displayed on tooltips are formated."
	Loc ["STRING_OPTIONS_TOOLTIPS_BACKGROUNDCOLOR"] = "Background Color"
	Loc ["STRING_OPTIONS_TOOLTIPS_BACKGROUNDCOLOR_DESC"] = "Choose the color used on the background."
	Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE1"] = "On Shift Ctrl Alt"
	Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE2"] = "Always Maximized"
	Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE3"] = "Only Shift Block"
	Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE4"] = "Only Ctrl Block"
	Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE5"] = "Only Alt Block"
	
	Loc ["STRING_OPTIONS_TOOLTIPS_SHOWAMT"] = "Show Amount"
	Loc ["STRING_OPTIONS_TOOLTIPS_SHOWAMT_DESC"] = "Shows a number indicating how many spells, targets and pets have in the tooltip."
	
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_POINT"] = "Anchor:"
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO"] = "Anchor"
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_DESC"] = "Tooltips attaches on the hovered row or on a chosen point in the game screen."
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO1"] = "Window Row"
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO2"] = "Point on Screen"
	
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_CHOOSE"] = "Move Anchor Point"
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_CHOOSE_DESC"] = "Move the anchor position when Anchor is set to |cFFFFFF00Point on Screen|r."
	
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TEXT"] = "Tooltip Anchor"
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TEXT_DESC"] = "right click to lock."
	
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_ATTACH"] = "Tooltip Side"
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_ATTACH_DESC"] = "Which side of tooltip is used to snap with the anchor attach side."
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_RELATIVE"] = "Anchor Side"
	Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_RELATIVE_DESC"] = "Which side of the anchor the tooltip will be placed."

	Loc ["STRING_ANCHOR_TOP"] = "Top"
	Loc ["STRING_ANCHOR_BOTTOM"] = "Bottom"
	Loc ["STRING_ANCHOR_LEFT"] = "Left"
	Loc ["STRING_ANCHOR_RIGHT"] = "Right"
	Loc ["STRING_ANCHOR_TOPLEFT"] = "Top Left"
	Loc ["STRING_ANCHOR_TOPRIGHT"] = "Top Right"
	Loc ["STRING_ANCHOR_BOTTOMLEFT"] = "Bottom Left"
	Loc ["STRING_ANCHOR_BOTTOMRIGHT"] = "Bottom Right"
	
	Loc ["STRING_OPTIONS_TOOLTIPS_OFFSETX"] = "Distance X"
	Loc ["STRING_OPTIONS_TOOLTIPS_OFFSETX_DESC"] = "How far horizontally the tooltip is placed from its anchor."
	Loc ["STRING_OPTIONS_TOOLTIPS_OFFSETY"] = "Distance Y"
	Loc ["STRING_OPTIONS_TOOLTIPS_OFFSETY_DESC"] = "How far vertically the tooltip is placed from its anchor."
	
	-- options window Attribute Text ~14
	Loc ["STRING_OPTIONS_ATTRIBUTE_TEXT"] = "Title Text Settings"
	Loc ["STRING_OPTIONS_ATTRIBUTE_TEXT_DESC"] = "This options controls the title text of window."

	Loc ["STRING_OPTIONS_MENU_ATTRIBUTETEXT_ANCHOR"] = "Texts:"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTESETTINGS_ANCHOR"] = "Settings:"
	
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ENABLED"] = "Enabled"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ENABLED_DESC"] = "Enable or disable the attribute name which is current shown on this instance."
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORX"] = "Pos X"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORY"] = "Pos Y"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORX_DESC"] = "Adjust the attribute text location on the X axis."
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORY_DESC"] = "Adjust the attribute text location on the Y axis."
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_FONT"] = "Text Font"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_FONT_DESC"] = "Select the text font for attribute text."
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTSIZE"] = "Text Size"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTSIZE_DESC"] = "Adjust the size of attribute text."
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR"] = "Text Color"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR_DESC"] = "Change the attribute text color."
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SIDE"] = "Text Anchor"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SIDE_DESC"] = "Choose where the text is anchored."
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW"] = "Shadow"
	Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW_DESC"] = "Enable or disable the shadow on the text."	
	
	-- options window Skin Settings ~3
	Loc ["STRING_OPTIONS_INSTANCE_SKIN"] = "Skin"
	Loc ["STRING_OPTIONS_INSTANCE_SKIN_DESC"] = "Modify window appearance based on a skin theme."
	
	Loc ["STRING_OPTIONS_SKIN_SELECT_ANCHOR"] = "Skin Selection:"
	Loc ["STRING_OPTIONS_SKIN_PRESETS_ANCHOR"] = "Save Presets:"
	
	Loc ["STRING_OPTIONS_SKIN_SELECT"] = "select a skin"
	Loc ["STRING_OPTIONS_SKIN_LOADED"] = "skin successful loaded."
	Loc ["STRING_OPTIONS_SKIN_REMOVED"] = "skin removed."
	
	Loc ["STRING_OPTIONS_SKIN_A"] = "Skin Settings"
	Loc ["STRING_OPTIONS_SKIN_A_DESC"] = "This options allows you to change the skin."

	Loc ["STRING_OPTIONS_SAVELOAD_PNAME"] = "Custom Skin Name"
	Loc ["STRING_OPTIONS_SAVELOAD_SAVE"] = "create"
	Loc ["STRING_OPTIONS_SAVELOAD_LOAD"] = "Load Custom Skin"
	Loc ["STRING_OPTIONS_SAVELOAD_LOAD_DESC"] = "Choose one of the previous saved skins to apply on the current selected instance."
	Loc ["STRING_OPTIONS_SAVELOAD_CREATE_DESC"] = "Type the custom skin name on the field and click on create button.\n\nThis process create a custom skin which you can load on others instances or just save for another time."
	Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"] = "Erase Custom Skin"
	Loc ["STRING_OPTIONS_SAVELOAD_RESET"] = "Load Default Skin"
	Loc ["STRING_OPTIONS_SAVELOAD_APPLYTOALL"] = "Apply in all Instances"
	Loc ["STRING_OPTIONS_SAVELOAD_MAKEDEFAULT"] = "Save Standard Skin"
	Loc ["STRING_OPTIONS_SAVELOAD_ERASE_DESC"] = "This option erase a previous saved skin."
	Loc ["STRING_OPTIONS_SAVELOAD_STDSAVE"] = "Standard Skin has been saved, new instances will be using this skin by default."
	Loc ["STRING_OPTIONS_SAVELOAD_APPLYALL"] = "The current skin has been applied in all other instances."
	Loc ["STRING_OPTIONS_SAVELOAD_SKINCREATED"] = "Skin created."
	Loc ["STRING_OPTIONS_SAVELOAD_STD_DESC"] = "Standard skin is applied on all new instances created."
	Loc ["STRING_OPTIONS_SAVELOAD_APPLYALL_DESC"] = "Apply the current skin on all instances created."
	
	-- options window Window Settings ~6
	Loc ["STRING_OPTIONS_WINDOW_ANCHOR"] = "Appearance Adjustments:"

	Loc ["STRING_OPTIONS_WINDOW_TITLE"] = "Window Settings"
	Loc ["STRING_OPTIONS_WINDOW_TITLE_DESC"] = "This options control the window appearance of selected instance."	
	
	Loc ["STRING_OPTIONS_INSTANCE_COLOR"] = "Window Color"
	Loc ["STRING_OPTIONS_INSTANCE_COLOR_DESC"] = "Change the color and alpha of this window.\n\n|cFFFFFF00Important|r: the alpha chosen here are overwritten with |cFFFFFF00Auto Transparency|r values when enabled.\n\n|cFFFFFF00Important|r: selecting the instance window color overwrite any color customization over the statusbar."
	
	Loc ["STRING_OPTIONS_INSTANCE_BACKDROP"] = "Background Texture"
	Loc ["STRING_OPTIONS_INSTANCE_BACKDROP_DESC"] = "Select the background texture used by this window.\n\n|cFFFFFF00Default|r: Details Background."
	
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA"] = "Background Alpha"
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA_DESC"] = "This option let you change the transparency of the instance window background."
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA2"] = "Background Color"
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA2_DESC"] = "This option let you change the color of the instance window background."

	Loc ["STRING_OPTIONS_SHOW_SIDEBARS"] = "Show Borders"
	Loc ["STRING_OPTIONS_SHOW_SIDEBARS_DESC"] = "Show or hide window borders."
	
	Loc ["STRING_OPTIONS_SHOW_STATUSBAR"] = "Show Statusbar"
	Loc ["STRING_OPTIONS_SHOW_STATUSBAR_DESC"] = "Show or hide the bottom statusbar."	
	
	-- options window Left Menu Settings ~7 
	Loc ["STRING_OPTIONS_LEFT_MENU_ANCHOR"] = "Menu Settings:"
	
	
	-- options window Wallpaper Settings ~9
	Loc ["STRING_OPTIONS_WALLPAPER_ANCHOR"] = "Wallpaper Selection:"
	
	
	--options window Performance Settings ~10
	Loc ["STRING_OPTIONS_PERFORMANCE_ANCHOR"] = "General:"
	Loc ["STRING_OPTIONS_DATACOLLECT_ANCHOR"] = "Data Types:"
	
	--
	
	Loc ["STRING_OPTIONS_SHOWHIDE"] = "Show & Hide settings"
	Loc ["STRING_OPTIONS_SHOWHIDE_DESC"] = "Controls when a window should hide or appear on the screen."

	Loc ["STRING_OPTIONS_INSTANCE_CURRENT"] = "Auto Switch To Current"
	Loc ["STRING_OPTIONS_INSTANCE_CURRENT_DESC"] = "Whenever a combat start and there is no other instance on current segment, this instance auto switch to current segment."

	Loc ["STRING_OPTIONS_SHOW_TOTALBAR"] = "Show Total Bar"
	Loc ["STRING_OPTIONS_SHOW_TOTALBAR_DESC"] = "Show or hide the total bar."
	Loc ["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP"] = "Only in Group"
	Loc ["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP_DESC"] = "Total bar aren't shown if you isn't in a group."
	Loc ["STRING_OPTIONS_SHOW_TOTALBAR_ICON"] = "Icon"
	Loc ["STRING_OPTIONS_SHOW_TOTALBAR_ICON_DESC"] = "Select the icon shown on the total bar."
	Loc ["STRING_OPTIONS_SHOW_TOTALBAR_COLOR_DESC"] = "Select the color. The transparency value follow the row alpha value."
	


Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS"] = "Left Menu Settings"
Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS_DESC"] = "This options change the main menu on the top of the window."
Loc ["STRING_OPTIONS_TOOLBAR2_SETTINGS"] = "Right Menu Settings"
Loc ["STRING_OPTIONS_TOOLBAR2_SETTINGS_DESC"] = "This options change the reset, instance and close buttons from the toolbar menu on the top of the window."
	
Loc ["STRING_OPTIONS_DESATURATE_MENU"] = "Desaturate Menu"
Loc ["STRING_OPTIONS_DESATURATE_MENU_DESC"] = "Enabling this option, all menu icons on toolbar became black and white."

Loc ["STRING_OPTIONS_HIDE_ICON"] = "Hide Icon"
Loc ["STRING_OPTIONS_HIDE_ICON_DESC"] = "When enabled, the icon on the top left corner isn't draw.\n\nSome skins may prefer remove this icon."

Loc ["STRING_OPTIONS_MENU_X"] = "Menu Pos X"
Loc ["STRING_OPTIONS_MENU_X_DESC"] = "Change the position of all left menu buttons, the first slider changes the horizontal axis, the second changes the vertical axis."
Loc ["STRING_OPTIONS_MENU_Y"] = "Menu Pos Y"
Loc ["STRING_OPTIONS_MENU_Y_DESC"] = "Change the position of all left menu buttons, the first slider changes the horizontal axis, the second changes the vertical axis."

Loc ["STRING_OPTIONS_MENU2_X"] = "Menu Pos X"
Loc ["STRING_OPTIONS_MENU2_X_DESC"] = "Change the position of all right menu buttons, the first slider changes the horizontal axis, the second changes the vertical axis."
Loc ["STRING_OPTIONS_MENU2_Y"] = "Menu Pos Y"
Loc ["STRING_OPTIONS_MENU2_Y_DESC"] = "Change the position of all right menu buttons, the first slider changes the horizontal axis, the second changes the vertical axis."

Loc ["STRING_OPTIONS_MENU_ANCHOR"] = "Menu Anchor Side"
Loc ["STRING_OPTIONS_MENU_ANCHOR_DESC"] = "Change if the left menu is attached within left side of window or in the right side."

Loc ["STRING_OPTIONS_MENU_BUTTONSSIZE"] = "Buttons Size"
Loc ["STRING_OPTIONS_MENU_BUTTONSSIZE_DESC"] = "Choose the buttons size. This also modify the buttons added by plugins."

Loc ["STRING_OPTIONS_CUSTOMSPELL_ADD"] = "Add Spell"
Loc ["STRING_OPTIONS_CUSTOMSPELLTITLE"] = "Edit Spells Settings"
Loc ["STRING_OPTIONS_CUSTOMSPELLTITLE_DESC"] = "This panel alows you modify the name and icon of spells."

Loc ["STRING_OPTIONS_DATACHARTTITLE"] = "Create Timed Data for Charts"
Loc ["STRING_OPTIONS_DATACHARTTITLE_DESC"] = "This panel alows you to create customized data captures for charts creation."



Loc ["STRING_OPTIONS_INSTANCE_STRATA"] = "Layer Strata"
Loc ["STRING_OPTIONS_INSTANCE_STRATA_DESC"] = "Selects the layer height that the frame will be placed on.\n\nLow layer is the default and makes the window stay behind of the most interface panels.\n\nUsing high layer the window might stay in front of the major others panels.\n\nWhen changing the layer height you may find some conflict with others panels, overlapping each other."

Loc ["STRING_OPTIONS_MENU_AUTOHIDE_ANCHOR"] = "Auto Hide Menu Buttons"
Loc ["STRING_OPTIONS_MENU_AUTOHIDE_LEFT"] = "Auto Hide Menu"
Loc ["STRING_OPTIONS_MENU_AUTOHIDE_RIGHT"] = "Auto Hide Menu"
Loc ["STRING_OPTIONS_MENU_AUTOHIDE_DESC"] = "When enabled the menu automatically hides it self when the mouse leaves the window and shows up when you are interacting with it again."

Loc ["STRING_OPTIONS_INSTANCE_STATUSBAR_ANCHOR"] = "Statusbar:"
Loc ["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR"] = "Color and Transparency"
Loc ["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR_DESC"] = "Select the color used by the statusbar.\n\n|cFFFFFF00Important|r: this option overwrite the color and transparency chosen over Window Color."

Loc ["STRING_OPTIONS_MENU_ALPHA"] = "Interact Auto Transparency:"
Loc ["STRING_OPTIONS_MENU_ALPHAENABLED"] = "Enabled"
Loc ["STRING_OPTIONS_MENU_ALPHAENTER"] = "When Interacting"
Loc ["STRING_OPTIONS_MENU_ALPHALEAVE"] = "Stand by"
Loc ["STRING_OPTIONS_MENU_ALPHAICONSTOO"] = "Affect Buttons"
Loc ["STRING_OPTIONS_MENU_IGNOREBARS"] = "Ignore Rows"

Loc ["STRING_OPTIONS_MENU_SHOWBUTTONS"] = "Show Buttons"
Loc ["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"] = "Choose which buttons are shown on the toolbar."

Loc ["STRING_OPTIONS_MENU_IGNOREBARS_DESC"] = "When enabled, all rows on this window aren't affected by this mechanism."
Loc ["STRING_OPTIONS_MENU_ALPHAENABLED_DESC"] = "Enable or disable the auto transparency. When enabled, the alpha changes automatically when you hover and leave the window.\n\n|cFFFFFF00Important|r: This settings overwrites the alpha selected over Window Color."
Loc ["STRING_OPTIONS_MENU_ALPHAENTER_DESC"] = "When you have the mouse over the window, the transparency changes to this value."
Loc ["STRING_OPTIONS_MENU_ALPHALEAVE_DESC"] = "When you don't have the mouse over the window, the transparency changes to this value."
Loc ["STRING_OPTIONS_MENU_ALPHAICONSTOO_DESC"] = "If enabled, all icons, buttons, also have their alpha affected by this feature."

Loc ["STRING_OPTIONS_MENU_ALPHAWARNING"] = "Auto Transparency is enabled, alpha may not be affected."

Loc ["STRING_OPTIONS_INSTANCE_BUTTON_ANCHOR"] = "Instance Button:"
Loc ["STRING_OPTIONS_RESET_BUTTON_ANCHOR"] = "Reset Button:"
Loc ["STRING_OPTIONS_CLOSE_BUTTON_ANCHOR"] = "Close Button:"

Loc ["STRING_OPTIONS_RESET_TEXTCOLOR"] = "Text Color"
Loc ["STRING_OPTIONS_RESET_TEXTCOLOR_DESC"] = "Modify the reset button text color.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_RESET_TEXTFONT"] = "Text Font"
Loc ["STRING_OPTIONS_RESET_TEXTFONT_DESC"] = "Modify the reset button text font.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_RESET_TEXTSIZE"] = "Text Size"
Loc ["STRING_OPTIONS_RESET_TEXTSIZE_DESC"] = "Modify the reset button text size.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_RESET_OVERLAY"] = "Overlay Color"
Loc ["STRING_OPTIONS_RESET_OVERLAY_DESC"] = "Modify the reset button overlay color.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_RESET_SMALL"] = "Always Small"
Loc ["STRING_OPTIONS_RESET_SMALL_DESC"] = "When enabled, reset button always shown as his smaller size.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR"] = "Text Color"
Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR_DESC"] = "Change the instance button text color."

Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT"] = "Text Font"
Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT_DESC"] = "Change the instance button text font."

Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE"] = "Text Size"
Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE_DESC"] = "Change the instance button text size."

Loc ["STRING_OPTIONS_INSTANCE_OVERLAY"] = "Overlay Color"
Loc ["STRING_OPTIONS_INSTANCE_OVERLAY_DESC"] = "Change the instance button overlay color."

Loc ["STRING_OPTIONS_CLOSE_OVERLAY"] = "Overlay Color"
Loc ["STRING_OPTIONS_CLOSE_OVERLAY_DESC"] = "Change the close button overlay color."

Loc ["STRING_OPTIONS_STRETCH"] = "Stretch Button Anchor"
Loc ["STRING_OPTIONS_STRETCH_DESC"] = "Alternate the stretch button position.\n\n|cFFFFFF00Top|r: the grab is placed on the top right corner.\n\n|cFFFFFF00Bottom|r: the grab is placed on the bottom center."

Loc ["STRING_OPTIONS_STRETCHTOP"] = "Stretch Button Always On Top"
Loc ["STRING_OPTIONS_STRETCHTOP_DESC"] = "The stretch button will be placed on the FULLSCREEN strata and always stay higher than the others frames.\n\n|cFFFFFF00Important|r: Moving the grab for a high layer, it might stay in front of others frames like backpacks, use only if you really need."

Loc ["STRING_OPTIONS_PICONS_DIRECTION"] = "Plugin Icons Direction"
Loc ["STRING_OPTIONS_PICONS_DIRECTION_DESC"] = "Change the direction which plugins icons are displayed on the toolbar."

Loc ["STRING_OPTIONS_INSBUTTON_X"] = "Instance Button X"
Loc ["STRING_OPTIONS_INSBUTTON_X_DESC"] = "Change the instance button position."

Loc ["STRING_OPTIONS_INSBUTTON_Y"] = "Instance Button Y"
Loc ["STRING_OPTIONS_INSBUTTON_Y_DESC"] = "Change the instance button position."

Loc ["STRING_OPTIONS_MICRODISPLAYSSIDE"] = "Micro Displays Anchor"
Loc ["STRING_OPTIONS_MICRODISPLAYSSIDE_DESC"] = "Place the micro displays on the top of the window or on the bottom side."
Loc ["STRING_OPTIONS_MICRODISPLAYWARNING"] = "Micro displays isn't shown because statusbar is disabled."

Loc ["STRING_OPTIONS_TOOLBARSIDE"] = "Toolbar Anchor"
Loc ["STRING_OPTIONS_TOOLBARSIDE_DESC"] = "Place the toolbar on the top or bottom side of window."


	

	
	Loc ["STRING_OPTIONS_WP"] = "Wallpaper Settings"
	Loc ["STRING_OPTIONS_WP_DESC"] = "This options control the wallpaper of instance."
	
	Loc ["STRING_OPTIONS_WP_ENABLE"] = "Show"
	Loc ["STRING_OPTIONS_WP_ENABLE_DESC"] = "Enable or Disable the wallpaper of the instance.\n\nSelect the category and the image you want on the two following boxes."
	
	Loc ["STRING_OPTIONS_WP_GROUP"] = "Category"
	Loc ["STRING_OPTIONS_WP_GROUP_DESC"] = "In this box, you select the group of the wallpaper, the images of this category can be chosen on the next dropbox."
	
	Loc ["STRING_OPTIONS_WP_GROUP2"] = "Wallpaper"
	Loc ["STRING_OPTIONS_WP_GROUP2_DESC"] = "Select the wallpaper, for more, choose a diferent category on the left dropbox."
	
	Loc ["STRING_OPTIONS_WP_ALIGN"] = "Align"
	Loc ["STRING_OPTIONS_WP_ALIGN_DESC"] = "Select how the wallpaper will align within the window instance.\n\n- |cFFFFFF00Fill|r: auto resize and align with all corners.\n\n- |cFFFFFF00Center|r: doesn`t resize and align with the center of the window.\n\n-|cFFFFFF00Stretch|r: auto resize on vertical or horizontal and align with left-right or top-bottom sides.\n\n-|cFFFFFF00Four Corners|r: align with specified corner, no auto resize is made."
	
	Loc ["STRING_OPTIONS_WP_EDIT"] = "Edit Image"
	Loc ["STRING_OPTIONS_WP_EDIT_DESC"] = "Open the image editor to change some wallpaper aspects."

	Loc ["STRING_OPTIONS_SAVELOAD"] = "Save and Load"
	Loc ["STRING_OPTIONS_SAVELOAD_DESC"] = "This options allow you to save or load predefined settings."
	


	Loc ["STRING_OPTIONS_MISCTITLE"] = "Miscellaneous Settings"
	Loc ["STRING_OPTIONS_MISCTITLE2"] = "This options controls several options."
	
-- Mini Tutorials -----------------------------------------------------------------------------------------------------------------

	Loc ["STRING_MINITUTORIAL_1"] = "Window Instance Button:\n\nClick to open a new Details! window.\n\nMouse over to reopen closed instances."
	Loc ["STRING_MINITUTORIAL_2"] = "Stretch Button:\n\nClick, hold and pull to stretch the window.\n\nRelease the button to restore normal size."
	Loc ["STRING_MINITUTORIAL_3"] = "Resize and Lock Buttons:\n\nUse this to change the size of the window.\n\nLocking it, make the window unmovable."
	Loc ["STRING_MINITUTORIAL_4"] = "Shortcut Panel:\n\nWhen you right click a bar or window background, shortcut panel is shown."
	Loc ["STRING_MINITUTORIAL_5"] = "Micro Displays:\n\nThese shows important informations.\n\nLeft Click to config.\n\nRight Click to choose other widget."
	Loc ["STRING_MINITUTORIAL_6"] = "Snap Windows:\n\nMove a window near other to snap both.\n\nAlways snap with previous instance number, example: #5 snap with #4, #2 snap with #1."
