
--this file controls the left panel of the breakdown window, where the player list and plugins are shown
---@type details
local Details = _G.Details

---@class detailsframework
local detailsFramework = _G.DetailsFramework

local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
local addonName, Details222 = ...

local breakdownWindowPlayerList = {}

local unpack = table.unpack or unpack
local C_Timer = _G.C_Timer
local tinsert = table.insert
local CreateFrame = CreateFrame
local GetSpecializationInfoByID = GetSpecializationInfoByID
local PixelUtil = PixelUtil

local scrollbox_size = {215, 405}
local scrollbox_lines = 20
local player_line_height = 20
local scrollbox_line_backdrop_color = {0.2, 0.2, 0.2, 0.5}
local scrollbox_line_backdrop_color_selected = {1, 1, 0, 0.45}
local scrollbox_line_backdrop_color_highlight = {.9, .9, .9, 0.5}
local player_scroll_size = {195, 288}

---@type table<uniquecombatid, actorname>
local lastSelectedPlayerPerSegment = {}

---@type actorname
local lastSelectedPlayerName = ""

local onPlayerSelected = function(breakdownWindowFrame, playerObject)
	---@type instance
	local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
	Details:OpenBreakdownWindow(instanceObject, playerObject, false, true)

	--cache the latest selected player for this combat
	---@type combat
	local combatObject = instanceObject:GetCombat()
	---@type actorname
	local playerName = playerObject:Name()

	lastSelectedPlayerPerSegment[combatObject:GetCombatUID()] = playerName
	lastSelectedPlayerName = playerName

	breakdownWindowFrame.playerScrollBox:Refresh()
end

local getActorToShowInBreakdownWindow = function(combatObject)
	---@type breakdownwindow
	local breakdownWindowFrame = Details.BreakdownWindowFrame

	--when the select is selected, figure out which player need to be selected in the playerScroll
	---@type instance
	local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
	---@type uniquecombatid
	local combatUID = combatObject:GetCombatUID()

	local displayId, subDisplayId = instanceObject:GetDisplay()

	---@type actorname
	local playerName = lastSelectedPlayerPerSegment[combatUID]

	if (playerName) then
		---@type actor
		local playerObject = combatObject:GetActor(displayId, playerName)
		return playerObject
	else
		---@type actor
		local playerObject = combatObject:GetActor(displayId, lastSelectedPlayerName)
		if (playerObject) then
			lastSelectedPlayerPerSegment[combatUID] = playerObject:Name()
			return playerObject
		else
			playerObject = combatObject:GetActor(displayId, Details.playername)
			if (playerObject) then
				lastSelectedPlayerPerSegment[combatUID] = playerObject:Name()
				return playerObject
			end

			--get the top player from the combat display and subDisplay and select it
			---@type actor
			local actorObject = instanceObject:GetActorBySubDisplayAndRank(displayId, subDisplayId, 1)
			if (actorObject) then
				lastSelectedPlayerPerSegment[combatUID] = actorObject:Name()
				return actorObject
			end
		end
	end
end

---this function get the list of active plugins which has a frame to show in the breakdown window and create a button for each one
---@param breakdownWindowFrame breakdownwindow
---@param pluginsFrame frame
---@param breakdownSideMenu frame
---@return number height how much space pluginsFrame is using
local refreshPluginButtons = function(breakdownWindowFrame, pluginsFrame, breakdownSideMenu)
	local amountPluginButtons = #breakdownWindowFrame.RegisteredPluginButtons
	local pluginButtonHeight = 20
	local spacingBetweenButtons = 1
	local totalHeight = 0

	for i = 1, amountPluginButtons do
		---@type button
		local pluginButton = breakdownWindowFrame.RegisteredPluginButtons[i]
		pluginButton:Show()
		PixelUtil.SetSize(pluginButton, pluginsFrame:GetWidth() - 4, pluginButtonHeight)
		pluginButton:ClearAllPoints()

		if (i == 1) then
			PixelUtil.SetPoint(pluginButton, "topleft", pluginsFrame, "topleft", 2, -22)
		else
			PixelUtil.SetPoint(pluginButton, "topleft", breakdownWindowFrame.RegisteredPluginButtons[i - 1], "bottomleft", 0, -spacingBetweenButtons)
		end

		local fontString = _G[pluginButton:GetName() .. "_Text"]
		Details222.BreakdownWindow.ApplyFontSettings(fontString)

		totalHeight = totalHeight + pluginButtonHeight + spacingBetweenButtons
	end

	--add the height of the header and the spacing between the header and the first button and the last button and the bottom of the frame
	totalHeight = totalHeight + 20 + 2

	pluginsFrame:SetPoint("topleft", breakdownSideMenu, "topleft", 0, 0)
	pluginsFrame:SetWidth(breakdownSideMenu:GetWidth())
	pluginsFrame:SetHeight(amountPluginButtons * pluginButtonHeight + 22 + (amountPluginButtons * 1))

	return totalHeight
