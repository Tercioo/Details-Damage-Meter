
	local Details = _G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	local addonName, Details222 = ...

	--Event types:
	Details.RegistredEvents = {
		--instances
			["DETAILS_STARTED"] = {},
			["DETAILS_INSTANCE_OPEN"] = {},
			["DETAILS_INSTANCE_CLOSE"] = {},
			["DETAILS_INSTANCE_SIZECHANGED"] = {},
			["DETAILS_INSTANCE_STARTRESIZE"] = {},
			["DETAILS_INSTANCE_ENDRESIZE"] = {},
			["DETAILS_INSTANCE_STARTSTRETCH"] = {},
			["DETAILS_INSTANCE_ENDSTRETCH"] = {},
			["DETAILS_INSTANCE_CHANGESEGMENT"] = {},
			["DETAILS_INSTANCE_CHANGEATTRIBUTE"] = {},
			["DETAILS_INSTANCE_CHANGEMODE"] = {},
			["DETAILS_INSTANCE_NEWROW"] = {},

		--misc
			["DETAILS_OPTIONS_MODIFIED"] = {},
			["UNIT_SPEC"] = {},
			["UNIT_TALENTS"] = {},
			["PLAYER_TARGET"] = {},
			["DETAILS_PROFILE_APPLYED"] = {},

		--data
			["DETAILS_DATA_RESET"] = {},
			["DETAILS_DATA_SEGMENTREMOVED"] = {},

		--combat
			["COMBAT_ENCOUNTER_START"] = {},
			["COMBAT_ENCOUNTER_END"] = {},
			["COMBAT_PLAYER_ENTER"] = {},
			["COMBAT_PLAYER_LEAVE"] = {},
			["COMBAT_PLAYER_LEAVING"] = {},
			["COMBAT_PLAYER_TIMESTARTED"] = {},
			["COMBAT_BOSS_WIPE"] = {},
			["COMBAT_BOSS_DEFEATED"] = {},
			["COMBAT_BOSS_FOUND"] = {},
			["COMBAT_INVALID"] = {},
			["COMBAT_PREPOTION_UPDATED"] = {},
			["COMBAT_CHARTTABLES_CREATING"] = {},
			["COMBAT_CHARTTABLES_CREATED"] = {},
			["COMBAT_ENCOUNTER_PHASE_CHANGED"] = {},
			["COMBAT_ARENA_START"] = {},
			["COMBAT_ARENA_END"] = {},
			["COMBAT_MYTHICDUNGEON_START"] = {},
			["COMBAT_MYTHICDUNGEON_END"] = {},
			["COMBAT_MYTHICPLUS_OVERALL_READY"] = {},

		--area
			["ZONE_TYPE_CHANGED"] = {},

		--roster
			["GROUP_ONENTER"] = {},
			["GROUP_ONLEAVE"] = {},

		--buffs
			["BUFF_UPDATE"] = {},
			["BUFF_UPDATE_DEBUFFPOWER"] = {},

		--network
			["REALM_CHANNEL_ENTER"] = {}, --deprecated (realm channels are disabled)
			["REALM_CHANNEL_LEAVE"] = {}, --deprecated
			["COMM_EVENT_RECEIVED"] = {}, --added on core 129
			["COMM_EVENT_SENT"] = {}, --added on core 129
	}

	local function isAlreadyRegistred(_tables, _object)
		for index, _this_object in ipairs(_tables) do
			if (_this_object.__eventtable) then
				if (_this_object[1] == _object) then
					return index
				end
			elseif (_this_object == _object) then
				return index
			end
		end
		return false
	end

