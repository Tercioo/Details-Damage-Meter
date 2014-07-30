--[[this file save the data when player leave the game]]

local _detalhes = 		_G._detalhes

function _detalhes:WipeConfig()
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	
	local b = CreateFrame ("button", "DetailsResetConfigButton", UIParent, "OptionsButtonTemplate")
	tinsert (UISpecialFrames, "DetailsResetConfigButton")
	
	b:SetSize (250, 40)
	b:SetText (Loc ["STRING_SLASH_WIPECONFIG_CONFIRM"])
	b:SetScript ("OnClick", function() _detalhes.wipe_full_config = true; ReloadUI(); end)
	b:SetPoint ("center", UIParent, "center", 0, 0)
end

local is_exception = {
	["nick_tag_cache"] = true
}

function _detalhes:SaveConfig()

	--> nicktag cache
		--_detalhes.copy_nick_tag = table_deepcopy (_detalhes_database.nick_tag_cache)

	--> cleanup
		_detalhes:PrepareTablesForSave()
		_detalhes_database.tabela_instancias = _detalhes.tabela_instancias
		_detalhes_database.tabela_historico = _detalhes.tabela_historico
		
		local name, ttype, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
		if (ttype == "party" or ttype == "raid") then
			--> salvar container de pet
			_detalhes_database.tabela_pets = _detalhes.tabela_pets.pets
		end
		
		_detalhes:TimeDataCleanUpTemporary()
		
	--> buffs
		_detalhes.Buffs:SaveBuffs()
	
	--> salva o container do personagem
		for key, value in pairs (_detalhes.default_player_data) do
			if (not is_exception [key]) then
				_detalhes_database [key] = _detalhes [key]
			end
		end
	
	--> salva o container das globais
		for key, value in pairs (_detalhes.default_global_data) do
			if (key ~= "__profiles") then
				_detalhes_global [key] = _detalhes [key]
			end
		end

	--> solo e raid mode
		if (_detalhes.SoloTables.Mode) then
			_detalhes_database.SoloTablesSaved = {}
			_detalhes_database.SoloTablesSaved.Mode = _detalhes.SoloTables.Mode
			if (_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode]) then
				_detalhes_database.SoloTablesSaved.LastSelected = _detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].real_name
			end
		end
		
		_detalhes_database.RaidTablesSaved = nil
		
	--> salva switch tables
		_detalhes_global.switchSaved.slots = _detalhes.switch.slots
		_detalhes_global.switchSaved.table = _detalhes.switch.table
	
	--> last boss
		_detalhes_database.last_encounter = _detalhes.last_encounter
	
	--> last versions
		_detalhes_database.last_realversion = _detalhes.realversion --> core number
		_detalhes_database.last_version = _detalhes.userversion --> version
		_detalhes_global.got_first_run = true
	
end
