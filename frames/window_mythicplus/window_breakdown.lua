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
local headerY = -30
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

    detailsFramework:ApplyStandardBackdrop(readyFrame)
    detailsFramework:MakeDraggable(readyFrame)

    ---@type df_titlebar
    local titleBar = detailsFramework:CreateTitleBar(readyFrame, Loc["STRING_MYTHIC_PLUS_BREAKDOWN"])

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

            local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unitId)
            if (ratingSummary) then
                local rating = ratingSummary.currentSeasonScore or 0
                local color = C_ChallengeMode.GetDungeonScoreRarityColor(rating)
                if (not color) then
                    color = _G["HIGHLIGHT_FONT_COLOR"]
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
                    role = UnitGroupRolesAssigned(unitId),
                    score = rating,
                    scoreColor = color,
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
            local role = playerData.role
            if (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
                playerPortrait.RoleIcon:SetAtlas(GetMicroIconForRole(role), TextureKitConstants.IgnoreAtlasSize)
                playerPortrait.RoleIcon:Show()
            else
                playerPortrait.RoleIcon:Hide()
            end

            specIcon:SetTexture(select(4, GetSpecializationInfoByID(playerData.spec)))
            playerName:SetText(playerData.name)
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
