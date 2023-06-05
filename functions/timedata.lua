
	local _
	local Details = _G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
	local addonName, Details222 = ...

	--create a namespace
	Details222.TimeCapture = {}

	--mantain the enabled time captures
	Details.timeContainer = {}
	Details.timeContainer.Exec = {}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers
	local ipairs = ipairs
	local _math_floor = math.floor
	local _pcall = pcall
	local time = time

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants

	local INDEX_NAME = 1
	local INDEX_FUNCTION = 2
	local INDEX_MATRIX = 3
	local INDEX_AUTHOR = 4
	local INDEX_VERSION = 5
	local INDEX_ICON = 6
	local INDEX_ENABLED = 7

	local DEFAULT_USER_MATRIX = {max_value = 0, last_value = 0}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--register and unregister captures


	function Details:TimeDataUpdate (index_or_name, name, func, matrix, author, version, icon, is_enabled)

		local this_capture
		if (type(index_or_name) == "number") then
			this_capture = Details.savedTimeCaptures [index_or_name]
		else
			for index, t in ipairs(Details.savedTimeCaptures) do
				if (t [INDEX_NAME] == index_or_name) then
					this_capture = t
				end
			end
		end

		if (not this_capture) then
			return false
		end

		if (this_capture.do_not_save) then
			return Details:Msg("This capture belongs to a plugin and cannot be edited.")
		end

		this_capture [INDEX_NAME] = name or this_capture [INDEX_NAME]
		this_capture [INDEX_FUNCTION] = func or this_capture [INDEX_FUNCTION]
		this_capture [INDEX_MATRIX] = matrix or this_capture [INDEX_MATRIX]
		this_capture [INDEX_AUTHOR] = author or this_capture [INDEX_AUTHOR]
		this_capture [INDEX_VERSION] = version or this_capture [INDEX_VERSION]
		this_capture [INDEX_ICON] = icon or this_capture [INDEX_ICON]

		if (is_enabled ~= nil) then
			this_capture [INDEX_ENABLED] = is_enabled
		else
			this_capture [INDEX_ENABLED] = this_capture [INDEX_ENABLED]
		end

		if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
			DetailsOptionsWindowTab17UserTimeCapturesFillPanel.MyObject:Refresh()
		end

		return true

	end

	--matrix = table containing {max_value = 0, last_value = 0}
	function Details:TimeDataRegister(name, func, matrix, author, version, icon, is_enabled, force_no_save)
		--check name
		if (not name) then
			return "Couldn't register the time capture, name was nil."
		end

		--check if the name already exists
		for index, t in ipairs(Details.savedTimeCaptures) do
			if (t [INDEX_NAME] == name) then
				return "Couldn't register the time capture, name already registred."
			end
		end

		--check function
		if (not func) then
			return "Couldn't register the time capture, invalid function."
		end

		local no_save = nil
		--passed a function means that this isn't came from a user
		--so the plugin register the capture every time it loads.
		if (type(func) == "function") then
			no_save = true

		--this a custom capture from a user, so we register a default user table for matrix
		elseif (type(func) == "string") then
			matrix = DEFAULT_USER_MATRIX

		end

		if (not no_save and force_no_save) then
			no_save = true
		end

		--check matrix
		if (not matrix or type(matrix) ~= "table") then
			return "Couldn't register the time capture, matrix was invalid."
		end

		author = author or "Unknown"
		version = version or "v1.0"
		icon = icon or [[Interface\InventoryItems\WoWUnknownItem01]]

		tinsert(Details.savedTimeCaptures, {name, func, matrix, author, version, icon, is_enabled, do_not_save = no_save})

		if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
			DetailsOptionsWindowTab17UserTimeCapturesFillPanel.MyObject:Refresh()
		end

		return true

	end

	--unregister
	function Details:TimeDataUnregister (name)
		if (type(name) == "number") then
			tremove(Details.savedTimeCaptures, name)
			if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
				DetailsOptionsWindowTab17UserTimeCapturesFillPanel.MyObject:Refresh()
			end
		else
			for index, t in ipairs(Details.savedTimeCaptures) do
				if (t [INDEX_NAME] == name) then
					tremove(Details.savedTimeCaptures, index)
					if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
						DetailsOptionsWindowTab17UserTimeCapturesFillPanel.MyObject:Refresh()
					end
					return true
				end
			end
			return false
		end
	end

	--cleanup when logout
	function Details:TimeDataCleanUpTemporary()
		local newData = {}
		for index, t in ipairs(Details.savedTimeCaptures) do
			if (not t.do_not_save) then
				tinsert(newData, t)
			end
		end
		Details.savedTimeCaptures = newData
	end

	local tick_time = 0

	--starting a combat
	function Details:TimeDataCreateChartTables()
		--create capture table
		local chartTables = {}

		--drop the last capture exec table without wiping
		local exec = {}
		Details.timeContainer.Exec = exec

		Details:SendEvent("COMBAT_CHARTTABLES_CREATING")

		--build the exec table
		for index, t in ipairs(Details.savedTimeCaptures) do
			if (t[INDEX_ENABLED]) then
				local data = {}
				chartTables[t[INDEX_NAME]] = data

				if (type(t[INDEX_FUNCTION]) == "string") then
					--user
					local func, errortext = loadstring(t[INDEX_FUNCTION])
					if (func) then
						DetailsFramework:SetEnvironment(func)
						tinsert(exec, {func = func, data = data, attributes = Details.CopyTable(t[INDEX_MATRIX]), is_user = true})
					else
						Details:Msg("|cFFFF9900error compiling script for time data (charts)|r: ", errortext)
					end
				else
					--plugin
					local func = t[INDEX_FUNCTION]
					DetailsFramework:SetEnvironment(func)
					tinsert(exec, {func = func, data = data, attributes = Details.CopyTable(t[INDEX_MATRIX])})
				end

			end
		end

		Details:SendEvent("COMBAT_CHARTTABLES_CREATED")

		tick_time = 0

		--return the capture table the to combat object
		return chartTables
	end

	local exec_user_func = function(func, attributes, data, this_second)

		local okey, result = _pcall (func, attributes)
		if (not okey) then
			Details:Msg("|cFFFF9900error on chart script function|r:", result)
			result = 0
		end

		local current = result - attributes.last_value
		data [this_second] = current

		if (current > attributes.max_value) then
			attributes.max_value = current
			data.max_value = current
		end

		attributes.last_value = result

	end

	function Details:TimeDataTick()

		tick_time = tick_time + 1

		for index, t in ipairs(Details.timeContainer.Exec) do

			if (t.is_user) then
				--by a user
				exec_user_func (t.func, t.attributes, t.data, tick_time)

			else
				--by a plugin
				t.func (t.attributes, t.data, tick_time)

			end

		end

	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--broker dps stuff

	local ToKFunctions = Details.ToKFunctions

	local broker_functions = {
		-- raid dps [1]
		function()
			local combat = Details.tabela_vigente
			local combatTime = combat:GetCombatTime()
			if (not combatTime or combatTime == 0) then
				return 0
			else
				return ToKFunctions [Details.minimap.text_format] (_, combat.totals_grupo[1] / combatTime)
			end
		end,
		-- raid hps [2]
		function()
			local combat = Details.tabela_vigente
			local combatTime = combat:GetCombatTime()
			if (not combatTime or combatTime == 0) then
				return 0
			else
				return ToKFunctions [Details.minimap.text_format] (_, combat.totals_grupo[2] / combatTime)
			end
		end
	}


	local get_combat_time = function()
		local combat_time = Details.tabela_vigente:GetCombatTime()
		local minutos, segundos = _math_floor(combat_time / 60), _math_floor(combat_time % 60)
		if (segundos < 10) then
			segundos = "0" .. segundos
		end
		return minutos .. "m " .. segundos .. "s"
	end

	local get_damage_position = function()
		local damage_container = Details.tabela_vigente [1]
		damage_container:SortByKey ("total")

		local pos = 1
		for index, actor in ipairs(damage_container._ActorTable) do
			if (actor.grupo) then
				if (actor.nome == Details.playername) then
					return pos
				end
				pos = pos + 1
			end
		end

		return 0
	end

	local get_heal_position = function()
		local heal_container = Details.tabela_vigente [2]
		heal_container:SortByKey ("total")

		local pos = 1
		for index, actor in ipairs(heal_container._ActorTable) do
			if (actor.grupo) then
				if (actor.nome == Details.playername) then
					return pos
				end
				pos = pos + 1
			end
		end

		return 0
	end

	local get_damage_diff = function()
		local damage_container = Details.tabela_vigente [1]
		damage_container:SortByKey ("total")

		local first
		local first_index
		for index, actor in ipairs(damage_container._ActorTable) do
			if (actor.grupo) then
				first = actor
				first_index = index
				break
			end
		end

		if (first) then
			if (first.nome == Details.playername) then
				local second
				local container = damage_container._ActorTable
				for i = first_index+1, #container do
					if (container[i].grupo) then
						second = container[i]
						break
					end
				end

				if (second) then
					local diff = first.total - second.total
					return "+" .. ToKFunctions [Details.minimap.text_format] (_, diff)
				else
					return "0"
				end
			else
				local player = damage_container._NameIndexTable [Details.playername]
				if (player) then
					player = damage_container._ActorTable [player]
					local diff = first.total - player.total
					return "-" .. ToKFunctions [Details.minimap.text_format] (_, diff)
				else
					return ToKFunctions [Details.minimap.text_format] (_, first.total)
				end
			end
		else
			return "0"
		end
	end

	local get_heal_diff = function()
		local heal_container = Details.tabela_vigente [2]
		heal_container:SortByKey ("total")

		local first
		local first_index
		for index, actor in ipairs(heal_container._ActorTable) do
			if (actor.grupo) then
				first = actor
				first_index = index
				break
			end
		end

		if (first) then
			if (first.nome == Details.playername) then
				local second
				local container = heal_container._ActorTable
				for i = first_index+1, #container do
					if (container[i].grupo) then
						second = container[i]
						break
					end
				end

				if (second) then
					local diff = first.total - second.total
					return "+" .. ToKFunctions [Details.minimap.text_format] (_, diff)
				else
					return "0"
				end
			else
				local player = heal_container._NameIndexTable [Details.playername]
				if (player) then
					player = heal_container._ActorTable [player]
					local diff = first.total - player.total
					return "-" .. ToKFunctions [Details.minimap.text_format] (_, diff)
				else
					return ToKFunctions [Details.minimap.text_format] (_, first.total)
				end
			end
		else
			return "0"
		end
	end

	local get_player_dps = function()
		local damage_player = Details.tabela_vigente(1, Details.playername)
		if (damage_player) then
			if (Details.time_type == 1) then --activity time
				local combat_time = damage_player:Tempo()
				if (combat_time > 0) then
					return ToKFunctions [Details.minimap.text_format] (_, damage_player.total / combat_time)
				else
					return 0
				end
			else --effective time
				local combat_time = Details.tabela_vigente:GetCombatTime()
				if (combat_time > 0) then
					return ToKFunctions [Details.minimap.text_format] (_, damage_player.total / combat_time)
				else
					return 0
				end
			end
			return 0
		else
			return 0
		end
	end

	local get_player_hps = function()
		local heal_player = Details.tabela_vigente(2, Details.playername)
		if (heal_player) then
			if (Details.time_type == 1) then --activity time
				local combat_time = heal_player:Tempo()
				if (combat_time > 0) then
					return ToKFunctions [Details.minimap.text_format] (_, heal_player.total / combat_time)
				else
					return 0
				end
			else --effective time
				local combat_time = Details.tabela_vigente:GetCombatTime()
				if (combat_time > 0) then
					return ToKFunctions [Details.minimap.text_format] (_, heal_player.total / combat_time)
				else
					return 0
				end
			end
			return 0
		else
			return 0
		end
	end

	local get_raid_dps = function()
		local damage_raid = Details.tabela_vigente and Details.tabela_vigente.totals [1]
		if (damage_raid ) then
			return ToKFunctions [Details.minimap.text_format] (_, damage_raid / Details.tabela_vigente:GetCombatTime())
		else
			return 0
		end
	end

	local get_raid_hps = function()
		local healing_raid = Details.tabela_vigente and Details.tabela_vigente.totals [2]
		if (healing_raid ) then
			return ToKFunctions [Details.minimap.text_format] (_, healing_raid / Details.tabela_vigente:GetCombatTime())
		else
			return 0
		end
	end

	local get_player_damage = function()
		local damage_player = Details.tabela_vigente(1, Details.playername)
		if (damage_player) then
			return ToKFunctions [Details.minimap.text_format] (_, damage_player.total)
		else
			return 0
		end
	end

	local get_player_heal = function()
		local heal_player = Details.tabela_vigente(2, Details.playername)
		if (heal_player) then
			return ToKFunctions [Details.minimap.text_format] (_, heal_player.total)
		else
			return 0
		end
	end

	local parse_broker_text = function()
		local text = Details.data_broker_text
		if (text == "") then
			return
		end

		text = text:gsub("{dmg}", get_player_damage)
		text = text:gsub("{rdps}", get_raid_dps)
		text = text:gsub("{rhps}", get_raid_hps)
		text = text:gsub("{dps}", get_player_dps)
		text = text:gsub("{heal}", get_player_heal)
		text = text:gsub("{hps}", get_player_hps)
		text = text:gsub("{time}", get_combat_time)
		text = text:gsub("{dpos}", get_damage_position)
		text = text:gsub("{hpos}", get_heal_position)
		text = text:gsub("{ddiff}", get_damage_diff)
		text = text:gsub("{hdiff}", get_heal_diff)

		return text
	end

	function Details:BrokerTick()
		Details.databroker.text = parse_broker_text()
	end

	function Details:SetDataBrokerText (text)
		if (type(text) == "string") then
			Details.data_broker_text = text
			Details:BrokerTick()
		elseif (text == nil or (type(text) == "boolean" and not text)) then
			Details.data_broker_text = ""
			Details:BrokerTick()
		end
	end



