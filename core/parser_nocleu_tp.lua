
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
local tooltipLineHeight = 20
local tooltipFontStringPadding = 6 --space between each font string horizontally
local tooltipPadding = 1 --space between each line
local cantStartUpdater = false
local updaterTicker = nil

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

    tooltip:SetScript("OnLeave", function(self)
        self:Hide()
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

    --refresh the scroll box lines
    ---@param self df_scrollbox
    ---@param data table an indexed table with subtables holding the data necessary to refresh each line
    ---@param offset number used to know which line to start showing
    ---@param totalLines number of lines shown in the scroll box
    local refresFunc = function(self, data, offset, totalLines)
        --the first line will be used as a header line
        local headerLine = self:GetLine(1)
        ---@cast headerLine detailstooltipline
        --clear font strings
        for j = 1, 6 do
            local fontString = headerLine.dataFontStrings[j]
            fontString:SetText("")
        end
        headerLine.SpellName:SetText(data.header[1])
        headerLine.StatusBar:SetPoint("left", headerLine, "left", 0, 0)
        headerLine.StatusBar:SetSize(tooltip:GetWidth()-4, tooltipLineHeight)
        headerLine.StatusBar:SetMinMaxValues(0, 1)
        headerLine.StatusBar:SetValue(0)
        headerLine.SpellIcon:ClearAllPoints()
        headerLine.SpellIcon:SetPoint("left", headerLine, "left", 2, 0)
        headerLine.SpellIcon:SetTexture([[Interface\WORLDSTATEFRAME\CombatSwords]])
        headerLine.SpellIcon:SetTexCoord(0, .5, 0, .5)

        for j = #data.header, 2, -1 do
            local fontString = headerLine.dataFontStrings[#data.header - j + 1]
            --local fontString = line.dataFontStrings[j]
            fontString:SetText(data.header[j])
        end

        for i = 2, totalLines do
            local index = (i-1) + offset
            local thisData = data[index]
            if (thisData) then
                local line = self:GetLine(i)
                ---@cast line detailstooltipline
                --update the line with the data
                line.SpellName:SetText(thisData.name)
                line.SpellIcon:SetTexture(thisData.icon)
                line.StatusBar:SetMinMaxValues(0, tooltip.maxAmount)
                line.StatusBar:SetValue(thisData.amount)
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
                    local fontString = line.dataFontStrings[fontStringIndex]
                    fontString:SetText(thisData.texts[j])
                    fontStringIndex = fontStringIndex + 1
                end
            end
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

        local yPosition = (tooltipLineHeight + tooltipPadding) * (index - 1) * -1
        yPosition = yPosition - 3

        line:SetPoint("topleft", self, "topleft", 2, yPosition)
        line:SetPoint("topright", self, "topright", -2, yPosition)
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

    local scrollBox = detailsFramework:CreateScrollBox(tooltip, "$parentScrollbox", refresFunc, dataPlaceholder, 1, 1, tooltipAmountOfLines, tooltipLineHeight)
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

--~tooltip
---@param instanceLine detailsline
function bParser.ShowTooltip_Hook(instanceLine, mouse)
    if not detailsFramework.IsAddonApocalypseWow() then
        return
    end

    if not bParser.InSecretLockdown() then
        if not Details:IsUsingBlizzardAPI() then
            return
        end
    end

    if instanceLine.isTotalBar then
        return
    end

    local instance = instanceLine:GetInstance()
    local baseFrame = instance.baseframe

    local tooltip = Details:GetTooltip()

    tooltip:SetClampedToScreen(true)
    tooltip:ClearAllPoints()

    if (Details.tooltip.anchored_to == 1) then
        local instanceLineWidth = instanceLine:GetWidth()
        local addedPadding = 0
        if (instanceLineWidth < 300) then
            local diff = 300 - instanceLineWidth
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
        tooltip:SetWidth(baseFrame:GetWidth())
    end

    ---@type attributeid, attributeid
    --local mainDisplay, subDisplay = instance:GetDisplay()

    --fragile: Handle with care!
    --local sourceGUID = instanceLine.secret_SourceGUID
    --local actorName = instanceLine.secret_SourceName

    ---@type damagemeter_type
    --local damageMeterType = bParser.GetAttributeTypeFromDisplay(mainDisplay, subDisplay)
    --local spells = GetSpells(DAMAGE_METER_SESSIONPARAMETER_TYPE, 0, 0, sourceGUID)
    --local blzDamageContainer = Details222.B.GetSegment(DETAILS_SEGMENTTYPE_TYPE, Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.DamageDone)
    --local firstCombatant = blzDamageContainer.combatSources[1]
    --local spells = Details222.B.GetSegment(DETAILS_SEGMENTTYPE_TYPE, 1, 0, UnitGUID("player"))

    local sourceSpells

    local sessionType = instanceLine.sessionType
    local sessionId = instanceLine.sessionId
    local icon = instanceLine.blzSpecIcon
    local damageMeterType = instanceLine.damageMeterType
    local sourcePlayer = instanceLine.sourceData

    --[=[
        ["classFilename"] = "", --no secret
        ["deathRecapID"] = 0,
        ["amountPerSecond"] = 273.32142857143,
        ["sourceCreatureID"] = 225976,
        ["name"] = "Normal Tank Dummy",
        ["classification"] = "normal", --no secret
        ["deathTimeSeconds"] = 0,
        ["totalAmount"] = 7653,
        ["isLocalPlayer"] = false,

        ["classFilename"] = "HUNTER",
        ["deathRecapID"] = 0,
        ["amountPerSecond"] = 273.32142857143,
        ["specIconID"] = 236179,
        ["name"] = "Tiranaa",
        ["classification"] = "", --no secret
        ["deathTimeSeconds"] = 0,
        ["totalAmount"] = 7653,
        ["isLocalPlayer"] = true,
        ["sourceGUID"] = "Player-3209-0514457A",
    ]=]

    local thisGUID = not issecretvalue(sourcePlayer.sourceGUID) and sourcePlayer.sourceGUID
    thisGUID = thisGUID or bParser.guidCache[icon]
    local guid = thisGUID or (sourcePlayer.isLocalPlayer and UnitGUID("player"))
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
    else
        if guid then
            if Details222.B.IsSegmentType(sessionType) then
                sourceSpells = Details222.B.GetSpells("Type", sessionType, damageMeterType, guid, sourcePlayer.sourceCreatureID)
                hasSourceSpells = true
            else
                sourceSpells = Details222.B.GetSpells("ID", sessionId, damageMeterType, guid, sourcePlayer.sourceCreatureID)
                hasSourceSpells = true
            end
        elseif (bParser.IsNotADude(sourcePlayer)) then
            if Details222.B.IsSegmentType(sessionType) then
                sourceSpells = Details222.B.GetSpells("Type", sessionType, damageMeterType, nil, sourcePlayer.sourceCreatureID)
                hasSourceSpells = true
            else
                sourceSpells = Details222.B.GetSpells("ID", sessionId, damageMeterType, nil, sourcePlayer.sourceCreatureID)
                hasSourceSpells = true
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

    local amountOfSpellsToShow = min(#sourceSpells.combatSpells, tooltipAmountOfLines)
    local maxAmount = sourceSpells.maxAmount
    local totalAmount = sourceSpells.totalAmount

    tooltip:SetMaxAmount(maxAmount)
    tooltip:SetHeight((amountOfSpellsToShow+1) * (tooltipLineHeight+1) + 4)

--[=[
["combatSpells"] =  {
   [1] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "",
      ["amountPerSecond"] = 181.95422363281,
      ["totalAmount"] = 7903,
      ["isAvoidable"] = false,
      ["spellID"] = 193455,
   },
   [2] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "",
      ["amountPerSecond"] = 113.34438323975,
      ["totalAmount"] = 4923,
      ["isAvoidable"] = false,
      ["spellID"] = 75,
   },
   [3] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "",
      ["amountPerSecond"] = 74.27360534668,
      ["totalAmount"] = 3226,
      ["isAvoidable"] = false,
      ["spellID"] = 389839,
   },
   [4] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "",
      ["amountPerSecond"] = 57.650684356689,
      ["totalAmount"] = 2504,
      ["isAvoidable"] = false,
      ["spellID"] = 217200,
   },
   [5] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "CatTwo",
      ["amountPerSecond"] = 56.246257781982,
      ["totalAmount"] = 2443,
      ["isAvoidable"] = false,
      ["spellID"] = 6603,
   },
   [6] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "CatTwo",
      ["amountPerSecond"] = 52.746692657471,
      ["totalAmount"] = 2291,
      ["isAvoidable"] = false,
      ["spellID"] = 17253,
   },
   [7] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "",
      ["amountPerSecond"] = 40.843578338623,
      ["totalAmount"] = 1774,
      ["isAvoidable"] = false,
      ["spellID"] = 404884,
   },
   [8] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "CatTwo",
      ["amountPerSecond"] = 32.900489807129,
      ["totalAmount"] = 1429,
      ["isAvoidable"] = false,
      ["spellID"] = 34026,
   },
   [9] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "",
         ["amount"] = 0,
         ["unitName"] = "",
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "CatTwo",
      ["amountPerSecond"] = 17.520835876465,
      ["totalAmount"] = 761,
      ["isAvoidable"] = false,
      ["spellID"] = 201754,
   },
},
["totalAmount"] = 27254,
["maxAmount"] = 7903,

]=]

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
        ---@field texts number[]
        ---@field amount number

        --
        --print(issecretvalue(creatureName), "creatureName", creatureName)

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

        if not success then
            ---@type addonapoc_tooltipdata
            local data = {
                name = leftText,
                icon = spellInfo.iconID,
                texts = {AbbreviateNumbers(spellAmount, Details.abbreviateOptionsDamage), AbbreviateNumbers(dps, Details.abbreviateOptionsDPS)},
                amount = spellAmount,
            }
            tooltipData[#tooltipData + 1] = data

        else
            ---@type addonapoc_tooltipdata
            local data = {
                name = leftText,
                icon = spellInfo.iconID,
                texts = {AbbreviateNumbers(spellAmount, Details.abbreviateOptionsDamage), AbbreviateNumbers(dps, Details.abbreviateOptionsDPS), format("%.1f%%", percent)},
                amount = spellAmount,
            }
            couldGetPercent = true
            tooltipData[#tooltipData + 1] = data
        end

        --GameCooltip:AddLine(spellInfo.name, spellAmount)

        --local iconSize = Details.DefaultTooltipIconSize
        --local icon_border = Details.tooltip.icon_border_texcoord

        --GameCooltip:AddIcon(spellInfo.iconID, nil, nil, iconSize, iconSize, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
        --Details:AddTooltipBackgroundStatusbar_Secret(spellAmount, maxAmount)
    end

    if not couldGetPercent then
        tooltipData.header = {"Spell Name", "Amount", "DPS"}
    else
        tooltipData.header = {"Spell Name", "Amount", "DPS", "%"}
    end

    tooltipData.class = instanceLine.sourceData.classFilename
    tooltipData.specIcon = instanceLine.sourceData.specIconID

    tooltip.ScrollBox:RefreshMe(tooltipData)
    tooltip.showTime = GetTime()
    tooltip:Show()
end

