
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
--lua locals
local rawset = rawset
local rawget = rawget
local setmetatable = setmetatable
local unpack = unpack ---@diagnostic disable-line
local type = type
local floor = math.floor
local loadstring = loadstring ---@diagnostic disable-line
local CreateFrame = CreateFrame ---@diagnostic disable-line
local UnitIsUnit = UnitIsUnit ---@diagnostic disable-line
local UnitClass = UnitClass ---@diagnostic disable-line
local GetInstanceInfo = GetInstanceInfo ---@diagnostic disable-line
local C_ChallengeMode = C_ChallengeMode ---@diagnostic disable-line
local C_Map = C_Map ---@diagnostic disable-line
local GetTalentInfoByID = GetTalentInfoByID ---@diagnostic disable-line

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE ---@diagnostic disable-line
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE ---@diagnostic disable-line
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC ---@diagnostic disable-line

local PixelUtil = PixelUtil or DFPixelUtil  ---@diagnostic disable-line
local UnitGroupRolesAssigned = detailsFramework.UnitGroupRolesAssigned
local loadConditionsFrame

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--load conditions panel

--this is the table prototype to hold load conditions settings
local default_load_conditions = {
	class = {},
	spec = {},
	race = {},
	talent = {},
	pvptalent = {},
	group = {},
	role = {},
	affix = {},
	encounter_ids = {},
	map_ids = {},
}

--[=[
Skittish 135994 2
Volcanic 451169 3
Necrotic 1029009 4
Teeming 136054 5
Raging 132345 6
Bolstering 132333 7
Sanguine 136124 8
Tyrannical 236401 9
Fortified 463829 10
Bursting 1035055 11
Grievous 132090 12
Explosive 2175503 13
Quaking 136025 14
Infested 2032223 16
Reaping 2446016 117
Beguiling 237565 119
Awakened 442737 120
Prideful 3528307 121
Inspiring 135946 122
Spiteful 135945 123
Storming 136018 124
Tormented 3528304 128
Infernal 1394959 129
Encrypted 4038106 130
Shrouded 136177 131
Thundering 1385910 132
[PH] 0 133
Entangling 134412 134
Afflicted 237555 135
Incorporeal 298642 136
Shielding 535593 137
--]=]

local deprecatedAffixes = {
	[2] = true, --Skittish
	[5] = true, --Teeming
	[16] = true, --Infested
	[117] = true, --Reaping
	[119] = true, --Beguiling
	[13] = true, --Explosive
	[14] = true, --Quaking
	[120] = true, --Awakened
	[121] = true, --Prideful
	[130] = true, --Encrypted
}

local default_load_conditions_frame_options = {
	title = "Details! Framework: Load Conditions",
	name = "Object",
}

function detailsFramework:CreateLoadFilterParser(callback)
	local filterFrame = CreateFrame("frame")

	if IS_WOW_PROJECT_MAINLINE then
		filterFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		filterFrame:RegisterEvent("TRAIT_CONFIG_LIST_UPDATED")
		filterFrame:RegisterEvent("CHALLENGE_MODE_START")
	else
		filterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		filterFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	end

	filterFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	filterFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	filterFrame:RegisterEvent("ENCOUNTER_START")
	filterFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	filterFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

	filterFrame:RegisterEvent("CHAT_MSG_LOOT")

	filterFrame:SetScript("OnEvent", function(self, event, ...)
		if (event == "ENCOUNTER_START") then --triggers before regen_disabled
			local encounterID = ...
			filterFrame.EncounterIDCached = encounterID

		elseif (event == "CHAT_MSG_LOOT") then
			local message = ...
			local itemId = message:match("|Hitem:(%d+):")
			itemId = tonumber(itemId)

			if (itemId == 191140) then
				xpcall(callback, geterrorhandler(), "RACE_START")
				--monitor the player backpack each second to know when the item is removed from the bag

				C_Timer.After(5, function()
					filterFrame.FindBackpackItem = C_Timer.NewTicker(1, function()
						local bFoundItem = false
						for bagId = 0, 4 do
							for slotId = 1, 32 do
								local bagItemID = C_Container.GetContainerItemID(bagId, slotId)
								if (bagItemID) then
									if (bagItemID == itemId) then
										--bronze timepiece is on the player backpack
										return
									end
								end
							end
						end

						if (not bFoundItem) then
							filterFrame.FindBackpackItem:Cancel()
							xpcall(callback, geterrorhandler(), "RACE_STOP")
							return
						end
					end)
				end)
			end
			return

		elseif (event == "PLAYER_REGEN_DISABLED") then

		elseif (event == "ENCOUNTER_END") then
			filterFrame.EncounterIDCached = nil

		elseif (event == "PLAYER_REGEN_ENABLED") then
			--f.EncounterIDCached = nil
			--when the player dies during an encounter, the game is triggering regen enabled

		elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then
			if (loadConditionsFrame and loadConditionsFrame:IsShown()) then
				loadConditionsFrame:Refresh()
			end

			local unit = ...
			if (not unit or not UnitIsUnit("player", unit)) then
				return
			end

		elseif (event == "PLAYER_ROLES_ASSIGNED") then
			local assignedRole = UnitGroupRolesAssigned("player")
			if (assignedRole == "NONE") then
				local spec = DetailsFramework.GetSpecialization()
				if (spec) then
					assignedRole = DetailsFramework.GetSpecializationRole(spec)
				end
			end

			if (detailsFramework.CurrentPlayerRole == assignedRole) then
				return
			end

			detailsFramework.CurrentPlayerRole = assignedRole
		end

		--problem: this xpcall won't tell where the error happened in the callback code
		xpcall(callback, geterrorhandler(), filterFrame.EncounterIDCached)
	end)
