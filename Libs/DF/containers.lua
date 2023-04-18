
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local DF = detailsFramework

local CreateFrame = CreateFrame

---@class framecontainer : frame
---@field bIsSizing boolean
---@field options table
---@field leftResizer button
---@field rightResizer button
---@field OnSizeChanged fun(frameContainer: framecontainer)
---@field OnResizerMouseDown fun(resizerButton: button, mouseButton: string)
---@field OnResizerMouseUp fun(resizerButton: button, mouseButton: string)
---@field HideResizer fun(frameContainer: framecontainer)
---@field ShowResizer fun(frameContainer: framecontainer)
---@field OnInitialize fun(frameContainer: framecontainer)
---@field SetLocked fun(frameContainer: framecontainer, isLocked: boolean)
---@field CheckLockedState fun(frameContainer: framecontainer)

detailsFramework.frameContainerMixin = {
    --methods
    ---run when the container has its size changed
    ---@param frameContainer framecontainer
    OnSizeChanged = function(frameContainer)
        ---@type frame[]
        local children = {frameContainer:GetChildren()}
        ---@type number
        local childrenAmount = #children

        --get the width of each children and sum the values, do the same thing for height
        ---@type number
        local childrenWidth = 0
        ---@type number
        local childrenHeight = 0

        for i = 1, childrenAmount do
            childrenWidth = childrenWidth + children[i]:GetWidth()
            childrenHeight = childrenHeight + children[i]:GetHeight()
        end

        print("running...")

        --if the children width is bigger than the container width, then need to resize the width of the children to porportionally fit the container
        --this resize is done by getting the width of each child and reduce the width of the child by the percentage of the difference between the container width and the children width
        if childrenWidth > frameContainer:GetWidth() then
            ---@type number
            local widthDifference = childrenWidth - frameContainer:GetWidth()

            for i = 1, childrenAmount do
                children[i]:SetWidth(children[i]:GetWidth() - (children[i]:GetWidth() * (widthDifference / childrenWidth)))
            end
        end
    end,

    ---run when the user click on the resizer
    ---@param resizerButton button
    ---@param mouseButton string
    OnResizerMouseDown = function(resizerButton, mouseButton)
        if (mouseButton ~= "LeftButton") then
            return
        end
print(1)
        ---@type framecontainer
        local frameContainer = resizerButton:GetParent() --Cannot assign `frame` to `framecontainer`. .. but framecontainer is inherited from frame

        if (frameContainer.bIsSizing) then
            return
        end

        frameContainer.bIsSizing = true
        frameContainer:StartSizing("bottomright")
    end,

    ---run when the user click on the resizer
    ---@param resizerButton button
    ---@param mouseButton string
    OnResizerMouseUp = function(resizerButton, mouseButton)
        ---@type framecontainer
        local frameContainer = resizerButton:GetParent() --Cannot assign `frame` to `framecontainer`. .. but framecontainer is inherited from frame
        print(2)
        if (not frameContainer.bIsSizing) then
            print("fuck")
            return
        end

        frameContainer:StopMovingOrSizing()
        frameContainer.bIsSizing = false
    end,

    ---hide resizer
    ---@param frameContainer framecontainer
    HideResizer = function(frameContainer)
        frameContainer.leftResizer:Hide()
        frameContainer.rightResizer:Hide()
    end,

    ---show resizer
    ---@param frameContainer framecontainer
    ShowResizer = function(frameContainer)
        if (frameContainer.options.use_left_resizer) then
            frameContainer.leftResizer:Show()
        end
        if (frameContainer.options.use_right_resizer) then
            frameContainer.rightResizer:Show()
        end
    end,

    ---check the lock state and show or hide the resizer, set the frame as movable or not, resizeable or not
    ---@param frameContainer framecontainer
    CheckLockedState = function(frameContainer)
        if (frameContainer.options.is_locked) then
            frameContainer:HideResizer()
            frameContainer:EnableMouse(false)
            frameContainer:SetResizable(false)
        else
            frameContainer:ShowResizer()
            frameContainer:EnableMouse(true)
            frameContainer:SetResizable(true)
        end
    end,

    ---set the lock state
    ---@param frameContainer framecontainer
    ---@param isLocked boolean
    SetLocked = function(frameContainer, isLocked)
        frameContainer.options.is_locked = isLocked
        frameContainer:CheckLockedState()
    end,

    ---run when the container is created
    ---@param frameContainer framecontainer
    OnInitialize = function(frameContainer)
        frameContainer.leftResizer:SetScript("OnMouseDown", frameContainer.OnResizerMouseDown)
        frameContainer.leftResizer:SetScript("OnMouseUp", frameContainer.OnResizerMouseUp)
        frameContainer.rightResizer:SetScript("OnMouseDown", frameContainer.OnResizerMouseDown)
        frameContainer.rightResizer:SetScript("OnMouseUp", frameContainer.OnResizerMouseUp)

        if (frameContainer.options.is_locked) then
            frameContainer:HideResizer()
        else
            frameContainer:ShowResizer()
        end

        frameContainer:CheckLockedState()

        frameContainer:SetResizeBounds(50, 50, 1000, 1000)
    end,

}

local frameContainerOptions = {
    --default settings
    width = 300,
    height = 150,
    is_locked = false,
    use_left_resizer = false,
    use_right_resizer = true,
}

---create a frame container, which is a frame that envelops another frame, and can be moved, resized, etc.
---@param parent frame
---@param options table|nil
---@param frameName string|nil
---@return framecontainer
function DF:CreateFrameContainer(parent, options, frameName)
    ---@type framecontainer
    local container = CreateFrame("frame", frameName or ("$parentFrameContainer" .. math.random(10000, 99999)), parent, "BackdropTemplate")

    detailsFramework:Mixin(container, detailsFramework.frameContainerMixin)
    detailsFramework:Mixin(container, detailsFramework.OptionsFunctions)

    detailsFramework:CreateResizeGrips(container)

    container:BuildOptionsTable(frameContainerOptions, options)

    container:SetScript("OnSizeChanged", container.OnSizeChanged)

    container.bIsSizing = false

    container:OnInitialize()

    return container
end

function DF:CreateFrameContainerTest(parent, options, frameName)

    local container = DF:CreateFrameContainer(parent, options, frameName)
    container:SetSize(400, 400)
    container:SetPoint("center", UIParent, "center", 0, 0)

    detailsFramework:ApplyStandardBackdrop(container)

    for i = 1, 3 do
        for o = 1, 3 do
            local frame = CreateFrame("frame", "$parentFrame" .. math.random(10000, 99999), container, "BackdropTemplate")
            frame:SetBackdrop({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16, edgeFile = "Interface\\AddOns\\Details\\images\\border_2", edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
            frame:SetBackdropColor(0, 0, 0, 0.5)
            frame:SetBackdropBorderColor(1, 1, 1, 0.5)
            frame:SetSize(100, 100)
            frame:SetPoint("TOPLEFT", container, "TOPLEFT", 10 + (i - 1) * 110, -10 - (o - 1) * 110)
        end
    end
end

C_Timer.After(2, function()
    --DetailsFramework:CreateFrameContainerTest(UIParent)
end)

--[=[
    /run DetailsFramework:CreateFrameContainerTest(UIParent)

    C_Timer.After(2, function()
        DetailsFramework:CreateFrameContainerTest(UIParent)
    end)    
--]=]