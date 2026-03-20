
local detailsFramework = DetailsFramework
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

---@class wheelmenuframe : frame
---@field options wheelmenuoption[]
---@field outerRadius number
---@field innerRadius number
---@field optionRadius number
---@field optionButtonWidth number
---@field optionButtonHeight number
---@field firstOptionAngle number
---@field hoveredIndex number?
---@field InnerDisc frame
---@field CenterText fontstring
---@field optionButtons wheeloptionbutton[]
---@field UpdateButtons fun(self: wheelmenuframe) called when method Refresh is called, responsible for positioning buttons based on the amount of options
---@field SetHoveredButtonIndex fun(self: wheelmenuframe, index: number?) sets the index of the hovered button, nil to set no hovered button
---@field OnUpdate fun(self: wheelmenuframe) part of the OnUpdate, get the mouse position, get the nearest button and set the button index as the hovered index
---@field GetOptionIndexUnderCursor fun(self: wheelmenuframe, cursorX: number, cursorY: number): number?
---@field ConfirmHoveredOption fun(self: wheelmenuframe)
---@field SetOptions fun(self: wheelmenuframe, options: wheelmenuoption[])
---@field GetOptions fun(self: wheelmenuframe): wheelmenuoption[]
---@field GetOption fun(self: wheelmenuframe, index: number): wheelmenuoption
---@field GetNumOptions fun(self: wheelmenuframe): number
---@field GetOptionButton fun(self: wheelmenuframe, index: number, dontCreate: boolean?): wheeloptionbutton
---@field GetAllOptionsButtons fun(self: wheelmenuframe): wheeloptionbutton[]
---@field CreateOptionButton fun(self: wheelmenuframe, parent: frame, width: number, height: number): wheeloptionbutton
---@field GetNumOptionButtonsCreated fun(self: wheelmenuframe): number return the amount of button created to show options
---@field HideUnusedButtons fun(self: wheelmenuframe)
---@field ResetAppearance fun(self: wheelmenuframe)
---@field ApplyHoveredAppearance fun(self: wheelmenuframe, button: wheeloptionbutton)
---@field Refresh fun(self: wheelmenuframe)
---@field OpenAtCursor fun(self: wheelmenuframe)
---@field CloseMenu fun(self: wheelmenuframe)
local WheelMenuMixin = {}
    
---@class wheelmenuoption
---@field text string?
---@field icon string|number?
---@field onClick fun(option: wheelmenuoption, menu: wheelmenuframe)?
---@field value any

---@class wheeloptionbutton : button
---@field Option wheelmenuoption?
---@field Icon texture?
---@field Text fontstring?
---@field SectorStartAngle number?
---@field SectorEndAngle number?

local threeSixty = math.pi * 2

local normalizeAngle = function(angle)
    angle = angle % threeSixty
    if angle < 0 then
        angle = angle + threeSixty
    end
    return angle
end

function WheelMenuMixin:ResetAppearance()
    --reset appearance of all buttons, including hovered one
    for index, button in ipairs(self:GetAllOptionsButtons()) do
        --do appearance changes
    end
end

function WheelMenuMixin:ApplyHoveredAppearance(button)
    --do appearance changes
end

function WheelMenuMixin:SetHoveredButtonIndex(index)
    if self.hoveredIndex == index then
        return
    end

    --reset the appearance of all buttons
    self:ResetAppearance()

    --set the new hovered button, if index is nil, no button is hovered
    self.hoveredIndex = index

    --apply hovered appearance to the new hovered button
    if index then
        local dontCreate = true
        local hoveredButton = self:GetOptionButton(index, dontCreate)
        if hoveredButton then
            self:ApplyHoveredAppearance(hoveredButton)
        end
    end
end

