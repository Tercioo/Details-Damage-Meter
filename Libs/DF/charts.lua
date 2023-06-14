
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local CreateFrame = CreateFrame
local unpack = unpack
local _

---@class df_chartshared: table
---@field yAxisLine line the vertical line which can be anchored in the left or right side of the frame, if the chart is a multi chart, this line is shared by all charts
---@field xAxisLine line
---@field lineThickness number
---@field yAxisLabels fontstring[]
---@field xAxisLabels fontstring[]
---@field SetAxisColor fun(self: df_chartmulti, red: number|string|table|nil, green: number|nil, blue: number|nil, alpha: number|nil) : boolean set the color of both axis lines
---@field SetAxisThickness fun(self: df_chartmulti, thickness: number) : boolean set the thickness of both axis lines

---@class df_chart: frame, df_data, df_value, df_chartshared
---@field _dataInfo df_data
---@field color number[] red green blue alpha
---@field nextLine number
---@field minValue number
---@field maxValue number
---@field data number[]
---@field lines line[]
---@field ChartFrameConstructor fun(self: df_chart) set the default values for the chart frame
---@field GetLine fun(self: df_chart) : line return a line and also internally handle next line
---@field GetLines fun(self: df_chart) : line[] return a table with all lines already created
---@field GetLineWidth fun(self: df_chart) : number calculate the width of each drawn line
---@field SetLineWidth fun(self: df_chart, width: number) set the line width to a fixed value
---@field Plot fun(self: df_chart) draw the graphic using lines and following the data set by SetData()
---@field GetAmountLines fun(self: df_chart) : number return the amount of lines in use
---@field OnSizeChanged fun(self: df_chart)
---@field HideLines fun(self: df_chart) hide all lines already created
---@field Reset fun(self: df_chart) hide all lines and reset the next line to 1
---@field SetColor fun(self: df_chart, r: number|string|table|nil, g: number|nil, b: number|nil, a: number|nil) set the color for the lines
---@field SetLineThickness fun(self: df_chart, thickness: number) set the line thickness
---@field CalcYAxisPointForValue fun(self: df_chart, value: number)
---@field UpdateFrameSizeCache fun(self: df_chart)

---@class df_chartmulti : df_chart, df_chartshared
---@field chartFrames df_chart[]
---@field nextChartselframe number
---@field biggestDataValue number
---@field MultiChartFrameConstructor fun(self: df_chartmulti)
---@field GetCharts fun(self: df_chartmulti) : df_chart[]
---@field GetChart fun(self: df_chartmulti) : df_chart
---@field AddData fun(self: df_chartmulti, data: table, red: number|string|table|nil, green: number|nil, blue: number|nil, alpha: number|nil)
---@field GetAmountCharts fun(self: df_chartmulti): number
---@field HideCharts fun(self: df_chartmulti)
---@field Reset fun(self: df_chartmulti)
---@field SetChartsMinMaxValues fun(self: df_chartmulti, minValue: number, maxValue: number)
---@field SetMaxDataSize fun(self: df_chartmulti, dataSize: number)
---@field GetMaxDataSize fun(self: df_chartmulti)
---@field SetLineThickness fun(self: df_chart, thickness: number) set the line thickness for all chart frames
---@field Plot fun(self: df_chartmulti)

detailsFramework.ChartFrameSharedMixin = {
    ---set the color of both axis lines
    ---@param self df_chart|df_chartmulti
    ---@param red any
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    ---@return boolean bColorChanged return true if the color was set, false if the axis lines are not created yet
    SetAxisColor = function(self, red, green, blue, alpha)
        if (not self.yAxisLine) then
            return false
        end
        red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)
        self.yAxisLine:SetColorTexture(red, green, blue, alpha)
        self.xAxisLine:SetColorTexture(red, green, blue, alpha)
        return true
    end,

    ---set the thickness of both axis lines
    ---@param self df_chart|df_chartmulti
    ---@param thickness number
    ---@return boolean bThicknessChanged return true if the thickness was set, false if the axis lines are not created yet
    SetAxisThickness = function(self, thickness)
        if (not self.yAxisLine) then
            return false
        end
        self.yAxisLine:SetThickness(thickness)
        self.xAxisLine:SetThickness(thickness)
        return true
    end,
}

