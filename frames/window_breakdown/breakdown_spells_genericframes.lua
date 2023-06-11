
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
local tinsert = table.insert

local damageClass = Details.atributo_damage

local spellsTab = DetailsSpellBreakdownTab
local headerContainerType = spellsTab.headerContainerType

local CONST_BAR_HEIGHT = 20
local CONST_SPELLSCROLL_LINEHEIGHT = 20
local CONST_TARGET_TEXTURE = [[Interface\MINIMAP\TRACKING\Target]]
local CONST_SPELLBLOCK_DEFAULT_COLOR = {.4, .4, .4, 1}
local CONST_SPELLBLOCK_HEADERTEXT_COLOR = {.9, .8, 0, 1}
local CONST_SPELLBLOCK_HEADERTEXT_SIZE = 11

---onEnter function for the generic bars, set the alpha of the bar to one
---@param self breakdowngenericbar
local onEnterGenericBar = function(self) --~onenter ~genericbaronenter
    self:SetAlpha(1)

    if (self.bIsFromLeftScroll) then
        ---@type instance
        local instanceObject = spellsTab.GetInstance()
        local mainAttribute, subAttribute = instanceObject:GetDisplay()

        ---@type actordamage
        local currentActor = spellsTab.GetActor()

        ---@type combat
        local currentCombat = instanceObject:GetCombat()

        ---@type actorcontainer
        local actorContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

        if (mainAttribute == DETAILS_ATTRIBUTE_DAMAGE) then
            if (subAttribute == DETAILS_SUBATTRIBUTE_DAMAGETAKEN) then
                local aggressorActor = actorContainer:GetActor(self.actorName)
                ---@type {topValue: number, data: {key1: spellid, key2: number, key3: actorname}[]}
                local spellList = damageClass.BuildDamageTakenSpellListFromAgressor(currentActor, aggressorActor)
                spellsTab.GenericScrollFrameRight:RefreshMe(spellList)

			elseif (subAttribute == DETAILS_SUBATTRIBUTE_FRIENDLYFIRE) then
				--currentActor is the player which inflicted the damage to other players
				--self.actorName is the name of the actor in the hovered bar
				local spellList = damageClass.BuildFriendlySpellListFromAgressor(currentActor, self.actorName)
				spellsTab.GenericScrollFrameRight:RefreshMe(spellList)
            end
        end
    end

    --when hovered over, it need to detect which data is shown and call a function within a class to generate the data to show in the right scroll
end

--onLeave function for the generic bars, set the alpha of the bar to 0.9
---@param self breakdowngenericbar
local onLeaveGenericBar = function(self) --~onleave ~genericbaronleave
    self:SetAlpha(0.9)
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

---@param scrollFrame table
---@param scrollData table
---@param offset number
---@param totalLines number
local refreshGenericRightScrollFunc = function(scrollFrame, scrollData, offset, totalLines) --~refreshgeneric ~refreshfunc ~refresh ~refreshg ~updategenericbar
    local lineIndex = 1
	local combatTime = scrollData.combatTime
	local totalValue = scrollData.totalValue

    for i = 1, totalLines do
		local index = i + offset
		local spellData = scrollData[index]

        if (spellData) then
            local spellId = spellData.spellId
            local spellTotal = spellData.total
            local petName = spellData.petName
            local spellSchool = spellData.spellScholl

            local spellName, _, spellIcon = _GetSpellInfo(spellId)

            --get a bar from the second generic scroll frame
            local genericBar = getGenericBar(scrollFrame, i)
            genericBar.statusBar:SetValue(spellTotal / scrollFrame.topValue * 100)

            local r, g, b = Details:GetSpellSchoolColor(spellSchool)
            genericBar.statusBar:SetStatusBarColor(r, g, b, 1)

			---@type number
			local textIndex = 1

            if (scrollData.headersAllowed.icon) then
				---@type texturetable
				genericBar.Icon:Show()
				genericBar.Icon:SetTexture(spellIcon)
				genericBar.Icon:SetTexCoord(.1, .9, .1, .9)
				genericBar.Icon:SetSize(CONST_SPELLSCROLL_LINEHEIGHT-2, CONST_SPELLSCROLL_LINEHEIGHT-2)
				genericBar:AddFrameToHeaderAlignment(genericBar.Icon)
            end

			if (scrollData.headersAllowed.rank) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(index)
				textIndex = textIndex + 1
			end

			if (scrollData.headersAllowed.name) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				if (petName ~= "") then
					--remove the owner name from the pet name
					petName = petName:gsub((" <.*"), "")
					spellName = spellName .. " (" .. petName .. ")"
				end
				fontString:SetText(spellName)
				textIndex = textIndex + 1
                genericBar.actorName = spellName
			end

			if (scrollData.headersAllowed.amount) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(Details:Format(spellTotal))
				textIndex = textIndex + 1
			end

			if (scrollData.headersAllowed.persecond) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(Details:Format(spellTotal / combatTime))
				textIndex = textIndex + 1
			end

			if (scrollData.headersAllowed.percent) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(string.format("%.1f", spellTotal / totalValue * 100) .. "%")
				textIndex = textIndex + 1
			end

            genericBar:Show()

			genericBar:AlignWithHeader(scrollFrame.Header, "left")

			lineIndex = lineIndex + 1
			if (lineIndex > totalLines) then
				break
			end

            --set the amount
            --genericBar.InLineTexts[2]:SetText(Details:ToK(spellTotal))

            --set the amount percent
            --genericBar.InLineTexts[3]:SetText(Details:ToK(spellTotal / totalValue * 100))
        end
    end
