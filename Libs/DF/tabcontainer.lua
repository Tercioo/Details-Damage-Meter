
local detailsFramework = DetailsFramework

if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local unpack = unpack
local CreateFrame = CreateFrame
local PixelUtil = PixelUtil

---@class df_tabinfotable : table
---@field name string
---@field text string
---@field createOnDemandFunc function?

---@class df_tabcontainer : frame
---@field AllFrames df_tabcontainerframe[]
---@field AllButtons df_tabcontainerbutton[]
---@field AllFramesByName table<string, df_tabcontainerframe>
---@field AllButtonsByName table<string, df_tabcontainerbutton>
---@field hookList table
---@field options df_tabcontaineroptions
---@field CurrentIndex number
---@field IsContainer boolean
---@field ButtonSelectedBorderColor table
---@field ButtonNotSelectedBorderColor table
---@field CanCloseWithRightClick boolean
---@field CallOnEachTab fun(self: df_tabcontainer, callback: function, ...)
---@field SetIndex fun(self: df_tabcontainer, index: number)
---@field SelectTabByIndex fun(self: df_tabcontainer, menuIndex: number)
---@field SelectTabByName fun(self: df_tabcontainer, name: string)
---@field CreateUnderlineGlow fun(button: button)
---@field OnShow fun(self: df_tabcontainer)
---@field GetTabFrameByName fun(self: df_tabcontainer, name: string): df_tabcontainerframe
---@field GetTabFrameByIndex fun(self: df_tabcontainer, index: number): df_tabcontainerframe
---@field GetTabButtonByName fun(self: df_tabcontainer, name: string): df_tabcontainerbutton
---@field GetTabButtonByIndex fun(self: df_tabcontainer, index: number): df_tabcontainerbutton

---@class df_tabcontainerframe : frame
---@field bIsFrontPage boolean
---@field titleText fontstring
---@field tabIndex number
---@field OnMouseDown fun(self: df_tabcontainerframe, button: string)
---@field OnMouseUp fun(self: df_tabcontainerframe, button: string)
---@field RefreshOptions fun(self: df_tabcontainerframe)|nil

---@class df_tabcontainerbutton : button
---@field selectedUnderlineGlow texture
---@field textsize number
---@field mainFrame df_tabcontainer
---@field leftSelectionIndicator texture

