
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _

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
---@field left number
---@field index number
---@field data df_lineindicator_data
---@field Texture texture

---@param self df_lineindicator
---@param indicator df_lineindicator_line
local lineIndicator_GetValueForMoving = function(self, indicator, leftDiff)
	local targetFrame = self:LineIndicatorGetTarget()
	local data = indicator.data

	if (data.valueType == "PERCENT") then
		local effectiveWidth = targetFrame:GetWidth() - self.lineIndicatorXOffset
		local x = indicator:GetLeft() - self.lineIndicatorXOffset
		local percent = x / effectiveWidth
		data.value = percent
		return data.value

	elseif (data.valueType == "TIME") then
		local pixelPerSecond = self.lineIndicatorPixelPerSecond

		if (leftDiff) then --leftDiff is the amount of pixels the indicator has moved
			--scale the pixels per second with the scale set
			pixelPerSecond = pixelPerSecond * self.lineIndicatorScale
			--get the time difference in seconds by dividing the pixels moved by the pixels per second
			local timeDiff = leftDiff / pixelPerSecond
			--add the time difference to the current value
			data.value = data.value + timeDiff
			return data.value
		else
			local effectiveWidth = targetFrame:GetWidth() - self.lineIndicatorXOffset
			local indicatorXOffset = indicator:GetLeft() - self.lineIndicatorXOffset
			local timePercent = indicatorXOffset / effectiveWidth
			data.value = timePercent * self.lineIndicatorTotalTime
			return data.value
		end

	elseif (data.valueType == "PIXELS") then
		local x = indicator:GetLeft() - self.lineIndicatorXOffset
		data.value = x
		return data.value
	end
end

