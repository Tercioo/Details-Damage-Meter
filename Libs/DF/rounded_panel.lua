
---@class detailsframework
local detailsFramework = _G.DetailsFramework
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local unpack = unpack

local CreateFrame = CreateFrame
local defaultRed, defaultGreen, defaultBlue = detailsFramework:GetDefaultBackdropColor()
local defaultColorTable = {.98, .98, .98, 1}
local defaultBorderColorTable = {.2, .2, .2, .5}
local titleBarColor = {.2, .2, .2, .5}

local PixelUtil = PixelUtil or DFPixelUtil

---@type edgenames[]
local cornerNames = {"TopLeft", "TopRight", "BottomLeft", "BottomRight"}

---@class blz_backdrop : table
---@field TopLeftCorner texture
---@field TopRightCorner texture
---@field BottomLeftCorner texture
---@field BottomRightCorner texture
---@field TopEdge texture
---@field BottomEdge texture
---@field LeftEdge texture
---@field RightEdge texture
---@field Center texture

---@class cornertextures : table
---@field TopLeft texture
---@field TopRight texture
---@field BottomLeft texture
---@field BottomRight texture

---@class edgetextures : table
---@field Top texture
---@field Bottom texture
---@field Left texture
---@field Right texture

---@class df_roundedpanel_options : table
---@field width number?
---@field height number?
---@field use_titlebar boolean?
---@field use_scalebar boolean?
---@field title string?
---@field scale number?
---@field roundness number?
---@field color any
---@field border_color any
---@field corner_texture any
---@field horizontal_border_size_offset number?
---@field titlebar_height number?

---@class df_roundedpanel_preset : table, df_roundedpanel_options
---@field border_color any
---@field color any
---@field roundness number?
---@field titlebar_height number?

---@class df_roundedcornermixin : table
---@field RoundedCornerConstructor fun(self:df_roundedpanel) --called from CreateRoundedPanel
---@field SetColor fun(self:df_roundedpanel, red: any, green: number|nil, blue: number|nil, alpha: number|nil)
---@field SetBorderCornerColor fun(self:df_roundedpanel, red: any, green: number|nil, blue: number|nil, alpha: number|nil)
---@field SetRoundness fun(self:df_roundedpanel, slope: number)
---@field GetCornerSize fun(self:df_roundedpanel) : width, height
---@field OnSizeChanged fun(self:df_roundedpanel) --called when the frame size changes
---@field CreateBorder fun(self:df_roundedpanel) --called from SetBorderCornerColor if the border is not created yet
---@field CalculateBorderEdgeSize fun(self:df_roundedpanel, alignment: "vertical"|"horizontal"): number --calculate the size of the border edge texture
---@field SetTitleBarColor fun(self:df_roundedpanel, red: any, green: number|nil, blue: number|nil, alpha: number|nil)
---@field GetMaxFrameLevel fun(self:df_roundedpanel) : number --return the max frame level of the frame and its children

---@class df_roundedpanel : frame, df_roundedcornermixin, df_optionsmixin, df_titlebar
---@field disabled boolean
---@field bHasBorder boolean
---@field bHasTitleBar boolean
---@field options df_roundedpanel_options
---@field cornerRoundness number
---@field CornerTextures cornertextures
---@field CenterTextures texture[]
---@field BorderCornerTextures cornertextures
---@field BorderEdgeTextures edgetextures
---@field TitleBar df_roundedpanel
---@field bIsTitleBar boolean
---@field TopLeft texture corner texture
---@field TopRight texture corner texture
---@field BottomLeft texture corner texture
---@field BottomRight texture corner texture
---@field TopEdgeBorder texture border edge
---@field BottomEdgeBorder texture border edge
---@field LeftEdgeBorder texture border edge
---@field RightEdgeBorder texture border edge
---@field TopLeftBorder texture border corner
---@field TopRightBorder texture border corner
---@field BottomLeftBorder texture border corner
---@field BottomRightBorder texture border corner
---@field TopHorizontalEdge texture texture connecting the top corners
---@field BottomHorizontalEdge texture texture connecting the bottom corners
---@field CenterBlock texture texture connecting the bottom left of the topleft corner with the top right of the bottom right corner

