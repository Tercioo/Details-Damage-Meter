
---@type detailsframework
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
--lua locals
local unpack = table.unpack or unpack --lua local
local CreateFrame = CreateFrame

local PixelUtil = PixelUtil or DFPixelUtil

---@alias timelinecomponenttype
---| "line"
---| "block"
---| "length"
---| "header"
---| "timeline"
---| "body"

---@class df_timeline_options : table
---@field width number
---@field height number
---@field can_resize boolean
---@field line_height number
---@field line_padding number
---@field show_elapsed_timeline boolean
---@field elapsed_timeline_height number
---@field header_width number
---@field header_detached boolean if true the frameCanvas will have .headerFrame
---@field pixels_per_second number
---@field scale_min number
---@field scale_max number
---@field zoom_out_zero boolean if true, when the scale is reduced by mouse wheel, it will be set to 0
---@field use_perpixel_buttons boolean
---@field backdrop backdrop
---@field backdrop_color number[]
---@field backdrop_color_highlight number[]
---@field backdrop_border_color number[]
---@field slider_backdrop backdrop
---@field slider_backdrop_color number[]
---@field slider_backdrop_border_color number[]
---@field title_template string "ORANGE_FONT_TEMPLATE"
---@field text_tempate string "OPTIONS_FONT_TEMPLATE"
---@field on_enter fun(self:df_timeline_line) --line
---@field on_leave fun(self:df_timeline_line) --line
---@field on_create_line fun(self:df_timeline_line) --line
---@field on_refresh_line fun(self:df_timeline_line) --line
---@field block_on_enter fun(self:button)
---@field block_on_leave fun(self:button)
---@field block_on_click fun(self:button)
---@field block_on_create fun(self:df_timeline_line_block)
---@field block_on_set_data fun(self:button, data:table)
---@field block_on_create_auralength fun(self:df_timeline_line_block)
---@field block_on_create_blocklength fun(self:df_timeline_line_block)
---@field block_on_enter_auralength fun(self:df_timeline_line_block)
---@field block_on_leave_auralength fun(self:df_timeline_line_block)
---@field block_on_click_auralength fun(self:df_timeline_line_block, button:string)
---@field block_on_enter_blocklength fun(self:df_timeline_line_block)
---@field block_on_leave_blocklength fun(self:df_timeline_line_block)
---@field block_on_click_blocklength fun(self:df_timeline_line_block, button:string)
local timeline_options = {
	width = 400,
	height = 700,
	line_height = 20,
	line_padding = 1,
	auto_height = false, --set the timeline height to the amount of lines it has

	show_elapsed_timeline = true,
	elapsed_timeline_height = 20,

	--space to put the player/spell name and icons
	header_width = 150,
	header_detached = false,

	--how many pixels will be use to represent 1 second
	pixels_per_second = 20,
	use_perpixel_buttons = false,

	scale_min = 0.15,
	scale_max = 1,
	zoom_out_zero = false,

	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdrop_color = {0, 0, 0, 0.2},
	backdrop_color_highlight = {.2, .2, .2, 0.4},
	backdrop_border_color = {0.1, 0.1, 0.1, .2},

	slider_backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	slider_backdrop_color = {0, 0, 0, 0.2},
	slider_backdrop_border_color = {0.1, 0.1, 0.1, .2},

	title_template = "ORANGE_FONT_TEMPLATE",
	text_tempate = "OPTIONS_FONT_TEMPLATE",

	---@param self df_timeline_line
	on_enter = function(self)
		self:SetBackdropColor(unpack(self.backdrop_color_highlight))
	end,
	on_leave = function(self)
		self:SetBackdropColor(unpack(self.backdrop_color))
	end,

--	block_on_enter = function(self)
--	end,
--	block_on_leave = function(self)
--	end,
--	block_on_click = function(self)
--	end,
--	block_on_set_data = function(self, data)
--	end,
--	block_on_enter_auralength = function()
--	end,
--	block_on_leave_auralength = function()
--	end,
}

---@class df_timeline_block_data : table
---@field [1] number timeInSeconds
---@field [2] number length
---@field [3] boolean? isAura
---@field [4] number? auraDuration
---@field [5] number? blockSpellId
---@field payload any
---@field customIcon any
---@field customName any
---@field isIconRow boolean?
---@field showRightIcon boolean?
---@field blockLengthHeight number? --need to remove
---@field blockLengthYOffset number? --need to remove
---@field auraLengthColor any
---@field auraLengthTexture any
---@field auraHeight number?
---@field auraYOffset number?

---@class df_timeline_linedata : table
---@field spellId number
---@field icon any
---@field coords number[]?
---@field text string?
---@field timeline df_timeline_block_data[]
---@field lineHeight number?
---@field disabled boolean?
---@field type string|number? helper to identify the line, defined by user

---@class df_timeline_scrolldata : table
---@field length number
---@field defaultColor number[]
---@field useIconOnBlocks boolean
---@field lines df_timeline_linedata[]

---@class df_timeline_line_blockinfo : table
---@field time number
---@field duration number
---@field spellId number
---@field payload any
---@field customIcon any
---@field customName any

---@class df_timeline_line_block : button
---@field type timelinecomponenttype
---@field icon texture
---@field text fontstring
---@field background texture
---@field blockLength df_timeline_line_blocklength
---@field info df_timeline_line_blockinfo
---@field blockData df_timeline_block_data
---@field timeline df_timeline
---@field backgroundBorder border_frame

---@class df_timeline_line_blocklength : button
---@field type timelinecomponenttype
---@field isMoving boolean
---@field Texture texture
---@field RightIcon texture
---@field block df_timeline_line_block
---@field timeline df_timeline

---@param auraLengthFrame df_timeline_line_blocklength
local registerForDrag = function(auraLengthFrame)
	auraLengthFrame:SetMovable(true)
	auraLengthFrame:SetScript("OnMouseDown", function()
		do return end
		auraLengthFrame.isMoving = true
		auraLengthFrame:StartMoving()
		auraLengthFrame:ClearAllPoints()

		auraLengthFrame:SetScript("OnUpdate", function()
			--get the timeline
			local timeline = auraLengthFrame.timeline
			local blockUnderMouse = timeline:GetBlockUnderMouse()
			if (blockUnderMouse) then
				print("underblock")
			else
				print("no block under mouse")
			end
		end)
	end)

	auraLengthFrame:SetScript("OnMouseUp", function()
		do return end
		auraLengthFrame:StopMovingOrSizing()
		auraLengthFrame.isMoving = false
		auraLengthFrame:SetScript("OnUpdate", nil)
		--set the original point
		--auraLengthFrame:ClearAllPoints()
		--auraLengthFrame:SetPoint("topleft", cooldownSelectorScroll, "topleft", auraLengthFrame.originalXPoint, auraLengthFrame.originalYPoint)
	end)
