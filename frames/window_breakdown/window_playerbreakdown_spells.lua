
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
local DF = DetailsFramework
local tinsert = tinsert

---@type breakdownspelltab
local spellsTab = {}

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

---@return breakdowngenericscrollframe
function spellsTab.GetGenericScrollFrame()
	return spellsTab.GenericScrollFrame
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

---@return df_framecontainer
function spellsTab.GetGenericScrollContainer()
	return spellsTab.GenericContainerFrame
end

function spellsTab.GetScrollFrameByContainerType(containerType)
	if (containerType == "spells") then
		return spellsTab.GetSpellScrollFrame()

	elseif (containerType == "targets") then
		return spellsTab.GetTargetScrollFrame()

	elseif (containerType == "phases") then
		return spellsTab.GetPhaseScrollFrame()

	elseif (containerType == "generic") then
		return spellsTab.GetGenericScrollFrame()
	end
end

function spellsTab.OnProfileChange()
	--no need to cache, just call the db from there
	spellsTab.UpdateHeadersSettings("spells")
	spellsTab.UpdateHeadersSettings("targets")
	spellsTab.UpdateHeadersSettings("phases")
	spellsTab.UpdateHeadersSettings("generic")
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

local phaseContainerColumnData = {
	{name = "icon", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "name", label = "name", width = 90, align = "left", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 30, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset, selected = true},
	{name = "persecond", label = "ps", key = "total", width = 44, align = "left", enabled = true, canSort = true, sortKey = "ps", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "percent", label = "%", key = "total", width = 44, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
}

--generic container can show data from any attribute
local genericContainerColumnData = {
	{name = "icon", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "name", label = "name", width = 200, align = "left", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 30, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset, selected = true},
	{name = "persecond", label = "ps", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "ps", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "percent", label = "%", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
}

---get the header settings from details saved variables and the container column data
---@param containerType "spells"|"targets"|"phases"|"generic"
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

	elseif (containerType == "generic") then
		settings = Details.breakdown_spell_tab.genericcontainer_headers
		containerColumnData = genericContainerColumnData

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
	---@type "spells"|"targets"|"phases"|"generic"
	local containerType = headerContainerType[headerFrame]
	---@type headercolumndatabase
	local settings = spellsTab.GetHeaderSettings(containerType)

	settings[columnName][optionName] = value
	spellsTab.UpdateHeadersSettings(containerType)
end

local onAnyColumnHeaderClickCallback = function()
	local instance = spellsTab.GetInstance()
	instance:RefreshWindow(true)
end

---copy settings from the ColumnInfo table which doesn't exists in the details profile
---this is called when the profile changes or when the tab is opened with a different actor than before
---@param containerType "spells"|"targets"|"phases"|"generic"
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

	elseif (containerType == "generic") then
		spellsTab.genericHeaderData = spellsTab.BuildHeaderTable(containerType)
		spellsTab.GetGenericScrollFrame().Header:SetHeaderTable(spellsTab.genericHeaderData)
	end
end

---get the header settings from details profile and build a header table using the table which store all headers columns information
---the data for each header is stored on 'spellContainerColumnInfo' and 'targetContainerColumnInfo' variables
---@param containerType "spells"|"targets"|"phases"|"generic"
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
	spellsTab.UpdateHeadersSettings("generic")
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
	spellsTab.CreateGenericContainer(tabFrame)

    --create the report buttons for each container
    --spellsTab.CreateReportButtons(tabFrame)

	--create a button in the breakdown window to open the options for this tab
	local optionsButton = DF:CreateButton(tabFrame, Details.OpenSpellBreakdownOptions, 130, 20, "options", 14, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
	optionsButton:SetPoint("bottomright", tabFrame, "bottomright", -5, 5)
	optionsButton.textsize = 16
	optionsButton.textcolor = "yellow"

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

---------------------------------------------------------------------------------------------------
--Targets


---get a target bar from the scroll box, if it doesn't exist, return nil
---@param scrollFrame table
---@param lineIndex number
---@return breakdowntargetbar
local getTargetBar = function(scrollFrame, lineIndex)
	---@type breakdowntargetbar
	local targetBar = scrollFrame:GetLine(lineIndex)

	--reset header alignment
	targetBar:ResetFramesToHeaderAlignment()

	spellsTab.UpdateBarSettings(targetBar)

	--reset columns, hiding them
	targetBar.Icon:Hide()
	for inLineIndex = 1, #targetBar.InLineTexts do
		targetBar.InLineTexts[inLineIndex]:SetText("")
	end

	return targetBar
end


---update a line using the data passed
---@param targetBar breakdowntargetbar
---@param index number spell position (from best to wrost)
---@param combatObject combat
---@param scrollFrame table
---@param headerTable table
---@param bkTargetData breakdowntargettable
---@param totalValue number
---@param topValue number the amount done of the first target, used to calculate the length of the statusbar
---@param sortKey string
local updateTargetBar = function(targetBar, index, combatObject, scrollFrame, headerTable, bkTargetData, totalValue, topValue, sortKey) --~target ~update ~targetbar ~updatetargetbar
	--scrollFrame is defined as a table which is false, scrollFrame is a frame

	local textIndex = 1

	for headerIndex = 1, #headerTable do
		---@type number
		local value

		targetBar.bkTargetData = bkTargetData
		value = bkTargetData.total

		---@type number
		local combatTime = combatObject:GetCombatTime()

		local actorContainer = combatObject:GetContainer(spellsTab.mainAttribute)
		local targetActorObject = actorContainer:GetActor(bkTargetData.name)

		targetBar.statusBar.backgroundTexture:SetAlpha(Details.breakdown_spell_tab.spellbar_background_alpha)

		--statusbar size by percent
		if (topValue > 0) then
			targetBar.statusBar:SetValue(bkTargetData[sortKey] / topValue * 100)
		else
			targetBar.statusBar:SetValue(0)
		end

		--statusbar color
		targetBar.statusBar:SetStatusBarColor(1, 1, 1, 1)
		targetBar.combatTime = combatTime
		targetBar.actorName = bkTargetData.name

		---@type fontstring
		local text = targetBar.InLineTexts[textIndex]
		local header = headerTable[headerIndex]

		if (header.name == "icon") then --ok
			targetBar.Icon:Show()

			if (targetActorObject) then
				Details.SetClassIcon(targetActorObject, targetBar.Icon, spellsTab.GetInstance(), targetActorObject:Class())
			else
				targetBar.Icon:SetTexture([[Interface\AddOns\Details\images\classes_small_alpha]])
				---@type {key1: number, key2: number, key3: number, key4: number}
				local texCoords = Details.class_coords["ENEMY"]
				targetBar.Icon:SetTexCoord(unpack(texCoords))
			end

			targetBar:AddFrameToHeaderAlignment(targetBar.Icon)

		elseif (header.name == "rank") then --ok
			text:SetText(index)
			targetBar:AddFrameToHeaderAlignment(text)
			targetBar.rank = index
			textIndex = textIndex + 1

		elseif (header.name == "name") then --ok
			text:SetText(DF:RemoveRealmName(bkTargetData.name))
			targetBar.name = bkTargetData.name
			targetBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "amount") then --ok
			text:SetText(Details:Format(value))
			targetBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "percent") then --ok
			targetBar.percent = value / totalValue * 100 --totalValue is nil
			---@type string
			local percentFormatted = string.format("%.1f", targetBar.percent) .. "%"
			text:SetText(percentFormatted)

			targetBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "overheal" and bkTargetData.overheal) then
			if (bkTargetData.overheal > 0) then
				local totalHeal = bkTargetData.overheal + value
				text:SetText(string.format("%.1f", bkTargetData.overheal / totalHeal * 100) .. "%")
			else
				text:SetText("0%")
			end
			targetBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "absorbed") then
			text:SetText(Details:Format(bkTargetData.absorbed or 0))
			targetBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1
		end
	end

	targetBar:AlignWithHeader(scrollFrame.Header, "left")
