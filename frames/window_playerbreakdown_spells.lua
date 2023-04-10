
local addonName, Details222 = ...
local spellsTab = {}
local breakdownWindow = Details.BreakdownWindow
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local unpack = unpack
local GetTime = GetTime
local GetCursorPosition = GetCursorPosition
local CreateFrame = CreateFrame
local GetSpellLink = GetSpellLink
local _GetSpellInfo = Details.GetSpellInfo
local GameTooltip = GameTooltip
local IsShiftKeyDown = IsShiftKeyDown
local DF = DetailsFramework

--Expose the object to the global namespace
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

local row_backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
local row_backdrop_onleave = {bgFile = "", edgeFile = "", tile = true, tileSize = 16, edgeSize = 32,
		insets = {left = 1, right = 1, top = 0, bottom = 1}}

local CONST_BAR_HEIGHT = 20
local CONST_TARGET_HEIGHT = 18

local CONST_SPELLSCROLL_WIDTH = 435
local CONST_SPELLSCROLL_HEIGHT = 311
local CONST_SPELLSCROLL_AMTLINES = 14
local CONST_SPELLSCROLL_LINEHEIGHT = 20

Details.SpellGroups = {
	[193473] = 15407, --mind flay
}

function spellsTab.GetActor()
	return spellsTab.currentActor
end

function spellsTab.GetCombat()
	return spellsTab.combatObject
end

function spellsTab.GetInstance()
	return spellsTab.instance
end

---return the breakdownspellscrollframe object, there's only one of this in the breakdown window
---@return breakdownspellscrollframe
function spellsTab.GetSpellScrollContainer()
	return spellsTab.TabFrame.SpellScrollFrame
end

---return the breakdownspellblockcontainer object, there's only one of this in the breakdown window
---@return breakdownspellblockcontainer
function spellsTab.GetSpellBlockContainer()
	return spellsTab.TabFrame.SpellBlockContainer
end

---@type {name: string, width: number, label: string, align: string, enabled: boolean, attribute: number|nil}[]
local columnInfo = {
	{name = "icon", width = 22, label = "", align = "center", enabled = true,},
	{name = "target", width = 22, label = "", align = "center", enabled = true},
	{name = "rank", label = "#", width = 16, align = "center", enabled = true},
	{name = "expand", label = "^", width = 16, align = "center", enabled = true},
	{name = "name", label = "spell name", width = 246, align = "left", enabled = true},
	{name = "amount", label = "total", width = 50, align = "left", enabled = true},
	{name = "persecond", label = "ps", width = 50, align = "left", enabled = true},
	{name = "percent", label = "%", width = 50, align = "left", enabled = true},
	{name = "casts", label = "casts", width = 40, align = "left", enabled = true},
	{name = "critpercent", label = "crit %", width = 40, align = "left", enabled = true},
	{name = "hits", label = "hits", width = 40, align = "left", enabled = true},
	{name = "castavg", label = "cast avg", width = 50, align = "left", enabled = true},
	{name = "uptime", label = "uptime", width = 45, align = "left", enabled = true},
	{name = "overheal", label = "overheal", width = 45, align = "left", enabled = true, attribute = DETAILS_ATTRIBUTE_HEAL},
	{name = "absorbed", label = "absorbed", width = 45, align = "left", enabled = true, attribute = DETAILS_ATTRIBUTE_HEAL},
}

function spellsTab.BuildHeaderTable()
	---@type {name: string, width: number, label: string, align: string, enabled: boolean}[]
	local headerTable = {}

    ---@type instance
    local instance = spellsTab.GetInstance()

	---@type number, number
	local mainAttribute, subAttribute = instance:GetDisplay()

	for i = 1, #columnInfo do
		local columnData = columnInfo[i]
		if (columnData.enabled) then
			local bCanAdd = true
			if (columnData.attribute) then
				if (columnData.attribute ~= mainAttribute) then
					bCanAdd = false
				end
			end

			if (bCanAdd) then
				headerTable[#headerTable+1] = {
					text = columnData.label,
					width = columnData.width,
					name = columnData.name,
					--align = column.align,
				}
			end
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

	--it is only selecting the bar is the mouse down elapsed 0.4 seconds or more

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
	spellsTab.GetSpellBlockContainer():ClearBlocks()
