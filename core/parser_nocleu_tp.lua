
---@type details
local Details = Details
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@type bparser
local bParser = Details222.BParser

---@class details : table
---@field tooltip table

---@class detailstooltip : button
---@field maxAmount number
---@field ScrollBox df_scrollbox
---@field Background texture
---@field Background2 texture
---@field SetMaxAmount fun(self:detailstooltip, maxAmount:number)

--tooltip settings
local tooltipAmountOfLines = 20
local tooltipEmptyLineHeight = 5
local tooltipLineHeight = 20
local tooltipFontStringPadding = 6 --space between each font string horizontally
local tooltipPadding = 1 --space between each line
local cantStartUpdater = false
local updaterTicker = nil
local amountOfTargetLines = 3

local MAX_TOOLTIP_HELP = 30

---@return detailstooltip
local getTooltipFrame = function() --~tooltip
    local tooltip = _G["DetailsDLC12TooltipFrame"]
    if tooltip then
        return tooltip
    end

    ---@cast tooltip detailstooltip

    tooltip = CreateFrame("frame", "DetailsDLC12TooltipFrame", UIParent)
    tooltip:Hide()
    tooltip:EnableMouse(true)
    tooltip:SetFrameStrata("TOOLTIP")

    tooltip:SetScript("OnLeave", function(self)
        self:Hide()
    end)

    tooltip:SetScript("OnShow", function()
        if DetailsMidnightSegmentSelectionFrame and DetailsMidnightSegmentSelectionFrame:IsShown() then
            DetailsMidnightSegmentSelectionFrame:Hide()
        end
    end)

    tooltip.Background = tooltip:CreateTexture("$parentBackground", "background", nil, -4)
    tooltip.Background:SetColorTexture(.8, .8, .8, 1)
    tooltip.Background:SetAllPoints()

    tooltip.Background2 = tooltip:CreateTexture("$parentBackground2", "background", nil, -5)
    tooltip.Background2:SetColorTexture(0, 0, 0, 0.7)
    tooltip.Background2:SetAllPoints()


    function tooltip:SetMaxAmount(maxAmount)
        self.maxAmount = maxAmount
    end

    tooltip:SetHeight(50)

    ---formats one tooltip line as a header row
    ---@param line detailstooltipline
    ---@param headerData table
    ---@param iconTexture string?
    ---@param iconCoords table?
    local formatLineAsHeader = function(line, headerData, iconTexture, iconCoords)
        --clear font strings
        for j = 1, 6 do
            local fontString = line.dataFontStrings[j]
            fontString:SetText("")
        end

        line:SetHeight(tooltipLineHeight)
        line.SpellName:SetText(headerData[1] or "")
        line.StatusBar:SetPoint("left", line, "left", 0, 0)
        line.StatusBar:SetSize(tooltip:GetWidth()-4, tooltipLineHeight)
        line.StatusBar:SetMinMaxValues(0, 1)
        line.StatusBar:SetValue(0)
        line.SpellIcon:ClearAllPoints()
        line.SpellIcon:SetPoint("left", line, "left", 2, 0)
        line.SpellIcon:SetTexture(iconTexture or [[Interface\WORLDSTATEFRAME\CombatSwords]])
        line.SpellIcon:SetTexCoord(unpack(iconCoords or {0, 1, 0, 1}))

        local fontStringIndex = 1
        for j = #headerData, 2, -1 do
            --all headers are always passed, but data might be missing for some of them, so we check if there is data to show for each header column
            if headerData[j] and headerData[j] ~= "" then
                --if there is data for this header column, show it, otherwise leave it blank
                local fontString = line.dataFontStrings[fontStringIndex]
                fontString:SetText(headerData[j])
                fontStringIndex = fontStringIndex + 1
            end
        end
    end

    --refresh the scroll box lines
    ---@param self df_scrollbox
    ---@param data table an indexed table with subtables holding the data necessary to refresh each line
    ---@param offset number used to know which line to start showing
    ---@param totalLines number of lines shown in the scroll box
    local refreshFunc = function(self, data, offset, totalLines) --~refresh
		local showHeader = Details.tooltip.show_header
		local showHelp = Details.tooltip.show_help

        local loopStart = 1

        local nextLine = loopStart
        for i = loopStart, totalLines do
            local index = i - loopStart + 1 + offset
            local thisData = data[index]
            if (thisData) then
                local line = self:GetLine(i)
                ---@cast line detailstooltipline
                --update the line with the data

                local spellName = thisData.name
                if not issecretvalue(spellName) and spellName == "EMPTY" then
                    line:SetHeight(tooltipEmptyLineHeight)
                    line.SpellName:SetText("")
                    line.SpellIcon:SetTexture(nil)
                    --clear font strings so only the help text shows
                    for j = 1, 6 do
                        local fontString = line.dataFontStrings[j]
                        fontString:SetText("")
                    end
                    line.StatusBar:SetMinMaxValues(0, 1)
                    line.StatusBar:SetValue(0)
                    line.StatusBar:SetPoint("left", line, "left", tooltipLineHeight, 0)
                    line.StatusBar:SetSize(tooltip:GetWidth() - tooltipLineHeight - 4, tooltipEmptyLineHeight)

                elseif thisData.isHeader then
                    if showHeader then
                        formatLineAsHeader(line, {thisData.name, unpack(thisData.texts or {})}, thisData.icon, thisData.iconcoords)
                    end

                else
                    line.SpellName:SetText(spellName)

                    if not issecretvalue(spellName) then
                        detailsFramework:TruncateText(line.SpellName, tooltip:GetWidth() / 2.3)
                    end

                    line.SpellIcon:ClearAllPoints()
                    line.SpellIcon:SetPoint("left", line.StatusBar, "left", -tooltipLineHeight, 0)
                    line.SpellIcon:SetTexture(thisData.icon)
                    line.SpellIcon:SetTexCoord(unpack(thisData.iconcoords or {0, 1, 0, 1}))
                    local iconSize = thisData.iconsize or tooltipLineHeight
                    line.SpellIcon:SetSize(iconSize, iconSize)

                    if thisData.amount and thisData.topBarValue then
                        line.StatusBar:SetMinMaxValues(0, thisData.topBarValue)
                        line.StatusBar:SetValue(thisData.amount)
                    else
                        line.StatusBar:SetMinMaxValues(0, tooltip.maxAmount)
                        line.StatusBar:SetValue(thisData.amount)
                    end

                    line.StatusBar:SetPoint("left", line, "left", tooltipLineHeight, 0)
                    line.StatusBar:SetSize(tooltip:GetWidth() - tooltipLineHeight - 4, tooltipLineHeight)

                    --clear font strings
                    for j = 1, 6 do
                        local fontString = line.dataFontStrings[j]
                        fontString:SetText("")
                    end

                    local dataAmount = #thisData.texts

                    local fontStringIndex = 1
                    for j = dataAmount, 1, -1 do
                        --if data is an empty string, skip it: when the data is invalid or user choise to not show
                        if not issecretvalue(thisData.texts[j]) and thisData.texts[j] and thisData.texts[j] ~= "" then
                            local fontString = line.dataFontStrings[fontStringIndex]
                            fontString:SetText(thisData.texts[j])
                            fontStringIndex = fontStringIndex + 1
                        else
                            local fontString = line.dataFontStrings[fontStringIndex]
                            fontString:SetText(thisData.texts[j])
                            fontStringIndex = fontStringIndex + 1
                        end
                    end

                    line:SetHeight(tooltipLineHeight)
                end
                nextLine = i + 1
            end
        end

        if showHelp and nextLine <= totalLines then
            --show an extra line with the text "/details tooltip for options"
            local line = self:GetLine(nextLine)
            ---@cast line detailstooltipline
            line.SpellName:SetText("/details tooltip for options")

            --clear font strings so only the help text shows
            for j = 1, 6 do
                local fontString = line.dataFontStrings[j]
                fontString:SetText("")
            end

            local fontString = line.dataFontStrings[1]
            fontString:SetText(Details.tooltip.show_help_count .. " / " .. MAX_TOOLTIP_HELP)

            --set up the status bar for the help line
            line.StatusBar:SetMinMaxValues(0, 1)
            line.StatusBar:SetValue(1)
            line.StatusBar:SetPoint("left", line, "left", tooltipLineHeight, 0)
            line.StatusBar:SetSize(tooltip:GetWidth() - tooltipLineHeight - 4, tooltipLineHeight)
        end
    end

    ---@class detailstooltipline : button
    ---@field StatusBar statusbar
    ---@field SpellIcon texture
    ---@field SpellName fontstring
    ---@field Background texture
    ---@field dataFontStrings fontstring[]

    ---this function creates a new line for the scroll box
    ---@param self df_scrollbox
    ---@param index number line index
    ---@return detailstooltipline
    local createLineFunc = function(self, index)
        --create a new line
        local line = CreateFrame("button", "$parentLine" .. index, self)
        ---@cast line detailstooltipline
        line:EnableMouse(false)

        local linesCreated = self:GetLines()
        local previousLine = linesCreated[#linesCreated]

        if not previousLine then
            line:SetPoint("topleft", self, "topleft", 2, 0)
            line:SetPoint("topright", self, "topright", -2, 0)
        else
            line:SetPoint("topleft", previousLine, "bottomleft", 0, -tooltipPadding)
            line:SetPoint("topright", previousLine, "bottomright", 0, -tooltipPadding)
        end
        line:SetHeight(tooltipLineHeight)

        local statusBar = CreateFrame("statusbar", "$parentStatusBar", line)
        ---@cast statusBar statusbar
        --statusBar:SetAllPoints()
        --ponit and size update dynamically in the refresFunc
        statusBar:SetStatusBarTexture([[Interface\AddOns\Details\images\bar_background_dark_withline]])

        local background = statusBar:CreateTexture("$parentBackground", "background")
        background:SetAllPoints()
        background:SetColorTexture(.5, .5, .5, 1)

        local spellIcon = statusBar:CreateTexture("$parentIcon", "overlay")
        spellIcon:SetPoint("left", statusBar, "left", -tooltipLineHeight, 0)
        spellIcon:SetSize(tooltipLineHeight, tooltipLineHeight)
        spellIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        --setup the line creating frames, texts and other widgets, they are refreshed in the refresFunc
        local spellName = statusBar:CreateFontString("$parentSpellName", "overlay", "GameFontNormal")
        spellName:SetPoint("left", spellIcon, "right", 2, 0)

        line.dataFontStrings = {}

        for i = 1, 6 do
            local dataFontString = statusBar:CreateFontString("$parentDataFontString" .. i, "overlay", "GameFontNormal")

            if i == 1 then
                dataFontString:SetPoint("right", statusBar, "right", -2, 0)
            else
                dataFontString:SetPoint("right", line.dataFontStrings[i - 1], "left", -tooltipFontStringPadding, 0)
            end

            line.dataFontStrings[i] = dataFontString
        end

        --test
        for i = 1, #line.dataFontStrings do
            local s = line.dataFontStrings[i]
            s:ClearAllPoints()
            s:SetPoint("right", statusBar, "right", -2 - (i-1) * (tooltipFontStringPadding + 45), 0)
        end

        line.StatusBar = statusBar
        line.SpellIcon = spellIcon
        line.SpellName = spellName
        line.Background = background

        return line
    end

    local dataPlaceholder = {}

    local scrollBox = detailsFramework:CreateScrollBox(tooltip, "$parentScrollbox", refreshFunc, dataPlaceholder, 1, 1, tooltipAmountOfLines, tooltipLineHeight)
    --used 1 for width and height because we will set the size using anchors
    scrollBox:SetPoint("topleft", tooltip, "topleft", 0, 0)
    scrollBox:SetPoint("bottomright", tooltip, "bottomright", 0, 0)
    scrollBox:EnableMouse(false)
    --appearance
    detailsFramework:ReskinSlider(scrollBox)

    tooltip.ScrollBox = scrollBox

    --manually create the lines when the createLineFunc is not provided
    for i = 1, tooltipAmountOfLines do
        scrollBox:CreateLine(createLineFunc)
    end

    --call a refresh in the scrollBox
    --scrollBox:Refresh()

    local defaultColor = {r=0.5, g=0.5, b=0.5, a=1}

    ---@param self df_scrollbox
    ---@param data addonapoc_tooltipdata
    function scrollBox:RefreshMe(data)
        --refresh the line appearance
        local classColor = RAID_CLASS_COLORS[data.class] or defaultColor
        local r, g, b, a = unpack(Details.tooltip.bar_color)
        local rBG, gBG, bBG, aBG = unpack(Details.tooltip.background)

        local allTooltipLines = self:GetLines()
        for i = 1, #allTooltipLines do
            local line = allTooltipLines[i]
            line.Background:SetColorTexture(0, 0, 0, 0.5)

            --format right texts using tooltip settings
            for j = 1, #line.dataFontStrings do
                local fontString = line.dataFontStrings[j]
                fontString:SetTextColor(unpack(Details.tooltip.fontcolor_right)) --
                detailsFramework:SetFontSize(fontString, Details.tooltip.fontsize) --
                detailsFramework:SetFontFace(fontString, Details.tooltip.fontface) --
                detailsFramework:SetFontOutline(fontString, Details.tooltip.fontshadow  and "OUTLINE") --
            end

            local fontString = line.SpellName
            fontString:SetTextColor(unpack(Details.tooltip.fontcolor)) --
            detailsFramework:SetFontSize(fontString, Details.tooltip.fontsize) --
            detailsFramework:SetFontFace(fontString, Details.tooltip.fontface) --
            detailsFramework:SetFontOutline(fontString, Details.tooltip.fontshadow  and "OUTLINE")

            line.Background:SetVertexColor(classColor.r, classColor.g, classColor.b, aBG)
            line.StatusBar:GetStatusBarTexture():SetVertexColor(r, g, b, a)
        end

        tooltip.Background:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)

        self:SetData(data)
        self:Refresh()

        self.ScrollBar:Hide()
    end

    return tooltip
