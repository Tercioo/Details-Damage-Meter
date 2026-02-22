---@type detailsframework
local DF = DetailsFramework

---1º example: a simple dropdown usage example:

---a random function to be used as a callback for the dropdown options, this is just an example to show how the onclick function of the dropdown options works, in a real scenario you would replace this with your actual function that does something useful when an option is selected
local toggleRecording = function()
    ToggleRecording()
end

---the 'func' parameters on CreateDropDown is a function which will return a table to fill the dropdown options, this is useful when the dropdown options are dynamic and can change during the addon usage, when the dropdown is shown it will call this function to get the options to show, and when an option is selected it will call the 'onclick' function of that option if it exists, passing the dropdown object, the fixed value and the option value as parameters
local createAdvancedOptionsFunction = function()
    ---@class dropdownoption : table
    ---@field value any
    ---@field label string text shown in the dropdown option
    ---@field onclick fun(dropdownObject:table, fixedValue:any, value:any)? function to call when the option is selected
    ---@field icon string|number? texture
    ---@field iconcolor any any color format
    ---@field iconsize number[]? width, height
    ---@field texcoord number[]? left, right, top, bottom
    ---@field color any any color format
    ---@field font string?
    ---@field languageId string?
    ---@field rightbutton function? function to call on right click
    ---@field statusbar string|number? statusbar texture
    ---@field statusbarcolor any any color format
    ---@field rightTexture string|number? texture
    ---@field centerTexture string|number? texture

    ---@type dropdownoption[]
    local options = {
        {value = 0, label = "For Nerds", onclick = function(dropdownObject, fixedValue, value) OpenAdvancedOptions() end, icon = [[Interface\ICONS\Spell_Shadow_Brainwash]], iconsize = {17, 17}, texcoord = {0.05, 0.95, 0.05, 0.95}},
        {value = 1, label = "Open Debug Window", onclick = function(dropdownObject, fixedValue, value) OpenDebugWindow() end, icon = [[Interface\HELPFRAME\HelpIcon-Bug]], iconsize = {17, 17}, texcoord = {0.2, 0.8, 0.2, 0.8}},
        {value = 3, label = "Record Times", onclick = function(dropdownObject, fixedValue, value) ToggleRecording() end, icon = [[Interface\AddOns\RCP_CDAssignment\Assets\Textures\Icon\record.png]], iconsize = {17, 17}, texcoord = {0.05, 0.95, 0.05, 0.95}},
    }
    return options
end

