
local addonName, Details222 = ...
local breakdownWindow = Details.BreakdownWindow
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local unpack = unpack
local GetTime = GetTime
local wipe = wipe
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

local spellBlockContainerSettings = {
	amount = 6, --amount of block the container have
	lineAmount = 3, --amount of line each block have
}

local spellBreakdownSettings = {}

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

---@return breakdowntargetscrollframe
function spellsTab.GetPhaseScrollFrame()
	return spellsTab.PhaseScrollFrame
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

function spellsTab.GetScrollFrameByContainerType(containerType)
	if (containerType == "spells") then
		return spellsTab.GetSpellScrollFrame()

	elseif (containerType == "targets") then
		return spellsTab.GetTargetScrollFrame()

	elseif (containerType == "phases") then
		return spellsTab.GetPhaseScrollFrame()
	end
end

function spellsTab.OnProfileChange()
	--no need to cache, just call the db from there
	spellsTab.UpdateHeadersSettings("spells")
	spellsTab.UpdateHeadersSettings("targets")
	spellsTab.UpdateHeadersSettings("phases")
end

------------------------------------------------------------------------------------------------------------------------------------------------
--Header

---store the header object has key and its type as value, the header type can be 'spell' or 'target'
---@type table<uiobject, string>
local headerContainerType = {}

---@type number
local columnOffset = 0

---column header information saved into details database: if is enabaled, its with and align
---@class headercolumndatasaved : {enabled: boolean, width: number, align: string}
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
	{name = "name", label = "spell name", width = 246, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", selected = true, width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "persecond", label = "ps", key = "total", width = 50, align = "left", enabled = false, canSort = true, sortKey = "ps", offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "percent", label = "%", key = "total", width = 50, align = "left", enabled = true, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "casts", label = "casts", key = "casts", width = 40, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "critpercent", label = "crit %", key = "critpercent", width = 40, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "hits", label = "hits", key = "counter", width = 40, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "castavg", label = "cast avg", key = "castavg", width = 50, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "uptime", label = "uptime", key = "uptime", width = 45, align = "left", enabled = false, canSort = true, offset = columnOffset, order = "DESC", dataType = "number"},
	{name = "overheal", label = "overheal", key = "overheal", width = 55, align = "left", enabled = false, canSort = true, order = "DESC", dataType = "number", attribute = DETAILS_ATTRIBUTE_HEAL, offset = columnOffset},
	{name = "absorbed", label = "absorbed", key = "healabsorbed", width = 55, align = "left", enabled = false, canSort = true, order = "DESC", dataType = "number", attribute = DETAILS_ATTRIBUTE_HEAL, offset = columnOffset},
}