end

function detailsFramework:PassLoadFilters(loadTable, encounterID)
	--class
	local passLoadClass
	if (loadTable.class.Enabled) then
		local _, classFileName = UnitClass("player")
		if (not loadTable.class[classFileName]) then
			return false, _G["CLASS"]
		else
			passLoadClass = true
		end
	end

	--spec
	if (IS_WOW_PROJECT_MAINLINE and loadTable.spec.Enabled) then
		local canCheckTalents = true

		if (passLoadClass) then
			--if is allowed to load on this class, check if the talents isn't from another class
			local _, classFileName = UnitClass("player")
			local specsForThisClass = detailsFramework:GetClassSpecIDs(classFileName)

			canCheckTalents = false

			for _, specID in ipairs(specsForThisClass) do
				if (loadTable.spec[specID] or loadTable.spec[specID..""]) then
					--theres a talent for this class
					canCheckTalents = true
					break
				end
			end
		end

		if (canCheckTalents) then
			local specIndex = DetailsFramework.GetSpecialization()
			if (specIndex) then
				local specID = DetailsFramework.GetSpecializationInfo(specIndex)
				if not specID or(not loadTable.spec[specID] and not loadTable.spec[specID .. ""]) then
					return false, _G["SPECIALIZATION"]
				end
			else
				return false, _G["SPECIALIZATION"]
			end
		end
	end

	--race
	if (loadTable.race.Enabled) then
		local raceName, raceFileName, raceID = UnitRace("player")
		if (not loadTable.race [raceFileName]) then
			return false, _G["RACE"]
		end
	end

	--talents
	if (IS_WOW_PROJECT_MAINLINE and loadTable.talent.Enabled) then
		local bOnlySelected, bUseHashTable = true, true
		local talentsInUse = detailsFramework:GetCharacterTalents(bOnlySelected, bUseHashTable)

		local hasTalent

		for talentId in pairs(talentsInUse) do
			if talentId and(loadTable.talent[talentId] or loadTable.talent[talentId .. ""]) then
				hasTalent =  true
				break
			end
		end

		if (not hasTalent) then
			return false, _G["TALENTS"]
		end
	end

	--pvptalent
	if (IS_WOW_PROJECT_MAINLINE and loadTable.pvptalent.Enabled) then
		local talentsInUse = detailsFramework:GetCharacterPvPTalents(false, true)
		local hasTalent
		for talentID, _ in pairs(talentsInUse) do
			if talentID and(loadTable.pvptalent [talentID] or loadTable.pvptalent [talentID .. ""]) then
				hasTalent =  true
				break
			end
		end
		if (not hasTalent) then
			return false, (_G["PVP"] or "") .. " " .. (_G["TALENTS"] or "")
		end
	end

	--group
	if (loadTable.group.Enabled) then
		local _, zoneType = GetInstanceInfo()
		if (not loadTable.group[zoneType]) then
			return false, _G["GROUP"]
		end
	end

	--role
	if (loadTable.role.Enabled) then
		local assignedRole = UnitGroupRolesAssigned("player")
		if (assignedRole == "NONE") then
			local spec = DetailsFramework.GetSpecialization()
			if (spec) then
				assignedRole = DetailsFramework.GetSpecializationRole(spec)
			end
		end
		if (not loadTable.role [assignedRole]) then
			return false, _G["ROLE"]
		end
	end

	--affix
	if (IS_WOW_PROJECT_MAINLINE and loadTable.affix.Enabled) then
		local isInMythicDungeon = C_ChallengeMode.IsChallengeModeActive()
		if (not isInMythicDungeon) then
			return false, "M+ Affix"
		end

		local level, affixes, wasEnergized = C_ChallengeMode.GetActiveKeystoneInfo()
		local hasAffix = false
		for _, affixID in ipairs(affixes) do
			if affixID and(loadTable.affix[affixID] or loadTable.affix[affixID .. ""]) then
				hasAffix = true
				break
			end
		end

		if (not hasAffix) then
			return false, "M+ Affix"
		end
	end

	--encounter id
	if (loadTable.encounter_ids.Enabled) then
		if (not encounterID) then
			return
		end

		local bHasEncounter
		for _, userEnteredEncounterId in pairs(loadTable.encounter_ids) do
			if (userEnteredEncounterId == encounterID) then
				bHasEncounter = true
				break
			end
		end

		if (not bHasEncounter) then
			return false, _G["GUILD_NEWS_FILTER3"] --"raid encounters"
		end
	end

	--map id
	if (loadTable.map_ids.Enabled) then
		local _, _, _, _, _, _, _, zoneMapID = GetInstanceInfo()
		local uiMapID = C_Map.GetBestMapForUnit("player")
		local bHasMapID = false

		for _, userEnteredMapId in pairs(loadTable.map_ids) do
			if (userEnteredMapId == zoneMapID or userEnteredMapId == uiMapID) then
				bHasMapID = true
				break
			end
		end

		if (not bHasMapID) then
			return false, _G["BATTLEFIELD_MINIMAP"] --"zone map"
		end
	end

	return true
