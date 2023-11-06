
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

---@cast detailsFramework detailsframework

local CreateFrame = CreateFrame
local unpack = unpack
local wipe = table.wipe
local _

--[=[
    file description: this file has the code for the object editor
    the object editor itself is a frame and has a scrollframe as canvas showing another frame where there's the options for the editing object
    
--]=]


--the editor doesn't know which key in the profileTable holds the current value for an attribute, so it uses a map table to find it.
--the mapTable is a table with the attribute name as a key, and the value is the profile key. For example, {["size"] = "text_size"} means profileTable["text_size"] = 10.

---@class df_editor_attribute
---@field name string
---@field label string
---@field widget string
---@field default any
---@field minvalue number?
---@field maxvalue number?
---@field step number?
---@field usedecimals boolean?
---@field subkey string?

--which object attributes are used to build the editor menu for each object type
local attributes = {
    ---@type df_editor_attribute[]
    FontString = {
        {
            name = "text",
            label = "Text",
            widget = "textentry",
            default = "font string text",
            setter = function(widget, value) widget:SetText(value) end,
        },
        {
            name = "size",
            label = "Size",
            widget = "range",
            minvalue = 5,
            maxvalue = 120,
            setter = function(widget, value) widget:SetFont(widget:GetFont(), value, select(3, widget:GetFont())) end
        },
        {
            name = "font",
            label = "Font",
            widget = "fontdropdown",
            setter = function(widget, value) widget:SetFont(value, select(2, widget:GetFont())) end
        },
        {
            name = "color",
            label = "Color",
            widget = "colordropdown",
            setter = function(widget, value) widget:SetTextColor(unpack(value)) end
        },
        {
            name = "alpha",
            label = "Alpha",
            widget = "range",
            setter = function(widget, value) widget:SetAlpha(value) end
        },
        {
            name = "shadow",
            label = "Draw Shadow",
            widget = "toggle",
            setter = function(widget, value) widget:SetShadowColor(widget:GetShadowColor(), select(2, widget:GetShadowColor()), select(3, widget:GetShadowColor()), value and 0.5 or 0) end
        },
        {
            name = "shadowcolor",
            label = "Shadow Color",
            widget = "colordropdown",
            setter = function(widget, value) widget:SetShadowColor(unpack(value)) end
        },
        {
            name = "shadowoffsetx",
            label = "Shadow X Offset",
            widget = "range",
            minvalue = -10,
            maxvalue = 10,
            setter = function(widget, value) widget:SetShadowOffset(value, select(2, widget:GetShadowOffset())) end
        },
        {
            name = "shadowoffsety",
            label = "Shadow Y Offset",
            widget = "range",
            minvalue = -10,
            maxvalue = 10,
            setter = function(widget, value) widget:SetShadowOffset(widget:GetShadowOffset(), value) end
        },
        {
            name = "outline",
            label = "Outline",
            widget = "outlinedropdown",
            setter = function(widget, value) widget:SetFont(widget:GetFont(), select(2, widget:GetFont()), value) end
        },
        {
            name = "anchor",
            label = "Anchor",
            widget = "anchordropdown",
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "anchoroffsetx",
            label = "Anchor X Offset",
            widget = "range",
            minvalue = -20,
            maxvalue = 20,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "anchoroffsety",
            label = "Anchor Y Offset",
            widget = "range",
            minvalue = -20,
            maxvalue = 20,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "rotation",
            label = "Rotation",
            widget = "range",
            usedecimals = true,
            minvalue = 0,
            maxvalue = math.pi*2,
            setter = function(widget, value) widget:SetRotation(value) end
        },
    }
}

local profileTable = {
    spellname_text_size = 10,
    spellname_text_font = "Arial Narrow",
    spellname_text_color = {1, 1, 1, 1},
    spellname_text_outline = "NONE",
    spellname_text_shadow_color = {0, 0, 0, 1},
    spellname_text_shadow_color_offset = {1, -1},
    spellname_text_anchor = {side = 9, x = 0, y = 0},
}

--create a map table for the profile table
local mapTable = {
    text = "text test",
    size = "spellname_text_size",
    font = "spellname_text_font",
    color = "spellname_text_color",
    outline = "spellname_text_outline",
    shadowcolor = "spellname_text_shadow_color",
    shadowoffsetx = "spellname_text_shadow_color_offset[1]",
    shadowoffsety = "spellname_text_shadow_color_offset[2]",
    anchor = "spellname_text_anchor.side",
    anchoroffsetx = "spellname_text_anchor.x",
    anchoroffsety = "spellname_text_anchor.y",
}

local table_path = {
    shadowWidth = "text_settings[1].width",
    shadowHeight = "text_settings[1].height",
    shadowEnabled = "text_settings.settings.enabled",
    text = "text_settings.settings.text.current_text",
}

local text_settings = {
    shadowWidth = {{width = 100}},
    shadowHeight = {{height = 100}},
    shadowEnabled = {settings = {enabled = true}},
    text = {settings = {text = {current_text = "hellow world"}}},
}

---@class df_editormixin : table
---@field GetEditingObject fun(self:df_editor):uiobject
---@field GetEditingProfile fun(self:df_editor):table, table
---@field GetOnEditCallback fun(self:df_editor):function
---@field GetOptionsFrame fun(self:df_editor):frame
---@field GetCanvasScrollBox fun(self:df_editor):df_canvasscrollbox
---@field EditObject fun(self:df_editor, object:uiobject, profileTable:table, profileKeyMap:table, callback:function)
---@field PrepareObjectForEditing fun(self:df_editor)

