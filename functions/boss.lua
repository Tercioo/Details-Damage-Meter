
do 

	local _detalhes = _G._detalhes
	_detalhes.EncounterInformation = {}
	local _ipairs = ipairs --> lua local
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions
	
	--> return if the player is inside a raid supported by details
	function _detalhes:IsInInstance()
		local _, _, _, _, _, _, _, zoneMapID = GetInstanceInfo()
		if (_detalhes.EncounterInformation [zoneMapID]) then
			return true
		else
			return false
		end
	end

	--> return the function for the boss
	function _detalhes:GetBossFunction (mapid, bossindex)
		local func = _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex] and _detalhes.EncounterInformation [mapid].encounters [bossindex].func
		if (func) then
			return func, _detalhes.EncounterInformation [mapid].encounters [bossindex].funcType
		end
		return 
	end
	
	--> return the boss table with information about name, adds, spells, etc
	function _detalhes:GetBossDetails (mapid, bossindex)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex]
	end
	
	--> return a table with spells id of specified encounter
	function _detalhes:GetEncounterSpells (mapid, bossindex)
		local encounter = _detalhes:GetBossDetails (mapid, bossindex)
		local habilidades_poll = {}
		if (encounter.continuo) then
			for index, spellid in _ipairs (encounter.continuo) do 
				habilidades_poll [spellid] = true
			end
		end
		local fases = encounter.phases
		for fase_id, fase in _ipairs (fases) do 
			if (fase.spells) then
				for index, spellid in _ipairs (fase.spells) do 
					habilidades_poll [spellid] = true
				end
			end
		end
		return habilidades_poll
	end
	
	--> return a table with all boss ids from a raid instance
	function _detalhes:GetBossIds (mapid)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].boss_ids
	end
	
	--> return a table with all encounter names present in raid instance
	function _detalhes:GetBossNames (mapid)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].boss_names
	end
	
	--> return the encounter name
	function _detalhes:GetBossName (mapid, bossindex)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].boss_names [bossindex]
	end
	
	--> same thing as GetBossDetails, just a alias
	function _detalhes:GetBossEncounterDetails (mapid, bossindex)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex]
	end
	
	--> return the wallpaper for the raid instance
	function _detalhes:GetRaidBackground (mapid)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].background
	end
	
	--> return the boss icon
	function _detalhes:GetBossIcon (mapid, bossindex)
		if (_detalhes.EncounterInformation [mapid]) then
			local line = math.ceil (bossindex / 4)
			local x = ( bossindex - ( (line-1) * 4 ) )  / 4
			return x-0.25, x, 0.25 * (line-1), 0.25 * line, _detalhes.EncounterInformation [mapid].icons
		end
	end
	
	--> return the boss portrit
	function _detalhes:GetBossPortrait (mapid, bossindex)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex].portrait
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function _detalhes:InstallEncounter (InstanceTable)
		_detalhes.EncounterInformation [InstanceTable.id] = InstanceTable
		return true
	end
end