
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

	--> return the ids of trash mobs in the instance
	function _detalhes:GetInstanceTrashInfo (mapid)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].trash_ids
	end
	
	--> return the boss table using a encounter id
	function _detalhes:GetBossEncounterDetailsFromEncounterId (mapid, encounterid)
		local bossindex = _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounter_ids and _detalhes.EncounterInformation [mapid].encounter_ids [encounterid]
		if (bossindex) then
			return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex], bossindex
		else
			local bossindex = _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounter_ids2 and _detalhes.EncounterInformation [mapid].encounter_ids2 [encounterid]
			if (bossindex) then
				return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex], bossindex
			end
		end
	end
	
	--> return the EJ boss id
	function _detalhes:GetEncounterIdFromBossIndex (mapid, index)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounter_ids and _detalhes.EncounterInformation [mapid].encounter_ids [index]
	end
	
	--> return the table which contain information about the start of a encounter
	function _detalhes:GetEncounterStartInfo (mapid, encounterid)
		local bossindex = _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounter_ids and _detalhes.EncounterInformation [mapid].encounter_ids [encounterid]
		if (bossindex) then
			return _detalhes.EncounterInformation [mapid].encounters [bossindex] and _detalhes.EncounterInformation [mapid].encounters [bossindex].encounter_start
		end
	end
	
	--> return the table which contain information about the end of a encounter
	function _detalhes:GetEncounterEndInfo (mapid, encounterid)
		local bossindex = _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounter_ids and _detalhes.EncounterInformation [mapid].encounter_ids [encounterid]
		if (bossindex) then
			return _detalhes.EncounterInformation [mapid].encounters [bossindex] and _detalhes.EncounterInformation [mapid].encounters [bossindex].encounter_end
		end
	end
	
	--> return the function for the boss
	function _detalhes:GetEncounterEnd (mapid, bossindex)
		local t = _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex]
		if (t) then
			local _end = t.combat_end
			if (_end) then
				return unpack (_end)
			end
		end
		return 
	end
	
	--> generic boss find function
	function _detalhes:GetRaidBossFindFunction (mapid)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].find_boss_encounter
	end
	
	--> return if the boss need sync
	function _detalhes:GetEncounterEqualize (mapid, bossindex)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex] and _detalhes.EncounterInformation [mapid].encounters [bossindex].equalize
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
	
	--> return a table with all names of boss enemies
	function _detalhes:GetEncounterActors (mapid, bossindex)
		
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
	
	function _detalhes:InstanceIsRaid (mapid)
		return _detalhes:InstanceisRaid (mapid)
	end
	function _detalhes:InstanceisRaid (mapid)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].is_raid
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
		local bosstables = _detalhes.EncounterInformation [mapid]
		if (bosstables) then
			local bg = bosstables.backgroundFile
			if (bg) then
				return bg.file, unpack (bg.coords)
			end
		end
	end
	--> return the icon for the raid instance
	function _detalhes:GetRaidIcon (mapid)
		return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].icon
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
		if (mapid and bossindex) then
			return _detalhes.EncounterInformation [mapid] and _detalhes.EncounterInformation [mapid].encounters [bossindex].portrait
		else
			return false
		end
	end
	
	--> return a list with names of adds and bosses
	function _detalhes:GetEncounterActorsName (EJ_EncounterID)
		--code snippet from wowpedia
		local actors = {}
		local stack, encounter, _, _, curSectionID = {}, EJ_GetEncounterInfo (EJ_EncounterID)
		repeat
			local title, description, depth, abilityIcon, displayInfo, siblingID, nextSectionID, filteredByDifficulty, link, startsOpen, flag1, flag2, flag3, flag4 = EJ_GetSectionInfo (curSectionID)
			if (displayInfo ~= 0 and abilityIcon == "") then
				actors [title] = {model = displayInfo, info = description}
			end
			table.insert (stack, siblingID)
			table.insert (stack, nextSectionID)
			curSectionID = table.remove (stack)
		until not curSectionID
		
		return actors
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function _detalhes:InstallEncounter (InstanceTable)
		_detalhes.EncounterInformation [InstanceTable.id] = InstanceTable
		return true
	end
end