end

---@class df_timeline_line_mixin : frame
---@field lineHeader frame
---@field blocks df_timeline_line_block[]
---@field CreateBlock fun(self:df_timeline_line, index:number):df_timeline_line_block
---@field GetBlock fun(self:df_timeline_line, index:number):df_timeline_line_block
---@field SetBlocksFromData fun(self:df_timeline_line)
---@field GetAllBlocks fun(self:df_timeline_line):df_timeline_line_block[]
---@field CreateBlockLength fun(block:df_timeline_line_block):df_timeline_line_blocklength
---@field OnEnterBlockLength fun(self:df_timeline_line_block)
---@field OnLeaveBlockLength fun(self:df_timeline_line_block)
---@field Reset fun(self:df_timeline_line)
detailsFramework.TimeLine_LineMixin = {
	GetAllBlocks = function(self)
		return self.blocks
	end,

	SetBlocksFromData = function(self)
		local timeline = self:GetParent():GetParent()
		local data = timeline.data
		local defaultColor = timeline.defaultColor --guarantee to have a value

		self:Show()

		--none of these values are scaled, need to calculate
		local pixelPerSecond = timeline.pixelPerSecond
		local totalLength = timeline.totalLength
		local scale = timeline.currentScale

		pixelPerSecond = pixelPerSecond * scale

		local headerWidth = timeline.headerWidth

		--dataIndex stores which line index from the data this line will use
		--lineData store members: .text .icon .timeline
		---@type df_timeline_linedata
		local lineData = data.lines[self.dataIndex]
		self.lineData = lineData

		local mouseEnabled = not lineData.disabled
		self.lineHeader:EnableMouse(mouseEnabled)
		self:EnableMouse(mouseEnabled)
		self:SetMouseClickEnabled(mouseEnabled)
		self:SetPropagateMouseClicks(true)
		self.enabled = mouseEnabled

		if (lineData.lineHeight) then
			self:SetHeight(lineData.lineHeight)
			self.lineHeader:SetHeight(lineData.lineHeight)
		else
			self:SetHeight(timeline.options.line_height)
			self.lineHeader:SetHeight(timeline.options.line_height)
		end

		self.spellId = lineData.spellId

		--if there's an icon, anchor the text at the right side of the icon
		--this is the title and icon of the title
		if (lineData.icon) then
			self.icon:SetTexture(lineData.icon)
			if (lineData.coords) then
				self.icon:SetTexCoord(unpack(lineData.coords))
			else
				self.icon:SetTexCoord(.1, .9, .1, .9)
			end
			self.text:SetText(lineData.text or "")
			self.text:SetPoint("left", self.icon.widget, "right", 2, 0)
		else
			self.icon:SetTexture(nil)
			self.text:SetText(lineData.text or "")
			self.text:SetPoint("left", self, "left", 2, 0)
		end

		if (self.dataIndex % 2 == 1) then
			self:SetBackdropColor(0, 0, 0, 0)
		else
			local r, g, b, a = unpack(self.backdrop_color)
			self:SetBackdropColor(r, g, b, a)
		end

		self:SetWidth(timeline.body:GetWidth()) -- self:SetWidth(5000)

		local timelineData = lineData.timeline
		local spellId = lineData.spellId
		local useIconOnBlock = data.useIconOnBlocks

		local baseFrameLevel = timeline:GetFrameLevel() + 10
		local errorHandler = geterrorhandler()
		local rowStartBlock

		for i = 1, #timelineData do
			local blockInfo = timelineData[i]

			local timeInSeconds = blockInfo[1]
			local length = blockInfo[2]
			local isAura = blockInfo[3]
			local auraDuration = blockInfo[4]
			local blockSpellId = blockInfo[5]

			local payload = blockInfo.payload
			local customIcon = blockInfo.customIcon
			local customName = blockInfo.customName
			local inRow = blockInfo.isIconRow
			local showRightIcon = blockInfo.showRightIcon
			local blockLengthHeight = blockInfo.blockLengthHeight or blockInfo.auraHeight
			local blockLengthYOffset = blockInfo.blockLengthYOffset or blockInfo.auraYOffset

			local xOffset = pixelPerSecond * timeInSeconds
			local width = pixelPerSecond * length

			if (timeInSeconds < -0.2) then
				xOffset = xOffset / 2.5
			end

			local block = self:GetBlock(i)
			block:Show()
			block:SetFrameLevel(baseFrameLevel)

			block.blockData = blockInfo

			if (inRow) then
				--when tagged as row, the icon will be attached to the latest block added into the line
				local lastBlock = self:GetBlock(i-1)
				PixelUtil.SetPoint(block, "left", lastBlock, "right", 2, 0)
				if (not rowStartBlock) then
					rowStartBlock = lastBlock
				end
			else
				PixelUtil.SetPoint(block, "left", self, "left", xOffset + headerWidth, 0)
				rowStartBlock = nil
			end

			auraDuration = auraDuration or 0

			block.info.spellId = blockSpellId or spellId
			block.info.time = timeInSeconds
			block.info.duration = auraDuration
			block.info.payload = payload
			block.info.customIcon = customIcon --nil set to nil if not exists
			block.info.customName = customName

			block.text:SetText(customName or "")

			if (useIconOnBlock) then
				local iconTexture = lineData.icon
				if (customIcon) then
					iconTexture = customIcon
				elseif (blockSpellId) then
					local spellInfo = C_Spell.GetSpellInfo(blockSpellId)
					iconTexture = spellInfo.iconID
				end

				block.icon:SetTexture(iconTexture)
				block.icon:SetTexCoord(.1, .9, .1, .9)
				block.icon:SetAlpha(.965)
				block.icon:SetSize(self:GetHeight(), self:GetHeight())

				if (timeInSeconds < -0.2) then
					block.icon:SetDesaturated(true)
				else
					block.icon:SetDesaturated(false)
				end

				PixelUtil.SetSize(block, self:GetHeight(), self:GetHeight())

				if (isAura) then
					block.blockLength:Show()
					local thisAuraDuration = auraDuration
					if (timeInSeconds + thisAuraDuration > timeline.data.length) then
						thisAuraDuration = timeline.data.length - timeInSeconds
					end

					local blockLengthTexture = blockInfo.auraLengthTexture
					if (blockLengthTexture) then
						block.blockLength.Texture:SetTexture(blockLengthTexture, true)
						block.blockLength.Texture:SetHorizTile(true)
					else
						block.blockLength.Texture:SetColorTexture(1, 1, 1, 1)
					end

					local auraLengthColor = blockInfo.auraLengthColor
					if (auraLengthColor) then
						local r, g, b, a = detailsFramework:ParseColors(auraLengthColor)
						block.blockLength.Texture:SetVertexColor(r, g, b, a or 0.5)
					else
						block.blockLength.Texture:SetVertexColor(1, 1, 1, 0.5)
					end

					block.blockLength.Texture:Show()

					block.blockLength:SetWidth(pixelPerSecond * thisAuraDuration)
					block.blockLength:SetHeight(blockLengthHeight and blockLengthHeight or block:GetHeight())

					if (showRightIcon) then
						block.blockLength.RightIcon:SetTexture(iconTexture)
						block.blockLength.RightIcon:SetTexCoord(.1, .9, .1, .9)
						block.blockLength.RightIcon:SetWidth(block.blockLength:GetHeight())
						block.blockLength.RightIcon:Show()
					else
						block.blockLength.RightIcon:SetTexture(nil)
						block.blockLength.RightIcon:Hide()
					end

					if (inRow) then
						block.blockLength:SetPoint("bottomleft", rowStartBlock or block.icon, "bottomleft", 0, blockLengthYOffset)
					else
						block.blockLength:SetPoint("bottomleft", block.icon, "bottomleft", 0, blockLengthYOffset)
					end

					--block:SetWidth(max(pixelPerSecond * auraDuration, 16))
				else
					block.blockLength:Hide()
				end

				block.background:SetVertexColor(0, 0, 0, 0)
			else
				block.icon:SetTexture("")
				block.background:SetVertexColor(0, 0, 0, 0)
				PixelUtil.SetSize(block, max(width, 16), self:GetHeight())
				block.blockLength:Hide()
			end

			if (timeline.options.block_on_set_data) then
				xpcall(timeline.options.block_on_set_data, errorHandler, block, blockInfo)
			end

			if (timeline.options.block_on_click) then
				block:SetMouseClickEnabled(true)
				block:SetScript("OnClick", timeline.options.block_on_click)
			end
		end
	end,

	GetBlock = function(self, index)
		local block = self.blocks[index]
		if (not block) then --CreateBlock
			block = self:CreateBlock(index)
		end
		return block
	end,

	CreateBlock = function(self, index)
		---@type df_timeline_line_block
		local block = CreateFrame("button", nil, self, "BackdropTemplate")
		block:SetMouseClickEnabled(false)
		self.blocks[index] = block

		block.type = "block"

		local background = block:CreateTexture(nil, "background")
		background:SetColorTexture(1, 1, 1, 1)
		local icon = block:CreateTexture(nil, "artwork")
		local text = block:CreateFontString(nil, "artwork", "GameFontNormal")

		local backgroundBorder = detailsFramework:CreateFullBorder("$parentBorder", block)
		local iconOffset = UIParent:GetEffectiveScale() * -1
		PixelUtil.SetPoint(backgroundBorder, "topleft", block, "topleft", -iconOffset, iconOffset)
		PixelUtil.SetPoint(backgroundBorder, "topright", block, "topright", iconOffset, iconOffset)
		PixelUtil.SetPoint(backgroundBorder, "bottomleft", block, "bottomleft", -iconOffset, -iconOffset)
		PixelUtil.SetPoint(backgroundBorder, "bottomright", block, "bottomright", iconOffset, -iconOffset)

		backgroundBorder:SetVertexColor(0, 0, 0, 1) --need to create a class for border frame

		background:SetAllPoints()
		icon:SetPoint("center", block, "center", 0, 0)
		text:SetPoint("left", icon, "right", 2, 0)
		detailsFramework:SetFontOutline(text, "OUTLINE")

		block.icon = icon
		block.text = text
		block.background = background
		block.backgroundBorder = backgroundBorder

		local timeline = self:GetParent():GetParent()
		block.timeline = timeline

		---@type df_timeline_options
		local timelineOptions = timeline.options

		block:SetScript("OnEnter", timelineOptions.block_on_enter)
		block:SetScript("OnLeave", timelineOptions.block_on_leave)

		block:SetMouseClickEnabled(false)
		---@diagnostic disable-next-line: missing-fields
		block.info = {}

		if (timelineOptions.block_on_create) then
			timelineOptions.block_on_create(block)
		end

		detailsFramework.TimeLine_LineMixin.CreateBlockLength(block)

		return block
	end,

	CreateBlockLength = function(block)
		---@type df_timeline_line_blocklength
		local blockLengthFrame = CreateFrame("button", nil, block)
		blockLengthFrame:SetFrameLevel(block:GetFrameLevel() - 1)
		blockLengthFrame:SetScript("OnEnter", detailsFramework.TimeLine_LineMixin.OnEnterBlockLength)
		blockLengthFrame:SetScript("OnLeave", detailsFramework.TimeLine_LineMixin.OnLeaveBlockLength)
		blockLengthFrame:SetScript("OnClick", detailsFramework.TimeLine_LineMixin.OnClickBlockLength)
		--save reference of the block
		blockLengthFrame.block = block
		--save reference of the timeline
		blockLengthFrame.timeline = block:GetParent():GetParent():GetParent()

		blockLengthFrame.type = "length"

		registerForDrag(blockLengthFrame)

		local auraLengthTexture = blockLengthFrame:CreateTexture(nil, "border")
		auraLengthTexture:SetColorTexture(1, 1, 1, 1)
		auraLengthTexture:SetVertexColor(1, 1, 1, 0.1)
		auraLengthTexture:SetAllPoints()
		blockLengthFrame.Texture = auraLengthTexture

		--icon which will be shown at the end of the blockLength frame if the icon is enabled
		local rightIcon = blockLengthFrame:CreateTexture(nil, "border")
		rightIcon:SetPoint("topright", blockLengthFrame, "topright", 0, 0)
		rightIcon:SetPoint("bottomright", blockLengthFrame, "bottomright", 0, 0)
		blockLengthFrame.RightIcon = rightIcon

		detailsFramework:CreateHighlightTexture(blockLengthFrame, "highlightTexture")

		block.blockLength = blockLengthFrame

		---@type df_timeline
		local timeline = block.timeline

		local callbackFunc = timeline.options.block_on_create_auralength or timeline.options.block_on_create_blocklength
		if (callbackFunc) then
			callbackFunc(blockLengthFrame)
		end

		return blockLengthFrame
	end,

	OnEnterBlockLength = function(self)
		---@type df_timeline
		local timeline = self.timeline
		local callbackFunc = timeline.options.block_on_enter_auralength or timeline.options.block_on_enter_blocklength
		if (callbackFunc) then
			callbackFunc(self)
		end
	end,

	OnLeaveBlockLength = function(self)
		---@type df_timeline
		local timeline = self.timeline
		local callbackFunc = timeline.options.block_on_leave_auralength or timeline.options.block_on_leave_blocklength
		if (callbackFunc) then
			callbackFunc(self)
		end
	end,

	OnClickBlockLength = function(self, button)
		---@type df_timeline
		local timeline = self.timeline
		local callbackFunc = timeline.options.block_on_click_auralength or timeline.options.block_on_click_blocklength
		if (callbackFunc) then
			callbackFunc(self, button)
		end
	end,

	Reset = function(self)
		--attention, it doesn't reset icon texture, text and background color
		for i = 1, #self.blocks do
			self.blocks[i]:Hide()
		end
		self:Hide()
		self.lineHeader:Hide()
	end,
}

