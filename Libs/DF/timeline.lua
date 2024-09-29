
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
---@field line_height number
---@field line_padding number
---@field show_elapsed_timeline boolean
---@field elapsed_timeline_height number
---@field header_width number
---@field pixels_per_second number
---@field scale_min number
---@field scale_max number
---@field backdrop backdrop
---@field backdrop_color number[]
---@field backdrop_color_highlight number[]
---@field backdrop_border_color number[]
---@field slider_backdrop backdrop
---@field slider_backdrop_color number[]
---@field slider_backdrop_border_color number[]
---@field title_template string "ORANGE_FONT_TEMPLATE"
---@field text_tempate string "OPTIONS_FONT_TEMPLATE"
---@field on_enter fun(self:frame)
---@field on_leave fun(self:frame)
---@field block_on_enter fun(self:frame)
---@field block_on_leave fun(self:frame)
local timeline_options = {
	width = 400,
	height = 700,
	line_height = 20,
	line_padding = 1,

	show_elapsed_timeline = true,
	elapsed_timeline_height = 20,

	--space to put the player/spell name and icons
	header_width = 150,

	--how many pixels will be use to represent 1 second
	pixels_per_second = 20,

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

	block_on_enter = function(self)

	end,
	block_on_leave = function(self)

	end,
}

---@class df_elapsedtime_options : table
---@field backdrop backdrop
---@field backdrop_color number[]
---@field text_color number[]
---@field text_size number
---@field text_font string
---@field text_outline outline
---@field height number
---@field distance number
---@field distance_min number
---@field draw_line boolean
---@field draw_line_color number[]
---@field draw_line_thickness number
local elapsedtime_frame_options = {
	backdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdrop_color = {.3, .3, .3, .7},

	text_color = {1, 1, 1, 1},
	text_size = 12,
	text_font = "Arial Narrow",
	text_outline = "NONE",

	height = 20,

	distance = 200, --distance in pixels between each label informing the time
	distance_min = 50, --minimum distance in pixels
	draw_line = true, --if true it'll draw a vertical line to represent a segment
	draw_line_color = {1, 1, 1, 0.2},
	draw_line_thickness = 1,
}

---@class df_elapsedtime_label : fontstring
---@field line texture

---@class df_elapsedtime_mixin : table
---@field GetLabel fun(self:df_elapsedtime, index:number):fontstring
---@field Reset fun(self:df_elapsedtime)
---@field Refresh fun(self:df_elapsedtime, elapsedTime:number, scale:number)
detailsFramework.TimeLineElapsedTimeFunctions = {
	--get a label and update its appearance
	GetLabel = function(self, index)
		---@type df_elapsedtime_label
		local label = self.labels[index]

		if (not label) then
			label = self:CreateFontString(nil, "artwork", "GameFontNormal")
			---@cast label df_elapsedtime_label
			label.line = self:CreateTexture(nil, "artwork")
			label.line:SetColorTexture(1, 1, 1)
			label.line:SetPoint("topleft", label, "bottomleft", 0, -2)
			self.labels[index] = label
		end

		detailsFramework:SetFontColor(label, self.options.text_color)
		detailsFramework:SetFontSize(label, self.options.text_size)
		detailsFramework:SetFontFace(label, self.options.text_font)
		detailsFramework:SetFontOutline(label, self.options.text_outline)

		if (self.options.draw_line) then
			label.line:SetVertexColor(unpack(self.options.draw_line_color))
			label.line:SetWidth(self.options.draw_line_thickness)
			label.line:Show()
		else
			label.line:Hide()
		end

		return label
	end,

	Reset = function(self)
		for i = 1, #self.labels do
			self.labels[i]:Hide()
		end
	end,

	Refresh = function(self, elapsedTime, scale)
		local parent = self:GetParent()

		self:SetHeight(self.options.height)
		local effectiveArea = self:GetWidth() --already scaled down width
		local pixelPerSecond = elapsedTime / effectiveArea --how much 1 pixels correlate to time

		local distance = self.options.distance --pixels between each segment
		local minDistance = self.options.distance_min --min pixels between each segment

		--scale the distance between each label showing the time with the parent's scale
		distance = distance * scale
		distance = max(distance, minDistance)

		local amountSegments = ceil (effectiveArea / distance)

		for i = 1, amountSegments do
			---@type df_elapsedtime_label
			local label = self:GetLabel(i)
			local xOffset = distance * (i - 1)
			label:SetPoint("left", self, "left", xOffset, 0)

			local secondsOfTime = pixelPerSecond * xOffset

			label:SetText(detailsFramework:IntegerToTimer(floor(secondsOfTime)))

			if (label.line:IsShown()) then
				label.line:SetHeight(parent:GetParent():GetHeight())
			end

			label:Show()
		end
	end,
}

