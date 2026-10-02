local Loc = LibStub("AceLocale-3.0"):NewLocale("Details_Threat", "ruRU")

if (not Loc) then
	return 
end 

Loc ["STRING_PLUGIN_NAME"] = "Небольшая угроза"

Loc ["STRING_SLASH_ANIMATE"] = "анимация"
Loc ["STRING_SLASH_SPEED"] = "скорость"
Loc ["STRING_SLASH_AMOUNT"] = "количество"

Loc ["STRING_COMMAND_LIST"] = "Доступные команды:"
Loc ["STRING_SLASH_SPEED_DESC"] = "Изменяет частоту (в секундах) обновления окна, допускаются значения от 0.1 до 3.0"
Loc ["STRING_SLASH_SPEED_CHANGED"] = "Скорость обновления изменена на "
Loc ["STRING_SLASH_SPEED_CURRENT"] = "Текущее значение скорости обновления: "