---@class df_timeline_header_body : frame
---@field Buttons button[]
---@field originalHeight number
---@field Lines frame[]

---@class df_timeline_header : scrollframe
---@field type timelinecomponenttype
---@field body frame
---@field headerBody df_timeline_header_body
---@field verticalSlider slider

---@class df_timeline_body : frame
---@field type timelinecomponenttype
---@field Buttons button[]
---@field originalHeight number
---@field effectiveWidth number

---@class df_timeline_line : button, df_timeline_line_mixin
---@field type timelinecomponenttype
---@field index number
---@field spellId number
---@field icon df_image
---@field text df_label
---@field dataIndex number
---@field backdrop_color table
---@field backdrop_color_highlight table
---@field enabled boolean
---@field lineData df_timeline_linedata

---@class df_timeline : scrollframe, df_timeline_mixin, df_optionsmixin, df_framelayout, df_lineindicator
---@field type timelinecomponenttype
---@field body df_timeline_body
---@field onClickCallback fun(...)
---@field onClickCallbackFunc fun(...)
---@field onClickCallbackArgs any[]
---@field headerFrame df_timeline_header headerFrame only exists if the options.header_detached is true
---@field headerBody frame headerBody only exists if the options.header_detached is true
---@field resizeButton button
---@field elapsedTimeFrame df_elapsedtime
---@field horizontalSlider slider
---@field scaleSlider slider
---@field verticalSlider slider
---@field oldScale number
---@field currentScale number
---@field oldMinWidth number
---@field oldMaxWidth number
---@field scrolledWidth number
---@field data df_timeline_scrolldata
---@field lines df_timeline_line[]
---@field options df_timeline_options
---@field pixelPerSecond number
---@field totalLength number
---@field defaultColor table
---@field headerWidth number
---@field delayButtonRefreshTimer timer

