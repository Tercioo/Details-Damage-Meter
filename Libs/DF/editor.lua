
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

---@class df_editor : frame, df_optionsmixin, df_editormixin
---@field options table
---@field registeredObjects df_editor_objectinfo[]
---@field registeredObjectsByID table<any, df_editor_objectinfo>
---@field editingObject uiobject
---@field editingProfileTable table
---@field editingProfileMap table
---@field editingOptions df_editobjectoptions
---@field editingExtraOptions table
---@field moverGuideLines table<string, texture>
---@field onEditCallback function
---@field optionsFrame frame
---@field overTheTopFrame frame
---@field objectSelector df_scrollbox
---@field moverFrame frame
---@field canvasScrollBox df_canvasscrollbox

---@class df_editor_attribute
---@field key string?
---@field label string?
---@field widget string
---@field default any?
---@field minvalue number?
---@field maxvalue number?
---@field step number?
---@field usedecimals boolean?
---@field subkey string?

---@class df_editor_objectinfo : table
---@field object uiobject
---@field label string
---@field id any
---@field profiletable table
---@field profilekeymap table
---@field subtablepath string?
---@field extraoptions table
---@field callback function?
---@field options df_editobjectoptions
---@field selectButton button

--which object attributes are used to build the editor menu for each object type
local attributes = {
    ---@type df_editor_attribute[]
    Texture = {
        {
            key = "texture",
            label = "Texture",
            widget = "textentry",
            default = "",
            setter = function(widget, value) widget:SetTexture(value) end,
        },
        {
            key = "width",
            label = "Width",
            widget = "range",
            minvalue = 5,
            maxvalue = 120,
            setter = function(widget, value) widget:SetWidth(value) end
        },
        {
            key = "height",
            label = "Height",
            widget = "range",
            minvalue = 5,
            maxvalue = 120,
            setter = function(widget, value) widget:SetHeight(value) end
        },
        {widget = "blank"},
        {
            key = "anchor",
            label = "Anchor",
            widget = "anchordropdown",
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            key = "anchoroffsetx",
            label = "Anchor X Offset",
            widget = "range",
            minvalue = -20,
            maxvalue = 20,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            key = "anchoroffsety",
            label = "Anchor Y Offset",
            widget = "range",
            minvalue = -20,
            maxvalue = 20,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
    },

    FontString = {
        {
            key = "text",
            label = "Text",
            widget = "textentry",
            default = "font string text",
            setter = function(widget, value) widget:SetText(value) end,
        },
        {
            key = "size",
            label = "Size",
            widget = "range",
            minvalue = 5,
            maxvalue = 120,
            setter = function(widget, value) widget:SetFont(widget:GetFont(), value, select(3, widget:GetFont())) end
        },
        {
            key = "font",
            label = "Font",
            widget = "fontdropdown",
            setter = function(widget, value)
                local font = LibStub:GetLibrary("LibSharedMedia-3.0"):Fetch("font", value)
                widget:SetFont(font, select(2, widget:GetFont()))
            end
        },
        {
            key = "color",
            label = "Color",
            widget = "color",
            setter = function(widget, value) widget:SetTextColor(unpack(value)) end
        },
        {
            key = "alpha",
            label = "Alpha",
            widget = "range",
            setter = function(widget, value) widget:SetAlpha(value) end
        },
        {widget = "blank"},
        {
            key = "shadow",
            label = "Draw Shadow",
            widget = "toggle",
            setter = function(widget, value) widget:SetShadowColor(widget:GetShadowColor(), select(2, widget:GetShadowColor()), select(3, widget:GetShadowColor()), value and 0.5 or 0) end
        },
        {
            key = "shadowcolor",
            label = "Shadow Color",
            widget = "color",
            setter = function(widget, value) widget:SetShadowColor(unpack(value)) end
        },
        {
            key = "shadowoffsetx",
            label = "Shadow X Offset",
            widget = "range",
            minvalue = -10,
            maxvalue = 10,
            setter = function(widget, value) widget:SetShadowOffset(value, select(2, widget:GetShadowOffset())) end
        },
        {
            key = "shadowoffsety",
            label = "Shadow Y Offset",
            widget = "range",
            minvalue = -10,
            maxvalue = 10,
            setter = function(widget, value) widget:SetShadowOffset(widget:GetShadowOffset(), value) end
        },
        {
            key = "outline",
            label = "Outline",
            widget = "outlinedropdown",
            setter = function(widget, value) widget:SetFont(widget:GetFont(), select(2, widget:GetFont()), value) end
        },
        {widget = "blank"},
        {
            key = "anchor",
            label = "Anchor",
            widget = "anchordropdown",
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            key = "anchoroffsetx",
            label = "Anchor X Offset",
            widget = "range",
            minvalue = -20,
            maxvalue = 20,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            key = "anchoroffsety",
            label = "Anchor Y Offset",
            widget = "range",
            minvalue = -20,
            maxvalue = 20,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            key = "rotation",
            label = "Rotation",
            widget = "range",
            usedecimals = true,
            minvalue = 0,
            maxvalue = math.pi*2,
            setter = function(widget, value) widget:SetRotation(value) end
        },
        {
            key = "scale",
            label = "Scale",
            widget = "range",
            usedecimals = true,
            minvalue = 0.65,
            maxvalue = 2.5,
            setter = function(widget, value) widget:SetScale(value) end
        },
    }
}

---@class df_editormixin : table
---@field GetAllRegisteredObjects fun(self:df_editor):df_editor_objectinfo[]
---@field GetEditingObject fun(self:df_editor):uiobject
---@field GetEditingOptions fun(self:df_editor):df_editobjectoptions
---@field GetExtraOptions fun(self:df_editor):table
---@field GetEditingProfile fun(self:df_editor):table, table
---@field GetOnEditCallback fun(self:df_editor):function
---@field GetOptionsFrame fun(self:df_editor):frame
---@field GetCanvasScrollBox fun(self:df_editor):df_canvasscrollbox
---@field GetObjectSelector fun(self:df_editor):df_scrollbox
---@field EditObject fun(self:df_editor, object:uiobject, profileTable:table?, profileKeyMap:table?, extraOptions:table?, callback:function?, options:df_editobjectoptions?)
---@field PrepareObjectForEditing fun(self:df_editor)
---@field CreateMoverGuideLines fun(self:df_editor)
---@field GetOverTheTopFrame fun(self:df_editor):frame
---@field GetMoverFrame fun(self:df_editor):frame
---@field StartObjectMovement fun(self:df_editor, anchorSettings:df_anchor)
---@field StopObjectMovement fun(self:df_editor)
---@field RegisterObject fun(self:df_editor, object:uiobject, localizedLabel:string, id:any, profileTable:table, subTablePath:string, profileKeyMap:table, extraOptions:table?, callback:function?, options:df_editobjectoptions?):df_editor_objectinfo
---@field UnregisterObject fun(self:df_editor, object:uiobject)
---@field EditObjectById fun(self:df_editor, id:any)
---@field EditObjectByIndex fun(self:df_editor, index:number)
---@field UpdateGuideLinesAnchors fun(self:df_editor)
---@field GetObjectByRef fun(self:df_editor, object:uiobject):df_editor_objectinfo
---@field GetObjectByIndex fun(self:df_editor, index:number):df_editor_objectinfo
---@field GetObjectById fun(self:df_editor, id:any):df_editor_objectinfo
---@field CreateObjectSelectionList fun(self:df_editor, scroll_width:number, scroll_height:number, scroll_lines:number, scroll_line_height:number):df_scrollbox
---@field OnHide fun(self:df_editor)
---@field UpdateProfileTableOnAllRegisteredObjects fun(self:df_editor, profileTable:table)
---@field GetProfileTableFromObject fun(self:df_editor, object:df_editor_objectinfo):table

---@class df_editobjectoptions : table
---@field use_colon boolean if true a colon is shown after the option name
---@field can_move boolean if true the object can be moved
---@field use_guide_lines boolean if true guide lines are shown when the object is being moved
---@field text_template table

---@type df_editobjectoptions
local editObjectDefaultOptions = {
    use_colon = false,
    can_move = true,
    use_guide_lines = true,
    text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"),
}

local getParentTable = function(profileTable, profileKey)
    local parentPath
    if (profileKey:match("%]$")) then
        parentPath = profileKey:gsub("%s*%[.*%]%s*$", "")
    else
        parentPath = profileKey:gsub("%.[^.]*$", "")
    end

    local parentTable = detailsFramework.table.getfrompath(profileTable, parentPath)
    return parentTable
end

detailsFramework.EditorMixin = {
    ---@param self df_editor
    GetEditingObject = function(self)
        return self.editingObject
    end,

    ---@param self df_editor
    ---@return df_editobjectoptions
    GetEditingOptions = function(self)
        return self.editingOptions
    end,

    ---@param self df_editor
    ---@return table
    GetExtraOptions = function(self)
        return self.editingExtraOptions
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

    GetOverTheTopFrame = function(self)
        return self.overTheTopFrame
    end,

    GetMoverFrame = function(self)
        return self.moverFrame
    end,

    GetCanvasScrollBox = function(self)
        return self.canvasScrollBox
    end,

    GetObjectSelector = function(self)
        return self.objectSelector
    end,

    EditObjectById = function(self, id)
        ---@type df_editor_objectinfo
        local objectRegistered = self:GetObjectById(id)
        assert(type(objectRegistered) == "table", "EditObjectById() object not found.")
        self:EditObject(objectRegistered)
        self.objectSelector:RefreshMe()
    end,

    EditObjectByIndex = function(self, index)
        ---@type df_editor_objectinfo
        local objectRegistered = self:GetObjectByIndex(index)
        assert(type(objectRegistered) == "table", "EditObjectById() object not found.")
        self:EditObject(objectRegistered)
        self.objectSelector:RefreshMe()
    end,

    ---@param self df_editor
    ---@param registeredObject df_editor_objectinfo
    EditObject = function(self, registeredObject)
        --clear previous values
        self.editingObject = nil
        self.editingProfileMap = nil
        self.editingProfileTable = nil
        self.editingOptions = nil
        self.editingExtraOptions = nil
        self.onEditCallback = nil

        local object = registeredObject.object
        local profileKeyMap = registeredObject.profilekeymap
        local extraOptions = registeredObject.extraoptions
        local callback = registeredObject.callback
        local options = registeredObject.options

        local profileTable = self:GetProfileTableFromObject(registeredObject)
        assert(type(profileTable) == "table", "EditObject() profileTable is invalid.")

        --as there's no other place which this members are set, there is no need to create setter functions
        self.editingObject = object
        self.editingProfileMap = profileKeyMap
        self.editingProfileTable = profileTable
        self.editingOptions = options
        self.editingExtraOptions = extraOptions

        if (type(callback) == "function") then
            self.onEditCallback = callback
        end

        self:PrepareObjectForEditing()
    end,

    ---@param self df_editor
    CreateMoverGuideLines = function(self)
        local overTheTopFrame = self:GetOverTheTopFrame()
        local moverFrame = self:GetMoverFrame()

        self.moverGuideLines = {
            left = overTheTopFrame:CreateTexture(nil, "overlay"),
            right = overTheTopFrame:CreateTexture(nil, "overlay"),
            top = overTheTopFrame:CreateTexture(nil, "overlay"),
            bottom = overTheTopFrame:CreateTexture(nil, "overlay"),
        }

        for side, texture in pairs(self.moverGuideLines) do
            texture:SetColorTexture(.8, .8, .8, 0.1)
            texture:SetSize(1, 1)
            texture:SetDrawLayer("overlay", 7)
            texture:Hide()

            if (side == "left" or side == "right") then
                texture:SetHeight(1)
                texture:SetWidth(GetScreenWidth())
            else
                texture:SetWidth(1)
                texture:SetHeight(GetScreenHeight())
            end
        end
    end,

    UpdateGuideLinesAnchors = function(self)
        local object = self:GetEditingObject()

        for side, texture in pairs(self.moverGuideLines) do
            texture:ClearAllPoints()
            if (side == "left" or side == "right") then
                if (side == "left") then
                    texture:SetPoint("right", object, "left", -2, 0)
                else
                    texture:SetPoint("left", object, "right", 2, 0)
                end
            else
                if (side == "top") then
                    texture:SetPoint("bottom", object, "top", 0, 2)
                else
                    texture:SetPoint("top", object, "bottom", 0, -2)
                end
            end
        end
    end,

    PrepareObjectForEditing = function(self) --~edit
        --get the object and its profile table with the current values
        local object = self:GetEditingObject()
        local profileTable, profileMap = self:GetEditingProfile()
        profileMap = profileMap or {}

        local conditionalKeys = profileMap.enable_if or {}

        if (not object or not profileTable) then
            return
        end

        --get the object type
        local objectType = object:GetObjectType()
        local attributeList

        --get options and extra options
        local editingOptions = self:GetEditingOptions()
        local extraOptions = self:GetExtraOptions()

        --get the attribute list for the object type
        if (objectType == "FontString") then
            ---@cast object fontstring
            attributeList = attributes[objectType]

        elseif (objectType == "Texture") then
            ---@cast object texture
            attributeList = attributes[objectType]
        end

        --if there's extra options, add the attributeList to a new table and right after the extra options
        if (extraOptions and #extraOptions > 0) then
            local attributeListWithExtraOptions = {}

            for i = 1, #attributeList do
                attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = attributeList[i]
            end

            attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = {widget = "blank", default = true}

            for i = 1, #extraOptions do
                attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = extraOptions[i]
            end

            attributeList = attributeListWithExtraOptions
        end

        local anchorSettings

        --table to use on DF:BuildMenuVolatile()
        local menuOptions = {}
        for i = 1, #attributeList do
            local option = attributeList[i]

            if (option.widget == "blank") then
                menuOptions[#menuOptions+1] = {type = "blank"}
            else
                --get the key to be used on profile table
                local profileKey = profileMap[option.key]
                local value

                --if the key contains a dot or a bracket, it means it's a table path, example: "text_settings[1].width"
                if (profileKey and (profileKey:match("%.") or profileKey:match("%["))) then
                    value = detailsFramework.table.getfrompath(profileTable, profileKey)
                else
                    value = profileTable[profileKey]
                end

                --print(value, profileKey, profileTable, option.key)

                --if no value is found, attempt to get a default
                if (type(value) == "nil") then
                    value = option.default
                end

                local bHasValue = type(value) ~= "nil"

                local minValue = option.minvalue
                local maxValue = option.maxvalue

                if (option.key == "anchoroffsetx") then
                    minValue = -math.floor(object:GetParent():GetWidth()/10)
                    maxValue = math.floor(object:GetParent():GetWidth()/10)
                elseif (option.key == "anchoroffsety") then
                    minValue = -math.floor(object:GetParent():GetHeight()/10)
                    maxValue = math.floor(object:GetParent():GetHeight()/10)
                end

                if (bHasValue) then
                    local parentTable = getParentTable(profileTable, profileKey)

                    if (option.key == "anchor" or option.key == "anchoroffsetx" or option.key == "anchoroffsety") then
                        anchorSettings = parentTable
                    end

                    local optionTable = {
                        type = option.widget,
                        name = option.label,
                        get = function() return value end,
                        set = function(widget, fixedValue, newValue, ...)
                            --color is a table with 4 indexes for each color plus alpha
                            if (option.widget == "range" or option.widget == "slider") then
                                if (not option.usedecimals) then
                                    newValue = math.floor(newValue)
                                end

                            elseif (option.widget == "color") then
                                --calor callback sends the red color in the fixedParameter slot
                                local r, g, b, alpha = fixedValue, newValue, ...
                                --need to use the same table from the profile table
                                parentTable[1] = r
                                parentTable[2] = g
                                parentTable[3] = b
                                parentTable[4] = alpha

                                newValue = parentTable
                            end

                            detailsFramework.table.setfrompath(profileTable, profileKey, newValue)

                            if (self:GetOnEditCallback()) then
                                self:GetOnEditCallback()(object, option.key, newValue, profileTable, profileKey)
                            end

                            --update the widget visual
                            --anchoring uses SetAnchor() which require the anchorTable to be passed
                            if (option.key == "anchor" or option.key == "anchoroffsetx" or option.key == "anchoroffsety") then
                                anchorSettings = parentTable

                                if (option.key == "anchor") then
                                    anchorSettings.x = 0
                                    anchorSettings.y = 0
                                end

                                self:StopObjectMovement()

                                option.setter(object, parentTable)

                                if (editingOptions.can_move) then
                                    self:StartObjectMovement(anchorSettings)
                                end
                            else
                                option.setter(object, newValue)
                            end
                        end,
                        min = minValue,
                        max = maxValue,
                        step = option.step,
                        usedecimals = option.usedecimals,
                        id = option.key,
                    }

                    --disabled = true
                    if (conditionalKeys[option.key]) then
                        local bIsEnabled = conditionalKeys[option.key](object, profileTable, profileKey)
                        if (not bIsEnabled) then
                            optionTable.disabled = true
                        end
                    end

                    menuOptions[#menuOptions+1] = optionTable
                end
            end
        end

        --at this point, the optionsTable is ready to be used on DF:BuildMenuVolatile()
        menuOptions.align_as_pairs = true
        menuOptions.align_as_pairs_length = 150
        menuOptions.widget_width = 180
        menuOptions.slider_buttons_to_left = true

        local optionsFrame = self:GetOptionsFrame()
        local canvasScrollBox = self:GetCanvasScrollBox()

        local bUseColon = editingOptions.use_colon

        local bSwitchIsCheckbox = true
        local maxHeight = 5000

        local amountOfOptions = #menuOptions
        local optionsFrameHeight = amountOfOptions * 20
        optionsFrame:SetHeight(optionsFrameHeight)

        --templates
        local options_text_template = self.options.text_template or detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
        local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
        local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

        --~build ~menu ~volatile
        detailsFramework:BuildMenuVolatile(optionsFrame, menuOptions, 2, -2, maxHeight, bUseColon, options_text_template, options_dropdown_template, options_switch_template, bSwitchIsCheckbox, options_slider_template, options_button_template)

        if (editingOptions.can_move) then
            self:StartObjectMovement(anchorSettings)
        end
    end,

    ---@param self df_editor
    ---@param anchorSettings df_anchor
    StartObjectMovement = function(self, anchorSettings)
        local object = self:GetEditingObject()

        local moverFrame = self:GetMoverFrame()
        moverFrame:EnableMouse(true)
        moverFrame:SetMovable(true)
        moverFrame:ClearAllPoints()
        moverFrame:Show()

        --update guidelines
        if (self:GetEditingOptions().use_guide_lines) then
            --self:UpdateGuideLinesAnchors()
            --show all four guidelines
            for side, texture in pairs(self.moverGuideLines) do
                texture:Show()
            end
        end

        local optionsFrame = self:GetOptionsFrame()

        --getting the size this way due to the cascade of different scales that are applyed to unitFrame objects
        moverFrame:ClearAllPoints()
        moverFrame:SetPoint("topleft", object, "topleft", -5, 5)
        moverFrame:SetPoint("bottomright", object, "bottomright", 5, -5)
        local moverWidth, moverHeight = moverFrame:GetSize()

        local objectWidth, objectHeight = object:GetSize()
        moverFrame:SetSize(moverWidth, moverHeight)
        detailsFramework:SetAnchor(moverFrame, anchorSettings, object:GetParent())
        local currentPosX, currentPosY

        moverFrame:SetScript("OnMouseDown", function()
            object:ClearAllPoints()
            object:SetPoint("topleft", moverFrame, "topleft", 0, 0)

            currentPosX, currentPosY = moverFrame:GetCenter()
            moverFrame.bIsMoving = true
            moverFrame:StartMoving()
        end)

        moverFrame:SetScript("OnMouseUp", function()
            moverFrame:StopMovingOrSizing()
            moverFrame.bIsMoving = false

            --0.64 UIParent
            --0.96 object
            --local scale = object:GetEffectiveScale() / UIParent:GetEffectiveScale() --1.5

            local originX = anchorSettings.x
            local originY = anchorSettings.y

            local newPosX, newPosY = moverFrame:GetCenter()

            local xOffset = newPosX - currentPosX
            local yOffset = newPosY - currentPosY

            xOffset = xOffset
            yOffset = yOffset

            anchorSettings.x = (originX + xOffset)
            anchorSettings.y = (originY + yOffset)

            local anchorXSlider = optionsFrame:GetWidgetById("anchoroffsetx")
            anchorXSlider:SetValueNoCallback(anchorSettings.x)

            local anchorYSlider = optionsFrame:GetWidgetById("anchoroffsety")
            anchorYSlider:SetValueNoCallback(anchorSettings.y)

            object:ClearAllPoints()
            detailsFramework:SetAnchor(object, anchorSettings, object:GetParent())

            --save the new position
            local profileTable, profileMap = self:GetEditingProfile()
            local profileKey = profileMap.anchor
            local parentTable = getParentTable(profileTable, profileKey)
            parentTable.x = anchorSettings.x
            parentTable.y = anchorSettings.y

            if (self:GetOnEditCallback()) then
                self:GetOnEditCallback()(object, "x", anchorSettings.x, profileTable, profileKey)
                self:GetOnEditCallback()(object, "y", anchorSettings.x, profileTable, profileKey)
            end
        end)

        --detailsFramework:SetAnchor(moverFrame, anchorSettings)
        --detailsFramework:SetAnchor(object, anchorSettings, moverFrame)

        moverFrame:SetScript("OnUpdate", function() --not in use
            --if the object isn't moving, make the mover follow the object position
            if (false and moverFrame.bIsMoving) then
                --object:ClearAllPoints()
                --object:SetPoint("topleft", moverFrame, "topleft", 0, 0)

                --if the object is moving, check if the moverFrame has moved
                local newPosX, newPosY = moverFrame:GetCenter()

                --did the frame moved?
                if (newPosX ~= currentPosX) then
                    local xOffset = newPosX - currentPosX
                    anchorSettings.x = anchorSettings.x + xOffset
                    local anchorXSlider = optionsFrame:GetWidgetById("anchoroffsetx")
                    anchorXSlider:SetValueNoCallback(anchorSettings.x)
                end

                if (newPosY ~= currentPosY) then
                    local yOffset = newPosY - currentPosY
                    anchorSettings.y = anchorSettings.y + yOffset
                    local anchorYSlider = optionsFrame:GetWidgetById("anchoroffsety")
                    anchorYSlider:SetValueNoCallback(anchorSettings.y)
                end

                currentPosX, currentPosY = newPosX, newPosY
            end
        end)
    end,

    ---@param self df_editor
    StopObjectMovement = function(self)
        local moverFrame = self:GetMoverFrame()

        moverFrame:EnableMouse(false)
        moverFrame:SetScript("OnUpdate", nil)

        --hide all four guidelines
        for side, texture in pairs(self.moverGuideLines) do
            texture:Hide()
        end

        moverFrame:Hide()
    end,

    ---@param self df_editor
    ---@param object df_editor_objectinfo
    GetProfileTableFromObject = function(self, object)
        local profileTable = object.profiletable
        local subTablePath = object.subtablepath

        if (type(subTablePath) == "string" and subTablePath ~= "") then
            local subTable = detailsFramework.table.getfrompath(profileTable, subTablePath)
            assert(type(subTable) == "table", "GetProfileTableFromObject() subTablePath is invalid.")
            return subTable
        end

        return profileTable
    end,

    UpdateProfileTableOnAllRegisteredObjects = function(self, profileTable)
        assert(type(profileTable) == "table", "UpdateProfileTableOnAllRegisteredObjects() expects a table on #1 parameter.")

        local registeredObjects = self:GetAllRegisteredObjects()

        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            objectRegistered.profiletable = profileTable
        end

        local objectSelector = self:GetObjectSelector()
        objectSelector:RefreshMe()
    end,

    RegisterObject = function(self, object, localizedLabel, id, profileTable, subTablePath, profileKeyMap, extraOptions, callback, options)
        assert(type(object) == "table", "RegisterObjectToEdit() expects an UIObject on #1 parameter.")
        assert(object.GetObjectType, "RegisterObjectToEdit() expects an UIObject on #1 parameter.")
        assert(type(profileTable) == "table", "RegisterObjectToEdit() expects a table on #4 parameter.")
        assert(type(id) ~= "nil" and type(id) ~= "boolean", "RegisterObjectToEdit() expects an ID on parameter #3.")
        assert(type(callback) == "function" or callback == nil, "RegisterObjectToEdit() expects a function or nil as the #7 parameter.")

        local registeredObjects = self:GetAllRegisteredObjects()

        --is object already registered?
        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            if (objectRegistered.object == object) then
                error("RegisterObjectToEdit() object already registered.")
            end
        end

        --deploy the options table
        options = type(options) == "table" and options or {}
        detailsFramework.table.deploy(options, editObjectDefaultOptions)

        localizedLabel = type(localizedLabel) == "string" and localizedLabel or "invalid label"

        --a button to select the widget
        local selectButton = CreateFrame("button", "$parentSelectButton" .. id, object:GetParent())
        selectButton:SetAllPoints(object)

        ---@type df_editor_objectinfo
        local objectRegistered = {
            object = object,
            label = localizedLabel,
            id = id,
            profiletable = profileTable,
            subtablepath = subTablePath,
            profilekeymap = profileKeyMap,
            extraoptions = extraOptions or {},
            callback = callback,
            options = options,
            selectButton = selectButton,
        }

        selectButton:SetScript("OnClick", function()
            self:EditObject(objectRegistered)
        end)

        registeredObjects[#registeredObjects+1] = objectRegistered
        self.registeredObjectsByID[id] = objectRegistered

        local objectSelector = self:GetObjectSelector()
        objectSelector:RefreshMe()

        --what to do after an object is registered?
        return objectRegistered
    end,

    UnregisterObject = function(self, object)
        local registeredObjects = self:GetAllRegisteredObjects()

        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            if (objectRegistered.object == object) then
                self.registeredObjectsByID[objectRegistered.id] = nil
                table.remove(registeredObjects, i)
                break
            end
        end

        local objectSelector = self:GetObjectSelector()
        objectSelector:RefreshMe()

        --stop editing the object
    end,

    ---@param self df_editor
    ---@return df_editor_objectinfo[]
    GetAllRegisteredObjects = function(self)
        return self.registeredObjects
    end,

    ---@param self df_editor
    ---@return df_editor_objectinfo?
    GetObjectByRef = function(self, object)
        local registeredObjects = self:GetAllRegisteredObjects()
        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            if (objectRegistered.object == object) then
                return objectRegistered
            end
        end
    end,

    GetObjectByIndex = function(self, index)
        local registeredObjects = self:GetAllRegisteredObjects()
        return registeredObjects[index]
    end,

    GetObjectById = function(self, id)
        return self.registeredObjectsByID[id]
    end,

    CreateObjectSelectionList = function(self, scroll_width, scroll_height, scroll_lines, scroll_line_height)
        local editorFrame = self

        local refreshFunc = function(self, data, offset, totalLines) --~refresh
            self.SelectionTexture:Hide()
            self.SelectionTexture:ClearAllPoints()
            local objectCurrentBeingEdited = editorFrame:GetEditingObject()

			for i = 1, totalLines do
				local index = i + offset
                ---@type df_editor_objectinfo
				local objectRegistered = data[index]

				if (objectRegistered) then
                    local line = self:GetLine(i)
                    line.index = index

                    if (objectRegistered.object:GetObjectType() == "Texture") then
                        line.Icon:SetAtlas("AnimCreate_Icon_Texture")

                    elseif (objectRegistered.object:GetObjectType() == "FontString") then
                        line.Icon:SetAtlas("AnimCreate_Icon_Text")
                    end

                    line.Label:SetText(objectRegistered.label)

                    if (objectRegistered.object == objectCurrentBeingEdited) then
                        self.SelectionTexture:SetAllPoints(line)
                        self.SelectionTexture:Show()
                    end
                end
            end
        end

		local createLineFunc = function(self, index) -- ~createline --~line
			local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
			line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
			line:SetSize(scroll_width - 2, scroll_line_height)

			line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            if (index % 2 == 0) then
                line:SetBackdropColor(.1, .1, .1, .1)
            else
                line:SetBackdropColor(.1, .1, .1, .4)
            end

            detailsFramework:CreateHighlightTexture(line, "HighlightTexture")
    		detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

            line:SetScript("OnClick", function(self)
                local objectRegistered = editorFrame:GetObjectByIndex(self.index)
                editorFrame:EditObject(objectRegistered)
                editorFrame.objectSelector:RefreshMe()
            end)

			--icon
			local objectIcon = line:CreateTexture("$parentIcon", "overlay")
			objectIcon:SetSize(scroll_line_height - 2, scroll_line_height - 2)

			--object label
			local objectLabel = line:CreateFontString("$parentLabel", "overlay", "GameFontNormal")

            objectIcon:SetPoint("left", line, "left", 2, 0)
            objectLabel:SetPoint("left", objectIcon, "right", 2, 0)

			line.Icon = objectIcon
			line.Label = objectLabel

			return line
		end

        local selectObjectScrollBox = detailsFramework:CreateScrollBox(self:GetParent(), "$parentSelectObjectScrollBox", refreshFunc, editorFrame:GetAllRegisteredObjects(), scroll_width, scroll_height, scroll_lines, scroll_line_height)
        detailsFramework:ReskinSlider(selectObjectScrollBox)

        local selectionTexture = selectObjectScrollBox:CreateTexture(nil, "overlay")
        selectionTexture:SetColorTexture(1, 1, 0, 0.2)
        selectObjectScrollBox.SelectionTexture = selectionTexture

		function selectObjectScrollBox:RefreshMe()
			selectObjectScrollBox:SetData(editorFrame:GetAllRegisteredObjects())
		    selectObjectScrollBox:Refresh()
		end

		--create lines
		for i = 1, scroll_lines do
			selectObjectScrollBox:CreateLine(createLineFunc)
		end

        return selectObjectScrollBox
    end,

    OnHide = function(self)
        self:StopObjectMovement()
    end,
}

---@class df_editor_defaultoptions : table
---@field width number
---@field height number
---@field options_width number
---@field create_object_list boolean
---@field object_list_width number
---@field object_list_height number
---@field object_list_lines number
---@field object_list_line_height number
---@field text_template table

--editorFrame.options.text_template

---@type df_editor_defaultoptions
local editorDefaultOptions = {
    width = 400,
    height = 548,
    options_width = 340,
    create_object_list = true,
    object_list_width = 200,
    object_list_height = 420,
    object_list_lines = 20,
    object_list_line_height = 20,
    text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"),
}

function detailsFramework:CreateEditor(parent, name, options)
    name = name or ("DetailsFrameworkEditor" .. math.random(100000, 10000000))
    local editorFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

    detailsFramework:Mixin(editorFrame, detailsFramework.EditorMixin)
    detailsFramework:Mixin(editorFrame, detailsFramework.OptionsFunctions)

    editorFrame:SetScript("OnHide", editorFrame.OnHide)

    editorFrame.registeredObjects = {}
    editorFrame.registeredObjectsByID = {}

    editorFrame:BuildOptionsTable(editorDefaultOptions, options)

    editorFrame:SetSize(editorFrame.options.width, editorFrame.options.height)

    --The options frame holds the options for the object being edited. It is used as the parent frame for the BuildMenuVolatile() function.
    local optionsFrame = CreateFrame("frame", name .. "OptionsFrame", editorFrame, "BackdropTemplate")
    optionsFrame:SetSize(editorFrame.options.options_width, 5000)

    local canvasScrollBoxOptions = {
        width = editorFrame.options.options_width,
        height = 400,
        reskin_slider = true,
    }
    local canvasFrame = detailsFramework:CreateCanvasScrollBox(editorFrame, optionsFrame, name .. "CanvasScrollBox", canvasScrollBoxOptions)

    if (editorFrame.options.create_object_list) then
        local scrollWidth = editorFrame.options.object_list_width
        local scrollHeight = editorFrame.options.object_list_height
        local scrollLinesAmount = editorFrame.options.object_list_lines
        local scrollLineHeight = editorFrame.options.object_list_line_height

        local objectSelector = editorFrame:CreateObjectSelectionList(scrollWidth, scrollHeight, scrollLinesAmount, scrollLineHeight)
        objectSelector:SetPoint("topleft", editorFrame, "topleft", 0, -2)
        objectSelector:SetBackdropBorderColor(0, 0, 0, 0)
        editorFrame.objectSelector = objectSelector
        objectSelector:RefreshMe()

        local nScrollBarWidth = 30
        canvasFrame:SetPoint("topleft", objectSelector, "topright", nScrollBarWidth, 0)
        canvasFrame:SetPoint("bottomleft", objectSelector, "bottomright", -nScrollBarWidth, 0)
    else
        canvasFrame:SetPoint("topleft", editorFrame, "topleft", 2, -2)
        canvasFrame:SetPoint("bottomleft", editorFrame, "bottomleft", 2, 0)
    end

    --over the top frame is a frame that is always on top of everything else
    local OTTFrame = CreateFrame("frame", "$parentOTTFrame", UIParent)
    OTTFrame:SetFrameStrata("TOOLTIP")
    editorFrame.overTheTopFrame = OTTFrame

    --frame that is used to move the object
    local moverFrame = CreateFrame("frame", "$parentMoverFrame", OTTFrame, "BackdropTemplate")
    moverFrame:SetClampedToScreen(true)
    detailsFramework:ApplyStandardBackdrop(moverFrame)
    moverFrame:SetBackdropColor(.10, .10, .10, 0)
    moverFrame.__background:SetAlpha(0.1)
    editorFrame.moverFrame = moverFrame

    editorFrame:CreateMoverGuideLines()

    editorFrame.optionsFrame = optionsFrame
    editorFrame.canvasScrollBox = canvasFrame

    return editorFrame
end
