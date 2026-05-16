
--documentation: see the header of the file charts.lua


--1º example: making a simple chart with two lines, just copy and paste this code into a lua file and run it
do
    local ChartFrameTest = ChartFrameExample1 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample1")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0) --set the position of the chart
    ChartFrameTest:SetSize(800, 600) --set the size of the chart
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest) --apply a backdrop to this example hence see the frame size

    --add a line:
    local data = {1, 2, 30, 25, 6, 5, 4, 8, 7, 4, 1, 12, 15, 24, 18, 17, 14, 15, 8, 4, 14, 42, 22, 25, 30, 35, 39, 8, 7, 4, 1, 2, 5, 4, 8, 7, 4, 12, 12, 4}
    local smoothingMethod = "sma" --(optional, default: "sma")
    local smoothnessLevel = 3 --(optional, default: 1)
    local name = "Line 1" --(optional, default: none)
    local red, green, blue, alpha = 1, 1, 1, 1 --(optional, default: 1, 1, 1, 1)

    ChartFrameTest:AddData(data, smoothingMethod, smoothnessLevel, name, red, green, blue, alpha)

    --add another line:
    data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    smoothingMethod = "loess" --using a different smoothing method
    smoothnessLevel = 50
    name = "Line 2"
    local color = "red" --using a string with the color name
    ChartFrameTest:AddData(data, smoothingMethod, smoothnessLevel, name, color)

    --draw the chart
    ChartFrameTest:Plot()
end

--2º example: thickness and scale of the line:
do
    local ChartFrameTest = ChartFrameExample2 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample2")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0) --set the position of the chart
    ChartFrameTest:SetSize(800, 600) --set the size of the chart
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest) --apply a backdrop to this example hence see the frame size

    --add the data (required)
    local data = {1, 2, 30, 25, 6, 5, 4, 8, 7, 4, 1, 12, 15, 24 ,18, 17 ,14, 15, 8 , 4, 14, 42, 22, 25, 30, 35, 39, 8, 7, 4, 1, 2, 5, 4 ,8, 7 ,4, 12, 12 , 4}
    ChartFrameTest:AddData(data)

    --set the line thickness (optional, default: 2)
    local lineThickness = 3
    ChartFrameTest:SetLineThickness(lineThickness)

    --height modifier, if for some reason need to scale the chart height
    local heightScale = 1.2 --(optional, default: 1)
    --draw the chart
    ChartFrameTest:Plot(heightScale)
end

--3º example: setting the axes lines and labels
do
    local ChartFrameTest = ChartFrameExample3 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample3")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0)
    ChartFrameTest:SetSize(800, 600)
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest)

    --create guide lines in the left and bottom of the chart
    local xOffset = 48 --pixels from the left border of the chart
    local yOffset = 28 --pixels from the bottom border of the chart
    local whichSide = "left" --which side of vertical line should be placed
    local thickness = 1
    local amountYLabels = 10 --amounf of texts indicating the scale of the chart
    local amountXLabels = 10
    local r, g, b, a = 1, 1, 1, 1
    ChartFrameTest:CreateAxesLines(xOffset, yOffset, whichSide, thickness, amountYLabels, amountXLabels, r, g, b, a)

    --the labels in the bottom line can be 'time', 'number' or 'value'
    ChartFrameTest:SetXAxisDataType("time")
    --set the data to be used in the bottom line labels, how the data is formatted depends on the type set above
    ChartFrameTest:SetXAxisData(10) --with type 'time' the chart interprets this as seconds and shows 1:00 to 10:00

    ChartFrameTest:SetXAxisDataType("number")
    ChartFrameTest:SetXAxisData(600) --the chart interprets this as a 'number' type and displays it as 60, 120, 180.

    ChartFrameTest:SetXAxisDataType("value")
    ChartFrameTest:SetXAxisData("hello", "world", 1, 2, 3, 4, "chart", 0, 1, 0) --and 'value' show the values passed

    --setting the data, doesn't matter if it is set at the top or right before Plot()
    local data = {1, 2, 30, 25, 6, 5, 4, 8, 7, 4, 1, 12, 15, 24 ,18, 17 ,14, 15, 8 , 4, 14, 42, 22, 25, 30, 35, 39, 8, 7, 4, 1, 2, 5, 4 ,8, 7 ,4, 12, 12 , 4}
    ChartFrameTest:AddData(data)
    ChartFrameTest:Plot()
end

