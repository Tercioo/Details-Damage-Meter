
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--horizontal bar with 20 pixels height with many texts indicating the time in seconds, example: 0:10, 0:30, 1:45, 2:00, 2:30, 3:00, 3:30, 4:00

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
            ---@diagnostic disable-next-line: cast-local-type
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

	SetScrollChild = function(self, scrollChild)
		self.scrollChild = scrollChild
	end,

	Refresh = function(self, elapsedTime, scale)
		if (not elapsedTime) then
			--invalid data passed
			return
		end

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
			local label = self:GetLabel(i)
            ---@cast label df_elapsedtime_label
			local xOffset = distance * (i - 1)
			label:SetPoint("left", self, "left", xOffset, 0)

			local secondsOfTime = pixelPerSecond * xOffset

			label:SetText(detailsFramework:IntegerToTimer(floor(secondsOfTime)))

			if (label.line:IsShown()) then
				label.line:SetHeight(self.scrollChild:GetHeight())
			end

			label:Show()
		end
	end,
}

---@class df_elapsedtime : frame, df_elapsedtime_mixin, df_optionsmixin
---@field labels table<number, df_elapsedtime_label>
---@field scrollChild frame

---creates a frame to show the elapsed time in a row
---@param parent frame
---@param name string?
---@param options df_elapsedtime_options?
---@return df_elapsedtime
function detailsFramework:CreateElapsedTimeFrame(parent, name, options)
	---@type df_elapsedtime
	local elapsedTimeFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

	detailsFramework:Mixin(elapsedTimeFrame, detailsFramework.OptionsFunctions)
	detailsFramework:Mixin(elapsedTimeFrame, detailsFramework.LayoutFrame)
	detailsFramework:Mixin(elapsedTimeFrame, detailsFramework.TimeLineElapsedTimeFunctions)

	elapsedTimeFrame:BuildOptionsTable(elapsedtime_frame_options, options)

	elapsedTimeFrame:SetBackdrop(elapsedTimeFrame.options.backdrop)
	elapsedTimeFrame:SetBackdropColor(unpack(elapsedTimeFrame.options.backdrop_color))

	elapsedTimeFrame.scrollChild = parent

	elapsedTimeFrame.labels = {}

	return elapsedTimeFrame
end