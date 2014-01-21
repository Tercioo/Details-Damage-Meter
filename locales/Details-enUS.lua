local Loc = LibStub("AceLocale-3.0"):NewLocale("Details", "enUS", true) 
if not Loc then return end 

--------------------------------------------------------------------------------------------------------------------------------------------
-- \n\n|cFFFFFF00-|r 
	
	
	
	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v1.9.1|r\n\n|cFFFFFF00-|r fixed issue with main window icon when no plugin installed. \n\n|cFFFFFF00-|r fixed issue with some options button text which where out of positioning.\n\n|cFFFFFF00-|r fixed sub menu overlap when near right screen edge.\n\n|cFFFFFF00-|r fixed close button position for default skin.\n\n|cFFFFFF00-|r fixed skin error when selecting solo or right plugins.|cFFFFFF00v1.9.0|r\n\n|cFFFFFF00-|r Fixed minimap icon stuck problem.\n\n|cFFFFFF00-|r Skin support has been rewrite and now is more flexibe.\n\n|cFFFFFF00-|r Added up to 20 new customization options over options panel.\n\n|cFFFFFF00v1.8.4|r\n\n|cFFFFFF00-|r Added slash command 'details reinstall' which cleans Details! config in case of erros.\n\n|cFFFFFF00v1.8.3|r\n\n|cFFFFFF00-|r Added new skin: Simple Gray.\n\n|cFFFFFF00-|r Added minimap and interface addon panel buttons.\n\n|cFFFFFF00-|r Added new tutorials bubbles for basic aspects of Details! window.\n\n|cFFFFFF00-|r Fixed a issue with Panic Mode where sometimes his isnt triggered.\n\n|cFFFFFF00v1.8.0|r\n\n|cFFFFFF00-|r Added a new plugin: You Are Not Prepared.\n\n|cFFFFFF00-|r New options panel!\n\n|cFFFFFF00v1.7.0|r\n\n- Fixed some colors issues with enimies bars.\n\n|cFFFFFF00-|r Fixed some phrases which isn't still not translated to enUS.\n\n|cFFFFFF00-|r Major rewrite on CC-Breaks, now it's working properly.\n\n|cFFFFFF00-|r Added new sub attribute for damage: Voidzones & Debuffs.|cFFFFFF00v1.6.7|r\n\n- Added support to skins, you can change over options panel.\n\n|cFFFFFF00v1.6.5|r\n\n|cFFFFFF00-|r Added sub attribute 'Enemies' which shows, of course, only enemies.\n\n|cFFFFFF00-|r Fixed issue with successful spell cast.\n\n|cFFFFFF00v1.6.3|r\n\n|cFFFFFF00-|r data capture now runs 4% faster.\n\n|cFFFFFF00-|r Fixed issue with pets were wasn't uptading owner activity time.\n\n|cFFFFFF00-|r Fixed healing being counted even out of combat.\n\n|cFFFFFF00-|r Fixed some problems with multi-boss encountes like Twin Consorts.\n\n|cFFFFFF00-|r Added options for concatenate trash segments.\n\n|cFFFFFF00-|r Added options for auto remove trash segments. \n\n|cFFFFFF00-|r Added options for change bar height. \n\n|cFFFFFF00-|r Encounter Details now display how many interrupted and successful cast of a boss skill.\n\n|cFFFFFF00v1.6.1|r\n\n|cFFFFFF00-|r Fixed:\n- a issue with debuff uptime.\n- overall data dps and hps for overall data on micro display.\n- many bugs involving sword and book menus.\n- garbage collector erasing actors with interactions with your group members.\n\n|cFFFFFF00-|r overall data now always use the combat data for measure dps and hps."

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
	Loc ["STRING_MINIMAP_TOOLTIP2"] = "|cFFCFCFCFright click|r: quick menu"
	
	Loc ["STRING_MINIMAPMENU_NEWWINDOW"] = "Create New Window"
	Loc ["STRING_MINIMAPMENU_RESET"] = "Reset"
	Loc ["STRING_MINIMAPMENU_REOPEN"] = "Reopen Window"
	Loc ["STRING_MINIMAPMENU_REOPENALL"] = "Reopen All"
	Loc ["STRING_MINIMAPMENU_UNLOCK"] = "Unlock"
	Loc ["STRING_MINIMAPMENU_LOCK"] = "Lock"
	
	Loc ["STRING_RESETBUTTON_WRONG_INSTANCE"] = "Warning, reset button isn't in the current editing instance."
	
	Loc ["STRING_INTERFACE_OPENOPTIONS"] = "Open Options Panel"
		
	Loc ["STRING_RIGHTCLICK_TYPEVALUE"] = "right click to type the value"
	Loc ["STRING_TOOOLD"] = "could not be installed because your Details! version is too old."
	Loc ["STRING_TOOOLD2"] = "your Details! version isn't the same."
	Loc ["STRING_CHANGED_TO_CURRENT"] = "Segment changed to current"
	Loc ["STRING_SEGMENT_TRASH"] = "Next Boss Cleanup"
	Loc ["STRING_VERSION_UPDATE"] = "new version: what's changed? click here"
	Loc ["STRING_NEWS_TITLE"] = "What's New In This Version"
	Loc ["STRING_NEWS_REINSTALL"] = "Found problems after a update? try '/details reinstall' command."
	Loc ["STRING_TIME_OF_DEATH"] = "Death"
	Loc ["STRING_SHORTCUT_RIGHTCLICK"] = "Shortcut Menu (right click to close)"
	
	Loc ["STRING_NO_DATA"] = "data already has been cleaned"
	Loc ["STRING_ISA_PET"] = "This Actor is a Pet"
	Loc ["STRING_EQUILIZING"] = "Sharing encounter data"
	Loc ["STRING_LEFT_CLICK_SHARE"] = "Left click to report."
	
	Loc ["STRING_LAST_COOLDOWN"] = "last cooldown used"
	Loc ["STRING_NOLAST_COOLDOWN"] = "no cooldown used"
	
	Loc ["STRING_INSTANCE_LIMIT"] = "max instance number has been reached, you can modify this limit on options panel."
	
	Loc ["STRING_PLEASE_WAIT"] = "Please wait"
	Loc ["STRING_UPTADING"] = "updating"
	
	Loc ["STRING_RAID_WIDE"] = "[*] raid wide cooldown"
	
	Loc ["STRING_RIGHTCLICK_CLOSE_SHORT"] = "Right click to close."
	Loc ["STRING_RIGHTCLICK_CLOSE_MEDIUM"] = "Use right click to close this window."
	Loc ["STRING_RIGHTCLICK_CLOSE_LARGE"] = "Click with right mouse button to close this window."

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
	Loc ["STRING_UNKNOW"] = "Unknow"
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
	
	Loc ["STRING_MODE_SELF"] = "Lone Wolf"
	Loc ["STRING_MODE_RAID"] = "Widgets"
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
		Loc ["STRING_ATTRIBUTE_DAMAGE_DPS"] = "Damage Per Second"
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
		Loc ["STRING_ATTRIBUTE_HEAL_HPS"] = "Healing Per Second"
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
	Loc ["STRING_GERAL"] = "Geral"
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
	Loc ["STRING_PLAYERS"] = "Players"
	
	Loc ["STRING_HPS"] = "Hps"
	Loc ["STRING_HEAL"] = "Heal"
	Loc ["STRING_HEAL_CRIT"] = "Heal Critical"
	Loc ["STRING_HEAL_ABSORBED"] = "Heal absorbed"
	Loc ["STRING_OVERHEAL"] = "Overheal"
	Loc ["STRING_"] = ""
	
