
---@type detailsframework
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
--lua locals
local rawset = rawset --lua local
local rawget = rawget --lua local
local setmetatable = setmetatable --lua local
local unpack = table.unpack or unpack --lua local
local type = type --lua local
local floor = math.floor --lua local
local loadstring = loadstring --lua local
local CreateFrame = CreateFrame

-- TWW compatibility:
local Enum = _G.Enum
local C_SpellBook = _G.C_SpellBook


local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end
local GetNumSpellTabs = GetNumSpellTabs or C_SpellBook.GetNumSpellBookSkillLines
local GetSpellTabInfo = GetSpellTabInfo or function(tabLine) local skillLine = C_SpellBook.GetSpellBookSkillLineInfo(tabLine) if skillLine then return skillLine.name, skillLine.iconID, skillLine.itemIndexOffset, skillLine.numSpellBookItems, skillLine.isGuild, skillLine.offSpecID end end
local SPELLBOOK_BANK_PLAYER = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or "player"
local SpellBookItemTypeMap = Enum.SpellBookItemType and {[Enum.SpellBookItemType.Spell] = "SPELL", [Enum.SpellBookItemType.None] = "NONE", [Enum.SpellBookItemType.Flyout] = "FLYOUT", [Enum.SpellBookItemType.FutureSpell] = "FUTURESPELL", [Enum.SpellBookItemType.PetAction] = "PETACTION" } or {}
local GetSpellBookItemInfo = GetSpellBookItemInfo or function(...) local si = C_SpellBook.GetSpellBookItemInfo(...) if si then return SpellBookItemTypeMap[si.itemType] or "NONE", (si.itemType == Enum.SpellBookItemType.Flyout or si.itemType == Enum.SpellBookItemType.PetAction) and si.actionID or si.spellID or si.actionID, si end end
local GetSpellBookItemTexture = GetSpellBookItemTexture or function(...) return C_SpellBook.GetSpellBookItemTexture(...) end
local GetSpellTexture = GetSpellTexture or function(...) return C_Spell.GetSpellTexture(...) end

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local CastInfo = detailsFramework.CastInfo

local PixelUtil = PixelUtil or DFPixelUtil

local UnitGroupRolesAssigned = detailsFramework.UnitGroupRolesAssigned

local cleanfunction = function() end
local APIFrameFunctions


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--horizontal scroll frame

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
---@field on_enter fun(self:frame) --line
---@field on_leave fun(self:frame) --line
---@field block_on_enter fun(self:button)
---@field block_on_leave fun(self:button)
---@field block_on_click fun(self:button)
---@field block_on_set_data fun(self:button, data:table)
---@field block_on_enter_auralength fun(self:df_timeline_line_block)
---@field block_on_leave_auralength fun(self:df_timeline_line_block)
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

	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdrop_color = {0, 0, 0, 0.2},
	backdrop_color_highlight = {.2, .2, .2, 0.4},
	backdrop_border_color = {0.1, 0.1, 0.1, .2},

	slider_backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	slider_backdrop_color = {0, 0, 0, 0.2},
	slider_backdrop_border_color = {0.1, 0.1, 0.1, .2},

	title_template = "ORANGE_FONT_TEMPLATE",
	text_tempate = "OPTIONS_FONT_TEMPLATE",

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
---@field [3] boolean isAura
---@field [4] number auraDuration
---@field [5] number blockSpellId
---@field payload any
---@field customIcon any
---@field customName any
---@field isIconRow boolean?

---@class df_timeline_linedata : table
---@field spellId number
---@field icon any
---@field coords number[]?
---@field text string?
---@field timeline df_timeline_block_data[]

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

---@class df_timeline_line_block : frame
---@field icon texture
---@field text fontstring
---@field background texture
---@field auraLength frame
---@field info df_timeline_line_blockinfo

