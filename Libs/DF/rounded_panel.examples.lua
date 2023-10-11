
--Details Framework Examples for the frame.lua file
--create a frame with rounded corners

local detailsFramework = DetailsFramework
local parent = UIParent

--example of how to create a frame with rounded corners
--frame name for the example
local name = "RoundedCornerFrameExample"

--default options
local optionsTable = {
    use_titlebar = true, --default false | if true creates a title bar for the frame
    use_scalebar = true, --default false | if true creates a scale bar for the frame
    title = "Test", --default "" | title shown in the title bar
    scale = 1,
    width = 800, --default 200
    height = 600, --default 200
    roundness = 8, --default 0 | how rounded are the corner, 0 means very rounded, 15 means no rounded
    color = {.1, .1, .1, 1},
    border_color = {.2, .2, .2, .5},
    corner_texture = [[Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall]],
}

--create the frame and set it's position
---@type df_roundedpanel
local frame = _G[name] or detailsFramework:CreateRoundedPanel(parent, name, optionsTable)
frame:SetPoint("center", parent, "center", 0, 0)