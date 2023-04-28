
local addonName, Details222 = ...
local spellsTab = {}
local breakdownWindow = Details.BreakdownWindow
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local unpack = unpack
local GetTime = GetTime
local wipe = wipe
local GetCursorPosition = GetCursorPosition
local CreateFrame = CreateFrame
local GetSpellLink = GetSpellLink
local _GetSpellInfo = Details.GetSpellInfo
local GameTooltip = GameTooltip
local IsShiftKeyDown = IsShiftKeyDown
local DF = DetailsFramework

--expose the object to the global namespace
DetailsSpellBreakdownTab = spellsTab

local iconTableSummary = {
    texture = [[Interface\AddOns\Details\images\icons]],
    coords = {238/512, 255/512, 0, 18/512},
    width = 16,
    height = 16,
}

local spellBlockContainerSettings = {
	amount = 6, --amount of block the container have
	lineAmount = 3, --amount of line each block have
}

local spellBreakdownSettings = {}

local CONST_BAR_HEIGHT = 20
local CONST_TARGET_HEIGHT = 18

local CONST_SPELLSCROLL_WIDTH = 535
local CONST_SPELLSCROLL_HEIGHT = 311
local CONST_SPELLSCROLL_AMTLINES = 14
local CONST_SPELLSCROLL_LINEHEIGHT = 20

Details.SpellGroups = {
	[193473] = 15407, --mind flay
}

---@return actor
function spellsTab.GetActor()
	return spellsTab.currentActor
end

---@return combat
function spellsTab.GetCombat()
	return spellsTab.combatObject
end

---@return instance
function spellsTab.GetInstance()
	return spellsTab.instance or Details:GetActiveWindowFromBreakdownWindow()
end

---return the breakdownspellscrollframe object, there's only one of this in the breakdown window
---@return breakdownspellscrollframe
function spellsTab.GetSpellScrollFrame()
	return spellsTab.TabFrame.SpellScrollFrame
end

---return the breakdownspellblockcontainer object, there's only one of this in the breakdown window
---@return breakdownspellblockcontainer
function spellsTab.GetSpellBlockFrame()
	return spellsTab.TabFrame.SpellBlockFrame
end

function spellsTab.OnProfileChange()
	spellsTab.spellcontainer_header_settings = Details.breakdown_spell_tab.spellcontainer_headers
	spellsTab.UpdateHeadersSettings("spells")
end

---@type table<table, string>
local headerContainerType = {}

---@type number
local columnOffset = 0

---@class headercolumndatasaved : {enabled: boolean, width: number, align: string}
local settingsPrototype = {
	enabled = true,
	width = 100,
	align = "left",
}

---headercolumndata goes inside the header table which is passed to the header constructor or header:SetHeaderTable()
---@class headercolumndata : {name:string, width:number, text:string, align:string, key:string, selected:boolean, canSort:boolean, dataType:string, order:string, offset:number, key:string}

---columndata is the raw table with all options which can be used to create a headertable, some may not be used due to settings or filtering
---@class columndata : {name:string, width:number, key:string, selected:boolean, label:string, align:string, enabled:boolean, attribute:number, canSort:boolean, dataType:string, order:string, offset:number}

