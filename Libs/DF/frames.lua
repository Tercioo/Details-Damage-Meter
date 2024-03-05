
---@class detailsframework
local detailsFramework = _G.DetailsFramework
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local CreateFrame = CreateFrame
local defaultRed, defaultGreen, defaultBlue = detailsFramework:GetDefaultBackdropColor()
--local defaultColorTable = {defaultRed, defaultGreen, defaultBlue, 1}
local defaultColorTable = {0.98, 0.98, 0.98, 1}
local defaultBorderColorTable = {0.1, 0.1, 0.1, 1}

---@type edgenames[]
local cornerNames = {"TopLeft", "TopRight", "BottomLeft", "BottomRight"}

---@param self df_roundedpanel
---@param textures cornertextures
---@param width number|nil
---@param height number|nil
---@param xOffset number|nil
---@param yOffset number|nil
---@param bIsBorder boolean|nil
local setCornerPoints = function(self, textures, width, height, xOffset, yOffset, bIsBorder)
    for cornerName, thisTexture in pairs(textures) do
        thisTexture:SetSize(width or 16, height or 16)
        thisTexture:SetTexture(self.options.corner_texture)

        --set the mask
        if (not thisTexture.MaskTexture and bIsBorder) then
            thisTexture.MaskTexture = self:CreateMaskTexture(nil, "background")
            thisTexture.MaskTexture:SetSize(74, 64)
            thisTexture:AddMaskTexture(thisTexture.MaskTexture)
            thisTexture.MaskTexture:SetTexture([[Interface\Azerite\AzeriteGoldRingRank2]]) --1940690
            --thisTexture.MaskTexture:Hide()
        end

        xOffset = xOffset or 0
        yOffset = yOffset or 0

        --todo: adjust the other corners setpoint offset
        --todo (done): use mask when the alpha is below 0.98, disable the mask when the alpha is above 0.98

        if (cornerName == "TopLeft") then
            thisTexture:SetTexCoord(0, 0.5, 0, 0.5)
            thisTexture:SetPoint(cornerName, self, cornerName, -xOffset, yOffset)
            if (thisTexture.MaskTexture) then
                thisTexture.MaskTexture:SetPoint(cornerName, self, cornerName, -18-xOffset, 16+yOffset)
            end

        elseif (cornerName == "TopRight") then
            thisTexture:SetTexCoord(0.5, 1, 0, 0.5)
            thisTexture:SetPoint(cornerName, self, cornerName, xOffset, yOffset)
            if (thisTexture.MaskTexture) then
                thisTexture.MaskTexture:SetPoint(cornerName, self, cornerName, -18+xOffset, 16+yOffset)
            end

        elseif (cornerName == "BottomLeft") then
            thisTexture:SetTexCoord(0, 0.5, 0.5, 1)
            thisTexture:SetPoint(cornerName, self, cornerName, -xOffset, -yOffset)
            if (thisTexture.MaskTexture) then
                thisTexture.MaskTexture:SetPoint(cornerName, self, cornerName, -18-xOffset, 16-yOffset)
            end

        elseif (cornerName == "BottomRight") then
            thisTexture:SetTexCoord(0.5, 1, 0.5, 1)
            thisTexture:SetPoint(cornerName, self, cornerName, xOffset, -yOffset)
            if (thisTexture.MaskTexture) then
                thisTexture.MaskTexture:SetPoint(cornerName, self, cornerName, -18+xOffset, 16-yOffset)
            end
        end
    end
end

