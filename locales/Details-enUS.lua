local Loc = LibStub("AceLocale-3.0"):NewLocale("Details", "enUS", true) 
if not Loc then return end 

--------------------------------------------------------------------------------------------------------------------------------------------

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetails:|r " --> color and details name

	Loc ["STRING_YES"] = "Yes"
	Loc ["STRING_NO"] = "No"
	
	Loc ["STRING_AUTO"] = "auto"
	Loc ["STRING_LEFT"] = "left"
	Loc ["STRING_CENTER"] = "center"
	Loc ["STRING_RIGHT"] = "right"
	Loc ["STRING_TOOOLD"] = "could not be installed because your Details! version is too old."
	Loc ["STRING_TOOOLD2"] = "your Details! version isn't the same."
	
	Loc ["STRING_PLEASE_WAIT"] = "Please wait"
	
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
	Loc ["STRING_REPORT_LEFTCLICK"] = "Click to open report dialog"
	Loc ["STRING_REPORT_FIGHT"] = "fight"
	Loc ["STRING_REPORT_LAST"] = "Last" -- >last< 3 fights
	Loc ["STRING_REPORT_FIGHTS"] = "fights" -- last 3 >fights<
	Loc ["STRING_REPORT_LASTFIGHT"] = "last fight"
	Loc ["STRING_REPORT_PREVIOUSFIGHTS"] = "previous fights"
	Loc ["STRING_REPORT_INVALIDTARGET"] = "Whisper target not found"
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


	
--O modo sozinho possui plugins que irão trabalhar apenas em cima dos dados capturados do seu personagem, como o dano que ele causa, os buffs e debuffs que ele possui, entre outros.	
	
--> misc
	
	Loc ["STRING_PLAYER_DETAILS"] = "Player Details"
	Loc ["STRING_MELEE"] = "Melee"
	Loc ["STRING_AUTOSHOT"] = "Auto Shot"
	Loc ["STRING_DOT"] = " (DoT)"
	Loc ["STRING_UNKNOWSPELL"] = "Unknow Spell"
	
	Loc ["STRING_CCBROKE"] = "Crowd Control Removed"
	Loc ["STRING_DISPELLED"] = "Buffs/Debuffs Removed"
	Loc ["STRING_SPELL_INTERRUPTED"] = "Spells interrupted"
	
	
	
	