----------------	
--> BuiltIn Plugins

	Loc ["STRING_PLUGIN_MINSEC"] = "Minutes & Seconds"
	Loc ["STRING_PLUGIN_SECONLY"] = "Seconds Only"
	Loc ["STRING_PLUGIN_TIMEDIFF"] = "Last Combat Difference"
	
	Loc ["STRING_PLUGIN_TOOLTIP_LEFTBUTTON"] = "Config current plugin"
	Loc ["STRING_PLUGIN_TOOLTIP_RIGHTBUTTON"] = "Choose another plugin"

	Loc ["STRING_PLUGIN_CLOCKTYPE"] = "Clock Type"
	
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
	
	Loc ["STRING_OPTIONS_COLOR"] = "Color"
	Loc ["STRING_OPTIONS_SIZE"] = "Size"
	Loc ["STRING_OPTIONS_ANCHOR"] = "Side"


	Loc ["ABILITY_ID"] = "ability id"
	
--> Details Instances

	Loc ["STRING_SOLO_SWITCHINCOMBAT"] = "Cannot switch while in combat"
	Loc ["STRING_CUSTOM_NEW"] = "Create New"
	Loc ["STRING_CUSTOM_REPORT"] = "Report for (custom)"
	Loc ["STRING_REPORT"] = "Report for"
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
	Loc ["STRING_NOCLOSED_INSTANCES"] = "There are no closed instances,\nclick to open a new one."
	
