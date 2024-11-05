
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

---@class df_chartline : line
---@field thickness number

---@class df_chartshared: table
---@field fillOrder table<number, number[]> the order of the lines to be filled, this table is shared by all charts
---@field bFillChart boolean if the chart lines should be filled or not
---@field fillChartLineThickness number the thickness of the fill line
---@field bRunningInBackground boolean true if there is a proccess happening asynchronously
---@field waitForBackgroundProcessTicker timer a ticker to check if all background process finished
---@field amountOfBackgroundProcess number the amount of background processes happening
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
---@field SetFillChart fun(self: df_chartshared, bFill: boolean, lineThickness:number?) set if the chart lines should be filled or not
---@field GetFillState fun(self: df_chartshared) : boolean, number return if the chart lines should be filled or not
---@field ShrinkData fun(self: df_chartmulti|df_chart, data: table, skrinkBy: number, bJustDrop: boolean?) : table
---@field HasBackgroundProcess fun(self: df_chartmulti|df_chart) : boolean return true if there is a proccess happening asynchronously
---@field SetBackgroundProcessState fun(self: df_chartmulti|df_chart, bRunning: boolean) set if there is a proccess happening asynchronously
---@field CreateBackdropIndicator fun(self: df_chartmulti|df_chart, index: number) : chart_backdropindicator create a new backdrop indicator
---@field GetBackdropIndicator fun(self: df_chartmulti|df_chart) : chart_backdropindicator get a backdrop indicator by index
---@field ResetBackdropIndicators fun(self: df_chartmulti|df_chart) reset all backdrop indicators
---@field SetAxesColor fun(self: df_chartmulti, red: number|string|table|nil, green: number|nil, blue: number|nil, alpha: number|nil) : boolean set the color of both axis lines
---@field SetAxesThickness fun(self: df_chartmulti, thickness: number) : boolean set the thickness of both axis lines
---@field CreateAxesLines fun(self: df_chartmulti|df_chart, xOffset: number, yOffset: number, whichSide: "left"|"right", thickness: number, amountYLabels: number, amountXLabels: number, red: any, green: number|nil, blue: number|nil, alpha: number|nil) create the x and y axis lines with their labels, offsets are the distance from left and bottom
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
---@field average number
---@field depth number
---@field color number[] red green blue alpha
---@field height number
---@field nextLine number
---@field minValue number
---@field maxValue number
---@field data number[]
---@field lines df_chartline[]
---@field fixedLineWidth number
---@field chartName string
---@field dataPoint_OnEnterFunc fun(self: df_chart, onEnterFunc: function, ...) set the function to be called when the mouse hover over a data point in the chart
---@field dataPoint_OnEnterPayload any[] set the payload to be passed to the function set by DataPoint_OnEnterFunc
---@field dataPoint_OnLeaveFunc fun(self: df_chart, onLeaveFunc: function, ...) set the function to be called when the mouse leaves a data point in the chart
---@field dataPoint_OnLeavePayload any[] set the payload to be passed to the function set by DataPoint_OnLeaveFunc
---@field GetOnEnterLeaveFunctions fun(self: df_chart) : function, any[], function, any[] return the functions and payloads set by DataPoint_OnEnterFunc and DataPoint_OnLeaveFunc
---@field ChartFrameConstructor fun(self: df_chart) set the default values for the chart frame
---@field GetLine fun(self: df_chart) : df_chartline return a line and also internally handle next line
---@field GetLines fun(self: df_chart) : df_chartline[] return a table with all lines already created
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
---@field Plot fun(self: df_chart, yPointScale: number|nil, bUpdateLabels: boolean|nil, lineId:number?)  draw the graphic using lines and following the data set by SetData() or AddData() in multi chart

