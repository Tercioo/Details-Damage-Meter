--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = _G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	--> Event types:
	_detalhes.RegistredEvents = {
		--> instances
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
			
		--> data
			["DETAILS_DATA_RESET"] = {},
			["DETAILS_DATA_SEGMENTREMOVED"] = {},
		
		--> combat
			["COMBAT_PLAYER_ENTER"] = {},
			["COMBAT_PLAYER_LEAVE"] = {},
			["COMBAT_PLAYER_TIMESTARTED"] = {},
			["COMBAT_BOSS_FOUND"] = {},
		
		--> area
			["ZONE_TYPE_CHANGED"] = {},
		
		--> roster
			["GROUP_ONENTER"] = {},
			["GROUP_ONLEAVE"] = {},
		
		--> buffs
			["BUFF_UPDATE"] = {},
			["BUFF_UPDATE_DEBUFFPOWER"] = {}
	}

	local function AlreadyRegistred (_tables, _object)
		for index, _this_object in ipairs (_tables) do 
			if (_this_object.__eventtable) then
				if (_this_object [1] == _object) then
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
	["DETAILS_DATA_RESET"] = true,
	["DETAILS_DATA_SEGMENTREMOVED"] = true,
	["COMBAT_PLAYER_ENTER"] = true,
	["COMBAT_PLAYER_LEAVE"] = true,
	["COMBAT_PLAYER_TIMESTARTED"] = true,
	["COMBAT_BOSS_FOUND"] = true,
	["GROUP_ONENTER"] = true,
	["GROUP_ONLEAVE"] = true,
	["ZONE_TYPE_CHANGED"] = true,
}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> register a event

	function _detalhes:RegisterEvent (object, event, func)

		if (not _detalhes.RegistredEvents [event]) then
			if (object.Msg) then
				object:DelayMsg ("(debug) unknown event", event)
			else
				_detalhes:DelayMsg ("(debug) unknown event", event)
			end
			return
		end
		
		if (common_events [event]) then
			if (not AlreadyRegistred (_detalhes.RegistredEvents [event], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents [event], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents [event], object)
				end
				return true
			else
				return false
			end
		else
			if (event == "BUFF_UPDATE") then
				if (not AlreadyRegistred (_detalhes.RegistredEvents ["BUFF_UPDATE"], object)) then
					if (func) then
						tinsert (_detalhes.RegistredEvents ["BUFF_UPDATE"], {object, func, __eventtable = true})
					else
						tinsert (_detalhes.RegistredEvents ["BUFF_UPDATE"], object)
					end
					_detalhes.Buffs:CatchBuffs()
					_detalhes.RecordPlayerSelfBuffs = true
					_detalhes:UpdateParserGears()
					return true
				else
					return false
				end
				
			elseif (event == "BUFF_UPDATE_DEBUFFPOWER") then
				if (not AlreadyRegistred (_detalhes.RegistredEvents ["BUFF_UPDATE_DEBUFFPOWER"], object)) then
					if (func) then
						tinsert (_detalhes.RegistredEvents ["BUFF_UPDATE_DEBUFFPOWER"], {object, func, __eventtable = true})
					else
						tinsert (_detalhes.RegistredEvents ["BUFF_UPDATE_DEBUFFPOWER"], object)
					end
					_detalhes.RecordPlayerAbilityWithBuffs = true
					_detalhes:UpdateDamageAbilityGears()
					_detalhes:UpdateParserGears()
					return true
				else
					return false
				end
			end
		end
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Unregister a Event

	function _detalhes:UnregisterEvent (object, event)
	
		if (not _detalhes.RegistredEvents [event]) then
			if (object.Msg) then
				object:Msg ("(debug) unknown event", event)
			else
				_detalhes:Msg ("(debug) unknown event", event)
			end
			return
		end
	
		if (common_events [event]) then
			local index = AlreadyRegistred (_detalhes.RegistredEvents [event], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents [event], index)
				return true
			else
				return false
			end
		else
			if (event == "BUFF_UPDATE") then
				local index = AlreadyRegistred (_detalhes.RegistredEvents ["BUFF_UPDATE"], object)
				if (index) then
					table.remove (_detalhes.RegistredEvents ["BUFF_UPDATE"], index)
					if (#_detalhes.RegistredEvents ["BUFF_UPDATE"] < 1) then
						_detalhes.RecordPlayerSelfBuffs = true
						_detalhes:UpdateParserGears()
					end
					return true
				else
					return false
				end
				
			elseif (event == "BUFF_UPDATE_DEBUFFPOWER") then
				local index = AlreadyRegistred (_detalhes.RegistredEvents ["BUFF_UPDATE_DEBUFFPOWER"], object)
				if (index) then
					table.remove (_detalhes.RegistredEvents ["BUFF_UPDATE_DEBUFFPOWER"], index)
					if (#_detalhes.RegistredEvents ["BUFF_UPDATE_DEBUFFPOWER"] < 1) then
						_detalhes.RecordPlayerAbilityWithBuffs = false
						_detalhes:UpdateDamageAbilityGears()
						_detalhes:UpdateParserGears()
					end
					return true
				else
					return false
				end
			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions
	
	--> Send Event
	function _detalhes:SendEvent (event, object, ...)

		--> send event to all registred plugins
		if (event == "PLUGIN_DISABLED" or event == "PLUGIN_ENABLED") then
			return object:OnDetailsEvent (event, ...)
		
		elseif (not object) then
			for _, PluginObject in ipairs (_detalhes.RegistredEvents[event]) do
				if (PluginObject.__eventtable) then
					if (PluginObject [1].Enabled and PluginObject [1].__enabled) then
						if (type (PluginObject [2]) == "function") then
							PluginObject [2] (event, ...)
						else
							PluginObject [1] [PluginObject [2]] (event, ...)
						end
					end
				else
					if (PluginObject.Enabled and PluginObject.__enabled) then
						PluginObject:OnDetailsEvent (event, ...)
					end
				end
			end
			
		elseif (type (object) == "string" and object == "SEND_TO_ALL") then
			
			for _, PluginObject in ipairs (_detalhes.RaidTables.Plugins) do 
				if (PluginObject.__enabled) then
					PluginObject:OnDetailsEvent (event)
				end
			end
			
			for _, PluginObject in ipairs (_detalhes.SoloTables.Plugins) do 
				if (PluginObject.__enabled) then
					PluginObject:OnDetailsEvent (event)
				end
			end
			
			for _, PluginObject in ipairs (_detalhes.ToolBar.Plugins) do 
				if (PluginObject.__enabled) then
					PluginObject:OnDetailsEvent (event)
				end
			end
		else
		--> send the event only for requested plugin
			if (object.Enabled and object.__enabled) then
				return object:OnDetailsEvent (event, ...)
			end
		end
	end