end

---@param scrollFrame table
---@param scrollData table
---@param offset number
---@param totalLines number
local refreshGenericLeftScrollFunc = function(scrollFrame, scrollData, offset, totalLines) --~refreshgeneric ~refreshfunc ~refresh ~refreshg ~updategenericbar
	local lineIndex = 1
	local combatTime = scrollData.combatTime
	local totalValue = scrollData.totalValue

	for i = 1, totalLines do
		local index = i + offset
		local dataTable = scrollData[index]

		if (dataTable) then
			local genericBar = getGenericBar(scrollFrame, lineIndex)
			genericBar.statusBar:SetValue(dataTable.total / scrollFrame.topValue * 100)

			local spellSchool = dataTable.spellScholl
			local className = dataTable.class

			if (spellSchool) then
            	local r, g, b = Details:GetSpellSchoolColor(spellSchool)
            	genericBar.statusBar:SetStatusBarColor(r, g, b, 1)

			else
				local red, green, blue = Details:GetClassColor(className)
				genericBar.statusBar:SetStatusBarColor(red, green, blue, 1)
			end

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

			if (scrollData.headersAllowed.rank) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				fontString:SetText(index)
				textIndex = textIndex + 1
			end

			if (scrollData.headersAllowed.name) then
				---@type fontstring
				local fontString = genericBar.InLineTexts[textIndex]
				genericBar:AddFrameToHeaderAlignment(fontString)
				local nameWithoutRealm = DF:RemoveRealmName(dataTable.name)
				fontString:SetText(nameWithoutRealm or dataTable.name)
				textIndex = textIndex + 1
                genericBar.actorName = dataTable.name
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

			genericBar:AlignWithHeader(scrollFrame.Header, "left")

			lineIndex = lineIndex + 1
			if (lineIndex > totalLines) then
				break
			end
		end
	end
end


---create a genericbar within the generic scroll
---@param self breakdowngenericscrollframe
---@param index number
---@return breakdowngenericbar
local createGenericBar = function(self, index) --~create ~generic ~creategeneric ~genericbar
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
	genericBar:SetScript("OnEnter", onEnterGenericBar)
	genericBar:SetScript("OnLeave", onLeaveGenericBar)

	DF:Mixin(genericBar, DF.HeaderFunctions)

	---@type breakdownspellbarstatusbar
	local statusBar = CreateFrame("StatusBar", "$parentStatusBar", genericBar)
	statusBar:SetAllPoints()
	statusBar:SetAlpha(0.8)
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

