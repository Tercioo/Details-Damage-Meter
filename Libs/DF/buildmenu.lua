
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local unpack = unpack
local C_Timer = C_Timer
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame
local PixelUtil = PixelUtil
local _

---@class df_menu_table : table
---@field text_template table
---@field id string an unique string or number to identify the button, from parent.widgetids[id], parent is the first argument of BuildMenu and BuildMenuVolatile
---@field namePhraseId string the phrase id (from language localization) to use on the button

---@class df_menu_label : df_menu_table
---@field get function
---@field color table
---@field font string
---@field size number
---@field text string

---@class df_menu_dropdown : df_menu_table
---@field type string
---@field set function
---@field get function
---@field values table
---@field name string
---@field desc string
---@field descPhraseId string
---@field hooks table

---@class df_menu_toggle : df_menu_table
---@field set function
---@field get function
---@field name string
---@field desc string
---@field descPhraseId string
---@field hooks table
---@field width number
---@field height number
---@field boxfirst boolean

---@class df_menu_range : df_menu_table
---@field set function
---@field get function
---@field min number
---@field max number
---@field step number
---@field name string
---@field desc string
---@field descPhraseId string
---@field hooks table
---@field thumbscale number
---@field usedecimals boolean if true allow fraction values

---@class df_menu_color : df_menu_table
---@field set function
---@field get function
---@field name string
---@field desc string
---@field descPhraseId string
---@field hooks table
---@field boxfirst boolean

---@class df_menu_button : df_menu_table
---@field func function the function to execute when the button is pressed
---@field param1 any the first parameter to pass to the function
---@field param2 any the second parameter to pass to the function
---@field name string text to show on the button
---@field desc string text to show on the tooltip
---@field descPhraseId string the phrase id (from language localization) to use on the tooltip
---@field hooks table a table with hooks to add to the button
---@field width number
---@field height number
---@field inline boolean
---@field icontexture any
---@field icontexcoords table

---@class df_menu_textentry : df_menu_table
---@field func function the function to execute when enter key is pressed
---@field set function same as above 'func'
---@field get function
---@field name string text to show on the button
---@field desc string text to show on the tooltip
---@field descPhraseId string the phrase id (from language localization) to use on the tooltip
---@field hooks table a table with hooks to add to the button
---@field inline boolean if true, the widget is placed in the rigt side of the previous one
---@field align string "left", "center" or "right"
---@field nocombat boolean can't edit when in combat
---@field spacement boolean gives a little of more space from the next widget

local onEnterHighlight = function(self)
    self.highlightTexture:Show()
    if (self.parent:GetScript("OnEnter")) then
        self.parent:GetScript("OnEnter")(self.parent)
    end
end

local onLeaveHighlight = function(self)
    self.highlightTexture:Hide()
    if (self.parent:GetScript("OnLeave")) then
        self.parent:GetScript("OnLeave")(self.parent)
    end
end

local createOptionHighlightTexture = function(frame, label, widgetWidth)
    frame = frame.widget or frame
    label = label.widget or label

    local highlightFrame = CreateFrame("frame", nil, frame)
    highlightFrame:EnableMouse(true)
    highlightFrame:SetFrameLevel(frame:GetFrameLevel()-1)

    PixelUtil.SetSize(highlightFrame, widgetWidth, frame:GetHeight() + 1)
    PixelUtil.SetPoint(highlightFrame, "topleft", label, "topleft", -2, 5)

    highlightFrame:SetScript("OnEnter", onEnterHighlight)
    highlightFrame:SetScript("OnLeave", onLeaveHighlight)

    local highlightTexture = highlightFrame:CreateTexture(nil, "overlay")
    highlightTexture:SetColorTexture(1, 1, 1, 0.1)
    PixelUtil.SetPoint(highlightTexture, "topleft", highlightFrame, "topleft", 0, 0)
    PixelUtil.SetPoint(highlightTexture, "bottomright", highlightFrame, "bottomright", 0, 0)
    highlightTexture:Hide()

    local backgroundTexture = highlightFrame:CreateTexture(nil, "artwork")
    backgroundTexture:SetColorTexture(1, 1, 1)
    backgroundTexture:SetVertexColor(.25, .25, .25, 0.5)
    PixelUtil.SetPoint(backgroundTexture, "topleft", highlightFrame, "topleft", 0, 0)
    PixelUtil.SetPoint(backgroundTexture, "bottomright", highlightFrame, "bottomright", 0, 0)

    highlightFrame.highlightTexture = highlightTexture
    highlightFrame.parent = frame

    return highlightTexture
end



local formatOptionNameWithColon = function(text, useColon)
    if (text) then
        if (useColon) then
            text = text .. ":"
            return text
        else
            return text
        end
    end
end

local widgetsToDisableOnCombat = {}

