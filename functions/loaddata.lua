
local Details = 		_G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local _
local addonName, Details222 = ...
local C_Timer = C_Timer
local UnitName = UnitName

--On Details! Load load default keys into the main object
function Details222.LoadSavedVariables.DefaultProfile()
	for key, value in pairs(Details.default_profile) do
		if (type(value) == "table") then
			Details[key] = Details.CopyTable(value)
		else
			Details[key] = value
		end
	end
end

function Details222.LoadSavedVariables.CharacterData()
	local defaultCharacterData = Details.default_player_data
	local currentCharacterData = _detalhes_database

	--check if the player data exists, if not, load from default
	if (not currentCharacterData) then --NOT EXISTS
		currentCharacterData = Details.CopyTable(defaultCharacterData)
		--[[GLOBAL]] _detalhes_database = currentCharacterData
	end

	--verify if there's new data added to 'default_player_data' and copy it to the savedvariable table
	--do this up to a deepness level of 2, example: currentCharacterData[key][subKey] = any
	for key, value in pairs(defaultCharacterData) do
		if (currentCharacterData[key] == nil) then --the key doesn't exists, add it
			if (type(value) == "table") then
				currentCharacterData[key] = Details.CopyTable(defaultCharacterData[key])
			else
				currentCharacterData[key] = value
			end

		elseif (type(currentCharacterData[key]) == "table") then
			for subKey, subValue in pairs(defaultCharacterData[key]) do
				if (currentCharacterData[key][subKey] == nil) then
					if (type(subValue) == "table") then
						currentCharacterData[key][subKey] = Details.CopyTable(defaultCharacterData[key][subKey])
					else
						currentCharacterData[key][subKey] = subValue
					end
				end
			end
		end

		--copy the key from saved table to Details object
		if (type(value) == "table") then
			Details[key] = Details.CopyTable(currentCharacterData[key])
		else
			Details[key] = currentCharacterData[key]
		end
	end
end

--check if this is a first run, reset, or just load the saved data.
function Details222.LoadSavedVariables.SharedData()
	local defaultAccountData = Details.default_global_data
	local currentAccountData = _detalhes_global

	if (not currentAccountData) then
		currentAccountData = Details.CopyTable(defaultAccountData)
		--[[GLOBAL]] _detalhes_global = currentAccountData
	end

	for key, value in pairs(defaultAccountData) do
		if (currentAccountData[key] == nil) then
			if (type(value) == "table") then
				currentAccountData[key] = Details.CopyTable(defaultAccountData[key])
			else
				currentAccountData[key] = value
			end

		elseif (type(currentAccountData[key]) == "table") then
			if (key == "always_use_profile_name") then
				currentAccountData["always_use_profile_name"] = ""
			end

			if (type(currentAccountData[key]) == "table") then
				for subKey, subValue in pairs(defaultAccountData[key]) do
					if (currentAccountData[key][subKey] == nil) then
						if (type(subValue) == "table") then
							currentAccountData[key][subKey] = Details.CopyTable(defaultAccountData[key][subKey])
						else
							currentAccountData[key][subKey] = subValue
						end
					end
				end
			end
		end

		--copy the key from savedvariables to Details object
		if (type(value) == "table") then
			Details[key] = Details.CopyTable(currentAccountData[key])
		else
			Details[key] = currentAccountData[key]
		end
	end
end