end

--called when the tab is getting created
function spellsTab.OnCreateTabCallback(tabButton, tabFrame)
	spellBreakdownSettings = Details.breakdown_spell_tab

    --create the scrollbar to show the spells in the breakdown window
	---@type breakdownspellscrollframe
    local spellScrollContainer = spellsTab.CreateSpellScrollContainer(tabFrame) --finished

    --create the 6 spell blocks in the right side of the breakdown window
    --these blocks show the spell info like normal hits, critical hits, average, etc
	---@type breakdownspellblockcontainer
    local spellBlockContainer = spellsTab.CreateSpellBlockContainer(tabFrame)
	spellsTab.SpellBlockContainer = spellBlockContainer
	spellBlockContainer:SetPoint("topleft", spellScrollContainer, "topright", 26, 0)

    --create the targets container
    spellsTab.CreateTargetContainer(tabFrame)

    --craete special backgrounds (still needed?)
    spellsTab.CreateSpecialBackgrounds(tabFrame)

    --create the report buttons for each container
    spellsTab.CreateReportButtons(tabFrame)

	--these bars table are kinda deprecated now:

    --store the spell bars for the spell container
	tabFrame.barras1 = {}
	--store the target bars for the target container
	tabFrame.barras2 = {}
	--store the special bars shown in the right side of the breakdown window, this is only shown when spellBlocks aren't in use
	tabFrame.barras3 = {}

    spellsTab.TabFrame = tabFrame
end

function spellsTab.TrocaBackgroundInfo(tabFrame) --> spells tab | to be refactored | called fom OpenJanelaInfo function
	tabFrame.bg3_sec_texture:Hide()
	tabFrame.bg2_sec_texture:Hide()
	tabFrame.report_direita:Hide()

	if (breakdownWindow.atributo == 1) then --damage
		if (breakdownWindow.sub_atributo == 1 or breakdownWindow.sub_atributo == 2) then --damage done / dps
			tabFrame.bg1_sec_texture:SetTexture("")
			tabFrame.tipo = 1

			if (breakdownWindow.sub_atributo == 2) then
				tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_DPS"] .. ":")
				tabFrame.target_persecond = true
			else
				tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
			end

		elseif (breakdownWindow.sub_atributo == 3) then --damage taken
			tabFrame.bg1_sec_texture:SetColorTexture(.05, .05, .05, .4)
			tabFrame.bg3_sec_texture:Show()
			tabFrame.bg2_sec_texture:Show()
			tabFrame.tipo = 2

			for i = 1, spellBlockContainerSettings.amount do
				tabFrame["right_background" .. i]:Hide()
			end

			tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
			tabFrame.no_targets:Show()
			tabFrame.no_targets.text:Show()
			tabFrame.report_direita:Show()

		elseif (breakdownWindow.sub_atributo == 4) then --friendly fire
			tabFrame.bg1_sec_texture:SetColorTexture(.05, .05, .05, .4)
			tabFrame.bg3_sec_texture:Show()
			tabFrame.bg2_sec_texture:Show()
			tabFrame.tipo = 3

			for i = 1, spellBlockContainerSettings.amount do
				tabFrame["right_background" .. i]:Hide()
			end

			tabFrame.targets:SetText(Loc ["STRING_SPELLS"] .. ":")
			tabFrame.report_direita:Show()

		elseif (breakdownWindow.sub_atributo == 6) then --enemies
			tabFrame.bg1_sec_texture:SetColorTexture(.05, .05, .05, .4)
			tabFrame.bg3_sec_texture:Show()
			tabFrame.bg2_sec_texture:Show()
			tabFrame.tipo = 3

			for i = 1, spellBlockContainerSettings.amount do
				tabFrame["right_background" .. i]:Hide()
			end

			tabFrame.targets:SetText(Loc ["STRING_DAMAGE_TAKEN_FROM"])
		end

	elseif (breakdownWindow.atributo == 2) then --healing
		if (breakdownWindow.sub_atributo == 1 or breakdownWindow.sub_atributo == 2 or breakdownWindow.sub_atributo == 3) then --damage done / dps
			tabFrame.bg1_sec_texture:SetTexture("")
			tabFrame.tipo = 1

			if (breakdownWindow.sub_atributo == 3) then
				tabFrame.targets:SetText(Loc ["STRING_OVERHEALED"] .. ":")
				tabFrame.target_member = "overheal"
				tabFrame.target_text = Loc ["STRING_OVERHEALED"] .. ":"

			elseif (breakdownWindow.sub_atributo == 2) then
				tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. " " .. Loc ["STRING_ATTRIBUTE_HEAL_HPS"] .. ":")
				tabFrame.target_persecond = true

			else
				tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
			end

		elseif (breakdownWindow.sub_atributo == 4) then --Healing taken
			tabFrame.bg1_sec_texture:SetColorTexture(.05, .05, .05, .4)
			tabFrame.bg3_sec_texture:Show()
			tabFrame.bg2_sec_texture:Show()
			tabFrame.tipo = 2

			for i = 1, spellBlockContainerSettings.amount do
				tabFrame ["right_background" .. i]:Hide()
			end

			tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
			tabFrame.no_targets:Show()
			tabFrame.no_targets.text:Show()
			tabFrame.report_direita:Show()
		end

	elseif (breakdownWindow.atributo == 3) then --energy
		tabFrame.bg1_sec_texture:SetTexture("")
		tabFrame.tipo = 2
		tabFrame.targets:SetText("Vindo de:")

	elseif (breakdownWindow.atributo == 4) then --utility
		tabFrame.bg1_sec_texture:SetTexture("")
		tabFrame.tipo = 2

		tabFrame.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
	end