local targetContainerColumnData = {
	{name = "icon", width = 22, label = "", align = "left", enabled = true, offset = columnOffset},
	{name = "rank", label = "#", width = 20, align = "left", enabled = true, offset = columnOffset},
	{name = "name", label = "name", width = 200, align = "left", enabled = true, offset = columnOffset},
	{name = "amount", label = "total", key = "total", selected = true, width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset},
	{name = "overheal", label = "overheal", key = "overheal", width = 50, align = "left", enabled = true, canSort = true, sortKey = "total", dataType = "number", order = "DESC", offset = columnOffset, attribute = DETAILS_ATTRIBUTE_HEAL},
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

---get the header settings from details saved variables and the container column data
---@param containerType "spells"|"targets"|"phases"
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
	end

	---@cast settings headercolumndatabase
	return settings, containerColumnData
end

---callback for when the user resizes a column on the header
---@param headerFrame df_headerframe
---@param optionName string
---@param columnName string
---@param value any
local onHeaderColumnOptionChanged = function(headerFrame, optionName, columnName, value)
	---@type "spells"|"targets"|"phases"
	local containerType = headerContainerType[headerFrame]
	---@type headercolumndatabase
	local settings = spellsTab.GetHeaderSettings(containerType)

	settings[columnName][optionName] = value
	spellsTab.UpdateHeadersSettings(containerType)
end

---run when the user clicks the columnHeader
---@param headerFrame df_headerframe
---@param columnHeader df_headercolumnframe
local onColumnHeaderClickCallback = function(headerFrame, columnHeader)
	---@type string
	local containerType = headerContainerType[headerFrame]

	local scrollFrame = spellsTab.GetScrollFrameByContainerType(containerType)
	scrollFrame:Refresh()
end

---copy settings from the ColumnInfo table which doesn't exists in the details profile
---this is called when the profile changes or when the tab is opened with a different actor than before
---@param containerType "spells"|"targets"|"phases"
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
	end
end

---get the header settings from details profile and build a header table using the table which store all headers columns information
---the data for each header is stored on 'spellContainerColumnInfo' and 'targetContainerColumnInfo' variables
---@param containerType "spells"|"targets"|"phases"
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

---some values required by the header sort key is not available in the spellTable, so they need to be calculated
---@param combatObject combat
---@param spellData spelltable|spelltableadv
---@param key string
---@return any
local getValueForHeaderSortKey = function(combatObject, spellData, key)
	if (key == "critpercent") then
		return Details.SpellTableMixin.GetCritPercent(spellData)

	elseif (key == "casts") then
		local spellName = GetSpellInfo(spellData.id)
		local amountOfCasts = combatObject:GetSpellCastAmount(spellsTab.GetActor():Name(), spellName)
		return amountOfCasts

	elseif (key == "castavg") then
		local spellName = GetSpellInfo(spellData.id)
		local amountOfCasts = combatObject:GetSpellCastAmount(spellsTab.GetActor():Name(), spellName)
		return Details.SpellTableMixin.GetCastAverage(spellData, amountOfCasts)

	elseif (key == "uptime") then
		return combatObject:GetSpellUptime(spellsTab.GetActor():Name(), spellData.id)

	elseif (key == "healabsorbed") then
		return spellData.absorbed
	end
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
end

---called when the tab is getting created, run only once
---@param tabButton button
---@param tabFrame breakdownspellstab
function spellsTab.OnCreateTabCallback(tabButton, tabFrame) --~init
	spellBreakdownSettings = Details.breakdown_spell_tab

    --create the scrollbar to show the spells in the breakdown window
    spellsTab.CreateSpellScrollContainer(tabFrame) --finished
    --create the 6 spell blocks in the right side of the breakdown window, these blocks show the spell info like normal hits, critical hits, average, etc
    spellsTab.CreateSpellBlockContainer(tabFrame)
    --create the targets container
    spellsTab.CreateTargetContainer(tabFrame)
	--create phases container
	spellsTab.CreatePhasesContainer(tabFrame)

    --create the report buttons for each container
    --spellsTab.CreateReportButtons(tabFrame)

    spellsTab.TabFrame = tabFrame

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
--Scripts

--create a details bar on the right side of the window
local onEnterSpellBlock = function(spellBlock) --info background is the 6 bars in the right side of the window?
	spellBlock.overlay:Show()
	spellBlock.reportButton:Show()
end

local onLeaveSpellBlock = function(spellBlock)
	spellBlock.overlay:Hide()
	spellBlock.reportButton:Hide()
end

local onEnterInfoReport = function(self)
	Details.FadeHandler.Fader(self:GetParent().overlay, 0)
	Details.FadeHandler.Fader(self, 0)
end

local onLeaveInfoReport = function(self)
	Details.FadeHandler.Fader(self:GetParent().overlay, 1)
	Details.FadeHandler.Fader(self, 1)
end

---run this function when the mouse hover over a breakdownspellbar
---@param spellBar breakdownspellbar
---@param motion boolean|nil
local onEnterSpellBar = function(spellBar, motion) --parei aqui: precisa por nomes nas funções e formatar as linhas das funcções
	--all values from spellBar are cached values
	--check if there's a spellbar selected, if there's one, ignore the mouseover
	if (spellsTab.HasSelectedSpellBar() and motion) then
		return
	end

	spellsTab.currentSpellBar = spellBar

    ---@type instance
    local instance = spellsTab.GetInstance()

	---@type combat
	local combatObject = spellsTab.GetCombat()

	---@type number, number
	local mainAttribute, subAttribute = instance:GetDisplay()

	---@type breakdownspellblockframe
	local spellBlockContainer = spellsTab.GetSpellBlockFrame()
	spellBlockContainer:ClearBlocks()

	---@type number
	local spellId = spellBar.spellId

	---@type number
	local elapsedTime = spellBar.combatTime --this should be actorObject:Tempo()

	---@type string
	local actorName = spellsTab.GetActor():Name()

	---@type spelltable
	local spellTable = spellBar.spellTable

	if (IsShiftKeyDown()) then
		if (type(spellId) == "number") then
			GameCooltip:Preset(2)
			GameCooltip:SetOwner(spellBar)
			GameCooltip:AddLine(Loc ["ABILITY_ID"] .. ": " .. spellBar.spellId)
			GameCooltip:Show()

			local t = combatObject:GetActor(1, actorName).spells._ActorTable[spellId]

			local textToEditor = ""
			for key, value in pairs(t) do
				if (type(value) ~= "function" and type(value) ~= "table") then
					textToEditor = textToEditor .. key .. " = " .. tostring(value) .. "\n"
				end
			end

			breakdownWindow.dumpDataFrame:Show()
			breakdownWindow.dumpDataFrame.luaEditor:SetText(textToEditor)
			--hide the scroll bar
			_G["DetailsBreakdownWindowPlayerScrollBoxDumpTableFrameCodeEditorWindowScrollBar"]:Hide()
		end

	elseif (breakdownWindow.dumpDataFrame:IsShown()) then
		breakdownWindow.dumpDataFrame:Hide()
	end

	if (spellId == 98021) then --spirit link totem
		GameTooltip:SetOwner(spellBar, "ANCHOR_TOPLEFT")
		GameTooltip:AddLine(Loc ["STRING_SPIRIT_LINK_TOTEM_DESC"])
		GameTooltip:Show()
	end

	---@type trinketdata
	local trinketData = Details:GetTrinketData()

	---@type number
	local blockIndex = 1

	--get the first spell block to use as summary
	---@type breakdownspellblock
	local summaryBlock = spellBlockContainer:GetBlock(blockIndex)
	summaryBlock:Show()
	summaryBlock:SetValue(50)
	summaryBlock:SetValue(100)

	if (mainAttribute == DETAILS_ATTRIBUTE_DAMAGE) then --this should run within the damage class ~damage
		local bShowDamageDone = subAttribute == DETAILS_SUBATTRIBUTE_DAMAGEDONE or subAttribute == DETAILS_SUBATTRIBUTE_DPS

		---@type number
		local totalHits = spellTable.counter

		--damage section showing damage done sub section
		blockIndex = blockIndex + 1

		do --update the texts in the summary block
			local blockLine1, blockLine2, blockLine3 = summaryBlock:GetLines()

			local totalCasts = spellBar.amountCasts > 0 and spellBar.amountCasts or "(?)"
			blockLine1.leftText:SetText(Loc ["STRING_CAST"] .. ": " .. totalCasts) --total amount of casts

			if (trinketData[spellId] and combatObject.trinketProcs) then
				local trinketProcData = combatObject.trinketProcs[actorName]
				if (trinketProcData) then
					local trinketProc = trinketProcData[spellId]
					if (trinketProc) then
						blockLine1.leftText:SetText("Procs: " .. trinketProc.total)
					end
				end
			end

			blockLine1.rightText:SetText(Loc ["STRING_HITS"]..": " .. totalHits) --hits and uptime

			blockLine2.leftText:SetText(Loc ["STRING_DAMAGE"]..": " .. Details:Format(spellTable.total)) --total damage
			blockLine2.rightText:SetText(Details:GetSpellSchoolFormatedName(spellTable.spellschool)) --spell school

			blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:Format(spellBar.average)) --average damage
			blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellBar.perSecond)) --dps
		end

		local emporwerSpell = spellTable.e_total
		if (emporwerSpell) then
			local empowerLevelSum = spellTable.e_total --total sum of empower levels
			local empowerAmount = spellTable.e_amt --amount of casts with empower
			local empowerAmountPerLevel = spellTable.e_lvl --{[1] = 4; [2] = 9; [3] = 15}
			local empowerDamagePerLevel = spellTable.e_dmg --{[1] = 54548745, [2] = 74548745}

			---@type breakdownspellblock
			local empowerBlock = spellBlockContainer:GetBlock(blockIndex)
			blockIndex = blockIndex + 1

			local level1AverageDamage = "0"
			local level2AverageDamage = "0"
			local level3AverageDamage = "0"
			local level4AverageDamage = "0"
			local level5AverageDamage = "0"

			if (empowerDamagePerLevel[1]) then
				level1AverageDamage = Details:Format(empowerDamagePerLevel[1] / empowerAmountPerLevel[1])
			end
			if (empowerDamagePerLevel[2]) then
				level2AverageDamage = Details:Format(empowerDamagePerLevel[2] / empowerAmountPerLevel[2])
			end
			if (empowerDamagePerLevel[3]) then
				level3AverageDamage = Details:Format(empowerDamagePerLevel[3] / empowerAmountPerLevel[3])
			end
			if (empowerDamagePerLevel[4]) then
				level4AverageDamage = Details:Format(empowerDamagePerLevel[4] / empowerAmountPerLevel[4])
			end
			if (empowerDamagePerLevel[5]) then
				level5AverageDamage = Details:Format(empowerDamagePerLevel[5] / empowerAmountPerLevel[5])
			end

			empowerBlock:Show()
			empowerBlock:SetValue(100)

			empowerBlock.sparkTexture:SetPoint("left", empowerBlock, "left", empowerBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)
			empowerBlock:SetColor(0.200, 0.576, 0.498, 0.6)

			local blockLine1, blockLine2, blockLine3 = empowerBlock:GetLines()
			blockLine1.leftText:SetText("Spell Empower Average Level: " .. string.format("%.2f", empowerLevelSum / empowerAmount))

			if (level1AverageDamage ~= "0") then
				blockLine2.leftText:SetText("Level 1 Avg: " .. level1AverageDamage .. " (" .. (empowerAmountPerLevel[1] or 0) .. ")")
			end

			if (level2AverageDamage ~= "0") then
				blockLine2.centerText:SetText("Level 2 Avg: " .. level2AverageDamage .. " (" .. (empowerAmountPerLevel[2] or 0) .. ")")
			end

			if (level3AverageDamage ~= "0") then
				blockLine2.rightText:SetText("Level 3 Avg: " .. level3AverageDamage .. " (" .. (empowerAmountPerLevel[3] or 0) .. ")")
			end

			if (level4AverageDamage ~= "0") then
				blockLine3.leftText:SetText("Level 4 Avg: " .. level4AverageDamage .. " (" .. (empowerAmountPerLevel[4] or 0) .. ")")
			end

			if (level5AverageDamage ~= "0") then
				blockLine3.rightText:SetText("Level 5 Avg: " .. level5AverageDamage .. " (" .. (empowerAmountPerLevel[5] or 0) .. ")")
			end
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
			normalHitsBlock.sparkTexture:SetPoint("left", normalHitsBlock, "left", percent / 100 * normalHitsBlock:GetWidth() + Details.breakdown_spell_tab.blockspell_spark_offset, 0)

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

		if (trinketData[spellId]) then
			---@type trinketdata
			local trinketInfo = trinketData[spellId]

			local minTime = trinketInfo.minTime
			local maxTime = trinketInfo.maxTime
			local average = trinketInfo.averageTime

			---@type breakdownspellblock
			local trinketBlock = spellBlockContainer:GetBlock(blockIndex)
			trinketBlock:Show()
			trinketBlock:SetValue(100)
			trinketBlock.sparkTexture:SetPoint("left", trinketBlock, "left", trinketBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)
			blockIndex = blockIndex + 1

			local blockLine1, blockLine2, blockLine3 = trinketBlock:GetLines()
			blockLine1.leftText:SetText("Trinket Info")

			blockLine1.rightText:SetText("PPM: " .. string.format("%.2f", average / 60))
			if (minTime == 9999999) then
				blockLine2.leftText:SetText("Min Time: " .. _G["UNKNOWN"])
			else
				blockLine2.leftText:SetText("Min Time: " .. math.floor(minTime))
			end
			blockLine2.rightText:SetText("Max Time: " .. math.floor(maxTime))
		end

	elseif (mainAttribute == DETAILS_ATTRIBUTE_HEAL) then --this should run within the heal class ~healing
		---@type number
		local totalHits = spellTable.counter

		--healing section showing healing done sub section
		blockIndex = blockIndex + 1

		do --update the texts in the summary block
			local blockLine1, blockLine2, blockLine3 = summaryBlock:GetLines()

			local totalCasts = spellBar.amountCasts > 0 and spellBar.amountCasts or "(?)"
			blockLine1.leftText:SetText(Loc ["STRING_CAST"] .. ": " .. totalCasts) --total amount of casts
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
			--blockIndex = blockIndex + 1 --skip one block
			---@type breakdownspellblock
			local overhealBlock = spellBlockContainer:GetBlock(blockIndex)
			overhealBlock:Show()
			blockIndex = blockIndex + 1

			local blockName
			if (spellTable.is_shield) then
				blockName = Loc ["STRING_SHIELD_OVERHEAL"]
			else
				blockName = Loc ["STRING_OVERHEAL"]
			end

			local percent = overheal / (overheal + spellTable.total) * 100
			overhealBlock:SetValue(percent)
			overhealBlock.sparkTexture:SetPoint("left", overhealBlock, "left", percent / 100 * overhealBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)

			overhealBlock:SetColor(1, 0, 0, 0.4)

			local blockLine1, blockLine2, blockLine3 = overhealBlock:GetLines()
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
local onLeaveSpellBar = function(spellBar)
	spellsTab.currentSpellBar = nil

	--remove effects on entering the bar line
	spellBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	spellBar:SetAlpha(0.9)

	GameTooltip:Hide()
	GameCooltip:Hide()

	--clear spell blocks
	if (not spellsTab.HasSelectedSpellBar()) then
		spellsTab.GetSpellBlockFrame():ClearBlocks()
	end

	if (breakdownWindow.dumpDataFrame:IsShown()) then
		breakdownWindow.dumpDataFrame:Hide()
	end
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
--Spell Blocks

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

	---@param self breakdownspellblock
	SetColor = function(self, ...)
		local r, g, b, a = DF:ParseColors(...)
		self.statusBarTexture:SetColorTexture(r, g, b, a)
	end,
}