--> report frame

	Loc ["STRING_REPORTFRAME_PARTY"] = "Party"
	Loc ["STRING_REPORTFRAME_RAID"] = "Raid"
	Loc ["STRING_REPORTFRAME_GUILD"] = "Guild"
	Loc ["STRING_REPORTFRAME_OFFICERS"] = "Officer Channel"
	Loc ["STRING_REPORTFRAME_WHISPER"] = "Whisper"
	Loc ["STRING_REPORTFRAME_WHISPERTARGET"] = "Whisper Target"
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

	Loc ["STRING_LOCK_WINDOW"] = "lock"
	Loc ["STRING_UNLOCK_WINDOW"] = "unlock"
	Loc ["STRING_ERASE"] = "delete"
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

	Loc ["STRING_OPTIONS_SWITCHINFO"] = "|cFFF79F81 LEFT DISABLED|r  |cFF81BEF7 RIGHT ENABLED|r"
	
	Loc ["STRING_OPTIONS_PICKCOLOR"] = "color"
	Loc ["STRING_OPTIONS_EDITIMAGE"] = "Edit Image"
	
	Loc ["STRING_OPTIONS_PRESETTOOLD"] = "This preset requires a newer version of Details!."
	Loc ["STRING_OPTIONS_PRESETNONAME"] = "Give a name to your preset."
	
	Loc ["STRING_OPTIONS_EDITINSTANCE"] = "Editing Instance:"
	
	Loc ["STRING_OPTIONS_GENERAL"] = "General Settings"
	Loc ["STRING_OPTIONS_APPEARANCE"] = "Appearance"
	Loc ["STRING_OPTIONS_PERFORMANCE"] = "Performance"
	Loc ["STRING_OPTIONS_SOCIAL"] = "Social"
	Loc ["STRING_OPTIONS_SOCIAL_DESC"] = "Tell how do you want to be known in your guild enviorement."
	Loc ["STRING_OPTIONS_NICKNAME"] = "Nickname"
	Loc ["STRING_OPTIONS_NICKNAME_DESC"] = "Type your nickname in this box. The chosen nickname will be broadcasted for members of your guild and Details! shown it instead of your character name."
	Loc ["STRING_OPTIONS_AVATAR"] = "Choose Avatar"
	Loc ["STRING_OPTIONS_AVATAR_DESC"] = "Your avatar is also broadcasted for your guild mates and Details! show it on the top of tooltips when you mouse over a bar."
	Loc ["STRING_OPTIONS_REALMNAME"] = "Remove Realm Name"
	Loc ["STRING_OPTIONS_REALMNAME_DESC"] = "When enabled, the realm name of character isn't displayed with his name.\n\n|cFFFFFFFFExample:|r\n\nCharles-Netherwing |cFFFFFFFF(disabled)|r\nCharles |cFFFFFFFF(enabled)|r"
	
	Loc ["STRING_OPTIONS_MAXSEGMENTS"] = "Max. Segments"
	Loc ["STRING_OPTIONS_MAXSEGMENTS_DESC"] = "This option control how many segments you want to maintain.\n\nRecommended value is |cFFFFFFFF12|r, but feel free to adjust this number to be comfortable for you.\n\nComputers with |cFFFFFFFF2GB|r or less memory ram should keep low segments amount, this can help your system overall."
	
	Loc ["STRING_OPTIONS_SCROLLBAR"] = "Scroll Bar"
	Loc ["STRING_OPTIONS_SCROLLBAR_DESC"] = "Enable ou Disable the scroll bar.\n\nBy default, Details! scroll bars are replaced by a mechanism that stretches the window.\n\nThe |cFFFFFFFFstretch handle|r is outside over instances button/menu (left of close button)."
	Loc ["STRING_OPTIONS_MAXINSTANCES"] = "Max. Instances"
	Loc ["STRING_OPTIONS_MAXINSTANCES_DESC"] = "Limit the number of Details! instances which can be created.\n\nYou can open and re-open instances clicking on the instance button |cFFFFFFFF#X|r."
	Loc ["STRING_OPTIONS_PVPFRAGS"] = "Only Pvp Frags"
	Loc ["STRING_OPTIONS_PVPFRAGS_DESC"] = "When enabled, only kills against enemy players will be count."
	Loc ["STRING_OPTIONS_MINIMAP"] = "Minimap Icon"
	Loc ["STRING_OPTIONS_MINIMAP_DESC"] = "Show or Hide minimap icon."
	Loc ["STRING_OPTIONS_TIMEMEASURE"] = "Time Measure"
	Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"] = "|cFFFFFFFFActivity|r: the timer of each raid member is put on hold if his activity is ceased and back again to count when is resumed, common way of mensure Dps and Hps.\n\n|cFFFFFFFFEffective|r: used on rankings, this method uses the elapsed combat time for mensure the Dps and Hps of all raid members."
	
	Loc ["STRING_OPTIONS_PERFORMANCE1"] = "Performance Tweaks"
	Loc ["STRING_OPTIONS_PERFORMANCE1_DESC"] = "This options can help save some cpu usage."
	
	Loc ["STRING_OPTIONS_MEMORYT"] = "Memory Threshold"
	Loc ["STRING_OPTIONS_MEMORYT_DESC"] = "Details! have internal mechanisms to handle memory and try adjust it self within the amount of memory avaliable on your system.\n\nAlso is recommeded keep the amount of segments low on systems with |cFFFFFFFF2GB|r or less of memory."
	
	Loc ["STRING_OPTIONS_SEGMENTSSAVE"] = "Segments Saved"
	Loc ["STRING_OPTIONS_SEGMENTSSAVE_DESC"] = "This options controls how many segments you wish save between game sesions.\n\nHigh values can make your character logoff take more time\n\nIf you rarelly use the data of last day, it`s high recommeded leave this option in |cFFFFFFFF1|r."
	
	Loc ["STRING_OPTIONS_PANIMODE"] = "Panic Mode"
	Loc ["STRING_OPTIONS_PANIMODE_DESC"] = "When enabled and you got dropped from the game (by a disconnect, for instance) and you are fighting against a boss encounter, all segments are erased, this make your logoff process faster."
	
	Loc ["STRING_OPTIONS_ANIMATEBARS"] = "Animate Bars"
	Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"] = "Instead of 'jumping' all bars moves to the left or right when this options is activated."
	
	Loc ["STRING_OPTIONS_ANIMATESCROLL"] = "Animate Scroll Bar"
	Loc ["STRING_OPTIONS_ANIMATESCROLL_DESC"] = "When enabled, scrollbar uses a animation when showing up or hiding."
	
	Loc ["STRING_OPTIONS_WINDOWSPEED"] = "Update Speed"
	Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"] = "Seconds between each update on instances (opened windows).\n\n|cFFFFFFFF0.3|r: update about 3 times each second.\n\n|cFFFFFFFF3.0|r: update once every 3 seconds."
	
	Loc ["STRING_OPTIONS_CLEANUP"] = "Auto Erase Cleanup Segments"
	Loc ["STRING_OPTIONS_CLEANUP_DESC"] = "Segments with trash mobs' are considered clean up segments.\n\nThis option enable the auto erase of this segments when possible."
	
	Loc ["STRING_OPTIONS_PERFORMANCECAPTURES"] = "Data Collector"
	Loc ["STRING_OPTIONS_PERFORMANCECAPTURES_DESC"] = "This options are responsible for analysis and collect combat data."
	
	
	Loc ["STRING_OPTIONS_CDAMAGE"] = "Collect Damage"
	Loc ["STRING_OPTIONS_CHEAL"] = "Collect Heal"
	Loc ["STRING_OPTIONS_CENERGY"] = "Collect Energy"
	Loc ["STRING_OPTIONS_CMISC"] = "Collect Misc"
	Loc ["STRING_OPTIONS_CAURAS"] = "Collect Auras"
	
	Loc ["STRING_OPTIONS_CDAMAGE_DESC"] = "Enable capture of:\n\n- |cFFFFFFFFDamage Done|r\n- |cFFFFFFFFDamage Per Second|r\n- |cFFFFFFFFFriendly Fire|r\n- |cFFFFFFFFDamage Taken|r"
	Loc ["STRING_OPTIONS_CHEAL_DESC"] = "Enable capture of:\n\n- |cFFFFFFFFHealing Done|r\n- |cFFFFFFFFAbsorbs|r\n- |cFFFFFFFFHealing Per Second|r\n- |cFFFFFFFFOverhealing|r\n- |cFFFFFFFFHealing Taken|r\n- |cFFFFFFFFEnemy Healed|r\n- |cFFFFFFFFDamage Prevented|r"
	Loc ["STRING_OPTIONS_CENERGY_DESC"] = "Enable capture of:\n\n- |cFFFFFFFFMana Restored|r\n- |cFFFFFFFFRage Generated|r\n- |cFFFFFFFFEnergy Generated|r\n- |cFFFFFFFFRunic Power Generated|r"
	Loc ["STRING_OPTIONS_CMISC_DESC"] = "Enable capture of:\n\n- |cFFFFFFFFCrowd Control Break|r\n- |cFFFFFFFFDispells|r\n- |cFFFFFFFFInterrupts|r\n- |cFFFFFFFFResurrection|r\n- |cFFFFFFFFDeaths|r"
	Loc ["STRING_OPTIONS_CAURAS_DESC"] = "Enable capture of:\n\n- |cFFFFFFFFBuffs Uptime|r\n- |cFFFFFFFFDebuffs Uptime|r\n- |cFFFFFFFFVoid Zones|r\n-|cFFFFFFFF Cooldowns|r"
	
	Loc ["STRING_OPTIONS_CLOUD"] = "Cloud Capture"
	Loc ["STRING_OPTIONS_CLOUD_DESC"] = "When enabled, the data of disabled collectors are collected within others raid members."
	
	Loc ["STRING_OPTIONS_BARS"] = "Bar General Settings"
	Loc ["STRING_OPTIONS_BARS_DESC"] = "This options control the appearance of the instance bars."

	Loc ["STRING_OPTIONS_BAR_TEXTURE"] = "Texture"
	Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"] = "Choose the texture of bars."
	
	Loc ["STRING_OPTIONS_BAR_BTEXTURE"] = "Texture (bg)"
	Loc ["STRING_OPTIONS_BAR_BTEXTURE_DESC"] = "Choose the background texture of bars."
	
	Loc ["STRING_OPTIONS_BAR_BCOLOR"] = "Background Color"
	Loc ["STRING_OPTIONS_BAR_BCOLOR_DESC"] = "Choose the background color of bars."
	
	Loc ["STRING_OPTIONS_BAR_HEIGHT"] = "Height"
	Loc ["STRING_OPTIONS_BAR_HEIGHT_DESC"] = "Change the height of bars."
	
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"] = "Color By Class"
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"] = "When enabled, the instance bars have the color of the character class.\n\nIf disabled, the color chosen on the right box will be used."
	
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2"] = "Color By Class (bg)"
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2_DESC"] = "When enabled, the instance bars  background have the color of the character class.\n\nIf disabled, the color chosen on the right box will be used."
	--
	Loc ["STRING_OPTIONS_TEXT"] = "Bar Text Settings"
	Loc ["STRING_OPTIONS_TEXT_DESC"] = "This options control the appearance of the instance bar texts."
	
	Loc ["STRING_OPTIONS_TEXT_SIZE"] = "Size"
	Loc ["STRING_OPTIONS_TEXT_SIZE_DESC"] = "Change the size of bar texts."
	
	Loc ["STRING_OPTIONS_TEXT_FONT"] = "Font"
	Loc ["STRING_OPTIONS_TEXT_FONT_DESC"] = "Change the font of bar texts."
	
	Loc ["STRING_OPTIONS_TEXT_LOUTILINE"] = "Left Text Outline"
	Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"] = "Enable or Disable the outline for left text."
	
	Loc ["STRING_OPTIONS_TEXT_ROUTILINE"] = "Right Text Outline"
	Loc ["STRING_OPTIONS_TEXT_ROUTILINE_DESC"] = "Enable or Disable the outline for right text."
	
	Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR"] = "Left Text Color By Class"
	Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"] = "When enabled, the left text uses the class color of the character.\n\nIf disabled, choose the color on the color picker button."
	
	Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR"] = "Right Text Color By Class"
	Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"] = "When enabled, the right text uses the class color of the character.\n\nIf disabled, choose the color on the color picker button."
	--
	Loc ["STRING_OPTIONS_INSTANCE"] = "Instance Settings"
	Loc ["STRING_OPTIONS_INSTANCE_DESC"] = "This options control the appearance of the instance it self."
	
	Loc ["STRING_OPTIONS_INSTANCE_COLOR"] = "Color and Transparency"
	Loc ["STRING_OPTIONS_INSTANCE_COLOR_DESC"] = "Change the color and alpha of instance window."
	
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA"] = "Background Alpha"
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA_DESC"] = "This option let you change the transparency of the instance window background."
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA2"] = "Background Color"
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA2_DESC"] = "This option let you change the color of the instance window background."
	
	Loc ["STRING_OPTIONS_INSTANCE_CURRENT"] = "Auto Switch To Current"
	Loc ["STRING_OPTIONS_INSTANCE_CURRENT_DESC"] = "Whenever a combat start and there is no other instance on current segment, this instance auto switch to current segment."

	Loc ["STRING_OPTIONS_SHOW_SIDEBARS"] = "Show Borders"
	Loc ["STRING_OPTIONS_SHOW_SIDEBARS_DESC"] = "Show or hide window borders."
	
	Loc ["STRING_OPTIONS_SHOW_STATUSBAR"] = "Show Statusbar"
	Loc ["STRING_OPTIONS_SHOW_STATUSBAR_DESC"] = "Show or hide the bottom statusbar."
	
	Loc ["STRING_OPTIONS_INSTANCE_SKIN"] = "Skin"
	Loc ["STRING_OPTIONS_INSTANCE_SKIN_DESC"] = "Modify window appearance based on a skin theme."
	