detailsFramework.RoundedCornerPanelMixin = {
    RoundedCornerConstructor = function(self)
        self.CornerTextures = {}
        self.CenterTextures = {}
        self.BorderCornerTextures = {}
        self.BorderEdgeTextures = {}

        self.cornerRoundness = 0

        for i = 1, #cornerNames do
            ---@type texture
            local newCornerTexture = self:CreateTexture(nil, "border", nil, 0)
            self.CornerTextures[cornerNames[i]] = newCornerTexture
            self[cornerNames[i]] = newCornerTexture
        end

        --create the top texture which connects the top corners with a horizontal line
        ---@type texture
        local topHorizontalEdge = self:CreateTexture(nil, "border", nil, 0)
        topHorizontalEdge:SetPoint("topleft", self.CornerTextures["TopLeft"], "topright", 0, 0)
        topHorizontalEdge:SetPoint("bottomleft", self.CornerTextures["TopLeft"], "bottomright", 0, 0)
        topHorizontalEdge:SetPoint("topright", self.CornerTextures["TopRight"], "topleft", 0, 0)
        topHorizontalEdge:SetPoint("bottomright", self.CornerTextures["TopRight"], "bottomleft", 0, 0)
        topHorizontalEdge:SetColorTexture(unpack(defaultColorTable))

        --create the bottom texture which connects the bottom corners with a horizontal line
        ---@type texture
        local bottomHorizontalEdge = self:CreateTexture(nil, "border", nil, 0)
        bottomHorizontalEdge:SetPoint("topleft", self.CornerTextures["BottomLeft"], "topright", 0, 0)
        bottomHorizontalEdge:SetPoint("bottomleft", self.CornerTextures["BottomLeft"], "bottomright", 0, 0)
        bottomHorizontalEdge:SetPoint("topright", self.CornerTextures["BottomRight"], "topleft", 0, 0)
        bottomHorizontalEdge:SetPoint("bottomright", self.CornerTextures["BottomRight"], "bottomleft", 0, 0)
        bottomHorizontalEdge:SetColorTexture(unpack(defaultColorTable))

        --create the center block which connects the bottom left of the topleft corner with the top right of the bottom right corner
        ---@type texture
        local centerBlock = self:CreateTexture(nil, "border", nil, 0)
        centerBlock:SetPoint("topleft", self.CornerTextures["TopLeft"], "bottomleft", 0, 0)
        centerBlock:SetPoint("bottomleft", self.CornerTextures["BottomLeft"], "topleft", 0, 0)
        centerBlock:SetPoint("topright", self.CornerTextures["BottomRight"], "topright", 0, 0)
        centerBlock:SetPoint("bottomright", self.CornerTextures["BottomRight"], "topright", 0, 0)
        centerBlock:SetColorTexture(unpack(defaultColorTable))

        self.CenterTextures[#self.CenterTextures+1] = topHorizontalEdge
        self.CenterTextures[#self.CenterTextures+1] = bottomHorizontalEdge
        self.CenterTextures[#self.CenterTextures+1] = centerBlock

        self.TopHorizontalEdge = topHorizontalEdge
        self.BottomHorizontalEdge = bottomHorizontalEdge
        self.CenterBlock = centerBlock

        ---@type width
        local width = self.options.width
        ---@type height
        local height = self.options.height

        self:SetSize(width, height)

        --fill the corner and edge textures table
        setCornerPoints(self, self.CornerTextures)
    end,

    ---get the highest frame level of the rounded panel and its children
    ---@param self df_roundedpanel
    ---@return framelevel
    GetMaxFrameLevel = function(self)
        ---@type framelevel
        local maxFrameLevel = 0
        local children = {self:GetChildren()}

        for i = 1, #children do
            local thisChild = children[i]
            ---@cast thisChild frame
            if (thisChild:GetFrameLevel() > maxFrameLevel) then
                maxFrameLevel = thisChild:GetFrameLevel()
            end
        end

        return maxFrameLevel
    end,

    ---create a frame placed at the top side of the rounded panel, this frame has a member called 'Text' which is a fontstring for the title
    ---@param self df_roundedpanel
    ---@return df_roundedpanel
    CreateTitleBar = function(self)
        ---@type df_roundedpanel
        local titleBar = detailsFramework:CreateRoundedPanel(self, "$parentTitleBar", {width = self.options.width - 6, height = 16})
        titleBar:SetPoint("top", self, "top", 0, -4)
        titleBar:SetRoundness(5)
        titleBar:SetFrameLevel(9500)
        titleBar.bIsTitleBar = true
        self.TitleBar = titleBar
        self.bHasTitleBar = true

        local textFontString = titleBar:CreateFontString("$parentText", "overlay", "GameFontNormal")
        textFontString:SetPoint("center", titleBar, "center", 0, 0)
        titleBar.Text = textFontString

        local closeButton = detailsFramework:CreateCloseButton(titleBar, "$parentCloseButton")
        closeButton:SetPoint("right", titleBar, "right", -3, 0)
		closeButton:SetSize(10, 10)
		closeButton:SetAlpha(0.3)
        closeButton:SetScript("OnClick", function(self)
            self:GetParent():GetParent():Hide()
        end)
        detailsFramework:SetButtonTexture(closeButton, "common-search-clearbutton")

        return titleBar
    end,

    ---return the width and height of the corner textures
    ---@param self df_roundedpanel
    ---@return number, number
    GetCornerSize = function(self)
        return self.CornerTextures["TopLeft"]:GetSize()
    end,

    ---set how rounded the corners should be
    ---@param self df_roundedpanel
    ---@param roundness number
    SetRoundness = function(self, roundness)
        self.cornerRoundness = roundness
        self:OnSizeChanged()
    end,

    ---adjust the size of the corner textures and the border edge textures
    ---@param self df_roundedpanel
    OnSizeChanged = function(self)
        --if the frame has a titlebar, need to adjust the size of the titlebar
        if (self.bHasTitleBar) then
            self.TitleBar:SetWidth(self:GetWidth() - 14)
        end

        --if the frame height is below 32, need to recalculate the size of the corners
        ---@type height
        local frameHeight = self:GetHeight()

        if (frameHeight < 32) then
            local newCornerSize = frameHeight / 2

            --set the new size of the corners on all corner textures
            for _, thisTexture in pairs(self.CornerTextures) do
                thisTexture:SetSize(newCornerSize - (self.cornerRoundness - 2), newCornerSize)
            end

            --check if the frame has border and set the size of the border corners as well
            if (self.bHasBorder) then
                for _, thisTexture in pairs(self.BorderCornerTextures) do
                    thisTexture:SetSize(newCornerSize-2, newCornerSize+2)
                end

                --hide the left and right edges as the corner textures already is enough to fill the frame
                self.BorderEdgeTextures["Left"]:Hide()
                self.BorderEdgeTextures["Right"]:Hide()

                local horizontalEdgesNewSize = self:CalculateBorderEdgeSize("horizontal")
                self.BorderEdgeTextures["Top"]:SetSize(horizontalEdgesNewSize + (self.options.horizontal_border_size_offset or 0), 1)
                self.BorderEdgeTextures["Bottom"]:SetSize(horizontalEdgesNewSize + (self.options.horizontal_border_size_offset or 0), 1)
            end

            self.CenterBlock:Hide()
        else
            if (self.bHasBorder) then
                self.BorderEdgeTextures["Left"]:Show()
                self.BorderEdgeTextures["Right"]:Show()
            end

            ---@type width, height
            local cornerWidth, cornerHeight = 16, 16

            self.CenterBlock:Show()

            for _, thisTexture in pairs(self.CornerTextures) do
                thisTexture:SetSize(cornerWidth-self.cornerRoundness, cornerHeight-self.cornerRoundness)
            end

            if (self.bHasBorder) then
                for _, thisTexture in pairs(self.BorderCornerTextures) do
                    thisTexture:SetSize(cornerWidth-self.cornerRoundness, cornerHeight-self.cornerRoundness)
                    thisTexture.MaskTexture:SetSize(74-(self.cornerRoundness*0.75), 64-self.cornerRoundness)
                end

                local horizontalEdgesNewSize = self:CalculateBorderEdgeSize("horizontal")
                self.BorderEdgeTextures["Top"]:SetSize(horizontalEdgesNewSize, 1)
                self.BorderEdgeTextures["Bottom"]:SetSize(horizontalEdgesNewSize, 1)

                local verticalEdgesNewSize = self:CalculateBorderEdgeSize("vertical")
                self.BorderEdgeTextures["Left"]:SetSize(1, verticalEdgesNewSize)
                self.BorderEdgeTextures["Right"]:SetSize(1, verticalEdgesNewSize)
            end
        end
    end,

    ---get the size of the edge texture
    ---@param self df_roundedpanel
    ---@param alignment "vertical"|"horizontal"
    ---@return number edgeSize
    CalculateBorderEdgeSize = function(self, alignment)
        ---@type string
        local borderCornerName = next(self.BorderCornerTextures)
        if (not borderCornerName) then
            return 0
        end

        ---@type texture
        local borderTexture = self.BorderCornerTextures[borderCornerName]

        alignment = alignment:lower()

        if (alignment == "vertical") then
            return self:GetHeight() - (borderTexture:GetHeight() * 2) + 2

        elseif (alignment == "horizontal") then
            return self:GetWidth() - (borderTexture:GetHeight() * 2) + 2
        end

        error("df_roundedpanel:CalculateBorderEdgeSize(self, alignment) alignment must be 'vertical' or 'horizontal'")
    end,

    ---@param self df_roundedpanel
    CreateBorder = function(self)
        local r, g, b, a = 0, 0, 0, 0.8

        --create the corner edges
        for i = 1, #cornerNames do
            ---@type texture
            local newBorderTexture = self:CreateTexture(nil, "background", nil, 0)
            self.BorderCornerTextures[cornerNames[i]] = newBorderTexture
            newBorderTexture:SetColorTexture(unpack(defaultColorTable))
            newBorderTexture:SetVertexColor(r, g, b, a)
            self[cornerNames[i] .. "Border"] = newBorderTexture
        end

        setCornerPoints(self, self.BorderCornerTextures, 16, 16, 1, 1, true)

        --create the top, left, bottom and right edges, the edge has 1pixel width and connects the corners
        ---@type texture
        local topEdge = self:CreateTexture(nil, "background", nil, 0)
        topEdge:SetPoint("bottom", self, "top", 0, 0)
        self.BorderEdgeTextures["Top"] = topEdge

        ---@type texture
        local leftEdge = self:CreateTexture(nil, "background", nil, 0)
        leftEdge:SetPoint("right", self, "left", 0, 0)
        self.BorderEdgeTextures["Left"] = leftEdge

        ---@type texture
        local bottomEdge = self:CreateTexture(nil, "background", nil, 0)
        bottomEdge:SetPoint("top", self, "bottom", 0, 0)
        self.BorderEdgeTextures["Bottom"] = bottomEdge

        ---@type texture
        local rightEdge = self:CreateTexture(nil, "background", nil, 0)
        rightEdge:SetPoint("left", self, "right", 0, 0)
        self.BorderEdgeTextures["Right"] = rightEdge

        ---@type width
        local horizontalEdgeSize = self:CalculateBorderEdgeSize("horizontal")
        ---@type height
        local verticalEdgeSize = self:CalculateBorderEdgeSize("vertical")

        --set the edges size
        topEdge:SetSize(horizontalEdgeSize, 1)
        leftEdge:SetSize(1, verticalEdgeSize)
        bottomEdge:SetSize(horizontalEdgeSize, 1)
        rightEdge:SetSize(1, verticalEdgeSize)

        for edgeName, thisTexture in pairs(self.BorderEdgeTextures) do
            ---@cast thisTexture texture
            thisTexture:SetColorTexture(unpack(defaultColorTable))
            thisTexture:SetVertexColor(r, g, b, a)
        end

        self.TopEdgeBorder = topEdge
        self.BottomEdgeBorder = bottomEdge
        self.LeftEdgeBorder = leftEdge
        self.RightEdgeBorder = rightEdge

        self.bHasBorder = true
    end,

    ---@param self df_roundedpanel
    ---@param red any
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    SetTitleBarColor = function(self, red, green, blue, alpha)
        if (self.bHasTitleBar) then
            red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)
            self.TitleBar:SetColor(red, green, blue, alpha)
        end
    end,

    ---@param self df_roundedpanel
    ---@param red any
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    SetBorderCornerColor = function(self, red, green, blue, alpha)
        if (not self.bHasBorder) then
            self:CreateBorder()
        end

        red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)

        for _, thisTexture in pairs(self.BorderCornerTextures) do
            thisTexture:SetVertexColor(red, green, blue, alpha)
        end

        for _, thisTexture in pairs(self.BorderEdgeTextures) do
            thisTexture:SetVertexColor(red, green, blue, alpha)
        end
    end,

    ---@param self df_roundedpanel
    ---@param red any
    ---@param green number|nil
    ---@param blue number|nil
    ---@param alpha number|nil
    SetColor = function(self, red, green, blue, alpha)
        red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)

        for _, thisTexture in pairs(self.CornerTextures) do
            thisTexture:SetVertexColor(red, green, blue, alpha)
        end

        for _, thisTexture in pairs(self.CenterTextures) do
            thisTexture:SetVertexColor(red, green, blue, alpha)
        end

        if (self.bHasBorder) then
            if (alpha < 0.98) then
                --if using borders, the two border textures overlaps making the alpha be darker than it should
                for _, thisTexture in pairs(self.BorderCornerTextures) do
                    thisTexture.MaskTexture:Show()
                end
            else
                for _, thisTexture in pairs(self.BorderCornerTextures) do
                    thisTexture.MaskTexture:Hide()
                end
            end
        end
    end,
}