end

do --hide bars functions - to be refactored
    --hide all the bars of the skills in the window info
    function spellsTab.HidaAllBarrasInfo()
        local allBars = _detalhes.playerDetailWindow.barras1
        for index = 1, #allBars, 1 do
            allBars[index]:Hide()
            allBars[index].textura:SetStatusBarColor(1, 1, 1, 1)
            allBars[index].on_focus = false
        end
    end

    --hide all the bars of the player's targets
    function spellsTab.HidaAllBarrasAlvo()
        local allBars = _detalhes.playerDetailWindow.barras2
        for index = 1, #allBars, 1 do
            allBars[index]:Hide()
        end
    end

    --hide the 5 bars on the right side of the window
    function spellsTab.HidaAllDetalheInfo() --there's a call from the breakdown file yet
        for i = 1, spellBlockContainerSettings.amount do
            spellsTab.HidaDetalheInfo(i)
        end

		--breakdownWindow.barras3 will not exists anymore soon
        --for _, thisBar in ipairs(breakdownWindow.barras3) do
        --    thisBar:Hide()
        --end
        --_detalhes.playerDetailWindow.spell_icone:SetTexture("")
    end

    function spellsTab.ResetBars()
        spellsTab.HidaAllBarrasInfo()
        spellsTab.HidaAllBarrasAlvo()
        spellsTab.HidaAllDetalheInfo()
    end

    function spellsTab.HidaDetalheInfo(index)  --> spells tab  this is getting called from class damage and heal
        local info = _detalhes.playerDetailWindow.grupos_detalhes[index]
        info.nome:SetText("")
        info.nome2:SetText("")
        info.dano:SetText("")
        info.dano_porcento:SetText("")
        info.dano_media:SetText("")
        info.dano_dps:SetText("")
        info.bg:Hide()
    end
end

--bar scripts
local onMouseDownCallback = function(self, button)
    local hostFrame = breakdownWindow

    if (button == "LeftButton") then
        hostFrame:StartMoving()
        hostFrame.isMoving = true

    elseif (button == "RightButton" and not self.isMoving) then
        Details:CloseBreakdownWindow()
    end
end

local onMouseUpCallback = function(self, button)
    local hostFrame = breakdownWindow

    if (hostFrame.isMoving) then
        hostFrame:StopMovingOrSizing()
        hostFrame.isMoving = false
    end
end

