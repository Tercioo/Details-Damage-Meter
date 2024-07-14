
local detailsFramework = DetailsFramework

if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local unpack = unpack
local CreateFrame = CreateFrame
local geterrorhandler = geterrorhandler
local wipe = wipe

--definitions

---@class df_headercolumndata : table
---@field key string?
---@field name string?
---@field icon string?
---@field texcoord table?
---@field text string?
---@field canSort boolean?
---@field selected boolean?
---@field width number?
---@field height number?
---@field align string?
---@field offset number?

---@class df_headerchild : uiobject
---@field FramesToAlign table

---@class df_headerframe : frame, df_headermixin, df_optionsmixin
---@field columnHeadersCreated df_headercolumnframe[]
---@field options table
---@field HeaderTable df_headercolumndata[]
---@field columnSelected number

---@class df_headermixin : table
---@field NextHeader number
---@field HeaderWidth number
---@field HeaderHeight number
---@field OnColumnSettingChangeCallback function
---@field GetColumnWidth fun(self: df_headerframe, columnId: number) : number
---@field SetHeaderTable fun(self: df_headerframe, table)
---@field GetSelectedColumn fun(self: df_headerframe) : number, string, string, string
---@field Refresh fun(self: df_headerframe)
---@field UpdateSortArrow fun(self: df_headerframe, columnHeader: df_headercolumnframe, defaultShown: boolean|nil, defaultOrder: string|nil)
---@field UpdateColumnHeader fun(self: df_headerframe, columnHeader: df_headercolumnframe, headerIndex)
---@field ResetColumnHeaderBackdrop fun(self: df_headerframe, columnHeader: df_headercolumnframe)
---@field SetBackdropColorForSelectedColumnHeader fun(self: df_headerframe, columnHeader: df_headercolumnframe)
---@field ClearColumnHeader fun(self: df_headerframe, columnHeader: df_headercolumnframe)
---@field GetNextHeader fun(self: df_headerframe) : df_headercolumnframe
---@field SetColumnSettingChangedCallback fun(self: df_headerframe, func: function) : boolean

---@class df_headercolumnframe : button
---@field Icon texture
---@field Text fontstring
---@field Arrow texture
---@field Separator texture
---@field resizerButton df_headerresizer
---@field bIsRezising boolean
---@field bInUse boolean
---@field columnData table
---@field order string
---@field columnIndex number
---@field columnAlign string
---@field XPosition number
---@field columnOffset number
---@field key string used to sort the values

---@class df_headerresizer : button
---@field texture texture

