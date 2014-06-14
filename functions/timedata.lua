



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> basic stuff

	local _
	local _detalhes = _G._detalhes
	
	--> mantain the enabled time captures
	_detalhes.timeContainer = {}
	_detalhes.timeContainer.Exec = {}
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers
	local ipairs = ipairs
	local time = time

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local INDEX_NAME = 1
	local INDEX_FUNCTION = 2
	local INDEX_MATRIX = 3
	local INDEX_AUTHOR = 4
	local INDEX_VERSION = 5
	local INDEX_ICON = 6
	local INDEX_ENABLED = 7
	
	local DEFAULT_USER_MATRIX = {max_value = 0, last_value = 0}
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> register and unregister captures


	function _detalhes:TimeDataUpdate (index_or_name, name, func, matrix, author, version, icon, is_enabled)
		
		local this_capture
		if (type (index_or_name) == "number") then
			this_capture = _detalhes.savedTimeCaptures [index_or_name]
		else
			for index, t in ipairs (_detalhes.savedTimeCaptures) do
				if (t [INDEX_NAME] == index_or_name) then
					this_capture = t
				end
			end
		end
		
		if (not this_capture) then
			return false
		end
		
		if (this_capture.do_not_save) then
			return _detalhes:Msg ("This capture belongs to a plugin and cannot be edited.")
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
		
		return true
		
	end

	function _detalhes:TimeDataRegister (name, func, matrix, author, version, icon, is_enabled, force_no_save)
	
		--> check name
		if (not name) then
			return "Couldn't register the time capture, name was nil."
		end
		
		--> check if the name already exists
		for index, t in ipairs (_detalhes.savedTimeCaptures) do
			if (t [INDEX_NAME] == name) then
				return "Couldn't register the time capture, name already registred."
			end
		end
		
		--> check function
		if (not func) then
			return "Couldn't register the time capture, invalid function."
		end
		
		local no_save = nil
		--> passed a function means that this isn't came from a user
		--> so the plugin register the capture every time it loads.
		if (type (func) == "function") then
			no_save = true
		
		--> this a custom capture from a user, so we register a default user table for matrix
		elseif (type (func) == "string") then
			matrix = DEFAULT_USER_MATRIX
			
		end
		
		if (not no_save and force_no_save) then
			no_save = true
		end
		
		--> check matrix
		if (not matrix or type (matrix) ~= "table") then
			return "Couldn't register the time capture, matrix was invalid."
		end
		
		author = author or "Unknown"
		version = version or "v1.0"
		icon = icon or [[Interface\InventoryItems\WoWUnknownItem01]]
		
		tinsert (_detalhes.savedTimeCaptures, {name, func, matrix, author, version, icon, is_enabled, do_not_save = no_save})
		
		if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
			_G.DetailsOptionsWindow16UserTimeCapturesFillPanel.MyObject:Refresh()
		end
		
		return true
		
	end
	
	--> unregister
	function _detalhes:TimeDataUnregister (name)
		if (type (name) == "number") then
			return tremove (_detalhes.savedTimeCaptures, name)
		else
			for index, t in ipairs (_detalhes.savedTimeCaptures) do
				if (t [INDEX_NAME] == name) then
					tremove (_detalhes.savedTimeCaptures, index)
					return true
				end
			end
			return false
		end
	end
	
	--> cleanup when logout
	function _detalhes:TimeDataCleanUpTemporary()
		local new_table = {}
		for index, t in ipairs (_detalhes.savedTimeCaptures) do
			if (not t.do_not_save) then
				tinsert (new_table, t)
			end
		end
		_detalhes.savedTimeCaptures = new_table
	end

	local tick_time = 0
	
	--> starting a combat
	function _detalhes:TimeDataCreateCombatTables()
		
		--> create capture table
		local data_captured = {}
	
		--> drop the last capture exec table without wiping
		local exec = {}
		_detalhes.timeContainer.Exec = exec
		
		--> build the exec table
		for index, t in ipairs (_detalhes.savedTimeCaptures) do
			if (t [INDEX_ENABLED]) then
			
				local data = {}
				data_captured [t [INDEX_NAME]] = data
			
				if (type (t [INDEX_FUNCTION]) == "string") then
					--> user
					local func = loadstring (t [INDEX_FUNCTION])
					if (func) then
						tinsert (exec, { func = func, data = data, attributes = table_deepcopy (t [INDEX_MATRIX]), is_user = true })
					end
				else
					--> plugin
					tinsert (exec, { func = t [INDEX_FUNCTION], data = data, attributes = table_deepcopy (t [INDEX_MATRIX]) })
				end
			
			end
		end
	
		tick_time = 0
	
		--> return the capture table the to combat object
		return data_captured
	end
	
	local exec_user_func = function (func, attributes, data, this_second)
		
		local result = func()
		
		local current = result - attributes.last_value
		data [this_second] = current
		
		if (current > attributes.max_value) then
			attributes.max_value = current
			data.max_value = current
		end
		
		attributes.last_value = result
		
	end
	
	function _detalhes:TimeDataTick()
	
		tick_time = tick_time + 1
	
		for index, t in ipairs (_detalhes.timeContainer.Exec) do 
		
			if (t.is_user) then
				--> by a user
				exec_user_func (t.func, t.attributes, t.data, tick_time)
				
			else
				--> by a plugin
				t.func (t.attributes, t.data, tick_time)
				
			end
		
		end
	
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> broker dps stuff

	function _detalhes:BrokerTick()
		local texttype = _detalhes.minimap.text_type
		if (texttype == 1) then --dps
			local time = _detalhes.tabela_vigente:GetCombatTime()
			if (not time or time == 0) then
				_detalhes.databroker.text = 0
			else
				_detalhes.databroker.text = _detalhes.tabela_vigente.totals_grupo[1] / time
			end
			
		elseif (texttype == 2) then --hps
			local time = _detalhes.tabela_vigente:GetCombatTime()
			if (not time or time == 0) then
				_detalhes.databroker.text = 0
			else
				_detalhes.databroker.text = _detalhes.tabela_vigente.totals_grupo[2] / time
			end
			
		else
			if (_detalhes.minimap.text_func) then
				_detalhes.databroker.text = _detalhes.minimap.text_func()
			else
				_detalhes.databroker.text = 0
			end
		end
		
	end
	