---@class df_elapsedtime : frame, df_elapsedtime_mixin, df_optionsmixin
---@field labels table<number, df_elapsedtime_label>

---creates a frame to show the elapsed time in a row
---@param parent frame
---@param name string?
---@param options df_elapsedtime_options?
function detailsFramework:CreateElapsedTimeFrame(parent, name, options)
	local elapsedTimeFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

	detailsFramework:Mixin(elapsedTimeFrame, detailsFramework.OptionsFunctions)
	detailsFramework:Mixin(elapsedTimeFrame, detailsFramework.LayoutFrame)
	detailsFramework:Mixin(elapsedTimeFrame, detailsFramework.TimeLineElapsedTimeFunctions)

	elapsedTimeFrame:BuildOptionsTable(elapsedtime_frame_options, options)

	elapsedTimeFrame:SetBackdrop(elapsedTimeFrame.options.backdrop)
	elapsedTimeFrame:SetBackdropColor(unpack(elapsedTimeFrame.options.backdrop_color))

	elapsedTimeFrame.labels = {}

	return elapsedTimeFrame
end

---@class df_timeline_block_data : table
---@field [1] number timeInSeconds
---@field [2] number length
---@field [3] boolean isAura
---@field [4] number auraDuration
---@field [5] number blockSpellId
---@field payload any

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

---@class df_timeline_line_block : frame
---@field icon texture
---@field text fontstring
---@field background texture
---@field auraLength texture
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
		local parent = self:GetParent():GetParent()
		local data = parent.data
		local defaultColor = parent.defaultColor --guarantee to have a value

		self:Show()

		--none of these values are scaled, need to calculate
		local pixelPerSecond = parent.pixelPerSecond
		local totalLength = parent.totalLength
		local scale = parent.currentScale

		pixelPerSecond = pixelPerSecond * scale

		local headerWidth = parent.headerWidth

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

		self:SetWidth(5000)

		local timelineData = lineData.timeline
		local spellId = lineData.spellId
		local useIconOnBlock = data.useIconOnBlocks

		local baseFrameLevel = parent:GetFrameLevel() + 10

		for i = 1, #timelineData do
			local blockInfo = timelineData[i]

			local timeInSeconds = blockInfo[1]
			local length = blockInfo[2]
			local isAura = blockInfo[3]
			local auraDuration = blockInfo[4]
			local blockSpellId = blockInfo[5]

			local payload = blockInfo.payload

			local xOffset = pixelPerSecond * timeInSeconds
			local width = pixelPerSecond * length

			if (timeInSeconds < -0.2) then
				xOffset = xOffset / 2.5
			end

			local block = self:GetBlock(i)
			block:Show()
			block:SetFrameLevel(baseFrameLevel + i)

			PixelUtil.SetPoint(block, "left", self, "left", xOffset + headerWidth, 0)

			block.info.spellId = blockSpellId or spellId
			block.info.time = timeInSeconds
			block.info.duration = auraDuration
			block.info.payload = payload

			if (useIconOnBlock) then
				local iconTexture = lineData.icon
				if (blockSpellId) then
					iconTexture = GetSpellTexture(blockSpellId)
				end

				block.icon:SetTexture(iconTexture)
				block.icon:SetTexCoord(.1, .9, .1, .9)
				block.icon:SetAlpha(.834)
				block.icon:SetSize(self:GetHeight(), self:GetHeight())

				if (timeInSeconds < -0.2) then
					block.icon:SetDesaturated(true)
				else
					block.icon:SetDesaturated(false)
				end

				PixelUtil.SetSize(block, self:GetHeight(), self:GetHeight())

				if (isAura) then
					block.auraLength:Show()
					block.auraLength:SetWidth(pixelPerSecond * isAura)
					block:SetWidth(max(pixelPerSecond * isAura, 16))
				else
					block.auraLength:Hide()
				end

				block.background:SetVertexColor(0, 0, 0, 0)
			else
				block.background:SetVertexColor(0, 0, 0, 0)
				PixelUtil.SetSize(block, max(width, 16), self:GetHeight())
				block.auraLength:Hide()
			end
		end
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
			local text = block:CreateFontString(nil, "artwork")
			local auraLength = block:CreateTexture(nil, "border")

			background:SetAllPoints()
			icon:SetPoint("left")
			text:SetPoint("left", icon, "left", 2, 0)
			auraLength:SetPoint("topleft", icon, "topleft", 0, 0)
			auraLength:SetPoint("bottomleft", icon, "bottomleft", 0, 0)
			auraLength:SetColorTexture(1, 1, 1, 1)
			auraLength:SetVertexColor(1, 1, 1, 0.1)

			block.icon = icon
			block.text = text
			block.background = background
			block.auraLength = auraLength

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
	end,
}