function spellsTab.ApplyScripts()
    local hostFrame = breakdownWindow --cannot be breakdown window, it should be the frame of the tab
    hostFrame.SpellScrollFrame.gump:SetScript("OnMouseDown", onMouseDownCallback)
    hostFrame.SpellScrollFrame.gump:SetScript("OnMouseUp", onMouseUpCallback)

    hostFrame.container_detalhes:SetScript("OnMouseDown", onMouseDownCallback)
    hostFrame.container_detalhes:SetScript("OnMouseUp", onMouseUpCallback)

    hostFrame.container_alvos.gump:SetScript("OnMouseDown", onMouseDownCallback)
    hostFrame.container_alvos.gump:SetScript("OnMouseUp", onMouseUpCallback)
end

function spellsTab.CreateReportButtons(tabFrame)
    --spell list report button
	tabFrame.report_esquerda = Details.gump:NewDetailsButton(tabFrame, tabFrame, nil, _detalhes.Reportar, tabFrame, 1, 16, 16, "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport2")
	tabFrame.report_esquerda:SetPoint("bottomleft", tabFrame.SpellScrollFrame, "TOPLEFT",  33, 3)
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
	local spellBlockContainer = spellsTab.GetSpellBlockContainer()
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

	if (mainAttribute == DETAILS_ATTRIBUTE_DAMAGE) then --this should run within the damage class
		local bShowDamageDone = subAttribute == DETAILS_SUBATTRIBUTE_DAMAGEDONE or subAttribute == DETAILS_SUBATTRIBUTE_DPS

		---@type number
		local blockIndex = 1

		---@type number
		local totalHits = spellTable.counter

		--damage section showing damage done sub section
		--get the first spell block to use as summary
		---@type breakdownspellblock
		local summaryBlock = spellBlockContainer:GetBlock(blockIndex)
		summaryBlock:Show()
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
			normalHitsBlock:SetStatusBarColor(1, 1, 1, .5)

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

			local percent = criticalHitsAmt / math.max(totalHits, 0.0001) * 100
			critHitsBlock:SetValue(percent)
			critHitsBlock.sparkTexture:SetPoint("left", critHitsBlock, "left", percent / 100 * critHitsBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)
			critHitsBlock:SetStatusBarColor(1, 1, 1, .5)

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
			blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellTable.c_total / critTempoPercent))
		end

	elseif (mainAttribute == DETAILS_ATTRIBUTE_HEAL) then --this should run within the heal class
		---@type number
		local blockIndex = 1

		---@type number
		local totalHits = spellTable.counter

		--damage section showing damage done sub section
		--get the first spell block to use as summary
		---@type breakdownspellblock
		local summaryBlock = spellBlockContainer:GetBlock(blockIndex)
		summaryBlock:Show()
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
			normalHitsBlock:SetStatusBarColor(1, 1, 1, .5)

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

			local percent = criticalHitsAmt / math.max(totalHits, 0.0001) * 100
			critHitsBlock:SetValue(percent)
			critHitsBlock.sparkTexture:SetPoint("left", critHitsBlock, "left", percent / 100 * critHitsBlock:GetWidth() + spellBreakdownSettings.blockspell_spark_offset, 0)
			critHitsBlock:SetStatusBarColor(1, 1, 1, .5)

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
			blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellTable.c_total / critTempoPercent))
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
	--diminui o tamanho da barra
	spellBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	--volta com o alfa antigo da barra que era de 0.9
	spellBar:SetAlpha(0.9)

	--volto o background ao normal
	spellBar:SetBackdrop(row_backdrop_onleave)
	spellBar:SetBackdropBorderColor(0, 0, 0, 0)
	spellBar:SetBackdropColor(0, 0, 0, 0)

	GameTooltip:Hide()
	GameCooltip:Hide()

	if (spellBar.isMain) then
		--retira o zoom no icone
		spellBar.spellIcon:SetSize(CONST_SPELLSCROLL_LINEHEIGHT, CONST_SPELLSCROLL_LINEHEIGHT)
		spellBar.spellIcon:SetAlpha(1)

		--remover o conte�do que estava sendo mostrado na direita
		if (breakdownWindow.mostrando_mouse_over) then
			breakdownWindow.mostrando = nil
			breakdownWindow.mostrando_mouse_over = false
			breakdownWindow.showing = nil
			breakdownWindow.jogador.detalhes = nil
			spellsTab.HidaAllDetalheInfo()
		end

	elseif (spellBar.isAlvo) then
		spellBar:SetHeight(CONST_TARGET_HEIGHT)

	elseif (spellBar.isDetalhe) then
		spellBar:SetHeight(16)
	end
