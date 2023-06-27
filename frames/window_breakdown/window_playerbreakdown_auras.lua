
local Details = Details
local GameTooltip = GameTooltip
local detailsFramework = DetailsFramework
local unpack = unpack
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo

local createAuraTabOnBreakdownWindow = function(tab, frame)
    local scroll_line_amount = 22
    local scroll_width = 410
    local scrollHeight = 445
    local scroll_line_height = 19
    local text_size = 10

    local debuffScrollStartX = 445

    local headerOffsetsBuffs = {
        --buff label, uptime, applications, refreshes, wa
        6, 190, 290, 336, 380
    }

    local headerOffsetsDebuffs = {
        --debuff label, uptime, applications, refreshes, wa
        426, 630, 729, 775, 820
    }

    local onEnterLine = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        Details:GameTooltipSetSpellByID(self.spellID)
        GameTooltip:Show()
        self:SetBackdropColor(1, 1, 1, .2)
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

        local iconTexture = line:CreateTexture("$parentIcon", "overlay")
        iconTexture:SetSize(scroll_line_height -2 , scroll_line_height - 2)
        local nameLabel = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
        local uptimeLabel = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
        local applyLabel = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
        local refreshLabel = line:CreateFontString("$parentName", "overlay", "GameFontNormal")

        detailsFramework:SetFontSize(nameLabel, text_size)
        detailsFramework:SetFontSize(uptimeLabel, text_size)
        detailsFramework:SetFontSize(applyLabel, text_size)
        detailsFramework:SetFontSize(refreshLabel, text_size)

        iconTexture:SetPoint("left", line, "left", 2, 0)
        nameLabel:SetPoint("left", iconTexture, "right", 2, 0)
        uptimeLabel:SetPoint("left", line, "left", 186, 0)
        applyLabel:SetPoint("left", line, "left", 276, 0)
        refreshLabel:SetPoint("left", line, "left", 322, 0)

        line.Icon = iconTexture
        line.Name = nameLabel
        line.Uptime = uptimeLabel
        line.Apply = applyLabel
        line.Refresh = refreshLabel

        nameLabel:SetJustifyH("left")
        uptimeLabel:SetJustifyH("left")

        applyLabel:SetJustifyH("center")
        refreshLabel:SetJustifyH("center")
        applyLabel:SetWidth(26)
        refreshLabel:SetWidth(26)

        return line
    end

    local lineBackgroundColor = {{1, 1, 1, .1}, {1, 1, 1, 0}}

    local scrollRefreshBuffs = function(self, data, offset, total_lines)
        for i = 1, total_lines do
            local index = i + offset
            local aura = data[index]

            if (aura) then
                local line = self:GetLine(i)
                line.spellID = aura.spellID
                line.Icon:SetTexture(aura[1])

                line.Icon:SetTexCoord(.1, .9, .1, .9)

                line.Name:SetText(aura[2])
                line.Uptime:SetText(detailsFramework:IntegerToTimer(aura[3]) .. "(|cFFBBAAAA" .. math.floor(aura[6]) .. "%|r)")
                line.Apply:SetText(aura[4])
                line.Refresh:SetText(aura[5])

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
    local miscActor = combat:GetActor(DETAILS_ATTRIBUTE_MISC, player:Name())
    ---@type number
    local combatTime = combat:GetCombatTime()

    if (miscActor) then
        do --buffs
            local newAuraTable = {}
            local spellContainer = miscActor:GetSpellContainer("buff")
            if (spellContainer) then
                for spellId, spellTable in spellContainer:ListSpells() do
                    local spellName, _, spellIcon = GetSpellInfo(spellId)
                    local uptime = spellTable.uptime or 0
                    table.insert(newAuraTable, {spellIcon, spellName, uptime, spellTable.appliedamt, spellTable.refreshamt, uptime / combatTime * 100, spellID = spellId})
                end
            end

            table.sort(newAuraTable, Details.Sort3)
            tab.BuffScroll:SetData(newAuraTable)
            tab.BuffScroll:Refresh()
        end

        do --debuffs
            local newAuraTable = {}
            local spellContainer = miscActor:GetSpellContainer("debuff")
            if (spellContainer) then
                for spellId, spellTable in spellContainer:ListSpells() do
                    local spellName, _, spellIcon = GetSpellInfo(spellId)
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