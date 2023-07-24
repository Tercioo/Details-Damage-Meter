
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local CreateFrame = CreateFrame
local unpack = unpack
local wipe = table.wipe
local _

---@class chart_guideline : fontstring
---@field circleTexture texture
---@field guideLine line

---@class chart_nameindicator : frame
---@field Texture texture
---@field Label fontstring

---@class chart_backdropindicator : frame a frame which is used to indicate a specific time frame in the chart with a colored texture
---@field fieldTexture texture the texture which indicates the amount of time the effect was active, it is painted over the background texture
---@field fieldLabel fontstring the label showing the name of the indicator, example: bloodlust, heroism, etc
---@field indicatorTexture texture a small squere texture located in the top right of the chart frame, it is used to indicate the color of the indicator
---@field indicatorLabel fontstring the label showing the name of the indicator within the indicatorTexture
---@field bInUse boolean if the indicator is in use or not
---@field startTime number
---@field endTime number
---@field labelText string
---@field color color

---@alias x_axisdatatype
---| "time" when setting the text into the labels, it will be converted into a time format
---| "number" same as timer, but the number is not comverted to time
---| "value" a fixed table with values is passed by the SetXAxisData() function

---@class df_chartshared: table
---@field yAxisLine line the vertical line which can be anchored in the left or right side of the frame, if the chart is a multi chart, this line is shared by all charts
---@field xAxisLine line the horizontal line which can be anchored in the top or bottom side of the frame, if the chart is a multi chart, this line is shared by all charts
---@field xAxisDataNumber any if the data type of the x axis is "number" or "time"
---@field xAxisDataValues table if the data type of the x axis is "value"
---@field xAxisDataType x_axisdatatype the data type of the x axis, if time, the x axis will be a time axis, if value, the x axis will be a value axis
---@field yAxisLabels chart_guideline[] the vertical axis labels to indicate the values of the chart data
---@field xAxisLabels fontstring[] the horizontal axis labels to indicate the values of the chart data
---@field plotFrame frame the plot frame which is the frame that will hold the chart lines
---@field lineThickness number the thickness of the chart lines
---@field chartLeftOffset number the offset of the left side of the chart frame to the plot frame
---@field chartBottomOffset number the offset of the bottom side of the chart frame to the plot frame
---@field xAxisLabelsYOffset number default: -6, the offset of the horizontal axis labels to the horizontal axis line (y coordinate)
---@field smoothnessLevel number default: 0, the smoothness level of the chart lines, 0 is no smoothness
---@field backdropIndicators chart_backdropindicator[]
---@field nextBackdropIndicator number tell which is the next backdrop indicator to be used
---@field CreateBackdropIndicator fun(self: df_chartmulti|df_chart, index: number) : chart_backdropindicator create a new backdrop indicator
---@field GetBackdropIndicator fun(self: df_chartmulti|df_chart) : chart_backdropindicator get a backdrop indicator by index
---@field ResetBackdropIndicators fun(self: df_chartmulti|df_chart) reset all backdrop indicators
---@field SetAxesColor fun(self: df_chartmulti, red: number|string|table|nil, green: number|nil, blue: number|nil, alpha: number|nil) : boolean set the color of both axis lines
---@field SetAxesThickness fun(self: df_chartmulti, thickness: number) : boolean set the thickness of both axis lines
---@field CreateAxesLines fun(self: df_chartmulti|df_chart, xOffset: number, yOffset: number, whichSide: "left"|"right", thickness: number, amountYLabels: number, amountXLabels: number, red: any, green: number|nil, blue: number|nil, alpha: number|nil)
---@field SetXAxisDataType fun(self: df_chartmulti|df_chart, dataType: x_axisdatatype) : boolean set the data type of the x axis, if time, the x axis will be a time axis, if value, the x axis will be a value axis
---@field SetXAxisData fun(self: df_chartmulti|df_chart, data: any) set the data of the x axis, if time, the x axis will be a time axis, if value, the x axis will be a value axis
---@field SharedContrustor fun(self: df_chartmulti|df_chart) set default values for fields used on both chart types
---@field IsMultiChart fun(self: df_chartmulti|df_chart) : boolean return true if the chart is a multi chart

---@param self df_chart|df_chartmulti
local chartFrameSharedConstructor = function(self)
    self.xAxisDataType = "number"
    self.lineThickness = 2
    self.xAxisDataNumber = 0
    self.xAxisDataValues = {}
    self.xAxisLabels = {}
    self.yAxisLabels = {}
    self.chartLeftOffset = 0
    self.chartBottomOffset = 0
    self.xAxisLabelsYOffset = -6
    self.smoothnessLevel = 0
    self.backdropIndicators = {}
    self.nextBackdropIndicator = 1
end