------------------------------------------------------------------------------------------------------
--regular spell timers
Details222.TimeCapture.Timers = {}
local damageContainer
local healingContainer
local timeElapsed = 0

local combatTimeTicker = function()
	timeElapsed = timeElapsed + 1
end

local damageCapture = function(tickerObject)
	local actorObject = tickerObject.ActorObject
	if (not actorObject) then
		tickerObject.ActorObject = damageContainer:GetActor(tickerObject.unitName)
		if (not actorObject) then
			return
		end
	end

	for spellId, spellTable in pairs(actorObject.spells._ActorTable) do
		local totalDamage = spellTable.total
		if (totalDamage) then
			if (not spellTable.ChartData) then
				spellTable.ChartData = {}
			end
			spellTable.ChartData[timeElapsed] = totalDamage
		end
	end
end

function Details222.TimeCapture.StartCombatTimer(combatObject)
	timeElapsed = 0
	damageContainer = combatObject[1]
	healingContainer = combatObject[2]

	Details222.TimeCapture.CombatObject = combatObject
	Details222.TimeCapture.CombatTimeTicker = C_Timer.NewTicker(1, combatTimeTicker)

	--debug: starting only for the player
	Details222.TimeCapture.Start(UnitName("player"), DETAILS_ATTRIBUTE_DAMAGE)
