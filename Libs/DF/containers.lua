
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local DF = detailsFramework

local CreateFrame = CreateFrame
local wipe = wipe
local unpack = unpack

---@class df_framecontainer : frame, dfframecontainermixin, df_optionsmixin
---@field bIsSizing boolean
---@field options table
---@field currentWidth number
---@field currentHeight number
---@field bottomLeftResizer framecontainerresizer
---@field bottomRightResizer framecontainerresizer
---@field topLeftResizer framecontainerresizer
---@field topRightResizer framecontainerresizer
---@field topResizer framecontainerresizer
---@field bottomResizer framecontainerresizer
---@field leftResizer framecontainerresizer
---@field rightResizer framecontainerresizer
---@field cornerResizers framecontainerresizer[]
---@field sideResizers framecontainerresizer[]
---@field components table<frame, boolean>
---@field moverFrame frame
---@field movableChildren table<frame, boolean>
---@field settingChangedCallback fun(frameContainer: df_framecontainer, settingName: string, settingValue: any)
---@field OnSizeChanged fun(frameContainer: df_framecontainer)
---@field OnResizerMouseDown fun(resizerButton: button, mouseButton: string)
---@field OnResizerMouseUp fun(resizerButton: button, mouseButton: string)
---@field HideResizer fun(frameContainer: df_framecontainer)
---@field ShowResizer fun(frameContainer: df_framecontainer)
---@field OnInitialize fun(frameContainer: df_framecontainer)
---@field SetResizeLocked fun(frameContainer: df_framecontainer, isLocked: boolean)
---@field SetMovableLocked fun(frameContainer: df_framecontainer, isLocked: boolean)
---@field CheckResizeLockedState fun(frameContainer: df_framecontainer)
---@field CheckMovableLockedState fun(frameContainer: df_framecontainer)
---@field CreateMover fun(frameContainer: df_framecontainer)
---@field CreateResizers fun(frameContainer: df_framecontainer)
---@field RegisterChildForDrag fun(frameContainer: df_framecontainer, child: frame)
---@field UnregisterChildForDrag fun(frameContainer: df_framecontainer, child: frame)
---@field RefreshChildrenState fun(frameContainer: df_framecontainer)
---@field OnChildDragStart fun(frameContainer: df_framecontainer, child: frame)
---@field OnChildDragStop fun(frameContainer: df_framecontainer, child: frame)
---@field SetSettingChangedCallback fun(frameContainer: df_framecontainer, callback: fun(frameContainer: df_framecontainer, settingName: string, settingValue: any))
---@field SendSettingChangedCallback fun(frameContainer: df_framecontainer, settingName: string, settingValue: any)



---@class framecontainerresizer : button
---@field sizingFrom string