---@class df_timeline_line : frame, df_timeline_line_mixin
---@field spellId number
---@field icon df_image
---@field text df_label
---@field dataIndex number
---@field backdrop_color table
---@field backdrop_color_highlight table

---@class df_timeline : scrollframe, df_timeline_mixin, df_optionsmixin, df_framelayout, df_lineindicator
---@field body frame
---@field elapsedTimeFrame df_elapsedtime
---@field horizontalSlider slider
---@field scaleSlider slider
---@field verticalSlider slider
---@field currentScale number
---@field data df_timeline_scrolldata
---@field lines df_timeline_line[]
---@field options table
---@field pixelPerSecond number
---@field totalLength number
---@field defaultColor table
---@field headerWidth number

---@class df_timeline_mixin : table
---@field GetLine fun(self:df_timeline, index:number):df_timeline_line
---@field ResetAllLines fun(self:df_timeline)
---@field RefreshTimeLine fun(self:df_timeline)
---@field SetData fun(self:df_timeline, data:table)
---@field GetData fun(self:df_timeline):table
detailsFramework.TimeLineMixin = {
	GetLine = function(self, index)
		local line = self.lines[index]
		if (not line) then
			--create a new line
			---@type df_timeline_line
			line = CreateFrame("frame", "$parentLine" .. index, self.body, "BackdropTemplate")
			detailsFramework:Mixin(line, detailsFramework.TimeLine_LineMixin)
			self.lines[index] = line

			local lineHeader = CreateFrame("frame", nil, line, "BackdropTemplate")
			lineHeader:SetPoint("topleft", line, "topleft", 0, 0)
			lineHeader:SetPoint("bottomleft", line, "bottomleft", 0, 0)
			lineHeader:SetScript("OnEnter", self.options.header_on_enter)
			lineHeader:SetScript("OnLeave", self.options.header_on_leave)

			line.lineHeader = lineHeader

			--store the individual textures that shows the timeline information
			line.blocks = {}

			if (self.options.show_elapsed_timeline) then
				line:SetPoint("topleft", self.body, "topleft", 1, -((index-1) * (self.options.line_height + 1)) - 2 - self.options.elapsed_timeline_height)
			else
				line:SetPoint("topleft", self.body, "topleft", 1, -((index-1) * (self.options.line_height + 1)) - 1)
			end
			line:SetSize(1, self.options.line_height) --width is set when updating the frame

			line:SetScript("OnEnter", self.options.on_enter)
			line:SetScript("OnLeave", self.options.on_leave)
			line:SetMouseClickEnabled(false)

			line:SetBackdrop(self.options.backdrop)
			line:SetBackdropColor(unpack(self.options.backdrop_color))
			line:SetBackdropBorderColor(unpack(self.options.backdrop_border_color))

			local icon = detailsFramework:CreateImage(line, "", self.options.line_height, self.options.line_height)
			icon:SetPoint("left", line, "left", 2, 0)
			line.icon = icon

			local text = detailsFramework:CreateLabel(line, "", detailsFramework:GetTemplate("font", self.options.title_template))
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

	--todo
	--make the on enter and leave tooltips
	--set icons and texts
	--skin the sliders

	RefreshTimeLine = function(self)
		--debug
		--self.currentScale = 1

		--calculate the total width
		local pixelPerSecond = self.options.pixels_per_second
		local totalLength = self.data.length or 1 --total time
		local currentScale = self.currentScale

		self.scaleSlider:Enable()

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

		local defaultColor = self.data.defaultColor or {1, 1, 1, 1}

		--cache values
		self.pixelPerSecond = pixelPerSecond
		self.totalLength = totalLength
		self.defaultColor = defaultColor
		self.headerWidth = self.options.header_width

		--calculate the total height
		local lineHeight = self.options.line_height
		local linePadding = self.options.line_padding

		local bodyHeight = (lineHeight + linePadding) * #self.data.lines
		self.body:SetHeight(bodyHeight)
		self.verticalSlider:SetMinMaxValues(0, max(bodyHeight - self:GetHeight(), 0))
		self.verticalSlider:SetValue(0)

		--refresh lines
		self:ResetAllLines()
		for i = 1, #self.data.lines do
			local line = self:GetLine(i)
			line.dataIndex = i --this index is used inside the line update function to know which data to get
			line.lineHeader:SetWidth(self.options.header_width)
			line:SetBlocksFromData() --the function to update runs within the line object
		end

		--refresh elapsed time frame
		--the elapsed frame must have a width before the refresh function is called
		self.elapsedTimeFrame:ClearAllPoints()
		self.elapsedTimeFrame:SetPoint("topleft", self.body, "topleft", self.options.header_width, 0)
		self.elapsedTimeFrame:SetPoint("topright", self.body, "topright", 0, 0)
		self.elapsedTimeFrame:Reset()

		self.elapsedTimeFrame:Refresh(self.data.length, self.currentScale)

		--refresh the indicator lines
		self:LineIndicatorSetXOffset(self.options.header_width)
		self:LineIndicatorSetValueType("TIME")
		self:LineIndicatorSetElapsedTime(self.data.length)
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

---@class df_lineindicator_data : table
---@field value number
---@field valueType "PERCENT"|"TIME"|"PIXELS"
---@field width number
---@field color number[]
---@field alpha number
---@field onClick fun(self:df_lineindicator_line)
---@field onEnter fun(self:df_lineindicator_line)
---@field onLeave fun(self:df_lineindicator_line)

---@class df_lineindicator_line : button
---@field xOffset number
---@field index number
---@field data df_lineindicator_data
---@field Texture texture

local lineIndicator_GetValueForMoving = function(self, indicator)
	local targetFrame = self:LineIndicatorGetTarget()
	local data = indicator.data

	if (data.valueType == "PERCENT") then
		local effectiveWidth = targetFrame:GetWidth() - self.xOffset
		local x = indicator:GetLeft() - self.xOffset
		local percent = x / effectiveWidth
		data.value = percent
		return data.value

	elseif (data.valueType == "TIME") then
		local effectiveWidth = targetFrame:GetWidth() - self.xOffset
		local x = indicator:GetLeft() - self.xOffset
		local timePercent = x / effectiveWidth
		data.value = timePercent * self.lineIndicatorTime
		return data.value

	elseif (data.valueType == "PIXELS") then
		local x = indicator:GetLeft() - self.xOffset
		data.value = x
		return data.value
	end
end

---@class df_lineindicator : table, frame
---@field lineIndicatorTime number
---@field xOffset number
---@field lineIndicators df_pool
---@field data table
---@field valueType string
---@field frameTarget frame
---@field scale number
---@field lineHeight number
---@field lineWidth number
---@field color any
---@field ValueFontString fontstring
---@field LineIndicatorConstructor fun(self:df_lineindicator)
---@field LineIndicatorSetTarget fun(self:df_lineindicator, frameTarget:frame)
---@field LineIndicatorsReset fun(self:df_lineindicator)
---@field LineIndicatorCreateLine fun(self:df_lineindicator, index:number):df_lineindicator_line
---@field LineIndicatorGetLine fun(self:df_lineindicator):df_lineindicator_line
---@field LineIndicatorSetElapsedTime fun(self:df_lineindicator, totalTime:number)
---@field LineIndicatorSetLinePosition fun(self:df_lineindicator, line:df_lineindicator_line, value:number, valueType:string)
---@field LineIndicatorSetValueType fun(self:df_lineindicator, valueType:"PERCENT"|"TIME"|"PIXELS")
---@field LineIndicatorAddData fun(self:df_lineindicator, data:df_lineindicator_data)
---@field LineIndicatorSetData fun(self:df_lineindicator, data:df_lineindicator_data[])
---@field LineIndicatorRemoveData fun(self:df_lineindicator, dataId:number|df_lineindicator_data)
---@field LineIndicatorAddLine fun(self:df_lineindicator, value:number, valueType:string) : df_lineindicator_line
---@field LineIndicatorSetXOffset fun(self:df_lineindicator, xOffset:number)
---@field LineIndicatorSetScale fun(self:df_lineindicator, scale:number)
---@field LineIndicatorRefresh fun(self:df_lineindicator)
---@field LineIndicatorSetAllLinesWidth fun(self:df_lineindicator, width:number)
---@field LineIndicatorSetAllLinesHeight fun(self:df_lineindicator, height:number) set the height of all lines
---@field LineIndicatorSetAllLinesColor fun(self:df_lineindicator, color:any, g:number?, b:number?)
---@field LineIndicatorSetLineWidth fun(self:df_lineindicator, dataId:number|df_lineindicator_data, newWidth:number)
---@field LineIndicatorSetLineColor fun(self:df_lineindicator, dataId:number|df_lineindicator_data, color:any, g:number?, b:number?)
---@field LineIndicatorSetLineAlpha fun(self:df_lineindicator, dataId:number|df_lineindicator_data, alpha:number)
detailsFramework.LineIndicatorMixin = {
	LineIndicatorConstructor = function(self)
		self.lineIndicatorTime = 0
		self.lineIndicators = detailsFramework:CreatePool(detailsFramework.LineIndicatorMixin.LineIndicatorCreateLine, self)
		self.lineIndicators:SetOnReset(function(lineIndicator) lineIndicator:Hide() lineIndicator:ClearAllPoints() end)
		self.frameTarget = nil
		self.data = {}
		self.valueType = "PIXELS"
		self.xOffset = 0
		self.scale = 1
		self.lineHeight = 50
		self.lineWidth = 3
		self.color = {1, 1, 1}
	end,

	LineIndicatorSetTarget = function(self, frameTarget)
		self.frameTarget = frameTarget
	end,

	LineIndicatorGetTarget = function(self)
		return self.frameTarget or self
	end,

	--hide all indicators and clear their points
	---@param self df_lineindicator
	LineIndicatorsReset = function(self)
		self.lineIndicatorTime = 0
		self.lineIndicators:Reset()
	end,

	---@param pool df_pool
	---@param self df_lineindicator
	---@return df_lineindicator_line
	LineIndicatorCreateLine = function(pool, self)
		local index = pool:GetAmount() + 1
		local parentName = self:GetName()
		local indicatorName = parentName and parentName .. "LineIndicator" .. index

		local targetFrame = self:LineIndicatorGetTarget()

		---@type df_lineindicator_line
		local indicator = CreateFrame("button", indicatorName, targetFrame, "BackdropTemplate")
		indicator:SetSize(3, targetFrame:GetParent():GetHeight())
		indicator:SetFrameLevel(targetFrame:GetFrameLevel() + 10)

		local texture = indicator:CreateTexture(nil, "background")
		texture:SetColorTexture(1, 1, 1, 1)
		texture:SetAllPoints()

		indicator:SetMovable(true)
		indicator:SetScript("OnMouseDown", function(_, button)
			if (button == "LeftButton") then
				if (not self.ValueFontString) then
					self.ValueFontString = self:CreateFontString(nil, "overlay", "GameFontNormal")
					self.ValueFontString.Background = self:CreateTexture(nil, "artwork")
					self.ValueFontString.Background:SetColorTexture(0, 0, 0, 0.7)
					self.ValueFontString.Background:SetPoint("topleft", self.ValueFontString, "topleft", -2, 2)
					self.ValueFontString.Background:SetPoint("bottomright", self.ValueFontString, "bottomright", 2, -2)
				end

				local mouseX = GetCursorPosition()
				local point1, point2, point3, point4, point5 = indicator:GetPoint(1)
				self.ValueFontString:Show()
				self.ValueFontString:ClearAllPoints()
				self.ValueFontString:SetPoint("bottomleft", indicator, "bottomright", 2, 0)

				indicator:SetScript("OnUpdate", function()
					local offset = GetCursorPosition() - mouseX
					indicator:SetPoint(point1, point2, point3, point4 + offset, point5)
					local value = lineIndicator_GetValueForMoving(self, indicator)

					if (indicator.data.valueType == "TIME") then
						self.ValueFontString:SetText(detailsFramework:IntegerToTimer(value))

					elseif (indicator.data.valueType == "PERCENT") then
						self.ValueFontString:SetText(format("%.2f%%", value * 100))

					elseif (indicator.data.valueType == "PIXELS") then
						self.ValueFontString:SetText(value)
					end
				end)
			end
		end)

		indicator:SetScript("OnMouseUp", function(_, button)
			if (button == "LeftButton") then
				indicator:StopMovingOrSizing()
				indicator:SetScript("OnUpdate", nil)
				local value = lineIndicator_GetValueForMoving(self, indicator)
				self.ValueFontString:Hide()
				self.ValueFontString.Background:Hide()
				self:LineIndicatorRefresh()
			end
		end)

		indicator.Texture = texture

		return indicator
	end,

	LineIndicatorGetLine = function(self)
		assert(self.lineIndicators, "LineIndicatorGetLine(): LineIndicatorConstructor() not called.")
		local thisIndicator = self.lineIndicators:Acquire()
		return thisIndicator
	end,

	LineIndicatorSetElapsedTime = function(self, totalTime)
		self.lineIndicatorTime = totalTime
	end,

	LineIndicatorSetLinePosition = function(self, line, value, valueType)
		local targetFrame = self:LineIndicatorGetTarget()

		if (valueType) then
			if (valueType == "PERCENT") then
				local effectiveWidth = targetFrame:GetWidth() - self.xOffset
				effectiveWidth = effectiveWidth * self.scale
				local x = effectiveWidth * value
				line:SetPoint("left", targetFrame, "left", self.xOffset + x, 0)
				line.xOffset = x

			elseif (valueType == "TIME") then
				assert(self.lineIndicatorTime > 0, "LineIndicatorSetElapsedTime(self, totalTime) must be called before SetLineIndicatorPosition() with valueType TIME.")

				local timePercent = value / self.lineIndicatorTime

				local effectiveWidth = targetFrame:GetWidth() - self.xOffset
				effectiveWidth = effectiveWidth * self.scale

				local x = effectiveWidth * timePercent
				line:SetPoint("left", targetFrame, "left", self.xOffset + x, 0)
				line.xOffset = x

			elseif (valueType == "PIXELS") then
				value = value * self.scale
				line:SetPoint("left", targetFrame, "left", self.xOffset + value, 0)
				line.xOffset = x
			end
		end
	end,

	LineIndicatorRefresh = function(self)
		--release all objects
		self.lineIndicators:Reset()
		--redraw all objects
		for i = 1, #self.data do
			local data = self.data[i]
			if (not data.valueType) then
				data.valueType = self.valueType
			end

			local line = self:LineIndicatorAddLine(data.value, data.valueType)

			line.index = i
			line.data = data
			line:SetHeight(self.lineHeight)
			line:SetWidth(data.width or self.lineWidth)
			line:SetAlpha(data.alpha or 1)
			line.Texture:SetVertexColor(unpack(self.color))
			line:SetScript("OnClick", data.onClick)
			line:SetScript("OnEnter", data.onEnter)
			line:SetScript("OnLeave", data.onLeave)
		end
	end,

	LineIndicatorSetValueType = function(self, valueType)
		assert(valueType == "PERCENT" or valueType == "TIME" or valueType == "PIXELS", "SetLineIndicatorValueType(valueType): valueType must be PERCENT, TIME or PIXELS.")
		self.valueType = valueType
	end,

	LineIndicatorAddLine = function(self, value, valueType)
		local line = self:LineIndicatorGetLine()
		self:LineIndicatorSetLinePosition(line, value, valueType or self.valueType)
		line:Show()
		return line
	end,

	LineIndicatorRemoveData = function(self, dataId)
		assert(type(dataId) == "number" or type(dataId) == "table", "LineIndicatorRemoveData(dataId): dataId must be the data index or a data table.")

		if (type(dataId) == "number") then
			local index = dataId
			table.remove(self.data, index)

		elseif (type(dataId) == "table") then
			local dataTable = dataId
			for i = 1, #self.data do
				if (self.data[i] == dataTable) then
					table.remove(self.data, i)
					break
				end
			end
		end

		self:LineIndicatorRefresh()
	end,

	LineIndicatorAddData = function(self, data)
		self.data[#self.data+1] = data
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetData = function(self, data)
		self.data = data
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetXOffset = function(self, xOffset)
		self.xOffset = xOffset
	end,

	LineIndicatorSetScale = function(self, scale)
		self.scale = scale
	end,

	LineIndicatorSetAllLinesHeight = function(self, height)
		assert(type(height) == "number", "LineIndicatorSetAllLinesHeight(height): height must be a number.")
		self.lineHeight = height
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetAllLinesWidth = function(self, width)
		assert(type(width) == "number", "LineIndicatorSetAllLinesWidth(width): width must be a number.")
		self.lineWidth = width
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetLineWidth = function(self, dataId, newWidth)
		assert(type(dataId) == "number" or type(dataId) == "table", "LineIndicatorSetLineWidth(dataId): dataId must be the data index or a data table.")

		if (type(dataId) == "number") then
			local index = dataId
			local data = self.data[index]
			if (data) then
				data.width = newWidth
			end

		elseif (type(dataId) == "table") then
			local dataTable = dataId
			for i = 1, #self.data do
				if (self.data[i] == dataTable) then
					self.data[i].width = newWidth
					break
				end
			end
		end

		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetAllLinesColor = function(self, color, g, b)
		local r, g, b = detailsFramework:ParseColors(color, g, b)
		self.color[1] = r
		self.color[2] = g
		self.color[3] = b
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetLineColor = function(self, dataId, color, g, b)
		assert(type(dataId) == "number" or type(dataId) == "table", "LineIndicatorSetLineColor(dataId): dataId must be the data index or a data table.")

		local r, g, b = detailsFramework:ParseColors(color, g, b)

		if (type(dataId) == "number") then
			local index = dataId
			local data = self.data[index]
			if (data) then
				data.color[1] = r
				data.color[2] = g
				data.color[3] = b
			end

		elseif (type(dataId) == "table") then
			local dataTable = dataId
			for i = 1, #self.data do
				if (self.data[i] == dataTable) then
					self.data[i].color[1] = r
					self.data[i].color[2] = g
					self.data[i].color[3] = b
					break
				end
			end
		end

		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetLineAlpha = function(self, dataId, alpha)
		assert(type(dataId) == "number" or type(dataId) == "table", "LineIndicatorSetLineAlpha(dataId): dataId must be the data index or a data table.")

		if (type(dataId) == "number") then
			local index = dataId
			local data = self.data[index]
			if (data) then
				data.alpha = alpha
			end

		elseif (type(dataId) == "table") then
			local dataTable = dataId
			for i = 1, #self.data do
				if (self.data[i] == dataTable) then
					self.data[i].alpha = alpha
					break
				end
			end
		end

		self:LineIndicatorRefresh()
	end,
}


---@class df_timeline_body : frame, df_lineindicator

---creates a scrollable panel with vertical, horizontal and scale sliders to show a timeline
---also creates a frame for the elapsed timeline at the top, it shows the time in seconds
---@param parent frame
---@param name string
---@param timelineOptions df_timeline_options
---@param elapsedtimeOptions df_elapsedtime_options
---@return df_timeline
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
	frameCanvas.data = {} --placeholder
	frameCanvas.lines = {}

	frameCanvas.currentScale = 0.5
	frameCanvas:SetSize(width, height)

	detailsFramework:ApplyStandardBackdrop(frameCanvas)

	local frameBody = CreateFrame("frame", nil, frameCanvas, "BackdropTemplate")
	frameBody:SetSize(scrollWidth, scrollHeight)
	frameCanvas:LineIndicatorSetTarget(frameBody)

	frameCanvas:SetScrollChild(frameBody)
	frameCanvas.body = frameBody

	frameCanvas:BuildOptionsTable(timeline_options, timelineOptions)


	--create elapsed time frame
	frameCanvas.elapsedTimeFrame = detailsFramework:CreateElapsedTimeFrame(frameBody, frameCanvas:GetName() and frameCanvas:GetName() .. "ElapsedTimeFrame", elapsedtimeOptions)

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
		horizontalSlider:SetSize(width + 20, 20)
		horizontalSlider:SetPoint("topleft", frameCanvas, "bottomleft")
		horizontalSlider:SetMinMaxValues(0, scrollWidth)
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
		scaleSlider:SetSize(width + 20, 20)
		scaleSlider:SetPoint("topleft", horizontalSlider, "bottomleft", 0, -2)
		scaleSlider:SetMinMaxValues(frameCanvas.options.scale_min, frameCanvas.options.scale_max)
		scaleSlider:SetValue(detailsFramework:GetRangeValue(frameCanvas.options.scale_min, frameCanvas.options.scale_max, 0.5))

		scaleSlider:SetScript("OnValueChanged", function(self)
			local stepValue = ceil(self:GetValue() * 100) / 100
			if (stepValue ~= frameCanvas.currentScale) then
				local current = stepValue
				frameCanvas.currentScale = stepValue
				frameCanvas:RefreshTimeLine()
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
		verticalSlider:SetSize(20, height - 2)
		verticalSlider:SetPoint("topleft", frameCanvas, "topright", 0, 0)
		verticalSlider:SetMinMaxValues(0, scrollHeight)
		verticalSlider:SetValue(0)
		verticalSlider:SetScript("OnValueChanged", function(self)
		    frameCanvas:SetVerticalScroll(self:GetValue())
		end)

	--mouse scroll
		frameCanvas:EnableMouseWheel(true)
		frameCanvas:SetScript("OnMouseWheel", function(self, delta)
			local minValue, maxValue = horizontalSlider:GetMinMaxValues()
			local currentHorizontal = horizontalSlider:GetValue()

			if (IsShiftKeyDown() and delta < 0) then
				local amountToScroll = frameBody:GetHeight() / 20
				verticalSlider:SetValue(verticalSlider:GetValue() + amountToScroll)

			elseif (IsShiftKeyDown() and delta > 0) then
				local amountToScroll = frameBody:GetHeight() / 20
				verticalSlider:SetValue(verticalSlider:GetValue() - amountToScroll)

			elseif (IsControlKeyDown() and delta > 0) then
				scaleSlider:SetValue(min(scaleSlider:GetValue() + 0.1, 1))

			elseif (IsControlKeyDown() and delta < 0) then
				scaleSlider:SetValue(max(scaleSlider:GetValue() - 0.1, 0.15))

			elseif (delta < 0 and currentHorizontal < maxValue) then
				local amountToScroll = frameBody:GetWidth() / 20
				horizontalSlider:SetValue(currentHorizontal + amountToScroll)

			elseif (delta > 0 and maxValue > 1) then
				local amountToScroll = frameBody:GetWidth() / 20
				horizontalSlider:SetValue(currentHorizontal - amountToScroll)

			end
		end)

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

	return frameCanvas
end



--[=[
local f = CreateFrame("frame", "TestFrame", UIParent)
f:SetPoint("center")
f:SetSize(900, 420)
f:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,	insets = {left = 1, right = 1, top = 0, bottom = 1}})

local scroll = DF:CreateTimeLineFrame (f, "$parentTimeLine", {width = 880, height = 400})
scroll:SetPoint("topleft", f, "topleft", 0, 0)

--need fake data to test fills
scroll:SetData ({
	length = 360,
	defaultColor = {1, 1, 1, 1},
	lines = {
			{text = "player 1", icon = "", timeline = {
				--each table here is a block shown in the line
				--is an indexed table with: [1] time [2] length [3] color (if false, use the default) [4] text [5] icon [6] tooltip: if number = spellID tooltip, if table is text lines
				{1, 10}, {13, 11}, {25, 7}, {36, 5}, {55, 18}, {76, 30}, {105, 20}, {130, 11}, {155, 11}, {169, 7}, {199, 16}, {220, 18}, {260, 10}, {290, 23}, {310, 30}, {350, 10}
			}
		}, --end of line 1
	},
})


f:Hide()

--scroll.body:SetScale(0.5)

--]=]