---create a dropdown object with UIParent as the parent frame, createAdvancedOptionsFunction as the function that returns the dropdown options, 1 as the default value, 160 as the width and 20 as the height
---@param parent frame
---@param func function
---@param default any
---@param width number?
---@param height number?
---@param member string?
---@param name string?
---@param template table?
---@return df_dropdown
local advancedFeatures = DF:CreateDropDown(UIParent, createAdvancedOptionsFunction, 1, 160, 20, "advancedFeaturesDropdown", "DropdownForAdvancedFeatures", DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
---fixed parameters are parameters that will be passed to the onclick function of the dropdown options when they are selected, this is useful when you want to pass some context to the onclick function without having to create a closure or a new function for each option, in this example we are passing the string "advanced_settings_dropdown" as a fixed parameter to all options in the dropdown, so when an option is selected and its onclick function is called, it will receive this string as the second parameter (the first parameter is the dropdown object itself and the third parameter is the option value)
--- it also is useful if more than one dropdown use the same onclick function and you want to know which dropdown is calling the function, in this case you can pass a different fixed parameter for each dropdown and check it in the onclick function to know which dropdown is calling it
advancedFeatures:SetFixedParameter("advanced_settings_dropdown")

---2º example: a more complex dropdown example with dynamic options based on the raid instances and encounters from the dungeon journal:

---callback for the encounter selector dropdown
---@param dropdownObject df_dropdown
---@param fixedParam nil
---@param journalEncounterId journalencounterid
local onSelectBoss = function(dropdownObject, fixedParam, journalEncounterId)
    private.debug.print("encounter selected:", journalEncounterId)

    --with the journalEncounterId of the encounter, find the journalInstanceId of the instance that contains this encounter
    local allInstances = DF.Ejc.GetAllRaidInstances()
    for i = 1, #allInstances do
        local instanceData = allInstances[i]
        local allEncounters = DF.Ejc.GetAllEncountersFromInstance(instanceData.journalInstanceId)
        for j = 1, #allEncounters do
            local thisEncounter = allEncounters[j]
            if (thisEncounter.journalEncounterId == journalEncounterId) then
                private.addon.profile.selected_journalinstance_id = instanceData.journalInstanceId
                private.addon.profile.journalencounterid_lastselected_forinstance[instanceData.journalInstanceId] = journalEncounterId
                --saveLastSelectedEncounterForInstance(instanceData.journalInstanceId, journalEncounterId)
                break
            end
        end
    end

    assignment.RefreshTimeline()
end

---an example of a complex dropdown, this dropdown will show all raid encounters from the dungeon journal, when an encounter is selected it will save the selected encounter id in the profile and also save the last selected encounter for the instance that contains this encounter, so when the user opens the dropdown again it will show the last selected encounter for each instance as selected, this is useful because it allows the user to quickly switch between encounters of the same instance without having to select the instance first and then select the encounter, it also allows the user to see which encounter was last selected for each instance at a glance
local createEncounterSelectorOptionsFunction = function()
    ---@type dropdownoption[]
    local options = {}

    local currentRaidTierId = 1

    local allInstances = DF.Ejc.GetAllRaidInstances()
    for i = 1, #allInstances do
        local instanceData = allInstances[i]

        --get all encounters from this instance
        local allEncounters = DF.Ejc.GetAllEncountersFromInstance(instanceData.journalInstanceId)
        for j = 1, #allEncounters do
            local thisEncounter = allEncounters[j]
            --make dropdown option
            ---@type dropdownoption
            local option = {
                value = thisEncounter.journalEncounterId,
                label = thisEncounter.name,
                onclick = onSelectBoss,
                selected = private.addon.profile.journalencounterid_lastselected_forinstance[instanceData.journalInstanceId] == thisEncounter.journalEncounterId,
                icon = thisEncounter.creatureIcon,
                texcoord = thisEncounter.creatureIconCoords,
                iconsize = {34, 18},
                color = currentRaidTierId == i and {1, 1, 1, 1} or {0.5, 0.5, 0.5, 1}, --white or gray
            }
            table.insert(options, option)
        end
    end
    return options
end

---encounter selector
local journalInstanceId = private.addon.profile.selected_journalinstance_id
local journalEncounterId = getLastSelectedEncounterForInstance(journalInstanceId)

local encounterSelectorDropdown = DF:CreateDropDown(assignmentMainFrame, createEncounterSelectorOptionsFunction, 1, 200, 20, "AssignmentDropdown")
encounterSelectorDropdown:SetPoint("topright", assignmentMainFrame, "topright", -2, -30)
---post creation template application
encounterSelectorDropdown:SetTemplate(private.templates.dropdown)
---post creation option selection
encounterSelectorDropdown:Select(journalEncounterId)


---3º example: an even more complex dropdown example with dynamic options and secondary buttons:
---assignemnt dropdown selection, this is the onclick function for when the an option is selected
local onSelectAssignment = function(self, fixedParameter, encounterData)
    local journalInstanceId, journalEncounterId = private.encounter.GetInstanceAndEncounterJournalId()
    private.assignment.SetLatestAssignmentNameAndIdSelectedForEncounter(journalInstanceId, journalEncounterId, encounterData.name, encounterData.id)
    assignment.RefreshTimeline()
end

---this function creates a table of dropdown options based on the 'assignments' created for the 'current encounter'.
---this example also shows the usage of the 'rightbutton' key in the dropdown option to create a secondary button for each option
---shows how to create a 'fake' separator by using an option with an empty label and no onclick function
---also shows that a dropdown option can be used to add/create new data, useful in cases where you don't want to create a button to create new data
local createAssignmentOptionsFunction = function(dropdownObject)
    ---@cast dropdownObject df_dropdown
    ---@type dropdownoption[]
    local options = {}

    local journalInstanceId, journalEncounterId = private.encounter.GetInstanceAndEncounterJournalId()
    local allEncounterData = private.encounter.GetAllEncounterDataById(journalInstanceId, journalEncounterId)

    local lastAssignmentName, lastAssingmentId = private.assignment.GetLatestAssignmentNameAndIdSelectedForEncounter(journalEncounterId)

    for i = 1, #allEncounterData do
        local encounterData = allEncounterData[i]

        ---@type dropdownoption
        local option = {
            ---the value passed to the onclick function when this option is selected
            value = encounterData,
            ---the text shown in the dropdown option
            label = encounterData.name,
            ---the function called when this option is selected, it receives the dropdown object, the fixed parameter set for the dropdown and the option value as parameters
            onclick = onSelectAssignment,
            ---if this option is selected by default
            selected = lastAssingmentId == encounterData.id,
            ---the icon shown in the dropdown option, this can be a texture path or a texture id
            icon = [[Interface\AddOns\RCP_CDAssignment\Assets\Textures\Icon\assignment_normal.png]],
            ---the size of the icon, this is optional and if not set it will use the default size of 16x16
            iconsize = {14, 14},
            ---when the dropdown option has the key 'rightbutton' an extra button will be shown on the right side of the option, this button can be used for a secondary action related to the option, in this example we are using it to show a delete button, so the user can select the option in the dropdown or delete the option if clicked in the right button
            rightbutton = function(rightButton, dropdownButton, optionTable)
                ---@cast rightButton df_button
                ---@cast optionTable dropdownoption
                rightButton:Show()
                rightButton:SetBackdrop(nil)
                rightButton:ClearAllPoints()
                rightButton:SetPoint("right", dropdownButton, "right", 6, 0)
                --set the icon to be an X, in this context is to delete the assignment
                rightButton:SetIcon("common-search-clearbutton", 10, 10, nil, nil, {.5, .5, .5, .5}, nil, 6)
                rightButton.icon:SetAlpha(0.4)
                rightButton:SetClickFunction(function()
                    DF:ShowPromptPanel(format("Confirm delete %s timeline.", optionTable.value.name), function()
                        --print(journalInstanceId, journalEncounterId, optionTable.value.id, optionTable.value.name)
                        private.assignment.RemoveAssignmentById(journalInstanceId, journalEncounterId, optionTable.value.id)
                        assignment.RefreshTimeline()
                        assignment.RefreshAssignmentDropdown()
                        dropdownObject:Close()
                    end,
                    function()
                        dropdownObject:Close()
                    end)
                end)
            end,
            ---icon shown in the right button
            rightbuttonicon = [[Interface\BUTTONS\UI-OptionsButton]],
        }

        ---add the option to the options table that will be returned by the function that creates the dropdown options
        table.insert(options, option)
    end

    ---a line with no label and an empty onclick function to be used as a separator, when the dropdown options is shown this line will be empty giving the impression of a separator
    table.insert(options, {value = 0, label = "", onclick = function()end})

    table.insert(options, {value = -1, label = L["S_CREATE_NEW_ASSIGNMENT"], onclick = assignment.ShowCreateNewAssignmentPanel})

    return options
end

local assignmentDropdown = DF:CreateDropDown(assignmentMainFrame, createAssignmentOptionsFunction, 1, 200, 20, "AssignmentDropdown")
assignmentDropdown:SetPoint("topright", encounterSelectorDropdown, "topleft", -31, 0)
assignmentDropdown:SetTemplate(private.templates.dropdown)

---set the size of the dropdown menu
assignmentDropdown:SetMenuSize(500, 400)
local width, height = assignmentDropdown:GetMenuSize()
---set the function for dropdown options creation, it replaces the 'createAssignmentOptionsFunction' in the example above
assignmentDropdown:SetFunction(function() return {} end)
local optionCreationFunction = assignmentDropdown:GetFunction()
---the value of the currently selected option in the dropdown
local currentValue = assignmentDropdown:GetValue()
---in case it need to override the value of the currently selected option without triggering the onclick function of the option
assignmentDropdown:SetValue("hello world")
local isEnabled = assignmentDropdown:IsEnabled()
assignmentDropdown:Enable()
assignmentDropdown:Disable()
assignmentDropdown:SetFixedParameter("NewValue")
local fixedParamenter = assignmentDropdown:GetFixedParameter()
---return the frames already created to show the options
local frames = assignmentDropdown:GetMenuFrames()
---call the function to create the dropdown options, in the example above it'll call 'createAssignmentOptionsFunction'
assignmentDropdown:Refresh()