---@class df_chart: frame, df_data, df_value, df_chartshared
---@field _dataInfo df_data
---@field color number[] red green blue alpha
---@field height number
---@field nextLine number
---@field minValue number
---@field maxValue number
---@field data number[]
---@field lines line[]
---@field fixedLineWidth number
---@field chartName string
---@field ChartFrameConstructor fun(self: df_chart) set the default values for the chart frame
---@field GetLine fun(self: df_chart) : line return a line and also internally handle next line
---@field GetLines fun(self: df_chart) : line[] return a table with all lines already created
---@field GetLineWidth fun(self: df_chart) : number calculate the width of each drawn line
---@field SetLineWidth fun(self: df_chart, width: number) set the line width to a fixed value
---@field GetAmountLines fun(self: df_chart) : number return the amount of lines in use
---@field OnSizeChanged fun(self: df_chart)
---@field HideLines fun(self: df_chart) hide all lines already created
---@field Reset fun(self: df_chart) hide all lines and reset the next line to 1
---@field SetColor fun(self: df_chart, r: number|string|table|nil, g: number|nil, b: number|nil, a: number|nil) set the color for the lines
---@field GetColor fun(self: df_chart) : red, green, blue, alpha
---@field SetLineThickness fun(self: df_chart, thickness: number) set the line thickness
---@field CalcYAxisPointForValue fun(self: df_chart, value: number, plotFrameHeightScaled: number) : number
---@field UpdateFrameSizeCache fun(self: df_chart)
---@field Plot fun(self: df_chart, yPointScale: number|nil, bUpdateLabels: boolean|nil)  draw the graphic using lines and following the data set by SetData() or AddData() in multi chart

---@class df_chartmulti : df_chart, df_chartshared
---@field chartFrames df_chart[]
---@field nextChartselframe number
---@field biggestDataValue number
---@field nextChartFrame number
---@field lineNameIndicators chart_nameindicator[]
---@field MultiChartFrameConstructor fun(self: df_chartmulti)
---@field GetCharts fun(self: df_chartmulti) : df_chart[]
---@field GetChart fun(self: df_chartmulti) : df_chart
---@field AddData fun(self: df_chartmulti, data: table, name: string, red: any, green: number|nil, blue: number|nil, alpha: number|nil)
---@field GetAmountCharts fun(self: df_chartmulti): number
---@field HideCharts fun(self: df_chartmulti)
---@field Reset fun(self: df_chartmulti)
---@field SetChartsMinMaxValues fun(self: df_chartmulti, minValue: number, maxValue: number)
---@field SetMaxDataSize fun(self: df_chartmulti, dataSize: number)
---@field GetMaxDataSize fun(self: df_chartmulti)
---@field SetLineThickness fun(self: df_chart, thickness: number) set the line thickness for all chart frames
---@field UpdateChartNamesIndicator fun(self: df_chartmulti) if the chart names has been passed while adding data, this function will update the chart names indicator
---@field Plot fun(self: df_chartmulti) draw the graphic using lines and following the data set by SetData() or AddData() in multi chart

---create the plot frame which is the frame that will hold the chart lines
---@param self df_chartmulti|df_chart
---@return frame
local createPlotFrame = function(self)
    local plotFrame = CreateFrame("frame", "$parentPlotFrame", self, "BackdropTemplate")
    plotFrame:SetAllPoints()
    self.plotFrame = plotFrame
    return plotFrame
end

---generate the vertical axis labels to indicate the values of the chart data
---@param parent frame
---@param amountLabels number
---@param labelsTable chart_guideline[]
---@param red number
---@param green number
---@param blue number
---@param alpha number
local createVerticalAxisLabels = function(parent, amountLabels, labelsTable, red, green, blue, alpha)
    for i = 1, amountLabels do
        ---@type fontstring
        local label = parent:CreateFontString("$parentYAxisLabel" .. i, "overlay", "GameFontNormal")
        ---@cast label chart_guideline

        label:SetJustifyH("right")
        label:SetTextColor(red, green, blue, alpha)
        detailsFramework:SetFontSize(label, 11)
        table.insert(labelsTable, label)

        local circleTexture = parent:CreateTexture("$parentYAxisLabel" .. i .. "CircleTexture", "border")
        circleTexture:SetSize(4, 4)
        circleTexture:SetTexture([[Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall]])
        circleTexture:SetVertexColor(red, green, blue, alpha)
        circleTexture:SetPoint("right", label, "right", 5, 0)

        local guideLine = parent:CreateLine("$parentYAxisLabel" .. i .. "GuideLine", "border")
        guideLine:SetThickness(1)
        guideLine:SetColorTexture(red, green, blue, 0.05)

        label.circleTexture = circleTexture
        label.guideLine = guideLine
    end
end

---generate the horizontal axis labels to indicate the values of the chart data
---@param parent frame
---@param amountLabels number
---@param labelsTable fontstring[]
---@param red number
---@param green number
---@param blue number
---@param alpha number
local createHorizontalAxisLabels = function(parent, amountLabels, labelsTable, red, green, blue, alpha)
    for i = 1, amountLabels do
        local label = parent:CreateFontString("$parentXAxisLabel" .. i, "overlay", "GameFontNormal")
        label:SetJustifyH("left")
        label:SetTextColor(red, green, blue, alpha)
        detailsFramework:SetFontSize(label, 11)
        table.insert(labelsTable, label)
    end
end