end

---refresh the data shown in the spells scroll box
---@param scrollFrame table
---@param scrollData breakdowntargettablelist
---@param offset number
---@param totalLines number
local refreshTargetsFunc = function(scrollFrame, scrollData, offset, totalLines) --~refresh ~target ~refreshtargets
	---@type number
	local topValue = scrollFrame.topValue
	---@type number
	local totalValue = scrollData.totalValue
	---@type actor
	local actorObject = spellsTab.GetActor()
	---@type string
	local actorName = actorObject:Name()
	---@type combat
	local combatObject = spellsTab.GetCombat()
	---@type instance
	local instanceObject = spellsTab.GetInstance()

	---@type number
	local mainAttribute = spellsTab.mainAttribute

	local sortKey = scrollFrame.SortKey
	local headerTable = spellsTab.targetsHeaderData

	local lineIndex = 1

	for i = 1, totalLines do
		local index = i + offset

		---@type breakdowntargettable
		local bkTargetData = scrollData[index]
		if (bkTargetData) then
			---called mainSpellBar because it is the line that shows the sum of all spells merged (if any)
			---@type breakdowntargetbar
			local targetBar = getTargetBar(scrollFrame, lineIndex)
			do
				if (targetBar) then
					lineIndex = lineIndex + 1
					updateTargetBar(targetBar, index, combatObject, scrollFrame, headerTable, bkTargetData, totalValue, topValue, sortKey)
				end
			end

			if (lineIndex > totalLines) then
				break
			end
		end
	end
end

---create a targetbar within the target scroll
---@param self breakdownphasescrollframe
---@param index number
---@return breakdownphasebar
function spellsTab.CreatePhaseBar(self, index) --~create ~createphase ~phasebar
	---@type breakdownphasebar
	local phaseBar = CreateFrame("button", self:GetName() .. "PhaseBarButton" .. index, self)
	phaseBar.index = index

	--size and positioning
	phaseBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	local y = (index-1) * CONST_SPELLSCROLL_LINEHEIGHT * -1 + (1 * -index) - 15
	phaseBar:SetPoint("topleft", self, "topleft", 1, y)
	phaseBar:SetPoint("topright", self, "topright", -1, y)

	phaseBar:EnableMouse(true)

	phaseBar:SetAlpha(0.823)
	phaseBar:SetFrameStrata("HIGH")
	phaseBar:SetScript("OnEnter", nil)
	phaseBar:SetScript("OnLeave", nil)

	DF:Mixin(phaseBar, DF.HeaderFunctions)

	---@type breakdownspellbarstatusbar
	local statusBar = CreateFrame("StatusBar", "$parentStatusBar", phaseBar)
	statusBar:SetAllPoints()
	statusBar:SetAlpha(0.5)
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetValue(50)
	statusBar:EnableMouse(false)
	statusBar:SetFrameLevel(phaseBar:GetFrameLevel() - 1)
	phaseBar.statusBar = statusBar

	---@type texture this is the statusbar texture
	local statusBarTexture = statusBar:CreateTexture("$parentTexture", "artwork")
	statusBarTexture:SetTexture(SharedMedia:Fetch("statusbar", "Details Hyanda"))
	statusBar:SetStatusBarTexture(statusBarTexture)
	statusBar:SetStatusBarColor(1, 1, 1, 1)

	---@type texture shown when the mouse hoverover this bar
	local hightlightTexture = statusBar:CreateTexture("$parentTextureHighlight", "highlight")
	hightlightTexture:SetColorTexture(1, 1, 1, 0.2)
	hightlightTexture:SetAllPoints()
	statusBar.highlightTexture = hightlightTexture

	---@type texture background texture
	local backgroundTexture = statusBar:CreateTexture("$parentTextureBackground", "border")
	backgroundTexture:SetAllPoints()
	backgroundTexture:SetColorTexture(.05, .05, .05)
	backgroundTexture:SetAlpha(1)
	statusBar.backgroundTexture = backgroundTexture

	--create an icon
	---@type texture
	local icon = statusBar:CreateTexture("$parentTexture", "overlay")
	icon:SetPoint("left", statusBar, "left", 0, 0)
	icon:SetSize(CONST_SPELLSCROLL_LINEHEIGHT-2, CONST_SPELLSCROLL_LINEHEIGHT-2)
	icon:SetTexCoord(.1, .9, .1, .9)
	phaseBar.Icon = icon

	phaseBar:AddFrameToHeaderAlignment(icon)

	phaseBar.InLineTexts = {}

	for i = 1, 5 do
		---@type fontstring
		local fontString = phaseBar:CreateFontString("$parentFontString" .. i, "overlay", "GameFontHighlightSmall")
		fontString:SetJustifyH("left")
		fontString:SetTextColor(1, 1, 1, 1)
		fontString:SetNonSpaceWrap(true)
		fontString:SetWordWrap(false)
		phaseBar["lineText" .. i] = fontString
		phaseBar.InLineTexts[i] = fontString
		fontString:SetTextColor(1, 1, 1, 1)
		phaseBar:AddFrameToHeaderAlignment(fontString)
	end

	phaseBar:AlignWithHeader(self.Header, "left")

	return phaseBar