---create a spell block into the spellblockcontainer
---@param spellBlockContainer breakdownspellblockframe
---@param index number
---@return breakdownspellblock
function spellsTab.CreateSpellBlock(spellBlockContainer, index) --~breakdownspellblock ~create ~spellblocks
	---@type breakdownspellblock
	local spellBlock = CreateFrame("statusbar", "$parentBlock" .. index, spellBlockContainer, "BackdropTemplate")
	DetailsFramework:Mixin(spellBlock, spellBlockMixin)

	local statusBarTexture = spellBlock:CreateTexture("$parentTexture", "artwork")
	statusBarTexture:SetColorTexture(unpack(CONST_SPELLBLOCK_DEFAULT_COLOR))
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
	---@param self breakdownspellblockframe
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

	---@param self breakdownspellblockframe
	ClearBlocks = function(self)
		for i = 1, #self.SpellBlocks do
			---@type breakdownspellblock
			local spellBlock = self.SpellBlocks[i]
			spellBlock:Hide()

			spellBlock:SetColor(unpack(CONST_SPELLBLOCK_DEFAULT_COLOR))

			--clear the text shown in their lines
			for o = 1, 3 do
				spellBlock.Lines[o].leftText:SetText("")

				--set the color of the top left text in the block, the text is used as header text
				if (o == 1) then
					DF:SetFontColor(spellBlock.Lines[o].leftText, CONST_SPELLBLOCK_HEADERTEXT_COLOR)
					DF:SetFontSize(spellBlock.Lines[o].leftText, CONST_SPELLBLOCK_HEADERTEXT_SIZE)
				end

				spellBlock.Lines[o].centerText:SetText("")
				spellBlock.Lines[o].rightText:SetText("")
			end
		end
	end,

	---get a breakdownspellblock from the container
	---@param self breakdownspellblockframe
	---@param index number
	---@return breakdownspellblock
	GetBlock = function(self, index)
		return self.SpellBlocks[index]
	end,
}

