
local addonId, edTable = ...
local Details = _G._detalhes
local AceLocale = LibStub("AceLocale-3.0")
local Loc = AceLocale:GetLocale("Details_EncounterDetails")
local ipairs = ipairs
local Details_GetSpellInfo = Details.getspellinfo
local unpack = unpack
local detailsFramework = DetailsFramework
local CreateFrame = CreateFrame
local GameCooltip = GameCooltip
local _
local DETAILS_ATTRIBUTE_DAMAGE = DETAILS_ATTRIBUTE_DAMAGE
local CONST_DETAILS_MODE_GROUP = DETAILS_MODE_GROUP
local DETAILS_SEGMENTTYPE_MYTHICDUNGEON = DETAILS_SEGMENTTYPE_MYTHICDUNGEON
local DETAILS_ATTRIBUTE_MISC = DETAILS_ATTRIBUTE_MISC
local GameTooltip = GameTooltip

local GetSpellInfo = GetSpellInfo or C_Spell.GetSpellInfo

if (detailsFramework.IsWarWow()) then
    GetSpellInfo = function(...)
        local result = C_Spell.GetSpellInfo(...)
        if result then
            return result.name, 1, result.iconID
        end
    end
end

local encounterDetails = _G.EncounterDetailsGlobal
local edFrame = encounterDetails.Frame

---@alias interruptamount number
---@alias successcastamount number

local genericOnMouseDown = function()
    --frame:StartMoving()
    --frame.isMoving = true
end

local genericOnMouseUp = function()
    if (edFrame.isMoving) then
    --	frame:StopMovingOrSizing()
    --	frame.isMoving = false
    end
end

local CONST_BOX_VERTICAL_SPACING = -29
local CONST_BOX_HORIZONTAL_SPACING = 42
local CONST_BOX_WIDTH = 250
local CONST_LINE_HEIGHT = 20

local CONST_BOX_HEIGHT_TOP = 263
local CONST_BOX_HEIGHT_BOTTOM = 202
local CONST_LINE_AMOUNT_TOP = 13
local CONST_LINE_AMOUNT_BOTTOM = 10

---create a new row
---@param index number
---@param parent any
---@return ed_barline
local createRow = function(parent, index)
    ---@type ed_barline
    local newBar = CreateFrame("Button", parent:GetName() .. "Bar" .. index, parent, "BackdropTemplate")

    newBar:SetSize(CONST_BOX_WIDTH - 2, CONST_LINE_HEIGHT)
    newBar:SetPoint("topleft", parent, "topleft", 1, -((index-1) * (CONST_LINE_HEIGHT)) - 1)
    newBar:SetFrameLevel(parent:GetFrameLevel() + 1)
    newBar:EnableMouse(true)
    newBar:RegisterForClicks("LeftButtonDown", "RightButtonUp")
    newBar:SetBackdrop(edTable.defaultBackdrop)
    newBar:SetBackdropColor(.1, .1, .1, 0.834)
    newBar:SetAlpha(0.9)

    newBar.statusBar = CreateFrame("StatusBar", nil, newBar, "BackdropTemplate")
    newBar.statusBar:SetPoint("topleft", newBar, "topleft", 0, 0)
    newBar.statusBar:SetPoint("bottomright", newBar, "bottomright", 0, 1)
    newBar.statusBar:SetFrameLevel(newBar:GetFrameLevel() + 1)

    local statusBarTexture = newBar.statusBar:CreateTexture(nil, "artwork")
    statusBarTexture:SetTexture(encounterDetails.Frame.DefaultBarTexture)
    newBar.statusBarTexture = statusBarTexture
    newBar.statusBar:SetStatusBarTexture(statusBarTexture)
    newBar.statusBar:SetStatusBarColor(0, 0, 0, 1)
    newBar.statusBar:SetMinMaxValues(0, 1)

    local highlightTexture = newBar.statusBar:CreateTexture(nil, "overlay", nil, 7) --"highlight" doesn't work, dunno why
    highlightTexture:SetColorTexture(1, 1, 1, 0.2)
    highlightTexture:SetAllPoints()
    highlightTexture:Hide()
    newBar.highlightTexture = highlightTexture

    newBar.lineText1 = newBar.statusBar:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    newBar.lineText1:SetPoint("left", newBar.statusBar, "left", 22, -1)
    newBar.lineText1:SetJustifyH("left")
    newBar.lineText1:SetTextColor(1, 1, 1, 1)

    newBar.lineText3 = newBar.statusBar:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    newBar.lineText3:SetPoint("right", newBar.statusBar, "right", -70, 0)
    newBar.lineText3:SetJustifyH("right")
    newBar.lineText3:SetTextColor(1, 1, 1, 1)

    newBar.lineText4 = newBar.statusBar:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    newBar.lineText4:SetPoint("right", newBar.statusBar, "right", -2, 0)
    newBar.lineText4:SetJustifyH("right")
    newBar.lineText4:SetTextColor(1, 1, 1, 1)

    newBar.Icon = newBar.statusBar:CreateTexture(nil, "overlay")
    newBar.Icon:SetWidth(CONST_LINE_HEIGHT)
    newBar.Icon:SetHeight(CONST_LINE_HEIGHT)
    newBar.Icon:SetPoint("right", newBar.statusBar, "left", 20, 0)
    newBar.Icon:SetAlpha(.9)

    newBar:Hide()
    return newBar
end

