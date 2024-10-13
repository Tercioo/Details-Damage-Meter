
local addonId, edTable = ...
local Details = _G._detalhes
local AceLocale = LibStub("AceLocale-3.0")
local Loc = AceLocale:GetLocale("Details_EncounterDetails")
local Graphics = LibStub:GetLibrary("LibGraph-2.0")
local ipairs = ipairs
local _GetSpellInfo = Details.getspellinfo
local unpack = unpack

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = CreateFrame
local GameCooltip = GameCooltip
local wipe = table.wipe
local _

--VerticalLines são os indicatores de onde aconteceram mortes, precisa ser renomeados e criar uma classe pra eles
--precisa fazer um indicator genérico na classe df_chart para ser usado como indicador de bloodlust ou qualquer coisa que indica um evento por x tempo

---@class ed_phaseframe : frame
---@field texture texture

local encounterDetails = _G.EncounterDetailsGlobal
local edFrame = encounterDetails.Frame

--an auxiliary table to store things related to df_chartmulti but can't be stored in 'chartPanel'
encounterDetails.chartFrameAux = {}

local CONST_CHART_WIDTH = 921
local CONST_CHART_HEIGHT = 524
local CONST_CHART_LENGTH = 810
local CONST_CHART_TIMELINE_Y_POSITION = -540
local CONST_CHART_MAX_DEATHS_ICONS = 6

local CONST_PHASE_PANEL_WIDTH = 451
local CONST_PHASE_BAR_HEIGHT = 16

local DETAILS_ATTRIBUTE_DAMAGE = 1

local phaseAlpha = 0.5
local lastBoss = nil
local chartLineColors = {{1, 1, 1, 1}, {1, 0.5, 0.3, 1}, {0.75, 0.7, 0.1, 1}, {0.2, 0.9, 0.2, 1}, {0.2, 0.5, 0.9, 1}}
encounterDetails.CombatsAlreadyDrew = {}

---create a multi chart frame
---@return df_chartmulti
local createMultiChartFrame = function()
    ---@type df_chartmulti
    local chartPanel = detailsFramework:CreateGraphicMultiLineFrame(edFrame, "EncounterDetailsChartPanel")
    chartPanel.xAxisLabelsYOffset = -9
    chartPanel:CreateAxesLines(48, 28, "left", 1, 10, 10, 1, 1, 1, 1)
    chartPanel:SetXAxisDataType("time")
    chartPanel:SetSize(CONST_CHART_WIDTH, CONST_CHART_HEIGHT)
    chartPanel:SetPoint("topleft", encounterDetails.Frame, "topleft", 2, -76)
    chartPanel:SetLineThickness(3)
    encounterDetails.chartPanel = chartPanel

    detailsFramework:ApplyStandardBackdrop(chartPanel)

    ---@type ed_phaseframe[]
    encounterDetails.chartFrameAux.PhaseFrames = {}
    encounterDetails.chartFrameAux.VerticalLines = {}

    local phaseTooltip = encounterDetails:CreatePhaseTooltip(chartPanel)
    encounterDetails:CreatePhaseIndicators(chartPanel, phaseTooltip)

    detailsFramework:NewLabel(chartPanel, chartPanel, nil, "phases_string", "phases:", "GameFontHighlightSmall")
    chartPanel["phases_string"]:SetPoint("bottomleft", chartPanel, "bottomleft", 5, 10)

    chartPanel:SetScript("OnShow", function()
        chartPanel["phases_string"]:Show()
    end)

    chartPanel:SetScript("OnHide", function()
        chartPanel["phases_string"]:Hide()
    end)

    return chartPanel
end