--load previous saved combat data
function Details222.LoadSavedVariables.CombatSegments()
	--this is the table where the character data is saved as well the combat data
	local currentCharacterData = _G["_detalhes_database"] --no need to check if it exists, it's already checked
	if (currentCharacterData == nil) then
		currentCharacterData = {}
	end

	--custom displays - if there's no saved custom display, they will be filled from the StartMeUp() when a new version is installed
	if (_detalhes_global.custom) then
		Details.custom = _detalhes_global.custom
		Details.refresh:r_atributo_custom()
	end

	local bShouldClearAndExit = not currentCharacterData.tabela_historico

	--check integrity of the sub table 'tabelas' and its first index 'current segment'
	if (not bShouldClearAndExit) then
		if (not currentCharacterData.tabela_historico.tabelas or not currentCharacterData.tabela_historico.tabelas[1]) then
			bShouldClearAndExit = true
		end
	end

	--check if is a major version upgrade (usualy API or low level changes)
	if (not bShouldClearAndExit) then
		bShouldClearAndExit = currentCharacterData.last_realversion and currentCharacterData.last_realversion < Details.realversion
	end

	--if can just clear all data and exit
	if (bShouldClearAndExit) then
		Details.tabela_historico = Details.historico:CreateNewSegmentDatabase()
		Details.tabela_overall = Details.combate:NovaTabela()
		Details.tabela_vigente = Details.combate:NovaTabela(_, Details.tabela_overall)
		Details222.PetContainer.Reset()

		if (currentCharacterData.saved_pet_cache) then
			Details:Destroy(currentCharacterData.saved_pet_cache) --saved pet data
			currentCharacterData.saved_pet_cache = nil
		end

		if (currentCharacterData.tabela_overall) then --saved overall data
			Details:Destroy(currentCharacterData.tabela_overall)
			currentCharacterData.tabela_overall = nil
		end

		if (currentCharacterData.tabela_historico) then
			Details:Destroy(currentCharacterData.tabela_historico)
			currentCharacterData.tabela_historico = nil
		end

		return
	else
		--pet owners cache saved on logout
		do
			Details222.PetContainer.Reset()
			if (currentCharacterData.saved_pet_cache) then
				--pet ownership table only exists if the player logoff inside a raid or dungeon
				Details222.PetContainer.SetPetData(currentCharacterData.saved_pet_cache)
				Details:Destroy(currentCharacterData.saved_pet_cache)
				currentCharacterData.saved_pet_cache = nil
			end
		end

		--restore saved overall data
		do
			if (currentCharacterData.tabela_overall) then
				Details.tabela_overall = Details.CopyTable(currentCharacterData.tabela_overall)
				Details:RestoreOverallMetatables()
			else
				Details.tabela_overall = Details.combate:NovaTabela()
				Details.tabela_overall.overall_refreshed = true
			end
		end

		--restore saved segments
		do
			Details.tabela_historico = Details.CopyTable(currentCharacterData.tabela_historico)
			Details:Destroy(currentCharacterData.tabela_historico)
			currentCharacterData.tabela_historico = nil
		end

		--get the first segment saved and use it as current segment
		Details.tabela_vigente = Details.tabela_historico.tabelas[1] --only low level access to this table allowed

		--need refresh for all containers
		for _, actorContainer in ipairs(Details.tabela_overall) do
			actorContainer.need_refresh = true
		end
		for _, actorContainer in ipairs(Details.tabela_vigente) do
			actorContainer.need_refresh = true
		end

		Details:RestoreMetatables()
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--On Details! Load:
	--load the saved config on the addon