---create the x and y axis lines with their labels
---@param self df_chart|df_chartmulti
---@param xOffset number
---@param yOffset number
---@param whichSide "left"|"right"
---@param thickness number
---@param amountYLabels number
---@param amountXLabels number
---@param red any
---@param green number|nil
---@param blue number|nil
---@param alpha number|nil
---@return boolean
local createAxesLines = function(self, xOffset, yOffset, whichSide, thickness, amountYLabels, amountXLabels, red, green, blue, alpha)
    if (self.axisCreated) then
        return false
    end

    local plotFrame = self.plotFrame

    self.chartLeftOffset = xOffset or 48
    self.chartBottomOffset = yOffset or 28
    whichSide = whichSide or "left"
    thickness = thickness or 1
    amountYLabels = amountYLabels or 10
    amountXLabels = amountXLabels or 10
    red = red or 1
    green = green or 1
    blue = blue or 1
    alpha = alpha or 1

    --adjust the plotFrame size and point taking in consideration of the left and bottom offsets, this is done to free space for the axis labels
    plotFrame:SetSize(self:GetWidth() - self.chartLeftOffset - 10, self:GetHeight() - self.chartBottomOffset - 20)
    plotFrame:ClearAllPoints()
    plotFrame:SetPoint("topleft", self, "topleft", self.chartLeftOffset, -1)
    plotFrame:SetPoint("bottomright", self, "bottomright", -1, self.chartBottomOffset)

    --this is the vertical line which can be anchored in the left or right side of the frame, it separates the chart lines from the labels
    ---@type line
    local yAxisLine = plotFrame:CreateLine("$parentYAxisLine", "overlay")
    self.yAxisLine = yAxisLine
    --and the horizontal line which is always anchored in the bottom of the frame
    ---@type line
    local xAxisLine = plotFrame:CreateLine("$parentXAxisLine", "overlay")
    self.xAxisLine = xAxisLine

    --vertical axis point
    if (whichSide == "left") then
        yAxisLine:SetStartPoint("topleft", plotFrame, 0, -1)
        yAxisLine:SetEndPoint("bottomleft", plotFrame, 0, self.chartBottomOffset * -1)
    else
        yAxisLine:SetStartPoint("topright", plotFrame, 0, -1)
        yAxisLine:SetEndPoint("bottomleft", plotFrame, 0, self.chartBottomOffset)
    end

    --horizontal axis point
    xAxisLine:SetStartPoint("bottomleft", plotFrame, self.chartLeftOffset * -1, 0)
    xAxisLine:SetEndPoint("bottomright", plotFrame, -1, 0)

    red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)
    self:SetAxesColor(red, green, blue, alpha)

    --set the thickness of the both axis lines
    self:SetAxesThickness(thickness)

    createVerticalAxisLabels(plotFrame, amountYLabels, self.yAxisLabels, red, green, blue, alpha)
    createHorizontalAxisLabels(plotFrame, amountXLabels, self.xAxisLabels, red, green, blue, alpha)

    self.axisCreated = true
    return true
end

---@param self df_chartmulti|df_chart
---@param ... any
local setXAxisData = function(self, ...)
    --when the data type is set to time, the x axis data is a number which represents the biggest time in seconds of all charts added
    if (self.xAxisDataType == "time" or self.xAxisDataType == "number") then
        self.xAxisDataNumber = math.max(self.xAxisDataNumber, select(1, ...))
    else
        wipe(self.xAxisDataValues)
        self.xAxisDataValues = {...}
    end
end

---@param self df_chartmulti|df_chart
---@param dataType x_axisdatatype
local setXAxisDataType = function(self, dataType)
    assert(type(dataType) == "string", "string expected on :SetXAxisDataType(string)")
    self.xAxisDataType = dataType

    if (dataType == "time" or dataType == "number") then
        self.xAxisDataNumber = 0

    elseif (dataType == "value") then
        wipe(self.xAxisDataValues)
    end
end

---updates the values of the labels on the axes to reflect the data shown
---@param self df_chart|df_chartmulti
local updateLabelValues = function(self)
    local maxValue = self:GetMaxValue()
    local height = self.plotFrame:GetHeight()
    local verticalLabelCount = #self.yAxisLabels
    local heightStep = height / verticalLabelCount

    --update the labels in the vertical axis line
    for i = 1, verticalLabelCount do
        local label = self.yAxisLabels[i]
        local value = maxValue * (i / verticalLabelCount)
        label:ClearAllPoints()
        label:SetPoint("topright", self.yAxisLine, "bottomleft", -6, heightStep * i + self.chartBottomOffset)
        label:SetText(detailsFramework.FormatNumber(value))

        label.circleTexture:ClearAllPoints()
        label.circleTexture:SetPoint("center", self.yAxisLine, "bottomleft", -2, heightStep * i - 5 + self.chartBottomOffset)

        label.guideLine:SetStartPoint("center", label.circleTexture, 0, 0)
        label.guideLine:SetEndPoint("bottomright", self.plotFrame, 0, heightStep * i - 5)
    end

    --update the labels in the horizontal axis line
    local xAxisDataType = self.xAxisDataType
    local horizontalLabelCount = #self.xAxisLabels
    local width = self.plotFrame:GetWidth()
    local widthStep = width / horizontalLabelCount

    for i = horizontalLabelCount, 1, -1 do
        local label = self.xAxisLabels[i]
        label:ClearAllPoints()
        label:SetJustifyH("right")

        --set the point of each x axis label
        label:SetPoint("topright", self.plotFrame, "bottomleft", widthStep * i, self.xAxisLabelsYOffset or -6)

        --get the type set for the x axis labels and format the value accordingly
        if (xAxisDataType == "time" or xAxisDataType == "number") then
            local maxNumberValue = self.xAxisDataNumber
            local thisValue = maxNumberValue * (i / horizontalLabelCount)
            if (xAxisDataType == "time") then
                label:SetText(detailsFramework:IntegerToTimer(thisValue))
            else
                label:SetText(detailsFramework.FormatNumber(thisValue))
            end

        elseif (xAxisDataType == "value") then
            label:SetText(self.xAxisDataValues[i])
        end
    end
