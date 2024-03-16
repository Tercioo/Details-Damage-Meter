
local addonName, Details222 = ...
local breakdownWindow = Details.BreakdownWindow
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
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

local spellsTab = DetailsSpellBreakdownTab

local CONST_BAR_HEIGHT = 20
local CONST_SPELLSCROLL_LINEHEIGHT = 20
local CONST_TARGET_TEXTURE = [[Interface\MINIMAP\TRACKING\Target]]
local CONST_SPELLBLOCK_DEFAULT_COLOR = {.4, .4, .4, 1}
local CONST_SPELLBLOCK_HEADERTEXT_COLOR = {.9, .8, 0, 1}
local CONST_SPELLBLOCK_HEADERTEXT_SIZE = 11

local spellBlockContainerSettings = {
	amount = 6, --amount of block the container have
	lineAmount = 3, --amount of line each block have
}

local headerContainerType = spellsTab.headerContainerType

local formatPetName = function(petName, spellName, ownerName)
	--remove the owner name from the pet name
	local petNameWithoutOwner = petName:gsub((" <.*"), "")

	local texture = [[Interface\AddOns\Details\images\classes_small]]

	local bUseAlphaIcons = true
	local specIcon = nil
	local iconSize = 14

	if (petName:len() == 0) then
		return Details:AddClassOrSpecIcon(spellName, "PET", specIcon, iconSize, bUseAlphaIcons)
	end

	petNameWithoutOwner = Details:AddClassOrSpecIcon(petNameWithoutOwner, "PET", specIcon, iconSize, bUseAlphaIcons)

	return spellName .. " |cFFCCBBBB" .. petNameWithoutOwner .. "|r"
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

