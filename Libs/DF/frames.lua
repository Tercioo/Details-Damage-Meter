
local detailsFramework = _G.DetailsFramework
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local CreateFrame = CreateFrame

---@class df_roundedpanel : frame, blz_backdrop, df_optionsmixin, df_titlebar
---@field cornerTextures texture[]
---@field edgeTextures texture[]
---@field Constructor fun(self:df_roundedpanel)

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

detailsFramework.RoundedCornerPanelMixin = {
    Constructor = function(self)
        self.cornerTextures = {}
        self.edgeTextures = {}

        local red, green, blue, alpha = detailsFramework:GetDefaultBackdropColor()

		self:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		self:SetBackdropColor(red, green, blue, alpha * 0.95)
		self:SetBackdropBorderColor(0, 0, 0, 0.95)

        self.__background = self:CreateTexture(nil, "border", nil, -6)
        self.__background:SetColorTexture(red, green, blue)
        self.__background:SetAllPoints()

        self:SetSize(self.options.width, self.options.height)

        if (self.options.use_titlebar) then
            detailsFramework:CreateTitleBar(self)
            self:SetTitle(self.options.title)
        end

        if (self.options.use_scalebar) then
            detailsFramework:CreateScaleBar(self, self.options)
            self:SetScale(self.options.scale)
        end

        --fill the corner and edge textures table
        for index, cornerName in ipairs({"TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner"}) do
            local thisTexture = self[cornerName]
            self.cornerTextures[cornerName] = thisTexture
            thisTexture:SetTexture([[Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall]])

            --local bIsOdd = index % 2 == 1
            --thisTexture:SetTexCoord(bIsOdd and 0 or 0.5, index < 3 and 0 or 0.5, bIsOdd and 0.5 or 1, index < 3 and 0.5 or 1)

            if (cornerName == "TopLeftCorner") then
                thisTexture:SetTexCoord(0, 0.5, 0, 0.5)
            elseif (cornerName == "TopRightCorner") then
                thisTexture:SetTexCoord(0.5, 1, 0, 0.5)
            elseif (cornerName == "BottomLeftCorner") then
                thisTexture:SetTexCoord(0, 0.5, 0.5, 1)
            elseif (cornerName == "BottomRightCorner") then
                thisTexture:SetTexCoord(0.5, 1, 0.5, 1)
            end
        end

        for _, edgeName in ipairs({"TopEdge", "BottomEdge", "LeftEdge", "RightEdge"}) do
            self.edgeTextures[edgeName] = self[edgeName]
        end
    end,
}

local defaultOptions = {
    width = 200,
    height = 200,
    use_titlebar = true,
    use_scalebar = true,
    title = "",
    scale = 1,
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

    detailsFramework:Mixin(newRoundedPanel, detailsFramework.RoundedCornerPanelMixin)
    detailsFramework:Mixin(newRoundedPanel, detailsFramework.OptionsFunctions)

    newRoundedPanel:BuildOptionsTable(defaultOptions, optionsTable or {})

    newRoundedPanel:Constructor()

    return newRoundedPanel
end