function WheelMenuMixin:GetOptionIndexUnderCursor(cursorX, cursorY)
    --get number of slices to decide if selection is possible
    local optionCount = #self.options
    if optionCount < 1 then
        return
    end

    --get wheel center on screen and cursor offset from center
    local centerX, centerY = self:GetCenter()
    local deltaX = cursorX - centerX
    local deltaY = cursorY - centerY
    --get the distance
    local distanceSquared = deltaX * deltaX + deltaY * deltaY

    --ignore if the cursor is inside the small center circle
    if distanceSquared < (self.innerRadius * self.innerRadius) then
        return
    end
    --ignore if the cursor is outside the wheel ring
    if distanceSquared > (self.outerRadius * self.outerRadius) then
        return
    end

    --convert cursor direction to normalized angle around the wheel
    ---@diagnostic disable-next-line: deprecated
    local angle = normalizeAngle(math.atan2(deltaY, deltaX))
    --each option owns one equal angular slice
    local sliceAngle = threeSixty / optionCount
    --rotate the angle so option one is centered at the firstOptionAngle
    local firstOptionAngle = self.firstOptionAngle or (math.pi * 0.5)
    local adjustedAngle = normalizeAngle(angle - firstOptionAngle + sliceAngle * 0.5)
    --map adjusted angle to index in range 1 to .optionCount
    local index = math.floor(adjustedAngle / sliceAngle) + 1
    --clamp edge cases from floating point precision
    if index < 1 then
        index = 1
    elseif index > optionCount then
        index = optionCount
    end

    --return selected option index for current cursor position
    return index
end

function WheelMenuMixin:OnUpdate() --called from OnUpdate
    local mouseX, mouseY = detailsFramework:GetCursorPosition()
    local hoveredIndex = self:GetOptionIndexUnderCursor(mouseX, mouseY) --can be nil
    self:SetHoveredButtonIndex(hoveredIndex)
end

function WheelMenuMixin:ConfirmHoveredOption()
    local index = self.hoveredIndex
    if not index then
        return
    end

    local option = self:GetOption(index)
    if option and option.onClick then
        xpcall(option.onClick, geterrorhandler(), self, option)
    end
end

---@param options wheelmenuoption[]
function WheelMenuMixin:SetOptions(options)
    self.options = options
end

function WheelMenuMixin:GetOption(index)
    return self.options[index]
end

function WheelMenuMixin:GetOptions()
    return self.options
end

function WheelMenuMixin:GetNumOptions()
    return #self.options
end

function WheelMenuMixin:GetNumOptionButtonsCreated()
    return #self.optionButtons
end

function WheelMenuMixin:GetAllOptionsButtons()
    return self.optionButtons
end

