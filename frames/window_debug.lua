
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

--frame options
local windowWidth = 1024
local windowHeight = 670
local scrollWidth = 990
local scrollHeightBuff = 400
local scrollHeightDebuff = 200
local scrollLineAmountBuff = 20
local scrollLineAmountDebuff = 10
local scrollLineHeight = 20
local amountOfLines = 26
local lineHeight = 19

local createDebugOptionsFrame = function()
    --create a panel
    --parent, width, height, title, frameName, panelOptions
    local debugOptionsPanel = DetailsFramework:CreateSimplePanel(UIParent, windowWidth/2, windowHeight, "Details! Debug Options", "DetailsDebugOptionsPanel", {})

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

        {type = "blank"},

        {--storage debug
            type = "toggle",
            get = function()
                return Details222.storage.IsDebug
            end,
            set = function(self, fixedparam, value)
                Details222.storage.IsDebug = value
                if (Details222.storage.IsDebug) then
                    Details:Msg("Storage Debug is ON.")
                else
                    Details:Msg("Storage Debug is OFF.")
                end
            end,
            name = "Encounter Storage Debug",
            desc = "Internal tests of the storage feature.",
        },

        {type = "blank"},

        {--pet debug
            type = "toggle",
            get = function()
                return Details222.Debug.DebugPets
            end,
            set = function(self, fixedparam, value)
                Details222.Debug.DebugPets = value
                if (Details222.Debug.DebugPets) then
                    Details:Msg("Pet Debug is ON.")
                    Details:ShowCleuDebugWindow(function(token, who_serial, who_name, who_flags, target_serial, target_name, target_flags, A1, A2, A3)
                        if (token == "SPELL_SUMMON") then
                            return true
                        end
                    end)
                else
                    Details:Msg("Pet Debug is OFF.")
                end
            end,
            name = "General Pet Debug",
            desc = "General Pet Debug",
        },

        {--pet debug
            type = "toggle",
            get = function()
                return Details222.Debug.DebugPlayerPets
            end,
            set = function(self, fixedparam, value)
                Details222.Debug.DebugPlayerPets = value
                if (Details222.Debug.DebugPlayerPets) then
                    Details:Msg("Player Pet Debug is ON.")
                    Details:ShowCleuDebugWindow(function(token, who_serial, sourceName, who_flags, target_serial, target_name, target_flags, A1, A2, A3)
                        if (token == "SPELL_SUMMON") then
                            if (sourceName == Details.playername) then
                                return true
                            end
                        end
                    end)
                else
                    Details:Msg("Player Pet Debug is OFF.")
                end
            end,
            name = "Player Pets Debug",
            desc = "Player Pets Debug",
        },
    }

    --/run Details:GetWindow(1):GetActorInfoFromLineIndex(3)

    --create a label with the text "actor info from window and line index"
    local actorInfoLabel = detailsFramework:CreateLabel(debugOptionsPanel, "Get Actor Info From Window 'X' and Line Index 'X'", 12)
    actorInfoLabel:SetPoint("bottomleft", debugOptionsPanel, "bottomleft", 5, 50)

    local instanceIdEntry = detailsFramework:CreateTextEntry(debugOptionsPanel, function()end, 20, 20, _, _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
    instanceIdEntry:SetPoint("topleft", actorInfoLabel, "bottomleft", 0, -5)
    instanceIdEntry:SetText("1")

    local lineIndexEntry = detailsFramework:CreateTextEntry(debugOptionsPanel, function()end, 20, 20, _, _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
    lineIndexEntry:SetPoint("left", instanceIdEntry, "right", 5, 0)
    lineIndexEntry:SetText("1")

    --create a button with the get "Get", when the button is pressed, it get the text in the instanceIdEntry and lineIndexEntry and call the function GetActorInfoFromWindowAndLineIndex
    local getButton = detailsFramework:CreateButton(debugOptionsPanel, function()
        local instanceId = tonumber(instanceIdEntry:GetText())
        local lineIndex = tonumber(lineIndexEntry:GetText())
        Details:GetWindow(instanceId):GetActorInfoFromLineIndex(lineIndex)
    end, 50, 20, "Get")
    getButton:SetPoint("left", lineIndexEntry, "right", 5, 0)
    getButton:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

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


function Details:ShowCleuDebugWindow(filterFunction)
    if (not DetailsCleuDebugWindow) then
        --create a simple panel from the framework with size of 400 x 800
        --this panel will have a scrollbox with 20 lines, these lines will show data
        --each line will have an icon, 6 text entries and 3 labels
        --the scrollbox is attached to a header frame from the framework for organization

        --create a panel
        --parent, width, height, title, frameName, panelOptions
        local cleuDebugPanel = detailsFramework:CreateSimplePanel(UIParent, windowWidth, windowHeight, "Details! Cleu Debug", "DetailsCleuDebugWindow", {})
        detailsFramework:ApplyStandardBackdrop(cleuDebugPanel)

        cleuDebugPanel:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

        cleuDebugPanel:SetScript("OnShow", function()
            cleuDebugPanel:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end)

        cleuDebugPanel:SetScript("OnHide", function()
            cleuDebugPanel:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end)

        --disable the buil-in mouse integration of the simple panel, doing this to use LibWindow-1.1 as the window management
        cleuDebugPanel:SetScript("OnMouseDown", nil)
        cleuDebugPanel:SetScript("OnMouseUp", nil)

        --need to create a window frame button that only accepts right clicks and when clicked it'll hide the panel

        --register in the libWindow
        local LibWindow = LibStub("LibWindow-1.1")
        LibWindow.RegisterConfig(cleuDebugPanel, Details.cleu_debug_panel.position)
        LibWindow.MakeDraggable(cleuDebugPanel)
        LibWindow.RestorePosition(cleuDebugPanel)

        --scale bar
        local scaleBar = detailsFramework:CreateScaleBar(cleuDebugPanel, Details.cleu_debug_panel.scaletable)
        cleuDebugPanel:SetScale(Details.cleu_debug_panel.scaletable.scale)

        --status bar
        local statusBar = detailsFramework:CreateStatusBar(cleuDebugPanel)
        statusBar.text = statusBar:CreateFontString(nil, "overlay", "GameFontNormal")
        statusBar.text:SetPoint("left", statusBar, "left", 5, 0)
        statusBar.text:SetText("By Terciob | Part of Details! Damage Meter")
        detailsFramework:SetFontSize(statusBar.text, 11)
        detailsFramework:SetFontColor(statusBar.text, "gray")

        ---@type df_headercolumndata[]
        local headerTable = {
			{text = "", width = 20},
			{text = "Source Name", width = 150},
			{text = "Spell Name", width = 150},
			{text = "Pet Name", width = 150},
			{text = "Spell ID", width = 50},
			{text = "Data 1", width = 150},
			{text = "Data 2", width = 150},
			{text = "Data 3", width = 150},
        }

		local headerOptions = {
			padding = 2,
		}

        ---@type df_headerframe
        local headerFrame = detailsFramework:CreateHeader(cleuDebugPanel, headerTable, headerOptions)
        cleuDebugPanel.Header = headerFrame

        local onRefreshScroll = function(self, data, offSet, totalLines)
            for i = 1, totalLines do
                local index = i + offSet
                local spellData = data[index]
                if (spellData) then
                    local time, token, sourceGUID, sourceName, sourceFlags, targetGUID, targetName, targetFlags, A1, A2, A3 = unpack(spellData)

                    local line = self:GetLine(i)
                    if (line) then
                        line.Icon:SetTexture(select(3, Details222.GetSpellInfo(A1)))
                        line.casterNameText:SetText(sourceName)
                        line.spellNameText:SetText(A2)
                        line.targetNameText:SetText(targetName)
                        line.spellIdText:SetText(A1)

                        if (Details222.Debug.DebugPets or Details222.Debug.DebugPlayerPets) then
                            local petContainer = Details222.PetContainer
                            ---@type petdata?
                            local petData = petContainer.GetPetInfo(targetGUID)
                            if (petData) then
                                --print(targetGUID, petData.ownerName, petData.petName, petData.petFlags)
                                line.data1Text:SetText(petData.ownerName)
                                line.data2Text:SetText(petData.petName)
                                line.data3Text:SetText(petData.petFlags)
                            else
                                line.data1Text:SetText("Pet not found")
                                line.data2Text:SetText("")
                                line.data3Text:SetText("")
                            end
                        else
                            line.data1Text:SetText("")
                            line.data2Text:SetText("")
                            line.data3Text:SetText("")
                        end
                    end
                end
            end
        end

        local dropdownTemplate = DetailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWNDARK_TEMPLATE")

        local createLineFunc = function(self, index)
            --create the line for a scrollbox
            local line = CreateFrame("frame", "$parentLine" .. index, self, "BackdropTemplate")
            --set the point using the line index, line height and scrollbox width
			line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(lineHeight+1)) - 1)
			line:SetSize(scrollWidth - 2, lineHeight)

            --import functions from the header feature
            detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

            --create the spell icon texture
            local icon = line:CreateTexture(nil, "overlay")
            icon:SetSize(lineHeight-2, lineHeight-2)

            --create the caster name text entry
            local casterNameText = DetailsFramework:CreateTextEntry(line, function()end, headerTable[2].width, lineHeight, _, _, _, dropdownTemplate)

            --create the spell name text entry
            local spellNameText = DetailsFramework:CreateTextEntry(line, function()end, headerTable[3].width, lineHeight, _, _, _, dropdownTemplate)

            --create the target name text entry
            local targetNameText = DetailsFramework:CreateTextEntry(line, function()end, headerTable[4].width, lineHeight, _, _, _, dropdownTemplate)

            --create the spell id text entry
            local spellIdText = DetailsFramework:CreateTextEntry(line, function()end, headerTable[5].width, lineHeight, _, _, _, dropdownTemplate)

            --create a negeric text entry
            local data1Text = DetailsFramework:CreateTextEntry(line, function()end, headerTable[6].width, lineHeight, _, _, _, dropdownTemplate)
            --create a negeric text entry
            local data2Text = DetailsFramework:CreateTextEntry(line, function()end, headerTable[7].width, lineHeight, _, _, _, dropdownTemplate)
            --create a negeric text entry
            local data3Text = DetailsFramework:CreateTextEntry(line, function()end, headerTable[8].width, lineHeight, _, _, _, dropdownTemplate)

			line:AddFrameToHeaderAlignment(icon)
			line:AddFrameToHeaderAlignment(casterNameText)
			line:AddFrameToHeaderAlignment(spellNameText)
			line:AddFrameToHeaderAlignment(targetNameText)
			line:AddFrameToHeaderAlignment(spellIdText)
            line:AddFrameToHeaderAlignment(data1Text)
            line:AddFrameToHeaderAlignment(data2Text)
            line:AddFrameToHeaderAlignment(data3Text)

			line:AlignWithHeader(headerFrame, "left")

			line.Icon = icon
			line.casterNameText = casterNameText
			line.spellNameText = spellNameText
			line.targetNameText = targetNameText
			line.spellIdText = spellIdText
            line.data1Text = data1Text
            line.data2Text = data2Text
            line.data3Text = data3Text

            return line
        end

        cleuDebugPanel.ScrollBoxData = {}
        --create a scrollbox
        ---@type df_scrollbox
        local scrollBox = detailsFramework:CreateScrollBox(cleuDebugPanel, "$parentScrollBox", onRefreshScroll, cleuDebugPanel.ScrollBoxData, scrollWidth, windowHeight - 60, amountOfLines, lineHeight)
        scrollBox:SetPoint("topleft", cleuDebugPanel, "topleft", 5, -46)
        cleuDebugPanel.ScrollBox = scrollBox

        cleuDebugPanel.Header:SetPoint("bottomleft", scrollBox, "topleft", 0, 2)

        for i = 1, amountOfLines do
            --just call the line creation function with the scrollbox as the parent argument and the line index
            scrollBox:CreateLine(createLineFunc)
        end

        local bHasScheduled = false

        cleuDebugPanel:SetScript("OnEvent", function()
            local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()
            local addLine = filterFunction(token, who_serial, who_name, who_flags, target_serial, target_name, target_flags, A1, A2, A3)
            if (addLine) then
                table.insert(cleuDebugPanel.ScrollBoxData, {
                    GetTime() - cleuDebugPanel.Time,
                    token,
                    who_serial,
                    who_name,
                    who_flags,
                    target_serial,
                    target_name,
                    target_flags,
                    A1,
                    A2,
                    A3
                })

                if (not bHasScheduled) then
                    bHasScheduled = true
                    C_Timer.After(0.1, function()
                        bHasScheduled = false
                        scrollBox:Refresh()
                    end)
                end
            end
        end)
    end

    DetailsCleuDebugWindow:Show()
    table.wipe(DetailsCleuDebugWindow.ScrollBoxData) --clear the data
    DetailsCleuDebugWindow.ScrollBox:Refresh()
    DetailsCleuDebugWindow.Time = GetTime()
end