function encounterDetails:ShowChartFrame()
    local segment = encounterDetails._segment
    if (not segment) then
        return
    end

    ---@type df_chartmulti
    local multiChartPanel = encounterDetails.chartPanel

    if (not multiChartPanel) then
        ---@type df_chartmulti
        multiChartPanel = createMultiChartFrame()
    end
    multiChartPanel:Reset()

    ---@type combat
    local combatObject = encounterDetails:GetCombat(segment)
    --elapsed combat time
    if (combatObject:GetCombatTime() < 12) then
        return
    end

    local uniqueCombatId = combatObject:GetCombatUID()
    local chartData = EncounterDetailsDB.chartData[uniqueCombatId]
    local currentChartData = chartData and chartData["Raid Damage Done"]

    if (not currentChartData or not combatObject.start_time or not combatObject.end_time) then
        encounterDetails:Msg("This segment doesn't have chart data.")
        return

    elseif (currentChartData.max_value and currentChartData.max_value == 0) then
        return
    end

    encounterDetails.Frame.linhas = 1 --can't find references to this variable
    if (encounterDetails.Frame.linhas > 5) then
        encounterDetails.Frame.linhas = 1
    end

    for _, line in ipairs(encounterDetails.chartFrameAux.VerticalLines) do
        line:Hide()
    end

    local encounterId = combatObject.is_boss and combatObject.is_boss.id
    local chartIndex = 2
    local smoothnessLevel = 3

    ---draw the damage line from the 5th combat to 2nd combat
    for i = segment + 4, segment + 1, -1 do
        ---@type combat
        local thisCombatObject = encounterDetails:GetCombat(i)
        if (thisCombatObject) then
            local elapsedTime = thisCombatObject:GetCombatTime()
            if (elapsedTime > 12 and thisCombatObject.is_boss and thisCombatObject.is_boss.id == encounterId) then --is the same boss
                local thisUniqueCombatId = thisCombatObject:GetCombatUID()
                local thisChartData = EncounterDetailsDB.chartData[thisUniqueCombatId] and EncounterDetailsDB.chartData[thisUniqueCombatId]["Raid Damage Done"]

                --check if this is a valid chart data
                if (thisChartData and thisChartData.max_value and thisChartData.max_value > 0) then
                    local tryNumber = thisCombatObject.is_boss.try_number or i
                    multiChartPanel:AddData(thisChartData, nil, smoothnessLevel, "Try #" .. tryNumber, chartLineColors[chartIndex])
                    multiChartPanel:SetXAxisData(elapsedTime)
                    chartIndex = chartIndex + 1
                end
            end
        end
    end

    ---@type number[]
    local bloodLustTimers = combatObject.bloodlust or {}

    for index, bloodlustCombatTime in ipairs(bloodLustTimers) do
        multiChartPanel:AddBackdropIndicator("Bloodlust #" .. index, bloodlustCombatTime, bloodlustCombatTime + 40, {0, 0, 1, 0.2})
    end

    encounterDetails:UpdatePhaseIndicators(multiChartPanel, combatObject)

    multiChartPanel:AddData(currentChartData, nil, smoothnessLevel, "current", chartLineColors[1])
    multiChartPanel:SetXAxisData(combatObject:GetCombatTime())
    multiChartPanel:Plot()
    multiChartPanel:Show()
end


function encounterDetails:UpdatePhaseIndicators(chartPanel, combatObject)
    encounterDetails:ClearPhaseIndicators()

    --update phase indicators
    local phaseData = combatObject.PhaseData
    local plotFrameWidth = chartPanel.plotFrame:GetWidth()
    local scale = (plotFrameWidth) / combatObject:GetCombatTime()

    for i = 1, #phaseData do
        local phase = phaseData[i][1]
        local phaseStartAt = phaseData[i][2]
        local phaseIndicator = encounterDetails:GetPhaseIndicator(i, phase)

        if (phaseStartAt == 1) then
            phaseStartAt = 0
        end

        phaseIndicator:SetPoint("topleft", chartPanel.plotFrame, "bottomleft", (phaseStartAt * scale), -6)
        phaseIndicator.phase = phase
        phaseIndicator.start_at = phaseStartAt

        local nextPhase = phaseData[i+1]
        if (nextPhase) then
            local duration = nextPhase[2] - phaseStartAt
            phaseIndicator:SetWidth(scale * duration)
            phaseIndicator.elapsed = duration
        else
            local duration = combatObject:GetCombatTime() - phaseStartAt
            phaseIndicator:SetWidth(scale * duration)
            phaseIndicator.elapsed = duration
        end
    end
