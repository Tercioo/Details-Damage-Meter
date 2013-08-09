--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = _G._detalhes
	
	_detalhes.timeContainer = {
		damage_recording = 0,
		healing_recording = 0,
		
		have_custom = false,
		custom_functions = {},
		custom_attributes = {},
		
		current_table = {} --> place holder
	}
	_detalhes.timeContainer.__index = _detalhes.timeContainer

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _pairs = pairs

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions

	--> remove a capture previous registred
	function _detalhes:UnregisterTimeCapture (captureType)
		if (type (captureType) == "number" and captureType == 1) then
			if (_detalhes.timeContainer.damage_recording > 1) then
				_detalhes.timeContainer.damage_recording = _detalhes.timeContainer.damage_recording - 1
			end
			
		elseif (type (captureType) == "number" and captureType == 2) then
			if (_detalhes.timeContainer.healing_recording > 1) then
				_detalhes.timeContainer.healing_recording = _detalhes.timeContainer.healing_recording - 1
			end
			
		elseif (type (captureType) == "string") then
			if (_detalhes.timeContainer.have_custom) then
				if (_detalhes.timeContainer.custom_functions [captureType]) then
					_detalhes.timeContainer.custom_functions [captureType] = nil
				end
			end
		end
	end

	--> register a new capture
	function _detalhes:RegisterTimeCapture (captureType, customName, attributes)

		if (type (captureType) == "number" and captureType == 1) then
			if (_detalhes.timeContainer.damage_recording < 1) then
				_detalhes.timeContainer.current_table.damage = {}
				_detalhes.timeContainer.current_table.damageLast = 0
				_detalhes.timeContainer.current_table.damageMax = 0
			end
			_detalhes.timeContainer.damage_recording = _detalhes.timeContainer.damage_recording + 1
			
		elseif (type (captureType) == "number" and captureType == 2) then
			if (_detalhes.timeContainer.healing_recording < 1) then
				_detalhes.timeContainer.current_table.healing = {}
				_detalhes.timeContainer.current_table.healingLast = 0
				_detalhes.timeContainer.current_table.healingMax = 0
			end
			_detalhes.timeContainer.healing_recording = _detalhes.timeContainer.healing_recording + 1
			
		elseif (type (captureType) == "function") then
			if (customName) then
				_detalhes.timeContainer.have_custom = true
				_detalhes.timeContainer.custom_functions [customName] = captureType
				_detalhes.timeContainer.custom_attributes [customName] = attributes or {}
				_detalhes.timeContainer.current_table [customName .. "Data"] = {}
				_detalhes.timeContainer.current_table [customName .. "Attributes"] = {}
				if (attributes) then
					for k, v in pairs (attributes) do 
						_detalhes.timeContainer.current_table [customName .. "Attributes"][k] = v
					end
				end
			end
		end
		
		return true
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions
	
	function _detalhes.timeContainer:CreateTimeTable()
		local _t = {}
		setmetatable (_t, _detalhes.timeContainer)
		_t.timeIndex = 1
		--
		if (_detalhes.timeContainer.damage_recording > 0) then
			_t.damage = {}
			_t.damageLast = 0
			_t.damageMax = 0
		end
		--
		if (_detalhes.timeContainer.healing_recording > 0) then
			_t.healing = {}
			_t.healingLast = 0
			_t.healingMax = 0
		end
		--
		if (_detalhes.timeContainer.have_custom) then
			for customName, customFunction in _pairs (_detalhes.timeContainer.custom_functions) do 
				if (customFunction) then
					_t [customName .. "Data"] = {}
					_t [customName .. "Attributes"] = {}
					
					local attributes = _detalhes.timeContainer.custom_attributes [customName]
					local attributeTable = _t [customName .. "Attributes"]
					for k, v in pairs (attributes) do 
						attributeTable [k] = v
					end
					
				end
			end
		end
		
		_detalhes.timeContainer.current_table = _t
		
		return _t
	end

	function _detalhes.timeContainer:Record()

		if (self.damage_recording > 0) then
			--> record damage
			local currentDamage = _detalhes.tabela_vigente.totals_grupo[1]
			local thisDamage = currentDamage - self.damageLast
			self.damage [self.timeIndex] = thisDamage
			if (thisDamage > self.damageMax) then
				self.damageMax = thisDamage
			end
			self.damageLast = currentDamage
		end
		
		if (self.healing_recording > 0) then
			--> record healing
			local currentHealing = _detalhes.tabela_vigente.totals_grupo[2]
			self.healing [self.timeIndex] = currentHealing - self.healingLast
			if (currentHealing > self.healingMax) then
				self.healingMax = currentHealing
			end
			self.healingLast = currentHealing
		end
		
		if (self.have_custom) then
			--> record unknow, handled by function
			for customName, customFunction in _pairs (self.custom_functions) do 
				if (customFunction) then
					customFunction (self.timeIndex, self [customName .. "Data"], self [customName .. "Attributes"])
				end
			end
		end
		
		self.timeIndex = self.timeIndex + 1
	end