end

---@return detailstooltip
function Details:GetTooltip()
    return getTooltipFrame()
end


--~tooltip
---@param instanceLine detailsline
function bParser.ShowTooltip(instance, instanceLine)
    ---@type attributeid, attributeid
    local mainDisplay, subDisplay = instance:GetDisplay()

    --fragile: Handle with care!
    local sourceGUID = instanceLine.secret_SourceGUID
    local actorName = instanceLine.secret_SourceName
    local attributeType = bParser.GetAttributeTypeFromDisplay(mainDisplay, subDisplay)
    local actorList = Details222.B.GetSegmentInfo(Details222.B.GetSegment("Type", 1, 0))
    local firstActor = actorList[1]
    local spellList, amountOfSpells, totalAmount, maxAmount = Details222.B.GetSpellContainerInfo(Details222.B.GetSpells("Type", 1, 0, sourceGUID or UnitGUID("player")))

    for i = 1, amountOfSpells do
        local spellDetails = spellList[i]
        local spellID = spellDetails.spellID
        local spellAmount = spellDetails.totalAmount
        --local spellPercent = (spellAmount / maxAmount) * 100 --nop

        local spellInfo = C_Spell.GetSpellInfo(spellID)
        GameCooltip:AddLine(spellInfo.name, spellAmount)

        local iconSize = Details.DefaultTooltipIconSize
        local icon_border = Details.tooltip.icon_border_texcoord

        GameCooltip:SetOption("FixedWidth", 200)

        GameCooltip:AddIcon(spellInfo.iconID, nil, nil, iconSize, iconSize, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
        Details:AddTooltipBackgroundStatusbar_Secret(spellAmount, maxAmount)
    end
end

function bParser.HideTooltip_Hook(instanceLine, mouse)
    if not detailsFramework.IsAddonApocalypseWow() then
        return
    end

    local tooltip = Details:GetTooltip()
    if not tooltip:IsMouseOver() then
        tooltip:Hide()
    else
        local x, y = GetCursorPosition()
        if tooltip.showTime and tooltip.showTime == GetTime() then
        end

        C_Timer.NewTicker(0.03, function(ticker)
            if not tooltip:IsMouseOver() then
                tooltip:Hide()
                ticker:Cancel()
            else
                local nx, ny = GetCursorPosition()
                if nx ~= x or ny ~= y then
                    tooltip:Hide()
                    ticker:Cancel()
                end
            end
        end)
    end
end

function bParser.GetSerial(sourcePlayer, icon)
    local thisSerial = not issecretvalue(sourcePlayer.sourceGUID) and sourcePlayer.sourceGUID or nil
    thisSerial = thisSerial or bParser.guidCache[icon or sourcePlayer.specIconID] or nil
    local guid = thisSerial or (sourcePlayer.isLocalPlayer and UnitGUID("player")) or nil
    return guid
end

--~tooltip
---@param instanceLine detailsline
function bParser.ShowTooltip_Hook(instanceLine, mouse)
    if not detailsFramework.IsAddonApocalypseWow() then
        return
    end

    local instance = instanceLine:GetInstance()

    if instance.line_no_tooltip then
        return
    end

    if not bParser.InSecretLockdown() then
        if not Details:IsUsingBlizzardAPI(instance) then
            return
        end
    end

    if instanceLine.isTotalBar then
        return
    end

    local baseFrame = instance.baseframe

    local tooltip = Details:GetTooltip()

    tooltip:SetClampedToScreen(true)
    tooltip:ClearAllPoints()

    local instanceLineWidth = instanceLine:GetWidth()
    local tooltipWidth = Details.tooltip.apocalypse_width_useline and instanceLineWidth or (Details.tooltip.apocalypse_width or 300)

    if (Details.tooltip.anchored_to == 1) then
        local addedPadding = 0
        if (instanceLineWidth < tooltipWidth) then
            local diff = tooltipWidth - instanceLineWidth
            addedPadding = diff / 2
        end
        tooltip:SetPoint("bottomleft", instanceLine, "topleft", -addedPadding, 3)
        tooltip:SetPoint("bottomright", instanceLine, "topright", addedPadding, 3)
    else
        local myPoint = Details.tooltip.anchor_point
        local anchorPoint = Details.tooltip.anchor_relative
        local x_Offset = Details.tooltip.anchor_offset[1]
        local y_Offset = Details.tooltip.anchor_offset[2]
        tooltip:SetPoint(myPoint, DetailsTooltipAnchor, anchorPoint, x_Offset, y_Offset)
        tooltip:SetWidth(tooltipWidth)
    end

    local sourceSpells, targets

    local sessionType = instanceLine.sessionType
    local sessionId = instanceLine.sessionId
    local icon = instanceLine.blzSpecIcon
    local damageMeterType = instanceLine.damageMeterType
    local sourcePlayer = instanceLine.sourceData

    local guid = bParser.GetSerial(sourcePlayer, icon)
    local hasSourceSpells = false

    if damageMeterType == 9 then
        local hasRecap, events, maxHealth, link = Details222.Recap.GetRecapInfo(sourcePlayer.deathRecapID)
        if hasRecap then
            local instance = instanceLine:GetInstance()
            GameCooltip:Preset(2)

            if not issecretvalue(instanceLine.actorName) then
                local adapter = Details:MakeDeathLogAdapter(instance, instanceLine.actorName, events, maxHealth)
                Details:ToolTipDead(instance, adapter.deathLog, instanceLine)
            else
                Details.ShowDeathTooltip2(instance, instanceLine) do return end
                GameCooltip:AddLine("The tooltip for this player is a secret and can't be displayed while in combat.", "", 1, "orange", "white", 14)
                GameCooltip:AddIcon([[Interface\ENCOUNTERJOURNAL\UI-EJ-WarningTextIcon]], 1, 1, 40, 40, 0, 1, 0, 1)
                GameCooltip:SetOption("FixedWidth", 300)
                GameCooltip:ShowCooltip(instanceLine)
            end
        end
        return

    elseif (damageMeterType < 0) then
        sourceSpells = Details222.BParser.GetCustomDataForTooltip(instance, damageMeterType, sourcePlayer)
        --dumpt(sourceSpells)
        hasSourceSpells = true
    else
        local creature = not issecretvalue(sourcePlayer.sourceCreatureID) and sourcePlayer.sourceCreatureID
        if guid or creature then
            sourceSpells = Details222.B.GetSpells(sessionType <= 1 and DETAILS_SEGMENTTYPE_TYPE or DETAILS_SEGMENTTYPE_ID, sessionType <= 1 and sessionType or sessionId, damageMeterType, guid, creature)
            hasSourceSpells = true
            --dumpt(sourceSpells)

            if not issecretvalue(sourcePlayer.name) then
                targets = Details222.BreakdownWindowMidnight.LoadTargets(sessionType, sessionId, sourcePlayer.name)
            end
        end
    end

    ---@type addonapoc_tooltipdata[]
    local tooltipData = {}

    if not hasSourceSpells then
        if issecretvalue(sourcePlayer.sourceGUID) then
            --print("tooltip error: sourcePlayer.sourceGUID")
        end

        GameCooltip:Preset(2)
        GameCooltip:AddLine("The tooltip for this player is a secret and can't be displayed while in combat.", "", 1, "orange", "white", 14)
        GameCooltip:AddIcon([[Interface\ENCOUNTERJOURNAL\UI-EJ-WarningTextIcon]], 1, 1, 40, 40, 0, 1, 0, 1)
        GameCooltip:SetOption("FixedWidth", 300)
        GameCooltip:ShowCooltip(instanceLine)
        do return end

        ---@type addonapoc_tooltipdata
        local data = {
            name = "The World of Warcraft client\ndoes not give the tooltip data\nfor this player.",
            icon = "",
            texts = {""},
            amount = 0,
            text_size = 16,
        }
        tooltipData[#tooltipData + 1] = data

        tooltipData.class = instanceLine.sourceData.classFilename
        tooltipData.specIcon = instanceLine.sourceData.specIconID

        tooltip.ScrollBox:RefreshMe(tooltipData)
        tooltip:Show()
        return
    end

    if not sourceSpells then
        ---@type addonapoc_tooltipdata
        local data = {
            name = "No Spells Found",
            icon = "",
            texts = {""},
            amount = 0,
        }
        tooltipData[#tooltipData + 1] = data
        return
    end

    local extraTooltipLines = (Details.tooltip.show_help and 1 or 0)
    --local targetLineCount = (targets and #targets > 0) and (#targets + 2) or 0
    local targetLineCount = (targets and #targets > 0) and (min(#targets, amountOfTargetLines) + 2) or 0

    local headerLineCount = Details.tooltip.show_header and 1 or 0
    local maxSpellLines = max(0, tooltipAmountOfLines - extraTooltipLines - targetLineCount - headerLineCount)
    local amountOfSpellsToShow = min(#sourceSpells.combatSpells, maxSpellLines)
    local maxAmount = sourceSpells.maxAmount
    local totalAmount = sourceSpells.totalAmount

    tooltip:SetMaxAmount(maxAmount)

    if Details.tooltip.show_help then
        Details.tooltip.show_help_count = Details.tooltip.show_help_count + 1
        if Details.tooltip.show_help_count >= MAX_TOOLTIP_HELP then
            Details.tooltip.show_help = false
        end
    end

    local couldGetPercent = false
    --for i = amountOfSpellsToShow, 1, -1 do
    for i = 1, amountOfSpellsToShow do
        local spellDetails = sourceSpells.combatSpells[i]

        --spell details
        local spellId = spellDetails.spellID
        local spellAmount = spellDetails.totalAmount
        local dps = spellDetails.amountPerSecond
        local isDeadly = spellDetails.isDeadly
        local creatureName = spellDetails.creatureName
        local isAvoidable = spellDetails.isAvoidable
        local overkillAmount = spellDetails.overkillAmount

        --creature info
        local isPet = spellDetails.combatSpellDetails.isPet
        local unitClassFilename = spellDetails.combatSpellDetails.unitClassFilename
        local amount = spellDetails.combatSpellDetails.amount
        local unitName = spellDetails.combatSpellDetails.unitName
        local isMob = spellDetails.combatSpellDetails.isMob
        local classification = spellDetails.combatSpellDetails.classification
        local specIconID = spellDetails.combatSpellDetails.specIconID

        --local spellPercent = (spellAmount / maxAmount) * 100 --nop

        local spellInfo = C_Spell.GetSpellInfo(spellId)
        if not spellInfo then
            ---@diagnostic disable-next-line: missing-fields
            spellInfo = {
                name = unitName or "Unknown Spell",
                iconID = specIconID or 136243, --question mark?
            }
        end

        ---@class addonapoc_tooltipdata
        ---@field name string
        ---@field icon number
        ---@field texts (string|number)[]
        ---@field amount number

        local leftText = ""
        if issecretvalue(creatureName) then
            if instanceLine.classFilename == "HUNTER" then
                leftText = spellInfo.name .. " (|cFFAAAAAA" .. creatureName .. "|r)"
            else
                leftText = spellInfo.name
            end
        else
            leftText = spellInfo.name .. (creatureName and creatureName ~= "" and " (|cFFAAAAAA" .. creatureName .. "|r)" or "")
        end
        --local result = DurationObject:EvaluateElapsedPercent(curve [, modifier])

        local success, percent = pcall(function()
            local curve = C_CurveUtil.CreateCurve()
            curve:AddPoint(0, 0)
            curve:AddPoint(totalAmount, 100.0)
            return curve:Evaluate(spellAmount)
        end)

		local showDPS = Details.tooltip.show_dps_column
		local showPercent = Details.tooltip.show_percent_column
        local canShowPercent = showPercent and not issecretvalue(totalAmount)
        couldGetPercent = couldGetPercent or canShowPercent

        local thisAmount = AbbreviateNumbers(spellAmount, Details.abbreviateOptionsDamage) or ""
        local thisDPS = showDPS and AbbreviateNumbers(dps, Details.abbreviateOptionsDPS)
        local thisPercent = canShowPercent and format("%.1f%%", spellAmount / totalAmount * 100)

        local dataToShow = {thisAmount} --amount done is always shown
        if thisDPS then
            dataToShow[#dataToShow + 1] = thisDPS
        end
        if thisPercent then
            dataToShow[#dataToShow + 1] = thisPercent
        end

        tooltipData[#tooltipData + 1] = {
            name = leftText,
            icon = spellInfo.iconID,
            texts = dataToShow,
            amount = spellAmount,
        }
    end

    if targets and #targets > 0 then --~target ~targets
        local showDPS = Details.tooltip.show_dps_column
        local showPercent = Details.tooltip.show_percent_column and couldGetPercent

        local targetHeaderTexts = {"Amount"}
        if showDPS then
            targetHeaderTexts[#targetHeaderTexts + 1] = "DPS"
        end
        if showPercent then
            targetHeaderTexts[#targetHeaderTexts + 1] = "%"
        end

        --empty line
        tooltipData[#tooltipData + 1] = {
            name = "EMPTY",
            icon = "",
            texts = {""},
            amount = 0,
        }

        tooltipData[#tooltipData + 1] = {
            name = "Targets",
            icon = [[Interface/MINIMAP/TRACKING/Target]],
            iconcoords = {0.1, 0.9, 0.1, 0.9},
            texts = targetHeaderTexts,
            amount = 0,
            isHeader = true,
        }

        table.sort(targets, function(a, b) return a.amount > b.amount end)
        targets.topValue = targets[1] and targets[1].amount or 0

        for i = 1, min(#targets, amountOfTargetLines) do
            tooltipData[#tooltipData + 1] = targets[i]
            targets[i].topBarValue = targets.topValue
        end
    end

    local showDPS = Details.tooltip.show_dps_column
    local showPercent = Details.tooltip.show_percent_column and couldGetPercent

    if Details.tooltip.show_header then
        local spellHeaderTexts = {"Amount"}
        if showDPS then
            spellHeaderTexts[#spellHeaderTexts + 1] = "DPS"
        end
        if showPercent then
            spellHeaderTexts[#spellHeaderTexts + 1] = "%"
        end

        table.insert(tooltipData, 1, {
            name = "Spell Name",
            icon = [[Interface\\WORLDSTATEFRAME\\CombatSwords]],
            iconcoords = {0, 0.5, 0, 0.5},
            texts = spellHeaderTexts,
            amount = 0,
            isHeader = true,
        })
    end

    tooltipData.class = instanceLine.sourceData.classFilename
    tooltipData.specIcon = instanceLine.sourceData.specIconID

    local totalVisibleLines = min(tooltipAmountOfLines, #tooltipData + extraTooltipLines)
    local visibleHeight = 0
    for i = 1, totalVisibleLines do
        local lineHeight = tooltipLineHeight
        local thisLineData = tooltipData[i]
        if thisLineData and not issecretvalue(thisLineData.name) and thisLineData.name == "EMPTY" then
            lineHeight = tooltipEmptyLineHeight
        end
        visibleHeight = visibleHeight + lineHeight
    end

    if totalVisibleLines > 1 then
        visibleHeight = visibleHeight + ((totalVisibleLines - 1) * tooltipPadding)
    end

    tooltip:SetHeight(visibleHeight + 4)

    tooltip.ScrollBox:RefreshMe(tooltipData)
    tooltip.showTime = GetTime()
    tooltip:Show()

    GameCooltip:Hide()
end

