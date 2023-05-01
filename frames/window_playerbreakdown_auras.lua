
local Details = Details
local GameTooltip = GameTooltip
local unpack = unpack
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo

local auras_tab_create = function(tab, frame)
    local DF = DetailsFramework
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

    local line_onenter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        Details:GameTooltipSetSpellByID (self.spellID)
        GameTooltip:Show()
        self:SetBackdropColor(1, 1, 1, .2)
    end

    local line_onleave = function(self)
        GameTooltip:Hide()
        self:SetBackdropColor(unpack(self.BackgroundColor))
    end

    local line_onclick = function(self)

    end

    --buff scroll
    --icon - name - applications - refreshes - uptime
    --

    --local wa_button = function(self, mouseButton, spellID, auraType)
    --	local spellName, _, spellIcon = GetSpellInfo(spellID)
    --	Details:OpenAuraPanel (spellID, spellName, spellIcon, nil, auraType == "BUFF" and 4 or 2, 1)
    --end

    local scroll_createline = function(self, index)
        local line = CreateFrame("button", "$parentLine" .. index, self,"BackdropTemplate")
        line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)))
        line:SetSize(scroll_width -2, scroll_line_height)
        line:SetScript("OnEnter", line_onenter)
        line:SetScript("OnLeave", line_onleave)
        line:SetScript("OnClick", line_onclick)

        line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        line:SetBackdropColor(0, 0, 0, 0.2)

        local icon = line:CreateTexture("$parentIcon", "overlay")
        icon:SetSize(scroll_line_height -2 , scroll_line_height - 2)
        local name = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
        local uptime = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
        local apply = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
        local refresh = line:CreateFontString("$parentName", "overlay", "GameFontNormal")

        --local waButton = DF:CreateButton(line, wa_button, 18, 18)
        --waButton:SetIcon ([[Interface\AddOns\WeakAuras\Media\Textures\icon]])

        DF:SetFontSize(name, text_size)
        DF:SetFontSize(uptime, text_size)
        DF:SetFontSize(apply, text_size)
        DF:SetFontSize(refresh, text_size)

        icon:SetPoint("left", line, "left", 2, 0)
        name:SetPoint("left", icon, "right", 2, 0)
        uptime:SetPoint("left", line, "left", 186, 0)
        apply:SetPoint("left", line, "left", 276, 0)
        refresh:SetPoint("left", line, "left", 322, 0)
        --waButton:SetPoint("left", line, "left", 372, 0)

        line.Icon = icon
        line.Name = name
        line.Uptime = uptime
        line.Apply = apply
        line.Refresh = refresh
        --line.WaButton = waButton

        name:SetJustifyH("left")
        uptime:SetJustifyH("left")

        apply:SetJustifyH("center")
        refresh:SetJustifyH("center")
        apply:SetWidth(26)
        refresh:SetWidth(26)

        return line
    end

    local line_bg_color = {{1, 1, 1, .1}, {1, 1, 1, 0}}

    local scroll_buff_refresh = function(self, data, offset, total_lines)

        local haveWA = false --_G.WeakAuras

        for i = 1, total_lines do
            local index = i + offset
            local aura = data [index]

            if (aura) then
                local line = self:GetLine (i)
                line.spellID = aura.spellID
                line.Icon:SetTexture(aura [1])

                line.Icon:SetTexCoord(.1, .9, .1, .9)

                line.Name:SetText(aura [2])
                line.Uptime:SetText(DF:IntegerToTimer(aura [3]) .. " (|cFFBBAAAA" .. math.floor(aura [6]) .. "%|r)")
                line.Apply:SetText(aura [4])
                line.Refresh:SetText(aura [5])

                --if (haveWA) then
                --	line.WaButton:SetClickFunction(wa_button, aura.spellID, line.AuraType)
                --else
                --	line.WaButton:Disable()
                --end

                if (i%2 == 0) then
                    line:SetBackdropColor(unpack(line_bg_color [1]))
                    line.BackgroundColor = line_bg_color [1]
                else
                    line:SetBackdropColor(unpack(line_bg_color [2]))
                    line.BackgroundColor = line_bg_color [2]
                end
            end
        end
    end

    local create_titledesc_frame = function(anchorWidget, desc)
        local f = CreateFrame("frame", nil, frame)
        f:SetSize(40, 20)
        f:SetPoint("center", anchorWidget, "center")
        f:SetScript("OnEnter", function()
            GameTooltip:SetOwner(f, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(desc)
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        return f
    end



    local buffLabel = DF:CreateLabel(frame, "Buff Name")
    buffLabel:SetPoint(headerOffsetsBuffs[1], -10)
    local uptimeLabel = DF:CreateLabel(frame, "Uptime")
    uptimeLabel:SetPoint(headerOffsetsBuffs[2], -10)

    local appliedLabel = DF:CreateLabel(frame, "A")
    appliedLabel:SetPoint(headerOffsetsBuffs[3], -10)
    create_titledesc_frame (appliedLabel.widget, "applications")

    local refreshedLabel = DF:CreateLabel(frame, "R")
    refreshedLabel:SetPoint(headerOffsetsBuffs[4], -10)
    create_titledesc_frame (refreshedLabel.widget, "refreshes")

    --local waLabel = DF:CreateLabel(frame, "WA")
    --waLabel:SetPoint(headerOffsetsBuffs[5], -10)
    --create_titledesc_frame (waLabel.widget, "create weak aura")

    local buffScroll = DF:CreateScrollBox (frame, "$parentBuffUptimeScroll", scroll_buff_refresh, {}, scroll_width, scrollHeight, scroll_line_amount, scroll_line_height)
    buffScroll:SetPoint("topleft", frame, "topleft", 5, -30)
    for i = 1, scroll_line_amount do
        local line = buffScroll:CreateLine (scroll_createline)
        line.AuraType = "BUFF"
    end
    DF:ReskinSlider(buffScroll)
    tab.BuffScroll = buffScroll

    --debuff scroll
    --icon - name - applications - refreshes - uptime
    --

    local debuffLabel = DF:CreateLabel(frame, "Debuff Name")
    debuffLabel:SetPoint(headerOffsetsDebuffs[1], -10)
    local uptimeLabel2 = DF:CreateLabel(frame, "Uptime")
    uptimeLabel2:SetPoint(headerOffsetsDebuffs[2], -10)

    local appliedLabel2 = DF:CreateLabel(frame, "A")
    appliedLabel2:SetPoint(headerOffsetsDebuffs[3], -10)
    create_titledesc_frame (appliedLabel2.widget, "applications")

    local refreshedLabel2 = DF:CreateLabel(frame, "R")
    refreshedLabel2:SetPoint(headerOffsetsDebuffs[4], -10)
    create_titledesc_frame (refreshedLabel2.widget, "refreshes")

    --local waLabel2 = DF:CreateLabel(frame, "WA")
    --waLabel2:SetPoint(headerOffsetsDebuffs[5], -10)
    --create_titledesc_frame (waLabel2.widget, "create weak aura")

    local debuffScroll = DF:CreateScrollBox (frame, "$parentDebuffUptimeScroll", scroll_buff_refresh, {}, scroll_width, scrollHeight, scroll_line_amount, scroll_line_height)
    debuffScroll:SetPoint("topleft", frame, "topleft", debuffScrollStartX, -30)
    for i = 1, scroll_line_amount do
        local line = debuffScroll:CreateLine (scroll_createline)
        line.AuraType = "DEBUFF"
    end
    DF:ReskinSlider(debuffScroll)

    tab.DebuffScroll = debuffScroll

    if (not frame.__background) then
        DetailsFramework:ApplyStandardBackdrop(frame)
        frame.__background:SetAlpha(0.6)
    end
end

local auras_tab_fill = function(tab, player, combat)
    local miscActor = combat:GetActor(4, player:name())
    local combatTime = combat:GetCombatTime()

    do --buffs
        local newAuraTable = {}
        if (miscActor and miscActor.buff_uptime_spells) then
            for spellID, spellObject in pairs(miscActor.buff_uptime_spells._ActorTable) do
                local spellName, _, spellIcon = GetSpellInfo(spellID)
                if (not spellObject.uptime) then
                    --print(_GetSpellInfo(spellID))
                    --dumpt(spellObject)
                end
                table.insert(newAuraTable, {spellIcon, spellName, spellObject.uptime, spellObject.appliedamt, spellObject.refreshamt, spellObject.uptime/combatTime*100, spellID = spellID})
            end
        end
        table.sort (newAuraTable, Details.Sort3)
        tab.BuffScroll:SetData (newAuraTable)
        tab.BuffScroll:Refresh()
    end

    do --debuffs
        local newAuraTable = {}
        if (miscActor and miscActor.debuff_uptime_spells) then
            for spellID, spellObject in pairs(miscActor.debuff_uptime_spells._ActorTable) do
                local spellName, _, spellIcon = GetSpellInfo(spellID)
                table.insert(newAuraTable, {spellIcon, spellName, spellObject.uptime, spellObject.appliedamt, spellObject.refreshamt, spellObject.uptime/combatTime*100, spellID = spellID})
            end
        end
        table.sort (newAuraTable, Details.Sort3)
        tab.DebuffScroll:SetData (newAuraTable)
        tab.DebuffScroll:Refresh()
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

        auras_tab_fill, --[4] fill function

        nil, --[5] onclick

        auras_tab_create, --[6] oncreate
        iconTableAuras --icon table
    )
end