---@class df_chartmulti : df_chart, df_chartshared
---@field chartFrames df_chart[]
---@field nextChartselframe number
---@field biggestDataValue number
---@field nextChartFrame number
---@field lineNameIndicators chart_nameindicator[]
---@field MultiChartFrameConstructor fun(self: df_chartmulti)
---@field GetCharts fun(self: df_chartmulti) : df_chart[]
---@field GetChart fun(self: df_chartmulti) : df_chart
---@field AddData fun(self: df_chartmulti, data: table, smoothingMethod: string|nil, smoothnessLevel:number, name: string, red: any, green: number|nil, blue: number|nil, alpha: number|nil)
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
    ---set if the chart lines should be filled or not, when filled, an extra line is drawn at the bottom of the chart to close the fill
    ---@param self df_chartshared
    ---@param bFill boolean
    ---@param lineThickness number?
    SetFillChart = function(self, bFill, lineThickness)
        lineThickness = lineThickness or 1
        self.bFillChart = bFill
        self.fillChartLineThickness = lineThickness
    end,

    ---return if the chart lines should be filled or not
    ---@param self df_chartshared
    ---@return boolean
    ---@return number
    GetFillState = function(self)
        return self.bFillChart, self.fillChartLineThickness
    end,

    ---receives a table containing the data to be plotted in the chart, returns a new table with the data reduced by the skrinkBy value
    ---if bJustDrop is true, the data will be reduced by dropping values, if false, the data will be reduced by averaging the values
    ---@param self df_chart|df_chartmulti
    ---@param data table
    ---@param skrinkBy number
    ---@param bJustDrop boolean
    ---@return table
    ShrinkData = function(self, data, skrinkBy, bJustDrop)
        local newData = {}
        local dataSize = #data

        local tinsert = table.insert

        if (bJustDrop) then
            if (true) then
                --make a for loop to drop the values by random, for example, is shrink is 3 and index is 9, it will drop at random two values of: 9 10 or 11
            else
                --it will shrink the data by dropping values each skrinkBy indexes
                for i = 1, dataSize, skrinkBy do
                    tinsert(newData, data[i])
                end
            end
        else
            --it will shrink the data by making an average of the values and add to newTable, shrinkBy controls how many values will be averaged
            for i = 1, dataSize, skrinkBy do
                local sum = 0
                for o = 0, skrinkBy - 1 do
                    sum = sum + (data[i + o] or 0) --attempt to perform arithmetic on field '?' (a nil value)
                end
                tinsert(newData, sum / skrinkBy)
            end
        end

        return newData
    end,

    ---return if there is a proccess happening asynchronously
    ---@param self df_chartmulti
    ---@return boolean
    HasBackgroundProcess = function(self)
        return self.bRunningInBackground
    end,

    ---set if there is a proccess happening asynchronously
    ---@param self df_chartmulti
    ---@param bRunning boolean
    SetBackgroundProcessState = function(self, bRunning)
        if (bRunning) then
            self.amountOfBackgroundProcess = self.amountOfBackgroundProcess + 1
            self.bRunningInBackground = bRunning
        else
            self.amountOfBackgroundProcess = self.amountOfBackgroundProcess - 1
            if (self.amountOfBackgroundProcess == 0) then
                self.bRunningInBackground = false
            end
        end
    end,

    ---set the color of both axis lines
    ---@param self df_chartmulti
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
    ---@param self df_chartmulti
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
    ---@param self df_chartmulti
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

    ---@param self df_chartmulti
    ---@param ... any
    SetXAxisData = function(self, ...)
        setXAxisData(self, ...)
    end,

    ---@param self df_chartmulti
    ---@param dataType x_axisdatatype
    SetXAxisDataType = function(self, dataType)
        setXAxisDataType(self, dataType)
    end,

    ---create a new backdrop indicator, this is called from the function GetBackdropIndicator
    ---@param self df_chartmulti
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
    ---@param self df_chartmulti
    ResetBackdropIndicators = function(self)
        for i = 1, #self.backdropIndicators do
            local thisBackdropIndicator = self.backdropIndicators[i]
            thisBackdropIndicator:Hide()
            thisBackdropIndicator.bInUse = false
        end
        self.nextBackdropIndicator = 1
    end,

    ---get a backdrop indicator, if it doesn't exist, create a new one
    ---@param self df_chartmulti
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
    ---@param self df_chartmulti
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
    ---@param self df_chartmulti
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