detailsFramework.EditorMixin = {
    ---@param self df_editor
    GetEditingObject = function(self)
        return self.editingObject
    end,

    ---@param self df_editor
    ---@return table, table
    GetEditingProfile = function(self)
        return self.editingProfileTable, self.editingProfileMap
    end,

    ---@param self df_editor
    ---@return function
    GetOnEditCallback = function(self)
        return self.onEditCallback
    end,

    GetOptionsFrame = function(self)
        return self.optionsFrame
    end,

    GetCanvasScrollBox = function(self)
        return self.canvasScrollBox
    end,

    ---@param self df_editor
    ---@param object uiobject
    ---@param profileTable table
    ---@param profileKeyMap table
    ---@param callback function calls when an attribute is changed with the payload: editingObject, optionName, newValue, profileTable, profileKey
    EditObject = function(self, object, profileTable, profileKeyMap, callback)
        assert(type(object) == "table", "EditObject(object) expects an UIObject on first parameter.")
        assert(type(profileTable) == "table", "EditObject(object) expects a table on second parameter.")
        assert(object.GetObjectType, "EditObject(object) expects an UIObject on first parameter.")

        self.editingObject = object
        self.editingProfileMap = profileKeyMap
        self.editingProfileTable = profileTable
        self.onEditCallback = callback

        self:PrepareObjectForEditing()
    end,

    PrepareObjectForEditing = function(self)
        --get the object and its profile table with the current values
        local object = self:GetEditingObject()
        local profileTable, profileMap = self:GetEditingProfile()
        profileMap = profileMap or {}

        if (not object or not profileTable) then
            return
        end

        --get the object type
        local objectType = object:GetObjectType()
        local attributeList

        if (objectType == "FontString") then
            attributeList = attributes[objectType]
        end

        local menuOptions = {}
        for i = 1, #attributeList do
            local option = attributeList[i]

            --get the key to be used on profile table
            local profileKey = profileMap[option.name]
            local value

            --if the key contains a dot or a bracket, it means it's a table path, example: "text_settings[1].width"
            if (profileKey and (profileKey:match("%.") or profileKey:match("%["))) then
                value = detailsFramework.table.getfrompath(profileTable, profileKey)
            else
                value = profileTable[profileKey]
            end

            --if no value is found, attempt to get a default
            value = value or option.default

            if (value) then
                menuOptions[#menuOptions+1] = {
                    type = option.widget,
                    name = option.label,
                    get = function() return value end,
                    set = function(widget, fixedValue, newValue)
                        if (profileKey and (profileKey:match("%.") or profileKey:match("%["))) then
                            detailsFramework.table.setfrompath(profileTable, profileKey, value)
                        else
                            profileTable[profileKey] = value
                        end

                        if (self:GetOnEditCallback()) then
                            self:GetOnEditCallback()(object, option.name, newValue, profileTable, profileKey)
                        end

                        if (option.name == "anchor" or option.name == "anchoroffsetx" or option.name == "anchoroffsety") then
                            local anchorTable = detailsFramework.table.getfrompath(profileTable, profileKey:gsub("%.[^.]*$", ""))
                            option.setter(object, anchorTable)
                        else
                            option.setter(object, newValue)
                        end
                    end,
                    min = option.minvalue,
                    max = option.maxvalue,
                    step = option.step,
                    usedecimals = option.usedecimals,
                }
            end
        end

        --at this point, the optionsTable is ready to be used on DF:BuildMenuVolatile()
        menuOptions.align_as_pairs = true
        menuOptions.align_as_pairs_length = 150
        menuOptions.widget_width = 180

        local optionsFrame = self:GetOptionsFrame()
        local canvasScrollBox = self:GetCanvasScrollBox()
        local bUseColon = true
        local bSwitchIsCheckbox = true
        local maxHeight = 5000

        local amountOfOptions = #menuOptions
        local optionsFrameHeight = amountOfOptions * 20
        optionsFrame:SetHeight(optionsFrameHeight)

        --templates
        local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
        local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
        local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

        detailsFramework:BuildMenu(optionsFrame, menuOptions, 0, -2, maxHeight, bUseColon, options_text_template, options_dropdown_template, options_switch_template, bSwitchIsCheckbox, options_slider_template, options_button_template)
    end,

}

local editorDefaultOptions = {
    width = 400,
    height = 600,
}

---@class df_editor : frame, df_optionsmixin, df_editormixin
---@field options table
---@field editingObject uiobject
---@field editingProfileTable table
---@field editingProfileMap table
---@field onEditCallback function
---@field optionsFrame frame
---@field canvasScrollBox df_canvasscrollbox

function detailsFramework:CreateEditor(parent, name, options)
    name = name or ("DetailsFrameworkEditor" .. math.random(100000, 10000000))
    local editorFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

    detailsFramework:Mixin(editorFrame, detailsFramework.EditorMixin)
    detailsFramework:Mixin(editorFrame, detailsFramework.OptionsFunctions)

    editorFrame:BuildOptionsTable(editorDefaultOptions, options)

    editorFrame:SetSize(editorFrame.options.width, editorFrame.options.height)

    --options frame is the frame that holds the options for the editing object, it is used as the parent frame for BuildMenuVolatile()
    local optionsFrame = CreateFrame("frame", name .. "OptionsFrame", editorFrame, "BackdropTemplate")
    optionsFrame:SetSize(editorFrame.options.width, 5000)

    local canvasFrame = detailsFramework:CreateCanvasScrollBox(editorFrame, optionsFrame, name .. "CanvasScrollBox")
    canvasFrame:SetAllPoints()

    editorFrame.optionsFrame = optionsFrame
    editorFrame.canvasScrollBox = canvasFrame

    return editorFrame
end