local defaultOptions = {
    width = 200,
    height = 200,
    use_titlebar = false,
    use_scalebar = false,
    title = "",
    scale = 1,
    roundness = 0,
    color = defaultColorTable,
    border_color = defaultColorTable,
    corner_texture = [[Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall]],
}

local defaultPreset = {
    border_color = {.1, .1, .1, 0.834},
    color = {defaultRed, defaultGreen, defaultBlue},
    roundness = 3,
}

---create a regular panel with rounded corner
---@param parent frame
---@param name string|nil
---@param optionsTable table|nil
---@return df_roundedpanel
function detailsFramework:CreateRoundedPanel(parent, name, optionsTable)
    ---@type df_roundedpanel
    local newRoundedPanel = CreateFrame("frame", name, parent, "BackdropTemplate")
    newRoundedPanel:EnableMouse(true)
    newRoundedPanel.__dftype = "df_roundedpanel"
    newRoundedPanel.__rcorners = true

    detailsFramework:Mixin(newRoundedPanel, detailsFramework.RoundedCornerPanelMixin)
    detailsFramework:Mixin(newRoundedPanel, detailsFramework.OptionsFunctions)
    newRoundedPanel:BuildOptionsTable(defaultOptions, optionsTable or {})
    newRoundedPanel:RoundedCornerConstructor()
    newRoundedPanel:SetScript("OnSizeChanged", newRoundedPanel.OnSizeChanged)

    if (newRoundedPanel.options.use_titlebar) then
        ---@type df_roundedpanel
        local titleBar = detailsFramework:CreateRoundedPanel(newRoundedPanel, "$parentTitleBar", {height = 26})
        titleBar:SetPoint("top", newRoundedPanel, "top", 0, -7)
        newRoundedPanel.TitleBar = titleBar
        titleBar:SetRoundness(5)
        newRoundedPanel.bHasTitleBar = true
    end

    if (newRoundedPanel.options.use_scalebar) then
        detailsFramework:CreateScaleBar(newRoundedPanel.TitleBar or newRoundedPanel, newRoundedPanel.options)
        newRoundedPanel:SetScale(newRoundedPanel.options.scale)
    end

    newRoundedPanel:SetRoundness(newRoundedPanel.options.roundness)
    newRoundedPanel:SetColor(newRoundedPanel.options.color)
    newRoundedPanel:SetBorderCornerColor(newRoundedPanel.options.border_color)

    return newRoundedPanel