end

detailsFramework.ChartFrameSharedMixin = {
    ---set the color of both axis lines
    ---@param self df_chart|df_chartmulti
    ---@param red any
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    ---@return boolean bColorChanged return true if the color was set, false if the axis lines are not created yet
    SetAxesColor = function(self, red, green, blue, alpha)
        if (not self.yAxisLine) then
            return false
        end

        --set the color of both axis lines
        red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)
        self.yAxisLine:SetColorTexture(red, green, blue, alpha)
        self.xAxisLine:SetColorTexture(red, green, blue, alpha)

        --iterage over all labels and set their color
        for i = 1, #self.yAxisLabels do
            self.yAxisLabels[i]:SetTextColor(red, green, blue, alpha)
        end

        for i = 1, #self.xAxisLabels do
            self.xAxisLabels[i]:SetTextColor(red, green, blue, alpha)
        end

        return true
    end,

    ---set the thickness of both axis lines
    ---@param self df_chart|df_chartmulti
    ---@param thickness number
    ---@return boolean bThicknessChanged return true if the thickness was set, false if the axis lines are not created yet
    SetAxesThickness = function(self, thickness)
        if (not self.yAxisLine) then
            return false
        end
        self.yAxisLine:SetThickness(thickness)
        self.xAxisLine:SetThickness(thickness)
        return true
    end,

    ---create the x and y axis lines with their labels
    ---@param self df_chart|df_chartmulti
    ---@param xOffset number
    ---@param yOffset number
    ---@param whichSide "left"|"right"
    ---@param thickness number
    ---@param amountYLabels number
    ---@param amountXLabels number
    ---@param red any
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    ---@return boolean
    CreateAxesLines = function(self, xOffset, yOffset, whichSide, thickness, amountYLabels, amountXLabels, red, green, blue, alpha)
        return createAxesLines(self, xOffset, yOffset, whichSide, thickness, amountYLabels, amountXLabels, red, green, blue, alpha)
    end,

    ---@param self df_chartmulti|df_chart
    ---@param ... any
    SetXAxisData = function(self, ...)
        setXAxisData(self, ...)
    end,

    ---@param self df_chartmulti|df_chart
    ---@param dataType x_axisdatatype
    SetXAxisDataType = function(self, dataType)
        setXAxisDataType(self, dataType)
    end,

    ---create a new backdrop indicator, this is called from the function GetBackdropIndicator
    ---@param self df_chartmulti|df_chart
    ---@return chart_backdropindicator
    CreateBackdropIndicator = function(self, nextIndicatorIndex)
        ---@type chart_backdropindicator
        local newBackdropIndicator = CreateFrame("frame", "$parentBackdropIndicator" .. nextIndicatorIndex, self.plotFrame)
        --make the backdrop indicators bebelow the plot frame
        newBackdropIndicator:SetFrameLevel(self.plotFrame:GetFrameLevel() - 1)

        newBackdropIndicator.fieldTexture = newBackdropIndicator:CreateTexture(nil, "overlay")
        newBackdropIndicator.fieldTexture:SetAllPoints()

        newBackdropIndicator.fieldLabel = newBackdropIndicator:CreateFontString(nil, "overlay", "GameFontNormal")
        newBackdropIndicator.fieldLabel:SetTextColor(1, 1, 1, 0.3)
        newBackdropIndicator.fieldLabel:SetJustifyH("left")
        newBackdropIndicator.fieldLabel:SetJustifyV("top")
        detailsFramework:SetFontSize(newBackdropIndicator.fieldLabel, 10)
        newBackdropIndicator.fieldLabel:SetPoint("topleft", newBackdropIndicator.fieldTexture, "topleft", 2, -2)

        newBackdropIndicator.indicatorTexture = newBackdropIndicator:CreateTexture(nil, "overlay")
        newBackdropIndicator.indicatorTexture:SetSize(10, 10)

        newBackdropIndicator.indicatorLabel = newBackdropIndicator:CreateFontString(nil, "overlay", "GameFontNormal")
        newBackdropIndicator.indicatorLabel:SetTextColor(1, 1, 1, 0.837)
        newBackdropIndicator.indicatorLabel:SetJustifyH("left")
        newBackdropIndicator.indicatorLabel:SetPoint("left", newBackdropIndicator.indicatorTexture, "right", 2, 0)

        return newBackdropIndicator
    end,

    ---reset the backdrop indicators by hidding all of them
    ---@param self df_chartmulti|df_chart
    ResetBackdropIndicators = function(self)
        for i = 1, #self.backdropIndicators do
            local thisBackdropIndicator = self.backdropIndicators[i]
            thisBackdropIndicator:Hide()
            thisBackdropIndicator.bInUse = false
        end
        self.nextBackdropIndicator = 1
    end,

    ---get a backdrop indicator, if it doesn't exist, create a new one
    ---@param self df_chartmulti|df_chart
    ---@return chart_backdropindicator
    GetBackdropIndicator = function(self)
        local nextIndicator = self.nextBackdropIndicator

        if (not self.backdropIndicators[nextIndicator]) then
            self.backdropIndicators[nextIndicator] = self:CreateBackdropIndicator(nextIndicator)
        end

        self.nextBackdropIndicator = nextIndicator + 1
        return self.backdropIndicators[nextIndicator]
    end,

    ---add a backdrop indicator to the chart
    ---@param self df_chartmulti|df_chart
    ---@param label string this is a text to be displayed on the left side of the indicator and on the top right corner of the chart panel
    ---@param timeStart number the start time of the indicator
    ---@param timeEnd number the end time of the indicator
    ---@param red number|nil
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    AddBackdropIndicator = function(self, label, timeStart, timeEnd, red, green, blue, alpha)
        assert(type(label) == "string", "AddBackdropIndicator: label must be a string.")
        assert(type(timeStart) == "number", "AddBackdropIndicator: timeStart must be a number.")
        assert(type(timeEnd) == "number", "AddBackdropIndicator: timeEnd must be a number.")

        red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)

        local backdropIndicator = self:GetBackdropIndicator()
        backdropIndicator.bInUse = true
        backdropIndicator.startTime = timeStart
        backdropIndicator.endTime = timeEnd
        backdropIndicator.labelText = label
        backdropIndicator.color = {red, green, blue, alpha}

        return true
    end,

    ---when Plot() is called, this function will be called to show the backdrop indicators
    ---it gets the x_axisdatatype or if not existant defaults to "time", calculate the area in pixels using the plot area width and the plot area 'time'
    ---then set the texture color, label texts and show the small squere indicators in the top right of the plot area
    ---@param self df_chartmulti|df_chart
    ShowBackdropIndicators = function(self)
        --get the x axis data type
        local xDataType = self.xAxisDataType or "time"
        --get the max value of the data type
        local dataSize = self.xAxisDataNumber or self.GetDataSize and self:GetDataSize() or 0
        --frame width in pixels
        local frameWidth = self.plotFrame:GetWidth()

        for i = 1, self.nextBackdropIndicator-1 do
            local thisIndicator = self.backdropIndicators[i]
            if (not thisIndicator.bInUse) then
                break
            end

            local startTime = thisIndicator.startTime
            local endTime = thisIndicator.endTime
            local labelText = thisIndicator.labelText
            local color = thisIndicator.color

            --set the point where the indicator will be placed
            local startX = startTime / dataSize * frameWidth
            local endX = endTime / dataSize * frameWidth

            thisIndicator:SetPoint("topleft", self.plotFrame, "topleft", startX, 0)
            thisIndicator:SetPoint("bottomright", self.plotFrame, "bottomleft", endX, 0)

            thisIndicator.fieldLabel:SetText(labelText)
            thisIndicator.fieldTexture:SetColorTexture(unpack(color))

            thisIndicator.indicatorLabel:SetText(labelText)
            thisIndicator.indicatorTexture:SetColorTexture(unpack(color))

            local stringWidth = thisIndicator.indicatorLabel:GetStringWidth()
            local squareWidth = thisIndicator.indicatorTexture:GetWidth()

            if (i == 1) then
                local space = stringWidth + squareWidth
                thisIndicator.indicatorTexture:SetPoint("topright", self.plotFrame, "topright", -space + 2, -30)
            else
                local space = stringWidth + squareWidth + 10
                thisIndicator.indicatorTexture:SetPoint("left", self.backdropIndicators[i-1].indicatorTexture, "left", -space, 0)
            end

            thisIndicator:Show()
        end
    end,
}

