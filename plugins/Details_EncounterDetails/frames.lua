do
	local addonId, edTable = ...
	local Details = _G._detalhes
	local AceLocale = LibStub("AceLocale-3.0")
	local Loc = AceLocale:GetLocale("Details_EncounterDetails")
	local Graphics = LibStub:GetLibrary("LibGraph-2.0")
	local ipairs = ipairs
	local _GetSpellInfo = Details.getspellinfo
	local unpack = unpack
	local detailsFramework = DetailsFramework
	local CreateFrame = CreateFrame
	local GameCooltip = GameCooltip
	local _

	Details.EncounterDetailsTempWindow = function(encounterDetails)
		--options panel
		encounterDetails.SetBarBackdrop_OnEnter = function(self)
			self:SetBackdropColor(unpack(edTable.defaultBackgroundColor_OnEnter))
		end

		encounterDetails.SetBarBackdrop_OnLeave = function(self)
			self:SetBackdropColor(unpack(edTable.defaultBackgroundColor))
		end

		function encounterDetails:AutoShowIcon()
			local bFoundBoss = false
			for _, combatObject in ipairs(encounterDetails:GetCombatSegments()) do
				---@cast combatObject combat
				if (combatObject.is_boss) then
					encounterDetails:ShowIcon()
					bFoundBoss = true
				end
			end

			if (encounterDetails:GetCurrentCombat().is_boss) then
				encounterDetails:ShowIcon()
				bFoundBoss = true
			end

			if (not bFoundBoss) then
				encounterDetails:HideIcon()
			end
		end

		local buildOptionsPanel = function()
			local pluginIcon = "Interface\\AddOns\\Details_EncounterDetails\\images\\icon"
			local pluginIconCoords = {0.15, 0.85, 0.15, 0.85}
			local optionsFrame = encounterDetails:CreatePluginOptionsFrame("EncounterDetailsOptionsWindow", "Encounter Breakdown Options", 3, pluginIcon, pluginIconCoords)
			-- 1 = only when inside a raid map
			-- 2 = only when in raid group
			-- 3 = only after a boss encounter
			-- 4 = always show
			-- 5 = automatic show when have at least 1 encounter with boss

			local onShowIconCallback = function(_, _, value)
				encounterDetails.db.show_icon = value
				if (value == 1) then
					if (encounterDetails:GetZoneType() == "raid") then
						encounterDetails:ShowIcon()
					else
						encounterDetails:HideIcon()
					end

				elseif (value == 2) then
					if (encounterDetails:InGroup()) then
						encounterDetails:ShowIcon()
					else
						encounterDetails:HideIcon()
					end

				elseif (value == 3) then
					if (encounterDetails:GetCurrentCombat().is_boss) then
						encounterDetails:ShowIcon()
					else
						encounterDetails:HideIcon()
					end

				elseif (value == 4) then
					encounterDetails:ShowIcon()

				elseif (value == 5) then
					encounterDetails:AutoShowIcon()
				end
			end

			local on_show_menu = {
				{value = 1, label = "Inside Raid", onclick = onShowIconCallback, desc = "Only show the icon while inside a raid."},
				{value = 2, label = "In Group", onclick = onShowIconCallback, desc = "Only show the icon while in group."},
				{value = 3, label = "After Encounter", onclick = onShowIconCallback, desc = "Show the icon after a raid boss encounter."},
				{value = 4, label = "Always", onclick = onShowIconCallback, desc = "Always show the icon."},
				{value = 5, label = "Auto", onclick = onShowIconCallback, desc = "The plugin decides when the icon needs to be shown."},
			}

			--/dump DETAILS_PLUGIN_ENCOUNTER_DETAILS.db.show_icon

			local menu = {
				{
					type = "select",
					get = function() return encounterDetails.db.show_icon end,
					values = function() return on_show_menu end,
					desc = "When the icon is shown in the Details! tooltip.",
					name = "Show Icon"
				},
				{
					type = "toggle",
					get = function() return encounterDetails.db.hide_on_combat end,
					set = function(self, fixedparam, value) encounterDetails.db.hide_on_combat = value end,
					desc = "Encounter Breakdown window automatically close when you enter in combat.",
					name = "Hide on Combat"
				},
				{
					type = "range",
					get = function() return encounterDetails.db.max_emote_segments end,
					set = function(self, fixedparam, value) encounterDetails.db.max_emote_segments = value end,
					min = 1,
					max = 10,
					step = 1,
					desc = "Keep how many segments emotes.",
					name = "Emote Segments Amount",
					usedecimals = true,
				},
				{
					type = "range",
					get = function() return encounterDetails.db.window_scale end,
					set = function(self, fixedparam, value) encounterDetails.db.window_scale = value; encounterDetails:RefreshScale() end,
					min = 0.65,
					max = 1.50,
					step = 0.1,
					desc = "Set the window size",
					name = "Window Scale",
					usedecimals = true,
				},

			}

			local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
			local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
			local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
			local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
			local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

			detailsFramework:BuildMenu(optionsFrame, menu, 15, -75, 260, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
		end

		encounterDetails.OpenOptionsPanel = function()
			if (not EncounterDetailsOptionsWindow) then
				buildOptionsPanel()
			end
			EncounterDetailsOptionsWindow:Show()
		end

		function encounterDetails:RefreshScale()
			local scale = encounterDetails.db.window_scale
			if (encounterDetails.Frame) then
				encounterDetails.Frame:SetScale(scale)
			end
		end

		-- ~start ~main ~frame ~baseframe ~bossframe
		local edFrame = encounterDetails.Frame
		detailsFramework:ApplyStandardBackdrop(edFrame)
		edFrame:SetFrameStrata("high")
		edFrame:SetToplevel(true)
		edFrame:SetWidth(898)
		edFrame:SetHeight(504)
		edFrame:EnableMouse(true)
		edFrame:SetResizable(false)
		edFrame:SetMovable(true)
		edFrame:SetPoint("center", UIParent, "center", 0, 0)

		--background
		edFrame.bosFrameBackgroundTexture = edFrame:CreateTexture(nil, "background")
		edFrame.bosFrameBackgroundTexture:SetTexture([[Interface\AddOns\Details\images\background]], true)
		edFrame.bosFrameBackgroundTexture:SetAlpha(0.7)
		edFrame.bosFrameBackgroundTexture:SetVertexColor(0.27, 0.27, 0.27)
		edFrame.bosFrameBackgroundTexture:SetVertTile(true)
		edFrame.bosFrameBackgroundTexture:SetHorizTile(true)
		edFrame.bosFrameBackgroundTexture:SetSize(790, 454)
		edFrame.bosFrameBackgroundTexture:SetAllPoints()

		--title bar
		local titleBar = detailsFramework:CreateTitleBar(edFrame, Loc ["STRING_WINDOW_TITLE"])
		titleBar.CloseButton:Hide()

		--close button
		titleBar.CloseButton = detailsFramework:CreateCloseButton(titleBar)
		titleBar.CloseButton:SetScript("OnClick", function(self)
			encounterDetails:CloseWindow()
		end)

		titleBar.CloseButton:SetPoint("right", titleBar, "right", -2, 0)

		--header background
		local headerFrame = CreateFrame("frame", "EncounterDetailsHeaderFrame", edFrame, "BackdropTemplate")
		headerFrame:EnableMouse(false)
		headerFrame:SetPoint("topleft", titleBar, "bottomleft", -1, -1)
		headerFrame:SetPoint("topright", titleBar, "bottomright", 1, -1)
		headerFrame:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
		headerFrame:SetBackdropColor(.7, .7, .7, .4)
		headerFrame:SetHeight(48)

		edFrame.raidBackgroundTexture = edFrame:CreateTexture(nil, "border")
		edFrame.raidBackgroundTexture:SetPoint("topleft", edFrame, "topleft", 0, -74)
		edFrame.raidBackgroundTexture:SetPoint("bottomright", edFrame, "bottomright", 0, 0)
		edFrame.raidBackgroundTexture:SetDrawLayer("border", 2)
		edFrame.raidBackgroundTexture:SetAlpha(0.1)

		local gradientBelow = detailsFramework:CreateTexture(headerFrame,
		{gradient = "vertical", fromColor = {0, 0, 0, 0.5}, toColor = "transparent"}, 1, 48, "artwork", {0, 1, 0, 1})
		gradientBelow:SetPoint("bottoms", 1, 1)

		--boss icon in the top left corner
		edFrame.bossIcon = headerFrame:CreateTexture(nil, "overlay")
		edFrame.bossIcon:SetPoint("topleft", edFrame, "topleft", 9, -24)
		edFrame.bossIcon:SetWidth(46)
		edFrame.bossIcon:SetHeight(46)

		--raid name
		detailsFramework:NewLabel(headerFrame, headerFrame, nil, "raidNameLabel", "Unknown Raid", "GameFontHighlightSmall")
		edFrame.raidNameLabel = headerFrame.raidNameLabel
		edFrame.raidNameLabel:SetPoint("topleft", edFrame, "topleft", 60, -34)

		--encounter name
		detailsFramework:NewLabel(headerFrame, headerFrame, nil, "bossNameLabel", "Unknown Encounter", "QuestFont_Large")
		edFrame.bossNameLabel = headerFrame.bossNameLabel
		edFrame.bossNameLabel:SetPoint("topleft", edFrame.raidNameLabel, "bottomleft", 0, -2)

		edFrame.bossIcon:Hide()
		edFrame.raidNameLabel.show = false
		edFrame.bossNameLabel.show = false

		edFrame:SetScript("OnMouseDown", function(self, button)
			if (button == "LeftButton") then
				self:StartMoving()
				self.isMoving = true

			elseif (button == "RightButton" and not self.isMoving) then
				encounterDetails:CloseWindow()
			end
		end)

		edFrame:SetScript("OnMouseUp", function(self)
			if (self.isMoving) then
				self:StopMovingOrSizing()
				self.isMoving = false
			end
		end)

		edFrame.ShowType = "main"

		--> revisar
		edFrame.Reset = function()
			edFrame.switch(nil, nil, "main")
			if (encounterDetails.chartPanel) then
				encounterDetails.chartPanel:ResetData()
			end
			edFrame.linhas = nil
		end

		local hide_Graph = function()
			if (encounterDetails.chartPanel) then
				encounterDetails.chartPanel:Hide()
			end
		end

		local hide_Emote = function()
			for _, widget in pairs(edFrame.EmoteWidgets) do
				widget:Hide()
			end
		end

		local hide_Summary = function()
			for _, frame in ipairs(edFrame.encounterSummaryWidgets) do
				frame:Hide()

				frame:SetScript("OnShow", function()
					--print(debugstack())
				end)
			end
		end

		local resetSelectedButtonTemplate = function()
			edFrame.buttonSwitchNormal:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			edFrame.buttonSwitchPhases:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			edFrame.buttonSwitchGraphic:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			edFrame.buttonSwitchBossEmotes:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		end

		edFrame.switch = function(buttonObject, _, tabName)
			local tabSelected
			if (type(buttonObject) == "string") then
				tabSelected = buttonObject

			elseif (type(tabName) == "string") then
				tabSelected = tabName
			end

			if (not edFrame:IsShown()) then
				Details:OpenPlugin("DETAILS_PLUGIN_ENCOUNTER_DETAILS")
			end

			EncounterDetailsPhaseFrame:Hide()
			resetSelectedButtonTemplate()

			if (tabSelected == "main") then
				edFrame.raidBackgroundTexture:Show()

				for _, frame in ipairs(edFrame.encounterSummaryWidgets) do
					frame:Show()
				end

				hide_Graph()
				hide_Emote()

				edFrame.ShowType = "main"
				edFrame.segmentsDropdown:Enable()
				edFrame.buttonSwitchNormal:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE"))
				encounterDetails.db.last_section_selected = edFrame.ShowType

				if (encounterDetails.LastSegmentShown) then
					encounterDetails.RefreshSummaryPage(encounterDetails.LastSegmentShown)
				else
					encounterDetails.RefreshSummaryPage(Details:GetCurrentCombat())
				end

			elseif (tabSelected == "emotes") then
				Details:SetTutorialCVar("ENCOUNTER_BREAKDOWN_EMOTES", true)
				if (encounterDetails.Frame.buttonSwitchBossEmotes.AntsFrame) then
					encounterDetails.Frame.buttonSwitchBossEmotes.AntsFrame:Hide()
				end

				--hide boss frames
				for _, frame in ipairs(edFrame.encounterSummaryWidgets) do
					frame:Hide()
				end

				edFrame.raidBackgroundTexture:Show()

				--hide graph
				if (encounterDetails.chartPanel) then
					encounterDetails.chartPanel:Hide()
				end

				--show emote frames
				for _, widget in pairs(edFrame.EmoteWidgets) do
					widget:Show()
				end

				edFrame.ShowType = "emotes"
				encounterDetails.EmoteScrollFrame:Update()
				edFrame.EmotesSegment:Refresh()
				edFrame.EmotesSegment:Select(encounterDetails.emoteSegmentIndex)
				edFrame.segmentsDropdown:Disable()
				edFrame.buttonSwitchBossEmotes:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE"))
				encounterDetails.db.last_section_selected = edFrame.ShowType

			elseif (tabSelected == "phases") then
				Details:SetTutorialCVar("ENCOUNTER_BREAKDOWN_PHASES", true)
				if (encounterDetails.Frame.buttonSwitchPhases.AntsFrame) then
					encounterDetails.Frame.buttonSwitchPhases.AntsFrame:Hide()
				end

				hide_Summary()
				hide_Graph()
				hide_Emote()

				edFrame.ShowType = "phases"

				EncounterDetailsPhaseFrame:Show()

				edFrame.buttonSwitchPhases:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE"))

				encounterDetails.db.last_section_selected = edFrame.ShowType

			elseif (tabSelected == "graph") then
				Details:SetTutorialCVar("ENCOUNTER_BREAKDOWN_CHART", true)
				if (encounterDetails.Frame.buttonSwitchGraphic.AntsFrame) then
					encounterDetails.Frame.buttonSwitchGraphic.AntsFrame:Hide()
				end

				encounterDetails:ShowChartFrame()

				if (not encounterDetails.chartPanel) then
					return
				end

				edFrame.raidBackgroundTexture:Hide()

				for _, frame in ipairs(edFrame.encounterSummaryWidgets) do
					frame:Hide()
				end

				encounterDetails.chartPanel:Show()
				edFrame.ShowType = "graph"

				--hide emote frames
				for _, widget in pairs(edFrame.EmoteWidgets) do
					widget:Hide()
				end

				edFrame.segmentsDropdown:Enable()
				edFrame.buttonSwitchGraphic:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE"))
				encounterDetails.db.last_section_selected = edFrame.ShowType
			end
		end

		-- ~button ~menu
		local BUTTON_WIDTH = 120
		local BUTTON_HEIGHT = 20
		local HEADER_MENUBUTTONS_SPACEMENT = 4
		local HEADER_MENUBUTTONS_X = 290
		local HEADER_MENUBUTTONS_Y = -38

		--create selection tab buttons
		do
			--summary
			edFrame.buttonSwitchNormal = detailsFramework:CreateButton(edFrame, edFrame.switch, BUTTON_WIDTH, BUTTON_HEIGHT, "Summary", "main")
			edFrame.buttonSwitchNormal:SetIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 18, 18, "overlay", {0, 32/256, 0, 0.505625})
			edFrame.buttonSwitchNormal:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE"))
			edFrame.buttonSwitchNormal:SetWidth(BUTTON_WIDTH)
				--summary for the breakdown window
				edFrame.buttonSwitchNormalBreakdown = detailsFramework:CreateButton(edFrame, edFrame.switch, BUTTON_WIDTH, BUTTON_HEIGHT, "Summary", "main")
				edFrame.buttonSwitchNormalBreakdown:SetIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 18, 18, "overlay", {0, 32/256, 0, 0.505625})
				edFrame.buttonSwitchNormalBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE"))
				edFrame.buttonSwitchNormalBreakdown:SetWidth(BUTTON_WIDTH)
				_G.DetailsBreakdownWindow.RegisterPluginButton(edFrame.buttonSwitchNormalBreakdown, edTable.PluginObject, edTable.PluginAbsoluteName)

			--phases
			edFrame.buttonSwitchPhases = detailsFramework:CreateButton(edFrame, edFrame.switch, BUTTON_WIDTH, BUTTON_HEIGHT, "Phases", "phases")
			edFrame.buttonSwitchPhases:SetIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 18, 18, "overlay", {65/256, 96/256, 0, 0.505625})
			edFrame.buttonSwitchPhases:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			edFrame.buttonSwitchPhases:SetWidth(BUTTON_WIDTH)
				--phases for the breakdown window
				edFrame.buttonSwitchPhasesBreakdown = detailsFramework:CreateButton(edFrame, edFrame.switch, BUTTON_WIDTH, BUTTON_HEIGHT, "Phases", "phases")
				edFrame.buttonSwitchPhasesBreakdown:SetIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 18, 18, "overlay", {65/256, 96/256, 0, 0.505625})
				edFrame.buttonSwitchPhasesBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
				edFrame.buttonSwitchPhasesBreakdown:SetWidth(BUTTON_WIDTH)
				_G.DetailsBreakdownWindow.RegisterPluginButton(edFrame.buttonSwitchPhasesBreakdown, edTable.PluginObject, edTable.PluginAbsoluteName)

			--chart
			edFrame.buttonSwitchGraphic = detailsFramework:CreateButton(edFrame, edFrame.switch, BUTTON_WIDTH, BUTTON_HEIGHT, "Damage Graphic", "graph")
			edFrame.buttonSwitchGraphic:SetIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 18, 18, "overlay", {97/256, 128/256, 0, 0.505625})
			edFrame.buttonSwitchGraphic:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			edFrame.buttonSwitchGraphic:SetWidth(BUTTON_WIDTH)
				--charts for the breakdown window
				edFrame.buttonSwitchGraphicBreakdown = detailsFramework:CreateButton(edFrame, edFrame.switch, BUTTON_WIDTH, BUTTON_HEIGHT, "Damage Graphic", "graph")
				edFrame.buttonSwitchGraphicBreakdown:SetIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 18, 18, "overlay", {97/256, 128/256, 0, 0.505625})
				edFrame.buttonSwitchGraphicBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
				edFrame.buttonSwitchGraphicBreakdown:SetWidth(BUTTON_WIDTH)
				_G.DetailsBreakdownWindow.RegisterPluginButton(edFrame.buttonSwitchGraphicBreakdown, edTable.PluginObject, edTable.PluginAbsoluteName)

			--emotes
			edFrame.buttonSwitchBossEmotes = detailsFramework:CreateButton(edFrame, edFrame.switch, BUTTON_WIDTH, BUTTON_HEIGHT, "Emotes", "emotes")
			edFrame.buttonSwitchBossEmotes:SetIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 18, 18, "overlay", {129/256, 160/256, 0, 0.505625})
			edFrame.buttonSwitchBossEmotes:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			edFrame.buttonSwitchBossEmotes:SetWidth(BUTTON_WIDTH)
				--emotes for the breakdown window
				edFrame.buttonSwitchBossEmotesBreakdown = detailsFramework:CreateButton(edFrame, edFrame.switch, BUTTON_WIDTH, BUTTON_HEIGHT, "Emotes", "emotes")
				edFrame.buttonSwitchBossEmotesBreakdown:SetIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 18, 18, "overlay", {129/256, 160/256, 0, 0.505625})
				edFrame.buttonSwitchBossEmotesBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
				edFrame.buttonSwitchBossEmotesBreakdown:SetWidth(BUTTON_WIDTH)
				_G.DetailsBreakdownWindow.RegisterPluginButton(edFrame.buttonSwitchBossEmotesBreakdown, edTable.PluginObject, edTable.PluginAbsoluteName)

			--anchors
			edFrame.buttonSwitchNormal:SetPoint("topleft", edFrame, "topleft", 5, -26)
			edFrame.buttonSwitchPhases:SetPoint("left", edFrame.buttonSwitchNormal, "right", HEADER_MENUBUTTONS_SPACEMENT, 0)
			edFrame.buttonSwitchGraphic:SetPoint("topleft", edFrame.buttonSwitchNormal, "bottomleft", 0, -3)
			edFrame.buttonSwitchBossEmotes:SetPoint("left", edFrame.buttonSwitchGraphic, "right", HEADER_MENUBUTTONS_SPACEMENT, 0)

			edFrame.AllButtons = {edFrame.buttonSwitchNormal, edFrame.buttonSwitchGraphic, edFrame.buttonSwitchBossEmotes, edFrame.buttonSwitchPhases}
		end

		--segment selection
		C_Timer.After(5, function()
			local buildSegmentosMenu = function(self)
				local segmentList = Details:GetCombatSegments()
				local resultTable = {}

				for index, combate in ipairs(segmentList) do
					if (combate.is_boss and combate.is_boss.index) then
						local bossIcon = Details:GetBossEncounterTexture(combate.is_boss.id or combate.is_boss.encounter or combate.is_boss.name)
						resultTable[#resultTable+1] = {
							value = index,
							label = "#" .. index .. " " .. (combate.is_boss.encounter or combate.is_boss.name or _G["UNKNOWN"]),
							icon = bossIcon,
							iconsize = {32, 20},
							texcoord = {0, 1, 0, 0.9},
							onclick = encounterDetails.OpenAndRefresh
						}
					end
				end

				return resultTable
			end

			--space between the 4 tab buttons and the segments and macro frames
			local xSpacement = 20
			--~dropdown
			local segmentDropdown = detailsFramework:NewDropDown(edFrame, _, "$parentSegmentsDropdown", "segmentsDropdown", 218, 20, buildSegmentosMenu, nil)
			segmentDropdown:SetPoint("left", edFrame.buttonSwitchPhases, "right", xSpacement, 0)
			segmentDropdown:SetTemplate(detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

			--options button
			local optionsButton = detailsFramework:NewButton(edFrame, nil, "$parentOptionsButton", "OptionsButton", 120, 20, encounterDetails.OpenOptionsPanel, nil, nil, nil, "Options")
			optionsButton:SetPoint("left", segmentDropdown, "right", 10, 0)
			optionsButton:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			optionsButton:SetIcon([[Interface\Buttons\UI-OptionsButton]], 14, 14, nil, {0, 1, 0, 1}, nil, 3)
		end)

		--macro box
		edFrame.MacroEditBox = detailsFramework:CreateTextEntry(edFrame, function()end, 300, 20)
		edFrame.MacroEditBox:SetPoint("left", edFrame.buttonSwitchBossEmotes, "right", xSpacement, 0)
		edFrame.MacroEditBox:SetAlpha(0.7)
		edFrame.MacroEditBox:SetText("/run Details:OpenPlugin('Encounter Breakdown')")
		edFrame.MacroEditBox:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		edFrame.MacroEditBox:SetSize(348, 20)

		edFrame.MacroEditBox:HookScript("OnEditFocusGained", function()
			C_Timer.After(0, function() edFrame.MacroEditBox:HighlightText() end)
		end)

		edFrame.MacroEditBox.BackgroundLabel = detailsFramework:CreateLabel(edFrame.MacroEditBox, "macro")
		edFrame.MacroEditBox.BackgroundLabel:SetPoint("left", edFrame.MacroEditBox, "left", 6, 0)
		edFrame.MacroEditBox.BackgroundLabel:SetTextColor(.3, .3, .3, .98)
	end
end