--> functions shared by both single and multi chart frames

---create the x and y axis lines with their labels
---@param self df_chart|df_chartmulti
---@param whichSide "left"|"right"
---@param thickness number
---@param amountYLabels number
---@param amountXLabels number
---@param red any
---@param green number|nil
---@param blue number|nil
---@param alpha number|nil
---@return boolean
local createAxysLines = function(self, whichSide, thickness, amountYLabels, amountXLabels, red, green, blue, alpha)
    if (self.axisCreated) then
        return false
    end

    self.yAxisLabels = {}
    self.xAxisLabels = {}

    --this is the vertical line which can be anchored in the left or right side of the frame, it separates the chart lines from the measurements texts
    ---@type line
    local yAxisLine = self:CreateLine("$parentYAxisLine", "overlay")
    self.yAxisLine = yAxisLine

    --and the horizontal line which is always anchored in the bottom of the frame
    ---@type line
    local xAxisLine = self:CreateLine("$parentXAxisLine", "overlay")
    self.xAxisLine = xAxisLine

    red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)

    self:SetAxisColor(red, green, blue, alpha)
    self:SetAxisThickness(thickness)

    --create the labels in the vertical axis line
    for i = 1, amountYLabels do
        local label = self:CreateFontString("$parentYAxisLabel" .. i, "overlay", "GameFontNormal")
        label:SetJustifyH("right")
        label:SetTextColor(red, green, blue, alpha)
        table.insert(self.yAxisLabels, label)
    end

    --create the labels in the horizontal axis line
    for i = 1, amountXLabels do
        local label = self:CreateFontString("$parentXAxisLabel" .. i, "overlay", "GameFontNormal")
        label:SetJustifyH("left")
        label:SetTextColor(red, green, blue, alpha)
        table.insert(self.xAxisLabels, label)
    end

    yAxisLine:SetStartPoint("topleft", self, "topleft", 0, 0)
    yAxisLine:SetEndPoint("bottomleft", self, "bottomleft", 0, 0)
    yAxisLine:Hide()

    xAxisLine:SetStartPoint("bottomleft", self, "bottomleft", 0, 0)
    xAxisLine:SetEndPoint("bottomright", self, "bottomright", 0, 0)
    xAxisLine:Hide()

    self.axisCreated = true

    return true
end

