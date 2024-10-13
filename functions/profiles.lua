
local Details = 		_G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local _
local addonName, Details222 = ...
local detailsFramework = DetailsFramework

---return the current profile name
---@return string
function Details:GetCurrentProfileName()
	if (_detalhes_database.active_profile == "") then
		local characterKey = UnitName ("player") .. "-" .. GetRealmName()
		_detalhes_database.active_profile = characterKey
	end
	return _detalhes_database.active_profile
end

---create a new profile
---@param profileName string
---@return boolean|table
function Details:CreateProfile(profileName)
	if (not profileName or type(profileName) ~= "string" or profileName == "") then
		return false
	end

	--check if already exists
	if (_detalhes_global.__profiles[profileName]) then
		return false
	end

	--copy the default table
	local newProfile = Details.CopyTable(Details.default_profile)
	newProfile.instances = {}

	--add to global container
	_detalhes_global.__profiles[profileName] = newProfile

	--end
	return newProfile
end

---return the list os all profiles
---@return table
function Details:GetProfileList()
	local profileList = {}
	for profileName in pairs(_detalhes_global.__profiles) do
		profileList[#profileList + 1] = profileName
	end
	return profileList
end

---delete a profile
---@param profileName string|nil
---@return boolean
function Details:EraseProfile(profileName)
	if (not profileName) then
		return false
	end

	--erase the profile from the profile container
	_detalhes_global.__profiles[profileName] = nil

	if (_detalhes_database.active_profile == profileName) then
		local characterKey = UnitName("player") .. "-" .. GetRealmName()
		local profile = Details:GetProfile(characterKey)

		if (profile) then
			Details:ApplyProfile(characterKey, true)
		else
			Details:CreateProfile(characterKey)
			Details:ApplyProfile(characterKey, true)
		end
	end

	return true
end

---return the profile table requested
---@param profileName string
---@param create boolean
---@return table|boolean
function Details:GetProfile(profileName, create)
	if (not profileName) then
		profileName = Details:GetCurrentProfileName()
	end

	local profile = _detalhes_global.__profiles[profileName]

	if (not profile and not create) then
		return false

	elseif (not profile and create) then
		profile = Details:CreateProfile(profileName)
	end

	return profile
end

function Details:SetProfileCProp (name, cprop, value)
	if (not name) then
		name = Details:GetCurrentProfileName()
	end

	local profile = Details:GetProfile (name, false)

	if (profile) then
		if (type(value) == "table") then
			rawset(profile, cprop, Details.CopyTable(value))
		else
			rawset(profile, cprop, value)
		end
	else
		return
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Profiles:
	--reset the profile
function Details:ResetProfile (profile_name)

	--get the profile
		local profile = Details:GetProfile (profile_name, true)

		if (not profile) then
			return false
		end

	--reset all already created instances
		for index, instance in Details:ListInstances() do
			if (not instance.baseframe) then
				instance:AtivarInstancia()
			end
			instance.skin = ""
			instance:ChangeSkin (Details.default_skin_to_use)
		end

		for index, instance in pairs(Details.unused_instances) do
			if (not instance.baseframe) then
				instance:AtivarInstancia()
			end
			instance.skin = ""
			instance:ChangeSkin(Details.default_skin_to_use)
		end

	--reset the profile
		Details:Destroy(profile.instances)

		--export first instance
		local instance = Details:GetInstance(1)
		local exported = instance:ExportSkin()
		exported.__was_opened = instance:IsEnabled()
		exported.__pos = Details.CopyTable(instance:GetPosition())
		exported.__locked = instance.isLocked
		exported.__snap = {}
		exported.__snapH = false
		exported.__snapV = false
		profile.instances [1] = exported
		instance.horizontalSnap = false
		instance.verticalSnap = false
		instance.snap = {}

		Details:ApplyProfile (profile_name, true)

	--end
		return true
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Profiles:
	--return the profile table requested

function Details:CreatePanicWarning()
	Details.instance_load_failed = CreateFrame("frame", "DetailsPanicWarningFrame", UIParent,"BackdropTemplate")
	Details.instance_load_failed:SetHeight(80)
	--tinsert(UISpecialFrames, "DetailsPanicWarningFrame")
	Details.instance_load_failed.text = Details.instance_load_failed:CreateFontString(nil, "overlay", "GameFontNormal")
	Details.instance_load_failed.text:SetPoint("center", Details.instance_load_failed, "center")
	Details.instance_load_failed.text:SetTextColor(1, 0.6, 0)
	Details.instance_load_failed:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	Details.instance_load_failed:SetBackdropColor(1, 0, 0, 0.2)
	Details.instance_load_failed:SetPoint("topleft", UIParent, "topleft", 0, -250)
	Details.instance_load_failed:SetPoint("topright", UIParent, "topright", 0, -250)
end

local safe_load = function(func, param1, ...)
	local okey, errortext = pcall(func, param1, ...)
	if (not okey) then
		if (not Details.instance_load_failed) then
			Details:CreatePanicWarning()
		end
		Details.do_not_save_skins = true
		Details.instance_load_failed.text:SetText("Failed to load a Details! window.\n/reload or reboot the game client may fix the problem.\nIf the problem persist, try /details reinstall.\nError: " .. errortext .. "")
	end
	return okey
end

function Details:ApplyProfile(profileName, bNoSave, bIsCopy)
	--get the profile
		local profile = Details:GetProfile(profileName, true)

	--if the profile doesn't exist, just quit
		if (not profile) then
			Details:Msg("Profile Not Found.")
			return false
		end

		profile.ocd_tracker = nil --moved to local character saved

	--always save the previous profile, except if nosave flag is up
		if (not bNoSave) then
			--salva o profile ativo no momento
			Details:SaveProfile()
		end

	--update profile keys before go
		for key, value in pairs(Details.default_profile) do
			--the entire key doesn't exist
			if (profile [key] == nil) then
				if (type(value) == "table") then
					profile [key] = Details.CopyTable(Details.default_profile [key])
				else
					profile [key] = value
				end

			--the key exist and is a table, check for missing values on sub tables
			elseif (type(value) == "table") then
				--deploy only copy non existing data
				Details.table.deploy(profile [key], value)
			end
		end

	--apply the profile values
		for key, _ in pairs(Details.default_profile) do
			local value = profile [key]

			if (type(value) == "table") then
				if (key == "class_specs_coords") then
					value = Details.CopyTable(Details.default_profile.class_specs_coords)
				end

				local ctable = Details.CopyTable(value)
				Details [key] = ctable
			else
				Details [key] = value
			end
		end

	--set the current profile
	if (not bIsCopy) then
		Details.active_profile = profileName
		_detalhes_database.active_profile = profileName
	end

	--apply the skin
		--first save the local instance configs
		Details:SaveLocalInstanceConfig()

		local saved_skins = profile.instances
		local instance_limit = Details.instances_amount

		--then close all opened instances
		for index, instance in Details:ListInstances() do
			if (not getmetatable(instance)) then
				instance.iniciada = false
				setmetatable(instance, Details)
			end
			if (instance:IsStarted()) then
				if (instance:IsEnabled()) then
					instance:ShutDown()
				end
			end
		end

		--check if there is a skin saved or this is a empty profile
		if (#saved_skins == 0) then
			local instance1 = Details:GetInstance(1)
			if (not instance1) then
				instance1 = Details:CreateInstance (1)
			end

			--apply default config on this instance (flat skin texture was 'ResetInstanceConfig' running).
			instance1.modo = 2
			instance1:ResetInstanceConfig()
			instance1.skin = "no skin"
			instance1:ChangeSkin (Details.default_skin_to_use)

			--release the snap and lock
			instance1:LoadLocalInstanceConfig()
			instance1.snap = {}
			instance1.horizontalSnap = nil
			instance1.verticalSnap = nil
			instance1:LockInstance (false)

			if (#Details.tabela_instancias > 1) then
				for i = #Details.tabela_instancias, 2, -1 do
					Details.tabela_instancias [i].modo = 2
					Details.unused_instances [i] = Details.tabela_instancias [i]
					Details.tabela_instancias [i] = nil
				end
			end
		else

			--load skins
			local instances_loaded = 0

			for index, skin in ipairs(saved_skins) do
				if (instance_limit < index) then
					break
				end

				--get the instance
				local instance = Details:GetInstance(index)
				if (not instance) then
					--create a instance without creating its frames (not initializing)
					instance = Details:CreateDisabledInstance (index, skin)
				end

				--copy skin
				for key, value in pairs(skin) do
					if (type(value) == "table") then
						instance [key] = Details.CopyTable(value)
					else
						instance [key] = value
					end
				end

				--apply default values if some key is missing
				instance:LoadInstanceConfig()

				--reset basic config
				instance.snap = {}
				instance.horizontalSnap = nil
				instance.verticalSnap = nil
				instance:LockInstance (false)

				--load data saved for this character only
				instance:LoadLocalInstanceConfig()
				if (skin.__was_opened) then
					if (not safe_load (Details.AtivarInstancia, instance, nil, true)) then
						return
					end
				else
					instance.ativa = false
				end

				instance.modo = instance.modo or 2

				--load data saved again
				instance:LoadLocalInstanceConfig()
				--check window positioning
				if (Details.profile_save_pos) then
					--print("is profile save pos", skin.__pos.normal.x, skin.__pos.normal.y)
					if (skin.__pos) then
						instance.posicao = Details.CopyTable(skin.__pos)
					else
						if (not instance.posicao) then
							print("|cFFFF2222Details!: Position for a window wasn't found! Moving it to the center of the screen.|r\nType '/details exitlog' to check for errors.")
							instance.posicao = {normal = {x = 1, y = 1, w = 300, h = 200}, solo = {}}
						elseif (not instance.posicao.normal) then
							print("|cFFFF2222Details!: Normal position for a window wasn't found! Moving it to the center of the screen.|r\nType '/details exitlog' to check for errors.")
							instance.posicao.normal = {x = 1, y = 1, w = 300, h = 200}
						end
					end

					instance.isLocked = skin.__locked
					instance.snap = Details.CopyTable(skin.__snap) or {}
					instance.horizontalSnap = skin.__snapH
					instance.verticalSnap = skin.__snapV
				else
					if (not instance.posicao) then
						instance.posicao = {normal = {x = 1, y = 1, w = 300, h = 200}, solo = {}}
					elseif (not instance.posicao.normal) then
						instance.posicao.normal = {x = 1, y = 1, w = 300, h = 200}
					end
				end

				--open the instance
				if (instance:IsEnabled()) then
					if (not instance.baseframe) then
						instance:AtivarInstancia()
					end

					instance:LockInstance (instance.isLocked)

					--tinsert(Details.resize_debug, #Details.resize_debug+1, "libwindow X (427): " .. (instance.libwindow.x or 0))
					instance:RestoreMainWindowPosition()
					instance:ReajustaGump()
					--instance:SaveMainWindowPosition()
					--Load StatusBarSaved values and options.
					instance.StatusBarSaved = skin.StatusBarSaved or {options = {}}
					instance.StatusBar.options = instance.StatusBarSaved.options
					Details.StatusBar:UpdateChilds (instance)
					instance:ChangeSkin()

				else
					instance.skin = skin.skin
				end

				instances_loaded = instances_loaded + 1
			end

			--move unused instances for unused container
			if (#Details.tabela_instancias > instances_loaded) then
				for i = #Details.tabela_instancias, instances_loaded+1, -1 do
					Details.unused_instances [i] = Details.tabela_instancias [i]
					Details.tabela_instancias [i] = nil
				end
			end

			--check all snaps for invalid entries
			for i = 1, instances_loaded do
				local instance = Details:GetInstance(i)
				local previous_instance_id = Details:GetInstance(i-1) and Details:GetInstance(i-1):GetId() or 0
				local next_instance_id = Details:GetInstance(i+1) and Details:GetInstance(i+1):GetId() or 0

				for snap_side, instance_id in pairs(instance.snap) do
					if (instance_id < 1) then --invalid instance
						instance.snap [snap_side] = nil
					elseif (instance_id ~= previous_instance_id and instance_id ~= next_instance_id) then --no match
						instance.snap [snap_side] = nil
					end
				end
			end

			--auto realign windows
			if (not Details.initializing) then
				for _, instance in Details:ListInstances() do
					if (instance:IsEnabled()) then
						Details.move_janela_func(instance.baseframe, true, instance)
						Details.move_janela_func(instance.baseframe, false, instance)
					end
				end
			else
				--is in startup
				for _, instance in Details:ListInstances() do
					for side, id in pairs(instance.snap) do
						local window = Details.tabela_instancias [id]
						if (not window.ativa) then
							instance.snap [side] = nil
							if ((side == 1 or side == 3) and (not instance.snap [1] and not instance.snap [3])) then
								instance.horizontalSnap = false
							elseif ((side == 2 or side == 4) and (not instance.snap [2] and not instance.snap [4])) then
								instance.verticalSnap = false
							end
						end
					end
					if (not instance:IsEnabled()) then
						for side, id in pairs(instance.snap) do
							instance.snap [side] = nil
						end
						instance.horizontalSnap = false
						instance.verticalSnap = false
					end
				end
			end

		end

		--check instance amount
		Details.opened_windows = 0
		for index = 1, Details.instances_amount do
			local instance = Details.tabela_instancias [index]
			if (instance and instance.ativa) then
				Details.opened_windows = Details.opened_windows + 1
			end
		end

		--update tooltip settings
		Details:SetTooltipBackdrop()

		--update the numerical system
		Details:SelectNumericalSystem()

		--refresh the update interval
		Details:RefreshUpdater()

		--refresh animation functions
		Details:RefreshAnimationFunctions()

		--refresh broadcaster tools
		Details:LoadFramesForBroadcastTools()

		--change the rogue spec combat icon to outlaw depending on the game version
		Details:HandleRogueCombatSpecIconByGameVersion()

	if (Details.initializing) then
		Details.profile_loaded = true
	end

	Details:SendEvent("DETAILS_PROFILE_APPLYED", profileName)

	--to be removed in the future (2023-08-13)
	if (Details.time_type == 3 or not Details.time_type) then
		Details.time_type = 2
	end

	--enable all captures, this is a fix for the old performance profiles which doesn't exiss anymore
	Details.capture_real["damage"] = true
	Details.capture_real["heal"] = true
	Details.capture_real["energy"] = true
	Details.capture_real["miscdata"] = true
	Details.capture_real["aura"] = true
	Details.capture_real["spellcast"] = true

	return true
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Profiles:
	--return the profile table requested

function Details:SaveProfile (saveas)

	--get the current profile

		local profile_name

		if (saveas) then
			profile_name = saveas
		else
			profile_name = Details:GetCurrentProfileName()
		end

		local profile = Details:GetProfile (profile_name, true)

	--save default keys
		for key, _ in pairs(Details.default_profile) do

			local current_value = Details [key]

			if (type(current_value) == "table") then
				local ctable = Details.CopyTable(current_value)
				profile [key] = ctable
			else
				profile [key] = current_value
			end

		end

	--save skins
	if (not Details.do_not_save_skins) then
		Details:Destroy(profile.instances)
		for index, instance in ipairs(Details.tabela_instancias) do
			local exported = instance:ExportSkin()
			exported.__was_opened = instance:IsEnabled()
			exported.__pos = Details.CopyTable(instance:GetPosition())
			exported.__locked = instance.isLocked
			exported.__snap = Details.CopyTable(instance.snap)
			exported.__snapH = instance.horizontalSnap
			exported.__snapV = instance.verticalSnap
			profile.instances[index] = exported
		end
	end
	Details.do_not_save_skins = nil
	Details:SaveLocalInstanceConfig()

	return profile
end

local default_profile = {
	--spec coords, reset with: /run Details.class_specs_coords = nil
	class_specs_coords = {
		[577] = {128/512, 192/512, 256/512, 320/512}, --havoc demon hunter
		[581] = {192/512, 256/512, 256/512, 320/512}, --vengeance demon hunter

		[250] = {0, 64/512, 0, 64/512}, --blood dk
		[251] = {64/512, 128/512, 0, 64/512}, --frost dk
		[252] = {128/512, 192/512, 0, 64/512}, --unholy dk

		[102] = {192/512, 256/512, 0, 64/512}, -- druid balance
		[103] = {256/512, 320/512, 0, 64/512}, -- druid feral
		[104] = {320/512, 384/512, 0, 64/512}, -- druid guardian
		[105] = {384/512, 448/512, 0, 64/512}, -- druid resto

		[253] = {448/512, 512/512, 0, 64/512}, -- hunter bm
		[254] = {0, 64/512, 64/512, 128/512}, --hunter marks
		[255] = {64/512, 128/512, 64/512, 128/512}, --hunter survivor

		[62] = {(128/512) + 0.001953125, 192/512, 64/512, 128/512}, --mage arcane
		[63] = {192/512, 256/512, 64/512, 128/512}, --mage fire
		[64] = {256/512, 320/512, 64/512, 128/512}, --mage frost

		[268] = {320/512, 384/512, 64/512, 128/512}, --monk bm
		[269] = {448/512, 512/512, 64/512, 128/512}, --monk ww
		[270] = {384/512, 448/512, 64/512, 128/512}, --monk mw

		[65] = {0, 64/512, 128/512, 192/512}, --paladin holy
		[66] = {64/512, 128/512, 128/512, 192/512}, --paladin protect
		[70] = {(128/512) + 0.001953125, 192/512, 128/512, 192/512}, --paladin ret

		[256] = {192/512, 256/512, 128/512, 192/512}, --priest disc
		[257] = {256/512, 320/512, 128/512, 192/512}, --priest holy
		[258] = {(320/512) + (0.001953125 * 4), 384/512, 128/512, 192/512}, --priest shadow

		[259] = {384/512, 448/512, 128/512, 192/512}, --rogue assassination
		[260] = {448/512, 512/512, 128/512, 192/512}, --rogue combat
		[261] = {0, 64/512, 192/512, 256/512}, --rogue sub

		[262] = {64/512, 128/512, 192/512, 256/512}, --shaman elemental
		[263] = {128/512, 192/512, 192/512, 256/512}, --shamel enhancement
		[264] = {192/512, 256/512, 192/512, 256/512}, --shaman resto

		[265] = {256/512, 320/512, 192/512, 256/512}, --warlock aff
		[266] = {320/512, 384/512, 192/512, 256/512}, --warlock demo
		[267] = {384/512, 448/512, 192/512, 256/512}, --warlock destro

		[71] = {448/512, 512/512, 192/512, 256/512}, --warrior arms
		[72] = {0, 64/512, 256/512, 320/512}, --warrior fury
		[73] = {64/512, 128/512, 256/512, 320/512}, --warrior protect

		[1467] = {256/512, 320/512, 256/512, 320/512}, -- Devastation
		[1468] = {320/512, 384/512, 256/512, 320/512}, -- Preservation
		[1473] = {384/512, 448/512, 256/512, 320/512}, -- Augmentation
	},

	--class icons and colors
	class_icons_small = [[Interface\AddOns\Details\images\classes_small]],
	class_coords = {
		["DEMONHUNTER"] = {
			0.73828126 / 2, -- [1]
			1 / 2, -- [2]
			0.5 / 2, -- [3]
			0.75 / 2, -- [4]
		},
		["HUNTER"] = {
			0, -- [1]
			0.25 / 2, -- [2]
			0.25 / 2, -- [3]
			0.5 / 2, -- [4]
		},
		["WARRIOR"] = {
			0, -- [1]
			0.25 / 2, -- [2]
			0, -- [3]
			0.25 / 2, -- [4]
		},
		["ROGUE"] = {
			0.49609375 / 2, -- [1]
			0.7421875 / 2, -- [2]
			0, -- [3]
			0.25 / 2, -- [4]
		},
		["MAGE"] = {
			0.25 / 2, -- [1]
			0.49609375 / 2, -- [2]
			0, -- [3]
			0.25 / 2, -- [4]
		},
		["PET"] = {
			0.25 / 2, -- [1]
			0.49609375 / 2, -- [2]
			0.75 / 2, -- [3]
			1 / 2, -- [4]
		},
		["DRUID"] = {
			0.7421875 / 2, -- [1]
			0.98828125 / 2, -- [2]
			0, -- [3]
			0.25 / 2, -- [4]
		},
		["MONK"] = {
			0.5 / 2, -- [1]
			0.73828125 / 2, -- [2]
			0.5 / 2, -- [3]
			0.75 / 2, -- [4]
		},
		["DEATHKNIGHT"] = {
			0.25 / 2, -- [1]
			0.5 / 2, -- [2]
			0.5 / 2, -- [3]
			0.75 / 2, -- [4]
		},
		["UNKNOW"] = {
			0.5 / 2, -- [1]
			0.75 / 2, -- [2]
			0.75 / 2, -- [3]
			1 / 2, -- [4]
		},
		["PRIEST"] = {
			0.49609375 / 2, -- [1]
			0.7421875 / 2, -- [2]
			0.25 / 2, -- [3]
			0.5 / 2, -- [4]
		},
		["UNGROUPPLAYER"] = {
			0.5 / 2, -- [1]
			0.75 / 2, -- [2]
			0.75 / 2, -- [3]
			1 / 2, -- [4]
		},
		["Alliance"] = {
			0.49609375 / 2, -- [1]
			0.742187 / 25, -- [2]
			0.75 / 2, -- [3]
			1 / 2, -- [4]
		},
		["WARLOCK"] = {
			0.7421875 / 2, -- [1]
			0.98828125 / 2, -- [2]
			0.25 / 2, -- [3]
			0.5 / 2, -- [4]
		},
		["ENEMY"] = {
			0, -- [1]
			0.25 / 2, -- [2]
			0.75 / 2, -- [3]
			1 / 2, -- [4]
		},
		["Horde"] = {
			0.7421875 / 2, -- [1]
			0.98828125 / 2, -- [2]
			0.75 / 2, -- [3]
			1 / 2, -- [4]
		},
		["PALADIN"] = {
			0, -- [1]
			0.25 / 2, -- [2]
			0.5 / 2, -- [3]
			0.75 / 2, -- [4]
		},
		["MONSTER"] = {
			0, -- [1]
			0.25 / 2, -- [2]
			0.75 / 2, -- [3]
			1 / 2, -- [4]
		},
		["SHAMAN"] = {
			0.25 / 2, -- [1]
			0.49609375 / 2, -- [2]
			0.25 / 2, -- [3]
			0.5 / 2, -- [4]
		},
		["EVOKER"] = {
			0.50390625, -- [1]
			0.625, -- [2]
			0, -- [3]
			0.125, -- [4]
		},
	},

	class_colors = {
		["DEMONHUNTER"] = {
			0.64,
			0.19,
			0.79,
		},
		["HUNTER"] = {
			0.67, -- [1]
			0.83, -- [2]
			0.45, -- [3]
		},
		["WARRIOR"] = {
			0.78, -- [1]
			0.61, -- [2]
			0.43, -- [3]
		},
		["PALADIN"] = {
			0.96, -- [1]
			0.55, -- [2]
			0.73, -- [3]
		},
		["SHAMAN"] = {
			0, -- [1]
			0.44, -- [2]
			0.87, -- [3]
		},
		["MAGE"] = {
			0.41, -- [1]
			0.8, -- [2]
			0.94, -- [3]
		},
		["ROGUE"] = {
			1, -- [1]
			0.96, -- [2]
			0.41, -- [3]
		},
		["UNKNOW"] = {
			0.2, -- [1]
			0.2, -- [2]
			0.2, -- [3]
		},
		["PRIEST"] = {
			1, -- [1]
			1, -- [2]
			1, -- [3]
		},
		["WARLOCK"] = {
			0.58, -- [1]
			0.51, -- [2]
			0.79, -- [3]
		},
		["UNGROUPPLAYER"] = {
			0.4, -- [1]
			0.4, -- [2]
			0.4, -- [3]
		},
		["ENEMY"] = {
			0.94117, -- [1]
			0, -- [2]
			0.0196, -- [3]
			1, -- [4]
		},
		["version"] = 1,
		["PET"] = {
			0.3, -- [1]
			0.4, -- [2]
			0.5, -- [3]
		},
		["DRUID"] = {
			1, -- [1]
			0.49, -- [2]
			0.04, -- [3]
		},
		["MONK"] = {
			0, -- [1]
			1, -- [2]
			0.59, -- [3]
		},
		["DEATHKNIGHT"] = {
			0.77, -- [1]
			0.12, -- [2]
			0.23, -- [3]
		},
		["ARENA_GREEN"] = {
			0.686, -- [1]
			0.372, -- [2]
			0.905, -- [3]
		},
		["ARENA_YELLOW"] = {
			1, -- [1]
			1, -- [2]
			0.25, -- [3]
		},
		["NEUTRAL"] = {
			1, -- [1]
			1, -- [2]
			0, -- [3]
		},
		["SELF"] = {
			0.89019, -- [1]
			0.32156, -- [2]
			0.89019, -- [3]
		},

		["EVOKER"] = {
			--0.2000,
			--0.4980,
			--0.5764,
			0.2000,
			0.5764,
			0.4980,
		},
	},

	death_log_colors = {
		damage = "red",
		heal = "green",
		friendlyfire = "darkorange",
		cooldown = "yellow",
		debuff = "purple",
		buff = "silver",
	},

	fade_speed = 0.15,
	use_self_color = false,

	--minimap
		minimap = {hide = false, radius = 160, minimapPos = 220, onclick_what_todo = 1, text_type = 1, text_format = 3},
		data_broker_text = "",

	--hotcorner
		hotcorner_topleft = {hide = false},

	--PvP
		only_pvp_frags = false,
		color_by_arena_team = true,
		show_arena_role_icon = false, --deprecated: this has been moved to instance settings 05.06.22 (tercio)

	--window settings
		max_window_size = {width = 480, height = 450},
		new_window_size = {width = 310, height = 158},
		window_clamp = {-8, 0, 21, -14},
		grouping_horizontal_gap = 0,
		disable_window_groups = false,
		disable_reset_button = false,
		disable_lock_ungroup_buttons = false,
		disable_stretch_from_toolbar = false,
		disable_stretch_button = false,
		disable_alldisplays_window = false,
		damage_taken_everything = false,

	--info window
		player_details_window = {
			skin = "ElvUI",
			bar_texture = "Skyline",
			scale = 1,
		},

		options_window = {
			scale = 1,
		},

	--segments
		segments_amount = 25,
		segments_amount_to_save = 15,
		--max amount of boss wipes allowed
		segments_amount_boss_wipes = 10,
		--should boss wipes delete segments with less progression?
		segments_boss_wipes_keep_best_performance = true,
		segments_panic_mode = false,
		segments_auto_erase = 1,

	--instances
		instances_amount = 5,
		instances_segments_locked = true,
		instances_disable_bar_highlight = false,
		instances_menu_click_to_open = false,
		instances_no_libwindow = false,
		instances_suppress_trash = 0,

	--if clear ungroup characters when logout
		clear_ungrouped = true,

	--if clear graphic data when logout
		clear_graphic = true,

	--item level tracker
		track_item_level = false,

	--text settings
		font_sizes = {menus = 10},
		font_faces = {menus = "Friz Quadrata TT"},
		ps_abbreviation = 3,
		total_abbreviation = 2,
		numerical_system = 1,
		numerical_system_symbols = "auto",

	--performance
		use_row_animations = true,
		--default animation speed - % per second
		animation_speed = 33,
		--percent to trigger fast speed - if the percent is hiogher than this it will increase the speed
		animation_speed_triggertravel = 5,
		--minumim speed multiplication value
		animation_speed_mintravel = 0.45,
		--max speed multiplication value
		animation_speed_maxtravel = 3,

		animate_scroll = false,
		use_scroll = false,
		scroll_speed = 2,
		update_speed = 0.20,
		time_type = 2,
		time_type_original = 2,

		use_realtimedps = false,
		realtimedps_order_bars = false,
		realtimedps_always_arena = false,

		memory_threshold = 3,
		memory_ram = 64,
		remove_realm_from_name = true,
		trash_concatenate = false,
		trash_auto_remove = false,
		world_combat_is_trash = false,

	--death log
		deadlog_limit = 16,
		deadlog_events = 32,

	--report
		report_lines = 5,
		report_to_who = "",
		report_heal_links = false,
		report_schema = 1,
		deny_score_messages = false,

	--colors
		default_bg_color = 0.0941,
		default_bg_alpha = 0.5,

	--fades
		row_fade_in = {"in", 0.2},
		windows_fade_in = {"in", 0.2},
		row_fade_out = {"out", 0.2},
		windows_fade_out = {"out", 0.2},

	--captures
		capture_real = {
			["damage"] = true,
			["heal"] = true,
			["energy"] = true,
			["miscdata"] = true,
			["aura"] = true,
			["spellcast"] = true,
		},

	--bookmark
		bookmark_text_size = 11,

	--cloud capture
		cloud_capture = true,

	--combat
		minimum_combat_time = 5, --combats with less then this in elapsed time is discarted
		minimum_overall_combat_time = 10, --minimum time the combat must have to be added into the overall data
		overall_flag = 0x10,
		overall_clear_newboss = true,
		overall_clear_newchallenge = true,
		overall_clear_newtorghast = true,
		overall_clear_logout = false,
		overall_clear_pvp = true,
		data_cleanup_logout = false,
		close_shields = false,
		pvp_as_group = true,
		use_battleground_server_parser = false,
		force_activity_time_pvp = true,
		death_tooltip_width = 350,
		death_tooltip_spark = false,
		death_tooltip_texture = "Details Serenity",
		override_spellids = true,
		all_players_are_group = false,

	--skins
		standard_skin = false,
		skin = "Minimalistic",
		profile_save_pos = true,
		options_group_edit = true,

		chat_tab_embed = {
			enabled = false,
			tab_name = "",
			single_window = false,
			x_offset = 0,
			y_offset = 0,
		},

	--broadcaster options
		broadcaster_enabled = false,

	--event tracker
		event_tracker = {
			frame = {
				locked = false,
				width = 250,
				height = 300,
				backdrop_color = {0.1921, 0.1921, 0.1921, 0.3869},
				show_title = true,
				strata = "LOW",
			},
			options_frame = {},
			enabled = false,
			font_size = 10,
			font_color = {1, 1, 1, 1},
			font_shadow = "NONE",
			font_face = "Friz Quadrata TT",
			line_height = 16,
			line_texture = "Details Serenity",
			line_color = {.1, .1, .1, 0.3},
			show_crowdcontrol_pvp = true,
			show_crowdcontrol_pvm = false,
		},

	--current damage
		realtime_dps_meter = {
			frame_settings = {
				locked = true,
				width = 300,
				height = 23,
				backdrop_color = {0, 0, 0, 0.2},
				show_title = true,
				strata = "LOW",

				--libwindow
				point = "TOP",
				scale = 1,
				y = -110,
				x = 0,
			},
			options_frame = {},
			enabled = false,
			arena_enabled = true,
			mythic_dungeon_enabled = false,
			font_size = 18,
			font_color = {1, 1, 1, 1},
			font_shadow = "NONE",
			font_face = "Friz Quadrata TT",
			text_offset = 2,
			update_interval = 0.30,
			sample_size = 3, --in seconds
		},

	--streamer
--	Details.streamer_config.
		streamer_config = {
			reset_spec_cache = false,
			disable_mythic_dungeon = false,
			no_alerts = false,
			quick_detection = false,
			faster_updates = false,
			use_animation_accel = true,
			no_helptips = false,
		},

	--tooltip
		tooltip = {
			fontface = "Friz Quadrata TT",
			fontsize = 10,
			fontsize_title = 10,
			fontcolor = {1, 1, 1, 1},
			fontcolor_right = {1, 0.7, 0, 1}, --{1, 0.9254, 0.6078, 1}
			fontshadow = true,
			fontcontour = {0, 0, 0, 1},
			bar_color = {0.3960, 0.3960, 0.3960, 0.8700},
			background = {0.0941, 0.0941, 0.0941, 0.8},
			divisor_color = {1, 1, 1, 1},
			abbreviation = 2, -- 2 = ToK I Upper 5 = ToK I Lower -- was 8
			maximize_method = 1,
			show_amount = false,
			commands = {},
			header_text_color = {1, 0.9176, 0, 1}, --{1, 0.7, 0, 1}
			header_statusbar = {0.3, 0.3, 0.3, 0.8, false, false, "WorldState Score"},
			submenu_wallpaper = true,

			rounded_corner = true,

			anchored_to = 1,
			anchor_screen_pos = {507.700, -350.500},
			anchor_point = "bottom",
			anchor_relative = "top",
			anchor_offset = {0, 0},

			border_texture = "Details BarBorder 3",
			border_color = {0, 0, 0, 1},
			border_size = 14,

			tooltip_max_abilities = 6,
			tooltip_max_targets = 2,
			tooltip_max_pets = 2,

			--menus_bg_coords = {331/512, 63/512, 109/512, 143/512}, --with gradient on right side
			menus_bg_coords = {0.309777336120606, 0.924000015258789, 0.213000011444092, 0.279000015258789},
			menus_bg_color = {.8, .8, .8, 0.2},
			menus_bg_texture = [[Interface\SPELLBOOK\Spellbook-Page-1]],

			icon_border_texcoord = {L = 5/64, R = 59/64, T = 5/64, B = 59/64},
			icon_size = {W = 13, H = 13},

			--height used on tooltips at displays such as damage taken by spell
			line_height = 17,

			show_border_shadow = true, --from spell tooltips from the main window
		},

	--new window system
	all_in_one_windows = {},

	--auto show overall data in dynamic mode
	auto_swap_to_dynamic_overall = false,
}

Details.default_profile = default_profile

-- aqui fica as propriedades do jogador que n�o ser�o armazenadas no profile
local default_player_data = {
		coach = {
			enabled = false,
			welcome_panel_pos = {},
			last_coach_name = false,
		},

		player_stats = {},

		combat_log = {
			inverse_deathlog_raid = false,
			inverse_deathlog_mplus = false,
			inverse_deathlog_overalldata = false,
			track_hunter_frenzy = false,
			merge_gemstones_1007 = false,
			merge_critical_heals = false,
			calc_evoker_damage = true,
			evoker_show_realtimedps = false,
		},

		--this is used by the new data capture for charts
		data_harvest_for_charsts = {
			players = {
				--damage done by each player
				{
					name = "Damage of Each Individual Player",
					combatObjectContainer = 1,
					playerOnly = true,
					playerKey = "total",
				},
			},

			totals = {
				--total damage done by the raid group
				{
					name = "Damage of All Player Combined",
					combatObjectSubTableName = "totals",
					combatObjectSubTableKey = 1,
				},
			},
		},

		data_harvested_for_charts = {},


	--ocd tracker test
		ocd_tracker = {
			enabled = false,
			cooldowns = {},
			ignored_cooldowns = {},
			frames = {
				["defensive-raid"] = {},
				["defensive-target"] = {},
				["defensive-personal"] = {},
				["ofensive"] = {},
				["utility"] = {},
				["main"] = {}, --any cooldown that does not have a frame is shown on main frame
			}, --panels for each cooldown type

			show_conditions = {
				only_in_group = true,
				only_inside_instance = true,
			},
			show_options = false,
			current_cooldowns = {},
			framme_locked = false,
			filters = {
				["defensive-raid"] = false,
				["defensive-target"] = false,
				["defensive-personal"] = false,
				["ofensive"] = true,
				["utility"] = false,
				["itemheal"] = false,
				["itempower"] = false,
				["itemutil"] = false,
				["crowdcontrol"] = false,
			}, --when creating a filter, add it here and also add to 'own_frame'

			own_frame = {
				["defensive-raid"] = false,
				["defensive-target"] = false,
				["defensive-personal"] = false,
				["ofensive"] = false,
				["utility"] = false,
			},

			show_title = true,
			group_frames = true,

			width = 120,
			height = 18,
			lines_per_column = 12,
		},

	--mythic plus log
		mythic_plus_log = {},

	--force all fonts to have this outline
		force_font_outline = "",

	--current combat number
		cached_specs = {},
		cached_talents = {},
		cached_roles = {},

		last_day = date ("%d"),

		combat_id = 0,
		combat_counter = 0,
		last_instance_id = 0,
		last_instance_time = 0,
		mythic_dungeon_id = 0,
		mythic_dungeon_currentsaved = {
			started = false,
			run_id = 0,
			dungeon_name = "",
			dungeon_zone_id = 0,
			started_at = 0,
			segment_id = 0,
			level = 0,
			ej_id = 0,
			previous_boss_killed_at = 0,
		},
	--nicktag cache
		nick_tag_cache = {},
		ignore_nicktag = false,
	--plugin data
		plugin_database = {},
	--information about this character
		character_data = {logons = 0},
	--version
		last_realversion = Details.realversion,
		last_version = "v1.0.0",
	--profile
		active_profile = "",
	--plugins tables
		SoloTablesSaved = {},
		RaidTablesSaved = {},
	--saved skins
		savedStyles = {},
	--instance config
		local_instances_config = {},
	--announcements
		announce_deaths = {
			enabled = false,
			only_first = 5,
			last_hits = 1,
			where = 1,
		},
		announce_cooldowns = {
			enabled = false,
			channel = "RAID",
			ignored_cooldowns = {},
			custom = "",
		},
		announce_interrupts = {
			enabled = false,
			channel = "SAY",
			whisper = "",
			next = "",
			custom = "",
		},
		announce_prepots = {
			enabled = true,
			reverse = false,
			channel = "SELF",
		},
		announce_firsthit = {
			enabled = true,
			channel = "SELF",
		},
		announce_damagerecord = {
			enabled = true,
			channel = "SELF",
		},
	--benchmark
		benchmark_db = {
			frame = {},

		},
	--rank
		rank_window = {
			last_difficulty = 15,
			last_raid = "",
		},

	--death panel buttons
		on_death_menu = false,
}

Details.default_player_data = default_player_data

local default_global_data = {

	--profile pool
		__profiles = {},
		latest_news_saw = "",
		always_use_profile = false,
		always_use_profile_name = "",
		always_use_profile_exception = {},
		custom = {},
		savedStyles = {},
		savedCustomSpells = {},
		userCustomSpells = {}, --spells modified by the user
		savedTimeCaptures = {},
		lastUpdateWarning = 0,
		update_warning_timeout = 10,
		report_where = "SAY",
		realm_sync = true, --deprecated
		spell_school_cache = {},
		global_plugin_database = {},
		last_changelog_size = 0,
		auto_open_news_window = true,
		immersion_special_units = true, --show a special unit as member of your group
		immersion_unit_special_icons = true, --custom icons for specific units
		immersion_pets_on_solo_play = false, --pets showing when solo play
		damage_scroll_auto_open = true,
		damage_scroll_position = {
			scale = 1,
		},
        cleu_debug_panel = {
            position = {},
            scaletable = {scale = 1},
        },
		data_wipes_exp = {
			["9"] = false,
			["10"] = false,
			["11"] = false,
			["12"] = false,
			["13"] = false,
			["14"] = false,
		},
		current_exp_raid_encounters = {},
		encounter_journal_cache = {}, --store a dump of the encounter journal
		installed_skins_cache = {},

		auto_change_to_standard = true,

		debug_options_panel = {
			scaletable = {scale = 1},
			position = {},
		},

		boss_wipe_counter = {},
		boss_wipe_min_time = 20, --minimum time to consider a wipe as a boss wipe

		user_is_patreon_supporter = false,

		show_aug_predicted_spell_damage = false,

		show_warning_id1 = true,
		show_warning_id1_amount = 0,

		combat_id_global = 0,

		slash_me_used = false,
		trinket_data = {},

		merge_pet_abilities = false,
		merge_player_abilities = false,

		played_class_time = true,
		check_stuttering = false,

		--[bossname] = texture
		boss_icon_cache = {},

	--spell category feedback
		spell_category_savedtable = {},
		spell_category_latest_query = 0,
		spell_category_latest_save = 0,
		spell_category_latest_sent = 0,

	--class time played
		class_time_played = {},

	--keystone cache
		keystone_cache = {},

	--all switch settings (panel shown when right click the title bar)
		all_switch_config = {
			scale = 1,
			font_size = 10,
		},

	--keystone window
		keystone_frame = {
			scale = 1,
			position = {},
		},

	--ask to erase data frame
		ask_to_erase_frame = {
			scale = 1,
			position = {},
		},

	--aura tracker panel
		aura_tracker_frame = {
			position = {}, --for libwindow
			scaletable = {
				scale = 1
			},
		},

	breakdown_general = {
		font_size = 11,
		font_color = {0.9, 0.9, 0.9, 0.923},
		font_outline = "NONE",
		font_face = "DEFAULT",
		bar_texture = "You Are the Best!",
	},

	frame_background_color = {0.0549, 0.0549, 0.0549, 0.934},

--/run Details.breakdown_spell_tab.spellcontainer_height = 311 --352
	--breakdown spell tab
	breakdown_spell_tab = {
		--player spells
		nest_players_spells_with_same_name = true,
		--pet spells
		nest_pet_spells_by_name = false,
		nest_pet_spells_by_caster = true,

		blockcontainer_width = 430,
		blockcontainer_height = 270,
		blockcontainer_islocked = true,

		statusbar_background_color = {.15, .15, .15},
		statusbar_background_alpha = 0.7,
		statusbar_texture = [[Interface\AddOns\Details\images\bar_skyline]],
		statusbar_alpha = 0.70,

		blockspell_height = 67,
		blockspell_padding = 5,
		blockspell_color = {0, 0, 0, 0.7},
		blockspell_bordercolor = {0, 0, 0, 0.7},
		blockspell_backgroundcolor = {0.1, 0.1, 0.1, 0.4},
		blockspell_spark_offset = -1,
		blockspell_spark_width = 4,
		blockspell_spark_show = true,
		blockspell_spark_color = {1, 1, 1, 0.7},

		spellcontainer_width = 429,
		spellcontainer_height = 311,
		spellcontainer_islocked = true,

		targetcontainer_width = 429,
		targetcontainer_height = 140,
		targetcontainer_islocked = true,

		phasecontainer_enabled = true,
		phasecontainer_width = 290,
		phasecontainer_height = 140,
		phasecontainer_islocked = true,

		genericcontainer_enabled = true,
		genericcontainer_width = 429,
		genericcontainer_height = 311 + 140 + 30,
		genericcontainer_islocked = true,

		genericcontainer_right_width = 403,
		genericcontainer_right_height = 460,

		spellbar_background_alpha = 0.92,

		spellcontainer_headers = {}, --store information about active headers and their sizes (spells)
		targetcontainer_headers = {}, --store information about active headers and their sizes (target)
		phasecontainer_headers = {}, --store information about active headers and their sizes (phases)
		genericcontainer_headers = {}, --store information about active headers and their sizes (generic left)
		genericcontainer_headers_right = {}, --store information about active headers and their sizes (generic right)

		spellcontainer_header_height = 20,
		spellcontainer_header_fontsize = 10,
		spellcontainer_header_fontcolor = {1, 1, 1, 1},
	},

	--profile by spec
		profile_by_spec = {},

	--displays by spec
		displays_by_spec = {},

	--death log
		show_totalhitdamage_on_overkill = false,

	--switch tables
		switchSaved = {slots = 4, table = {
			{["atributo"] = 1, ["sub_atributo"] = 1}, --damage done
			{["atributo"] = 2, ["sub_atributo"] = 1}, --healing done
			{["atributo"] = 1, ["sub_atributo"] = 6}, --enemies
			{["atributo"] = 4, ["sub_atributo"] = 5}, --deaths
		}},
		report_pos = {1, 1},

	--tutorial
		tutorial = {
			logons = 0,
			unlock_button = 0,
			version_announce = 0,
			main_help_button = 0,
			alert_frames = {false, false, false, false, false, false},
			bookmark_tutorial = false,
			ctrl_click_close_tutorial = false,
		},

		performance_profiles = { --deprecated
			["RaidFinder"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Raid15"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Raid30"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Mythic"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Battleground15"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Battleground40"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Arena"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
			["Dungeon"] = {enabled = false, update_speed = 1, use_row_animations = false, damage = true, heal = true, aura = true, energy = false, miscdata = true},
		},

	--auras (wa auras created from the aura panel)
		details_auras = {}, --deprecated due to major security wa code revamp

	--ilvl
		item_level_pool = {},

	--latest report
		latest_report_table = {},

	--death recap
		death_recap = {
			enabled = true,
			relevance_time = 7,
			show_life_percent = false,
			show_segments = false,
		},

	--spell caches
		boss_mods_timers = {
			encounter_timers_dbm = {},
			encounter_timers_bw = {},
			latest_boss_mods_access = time(),
		},

		spell_pool = {},
		latest_spell_pool_access = time(),

		npcid_pool = {},
		latest_npcid_pool_access = time(),

		encounter_spell_pool = {},
		latest_encounter_spell_pool_access = time(),

		--store spells that passed by the healing absorb event on the parser, this list will help counting the overhealing of shields
		shield_spellid_cache = {},
		latest_shield_spellid_cache_access = time(),

	--parser options
		parser_options = {
			--compute the overheal of shields
			shield_overheal = false,
			--compute the energy wasted by players when they current energy is equal to the maximum energy
			energy_overflow = false,
		},

	--aura creation frame libwindow
		createauraframe = {}, --deprecated

	--min health done on the death report
		deathlog_healingdone_min = 1,
		deathlog_healingdone_min_arena = 400,
		deathlog_line_height = 16,

	--mythic plus config
		mythic_plus = {
			merge_boss_trash = true,
			boss_dedicated_segment = true,
			make_overall_when_done = true,
			make_overall_boss_only = false,
			show_damage_graphic = true,

			reverse_death_log = false,

			delay_to_show_graphic = 1,
			last_mythicrun_chart = {},
			mythicrun_chart_frame = {},
			mythicrun_chart_frame_minimized = {},
			finished_run_panel3 = {}, --save window position
			finished_run_frame_options = {
				orientation = "horizontal",
				grow_direction = "left",
			},

			autoclose_time = 90,

			mythicrun_time_type = 1, --1: combat time (the amount of time the player is in combat) 2: run time (the amount of time it took to finish the mythic+ run)
		}, --implementar esse time_type quando estiver dando refresh na janela

	--plugin window positions
		plugin_window_pos = {},

	--run code
		run_code = {
			["on_specchanged"] = "\n-- run when the player changes its spec",
			["on_zonechanged"] = "\n-- when the player changes zone, this code will run",
			["on_init"] = "\n-- code to run when Details! initializes, put here code which only will run once\n-- this also will run then the profile is changed\n\n--size of the death log tooltip in the Deaths display (default 350)\nDetails.death_tooltip_width = 350;\n\n--when in arena or battleground, details! silently switch to activity time (goes back to the old setting on leaving, default true)\nDetails.force_activity_time_pvp = true;\n\n--speed of the bar animations (default 33)\nDetails.animation_speed = 33;\n\n--threshold to trigger slow or fast speed (default 0.45)\nDetails.animation_speed_mintravel = 0.45;\n\n--call to update animations\nDetails:RefreshAnimationFunctions();\n\n--max window size, does require a /reload to work (default 480 x 450)\nDetails.max_window_size.width = 480;\nDetails.max_window_size.height = 450;\n\n--use the arena team color as the class color (default true)\nDetails.color_by_arena_team = true;\n\n--how much time the update warning is shown (default 10)\nDetails.update_warning_timeout = 10;",
			["on_leavecombat"] = "\n-- this code runs when the player leave combat",
			["on_entercombat"] = "\n-- this code runs when the player enters in combat",
			["on_groupchange"] = "\n-- this code runs when the player enter or leave a group",
		},

	--plater integration
		plater = {
			realtime_dps_enabled = false,
			realtime_dps_size = 12,
			realtime_dps_color = {1, 1, 0, 1},
			realtime_dps_shadow = true,
			realtime_dps_anchor = {side = 7, x = 0, y = 0},
			--
			realtime_dps_player_enabled = false,
			realtime_dps_player_size = 12,
			realtime_dps_player_color = {1, 1, 0, 1},
			realtime_dps_player_shadow = true,
			realtime_dps_player_anchor = {side = 7, x = 0, y = 0},
			--
			damage_taken_enabled = false,
			damage_taken_size = 12,
			damage_taken_color = {1, 1, 0, 1},
			damage_taken_shadow = true,
			damage_taken_anchor = {side = 7, x = 0, y = 0},

		},

	--dungeon information - can be accessed by plugins and third party mods
		dungeon_data = {},

	--raid information - can be accessed by plugins and third party mods
		raid_data = {},

	--store all npcids blacklisted by the user
		npcid_ignored = {},
	--store all spellids blacklisted by the user
		spellid_ignored = {},

	--9.0 exp (store data only used for the 9.0 expansion)
		exp90temp = {
			delete_damage_TCOB = true, --delete damage on the concil of blood encounter
		},

	third_party = {
		openraid_notecache = {},
	},
}

Details.default_global_data = default_global_data

function Details:GetTutorialCVar(key, default)
	--is disabling all popups from the streamer options
	if (Details.streamer_config.no_alerts) then
		return true
	end

	local value = Details.tutorial [key]
	if (value == nil and default) then
		Details.tutorial [key] = default
		value = default
	end
	return value
end
function Details:SetTutorialCVar (key, value)
	Details.tutorial [key] = value
end

function Details:SaveProfileSpecial()

	--get the current profile
		local profile_name = Details:GetCurrentProfileName()
		local profile = Details:GetProfile (profile_name, true)

	--save default keys
		for key, _ in pairs(Details.default_profile) do

			local current_value = _detalhes_database [key] or _detalhes_global [key] or Details.default_player_data [key] or Details.default_global_data [key]

			if (type(current_value) == "table") then
				local ctable = Details.CopyTable(current_value)
				profile [key] = ctable
			else
				profile [key] = current_value
			end

		end

	--save skins
		Details:Destroy(profile.instances)

		if (Details.tabela_instancias) then
			for index, instance in ipairs(Details.tabela_instancias) do
				local exported = instance:ExportSkin()
				profile.instances [index] = exported
			end
		end

	--end
		return profile
end

--save things for the mythic dungeon run
function Details:SaveState_CurrentMythicDungeonRun(runID, zoneName, zoneID, startAt, segmentID, level, ejID, latestBossAt)
	local zoneName, _, _, _, _, _, _, currentZoneID = GetInstanceInfo()

	local savedTable = Details.mythic_dungeon_currentsaved
	savedTable.started = true
	savedTable.run_id = runID
	savedTable.dungeon_name = zoneName
	savedTable.dungeon_zone_id = currentZoneID
	savedTable.started_at = startAt
	savedTable.segment_id = segmentID
	savedTable.level = level
	savedTable.ej_id = ejID
	savedTable.previous_boss_killed_at = latestBossAt

	local playersOnTheRun = {}
	for i = 1, GetNumGroupMembers() do
		local unitGUID = UnitGUID("party" .. i)
		if (unitGUID) then
			playersOnTheRun[#playersOnTheRun+1] = unitGUID
		end
	end

	savedTable.players = playersOnTheRun
end

function Details:UpdateState_CurrentMythicDungeonRun(stillOngoing, segmentID, latestBossAt)
	local savedTable = Details.mythic_dungeon_currentsaved

	if (not stillOngoing) then
		savedTable.started = false
	end

	if (segmentID) then
		savedTable.segment_id = segmentID
	end

	if (latestBossAt) then
		savedTable.previous_boss_killed_at = latestBossAt
	end
end

function Details:RestoreState_CurrentMythicDungeonRun()
	--no need to check for mythic+ if the user is playing on classic wow
	if (DetailsFramework.IsTimewalkWoW()) then
		return
	end

	local savedTable = Details.mythic_dungeon_currentsaved
	local mythicLevel = C_ChallengeMode.GetActiveKeystoneInfo()
	local zoneName, _, _, _, _, _, _, currentZoneID = GetInstanceInfo()
	local mapID =  C_Map.GetBestMapForUnit("player")

	if (not mapID) then
		--print("D! no mapID to restored mythic dungeon state.")
		return
	end

	local ejID = 0

	if (mapID) then
		ejID = DetailsFramework.EncounterJournal.EJ_GetInstanceForMap(mapID) or 0
	end

	--is there a saved state for the dungeon?
	if (savedTable.started) then
		--player are within the same zone?
		if (zoneName == savedTable.dungeon_name and currentZoneID == savedTable.dungeon_zone_id) then
			--is there a mythic run ongoing and the level is the same as the saved state?
			if (mythicLevel and mythicLevel == savedTable.level) then
				--restore the state
				Details.MythicPlus.Started = true
				Details.MythicPlus.DungeonName = zoneName
				Details.MythicPlus.DungeonID = currentZoneID
				Details.MythicPlus.StartedAt = savedTable.started_at
				Details.MythicPlus.SegmentID = savedTable.segment_id
				Details.MythicPlus.Level = mythicLevel
				Details.MythicPlus.ejID = ejID
				Details.MythicPlus.PreviousBossKilledAt = savedTable.previous_boss_killed_at
				Details.MythicPlus.IsRestoredState = true
				DetailsMythicPlusFrame.IsDoingMythicDungeon = true

				Details:Msg("D! (debug) mythic dungeon state restored.")

				C_Timer.After(2, function()
					Details:SendEvent("COMBAT_MYTHICDUNGEON_START")
				end)
				return
			else
				print("D! (debug) mythic level isn't equal.", mythicLevel, savedTable.level)
			end
		else
			print("D! (debug) zone name or zone Id isn't the same:", zoneName, savedTable.dungeon_name, currentZoneID, savedTable.dungeon_zone_id)
		end

		--mythic run is over
		savedTable.started = false
	else
		--print("D! savedTable.stated isn't true.")
	end
end


--------------------------------------------------------------------------------------------------------------------------------------------
--~export ~ import ~profile

local exportProfileBlacklist = {
	custom = true,
	cached_specs = true,
	cached_talents = true,
	combat_id = true,
	combat_counter = true,
	mythic_dungeon_currentsaved = true,
	nick_tag_cache = true,
	plugin_database = true,
	character_data = true,
	active_profile = true,
	SoloTablesSaved = true,
	RaidTablesSaved = true,
	benchmark_db = true,
	rank_window = true,
	last_realversion = true,
	last_version = true,
	__profiles = true,
	latest_news_saw = true,
	always_use_profile = true,
	always_use_profile_name = true,
	always_use_profile_exception = true,
	savedStyles = true,
	savedTimeCaptures = true,
	lastUpdateWarning = true,
	spell_school_cache = true,
	global_plugin_database = true,
	details_auras = true,
	item_level_pool = true,
	latest_report_table = true,
	boss_mods_timers = true,
	spell_pool = true,
	encounter_spell_pool = true,
	npcid_pool = true,
	createauraframe = true,
	mythic_plus = true,
	plugin_window_pos = true,
	switchSaved = true,
	installed_skins_cache = true,
	trinket_data = true,
	keystone_cache = true,
	performance_profiles = true,
}

--transform the current profile into a string which can be shared in the internet
function Details:ExportCurrentProfile()
	--save the current profile
	Details:SaveProfile()

	--data saved inside the profile
	local profileObject = Details:GetProfile (Details:GetCurrentProfileName())
	if (not profileObject) then
		Details:Msg("fail to get the current profile.")
		return false
	end

	--data saved individual for each character
	local defaultPlayerData = Details.default_player_data
	local playerData = {}
	--data saved for the account
	local defaultGlobalData = Details.default_global_data
	local globaData = {} --typo: 'globalData' was intended, cannot be fixed due to export strings compatibility

	--fill player and global data tables
	for key, _ in pairs(defaultPlayerData) do
		if (not exportProfileBlacklist[key]) then
			if (type(Details[key]) == "table") then
				playerData [key] = DetailsFramework.table.copy({}, Details[key])
			else
				playerData [key] = Details[key]
			end
		end
	end
	for key, _ in pairs(defaultGlobalData) do
		if (not exportProfileBlacklist[key]) then
			if (type(Details[key]) == "table") then
				globaData [key] = DetailsFramework.table.copy({}, Details[key])
			else
				globaData [key] = Details[key]
			end
		end
	end

	local exportedData = {
		profile = profileObject,
		playerData = playerData,
		globaData = globaData,
		version = 1,
	}

	local compressedData = Details:CompressData (exportedData, "print")
	return compressedData
end

---bIsFromImportPrompt is true when the import call is from the import window
---@param profileString string
---@param newProfileName string
---@param bImportAutoRunCode boolean
---@param bIsFromImportPrompt boolean
---@param overwriteExisting boolean
---@return boolean
function Details:ImportProfile (profileString, newProfileName, bImportAutoRunCode, bIsFromImportPrompt, overwriteExisting)
	if (not newProfileName or type(newProfileName) ~= "string" or string.len(newProfileName) < 2) then
		Details:Msg("invalid profile name or profile name is too short.") --localize-me
		return false
	end

	profileString = DetailsFramework:Trim (profileString)
	local currentDataVersion = 1

	local dataTable = Details:DecompressData (profileString, "print")
	if (dataTable) then

		local profileObject = Details:GetProfile (newProfileName, false)
		local nameWasDuplicate = false
    if not overwriteExisting then
      while(profileObject) do
        newProfileName = newProfileName .. '2';
        profileObject = Details:GetProfile(newProfileName, false)
        nameWasDuplicate = true
      end
    end
		if (not profileObject) then
			--profile doesn't exists, create new
			profileObject = Details:CreateProfile (newProfileName)
			if (not profileObject) then
				Details:Msg("failed to create a new profile.")--localize-me
				return
			end
		end

		local profileData, playerData, globalData, version = dataTable.profile, dataTable.playerData, dataTable.globaData, dataTable.version

		if (version < currentDataVersion) then
			--perform update in the sereived settings
		end

		--character data defaults
		local defaultPlayerData = Details.default_player_data
		--global data defaults
		local defaultGlobalData = Details.default_global_data
		--profile defaults
		local defaultProfileData = Details.default_profile

		if (not bImportAutoRunCode or not bIsFromImportPrompt) then
			globalData.run_code = nil
		end

		--transfer player and global data tables from the profile to details object
		for key, _ in pairs(defaultPlayerData) do
			local importedValue = playerData[key]
			if (importedValue ~= nil) then
				if (type(importedValue) == "table") then
					Details [key] = DetailsFramework.table.copy({}, importedValue)
				else
					Details [key] = importedValue
				end
			end
		end

		for key, _ in pairs(defaultGlobalData) do
			local importedValue = globalData[key]
			if (importedValue ~= nil) then
				if (type(importedValue) == "table") then
					Details [key] = DetailsFramework.table.copy({}, importedValue)
				else
					Details [key] = importedValue
				end
			end
		end

		--transfer data from the imported profile to the new profile object
		for key, _ in pairs(defaultProfileData) do
			local importedValue = profileData[key]
			if (importedValue ~= nil) then
				if (type(importedValue) == "table") then
					profileObject [key] = DetailsFramework.table.copy({}, importedValue)
				else
					profileObject [key] = importedValue
				end
			end
		end

		--profile imported, set mythic dungeon to default settings
		local mythicPlusSettings = Details.mythic_plus
		mythicPlusSettings.merge_boss_trash = true
		mythicPlusSettings.boss_dedicated_segment = true
		mythicPlusSettings.make_overall_when_done = true
		mythicPlusSettings.make_overall_boss_only = false
		mythicPlusSettings.show_damage_graphic = true
		mythicPlusSettings.reverse_death_log = false
		mythicPlusSettings.delay_to_show_graphic = 1
		mythicPlusSettings.last_mythicrun_chart = {}
		mythicPlusSettings.mythicrun_chart_frame = {}
		mythicPlusSettings.mythicrun_chart_frame_minimized = {}
		mythicPlusSettings.finished_run_panel3 = {}

		--max segments allowed
		Details.segments_amount = 25
		--max segments to save between sections
		Details.segments_amount_to_save = 15
		--max amount of boss wipes allowed
		Details.segments_amount_boss_wipes = 10
		--should boss wipes delete segments with less progression?
		Details.segments_boss_wipes_keep_best_performance = true

		--transfer instance data to the new created profile
		profileObject.instances = DetailsFramework.table.copy({}, profileData.instances)

		Details:ApplyProfile (newProfileName)

		--reset automation settings (due to user not knowing why some windows are disappearing)
		for instanceId, instance in Details:ListInstances() do
			DetailsFramework.table.copy(instance.hide_on_context, Details.instance_defaults.hide_on_context)
		end

		if(nameWasDuplicate) then
			Details:Msg("profile name already exists and was imported as:", newProfileName)--localize-me
		else
			Details:Msg("profile successfully imported.")--localize-me
		end
		return true
	else
		Details:Msg("failed to decompress profile data.")--localize-me
		return false
	end
end

--create a import profile confirmation dialog with a text box to enter the profile name and a checkbox to select if should import auto run scripts
function Details.ShowImportProfileConfirmation(message, callback)
	if (not Details.profileConfirmationDialog) then
		local promptFrame = CreateFrame("frame", "DetailsImportProfileDialog", UIParent, "BackdropTemplate")
		promptFrame:SetSize(400, 170)
		promptFrame:SetFrameStrata("FULLSCREEN")
		promptFrame:SetPoint("center", UIParent, "center", 0, 100)
		promptFrame:EnableMouse(true)
		promptFrame:SetMovable(true)
		promptFrame:RegisterForDrag ("LeftButton")
		promptFrame:SetScript("OnDragStart", function() promptFrame:StartMoving() end)
		promptFrame:SetScript("OnDragStop", function() promptFrame:StopMovingOrSizing() end)
		promptFrame:SetScript("OnMouseDown", function(self, button) if (button == "RightButton") then promptFrame.EntryBox:ClearFocus() promptFrame:Hide() end end)
		table.insert(UISpecialFrames, "DetailsImportProfileDialog")

		detailsFramework:CreateTitleBar(promptFrame, "Import Profile Confirmation")
		detailsFramework:ApplyStandardBackdrop(promptFrame)

		local prompt = promptFrame:CreateFontString(nil, "overlay", "GameFontNormal")
		prompt:SetPoint("top", promptFrame, "top", 0, -25)
		prompt:SetJustifyH("center")
		prompt:SetSize(360, 36)
		promptFrame.prompt = prompt

		local button_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
		local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")

		local textbox = detailsFramework:CreateTextEntry(promptFrame, function()end, 380, 20, "textbox", nil, nil, options_dropdown_template)
		textbox:SetPoint("topleft", promptFrame, "topleft", 10, -60)
		promptFrame.EntryBox = textbox

		--create a detailsframework checkbox to select if want to import the auto run scripts
		local checkbox = detailsFramework:CreateSwitch(promptFrame, function()end, false, _, _, _, _, _, _, _, _, _, _, DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
		checkbox:SetPoint("topleft", promptFrame, "topleft", 10, -90)
		checkbox:SetAsCheckBox()
		promptFrame.checkbox = checkbox

		--create the checkbox label with the text: "Import Auto Run Scripts"
		local checkboxLabel = promptFrame:CreateFontString(nil, "overlay", "GameFontNormal")
		checkboxLabel:SetPoint("left", checkbox.widget, "right", 2, 0)
		checkboxLabel:SetText("Import Auto Run Scripts")
		checkboxLabel:SetJustifyH("left")
		promptFrame.checkboxLabel = checkboxLabel

		local buttonTrue = detailsFramework:CreateButton(promptFrame, nil, 60, 20, "Okay", nil, nil, nil, nil, nil, nil, options_dropdown_template)
		buttonTrue:SetPoint("bottomright", promptFrame, "bottomright", -10, 5)
		promptFrame.button_true = buttonTrue

		local buttonFalse = detailsFramework:CreateButton(promptFrame, function() promptFrame.textbox:ClearFocus() promptFrame:Hide() end, 60, 20, "Cancel", nil, nil, nil, nil, nil, nil, options_dropdown_template)
		buttonFalse:SetPoint("bottomleft", promptFrame, "bottomleft", 10, 5)
		promptFrame.button_false = buttonFalse

		local executeCallback = function()
			local bCanImportAutoRunCode = promptFrame.checkbox:GetValue()
			local myFunc = buttonTrue.true_function
			if (myFunc) then
				local okey, errormessage = pcall(myFunc, textbox:GetText(), bCanImportAutoRunCode)
				textbox:ClearFocus()
				if (not okey) then
					print("error:", errormessage)
				end
				promptFrame:Hide()
			end
		end

		buttonTrue:SetClickFunction(function()
			executeCallback()
		end)

		textbox:SetHook("OnEnterPressed", function()
			executeCallback()
		end)

		promptFrame:Hide()
		Details.profileConfirmationDialog = promptFrame
	end

	Details.profileConfirmationDialog:Show()
	Details.profileConfirmationDialog.EntryBox:SetText("")
	Details.profileConfirmationDialog.EntryBox:SetFocus(false)

	Details.profileConfirmationDialog.prompt:SetText(message)
	Details.profileConfirmationDialog.button_true.true_function = callback
	Details.profileConfirmationDialog.textbox:SetFocus(true)
end
