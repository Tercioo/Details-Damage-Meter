
---@type details
local Details = Details
---@type detailsframework
local detailsFramework = DetailsFramework

local GameTooltip = GameTooltip
local unpack = unpack
local CreateFrame = CreateFrame

local _

Details.BuffUptimeSpellsToIgnore = {
    [186401] = true, --Sign of the Skirmisher
    [366646] = true, --Familiar Skies
    [403265] = true, --Bronze Attunement
    [381748] = true, --Blessing of the Bronze
    [397734] = true, --Word of a Worthy Ally
    [402221] = true, --Obsidian Resonance
    [225788] = true, --Sign of the Emissary
    --[] = true, --
}

local createAuraTabOnBreakdownWindow = function(tab, frame)
    local scroll_line_amount = 25
    local scroll_width = 410
    local scrollHeight = 495
    local scroll_line_height = 19
    local text_size = 10

    local debuffScrollStartX = 445

    local lineBackgroundColor = {{1, 1, 1, .1}, {1, 1, 1, 0}}

    local headerOffsetsBuffs = {
        --buff label, uptime, applications, refreshes, wa
        6, 190, 290, 336, 380
    }

    local headerOffsetsDebuffs = {
        --debuff label, uptime, applications, refreshes, wa
        426, 630, 729, 775, 820
    }

    local onEnterLine = function(self)
        if (self.spellID) then
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            Details:GameTooltipSetSpellByID(self.spellID)
            GameTooltip:Show()
            self:SetBackdropColor(1, 1, 1, .2)
        end
    end

    local onLeaveLine = function(self)
        GameTooltip:Hide()
        self:SetBackdropColor(unpack(self.BackgroundColor))
    end

    local onClickLine = function(self)

    end

    local createLineScroll = function(self, index)
        local line = CreateFrame("button", "$parentLine" .. index, self,"BackdropTemplate")
        line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)))
        line:SetSize(scroll_width -2, scroll_line_height)
        line:SetScript("OnEnter", onEnterLine)
        line:SetScript("OnLeave", onLeaveLine)
        line:SetScript("OnClick", onClickLine)

        line:SetBackdrop({bgFile =[[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        line:SetBackdropColor(0, 0, 0, 0.2)
        line.BackgroundColor = lineBackgroundColor[1]

        local iconTexture = line:CreateTexture("$parentIcon", "overlay")
        iconTexture:SetSize(scroll_line_height -2 , scroll_line_height - 2)
        iconTexture:SetAlpha(0.924)
        detailsFramework:SetMask(iconTexture, Details:GetTextureAtlas("iconmask"))

        local nameLabel = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
        local uptimeLabel = line:CreateFontString("$parentUptime", "overlay", "GameFontNormal")
        local uptimePercentLabel = line:CreateFontString("$parentPercent", "overlay", "GameFontNormal")
        local applyLabel = line:CreateFontString("$parentApplyed", "overlay", "GameFontNormal")
        local refreshLabel = line:CreateFontString("$parentRefreshed", "overlay", "GameFontNormal")

        local receivedTexture = line:CreateTexture("$parentReceived", "artwork")
        receivedTexture:SetPoint("topright", line, "topright", 0, 0)
        receivedTexture:SetPoint("bottomright", line, "bottomright", 0, 0)
        receivedTexture:SetWidth(line:GetWidth())
        receivedTexture:SetTexture([[Interface\AddOns\Details\images\bar_textures\gradient_white_10percent_left]])
        receivedTexture:SetTexCoord(0, 1, 0, 1)
        receivedTexture:SetVertexColor(0, .8, 0, 0.7)
        receivedTexture:Hide()

        detailsFramework:SetFontSize(nameLabel, text_size)
        detailsFramework:SetFontSize(uptimeLabel, text_size)
        detailsFramework:SetFontSize(uptimePercentLabel, text_size)
        detailsFramework:SetFontSize(applyLabel, text_size)
        detailsFramework:SetFontSize(refreshLabel, text_size)

        iconTexture:SetPoint("left", line, "left", 2, 0)
        nameLabel:SetPoint("left", iconTexture, "right", 2, 0)
        uptimeLabel:SetPoint("left", line, "left", 186, 0)
        uptimePercentLabel:SetPoint("left", line, "left", 220, 0)
        applyLabel:SetPoint("left", line, "left", 276, 0)
        refreshLabel:SetPoint("left", line, "left", 322, 0)

        line.Icon = iconTexture
        line.Name = nameLabel
        line.Uptime = uptimeLabel
        line.UptimePercent = uptimePercentLabel
        line.Apply = applyLabel
        line.Refresh = refreshLabel
        line.ReceivedAura = receivedTexture

        nameLabel:SetJustifyH("left")
        uptimeLabel:SetJustifyH("left")
        uptimePercentLabel:SetJustifyH("left")

        applyLabel:SetJustifyH("center")
        refreshLabel:SetJustifyH("center")
        applyLabel:SetWidth(26)
        refreshLabel:SetWidth(26)

        return line
    end

    local scrollRefreshBuffs = function(self, data, offset, total_lines)
        for i = 1, total_lines do
            local index = i + offset
            local aura = data[index]

            if (aura) then
                local spellIcon, spellName, uptime, applicationsAmount, refreshedAmount, uptimePercent = unpack(aura)
                local line = self:GetLine(i)

                if (aura.bReceived) then
                    line.ReceivedAura:Show()
                else
                    line.ReceivedAura:Hide()
                end

                line.spellID = aura.spellID
                line.Icon:SetTexture(spellIcon)

                line.Icon:SetTexCoord(.1, .9, .1, .9)

                line.Name:SetText(spellName)
                line.Uptime:SetText(detailsFramework:IntegerToTimer(uptime))
                line.UptimePercent:SetText("|cFFBBAAAA" .. math.floor(uptimePercent) .. "%|r")
                line.Apply:SetText(applicationsAmount)
                line.Refresh:SetText(refreshedAmount)

                if (i % 2 == 0) then
                    line:SetBackdropColor(unpack(lineBackgroundColor[1]))
                    line.BackgroundColor = lineBackgroundColor[1]
                else
                    line:SetBackdropColor(unpack(lineBackgroundColor[2]))
                    line.BackgroundColor = lineBackgroundColor[2]
                end
            end
        end
    end

    local createTitleDesc_Frame = function(anchorWidget, desc)
        local newTitleDescFrame = CreateFrame("frame", nil, frame)
        newTitleDescFrame:SetSize(40, 20)
        newTitleDescFrame:SetPoint("center", anchorWidget, "center")

        newTitleDescFrame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(newTitleDescFrame, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(desc)
            GameTooltip:Show()
        end)

        newTitleDescFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        return newTitleDescFrame
    end

    local buffLabel = detailsFramework:CreateLabel(frame, "Buff Name")
    buffLabel:SetPoint(headerOffsetsBuffs[1], -10)
    local uptimeLabel = detailsFramework:CreateLabel(frame, "Uptime")
    uptimeLabel:SetPoint(headerOffsetsBuffs[2], -10)

    local appliedLabel = detailsFramework:CreateLabel(frame, "A")
    appliedLabel:SetPoint(headerOffsetsBuffs[3], -10)
    createTitleDesc_Frame(appliedLabel.widget, "applications")

    local refreshedLabel = detailsFramework:CreateLabel(frame, "R")
    refreshedLabel:SetPoint(headerOffsetsBuffs[4], -10)
    createTitleDesc_Frame(refreshedLabel.widget, "refreshes")

    local buffScroll = detailsFramework:CreateScrollBox(frame, "$parentBuffUptimeScroll", scrollRefreshBuffs, {}, scroll_width, scrollHeight, scroll_line_amount, scroll_line_height)
    buffScroll:SetPoint("topleft", frame, "topleft", 5, -30)
    for i = 1, scroll_line_amount do
        local line = buffScroll:CreateLine(createLineScroll)
        line.AuraType = "BUFF"
    end
    detailsFramework:ReskinSlider(buffScroll)
    tab.BuffScroll = buffScroll

    local debuffLabel = detailsFramework:CreateLabel(frame, "Debuff Name")
    debuffLabel:SetPoint(headerOffsetsDebuffs[1], -10)

    local uptimeLabel2 = detailsFramework:CreateLabel(frame, "Uptime")
    uptimeLabel2:SetPoint(headerOffsetsDebuffs[2], -10)

    local appliedLabel2 = detailsFramework:CreateLabel(frame, "A")
    appliedLabel2:SetPoint(headerOffsetsDebuffs[3], -10)
    createTitleDesc_Frame(appliedLabel2.widget, "applications")

    local refreshedLabel2 = detailsFramework:CreateLabel(frame, "R")
    refreshedLabel2:SetPoint(headerOffsetsDebuffs[4], -10)
    createTitleDesc_Frame(refreshedLabel2.widget, "refreshes")

    local debuffScroll = detailsFramework:CreateScrollBox(frame, "$parentDebuffUptimeScroll", scrollRefreshBuffs, {}, scroll_width, scrollHeight, scroll_line_amount, scroll_line_height)
    debuffScroll:SetPoint("topleft", frame, "topleft", debuffScrollStartX, -30)
    for i = 1, scroll_line_amount do
        local line = debuffScroll:CreateLine(createLineScroll)
        line.AuraType = "DEBUFF"
    end
    detailsFramework:ReskinSlider(debuffScroll)

    tab.DebuffScroll = debuffScroll

    if (not frame.__background) then
        DetailsFramework:ApplyStandardBackdrop(frame)
        frame.__background:SetAlpha(0.6)
    end
end

local aurasTabFillCallback = function(tab, player, combat)
    ---@type actor
    local utilityActor = combat:GetActor(DETAILS_ATTRIBUTE_MISC, player:Name())
    ---@type number
    local combatTime = combat:GetCombatTime()

    if (utilityActor) then
        do --buffs
            local newAuraTable = {}
            local spellContainer = utilityActor:GetSpellContainer("buff")
            if (spellContainer) then
                for spellId, spellTable in spellContainer:ListSpells() do
                    local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
                    local uptime = spellTable.uptime or 0
                    if (not Details.BuffUptimeSpellsToIgnore[spellId]) then
                        table.insert(newAuraTable, {spellIcon, spellName, uptime, spellTable.appliedamt, spellTable.refreshamt, uptime / combatTime * 100, spellID = spellId})
                    end
                end
            end

            --check if this player has a augmentation buff container
            local augmentedBuffContainer = utilityActor.received_buffs_spells
            if (augmentedBuffContainer) then
                for sourceNameSpellId, spellTable in augmentedBuffContainer:ListSpells() do
                    local sourceName, spellId = strsplit("@", sourceNameSpellId)
                    spellId = tonumber(spellId)
                    local spellName, _, spellIcon = Details.GetSpellInfo(spellId)

                    if (spellName) then
                        sourceName = detailsFramework:RemoveRealmName(sourceName)
                        local uptime = spellTable.uptime or 0
                        table.insert(newAuraTable, {spellIcon, spellName .. " [" .. sourceName .. "]", uptime, spellTable.appliedamt, spellTable.refreshamt, uptime / combatTime * 100, spellID = spellId, bReceived = true})
                    end
                end
            end

            table.sort(newAuraTable, Details.Sort3)
            tab.BuffScroll:SetData(newAuraTable)
            tab.BuffScroll:Refresh()
        end

        do --debuffs
            local newAuraTable = {}
            local spellContainer = utilityActor:GetSpellContainer("debuff")
            if (spellContainer) then
                for spellId, spellTable in spellContainer:ListSpells() do
                    local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
                    table.insert(newAuraTable, {spellIcon, spellName, spellTable.uptime, spellTable.appliedamt, spellTable.refreshamt, spellTable.uptime / combatTime * 100, spellID = spellId})
                end
            end

            table.sort(newAuraTable, Details.Sort3)
            tab.DebuffScroll:SetData(newAuraTable)
            tab.DebuffScroll:Refresh()
        end
    end
end

local iconTableAuras = {
    texture = [[Interface\AddOns\Details\images\icons]],
    coords = {257/512, 278/512, 0/512, 19/512},
    width = 16,
    height = 16,
}

function Details:InitializeAurasTab()
    --check if the tab is already created
    for i = 1, #Details.player_details_tabs do
        local tabButton = Details.player_details_tabs[i]
        if (tabButton.tabname == "Auras") then
            return
        end
    end

    Details:CreatePlayerDetailsTab("Auras", --[1] tab name
        "Auras",  --[2] localized name
        function(tabOBject, playerObject)  --[3] condition
            return true
        end,

        aurasTabFillCallback, --[4] fill function

        nil, --[5] onclick

        createAuraTabOnBreakdownWindow, --[6] oncreate
        iconTableAuras --icon table
    )
end