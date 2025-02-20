--[[
    This file show a frame at the end of a mythic+ run with a breakdown of the players performance.
    It shows the player name, the score, deaths, damage taken, dps, hps, interrupts, dispels and cc casts.    
]]

---@type details
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, Details222 = ...
local _ = nil
local mPlus = Details222.MythicPlusBreakdown

---@class details_mythicplus_breakdown : table
---@field CreateBigBreakdownFrame fun():details_mythicbreakdown_bigframe
---@field CreateLineForBigBreakdownFrame fun(parent:details_mythicbreakdown_bigframe, header:details_mythicbreakdown_headerframe, index:number):details_mythicbreakdown_line
---@field RefreshBigBreakdownFrame fun()

---@class details_mythicbreakdown_bigframe : frame
---@field HeaderFrame details_mythicbreakdown_headerframe

---@class details_mythicbreakdown_headerframe : df_headerframe
---@field lines table<number, details_mythicbreakdown_line>

---@class details_mythicbreakdown_line : frame, df_headerfunctions

---@type details_mythicplus_breakdown
---@diagnostic disable-next-line: missing-fields
local mythicPlusBreakdown = {}

local GetItemInfo = GetItemInfo or C_Item.GetItemInfo
local GetItemIcon = GetItemIcon or C_Item.GetItemIcon
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo or C_Item.GetDetailedItemLevelInfo

local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

local mythicDungeonCharts = Details222.MythicPlus.Charts.Listener
local mythicDungeonFrames = Details222.MythicPlus.Frames

local CONST_DEBUG_MODE = false
local LOOT_DEBUG_MODE = false

--main frame settings
local mainFrameName = "DetailsMythicPlusBreakdownFrame"
local mainFrameWidth = 1200
local mainFrameHeight = 420
--where the header is positioned in the Y axis from the top of the frame
local headerY = -70
--the amount of lines to be created to show player data
local lineAmount = 6
--player info area width (a.k.a the width of each line)
local lineWidth = mainFrameWidth - 6
local lineOffset = 3
--the height of each line
local lineHeight = 40
--two backdrop colors
local lineColor1 = {1, 1, 1, 0.05}
local lineColor2 = {1, 1, 1, 0.1}
local lineBackdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true}

---store spell names of interrupt spells
---the table is filled when the main frame is created
---@type table<string, boolean>
local interruptSpellNameCache = {}

function Details222.OpenMythicPlusBreakdownBigFrame()
    if (not _G[mainFrameName]) then
        mythicPlusBreakdown.CreateBigBreakdownFrame()
    end

    local mainFrame = _G[mainFrameName]
    mythicPlusBreakdown.RefreshBigBreakdownFrame()
    mainFrame:Show()
end

function Details.OpenMythicPlusBreakdownBigFrame()
    Details222.OpenMythicPlusBreakdownBigFrame()
end

