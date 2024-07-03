
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

--frame options
local windowWidth = 800
local windowHeight = 670
local scrollWidth = 790
local scrollHeightBuff = 400
local scrollHeightDebuff = 200
local scrollLineAmountBuff = 20
local scrollLineAmountDebuff = 10
local scrollLineHeight = 20

local createDebugOptionsFrame = function()
    --create a panel
    --parent, width, height, title, frameName, panelOptions
    local debugOptionsPanel = DetailsFramework:CreateSimplePanel(UIParent, windowWidth, windowHeight, "Details! Debug Options", "DetailsDebugOptionsPanel", {})

    detailsFramework:ApplyStandardBackdrop(debugOptionsPanel)

    --disable the buil-in mouse integration of the simple panel, doing this to use LibWindow-1.1 as the window management
    debugOptionsPanel:SetScript("OnMouseDown", nil)
    debugOptionsPanel:SetScript("OnMouseUp", nil)

    --need to create a window frame button that only accepts right clicks and when clicked it'll hide the panel

    --register in the libWindow
    local LibWindow = LibStub("LibWindow-1.1")
    LibWindow.RegisterConfig(debugOptionsPanel, Details.debug_options_panel.position)
    LibWindow.MakeDraggable(debugOptionsPanel)
    LibWindow.RestorePosition(debugOptionsPanel)

    --scale bar
    local scaleBar = DetailsFramework:CreateScaleBar(debugOptionsPanel, Details.debug_options_panel.scaletable)
    debugOptionsPanel:SetScale(Details.debug_options_panel.scaletable.scale)

    --status bar
    local statusBar = DetailsFramework:CreateStatusBar(debugOptionsPanel)
    statusBar.text = statusBar:CreateFontString(nil, "overlay", "GameFontNormal")
    statusBar.text:SetPoint("left", statusBar, "left", 5, 0)
    statusBar.text:SetText("By Terciob | Part of Details! Damage Meter")
    DetailsFramework:SetFontSize(statusBar.text, 11)
    DetailsFramework:SetFontColor(statusBar.text, "gray")

    local options = {
        {--general debug
            type = "toggle",
            get = function()
                return Details.debug
            end,
            set = function(self, fixedparam, value)
                Details.debug = value
                if (not value) then
                    Details:Msg("diagnostic mode has been turned off.")
                else
                    Details:Msg("diagnostic mode has been turned on.")
                end
            end,
            name = "General Details! Debug",
            desc = "General Details! Debug",
        },

        {type = "blank"},

        {--debug net
            type = "toggle",
            get = function()
                return Details.debugnet
            end,
            set = function(self, fixedparam, value)
                Details.debugnet = value
                if (not value) then
                    Details:Msg("net diagnostic mode has been turned off.")
                else
                    Details:Msg("net diagnostic mode has been turned on.")
                end
            end,
            name = "Net Diagnostic Debug",
            desc = "Net Diagnostic Debug",
        },

        {type = "blank"},

        {--mythic+ debug
            type = "toggle",
            get = function()
                local debugState = Details222.Debug.GetMythicPlusDebugState()
                return debugState
            end,
            set = function(self, fixedparam, value)
                Details222.Debug.SetMythicPlusDebugState()
            end,
            name = "End of Mythic+ Panel Debug",
            desc = "Panel shown at the end of a Mythic+ dungeon",
        },

        {--mythic+ loot debug
            type = "toggle",
            get = function()
                local _, lootDebugState = Details222.Debug.GetMythicPlusDebugState()
                return lootDebugState
            end,
            set = function(self, fixedparam, value)
                Details222.Debug.SetMythicPlusLootDebugState()
            end,
            name = "Loot Shown in the End of Mythic+ Panel Debug",
            desc = "Loot shown in the Panel shown at the end of a Mythic+ dungeon",
        },

        {--mythic+ chart debug
            type = "toggle",
            get = function()
                return Details222.Debug.MythicPlusChartWindowDebug
            end,
            set = function(self, fixedparam, value)
                Details222.Debug.MythicPlusChartWindowDebug = value
            end,
            name = "Mythic+ Chart Save and Use The Same Chart Data",
            desc = "When enabled, Details! will save the chart data from the next m+ run and use it when showing the chart panel. This save persist on saved variables and I don't think it is deleted, never.",
            --/run Details.mythic_plus.last_mythicrun_chart = {}
        },
    }

    options.always_boxfirst = true
    options.align_as_pairs = true
    options.align_as_pairs_string_space = 260

    --templates
    local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

    detailsFramework:BuildMenu(debugOptionsPanel, options, 5, -40, windowHeight - 50, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
end

function Details.ShowDebugOptionsPanel()
    if (DetailsDebugOptionsPanel) then
        DetailsDebugOptionsPanel:Show()
    else
        createDebugOptionsFrame()
    end
end