---create the spell blocks which shows the critical hits, normal hits, etc
---@param tabFrame tabframe
---@return breakdownspellblockframe
function spellsTab.CreateSpellBlockContainer(tabFrame) --~create ~createblock ~spellblock ~block ~container
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
	container:SetPoint("topleft", spellsTab.GetSpellScrollContainer(), "topright", 26, 0)
	container:SetFrameLevel(tabFrame:GetFrameLevel() + 10)
	spellsTab.BlocksContainerFrame = container

	local settingChangedCallbackFunction = function(frameContainer, settingName, settingValue)
		if (frameContainer:IsShown()) then
			if (settingName == "UpdateSize") then
				--get the tabFrame width and height
				local width, height = tabFrame:GetSize()
				--get with of the container holding the spellscrollframe
				local containerWidth = spellsTab.GetSpellScrollContainer():GetWidth()
				--calculate the widh of the spellblockcontainer by subtracting the width of the spellscrollframe container from the tabFrame width
				local spellBlockContainerWidth = width - containerWidth - 38
				--set the width of the spellblockcontainer
				container:SetWidth(spellBlockContainerWidth)

			elseif (settingName == "height") then
				---@type number
				local currentHeight = spellsTab.GetSpellScrollFrame():GetHeight()
				Details.breakdown_spell_tab.blockcontainer_height = settingValue
				spellsTab.GetSpellScrollFrame():SetNumFramesShown(math.floor(currentHeight / CONST_SPELLSCROLL_LINEHEIGHT) - 1)

			elseif (settingName == "width") then
				Details.breakdown_spell_tab.blockcontainer_width = settingValue

			elseif (settingName == "is_locked") then
				Details.breakdown_spell_tab.blockcontainer_islocked = settingValue
			end

			--update the spell blocks
			spellsTab.GetSpellBlockFrame():UpdateBlocks()

			if (spellsTab.GetSelectedSpellBar()) then
				onEnterSpellBar(spellsTab.GetSelectedSpellBar())
			end
		end
	end
	container:SetSettingChangedCallback(settingChangedCallbackFunction)

	--create the container which will hold the spell blocks
	---@type breakdownspellblockframe
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