end

local applyPreset = function(frame, preset)
    if (preset.border_color) then
        frame:SetBorderCornerColor(preset.border_color)
    end

    if (preset.color) then
        frame:SetColor(preset.color)
    end

    if (preset.roundness) then
        frame:SetRoundness(preset.roundness)
    else
        frame:SetRoundness(1)
    end

    if (preset.use_titlebar) then
        frame:CreateTitleBar()
    end
end

---set a frame to have rounded corners following the settings passed by the preset table
---@param frame frame
---@param preset df_roundedpanel_preset?
function detailsFramework:AddRoundedCornersToFrame(frame, preset)
    frame = frame and frame.widget or frame
    assert(frame and frame.GetObjectType and frame.SetPoint, "AddRoundedCornersToFrame(frame): frame must be a frame object.")

    if (frame.__rcorners) then
        return
    end

    if (frame.GetBackdropBorderColor) then
        local red, green, blue, alpha = frame:GetBackdropBorderColor()
        if (alpha and alpha > 0) then
            detailsFramework:MsgWarning("AddRoundedCornersToFrame() applyed to a frame with a backdrop border.")
            detailsFramework:Msg(debugstack(2, 1, 0))
        end
    end

    ---@cast frame +df_roundedcornermixin
    detailsFramework:Mixin(frame, detailsFramework.RoundedCornerPanelMixin)

    if (not frame["BuildOptionsTable"]) then
        ---@cast frame +df_optionsmixin
        detailsFramework:Mixin(frame, detailsFramework.OptionsFunctions)
    end

    frame:BuildOptionsTable(defaultOptions, {})

    frame.options.width = frame:GetWidth()
    frame.options.height = frame:GetHeight()

    frame:RoundedCornerConstructor()
    frame:HookScript("OnSizeChanged", frame.OnSizeChanged)

    frame.__rcorners = true

    --handle preset
    if (preset and type(preset) == "table") then
        frame.options.horizontal_border_size_offset = preset.horizontal_border_size_offset
        applyPreset(frame, preset)
    else
        applyPreset(frame, defaultPreset)
    end