---default settings for the header of the spells container, label is a localized string, name is a string used to save the column settings, key is the key used to get the value from the spell table, width is the width of the column, align is the alignment of the text, enabled is if the column is enabled, canSort is if the column can be sorted, sortKey is the key used to sort the column, dataType is the type of data the column is sorting, order is the order of the sorting, offset is the offset of the column
---@type columndata[]
local spellContainerColumnInfo = {
	{name = "icon", width = 22, label = "", align = "center", enabled = true, offset = columnOffset},
	{name = "target", width = 22, label = "", align = "center", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 16, align = "center", enabled = true, offset = columnOffset, dataType = "number"},
	{name = "expand", label = "^", width = 16, align = "center", enabled = true, offset = columnOffset},
	{name = "name", label = "spell name", width = 246, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", selected = true, width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "persecond", label = "ps", key = "total", width = 50, align = "left", enabled = true, canSort = true, sortKey = "ps", offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "percent", label = "%", key = "total", width = 50, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "casts", label = "casts", key = "casts", width = 40, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "critpercent", label = "crit %", key = "critpercent", width = 40, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "hits", label = "hits", key = "counter", width = 40, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "castavg", label = "cast avg", key = "castavg", width = 50, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "uptime", label = "uptime", key = "uptime", width = 45, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "overheal", label = "overheal", key = "overheal", width = 55, align = "left", enabled = false, canSort = true, order = "DESC", dataType = "number", attribute = DETAILS_ATTRIBUTE_HEAL, offset = columnOffset},
	{name = "absorbed", label = "absorbed", key = "healabsorbed", width = 55, align = "left", enabled = false, canSort = true, order = "DESC", dataType = "number", attribute = DETAILS_ATTRIBUTE_HEAL, offset = columnOffset},
}

---callback for when the user resizes a column on the header
---@param headerFrame df_headerframe
---@param optionName string
---@param columnName string
---@param value any
local onHeaderColumnOptionChanged = function(headerFrame, optionName, columnName, value)
	---@type string
	local containerType = headerContainerType[headerFrame]
	---@type table
	local settings

	if (containerType == "spells") then
		settings = spellsTab.spellcontainer_header_settings

	elseif (containerType == "targets") then

	end

	settings[columnName][optionName] = value

	spellsTab.UpdateHeadersSettings(containerType)
end

---run when the user clicks the columnHeader
---@param headerFrame df_headerframe
---@param columnHeader df_headercolumnframe
local onColumnHeaderClickCallback = function(headerFrame, columnHeader)
	---@type string
	local containerType = headerContainerType[headerFrame]

	if (containerType == "spells") then
		spellsTab.GetSpellScrollFrame():Refresh()
	end
end

---copy settings from the ColumnInfo table which doesn't exists in the details profile
---this is called when the profile changes or when the tab is opened with a different actor than before
---@param containerType "spells"|"targets"
function spellsTab.UpdateHeadersSettings(containerType)
	---details table which hold the settings for a container header
	---@type table
	local settings
	---@type table
	local containerInfo
	if (containerType == "spells") then
		settings = spellsTab.spellcontainer_header_settings
		containerInfo = spellContainerColumnInfo

	elseif (containerType == "targets") then

	end

	--do a loop and check if the column data from columnInfo exists in the details profile settings, if not, add it
	for i = 1, #containerInfo do
		--default column settings
		local columnData = containerInfo[i]
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
		spellsTab.spellsHeaderData = spellsTab.BuildHeaderTable("spells")
		spellsTab.GetSpellScrollFrame().Header:SetHeaderTable(spellsTab.spellsHeaderData)

	elseif (containerType == "targets") then
		spellsTab.spellsHeaderData = spellsTab.BuildHeaderTable("targets")
	end
end

---parse the data from details profile and build a table with the data to be used by the header
---@param containerType "spells"|"targets"
---@return {name: string, width: number, text: string, align: string}[]
function spellsTab.BuildHeaderTable(containerType)
	---@type headercolumndata[]
	local headerTable = {}

    ---@type instance
    local instance = spellsTab.GetInstance()

	---@type number, number
	local mainAttribute, subAttribute = instance:GetDisplay()

	--settings from profile | updated at UpdateHeadersSettings() > called on OnProfileChange() and when the tab is opened
	local settings

	---@type table
	local containerInfo

	if (containerType == "spells") then
		settings = spellsTab.spellcontainer_header_settings
		containerInfo = spellContainerColumnInfo

	elseif (containerType == "targets") then

	end

	for i = 1, #containerInfo do
		local columnData = containerInfo[i]
		---@type {enabled: boolean, width: number, align: string}
		local columnSettings = settings[columnData.name]

		--, canSort = true, dataType = "number", order = "DESC", offset = 0

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

				headerTable[#headerTable+1] = headerColumnData
			end
		else
			--targets
		end
	end

	return headerTable
end

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
	--update spells header frame (for the used spells frame)
	spellsTab.UpdateHeadersSettings("spells")
end

--called when the tab is getting created, run only once
function spellsTab.OnCreateTabCallback(tabButton, tabFrame) --~init
	spellsTab.spellcontainer_header_settings = Details.breakdown_spell_tab.spellcontainer_headers

	spellBreakdownSettings = Details.breakdown_spell_tab
	DetailsFramework:ApplyStandardBackdrop(tabFrame)

    --create the scrollbar to show the spells in the breakdown window
	---@type breakdownspellscrollframe
    local spellScrollContainer = spellsTab.CreateSpellScrollContainer(tabFrame) --finished

    --create the 6 spell blocks in the right side of the breakdown window
    --these blocks show the spell info like normal hits, critical hits, average, etc
	---@type breakdownspellblockcontainer
    local spellBlockContainer = spellsTab.CreateSpellBlockContainer(tabFrame)

    --create the targets container
    spellsTab.CreateTargetContainer(tabFrame)

    --create the report buttons for each container
    --spellsTab.CreateReportButtons(tabFrame)

	--these bars table are kinda deprecated now:
    --store the spell bars for the spell container
	tabFrame.barras1 = {} --deprecated
	--store the special bars shown in the right side of the breakdown window, this is only shown when spellBlocks aren't in use
	tabFrame.barras3 = {} --deprecated

    spellsTab.TabFrame = tabFrame

	--open the breakdown window at startup for testing
	--[= debug
	C_Timer.After(1, function()
		Details:OpenPlayerDetails(1)
		C_Timer.After(1, function()
			Details:OpenPlayerDetails(1)
			Details:OpenPlayerDetails(1)
		end)
	end)
	--]=]
end

----------------------------------------------------------------------
--> scripts

--create a details bar on the right side of the window
local onEnterSpellBlock = function(spellBlock) --info background is the 6 bars in the right side of the window?
	Details.FadeHandler.Fader(spellBlock.overlay, "OUT")
	Details.FadeHandler.Fader(spellBlock.reportButton, "OUT")
end

local onLeaveSpellBlock = function(spellBlock)
	Details.FadeHandler.Fader(spellBlock.overlay, "IN")
	Details.FadeHandler.Fader(spellBlock.reportButton, "IN")
end

local onEnterInfoReport = function(self)
	Details.FadeHandler.Fader(self:GetParent().overlay, "OUT")
	Details.FadeHandler.Fader(self, "OUT")
end

local onLeaveInfoReport = function(self)
	Details.FadeHandler.Fader(self:GetParent().overlay, "IN")
	Details.FadeHandler.Fader(self, "IN")
end

---run this function when the mouse hover over a breakdownspellbar
---@param spellBar breakdownspellbar
local onEnterBreakdownSpellBar = function(spellBar) --parei aqui: precisa por nomes nas funções e formatar as linhas das funcções
	--all values from spellBar are cached values
	--check if there's a spellbar selected, if there's one, ignore the mouseover
	if (spellsTab.HasSelectedSpellBar()) then
		return
	end

    ---@type instance
    local instance = spellsTab.GetInstance()

	---@type number, number
	local mainAttribute, subAttribute = instance:GetDisplay()

	---@type breakdownspellblockcontainer
	local spellBlockContainer = spellsTab.GetSpellBlockFrame()
	spellBlockContainer:ClearBlocks()

	---@type number
	local spellId = spellBar.spellId

	---@type number
	local elapsedTime = spellBar.combatTime --this should be actorObject:Tempo()

	---@type spelltable
	local spellTable = spellBar.spellTable

	if (IsShiftKeyDown()) then
		if (type(spellId) == "number") then
			GameCooltip:Preset(2)
			GameCooltip:SetOwner(spellBar, "ANCHOR_TOPRIGHT")
			GameCooltip:AddLine(Loc ["ABILITY_ID"] .. ": " .. spellBar.spellId)
			GameCooltip:Show()
		end
	end

	if (spellId == 98021) then --spirit link totem
		GameTooltip:SetOwner(spellBar, "ANCHOR_TOPLEFT")
		GameTooltip:AddLine(Loc ["STRING_SPIRIT_LINK_TOTEM_DESC"])
		GameTooltip:Show()
	end

	---@type number
	local blockIndex = 1

	--get the first spell block to use as summary
	---@type breakdownspellblock
	local summaryBlock = spellBlockContainer:GetBlock(blockIndex)
	summaryBlock:Show()
	summaryBlock:SetValue(50)
	summaryBlock:SetValue(100)

	if (mainAttribute == DETAILS_ATTRIBUTE_DAMAGE) then --this should run within the damage class
		local bShowDamageDone = subAttribute == DETAILS_SUBATTRIBUTE_DAMAGEDONE or subAttribute == DETAILS_SUBATTRIBUTE_DPS

		---@type number
		local totalHits = spellTable.counter

		--damage section showing damage done sub section
		blockIndex = blockIndex + 1

		do --update the texts in the summary block
			local blockLine1, blockLine2, blockLine3 = summaryBlock:GetLines()

			blockLine1.leftText:SetText(Loc ["STRING_CAST"] .. ": " .. spellBar.amountCasts) --total amount of casts
			blockLine1.rightText:SetText(Loc ["STRING_HITS"]..": " .. totalHits) --hits and uptime

			blockLine2.leftText:SetText(Loc ["STRING_DAMAGE"]..": " .. Details:Format(spellTable.total)) --total damage
			blockLine2.rightText:SetText(Details:GetSpellSchoolFormatedName(spellTable.spellschool)) --spell school

			blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:Format(spellBar.average)) --average damage
			blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellBar.perSecond)) --dps
		end

		--check if there's normal hits and build the block
		---@type number
		local normalHitsAmt = spellTable.n_amt

		if (normalHitsAmt > 0) then
			---@type breakdownspellblock
			local normalHitsBlock = spellBlockContainer:GetBlock(blockIndex)
			normalHitsBlock:Show()
			blockIndex = blockIndex + 1

			local percent = normalHitsAmt / math.max(totalHits, 0.0001) * 100
			normalHitsBlock:SetValue(percent)
			normalHitsBlock.sparkTexture:SetPoint("left", normalHitsBlock, "left", percent / 100 * normalHitsBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)

			local blockLine1, blockLine2, blockLine3 = normalHitsBlock:GetLines()
			blockLine1.leftText:SetText(Loc ["STRING_NORMAL_HITS"])
			blockLine1.rightText:SetText(normalHitsAmt .. " [|cFFC0C0C0" .. string.format("%.1f", normalHitsAmt / math.max(totalHits, 0.0001) * 100) .. "%|r]")

			blockLine2.leftText:SetText(Loc ["STRING_MINIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.n_min))
			blockLine2.rightText:SetText(Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.n_max))

			local normalAverage = spellTable.n_total / math.max(normalHitsAmt, 0.0001)
			blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:CommaValue(normalAverage))

			local tempo = (elapsedTime * spellTable.n_total) / math.max(spellTable.total, 0.001)
			local normalAveragePercent = spellBar.average / normalAverage * 100
			local normalTempoPercent = normalAveragePercent * tempo / 100
			blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellTable.n_total / normalTempoPercent))
		end

		---@type number
		local criticalHitsAmt = spellTable.c_amt
		if (criticalHitsAmt > 0) then
			---@type breakdownspellblock
			local critHitsBlock = spellBlockContainer:GetBlock(blockIndex)
			critHitsBlock:Show()
			blockIndex = blockIndex + 1

			local percent = Details.SpellTableMixin.GetCritPercent(spellTable)
			critHitsBlock:SetValue(percent)
			critHitsBlock.sparkTexture:SetPoint("left", critHitsBlock, "left", percent / 100 * critHitsBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)

			local blockLine1, blockLine2, blockLine3 = critHitsBlock:GetLines()
			blockLine1.leftText:SetText(Loc ["STRING_CRITICAL_HITS"])
			blockLine1.rightText:SetText(criticalHitsAmt .. " [|cFFC0C0C0" .. string.format("%.1f", criticalHitsAmt / math.max(totalHits, 0.0001) * 100) .. "%|r]")

			blockLine2.leftText:SetText(Loc ["STRING_MINIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.c_min))
			blockLine2.rightText:SetText(Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.c_max))

			local critAverage = Details.SpellTableMixin.GetCritAverage(spellTable)
			blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:CommaValue(critAverage))

			local tempo = (elapsedTime * spellTable.c_total) / math.max(spellTable.total, 0.001)
			local critAveragePercent = spellBar.average / critAverage * 100
			local critTempoPercent = critAveragePercent * tempo / 100
			blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellTable.c_total / critTempoPercent))
		end

	elseif (mainAttribute == DETAILS_ATTRIBUTE_HEAL) then --this should run within the heal class
		---@type number
		local totalHits = spellTable.counter

		--healing section showing healing done sub section
		blockIndex = blockIndex + 1

		do --update the texts in the summary block
			local blockLine1, blockLine2, blockLine3 = summaryBlock:GetLines()

			blockLine1.leftText:SetText(Loc ["STRING_CAST"] .. ": " .. spellBar.amountCasts) --total amount of casts
			blockLine1.rightText:SetText(Loc ["STRING_HITS"]..": " .. totalHits) --hits and uptime

			blockLine2.leftText:SetText(Loc ["STRING_HEAL"]..": " .. Details:Format(spellTable.total)) --total damage
			blockLine2.rightText:SetText(Details:GetSpellSchoolFormatedName(spellTable.spellschool)) --spell school

			blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:Format(spellBar.average)) --average damage
			blockLine3.rightText:SetText(Loc ["STRING_HPS"] .. ": " .. Details:CommaValue(spellBar.perSecond)) --dps
		end

		--check if there's normal hits and build the block
		---@type number
		local normalHitsAmt = spellTable.n_amt

		if (normalHitsAmt > 0) then
			---@type breakdownspellblock
			local normalHitsBlock = spellBlockContainer:GetBlock(blockIndex)
			normalHitsBlock:Show()
			blockIndex = blockIndex + 1

			local percent = normalHitsAmt / math.max(totalHits, 0.0001) * 100
			normalHitsBlock:SetValue(percent)
			normalHitsBlock.sparkTexture:SetPoint("left", normalHitsBlock, "left", percent / 100 * normalHitsBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)

			local blockLine1, blockLine2, blockLine3 = normalHitsBlock:GetLines()
			blockLine1.leftText:SetText(Loc ["STRING_NORMAL_HITS"])
			blockLine1.rightText:SetText(normalHitsAmt .. " [|cFFC0C0C0" .. string.format("%.1f", normalHitsAmt / math.max(totalHits, 0.0001) * 100) .. "%|r]")

			blockLine2.leftText:SetText(Loc ["STRING_MINIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.n_min))
			blockLine2.rightText:SetText(Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.n_max))

			local normalAverage = spellTable.n_total / math.max(normalHitsAmt, 0.0001)
			blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:CommaValue(normalAverage))

			local tempo = (elapsedTime * spellTable.n_total) / math.max(spellTable.total, 0.001)
			local normalAveragePercent = spellBar.average / normalAverage * 100
			local normalTempoPercent = normalAveragePercent * tempo / 100
			blockLine3.rightText:SetText(Loc ["STRING_HPS"] .. ": " .. Details:CommaValue(spellTable.n_total / normalTempoPercent))
		end

		---@type number
		local criticalHitsAmt = spellTable.c_amt
		if (criticalHitsAmt > 0) then
			---@type breakdownspellblock
			local critHitsBlock = spellBlockContainer:GetBlock(blockIndex)
			critHitsBlock:Show()
			blockIndex = blockIndex + 1

			local percent = criticalHitsAmt / math.max(totalHits, 0.0001) * 100
			critHitsBlock:SetValue(percent)
			critHitsBlock.sparkTexture:SetPoint("left", critHitsBlock, "left", percent / 100 * critHitsBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)

			local blockLine1, blockLine2, blockLine3 = critHitsBlock:GetLines()
			blockLine1.leftText:SetText(Loc ["STRING_CRITICAL_HITS"])
			blockLine1.rightText:SetText(criticalHitsAmt .. " [|cFFC0C0C0" .. string.format("%.1f", criticalHitsAmt / math.max(totalHits, 0.0001) * 100) .. "%|r]")

			blockLine2.leftText:SetText(Loc ["STRING_MINIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.c_min))
			blockLine2.rightText:SetText(Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.c_max))

			local critAverage = spellTable.c_total / math.max(criticalHitsAmt, 0.0001)
			blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:CommaValue(critAverage))

			local tempo = (elapsedTime * spellTable.c_total) / math.max(spellTable.total, 0.001)
			local critAveragePercent = spellBar.average / critAverage * 100
			local critTempoPercent = critAveragePercent * tempo / 100
			blockLine3.rightText:SetText(Loc ["STRING_HPS"] .. ": " .. Details:CommaValue(spellTable.c_total / critTempoPercent))
		end

		---@type number
		local overheal = spellTable.overheal or 0
		if (overheal > 0) then
			blockIndex = blockIndex + 1 --skip one block
			---@type breakdownspellblock
			local critHitsBlock = spellBlockContainer:GetBlock(blockIndex)
			critHitsBlock:Show()
			blockIndex = blockIndex + 1

			local blockName
			if (spellTable.is_shield) then
				blockName = Loc ["STRING_SHIELD_OVERHEAL"]
			else
				blockName = Loc ["STRING_OVERHEAL"]
			end

			local percent = overheal / (overheal + spellTable.total) * 100
			critHitsBlock:SetValue(percent)
			critHitsBlock.sparkTexture:SetPoint("left", critHitsBlock, "left", percent / 100 * critHitsBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)

			local blockLine1, blockLine2, blockLine3 = critHitsBlock:GetLines()
			blockLine1.leftText:SetText(blockName)

			local overhealString = Details:CommaValue(overheal)
			local overhealText = overhealString .. " / " .. string.format("%.1f", percent) .. "%"
			blockLine1.rightText:SetText(overhealText)
		end
	end

	--effects on entering the bar line
	spellBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT + 1)
	spellBar:SetAlpha(1)
	spellBar.spellIcon:SetSize(CONST_SPELLSCROLL_LINEHEIGHT + 2, CONST_SPELLSCROLL_LINEHEIGHT + 2)
	spellBar.spellIcon:SetAlpha(1)
