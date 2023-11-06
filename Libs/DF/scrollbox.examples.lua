
--exemples for world of warcraft library "Details Framework" file: scrollbox.lua
--a scrollbox is a frame with a scrollbar and lines, these lines can be used to show data or show more frames in the case of a grid frame
--a grid of frames if a frame with lines and columns, each line can have multiple columns, a column is a frame

--------Start of the Grid Scroll Box Example--------

--in world of warcraft, UIParent is the default parent, this frame is created by the game and is the base frame for all other frames
local parent = UIParent
local name = "GridScrollBoxExample"

--declare a function which receives a frame and the data which will be used to refresh it
local refreshOptionFunc = function(optionButton, data)
    optionButton.text:SetText(data.text)
    optionButton:SetScript("OnClick", function(self) print("clicked option " .. data.text) end)
    optionButton:Show()
end

--declare a function to create a column within a scroll line
--this function will receive the line, the line index within the scrollbox and the column index within the line
local createOptionFrameFunc = function(line, lineIndex, columnIndex)
    local optionButton = CreateFrame("button", "$parentOptionFrame" .. lineIndex .. columnIndex, line)
    optionButton:SetSize(100, 20)
    optionButton.text = optionButton:CreateFontString(nil, "overlay", "GameFontNormal")
    optionButton.text:SetPoint("center", optionButton, "center", 0, 0)
    optionButton.text:SetText("Option " .. lineIndex .. columnIndex)

    local highlightTexture = optionButton:CreateTexture(nil, "highlight")
    highlightTexture:SetAllPoints()
    highlightTexture:SetColorTexture(1, 1, 1, 0.2)

    DetailsFramework:ApplyStandardBackdrop(optionButton)

    return optionButton
end

--when creatin a grid scrollbox, some of the settings for the grid is clared into a table to be passed as an argument
local options = {
    width = 600,
    height = 400,
    --amount of horizontal lines
    line_amount = 12,
    --amount of columns per line
    columns_per_line = 4,
    --height of each line
    line_height = 30,
    auto_amount = false,
    no_scroll = false,
    no_backdrop = false,
}

--grid scrollbox data, can also be set with gridScrollBox:SetData(data) if the data is only available later on
--the data table is passed within the optionFrame when calling the refresh function
local data = {
    {text = "1"}, {text = "2"}, {text = "3"}, {text = "4"}, {text = "5"}, {text = "6"}, {text = "7"}, {text = "8"}, {text = "9"}, {text = "10"},
    {text = "11"}, {text = "12"}, {text = "13"}, {text = "14"}, {text = "15"}, {text = "16"}, {text = "17"}, {text = "18"}, {text = "19"}, {text = "20"},
    {text = "21"}, {text = "22"}, {text = "23"}, {text = "24"}, {text = "25"}, {text = "26"}, {text = "27"}, {text = "28"}, {text = "29"}, {text = "30"},
    {text = "31"}, {text = "32"}, {text = "33"}, {text = "34"}, {text = "35"}, {text = "36"}, {text = "37"}, {text = "38"}, {text = "39"}, {text = "40"},
    {text = "41"}, {text = "42"}, {text = "43"}, {text = "44"}, {text = "45"}, {text = "46"}, {text = "47"}, {text = "48"}, {text = "49"}, {text = "50"},
    {text = "51"}, {text = "52"}, {text = "53"}, {text = "54"}, {text = "55"}, {text = "56"}, {text = "57"}, {text = "58"}, {text = "59"}, {text = "60"},
    {text = "61"}, {text = "62"}, {text = "63"}, {text = "64"}, {text = "65"}, {text = "66"}, {text = "67"}, {text = "68"}, {text = "69"}, {text = "70"},
    {text = "71"}, {text = "72"}, {text = "73"}, {text = "74"}, {text = "75"}, {text = "76"}, {text = "77"}, {text = "78"}, {text = "79"}, {text = "80"},
    {text = "81"}, {text = "82"}, {text = "83"}, {text = "84"}, {text = "85"}, {text = "86"}, {text = "87"}, {text = "88"}, {text = "89"}, {text = "90"},
    {text = "91"}, {text = "92"}, {text = "93"}, {text = "94"}, {text = "95"}, {text = "96"}, {text = "97"}, {text = "98"}, {text = "99"}, {text = "100"},
}

--create the grid scrollbox
local gridScrollBox = DetailsFramework:CreateGridScrollBox(parent, name, refreshOptionFunc, data, createOptionFrameFunc, options)
gridScrollBox:SetPoint("center", parent, "center", 0, 0)
gridScrollBox:Refresh()

--------End of the Grid Scroll Box Example--------


--------Start of the Canvas Scroll Box Example--------

--display frame is the frame which will be shown within the canvas, this frame can have any size and if it is bigger than the canvas, it will be scrollable
local displayFrame = CreateFrame("frame", "CanvasScrollBoxDisplayFrameExample", nil, "BackdropTemplate")
displayFrame:SetSize(800, 1200)
displayFrame:SetBackdrop({bgFile = "Interface\\FrameGeneral\\UI-Background-Marble", tile = true, tileSize = 32})

--signature: CreateCanvasScrollBox(parentFrame, displayFrame, frameName)
--display frame is the frame which will be shown within the canvas
local canvasScrollFrame = DetailsFramework:CreateCanvasScrollBox(UIParent, displayFrame, "CanvasScrollBoxExample")
canvasScrollFrame:SetPoint("center", UIParent, "center", 0, 0)
canvasScrollFrame:SetSize(300, 500)

--------End of the Canvas Scroll Box Example--------