---run when the user clicks the columnHeader
---@param headerFrame df_headerframe
---@param columnHeader df_headercolumnframe
local onColumnHeaderClickCallback = function(headerFrame, columnHeader)
	---@type string
	local containerType = headerContainerType[headerFrame]

	local scrollFrame = spellsTab.GetScrollFrameByContainerType(containerType)
	scrollFrame:Refresh()

	local instance = spellsTab.GetInstance()
	instance:RefreshWindow(true)
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
	local actorName = spellsTab.GetActor():Name() --attempt to index a nil value x2

	---@type spelltable
	local spellTable = spellBar.spellTable

	if (IsShiftKeyDown()) then
		if (type(spellId) == "number") then
			GameCooltip:Preset(2)
			GameCooltip:SetOwner(spellBar)

			--if this is an actor header (e.g. a pet bar showing its nested spells)
			if (spellBar.bkSpellData.bIsActorHeader) then
				local petActor = combatObject:GetContainer(mainAttribute):GetActor(spellBar.bkSpellData.actorName)
				local textToEditor = ""
				for key, value in pairs(petActor) do
					if (type(value) ~= "function" and type(value) ~= "table") then
						textToEditor = textToEditor .. key .. " = " .. tostring(value) .. "\n"
					end

					breakdownWindow.dumpDataFrame:Show()
					breakdownWindow.dumpDataFrame.luaEditor:SetText(textToEditor)
					--hide the scroll bar
					_G["DetailsBreakdownWindowPlayerScrollBoxDumpTableFrameCodeEditorWindowScrollBar"]:Hide()
				end

				GameCooltip:AddLine("npc id: " .. petActor.aID)
				GameCooltip:Show()
				return
			end

			---@type actor
			local thisActor = spellsTab.GetActor()

			---@type spelltable
			local thisSpellTable = thisActor:GetSpell(spellId)

			if (not thisSpellTable) then
				local petName = spellBar.bkSpellData.actorName
				local actorContainer = combatObject:GetContainer(mainAttribute)
				local petObject = actorContainer:GetActor(petName)
				if (petObject) then
					thisSpellTable = petObject:GetSpell(spellId)
				end
			end

			GameCooltip:AddLine("spell id: " .. thisSpellTable.id)
			GameCooltip:Show() --add the icon for the bar bar with nested spells (place the icon of the npc or pet)

			local textToEditor = ""
			for key, value in pairs(thisSpellTable) do
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

	if (mainAttribute == DETAILS_ATTRIBUTE_DAMAGE) then
		--bounce to damage class to handle the spell details
		if (subAttribute == 1 or subAttribute == 2 or subAttribute == 6) then
			Details.atributo_damage:BuildSpellDetails(spellBar, spellBlockContainer, blockIndex, summaryBlock, spellId, elapsedTime, actorName, spellTable, trinketData, combatObject)
		end

		--need to know how many blocks the damage class used
		local blocksInUse = spellBlockContainer:GetBlocksInUse()
		local maxBlocks = spellBlockContainer:GetBlocksAmount()

		for i = blocksInUse + 1, math.min(maxBlocks, 4) do --in the current state of the breakdown, showing 5 will overlap with the phase container
			spellBlockContainer:ShowEmptyBlock(i)
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
			critHitsBlock.sparkTexture:SetPoint("left", critHitsBlock, "left", percent / 100 * critHitsBlock:GetWidth() + Details.breakdown_spell_tab.blockspell_spark_offset, 0)

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
			overhealBlock.sparkTexture:SetPoint("left", overhealBlock, "left", percent / 100 * overhealBlock:GetWidth() + Details.breakdown_spell_tab.blockspell_spark_offset, 0)

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
	detailsFramework:Mixin(spellBlock, spellBlockMixin)

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
	spellsTab.ApplyStandardBackdrop(spellBlock)

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
	spellBlock.reportButton = Details.gump:NewDetailsButton(spellBlock, nil, nil, Details.Reportar, Details.BreakdownWindowFrame, 10 + index, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport1")
	Details.FadeHandler.Fader(spellBlock.reportButton, 1) --hide
	spellBlock.reportButton:SetScript("OnEnter", onEnterInfoReport)
	spellBlock.reportButton:SetScript("OnLeave", onLeaveInfoReport)

	--spark texture
	spellBlock.sparkTexture = spellBlock:CreateTexture("$parentOverlaySparkTexture", "overlay")
	spellBlock.sparkTexture:SetTexture("Interface\\AddOns\\Details\\images\\bar_detalhes2_end")
	spellBlock.sparkTexture:SetBlendMode("ADD")

    local gradientDown = detailsFramework:CreateTexture(spellBlock, {gradient = "vertical", fromColor = {0, 0, 0, 0.1}, toColor = "transparent"}, 1, spellBlock:GetHeight(), "background", {0, 1, 0, 1})
    gradientDown:SetPoint("bottoms")
	spellBlock.gradientTexture = gradientDown
	spellBlock.gradientTexture:Hide()

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

			spellBlock.sparkTexture:SetSize(Details.breakdown_spell_tab.blockspell_spark_width, blockHeight)
			spellBlock.sparkTexture:SetShown(Details.breakdown_spell_tab.blockspell_spark_show)
			spellBlock.sparkTexture:SetVertexColor(unpack(Details.breakdown_spell_tab.blockspell_spark_color))
			spellBlock.reportButton:SetPoint("bottomright", spellBlock.overlay, "bottomright", -2, 2)
			spellBlock.gradientTexture:SetHeight(blockHeight)

			spellBlock:SetBackdropBorderColor(unpack(borderColor)) --border color
			spellBlock.statusBarTexture:SetVertexColor(unpack(Details.breakdown_spell_tab.blockspell_color)) --bar color

			local lineHeight = blockHeight * 0.2687

			--update the lines
			local previousLine
			for o = 1, spellBlockContainerSettings.lineAmount do
				---@type breakdownspellblockline
				local line = spellBlock.Lines[o]
				line:SetSize(width - 2, lineHeight)
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
		for i = 1, self:GetBlocksAmount() do
			---@type breakdownspellblock
			local spellBlock = self.SpellBlocks[i]
			spellBlock:Hide()

			spellBlock:SetColor(unpack(CONST_SPELLBLOCK_DEFAULT_COLOR))

			--set the status bar value to zero
			spellBlock:SetValue(0)
			spellBlock.statusBarTexture:Show()
			spellBlock.sparkTexture:Show()

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

		for i = 1, math.min(self:GetBlocksAmount(), 4) do
			self:ShowEmptyBlock(i)
		end

		self.blocksInUse = 0
	end,

	---show the empty block in the container, this is done to preview where the rectangle will be
	---@param self breakdownspellblockframe
	---@param index number
	ShowEmptyBlock = function(self, index)
		local spellBlock = self.SpellBlocks[index]
		spellBlock:Show()
		spellBlock:SetValue(0)
		spellBlock.statusBarTexture:Hide()
		spellBlock.sparkTexture:Hide()
	end,

	---get a breakdownspellblock from the container
	---@param self breakdownspellblockframe
	---@param index number
	---@return breakdownspellblock
	GetBlock = function(self, index)
		self.blocksInUse = self.blocksInUse + 1
		local spellBlock = self.SpellBlocks[index]
		spellBlock.statusBarTexture:Show()
		spellBlock.sparkTexture:Show()
		return self.SpellBlocks[index]
	end,

	---get the amount of blocks in use
	---@param self breakdownspellblockframe
	---@return number
	GetBlocksInUse = function(self)
		return self.blocksInUse
	end,

	---get the total blocks created
	---@param self breakdownspellblockframe
	---@return number
	GetBlocksAmount = function(self)
		return #self.SpellBlocks
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
				local containerWidth

				--get with of the container holding the spellscrollframe
				if (spellsTab.GetSpellScrollContainer():IsShown()) then
					containerWidth = spellsTab.GetSpellScrollContainer():GetWidth()

				elseif (spellsTab.GetGenericScrollContainer():IsShown()) then
					containerWidth = spellsTab.GetGenericScrollContainer():GetWidth()
				end

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
	detailsFramework:Mixin(spellBlockFrame, spellBlockContainerMixin)

	tabFrame.SpellBlockFrame = spellBlockFrame
	spellsTab.SpellBlockFrame = spellBlockFrame

	container:RegisterChildForDrag(spellBlockFrame)

	spellBlockFrame.SpellBlocks = {}
	spellBlockFrame.blocksInUse = 0

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
	Details222.BreakdownWindow.SetSpellAsExpanded(expandButton.petName or expandButton.spellId, not bIsSpellExpaded)

	--call the refresh function of the window
	---@type instance
	local instanceObject = spellsTab.GetInstance()
	instanceObject:RefreshWindow(true)
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

		spellBar.bkSpellData = bkSpellData

		local petName = ""
		---@type boolean @if true, this is the main line of an actor which has its spells nested in the bkSpellData.nestedData
		local bIsActorHeader = bkSpellData.bIsActorHeader

		if (bIsMainLine and bIsActorHeader) then
			spellTable = bkSpellData
			value = bkSpellData.total
			spellId = 0
			petName = actorName

		elseif (bIsMainLine) then
			spellTable = bkSpellData
			value = bkSpellData.total
			spellId = bkSpellData.id
			petName = bkSpellData.nestedData[spellTableIndex].actorName

		else
			spellTable = bkSpellData.nestedData[spellTableIndex].spellTable
			value = spellTable.total
			spellId = spellTable.id

			--if isn't a spell from a nested actor, then it can use the pet name in the spell name
			if (not bkSpellData.nestedData[spellTableIndex].bIsActorHeader) then
				petName = bkSpellData.nestedData[spellTableIndex].actorName
			end

			spellBar.bIsExpandedSpell = true
		end

		spellBar.spellId = spellId

		---@cast spellTable spelltable
		spellBar.spellTable = spellTable

		---@type string, number, any, string?, boolean?
		local spellName, _, spellIcon, defaultName, bBreakdownCanStack = Details.GetCustomSpellInfo(spellId)
		if (not spellName) then
			spellName = actorName
			---@type npcid
			local npcId = tonumber(bkSpellData.npcId) or 0
			spellIcon = Details.NpcIdToIcon[npcId] or bkSpellData.actorIcon or ""
		end

		--if this damage was made by an item, then get the default spellName of the damaging spell
		--the name from GetSpellInfo are probably modified by a custom spell name
		--amount of casts does not use custom names but always the damaging spell name from combatlog
		local defaultSpellName = Details.GetItemSpellInfo(spellId)
		---@type number
		local amtCasts = combatObject:GetSpellCastAmount(actorName, defaultSpellName or spellName)
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
			--if is a pet spell and has more pets nested || nop, now is a pet with its spells nested
			if (spellTablesAmount > 1 and bIsMainLine) then
				spellName = formatPetName("", spellName, "") --causing error as spellName is nil
			elseif (bIsMainLine) then
				spellName = formatPetName(petName, spellName, actorName)
			else
				spellName = formatPetName(petName, "", "")
			end
		end

		spellBar.spellId = spellId
		spellBar.spellIconFrame.spellId = spellId
		--spellBar.statusBar.backgroundTexture:SetAlpha(Details.breakdown_spell_tab.spellbar_background_alpha)

		--statusbar color by school
		local r, g, b = Details:GetSpellSchoolColor(spellTable.spellschool or 1)
		spellBar.statusBar:SetStatusBarColor(r, g, b, 0.963)

		if (spellTable.counter > 0) then
			spellBar.average = value / spellTable.counter
		else
			spellBar.average = 0.0001
		end

		spellBar.combatTime = combatTime

		---@type fontstring
		local text = spellBar.InLineTexts[textIndex]
		local header = headerTable[headerIndex]

		if (header.name == "icon") then
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

		elseif (header.name == "rank") then
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
				local bIsSpellExpaded = Details222.BreakdownWindow.IsSpellExpanded(bIsActorHeader and actorName or spellId)
				spellBar.expandButton.spellId = bIsActorHeader and actorName or spellId
				spellBar.expandButton.bIsSpellExpaded = bIsSpellExpaded
				spellBar.expandButton:SetScript("OnClick", onClickExpandButton)

				--update the texture taking the state of the expanded value
				if (bIsSpellExpaded) then
					spellBar.expandButton.texture:SetTexture([[Interface\AddOns\Details\images\arrow_face_down]])
					--spellBar.expandButton.texture:SetTexCoord(0, 1, 0, 1)
					spellBar.expandButton.texture:SetRotation(0)
				else
					spellBar.expandButton.texture:SetTexture([[Interface\AddOns\Details\images\arrow_face_down]])
					--spellBar.expandButton.texture:SetTexCoord(0, 1, 0, 1)
					spellBar.expandButton.texture:SetRotation(math.pi/2)
				end

				spellBar.expandButton.texture:SetAlpha(0.7)
				spellBar.expandButton.texture:SetSize(16, 16)
			end

		elseif (header.name == "name") then
			text:SetText(Details:RemoveOwnerName(spellName))
			spellBar.name = spellName
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "amount") then
			text:SetText(Details:Format(value))
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "persecond") then
			spellBar.perSecond = value / combatTime

			---@type string
			local perSecondFormatted = Details:Format(spellBar.perSecond)
			text:SetText(perSecondFormatted)

			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "percent") then
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

		elseif (header.name == "overheal" and spellTable.overheal) then
			if (spellTable.overheal > 0) then
				local totalHeal = spellTable.overheal + value
				text:SetText(Details:ToK2(spellTable.overheal) .. " (" .. math.floor(spellTable.overheal / totalHeal * 100) .. "%)")
			else
				text:SetText("0%")
			end
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

	Details:Destroy(spellBar.ExpandedChildren)

	--reset header alignment
	spellBar:ResetFramesToHeaderAlignment()

	spellsTab.UpdateBarSettings(spellBar)

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
					local bIsActorHeader = bkSpellData.bIsActorHeader
					local spellTableIndex = 1
					local spellBar = mainSpellBar

					local nameToUse = actorName
					if (bIsActorHeader) then
						nameToUse = bkSpellData.actorName
					end

					--both calls are equal but the traceback will be different in case of an error
					if (bIsActorHeader) then
						updateSpellBar(spellBar, index, nameToUse, combatObject, scrollFrame, headerTable, bkSpellData, spellTableIndex, totalValue, topValue, bIsMainLine, keyToSort, spellTablesAmount)
					else
						--here
						updateSpellBar(spellBar, index, nameToUse, combatObject, scrollFrame, headerTable, bkSpellData, spellTableIndex, totalValue, topValue, bIsMainLine, keyToSort, spellTablesAmount)
					end
				end
			end

			--if the spell is expanded
			--then it adds the lines for each spell merged, but it cannot use the bkSpellData, it needs the spellTable, it's kinda using bkSpellData, need to debug
			if (bkSpellData.bIsExpanded and (spellTablesAmount > 1)) then
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
						local petName = nestedBkSpellData.actorName
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
function spellsTab.CreateSpellScrollContainer(tabFrame) --~scroll ~create ~spell ~container ~createspellcontainer
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

	---@type breakdownspellscrollframe
	local scrollFrame = DF:CreateScrollBox(container, "$parentSpellScroll", refreshSpellsFunc, {}, width, height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(scrollFrame)
	scrollFrame:SetPoint("topleft", container, "topleft", 0, 0) --need to set the points
	scrollFrame:SetPoint("bottomright", container, "bottomright", 0, 0) --need to set the points

	container:RegisterChildForDrag(scrollFrame)

	scrollFrame.DontHideChildrenOnPreRefresh = true
	tabFrame.SpellScrollFrame = scrollFrame
	spellsTab.SpellScrollFrame = scrollFrame

	spellsTab.ApplyStandardBackdrop(container, scrollFrame)

	---@param self breakdownphasescrollframe
	---@return breakdownreporttable
	function scrollFrame:GetReportData()
		local instance = spellsTab.GetInstance()

		---@type breakdownspelldatalist
		local data = self:GetData()

		local formatFunc = Details:GetCurrentToKFunction()
		local actorObject = spellsTab.GetActor()
		local displayId, subDisplayId = instance:GetDisplay()
		local subDisplayName = Details:GetSubAttributeName(displayId, subDisplayId)
		local combatName = instance:GetCombat():GetCombatName()

		---@type breakdownreporttable
		local reportData = {
			title = subDisplayName .. " for " .. detailsFramework:RemoveRealmName(actorObject:Name()) .. " | " .. combatName
		}

		local topValue = data[1] and data[1].total or 0

		for i = 1, #data do
			---@type spelltableadv
			local bkSpellData = data[i]
			local spellId = bkSpellData.id
			local spellName = Details.GetSpellInfo(spellId)

			if (not spellName) then
				--dumpt(bkSpellData)
				if (bkSpellData.npcId) then
					spellName = detailsFramework:CleanUpName(bkSpellData.actorName)
				end
			else
				spellName = detailsFramework:CleanUpName(spellName)
			end

			reportData[#reportData+1] = {
				name = spellName,
				amount = formatFunc(nil, bkSpellData.total),
				percent = string.format("%.1f", bkSpellData.total/topValue*100) .. "%",
			}
		end

		return reportData
	end

	--~header
	local headerOptions = {
		padding = 2,

		header_height = 14,
		reziser_shown = true,
		reziser_width = 2,
		reziser_color = {.5, .5, .5, 0.7},
		reziser_max_width = 246,

		header_click_callback = onColumnHeaderClickCallback,

		header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
		text_color = {1, 1, 1, 0.823},
	}

	local headerTable = {}

	---create the header frame, the header frame is the frame which shows the columns names to describe the data shown in the scrollframe
	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, headerTable, headerOptions)
	scrollFrame.Header = header
	scrollFrame.Header:SetPoint("topleft", scrollFrame, "topleft", 0, 1)
	scrollFrame.Header:SetColumnSettingChangedCallback(spellsTab.OnHeaderColumnOptionChanged)

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