---create two generic containers, these containers hold bars that can show any type of data
---an example is damage taken in the left container and the spells which caused the damage in the right container
---@param tabFrame tabframe
---@return breakdowngenericscrollframe, breakdowngenericscrollframe
function spellsTab.CreateGenericContainers(tabFrame) --~create ~generic ~creategenericcontainer ~creategenericscroll ~creategeneric
	local defaultAmountOfLines = 50

	--create a container for the scrollframe
	local optionsLeftScroll = {
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

	--create a container for the scrollframe
	local optionsRightScroll = {
		width = Details.breakdown_spell_tab.genericcontainer_right_width,
		height = Details.breakdown_spell_tab.genericcontainer_right_height,
		is_locked = Details.breakdown_spell_tab.genericcontainer_islocked,
		can_move = false,
		can_move_children = false,
		use_top_resizer = true,
		use_right_resizer = true,
		use_bottom_resizer = true,
		use_left_resizer = true,
	}

	---@type df_framecontainer
	local leftContainer = DF:CreateFrameContainer(tabFrame, optionsLeftScroll, tabFrame:GetName() .. "GenericScrollContainerLeft")
	leftContainer:SetPoint("topleft", tabFrame, "topleft", 0, 0)
	leftContainer:SetFrameLevel(tabFrame:GetFrameLevel()+1)
	spellsTab.GenericContainerFrameLeft = leftContainer

	---@type df_framecontainer
	local rightContainer = DF:CreateFrameContainer(tabFrame, optionsRightScroll, tabFrame:GetName() .. "GenericScrollContainerRight")
	rightContainer:SetPoint("topleft", leftContainer, "topright", 30, 0)
	rightContainer:SetFrameLevel(tabFrame:GetFrameLevel()+1)
	spellsTab.GenericContainerFrameRight = rightContainer

	--when a setting is changed in the container, it will call this function, it is registered below with SetSettingChangedCallback()
	local settingChangedCallbackFunction_Left = function(frameContainer, settingName, settingValue)
		if (frameContainer:IsShown()) then
			if (settingName == "height") then
				---@type number
				local currentHeight = frameContainer.ScrollFrame:GetHeight()
				Details.breakdown_spell_tab.genericcontainer_height = settingValue
				frameContainer.ScrollFrame:SetNumFramesShown(math.floor(currentHeight / CONST_SPELLSCROLL_LINEHEIGHT) - 2)

			elseif (settingName == "width") then
				Details.breakdown_spell_tab.genericcontainer_width = settingValue

			elseif (settingName == "is_locked") then
				Details.breakdown_spell_tab.genericcontainer_islocked = settingValue
			end
		end
	end
	leftContainer:SetSettingChangedCallback(settingChangedCallbackFunction_Left)

	--when a setting is changed in the container, it will call this function, it is registered below with SetSettingChangedCallback()
	local settingChangedCallbackFunction_Right = function(frameContainer, settingName, settingValue)
		if (frameContainer:IsShown()) then
			if (settingName == "height") then
				---@type number
				local currentHeight = frameContainer.ScrollFrame:GetHeight()
				Details.breakdown_spell_tab.genericcontainer_right_height = settingValue
				frameContainer.ScrollFrame:SetNumFramesShown(math.floor(currentHeight / CONST_SPELLSCROLL_LINEHEIGHT) - 2)

			elseif (settingName == "width") then
				Details.breakdown_spell_tab.genericcontainer_right_width = settingValue

			elseif (settingName == "is_locked") then
				Details.breakdown_spell_tab.genericcontainer_islocked = settingValue
			end
		end
	end
	rightContainer:SetSettingChangedCallback(settingChangedCallbackFunction_Right)

	--create the left scrollframe
	local genericScrollFrameLeft = DF:CreateScrollBox(leftContainer, "$parentGenericScrollLeft", refreshGenericLeftScrollFunc, {}, Details.breakdown_spell_tab.genericcontainer_width, Details.breakdown_spell_tab.genericcontainer_height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(genericScrollFrameLeft)
	genericScrollFrameLeft:SetBackdrop({})
	genericScrollFrameLeft:SetAllPoints()
    leftContainer:RegisterChildForDrag(genericScrollFrameLeft)
    leftContainer.ScrollFrame = genericScrollFrameLeft
	genericScrollFrameLeft.DontHideChildrenOnPreRefresh = false
	tabFrame.GenericScrollFrameLeft = genericScrollFrameLeft
	spellsTab.GenericScrollFrameLeft = genericScrollFrameLeft

	--create the right scrollframe
	local genericScrollFrameRight = DF:CreateScrollBox(rightContainer, "$parentGenericScrollRight", refreshGenericRightScrollFunc, {}, Details.breakdown_spell_tab.genericcontainer_right_width, Details.breakdown_spell_tab.genericcontainer_right_height, defaultAmountOfLines, CONST_SPELLSCROLL_LINEHEIGHT)
	DF:ReskinSlider(genericScrollFrameRight)
	genericScrollFrameRight:SetBackdrop({})
	genericScrollFrameRight:SetAllPoints()
    rightContainer:RegisterChildForDrag(genericScrollFrameRight)
    rightContainer.ScrollFrame = genericScrollFrameRight
	genericScrollFrameRight.DontHideChildrenOnPreRefresh = false
	tabFrame.GenericScrollFrameRight = genericScrollFrameRight
	spellsTab.GenericScrollFrameRight = genericScrollFrameRight

	function genericScrollFrameLeft:RefreshMe(data) --~refreshme (generic) ~refreshg
		--get which column is currently selected and the sort order
		local columnIndex, order, key = genericScrollFrameLeft.Header:GetSelectedColumn()
		genericScrollFrameLeft.SortKey = key

		---@type string
		local keyToSort = key

		if (order == "DESC") then
			table.sort(data,
			function(t1, t2)
				return t1[keyToSort] > t2[keyToSort]
			end)
			genericScrollFrameLeft.topValue = data[1] and data[1][keyToSort] or 0.00001
		else
			table.sort(data,
			function(t1, t2)
				return t1[keyToSort] < t2[keyToSort]
			end)
			genericScrollFrameLeft.topValue = data[#data] and data[#data][keyToSort] or 0.00001
		end

		genericScrollFrameLeft:SetData(data)
		genericScrollFrameLeft:Refresh()

		--clear the right scrollframe
		genericScrollFrameRight:SetData({})
		genericScrollFrameRight:Refresh()
	end

    function genericScrollFrameRight:RefreshMe(data) --~refreshme (generic) ~refreshg
		--get which column is currently selected and the sort order
		local columnIndex, order, key = genericScrollFrameRight.Header:GetSelectedColumn()
		genericScrollFrameRight.SortKey = key

		---@type string
		local keyToSort = key

		if (order == "DESC") then
			table.sort(data,
			function(t1, t2)
				return t1[keyToSort] > t2[keyToSort]
			end)
			genericScrollFrameRight.topValue = data[1] and data[1][keyToSort] or 0.00001
		else
			table.sort(data,
			function(t1, t2)
				return t1[keyToSort] < t2[keyToSort]
			end)
			genericScrollFrameRight.topValue = data[#data] and data[#data][keyToSort] or 0.00001
		end

		genericScrollFrameRight:SetData(data)
		genericScrollFrameRight:Refresh()
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

	local headerOptionsRight = {
		padding = 2,
		header_height = 14,

		reziser_shown = true,
		reziser_width = 2,
		reziser_color = {.5, .5, .5, 0.7},
		reziser_max_width = 210,

		header_click_callback = spellsTab.OnAnyColumnHeaderClickCallback,

		header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
		text_color = {1, 1, 1, 0.823},
	}

	---@type df_headerframe
	local headerLeft = DetailsFramework:CreateHeader(leftContainer, spellsTab.genericContainerLeftColumnData, headerOptions)
	headerLeft:SetPoint("topleft", genericScrollFrameLeft, "topleft", 0, 1)
	headerLeft:SetColumnSettingChangedCallback(spellsTab.OnHeaderColumnOptionChanged)
	genericScrollFrameLeft.Header = headerLeft

	---@type df_headerframe
	local headerRight = DetailsFramework:CreateHeader(rightContainer, spellsTab.genericContainerRightColumnData, headerOptionsRight)
	headerRight:SetPoint("topleft", genericScrollFrameRight, "topleft", 0, 1)
	headerRight:SetColumnSettingChangedCallback(spellsTab.OnHeaderColumnOptionChanged)
	genericScrollFrameRight.Header = headerRight

	--cache the type of these headers
	headerContainerType[headerLeft] = "generic_left"
	headerContainerType[headerRight] = "generic_right"

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		local lineFrame = genericScrollFrameLeft:CreateLine(createGenericBar)
        lineFrame.bIsFromLeftScroll = true
	end

	--create the scroll lines
	for i = 1, defaultAmountOfLines do
		local lineFrame = genericScrollFrameRight:CreateLine(createGenericBar)
        lineFrame:Hide()
        lineFrame.bIsFromRightScroll = true
	end

	--need to create the second scroll frame to show the details about the spelltable/actor hovered over

	return genericScrollFrameLeft, genericScrollFrameRight
end