end

local createPlayerScrollBox = function(breakdownWindowFrame, breakdownSideMenu, playerSelectionHeaderFrame)
	local refreshPlayerScrollFunc = function(self, data, offset, totalLines)
		local topResult = data[1]
		if (topResult) then
			topResult = topResult.total
		end

		---@type combat
		local combatObject = Details:GetCombatFromBreakdownWindow()
		local encounterId = combatObject:GetEncounterCleuID()
		local difficultyId = combatObject:GetDifficulty()

		for i = 1, totalLines do --~refresh
			local index = i + offset
			local playerObject = data[index]
			if (playerObject) then
				local line = self:GetLine(i)
				if (line) then
					line.playerObject = playerObject
					line.combatObject = combatObject
					line.index = index
					line:UpdateLine(topResult, encounterId, difficultyId)
				end
			end
		end
	end

	local lineOnClick = function(self)
		if (self.playerObject ~= Details:GetActorObjectFromBreakdownWindow() or breakdownWindowFrame.shownPluginObject) then
			onPlayerSelected(breakdownWindowFrame, self.playerObject)
		end
	end

	local lineOnEnter = function(self)
		self:SetBackdropColor(unpack(scrollbox_line_backdrop_color_highlight))
		self.specIcon:SetBlendMode("ADD")
		self.roleIcon:SetBlendMode("ADD")
	end

	local lineOnLeave = function(self)
		if (self.isSelected) then
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color_selected))
		else
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color))
		end
		self.specIcon:SetBlendMode("BLEND")
		self.roleIcon:SetBlendMode("BLEND")
	end

	local updatePlayerLine = function(self, topResult, encounterId, difficultyId) --~update
		local playerSelected = lastSelectedPlayerName
		local playerInTheLine = self.playerObject

		--checking if the playerObject is still valid, it could have been removed by the garbage collector
		if (not Details:IsValidActor(playerInTheLine)) then
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color))
			self.specIcon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
			self.playerName:SetText("")
			return
		end

		if (playerSelected == self.playerObject:Name()) then
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color_selected))
			self.isSelected = true
		else
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color))
			self.isSelected = nil
		end

		local specRole

		--adjust the player icon
		if (self.playerObject.spellicon) then
			self.specIcon:SetTexture(self.playerObject.spellicon)
			self.specIcon:SetTexCoord(.1, .9, .1, .9)
		else
			local specIcon, L, R, T, B = Details:GetSpecIcon(self.playerObject.spec, false)

			if (specIcon) then
				self.specIcon:SetTexture(specIcon)
				self.specIcon:SetTexCoord(L, R, T, B)

				if (DetailsFramework.IsTimewalkWoW()) then
					specRole = "NONE"
				else
					---@type number
					local spec = self.playerObject.spec
					if (spec) then
						specRole = select(5, GetSpecializationInfoByID(self.playerObject.spec))
					end
				end
			else
				self.specIcon:SetTexture("")
			end
		end

		--adjust the role icon
		if (specRole) then
			local roleIcon, L, R, T, B = Details:GetRoleIcon(specRole)
			if (roleIcon) then
				self.roleIcon:SetTexture(roleIcon)
				self.roleIcon:SetTexCoord(L, R, T, B)
			else
				self.roleIcon:SetTexture("")
			end
		else
			self.roleIcon:SetTexture("")
		end

		local playerGear = openRaidLib and openRaidLib.GetUnitGear(self.playerObject.nome)

		--do not show the role icon
		self.roleIcon:SetTexture("") --not in use

		--set the player name
		self.playerName:SetText(Details:GetOnlyName(self.playerObject.nome))
		self.rankText:SetText(self.index) --not in use

		--item level
		local itemLevel = Details.ilevel:GetIlvl(self.playerObject.serial)
		self.itemLevelText:SetText((itemLevel and itemLevel.ilvl and math.floor(itemLevel.ilvl)) or (self.playerObject.ilvl) or (playerGear and playerGear.ilevel) or "0")

		local actorSpecId = self.playerObject.spec
		local actorTotal = self.playerObject.total
		local combatObject = self.combatObject

		--warcraftlogs percentile
		if (self.playerObject.tipo == DETAILS_ATTRIBUTE_DAMAGE) then
			local actorDPS = self.playerObject.total / combatObject:GetCombatTime()

			local parsePercent = Details222.WarcraftLogs.GetDamageParsePercent(encounterId, difficultyId, actorSpecId, actorDPS)
			if (parsePercent) then
				parsePercent =  math.floor(parsePercent)
				local colorName = Details222.WarcraftLogs.GetParseColor(parsePercent)
				self.percentileText:SetTextColor(detailsFramework:ParseColors(colorName))
				self.percentileText:SetText(math.floor(parsePercent))
				self.percentileText.alpha = 1
			else
				parsePercent = Details222.ParsePercent.GetPercent(DETAILS_ATTRIBUTE_DAMAGE, difficultyId, encounterId, actorSpecId, actorDPS)
				if (parsePercent) then
					parsePercent =  math.floor(parsePercent)
					local colorName = Details222.WarcraftLogs.GetParseColor(parsePercent)
					self.percentileText:SetTextColor(detailsFramework:ParseColors(colorName))
					self.percentileText:SetText(math.floor(parsePercent))
					self.percentileText.alpha = 1
				else
					self.percentileText:SetText("#.def")
					self.percentileText:SetAlpha(0.25)
				end
			end
		else
			self.percentileText:SetText("#.def")
			self.percentileText:SetAlpha(0.25)
		end

		Details222.BreakdownWindow.ApplyFontSettings(self.playerName)
		Details222.BreakdownWindow.ApplyFontSettings(self.itemLevelText)
		Details222.BreakdownWindow.ApplyFontSettings(self.percentileText)

		Details222.BreakdownWindow.ApplyTextureSettings(self.totalStatusBar)

		--set the statusbar
		local r, g, b = self.playerObject:GetClassColor()
		self.totalStatusBar:SetStatusBarColor(r, g, b, 1)
		self.totalStatusBar:SetMinMaxValues(0, topResult)
		self.totalStatusBar:SetValue(actorTotal)
	end

	--get a Details! window
	local lowerInstanceId = Details:GetLowerInstanceNumber()
	local fontFile
	local fontSize
	local fontOutline

	--header setup
	local headerTable = {
		{text = "", width = 20},
		{text = "Player Name", width = 100},
		{text = "iLvL", width = 30},
		{text = "WCL Parse", width = 60},
	}
	local headerOptions = {
		padding = 2,
	}

	if (lowerInstanceId) then
		local instance = Details:GetInstance(lowerInstanceId)
		if (instance) then
			fontFile = instance.row_info.font_face
			fontSize = instance.row_info.font_size
			fontOutline = instance.row_info.textL_outline
		end
	end

	local createPlayerLine = function(self, index)
		--create a new line
		local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
		detailsFramework:SetTemplate(line, "STANDARD_GRAY")

		detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

		---@type frame
		local OTTFrame = CreateFrame("frame", nil, line)
		OTTFrame:SetFrameLevel(line:GetFrameLevel()+2)
		OTTFrame:SetAllPoints()
		line.OTTFrame = OTTFrame

		PixelUtil.SetPoint(line, "topleft", breakdownWindowFrame.PlayerSelectionHeader, "topleft", 1, -((index) * (player_line_height+1)))
		PixelUtil.SetSize(line, scrollbox_size[1]-2, player_line_height)

		line:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		line:SetScript("OnEnter", lineOnEnter)
		line:SetScript("OnLeave", lineOnLeave)
		line:SetScript("OnClick", lineOnClick)

		local specIcon = OTTFrame:CreateTexture("$parentSpecIcon", "artwork")
		specIcon:SetSize(headerTable[1].width - 1, headerTable[1].width - 1)
		specIcon:SetAlpha(0.834)
		detailsFramework:SetMask(specIcon, Details:GetTextureAtlas("iconmask"))

		local roleIcon = OTTFrame:CreateTexture("$parentRoleIcon", "overlay")
		roleIcon:SetSize((player_line_height-2) / 2, (player_line_height-2) / 2)
		roleIcon:SetAlpha(0.71)

		local playerName = OTTFrame:CreateFontString("$parentPlayerName", "artwork", "GameFontNormal")
		playerName:SetTextColor(1, 1, 1, .9)

		local className = detailsFramework:CreateLabel(OTTFrame, "", "GameFontNormal")
		className.textcolor = {.95, .8, .2, 0}
		className.textsize = 9

		local itemLevelText = detailsFramework:CreateLabel(OTTFrame, "", "GameFontNormal")
		itemLevelText.textcolor = {1, 1, 1, .7}
		itemLevelText.textsize = 11

		local percentileText = detailsFramework:CreateLabel(OTTFrame, "", "GameFontNormal")
		percentileText.textcolor = {1, 1, 1, .7}
		percentileText.textsize = 11

		local rankText = detailsFramework:CreateLabel(OTTFrame, "", "GameFontNormal")
		rankText.textcolor = {.3, .3, .3, .7}
		rankText.textsize = fontSize

		local totalStatusBar = CreateFrame("statusbar", nil, line)
		totalStatusBar:SetSize(scrollbox_size[1]-player_line_height, player_line_height)
		totalStatusBar:SetMinMaxValues(0, 100)
		totalStatusBar:SetFrameLevel(line:GetFrameLevel()+1)
		totalStatusBar:SetAlpha(0.5)
		totalStatusBar:SetPoint("bottomleft", specIcon, "bottomright", 0, 0)

		local gradientTexture = DetailsFramework:CreateTexture(OTTFrame, {gradient = "horizontal", fromColor = {.1, .1, .1, .634}, toColor = "transparent"}, 100, 1, "border", {0, 1, 0, 1}, "segmentsGradient")
		gradientTexture:SetPoint("lefts")

		line.specIcon = specIcon
		line.roleIcon = roleIcon
		line.playerName = playerName
		line.className = className
		line.rankText = rankText
		line.totalStatusBar = totalStatusBar
		line.itemLevelText = itemLevelText
		line.percentileText = percentileText

		line:AddFrameToHeaderAlignment(specIcon)
		line:AddFrameToHeaderAlignment(playerName)
		line:AddFrameToHeaderAlignment(itemLevelText)
		line:AddFrameToHeaderAlignment(percentileText)

		line:AlignWithHeader(breakdownWindowFrame.PlayerSelectionHeader, "left")

		line.UpdateLine = updatePlayerLine

		return line
	end

	---@type width
	local width = player_scroll_size[1] + 22
	---@type height
	local height = player_scroll_size[2]

	local playerScroll = detailsFramework:CreateScrollBox(breakdownSideMenu, "DetailsBreakdownWindowPlayerScrollBox", refreshPlayerScrollFunc, {}, width, height, scrollbox_lines, player_line_height)
	detailsFramework:ReskinSlider(playerScroll)
	playerScroll.ScrollBar:ClearAllPoints()
	playerScroll.ScrollBar:SetPoint("topright", playerScroll, "topright", -2, -37)
	playerScroll.ScrollBar:SetPoint("bottomright", playerScroll, "bottomright", -2, 17)
	breakdownWindowFrame.playerScrollBox = playerScroll
	playerScroll.ScrollBar:Hide()

	--remove the standard backdrop
	playerScroll:SetBackdrop({})
	playerScroll:SetBackdropColor(0, 0, 0, 0)
	playerScroll:SetBackdropBorderColor(0, 0, 0, 0)
	playerScroll.__background:Hide()

	--create the header frame for the player scrollbox selection
	---@type df_headerframe
	breakdownWindowFrame.PlayerSelectionHeader = DetailsFramework:CreateHeader(playerScroll, headerTable, headerOptions)
	breakdownWindowFrame.PlayerSelectionHeader:SetAlpha(0.823)
	breakdownWindowFrame.PlayerSelectionHeader:SetPoint("topleft", playerSelectionHeaderFrame, "bottomleft", 0, -2)
	breakdownWindowFrame.PlayerSelectionHeader:SetPoint("topright", playerSelectionHeaderFrame, "bottomright", 0, -2)

	detailsFramework:ApplyStandardBackdrop(breakdownWindowFrame.PlayerSelectionHeader)
	breakdownWindowFrame.PlayerSelectionHeader.__background:SetColorTexture(.60, .60, .60)

	--create the scrollbox lines
	for i = 1, scrollbox_lines do
		playerScroll:CreateLine(createPlayerLine)
	end

	return playerScroll