end

---run this function when the mouse leaves a breakdownspellbar
---@param spellBar breakdownspellbar
local onLeaveBreakdownSpellBar = function(spellBar)
	--remove effects on entering the bar line
	spellBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	spellBar:SetAlpha(0.9)

	GameTooltip:Hide()
	GameCooltip:Hide()
end

---on mouse down a breakdownspellbar in the breakdown window
---@param spellBar breakdownspellbar
---@param button string
local onMouseDownBreakdownSpellBar = function(spellBar, button)
	local x, y = _G.GetCursorPosition()
	spellBar.cursorPosX = math.floor(x)
	spellBar.cursorPosY = math.floor(y)
end

---on mouse up a breakdownspellbar in the breakdown window
---@param spellBar breakdownspellbar
---@param button string
local onMouseUpBreakdownSpellBar = function(spellBar, button)
	spellBar.onMouseUpTime = GetTime()

	---@type number, number
	local x, y = _G.GetCursorPosition()
	x = math.floor(x)
	y = math.floor(y)

	---@type boolean
	local bIsMouseInTheSamePosition = (x == spellBar.cursorPosX) and (y == spellBar.cursorPosY)

	--if the mouse is in the same position, then the user clicked the bar
	if (bIsMouseInTheSamePosition) then
		spellsTab.SelectSpellBar(spellBar)
	end
end


local onEnterSpellIconFrame = function(self)
	local line = self:GetParent()
	if (line.spellId and type(line.spellId) == "number") then
		local spellName = _GetSpellInfo(line.spellId)
		if (spellName) then
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			Details:GameTooltipSetSpellByID(line.spellId)
			GameTooltip:Show()
		end
	end
	line:GetScript("OnEnter")(line)
end

local onLeaveSpellIconFrame = function(self)
	GameTooltip:Hide()
	self:GetParent():GetScript("OnLeave")(self:GetParent())
end

--------------------------------------------------------------------------------------------------------------------------------------------

local spellBlockMixin = {
	---get one of the three lines containing fontstrings to show data
	---line 1 is the top line, line 2 is the middle line and line 3 is the bottom line
	---@param self breakdownspellblock
	---@param lineIndex number
	---@return breakdownspellblockline
	GetLine = function(self, lineIndex)
		---@type breakdownspellblockline
		local line = self.Lines[lineIndex]
		return line
	end,

	---return all lines in the spell block, all spell block have 3 lines
	---@param self breakdownspellblock
	---@return breakdownspellblockline, breakdownspellblockline, breakdownspellblockline
	GetLines = function(self)
		return unpack(self.Lines)
	end,
}

