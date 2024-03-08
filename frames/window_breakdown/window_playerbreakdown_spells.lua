
--note: do maintenance on spelltable.ChartData

local addonName, Details222 = ...
local breakdownWindow = Details.BreakdownWindow
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local unpack = unpack
local GetTime = GetTime
local CreateFrame = CreateFrame
local GetSpellLink = GetSpellLink
local GetSpellInfo = GetSpellInfo
local _GetSpellInfo = Details.GetSpellInfo
local GameTooltip = GameTooltip
local IsShiftKeyDown = IsShiftKeyDown
local tinsert = table.insert

---@type detailsframework
local DF = DetailsFramework
---@type detailsframework
local detailsFramework = DetailsFramework

---@type breakdownspelltab
local spellsTab = {}
spellsTab.ReportOverlays = {}

function spellsTab.SetShownReportOverlay(bIsShown)
	for robIndex, ROB in ipairs(spellsTab.ReportOverlays) do
		ROB:SetShown(bIsShown)
	end
end

--expose the object to the global namespace
DetailsSpellBreakdownTab = spellsTab

local iconTableSummary = {
    texture = [[Interface\AddOns\Details\images\icons]],
    coords = {238/512, 255/512, 0, 18/512},
    width = 16,
    height = 16,
}

local CONST_BAR_HEIGHT = 20
local CONST_SPELLSCROLL_LINEHEIGHT = 20
local CONST_TARGET_TEXTURE = [[Interface\MINIMAP\TRACKING\Target]]
local CONST_SPELLBLOCK_DEFAULT_COLOR = {.4, .4, .4, 1}
local CONST_SPELLBLOCK_HEADERTEXT_COLOR = {.9, .8, 0, 1}
local CONST_SPELLBLOCK_HEADERTEXT_SIZE = 11

Details.SpellGroups = {
	[193473] = 15407, --mind flay
}

---return the actor currently in use by the breakdown window
---@return actor
function spellsTab.GetActor() --this cache must be cleared when the actor changes or the breakdown window is closed
	return spellsTab.currentActor
end

---return the combat currently in use by the breakdown window
---@return combat
function spellsTab.GetCombat() --must be cleared
	return spellsTab.combatObject
end

---@return instance
function spellsTab.GetInstance()
	return spellsTab.instance or Details:GetActiveWindowFromBreakdownWindow()
end

---set the backdrop of scrollframe and container following the settings of the breakdown window
---@param containerFrame frame
---@param scrollFrame frame|nil
function spellsTab.ApplyStandardBackdrop(containerFrame, scrollFrame)
	C_Timer.After(0, function()
		containerFrame:SetBackdrop(Details222.BreakdownWindow.BackdropSettings.backdrop)
		containerFrame:SetBackdropColor(unpack(Details222.BreakdownWindow.BackdropSettings.backdropcolor))
		containerFrame:SetBackdropBorderColor(unpack(Details222.BreakdownWindow.BackdropSettings.backdropbordercolor))

		if (scrollFrame) then
			scrollFrame:SetBackdrop({})
			if (scrollFrame["__background"]) then
				scrollFrame["__background"]:Hide()
			end
		end
	end)
end

---return the breakdownspellscrollframe object, there's only one of this in the breakdown window
---@return breakdownspellscrollframe
function spellsTab.GetSpellScrollFrame()
	return spellsTab.TabFrame.SpellScrollFrame
end

---return the breakdownspellblockframe object, there's only one of this in the breakdown window
---@return breakdownspellblockframe
function spellsTab.GetSpellBlockFrame()
	return spellsTab.TabFrame.SpellBlockFrame
end

---@return breakdowntargetscrollframe
function spellsTab.GetTargetScrollFrame()
	return spellsTab.TargetScrollFrame
end

---@return breakdownphasescrollframe
function spellsTab.GetPhaseScrollFrame()
	return spellsTab.PhaseScrollFrame
end

---@return breakdowngenericscrollframe, breakdowngenericscrollframe
function spellsTab.GetGenericScrollFrame()
	return spellsTab.GenericScrollFrameLeft, spellsTab.GenericScrollFrameRight
end

---@return df_framecontainer
function spellsTab.GetSpellScrollContainer()
	return spellsTab.SpellContainerFrame
end

---@return df_framecontainer
function spellsTab.GetSpellBlockContainer()
	return spellsTab.BlocksContainerFrame
end

---@return df_framecontainer
function spellsTab.GetTargetScrollContainer()
	return spellsTab.TargetsContainerFrame
end

---@return df_framecontainer
function spellsTab.GetPhaseScrollContainer()
	return spellsTab.PhaseContainerFrame
end

---@return df_framecontainer leftContainer, df_framecontainer rightContainer
function spellsTab.GetGenericScrollContainer()
	return spellsTab.GenericContainerFrameLeft, spellsTab.GenericContainerFrameRight
end