end

---get a generic bar from the scroll box, if it doesn't exist, return nil
---@param scrollFrame table
---@param lineIndex number
---@return breakdownphasebar
local getGenericBar = function(scrollFrame, lineIndex)
	---@type breakdowngenericbar
	local genericBar = scrollFrame:GetLine(lineIndex)

	--reset header alignment
	genericBar:ResetFramesToHeaderAlignment()

	--reset columns, hiding them
	genericBar.Icon:Hide()
	for inLineIndex = 1, #genericBar.InLineTexts do
		genericBar.InLineTexts[inLineIndex]:SetText("")
	end

	return genericBar
end

---get a spell bar from the scroll box, if it doesn't exist, return nil
---@param scrollFrame table
---@param lineIndex number
---@return breakdownphasebar
local getPhaseBar = function(scrollFrame, lineIndex)
	---@type breakdownphasebar
	local phaseBar = scrollFrame:GetLine(lineIndex)

	--reset header alignment
	phaseBar:ResetFramesToHeaderAlignment()

	spellsTab.UpdateBarSettings(phaseBar)

	--reset columns, hiding them
	phaseBar.Icon:Hide()
	for inLineIndex = 1, #phaseBar.InLineTexts do
		phaseBar.InLineTexts[inLineIndex]:SetText("")
	end

	return phaseBar
end

---@param scrollFrame table
---@param scrollData table
---@param offset number
---@param totalLines number
local refreshGenericFunc = function(scrollFrame, scrollData, offset, totalLines) --~refreshgeneric ~refreshfunc ~refresh ~refreshg ~updategenericbar
	local lineIndex = 1
	local combatTime = scrollData.combatTime
	local totalValue = scrollData.totalValue

	for i = 1, totalLines do
		local index = i + offset
		local dataTable = scrollData[index]

		if (dataTable) then
			local genericBar = getGenericBar(scrollFrame, lineIndex)
			genericBar.statusBar:SetValue(dataTable.total / scrollFrame.topValue * 100)

			---@type number
			local textIndex = 1

			if (scrollData.headersAllowed.icon) then
				---@type texturetable
				local dataIcon = dataTable.icon
				genericBar.Icon:Show()
				genericBar.Icon:SetTexture(dataIcon.texture)
				genericBar.Icon:SetTexCoord(dataIcon.coords.left, dataIcon.coords.right, dataIcon.coords.top, dataIcon.coords.bottom)
				genericBar.Icon:SetSize(CONST_SPELLSCROLL_LINEHEIGHT-2, CONST_SPELLSCROLL_LINEHEIGHT-2)
				genericBar:AddFrameToHeaderAlignment(genericBar.Icon)
			end

			if (scrollData.headersAllowed.name) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				local nameWithoutRealm = DF:RemoveRealmName(dataTable.name)
				fontString:SetText(nameWithoutRealm or dataTable.name)
				textIndex = textIndex + 1
			end

			if (scrollData.headersAllowed.rank) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(index)
				textIndex = textIndex + 1
			end

			if (scrollData.headersAllowed.amount) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(Details:Format(dataTable.total))
				textIndex = textIndex + 1
			end

			if (scrollData.headersAllowed.persecond) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(Details:Format(dataTable.total / combatTime))
				textIndex = textIndex + 1
			end

			if (scrollData.headersAllowed.percent) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(string.format("%.1f", dataTable.total / totalValue * 100) .. "%")
				textIndex = textIndex + 1
			end

			lineIndex = lineIndex + 1
			if (lineIndex > totalLines) then
				break
			end
		end
	end
end


---@param scrollFrame table
---@param scrollData table
---@param offset number
---@param totalLines number
local refreshPhaseFunc = function(scrollFrame, scrollData, offset, totalLines) --~refreshphases ~refreshfunc ~refresh ~refreshp ~updatephasebar
	local lineIndex = 1
	local formatFunc = Details:GetCurrentToKFunction()
	local phaseElapsedTime = scrollData.phaseElapsed

	for i = 1, totalLines do
		local index = i + offset
		local dataTable = scrollData[index]

		if (dataTable) then
			local phaseBar = getPhaseBar(scrollFrame, lineIndex)

			phaseBar.statusBar:SetValue(100)

			local totalDone = dataTable.amountDone
			local phaseName = dataTable.phaseName
			local phaseNameFormatted = "Phase: " .. phaseName
			local amountDoneFormatted = formatFunc(nil, totalDone)
			local positionWithInPhase = math.floor(dataTable.positionWithInPhase)
			local percentDone = string.format("%.1f", dataTable.percentDone)

			local elapsedTime = phaseElapsedTime[phaseName]
			local phaseDps = formatFunc(nil, totalDone / elapsedTime)

			phaseBar.Icon:Show()
			phaseBar.Icon:SetTexture([[Interface\Garrison\orderhall-missions-mechanic9]])
			phaseBar.Icon:SetTexCoord(11/64, 53/64, 11/64, 53/64)
			phaseBar.Icon:SetSize(CONST_SPELLSCROLL_LINEHEIGHT-2, CONST_SPELLSCROLL_LINEHEIGHT-2)
			phaseBar:AddFrameToHeaderAlignment(phaseBar.Icon)

			for inLineIndex = 1, #phaseBar.InLineTexts do
				phaseBar.InLineTexts[inLineIndex]:SetText("")
			end

			local text1 = phaseBar.InLineTexts[1]
			phaseBar:AddFrameToHeaderAlignment(text1)
			text1:SetText(phaseNameFormatted)

			local text2 = phaseBar.InLineTexts[2]
			phaseBar:AddFrameToHeaderAlignment(text2)
			text2:SetText("#" .. positionWithInPhase)

			local text3 = phaseBar.InLineTexts[3]
			phaseBar:AddFrameToHeaderAlignment(text3)
			text3:SetText(amountDoneFormatted)

			local text4 = phaseBar.InLineTexts[4]
			phaseBar:AddFrameToHeaderAlignment(text4)
			text4:SetText(phaseDps)

			local text5 = phaseBar.InLineTexts[5]
			phaseBar:AddFrameToHeaderAlignment(text5)
			text5:SetText(percentDone .. "%")

			lineIndex = lineIndex + 1
		end
	end