---create a spell block into the spellblockcontainer
---@param spellBlockContainer breakdownspellblockcontainer
---@param index number
---@return breakdownspellblock
function spellsTab.CreateSpellBlock(spellBlockContainer, index) --~breakdownspellblock ~create ~spellblocks
	---@type breakdownspellblock
	local spellBlock = CreateFrame("statusbar", "$parentBlock" .. index, spellBlockContainer, "BackdropTemplate")
	DetailsFramework:Mixin(spellBlock, spellBlockMixin)

	local statusBarTexture = spellBlock:CreateTexture("$parentTexture", "artwork")
	statusBarTexture:SetColorTexture(.4, .4, .4, 1)
	statusBarTexture:SetPoint("topleft", spellBlock, "topleft", 1, -1)
	statusBarTexture:SetPoint("bottomleft", spellBlock, "bottomleft", 1, 1)
	spellBlock.statusBarTexture = statusBarTexture

	spellBlock:SetScript("OnEnter", onEnterSpellBlock)
	spellBlock:SetScript("OnLeave", onLeaveSpellBlock)
	spellBlock:SetScript("OnValueChanged", function()
		statusBarTexture:SetWidth(spellBlock:GetValue() / 100 * spellBlock:GetWidth())
	end)

	spellBlock:SetMinMaxValues(0, 100)
	spellBlock:SetValue(100)

	--set the backdrop to have a 8x8 edge file
	spellBlock:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})

	local backgroundTexture = spellBlock:CreateTexture("$parentBackground", "artwork")
	backgroundTexture:SetColorTexture(1, 1, 1, 1)
	backgroundTexture:SetAllPoints()
	spellBlock.backgroundTexture = backgroundTexture

	--create the lines which will host the texts
	spellBlock.Lines = {}
	for i = 1, spellBlockContainerSettings.lineAmount do
		---@type breakdownspellblockline
		local line = CreateFrame("frame", "$parentLine" .. i, spellBlock)
		spellBlock.Lines[i] = line

		line.leftText = line:CreateFontString("$parentLeftText", "overlay", "GameFontHighlightSmall")
		line.centerText = line:CreateFontString("$parentLeftText", "overlay", "GameFontHighlightSmall")
		line.rightText = line:CreateFontString("$parentLeftText", "overlay", "GameFontHighlightSmall")

		line.leftText:SetPoint("left", line, "left", 2, 0)
		line.leftText:SetJustifyH("left")
		line.centerText:SetPoint("center", line, "center", 0, 0)
		line.centerText:SetJustifyH("center")
		line.rightText:SetPoint("right", line, "right", -2, 0)
		line.rightText:SetJustifyH("right")
	end

	--overlay texture which fade in and out when the spell block is hovered over
	--is only possible to hover over a spell block when the spellbar is selected
	spellBlock.overlay = spellBlock:CreateTexture("$parentOverlay", "artwork")
	spellBlock.overlay:SetTexture("Interface\\AddOns\\Details\\images\\overlay_detalhes")
	spellBlock.overlay:SetPoint("topleft", spellBlock, "topleft", -8, 8)
	spellBlock.overlay:SetPoint("bottomright", spellBlock, "bottomright", 26, -14)
	Details.FadeHandler.Fader(spellBlock.overlay, 1) --hide

	--report button, also only shown when the spell block is hovered over
	spellBlock.reportButton = Details.gump:NewDetailsButton(spellBlock, nil, nil, Details.Reportar, Details.playerDetailWindow, 10 + index, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport1")
	Details.FadeHandler.Fader(spellBlock.reportButton, 1) --hide
	spellBlock.reportButton:SetScript("OnEnter", onEnterInfoReport)
	spellBlock.reportButton:SetScript("OnLeave", onLeaveInfoReport)

	--spark texture
	spellBlock.sparkTexture = spellBlock:CreateTexture("$parentOverlaySparkTexture", "overlay")
	spellBlock.sparkTexture:SetTexture("Interface\\AddOns\\Details\\images\\bar_detalhes2_end")
	spellBlock.sparkTexture:SetBlendMode("ADD")

    local gradientDown = DetailsFramework:CreateTexture(spellBlock, {gradient = "vertical", fromColor = {0, 0, 0, 0.1}, toColor = "transparent"}, 1, spellBlock:GetHeight(), "background", {0, 1, 0, 1})
    gradientDown:SetPoint("bottoms")
	spellBlock.gradientTexture = gradientDown

	return spellBlock
end

local spellBlockContainerMixin = {
	---refresh all the spellblocks in the container ~UpdateBlocks
	---this function adjust the frame properties, does not update the data shown on them
	---@param self breakdownspellblockcontainer
	UpdateBlocks = function(self) --~update
		---@type number, number
		local width, height = Details.breakdown_spell_tab.blockcontainer_width, Details.breakdown_spell_tab.blockcontainer_height
		local blockHeight = Details.breakdown_spell_tab.blockspell_height
		local backgroundColor = Details.breakdown_spell_tab.blockspell_backgroundcolor
		local borderColor = Details.breakdown_spell_tab.blockspell_bordercolor
		local padding = Details.breakdown_spell_tab.blockspell_padding * -1
		local color = Details.breakdown_spell_tab.blockspell_color

		self:SetSize(width, height)

		backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4] = 0.05, 0.05, 0.05, 0.2
		color[1], color[2], color[3], color[4] = 0.6, 0.6, 0.6, 0.55

		for i = 1, #self.SpellBlocks do
			---@type breakdownspellblock
			local spellBlock = self.SpellBlocks[i]

			spellBlock:SetSize(width - 2, blockHeight)
			spellBlock:SetPoint("topleft", self, "topleft", 1, (blockHeight * (i - 1) - i) * -1 - (i*2) + ((i-1) * padding))
			spellBlock:SetPoint("topright", self, "topright", 1, (blockHeight * (i - 1) - i) * -1 - (i*2) + ((i-1) * padding))
			spellBlock.sparkTexture:SetSize(spellBreakdownSettings.blockspell_spark_width, blockHeight)
			spellBlock.sparkTexture:SetShown(spellBreakdownSettings.blockspell_spark_show)
			spellBlock.sparkTexture:SetVertexColor(unpack(spellBreakdownSettings.blockspell_spark_color))
			spellBlock.reportButton:SetPoint("bottomright", spellBlock.overlay, "bottomright", -2, 2)
			spellBlock.gradientTexture:SetHeight(blockHeight)

			spellBlock:SetBackdropBorderColor(unpack(borderColor)) --border color
			spellBlock.backgroundTexture:SetVertexColor(unpack(backgroundColor)) --background color

			spellBlock.statusBarTexture:SetVertexColor(unpack(Details.breakdown_spell_tab.blockspell_color)) --bar color

			--update the lines
			local previousLine
			for o = 1, spellBlockContainerSettings.lineAmount do
				---@type breakdownspellblockline
				local line = spellBlock.Lines[o]
				line:SetSize(width - 2, spellBreakdownSettings.blockspellline_height)
				if (previousLine) then
					line:SetPoint("topleft", previousLine, "bottomleft", 0, -2)
				else
					line:SetPoint("topleft", spellBlock, "topleft", 1, -2)
				end
				previousLine = line
			end
		end
	end,

	---@param self breakdownspellblockcontainer
	ClearBlocks = function(self)
		for i = 1, #self.SpellBlocks do
			---@type breakdownspellblock
			local spellBlock = self.SpellBlocks[i]
			spellBlock:Hide()

			--clear the text shown in their lines
			for o = 1, 3 do
				spellBlock.Lines[o].leftText:SetText("")
				spellBlock.Lines[o].centerText:SetText("")
				spellBlock.Lines[o].rightText:SetText("")
			end
		end
	end,

	---get a breakdownspellblock from the container
	---@param self breakdownspellblockcontainer
	---@param index number
	---@return breakdownspellblock
	GetBlock = function(self, index)
		return self.SpellBlocks[index]
	end,
}

---create the spell blocks which shows the critical hits, normal hits, etc
---@param tabFrame tabframe
---@return breakdownspellblockcontainer
function spellsTab.CreateSpellBlockContainer(tabFrame)
	--create a container for the scrollframe
	local options = {
		width = Details.breakdown_spell_tab.blockcontainer_width,
		height = Details.breakdown_spell_tab.blockcontainer_height,
		is_locked = Details.breakdown_spell_tab.blockcontainer_islocked,
		can_move = false,
		can_move_children = false,
		use_bottom_resizer = true,
		use_right_resizer = true,
	}

	---@type df_framecontainer
	local container = DF:CreateFrameContainer(tabFrame, options, tabFrame:GetName() .. "SpellScrollContainer")
	container:SetPoint("topleft", spellsTab.SpellContainerFrame, "topright", 26, 0)
	container:SetFrameLevel(tabFrame:GetFrameLevel() + 10)
	spellsTab.BlocksContainerFrame = container

	local settingChangedCallbackFunction = function(frameContainer, settingName, settingValue) --doing here the callback for thge settings changed in the container
		if (frameContainer:IsShown()) then
			if (settingName == "height") then
				---@type number
				local currentHeight = spellsTab.GetSpellScrollFrame():GetHeight()
				Details.breakdown_spell_tab.blockcontainer_height = settingValue
				spellsTab.GetSpellScrollFrame():SetNumFramesShown(math.floor(currentHeight / CONST_SPELLSCROLL_LINEHEIGHT) - 1)

			elseif (settingName == "width") then
				Details.breakdown_spell_tab.blockcontainer_width = settingValue

			elseif (settingName == "is_locked") then
				Details.breakdown_spell_tab.blockcontainer_islocked = settingValue
			end
		end
	end
	container:SetSettingChangedCallback(settingChangedCallbackFunction)

	--create the container which will hold the spell blocks
	---@type breakdownspellblockcontainer
	local spellBlockFrame = CreateFrame("Frame", "$parentSpellBlockContainer", container, "BackdropTemplate")
	spellBlockFrame:EnableMouse(false)
	spellBlockFrame:SetResizable(false)
	spellBlockFrame:SetMovable(false)
	spellBlockFrame:SetAllPoints()
	DetailsFramework:Mixin(spellBlockFrame, spellBlockContainerMixin)

	tabFrame.SpellBlockFrame = spellBlockFrame
	spellsTab.SpellBlockFrame = spellBlockFrame

	container:RegisterChildForDrag(spellBlockFrame)

	spellBlockFrame.SpellBlocks = {}

	--create the spell blocks within the spellBlockFrame
	for i = 1, spellBlockContainerSettings.amount do
		---@type breakdownspellblock
		local spellBlock = spellsTab.CreateSpellBlock(spellBlockFrame, i)
		table.insert(spellBlockFrame.SpellBlocks, spellBlock)
		--size and point are set on ~UpdateBlocks
	end

	spellBlockFrame:UpdateBlocks()

	return spellBlockFrame