Loc ["STRING_OPTIONS_SKIN_A"] = "Skin Settings"
Loc ["STRING_OPTIONS_SKIN_A_DESC"] = "This options allows you to change the skin."

Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS"] = "Toolbar Settings"
Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS_DESC"] = "This options change the main menu on the top of the window."
	
Loc ["STRING_OPTIONS_DESATURATE_MENU"] = "Desaturate Menu"
Loc ["STRING_OPTIONS_DESATURATE_MENU_DESC"] = "Enabling this option, all menu icons on toolbar became black and white."

Loc ["STRING_OPTIONS_HIDE_ICON"] = "Hide Icon"
Loc ["STRING_OPTIONS_HIDE_ICON_DESC"] = "When enabled, the icon on the top left corner isn't draw.\n\nSome skins may prefer remove this icon."

Loc ["STRING_OPTIONS_MENU_X"] = "Menu Pos X"
Loc ["STRING_OPTIONS_MENU_X_DESC"] = "Slightly move the main menu on tooltip to the left or right direction."

Loc ["STRING_OPTIONS_MENU_Y"] = "Menu Pos Y"
Loc ["STRING_OPTIONS_MENU_Y_DESC"] = "Slightly move the main menu on tooltip to the up or down direction."

Loc ["STRING_OPTIONS_RESET_TEXTCOLOR"] = "Reset Text Color"
Loc ["STRING_OPTIONS_RESET_TEXTCOLOR_DESC"] = "Modify the reset button text color.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_RESET_TEXTFONT"] = "Reset Text Font"
Loc ["STRING_OPTIONS_RESET_TEXTFONT_DESC"] = "Modify the reset button text font.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_RESET_TEXTSIZE"] = "Reset Text Size"
Loc ["STRING_OPTIONS_RESET_TEXTSIZE_DESC"] = "Modify the reset button text size.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_RESET_OVERLAY"] = "Reset Overlay Color"
Loc ["STRING_OPTIONS_RESET_OVERLAY_DESC"] = "Modify the reset button overlay color.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_RESET_SMALL"] = "Reset Always Small"
Loc ["STRING_OPTIONS_RESET_SMALL_DESC"] = "When enabled, reset button always shown as his smaller size.\n\nOnly applied when reset button is hosted by this instance."

Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR"] = "Instance Text Color"
Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR_DESC"] = "Change the instance button text color."

Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT"] = "Instance Text Font"
Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT_DESC"] = "Change the instance button text font."

Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE"] = "Instance Text Size"
Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE_DESC"] = "Change the instance button text size."