---@class df_lineindicator : table, frame
---@field lineIndicatorTotalTime number
---@field lineIndicatorXOffset number
---@field lineIndicators df_pool
---@field lineIndicatorData table
---@field lineIndicatorValueType string
---@field lineIndicatorFrameTarget frame
---@field lineIndicatorScale number
---@field lineIndicatorLineHeight number
---@field lineIndicatorLineWidth number
---@field lineIndicatorPixelPerSecond number
---@field lineIndicatorMouseEnabled boolean
---@field lineIndicatorColor any
---@field lineIndicatorValueFontString fontstring
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
---@field LineIndicatorGetTarget fun(self:df_lineindicator):frame
---@field LineIndicatorSetPixelsPerSecond fun(self:df_lineindicator, pixelsPerSecond:number)
detailsFramework.LineIndicatorMixin = {
	LineIndicatorConstructor = function(self)
		self.lineIndicatorTotalTime = 0
		self.lineIndicators = detailsFramework:CreatePool(detailsFramework.LineIndicatorMixin.LineIndicatorCreateLine, self)
		self.lineIndicators:SetOnReset(function(lineIndicator) lineIndicator:Hide() lineIndicator:ClearAllPoints() end)
		self.lineIndicatorFrameTarget = nil
		self.lineIndicatorData = {}
		self.lineIndicatorValueType = "PIXELS"
		self.lineIndicatorXOffset = 0
		self.lineIndicatorScale = 1
		self.lineIndicatorLineHeight = 50
		self.lineIndicatorLineWidth = 3
		self.lineIndicatorColor = {1, 1, 1}
		self.lineIndicatorPixelPerSecond = 20
		self.lineIndicatorMouseEnabled = true
	end,

	LineIndicatorSetTarget = function(self, frameTarget)
		self.lineIndicatorFrameTarget = frameTarget
	end,

	LineIndicatorGetTarget = function(self)
		return self.lineIndicatorFrameTarget or self
	end,

	LineIndicatorSetPixelsPerSecond = function(self, pixelsPerSecond)
		self.lineIndicatorPixelPerSecond = pixelsPerSecond
	end,

	--hide all indicators and clear their points
	---@param self df_lineindicator
	LineIndicatorsReset = function(self)
		self.lineIndicatorTotalTime = 0
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
		indicator:RegisterForDrag("LeftButton")

		indicator:SetScript("OnMouseDown", function()
			indicator.left = indicator:GetLeft()
		end)

		indicator:SetScript("OnDragStart", function()
			indicator:StartMoving()
			indicator:SetUserPlaced(false)

			if (not self.lineIndicatorValueFrame) then
				self.lineIndicatorValueFrame = CreateFrame("frame", nil, self)
				self.lineIndicatorValueFrame:SetSize(100, 20)
				self.lineIndicatorValueFrame:SetFrameLevel(self:GetFrameLevel() + 11)

				local valueString = self.lineIndicatorValueFrame:CreateFontString(nil, "overlay", "GameFontNormal")
				valueString:SetPoint("left", self.lineIndicatorValueFrame, "left", 2, 0)
				self.lineIndicatorValueFrame.lineIndicatorValueFontString = valueString

				valueString.Background = self.lineIndicatorValueFrame:CreateTexture(nil, "artwork")
				valueString.Background:SetColorTexture(0, 0, 0, 0.7)
				valueString.Background:SetPoint("topleft", valueString, "topleft", -2, 4)
				valueString.Background:SetPoint("bottomright", valueString, "bottomright", 2, -4)
			end

			self.lineIndicatorValueFrame:Show()
			self.lineIndicatorValueFrame:ClearAllPoints()
			--self.lineIndicatorValueFrame:SetPoint("bottomleft", indicator, "bottomright", 2, 0)

			local leftValue = indicator.left

			indicator:SetScript("OnUpdate", function()
				local newLeftValue = indicator:GetLeft()
				local leftDiff = newLeftValue - leftValue --how much the indicator was moved

				local value = lineIndicator_GetValueForMoving(self, indicator, leftDiff)
				leftValue = newLeftValue
				indicator.left = newLeftValue

				--detailsFramework:DebugVisibility(self.lineIndicatorValueFrame)
				self.lineIndicatorValueFrame:SetPoint("topleft", targetFrame, "topleft", newLeftValue + 2, -2)

				if (indicator.data.valueType == "TIME") then
					self.lineIndicatorValueFrame.lineIndicatorValueFontString:SetText(detailsFramework:IntegerToTimer(value))

				elseif (indicator.data.valueType == "PERCENT") then
					self.lineIndicatorValueFrame.lineIndicatorValueFontString:SetText(format("%.2f%%", value * 100))

				elseif (indicator.data.valueType == "PIXELS") then
					self.lineIndicatorValueFrame.lineIndicatorValueFontString:SetText(value)
				end
			end)
		end)

		indicator:SetScript("OnDragStop", function()
			if (self.lineIndicatorValueFrame) then
				self.lineIndicatorValueFrame:Hide()
			end

			indicator:SetScript("OnUpdate", nil)
			indicator:StopMovingOrSizing()

			--[=[ not over engineering this for now
			--need to auto scroll the horizontal scroll frame if the indicator is moved
			--get the amount of width that the horizontal scroll frame has scrolled
			local horizontalScrolled = 0
			if (self.GetHorizontalScrolledWidth) then
				horizontalScrolled = self:GetHorizontalScrolledWidth() or 0
			end

			--add the amount of width that the horizontal scroll frame has scrolled to the indicator left position
			if (horizontalScrolled ~= 0) then
				local diff = indicator.left + horizontalScrolled
				local value = lineIndicator_GetValueForMoving(self, indicator, diff)
			end
			--]=]

			self:LineIndicatorRefresh()
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
		self.lineIndicatorTotalTime = totalTime
	end,

	LineIndicatorSetLinePosition = function(self, line, value, valueType)
		local targetFrame = self:LineIndicatorGetTarget()

		if (valueType) then
			if (valueType == "PERCENT") then
				local effectiveWidth = targetFrame:GetWidth() - self.lineIndicatorXOffset
				--effectiveWidth = effectiveWidth * self.lineIndicatorScale
				local x = effectiveWidth * value
				line:ClearAllPoints()
				line:SetPoint("topleft", targetFrame, "topleft", self.lineIndicatorXOffset + x, 0)
				line.xOffset = x

			elseif (valueType == "TIME") then
				assert(self.lineIndicatorTotalTime > 0, "LineIndicatorSetElapsedTime(self, totalTime) must be called before SetLineIndicatorPosition() with valueType TIME.")

				local timePercent = value / self.lineIndicatorTotalTime

				local effectiveWidth = targetFrame:GetWidth() - self.lineIndicatorXOffset
				--effectiveWidth = effectiveWidth * self.lineIndicatorScale

				local x = effectiveWidth * timePercent
				line:ClearAllPoints()
				line:SetPoint("left", targetFrame, "left", self.lineIndicatorXOffset + x, 0)
				line:SetHeight(GetScreenHeight())
				line.xOffset = x
				line.left = line:GetLeft()

			elseif (valueType == "PIXELS") then
				--value = value * self.lineIndicatorScale
				line:ClearAllPoints()
				line:SetPoint("topleft", targetFrame, "topleft", self.lineIndicatorXOffset + value, 0)
				line.xOffset = x
			end
		end
	end,

	LineIndicatorRefresh = function(self)
		--release all objects
		self.lineIndicators:Reset()
		--redraw all objects
		for i = 1, #self.lineIndicatorData do
			local data = self.lineIndicatorData[i]
			if (not data.valueType) then
				data.valueType = self.lineIndicatorValueType
			end

			local line = self:LineIndicatorAddLine(data.value, data.valueType)

			line.index = i
			line.data = data

			if (self.lineIndicatorLineHeight == -1) then
				line:SetHeight(GetScreenHeight() * 2)
			else
				line:SetHeight(self.lineIndicatorLineHeight)
			end

			line:SetWidth(data.width or self.lineIndicatorLineWidth)
			line:SetAlpha(data.alpha or 1)
			line.Texture:SetVertexColor(unpack(self.lineIndicatorColor))

			line:SetScript("OnClick", data.onClick)
			line:SetScript("OnEnter", data.onEnter)
			line:SetScript("OnLeave", data.onLeave)

			if (self.lineIndicatorMouseEnabled) then

			end
		end
	end,

	LineIndicatorSetValueType = function(self, valueType)
		assert(valueType == "PERCENT" or valueType == "TIME" or valueType == "PIXELS", "SetLineIndicatorValueType(valueType): valueType must be PERCENT, TIME or PIXELS.")
		self.lineIndicatorValueType = valueType
	end,

	LineIndicatorAddLine = function(self, value, valueType)
		local line = self:LineIndicatorGetLine()
		self:LineIndicatorSetLinePosition(line, value, valueType or self.lineIndicatorValueType)
		line:Show()
		return line
	end,

	LineIndicatorRemoveData = function(self, dataId)
		assert(type(dataId) == "number" or type(dataId) == "table", "LineIndicatorRemoveData(dataId): dataId must be the data index or a data table.")

		if (type(dataId) == "number") then
			local index = dataId
			table.remove(self.lineIndicatorData, index)

		elseif (type(dataId) == "table") then
			local dataTable = dataId
			for i = 1, #self.lineIndicatorData do
				if (self.lineIndicatorData[i] == dataTable) then
					table.remove(self.lineIndicatorData, i)
					break
				end
			end
		end

		self:LineIndicatorRefresh()
	end,

	LineIndicatorAddData = function(self, data)
		self.lineIndicatorData[#self.lineIndicatorData+1] = data
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetData = function(self, data)
		self.lineIndicatorData = data
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetXOffset = function(self, xOffset)
		self.lineIndicatorXOffset = xOffset
	end,

	LineIndicatorSetScale = function(self, scale)
		self.lineIndicatorScale = scale
	end,

	LineIndicatorSetAllLinesHeight = function(self, height)
		assert(type(height) == "number", "LineIndicatorSetAllLinesHeight(height): height must be a number.")
		self.lineIndicatorLineHeight = height
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetAllLinesWidth = function(self, width)
		assert(type(width) == "number", "LineIndicatorSetAllLinesWidth(width): width must be a number.")
		self.lineIndicatorLineWidth = width
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetLineWidth = function(self, dataId, newWidth)
		assert(type(dataId) == "number" or type(dataId) == "table", "LineIndicatorSetLineWidth(dataId): dataId must be the data index or a data table.")

		if (type(dataId) == "number") then
			local index = dataId
			local data = self.lineIndicatorData[index]
			if (data) then
				data.width = newWidth
			end

		elseif (type(dataId) == "table") then
			local dataTable = dataId
			for i = 1, #self.lineIndicatorData do
				if (self.lineIndicatorData[i] == dataTable) then
					self.lineIndicatorData[i].width = newWidth
					break
				end
			end
		end

		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetAllLinesColor = function(self, color, g, b)
		local r, g, b = detailsFramework:ParseColors(color, g, b)
		self.lineIndicatorColor[1] = r
		self.lineIndicatorColor[2] = g
		self.lineIndicatorColor[3] = b
		self:LineIndicatorRefresh()
	end,

	LineIndicatorSetLineColor = function(self, dataId, color, g, b)
		assert(type(dataId) == "number" or type(dataId) == "table", "LineIndicatorSetLineColor(dataId): dataId must be the data index or a data table.")

		local r, g, b = detailsFramework:ParseColors(color, g, b)

		if (type(dataId) == "number") then
			local index = dataId
			local data = self.lineIndicatorData[index]
			if (data) then
				data.color[1] = r
				data.color[2] = g
				data.color[3] = b
			end

		elseif (type(dataId) == "table") then
			local dataTable = dataId
			for i = 1, #self.lineIndicatorData do
				if (self.lineIndicatorData[i] == dataTable) then
					self.lineIndicatorData[i].color[1] = r
					self.lineIndicatorData[i].color[2] = g
					self.lineIndicatorData[i].color[3] = b
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
			local data = self.lineIndicatorData[index]
			if (data) then
				data.alpha = alpha
			end

		elseif (type(dataId) == "table") then
			local dataTable = dataId
			for i = 1, #self.lineIndicatorData do
				if (self.lineIndicatorData[i] == dataTable) then
					self.lineIndicatorData[i].alpha = alpha
					break
				end
			end
		end

		self:LineIndicatorRefresh()
	end,
}