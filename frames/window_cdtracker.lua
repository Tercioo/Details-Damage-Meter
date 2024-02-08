

local Details = _G.Details
local DF = _G.DetailsFramework
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
local addonName, Details222 = ...

--a cooldownFrame is the frame which holds cooldownLines
--cooldownFrame has a key where the value is a table with all cooldownLines created for the frame. The key is called "bars"

--namespace
Details222.CooldownTracking = {
    --a cooldown panel is a frame that shows the cooldowns of a specific filter type
    --this table store all frames created to show cooldowns
    --frames are created for filter types (example: all cooldowns, only player cooldowns, only raid cooldowns, etc)
    --the key on the table is the filter name and the value is the frame object
    cooldownPanels = {},
}

function Details222.CooldownTracking.IsCooldownIgnored(spellId)
    return Details.ocd_tracker.ignored_cooldowns[spellId]
end

--return a hash table with all cooldown panels created
function Details222.CooldownTracking.GetAllCooldownFrames()
    return Details222.CooldownTracking.cooldownPanels
end

--return a hash table with all cooldown panels created
function Details222.CooldownTracking.GetCooldownFrame(filterName)
    return Details222.CooldownTracking.cooldownPanels[filterName]
end

--hide all bars created
function Details222.CooldownTracking.HideAllBars(filterName)
    local allCooldownFrames = Details222.CooldownTracking.GetAllCooldownFrames()
    local cooldownFrame = allCooldownFrames[filterName]

    for _, cooldownLine in ipairs(cooldownFrame.bars) do
        cooldownLine:ClearAllPoints()
        cooldownLine:Hide()

        cooldownLine.cooldownInfo = nil
        cooldownLine.spellId = nil
        cooldownLine.class = nil
        cooldownLine.unitName = nil
    end
end

function Details222.CooldownTracking.HideAllLines(cooldownFrame)
    for _, cooldownLine in ipairs(cooldownFrame.bars) do
        cooldownLine:ClearAllPoints()
        cooldownLine:Hide()
        cooldownLine.cooldownInfo = nil
        cooldownLine.spellId = nil
        cooldownLine.class = nil
        cooldownLine.unitName = nil
    end
end

--get or create a cooldownLine
function Details222.CooldownTracking.GetOrCreateNewCooldownLine(cooldownFrame, lineId)
    local cooldownLine = cooldownFrame.bars[lineId]

    if (cooldownLine) then
        return cooldownLine
    else
        cooldownLine = DF:CreateTimeBar(cooldownFrame, [[Interface\AddOns\Details\images\bar_serenity]], Details.ocd_tracker.width-2, Details.ocd_tracker.height-2, 100, nil, cooldownFrame:GetName() .. "CDFrame" .. lineId)
        table.insert(cooldownFrame.bars, cooldownLine)
        cooldownLine:EnableMouse(false)
        return cooldownLine
    end
end

--return truen if the cooldown tracker is enabled
function Details222.CooldownTracking.IsEnabled()
    return Details.ocd_tracker.enabled
end

--enable the cooldown tracker
function Details222.CooldownTracking.EnableTracker()
    if (not Details.ocd_tracker.show_options) then
        return
    end

    Details.ocd_tracker.enabled = true

    --register callbacks with the openRaidLib
    openRaidLib.RegisterCallback(Details222.CooldownTracking, "CooldownListUpdate", "OnReceiveUnitFullCooldownList")
    openRaidLib.RegisterCallback(Details222.CooldownTracking, "CooldownUpdate", "OnReceiveSingleCooldownUpdate")
    openRaidLib.RegisterCallback(Details222.CooldownTracking, "CooldownListWipe", "OnCooldownListWipe")
    openRaidLib.RegisterCallback(Details222.CooldownTracking, "CooldownAdded", "OnCooldownAdded")
    openRaidLib.RegisterCallback(Details222.CooldownTracking, "CooldownRemoved", "OnCooldownRemoved")

    Details222.CooldownTracking.RefreshAllCooldownFrames()
end

