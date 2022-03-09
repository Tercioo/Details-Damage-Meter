local Loc = LibStub("AceLocale-3.0"):NewLocale("Details_Vanguard", "zhCN") 

if (not Loc) then
	return 
end 

Loc ["STRING_PLUGIN_NAME"] = "Vanguard"
Loc ["STRING_HEALVSDAMAGETOOLTIP"] = "预治疗量是指接下来几秒内预计的治疗量.\nVanguard以最后几秒受到的平均伤害\n来计算预伤害.\n\n|cff33CC00*点击查看更多信息."
Loc ["STRING_AVOIDVSHITSTOOLTIP"] = "这是对最后几秒受到的成功命中的\n闪避和格挡的数量.\n\n|cff33CC00*点击查看更多信息."
Loc ["STRING_DAMAGESCROLL"] = "最新收到的伤害量."
Loc ["STRING_REPORT"] = "Details Vanguard报告"
Loc ["STRING_REPORT_AVOIDANCE"] = "回避统计"
Loc ["STRING_REPORT_AVOIDANCE_TOOLTIP"] = "发送回避报告"

Loc ["STRING_HEALRECEIVED"] = "受到治疗"
Loc ["STRING_HPS"] = "RHPS"
Loc ["STRING_HITS"] = "受到命中"
Loc ["STRING_DODGE"] = "闪避"
Loc ["STRING_PARRY"] = "格挡"
Loc ["STRING_DAMAGETAKEN"] = "受到伤害"
Loc ["STRING_DTPS"] = "DTPS"
Loc ["STRING_DEBUFF"] = "Debuff"
Loc ["STRING_DURATION"] = "时长"
