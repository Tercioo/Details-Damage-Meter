local addonName, Details222 = ...
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
local _ = nil
local detailsFramework = DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then

    --constants
    local WINDOW_WIDTH = 350
    local WINDOW_HEIGHT = 320

    --createRoundedPanel's title bar is positioned 4px from the top and is 16px tall,
    --so it occupies y=0 to y=-20 from the panel top. Its frame level is 9500 (always above tabs).
    local TITLEBAR_BOTTOM = 20

    --main rounded panel — provides the visual shell, title bar, and close button.
    local mainPanel = detailsFramework:CreateRoundedPanel(UIParent, "DetailsKeystoneSmallFrame", {
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
        use_titlebar = false,
        title = "M+ Keys",
        roundness = 3,
        color = {.09, .09, .09, 0.95},
        border_color = {.15, .15, .15, 0.9},
    })

    mainPanel:SetPoint("center", UIParent, "center", 0, 0)
    mainPanel:SetMovable(true)
    mainPanel:RegisterForDrag("LeftButton")
    mainPanel:SetClampedToScreen(true)
    mainPanel:SetResizable(true)
    mainPanel:SetResizeBounds(350, 200, 350, 700)

    mainPanel:Hide()

    local leftResizer, rightResizer = detailsFramework:CreateResizeGrips(mainPanel)
    leftResizer:SetScale(0.7)
    rightResizer:SetScale(0.7)
    leftResizer:Hide()
    --rightResizer:SetParent()

    local closeButton = CreateFrame("button", nil, mainPanel, "UIPanelCloseButton")
    closeButton:SetPoint("topright", mainPanel, "topright", -4, -4)
    C_Timer.After(0.1, function() --delay to ensure the button is fully loaded before skinning
        Details:SkinCloseButton(closeButton, mainPanel)
    end)

    --shows the compact M+ keystone window.
    function Details222.MythicKeys.OpenSmallKeysPanel()
        mainPanel:Show()
    end

    --allow dragging the title bar to reposition the panel.
    --the title bar close button already hides mainPanel when clicked (built-in behaviour).
    detailsFramework:MakeDraggable(mainPanel, Details.mythic_small_window_pos)

    --pre-create teleport buttons as children of mainPanel using InsecureActionButtonTemplate.
    --they must be created at load time (outside createOnDemandFunc and outside combat)
    --to avoid tainting the secure execution environment.
    local smallKeysTeleportButtons = {}
    for i = 1, 50 do
        local button = CreateFrame("button", nil, mainPanel, "InsecureActionButtonTemplate, BackdropTemplate")
        button:SetAttribute("type", "spell")
        button:RegisterForClicks("AnyDown")
        button:Hide()
        smallKeysTeleportButtons[i] = button
    end

    --pre-create one secure button per dungeon entry for the Teleports tab.
    --spell attributes are stamped at creation time and never change after that.
    local dungeonTeleportButtons = {}
    if LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO then
        for challengeMapId, mapInfo in pairs(LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO) do
            local spellId = mapInfo[7]
            if spellId and spellId > 0 then
                local button = CreateFrame("button", nil, mainPanel, "InsecureActionButtonTemplate, BackdropTemplate")
                button:SetAttribute("type", "spell")
                button:SetAttribute("spell", spellId)
                button:RegisterForClicks("AnyDown")
                button:Hide()
                dungeonTeleportButtons[challengeMapId] = button
            end
        end
    end

    --each tab uses createOnDemandFunc so its content is built the first time the tab is shown.
    local tabList = {
        {
            name = "Keys",
            text = "Keys",
            createOnDemandFunc = function(tabFrame, tabContainer, parent)
                tabFrame:EnableMouse(false)

                --constants
                local LINE_HEIGHT = 22
                local LINE_AMOUNT = 50
                local SCROLL_WIDTH = WINDOW_WIDTH - 8  --342px, 4px margin each side
                --initial visible lines based on default window height minus the title bar and button row
                local LINES_VISIBLE = math.floor((WINDOW_HEIGHT - TITLEBAR_BOTTOM - 26) / LINE_HEIGHT)

                --toggle this to true during development to display fake party data without needing
                --a real group or LibOpenRaid. Set to false before shipping.
                local USE_DUMMY_DATA = false

                --unitName, level, mapID, challengeMapID, classID, rating, mythicPlusMapID,
                --classIconTex, iconTexCoords, mapName, isInMyParty, isOnline, isGuildMember, specId
                local DUMMY_DATA = {
                    { "Tankmaster-Silvermoon",  18, 0, 375, 1,  3450, 375, [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]], nil, "Ara-Kara, City of Echoes",  1, true, false, 73  }, --prot Warrior
                    { "Healbot-Stormrage",      15, 0, 376, 2,  3100, 376, [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]], nil, "City of Threads",           1, true, false, 65  }, --holy Paladin
                    { "Frostmage-Area52",       12, 0, 377, 8,  2800, 377, [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]], nil, "The Stonevault",            1, true, false, 64  }, --frost Mage
                    { "Moonkin-Moonguard",      10, 0, 379, 11, 2300, 379, [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]], nil, "Grim Batol",               1, true, false, 102 }, --balance Druid
                    { "Havocblade-Argent",       8, 0, 380, 12, 1950, 380, [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]], nil, "The Dawnbreaker",          1, true, false, 577 }, --havoc DH
                }

                --x positions of each column within the line frame (line width = SCROLL_WIDTH-2 = 340)
                local X_ROLE_ICON = 2    --roleIcon  [2,  22]
                local X_SPEC_ICON = 24   --specIcon  [24, 44]
                local X_PLAYER_NAME = 46   --name text [46, ~126]  (truncated to 80px)
                local X_KEY_LEVEL = 132  --"+NN"     [132,~155]
                local X_DUNGEON_ICON = 160  --icon      [160,180]
                local X_DUNGEON_NAME = 183  --name text [183,~273] (truncated to 90px)
                --rating is right-anchored at -4

                --called by the scrollbox to render each visible line
                local refreshScrollLines = function(self, data, offset, totalLines)
                    for i = 1, totalLines do
                        local index = i + offset
                        local unitTable = data[index]
                        if (unitTable) then
                            local line = self:GetLine(i)
                            line:Show()

                            local unitName, level, _, challengeMapID, classID, rating, _, classIconTex, iconTexCoords, mapName, _, _, _, specId = unpack(unitTable)

                            --spec / class icon
                            if (specId and specId > 20) then
                                local specIconTex, L, R, T, B = Details:GetSpecIcon(specId, false)
                                line.specIcon:SetTexture(specIconTex)
                                line.specIcon:SetTexCoord(L, R, T, B)
                            elseif (classIconTex and iconTexCoords) then
                                line.specIcon:SetTexture(classIconTex)
                                local L, R, T, B = unpack(iconTexCoords)
                                line.specIcon:SetTexCoord(L + 0.02, R - 0.02, T + 0.02, B - 0.02)
                            end

                            --role icon
                            local unitRole = detailsFramework.UnitGroupRolesAssigned(unitName)
                            if (specId and specId > 20) then
                                local _, _, _, _, role = GetSpecializationInfoByID(specId)
                                if (role) then
                                    unitRole = role
                                end
                            end

                            if (unitRole == "DAMAGER") then
                                line.roleIcon:SetAtlas("GM-icon-role-dps")
                            elseif (unitRole == "HEALER") then
                                line.roleIcon:SetAtlas("GM-icon-role-healer")
                            elseif (unitRole == "TANK") then
                                line.roleIcon:SetAtlas("GM-icon-role-tank")
                            else
                                line.roleIcon:SetColorTexture(.1, .1, .1, .3)
                            end

                            --player name: class-colored, realm suffix stripped
                            local nameNoRealm = detailsFramework:RemoveRealmName(unitName)
                            line.playerNameText.text = detailsFramework:AddClassColorToText(nameNoRealm, detailsFramework.ClassIndexToFileName[classID])
                            detailsFramework:TruncateText(line.playerNameText, 80)

                            --keystone level
                            line.keystoneLevelText.text = level > 0 and (level) or ""

                            --dungeon icon
                            local challengeMapInfo = LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO and LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO[challengeMapID]
                            if (challengeMapInfo and challengeMapInfo[4]) then
                                line.dungeonIcon:SetTexture(challengeMapInfo[4])
                                line.dungeonIcon:Show()
                            else
                                line.dungeonIcon:SetTexture("")
                                line.dungeonIcon:Hide()
                            end

                            --dungeon name (strip "Dungeon: " prefix if present)
                            local shortMapName = mapName or ""
                            if (shortMapName:find(":")) then
                                shortMapName = shortMapName:match(":%s*(.+)") or shortMapName
                            end

                            line.dungeonNameText.text = shortMapName
                            detailsFramework:TruncateText(line.dungeonNameText, 100)

                            --M+ rating
                            line.ratingText.text = rating > 0 and Details:comma_value(rating) or ""

                            --teleport button: look up the spell from the challenge map info table
                            local teleportButton = line.teleportButton
                            teleportButton:Hide()
                            if (challengeMapInfo and challengeMapInfo[7] and not InCombatLockdown()) then
                                teleportButton:SetAttribute("spell", challengeMapInfo[7])
                                teleportButton.spellId = challengeMapInfo[7]
                                teleportButton:Show()
                            end
                        end
                    end
                end

                --factory called once per line by scrollBox:CreateLine()
                local createLineFunc = function(self, index)
                    local line = CreateFrame("frame", "$parentLine" .. index, self, "BackdropTemplate")
                    line:SetPoint("topleft", self, "topleft", 1, -((index - 1) * (LINE_HEIGHT + 1)) - 1)
                    line:SetSize(SCROLL_WIDTH - 2, LINE_HEIGHT)
                    line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
                    line:SetBackdropColor(.12, .12, .12, 0.6)

                    --teleport button: covers the whole line, triggers the dungeon teleport spell
                    local teleportButton = smallKeysTeleportButtons[index]
                    teleportButton:SetParent(line)
                    teleportButton:SetAllPoints(line)
                    teleportButton:SetFrameLevel(line:GetFrameLevel() + 1)

                    local roleIcon = line:CreateTexture(nil, "overlay")
                    roleIcon:SetSize(20, 20)
                    roleIcon:SetPoint("left", line, "left", X_ROLE_ICON, 0)

                    local specIcon = line:CreateTexture(nil, "overlay")
                    specIcon:SetSize(20, 20)
                    specIcon:SetPoint("left", line, "left", X_SPEC_ICON, 0)

                    local playerNameText = detailsFramework:CreateLabel(line, "")
                    detailsFramework:SetFontSize(playerNameText, 10)
                    playerNameText:SetPoint("left", line, "left", X_PLAYER_NAME, 0)

                    local keystoneLevelText = detailsFramework:CreateLabel(line, "")
                    detailsFramework:SetFontSize(keystoneLevelText, 10)
                    keystoneLevelText:SetPoint("left", line, "left", X_KEY_LEVEL, 0)

                    local dungeonIcon = line:CreateTexture(nil, "overlay")
                    dungeonIcon:SetSize(20, 20)
                    dungeonIcon:SetPoint("left", line, "left", X_DUNGEON_ICON, 0)

                    local dungeonNameText = detailsFramework:CreateLabel(line, "")
                    detailsFramework:SetFontSize(dungeonNameText, 9)
                    dungeonNameText:SetPoint("left", line, "left", X_DUNGEON_NAME, 0)

                    local ratingText = detailsFramework:CreateLabel(line, "")
                    detailsFramework:SetFontSize(ratingText, 10)
                    ratingText:SetPoint("right", line, "right", -4, 0)

                    line.roleIcon = roleIcon
                    line.specIcon = specIcon
                    line.playerNameText = playerNameText
                    line.keystoneLevelText = keystoneLevelText
                    line.dungeonIcon = dungeonIcon
                    line.dungeonNameText = dungeonNameText
                    line.ratingText = ratingText
                    line.teleportButton = teleportButton

                    return line
                end

                local scrollBox = detailsFramework:CreateScrollBox(
                    tabFrame,
                    "$parentKeysScrollBox",
                    refreshScrollLines,
                    {},
                    SCROLL_WIDTH,
                    LINES_VISIBLE * (LINE_HEIGHT + 1),
                    LINES_VISIBLE,
                    LINE_HEIGHT
                )
                scrollBox:SetPoint("topleft", tabFrame, "topleft", 4, -26)
                scrollBox:SetPoint("bottomright", tabFrame, "bottomright", 0, 20)
                scrollBox:SetBackdropBorderColor(0, 0, 0, 0)
                scrollBox:SetScript("OnSizeChanged", function(self)
                    local newAmount = math.floor(self:GetHeight() / LINE_HEIGHT)
                    if (newAmount < 1) then
                        newAmount = 1
                    end

                    if (newAmount > LINE_AMOUNT) then
                        newAmount = LINE_AMOUNT
                    end

                    self:SetNumFramesShown(newAmount)
                    self:Refresh()
                end)

                for i = 1, LINE_AMOUNT do
                    scrollBox:CreateLine(createLineFunc)
                end

                tabFrame.ScrollBox = scrollBox

                --build party-member-only data and push it into the scrollbox
                local refreshData = function()
                    if (USE_DUMMY_DATA) then
                        scrollBox:SetData(DUMMY_DATA)
                        scrollBox:Refresh()
                        return
                    end

                    local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
                    if (not openRaidLib) then
                        scrollBox:SetData({})
                        scrollBox:Refresh()
                        return
                    end

                    local keystoneData = openRaidLib.GetAllKeystonesInfo()
                    if (not keystoneData) then
                        scrollBox:SetData({})
                        scrollBox:Refresh()
                        return
                    end

                    local newData = {}

                    for unitName, keystoneInfo in pairs(keystoneData) do
                        if (UnitInParty(unitName) and (keystoneInfo.level > 0 or keystoneInfo.rating > 0)) then
                            local classId = keystoneInfo.classID
                            local classIcon = [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]]
                            local _, class = GetClassInfo(classId)
                            local specId = keystoneInfo.specID or 0

                            local mapName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.mythicPlusMapID)
                            if (not mapName) then
                                mapName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)
                            end

                            if (not mapName and keystoneInfo.mapID) then
                                mapName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.mapID)
                            end

                            mapName = mapName or ""

                            newData[#newData + 1] = {
                                unitName, --[1]  unit name
                                keystoneInfo.level, --[2]  keystone level
                                keystoneInfo.mapID, --[3]  map ID
                                keystoneInfo.challengeMapID, --[4]  challenge map ID
                                keystoneInfo.classID, --[5]  class ID
                                keystoneInfo.rating, --[6]  M+ rating
                                keystoneInfo.mythicPlusMapID, --[7]  mythic+ map ID
                                classIcon, --[8]  class icon texture
                                class and CLASS_ICON_TCOORDS[class], --[9]  icon tex coords
                                mapName, --[10] dungeon name
                                1, --[11] isInMyParty
                                true, --[12] isOnline
                                false, --[13] isGuildMember
                                specId, --[14] spec ID
                            }

                            if (#newData >= LINE_AMOUNT) then
                                break
                            end
                        end
                    end

                    scrollBox:SetData(newData)
                    scrollBox:Refresh()
                end

                --called automatically by the tab container each time this tab is selected
                tabFrame.RefreshOptions = refreshData
                tabFrame.titleText:Hide()
            end,
        },
        {
            name = "Teleports",
            text = "Teleports",
            createOnDemandFunc = function(tabFrame, tabContainer, parent)
                tabFrame:EnableMouse(false)

                --constants
                local LINE_HEIGHT = 30
                local SCROLL_WIDTH = WINDOW_WIDTH - 8
                local LINES_VISIBLE = math.floor((WINDOW_HEIGHT - TITLEBAR_BOTTOM - 26) / LINE_HEIGHT)

                --build a sorted list of dungeons that have a teleport spell
                local teleportData = {}
                if LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO then
                    for key, mapInfo in pairs(LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO) do
                        if mapInfo[7] and mapInfo[7] > 0 then
                            local entry = detailsFramework.table.copy({}, mapInfo)
                            entry[8] = C_SpellBook.IsSpellKnownOrInSpellBook(mapInfo[7])
                            teleportData[#teleportData + 1] = entry
                        end
                    end

                    table.sort(teleportData, function(a, b)
                        if a[8] ~= b[8] then
                            return a[8] and not b[8]
                        end
                        return (a[1] or "") < (b[1] or "")
                    end)
                end

                local lineCount = math.max(#teleportData, 1)
                local searchText = ""

                --filters teleportData by searchText and refreshes the scrollbox
                local refreshScrollData = function(scrollBox)
                    if searchText ~= "" then
                        local filteredData = {}
                        for index, mapInfo in ipairs(teleportData) do
                            local zoneName = (mapInfo[1] or ""):lower()
                            if zoneName:find(searchText, 1, true) then
                                filteredData[#filteredData + 1] = mapInfo
                            end
                        end

                        scrollBox:SetData(filteredData)
                    else
                        scrollBox:SetData(teleportData)
                    end

                    scrollBox:Refresh()
                end

                --renders each visible line, button attributes are already stamped, only visuals update
                local refreshTeleportLines = function(self, data, offset, totalLines)
                    for i = 1, totalLines do
                        local index = i + offset
                        local mapInfo = data[index]
                        if mapInfo then
                            local line = self:GetLine(i)
                            line:Show()
                            line.dungeonTexture:SetTexture(mapInfo[4])
                            line.dungeonNameText.text = mapInfo[1] or ""

                            if mapInfo[8] then
                                line.notLearnedBg:Hide()
                                line.dungeonTexture:SetAlpha(1)
                                line.dungeonNameText:SetAlpha(1)
                            else
                                line.notLearnedBg:SetColorTexture(1, .2, .2, 0.03)
                                line.notLearnedBg:Show()
                                line.dungeonTexture:SetAlpha(0.5)
                                line.dungeonNameText:SetAlpha(0.5)
                            end

                            if not InCombatLockdown() then
                                if line.button then
                                    line.button:ClearAllPoints()
                                end

                                local challengeMapId = mapInfo[2]
                                --teleport button covers the whole line, spell attribute was stamped at load time
                                if challengeMapId then
                                    local button = dungeonTeleportButtons[challengeMapId]
                                    if button then
                                        button:SetParent(line)
                                        button:ClearAllPoints()
                                        button:SetAllPoints(line)
                                        button:SetFrameLevel(line:GetFrameLevel() + 1)
                                        button:Show()
                                        line.button = button
                                    end
                                end
                            end
                        end
                    end
                end

                --called once per line; the teleport button is parented here using the sorted data index
                local createLineFunc = function(self, index)
                    local mapInfo = teleportData[index]
                    local challengeMapId = mapInfo and mapInfo[2]

                    local line = CreateFrame("frame", "$parentTeleportLine" .. index, self, "BackdropTemplate")
                    line:SetPoint("topleft", self, "topleft", 1, -((index - 1) * (LINE_HEIGHT + 1)) - 1)
                    line:SetSize(SCROLL_WIDTH - 2, LINE_HEIGHT)
                    line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
                    line:SetBackdropColor(.12, .12, .12, 0.6)

                    local notLearnedBg = line:CreateTexture(nil, "background")
                    notLearnedBg:SetAllPoints(line)
                    notLearnedBg:Hide()
                    line.notLearnedBg = notLearnedBg

                    local dungeonTexture = line:CreateTexture(nil, "artwork")
                    dungeonTexture:SetSize(LINE_HEIGHT - 2, LINE_HEIGHT - 2)
                    dungeonTexture:SetPoint("left", line, "left", 2, 0)

                    local dungeonNameText = detailsFramework:CreateLabel(line, "")
                    detailsFramework:SetFontSize(dungeonNameText, 10)
                    dungeonNameText:SetPoint("left", line, "left", LINE_HEIGHT + 4, 0)

                    line.dungeonTexture = dungeonTexture
                    line.dungeonNameText = dungeonNameText

                    return line
                end

                local scrollBox = detailsFramework:CreateScrollBox(
                    tabFrame,
                    "$parentTeleportsScrollBox",
                    refreshTeleportLines,
                    teleportData,
                    SCROLL_WIDTH,
                    LINES_VISIBLE * (LINE_HEIGHT + 1),
                    LINES_VISIBLE,
                    LINE_HEIGHT
                )

                for i = 1, lineCount do
                    scrollBox:CreateLine(createLineFunc)
                end

                --scrollbox is offset 50px from the top to leave room for the search box (26px) + margin
                scrollBox:SetPoint("topleft", tabFrame, "topleft", 4, -50)
                scrollBox:SetPoint("bottomright", tabFrame, "bottomright", 0, 20)
                scrollBox:SetBackdropBorderColor(0, 0, 0, 0)
                scrollBox:SetScript("OnSizeChanged", function(self)
                    local newAmount = math.floor(self:GetHeight() / LINE_HEIGHT)
                    if (newAmount < 1) then
                        newAmount = 1
                    end

                    if (newAmount > lineCount) then
                        newAmount = lineCount
                    end

                    self:SetNumFramesShown(newAmount)
                    self:Refresh()
                end)

                tabFrame.ScrollBox = scrollBox

                --search box anchored at the top of the tab area, above the scrollbox
                --declare before assignment so the closure captures the local, not the global
                local searchBox
                searchBox = detailsFramework:CreateSearchBox(tabFrame, function()
                    searchText = searchBox.text and searchBox.text:lower() or ""
                    refreshScrollData(scrollBox)
                end)
                searchBox:SetWidth(SCROLL_WIDTH - 8)
                searchBox:SetPoint("topleft", tabFrame, "topleft", 8, -28)

                --called automatically by the tab container each time this tab is selected
                tabFrame.RefreshOptions = function()
                    refreshScrollData(scrollBox)
                end
            end,
        },
        {
            name = "Alts",
            text = "Alts",
            createOnDemandFunc = function(tabFrame, tabContainer, parent)
                --build Alts tab content here
            end,
        },
        {
            name = "History",
            text = "History",
            createOnDemandFunc = function(tabFrame, tabContainer, parent)
                --build History tab content here
            end,
        },
    }

    --button layout: 4 × 75px + 3 × 2px gaps = 306px total.
    --to center in 350px: left margin = (350-306)/2 = 22px.
    --the tab container's internal title fontstring anchors at x=10, so button_x = 22-10 = 12.
    --y_offset=30 shifts the (empty) internal title to y=0, placing tab buttons at the very top
    --of the tab area (just below the rounded panel's title bar).
    local tabOptions = {
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT - TITLEBAR_BOTTOM,
        button_width = 75,
        button_height = 20,
        button_x = 12,
        button_y = 0,
        button_text_size = 10,
        button_selected_border_color = {1, 0.8, 0, 1},
        button_border_color = {0.2, 0.2, 0.2, 1},
        y_offset = 30,
        hide_click_label = true,
        can_move_parent = false,
    }

    --create the tab container as a child of mainPanel, filling the area below the title bar.
    --passing an empty title suppresses the internal 24pt title fontstring.
    local tabContainer = detailsFramework:CreateTabContainer(
        mainPanel, "", "DetailsKeystoneSmallTabContainer", tabList, tabOptions
    )
    tabContainer:EnableMouse(false)

    tabContainer:SetPoint("topleft", mainPanel, "topleft", 0, -TITLEBAR_BOTTOM)
    tabContainer:SetPoint("bottomright", mainPanel, "bottomright", 0, 0)

    Details222.MythicKeysSmall = {
        MainPanel = mainPanel,
        TabContainer = tabContainer,
    }

end

Details222.MythicKeys.ExpansionNames = {
    LE_EXPANSION_CLASSIC = Loc["LE_EXPANSION_CLASSIC"],
	LE_EXPANSION_BURNING_CRUSADE = Loc["LE_EXPANSION_BURNING_CRUSADE"],
	LE_EXPANSION_WRATH_OF_THE_LICH_KING = Loc["LE_EXPANSION_WRATH_OF_THE_LICH_KING"],
	LE_EXPANSION_CATACLYSM = Loc["LE_EXPANSION_CATACLYSM"],
	LE_EXPANSION_MISTS_OF_PANDARIA = Loc["LE_EXPANSION_MISTS_OF_PANDARIA"],
	LE_EXPANSION_WARLORDS_OF_DRAENOR = Loc["LE_EXPANSION_WARLORDS_OF_DRAENOR"],
	LE_EXPANSION_LEGION = Loc["LE_EXPANSION_LEGION"],
	LE_EXPANSION_BATTLE_FOR_AZEROTH = Loc["LE_EXPANSION_BATTLE_FOR_AZEROTH"],
	LE_EXPANSION_SHADOWLANDS = Loc["LE_EXPANSION_SHADOWLANDS"],
	LE_EXPANSION_DRAGONFLIGHT = Loc["LE_EXPANSION_DRAGONFLIGHT"],
	LE_EXPANSION_WAR_WITHIN = Loc["LE_EXPANSION_WAR_WITHIN"],
	LE_EXPANSION_MIDNIGHT = Loc["LE_EXPANSION_MIDNIGHT"],
}