--disable the cooldown tracker
function Details222.CooldownTracking.DisableTracker()
    Details.ocd_tracker.enabled = false

    --hide the panel
    local allCooldownFrames = Details222.CooldownTracking.GetAllCooldownFrames()

    for filterName, cooldownFrame in pairs(allCooldownFrames) do
        cooldownFrame:Hide()
    end

    --unregister callbacks
    openRaidLib.UnregisterCallback(Details222.CooldownTracking, "CooldownListUpdate", "OnReceiveUnitFullCooldownList")
    openRaidLib.UnregisterCallback(Details222.CooldownTracking, "CooldownUpdate", "OnReceiveSingleCooldownUpdate")
    openRaidLib.UnregisterCallback(Details222.CooldownTracking, "CooldownListWipe", "OnCooldownListWipe")
end


--Library Open Raid Callbacks
    --callback on the event 'CooldownListUpdate', this is triggered when a player in the group sent the list of cooldowns
    --@unitId: which unit got updated
    --@unitCooldows: a table with [spellId] = cooldownInfo
    --@allUnitsCooldowns: a table containing all units [unitName] = {[spellId] = cooldownInfo}
    function Details222.CooldownTracking.OnReceiveUnitFullCooldownList(unitId, unitCooldows, allUnitsCooldowns)
        --print("|cFFFFFF00received full cooldown list|r from:", unitId)
        Details222.CooldownTracking.RefreshAllCooldownFrames()
    end

    --callback on the event 'CooldownUpdate', this is triggered when a player uses a cooldown or a cooldown got updated (time left reduced, etc)
    --@unitId: which unit got updated
    --@spellId: which cooldown spell got updated
    --@cooldownInfo: cooldown information table to be passed with other functions
    --@unitCooldows: a table with [spellId] = cooldownInfo
    --@allUnitsCooldowns: a table containing all units [unitName] = {[spellId] = cooldownInfo}
    function Details222.CooldownTracking.OnReceiveSingleCooldownUpdate(unitId, spellId, cooldownInfo, unitCooldows, allUnitsCooldowns)
        --TODO: make a function inside lib open raid to get the filters the cooldown is in
        --I dont known which panel will be used
        --need to get the filter name which that spell belong
        --and then check if that filter is enabled

        if (Details222.CooldownTracking.IsCooldownIgnored(spellId)) then
            return
        end

        local gotUpdate = false

        --get a map with the filters the spell is in, the key is the filter name and the value is boolean true
        local spellFilters = openRaidLib.CooldownManager.GetSpellFilters(spellId)

        --get all cooldownFrames created
        local allCooldownFrames = Details222.CooldownTracking.GetAllCooldownFrames()

        for filterName in pairs(spellFilters) do
            local cooldownFrame = allCooldownFrames[filterName]
            if (cooldownFrame) then
                local unitName = GetUnitName(unitId, true)
                local cooldownLine = cooldownFrame.playerCache[unitName] and cooldownFrame.playerCache[unitName][spellId]

                if (cooldownLine) then
                    --get the cooldown time from the lib, it return data ready to use on statusbar

                    local isReady, normalizedPercent, timeLeft, charges, minValue, maxValue, currentValue
                    local bRunOkay, errorText = pcall(function()
                        isReady, normalizedPercent, timeLeft, charges, minValue, maxValue, currentValue = openRaidLib.GetCooldownStatusFromCooldownInfo(cooldownInfo)
                    end)
                    if (not bRunOkay) then
                        local spellName = GetSpellInfo(spellId)
                        --print("error on cooldown update:", unitName, spellName, errorText)
                        return
                    end

                    if (not isReady) then
                        cooldownLine:SetTimer(currentValue, minValue, maxValue)
                    else
                        cooldownLine:SetTimer()
                    end

                    gotUpdate = true
                end
            end
        end

        if (not gotUpdate) then
            Details222.CooldownTracking.RefreshAllCooldownFrames()
        end
    end

    --when the list of cooldowns got wiped, usually happens when the player left a group
    --@allUnitsCooldowns: a table containing all units [unitName] = {[spellId] = cooldownInfo}
    function Details222.CooldownTracking.OnCooldownListWipe(allUnitsCooldowns)
        Details222.CooldownTracking.RefreshAllCooldownFrames()
    end

    --when a cooldown has been added to an unit
    function Details222.CooldownTracking.OnCooldownAdded(unitId, spellId, cooldownInfo, unitCooldows, allUnitsCooldowns)
        --here could update the cooldown of the unit, but I'm too lazy so it update all units
        Details222.CooldownTracking.RefreshAllCooldownFrames()
    end

    --when a cooldown has been removed from an unit
    function Details222.CooldownTracking.OnCooldownRemoved(unitId, spellId, unitCooldows, allUnitsCooldowns)
        Details222.CooldownTracking.RefreshAllCooldownFrames()
    end

    local eventFrame = CreateFrame("frame")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:SetScript("OnShow", function()
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    end)

    eventFrame:SetScript("OnHide", function()
        eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
    end)

    eventFrame:SetScript("OnEvent", function(self, event)
        if (event == "GROUP_ROSTER_UPDATE") then
            if (eventFrame.scheduleRosterUpdate) then
                return
            end
            --eventFrame.scheduleRosterUpdate = C_Timer.NewTimer(1, Details222.CooldownTracking.RefreshCooldownFrames)
        end
    end)

    --create the screen panel, goes into the UIParent and show cooldowns
    function Details222.CooldownTracking.CreateCooldownFrame(filterName)
        if (not Details222.CooldownTracking.AnchorFrame) then
            local anchorFrame = CreateFrame("frame", "DetailsOnlineCDTrackerAnchorFrame", UIParent, "BackdropTemplate")
            Details222.CooldownTracking.AnchorFrame = anchorFrame
            anchorFrame:SetPoint("center", 0, 0)
            anchorFrame:SetSize(20, 20)
            anchorFrame:EnableMouse(true)

            DetailsFramework:ApplyStandardBackdrop(anchorFrame)

            Details.ocd_tracker.frames["anchor_frame"] = Details.ocd_tracker.frames["anchor_frame"] or {}

            --register on libwindow
            local libWindow = LibStub("LibWindow-1.1")
            libWindow.RegisterConfig(anchorFrame, Details.ocd_tracker.frames["anchor_frame"])
            libWindow.MakeDraggable(anchorFrame)
            libWindow.RestorePosition(anchorFrame)
        end

        filterName = filterName or "main"
        local frameName = "DetailsOnlineCDTrackerScreenPanel" .. filterName
        local cooldownFrame = CreateFrame("frame", frameName, UIParent, "BackdropTemplate")
        cooldownFrame:Hide()
        cooldownFrame.filterName = filterName
        cooldownFrame:SetSize(Details.ocd_tracker.width, Details.ocd_tracker.height)
        cooldownFrame:SetPoint("center", 0, 0)
        DetailsFramework:ApplyStandardBackdrop(cooldownFrame)
        cooldownFrame:EnableMouse(true)

        local titleString = cooldownFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        titleString:SetPoint("bottomleft", cooldownFrame, "topleft", 0, 1)
        cooldownFrame.TitleString = titleString

        --register on libwindow
        local libWindow = LibStub("LibWindow-1.1")
        Details.ocd_tracker.frames[filterName] = Details.ocd_tracker.frames[filterName] or {}
        libWindow.RegisterConfig(cooldownFrame, Details.ocd_tracker.frames[filterName])
        libWindow.MakeDraggable(cooldownFrame)
        libWindow.RestorePosition(cooldownFrame)

        cooldownFrame.bars = {}
        cooldownFrame.cooldownCache = Details.ocd_tracker.current_cooldowns
        cooldownFrame.playerCache = {}
        cooldownFrame.nextLineId = 1

        local allCooldownFrames = Details222.CooldownTracking.GetAllCooldownFrames()
        allCooldownFrames[filterName] = cooldownFrame

        return cooldownFrame
    end

    function Details222.CooldownTracking.SetupCooldownLine(cooldownLine)
        local spellIcon = GetSpellTexture(cooldownLine.spellId)
        if (spellIcon) then
            cooldownLine:SetIcon(spellIcon, .1, .9, .1, .9)

            local classColor = C_ClassColor.GetClassColor(cooldownLine.class or "PRIEST")
            if (classColor) then
                cooldownLine:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
            else
                cooldownLine:SetStatusBarColor(1, 1, 1)
            end
            cooldownLine:SetLeftText(DF:RemoveRealmName(cooldownLine.unitName))
            cooldownLine:SetSize(Details.ocd_tracker.width, Details.ocd_tracker.height)
        end
    end

    function Details222.CooldownTracking.ProcessUnitCooldowns(cooldownFrame, unitId, unitCooldowns, cooldownsOrganized)
        if (unitCooldowns) then
            local unitInfo = openRaidLib.GetUnitInfo(unitId)
            local filterName = false

            local classId = unitInfo and unitInfo.classId
            if (unitInfo and not classId) then
                classId = select(3, UnitClass(unitInfo.nameFull))
            end

            if (unitInfo and classId and cooldownsOrganized[classId]) then
                local allCooldownFrames = Details222.CooldownTracking.GetAllCooldownFrames()

                for spellId, cooldownInfo in pairs(unitCooldowns) do
                    if (not Details222.CooldownTracking.IsCooldownIgnored(spellId)) then
                        --get a cooldownLine
                        local cooldownLine = Details222.CooldownTracking.GetOrCreateNewCooldownLine(cooldownFrame, cooldownFrame.nextLineId)
                        cooldownLine.cooldownInfo = cooldownInfo
                        --local isReady, normalizedPercent, timeLeft, charges, minValue, maxValue, currentValue = openRaidLib.GetCooldownStatusFromCooldownInfo(cooldownInfo)

                        cooldownLine.spellId = spellId
                        cooldownLine.class = unitInfo.class
                        cooldownLine.unitName = unitInfo.nameFull

                        --setup the cooldown in the line
                        Details222.CooldownTracking.SetupCooldownLine(cooldownLine)

                        --add the cooldown into the organized by class table
                        table.insert(cooldownsOrganized[classId], cooldownLine)

                        --iterate to the next cooldown line
                        cooldownFrame.nextLineId = cooldownFrame.nextLineId + 1

                        --store the cooldown line into a cache to get the cooldown line quicker when a cooldown receives updates
                        cooldownFrame.playerCache[unitInfo.nameFull] = cooldownFrame.playerCache[unitInfo.nameFull] or {}
                        cooldownFrame.playerCache[unitInfo.nameFull][spellId] = cooldownLine
                    end
                end
            end
        end
    end

    function Details222.CooldownTracking.RefreshSingleCooldownFrame(cooldownFrame)
        local filterName = cooldownFrame.filterName

        if (Details.ocd_tracker.framme_locked) then
            cooldownFrame:EnableMouse(false)
        else
            cooldownFrame:EnableMouse(true)
        end

        Details222.CooldownTracking.HideAllLines(cooldownFrame)

        --check if can show the title string where the text is the filter name
        if (Details.ocd_tracker.show_title) then
            cooldownFrame.TitleString:SetText(filterName)
            cooldownFrame.TitleString:Show()
        else
            cooldownFrame.TitleString:Hide()
        end

        cooldownFrame.scheduleRosterUpdate = nil
        Details:Destroy(cooldownFrame.playerCache)
        cooldownFrame.nextLineId = 1

        if (Details.ocd_tracker.show_conditions.only_in_group) then
            if (not IsInGroup()) then
                cooldownFrame:Hide()
                return
            end
        end

        if (Details.ocd_tracker.show_conditions.only_inside_instance) then
            local isInInstanceType = select(2, GetInstanceInfo())
            if (isInInstanceType ~= "party" and isInInstanceType ~= "raid" and isInInstanceType ~= "scenario" and isInInstanceType ~= "arena") then
                cooldownFrame:Hide()
                return
            end
        end

        local cooldownsOrganized = {}
        for classId = 1, 13 do --13 classes
            cooldownsOrganized[classId] = {}
        end

        local numGroupMembers = GetNumGroupMembers()

        if (IsInRaid()) then
            for i = 1, numGroupMembers do
                local unitId = "raid"..i
                local unitCooldowns = openRaidLib.GetUnitCooldowns(unitId, filterName)
                Details222.CooldownTracking.ProcessUnitCooldowns(cooldownFrame, unitId, unitCooldowns, cooldownsOrganized)
            end

        elseif (IsInGroup()) then
            for i = 1, numGroupMembers - 1 do
                local unitId = "party"..i
                local unitCooldowns = openRaidLib.GetUnitCooldowns(unitId, filterName)
                Details222.CooldownTracking.ProcessUnitCooldowns(cooldownFrame, unitId, unitCooldowns, cooldownsOrganized)
            end

            --player
            local unitCooldowns = openRaidLib.GetUnitCooldowns("player", filterName)
            Details222.CooldownTracking.ProcessUnitCooldowns(cooldownFrame, "player", unitCooldowns, cooldownsOrganized)

        else
            --player
            local unitCooldowns = openRaidLib.GetUnitCooldowns("player", filterName)
            Details222.CooldownTracking.ProcessUnitCooldowns(cooldownFrame, "player", unitCooldowns, cooldownsOrganized)
        end

        for classId = 1, 13 do --13 classes
            table.sort(cooldownsOrganized[classId], function(t1, t2) return t1.spellId < t2.spellId end)
        end

        local xPos = 1
        local cooldownFrameIndex = 1
        local lineIndex = 1
        local totalLinesUsed = 0

        for classId = 1, 13 do
            local cooldownFrameList = cooldownsOrganized[classId]
            for index, cooldownLine in ipairs(cooldownFrameList) do
                local cooldownInfo = cooldownLine.cooldownInfo
                local isReady, normalizedPercent, timeLeft, charges, minValue, maxValue, currentValue = openRaidLib.GetCooldownStatusFromCooldownInfo(cooldownInfo)

                if (not isReady) then
                    cooldownLine:SetTimer(currentValue, minValue, maxValue)
                else
                    cooldownLine:SetTimer()
                end

                cooldownLine:ClearAllPoints()
                local yLocation = (lineIndex - 1) * Details.ocd_tracker.height * -1
                cooldownLine:SetPoint("topleft", cooldownFrame, "topleft", xPos, yLocation - 1)

                lineIndex = lineIndex + 1

                if (lineIndex > Details.ocd_tracker.lines_per_column) then
                    xPos = xPos + Details.ocd_tracker.width + 2
                    lineIndex = 1
                end

                cooldownFrameIndex = cooldownFrameIndex + 1
                totalLinesUsed = totalLinesUsed + 1
            end
        end

        if (totalLinesUsed == 0) then
            cooldownFrame:Hide()
            return
        end

        local totalColumns = ceil(totalLinesUsed / Details.ocd_tracker.lines_per_column)
        local maxRows = math.min(Details.ocd_tracker.lines_per_column, totalLinesUsed)

        local width = 1 + totalColumns * Details.ocd_tracker.width + (totalColumns * 2)
        local height =  2 + maxRows * Details.ocd_tracker.height

        cooldownFrame:SetSize(width, height)
        cooldownFrame:Show()
    end