end

---on mouse down a breakdownspellbar in the breakdown window
---@param spellBar breakdownspellbar
---@param button string
local onMouseDownBreakdownSpellBar = function(spellBar, button)
	local x, y = _G.GetCursorPosition()
	spellBar.cursorPosX = math.floor(x)
	spellBar.cursorPosY = math.floor(y)
	Details222.PlayerBreakdown.OnMouseDown(spellBar, button)
end

---on mouse up a breakdownspellbar in the breakdown window
---@param spellBar breakdownspellbar
---@param button string
local onMouseUpBreakdownSpellBar = function(spellBar, button)
	if (spellBar.onMouseUpTime == GetTime()) then
		return
	end

	spellBar.onMouseUpTime = GetTime()

	---@type number, number
	local x, y = _G.GetCursorPosition()
	x = math.floor(x)
	y = math.floor(y)

	---@type boolean
	local bIsMouseInTheSamePosition = (x == spellBar.cursorPosX) and (y == spellBar.cursorPosY)

	--if the mouse is in the same position, then the user clicked the bar
	--clicking the bar activate the lock mechanism
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

---create a spell block into the spellcontainer
---@param spellBlockContainer breakdownspellblockcontainer
---@param index number
---@return breakdownspellblock
function spellsTab.CreateSpellBlock(spellBlockContainer, index) --~breakdownspellblock ~create ~spellblocks
	---@type breakdownspellblock
	local spellBlock = CreateFrame("statusbar", "$parentBlock" .. index, spellBlockContainer, "BackdropTemplate")
	DetailsFramework:Mixin(spellBlock, spellBlockMixin)
	local t = spellBlock:CreateTexture(nil, "artwork")
	t:SetColorTexture(1, 1, 1, 1)
	spellBlock:SetStatusBarTexture(t) --debug
	--spellBlock:SetStatusBarTexture("Interface\\AddOns\\Details\\images\\bar_background")
	spellBlock:SetStatusBarColor(1, 1, 1, .84)
	spellBlock:SetMinMaxValues(0, 100)
	spellBlock:SetValue(100)
	spellBlock:SetScript("OnEnter", onEnterSpellBlock)
	spellBlock:SetScript("OnLeave", onLeaveSpellBlock)

	--create the lines which will host the texts
	spellBlock.Lines = {}
	for i = 1, spellBlockContainerSettings.lineAmount do
		---@type breakdownspellblockline
		local line = CreateFrame("frame", "$parentLine" .. i, spellBlock)
		--DetailsFramework:ApplyStandardBackdrop(line)
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
	spellBlock.overlay:SetColorTexture(1, 0, 0, 1)
	spellBlock.overlay:SetAllPoints()
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

    local gradientDown = DetailsFramework:CreateTexture(spellBlock, {gradient = "vertical", fromColor = {0, 0, 0, 0.1}, toColor = "transparent"}, 1, 43, "background", {0, 1, 0, 1})
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
		local width, height = spellBreakdownSettings.blockcontainer_width, spellBreakdownSettings.blockcontainer_height
		local blockHeight = spellBreakdownSettings.blockspell_height
		self:SetSize(width, height)

		for i = 1, #self.SpellBlocks do
			---@type breakdownspellblock
			local spellBlock = self.SpellBlocks[i]

			spellBlock:SetSize(width - 2, blockHeight)
			spellBlock:SetPoint("topleft", self, "topleft", 1, (blockHeight * (i - 1) - i) * -1 - (i*2))
			spellBlock.sparkTexture:SetSize(spellBreakdownSettings.blockspell_spark_width, blockHeight)
			spellBlock.sparkTexture:SetShown(spellBreakdownSettings.blockspell_spark_show)
			spellBlock.sparkTexture:SetVertexColor(unpack(spellBreakdownSettings.blockspell_spark_color))
			spellBlock.reportButton:SetPoint("bottomright", spellBlock.overlay, "bottomright", -2, 2)
			spellBlock.gradientTexture:SetHeight(blockHeight)

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
	--create the container which will hold the spell blocks
	---@type breakdownspellblockcontainer
	local spellBlockContainer = CreateFrame("Frame", "$parentSpellBlockContainer", tabFrame, "BackdropTemplate")
	spellBlockContainer:EnableMouse(true)
	spellBlockContainer:SetResizable(false)
	spellBlockContainer:SetMovable(true)
	DetailsFramework:Mixin(spellBlockContainer, spellBlockContainerMixin)
	DetailsFramework:ApplyStandardBackdrop(spellBlockContainer)
	tabFrame.SpellBlockContainer = spellBlockContainer

	spellBlockContainer.SpellBlocks = {}

	for i = 1, spellBlockContainerSettings.amount do
		---@type breakdownspellblock
		local spellBlock = spellsTab.CreateSpellBlock(spellBlockContainer, i)
		table.insert(spellBlockContainer.SpellBlocks, spellBlock)
		--size and point are set on ~UpdateBlocks
	end

	spellBlockContainer:UpdateBlocks()

	return spellBlockContainer
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
---@param bkSpellData breakdownspelldata
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

		--statusbar size by percent, statusbar color by school
		spellBar.statusBar:SetValue(value / maxValue * 100)
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

		elseif (header.name == "casts") then --the tab doesn't have information about the amount of casts
			text:SetText(amtCasts)
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "critpercent") then --the tab does not have this information
			text:SetText(string.format("%.1f", spellTable.c_amt / (spellTable.counter) * 100) .. "%")
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "hits") then
			text:SetText(spellTable.counter)
			spellBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "castavg") then
			spellBar.castAverage = value / amtCasts
			text:SetText(Details:Format(spellBar.castAverage))
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

	table.wipe(spellBar.ExpandedChildren)

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
---@param scrollData breakdownscrolldata
---@param offset number
---@param totalLines number
local refreshFunc = function(scrollFrame, scrollData, offset, totalLines) --~refresh spells
	---@type number
	local maxValue = scrollData[1] and scrollData[1].total
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

	local headerTable = spellsTab.BuildHeaderTable()
	scrollFrame.Header:SetHeaderTable(headerTable)

	local lineIndex = 1
	for i = 1, totalLines do
		local index = i + offset

		---@type breakdownspelldata
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
function spellsTab.CreateSpellScrollContainer(tabFrame)
    --replace this with a framework scrollframe
	local scrollFrame = DF:CreateScrollBox(tabFrame, "$parentSpellScroll", refreshFunc, {}, CONST_SPELLSCROLL_WIDTH, CONST_SPELLSCROLL_HEIGHT, CONST_SPELLSCROLL_AMTLINES, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(scrollFrame)
	DF:ApplyStandardBackdrop(scrollFrame)
	scrollFrame:SetPoint("topleft", tabFrame, "topleft", 5, -5) --need to set the points
	scrollFrame:EnableMouse(true)
	scrollFrame:SetMovable(true)
	tabFrame.SpellScrollFrame = scrollFrame

	function scrollFrame:RefreshMe(data)
		self:SetData(data)
		self:Refresh()
	end

	--~header
	local headerOptions = {
		padding = 2,
		header_height = 14,
	}

	local headerTable = {}

	scrollFrame.Header = DetailsFramework:CreateHeader(scrollFrame, headerTable, headerOptions)
	scrollFrame.Header:SetPoint("topleft", scrollFrame, "topleft", 0, 0)

	--create the scroll lines
	for i = 1, CONST_SPELLSCROLL_AMTLINES do
		scrollFrame:CreateLine(spellsTab.CreateSpellBar)
	end

	return scrollFrame
end

--special backgrounds	-- fundos especiais de friendly fire e outros
function spellsTab.CreateSpecialBackgrounds(tabFrame)
    tabFrame.no_targets = tabFrame:CreateTexture("DetailsBreakdownWindow_no_targets", "overlay")
    tabFrame.no_targets:SetPoint("bottomleft", tabFrame, "bottomleft", 20, 6)
    tabFrame.no_targets:SetSize(301, 100)
    tabFrame.no_targets:SetTexture([[Interface\QUESTFRAME\UI-QUESTLOG-EMPTY-TOPLEFT]])
    tabFrame.no_targets:SetTexCoord(0.015625, 1, 0.01171875, 0.390625)
    tabFrame.no_targets:SetDesaturated(true)
    tabFrame.no_targets:SetAlpha(.7)
    tabFrame.no_targets.text = tabFrame:CreateFontString(nil, "overlay", "GameFontNormal")
    tabFrame.no_targets.text:SetPoint("center", tabFrame.no_targets, "center")
    tabFrame.no_targets.text:SetText(Loc ["STRING_NO_TARGET_BOX"])
    tabFrame.no_targets.text:SetTextColor(1, 1, 1, .4)
    tabFrame.no_targets:Hide()
end

---on enter function for the spell target frame
---@param targetFrame breakdowntargetframe
local onEnterSpellTarget = function(targetFrame)
	--the spell target frame is created in the statusbar which is placed above the line frame
	local lineBar = targetFrame:GetParent():GetParent()
	local spellId = targetFrame.spellId

	---@type actor
	local actorObject = Details:GetPlayerObjectFromBreakdownWindow()

	local targets
	if (targetFrame.bIsMainLine) then
		---@type breakdownspelldata
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
function spellsTab.CreateSpellBar(self, index) --~spellbar ~spellline ~spell ~create ~createline
	---@type breakdownspellbar
	local spellBar = CreateFrame("button", self:GetName() .. "SpellBar" .. index, self, "BackdropTemplate")
	spellBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
	spellBar.index = index
	local y = (index-1) * CONST_SPELLSCROLL_LINEHEIGHT * -1 + (1 * -index) - 15
	spellBar:SetPoint("topleft", self, "topleft", 0, y)
	spellBar:SetPoint("topright", self, "topright", 0, y)
	spellBar:SetFrameLevel(self:GetFrameLevel() + 1)
	spellBar:EnableMouse(true)
	spellBar:RegisterForClicks("LeftButtonDown", "RightButtonUp")
	spellBar:SetScript("OnEnter", onEnterBreakdownSpellBar)
	spellBar:SetScript("OnLeave", onLeaveBreakdownSpellBar)
	spellBar:SetScript("OnMouseDown", onMouseDownBreakdownSpellBar)
	spellBar:SetScript("OnMouseUp", onMouseUpBreakdownSpellBar)
	spellBar.onMouseUpTime = 0
	spellBar.ExpandedChildren = {}

	DF:Mixin(spellBar, DF.HeaderFunctions)

	---@type statusbar
	local statusBar = CreateFrame("StatusBar", "$parentStatusBar", spellBar, "BackdropTemplate")
	statusBar:SetFrameLevel(spellBar:GetFrameLevel()-1)
	statusBar:SetAllPoints()
	statusBar:SetAlpha(0.5)
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetValue(50)
	spellBar.statusBar = statusBar

	---@type texture
	local statusBarTexture = statusBar:CreateTexture("$parentTexture", "artwork")
	statusBarTexture:SetTexture(SharedMedia:Fetch("statusbar", "Details Hyanda"))
	statusBar:SetStatusBarTexture(statusBarTexture)
	statusBar:SetStatusBarColor(1, 1, 1, 1)

	---create the overlay texture to use when the spellbar is selected
	---@type texture
	local statusBarOverlayTexture = statusBar:CreateTexture("$parentTextureOverlay", "overlay", nil, 7)
	statusBarOverlayTexture:SetTexture([[Interface/AddOns/Details/images/overlay_indicator_1]])
	statusBarOverlayTexture:SetVertexColor(1, 1, 1, 0.2)
	statusBarOverlayTexture:SetAllPoints()
	statusBarOverlayTexture:Hide()
	spellBar.overlayTexture = statusBarOverlayTexture
	statusBar.overlayTexture = statusBarOverlayTexture

	---@type texture
	local hightlightTexture = statusBar:CreateTexture("$parentTextureHighlight", "highlight")
	hightlightTexture:SetColorTexture(1, 1, 1, 0.2)
	hightlightTexture:SetAllPoints()
	statusBar.highlightTexture = hightlightTexture

	---@type texture
	local backgroundTexture = statusBar:CreateTexture("$parentTextureBackground", "background")
	backgroundTexture:SetAllPoints()
	backgroundTexture:SetColorTexture(.1, .1, .1, 0.38)
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

	spellBar.on_focus = false

	return spellBar
end


--[=[
function gump:CriaNovaBarraInfo2(instance, index) --not used on this file, used on class damage, heal, etc
	if (_detalhes.playerDetailWindow.barras2[index]) then
		return
	end

	local janela = info.container_alvos.gump

	local newBar = CreateFrame("Button", "Details_infobox2_bar_" .. index, info.container_alvos.gump, "BackdropTemplate")
	newBar:SetHeight(CONST_TARGET_HEIGHT)

	local y = (index-1) * (CONST_TARGET_HEIGHT + 1)
	y = y* - 1

	newBar:SetPoint("LEFT", janela, "LEFT", CONST_TARGET_HEIGHT, 0)
	newBar:SetPoint("RIGHT", janela, "RIGHT", 0, 0)
	newBar:SetPoint("TOP", janela, "TOP", 0, y)
	newBar:SetFrameLevel(janela:GetFrameLevel() + 1)
	newBar:EnableMouse(true)
	newBar:RegisterForClicks("LeftButtonDown","RightButtonUp")

	--icon
	newBar.icone = newBar:CreateTexture(nil, "OVERLAY")
	newBar.icone:SetWidth(CONST_TARGET_HEIGHT)
	newBar.icone:SetHeight(CONST_TARGET_HEIGHT)
	newBar.icone:SetPoint("RIGHT", newBar, "LEFT", 0, 0)

	CriaTexturaBarra(newBar)

	newBar:SetAlpha(ALPHA_BLEND_AMOUNT)
	newBar.icone:SetAlpha(1)

	newBar.isAlvo = true

	SetBarraScripts(newBar, instance, index)

	info.barras2[index] = newBar --barra adicionada

	return newBar
end

function gump:CriaNovaBarraInfo3(instance, index) --not used on this file, used on class damage, heal, etc
	if (_detalhes.playerDetailWindow.barras3[index]) then
		return
	end

	local janela = info.container_detalhes

	local newBar = CreateFrame("button", "Details_infobox3_bar_" .. index, janela, "BackdropTemplate")
	newBar:SetHeight(16)

	local y = (index-1) * 17
	y = y*-1

	container3_bars_pointFunc(newBar, index) --what this fun does?
	newBar:EnableMouse(true)

	--icon
	newBar.icone = newBar:CreateTexture(nil, "OVERLAY")
	newBar.icone:SetWidth(14)
	newBar.icone:SetHeight(14)
	newBar.icone:SetPoint("LEFT", newBar, "LEFT", 0, 0)

	CriaTexturaBarra(newBar)

	newBar:SetAlpha(0.9)
	newBar.icone:SetAlpha(1)

	newBar.isDetalhe = true

	SetBarraScripts(newBar, instance, index)

	info.barras3[index] = newBar

	return newBar
end
--]=]

-----------------------------------------------------------------------------------------------------------------------
--> report data

function spellsTab.monta_relatorio(botao)
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
			print(Loc ["STRING_ACTORFRAME_NOTHING"])
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
				print(Loc ["STRING_ACTORFRAME_NOTHING"])
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

		function() --[4] fill function
			--spellsTab.JI_AtualizaContainerBarras(-1) --not in use anymore
			spellsTab.TabFrame.no_targets:Hide() --this is nil
			spellsTab.TabFrame.no_targets.text:Hide()

			spellsTab.OnShownTab()
			--spellsTab.TrocaBackgroundInfo(spellsTab.TabFrame)
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
	---@param data table
	---@param actorObject actor
	---@param combatObject combat
	---@param instance instance
	function tabButton.OnReceiveSpellData(data, actorObject, combatObject, instance)
		spellsTab.currentActor = actorObject
		spellsTab.combatObject = combatObject
		spellsTab.instance = instance
		spellsTab.TabFrame.SpellScrollFrame:RefreshMe(data)
	end
end

