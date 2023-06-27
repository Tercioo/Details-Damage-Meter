
local Details = _G.Details
local detailsFramework = _G.DetailsFramework
local _
local addonName, Details222 = ...
local CreateFrame = CreateFrame
local UIParent = UIParent
local load = loadstring

function Details:InitializeRunCodeWindow()
    local detailsRunCodePanel = detailsFramework:CreateSimplePanel(UIParent, 700, 480, "Details! Run Code Automation", "DetailsRunCodePanel")
    detailsRunCodePanel.Frame = detailsRunCodePanel
    detailsRunCodePanel.__name = "Auto Run Code"
    detailsRunCodePanel.real_name = "DETAILS_RUNCODEWINDOW"
    --DetailsRunCodePanel.__icon = [[Interface\AddOns\Details\images\lua_logo]]
    detailsRunCodePanel.__icon = [[Interface\AddOns\Details\images\run_code]]
    --DetailsRunCodePanel.__iconcoords = {0, 1, 0, 1}
    detailsRunCodePanel.__iconcoords = {0, 30/32, 0, 25/32}
    detailsRunCodePanel.__iconcoords = {0, 1, 0, 1}
    detailsRunCodePanel.__iconcolor = "white"
    DetailsPluginContainerWindow.EmbedPlugin(detailsRunCodePanel, detailsRunCodePanel, true)

    function detailsRunCodePanel.RefreshWindow()
        Details222.AutoRunCode.OpenRunCodeWindow()
    end

    detailsRunCodePanel:Hide()

    Details222.AutoRunCode.DetailsRunCodePanel = detailsRunCodePanel
end