--update cooldown frames based on the amount of players in the group or raid
    function Details222.CooldownTracking.RefreshAllCooldownFrames()
        if (not Details.ocd_tracker.enabled) then
            Details222.CooldownTracking.DisableTracker()
            return
        end

        local allCooldownFrames = Details222.CooldownTracking.GetAllCooldownFrames()
        local allFilters = Details.ocd_tracker.filters

        for filterName, bIsEnabled in pairs(allFilters) do
            if (bIsEnabled) then
                local cooldownFrame = allCooldownFrames[filterName]
                if (not cooldownFrame) then
                    cooldownFrame = Details222.CooldownTracking.CreateCooldownFrame(filterName)
                end
                cooldownFrame:Show()
            else
                local cooldownFrame = Details222.CooldownTracking.GetCooldownFrame(filterName)
                if (cooldownFrame) then
                    cooldownFrame:Hide()
                end
            end
        end

        local previousFrame
        for filterName, cooldownFrame in pairs(allCooldownFrames) do
            if (cooldownFrame:IsShown()) then
                Details222.CooldownTracking.RefreshSingleCooldownFrame(cooldownFrame)
                --
                if (Details.ocd_tracker.group_frames) then
                    if (not previousFrame) then
                        previousFrame = cooldownFrame
                        cooldownFrame:ClearAllPoints()
                        cooldownFrame:SetPoint("topleft", Details222.CooldownTracking.AnchorFrame, "topleft", 5, 0)
                    else
                        cooldownFrame:ClearAllPoints()
                        cooldownFrame:SetPoint("topleft", previousFrame, "topright", 2, 0)
                        previousFrame = cooldownFrame
                    end
                end
            end
        end
    end