end

local createSegmentsScrollBox = function(breakdownWindowFrame, breakdownSideMenu, playerSelectionHeaderFrame)
	local refreshSegmentsScrollFunc = function(self, data, offset, totalLines)
		for lineIndex = 1, totalLines do --~refresh
			local index = lineIndex + offset
			---@type breakdownsegmentdata
			local segmentData = data[index]
			if (segmentData) then
				---@type breakdownsegmentline
				local line = self:GetLine(lineIndex)
				if (line) then
					line:UpdateLine(lineIndex, segmentData)
				end
			end
		end
	end

	local lineOnClick = function(self)
		--unique combat id from the button clicked
		local combatUniqueID = self.combatUniqueID
		if (not Details:DoesCombatWithUIDExists(combatUniqueID)) then
			Details:Msg("This segment is not available anymore.")
			return
		end

		--current breakdown combat
		local currentBKCombat = Details:GetCombatFromBreakdownWindow()
		--unique combat id from the combat the breakdown window is using
		local currentBKCombatUniqueID = currentBKCombat:GetCombatUID()

		if (combatUniqueID ~= currentBKCombatUniqueID) then
			local newCombatToShowInBreakdownWindow = Details:GetCombatByUID(combatUniqueID)
			if (newCombatToShowInBreakdownWindow) then
				---@cast newCombatToShowInBreakdownWindow combat
				local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
				--set the segment of the instance to be the segment just selected by the user
				instanceObject:SetSegment(newCombatToShowInBreakdownWindow:GetSegmentSlotId())

				local bFromAttributeChange = false
				local bIsRefresh = true

				local actor = getActorToShowInBreakdownWindow(newCombatToShowInBreakdownWindow)
				if (actor) then
					Details:OpenBreakdownWindow(instanceObject, actor, bFromAttributeChange, bIsRefresh)
				else
					local actorObject = Details:GetActorObjectFromBreakdownWindow()
					lastSelectedPlayerPerSegment[combatUniqueID] = actorObject:Name()
					Details:OpenBreakdownWindow(instanceObject, actorObject, bFromAttributeChange, bIsRefresh)
				end

				breakdownWindowFrame.segmentScrollBox:Refresh()
			end
		end
	end

	local lineOnEnter = function(self)
		if (not self.isSelected) then
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color_highlight))
		end
	end

	local lineOnLeave = function(self)
		if (not self.isSelected) then
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color))
		end
	end

	---update the segment line from the segments scrollbox
	---@param self breakdownsegmentline
	---@param index number
	---@param segmentData breakdownsegmentdata
	local updateSegmentLine = function(self, index, segmentData) --~update
		local combatName = segmentData.combatName
		local r, g, b = segmentData.r, segmentData.g, segmentData.b
		local combatIcon1 = segmentData.combatIcon

		self.segmentText:SetText(combatName)
		Details222.BreakdownWindow.ApplyFontSettings(self.segmentText)

		self.segmentText:SetTextColor(r, g, b)
		detailsFramework:TruncateText(self.segmentText, player_scroll_size[1] - 20)

		local bUseAtlasSize = true
		detailsFramework:SetAtlas(self.segmentIcon, combatIcon1, bUseAtlasSize)

		self.combatUniqueID = segmentData.UID

		local combatSelected = Details:GetCombatFromBreakdownWindow()
		if (combatSelected and combatSelected:GetCombatUID() == segmentData.UID) then
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color_selected))
			self.isSelected = true
		else
			self:SetBackdropColor(unpack(scrollbox_line_backdrop_color))
			self.isSelected = false
		end
	end

	--header setup
	local headerTable = {
		{text = "Segment Name", width = 100},
	}
	local headerOptions = {
		padding = 2,
	}

	local createSegmentLine = function(self, index)
		--create a new line
		local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
		detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)
		detailsFramework:SetTemplate(line, "STANDARD_GRAY")

		PixelUtil.SetPoint(line, "topleft", self, "topleft", 1, -((index-1) * (player_line_height+1)))
		PixelUtil.SetSize(line, scrollbox_size[1]-2, player_line_height)

		line:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		line:SetScript("OnEnter", lineOnEnter)
		line:SetScript("OnLeave", lineOnLeave)
		line:SetScript("OnClick", lineOnClick)

		--segment icon, this icon will tell which type of segment the line is
		---@type df_image
		local segmentIcon = detailsFramework:CreateTexture(line, "", player_line_height, player_line_height - 1, "artwork")
		segmentIcon:SetSize(player_line_height - 4, player_line_height - 4)
		segmentIcon:SetAlpha(0.834)

		local segmentText = line:CreateFontString("$parentSegmentName", "artwork", "GameFontNormal")
		line.segmentText = segmentText
		line.segmentIcon = segmentIcon

		--create a texture gradient in horizontal with the left side starting from black and the right side ending in transparent, the width is 40 and is placed at the left side of the line
		local gradientTexture = DetailsFramework:CreateTexture(line, {gradient = "horizontal", fromColor = {.1, .1, .1, .634}, toColor = "transparent"}, 100, 1, "border", {0, 1, 0, 1}, "segmentsGradient")
		gradientTexture:SetPoint("lefts")

		segmentIcon:SetPoint("left", line, "left", 2, 0)
		segmentText:SetPoint("left", segmentIcon.widget, "right", 5, 0)

		line.UpdateLine = updateSegmentLine

		return line
	end

	---@type width
	local width = player_scroll_size[1] + 22
	---@type height
	local height = player_scroll_size[2]

	local segmentsScroll = detailsFramework:CreateScrollBox(breakdownSideMenu, "DetailsBreakdownWindowSegmentsScrollBox", refreshSegmentsScrollFunc, {}, width, height, scrollbox_lines, player_line_height)
	detailsFramework:ReskinSlider(segmentsScroll)

	segmentsScroll.ScrollBar:ClearAllPoints()
	segmentsScroll.ScrollBar:SetPoint("topright", segmentsScroll, "topright", -2, -37)
	segmentsScroll.ScrollBar:SetPoint("bottomright", segmentsScroll, "bottomright", -2, 17)
	segmentsScroll.ScrollBar:Hide()

	breakdownWindowFrame.segmentScrollBox = segmentsScroll

	--remove the standard backdrop
	segmentsScroll:SetBackdrop(nil)
	segmentsScroll.__background:Hide()

	--create the scrollbox lines
	for i = 1, scrollbox_lines do
		segmentsScroll:CreateLine(createSegmentLine)
	end

	return segmentsScroll
