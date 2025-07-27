
---@type details
local Details = Details
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework
local _

local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
if (not openRaidLib) then
    return
end

Details222.ArenaSummary = {
    arenaData = {},
}

local ArenaSummary = Details222.ArenaSummary

function Details:OpenArenaSummaryWindow()
    return ArenaSummary.OpenWindow()
end

function ArenaSummary.OpenWindow()
    if not ArenaSummary.window then
        ArenaSummary.window = ArenaSummary.CreateWindow()
    end

    if not ArenaSummary.window:IsShown() then
        ArenaSummary.window:Show()
    end

    --refresh the scroll area
    ArenaSummary.window.ArenaPlayersScroll:RefreshScroll()
end

local makePlayerTable = function(unitName, thisData)
    local playerTable = {
        name = unitName,
        role = thisData.role or "NONE",
        class = thisData.class or "UNKNOWN",
        guid = thisData.guid or "",
        isFriendly = thisData.isFriendly or false,
        finalHits = 0,
        dps = 0, --the average dps for this player
        hps = 0, --the average hps for this player
        realTimeDps = {}, --this table stores an array of numbers with the real time dps values per second
        realTimePeakDamage = 0, --the peak damage done in real time
    }
    return playerTable
end

--ARENA TICKER
local arenaTicker = function(tickerObject)
    local currentCombat = Details:GetCurrentCombat()
    local combatTime = currentCombat:GetCombatTime()

    --iterate among the arena players and update their data
    for unitName, playerData in pairs(Details222.ArenaSummary.arenaData.combatData.groupMembers) do
        -- Update playerData with new information
        local damageActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, unitName)
        if (damageActorObject) then
            playerData.dps = damageActorObject.total / combatTime
        end
        local healingActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_HEAL, unitName)
        if (healingActorObject) then
            playerData.hps = healingActorObject.total / combatTime
        end

        local currentDPS = Details.CurrentDps.GetCurrentDps(playerData.guid)
        playerData.realTimeDps[#playerData.realTimeDps + 1] = currentDPS or 0
        if (currentDPS and currentDPS > playerData.realTimePeakDamage) then
            playerData.realTimePeakDamage = currentDPS
        end
    end

    Details222.ArenaSummary.arenaData.dampening = C_Commentator.GetDampeningPercent()
end

function ArenaSummary.OnArenaStart()
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()

    Details222.ArenaSummary.arenaData = {
        combatData = {
            groupMembers = {},
        },
        arenaName = name,
        arenaMapId = instanceID,
        startTime = time(),
        dampening = 0,
        combatId = Details:GetCurrentCombat():GetCombatUID(),
    }

    --data already existing:
        --Details.arena_table [unitName] = {role = role}
        --Details.arena_enemies[enemyName] = "arena" .. i

        --Details.savedTimeCaptures table[] -> {timeDataName, callbackFunc, matrix, author, version, icon, bIsEnabled, do_not_save = no_save})
        --"Your Team Damage"
        --"Enemy Team Damage"
        --"Your Team Healing"
        --"Enemy Team Healing"

    --what need to be done:
    --1. create a table for each player in the arena
    for unitName, data in pairs(Details.arena_table) do
        print("ArenaSummary: Adding player " .. unitName)
        local thisData = detailsFramework.table.copy({}, data)
        thisData.isFriendly = true
        thisData.guid = UnitGUID(unitName) or ""
        thisData.class = select(2, UnitClass(unitName)) or "UNKNOWN"
        Details222.ArenaSummary.arenaData.combatData.groupMembers[unitName] = makePlayerTable(unitName, thisData)
    end
    --2. create a table for each enemy in the arena
    for enemyName, unitId in pairs(Details.arena_enemies) do
        print("ArenaSummary: Adding enemy " .. enemyName)
        local thisData = {
            role = "NONE",
            isFriendly = false,
            guid = UnitGUID(unitId) or "",
            class = select(2, UnitClass(unitId)) or "UNKNOWN"
        }
        Details222.ArenaSummary.arenaData.combatData.groupMembers[enemyName] = makePlayerTable(enemyName, thisData)
    end

    --signature: NewLooper(time: number, callback: function, loopAmount: number, loopEndCallback: function?, checkPointCallback: function?, ...: any): timer
    local time = 1
    local loopAmount = 0 --0 means infinite
    local loopEndCallback = function() end --called when the loop ends
    ArenaSummary.LoopTicker = detailsFramework.Schedules.NewLooper(time, arenaTicker, loopAmount, loopEndCallback)