---@class df_timeline_mixin : table
---@field GetLine fun(self:df_timeline, index:number):df_timeline_line
---@field GetAllLines fun(self:df_timeline):df_timeline_line[]
---@field GetBlockUnderMouse fun(self:df_timeline):df_timeline_line_block?
---@field GetBlockOrLengthUnderMouse fun(self:df_timeline):df_timeline_line_block|df_timeline_line_blocklength?
---@field GetLineUnderMouse fun(self:df_timeline):df_timeline_line?
---@field GetTimeUnderMouse fun(self:df_timeline):number
---@field GetBodyWidthUnderMouse fun(self:df_timeline):number
---@field GetBlocksAtTime fun(self:df_timeline, time:number?):df_timeline_line_block[]
---@field GetHorizontalScrolledWidth fun(self:df_timeline):number
---@field GetEffectivePixelPerSecond fun(self:df_timeline):number
---@field SetData fun(self:df_timeline, data:table)
---@field GetData fun(self:df_timeline):table
---@field RefreshTimeLine fun(self:df_timeline, bDelayButtonRefresh:boolean?, bFromScale:boolean?)
---@field RefreshResize fun(self:df_timeline)
---@field RefreshPerPixelButtons fun(self:df_timeline)
---@field ResetAllLines fun(self:df_timeline)
---@field SetCanResize fun(self:df_timeline, canResize:boolean)
---@field OnSizeChanged fun(self:df_timeline)
---@field SetOnClickCallback fun(self:df_timeline, callback:fun(), ...:any)
---@field UpdateOnClickCallback fun(self:df_timeline, button:button?)
---@field HideVerticalScroll fun(self:df_timeline)
---@field SetScale fun(self:df_timeline, scale:number)