detailsFramework.ChartFrameMixin = {
    ---set the default values for the chart frame
    ---@param self df_chart
    ChartFrameConstructor = function(self)
        self.nextLine = 1
        self.minValue = 0
        self.maxValue = 1
        self.lineThickness = 1
        self.data = {}
        self.lines = {}
        self.color = {1, 1, 1, 1}

        --OnSizeChanged
        self:SetScript("OnSizeChanged", self.OnSizeChanged)
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
            line = self:CreateLine(nil, "overlay")
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
        self.nextLine = 1
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
            local frameWidth = self:GetWidth()
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
    CalcYAxisPointForValue = function(self, value)
        return value / self.maxValue * self.height
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
    Plot = function(self)
        --debug
        --self:SetData({38, 26, 12, 63, 100, 96, 42, 94, 25, 75, 61, 54, 71, 40, 34, 100, 66, 90, 39, 13, 99, 18, 72, 18, 83, 45, 56, 24, 33, 85, 95, 71, 15, 66, 19, 58, 52, 9, 83, 99, 100, 4, 3, 56, 6, 80, 94, 7, 40, 55, 98, 92, 20, 9, 35, 89, 72, 7, 13, 81, 29, 78, 55, 70, 12, 33, 39, 3, 84, 31, 10, 53, 51, 69, 66, 58, 71, 60, 31, 71, 27, 76, 21, 75, 15, 89, 2, 81, 72, 78, 74, 80, 97, 10, 59, 0, 31, 5, 1, 82, 71, 89, 78, 94, 74, 20, 65, 72, 56, 40, 92, 91, 40, 79, 4, 56, 18, 88, 88, 20, 20, 10, 47, 26, 80, 26, 75, 21, 57, 10, 67, 66, 84, 83, 14, 47, 83, 9, 7, 73, 63, 32, 64, 20, 40, 3, 46, 54, 17, 37, 82, 66, 65, 22, 12, 1, 100, 41, 1, 72, 38, 41, 71, 69, 88, 34, 10, 50, 9, 25, 19, 27, 3, 13, 40, 75, 3, 11, 93, 58, 81, 80, 93, 25, 74, 68, 91, 87, 79, 48, 66, 53, 64, 18, 51, 19, 32, 4, 21, 43})
        local currentXPoint = 0
        local currentYPoint = 0

        self:UpdateFrameSizeCache()

        --max amount of data is the max amount of point the chart will have
        local maxLines = self:GetDataSize()

        --calculate where the first point height will be
        local firstValue = self:GetDataFirstValue()
        assert(firstValue, "Can't Plot(), chart has no data, use Chart:SetData(table)")

        currentYPoint = self:CalcYAxisPointForValue(firstValue)

        --calculate the width space which line should have
        local eachLineWidth = self:GetLineWidth()

        self:ResetDataIndex()

        for i = 1, maxLines do
            local line = self:GetLine()
            line:SetColorTexture(unpack(self.color))
            line:SetThickness(self.lineThickness)

            --the start point starts where the latest point finished
            line:SetStartPoint("bottomleft", currentXPoint, currentYPoint)

            --move x
            currentXPoint = currentXPoint + eachLineWidth

            --end point
            local value = self:GetDataNextValue()
            currentYPoint = self:CalcYAxisPointForValue(value)
            line:SetEndPoint("bottomleft", currentXPoint, currentYPoint)
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
    local onSetDataCallback = function()
        local minValue, maxValue = chartFrame:GetDataMinMaxValues()
        chartFrame:SetMinMaxValues(minValue, maxValue)
        --clear the lines
        chartFrame:HideLines()
    end
    chartFrame:AddDataChangeCallback(onSetDataCallback)

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
        self.lineThickness = 1
        self.chartFrames = {}
    end,

    CreateAxisLines = function(self, whichSide, thickness, amountYLabels, amountXLabels, red, green, blue, alpha)
        createAxysLines(self, whichSide, thickness, amountYLabels, amountXLabels, red, green, blue, alpha)
    end,

    ---add a new chart data and create a new chart frame if necessary to the multi chart
    ---@param self df_chartmulti
    ---@param data table
    ---@param red number|string|table|nil
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    AddData = function(self, data, red, green, blue, alpha)
        assert(type(data) == "table", "MultiChartFrame:AddData() usage: AddData(table)")
        local chartFrame = self:GetChart()
        chartFrame:SetColor(red, green, blue, alpha)
        chartFrame:SetData(data)

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
        self.nextChartFrame = 1
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

    ---draw all the charts added to the multi chart frame
    ---@param self df_chartmulti
    Plot = function(self)
        local minValue, maxValue = self:GetMinMaxValues()
        self:SetChartsMinMaxValues(minValue, maxValue)

        local plotAreaWidth = self:GetWidth()
        local maxDataSize = self:GetMaxDataSize()
        local eachLineWidth = plotAreaWidth / maxDataSize

        local allCharts = self:GetCharts()
        for i = 1, self:GetAmountCharts() do
            local chartFrame = allCharts[i]
            chartFrame:SetLineThickness(self.lineThickness)
            chartFrame:SetLineWidth(eachLineWidth)
            chartFrame:Plot()
        end
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

    return chartFrame
end