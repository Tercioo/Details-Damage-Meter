
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local GetSpellInfo = GetSpellInfo
local UnitClass = UnitClass
local UnitName = UnitName
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local DF = DetailsFramework

--> build the list of buffs to track
local flask_list = DetailsFramework.FlaskIDs

local food_list = {
	tier1 = {},
	tier2 = {},
	tier3 = {},
}

for spellID, power in pairs (DetailsFramework.FoodIDs) do
	if (power == 41) then
		food_list.tier1 [spellID] = true
		
	elseif (power == 55) then
		food_list.tier2 [spellID] = true
		
	elseif (power >= 75) then
		food_list.tier3 [spellID] = true
		
	end
end

local runes_id = DetailsFramework.RuneIDs

-- 

local get_unit_id = function (i)
	local unitID
	
	local unitType = "raid"
	if (not IsInRaid()) then --o jogador esta em grupo
		unitType = "party"
	end
	
	if (unitType == "party") then
		if (i == GetNumGroupMembers()) then
			unitID = "player"
		else
			unitID = unitType .. i
		end
	else
		unitID = unitType .. i
	end
	
	return unitID
end

--> localization
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details")
--> create the plugin object
	local DetailsRaidCheck = _detalhes:NewPluginObject ("DetailsRaidCheck", DETAILSPLUGIN_ALWAYSENABLED)
	tinsert (UISpecialFrames, "DetailsRaidCheck")
	DetailsRaidCheck:SetPluginDescription (Loc ["STRING_RAIDCHECK_PLUGIN_DESC"])

	local version = "v0.6"
	
	local debugmode = false
	--local debugmode = true
	
	local CreatePluginFrames = function()
	
		--> localize details functions (localize = it doesn't need to get this through indexed metatable any more)
		DetailsRaidCheck.GetOnlyName = DetailsRaidCheck.GetOnlyName
	
		--> tables
		DetailsRaidCheck.usedprepot_table = {}
		DetailsRaidCheck.focusaug_table = {}
		DetailsRaidCheck.haveflask_table = {}
		DetailsRaidCheck.havefood_table = {}
		DetailsRaidCheck.havefocusaug_table = {}
		
		DetailsRaidCheck.on_raid = false
		DetailsRaidCheck.tracking_buffs = false
		
		local empty_table = {}
		
		local PlayerData = {}
		local UpdateSpeed = .3
		
		function DetailsRaidCheck:OnDetailsEvent (event, ...)
			
			if (event == "ZONE_TYPE_CHANGED") then
			
				DetailsRaidCheck:CheckZone (...)

			elseif (event == "COMBAT_PREPOTION_UPDATED") then

				DetailsRaidCheck.usedprepot_table, DetailsRaidCheck.focusaug_table = select (1, ...)

			elseif (event == "COMBAT_PLAYER_LEAVE") then
				
				if (DetailsRaidCheck.on_raid) then
					DetailsRaidCheck:StartTrackBuffs()
				end
			
			elseif (event == "COMBAT_PLAYER_ENTER") then
				
				if (DetailsRaidCheck.on_raid) then
					DetailsRaidCheck:StopTrackBuffs()
				end
				
			elseif (event == "DETAILS_STARTED") then

				DetailsRaidCheck:CheckZone()
				
			elseif (event == "PLUGIN_DISABLED") then
			
				DetailsRaidCheck.on_raid = false
				DetailsRaidCheck.tracking_buffs = false
				
				DetailsRaidCheck:StopTrackBuffs()
				
				DetailsRaidCheck:HideToolbarIcon (DetailsRaidCheck.ToolbarButton)
			
			elseif (event == "PLUGIN_ENABLED") then

				DetailsRaidCheck:CheckZone()
				
			end
			
		end
		
		DetailsRaidCheck.ToolbarButton = _detalhes.ToolBar:NewPluginToolbarButton (DetailsRaidCheck.empty_function, [[Interface\AddOns\Details_RaidCheck\icon]], Loc ["STRING_RAIDCHECK_PLUGIN_NAME"], "", 16, 16, "RAIDCHECK_PLUGIN_BUTTON")
		DetailsRaidCheck.ToolbarButton.shadow = true --> loads icon_shadow.tga when the instance is showing icons with shadows
		
		function DetailsRaidCheck.GetPlayerAmount()
			local playerAmount = GetNumGroupMembers()
			
			--limit to 20 if in mythic raid and the option is enabled
			local _, _, difficulty = GetInstanceInfo()
			if (difficulty == 16 and DetailsRaidCheck.db.mythic_1_4 and playerAmount > 20) then
				playerAmount = 20
			end
			
			--reduce in 1 if the player is only in party
			if (not IsInRaid()) then
				playerAmount = playerAmount - 1
			end
			
			return playerAmount
		end
		
		function DetailsRaidCheck:SetGreenIcon()
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (not lower_instance) then
				return
			end
			local instance = _detalhes:GetInstance (lower_instance)
			
			if (instance.menu_icons.shadow) then
				DetailsRaidCheck.ToolbarButton:SetNormalTexture ([[Interface\AddOns\Details_RaidCheck\icon_shadow]])
				DetailsRaidCheck.ToolbarButton:SetPushedTexture ([[Interface\AddOns\Details_RaidCheck\icon_shadow]])
				DetailsRaidCheck.ToolbarButton:SetDisabledTexture ([[Interface\AddOns\Details_RaidCheck\icon_shadow]])
				DetailsRaidCheck.ToolbarButton:SetHighlightTexture ([[Interface\AddOns\Details_RaidCheck\icon_shadow]], "ADD")
			else
				DetailsRaidCheck.ToolbarButton:SetNormalTexture ([[Interface\AddOns\Details_RaidCheck\icon]])
				DetailsRaidCheck.ToolbarButton:SetPushedTexture ([[Interface\AddOns\Details_RaidCheck\icon]])
				DetailsRaidCheck.ToolbarButton:SetDisabledTexture ([[Interface\AddOns\Details_RaidCheck\icon]])
				DetailsRaidCheck.ToolbarButton:SetHighlightTexture ([[Interface\AddOns\Details_RaidCheck\icon]], "ADD")
			end
		end
		
		function DetailsRaidCheck:SetRedIcon()
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (not lower_instance) then
				return
			end
			local instance = _detalhes:GetInstance (lower_instance)
			
			if (instance.menu_icons.shadow) then
				DetailsRaidCheck.ToolbarButton:SetNormalTexture ([[Interface\AddOns\Details_RaidCheck\icon_red_shadow]])
				DetailsRaidCheck.ToolbarButton:SetPushedTexture ([[Interface\AddOns\Details_RaidCheck\icon_red_shadow]])
				DetailsRaidCheck.ToolbarButton:SetDisabledTexture ([[Interface\AddOns\Details_RaidCheck\icon_red_shadow]])
				DetailsRaidCheck.ToolbarButton:SetHighlightTexture ([[Interface\AddOns\Details_RaidCheck\icon_red_shadow]], "ADD")
			else
				DetailsRaidCheck.ToolbarButton:SetNormalTexture ([[Interface\AddOns\Details_RaidCheck\icon_red]])
				DetailsRaidCheck.ToolbarButton:SetPushedTexture ([[Interface\AddOns\Details_RaidCheck\icon_red]])
				DetailsRaidCheck.ToolbarButton:SetDisabledTexture ([[Interface\AddOns\Details_RaidCheck\icon_red]])
				DetailsRaidCheck.ToolbarButton:SetHighlightTexture ([[Interface\AddOns\Details_RaidCheck\icon_red]], "ADD")
			end
		end

		local show_panel = CreateFrame ("frame", nil, UIParent)
		show_panel:SetPoint ("bottom", DetailsRaidCheck.ToolbarButton, "top", 0, 10)
		show_panel:SetClampedToScreen (true)
		show_panel:SetFrameStrata ("TOOLTIP")
		
		--
		
		--copying style from the all displays menu
		show_panel:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16 })
		show_panel:SetBackdropColor (0.05, 0.05, 0.05, 0.3)
		show_panel.background = show_panel:CreateTexture ("DetailsAllAttributesFrameBackground111", "background")
		show_panel.background:SetDrawLayer ("background", 2)
		show_panel.background:SetPoint ("topleft", show_panel, "topleft", 4, -4)
		show_panel.background:SetPoint ("bottomright", show_panel, "bottomright", -4, 4)
		show_panel.wallpaper = show_panel:CreateTexture ("DetailsAllAttributesFrameWallPaper111", "background")
		show_panel.wallpaper:SetDrawLayer ("background", 4)
		show_panel.wallpaper:SetPoint ("topleft", show_panel, "topleft", 4, -4)
		show_panel.wallpaper:SetPoint ("bottomright", show_panel, "bottomright", -4, 4)		

		show_panel:SetBackdrop (_detalhes.menu_backdrop_config.menus_backdrop)
		show_panel:SetBackdropColor (unpack (_detalhes.menu_backdrop_config.menus_backdropcolor))
		show_panel:SetBackdropBorderColor (unpack (_detalhes.menu_backdrop_config.menus_bordercolor))
		
		--
		
		local report_string1 = show_panel:CreateFontString (nil, "overlay", "GameFontNormal")
		report_string1:SetPoint ("bottomleft", show_panel, "bottomleft", 10, 10)
		report_string1:SetText ("|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:12:0:1:512:512:8:70:225:307|t Report No Food/Flask  |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:12:0:1:512:512:8:70:328:409|t Report No Pre-Pot  |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:12:0:1:512:512:8:70:126:204|t Report No Rune  |  |cFFFFFFFFShift+Click: Options|r") 

		DetailsRaidCheck:SetFontSize (report_string1, 10)
		DetailsRaidCheck:SetFontColor (report_string1, "white")
		report_string1:SetAlpha (0.6)
		
		--
		
		--header and scroll
		local headerTable = {
			{text = "Player Name", width = 160},
			{text = "Talents", width = 150},
			{text = "Item Level", width = 80},
			{text = "Food", width = 80},
			{text = "Flask", width = 80},
			{text = "Rune", width = 80},
			{text = "Pre-Pot", width = 80},
		}
		local headerOptions = {
			padding = 2,
		}
		
		DetailsRaidCheck.Header = DF:CreateHeader (show_panel, headerTable, headerOptions)
		DetailsRaidCheck.Header:SetPoint ("topleft", show_panel, "topleft", 10, -10)
		
		--options
		local scroll_width = 722
		local scroll_lines = 30
		local scroll_line_height = 16
		local scroll_height = scroll_lines * scroll_line_height
		local backdrop_color = {.2, .2, .2, 0.2}
		local backdrop_color_on_enter = {.8, .8, .8, 0.4}
		local y = -10
		local headerY = y - 2
		local scrollY = headerY - 20
		
		show_panel:SetSize (722 + 20, 540)
		
		--create line for the scroll
		local scroll_createline = function (self, index)
		
			local line = CreateFrame ("button", "$parentLine" .. index, self)
			line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
			line:SetSize (scroll_width - 2, scroll_line_height)
			line:SetScript ("OnEnter", line_onenter)
			line:SetScript ("OnLeave", line_onleave)
			
			line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor (unpack (backdrop_color))
			
			DF:Mixin (line, DetailsFramework.HeaderFunctions)
			
			--role icon
			local roleIcon = DF:CreateImage (line, nil, scroll_line_height, scroll_line_height)
			
			--spec icon
			local specIcon = DF:CreateImage (line, nil, scroll_line_height, scroll_line_height)
				specIcon:SetPoint ("left", roleIcon, "right", 2, 0)
				
			--player name
			local playerName = DF:CreateLabel (line)
				playerName:SetPoint ("left", specIcon, "right", 2, 0)
			
			--talents
			local talent_row_options = {
				icon_width = 16, 
				icon_height = 16, 
				texcoord = {.1, .9, .1, .9},
				show_text = false,
			}
			local talentsRow = DF:CreateIconRow (line, "$parentTalentIconsRow", talent_row_options)
			
			--item level
			local itemLevel = DF:CreateLabel (line)
			
			--no food
			local noFood = DF:CreateLabel (line)
			--no flask
			local noFlask = DF:CreateLabel (line)
			--no rune
			local noRune = DF:CreateLabel (line)
			--no pre pot
			local noPrePot = DF:CreateLabel (line)
			
			line:AddFrameToHeaderAlignment (roleIcon)
			line:AddFrameToHeaderAlignment (talentsRow)
			line:AddFrameToHeaderAlignment (itemLevel)
			line:AddFrameToHeaderAlignment (noFood)
			line:AddFrameToHeaderAlignment (noFlask)
			line:AddFrameToHeaderAlignment (noRune)
			line:AddFrameToHeaderAlignment (noPrePot)
			
			line:AlignWithHeader (DetailsRaidCheck.Header, "left")
			
			line.RoleIcon = roleIcon
			line.SpecIcon = specIcon
			line.PlayerName = playerName
			line.TalentsRow = talentsRow
			line.ItemLevel = itemLevel
			line.NoFood = noFood
			line.NoFlask = noFlask
			line.NoRune = noRune
			line.NoPrePot = noPrePot
			
			return line
		end		
		
		local noFoodText = "|cFFFF2222X|r"
		
		--refresh scroll
		local scroll_refresh = function (self, data, offset, total_lines)
			
			local dataInOrder = {}

			for i = 1, #data do
				dataInOrder [#dataInOrder+1] = data [i]
			end

			table.sort (dataInOrder, DF.SortOrder1R)
			data = dataInOrder
		
			for i = 1, total_lines do
				local index = i + offset
				local playerTable = data [index]
				
				if (playerTable) then
					local line = self:GetLine (i)
					if (line) then
						
						local roleTexture, L, R, T, B = _detalhes:GetRoleIcon (playerTable.Role or "NONE")
						
						line.RoleIcon:SetTexture (roleTexture)
						line.RoleIcon:SetTexCoord (L, R, T, B)
						
						if (playerTable.Spec) then
							local texture, L, R, T, B = _detalhes:GetSpecIcon (playerTable.Spec)
							line.SpecIcon:SetTexture (texture)
							line.SpecIcon:SetTexCoord (L, R, T, B)
						else
							local texture, L, R, T, B = _detalhes:GetClassIcon (playerTable.Class)
							line.SpecIcon:SetTexture (texture)
							line.SpecIcon:SetTexCoord (L, R, T, B)
						end
						
						line.TalentsRow:ClearIcons()
						
						if (playerTable.Talents) then
							for i = 1, #playerTable.Talents do
								local talent = playerTable.Talents [i]
								local talentID, name, texture, selected, available = GetTalentInfoByID (talent)
								line.TalentsRow:SetIcon (false, false, false, false, texture)
							end
						end
						
					--	line.TalentsRow = talentsRow
						
						line.PlayerName.text = playerTable.Name
						line.ItemLevel.text = floor (playerTable.ILevel.ilvl or 0)
						line.NoFood.text = playerTable.Food and noFoodText or ""
						line.NoFlask.text = playerTable.Flask and noFoodText or ""
						line.NoRune.text = playerTable.Rune and noFoodText or ""
						line.NoPrePot.text = playerTable.PrePot and noFoodText or ""
						
						--[=[
							Name = unitName,
							Class = unitClass,
							Role = unitRole,
							Spec = unitSpec,
							ILevel = itemLevelTable,
							Talents = talentsTable,
							Food = DetailsRaidCheck.havefood_table [unitName],
							Flask = DetailsRaidCheck.haveflask_table [unitName],
							PrePot = DetailsRaidCheck.usedprepot_table [cleuName],
							Rune = DetailsRaidCheck.havefocusaug_table [unitName],
						--]=]
					end
				end
			end
			
		end
		
		--create scroll
		local mainScroll = DF:CreateScrollBox (show_panel, "$parentMainScroll", scroll_refresh, PlayerData, scroll_width, scroll_height, scroll_lines, scroll_line_height)
		DF:ReskinSlider (mainScroll)
		mainScroll.HideScrollBar = true
		mainScroll:SetPoint ("topleft", show_panel, "topleft", 10, scrollY)
		
		--create lines
		for i = 1, scroll_lines do 
			mainScroll:CreateLine (scroll_createline)
		end
		
		show_panel:Hide()
		
		DetailsRaidCheck.report_lines = ""
		local reportFunc = function (IsCurrent, IsReverse, AmtLines)
			DetailsRaidCheck:SendReportLines (DetailsRaidCheck.report_lines)
		end
		
		--> overwrite the default scripts
		DetailsRaidCheck.ToolbarButton:RegisterForClicks ("AnyUp")
		DetailsRaidCheck.ToolbarButton:SetScript ("OnClick", function (self, button)
			
			if (IsShiftKeyDown()) then
				DetailsRaidCheck.OpenOptionsPanel()
				return
			end
			
			if (button == "LeftButton") then
				--> link no food/flask
				local s, added = "Details!: No Flask or Food: ", {}
				
				local amt = GetNumGroupMembers()
				local _, _, difficulty = GetInstanceInfo()
				if (difficulty == 16 and DetailsRaidCheck.db.mythic_1_4 and amt > 20) then
					amt = 20
				end
				
				for i = 1, amt, 1 do
					local unitID = get_unit_id (i)
					
					local name = UnitName (unitID)
					if (not DetailsRaidCheck.havefood_table [name]) then
						added [name] = true
						s = s .. DetailsRaidCheck:GetOnlyName (name) .. " "
					end
					
					if (not DetailsRaidCheck.haveflask_table [name] and not added [name]) then
						s = s .. DetailsRaidCheck:GetOnlyName (name) .. " "
					end
				end
				
				if (DetailsRaidCheck.db.use_report_panel) then
					DetailsRaidCheck.report_lines = s
					DetailsRaidCheck:SendReportWindow (reportFunc)
				else
					if (IsInRaid()) then
						DetailsRaidCheck:SendMsgToChannel (s, "RAID")
					else
						DetailsRaidCheck:SendMsgToChannel (s, "PARTY")
					end
				end
				
			elseif (button == "RightButton") then
				--> link no pre-pot latest segment
				
				local s = "Details!: No Pre-Pot Last Try: "
				
				local amt = GetNumGroupMembers()
				local _, _, difficulty = GetInstanceInfo()
				if (difficulty == 16 and DetailsRaidCheck.db.mythic_1_4 and amt > 20) then
					amt = 20
				end
				
				for i = 1, amt, 1 do
				
					local unitID = get_unit_id (i)
					local role = UnitGroupRolesAssigned (unitID)
			
					if (role == "DAMAGER" or (role == "HEALER" and DetailsRaidCheck.db.pre_pot_healers) or (role == "TANK" and DetailsRaidCheck.db.pre_pot_tanks)) then
				
						local playerName, realmName = UnitName (unitID)
						if (realmName and realmName ~= "") then
							playerName = playerName .. "-" .. realmName
						end
						
						if (not DetailsRaidCheck.usedprepot_table [playerName]) then
							s = s .. DetailsRaidCheck:GetOnlyName (playerName) .. " "
						end
					
					end
				end
				
				if (DetailsRaidCheck.db.use_report_panel) then
					DetailsRaidCheck.report_lines = s
					DetailsRaidCheck:SendReportWindow (reportFunc)
				else
					if (IsInRaid()) then
						DetailsRaidCheck:SendMsgToChannel (s, "RAID")
					else
						DetailsRaidCheck:SendMsgToChannel (s, "PARTY")
					end
				end
			
			elseif (button == "MiddleButton") then
				--report focus aug
				local s = "Details!: Not using Rune: "
				
				local amt = GetNumGroupMembers()
				local _, _, difficulty = GetInstanceInfo()
				if (difficulty == 16 and DetailsRaidCheck.db.mythic_1_4 and amt > 20) then
					amt = 20
				end
				
				for i = 1, amt do
					local unitID = get_unit_id (i)
					local name = UnitName (unitID)
					if (not DetailsRaidCheck.havefocusaug_table [name]) then
						s = s .. DetailsRaidCheck:GetOnlyName (name) .. " "
					end
				end
				
				if (DetailsRaidCheck.db.use_report_panel) then
					DetailsRaidCheck.report_lines = s
					DetailsRaidCheck:SendReportWindow (reportFunc)
				else
					if (IsInRaid()) then
						DetailsRaidCheck:SendMsgToChannel (s, "RAID")
					else
						DetailsRaidCheck:SendMsgToChannel (s, "PARTY")
					end
				end
			
			end
			
		end)
		
		
		
		local update_panel = function (self, elapsed)
			show_panel.NextUpdate = show_panel.NextUpdate - elapsed
			
			if (show_panel.NextUpdate > 0) then
				return
			end

			show_panel.NextUpdate = UpdateSpeed
			
			if (not IsInRaid() and not IsInGroup()) then
				return
			end
			
			wipe (PlayerData)

			local groupTypeID = IsInRaid() and "raid" or "party"
			
			local playerAmount = DetailsRaidCheck.GetPlayerAmount()
			
			for i = 1, playerAmount do
				local unitID = groupTypeID .. i
				local unitName = UnitName (unitID)
				local cleuName = _detalhes:GetCLName (unitID)
				local unitSerial = UnitGUID (unitID)
				local _, unitClass = UnitClass (unitID)
				local unitRole = UnitGroupRolesAssigned (unitID)
				local unitSpec = _detalhes:GetSpecFromSerial (unitSerial) or _detalhes:GetSpec (cleuName)
				local itemLevelTable = _detalhes.ilevel:GetIlvl (unitSerial)
				local talentsTable = _detalhes:GetTalents (unitSerial)
				
				tinsert (PlayerData, {unitName,
					Name = unitName,
					Class = unitClass,
					Role = unitRole,
					Spec = unitSpec,
					ILevel = itemLevelTable,
					Talents = talentsTable,
					Food = DetailsRaidCheck.havefood_table [unitName],
					Flask = DetailsRaidCheck.haveflask_table [unitName],
					PrePot = DetailsRaidCheck.usedprepot_table [cleuName],
					Rune = DetailsRaidCheck.havefocusaug_table [unitName],
				})
			end
			
			if (not IsInRaid()) then
				--> add the player data
				local unitID = "player"
				
				local unitName = UnitName (unitID)
				local cleuName = _detalhes:GetCLName (unitID)
				local unitSerial = UnitGUID (unitID)
				local _, unitClass = UnitClass (unitID)
				local unitRole = UnitGroupRolesAssigned (unitID)
				local unitSpec = _detalhes:GetSpecFromSerial (unitSerial) or _detalhes:GetSpec (cleuName)
				local itemLevelTable = _detalhes.ilevel:GetIlvl (unitSerial)
				local talentsTable = _detalhes:GetTalents (unitSerial)
				
				tinsert (PlayerData, {unitName,
					Name = unitName,
					Class = unitClass,
					Role = unitRole,
					Spec = unitSpec,
					ILevel = itemLevelTable,
					Talents = talentsTable,
					Food = DetailsRaidCheck.havefood_table [unitName],
					Flask = DetailsRaidCheck.haveflask_table [unitName],
					PrePot = DetailsRaidCheck.usedprepot_table [cleuName],
					Rune = DetailsRaidCheck.havefocusaug_table [unitName],
				})
			end

			mainScroll:Refresh()
		end
		
		DetailsRaidCheck.ToolbarButton:SetScript ("OnEnter", function (self)
			show_panel:Show()
			show_panel:ClearAllPoints()
			show_panel:SetPoint ("bottom", DetailsRaidCheck.ToolbarButton, "top", 0, 10)
			show_panel.NextUpdate = UpdateSpeed
			update_panel (show_panel, 1)
			show_panel:SetScript ("OnUpdate", update_panel)
		end)
		
		DetailsRaidCheck.ToolbarButton:SetScript ("OnLeave", function (self)
			show_panel:SetScript ("OnUpdate", nil)
			show_panel:Hide()
		end)
		
		function DetailsRaidCheck:CheckZone (...)
		
			if (debugmode) then
				DetailsRaidCheck:ShowToolbarIcon (DetailsRaidCheck.ToolbarButton, "star")
			
				DetailsRaidCheck.on_raid = true
				
				if (not DetailsRaidCheck.in_combat) then
					DetailsRaidCheck:StartTrackBuffs()
				end
				
				return
			end
		
			zone_type = select (1, ...)
			
			if (not zone_type) then
				zone_type = select (2, GetInstanceInfo())
			end
			
			if (zone_type == "raid" or zone_type == "party") then
				DetailsRaidCheck:ShowToolbarIcon (DetailsRaidCheck.ToolbarButton, "star")
			
				DetailsRaidCheck.on_raid = true
				
				if (not DetailsRaidCheck.in_combat) then
					DetailsRaidCheck:StartTrackBuffs()
				end
			else
				DetailsRaidCheck:HideToolbarIcon (DetailsRaidCheck.ToolbarButton)
			
				DetailsRaidCheck.on_raid = false
				
				if (DetailsRaidCheck.tracking_buffs) then
					DetailsRaidCheck:StopTrackBuffs()
				end
			end
		end
		
		function DetailsRaidCheck:BuffTrackTick()
			
			wipe (DetailsRaidCheck.haveflask_table)
			wipe (DetailsRaidCheck.havefood_table)
			wipe (DetailsRaidCheck.havefocusaug_table)
			
			local playerAmount = DetailsRaidCheck.GetPlayerAmount()
			local with_flask, with_food = 0, 0
			
			for i = 1, playerAmount do
			
				local unitID = get_unit_id (i)
				local name = UnitName (unitID)
				
				for buffIndex = 1, 40 do
					local bname, _, _, _, _, _, _, _, _, _, spellid  = UnitBuff (unitID, buffIndex)
					
					if (bname) then
						if (flask_list [spellid]) then
							DetailsRaidCheck.haveflask_table [name] = spellid
							with_flask = with_flask + 1
						end
						
						if (DetailsRaidCheck.db.food_tier1) then
							if (food_list.tier1 [spellid]) then
								DetailsRaidCheck.havefood_table [name] = 1
								with_food = with_food + 1
							end
						end
						
						if (DetailsRaidCheck.db.food_tier2) then
							if (food_list.tier2 [spellid]) then
								DetailsRaidCheck.havefood_table [name] = 2
								with_food = with_food + 1
							end
						end
						
						if (DetailsRaidCheck.db.food_tier3) then
							if (food_list.tier3 [spellid]) then
								DetailsRaidCheck.havefood_table [name] = 3
								with_food = with_food + 1
							end
						end
						
						if (runes_id [spellid]) then
							DetailsRaidCheck.havefocusaug_table [name] = spellid
						end
					else
						break
					end
				end
			end
			
			if (with_food == playerAmount and with_flask == playerAmount) then
				DetailsRaidCheck:SetGreenIcon()
			else
				DetailsRaidCheck:SetRedIcon()
			end
			
		end
		
--		DETAILS_PLUGIN_RAIDCHECK
--		/run vardump (DETAILS_PLUGIN_RAIDCHECK.havefood_table)
--		DETAILS_PLUGIN_RAIDCHECK.tracking_buffs
--		/run DETAILS_PLUGIN_RAIDCHECK:StartTrackBuffs()
--		/run DETAILS_PLUGIN_RAIDCHECK:StopTrackBuffs()
		
		function DetailsRaidCheck:StartTrackBuffs()
			
			if (not DetailsRaidCheck.tracking_buffs) then
				DetailsRaidCheck.tracking_buffs = true
				
				table.wipe (DetailsRaidCheck.haveflask_table)
				table.wipe (DetailsRaidCheck.havefood_table)
				
				if (DetailsRaidCheck.tracking_buffs_process) then
					DetailsRaidCheck:CancelTimer (DetailsRaidCheck.tracking_buffs_process)
				end
				
				DetailsRaidCheck.tracking_buffs_process = DetailsRaidCheck:ScheduleRepeatingTimer ("BuffTrackTick", 1)
			end
			
		end
		
		function DetailsRaidCheck:StopTrackBuffs()
			if (DetailsRaidCheck.tracking_buffs) then
				DetailsRaidCheck.tracking_buffs = false
				
				if (DetailsRaidCheck.tracking_buffs_process) then
					DetailsRaidCheck:CancelTimer (DetailsRaidCheck.tracking_buffs_process)
				end
			else
				if (DetailsRaidCheck.tracking_buffs_process) then
					DetailsRaidCheck:CancelTimer (DetailsRaidCheck.tracking_buffs_process)
				end
			end
		end

	end

local build_options_panel = function()

	local options_frame = DetailsRaidCheck:CreatePluginOptionsFrame ("DetailsRaidCheckOptionsWindow", "Details Raid Check Options", 1)

	local menu = {
		{
			type = "toggle",
			get = function() return DetailsRaidCheck.db.pre_pot_healers end,
			set = function (self, fixedparam, value) DetailsRaidCheck.db.pre_pot_healers = value end,
			desc = "If enabled, pre potion for healers are also shown.",
			name = "Track Healers Pre Pot"
		},
		{
			type = "toggle",
			get = function() return DetailsRaidCheck.db.pre_pot_tanks end,
			set = function (self, fixedparam, value) DetailsRaidCheck.db.pre_pot_tanks = value end,
			desc = "If enabled, pre potion for tanks are also shown.",
			name = "Track Tank Pre Pot"
		},
		{
			type = "toggle",
			get = function() return DetailsRaidCheck.db.mythic_1_4 end,
			set = function (self, fixedparam, value) DetailsRaidCheck.db.mythic_1_4 = value end,
			desc = "When raiding on Mythic difficult, only tracks the first 4 groups.",
			name = "Mythic Special Tracker"
		},
		{
			type = "toggle",
			get = function() return DetailsRaidCheck.db.use_report_panel end,
			set = function (self, fixedparam, value) DetailsRaidCheck.db.use_report_panel = value end,
			desc = "If enabled, clicking to report open the report panel instead (to be able to choose where to send the report).",
			name = "Use Report Panel"
		},
		
		{
			type = "toggle",
			get = function() return DetailsRaidCheck.db.food_tier1 end,
			set = function (self, fixedparam, value) DetailsRaidCheck.db.food_tier1 = value end,
			desc = "Consider players using Tier 1 food.",
			name = "Food Tier 1 [41]"
		},
		{
			type = "toggle",
			get = function() return DetailsRaidCheck.db.food_tier2 end,
			set = function (self, fixedparam, value) DetailsRaidCheck.db.food_tier2 = value end,
			desc = "Consider players using Tier 2 food.",
			name = "Food Tier 2 [55]"
		},
		{
			type = "toggle",
			get = function() return DetailsRaidCheck.db.food_tier3 end,
			set = function (self, fixedparam, value) DetailsRaidCheck.db.food_tier3 = value end,
			desc = "Consider players using Tier 3 food.",
			name = "Food Tier 3 [>= 75]"
		},
	}
	
	_detalhes.gump:BuildMenu (options_frame, menu, 15, -65, 180)

end

DetailsRaidCheck.OpenOptionsPanel = function()
	if (not DetailsRaidCheckOptionsWindow) then
		build_options_panel()
	end
	DetailsRaidCheckOptionsWindow:Show()
end
	
	function DetailsRaidCheck:OnEvent (_, event, ...)

		if (event == "ADDON_LOADED") then
			local AddonName = select (1, ...)
			if (AddonName == "Details_RaidCheck") then
				
				if (_G._detalhes) then

					--> create widgets
					CreatePluginFrames()

					--> core version required
					local MINIMAL_DETAILS_VERSION_REQUIRED = 20
					
					local default_settings = {
						pre_pot_healers = false, --do not report pre pot for healers
						pre_pot_tanks = false, --do not report pre pot for tanks
						mythic_1_4 = true, --only track groups 1-4 on mythic
						use_report_panel = true, --if true, shows the report panel
						
						food_tier1 = true, --legion food tiers
						food_tier2 = true,
						food_tier3 = true,
					}
					
					--> install
					local install, saveddata, is_enabled = _G._detalhes:InstallPlugin ("TOOLBAR", Loc ["STRING_RAIDCHECK_PLUGIN_NAME"], [[Interface\AddOns\Details_RaidCheck\icon]], DetailsRaidCheck, "DETAILS_PLUGIN_RAIDCHECK", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", version, default_settings)
					if (type (install) == "table" and install.error) then
						return print (install.error)
					end
					
					--> register needed events
					
					_G._detalhes:RegisterEvent (DetailsRaidCheck, "COMBAT_PLAYER_LEAVE")
					_G._detalhes:RegisterEvent (DetailsRaidCheck, "COMBAT_PLAYER_ENTER")
					_G._detalhes:RegisterEvent (DetailsRaidCheck, "COMBAT_PREPOTION_UPDATED")
					_G._detalhes:RegisterEvent (DetailsRaidCheck, "ZONE_TYPE_CHANGED")
					
				end
			end
		end
	end	
	
-- doo