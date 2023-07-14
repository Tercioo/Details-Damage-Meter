
local Details = _G.Details
local detailsFramework = _G.DetailsFramework
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
local addonName, Details222 = ...

local breakdownWindowPlayerList = {}

local unpack = table.unpack or unpack
local C_Timer = _G.C_Timer
local tinsert = table.insert
local CreateFrame = CreateFrame
local GetSpecializationInfoByID = GetSpecializationInfoByID

local scrollbox_size = {215, 405}
local scrollbox_lines = 19
local player_line_height = 21.7
local scrollbox_line_backdrop_color = {0.2, 0.2, 0.2, 0.5}
local scrollbox_line_backdrop_color_selected = {.6, .6, .1, 0.7}
local scrollbox_line_backdrop_color_highlight = {.9, .9, .9, 0.5}
local player_scroll_size = {195, 288}
local player_scroll_y = -300

function breakdownWindowPlayerList.CreatePlayerListFrame()
	---@type breakdownwindow
	local breakdownWindowFrame = Details.BreakdownWindowFrame
	---@type frame
	local breakdownSideMenu = breakdownWindowFrame.BreakdownSideMenuFrame
	---@type frame
	local pluginsFrame = breakdownWindowFrame.BreakdownPluginSelectionFrame

	breakdownSideMenu:SetSize(scrollbox_size[1], scrollbox_size[2])
	breakdownSideMenu:SetPoint("topright", breakdownWindowFrame, "topleft", 0, 0)
	breakdownSideMenu:SetPoint("bottomright", breakdownWindowFrame, "bottomleft", 0, 0)
	detailsFramework:ApplyStandardBackdrop(breakdownSideMenu)
	breakdownSideMenu.RightEdge:Hide()

	local titleHeight = 20
	--plugins menu title bar
	local titleBarPlugins = CreateFrame("frame", nil, breakdownSideMenu, "BackdropTemplate")
	PixelUtil.SetPoint(titleBarPlugins, "topleft", breakdownSideMenu, "topleft", 2, -3)
	PixelUtil.SetPoint(titleBarPlugins, "topright", breakdownSideMenu, "topright", -2, -3)
	titleBarPlugins:SetHeight(titleHeight)
	titleBarPlugins:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
	titleBarPlugins:SetBackdropColor(.5, .5, .5, 1)
	titleBarPlugins:SetBackdropBorderColor(0, 0, 0, 1)

	--title label
	local titleBarPlugins_TitleLabel = detailsFramework:NewLabel(titleBarPlugins, titleBarPlugins, nil, "titulo", "Plugins", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	PixelUtil.SetPoint(titleBarPlugins_TitleLabel, "center", titleBarPlugins , "center", 0, 0)
	PixelUtil.SetPoint(titleBarPlugins_TitleLabel, "top", titleBarPlugins , "top", 0, -5)

	--plugins menu title bar
	local titleBarPlayerSeparator = CreateFrame("frame", nil, breakdownSideMenu, "BackdropTemplate")
	titleBarPlayerSeparator:SetHeight(titleHeight)
	titleBarPlayerSeparator:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
	titleBarPlayerSeparator:SetBackdropColor(.5, .5, .5, 1)
	titleBarPlayerSeparator:SetBackdropBorderColor(0, 0, 0, 1)

	--title label
	local titleBarTools_TitleLabel = detailsFramework:NewLabel(titleBarPlayerSeparator, titleBarPlayerSeparator, nil, "titulo", "Players", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	PixelUtil.SetPoint(titleBarTools_TitleLabel, "center", titleBarPlayerSeparator , "center", 0, 0)
	PixelUtil.SetPoint(titleBarTools_TitleLabel, "top", titleBarPlayerSeparator , "top", 0, -5)

	titleBarPlayerSeparator:SetPoint("topleft", pluginsFrame, "bottomleft", 0, -1)
	titleBarPlayerSeparator:SetPoint("topright", pluginsFrame, "bottomright", 0, -1)

	local highlightPluginButtonOnBreakdownWindow = function(pluginAbsoluteName)
		for index, button in ipairs(breakdownWindowFrame.RegisteredPluginButtons) do
			---@cast button df_button
			button:Show()

			if (button.PluginAbsName == pluginAbsoluteName) then
				button:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGINPANEL_BUTTONSELECTED_TEMPLATE"))
			else
				button:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGINPANEL_BUTTON_TEMPLATE"))
			end
		end
	end

	local refreshPluginButtons = function()
		local amountPluginButtons = #breakdownWindowFrame.RegisteredPluginButtons
		local pluginButtonHeight = 20

		for i = 1, amountPluginButtons do
			---@type button
			local pluginButton = breakdownWindowFrame.RegisteredPluginButtons[i]
			pluginButton:Show()
			pluginButton:SetWidth(pluginsFrame:GetWidth() - 4)
			pluginButton:SetHeight(pluginButtonHeight)
			pluginButton:ClearAllPoints()

			if (i == 1) then
				pluginButton:SetPoint("topleft", pluginsFrame, "topleft", 2, -22)
			else
				pluginButton:SetPoint("topleft", breakdownWindowFrame.RegisteredPluginButtons[i - 1], "bottomleft", 0, -2)
			end
		end

		pluginsFrame:SetPoint("topleft", breakdownSideMenu, "topleft", 0, 0)
		pluginsFrame:SetWidth(breakdownSideMenu:GetWidth())
		pluginsFrame:SetHeight(amountPluginButtons * pluginButtonHeight + 22 + (amountPluginButtons * 2))
	end

	local refreshScrollFunc = function(self, data, offset, totalLines)
		--update the scroll
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
			Details:OpenBreakdownWindow(Details:GetActiveWindowFromBreakdownWindow(), self.playerObject)
			breakdownWindowFrame.playerScrollBox:Refresh()
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
		local playerSelected = Details:GetActorObjectFromBreakdownWindow()
		if (playerSelected and playerSelected == self.playerObject) then
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

		--set the player class name
		--self.className:SetText(string.lower(_G.UnitClass(self.playerObject.nome) or self.playerObject:Class())) --not in use

		--item level
		self.itemLevelText:SetText(self.playerObject.ilvl or (playerGear and playerGear.ilevel) or "0")

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
		detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

		local upFrame = CreateFrame("frame", nil, line)
		upFrame:SetFrameLevel(line:GetFrameLevel()+2)
		upFrame:SetAllPoints()

		--set its parameters
		--line:SetPoint("topleft", self, "topleft", 1, -((index) * (player_line_height+1)) - 1)
		line:SetPoint("topleft", breakdownWindowFrame.Header, "topleft", 1, -((index) * (player_line_height*1.02)))
		line:SetSize(scrollbox_size[1]-2, player_line_height)
		line:RegisterForClicks("LeftButtonDown", "RightButtonDown")

		line:SetScript("OnEnter", lineOnEnter)
		line:SetScript("OnLeave", lineOnLeave)
		line:SetScript("OnClick", lineOnClick)

		detailsFramework:ApplyStandardBackdrop(line)

		local specIcon = upFrame:CreateTexture("$parentSpecIcon", "artwork")
		specIcon:SetSize(headerTable[1].width - 1, headerTable[1].width - 1)
		specIcon:SetAlpha(0.71)

		local roleIcon = upFrame:CreateTexture("$parentRoleIcon", "overlay")
		roleIcon:SetSize((player_line_height-2) / 2, (player_line_height-2) / 2)
		roleIcon:SetAlpha(0.71)

		local playerName = detailsFramework:CreateLabel(upFrame, "", 11, "white", "GameFontNormal")
		if (fontFile) then
			playerName.fontface = fontFile
		end
		if (fontSize) then
			playerName.fontsize = fontSize
		end
		if (fontOutline) then
			playerName.outline = fontOutline
		end

		--~create
		playerName.textcolor = {1, 1, 1, .9}

		local className = detailsFramework:CreateLabel(upFrame, "", "GameFontNormal")
		className.textcolor = {.95, .8, .2, 0}
		className.textsize = 9

		local itemLevelText = detailsFramework:CreateLabel(upFrame, "", "GameFontNormal")
		itemLevelText.textcolor = {1, 1, 1, .7}
		itemLevelText.textsize = 11

		local percentileText = detailsFramework:CreateLabel(upFrame, "", "GameFontNormal")
		percentileText.textcolor = {1, 1, 1, .7}
		percentileText.textsize = 11

		local rankText = detailsFramework:CreateLabel(upFrame, "", "GameFontNormal")
		rankText.textcolor = {.3, .3, .3, .7}
		rankText.textsize = fontSize

		local totalStatusBar = CreateFrame("statusbar", nil, line)
		totalStatusBar:SetSize(scrollbox_size[1]-player_line_height, 4)
		totalStatusBar:SetMinMaxValues(0, 100)
		totalStatusBar:SetStatusBarTexture([[Interface\AddOns\Details\images\bar_skyline]])
		totalStatusBar:SetFrameLevel(line:GetFrameLevel()+1)
		totalStatusBar:SetAlpha(0.5)

		--setup anchors
		--specIcon:SetPoint("topleft", line, "topleft", 0, 0)
		--roleIcon:SetPoint("topleft", specIcon, "topright", 2, 0)
		--playerName:SetPoint("topleft", specIcon, "topright", 2, -3)
		--className:SetPoint("topleft", roleIcon, "bottomleft", 0, -2)
		--rankText:SetPoint("right", line, "right", -2, 0)
		totalStatusBar:SetPoint("bottomleft", specIcon, "bottomright", 0, 0)

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

		line:AlignWithHeader(breakdownWindowFrame.Header, "left")

		line.UpdateLine = updatePlayerLine

		return line
	end

	---@type width
	local width = player_scroll_size[1] + 22
	---@type height
	local height = player_scroll_size[2]

	local playerScroll = detailsFramework:CreateScrollBox(breakdownSideMenu, "DetailsBreakdownWindowPlayerScrollBox", refreshScrollFunc, {}, width, height, scrollbox_lines, player_line_height)
	detailsFramework:ReskinSlider(playerScroll)
	playerScroll.ScrollBar:ClearAllPoints()
	playerScroll.ScrollBar:SetPoint("topright", playerScroll, "topright", -2, -37)
	playerScroll.ScrollBar:SetPoint("bottomright", playerScroll, "bottomright", -2, 17)
	playerScroll.ScrollBar:Hide()

	playerScroll:SetBackdrop({})
	playerScroll:SetBackdropColor(0, 0, 0, 0)
	playerScroll:SetBackdropBorderColor(0, 0, 0, 0)
	breakdownWindowFrame.playerScrollBox = playerScroll

	--need to be created before
	breakdownWindowFrame.Header = DetailsFramework:CreateHeader(playerScroll, headerTable, headerOptions)
	breakdownWindowFrame.Header:SetAlpha(0.823)
	breakdownWindowFrame.Header:SetPoint("topleft", titleBarPlayerSeparator, "bottomleft", 0, -2)
	breakdownWindowFrame.Header:SetPoint("topright", titleBarPlayerSeparator, "bottomright", 0, -2)

	playerScroll:SetPoint("topleft", breakdownWindowFrame.Header, "bottomleft", 0, -2)
	playerScroll:SetPoint("topright", breakdownWindowFrame.Header, "bottomright", 0, -2)
	playerScroll:SetPoint("bottomleft", breakdownSideMenu, "bottomleft", 0, 0)
	playerScroll:SetPoint("bottomright", breakdownSideMenu, "bottomright", 0, 0)

	detailsFramework:ApplyStandardBackdrop(breakdownWindowFrame.Header)
	breakdownWindowFrame.Header.__background:SetColorTexture(.60, .60, .60)

	--create the scrollbox lines
	for i = 1, scrollbox_lines do
		playerScroll:CreateLine(createPlayerLine)
	end

	local classIds = {
		WARRIOR = 1,
		PALADIN = 2,
		HUNTER = 3,
		ROGUE = 4,
		PRIEST = 5,
		DEATHKNIGHT = 6,
		SHAMAN = 7,
		MAGE = 8,
		WARLOCK = 9,
		MONK = 10,
		DRUID = 11,
		DEMONHUNTER = 12,
		EVOKER = 13,
	}

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

	local updatePlayerList = function()
		refreshPluginButtons()

		playerScroll:SetNumFramesShown(math.floor(playerScroll:GetHeight() / player_line_height)) --looks like it is not updating the 'totalLines' at the refresh function

		---@type actor[]
		local playerList = breakdownWindowPlayerList.BuildPlayerList()

		playerScroll:SetData(playerList)
		playerScroll:Refresh()
		playerScroll:Show()
	end

	function Details:UpdateBreakdownPlayerList()
		--run the update on the next tick
		C_Timer.After(0, updatePlayerList)
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

	local gradientStartColor = Details222.ColorScheme.GetColorFor("gradient-background")
	local gradientBelow = DetailsFramework:CreateTexture(breakdownWindowFrame.playerScrollBox,
	{gradient = "vertical", fromColor = gradientStartColor, toColor = "transparent"}, 1, 90, "artwork", {0, 1, 0, 1})
	gradientBelow:SetPoint("bottoms", 1, 1)
end

function Details.PlayerBreakdown.CreatePlayerListFrame()
	if (not Details.PlayerBreakdown.playerListFrameCreated) then
		breakdownWindowPlayerList.CreatePlayerListFrame()
		Details.PlayerBreakdown.playerListFrameCreated = true
	end
end