end

---test case:
C_Timer.After(1, function()

    if true then return end

    local DF = DetailsFramework

    local parent = UIParent
    local name = "NewRoundedCornerFrame"
    local optionsTable = {
        use_titlebar = true,
        use_scalebar = true,
        title = "Test",
        scale = 1.0,
    }

    ---@type df_roundedpanel
    local frame = _G[name] or DF:CreateRoundedPanel(parent, name, optionsTable)
    frame:SetSize(800, 600)
    frame:SetPoint("center", parent, "center", 0, 0)

    frame:SetColor(.1, .1, .1, 1)
    frame:SetTitleBarColor(.2, .2, .2, .5)
    frame:SetBorderCornerColor(.2, .2, .2, .5)
    frame:SetRoundness(0)

    local radiusSlider = DF:CreateSlider(frame, 120, 14, 0, 15, 1, frame.cornerRoundness, false, "RadiusBar", nil, nil, DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE"))
    radiusSlider:SetHook("OnValueChange", function(self, fixedValue, value)
        value = floor(value)
        if (frame.cornerRoundness == value) then
            return
        end
        frame:SetRoundness(value)
    end)

    local radiusText = frame:CreateFontString(nil, "overlay", "GameFontNormal")
    radiusText:SetText("Radius:")
    radiusText:SetPoint("bottomleft", radiusSlider.widget, "topleft", 0, 0)
    radiusSlider:SetPoint(10, -100)
end)