local fillerLines_InAvailable = {}
local fillerLines_InUse = {}

---@class df_chartlazypayload : table
---@field self df_chartmulti
---@field currentDataIndex number
---@field executionsPerFrame number
---@field dataSize number
---@field currentXPoint number
---@field currentYPoint number
---@field eachLineWidth number
---@field plotFrameHeightScaled number
---@field r number
---@field g number
---@field b number
---@field lineId number
---@field bUpdateLabels boolean
---@field bFillChart boolean
---@field fillLineThickness number

--this is the function which is called by the schedules lazy execution system
local lazyChartUpdate = function(payload, iterationCount, maxIterations)
    ---@cast payload df_chartlazypayload

    local self = payload.self
    ---@cast self df_chart

    local currentDataIndex = payload.currentDataIndex
    local dataSize = payload.dataSize
    local currentXPoint = payload.currentXPoint
    local currentYPoint = payload.currentYPoint
    local eachLineWidth = payload.eachLineWidth
    local plotFrameHeightScaled = payload.plotFrameHeightScaled
    local r = payload.r
    local g = payload.g
    local b = payload.b
    local lineId = payload.lineId
    local bUpdateLabels = payload.bUpdateLabels
    local bFillChart = payload.bFillChart
    local fillLineThickness = payload.fillLineThickness

    local executionsPerFrame = payload.executionsPerFrame
    currentDataIndex = currentDataIndex + executionsPerFrame

    for i = 1, payload.executionsPerFrame do
        local value, dataIndex = self:GetDataNextValue()
        if (not value) then
            --the data stream has ended
            return true
        end

        local line = self:GetLine()
        line:SetColorTexture(r, g, b)

        if (line.thickness ~= self.lineThickness) then
            line:SetThickness(self.lineThickness)
            line.thickness = self.lineThickness
        end

        --get the start points
        local startX = currentXPoint
        local startY = currentYPoint
        currentXPoint = currentXPoint + eachLineWidth
        --end point
        local endX = currentXPoint
        currentYPoint = self:CalcYAxisPointForValue(value, plotFrameHeightScaled)
        local endY = currentYPoint

        local length = detailsFramework:GetVectorLength(endX - startX, endY - startY)
        --make sure the magnitude of the difference between previous point to current point is at least 1.5
        if (length < 1.5) then
            local diffX = endX - startX
            local diffY = endY - startY

            local diffLength = detailsFramework:GetVectorLength(diffX, diffY)
            local scaleFactor = 1.5 / diffLength

            diffX = diffX * scaleFactor
            diffY = diffY * scaleFactor

            endX = endX + diffX
            endY = endY + diffY
        end

        --the start point starts where the latest point finished
        line:SetStartPoint("bottomleft", startX, startY)
        line:SetEndPoint("bottomleft", endX, endY)

        if (bFillChart) then
            if (lineId) then
                local fillLine = table.remove(fillerLines_InAvailable)
                if (not fillLine) then
                    fillLine = self.plotFrame:CreateLine(nil, "overlay")
                    fillLine:SetThickness(fillLineThickness)
                    fillerLines_InUse[#fillerLines_InUse+1] = fillLine
                else
                    fillerLines_InUse[#fillerLines_InUse+1] = fillLine
                end

                fillLine:SetStartPoint("bottomleft", endX, endY)
                fillLine:SetEndPoint("bottomleft", endX, 0)
                fillLine:SetDrawLayer("overlay", self.depth)
                fillLine:SetColorTexture(r, g, b, 0.15 + (self.depth/10))

                fillLine:Show()
            end
        end
    end

    payload.currentXPoint = currentXPoint
    payload.currentYPoint = currentYPoint
end

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
        self.amountOfBackgroundProcess = 0

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
    ---@return df_chartline
    GetLine = function(self)
        ---@type df_chartline
        local line = self.lines[self.nextLine]

        if (not line) then
            ---@type line
            local newLine = self.plotFrame:CreateLine(nil, "overlay", nil, 5)
            ---@cast newLine df_chartline
            self.lines[self.nextLine] = newLine
            line = newLine
        end

        self.nextLine = self.nextLine + 1
        line:Show()
        return line
    end,

    ---return all lines created for this chart
    ---@param self df_chart
    ---@return df_chartline[]
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

    ---when the mouse hover over a data point in the chart, this function will be called
    ---@param self df_chart
    SetOnEnterFunction = function(self, onEnterFunc, ...)
        self.dataPoint_OnEnterFunc = onEnterFunc
        self.dataPoint_OnEnterPayload = {...}
    end,

    ---when the mouse leaves a data point in the chart, this function will be called
    ---@param self df_chart
    SetOnLeaveFunction = function(self, onLeaveFunc, ...)
        self.dataPoint_OnLeaveFunc = onLeaveFunc
        self.dataPoint_OnLeavePayload = {...}
    end,

    ---get the data point on enter and on leave function
    ---@param self df_chart
    ---@return function onEnterFunc
    ---@return any[] onEnterPayload
    ---@return function onLeaveFunc
    ---@return any[] onLeavePayload
    GetOnEnterLeaveFunctions = function(self)
        return self.dataPoint_OnEnterFunc, self.dataPoint_OnEnterPayload, self.dataPoint_OnLeaveFunc, self.dataPoint_OnLeavePayload
    end,

    ---this function will draw the chart lines
    ---@param self df_chart
    ---@param yPointScale number|nil
    ---@param bUpdateLabels boolean|nil
    Plot = function(self, yPointScale, bUpdateLabels, lineId)
        lineId = lineId or 1
        self:UpdateFrameSizeCache()

        --max amount of data is the max amount of point the chart will have
        local dataSize = self:GetDataSize()

        --calculate where the first point height will be
        local firstValue = self:GetDataFirstValue()
        assert(firstValue, "Can't Plot(), chart has no data, use Chart:SetData(table)")

        local plotFrameHeightScaled = self.plotFrame:GetHeight() * (yPointScale or 1)
        local currentXPoint = 0
        local currentYPoint = self:CalcYAxisPointForValue(firstValue, plotFrameHeightScaled)

        --calculate the width space which line should have
        local eachLineWidth = self:GetLineWidth()

        self:ResetDataIndex()

        local r, g, b = unpack(self.color)

        local bFillChart, fillLineThickness = self:GetFillState()

        local payload = {
            executionsPerFrame = 50,
            self = self,
            currentDataIndex = 1,
            dataSize = dataSize,
            currentXPoint = currentXPoint,
            currentYPoint = currentYPoint,
            eachLineWidth = eachLineWidth,
            plotFrameHeightScaled = plotFrameHeightScaled,
            r = r,
            g = g,
            b = b,
            lineId = lineId,
            bUpdateLabels = bUpdateLabels,
            bFillChart = bFillChart,
            fillLineThickness = fillLineThickness,
        }

        for i = #fillerLines_InUse, 1, -1 do
            local line = table.remove(fillerLines_InUse, i)
            fillerLines_InAvailable[#fillerLines_InAvailable+1] = line
            line:Hide()
        end

        detailsFramework.Schedules.LazyExecute(lazyChartUpdate, payload)

        self:ShowBackdropIndicators()

        if (bUpdateLabels or bUpdateLabels == nil) then
            updateLabelValues(self)
        end
    end,
}

--https://en.wikipedia.org/wiki/Local_regression
local calcLOESS = function(data, span, mainFrame, chartFrame)
    local lazyLOESSUpdate = function(payload, iterationCount, maxIterations)
        local data = payload.data
        local span = payload.span
        local lastDataIndex = payload.lastDataIndex
        local result = payload.result
        local halfSpan = payload.halfSpan
        local sumTotal = payload.sumTotal

        local currentDataIndex = payload.currentDataIndex
        payload.currentDataIndex = currentDataIndex + payload.executionsPerFrame

        local max = math.max
        local min = math.min
        local abs = math.abs
        local tinsert = table.insert

        for i = currentDataIndex, currentDataIndex + payload.executionsPerFrame do
            --define the local neighborhood
            local neighborhood = {}
            for o = max(1, i - halfSpan), min(lastDataIndex, i + halfSpan) do
                tinsert(neighborhood, {x = o, y = data[o]})
            end

            sumTotal = sumTotal + data[i]

            --calculate weights based on distance from target point
            local weights = {}
            for _, point in ipairs(neighborhood) do
                local distance = abs(i - point.x)
                local weight = (1 - (distance / (halfSpan + 1)) ^ 3) ^ 3
                weights[point.x] = weight
            end

            --fit a weighted linear regression to the neighborhood
            local sum_w = 0
            local sum_wx = 0
            local sum_wy = 0
            local sum_wxx = 0
            local sum_wxy = 0

            for _, point in ipairs(neighborhood) do
                local w = weights[point.x]
                sum_w = sum_w + w
                sum_wx = sum_wx + w * point.x
                sum_wy = sum_wy + w * point.y
                sum_wxx = sum_wxx + w * point.x * point.x
                sum_wxy = sum_wxy + w * point.x * point.y
            end

            local denominator = sum_w * sum_wxx - sum_wx * sum_wx
            local intercept = (sum_wy * sum_wxx - sum_wx * sum_wxy) / denominator
            local slope = (sum_w * sum_wxy - sum_wx * sum_wy) / denominator

            --predict the smoothed value at the target point
            result[i] = max(0, intercept + slope * i)

            --check if can finishe the execution
            if (i == lastDataIndex) then
                return true
            end
        end

        payload.sumTotal = sumTotal
    end

    local result = {}
    local dataSize = #data
    local halfSpan = math.floor(span / 2)

    local payload = {
        currentDataIndex = 1,
        sumTotal = 0,
        lastDataIndex = dataSize,
        executionsPerFrame = 100,
        data = data,
        span = span,
        result = result,
        halfSpan = halfSpan,
    }

    ---@type df_schedule
    local schedules = detailsFramework.Schedules

    local onEndLazyExecution = function(payload)
        chartFrame:SetDataRaw(payload.result)

        chartFrame.average = payload.sumTotal / dataSize

        local minValue, maxValue = chartFrame:GetDataMinMaxValues()
        chartFrame:SetMinMaxValues(minValue, maxValue)
        --clear the lines
        chartFrame:HideLines()
        mainFrame:SetBackgroundProcessState(false)
    end

    mainFrame:SetBackgroundProcessState(true)
    schedules.LazyExecute(lazyLOESSUpdate, payload, 999, onEndLazyExecution)
end

--simple moving average
---@param data table
---@param averageSize number
---@param mainFrame df_chartmulti
---@param chartFrame df_chart
---@param bAddZeroPadding boolean?
local calcSMA = function(data, averageSize, mainFrame, chartFrame, bAddZeroPadding)
    if (bAddZeroPadding) then
        --fill the start of the data with zeros
        for i = 1, averageSize - 1 do
            --insert at index 1 a zero
            table.insert(data, 1, 0)
        end
    end

    local lazySMAUpdate = function(payload, iterationCount, maxIterations)
        local averageSize = payload.averageSize
        local result = payload.result
        local data = payload.data
        local lastDataIndex = payload.lastDataIndex
        local sum = payload.sum
        local sumTotal = payload.sumTotal
        local bAddZeroPadding = payload.bAddZeroPadding

        local currentDataIndex = payload.currentDataIndex
        payload.currentDataIndex = currentDataIndex + payload.executionsPerFrame

        local tinsert = table.insert

        for i = currentDataIndex, currentDataIndex + payload.executionsPerFrame do
            sum = sum + data[i]
            sumTotal = sumTotal + data[i]
            if (i >= averageSize) then
                if (i > averageSize) then
                    sum = sum - data[i - averageSize]
                end
                tinsert(result, max(0, sum / averageSize))
            end

            --check if can finishe the execution
            if (i == lastDataIndex) then
                if (bAddZeroPadding) then
                    --remove from the data the zeros added at the start
                    for o = 1, averageSize - 1 do
                        --remove from the data the zero added at the first index
                        table.remove(data, 1)
                    end
                end
                return true
            end
        end

        payload.sumTotal = sumTotal
        payload.sum = sum
    end

    --return result
    local result = {}
    local dataSize = #data

    local payload = {
        sum = 0,
        sumTotal = 0,
        currentDataIndex = 1,
        lastDataIndex = dataSize,
        executionsPerFrame = 300,
        data = data,
        result = result,
        averageSize = averageSize,
        bAddZeroPadding = bAddZeroPadding,
    }

    ---@type df_schedule
    local schedules = detailsFramework.Schedules

    local onEndLazyExecution = function(payload)
        chartFrame:SetDataRaw(payload.result)

        chartFrame.average = payload.sumTotal / dataSize

        local minValue, maxValue = chartFrame:GetDataMinMaxValues()
        chartFrame:SetMinMaxValues(minValue, maxValue)
        --clear the lines
        chartFrame:HideLines()
        mainFrame:SetBackgroundProcessState(false)
    end

    mainFrame:SetBackgroundProcessState(true)
    schedules.LazyExecute(lazySMAUpdate, payload, 999, onEndLazyExecution)
end

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

    --when a new data is set, starting an background process to smooth the data
    local onSetDataCallback = function(data, payload)
        local smoothnessMethod = payload.smoothnessMethod or ""
        local smoothnessLevel = payload.smoothnessLevel
        local mainFrame = payload.mainFrame

        smoothnessLevel = smoothnessLevel or 0
        smoothnessMethod = string.lower(smoothnessMethod)

        if (smoothnessMethod == "loess") then
            calcLOESS(data, smoothnessLevel, mainFrame, chartFrame)

        elseif (smoothnessMethod == "sma") then
            calcSMA(data, smoothnessLevel, mainFrame, chartFrame)

        elseif (smoothnessMethod == "smaz") then
            local bAddZeroPadding = true
            calcSMA(data, smoothnessLevel, mainFrame, chartFrame, bAddZeroPadding)
        else
            chartFrame:SetDataRaw(data)
            local minValue, maxValue = chartFrame:GetDataMinMaxValues()
            chartFrame:SetMinMaxValues(minValue, maxValue)
            --clear the lines
            chartFrame:HideLines()
        end
    end
    chartFrame:AddDataChangeCallback(onSetDataCallback)

    createPlotFrame(chartFrame) --creates chartFrame.plotFrame
    return chartFrame
end


detailsFramework.MultiChartFrameMixin = {
    MultiChartFrameConstructor = function(self)
        self.nextChartselframe = 1
        self.biggestDataValue = 0
        self.lineThickness = 2
        self.nextChartFrame = 1
        self.chartFrames = {}
        self.lineNameIndicators = {}
        self.amountOfBackgroundProcess = 0

        chartFrameSharedConstructor(self)
    end,

    IsMultiChart = function(self)
        return true
    end,

    ---add a new chart data and create a new chart frame if necessary to the multi chart
    ---@param self df_chartmulti
    ---@param data table
    ---@param smoothingMethod string|nil
    ---@param smoothnessLevel number|nil
    ---@param name string|nil
    ---@param red any
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    AddData = function(self, data, smoothingMethod, smoothnessLevel, name, red, green, blue, alpha)
        assert(type(data) == "table", "MultiChartFrame:AddData() usage: AddData(table)")
        local chartFrame = self:GetChart()

        red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)
        chartFrame:SetColor(red, green, blue, alpha)
        chartFrame.chartName = name or ""

        local payload = {
            smoothnessMethod = smoothingMethod or "sma",
            smoothnessLevel = smoothnessLevel or 3,
            mainFrame = self,
        }

        --setting the data will start a background process to smooth the data
        chartFrame:SetData(data, payload)
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

    ---@param self df_chartmulti
    WaitForBackgroundProcess = function(self)
        --start a ticker to check if the background process is done
        if (not self.waitForBackgroundProcessTicker) then
            self.waitForBackgroundProcessTicker = C_Timer.NewTicker(0.1, function()
                if (not self:HasBackgroundProcess()) then
                    self.waitForBackgroundProcessTicker:Cancel()
                    self.waitForBackgroundProcessTicker = nil
                    self:Plot()
                end
            end)
        end
    end,

    ---draw all the charts added to the multi chart frame
    ---@param multiChartFrame df_chartmulti
    Plot = function(multiChartFrame)
        --check if there is a background process ongoing
        if (multiChartFrame:HasBackgroundProcess()) then
            multiChartFrame:WaitForBackgroundProcess()
            return
        end

        local allCharts = multiChartFrame:GetCharts()
        local bFillChart, fillLineThickness = multiChartFrame:GetFillState()
        ---@type table<number, {average: number, chartIndex: number}>
        local biggestAverage = {}

        --set the min/max values of the multi chart frame
        for i = 1, multiChartFrame:GetAmountCharts() do
            local chartFrame = allCharts[i]
            multiChartFrame:SetMaxValueIfBigger(chartFrame:GetMaxValue())
            multiChartFrame:SetMinValueIfLower(chartFrame:GetMinValue())

            local dataAmount = chartFrame:GetDataSize()
            multiChartFrame:SetMaxDataSize(dataAmount)

            if (bFillChart) then
                chartFrame:SetFillChart(true, fillLineThickness)
            end

            --get the average of this chart
            biggestAverage[i] = {average = chartFrame.average, chartIndex = i}
        end

        -- sort the averages by the biggest average placing the biggest average in the first position
        table.sort(biggestAverage, function(a, b) if not (a.average and b.average) then return a.average ~= nil end return a.average > b.average end)

        local minValue, multiChartMaxValue = multiChartFrame:GetMinMaxValues()
        local plotAreaWidth = multiChartFrame.plotFrame:GetWidth() --if there's no axis, the plotFrame has no width
        local maxDataSize = multiChartFrame:GetMaxDataSize() --it's not clearing when a new boss is selected
        local eachLineWidth = plotAreaWidth / maxDataSize

        for i = 1, multiChartFrame:GetAmountCharts() do
            local chartFrame = allCharts[i]
            chartFrame.chartLeftOffset = multiChartFrame.chartLeftOffset
            chartFrame.chartBottomOffset = multiChartFrame.chartLeftOffset

            chartFrame.plotFrame:ClearAllPoints()
            chartFrame.plotFrame:SetAllPoints(multiChartFrame.plotFrame)

            chartFrame:SetLineThickness(multiChartFrame.lineThickness)
            chartFrame:SetLineWidth(eachLineWidth)

            for o = 1, #biggestAverage do
                local thisAverageTable = biggestAverage[o]
                if (thisAverageTable.chartIndex == i) then
                    chartFrame.depth = o
                    break
                end
            end

            --get the percentage of how small this data is compared to the biggest data
            --this percentage is then used to scale down the to fit correctly the fontStrings showing the value metrics
            local yPointScale = chartFrame.maxValue / multiChartMaxValue
            local bUpdateLabels = false
            chartFrame:Plot(yPointScale, bUpdateLabels, i)
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