--Options panel

    --initialize the cooldown options window and embed it to Details! options panel
    function Details:InitializeCDTrackerWindow()
        if (not Details.ocd_tracker.show_options) then
            return
        end

        local DetailsCDTrackerWindow = CreateFrame("frame", "DetailsCDTrackerWindow", UIParent, "BackdropTemplate")
        DetailsCDTrackerWindow:SetSize(700, 480)
        DetailsCDTrackerWindow.Frame = DetailsCDTrackerWindow
        DetailsCDTrackerWindow.__name = "Cooldown Tracker"
        DetailsCDTrackerWindow.real_name = "DETAILS_CDTRACKERWINDOW"
        DetailsCDTrackerWindow.__icon = [[Interface\TUTORIALFRAME\UI-TUTORIALFRAME-SPIRITREZ]]
        DetailsCDTrackerWindow.__iconcoords = {130/512, 256/512, 0, 1}
        DetailsCDTrackerWindow.__iconcolor = "white"
        _G.DetailsPluginContainerWindow.EmbedPlugin(DetailsCDTrackerWindow, DetailsCDTrackerWindow, true)

        function DetailsCDTrackerWindow.RefreshWindow()
            Details222.CooldownTracking.OpenCDTrackerWindow()
        end

        --check if is enabled at startup
        if (Details222.CooldownTracking.IsEnabled()) then
            Details222.CooldownTracking.EnableTracker()
        end

        DetailsCDTrackerWindow:Hide()
    end

    function Details222.CooldownTracking.OpenCDTrackerWindow()
        if (not Details.ocd_tracker.show_options) then
            return
        end

        --check if the window exists, if not create it
        if (not _G.DetailsCDTrackerWindow or not _G.DetailsCDTrackerWindow.Initialized) then
            local f = _G.DetailsCDTrackerWindow or DF:CreateSimplePanel(UIParent, 700, 480, "Details! Online CD Tracker", "DetailsCDTrackerWindow")
            _G.DetailsCDTrackerWindow.Initialized = true
            DF:ApplyStandardBackdrop(f)
            --enabled with a toggle button
            --execute to reset position
            --misc configs
            local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
            local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
            local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
            local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
            local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

            local generalOptions = {
                {--enable ocd
                    type = "toggle",
                    get = function() return Details.ocd_tracker.enabled end,
                    set = function(self, fixedparam, value)
                        if (value) then
                            if (not Details.ocd_tracker.show_options) then
                                return
                            end
                            Details222.CooldownTracking.EnableTracker()
                        else
                            Details222.CooldownTracking.DisableTracker()
                        end
                    end,
                    name = "Enable Experimental Cooldown Tracker",
                    desc = "Enable Experimental Cooldown Tracker",
                },

                {--show only in group
                    type = "toggle",
                    get = function() return Details.ocd_tracker.show_conditions.only_in_group end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.show_conditions.only_in_group = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Only in Group",
                    desc = "Only in Group",
                },

                {--show only inside instances
                    type = "toggle",
                    get = function() return Details.ocd_tracker.show_conditions.only_inside_instance end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.show_conditions.only_inside_instance = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Only Inside Instances",
                    desc = "Only Inside Instances",
                },
                {--lock frame
                    type = "toggle",
                    get = function() return Details.ocd_tracker.framme_locked end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.framme_locked = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Lock Frame",
                    desc = "Lock Frame",
                },

                {type = "breakline"},

                {--filter: show raid wide defensive cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["defensive-raid"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["defensive-raid"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Defensive: Raid",
                    desc = "Example: druid tranquility.",
                },

                {--filter: show target defensive cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["defensive-target"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["defensive-target"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Defensive: Target",
                    desc = "Example: priest pain suppression.",
                },

                {--filter: show personal defensive cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["defensive-personal"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["defensive-personal"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Defensive: Personal",
                    desc = "Example: mage ice block.",
                },

                {--filter: show ofensive cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["ofensive"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["ofensive"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Offensive Cooldowns",
                    desc = "Example: priest power infusion.",
                },

                {--filter: show utility cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["utility"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["utility"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Utility Cooldowns",
                    desc = "Example: druid roar.",
                },

                {--filter: show interrupt cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["interrupt"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["interrupt"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Interrupt Cooldowns",
                    desc = "Example: rogue kick.",
                },

                {--filter: item cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["itemheal"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["itemheal"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Item: Healing",
                    desc = "Example: Healthstone.",
                },

                {--filter: item cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["itempower"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["itempower"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Item: Power Increase",
                    desc = "Example: Elemental Potion of Power.",
                },

                {--filter: item cooldowns
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["itemutil"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["itemutil"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Item: Utility",
                    desc = "Example: Invisibility Potion.",
                },

                {--filter: crowd control
                    type = "toggle",
                    get = function() return Details.ocd_tracker.filters["crowdcontrol"] end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.filters["crowdcontrol"] = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Crowd Control",
                    desc = "Example: Incapacitaion Roar.",
                },

                {type = "breakline"},

                {--bar width
                    type = "range",
                    get = function() return Details.ocd_tracker.width end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.width = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    min = 10,
                    max = 200,
                    step = 1,
                    name = "Width",
                    desc = "Width",
                },

                {--bar height
                    type = "range",
                    get = function() return Details.ocd_tracker.height end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.height = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    min = 10,
                    max = 200,
                    step = 1,
                    name = "Height",
                    desc = "Height",
                },
                
                {--bar height
                    type = "range",
                    get = function() return Details.ocd_tracker.lines_per_column end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.lines_per_column = floor(value)
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    min = 1,
                    max = 30,
                    step = 1,
                    name = "Lines Per Column",
                    desc = "Lines Per Column",
                },

                {--show anchor
                    type = "toggle",
                    get = function() return Details.ocd_tracker.show_title end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.show_title = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Show Title",
                    desc = "Show Title",
                },

                {--show anchor
                    type = "toggle",
                    get = function() return Details.ocd_tracker.group_frames end,
                    set = function(self, fixedparam, value)
                        Details.ocd_tracker.group_frames = value
                        Details222.CooldownTracking.RefreshAllCooldownFrames()
                    end,
                    name = "Group Frames",
                    desc = "Group Frames",
                },

            }

            generalOptions.always_boxfirst = true
            DF:BuildMenu(f, generalOptions, 5, -30, 150, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

            --cooldown selection
            local cooldownProfile = Details.ocd_tracker.cooldowns

            local cooldownSelectionFrame = CreateFrame("frame", "$parentCooldownSelectionFrame", f, "BackdropTemplate")
            cooldownSelectionFrame:SetPoint("topleft", f, "topleft", 0, -150)
            cooldownSelectionFrame:SetPoint("bottomright", f, "bottomright", 0, 10)
            DF:ApplyStandardBackdrop(cooldownSelectionFrame)

            local warning2 = cooldownSelectionFrame:CreateFontString(nil, "overlay", "GameFontNormal", 5)
            warning2:SetJustifyH("left")
            warning2:SetPoint("topleft", f, "topleft", 5, -160)
            DF:SetFontColor(warning2, "lime")
            --warning2:SetText("This is a concept of a cooldown tracker using the new library 'Open Raid' which uses comms to update cooldown timers.\nThe code to implement is so small that can fit inside a weakaura\nIf you're a coder, the implementation is on Details/frames/window_cdtracker.lua")

            cooldownSelectionFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
            --cooldownSelectionFrame:RegisterEvent("PLAYER_STARTED_MOVING") --debug

            local maxClasses = 13

            cooldownSelectionFrame.ClassCDsAnchorFrames = {}

            for i = 1, maxClasses do
                local anchorFrame = CreateFrame("frame", "$parentAnchorFrame"..i, cooldownSelectionFrame, "BackdropTemplate")
                anchorFrame:SetSize(1, 1)
                if (i == 1) then
                    anchorFrame:SetPoint("topleft", cooldownSelectionFrame, "topleft", 5, -5)
                else
                    anchorFrame:SetPoint("topleft", cooldownSelectionFrame.ClassCDsAnchorFrames[i-1], "topright", 310, 0)
                end

                cooldownSelectionFrame.ClassCDsAnchorFrames[i] = anchorFrame
            end

            function cooldownSelectionFrame.ClearAllCDsAnchorFrames()
                for i = 1, maxClasses do
                    cooldownSelectionFrame.ClassCDsAnchorFrames[i]:Hide()
                end
            end

            cooldownSelectionFrame:SetScript("OnEvent", function(self, event)
                --show a list of players in the group, 1 player per column
                --below the player name, show a list in vertical with checkboxes to enable/disable cooldowns for that class
                --use DetailsFramework:BuildMenuVolatile() to build the each list

                if (not cooldownSelectionFrame:IsShown()) then
                    return
                end

                local amountOfUnits = GetNumGroupMembers()

                if (amountOfUnits == 0) then
                    return
                end

                local allClasses = {}
                if (IsInGroup() and not IsInRaid()) then
                    for i = 1, amountOfUnits - 1 do
                        local unitId = "party"..i
                        local _, class = UnitClass(unitId)
                        if (class) then
                            allClasses[class] = {}
                        end
                    end

                    local unitId = "player"
                    local _, class = UnitClass(unitId)
                    allClasses[class] = {}

                elseif (IsInRaid()) then
                    for i = 1, amountOfUnits do
                        local unitId = "raid"..i
                        local _, class = UnitClass(unitId)
                        if (class) then
                            allClasses[class] = {}
                        end
                    end
                end

                local index = 1
                cooldownSelectionFrame.ClearAllCDsAnchorFrames()

                for className, allClassCDs in pairs(allClasses) do
                    --menu to build with DetailsFramework:BuildMenuVolatile()
                    local menuOptions = {}

                    for spellId, spellInfo in pairs(LIB_OPEN_RAID_COOLDOWNS_INFO) do
                        if (spellInfo.class == className) then
                            local spellName, _, spellIcon = GetSpellInfo(spellId)

                            if (spellName) then
                                local smallSpellName = string.sub(spellName, 1, 12)
                                spellName = "|T" .. spellIcon .. ":" .. 20 .. ":" .. 20 .. ":0:0:" .. 64 .. ":" .. 64 .. "|t " .. smallSpellName

                                if (spellName) then
                                    menuOptions[#menuOptions+1] = {
                                        type = "toggle",
                                        get = function() return Details.ocd_tracker.ignored_cooldowns[spellId] end,
                                        set = function(self, fixedparam, value)
                                            Details.ocd_tracker.ignored_cooldowns[spellId] = value
                                            Details222.CooldownTracking.RefreshAllCooldownFrames()
                                        end,
                                        name = spellName,
                                        desc = spellName,
                                    }
                                end
                            end
                        end
                    end

                    local anchorFrame = cooldownSelectionFrame.ClassCDsAnchorFrames[index]
                    anchorFrame:Show()

                    menuOptions.always_boxfirst = true

                    DF:BuildMenuVolatile(anchorFrame, menuOptions, 5, -5, 400, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

                    index = index + 1
                end
            end)

            cooldownSelectionFrame:GetScript("OnEvent")(cooldownSelectionFrame, "GROUP_ROSTER_UPDATE")

            cooldownSelectionFrame:SetScript("OnShow", function()
                cooldownSelectionFrame:GetScript("OnEvent")(cooldownSelectionFrame, "GROUP_ROSTER_UPDATE")
            end)
        end

        _G.DetailsPluginContainerWindow.OpenPlugin(_G.DetailsCDTrackerWindow)
        _G.DetailsCDTrackerWindow:Show()
    end