detailsFramework.ChartFrameMixin = {
    ---set the default values for the chart frame
    ---@param self df_chart
    ChartFrameConstructor = function(self)
        self.nextLine = 1
        self.minValue = 0
        self.maxValue = 1
        self.lineThickness = 2
        self.data = {}
        self.lines = {}
        self.color = {1, 1, 1, 1}
        --OnSizeChanged
        self:SetScript("OnSizeChanged", self.OnSizeChanged)

        chartFrameSharedConstructor(self)
    end,

    IsMultiChart = function(self)
        return false
    end,

    ---get the chart color
    ---@param self df_chart
    ---@return number red
    ---@return number green
    ---@return number blue
    ---@return number alpha
    GetColor = function(self)
        return unpack(self.color)
    end,

    ---set the color for the lines
    ---@param self df_chart
    ---@param r number
    ---@param g number
    ---@param b number
    ---@param a number|nil
    SetColor = function(self, r, g, b, a)
        r, g, b, a = detailsFramework:ParseColors(r, g, b, a)
        self.color[1] = r
        self.color[2] = g
        self.color[3] = b
        self.color[4] = a or 1
    end,

    ---internally handle next line
    ---@param self df_chart
    GetLine = function(self)
        ---@type line
        local line = self.lines[self.nextLine]

        if (not line) then
            ---@type line
            line = self.plotFrame:CreateLine(nil, "overlay", nil, 5)
            self.lines[self.nextLine] = line
        end

        self.nextLine = self.nextLine + 1
        line:Show()
        return line
    end,

    ---return all lines created for this chart
    ---@param self df_chart
    ---@return line[]
    GetLines = function(self)
        return self.lines
    end,

    ---return the amount of lines in use
    ---@param self df_chart
    ---@return number
    GetAmountLines = function(self)
        return self.nextLine - 1
    end,

    ---hide all lines already created
    ---@param self df_chart
    HideLines = function(self)
        local allLines = self:GetLines()
        for i = 1, #allLines do
            local line = allLines[i]
            line:Hide()
        end
    end,

    ---hide all lines and reset the next line to 1
    ---@param self df_chart
    Reset = function(self)
        self:HideLines()
        self:ResetMinMaxValues()
        self.nextLine = 1
        self.xAxisDataNumber = 0
        self:ResetBackdropIndicators()
    end,

    ---@param self df_chart
    ---@param value number
    SetLineThickness = function(self, value)
        assert(type(value) == "number", "number expected on :SetLineThickness(number)")
        self.lineThickness = value
    end,

    ---calculate the width of each drawn line
    ---@param self df_chart
    GetLineWidth = function(self)
        --self:SetLineWidth(nil) to erase the fixed value
        if (self.fixedLineWidth) then
            return self.fixedLineWidth
        else
            local amountData = self:GetDataSize()
            local frameWidth = self.plotFrame:GetWidth()
            return frameWidth / amountData
        end
    end,

    ---set the line width to a fixed value
    ---@param self df_chart
    ---@param width number
    SetLineWidth = function(self, width)
        assert(type(width) == "number", "number expected on :SetLineWidth(number)")
        self.fixedLineWidth = width
    end,

    ---@param self df_chart
    ---@param value number
    ---@param plotFrameHeightScaled number
    ---@return number
    CalcYAxisPointForValue = function(self, value, plotFrameHeightScaled)
        return value / self.maxValue * (plotFrameHeightScaled)
    end,

    ---@param self df_chart
    UpdateFrameSizeCache = function(self)
        self.width = self:GetWidth()
        self.height = self:GetHeight()
    end,

    ---@param self df_chart
    OnSizeChanged = function(self)
        self:UpdateFrameSizeCache()
    end,

    ---@param self df_chart
    ---@param yPointScale number|nil
    ---@param bUpdateLabels boolean|nil
    Plot = function(self, yPointScale, bUpdateLabels)
        --debug
        --self:SetData({38, 26, 12, 63, 100, 96, 42, 94, 25, 75, 61, 54, 71, 40, 34, 100, 66, 90, 39, 13, 99, 18, 72, 18, 83, 45, 56, 24, 33, 85, 95, 71, 15, 66, 19, 58, 52, 9, 83, 99, 100, 4, 3, 56, 6, 80, 94, 7, 40, 55, 98, 92, 20, 9, 35, 89, 72, 7, 13, 81, 29, 78, 55, 70, 12, 33, 39, 3, 84, 31, 10, 53, 51, 69, 66, 58, 71, 60, 31, 71, 27, 76, 21, 75, 15, 89, 2, 81, 72, 78, 74, 80, 97, 10, 59, 0, 31, 5, 1, 82, 71, 89, 78, 94, 74, 20, 65, 72, 56, 40, 92, 91, 40, 79, 4, 56, 18, 88, 88, 20, 20, 10, 47, 26, 80, 26, 75, 21, 57, 10, 67, 66, 84, 83, 14, 47, 83, 9, 7, 73, 63, 32, 64, 20, 40, 3, 46, 54, 17, 37, 82, 66, 65, 22, 12, 1, 100, 41, 1, 72, 38, 41, 71, 69, 88, 34, 10, 50, 9, 25, 19, 27, 3, 13, 40, 75, 3, 11, 93, 58, 81, 80, 93, 25, 74, 68, 91, 87, 79, 48, 66, 53, 64, 18, 51, 19, 32, 4, 21, 43})

        self:UpdateFrameSizeCache()

        --max amount of data is the max amount of point the chart will have
        local maxLines = self:GetDataSize()

        --calculate where the first point height will be
        local firstValue = self:GetDataFirstValue()
        assert(firstValue, "Can't Plot(), chart has no data, use Chart:SetData(table)")

        local plotFrameHeightScaled = self.plotFrame:GetHeight() * (yPointScale or 1)
        local currentXPoint = 0
        local currentYPoint = self:CalcYAxisPointForValue(firstValue, plotFrameHeightScaled)

        --calculate the width space which line should have
        local eachLineWidth = self:GetLineWidth()

        self:ResetDataIndex()

        for i = 1, maxLines do
            local line = self:GetLine()

            line:SetColorTexture(unpack(self.color))

            if (line.thickness ~= self.lineThickness) then
                line:SetThickness(self.lineThickness)
                line.thickness = self.lineThickness
            end

            --the start point starts where the latest point finished
            line:SetStartPoint("bottomleft", currentXPoint, currentYPoint)

            --move x
            currentXPoint = currentXPoint + eachLineWidth

            --end point
            local value = self:GetDataNextValue()
            currentYPoint = self:CalcYAxisPointForValue(value, plotFrameHeightScaled)
            line:SetEndPoint("bottomleft", currentXPoint, currentYPoint)
        end

        self:ShowBackdropIndicators()

        if (bUpdateLabels or bUpdateLabels == nil) then
            updateLabelValues(self)
        end
    end,
}