function spellsTab.UpdateShownSpellBlock()
	if (spellsTab.currentSpellBar) then
		onEnterSpellBar(spellsTab.currentSpellBar)

	elseif (spellsTab.GetSelectedSpellBar()) then
		onEnterSpellBar(spellsTab.GetSelectedSpellBar())
	end

end

---get a spell bar from the scroll box, if it doesn't exist, return nil
---@param scrollFrame table
---@param lineIndex number
---@return breakdowntargetbar
local getTargetBar = function(scrollFrame, lineIndex)
	---@type breakdowntargetbar
	local targetBar = scrollFrame:GetLine(lineIndex)

	--reset header alignment
	targetBar:ResetFramesToHeaderAlignment()

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

		elseif (header.name == "overheal") then
			text:SetText(Details:Format(bkTargetData.overheal or 0))
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
	phaseBar:SetPoint("topleft", self, "topleft", 0, y)
	phaseBar:SetPoint("topright", self, "topright", 0, y)

	phaseBar:EnableMouse(true)

	phaseBar:SetAlpha(0.9)
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

---get a spell bar from the scroll box, if it doesn't exist, return nil
---@param scrollFrame table
---@param lineIndex number
---@return breakdownphasebar
local getPhaseBar = function(scrollFrame, lineIndex)
	---@type breakdownphasebar
	local phaseBar = scrollFrame:GetLine(lineIndex)

	--reset header alignment
	phaseBar:ResetFramesToHeaderAlignment()

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
local refreshPhaseFunc = function(scrollFrame, scrollData, offset, totalLines) --~refreshspells ~refreshfunc ~refresh ~refreshp ~updatephasebar
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
---@return breakdowntargetscrollframe
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

	---@type breakdowntargetscrollframe not sure is this is correct
	local phaseScrollFrame = DF:CreateScrollBox(container, "$parentPhaseScroll", refreshPhaseFunc, {}, width, height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(phaseScrollFrame)
	phaseScrollFrame:SetBackdrop({})
	phaseScrollFrame:SetAllPoints()

	container:RegisterChildForDrag(phaseScrollFrame)

	phaseScrollFrame.DontHideChildrenOnPreRefresh = false
	tabFrame.PhaseScrollFrame = phaseScrollFrame
	spellsTab.PhaseScrollFrame = phaseScrollFrame

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

	   --local bossInfo = combatObject:GetBossInfo()
	   local phasesInfo = combatObject:GetPhases()

	   if (phasesInfo) then --bossInfo and
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
				   table.sort(allPlayers, function(a, b) return a[2] > b[2] end)

				   local myRank = 0
				   for i = 1, #allPlayers do
					   if (allPlayers[i][1] == actorName) then
						   myRank = i
						   break
					   end
				   end

				   tinsert(playerPhases, {phaseName, playersTable[actorName] or 0, myRank, (playersTable [actorName] or 0) / totalDamage * 100})
			   end
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
	}

	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, phaseContainerColumnData, headerOptions)
	phaseScrollFrame.Header = header
	phaseScrollFrame.Header:SetPoint("topleft", phaseScrollFrame, "topleft", 0, 1)
	phaseScrollFrame.Header:SetColumnSettingChangedCallback(onHeaderColumnOptionChanged)

	--cache the type of this container
	headerContainerType[phaseScrollFrame.Header] = "phases"

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		phaseScrollFrame:CreateLine(spellsTab.CreatePhaseBar)
	end

	tabFrame.phases = tabFrame:CreateFontString(nil, "overlay", "QuestFont_Large")
	tabFrame.phases:SetPoint("bottomleft", container, "topleft", 2, 2)
	tabFrame.phases:SetText("Phases:") --localize-me

	return phaseScrollFrame
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
	local targetScrollFrame = DF:CreateScrollBox(container, "$parentSpellScroll", refreshTargetsFunc, {}, width, height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(targetScrollFrame)
	targetScrollFrame:SetBackdrop({})
	targetScrollFrame:SetAllPoints()

	container:RegisterChildForDrag(targetScrollFrame)

	targetScrollFrame.DontHideChildrenOnPreRefresh = false
	tabFrame.TargetScrollFrame = targetScrollFrame
	spellsTab.TargetScrollFrame = targetScrollFrame

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
	}

	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, targetContainerColumnData, headerOptions)
	targetScrollFrame.Header = header
	targetScrollFrame.Header:SetPoint("topleft", targetScrollFrame, "topleft", 0, 1)
	targetScrollFrame.Header:SetColumnSettingChangedCallback(onHeaderColumnOptionChanged)

	--cache the type of this container
	headerContainerType[targetScrollFrame.Header] = "targets"

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		targetScrollFrame:CreateLine(spellsTab.CreateTargetBar)
	end

	tabFrame.targets = tabFrame:CreateFontString(nil, "overlay", "QuestFont_Large")
	tabFrame.targets:SetPoint("bottomleft", container, "topleft", 2, 2)
	tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. ":")

	return targetScrollFrame
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

	--call the refresh function of the window
	---@type instance
	local instanceObject = spellsTab.GetInstance()
	instanceObject:RefreshWindow(true)