Loc ["STRING_OPTIONS_INSTANCE_OVERLAY"] = "Instance Overlay Color"
Loc ["STRING_OPTIONS_INSTANCE_OVERLAY_DESC"] = "Change the instance button overlay color."

Loc ["STRING_OPTIONS_CLOSE_OVERLAY"] = "Close Overlay Color"
Loc ["STRING_OPTIONS_CLOSE_OVERLAY_DESC"] = "Change the close button overlay color."

Loc ["STRING_OPTIONS_STRETCH"] = "Stretch Button Anchor"
Loc ["STRING_OPTIONS_STRETCH_DESC"] = "Alternate the stretch button position.\n\nTop: the grab is placed on the top right corner.\n\nBottom: the grab is placed on the bottom center."

Loc ["STRING_OPTIONS_PICONS_DIRECTION"] = "Plugin Icons Direction"
Loc ["STRING_OPTIONS_PICONS_DIRECTION_DESC"] = "Change the direction which plugins icons are displayed on the toolbar."

Loc ["STRING_OPTIONS_INSBUTTON_X"] = "Instance Button X"
Loc ["STRING_OPTIONS_INSBUTTON_X_DESC"] = "Change the instance button position."

Loc ["STRING_OPTIONS_INSBUTTON_Y"] = "Instance Button Y"
Loc ["STRING_OPTIONS_INSBUTTON_Y_DESC"] = "Change the instance button position."