function Details:LoadConfig()

	--plugins data
		Details.plugin_database = _detalhes_database.plugin_database or {}

	--startup

		--set the nicktag cache host
			Details:NickTagSetCache (_detalhes_database.nick_tag_cache)

		--count data
			Details:CountDataOnLoad()

		--solo e raid plugin
			if (_detalhes_database.SoloTablesSaved) then
				if (_detalhes_database.SoloTablesSaved.Mode) then
					Details.SoloTables.Mode = _detalhes_database.SoloTablesSaved.Mode
					Details.SoloTables.LastSelected = _detalhes_database.SoloTablesSaved.LastSelected
				else
					Details.SoloTables.Mode = 1
				end
			end

		--switch tables
			Details.switch.slots = _detalhes_global.switchSaved.slots
			Details.switch.table = _detalhes_global.switchSaved.table

			if (Details.switch.table) then
				for i = 1, #Details.switch.table do
					if (not Details.switch.table [i]) then
						Details.switch.table [i] = {}
					end
				end
			end

		--last boss
			Details.last_encounter = _detalhes_database.last_encounter

		--buffs
			Details.savedbuffs = _detalhes_database.savedbuffs
			Details.Buffs:BuildTables()

		--initialize parser
			Details.capture_current = {}
			for captureType, captureValue in pairs(Details.capture_real) do
				Details.capture_current [captureType] = captureValue
			end

		--row animations
			Details:SetUseAnimations()

		--initialize spell cache
			Details:ClearSpellCache()

		--version first run
			if (not _detalhes_database.last_version or _detalhes_database.last_version ~= Details.userversion) then
				Details.is_version_first_run = true
			end

	--profile

		local unitname = UnitName ("player")

		--fix for old versions
		if (type(Details.always_use_profile) == "string") then
			Details.always_use_profile = false
			Details.always_use_profile_name = ""
		end

		if (type(Details.always_use_profile_name) ~= "string") then
			Details.always_use_profile = false
			Details.always_use_profile_name = ""
		end

		--check for "always use this profile"
			if (Details.always_use_profile and not Details.always_use_profile_exception [unitname]) then
				local profile_name = Details.always_use_profile_name
				if (profile_name and profile_name ~= "" and Details:GetProfile (profile_name)) then
					_detalhes_database.active_profile = profile_name
				end
			end

		--character first run
			if (_detalhes_database.active_profile == "") then
				Details.character_first_run = true
				--� a primeira vez que este character usa profiles,  precisa copiar as keys existentes
				local current_profile_name = Details:GetCurrentProfileName()
				Details:GetProfile (current_profile_name, true)
				Details:SaveProfileSpecial()
			end

		--load profile and active instances
			local current_profile_name = Details:GetCurrentProfileName()
		--check if exists, if not, create one
			local profile = Details:GetProfile (current_profile_name, true)

		--instances
			Details.tabela_instancias = _detalhes_database.tabela_instancias or {}

			--fix for version 1.21.0
			if (#Details.tabela_instancias > 0) then --only happens once after the character logon
				for index, saved_skin in ipairs(profile.instances) do
					local instance = Details.tabela_instancias [index]
					if (instance) then
						saved_skin.__was_opened = instance.ativa
						saved_skin.__pos = Details.CopyTable(instance.posicao)
						saved_skin.__locked = instance.isLocked
						saved_skin.__snap = Details.CopyTable(instance.snap)
						saved_skin.__snapH = instance.horizontalSnap
						saved_skin.__snapV = instance.verticalSnap

						for key, value in pairs(instance) do
							if (Details.instance_defaults [key] ~= nil) then
								if (type(value) == "table") then
									saved_skin [key] = Details.CopyTable(value)
								else
									saved_skin [key] = value
								end
							end
						end
					end
				end

				for index, instance in Details:ListInstances() do
					Details.local_instances_config [index] = {
						pos = Details.CopyTable(instance.posicao),
						is_open = instance.ativa,
						attribute = instance.atributo,
						sub_attribute = instance.sub_atributo,
						mode = instance.modo or 2,
						modo = instance.modo or 2,
						segment = instance.segmento,
						snap = Details.CopyTable(instance.snap),
						horizontalSnap = instance.horizontalSnap,
						verticalSnap = instance.verticalSnap,
						sub_atributo_last = instance.sub_atributo_last,
						isLocked = instance.isLocked
					}

					if (Details.local_instances_config [index].isLocked == nil) then
						Details.local_instances_config [index].isLocked = false
					end
				end

				Details.tabela_instancias = {}
			end

		--apply the profile
		Details:ApplyProfile(current_profile_name, true)
end

--On Details! Load count logons, tutorials, etc
function Details:CountDataOnLoad()
	--basic
	if (not _detalhes_global.got_first_run) then
		Details.is_first_run = true
	end

	--tutorial
	self.tutorial = self.tutorial or {}

	self.tutorial.logons = self.tutorial.logons or 0
	self.tutorial.logons = self.tutorial.logons + 1

	self.tutorial.unlock_button = self.tutorial.unlock_button or 0
	self.tutorial.version_announce = self.tutorial.version_announce or 0
	self.tutorial.main_help_button = self.tutorial.main_help_button or 0
	self.tutorial.alert_frames = self.tutorial.alert_frames or {false, false, false, false, false, false}

	self.tutorial.main_help_button = self.tutorial.main_help_button + 1

	self.character_data = self.character_data or {logons = 0}
	self.character_data.logons = self.character_data.logons + 1
end