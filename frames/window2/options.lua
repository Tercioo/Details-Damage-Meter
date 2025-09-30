
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@type details_allinonewindow
local AllInOneWindow = Details222.AllInOneWindow


---@class details_allinonewindow_optionspanel : frame
---@field WindowFrame details_allinonewindow
---@field HeaderOptionsFrame frame

local optionsPanel

---@type details_allinonewindow_frame
local editingWindowFrame

--this file creates the options panel for the window2


--function to open the options panel, if the options panel isn't created yet, create it
function AllInOneWindow:OpenOptionsPanel(windowFrame)
    editingWindowFrame = windowFrame

    if (not optionsPanel) then
        AllInOneWindow:CreateOptionsPanel()
    end

    optionsPanel.WindowFrame = windowFrame

    AllInOneWindow:RefreshOptionsPanel()

    if (optionsPanel:IsShown()) then
        optionsPanel:Hide()
    else
        optionsPanel:Show()
    end
end

--this function refreshes the options panel using the settings of the window that invoked the options panel
function AllInOneWindow:RefreshOptionsPanel()
    if (not optionsPanel) then
        return
    end

    local headerOptionsFrame = optionsPanel.HeaderOptionsFrame
    local headerCheckboxes = headerOptionsFrame.ColumnCheckboxes
    local headerIconCheckboxes = headerOptionsFrame.ColumnIconCheckboxes
    local headersNamesActive = editingWindowFrame:GetHeaderNames()

    for i = 1, #headerCheckboxes do
        local checkbox = headerCheckboxes[i]
        local columnName = checkbox.columnName

        if (detailsFramework.table.find(headersNamesActive, columnName)) then
            checkbox:SetValue(true)
        else
            checkbox:SetValue(false)
        end
    end

    local columnShowIcon = editingWindowFrame.settings.header.column_show_icon
    local columnShowText = editingWindowFrame.settings.header.column_show_text

    for i = 1, #headerIconCheckboxes do
        local checkboxShowIcon = headerIconCheckboxes[i]
        local columnName = checkboxShowIcon.columnName

        if (columnShowIcon[columnName] == nil) then
            columnShowIcon[columnName] = true
        end
        if (columnShowIcon[columnName]) then
            checkboxShowIcon:SetValue(true)
        else
            checkboxShowIcon:SetValue(false)
        end

        if (columnShowText[columnName] == nil) then
            columnShowText[columnName] = AllInOneWindow:GetColumnData(columnName).showText
        end
        local checkboxShowText = headerOptionsFrame.ColumnTextCheckboxes[i]
        if (columnShowText[columnName]) then
            checkboxShowText:SetValue(true)
        else
            checkboxShowText:SetValue(false)
        end
    end

    optionsPanel:RefreshOptions()
end