---@class dfframecontainermixin
detailsFramework.FrameContainerMixin = {
    --methods

    ---run when the user click on the resizer
    ---@param resizerButton framecontainerresizer
    ---@param mouseButton string
    OnResizerMouseDown = function(resizerButton, mouseButton)
        if (mouseButton ~= "LeftButton") then
            return
        end

        ---@type df_framecontainer
        local frameContainer = resizerButton:GetParent() --Cannot assign `frame` to `df_framecontainer`. .. but df_framecontainer is inherited from frame

        if (frameContainer.bIsSizing) then
            return
        end

        frameContainer.bIsSizing = true
        frameContainer:StartSizing(resizerButton.sizingFrom)
    end,

    ---run when the user click on the resizer
    ---@param resizerButton framecontainerresizer
    ---@param mouseButton string
    OnResizerMouseUp = function(resizerButton, mouseButton)
        ---@type df_framecontainer
        local frameContainer = resizerButton:GetParent() --Cannot assign `frame` to `df_framecontainer`. .. but df_framecontainer is inherited from frame

        if (not frameContainer.bIsSizing) then
            return
        end

        frameContainer:StopMovingOrSizing()
        frameContainer.bIsSizing = false
    end,

    ---hide resizer
    ---@param frameContainer df_framecontainer
    HideResizer = function(frameContainer)
        for i = 1, #frameContainer.cornerResizers do
            frameContainer.cornerResizers[i]:Hide()
        end

        for i = 1, #frameContainer.sideResizers do
            frameContainer.sideResizers[i]:Hide()
        end
    end,

    ---show resizer
    ---@param frameContainer df_framecontainer
    ShowResizer = function(frameContainer)
        --corner resizers
        if (frameContainer.options.use_bottomleft_resizer) then
            frameContainer.bottomLeftResizer:Show()
        end
        if (frameContainer.options.use_bottomright_resizer) then
            frameContainer.bottomRightResizer:Show()
        end
        if (frameContainer.options.use_topleft_resizer) then
            frameContainer.topRightResizer:Show()
        end
        if (frameContainer.options.use_topright_resizer) then
            frameContainer.topRightResizer:Show()
        end

        --side resizers
        if (frameContainer.options.use_top_resizer) then
            frameContainer.topResizer:Show()
        end
        if (frameContainer.options.use_bottom_resizer) then
            frameContainer.bottomResizer:Show()
        end
        if (frameContainer.options.use_left_resizer) then
            frameContainer.leftResizer:Show()
        end
        if (frameContainer.options.use_right_resizer) then
            frameContainer.rightResizer:Show()
        end
    end,

    ---check the lock state and show or hide the resizer, set the frame as movable or not, resizeable or not
    ---@param frameContainer df_framecontainer
    CheckResizeLockedState = function(frameContainer)
        if (frameContainer.options.is_locked) then
            frameContainer:HideResizer()
            frameContainer:SetResizable(false)
        else
            frameContainer:ShowResizer()
            frameContainer:SetResizable(true)
        end
    end,

    ---check if the framecontainer can be moved and show or hide the mover
    ---@param frameContainer df_framecontainer
    CheckMovableLockedState = function(frameContainer)
        if (frameContainer.options.is_movement_locked) then
            frameContainer:SetMovable(false)
            frameContainer:EnableMouse(false)
            frameContainer.moverFrame:Hide()
        else
            frameContainer:SetMovable(true)
            frameContainer:EnableMouse(true)
            frameContainer.moverFrame:Show()
        end
    end,

    ---set the lock state
    ---@param frameContainer df_framecontainer
    ---@param isLocked boolean
    SetResizeLocked = function(frameContainer, isLocked)
        frameContainer.options.is_locked = isLocked
        frameContainer:SendSettingChangedCallback("is_locked", isLocked)
        frameContainer:CheckResizeLockedState()
    end,

    ---set the state of the mover frame
    ---@param frameContainer df_framecontainer
    ---@param isLocked boolean
    SetMovableLocked = function(frameContainer, isLocked)
        frameContainer.options.is_movement_locked = isLocked
        frameContainer:SendSettingChangedCallback("is_movement_locked", isLocked)
        frameContainer:CheckMovableLockedState()
    end,

    ---create a mover to move the frame
    ---@param frameContainer df_framecontainer
    CreateMover = function(frameContainer)
        local mover = CreateFrame("button", nil, frameContainer)
        frameContainer.moverFrame = mover
        mover:SetAllPoints(frameContainer)
        mover:EnableMouse(false)
        mover:SetMovable(true)
        mover:SetScript("OnMouseDown", function(self, mouseButton)
            if (mouseButton ~= "LeftButton" or frameContainer.options.is_movement_locked) then
                return
            end
            frameContainer:StartMoving()
        end)
        mover:SetScript("OnMouseUp", function(self, mouseButton)
            if (mouseButton ~= "LeftButton" or frameContainer.options.is_movement_locked) then
                return
            end
            frameContainer:StopMovingOrSizing()
        end)
    end,

    ---create four corner resizer and four side resizer
    ---@param frameContainer df_framecontainer
    CreateResizers = function(frameContainer)
        local parent = frameContainer:GetParent()
        --create resizers for the container corners
        local bottomLeftResizer, bottomRightResizer = detailsFramework:CreateResizeGrips(frameContainer, nil, parent:GetName() .. "BottomLeftResizer", parent:GetName() .. "BottomRightResizer")
        frameContainer.bottomLeftResizer = bottomLeftResizer
        frameContainer.bottomRightResizer = bottomRightResizer

        local topLeftResizer, topRightResizer = detailsFramework:CreateResizeGrips(frameContainer, nil, parent:GetName() .. "TopLeftResizer", parent:GetName() .. "TopRightResizer")
        frameContainer.topLeftResizer = topLeftResizer
        frameContainer.topRightResizer = topRightResizer

        local topResizer, bottomResizer = detailsFramework:CreateResizeGrips(frameContainer, nil, parent:GetName() .. "TopResizer", parent:GetName() .. "BottomResizer")
        frameContainer.topResizer = topResizer
        frameContainer.bottomResizer = bottomResizer

        local leftResizer, rightResizer = detailsFramework:CreateResizeGrips(frameContainer, nil, parent:GetName() .. "LeftResizer", parent:GetName() .. "RightResizer")
        frameContainer.leftResizer = leftResizer
        frameContainer.rightResizer = rightResizer

        frameContainer.cornerResizers = {
            bottomLeftResizer,
            bottomRightResizer,
            topLeftResizer,
            topRightResizer,
        }

        frameContainer.sideResizers = {
            topResizer,
            bottomResizer,
            leftResizer,
            rightResizer,
        }

        --add all resizers to the frameContainer.components table
        for i = 1, #frameContainer.cornerResizers do
            frameContainer.components[frameContainer.cornerResizers[i]] = true
        end
        for i = 1, #frameContainer.sideResizers do
            frameContainer.components[frameContainer.sideResizers[i]] = true
        end

        --hide all resizers
        frameContainer:HideResizer()
    end,

    ---run when the container is created
    ---@param frameContainer df_framecontainer
    OnInitialize = function(frameContainer) --õninit ~init ~oninit
        --set the default members
        frameContainer.bIsSizing = false
        frameContainer:SetSize(frameContainer.options.width, frameContainer.options.height)

        --iterate among the corner resizers and set the mouse down and up scripts
        for i = 1, #frameContainer.cornerResizers do
            frameContainer.cornerResizers[i]:SetScript("OnMouseDown", frameContainer.OnResizerMouseDown)
            frameContainer.cornerResizers[i]:SetScript("OnMouseUp", frameContainer.OnResizerMouseUp)
        end

        local sideResizeThickness = 2

        --iterate among the side resizers and set the mouse down and up scripts; set the texture color; clear all points; set the thickness
        for i = 1, #frameContainer.sideResizers do
            frameContainer.sideResizers[i]:SetScript("OnMouseDown", frameContainer.OnResizerMouseDown)
            frameContainer.sideResizers[i]:SetScript("OnMouseUp", frameContainer.OnResizerMouseUp)

            frameContainer.sideResizers[i]:GetNormalTexture():SetColorTexture(1, 1, 1, 0.6)
            frameContainer.sideResizers[i]:GetHighlightTexture():SetColorTexture(detailsFramework:ParseColors("aqua"))
            frameContainer.sideResizers[i]:GetPushedTexture():SetColorTexture(1, 1, 1, 1)

            frameContainer.sideResizers[i]:ClearAllPoints()

            --can use SetSize here because the width or height are set by the point, e.g. 'topleft' to 'topright' overwrite the width set here
            frameContainer.sideResizers[i]:SetSize(sideResizeThickness, sideResizeThickness)
        end

        --flip the corner resizers texturess
		frameContainer.topLeftResizer:GetNormalTexture():SetTexCoord(1, 0, 1, 0)
		frameContainer.topLeftResizer:GetHighlightTexture():SetTexCoord(1, 0, 1, 0)
		frameContainer.topLeftResizer:GetPushedTexture():SetTexCoord(1, 0, 1, 0)
		frameContainer.topRightResizer:GetNormalTexture():SetTexCoord(0, 1, 1, 0)
		frameContainer.topRightResizer:GetHighlightTexture():SetTexCoord(0, 1, 1, 0)
		frameContainer.topRightResizer:GetPushedTexture():SetTexCoord(0, 1, 1, 0)
        frameContainer.topLeftResizer:ClearAllPoints()
        frameContainer.topLeftResizer:SetPoint("topleft", frameContainer, "topleft", 0, 0)
        frameContainer.topRightResizer:ClearAllPoints()
        frameContainer.topRightResizer:SetPoint("topright", frameContainer, "topright", 0, 0)

        --resize from for the corner resizers
        frameContainer.bottomLeftResizer.sizingFrom = "bottomleft"
        frameContainer.bottomRightResizer.sizingFrom = "bottomright"
        frameContainer.topLeftResizer.sizingFrom = "topleft"
        frameContainer.topRightResizer.sizingFrom = "topright"

        --resize from for the side resizers
        frameContainer.topResizer.sizingFrom = "top"
        frameContainer.bottomResizer.sizingFrom = "bottom"
        frameContainer.leftResizer.sizingFrom = "left"
        frameContainer.rightResizer.sizingFrom = "right"

        --set the side resizer points
        frameContainer.topResizer:SetPoint("topleft", frameContainer, "topleft", 0, 2)
        frameContainer.topResizer:SetPoint("topright", frameContainer, "topright", 0, 2)
        frameContainer.bottomResizer:SetPoint("bottomleft", frameContainer, "bottomleft", 0, -2)
        frameContainer.bottomResizer:SetPoint("bottomright", frameContainer, "bottomright", 0, -2)
        frameContainer.leftResizer:SetPoint("topleft", frameContainer, "topleft", -2, 0)
        frameContainer.leftResizer:SetPoint("bottomleft", frameContainer, "bottomleft", -2, 0)
        frameContainer.rightResizer:SetPoint("topright", frameContainer, "topright", 2, 0)
        frameContainer.rightResizer:SetPoint("bottomright", frameContainer, "bottomright", 2, 0)

        if (frameContainer.options.is_locked) then
            frameContainer:HideResizer()
        else
            frameContainer:ShowResizer()
        end

        frameContainer:CheckResizeLockedState()
        frameContainer:CheckMovableLockedState()


        frameContainer:SetResizeBounds(50, 50, 1000, 1000) --new versions has this method

    end,

    ---run when the container has its size changed
    ---@param frameContainer df_framecontainer
    OnSizeChanged = function(frameContainer)
        ---@type frame[]
        local children = {frameContainer:GetChildren()}
        ---@type number
        local childrenAmount = #children

        --get the container size before its size was changed and calculate the percent of the difference between the old size and the new size
        --adding +1 to the width and height difference to prevent the child from shrinking to 0, so it is scaled by 1
        ---@type number
        local widthDifference = 1 + (frameContainer:GetWidth() - frameContainer.currentWidth) / frameContainer.currentWidth
        ---@type number
        local heightDifference = 1 + (frameContainer:GetHeight() - frameContainer.currentHeight) / frameContainer.currentHeight

        for i = 1, childrenAmount do
            ---@type frame
            local child = children[i]
            --if the child is a component, skip it
            if (not frameContainer.components[child]) then
                child:SetWidth(child:GetWidth() * widthDifference)
                child:SetHeight(child:GetHeight() * heightDifference)
            end
        end

        --update the current size of the container
        frameContainer.currentWidth = frameContainer:GetWidth()
        frameContainer.currentHeight = frameContainer:GetHeight()

        frameContainer:SendSettingChangedCallback("width", frameContainer.currentWidth)
        frameContainer:SendSettingChangedCallback("height", frameContainer.currentHeight)
    end,

    OnChildDragStop = function(child)
        child:StopMovingOrSizing()
        child:SetScript("OnUpdate", nil)
    end,

    ---@param child frame
    OnChildDragStart = function(child)
        ---@type df_framecontainer
        local frameContainer = child:GetParent()

        ---get the coordinates for the frame container, which is called 'boundingBox' for convenience
        ---@type objectcoordinates
        local boundingBox = detailsFramework:GetObjectCoordinates(frameContainer)

        child:StartMoving()

        --save the current point of the child, so it can be restored if the child is dragged outside the container
        local childPoints = {}
        for pointIndex = 1, child:GetNumPoints() do
            childPoints[pointIndex] = {child:GetPoint(pointIndex)}
        end

        child:SetScript("OnUpdate", function(self)
            ---@type objectcoordinates
            local childPos = detailsFramework:GetObjectCoordinates(self)
            --check if the borders of the rectangle 'rec' collided with the borders of the rectangle 'bbox'
            if ((childPos.left < boundingBox.left or childPos.right > boundingBox.right) or (childPos.top > boundingBox.top or childPos.bottom < boundingBox.bottom)) then
                child:ClearAllPoints()
                for pointIndex = 1, #childPoints do
                    child:SetPoint(unpack(childPoints[pointIndex]))
                end
            else
                wipe(childPoints)
                for pointIndex = 1, child:GetNumPoints() do
                    childPoints[pointIndex] = {child:GetPoint(pointIndex)}
                end
            end
        end)
    end,

    ---check if the children can be moved and set the properties on thisFrame
    ---@param frameContainer df_framecontainer
    RefreshChildrenState = function(frameContainer)
        frameContainer:EnableMouse(true)
        if (frameContainer.options.can_move_children) then
            for child, _ in pairs(frameContainer.movableChildren) do
                child:EnableMouse(true)
                child:SetMovable(true)
                child:RegisterForDrag("LeftButton")
                child:SetScript("OnDragStart", detailsFramework.FrameContainerMixin.OnChildDragStart)
                child:SetScript("OnDragStop", detailsFramework.FrameContainerMixin.OnChildDragStop)
            end
        else
            for child, _ in pairs(frameContainer.movableChildren) do
                child:EnableMouse(false)
                child:SetMovable(false)
                child:RegisterForDrag("")
                child:SetScript("OnDragStart", nil)
                child:SetScript("OnDragStop", nil)
            end
        end
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    RegisterChildForDrag = function(frameContainer, child)
        frameContainer.movableChildren[child] = true
        frameContainer:RefreshChildrenState()
        child:SetFrameStrata(frameContainer:GetFrameStrata())
        child:SetFrameLevel(frameContainer:GetFrameLevel() + 1)
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    UnregisterChildForDrag = function(frameContainer, child)
        frameContainer.movableChildren[child] = nil
        frameContainer:RefreshChildrenState()
    end,

    ---@param frameContainer df_framecontainer
    ---@param callback function
    SetSettingChangedCallback = function(frameContainer, callback)
        frameContainer.settingChangedCallback = callback
    end,

    ---send a callback to the setting changed callback
    ---@param frameContainer df_framecontainer
    ---@param key string
    ---@param value any
    SendSettingChangedCallback = function(frameContainer, key, value)
        if (type(frameContainer.settingChangedCallback) == "function") then
            detailsFramework:Dispatch(frameContainer.settingChangedCallback, frameContainer, key, value)
        end
    end,
}