end

function breakdownWindowPlayerList.CreatePlayerListFrame()
	---@type breakdownwindow
	local breakdownWindowFrame = Details.BreakdownWindowFrame
	---@type frame
	local breakdownSideMenu = breakdownWindowFrame.BreakdownSideMenuFrame
	---@type frame
	local pluginsFrame = breakdownWindowFrame.BreakdownPluginSelectionFrame

	breakdownSideMenu:SetSize(scrollbox_size[1], scrollbox_size[2])
	PixelUtil.SetPoint(breakdownSideMenu, "topright", breakdownWindowFrame, "topleft", -2, 0)
	PixelUtil.SetPoint(breakdownSideMenu, "bottomright", breakdownWindowFrame, "bottomleft", -2, 0)

	--> create headers
		local sectionHeaderHeight = 20
		--plugins header frame
		local pluginHeaderFrame = CreateFrame("frame", nil, breakdownSideMenu, "BackdropTemplate")
		PixelUtil.SetPoint(pluginHeaderFrame, "topleft", breakdownSideMenu, "topleft", 2, -0)
		PixelUtil.SetPoint(pluginHeaderFrame, "topright", breakdownSideMenu, "topright", -2, -0)
		pluginHeaderFrame:SetHeight(sectionHeaderHeight)
			--plugins header label
			local titleBarPlugins_TitleLabel = detailsFramework:CreateLabel(pluginHeaderFrame, "Plugins", 12, "DETAILS_HEADER_YELLOW", "GameFontHighlightLeft", "pluginsLabel", nil, "overlay")
			PixelUtil.SetPoint(titleBarPlugins_TitleLabel, "center", pluginHeaderFrame , "center", 0, 0)
			PixelUtil.SetPoint(titleBarPlugins_TitleLabel, "top", pluginHeaderFrame , "top", 0, -5)

		--player selection header frame
		local playerSelectionHeaderFrame = CreateFrame("frame", nil, breakdownSideMenu, "BackdropTemplate")
		playerSelectionHeaderFrame:SetHeight(sectionHeaderHeight)
		playerSelectionHeaderFrame:SetPoint("topleft", pluginsFrame, "bottomleft", 0, -1)
		playerSelectionHeaderFrame:SetPoint("topright", pluginsFrame, "bottomright", 0, -1)
			--player selection header label
			--converting from detailsFramework:NewLabel to detailsFramework:CreateLabel
			--local titleBarTools_TitleLabel = detailsFramework:NewLabel(titleBarPlayerSeparator, titleBarPlayerSeparator, nil, "titulo", "Players", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
			local titleBarTools_TitleLabel = detailsFramework:CreateLabel(playerSelectionHeaderFrame, "Select Player", 12, "DETAILS_HEADER_YELLOW", "GameFontHighlightLeft", "playersLabel", nil, "overlay")
			PixelUtil.SetPoint(titleBarTools_TitleLabel, "center", playerSelectionHeaderFrame , "center", 0, 0)
			PixelUtil.SetPoint(titleBarTools_TitleLabel, "top", playerSelectionHeaderFrame , "top", 0, -5)

		--segment selection header frame
		local segmentSelectionHeaderFrame = CreateFrame("frame", nil, breakdownSideMenu, "BackdropTemplate")
		segmentSelectionHeaderFrame:SetHeight(sectionHeaderHeight)
			--segment selection header label
			local titleBarSegment_TitleLabel = detailsFramework:CreateLabel(segmentSelectionHeaderFrame, "Select Segment", 12, "DETAILS_HEADER_YELLOW", "GameFontHighlightLeft", "segmentsLabel", nil, "overlay")
			PixelUtil.SetPoint(titleBarSegment_TitleLabel, "center", segmentSelectionHeaderFrame , "center", 0, 0)
			PixelUtil.SetPoint(titleBarSegment_TitleLabel, "top", segmentSelectionHeaderFrame , "top", 0, -5)

	local playerScroll = createPlayerScrollBox(breakdownWindowFrame, breakdownSideMenu, playerSelectionHeaderFrame)
	playerScroll:SetPoint("topleft", breakdownWindowFrame.PlayerSelectionHeader, "bottomleft", 0, -2)
	playerScroll:SetPoint("topright", breakdownWindowFrame.PlayerSelectionHeader, "bottomright", 0, -2)

	local segmentsScroll = createSegmentsScrollBox(breakdownWindowFrame, breakdownSideMenu, playerSelectionHeaderFrame)
	segmentsScroll:SetPoint("topleft", playerScroll, "bottomleft", 0, -20)
	segmentsScroll:SetPoint("topright", playerScroll, "bottomright", 0, -20)

	PixelUtil.SetPoint(segmentSelectionHeaderFrame, "topleft", playerScroll, "bottomleft", 0, -1)
	PixelUtil.SetPoint(segmentSelectionHeaderFrame, "topright", playerScroll, "bottomright", 0, -1)

	local classIds = detailsFramework.ClassFileNameToIndex

	---get the player list from the segment and build a table compatible with the scroll box
	---@return actor[]
	function breakdownWindowPlayerList.BuildPlayerList()
		---@type combat
		local combatObject = Details:GetCombatFromBreakdownWindow()
		---@type {key1: actor, key2: number, key3: number}[]
		local playerTable = {}

		if (combatObject) then
			local displayType = Details:GetDisplayTypeFromBreakdownWindow()
			local containerType = displayType == 1 and DETAILS_ATTRIBUTE_DAMAGE or DETAILS_ATTRIBUTE_HEAL
			---@type actorcontainer
			local actorContainer = combatObject:GetContainer(containerType)

			for index, actorObject in actorContainer:ListActors() do
				---@cast actorObject actor
				if (actorObject:IsPlayer() and actorObject:IsGroupPlayer()) then
					local unitClassID = classIds[actorObject:Class()] or 13
					local unitName = actorObject:Name()
					--actor position calculation: if two actors has the same amount of a total number, the sort function would flip they around, so we need to add a unique number to the position based on the class and the two first letters of the name
					local playerPosition = (((unitClassID or 0) + 128) ^ 4) + tonumber(string.byte(unitName, 1) .. "" .. string.byte(unitName, 2))

					---@type {key1: actor, key2: number, key3: number}
					local data = {actorObject, playerPosition, actorObject.total}
					tinsert(playerTable, data)
				end
			end
		end

		table.sort(playerTable, detailsFramework.SortOrder3)

		---@type actor[]
		local resultTable = {}
		for i = 1, #playerTable do
			---@type actor
			local actor = playerTable[i][1]
			resultTable[#resultTable+1] = actor
		end

		return resultTable
	end

	local updatePlayerAndSegmentsList = function()
		--the left menu side has 620 pixels of height

		--when updating the player list, update the plugin buttons as well for convenience
		--the refreshPluginButtons function returns the height occupied by the pluginsFrame
		--this height is then used to set the amount of lines the player and segments scroll frames will show
		local heightOccupied = refreshPluginButtons(breakdownWindowFrame, pluginsFrame, breakdownSideMenu)

		--the height of the player and segments scroll is determined by the height of the pluginsFrame, by the amount of players needed to be shown and the amount of segments needed to be shown
		--calculate the height "free" to use for both scrolls
		local heightFree = breakdownSideMenu:GetHeight() - heightOccupied
		--the -60 is the space used by the player and segments labels, plus the player scroll header
		--the -5 is the space between the player and segments scroll
		heightFree = heightFree - 60 - 5

		---@type actor[]
		local playerList = breakdownWindowPlayerList.BuildPlayerList()

		local amountOfLines = math.floor(heightFree / player_line_height)

		local linesForPlayerScroll = math.floor(amountOfLines/2)
		if (linesForPlayerScroll < 5) then
			linesForPlayerScroll = 5
		elseif (linesForPlayerScroll > 10) then
			linesForPlayerScroll = 10
		end

		local selectedPlayerName = Details:GetActorObjectFromBreakdownWindow():Name()
		lastSelectedPlayerPerSegment[Details:GetCombatFromBreakdownWindow():GetCombatUID()] = selectedPlayerName
		lastSelectedPlayerName = selectedPlayerName

		local playerLineHeight = player_line_height+1 --the +1 is the space between the lines

		--recalculate the height free, now that we know the amount of lines the player scroll will show
		heightFree = heightFree - (linesForPlayerScroll * playerLineHeight)
		local linesForSegmentsScroll = math.floor(heightFree/playerLineHeight)

		playerScroll:SetNumFramesShown(linesForPlayerScroll) --looks like it is not updating the 'totalLines' at the refresh function
		playerScroll:SetHeight(linesForPlayerScroll * playerLineHeight)

		segmentsScroll:SetNumFramesShown(linesForSegmentsScroll)
		segmentsScroll:SetHeight(linesForSegmentsScroll * playerLineHeight)

		playerScroll:SetData(playerList)
		playerScroll:Refresh()
		playerScroll:Show()

		---@type breakdownsegmentdata[]
		local segmentsData = {}

		---@type combat[]
		local segmentsTable = Details:GetCombatSegments()

		for i = 1, #segmentsTable do
			---@type combat
			local combatObject = segmentsTable[i]

			---@type uniquecombatid
			local UID = combatObject:GetCombatUID()

			local combatName, r, g, b = combatObject:GetCombatName(true)
			local combatIcon, categoryIcon = combatObject:GetCombatIcon()

			segmentsData[i] = {
				UID = UID,
				combatName = combatName,
				combatIcon = combatIcon,
				r = r or 1,
				g = g or 1,
				b = b or 1,
			}
		end

		segmentsScroll:SetData(segmentsData)
		segmentsScroll:Refresh()
		segmentsScroll:Show()
	end

	function Details:UpdateBreakdownPlayerList()
		--run the update on the next tick
		C_Timer.After(0, updatePlayerAndSegmentsList)
	end

	breakdownWindowFrame:HookScript("OnShow", function()
		Details:UpdateBreakdownPlayerList()
	end)

	breakdownWindowFrame:HookScript("OnHide", function()
		for lineIndex, line in ipairs(breakdownWindowFrame.playerScrollBox:GetLines()) do
			line.playerObject = nil
			line.combatObject = nil
		end
	end)
end

function Details.PlayerBreakdown.CreatePlayerListFrame()
	if (not Details.PlayerBreakdown.playerListFrameCreated) then
		breakdownWindowPlayerList.CreatePlayerListFrame()
		Details.PlayerBreakdown.playerListFrameCreated = true
	end
end

function Details222.BreakdownWindow.RefreshScrolls()
	Details:UpdateBreakdownPlayerList()
end