--mixed functions
---@class df_headerfunctions : table
detailsFramework.HeaderFunctions = {
    ---comment
    ---@param self df_headerchild
    ---@param frame uiobject
	AddFrameToHeaderAlignment = function(self, frame)
		self.FramesToAlign = self.FramesToAlign or {}
		table.insert(self.FramesToAlign, frame)
	end,

    ---comment
    ---@param self df_headerchild
	ResetFramesToHeaderAlignment = function(self)
		wipe(self.FramesToAlign)
	end,

	SetFramesToHeaderAlignment = function(self, ...)
        ---@cast self df_headerchild
		wipe(self.FramesToAlign)
		self.FramesToAlign = {...}
	end,

	GetFramesFromHeaderAlignment = function(self, frame)
		return self.FramesToAlign or {}
	end,

	---@param self uiobject
	---@param headerFrame df_headerframe
	---@param anchor string
	AlignWithHeader = function(self, headerFrame, anchor)
		local columnHeaderFrames = headerFrame.columnHeadersCreated
		anchor = anchor or "topleft"

        ---@cast self df_headerchild

		for i = 1, #self.FramesToAlign do
			---@type uiobject
			local uiObject = self.FramesToAlign[i]
			uiObject:ClearAllPoints()

			---@type df_headercolumnframe
			local columnHeader = columnHeaderFrames[i]
			if (columnHeader) then
				local offset = 0

				if (columnHeader.columnAlign == "right") then
					offset = columnHeader:GetWidth()
				end

				if (uiObject:GetObjectType() == "FontString") then
					---@cast uiObject fontstring
					if (columnHeader.columnAlign == "right") then
						uiObject:SetJustifyH("right")
					elseif (columnHeader.columnAlign == "left") then
						uiObject:SetJustifyH("left")
					elseif (columnHeader.columnAlign == "center") then
						uiObject:SetJustifyH("center")
					end
				end

				uiObject:SetPoint(columnHeader.columnAlign, self, anchor, columnHeader.XPosition + columnHeader.columnOffset + offset, 0)
			end
		end
	end,

	---comment
	---@param columnHeader df_headercolumnframe
	---@param buttonClicked string
	OnClick = function(columnHeader, buttonClicked)
		--get the header main frame
		local headerFrame = columnHeader:GetParent()
		---@cast headerFrame df_headerframe

		--if this header does not have a clickable header, just ignore
		if (not headerFrame.columnSelected) then
			return
		end

		--check if this column has 'canSort' key, otherwise ignore the click
		if (not columnHeader.columnData.canSort) then
			return
		end

		--get the latest column header selected
		---@type df_headercolumnframe
		local previousColumnHeader = headerFrame.columnHeadersCreated[headerFrame.columnSelected]
		previousColumnHeader.Arrow:Hide()
		headerFrame:ResetColumnHeaderBackdrop(previousColumnHeader)
		headerFrame:SetBackdropColorForSelectedColumnHeader(columnHeader)

		if (headerFrame.columnSelected == columnHeader.columnIndex) then
			columnHeader.order = columnHeader.order ~= "ASC" and "ASC" or "DESC"
		end
		headerFrame.columnOrder = columnHeader.order

		--set the new column header selected
		headerFrame.columnSelected = columnHeader.columnIndex

		headerFrame:UpdateSortArrow(columnHeader)

		if (headerFrame.options.header_click_callback) then
			--callback with the main header frame, column header, column index and column order as payload
			local okay, errortext = pcall(headerFrame.options.header_click_callback, headerFrame, columnHeader, columnHeader.columnIndex, columnHeader.order)
			if (not okay) then
				print("DF: Header onClick callback error:", errortext)
			end
		end
	end,

	---comment
	---@param self button
	---@param buttonClicked string
	OnMouseDown = function(self, buttonClicked)
		if (buttonClicked == "LeftButton") then

		end
	end,

	---comment
	---@param self button
	---@param buttonClicked string
	OnMouseUp = function(self, buttonClicked)
		if (buttonClicked == "LeftButton") then

		end
	end,
}