local getMenuWidgetVolative = function(parent, widgetType, indexTable)
    local widgetObject

    if (widgetType == "label") then
        widgetObject = parent.widget_list_by_type[widgetType][indexTable[widgetType]]
        if (not widgetObject) then
            widgetObject = detailsFramework:CreateLabel(parent, "", 10, "white", "", nil, "$parentWidget" .. widgetType .. indexTable[widgetType], "overlay")
            table.insert(parent.widget_list, widgetObject)
            table.insert(parent.widget_list_by_type[widgetType], widgetObject)
        end
        indexTable[widgetType] = indexTable[widgetType] + 1

    elseif (widgetType == "dropdown") then
        widgetObject = parent.widget_list_by_type[widgetType][indexTable[widgetType]]
        if (not widgetObject) then
            widgetObject = detailsFramework:CreateDropDown(parent, function() return {} end, nil, 120, 18, nil, "$parentWidget" .. widgetType .. indexTable[widgetType])
            widgetObject.hasLabel = detailsFramework:CreateLabel(parent, "", 10, "white", "", nil, "$parentWidget" .. widgetType .. indexTable[widgetType] .. "label", "overlay")
            table.insert(parent.widget_list, widgetObject)
            table.insert(parent.widget_list_by_type[widgetType], widgetObject)

        else
            widgetObject:ClearHooks()
            widgetObject.hasLabel.text = ""
        end
        indexTable[widgetType] = indexTable[widgetType] + 1

    elseif (widgetType == "switch") then
        widgetObject = parent.widget_list_by_type[widgetType][indexTable[widgetType]]
        if (not widgetObject) then
            widgetObject = detailsFramework:CreateSwitch(parent, nil, true, 20, 20, nil, nil, nil, "$parentWidget" .. widgetType .. indexTable[widgetType])
            widgetObject.hasLabel = detailsFramework:CreateLabel(parent, "", 10, "white", "", nil, "$parentWidget" .. widgetType .. indexTable[widgetType] .. "label", "overlay")

            table.insert(parent.widget_list, widgetObject)
            table.insert(parent.widget_list_by_type[widgetType], widgetObject)
        else
            widgetObject:ClearHooks()
        end
        indexTable[widgetType] = indexTable[widgetType] + 1

    elseif (widgetType == "slider") then
        widgetObject = parent.widget_list_by_type[widgetType][indexTable[widgetType]]
        if (not widgetObject) then
            widgetObject = detailsFramework:CreateSlider(parent, 120, 20, 1, 2, 1, 1, false, nil, "$parentWidget" .. widgetType .. indexTable[widgetType])
            widgetObject.hasLabel = detailsFramework:CreateLabel(parent, "", 10, "white", "", nil, "$parentWidget" .. widgetType .. indexTable[widgetType] .. "label", "overlay")

            table.insert(parent.widget_list, widgetObject)
            table.insert(parent.widget_list_by_type[widgetType], widgetObject)
        else
            widgetObject:ClearHooks()
        end
        indexTable[widgetType] = indexTable[widgetType] + 1

    elseif (widgetType == "color") then
        widgetObject = parent.widget_list_by_type[widgetType][indexTable[widgetType]]
        if (not widgetObject) then
            widgetObject = detailsFramework:CreateColorPickButton(parent, "$parentWidget" .. widgetType .. indexTable[widgetType], nil, function()end, 1)
            widgetObject.hasLabel = detailsFramework:CreateLabel(parent, "", 10, "white", "", nil, "$parentWidget" .. widgetType .. indexTable[widgetType] .. "label", "overlay")

            table.insert(parent.widget_list, widgetObject)
            table.insert(parent.widget_list_by_type[widgetType], widgetObject)
        else
            widgetObject:ClearHooks()
        end
        indexTable[widgetType] = indexTable[widgetType] + 1

    elseif (widgetType == "button") then
        widgetObject = parent.widget_list_by_type[widgetType][indexTable[widgetType]]
        if (not widgetObject) then
            widgetObject = detailsFramework:CreateButton(parent, function()end, 120, 18, "", nil, nil, nil, nil, "$parentWidget" .. widgetType .. indexTable[widgetType])
            widgetObject.hasLabel = detailsFramework:CreateLabel(parent, "", 10, "white", "", nil, "$parentWidget" .. widgetType .. indexTable[widgetType] .. "label", "overlay")

            table.insert(parent.widget_list, widgetObject)
            table.insert(parent.widget_list_by_type[widgetType], widgetObject)
        else
            widgetObject:ClearHooks()
        end
        indexTable[widgetType] = indexTable[widgetType] + 1

    elseif (widgetType == "textentry") then
        widgetObject = parent.widget_list_by_type[widgetType][indexTable[widgetType]]
        if (not widgetObject) then
            widgetObject = detailsFramework:CreateTextEntry(parent, function()end, 120, 18, nil, "$parentWidget" .. widgetType .. indexTable[widgetType])
            widgetObject.hasLabel = detailsFramework:CreateLabel(parent, "", 10, "white", "", nil, "$parentWidget" .. widgetType .. indexTable[widgetType] .. "label", "overlay")

            table.insert(parent.widget_list, widgetObject)
            table.insert(parent.widget_list_by_type[widgetType], widgetObject)
        else
            widgetObject:ClearHooks()
        end
        indexTable[widgetType] = indexTable[widgetType] + 1
    end

    --if the widget is inside the no combat table, remove it
    for i = 1, #widgetsToDisableOnCombat do
        if (widgetsToDisableOnCombat[i] == widgetObject) then
            table.remove(widgetsToDisableOnCombat, i)
            break
        end
    end

    return widgetObject
end

--get the description phrase from the language table or use the .desc or .deschraseid
local getDescPhraseText = function(languageTable, widgetTable)
    local descPhraseId = languageTable and (languageTable[widgetTable.descPhraseId] or languageTable[widgetTable.desc])
    return descPhraseId or widgetTable.descPhraseId or widgetTable.desc or widgetTable.name or "-?-"
end

local getNamePhraseID = function(widgetTable, languageAddonId, languageTable, bIgnoreEmbed)
    if (widgetTable.namePhraseId) then
        return widgetTable.namePhraseId
    end

    if (not languageTable) then
        return
    end

    local keyName = widgetTable.name

    if (widgetTable.type == "label" and widgetTable.get) then
        local key = widgetTable.get()
        if (key and type(key) == "string") then
            keyName = key
        end
    end

    --embed key is when the phraseId is inside a string surounded by @
    local embedPhraseId = keyName:match("@(.-)@")

    local hasValue = detailsFramework.Language.DoesPhraseIDExistsInDefaultLanguage(languageAddonId, embedPhraseId or keyName)
    if (not hasValue) then
        return
    end

    if (embedPhraseId and not bIgnoreEmbed) then
        return embedPhraseId, true
    else
        return keyName
    end
end

local getNamePhraseText = function(languageTable, widgetTable, useColon, languageAddonId)
    local namePhraseId, bWasEmbed = getNamePhraseID(widgetTable, languageAddonId, languageTable)
    local namePhrase = languageTable and (languageTable[namePhraseId] or languageTable[widgetTable.namePhraseId] or languageTable[widgetTable.name])

    if (bWasEmbed and widgetTable.name) then
        namePhrase = widgetTable.name:gsub("@" .. namePhraseId .. "@", namePhrase)
    end

    return namePhrase or formatOptionNameWithColon(widgetTable.name, useColon) or widgetTable.namePhraseId or widgetTable.name or "-?-"
end

