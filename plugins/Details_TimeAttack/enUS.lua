local Loc = LibStub("AceLocale-3.0"):NewLocale("Details_TimeAttack", "enUS", true) 

if (not Loc) then
	return 
end 

Loc ["STRING_PLUGIN_NAME"] = "Time Attack"
Loc ["STRING_TIME_SELECTION"] = "Select the amount of time (seconds):"
Loc ["STRING_SAVE"] = "Save"
Loc ["STRING_SAVED"] = "Saved"
Loc ["STRING_SAVERECORD"] = "save record"
Loc ["STRING_REMOVERECORD"] = "remove record"
Loc ["STRING_RECENTLY"] = "Recently"
Loc ["STRING_SETNOTE"] = "set note"
Loc ["STRING_SECONDS"] = "seconds"
Loc ["STRING_COMBATFAIL"] = "Combat wasn't started by you, try leave your group or raid."
Loc ["STRING_HELP"] = "Use timeattack to measure your damage within a certain time window. You can choose the amount of time from on the slider bar below. After reaching the time you can save the attempt to compare with others attempts in the future. When you save an attempt, Timeattack record your item level and the date together with the damage and time."

Loc ["STRING_REPORT"] = "Details Time Attack Report"
Loc ["STRING_DAMAGEOVER"] = "damage over"
Loc ["STRING_AVERAGEDPS"] = "Average DPS of"
Loc ["STRING_WITH"] = "with"
Loc ["STRING_ITEMLEVEL"] = "gear score"