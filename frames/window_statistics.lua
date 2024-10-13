
--todo: need to fix this file after pre-patch

local Details = _G.Details
local DF = _G.DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")
local tocName, Details222 = ...
local _

--prefix used on sync statistics
local CONST_GUILD_SYNC = "GS"

local difficultyNames = {
    ["normal"] = true,
    ["heroic"] = true,
    ["mythic"] = true,
    ["raidfinder"] = true,
}

function Details:InitializeRaidHistoryWindow()
    local DetailsRaidHistoryWindow = CreateFrame("frame", "DetailsRaidHistoryWindow", UIParent,"BackdropTemplate")
    DetailsRaidHistoryWindow.Frame = DetailsRaidHistoryWindow
    DetailsRaidHistoryWindow.__name = Loc ["STRING_STATISTICS"]
    DetailsRaidHistoryWindow.real_name = "DETAILS_STATISTICS"
    DetailsRaidHistoryWindow.__icon = [[Interface\AddOns\Details\images\icons]]
    DetailsRaidHistoryWindow.__iconcoords = {278/512, 314/512, 43/512, 76/512}
    DetailsRaidHistoryWindow.__iconcolor = "DETAILS_STATISTICS_ICON"
    DetailsPluginContainerWindow.EmbedPlugin (DetailsRaidHistoryWindow, DetailsRaidHistoryWindow, true)

    function DetailsRaidHistoryWindow.RefreshWindow()
        Details:OpenRaidHistoryWindow()
        C_Timer.After(1, function()
            Details:OpenRaidHistoryWindow()
        end)
    end
end

function Details:OpenRaidHistoryWindow(raidName, bossEncounterId, difficultyId, playerRole, guildName, playerBase, playerName, historyType)
    if (type(raidName) == "table") then
        raidName = nil
    end
    if (guildName == "LeftButton") then
        guildName = nil
    end

    if (not DetailsRaidHistoryWindow or not DetailsRaidHistoryWindow.Initialized) then

        DetailsRaidHistoryWindow.Initialized = true

        local statisticsFrame = DetailsRaidHistoryWindow or CreateFrame("frame", "DetailsRaidHistoryWindow", UIParent, "BackdropTemplate")
        statisticsFrame:SetPoint("center", UIParent, "center")
        statisticsFrame:SetFrameStrata("HIGH")
        statisticsFrame:SetToplevel(true)

        statisticsFrame:SetMovable(true)
        statisticsFrame:SetWidth(850)
        statisticsFrame:SetHeight(500)
        table.insert(UISpecialFrames, "DetailsRaidHistoryWindow")

        function statisticsFrame.OpenDB()
            local db = Details222.storage.OpenRaidStorage()
            if (not db) then
                Details:Msg(Loc ["STRING_GUILDDAMAGERANK_DATABASEERROR"])
                return
            end
            return db
        end

        local db = statisticsFrame.OpenDB()
        if (not db) then
            return
        end

        statisticsFrame.Mode = 2

        DF:ApplyStandardBackdrop(statisticsFrame)

        --create title bar
        local titlebar = DF:CreateTitleBar(statisticsFrame, "Details! " .. Loc ["STRING_STATISTICS"])
        titlebar.CloseButton:SetScript("OnClick", function() statisticsFrame:GetParent():Hide() end)

