local addonName, Details222 = ...
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
local _ = nil
local detailsFramework = DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
    local eventFrame = CreateFrame("frame")
    eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
    eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
    eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")

    eventFrame.isCasting = false

    --forward-declared; assigned after mainPanel exists. captured by the OnEvent closure below.
    local castOverlay
    local castTimeBar

    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_SPELLCAST_START" then
            local _, _, spellId = ...
            if LIB_OPEN_RAID_MYTHIC_PLUS_TELEPORT_SPELLS[spellId] then
                --confirmed that this cast is a teleport spell
                --the next interrupted or succeeded event, indicate the cast stop
                self.isCasting = true

                local spellInfo = C_Spell.GetSpellInfo(spellId)
                castTimeBar:SetIcon(spellInfo.iconID)
                castTimeBar:SetLeftText(spellInfo.name)

                castOverlay:Show()
                castTimeBar:SetTimer(10, true)
            end

        elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_SUCCEEDED" or event == "UNIT_SPELLCAST_FAILED" then
            if self.isCasting then
                self.isCasting = false
                castTimeBar:StopTimer()
                castOverlay:Hide()
            end
        end
    end)

    --constants
    local WINDOW_WIDTH = 350
    local WINDOW_HEIGHT = 320

    --use_titlebar is false, so there's no internal title bar reserve. The corner curve
    --is roundness=3, so 4px from the top puts the tab buttons right at the curve.
    local TITLEBAR_BOTTOM = 4

    --row background tints used by the Keys tab to mark group membership of each keystone
    --holder. priority blue > orange > green; blue and orange can't both apply because they
    --branch on IsInRaid(). {r, g, b, a}.
    local LINE_COLOR_PARTY = {0.05, 0.10, 0.65, 0.6}  --dark blue
    local LINE_COLOR_RAID = {0.6, 0.18, 0.05, 0.6}   --dark orange
    local LINE_COLOR_GUILD = {0.30, 0.45, 0.30, 0.5}  --washed-out green

    --main rounded panel — provides the visual shell, title bar, and close button.
    --alpha is 1.0 so the empty top/bottom strips don't read as more transparent than the row area.
    local mainPanel = detailsFramework:CreateRoundedPanel(UIParent, "DetailsKeystoneSmallFrame", {
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
        use_titlebar = false,
        title = "M+ Keys",
        roundness = 3,
        color = {.09, .09, .09, 1.0},
        border_color = {.15, .15, .15, 0.9},
    })

    mainPanel:SetPoint("center", UIParent, "center", 0, 0)
    mainPanel:SetMovable(true)
    mainPanel:RegisterForDrag("LeftButton")
    mainPanel:SetClampedToScreen(true)
    mainPanel:SetResizable(true)
    mainPanel:SetResizeBounds(350, 200, 350, 700)

    mainPanel:Hide()

    --cast feedback overlay anchored to the bottom of mainPanel.
    --shows a 10s timebar while the player casts a dungeon teleport spell;
    --hidden as soon as UNIT_SPELLCAST_SUCCEEDED/FAILED/INTERRUPTED fires.
    --castOverlay/castTimeBar are forward-declared at the top of the block.
    castOverlay = CreateFrame("frame", nil, mainPanel, "BackdropTemplate")
    castOverlay:SetHeight(30)
    castOverlay:SetPoint("bottomleft", mainPanel, "bottomleft", 0, 0)
    castOverlay:SetPoint("bottomright", mainPanel, "bottomright", 0, 0)
    --tabContainer reaches the bottom of mainPanel and its scrollbox rows render in the
    --overlay area. raising strata (not just frame level) guarantees the bar sits above
    --every row regardless of the level math inside the tab/scrollbox hierarchy.
    castOverlay:SetFrameStrata("HIGH")
    detailsFramework:ApplyStandardBackdrop(castOverlay)
    castOverlay:Hide()

    castTimeBar = detailsFramework:CreateTimeBar(castOverlay, nil, nil, 22)
    castTimeBar:SetPoint("left", castOverlay, "left", 4, 0)
    castTimeBar:SetPoint("right", castOverlay, "right", -4, 0)
    castTimeBar:ShowTimer(true)

    --use_default_scripts = false: the DF default OnMouseDown calls parent:StartSizing,
    --which snaps the resized corner to the cursor position on click. Since the grip is
    --32x32 anchored at the corner (extending up-left), the cursor is almost never exactly
    --on the corner, so the panel "jumps" by that offset just from clicking. We attach
    --our own scripts below that track the cursor delta instead.
    local leftResizer, rightResizer = detailsFramework:CreateResizeGrips(mainPanel, {use_default_scripts = false})
    leftResizer:SetScale(0.7)
    rightResizer:SetScale(0.7)
    leftResizer:Hide()

    local MIN_RESIZE_H, MAX_RESIZE_H = 200, 700
    rightResizer:SetScript("OnMouseDown", function(self)
        local _, cursorY = GetCursorPosition()
        self.startCursorY = cursorY
        self.startHeight = mainPanel:GetHeight()

        --re-anchor to topleft so SetHeight grows only the bottom edge. With a center
        --anchor, the frame expands both up and down from its midpoint and the top edge
        --drifts upward while the user drags the bottom.
        local top, left = mainPanel:GetTop(), mainPanel:GetLeft()
        if (top and left) then
            mainPanel:ClearAllPoints()
            mainPanel:SetPoint("topleft", UIParent, "bottomleft", left, top)
        end

        self:SetScript("OnUpdate", function(grip)
            local _, y = GetCursorPosition()
            local scale = mainPanel:GetEffectiveScale()
            --cursor y increases upward in WoW, so moving the cursor down (y decreases)
            --should make the panel taller; (startY - y) is the downward delta.
            local newHeight = grip.startHeight + (grip.startCursorY - y) / scale

            if (newHeight < MIN_RESIZE_H) then
                newHeight = MIN_RESIZE_H
            end

            if (newHeight > MAX_RESIZE_H) then
                newHeight = MAX_RESIZE_H
            end

            mainPanel:SetHeight(newHeight)
        end)
    end)
    rightResizer:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    local closeButton = CreateFrame("button", nil, mainPanel, "UIPanelCloseButton")
    closeButton:SetPoint("topright", mainPanel, "topright", -4, -4)
    C_Timer.After(0.1, function() --delay to ensure the button is fully loaded before skinning
        Details:SkinCloseButton(closeButton, mainPanel)
    end)

    --button to request keystone data from guild + group; positioned at the bottom-left.
    --mirrors the request-from-guild button on the full keystone window.
    local requestFromGuildButton = detailsFramework:CreateButton(mainPanel, function()
        local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
        if (not openRaidLib) then
            return
        end

        local guildName = GetGuildInfo("player")
        if (guildName) then
            if (C_GuildInfo and C_GuildInfo.GuildRoster) then
                C_GuildInfo.GuildRoster()
            end
            openRaidLib.RequestKeystoneDataFromGuild()
        end

        if (IsInRaid()) then
            openRaidLib.RequestKeystoneDataFromRaid()
        elseif (IsInGroup()) then
            openRaidLib.RequestKeystoneDataFromParty()
        end
    end, 22, 18, REFRESH)
    requestFromGuildButton:SetPoint("bottomleft", mainPanel, "bottomleft", 28, 2)
    requestFromGuildButton:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
    requestFromGuildButton:SetIcon("UI-RefreshButton", 14, 14, "overlay", {0, 1, 0, 1}, "lawngreen")
    requestFromGuildButton:SetFrameLevel(mainPanel:GetFrameLevel() + 100)
    requestFromGuildButton.tooltip = Loc["STRING_KEYSTONE_REQUEST_FROM_GUILD"]
    mainPanel.RequestFromGuildButton = requestFromGuildButton

    --shows the compact M+ keystone window.
    function Details222.MythicKeys.OpenSmallKeysPanel()
        mainPanel:Show()
        --auto-request keys from guild on first open or after 60 seconds (matches the full window)
        local guildName = GetGuildInfo("player")
        if (guildName) then
            if (not mainPanel.lastGuildRequest or GetTime() - mainPanel.lastGuildRequest > 60) then
                mainPanel.lastGuildRequest = GetTime()
                mainPanel.RequestFromGuildButton:Click()
            end
        end
    end

    --allow dragging the title bar to reposition the panel.
    --the title bar close button already hides mainPanel when clicked (built-in behaviour).
    detailsFramework:MakeDraggable(mainPanel, Details.mythic_small_window_pos)

    --when the group composition changes while the panel is open, re-request keystone data
    --from the new party/raid members. Without this, you have to /reload (or close and reopen
    --the panel) before keys from people who joined after the panel opened actually appear.
    mainPanel:SetScript("OnEvent", function(self, event)
        if (event == "GROUP_ROSTER_UPDATE") then
            --throttle: GROUP_ROSTER_UPDATE fires repeatedly on a single join/leave
            if (self.lastGroupRequest and GetTime() - self.lastGroupRequest < 3) then
                return
            end
            self.lastGroupRequest = GetTime()
            --small delay so openRaidLib finishes its own GROUP_ROSTER_UPDATE bookkeeping first
            C_Timer.After(1, function()
                local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
                if (not openRaidLib) then return end
                if (IsInRaid()) then
                    openRaidLib.RequestKeystoneDataFromRaid()
                elseif (IsInGroup()) then
                    openRaidLib.RequestKeystoneDataFromParty()
                end
            end)
        end
    end)
    mainPanel:HookScript("OnShow", function(self)
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
    end)
    mainPanel:HookScript("OnHide", function(self)
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    end)

    --refresh the Keys tab list every 3 seconds while the panel is shown.
    --mainPanel.RefreshKeysData is assigned by the Keys tab createOnDemandFunc once the tab is built.
    mainPanel:SetScript("OnUpdate", function(self, deltaTime)
        if (not self.lastRefresh) then
            self.lastRefresh = 0
        end
        self.lastRefresh = self.lastRefresh + deltaTime
        if (self.lastRefresh > 3) then
            self.lastRefresh = 0
            if (self.RefreshKeysData) then
                self.RefreshKeysData()
            end
        end
    end)

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

                            --background tint based on group (slot 15); fall back to default if nil
                            local lineColor = unitTable[15]
                            if (lineColor) then
                                line:SetBackdropColor(lineColor[1], lineColor[2], lineColor[3], lineColor[4])
                            else
                                line:SetBackdropColor(.12, .12, .12, 0.6)
                            end

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
                    --shorter than the scrollBox so the rating text doesn't sit under the inset scrollbar
                    line:SetSize(SCROLL_WIDTH - 22, LINE_HEIGHT)
                    line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
                    line:SetBackdropColor(.12, .12, .12, 0.6)

                    --teleport button: covers the whole line, triggers the dungeon teleport spell
                    local teleportButton = smallKeysTeleportButtons[index]
                    teleportButton:SetParent(line)
                    teleportButton:SetAllPoints(line)
                    teleportButton:SetFrameLevel(line:GetFrameLevel() + 1)

                    --hover highlight: the button covers the whole line and captures mouse events,
                    --so anchoring the highlight texture to it lets Blizzard auto-toggle it on hover.
                    if (not teleportButton.hoverHighlight) then
                        local hoverHighlight = teleportButton:CreateTexture(nil, "highlight")
                        hoverHighlight:SetAllPoints()
                        hoverHighlight:SetColorTexture(1, 1, 1, 0.10)
                        teleportButton.hoverHighlight = hoverHighlight
                    end

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
                --scrollBox at x=1 + line internal x=1 → line left edge sits 2px inside the panel.
                --right side at -2 keeps the scrollbar 2px inside the right border.
                scrollBox:SetPoint("topleft", tabFrame, "topleft", 1, -26)
                scrollBox:SetPoint("bottomright", tabFrame, "bottomright", -2, 20)
                scrollBox:SetBackdropBorderColor(0, 0, 0, 0)

                --bind the custom scrollbar; CreateScrollBar2 handles HideScrollBar, IsFauxScroll,
                --offset wiring, anchoring (right gutter, panel-aligned), frame level, mouse wheel,
                --and auto-syncs range/visible-ratio via a Refresh hook.
                scrollBox:CreateScrollBar2()

                scrollBox:SetScript("OnSizeChanged", function(self)
                    --each line occupies (LINE_HEIGHT + 1) pixels including the gap between rows.
                    --dividing by LINE_HEIGHT would overestimate and let the last line spill into
                    --the bottom margin where the refresh button lives.
                    local newAmount = math.floor(self:GetHeight() / (LINE_HEIGHT + 1))
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

                --CreateScrollBox seeds NumFramesShown from LINES_VISIBLE (computed from the
                --default WINDOW_HEIGHT). The SetPoint above stretches the scrollBox to its real
                --height, but that resize happens before OnSizeChanged is attached, so the
                --handler never fires on first display. Recalculate now so the initial layout
                --fills the available height instead of waiting for the user to resize.
                --recompute the visible-line count from the scrollbox's actual height and apply it.
                local syncVisibleLines = function()
                    --divide by (LINE_HEIGHT + 1) to include the 1px gap between rows; using
                    --just LINE_HEIGHT lets one extra row spill into the bottom margin.
                    local actualLines = math.floor(scrollBox:GetHeight() / (LINE_HEIGHT + 1))

                    if (actualLines < 1) then
                        actualLines = 1
                    end

                    if (actualLines > LINE_AMOUNT) then
                        actualLines = LINE_AMOUNT
                    end

                    scrollBox:SetNumFramesShown(actualLines)
                end
                syncVisibleLines()
                --also resync each time the panel is shown, in case a saved size is restored
                --after this createOnDemandFunc runs.
                scrollBox:HookScript("OnShow", syncVisibleLines)

                tabFrame.ScrollBox = scrollBox

                --build party-member-only data and push it into the scrollbox.
                --scrollbar sync happens automatically inside scrollBox:Refresh() via the hook
                --installed by scrollBox:CreateScrollBar2 above.
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

                    --build the set of online guild members so their keystones can also appear.
                    --GetGuildRosterInfo returns "Name-Realm"; openRaidLib unit names are realm-stripped
                    --on this realm, so strip both sides before matching.
                    local realmNameGsub = "%-.*"
                    local guildUsers = {}
                    local guildName = GetGuildInfo("player")
                    if (guildName) then
                        local totalMembers = GetNumGuildMembers()
                        for i = 1, totalMembers do
                            local fullName, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
                            if (not fullName) then
                                break
                            end
                            if (online) then
                                guildUsers[fullName:gsub(realmNameGsub, "")] = true
                            end
                        end
                    end

                    local newData = {}
                    local isPlayerInRaid = IsInRaid()
                    local playerNameNoRealm = Details:GetFullName("player"):gsub(realmNameGsub, "")

                    for unitName, keystoneInfo in pairs(keystoneData) do
                        local nameNoRealm = unitName:gsub(realmNameGsub, "")
                        local isThisPlayer = (nameNoRealm == playerNameNoRealm)
                        local isInMyParty = UnitInParty(unitName)
                        local isInMyRaid = isPlayerInRaid and UnitInRaid(unitName)
                        local isGuildMember = guildName and guildUsers[nameNoRealm] and true or false

                        if ((isThisPlayer or isInMyParty or isInMyRaid or isGuildMember) and (keystoneInfo.level > 0 or keystoneInfo.rating > 0)) then
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

                            --sort group: 0=player, 1=party, 2=raid, 3=guild, 4=other.
                            --party and raid are mutually exclusive (party only counts when not in a raid).
                            local sortGroup
                            if (isThisPlayer) then
                                sortGroup = 0
                            elseif (isInMyParty and not isPlayerInRaid) then
                                sortGroup = 1
                            elseif (isInMyRaid) then
                                sortGroup = 2
                            elseif (isGuildMember) then
                                sortGroup = 3
                            else
                                sortGroup = 4
                            end

                            --background tint constants live at the top of the file; resolved here per row.
                            local lineColor
                            if (isInMyParty and not isPlayerInRaid) then
                                lineColor = LINE_COLOR_PARTY
                            elseif (isInMyRaid) then
                                lineColor = LINE_COLOR_RAID
                            elseif (isGuildMember) then
                                lineColor = LINE_COLOR_GUILD
                            end

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
                                isInMyParty and 1 or 0, --[11] isInMyParty
                                true, --[12] isOnline
                                isGuildMember, --[13] isGuildMember
                                specId, --[14] spec ID
                                lineColor, --[15] line backdrop tint (or nil)
                                sortGroup, --[16] sort bucket
                            }

                            if (#newData >= LINE_AMOUNT) then
                                break
                            end
                        end
                    end

                    --player first, then party, then raid, then guild; tiebreak on rating descending
                    table.sort(newData, function(a, b)
                        if (a[16] ~= b[16]) then
                            return a[16] < b[16]
                        end
                        return (a[6] or 0) > (b[6] or 0)
                    end)

                    scrollBox:SetData(newData)
                    scrollBox:Refresh()
                end

                --called automatically by the tab container each time this tab is selected
                tabFrame.RefreshOptions = refreshData
                --expose the refresh closure so the panel-level OnUpdate handler can keep keys live
                mainPanel.RefreshKeysData = refreshData
                tabFrame.titleText:Hide()
            end,
        },
        {
            name = "Teleports",
            text = "Teleports",
            createOnDemandFunc = function(tabFrame, tabContainer, parent)
                tabFrame:EnableMouse(false)
                tabFrame.titleText:Hide()

                --constants
                local LINE_HEIGHT = 30
                local SCROLL_WIDTH = WINDOW_WIDTH - 8
                local LINES_VISIBLE = math.floor((WINDOW_HEIGHT - TITLEBAR_BOTTOM - 26) / LINE_HEIGHT)

                --current-season dungeon names. Used to push these dungeons to the top of the list.
                local currentSeasonDungeons = {}
                if (detailsFramework.Ejc and detailsFramework.Ejc.GetAllDungeonNames) then
                    local dungeonNames = detailsFramework.Ejc.GetAllDungeonNames()
                    for i = 1, #dungeonNames do
                        currentSeasonDungeons[dungeonNames[i]] = true
                    end
                end

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

                    --current-season dungeons first (alphabetical), then the rest by known-first then alphabetical.
                    table.sort(teleportData, function(a, b)
                        local aIsSeasonal = currentSeasonDungeons[a[1]] and true or false
                        local bIsSeasonal = currentSeasonDungeons[b[1]] and true or false

                        if (aIsSeasonal ~= bIsSeasonal) then
                            return aIsSeasonal
                        end

                        if (a[8] ~= b[8]) then
                            return a[8] and not b[8]
                        end

                        return (a[1] or "") < (b[1] or "")
                    end)
                end

                local lineCount = math.max(#teleportData, 1)
                local searchText = ""

                --map of zone name -> number of party members currently in that zone.
                --rebuilt on each refresh from C_Map.GetBestMapForUnit + C_Map.GetMapInfo,
                --with a tooltip-scrape fallback for units C_Map can't resolve.
                local playerZoneCounts = {}

                ---reads the localised "Zone:" line from the server-cached unit tooltip.
                ---used as a fallback when C_Map can't resolve a distant party member's zone.
                ---@param unit string unit token like "player" or "party1"
                ---@return string? zoneName the zone name, or nil if no "Zone:" line is found
                local getZoneNameFromTooltip = function(unit)
                    if (not C_TooltipInfo or not C_TooltipInfo.GetUnit) then
                        return nil
                    end

                    local result = C_TooltipInfo.GetUnit(unit)
                    if (not result or not result.lines) then
                        return nil
                    end

                    --localised "Zone:" prefix from GlobalStrings; fall back to English literal.
                    local zonePrefix = (_G.ZONE or "Zone") .. ":"
                    local prefixLen = #zonePrefix

                    for i = 1, #result.lines do
                        local line = result.lines[i]
                        local text = line and line.leftText

                        if (text and text:sub(1, prefixLen) == zonePrefix) then
                            local rest = text:sub(prefixLen + 1):match("^%s*(.+)$")

                            if (rest and rest ~= "") then
                                return rest
                            end
                        end
                    end

                    return nil
                end

                ---rebuilds playerZoneCounts from {player, party1..4}: resolves each unit's zone
                ---via C_Map first, falling back to a tooltip scrape, and tallies counts by zone name.
                local computePlayerZoneCounts = function()
                    wipe(playerZoneCounts)
                    local units = {"player", "party1", "party2", "party3", "party4"}

                    for index, unit in ipairs(units) do
                        if (UnitExists(unit)) then
                            local zoneName
                            local uiMapID = C_Map.GetBestMapForUnit(unit)

                            if (uiMapID) then
                                local info = C_Map.GetMapInfo(uiMapID)

                                if (info and info.name) then
                                    zoneName = info.name
                                end
                            end

                            if (not zoneName) then
                                zoneName = getZoneNameFromTooltip(unit)
                            end

                            if (zoneName) then
                                playerZoneCounts[zoneName] = (playerZoneCounts[zoneName] or 0) + 1
                            end
                        end
                    end
                end

                --filters teleportData by searchText and refreshes the scrollbox.
                --scrollbar sync happens automatically inside scrollBox:Refresh() via the hook
                --installed by scrollBox:CreateScrollBar2 below.
                local refreshScrollData = function(scrollBox)
                    computePlayerZoneCounts()

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

                            local count = playerZoneCounts[mapInfo[1] or ""]
                            if count and count > 0 then
                                line.playerCountText.text = tostring(count)
                            else
                                line.playerCountText.text = ""
                            end

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
                                        --hover highlight: the button covers the whole line and captures mouse events,
                                        --so anchoring the highlight texture to it lets Blizzard auto-toggle it on hover.
                                        if (not button.hoverHighlight) then
                                            local hoverHighlight = button:CreateTexture(nil, "highlight")
                                            hoverHighlight:SetAllPoints()
                                            hoverHighlight:SetColorTexture(1, 1, 1, 0.10)
                                            button.hoverHighlight = hoverHighlight
                                        end
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
                    --width leaves a 22px gutter on the right so the scroll bar sits over empty
                    --space instead of overlapping the row text (matches the Keys tab layout).
                    line:SetSize(SCROLL_WIDTH - 22, LINE_HEIGHT)
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

                    --party-member count: how many of {player, party1..4} are currently in this dungeon's zone.
                    local playerCountText = detailsFramework:CreateLabel(line, "")
                    detailsFramework:SetFontSize(playerCountText, 12)
                    playerCountText:SetPoint("right", line, "right", -8, 0)

                    line.dungeonTexture = dungeonTexture
                    line.dungeonNameText = dungeonNameText
                    line.playerCountText = playerCountText

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

                --scrollbox is offset 50px from the top to leave room for the search box (26px) + margin.
                --bottomright is pulled in 2px so the scroll bar (reskinned ~6px right of the box)
                --stays visually inside the panel edge.
                scrollBox:SetPoint("topleft", tabFrame, "topleft", 4, -50)
                scrollBox:SetPoint("bottomright", tabFrame, "bottomright", -2, 20)
                scrollBox:SetBackdropBorderColor(0, 0, 0, 0)

                --bind the custom scrollbar; CreateScrollBar2 handles HideScrollBar, IsFauxScroll,
                --offset wiring, anchoring (right gutter, panel-aligned), frame level, mouse wheel,
                --and auto-syncs range/visible-ratio via a Refresh hook.
                scrollBox:CreateScrollBar2()

                local resizeScrollBox = function(self)
                    local newAmount = math.floor(self:GetHeight() / LINE_HEIGHT)
                    if (newAmount < 1) then
                        newAmount = 1
                    end

                    if (newAmount > lineCount) then
                        newAmount = lineCount
                    end

                    self:SetNumFramesShown(newAmount)
                    self:Refresh()
                end
                scrollBox:SetScript("OnSizeChanged", resizeScrollBox)

                --LINES_VISIBLE passed to CreateScrollBox is an estimate from WINDOW_HEIGHT, but the
                --actual height comes from the anchors above. The first time the tab is shown, the
                --estimate can exceed the real height by one line, which renders below the visible
                --area until a resize triggers OnSizeChanged. Force a recompute after the layout pass.
                C_Timer.After(0, function()
                    resizeScrollBox(scrollBox)
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
                tabFrame.titleText:Hide()
            end,
        },
        {
            name = "History",
            text = "History",
            createOnDemandFunc = function(tabFrame, tabContainer, parent)
                --build History tab content here
                tabFrame.titleText:Hide()
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

    --strip any default backdrop the tab framework may apply on the container or per-tab frames,
    --so the rounded panel shows through cleanly without a fade band at top/bottom.
    if (tabContainer.SetBackdrop) then
        tabContainer:SetBackdrop(nil)
    end
    if (tabContainer.AllFrames) then
        for index, tabFrame in ipairs(tabContainer.AllFrames) do
            if (tabFrame.SetBackdrop) then
                tabFrame:SetBackdrop(nil)
            end
        end
    end

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