end

---tooltip frame on hovering over
---@param chartPanel df_chartmulti
---@return frame
function encounterDetails:CreatePhaseTooltip(chartPanel)
    ---@type frame
    local phaseTooltip = CreateFrame("frame", "EncounterDetailsPhasePanel", chartPanel, "BackdropTemplate")
    phaseTooltip:SetFrameStrata("TOOLTIP")
    phaseTooltip:SetFrameLevel(1000)
    phaseTooltip:SetWidth(450)
    detailsFramework:ApplyStandardBackdrop(phaseTooltip)

    local damageTexture = detailsFramework:CreateImage(phaseTooltip,[[Interface\AddOns\Details\images\skins\classic_skin_v1]], 16, 16, "overlay", {11/1024, 24/1024, 376/1024, 390/1024})
    local damageLabel = detailsFramework:CreateLabel(phaseTooltip, "Damage Done:")
    damageTexture:SetPoint("topleft", phaseTooltip, "topleft", 10, -10)
    damageLabel:SetPoint("left", damageTexture, "right", 4, 0)

    local healingTexture = detailsFramework:CreateImage(phaseTooltip,[[Interface\AddOns\Details\images\skins\classic_skin_v1]], 16, 16, "overlay", {43/1024, 57/1024, 376/1024, 390/1024})
    local healingLabel = detailsFramework:CreateLabel(phaseTooltip, "Healing Done:")
    healingTexture:SetPoint("topleft", phaseTooltip, "topleft", 250, -10)
    healingLabel:SetPoint("left", healingTexture, "right", 4, 0)

    phaseTooltip.phase_label = detailsFramework:CreateLabel(phaseTooltip, "")
    phaseTooltip.phase_label.fontsize = 10
    phaseTooltip.time_label = detailsFramework:CreateLabel(phaseTooltip, "")
    phaseTooltip.time_label.fontsize = 10
    phaseTooltip.report_label = detailsFramework:CreateLabel(phaseTooltip, "|cFFffb400Left Click|r: Report Damage |cFFffb400Right Click|r: Report Heal")
    phaseTooltip.report_label.fontsize = 10

    phaseTooltip.phase_label:SetPoint("bottomleft", phaseTooltip, "bottomleft", 10, 5)
    phaseTooltip.time_label:SetPoint("left", phaseTooltip.phase_label, "right", 5, 0)
    phaseTooltip.report_label:SetPoint("bottomright", phaseTooltip, "bottomright", -10, 5)

    local phaseFrameBackgroundTexture = detailsFramework:CreateImage(phaseTooltip,[[Interface\Tooltips\UI-Tooltip-Background]], nil, nil, "artwork")
    phaseFrameBackgroundTexture:SetPoint("left", phaseTooltip.phase_label, "left")
    phaseFrameBackgroundTexture.height = 16
    phaseFrameBackgroundTexture:SetPoint("right", phaseTooltip.report_label, "right")
    phaseFrameBackgroundTexture:SetVertexColor(0, 0, 0, 1)

    phaseTooltip.damage_labels = {}
    phaseTooltip.heal_labels = {}

    function phaseTooltip:ClearLabels()
        for i, tooltipBar in ipairs(phaseTooltip.damage_labels) do
            tooltipBar:Hide()
        end
        for i, tooltipBar in ipairs(phaseTooltip.heal_labels) do
            tooltipBar:Hide()
        end
    end

    local createTooltipBar = function(index, xOffset)
        ---@type statusbar
        local newtooltipBar = CreateFrame("statusbar", nil, phaseTooltip, "BackdropTemplate")
        newtooltipBar:SetSize(200, 16)
        newtooltipBar:SetFrameLevel(phaseTooltip:GetFrameLevel() + 50 - index)
        newtooltipBar:SetMinMaxValues(0, 1)
        newtooltipBar:SetPoint("topleft", phaseTooltip, "topleft", 5 + xOffset, ((index * 16) * -1) - 30)

        local playerName = detailsFramework:CreateLabel(newtooltipBar, "", 11, "white", nil, nil, nil, "overlay")

        local amountLabel = detailsFramework:CreateLabel(newtooltipBar, "", 11, nil, nil, nil, nil, "overlay")
        amountLabel:SetJustifyH("right")

        local iconTexture = detailsFramework:CreateImage(newtooltipBar, "", 16, 16, "overlay")

        local backgroundTexture = detailsFramework:CreateImage(newtooltipBar, [[Interface\AddOns\Details\images\bar_serenity]], nil, nil, "border")
        backgroundTexture.height = 16
        backgroundTexture:SetVertexColor(.1, .1, .1, 0.834)

        local statusBarTexture = newtooltipBar:CreateTexture(nil, "artwork")
        statusBarTexture:SetTexture([[Interface\AddOns\Details\images\bar_serenity]])
        statusBarTexture:SetVertexColor(.3, .3, .3, 1)
        statusBarTexture:SetAllPoints()
        newtooltipBar:SetStatusBarTexture(statusBarTexture)

        backgroundTexture:SetAllPoints()
        iconTexture:SetPoint("left", newtooltipBar, "left", 0, 0)
        playerName:SetPoint("left", iconTexture, "right", 2, 0)
        amountLabel:SetPoint("right", newtooltipBar, "right", -2, 0)

        newtooltipBar.lefttext = playerName
        newtooltipBar.righttext = amountLabel
        newtooltipBar.icon = iconTexture
        newtooltipBar.bg = backgroundTexture
        newtooltipBar.statusBarTexture = statusBarTexture

        return newtooltipBar
    end

    function phaseTooltip:GetTooltipBar(index, barType)
        local thisBar

        if (barType == "damage") then
            thisBar = phaseTooltip.damage_labels[index]
            if (not thisBar) then
                thisBar = createTooltipBar(index, 0)
                phaseTooltip.damage_labels[index] = thisBar
            end

        elseif (barType == "healing") then
            thisBar = phaseTooltip.heal_labels[index]
            if (not thisBar) then
                thisBar = createTooltipBar(index, 235)
                phaseTooltip.heal_labels[index] = thisBar
            end
        end

        thisBar:Show()
        return thisBar
    end

    return phaseTooltip