--STRING_GUILDDAMAGERANK_TUTORIAL_DESC
--STRING_OPTIONS_CHART_CLOSE

        --background
        local background = statisticsFrame:CreateTexture("$parentBackgroundImage", "border")
        background:SetAlpha(0.3)
        background:SetPoint("topleft", statisticsFrame, "topleft", 6, -65)
        background:SetPoint("bottomright", statisticsFrame, "bottomright", -10, 28)

        --separate menu and main list
        local div = statisticsFrame:CreateTexture(nil, "artwork")
        div:SetTexture([[Interface\ACHIEVEMENTFRAME\UI-Achievement-MetalBorder-Left]])
        div:SetAlpha(0.1)
        div:SetPoint("topleft", statisticsFrame, "topleft", 180, -64)
        div:SetHeight(574)

        --select history or guild rank
        local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

        local selectKillTimeline = function()
            statisticsFrame.GuildRankCheckBox:SetValue(false)
            statisticsFrame.HistoryCheckBox:SetValue(true)
            statisticsFrame.Mode = 1
            statisticsFrame:Refresh()
            statisticsFrame.ReportButton:Hide()
        end

        local selectGuildRank = function()
            statisticsFrame.HistoryCheckBox:SetValue(false)
            statisticsFrame.GuildRankCheckBox:SetValue(true)
            statisticsFrame.select_player:Select(1, true)
            statisticsFrame.select_player2:Hide()
            statisticsFrame.select_player2_label:Hide()
            statisticsFrame.Mode = 2
            statisticsFrame:Refresh()
            statisticsFrame.ReportButton:Show()
        end

        --kill timeline
        local HistoryCheckBox, HistoryLabel = DF:CreateSwitch(statisticsFrame, selectKillTimeline, false, 18, 18, "", "", "HistoryCheckBox", nil, nil, nil, nil, Loc ["STRING_GUILDDAMAGERANK_SHOWHISTORY"], options_switch_template) --, options_text_template
        HistoryLabel:ClearAllPoints()
        HistoryCheckBox:ClearAllPoints()
        HistoryCheckBox:SetPoint("topleft", statisticsFrame, "topleft", 100, -34)
        HistoryLabel:SetPoint("left", HistoryCheckBox, "right", 2, 0)
        HistoryCheckBox:SetAsCheckBox()

        --guildrank
        local GuildRankCheckBox, GuildRankLabel = DF:CreateSwitch(statisticsFrame, selectGuildRank, true, 18, 18, "", "", "GuildRankCheckBox", nil, nil, nil, nil, Loc ["STRING_GUILDDAMAGERANK_SHOWRANK"], options_switch_template) --, options_text_template
        GuildRankLabel:ClearAllPoints()
        GuildRankCheckBox:ClearAllPoints()
        GuildRankCheckBox:SetPoint("topleft", statisticsFrame, "topleft", 240, -34)
        GuildRankLabel:SetPoint("left", GuildRankCheckBox, "right", 2, 0)
        GuildRankCheckBox:SetAsCheckBox()

        --guild sync
        local doGuildSync = function()
            statisticsFrame.RequestedAmount = 0
            statisticsFrame.DownloadedAmount = 0
            statisticsFrame.EstimateSize = 0
            statisticsFrame.DownloadedSize = 0
            statisticsFrame.SyncStartTime = time()

            Details222.storage.DBGuildSync()
            statisticsFrame.GuildSyncButton:Disable()

            if (not statisticsFrame.SyncTexture) then
                local workingFrame = CreateFrame("frame", nil, statisticsFrame, "BackdropTemplate")
                statisticsFrame.WorkingFrame = workingFrame
                workingFrame:SetSize(1, 1)
                statisticsFrame.SyncTextureBackground = workingFrame:CreateTexture(nil, "border")
                statisticsFrame.SyncTextureBackground:SetPoint("bottomright", statisticsFrame, "bottomright", -5, -1)
                statisticsFrame.SyncTextureBackground:SetTexture([[Interface\COMMON\StreamBackground]])
                statisticsFrame.SyncTextureBackground:SetSize(32, 32)

                statisticsFrame.SyncTextureCircle = workingFrame:CreateTexture(nil, "artwork")
                statisticsFrame.SyncTextureCircle:SetPoint("center", statisticsFrame.SyncTextureBackground, "center", 0, 0)
                statisticsFrame.SyncTextureCircle:SetTexture([[Interface\COMMON\StreamCircle]])
                statisticsFrame.SyncTextureCircle:SetSize(32, 32)

                statisticsFrame.SyncTextureGrade = workingFrame:CreateTexture(nil, "overlay")
                statisticsFrame.SyncTextureGrade:SetPoint("center", statisticsFrame.SyncTextureBackground, "center", 0, 0)
                statisticsFrame.SyncTextureGrade:SetTexture([[Interface\COMMON\StreamFrame]])
                statisticsFrame.SyncTextureGrade:SetSize(32, 32)

                local animationHub = DF:CreateAnimationHub(workingFrame)
                animationHub:SetLooping("Repeat")
                statisticsFrame.WorkingAnimation = animationHub

                local rotation = DF:CreateAnimation(animationHub, "ROTATION", 1, 3, -360)
                rotation:SetTarget(statisticsFrame.SyncTextureCircle)

                statisticsFrame.SyncText = workingFrame:CreateFontString(nil, "border", "GameFontNormal")
                statisticsFrame.SyncText:SetPoint("right", statisticsFrame.SyncTextureBackground, "left", 0, 0)
                statisticsFrame.SyncText:SetText("working")

                local endAnimationHub = DF:CreateAnimationHub(workingFrame, nil, function() workingFrame:Hide() end)
                DF:CreateAnimation(endAnimationHub, "ALPHA", 1, 0.5, 1, 0)
                statisticsFrame.EndAnimationHub = endAnimationHub
            end

            statisticsFrame.WorkingFrame:Show()
            statisticsFrame.WorkingAnimation:Play()

            C_Timer.NewTicker(10, function(self)
                if (not Details.LastGuildSyncReceived) then
                    statisticsFrame.GuildSyncButton:Enable()
                    statisticsFrame.EndAnimationHub:Play()

                elseif (Details.LastGuildSyncReceived+10 < GetTime()) then
                    statisticsFrame.GuildSyncButton:Enable()
                    statisticsFrame.EndAnimationHub:Play()
                    self:Cancel()
                end
            end)
        end

        local guildSyncButton = DF:CreateButton(statisticsFrame, doGuildSync, 130, 20, Loc ["STRING_GUILDDAMAGERANK_SYNCBUTTONTEXT"], nil, nil, nil, "GuildSyncButton", nil, nil, options_button_template, options_text_template)
        guildSyncButton:SetPoint("topright", statisticsFrame, "topright", -20, -34)
        guildSyncButton:SetIcon([[Interface\GLUES\CharacterSelect\RestoreButton]], 12, 12, "overlay", {0.2, .8, 0.2, .8}, nil, 4)

        --listen to comm events
        local eventListener = Details:CreateEventListener()

        function eventListener:OnCommReceived(event, length, prefix, playerName, realmName, detailsVersion, guildSyncID, data)
            if (prefix == CONST_GUILD_SYNC) then
                --print(event, length, prefix, playerName, realmName, detailsVersion, guildSyncID, data)

                --received a list of encounter IDs
                if (guildSyncID == "L") then

                --received one encounter table
                elseif (guildSyncID == "A") then
                    if (not statisticsFrame.RequestedAmount) then
                        --if the receiving player reloads, f.RequestedAmount is nil
                        return
                    end
                    statisticsFrame.DownloadedAmount = (statisticsFrame.DownloadedAmount or 0) + 1

                    --size = 1 byte per characters in the string
                    statisticsFrame.EstimateSize = length * statisticsFrame.RequestedAmount > statisticsFrame.EstimateSize and length * statisticsFrame.RequestedAmount or statisticsFrame.RequestedAmount
                    statisticsFrame.DownloadedSize = statisticsFrame.DownloadedSize + length
                    local downloadSpeed = statisticsFrame.DownloadedSize / (time() - statisticsFrame.SyncStartTime)

                    statisticsFrame.SyncText:SetText("working [downloading " .. statisticsFrame.DownloadedAmount .. "/" .. statisticsFrame.RequestedAmount .. ", " .. format("%.2f", downloadSpeed/1024) .. "Kbps]")
                end
            end
        end

        function eventListener:OnCommSent(event, length, prefix, playerName, realmName, detailsVersion, guildSyncID, missingIDs, arg8, arg9)
            if (prefix == CONST_GUILD_SYNC) then
                --print(event, length, prefix, playerName, realmName, detailsVersion, guildSyncID, missingIDs, arg8, arg9)

                --requested a list of encounters
                if (guildSyncID == "R") then

                --requested to download a selected list of encounter tables
                elseif (guildSyncID == "G") then
                    statisticsFrame.RequestedAmount = statisticsFrame.RequestedAmount + #missingIDs
                    statisticsFrame.SyncText:SetText("working [downloading " .. statisticsFrame.DownloadedAmount .. "/" .. statisticsFrame.RequestedAmount .. "]")
                end
            end
        end

        eventListener:RegisterEvent("COMM_EVENT_RECEIVED", "OnCommReceived")
        eventListener:RegisterEvent("COMM_EVENT_SENT", "OnCommSent")

        --report results
        function statisticsFrame.BuildReport()
            if (statisticsFrame.LatestResourceTable) then
                local reportFunc = function(IsCurrent, IsReverse, AmtLines)
                    local bossName = statisticsFrame.select_boss.label:GetText()
                    local bossDiff = statisticsFrame.select_diff.label:GetText()
                    local guildName = statisticsFrame.select_guild.label:GetText()
                    local reportTable = {"Details!: DPS Rank for: " .. (bossDiff or "") .. " " .. (bossName or "--x--x--") .. " <" .. (guildName or "") .. ">"}
                    local result = {}

                    for i = 1, AmtLines do
                        if (statisticsFrame.LatestResourceTable[i]) then
                            local playerName = statisticsFrame.LatestResourceTable[i][1]
                            playerName = playerName:gsub("%|c%x%x%x%x%x%x%x%x", "")
                            playerName = playerName:gsub("%|r", "")
                            playerName = playerName:gsub(".*%s", "")
                            table.insert(result, {playerName, statisticsFrame.LatestResourceTable[i][2]})
                        else
                            break
                        end
                    end

                    Details:FormatReportLines(reportTable, result)
                    Details:SendReportLines(reportTable)
                end

                Details:SendReportWindow(reportFunc, nil, nil, true)
            end
        end

        local reportButton = DF:CreateButton(statisticsFrame, statisticsFrame.BuildReport, 130, 20, Loc ["STRING_OPTIONS_REPORT_ANCHOR"]:gsub(":", ""), nil, nil, nil, "ReportButton", nil, nil, options_button_template, options_text_template)
        reportButton:SetPoint("right", guildSyncButton, "left", -2, 0)
        reportButton:SetIcon([[Interface\GLUES\CharacterSelect\RestoreButton]], 12, 12, "overlay", {0.2, .8, 0.2, .8}, nil, 4)

        --
        function statisticsFrame:SetBackgroundImage(encounterId)
            local instanceId = Details:GetInstanceIdFromEncounterId(encounterId)
            if (instanceId) then
                local file, L, R, T, B = Details:GetRaidBackground(instanceId)
                --print("file:", file)
                --can't get the image, looks to be restricted
                --[[
                if (file) then
                    background:SetTexture(file)
                    background:SetTexCoord(L, R, T, B)
                else
                    background:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                end
                --]]
                background:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            end
        end

        --window script handlers
        statisticsFrame:SetScript("OnMouseDown", function(self, button)
            if (self.isMoving) then
                return
            end
            if (button == "RightButton") then
                self:Hide()
            else
                self:StartMoving()
                self.isMoving = true
            end
        end)

        statisticsFrame:SetScript("OnMouseUp", function(self, button)
            if (self.isMoving and button == "LeftButton") then
                self:StopMovingOrSizing()
                self.isMoving = nil
            end
        end)

        statisticsFrame:SetScript("OnHide", function()
            --save latest shown state
            statisticsFrame.LatestSelection = statisticsFrame.LatestSelection or {}
            statisticsFrame.LatestSelection.Raid = DetailsRaidHistoryWindow.select_raid.value
            statisticsFrame.LatestSelection.Boss = DetailsRaidHistoryWindow.select_boss.value
            statisticsFrame.LatestSelection.Diff = DetailsRaidHistoryWindow.select_diff.value
            statisticsFrame.LatestSelection.Role = DetailsRaidHistoryWindow.select_role.value
            statisticsFrame.LatestSelection.Guild = DetailsRaidHistoryWindow.select_guild.value
            statisticsFrame.LatestSelection.PlayerBase = DetailsRaidHistoryWindow.select_player.value
            statisticsFrame.LatestSelection.PlayerName = DetailsRaidHistoryWindow.select_player2.value
        end)

        local dropdownWidth = 160
        local icon = [[Interface\FriendsFrame\battlenet-status-offline]]

        local difficultyList = {}
        local raidList = {}
        local bossList = {}
        local guildList = {}

        local sortAlphabetical = function(a,b) return a.value < b.value end

        local onSelect = function()
            if (statisticsFrame.Refresh) then
                statisticsFrame:Refresh()
            end
        end

        --select raid:
        local onRaidSelect = function(_, _, raid)
            Details.rank_window.last_raid = raid
            statisticsFrame:UpdateDropdowns(true)
            onSelect()
        end

        local buildRaidList = function()
            return raidList
        end

        local raidDropdown = DF:CreateDropDown(statisticsFrame, buildRaidList, 1, dropdownWidth, 20, "select_raid")
        local raidString = DF:CreateLabel(statisticsFrame, Loc ["STRING_GUILDDAMAGERANK_RAID"] .. ":", _, _, "GameFontNormal", "select_raid_label")
        raidDropdown:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        --select boss:
        local onSelectBoss = function(_, _, boss)
            onSelect()
        end

        local buildBossList = function()
            return bossList
        end

        local bossDropdown = DF:CreateDropDown(statisticsFrame, buildBossList, 1, dropdownWidth, 20, "select_boss")
        local bossString = DF:CreateLabel(statisticsFrame, Loc ["STRING_GUILDDAMAGERANK_BOSS"] .. ":", _, _, "GameFontNormal", "select_boss_label")
        bossDropdown:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        --select difficulty:
        local onDifficultySelect = function(_, _, diff)
            Details.rank_window.last_difficulty = diff
            onSelect()
        end

        local buildDifficultyList = function()
            return difficultyList
        end

        local difficultyDropdown = DF:CreateDropDown(statisticsFrame, buildDifficultyList, 1, dropdownWidth, 20, "select_diff")
        local difficultyString = DF:CreateLabel(statisticsFrame, Loc ["STRING_GUILDDAMAGERANK_DIFF"] .. ":", _, _, "GameFontNormal", "select_diff_label")
        difficultyDropdown:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        --select role:
        local onRoleSelect = function(_, _, role)
            onSelect()
        end

        local buildRoleList = function()
            return {
                {value = "DAMAGER", label = "Damager", icon = icon, onclick = onRoleSelect},
                {value = "HEALER", label = "Healer", icon = icon, onclick = onRoleSelect}
            }
        end

        local role_dropdown = DF:CreateDropDown (statisticsFrame, buildRoleList, 1, dropdownWidth, 20, "select_role")
        local role_string = DF:CreateLabel(statisticsFrame, Loc ["STRING_GUILDDAMAGERANK_ROLE"] .. ":", _, _, "GameFontNormal", "select_role_label")
        role_dropdown:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        --select guild:
        local onGuildSelect = function(_, _, guild)
            onSelect()
        end

        local buildGuildList = function()
            return guildList
        end

        local guildDropdown = DF:CreateDropDown(statisticsFrame, buildGuildList, 1, dropdownWidth, 20, "select_guild")
        local guildString = DF:CreateLabel(statisticsFrame, Loc ["STRING_GUILDDAMAGERANK_GUILD"] .. ":", _, _, "GameFontNormal", "select_guild_label")
        guildDropdown:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        --select playerbase:
        local onPlayerSelect = function(_, _, player)
            onSelect()
        end

        local buildPlayerList = function()
            return {
                {value = 1, label = Loc ["STRING_GUILDDAMAGERANK_PLAYERBASE_RAID"], icon = icon, onclick = onPlayerSelect},
                {value = 2, label = Loc ["STRING_GUILDDAMAGERANK_PLAYERBASE_INDIVIDUAL"], icon = icon, onclick = onPlayerSelect},
            }
        end

        local player_dropdown = DF:CreateDropDown(statisticsFrame, buildPlayerList, 1, dropdownWidth, 20, "select_player")
        local player_string = DF:CreateLabel(statisticsFrame, Loc ["STRING_GUILDDAMAGERANK_PLAYERBASE"] .. ":", _, _, "GameFontNormal", "select_player_label")
        player_dropdown:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        --select player:
        local onPlayer2Select = function(_, _, player)
            statisticsFrame.latest_player_selected = player
            statisticsFrame:BuildPlayerTable(player)
        end

        local buildPlayer2List = function()
            local encounterTable, guild, role = unpack(statisticsFrame.build_player2_data or {})
            local t = {}
            local alreadyListed = {}
            if (encounterTable) then
                for encounterIndex, encounter in ipairs(encounterTable) do
                    if (encounter.guild == guild) then
                        local roleTable = encounter [role]
                        for playerName, _ in pairs(roleTable) do
                            if (not alreadyListed [playerName]) then
                                table.insert(t, {value = playerName, label = playerName, icon = icon, onclick = onPlayer2Select})
                                alreadyListed [playerName] = true
                            end
                        end
                    end
                end
            end

            table.sort(t, sortAlphabetical)
            return t
        end

        local player2Dropdown = DF:CreateDropDown(statisticsFrame, buildPlayer2List, 1, dropdownWidth, 20, "select_player2")
        local player2String = DF:CreateLabel(statisticsFrame, Loc ["STRING_GUILDDAMAGERANK_PLAYERBASE_PLAYER"] .. ":", _, _, "GameFontNormal", "select_player2_label")
        player2Dropdown:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        local fillDifficultyDropdown = function(difficulty)
            --add the difficult to the dropdown
            if (difficulty == "normal") then
                local alreadyHave = false
                for i, t in ipairs(difficultyList) do
                    if (t.label == "Normal") then
                        alreadyHave = true
                    end
                end
                if (not alreadyHave) then
                    table.insert(difficultyList, 1, {value = difficulty, label = "Normal", icon = icon, onclick = onDifficultySelect})
                end

            elseif (difficulty == "heroic") then
                local alreadyHave = false
                for i, t in ipairs(difficultyList) do
                    if (t.label == "Heroic") then
                        alreadyHave = true
                    end
                end
                if (not alreadyHave) then
                    table.insert(difficultyList, 1, {value = difficulty, label = "Heroic", icon = icon, onclick = onDifficultySelect})
                end

            elseif (difficulty == "mythic") then
                local alreadyHave = false
                for i, t in ipairs(difficultyList) do
                    if (t.label == "Mythic") then
                        alreadyHave = true
                    end
                end
                if (not alreadyHave) then
                    table.insert(difficultyList, {value = difficulty, label = "Mythic", icon = icon, onclick = onDifficultySelect})
                end
            end
        end


        function statisticsFrame:UpdateDropdowns(bDoNotSelectRaid)
            local currentGuild = guildDropdown.value

            --wipe data
            Details:Destroy(difficultyList)
            Details:Destroy(bossList)
            Details:Destroy(raidList)
            Details:Destroy(guildList)

            local bossRepeated = {}
            local raidRepeated = {}
            local guildRepeated = {}

            local raidSelected = _G.DetailsRaidHistoryWindow.select_raid:GetValue()
            db = statisticsFrame.OpenDB()
            if (not db) then
                return
            end

            ---@cast db details_storage

            local playerGuildName = GetGuildInfo("player")

            for difficulty, encounterIdTable in pairs(db) do
                ---@cast difficulty details_raid_difficulties
                if (difficultyNames[difficulty]) then
                    ---@cast encounterIdTable table<encounterid, details_encounterkillinfo[]>
                    for dungeonEncounterID, encounterKillsTable in pairs(encounterIdTable) do
                        ---@cast encounterKillsTable details_encounterkillinfo[]
                        if (Details222.EJCache.IsCurrentContent(dungeonEncounterID)) then
                            if (not bossRepeated[dungeonEncounterID]) then
                                ---@type details_encounterinfo
                                local encounterInfo = Details:GetEncounterInfo(dungeonEncounterID)
                                ---@type details_instanceinfo
                                local instanceInfo = Details:GetInstanceInfo(encounterInfo and encounterInfo.instanceId)

                                if (encounterInfo and instanceInfo) then
                                    local instanceId = instanceInfo.instanceId
                                    if (raidSelected == instanceId) then
                                        table.insert(bossList, {value = dungeonEncounterID, label = encounterInfo.name, icon = encounterInfo.creatureIcon, onclick = onSelectBoss})
                                        bossRepeated[dungeonEncounterID] = true
                                    end

                                    if (not raidRepeated[instanceInfo.name]) then
                                        local instanceName = instanceInfo.name
                                        local raidIcon = instanceInfo.icon
                                        local raidIconCoords = instanceInfo.iconCoords

                                        table.insert(raidList, {value = instanceInfo.instanceId, label = instanceName, icon = raidIcon, texcoord = raidIconCoords, onclick = onRaidSelect})
                                        raidRepeated[instanceInfo.name] = true
                                    end
                                end
                            end

                            --add guild name to the dropdown
                            if (playerGuildName) then
                                if (not guildRepeated[playerGuildName]) then
                                    table.insert(guildList, {value = playerGuildName, label = playerGuildName, icon = icon, onclick = onGuildSelect})
                                    guildRepeated[playerGuildName] = true
                                end
                            else
                                for index, encounter in ipairs(encounterKillsTable) do
                                    local guild = encounter.guild
                                    if (not guildRepeated[guild]) then
                                        table.insert(guildList, {value = guild, label = guild, icon = icon, onclick = onGuildSelect})
                                        guildRepeated[guild] = true
                                    end
                                end
                            end

                            --add the difficult to the dropdown
                            fillDifficultyDropdown(difficulty)
                        end
                    end
                end
            end

            table.sort(bossList, function(t1, t2) return t1.label < t2.label end)

            difficultyDropdown:Refresh()
            guildDropdown:Refresh()

            if (not bDoNotSelectRaid) then
                raidDropdown:Refresh()
            end
            bossDropdown:Refresh()

            C_Timer.After(1, function()
                if (not bDoNotSelectRaid) then
                    raidDropdown:Select(1, true)
                end

                difficultyDropdown:Select(1, true)

                if (currentGuild) then
                    guildDropdown:Select(currentGuild)
                else
                    guildDropdown:Select(1, true)
                end

                bossDropdown:Select(1, true)
            end)
        end --end of UpdateDropdowns()

        function statisticsFrame.UpdateBossDropdown()
            local raidSelected = DetailsRaidHistoryWindow.select_raid:GetValue()
            local bossRepeated = {}
            Details:Destroy(bossList)
            Details:Destroy(difficultyList)

            for difficulty, encounterIdTable in pairs(db) do
                ---@cast difficulty details_raid_difficulties
                if (difficultyNames[difficulty]) then
                    ---@cast encounterIdTable table<encounterid, details_encounterkillinfo[]>
                    for dungeonEncounterID, encounterKillsTable in pairs(encounterIdTable) do
                        if (Details222.EJCache.IsCurrentContent(dungeonEncounterID)) then
                            if (not bossRepeated[dungeonEncounterID]) then
                                ---@type details_encounterinfo
                                local encounterInfo = Details:GetEncounterInfo(dungeonEncounterID)
                                ---@type details_instanceinfo
                                local instanceInfo = Details:GetInstanceInfo(encounterInfo and encounterInfo.instanceId)

                                if (encounterInfo and instanceInfo) then
                                    if (raidSelected == instanceInfo.instanceId) then
                                        table.insert(bossList, {value = dungeonEncounterID, label = encounterInfo.name, icon = encounterInfo.creatureIcon, onclick = onSelectBoss})
                                        bossRepeated[dungeonEncounterID] = true
                                    end
                                end
                            end

                            --add the difficult to the dropdown
                            fillDifficultyDropdown(difficulty)
                        end
                    end
                end
            end

            table.sort(bossList, function(t1, t2) return t1.label < t2.label end)
            bossDropdown:Refresh()
        end

        --anchors:
        raidString:SetPoint("topleft", statisticsFrame, "topleft", 10, -70)
        raidDropdown:SetPoint("topleft", statisticsFrame, "topleft", 10, -85)

        bossString:SetPoint("topleft", statisticsFrame, "topleft", 10, -110)
        bossDropdown:SetPoint("topleft", statisticsFrame, "topleft", 10, -125)

        difficultyString:SetPoint("topleft", statisticsFrame, "topleft", 10, -150)
        difficultyDropdown:SetPoint("topleft", statisticsFrame, "topleft", 10, -165)

        role_string:SetPoint("topleft", statisticsFrame, "topleft", 10, -190)
        role_dropdown:SetPoint("topleft", statisticsFrame, "topleft", 10, -205)

        guildString:SetPoint("topleft", statisticsFrame, "topleft", 10, -230)
        guildDropdown:SetPoint("topleft", statisticsFrame, "topleft", 10, -245)

        player_string:SetPoint("topleft", statisticsFrame, "topleft", 10, -270)
        player_dropdown:SetPoint("topleft", statisticsFrame, "topleft", 10, -285)

        player2String:SetPoint("topleft", statisticsFrame, "topleft", 10, -310)
        player2Dropdown:SetPoint("topleft", statisticsFrame, "topleft", 10, -325)
        player2String:Hide()
        player2Dropdown:Hide()

        ---@class details_stats_gframe_data
        ---@field text string
        ---@field value number
        ---@field utext string
        ---@field data details_storage_unitresult
        ---@field fulldate string
        ---@field elapsed number

        function statisticsFrame:BuildPlayerTable(thisPlayerName)
            local encounterTable, selectedGuildName, role = unpack(statisticsFrame.build_player2_data or {})
            ---@cast encounterTable details_encounterkillinfo[]

            ---@type details_stats_gframe_data[]
            local data = {}

            if (type(thisPlayerName) == "string" and string.len(thisPlayerName) > 1) then
                for encounterIndex, encounterKillInfo in ipairs(encounterTable) do
                    if (encounterKillInfo.guild == selectedGuildName) then
                        ---@type table<string, details_storage_unitresult>
                        local roleTable = encounterKillInfo[role]

                        local date = encounterKillInfo.date
                        date = date:gsub(".*%s", "")
                        date = date:sub(1, -4)

                        local playerTable = roleTable[thisPlayerName]
                        if (playerTable) then
                            table.insert(data, {text = date, value = playerTable.total, utext = Details:ToK2(playerTable.total/encounterKillInfo.elapsed), data = playerTable, fulldate = encounterKillInfo.date, elapsed = encounterKillInfo.elapsed})
                        end
                    end
                end

                --update graphic
                if (not statisticsFrame.gframe) then
                    local onenter = function(self)
                        GameCooltip:Reset()
                        GameCooltip:SetType("tooltip")
                        GameCooltip:Preset(2)

                        ---@type details_stats_gframe_data
                        local thisData = self.data

                        GameCooltip:AddLine("Total Done:", Details:ToK2(thisData.value), 1, "white")
                        GameCooltip:AddLine("Dps:", Details:ToK2(thisData.value / thisData.elapsed), 1, "white")
                        GameCooltip:AddLine("Item Level:", floor(thisData.data.itemLevel), 1, "white")
                        GameCooltip:AddLine("Date:", thisData.fulldate:gsub(".*%s", ""), 1, "white")

                        GameCooltip:SetOwner(self.ball.tooltip_anchor)
                        GameCooltip:Show()
                    end

                    local onleave = function(self)
                        GameCooltip:Hide()
                    end

                    statisticsFrame.gframe = DF:CreateGFrame(statisticsFrame, 650, 400, 35, onenter, onleave, "gframe", "$parentGF")
                    statisticsFrame.gframe:SetPoint("topleft", statisticsFrame, "topleft", 190, -65)
                end

                statisticsFrame.gframe:Reset()
                statisticsFrame.gframe:UpdateLines(data)
            end
        end

        local fillpanel = DF:NewFillPanel(statisticsFrame, {}, "$parentFP", "fillpanel", 710, 501, false, false, true, nil)
        fillpanel:SetPoint("topleft", statisticsFrame, "topleft", 195, -65)

        function statisticsFrame:BuildGuildRankTable(encounterKillsTable, selectedGuildName, role)
            local header = {
                {name = "Player Name", type = "text"},
                {name = "Per Second", type = "text"},
                {name = "Total", type = "text"},
                {name = "Length", type = "text"},
                {name = "Item Level", type = "text"},
                {name = "Date", type = "text"}
            }

            ---@cast encounterKillsTable details_encounterkillinfo[]

            --print(encounterTable, guild, role)
            --dumpt(encounterKillsTable) --encounterTable is empty at the first run when the panel is shown, coorect data after selecting a dropdown

            local players = {}
            local players_index = {}

            ---@type table<unitname, details_stats_playerinfo>
            local playerScore = {}

            ---@class details_stats_playerinfo
            ---@field total number
            ---@field ps number
            ---@field ilvl number
            ---@field date string
            ---@field class number
            ---@field length number

            --get the best of each player
            for encounterIndex, encounterKillInfo in ipairs(encounterKillsTable) do
                if (encounterKillInfo.guild == selectedGuildName) then
                    local roleTable = encounterKillInfo[role]

                    local date = encounterKillInfo.date
                    date = date:gsub(".*%s", "")
                    date = date:sub(1, -4)

                    ---@cast roleTable table<actorname, details_storage_unitresult>

                    for thisPlayerName, playerTable in pairs(roleTable) do
                        if (not playerScore[thisPlayerName]) then
                            playerScore[thisPlayerName] = {
                                total = 0,
                                ps = 0,
                                ilvl = 0,
                                date = "",
                                class = 0,
                                length = 0,
                            }
                        end

                        local total = playerTable.total
                        local dps = total / encounterKillInfo.elapsed

                        if (dps > playerScore[thisPlayerName].ps) then
                            playerScore[thisPlayerName].total = total
                            playerScore[thisPlayerName].ps = total / encounterKillInfo.elapsed
                            playerScore[thisPlayerName].ilvl = playerTable.itemLevel
                            playerScore[thisPlayerName].length = encounterKillInfo.elapsed
                            playerScore[thisPlayerName].date = date
                            playerScore[thisPlayerName].class = playerTable.classId
                        end
                    end
                end
            end

            local sortTable = {}
            for thisPlayerName, playerInfo in pairs(playerScore) do
                local className = select(2, GetClassInfo(playerInfo.class or 0))
                local classColor = "FFFFFFFF"
                if (className) then
                    classColor = RAID_CLASS_COLORS[className] and RAID_CLASS_COLORS[className].colorStr
                end

                local playerNameFormated = Details:GetOnlyName(thisPlayerName)
                table.insert(sortTable, {
                    "|c" .. classColor .. playerNameFormated .. "|r",
                    Details:ToK2(playerInfo.ps),
                    Details:ToK2(playerInfo.total),
                    DF:IntegerToTimer(playerInfo.length),
                    floor(playerInfo.ilvl),
                    playerInfo.date,
                    playerInfo.total,
                    playerInfo.ps,
                })
            end

            table.sort(sortTable, function(a, b) return a[8] > b[8] end)

            --add the number before the player name
            for i = 1, #sortTable do
                local t = sortTable [i]
                t[1] = i .. ". " .. t[1]
            end

            fillpanel:SetFillFunction(function(index) return sortTable [index] end)
            fillpanel:SetTotalFunction(function() return #sortTable end)
            fillpanel:UpdateRows(header)
            fillpanel:Refresh()

            statisticsFrame.LatestResourceTable = sortTable
        end

        ---@param encounterKillsTable details_encounterkillinfo[]
        ---@param selectedGuildName string
        ---@param role string
        function statisticsFrame:BuildRaidTable(encounterKillsTable, selectedGuildName, role)
            if (statisticsFrame.Mode == 2) then
                statisticsFrame:BuildGuildRankTable(encounterKillsTable, selectedGuildName, role)
                return
            end

            local header = {{name = "Player Name", type = "text"}} -- , width = 90
            local players = {}

            ---@type table<unitname, number>
            local playerIndex = {}

            ---@type table<unitname, number>
            local playerClassTable = {}

            local encounterAmount = 0

            for encounterIndex, encounterKillInfo in ipairs(encounterKillsTable) do
                if (encounterKillInfo.guild == selectedGuildName) then
                    ---@type table<actorname, details_storage_unitresult>
                    local roleTable = encounterKillInfo[role]

                    local date = encounterKillInfo.date
                    date = date:gsub(".*%s", "")
                    date = date:sub(1, -4)
                    encounterAmount = encounterAmount + 1

                    table.insert(header, {name = date, type = "text"})

                    for thisPlayerName, playerTable in pairs(roleTable) do
                        local index = playerIndex[thisPlayerName]

                        if (not index) then
                            local playerInfo = {thisPlayerName}
                            playerClassTable[thisPlayerName] = playerTable.classId
                            for i = 1, encounterAmount-1 do
                                table.insert(playerInfo, "")
                            end
                            table.insert(playerInfo, Details:ToK2(playerTable.total / encounterKillInfo.elapsed))
                            table.insert(players, playerInfo)
                            playerIndex[thisPlayerName] = #players
                        else
                            local player = players[index]
                            for i = #player+1, encounterAmount-1 do
                                table.insert(player, "")
                            end
                            table.insert(player, Details:ToK2(playerTable.total / encounterKillInfo.elapsed))
                        end

                    end
                end
            end

            --sort alphabetical
            table.sort(players, function(a, b) return a[1] < b[1] end)

            for index, playerTable in ipairs(players) do
                for i = #playerTable, encounterAmount do
                    table.insert(playerTable, "")
                end

                local className = select(2, GetClassInfo(playerClassTable[playerTable[1]] or 0))
                if (className) then
                    local playerNameFormated = Details:GetOnlyName(playerTable[1])
                    local classColor = RAID_CLASS_COLORS[className] and RAID_CLASS_COLORS[className].colorStr
                    playerTable [1] = "|c" .. classColor .. playerNameFormated .. "|r"
                end
            end

            fillpanel:SetFillFunction(function(index) return players [index] end)
            fillpanel:SetTotalFunction(function() return #players end)

            fillpanel:UpdateRows(header)

            fillpanel:Refresh()
            fillpanel:SetPoint("topleft", statisticsFrame, "topleft", 200, -65)
        end

        function statisticsFrame:Refresh(player_name) --called when any dropdown is selected
            --build the main table
            local diff = difficultyDropdown.value
            local boss = bossDropdown.value
            local role = role_dropdown.value
            local selectedGuildName = guildDropdown.value
            local player = player_dropdown.value

            ---@type table<number, details_encounterkillinfo[]>
            local encounterIdTable = db[diff]

            statisticsFrame:SetBackgroundImage(boss)

--[=[                if (difficultyNames[difficulty]) then
                    ---@cast encounterIdTable table<encounterid, details_encounterkillinfo[]>
                    for dungeonEncounterID, encounterKillsTable in pairs(encounterIdTable) do
                        if (Details222.EJCache.IsCurrentContent(dungeonEncounterID)) then
                            if (not bossRepeated[dungeonEncounterID]) then
                                ---@type details_encounterinfo
                                local encounterInfo = Details:GetEncounterInfo(dungeonEncounterID)
                                ---@type details_instanceinfo
                                local instanceInfo = Details:GetInstanceInfo(encounterInfo and encounterInfo.instanceId)
]=]


            if (encounterIdTable) then
                local encounterKillsTable = encounterIdTable[boss]
                if (encounterKillsTable) then
                    if (player == 1) then --raid
                        fillpanel:Show()

                        if (statisticsFrame.gframe) then
                            statisticsFrame.gframe:Hide()
                        end

                        player2String:Hide()
                        player2Dropdown:Hide()
                        statisticsFrame:BuildRaidTable(encounterKillsTable, selectedGuildName, role) --calling here

                    elseif (player == 2) then --only one player
                        fillpanel:Hide()

                        if (statisticsFrame.gframe) then
                            statisticsFrame.gframe:Show()
                        end

                        player2String:Show()
                        player2Dropdown:Show()
                        statisticsFrame.build_player2_data = {encounterKillsTable, selectedGuildName, role}
                        player2Dropdown:Refresh()

                        player_name = statisticsFrame.latest_player_selected or player_name

                        if (player_name) then
                            player2Dropdown:Select(player_name)
                        else
                            player2Dropdown:Select(1, true)
                        end

                        statisticsFrame:BuildPlayerTable (player2Dropdown.value)
                    end
                else
                    if (player == 1) then --raid
                        fillpanel:Show()
                        if (statisticsFrame.gframe) then
                            statisticsFrame.gframe:Hide()
                        end
                        player2String:Hide()
                        player2Dropdown:Hide()
                        statisticsFrame:BuildRaidTable({}, selectedGuildName, role)

                    elseif (player == 2) then --only one player
                        fillpanel:Hide()
                        if (statisticsFrame.gframe) then
                            statisticsFrame.gframe:Show()
                        end
                        player2String:Show()
                        player2Dropdown:Show()
                        statisticsFrame.build_player2_data = {{}, selectedGuildName, role}
                        player2Dropdown:Refresh()
                        player2Dropdown:Select(1, true)
                        statisticsFrame:BuildPlayerTable (player2Dropdown.value)
                    end
                end
            end
        end

        statisticsFrame.FirstRun = true
    end --end of DetailsRaidHistoryWindow creation

    local statsWindow = _G.DetailsRaidHistoryWindow

    --table means some button send the request - nil for other ways
        if (type(raidName) == "table" or (not raidName and not bossEncounterId and not difficultyId and not playerRole and not guildName and not playerBase and not playerName)) then
            local f = statsWindow
            if (f.LatestSelection) then
                raidName = f.LatestSelection.Raid
                bossEncounterId = f.LatestSelection.Boss
                difficultyId = f.LatestSelection.Diff
                playerRole = f.LatestSelection.Role
                guildName = f.LatestSelection.Guild
                playerBase = f.LatestSelection.PlayerBase
                playerName = f.LatestSelection.PlayerBase
            end
        end

    if (statsWindow.FirstRun) then
        if (type(Details.rank_window.last_difficulty) == "number") then
            Details.rank_window.last_difficulty = "normal"
        end
        difficultyId = Details.rank_window.last_difficulty or difficultyId

        if (IsInGuild()) then
            local guildName = GetGuildInfo("player")
            if (guildName) then
                guildName = guildName
            end
        end

        if (Details.rank_window.last_raid ~= "") then
            raidName = Details.rank_window.last_raid or raidName
        end
    end

    if (not statsWindow.UpdateDropdowns) then
        Details:Msg("Failled to load statistics, Details! Storage is disabled?")
        return
    end

    statsWindow:UpdateDropdowns()
    statsWindow:Refresh()
    statsWindow:Show()

    if (historyType == 1 or historyType == 2) then
        statsWindow.Mode = historyType
        if (statsWindow.Mode == 1) then
            --overall
            statsWindow.HistoryCheckBox:SetValue(true)
            statsWindow.GuildRankCheckBox:SetValue(false)
        elseif (statsWindow.Mode == 2) then
            --guild rank
            statsWindow.GuildRankCheckBox:SetValue(true)
            statsWindow.HistoryCheckBox:SetValue(false)
        end
    end

    print("raidName", raidName)
    print("bossEncounterId", bossEncounterId)
    print("difficultyId", difficultyId)
    print("playerRole", playerRole)
    print("guildName", guildName)
    print("playerBase", playerBase)
    print("playerName", playerName)

    if (raidName) then
        statsWindow.select_raid:Select(raidName)
        statsWindow:Refresh()
        statsWindow.UpdateBossDropdown()
    end

    if (bossEncounterId) then
        statsWindow.select_boss:Select(bossEncounterId)
        statsWindow:Refresh()
    end

    if (difficultyId) then
        statsWindow.select_diff:Select(difficultyId)
        statsWindow:Refresh()
    end

    if (playerRole) then
        statsWindow.select_role:Select(playerRole)
        statsWindow:Refresh()
    end

    if (guildName) then
        if (type(guildName) == "boolean") then
            guildName = GetGuildInfo("player")
        end
        statsWindow.select_guild:Select(guildName)
        statsWindow:Refresh()
    end

    if (playerBase) then
        statsWindow.select_player:Select(playerBase)
        statsWindow:Refresh()
    end

    if (playerName) then
        statsWindow.select_player2:Refresh()
        statsWindow.select_player2:Select(playerName)
        statsWindow:Refresh(playerName)
    end

    DetailsPluginContainerWindow.OpenPlugin(statsWindow)
end
