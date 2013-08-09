local Loc = LibStub("AceLocale-3.0"):NewLocale("Details", "enUS", true) 
if not Loc then return end 

--------------------------------------------------------------------------------------------------------------------------------------------

	Loc ["STRING_AUTO"] = "auto"
	Loc ["STRING_LEFT"] = "left"
	Loc ["STRING_CENTER"] = "center"
	Loc ["STRING_RIGHT"] = "right"
	Loc ["STRING_TOOOLD"] = "could not be installed because your Details! version is too old."

--> Slash
	Loc ["STRING_SLASH_NEW"] = "new"

--> StatusBar Plugins
	Loc ["STRING_STATUSBAR_NOOPTIONS"] = "This widget doesn't have options."

--> Fights and Segments

	Loc ["STRING_SEGMENT"] = "Segment"
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
	Loc ["STRING_CUSTOM_TOOLTIPSPELL"] = "Select a boss ability from the menu on the right or type the spell name to filter."
	Loc ["STRING_CUSTOM_TOOLTIPSOURCE"] = "Spell source allow:\n|cFF00FF00[all]|r: Search for spell in all Actors.\n|cFFFF9900[raid]|r: Search only in your raid or party members.\n|cFF33CCFF[player]|r: Check only you\nAny other text will be considered an spesific Actor name."
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
	Loc ["STRING_CUSTOM_"] = ""

--> Switch Window

	Loc ["STRING_SWITCH_CLICKME"] = "left click me"
	
--> Mode Names

	Loc ["STRING_MODE_SELF"] = "Self"
	Loc ["STRING_MODE_GROUP"] = "Group"
	Loc ["STRING_MODE_ALL"] = "Everything"
	Loc ["STRING_MODE_RAID"] = "Raid"

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
		Loc ["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] = "Friendly Fire"

	
	Loc ["STRING_ATTRIBUTE_HEAL"] = "Heal"
		Loc ["STRING_ATTRIBUTE_HEAL_DONE"] = "Healing Done"
		Loc ["STRING_ATTRIBUTE_HEAL_HPS"] = "Healing Per Second"
		Loc ["STRING_ATTRIBUTE_HEAL_OVERHEAL"] = "Overhealing"
		Loc ["STRING_ATTRIBUTE_HEAL_TAKEN"] = "Healing Taken"
	
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
		
	Loc ["STRING_ATTRIBUTE_CUSTOM"] = "Custom"

--> Tooltips & Info Box	

	Loc ["STRING_SPELLS"] = "Spells"
	Loc ["STRING_NO_SPELL"] = "no spell has been used"
	Loc ["STRING_TARGET"] = "Target"
	Loc ["STRING_TARGETS"] = "Targets"
	Loc ["STRING_PET"] = "Pet"
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
	
	Loc ["STRING_PLUGIN_CLOCKNAME"] = "Encounter Time"
	Loc ["STRING_PLUGIN_PSEGMENTNAME"] = "Instance Segment"
	Loc ["STRING_PLUGIN_PDPSNAME"] = "Raid Dps"
	Loc ["STRING_PLUGIN_THREATNAME"] = "My Threat"
	Loc ["STRING_PLUGIN_PATTRIBUTENAME"] = "Attribute"
	
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
	Loc ["STRING_REPORT_FIGHT"] = "fight"
	Loc ["STRING_REPORT_LAST"] = "Last" -- >last< 3 fights
	Loc ["STRING_REPORT_FIGHTS"] = "fights" -- last 3 >fights<
	Loc ["STRING_REPORT_LASTFIGHT"] = "last fight"
	Loc ["STRING_REPORT_PREVIOUSFIGHTS"] = "previous fights"
	Loc ["STRING_REPORT_INVALIDTARGET"] = "Whisper target not found"
	
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

	Loc ["STRING_OPTIONS_WINDOW"] = "options"
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
	
--> misc
	
	Loc ["STRING_PLAYER_DETAILS"] = "Player Details"
	Loc ["STRING_MELEE"] = "Melee"
	Loc ["STRING_AUTOSHOT"] = "Auto Shot"
	Loc ["STRING_DOT"] = " (DoT)"
	Loc ["STRING_UNKNOWSPELL"] = "Unknow Spell"
	
	Loc ["STRING_CCBROKE"] = "Crowd Control Removed"
	Loc ["STRING_DISPELLED"] = "Buffs/Debuffs Removed"
	Loc ["STRING_SPELL_INTERRUPTED"] = "Spells interrupted"
	
	
	
	