end

--combat ended on Details! end
function Details222.TimeCapture.StopCombat()
	local combatTimeTickerObject = Details222.TimeCapture.CombatTimeTicker
	if (combatTimeTickerObject and not combatTimeTickerObject:IsCancelled()) then
		combatTimeTickerObject:Cancel()
		Details222.TimeCapture.CombatTimeTicker = nil
	end

	Details222.TimeCapture.StopAllUnitTimers()
end

--start a capture for a specific unit
function Details222.TimeCapture.Start(unitName, attribute)
	local tickerObject = C_Timer.NewTicker(3, damageCapture)
	tickerObject.unitName = unitName
	Details222.TimeCapture.Timers[unitName] = tickerObject
end

function Details222.TimeCapture.StopAllUnitTimers()
	for unitName, tickerObject in pairs(Details222.TimeCapture.Timers) do
		if (not tickerObject:IsCancelled()) then --why do I need to stop here, it's stopping in the unit itself right below
			tickerObject:Cancel()
		end
		Details222.TimeCapture.Stop(unitName)
	end
	Details:Destroy(Details222.TimeCapture.Timers)
end

--can be a manual stop or from the stop all unit frames (function above)
function Details222.TimeCapture.Stop(unitName)
	local tickerObject = Details222.TimeCapture.Timers[unitName]
	if (tickerObject and not tickerObject:IsCancelled()) then
		tickerObject:Cancel()
		Details222.TimeCapture.Timers[unitName] = nil
	end
end

function Details222.TimeCapture.GetChartDataFromSpell(spellTable)
	return spellTable.ChartData
end