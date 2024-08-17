
local Details = Details

---@type detailsframework
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
    optionsFrame:SetFrameStrata("DIALOG")
    optionsFrame:SetPoint("topleft", UIParent, "topleft", 2, -40)
    optionsFrame.Title:SetParent(optionsFrame)
    optionsFrame.TitleBar:Hide()
    optionsFrame:Show()

    --remove the backdrop
    optionsFrame:SetBackdrop(nil)

    --apply rounded corners with the breakdown window preset
    DF:AddRoundedCornersToFrame(optionsFrame, Details.PlayerBreakdown.RoundedCornerPreset)

    local closeButton = DF:CreateCloseButton(optionsFrame, "$parentTopRightCloseButton")
    closeButton:SetPoint("topright", optionsFrame, "topright", -5, -5)

    Details:RefreshWindowColor()

    local resetSettings = function()
        --overwrite the settings for the spell frame
        for key, value in pairs (Details.default_global_data.breakdown_spell_tab) do
            if (type(value) == "table") then
                local t = DF.table.copy({}, value)
                Details.breakdown_spell_tab[key] = t
            else
                Details.breakdown_spell_tab[key] = value
            end
        end

        --overwrite the settings for the general frame
        for key, value in pairs (Details.default_global_data.breakdown_general) do
            if (type(value) == "table") then
                local t = DF.table.copy({}, value)
                Details.breakdown_general[key] = t
            else
                Details.breakdown_general[key] = value
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
        {type = "label", get = function() return "General Settings" end, text_template = subSectionTitleTextTemplate},
        --background color from setting Details.frame_background_color
            { --background color
                type = "color",
                get = function()
                        local colorTable = Details.frame_background_color
                        return colorTable[1], colorTable[2], colorTable[3], colorTable[4]
                    end,
                set = function(self, r, g, b, a)
                    local colorTable = Details.frame_background_color

                    --/run Details.frame_background_color = {0.1215, 0.1176, 0.1294, 0.934}

                    r = math.min(r, 0.1215)
                    g = math.min(g, 0.1176)
                    b = math.min(b, 0.1294)
                    a = math.min(a, 0.934)

                    colorTable[1] = r
                    colorTable[2] = g
                    colorTable[3] = b
                    colorTable[4] = a
                    Details:SetWindowColor(r, g, b, a)
                end,
                name = "Background Color",
                desc = "Background Color",
            },

        {type = "blank"},

        {type = "label", get = function() return "Spell Details Block" end, text_template = subSectionTitleTextTemplate},
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

        {type = "blank"},

        {type = "label", get = function() return "What to Show" end, text_template = subSectionTitleTextTemplate},
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

        {type = "blank"},

        {type = "label", get = function() return "Text Options" end, text_template = subSectionTitleTextTemplate},
            { --font color
                type = "color",
                get = function() return Details.breakdown_general.font_color[1], Details.breakdown_general.font_color[2], Details.breakdown_general.font_color[3], Details.breakdown_general.font_color[4] end,
                set = function(self, r, g, b, a)
                    local colorTable = Details.breakdown_general.font_color
                    colorTable[1] = r
                    colorTable[2] = g
                    colorTable[3] = b
                    colorTable[4] = a
                    Details:UpdateBreakdownPlayerList()
                    DetailsAllAttributesFrame:UpdateFontStrings()
                end,
                name = "Text Color",
                desc = "Text Color",
            },

            { --font size
                type = "range",
                get = function() return Details.breakdown_general.font_size end,
                set = function(self, fixedparam, value)
                    Details.breakdown_general.font_size = value
                    Details:UpdateBreakdownPlayerList()
                    DetailsAllAttributesFrame:UpdateFontStrings()
                end,
                min = 8,
                max = 20,
                step = 1,
                name = "Text Size",
                desc = "Text Size",
            },

            { --font outline
                type = "outlinedropdown",
                get = function() return Details.breakdown_general.font_outline end,
                set = function(self, fixedparam, value)
                    Details.breakdown_general.font_outline = value
                    Details:UpdateBreakdownPlayerList()
                    DetailsAllAttributesFrame:UpdateFontStrings()
                end,
                name = "Text Outline",
                desc = "Text Outline",
            },

            {---font face
                type = "fontdropdown",
                get = function() return Details.breakdown_general.font_face end,
                set = function(self, fixedparam, value)
                    Details.breakdown_general.font_face = value
                    Details:UpdateBreakdownPlayerList()
                    DetailsAllAttributesFrame:UpdateFontStrings()
                end,
                name = "Font Face",
                desc = "Font Face",
                include_default = true,
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

        {type = "blank"},
        {type = "label", get = function() return "Group Player Spells:" end, text_template = subSectionTitleTextTemplate},
            { --nest player spells | merge player spells
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.nest_players_spells_with_same_name end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.nest_players_spells_with_same_name = value
                end,
                name = "Group Player Spells With Same Name",
                desc = "Group spells casted by players which has the same name",
            },

        {type = "blank"},
        {type = "label", get = function() return "Group Pet Spells:" end, text_template = subSectionTitleTextTemplate},

            { --nest pet spells with the same name
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.nest_pet_spells_by_name end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.nest_pet_spells_by_name = value
                end,
                name = "Group Pet Names Under a Pet Spell Bar",
                desc = "Group Pets By Name",
                hooks = {["OnSwitch"] = function()
                    if (Details.breakdown_spell_tab.nest_pet_spells_by_name) then
                        Details.breakdown_spell_tab.nest_pet_spells_by_caster = false
                        DetailsSpellBreakdownOptionsPanel:RefreshOptions()
                    end
                end}
            },

            { --nest pet spells with the same name
                type = "toggle",
                get = function() return Details.breakdown_spell_tab.nest_pet_spells_by_caster end,
                set = function(self, fixedparam, value)
                    Details.breakdown_spell_tab.nest_pet_spells_by_caster = value

                end,
                name = "Group Pet Spells Under a Pet Name Bar",
                desc = "Group Pets By Spell",
                hooks = {["OnSwitch"] = function()
                    if (Details.breakdown_spell_tab.nest_pet_spells_by_caster) then
                        Details.breakdown_spell_tab.nest_pet_spells_by_name = false
                        DetailsSpellBreakdownOptionsPanel:RefreshOptions()
                    end
                end}
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