--4º example: a multi line chart is a chart which supports multiple lines, each line can have a different color, name, smoothnessLevel and thickness
do
    local ChartFrameTest = ChartFrameExample4 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample4")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0)
    ChartFrameTest:SetSize(800, 600)
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest)

    --when using multi-line, the Reset() function instructs the chart to discard the previous data as new data is about to be added
    ChartFrameTest:Reset()

    --smoothnessLevel, name, red, green, blue, alpha
    local smoothnessLevel = 2 --(optional, default: 0)
    local line1Name, line2Name, line3Name = "Line 1", "Line 2", "Line 3" --show the line name at the top right corner (optional, default none)
    local line1Color, line2Color, line3Color = "lime", "purple", "orange" --(optional, default "white")

    --add data into the chart (it plots a line for each data added when :Plot() is called)
    local data1 = {1, 2, 30, 25, 6, 5, 4, 8, 7, 4, 1, 12, 15, 24 ,18, 17 ,14, 15, 8 , 4, 14, 42, 22, 25, 30, 35, 39, 8, 7, 4, 1, 2, 5, 4}
    ChartFrameTest:AddData(data1, smoothnessLevel, line1Name, line1Color)

    local data2 = {3, 5, 20, 25, 6, 5, 15, 18, 12, 14, 11, 8, 7, 8 ,7, 4 ,1, 25, 26 , 30, 28, 20, 22, 25, 20, 15, 10, 8, 7, 4, 1, 2, 5, 4}
    ChartFrameTest:AddData(data2, smoothnessLevel, line2Name, line2Color)

    local data3 = {5, 7, 15, 30, 6, 2, 10, 13, 10, 5, 11, 8, 7, 5, 3, 1, 1, 8, 10 , 12, 15, 20, 25, 25, 20, 17, 12, 7, 7, 6, 4, 5, 6, 5}
    ChartFrameTest:AddData(data3, smoothnessLevel, line3Name, line3Color)

    ChartFrameTest:Plot()
end

--5º example: a 5-line chart using World of Warcraft class colors and names,
--with the Y axis fixed from 0 to 100 and the X axis from 00:00 to 05:00 minutes
do
    local ChartFrameTest = ChartFrameExample5 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample5")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0)
    ChartFrameTest:SetSize(1200, 500)
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest)

    --discard any previous data before adding the new lines
    ChartFrameTest:Reset()

    --create the axes lines and labels (10 labels on each axis)
    --CreateAxesLines only takes effect once per chart, so re-running this block is safe
    ChartFrameTest:CreateAxesLines(48, 28, "left", 1, 10, 10, 1, 1, 1, 1)

    --X axis: 'time' type with 300 seconds -> labels run 0:30, 1:00 ... 5:00
    ChartFrameTest:SetXAxisDataType("time")
    ChartFrameTest:SetXAxisData(300)

    --Y axis: lock the vertical scale to 0 - 100
    --all the data below stays within 0-100, so Plot() keeps this range
    ChartFrameTest:SetMinMaxValues(0, 100)

    --one data table per line, each entry is a data point (all kept within 0-100)
    --the chart connects data points with straight segments: many points that change
    --gradually give smooth, rounded lines -- few points with big jumps give scribbles
    local mage        = {40, 46, 53, 61, 69, 76, 82, 87, 90, 91, 90, 87, 82, 76, 69, 61, 53, 46, 40, 35, 32, 30, 30, 32, 36, 42, 49, 57, 64, 71, 77, 82, 85, 86, 85, 82, 77, 71, 64, 57, 50, 45, 42, 41, 42, 45, 50, 56}
    local druid       = {15, 17, 20, 24, 29, 35, 41, 47, 53, 58, 63, 67, 70, 72, 73, 74, 75, 77, 79, 82, 85, 87, 88, 88, 87, 86, 86, 87, 89, 91, 92, 93, 93, 92, 91, 90, 90, 91, 92, 93, 94, 94, 93, 92, 91, 90, 90, 91}
    local deathKnight = {55, 60, 66, 72, 78, 83, 87, 90, 92, 93, 93, 92, 90, 88, 86, 85, 84, 84, 85, 86, 87, 87, 86, 84, 81, 77, 73, 68, 63, 58, 53, 49, 46, 44, 43, 43, 44, 46, 48, 50, 52, 53, 53, 52, 50, 48, 46, 45}
    local shaman      = {85, 84, 82, 79, 75, 70, 64, 58, 52, 46, 40, 35, 31, 28, 26, 25, 25, 27, 30, 34, 39, 44, 50, 55, 60, 64, 67, 69, 70, 70, 69, 67, 65, 63, 62, 62, 63, 65, 67, 69, 71, 72, 72, 71, 70, 69, 69, 70}
    local monk        = {35, 38, 42, 46, 49, 51, 52, 51, 49, 46, 43, 40, 38, 37, 38, 40, 43, 47, 51, 54, 56, 57, 56, 54, 51, 48, 45, 43, 42, 43, 45, 48, 51, 54, 56, 57, 57, 56, 54, 52, 50, 49, 49, 50, 52, 54, 56, 57}

    --add one line per class -- AddData(data, smoothingMethod, smoothnessLevel, name, red, green, blue, alpha)
    --the 'name' becomes the legend label; red/green/blue is the class color
    ChartFrameTest:AddData(mage,        "sma", 3, "Mage",         0.25, 0.78, 0.92, 1)
    ChartFrameTest:AddData(druid,       "sma", 3, "Druid",        1.00, 0.49, 0.04, 1)
    ChartFrameTest:AddData(deathKnight, "sma", 3, "Death Knight", 0.77, 0.12, 0.23, 1)
    ChartFrameTest:AddData(shaman,      "sma", 3, "Shaman",       0.00, 0.44, 0.87, 1)
    ChartFrameTest:AddData(monk,        "sma", 3, "Monk",         0.00, 1.00, 0.60, 1)

    --draw the chart
    ChartFrameTest:Plot()
end