end

---@class details : table
---@field arena_data_headers table
---@field arena_data_compressed table

---@class arena_playerinfo : table
---@field name string
---@field role string
---@field class string
---@field guid string
---@field isFriendly boolean
---@field finalHits number
---@field dps number
---@field hps number
---@field realTimeDps table<number>
---@field realTimePeakDamage number
---@field totalDamage number
---@field totalDamageTaken number
---@field totalHeal number
---@field totalHealTaken number
---@field totalDispels number
---@field totalInterrupts number
---@field totalInterruptsCasts number
---@field totalCrowdControlCasts number
---@field dispelWhat table<string, number>
---@field interruptWhat table<string, number>
---@field crowdControlSpells table<string, number>

function ArenaSummary.OnArenaEnd()
    if (ArenaSummary.LoopTicker) then
        ArenaSummary.LoopTicker:Cancel()
    end

    local currentCombat = Details:GetCurrentCombat()
    local combatTime = currentCombat:GetCombatTime()

    local actorContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

    --iterate among the arena players and update their data
    for unitName, playerInfo in pairs(Details222.ArenaSummary.arenaData.combatData.groupMembers) do
        -- Update playerInfo with new information
        ---@type actordamage
        local damageActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, unitName)
        if (damageActorObject) then
            playerInfo.dps = damageActorObject.total / combatTime
            playerInfo.totalDamage = damageActorObject.total
            playerInfo.totalDamageTaken = damageActorObject.damage_taken
        end
        ---@type actorheal
        local healingActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_HEAL, unitName)
        if (healingActorObject) then
            playerInfo.hps = healingActorObject.total / combatTime
            playerInfo.totalHeal = healingActorObject.total
            playerInfo.totalHealTaken = healingActorObject.healing_taken
        end

        local ccTotal = 0
        local ccUsed = {}

        if (Details:GetCoreVersion() < 166) then
            for spellName, casts in pairs(currentCombat:GetCrowdControlSpells(unitName)) do
                local spellInfo = C_Spell.GetSpellInfo(spellName)
                local spellId = spellInfo and spellInfo.spellID or openRaidLib.GetCCSpellIdBySpellName(spellName)
                if (spellId ~= 197214) then
                    ccUsed[spellName] = casts
                    ccTotal = ccTotal + casts
                end
            end
        else
            --at 166, Details! now uses the spellId instead of the spellName for crowd controls
            for spellId, casts in pairs(currentCombat:GetCrowdControlSpells(unitName)) do
                if (spellId ~= 197214) then
                    ccUsed[spellId] = casts
                    ccTotal = ccTotal + casts
                end
            end
        end

        ---@type actorutility
        local utilityActorObject = currentCombat:GetActor(DETAILS_ATTRIBUTE_MISC, unitName)
        if (utilityActorObject) then
            playerInfo.totalDispels = utilityActorObject.dispell
            playerInfo.totalInterrupts = utilityActorObject.interrupt
            playerInfo.totalInterruptsCasts = currentCombat:GetInterruptCastAmount(unitName)
            playerInfo.totalCrowdControlCasts = ccTotal
            playerInfo.dispelWhat = detailsFramework.table.copy({}, utilityActorObject.dispell_oque or {})
            playerInfo.interruptWhat = detailsFramework.table.copy({}, utilityActorObject.interrompeu_oque or {})
            playerInfo.crowdControlSpells = ccUsed
        end
    end

    Details222.ArenaSummary.arenaData.endTime = time()

    local arenaDataCompressed = Details.arena_data_compressed

    local thisArenaData = {
        combatId = Details222.ArenaSummary.arenaData.combatId,
        arenaName = Details222.ArenaSummary.arenaData.arenaName,
        arenaMapId = Details222.ArenaSummary.arenaData.arenaMapId,
        startTime = Details222.ArenaSummary.arenaData.startTime,
        endTime = Details222.ArenaSummary.arenaData.endTime,
        dampening = Details222.ArenaSummary.arenaData.dampening,
        combatData = Details222.ArenaSummary.arenaData.combatData,
        playerName = UnitName("player"),
        playerClass = select(2, UnitClass("player")),
        playerGuid = UnitGUID("player"),
    }

    local thisArenaDataCompressed = ArenaSummary.CompressArena(thisArenaData)

    table.insert(arenaDataCompressed, 1, thisArenaDataCompressed)

    local thisArenaHeader = {
        combatId = Details222.ArenaSummary.arenaData.combatId,
        arenaName = Details222.ArenaSummary.arenaData.arenaName,
        arenaMapId = Details222.ArenaSummary.arenaData.arenaMapId,
        startTime = Details222.ArenaSummary.arenaData.startTime,
        endTime = Details222.ArenaSummary.arenaData.endTime,
        playerName = UnitName("player"),
        playerClass = select(2, UnitClass("player")),
        playerGuid = UnitGUID("player"),
        groupMembers = {},
    }

    for unitName, playerData in pairs(Details222.ArenaSummary.arenaData.combatData.groupMembers) do
        thisArenaHeader.groupMembers[unitName] = playerData.class
    end

    table.insert(Details.arena_data_headers, 1, thisArenaHeader)
    print("ARENA HEADER ADDED amount:", #Details.arena_data_headers)
end

function ArenaSummary.CreateWindow()
    local posY = -35
    local maxLines = 10
    local lineHeight = 22
    local windowWidth = 900
    local windowHeight = 400
    local scrollWidth = windowWidth - 32
    local scrollHeight = 306

    local backdrop_color = {.2, .2, .2, 0.2}
    local backdrop_color_on_enter = {.8, .8, .8, 0.4}

    local window = detailsFramework:CreateSimplePanel(UIParent, windowWidth, windowHeight, "Arena Summary by Details!")
    window:SetPoint("center", UIParent, "center", 0, 0)
    window:SetFrameStrata("HIGH")
    window:SetFrameLevel(10)

    local arenaInfoText = window:CreateFontString("$parentArenaInfoText", "overlay", "GameFontNormal")
    arenaInfoText:SetText("")
    arenaInfoText:SetPoint("top", window, "top", 0, posY)
    window.ArenaInfoText = arenaInfoText
    detailsFramework:SetFontSize(arenaInfoText, 18)

    posY = posY - 28

    --header
		local headerTable = {
			{text = "", width = 20},
			{text = "Name", width = 120},
			{text = "Final Hits", width = 60},
			{text = "Peak Damage", width = 90},
			{text = "Dps", width = 60},
            {text = "Hps", width = 60},
            {text = "Dispels", width = 60},
            {text = "Interrupts", width = 70},
            {text = "CCs", width = 70},
		}

		local headerOptions = {
			padding = 2,
		}

		local header = detailsFramework:CreateHeader(window, headerTable, headerOptions)
		header:SetPoint("topleft", window, "topleft", 5, posY)

    --create a scroll area for the lines
        local refreshFunc = function(self, data, offset, totalLines) --~refresh
			local ToK = Details:GetCurrentToKFunction()

			for i = 1, totalLines do
				local index = i + offset
				local playerData = data[index]

				if (playerData) then
					local line = self:GetLine(i)

                    --set the data for the line
                    line.Icon:SetTexture("Interface\\ICONS\\" .. playerData.class) --use class icon as icon

                    local playerNameWithOutRealm = detailsFramework:RemoveRealmName(playerData.name)
                    line.PlayerName:SetText(playerNameWithOutRealm)
                    line.FinalHits:SetText(playerData.finalHits or 0)
                    line.PeakDamage:SetText(Details:Format(playerData.realTimePeakDamage or 0))
                    line.Dps:SetText(Details:Format(playerData.dps or 0))
                    line.Hps:SetText(Details:Format(playerData.hps or 0))
                    line.Dispels:SetText(playerData.totalDispels or 0)
                    line.Interrupts:SetText(playerData.totalInterrupts or 0)
                    line.CrowdControlSpells:SetText(playerData.totalCrowdControlCasts or 0)
                    --line.CrowdControlSpells:SetText(table.concat(detailsFramework.table.keys(playerData.crowdControlSpells), ", ") or "None")

                    if (playerData.isFriendly) then
                        line:SetBackdropColor(0.2, 0.8, 0.2, 0.2) --green for friendly players
                    else
                        line:SetBackdropColor(0.8, 0.2, 0.2, 0.2) --red for enemies
                    end
                end
            end
        end

        local lineOnEnter = function(self) --~onenter
            local r, g, b, a = self:GetBackdropColor()
            self:SetBackdropColor(r, g, b, a + 0.2) --increase the alpha to make it more visible
        end

        local lineOnLeave = function(self) --~onleave
            local r, g, b, a = self:GetBackdropColor()
            self:SetBackdropColor(r, g, b, a - 0.2) --decrease the alpha to make it less visible
        end

        local createLineFunc = function(self, index)
			local line = CreateFrame("button", "$parentLine" .. index, self,"BackdropTemplate")
			line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(lineHeight+1)) - 1)
			line:SetSize(scrollWidth - 2, lineHeight)

			line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor(unpack(backdrop_color))

			-- ~createline --~line
			detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

			line:SetScript("OnEnter", lineOnEnter)
			line:SetScript("OnLeave", lineOnLeave)

			--icon
			local icon = line:CreateTexture("$parentSpellIcon", "overlay")
			icon:SetSize(lineHeight - 2, lineHeight - 2)

			--player name
			local playerNameText = line:CreateFontString("$parentPlayerName", "overlay", "GameFontNormal")

            --final hits
            local finalHitsText = line:CreateFontString("$parentFinalHits", "overlay", "GameFontNormal")

            --peak damage
            local peakDamageText = line:CreateFontString("$parentPeakDamage", "overlay", "GameFontNormal")

            --dps
            local dpsText = line:CreateFontString("$parentDps", "overlay", "GameFontNormal")
            --hps
            local hpsText = line:CreateFontString("$parentHps", "overlay", "GameFontNormal")

            --peak healing
            local dispelsText = line:CreateFontString("$parentDispels", "overlay", "GameFontNormal")

            --interrupts
            local interruptsText = line:CreateFontString("$parentInterrupts", "overlay", "GameFontNormal")

            --crowd control spells
            local ccsText = line:CreateFontString("$parentCrowdControlSpells", "overlay", "GameFontNormal")

            local textSize = 10
            --use the framework to set the font size
            detailsFramework:SetFontSize(ccsText, textSize)
            detailsFramework:SetFontSize(interruptsText, textSize)
            detailsFramework:SetFontSize(dispelsText, textSize)
            detailsFramework:SetFontSize(hpsText, textSize)
            detailsFramework:SetFontSize(dpsText, textSize)
            detailsFramework:SetFontSize(peakDamageText, textSize)
            detailsFramework:SetFontSize(finalHitsText, textSize)
            detailsFramework:SetFontSize(playerNameText, textSize)


            line:AddFrameToHeaderAlignment(icon)
            line:AddFrameToHeaderAlignment(playerNameText)
            line:AddFrameToHeaderAlignment(finalHitsText)
            line:AddFrameToHeaderAlignment(peakDamageText)
            line:AddFrameToHeaderAlignment(dpsText)
            line:AddFrameToHeaderAlignment(hpsText)
            line:AddFrameToHeaderAlignment(dispelsText)
            line:AddFrameToHeaderAlignment(interruptsText)
            line:AddFrameToHeaderAlignment(ccsText)

            line:AlignWithHeader(header, "left")

            line.Icon = icon
            line.PlayerName = playerNameText
            line.FinalHits = finalHitsText
            line.PeakDamage = peakDamageText
            line.Dps = dpsText
            line.Hps = hpsText
            line.Dispels = dispelsText
            line.Interrupts = interruptsText
            line.CrowdControlSpells = ccsText

            return line
        end

        local arenaPlayersScroll = detailsFramework:CreateScrollBox(window, "$parentScroll", refreshFunc, {}, scrollWidth, scrollHeight, maxLines, lineHeight)
        arenaPlayersScroll:SetPoint("topleft", header, "bottomleft", 0, -5)
        window.ArenaPlayersScroll = arenaPlayersScroll

        detailsFramework:ReskinSlider(arenaPlayersScroll)

        function ArenaSummary.SetSelectedArenaIndex(index)
            Details.arena_data_index_selected = index
            arenaPlayersScroll:RefreshScroll()
        end

        function arenaPlayersScroll:RefreshScroll()
            local playersData = {}

            local arenaData = ArenaSummary.UncompressArena(Details.arena_data_index_selected)

            if (not arenaData) then
                print("ArenaSummary: No arena data found for index " .. Details.arena_data_index_selected)
                return
            end

            local playersInTheArena = arenaData.combatData.groupMembers
            --iterate through the players in the arena and create lines for them
            for unitName, playerData in pairs(playersInTheArena) do
                local thisPlayer = {
                    name = playerData.name or unitName,
                    role = playerData.role or "NONE",
                    class = playerData.class or "UNKNOWN",
                    guid = playerData.guid or "",
                    isFriendly = playerData.isFriendly or false,
                    finalHits = playerData.finalHits or 0,
                    dps = playerData.dps or 0,
                    hps = playerData.hps or 0,
                    realTimeDps = playerData.realTimeDps or {},
                    realTimePeakDamage = playerData.realTimePeakDamage or 0,
                    totalDamage = playerData.totalDamage or 0,
                    totalDamageTaken = playerData.totalDamageTaken or 0,
                    totalHeal = playerData.totalHeal or 0,
                    totalHealTaken = playerData.totalHealTaken or 0,
                    totalDispels = playerData.totalDispels or 0,
                    totalInterrupts = playerData.totalInterrupts or 0,
                    totalInterruptsCasts = playerData.totalInterruptsCasts or 0,
                    totalCrowdControlCasts = playerData.totalCrowdControlCasts or 0,
                    dispelWhat = detailsFramework.table.copy({}, playerData.dispelWhat or {}),
                    interruptWhat = detailsFramework.table.copy({}, playerData.interruptWhat or {}),
                    crowdControlSpells = detailsFramework.table.copy({}, playerData.crowdControlSpells or {}),
                }

                playersData[#playersData+1] = thisPlayer
            end

            arenaPlayersScroll:SetData(playersData)
            arenaPlayersScroll:Refresh()

            local elapsedTime = arenaData.endTime - arenaData.startTime
            window.ArenaInfoText:SetText(arenaData.arenaName .. " ".. detailsFramework:IntegerToTimer(elapsedTime) .. " - " .. arenaData.dampening .. "% Dampening")

        end

		--create lines
		for i = 1, maxLines do
			arenaPlayersScroll:CreateLine(createLineFunc)
		end

    return window
end

function ArenaSummary.UncompressArena(headerIndex)
    assert(type(headerIndex) == "number", "UncompressedArena(headerIndex): headerIndex must be a number.")
    assert(C_EncodingUtil, "C_EncodingUtil is nil")

    local compressedArenas = Details.arena_data_compressed

    local arenaData = compressedArenas[headerIndex]
    if (not arenaData) then
        print("not found arenaData for headerIndex: " .. headerIndex)
        return nil
    end

    local dataDecoded = C_EncodingUtil.DecodeBase64(arenaData)
    if (not dataDecoded) then
        print("UncompressedRun(headerIndex): C_EncodingUtil.DecodeBase64 failed")
        return nil
    end

    local dataDecompressed = C_EncodingUtil.DecompressString(dataDecoded, Enum.CompressionMethod.Deflate)
    if (not dataDecompressed) then
        print("UncompressedRun(headerIndex): C_EncodingUtil.DecompressString failed")
        return nil
    end

    local arenaInfo = C_EncodingUtil.DeserializeCBOR(dataDecompressed)
    if (not arenaInfo) then
        print("UncompressedRun(headerIndex): C_EncodingUtil.DeserializeCBOR failed")
        return nil
    end

    return arenaInfo
end

function ArenaSummary.CompressArena(arenaData)
    if (not arenaData) then
        --private.log("CompressRun: arenaData is nil")
        return false
    end

    assert(C_EncodingUtil, "C_EncodingUtil is nil")

    local dataSerialized = C_EncodingUtil.SerializeCBOR(arenaData)
    if (not dataSerialized) then
        --private.log("CompressRun: C_EncodingUtil.SerializeCBOR failed")
        return false
    end

    local dataCompressed = C_EncodingUtil.CompressString(dataSerialized, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
    if (not dataCompressed) then
        --private.log("CompressRun: C_EncodingUtil.CompressString failed")
        return false
    end

    local dataEncoded = C_EncodingUtil.EncodeBase64(dataCompressed)
    if (not dataEncoded) then
        --private.log("CompressRun: C_EncodingUtil.EncodeBase64 failed")
        return false
    end

    return dataEncoded
end