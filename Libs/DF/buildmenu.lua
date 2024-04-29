
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

---@class df_menu : frame
---@field RefreshOptions fun()
---@field widget_list table
---@field widget_list_by_type table
---@field widgetids table
---@field GetWidgetById fun(optionsFrame: df_menu, id: string): table this should return a widget from the widgetids table

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
---@field include_default boolean

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

detailsFramework.OptionsFrameMixin = {

}

local onWidgetSetInUse = function(widget, widgetTable)
    if (widgetTable.childrenids) then
        widget.childrenids = widgetTable.childrenids
    end
    widget.children_follow_enabled = widgetTable.children_follow_enabled

    if (widgetTable.disabled) then
        widget:Disable()
    else
        if (widget.IsEnabled and not widget:IsEnabled()) then
            widget:Enable()
        end
    end
end

local setWidgetId = function(parent, widgetTable, widgetObject)
    if (widgetTable.id) then
        parent.widgetids[widgetTable.id] = widgetObject
    end
    widgetTable.widget = widgetObject
end

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

local setLabelProperties = function(parent, widget, widgetTable, currentXOffset, currentYOffset, template)
    widget._get = widgetTable.get
    widget.widget_type = "label"
    widget:SetPoint(currentXOffset, currentYOffset)

    if (widgetTable.text_template or template) then
        widget:SetTemplate(widgetTable.text_template or template)
    else
        widget.fontsize = widgetTable.size or 10
    end

    if (widgetTable.font) then
        widget.fontface = widgetTable.font
    end

    setWidgetId(parent, widgetTable, widget)
    onWidgetSetInUse(widget, widgetTable)
end