function spellsTab.GetScrollFrameByContainerType(containerType)
	if (containerType == "spells") then
		return spellsTab.GetSpellScrollFrame()

	elseif (containerType == "targets") then
		return spellsTab.GetTargetScrollFrame()

	elseif (containerType == "phases") then
		return spellsTab.GetPhaseScrollFrame()

	elseif (containerType == "generic_left") then
		local scrollFrameLeft = spellsTab.GetGenericScrollFrame()
		return scrollFrameLeft

	elseif (containerType == "generic_right") then
		local _, scrollFrameRight = spellsTab.GetGenericScrollFrame()
		return scrollFrameRight
	end
end

function spellsTab.OnProfileChange()
	--no need to cache, just call the db from there
	spellsTab.UpdateHeadersSettings("spells")
	spellsTab.UpdateHeadersSettings("targets")
	spellsTab.UpdateHeadersSettings("phases")
	spellsTab.UpdateHeadersSettings("generic_left")
	spellsTab.UpdateHeadersSettings("generic_right")
end

------------------------------------------------------------------------------------------------------------------------------------------------
--Header

---store the header object has key and its type as value, the header type can be 'spell' or 'target'
---@type table<uiobject, string>
local headerContainerType = {}
spellsTab.headerContainerType = headerContainerType

---@type number
local columnOffset = 0

---column header information saved into details database: if is enabaled, its with and align
local settingsPrototype = {
	enabled = true,
	width = 100,
	align = "left",
}

---contains the column settings for each header column, the table key is columnName and the value is headercolumndatasaved
---@class headercolumndatabase : table<string, headercolumndatasaved>

---headercolumndata goes inside the header table which is passed to the header constructor or header:SetHeaderTable()
---@class headercolumndata : {name:string, width:number, text:string, align:string, key:string, selected:boolean, canSort:boolean, dataType:string, order:string, offset:number, key:string}

---columndata is the raw table with all options which can be used to create a headertable, some may not be used due to settings or filtering
---@class columndata : {name:string, width:number, key:string, selected:boolean, label:string, align:string, enabled:boolean, attribute:number, canSort:boolean, dataType:string, order:string, offset:number}

