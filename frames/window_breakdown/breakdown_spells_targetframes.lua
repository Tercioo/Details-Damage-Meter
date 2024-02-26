
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
local headerContainerType = spellsTab.headerContainerType

local CONST_BAR_HEIGHT = 20
local CONST_SPELLSCROLL_LINEHEIGHT = 20
local CONST_TARGET_TEXTURE = [[Interface\MINIMAP\TRACKING\Target]]
local CONST_SPELLBLOCK_DEFAULT_COLOR = {.4, .4, .4, 1}
local CONST_SPELLBLOCK_HEADERTEXT_COLOR = {.9, .8, 0, 1}
local CONST_SPELLBLOCK_HEADERTEXT_SIZE = 11

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

		local platerNameplates = _G.Plater
		if (platerNameplates and targetActorObject) then
			local npcId = tonumber(targetActorObject.aID)
			if (npcId) then
				local platerProfile = platerNameplates.db.profile
				local npcColors = platerProfile.npc_colors
				local platerNpcColorTable = npcColors[npcId]
				if (platerNpcColorTable) then
					if (platerNpcColorTable[1] == true) then
						local color = platerNpcColorTable[3]
						local r, g, b, a = DF:ParseColors(color)
						targetBar.statusBar:SetStatusBarColor(r, g, b, a)
					end
				end
			end
		end

		targetBar.combatTime = combatTime
		targetBar.actorName = bkTargetData.name

		---@type fontstring
		local text = targetBar.InLineTexts[textIndex]
		local header = headerTable[headerIndex]

		if (header.name == "icon") then
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

		elseif (header.name == "rank") then
			text:SetText(index)
			targetBar:AddFrameToHeaderAlignment(text)
			targetBar.rank = index
			textIndex = textIndex + 1

		elseif (header.name == "name") then
			local noRealmName = DF:RemoveRealmName(bkTargetData.name)
			local noOwnerName = noRealmName:gsub((" <.*"), "")
			text:SetText(noOwnerName)
			targetBar.name = bkTargetData.name
			targetBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "amount") then
			text:SetText(Details:Format(value))
			targetBar:AddFrameToHeaderAlignment(text)
			textIndex = textIndex + 1

		elseif (header.name == "percent") then
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

	---@param self breakdownphasescrollframe
	---@return breakdownreporttable
	function targetScrollFrame:GetReportData()
		local instance = spellsTab.GetInstance()
		local data = targetScrollFrame:GetData()
		local formatFunc = Details:GetCurrentToKFunction()
		local actorObject = spellsTab.GetActor()
		local displayId, subDisplayId = instance:GetDisplay()
		local subDisplayName = Details:GetSubAttributeName(displayId, subDisplayId)
		local combatName = instance:GetCombat():GetCombatName()

		---@type breakdownreporttable
		local reportData = {
			title = "Target of " .. detailsFramework:RemoveRealmName(actorObject:Name()) .. " | " .. subDisplayName .. " | " .. combatName
		}

		local topValue = data[1] and data[1].total or 0

		for i = 1, #data do
			---@type breakdowntargettable
			local dataTable = data[i]

			reportData[#reportData+1] = {
				name = dataTable.name,
				amount = formatFunc(nil, dataTable.total),
				percent = string.format("%.1f", dataTable.total / topValue * 100) .. "%",
			}
		end

		return reportData
	end

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

		header_click_callback = spellsTab.OnAnyColumnHeaderClickCallback,

		header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
		text_color = {1, 1, 1, 0.823},
	}

	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, spellsTab.targetContainerColumnData, headerOptions)
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
			for spellTargetName in pairs(spellTable.targets) do
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

			---@type spellid, spelltable
			for spellId, spellTable in petSpellContainer:ListActors() do --user reported petSpellContainer is nil x1
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