---create a chart frame object
---@param parent frame
---@param name string|nil
---@return df_chart
local createChartFrame = function(parent, name)
    ---@type df_chart
    local chartFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

    detailsFramework:Mixin(chartFrame, detailsFramework.DataMixin)
    detailsFramework:Mixin(chartFrame, detailsFramework.ValueMixin)
    detailsFramework:Mixin(chartFrame, detailsFramework.ChartFrameMixin)
    detailsFramework:Mixin(chartFrame, detailsFramework.ChartFrameSharedMixin)

    chartFrame:DataConstructor()
    chartFrame:ValueConstructor()
    chartFrame:ChartFrameConstructor()

    --when a new data is set, update the min and max values
    local onSetDataCallback = function(data, smoothnessLevel)
        local newData = {}

        smoothnessLevel = smoothnessLevel or 0

        if (smoothnessLevel > 0) then
            smoothnessLevel = smoothnessLevel + 2

            for i = 1, #data do
                local thisValue = 0
                local amountDataAdded = 0

                --calculate the sum within the window
                for o = i - math.floor(smoothnessLevel / 2), i + math.floor(smoothnessLevel / 2) do
                    if o >= 1 and o <= #data then
                        thisValue = thisValue + data[o]
                        amountDataAdded = amountDataAdded + 1
                    end
                end

                --calculate the average and store in the smoothedData value
                local average = thisValue / amountDataAdded
                table.insert(newData, average)
            end
        else
            newData = data
        end

        chartFrame:SetDataRaw(newData)

        local minValue, maxValue = chartFrame:GetDataMinMaxValues()
        chartFrame:SetMinMaxValues(minValue, maxValue)
        --clear the lines
        chartFrame:HideLines()
    end
    chartFrame:AddDataChangeCallback(onSetDataCallback)

    createPlotFrame(chartFrame) --creates chartFrame.plotFrame
    return chartFrame