---@param self df_roundedpanel
---@param textures cornertextures
---@param width number|nil
---@param height number|nil
---@param xOffset number|nil
---@param yOffset number|nil
---@param bIsBorder boolean|nil
local setCornerPoints = function(self, textures, width, height, xOffset, yOffset, bIsBorder)
    for cornerName, thisTexture in pairs(textures) do
        PixelUtil.SetSize(thisTexture, width or 16, height or 16)
        thisTexture:SetTexture(self.options.corner_texture, "CLAMP", "CLAMP", "TRILINEAR")

        --set the mask
        if (not thisTexture.MaskTexture and bIsBorder) then
            thisTexture.MaskTexture = self:CreateMaskTexture(nil, "background")
            thisTexture.MaskTexture:SetSize(74, 64)
            thisTexture:AddMaskTexture(thisTexture.MaskTexture)
            thisTexture.MaskTexture:SetTexture([[Interface\Azerite\AzeriteGoldRingRank2]], "CLAMP", "CLAMP", "TRILINEAR") --1940690
            --thisTexture.MaskTexture:Hide()
        end

        xOffset = xOffset or 0
        yOffset = yOffset or 0

        --todo: adjust the other corners setpoint offset
        --todo (done): use mask when the alpha is below 0.98, disable the mask when the alpha is above 0.98

        if (cornerName == "TopLeft") then
            thisTexture:SetTexCoord(0, 0.5, 0, 0.5)
            PixelUtil.SetPoint(thisTexture, cornerName, self, cornerName, -xOffset, yOffset)
            if (thisTexture.MaskTexture) then
                PixelUtil.SetPoint(thisTexture.MaskTexture, cornerName, self, cornerName, -18-xOffset, 16+yOffset)
            end

        elseif (cornerName == "TopRight") then
            thisTexture:SetTexCoord(0.5, 1, 0, 0.5)
            PixelUtil.SetPoint(thisTexture, cornerName, self, cornerName, xOffset, yOffset)
            if (thisTexture.MaskTexture) then
                PixelUtil.SetPoint(thisTexture.MaskTexture, cornerName, self, cornerName, -18+xOffset, 16+yOffset)
            end

        elseif (cornerName == "BottomLeft") then
            thisTexture:SetTexCoord(0, 0.5, 0.5, 1)
            PixelUtil.SetPoint(thisTexture, cornerName, self, cornerName, -xOffset, -yOffset)
            if (thisTexture.MaskTexture) then
                PixelUtil.SetPoint(thisTexture.MaskTexture, cornerName, self, cornerName, -18-xOffset, 16-yOffset)
            end

        elseif (cornerName == "BottomRight") then
            thisTexture:SetTexCoord(0.5, 1, 0.5, 1)
            PixelUtil.SetPoint(thisTexture, cornerName, self, cornerName, xOffset, -yOffset)
            if (thisTexture.MaskTexture) then
                PixelUtil.SetPoint(thisTexture.MaskTexture, cornerName, self, cornerName, -18+xOffset, 16-yOffset)
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
        PixelUtil.SetPoint(topHorizontalEdge, "topleft", self.CornerTextures["TopLeft"], "topright", 0, 0)
        PixelUtil.SetPoint(topHorizontalEdge, "bottomleft", self.CornerTextures["TopLeft"], "bottomright", 0, 0)
        PixelUtil.SetPoint(topHorizontalEdge, "topright", self.CornerTextures["TopRight"], "topleft", 0, 0)
        PixelUtil.SetPoint(topHorizontalEdge, "bottomright", self.CornerTextures["TopRight"], "bottomleft", 0, 0)
        topHorizontalEdge:SetColorTexture(unpack(defaultColorTable))

        --create the bottom texture which connects the bottom corners with a horizontal line
        ---@type texture
        local bottomHorizontalEdge = self:CreateTexture(nil, "border", nil, 0)
        PixelUtil.SetPoint(bottomHorizontalEdge, "topleft", self.CornerTextures["BottomLeft"], "topright", 0, 0)
        PixelUtil.SetPoint(bottomHorizontalEdge, "bottomleft", self.CornerTextures["BottomLeft"], "bottomright", 0, 0)
        PixelUtil.SetPoint(bottomHorizontalEdge, "topright", self.CornerTextures["BottomRight"], "topleft", 0, 0)
        PixelUtil.SetPoint(bottomHorizontalEdge, "bottomright", self.CornerTextures["BottomRight"], "bottomleft", 0, 0)
        bottomHorizontalEdge:SetColorTexture(unpack(defaultColorTable))

        --create the center block which connects the bottom left of the topleft corner with the top right of the bottom right corner
        ---@type texture
        local centerBlock = self:CreateTexture(nil, "border", nil, 0)
        PixelUtil.SetPoint(centerBlock, "topleft", self.CornerTextures["TopLeft"], "bottomleft", 0, 0)
        PixelUtil.SetPoint(centerBlock, "bottomleft", self.CornerTextures["BottomLeft"], "topleft", 0, 0)
        PixelUtil.SetPoint(centerBlock, "topright", self.CornerTextures["BottomRight"], "topright", 0, 0)
        PixelUtil.SetPoint(centerBlock, "bottomright", self.CornerTextures["BottomRight"], "topright", 0, 0)
        centerBlock:SetColorTexture(unpack(defaultColorTable))

        self:CreateBorder()
        self:SetBorderCornerColor(0, 0, 0, 0)

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

        PixelUtil.SetSize(self, width, height)

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
    CreateTitleBar = function(self, optionsTable)
        ---@type df_roundedpanel
        local titleBar = detailsFramework:CreateRoundedPanel(self, "$parentTitleBar", {width = self.options.width - 6, height = self.options.titlebar_height})
        titleBar:SetPoint("top", self, "top", 0, -4)
        titleBar:SetRoundness(5)
        titleBar:SetFrameLevel(9500)
        titleBar:SetColor(unpack(titleBarColor))
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
        if (self.disabled) then
            return
        end

        --if the frame has a titlebar, need to adjust the size of the titlebar
        if (self.bHasTitleBar) then
            self.TitleBar:SetWidth(self:GetWidth() - 14)
        end

        --if the frame height is below 32, need to recalculate the size of the corners
        ---@type height
        local frameHeight = self:GetHeight()

        if (false and frameHeight < 32) then
            local newCornerSize = frameHeight / 2

            --set the new size of the corners on all corner textures
            for _, thisTexture in pairs(self.CornerTextures) do
                PixelUtil.SetSize(thisTexture, newCornerSize - (self.cornerRoundness - 2), newCornerSize)
            end

            --check if the frame has border and set the size of the border corners as well
            if (self.bHasBorder) then
                for _, thisTexture in pairs(self.BorderCornerTextures) do
                    PixelUtil.SetSize(thisTexture, newCornerSize-2, newCornerSize+2)
                end

                --hide the left and right edges as the corner textures already is enough to fill the frame
                self.BorderEdgeTextures["Left"]:Hide()
                self.BorderEdgeTextures["Right"]:Hide()

                local horizontalEdgesNewSize = self:CalculateBorderEdgeSize("horizontal")
                PixelUtil.SetSize(self.BorderEdgeTextures["Top"], horizontalEdgesNewSize + (self.options.horizontal_border_size_offset or 0), 1)
                PixelUtil.SetSize(self.BorderEdgeTextures["Bottom"], horizontalEdgesNewSize + (self.options.horizontal_border_size_offset or 0), 1)
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
                PixelUtil.SetSize(thisTexture, cornerWidth-self.cornerRoundness, cornerHeight-self.cornerRoundness)
            end

            if (self.bHasBorder) then
                for _, thisTexture in pairs(self.BorderCornerTextures) do
                    PixelUtil.SetSize(thisTexture, cornerWidth-self.cornerRoundness, cornerHeight-self.cornerRoundness)
                    thisTexture.MaskTexture:SetSize(74-(self.cornerRoundness*0.75), 64-self.cornerRoundness)
                end

                local horizontalEdgesNewSize = self:CalculateBorderEdgeSize("horizontal")
                PixelUtil.SetSize(self.BorderEdgeTextures["Top"], horizontalEdgesNewSize, 1)
                PixelUtil.SetSize(self.BorderEdgeTextures["Bottom"], horizontalEdgesNewSize, 1)

                local verticalEdgesNewSize = self:CalculateBorderEdgeSize("vertical")
                PixelUtil.SetSize(self.BorderEdgeTextures["Left"], 1, verticalEdgesNewSize)
                PixelUtil.SetSize(self.BorderEdgeTextures["Right"], 1, verticalEdgesNewSize)
            end
        end
    end,

    DisableRoundedCorners = function(self)
		self.TopLeft:Hide()
		self.TopRight:Hide()
		self.BottomLeft:Hide()
		self.BottomRight:Hide()
		self.CenterBlock:Hide()
		self.TopEdgeBorder:Hide()
		self.BottomEdgeBorder:Hide()
		self.LeftEdgeBorder:Hide()
		self.RightEdgeBorder:Hide()
		self.TopLeftBorder:Hide()
		self.TopRightBorder:Hide()
		self.BottomLeftBorder:Hide()
		self.BottomRightBorder:Hide()
		self.TopHorizontalEdge:Hide()
		self.BottomHorizontalEdge:Hide()
        self.disabled = true
    end,

    EnableRoundedCorners = function(self)
		self.TopLeft:Show()
		self.TopRight:Show()
		self.BottomLeft:Show()
		self.BottomRight:Show()
		self.CenterBlock:Show()
		self.TopEdgeBorder:Show()
		self.BottomEdgeBorder:Show()
		self.LeftEdgeBorder:Show()
		self.RightEdgeBorder:Show()
		self.TopLeftBorder:Show()
		self.TopRightBorder:Show()
		self.BottomLeftBorder:Show()
		self.BottomRightBorder:Show()
		self.TopHorizontalEdge:Show()
		self.BottomHorizontalEdge:Show()
        self.disabled = false
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
            if (self.tabSide) then
                if (self.tabSide == "top" or self.tabSide == "bottom") then
                    return self:GetHeight() - (borderTexture:GetHeight() * 2) + 2 - borderTexture:GetHeight()
                end
            end
            return self:GetHeight() - (borderTexture:GetHeight() * 2) + 2

        elseif (alignment == "horizontal") then
            if (self.tabSide) then
                if (self.tabSide == "left" or self.tabSide == "right") then
                    return self:GetWidth() - (borderTexture:GetHeight() * 2) + 2 - borderTexture:GetHeight()
                end
            end
            return self:GetWidth() - (borderTexture:GetHeight() * 2) + 2
        end

        error("df_roundedpanel:CalculateBorderEdgeSize(self, alignment) alignment must be 'vertical' or 'horizontal'")
    end,

    ---create the border textures
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
        PixelUtil.SetPoint(topEdge, "bottom", self, "top", 0, 0)
        self.BorderEdgeTextures["Top"] = topEdge

        ---@type texture
        local leftEdge = self:CreateTexture(nil, "background", nil, 0)
        PixelUtil.SetPoint(leftEdge, "right", self, "left", 0, 0)
        self.BorderEdgeTextures["Left"] = leftEdge

        ---@type texture
        local bottomEdge = self:CreateTexture(nil, "background", nil, 0)
        PixelUtil.SetPoint(bottomEdge, "top", self, "bottom", 0, 0)
        self.BorderEdgeTextures["Bottom"] = bottomEdge

        ---@type texture
        local rightEdge = self:CreateTexture(nil, "background", nil, 0)
        PixelUtil.SetPoint(rightEdge, "left", self, "right", 0, 0)
        self.BorderEdgeTextures["Right"] = rightEdge

        ---@type width
        local horizontalEdgeSize = self:CalculateBorderEdgeSize("horizontal")
        ---@type height
        local verticalEdgeSize = self:CalculateBorderEdgeSize("vertical")

        --set the edges size
        PixelUtil.SetSize(topEdge, horizontalEdgeSize, 1)
        PixelUtil.SetSize(leftEdge, 1, verticalEdgeSize)
        PixelUtil.SetSize(bottomEdge, horizontalEdgeSize, 1)
        PixelUtil.SetSize(rightEdge, 1, verticalEdgeSize)

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

    ---set the color of the titlebar
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

    ---set the color of the border corners
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

    ---set the background color of the rounded panel
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
            if (alpha < 0.979) then
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
    color = {.1, .1, .1, 1},
    border_color = {.2, .2, .2, .5},
    corner_texture = [[Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall]],
    titlebar_height = 26,
}

