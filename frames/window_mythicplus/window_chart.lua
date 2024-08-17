
local Details = _G.Details
local addonName, Details222 = ...
local _

Details222.Debug.MythicPlusChartWindowDebug = false
local verbosemode = false


local CreateFrame = CreateFrame
local UIParent = UIParent

---@type detailsframework
local detailsFramework = DetailsFramework

local mythicDungeonCharts = Details222.MythicPlus.Charts.Listener

local UISpecialFrames = UISpecialFrames

-- /run _G.DetailsMythicDungeonChartHandler.ShowEndOfMythicPlusPanel()
-- /run _G.DetailsMythicDungeonChartHandler.ShowChart()

function mythicDungeonCharts.ShowChart()
	if (not mythicDungeonCharts.Frame) then
		mythicDungeonCharts.Frame = CreateFrame("frame", "DetailsMythicDungeonChartFrame", UIParent, "BackdropTemplate")
		local dungeonChartFrame = mythicDungeonCharts.Frame

		--get the screen width
		local screenWidth = GetScreenWidth()

		dungeonChartFrame:SetSize(screenWidth - 200, 400)
		dungeonChartFrame:SetPoint("center", UIParent, "center", 0, 200)
		dungeonChartFrame:SetFrameStrata("DIALOG")
		dungeonChartFrame:EnableMouse(true)
		dungeonChartFrame:SetMovable(true)
		detailsFramework:ApplyStandardBackdrop(dungeonChartFrame)
		dungeonChartFrame.__background:SetAlpha(0.834)

		--minimized frame
		mythicDungeonCharts.FrameMinimized = CreateFrame("frame", "DetailsMythicDungeonChartFrameminimized", UIParent, "BackdropTemplate")
		local fMinimized = mythicDungeonCharts.FrameMinimized
		fMinimized:SetSize(160, 24)
		fMinimized:SetPoint("center", UIParent, "center", 0, 0)
		fMinimized:SetFrameStrata("LOW")
		fMinimized:EnableMouse(true)
		fMinimized:SetMovable(true)
		fMinimized:Hide()
		detailsFramework:ApplyStandardBackdrop(fMinimized)

		dungeonChartFrame.IsMinimized = false

		--titlebar
			local titlebar = CreateFrame("frame", nil, dungeonChartFrame, "BackdropTemplate")
			titlebar:SetPoint("topleft", dungeonChartFrame, "topleft", 2, -3)
			titlebar:SetPoint("topright", dungeonChartFrame, "topright", -2, -3)
			titlebar:SetHeight(20)
			titlebar:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
			titlebar:SetBackdropColor(.5, .5, .5, 1)
			titlebar:SetBackdropBorderColor(0, 0, 0, 1)

			--title
			local titleLabel = detailsFramework:NewLabel(titlebar, titlebar, nil, "titulo", "Plugins", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
			titleLabel:SetPoint("center", titlebar , "center")
			titleLabel:SetPoint("top", titlebar , "top", 0, -5)
			dungeonChartFrame.TitleText = titleLabel

		--titlebar when minimized
			local titlebarMinimized = CreateFrame("frame", nil, fMinimized, "BackdropTemplate")
			titlebarMinimized:SetPoint("topleft", fMinimized, "topleft", 2, -3)
			titlebarMinimized:SetPoint("topright", fMinimized, "topright", -2, -3)
			titlebarMinimized:SetHeight(20)
			titlebarMinimized:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
			titlebarMinimized:SetBackdropColor(.5, .5, .5, 1)
			titlebarMinimized:SetBackdropBorderColor(0, 0, 0, 1)

			--title
			local titleLabelMinimized = detailsFramework:NewLabel(titlebarMinimized, titlebarMinimized, nil, "titulo", "Dungeon Run Chart", "GameFontHighlightLeft", 10, {227/255, 186/255, 4/255})
			titleLabelMinimized:SetPoint("left", titlebarMinimized , "left", 4, 0)
			--titleLabelMinimized:SetPoint("top", titlebarMinimized , "top", 0, -5)
			dungeonChartFrame.TitleTextMinimized = titleLabelMinimized

		table.insert(UISpecialFrames, "DetailsMythicDungeonChartFrame")

		--register to libwindow
		local LibWindow = LibStub("LibWindow-1.1")
		LibWindow.RegisterConfig(dungeonChartFrame, Details.mythic_plus.mythicrun_chart_frame)
		LibWindow.RestorePosition(dungeonChartFrame)
		LibWindow.MakeDraggable(dungeonChartFrame)
		LibWindow.SavePosition(dungeonChartFrame)

		LibWindow.RegisterConfig(fMinimized, Details.mythic_plus.mythicrun_chart_frame_minimized)
		LibWindow.RestorePosition(fMinimized)
		LibWindow.MakeDraggable(fMinimized)
		LibWindow.SavePosition(fMinimized)

		local chartFrame = detailsFramework:CreateGraphicMultiLineFrame(dungeonChartFrame, "DetailsMythicDungeonChartGraphicFrame")
		chartFrame:SetPoint("topleft", dungeonChartFrame, "topleft", 1, -20)
		chartFrame:SetSize(dungeonChartFrame:GetWidth(), dungeonChartFrame:GetHeight() - 20)
		chartFrame:EnableMouse(false)
		dungeonChartFrame:Hide()
		dungeonChartFrame.ChartFrame = chartFrame

		local red, green, blue, opacity = 1, 1, 1, 1
		chartFrame:CreateAxesLines(48, 20, "left", 1, 10, 10, red, green, blue, opacity)
		chartFrame:SetXAxisDataType("time")
		chartFrame:SetLineThickness(2)

		function dungeonChartFrame.ShowChartFrame()
			if (dungeonChartFrame.IsMinimized) then
				dungeonChartFrame.IsMinimized = false
				fMinimized:Hide()
				dungeonChartFrame:Show()
			else
				dungeonChartFrame:Show()
			end
		end

		mythicDungeonCharts.CreateCloseMinimizeButtons(dungeonChartFrame)
		mythicDungeonCharts.CreateBossWidgets(dungeonChartFrame)
	end --finished created the chart frame

	local dungeonChartFrame = mythicDungeonCharts.Frame

	---@type df_chartmulti
	local chartFrame = dungeonChartFrame.ChartFrame

	chartFrame:Reset()

	--check if there is a valid chart table
	if (not mythicDungeonCharts.ChartTable) then
		if (Details222.Debug.MythicPlusChartWindowDebug) then
			--development
			if (Details.mythic_plus.last_mythicrun_chart) then
				--load the last mythic dungeon run chart
				local t = {}
				detailsFramework.table.copy(t, Details.mythic_plus.last_mythicrun_chart)
				mythicDungeonCharts.ChartTable = t
				mythicDungeonCharts:Debug("no valid data, saved data loaded")

			else
				mythicDungeonCharts:Debug("no valid data and no saved data, canceling")
				dungeonChartFrame:Hide()
				return
			end

		else
			dungeonChartFrame:Hide()
			mythicDungeonCharts:Debug("no data found, canceling")

			if (verbosemode) then
				mythicDungeonCharts:Debug("mythicDungeonCharts.ShowChart() failed: no chart table")
			end
			return
		end
	end

	local charts = mythicDungeonCharts.ChartTable.Players
	local classDuplicated = {}

	mythicDungeonCharts.PlayerGraphIndex = {}

	--add the lines to the chart (one line per player)
	for playerName, playerTable in pairs(charts) do
		local chartData = playerTable.ChartData

		classDuplicated[playerTable.Class] = (classDuplicated[playerTable.Class] or 0) + 1

		local lineColor
		if (playerTable.Class) then
			local classColor = mythicDungeonCharts.ClassColors[playerTable.Class .. classDuplicated[playerTable.Class]]
			if (classColor) then
				lineColor = {classColor.r, classColor.g, classColor.b}
			else
				lineColor = {1, 1, 1}
			end
		else
			lineColor = {1, 1, 1}
		end

		local combatTime = mythicDungeonCharts.ChartTable.ElapsedTime

		local opacity = 1
		--local smoothnessLevel = 50
		--local smoothMethod = "loess"
		local smoothnessLevel = 20
		local smoothMethod = "sma"

		local chartSize = #chartData

		local shrinkBy = 1
		if (chartSize >= 800) then
			shrinkBy = math.max(2, math.floor(chartSize/800))
		end

		local reducedData = chartFrame:ShrinkData(chartData, shrinkBy)

		chartFrame:SetFillChart(true, 5)
		chartFrame:AddData(reducedData, smoothMethod, smoothnessLevel, playerName, lineColor[1], lineColor[2], lineColor[3], opacity)
		chartFrame:SetXAxisData(combatTime)
		table.insert(mythicDungeonCharts.PlayerGraphIndex, playerName)
	end

	mythicDungeonCharts.RefreshBossTimeline(dungeonChartFrame, mythicDungeonCharts.ChartTable.ElapsedTime)

	--generate boss time table
	local bossTimeTable = {}
	for i, bossTable in ipairs(mythicDungeonCharts.ChartTable.BossDefeated) do
		local combatTime = bossTable [3] or math.random(10, 30)
		table.insert(bossTimeTable, bossTable[1])
		table.insert(bossTimeTable, bossTable[1] - combatTime)
	end

	--chartFrame:AddOverlay(bossTimeTable, {1, 1, 1, 0.05}, "Show Boss", "")

	--local phrase = " Average Dps (under development)\npress Escape to hide, Details! Alpha Build." .. _detalhes.build_counter .. "." .. _detalhes.realversion
	local phrase = "Details!: Average Dps for "

	--chartFrame:SetTitle("")
	--detailsFramework:SetFontSize(chartFrame.chart_title, 14)

	dungeonChartFrame.TitleText:SetText(mythicDungeonCharts.ChartTable.DungeonName and phrase .. mythicDungeonCharts.ChartTable.DungeonName or phrase)

	dungeonChartFrame.ShowChartFrame()

	chartFrame:Plot()

	if (verbosemode) then
		mythicDungeonCharts:Debug("mythicDungeonCharts.ShowChart() success")
	end
end

local showID = 0
local HideTooltip = function(ticker)
	if (showID == ticker.ShowID) then
		GameCooltip2:Hide()
		mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPin:Hide()
		mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPinGlow:Hide()
	end
end

local PixelFrameOnEnter = function(self)
	local playerName = self.PlayerName
	--get the percent from the pixel height relative to the chart window
	local dps = self.Height / mythicDungeonCharts.Frame.ChartFrame:GetHeight()
	--multiply the max dps with the percent
	dps = mythicDungeonCharts.Frame.ChartFrame.Graphic.max_value * dps

	mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPin:SetPoint("center", self, "center", 0, 0)
	mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPin:Show()
	mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPinGlow:Show()

	GameCooltip2:Preset(2)
	GameCooltip2:SetOption("FixedWidth", 100)
	GameCooltip2:SetOption("TextSize", 10)
	local onlyName = Details:GetOnlyName(playerName)
	GameCooltip2:AddLine(onlyName)

	local classIcon, L, R, B, T = Details:GetClassIcon(mythicDungeonCharts.ChartTable.Players [playerName] and mythicDungeonCharts.ChartTable.Players [playerName].Class)
	GameCooltip2:AddIcon (classIcon, 1, 1, 16, 16, L, R, B, T)

	GameCooltip2:AddLine(Details:GetCurrentToKFunction()(nil, floor(dps)))

	GameCooltip2:SetOwner(self)
	GameCooltip2:Show()
	showID = showID + 1
end

local PixelFrameOnLeave = function(self)
	local timer = C_Timer.NewTimer(1, HideTooltip)
	timer.ShowID = showID
end


mythicDungeonCharts.ClassColors = {
	["HUNTER1"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
	["HUNTER2"] = { r = 0.47, g = 0.63, b = 0.25, colorStr = "ffabd473" },
	["HUNTER3"] = { r = 0.27, g = 0.43, b = 0.05, colorStr = "ffabd473" },

	["WARLOCK1"] = { r = 0.53, g = 0.53, b = 0.93, colorStr = "ff8788ee" },
	["WARLOCK2"] = { r = 0.33, g = 0.33, b = 0.73, colorStr = "ff8788ee" },
	["WARLOCK3"] = { r = 0.13, g = 0.13, b = 0.53, colorStr = "ff8788ee" },

	["PRIEST1"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
	["PRIEST2"] = { r = 0.8, g = 0.8, b = 0.8, colorStr = "ffffffff" },
	["PRIEST3"] = { r = 0.6, g = 0.6, b = 0.6, colorStr = "ffffffff" },

	["PALADIN1"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
	["PALADIN2"] = { r = 0.76, g = 0.35, b = 0.53, colorStr = "fff58cba" },
	["PALADIN3"] = { r = 0.56, g = 0.15, b = 0.33, colorStr = "fff58cba" },

	["MAGE1"] = { r = 0.25, g = 0.78, b = 0.92, colorStr = "ff3fc7eb" },
	["MAGE2"] = { r = 0.05, g = 0.58, b = 0.72, colorStr = "ff3fc7eb" },
	["MAGE3"] = { r = 0.0, g = 0.38, b = 0.52, colorStr = "ff3fc7eb" },

	["ROGUE1"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
	["ROGUE2"] = { r = 0.8, g = 0.76, b = 0.21, colorStr = "fffff569" },
	["ROGUE3"] = { r = 0.6, g = 0.56, b = 0.01, colorStr = "fffff569" },

	["DRUID1"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
	["DRUID2"] = { r = 0.8, g = 0.29, b = 0.04, colorStr = "ffff7d0a" },
	["DRUID3"] = { r = 0.6, g = 0.09, b = 0.04, colorStr = "ffff7d0a" },

	["SHAMAN1"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
	["SHAMAN2"] = { r = 0.0, g = 0.24, b = 0.67, colorStr = "ff0070de" },
	["SHAMAN3"] = { r = 0.0, g = 0.04, b = 0.47, colorStr = "ff0070de" },

	["WARRIOR1"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
	["WARRIOR2"] = { r = 0.58, g = 0.41, b = 0.23, colorStr = "ffc79c6e" },
	["WARRIOR3"] = { r = 0.38, g = 0.21, b = 0.03, colorStr = "ffc79c6e" },

	["DEATHKNIGHT1"] = { r = 0.77, g = 0.12 , b = 0.23, colorStr = "ffc41f3b" },
	["DEATHKNIGHT2"] = { r = 0.57, g = 0.02 , b = 0.03, colorStr = "ffc41f3b" },
	["DEATHKNIGHT3"] = { r = 0.37, g = 0.02 , b = 0.03, colorStr = "ffc41f3b" },

	["MONK1"] = { r = 0.0, g = 1.00 , b = 0.59, colorStr = "ff00ff96" },
	["MONK2"] = { r = 0.0, g = 0.8 , b = 0.39, colorStr = "ff00ff96" },
	["MONK3"] = { r = 0.0, g = 0.6 , b = 0.19, colorStr = "ff00ff96" },

	["DEMONHUNTER1"] = { r = 0.64, g = 0.19, b = 0.79, colorStr = "ffa330c9" },
	["DEMONHUNTER2"] = { r = 0.44, g = 0.09, b = 0.59, colorStr = "ffa330c9" },
	["DEMONHUNTER3"] = { r = 0.24, g = 0.09, b = 0.39, colorStr = "ffa330c9" },

	["EVOKER1"] = { r = 0.0, g = 1.00 , b = 0.59, colorStr = "FF205F45" },
	["EVOKER2"] = { r = 0.0, g = 0.8 , b = 0.39, colorStr = "FF126442" },
	["EVOKER3"] = { r = 0.0, g = 0.6 , b = 0.19, colorStr = "FF274B3C" },
};

if (Details222.Debug.MythicPlusChartWindowDebug) then
	--C_Timer.After(1, mythicDungeonCharts.ShowChart)
end

function mythicDungeonCharts.RefreshBossTimeline(dungeonChartFrame, elapsedTime)
	---@type df_chartmulti
	local chartFrame = dungeonChartFrame.ChartFrame

	for i, bossTable in ipairs(mythicDungeonCharts.ChartTable.BossDefeated) do
		local bossWidget = dungeonChartFrame.BossWidgetsFrame.Widgets[i]

		if (not bossWidget) then
			local newBossWidget = CreateFrame("frame", "$parentBossWidget" .. i, dungeonChartFrame.BossWidgetsFrame, "BackdropTemplate")
			newBossWidget:SetSize(64, 32)
			newBossWidget:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			newBossWidget:SetBackdropColor(0, 0, 0, 0.1)
			newBossWidget:SetBackdropBorderColor(0, 0, 0, 0)

			local bossAvatar = detailsFramework:CreateImage(newBossWidget, "", 64, 32, "border")
			bossAvatar:SetPoint("bottomleft", newBossWidget, "bottomleft", 0, 0)
			bossAvatar:SetScale(1.0)
			newBossWidget.AvatarTexture = bossAvatar

			local verticalLine = detailsFramework:CreateImage(newBossWidget, "", 1, chartFrame:GetHeight() - 25, "overlay")
			verticalLine:SetColorTexture(1, 1, 1, 0.3)
			verticalLine:SetPoint("bottomleft", newBossWidget, "bottomright", 0, 0)

			local timeText = detailsFramework:CreateLabel(newBossWidget)
			timeText:SetPoint("bottomright", newBossWidget, "bottomright", 0, 0)
			newBossWidget.TimeText = timeText

			local timeBackground = detailsFramework:CreateImage(newBossWidget, "", 30, 12, "artwork")
			timeBackground:SetColorTexture(0, 0, 0, 0.8)
			timeBackground:SetPoint("topleft", timeText, "topleft", -2, 2)
			timeBackground:SetPoint("bottomright", timeText, "bottomright", 2, 0)

			dungeonChartFrame.BossWidgetsFrame.Widgets[i] = newBossWidget
			bossWidget = newBossWidget
		end

		local chartLength = chartFrame:GetWidth()
		local secondsPerPixel = chartLength / elapsedTime
		local xPosition = bossTable[1] * secondsPerPixel

		bossWidget:SetPoint("bottomright", chartFrame, "bottomleft", xPosition, 22)

		bossWidget.TimeText:SetText(detailsFramework:IntegerToTimer(bossTable[1]))

		if (bossTable[2].bossimage) then
			bossWidget.AvatarTexture:SetTexture(bossTable[2].bossimage)
		else
			local bossAvatar = Details:GetBossPortrait(nil, nil, bossTable[2].name, bossTable[2].ej_instance_id)
			bossWidget.AvatarTexture:SetTexture(bossAvatar)
		end
	end
end

function mythicDungeonCharts.CreateCloseMinimizeButtons(dungeonChartFrame)
	local fMinimized = mythicDungeonCharts.FrameMinimized

	local closeButton = CreateFrame("button", "$parentCloseButton", dungeonChartFrame, "UIPanelCloseButton")
	closeButton:GetNormalTexture():SetDesaturated(true)
	closeButton:SetWidth(24)
	closeButton:SetHeight(24)
	closeButton:SetPoint("topright", dungeonChartFrame, "topright", 0, -1)
	closeButton:SetFrameLevel(dungeonChartFrame:GetFrameLevel()+16)

	local minimizeButton = CreateFrame("button", "$parentCloseButton", dungeonChartFrame, "UIPanelCloseButton")
	minimizeButton:GetNormalTexture():SetDesaturated(true)
	minimizeButton:SetWidth(24)
	minimizeButton:SetHeight(24)
	minimizeButton:SetPoint("right", closeButton, "left", 2, 0)
	minimizeButton:SetFrameLevel(dungeonChartFrame:GetFrameLevel()+16)
	minimizeButton:SetNormalTexture([[Interface\BUTTONS\UI-Panel-HideButton-Up]])
	minimizeButton:SetPushedTexture([[Interface\BUTTONS\UI-Panel-HideButton-Down]])
	minimizeButton:SetHighlightTexture([[Interface\BUTTONS\UI-Panel-MinimizeButton-Highlight]])

	local closeButtonWhenMinimized = CreateFrame("button", "$parentCloseButton", fMinimized, "UIPanelCloseButton")
	closeButtonWhenMinimized:GetNormalTexture():SetDesaturated(true)
	closeButtonWhenMinimized:SetWidth(24)
	closeButtonWhenMinimized:SetHeight(24)
	closeButtonWhenMinimized:SetPoint("topright", fMinimized, "topright", 0, -1)
	closeButtonWhenMinimized:SetFrameLevel(fMinimized:GetFrameLevel()+16)

	local minimizeButtonWhenMinimized = CreateFrame("button", "$parentCloseButton", fMinimized, "UIPanelCloseButton")
	minimizeButtonWhenMinimized:GetNormalTexture():SetDesaturated(true)
	minimizeButtonWhenMinimized:SetWidth(24)
	minimizeButtonWhenMinimized:SetHeight(24)
	minimizeButtonWhenMinimized:SetPoint("right", closeButtonWhenMinimized, "left", 2, 0)
	minimizeButtonWhenMinimized:SetFrameLevel(fMinimized:GetFrameLevel()+16)
	minimizeButtonWhenMinimized:SetNormalTexture([[Interface\BUTTONS\UI-Panel-HideButton-Up]])
	minimizeButtonWhenMinimized:SetPushedTexture([[Interface\BUTTONS\UI-Panel-HideButton-Down]])
	minimizeButtonWhenMinimized:SetHighlightTexture([[Interface\BUTTONS\UI-Panel-MinimizeButton-Highlight]])

	closeButtonWhenMinimized:SetScript("OnClick", function()
		dungeonChartFrame.IsMinimized = false
		fMinimized:Hide()
		minimizeButtonWhenMinimized:SetNormalTexture([[Interface\BUTTONS\UI-Panel-HideButton-Up]])
		minimizeButtonWhenMinimized:SetPushedTexture([[Interface\BUTTONS\UI-Panel-HideButton-Down]])
	end)

	--replace the default click function
	local minimize_func = function(self)
		if (dungeonChartFrame.IsMinimized) then
			dungeonChartFrame.IsMinimized = false
			fMinimized:Hide()
			dungeonChartFrame:Show()
			minimizeButtonWhenMinimized:SetNormalTexture([[Interface\BUTTONS\UI-Panel-HideButton-Up]])
			minimizeButtonWhenMinimized:SetPushedTexture([[Interface\BUTTONS\UI-Panel-HideButton-Down]])
		else
			dungeonChartFrame.IsMinimized = true
			dungeonChartFrame:Hide()
			fMinimized:Show()
			minimizeButtonWhenMinimized:SetNormalTexture([[Interface\BUTTONS\UI-Panel-CollapseButton-Up]])
			minimizeButtonWhenMinimized:SetPushedTexture([[Interface\BUTTONS\UI-Panel-CollapseButton-Up]])
		end
	end

	minimizeButton:SetScript("OnClick", minimize_func)
	minimizeButtonWhenMinimized:SetScript("OnClick", minimize_func)
end

function mythicDungeonCharts.CreateBossWidgets(dungeonChartFrame)
	dungeonChartFrame.BossWidgetsFrame = CreateFrame("frame", "$parentBossFrames", dungeonChartFrame, "BackdropTemplate")
	dungeonChartFrame.BossWidgetsFrame:SetFrameLevel(dungeonChartFrame:GetFrameLevel()+10)
	dungeonChartFrame.BossWidgetsFrame.Widgets = {}

	dungeonChartFrame.BossWidgetsFrame.GraphPin = dungeonChartFrame.BossWidgetsFrame:CreateTexture(nil, "overlay")
	dungeonChartFrame.BossWidgetsFrame.GraphPin:SetTexture([[Interface\BUTTONS\UI-RadioButton]])
	dungeonChartFrame.BossWidgetsFrame.GraphPin:SetTexCoord(17/64, 32/64, 0, 1)
	dungeonChartFrame.BossWidgetsFrame.GraphPin:SetSize(16, 16)

	dungeonChartFrame.BossWidgetsFrame.GraphPinGlow = dungeonChartFrame.BossWidgetsFrame:CreateTexture(nil, "artwork")
	dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetTexture([[Interface\Calendar\EventNotificationGlow]])
	dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetTexCoord(0, 1, 0, 1)
	dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetSize(14, 14)
	dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetBlendMode("ADD")
	dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetPoint("center", dungeonChartFrame.BossWidgetsFrame.GraphPin, "center", 0, 0)
end