end

function detailsFramework:CreateGraphicLineFrame(parent, name)
    ---@type df_chart
    local newGraphicFrame = createChartFrame(parent, name)
    return newGraphicFrame
end

detailsFramework.MultiChartFrameMixin = {
    MultiChartFrameConstructor = function(self)
        self.nextChartselframe = 1
        self.biggestDataValue = 0
        self.lineThickness = 2
        self.nextChartFrame = 1
        self.chartFrames = {}
        self.lineNameIndicators = {}

        chartFrameSharedConstructor(self)
    end,

    IsMultiChart = function(self)
        return true
    end,

    ---add a new chart data and create a new chart frame if necessary to the multi chart
    ---@param self df_chartmulti
    ---@param data table
    ---@param smoothnessLevel number|nil
    ---@param name string|nil
    ---@param red any
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    AddData = function(self, data, smoothnessLevel, name, red, green, blue, alpha)
        assert(type(data) == "table", "MultiChartFrame:AddData() usage: AddData(table)")
        local chartFrame = self:GetChart()

        red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)
        chartFrame:SetColor(red, green, blue, alpha)
        chartFrame:SetData(data, smoothnessLevel)

        chartFrame.chartName = name or ""

        self:SetMaxValueIfBigger(chartFrame:GetMaxValue())
        self:SetMinValueIfLower(chartFrame:GetMinValue())

        local dataAmount = chartFrame:GetDataSize()
        self:SetMaxDataSize(dataAmount)
    end,

    ---internally handle next line
    ---@param self df_chartmulti
    ---@return df_chart
    GetChart = function(self)
        local chartFrame = self.chartFrames[self.nextChartFrame]
        if (not chartFrame) then
            chartFrame = createChartFrame(self, "$parentChartFrame" .. self.nextChartFrame)
            chartFrame:SetAllPoints()
            chartFrame:UpdateFrameSizeCache()
            self.chartFrames[self.nextChartFrame] = chartFrame
        end
        self.nextChartFrame = self.nextChartFrame + 1
        chartFrame:Show()
        return chartFrame
    end,

    ---get all charts added to the multi chart frame
    ---@param self df_chartmulti
    ---@return df_chart[]
    GetCharts = function(self)
        return self.chartFrames
    end,

    ---get the amount of charts added to the multi chart frame
    ---@param self df_chartmulti
    ---@return number
    GetAmountCharts = function(self)
        return self.nextChartFrame - 1
    end,

    ---hide all charts
    ---@param self df_chartmulti
    HideCharts = function(self)
        local charts = self:GetCharts()
        for i = 1, #charts do
            local chartFrame = charts[i]
            chartFrame:Hide()
        end
    end,

    ---reset the multi chart frame
    ---@param self df_chartmulti
    Reset = function(self)
        self:HideCharts()
        self:ResetMinMaxValues()
        self:ResetBackdropIndicators()
        self.nextChartFrame = 1
        self.biggestDataValue = 0
        self.xAxisDataNumber = 0
    end,

    ---set the min and max values of all charts
    ---@param self df_chartmulti
    ---@param minValue number
    ---@param maxValue number
    SetChartsMinMaxValues = function(self, minValue, maxValue)
        local allCharts = self:GetCharts()
        for i = 1, self:GetAmountCharts() do
            local chartFrame = allCharts[i]
            chartFrame:SetMinMaxValues(minValue, maxValue)
        end
    end,

    ---set the max data size of all charts
    ---@param self df_chartmulti
    ---@param dataSize number
    SetMaxDataSize = function(self, dataSize)
        self.biggestDataValue = math.max(self.biggestDataValue, dataSize)
    end,

    ---get the max data size of all charts
    ---@param self df_chartmulti
    ---@return number
    GetMaxDataSize = function(self)
        return self.biggestDataValue
    end,

    ---@param self df_chartmulti
    ---@param value number
    SetLineThickness = function(self, value)
        assert(type(value) == "number", "number expected on :SetLineThickness(number)")
        self.lineThickness = value
    end,

    ---@param self df_chartmulti
    UpdateChartNamesIndicator = function(self)
        local allCharts = self:GetCharts()
        local allChartsAmount = self:GetAmountCharts()

        --hide all indicators already created
        for i = 1, #self.lineNameIndicators do
            local thisIndicator = self.lineNameIndicators[i]
            thisIndicator:Hide()
        end

        local nameIndicatorIndex = 1

        for i = allChartsAmount, 1, -1 do
            local chartFrame = allCharts[i]
            local chartName = chartFrame.chartName
            local red, green, blue, alpha = chartFrame:GetColor()

            ---@type chart_nameindicator
            local thisIndicator = self.lineNameIndicators[nameIndicatorIndex]
            if (not thisIndicator) then
                ---@type chart_nameindicator
                thisIndicator = CreateFrame("frame", "$parentLineNameIndicator" .. i, self)
                thisIndicator:SetSize(60, 12)
                thisIndicator:Hide()
                if (nameIndicatorIndex == 1) then
                    thisIndicator:SetPoint("topright", self, "topright", nameIndicatorIndex * -10, -10)
                end

                thisIndicator.Texture = thisIndicator:CreateTexture("$parentTexture", "overlay")
                thisIndicator.Texture:SetSize(12, 12)

                thisIndicator.Label = thisIndicator:CreateFontString("$parentLabel", "overlay", "GameFontNormal")
                detailsFramework:SetFontSize(thisIndicator.Label, 11)
                detailsFramework:SetFontColor(thisIndicator.Label, "white")

                thisIndicator.Texture:SetPoint("left", thisIndicator, "left", 0, 0)
                thisIndicator.Label:SetPoint("left", thisIndicator.Texture, "right", 2, 0)
                self.lineNameIndicators[nameIndicatorIndex] = thisIndicator
            end

            thisIndicator.Texture:SetColorTexture(red, green, blue, alpha)
            thisIndicator.Label:SetText(chartName)
            local textWidth = thisIndicator.Label:GetStringWidth()
            thisIndicator:SetWidth(math.max(textWidth + thisIndicator.Texture:GetWidth() + 4, 85))

            if (nameIndicatorIndex > 1) then
                local previousIndicator = self.lineNameIndicators[nameIndicatorIndex-1]
                thisIndicator:SetPoint("topright", previousIndicator, "topleft", -2, 0)
            end

            nameIndicatorIndex = nameIndicatorIndex + 1

            if (chartName ~= "") then
                thisIndicator:Show()
            end
        end
    end,

    ---draw all the charts added to the multi chart frame
    ---@param multiChartFrame df_chartmulti
    Plot = function(multiChartFrame)
        local minValue, multiChartMaxValue = multiChartFrame:GetMinMaxValues()
        local plotAreaWidth = multiChartFrame.plotFrame:GetWidth() --if there's no axis, the plotFrame has no width
        local maxDataSize = multiChartFrame:GetMaxDataSize() --it's not clearing when a new boss is selected
        local eachLineWidth = plotAreaWidth / maxDataSize
        local allCharts = multiChartFrame:GetCharts()

        for i = 1, multiChartFrame:GetAmountCharts() do
            local chartFrame = allCharts[i]
            chartFrame.chartLeftOffset = multiChartFrame.chartLeftOffset
            chartFrame.chartBottomOffset = multiChartFrame.chartLeftOffset

            chartFrame.plotFrame:ClearAllPoints()
            chartFrame.plotFrame:SetAllPoints(multiChartFrame.plotFrame)

            chartFrame:SetLineThickness(multiChartFrame.lineThickness)
            chartFrame:SetLineWidth(eachLineWidth)

            --get the percentage of how small this data is compared to the biggest data
            --this percentage is then used to scale down the to fit correctly the fontStrings showing the value metrics
            local yPointScale = chartFrame.maxValue / multiChartMaxValue
            local bUpdateLabels = false
            chartFrame:Plot(yPointScale, bUpdateLabels)
        end

        multiChartFrame:ShowBackdropIndicators()
        updateLabelValues(multiChartFrame)
        multiChartFrame:UpdateChartNamesIndicator()
    end,
}

---create a chart frame object with support to multi lines
---@param parent frame
---@param name string|nil
---@return df_chartmulti
function detailsFramework:CreateGraphicMultiLineFrame(parent, name)
    name = name or ("DetailsMultiChartFrameID" .. math.random(1, 10000000))

    ---@type df_chartmulti
    local chartFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

    detailsFramework:Mixin(chartFrame, detailsFramework.ValueMixin)
    detailsFramework:Mixin(chartFrame, detailsFramework.MultiChartFrameMixin)
    detailsFramework:Mixin(chartFrame, detailsFramework.ChartFrameSharedMixin)

    chartFrame:ValueConstructor()
    chartFrame:MultiChartFrameConstructor()

    createPlotFrame(chartFrame) --creates chartFrame.plotFrame
    return chartFrame
end