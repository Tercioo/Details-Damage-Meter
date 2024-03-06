if (true) then
    --return
end

local addonName, Details222 = ...
local Details = _G.Details
local detailsFramework = _G.DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

--options panel namespace
Details222.OptionsPanel = {}

--local tinsert = _G.tinsert
local unpack = _G.unpack
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local _
local preset_version = 3
Details.preset_version = preset_version

--templates
local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local options_button_template_selected = detailsFramework.table.copy({}, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
options_button_template_selected.backdropbordercolor = {1, .8, .2}

--options
local section_menu_button_width = 135
local section_menu_button_height = 20

local startX = 160

--build the options window
function Details:InitializeOptionsWindow(instance)
    return Details222.OptionsPanel.InitializeOptionsWindow(instance)
end

--C_Timer.After(2, function()
--    Details:OpenOptionsWindow(Details:GetInstance(1), false, 1)
--end)

function Details222.OptionsPanel.InitializeOptionsWindow(instance)
	local DetailsOptionsWindow = detailsFramework:NewPanel(UIParent, _, "DetailsOptionsWindow", _, 897, 592)
    local optionsFrame = DetailsOptionsWindow.frame
    optionsFrame:Hide()

    DetailsOptionsWindow:SetBackdrop({})
    detailsFramework:AddRoundedCornersToFrame(optionsFrame, Details.PlayerBreakdown.RoundedCornerPreset)
    optionsFrame:SetColor(unpack(Details.frame_background_color))

	optionsFrame.Frame = optionsFrame
	optionsFrame.__name = "Options"
	optionsFrame.real_name = "DETAILS_OPTIONS"
	optionsFrame.__icon = [[Interface\Scenarios\ScenarioIcon-Interact]]
    _G.DetailsPluginContainerWindow.EmbedPlugin(optionsFrame, optionsFrame, true)
    optionsFrame.sectionFramesContainer = {}

    local closeButton = detailsFramework:CreateCloseButton(optionsFrame, "$parentCloseButton")
    closeButton:SetScript("OnClick", function()
        DetailsPluginContainerWindow:Hide()
    end)
    closeButton:SetPoint("topright", optionsFrame, "topright", -5, -5)

    local titleText = detailsFramework:NewLabel(optionsFrame, nil, "$parentTitleLabel", "title", "Details! " .. Loc ["STRING_OPTIONS_WINDOW"], "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
    titleText:SetPoint("top", optionsFrame, "top", 0, -5)

    --[=[
    local gradientBelowTheLine = DetailsFramework:CreateTexture(optionsFrame, {gradient = "vertical", fromColor = {0, 0, 0, 0.25}, toColor = "transparent"}, 1, 90, "artwork", {0, 1, 0, 1}, "dogGradient")
    gradientBelowTheLine:SetPoint("bottoms")
    gradientBelowTheLine:Hide()

    local OTTFrame = CreateFrame("frame", "$parentOverTheTopFrame", optionsFrame)
    OTTFrame:SetSize(1, 1)
    OTTFrame:SetFrameLevel(999)
    OTTFrame:SetPoint("topleft", optionsFrame, "topleft", 0, 0)
    OTTFrame:Hide()

    --divisor shown above the tab options area
    local frameBackgroundTextureTopLine = OTTFrame:CreateTexture("$parentHeaderDivisorTopLine", "artwork")
    local divisorYPosition = -60
    frameBackgroundTextureTopLine:SetPoint("topleft", optionsFrame, "topleft", startX-9, divisorYPosition)
    frameBackgroundTextureTopLine:SetPoint("topright", optionsFrame, "topright", -1, divisorYPosition)
    frameBackgroundTextureTopLine:SetHeight(1)
    frameBackgroundTextureTopLine:SetColorTexture(0.1215, 0.1176, 0.1294)
    frameBackgroundTextureTopLine:Hide()

    --divisor shown in the left side of the tab options area
    local frameBackgroundTextureLeftLine = OTTFrame:CreateTexture("$parentHeaderDivisorLeftLine", "artwork")
    frameBackgroundTextureLeftLine:SetPoint("topleft", frameBackgroundTextureTopLine, "topleft", 0, 0)
    frameBackgroundTextureLeftLine:SetPoint("bottomleft", optionsFrame, "bottomleft", startX-9, 1)
    frameBackgroundTextureLeftLine:SetHeight(1)
    frameBackgroundTextureLeftLine:SetColorTexture(0.1215, 0.1176, 0.1294)
    frameBackgroundTextureLeftLine:Hide()

    local frameBackgroundTexture = optionsFrame:CreateTexture(nil, "artwork")
    frameBackgroundTexture:SetPoint("topleft", optionsFrame, "topleft", startX-9, divisorYPosition-1)
    frameBackgroundTexture:SetPoint("bottomright", optionsFrame, "bottomright", -1, 0)
    frameBackgroundTexture:SetColorTexture (0.2317647, 0.2317647, 0.2317647)
    frameBackgroundTexture:SetVertexColor (0.27, 0.27, 0.27)
    frameBackgroundTexture:SetAlpha (0.3)
    frameBackgroundTexture:Hide()
    --]=]

    --select the instance to edit
    local onSelectInstance = function(_, _, instanceId)
        ---@type instance
        local instanceObject = Details.tabela_instancias[instanceId]
        if (not instanceObject:IsEnabled() or not instanceObject:IsStarted()) then
            Details.CriarInstancia (_, _, instanceObject.meu_id)
        end

        Details222.OptionsPanel.SetCurrentInstanceAndRefresh(instanceObject)
        optionsFrame.updateMicroFrames()
    end

    local buildInstanceMenu = function()
        local instanceList = {}
        for index = 1, math.min (#Details.tabela_instancias, Details.instances_amount) do
            local instanceObject = Details.tabela_instancias[index]

            --what the window is showing
            local atributo = instanceObject.atributo
            local sub_atributo = instanceObject.sub_atributo

            if (atributo == 5) then --custom
                local CustomObject = Details.custom[sub_atributo]
                if (not CustomObject) then
                    instanceObject:ResetAttribute()
                    atributo = instanceObject.atributo
                    sub_atributo = instanceObject.sub_atributo
                    instanceList[#instanceList+1] = {value = index, label = "#".. index .. " " .. Details.atributos.lista[atributo] .. " - " .. Details.sub_atributos[atributo].lista[sub_atributo], onclick = onSelectInstance, icon = Details.sub_atributos[atributo].icones[sub_atributo][1], texcoord = Details.sub_atributos[atributo].icones[sub_atributo][2]}
                else
                    instanceList[#instanceList+1] = {value = index, label = "#".. index .. " " .. CustomObject.name, onclick = onSelectInstance, icon = CustomObject.icon}
                end
            else
                local modo = instanceObject.modo

                if (modo == 1) then --solo plugin
                    atributo = Details.SoloTables.Mode or 1
                    local SoloInfo = Details.SoloTables.Menu[atributo]
                    if (SoloInfo) then
                        instanceList[#instanceList+1] = {value = index, label = "#".. index .. " " .. SoloInfo[1], onclick = onSelectInstance, icon = SoloInfo [2]}
                    else
                        instanceList[#instanceList+1] = {value = index, label = "#".. index .. " unknown", onclick = onSelectInstance, icon = ""}
                    end

                elseif (modo == 4) then --raid plugin
                    local plugin_name = instanceObject.current_raid_plugin or instanceObject.last_raid_plugin
                    if (plugin_name) then
                        local plugin_object = Details:GetPlugin(plugin_name)
                        if (plugin_object) then
                            instanceList[#instanceList+1] = {value = index, label = "#".. index .. " " .. plugin_object.__name, onclick = onSelectInstance, icon = plugin_object.__icon}
                        else
                            instanceList[#instanceList+1] = {value = index, label = "#".. index .. " unknown", onclick = onSelectInstance, icon = ""}
                        end
                    else
                        instanceList[#instanceList+1] = {value = index, label = "#".. index .. " unknown", onclick = onSelectInstance, icon = ""}
                    end
                else
                    instanceList[#instanceList+1] = {value = index, label = "#".. index .. " " .. Details.atributos.lista[atributo] .. " - " .. Details.sub_atributos [atributo].lista [sub_atributo], onclick = onSelectInstance, icon = Details.sub_atributos [atributo].icones[sub_atributo] [1], texcoord = Details.sub_atributos [atributo].icones[sub_atributo] [2]}
                end
            end
        end
        return instanceList
    end

    local instanceSelection = detailsFramework:NewDropDown(optionsFrame, _, "$parentInstanceSelectDropdown", "instanceDropdown", 200, 18, buildInstanceMenu) --, nil, options_dropdown_template
    optionsFrame.instanceDropdown = instanceSelection
    instanceSelection:SetPoint("topright", optionsFrame, "topright", -7, -39)
    instanceSelection:SetTemplate(options_dropdown_template)
    instanceSelection:SetHook("OnEnter", function()
        GameCooltip:Reset()
        GameCooltip:Preset(2)
        GameCooltip:AddLine(Loc ["STRING_MINITUTORIAL_OPTIONS_PANEL1"])
        GameCooltip:ShowCooltip(instanceSelection.widget, "tooltip")
    end)
    instanceSelection:SetHook("OnLeave", function()
        GameCooltip:Hide()
    end)

    local formatFooterText = function(object)
        object.fontface = "GameFontNormal"
        object.fontsize = 10
        object.fontcolor = {1, 0.82, 0}
    end

    local instancesFontString = detailsFramework:NewLabel(optionsFrame, nil, "$parentInstanceDropdownLabel", "instancetext", Loc ["STRING_OPTIONS_EDITINSTANCE"], "GameFontNormal", 12)
    instancesFontString:SetPoint("right", instanceSelection, "left", -2, 1)
    formatFooterText(instancesFontString)

    local bigdogImage = detailsFramework:NewImage(optionsFrame, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]], 180*0.9, 200*0.9, nil, {1, 0, 0, 1}, "backgroundBigDog", "$parentBackgroundBigDog")
    bigdogImage:SetPoint("bottomright", optionsFrame, "bottomright", 0, 0)
    bigdogImage:SetAlpha(.25)

    --editing group checkbox
    local onToggleEditingGroup = function(self, fixparam, value)
        Details.options_group_edit = value
    end
    local editingGroupCheckBox = detailsFramework:CreateSwitch(optionsFrame, onToggleEditingGroup, Details.options_group_edit, _, _, _, _, _, "$parentEditGroupCheckbox", _, _, _, _, detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
    editingGroupCheckBox:SetAsCheckBox()
    editingGroupCheckBox.tooltip = Loc ["STRING_MINITUTORIAL_OPTIONS_PANEL2"]

    local editingGroupLabel = detailsFramework:NewLabel(optionsFrame, nil, "$parentEditingGroupLabel", "editingGroupLabel", "Editing Group:", "GameFontNormal", 12) --localize-me
    editingGroupLabel:SetPoint("bottomleft", instancesFontString, "topleft", 0, 5)
    editingGroupCheckBox:SetPoint("left", editingGroupLabel, "right", 2, 0)
    formatFooterText(editingGroupLabel)

	--create test bars ~test
        detailsFramework:NewColor("C_OptionsButtonOrange", 0.9999, 0.8196, 0, 1)
        local create_test_bars_func = function()
            Details.CreateTestBars()
            if (not Details.test_bar_update) then
                Details:StartTestBarUpdate()
            else
                Details:StopTestBarUpdate()
            end
        end

        local fillbars = detailsFramework:NewButton(optionsFrame, _, "$parentCreateExampleBarsButton", nil, 140, 20, create_test_bars_func, nil, nil, nil, Loc ["STRING_OPTIONS_TESTBARS"], 1)
        PixelUtil.SetPoint(fillbars, "topleft", optionsFrame.widget, "topleft", startX-8, -30)
        fillbars:SetTemplate(options_button_template)
        fillbars:SetIcon ("Interface\\AddOns\\Details\\images\\icons", nil, nil, nil, {323/512, 365/512, 42/512, 78/512}, {1, 1, 1, 0.6}, 4, 2)

    --change log
        local changelog = detailsFramework:NewButton(optionsFrame, _, "$parentOpenChangeLogButton", nil, 140, 20, Details.OpenNewsWindow, "change_log", nil, nil, Loc ["STRING_OPTIONS_CHANGELOG"], 1)
        changelog:SetPoint("left", fillbars, "right", 10, 0)
        changelog:SetTemplate(options_button_template)
        changelog:SetIcon ("Interface\\AddOns\\Details\\images\\icons", nil, nil, nil, {367/512, 399/512, 43/512, 76/512}, {1, 1, 1, 0.8}, 4, 2)

    --search field
        local searchBox = detailsFramework:CreateTextEntry(optionsFrame, function()end, 140, 20, _, _, _, options_dropdown_template)
        searchBox:SetPoint("left", changelog, "right", 10, 0)
        searchBox:SetAsSearchBox()

        searchBox:SetHook("OnChar", function()
            if (searchBox.text ~= "") then
                local searchSection = optionsFrame.sectionFramesContainer[19]
                searchSection.sectionButton:Enable()
                searchSection.sectionButton:Click()

                local searchingFor = searchBox.text
                local allSectionFrames = optionsFrame.sectionFramesContainer

                local allSectionNames = {}
                local allSectionOptions = {}

                for i = 1, #allSectionFrames do
                    local sectionFrame = allSectionFrames[i]
                    local sectionOptionsTable = sectionFrame.sectionOptions

                    allSectionNames[#allSectionNames+1] = sectionFrame.name
                    allSectionOptions[#allSectionOptions+1] = sectionOptionsTable
                end

                --this table will hold all options
                local allOptions = {}
                --start the fill process filling 'allOptions' with each individual option from each tab
                for i = 1, #allSectionOptions do
                    local sectionOptions = allSectionOptions[i]
                    local lastLabel = nil
                    for k, setting in pairs(sectionOptions) do
                        if (type(setting) == "table") then
                            if (setting.type == "label") then
                                lastLabel = setting
                            end
                            if (setting.name) then
                                allOptions[#allOptions+1] = {setting = setting, label = lastLabel, header = allSectionNames[i]}
                            end
                        end
                    end
                end

                local searchingText = string.lower(searchingFor)
                searchBox:SetFocus()

                local options = {}

                local lastTab = nil
                local lastLabel = nil
                for i = 1, #allOptions do
                    local optionData = allOptions[i]
                    local optionName = string.lower(optionData.setting.name)
                    if (optionName:find(searchingText)) then
                        if optionData.header ~= lastTab then
                            if lastTab ~= nil then
                                options[#options+1] = {type = "label", get = function() return "" end, text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")} -- blank
                            end
                            options[#options+1] = {type = "label", get = function() return optionData.header end, text_template = {color = "silver", size = 14, font = detailsFramework:GetBestFontForLanguage()}}
                            lastTab = optionData.header
                            lastLabel = nil
                        end
                        if optionData.label ~= lastLabel then
                            options[#options+1] = optionData.label
                            lastLabel = optionData.label
                        end
                        options[#options+1] = optionData.setting
                    end
                end

                local startX = 200
                local startY = -60

                detailsFramework:BuildMenuVolatile(searchSection, options, startX, startY, 560, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

            else
                optionsFrame.sectionFramesContainer[19].sectionButton:Disable()
            end
        end)

    local sectionsName = { --section names
        [1] = Loc ["STRING_OPTIONSMENU_DISPLAY"],
        [3] = Loc ["STRING_OPTIONSMENU_ROWSETTINGS"],
        [4] = Loc ["STRING_OPTIONSMENU_ROWTEXTS"],

        [5] = Loc ["STRING_OPTIONSMENU_TITLEBAR"], --titlebar
        [6] = Loc ["STRING_OPTIONSMENU_WINDOWBODY"], --window body
        [7] = Loc ["STRING_OPTIONS_INSTANCE_STATUSBAR_ANCHOR"], --statusbar
        [12] = Loc ["STRING_OPTIONSMENU_WALLPAPER"],
        [13] = Loc ["STRING_OPTIONSMENU_AUTOMATIC"],

        [9] = Loc ["STRING_OPTIONSMENU_PROFILES"],
        [2] = Loc ["STRING_OPTIONSMENU_SKIN"],
        [8] = Loc ["STRING_OPTIONSMENU_PLUGINS"],
        [10] = Loc ["STRING_OPTIONSMENU_TOOLTIP"],
        [11] = Loc ["STRING_OPTIONSMENU_DATAFEED"],

        [14] = Loc ["STRING_OPTIONSMENU_RAIDTOOLS"],
        [15] = "Broadcaster Tools",
        [16] = Loc ["STRING_OPTIONSMENU_SPELLS"],
        [17] = Loc ["STRING_OPTIONSMENU_DATACHART"],
        [18] = "Mythic Dungeon",
        [19] = "Search Results",
        [20] = "Combat Log",
    }

    local optionsSectionsOrder = {
        1, 20, "", 3, 4, "", 5, 6, 7, 12, 13, "", 9, 2, 8, 10, 11, 18, "", 14, 15, 16, 17, "", 19
    }

    local maxSectionIds = 0
    for k in pairs(sectionsName) do
        maxSectionIds = maxSectionIds + 1
    end

    Details222.OptionsPanel.maxSectionIds = maxSectionIds

    local buttonYPosition = -40

    function Details222.OptionsPanel.SelectOptionsSection(sectionId)
        for i = 1, maxSectionIds do
            optionsFrame.sectionFramesContainer[i]:Hide()
            if (optionsFrame.sectionFramesContainer[i].sectionButton) then
                optionsFrame.sectionFramesContainer[i].sectionButton:SetTemplate(options_button_template)
                optionsFrame.sectionFramesContainer[i].sectionButton:SetIcon({.4, .4, .4}, 4, section_menu_button_height -4, "overlay")
            end
        end

        optionsFrame.sectionFramesContainer[sectionId]:Show()
        if(optionsFrame.sectionFramesContainer[sectionId].RefreshOptions) then
            optionsFrame.sectionFramesContainer[sectionId]:RefreshOptions()
        end
        --hightlight the option button
        optionsFrame.sectionFramesContainer[sectionId].sectionButton:SetTemplate(options_button_template_selected)
        optionsFrame.sectionFramesContainer[sectionId].sectionButton:SetIcon({1, 1, 0}, 4, section_menu_button_height -4, "overlay")
    end

    Details222.OptionsPanel.SetCurrentInstance(instance)

    --create frames for sections
    for index, sectionId in ipairs(optionsSectionsOrder) do
        if (type(sectionId) == "number") then
            local sectionFrame = CreateFrame("frame", "$parentTab" .. sectionId, optionsFrame, "BackdropTemplate")
            sectionFrame:SetPoint("topleft", optionsFrame, "topleft", -40, 22)
            sectionFrame:SetSize(optionsFrame:GetSize())
            sectionFrame:EnableMouse(false)

            sectionFrame.name = sectionsName[sectionId]
            optionsFrame.sectionFramesContainer[sectionId] = sectionFrame

            local buildOptionSectionFunc = Details.optionsSection[sectionId]
            if (buildOptionSectionFunc) then
                --call the function to create the frame
                buildOptionSectionFunc(sectionFrame)

                --create a button for the section
                local sectionButton = detailsFramework:CreateButton(optionsFrame, function() Details222.OptionsPanel.SelectOptionsSection(sectionId) end, section_menu_button_width, section_menu_button_height, sectionsName[sectionId], sectionId, nil, nil, nil, "$parentButtonSection" .. sectionId, nil, options_button_template, options_text_template)
                sectionButton:SetIcon({.4, .4, .4}, 4, section_menu_button_height -4, "overlay")
                sectionButton:SetPoint("topleft", optionsFrame, "topleft", 10, buttonYPosition)
                buttonYPosition = buttonYPosition - (section_menu_button_height + 1)
                sectionFrame.sectionButton = sectionButton

                if (sectionId == 19) then --search results
                    sectionButton:Disable()

                elseif (sectionId == 1) then
                    sectionButton:SetIcon({1, 1, 0}, 4, section_menu_button_height -4, "overlay")
                end
            end
        else
            buttonYPosition = buttonYPosition - 15
        end
    end

    function Details222.OptionsPanel.GetOptionsSection(sectionId)
        return optionsFrame.sectionFramesContainer[sectionId]
    end

    function optionsFrame.RefreshWindow()
		if (not _G.DetailsOptionsWindow.instance) then
			local lowerInstance = Details:GetLowerInstanceNumber()
			if (not lowerInstance) then
				local instance = Details:GetInstance(1)
				Details.CriarInstancia(_, _, 1)
				Details:OpenOptionsWindow(instance)
			else
				Details:OpenOptionsWindow(Details:GetInstance(lowerInstance))
			end
		else
			Details:OpenOptionsWindow(_G.DetailsOptionsWindow.instance)
        end
    end

    Details222.OptionsPanel.SelectOptionsSection(1)
end

-- ~options
---open the options window
---@param instance instance
---@param bNoReopen boolean|nil
---@param section any
function Details:OpenOptionsWindow(instance, bNoReopen, section)
	if (not instance.GetId or not instance:GetId()) then
		instance, bNoReopen, section = unpack(instance)
    end

    if (not bNoReopen and not instance:IsEnabled() or not instance:IsStarted()) then
        Details:CreateInstance(instance:GetId())
	end

    GameCooltip:Close()

    local window = _G.DetailsOptionsWindow
    if (not window) then
        Details222.OptionsPanel.InitializeOptionsWindow(instance)
        window = _G.DetailsOptionsWindow
    end

    Details222.OptionsPanel.SetCurrentInstanceAndRefresh(instance)
    _G.DetailsPluginContainerWindow.OpenPlugin(_G.DetailsOptionsWindow)

    if (section) then
        Details222.OptionsPanel.SelectOptionsSection(section)
    end

    window.instanceDropdown:Refresh()
    window.instanceDropdown:Select(instance:GetId())

    window.updateMicroFrames()

    DetailsPluginContainerWindowMenuFrame:SetColor(unpack(Details.frame_background_color))
end

function Details:OpenOptionsPanel(instance, bNoReopen, section) --alias
    Details:OpenOptionsWindow(instance, bNoReopen, section)
end