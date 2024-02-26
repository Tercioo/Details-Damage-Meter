
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
local DF = DetailsFramework
local detailsFramework = DetailsFramework
local tinsert = table.insert

local spellsTab = DetailsSpellBreakdownTab
local headerContainerType = spellsTab.headerContainerType

local CONST_BAR_HEIGHT = 20
local CONST_SPELLSCROLL_LINEHEIGHT = 20
local CONST_TARGET_TEXTURE = [[Interface\MINIMAP\TRACKING\Target]]
local CONST_SPELLBLOCK_DEFAULT_COLOR = {.4, .4, .4, 1}
local CONST_SPELLBLOCK_HEADERTEXT_COLOR = {.9, .8, 0, 1}
local CONST_SPELLBLOCK_HEADERTEXT_SIZE = 11


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

	---@param self breakdownphasescrollframe
	---@return breakdownreporttable
	function phaseScrollFrame:GetReportData()
		local instance = spellsTab.GetInstance()
		local data = phaseScrollFrame:GetData()
		local formatFunc = Details:GetCurrentToKFunction()
		local actorObject = spellsTab.GetActor()
		local displayId, subDisplayId = instance:GetDisplay()
		local subDisplayName = Details:GetSubAttributeName(displayId, subDisplayId)
		local combatName = instance:GetCombat():GetCombatName()

		---@type breakdownreporttable
		local reportData = {
			title = "Phases for " .. detailsFramework:RemoveRealmName(actorObject:Name()) .. " | " .. subDisplayName .. " | " .. combatName
		}

		for i = 1, #data do
			local dataTable = data[i]
			reportData[#reportData+1] = {
				name = "Phase:" .. dataTable.phaseName,
				amount = formatFunc(nil, dataTable.amountDone),
				percent = string.format("%.1f", dataTable.percentDone) .. "%",
			}
		end

		return reportData
	end

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

		header_click_callback = spellsTab.OnAnyColumnHeaderClickCallback,

		header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
		text_color = {1, 1, 1, 0.823},
	}

	---@type df_headerframe
	local header = DetailsFramework:CreateHeader(container, spellsTab.phaseContainerColumnData, headerOptions)
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