Loc ["STRING_OPTIONS_TOOLBARSIDE"] = "Toolbar Anchor"
Loc ["STRING_OPTIONS_TOOLBARSIDE_DESC"] = "Place the toolbar on the top or bottom side of window."

Loc ["STRING_OPTIONS_BARGROW_DIRECTION"] = "Bar Grow Direction"
Loc ["STRING_OPTIONS_BARGROW_DIRECTION_DESC"] = "Change the bars grow method.."

Loc ["STRING_OPTIONS_BARSORT_DIRECTION"] = "Bar Sort Direction"
Loc ["STRING_OPTIONS_BARSORT_DIRECTION_DESC"] = "Change the order which characters are shown within the bars."
	
	Loc ["STRING_OPTIONS_WP"] = "Wallpaper Settings"
	Loc ["STRING_OPTIONS_WP_DESC"] = "This options control the wallpaper of instance."
	
	Loc ["STRING_OPTIONS_WP_ENABLE"] = "Show"
	Loc ["STRING_OPTIONS_WP_ENABLE_DESC"] = "Enable or Disable the wallpaper of the instance.\n\nSelect the category and the image you want on the two following boxes."
	
	Loc ["STRING_OPTIONS_WP_GROUP"] = "Category"
	Loc ["STRING_OPTIONS_WP_GROUP_DESC"] = "In this box, you select the group of the wallpaper, the images of this category can be chosen on the next dropbox."
	
	Loc ["STRING_OPTIONS_WP_GROUP2"] = "Wallpaper"
	Loc ["STRING_OPTIONS_WP_GROUP2_DESC"] = "Select the wallpaper, for more, choose a diferent category on the left dropbox."
	
	Loc ["STRING_OPTIONS_WP_ALIGN"] = "Align"
	Loc ["STRING_OPTIONS_WP_ALIGN_DESC"] = "Select how the wallpaper will align within the window instance.\n\n- |cFFFFFFFFFill|r: auto resize and align with all corners.\n\n- |cFFFFFFFFCenter|r: doesn`t resize and align with the center of the window.\n\n-|cFFFFFFFFStretch|r: auto resize on vertical or horizontal and align with left-right or top-bottom sides.\n\n-|cFFFFFFFFFour Corners|r: align with specified corner, no auto resize is made."
	
	Loc ["STRING_OPTIONS_WP_EDIT"] = "Edit Image"
	Loc ["STRING_OPTIONS_WP_EDIT_DESC"] = "Open the image editor to change some wallpaper aspects."

	Loc ["STRING_OPTIONS_SAVELOAD"] = "Save and Load"
	Loc ["STRING_OPTIONS_SAVELOAD_DESC"] = "This options allow you to save or load predefined settings."
	
	Loc ["STRING_OPTIONS_SAVELOAD_PNAME"] = "Preset Name"
	Loc ["STRING_OPTIONS_SAVELOAD_SAVE"] = "save"
	Loc ["STRING_OPTIONS_SAVELOAD_LOAD"] = "load"
	Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"] = "x"
	Loc ["STRING_OPTIONS_SAVELOAD_RESET"] = "reset to default"
	Loc ["STRING_OPTIONS_SAVELOAD_APPLYTOALL"] = "apply to all instances"

-- Mini Tutorials -----------------------------------------------------------------------------------------------------------------

	Loc ["STRING_MINITUTORIAL_1"] = "Window Instance Button:\n\nClick to open a new Details! window.\n\nMouse over to reopen closed instances."
	Loc ["STRING_MINITUTORIAL_2"] = "Stretch Button:\n\nClick, hold and pull to stretch the window.\n\nRelease the button to restore normal size."
	Loc ["STRING_MINITUTORIAL_3"] = "Resize and Lock Buttons:\n\nUse this to change the size of the window.\n\nLocking it, make the window unmovable."
	Loc ["STRING_MINITUTORIAL_4"] = "Shortcut Panel:\n\nWhen you right click a bar or window background, shortcut panel is shown."
	Loc ["STRING_MINITUTORIAL_5"] = "Micro Displays:\n\nThese shows important informations.\n\nLeft Click to config.\n\nRight Click to choose other widget."
	Loc ["STRING_MINITUTORIAL_6"] = "Snap Windows:\n\nMove a window near other to snap both.\n\nAlways snap with previous instance number, example: #5 snap with #4, #2 snap with #1."