--create a template for the tab buttons
local tabTemplate = detailsFramework.table.copy({}, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
tabTemplate.backdropbordercolor = nil

detailsFramework.TabContainerMixin = {
    CallOnEachTab = function(self, callback, ...)
        for _, tabFrame in ipairs(self.AllFrames) do
            detailsFramework:Dispatch(callback, tabFrame, ...)
        end
    end,

    ---@param self df_tabcontainer
    ---@param tabIndex number
    ---@return df_tabcontainerframe
    GetTabFrameByIndex = function(self, tabIndex)
        return self.AllFrames[tabIndex]
    end,

    ---@param self df_tabcontainer
    ---@param name string
    ---@return df_tabcontainerframe
    GetTabFrameByName = function(self, name)
        return self.AllFramesByName[name]
    end,

    ---@param self df_tabcontainer
    ---@param tabIndex number
    ---@return df_tabcontainerbutton
    GetTabButtonByIndex = function(self, tabIndex)
        return self.AllButtons[tabIndex]
    end,

    ---@param self df_tabcontainer
    ---@param name string
    ---@return df_tabcontainerbutton
    GetTabButtonByName = function(self, name)
        return self.AllButtonsByName[name]
    end,

    ---@param self df_tabcontainer
    ---@param backdropTable backdrop|nil
    ---@param backdropColorTable table|string|nil
    ---@param backdropBorderColorTable table|string|nil
    SetTabFramesBackdrop = function(self, backdropTable, backdropColorTable, backdropBorderColorTable)
        for tabIndex, tabFrame in ipairs(self.AllFrames) do
            if (backdropTable) then
                tabFrame:SetBackdrop(backdropTable)
            end
            if (backdropColorTable) then
                local r, g, b, a = detailsFramework:ParseColors(backdropColorTable)
                tabFrame:SetBackdropColor(r, g, b, a)
            end
            if (backdropBorderColorTable) then
                local r, g, b, a = detailsFramework:ParseColors(backdropColorTable)
                tabFrame:SetBackdropBorderColor(r, g, b, a)
            end
        end
    end,

    ---create a underglow texture for the selected tab, this texture is a small yellow bright gradient below the button
    ---@param self df_tabcontainerbutton
    CreateUnderlineGlow = function(self)
        local selectedGlow = self:CreateTexture(nil, "background", nil, -4)
        selectedGlow:SetPoint("topleft", self["widget"], "bottomleft", -7, 0)
        selectedGlow:SetPoint("topright", self["widget"], "bottomright", 7, 0)
        selectedGlow:SetTexture([[Interface\BUTTONS\UI-Panel-Button-Glow]])
        selectedGlow:SetTexCoord(0, 95/128, 30/64, 38/64)
        selectedGlow:SetBlendMode("ADD")
        selectedGlow:SetHeight(8)
        selectedGlow:SetAlpha(.75)
        selectedGlow:Hide()
        self.selectedUnderlineGlow = selectedGlow
    end,

    ---@param tabContainer df_tabcontainer
    ---@param menuIndex number
    SelectTabByIndex = function(tabContainer, menuIndex)
        ---@type df_tabcontainerbutton
        local tabButton = tabContainer.AllButtons[menuIndex]
        ---@type df_tabcontainerframe
        local tabFrame = tabContainer.AllFrames[menuIndex]

        if (not tabFrame) then
            return
        end

        --hide all tab frame and hide the selection glow from tab buttons
        for i = 1, #tabContainer.AllFrames do
            ---@type df_tabcontainerframe
            local thisTabFrame = tabContainer.AllFrames[i]
            thisTabFrame:Hide()

            ---@type df_tabcontainerbutton
            local thisTabButton = tabContainer.AllButtons[i]
            if (tabContainer.ButtonNotSelectedBorderColor) then
                thisTabButton:SetBackdropBorderColor(unpack(tabContainer.ButtonNotSelectedBorderColor))
            end
            if (thisTabButton.selectedUnderlineGlow) then
                thisTabButton.selectedUnderlineGlow:Hide()
            end
        end

        tabFrame:Show()
        if (tabFrame.RefreshOptions) then
            tabFrame:RefreshOptions()
        end

        if (tabContainer.ButtonSelectedBorderColor) then
            tabButton:SetBackdropBorderColor(unpack(tabContainer.ButtonSelectedBorderColor))
        end

        if (tabButton.selectedUnderlineGlow) then
            tabButton.selectedUnderlineGlow:Show()
        end

        tabContainer.CurrentIndex = menuIndex

        if (tabContainer.hookList.OnSelectIndex) then
            detailsFramework:QuickDispatch(tabContainer.hookList.OnSelectIndex, tabContainer, tabButton)
        end
    end,

    ---@param tabContainer df_tabcontainer
    ---@param name string
    SelectTabByName = function(tabContainer, name)
        ---@type df_tabcontainerframe
        local tabFrame = tabContainer.AllFramesByName[name]
        if (tabFrame) then
            local tabIndex = tabFrame.tabIndex
            tabContainer:SelectTabByIndex(tabIndex)
        else
            error("df_tabcontainer:SelectTabByName(name): param #2 'name' not found within 'tabContainer.AllFramesByName'.")
        end
    end,

    ---@param self df_tabcontainer
    ---@param index number
    SetIndex = function(self, index)
        self.CurrentIndex = index
    end,

    ---@param self df_tabcontainer
    OnShow = function(self)
        local index = self.CurrentIndex
        self:SelectTabByIndex(index)
    end
}

detailsFramework.TabContainerFrameMixin = {
    ---@param self df_tabcontainerframe
    ---@param button string
    OnMouseDown = function(self, button)
        if (self:GetParent().options.can_move_parent) then
            --search for UIParent
            ---@type frame
            local highestParent = detailsFramework:FindHighestParent(self)
            local tabContainer = self:GetParent()
            ---@cast tabContainer df_tabcontainer

            if (button == "LeftButton") then
                if (not highestParent.IsMoving and highestParent:IsMovable()) then
                    highestParent:StartMoving()
                    highestParent.IsMoving = true
                end

            elseif (button == "RightButton") then
                if (not highestParent.IsMoving and tabContainer.IsContainer) then
                    if (self.bIsFrontPage) then
                        if (tabContainer.CanCloseWithRightClick) then
                            if (highestParent["CloseFunction"]) then
                                highestParent["CloseFunction"](highestParent)
                            else
                                highestParent:Hide()
                            end
                        end
                    else
                        --goes back to front page
                        tabContainer:SelectTabByIndex(1)
                    end
                end
            end
        end
    end,

    ---@param self df_tabcontainerframe
    ---@param button string
    OnMouseUp = function(self, button)
        if (self:GetParent().options.can_move_parent) then
            local frame = detailsFramework:FindHighestParent(self)
            if (frame.IsMoving) then
                frame:StopMovingOrSizing()
                frame.IsMoving = false
            end
        end
    end,
}

---@class df_tabcontaineroptions : table
---@field width number?
---@field height number?
---@field button_border_color table?
---@field button_selected_border_color table?
---@field right_click_y number?
---@field hide_click_label boolean?
---@field close_text_alpha number?
---@field rightbutton_always_close boolean?
---@field right_click_interact boolean?
---@field y_offset number?
---@field button_width number?
---@field button_height number?
---@field button_x number?
---@field button_y number?
---@field button_text_size number?
---@field container_width_offset number?
---@field can_move_parent boolean?

---creates a frame called tabContainer which is used as base for the tab container object
---the function receives a table called tabList which contains sub tables with two keys 'name' and 'text', name is the frame name and text is the text displayed on the button
---then the function iterate amongst the tabList and create a frame and a button for each entry using the value of the 'text' key as the text for the button and 'name' for the name of the frame
---when the user click on a button, the tabContainer hide all frames and show the frame which was created together with that button
---@param parent frame the parent frame
---@param title string a string to use as the title of the tab container, the title is always shown
---@param frameName string the frame name to pass into the CreateFrame function
---@param tabList df_tabinfotable[] the list of tabs to create, each entry has a 'name' and 'text' keys
---@param optionsTable df_tabcontaineroptions?
---@param hookList table<string, function>?
---@param languageInfo any
---@return df_tabcontainer
function detailsFramework:CreateTabContainer(parent, title, frameName, tabList, optionsTable, hookList, languageInfo)
	optionsTable = optionsTable or {}

	local parentFrameWidth = parent:GetWidth()
	local yOffset = optionsTable.y_offset or 0
	local buttonWidth = optionsTable.button_width or 160
	local buttonHeight = optionsTable.button_height or 20
	local buttonAnchorX = optionsTable.button_x or 230
	local buttonAnchorY = optionsTable.button_y or 0
	local buttonTextSize = optionsTable.button_text_size or 10
	local containerWidthOffset = optionsTable.container_width_offset or 0

    if (optionsTable.can_move_parent == nil) then
        optionsTable.can_move_parent = true
    end

    local bFirstTabIsCreateOnDemand = false

    --create the base frame
    ---@type df_tabcontainer
	local tabContainer = CreateFrame("frame", frameName, parent["widget"] or parent, "BackdropTemplate")
    tabContainer.hookList = hookList or {}
    tabContainer:SetSize(optionsTable.width or 750, optionsTable.height or 450)
    tabContainer.options = optionsTable

	detailsFramework:Mixin(tabContainer, detailsFramework.TabContainerMixin)

    --create the fontstring which show the title
    ---@type fontstring
	local mainTitle = detailsFramework:CreateLabel(tabContainer, title, 24, "white")
	mainTitle:SetPoint("topleft", tabContainer, "topleft", 10, -30 + yOffset)

	tabContainer.AllFrames = {}
	tabContainer.AllButtons = {}
    tabContainer.AllFramesByName = {}
    tabContainer.AllButtonsByName = {}
	tabContainer.CurrentIndex = 1
	tabContainer.IsContainer = true
	tabContainer.ButtonSelectedBorderColor = optionsTable.button_selected_border_color or {1, 1, 0, 1}
	tabContainer.ButtonNotSelectedBorderColor = optionsTable.button_border_color or {0, 0, 0, 0}

	if (optionsTable.right_click_interact ~= nil) then
		tabContainer.CanCloseWithRightClick = optionsTable.right_click_interact
	else
		tabContainer.CanCloseWithRightClick = true
	end

	--languageInfo
	local addonId = languageInfo and languageInfo.language_addonId or "none"

	for tabIndex, tabInfo in ipairs(tabList) do
        --create a frame which will be shown when the tabButton is clicked
        --when this tab isn't selected, this frame is hidden
        ---@type df_tabcontainerframe
		local tabFrame = CreateFrame("frame", "$parent" .. tabInfo.name, tabContainer, "BackdropTemplate")
        detailsFramework:Mixin(tabFrame, detailsFramework.TabContainerFrameMixin)
		tabFrame:SetAllPoints()
		tabFrame:SetFrameLevel(210)
		tabFrame:SetScript("OnMouseDown", tabFrame.OnMouseDown)
		tabFrame:SetScript("OnMouseUp", tabFrame.OnMouseUp)
        tabFrame.tabIndex = tabIndex
        tabFrame:Hide()

        if (tabInfo.createOnDemandFunc) then
            tabFrame:SetScript("OnShow", function()
                if (tabInfo.createOnDemandFunc) then
                    detailsFramework:Dispatch(tabInfo.createOnDemandFunc, tabFrame, tabContainer, parent)
                    tabInfo.createOnDemandFunc = nil
                end
            end)

            if (tabIndex == 1) then
                bFirstTabIsCreateOnDemand = true
            end
        end

		--attempt to get the localized text from the language system using the addonId and the frameInfo.text
		local phraseId = tabInfo.text
		local bIsLanguagePrahseID = detailsFramework.Language.DoesPhraseIDExistsInDefaultLanguage(addonId, phraseId)

        --create the fontstring which show this tab text, this text is only shown when the tab is shown
		local titleLabel = detailsFramework:CreateLabel(tabFrame, "", 16, "silver")
		if (bIsLanguagePrahseID) then
			DetailsFramework.Language.RegisterObjectWithDefault(addonId, titleLabel, tabInfo.text, tabInfo.text)
		else
			titleLabel:SetText(tabInfo.text)
		end
		titleLabel:SetPoint("topleft", mainTitle, "bottomleft", 0, 0)
		tabFrame.titleText = titleLabel

        ---@type df_tabcontainerbutton
		local tabButton = detailsFramework:CreateButton(tabContainer, function() tabContainer:SelectTabByIndex(tabIndex) end, buttonWidth, buttonHeight, tabInfo.text, tabIndex, nil, nil, nil, "$parentTabButton" .. tabInfo.name, false, tabTemplate)
		PixelUtil.SetSize(tabButton, buttonWidth, buttonHeight)
		tabButton:SetFrameLevel(220)
		tabButton.textsize = buttonTextSize
		tabButton.mainFrame = tabContainer
		tabContainer.CreateUnderlineGlow(tabButton)

        --register the fontstring with the language system
		if (bIsLanguagePrahseID) then
			DetailsFramework.Language.RegisterObjectWithDefault(addonId, tabButton["widget"], tabInfo.text, tabInfo.text)
		end

		local rightClickToBack
		if (tabIndex == 1 or optionsTable.rightbutton_always_close) then
			rightClickToBack = detailsFramework:CreateLabel(tabFrame, "right click to close", 10, "gray")
			rightClickToBack:SetPoint("bottomright", tabFrame, "bottomright", -1, optionsTable.right_click_y or 0)
			if (optionsTable.close_text_alpha) then
				rightClickToBack:SetAlpha(optionsTable.close_text_alpha)
			end
			tabFrame.bIsFrontPage = true
		else
			rightClickToBack = detailsFramework:CreateLabel(tabFrame, "right click to go back to main menu", 10, "gray")
			rightClickToBack:SetPoint("bottomright", tabFrame, "bottomright", -1, optionsTable.right_click_y or 0)
			if (optionsTable.close_text_alpha) then
				rightClickToBack:SetAlpha(optionsTable.close_text_alpha)
			end
		end

		if (optionsTable.hide_click_label) then
			rightClickToBack:Hide()
		end

		table.insert(tabContainer.AllFrames, tabFrame)
		table.insert(tabContainer.AllButtons, tabButton)
        tabContainer.AllFramesByName[tabInfo.name] = tabFrame
        tabContainer.AllFramesByName[tabInfo.text] = tabFrame
        tabContainer.AllButtonsByName[tabInfo.name] = tabButton
        tabContainer.AllButtonsByName[tabInfo.text] = tabButton
	end

	--order buttons
	local x = buttonAnchorX
	local y = buttonAnchorY
	local spaceBetweenButtons = 2

	local allocatedSpaceForButtons = parentFrameWidth - ((#tabList - 2) * spaceBetweenButtons) - buttonAnchorX + containerWidthOffset
	local amountButtonsPerRow = math.floor(allocatedSpaceForButtons / buttonWidth)

    if (tabContainer.AllButtons[1]) then
	    tabContainer.AllButtons[1]:SetPoint("topleft", mainTitle, "topleft", x, y)
    end

	x = x + buttonWidth + 2

	for i = 2, #tabContainer.AllButtons do
		local button = tabContainer.AllButtons[i]
		PixelUtil.SetPoint(button, "topleft", mainTitle, "topleft", x, y)
		x = x + buttonWidth + 2

		if (i % amountButtonsPerRow == 0) then
			x = buttonAnchorX
			y = y - buttonHeight - 1
		end
	end

	--when show the frame, reset to the current internal index
	tabContainer:SetScript("OnShow", tabContainer.OnShow)
	--select the first frame
    local defaultTab = 1

    if (bFirstTabIsCreateOnDemand) then
        C_Timer.After(0, function() tabContainer:SelectTabByIndex(defaultTab) end)
    else
        tabContainer:SelectTabByIndex(defaultTab)
    end

	return tabContainer
end


--[=[example:

local parent = UIParent
local title = "My AddOn Options"
local frameName = "MyAddOnOptionsFrame"
local tabList = { 
    {name = "GeneralSettings", text = "General Settings"},
    {name = "AdvancedSettings", text = "Advanced Settings"},
    {name = "AboutTheAddon", text = "Addon Info"},
}
local optionsTable = {}
local hookList = {}
local languageInfo = {language_addonId = "MyAddOnTocName"}

local tabContainer = DetailsFramework:CreateTabContainer(parent, title, frameName, tabList, optionsTable, hookList, languageInfo)
tabContainer:SetPoint("center", UIParent, "center", 0, 0)
tabContainer:SetSize(750, 450)
tabContainer:Show()

--ways for getting a tab frame and start to create widgets inside it
local tabIndex = 1
local generalSettingsTabFrame = tabContainer:GetTabFrameByIndex(tabIndex) --using a tabIndex
local advancedSettingsTabFrame = tabContainer:GetTabFrameByName("Advanced Settings") --using the tab text
local aboutTabFrame = tabContainer:GetTabFrameByName("AboutTheAddon") --using the tab name

--clicking on tab buttons will automatically show the tab frame, to select a tab frame without clicking on the button, use:
tabContainer:SelectTabByIndex(tabIndex) --using a tabIndex
tabContainer:SelectTabByName("Advanced Settings") --using the tab text
tabContainer:SelectTabByName("AdvancedSettings") --using the tab name

--modify the background color by applying a backdrop
local backdropTable = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true}
local backdropColor = {DetailsFramework:GetDefaultBackdropColor()}
local backdropBorderColor = {0, 0, 0, 1}
tabContainer:SetTabFramesBackdrop(backdropTable, backdropColor, backdropBorderColor)

--]=]