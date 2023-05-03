
local Details = Details
local DF = DetailsFramework

--create the main frame for the options panel

local createOptionsPanel = function()
    local startX = 5
    local startY = -32
    local heightSize = 540

    local DetailsSpellBreakdownTab = DetailsSpellBreakdownTab
    local UIParent = UIParent

    local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

    local optionsFrame = DF:CreateSimplePanel(UIParent, 550, 500, "Details! Breakdown Options", "DetailsSpellBreakdownOptionsPanel")
    optionsFrame:SetFrameStrata("HIGH")
    optionsFrame:SetPoint("topleft", UIParent, "topleft", 2, -40)
    optionsFrame:Show()

    local bUseSolidColor = true
    DF:ApplyStandardBackdrop(optionsFrame, bUseSolidColor)

    local resetSettings = function()
        for key, value in pairs (Details.default_global_data.breakdown_spell_tab) do
            if (type(value) == "table") then
                local t = DF.table.copy({}, value)
                Details.breakdown_spell_tab[key] = t
            else
                Details.breakdown_spell_tab[key] = value
            end
        end

        local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
        local actorObject = Details:GetActorObjectFromBreakdownWindow()
        local bFromAttributeChange = true
        local bIsRefresh = true
        local bIsShiftKeyDown = false
        local bIsControlKeyDown = false

        Details:CloseBreakdownWindow()
        Details:OpenBreakdownWindow(instanceObject, actorObject, bFromAttributeChange, bIsRefresh, bIsShiftKeyDown, bIsControlKeyDown)
        DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
        DetailsSpellBreakdownTab.UpdateShownSpellBlock()
        DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
        DetailsSpellBreakdownOptionsPanel:RefreshOptions()

        Details:Msg("Settings reseted to default.")
    end

    local resetSettingsButton = DF:CreateButton(optionsFrame, resetSettings, 130, 20, "Reset Settings")
    resetSettingsButton:SetPoint("bottomleft", optionsFrame, "bottomleft", 5, 5)
    resetSettingsButton:SetTemplate(options_button_template)

    local subSectionTitleTextTemplate = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")

    local optionsTable = {
        {type = "label", get = function() return "Spell Details Block" end, text_template = subSectionTitleTextTemplate},
            {--width
                type = "range",
                get = function() return Details.breakdown_spell_tab.blockcontainer_width end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.blockcontainer_width = value
                    DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
                end,
                min = 150,
                max = 450,
                step = 1,
                name = "Width",
                desc = "Width",
                hidden = true,
            },
            {--height
                type = "range",
                get = function() return Details.breakdown_spell_tab.blockcontainer_height end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.blockcontainer_height = value
                    DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
                end,
                min = 150,
                max = 450,
                step = 1,
                name = "Height",
                desc = "Height",
                hidden = true,
            },
            {--block height
                type = "range",
                get = function() return Details.breakdown_spell_tab.blockspell_height end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.blockspell_height = value
                    DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
                end,
                min = 50,
                max = 80,
                step = 1,
                name = "Block Height",
                desc = "Block Height",
            },
            {--line height
                type = "range",
                get = function() return Details.breakdown_spell_tab.blockspellline_height end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.blockspellline_height = value
                    DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
                end,
                min = 10,
                max = 30,
                step = 1,
                name = "Line Height",
                desc = "Line Height",
            },
            {--show spark
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.blockspell_spark_show end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.blockspell_spark_show = value
                    DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
                end,
                name = "Show Spark",
                desc = "Show Spark",
            },
            {--spark width
                type = "range",
                get = function() return Details.breakdown_spell_tab.blockspell_spark_width end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.blockspell_spark_width = value
                    DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
                end,
                min = 1,
                max = 24,
                step = 1,
                name = "Spark Width",
                desc = "Spark Width",
            },
            {--spark offset
                type = "range",
                get = function() return Details.breakdown_spell_tab.blockspell_spark_offset end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.blockspell_spark_offset = value
                    DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
                    DetailsSpellBreakdownTab.UpdateShownSpellBlock()
                end,
                min = -12,
                max = 12,
                step = 1,
                name = "Spark Offset",
                desc = "Spark Offset",
            },
			{--spark color
				type = "color",
                get = function()
                    return Details.breakdown_spell_tab.blockspell_spark_color
				end,
				set = function(self, r, g, b, a)
                    Details.breakdown_spell_tab.blockspell_spark_color[1] = r
                    Details.breakdown_spell_tab.blockspell_spark_color[2] = g
                    Details.breakdown_spell_tab.blockspell_spark_color[3] = b
                    Details.breakdown_spell_tab.blockspell_spark_color[4] = a
                    DetailsSpellBreakdownTab.GetSpellBlockFrame():UpdateBlocks()
				end,
				name = "Spark Color",
				desc = "Spark Color",
            },

        {type = "blank"},
        {type = "blank"},

        {type = "label", get = function() return "Spell Header Options" end, text_template = subSectionTitleTextTemplate},
            { --per second
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_headers["persecond"].enabled end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellcontainer_headers["persecond"].enabled = value
                    DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
                end,
                name = "Per Second",
                desc = "Per Second",
            },

            { --amount of casts
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_headers["casts"].enabled end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellcontainer_headers["casts"].enabled = value
                    DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
                end,
                name = "Casts",
                desc = "Casts",
            },

            { --critical hits percent
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_headers["critpercent"].enabled end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellcontainer_headers["critpercent"].enabled = value
                    DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
                end,
                name = "Critical Hits Percent",
                desc = "Critical Hits Percent",
            },

            { --amount of hits
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_headers["hits"].enabled end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellcontainer_headers["hits"].enabled = value
                    DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
                end,
                name = "Hits Amount",
                desc = "Hits Amount",
            },

            { --average damage of healing per cast amount
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_headers["castavg"].enabled end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellcontainer_headers["castavg"].enabled = value
                    DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
                end,
                name = "Cast Average",
                desc = "Cast Average",
            },

            { --debuff uptime
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_headers["uptime"].enabled end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellcontainer_headers["uptime"].enabled = value
                    DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
                end,
                name = "Uptime",
                desc = "Uptime",
            },

            { --overheal
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_headers["overheal"].enabled end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellcontainer_headers["overheal"].enabled = value
                    DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
                end,
                name = "Overheal",
                desc = "Overheal",
            },

            { --absorbed
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_headers["absorbed"].enabled end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellcontainer_headers["absorbed"].enabled = value
                    DetailsSpellBreakdownTab.UpdateHeadersSettings("spells")
                end,
                name = "Heal Absorbed",
                desc = "Heal Absorbed",
            },

        {type = "breakline"},
        {type = "label", get = function() return "Scroll Options" end, text_template = subSectionTitleTextTemplate},

            { --locked
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.spellcontainer_islocked end,
                set = function(self, fixedparam, value)
                    ---@type df_framecontainer
                    local container = DetailsSpellBreakdownTab.GetSpellScrollContainer()
                    container:SetResizeLocked(value)

                    local container = DetailsSpellBreakdownTab.GetTargetScrollContainer()
                    container:SetResizeLocked(value)
                end,
                name = "Is Locked",
                desc = "Is Locked",
            },

            {--background alpha
                type = "range",
                get = function() return Details.breakdown_spell_tab.spellbar_background_alpha end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.spellbar_background_alpha = value
                    DetailsSpellBreakdownTab.GetSpellScrollFrame():Refresh()
                end,
                min = 0,
                max = 1,
                step = 0.1,
                usedecimals = true,
                name = "Background Alpha",
                desc = "Background Alpha",
            },

    }

    --build the menu
    optionsTable.always_boxfirst = true
    DF:BuildMenu(optionsFrame, optionsTable, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
end


function Details.OpenSpellBreakdownOptions()
    if (DetailsSpellBreakdownOptionsPanel) then
        DetailsSpellBreakdownOptionsPanel:RefreshOptions()
        DetailsSpellBreakdownOptionsPanel:Show()
        return
    end

    createOptionsPanel()
end