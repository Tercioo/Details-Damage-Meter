
---@type detailsframework
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end
local GameTooltip = GameTooltip
local unpack = unpack

---mixin to use with DetailsFramework:Mixin(table, detailsFramework.SortFunctions)
---add methods to be used on scrollframes
---@class df_scrollboxmixin
detailsFramework.ScrollBoxFunctions = {
	--set a function to run right before the refresh function (scroll:Refresh())
	--this function receives the same parameters as the refresh function
	SetPreRefreshFunction = function(self, func)
		self.pre_refresh_func = func
	end,

	---refresh the scrollbox by resetting all lines created with :CreateLine(), then calling the refresh_func which was set at :CreateScrollBox()
	---@param self table
	---@return table
	Refresh = function(self)
		--hide all frames and tag as not in use
		self._LinesInUse = 0
		--self.Frames has a list of frames used by the scrollbox
		for index, frame in ipairs(self.Frames) do
			if (not self.DontHideChildrenOnPreRefresh) then
				frame:Hide()
			end
			--set the frame as not in use
			frame._InUse = nil
		end

		local offset = 0
		if (self.IsFauxScroll) then
			self:UpdateFaux(#self.data, self.LineAmount, self.LineHeight)
			offset = self:GetOffsetFaux()
		end

		--before starting the refresh, check if there's a pre refresh function and call it
		if (self.pre_refresh_func) then
			detailsFramework:Dispatch(self.pre_refresh_func, self, self.data, offset, self.LineAmount)
		end

		--call the refresh function
		detailsFramework:Dispatch(self.refresh_func, self, self.data, offset, self.LineAmount)

		--hide all frames that are not in use
		for index, frame in ipairs(self.Frames) do
			--the member _InUse is true when the line is used by the refresh function
			--this member is set to true when the code calls scrollBox:GetLine(index)
			if (not frame._InUse) then
				frame:Hide()
			else
				frame:Show()
			end
		end

		self:Show()

		local frameName = self:GetName()
		if (frameName) then
			if (self.HideScrollBar) then
				local scrollBar = _G[frameName .. "ScrollBar"]
				if (scrollBar) then
					scrollBar:Hide()
				end
			else
				--[=[ --maybe in the future I visit this again
				local scrollBar = _G[frameName .. "ScrollBar"]
				local height = self:GetHeight()
				local totalLinesRequired = #self.data
				local linesShown = self._LinesInUse

				local percent = linesShown / totalLinesRequired
				local thumbHeight = height * percent
				scrollBar.ThumbTexture:SetSize(12, thumbHeight)
				print("thumbHeight:", thumbHeight)
				--]=]
			end
		end
		return self.Frames
	end,

	---@param self df_scrollbox
	---@param offset number
	---@return boolean
	OnVerticalScroll = function(self, offset)
		self:OnVerticalScrollFaux(offset, self.LineHeight, self.Refresh)
		return true
	end,

	---create a line within the scrollbox
	---@param self table is the scrollbox
	---@param func function|nil function to create the line object, this function will receive the line index as argument and return a table with the line object
	---@return table line object (table)
	CreateLine = function(self, func)
		if (not func) then
			func = self.CreateLineFunc
		end

		local okay, newLine = xpcall(func, geterrorhandler(), self, #self.Frames+1)
		if (okay) then
			if (not newLine) then
				error("ScrollFrame:CreateLine() function did not returned a line, use: 'return line'")
			end
			table.insert(self.Frames, newLine)
			newLine.Index = #self.Frames
			return newLine
		end
		return newLine
	end,

	---Creates multiple lines in the scroll box.
	---@param self df_scrollbox The DF_ScrollBox object.
	---@param callback function The callback function to be called for each line.
	---@param lineAmount number The number of lines to create.
	CreateLines = function(self, callback, lineAmount)
		for i = 1, lineAmount do
			self:CreateLine(callback)
		end
	end,

	---Retrieves a specific line from the scroll box.
	---@param self df_scrollbox The DF_ScrollBox object.
	---@param lineIndex number The index of the line to retrieve.
	---@return frame line The line object at the specified index.
	GetLine = function(self, lineIndex)
		local line = self.Frames[lineIndex]
		if (line) then
			line._InUse = true
		end

		self._LinesInUse = self._LinesInUse + 1
		return line
	end,

	---Sets the data for the scroll box.
	---@param data table The data to be set.
	SetData = function(self, data)
		self.data = data
		self.data_original = data
		if (self.OnSetData) then
			detailsFramework:CoreDispatch((self:GetName() or "ScrollBox") .. ":OnSetData()", self.OnSetData, self, self.data)
		end
	end,

	---Retrieves the data associated with the scrollbox.
	---@param self df_scrollbox
	---@return table The data associated with the scrollbox.
	GetData = function(self)
		return self.data
	end,

	---Retrieves the frames contained within the scrollbox.
	---@param self df_scrollbox
	---@return table The frames contained within the scrollbox.
	GetFrames = function(self)
		return self.Frames
	end,

	---Retrieves the lines contained within the scrollbox.
	---This is an alias of GetFrames.
	---@param self df_scrollbox
	---@return table The lines contained within the scrollbox.
	GetLines = function(self)
		return self.Frames
	end,

	---Retrieves the number of frames created within the scrollbox.
	---@param self df_scrollbox
	---@return number The number of frames created within the scrollbox.
	GetNumFramesCreated = function(self)
		return #self.Frames
	end,

	---get the amount of lines the scroll is currently showing
	---@param self df_scrollbox
	---@return number amountOfLines
	GetNumFramesShown = function(self)
		return self.LineAmount
	end,

	---set the max amount of lines the scroll can show
	---@param self df_scrollbox
	---@param newAmount number
	SetNumFramesShown = function(self, newAmount)
		--hide frames which won't be used
		if (newAmount < #self.Frames) then
			for i = newAmount+1, #self.Frames do
				self.Frames[i]:Hide()
			end
		end
		--set the new amount
		self.LineAmount = newAmount
	end,

	SetFramesHeight = function(self, height)
		self.LineHeight = height
		self:OnSizeChanged()
		self:Refresh()
	end,

	OnSizeChanged = function(self)
		if (self.ReajustNumFrames) then
			--how many lines the scroll can show
			local amountOfFramesToShow = math.floor(self:GetHeight() / self.LineHeight)

			--how many lines the scroll already have
			local totalFramesCreated = self:GetNumFramesCreated()

			--how many lines are current shown
			local totalFramesShown = self:GetNumFramesShown()

			--the amount of frames increased
			if (amountOfFramesToShow > totalFramesShown) then
				for i = totalFramesShown+1, amountOfFramesToShow do
					--check if need to create a new line
					if (i > totalFramesCreated) then
						self:CreateLine(self.CreateLineFunc)
					end
				end

			--the amount of frames decreased
			elseif (amountOfFramesToShow < totalFramesShown) then
				--hide all frames above the new amount to show
				for i = totalFramesCreated, amountOfFramesToShow, -1 do
					if (self.Frames[i]) then
						self.Frames[i]:Hide()
					end
				end
			end

			--set the new amount of frames
			self:SetNumFramesShown(amountOfFramesToShow)
			--refresh lines
			self:Refresh()
		end
	end,

	--moved functions from blizzard faux scroll that are called from insecure code environment
	--this reduces the amount of taints while using the faux scroll frame
	GetOffsetFaux = function(self)
		return self.offset or 0
	end,

	OnVerticalScrollFaux = function(self, value, lineHeight, updateFunction)
		local scrollbar = self:GetChildFramesFaux()
		scrollbar:SetValue(value)
		self.offset = math.floor((value / lineHeight) + 0.5)

		if (updateFunction) then
			updateFunction(self)
		end
	end,

	GetChildFramesFaux = function(frame)
		local frameName = frame:GetName();
		if frameName then
			return _G[ frameName.."ScrollBar" ], _G[ frameName.."ScrollChildFrame" ], _G[ frameName.."ScrollBarScrollUpButton" ], _G[ frameName.."ScrollBarScrollDownButton" ];
		else
			return frame.ScrollBar, frame.ScrollChildFrame, frame.ScrollBar.ScrollUpButton, frame.ScrollBar.ScrollDownButton;
		end
	end,

	UpdateFaux = function(frame, numItems, numToDisplay, buttonHeight, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar)
		local scrollBar, scrollChildFrame, scrollUpButton, scrollDownButton = frame:GetChildFramesFaux();
		-- If more than one screen full of items then show the scrollbar
		local showScrollBar;
		if ( numItems > numToDisplay or alwaysShowScrollBar ) then
			frame:Show();
			showScrollBar = 1;
		else
			scrollBar:SetValue(0);
			frame:Hide();
		end
		if ( frame:IsShown() ) then
			local scrollFrameHeight = 0;
			local scrollChildHeight = 0;

			if ( numItems > 0 ) then
				scrollFrameHeight = (numItems - numToDisplay) * buttonHeight;
				scrollChildHeight = numItems * buttonHeight;
				if ( scrollFrameHeight < 0 ) then
					scrollFrameHeight = 0;
				end
				scrollChildFrame:Show();
			else
				scrollChildFrame:Hide();
			end
			local maxRange = (numItems - numToDisplay) * buttonHeight;
			if (maxRange < 0) then
				maxRange = 0;
			end
			scrollBar:SetMinMaxValues(0, maxRange);
			scrollBar:SetValueStep(buttonHeight);
			scrollBar:SetStepsPerPage(numToDisplay-1);
			scrollChildFrame:SetHeight(scrollChildHeight);

			-- Arrow button handling
			if ( scrollBar:GetValue() == 0 ) then
				scrollUpButton:Disable();
			else
				scrollUpButton:Enable();
			end
			if ((scrollBar:GetValue() - scrollFrameHeight) == 0) then
				scrollDownButton:Disable();
			else
				scrollDownButton:Enable();
			end

			-- Shrink because scrollbar is shown
			if ( highlightFrame ) then
				highlightFrame:SetWidth(smallHighlightWidth);
			end
			if ( button ) then
				for i=1, numToDisplay do
					_G[button..i]:SetWidth(smallWidth);
				end
			end
		else
			-- Widen because scrollbar is hidden
			if ( highlightFrame ) then
				highlightFrame:SetWidth(bigHighlightWidth);
			end
			if ( button ) then
				for i=1, numToDisplay do
					_G[button..i]:SetWidth(bigWidth);
				end
			end
		end

		return showScrollBar;
	end,
}


---@class df_gridscrollbox_options : table
---@field width number?
---@field height number?
---@field line_amount number?
---@field line_height number?
---@field columns_per_line number?
---@field auto_amount boolean?
---@field no_scroll boolean?
---@field vertical_padding number?
---@field no_backdrop boolean?

---@type df_gridscrollbox_options
local grid_scrollbox_options = {
	width = 600,
	height = 400,
	line_amount = 10,
	line_height = 30,
    columns_per_line = 4,
	no_scroll = false,
    vertical_padding = 1,
    no_backdrop = false,
}

---@class df_gridscrollbox : df_scrollbox
---@field RefreshMe fun(self:df_gridscrollbox)

---create a scrollbox with a grid layout
---@param parent frame
---@param name string
---@param refreshFunc fun(button:frame, data:table)
---@param data table
---@param createColumnFrameFunc fun(line:frame, lineIndex:number, columnIndex:number)
---@param options df_gridscrollbox_options?
---@return df_gridscrollbox
function detailsFramework:CreateGridScrollBox(parent, name, refreshFunc, data, createColumnFrameFunc, options)
    options = options or {}

	--check values passed, get defaults and cast values due to the scrollbox require some values to be numbers
	local width = type(options.width) == "number" and options.width or grid_scrollbox_options.width
	---@cast width number

	local height = type(options.height) == "number" and options.height or grid_scrollbox_options.height
	---@cast height number

	local lineAmount = type(options.line_amount) == "number" and options.line_amount or grid_scrollbox_options.line_amount
	---@cast lineAmount number

	local lineHeight = type(options.line_height) == "number" and options.line_height or grid_scrollbox_options.line_height
	---@cast lineHeight number

    local columnsPerLine = options.columns_per_line or grid_scrollbox_options.columns_per_line
	local autoAmount = options.auto_amount
	local noScroll = options.no_scroll
	local noBackdrop = options.no_backdrop
    local verticalPadding = options.vertical_padding or grid_scrollbox_options.vertical_padding

    local createLineFunc = function(scrollBox, lineIndex)
        local line = CreateFrame("frame", "$parentLine" .. lineIndex, scrollBox)
        line:SetSize(width, lineHeight)
        line:SetPoint("top", scrollBox, "top", 0, -((lineIndex-1) * (lineHeight + verticalPadding)))
        line.optionFrames = {}

        for columnIndex = 1, columnsPerLine do
            --dispatch payload: line, lineIndex, columnIndex
            local optionFrame = createColumnFrameFunc(line, lineIndex, columnIndex)
            line.optionFrames[columnIndex] = optionFrame
            optionFrame:SetPoint("left", line, "left", (columnIndex-1) * (width/columnsPerLine), 0)
        end

        return line
    end

    local onSetData = function(self, data)
		self.data_original = data
        local newData = {}

        for i = 1, #data, columnsPerLine do
            local thisColumnData = {}

            for o = 1, columnsPerLine do
                local index = i + (o-1)
                local thisData = data[index]
                if (thisData) then
                    thisColumnData[#thisColumnData+1] = thisData
                end
            end
            newData[#newData+1] = thisColumnData
        end

        self.data = newData
    end

    local refreshGrid = function(scrollBox, thisData, offset, totalLines)
        for i = 1, totalLines do
            local index = i + offset
            local lineData = thisData[index]

            if (lineData) then
                local line = scrollBox:GetLine(i)
                for o = 1, columnsPerLine do
                    local optionFrame = line.optionFrames[o]
                    local data = lineData[o]
                    if (data) then
                        detailsFramework:Dispatch(refreshFunc, optionFrame, data)
                        optionFrame:Show()
                        line:Show()
                    else
                        optionFrame:Hide()
                    end
                end
            end
        end
    end

    if (not name) then
        name = "DetailsFrameworkAuraScrollBox" .. math.random(1, 9999999)
    end

	local scrollBox = detailsFramework:CreateScrollBox(parent, name, refreshGrid, data, width, height, lineAmount, lineHeight, createLineFunc, autoAmount, noScroll, noBackdrop)
    scrollBox:CreateLines(createLineFunc, lineAmount)
    detailsFramework:ReskinSlider(scrollBox)
    scrollBox.OnSetData = onSetData
    onSetData(scrollBox, data)

	---@cast scrollBox df_gridscrollbox
	return scrollBox
end

---@class df_gridscrollbox_menu : df_gridscrollbox
---@field data_original table the data passed into :SetData()
---@field searchBox df_searchbox
---@field Select fun(self:df_gridscrollbox_menu, value:any, key:string) --select a line by a value on a key, example: :Select("Power Infusion", "spellName")

---create a scrollbox with a grid layout to be used as a menu
---@param parent frame
---@param name string?
---@param refreshMeFunc fun(gridScrollBox:df_gridscrollbox, searchText:string)
---@param refreshButtonFunc fun(button:button, data:table)
---@param clickFunc fun(button:button, data:table)
---@param onCreateButton fun(button:button, lineIndex:number, columnIndex:number)
---@param gridScrollBoxOptions df_gridscrollbox_options
---@return df_gridscrollbox_menu
function detailsFramework:CreateMenuWithGridScrollBox(parent, name, refreshMeFunc, refreshButtonFunc, clickFunc, onCreateButton, gridScrollBoxOptions)
	local dataSelected = nil
	local gridScrollBox

	local onClickButtonSelectorButton = function(blizzButton, buttonDown, dfButton, data)
		dataSelected = data
		gridScrollBox:Refresh()
		xpcall(clickFunc, geterrorhandler(), dfButton, data)
	end

    --create a search bar to filter the auras
    local searchText = ""
    local onSearchTextChangedCallback = function(self, ...)
        local text = self:GetText()
        searchText = string.lower(text)
        dataSelected = nil
        gridScrollBox:RefreshMe()
    end

	local searchBox = detailsFramework:CreateSearchBox(parent, onSearchTextChangedCallback)

	---when the scroll is refreshing the line, the line will call this function for each selection button on it
    ---@param button df_button
    ---@param data table
    local refreshLine = function(button, data)
        button.data = data

		if (data.tooltip) then
			button.tooltip = data.tooltip
		end

        --set what happen when the user clicks the button
        button:SetClickFunction(onClickButtonSelectorButton, button, data)

		if (button.data == dataSelected) then
			button.widget:SetBorderCornerColor(.9, .9, .9)
		else
			button.widget:SetBorderCornerColor(unpack(gridScrollBoxOptions.roundedFramePreset.border_color))
		end

		xpcall(refreshButtonFunc, geterrorhandler(), button, data)
    end

	--create a line
    local createButton = function(line, lineIndex, columnIndex)
        local width = gridScrollBoxOptions.width / gridScrollBoxOptions.columns_per_line - 5
        local height = gridScrollBoxOptions.line_height
        if (not height) then
            height = 30
        end

        local button = detailsFramework:CreateButton(line, onClickButtonSelectorButton, width, height)
        detailsFramework:AddRoundedCornersToFrame(button.widget, gridScrollBoxOptions.roundedFramePreset)
        button.textsize = 11

		line.button = button

        button:SetHook("OnEnter", function(self)
            local dfButton = self:GetObject()
            GameCooltip:Reset()
			if (dfButton.spellId) then
            	GameCooltip:SetSpellByID(dfButton.spellId)
				GameCooltip:SetOwner(self)
				GameCooltip:Show()
			end
            self:SetBorderCornerColor(.9, .9, .9)
        end)

        button:SetHook("OnLeave", function(self)
            GameCooltip:Hide()
            local dfButton = self:GetObject()
			if (dfButton.data == dataSelected) then
				self:SetBorderCornerColor(.9, .9, .9)
			else
            	self:SetBorderCornerColor(unpack(gridScrollBoxOptions.roundedFramePreset.border_color))
			end
        end)

		xpcall(onCreateButton, geterrorhandler(), button, lineIndex, columnIndex)

        return button
    end

    gridScrollBox = detailsFramework:CreateGridScrollBox(parent, name, refreshLine, {}, createButton, gridScrollBoxOptions)
	---@cast gridScrollBox df_gridscrollbox_menu

    gridScrollBox:SetBackdrop({})
    gridScrollBox:SetBackdropColor(0, 0, 0, 0)
    gridScrollBox:SetBackdropBorderColor(0, 0, 0, 0)
    gridScrollBox.__background:Hide()
    gridScrollBox:Show()

	gridScrollBox.searchBox = searchBox
	searchBox:SetPoint("bottomleft", gridScrollBox, "topleft", 0, 2)
	searchBox:SetWidth(gridScrollBoxOptions.width)

	function gridScrollBox:Select(value, key)
		local bFoundResult = false
		local originalData

		for _, data in ipairs(gridScrollBox.data_original) do
			originalData = data

			if (type(value) == string) then
				value = value:lower()
				local dataValue = data[key]:lower()
				if (dataValue == value) then
					dataSelected = originalData
					bFoundResult = true
					break
				end
			else
				if (data[key] == value) then
					dataSelected = originalData
					bFoundResult = true
					break
				end
			end
		end

		if (bFoundResult) then
			for _, line in ipairs(gridScrollBox:GetFrames()) do
				local button = line.button
				if (button.data == originalData) then
					gridScrollBox:Refresh()
					onClickButtonSelectorButton(nil, nil, button, originalData)
					break
				end
			end
		end
	end

	function gridScrollBox:RefreshMe()
		xpcall(refreshMeFunc, geterrorhandler(), gridScrollBox, searchBox:GetText())
	end

	return gridScrollBox
end

--Need to test this and check the "same_name_spells_add(value)" on the OnEnter function
--also need to make sure this can work with any data (global, class, spec) and aura type (buff, debuff)

--aura scroll box
---@class df_aurascrollbox_options : table
---@field line_height number?
---@field line_amount number?
---@field width number?
---@field height number?
---@field vertical_padding number?
---@field show_spell_tooltip boolean
---@field remove_icon_border boolean
---@field no_scroll boolean
---@field no_backdrop boolean
---@field backdrop_onenter number[]?
---@field backdrop_onleave number[]?
---@field font_size number?
---@field title_text string?

local auraScrollDefaultSettings = {
    line_height = 18,
    line_amount = 18,
	width = 300,
	height = 500,
    vertical_padding = 1,
    show_spell_tooltip = false,
    remove_icon_border = true,
	no_scroll = false,
    no_backdrop = false,
    backdrop_onenter = {.8, .8, .8, 0.4},
    backdrop_onleave = {.8, .8, .8, 0.2},
    font_size = 12,
	title_text = "",
}

---@param parent frame
---@param name string?
---@param data table? --can be set later with :SetData()
---@param onAuraRemoveCallback function?
---@param options df_aurascrollbox_options?
---@param onSetupAuraClick function?
function detailsFramework:CreateAuraScrollBox(parent, name, data, onAuraRemoveCallback, options, onSetupAuraClick)
    --hack the construction of the options table here, as the scrollbox is created much later
    options = options or {}
    local scrollOptions = {}
    detailsFramework.OptionsFunctions.BuildOptionsTable(scrollOptions, auraScrollDefaultSettings, options)
    options = scrollOptions.options

    local refreshAuraLines = function(self, data, offset, totalLines)
        for i = 1, totalLines do
            local index = i + offset
            local auraTable = data[index]
            if (auraTable) then
                local line = self:GetLine(i)
                local spellId, spellName, spellIcon, lowerSpellName, bAddedBySpellName = unpack(auraTable)

                line.SpellID = spellId
                line.SpellName = spellName
                line.SpellNameLower = lowerSpellName
                line.SpellIcon = spellIcon
                line.Flag = bAddedBySpellName

                if (bAddedBySpellName) then
                    line.name:SetText(spellName)
                else
                    line.name:SetText(spellName .. " (" .. spellId .. ")")
                end

                line.icon:SetTexture(spellIcon)
                if (options.remove_icon_border) then
                    line.icon:SetTexCoord(.1, .9, .1, .9)
                else
                    line.icon:SetTexCoord(0, 1, 0, 1)
                end
            end
        end
    end

    local onLeaveAuraLine = function(self)
        self:SetBackdropColor(unpack(options.backdrop_onleave))
        GameTooltip:Hide()
        GameCooltip:Hide()
    end

	local onEnterAuraLine = function(line)
        if (options.show_spell_tooltip and line.SpellID and GetSpellInfo(line.SpellID)) then
            GameTooltip:SetOwner(line, "ANCHOR_CURSOR")
            GameTooltip:SetSpellByID(line.SpellID)
            GameTooltip:AddLine(" ")
            GameTooltip:Show()
        end

		if (line.setupbutton:IsShown()) then
			
		end

        line:SetBackdropColor(unpack(options.backdrop_onenter))

		local bTrackByName = line.Flag --the user entered the spell name to track the spell (and not a spellId)
		local spellId = line.SpellID

		if (bTrackByName) then --the user entered the spell name to track the spell
			local spellsHashMap, spellsIndexTable, spellsWithSameName = detailsFramework:GetSpellCaches()
			if (spellsWithSameName) then
				local spellName, _, spellIcon = GetSpellInfo(spellId)
				if (spellName) then
					local spellNameLower = spellName:lower()
					local sameNameSpells = spellsWithSameName[spellNameLower]

					if (sameNameSpells) then
						GameCooltip:Preset(2)
						GameCooltip:SetOwner(line, "left", "right", 2, 0)
						GameCooltip:SetOption("TextSize", 10)

						for i, thisSpellId in ipairs(sameNameSpells) do
							GameCooltip:AddLine(spellName .. " (" .. thisSpellId .. ")")
							GameCooltip:AddIcon(spellIcon, 1, 1, 14, 14, .1, .9, .1, .9)
						end

						GameCooltip:Show()
					end
				end
			end

		else --the user entered the spellId to track the spell
			GameCooltip:Preset(2)
			GameCooltip:SetOwner(line, "left", "right", 2, 0)
			GameCooltip:SetOption("TextSize", 10)

			local spellName, _, spellIcon = GetSpellInfo(spellId)
			if (spellName) then
				GameCooltip:AddLine(spellName .. " (" .. spellId .. ")")
				GameCooltip:AddIcon(spellIcon, 1, 1, 14, 14, .1, .9, .1, .9)
			end
			GameCooltip:Show()
		end
	end

    local onClickAuraRemoveButton = function(self)
        local spellId = tonumber(self:GetParent().SpellID)
        if (spellId and type(spellId) == "number") then
            --button > line > scrollbox
            local scrollBox = self:GetParent():GetParent()
            scrollBox.data_original[spellId] = nil
            scrollBox.data_original["" .. (spellId or "")] = nil -- cleanup...

            scrollBox:TransformAuraData()
            scrollBox:Refresh()

            if (onAuraRemoveCallback) then --upvalue
                detailsFramework:QuickDispatch(onAuraRemoveCallback, spellId)
            end
        end
    end

    local createLineFunc = function(self, index)
        local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
        local scrollBoxWidth = options.width
        local lineHeight = options.line_height
        local verticalPadding = options.vertical_padding

        line:SetPoint("topleft", self, "topleft", 1, -((index-1) * (lineHeight + verticalPadding)) - 1)
        line:SetSize(scrollBoxWidth - 2, lineHeight)
        line:SetScript("OnEnter", onEnterAuraLine)
        line:SetScript("OnLeave", onLeaveAuraLine)

        line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        line:SetBackdropColor(unpack(options.backdrop_onleave))

        local iconTexture = line:CreateTexture("$parentIcon", "overlay")
        iconTexture:SetSize(lineHeight - 2, lineHeight - 2)

        local spellNameFontString = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
        detailsFramework:SetFontSize(spellNameFontString, options.font_size)

        local removeButton = CreateFrame("button", "$parentRemoveButton", line, "UIPanelCloseButton")
        removeButton:SetSize(16, 16)
        removeButton:SetScript("OnClick", onClickAuraRemoveButton)
        removeButton:SetPoint("topright", line, "topright", 0, 0)
        removeButton:GetNormalTexture():SetDesaturated(true)

		local setupAuraButton = CreateFrame("button", "$parentSetupButton", line)
		setupAuraButton:SetSize(16, 16)
		setupAuraButton:SetPoint("right", removeButton, "left", -4, 0)
		setupAuraButton:SetScript("OnClick", onSetupAuraClick)

		line:SetScript("OnMouseUp", function(self, button)
			if (onSetupAuraClick) then
				setupAuraButton:Click()
			end
		end)

		local clickToSetupText = setupAuraButton:CreateFontString("$parentText", "overlay", "GameFontNormal")
		clickToSetupText:SetText("click to setup")
		clickToSetupText:SetPoint("right", setupAuraButton, "left", -2, 0)
		detailsFramework:SetFontSize(clickToSetupText, 9)

		local setupAuraTexture = setupAuraButton:CreateTexture(nil, "overlay")
		setupAuraTexture:SetAllPoints()
		setupAuraTexture:SetTexture([[Interface\ICONS\INV_Misc_Wrench_01.blp]])
		setupAuraTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		setupAuraButton.Texture = setupAuraTexture
		setupAuraButton.Text = clickToSetupText

		if (not onSetupAuraClick) then
			setupAuraButton:Hide()
		end

        iconTexture:SetPoint("left", line, "left", 2, 0)
        spellNameFontString:SetPoint("left", iconTexture, "right", 3, 0)

        line.icon = iconTexture
        line.name = spellNameFontString
        line.removebutton = removeButton
		line.setupbutton = setupAuraButton
		line.clicktosetuptext = clickToSetupText

        return line
    end

    ---@class df_aurascrollbox : df_scrollbox
    ---@field data_original table
    ---@field refresh_original function
	---@field TitleLabel fontstring
    ---@field TransformAuraData fun(self:df_aurascrollbox)
	---@field GetTitleFontString fun(self:df_aurascrollbox): fontstring

    data = data or {}

    if (not name) then
        name = "DetailsFrameworkAuraScrollBox" .. math.random(1, 9999999)
    end

    local auraScrollBox = detailsFramework:CreateScrollBox(parent, name, refreshAuraLines, data, options.width, options.height, options.line_amount, options.line_height)
    detailsFramework:ReskinSlider(auraScrollBox)
    ---@cast auraScrollBox df_aurascrollbox
    auraScrollBox.data_original = data

	local titleLabel = auraScrollBox:CreateFontString("$parentTitleLabel", "overlay", "GameFontNormal")
	titleLabel:SetPoint("bottomleft", auraScrollBox, "topleft", 0, 2)
	detailsFramework:SetFontColor(titleLabel, "silver")
	detailsFramework:SetFontSize(titleLabel, 10)
	auraScrollBox.TitleLabel = titleLabel

	function auraScrollBox:GetTitleFontString()
		return self.TitleLabel
	end

	for i = 1, options.line_amount do
		auraScrollBox:CreateLine(createLineFunc)
	end

    function auraScrollBox:TransformAuraData()
        local newData = {}
        local added = {}

        for spellId, bAddedBySpellName in pairs(self.data_original) do
            local spellName, _, spellIcon = GetSpellInfo(spellId)
            if (spellName and not added[tonumber(spellId) or 0]) then
                local lowerSpellName = spellName:lower()
                table.insert(newData, {spellId, spellName, spellIcon, lowerSpellName, bAddedBySpellName})
                added[tonumber(spellId) or 0] = true
            end
        end

        table.sort(newData, function(t1, t2) return t1[4] < t2[4] end)
        self.data = newData
    end

    auraScrollBox.SetData = function(self, data)
        self.data_original = data
        self.data = data
        auraScrollBox:TransformAuraData()
    end

    auraScrollBox.GetData = function(self)
        return self.data_original
    end

	auraScrollBox.refresh_original = auraScrollBox.Refresh

	auraScrollBox.Refresh = function()
		auraScrollBox:TransformAuraData()
		auraScrollBox:refresh_original()
	end

    auraScrollBox:SetData(data)

    return auraScrollBox
end


detailsFramework.CanvasScrollBoxMixin = {
	SetScrollSpeed = function(self, speed)
		assert(type(speed) == "number", "CanvasScrollBox:SetScrollSpeed(speed): speed must be a number.")
		self.scrollStep = speed
	end,

	GetScrollSpeed = function(self)
		return self.scrollStep
	end,

	OnVerticalScroll = function(self, delta)
		local scrollStep = self:GetScrollSpeed()
		if (delta > 0) then
			self:SetVerticalScroll(math.max(self:GetVerticalScroll() - scrollStep, 0))
		else
			self:SetVerticalScroll(math.min(self:GetVerticalScroll() + scrollStep, self:GetVerticalScrollRange()))
		end
	end,
}

local canvasScrollBoxDefaultOptions = {
	width = 600,
	height = 400,
	reskin_slider = true,
}

---@class df_canvasscrollbox : scrollframe, df_optionsmixin
---@field child frame

---@param parent frame
---@param child frame?
---@param name string?
---@param options table?
---@return df_canvasscrollbox
function detailsFramework:CreateCanvasScrollBox(parent, child, name, options)
	---@type df_canvasscrollbox
	local canvasScrollBox = CreateFrame("scrollframe", name or ("DetailsFrameworkCanvasScroll" .. math.random(50000, 10000000)), parent, "BackdropTemplate, UIPanelScrollFrameTemplate")
	canvasScrollBox.scrollStep = 20
	canvasScrollBox.minValue = 0

	canvasScrollBox:SetScript("OnMouseWheel", detailsFramework.CanvasScrollBoxMixin.OnVerticalScroll)

	detailsFramework:Mixin(canvasScrollBox, detailsFramework.CanvasScrollBoxMixin)
	detailsFramework:Mixin(canvasScrollBox, detailsFramework.OptionsFunctions)

    options = options or {}
    canvasScrollBox:BuildOptionsTable(canvasScrollBoxDefaultOptions, options)

	canvasScrollBox:SetSize(canvasScrollBox.options.width, canvasScrollBox.options.height)

	if (not child) then
		child = CreateFrame("frame", "$parentChild", canvasScrollBox)
	end

	canvasScrollBox:SetScrollChild(child)
	canvasScrollBox:EnableMouseWheel(true)

	canvasScrollBox.child = child

	if (canvasScrollBox.options.reskin_slider) then
		detailsFramework:ReskinSlider(canvasScrollBox)
	end

	return canvasScrollBox
end