end

---phase indicators below the x axis
---@param chartPanel df_chartmulti
function encounterDetails:CreatePhaseIndicators(chartPanel, phaseTooltip)
    local sparkContainer = {}
    local phaseColors = {{0.2, 1, 0.2, phaseAlpha}, {1, 1, 0.2, phaseAlpha}, {1, 0.2, 0.2, phaseAlpha}, {0.2, 1, 1, phaseAlpha}, {0.2, 0.2, 1, phaseAlpha},
    [1.5] = {0.25, 0.95, 0.25, phaseAlpha},[2.5] = {0.95, 0.95, 0.25, phaseAlpha},[3.5] = {0.95, 0.25, 0.25, phaseAlpha}
    }

    local createSpark = function()
        local newSpark = phaseTooltip:CreateTexture(nil, "overlay")
        newSpark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
        newSpark:SetBlendMode("ADD")
        newSpark:Hide()
        table.insert(sparkContainer, newSpark)
    end

    local getSpark = function(index)
        local spark = sparkContainer[index]
        if (not spark) then
            createSpark()
            spark = sparkContainer[index]
        end
        spark:ClearAllPoints()
        return spark
    end

    local hideSparks = function()
        for _, spark in ipairs(sparkContainer) do
            spark:Hide()
        end
    end

    local onClickPhase = function(self, button)
        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)

        if (button == "LeftButton") then
            local result = {}
            local reportFunc = function(IsCurrent, IsReverse, AmtLines)
                AmtLines = AmtLines + 1
                if (#result > AmtLines) then
                    for i = #result, AmtLines+1, -1 do
                        table.remove(result, i)
                    end
                end
                encounterDetails:SendReportLines(result)
            end

            --need to build here because the mouse will leave the block to click in the send button
            table.insert(result, "Details!: Damage for Phase " .. self.phase .. " of " .. (combatObject and combatObject.is_boss and combatObject.is_boss.name or "Unknown") .. ":")
            for i = 1, #self.damage_actors do
                table.insert(result, encounterDetails:GetOnlyName(self.damage_actors[i][1]) .. ": " .. Details:ToK(math.floor(self.damage_actors[i][2])))
            end
            encounterDetails:SendReportWindow(reportFunc, nil, nil, true)

        elseif (button == "RightButton") then
            local result = {}
            local reportFunc = function(IsCurrent, IsReverse, AmtLines)
                AmtLines = AmtLines + 1
                if (#result > AmtLines) then
                    for i = #result, AmtLines+1, -1 do
                        table.remove(result, i)
                    end
                end
                encounterDetails:SendReportLines(result)
            end

            table.insert(result, "Details!: Healing for Phase " .. self.phase .. " of " ..(combatObject and combatObject.is_boss and combatObject.is_boss.name or "Unknown") .. ":")
            for i = 1, #self.heal_actors do
                table.insert(result, encounterDetails:GetOnlyName(self.heal_actors[i][1]) .. ": " .. Details:ToK(math.floor(self.heal_actors[i][2])))
            end
            encounterDetails:SendReportWindow(reportFunc, nil, nil, true)
        end
    end

    local onEnterPhase = function(self)
        local leftSpark = getSpark(1)
        local rightSpark = getSpark(2)
        leftSpark:SetPoint("left", self.texture, "left", -16, 0)
        rightSpark:SetPoint("right", self.texture, "right", 16, 0)
        leftSpark:Show()
        rightSpark:Show()
        self.texture:SetBlendMode("ADD")

        local phase = self.phase
        local sparkIndex = 3

        self.texture:SetVertexColor(1, 1, 1)

        for _, thisPhaseFrame in ipairs(encounterDetails.chartFrameAux.PhaseFrames) do
            if (thisPhaseFrame ~= self and thisPhaseFrame.phase == phase) then
                local thisPhaseLeftSpark = getSpark(sparkIndex)
                local thisPhaseRightSpark = getSpark(sparkIndex+1)
                thisPhaseLeftSpark:SetPoint("left", thisPhaseFrame.texture, "left", -16, 0)
                thisPhaseRightSpark:SetPoint("right", thisPhaseFrame.texture, "right", 16, 0)
                thisPhaseLeftSpark:Show()
                thisPhaseRightSpark:Show()
                thisPhaseFrame.texture:SetBlendMode("ADD")
                thisPhaseFrame.texture:SetVertexColor(1, 1, 1)
                sparkIndex = sparkIndex + 2
            end
        end

        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)

        if (combatObject) then
            phaseTooltip:ClearLabels()

            --damage
            ---@type table<number, table<string, number>>
            local listOfPlayers = {}
            for playerName, damageDone in pairs(combatObject.PhaseData.damage[self.phase]) do
                table.insert(listOfPlayers, {playerName, damageDone})
            end
            table.sort(listOfPlayers, Details.Sort2)
            local topDamage = listOfPlayers[1] and listOfPlayers[1][2]

            for index, playerTable in ipairs(listOfPlayers) do
                local playerName = playerTable[1]
                local damageDone = playerTable[2]

                local tooltipBar = phaseTooltip:GetTooltipBar(index, "damage")
                tooltipBar:SetValue(damageDone / topDamage)

                tooltipBar.lefttext.text = encounterDetails:GetOnlyName(playerName)
                tooltipBar.righttext.text = Details:ToK(math.floor(damageDone))

                ---@type actor
                local actor = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, playerName)

                local class = encounterDetails:GetClass(playerName)
                local spec = encounterDetails:GetSpec(playerName) or actor and actor.spec

                --get the class color for the actor
                local red, green, blue = Details:GetClassColor(class)
                tooltipBar:SetStatusBarColor(red, green, blue)

                if (spec) then
                    tooltipBar.icon.texture = [[Interface\AddOns\Details\images\spec_icons_normal]]
                    tooltipBar.icon.texcoord = encounterDetails.class_specs_coords[spec]

                elseif (class) then
                    tooltipBar.icon.texture = [[Interface\AddOns\Details\images\classes_small_alpha]]
                    tooltipBar.icon.texcoord = Details.class_coords[class]

                else
                    tooltipBar.icon.texture = [[Interface\LFGFRAME\LFGROLE_BW]]
                    tooltipBar.icon:SetTexCoord(.25, .5, 0, 1)
                end

                tooltipBar:Show()
            end

            local damage_players = #listOfPlayers
            self.damage_actors = listOfPlayers

            --healing
            ---@type table<number, table<string, number>>
            local listOfPlayersHeal = {}
            for playerName, heal in pairs(combatObject.PhaseData.heal[self.phase]) do
                table.insert(listOfPlayersHeal, {playerName, heal})
            end
            table.sort(listOfPlayersHeal, Details.Sort2)
            local topHealing = listOfPlayersHeal[1] and listOfPlayersHeal[1][2]

            for index, playerTable in ipairs(listOfPlayersHeal) do
                local playerName = playerTable[1]
                local healingDone = playerTable[2]

                local tooltipBar = phaseTooltip:GetTooltipBar(index, "healing")
                tooltipBar:SetValue(healingDone / topHealing)

                tooltipBar.lefttext.text = encounterDetails:GetOnlyName(playerName)
                tooltipBar.righttext.text = Details:ToK(math.floor(healingDone))

                ---@type actor
                local actor = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, playerName)

                local class = encounterDetails:GetClass(playerName)
                local spec = encounterDetails:GetSpec(playerName) or actor and actor.spec

                --get the class color for the actor
                local red, green, blue = Details:GetClassColor(class)
                tooltipBar:SetStatusBarColor(red, green, blue)

                if (spec) then
                    tooltipBar.icon.texture = [[Interface\AddOns\Details\images\spec_icons_normal]]
                    tooltipBar.icon.texcoord = encounterDetails.class_specs_coords[spec]

                elseif (class) then
                    tooltipBar.icon:SetTexture([[Interface\AddOns\Details\images\classes_small_alpha]])
                    tooltipBar.icon:SetTexCoord(unpack(Details.class_coords[class]))

                else
                    tooltipBar.icon:SetTexture([[Interface\LFGFRAME\LFGROLE_BW]])
                    tooltipBar.icon:SetTexCoord(.25, .5, 0, 1)
                end

                tooltipBar:Show()
            end

            local heal_players = #listOfPlayersHeal
            self.heal_actors = listOfPlayersHeal

            --show the panel
            phaseTooltip:SetHeight((math.max(damage_players, heal_players) * 16) + 60)
            phaseTooltip:SetPoint("bottom", self, "top", 0, 10)
            phaseTooltip:Show()

            phaseTooltip.phase_label.text = "|cFFffb400Phase|r: " .. self.phase

            local m, s = math.floor(self.elapsed / 60), math.floor(self.elapsed % 60)
            phaseTooltip.time_label.text = "|cFFffb400Elapsed|r: " .. m .. "m " .. s .. "s"
        end
    end

    local onLeavePhase = function(self)
        wipe(self.damage_actors)
        wipe(self.heal_actors)

        for _, phaseTextureFrame in ipairs(encounterDetails.chartFrameAux.PhaseFrames) do
            phaseTextureFrame.texture:SetBlendMode("BLEND")
            phaseTextureFrame.texture:SetVertexColor(unpack(phaseTextureFrame.texture.original_color))
        end

        hideSparks()
        phaseTooltip:Hide()
    end

    function encounterDetails:GetPhaseIndicator(index, phase)
        local phaseIndicatorFrame = encounterDetails.chartFrameAux.PhaseFrames[index]

        if (not phaseIndicatorFrame) then
            ---@type ed_phaseframe
            phaseIndicatorFrame = CreateFrame("frame", "EncounterDetailsPhaseTexture" .. index, chartPanel, "BackdropTemplate")
            phaseIndicatorFrame:SetHeight(CONST_PHASE_BAR_HEIGHT)

            local phaseTexture = phaseIndicatorFrame:CreateTexture(nil, "artwork")
            phaseTexture:SetAllPoints()
            phaseTexture:SetColorTexture(1, 1, 1, phaseAlpha)
            phaseTexture.original_color = {1, 1, 1}
            phaseIndicatorFrame.texture = phaseTexture

            phaseIndicatorFrame:SetScript("OnEnter", onEnterPhase)
            phaseIndicatorFrame:SetScript("OnLeave", onLeavePhase)
            phaseIndicatorFrame:SetScript("OnMouseUp", onClickPhase)

            phaseIndicatorFrame = phaseIndicatorFrame
            table.insert(encounterDetails.chartFrameAux.PhaseFrames, phaseIndicatorFrame)
        end

        phaseIndicatorFrame:ClearAllPoints()

        phase = math.min(phase, 5)
        if (not phaseColors[phase]) then
            Details:Msg("Phase out of range:", phase)
            phase = math.max(phase, 1)
        end

        local phaseColor = phaseColors[phase]
        if (not phaseColor) then
            phaseColor = {1, 1, 1}
        end

        phaseIndicatorFrame.texture:SetVertexColor(unpack(phaseColor))
        local originalColor = phaseIndicatorFrame.texture.original_color
        originalColor[1], originalColor[2], originalColor[3] = unpack(phaseColors[phase])

        phaseIndicatorFrame:Show()

        return phaseIndicatorFrame
    end

    function encounterDetails:ClearPhaseIndicators()
        for i, texture in pairs(encounterDetails.chartFrameAux.PhaseFrames) do
            texture:Hide()
        end
    end