function Details222.AutoRunCode.OpenRunCodeWindow()
    local detailsRunCodePanel = Details222.AutoRunCode.DetailsRunCodePanel

    if (not detailsRunCodePanel or not detailsRunCodePanel.Initialized) then
        detailsRunCodePanel.Initialized = true

        local autoRunCodeFrame = detailsRunCodePanel or detailsFramework:CreateSimplePanel(UIParent, 700, 480, "Details! Run Code", "DetailsRunCodePanel")

        --lua editor
        local codeEditor = detailsFramework:NewSpecialLuaEditorEntry(UIParent, 885, 510, nil, nil, false, true, true)
        codeEditor:SetPoint("topleft", autoRunCodeFrame, "topleft", 20, -56)
        codeEditor:SetFrameStrata(autoRunCodeFrame:GetFrameStrata())
        codeEditor:SetFrameLevel(autoRunCodeFrame:GetFrameLevel()+1)

        function Details222.AutoRunCode.CodeEditorSetText(codeKey)
            local text = Details222.AutoRunCode.CodeTable[codeKey]
            return codeEditor:SetText(text)
        end

        detailsRunCodePanel:HookScript("OnShow", function()
            codeEditor:Show()
        end)
        detailsRunCodePanel:SetScript("OnHide", function()
            codeEditor:Hide()
            _G.DetailsPluginContainerWindow:Hide()
        end)

        --code editor appearance
        codeEditor.scroll:SetBackdrop(nil)
        codeEditor.editbox:SetBackdrop(nil)
        codeEditor:SetBackdrop(nil)

        detailsFramework:ReskinSlider(codeEditor.scroll)

        if (not codeEditor.__background) then
            codeEditor.__background = codeEditor:CreateTexture(nil, "background")
        end

        codeEditor:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
        codeEditor:SetBackdropBorderColor(0, 0, 0, 1)

        codeEditor.__background:SetColorTexture(0.2317647, 0.2317647, 0.2317647)
        codeEditor.__background:SetVertexColor(0.27, 0.27, 0.27)
        codeEditor.__background:SetAlpha(0.8)
        codeEditor.__background:SetVertTile(true)
        codeEditor.__background:SetHorizTile(true)
        codeEditor.__background:SetAllPoints()

        --code compile error warning
        local errortext_frame = CreateFrame("frame", nil, codeEditor, "BackdropTemplate")
        errortext_frame:SetPoint("bottomleft", codeEditor, "bottomleft", 1, 1)
        errortext_frame:SetPoint("bottomright", codeEditor, "bottomright", -1, 1)
        errortext_frame:SetHeight(20)
        errortext_frame:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        errortext_frame:SetBackdropBorderColor(0, 0, 0, 1)
        errortext_frame:SetBackdropColor(0, 0, 0)

        detailsFramework:CreateFlashAnimation (errortext_frame)

        local errortext_label = detailsFramework:CreateLabel(errortext_frame, "", detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
        errortext_label.textcolor = "red"
        errortext_label:SetPoint("left", errortext_frame, "left", 3, 0)
        codeEditor.NextCodeCheck = 0.33

        codeEditor:HookScript ("OnUpdate", function(self, deltaTime)
            codeEditor.NextCodeCheck = codeEditor.NextCodeCheck - deltaTime

            if (codeEditor.NextCodeCheck < 0) then
                local script = codeEditor:GetText()
                local func, errortext = load(script, "Q")
                if (not func) then
                    local firstLine = strsplit("\n", script, 2)
                    errortext = errortext:gsub(firstLine, "")
                    errortext = errortext:gsub("%[string \"", "")
                    errortext = errortext:gsub("...\"]:", "")
                    errortext = errortext:gsub("Q\"]:", "")
                    errortext = "Line " .. errortext
                    errortext_label.text = errortext
                else
                    errortext_label.text = ""
                end

                codeEditor.NextCodeCheck = 0.33
            end
        end)

        --script selector
        local on_select_CodeType_option = function(self, fixedParameter, value)
            --set the current editing code type
            autoRunCodeFrame.EditingCode = Details.RunCodeTypes[value].Value
            autoRunCodeFrame.EditingCodeKey = Details.RunCodeTypes[value].ProfileKey

            --load the code for the event
            Details222.AutoRunCode.CodeEditorSetText(autoRunCodeFrame.EditingCodeKey)
        end

        local build_CodeType_dropdown_options = function()
            local t = {}

            for i = 1, #Details.RunCodeTypes do
                local option = Details.RunCodeTypes [i]
                t [#t + 1] = {label = option.Name, value = option.Value, onclick = on_select_CodeType_option, desc = option.Desc}
            end

            return t
        end

        local code_type_label = detailsFramework:CreateLabel(autoRunCodeFrame, "Event:", detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
        local code_type_dropdown = detailsFramework:CreateDropDown(autoRunCodeFrame, build_CodeType_dropdown_options, 1, 160, 20, "CodeTypeDropdown", _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
        code_type_dropdown:SetPoint("left", code_type_label, "right", 2, 0)
        code_type_dropdown:SetFrameLevel(codeEditor:GetFrameLevel() + 10)
        code_type_label:SetPoint("bottomleft", codeEditor, "topleft", 0, 8)

        --create save button
        local save_script = function()
            local code = codeEditor:GetText()
            local func, errortext = load(code, "Q")

            if (func) then
                Details222.AutoRunCode.CodeTable[autoRunCodeFrame.EditingCodeKey] = code
                Details222.AutoRunCode.RecompileAutoRunCode()
                Details:Msg("Code saved!")
                codeEditor:ClearFocus()
            else
                errortext_frame:Flash(0.2, 0.2, 0.4, true, nil, nil, "NONE")
                Details:Msg("Can't save the code: it has errors.")
            end
        end

        local cancel_script = function()
            Details222.AutoRunCode.CodeEditorSetText(autoRunCodeFrame.EditingCodeKey)
            codeEditor:ClearFocus()
        end

        local execute_script = function()
            local script = codeEditor:GetText()
            local func, errortext = load(script, "Q")

            if (func) then
                detailsFramework:SetEnvironment(func)
                detailsFramework:QuickDispatch(func)
            else
                errortext_frame:Flash(0.2, 0.2, 0.4, true, nil, nil, "NONE")
            end
        end

        local button_y = -6

        local saveButton = CreateFrame("button", nil, codeEditor)
        detailsFramework:ApplyStandardBackdrop(saveButton)
        saveButton:SetSize(120, 20)
        saveButton:SetText("Save")
        saveButton:SetScript("OnClick", save_script)
        saveButton:SetPoint("topright", codeEditor, "bottomright", 0, button_y)
        saveButton:SetNormalFontObject("GameFontNormal")

        local cancelButton = CreateFrame("button", nil, codeEditor)
        detailsFramework:ApplyStandardBackdrop(cancelButton)
        cancelButton:SetSize(120, 20)
        cancelButton:SetText("Cancel")
        cancelButton:SetScript("OnClick", cancel_script)
        cancelButton:SetPoint("topleft", codeEditor, "bottomleft", 0, button_y)
        cancelButton:SetNormalFontObject("GameFontNormal")

        --create run now button
        local runButton = CreateFrame("button", nil, codeEditor)
        detailsFramework:ApplyStandardBackdrop(runButton)
        runButton:SetSize(120, 20)
        runButton:SetText("Test Code")
        runButton:SetScript("OnClick", execute_script)
        runButton:SetPoint("bottomright", codeEditor, "topright", 0, 3)
        runButton:SetNormalFontObject("GameFontNormal")
    end

    DetailsPluginContainerWindow.OpenPlugin(detailsRunCodePanel)
    detailsRunCodePanel.CodeTypeDropdown:Select(1, true)

    --show the initialization code when showing up this window
    detailsRunCodePanel.EditingCode = Details.RunCodeTypes[1].Value
    detailsRunCodePanel.EditingCodeKey = Details.RunCodeTypes[1].ProfileKey

    Details222.AutoRunCode.CodeEditorSetText(detailsRunCodePanel.EditingCodeKey)
end