end

function spellsTab.CreateTargetContainer(tabFrame)
    local container_alvos_window = CreateFrame("ScrollFrame", "Details_Info_ContainerAlvosScroll", tabFrame, "BackdropTemplate")
    local container_alvos = CreateFrame("Frame", "Details_Info_ContainerAlvos", container_alvos_window, "BackdropTemplate")

    container_alvos:SetAllPoints(container_alvos_window)
    container_alvos:SetSize(300, 100)
    container_alvos:EnableMouse(true)
    container_alvos:SetMovable(true)

    container_alvos_window:SetSize(300, 100)
    container_alvos_window:SetScrollChild(container_alvos)
    container_alvos_window:SetPoint("bottomleft", tabFrame, "bottomleft", 20, 6) --56 default

    container_alvos_window:SetScript("OnSizeChanged", function(self)
        container_alvos:SetSize(self:GetSize())
    end)

    _detalhes.gump:NewScrollBar(container_alvos_window, container_alvos, 7, 4)
    container_alvos_window.slider:Altura(88)
    container_alvos_window.slider:cimaPoint(0, 1)
    container_alvos_window.slider:baixoPoint(0, -3)

    container_alvos_window.gump = container_alvos
    tabFrame.container_alvos = container_alvos_window

	tabFrame.targets = tabFrame:CreateFontString(nil, "OVERLAY", "QuestFont_Large")
	tabFrame.targets:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 24, -273)
	tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
end

--logistics: class_damage build the list of spells, send it to window_playerbreakdown, which gets the current summary tab and send the data for it
--in this tab, the data is sent to the refresh function

local onClickExpandButton = function(expandButton, button)
	---@type breakdownspellbar
	local spellBar = expandButton:GetParent()
	---@type table
	local scrolFrame = spellBar:GetParent()
	---@type boolean
	local bIsSpellExpaded = expandButton.bIsSpellExpaded

	--check if the one of the expanded bars was a selected spellbar and deselect
	--get the current selected spellbar
	---@type breakdownspellbar
	local selectedSpellBar = spellsTab.GetSelectedSpellBar()

	if (bIsSpellExpaded) then --it's already expended, it'll close the expanded spellbars
		--check if the selected spellbar is one of the expanded spellbars and deselect it
		for i = 1, #spellBar.ExpandedChildren do
			---@type breakdownspellbar
			local expandedSpellBar = spellBar.ExpandedChildren[i]
			if (expandedSpellBar == selectedSpellBar) then
				--deselect the spellbar
				spellsTab.UnSelectSpellBar()
				break
			end
		end
	else
		spellsTab.UnSelectSpellBar()
	end

	--todo: check is any other bar has expanded state true, and close the expand (or not)

	--toggle this spell expand mode
	Details222.BreakdownWindow.SetSpellAsExpanded(expandButton.spellId, not bIsSpellExpaded)
	--refresh the scrollFrame
	scrolFrame:Refresh()
end

---update a line using the data passed
---@param spellBar breakdownspellbar
---@param index number spell position (from best to wrost)
---@param actorName string
---@param combatObject combat
---@param scrollFrame table
---@param headerTable table
---@param bkSpellData spelltableadv
---@param bkSpellStableIndex number
---@param totalValue number
---@param maxValue number
---@param bIsMainLine boolean if true this is the line which has all the values of the spell merged
local updateSpellBar = function(spellBar, index, actorName, combatObject, scrollFrame, headerTable, bkSpellData, bkSpellStableIndex, totalValue, maxValue, bIsMainLine)
	--scrollFrame is defined as a table which is false, scrollFrame is a frame

	local textIndex = 1
	for headerIndex = 1, #headerTable do
		---@type number
		local spellId
		---@type number
		local value
		---@type spelltable
		local spellTable

		local petName = ""

		spellBar.bkSpellData = bkSpellData

		if (bIsMainLine) then
			spellTable = bkSpellData
			value = bkSpellData.total
			spellId = bkSpellData.id
			petName = bkSpellData.petNames[bkSpellStableIndex]
		else
			spellTable = bkSpellData.spellTables[bkSpellStableIndex]
			value = spellTable.total
			spellId = spellTable.id
			petName = bkSpellData.petNames[bkSpellStableIndex]
			spellBar.bIsExpandedSpell = true
		end

		spellBar.spellId = spellId

		---@cast spellTable spelltable
		spellBar.spellTable = spellTable

		---@type number
		local amtCasts = combatObject:GetSpellCastAmount(actorName, spellId)
		spellBar.amountCasts = amtCasts
		---@type number
		local uptime = combatObject:GetSpellUptime(actorName, spellId)
		---@type number
		local combatTime = combatObject:GetCombatTime()
		---@type string, number, string
		local spellName, _, spellIcon = Details.GetSpellInfo(spellId)

		if (petName ~= "") then
			spellName = spellName .. " (" .. petName .. ")"
		end

		spellBar.spellId = spellId
		spellBar.spellIconFrame.spellId = spellId

		spellBar.statusBar.backgroundTexture:SetAlpha(Details.breakdown_spell_tab.spellbar_background_alpha)

		--statusbar size by percent
		if (maxValue > 0) then
			spellBar.statusBar:SetValue(value / maxValue * 100)
		else
			spellBar.statusBar:SetValue(0)
		end

		--statusbar color by school
		local r, g, b = Details:GetSpellSchoolColor(spellTable.spellschool or 1)
		spellBar.statusBar:SetStatusBarColor(r, g, b, 1)

		spellBar.average = value / spellTable.counter
		spellBar.combatTime = combatTime

		---@type fontstring
		local text = spellBar.InLineTexts[textIndex]
		local header = headerTable[headerIndex]

		if (header.name == "icon") then --ok
			spellBar.spellIcon:Show()
			spellBar.spellIcon:SetTexture(spellIcon)
			spellBar:AddFrameToHeaderAlignment(spellBar.spellIconFrame)

		elseif (header.name == "target") then --the tab does not have knownledge about the targets of the spell, it must be passed over
			---@type breakdowntargetframe
			local targetsSquareFrame = spellBar.targetsSquareFrame
			targetsSquareFrame:Show()
			targetsSquareFrame.spellId = spellId
			targetsSquareFrame.bkSpellData = spellTable
			targetsSquareFrame.spellTable = spellTable
			targetsSquareFrame.bIsMainLine = bIsMainLine
			spellBar:AddFrameToHeaderAlignment(targetsSquareFrame)

		elseif (header.name == "rank") then --ok
			text:SetText(index)
			spellBar:AddFrameToHeaderAlignment(text)
			spellBar.rank = index
			textIndex = textIndex + 1

		elseif (header.name == "expand") then
			text:SetText("")
			spellBar:AddFrameToHeaderAlignment(spellBar.expandButton)
			textIndex = textIndex + 1

			if (bkSpellData.bCanExpand and bIsMainLine) then
				spellBar.expandButton:Show()
				local bIsSpellExpaded = Details222.BreakdownWindow.IsSpellExpanded(spellId)

				spellBar.expandButton.spellId = spellId
				spellBar.expandButton.bIsSpellExpaded = bIsSpellExpaded
				spellBar.expandButton:SetScript("OnClick", onClickExpandButton)

				--update the texture taking the state of the expanded value
				spellBar.expandButton.texture:SetTexture(bIsSpellExpaded and [[Interface\BUTTONS\Arrow-Up-Down]] or [[Interface\BUTTONS\Arrow-Down-Down]])
			end

		elseif (header.name == "name") then --ok
			text:SetText(spellName)
			spellBar.name = spellName
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "amount") then --ok
			text:SetText(Details:Format(value))
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "persecond") then --ok
			spellBar.perSecond = value / combatTime

			---@type string
			local perSecondFormatted = Details:Format(spellBar.perSecond)
			text:SetText(perSecondFormatted)

			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "percent") then --ok
			spellBar.percent = value / totalValue * 100
			---@type string
			local percentFormatted = string.format("%.1f", spellBar.percent) .. "%"
			text:SetText(percentFormatted)

			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "casts") then
			text:SetText(amtCasts)
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "critpercent") then
			text:SetText(string.format("%.1f", spellTable.c_amt / (spellTable.counter) * 100) .. "%")
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "hits") then
			text:SetText(spellTable.counter)
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "castavg") then
			if (amtCasts > 0) then
				spellBar.castAverage = value / amtCasts
				text:SetText(Details:Format(spellBar.castAverage))
			else
				text:SetText("0")
			end
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "uptime") then --need to get the uptime of the spell with the biggest uptime
			text:SetText(string.format("%.1f", uptime / combatTime * 100) .. "%")
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "overheal") then
			text:SetText(Details:Format(spellTable.overheal or 0))
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "absorbed") then
			text:SetText(Details:Format(spellTable.absorbed or 0))
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		end
	end

	spellBar:AlignWithHeader(scrollFrame.Header, "left")