end

--this func will deploy the default values from the prototype into the config table
function detailsFramework:UpdateLoadConditionsTable(configTable)
	configTable = configTable or {}
	detailsFramework.table.deploy(configTable, default_load_conditions)
	return configTable
end

--/run Plater.OpenOptionsPanel()PlaterOptionsPanelContainer:SelectIndex(Plater, 14)

function detailsFramework:OpenLoadConditionsPanel(optionsTable, callback, frameOptions)
	frameOptions = frameOptions or {}
	detailsFramework.table.deploy(frameOptions, default_load_conditions_frame_options)

	detailsFramework:UpdateLoadConditionsTable(optionsTable)

	if (not loadConditionsFrame) then
		loadConditionsFrame = detailsFramework:CreateSimplePanel(UIParent, 1024, 600, "Load Conditions", "loadConditionsFrame")
		loadConditionsFrame:SetBackdropColor(0, 0, 0, 1)
		loadConditionsFrame.AllRadioGroups = {}
		loadConditionsFrame.AllTextEntries = {}
		loadConditionsFrame.OptionsTable = optionsTable

		detailsFramework:ApplyStandardBackdrop(loadConditionsFrame, false, 1.1)

		local xStartAt = 10
		local x2StartAt = 500
		local anchorPositions = {
			class = {xStartAt, -70},
			spec = {xStartAt, -200},
			race = {xStartAt, -250},
			role = {xStartAt, -380},
			talent = {xStartAt, -440},
			pvptalent = {x2StartAt, -70},
			group = {x2StartAt, -170},
			affix = {x2StartAt, -240},
			encounter_ids = {x2StartAt+1, -375},
			map_ids = {x2StartAt + 210, -375},
		}

		local editingLabel = detailsFramework:CreateLabel(loadConditionsFrame, "Load Conditions For:")
		local editingWhatLabel = detailsFramework:CreateLabel(loadConditionsFrame, "")
		editingLabel:SetPoint("topleft", loadConditionsFrame, "topleft", 10, -35)
		editingWhatLabel:SetPoint("left", editingLabel, "right", 2, 0)

		--this label store the name of what is being edited
		loadConditionsFrame.EditingLabel = editingWhatLabel

		--when the user click on an option, run the callback
			loadConditionsFrame.RunCallback = function()
				detailsFramework:Dispatch(loadConditionsFrame.CallbackFunc)
			end

		--when the user click on an option or when the panel is opened
		--check if there's an option enabled and fadein all options, fadeout otherwise
			loadConditionsFrame.OnRadioStateChanged = function(radioGroup, subConfigTable)
				subConfigTable.Enabled = nil
				subConfigTable.Enabled = next(subConfigTable) and true or nil
				radioGroup:SetFadeState(subConfigTable.Enabled)
			end

		--create the radio group for character class
			loadConditionsFrame.OnRadioCheckboxClick = function(self, key, value)
				--hierarchy: DBKey ["class"] key ["HUNTER"] value TRUE
				local DBKey = self:GetParent().DBKey
				loadConditionsFrame.OptionsTable [DBKey] [key and key .. ""] = value and true or nil

				if not value then -- cleanup "number" type values
					loadConditionsFrame.OptionsTable [DBKey] [key] = nil
				end

				loadConditionsFrame.OnRadioStateChanged(self:GetParent(), loadConditionsFrame.OptionsTable [DBKey])
				loadConditionsFrame.RunCallback()
			end

		--create the radio group for classes
			local classes = {}
			for _, classTable in pairs(detailsFramework:GetClassList()) do
				table.insert(classes, {
					name = classTable.Name,
					set = loadConditionsFrame.OnRadioCheckboxClick,
					param = classTable.FileString,
					get = function() return loadConditionsFrame.OptionsTable.class[classTable.FileString] end,
					texture = classTable.Texture,
					texcoord = classTable.TexCoord,
				})
			end

			local classGroup = detailsFramework:CreateCheckboxGroup(loadConditionsFrame, classes, nil, {width = 430, height = 200, title = "Character Class", backdrop_color = {0, 0, 0, 0}}, {offset_x = 130, amount_per_line = 3})
			classGroup:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.class[1], anchorPositions.class[2])
			classGroup.DBKey = "class"
			table.insert(loadConditionsFrame.AllRadioGroups, classGroup)

		--create the radio group for character spec
			if IS_WOW_PROJECT_MAINLINE then
				local specs = {}
				for _, specID in ipairs(detailsFramework:GetClassSpecIDs(select(2, UnitClass("player")))) do
					local specID, specName, specDescription, specIcon, specBackground, specRole, specClass = DetailsFramework.GetSpecializationInfoByID(specID)
					table.insert(specs, {
						name = specName,
						set = loadConditionsFrame.OnRadioCheckboxClick,
						param = specID,
						get = function() return loadConditionsFrame.OptionsTable.spec[specID] or loadConditionsFrame.OptionsTable.spec[specID..""] end,
						texture = specIcon,
					})
				end

				local specGroup = detailsFramework:CreateCheckboxGroup(loadConditionsFrame, specs, nil, {width = 200, height = 200, title = "Character Spec", backdrop_color = {0, 0, 0, 0}}, {offset_x = 120, amount_per_line = 4})
				specGroup:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.spec[1], anchorPositions.spec[2])
				specGroup.DBKey = "spec"
				table.insert(loadConditionsFrame.AllRadioGroups, specGroup)
			end

		--create radio group for character races
			local raceList = {}
			for _, raceTable in ipairs(detailsFramework:GetCharacterRaceList()) do
				table.insert(raceList, {
					name = raceTable.Name:sub(1, 15),
					set = loadConditionsFrame.OnRadioCheckboxClick,
					param = raceTable.FileString,
					get = function() return loadConditionsFrame.OptionsTable.race [raceTable.FileString] end,
				})
			end

			local raceGroup = detailsFramework:CreateCheckboxGroup(loadConditionsFrame, raceList, nil, {width = 200, height = 200, title = "Character Race", backdrop_color = {0, 0, 0, 0}})
			raceGroup:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.race [1], anchorPositions.race [2])
			raceGroup.DBKey = "race"
			table.insert(loadConditionsFrame.AllRadioGroups, raceGroup)

		--create radio group for talents
			if IS_WOW_PROJECT_MAINLINE then
				--[=[ 7.0 to 9.0 talents schema
				local talentList = {}
				for _, talentTable in ipairs(detailsFramework:GetCharacterTalents()) do
					if talentTable.ID then
						table.insert(talentList, {
							name = talentTable.Name:sub(1, 15),
							set = loadConditionsFrame.OnRadioCheckboxClick,
							param = talentTable.ID,
							get = function() return loadConditionsFrame.OptionsTable.talent[talentTable.ID] or loadConditionsFrame.OptionsTable.talent[talentTable.ID .. ""] end,
							texture = talentTable.Texture,
						})
					end
				end
				--]=]

				--10.0 talents schema
				local talentList = {}
				local talentGroup = detailsFramework:CreateCheckboxGroup(loadConditionsFrame, talentList, nil, {width = 200, height = 200, title = "Character Talents", backdrop_color = {0, 0, 0, 0}}, {offset_x = 64, amount_per_line = 16})
				talentGroup:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.talent[1], anchorPositions.talent[2])
				talentGroup.DBKey = "talent"

				table.insert(loadConditionsFrame.AllRadioGroups, talentGroup)
				loadConditionsFrame.TalentGroup = talentGroup

				do
					if (false) then --disabled, isn't in use
						--create a frame to show talents selected in other specs or characters
						local otherTalents = CreateFrame("frame", nil, loadConditionsFrame, "BackdropTemplate")
						otherTalents:SetSize(26, 26)
						otherTalents:SetPoint("left", talentGroup.Title.widget, "right", 10, -2)
						otherTalents.Texture = detailsFramework:CreateImage(otherTalents, [[Interface\BUTTONS\AdventureGuideMicrobuttonAlert]], 24, 24)
						otherTalents.Texture:SetAllPoints()

						local removeTalent = function(_, _, talentID)
							loadConditionsFrame.OptionsTable.talent[talentID] = nil
							GameCooltip2:Hide()
							loadConditionsFrame.OnRadioStateChanged(talentGroup, loadConditionsFrame.OptionsTable[talentGroup.DBKey])
							--loadConditionsFrame.CanShowTalentWarning()
						end

						local buildTalentMenu = function()
							local playerTalents = detailsFramework:GetCharacterTalents()
							local indexedTalents = {}
							for _, talentTable in ipairs(playerTalents) do
								table.insert(indexedTalents, talentTable.ID)
							end

							--talents selected to load
							GameCooltip2:AddLine("select a talent to remove it (added from a different spec or character)", "", 1, "orange", "orange", 9)
							GameCooltip2:AddLine("$div", nil, nil, -1, -1)

							for talentID, _ in pairs(loadConditionsFrame.OptionsTable.talent) do
								if (type(talentID) == "number" and not detailsFramework.table.find(indexedTalents, talentID)) then
									local talentID, name, texture, selected, available = GetTalentInfoByID(talentID)
									if (name) then
										GameCooltip2:AddLine(name)
										GameCooltip2:AddIcon(texture, 1, 1, 16, 16, .1, .9, .1, .9)
										GameCooltip2:AddMenu(1, removeTalent, talentID)
									end
								end
							end
						end

						otherTalents.CoolTip = {
							Type = "menu",
							BuildFunc = buildTalentMenu,
							OnEnterFunc = function(self) end,
							OnLeaveFunc = function(self) end,
							FixedValue = "none",
							ShowSpeed = 0.05,
							Options = function()
								GameCooltip2:SetOption("TextFont", "Friz Quadrata TT")
								GameCooltip2:SetOption("TextColor", "orange")
								GameCooltip2:SetOption("TextSize", 12)
								GameCooltip2:SetOption("FixedWidth", 220)
								GameCooltip2:SetOption("ButtonsYMod", -4)
								GameCooltip2:SetOption("YSpacingMod", -4)
								GameCooltip2:SetOption("IgnoreButtonAutoHeight", true)

								GameCooltip2:SetColor(1, 0.5, 0.5, 0.5, 0)

								local preset2_backdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile = true, edgeSize = 1, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}}
								local gray_table = {0.37, 0.37, 0.37, 0.95}
								local black_table = {0.2, 0.2, 0.2, 1}
								GameCooltip2:SetBackdrop(1, preset2_backdrop, gray_table, black_table)
								GameCooltip2:SetBackdrop(2, preset2_backdrop, gray_table, black_table)
							end,
						}
						GameCooltip2:CoolTipInject(otherTalents)

						--[=[
						function loadConditionsFrame.CanShowTalentWarning() --not in use
							local playerTalents = detailsFramework:GetCharacterTalents()
							local indexedTalents = {}
							for _, talentTable in ipairs(playerTalents) do
								table.insert(indexedTalents, talentTable.ID)
							end
							for talentID, _ in pairs(loadConditionsFrame.OptionsTable.talent) do
								if (type(talentID) == "number" and not detailsFramework.table.find(indexedTalents, talentID)) then
									otherTalents:Show()
									return
								end
							end
							otherTalents:Hide()
						end
						--]=]
					end
				end
			end

		--create radio group for pvp talents
			if IS_WOW_PROJECT_MAINLINE then
				local pvpTalentList = {}
				for _, talentTable in ipairs(detailsFramework:GetCharacterPvPTalents()) do
					table.insert(pvpTalentList, {
						name = talentTable.Name:sub(1, 15),
						set = loadConditionsFrame.OnRadioCheckboxClick,
						param = talentTable.ID,
						get = function() return loadConditionsFrame.OptionsTable.pvptalent [talentTable.ID] or loadConditionsFrame.OptionsTable.pvptalent [talentTable.ID .. ""] end,
						texture = talentTable.Texture,
					})
				end
				local pvpTalentGroup = detailsFramework:CreateCheckboxGroup(loadConditionsFrame, pvpTalentList, nil, {width = 200, height = 200, title = "Characer PvP Talents", backdrop_color = {0, 0, 0, 0}}, {offset_x = 160, amount_per_line = 3})
				pvpTalentGroup:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.pvptalent [1], anchorPositions.pvptalent [2])
				pvpTalentGroup.DBKey = "pvptalent"
				table.insert(loadConditionsFrame.AllRadioGroups, pvpTalentGroup)
				loadConditionsFrame.PvPTalentGroup = pvpTalentGroup

				do
					if (false) then
						--create a frame to show talents selected in other specs or characters
						local otherTalents = CreateFrame("frame", nil, loadConditionsFrame, "BackdropTemplate")
						otherTalents:SetSize(26, 26)
						otherTalents:SetPoint("left", pvpTalentGroup.Title.widget, "right", 10, -2)
						otherTalents.Texture = detailsFramework:CreateImage(otherTalents, [[Interface\BUTTONS\AdventureGuideMicrobuttonAlert]], 24, 24)
						otherTalents.Texture:SetAllPoints()

						local removeTalent = function(_, _, talentID)
							loadConditionsFrame.OptionsTable.pvptalent [talentID] = nil
							GameCooltip2:Hide()
							loadConditionsFrame.OnRadioStateChanged(pvpTalentGroup, loadConditionsFrame.OptionsTable [pvpTalentGroup.DBKey])
							--loadConditionsFrame.CanShowPvPTalentWarning()
						end

						local buildTalentMenu = function()
							local playerTalents = detailsFramework:GetCharacterPvPTalents()
							local indexedTalents = {}
							for _, talentTable in ipairs(playerTalents) do
								table.insert(indexedTalents, talentTable.ID)
							end

							--talents selected to load
							GameCooltip2:AddLine("select a talent to remove it(added from a different spec or character)", "", 1, "orange", "orange", 9)
							GameCooltip2:AddLine("$div", nil, nil, -1, -1)

							for talentID, _ in pairs(loadConditionsFrame.OptionsTable.pvptalent) do
								if (type(talentID) == "number" and not detailsFramework.table.find(indexedTalents, talentID)) then
									local _, name, texture = GetPvpTalentInfoByID(talentID)
									if (name) then
										GameCooltip2:AddLine(name)
										GameCooltip2:AddIcon(texture, 1, 1, 16, 16, .1, .9, .1, .9)
										GameCooltip2:AddMenu(1, removeTalent, talentID)
									end
								end
							end
						end

						otherTalents.CoolTip = {
							Type = "menu",
							BuildFunc = buildTalentMenu,
							OnEnterFunc = function(self) end,
							OnLeaveFunc = function(self) end,
							FixedValue = "none",
							ShowSpeed = 0.05,
							Options = function()
								GameCooltip2:SetOption("TextFont", "Friz Quadrata TT")
								GameCooltip2:SetOption("TextColor", "orange")
								GameCooltip2:SetOption("TextSize", 12)
								GameCooltip2:SetOption("FixedWidth", 220)
								GameCooltip2:SetOption("ButtonsYMod", -4)
								GameCooltip2:SetOption("YSpacingMod", -4)
								GameCooltip2:SetOption("IgnoreButtonAutoHeight", true)

								GameCooltip2:SetColor(1, 0.5, 0.5, 0.5, 0)

								local preset2_backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], tile = true, edgeSize = 1, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}}
								local gray_table = {0.37, 0.37, 0.37, 0.95}
								local black_table = {0.2, 0.2, 0.2, 1}
								GameCooltip2:SetBackdrop(1, preset2_backdrop, gray_table, black_table)
								GameCooltip2:SetBackdrop(2, preset2_backdrop, gray_table, black_table)
							end,
						}
						GameCooltip2:CoolTipInject(otherTalents)

						function loadConditionsFrame.CanShowPvPTalentWarning()
							local playerTalents = detailsFramework:GetCharacterPvPTalents()
							local indexedTalents = {}
							for _, talentTable in ipairs(playerTalents) do
								table.insert(indexedTalents, talentTable.ID)
							end
							for talentID, _ in pairs(loadConditionsFrame.OptionsTable.pvptalent) do
								if (type(talentID) == "number" and not detailsFramework.table.find(indexedTalents, talentID)) then
									otherTalents:Show()
									return
								end
							end
							otherTalents:Hide()
						end
						--]=]
					end
				end
			end

		--create radio for group types
			local groupTypes = {}
			for _, groupTable in ipairs(detailsFramework:GetGroupTypes()) do
				table.insert(groupTypes, {
					name = groupTable.Name,
					set = loadConditionsFrame.OnRadioCheckboxClick,
					param = groupTable.ID,
					get = function() return loadConditionsFrame.OptionsTable.group [groupTable.ID] or loadConditionsFrame.OptionsTable.group [groupTable.ID .. ""] end,
				})
			end
			local groupTypesGroup = detailsFramework:CreateCheckboxGroup(loadConditionsFrame, groupTypes, nil, {width = 200, height = 200, title = "Group Types", backdrop_color = {0, 0, 0, 0}}, {offset_x = 125})
			groupTypesGroup:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.group[1], anchorPositions.group[2])
			groupTypesGroup.DBKey = "group"
			table.insert(loadConditionsFrame.AllRadioGroups, groupTypesGroup)

		--create radio for character roles
			local roleTypes = {}
			for _, roleTable in ipairs(detailsFramework:GetRoleTypes()) do
				table.insert(roleTypes, {
					name = (roleTable.Texture .. " " .. roleTable.Name),
					set = loadConditionsFrame.OnRadioCheckboxClick,
					param = roleTable.ID,
					get = function() return loadConditionsFrame.OptionsTable.role [roleTable.ID] or loadConditionsFrame.OptionsTable.role [roleTable.ID .. ""] end,
				})
			end

			local roleTypesGroup = detailsFramework:CreateCheckboxGroup(loadConditionsFrame, roleTypes, nil, {width = 200, height = 200, title = "Role Types", backdrop_color = {0, 0, 0, 0}})
			roleTypesGroup:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.role[1], anchorPositions.role[2])
			roleTypesGroup.DBKey = "role"
			table.insert(loadConditionsFrame.AllRadioGroups, roleTypesGroup)

		--create radio group for mythic+ affixes
			if IS_WOW_PROJECT_MAINLINE then
				local affixes = {}
				for i = 2, 1000 do
					local affixName, desc, texture = C_ChallengeMode.GetAffixInfo(i)
					if (affixName and not deprecatedAffixes[i]) then
						table.insert(affixes, {
							name = affixName,
							set = loadConditionsFrame.OnRadioCheckboxClick,
							param = i,
							get = function() return loadConditionsFrame.OptionsTable.affix[i] or loadConditionsFrame.OptionsTable.affix[i .. ""] end,
							texture = texture,
						})
					end
				end

				local affixTypesGroup = detailsFramework:CreateCheckboxGroup(loadConditionsFrame, affixes, nil, {width = 200, height = 200, title = "M+ Affixes", backdrop_color = {0, 0, 0, 0}}, {offset_x = 125})
				affixTypesGroup:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.affix [1], anchorPositions.affix [2])
				affixTypesGroup.DBKey = "affix"
				table.insert(loadConditionsFrame.AllRadioGroups, affixTypesGroup)
			end

		--text entries functions
			local textEntryRefresh = function(self)
				local idList = loadConditionsFrame.OptionsTable [self.DBKey]
				self:SetText("")
				for _, id in pairs(idList) do
					if tonumber(id) then
						self:SetText(self:GetText() .. " " .. id)
					end
				end
				self:SetText(self:GetText():gsub("^ ", ""))
			end

			local textEntryOnEnterPressed = function(_, self)
				table.wipe(loadConditionsFrame.OptionsTable [self.DBKey])
				local text = self:GetText()

				for _, ID in ipairs({strsplit(" ", text)}) do
					ID = detailsFramework:trim(ID)
					ID = tonumber(ID)
					if (ID) then
						table.insert(loadConditionsFrame.OptionsTable [self.DBKey], ID)
						loadConditionsFrame.OptionsTable [self.DBKey].Enabled = true
					end
				end
			end

		--create the text entry to type the encounter ID
			local encounterIDLabel = detailsFramework:CreateLabel(loadConditionsFrame, "Encounter ID", detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
			local encounterIDEditbox = detailsFramework:CreateTextEntry(loadConditionsFrame, function() loadConditionsFrame.RunCallback() end, 200, 20, "EncounterEditbox", _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			encounterIDLabel:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.encounter_ids[1], anchorPositions.encounter_ids[2])
			encounterIDEditbox:SetPoint("topleft", encounterIDLabel, "bottomleft", 0, -2)
			encounterIDEditbox.DBKey = "encounter_ids"
			encounterIDEditbox.Refresh = textEntryRefresh
			encounterIDEditbox.tooltip = "Enter multiple IDs separating with a whitespace.\nExample: 35 45 95\n\nSanctum of Domination:\n"

			for _, encounterTable in ipairs(detailsFramework:GetCLEncounterIDs()) do
				encounterIDEditbox.tooltip = encounterIDEditbox.tooltip .. encounterTable.ID .. " - " .. encounterTable.Name .. "\n"
			end

			encounterIDEditbox:SetHook("OnEnterPressed", textEntryOnEnterPressed)
			table.insert(loadConditionsFrame.AllTextEntries, encounterIDEditbox)

		--create the text entry for map ID
			local mapIDLabel = detailsFramework:CreateLabel(loadConditionsFrame, "Map ID", detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
			local mapIDEditbox = detailsFramework:CreateTextEntry(loadConditionsFrame, function() loadConditionsFrame.RunCallback() end, 200, 20, "MapEditbox", _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			mapIDLabel:SetPoint("topleft", loadConditionsFrame, "topleft", anchorPositions.map_ids[1], anchorPositions.map_ids[2])
			mapIDEditbox:SetPoint("topleft", mapIDLabel, "bottomleft", 0, -2)
			mapIDEditbox.DBKey = "map_ids"
			mapIDEditbox.Refresh = textEntryRefresh
			mapIDEditbox.tooltip = "Enter multiple IDs separating with a whitespace\nExample: 35 45 95"
			mapIDEditbox:SetHook("OnEnterPressed", textEntryOnEnterPressed)
			table.insert(loadConditionsFrame.AllTextEntries, mapIDEditbox)

		function loadConditionsFrame.Refresh(self)
			if IS_WOW_PROJECT_MAINLINE then
				---@type {Name: string, ID: number, Texture: any, IsSelected: boolean}[]
				local allTalents = detailsFramework:GetAllTalents()
				local talentList = {}
				for _, talentTable in ipairs(allTalents) do
					if (talentTable.ID) then
						table.insert(talentList, {
							name = "", --talentTable.Name:sub(1, 15),
							set = loadConditionsFrame.OnRadioCheckboxClick,
							param = talentTable.ID,
							get = function() return loadConditionsFrame.OptionsTable.talent[talentTable.ID] or loadConditionsFrame.OptionsTable.talent[talentTable.ID .. ""] end,
							texture = talentTable.Texture,
							tooltip = talentTable.Name,
						})
					end
				end

				--[=[]]
				--update the talents(might have changed if the player changed its specializationid)
				local talentList = {}
				for _, talentTable in ipairs(detailsFramework:GetCharacterTalents()) do
					if talentTable.ID then
						table.insert(talentList, {
							name = talentTable.Name,
							set = loadConditionsFrame.OnRadioCheckboxClick,
							param = talentTable.ID,
							get = function() return loadConditionsFrame.OptionsTable.talent [talentTable.ID] or loadConditionsFrame.OptionsTable.talent [talentTable.ID .. ""] end,
							texture = talentTable.Texture,
						})
					end
				end
				--]=]

				loadConditionsFrame.TalentGroup:SetOptions(talentList)
			end

			if IS_WOW_PROJECT_MAINLINE then
				local pvpTalentList = {}
				for _, talentTable in ipairs(detailsFramework:GetCharacterPvPTalents()) do
					table.insert(pvpTalentList, {
						name = talentTable.Name:sub(1, 15),
						set = loadConditionsFrame.OnRadioCheckboxClick,
						param = talentTable.ID,
						get = function() return loadConditionsFrame.OptionsTable.pvptalent [talentTable.ID] or loadConditionsFrame.OptionsTable.pvptalent [talentTable.ID .. ""] end,
						texture = talentTable.Texture,
					})
				end
				loadConditionsFrame.PvPTalentGroup:SetOptions(pvpTalentList)
			end

			--refresh the radio group
			for _, radioGroup in ipairs(loadConditionsFrame.AllRadioGroups) do
				radioGroup:Refresh()
				loadConditionsFrame.OnRadioStateChanged(radioGroup, loadConditionsFrame.OptionsTable [radioGroup.DBKey])
			end

			--refresh text entries
			for _, textEntry in ipairs(loadConditionsFrame.AllTextEntries) do
				textEntry:Refresh()
			end

			if IS_WOW_PROJECT_MAINLINE then
				--loadConditionsFrame.CanShowTalentWarning()
				--loadConditionsFrame.CanShowPvPTalentWarning()
			end
		end

	end

	--set the options table
	loadConditionsFrame.OptionsTable = optionsTable

	--set the callback func
	loadConditionsFrame.CallbackFunc = callback
	loadConditionsFrame.OptionsTable = optionsTable

	--set title
	loadConditionsFrame.EditingLabel:SetText(frameOptions.name)
	loadConditionsFrame.Title:SetText(frameOptions.title)

	--show the panel to the user
	loadConditionsFrame:Show()

	loadConditionsFrame:Refresh()
end