--volatile menu can be called several times, each time all settings are reset and a new menu is built reusing the widgets
function detailsFramework:BuildMenuVolatile(parent, menuOptions, xOffset, yOffset, height, useColon, textTemplate, dropdownTemplate, switchTemplate, switchIsCheckbox, sliderTemplate, buttonTemplate, valueChangeHook)
    if (not parent.widget_list) then
        detailsFramework:SetAsOptionsPanel(parent)
    end
    detailsFramework:ClearOptionsPanel(parent)

    local currentXOffset = xOffset or 0
    local currentYOffset = yOffset or 0
    local maxColumnWidth = 0

    local latestInlineWidget

    local widgetIndexes = {
        label = 1,
        dropdown = 1,
        switch = 1,
        slider = 1,
        color = 1,
        button = 1,
        textentry = 1,
    }

    if (height and type(height) == "number") then
        height = math.abs((height or parent:GetHeight()) - math.abs(yOffset) + 20)
        height = height * -1
    else
        height = parent:GetHeight()
    end

    --normalize format types
    for index, widgetTable in ipairs(menuOptions) do
        if (widgetTable.type == "space") then
            widgetTable.type = "blank"

        elseif (widgetTable.type == "fontdropdown") then
            widgetTable.type = "selectfont"
        elseif (widgetTable.type == "colordropdown") then
            widgetTable.type = "selectcolor"
        elseif (widgetTable.type == "outlinedropdown") then
            widgetTable.type = "selectoutline"
        elseif (widgetTable.type == "anchordropdown") then
            widgetTable.type = "selectanchor"
        elseif (widgetTable.type == "dropdown") then
            widgetTable.type = "select"

        elseif (widgetTable.type == "switch") then
            widgetTable.type = "toggle"

        elseif (widgetTable.type == "slider") then
            widgetTable.type = "range"

        elseif (widgetTable.type == "button") then
            widgetTable.type = "execute"
        end
    end

    --catch some options added in the hash part of the menu table
    local bUseBoxFirstOnAllWidgets = menuOptions.always_boxfirst
    local bAlignAsPairs = menuOptions.align_as_pairs
    local nAlignAsPairsLength = menuOptions.align_as_pairs_string_space or 160
    local languageAddonId = menuOptions.language_addonId
    local widgetWidth = menuOptions.widget_width
    local widgetHeight = menuOptions.widget_height
    local languageTable

    if (languageAddonId) then
        languageTable = DetailsFramework.Language.GetLanguageTable(languageAddonId)
    end

    for index, widgetTable in ipairs(menuOptions) do
        if (not widgetTable.hidden) then
            local widgetCreated
            if (latestInlineWidget) then
                if (not widgetTable.inline) then
                    latestInlineWidget = nil
                    currentYOffset = currentYOffset - 20
                end
            end

            local extraPaddingY = 0

            if (not widgetTable.novolatile) then
                --step a line
                if (widgetTable.type == "blank" or widgetTable.type == "space") then
                    --do nothing

                elseif (widgetTable.type == "label" or widgetTable.type == "text") then
                    local label = getMenuWidgetVolative(parent, "label", widgetIndexes)
                    widgetCreated = label

                    local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable)
                    local namePhrase = (languageTable and (languageTable[namePhraseId] or languageTable[widgetTable.namePhraseId] or languageTable[widgetTable.name])) or (widgetTable.get and widgetTable.get()) or widgetTable.text or (widgetTable.namePhraseId) or ""
                    label.text = namePhrase
                    label.color = widgetTable.color

                    if (widgetTable.font) then
                        label.fontface = widgetTable.font
                    end

                    if (widgetTable.text_template or textTemplate) then
                        label:SetTemplate(widgetTable.text_template or textTemplate)
                    else
                        label.fontsize = widgetTable.size or 10
                    end

                    label._get = widgetTable.get
                    label.widget_type = "label"
                    label:ClearAllPoints()
                    label:SetPoint(currentXOffset, currentYOffset)

                    if (widgetTable.id) then
                        parent.widgetids [widgetTable.id] = label
                    end

                --dropdowns
                elseif (widgetTable.type:find("select")) then
                    assert(widgetTable.get, "DetailsFramework:BuildMenu(): .get() not found in the widget table for 'select'")
                    local dropdown = getMenuWidgetVolative(parent, "dropdown", widgetIndexes)
                    widgetCreated = dropdown

                    if (widgetTable.type == "selectfont") then
                        local func = detailsFramework:CreateFontListGenerator(widgetTable.set)
                        dropdown:SetFunction(func)

                    elseif (widgetTable.type == "selectcolor") then
                        local func = detailsFramework:CreateColorListGenerator(widgetTable.set)
                        dropdown:SetFunction(func)

                    elseif (widgetTable.type == "selectanchor") then
                        local func = detailsFramework:CreateAnchorPointListGenerator(widgetTable.set)
                        dropdown:SetFunction(func)

                    elseif (widgetTable.type == "selectoutline") then
                        local func = detailsFramework:CreateOutlineListGenerator(widgetTable.set)
                        dropdown:SetFunction(func)
                    else
                        dropdown:SetFunction(widgetTable.values)
                    end

                    dropdown:Refresh()
                    dropdown:Select(widgetTable.get())
                    dropdown:SetTemplate(dropdownTemplate)

                    if (widgetWidth) then
                        dropdown:SetWidth(widgetWidth)
                    end
                    if (widgetHeight) then
                        dropdown:SetHeight(widgetHeight)
                    end

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    dropdown:SetTooltip(descPhrase)
                    dropdown._get = widgetTable.get
                    dropdown.widget_type = "select"

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    dropdown.hasLabel.text = namePhrase

                    dropdown.hasLabel:SetTemplate(widgetTable.text_template or textTemplate)

                    --as these are reused widgets, clean the previous point
                    dropdown:ClearAllPoints()
                    dropdown.hasLabel:ClearAllPoints()

                    if (bAlignAsPairs) then
                        dropdown.hasLabel:SetPoint(currentXOffset, currentYOffset)
                        dropdown:SetPoint("left", dropdown.hasLabel, "left", nAlignAsPairsLength, 0)
                    else
                        dropdown:SetPoint("left", dropdown.hasLabel, "right", 2, 0)
                        dropdown.hasLabel:SetPoint(currentXOffset, currentYOffset)
                    end

                    --global callback
                    if (valueChangeHook) then
                        dropdown:SetHook("OnOptionSelected", valueChangeHook)
                    end

                    --hook list (hook list is wiped when getting the widget)
                    if (widgetTable.hooks) then
                        for hookName, hookFunc in pairs(widgetTable.hooks) do
                            dropdown:SetHook(hookName, hookFunc)
                        end
                    end

                    if (widgetTable.id) then
                        parent.widgetids[widgetTable.id] = dropdown
                    end

                    local widgetTotalSize = dropdown.hasLabel.widget:GetStringWidth() + 140 + 4
                    if (widgetTotalSize > maxColumnWidth) then
                        maxColumnWidth = widgetTotalSize
                    end

                --switchs
                elseif (widgetTable.type == "toggle" or widgetTable.type == "switch") then
                    local switch = getMenuWidgetVolative(parent, "switch", widgetIndexes)
                    widgetCreated = switch

                    switch:SetValue(widgetTable.get())
                    switch:SetTemplate(switchTemplate)
                    switch:SetAsCheckBox() --it's always a checkbox on volatile menu

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    switch:SetTooltip(descPhrase)
                    switch._get = widgetTable.get
                    switch.widget_type = "toggle"
                    switch.OnSwitch = widgetTable.set

                    if (valueChangeHook) then
                        switch:SetHook("OnSwitch", valueChangeHook)
                    end

                    --hook list
                    if (widgetTable.hooks) then
                        for hookName, hookFunc in pairs(widgetTable.hooks) do
                            switch:SetHook(hookName, hookFunc)
                        end
                    end

                    if (widgetTable.width) then
                        switch:SetWidth(widgetTable.width)
                    end
                    if (widgetTable.height) then
                        switch:SetHeight(widgetTable.height)
                    end

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    switch.hasLabel.text = namePhrase
                    switch.hasLabel:SetTemplate(widgetTable.text_template or textTemplate)

                    switch:ClearAllPoints()
                    switch.hasLabel:ClearAllPoints()

                    if (bAlignAsPairs) then
                        switch.hasLabel:SetPoint(currentXOffset, currentYOffset)
                        switch:SetPoint("left", switch.hasLabel, "left", nAlignAsPairsLength, 0)
                    else
                        if (widgetTable.boxfirst or bUseBoxFirstOnAllWidgets) then
                            switch:SetPoint(currentXOffset, currentYOffset)
                            switch.hasLabel:SetPoint("left", switch, "right", 2)

                            local nextWidgetTable = menuOptions[index+1]
                            if (nextWidgetTable) then
                                if (nextWidgetTable.type ~= "blank" and nextWidgetTable.type ~= "breakline" and nextWidgetTable.type ~= "toggle" and nextWidgetTable.type ~= "color") then
                                    extraPaddingY = 4
                                end
                            end
                        else
                            switch.hasLabel:SetPoint(currentXOffset, currentYOffset)
                            switch:SetPoint("left", switch.hasLabel, "right", 2)
                        end
                    end

                    if (widgetTable.id) then
                        parent.widgetids [widgetTable.id] = switch
                    end

                    local widgetTotalSize = switch.hasLabel:GetStringWidth() + 32
                    if (widgetTotalSize > maxColumnWidth) then
                        maxColumnWidth = widgetTotalSize
                    end

                --slider
                elseif (widgetTable.type == "range" or widgetTable.type == "slider") then
                    local slider = getMenuWidgetVolative(parent, "slider", widgetIndexes)
                    widgetCreated = slider

                    if (widgetTable.usedecimals) then
                        slider.slider:SetValueStep(0.01)
                    else
                        slider.slider:SetValueStep(widgetTable.step or 1)
                    end
                    slider.useDecimals = widgetTable.usedecimals

                    slider.slider:SetMinMaxValues(widgetTable.min, widgetTable.max)
                    slider.slider:SetValue(widgetTable.get())
                    slider.ivalue = slider.slider:GetValue()

                    slider:SetTemplate(sliderTemplate)

                    if (widgetWidth) then
                        slider:SetWidth(widgetWidth)
                    end
                    if (widgetHeight) then
                        slider:SetHeight(widgetHeight)
                    end

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    slider:SetTooltip(descPhrase)
                    slider._get = widgetTable.get
                    slider.widget_type = "range"
                    slider:SetHook("OnValueChange", widgetTable.set)

                    if (valueChangeHook) then
                        slider:SetHook("OnValueChange", valueChangeHook)
                    end

                    if (widgetTable.thumbscale) then
                        slider:SetThumbSize (slider.thumb.originalWidth * widgetTable.thumbscale, nil)
                    else
                        slider:SetThumbSize (slider.thumb.originalWidth * 1.3, nil)
                    end

                    --hook list
                    if (widgetTable.hooks) then
                        for hookName, hookFunc in pairs(widgetTable.hooks) do
                            slider:SetHook(hookName, hookFunc)
                        end
                    end

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    slider.hasLabel.text = namePhrase
                    slider.hasLabel:SetTemplate(widgetTable.text_template or textTemplate)

                    slider:ClearAllPoints()
                    slider.hasLabel:ClearAllPoints()

                    if (bAlignAsPairs) then
                        slider.hasLabel:SetPoint(currentXOffset, currentYOffset)
                        slider:SetPoint("left", slider.hasLabel, "left", nAlignAsPairsLength, 0)
                    else
                        slider:SetPoint("left", slider.hasLabel, "right", 2)
                        slider.hasLabel:SetPoint(currentXOffset, currentYOffset)
                    end

                    if (widgetTable.id) then
                        parent.widgetids[widgetTable.id] = slider
                    end

                    local widgetTotalSize = slider.hasLabel:GetStringWidth() + 146
                    if (widgetTotalSize > maxColumnWidth) then
                        maxColumnWidth = widgetTotalSize
                    end

                --color
                elseif (widgetTable.type == "color" or widgetTable.type == "color") then
                    local colorpick = getMenuWidgetVolative(parent, "color", widgetIndexes)
                    widgetCreated = colorpick

                    colorpick.color_callback = widgetTable.set --callback
                    colorpick:SetTemplate(buttonTemplate)
                    colorpick:SetSize(18, 18)

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    colorpick:SetTooltip(descPhrase)
                    colorpick._get = widgetTable.get
                    colorpick.widget_type = "color"

                    local default_value, g, b, a = widgetTable.get()
                    if (type(default_value) == "table") then
                        colorpick:SetColor(unpack(default_value))
                    else
                        colorpick:SetColor(default_value, g, b, a)
                    end

                    if (valueChangeHook) then
                        colorpick:SetHook("OnColorChanged", valueChangeHook)
                    end

                    --hook list
                    if (widgetTable.hooks) then
                        for hookName, hookFunc in pairs(widgetTable.hooks) do
                            colorpick:SetHook(hookName, hookFunc)
                        end
                    end

                    local label = colorpick.hasLabel

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    label.text = namePhrase
                    label:SetTemplate(widgetTable.text_template or textTemplate)

                    label:ClearAllPoints()
                    colorpick:ClearAllPoints()

                    if (bAlignAsPairs) then
                        label:SetPoint(currentXOffset, currentYOffset)
                        colorpick:SetPoint("left", label, "left", nAlignAsPairsLength, 0)
                    else
                        if (widgetTable.boxfirst or bUseBoxFirstOnAllWidgets) then
                            label:SetPoint("left", colorpick, "right", 2, 0)
                            colorpick:SetPoint(currentXOffset, currentYOffset)
                            extraPaddingY = 1
                        else
                            colorpick:SetPoint("left", label, "right", 2, 0)
                            label:SetPoint(currentXOffset, currentYOffset)
                        end
                    end

                    if (widgetTable.id) then
                        parent.widgetids[widgetTable.id] = colorpick
                    end

                    local widgetTotalSize = label:GetStringWidth() + 32
                    if (widgetTotalSize > maxColumnWidth) then
                        maxColumnWidth = widgetTotalSize
                    end

                --button
                elseif (widgetTable.type == "execute" or widgetTable.type == "button") then
                    local button = getMenuWidgetVolative(parent, "button", widgetIndexes)
                    widgetCreated = button

                    button:SetTemplate(buttonTemplate)
                    button:SetSize(widgetWidth or widgetTable.width or 120, widgetHeight or widgetTable.height or 18)
                    button:SetClickFunction(widgetTable.func, widgetTable.param1, widgetTable.param2)

                    local textTemplate = widgetTable.text_template or textTemplate or detailsFramework.font_templates["ORANGE_FONT_TEMPLATE"]
                    button.textcolor = textTemplate.color
                    button.textfont = textTemplate.font
                    button.textsize = textTemplate.size

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    button.text = namePhrase

                    button:ClearAllPoints()

                    if (bAlignAsPairs) then
                        button:SetPoint(currentXOffset, currentYOffset)
                    else
                        if (widgetTable.inline) then
                            if (latestInlineWidget) then
                                button:SetPoint("left", latestInlineWidget, "right", 2, 0)
                                latestInlineWidget = button
                            else
                                button:SetPoint(currentXOffset, currentYOffset)
                                latestInlineWidget = button
                            end
                        else
                            button:SetPoint(currentXOffset, currentYOffset)
                        end
                    end

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    button:SetTooltip(descPhrase)
                    button.widget_type = "execute"

                    --hook list
                    if (widgetTable.hooks) then
                        for hookName, hookFunc in pairs(widgetTable.hooks) do
                            button:SetHook(hookName, hookFunc)
                        end
                    end

                    if (widgetTable.width) then
                        button:SetWidth(widgetTable.width)
                    end
                    if (widgetTable.height) then
                        button:SetHeight(widgetTable.height)
                    end

                    if (widgetTable.id) then
                        parent.widgetids[widgetTable.id] = button
                    end

                    local widgetTotalSize = button:GetWidth() + 4
                    if (widgetTotalSize > maxColumnWidth) then
                        maxColumnWidth = widgetTotalSize
                    end

                --textentry
                elseif (widgetTable.type == "textentry") then
                    local textentry = getMenuWidgetVolative(parent, "textentry", widgetIndexes)
                    widgetCreated = textentry

                    textentry:SetCommitFunction(widgetTable.func or widgetTable.set)
                    textentry:SetTemplate(widgetTable.template or widgetTable.button_template or buttonTemplate)
                    textentry:SetSize(widgetWidth or widgetTable.width or 120, widgetHeight or widgetTable.height or 18)

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    textentry:SetTooltip(descPhrase)
                    textentry.text = widgetTable.get()
                    textentry._get = widgetTable.get
                    textentry.widget_type = "textentry"

                    textentry:SetHook("OnEnterPressed", function(...)
                        local upFunc = widgetTable.func or widgetTable.set
                        upFunc(...)
                        if (valueChangeHook) then
                            valueChangeHook()
                        end
                    end)
                    textentry:SetHook("OnEditFocusLost", function(...)
                        local upFunc = widgetTable.func or widgetTable.set
                        upFunc(...)
                        if (valueChangeHook) then
                            valueChangeHook()
                        end
                    end)

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    textentry.hasLabel.text = namePhrase
                    textentry.hasLabel:SetTemplate(widgetTable.text_template or textTemplate)

                    textentry.hasLabel:ClearAllPoints()
                    textentry:ClearAllPoints()

                    if (bAlignAsPairs) then
                        textentry.hasLabel:SetPoint(currentXOffset, currentYOffset)
                        textentry:SetPoint("left", textentry.hasLabel, "left", nAlignAsPairsLength, 0)
                    else
                        textentry:SetPoint("left", textentry.hasLabel, "right", 2)
                        textentry.hasLabel:SetPoint(currentXOffset, currentYOffset)
                    end

                    --hook list
                    if (widgetTable.hooks) then
                        for hookName, hookFunc in pairs(widgetTable.hooks) do
                            textentry:SetHook(hookName, hookFunc)
                        end
                    end

                    if (widgetTable.id) then
                        parent.widgetids[widgetTable.id] = textentry
                    end

                    local widgetTotalSize = textentry.hasLabel:GetStringWidth() + 64
                    if (widgetTotalSize > maxColumnWidth) then
                        maxColumnWidth = widgetTotalSize
                    end

                end --end loop

                if (widgetTable.nocombat) then
                    table.insert(widgetsToDisableOnCombat, widgetCreated)
                end

                if (not widgetTable.inline) then
                    if (widgetTable.spacement) then
                        currentYOffset = currentYOffset - 30
                    else
                        currentYOffset = currentYOffset - 20
                    end
                end

                if (extraPaddingY > 0) then
                    currentYOffset = currentYOffset - extraPaddingY
                end

                if (widgetTable.type == "breakline" or currentYOffset < height) then
                    currentYOffset = yOffset
                    currentXOffset = currentXOffset + maxColumnWidth + 20
                    maxColumnWidth = 0
                end

                if widgetCreated then
                    widgetCreated:Show()
                end
            end
        end
    end

    detailsFramework.RefreshUnsafeOptionsWidgets()