end

---get a spell bar from the scroll box, if it doesn't exist, return nil
---@param scrollFrame table
---@param lineIndex number
---@return breakdownspellbar
local getSpellBar = function(scrollFrame, lineIndex)
	---@type breakdownspellbar
	local spellBar = scrollFrame:GetLine(lineIndex)

	spellBar.bIsExpandedSpell = false

	wipe(spellBar.ExpandedChildren)

	--reset header alignment
	spellBar:ResetFramesToHeaderAlignment()

	--reset columns, hiding them
	spellBar.spellIcon:Hide()
	spellBar.expandButton:Hide()
	spellBar.targetsSquareFrame:Hide()
	for inLineIndex = 1, #spellBar.InLineTexts do
		spellBar.InLineTexts[inLineIndex]:SetText("")
	end

	return spellBar
end

---refresh the data shown in the spells scroll box
---@param scrollFrame table
---@param scrollData breakdownspelldatalist
---@param offset number
---@param totalLines number
local refreshFunc = function(scrollFrame, scrollData, offset, totalLines) --~refreshspells ~refresh
	---@type number
	local maxValue = scrollData[1] and scrollData[1].total
	local maxValue = scrollFrame.maxValue
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

	local headerTable = spellsTab.spellsHeaderData

	--todo: when swapping sort orders, close allexpanded spells

	local lineIndex = 1
	for i = 1, totalLines do
		local index = i + offset

		---@type spelltableadv
		local bkSpellData = scrollData[index]

		if (bkSpellData) then
			--before getting a line, check if the data for the line is a expanded line and if the spell is expanded
			local expandedIndex = bkSpellData.expandedIndex
			local spellId = bkSpellData.id
			local value = math.floor(bkSpellData.total)

			---@type number[]
			local spellIds = bkSpellData.spellIds --array with spellIds
			---@type spelltable[]
			local spellTables = bkSpellData.spellTables --array with spellTables
			---@type number
			local spellTablesAmount = #spellTables
			---@type string[]
			local petNames = bkSpellData.petNames --array with pet names
			---@type boolean

			---called mainSpellBar because it is the line that shows the sum of all spells merged (if any)
			---@type breakdownspellbar
			local mainSpellBar = getSpellBar(scrollFrame, lineIndex)
			do
				--main line of the spell, where the sum of all spells merged is shown
				if (mainSpellBar) then
					lineIndex = lineIndex + 1
					local bIsMainLine = true
					updateSpellBar(mainSpellBar, index, actorName, combatObject, scrollFrame, headerTable, bkSpellData, 1, totalValue, maxValue, bIsMainLine)
				end
			end

			--then it adds the lines for each spell merged, but it cannot use the bkSpellData, it needs the spellTable
			if (bkSpellData.bIsExpanded and spellTablesAmount > 1) then
				---@type number spellTableIndex is the same counter as bkSpellStableIndex
				for spellTableIndex = 1, spellTablesAmount do
					---@type breakdownspellbar
					local spellBar = getSpellBar(scrollFrame, lineIndex)
					if (spellBar) then
						lineIndex = lineIndex + 1
						---@type string
						local petName = petNames[spellTableIndex]
						---@type string
						local nameToUse = petName ~= "" and petName or actorName
						local bIsMainLine = false
						updateSpellBar(spellBar, index, nameToUse, combatObject, scrollFrame, headerTable, bkSpellData, spellTableIndex, totalValue, maxValue, bIsMainLine)
						mainSpellBar.ExpandedChildren[#mainSpellBar.ExpandedChildren + 1] = spellBar
					end
				end
			end

			if (lineIndex > totalLines) then
				break
			end
		end
	end
end

---creates a scrollframe which show breakdownspellbar to show the spells used by an actor
---@param tabFrame tabframe
---@return breakdownspellscrollframe
function spellsTab.CreateSpellScrollContainer(tabFrame) --~scroll ~create
	---@type width
	local width = Details.breakdown_spell_tab.spellcontainer_width
	---@type height
	local height = Details.breakdown_spell_tab.spellcontainer_height

	--create a container for the scrollframe
	local options = {
		width = Details.breakdown_spell_tab.spellcontainer_width,
		height = Details.breakdown_spell_tab.spellcontainer_height,
		is_locked = Details.breakdown_spell_tab.spellcontainer_islocked,
		can_move = false,
		can_move_children = false,
		use_bottom_resizer = true,
		use_right_resizer = true,

	}

	---@type df_framecontainer
	local container = DF:CreateFrameContainer(tabFrame, options, tabFrame:GetName() .. "SpellScrollContainer")
	container:SetPoint("topleft", tabFrame, "topleft", 5, -5)
	container:SetFrameLevel(tabFrame:GetFrameLevel() + 10)
	spellsTab.SpellContainerFrame = container

	local settingChangedCallbackFunction = function(frameContainer, settingName, settingValue) --doing here the callback for thge settings changed in the container
		if (frameContainer:IsShown()) then
			if (settingName == "height") then
				---@type number
				local currentHeight = spellsTab.GetSpellScrollFrame():GetHeight()
				Details.breakdown_spell_tab.spellcontainer_height = settingValue
				spellsTab.GetSpellScrollFrame():SetNumFramesShown(math.floor(currentHeight / CONST_SPELLSCROLL_LINEHEIGHT) - 1)

			elseif (settingName == "width") then
				Details.breakdown_spell_tab.spellcontainer_width = settingValue

			elseif (settingName == "is_locked") then
				Details.breakdown_spell_tab.spellcontainer_islocked = settingValue
			end
		end
	end
	local defaultAmountOfLines = 50
	container:SetSettingChangedCallback(settingChangedCallbackFunction)

    --replace this with a framework scrollframe
	---@type breakdownspellscrollframe
	local scrollFrame = DF:CreateScrollBox(container, "$parentSpellScroll", refreshFunc, {}, width, height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(scrollFrame)
	scrollFrame:SetBackdrop({})
	scrollFrame:SetPoint("topleft", container, "topleft", 0, 0) --need to set the points
	scrollFrame:SetPoint("bottomright", container, "bottomright", 0, 0) --need to set the points

	container:RegisterChildForDrag(scrollFrame)

	scrollFrame.DontHideChildrenOnPreRefresh = true
	tabFrame.SpellScrollFrame = scrollFrame
	spellsTab.SpellScrollFrame = scrollFrame

	--~header
	local headerOptions = {
		padding = 2,

		header_height = 14,
		reziser_shown = true,
		reziser_width = 2,
		reziser_color = {.5, .5, .5, 0.7},
		reziser_max_width = 246,

		header_click_callback = onColumnHeaderClickCallback,
	}

	local headerTable = {}

	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, headerTable, headerOptions)
	scrollFrame.Header = header
	scrollFrame.Header:SetPoint("topleft", scrollFrame, "topleft", 0, 1)
	scrollFrame.Header:SetColumnSettingChangedCallback(onHeaderColumnOptionChanged)

	--cache the type of this container
	headerContainerType[scrollFrame.Header] = "spells"

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		scrollFrame:CreateLine(spellsTab.CreateSpellBar)
	end

	---set the data and refresh the scrollframe
	---@param self any
	---@param data breakdownspelldatalist
	function scrollFrame:RefreshMe(data) --~refreshme
		--get which column is currently selected and the sort order
		local columnIndex, order, key = scrollFrame.Header:GetSelectedColumn()

		---@type combat
		local combatObject = spellsTab.GetCombat()
		---@type number, number
		local mainAttribute, subAttribute = spellsTab.GetInstance():GetDisplay()

		--filling necessary information to sort the data in the order the header wants
		for i = 1, #data do
			---@type spelltableadv
			local bkSpellData = data[i]

			--crit percent
			bkSpellData.critpercent = bkSpellData:GetCritPercent()

			--cast amount
			bkSpellData.casts = bkSpellData:GetCastAmount(spellsTab.GetActor():Name(), combatObject)

			--cast avg
			bkSpellData.castavg = bkSpellData:GetCastAverage(bkSpellData.casts)

			--uptime
			local uptime = combatObject:GetSpellUptime(spellsTab:GetActor():Name(), bkSpellData.id)
			bkSpellData.uptime = uptime

			if (mainAttribute == DETAILS_ATTRIBUTE_HEAL) then
				bkSpellData.healabsorbed = bkSpellData.absorbed
			end
		end

		---@type string
		local keyToSort = key

		if (order == "DESC") then
			table.sort(data,
			---@param t1 spelltableadv
			---@param t2 spelltableadv
			function(t1, t2)
				return t1[keyToSort] > t2[keyToSort]
			end)
			self.maxValue = data[1] and data[1][keyToSort]
		else
			table.sort(data,
			---@param t1 spelltableadv
			---@param t2 spelltableadv
			function(t1, t2)
				return t1[keyToSort] < t2[keyToSort]
			end)
			self.maxValue = data[#data] and data[#data][keyToSort]
		end

		self:SetData(data)
		self:Refresh()
	end

	return scrollFrame
end

---on enter function for the spell target frame
---@param targetFrame breakdowntargetframe
local onEnterSpellTarget = function(targetFrame)
	--the spell target frame is created in the statusbar which is placed above the line frame
	local lineBar = targetFrame:GetParent():GetParent()
	local spellId = targetFrame.spellId

	---@type actor
	local actorObject = Details:GetActorObjectFromBreakdownWindow()

	local targets
	if (targetFrame.bIsMainLine) then
		---@type spelltableadv
		local bkSpellData = targetFrame.bkSpellData
		targets = actorObject:BuildSpellTargetFromBreakdownSpellData(bkSpellData)
	else
		local spellTable = targetFrame.spellTable
		targets = actorObject:BuildSpellTargetFromSpellTable(spellTable)
	end

	---@type number the top value of targets
	local topValue = targets[1] and targets[1][2] or 0

	local cooltip = GameCooltip
	cooltip:Preset(2)

	for targetIndex, targetTable in ipairs(targets) do
		local targetName = targetTable[1]
		local value = targetTable[2]
		cooltip:AddLine(targetIndex .. ". " .. targetName, Details:Format(value))
		GameCooltip:AddIcon([[Interface\MINIMAP\TRACKING\Target]], 1, 1, 14, 14)
		Details:AddTooltipBackgroundStatusbar(false, value / topValue * 100)
	end

	cooltip:SetOwner(targetFrame)
	cooltip:Show()

	if true then return end

	do
		if (spellId and type(spellId) == "number") then
			---@type actor
			local actorObject = lineBar.other_actor or breakdownWindow.jogador
			local spellTable = actorObject.spells and actorObject.spells:GetSpell(spellId)

			if (spellTable) then
				local spellsSortedResult = {}
				local targetContainer
				local total = 0

				if (spellTable.isReflection) then
					targetContainer = spellTable.extra
				else
					local attribute, subAttribute = breakdownWindow.instancia:GetDisplay()
					if (attribute == 1 or attribute == 3) then
						targetContainer = spellTable.targets
					else
						if (subAttribute == 3) then --overheal
							targetContainer = spellTable.targets_overheal

						elseif (subAttribute == 6) then --absorbs
							targetContainer = spellTable.targets_absorbs

						else
							targetContainer = spellTable.targets
						end
					end
				end

				--add and sort
				for targetName, amount in pairs(targetContainer) do
					if (amount > 0) then
						spellsSortedResult[#spellsSortedResult+1] = {targetName, amount}
						total = total + amount
					end
				end
				table.sort(spellsSortedResult, Details.Sort2)

				local spellName, _, spellIcon = _GetSpellInfo(spellId)

				GameTooltip:SetOwner(targetFrame, "ANCHOR_TOPRIGHT")
				GameTooltip:AddLine(lineBar.index .. ". " .. spellName)
				GameTooltip:AddLine(Loc ["STRING_TARGETS"] .. ":")
				GameTooltip:AddLine(" ")

				--get time type
				local timeElapsed
				if (Details.time_type == 1 or not actorObject.grupo) then
					timeElapsed = actorObject:Tempo()
				elseif (Details.time_type == 2) then
					timeElapsed = breakdownWindow.instancia.showing:GetCombatTime()
				end

				local abbreviationFunction = Details.ToKFunctions[Details.ps_abbreviation]

				if (spellTable.isReflection) then
					Details:FormatCooltipForSpells()
					GameCooltip:SetOwner(targetFrame, "bottomright", "top", 4, -2)

					Details:AddTooltipSpellHeaderText("Spells Reflected", {1, 0.9, 0.0, 1}, 1, select(3, _GetSpellInfo(spellTable.id)), 0.1, 0.9, 0.1, 0.9) --localize-me
					Details:AddTooltipHeaderStatusbar(1, 1, 1, 0.4)

					GameCooltip:AddIcon(select(3, _GetSpellInfo(spellTable.id)), 1, 1, 16, 16, .1, .9, .1, .9)
					Details:AddTooltipHeaderStatusbar(1, 1, 1, 0.5)

					local topAmount = spellsSortedResult[1] and spellsSortedResult[1][2]

					for index, targetTable in ipairs(spellsSortedResult) do
						local targetName = targetTable[1]
						local amount = targetTable[2]

						GameCooltip:AddLine(spellName, abbreviationFunction(_, amount) .. " (" .. math.floor(amount / topAmount * 100) .. "%)")
						GameCooltip:AddIcon(spellIcon, 1, 1, 16, 16, .1, .9, .1, .9)
						Details:AddTooltipBackgroundStatusbar(false, amount / topAmount * 100)
					end

					GameCooltip:Show()

					targetFrame.texture:SetAlpha(1)
					targetFrame:SetAlpha(1)
					lineBar:GetScript("OnEnter")(lineBar)
					return
				else
					for index, targetTable in ipairs(spellsSortedResult) do
						local targetName = targetTable[1]
						local amount = targetTable[2]

						local class = Details:GetClass(targetName)
						if (class and Details.class_coords[class]) then
							local cords = Details.class_coords[class]
							if (breakdownWindow.target_persecond) then
								GameTooltip:AddDoubleLine(index .. ". |TInterface\\AddOns\\Details\\images\\classes_small_alpha:14:14:0:0:128:128:"..cords[1]*128 ..":"..cords[2]*128 ..":"..cords[3]*128 ..":"..cords[4]*128 .."|t " .. targetName, Details:comma_value(math.floor(amount / timeElapsed)), 1, 1, 1, 1, 1, 1)
							else
								GameTooltip:AddDoubleLine(index .. ". |TInterface\\AddOns\\Details\\images\\classes_small_alpha:14:14:0:0:128:128:"..cords[1]*128 ..":"..cords[2]*128 ..":"..cords[3]*128 ..":"..cords[4]*128 .."|t " .. targetName, abbreviationFunction(_, amount), 1, 1, 1, 1, 1, 1)
							end
						else
							if (breakdownWindow.target_persecond) then
								GameTooltip:AddDoubleLine(index .. ". " .. targetName, Details:comma_value(math.floor(amount / timeElapsed)), 1, 1, 1, 1, 1, 1)
							else
								GameTooltip:AddDoubleLine(index .. ". " .. targetName, abbreviationFunction(_, amount), 1, 1, 1, 1, 1, 1)
							end
						end
					end
				end

				GameTooltip:Show()
			else
				GameTooltip:SetOwner(targetFrame, "ANCHOR_TOPRIGHT")
				GameTooltip:AddLine(lineBar.index .. ". " .. lineBar.spellId)
				GameTooltip:AddLine(breakdownWindow.target_text)
				GameTooltip:AddLine(Loc ["STRING_NO_TARGET"], 1, 1, 1)
				GameTooltip:AddLine(Loc ["STRING_MORE_INFO"], 1, 1, 1)
				GameTooltip:Show()
			end
		else
			GameTooltip:SetOwner(targetFrame, "ANCHOR_TOPRIGHT")
			GameTooltip:AddLine(lineBar.index .. ". " .. lineBar.spellId)
			GameTooltip:AddLine(breakdownWindow.target_text)
			GameTooltip:AddLine(Loc ["STRING_NO_TARGET"], 1, 1, 1)
			GameTooltip:AddLine(Loc ["STRING_MORE_INFO"], 1, 1, 1)
			GameTooltip:Show()
		end

		targetFrame.texture:SetAlpha(.7)
		targetFrame:SetAlpha(1)
		lineBar:GetScript("OnEnter")(lineBar)
	end
end

local onLeaveSpellTarget = function(self)
	GameTooltip:Hide()
	GameCooltip:Hide()
	self:GetParent():GetParent():GetScript("OnLeave")(self:GetParent():GetParent())
	self.texture:SetAlpha(.7)
	self:SetAlpha(.7)
end

---create a spellbar within the spell scroll
---@param self breakdownspellscrollframe
---@param index number
---@return breakdownspellbar
function spellsTab.CreateSpellBar(self, index) --~spellbar ~spellline ~spell ~create ~createline ~createspell
	---@type breakdownspellbar
	local spellBar = CreateFrame("button", self:GetName() .. "SpellBarButton" .. index, self)
	spellBar.index = index

	--size and positioning
	spellBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	local y = (index-1) * CONST_SPELLSCROLL_LINEHEIGHT * -1 + (1 * -index) - 15
	spellBar:SetPoint("topleft", self, "topleft", 0, y)
	spellBar:SetPoint("topright", self, "topright", 0, y)

	spellBar:EnableMouse(true)
	spellBar:RegisterForClicks("AnyUp", "AnyDown")
	spellBar:SetAlpha(0.9)
	spellBar:SetFrameStrata("HIGH")
	spellBar:SetScript("OnEnter", onEnterBreakdownSpellBar)
	spellBar:SetScript("OnLeave", onLeaveBreakdownSpellBar)
	spellBar:SetScript("OnMouseDown", onMouseDownBreakdownSpellBar)
	spellBar:SetScript("OnMouseUp", onMouseUpBreakdownSpellBar)
	spellBar.onMouseUpTime = 0
	spellBar.ExpandedChildren = {}

	DF:Mixin(spellBar, DF.HeaderFunctions)

	---@type breakdownspellbarstatusbar
	local statusBar = CreateFrame("StatusBar", "$parentStatusBar", spellBar)
	statusBar:SetAllPoints()
	statusBar:SetAlpha(0.5)
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetValue(50)
	statusBar:EnableMouse(false)
	statusBar:SetFrameLevel(spellBar:GetFrameLevel() - 1)
	spellBar.statusBar = statusBar

	---@type texture this is the statusbar texture
	local statusBarTexture = statusBar:CreateTexture("$parentTexture", "artwork")
	statusBarTexture:SetTexture(SharedMedia:Fetch("statusbar", "Details Hyanda"))
	statusBar:SetStatusBarTexture(statusBarTexture)
	statusBar:SetStatusBarColor(1, 1, 1, 1)

	---@type texture overlay texture to use when the spellbar is selected
	local statusBarOverlayTexture = statusBar:CreateTexture("$parentTextureOverlay", "overlay", nil, 7)
	statusBarOverlayTexture:SetTexture([[Interface/AddOns/Details/images/overlay_indicator_1]])
	statusBarOverlayTexture:SetVertexColor(1, 1, 1, 0.2)
	statusBarOverlayTexture:SetAllPoints()
	statusBarOverlayTexture:Hide()
	spellBar.overlayTexture = statusBarOverlayTexture
	statusBar.overlayTexture = statusBarOverlayTexture

	---@type texture shown when the mouse hoverover this spellbar
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

	--button to expand the bar when there's spells merged
	---@type breakdownexpandbutton
	local expandButton = CreateFrame("button", "$parentExpandButton", spellBar, "BackdropTemplate")
	expandButton:SetSize(CONST_BAR_HEIGHT, CONST_BAR_HEIGHT)
	expandButton:RegisterForClicks("LeftButtonDown")
	spellBar.expandButton = expandButton

	---@type texture
	local expandButtonTexture = expandButton:CreateTexture("$parentTexture", "artwork")
	expandButtonTexture:SetPoint("center", expandButton, "center", 0, 0)
	expandButtonTexture:SetSize(CONST_BAR_HEIGHT-2, CONST_BAR_HEIGHT-2)
	expandButton.texture = expandButtonTexture

	--frame which will show the spell tooltip
	---@type frame
	local spellIconFrame = CreateFrame("frame", "$parentIconFrame", spellBar, "BackdropTemplate")
	spellIconFrame:SetSize(CONST_BAR_HEIGHT - 2, CONST_BAR_HEIGHT - 2)
	spellIconFrame:SetScript("OnEnter", onEnterSpellIconFrame)
	spellIconFrame:SetScript("OnLeave", onLeaveSpellIconFrame)
	spellBar.spellIconFrame = spellIconFrame

	--create the icon to show the spell texture
	---@type texture
	local spellIcon = spellIconFrame:CreateTexture("$parentTexture", "overlay")
	spellIcon:SetAllPoints()
	spellIcon:SetTexCoord(.1, .9, .1, .9)
	spellBar.spellIcon = spellIcon

	--create a square frame which is placed at the right side of the line to show which targets for damaged by the spell
	---@type breakdowntargetframe
	local targetsSquareFrame = CreateFrame("frame", "$parentTargetsFrame", statusBar, "BackdropTemplate")
	targetsSquareFrame:SetSize(CONST_SPELLSCROLL_LINEHEIGHT, CONST_SPELLSCROLL_LINEHEIGHT)
	targetsSquareFrame:SetAlpha(.7)
	targetsSquareFrame:SetScript("OnEnter", onEnterSpellTarget)
	targetsSquareFrame:SetScript("OnLeave", onLeaveSpellTarget)
	targetsSquareFrame:SetFrameLevel(statusBar:GetFrameLevel()+2)
	spellBar.targetsSquareFrame = targetsSquareFrame

	---@type texture
	local targetTexture = targetsSquareFrame:CreateTexture("$parentTexture", "overlay")
	targetTexture:SetTexture([[Interface\MINIMAP\TRACKING\Target]])
	targetTexture:SetAllPoints()
	targetTexture:SetDesaturated(true)
	spellBar.targetsSquareTexture = targetTexture
	targetsSquareFrame.texture = targetTexture

	spellBar:AddFrameToHeaderAlignment(spellIconFrame)
	spellBar:AddFrameToHeaderAlignment(targetsSquareFrame)

	--create texts
	---@type fontstring[]
	spellBar.InLineTexts = {}

	for i = 1, 16 do
		---@type fontstring
		local fontString = spellBar:CreateFontString("$parentFontString" .. i, "overlay", "GameFontHighlightSmall")
		fontString:SetJustifyH("left")
		fontString:SetTextColor(1, 1, 1, 1)
		fontString:SetNonSpaceWrap(true)
		fontString:SetWordWrap(false)
		spellBar["lineText" .. i] = fontString
		spellBar.InLineTexts[i] = fontString
		fontString:SetTextColor(1, 1, 1, 1)
		spellBar:AddFrameToHeaderAlignment(fontString)
	end

	spellBar:AlignWithHeader(self.Header, "left")
	return spellBar
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
		spellsTab.GetSpellScrollFrame():RefreshMe(data)
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

function spellsTab.CreateReportButtons(tabFrame)
    --spell list report button
	tabFrame.report_esquerda = Details.gump:NewDetailsButton(tabFrame, tabFrame, nil, _detalhes.Reportar, tabFrame, 1, 16, 16, "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport2")
	tabFrame.report_esquerda:SetPoint("bottomleft", spellsTab.GetSpellScrollFrame(), "TOPLEFT",  33, 3)
	tabFrame.report_esquerda:SetFrameLevel(tabFrame:GetFrameLevel()+2)
	tabFrame.topleft_report = tabFrame.report_esquerda

	--targets report button
	tabFrame.report_alvos = Details.gump:NewDetailsButton(tabFrame, tabFrame, nil, _detalhes.Reportar, tabFrame, 3, 16, 16,	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport3")
	tabFrame.report_alvos:SetPoint("bottomright", tabFrame.container_alvos, "TOPRIGHT",  -2, -1)
	tabFrame.report_alvos:SetFrameLevel(3) --solved inactive problem

	--special barras in the right report button
	tabFrame.report_direita = Details.gump:NewDetailsButton(tabFrame, tabFrame, nil, _detalhes.Reportar, tabFrame, 2, 16, 16, "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport4")
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
    local amt = _detalhes.report_lines

    local tabFrame = spellsTab.TabFrame

	if (not player) then
		_detalhes:Msg("Player not found.")
		return
	end

	local report_lines

	if (botao == 1) then --spell data
		if (mainSection == 1 and subSection == 4) then --friendly fire
			report_lines = {"Details!: " .. player.nome .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] .. ":"}

		elseif (mainSection == 1 and subSection == 3) then --damage taken
			report_lines = {"Details!: " .. player.nome .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"] .. ":"}

		else
			report_lines = {"Details!: " .. player.nome .. " - " .. _detalhes.sub_atributos [mainSection].lista [subSection] .. ""}
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

		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTARGETS"] .. " " .. _detalhes.sub_atributos [1].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome}

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

			report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [mainSection].lista [subSection] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome,
			Loc ["STRING_ACTORFRAME_SPELLDETAILS"] .. ": " .. nome}

			for i = 1, 5 do
				local caixa = _detalhes.playerDetailWindow.grupos_detalhes[i]
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
				report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [1].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.detalhes.. " " .. Loc ["STRING_ACTORFRAME_REPORTAT"] .. " " .. player.nome}
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

		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [mainSection].lista [subSection].. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome,
		Loc ["STRING_ACTORFRAME_SPELLDETAILS"] .. ": " .. nome}

		local caixa = _detalhes.playerDetailWindow.grupos_detalhes[botao]

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