---@class df_headermixin : table
detailsFramework.HeaderMixin = {
	---@param self df_headerframe
	---@param columnId number
	---@return number
	GetColumnWidth = function(self, columnId)
		return self.HeaderTable[columnId].width
	end,

	---@param self df_headerframe
	---@param newTable table
	SetHeaderTable = function(self, newTable)
		self.columnHeadersCreated = self.columnHeadersCreated or {}
		self.HeaderTable = newTable
		self.NextHeader = 1
		self.HeaderWidth = 0
		self.HeaderHeight = 0
		self:Refresh()
	end,

	---@param self df_headerframe
	---@param func function
	---@return boolean
	SetColumnSettingChangedCallback = function(self, func)
		if (type(func) ~= "function") then
			self.OnColumnSettingChangeCallback = nil
			return false
		end
		self.OnColumnSettingChangeCallback = func
		return true
	end,

	--return which header is current selected and the the order ASC DESC
	---@param self df_headerframe
	---@return number, string, string, string
	GetSelectedColumn = function(self)
		---@type number
		local columnSelected = self.columnSelected
		---@type df_headercolumnframe
		local columnHeader = self.columnHeadersCreated[columnSelected or 1]
		return columnSelected, columnHeader.order, columnHeader.key, columnHeader.columnData.name
	end,

	--clean up and rebuild the header following the header options
	--@self: main header frame
	---@param self df_headerframe
	Refresh = function(self)
		--refresh background frame
		self:SetBackdrop(self.options.backdrop)
		self:SetBackdropColor(unpack(self.options.backdrop_color))
		self:SetBackdropBorderColor(unpack(self.options.backdrop_border_color))

		--reset all header frames
		for i = 1, #self.columnHeadersCreated do
			local columnHeader = self.columnHeadersCreated[i]
			columnHeader.bInUse = false
			columnHeader:Hide()
		end

		local previousColumnHeader
		local growDirection = string.lower(self.options.grow_direction)

		--amount of headers to be updated
		local headerSize = #self.HeaderTable

		--update header frames
		for i = 1, headerSize do
			--get the header button, a new one is created if it doesn't exists yet
			local columnHeader = self:GetNextHeader()
			self:UpdateColumnHeader(columnHeader, i)

			--grow direction
			if (not previousColumnHeader) then
				columnHeader:SetPoint("topleft", self, "topleft", 0, 0)

				if (growDirection == "right") then
					if (self.options.use_line_separators) then
						columnHeader.Separator:Show()
						columnHeader.Separator:SetWidth(self.options.line_separator_width)
						columnHeader.Separator:SetColorTexture(unpack(self.options.line_separator_color))

						columnHeader.Separator:ClearAllPoints()
						if (self.options.line_separator_gap_align) then
							columnHeader.Separator:SetPoint("topleft", columnHeader, "topright", 0, 0)
						else
							columnHeader.Separator:SetPoint("topright", columnHeader, "topright", 0, 0)
						end
						columnHeader.Separator:SetHeight(self.options.line_separator_height)
					end
				end
			else
				if (growDirection == "right") then
					columnHeader:SetPoint("topleft", previousColumnHeader, "topright", self.options.padding, 0)

					if (self.options.use_line_separators) then
						columnHeader.Separator:Show()
						columnHeader.Separator:SetWidth(self.options.line_separator_width)
						columnHeader.Separator:SetColorTexture(unpack(self.options.line_separator_color))

						columnHeader.Separator:ClearAllPoints()
						if (self.options.line_separator_gap_align) then
							columnHeader.Separator:SetPoint("topleft", columnHeader, "topright", 0, 0)
						else
							columnHeader.Separator:SetPoint("topleft", columnHeader, "topright", 0, 0)
						end
						columnHeader.Separator:SetHeight(self.options.line_separator_height)

						if (headerSize == i) then
							columnHeader.Separator:Hide()
						end
					end

				elseif (growDirection == "left") then
					columnHeader:SetPoint("topright", previousColumnHeader, "topleft", -self.options.padding, 0)

				elseif (growDirection == "bottom") then
					columnHeader:SetPoint("topleft", previousColumnHeader, "bottomleft", 0, -self.options.padding)

				elseif (growDirection == "top") then
					columnHeader:SetPoint("bottomleft", previousColumnHeader, "topleft", 0, self.options.padding)
				end
			end

			previousColumnHeader = columnHeader
		end

		self:SetSize(self.HeaderWidth, self.HeaderHeight)
	end,

	---@param self df_headerframe
	---@param columnHeader df_headercolumnframe
	---@param defaultShown boolean
	---@param defaultOrder string
	UpdateSortArrow = function(self, columnHeader, defaultShown, defaultOrder)
		local options = self.options
		local order = defaultOrder or columnHeader.order
		local arrowIcon = columnHeader.Arrow

		if (type(defaultShown) ~= "boolean") then
			arrowIcon:Show()
		else
			arrowIcon:SetShown(defaultShown)
			if (defaultShown) then
				self:SetBackdropColorForSelectedColumnHeader(columnHeader)
			end
		end

		arrowIcon:SetAlpha(options.arrow_alpha)

		if (order == "ASC") then
			arrowIcon:SetTexture(options.arrow_up_texture)
			arrowIcon:SetTexCoord(unpack(options.arrow_up_texture_coords))
			arrowIcon:SetSize(unpack(options.arrow_up_size))

		elseif (order == "DESC") then
			arrowIcon:SetTexture(options.arrow_down_texture)
			arrowIcon:SetTexCoord(unpack(options.arrow_down_texture_coords))
			arrowIcon:SetSize(unpack(options.arrow_down_size))
		end
	end,

	---@param self df_headerframe
	---@param columnHeader df_headercolumnframe
	---@param headerIndex number
	UpdateColumnHeader = function(self, columnHeader, headerIndex)
		--this is the data to update the columnHeader
		local columnData = self.HeaderTable[headerIndex]
		columnHeader.key = columnData.key or "total"

		if (columnData.icon) then
			columnHeader.Icon:SetTexture(columnData.icon)

			if (columnData.texcoord) then
				columnHeader.Icon:SetTexCoord(unpack(columnData.texcoord))
			else
				columnHeader.Icon:SetTexCoord(0, 1, 0, 1)
			end

			columnHeader.Icon:SetPoint("left", columnHeader, "left", self.options.padding, 0)
			columnHeader.Icon:Show()
		end

		if (columnData.text) then
			columnHeader.Text:SetText(columnData.text)

			--text options
			detailsFramework:SetFontColor(columnHeader.Text, self.options.text_color)
			detailsFramework:SetFontSize(columnHeader.Text, self.options.text_size)
			detailsFramework:SetFontOutline(columnHeader.Text, self.options.text_shadow)

			--point
			if (not columnData.icon) then
				columnHeader.Text:SetPoint("left", columnHeader, "left", self.options.padding, 0)
			else
				columnHeader.Text:SetPoint("left", columnHeader.Icon, "right", self.options.padding, 0)
			end

			columnHeader.Text:Show()
		end

		--column header index
		columnHeader.columnIndex = headerIndex

		if (columnData.canSort) then
			columnHeader.order = "DESC"
			columnHeader.Arrow:SetTexture(self.options.arrow_up_texture)
		else
			columnHeader.Arrow:Hide()
		end

		if (columnData.selected) then
			columnHeader.Arrow:Show()
			columnHeader.Arrow:SetAlpha(.843)
			self:UpdateSortArrow(columnHeader, true, columnHeader.order)
			self.columnSelected = headerIndex
		else
			if (columnData.canSort) then
				self:UpdateSortArrow(columnHeader, false, columnHeader.order)
			end
		end

		--size
		if (columnData.width) then
			columnHeader:SetWidth(columnData.width)
		end
		if (columnData.height) then
			columnHeader:SetHeight(columnData.height)
		end

		columnHeader.XPosition = self.HeaderWidth -- + self.options.padding
		columnHeader.YPosition = self.HeaderHeight -- + self.options.padding
		
		columnHeader.columnAlign = columnData.align or "left"
		columnHeader.columnOffset = columnData.offset or 0

		--add the header piece size to the total header size
		local growDirection = string.lower(self.options.grow_direction)

		if (growDirection == "right" or growDirection == "left") then
			self.HeaderWidth = self.HeaderWidth + columnHeader:GetWidth() + self.options.padding
			self.HeaderHeight = math.max(self.HeaderHeight, columnHeader:GetHeight())

		elseif (growDirection == "top" or growDirection == "bottom") then
			self.HeaderWidth =  math.max(self.HeaderWidth, columnHeader:GetWidth())
			self.HeaderHeight = self.HeaderHeight + columnHeader:GetHeight() + self.options.padding
		end

		local bShowColumnHeaderReziser = self.options.reziser_shown
		if (bShowColumnHeaderReziser) then
			local resizerButton = columnHeader.resizerButton
			resizerButton:Show()
			resizerButton.texture:SetVertexColor(unpack(self.options.reziser_color))
			resizerButton:SetWidth(self.options.reziser_width)
			resizerButton:SetHeight(columnHeader:GetHeight())
		else
			columnHeader.resizerButton:Hide()
		end

		columnHeader:Show()
		columnHeader.bInUse = true
		columnHeader.columnData = columnData
	end,

	---reset column header backdrop
	---@param self df_headerframe
	---@param columnHeader df_headercolumnframe
	ResetColumnHeaderBackdrop = function(self, columnHeader)
		columnHeader:SetBackdrop(self.options.header_backdrop)
		columnHeader:SetBackdropColor(unpack(self.options.header_backdrop_color))
		columnHeader:SetBackdropBorderColor(unpack(self.options.header_backdrop_border_color))
	end,

	---@param self df_headerframe
	---@param columnHeader df_headercolumnframe
	SetBackdropColorForSelectedColumnHeader = function(self, columnHeader)
		columnHeader:SetBackdropColor(unpack(self.options.header_backdrop_color_selected))
	end,

	---clear the column header
	---@param self df_headerframe
	---@param columnHeader df_headercolumnframe
	ClearColumnHeader = function(self, columnHeader)
		columnHeader:SetSize(self.options.header_width, self.options.header_height)
		self:ResetColumnHeaderBackdrop(columnHeader)

		columnHeader:ClearAllPoints()

		columnHeader.Icon:SetTexture("")
		columnHeader.Icon:Hide()
		columnHeader.Text:SetText("")
		columnHeader.Text:Hide()
	end,

	---get the next column header, create one if doesn't exists
	---@param self df_headerframe
	GetNextHeader = function(self)
		local nextHeader = self.NextHeader
		local columnHeader = self.columnHeadersCreated[nextHeader]

		if (not columnHeader) then
			--create a new column header
			---@type df_headercolumnframe
			columnHeader = CreateFrame("button", "$parentHeaderIndex" .. nextHeader, self, "BackdropTemplate")
			columnHeader:SetScript("OnClick", detailsFramework.HeaderFunctions.OnClick)
			columnHeader:SetMovable(true)
			columnHeader:SetResizable(true)

			--header icon
			detailsFramework:CreateImage(columnHeader, "", self.options.header_height, self.options.header_height, "ARTWORK", nil, "Icon", "$parentIcon")
			--header separator
			detailsFramework:CreateImage(columnHeader, "", 1, 1, "ARTWORK", nil, "Separator", "$parentSeparator")
			--header name text
			detailsFramework:CreateLabel(columnHeader, "", self.options.text_size, self.options.text_color, "GameFontNormal", "Text", "$parentText", "ARTWORK")
			--header selected and order icon
			detailsFramework:CreateImage(columnHeader, self.options.arrow_up_texture, 12, 12, "ARTWORK", nil, "Arrow", "$parentArrow")

			---rezise button
			---@type df_headerresizer
			local resizerButton = CreateFrame("button", "$parentResizer", columnHeader)
			resizerButton:SetWidth(4)
			resizerButton:SetFrameLevel(columnHeader:GetFrameLevel()+2)
			resizerButton:SetPoint("topright", columnHeader, "topright", -1, -1)
			resizerButton:SetPoint("bottomright", columnHeader, "bottomright", -1, 1)
			resizerButton:EnableMouse(true)
			resizerButton:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
			columnHeader.resizerButton = resizerButton

			resizerButton:SetScript("OnEnter", function()
				resizerButton.texture:SetVertexColor(1, 1, 1, 0.9)
			end)

			resizerButton:SetScript("OnLeave", function()
				resizerButton.texture:SetVertexColor(unpack(self.options.reziser_color))
			end)

			resizerButton:SetScript("OnMouseDown", function() --move this to a single function
				if (not columnHeader.bIsRezising) then
					--get the string length to know the min size
					local textLength = columnHeader.Text:GetStringWidth() + 6
					columnHeader:SetResizeBounds(math.max(textLength, self.options.reziser_min_width), columnHeader:GetHeight(), self.options.reziser_max_width, columnHeader:GetHeight())
					columnHeader.bIsRezising = true
					columnHeader:StartSizing("right")
				end
			end)

			resizerButton:SetScript("OnMouseUp", function()
				if (columnHeader.bIsRezising) then
					columnHeader.bIsRezising = false
					columnHeader:StopMovingOrSizing()

					--callback or modify into a passed by table?
					if (self.OnColumnSettingChangeCallback) then --need to get the header name
						local columnName = columnHeader.columnData.name
						xpcall(self.OnColumnSettingChangeCallback, geterrorhandler(), self, "width", columnName, columnHeader:GetWidth())
					end
				end
			end)

			resizerButton:SetScript("OnHide", function()
				if (columnHeader.bIsRezising) then
					columnHeader:StopMovingOrSizing()
					columnHeader.bIsRezising = false
				end
			end)

			resizerButton.texture = resizerButton:CreateTexture(nil, "overlay")
			resizerButton.texture:SetAllPoints()
			resizerButton.texture:SetColorTexture(1, 1, 1, 1)

			local xOffset = self.options.reziser_shown and -5 or -1
			columnHeader.Arrow:SetPoint("right", columnHeader, "right", xOffset, 0)

			columnHeader.Separator:Hide()
			columnHeader.Arrow:Hide()

			self:UpdateSortArrow(columnHeader, false, "DESC")

			table.insert(self.columnHeadersCreated, columnHeader)
			columnHeader = columnHeader
		end

		self:ClearColumnHeader(columnHeader)
		self.NextHeader = self.NextHeader + 1
		return columnHeader
	end,

	---return a header button by passing its name (.name on the column table)
	---@param self df_headerframe
	---@param columnName string
	---@return df_headercolumnframe|nil
	GetHeaderColumnByName = function(self, columnName)
		for _, headerColumnFrame in ipairs(self.columnHeadersCreated) do
			if (headerColumnFrame.columnData.name == columnName) then
				return headerColumnFrame
			end
		end
	end,

	NextHeader = 1,
	HeaderWidth = 0,
	HeaderHeight = 0,
}

