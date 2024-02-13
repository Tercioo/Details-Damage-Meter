
--old small window for the end of mythic plus runs

if (false and Details222.MythicPlus.Level and Details222.MythicPlus.Level < 28 and not Details.user_is_patreon_supporter) then
    --create the panel
    if (not mythicDungeonFrames.ReadyFrame) then
        mythicDungeonFrames.ReadyFrame = CreateFrame("frame", "DetailsMythicDungeonReadyFrame", UIParent, "BackdropTemplate")
        local readyFrame = mythicDungeonFrames.ReadyFrame

        local textColor = {1, 0.8196, 0, 1}
        local textSize = 11

        local roundedCornerTemplate = {
            roundness = 6,
            color = {.1, .1, .1, 0.98},
            border_color = {.05, .05, .05, 0.834},
        }

        detailsFramework:AddRoundedCornersToFrame(readyFrame, roundedCornerTemplate)

        local titleLabel = DetailsFramework:CreateLabel(readyFrame, "Details! Mythic Run Completed!", 12, "yellow")
        titleLabel:SetPoint("top", readyFrame, "top", 0, -7)
        titleLabel.textcolor = textColor

        local closeButton = detailsFramework:CreateCloseButton(readyFrame, "$parentCloseButton")
        closeButton:SetPoint("topright", readyFrame, "topright", -2, -2)
        closeButton:SetScale(1.4)
        closeButton:SetAlpha(0.823)

        readyFrame:SetSize(255, 120)
        readyFrame:SetPoint("center", UIParent, "center", 300, 0)
        readyFrame:SetFrameStrata("LOW")
        readyFrame:EnableMouse(true)
        readyFrame:SetMovable(true)
        --DetailsFramework:ApplyStandardBackdrop(readyFrame)
        --DetailsFramework:CreateTitleBar (readyFrame, "Details! Mythic Run Completed!")

        readyFrame:Hide()

        --register to libwindow
        local LibWindow = LibStub("LibWindow-1.1")
        LibWindow.RegisterConfig(readyFrame, Details.mythic_plus.finished_run_frame)
        LibWindow.RestorePosition(readyFrame)
        LibWindow.MakeDraggable(readyFrame)
        LibWindow.SavePosition(readyFrame)

        --show button
        ---@type df_button
        readyFrame.ShowChartButton = DetailsFramework:CreateButton(readyFrame, function() mythicDungeonCharts.ShowChart(); readyFrame:Hide() end, 80, 20, "Show Damage Graphic")
        readyFrame.ShowChartButton:SetTemplate(DetailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
        readyFrame.ShowChartButton:SetPoint("topleft", readyFrame, "topleft", 5, -30)
        readyFrame.ShowChartButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 16, 16, "overlay", {42/512, 75/512, 153/512, 187/512}, {.7, .7, .7, 1}, nil, 0, 0)
        readyFrame.ShowChartButton.textcolor = textColor

        --disable feature check box (dont show this again)
        local on_switch_enable = function(self, _, value)
            Details.mythic_plus.show_damage_graphic = not value
        end

        local notAgainSwitch, notAgainLabel = DetailsFramework:CreateSwitch(readyFrame, on_switch_enable, not Details.mythic_plus.show_damage_graphic, _, _, _, _, _, _, _, _, _, Loc ["STRING_MINITUTORIAL_BOOKMARK4"], DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"), "GameFontHighlightLeft")
        notAgainSwitch:ClearAllPoints()
        notAgainLabel:SetPoint("left", notAgainSwitch, "right", 2, 0)
        notAgainSwitch:SetPoint("bottomleft", readyFrame, "bottomleft", 5, 5)
        notAgainSwitch:SetAsCheckBox()
        notAgainLabel.textSize = textSize

        local timeNotInCombatLabel = DetailsFramework:CreateLabel(readyFrame, "Time not in combat:", textSize, "orangered")
        timeNotInCombatLabel:SetPoint("bottomleft", notAgainSwitch, "topleft", 0, 7)
        local timeNotInCombatAmount = DetailsFramework:CreateLabel(readyFrame, "00:00", textSize, "orangered")
        timeNotInCombatAmount:SetPoint("left", timeNotInCombatLabel, "left", 130, 0)

        local elapsedTimeLabel = DetailsFramework:CreateLabel(readyFrame, "Run Time:", textSize, textColor)
        elapsedTimeLabel:SetPoint("bottomleft", timeNotInCombatLabel, "topleft", 0, 5)
        local elapsedTimeAmount = DetailsFramework:CreateLabel(readyFrame, "00:00", textSize, textColor)
        elapsedTimeAmount:SetPoint("left", elapsedTimeLabel, "left", 130, 0)

        readyFrame.TimeNotInCombatAmountLabel = timeNotInCombatAmount
        readyFrame.ElapsedTimeAmountLabel = elapsedTimeAmount
    end

    mythicDungeonFrames.ReadyFrame:Show()

    --update the run time and time not in combat
    local elapsedTime = Details222.MythicPlus.time or 1507
    mythicDungeonFrames.ReadyFrame.ElapsedTimeAmountLabel.text = DetailsFramework:IntegerToTimer(elapsedTime)

    local overallMythicDungeonCombat = Details:GetCurrentCombat()
    if (overallMythicDungeonCombat:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
        local combatTime = overallMythicDungeonCombat:GetCombatTime()
        local notInCombat = elapsedTime - combatTime
        mythicDungeonFrames.ReadyFrame.TimeNotInCombatAmountLabel.text = DetailsFramework:IntegerToTimer(notInCombat) .. " (" .. math.floor(notInCombat / elapsedTime * 100) .. "%)"
    end

    return
end