end

---not in use at the moment
---@param self any
---@param chartPanel df_chart
---@param detailsGraphicData any
---@param combatObject combat
---@param drawDeathsCombat combat
function encounterDetails:DrawSegmentGraphic(chartPanel, detailsGraphicData, combatObject, drawDeathsCombat)

    --> add death icons for the first deaths in the segment
    if (drawDeathsCombat) then
        local mortes = drawDeathsCombat.last_events_tables
        local scaleG = CONST_CHART_LENGTH / drawDeathsCombat:GetCombatTime()

        for _, row in ipairs(encounterDetails.chartFrameAux.VerticalLines) do
            row:Hide()
        end

        for i = 1, math.min(CONST_CHART_MAX_DEATHS_ICONS, #mortes) do

            local vRowFrame = encounterDetails.chartFrameAux.VerticalLines[i]

            if (not vRowFrame) then
                vRowFrame = CreateFrame("frame", "DetailsEncountersVerticalLine"..i, chartPanel, "BackdropTemplate")
                vRowFrame:SetWidth(20)
                vRowFrame:SetHeight(43)
                vRowFrame:SetFrameLevel(chartPanel:GetFrameLevel()+2)

                vRowFrame:SetScript("OnEnter", function(frame)
                    if (vRowFrame.dead[1] and vRowFrame.dead[1][3] and vRowFrame.dead[1][3][2]) then
                        GameCooltip:Reset()

                        --time of death and player name
                        GameCooltip:AddLine(vRowFrame.dead[6].." "..vRowFrame.dead[3])
                        local class, l, r, t, b = Details:GetClass(vRowFrame.dead[3])
                        if (class) then
                            GameCooltip:AddIcon([[Interface\AddOns\Details\images\classes_small]], 1, 1, 12, 12, l, r, t, b)
                        end
                        GameCooltip:AddLine("")

                        --last hits:
                        local death = vRowFrame.dead
                        local amt = 0
                        for i = #death[1], 1, -1 do
                            local this_hit = death[1][i]
                            if (type(this_hit[1]) == "boolean" and this_hit[1]) then
                                local spellname, _, spellicon = _GetSpellInfo(this_hit[2])
                                local t = death[2] - this_hit[4]
                                GameCooltip:AddLine("-" .. string.format("%.1f", t) .. " " .. spellname .. "(" .. this_hit[6] .. ")", encounterDetails:comma_value(this_hit[3]))
                                GameCooltip:AddIcon(spellicon, 1, 1, 12, 12, 0.1, 0.9, 0.1, 0.9)
                                amt = amt + 1
                                if (amt == 3) then
                                    break
                                end
                            end
                        end

                        GameCooltip:SetOption("TextSize", 9.5)
                        GameCooltip:SetOption("HeightAnchorMod", -15)

                        GameCooltip:SetWallpaper(1,[[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
                        GameCooltip:ShowCooltip(frame, "tooltip")
                    end
                end)

                vRowFrame:SetScript("OnLeave", function(frame)
                    Details.popup:ShowMe(false)
                end)

                vRowFrame.texture = vRowFrame:CreateTexture(nil, "overlay")
                vRowFrame.texture:SetTexture("Interface\\AddOns\\Details\\images\\verticalline")
                vRowFrame.texture:SetWidth(3)
                vRowFrame.texture:SetHeight(20)
                vRowFrame.texture:SetPoint("center", "DetailsEncountersVerticalLine"..i, "center")
                vRowFrame.texture:SetPoint("bottom", "DetailsEncountersVerticalLine"..i, "bottom", 0, 0)
                vRowFrame.texture:SetVertexColor(1, 1, 1, .5)

                vRowFrame.icon = vRowFrame:CreateTexture(nil, "overlay")
                vRowFrame.icon:SetTexture("Interface\\WorldStateFrame\\SkullBones")
                vRowFrame.icon:SetTexCoord(0.046875, 0.453125, 0.046875, 0.46875)
                vRowFrame.icon:SetWidth(16)
                vRowFrame.icon:SetHeight(16)
                vRowFrame.icon:SetPoint("center", "DetailsEncountersVerticalLine"..i, "center")
                vRowFrame.icon:SetPoint("bottom", "DetailsEncountersVerticalLine"..i, "bottom", 0, 20)

                encounterDetails.chartFrameAux.VerticalLines[i] = vRowFrame
            end

            local deadTime = mortes[i].dead_at
            vRowFrame:SetPoint("topleft", encounterDetails.Frame, "topleft",(deadTime*scaleG)+70, -CONST_CHART_HEIGHT-22)
            vRowFrame.dead = mortes[i]
            vRowFrame:Show()

        end
    end
end


function encounterDetails:CreateGraphPanel() --not in use
    --bloodlust indicators
    chartPanel.bloodlustIndicators = {}
    for i = 1, 5 do
        local bloodlustTexture = chartPanel:CreateTexture(nil, "overlay")
        bloodlustTexture:SetColorTexture(0, 1, 0, 0,6)
        chartPanel.bloodlustIndicators[#chartPanel.bloodlustIndicators+1] = bloodlustTexture
    end
end