detailsFramework.TimeLineMixin = {
	GetHorizontalScrolledWidth = function(self)
		return self.scrolledWidth
	end,

	HideVerticalScroll = function(self)
		self.verticalSlider:Hide()
	end,

	SetOnClickCallback = function(self, callback, ...)
		self.onClickCallbackArgs = {...}
		self.onClickCallback = callback

		self.onClickCallbackFunc = function(button)
			local second = button.index
			self.onClickCallback(second-1, unpack(self.onClickCallbackArgs))
		end

		self:UpdateOnClickCallback()
	end,

	UpdateOnClickCallback = function(self, button)
		if (button) then
			button:SetScript("OnClick", self.onClickCallbackFunc)
			return
		else
			for i = 1, #self.body.Buttons do
				local thisButton = self.body.Buttons[i]
				if (thisButton:IsShown()) then
					thisButton:SetScript("OnClick", self.onClickCallbackFunc)
				end
			end
		end
	end,

	SetScale = function(self, scale)
		local scaleSlider = self.scaleSlider
		local minValue, maxValue = scaleSlider:GetMinMaxValues()

		scale = max(minValue, min(maxValue, scale))
		scaleSlider:SetValue(detailsFramework.Math.MapRangeClamped(minValue, maxValue, 0, 1, scale))

		self:RefreshTimeLine()
	end,

	RefreshResize = function(self)
		if (self.options.can_resize) then
			self:SetResizable(true)
			self.resizeButton:Show()
			self:SetScript("OnSizeChanged", self.OnSizeChanged)
		else
			self:SetResizable(false)
			self.resizeButton:Hide()
			self:SetScript("OnSizeChanged", nil)
		end
	end,

	SetCanResize = function(self, bCanResize)
		self.options.can_resize = bCanResize
		self:RefreshResize()
	end,

	OnSizeChanged = function(self)
		local width, height = self:GetSize()
		self.horizontalSlider:SetSize(width + 20, 20)
		self.horizontalSlider:SetPoint("topleft", self, "bottomleft", 0, 0)

		self.scaleSlider:SetSize(width + 20, 20)
		self.scaleSlider:SetPoint("topleft", self.horizontalSlider, "bottomleft", 0, -2)

		self.verticalSlider:SetSize(20, height - 2)
		self.verticalSlider:SetPoint("topleft", self, "topright", 0, 0)

		--self.body:SetHeight(height)

		if (self.data.lines) then
			self:RefreshTimeLine()
		end
	end,

	GetAllLines = function(self)
		return self.lines
	end,

	GetLine = function(self, index)
		local line = self.lines[index]
		if (not line) then
			--create a new line
			---@type df_timeline_line
			line = CreateFrame("button", "$parentLine" .. index, self.body, "BackdropTemplate")
			detailsFramework:Mixin(line, detailsFramework.TimeLine_LineMixin)
			self.lines[index] = line

			line.type = "line"
			line.index = index

			local yPosition
			if (self.options.show_elapsed_timeline) then
				yPosition = -((index-1) * (self.options.line_height + 1)) - 2 - self.options.elapsed_timeline_height
			else
				--need code cleanup as the 'else' stuff isn't in use anymore
				yPosition = -((index-1) * (self.options.line_height + 1)) - 1
			end

			local yPadding = -10
			yPosition = yPosition + yPadding

			if (index == 1) then
				line:SetPoint("topleft", self.body, "topleft", 1, yPosition)
			else
				line:SetPoint("topleft", self.lines[index-1], "bottomleft", 0, -1)
			end

			line:SetSize(1, self.options.line_height) --width is set when updating the frame

			local detachedHeaderFrame = self.headerFrame
			local lineHeader

			if (detachedHeaderFrame) then
				lineHeader = CreateFrame("frame", "$parentHeader", self.headerBody, "BackdropTemplate")
				lineHeader.type = "header"
				lineHeader:SetSize(detachedHeaderFrame:GetWidth(), self.options.line_height)
				if (index == 1) then
					lineHeader:SetPoint("topleft", self.headerBody, "topleft", 0, yPosition)
				else
					lineHeader:SetPoint("topleft", self.lines[index-1].lineHeader, "bottomleft", 0, -1)
				end
				detailsFramework:CreateHighlightTexture(lineHeader, "HighlightTexture")
				lineHeader.HighlightTexture:SetDrawLayer("overlay", 1)
				lineHeader.HighlightTexture:Hide()
				lineHeader:EnableMouse(true)
				lineHeader:SetScript("OnEnter", function() self.options.on_enter(line) lineHeader.HighlightTexture:Show() end)
				lineHeader:SetScript("OnLeave", function() self.options.on_leave(line) lineHeader.HighlightTexture:Hide() end)
				line:SetScript("OnEnter", function() self.options.on_enter(line) lineHeader.HighlightTexture:Show() end)
				line:SetScript("OnLeave", function() self.options.on_leave(line) lineHeader.HighlightTexture:Hide() end)

				lineHeader.Line = line
			else
				lineHeader = CreateFrame("frame", "$parentHeader", line, "BackdropTemplate")
				lineHeader.type = "header"
				lineHeader:SetPoint("topleft", line, "topleft", 0, 0)
				lineHeader:SetPoint("bottomleft", line, "bottomleft", 0, 0)
				line:SetScript("OnEnter", self.options.on_enter)
				line:SetScript("OnLeave", self.options.on_leave)
			end
			--lineHeader:SetScript("OnEnter", self.options.header_on_enter)
			--lineHeader:SetScript("OnLeave", self.options.header_on_leave)

			line.lineHeader = lineHeader

			--store the individual textures that shows the timeline information
			line.blocks = {}

			line:SetMouseClickEnabled(false)

			line:SetBackdrop(self.options.backdrop)
			line:SetBackdropColor(unpack(self.options.backdrop_color))
			line:SetBackdropBorderColor(unpack(self.options.backdrop_border_color))

			local icon = detailsFramework:CreateImage(lineHeader, "", self.options.line_height, self.options.line_height)
			icon:SetPoint("left", lineHeader, "left", 2, 0)
			line.icon = icon

			local text = detailsFramework:CreateLabel(lineHeader, "", detailsFramework:GetTemplate("font", self.options.title_template))
			text:SetPoint("left", icon.widget, "right", 2, 0)
			line.text = text

			line.backdrop_color = self.options.backdrop_color or {.1, .1, .1, .3}
			line.backdrop_color_highlight = self.options.backdrop_color_highlight or {.3, .3, .3, .5}

			if (self.options.on_create_line) then
				self.options.on_create_line(line)
			end
		end

		return line
	end,

	ResetAllLines = function(self)
		for i = 1, #self.lines do
			self.lines[i]:Reset()
		end
	end,

	RefreshPerPixelButtons = function(self)
		--local amountOfButtons = floor(self.body:GetWidth() / (pixelPerSecond * currentScale))
		local amountOfButtons = self.totalLength
		local buttonHeight = self:GetHeight()
		local widthPerSecond = self.options.pixels_per_second * self.currentScale

		--print("Updating Buttons...", amountOfButtons, "bodyHeight??", buttonHeight, "scale:", currentScale)

		for i = 1, amountOfButtons do
			local button = self.body.Buttons[i]
			if (not button) then
				button = CreateFrame("button", "$parentButton" .. i, self.body, "BackdropTemplate")
				local overlayTexture = button:CreateTexture(nil, "overlay")
				local r, g, b, a = detailsFramework:GetDefaultBackdropColor()
				overlayTexture:SetColorTexture(1, 1, 1)
				overlayTexture:SetAlpha(i % 2 == 0 and 0.01 or 0.02)
				overlayTexture:SetAllPoints()

				--create a highlight texture
				local highlightTexture = button:CreateTexture(nil, "highlight")
				highlightTexture:SetColorTexture(1, 1, 1, 0.05)
				highlightTexture:SetAllPoints()

				self.body.Buttons[i] = button
			end

			button:SetSize(widthPerSecond, buttonHeight)

			local xPosition = (i - 1) * widthPerSecond
			xPosition = xPosition + self.options.header_width
			button:SetPoint("topleft", self.body, "topleft", xPosition, 0)

			self:UpdateOnClickCallback(button)

			button:Show()
			button.index = i
		end

		for i = amountOfButtons+1, #self.body.Buttons do
			self.body.Buttons[i]:Hide()
		end
	end,

	GetBlockUnderMouse = function(self)
		local allLines = self:GetAllLines()

		for i = 1, #allLines do
			local thisLine = allLines[i]
			local allBlocksInTheLine = thisLine:GetAllBlocks()
			for j = 1, #allBlocksInTheLine do
				local thisBlock = allBlocksInTheLine[j]
				if (thisBlock:IsShown()) then
					if (thisBlock:IsMouseOver()) then
						return thisBlock
					end
				end
			end
		end

		return nil
	end,

	GetBlockOrLengthUnderMouse = function(self)
		local allLines = self:GetAllLines()

		for i = 1, #allLines do
			local thisLine = allLines[i]
			local allBlocksInTheLine = thisLine:GetAllBlocks()
			for j = 1, #allBlocksInTheLine do
				local thisBlock = allBlocksInTheLine[j]
				if (thisBlock:IsShown()) then
					if (thisBlock:IsMouseOver()) then
						return thisBlock
					end

					local blockLength = thisBlock.blockLength
					if (blockLength and blockLength:IsShown()) then
						if (blockLength:IsMouseOver()) then
							return blockLength
						end
					end
				end
			end
		end

		return nil
	end,

	GetLineUnderMouse = function(self)
		local allLines = self:GetAllLines()

		for i = 1, #allLines do
			local thisLine = allLines[i]
			if (thisLine:IsMouseOver()) then
				return thisLine
			end
		end

		return nil
	end,

	GetBodyWidthUnderMouse = function(self)
		local x, y = GetCursorPosition()
		local scale = 1 / UIParent:GetEffectiveScale()
		x = x * scale

		local left = self.body:GetLeft()
		local width = x - left

		return width
	end,

	GetTimeUnderMouse = function(self)
		local bodyWidthUnderMouse = self:GetBodyWidthUnderMouse()
		local time = bodyWidthUnderMouse / (self.pixelPerSecond * self.currentScale)
		return time
	end,

	GetBlocksAtTime = function(self, time)
		if (not time) then
			time = self:GetTimeUnderMouse()
		end

		local blocks = {}
		local allLines = self:GetAllLines()

		local pixelsPerSecond = self:GetEffectivePixelPerSecond()

		for i = 1, #allLines do
			local thisLine = allLines[i]
			local allBlocksInTheLine = thisLine:GetAllBlocks()
			for j = 1, #allBlocksInTheLine do
				local thisBlock = allBlocksInTheLine[j]
				if (thisBlock:IsShown()) then
					local blockWidth = thisBlock:GetWidth()
					---@type df_timeline_line_blockinfo
					local blockInfo = thisBlock.info
					local blockTime = blockInfo.time

					local startTime = blockTime
					local endTime = blockTime + (blockWidth / pixelsPerSecond)

					--blockTime = math.floor(blockTime)
					--time = math.floor(time)
					if (time >= startTime and time <= endTime) then
						table.insert(blocks, thisBlock)
					end
				end
			end
		end

		return blocks
	end,

	--todo
	--make the on enter and leave tooltips
	--set icons and texts
	--skin the sliders

	GetEffectivePixelPerSecond = function(self)
		return self.pixelPerSecond * self.currentScale
	end,

	RefreshTimeLine = function(self, bDelayButtonRefresh, bFromScale) --~refresh
		if (not self.data.lines) then
			return
		end

		--calculate the total width
		local pixelPerSecond = self.options.pixels_per_second
		local totalLength = self.data.length or 1 --total time
		local currentScale = self.currentScale
		local bHeaderDetached = self.options.header_detached
		local effectiveHeaderWidth = (bHeaderDetached and 0) or self.options.header_width

		self.scaleSlider:Enable()

		local timelineWidth = self:GetWidth()

		--calculate the width that the body width should be
		local bodyWidth = totalLength * pixelPerSecond * currentScale
		self.body:SetWidth(bodyWidth + effectiveHeaderWidth)

		--reduce the default timeline size from the body width and don't allow the max value be negative
		local diff = bodyWidth - timelineWidth
		local newMaxValue = max(diff + effectiveHeaderWidth, 0)

		self.body.effectiveWidth = bodyWidth

		--cache values
		self.pixelPerSecond = pixelPerSecond
		self.totalLength = totalLength
		self.headerWidth = effectiveHeaderWidth

		--adjust the scale slider range
		--new max value is zero when all content is shown in the timeline (no scroll needed)
		local oldMin, oldMax = self.horizontalSlider:GetMinMaxValues()
		local newHorizontalSliderValue = self.horizontalSlider:GetValue()
		if (bFromScale) then
			local timeUnderMouse = self:GetTimeUnderMouse()
			local timeUnderMouseInPixels = (timeUnderMouse * pixelPerSecond * self.currentScale)
			newHorizontalSliderValue = timeUnderMouseInPixels
		end

		if (newMaxValue == 0) then
			--no scroll is needed
			self.horizontalSlider:SetMinMaxValues(0, 0)
			self.horizontalSlider:SetValue(0)

		elseif (oldMax ~= newMaxValue) then
			self.horizontalSlider:SetMinMaxValues(0, newMaxValue)
			self.horizontalSlider:SetValue(newHorizontalSliderValue) --it is setting for zoom even when if the refresh is not from zoom
		end

		self.oldMinWidth = 0
		self.oldMaxWidth = newMaxValue

		local defaultColor = self.data.defaultColor or {1, 1, 1, 1}

		self.defaultColor = defaultColor

		--buttons are the vertical clickable areas inside the timeline, each second on the time line has one
		if (not bDelayButtonRefresh and self.options.use_perpixel_buttons) then
			self:RefreshPerPixelButtons()
		elseif (bDelayButtonRefresh and self.options.use_perpixel_buttons) then
			if (self.delayButtonRefreshTimer and not self.delayButtonRefreshTimer:IsCancelled()) then
				self.delayButtonRefreshTimer:Cancel()
			end
			self.delayButtonRefreshTimer = detailsFramework.Schedules.NewTimer(0.1, function()
				self:RefreshPerPixelButtons()
			end)
		end

		--calculate the total height
		local lineHeight = self.options.line_height
		local linePadding = self.options.line_padding

		local bodyHeight = (lineHeight + linePadding) * #self.data.lines
		bodyHeight = bodyHeight + 40
		self.body:SetHeight(bodyHeight)
		self.verticalSlider:SetMinMaxValues(0, max(bodyHeight - self:GetHeight(), 0))
		self.verticalSlider:SetValue(0)

		if (bHeaderDetached) then
			self.headerBody:SetHeight(bodyHeight)
			self.headerFrame.verticalSlider:SetMinMaxValues(0, max(bodyHeight - self:GetHeight(), 0))
			self.headerFrame.verticalSlider:SetValue(0)
		end

		self:ResetAllLines()

		if (self.options.auto_height) then
			self:SetHeight(bodyHeight)
		end

		--refresh lines
		for i = 1, #self.data.lines do
			local line = self:GetLine(i)
			line.dataIndex = i --this index is used inside the line update function to know which data to get
			line.lineHeader:SetWidth(self.options.header_width)
			line:SetBlocksFromData() --the function to update runs within the line object
			line.lineHeader:Show()

			if (self.options.on_refresh_line) then
				self.options.on_refresh_line(line)
			end
		end

		--refresh elapsed time frame
		--the elapsed frame must have a width before the refresh function is called
		self.elapsedTimeFrame:ClearAllPoints()
		self.elapsedTimeFrame:SetPoint("topleft", self.body, "topleft", effectiveHeaderWidth, 0)
		self.elapsedTimeFrame:SetPoint("topright", self.body, "topright", 0, 0)
		self.elapsedTimeFrame:Reset()
		self.elapsedTimeFrame:Refresh(self.data.length, self.currentScale)

		--refresh the indicator lines
		self:LineIndicatorSetXOffset(effectiveHeaderWidth)
		self:LineIndicatorSetValueType("TIME")
		self:LineIndicatorSetScale(self.currentScale)
		self:LineIndicatorSetElapsedTime(self.data.length)
		self:LineIndicatorSetPixelsPerSecond(self.options.pixels_per_second)
		self:LineIndicatorRefresh()
	end,

	---@param self df_timeline
	---@param data df_timeline_scrolldata
	SetData = function(self, data)
		self.data = data
		self:RefreshTimeLine()
	end,

	---@param self df_timeline
	---@return df_timeline_scrolldata
	GetData = function(self)
		return self.data
	end,
}

