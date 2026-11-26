local Loc = LibStub("AceLocale-3.0"):NewLocale("Details_Vanguard", "ruRU") 

if (not Loc) then
	return 
end 


Loc["STRING_PLUGIN_NAME"] = "Vanguard"
Loc["STRING_HEALVSDAMAGETOOLTIP"] = "Входящее исцеление - это ожидаемое количество исцеления за следующие секунды.\nВходящий урон рассчитывается Vanguard по среднему урону,\nполученному за последние секунды.\n\n|cff33CC00Нажмите для получения дополнительной информации."
Loc["STRING_AVOIDVSHITSTOOLTIP"] = "Это количество уклонений и парирований против\nколичества успешных попаданий, полученных за последние несколько секунд.\n\n|cff33CC00Нажмите для получения дополнительной информации."
Loc["STRING_DAMAGESCROLL"] = "Последнее полученное количество урона."
Loc["STRING_REPORT"] = "Отчёт Details Vanguard"
Loc["STRING_REPORT_AVOIDANCE"] = "Статистика избегания для"
Loc["STRING_REPORT_AVOIDANCE_TOOLTIP"] = "Отправить отчёт об избегании"

Loc["STRING_HEALRECEIVED"] = "Полученное исцеление"
Loc["STRING_HPS"] = "RHPS"
Loc["STRING_HITS"] = "Полученные попадания"
Loc["STRING_DODGE"] = "Уклонение"
Loc["STRING_PARRY"] = "Парирование"
Loc["STRING_DAMAGETAKEN"] = "Полученный урон"
Loc["STRING_DTPS"] = "DTPS"
Loc["STRING_DEBUFF"] = "Дебафф"
Loc["STRING_DURATION"] = "Длительность"