--default options
local default_header_options = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdrop_color = {0, 0, 0, 0.2},
	backdrop_border_color = {0.1, 0.1, 0.1, .2},

	text_color = {1, 1, 1, 1},
	text_size = 10,
	text_shadow = false,
	grow_direction = "RIGHT",
	padding = 2,

	reziser_shown = false, --make sure to set the callback function with: header:SetOnColumnResizeScript(callbackFunction)
	reziser_width = 2,
	reziser_color = {1, 0.6, 0, 0.6},
	reziser_min_width = 16,
	reziser_max_width = 200,

	--each piece of the header
	header_backdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	header_backdrop_color = {0, 0, 0, 0.5},
	header_backdrop_color_selected = {0.3, 0.3, 0.3, 0.5},
	header_backdrop_border_color = {0, 0, 0, 0},
	header_width = 120,
	header_height = 20,

	arrow_up_texture = [[Interface\Buttons\Arrow-Up-Down]],
	arrow_up_texture_coords = {0, 1, 6/16, 1},
	arrow_up_size = {12, 11},
	arrow_down_texture = [[Interface\Buttons\Arrow-Down-Down]],
	arrow_down_texture_coords = {0, 1, 0, 11/16},
	arrow_down_size = {12, 11},
	arrow_alpha = 0.659,

	use_line_separators = false,
	line_separator_color = {.1, .1, .1, .6},
	line_separator_width = 1,
	line_separator_height = 200,
	line_separator_gap_align = false,
}