---@param parent frame
---@param width number
---@param height number
---@return wheeloptionbutton
function WheelMenuMixin:CreateOptionButton(parent, width, height)
    local button = CreateFrame("button", nil, parent)
    ---@cast button wheeloptionbutton
    button:SetSize(width, height)

    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetSize(16, 16)
    button.Icon:SetPoint("left", button, "left", 4, 0)

    button.Text = button:CreateFontString(nil, "overlay", "GameFontNormal")
    button.Text:SetPoint("left", button.Icon, "right", 4, 0)
    button.Text:SetPoint("right", button, "right", -4, 0)
    button.Text:SetJustifyH("left")

    button:SetScript("OnClick", function(clickedButton)
        local clickedOption = clickedButton.Option
        --need to have a payload
        xpcall(clickedOption.onClick, geterrorhandler(), clickedButton, clickedOption)
    end)

    self.optionButtons[#self.optionButtons+1] = button

    return button
end

function WheelMenuMixin:GetOptionButton(index, dontCreate)
    local button = self.optionButtons[index]
    if not button and not dontCreate then
        button = self:CreateOptionButton(self, self.optionButtonWidth, self.optionButtonHeight)
    end
    return button
end

--hide buttons that wasn't used in the UpdateButtons
function WheelMenuMixin:HideUnusedButtons()
    for index = self:GetNumOptions() + 1, self:GetNumOptionButtonsCreated() do
        local dontCreate = true
        local button = self:GetOptionButton(index, dontCreate)
        button.Option = nil
        button:Hide()
    end
end

function WheelMenuMixin:UpdateButtons()
    local optionCount = self:GetNumOptions()
    if optionCount == 0 then
        return
    end

    local sliceAngle = threeSixty / optionCount
    local firstOptionAngle = self.firstOptionAngle or (math.pi * 0.5)

    for index = 1, optionCount do
        ---@type wheeloptionbutton
        local button = self:GetOptionButton(index)
        local angle = normalizeAngle(firstOptionAngle + (index - 1) * sliceAngle)
        local x = math.cos(angle) * self.optionRadius
        local y = math.sin(angle) * self.optionRadius
        button:ClearAllPoints()
        button:SetPoint("center", self, "center", x, y)
        button.SectorStartAngle = normalizeAngle(angle - sliceAngle * 0.5)
        button.SectorEndAngle = normalizeAngle(angle + sliceAngle * 0.5)
        button:Show()
    end

    self:HideUnusedButtons()
end

---@param self wheelmenuframe
function WheelMenuMixin:Refresh()
    for index = 1, self:GetNumOptions() do
        local option = self:GetOption(index)
        ---@type wheeloptionbutton
        local button = self:GetOptionButton(index)

        button.Option = option
        button.Text:SetText(option.text or "")

        if option.icon then
            button.Icon:SetTexture(option.icon)
            button.Icon:Show()
        else
            button.Icon:SetTexture(nil)
            button.Icon:Hide()
        end
    end

    self:SetHoveredButtonIndex(nil)
    self:UpdateButtons()
end

function WheelMenuMixin:OpenAtCursor()
    local mouseX, mouseY = detailsFramework:GetCursorPosition()
    self:ClearAllPoints()
    self:SetPoint("center", UIParent, "bottomleft", mouseX, mouseY)
    self:SetHoveredButtonIndex(nil)
    self:Show()
    self:SetScript("OnUpdate", function(menu)
        menu:OnUpdate()
    end)
end

function WheelMenuMixin:CloseMenu()
    self:SetScript("OnUpdate", nil)
    self:SetHoveredButtonIndex(nil)
    self:Hide()
end

---@class wheelconfig : table
---@field inner_radius number?
---@field outer_radius number?
---@field option_radius number?
---@field option_button_width number?
---@field option_button_height number?
---@field first_option_angle number?
---@field frame_strata string?
---@field frame_level number?
---@field center_text string?

---@param name string?
---@param parent frame?
---@param wheelOptions wheelmenuoption[]?
---@param config wheelconfig?
---@return wheelmenuframe
function detailsFramework:CreateWheelMenu(parent, name, wheelOptions, config)
    parent = parent or UIParent
    config = config or {}
    wheelOptions = wheelOptions or {}
    local innerRadius = config.inner_radius or 42
    local outerRadius = config.outer_radius or 170
    local optionRadius = config.option_radius or math.floor((outerRadius + innerRadius) * 0.5)
    local optionButtonWidth = config.option_button_width or 122
    local optionButtonHeight = config.option_button_height or 24

    ---@type wheelmenuframe
    ---@diagnostic disable-next-line: assign-type-mismatch
    local menuFrame = CreateFrame("frame", name, parent)
    menuFrame:SetFrameStrata(config.frame_strata or "FULLSCREEN")
    menuFrame:SetFrameLevel(config.frame_level or 120)
    menuFrame:SetSize(outerRadius * 2, outerRadius * 2)
    menuFrame:SetClampedToScreen(true)
    menuFrame:EnableMouse(true)
    menuFrame:Hide()

    menuFrame.outerRadius = outerRadius
    menuFrame.innerRadius = innerRadius
    menuFrame.optionRadius = optionRadius
    menuFrame.optionButtonWidth = optionButtonWidth
    menuFrame.optionButtonHeight = optionButtonHeight
    menuFrame.firstOptionAngle = config.first_option_angle or (math.pi * 0.5)
    menuFrame.options = {}
    menuFrame.optionButtons = {}
    menuFrame.hoveredIndex = nil

    menuFrame.InnerDisc = CreateFrame("frame", nil, menuFrame)
    menuFrame.InnerDisc:SetPoint("center", menuFrame, "center", 0, 0)
    menuFrame.InnerDisc:SetSize(innerRadius * 2, innerRadius * 2)

    menuFrame.CenterText = menuFrame.InnerDisc:CreateFontString(nil, "overlay", "GameFontHighlight")
    menuFrame.CenterText:SetPoint("center")
    menuFrame.CenterText:SetText(config.center_text or "")

    Mixin(menuFrame, WheelMenuMixin)

    menuFrame:SetScript("OnMouseUp", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            self:ConfirmHoveredOption()
            self:CloseMenu()
        elseif mouseButton == "RightButton" then
            self:CloseMenu()
        end
    end)

    menuFrame:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    --set options to select
    menuFrame:SetOptions(wheelOptions)

    return menuFrame
end
