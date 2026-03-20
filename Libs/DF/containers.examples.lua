
---@type detailsframework
local DF = DetailsFramework

--create a frame to be use as parent for the container
local parentFrame = CreateFrame("Frame", "ExampleParentFrame", UIParent, "BackdropTemplate")
parentFrame:SetSize(800, 600)
parentFrame:SetPoint("CENTER")
parentFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})

--declare the option table for the container, you can find all the options in the df_framecontainer class declaration
local options = {
    width = 800,
    height = 600,
    is_locked = true,
    is_movement_locked = true,
    can_move_children = false,
    can_resize_children = true,
    use_top_child_resizer = true,
    use_bottom_child_resizer = true,
    use_left_child_resizer = true,
    use_right_child_resizer = true,
    use_top_resizer = false,
    use_bottom_resizer = false,
    use_left_resizer = false,
    use_right_resizer = false,
}

--create the container with the parent frame and the options
local frameContainer = DF:CreateFrameContainer(parentFrame, options, "ExampleMainContainer")
frameContainer:SetPoint("CENTER")

--start to create the frames that will be inside the container, the container will handle the movement and resizing of these frames
local leftMenu = CreateFrame("Frame", "ExampleParentFrameLeftMenu", frameContainer)
leftMenu:SetPoint("topleft", frameContainer, "topleft", 0, 0)
leftMenu:SetPoint("bottomleft", frameContainer, "bottomleft", 0, 0)
leftMenu:SetWidth(200)
--register this frame as part of the container
frameContainer:RegisterChild(leftMenu)
--set the sides where the children can be resized from
frameContainer:SetChildResizerSides(leftMenu, {left = false, right = true, top = false, bottom = false}) --can only resize from the right side
--create some random content for the left menu to test the resizing
leftMenu.fontStrings = {}
for i = 1, 20 do
    local fontString = leftMenu:CreateFontString(nil, "overlay", "GameFontNormal")
    fontString:SetPoint("topleft", leftMenu, "topleft", 2, -10 - (i - 1) * 20)
    fontString:SetText("Label of Option" .. i)
    leftMenu.fontStrings[i] = fontString
end

--this registers a function to run when the frame is resized
leftMenu:SetScript("OnSizeChanged", function(self)
    local width = self:GetWidth()
    for i = 1, #self.fontStrings do
        local fontString = self.fontStrings[i]
        fontString:SetWidth(width - 20) --10 padding on each side
    end
end)

--create another frame for the content, this frame will be resized by the container when the left menu is resized
local contentPanel = CreateFrame("Frame", "ExampleParentFrameContentPanel", frameContainer)
contentPanel:SetPoint("topleft", leftMenu, "topright", 0, 0)
contentPanel:SetPoint("bottomleft", leftMenu, "bottomright", 0, 0)
contentPanel:SetWidth(600)
frameContainer:RegisterChild(contentPanel)
frameContainer:SetChildResizerSides(contentPanel, {left = false, right = false, top = false, bottom = false})

--examples of method usage:
frameContainer:SetResizeLocked(true) --accept boolean, lock the container, preventing any movement or resizing
frameContainer:SetMovableLocked(false) --accept boolean, allowing movement of the children

--set a callback for when a setting within the container is changed
--setting names: "is_locked", "is_movement_locked", "width", "height"
frameContainer:SetSettingChangedCallback(function(container, settingName, value)
    print("Container setting changed:", settingName, value)
end)