---create a df_headerframe, alias 'header'.
---a header is a frame that can hold multiple columns which are also frames, each column is a df_headercolumnframe, these columns are arranged in horizontal form.
---a header is used to organize columns giving them a name/title, a way to sort and align them.
---each column is placed on the right side of the previous column.
---@param parent frame
---@param headerTable df_headercolumndata[]
---@param options table?
---@param frameName string?
---@return df_headerframe
function detailsFramework:CreateHeader(parent, headerTable, options, frameName)
	---create the header frame which is returned by this function
	---@type df_headerframe
	local newHeader = CreateFrame("frame", frameName or "$parentHeaderLine", parent, "BackdropTemplate")

	detailsFramework:Mixin(newHeader, detailsFramework.OptionsFunctions)
	detailsFramework:Mixin(newHeader, detailsFramework.HeaderMixin)

	options = options or {}
	newHeader:BuildOptionsTable(default_header_options, options)

	--set the backdrop and backdrop color following the values in the options table
	newHeader:SetBackdrop(newHeader.options.backdrop)
	newHeader:SetBackdropColor(unpack(newHeader.options.backdrop_color))
	newHeader:SetBackdropBorderColor(unpack(newHeader.options.backdrop_border_color))

	newHeader:SetHeaderTable(headerTable)

	return newHeader
end


--[=[example:
C_Timer.After(1, function()


	local parent = UIParent

	--declare the columns the headerFrame will have
	---@type df_headercolumndata[]
	local headerTable = {
		{name = "playername", text = "Player Name", width = 120, align = "left", canSort = true},
		{name = "damage", text = "Damage Done", width = 80, align = "right", canSort = true},
		{name = "points", text = "Total Points", width = 80, align = "right", canSort = false},
	}
	local frameName = "MyAddOnOptionsFrame"
	local options = {}

	local headerFrame = DetailsFramework:CreateHeader(parent, headerTable, options, frameName)
	headerFrame:SetPoint("center", parent, "center", 10, -10)


end)
--]=]