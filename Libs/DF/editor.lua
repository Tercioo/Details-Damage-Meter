
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
---@field currentObjectNinePoints df_ninepoints
---@field editingExtraOptions table
---@field registeredObjectInfo df_editor_objectinfo
---@field moverGuideLines table<string, texture>
---@field onEditCallback function
---@field optionsFrame frame
---@field overTheTopFrame frame
---@field objectSelector df_scrollbox
---@field moverObject moverobject
---@field canvasScrollBox df_canvasscrollbox
---@field ObjectBackgroundTexture texture
---@field AnchorFrames df_editor_anchorframes
---@field undoHistory undostate[]
---@field redoHistory undostate[]

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
---@field refFrame frame usually the parent of the object registered

---@class df_editor_mover_movinginfo : table
---@field startX number
---@field startY number
---@field restingX number
---@field restingY number



--which object attributes are used to build the editor menu for each object type
local attributes = {
    ---@type df_editor_attribute[]
    Texture = {
        {
            key = "texture",
            label = "Texture",
            widget = "selectstatusbartexture",
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
        {
            key = "vertexcolor",
            label = "Color",
            widget = "color",
            setter = function(widget, value) widget:SetVertexColor(unpack(value)) end
        },
        {
            key = "alpha",
            label = "Alpha",
            widget = "range",
            minvalue = 0,
            maxvalue = 1,
            usedecimals = true,
            setter = function(widget, value) widget:SetAlpha(value) end
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
            minvalue = -120,
            maxvalue = 120,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            key = "anchoroffsety",
            label = "Anchor Y Offset",
            widget = "range",
            minvalue = -120,
            maxvalue = 120,
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
            minvalue = 0,
            maxvalue = 1,
            usedecimals = true,
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
            minvalue = -120,
            maxvalue = 120,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            key = "anchoroffsety",
            label = "Anchor Y Offset",
            widget = "range",
            minvalue = -120,
            maxvalue = 120,
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
    },

    Frame = {
        {
            key = "width",
            label = "Width",
            widget = "range",
            minvalue = 5,
            maxvalue = 800,
            setter = function(widget, value) widget:SetWidth(value) end
        },
        {
            key = "height",
            label = "Height",
            widget = "range",
            minvalue = 5,
            maxvalue = 600,
            setter = function(widget, value) widget:SetHeight(value) end
        },
        --alpha
        {
            key = "alpha",
            label = "Alpha",
            widget = "range",
            minvalue = 0,
            maxvalue = 1,
            usedecimals = true,
            setter = function(widget, value) widget:SetAlpha(value) end
        },
        --frame strata
        {
            key = "framestrata",
            label = "Frame Strata",
            widget = "selectframestrata",
            setter = function(widget, value) widget:SetFrameStrata(value) end
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
            minvalue = -400,
            maxvalue = 400,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            key = "anchoroffsety",
            label = "Anchor Y Offset",
            widget = "range",
            minvalue = -300,
            maxvalue = 300,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
    },
}

---@class df_editormixin : table
---@field AddToUndoHistory fun(self:df_editor, undoData:undostate)
---@field AddToRedoHistory fun(self:df_editor, undoData:undostate)
---@field CreateMoverGuideLines fun(self:df_editor)
---@field CreateMoverFrame fun(self:df_editor):df_editor_mover[]
---@field CreateUndoManager fun(self:df_editor)
---@field CreateObjectSelectionList fun(self:df_editor, scroll_width:number, scroll_height:number, scroll_lines:number, scroll_line_height:number):df_scrollbox
---@field GetAllRegisteredObjects fun(self:df_editor):df_editor_objectinfo[]
---@field GetEditingObject fun(self:df_editor):uiobject
---@field GetEditingObjectIndex fun(self:df_editor):number?
---@field GetEditingOptions fun(self:df_editor):df_editobjectoptions
---@field GetExtraOptions fun(self:df_editor):table
---@field GetEditingProfile fun(self:df_editor):table, table
---@field GetOnEditCallback fun(self:df_editor):function
---@field GetOptionsFrame fun(self:df_editor):df_menu
---@field GetCanvasScrollBox fun(self:df_editor):df_canvasscrollbox
---@field GetObjectSelector fun(self:df_editor):df_scrollbox
---@field GetOverTheTopFrame fun(self:df_editor):frame
---@field GetMoverObject fun(self:df_editor):moverobject
---@field GetObjectById fun(self:df_editor, id:string):df_editor_objectinfo
---@field GetObjectByRef fun(self:df_editor, object:uiobject):df_editor_objectinfo
---@field GetObjectByIndex fun(self:df_editor, index:number):df_editor_objectinfo
---@field GetObjectByObjectInfo fun(self:df_editor, objectInfo:df_editor_objectinfo):df_editor_objectinfo
---@field GetEditingRegisteredObject fun(self:df_editor):df_editor_objectinfo
---@field EditObject fun(self:df_editor, object:df_editor_objectinfo)
---@field EditObjectById fun(self:df_editor, id:any)
---@field EditObjectByIndex fun(self:df_editor, index:number)
---@field PrepareObjectForEditing fun(self:df_editor)
---@field StartObjectMovement fun(self:df_editor, anchorSettings:df_anchor)
---@field StopObjectMovement fun(self:df_editor)
---@field RegisterObject fun(self:df_editor, object:uiobject, localizedLabel:string, id:string, profileTable:table, subTablePath:string, profileKeyMap:table, extraOptions:table?, callback:function?, options:df_editobjectoptions?, refFrame:frame):df_editor_objectinfo
---@field UnregisterObject fun(self:df_editor, object:uiobject)
---@field OnHide fun(self:df_editor)
---@field OnShow fun(self:df_editor)
---@field CreateSelectedTextures fun(self:df_editor)
---@field ShowSelectedTextures fun(self:df_editor, object:uiobject) 90 degree corner on each corner of the object
---@field GetProfileTableFromObject fun(self:df_editor, object:df_editor_objectinfo):table
---@field UpdateGuideLinesAnchors fun(self:df_editor)
---@field UpdateProfileTableOnAllRegisteredObjects fun(self:df_editor, profileTable:table)
---@field UpdateProfileTable fun(self:df_editor, identifier:any, profileTable:table):boolean change the profile table, identifier is the ID, index or object reference of the registered object info
---@field UpdateProfileSubTablePath fun(self:df_editor, identifier:any, subTablePath:string) change the subTablePath, identifier is the ID, index, object reference of the registered object info
---@field Undo fun(self:df_editor)
---@field Refresh fun(self:df_editor) re-start editing the object that is currently being edited

---@class df_editobjectoptions : table
---@field use_colon boolean? if true a colon is shown after the option name
---@field can_move boolean? if true the object can be moved
---@field use_guide_lines boolean? if true guide lines are shown when the object is being moved
---@field icon any atlasName atlasTable (from DF:CreateAtlas) or texture path|id

---@type df_editobjectoptions
local editObjectDefaultOptions = {
    use_colon = false,
    can_move = true,
    use_guide_lines = true,
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
---@field dropdown_template table
---@field switch_template table
---@field button_template table
---@field slider_template table
---@field no_anchor_points boolean
---@field start_editing_callback fun(editorFrame: df_editor, registeredObject: df_editor_objectinfo)?
---@field selection_texture string
---@field selection_size number

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
    dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"),
    switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE"),
    button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"),
    slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE"),
    text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"),
    no_anchor_points = false,
    start_editing_callback = nil,
    selection_texture = "GM_BehaviorMessage_CornerTopLeft_Frame",
    selection_size = 8,
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

---@param self df_editor
---@param identifier any
---@return df_editor_objectinfo?
local getRegisteredObject = function(self, identifier)
    if (type(identifier) == "string") then
        return self:GetObjectById(identifier)

    elseif (type(identifier) == "number") then
        return self:GetObjectByIndex(identifier)

    elseif (type(identifier) == "table" and identifier.GetObjectType) then
        return self:GetObjectByRef(identifier)

    elseif (type(identifier) == "table" and identifier.refFrame) then
        return self:GetObjectByObjectInfo(identifier)
    end

    return nil
end

detailsFramework.EditorMixin = {
    ---@param self df_editor
    GetEditingObject = function(self)
        return self.editingObject
    end,

    ---@param self df_editor
    Refresh = function(self)
        local registeredObject = self:GetEditingRegisteredObject()
        if (registeredObject) then
            self:EditObject(registeredObject)
        end
    end,

    ---@param self df_editor
    GetEditingObjectIndex = function(self)
        local object = self:GetEditingObject()
        local registeredObjects = self:GetAllRegisteredObjects()
        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            if (objectRegistered.object == object) then
                return i
            end
        end
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

    GetMoverObject = function(self)
        return self.moverObject
    end,

    GetCanvasScrollBox = function(self)
        return self.canvasScrollBox
    end,

    GetObjectSelector = function(self)
        return self.objectSelector
    end,

    ---@param self df_editor
    CreateSelectedTextures = function(self)
        self.SelectedTextures = {}
        local anchors = {"topleft", "topright", "bottomleft", "bottomright"}
        for i = 1, #anchors do
            local thisAnchor = anchors[i]
            local texture = self:GetOverTheTopFrame():CreateTexture(nil, "overlay")
            detailsFramework:SetTexture(texture, self.options.selection_texture)
            texture:SetDrawLayer("overlay", 6)
            texture:Hide()
            self.SelectedTextures[i] = texture

            if (thisAnchor == "topright") then
                texture:SetTexCoord(1, 0, 0, 1)
            elseif (thisAnchor == "bottomleft") then
                texture:SetTexCoord(0, 1, 1, 0)
            elseif (thisAnchor == "bottomright") then
                texture:SetTexCoord(1, 0, 1, 0)
            end
        end
    end,

    --90 degree corner on each corner of the object
    ShowSelectedTextures = function(self, object)
        local textures = self.SelectedTextures
        local size = self.options.selection_size

        --topleft
        textures[1]:ClearAllPoints()
        textures[1]:SetPoint("topleft", object, "topleft", -3, 3)
        textures[1]:SetSize(size, size)
        textures[1]:Show()

        --topright
        textures[2]:ClearAllPoints()
        textures[2]:SetPoint("topright", object, "topright", 3, 3)
        textures[2]:SetSize(size, size)
        textures[2]:Show()

        --bottomleft
        textures[3]:ClearAllPoints()
        textures[3]:SetPoint("bottomleft", object, "bottomleft", -3, -3)
        textures[3]:SetSize(size, size)
        textures[3]:Show()

        --bottomright
        textures[4]:ClearAllPoints()
        textures[4]:SetPoint("bottomright", object, "bottomright", 3, -3)
        textures[4]:SetSize(size, size)
        textures[4]:Show()
    end,

    ---@param self df_editor
    CreateMoverGuideLines = function(self)
        local overTheTopFrame = self:GetOverTheTopFrame()

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

    --creates the undo and redo history tables and the functions to add states to them
    CreateUndoManager = function(self)
        self.undoHistory = {}
        self.redoHistory = {}
    end,

    AddToUndoHistory = function(self, state)
        table.insert(self.undoHistory, state)
        wipe(self.redoHistory)
    end,

    AddToRedoHistory = function(self, state)
        table.insert(self.redoHistory, state)
    end,

    Undo = function(self)
        ---@type undostate
        local nextUndo = table.remove(self.undoHistory)
        if nextUndo then
            self:AddToRedoHistory(nextUndo)

            local originalStates = nextUndo.oldState
            for i = 1, #originalStates do
                local thisSettingState = originalStates[i]
                local key = thisSettingState.key
                local value = thisSettingState.value
                local configTable = thisSettingState.settingTable
                configTable[key] = value
            end

            --get the object by id
            local objectId = nextUndo.objectId

            ---@type df_editor_objectinfo
            local objectRegistered = self:GetObjectById(objectId)
--PAREI AQUI, PRECISA TESTAR - terminei de fazer o loop for i = 1, #originalStates do
--terminei de adicionar os dois self:EditObject(objectRegistered)
--o que espero ver: a localização do uiobject retornar ao estado anterior quando chamar a Undo
            local currentObjectRegistered = self:GetEditingRegisteredObject()
            --if the current object being edited is different from the one being undone, switch to it
            if currentObjectRegistered and objectId ~= currentObjectRegistered.id then
                self:EditObject(objectRegistered)
                self.objectSelector:RefreshMe()
            else
                self:EditObject(currentObjectRegistered)
                self.objectSelector:RefreshMe()
            end

        end
    end,

---@class df_editor_anchorframes : table
---@field anchorFrames table
---@field DisableAllAnchors fun(self:df_editor_anchorframes)
---@field SetupAnchorsForObject fun(self:df_editor_anchorframes, anchorTable:table)
---@field SelectAnchorPoint fun(self:df_editor_anchorframes)
---@field GetAnchorFrame fun(self:df_editor_anchorframes, index:number):frame
---@field SetNotInUseForAllAnchors fun(self:df_editor_anchorframes)
---@field SetNotInUse fun(self:df_editor_anchorframes, anchorFrame:frame)
---@field SetInUse fun(self:df_editor_anchorframes, anchorFrame:frame)
---@field CreateNineAnchors fun(self:df_editor_anchorframes)

    --screen position offset is the XY screen position offset from the bottom left of the screen, they are always positive, they go from 0 to screen width or height
    CreateAnchorFrames = function(editorFrame)
        --table containing 9 buttons, each one in a different position of the object, indexes one to nine in this order: topleft, left, bottomleft, bottom, bottomright, right, topright, top, center
        editorFrame.AnchorFrames = {
            anchorFrames = {},

            DisableAllAnchors = function(self)
                for i = 1, 9 do
                    local anchorFrame = self:GetAnchorFrame(i)
                    self:SetNotInUse(anchorFrame)
                    anchorFrame:Hide()
                end
            end,

            SetupAnchorsForObject = function(self, anchorTable)
                editorFrame.AnchorFrames:DisableAllAnchors()

                local registeredObject = editorFrame:GetEditingRegisteredObject()

                if (registeredObject.refFrame) then
                    for i = 1, 9 do
                        local anchorFrame = self.anchorFrames[i]
                        local anchorName = detailsFramework.AnchorPointsByIndex[i]
                        anchorFrame:ClearAllPoints()
                        anchorFrame:SetPoint(anchorName, registeredObject.refFrame, anchorName, 0, 0)
                        anchorFrame:Show()
                    end

                    local sideSelected = anchorTable.side
                    local anchorFrameSelected = self:GetAnchorFrame(detailsFramework.InsidePointsToAnchor[sideSelected] or sideSelected)
                    self:SetInUse(anchorFrameSelected)

                    self.anchorTable = anchorTable
                end
            end,

            --when the user click on one of the anchor points, change the anchor side setting and recalculate the xy offset of the new point related to the same point in the object
            SelectAnchorPoint = function(anchorFrame)
                editorFrame.AnchorFrames:SetNotInUseForAllAnchors()

                --change the color of the anchor point to show it's selected
                anchorFrame.Texture:SetColorTexture(1, 0, 0, 0.5)

                --get the object being edited in the editor
                local object = editorFrame:GetEditingObject()

                --get the xy of the nine points of the object
                local ninePoints = detailsFramework.Math.GetNinePoints(object)

                --get the coordinates of the anchorIndex within the ninePoints table
                --the xy point in here is the XY screen position offset from the bottom left of the screen
                local screenPoint = ninePoints[anchorFrame.anchorIndex]
                local objectScreenPosX = screenPoint.x
                local objectScreenPosY = screenPoint.y

                --get the screen position offset of the anchor
                local anchorScreenPosX, anchorScreenPosY = anchorFrame:GetCenter()

                --calculate the xy offset of the anchor point related to the object
                local offsetX = objectScreenPosX - anchorScreenPosX
                local offsetY = objectScreenPosY - anchorScreenPosY

                --get the anchor settings table
                local anchorTable = editorFrame.AnchorFrames.anchorTable

                --set the anchor settings
                anchorTable.x = offsetX
                anchorTable.y = offsetY
                anchorTable.side = detailsFramework.AnchorPointsToInside[anchorFrame.anchorIndex]

                C_Timer.After(0, function()
                    editorFrame:PrepareObjectForEditing()
                end)
            end,

            GetAnchorFrame = function(self, anchorIndex)
                return self.anchorFrames[anchorIndex]
            end,

            SetNotInUseForAllAnchors = function(self)
                for i = 1, 9 do
                    local anchorFrame = self:GetAnchorFrame(i)
                    self:SetNotInUse(anchorFrame)
                end
            end,

            SetNotInUse = function(self, anchorFrame)
                anchorFrame.Texture:SetColorTexture(1, 1, 1, 0.5)
            end,

            SetInUse = function(self, anchorFrame)
                anchorFrame.Texture:SetColorTexture(1, 0, 0, 0.5)
            end,

            CreateNineAnchors = function(self)
                local overTheTopFrame = editorFrame:GetOverTheTopFrame()

                for i = 1, 9 do
                    local anchorFrame = CreateFrame("button", "$parentAnchorFrame" .. i, overTheTopFrame, "BackdropTemplate")
                    anchorFrame:SetSize(8, 8)
                    anchorFrame:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
                    anchorFrame:SetBackdropColor(1, 0, 0, 0.5)
                    anchorFrame:SetFrameStrata("TOOLTIP")
                    anchorFrame:SetFrameLevel(10)
                    anchorFrame.anchorIndex = i
                    anchorFrame:Hide()

                    anchorFrame:SetScript("OnClick", editorFrame.AnchorFrames.SelectAnchorPoint)

                    self.anchorFrames[i] = anchorFrame

                    anchorFrame.Texture = anchorFrame:CreateTexture("$parentTexture", "border")
                    anchorFrame.Texture:SetColorTexture(1, 1, 1, 0.5)
                    anchorFrame.Texture:SetAllPoints(anchorFrame)
                end
            end,
        }

        editorFrame.AnchorFrames:CreateNineAnchors()
        return editorFrame.AnchorFrames
    end,

    ---@class moverobject : table
    ---@field bIsMoving boolean
    ---@field lastMoveInfo table
    ---@field MoverFrame df_editor_mover
    ---@field AddUndoState fun(self:moverobject) add a undo state into the editor object undo state manager
    ---@field Setup fun(self:moverobject, object:uiobject, registeredObject:df_editor_objectinfo, onTickWhileMoving:function, onTickNotMoving:function)
    ---@field Hide fun(self:moverobject)
    ---@field Stop fun(self:moverobject)
    ---@field UpdatePosition fun(self:moverobject, moverFrame:df_editor_mover)

    ---@class df_editor_mover : frame
    ---@field undoInfo table
    ---@field moved boolean
    ---@field anchorName string
    ---@field MovingInfo df_editor_mover_movinginfo
    ---@field MoverIcon texture
    ---@field bIsMoving boolean
    ---@field OnTickWhileMoving fun(self:df_editor_mover, deltaTime:number)
    ---@field OnTickNotMoving fun(self:df_editor_mover, deltaTime:number)

    ---@class undostate : table
    ---@field objectId string
    ---@field oldState table
    ---@field newState table

    ---create a frame to move the object, the frame is attached into the bottom right of the selected object
    ---@param editorFrame df_editor
    ---@return moverobject
    CreateMoverFrame = function(editorFrame)
        --frame that is used to move the object
        ---@type moverobject
        ---@diagnostic disable-next-line: missing-fields
        local moverObject = {
            bIsMoving = false,

            AddUndoState = function(self)
                local moverFrame = self.MoverFrame

                local editor = editorFrame
                local registeredObject = editor:GetEditingRegisteredObject()
                local profileTable, profileMap = editor:GetEditingProfile()
                local objectId = registeredObject.id
                local objectType = registeredObject.object:GetObjectType()

                local anchorSettingsTable = self.lastMoveInfo.anchorSettings
                local xKey = self.lastMoveInfo.keyX
                local yKey = self.lastMoveInfo.keyY
                local stateX = self.lastMoveInfo.defaultX
                local stateY = self.lastMoveInfo.defaultY

                ---@type undostate
                local newUndoState = {
                    objectId = objectId, --to start editing the object
                    oldState = {
                        {key = xKey, settingTable = anchorSettingsTable, value = stateX},
                        {key = yKey, settingTable = anchorSettingsTable, value = stateY},
                    },
                    newState = {
                        {key = xKey, settingTable = anchorSettingsTable, value = anchorSettingsTable[xKey]},
                        {key = yKey, settingTable = anchorSettingsTable, value = anchorSettingsTable[yKey]},
                    },
                }

                --add the undo state to the editor undo state
                editorFrame:AddToUndoHistory(newUndoState)
            end,

            Setup = function(self, object, registeredObject, onTickWhileMoving, onTickNotMoving)
                local moverFrame = self.MoverFrame
                moverFrame:Show()
                moverFrame:EnableMouse(true)
                moverFrame.OnTickWhileMoving = onTickWhileMoving
                moverFrame.OnTickNotMoving = onTickNotMoving
                moverFrame.anchorName = "center"

                moverFrame:SetScript("OnMouseDown", function()
                    --save the current position of the object
                    local startX, startY = moverFrame:GetCenter()
                    moverFrame.MovingInfo.startX = startX
                    moverFrame.MovingInfo.startY = startY

                    editorFrame.currentObjectNinePoints = detailsFramework.Math.GetNinePoints(registeredObject.refFrame)

                    --start moving
                    moverFrame:SetScript("OnUpdate", onTickWhileMoving)
                    moverFrame.bIsMoving = true
                    moverFrame:StartMoving()
                end)

                moverFrame:SetScript("OnMouseUp", function()
                    self:Stop()
                    moverFrame:EnableMouse(true)

                    --save the current position of the object selected
                    local x, y = object:GetCenter()
                    moverFrame.MovingInfo.restingX = x
                    moverFrame.MovingInfo.restingY = y
                    moverFrame:SetScript("OnUpdate", onTickNotMoving)

                    local editingObject = editorFrame:GetEditingObject()

                    --which object, from which table, path to property, key, old value, new value
                    self:AddUndoState()
                end)

                moverFrame:ClearAllPoints()

                --setting all points on the object
                moverFrame:SetPoint("topleft", object, "topleft", 0, 0)
                moverFrame:SetPoint("bottomright", object, "bottomright", 0, 0)

                --current position of object selected
                local x, y = object:GetCenter()
                moverFrame.MovingInfo.restingX = x
                moverFrame.MovingInfo.restingY = y
                moverFrame:SetScript("OnUpdate", onTickNotMoving)

                --problem, I don't remember why caused the issue of the hide on click on others tabs, I think the mover was anchored to parent frame all points
                if (not moverFrame.moved) then
                    moverFrame:GetScript("OnMouseDown")(moverFrame)
                    moverFrame:GetScript("OnMouseUp")(moverFrame)
                    --moverFrame.moved = true
                end
            end,

            Hide = function(self)
                self.MoverFrame:Hide()
            end,

            Stop = function(self)
                self.bIsMoving = false
                local moverFrame = self.MoverFrame
                moverFrame:StopMovingOrSizing()
                moverFrame:SetScript("OnUpdate", nil)
            end,

            UpdatePosition = function(self, moverFrame)
                local thisMoverFrame = self.MoverFrame
                if (thisMoverFrame ~= moverFrame) then --what?
                    thisMoverFrame.OnTickNotMoving(thisMoverFrame, 0)
                end
            end,
        }

        ---@type df_editor_mover
        local moverFrame = CreateFrame("button", editorFrame:GetName() .. "MoverFrame", UIParent, "BackdropTemplate")
        moverObject.MoverFrame = moverFrame
        moverFrame:SetFrameStrata("TOOLTIP")
        moverFrame:SetSize(16, 16)
        moverFrame:SetClampedToScreen(true)
        moverFrame:EnableMouse(true)
        moverFrame:SetMovable(true)
        moverFrame:SetFrameLevel(4)
        moverFrame.MovingInfo = {
            startX = 0,
            startY = 0,
            restingX = 0,
            restingY = 0,
        }
        --create the mover texture background
        moverFrame:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        moverFrame:SetBackdropColor(1, 0, 0, 0.2)

        --white dot in the middle of the mover frame
        moverFrame.MoverIcon = moverFrame:CreateTexture("$parentMoverIcon", "overlay")
        moverFrame.MoverIcon:SetTexture([[Interface\CHATFRAME\CHATFRAMEBACKGROUND]])
        moverFrame.MoverIcon:SetSize(6, 6) --default: 6
        moverFrame.MoverIcon:SetPoint("center", moverFrame, "center", 0, 0)

        return moverObject
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
        self.registeredObjectInfo = registeredObject
        self.editingObject = object
        self.editingProfileMap = profileKeyMap
        self.editingProfileTable = profileTable
        self.editingOptions = options
        self.editingExtraOptions = extraOptions

        if (type(callback) == "function") then
            self.onEditCallback = callback
        end

        self:PrepareObjectForEditing()

        if self.options.start_editing_callback then
            xpcall(self.options.start_editing_callback, geterrorhandler(), self, registeredObject)
        end
    end,

    PrepareObjectForEditing = function(self) --~edit
        --get the object and its profile table with the current values
        local object = self:GetEditingObject()
        local profileTable, profileMap = self:GetEditingProfile()
        profileMap = profileMap or {}

        self.AnchorFrames:DisableAllAnchors()

        local conditionalKeys = profileMap.enable_if or {}

        if (not object or not profileTable) then
            return
        end

        self.ObjectBackgroundTexture:SetPoint("topleft", object, "topleft", -2, 2)
        self.ObjectBackgroundTexture:SetPoint("bottomright", object, "bottomright", 2, -2) --using points instead of size due to width height being secret values in some objects

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

        elseif (objectType == "Frame" or objectType == "Button" or objectType == "StatusBar") then
            ---@cast object frame
            attributeList = attributes["Frame"]
        end

        --if there's extra options, add the attributeList to a new table and right after the extra options
        if (extraOptions and #extraOptions > 0) then
            local attributeListWithExtraOptions = {}

            --only add the blank space if there's attributes before the extra options
            if (#attributeList > 0) then
                for i = 1, #attributeList do
                    attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = attributeList[i]
                end
                attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = {widget = "blank", default = true}
            end

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
                local profileKey = profileMap[option.key] or option.key
                if profileKey then
                    local value

                    --if the key contains a dot or a bracket, it means it's a table path, example: "text_settings[1].width"
                    if (profileKey and (profileKey:match("%.") or profileKey:match("%["))) then --profileKey is a number
                        value = detailsFramework.table.getfrompath(profileTable, profileKey)
                    else
                        value = profileTable[profileKey]
                    end

                    --if no value is found, attempt to get a default
                    if (type(value) == "nil") then
                        value = option.default
                    end

                    local bHasValue = type(value) ~= "nil"

                    local minValue = option.minvalue
                    local maxValue = option.maxvalue

                    if (option.key == "anchoroffsetx") then
                        minValue = -math.floor(object:GetParent():GetWidth())
                        maxValue = math.floor(object:GetParent():GetWidth())
                    elseif (option.key == "anchoroffsety") then
                        minValue = -math.floor(object:GetParent():GetHeight())
                        maxValue = math.floor(object:GetParent():GetHeight())
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
                                    else
                                        --hide mover frame
                                        self.moverObject:Hide()
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
        end

        if (anchorSettings and not self.options.no_anchor_points) then
            self.AnchorFrames:SetupAnchorsForObject(anchorSettings)
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
        local options_dropdown_template = self.options.dropdown_template
        local options_switch_template = self.options.switch_template
        local options_button_template = self.options.button_template
        local options_slider_template = self.options.slider_template
        local options_text_template = self.options.text_template

        --~build ~menu ~volatile
        detailsFramework:BuildMenuVolatile(optionsFrame, menuOptions, 2, -2, maxHeight, bUseColon, options_text_template, options_dropdown_template, options_switch_template, bSwitchIsCheckbox, options_slider_template, options_button_template)

        if (editingOptions.can_move) then
            self:StartObjectMovement(anchorSettings)
        else
            --hide mover frame
            self.moverObject:Hide()
        end

        self:ShowSelectedTextures(object)
    end,

    ---@param self df_editor
    ---@param anchorSettings df_anchor
    StartObjectMovement = function(self, anchorSettings)
        local object = self:GetEditingObject()

        --update guidelines
        if (self:GetEditingOptions().use_guide_lines) then
            --self:UpdateGuideLinesAnchors()
            --show all four guidelines
            for side, texture in pairs(self.moverGuideLines) do
                texture:Show()
            end
        end

        local registeredObject = self:GetEditingRegisteredObject()
        local optionsFrame = self:GetOptionsFrame()
        local objectParent = object:GetParent()
        local moverObject = self:GetMoverObject()
        --the mover frame set its point to the object being moved
        --the move frame center dot keep under the mouse, but the object moves much faster

        moverObject.lastMoveInfo = {
            anchorSettings = anchorSettings,
            keyX = "x",
            keyY = "y",
            defaultX = anchorSettings.x,
            defaultY = anchorSettings.y,
        }

        local onTickWhileMoving = function(moverFrame, deltaTime)
            local startX, startY = moverFrame:GetCenter()
            local xOffset = startX - moverFrame.MovingInfo.startX
            local yOffset = startY - moverFrame.MovingInfo.startY

            local uiScale = UIParent:GetEffectiveScale()
            local objectScale = object:GetEffectiveScale()
            local scaleScaled = uiScale / objectScale

            xOffset = xOffset * scaleScaled
            yOffset = yOffset * scaleScaled

            if (xOffset ~= 0 or yOffset ~= 0) then
                assert(anchorSettings, "StartObjectMovement() anchorSettings is nil for object: " .. registeredObject.id)
                moverFrame.MovingInfo.startX = startX
                moverFrame.MovingInfo.startY = startY

                anchorSettings.x = anchorSettings.x + xOffset
                anchorSettings.y = anchorSettings.y + yOffset

                detailsFramework:SetAnchor(object, anchorSettings, objectParent)

                --update the slider offset in the options frame
                local anchorXSlider = optionsFrame:GetWidgetById("anchoroffsetx")
                anchorXSlider:SetValueNoCallback(anchorSettings.x)
                local anchorYSlider = optionsFrame:GetWidgetById("anchoroffsety")
                anchorYSlider:SetValueNoCallback(anchorSettings.y)

                --save the new position
                local profileTable, profileMap = self:GetEditingProfile()
                local profileKey = profileMap.anchor
                local parentTable = getParentTable(profileTable, profileKey)
                parentTable.x = anchorSettings.x
                parentTable.y = anchorSettings.y

                local closestPoint = self.currentObjectNinePoints:GetClosestPoint(CreateVector2D(startX, startY))
                if (closestPoint ~= parentTable.side) then
                    --print("side is different", closestPoint, parentTable.side)
                end

                if (self:GetOnEditCallback()) then
                    self:GetOnEditCallback()(object, "x", anchorSettings.x, profileTable, profileKey)
                    self:GetOnEditCallback()(object, "y", anchorSettings.y, profileTable, profileKey)
                end

                moverObject:UpdatePosition(moverFrame)
            end
        end

        local onTickNotMoving = function(moverFrame, deltaTime)
            --current position of the selected object
            local objectX, objectY = object:GetCenter()
            --did the object move?
            if (objectX ~= moverFrame.MovingInfo.restingX or objectY ~= moverFrame.MovingInfo.restingY) then
                moverFrame:SetPoint("center", object, moverFrame.anchorName, 0, 0)
                local x, y = moverFrame:GetCenter()
                --moverFrame:SetPoint("center", UIParent, "bottomleft", x, y)
                moverFrame.MovingInfo.restingX = objectX
                moverFrame.MovingInfo.restingY = objectY
            end
        end

        moverObject:Setup(object, registeredObject, onTickWhileMoving, onTickNotMoving)
    end,

    ---@param self df_editor
    StopObjectMovement = function(self)
        local moverFrame = self:GetMoverObject()
        moverFrame:Stop()

        --hide all four guidelines
        for side, texture in pairs(self.moverGuideLines) do
            texture:Hide()
        end
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

    UpdateProfileSubTablePath = function(self, identifier, subTablePath)
        assert(identifier, "UpdateProfileSubTablePath() expects a registered object identifier on #1 parameter.")
        assert(type(subTablePath) == "string", "UpdateProfileSubTablePath() expects a pathstring or nil on #2 parameter.")

        local objectRegistered = getRegisteredObject(self, identifier)
        assert(type(objectRegistered) == "table", "UpdateProfileSubTablePath() registered object not found.")

        objectRegistered.subtablepath = subTablePath

        return true
    end,

    ---@param self df_editor
    ---@param identifier any
    ---@param profileTable table
    ---@return boolean
    UpdateProfileTable = function(self, identifier, profileTable)
        assert(identifier, "UpdateProfileTable() expects a registered object identifier on #1 parameter.")
        assert(type(profileTable) == "table", "UpdateProfileTable() expects a table on #2 parameter.")

        local objectRegistered = getRegisteredObject(self, identifier)
        assert(type(objectRegistered) == "table", "UpdateProfileTable() registered object not found.")

        objectRegistered.profiletable = profileTable

        return true
    end,

    RegisterObject = function(self, object, localizedLabel, id, profileTable, subTablePath, profileKeyMap, extraOptions, callback, options, refFrame)
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
            refFrame = refFrame,
        }

        registeredObjects[#registeredObjects+1] = objectRegistered
        self.registeredObjectsByID[id] = objectRegistered

        local objectSelector = self:GetObjectSelector()
        objectSelector:RefreshMe()

        selectButton:SetScript("OnClick", function()
            self:EditObject(objectRegistered)
            objectSelector:RefreshMe()
        end)

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

    GetObjectByObjectInfo = function(self, objectInfo)
        local registeredObjects = self:GetAllRegisteredObjects()
        for i = 1, #registeredObjects do
            local objectRegistered = registeredObjects[i]
            if (objectRegistered == objectInfo) then
                return objectRegistered
            end
        end
    end,

    ---@param self df_editor
    ---@return df_editor_objectinfo
    GetEditingRegisteredObject = function(self)
        return self.registeredObjectInfo
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

                    local customIcon = objectRegistered.options.icon
                    if (customIcon) then
                        local isAtlas = C_Texture.GetAtlasInfo(customIcon)
                        if (isAtlas) then
                            line.Icon:SetAtlas(customIcon)

                        elseif (type(customIcon) == "table") then
                            local useAtlasSize = true
                            local resetTexCoords = true
                            detailsFramework:SetAtlas(line.Icon, customIcon, useAtlasSize, "TRILINEAR", resetTexCoords)

                        else
                            line.Icon:SetTexture(customIcon)
                            line.Icon:SetTexCoord(0, 1, 0, 1)
                            line.Icon:SetVertexColor(1, 1, 1, 1)
                        end

                    elseif (objectRegistered.object:GetObjectType() == "Texture") then
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
        local moverObject = self:GetMoverObject()
        moverObject:Hide()
        self.AnchorFrames:DisableAllAnchors()
    end,

    ---@param self df_editor
    OnShow = function(self)
        --get the editing object
        local objectIndex = self:GetEditingObjectIndex()
        if (objectIndex) then
            self:EditObjectByIndex(objectIndex)
            self.objectSelector:RefreshMe()
        end
    end,
}


function detailsFramework:CreateEditor(parent, name, options)
    name = name or ("DetailsFrameworkEditor" .. math.random(100000, 10000000))
    ---@type df_editor
    local editorFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

    detailsFramework:Mixin(editorFrame, detailsFramework.EditorMixin)
    detailsFramework:Mixin(editorFrame, detailsFramework.OptionsFunctions)

    editorFrame:SetScript("OnShow", editorFrame.OnShow)
    editorFrame:SetScript("OnHide", editorFrame.OnHide)

    editorFrame.registeredObjects = {}
    editorFrame.registeredObjectsByID = {}

    editorFrame:BuildOptionsTable(editorDefaultOptions, options)

    editorFrame:SetSize(editorFrame.options.width, editorFrame.options.height)

    --The options frame holds the options for the object being edited. It is used as the parent frame for the BuildMenuVolatile() function.
    ---@type df_menu
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

    --background below the selected object, its point is set when the movers are setup and set directly on the object being edited
    editorFrame.ObjectBackgroundTexture = editorFrame:CreateTexture("$parentMoverObjectBackground", "artwork")
    editorFrame.ObjectBackgroundTexture:SetColorTexture(1, 0, 1, 0.25)

    --over the top frame is a frame that is always on top of everything else
    local OTTFrame = CreateFrame("frame", "$parentOTTFrame", UIParent)
    OTTFrame:SetFrameStrata("TOOLTIP")
    editorFrame.overTheTopFrame = OTTFrame

    editorFrame:CreateAnchorFrames()
    editorFrame:CreateUndoManager()

    editorFrame.moverObject = editorFrame:CreateMoverFrame()
    editorFrame:CreateMoverGuideLines()

    editorFrame:CreateSelectedTextures()

    editorFrame.optionsFrame = optionsFrame
    editorFrame.canvasScrollBox = canvasFrame

    return editorFrame
end