local timelineHeader = {
	---@param self df_timeline
	CreateDetachedHeader = function(self)
		---@type df_timeline_header
		local headerFrame = CreateFrame("scrollframe", nil, self, "BackdropTemplate")
		headerFrame:SetWidth(self.options.header_width)
		self.headerFrame = headerFrame

		---@type df_timeline_header_body
		local headerBody = CreateFrame("frame", nil, headerFrame, "BackdropTemplate")
		headerBody:SetSize(headerFrame:GetSize())
		headerBody.Lines = {}
		headerFrame.body = headerBody
		self.headerBody = headerBody

		headerFrame:SetScrollChild(headerBody)
		headerBody.originalHeight = headerBody:GetHeight()

		local verticalSlider = CreateFrame("slider", nil, headerFrame)
		headerFrame.verticalSlider = verticalSlider
		verticalSlider:SetOrientation("vertical")
		verticalSlider:SetValue(0)
		verticalSlider:SetScript("OnValueChanged", function(self)
		    headerFrame:SetVerticalScroll(self:GetValue())
		end)

		return headerFrame, headerBody
	end,

}

local onScaleChange_RefreshTimer = nil


---@class df_timeline_body : frame, df_lineindicator


---creates a scrollable panel with vertical, horizontal and scale sliders to show a timeline
---also creates a frame for the elapsed timeline at the top, it shows the time in seconds
---@param parent frame
---@param name string
---@param timelineOptions df_timeline_options
---@param elapsedtimeOptions df_elapsedtime_options
---@return df_timeline, frame
function detailsFramework:CreateTimeLineFrame(parent, name, timelineOptions, elapsedtimeOptions)
	local width = timelineOptions and timelineOptions.width or timeline_options.width
	local height = timelineOptions and timelineOptions.height or timeline_options.height
	local scrollWidth = 800 --placeholder until the timeline receives data
	local scrollHeight = 800 --placeholder until the timeline receives data

	---@type df_timeline
	local frameCanvas = CreateFrame("scrollframe", name, parent, "BackdropTemplate")

	frameCanvas.type = "timeline"

	detailsFramework:Mixin(frameCanvas, detailsFramework.TimeLineMixin)
	detailsFramework:Mixin(frameCanvas, detailsFramework.OptionsFunctions)
	detailsFramework:Mixin(frameCanvas, detailsFramework.LayoutFrame)
	detailsFramework:Mixin(frameCanvas, detailsFramework.LineIndicatorMixin)

	frameCanvas:LineIndicatorConstructor()
	frameCanvas:LineIndicatorSetValueType("TIME")

	--this table is changed by SetData()
	---@diagnostic disable-next-line: missing-fields
	frameCanvas.data = {} --placeholder
	frameCanvas.lines = {}

	frameCanvas.currentScale = 0.5
	frameCanvas.oldScale = 0.5
	frameCanvas:SetSize(width, height)

	detailsFramework:ApplyStandardBackdrop(frameCanvas)

	local frameBody = CreateFrame("frame", nil, frameCanvas, "BackdropTemplate")
	frameBody:SetSize(scrollWidth, scrollHeight)
	frameCanvas:LineIndicatorSetTarget(frameBody)

	frameBody.type = "body"

	frameBody.Buttons = {}

	frameCanvas:SetScrollChild(frameBody)
	frameCanvas.body = frameBody
	frameCanvas.body.originalHeight = frameCanvas.body:GetHeight()

	frameCanvas:BuildOptionsTable(timeline_options, timelineOptions)

	--create elapsed time frame
	frameCanvas.elapsedTimeFrame = detailsFramework:CreateElapsedTimeFrame(frameBody, frameCanvas:GetName() and (frameCanvas:GetName() .. "ElapsedTimeFrame"), elapsedtimeOptions)
	frameCanvas.elapsedTimeFrame:SetScrollChild(frameBody)

	local thumbColor = 0.95
	local scrollBackgroudColor = {0.05, 0.05, 0.05, 0.7}

	--create horizontal slider
		local horizontalSlider = CreateFrame("slider", frameCanvas:GetName() .. "HorizontalSlider", parent, "BackdropTemplate")
		horizontalSlider.bg = horizontalSlider:CreateTexture(nil, "background")
		horizontalSlider.bg:SetAllPoints(true)
		horizontalSlider.bg:SetColorTexture(unpack(scrollBackgroudColor))
		frameCanvas.horizontalSlider = horizontalSlider

		horizontalSlider:SetBackdrop(frameCanvas.options.slider_backdrop)
		horizontalSlider:SetBackdropColor(unpack(frameCanvas.options.slider_backdrop_color))
		horizontalSlider:SetBackdropBorderColor(unpack(frameCanvas.options.slider_backdrop_border_color))

		horizontalSlider.thumb = horizontalSlider:CreateTexture(nil, "OVERLAY")
		horizontalSlider.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		horizontalSlider.thumb:SetSize(24, 24)
		horizontalSlider.thumb:SetVertexColor(thumbColor, thumbColor, thumbColor, 0.95)
		horizontalSlider:SetThumbTexture(horizontalSlider.thumb)

		horizontalSlider:SetOrientation("horizontal")
		horizontalSlider:SetValue(0)
		horizontalSlider:SetScript("OnValueChanged", function(self)
			local _, maxValue = horizontalSlider:GetMinMaxValues()
			local stepValue = ceil(ceil(self:GetValue() * maxValue) / max(maxValue, SMALL_FLOAT))
			if (stepValue ~= horizontalSlider.currentValue) then
				horizontalSlider.currentValue = stepValue
				frameCanvas:SetHorizontalScroll(stepValue)
			end
		end)

	--create scale slider
		local scaleSlider = CreateFrame("slider", frameCanvas:GetName() .. "ScaleSlider", parent, "BackdropTemplate")
		scaleSlider.bg = scaleSlider:CreateTexture(nil, "background")
		scaleSlider.bg:SetAllPoints(true)
		scaleSlider.bg:SetColorTexture(unpack(scrollBackgroudColor))
		scaleSlider:Disable()
		frameCanvas.scaleSlider = scaleSlider

		scaleSlider:SetBackdrop(frameCanvas.options.slider_backdrop)
		scaleSlider:SetBackdropColor(unpack(frameCanvas.options.slider_backdrop_color))
		scaleSlider:SetBackdropBorderColor(unpack(frameCanvas.options.slider_backdrop_border_color))

		scaleSlider.thumb = scaleSlider:CreateTexture(nil, "OVERLAY")
		scaleSlider.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		scaleSlider.thumb:SetSize(24, 24)
		scaleSlider.thumb:SetVertexColor(thumbColor, thumbColor, thumbColor, 0.95)
		scaleSlider:SetThumbTexture(scaleSlider.thumb)

		scaleSlider:SetOrientation("horizontal")
		scaleSlider:SetMinMaxValues(frameCanvas.options.scale_min, frameCanvas.options.scale_max)
		scaleSlider:SetValue(detailsFramework.Math.GetRangeValue(frameCanvas.options.scale_min, frameCanvas.options.scale_max, 0.5))

		scaleSlider:SetScript("OnValueChanged", function(self, delta)
			local stepValue = ceil(self:GetValue() * 100) / 100
			if (stepValue ~= frameCanvas.currentScale) then
				frameCanvas.oldScale = frameCanvas.currentScale
				frameCanvas.currentScale = stepValue
				local bDelayButtonRefresh = true
				local bFromScale = true
				frameCanvas:RefreshTimeLine(bDelayButtonRefresh, bFromScale)
			end
		end)

	--create vertical slider
		local verticalSlider = CreateFrame("slider", frameCanvas:GetName() .. "VerticalSlider", parent, "BackdropTemplate")
		verticalSlider.bg = verticalSlider:CreateTexture(nil, "background")
		verticalSlider.bg:SetAllPoints(true)
		verticalSlider.bg:SetColorTexture(unpack(scrollBackgroudColor))
		frameCanvas.verticalSlider = verticalSlider

		verticalSlider:SetBackdrop(frameCanvas.options.slider_backdrop)
		verticalSlider:SetBackdropColor(unpack(frameCanvas.options.slider_backdrop_color))
		verticalSlider:SetBackdropBorderColor(unpack(frameCanvas.options.slider_backdrop_border_color))

		verticalSlider.thumb = verticalSlider:CreateTexture(nil, "OVERLAY")
		verticalSlider.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		verticalSlider.thumb:SetSize(24, 24)
		verticalSlider.thumb:SetVertexColor(thumbColor, thumbColor, thumbColor, 0.95)
		verticalSlider:SetThumbTexture(verticalSlider.thumb)

		verticalSlider:SetOrientation("vertical")
		verticalSlider:SetValue(0)
		verticalSlider:SetScript("OnValueChanged", function(self)
		    frameCanvas:SetVerticalScroll(self:GetValue())
			if (frameCanvas.options.header_detached) then
				frameCanvas.headerFrame.verticalSlider:SetValue(self:GetValue())
			end
		end)

	--mouse scroll
		frameCanvas:EnableMouseWheel(true)
		frameCanvas:SetScript("OnMouseWheel", function(self, delta)
			local minValue, maxValue = horizontalSlider:GetMinMaxValues()
			local currentHorizontal = horizontalSlider:GetValue()

			if (IsShiftKeyDown() and delta < 0) then
				if (verticalSlider:IsShown()) then
					local amountToScroll = frameBody:GetHeight() / 20
					verticalSlider:SetValue(verticalSlider:GetValue() + amountToScroll)
				end

			elseif (IsShiftKeyDown() and delta > 0) then
				if (verticalSlider:IsShown()) then
					local amountToScroll = frameBody:GetHeight() / 20
					verticalSlider:SetValue(verticalSlider:GetValue() - amountToScroll)
				end

			elseif (IsControlKeyDown() and delta > 0) then
				scaleSlider:SetValue(min(scaleSlider:GetValue() + 0.1, frameCanvas.options.scale_max))

			elseif (IsControlKeyDown() and delta < 0) then
				if (self.options.zoom_out_zero) then
					scaleSlider:SetValue(0)
				else
					scaleSlider:SetValue(max(scaleSlider:GetValue() - 0.1, frameCanvas.options.scale_min))
				end

			elseif (delta < 0 and currentHorizontal < maxValue) then
				local amountToScroll = frameBody:GetWidth() / 20
				horizontalSlider:SetValue(currentHorizontal + amountToScroll)
				local scrolledWidth = horizontalSlider:GetValue() - currentHorizontal
				frameCanvas.scrolledWidth = scrolledWidth
				frameBody.scrolledWidth = scrolledWidth

			elseif (delta > 0 and maxValue > 1) then
				local amountToScroll = frameBody:GetWidth() / 20
				horizontalSlider:SetValue(currentHorizontal - amountToScroll)
				local scrolledWidth = horizontalSlider:GetValue() - currentHorizontal
				frameCanvas.scrolledWidth = scrolledWidth
				frameBody.scrolledWidth = scrolledWidth
			end
		end)

	frameBody.GetHorizontalScrolledWidth = frameCanvas.GetHorizontalScrolledWidth

	local dragOnTickFunc = function()
		local x = GetCursorPosition()
		local deltaX = frameBody.MouseX - x
		local current = horizontalSlider:GetValue()
		horizontalSlider:SetValue(current + (deltaX * 1.2) * ((IsShiftKeyDown() and 2) or (IsAltKeyDown() and 0.5) or 1))
		frameBody.MouseX = x
	end

	frameBody.isDragging = false

	frameBody:SetScript("OnUpdate", function(thisFrameBody, deltaTime)
		if (frameBody.isDragging) then
			dragOnTickFunc()
		end

		if (frameBody:IsMouseOver()) then
			frameBody.mouseTime = frameCanvas:GetTimeUnderMouse()
		end
	end)

	--mouse drag
	frameBody:SetScript("OnMouseDown", function(self, button)
		local x = GetCursorPosition()
		self.MouseX = x
		frameBody.isDragging = true
	end)

	frameBody:SetScript("OnMouseUp", function(self, button)
		frameBody.isDragging = false
	end)

	local headerFrame, headerBody
	--if the header detached?
	if (timelineOptions.header_detached) then
		headerFrame, headerBody = timelineHeader.CreateDetachedHeader(frameCanvas)
	end

	--create a resize button
	local resizerButton = CreateFrame("button", "$parentReziser", frameCanvas)
	resizerButton:SetSize(20, 20)
	resizerButton:SetAlpha(0.734)
	resizerButton:SetPoint("bottomright", frameCanvas, "bottomright", -2, 2)
	resizerButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
	resizerButton:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
	resizerButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
	resizerButton:SetFrameLevel(frameCanvas:GetFrameLevel() + 20)

	resizerButton:SetScript("OnMouseDown", function()
		frameCanvas:StartSizing("bottomright")
	end)
	resizerButton:SetScript("OnMouseUp", function()
		frameCanvas:StopMovingOrSizing()
	end)

	frameCanvas.resizeButton = resizerButton
	frameCanvas:RefreshResize()
	frameCanvas:OnSizeChanged()

	return frameCanvas, headerFrame, headerBody
end