--function to create the options panel, it'll be called from the open function if the panel isn't created yet
function AllInOneWindow:CreateOptionsPanel()
    optionsPanel = CreateFrame("frame", "DetailsAllInOneWindowOptionsPanel", UIParent, "BackdropTemplate")
    optionsPanel:SetSize(600, 400)
    optionsPanel:SetPoint("center", UIParent, "center", 0, 0)
    optionsPanel:SetFrameStrata("HIGH")

    detailsFramework:ApplyStandardBackdrop(optionsPanel)
    detailsFramework:MakeDraggable(optionsPanel)

    detailsFramework:CreateTitleBar(optionsPanel, "Details! All-in-One Window Options")
    detailsFramework:CreateRightClickToClose(optionsPanel)

    optionsPanel:SetScript("OnMouseUp", function(self, button)
        if (button == "RightButton") then
            self:Hide()
        end
    end)

    local headerOptionsFrame = CreateFrame("frame", "$parentHeaderOptionsFrame", optionsPanel, "BackdropTemplate")
    headerOptionsFrame:SetPoint("topleft", optionsPanel, "topleft", 2, -30)
    headerOptionsFrame:SetPoint("bottomright", optionsPanel, "bottomright", -2, 2)
    --detailsFramework:ApplyStandardBackdrop(headerOptionsFrame)
    optionsPanel.HeaderOptionsFrame = headerOptionsFrame

    local headerOptionsLabel = detailsFramework:CreateLabel(headerOptionsFrame, "Which Information To Show", 12, "orange")
    headerOptionsLabel:SetPoint("topleft", headerOptionsFrame, "topleft", 2, -2)

    ---@type details_allinonewindow_headercolumndata[]
    local allColumnData = AllInOneWindow.HeaderColumnData

    --headers shown in the window that invoked the options panel
    --

    --the AllInOneWindow.HeaderColumnData table has a fixed order, when a column name get removed and added back, it is added at the end of the list, this function get the columnName added and place in the correct index following the order of the AllInOneWindow.HeaderColumnData table
    local putColumnNamesInOrder = function(columnName)
        local windowFrame = optionsPanel.WindowFrame
        local columnDataKeyToIndex = windowFrame.settings.header.column_order
        local headersNamesActive = optionsPanel.WindowFrame:GetHeaderNames()

        table.sort(headersNamesActive, function(a, b)
            return columnDataKeyToIndex[a] < columnDataKeyToIndex[b]
        end)
    end

    local onToggleColumnDataVisibility = function(checkbox, fixedValue, state)
        local columnNameToBeRemoved = checkbox.columnName
        local windowFrame = optionsPanel.WindowFrame
        local headersNamesActive = windowFrame:GetHeaderNames()

        if (state) then
            detailsFramework.table.addunique(headersNamesActive, columnNameToBeRemoved)
            putColumnNamesInOrder()
        else
            --get the current selected header column
            local selectedColumnName = windowFrame:GetSelectedColumnName()
            --windowFrame:SetSelectedColumnName(columnHeader.key)
            --the table containing the column names currently shown in the window
            if (selectedColumnName == columnNameToBeRemoved) then
                local foundNewSelectedColumn = false
                for i = 1, #headersNamesActive do
                    local thisColumnName = headersNamesActive[i]
                    if (thisColumnName ~= columnNameToBeRemoved) then
                        local thisColumnData = self:GetColumnData(thisColumnName)
                        if (thisColumnData and thisColumnData.canSort) then
                            windowFrame:SetSelectedColumnName(thisColumnName)
                            foundNewSelectedColumn = true
                            break
                        end
                    end
                end

                if (not foundNewSelectedColumn) then
                    print("No other column available to be selected, the window will brick.")
                end
            end

            detailsFramework.table.remove(headersNamesActive, columnNameToBeRemoved)
        end

        AllInOneWindow:RefreshHeader(windowFrame)
        AllInOneWindow:RefreshWindow(windowFrame)
    end

    local onToggleColumnIconVisibility = function(checkbox, fixedValue, state)
        local columnNameToBeChanged = checkbox.columnName
        local windowFrame = optionsPanel.WindowFrame
        local column_show_icon = windowFrame.settings.header.column_show_icon

        if (state) then
            column_show_icon[columnNameToBeChanged] = true
        else
            column_show_icon[columnNameToBeChanged] = false
        end

        AllInOneWindow:RefreshHeader(windowFrame)
        AllInOneWindow:RefreshWindow(windowFrame)
    end

    local onToggleColumnTextVisibility = function(checkbox, fixedValue, state)
        local columnNameToBeChanged = checkbox.columnName
        local windowFrame = optionsPanel.WindowFrame
        local column_show_text = windowFrame.settings.header.column_show_text

        if (state) then
            column_show_text[columnNameToBeChanged] = true
        else
            column_show_text[columnNameToBeChanged] = false
        end

        AllInOneWindow:RefreshHeader(windowFrame)
        AllInOneWindow:RefreshWindow(windowFrame)
    end

    headerOptionsFrame.ColumnCheckboxes = {}
    headerOptionsFrame.ColumnIconCheckboxes = {}
    headerOptionsFrame.ColumnTextCheckboxes = {}

    --iterate among allColumnData and create a checkbox for each column that area available to toggle by the field 'shownOnOptions'
    local amountAdded = 0
    for i, columnData in ipairs(allColumnData) do
        if (columnData.shownOnOptions) then
            local columnDataVisibilitySwitch = DetailsFramework:CreateSwitch(headerOptionsFrame, onToggleColumnDataVisibility, false, _, _, _, _, "ColumnCheckbox" .. i, _, _, _, _, _, DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
            columnDataVisibilitySwitch:SetAsCheckBox()
            columnDataVisibilitySwitch:SetPoint("topleft", headerOptionsLabel, "bottomleft", 2, -5 - (amountAdded) * 25)
            columnDataVisibilitySwitch.columnName = columnData.name
            local columnDataVisibilityLabel = DetailsFramework:CreateLabel(headerOptionsFrame, columnData.text or columnData.key)
            columnDataVisibilityLabel:SetPoint("left", columnDataVisibilitySwitch, "right", 2, 0)
            headerOptionsFrame.ColumnCheckboxes[#headerOptionsFrame.ColumnCheckboxes + 1] = columnDataVisibilitySwitch
            amountAdded = amountAdded + 1

            --checkbox for icon
            local columnDataShowIcon = DetailsFramework:CreateSwitch(headerOptionsFrame, onToggleColumnIconVisibility, false, _, _, _, _, "ColumnIconCheckbox" .. i, _, _, _, _, _, DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
            columnDataShowIcon:SetAsCheckBox()
            columnDataShowIcon:SetPoint("left", columnDataVisibilitySwitch, "right", 100, 0)
            columnDataShowIcon.columnName = columnData.name
            local columnDataShowIconLabel = DetailsFramework:CreateLabel(headerOptionsFrame, "Icon")
            columnDataShowIconLabel:SetPoint("left", columnDataShowIcon, "right", 2, 0)
            headerOptionsFrame.ColumnIconCheckboxes[#headerOptionsFrame.ColumnIconCheckboxes + 1] = columnDataShowIcon

            --checkbox for text
            local columnDataShowText = DetailsFramework:CreateSwitch(headerOptionsFrame, onToggleColumnTextVisibility, false, _, _, _, _, "ColumnTextCheckbox" .. i, _, _, _, _, _, DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
            columnDataShowText:SetAsCheckBox()
            columnDataShowText:SetPoint("left", columnDataShowIcon, "right", 60, 0)
            columnDataShowText.columnName = columnData.name
            local columnDataShowTextLabel = DetailsFramework:CreateLabel(headerOptionsFrame, "Text")
            columnDataShowTextLabel:SetPoint("left", columnDataShowText, "right", 2, 0)
            headerOptionsFrame.ColumnTextCheckboxes[#headerOptionsFrame.ColumnTextCheckboxes + 1] = columnDataShowText
        end
    end

    local options = {
        {type = "label", get = function() return "Layout" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
        --line amount
        {
            type = "range",
            get = function() return editingWindowFrame.settings.window.line_amount end,
            set = function(self, fixedparam, value)
                editingWindowFrame.settings.window.line_amount = value
                AllInOneWindow:RefreshWindowLayout(editingWindowFrame)
            end,
            min = 1,
            max = 40,
            step = 1,
            name = "Line Amount",
        },

        --line height
        {
            type = "range",
            get = function() return editingWindowFrame.settings.lines.height end,
            set = function(self, fixedparam, value)
                editingWindowFrame.settings.lines.height = value
                AllInOneWindow:RefreshWindowLayout(editingWindowFrame)
            end,
            min = 10,
            max = 100,
            step = 1,
            name = "Line Height",
        },

        --text size
        {
            type = "range",
            get = function() return editingWindowFrame.settings.lines.text_size end,
            set = function(self, fixedparam, value)
                editingWindowFrame.settings.lines.text_size = value
                AllInOneWindow:RefreshWindowLayout(editingWindowFrame)
            end,
            min = 6,
            max = 30,
            step = 1,
            name = "Text Size",
        },


    }

    local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

    detailsFramework:BuildMenu(optionsPanel, options, 300, -30, 500, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

    optionsPanel:Hide()
end