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
		--> details self events
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

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions

	--> Register a Event
	function _detalhes:RegisterEvent (object, event, func)

	-------> combat -------------------------------------------------------------------------------------------------------------------------------------------------
		
		if (event == "COMBAT_PLAYER_ENTER") then

			if (not AlreadyRegistred (_detalhes.RegistredEvents ["COMBAT_PLAYER_ENTER"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["COMBAT_PLAYER_ENTER"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["COMBAT_PLAYER_ENTER"], object)
				end
				return true
			else
				return false
			end
		
		elseif (event == "COMBAT_PLAYER_LEAVE") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["COMBAT_PLAYER_LEAVE"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["COMBAT_PLAYER_LEAVE"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["COMBAT_PLAYER_LEAVE"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "COMBAT_PLAYER_TIMESTARTED") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["COMBAT_PLAYER_TIMESTARTED"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["COMBAT_PLAYER_TIMESTARTED"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["COMBAT_PLAYER_TIMESTARTED"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "COMBAT_BOSS_FOUND") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["COMBAT_BOSS_FOUND"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["COMBAT_BOSS_FOUND"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["COMBAT_BOSS_FOUND"], object)
				end
				return true
			else
				return false
			end
		
	-------> buffs -------------------------------------------------------------------------------------------------------------------------------------------------
		
		elseif (event == "BUFF_UPDATE") then
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
			
	-------> Addon Instances -------------------------------------------------------------------------------------------------------------------------------------------------

		elseif (event == "DETAILS_INSTANCE_OPEN") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_OPEN"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_OPEN"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_OPEN"], object)
				end
				return true
			else
				return false
			end

		elseif (event == "DETAILS_INSTANCE_CLOSE") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CLOSE"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CLOSE"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CLOSE"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_SIZECHANGED") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_SIZECHANGED"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_SIZECHANGED"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_SIZECHANGED"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_STARTRESIZE") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTRESIZE"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTRESIZE"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTRESIZE"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_ENDRESIZE") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDRESIZE"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDRESIZE"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDRESIZE"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_ENDSTRETCH") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDSTRETCH"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDSTRETCH"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDSTRETCH"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_STARTSTRETCH") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTSTRETCH"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTSTRETCH"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTSTRETCH"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_CHANGESEGMENT") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGESEGMENT"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGESEGMENT"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGESEGMENT"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_CHANGEATTRIBUTE") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEATTRIBUTE"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEATTRIBUTE"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEATTRIBUTE"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_CHANGEMODE") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEMODE"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEMODE"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEMODE"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_DATA_RESET") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_DATA_RESET"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_DATA_RESET"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_DATA_RESET"], object)
				end
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_DATA_SEGMENTREMOVED") then
			if (not AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_DATA_SEGMENTREMOVED"], object)) then
				if (func) then
					tinsert (_detalhes.RegistredEvents ["DETAILS_DATA_SEGMENTREMOVED"], {object, func, __eventtable = true})
				else
					tinsert (_detalhes.RegistredEvents ["DETAILS_DATA_SEGMENTREMOVED"], object)
				end
				return true
			else
				return false
			end
			
		end
	end




	------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--> Unregister a Event
	------------------------------------------------------------------------------------------------------------------------------------------------------------------




	function _detalhes:UnregisterEvent (object, event)

	-------> combat -------------------------------------------------------------------------------------------------------------------------------------------------	
		

		if (event == "COMBAT_PLAYER_ENTER") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["COMBAT_PLAYER_ENTER"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["COMBAT_PLAYER_ENTER"], index)
				return true
			else
				return false
			end
			
		elseif (event == "COMBAT_PLAYER_LEAVE") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["COMBAT_PLAYER_LEAVE"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["COMBAT_PLAYER_LEAVE"], index)
				return true
			else
				return false
			end
			
		elseif (event == "COMBAT_PLAYER_TIMESTARTED") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["COMBAT_PLAYER_TIMESTARTED"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["COMBAT_PLAYER_TIMESTARTED"], index)
				return true
			else
				return false
			end
			
		elseif (event == "COMBAT_BOSS_FOUND") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["COMBAT_BOSS_FOUND"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["COMBAT_BOSS_FOUND"], index)
				return true
			else
				return false
			end
		
	-------> buffs -------------------------------------------------------------------------------------------------------------------------------------------------	
		
		elseif (event == "BUFF_UPDATE") then
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

	-------> Addon Instances -------------------------------------------------------------------------------------------------------------------------------------------------
		
		elseif (event == "DETAILS_INSTANCE_OPEN") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_OPEN"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_OPEN"], index)
				return true
			else
				return false
			end	

		elseif (event == "DETAILS_INSTANCE_CLOSE") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CLOSE"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CLOSE"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_SIZECHANGED") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_SIZECHANGED"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_SIZECHANGED"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_STARTRESIZE") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTRESIZE"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTRESIZE"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_ENDRESIZE") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDRESIZE"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDRESIZE"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_ENDSTRETCH") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDSTRETCH"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_ENDSTRETCH"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_STARTSTRETCH") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTSTRETCH"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_STARTSTRETCH"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_CHANGESEGMENT") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGESEGMENT"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGESEGMENT"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_CHANGEATTRIBUTE") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEATTRIBUTE"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEATTRIBUTE"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_INSTANCE_CHANGEMODE") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEMODE"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_INSTANCE_CHANGEMODE"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_DATA_RESET") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_DATA_RESET"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_DATA_RESET"], index)
				return true
			else
				return false
			end
			
		elseif (event == "DETAILS_DATA_SEGMENTREMOVED") then
			local index = AlreadyRegistred (_detalhes.RegistredEvents ["DETAILS_DATA_SEGMENTREMOVED"], object)
			if (index) then
				table.remove (_detalhes.RegistredEvents ["DETAILS_DATA_SEGMENTREMOVED"], index)
				return true
			else
				return false
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
