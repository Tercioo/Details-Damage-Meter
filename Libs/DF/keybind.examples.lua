
    --Example file of how to create a keybind panel using the details framework

    local detailsFramework = DetailsFramework

    --a table with a list of all keybinds already set, usually this is stored in the addon saved variables, but for the example, it's just an empty table
    local keybindings = {}

    --[[
        a keybindTable store the information of a keybind set, its fields are:
        name: string -> a name to identify the keybind
        keybind: string -> the key or combination of keys that trigger the keybind, for example "CTRL-SHIFT-A"
        macro: string -> the macro text if the keybind runs a macro, if it's not a macro, this field can be nil or empty
        action: string -> which action the keybind trigger, example: a 'spellId' to cast a spell, 'macro', 'target', 'focus', 'togglemenu'
        icon: string -> an icon for the keybind
    --]]

    ---callback function that will be called when a keybind is modified, removed, or when the conditions, name, icon or macro of a keybind is changed, the parameters are:
    ---@param keybindFrame df_keybindframe
    ---@param type string "modified", "removed", "conditions", "name", "icon", "macro"
    ---@param keybindTable df_keybind?
    ---@param keybindPressed string?
    ---@param removedIndex number?
    ---@param macroText string?
    local callback = function(keybindFrame, type, keybindTable, keybindPressed, removedIndex, macroText)
        if (not keybindFrame.options.can_modify_keybind_data) then
            --the key to active the keybind has changed
            if (type == "modified") then
                ---@cast keybindTable df_keybind
                if (type(keybindPressed) == "string") then
                    --if can_modify_keybind_data is true, this part won't be necessary
                    --since the keybindTable will be already updated with the new keybindPressed value
                    keybindTable.keybind = keybindPressed
                end

            --the macro text has changed
            elseif (type == "macro") then
                ---@cast keybindTable df_keybind
                if (type(macroText) == "string") then
                    --if can_modify_keybind_data is true, this part won't be necessary
                    --it is here for an example
                    keybindTable.macro = macroText
                end

            --the keybind has been removed
            elseif (type == "removed") then
                table.remove(keybindings, removedIndex)
            end
        end
    end

    local parent = UIParent
    local frameName = "KeybindFrameName"
    local keybindOptions = {
        --when 'can_modify_keybind_data' the internal code won't change the keybindTable
        --it'll be the responsibility of the callback function to update the keybindTable
        --when a keybind is modified, removed, or when the conditions, name, icon or macro of a keybind is changed
        --this is useful when the addon want to have more control over how the keybind data is stored and updated
        --for example, if the addon want to store the keybinds in a different format or
        --if it want to have some validation before updating the keybindTable
        can_modify_keybind_data = true,

        --optional settings, values are the default ones
        width = 580,
        height = 500,
        edit_width = 400,
        edit_height = 0,
        scroll_width = 580,
        scroll_height = 480,
        amount_lines = 18,
        line_height = 26,
        show_spells = true,
        show_unitcontrols = true,
        show_macros = true,
    }

    local keybindFrame = detailsFramework:CreateKeybindFrame(parent, frameName, keybindOptions, callback, keybindings)
    keybindFrame:SetPoint("topleft", parent, "topleft", 10, -10)