---these are the default settings for the frame container; these keys can be accessed by df_framecontainer.options[key]
---@type table<string, any>
local frameContainerOptions = {
    --default settings
    width = 300,
    height = 150,
    is_locked = true, --can or not be resized
    is_movement_locked = true, --can or not be moved
    can_move_children = true,
    use_topleft_resizer = false,
    use_topright_resizer = false,
    use_bottomleft_resizer = false,
    use_bottomright_resizer = false,
    use_top_resizer = false,
    use_bottom_resizer = false,
    use_left_resizer = false,
    use_right_resizer = false,
}

---create a frame container, which is a frame that envelops another frame, and can be moved, resized, etc.
---@param parent frame
---@param options table|nil
---@param frameName string|nil
---@return df_framecontainer
function DF:CreateFrameContainer(parent, options, frameName)
    ---@type df_framecontainer
    local frameContainer = CreateFrame("frame", frameName or ("$parentFrameContainer" .. math.random(10000, 99999)), parent, "BackdropTemplate")
    frameContainer.components = {}
    frameContainer.movableChildren = {}
    frameContainer:EnableMouse(false)

    detailsFramework:Mixin(frameContainer, detailsFramework.FrameContainerMixin)
    detailsFramework:Mixin(frameContainer, detailsFramework.OptionsFunctions)

    frameContainer:CreateResizers()
    frameContainer:CreateMover()
    frameContainer:BuildOptionsTable(frameContainerOptions, options)

    frameContainer:OnInitialize()

    frameContainer.currentWidth = frameContainer:GetWidth()
    frameContainer.currentHeight = frameContainer:GetHeight()
    frameContainer:SetScript("OnSizeChanged", frameContainer.OnSizeChanged)

    return frameContainer