do --player damage taken
    -- ~containers ~damagetaken create the scroll frame
    local playerDamageTaken_OnEnterFunc = function(bar)
        ---@type actordamage
        local actorObject = bar.actorObject
        if (not actorObject) then
            return
        end

        bar.highlightTexture:Show()

        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local damageTakenFrom = actorObject.damage_from
        local damageTakenAmount = actorObject.damage_taken
        local actorName = actorObject:Name()

        ---@type {key1: spellid, key2: valueamount, key3: actorname, key4: spellschool}[]
        local aggressorList = {}

        for aggressorName in pairs(damageTakenFrom) do
            local thisAggressorActorObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, aggressorName)
            if (thisAggressorActorObject) then
                local spellContainer = thisAggressorActorObject:GetSpellContainer("spell")
                for spellId, spellTable in spellContainer:ListSpells() do
                    ---@type table<actorname, valueamount>
                    local targetsTable = spellTable.targets
                    for targetName, amount in pairs(targetsTable) do
                        if (targetName == actorName) then
                            local aggresorName = thisAggressorActorObject:Name()
                            ---@type {key1: spellid, key2: valueamount, key3: actorname, key4: spellschool}
                            aggressorList[#aggressorList+1] = {spellId, amount, aggresorName, spellTable.spellschool}
                        end
                    end
                end
            end
        end

        table.sort(aggressorList, Details.Sort2)

        local gameCooltip = GameCooltip
        Details:SetCooltipForPlugins()

        local topDamage = aggressorList[1] and aggressorList[1][2]

        for i = 1, #aggressorList do
            local spellId = aggressorList[i][1]
            local damageDone = aggressorList[i][2]
            local aggressorName = aggressorList[i][3]
            local spellSchool = aggressorList[i][4]

            local spellName, _, spellIcon = Details_GetSpellInfo(spellId)

            if (spellId == 1) then --melee
                aggressorName = detailsFramework:CleanUpName(aggressorName)
                spellName = "*" .. aggressorName
            end

            local school = spellSchool or Details:GetSpellSchool(spellId) or 1
            local red, green, blue = Details:GetSpellSchoolColor(school)

            gameCooltip:AddLine(spellName, Details:Format(damageDone) .. " (" .. string.format("%.1f", (damageDone / damageTakenAmount) * 100) .. "%)", 1, "white")
            gameCooltip:AddStatusBar(damageDone / topDamage * 100, 1, red, green, blue, edFrame.CooltipStatusbarAlpha, false, {value = 100, color = {.21, .21, .21, 0.8}, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
            gameCooltip:AddIcon(spellIcon, nil, 1, encounterDetails.CooltipLineHeight - 0, encounterDetails.CooltipLineHeight - 0, .1, .9, .1, .9)
        end

        gameCooltip:SetOwner(bar:GetParent(), "topleft", "topright", 2, 0)
        gameCooltip:Show()
    end

    local damageTaken_RefreshFunc = function(self, data, offset, totalLines) --~refresh ~damage ~taken ~by ~spell
        local ToK = Details:GetCurrentToKFunction()
        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local topValue = data[1] and data[1][2]

        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index]

            if (thisData) then
                local line = self:GetLine(i)
                local actorName = thisData[1]
                local damageTaken = thisData[2]
                local actorObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, actorName)

                line.lineText1:SetText(detailsFramework:RemoveRealmName(actorName))
                line.lineText3:SetText("")
                line.lineText4:SetText(Details:Format(damageTaken))
                local red, green, blue = Details:GetClassColor(actorObject:Class())
                line.statusBar:SetStatusBarColor(red, green, blue)

                line.statusBar:SetValue(damageTaken / topValue)

                local specTexture, left, right, top, bottom = Details:GetSpecIcon(actorObject:Spec())
                line.Icon:SetTexture(specTexture)
                line.Icon:SetTexCoord(left, right, top, bottom)

                line.actorObject = actorObject

                Details:name_space(line)
            end
        end
    end

    local damageTakenScroll = detailsFramework:CreateScrollBox(edFrame, "$parentDamageTakenScroll", damageTaken_RefreshFunc, {}, CONST_BOX_WIDTH, CONST_BOX_HEIGHT_BOTTOM, CONST_LINE_AMOUNT_BOTTOM, CONST_LINE_HEIGHT)
    detailsFramework:ReskinSlider(damageTakenScroll)
    detailsFramework:ApplyStandardBackdrop(damageTakenScroll)
    damageTakenScroll:SetScript("OnMouseDown", genericOnMouseDown)
    damageTakenScroll:SetScript("OnMouseUp", genericOnMouseUp)

    edFrame.encounterSummaryWidgets[#edFrame.encounterSummaryWidgets+1] = damageTakenScroll
    edFrame.damageTakenByPlayersScroll = damageTakenScroll

    local icon = detailsFramework:CreateImage(damageTakenScroll, "Interface\\AddOns\\Details\\images\\atributos_icones_damage", 20, 20, "overlay", {0.125*2, 0.125*3, 0, 1})
    icon:SetPoint("bottomleft", damageTakenScroll, "topleft", 0, 1)

    local damageTakenTitle = detailsFramework:NewLabel(damageTakenScroll, damageTakenScroll, nil, "damagetaken_title", "Player Damage Taken", "GameFontHighlight") --localize-me
    damageTakenTitle:SetPoint("left", icon, "right", 2, 0)

    for i = 1, CONST_LINE_AMOUNT_BOTTOM do
        local newBar = damageTakenScroll:CreateLine(createRow)
        newBar:SetScript("OnEnter", playerDamageTaken_OnEnterFunc)
        newBar:SetScript("OnLeave", function(self) GameCooltip:Hide(); GameTooltip:Hide(); newBar.highlightTexture:Hide() end)
    end

    function encounterDetails.RefreshDamageTakenScroll(combatObject)
        --this is a trick to use the refresh window function to set the data in order insted of doing the process manually
        Details.atributo_damage:RefreshWindow({}, combatObject, _, {key = "damage_taken", modo = CONST_DETAILS_MODE_GROUP})

        local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

        ---@type {key1: actorname, key2: number}[]
        local data = {}
        for _, actorObject in damageContainer:ListActors() do
            if (actorObject:IsGroupPlayer()) then
                data[#data+1] = {actorObject:Name(), actorObject.damage_taken}
            else
                break
            end
        end

        edFrame.damageTakenByPlayersScroll:SetData(data)
        edFrame.damageTakenByPlayersScroll:Refresh()
    end
end

do --~ability ~damage taken by spell
    local spellDamage_OnEnterFunc = function(bar)
        local spellId = bar.spellId
        local spellName, _, spellIcon = Details_GetSpellInfo(spellId)
        local damageDone = bar.damageDone

        local spellTargets = bar.spellTargets
        if (not spellTargets) then
            return
        end

        bar.highlightTexture:Show()

        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        ---@type actorcontainer
        local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

        local targetActors = {}
        local damageTotal = damageDone

        for playerName, damageAmount in pairs(spellTargets) do
            targetActors[#targetActors+1] = {playerName, damageAmount}
        end

        table.sort(targetActors, Details.Sort2)

        Details:SetCooltipForPlugins()

        local topValue = targetActors[1] and targetActors[1][2]

        GameCooltip:Preset(2)

        for index, playerDamageTable in ipairs(targetActors) do
            local playerName = playerDamageTable[1]
            local damageAmount = playerDamageTable[2]

            ---@type actor
            local actorObject = damageContainer:GetActor(playerName)
            if (not actorObject) then
                return
            end

            local coords = encounterDetails.class_coords[playerDamageTable[3]]

            GameCooltip:AddLine(encounterDetails:GetOnlyName(playerName), Details:Format(damageAmount) .. " (" .. string.format("%.1f", damageAmount / damageTotal * 100) .. "%)", 1, "white")

            local actorClass = Details:GetClass(playerName)
            if (actorClass) then
                local r, g, b = Details:GetClassColor(actorClass)
                GameCooltip:AddStatusBar(damageAmount / topValue * 100, 1, r, g, b, edFrame.CooltipStatusbarAlpha, false, {value = 100, color = {.21, .21, .21, 0.5}, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
            else
                GameCooltip:AddStatusBar(damageAmount / topValue * 100, 1, 1, 1, 1, edFrame.CooltipStatusbarAlpha, false, {value = 100, color = {.21, .21, .21, 0.8}, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
            end

            local specId = actorObject.spec
            if (specId) then
                local texture, l, r, t, b = Details:GetSpecIcon(specId, false)
                GameCooltip:AddIcon(texture, 1, 1, encounterDetails.CooltipLineHeight - 0, encounterDetails.CooltipLineHeight - 0, l, r, t, b)
            else
                if (coords) then
                    GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\classes_small", nil, 1, encounterDetails.CooltipLineHeight-2, encounterDetails.CooltipLineHeight-2,(coords[1]),(coords[2]),(coords[3]),(coords[4]))
                end
            end
        end

        local spellname = GetSpellInfo(spellId)
        if (spellname) then
            GameTooltip:SetOwner(GameCooltipFrame1, "ANCHOR_NONE")
            GameTooltip:SetSpellByID(spellId)
            GameTooltip:SetPoint("right", bar, "left", -2, 0)
            GameTooltip:Show()
        end

        GameCooltip:SetOwner(bar, "topleft", "topright", 2, 0) --GameCooltip:SetOwner(bar:GetParent(), "topleft", "topright", 2, 0)
        GameCooltip:Show()
    end

    ---@param self any
    ---@param data table<number, {key1: spellid, key2: number, key3: number}> spellid, total, spellschool
    ---@param offset number
    ---@param totalLines number
    local spellDamage_RefreshFunc = function(self, data, offset, totalLines) --~refresh ~damage ~taken ~by ~spell
        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local topValue = data[1] and data[1][2]

        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index]

            if (thisData) then
                local line = self:GetLine(i)
                local spellId = thisData[1]
                local damageDone = thisData[2]
                local spellSchool = thisData[3]
                local spellTargets = thisData[4]
                local spellName, _, spellIcon = Details_GetSpellInfo(spellId)

                line.spellId = spellId
                line.damageDone = damageDone
                line.spellTargets = spellTargets

                line.lineText1:SetText(spellName)
                line.lineText3:SetText("")
                line.lineText4:SetText(Details:Format(damageDone))

                local red, green, blue = Details:GetSpellSchoolColor(spellSchool)
                line.statusBar:SetStatusBarColor(red, green, blue)

                line.statusBar:SetValue(damageDone / topValue)

                line.Icon:SetTexture(spellIcon)
                line.Icon:SetTexCoord(.1, .9, .1, .9)

                Details:name_space(line)
            end
        end
    end

    --damage taken by spell
    local spellDamageScroll = detailsFramework:CreateScrollBox(edFrame, "$parentSpellDamageScroll", spellDamage_RefreshFunc, {}, CONST_BOX_WIDTH, CONST_BOX_HEIGHT_TOP, CONST_LINE_AMOUNT_TOP, CONST_LINE_HEIGHT)
    detailsFramework:ReskinSlider(spellDamageScroll)
    detailsFramework:ApplyStandardBackdrop(spellDamageScroll)
    spellDamageScroll:SetScript("OnMouseDown", genericOnMouseDown)
    spellDamageScroll:SetScript("OnMouseUp", genericOnMouseUp)

    edFrame.encounterSummaryWidgets[#edFrame.encounterSummaryWidgets+1] = spellDamageScroll
    edFrame.spellDamageScroll = spellDamageScroll

    local icon = detailsFramework:CreateImage(spellDamageScroll, "Interface\\AddOns\\Details\\images\\atributos_icones_damage", 20, 20, "overlay", {0.125*7, 1, 0, 1})
    icon:SetPoint("bottomleft", spellDamageScroll, "topleft", 0, 1)

    local spellDamageTitle = detailsFramework:NewLabel(spellDamageScroll, spellDamageScroll, nil, "spelldamage_title", "Damage Taken by Spell", "GameFontHighlight") --localize-me
    spellDamageTitle:SetPoint("left", icon, "right", 2, 0)

    for i = 1, CONST_LINE_AMOUNT_TOP do
        local newBar = spellDamageScroll:CreateLine(createRow)
        newBar:SetScript("OnEnter", spellDamage_OnEnterFunc)
        newBar:SetScript("OnLeave", function(self) GameCooltip:Hide(); GameTooltip:Hide(); newBar.highlightTexture:Hide() end)
    end

    function encounterDetails.RefreshEnemySpellDamageScroll(combatObject)
        local spellDamageIndexTable = {}
        ---@type table<number, {key1: spellid, key2: valueamount, key3: spellschool, key4: table<actorname, valueamount>}> spellid, total, spellschool, {[targetname] = damageReceived}
        local spellDamageTable = {}
        local spellDamageIndex, total = 0, 0

        ---@type actorcontainer
        local damageActorContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

        --do a loop amoung the actors
        for _, actorObject in damageActorContainer:ListActors() do
            ---@cast actorObject actordamage
            if (actorObject:IsPlayer()) then
                for aggressorName in pairs(actorObject.damage_from) do
                    local aggressorActorObject = damageActorContainer:GetActor(aggressorName)
                    if (aggressorActorObject) then
                        --came from an enemy (not a player)
                        if (not aggressorActorObject:IsPlayer()) then
                            local spellList = aggressorActorObject:GetSpellList()
                            for spellId, spellTable in pairs(spellList) do
                                ---@type table<actorname, valueamount>
                                local damageOnThisActor = spellTable.targets[actorObject:Name()]
                                if (damageOnThisActor and damageOnThisActor >= 1) then
                                    local spellName = Details_GetSpellInfo(spellId)
                                    if (spellName) then
                                        local index = spellDamageIndexTable[spellName]
                                        local thisSpell

                                        if (index) then
                                            thisSpell = spellDamageTable[index]
                                        else
                                            spellDamageIndex = spellDamageIndex + 1
                                            thisSpell = spellDamageTable[spellDamageIndex]

                                            if (thisSpell) then
                                                local spellSchool = spellTable.spellschool or Details.spell_school_cache[select(1, GetSpellInfo(spellId))] or 1
                                                thisSpell[1] = spellId
                                                thisSpell[2] = 0
                                                thisSpell[3] = spellSchool
                                                ---@type table<actorname, valueamount>
                                                thisSpell[4] = thisSpell[4] or {} --spell targets
                                                spellDamageIndexTable[spellName] = spellDamageIndex
                                            else
                                                --hold a list of players who took damage from this spell
                                                local targets = {}
                                                local spellSchool = spellTable.spellschool or Details.spell_school_cache[select(1, GetSpellInfo(spellId))] or 1
                                                ---@type {key1: spellid, key2: valueamount, key3: spellschool, key4: table<actorname, valueamount>}
                                                thisSpell = {spellId, 0, spellSchool, targets}
                                                spellDamageTable[spellDamageIndex] = thisSpell
                                                spellDamageIndexTable[spellName] = spellDamageIndex
                                            end
                                        end

                                        thisSpell[2] = thisSpell[2] + damageOnThisActor
                                        thisSpell[4][actorObject:Name()] = (thisSpell[4][actorObject:Name()] or 0) + damageOnThisActor  --spell targets
                                        total = total + damageOnThisActor
                                    else
                                        error("error - no spell id for DTBS " .. spellId)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        table.sort(spellDamageTable, function(a, b) return a[2] > b[2] end)
        edFrame.spellDamageScroll:SetData(spellDamageTable)
        edFrame.spellDamageScroll:Refresh()
    end
end

do --enemy damage taken ~adds ~enemies
    local enemyAdds_OnEnterFunc = function(bar)
        ---@type actordamage
        local actorObject = bar.actorObject
        if (not actorObject) then
            return
        end

        bar.highlightTexture:Show()

        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local damageTakenFrom = actorObject.damage_from
        local damageTakenAmount = actorObject.damage_taken
        local actorName = actorObject:Name()

        ---@type {key1: actor, key2: valueamount}[] actor, damageTaken
        local aggressors = {}

        for aggressorName in pairs(damageTakenFrom) do
            ---@type actor
            local thisAggressorActorObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, aggressorName)
            if (thisAggressorActorObject and thisAggressorActorObject:IsPlayer()) then
                ---@type table<actorname, valueamount>
                local targets = thisAggressorActorObject.targets
                local damageDoneToThisEnemy = targets[actorName] or 0
                if (damageDoneToThisEnemy > 0) then
                    ---@type {key1: actor, key2: valueamount}
                    aggressors[#aggressors+1] = {thisAggressorActorObject, damageDoneToThisEnemy}
                end
            end
        end

        table.sort(aggressors, Details.Sort2)

        Details:SetCooltipForPlugins()

        local topDamage = aggressors[1] and aggressors[1][2]

        for i = 1, #aggressors do
            local aggresorActorObject = aggressors[i][1]
            local damageDoneToThisEnemy = aggressors[i][2]

            local red, green, blue = Details:GetClassColor(aggresorActorObject:Class())

            local specId = aggresorActorObject:Spec()
            local aggressorName = aggresorActorObject:Name()
            aggressorName = detailsFramework:CleanUpName(aggressorName)

            local specTexture, left, right, top, bottom = Details:GetSpecIcon(specId)

            GameCooltip:AddLine(aggressorName, Details:Format(damageDoneToThisEnemy) .. " (" .. string.format("%.1f", (damageDoneToThisEnemy / damageTakenAmount) * 100) .. "%)", 1, "white")
            GameCooltip:AddStatusBar(damageDoneToThisEnemy / topDamage * 100, 1, red, green, blue, .834, false, {value = 100, color = {.21, .21, .21, 0.8}, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
            GameCooltip:AddIcon(specTexture, nil, 1, encounterDetails.CooltipLineHeight - 0, encounterDetails.CooltipLineHeight - 0, left, right, top, bottom)
        end

        GameCooltip:SetOwner(bar:GetParent(), "topleft", "topright", 2, 0)
        GameCooltip:Show()
    end

    local enemiesScroll_RefreshFunc = function(self, data, offset, totalLines) --~refresh ~damage ~taken ~by ~spell
        local ToK = Details:GetCurrentToKFunction()
        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local topValue = data[1] and data[1][2]

        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index]

            if (thisData) then
                local line = self:GetLine(i)
                local actorName = thisData[1]
                local damageTaken = thisData[2]
                local actorObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, actorName)

                line.actorName = actorName
                line.damegeTaken = damageTaken
                line.actorObject = actorObject

                line.lineText1:SetText(detailsFramework:CleanUpName(actorName))
                line.lineText3:SetText("")
                line.lineText4:SetText(Details:Format(damageTaken))
                local red, green, blue = Details:GetClassColor(actorObject:Class())
                line.statusBar:SetStatusBarColor(0.5, 0.3, 0.3)

                line.statusBar:SetValue(damageTaken / topValue)

                local specTexture, left, right, top, bottom = Details:GetSpecIcon(actorObject:Spec())
                line.Icon:SetTexture(specTexture)
                line.Icon:SetTexCoord(left, right, top, bottom)

                Details:name_space(line)
            end
        end
    end

    local enemiesScroll = detailsFramework:CreateScrollBox(edFrame, "$parentEnemiesScroll", enemiesScroll_RefreshFunc, {}, CONST_BOX_WIDTH, CONST_BOX_HEIGHT_TOP, CONST_LINE_AMOUNT_TOP, CONST_LINE_HEIGHT)
    detailsFramework:ReskinSlider(enemiesScroll)
    detailsFramework:ApplyStandardBackdrop(enemiesScroll)
    enemiesScroll:SetScript("OnMouseDown", genericOnMouseDown)
    enemiesScroll:SetScript("OnMouseUp", genericOnMouseUp)

    edFrame.encounterSummaryWidgets[#edFrame.encounterSummaryWidgets+1] = enemiesScroll
    edFrame.enemiesScroll = enemiesScroll

    local icon = detailsFramework:CreateImage(enemiesScroll, "Interface\\AddOns\\Details\\images\\atributos_icones_damage", 20, 20, "overlay", {0.125*5, 0.125*6, 0, 1})
    icon:SetPoint("bottomleft", enemiesScroll, "topleft", 0, 1)

    local enemiesScrollTitle = detailsFramework:NewLabel(enemiesScroll, enemiesScroll, nil, "enemies_title", "Enemy Damage Taken", "GameFontHighlight") --localize-me
    enemiesScrollTitle:SetPoint("left", icon, "right", 2, 0)

    for i = 1, CONST_LINE_AMOUNT_TOP do
        local newBar = enemiesScroll:CreateLine(createRow)
        newBar:SetScript("OnEnter", enemyAdds_OnEnterFunc)
        newBar:SetScript("OnLeave", function(self) GameCooltip:Hide(); GameTooltip:Hide(); newBar.highlightTexture:Hide() end)
    end

    function encounterDetails.RefreshEnemiesScoll(combatObject)
        local damageActorContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

        ---@type {key1: actorname, key2: valueamount}
        local data = {}

        local combatType, combatTypeZone = combatObject:GetCombatType()

        for _, actorObject in damageActorContainer:ListActors() do
            if (actorObject:IsNeutralOrEnemy() and (actorObject.boss_fight_component or combatTypeZone == DETAILS_SEGMENTTYPE_MYTHICDUNGEON)) then
                local actorName = actorObject:Name()
                local bIsSpellActor = actorName:match("%[%*%]%s") and true
                if (not bIsSpellActor) then
                    if (actorObject.damage_taken >= 1) then
                        data[#data+1] = {actorObject:Name(), actorObject.damage_taken}
                    end
                end
            end
        end

        table.sort(data, Details.Sort2)
        edFrame.enemiesScroll:SetData(data)
        edFrame.enemiesScroll:Refresh()
    end
end

do -- ~interrupt
    --structure: {spellId = {actorName = {interruptedAmountByThisPlayer, playerClass}}, interruptedAmount, spellId of the interrupted spell}[]
    local interrupt_OnEnterFunc = function(bar)
        local interruptBy = bar.whoInterrupted
        if (not interruptBy) then
            return
        end

        bar.highlightTexture:Show()

        local spellId = bar.spellId
        local interruptAmount = bar.interruptAmount

        GameCooltip:Preset(2)

        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local interruptsByTable = {}

        for playerName, amount in pairs(interruptBy) do
            local actorObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, playerName)
            interruptsByTable[#interruptsByTable + 1] = {playerName, amount, actorObject}
        end

        table.sort(interruptsByTable, Details.Sort2)

        for index, actorInterruptTable in ipairs(interruptsByTable) do
            local actorName = actorInterruptTable[1]
            local actorInterruptAmount = actorInterruptTable[2]
            local actorObject = actorInterruptTable[3]
            local specId = actorObject:Spec()

            GameCooltip:AddLine(encounterDetails:GetOnlyName(actorName), actorInterruptAmount, 1, "white", "orange")

            local texture, l, r, t, b = Details:GetSpecIcon(specId, false)
            if (texture) then
                GameCooltip:AddIcon(texture, 1, 1, encounterDetails.CooltipLineHeight, encounterDetails.CooltipLineHeight, l, r, t, b)
            else
                local coords = encounterDetails.class_coords[actorObject:Class()]
                GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\classes_small", nil, 1, encounterDetails.CooltipLineHeight, encounterDetails.CooltipLineHeight, coords[1], coords[2], coords[3], coords[4])
            end
        end

        GameCooltip:SetOwner(bar:GetParent(), "bottom", "top", 0, 5)
        GameCooltip:Show()

        local spellName = GetSpellInfo(spellId)
        if (spellName) then
            GameTooltip:SetOwner(GameCooltipFrame1, "ANCHOR_NONE")
            GameTooltip:SetSpellByID(spellId)
            GameTooltip:SetPoint("topright", GameCooltipFrame1, "topleft", -2, 0)
            GameTooltip:Show()
        end
    end

    local interruptScroll_RefreshFunc = function(self, data, offset, totalLines) --~refresh ~interrupt ~interrupts ~cut ~kicks ~quick
        local ToK = Details:GetCurrentToKFunction()
        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local topValue = data[1] and data[1][2]

        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index]

            if (thisData) then
                local line = self:GetLine(i)
                local interruptingPlayers = thisData[1]
                local interruptAmount = thisData[2]
                local spellId = thisData[3]
                local totalCasts = thisData[5]

                line.spellId = spellId
                line.whoInterrupted = interruptingPlayers

                local spellName, _, spellIcon = GetSpellInfo(spellId)

                line.lineText1:SetText(spellName)
                line.lineText3:SetText("")
                line.lineText4:SetText(interruptAmount .. " / " .. totalCasts)

                local spellSchool = Details.spell_school_cache[spellName]
                local red, green, blue = Details:GetSpellSchoolColor(spellSchool or 1)
                line.statusBar:SetStatusBarColor(red, green, blue)

                line.statusBar:SetValue(interruptAmount / topValue)

                line.Icon:SetTexture(spellIcon)
                line.Icon:SetTexCoord(.1, .9, .1, .9)

                Details:name_space(line)
            end
        end
    end

    local interruptsScroll = detailsFramework:CreateScrollBox(edFrame, "$parentInterruptsScroll", interruptScroll_RefreshFunc, {}, CONST_BOX_WIDTH, CONST_BOX_HEIGHT_BOTTOM, CONST_LINE_AMOUNT_BOTTOM, CONST_LINE_HEIGHT)
    detailsFramework:ReskinSlider(interruptsScroll)
    detailsFramework:ApplyStandardBackdrop(interruptsScroll)
    interruptsScroll:SetScript("OnMouseDown", genericOnMouseDown)
    interruptsScroll:SetScript("OnMouseUp", genericOnMouseUp)

    edFrame.encounterSummaryWidgets[#edFrame.encounterSummaryWidgets+1] = interruptsScroll
    edFrame.interruptsScroll = interruptsScroll

    local icon = detailsFramework:CreateImage(interruptsScroll, "Interface\\AddOns\\Details\\images\\atributos_icones_misc", 20, 20, "overlay", {0.125*2, 0.125*3, 0, 1})
    icon:SetPoint("bottomleft", interruptsScroll, "topleft", 0, 1)

    local interruptsScrollTitle = detailsFramework:NewLabel(interruptsScroll, interruptsScroll, nil, "interrupt_title", "Interrupts", "GameFontHighlight") --localize-me
    interruptsScrollTitle:SetPoint("left", icon, "right", 2, 0)

    for i = 1, CONST_LINE_AMOUNT_BOTTOM do
        local newBar = interruptsScroll:CreateLine(createRow)
        newBar:SetScript("OnEnter", interrupt_OnEnterFunc)
        newBar:SetScript("OnLeave", function(self) GameCooltip:Hide(); GameTooltip:Hide(); newBar.highlightTexture:Hide() end)
    end

    function encounterDetails.RefreshInterruptsScoll(combatObject)
        Details.atributo_misc:RefreshWindow({}, combatObject, _, {key = "interrupt", modo = CONST_DETAILS_MODE_GROUP})

        local data = {}

        local utilityActorContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_MISC)
        local damageActorContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

        ---@type {key1: table<actorname, interruptamount>, key2: interruptamount, key3: spellid, key4: actor, key5: successcastamount}[]
        local interruptedSpells = {}

        for index, actorObject in utilityActorContainer:ListActors() do
            ---@cast actorObject actorutility
            if (not actorObject:IsGroupPlayer()) then
                break
            end

            local actorName = actorObject:Name()

            --amount of interrupts
            local interrupts = actorObject.interrupt
            if (interrupts and interrupts > 0) then
                local spellsInterrupted = actorObject.interrompeu_oque

                for spellId, interruptAmount in pairs(spellsInterrupted) do
                    local thisInterruptedSpellTable = interruptedSpells[spellId]

                    if (not thisInterruptedSpellTable) then
                        ---@type {key1: table<actorname, valueamount>, key2: interruptamount, key3: spellid, key4: actor, key5: successcastamount}
                        thisInterruptedSpellTable = {{}, 0, spellId, actorObject, 0}
                        interruptedSpells[spellId] = thisInterruptedSpellTable
                    end

                    if (not thisInterruptedSpellTable[1][actorName]) then
                        thisInterruptedSpellTable[1][actorName] = 0
                    end

                    --increase the amount of interrupts of the interrupted spell
                    thisInterruptedSpellTable[2] = thisInterruptedSpellTable[2] + interruptAmount

                    --increase the amount of interrupts of this player
                    thisInterruptedSpellTable[1][actorName] = thisInterruptedSpellTable[1][actorName] + interruptAmount
                end
            end
        end

        local tableInOrder = {}

        for spellId, interruptInfo in pairs(interruptedSpells) do
            ---@type {key1: table<actorname, valueamount>, key2: interruptamount, key3: spellid, key4: actor, key5: successcastamount}
            tableInOrder[#tableInOrder+1] = interruptInfo

            for _, actorObject in damageActorContainer:ListActors() do
                if (actorObject:IsNeutralOrEnemy()) then
                    ---@type spelltable
                    local spellTable = actorObject:GetSpell(spellId)
                    if (spellTable) then
                        interruptInfo[5] = spellTable.successful_casted or 0.001
                    end
                end
            end
        end

        table.sort(tableInOrder, Details.Sort2)

        edFrame.interruptsScroll:SetData(tableInOrder)
        edFrame.interruptsScroll:Refresh()
    end
end

do -- ~dispel
    local function dispel_OnEnterFunc(bar)
        local dispelBy = bar.whoDispelled
        if (not dispelBy) then
            return
        end

        bar.highlightTexture:Show()

        local spellId = bar.spellId
        local dispelAmount = bar.dispelAmount

        GameCooltip:Preset(2)

        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local dispelsByTable = {}

        for playerName, amount in pairs(dispelBy) do
            local actorObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, playerName)
            dispelsByTable[#dispelsByTable + 1] = {playerName, amount, actorObject}
        end

        table.sort(dispelsByTable, Details.Sort2)

        for index, actorDispelTable in ipairs(dispelsByTable) do
            local actorName = actorDispelTable[1]
            local actorDispelAmount = actorDispelTable[2]
            local actorObject = actorDispelTable[3]
            local specId = actorObject:Spec()

            GameCooltip:AddLine(encounterDetails:GetOnlyName(actorName), actorDispelAmount, 1, "white", "orange")

            local texture, l, r, t, b = Details:GetSpecIcon(specId, false)
            if (texture) then
                GameCooltip:AddIcon(texture, 1, 1, encounterDetails.CooltipLineHeight, encounterDetails.CooltipLineHeight, l, r, t, b)
            else
                local coords = encounterDetails.class_coords[actorObject:Class()]
                GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\classes_small", nil, 1, encounterDetails.CooltipLineHeight, encounterDetails.CooltipLineHeight, coords[1], coords[2], coords[3], coords[4])
            end
        end

        GameCooltip:SetOwner(bar:GetParent(), "bottom", "top", 0, 5)
        GameCooltip:Show()

        local spellName = GetSpellInfo(spellId)
        if (spellName) then
            GameTooltip:SetOwner(GameCooltipFrame1, "ANCHOR_NONE")
            GameTooltip:SetSpellByID(spellId)
            GameTooltip:SetPoint("topright", GameCooltipFrame1, "topleft", -2, 0)
            GameTooltip:Show()
        end
    end

    local dispelScroll_RefreshFunc = function(self, data, offset, totalLines) --~refresh ~dispel ~dispels
        local ToK = Details:GetCurrentToKFunction()
        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local topValue = data[1] and data[1][2]

        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index]

            if (thisData) then
                local line = self:GetLine(i)
                local playersWhoDispelled = thisData[1]
                local dispelAmount = thisData[2]
                local spellId = thisData[3]

                line.whoDispelled = playersWhoDispelled
                line.spellId = spellId
                line.dispelAmount = dispelAmount

                local spellName, _, spellIcon = GetSpellInfo(spellId)

                line.lineText1:SetText(spellName)
                line.lineText3:SetText("")
                line.lineText4:SetText(dispelAmount)

                local spellSchool = Details.spell_school_cache[spellName]
                local red, green, blue = Details:GetSpellSchoolColor(spellSchool or 1)
                line.statusBar:SetStatusBarColor(red, green, blue)

                line.statusBar:SetValue(dispelAmount / topValue)

                line.Icon:SetTexture(spellIcon)
                line.Icon:SetTexCoord(.1, .9, .1, .9)

                Details:name_space(line)
            end
        end
    end

    local dispelScroll = detailsFramework:CreateScrollBox(edFrame, "$parentDispelScroll", dispelScroll_RefreshFunc, {}, CONST_BOX_WIDTH, CONST_BOX_HEIGHT_BOTTOM, CONST_LINE_AMOUNT_BOTTOM, CONST_LINE_HEIGHT)
    detailsFramework:ReskinSlider(dispelScroll)
    detailsFramework:ApplyStandardBackdrop(dispelScroll)
    dispelScroll:SetScript("OnMouseDown", genericOnMouseDown)
    dispelScroll:SetScript("OnMouseUp", genericOnMouseUp)

    edFrame.encounterSummaryWidgets[#edFrame.encounterSummaryWidgets+1] = dispelScroll
    edFrame.dispelScroll = dispelScroll

    local icon = detailsFramework:CreateImage(dispelScroll, "Interface\\AddOns\\Details\\images\\atributos_icones_misc", 20, 20, "overlay", {0.125*3, 0.125*4, 0, 1})
    icon:SetPoint("bottomleft", dispelScroll, "topleft", 0, 1)

    local dispelScrollTitle = detailsFramework:NewLabel(dispelScroll, dispelScroll, nil, "dispel_title", "Dispels", "GameFontHighlight") --localize-me
    dispelScrollTitle:SetPoint("left", icon, "right", 2, 0)

    for i = 1, CONST_LINE_AMOUNT_BOTTOM do
        local newBar = dispelScroll:CreateLine(createRow)
        newBar:SetScript("OnEnter", dispel_OnEnterFunc)
        newBar:SetScript("OnLeave", function(self) GameCooltip:Hide(); GameTooltip:Hide(); newBar.highlightTexture:Hide() end)
    end

    function encounterDetails.RefreshDispelsScoll(combatObject)
        Details.atributo_misc:RefreshWindow({}, combatObject, _, {key = "dispell", modo = CONST_DETAILS_MODE_GROUP})
        local utilityActorContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_MISC)

        local dispelledHarfulSpells = {}

        for index, actorObject in utilityActorContainer:ListActors() do
            ---@cast actorObject actorutility

            if (not actorObject:IsGroupPlayer()) then
                break
            end

            local actorName = actorObject:Name()

            --amount of dispels
            local dispels = actorObject.dispell
            if (dispels and dispels > 0) then
                ---@type table<number, number>
                local spellsDispelled = actorObject.dispell_oque

                for spellId, dispelAmount in pairs(spellsDispelled) do
                    local thisDispelSpellTable = dispelledHarfulSpells[spellId]

                    if (not thisDispelSpellTable) then
                        ---@type {key1: table<actorname, valueamount>, key2: valueamount, key3: spellid, key4: actorutility}
                        thisDispelSpellTable = {{}, 0, spellId, actorObject}
                        dispelledHarfulSpells[spellId] = thisDispelSpellTable
                    end

                    --check if this player dispelled this spell
                    if (not thisDispelSpellTable[1][actorName]) then
                        thisDispelSpellTable[1][actorName] = 0
                    end

                    --increase the amount of interrupts of the interrupted spell
                    thisDispelSpellTable[2] = thisDispelSpellTable[2] + dispelAmount

                    --increase the amount of interrupts of this player
                    thisDispelSpellTable[1][actorName] = thisDispelSpellTable[1][actorName] + dispelAmount
                end
            end
        end

        local tableInOrder = {}
        for spellId, dispellInfo in pairs(dispelledHarfulSpells) do
            tableInOrder[#tableInOrder+1] = dispellInfo
        end
        table.sort(tableInOrder, Details.Sort2)

        edFrame.dispelScroll:SetData(tableInOrder)
        edFrame.dispelScroll:Refresh()
    end
end

do --~deaths ~dead
	local bgColor, borderColor = {0.17, 0.17, 0.17, .9}, {.30, .30, .30, .3}
    local statusBarBackground = {value = 100, color = {.11, .11, .11, 0.8}, texture = [[Interface\AddOns\Details\images\bar_serenity]]}

	local deathLog_OnEnterFunc = function(bar)
		local iconSize = 19
        local deathTable = bar.deathInfo
        if (not deathTable) then
            return
        end

        bar.highlightTexture:Show()

		local eventsBeforeDeath = deathTable[1]
		local timeOfDeath = deathTable[2]
		local maxHealth = deathTable[5]

		local battleRess = false
		local lastCooldown = false

        Details:SetCooltipForPlugins()
		GameCooltip:SetType("tooltipbar")

        eventsBeforeDeath = detailsFramework.table.reverse(eventsBeforeDeath)

		GameCooltip:AddLine(deathTable[6] .. " " .. "died" , "-- -- -- ", 1, "white")
		GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\small_icons", 1, 1, iconSize, iconSize, .75, 1, 0, 1)
		GameCooltip:AddStatusBar(0, 1, .5, .5, .5, .5, false, {value = 100, color = {.5, .5, .5, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar4_vidro]]})

        for index, thisEvent in ipairs(eventsBeforeDeath) do
            local evType = thisEvent[1]
            if (evType == 2) then
                --battle ress
                battleRess = thisEvent

            elseif (evType == 3) then
                --last cooldown used
                lastCooldown = thisEvent
            end
        end

		if (battleRess) then
            local combatTimeOfDeath = deathTable.dead_at
            local battleRessTimeAfterDeath = battleRess[4] - timeOfDeath + combatTimeOfDeath

			local spellName, _, spellIcon = Details_GetSpellInfo(battleRess[2])
			GameCooltip:AddLine(detailsFramework:IntegerToTimer(battleRessTimeAfterDeath) .. " " .. spellName .. " (" .. battleRess[6] .. ")", "", 1, "white")
			GameCooltip:AddIcon("Interface\\Glues\\CharacterSelect\\Glues-AddOn-Icons", 1, 1, nil, nil, .75, 1, 0, 1)
			GameCooltip:AddStatusBar(0, 1, .5, .5, .5, .5, false, {value = 100, color = {.3, .3, .5, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
		end

		if (lastCooldown) then
			if (lastCooldown[2] > 0) then --spellId
				local spellName, _, spellIcon = Details_GetSpellInfo(lastCooldown[2])
				GameCooltip:AddLine(string.format("%.1f", lastCooldown[4] - timeOfDeath) .. "s " .. spellName .. " (" .. Loc ["STRING_LAST_COOLDOWN"] .. ")")
				GameCooltip:AddIcon(spellIcon, 1, 1, nil, nil, .1, .9, .1, .9)
                GameCooltip:AddStatusBar(0, 1, 1, 1, 1, 1, false, {value = 100, color = {.3, .5, .3, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
			else
				GameCooltip:AddLine(Loc ["STRING_NOLAST_COOLDOWN"])
				GameCooltip:AddIcon([[Interface\CHARACTERFRAME\UI-Player-PlayTimeUnhealthy]], 1, 1, 18, 18)
			end
		end

		--death parser
		for index, thisEvent in ipairs(eventsBeforeDeath) do
            local healthPercent = math.floor(thisEvent[5] * 100)
			if (healthPercent > 100) then
				healthPercent = 100
			end

			local evType = thisEvent[1]
			local spellName, _, spellIcon = Details_GetSpellInfo(thisEvent[2])
			local amount = thisEvent[3]
			local time = thisEvent[4]
			local source = thisEvent[6]

			if (type(evType) == "boolean") then
				--damage or heal
				if (evType) then --boolean true
					--damage
                    local overkillString = ""
					local overkill = thisEvent[10] or 0
					if (overkill > 0) then
						amount = amount - overkill
						overkillString = " (" .. Details:Format(overkill) .. " |cFFFF8800overkill|r)"
					else
						overkillString = ""
					end

					if (source:find("%[")) then
						source = source:gsub("%[%*%] ", "")
					end

                    local cleanSourceName = detailsFramework:CleanUpName(source)

					GameCooltip:AddLine("" .. string.format("%.1f", time - timeOfDeath) .. "s " .. spellName .. " (" .. cleanSourceName .. ")", "-" .. Details:Format(amount) .. overkillString .. " (" .. healthPercent .. "%)", 1, "white", "white")
					GameCooltip:AddIcon(spellIcon, 1, 1, 16, 16, .1, .9, .1, .9)

					if (thisEvent[9]) then
						--friendly fire
						GameCooltip:AddStatusBar(healthPercent, 1, "darkorange", false, statusBarBackground)
					else
						--from a enemy
						GameCooltip:AddStatusBar(healthPercent, 1, "red", false, statusBarBackground)
					end
				else --boolean false
					--heal
					local class = Details:GetClass(source)
					local spec = Details:GetSpec(source)

					GameCooltip:AddLine("" .. string.format("%.1f", time - timeOfDeath) .. "s " .. spellName .. " (" .. detailsFramework:CleanUpName(Details:AddClassOrSpecIcon(source, class, spec, 16, true)) .. ") ", "+" .. Details:Format(amount) .. "(" .. healthPercent .. "%)", 1, "white", "white")
					GameCooltip:AddIcon(spellIcon, 1, 1, 16, 16, .1, .9, .1, .9)
					GameCooltip:AddStatusBar(healthPercent, 1, "green", false, statusBarBackground)
				end

			elseif (type(evType) == "number") then
				if (evType == 1) then
					--cooldown
					GameCooltip:AddLine("" .. string.format("%.1f", time - timeOfDeath) .. "s " .. spellName .. " (" .. source .. ") ", "cooldown (" .. healthPercent .. "%)", 1, "white", "white")
					GameCooltip:AddIcon(spellIcon, 1, 1, 16, 16, .1, .9, .1, .9)
					GameCooltip:AddStatusBar(100, 1, "yellow", false, statusBarBackground)

				elseif (evType == 4) then
					--debuff
					if (source:find("%[")) then
						source = source:gsub("%[%*%] ", "")
					end

					GameCooltip:AddLine("" .. string.format("%.1f", time - timeOfDeath) .. "s [x" .. amount .. "] " .. spellName .. " (" .. source .. ")", "debuff (" .. healthPercent .. "%)", 1, "white", "white")
					GameCooltip:AddIcon(spellIcon, 1, 1, 16, 16, .1, .9, .1, .9)
					GameCooltip:AddStatusBar(100, 1, "purple", false, statusBarBackground)
				end
			end
		end

		--death log cooltip settings
		GameCooltip:SetOption("FixedWidth", 400)
		GameCooltip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar_serenity]])
		GameCooltip:SetBackdrop(1, Details.cooltip_preset2_backdrop, bgColor, borderColor)

		GameCooltip:SetOwner(bar:GetParent(), "topright", "topleft", -2, 0)
		GameCooltip:ShowCooltip()
	end

    local deathScroll_RefreshFunc = function(self, data, offset, totalLines) --~refresh ~death ~deaths
        ---@type combat
        local combatObject = encounterDetails:GetCombat(encounterDetails._segment)
        local topValue = data[1] and data[1][2]

        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index]

            if (thisData) then
                local line = self:GetLine(i)
                local actorName = thisData[1]
                local deathTime = thisData[2]
                local deathTable = thisData[3]
                local deathTimeUnixTime = thisData[4]
                local battleRess = thisData[5]

                local actorObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, actorName)
                local combatTime = combatObject:GetCombatTime()

                ---@type unixtime
                local combatStartTime = combatObject:GetStartTime()
                local combatEndTime = combatObject:GetEndTime()

                line.deathInfo = deathTable

                line.lineText1:SetText(detailsFramework:RemoveRealmName(actorName))
                line.lineText3:SetText("")

                if (battleRess[1]) then
                    --["1"] = 2, --evtype
                    --["2"] = 95750, --spellid
                    --["3"] = 1,
                    --["4"] = 1688241916.3,
                    --["5"] = 0,
                    --["6"] = "Source Name - who casted the battleress",

                    local spellName, _, spellIcon = GetSpellInfo(battleRess[2])
                    if (spellName) then
                        ---@type combattime
                        local combatTimeOfDeath = deathTable.dead_at
                        local timeOfDeath = deathTable[2]
                        local battleRessTimeAfterDeath = battleRess[4] - timeOfDeath + combatTimeOfDeath
                        local battleRessFormattedTime = detailsFramework:IntegerToTimer(battleRessTimeAfterDeath)
                        line.lineText3:SetText("|TInterface\\Glues\\CharacterSelect\\Glues-AddOn-Icons:16:16:0:0:64:64:48:64:0:64|t " .. battleRessFormattedTime)
                    end
                end

                line.lineText4:SetText(deathTime)
                local red, green, blue = Details:GetClassColor(actorObject:Class())
                line.statusBar:SetStatusBarColor(red, green, blue)

                line.statusBar:SetValue(1)

                local specTexture, left, right, top, bottom = Details:GetSpecIcon(actorObject:Spec())
                line.Icon:SetTexture(specTexture)
                line.Icon:SetTexCoord(left, right, top, bottom)

                Details:name_space(line)
            end
        end
    end

    local deathsScroll = detailsFramework:CreateScrollBox(edFrame, "$parentDeathsScroll", deathScroll_RefreshFunc, {}, CONST_BOX_WIDTH, CONST_BOX_HEIGHT_TOP, CONST_LINE_AMOUNT_TOP, CONST_LINE_HEIGHT)
    detailsFramework:ReskinSlider(deathsScroll)
    detailsFramework:ApplyStandardBackdrop(deathsScroll)
    deathsScroll:SetScript("OnMouseDown", genericOnMouseDown)
    deathsScroll:SetScript("OnMouseUp", genericOnMouseUp)

    edFrame.encounterSummaryWidgets[#edFrame.encounterSummaryWidgets+1] = deathsScroll
    edFrame.deathsScroll = deathsScroll

    local icon = detailsFramework:CreateImage(deathsScroll, "Interface\\AddOns\\Details\\images\\atributos_icones_misc", 20, 20, "overlay", {0.125*4, 0.125*5, 0, 1})
    icon:SetPoint("bottomleft", deathsScroll, "topleft", 0, 1)

    local deathsScrollTitle = detailsFramework:NewLabel(deathsScroll, deathsScroll, nil, "deaths_title", "Deaths", "GameFontHighlight") --localize-me
    deathsScrollTitle:SetPoint("left", icon, "right", 2, 0)

    for i = 1, CONST_LINE_AMOUNT_TOP do
        local newBar = deathsScroll:CreateLine(createRow)
        newBar:SetScript("OnEnter", deathLog_OnEnterFunc)
        newBar:SetScript("OnLeave", function() GameCooltip:Hide(); newBar.highlightTexture:Hide() end)
    end

    function encounterDetails.RefreshDeathsScoll(combatObject)
        local deathLog = combatObject:GetDeaths()
        local deathData = {}
        for index, deathInfo in ipairs(deathLog) do
            ---@cast deathInfo deathtable
            local unixTime = deathInfo[2]
            local playerName = deathInfo[3]
            local deathTime = deathInfo[6]

            local eventsBeforeDeath = deathInfo[1]
            local battleRess

            --find battle ress
            for _, thisEvent in ipairs(eventsBeforeDeath) do
                local evType = thisEvent[1]
                if (evType == 2 and not battleRess) then
                    --battle ress
                    battleRess = thisEvent
                    break
                end
            end

            deathData[#deathData+1] = {playerName, deathTime, deathInfo, unixTime, battleRess or {}}
        end

        table.sort(deathData, function(t1, t2) return t1[4] < t2[4] end)

        edFrame.deathsScroll:SetData(deathData)
        edFrame.deathsScroll:Refresh()
    end
end

function encounterDetails.RefreshSummaryPage(combatObject)
    local gradientHeight = 20
    local gradientAlpha = 0.25

    local topScrollRow = {
        edFrame.spellDamageScroll,
        edFrame.enemiesScroll,
        edFrame.deathsScroll
    }

    for i = 1, #topScrollRow do
        local thisScroll = topScrollRow[i]
        thisScroll:ClearAllPoints()
        if (i == 1) then
            thisScroll:SetPoint("topleft", edFrame, "topleft", 5, -97)
        else
            thisScroll:SetPoint("topleft", topScrollRow[i-1], "topright", CONST_BOX_HORIZONTAL_SPACING, 0)
        end
    end

    local bottomScrollRow = {
        edFrame.damageTakenByPlayersScroll,
        edFrame.interruptsScroll,
        edFrame.dispelScroll
    }

    for i = 1, #bottomScrollRow do
        local thisScroll = bottomScrollRow[i]
        thisScroll:ClearAllPoints()
        if (i == 1) then
            thisScroll:SetPoint("topleft", topScrollRow[1], "bottomleft", 0, CONST_BOX_VERTICAL_SPACING)
        else
            thisScroll:SetPoint("topleft", bottomScrollRow[i-1], "topright", CONST_BOX_HORIZONTAL_SPACING, 0)
        end
    end

    encounterDetails.RefreshDamageTakenScroll(combatObject)
    encounterDetails.RefreshEnemySpellDamageScroll(combatObject)
    encounterDetails.RefreshEnemiesScoll(combatObject)
    encounterDetails.RefreshInterruptsScoll(combatObject)
    encounterDetails.RefreshDispelsScoll(combatObject)
    encounterDetails.RefreshDeathsScoll(combatObject)
end