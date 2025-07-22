
local Details = Details
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework
local _

Details222.ArenaSummary = {
    arenaData = {},
}

local ArenaSummary = Details222.ArenaSummary

function ArenaSummary.OpenWindow()
    if not ArenaSummary.window then
        ArenaSummary.window = ArenaSummary.CreateWindow()
    end

    if not ArenaSummary.window:IsShown() then
        ArenaSummary.window:Show()
    end

    --refresh the scroll area
    ArenaSummary.window.ArenaPlayersScroll:RefreshScroll()
end

local makePlayerTable = function()
    local playerTable = {
        name = "PlayerName",
        finalHits = 0,
        peakDamage = 0,
        dps = 0,
        peakHealing = 0,
        hps = 0,
    }

    return playerTable
end

function ArenaSummary.OnArenaStart()
    Details222.ArenaSummary.arenaData = {}

    --Details.arena_table [unitName] = {role = role}
    --Details.arena_enemies[enemyName] = "arena" .. i

    --Details.savedTimeCaptures table[] -> {timeDataName, callbackFunc, matrix, author, version, icon, bIsEnabled, do_not_save = no_save})
    --"Your Team Damage"
    --"Enemy Team Damage"
    --"Your Team Healing"
    --"Enemy Team Healing"
end

function ArenaSummary.OnArenaEnd()

end

function ArenaSummary.CreateWindow()
    local headerY = -20
    local maxLines = 10
    local lineHeight = 22
    local windowWidth = 500
    local windowHeight = 400
    local scrollWidth = windowWidth - 20
    local scrollHeight = windowHeight - headerY - 20

    local backdrop_color = {.2, .2, .2, 0.2}
    local backdrop_color_on_enter = {.8, .8, .8, 0.4}

    local window = detailsFramework:CreateSimplePanel(UIParent, windowWidth, windowHeight, "Arena Summary")
    window:SetPoint("center", UIParent, "center", 0, 0)
    window:SetFrameStrata("HIGH")
    window:SetFrameLevel(10)
    self.window = window

    --add a close button
    local closeButton = detailsFramework:CreateButton(window, function() window:Hide() end, 20, 20, "X")
    closeButton:SetPoint("topright", window, "topright", -5, -5)

    --header
		local headerTable = {
			{text = "", width = 20},
			{text = "Name", width = 100},
			{text = "Final Hits", width = 60},
			{text = "Peak Damage", width = 70},
			{text = "Dps", width = 60},
            {text = "Peak Healing", width = 70},
            {text = "Hps", width = 60},

		}
		local headerOptions = {
			padding = 2,
		}

		local header = detailsFramework:CreateHeader(window, headerTable, headerOptions)
		header:SetPoint("topleft", window, "topleft", 5, headerY)

    --create a scroll area for the lines
        local refreshFunc = function(self, data, offset, totalLines) --~refresh

        end

        local lineOnEnter = function(self) --~onenter
            self:SetBackdropColor(unpack(backdrop_color_on_enter))
        end

        local lineOnLeave = function(self) --~onleave
            self:SetBackdropColor(unpack(backdrop_color))
        end

        local createLineFunc = function(self, index)
			local line = CreateFrame("button", "$parentLine" .. index, self,"BackdropTemplate")
			line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(lineHeight+1)) - 1)
			line:SetSize(scrollWidth - 2, lineHeight)

			line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor(unpack(backdrop_color))

			-- ~createline --~line
			detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

			line:SetScript("OnEnter", lineOnEnter)
			line:SetScript("OnLeave", lineOnLeave)

			--icon
			local icon = line:CreateTexture("$parentSpellIcon", "overlay")
			icon:SetSize(lineHeight - 2, lineHeight - 2)

			--player name
			local playerNameText = line:CreateFontString("$parentPlayerName", "overlay", "GameFontNormal")

            --final hits
            local finalHitsText = line:CreateFontString("$parentFinalHits", "overlay", "GameFontNormal")

            --peak damage
            local peakDamageText = line:CreateFontString("$parentPeakDamage", "overlay", "GameFontNormal")

            --dps
            local dpsText = line:CreateFontString("$parentDps", "overlay", "GameFontNormal")

            --peak healing
            local peakHealingText = line:CreateFontString("$parentPeakHealing", "overlay", "GameFontNormal")

            --hps
            local hpsText = line:CreateFontString("$parentHps", "overlay", "GameFontNormal")

            line:AddFrameToHeaderAlignment(icon)
            line:AddFrameToHeaderAlignment(playerNameText)
            line:AddFrameToHeaderAlignment(finalHitsText)
            line:AddFrameToHeaderAlignment(peakDamageText)
            line:AddFrameToHeaderAlignment(dpsText)
            line:AddFrameToHeaderAlignment(peakHealingText)
            line:AddFrameToHeaderAlignment(hpsText)

            line:AlignWithHeader(header, "left")

            line.Icon = icon
            line.PlayerName = playerNameText
            line.FinalHits = finalHitsText
            line.PeakDamage = peakDamageText
            line.Dps = dpsText
            line.PeakHealing = peakHealingText
            line.Hps = hpsText

            return line
        end

        local arenaPlayersScroll = detailsFramework:CreateScrollBox(DetailsScrollDamage, "$parentSpellScroll", refreshFunc, {}, scrollWidth, scrollHeight, maxLines, lineHeight)
        arenaPlayersScroll:SetPoint("topleft", header, "bottomleft", 0, -5)
        window.ArenaPlayersScroll = arenaPlayersScroll

        function arenaPlayersScroll:RefreshScroll()
            local newData = {}
            arenaPlayersScroll:SetData(newData)
            arenaPlayersScroll:Refresh()
        end

		--create lines
		for i = 1, maxLines do
			arenaPlayersScroll:CreateLine(createLineFunc)
		end

    return window
end
