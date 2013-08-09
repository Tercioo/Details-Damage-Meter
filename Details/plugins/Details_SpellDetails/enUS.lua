local Loc = LibStub("AceLocale-3.0"):NewLocale("Details_SpellDetails", "enUS", true) 

if (not Loc) then
	return 
end 

Loc ["PLUGIN_NAME"] = "Spell Details"
Loc ["STRING_TOOSHORT"] = "Combat time was too short \n and the graph cannot be generated."

Loc ["STRING_DAMAGE"] = "DMG"
Loc ["STRING_DPS"] = "DPS"
Loc ["STRING_TEMPO"] = "TIME"
Loc ["STRING_PERCENT"] = "Percent"
Loc ["STRING_UPTIME"] = "Uptime"
Loc ["STRING_CRIT"] = "Critical"
Loc ["STRING_MISS"] = "Miss"
Loc ["STRING_BLOCKED"] = "Blocked"	
Loc ["STRING_GLANCING"] = "Glancing"
Loc ["STRING_DEBUFFNAME"] = "insert buff name"
Loc ["STRING_INCOMBAT"] = "You are in combat"