end

local getDescripttionPhraseID = function(widgetTable, languageAddonId, languageTable)
    if (widgetTable.descPhraseId) then
        return widgetTable.descPhraseId
    end

    if (not languageTable) then
        return
    end

    local hasValue = detailsFramework.Language.DoesPhraseIDExistsInDefaultLanguage(languageAddonId, widgetTable.desc)
    if (not hasValue) then
        return
    end

    return widgetTable.desc
end

	---classes used by the menu builder on the menuOptions table on both functions BuildMenu and BuildMenuVolatile
	---the menuOptions consists of a table with several tables inside in array, each table is a widget to be created
	---class df_menu_label is used when the sub table of menuOptions has a key named "type" with the value "label" or "text"
	function detailsFramework:BuildMenu(parent, menuOptions, xOffset, yOffset, height, useColon, textTemplate, dropdownTemplate, switchTemplate, switchIsCheckbox, sliderTemplate, buttonTemplate, valueChangeHook)
		--how many widgets has been created on this line loop pass
		local amountLineWidgetCreated = 0
		local latestInlineWidget

		--normalize format types
		for index, widgetTable in ipairs(menuOptions) do
			if (widgetTable.type == "space") then
				widgetTable.type = "blank"

			elseif (widgetTable.type == "fontdropdown") then
				widgetTable.type = "selectfont"
			elseif (widgetTable.type == "colordropdown") then
				widgetTable.type = "selectcolor"
			elseif (widgetTable.type == "outlinedropdown") then
				widgetTable.type = "selectoutline"
			elseif (widgetTable.type == "anchordropdown") then
				widgetTable.type = "selectanchor"
			elseif (widgetTable.type == "dropdown") then
				widgetTable.type = "select"

			elseif (widgetTable.type == "switch") then
				widgetTable.type = "toggle"

			elseif (widgetTable.type == "slider") then
				widgetTable.type = "range"

			elseif (widgetTable.type == "button") then
				widgetTable.type = "execute"
			end
		end

		--catch some options added in the hash part of the menu table
		local bUseBoxFirstOnAllWidgets = menuOptions.always_boxfirst
        local widgetWidth = menuOptions.widget_width --a width to be used on all widgets
        local widgetHeight = menuOptions.widget_height --a height to be used on all widgets
        local bAlignAsPairs = menuOptions.align_as_pairs
        local nAlignAsPairsLength = menuOptions.align_as_pairs_string_space or 160
        local nAlignAsPairsSpacing = menuOptions.align_as_pairs_spacing or 20

        --if a scrollbox is passed, the height can be ignored
        --the scrollBox child will be used as the parent, and the height of the child will be resized to fit the widgets
        local bUseScrollFrame = menuOptions.use_scrollframe
        local biggestColumnHeight = 0 --used to resize the scrollbox child when a scrollbox is passed

        if (not bUseScrollFrame) then
            if (height and type(height) == "number") then
                height = math.abs((height or parent:GetHeight()) - math.abs(yOffset) + 20)
                height = height * -1
            else
                height = parent:GetHeight()
            end
        else
            local width, height = parent:GetSize()
            parent = parent:GetScrollChild()
            parent:SetSize(width, height)
        end

		local languageAddonId = menuOptions.language_addonId
		local languageTable

		if (languageAddonId) then
			languageTable = DetailsFramework.Language.GetLanguageTable(languageAddonId)
		end

		if (not parent.widget_list) then
			detailsFramework:SetAsOptionsPanel(parent)
		end

        local currentXOffset = xOffset or 0
        local currentYOffset = yOffset or 0
        local maxColumnWidth = 0 --biggest width of widget + text size on the current column loop pass
        local maxWidgetWidth = 0 --biggest widget width on the current column loop pass
        local maxWidth = parent:GetWidth() --total width the buildmenu can use - not in use

		for index, widgetTable in ipairs(menuOptions) do
			if (not widgetTable.hidden) then
				local widgetCreated
				if (latestInlineWidget) then
					if (not widgetTable.inline) then
						latestInlineWidget = nil
						currentYOffset = currentYOffset - 28
					end
				end

				local extraPaddingY = 0

				if (widgetTable.type == "blank") then
					--do nothing

				elseif (widgetTable.type == "label" or widgetTable.type == "text") then
					---@cast widgetTable df_menu_label

					local label = detailsFramework:CreateLabel(parent, "", widgetTable.text_template or textTemplate or widgetTable.size, widgetTable.color, widgetTable.font, nil, "$parentWidget" .. index, "overlay")
					label._get = widgetTable.get
					label.widget_type = "label"
					label:SetPoint(currentXOffset, currentYOffset)

					local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable)
					if (namePhraseId) then
						DetailsFramework.Language.RegisterObject(languageAddonId, label.widget, namePhraseId)
						label.languageAddonId = languageAddonId
					else
						local textToSet = (widgetTable.get and widgetTable.get()) or widgetTable.text or ""
						label:SetText(textToSet)
					end

					--store the widget created into the overall table and the widget by type
					table.insert(parent.widget_list, label)
					table.insert(parent.widget_list_by_type.label, label)

					amountLineWidgetCreated = amountLineWidgetCreated + 1

					if (widgetTable.id) then
						parent.widgetids[widgetTable.id] = label
					end

				elseif (widgetTable.type:find("select")) then
					---@cast widgetTable df_menu_dropdown

					assert(widgetTable.get, "DetailsFramework:BuildMenu(): .get not found in the widget table for 'select'")

                    local defaultHeight = 18

					local dropdown
					if (widgetTable.type == "selectfont") then
						dropdown = detailsFramework:CreateFontDropDown(parent, widgetTable.set, widgetTable.get(), widgetWidth or 140, widgetHeight or defaultHeight, nil, "$parentWidget" .. index, dropdownTemplate)

					elseif (widgetTable.type == "selectcolor") then
                        dropdown = detailsFramework:CreateColorDropDown(parent, widgetTable.set, widgetTable.get(), widgetWidth or 140, widgetHeight or defaultHeight, nil, "$parentWidget" .. index, dropdownTemplate)

					elseif (widgetTable.type == "selectanchor") then
						dropdown = detailsFramework:CreateAnchorPointDropDown(parent, widgetTable.set, widgetTable.get(), widgetWidth or 140, widgetHeight or defaultHeight, nil, "$parentWidget" .. index, dropdownTemplate)

					elseif (widgetTable.type == "selectoutline") then
						dropdown = detailsFramework:CreateOutlineDropDown(parent, widgetTable.set, widgetTable.get(), widgetWidth or 140, widgetHeight or defaultHeight, nil, "$parentWidget" .. index, dropdownTemplate)
					else
						dropdown = detailsFramework:NewDropDown(parent, nil, "$parentWidget" .. index, nil, widgetWidth or 140, widgetHeight or defaultHeight, widgetTable.values, widgetTable.get(), dropdownTemplate)
					end

					local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
					DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, dropdown, "have_tooltip", descPhraseId, widgetTable.desc)

					dropdown._get = widgetTable.get
					dropdown.widget_type = "select"

					local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
					local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
					DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

					dropdown.addonId = languageAddonId
					if (languageAddonId) then
						detailsFramework.Language.RegisterCallback(languageAddonId, function(addonId, languageId, ...) dropdown:Select(dropdown:GetValue()) end)
						C_Timer.After(0.1, function() dropdown:Select(dropdown:GetValue()) end)
					end

                    if (bAlignAsPairs) then
                        PixelUtil.SetPoint(label.widget, "topleft", dropdown:GetParent(), "topleft", currentXOffset, currentYOffset)
                        PixelUtil.SetPoint(dropdown.widget, "left", label.widget, "left", nAlignAsPairsLength, 0)
                        createOptionHighlightTexture(dropdown, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
                    else
                        dropdown:SetPoint("left", label, "right", 2, 0)
                        label:SetPoint(currentXOffset, currentYOffset)
                    end

					dropdown.hasLabel = label

					--global callback
					if (valueChangeHook) then
						dropdown:SetHook("OnOptionSelected", valueChangeHook)
					end

					--hook list
					if (widgetTable.hooks) then
						for hookName, hookFunc in pairs(widgetTable.hooks) do
							dropdown:SetHook(hookName, hookFunc)
						end
					end

					if (widgetTable.id) then
						parent.widgetids[widgetTable.id] = dropdown
					end

					local widgetTotalSize = label.widget:GetStringWidth() + 144
					if (widgetTotalSize > maxColumnWidth) then
						maxColumnWidth = widgetTotalSize
					end

                    if (dropdown:GetWidth() > maxWidgetWidth) then
                        maxWidgetWidth = dropdown:GetWidth()
                    end

					--store the widget created into the overall table and the widget by type
					table.insert(parent.widget_list, dropdown)
					table.insert(parent.widget_list_by_type.dropdown, dropdown)

					widgetCreated = dropdown
					amountLineWidgetCreated = amountLineWidgetCreated + 1

				elseif (widgetTable.type == "toggle") then
					---@cast widgetTable df_menu_toggle

					local switch = detailsFramework:NewSwitch(parent, nil, "$parentWidget" .. index, nil, 60, 20, nil, nil, widgetTable.get(), nil, nil, nil, nil, switchTemplate)

					local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
					DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, switch, "have_tooltip", descPhraseId, widgetTable.desc)

					switch._get = widgetTable.get
					switch.widget_type = "toggle"
					switch.OnSwitch = widgetTable.set

					if (switchIsCheckbox) then
						switch:SetAsCheckBox()
					end

					if (valueChangeHook) then
						switch:SetHook("OnSwitch", valueChangeHook)
					end

					--hook list
					if (widgetTable.hooks) then
						for hookName, hookFunc in pairs(widgetTable.hooks) do
							switch:SetHook(hookName, hookFunc)
						end
					end

					if (widgetTable.width) then
                        PixelUtil.SetWidth(switch.widget, widgetTable.width)
					end
					if (widgetTable.height) then
                        PixelUtil.SetHeight(switch.widget, widgetTable.height)
					end

					local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)

					local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
					DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

                    if (bAlignAsPairs) then
                        PixelUtil.SetPoint(label.widget, "topleft", switch:GetParent(), "topleft", currentXOffset, currentYOffset)
                        PixelUtil.SetPoint(switch.widget, "left", label.widget, "left", nAlignAsPairsLength, 0)
                        createOptionHighlightTexture(switch, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
                    else
                        if (widgetTable.boxfirst or bUseBoxFirstOnAllWidgets) then
                            switch:SetPoint(currentXOffset, currentYOffset)
                            label:SetPoint("left", switch, "right", 2)

                            local nextWidgetTable = menuOptions[index+1]
                            if (nextWidgetTable) then
                                if (nextWidgetTable.type ~= "blank" and nextWidgetTable.type ~= "breakline" and nextWidgetTable.type ~= "toggle" and nextWidgetTable.type ~= "color") then
                                    extraPaddingY = 4
                                end
                            end
                        else
                            label:SetPoint(currentXOffset, currentYOffset)
                            switch:SetPoint("left", label, "right", 2, 0)
                        end
                    end
					switch.hasLabel = label

					if (widgetTable.id) then
						parent.widgetids[widgetTable.id] = switch
					end

					local widgetTotalSize = label.widget:GetStringWidth() + 32
					if (widgetTotalSize > maxColumnWidth) then
						maxColumnWidth = widgetTotalSize
					end

                    if (switch:GetWidth() > maxWidgetWidth) then
                        maxWidgetWidth = switch:GetWidth()
                    end

					--store the widget created into the overall table and the widget by type
					table.insert(parent.widget_list, switch)
					table.insert(parent.widget_list_by_type.switch, switch)

					widgetCreated = switch
					amountLineWidgetCreated = amountLineWidgetCreated + 1

				elseif (widgetTable.type == "range") then
					---@cast widgetTable df_menu_range

					assert(widgetTable.get, "DetailsFramework:BuildMenu(): .get not found in the widget table for 'range'")
					local bIsDecimals = widgetTable.usedecimals
					local slider = detailsFramework:NewSlider(parent, nil, "$parentWidget" .. index, nil, widgetWidth or 140, widgetHeight or 18, widgetTable.min, widgetTable.max, widgetTable.step, widgetTable.get(),  bIsDecimals, nil, nil, sliderTemplate)

					local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
					DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, slider, "have_tooltip", descPhraseId, widgetTable.desc)

					slider._get = widgetTable.get
					slider.widget_type = "range"
					slider:SetHook("OnValueChange", widgetTable.set)

					if (widgetTable.thumbscale) then
						slider:SetThumbSize(slider.thumb:GetWidth() * widgetTable.thumbscale, nil)
					else
						slider:SetThumbSize(slider.thumb:GetWidth() * 1.3, nil)
					end

					if (valueChangeHook) then
						slider:SetHook("OnValueChange", valueChangeHook)
					end

					--hook list
					if (widgetTable.hooks) then
						for hookName, hookFunc in pairs(widgetTable.hooks) do
							slider:SetHook(hookName, hookFunc)
						end
					end

					local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
					local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
					DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

                    if (bAlignAsPairs) then
                        PixelUtil.SetPoint(label.widget, "topleft", slider:GetParent(), "topleft", currentXOffset, currentYOffset)
                        PixelUtil.SetPoint(slider.widget, "left", label.widget, "left", nAlignAsPairsLength, 0)
                        createOptionHighlightTexture(slider, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
                    else
					    slider:SetPoint("left", label, "right", 2)
					    label:SetPoint(currentXOffset, currentYOffset)
                    end
					slider.hasLabel = label

					if (widgetTable.id) then
						parent.widgetids[widgetTable.id] = slider
					end

					local widgetTotalSize = label.widget:GetStringWidth() + 146
					if (widgetTotalSize > maxColumnWidth) then
						maxColumnWidth = widgetTotalSize
					end

                    if (slider:GetWidth() > maxWidgetWidth) then
                        maxWidgetWidth = slider:GetWidth()
                    end

					--store the widget created into the overall table and the widget by type
					table.insert(parent.widget_list, slider)
					table.insert(parent.widget_list_by_type.slider, slider)

					widgetCreated = slider
					amountLineWidgetCreated = amountLineWidgetCreated + 1

				elseif (widgetTable.type == "color") then
					---@cast widgetTable df_menu_color
					assert(widgetTable.get, "DetailsFramework:BuildMenu(): .get not found in the widget table for 'color'")
					local colorpick = detailsFramework:NewColorPickButton(parent, "$parentWidget" .. index, nil, widgetTable.set, nil, buttonTemplate)

					local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
					DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, colorpick, "have_tooltip", descPhraseId, widgetTable.desc)

					colorpick._get = widgetTable.get
					colorpick.widget_type = "color"
					colorpick:SetSize(18, 18)

					local r, g, b, a = detailsFramework:ParseColors(widgetTable.get())
					colorpick:SetColor(r, g, b, a)

					if (valueChangeHook) then
						colorpick:SetHook("OnColorChanged", valueChangeHook)
					end

					--hook list
					if (widgetTable.hooks) then
						for hookName, hookFunc in pairs(widgetTable.hooks) do
							colorpick:SetHook(hookName, hookFunc)
						end
					end

					local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
					local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
					DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

                    if (bAlignAsPairs) then
                        label:SetPoint(currentXOffset, currentYOffset)
                        colorpick:SetPoint("left", label, "left", nAlignAsPairsLength, 0)
                        createOptionHighlightTexture(colorpick, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
                    else
                        if (widgetTable.boxfirst or bUseBoxFirstOnAllWidgets) then
                            label:SetPoint("left", colorpick, "right", 2)
                            colorpick:SetPoint(currentXOffset, currentYOffset)
                            extraPaddingY = 1
                        else
                            colorpick:SetPoint("left", label, "right", 2)
                            label:SetPoint(currentXOffset, currentYOffset)
                        end
                    end

					colorpick.hasLabel = label

					if (widgetTable.id) then
						parent.widgetids[widgetTable.id] = colorpick
					end

					local widgetTotalSize = label.widget:GetStringWidth() + 32
					if (widgetTotalSize > maxColumnWidth) then
						maxColumnWidth = widgetTotalSize
					end

                    if (colorpick:GetWidth() > maxWidgetWidth) then
                        maxWidgetWidth = colorpick:GetWidth()
                    end

					--store the widget created into the overall table and the widget by type
					table.insert(parent.widget_list, colorpick)
					table.insert(parent.widget_list_by_type.color, colorpick)

					widgetCreated = colorpick
					amountLineWidgetCreated = amountLineWidgetCreated + 1

				elseif (widgetTable.type == "execute") then
					---@cast widgetTable df_menu_button

					local button = detailsFramework:NewButton(parent, nil, "$parentWidget" .. index, nil, widgetWidth or 120, widgetHeight or 18, widgetTable.func, widgetTable.param1, widgetTable.param2, nil, "", nil, buttonTemplate, textTemplate)

					local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
					DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, button.widget, namePhraseId, widgetTable.name)

					if (not buttonTemplate) then
						button:InstallCustomTexture()
					end

                    if (widgetTable.inline) then
                        if (latestInlineWidget) then
                            button:SetPoint("left", latestInlineWidget, "right", 2, 0)
                            latestInlineWidget = button
                        else
                            button:SetPoint(currentXOffset, currentYOffset)
                            latestInlineWidget = button
                        end
                    else
                        button:SetPoint(currentXOffset, currentYOffset)
                    end

					local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
					DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, button, "have_tooltip", descPhraseId, widgetTable.desc)

					button.widget_type = "execute"

					--button icon
					if (widgetTable.icontexture) then
						button:SetIcon(widgetTable.icontexture, nil, nil, nil, widgetTable.icontexcoords, nil, nil, 2)
					end

					--hook list
					if (widgetTable.hooks) then
						for hookName, hookFunc in pairs(widgetTable.hooks) do
							button:SetHook(hookName, hookFunc)
						end
					end

					if (widgetTable.id) then
						parent.widgetids [widgetTable.id] = button
					end

					if (widgetTable.width and not widgetWidth) then
						button:SetWidth(widgetTable.width)
					end
					if (widgetTable.height and not widgetHeight) then
						button:SetHeight(widgetTable.height)
					end

					local widgetTotalSize = button:GetWidth() + 4
					if (widgetTotalSize > maxColumnWidth) then
						maxColumnWidth = widgetTotalSize
					end

                    if (button:GetWidth() > maxWidgetWidth) then
                        maxWidgetWidth = button:GetWidth()
                    end

					--store the widget created into the overall table and the widget by type
					table.insert(parent.widget_list, button)
					table.insert(parent.widget_list_by_type.button, button)

					widgetCreated = button
					amountLineWidgetCreated = amountLineWidgetCreated + 1

				elseif (widgetTable.type == "textentry") then
					---@cast widgetTable df_menu_textentry

					local textentry = detailsFramework:CreateTextEntry(parent, widgetTable.func or widgetTable.set, widgetWidth or 120, widgetHeight or 18, nil, "$parentWidget" .. index, nil, buttonTemplate)
					textentry.align = widgetTable.align or "left"

					local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
					DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, textentry, "have_tooltip", descPhraseId, widgetTable.desc)

					textentry.text = widgetTable.get()
					textentry._get = widgetTable.get
					textentry.widget_type = "textentry"
					textentry:SetHook("OnEnterPressed", widgetTable.func or widgetTable.set)
					textentry:SetHook("OnEditFocusLost", widgetTable.func or widgetTable.set)

					local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)

					local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
					DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

                    if (bAlignAsPairs) then
                        label:SetPoint(currentXOffset, currentYOffset)
                        textentry:SetPoint("left", label, "left", nAlignAsPairsLength, 0)
                        createOptionHighlightTexture(textentry, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
                    else
					    textentry:SetPoint("left", label, "right", 2)
					    label:SetPoint(currentXOffset, currentYOffset)
                    end

					textentry.hasLabel = label

					--hook list
					if (widgetTable.hooks) then
						for hookName, hookFunc in pairs(widgetTable.hooks) do
							textentry:SetHook(hookName, hookFunc)
						end
					end

					if (widgetTable.id) then
						parent.widgetids [widgetTable.id] = textentry
					end

					local widgetTotalSize = label.widget:GetStringWidth() + 64
					if (widgetTotalSize > maxColumnWidth) then
						maxColumnWidth = widgetTotalSize
					end

                    if (textentry:GetWidth() > maxWidgetWidth) then
                        maxWidgetWidth = textentry:GetWidth()
                    end

					--store the widget created into the overall table and the widget by type
					table.insert(parent.widget_list, textentry)
					table.insert(parent.widget_list_by_type.textentry, textentry)

					widgetCreated = textentry
					amountLineWidgetCreated = amountLineWidgetCreated + 1
				end

				if (widgetTable.nocombat) then
					table.insert(widgetsToDisableOnCombat, widgetCreated)
				end

				if (not widgetTable.inline) then
					if (widgetTable.spacement) then
						currentYOffset = currentYOffset - 30
					else
						currentYOffset = currentYOffset - 20
					end
				end

				if (extraPaddingY > 0) then
					currentYOffset = currentYOffset - extraPaddingY
				end

                if (bUseScrollFrame) then
                    if (widgetTable.type == "breakline") then
                        biggestColumnHeight = math.min(currentYOffset, biggestColumnHeight)
                        currentYOffset = yOffset

                        if (bAlignAsPairs) then
                            currentXOffset = currentXOffset + nAlignAsPairsLength + (widgetWidth or maxWidgetWidth) + nAlignAsPairsSpacing
                        else
                            currentXOffset = currentXOffset + maxColumnWidth + 20
                        end

                        amountLineWidgetCreated = 0
                        maxColumnWidth = 0
                        maxWidgetWidth = 0
                    end
                else
                    if (widgetTable.type == "breakline" or currentYOffset < height) then
                        currentYOffset = yOffset
                        currentXOffset = currentXOffset + maxColumnWidth + 20
                        amountLineWidgetCreated = 0
                        maxColumnWidth = 0
                    end
                end
			end
		end

        if (bUseScrollFrame) then
            parent:SetHeight(biggestColumnHeight * -1)
        end

		detailsFramework.RefreshUnsafeOptionsWidgets()
	end


    local lockNotSafeWidgetsForCombat = function()
		for _, widget in ipairs(widgetsToDisableOnCombat) do
			widget:Disable()
		end
	end

	local unlockNotSafeWidgetsForCombat = function()
		for _, widget in ipairs(widgetsToDisableOnCombat) do
			widget:Enable()
		end
	end

	function detailsFramework.RefreshUnsafeOptionsWidgets()
		if (detailsFramework.PlayerHasCombatFlag) then
			lockNotSafeWidgetsForCombat()
		else
			unlockNotSafeWidgetsForCombat()
		end
	end

	detailsFramework.PlayerHasCombatFlag = false
	local ProtectCombatFrame = CreateFrame("frame")
	ProtectCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	ProtectCombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	ProtectCombatFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ProtectCombatFrame:SetScript("OnEvent", function(self, event)
		if (event == "PLAYER_ENTERING_WORLD") then
			if (InCombatLockdown()) then
				detailsFramework.PlayerHasCombatFlag = true
			else
				detailsFramework.PlayerHasCombatFlag = false
			end
			detailsFramework.RefreshUnsafeOptionsWidgets()

		elseif (event == "PLAYER_REGEN_ENABLED") then
			detailsFramework.PlayerHasCombatFlag = false
			detailsFramework.RefreshUnsafeOptionsWidgets()

		elseif (event == "PLAYER_REGEN_DISABLED") then
			detailsFramework.PlayerHasCombatFlag = true
			detailsFramework.RefreshUnsafeOptionsWidgets()
		end
	end)

	function detailsFramework:CreateInCombatTexture(frame)
		if (detailsFramework.debug and not frame) then
			error("Details! Framework: CreateInCombatTexture invalid frame on parameter 1.")
		end

		local inCombatBackgroundTexture = detailsFramework:CreateImage(frame)
		inCombatBackgroundTexture:SetColorTexture(.6, 0, 0, .1)
		inCombatBackgroundTexture:Hide()

		local inCombatLabel = detailsFramework:CreateLabel(frame, "you are in combat", 24, "silver")
		inCombatLabel:SetPoint("right", inCombatBackgroundTexture, "right", -10, 0)
		inCombatLabel:Hide()

		frame:RegisterEvent("PLAYER_REGEN_DISABLED")
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")

		frame:SetScript("OnEvent", function(self, event)
			if (event == "PLAYER_REGEN_DISABLED") then
				inCombatBackgroundTexture:Show()
				inCombatLabel:Show()

			elseif (event == "PLAYER_REGEN_ENABLED") then
				inCombatBackgroundTexture:Hide()
				inCombatLabel:Hide()
			end
		end)

		return inCombatBackgroundTexture
	end