function mythicPlusBreakdown.CreateBigBreakdownFrame()
    --quick exit if the frame already exists
    if (_G[mainFrameName]) then
        return _G[mainFrameName]
    end

    ---@type details_mythicbreakdown_bigframe
    local readyFrame = CreateFrame("frame", mainFrameName, UIParent, "BackdropTemplate")
    readyFrame:SetSize(mainFrameWidth, mainFrameHeight)
    readyFrame:SetPoint("center", UIParent, "center", 0, 0)
    readyFrame:SetFrameStrata("HIGH")
    readyFrame:EnableMouse(true)
    readyFrame:SetMovable(true)

    readyFrame:SetBackdropColor(.1, .1, .1, 0)
    readyFrame:SetBackdropBorderColor(.1, .1, .1, 0)
    detailsFramework:AddRoundedCornersToFrame(readyFrame, Details.PlayerBreakdown.RoundedCornerPreset)

    --detailsFramework:ApplyStandardBackdrop(readyFrame)
    detailsFramework:MakeDraggable(readyFrame)

    --title string
    local titleString = readyFrame:CreateFontString("$parentTitle", "overlay", "GameFontNormalLarge")
    titleString:SetPoint("top", readyFrame, "top", 0, -7)
    titleString:SetText(Loc["STRING_MYTHIC_PLUS_BREAKDOWN"])

    --elapsed fontstring

	--update the run time and time not in combat
    --[=[
	local elapsedTime = Details222.MythicPlus.time or 1507
	readyFrame.ElapsedTimeText:SetText(detailsFramework:IntegerToTimer(elapsedTime))

	if (overallMythicDungeonCombat:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
		local combatTime = overallMythicDungeonCombat:GetCombatTime()
		local notInCombat = elapsedTime - combatTime
		readyFrame.OutOfCombatText:SetText(detailsFramework:IntegerToTimer(notInCombat))
	else
		readyFrame.OutOfCombatText:SetText("00:00")
	end
    --]=]

    do
        local topFrame = CreateFrame("frame", "$parentTopFrame", readyFrame, "BackdropTemplate")
        topFrame:SetPoint("topleft", readyFrame, "topleft", 0, 0)
        topFrame:SetPoint("topright", readyFrame, "topright", 0, 0)
        topFrame:SetHeight(1)
        topFrame:SetFrameLevel(readyFrame:GetFrameLevel() - 1)

        --use the same textures from the original end of dungeon panel
        local spikes = topFrame:CreateTexture("$parentSkullCircle", "overlay")
        spikes:SetSize(100, 100)
        spikes:SetPoint("center", readyFrame, "top", 0, 27)
        spikes:SetAtlas("ChallengeMode-SpikeyStar")
        spikes:SetAlpha(1)
        spikes:SetIgnoreParentAlpha(true)
        readyFrame.YellowSpikeCircle = spikes
        --spikes:Hide()

        local yellowFlash = topFrame:CreateTexture("$parentYellowFlash", "artwork")
        yellowFlash:SetSize(120, 120)
        yellowFlash:SetPoint("center", readyFrame, "top", 0, 27)
        yellowFlash:SetAtlas("BossBanner-RedFlash")
        yellowFlash:SetAlpha(0)
        yellowFlash:SetBlendMode("ADD")
        yellowFlash:SetIgnoreParentAlpha(true)
        readyFrame.YellowFlash = yellowFlash

        readyFrame.Level = topFrame:CreateFontString("$parentLevelText", "overlay", "GameFontNormalWTF2Outline")
        readyFrame.Level:SetPoint("center", readyFrame.YellowSpikeCircle, "center", 0, 0)
        readyFrame.Level:SetText("12")

        --create the animation for the yellow flash
        local flashAnimHub = detailsFramework:CreateAnimationHub(yellowFlash, function() yellowFlash:SetAlpha(0) end, function() yellowFlash:SetAlpha(0) end)
        local flashAnim1 = detailsFramework:CreateAnimation(flashAnimHub, "Alpha", 1, 0.5, 0, 1)
        local flashAnim2 = detailsFramework:CreateAnimation(flashAnimHub, "Alpha", 2, 0.5, 1, 0)

        --create the animation for the yellow spike circle
        local spikeCircleAnimHub = detailsFramework:CreateAnimationHub(spikes, function() spikes:SetAlpha(0); spikes:SetScale(1) end, function() flashAnimHub:Play(); spikes:SetSize(100, 100); spikes:SetScale(1); spikes:SetAlpha(1) end)
        local alphaAnim1 = detailsFramework:CreateAnimation(spikeCircleAnimHub, "Alpha", 1, 0.2960000038147, 0, 1)
        local scaleAnim1 = detailsFramework:CreateAnimation(spikeCircleAnimHub, "Scale", 1, 0.21599999070168, 5, 5, 1, 1, "center", 0, 0)
        readyFrame.YellowSpikeCircle.OnShowAnimation = spikeCircleAnimHub

        readyFrame.leftFiligree = topFrame:CreateTexture("$parentLeftFiligree", "artwork")
        readyFrame.leftFiligree:SetAtlas("BossBanner-LeftFillagree")
        readyFrame.leftFiligree:SetSize(72, 43)
        readyFrame.leftFiligree:SetPoint("bottom", readyFrame, "top", -50, -2)
        --readyFrame.leftFiligree:Hide()

        readyFrame.rightFiligree = topFrame:CreateTexture("$parentRightFiligree", "artwork")
        readyFrame.rightFiligree:SetAtlas("BossBanner-RightFillagree")
        readyFrame.rightFiligree:SetSize(72, 43)
        readyFrame.rightFiligree:SetPoint("bottom", readyFrame, "top", 50, -2)
        --readyFrame.rightFiligree:Hide()

        --create the bottom filligree using BossBanner-BottomFillagree atlas
        readyFrame.bottomFiligree = topFrame:CreateTexture("$parentBottomFiligree", "artwork")
        readyFrame.bottomFiligree:SetAtlas("BossBanner-BottomFillagree")
        readyFrame.bottomFiligree:SetSize(66, 28)
        readyFrame.bottomFiligree:SetPoint("bottom", readyFrame, "bottom", 0, -19)
        --readyFrame.bottomFiligree:Hide()

    end

    --header frame
    local headerTable = {
        {text = "", width = 50}, --player portrait
        {text = "", width = 20}, --spec icon
        {text = "Player Name", width = 100},
        {text = "M+ Score", width = 100},
        {text = "Deaths", width = 100},
        {text = "Damage Taken", width = 100},
        {text = "DPS", width = 100},
        {text = "HPS", width = 100},
        {text = "Interrupts", width = 100},
        {text = "Dispels", width = 100},
        {text = "CC Casts", width = 100},
        {text = "Empty Space", width = 200},
    }
    local headerOptions = {
        padding = 2,
    }

    ---@type details_mythicbreakdown_headerframe
    local headerFrame = detailsFramework:CreateHeader(readyFrame, headerTable, headerOptions)
    headerFrame:SetPoint("topleft", readyFrame, "topleft", 5, headerY)
    headerFrame.lines = {}
    readyFrame.HeaderFrame = headerFrame

    do --mythic+ run data
		local textColor = {1, 0.8196, 0, 1}
		local textSize = 11

		--clock texture and icon to show the total time elapsed
		local elapsedTimeIcon = readyFrame:CreateTexture("$parentClockIcon", "artwork", nil, 2)
		elapsedTimeIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		elapsedTimeIcon:SetTexCoord(172/512, 235/512, 84/512, 147/512)
		readyFrame.ElapsedTimeIcon = elapsedTimeIcon

		local elapsedTimeText = readyFrame:CreateFontString("$parentClockText", "artwork", "GameFontNormal")
		elapsedTimeText:SetTextColor(1, 1, 1)
		detailsFramework:SetFontSize(elapsedTimeText, 11)
		elapsedTimeText:SetText("00:00")
		elapsedTimeText:SetPoint("left", elapsedTimeIcon, "right", 3, 0)
		readyFrame.ElapsedTimeText = elapsedTimeText

		--another clock texture and icon to show the wasted time (time out of combat)
		local outOfCombatIcon = readyFrame:CreateTexture("$parentClockIcon2", "artwork", nil, 2)
		outOfCombatIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		outOfCombatIcon:SetTexCoord(172/512, 235/512, 84/512, 147/512)
		outOfCombatIcon:SetVertexColor(detailsFramework:ParseColors("orangered"))
		readyFrame.OutOfCombatIcon = outOfCombatIcon

		local outOfCombatText = readyFrame:CreateFontString("$parentClockText2", "artwork", "GameFontNormal")
		outOfCombatText:SetTextColor(1, 1, 1)
		detailsFramework:SetFontSize(outOfCombatText, 11)
		detailsFramework:SetFontColor(outOfCombatText, "orangered")
		outOfCombatText:SetText("00:00")
		outOfCombatText:SetPoint("left", outOfCombatIcon, "right", 3, 0)
		readyFrame.OutOfCombatText = outOfCombatText

		--create the sandtime icon and a text to show the keystone level
		local sandTimeIcon = readyFrame:CreateTexture("$parentSandTimeIcon", "artwork", nil, 2)
		sandTimeIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		sandTimeIcon:SetTexCoord(81/512, 137/512, 83/512, 143/512)
		readyFrame.SandTimeIcon = sandTimeIcon

		local sandTimeText = readyFrame:CreateFontString("$parentSandTimeText", "artwork", "GameFontNormal")
		sandTimeText:SetTextColor(1, 1, 1)
		detailsFramework:SetFontSize(sandTimeText, 11)
		sandTimeText:SetText("0")
		sandTimeText:SetPoint("left", sandTimeIcon, "right", 1, 0)
		readyFrame.KeylevelText = sandTimeText

		--create a strong arm texture and a text to show the ranting of the player
		local strongArmIcon = readyFrame:CreateTexture("$parentStrongArmIcon", "artwork", nil, 2)
		strongArmIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		strongArmIcon:SetTexCoord(84/512, 145/512, 151/512, 215/512)
		readyFrame.StrongArmIcon = strongArmIcon

		local rantingLabel = detailsFramework:CreateLabel(readyFrame, "0", textSize, textColor)
		rantingLabel:SetPoint("left", strongArmIcon, "right", 3, 0)
		readyFrame.RantingLabel = rantingLabel

        local buttonSize = 24

        readyFrame.ElapsedTimeIcon:SetSize(buttonSize, buttonSize)
        readyFrame.OutOfCombatIcon:SetSize(buttonSize, buttonSize)
        readyFrame.ElapsedTimeIcon:SetPoint("bottomleft", headerFrame, "topleft", 50, 12)
        readyFrame.OutOfCombatIcon:SetPoint("left", readyFrame.ElapsedTimeIcon, "right", 70, 0)

        readyFrame.SandTimeIcon:SetSize(buttonSize, buttonSize) --original size is 32x60, need to adjust to the correct size
        readyFrame.SandTimeIcon:SetPoint("left", readyFrame.OutOfCombatIcon, "right", 70, 0)

        readyFrame.StrongArmIcon:SetSize(buttonSize, buttonSize)
        readyFrame.StrongArmIcon:SetPoint("left", readyFrame.SandTimeIcon, "right", 70, 0)
    end

    --create 6 rows to show data of the player, it only require 5 lines, the last one can be used on exception cases.
    for i = 1, lineAmount do
        mythicPlusBreakdown.CreateLineForBigBreakdownFrame(readyFrame, headerFrame, i)
    end

    return readyFrame
end

--this function get the overall mythic+ segment created after a mythic+ run has finished
--then it fill the lines with data from the overall segment
function mythicPlusBreakdown.RefreshBigBreakdownFrame()
    ---@type details_mythicbreakdown_bigframe
    local mainFrame = _G[mainFrameName]
    local headerFrame = mainFrame.HeaderFrame
    local lines = headerFrame.lines

    local mythicPlusOverallSegment = Details:GetCurrentCombat()
    local mythicPlusOverallSegment = Details:GetOverallCombat()
    local combatTime = mythicPlusOverallSegment:GetCombatTime()

    local damageContainer = mythicPlusOverallSegment:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
    local healingContainer = mythicPlusOverallSegment:GetContainer(DETAILS_ATTRIBUTE_HEAL)
    local utilityContainer = mythicPlusOverallSegment:GetContainer(DETAILS_ATTRIBUTE_MISC)

    local data = {}

    for actorIndex, actorObject in damageContainer:ListActors() do
        ---@cast actorObject actor
        if (actorObject:IsGroupPlayer()) then
            local unitId
            for i = 1, #Details222.UnitIdCache.Party do
                if (Details:GetFullName(Details222.UnitIdCache.Party[i]) == actorObject.nome) then
                    unitId = Details222.UnitIdCache.Party[i]
                end
            end
            unitId = unitId or actorObject.nome

            if (type(actorObject.mrating) == "table") then
                actorObject.mrating = actorObject.mrating.currentSeasonScore
            end

            local rating = actorObject.mrating or 0
            local ratingColor = C_ChallengeMode.GetDungeonScoreRarityColor(rating)
            if (not ratingColor) then
                ratingColor = _G["HIGHLIGHT_FONT_COLOR"]
            end

            local deathAmount = 0
            local deathTable = mythicPlusOverallSegment:GetDeaths()
            for i = 1, #deathTable do
                local thisDeathTable = deathTable[i]
                local playerName = thisDeathTable[3]
                if (playerName == actorObject.nome) then
                    deathAmount = deathAmount + 1
                end
            end

            ---@cast actorObject actordamage

            local thisPlayerData = {
                name = actorObject.nome,
                class = actorObject.classe,
                spec = actorObject.spec,
                role = actorObject.role or UnitGroupRolesAssigned(unitId),
                score = rating,
                scoreColor = ratingColor,
                deaths = deathAmount,
                damageTaken = actorObject.damage_taken,
                dps = actorObject.total / combatTime,
                hps = 0,
                interrupts = 0,
                interruptCasts = mythicPlusOverallSegment:GetInterruptCastAmount(actorObject.nome),
                dispels = 0,
                ccCasts = mythicPlusOverallSegment:GetCCCastAmount(actorObject.nome),
                unitId = unitId,
            }

            if (thisPlayerData.role == "NONE") then
                thisPlayerData.role = "DAMAGER"
            end

            data[#data+1] = thisPlayerData
        end
    end

    for actorIndex, actorObject in healingContainer:ListActors() do
        local playerData
        for i = 1, #data do
            if (data[i].name == actorObject.nome) then
                playerData = data[i]
                break
            end
        end

        if (playerData) then
            ---@cast actorObject actorheal
            playerData.hps = actorObject.total / combatTime
        end
    end

    for actorIndex, actorObject in utilityContainer:ListActors() do
        local playerData
        for i = 1, #data do
            if (data[i].name == actorObject.nome) then
                playerData = data[i]
                break
            end
        end

        if (playerData) then
            ---@cast actorObject actorutility
            playerData.interrupts = actorObject.interrupt or 0
            playerData.dispels = actorObject.dispell or 0
        end
    end

    table.sort(data, function(t1, t2) return t1.role > t2.role end)

    for i = 1, lineAmount do
        lines[i]:Hide()
    end

    for i = 1, lineAmount do
        local line = lines[i]
        local frames = line:GetFramesFromHeaderAlignment()
        local playerData = data[i]

        --reset the line contents
        for j = 1, 11 do
            local frame = frames[j]
            if (frame:GetObjectType() == "FontString") then
                frame:SetText("")

            elseif (frame:GetObjectType() == "Texture") then
                frame:SetTexture(nil)
            end
        end

        if (playerData) then
            line:Show()
            --dumpt(playerData)
            local playerPortrait = frames[1]
            local specIcon = frames[2]
            local playerName = frames[3]
            local playerScore = frames[4]
            local playerDeaths = frames[5]
            local playerDamageTaken = frames[6]
            local playerDps = frames[7]
            local playerHps = frames[8]
            local playerInterrupts = frames[9]
            local playerDispels = frames[10]
            local playerCcCasts = frames[11]
            local playerEmptyField = frames[12]

            SetPortraitTexture(playerPortrait.Portrait, playerData.unitId)
            local portraitTexture = playerPortrait.Portrait:GetTexture()
            if (not portraitTexture) then
                local class = playerData.class
                playerPortrait.Portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
                playerPortrait.Portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
            end

            local role = playerData.role
            if (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
                playerPortrait.RoleIcon:SetAtlas(GetMicroIconForRole(role), TextureKitConstants.IgnoreAtlasSize)
                playerPortrait.RoleIcon:Show()
            else
                playerPortrait.RoleIcon:Hide()
            end

            specIcon:SetTexture(select(4, GetSpecializationInfoByID(playerData.spec)))
            playerName:SetText(detailsFramework:RemoveRealmName(playerData.name))
            playerScore:SetText(playerData.score)
            playerScore:SetTextColor(playerData.scoreColor.r, playerData.scoreColor.g, playerData.scoreColor.b)
            playerDeaths:SetText(playerData.deaths)
            playerDamageTaken:SetText(Details:Format(math.floor(playerData.damageTaken)))
            playerDps:SetText(Details:Format(math.floor(playerData.dps)))
            playerHps:SetText(Details:Format(math.floor(playerData.hps)))
            playerInterrupts:SetText(math.floor(playerData.interrupts))
            playerInterrupts.InterruptCasts:SetText("(casts: " .. math.floor(playerData.interruptCasts) .. ")")
            playerDispels:SetText(math.floor(playerData.dispels))
            playerCcCasts:SetText(math.floor(playerData.ccCasts))
            playerEmptyField:SetText("")

            --colors
            local classColor = RAID_CLASS_COLORS[playerData.class]
            playerName:SetTextColor(classColor.r, classColor.g, classColor.b)
        end
    end
end

function mythicPlusBreakdown.CreateLineForBigBreakdownFrame(mainFrame, headerFrame, index)
    ---@type details_mythicbreakdown_line
    local line = CreateFrame("button", "$parentLine" .. index, mainFrame, "BackdropTemplate")
    detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

    local yPosition = -((index-1)*(lineHeight+1)) - 1
    line:SetPoint("topleft", headerFrame, "bottomleft", lineOffset, yPosition)
    line:SetSize(lineWidth, lineHeight)

    line:SetBackdrop(lineBackdrop)
    if (index % 2 == 0) then
        line:SetBackdropColor(unpack(lineColor1))
    else
        line:SetBackdropColor(unpack(lineColor2))
    end

    --player portrait
    local playerPortrait = mPlus.CreatePlayerPortrait(line, "$parentPortrait")
    playerPortrait.Portrait:SetSize(lineHeight-2, lineHeight-2)
    playerPortrait:SetSize(lineHeight-2, lineHeight-2)
    playerPortrait.RoleIcon:SetSize(18, 18)
    playerPortrait.RoleIcon:ClearAllPoints()
    playerPortrait.RoleIcon:SetPoint("bottomleft", playerPortrait.Portrait, "bottomright", -9, -2)

    --texture to show the specialization of the player
    local specIcon = line:CreateTexture(nil, "overlay")
    specIcon:SetSize(20, 20)

    --fontstring for the player name
    local playerName = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --fontstring for the player score
    local playerScore = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --fontstring for the player deaths
    local playerDeaths = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --fontstring for the player damage taken
    local playerDamageTaken = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --fontstring for the player dps
    local playerDps = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --fontstring for the player hps
    local playerHps = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --fontstring for the player interrupts
    local playerInterrupts = line:CreateFontString(nil, "overlay", "GameFontNormal")
    local playerInterruptsCasts = line:CreateFontString(nil, "overlay", "GameFontNormal")
    playerInterrupts.InterruptCasts = playerInterruptsCasts

    --fontstring for the player dispels
    local playerDispels = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --fontstring for the player cc casts
    local playerCcCasts = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --fontstring for the empty field
    local playerEmptyField = line:CreateFontString(nil, "overlay", "GameFontNormal")

    --add each widget create to the header alignment
    line:AddFrameToHeaderAlignment(playerPortrait)
    line:AddFrameToHeaderAlignment(specIcon)
    line:AddFrameToHeaderAlignment(playerName)
    line:AddFrameToHeaderAlignment(playerScore)
    line:AddFrameToHeaderAlignment(playerDeaths)
    line:AddFrameToHeaderAlignment(playerDamageTaken)
    line:AddFrameToHeaderAlignment(playerDps)
    line:AddFrameToHeaderAlignment(playerHps)
    line:AddFrameToHeaderAlignment(playerInterrupts)
    line:AddFrameToHeaderAlignment(playerDispels)
    line:AddFrameToHeaderAlignment(playerCcCasts)
    line:AddFrameToHeaderAlignment(playerEmptyField)

    line:AlignWithHeader(headerFrame, "left")

    --set the point of the interrupt casts
    local a, b, c, d, e = playerInterrupts:GetPoint(1)
    playerInterruptsCasts:SetPoint(a, b, c, d + 20, e)

    headerFrame.lines[index] = line

    return line
end

Loc["STRING_MYTHIC_PLUS_BREAKDOWN"] = "Mythic+ Breakdown"
