--[[this file save the data when player leave the game]]

local Details = 		_G.Details
local addonName, Details222 = ...

function Details:WipeConfig()
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )

	local wipeButton = CreateFrame("button", "DetailsResetConfigButton", UIParent, "BackdropTemplate")
	wipeButton:SetSize(270, 40)
	wipeButton:SetScript("OnClick", function() Details.wipe_full_config = true; ReloadUI(); end)
	wipeButton:SetPoint("center", UIParent, "center", 0, 0)

	table.insert(UISpecialFrames, "DetailsResetConfigButton")

	DetailsFramework:ApplyStandardBackdrop(wipeButton)

	local label = DetailsFramework:CreateLabel(wipeButton, Loc ["STRING_SLASH_WIPECONFIG_CONFIRM"])
	label:SetPoint("center", 0, 0)

	wipeButton.close_button = CreateFrame("Button", nil, wipeButton, "UIPanelCloseButton")
	wipeButton.close_button:SetWidth(16)
	wipeButton.close_button:SetHeight(16)
	wipeButton.close_button:SetPoint("TOPRIGHT", wipeButton, "TOPRIGHT", -1, -1)
	wipeButton.close_button:SetText("X")
	wipeButton.close_button:SetFrameLevel(wipeButton:GetFrameLevel()+5)
end

local is_exception = {
	["nick_tag_cache"] = true
}

function Details:SaveLocalInstanceConfig()
	for index, instance in Details:ListInstances() do
		--check for the max size toggle, don't save it
		if (instance.is_in_max_size) then
			instance.is_in_max_size = false
			instance:SetSize(instance.original_width, instance.original_height)
		end

		--save local instance data
		local a1, a2 = instance:GetDisplay()

		local t = {
			pos = Details.CopyTable(instance:GetPosition()),
			is_open = instance:IsEnabled(),
			attribute = a1 or 1,
			sub_attribute = a2 or 1,
			modo = instance:GetMode() or 2,
			mode = instance:GetMode() or 2,
			segment = instance:GetSegment() or 0,
			snap = Details.CopyTable(instance.snap),
			horizontalSnap = instance.horizontalSnap,
			verticalSnap = instance.verticalSnap,
			sub_atributo_last = instance.sub_atributo_last or {1, 1, 1, 1, 1},
			isLocked = instance.isLocked,
			last_raid_plugin = instance.last_raid_plugin
		}

		if (t.isLocked == nil) then
			t.isLocked = false
		end

		if (Details.profile_save_pos) then
			local cprofile = Details:GetProfile()
			local skin = cprofile.instances [instance:GetId()]
			if (skin) then
				t.pos = Details.CopyTable(skin.__pos)
				t.horizontalSnap = skin.__snapH
				t.verticalSnap = skin.__snapV
				t.snap = Details.CopyTable(skin.__snap)
				t.is_open = skin.__was_opened
				t.isLocked = skin.__locked
			end
		end

		Details.local_instances_config [index] = t
	end
end

function Details:SaveConfig()
	--save character instance settings, e.g. which attribute is selected, position, etc
	Details:SaveLocalInstanceConfig()

	--cleanup
	Details:PrepareTablesForSave()

	_detalhes_database.tabela_instancias = {} --Details.tabela_instancias --[[instances now saves only inside the profile --]]
	_detalhes_database.tabela_historico = Details.tabela_historico

	if (Details.overall_clear_logout) then
		if (_detalhes_database.tabela_overall) then
			_detalhes_database.tabela_overall = nil
		end
	else
		_detalhes_database.tabela_overall = Details.tabela_overall
	end

	local name, instanceType = GetInstanceInfo()
	if (instanceType == "party" or instanceType == "raid") then
		--save pet ownership information
		_detalhes_database.saved_pet_cache = Details222.PetContainer.GetPets()
	end

	--clear temporarly time data (charts)
	xpcall(Details.TimeDataCleanUpTemporary, Details.saver_error_func)

	--buffs - feature lost in time
	xpcall(Details.Buffs.SaveBuffs, Details.saver_error_func)

	--date
	Details.last_day = date("%d")

	--save character data (unique for each character)
	for key in pairs(Details.default_player_data) do
		if (not is_exception[key]) then
			_detalhes_database[key] = Details[key]
		end
	end

	--save shared data (shared among all characters)
	for key in pairs(Details.default_global_data) do
		if (key ~= "__profiles") then
			_detalhes_global[key] = Details[key]
		end
	end

	--plugin for solo mode (currently none exists)
	if (Details.SoloTables.Mode) then
		_detalhes_database.SoloTablesSaved = {}
		_detalhes_database.SoloTablesSaved.Mode = Details.SoloTables.Mode
		if (Details.SoloTables.Plugins[Details.SoloTables.Mode]) then
			_detalhes_database.SoloTablesSaved.LastSelected = Details.SoloTables.Plugins[Details.SoloTables.Mode].real_name
		end
	end

	_detalhes_database.RaidTablesSaved = nil

	--save bookmark tables
	_detalhes_global.switchSaved.slots = Details.switch.slots
	_detalhes_global.switchSaved.table = Details.switch.table

	--last boss (boss name)
	_detalhes_database.last_encounter = Details.last_encounter

	--save the details version of the last time the user logged out
	_detalhes_database.last_realversion = Details.realversion --core number
	_detalhes_database.last_version = Details.userversion --version
	_detalhes_global.got_first_run = true
end