local defaultPreset = {
    color = {.1, .1, .1, 1},
    border_color = {.2, .2, .2, .5},
    roundness = 3,
    titlebar_height = 16,
}

---create a regular panel with rounded corner
---@param parent frame
---@param name string|nil
---@param optionsTable table|nil
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
        local titleBar = newRoundedPanel:CreateTitleBar(newRoundedPanel.options)

        --[=[
        local titleBar = detailsFramework:CreateRoundedPanel(newRoundedPanel, "$parentTitleBar", {height = newRoundedPanel.options.titlebar_height, title = newRoundedPanel.options.title})
        titleBar:SetColor(unpack(titleBarColor))
        titleBar:SetPoint("top", newRoundedPanel, "top", 0, -7)

        titleBar:SetBorderCornerColor(0, 0, 0, 0)

        newRoundedPanel.TitleBar = titleBar
        titleBar:SetRoundness(5)
        newRoundedPanel.bHasTitleBar = true
        --]=]
    end

    if (newRoundedPanel.options.use_scalebar) then
        detailsFramework:CreateScaleBar(newRoundedPanel.TitleBar or newRoundedPanel, newRoundedPanel.options)
        newRoundedPanel:SetScale(newRoundedPanel.options.scale)
    end

    newRoundedPanel:SetRoundness(newRoundedPanel.options.roundness)
    newRoundedPanel:SetBorderCornerColor(newRoundedPanel.options.border_color)
    newRoundedPanel:SetColor(newRoundedPanel.options.color)

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
        frame:CreateTitleBar(preset)
        frame.TitleBar.Text:SetText(preset.title)
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
        frame.options.titlebar_height = preset.titlebar_height
        applyPreset(frame, preset)
    else
        applyPreset(frame, defaultPreset)
        preset = defaultPreset
    end

    if (preset.tab_side) then
        if (preset.tab_side == "top") then
            --hide the bottom textures of the rounded corner, the top and middle textures will be used to fill the tab
            frame.BottomHorizontalEdge:Hide()
            frame.BottomLeft:Hide()
            frame.BottomRight:Hide()

            local point1, relativeTo, point2, x, y = frame.CornerTextures["TopLeft"]:GetPoint(1)
            frame.CornerTextures["TopLeft"]:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

            point1, relativeTo, point2, x, y = frame.CornerTextures["TopRight"]:GetPoint(1)
            frame.CornerTextures["TopRight"]:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

            if (frame.BorderCornerTextures["TopLeft"]) then
                point1, relativeTo, point2, x, y = frame.BorderCornerTextures["TopLeft"]:GetPoint(1)
                frame.BorderCornerTextures["TopLeft"]:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

                point1, relativeTo, point2, x, y = frame.BorderCornerTextures["TopRight"]:GetPoint(1)
                frame.BorderCornerTextures["TopRight"]:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

                point1, relativeTo, point2, x, y = frame.TopEdgeBorder:GetPoint(1)
                frame.TopEdgeBorder:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

                frame.BottomEdgeBorder:Hide()

                frame.tabSide = "top"
            end

        elseif (preset.tab_side == "bottom") then
            --hide the top textures of the rounded corner, the bottom and middle textures will be used to fill the tab
            frame.TopHorizontalEdge:Hide()
            frame.TopLeft:Hide()
            frame.TopRight:Hide()

            local point1, relativeTo, point2, x, y = frame.CornerTextures["BottomLeft"]:GetPoint(1)
            frame.CornerTextures["BottomLeft"]:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

            point1, relativeTo, point2, x, y = frame.CornerTextures["BottomRight"]:GetPoint(1)
            frame.CornerTextures["BottomRight"]:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

            if (frame.BorderCornerTextures["BottomLeft"]) then
                point1, relativeTo, point2, x, y = frame.BorderCornerTextures["BottomLeft"]:GetPoint(1)
                frame.BorderCornerTextures["BottomLeft"]:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

                point1, relativeTo, point2, x, y = frame.BorderCornerTextures["BottomRight"]:GetPoint(1)
                frame.BorderCornerTextures["BottomRight"]:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

                point1, relativeTo, point2, x, y = frame.BottomEdgeBorder:GetPoint(1)
                frame.BottomEdgeBorder:SetPoint(point1, relativeTo, point2, x, math.abs(preset.roundness -16))

                frame.TopEdgeBorder:Hide()

                point1, relativeTo, point2, x, y = frame.RightEdgeBorder:GetPoint(1)
                ---@type height
                local verticalEdgeSize = frame:CalculateBorderEdgeSize("vertical")
                frame.RightEdgeBorder:SetHeight(verticalEdgeSize - 6)
                frame.tabSide = "bottom"
            end
        end
    end
end