---create a spellbar within the spell scroll
---@param self breakdownspellscrollframe
---@param index number
---@return breakdownspellbar
function spellsTab.CreateSpellBar(self, index) --~spellbar ~spellline ~spell ~create ~createline ~createspell ~createspellbar
	---@type breakdownspellbar
	local spellBar = CreateFrame("button", self:GetName() .. "SpellBarButton" .. index, self)
	spellBar.index = index

	--size and positioning
	spellBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	local y = (index-1) * CONST_SPELLSCROLL_LINEHEIGHT * -1 + (1 * -index) - 15
	spellBar:SetPoint("topleft", self, "topleft", 1, y)
	spellBar:SetPoint("topright", self, "topright", -1, y)

	spellBar:EnableMouse(true)
	spellBar:RegisterForClicks("AnyUp", "AnyDown")
	spellBar:SetAlpha(0.823)
	spellBar:SetFrameStrata("high")
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
	statusBar:SetStatusBarTexture(statusBarTexture)
	statusBar:SetStatusBarColor(1, 1, 1, 1)

	---@type texture background texture
	local backgroundTexture = statusBar:CreateTexture("$parentTextureBackground", "border")
	backgroundTexture:SetAllPoints()
	statusBar.backgroundTexture = backgroundTexture

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
	detailsFramework:SetMask(spellIcon, Details:GetTextureAtlas("iconmask"))
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