---@class df_timeline_line_mixin : frame
---@field lineHeader frame
---@field blocks df_timeline_line_block[]
---@field SetBlock fun(self:df_timeline_line, index:number, blockInfo:table)
---@field GetBlock fun(self:df_timeline_line, index:number):df_timeline_line_block
---@field SetBlocksFromData fun(self:df_timeline_line)
---@field Reset fun(self:df_timeline_line)
detailsFramework.TimeLine_LineMixin = {
	--self is the line
	SetBlock = function(self, index, blockInfo)
		--get the block information
		--see what is the current scale
		--adjust the block position

		local block = self:GetBlock(index)

		--need:
			--the total time of the timeline
			--the current scale of the timeline
			--the elapsed time of this block
			--icon of the block
			--text
			--background color

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
			local auraHeight = blockInfo.auraHeight
			local auraYOffset = blockInfo.auraYOffset

			local xOffset = pixelPerSecond * timeInSeconds
			local width = pixelPerSecond * length

			if (timeInSeconds < -0.2) then
				xOffset = xOffset / 2.5
			end

			local block = self:GetBlock(i)
			block:Show()
			block:SetFrameLevel(baseFrameLevel)

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
					iconTexture = GetSpellTexture(blockSpellId)
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
					block.auraLength:Show()
					local thisAuraDuration = auraDuration
					if (timeInSeconds + thisAuraDuration > timeline.data.length) then
						thisAuraDuration = timeline.data.length - timeInSeconds
					end

					if (blockInfo.auraLengthColor) then
						local r, g, b = unpack(blockInfo.auraLengthColor)
						block.auraLength.Texture:SetVertexColor(r, g, b, 0.5)
					else
						block.auraLength.Texture:SetVertexColor(1, 1, 1, 0.5)
					end

					block.auraLength.Texture:Show()

					block.auraLength:SetWidth(pixelPerSecond * thisAuraDuration)
					block.auraLength:SetHeight(auraHeight and auraHeight or block:GetHeight())

					if (showRightIcon) then
						block.auraLength.RightIcon:SetTexture(iconTexture)
						block.auraLength.RightIcon:SetTexCoord(.1, .9, .1, .9)
						block.auraLength.RightIcon:SetWidth(block.auraLength:GetHeight())
						block.auraLength.RightIcon:Show()
					else
						block.auraLength.RightIcon:SetTexture(nil)
						block.auraLength.RightIcon:Hide()
					end

					if (inRow) then
						block.auraLength:SetPoint("bottomleft", rowStartBlock or block.icon, "bottomleft", 0, auraYOffset)
					else
						block.auraLength:SetPoint("bottomleft", block.icon, "bottomleft", 0, auraYOffset)
					end

					--block:SetWidth(max(pixelPerSecond * auraDuration, 16))
				else
					block.auraLength:Hide()
				end

				block.background:SetVertexColor(0, 0, 0, 0)
			else
				block.icon:SetTexture("")
				block.background:SetVertexColor(0, 0, 0, 0)
				PixelUtil.SetSize(block, max(width, 16), self:GetHeight())
				block.auraLength:Hide()
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

	OnEnterAuraLength = function(self)
		---@type df_timeline
		local timeline = self.timeline
		if (timeline.options.block_on_enter_auralength) then
			timeline.options.block_on_enter_auralength(self)
		end
	end,

	OnLeaveAuraLength = function(self)
		---@type df_timeline
		local timeline = self.timeline
		if (timeline.options.block_on_enter_auralength) then
			timeline.options.block_on_leave_auralength(self)
		end
	end,

	CreateAuraLength = function(block)
		local auraLengthFrame = CreateFrame("frame", nil, block)
		auraLengthFrame:SetFrameLevel(block:GetFrameLevel() - 1)
		auraLengthFrame:SetScript("OnEnter", detailsFramework.TimeLine_LineMixin.OnEnterAuraLength)
		auraLengthFrame:SetScript("OnLeave", detailsFramework.TimeLine_LineMixin.OnLeaveAuraLength)
		--save reference of the block
		auraLengthFrame.block = block
		--save reference of the timeline
		auraLengthFrame.timeline = block:GetParent():GetParent():GetParent()

		local auraLengthTexture = auraLengthFrame:CreateTexture(nil, "border")
		auraLengthTexture:SetColorTexture(1, 1, 1, 1)
		auraLengthTexture:SetVertexColor(1, 1, 1, 0.1)
		auraLengthTexture:SetAllPoints()
		auraLengthFrame.Texture = auraLengthTexture

		--icon which will be shown at the end of the auraLength frame if the icon is enabled
		local rightIcon = auraLengthFrame:CreateTexture(nil, "border")
		rightIcon:SetPoint("topright", auraLengthFrame, "topright", 0, 0)
		rightIcon:SetPoint("bottomright", auraLengthFrame, "bottomright", 0, 0)
		auraLengthFrame.RightIcon = rightIcon

		detailsFramework:CreateHighlightTexture(auraLengthFrame)

		block.auraLength = auraLengthFrame
	end,

	GetBlock = function(self, index)
		local block = self.blocks[index]
		if (not block) then
			block = CreateFrame("button", nil, self, "BackdropTemplate")
			block:SetMouseClickEnabled(false)
			self.blocks[index] = block

			local background = block:CreateTexture(nil, "background")
			background:SetColorTexture(1, 1, 1, 1)
			local icon = block:CreateTexture(nil, "artwork")
			local text = block:CreateFontString(nil, "artwork", "GameFontNormal")

			detailsFramework.TimeLine_LineMixin.CreateAuraLength(block)

			local backgroundBorder = detailsFramework:CreateFullBorder("$parentBorder", block)
			local iconOffset = -1 * UIParent:GetEffectiveScale()
			PixelUtil.SetPoint(backgroundBorder, "topleft", block, "topleft", -iconOffset, iconOffset)
			PixelUtil.SetPoint(backgroundBorder, "topright", block, "topright", iconOffset, iconOffset)
			PixelUtil.SetPoint(backgroundBorder, "bottomleft", block, "bottomleft", -iconOffset, -iconOffset)
			PixelUtil.SetPoint(backgroundBorder, "bottomright", block, "bottomright", iconOffset, -iconOffset)

			backgroundBorder:SetVertexColor(0, 0, 0, 1)

			background:SetAllPoints()
			icon:SetPoint("left")
			text:SetPoint("left", icon, "right", 2, 0)
			detailsFramework:SetFontOutline(text, "OUTLINE")

			block.icon = icon
			block.text = text
			block.background = background
			block.backgroundBorder = backgroundBorder

			block:SetScript("OnEnter", self:GetParent():GetParent().options.block_on_enter)
			block:SetScript("OnLeave", self:GetParent():GetParent().options.block_on_leave)

			block:SetMouseClickEnabled(false)
			block.info = {}
		end

		return block
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

---@class df_timeline_body : frame
---@field Buttons button[]
---@field originalHeight number
---@field effectiveWidth number

---@class df_timeline_line : frame, df_timeline_line_mixin
---@field spellId number
---@field icon df_image
---@field text df_label
---@field dataIndex number
---@field backdrop_color table
---@field backdrop_color_highlight table

---@class df_timeline : scrollframe, df_timeline_mixin, df_optionsmixin, df_framelayout, df_lineindicator
---@field body df_timeline_body
---@field onClickCallback fun()
---@field onClickCallbackFunc fun()
---@field onClickCallbackArgs any[]
---@field headerFrame scrollframe headerFrame only exists if the options.header_detached is true
---@field headerBody frame headerBody only exists if the options.header_detached is true
---@field resizeButton button
---@field elapsedTimeFrame df_elapsedtime
---@field horizontalSlider slider
---@field scaleSlider slider
---@field verticalSlider slider
---@field currentScale number
---@field scrolledWidth number
---@field data df_timeline_scrolldata
---@field lines df_timeline_line[]
---@field options df_timeline_options
---@field pixelPerSecond number
---@field totalLength number
---@field defaultColor table
---@field headerWidth number

---@class df_timeline_mixin : table
---@field GetLine fun(self:df_timeline, index:number):df_timeline_line
---@field ResetAllLines fun(self:df_timeline)
---@field RefreshTimeLine fun(self:df_timeline, bDoNotRefreshButtons:boolean?)
---@field SetData fun(self:df_timeline, data:table)
---@field GetData fun(self:df_timeline):table
---@field RefreshResize fun(self:df_timeline)
---@field SetCanResize fun(self:df_timeline, canResize:boolean)
---@field OnSizeChanged fun(self:df_timeline)
---@field SetOnClickCallback fun(self:df_timeline, callback:fun(), ...:any)
---@field UpdateOnClickCallback fun(self:df_timeline, button:button?)
---@field GetHorizontalScrolledWidth fun(self:df_timeline):number
---@field HideVerticalScrollBar fun(self:df_timeline)
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
			line = CreateFrame("frame", "$parentLine" .. index, self.body, "BackdropTemplate")
			detailsFramework:Mixin(line, detailsFramework.TimeLine_LineMixin)
			self.lines[index] = line

			local xPosition
			if (self.options.show_elapsed_timeline) then
				xPosition = -((index-1) * (self.options.line_height + 1)) - 2 - self.options.elapsed_timeline_height
			else
				xPosition = -((index-1) * (self.options.line_height + 1)) - 1
			end

			line:SetPoint("topleft", self.body, "topleft", 1, xPosition)
			line:SetSize(1, self.options.line_height) --width is set when updating the frame

			local detachedHeaderFrame = self.headerFrame
			local lineHeader

			if (detachedHeaderFrame) then
				lineHeader = CreateFrame("frame", nil, self.headerBody, "BackdropTemplate")
				lineHeader:SetSize(detachedHeaderFrame:GetWidth(), self.options.line_height)
				lineHeader:SetPoint("topleft", self.headerBody, "topleft", 0, xPosition)
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
				lineHeader = CreateFrame("frame", nil, line, "BackdropTemplate")
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

	--todo
	--make the on enter and leave tooltips
	--set icons and texts
	--skin the sliders

	RefreshTimeLine = function(self, bDoNotRefreshButtons) --~refresh
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

		--original code
		--[=[
			--how many pixels represent 1 second
			local bodyWidth = totalLength * pixelPerSecond * currentScale
			self.body:SetWidth(bodyWidth + self.options.header_width)
			self.body.effectiveWidth = bodyWidth

			--reduce the default canvas size from the body with and don't allow the max value be negative
			local newMaxValue = max(bodyWidth - (self:GetWidth() - self.options.header_width), 0)

			--adjust the scale slider range
			local oldMin, oldMax = self.horizontalSlider:GetMinMaxValues()
			self.horizontalSlider:SetMinMaxValues(0, newMaxValue)
			self.horizontalSlider:SetValue(detailsFramework:MapRangeClamped(oldMin, oldMax, 0, newMaxValue, self.horizontalSlider:GetValue()))
		]=]

		--calculate the width that the body width should be
		local bodyWidth = totalLength * pixelPerSecond * currentScale
		--get the biggest value between the calculated body width and (timeline width minus header width) in case the desired body width is smaller than the timeline width
		--local bodyFrameWidth = max(bodyWidth + effectiveHeaderWidth, timelineWidth - effectiveHeaderWidth)
		--self.body:SetWidth(bodyFrameWidth)
		self.body:SetWidth(bodyWidth + effectiveHeaderWidth)

		--[=[
		print("effectiveHeaderWidth", effectiveHeaderWidth)
		if (bodyWidth + effectiveHeaderWidth > timelineWidth - effectiveHeaderWidth) then
			print(1)
		else
			print(2) --this is fucking with the elapsed time bar | need to see further in the script that's happening
		end
		--]=]

		--reduce the default timeline size from the body width and don't allow the max value be negative
		local newMaxValue = max(bodyWidth - timelineWidth + effectiveHeaderWidth, 0)

		--print(desiredBodyWidth + effectiveHeaderWidth, timelineWidth - effectiveHeaderWidth) --1020, 750

		self.body.effectiveWidth = bodyWidth

		--adjust the scale slider range
		local oldMin, oldMax = self.horizontalSlider:GetMinMaxValues()
		self.horizontalSlider:SetMinMaxValues(0, newMaxValue)
		self.horizontalSlider:SetValue(detailsFramework:MapRangeClamped(oldMin, oldMax, 0, newMaxValue, self.horizontalSlider:GetValue()))

		local defaultColor = self.data.defaultColor or {1, 1, 1, 1}

		--cache values
		self.pixelPerSecond = pixelPerSecond
		self.totalLength = totalLength
		self.defaultColor = defaultColor
		self.headerWidth = effectiveHeaderWidth

		--buttons are the vertical clickable areas inside the timeline, each second on the time line has one
		if (not bDoNotRefreshButtons and self.options.use_perpixel_buttons) then
			self:RefreshPerPixelButtons()
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
		local howManyLinesTheTimelineCanShow = floor(self:GetHeight() / (lineHeight + linePadding)) - 1
		--for i = 1, math.min(#self.data.lines, howManyLinesTheTimelineCanShow) do
		for i = 1, #self.data.lines do
			local line = self:GetLine(i)
			line.dataIndex = i --this index is used inside the line update function to know which data to get
			line.lineHeader:SetWidth(self.options.header_width)
			line:SetBlocksFromData() --the function to update runs within the line object
			line.lineHeader:Show()
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
		local headerFrame = CreateFrame("scrollframe", nil, self, "BackdropTemplate")
		headerFrame:SetWidth(self.options.header_width)
		self.headerFrame = headerFrame

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
	frameCanvas:SetSize(width, height)

	detailsFramework:ApplyStandardBackdrop(frameCanvas)

	local frameBody = CreateFrame("frame", nil, frameCanvas, "BackdropTemplate")
	frameBody:SetSize(scrollWidth, scrollHeight)
	frameCanvas:LineIndicatorSetTarget(frameBody)

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
		scaleSlider:SetValue(detailsFramework:GetRangeValue(frameCanvas.options.scale_min, frameCanvas.options.scale_max, 0.5))

		scaleSlider:SetScript("OnValueChanged", function(self)
			local stepValue = ceil(self:GetValue() * 100) / 100
			if (stepValue ~= frameCanvas.currentScale) then
				local current = stepValue
				frameCanvas.currentScale = stepValue
				local bDoNotRefreshButtons = true
				frameCanvas:RefreshTimeLine(bDoNotRefreshButtons)

				if (onScaleChange_RefreshTimer and not onScaleChange_RefreshTimer:IsCancelled()) then
					onScaleChange_RefreshTimer:Cancel()
				end

				onScaleChange_RefreshTimer = detailsFramework.Schedules.NewTimer(0.1, function()
					frameCanvas:RefreshTimeLine()
				end)
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

			if (delta < 0) then
				if (verticalSlider:IsShown()) then
					local amountToScroll = frameBody:GetHeight() / 20
					verticalSlider:SetValue(verticalSlider:GetValue() + amountToScroll)
					return
				end

			elseif (delta > 0) then
				if (verticalSlider:IsShown()) then
					local amountToScroll = frameBody:GetHeight() / 20
					verticalSlider:SetValue(verticalSlider:GetValue() - amountToScroll)
					return
				end
			end

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
				scaleSlider:SetValue(min(scaleSlider:GetValue() + 0.1, 1))

			elseif (IsControlKeyDown() and delta < 0) then
				scaleSlider:SetValue(max(scaleSlider:GetValue() - 0.1, 0.15))

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

	--mouse drag
	frameBody:SetScript("OnMouseDown", function(self, button)
		local x = GetCursorPosition()
		self.MouseX = x

		frameBody:SetScript("OnUpdate", function(self, deltaTime)
			local x = GetCursorPosition()
			local deltaX = self.MouseX - x
			local current = horizontalSlider:GetValue()
			horizontalSlider:SetValue(current + (deltaX * 1.2) * ((IsShiftKeyDown() and 2) or (IsAltKeyDown() and 0.5) or 1))
			self.MouseX = x
		end)
	end)

	frameBody:SetScript("OnMouseUp", function(self, button)
		frameBody:SetScript("OnUpdate", nil)
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