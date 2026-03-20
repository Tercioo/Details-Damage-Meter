
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local DF = detailsFramework

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local IsMouseButtonDown = IsMouseButtonDown
local childResizerThickness = 4
local childMinimumSize = 20
local childResizerOptionBySide = {
    top = "use_top_child_resizer",
    bottom = "use_bottom_child_resizer",
    left = "use_left_child_resizer",
    right = "use_right_child_resizer",
}

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
---@field LeftResizeGrip df_resizergrip
---@field RightResizeGrip df_resizergrip
---@field components table<frame, boolean>
---@field moverFrame frame
---@field movableChildren table<frame, boolean>
---@field childResizers table<frame, table<string, button>>
---@field childResizerSideOverrides table<frame, table<string, boolean>>
---@field activeChildResizeState table|nil
---@field settingChangedCallback fun(frameContainer: df_framecontainer, settingName: string, settingValue: any)
---@field OnSizeChanged fun(frameContainer: df_framecontainer)
---@field OnResizerMouseDown fun(resizerButton: button, mouseButton: string)
---@field OnResizerMouseUp fun(resizerButton: button, mouseButton: string)
---@field HideResizer fun(frameContainer: df_framecontainer)
---@field ShowResizer fun(frameContainer: df_framecontainer)
---@field HideResizeGrips fun(frameContainer: df_framecontainer)
---@field ShowResizeGrips fun(frameContainer: df_framecontainer)
---@field OnInitialize fun(frameContainer: df_framecontainer)
---@field SetResizeLocked fun(frameContainer: df_framecontainer, isLocked: boolean)
---@field SetMovableLocked fun(frameContainer: df_framecontainer, isLocked: boolean)
---@field CheckResizeLockedState fun(frameContainer: df_framecontainer)
---@field CheckMovableLockedState fun(frameContainer: df_framecontainer)
---@field CreateMover fun(frameContainer: df_framecontainer)
---@field CreateResizers fun(frameContainer: df_framecontainer)
---@field RegisterChildForDrag fun(frameContainer: df_framecontainer, child: frame)
---@field RegisterChild fun(frameContainer: df_framecontainer, child: frame)
---@field UnregisterChild fun(frameContainer: df_framecontainer, child: frame)
---@field RefreshChildrenState fun(frameContainer: df_framecontainer)
---@field GetChildRelativeRect fun(frameContainer: df_framecontainer, child: frame): table|nil
---@field SetChildRelativeRect fun(frameContainer: df_framecontainer, child: frame, left: number, top: number, width: number, height: number)
---@field GetChildrenForResize fun(frameContainer: df_framecontainer, child: frame, resizeSide: string): table
---@field CreateChildResizers fun(frameContainer: df_framecontainer, child: frame)
---@field IsChildResizerSideEnabled fun(frameContainer: df_framecontainer, child: frame, resizeSide: string): boolean
---@field SetChildResizersShown fun(frameContainer: df_framecontainer, child: frame, shouldShow: boolean)
---@field SetChildResizerSides fun(frameContainer: df_framecontainer, child: frame, sideSettings: table|nil)
---@field OnChildResizerMouseDown fun(resizerButton: button, mouseButton: string)
---@field OnChildResizerMouseUp fun(resizerButton: button, mouseButton: string)
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
            frameContainer:SetResizable(true)
        end

        if frameContainer.options.show_resize_grips then
            frameContainer:SetResizable(true)
            frameContainer:ShowResizeGrips()
        else
            frameContainer:HideResizeGrips()
            if frameContainer.options.is_locked then
                frameContainer:ShowResizer()
                frameContainer:SetResizable(false)
            end
        end
    end,

    ShowResizeGrips = function(frameContainer) --internal
        frameContainer.LeftResizeGrip:Show()
        frameContainer.RightResizeGrip:Show()
    end,
    HideResizeGrips = function(frameContainer) --internal
        frameContainer.LeftResizeGrip:Hide()
        frameContainer.RightResizeGrip:Hide()
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

        frameContainer:SetResizeBounds(50, 50, 1920, 1440) --new versions has this method
    end,

    ---run when the container has its size changed
    ---@param frameContainer df_framecontainer
    OnSizeChanged = function(frameContainer)
        local oldWidth = frameContainer.currentWidth or 0
        local oldHeight = frameContainer.currentHeight or 0
        local newWidth = frameContainer:GetWidth() or oldWidth
        local newHeight = frameContainer:GetHeight() or oldHeight

        if (oldWidth <= 0 or oldHeight <= 0) then
            frameContainer.currentWidth = newWidth
            frameContainer.currentHeight = newHeight
            frameContainer:SendSettingChangedCallback("width", frameContainer.currentWidth)
            frameContainer:SendSettingChangedCallback("height", frameContainer.currentHeight)
            return
        end

        local widthDifference = newWidth / oldWidth
        local heightDifference = newHeight / oldHeight
        local containerLeft = frameContainer:GetLeft()
        local containerTop = frameContainer:GetTop()
        local children = {frameContainer:GetChildren()}
        local childrenAmount = #children

        if (not containerLeft or not containerTop) then
            frameContainer.currentWidth = newWidth
            frameContainer.currentHeight = newHeight
            frameContainer:SendSettingChangedCallback("width", frameContainer.currentWidth)
            frameContainer:SendSettingChangedCallback("height", frameContainer.currentHeight)
            return
        end

        for i = 1, childrenAmount do
            local child = children[i]
            if (not frameContainer.components[child]) then
                local childLeft = child:GetLeft()
                local childTop = child:GetTop()
                local childWidth = child:GetWidth() or 0
                local childHeight = child:GetHeight() or 0

                if (childLeft and childTop and childWidth > 0 and childHeight > 0) then
                    local relativeX = childLeft - containerLeft
                    local relativeY = containerTop - childTop

                    local newChildWidth = childWidth * widthDifference
                    local newChildHeight = childHeight * heightDifference
                    local newRelativeX = relativeX * widthDifference
                    local newRelativeY = relativeY * heightDifference

                    local maxX = math.max(0, newWidth - newChildWidth)
                    local maxY = math.max(0, newHeight - newChildHeight)
                    newRelativeX = math.min(math.max(newRelativeX, 0), maxX)
                    newRelativeY = math.min(math.max(newRelativeY, 0), maxY)

                    child:ClearAllPoints()
                    child:SetPoint("topleft", frameContainer, "topleft", newRelativeX, -newRelativeY)
                    child:SetWidth(newChildWidth)
                    child:SetHeight(newChildHeight)
                end
            end
        end

        frameContainer.currentWidth = newWidth
        frameContainer.currentHeight = newHeight

        frameContainer:SendSettingChangedCallback("width", frameContainer.currentWidth)
        frameContainer:SendSettingChangedCallback("height", frameContainer.currentHeight)
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    ---@return table|nil
    GetChildRelativeRect = function(frameContainer, child)
        local containerLeft = frameContainer:GetLeft()
        local containerTop = frameContainer:GetTop()
        local childLeft = child:GetLeft()
        local childTop = child:GetTop()
        local childWidth = child:GetWidth()
        local childHeight = child:GetHeight()

        if (not containerLeft or not containerTop or not childLeft or not childTop or not childWidth or not childHeight) then
            return nil
        end

        local left = childLeft - containerLeft
        local top = containerTop - childTop
        local right = left + childWidth
        local bottom = top + childHeight

        return {
            left = left,
            top = top,
            right = right,
            bottom = bottom,
            width = childWidth,
            height = childHeight,
        }
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    ---@param left number
    ---@param top number
    ---@param width number
    ---@param height number
    SetChildRelativeRect = function(frameContainer, child, left, top, width, height)
        child:ClearAllPoints()
        child:SetPoint("topleft", frameContainer, "topleft", left, -top)
        child:SetWidth(width)
        child:SetHeight(height)
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    ---@param resizeSide string
    ---@return table
    GetChildrenForResize = function(frameContainer, child, resizeSide)
        local childRect = frameContainer:GetChildRelativeRect(child)
        if (not childRect) then
            return {}
        end

        local candidateChildren = {}
        local nearestDistance
        local distanceTolerance = 0.75

        local isRangeOverlap = function(aStart, aEnd, bStart, bEnd)
            return aStart < bEnd and aEnd > bStart
        end

        for sibling in pairs(frameContainer.movableChildren) do
            if (sibling ~= child and sibling:IsShown()) then
                local siblingRect = frameContainer:GetChildRelativeRect(sibling)
                if (siblingRect) then
                    local isCandidate = false
                    local distance = 0

                    if (resizeSide == "left") then
                        if (isRangeOverlap(childRect.top, childRect.bottom, siblingRect.top, siblingRect.bottom) and siblingRect.right <= childRect.left + 0.5) then
                            distance = childRect.left - siblingRect.right
                            isCandidate = true
                        end
                    elseif (resizeSide == "right") then
                        if (isRangeOverlap(childRect.top, childRect.bottom, siblingRect.top, siblingRect.bottom) and siblingRect.left >= childRect.right - 0.5) then
                            distance = siblingRect.left - childRect.right
                            isCandidate = true
                        end
                    elseif (resizeSide == "top") then
                        if (isRangeOverlap(childRect.left, childRect.right, siblingRect.left, siblingRect.right) and siblingRect.bottom <= childRect.top + 0.5) then
                            distance = childRect.top - siblingRect.bottom
                            isCandidate = true
                        end
                    elseif (resizeSide == "bottom") then
                        if (isRangeOverlap(childRect.left, childRect.right, siblingRect.left, siblingRect.right) and siblingRect.top >= childRect.bottom - 0.5) then
                            distance = siblingRect.top - childRect.bottom
                            isCandidate = true
                        end
                    end

                    if (isCandidate) then
                        if (distance < 0) then
                            distance = 0
                        end

                        if (not nearestDistance or distance < nearestDistance) then
                            nearestDistance = distance
                        end

                        candidateChildren[#candidateChildren+1] = {
                            child = sibling,
                            rect = siblingRect,
                            distance = distance,
                        }
                    end
                end
            end
        end

        if (not nearestDistance) then
            return {}
        end

        local nearestChildren = {}
        for i = 1, #candidateChildren do
            local childData = candidateChildren[i]
            if (math.abs(childData.distance - nearestDistance) <= distanceTolerance) then
                nearestChildren[#nearestChildren+1] = childData
            end
        end

        return nearestChildren
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    CreateChildResizers = function(frameContainer, child)
        if (frameContainer.childResizers[child]) then
            return
        end

        local createResizer = function(resizeSide)
            local resizer = CreateFrame("button", nil, child)
            resizer.frameContainer = frameContainer
            resizer.ownerChild = child
            resizer.resizeSide = resizeSide
            resizer:SetFrameStrata(frameContainer:GetFrameStrata())
            resizer:SetFrameLevel(child:GetFrameLevel() + 20)
            resizer:EnableMouse(true)
            resizer:RegisterForClicks("LeftButtonDown", "LeftButtonUp")

            resizer:SetNormalTexture([[Interface\Buttons\WHITE8X8]])
            resizer:SetHighlightTexture([[Interface\Buttons\WHITE8X8]])
            resizer:SetPushedTexture([[Interface\Buttons\WHITE8X8]])
            resizer:GetNormalTexture():SetColorTexture(1, 1, 1, 0.25)
            resizer:GetHighlightTexture():SetColorTexture(detailsFramework:ParseColors("aqua"))
            resizer:GetPushedTexture():SetColorTexture(1, 1, 1, 0.85)

            resizer:SetScript("OnMouseDown", detailsFramework.FrameContainerMixin.OnChildResizerMouseDown)
            resizer:SetScript("OnMouseUp", detailsFramework.FrameContainerMixin.OnChildResizerMouseUp)

            if (resizeSide == "left") then
                resizer:SetWidth(childResizerThickness)
                resizer:SetPoint("topleft", child, "topleft", -2, 0)
                resizer:SetPoint("bottomleft", child, "bottomleft", -2, 0)
            elseif (resizeSide == "right") then
                resizer:SetWidth(childResizerThickness)
                resizer:SetPoint("topright", child, "topright", 2, 0)
                resizer:SetPoint("bottomright", child, "bottomright", 2, 0)
            elseif (resizeSide == "top") then
                resizer:SetHeight(childResizerThickness)
                resizer:SetPoint("topleft", child, "topleft", 0, 2)
                resizer:SetPoint("topright", child, "topright", 0, 2)
            else
                resizer:SetHeight(childResizerThickness)
                resizer:SetPoint("bottomleft", child, "bottomleft", 0, -2)
                resizer:SetPoint("bottomright", child, "bottomright", 0, -2)
            end

            resizer:Hide()
            return resizer
        end

        frameContainer.childResizers[child] = {
            left = createResizer("left"),
            right = createResizer("right"),
            top = createResizer("top"),
            bottom = createResizer("bottom"),
        }
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    ---@param resizeSide string
    ---@return boolean
    IsChildResizerSideEnabled = function(frameContainer, child, resizeSide)
        local sideOptionName = childResizerOptionBySide[resizeSide]
        if (not sideOptionName) then
            return false
        end

        local childSideOverrides = frameContainer.childResizerSideOverrides[child]
        if (childSideOverrides and childSideOverrides[resizeSide] ~= nil) then
            return childSideOverrides[resizeSide]
        end

        return frameContainer.options[sideOptionName] and true or false
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    ---@param shouldShow boolean
    SetChildResizersShown = function(frameContainer, child, shouldShow)
        if (shouldShow and not frameContainer.childResizers[child]) then
            frameContainer:CreateChildResizers(child)
        end

        local childResizers = frameContainer.childResizers[child]
        if (not childResizers) then
            return
        end

        for resizeSide, resizer in pairs(childResizers) do
            local canUseSideResizer = frameContainer:IsChildResizerSideEnabled(child, resizeSide)

            if (shouldShow and canUseSideResizer) then
                resizer:Show()
            else
                resizer:Hide()
                if (frameContainer.activeChildResizeState and frameContainer.activeChildResizeState.resizer == resizer) then
                    resizer:SetScript("OnUpdate", nil)
                    frameContainer.activeChildResizeState = nil
                end
            end
        end
    end,

    ---set per-child side settings for child resizers; keys can be top, bottom, left, right
    ---or their option aliases (use_top_child_resizer, use_bottom_child_resizer, use_left_child_resizer, use_right_child_resizer)
    ---@param frameContainer df_framecontainer
    ---@param child frame
    ---@param sideSettings table|nil
    SetChildResizerSides = function(frameContainer, child, sideSettings)
        assert(type(child) == "table" and child.GetObjectType, "SetChildResizerSides expects a frame as the child parameter.")
        assert(frameContainer.movableChildren[child], "SetChildResizerSides expects a registered child frame. Register with 'RegisterChild' before setting child resizer sides.")
        assert(type(sideSettings) == "table", "SetChildResizerSides expects the sideSettings parameter to be a table.")

        local childSideOverrides = {}
        local hasOverride = false

        for resizeSide, sideOptionName in pairs(childResizerOptionBySide) do
            local sideEnabled = sideSettings[resizeSide]
            if (sideEnabled == nil) then
                sideEnabled = sideSettings[sideOptionName]
            end

            if (type(sideEnabled) == "boolean") then
                childSideOverrides[resizeSide] = sideEnabled
                hasOverride = true
            end
        end

        if (hasOverride) then
            frameContainer.childResizerSideOverrides[child] = childSideOverrides
        else
            frameContainer.childResizerSideOverrides[child] = nil
        end

        local canShowResizers = frameContainer.options.can_resize_children and not frameContainer.options.can_move_children
        frameContainer:SetChildResizersShown(child, canShowResizers)
    end,

    ---@param resizerButton button
    ---@param mouseButton string
    OnChildResizerMouseDown = function(resizerButton, mouseButton)
        if (mouseButton ~= "LeftButton") then
            return
        end

        ---@type df_framecontainer
        local frameContainer = resizerButton.frameContainer
        local child = resizerButton.ownerChild
        local resizeSide = resizerButton.resizeSide
        if (not frameContainer or not child or not resizeSide) then
            return
        end

        if (frameContainer.options.can_move_children or not frameContainer.options.can_resize_children) then
            return
        end

        if (not frameContainer:IsChildResizerSideEnabled(child, resizeSide)) then
            return
        end

        if (frameContainer.activeChildResizeState) then
            return
        end

        local childRect = frameContainer:GetChildRelativeRect(child)
        local containerLeft = frameContainer:GetLeft()
        local containerTop = frameContainer:GetTop()
        if (not childRect or not containerLeft or not containerTop) then
            return
        end

        local neighborChildren = frameContainer:GetChildrenForResize(child, resizeSide)
        local mouseX, mouseY = DF:GetCursorPosition()

        local startCursorRelativeX = mouseX - containerLeft
        local startCursorRelativeY = containerTop - mouseY

        frameContainer.activeChildResizeState = {
            resizer = resizerButton,
            child = child,
            resizeSide = resizeSide,
            childStartRect = childRect,
            neighborChildren = neighborChildren,
            startCursorRelativeX = startCursorRelativeX,
            startCursorRelativeY = startCursorRelativeY,
            minSize = childMinimumSize,
        }

        resizerButton:SetScript("OnUpdate", function(thisResizer)
            local resizeState = frameContainer.activeChildResizeState

            if (not resizeState or resizeState.resizer ~= thisResizer) then
                thisResizer:SetScript("OnUpdate", nil)
                return
            end

            if (IsMouseButtonDown and not IsMouseButtonDown("LeftButton")) then
                thisResizer:SetScript("OnUpdate", nil)
                frameContainer.activeChildResizeState = nil
                return
            end

            if (frameContainer.options.can_move_children or not frameContainer.options.can_resize_children) then
                thisResizer:SetScript("OnUpdate", nil)
                frameContainer.activeChildResizeState = nil
                return
            end

            if (not frameContainer:IsChildResizerSideEnabled(resizeState.child, resizeState.resizeSide)) then
                thisResizer:SetScript("OnUpdate", nil)
                frameContainer.activeChildResizeState = nil
                return
            end

            local currentContainerLeft = frameContainer:GetLeft()
            local currentContainerTop = frameContainer:GetTop()
            local containerWidth = frameContainer:GetWidth() or 0
            local containerHeight = frameContainer:GetHeight() or 0

            if (not currentContainerLeft or not currentContainerTop) then
                return
            end

            local currentCursorX, currentCursorY = DF:GetCursorPosition()
            local currentCursorRelativeX = currentCursorX - currentContainerLeft
            local currentCursorRelativeY = currentContainerTop - currentCursorY

            local deltaX = currentCursorRelativeX - resizeState.startCursorRelativeX
            local deltaY = currentCursorRelativeY - resizeState.startCursorRelativeY

            local startRect = resizeState.childStartRect
            local side = resizeState.resizeSide
            local minSize = resizeState.minSize
            local newChildLeft = startRect.left
            local newChildTop = startRect.top
            local newChildWidth = startRect.width
            local newChildHeight = startRect.height

            local neighborChildren = resizeState.neighborChildren or {}

            if (side == "right") then
                local targetRight = startRect.right + deltaX
                local minRight = startRect.left + minSize
                local maxRight = containerWidth

                for i = 1, #neighborChildren do
                    local neighborRect = neighborChildren[i].rect
                    maxRight = math.min(maxRight, neighborRect.right - minSize)
                end

                if (maxRight < minRight) then
                    maxRight = minRight
                end

                local newRight = math.min(math.max(targetRight, minRight), maxRight)
                newChildWidth = newRight - startRect.left

                frameContainer:SetChildRelativeRect(child, newChildLeft, newChildTop, newChildWidth, newChildHeight)

                for i = 1, #neighborChildren do
                    local neighborData = neighborChildren[i]
                    local neighborRect = neighborData.rect
                    local newNeighborLeft = newRight
                    local newNeighborWidth = neighborRect.right - newNeighborLeft
                    frameContainer:SetChildRelativeRect(neighborData.child, newNeighborLeft, neighborRect.top, newNeighborWidth, neighborRect.height)
                end

            elseif (side == "left") then
                local targetLeft = startRect.left + deltaX
                local minLeft = 0
                local maxLeft = startRect.right - minSize

                for i = 1, #neighborChildren do
                    local neighborRect = neighborChildren[i].rect
                    minLeft = math.max(minLeft, neighborRect.left + minSize)
                end

                if (maxLeft < minLeft) then
                    minLeft = maxLeft
                end

                local newLeft = math.min(math.max(targetLeft, minLeft), maxLeft)
                newChildLeft = newLeft
                newChildWidth = startRect.right - newLeft

                frameContainer:SetChildRelativeRect(child, newChildLeft, newChildTop, newChildWidth, newChildHeight)

                for i = 1, #neighborChildren do
                    local neighborData = neighborChildren[i]
                    local neighborRect = neighborData.rect
                    local newNeighborWidth = newLeft - neighborRect.left
                    frameContainer:SetChildRelativeRect(neighborData.child, neighborRect.left, neighborRect.top, newNeighborWidth, neighborRect.height)
                end

            elseif (side == "bottom") then
                local targetBottom = startRect.bottom + deltaY
                local minBottom = startRect.top + minSize
                local maxBottom = containerHeight

                for i = 1, #neighborChildren do
                    local neighborRect = neighborChildren[i].rect
                    maxBottom = math.min(maxBottom, neighborRect.bottom - minSize)
                end

                if (maxBottom < minBottom) then
                    maxBottom = minBottom
                end

                local newBottom = math.min(math.max(targetBottom, minBottom), maxBottom)
                newChildHeight = newBottom - startRect.top

                frameContainer:SetChildRelativeRect(child, newChildLeft, newChildTop, newChildWidth, newChildHeight)

                for i = 1, #neighborChildren do
                    local neighborData = neighborChildren[i]
                    local neighborRect = neighborData.rect
                    local newNeighborTop = newBottom
                    local newNeighborHeight = neighborRect.bottom - newNeighborTop
                    frameContainer:SetChildRelativeRect(neighborData.child, neighborRect.left, newNeighborTop, neighborRect.width, newNeighborHeight)
                end

            elseif (side == "top") then
                local targetTop = startRect.top + deltaY
                local minTop = 0
                local maxTop = startRect.bottom - minSize

                for i = 1, #neighborChildren do
                    local neighborRect = neighborChildren[i].rect
                    minTop = math.max(minTop, neighborRect.top + minSize)
                end

                if (maxTop < minTop) then
                    minTop = maxTop
                end

                local newTop = math.min(math.max(targetTop, minTop), maxTop)
                newChildTop = newTop
                newChildHeight = startRect.bottom - newTop

                frameContainer:SetChildRelativeRect(child, newChildLeft, newChildTop, newChildWidth, newChildHeight)

                for i = 1, #neighborChildren do
                    local neighborData = neighborChildren[i]
                    local neighborRect = neighborData.rect
                    local newNeighborHeight = newTop - neighborRect.top
                    frameContainer:SetChildRelativeRect(neighborData.child, neighborRect.left, neighborRect.top, neighborRect.width, newNeighborHeight)
                end
            end
        end)
    end,

    ---@param resizerButton button
    ---@param mouseButton string
    OnChildResizerMouseUp = function(resizerButton, mouseButton)
        if (mouseButton ~= "LeftButton") then
            return
        end

        ---@type df_framecontainer
        local frameContainer = resizerButton.frameContainer
        if (not frameContainer) then
            return
        end

        resizerButton:SetScript("OnUpdate", nil)
        if (frameContainer.activeChildResizeState and frameContainer.activeChildResizeState.resizer == resizerButton) then
            frameContainer.activeChildResizeState = nil
        end
    end,

    OnChildDragStop = function(child)
        child:StopMovingOrSizing()
        child:SetScript("OnUpdate", nil)
    end,

    ---@param child frame
    OnChildDragStart = function(child)
        ---@type df_framecontainer
        local frameContainer = child:GetParent()
        if (not frameContainer or not frameContainer.movableChildren[child]) then
            return
        end

        local containerLeft = frameContainer:GetLeft()
        local containerTop = frameContainer:GetTop()
        local childLeft = child:GetLeft()
        local childTop = child:GetTop()
        if (not containerLeft or not containerTop or not childLeft or not childTop) then
            return
        end

        local childWidth = child:GetWidth() or 0
        local childHeight = child:GetHeight() or 0
        local containerWidth = frameContainer:GetWidth() or 0
        local containerHeight = frameContainer:GetHeight() or 0
        local maxX = math.max(0, containerWidth - childWidth)
        local maxY = math.max(0, containerHeight - childHeight)

        local initialX = math.min(math.max(childLeft - containerLeft, 0), maxX)
        local initialY = math.min(math.max(containerTop - childTop, 0), maxY)

        child:ClearAllPoints()
        child:SetPoint("topleft", frameContainer, "topleft", initialX, -initialY)

        local snappedChildLeft = containerLeft + initialX
        local snappedChildTop = containerTop - initialY

        local cursorX, cursorY = DF:GetCursorPosition()

        local grabOffsetX = cursorX - snappedChildLeft
        local grabOffsetY = snappedChildTop - cursorY

        local lastValidX = initialX
        local lastValidY = initialY

        local isOverlappingSibling = function(candidateX, candidateY)
            local thisLeft = candidateX
            local thisRight = candidateX + childWidth
            local thisTop = candidateY
            local thisBottom = candidateY + childHeight

            local currentContainerLeft = frameContainer:GetLeft()
            local currentContainerTop = frameContainer:GetTop()
            if (not currentContainerLeft or not currentContainerTop) then
                return false
            end

            for sibling in pairs(frameContainer.movableChildren) do
                if (sibling ~= child and sibling:IsShown()) then
                    local siblingLeft = sibling:GetLeft()
                    local siblingTop = sibling:GetTop()
                    if (siblingLeft and siblingTop) then
                        local siblingWidth = sibling:GetWidth() or 0
                        local siblingHeight = sibling:GetHeight() or 0

                        local siblingX = siblingLeft - currentContainerLeft
                        local siblingY = currentContainerTop - siblingTop
                        local siblingRight = siblingX + siblingWidth
                        local siblingBottom = siblingY + siblingHeight

                        local bNoHorizontalOverlap = (thisRight <= siblingX) or (thisLeft >= siblingRight)
                        local bNoVerticalOverlap = (thisBottom <= siblingY) or (thisTop >= siblingBottom)
                        if (not bNoHorizontalOverlap and not bNoVerticalOverlap) then
                            return true
                        end
                    end
                end
            end

            return false
        end

        local getClosestNonOverlappingPosition = function(startX, startY, targetX, targetY)
            if (isOverlappingSibling(startX, startY)) then
                return startX, startY
            end

            local bestX = startX
            local bestY = startY
            local low = 0
            local high = 1

            for i = 1, 12 do
                local mid = (low + high) * 0.5
                local testX = startX + (targetX - startX) * mid
                local testY = startY + (targetY - startY) * mid

                if (isOverlappingSibling(testX, testY)) then
                    high = mid
                else
                    bestX = testX
                    bestY = testY
                    low = mid
                end
            end

            return bestX, bestY
        end

        local getSlidingPosition = function(startX, startY, targetX, targetY)
            local xFirstX, xFirstY = getClosestNonOverlappingPosition(startX, startY, targetX, startY)
            xFirstX, xFirstY = getClosestNonOverlappingPosition(xFirstX, xFirstY, xFirstX, targetY)

            local yFirstX, yFirstY = getClosestNonOverlappingPosition(startX, startY, startX, targetY)
            yFirstX, yFirstY = getClosestNonOverlappingPosition(yFirstX, yFirstY, targetX, yFirstY)

            local xFirstDistance = math.abs(xFirstX - startX) + math.abs(xFirstY - startY)
            local yFirstDistance = math.abs(yFirstX - startX) + math.abs(yFirstY - startY)

            if (xFirstDistance >= yFirstDistance) then
                return xFirstX, xFirstY
            end

            return yFirstX, yFirstY
        end

        child:SetScript("OnUpdate", function(self)
            local currentContainerLeft = frameContainer:GetLeft()
            local currentContainerTop = frameContainer:GetTop()
            if (not currentContainerLeft or not currentContainerTop) then
                return
            end

            local currentScale = frameContainer:GetEffectiveScale()
            if (not currentScale or currentScale <= 0) then
                currentScale = 1
            end

            local currentCursorX, currentCursorY = GetCursorPosition()
            currentCursorX = currentCursorX / currentScale
            currentCursorY = currentCursorY / currentScale

            local currentContainerWidth = frameContainer:GetWidth() or 0
            local currentContainerHeight = frameContainer:GetHeight() or 0
            local currentMaxX = math.max(0, currentContainerWidth - childWidth)
            local currentMaxY = math.max(0, currentContainerHeight - childHeight)

            local candidateX = currentCursorX - currentContainerLeft - grabOffsetX
            local candidateY = currentContainerTop - currentCursorY - grabOffsetY
            candidateX = math.min(math.max(candidateX, 0), currentMaxX)
            candidateY = math.min(math.max(candidateY, 0), currentMaxY)

            if (isOverlappingSibling(candidateX, candidateY)) then
                candidateX, candidateY = getSlidingPosition(lastValidX, lastValidY, candidateX, candidateY)
                if (isOverlappingSibling(candidateX, candidateY)) then
                    candidateX = lastValidX
                    candidateY = lastValidY
                else
                    lastValidX = candidateX
                    lastValidY = candidateY
                end
            else
                lastValidX = candidateX
                lastValidY = candidateY
            end

            self:ClearAllPoints()
            self:SetPoint("topleft", frameContainer, "topleft", candidateX, -candidateY)
        end)
    end,

    ---check if the children can be moved and set the properties on thisFrame
    ---@param frameContainer df_framecontainer
    RefreshChildrenState = function(frameContainer)
        frameContainer:EnableMouse(true)
        local canMoveChildren = frameContainer.options.can_move_children
        local canResizeChildren = frameContainer.options.can_resize_children and not canMoveChildren

        if (canMoveChildren) then
            for child in pairs(frameContainer.movableChildren) do
                child:EnableMouse(true)
                child:SetMovable(true)
                child:RegisterForDrag("LeftButton")
                child:SetScript("OnDragStart", detailsFramework.FrameContainerMixin.OnChildDragStart)
                child:SetScript("OnDragStop", detailsFramework.FrameContainerMixin.OnChildDragStop)
                frameContainer:SetChildResizersShown(child, false)
            end
        else
            for child in pairs(frameContainer.movableChildren) do
                child:EnableMouse(false)
                child:SetMovable(false)
                child:RegisterForDrag("")
                child:SetScript("OnDragStart", nil)
                child:SetScript("OnDragStop", nil)

                if (canResizeChildren) then
                    frameContainer:SetChildResizersShown(child, true)
                else
                    frameContainer:SetChildResizersShown(child, false)
                end
            end
        end

        if (not canResizeChildren and frameContainer.activeChildResizeState) then
            local activeResizer = frameContainer.activeChildResizeState.resizer
            if (activeResizer) then
                activeResizer:SetScript("OnUpdate", nil)
            end
            frameContainer.activeChildResizeState = nil
        end
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    RegisterChild = function(frameContainer, child)
        frameContainer.movableChildren[child] = true
        child:SetFrameStrata(frameContainer:GetFrameStrata())
        child:SetFrameLevel(frameContainer:GetFrameLevel() + 10)
        frameContainer:CreateChildResizers(child)
        frameContainer:RefreshChildrenState()
    end,

    ---@param frameContainer df_framecontainer
    ---@param child frame
    UnregisterChild = function(frameContainer, child)
        frameContainer:SetChildResizersShown(child, false)
        frameContainer.childResizers[child] = nil
        frameContainer.childResizerSideOverrides[child] = nil
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
    is_locked = true, --can the container be resized
    is_movement_locked = true, --can the container be moved
    can_move_children = false, --can move children with drag and drop
    can_resize_children = false, --can resize children with side resizers
    use_top_child_resizer = true,
    use_bottom_child_resizer = true,
    use_left_child_resizer = true,
    use_right_child_resizer = true,
    use_topleft_resizer = false,
    use_topright_resizer = false,
    use_bottomleft_resizer = false,
    use_bottomright_resizer = false,
    use_top_resizer = false,
    use_bottom_resizer = false,
    use_left_resizer = false,
    use_right_resizer = false,
    show_resize_grips = false,
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
    frameContainer.childResizers = {}
    frameContainer.childResizerSideOverrides = {}
    frameContainer.activeChildResizeState = nil
    frameContainer:EnableMouse(false)

    detailsFramework:Mixin(frameContainer, detailsFramework.FrameContainerMixin)
    detailsFramework:Mixin(frameContainer, detailsFramework.OptionsFunctions)

    frameContainer.RegisterChildForDrag = detailsFramework.FrameContainerMixin.RegisterChild

    frameContainer:CreateResizers()
    frameContainer:CreateMover()
    frameContainer:BuildOptionsTable(frameContainerOptions, options)

    local resizeGripOptions = {
        width = 32,
        height = 32,
        use_default_scripts = true,
        should_mirror_left_texture = true,
        normal_texture = [[Interface\CHATFRAME\UI-ChatIM-SizeGrabber-Up]],
        highlight_texture = [[Interface\CHATFRAME\UI-ChatIM-SizeGrabber-Highlight]],
        pushed_texture = [[Interface\CHATFRAME\UI-ChatIM-SizeGrabber-Down]],
    }

    local leftResizer, rightResizer = detailsFramework:CreateResizeGrips(frameContainer, resizeGripOptions)
    if options.show_resize_grips then
        leftResizer:Show()
        rightResizer:Show()
        frameContainer:SetResizable(true)
    else
        leftResizer:Hide()
        rightResizer:Hide()
    end

    frameContainer.LeftResizeGrip = leftResizer
    frameContainer.RightResizeGrip = rightResizer

    frameContainer:OnInitialize()

    frameContainer.currentWidth = frameContainer:GetWidth()
    frameContainer.currentHeight = frameContainer:GetHeight()
    frameContainer:SetScript("OnSizeChanged", frameContainer.OnSizeChanged)

    return frameContainer
end


--this is a function to test the frame container
function DF:CreateFrameContainerTest(parent, options, frameName)
    local container = DF:CreateFrameContainer(parent, options, frameName)
    container:SetSize(400, 400)
    container:SetPoint("center", _G.UIParent, "center", 0, 0)

    detailsFramework:ApplyStandardBackdrop(container)

    local verticalLastBox = nil
    for i = 1, 4 do
        local lastBox = nil
        for o = 1, 2 do
            local frame = CreateFrame("frame", "$parentFrame" .. i .. o, container, "BackdropTemplate")
            container:RegisterChild(frame)

            frame:EnableMouse(true)

            frame:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            frame:SetBackdropColor(.4, .40, .40, 0.5)
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

    return container
end