local common_events = {
	["DETAILS_INSTANCE_OPEN"] = true,
	["DETAILS_INSTANCE_CLOSE"] = true,
	["DETAILS_INSTANCE_SIZECHANGED"] = true,
	["DETAILS_INSTANCE_STARTRESIZE"] = true,
	["DETAILS_INSTANCE_ENDRESIZE"] = true,
	["DETAILS_INSTANCE_STARTSTRETCH"] = true,
	["DETAILS_INSTANCE_ENDSTRETCH"] = true,
	["DETAILS_INSTANCE_CHANGESEGMENT"] = true,
	["DETAILS_INSTANCE_CHANGEATTRIBUTE"] = true,
	["DETAILS_INSTANCE_CHANGEMODE"] = true,
	["DETAILS_INSTANCE_NEWROW"] = true,
	["DETAILS_OPTIONS_MODIFIED"] = true,
	["DETAILS_DATA_RESET"] = true,
	["DETAILS_DATA_SEGMENTREMOVED"] = true,
	["COMBAT_ENCOUNTER_START"] = true,
	["COMBAT_ENCOUNTER_END"] = true,
	["COMBAT_PLAYER_ENTER"] = true,
	["COMBAT_PLAYER_LEAVE"] = true,
	["COMBAT_PLAYER_LEAVING"] = true,
	["COMBAT_PLAYER_TIMESTARTED"] = true,
	["COMBAT_BOSS_WIPE"] = true,
	["COMBAT_BOSS_DEFEATED"] = true,
	["COMBAT_BOSS_FOUND"] = true,
	["COMBAT_INVALID"] = true,
	["COMBAT_PREPOTION_UPDATED"] = true,
	["COMBAT_CHARTTABLES_CREATING"] = true,
	["COMBAT_CHARTTABLES_CREATED"] = true,
	["COMBAT_ENCOUNTER_PHASE_CHANGED"] = true,
	["COMBAT_ARENA_START"] = true,
	["COMBAT_ARENA_END"] = true,
	["COMBAT_MYTHICDUNGEON_START"] = true,
	["COMBAT_MYTHICDUNGEON_END"] = true,
	["COMBAT_MYTHICPLUS_OVERALL_READY"] = true,
	["GROUP_ONENTER"] = true,
	["GROUP_ONLEAVE"] = true,
	["ZONE_TYPE_CHANGED"] = true,
	["REALM_CHANNEL_ENTER"] = true,
	["REALM_CHANNEL_LEAVE"] = true,
	["COMM_EVENT_RECEIVED"] = true,
	["COMM_EVENT_SENT"] = true,
	["UNIT_SPEC"] = true,
	["UNIT_TALENTS"] = true,
	["PLAYER_TARGET"] = true,
	["DETAILS_PROFILE_APPLYED"] = true,

}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--register a event

	function Details:RegisterEvent(object, event, func)
		if (not Details.RegistredEvents[event]) then
			if (object.Msg) then
				object:DelayMsg("[debug] unknown event1: " .. (event or "no-event"))
			else
				Details:DelayMsg("[debug] unknown event2:", event, object.__name)
			end
			return
		end

		if (common_events[event]) then
			if (not isAlreadyRegistred(Details.RegistredEvents[event], object)) then
				if (func) then
					table.insert(Details.RegistredEvents[event], {object, func, __eventtable = true})
				else
					table.insert(Details.RegistredEvents[event], object)
				end
				return true
			else
				return false
			end
		else
			if (event == "BUFF_UPDATE") then
				if (not isAlreadyRegistred(Details.RegistredEvents["BUFF_UPDATE"], object)) then
					if (func) then
						table.insert(Details.RegistredEvents["BUFF_UPDATE"], {object, func, __eventtable = true})
					else
						table.insert(Details.RegistredEvents["BUFF_UPDATE"], object)
					end
					Details.Buffs:CatchBuffs()
					Details.RecordPlayerSelfBuffs = true
					Details:UpdateParserGears()
					return true
				else
					return false
				end

			elseif (event == "BUFF_UPDATE_DEBUFFPOWER") then
				if (not isAlreadyRegistred(Details.RegistredEvents["BUFF_UPDATE_DEBUFFPOWER"], object)) then
					if (func) then
						table.insert(Details.RegistredEvents["BUFF_UPDATE_DEBUFFPOWER"], {object, func, __eventtable = true})
					else
						table.insert(Details.RegistredEvents["BUFF_UPDATE_DEBUFFPOWER"], object)
					end
					Details.RecordPlayerAbilityWithBuffs = true
					Details:UpdateParserGears()
					return true
				else
					return false
				end
			end
		end
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Unregister a Event

	function Details:UnregisterEvent(object, event)
		if (not Details.RegistredEvents[event]) then
			if (object.Msg) then
				object:Msg("(debug) unknown event", event)
			else
				Details:Msg("(debug) unknown event", event)
			end
			return
		end

		if (common_events[event]) then
			local index = isAlreadyRegistred(Details.RegistredEvents[event], object)
			if (index) then
				table.remove(Details.RegistredEvents[event], index)
				return true
			else
				return false
			end
		else
			if (event == "BUFF_UPDATE") then
				local index = isAlreadyRegistred(Details.RegistredEvents["BUFF_UPDATE"], object)
				if (index) then
					table.remove(Details.RegistredEvents["BUFF_UPDATE"], index)
					if (#Details.RegistredEvents["BUFF_UPDATE"] < 1) then
						Details.RecordPlayerSelfBuffs = true
						Details:UpdateParserGears()
					end
					return true
				else
					return false
				end

			elseif (event == "BUFF_UPDATE_DEBUFFPOWER") then
				local index = isAlreadyRegistred(Details.RegistredEvents["BUFF_UPDATE_DEBUFFPOWER"], object)
				if (index) then
					table.remove(Details.RegistredEvents["BUFF_UPDATE_DEBUFFPOWER"], index)
					if (#Details.RegistredEvents["BUFF_UPDATE_DEBUFFPOWER"] < 1) then
						Details.RecordPlayerAbilityWithBuffs = false
						Details:UpdateParserGears()
					end
					return true
				else
					return false
				end
			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--internal functions

	local dispatch_error = function(name, errortext)
		Details:Msg((name or "<no context>"), " |cFFFF9900error|r: ", errortext)
	end

	--safe call an external func with payload and without telling who is calling
	function Details:QuickDispatchEvent(func, event, ...)
		if (type(func) ~= "function") then
			return
		elseif (type(event) ~= "string") then
			return
		end

		local okay, errortext = xpcall(func, geterrorhandler(), event, ...)

		if (not okay) then
			--trigger an error msg
			dispatch_error(_, errortext)

			return
		end

		return true
	end

	--quick dispatch with context, send the caller object within the payload
	function Details:QuickDispatchEventWithContext(context, func, event, ...)
		if (type(context) ~= "table") then
			return

		elseif (type(func) ~= "function") then
			return

		elseif (type(event) ~= "string") then
			return
		end

		local okay, errortext = xpcall(func, geterrorhandler(), context, event, ...)

		if (not okay) then
			--attempt to get the context name
			local objectName = context.__name or context._name or context.name or context.Name
			--trigger an error msg
			dispatch_error(objectName, errortext)
			return
		end

		return true
	end

	--Send Event
	function Details:SendEvent(event, object, ...)
		--send event to all registred plugins
		if (event == "PLUGIN_DISABLED" or event == "PLUGIN_ENABLED") then
			return object:OnDetailsEvent(event, ...)

		elseif (not object) then
			--iterate among all plugins which registered a function for this event
			for _, PluginObject in ipairs(Details.RegistredEvents[event]) do
				--when __eventtable is true, the plugin registered a function or method name to callback
				--if is false, we call OnDetailsEvent method on the plugin
				if (PluginObject.__eventtable) then

					local pluginTable = PluginObject[1]

					--check if the plugin is enabled
					if (pluginTable.Enabled and pluginTable.__enabled) then

						--check if fegistered a function
						if (type(PluginObject[2]) == "function") then
							local func = PluginObject[2]
							Details:QuickDispatchEvent(func, event, ...)
						--if not it must be a method name
						else
							local methodName = PluginObject[2]
							local func = pluginTable[methodName]
							Details:QuickDispatchEventWithContext(pluginTable, func, event, ...)
						end
					end

				--if no function(only registred the event) sent the event to OnDetailsEvent
				else
					if (PluginObject.Enabled and PluginObject.__enabled) then
						Details:QuickDispatchEventWithContext (PluginObject, PluginObject.OnDetailsEvent, event, ...)
					end
				end
			end

		--plugin notifications (does not send to listeners)
		elseif (type(object) == "string" and object == "SEND_TO_ALL") then
			for _, PluginObject in ipairs(Details.RaidTables.Plugins) do
				if (PluginObject.__enabled) then
					Details:QuickDispatchEventWithContext(PluginObject, PluginObject.OnDetailsEvent, event)
				end
			end

			for _, PluginObject in ipairs(Details.SoloTables.Plugins) do
				if (PluginObject.__enabled) then
					Details:QuickDispatchEventWithContext(PluginObject, PluginObject.OnDetailsEvent, event)
				end
			end

			for _, PluginObject in ipairs(Details.ToolBar.Plugins) do
				if (PluginObject.__enabled) then
					Details:QuickDispatchEventWithContext(PluginObject, PluginObject.OnDetailsEvent, event)
				end
			end
		else
			--send the event only for requested plugin
			if (object.Enabled and object.__enabled) then
				return Details:QuickDispatchEventWithContext(object, object.OnDetailsEvent, event, ...)
			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--special cases
	function Details:SendOptionsModifiedEvent(instance)
		Details.last_options_modified = Details.last_options_modified or (GetTime() - 5)
		if (Details.last_options_modified + 0.3 < GetTime()) then
			Details:SendEvent("DETAILS_OPTIONS_MODIFIED", nil, instance)
			Details.last_options_modified = GetTime()
			if (Details.last_options_modified_schedule) then
				Details:CancelTimer(Details.last_options_modified_schedule)
				Details.last_options_modified_schedule = nil
			end
		else
			if (Details.last_options_modified_schedule) then
				Details:CancelTimer(Details.last_options_modified_schedule)
			end
			Details.last_options_modified_schedule = Details:ScheduleTimer("SendOptionsModifiedEvent", 0.31, instance)
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--listeners

	local listener_meta = setmetatable({}, Details)
	listener_meta.__index = listener_meta

	function listener_meta:RegisterEvent(event, func)
		return Details:RegisterEvent(self, event, func)
	end

	function listener_meta:UnregisterEvent(event)
		return Details:UnregisterEvent(self, event)
	end

	function Details:CreateEventListener()
		local new = {Enabled = true, __enabled = true}
		setmetatable(new, listener_meta)
		return new
	end