end




function DF:CreateFrameContainerTest(parent, options, frameName)
    local container = DF:CreateFrameContainer(parent, options, frameName)
    container:SetSize(400, 400)
    container:SetPoint("center", _G.UIParent, "center", 0, 0)

    detailsFramework:ApplyStandardBackdrop(container)

    local verticalLastBox = nil
    for i = 1, 4 do
        local lastBox = nil
        for o = 1, 4 do
            local frame = CreateFrame("frame", "$parentFrame" .. i .. o, container, "BackdropTemplate")
            container:RegisterChildForDrag(frame)

            frame:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            frame:SetBackdropColor(0, 0, 0, 0.5)
            frame:SetBackdropBorderColor(1, 1, 1, 0.5)
            frame:SetSize(98, 98)
            if (lastBox) then
                frame:SetPoint("TOPLEFT", lastBox, "topright", 1, 0)
            else
                if (verticalLastBox) then
                    frame:SetPoint("TOPLEFT", verticalLastBox, "bottomleft", 0, -1)
                    verticalLastBox = frame
                else
                    local x = 1 + (o - 1) * 99
                    local y = -10 - (i - 1) * 99
                    frame:SetPoint("TOPLEFT", container, "TOPLEFT", x, y)
                    verticalLastBox = frame
                end
            end
            lastBox = frame
        end
    end

    C_Timer.After(2, function()
        --container:SetResizeLocked(true)
    end)
end

--C_Timer.After(2, function()
--    DetailsFramework:CreateFrameContainerTest(UIParent)
--end)

--[=[
    /run DetailsFramework:CreateFrameContainerTest(UIParent)

    C_Timer.After(2, function()
        DetailsFramework:CreateFrameContainerTest(UIParent)
    end)   
   
   
--]=]