---default settings for the header of the spells container, label is a localized string, name is a string used to save the column settings, key is the key used to get the value from the spell table, width is the width of the column, align is the alignment of the text, enabled is if the column is enabled, canSort is if the column can be sorted, sortKey is the key used to sort the column, dataType is the type of data the column is sorting, order is the order of the sorting, offset is the offset of the column
---@type columndata[]
local spellContainerColumnData = {
	--the align seems to be bugged as the left is aligning in the center and center is on the left side
	{name = "icon", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "target", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 16, align = "center", enabled = true, offset = 6, dataType = "number"},
	{name = "expand", label = "^", width = 16, align = "left", enabled = true, offset = -4}, --maybe -3
	{name = "name", label = "spell name", width = 231, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", selected = true, width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "persecond", label = "ps", key = "total", width = 50, align = "left", enabled = false, canSort = true, sortKey = "ps", offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "percent", label = "%", key = "total", width = 50, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "casts", label = "casts", key = "casts", width = 40, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "critpercent", label = "crit %", key = "critpercent", width = 40, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "hits", label = "hits", key = "counter", width = 40, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "castavg", label = "cast avg", key = "castavg", width = 50, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "uptime", label = "uptime", key = "uptime", width = 45, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "overheal", label = "overheal", key = "overheal", width = 70, align = "left", enabled = true, canSort = true, order = "DESC", dataType = "number", attribute = DETAILS_ATTRIBUTE_HEAL, offset = columnOffset},
	{name = "absorbed", label = "absorbed", key = "healabsorbed", width = 55, align = "left", enabled = false, canSort = true, order = "DESC", dataType = "number", attribute = DETAILS_ATTRIBUTE_HEAL, offset = columnOffset},
}

local targetContainerColumnData = {
	{name = "icon", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 20, align = "left", enabled = true, offset = columnOffset},
	{name = "name", label = "name", width = 185, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", selected = true, width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "overheal", label = "overheal", key = "overheal", width = 70, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset, attribute = DETAILS_ATTRIBUTE_HEAL},
	{name = "percent", label = "%", key = "total", width = 50, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
}
spellsTab.targetContainerColumnData = targetContainerColumnData

local phaseContainerColumnData = {
	{name = "icon", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "name", label = "name", width = 90, align = "left", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 30, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset, selected = true},
	{name = "persecond", label = "ps", key = "total", width = 44, align = "left", enabled = true, canSort = true, sortKey = "ps", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "percent", label = "%", key = "total", width = 44, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
}
spellsTab.phaseContainerColumnData = phaseContainerColumnData

--generic container can show data from any attribute
local genericContainerLeftColumnData = {
	{name = "icon", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 30, align = "left", enabled = true, offset = columnOffset},
	{name = "name", label = "name", width = 200, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset, selected = true},
	{name = "persecond", label = "ps", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "ps", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "percent", label = "%", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
}
spellsTab.genericContainerLeftColumnData = genericContainerLeftColumnData

--generic container can show data from any attribute
local genericContainerRightColumnData = {
	{name = "icon", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 30, align = "left", enabled = true, offset = columnOffset},
	{name = "name", label = "name", width = 190, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset, selected = true},
	{name = "persecond", label = "ps", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "percent", label = "%", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
}
spellsTab.genericContainerRightColumnData = genericContainerRightColumnData

---get the header settings from details saved variables and the container column data
---@param containerType "spells"|"targets"|"phases"|"generic_left"|"generic_right
---@return headercolumndatabase
---@return columndata
function spellsTab.GetHeaderSettings(containerType)
	local settings
	---@type headercolumndata
	local containerColumnData

	if (containerType == "spells") then
		settings = Details.breakdown_spell_tab.spellcontainer_headers
		containerColumnData = spellContainerColumnData

	elseif (containerType == "targets") then
		settings = Details.breakdown_spell_tab.targetcontainer_headers
		containerColumnData = targetContainerColumnData

	elseif (containerType == "phases") then
		settings = Details.breakdown_spell_tab.phasecontainer_headers
		containerColumnData = phaseContainerColumnData

	elseif (containerType == "generic_left") then
		settings = Details.breakdown_spell_tab.genericcontainer_headers
		containerColumnData = genericContainerLeftColumnData

		--as the generic data is received, it may have which columns can be shown
		if (spellsTab.headersAllowed) then
			for index, columnData in ipairs(containerColumnData) do
				local newEnabledState = spellsTab.headersAllowed[columnData.name] or false
				columnData.enabled = newEnabledState
				--check if the settings already has the data, and then set the header enabled value to follow the headersAllowed table
				if (settings[columnData.name]) then
					settings[columnData.name].enabled = newEnabledState
				end
			end
		end

	elseif (containerType == "generic_right") then
		settings = Details.breakdown_spell_tab.genericcontainer_headers_right
		containerColumnData = genericContainerRightColumnData

		--as the generic data is received, it may have which columns can be shown
		if (spellsTab.headersAllowed) then
			for index, columnData in ipairs(containerColumnData) do
				local newEnabledState = spellsTab.headersAllowed[columnData.name] or false
				columnData.enabled = newEnabledState
				--check if the settings already has the data, and then set the header enabled value to follow the headersAllowed table
				if (settings[columnData.name]) then
					settings[columnData.name].enabled = newEnabledState
				end
			end
		end
	end

	---@cast settings headercolumndatabase
	return settings, containerColumnData
end

---callback for when the user resizes a column on the header
---@param headerFrame df_headerframe
---@param optionName string
---@param columnName string
---@param value any
function spellsTab.OnHeaderColumnOptionChanged(headerFrame, optionName, columnName, value)
	---@type "spells"|"targets"|"phases"|"generic_left"|"generic_right"
	local containerType = headerContainerType[headerFrame]
	---@type headercolumndatabase
	local settings = spellsTab.GetHeaderSettings(containerType)

	settings[columnName][optionName] = value
	spellsTab.UpdateHeadersSettings(containerType)
end

function spellsTab.OnAnyColumnHeaderClickCallback()
	local instance = spellsTab.GetInstance()
	instance:RefreshWindow(true)
end

---copy settings from the ColumnInfo table which doesn't exists in the details profile
---this is called when the profile changes or when the tab is opened with a different actor than before
---@param containerType "spells"|"targets"|"phases"|"generic_left"|"generic_right"
function spellsTab.UpdateHeadersSettings(containerType)
	---details table which hold the settings for a container header
	local settings, containerColumnData = spellsTab.GetHeaderSettings(containerType)

	--do a loop and check if the column data from columnInfo exists in the details profile settings, if not, add it
	for i = 1, #containerColumnData do
		--default column settings
		local columnData = containerColumnData[i]
		---@type string
		local columnName = columnData.name

		--column settings for the column on details profile
		---@type headercolumndatasaved
		local columnSettings = settings[columnName]

		--check if this column does not have a mirror table in details profile
		if (not columnSettings) then
			--create a table in Details! saved variables to save the column settings
			---@type headercolumndatasaved
			local newColumnSettings = DetailsFramework.table.copy({}, settingsPrototype)
			settings[columnName] = newColumnSettings

			newColumnSettings.enabled = columnData.enabled
			newColumnSettings.width = columnData.width
			newColumnSettings.align = columnData.align
		end
	end

	if (containerType == "spells") then
		spellsTab.spellsHeaderData = spellsTab.BuildHeaderTable(containerType)

		local spellContainer = spellsTab.GetSpellScrollContainer()
		local spellScrollFrame = spellsTab.GetSpellScrollFrame()

		local headerFrame = spellScrollFrame.Header
		headerFrame:SetHeaderTable(spellsTab.spellsHeaderData)

		local width = headerFrame:GetWidth()

		--SetHeaderTable() calls Header:Refresh() which reset its width
		--if the spell container get a resize to be as big as the sum of all columns width, the option to resize the container's width is useless
		spellContainer:SetWidth(width)
		--save the width of the spell container in Details settings
		Details.breakdown_spell_tab.spellcontainer_width = width

	elseif (containerType == "targets") then
		spellsTab.targetsHeaderData = spellsTab.BuildHeaderTable(containerType)
		spellsTab.GetTargetScrollFrame().Header:SetHeaderTable(spellsTab.targetsHeaderData)

		local width = spellsTab.GetTargetScrollFrame().Header:GetWidth()
		spellsTab.GetTargetScrollContainer():SetWidth(width)

		--save the width of the target container in Details settings
		Details.breakdown_spell_tab.targetcontainer_width = width

	elseif (containerType == "phases") then
		spellsTab.phasesHeaderData = spellsTab.BuildHeaderTable(containerType)
		spellsTab.GetPhaseScrollFrame().Header:SetHeaderTable(spellsTab.phasesHeaderData)

	elseif (containerType == "generic_left") then
		spellsTab.genericHeaderData = spellsTab.BuildHeaderTable(containerType)
		spellsTab.GetGenericScrollFrame().Header:SetHeaderTable(spellsTab.genericHeaderData)

	elseif (containerType == "generic_right") then
		spellsTab.genericHeaderData = spellsTab.BuildHeaderTable(containerType)
		spellsTab.GetGenericScrollFrame().Header:SetHeaderTable(spellsTab.genericHeaderData)
	end
end

---get the header settings from details profile and build a header table using the table which store all headers columns information
---the data for each header is stored on 'spellContainerColumnInfo' and 'targetContainerColumnInfo' variables
---@param containerType "spells"|"targets"|"phases"|"generic_left"|"generic_right"
---@return {name: string, width: number, text: string, align: string}[]
function spellsTab.BuildHeaderTable(containerType)
	---@type headercolumndata[]
	local headerTable = {}

    ---@type instance
    local instance = spellsTab.GetInstance()

	---@type number, number
	local mainAttribute, subAttribute = instance:GetDisplay()

	--settings from profile | updated at UpdateHeadersSettings() > called on OnProfileChange() and when the tab is opened
	local settings, containerColumnData = spellsTab.GetHeaderSettings(containerType)

	---result of the sum of all columns width
	---@type number
	local totalWidth = 0

	for i = 1, #containerColumnData do
		local columnData = containerColumnData[i]
		---@type headercolumndatasaved
		local columnSettings = settings[columnData.name]

		if (columnSettings.enabled) then
			local bCanAdd = true
			if (columnData.attribute) then
				if (columnData.attribute ~= mainAttribute) then
					bCanAdd = false
				end
			end

			if (bCanAdd) then
				---@type headercolumndata
				local headerColumnData = {
					width = columnSettings.width,
					text = columnData.label,
					name = columnData.name,

					--these values may be nil
					selected = columnData.selected,
					align = columnData.align,
					canSort = columnData.canSort,
					dataType = columnData.dataType,
					order = columnData.order,
					offset = columnData.offset,
					key = columnData.key,
				}

				totalWidth = totalWidth + headerColumnData.width
				headerTable[#headerTable+1] = headerColumnData
			end
		end
	end

	return headerTable
end

------------------------------------------------------------------------------------------------------------------------------------------------
--Bar Selection

--store the current spellbar selected, this is used to lock the spellblock container to the spellbar selected
spellsTab.selectedSpellBar = nil

---selected a breakdownspellbar, locking into the bar
---when a breakdownspellbar is selected, all the other breakdownspellbar has it's hover over disabled
---@param spellBar breakdownspellbar
function spellsTab.SelectSpellBar(spellBar)
	--if already has a spellbar selected, unselect it
	if (spellsTab.HasSelectedSpellBar()) then --unselect and stop the function if the bar selected is the same as the one being selected
		if (spellsTab.GetSelectedSpellBar() == spellBar) then
			spellsTab.UnSelectSpellBar()
			return
		else
			spellsTab.UnSelectSpellBar()
		end
	end

	--as the spell block container get an update when hovering over
	--update the spell block container for the breakdownspellbar just selected
	--this is necessary since a previous breakdownspellbar could have been selected and prevented this breakdownspellbar to update on hover over
	---@type function
	local onEnterScript = spellBar:GetScript("OnEnter")
	if (onEnterScript) then
		onEnterScript(spellBar)
	end

	--set the new breakdownspellbar as selected
	spellsTab.selectedSpellBar = spellBar
	spellsTab.selectedSpellBar.overlayTexture:Show()
end

---deselect the breakdownspellbar
function spellsTab.UnSelectSpellBar()
	if (spellsTab.selectedSpellBar) then
		spellsTab.selectedSpellBar.overlayTexture:Hide()
	end
	spellsTab.selectedSpellBar = nil
end

---get the spellbar currently selected
---@return breakdownspellbar
function spellsTab.GetSelectedSpellBar()
	return spellsTab.selectedSpellBar
end

---return true if there's a spell bar selected
---@return boolean
function spellsTab.HasSelectedSpellBar()
	return spellsTab.selectedSpellBar ~= nil
end

function spellsTab.OnShownTab()
	--unselect any selected breakdownspellbar
	spellsTab.UnSelectSpellBar()
	--reset the spell blocks
	spellsTab.GetSpellBlockFrame():ClearBlocks()
	--update spells and target header frame (spellscroll and targetscroll)
	spellsTab.UpdateHeadersSettings("spells")
	spellsTab.UpdateHeadersSettings("targets")
	spellsTab.UpdateHeadersSettings("phases")
	spellsTab.UpdateHeadersSettings("generic_left")
	spellsTab.UpdateHeadersSettings("generic_right")

	spellsTab.SetShownReportOverlay(false)
end

---called when the tab is getting created, run only once
---@param tabButton button
---@param tabFrame breakdownspellstab
function spellsTab.OnCreateTabCallback(tabButton, tabFrame) --~init
	spellsTab.TabFrame = tabFrame

	--initialize the allowed headers for generic data container
	spellsTab.headersAllowed = {icon = true, name = true, rank = true, amount = true, persecond = true, percent = true}

    --create the scrollbar to show the spells in the breakdown window
    spellsTab.CreateSpellScrollContainer(tabFrame) --finished
    --create the 6 spell blocks in the right side of the breakdown window, these blocks show the spell info like normal hits, critical hits, average, etc
    spellsTab.CreateSpellBlockContainer(tabFrame)
    --create the targets container
    spellsTab.CreateTargetContainer(tabFrame)
	--create phases container
	spellsTab.CreatePhasesContainer(tabFrame)
	--create generic container
	spellsTab.CreateGenericContainers(tabFrame)

    --create the report buttons for each container
    --spellsTab.CreateReportButtons(tabFrame)

	--create a button in the breakdown window to open the options for this tab
	local optionsButton = DF:CreateButton(tabFrame, Details.OpenSpellBreakdownOptions, 130, 18, Loc["STRING_OPTIONS_PLUGINS_OPTIONS"], 14)
	--optionsButton:SetTemplate(DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
	optionsButton:SetPoint("bottomright", tabFrame, "bottomright", -10, -16)
	optionsButton:SetTemplate("STANDARD_GRAY")
	optionsButton:SetIcon(Details:GetTextureAtlas("breakdown-icon-optionsbutton"))
	optionsButton.textsize = 12
	optionsButton.textcolor = "DETAILS_STATISTICS_ICON"
	optionsButton:SetAlpha(0.834)

	--create a report button
	local onClickReportButton = function(blizButton, buttonType, param1, param2)
		if (spellsTab.ReportOverlays[1]:IsShown()) then
			spellsTab.SetShownReportOverlay(false)
		else
			spellsTab.SetShownReportOverlay(true)
		end
	end

	---~report
	local reportScrollContents = function(self, buttonPressed)
		local scrollFrame = self.scrollFrame

		---@type breakdownreporttable
		local reportData = scrollFrame:GetReportData()
		local reportDataBuilt = {reportData.title}

		for i = 1, #reportData do
			local data = reportData[i]
			local str = data.name .. " ...... " .. data.amount .. "  (" .. data.percent .. ")"
			reportDataBuilt[#reportDataBuilt+1] = str
		end

		spellsTab.SetShownReportOverlay(false)

		Details:Reportar(reportDataBuilt, {_no_current = true, _no_inverse = true, _custom = true})
	end

	--create a report overlay for each of the containers
	local createReportOverlay = function(scrollFrame)
		local reportOverlayButton = CreateFrame("button", "DetailsSpellScrollSelectionButton", scrollFrame, "BackdropTemplate")
		local ROB = reportOverlayButton

		spellsTab.ReportOverlays[#spellsTab.ReportOverlays+1] = ROB

		--backdrop
		ROB:SetBackdrop({
			edgeFile = [[Interface\AddOns\Details\images\border_2]],
			edgeSize = 16,
		})

		ROB:SetFrameLevel(scrollFrame:GetFrameLevel()+5)
		ROB:SetAllPoints()
		ROB:EnableMouse(true)

		local backgroundTexture = ROB:CreateTexture("DetailsSpellScrollSelectionButtonTexture", "overlay")
		--instead of all point, do topleft and bottomright
		backgroundTexture:SetPoint("topleft", ROB, "topleft", 0, 0)
		backgroundTexture:SetPoint("bottomright", ROB, "bottomright", 0, 0)
		ROB.backgroundTexture = backgroundTexture

		backgroundTexture:SetColorTexture(.1, .1, .1, 0.834)

		local text = ROB:CreateFontString(nil, "overlay", "GameFontNormal")
		text:SetText("REPORT")
		text:SetTextColor(1, 1, 1, 1)
		text:SetPoint("center", ROB, "center", 0, 0)
		ROB.reportText = text

		ROB.scrollFrame = scrollFrame
		ROB:SetScript("OnClick", reportScrollContents)

		ROB:Hide()
	end

	createReportOverlay(spellsTab.GetSpellScrollFrame())
	createReportOverlay(spellsTab.GetTargetScrollFrame())
	createReportOverlay(spellsTab.GetPhaseScrollFrame())
	createReportOverlay(spellsTab.GetGenericScrollFrame())

	local reportButton = DF:CreateButton(tabFrame, onClickReportButton, 130, 18, Loc["STRING_REPORT_TEXT"], 1, 2) --will have a text?
	reportButton:SetPoint("right", optionsButton, "left", -5, 0)
	reportButton.textsize = 12
	reportButton.textcolor = "DETAILS_STATISTICS_ICON"
	reportButton:SetTemplate("STANDARD_GRAY")
	reportButton:SetIcon(Details:GetTextureAtlas("breakdown-icon-reportbutton"))
	reportButton:SetAlpha(0.834)

	--open the breakdown window at startup for testing
	--[=[ debug
	C_Timer.After(1, function()
		Details:OpenPlayerDetails(1)
		C_Timer.After(1, function()
			Details:OpenPlayerDetails(1)
			Details:OpenPlayerDetails(1)
		end)
	end)
	--]=]
end

function spellsTab.UpdateBarSettings(bar)
	if (bar.statusBar) then
		bar.statusBar:SetAlpha(Details.breakdown_spell_tab.statusbar_alpha) --could be moved to when the bar is updated

		--bar.statusBar:GetStatusBarTexture():SetTexture(Details.breakdown_spell_tab.statusbar_texture)
		Details222.BreakdownWindow.ApplyTextureSettings(bar.statusBar)

		--bar.statusBar.backgroundTexture:SetColorTexture(unpack(Details.breakdown_spell_tab.statusbar_background_color))
		--bar.statusBar.backgroundTexture:SetAlpha(Details.breakdown_spell_tab.statusbar_background_alpha)

		detailsFramework:SetTemplate(bar.statusBar.backgroundTexture, "STANDARD_GRAY")
	end
end

-----------------------------------------------------------------------------------------------------------------------
--> create the new tab
function Details.InitializeSpellBreakdownTab()
	local tabButton, tabFrame = Details:CreatePlayerDetailsTab(
		"Summary", --[1] tab name
		Loc ["STRING_SPELLS"], --[2] localized name
		function(tabOBject, playerObject) --[3] condition
			if (playerObject) then
				return true
			else
				return false
			end
		end,

		function() --[4] fill function | passing a fill function, it'll set a OnShow() script on the tabFrame | only run if the actor is different
			spellsTab.OnShownTab()
		end,

		function(tabButton, tabFrame) --[5] onclick
			tabFrame:Show()
		end,

		spellsTab.OnCreateTabCallback, --[6] oncreate
		iconTableSummary, --[7] icon table
		nil, --[8] replace tab
		true --[9] is default tab
	)

	spellsTab.TabButton = tabButton
	spellsTab.TabFrame = tabFrame

	---on receive data from a class
	---@param data breakdownspelldatalist
	---@param actorObject actor
	---@param combatObject combat
	---@param instance instance
	function tabButton.OnReceiveSpellData(data, actorObject, combatObject, instance)
		spellsTab.currentActor = actorObject
		spellsTab.combatObject = combatObject
		spellsTab.instance = instance

		---@type number, number
		local mainAttribute, subAttribute = instance:GetDisplay()
		spellsTab.mainAttribute = mainAttribute
		spellsTab.subAttribute = subAttribute

		--show the regular containers
		spellsTab.GetSpellScrollContainer():Show()
		spellsTab.GetPhaseScrollContainer():Show()
		spellsTab.GetTargetScrollContainer():Show()
		spellsTab.GetSpellBlockContainer():Show()

		--hide the generic container
		local genericScrollContainerLeft, genericScrollContainerRight = spellsTab.GetGenericScrollContainer()
		genericScrollContainerLeft:Hide()
		genericScrollContainerRight:Hide()

		--refresh the data
		spellsTab.GetSpellScrollFrame():RefreshMe(data)
		spellsTab.GetPhaseScrollFrame():RefreshMe(data)
	end

	---called right after the OnReceiveSpellData() call
	---@param data breakdowntargettablelist
	---@param actorObject actor
	---@param combatObject combat
	---@param instance instance
	function tabButton.OnReceiveTargetData(data, actorObject, combatObject, instance)
		---@type number, number
		local mainAttribute, subAttribute = instance:GetDisplay()
		spellsTab.mainAttribute = mainAttribute
		spellsTab.subAttribute = subAttribute
		spellsTab.GetTargetScrollFrame():RefreshMe(data)
	end

	---when the window handler sends data which is not a spell or target data
	---@param data table
	---@param actorObject actor
	---@param combatObject combat
	---@param instance instance
	function tabButton.OnReceiveGenericData(data, actorObject, combatObject, instance)
		---@type number, number
		local mainAttribute, subAttribute = instance:GetDisplay()
		spellsTab.mainAttribute = mainAttribute
		spellsTab.subAttribute = subAttribute

		spellsTab.currentActor = actorObject
		spellsTab.combatObject = combatObject
		spellsTab.instance = instance

		if (spellsTab.headersAllowed ~= data.headersAllowed) then
			--refresh the header frame
			spellsTab.UpdateHeadersSettings("generic_left")
			--bug: now allowing to sort
		end

		--when generic data is shown, the damage-healing-targets-scrolls / spell details blocks/ can be removed
		spellsTab.GetSpellScrollContainer():Hide()
		spellsTab.GetPhaseScrollContainer():Hide()
		spellsTab.GetTargetScrollContainer():Hide()
		spellsTab.GetSpellBlockContainer():Hide()

		--show the generic scroll
		local genericScrollContainerLeft, genericScrollContainerRight = spellsTab.GetGenericScrollContainer()
		genericScrollContainerLeft:Show()
		genericScrollContainerRight:Show()

		--refresh the data
		spellsTab.GetGenericScrollFrame():RefreshMe(data)
	end

	---@type detailseventlistener
	local eventListener = Details:CreateEventListener()
	eventListener:RegisterEvent("DETAILS_PROFILE_APPLYED", function()
		--this event don't trigger at details startup
		spellsTab.OnProfileChange()
	end)
end

-----------------------------------------------------------------------------------------------------------------------
--> report data

function spellsTab.CreateReportButtons(tabFrame) --deprecated?
    --spell list report button
	tabFrame.report_esquerda = Details.gump:NewDetailsButton(tabFrame, tabFrame, nil, Details.Reportar, tabFrame, 1, 16, 16, "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport2")
	tabFrame.report_esquerda:SetPoint("bottomleft", spellsTab.GetSpellScrollFrame(), "TOPLEFT",  33, 3)
	tabFrame.report_esquerda:SetFrameLevel(tabFrame:GetFrameLevel()+2)
	tabFrame.topleft_report = tabFrame.report_esquerda

	--targets report button
	tabFrame.report_alvos = Details.gump:NewDetailsButton(tabFrame, tabFrame, nil, Details.Reportar, tabFrame, 3, 16, 16,	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport3")
	tabFrame.report_alvos:SetPoint("bottomright", tabFrame.container_alvos, "TOPRIGHT",  -2, -1)
	tabFrame.report_alvos:SetFrameLevel(3) --solved inactive problem

	--special barras in the right report button
	tabFrame.report_direita = Details.gump:NewDetailsButton(tabFrame, tabFrame, nil, Details.Reportar, tabFrame, 2, 16, 16, "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport4")
	tabFrame.report_direita:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT",  -10, -70)
	tabFrame.report_direita:Show()
end

function spellsTab.monta_relatorio(botao) --deprecated?
    ---@type attributeid
	local mainSection = breakdownWindow.atributo
    ---@type attributeid
	local subSection = breakdownWindow.sub_atributo
    ---@type actor
	local player = breakdownWindow.jogador
    ---@type instance
	local instance = breakdownWindow.instancia
    ---@type number
    local amt = Details.report_lines

    local tabFrame = spellsTab.TabFrame

	if (not player) then
		Details:Msg("Player not found.")
		return
	end

	local report_lines

	if (botao == 1) then --spell data
		if (mainSection == 1 and subSection == 4) then --friendly fire
			report_lines = {"Details!: " .. player.nome .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] .. ":"}

		elseif (mainSection == 1 and subSection == 3) then --damage taken
			report_lines = {"Details!: " .. player.nome .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"] .. ":"}

		else
			report_lines = {"Details!: " .. player.nome .. " - " .. Details.sub_atributos [mainSection].lista [subSection] .. ""}
		end

		for index, barra in ipairs(tabFrame.barras1) do
			if (barra:IsShown()) then
				local spellid = barra.show
				if (mainSection == 1 and subSection == 4) then --friendly fire
					report_lines [#report_lines+1] = barra.lineText1:GetText() .. ": " .. barra.lineText4:GetText()

				elseif (type(spellid) == "number" and spellid > 10) then
					local link = GetSpellLink(spellid)
					report_lines [#report_lines+1] = index .. ". " .. link .. ": " .. barra.lineText4:GetText()
				else
					local spellname = barra.lineText1:GetText():gsub((".*%."), "")
					spellname = spellname:gsub("|c%x%x%x%x%x%x%x%x", "")
					spellname = spellname:gsub("|r", "")
					report_lines [#report_lines+1] = index .. ". " .. spellname .. ": " .. barra.lineText4:GetText()
				end
			end

			if (index == amt) then
				break
			end
		end

	elseif (botao == 3) then --targets
		if (mainSection == 1 and subSection == 3) then
			Details:Msg(Loc ["STRING_ACTORFRAME_NOTHING"])
			return
		end

		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTARGETS"] .. " " .. Details.sub_atributos [1].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome}

		for index, barra in ipairs(tabFrame.barras2) do
			if (barra:IsShown()) then
				report_lines[#report_lines+1] = barra.lineText1:GetText().. " -> " .. barra.lineText4:GetText()
			end
			if (index == amt) then
				break
			end
		end

	elseif (botao == 2) then --spell blocks
        --dano --damage done --dps --heal
		if ((mainSection == 1 and (subSection == 1 or subSection == 2)) or (mainSection == 2)) then
			if (not player.detalhes) then
				Details:Msg(Loc ["STRING_ACTORFRAME_NOTHING"])
				return
			end

			local nome = _GetSpellInfo(player.detalhes)

			report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. Details.sub_atributos [mainSection].lista [subSection] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome,
			Loc ["STRING_ACTORFRAME_SPELLDETAILS"] .. ": " .. nome}

			for i = 1, 5 do
				local caixa = Details.BreakdownWindowFrame.grupos_detalhes[i]
				if (caixa.bg:IsShown()) then

					local linha = ""

					local nome2 = caixa.nome2:GetText() --golpes
					if (nome2 and nome2 ~= "") then
						if (i == 1) then
							linha = linha..nome2 .. " / "
						else
							linha = linha .. caixa.nome:GetText() .. " " .. nome2 .. " / "
						end
					end

					local dano = caixa.dano:GetText() --dano
					if (dano and dano ~= "") then
						linha = linha .. dano .. " / "
					end

					local media = caixa.dano_media:GetText() --media
					if (media and media ~= "") then
						linha = linha..media .. " / "
					end

					local dano_dps = caixa.dano_dps:GetText()
					if (dano_dps and dano_dps ~= "") then
						linha = linha..dano_dps.." / "
					end

					local dano_porcento = caixa.dano_porcento:GetText()
					if (dano_porcento and dano_porcento ~= "") then
						linha = linha..dano_porcento.." "
					end

					report_lines [#report_lines+1] = linha
				end

				if (i == amt) then
					break
				end
			end

		--dano --damage tanken
		elseif ( (mainSection == 1 and subSection == 3) or mainSection == 3) then
			if (player.detalhes) then
				report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. Details.sub_atributos [1].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.detalhes.. " " .. Loc ["STRING_ACTORFRAME_REPORTAT"] .. " " .. player.nome}
				for index, barra in ipairs(tabFrame.barras3) do
					if (barra:IsShown()) then
						report_lines [#report_lines+1] = barra.lineText1:GetText() .. " ....... " .. barra.lineText4:GetText()
					end
					if (index == amt) then
						break
					end
				end
			else
				report_lines = {}
			end
		end

	elseif (botao >= 11) then --primeira caixa dos detalhes
		botao =  botao - 10

		local nome
		if (type(spellid) == "string") then --unknown spellid value
			--is a pet
		else
			nome = _GetSpellInfo(player.detalhes)
			local spelllink = GetSpellLink(player.detalhes)
			if (spelllink) then
				nome = spelllink
			end
		end

		if (not nome) then
			nome = ""
		end

		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. Details.sub_atributos [mainSection].lista [subSection].. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome,
		Loc ["STRING_ACTORFRAME_SPELLDETAILS"] .. ": " .. nome}

		local caixa = Details.BreakdownWindowFrame.grupos_detalhes[botao]

		local linha = ""
		local nome2 = caixa.nome2:GetText() --golpes
		if (nome2 and nome2 ~= "") then
			if (botao == 1) then
				linha = linha .. nome2 .. " / "
			else
				linha = linha .. caixa.nome:GetText() .. " " .. nome2 .. " / "
			end
		end

		local dano = caixa.dano:GetText() --dano
		if (dano and dano ~= "") then
			linha = linha..dano.." / "
		end

		local media = caixa.dano_media:GetText() --media
		if (media and media ~= "") then
			linha = linha..media.." / "
		end

		local dano_dps = caixa.dano_dps:GetText()
		if (dano_dps and dano_dps ~= "") then
			linha = linha..dano_dps.." / "
		end

		local dano_porcento = caixa.dano_porcento:GetText()
		if (dano_porcento and dano_porcento ~= "") then
			linha = linha..dano_porcento.." "
		end

		--remove a cor da school
		linha = linha:gsub("|c%x?%x?%x?%x?%x?%x?%x?%x?", "")
		linha = linha:gsub("|r", "")

		report_lines [#report_lines+1] = linha
	end

	return instance:envia_relatorio(report_lines)
end