local setDropdownProperties = function(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth)
    widget._get = widgetTable.get
    widget.widget_type = "select"

    widget:Refresh()
    widget:Select(widgetTable.get())
    widget:SetTemplate(template)

    if (widgetWidth) then
        widget:SetWidth(widgetWidth)
    end
    if (widgetHeight) then
        widget:SetHeight(widgetHeight)
    end

    setWidgetId(parent, widgetTable, widget)

    local label = widget.hasLabel.widget

    widget:ClearAllPoints()
    label:ClearAllPoints()

    if (bAlignAsPairs) then --regular
        PixelUtil.SetPoint(label, "topleft", widget:GetParent(), "topleft", currentXOffset, currentYOffset)
        PixelUtil.SetPoint(widget.widget, "left", label, "left", nAlignAsPairsLength, 0)

        if (not widget.highlightFrame) then
            local highlightFrame = createOptionHighlightTexture(widget, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
            widget.highlightFrame = highlightFrame
        end
    else
        widget:SetPoint("left", label, "right", 2, 0)
        label:SetPoint("topleft", parent, "topleft", currentXOffset, currentYOffset)
    end

    --global callback
    if (valueChangeHook) then
        widget:SetHook("OnOptionSelected", valueChangeHook)
    end

    --hook list
    if (widgetTable.hooks) then
        for hookName, hookFunc in pairs(widgetTable.hooks) do
            widget:SetHook(hookName, hookFunc)
        end
    end

    local widgetTotalSize = label:GetStringWidth() + 144
    if (widgetTotalSize > maxColumnWidth) then
        maxColumnWidth = widgetTotalSize
    end

    if (widget:GetWidth() > maxWidgetWidth) then
        maxWidgetWidth = widget:GetWidth()
    end

    onWidgetSetInUse(widget, widgetTable)

    return maxColumnWidth, maxWidgetWidth
end

local setToggleProperties = function(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, switchIsCheckbox, bUseBoxFirstOnAllWidgets, menuOptions, index, maxWidgetWidth)
    widget._get = widgetTable.get
    widget.widget_type = "toggle"
    widget.OnSwitch = widgetTable.set

    if (switchIsCheckbox) then
        widget:SetAsCheckBox()
    end

    if (widgetTable.children_follow_enabled) then
        widget.SetValueOriginal = widget.SetValue

        local newSetFunc = function(widget, value)
            --look for children ids
            local childrenids = widgetTable.childrenids
            if (type(childrenids) == "table") then
                for i, childId in ipairs(childrenids) do
                    local childWidget = parent:GetWidgetById(childId)
                    if (childWidget) then
                        --if the children_follow_reverse is true, then the children will be enabled when the toogle is disabeld
                        --this is used when the main toggle is a kind of "Do This Automatically", if is not doing it automatically
                        --then the children should be enabled to set the options
                        if (widgetTable.children_follow_reverse) then
                            if (value) then
                                childWidget:Disable()
                            else
                                childWidget:Enable()
                            end
                        else
                            if (value) then
                                childWidget:Enable()
                            else
                                childWidget:Disable()
                            end
                        end
                    end
                end
            end

            widget.SetValueOriginal(widget, value)
            return value
        end

        widget:SetValue(widgetTable.get())
        rawset(widget, "SetValue", newSetFunc)
    else
        if (widget.SetValueOriginal) then
            rawset(widget, "SetValue", widget.SetValueOriginal)
            rawset(widget, "SetValueOriginal", nil)
        end
        widget:SetValue(widgetTable.get())
    end

    if (widgetWidth) then
        PixelUtil.SetWidth(widget.widget, widgetWidth)
    end
    if (widgetHeight) then
        PixelUtil.SetHeight(widget.widget, widgetHeight)
    end

    widget:SetTemplate(template)

    setWidgetId(parent, widgetTable, widget)

    local label = widget.hasLabel.widget

    widget:ClearAllPoints()
    label:ClearAllPoints()

    local extraPaddingY = 0

    if (bAlignAsPairs) then
        PixelUtil.SetPoint(label, "topleft", widget:GetParent(), "topleft", currentXOffset, currentYOffset)
        PixelUtil.SetPoint(widget.widget, "left", label, "left", nAlignAsPairsLength, 0)

        if (not widget.highlightFrame) then
            local highlightFrame = createOptionHighlightTexture(widget, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
            widget.highlightFrame = highlightFrame
        end
    else
        if (widgetTable.boxfirst or bUseBoxFirstOnAllWidgets) then
            label:SetPoint("left", widget.widget or widget, "right", 2, 0)
            widget:SetPoint("topleft", parent, "topleft", currentXOffset, currentYOffset)

            local nextWidgetTable = menuOptions[index+1]
            if (nextWidgetTable) then
                if (nextWidgetTable.type ~= "blank" and nextWidgetTable.type ~= "breakline" and nextWidgetTable.type ~= "toggle" and nextWidgetTable.type ~= "color") then
                    extraPaddingY = 4
                end
            end
        else
            widget:SetPoint("left", label, "right", 2, 0)
            label:SetPoint("topleft", parent, "topleft", currentXOffset, currentYOffset)
        end
    end

    --global callback
    if (valueChangeHook) then
        widget:SetHook("OnSwitch", valueChangeHook)
    end

    --hook list
    if (widgetTable.hooks) then
        for hookName, hookFunc in pairs(widgetTable.hooks) do
            widget:SetHook(hookName, hookFunc)
        end
    end

    local widgetTotalSize = label:GetStringWidth() + 32
    if (widgetTotalSize > maxColumnWidth) then
        maxColumnWidth = widgetTotalSize
    end

    if (widget:GetWidth() > maxWidgetWidth) then
        maxWidgetWidth = widget:GetWidth()
    end

    onWidgetSetInUse(widget, widgetTable)

    return maxColumnWidth, maxWidgetWidth, extraPaddingY
end

local setRangeProperties = function(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, bIsDecimals, bAttachSliderButtonsToLeft)
    widget._get = widgetTable.get
    widget.widget_type = "range"
    widget:SetTemplate(template)

    widget.bAttachButtonsToLeft = bAttachSliderButtonsToLeft

    local currentValue = widgetTable.get()

    if (bIsDecimals) then
        widget.slider:SetValueStep(0.01)
    else
        widget.slider:SetValueStep(widgetTable.step or 1)
        currentValue = math.floor(currentValue)
    end
    widget.useDecimals = bIsDecimals

    widget.slider:SetMinMaxValues(widgetTable.min, widgetTable.max)
    widget.slider:SetValue(currentValue or 0)
    widget.ivalue = widget.slider:GetValue()

    if (widgetWidth) then
        widget:SetWidth(widgetWidth)
    end
    if (widgetHeight) then
        widget:SetHeight(widgetHeight)
    end

    widget:SetHook("OnValueChange", widgetTable.set)

    if (valueChangeHook) then
        widget:SetHook("OnValueChange", valueChangeHook)
    end

    if (widgetTable.thumbscale) then
        widget:SetThumbSize(widget.thumb.originalWidth * widgetTable.thumbscale, nil)
    else
        widget:SetThumbSize(widget.thumb.originalWidth * 1.3, nil)
    end

    --hook list
    if (widgetTable.hooks) then
        for hookName, hookFunc in pairs(widgetTable.hooks) do
            widget:SetHook(hookName, hookFunc)
        end
    end

    setWidgetId(parent, widgetTable, widget)

    local label = widget.hasLabel.widget

    widget:ClearAllPoints()
    label:ClearAllPoints()

    if (bAlignAsPairs) then
        PixelUtil.SetPoint(label, "topleft", widget:GetParent(), "topleft", currentXOffset, currentYOffset)
        PixelUtil.SetPoint(widget.widget, "left", label, "left", nAlignAsPairsLength, 0)

        if (not widget.highlightFrame) then
            local highlightFrame = createOptionHighlightTexture(widget, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
            widget.highlightFrame = highlightFrame
        end
    else
        widget:SetPoint("left", label, "right", 2, 0)
        label:SetPoint("topleft", parent, "topleft", currentXOffset, currentYOffset)
    end

    local widgetTotalSize = label:GetStringWidth() + 146
    if (widgetTotalSize > maxColumnWidth) then
        maxColumnWidth = widgetTotalSize
    end

    if (widget:GetWidth() > maxWidgetWidth) then
        maxWidgetWidth = widget:GetWidth()
    end

    onWidgetSetInUse(widget, widgetTable)

    return maxColumnWidth, maxWidgetWidth
end

local setColorProperties = function(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, bUseBoxFirstOnAllWidgets, extraPaddingY)
    widget._get = widgetTable.get
    widget.widget_type = "color"

    local r, g, b, a = detailsFramework:ParseColors(widgetTable.get())
    widget:SetColor(r, g, b, a)

    widget.color_callback = widgetTable.set --callback

    --[=[
        if (widgetWidth) then
            widget:SetWidth(widgetWidth)
        else
            widget:SetWidth(18)
        end

        if (widgetHeight) then
            widget:SetHeight(widgetHeight)
        else
            widget:SetHeight(18)
        end
    --]=]

    widget:SetTemplate(template)
    widget:SetWidth(18)
    widget:SetHeight(18)

    widget:SetHook("OnColorChanged", widgetTable.set)

    if (valueChangeHook) then
        widget:SetHook("OnColorChanged", valueChangeHook)
    end

    --hook list
    if (widgetTable.hooks) then
        for hookName, hookFunc in pairs(widgetTable.hooks) do
            widget:SetHook(hookName, hookFunc)
        end
    end

    setWidgetId(parent, widgetTable, widget)

    local label = widget.hasLabel.widget

    widget:ClearAllPoints()
    label:ClearAllPoints()

    if (bAlignAsPairs) then
        PixelUtil.SetPoint(label, "topleft", widget:GetParent(), "topleft", currentXOffset, currentYOffset)
        PixelUtil.SetPoint(widget.widget, "left", label, "left", nAlignAsPairsLength, 0)

        if (not widget.highlightFrame) then
            local highlightFrame = createOptionHighlightTexture(widget, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
            widget.highlightFrame = highlightFrame
        end
    else
        if (widgetTable.boxfirst or bUseBoxFirstOnAllWidgets) then
            label:SetPoint("left", widget.widget, "right", 2, 0)
            widget:SetPoint(currentXOffset, currentYOffset)
            extraPaddingY = 1
        else
            widget:SetPoint("left", label, "right", 2, 0)
            label:SetPoint("topleft", parent, "topleft", currentXOffset, currentYOffset)
        end
    end

    local widgetTotalSize = label:GetStringWidth() + 32
    if (widgetTotalSize > maxColumnWidth) then
        maxColumnWidth = widgetTotalSize
    end

    if (widget:GetWidth() > maxWidgetWidth) then
        maxWidgetWidth = widget:GetWidth()
    end

    onWidgetSetInUse(widget, widgetTable)

    return maxColumnWidth, maxWidgetWidth, extraPaddingY
end

local setExecuteProperties = function(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, textTemplate, latestInlineWidget)
    widget._get = widgetTable.get
    widget.widget_type = "execute"
    widget:SetTemplate(template)
    widget:SetWidth(widgetWidth or widgetTable.width or 120, widgetHeight or widgetTable.height or 18)

    widget:SetClickFunction(widgetTable.func, widgetTable.param1, widgetTable.param2)

    --button icon
    if (widgetTable.icontexture) then
        widget:SetIcon(widgetTable.icontexture, nil, nil, nil, widgetTable.icontexcoords, nil, nil, 2)
    end

    textTemplate = widgetTable.text_template or textTemplate or detailsFramework.font_templates["ORANGE_FONT_TEMPLATE"]
    widget.textcolor = textTemplate.color
    widget.textfont = textTemplate.font
    widget.textsize = textTemplate.size

    --hook list
    if (widgetTable.hooks) then
        for hookName, hookFunc in pairs(widgetTable.hooks) do
            widget:SetHook(hookName, hookFunc)
        end
    end

    setWidgetId(parent, widgetTable, widget)

    local label = widget.hasLabel.widget

    widget:ClearAllPoints()
    label:ClearAllPoints()

    if (bAlignAsPairs) then
        PixelUtil.SetPoint(label, "topleft", widget:GetParent(), "topleft", currentXOffset, currentYOffset)
        PixelUtil.SetPoint(widget.widget, "left", label, "left", nAlignAsPairsLength, 0)

        if (not widget.highlightFrame) then
            local highlightFrame = createOptionHighlightTexture(widget, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
            widget.highlightFrame = highlightFrame
        end
    else
        if (widgetTable.inline) then
            if (latestInlineWidget) then
                widget:SetPoint("left", latestInlineWidget, "right", 2, 0)
                latestInlineWidget = widget
            else
                widget:SetPoint(currentXOffset, currentYOffset)
                latestInlineWidget = widget
            end
        else
            widget:SetPoint(currentXOffset, currentYOffset)
        end
    end

    local widgetTotalSize = widget:GetWidth() + 4
    if (widgetTotalSize > maxColumnWidth) then
        maxColumnWidth = widgetTotalSize
    end

    if (widget:GetWidth() > maxWidgetWidth) then
        maxWidgetWidth = widget:GetWidth()
    end

    onWidgetSetInUse(widget, widgetTable)

    return maxColumnWidth, maxWidgetWidth, latestInlineWidget
end

local setTextEntryProperties = function(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, textTemplate, latestInlineWidget)
    widget._get = widgetTable.get
    widget.text = widgetTable.get()
    widget.widget_type = "textentry"
    widget:SetTemplate(widgetTable.template or widgetTable.button_template or template)
    widget:SetWidth(widgetWidth or widgetTable.width or 120, widgetHeight or widgetTable.height or 18)
    widget:SetCommitFunction(widgetTable.func or widgetTable.set)

    widget:SetHook("OnEnterPressed", function(...)
        local upFunc = widgetTable.func or widgetTable.set
        upFunc(...)
        if (valueChangeHook) then
            valueChangeHook()
        end
    end)

    widget:SetHook("OnEditFocusLost", function(...)
        local upFunc = widgetTable.func or widgetTable.set
        upFunc(...)
        if (valueChangeHook) then
            valueChangeHook()
        end
    end)

    textTemplate = widgetTable.text_template or textTemplate or detailsFramework.font_templates["ORANGE_FONT_TEMPLATE"]
    widget.textcolor = textTemplate.color
    widget.textfont = textTemplate.font
    widget.textsize = textTemplate.size

    --hook list
    if (widgetTable.hooks) then
        for hookName, hookFunc in pairs(widgetTable.hooks) do
            widget:SetHook(hookName, hookFunc)
        end
    end

    setWidgetId(parent, widgetTable, widget)

    local label = widget.hasLabel.widget

    widget:ClearAllPoints()
    label:ClearAllPoints()

    if (bAlignAsPairs) then
        PixelUtil.SetPoint(label, "topleft", widget:GetParent(), "topleft", currentXOffset, currentYOffset)
        PixelUtil.SetPoint(widget.widget, "left", label, "left", nAlignAsPairsLength, 0)

        if (not widget.highlightFrame) then
            local highlightFrame = createOptionHighlightTexture(widget, label, (widgetWidth or 140) + nAlignAsPairsLength + 5)
            widget.highlightFrame = highlightFrame
        end
    else
        widget:SetPoint("left", label, "right", 2, 0)
        label:SetPoint("topleft", parent, "topleft", currentXOffset, currentYOffset)
    end

    local widgetTotalSize = label:GetStringWidth() + 64 --need review, might not be correct
    if (widgetTotalSize > maxColumnWidth) then
        maxColumnWidth = widgetTotalSize
    end

    if (widget:GetWidth() > maxWidgetWidth) then
        maxWidgetWidth = widget:GetWidth()
    end

    onWidgetSetInUse(widget, widgetTable)

    return maxColumnWidth, maxWidgetWidth
end

local onMenuBuilt = function(parent)
    --refresh the options to find children to disable or enable
    if (parent.build_menu_options) then
        for index, widgetTable in ipairs(parent.build_menu_options) do
            if (widgetTable.children_follow_enabled) then --not found, bug
                local widget = widgetTable.widget
                local childrenids = widgetTable.childrenids
                if (type(childrenids) == "table") then
                    for i, childId in ipairs(childrenids) do
                        local childWidget = parent:GetWidgetById(childId)
                        if (childWidget) then
                            local value = widget:GetValue()
                            if (widgetTable.children_follow_reverse) then
                                if (value) then
                                    childWidget:Disable()
                                else
                                    childWidget:Enable()
                                end
                            else
                                if (value) then
                                    childWidget:Enable()
                                else
                                    childWidget:Disable()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local refreshOptions = function(self)
    for _, widget in ipairs(self.widget_list) do
        if (widget._get) then
            if (widget.widget_type == "label") then
                if (widget._get() and not widget.languageAddonId) then
                    widget:SetText(widget._get())
                end

            elseif (widget.widget_type == "select") then
                widget:Select(widget._get())

            elseif (widget.widget_type == "toggle" or widget.widget_type == "range") then
                widget:SetValue(widget._get())

            elseif (widget.widget_type == "textentry") then
                widget:SetText(widget._get())

            elseif (widget.widget_type == "color") then
                local default_value, g, b, a = widget._get()
                if (type(default_value) == "table") then
                    widget:SetColor (unpack(default_value))

                else
                    widget:SetColor (default_value, g, b, a)
                end
            end
        end
    end

    onMenuBuilt(self)
end

detailsFramework.internalFunctions.RefreshOptionsPanel = refreshOptions

local parseOptionsTypes = function(menuOptions)
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
end

local parseOptionsTable = function(menuOptions)
    local bUseBoxFirstOnAllWidgets = menuOptions.always_boxfirst
    local widgetWidth = menuOptions.widget_width --a width to be used on all widgets
    local widgetHeight = menuOptions.widget_height --a height to be used on all widgets
    local bAlignAsPairs = menuOptions.align_as_pairs
    local nAlignAsPairsLength = menuOptions.align_as_pairs_string_space or 160
    local nAlignAsPairsSpacing = menuOptions.align_as_pairs_spacing or 20
    local bAttachSliderButtonsToLeft = menuOptions.slider_buttons_to_left

    --if a scrollbox is passed, the height can be ignored
    --the scrollBox child will be used as the parent, and the height of the child will be resized to fit the widgets
    local bUseScrollFrame = menuOptions.use_scrollframe
    local languageAddonId = menuOptions.language_addonId
    return bUseBoxFirstOnAllWidgets, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, nAlignAsPairsSpacing, bUseScrollFrame, languageAddonId, bAttachSliderButtonsToLeft
end

local parseParent = function(bUseScrollFrame, parent, height, yOffset)
    if (bUseScrollFrame) then
        local width, height = parent:GetSize()
        parent = parent:GetScrollChild()
        parent:SetSize(width, height)
    else
        if (height and type(height) == "number") then
            height = math.abs((height or parent:GetHeight()) - math.abs(yOffset) + 20)
            height = height * -1
        else
            height = parent:GetHeight()
        end
    end

    return parent, height
end

local parseLanguageTable = function(languageAddonId)
    local languageTable
    if (languageAddonId) then
        languageTable = DetailsFramework.Language.GetLanguageTable(languageAddonId)
    end
    return languageTable
end

local getFrameById = function(self, id)
    return self.widgetids[id]
end

function detailsFramework:ClearOptionsPanel(frame)
    for i = 1, #frame.widget_list do
        frame.widget_list[i]:Hide()
        if (frame.widget_list[i].hasLabel) then
            frame.widget_list[i].hasLabel:SetText("")
        end
    end
    table.wipe(frame.widgetids)
end

function detailsFramework:SetAsOptionsPanel(frame)
    --print("refresh_options", refresh_options)
    frame.RefreshOptions = refreshOptions
    frame.widget_list = {}
    frame.widget_list_by_type = {
        ["dropdown"] = {}, -- "select"
        ["switch"] = {}, -- "toggle"
        ["slider"] = {}, -- "range"
        ["color"] = {}, --
        ["button"] = {}, -- "execute"
        ["textentry"] = {}, --
        ["label"] = {}, --"text"
    }
    frame.widgetids = {}
    frame.GetWidgetById = getFrameById
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

    --clean children ids, children ids are used to disable or enable other widgets when a widget is disabled or enabled
    if (widgetObject.childrenids) then
        table.wipe(widgetObject.childrenids)
    end
    widgetObject.children_follow_enabled = nil

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

    local amountLineWidgetAdded = 0
    local biggestColumnHeight = 0 --used to resize the scrollbox child when a scrollbox is passed
    local latestInlineWidget
    local currentXOffset = xOffset or 0
    local currentYOffset = yOffset or 0
    local maxColumnWidth = 0 --biggest width of widget + text size on the current column loop pass
    local maxWidgetWidth = 0 --biggest widget width on the current column loop pass

    --which is the next widget to get from the pool
    local widgetIndexes = {
        label = 1,
        dropdown = 1,
        switch = 1,
        slider = 1,
        color = 1,
        button = 1,
        textentry = 1,
    }

    parseOptionsTypes(menuOptions)

    local bUseBoxFirstOnAllWidgets, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, nAlignAsPairsSpacing, bUseScrollFrame, languageAddonId, bAttachSliderButtonsToLeft = parseOptionsTable(menuOptions)
    parent, height = parseParent(bUseScrollFrame, parent, height, yOffset)
    local languageTable = parseLanguageTable(languageAddonId)

    parent.build_menu_options = menuOptions

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
                    label:ClearAllPoints()
                    widgetCreated = label

                    setLabelProperties(parent, label, widgetTable, currentXOffset, currentYOffset, textTemplate)

                    local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable)
                    local namePhrase = (languageTable and (languageTable[namePhraseId] or languageTable[widgetTable.namePhraseId] or languageTable[widgetTable.name])) or (widgetTable.get and widgetTable.get()) or widgetTable.text or (widgetTable.namePhraseId) or ""
                    label.text = namePhrase
                    label.color = widgetTable.color

                    amountLineWidgetAdded = amountLineWidgetAdded + 1

                --dropdowns
                elseif (widgetTable.type:find("select")) then
                    assert(widgetTable.get, "DetailsFramework:BuildMenu: .get() not found in the widget table for 'select'")
                    local dropdown = getMenuWidgetVolative(parent, "dropdown", widgetIndexes)
                    widgetCreated = dropdown
                    local defaultHeight = 18

                    do
                        if (widgetTable.type == "selectfont") then
                            local func = detailsFramework:CreateFontListGenerator(widgetTable.set, widgetTable.include_default)
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
                    end

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    dropdown:SetTooltip(descPhrase)

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    dropdown.hasLabel.text = namePhrase
                    dropdown.hasLabel:SetTemplate(widgetTable.text_template or textTemplate)

                    maxColumnWidth, maxWidgetWidth = setDropdownProperties(parent, dropdown, widgetTable, currentXOffset, currentYOffset, textTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth)
                    amountLineWidgetAdded = amountLineWidgetAdded + 1

                --switchs
                elseif (widgetTable.type == "toggle" or widgetTable.type == "switch") then
                    local switch = getMenuWidgetVolative(parent, "switch", widgetIndexes)
                    widgetCreated = switch

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    switch:SetTooltip(descPhrase)

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    switch.hasLabel.text = namePhrase
                    switch.hasLabel:SetTemplate(widgetTable.text_template or textTemplate)

                    maxColumnWidth, maxWidgetWidth, extraPaddingY = setToggleProperties(parent, switch, widgetTable, currentXOffset, currentYOffset, switchTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, true,             bUseBoxFirstOnAllWidgets, menuOptions, index, maxWidgetWidth)
                    amountLineWidgetAdded = amountLineWidgetAdded + 1

                --slider
                elseif (widgetTable.type == "range") then
                    local slider = getMenuWidgetVolative(parent, "slider", widgetIndexes)
                    widgetCreated = slider

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    slider:SetTooltip(descPhrase)

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    slider.hasLabel.text = namePhrase
                    slider.hasLabel:SetTemplate(widgetTable.text_template or textTemplate)

                    maxColumnWidth, maxWidgetWidth = setRangeProperties(parent, slider, widgetTable, currentXOffset, currentYOffset, sliderTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, widgetTable.usedecimals, bAttachSliderButtonsToLeft)
                    amountLineWidgetAdded = amountLineWidgetAdded + 1

                --color
                elseif (widgetTable.type == "color") then
                    local colorpick = getMenuWidgetVolative(parent, "color", widgetIndexes)
                    widgetCreated = colorpick

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    colorpick:SetTooltip(descPhrase)

                    local label = colorpick.hasLabel
                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    label.text = namePhrase
                    label:SetTemplate(widgetTable.text_template or textTemplate)

                    maxColumnWidth, maxWidgetWidth, extraPaddingY = setColorProperties(parent, colorpick, widgetTable, currentXOffset, currentYOffset, switchTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, bUseBoxFirstOnAllWidgets, extraPaddingY)
                    amountLineWidgetAdded = amountLineWidgetAdded + 1

                --button
                elseif (widgetTable.type == "execute" or widgetTable.type == "button") then
                    local button = getMenuWidgetVolative(parent, "button", widgetIndexes)
                    button.widget_type = "execute"
                    widgetCreated = button

                    maxColumnWidth, maxWidgetWidth, latestInlineWidget = setExecuteProperties(parent, button, widgetTable, currentXOffset, currentYOffset, buttonTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, textTemplate, latestInlineWidget)

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    button.text = namePhrase

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    button:SetTooltip(descPhrase)
                    amountLineWidgetAdded = amountLineWidgetAdded + 1

                --textentry
                elseif (widgetTable.type == "textentry") then
                    local textentry = getMenuWidgetVolative(parent, "textentry", widgetIndexes)
                    widgetCreated = textentry

                    local descPhrase = getDescPhraseText(languageTable, widgetTable)
                    textentry:SetTooltip(descPhrase)

                    local namePhrase = getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
                    textentry.hasLabel.text = namePhrase
                    textentry.hasLabel:SetTemplate(widgetTable.text_template or textTemplate)

                    maxColumnWidth, maxWidgetWidth = setTextEntryProperties(parent, textentry, widgetTable, currentXOffset, currentYOffset, buttonTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, textTemplate)
                    amountLineWidgetAdded = amountLineWidgetAdded + 1
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

                if (bUseScrollFrame) then
                    if (widgetTable.type == "breakline") then
                        biggestColumnHeight = math.min(currentYOffset, biggestColumnHeight)
                        currentYOffset = yOffset

                        if (bAlignAsPairs) then
                            currentXOffset = currentXOffset + nAlignAsPairsLength + (widgetWidth or maxWidgetWidth) + nAlignAsPairsSpacing
                        else
                            currentXOffset = currentXOffset + maxColumnWidth + 20
                        end

                        amountLineWidgetAdded = 0
                        maxColumnWidth = 0
                        maxWidgetWidth = 0
                    end
                else
                    if (widgetTable.type == "breakline" or currentYOffset < height) then
                        currentYOffset = yOffset
                        currentXOffset = currentXOffset + maxColumnWidth + 20
                        amountLineWidgetAdded = 0
                        maxColumnWidth = 0
                    end
                end

                if widgetCreated then
                    widgetCreated:Show()
                end
            end
        end
    end

    detailsFramework.RefreshUnsafeOptionsWidgets()
    onMenuBuilt(parent)
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
    local amountLineWidgetAdded = 0
    local biggestColumnHeight = 0 --used to resize the scrollbox child when a scrollbox is passed
    local latestInlineWidget
    local currentXOffset = xOffset or 0
    local currentYOffset = yOffset or 0
    local maxColumnWidth = 0 --biggest width of widget + text size on the current column loop pass
    local maxWidgetWidth = 0 --biggest widget width on the current column loop pass

    --parse settings and the options table
    parseOptionsTypes(menuOptions)

    local bUseBoxFirstOnAllWidgets, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, nAlignAsPairsSpacing, bUseScrollFrame, languageAddonId, bAttachSliderButtonsToLeft = parseOptionsTable(menuOptions)
    parent, height = parseParent(bUseScrollFrame, parent, height, yOffset)
    local languageTable = parseLanguageTable(languageAddonId)

    parent.build_menu_options = menuOptions

    if (not parent.widget_list) then
        detailsFramework:SetAsOptionsPanel(parent)
    end

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
                setLabelProperties(parent, label, widgetTable, currentXOffset, currentYOffset)

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

                amountLineWidgetAdded = amountLineWidgetAdded + 1

            elseif (widgetTable.type:find("select")) then
                ---@cast widgetTable df_menu_dropdown
                assert(widgetTable.get, "DetailsFramework:BuildMenu: .get not found in the widget table for 'select'")
                local defaultHeight = 18

                local dropdown
                do
                    if (widgetTable.type == "selectfont") then
                        dropdown = detailsFramework:CreateFontDropDown(parent, widgetTable.set, widgetTable.get(), widgetWidth or 140, widgetHeight or defaultHeight, nil, "$parentWidget" .. index, dropdownTemplate, widgetTable.include_default)

                    elseif (widgetTable.type == "selectcolor") then
                        dropdown = detailsFramework:CreateColorDropDown(parent, widgetTable.set, widgetTable.get(), widgetWidth or 140, widgetHeight or defaultHeight, nil, "$parentWidget" .. index, dropdownTemplate)

                    elseif (widgetTable.type == "selectanchor") then
                        dropdown = detailsFramework:CreateAnchorPointDropDown(parent, widgetTable.set, widgetTable.get(), widgetWidth or 140, widgetHeight or defaultHeight, nil, "$parentWidget" .. index, dropdownTemplate)

                    elseif (widgetTable.type == "selectoutline") then
                        dropdown = detailsFramework:CreateOutlineDropDown(parent, widgetTable.set, widgetTable.get(), widgetWidth or 140, widgetHeight or defaultHeight, nil, "$parentWidget" .. index, dropdownTemplate)
                    else
                        dropdown = detailsFramework:NewDropDown(parent, nil, "$parentWidget" .. index, nil, widgetWidth or 140, widgetHeight or defaultHeight, widgetTable.values, widgetTable.get(), dropdownTemplate)
                    end
                end

                local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
                DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, dropdown, "have_tooltip", descPhraseId, widgetTable.desc)
                local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
                dropdown.hasLabel = label

                local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
                DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))
                dropdown.addonId = languageAddonId

                if (languageAddonId) then
                    detailsFramework.Language.RegisterCallback(languageAddonId, function(addonId, languageId, ...) dropdown:Select(dropdown:GetValue()) end)
                    C_Timer.After(0.1, function() dropdown:Select(dropdown:GetValue()) end)
                end

                maxColumnWidth, maxWidgetWidth = setDropdownProperties(parent, dropdown, widgetTable, currentXOffset, currentYOffset, textTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth)

                --store the widget created into the overall table and the widget by type
                table.insert(parent.widget_list, dropdown)
                table.insert(parent.widget_list_by_type.dropdown, dropdown)

                widgetCreated = dropdown
                amountLineWidgetAdded = amountLineWidgetAdded + 1

            elseif (widgetTable.type == "toggle") then
                ---@cast widgetTable df_menu_toggle

                local switch = detailsFramework:NewSwitch(parent, nil, "$parentWidget" .. index, nil, 60, 20, nil, nil, widgetTable.get(), nil, nil, nil, nil, switchTemplate)

                local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
                DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, switch, "have_tooltip", descPhraseId, widgetTable.desc)

                local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
                switch.hasLabel = label

                local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
                DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

                maxColumnWidth, maxWidgetWidth, extraPaddingY = setToggleProperties(parent, switch, widgetTable, currentXOffset, currentYOffset, switchTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, switchIsCheckbox, bUseBoxFirstOnAllWidgets, menuOptions, index, maxWidgetWidth)

                --store the widget created into the overall table and the widget by type
                table.insert(parent.widget_list, switch)
                table.insert(parent.widget_list_by_type.switch, switch)

                widgetCreated = switch
                amountLineWidgetAdded = amountLineWidgetAdded + 1

            elseif (widgetTable.type == "range") then
                ---@cast widgetTable df_menu_range

                assert(widgetTable.get, "DetailsFramework:BuildMenu: .get not found in the widget table for 'range'")
                local bIsDecimals = widgetTable.usedecimals
                local slider = detailsFramework:NewSlider(parent, nil, "$parentWidget" .. index, nil, widgetWidth or 140, widgetHeight or 18, widgetTable.min, widgetTable.max, widgetTable.step, widgetTable.get(),  bIsDecimals, nil, nil, sliderTemplate)

                local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
                DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, slider, "have_tooltip", descPhraseId, widgetTable.desc)

                local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
                slider.hasLabel = label

                local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
                DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

                maxColumnWidth, maxWidgetWidth = setRangeProperties(parent, slider, widgetTable, currentXOffset, currentYOffset, sliderTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, bIsDecimals, bAttachSliderButtonsToLeft)
                --store the widget created into the overall table and the widget by type
                table.insert(parent.widget_list, slider)
                table.insert(parent.widget_list_by_type.slider, slider)

                widgetCreated = slider
                amountLineWidgetAdded = amountLineWidgetAdded + 1

            elseif (widgetTable.type == "color") then
                ---@cast widgetTable df_menu_color
                assert(widgetTable.get, "DetailsFramework:BuildMenu: .get not found in the widget table for 'color'")
                local colorpick = detailsFramework:NewColorPickButton(parent, "$parentWidget" .. index, nil, widgetTable.set, nil, buttonTemplate)

                local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
                DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, colorpick, "have_tooltip", descPhraseId, widgetTable.desc)

                local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
                colorpick.hasLabel = label

                local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
                DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

                maxColumnWidth, maxWidgetWidth, extraPaddingY = setColorProperties(parent, colorpick, widgetTable, currentXOffset, currentYOffset, buttonTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, bUseBoxFirstOnAllWidgets, extraPaddingY)

                --store the widget created into the overall table and the widget by type
                table.insert(parent.widget_list, colorpick)
                table.insert(parent.widget_list_by_type.color, colorpick)

                widgetCreated = colorpick
                amountLineWidgetAdded = amountLineWidgetAdded + 1

            elseif (widgetTable.type == "execute") then
                ---@cast widgetTable df_menu_button
                local button = detailsFramework:NewButton(parent, nil, "$parentWidget" .. index, nil, widgetWidth or 120, widgetHeight or 18, widgetTable.func, widgetTable.param1, widgetTable.param2, nil, "", nil, buttonTemplate, textTemplate)
                button.widget_type = "execute"

                local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
                button.hasLabel = label

                local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
                DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, button.widget, namePhraseId, widgetTable.name)

                local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
                DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, button, "have_tooltip", descPhraseId, widgetTable.desc)

                maxColumnWidth, maxWidgetWidth, latestInlineWidget = setExecuteProperties(parent, button, widgetTable, currentXOffset, currentYOffset, buttonTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, textTemplate, latestInlineWidget)

                --store the widget created into the overall table and the widget by type
                table.insert(parent.widget_list, button)
                table.insert(parent.widget_list_by_type.button, button)

                widgetCreated = button
                amountLineWidgetAdded = amountLineWidgetAdded + 1

            elseif (widgetTable.type == "textentry") then
                ---@cast widgetTable df_menu_textentry
                local textentry = detailsFramework:CreateTextEntry(parent, widgetTable.func or widgetTable.set, widgetWidth or 120, widgetHeight or 18, nil, "$parentWidget" .. index, nil, buttonTemplate)
                local label = detailsFramework:NewLabel(parent, nil, "$parentLabel" .. index, nil, "", "GameFontNormal", widgetTable.text_template or textTemplate or 12)
                textentry.hasLabel = label
                textentry.align = widgetTable.align or "left"

                local descPhraseId = getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
                DetailsFramework.Language.RegisterTableKeyWithDefault(languageAddonId, textentry, "have_tooltip", descPhraseId, widgetTable.desc)

                local namePhraseId = getNamePhraseID(widgetTable, languageAddonId, languageTable, true)
                DetailsFramework.Language.RegisterObjectWithDefault(languageAddonId, label.widget, namePhraseId, formatOptionNameWithColon(widgetTable.name, useColon))

                maxColumnWidth, maxWidgetWidth = setTextEntryProperties(parent, textentry, widgetTable, currentXOffset, currentYOffset, buttonTemplate, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, textTemplate)

                --store the widget created into the overall table and the widget by type
                table.insert(parent.widget_list, textentry)
                table.insert(parent.widget_list_by_type.textentry, textentry)

                widgetCreated = textentry
                amountLineWidgetAdded = amountLineWidgetAdded + 1
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

                    amountLineWidgetAdded = 0
                    maxColumnWidth = 0
                    maxWidgetWidth = 0
                end
            else
                if (widgetTable.type == "breakline" or currentYOffset < height) then
                    currentYOffset = yOffset
                    currentXOffset = currentXOffset + maxColumnWidth + 20
                    amountLineWidgetAdded = 0
                    maxColumnWidth = 0
                end
            end
        end --no widget.hidden
    end --end loop

    if (bUseScrollFrame) then
        parent:SetHeight(biggestColumnHeight * -1)
    end

    detailsFramework.RefreshUnsafeOptionsWidgets()
    onMenuBuilt(parent)
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