end

---create a container to show value per phase
---@param tabFrame tabframe
---@return breakdownphasescrollframe
function spellsTab.CreatePhasesContainer(tabFrame) --~phase ~createphasecontainer ~createphasescroll
	---@type width
	local width = Details.breakdown_spell_tab.phasecontainer_width
	---@type height
	local height = Details.breakdown_spell_tab.phasecontainer_height

	local defaultAmountOfLines = 10

	--create a container for the scrollframe
	local options = {
		width = Details.breakdown_spell_tab.phasecontainer_width,
		height = Details.breakdown_spell_tab.phasecontainer_height,
		is_locked = Details.breakdown_spell_tab.phasecontainer_islocked,
		can_move = false,
		can_move_children = false,
		use_top_resizer = true,
		use_right_resizer = true,
		use_left_resizer = true,
		use_bottom_resizer = true,
	}

	---@type df_framecontainer
	local container = DF:CreateFrameContainer(tabFrame, options, tabFrame:GetName() .. "PhaseScrollContainer")
	container:SetPoint("topleft", spellsTab.GetTargetScrollContainer(), "topright", 26, 0)
	container:SetFrameLevel(tabFrame:GetFrameLevel() + 10)
	spellsTab.PhaseContainerFrame = container

	local settingChangedCallbackFunction = function(frameContainer, settingName, settingValue)
		if (frameContainer:IsShown()) then
			if (settingName == "height") then
				---@type number
				local currentHeight = spellsTab.GetPhaseScrollFrame():GetHeight()
				Details.breakdown_spell_tab.phasecontainer_height = settingValue
				local lineAmount = math.floor(currentHeight / CONST_SPELLSCROLL_LINEHEIGHT)
				spellsTab.GetPhaseScrollFrame():SetNumFramesShown(lineAmount)

			elseif (settingName == "width") then
				Details.breakdown_spell_tab.phasecontainer_width = settingValue

			elseif (settingName == "is_locked") then
				Details.breakdown_spell_tab.phasecontainer_islocked = settingValue
			end
		end
	end
	container:SetSettingChangedCallback(settingChangedCallbackFunction)

	---@type breakdownphasescrollframe not sure is this is correct
	local phaseScrollFrame = DF:CreateScrollBox(container, "$parentPhaseScroll", refreshPhaseFunc, {}, width, height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(phaseScrollFrame)

	phaseScrollFrame:SetBackdrop({})
	phaseScrollFrame:SetAllPoints()

	container:RegisterChildForDrag(phaseScrollFrame)

	phaseScrollFrame.DontHideChildrenOnPreRefresh = false
	tabFrame.PhaseScrollFrame = phaseScrollFrame
	spellsTab.PhaseScrollFrame = phaseScrollFrame

	spellsTab.ApplyStandardBackdrop(container, phaseScrollFrame)

	function phaseScrollFrame:RefreshMe() --~refreshme (phases) ~refreshmep
    	--get the value of the top 1 ranking spell
		---@type actor
		local actorObject = spellsTab.GetActor()
		---@type combat
		local combatObject = spellsTab.GetCombat()
		local actorName = actorObject:Name()
		---@type instance
		local instanceObject = spellsTab.GetInstance()

		local mainAttribute = instanceObject:GetDisplay()

	   	local data = {
		   --playerObject = playerObject,
		   --attribute = attribute,
		   --combatObject = combatObject,
		   combatTime = combatObject:GetCombatTime(),
	   	}

	   	local playerPhases = {}
	   	local totalDamage = 0
	   	local phaseElapsed = {}

	   	local phasesInfo = combatObject:GetPhases()

		if (not phasesInfo) then
			spellsTab.PhaseContainerFrame:Hide()
			return
		end

		if (#phasesInfo == 1) then
		   --if there's only one phase, then there's no need to show phases
		   spellsTab.PhaseContainerFrame:Hide()
		   return
	   	else
		   spellsTab.PhaseContainerFrame:Show()
	   	end

		if (#phasesInfo >= 1) then
			--get phase elapsed time
			for i = 1, #phasesInfo do
				local thisPhase = phasesInfo[i]
				local phaseName = thisPhase[1]
				local startTime = thisPhase[2]

				local nextPhase = phasesInfo[i + 1]
				if (nextPhase) then
					--if there's a next phase, use it's start time as end time to calcule elapsed time
					local endTime = nextPhase[2]
					local elapsedTime = endTime - startTime
					phaseElapsed[phaseName] = (phaseElapsed[phaseName] or 0) + elapsedTime
				else
					--if there's no next phase, use the combat end time as end time to calcule elapsed time
					local endTime = combatObject:GetCombatTime()
					local elapsedTime = endTime - startTime
					phaseElapsed[phaseName] = (phaseElapsed[phaseName] or 0) + elapsedTime
				end
			end

			--get damage info
			local dataTable = mainAttribute == 1 and phasesInfo.damage or phasesInfo.heal
			for phaseName, playersTable in pairs(dataTable) do --each phase
				local allPlayers = {} --all players for this phase
				for playerName, amount in pairs(playersTable) do
					tinsert(allPlayers, {playerName, amount})
					totalDamage = totalDamage + amount
				end
				table.sort(allPlayers, function(a, b)
					return a[2] > b[2]
				end)

				local myRank = 0
				for i = 1, #allPlayers do
					if (allPlayers[i][1] == actorName) then
						myRank = i
						break
					end
				end

				tinsert(playerPhases, {phaseName, playersTable[actorName] or 0, myRank, (playersTable[actorName] or 0) / totalDamage * 100})
			end
		end

	   table.sort(playerPhases, function(a, b) return a[1] < b[1] end)

	   for i = 1, #playerPhases do
		   data[#data+1] = {
			   phaseName = playerPhases[i][1],
			   amountDone = playerPhases[i][2],
			   positionWithInPhase = playerPhases[i][3],
			   percentDone = playerPhases[i][4],
		   }
	   end

	   data.totalDamage = totalDamage
	   data.phaseElapsed = phaseElapsed

		phaseScrollFrame:SetData(data)
		phaseScrollFrame:Refresh()
	end

	--~header
	local headerOptions = {
		padding = 2,
		header_height = 14,

		reziser_shown = true,
		reziser_width = 2,
		reziser_color = {.5, .5, .5, 0.7},
		reziser_max_width = 246,

		header_click_callback = onAnyColumnHeaderClickCallback,

		header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
		text_color = {1, 1, 1, 0.823},
	}

	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, phaseContainerColumnData, headerOptions)
	phaseScrollFrame.Header = header
	phaseScrollFrame.Header:SetPoint("topleft", phaseScrollFrame, "topleft", 0, 1)
	phaseScrollFrame.Header:SetColumnSettingChangedCallback(spellsTab.OnHeaderColumnOptionChanged)

	--cache the type of this container
	headerContainerType[phaseScrollFrame.Header] = "phases"

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		phaseScrollFrame:CreateLine(spellsTab.CreatePhaseBar)
	end

	tabFrame.phases = container:CreateFontString(nil, "overlay", "QuestFont_Large")
	tabFrame.phases:SetPoint("bottomleft", container, "topleft", 2, 2)
	tabFrame.phases:SetText("Phases:") --localize-me

	return phaseScrollFrame
end

---create a genericbar within the generic scroll
---@param self breakdowngenericscrollframe
---@param index number
---@return breakdowngenericbar
function spellsTab.CreateGenericBar(self, index) --~create ~generic ~creategeneric ~genericbar
	---@type breakdowngenericbar
	local genericBar = CreateFrame("button", self:GetName() .. "GenericBarButton" .. index, self)
	genericBar.index = index

	--size and positioning
	genericBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	local y = (index-1) * CONST_SPELLSCROLL_LINEHEIGHT * -1 + (1 * -index) - 15
	genericBar:SetPoint("topleft", self, "topleft", 0, y)
	genericBar:SetPoint("topright", self, "topright", 0, y)

	genericBar:EnableMouse(true)

	genericBar:SetAlpha(0.9)
	genericBar:SetFrameStrata("HIGH")
	genericBar:SetScript("OnEnter", nil) --onEnterBreakdownGenericBar
	genericBar:SetScript("OnLeave", nil) --onLeaveBreakdownGenericBar

	DF:Mixin(genericBar, DF.HeaderFunctions)

	---@type breakdownspellbarstatusbar
	local statusBar = CreateFrame("StatusBar", "$parentStatusBar", genericBar)
	statusBar:SetAllPoints()
	statusBar:SetAlpha(0.5)
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetValue(50)
	statusBar:EnableMouse(false)
	statusBar:SetFrameLevel(genericBar:GetFrameLevel() - 1)
	genericBar.statusBar = statusBar

	---@type texture this is the statusbar texture
	local statusBarTexture = statusBar:CreateTexture("$parentTexture", "artwork")
	statusBarTexture:SetTexture(SharedMedia:Fetch("statusbar", "Details Hyanda"))
	statusBar:SetStatusBarTexture(statusBarTexture)
	statusBar:SetStatusBarColor(1, 1, 1, 1)

	---@type texture shown when the mouse hoverover this bar
	local hightlightTexture = statusBar:CreateTexture("$parentTextureHighlight", "highlight")
	hightlightTexture:SetColorTexture(1, 1, 1, 0.2)
	hightlightTexture:SetAllPoints()
	statusBar.highlightTexture = hightlightTexture

	---@type texture background texture
	local backgroundTexture = statusBar:CreateTexture("$parentTextureBackground", "border")
	backgroundTexture:SetAllPoints()
	backgroundTexture:SetColorTexture(.05, .05, .05)
	backgroundTexture:SetAlpha(1)
	statusBar.backgroundTexture = backgroundTexture

	--create an icon
	---@type texture
	local icon = statusBar:CreateTexture("$parentTexture", "overlay")
	icon:SetPoint("left", statusBar, "left", 0, 0)
	icon:SetSize(CONST_SPELLSCROLL_LINEHEIGHT-2, CONST_SPELLSCROLL_LINEHEIGHT-2)
	icon:SetTexCoord(.1, .9, .1, .9)
	genericBar.Icon = icon

	genericBar:AddFrameToHeaderAlignment(icon)

	genericBar.InLineTexts = {}

	for i = 1, 5 do
		---@type fontstring
		local fontString = genericBar:CreateFontString("$parentFontString" .. i, "overlay", "GameFontHighlightSmall")
		fontString:SetJustifyH("left")
		fontString:SetTextColor(1, 1, 1, 1)
		fontString:SetNonSpaceWrap(true)
		fontString:SetWordWrap(false)
		genericBar["lineText" .. i] = fontString
		genericBar.InLineTexts[i] = fontString
		fontString:SetTextColor(1, 1, 1, 1)
		genericBar:AddFrameToHeaderAlignment(fontString)
	end

	genericBar:AlignWithHeader(self.Header, "left")

	return genericBar
end

---create the generic container, this container hold bars that can show any type of data
---@param tabFrame tabframe
---@return breakdowngenericscrollframe
function spellsTab.CreateGenericContainer(tabFrame) --~create ~generic ~creategenericcontainer ~creategenericscroll ~creategeneric
	---@type width
	local width = Details.breakdown_spell_tab.genericcontainer_width
	---@type height
	local height = Details.breakdown_spell_tab.genericcontainer_height

	local defaultAmountOfLines = 50

	--create a container for the scrollframe
	local options = {
		width = Details.breakdown_spell_tab.genericcontainer_width,
		height = Details.breakdown_spell_tab.genericcontainer_height,
		is_locked = Details.breakdown_spell_tab.genericcontainer_islocked,
		can_move = false,
		can_move_children = false,
		use_top_resizer = true,
		use_right_resizer = true,
		use_bottom_resizer = true,
		use_left_resizer = true,
	}

	---@type df_framecontainer
	local container = DF:CreateFrameContainer(tabFrame, options, tabFrame:GetName() .. "GenericScrollContainer")
	container:SetPoint("topleft", tabFrame, "topleft", 0, 0)
	container:SetFrameLevel(tabFrame:GetFrameLevel()+1)
	spellsTab.GenericContainerFrame = container

	--when a setting is changed in the container, it will call this function, it is registered below with SetSettingChangedCallback()
	local settingChangedCallbackFunction = function(frameContainer, settingName, settingValue)
		if (frameContainer:IsShown()) then
			if (settingName == "height") then
				---@type number
				local currentHeight = spellsTab.GetGenericScrollFrame():GetHeight()
				Details.breakdown_spell_tab.genericcontainer_height = settingValue
				spellsTab.GetGenericScrollFrame():SetNumFramesShown(math.floor(currentHeight / CONST_SPELLSCROLL_LINEHEIGHT) - 2)

			elseif (settingName == "width") then
				Details.breakdown_spell_tab.genericcontainer_width = settingValue

			elseif (settingName == "is_locked") then
				Details.breakdown_spell_tab.genericcontainer_islocked = settingValue
			end

			spellsTab.GetSpellBlockContainer():SendSettingChangedCallback("UpdateSize", -1)
		end
	end
	container:SetSettingChangedCallback(settingChangedCallbackFunction)

	--create a scrollframe
	local genericScrollFrame = DF:CreateScrollBox(container, "$parentGenericScroll", refreshGenericFunc, {}, width, height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(genericScrollFrame)
	genericScrollFrame:SetBackdrop({})
	genericScrollFrame:SetAllPoints()

	container:RegisterChildForDrag(genericScrollFrame)

	genericScrollFrame.DontHideChildrenOnPreRefresh = false
	tabFrame.GenericScrollFrame = genericScrollFrame
	spellsTab.GenericScrollFrame = genericScrollFrame

	--settingChangedCallbackFunction(container, "height", Details.breakdown_spell_tab.genericcontainer_height)

	function genericScrollFrame:RefreshMe(data) --~refreshme (generic) ~refreshg
		--get which column is currently selected and the sort order
		local columnIndex, order, key = genericScrollFrame.Header:GetSelectedColumn()
		genericScrollFrame.SortKey = key

		---@type string
		local keyToSort = key

		if (order == "DESC") then
			table.sort(data,
			function(t1, t2)
				return t1[keyToSort] > t2[keyToSort]
			end)
			genericScrollFrame.topValue = data[1] and data[1][keyToSort]
		else
			table.sort(data,
			function(t1, t2)
				return t1[keyToSort] < t2[keyToSort]
			end)
			genericScrollFrame.topValue = data[#data] and data[#data][keyToSort]
		end

		genericScrollFrame:SetData(data)
		genericScrollFrame:Refresh()
	end

	--~header
	local headerOptions = {
		padding = 2,
		header_height = 14,

		reziser_shown = true,
		reziser_width = 2,
		reziser_color = {.5, .5, .5, 0.7},
		reziser_max_width = 246,

		header_click_callback = onAnyColumnHeaderClickCallback,

		header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
		text_color = {1, 1, 1, 0.823},
	}

	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, genericContainerColumnData, headerOptions)
	genericScrollFrame.Header = header
	genericScrollFrame.Header:SetPoint("topleft", genericScrollFrame, "topleft", 0, 1)
	genericScrollFrame.Header:SetColumnSettingChangedCallback(spellsTab.OnHeaderColumnOptionChanged)

	--cache the type of this container
	headerContainerType[genericScrollFrame.Header] = "generic"

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		genericScrollFrame:CreateLine(spellsTab.CreateGenericBar)
	end

	--need to create the second scroll frame to show the details about the spelltable/actor hovered over

	return genericScrollFrame
end

---create the target container
---@param tabFrame tabframe
---@return breakdowntargetscrollframe
function spellsTab.CreateTargetContainer(tabFrame) --~create ~target ~createtargetcontainer ~createtargetscroll ~createtarget
	---@type width
	local width = Details.breakdown_spell_tab.targetcontainer_width
	---@type height
	local height = Details.breakdown_spell_tab.targetcontainer_height

	local defaultAmountOfLines = 50

	--create a container for the scrollframe
	local options = {
		width = Details.breakdown_spell_tab.targetcontainer_width,
		height = Details.breakdown_spell_tab.targetcontainer_height,
		is_locked = Details.breakdown_spell_tab.targetcontainer_islocked,
		can_move = false,
		can_move_children = false,
		use_top_resizer = true,
		use_right_resizer = true,
	}

	---@type df_framecontainer
	local container = DF:CreateFrameContainer(tabFrame, options, tabFrame:GetName() .. "TargetScrollContainer")
	container:SetPoint("topleft", spellsTab.GetSpellScrollContainer(), "bottomleft", 0, -25)
	container:SetFrameLevel(tabFrame:GetFrameLevel() + 10)
	spellsTab.TargetsContainerFrame = container

	local settingChangedCallbackFunction = function(frameContainer, settingName, settingValue)
		if (frameContainer:IsShown()) then
			if (settingName == "height") then
				---@type number
				local currentHeight = spellsTab.GetTargetScrollFrame():GetHeight()
				Details.breakdown_spell_tab.targetcontainer_height = settingValue
				--the -0.1 is the avoid the random fraction of 1.9999999990 to 2.0000000001
				local lineAmount = currentHeight / CONST_SPELLSCROLL_LINEHEIGHT - 0.1
				lineAmount = math.floor(lineAmount)
				spellsTab.GetTargetScrollFrame():SetNumFramesShown(lineAmount)

			elseif (settingName == "width") then
				Details.breakdown_spell_tab.targetcontainer_width = settingValue

			elseif (settingName == "is_locked") then
				Details.breakdown_spell_tab.targetcontainer_islocked = settingValue
			end
		end
	end
	container:SetSettingChangedCallback(settingChangedCallbackFunction)

	--create the scrollframe similar to scrollframe used in the spellscrollframe
    --replace this with a framework scrollframe
	---@type breakdowntargetscrollframe
	local targetScrollFrame = DF:CreateScrollBox(container, "$parentTargetScroll", refreshTargetsFunc, {}, width, height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(targetScrollFrame)
	targetScrollFrame:SetBackdrop({})
	targetScrollFrame:SetAllPoints()

	container:RegisterChildForDrag(targetScrollFrame)

	targetScrollFrame.DontHideChildrenOnPreRefresh = false
	tabFrame.TargetScrollFrame = targetScrollFrame
	spellsTab.TargetScrollFrame = targetScrollFrame

	spellsTab.ApplyStandardBackdrop(container, targetScrollFrame)

	---@param data breakdowntargettablelist
	function targetScrollFrame:RefreshMe(data) --~refreshme (targets) ~refreshmet
		--get which column is currently selected and the sort order
		local columnIndex, order, key = targetScrollFrame.Header:GetSelectedColumn()
		targetScrollFrame.SortKey = key

		---@type string
		local keyToSort = key

		if (order == "DESC") then
			table.sort(data,
			function(t1, t2)
				return t1[keyToSort] > t2[keyToSort]
			end)
			targetScrollFrame.topValue = data[1] and data[1][keyToSort]
		else
			table.sort(data,
			function(t1, t2)
				return t1[keyToSort] < t2[keyToSort]
			end)
			targetScrollFrame.topValue = data[#data] and data[#data][keyToSort]
		end

		if (key == "overheal") then
			data.totalValue = data.totalValueOverheal
		end
		--default: data.totalValue
		--data.totalValueOverheal

		targetScrollFrame:SetData(data)
		targetScrollFrame:Refresh()
	end

	--~header
	local headerOptions = {
		padding = 2,
		header_height = 14,

		reziser_shown = true,
		reziser_width = 2,
		reziser_color = {.5, .5, .5, 0.7},
		reziser_max_width = 246,

		header_click_callback = onAnyColumnHeaderClickCallback,

		header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
		text_color = {1, 1, 1, 0.823},
	}

	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, targetContainerColumnData, headerOptions)
	targetScrollFrame.Header = header
	targetScrollFrame.Header:SetPoint("topleft", targetScrollFrame, "topleft", 0, 1)
	targetScrollFrame.Header:SetColumnSettingChangedCallback(spellsTab.OnHeaderColumnOptionChanged)

	--cache the type of this container
	headerContainerType[targetScrollFrame.Header] = "targets"

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		targetScrollFrame:CreateLine(spellsTab.CreateTargetBar)
	end

	tabFrame.targets = targetScrollFrame:CreateFontString(nil, "overlay", "QuestFont_Large")
	tabFrame.targets:SetPoint("bottomleft", container, "topleft", 2, 2)
	tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. ":")

	return targetScrollFrame
end






---@param targetBar breakdowntargetbar
local onEnterBreakdownTargetBar = function(targetBar)
	targetBar:SetAlpha(1)

	---@type string @the name of the target
	local targetName = targetBar.actorName

	Details:FormatCooltipForSpells()
	GameCooltip:SetOwner(targetBar, "bottom", "top", 4, -5)
	GameCooltip:SetOption("MinWidth", math.max(230, targetBar:GetWidth() * 0.98))

	--build a list of spells which the target was hit by
	local spellsSortedResult = {}
	local total = 0

	---@type actor
	local actorObject = spellsTab.GetActor()

	---@type combat
	local combatObject = spellsTab.GetCombat()

	---@type instance
	local instanceObject = spellsTab.GetInstance()

	---@type number
	local mainAttribute = instanceObject:GetDisplay()

	---@type spellcontainer
	local spellContainer = actorObject:GetSpellContainer("spell")

	local targetScrollFrame = spellsTab.GetTargetScrollFrame()

	---@type number, string, string
	local columnIndex, order, key = targetScrollFrame.Header:GetSelectedColumn()

	---@type string the label shown at the top of the tooltip
	local labelTooltipTitle = Loc ["STRING_DAMAGE_FROM"]

	local targetTableName = "targets"
	if (mainAttribute == DETAILS_ATTRIBUTE_HEAL) then
		if (key == "total") then
			labelTooltipTitle = Loc ["STRING_HEALING_FROM"]

		elseif (key == "overheal") then
			targetTableName = "targets_overheal"
			labelTooltipTitle = Loc ["STRING_OVERHEALED"]
		end
	end

	--this part kinda belong top damage or healing class, shouldn't be here

	---@type number, spelltable
	for spellId, spellTable in spellContainer:ListActors() do
		if (spellTable.isReflection) then
			---@type string, number
			for spellTargetName, amount in pairs(spellTable.targets) do
				if (spellTargetName == targetName) then
					for reflectedSpellId, reflectedAmount in pairs(spellTable.extra) do
						local spellName, _, spellIcon = _GetSpellInfo(reflectedSpellId)
						table.insert(spellsSortedResult, {reflectedSpellId, reflectedAmount, spellName .. " (|cFFCCBBBBreflected|r)", spellIcon})
						total = total + reflectedAmount
					end
				end
			end
		else
			for spellTargetName, amount in pairs(spellTable[targetTableName]) do
				if (spellTargetName == targetName) then
					local spellName, _, spellIcon = _GetSpellInfo(spellId)
					table.insert(spellsSortedResult, {spellId, amount, spellName, spellIcon})
					total = total + amount
				end
			end
		end
	end

	--add pets
	local petArray = actorObject:GetPets()
	for _, petName in ipairs(petArray) do
		local petActorObject = combatObject(mainAttribute, petName)
		if (petActorObject) then
			---@type spellcontainer
			local petSpellContainer = petActorObject:GetSpellContainer("spell")

			---@type number, spelltable
			for spellId, spellTable in petSpellContainer:ListActors() do
				for spellTargetName, amount in pairs(spellTable[targetTableName]) do
					if (spellTargetName == targetName) then
						local spellName, _, spellIcon = _GetSpellInfo(spellId)
						table.insert(spellsSortedResult, {spellId, amount, spellName .. " (" .. petName:gsub((" <.*"), "") .. ")", spellIcon})
						total = total + amount
					end
				end
			end
		end
	end

	table.sort(spellsSortedResult, Details.Sort2)

	--need to change is this is a healing
	Details:AddTooltipSpellHeaderText(labelTooltipTitle .. ":", {1, 0.9, 0.0, 1}, 1, Details.tooltip_spell_icon.file, unpack(Details.tooltip_spell_icon.coords))
	Details:AddTooltipHeaderStatusbar(1, 1, 1, 1)

	---@type tablesize
	local iconSize = Details.tooltip.icon_size
	---@type tablecoords
	local iconBorder = Details.tooltip.icon_border_texcoord

	local topValue = spellsSortedResult[1] and spellsSortedResult[1][2]

	if (topValue) then
		for index, tabela in ipairs(spellsSortedResult) do
			local spellId, amount, spellName, spellIcon = unpack(tabela)
			if (amount < 1) then
				break
			end
			GameCooltip:AddLine(spellName, Details:Format(amount) .. " (" .. string.format("%.1f", amount / total * 100) .. "%)")
			GameCooltip:AddIcon(spellIcon, nil, nil, iconSize.W + 4, iconSize.H + 4, iconBorder.L, iconBorder.R, iconBorder.T, iconBorder.B)
			Details:AddTooltipBackgroundStatusbar(false, amount / topValue * 100)
		end
	end

	GameCooltip:Show()
end

---@param self breakdowntargetbar
local onLeaveBreakdownTargetBar = function(self)
	self:SetAlpha(0.9)
	GameCooltip:Hide()
end

---create a targetbar within the target scroll
---@param self breakdowntargetscrollframe
---@param index number
---@return breakdowntargetbar
function spellsTab.CreateTargetBar(self, index) --~create ~target ~createtarget ~targetbar
	---@type breakdowntargetbar
	local targetBar = CreateFrame("button", self:GetName() .. "TargetBarButton" .. index, self)
	targetBar.index = index

	--size and positioning
	targetBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	local y = (index-1) * CONST_SPELLSCROLL_LINEHEIGHT * -1 + (1 * -index) - 15
	targetBar:SetPoint("topleft", self, "topleft", 1, y)
	targetBar:SetPoint("topright", self, "topright", -1, y)
	targetBar:EnableMouse(true)

	targetBar:SetAlpha(0.823)
	targetBar:SetFrameStrata("HIGH")
	targetBar:SetScript("OnEnter", onEnterBreakdownTargetBar)
	targetBar:SetScript("OnLeave", onLeaveBreakdownTargetBar)

	DF:Mixin(targetBar, DF.HeaderFunctions)

	---@type breakdownspellbarstatusbar
	local statusBar = CreateFrame("StatusBar", "$parentStatusBar", targetBar)
	statusBar:SetAllPoints()
	statusBar:SetAlpha(0.5)
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetValue(50)
	statusBar:EnableMouse(false)
	statusBar:SetFrameLevel(targetBar:GetFrameLevel() - 1)
	targetBar.statusBar = statusBar

	---@type texture this is the statusbar texture
	local statusBarTexture = statusBar:CreateTexture("$parentTexture", "artwork")
	statusBarTexture:SetTexture(SharedMedia:Fetch("statusbar", "Details Hyanda"))
	statusBar:SetStatusBarTexture(statusBarTexture)
	statusBar:SetStatusBarColor(1, 1, 1, 1)

	---@type texture shown when the mouse hoverover this bar
	local hightlightTexture = statusBar:CreateTexture("$parentTextureHighlight", "highlight")
	hightlightTexture:SetColorTexture(1, 1, 1, 0.2)
	hightlightTexture:SetAllPoints()
	statusBar.highlightTexture = hightlightTexture

	---@type texture background texture
	local backgroundTexture = statusBar:CreateTexture("$parentTextureBackground", "border")
	backgroundTexture:SetAllPoints()
	backgroundTexture:SetColorTexture(.05, .05, .05)
	backgroundTexture:SetAlpha(1)
	statusBar.backgroundTexture = backgroundTexture

	--create an icon
	---@type texture
	local icon = statusBar:CreateTexture("$parentTexture", "overlay")
	icon:SetPoint("left", statusBar, "left", 0, 0)
	icon:SetSize(CONST_SPELLSCROLL_LINEHEIGHT-2, CONST_SPELLSCROLL_LINEHEIGHT-2)
	icon:SetTexCoord(.1, .9, .1, .9)
	targetBar.Icon = icon

	targetBar:AddFrameToHeaderAlignment(icon)

	targetBar.InLineTexts = {}

	for i = 1, 5 do
		---@type fontstring
		local fontString = targetBar:CreateFontString("$parentFontString" .. i, "overlay", "GameFontHighlightSmall")
		fontString:SetJustifyH("left")
		fontString:SetTextColor(1, 1, 1, 1)
		fontString:SetNonSpaceWrap(true)
		fontString:SetWordWrap(false)
		targetBar["lineText" .. i] = fontString
		targetBar.InLineTexts[i] = fontString
		fontString:SetTextColor(1, 1, 1, 1)
		targetBar:AddFrameToHeaderAlignment(fontString)
	end

	targetBar:AlignWithHeader(self.Header, "left")

	return targetBar
end


function spellsTab.UpdateBarSettings(bar)
	if (bar.statusBar) then
		bar.statusBar:SetAlpha(Details.breakdown_spell_tab.statusbar_alpha) --could be moved to when the bar is updated
		bar.statusBar:GetStatusBarTexture():SetTexture(Details.breakdown_spell_tab.statusbar_texture)
		bar.statusBar.backgroundTexture:SetColorTexture(unpack(Details.breakdown_spell_tab.statusbar_background_color))
		bar.statusBar.backgroundTexture:SetAlpha(Details.breakdown_spell_tab.statusbar_background_alpha)
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

		--hide the generic container
		spellsTab.GetGenericScrollContainer():Hide()

		--refresh the data
		spellsTab.GetSpellScrollFrame():RefreshMe(data)
		spellsTab.GetPhaseScrollFrame():RefreshMe(data)
	end

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

		if (spellsTab.headersAllowed ~= data.headersAllowed) then
			--refresh the header frame
			spellsTab.UpdateHeadersSettings("generic")
			--bug: now allowing to sort
		end

		--when generic data is shown, the damage-healing-targets-scrolls / spell details blocks/ can be removed
		spellsTab.GetSpellScrollContainer():Hide()
		spellsTab.GetPhaseScrollContainer():Hide()
		spellsTab.GetTargetScrollContainer():Hide()

		--show the generic scroll
		spellsTab.GetGenericScrollContainer():Show()

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
				local caixa = Details.playerDetailWindow.grupos_detalhes[i]
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

		local caixa = Details.playerDetailWindow.grupos_detalhes[botao]

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