end

local formatPetName = function(petName, spellName, ownerName)
	--petName is raw (with the owner name)
	local petNameWithoutOwner = petName:gsub((" <.*"), "")

	local texture = [[Interface\AddOns\Details\images\classes_small]]

	local bUseAlphaIcons = true
	local specIcon = false
	local iconSize = 14

	if (petName:len() == 0) then
		return Details:AddClassOrSpecIcon(spellName, "PET", specIcon, iconSize, bUseAlphaIcons)
	end

	petNameWithoutOwner = Details:AddClassOrSpecIcon(petNameWithoutOwner, "PET", specIcon, iconSize, bUseAlphaIcons)

	return spellName .. " |cFFCCBBBB" .. petNameWithoutOwner .. "|r"
end

---update a line using the data passed
---@param spellBar breakdownspellbar
---@param index number spell position (from best to wrost)
---@param actorName string
---@param combatObject combat
---@param scrollFrame table
---@param headerTable table
---@param bkSpellData spelltableadv
---@param spellTableIndex number
---@param totalValue number
---@param topValue number
---@param bIsMainLine boolean if true this is the line which has all the values of the spell merged
---@param sortKey string
---@param spellTablesAmount number
local updateSpellBar = function(spellBar, index, actorName, combatObject, scrollFrame, headerTable, bkSpellData, spellTableIndex, totalValue, topValue, bIsMainLine, sortKey, spellTablesAmount)
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
			petName = bkSpellData.nestedData[spellTableIndex].petName
		else
			spellTable = bkSpellData.nestedData[spellTableIndex].spellTable
			value = spellTable.total
			spellId = spellTable.id
			petName = bkSpellData.nestedData[spellTableIndex].petName
			spellBar.bIsExpandedSpell = true
		end

		spellBar.spellId = spellId

		---@cast spellTable spelltable
		spellBar.spellTable = spellTable

		---@type string, number, string
		local spellName, _, spellIcon = Details.GetSpellInfo(spellId)

		---@type number
		local amtCasts = combatObject:GetSpellCastAmount(actorName, spellName)
		spellBar.amountCasts = amtCasts

		---@type number
		local uptime = combatObject:GetSpellUptime(actorName, spellId)

		---@type number
		local combatTime = combatObject:GetCombatTime()

		--statusbar size by percent
		if (topValue > 0) then
			local barValue = spellTable[sortKey] or getValueForHeaderSortKey(combatObject, spellTable, sortKey)
			spellBar.statusBar:SetValue(barValue / topValue * 100)
		else
			spellBar.statusBar:SetValue(0)
		end

		if (petName ~= "") then
			--if is a pet spell and has more pets nested
			if (spellTablesAmount > 1 and bIsMainLine) then
				spellName = formatPetName("", spellName, "")
			elseif (bIsMainLine) then
				spellName = formatPetName(petName, spellName, actorName)
			else
				spellName = formatPetName(petName, "", "")
			end
		end

		spellBar.spellId = spellId
		spellBar.spellIconFrame.spellId = spellId

		spellBar.statusBar.backgroundTexture:SetAlpha(Details.breakdown_spell_tab.spellbar_background_alpha)

		--statusbar color by school
		local r, g, b = Details:GetSpellSchoolColor(spellTable.spellschool or 1)
		spellBar.statusBar:SetStatusBarColor(r, g, b, 0.963)

		spellBar.average = value / spellTable.counter
		spellBar.combatTime = combatTime

		---@type fontstring
		local text = spellBar.InLineTexts[textIndex]
		local header = headerTable[headerIndex]

		if (header.name == "icon") then --ok
			spellBar.spellIcon:Show()
			spellBar.spellIcon:SetTexture(spellIcon)
			spellBar.spellIcon:SetAlpha(0.92)
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
				if (bIsSpellExpaded) then
					spellBar.expandButton.texture:SetTexture([[Interface\AddOns\Details\images\arrow_face_down]])
					spellBar.expandButton.texture:SetTexCoord(0, 1, 1, 0)
				else
					spellBar.expandButton.texture:SetTexture([[Interface\AddOns\Details\images\arrow_face_down]])
					spellBar.expandButton.texture:SetTexCoord(0, 1, 0, 1)
				end

				spellBar.expandButton.texture:SetAlpha(0.7)
				spellBar.expandButton.texture:SetSize(16, 16)
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
local refreshSpellsFunc = function(scrollFrame, scrollData, offset, totalLines) --~refreshspells ~refreshfunc ~refresh ~refreshs
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

	local keyToSort = scrollFrame.SortKey
	local orderToSort = scrollFrame.SortKey
	local headerTable = spellsTab.spellsHeaderData

	--todo: when swapping sort orders, close already expanded spells

	local lineIndex = 1
	for i = 1, totalLines do
		local index = i + offset

		---@type spelltableadv
		local bkSpellData = scrollData[index]

		if (bkSpellData) then
			---@type number
			local spellTablesAmount = #bkSpellData.nestedData

			---called mainSpellBar because it is the line that shows the sum of all spells merged (if any)
			---@type breakdownspellbar
			local mainSpellBar = getSpellBar(scrollFrame, lineIndex)
			do
				--main line of the spell, where the sum of all spells merged is shown
				if (mainSpellBar) then
					lineIndex = lineIndex + 1
					local bIsMainLine = true
					updateSpellBar(mainSpellBar, index, actorName, combatObject, scrollFrame, headerTable, bkSpellData, 1, totalValue, topValue, bIsMainLine, keyToSort, spellTablesAmount)
				end
			end

			--then it adds the lines for each spell merged, but it cannot use the bkSpellData, it needs the spellTable, it's kinda using bkSpellData, need to debug
			if (bkSpellData.bIsExpanded and spellTablesAmount > 1) then
				--filling necessary information to sort the data by the selected header column
				for spellTableIndex = 1, spellTablesAmount do
					---@type bknesteddata
					local nestedBkSpellData = bkSpellData.nestedData[spellTableIndex]
					---@type spelltable
					local spellTable = nestedBkSpellData.spellTable
					nestedBkSpellData.value = spellTable[keyToSort] or getValueForHeaderSortKey(combatObject, spellTable, keyToSort)
				end

				--sort the nested data
				if (orderToSort == "DESC") then
					table.sort(bkSpellData.nestedData,
					function(t1, t2)
						return t1.value < t2.value
					end)
				else
					table.sort(bkSpellData.nestedData,
					function(t1, t2)
						return t1.value > t2.value
					end)
				end

				for spellTableIndex = 1, spellTablesAmount do
					---@type breakdownspellbar
					local spellBar = getSpellBar(scrollFrame, lineIndex)
					if (spellBar) then
						---@type bknesteddata
						local nestedBkSpellData = bkSpellData.nestedData[spellTableIndex]

						lineIndex = lineIndex + 1
						---@type string
						local petName = nestedBkSpellData.petName
						---@type string
						local nameToUse = petName ~= "" and petName or actorName
						local bIsMainLine = false

						bkSpellData[keyToSort] = nestedBkSpellData.value

						updateSpellBar(spellBar, index, nameToUse, combatObject, scrollFrame, headerTable, bkSpellData, spellTableIndex, totalValue, topValue, bIsMainLine, keyToSort, spellTablesAmount)
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
function spellsTab.CreateSpellScrollContainer(tabFrame) --~scroll ~create ~spell ~container
	---@type width
	local width = Details.breakdown_spell_tab.spellcontainer_width
	---@type height
	local height = Details.breakdown_spell_tab.spellcontainer_height

	local options = {
		width = Details.breakdown_spell_tab.spellcontainer_width,
		height = Details.breakdown_spell_tab.spellcontainer_height,
		is_locked = Details.breakdown_spell_tab.spellcontainer_islocked,
		can_move = false,
		can_move_children = false,
		use_bottom_resizer = true,
		use_right_resizer = false,
	}

	---create a container for the scrollframe
	---@type df_framecontainer
	local container = DF:CreateFrameContainer(tabFrame, options, tabFrame:GetName() .. "SpellScrollContainer")
	container:SetPoint("topleft", tabFrame, "topleft", 5, -5)
	container:SetFrameLevel(tabFrame:GetFrameLevel() + 10)
	spellsTab.SpellContainerFrame = container

	--when a setting is changed in the container, it will call this function, it is registered below with SetSettingChangedCallback()
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

			spellsTab.GetSpellBlockContainer():SendSettingChangedCallback("UpdateSize", -1)
		end
	end
	container:SetSettingChangedCallback(settingChangedCallbackFunction)

	--amount of lines which will be created for the scrollframe
	local defaultAmountOfLines = 50

    --replace this with a framework scrollframe
	---@type breakdownspellscrollframe
	local scrollFrame = DF:CreateScrollBox(container, "$parentSpellScroll", refreshSpellsFunc, {}, width, height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
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

	---create the header frame, the header frame is the frame which shows the columns names to describe the data shown in the scrollframe
	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, headerTable, headerOptions)
	scrollFrame.Header = header
	scrollFrame.Header:SetPoint("topleft", scrollFrame, "topleft", 0, 1)
	scrollFrame.Header:SetColumnSettingChangedCallback(onHeaderColumnOptionChanged)

	--cache the containerType which this header is used for
	headerContainerType[scrollFrame.Header] = "spells"

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		scrollFrame:CreateLine(spellsTab.CreateSpellBar)
	end

	---set the data and refresh the scrollframe
	---@param self breakdownspellscrollframe
	---@param data breakdownspelldatalist
	function scrollFrame:RefreshMe(data) --~refreshme (spells) ~refreshmes
		--get which column is currently selected and the sort order
		local columnIndex, order, key = scrollFrame.Header:GetSelectedColumn()
		scrollFrame.SortKey = key
		scrollFrame.SortOrder = order

		---@type string
		local keyToSort = key

		---@type combat
		local combatObject = spellsTab.GetCombat()
		---@type number, number
		local mainAttribute, subAttribute = spellsTab.GetInstance():GetDisplay()

		--filling necessary information to sort the data by the selected header column
		for i = 1, #data do
			---@type spelltableadv
			local bkSpellData = data[i]
			if (not bkSpellData[keyToSort]) then
				local value = getValueForHeaderSortKey(combatObject, bkSpellData, keyToSort)
				bkSpellData[keyToSort] = value
			end
		end

		if (order == "DESC") then
			table.sort(data,
			---@param t1 spelltableadv
			---@param t2 spelltableadv
			function(t1, t2)
				return t1[keyToSort] > t2[keyToSort]
			end)
			self.topValue = data[1] and data[1][keyToSort]
		else
			table.sort(data,
			---@param t1 spelltableadv
			---@param t2 spelltableadv
			function(t1, t2)
				return t1[keyToSort] < t2[keyToSort]
			end)
			self.topValue = data[#data] and data[#data][keyToSort]
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
		GameCooltip:AddIcon(CONST_TARGET_TEXTURE, 1, 1, 14, 14)
		Details:AddTooltipBackgroundStatusbar(false, value / topValue * 100)
	end

	cooltip:SetOwner(targetFrame)
	cooltip:Show()
end

local onLeaveSpellTarget = function(self)
	GameTooltip:Hide()
	GameCooltip:Hide()
	self:GetParent():GetParent():GetScript("OnLeave")(self:GetParent():GetParent())
	self.texture:SetAlpha(.7)
	self:SetAlpha(.7)
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
	targetBar:SetPoint("topleft", self, "topleft", 0, y)
	targetBar:SetPoint("topright", self, "topright", 0, y)

	targetBar:EnableMouse(true)

	targetBar:SetAlpha(0.9)
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
	spellBar:SetScript("OnEnter", onEnterSpellBar)
	spellBar:SetScript("OnLeave", onLeaveSpellBar)
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
	targetTexture:SetTexture(CONST_TARGET_TEXTURE)
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

		---@type number, number
		local mainAttribute, subAttribute = instance:GetDisplay()
		spellsTab.mainAttribute = mainAttribute
		spellsTab.subAttribute = subAttribute

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
