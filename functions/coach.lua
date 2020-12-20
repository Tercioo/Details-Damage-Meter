
local Details = _G.Details

--stop yellow warning on my editor
local IsInRaid = _G.IsInRaid
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitName = _G.UnitName
local GetRealmName = _G.GetRealmName
local GetTime = _G.GetTime
local GetNumGroupMembers = _G.GetNumGroupMembers

--return if the player is inside a raid zone
local isInRaidZone = function()
    return Details.zone_type == "raid"
end

--create a namespace using capital letter 'C' for coach feature, the profile entry is lower character .coach
Details.Coach = {
    Client = { --regular player
        enabled = false,
        coachName = "",
    },

    Server = { --the raid leader
        enabled = false,
        lastCombatStartTime = 0,
        lastCombatEndTime = 0,
    },

    isInRaidGroup = false,
    isInRaidZone = false,
}

function Details.Coach.AskRLForCoachStatus(raidLeaderName)
    Details:SendCommMessage(_G.DETAILS_PREFIX_NETWORK, Details:Serialize(_G.DETAILS_PREFIX_COACH, UnitName("player"), GetRealmName(), Details.realversion, "CIEA"), "WHISPER", raidLeaderName)
    if (_detalhes.debug) then
        Details:Msg("[|cFFAAFFAADetails! Coach|r] asked the raid leader the coach status.")
    end
end

function Details.Coach.SendRLCombatStartNotify(raidLeaderName)
    Details:SendCommMessage(_G.DETAILS_PREFIX_NETWORK, Details:Serialize(_G.DETAILS_PREFIX_COACH, UnitName("player"), GetRealmName(), Details.realversion, "CCS"), "WHISPER", raidLeaderName)
    if (_detalhes.debug) then
        Details:Msg("[|cFFAAFFAADetails! Coach|r] sent to raid leader a combat start notification.")
    end
end

function Details.Coach.SendRLCombatEndNotify(raidLeaderName)
    Details:SendCommMessage(_G.DETAILS_PREFIX_NETWORK, Details:Serialize(_G.DETAILS_PREFIX_COACH, UnitName("player"), GetRealmName(), Details.realversion, "CCE"), "WHISPER", raidLeaderName)
    if (_detalhes.debug) then
        Details:Msg("[|cFFAAFFAADetails! Coach|r] sent to raid leader a combat end notification.")
    end
end

--the coach is no more a coach
function Details.Coach.SendRaidCoachEndNotify()
    Details:SendCommMessage(_G.DETAILS_PREFIX_NETWORK, Details:Serialize(_G.DETAILS_PREFIX_COACH, UnitName("player"), GetRealmName(), Details.realversion, "CE"), "RAID")
    if (_detalhes.debug) then
        Details:Msg("[|cFFAAFFAADetails! Coach|r] sent to raid a coach end notification.")
    end
end

--there's a new coach, notify players
function Details.Coach.SendRaidCoachStartNotify()
    Details:SendCommMessage(_G.DETAILS_PREFIX_NETWORK, Details:Serialize(_G.DETAILS_PREFIX_COACH, UnitName("player"), GetRealmName(), Details.realversion, "CS"), "RAID")
    if (_detalhes.debug) then
        Details:Msg("[|cFFAAFFAADetails! Coach|r] sent to raid a coach start notification.")
    end
end

--player send his death to the raid leader
function Details.Coach.SendDeathToRL(deathTable)
    Details:SendCommMessage(_G.DETAILS_PREFIX_NETWORK, Details:Serialize(_G.DETAILS_PREFIX_COACH, UnitName("player"), GetRealmName(), Details.realversion, "CDD", deathTable), "RAID")
    if (_detalhes.debug) then
        Details:Msg("[|cFFAAFFAADetails! Coach|r] your death has been sent to coach.")
    end
end

--send data to raid leader
function Details.Coach.Client.SendDataToRL()
    if (_detalhes.debug) then
        print("Details Coach sending data to RL.")
    end
    
    local data = Details.packFunctions.GetAllData()
    if (data and Details.Coach.Client.coachName) then
        Details:SendCommMessage(_G.DETAILS_PREFIX_NETWORK, Details:Serialize(_G.DETAILS_PREFIX_COACH, UnitName("player"), GetRealmName(), Details.realversion, "CDT", data), "WHISPER", Details.Coach.Client.coachName)
    end
end

--on details startup
function Details.Coach.StartUp()

    Details.Coach.isInRaidGroup = IsInRaid()
    Details.Coach.isInRaidZone = select(2, _G.GetInstanceInfo())

    --server
    if (Details.coach.enabled) then --profile
        Details.Coach.Server.EnableCoach(true)

    elseif (not Details.coach.enabled) then --profile
        if (IsInRaid()) then
            if (isInRaidZone()) then
                local raidLeaderName = Details:GetRaidLeader()
                if (raidLeaderName) then
                    --client ask for the raid leader if the Coach is enabled, GetRaidLeader returns nil is the user isn't in raid
                    if (_detalhes.debug) then
                        Details:Msg("[|cFFAAFFAADetails! Coach|r] sent ask to raid leader, is coach?")
                    end
                    Details.Coach.AskRLForCoachStatus(raidLeaderName)
                end
            end
        end
    end

    local eventListener = Details:CreateEventListener()
    Details.Coach.Listener = eventListener

    function eventListener.OnEnterGroup() --client
        --when entering a group, check if the player isn't the raid leader
        if (not UnitIsGroupLeader("player")) then
            if (IsInRaid()) then
                if (isInRaidZone()) then
                    local raidLeaderName = Details:GetRaidLeader()
                    if (raidLeaderName) then
                        if (_detalhes.debug) then
                            Details:Msg("[|cFFAAFFAADetails! Coach|r] sent ask to raid leader, is coach?")
                        end
                        Details.Coach.AskRLForCoachStatus(raidLeaderName)
                    end
                end
            end
        end

        Details.Coach.isInRaidGroup = true
    end

    function eventListener.OnLeaveGroup()
        --disable coach feature on server and client if the player leaves the group
        Details.Coach.Disable()
        Details.Coach.isInRaidGroup = false
    end

    function eventListener.OnEnterCombat()
        --send a notify to raid leader telling a new combat has started
        if (Details.Coach.Client.IsEnabled()) then
            if (IsInRaid() and isInRaidZone()) then
                if (UnitIsGroupAssistant("player")) then
                    local raidLeaderName = Details.Coach.Client.GetLeaderName()
                    if (raidLeaderName) then
                        if (_detalhes.debug) then
                            Details:Msg("[|cFFAAFFAADetails! Coach|r] i'm a raid assistant, sent combat start notification to raid leader.")
                        end
                        Details.Coach.SendRLCombatStartNotify(raidLeaderName)
                    end
                end

                --start a timer to send data to the raid leader
                if (Details.Coach.Client.UpdateTicker) then
                    Details.Coach.Client.UpdateTicker:Cancel()
                end
                Details.Coach.Client.UpdateTicker = Details.Schedules.NewTicker(1.5, Details.Coach.Client.SendDataToRL)
            end
        end
    end

    function eventListener.OnLeaveCombat()
        --send a notify to raid leader telling the combat has finished
        if (Details.Coach.Client.IsEnabled()) then
            if (IsInRaid() and isInRaidZone()) then
                if (UnitIsGroupAssistant("player")) then
                    local raidLeaderName = Details.Coach.Client.GetLeaderName()
                    if (raidLeaderName) then
                        if (_detalhes.debug) then
                            Details:Msg("[|cFFAAFFAADetails! Coach|r] i'm a raid assistant, sent combat end notification to raid leader.")
                        end
                        Details.Coach.SendRLCombatEndNotify(raidLeaderName)
                    end
                end
            end

            Details.Schedules.Cancel(Details.Coach.Client.UpdateTicker)
        end
    end

    function eventListener.OnZoneChanged()
        --if the raid leader entered in a raid, disable the coach
        if (Details.Coach.Server.IsEnabled()) then
            if (isInRaidZone()) then
                --the raid leader entered a raid instance
                Details.Coach.Disable()
                if (_detalhes.debug) then
                    Details:Msg("[|cFFAAFFAADetails! Coach|r] Coach feature stopped: you entered in a raid instance.")
                end
            end
            return
        else
            --check if the raid leader just left the raid to be a coach
            if (Details.Coach.IsEnabled()) then --profile coach feature is enabled
                if (UnitIsGroupLeader("player")) then --player is the raid leader
                    if (not Details.Coach.Server.IsEnabled()) then --the coach feature isn't running
                        Details.Coach.Server.EnableCoach()
                        if (_detalhes.debug) then
                            Details:Msg("[|cFFAAFFAADetails! Coach|r] Coach feature is now running, if this come as surprise, use '/details coach' to disable.")
                        end
                    end
                end
                return
            end
        end

        --when entering a new zone, check if there's a coach
        if (not Details.Coach.isInRaidZone and isInRaidZone()) then
            if (not UnitIsGroupLeader("player")) then
                if (IsInRaid()) then
                    if (not Details.Coach.Client.IsEnabled()) then
                        local raidLeaderName = Details:GetRaidLeader()
                        if (raidLeaderName) then
                            if (_detalhes.debug) then
                                Details:Msg("[|cFFAAFFAADetails! Coach|r] sent ask to raid leader, is coach?")
                            end
                            Details.Coach.AskRLForCoachStatus(raidLeaderName)
                            return
                        end
                    end
                end
            end
        end

        --check if the player has left the raid zone
        if (Details.Coach.isInRaidZone and Details.Coach.Client.IsEnabled()) then
            if (not isInRaidZone()) then
                --player left the raid zone
                Details.Schedules.Cancel(Details.Coach.Client.UpdateTicker)
                Details.Coach.Disable()
            end
        end

        Details.Coach.isInRaidZone = isInRaidZone()
    end

    eventListener:RegisterEvent("GROUP_ONENTER", "OnEnterGroup")
    eventListener:RegisterEvent("GROUP_ONLEAVE", "OnLeaveGroup")
    eventListener:RegisterEvent("COMBAT_PLAYER_ENTER", "OnEnterCombat")
    eventListener:RegisterEvent("COMBAT_PLAYER_LEAVE", "OnLeaveCombat")
    eventListener:RegisterEvent("ZONE_TYPE_CHANGED", "OnZoneChanged")
end

C_Timer.After(0.1, function()
    --Details.debug = true
end)

--received an answer from server telling if the raidleader has the coach feature enabled
--the request is made when the player enters a new group or reconnects
function Details.Coach.Client.CoachIsEnabled_Response(isCoachEnabled, raidLeaderName)
    if (_detalhes.debug) then
        Details:Msg("[|cFFAAFFAADetails! Coach|r] Raid Leader sent response about the status of Coach Mode:", isCoachEnabled, raidLeaderName)
    end

    if (isCoachEnabled) then
        --raid leader confirmed the coach feature is enabled and running
        Details.Coach.Client.EnableCoach(raidLeaderName)
        Details:Msg("[|cFFAAFFAADetails! Coach|r] current coach:", raidLeaderName)
    end
end

function Details.Coach.Server.CoachIsEnabled_Answer(sourcePlayer)
    if (not UnitIsGroupLeader("player")) then
        return
    end
    --send the answer
    Details:SendCommMessage(_G.DETAILS_PREFIX_NETWORK, Details:Serialize(_G.DETAILS_PREFIX_COACH, sourcePlayer, GetRealmName(), Details.realversion, "CIER", Details.Coach.Server.IsEnabled()), "WHISPER", sourcePlayer)
end

function Details.Coach.Disable()
    Details.coach.enabled = false --profile

    --if the player is the raid leader and the coach feature is enabled
    if (Details.Coach.Server.IsEnabled()) then
        Details.Coach.SendRaidCoachEndNotify()
    end

    Details.Coach.Server.enabled = false
    Details.Coach.Client.enabled = false
    Details.Coach.Client.coachName = nil

    Details.Coach.EventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
end

--the player used '/details coach' or it's Details! initialization
function Details.Coach.Server.EnableCoach(fromStartup)
    if (not IsInRaid()) then
        if (_detalhes.debug) then
            Details:Msg("[|cFFAAFFAADetails! Coach|r] cannot enabled coach: not in raid.")
        end
        Details.coach.enabled = false
        Details.Coach.Server.enabled = false
        return

    elseif (not UnitIsGroupLeader("player")) then
        if (_detalhes.debug) then
            Details:Msg("[|cFFAAFFAADetails! Coach|r] cannot enabled coach: you aren't the raid leader.")
        end
        Details.coach.enabled = false
        Details.Coach.Server.enabled = false
        return

    elseif (isInRaidZone()) then
        if (_detalhes.debug) then
            Details:Msg("[|cFFAAFFAADetails! Coach|r] cannot enabled coach: you are inside a raid zone.")
        end
        Details.coach.enabled = false
        Details.Coach.Server.enabled = false
        return
    end

    Details.coach.enabled = true
    Details.Coach.Server.enabled = true

    --notify players about the new coach
    Details.Coach.SendRaidCoachStartNotify()

    --enable group roster to know if the server isn't raid leader any more
    Details.Coach.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

    if (fromStartup) then
        if (_detalhes.debug) then
            Details:Msg("[|cFFAAFFAADetails! Coach|r] coach feature enabled, welcome back captain!")
        end
    end
end

--the raid leader sent a coach end notify
function Details.Coach.Client.CoachEnd()
    Details.Coach.Client.enabled = false
    Details.Coach.Client.coachName = nil
    Details.Coach.EventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
end

--a player in the raid asked to be the coach of the group
function Details.Coach.Client.EnableCoach(raidLeaderName)
    if (not IsInRaid()) then
        if (_detalhes.debug) then
            print("Details Coach can't enable coach on client: isn't in raid")
        end
        return

    elseif (not UnitIsGroupLeader(raidLeaderName)) then
        if (_detalhes.debug) then
            print("Details Coach can't enable coach on client: the unit passed isn't the raid leader")
        end
        return
    end

    Details.Coach.Client.enabled = true
    Details.Coach.Client.coachName = raidLeaderName

    --enable group roster to know if the raid leader has changed
    Details.Coach.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

    if (_detalhes.debug) then
        Details:Msg("[|cFFAAFFAADetails! Coach|r] there's a new coach: ", raidLeaderName)
    end

    Details:Msg("[|cFFAAFFAADetails! Coach|r] current coach:", raidLeaderName)
end

--raid leader received a notification that a new combat has started
function Details.Coach.Server.CombatStarted()
    if (Details.Coach.Server.lastCombatStartTime > GetTime()) then
        return
    else
        Details.Coach.Server.lastCombatStartTime = GetTime() + 10
    end

    --stop the combat if already in one
    if (Details.in_combat) then
        Details:EndCombat()
    end

    --start a new combat
    Details:StartCombat()
end

--raid leader received a notification that the current combat ended
function Details.Coach.Server.CombatEnded()
    if (Details.Coach.Server.lastCombatEndTime > GetTime()) then
        return
    else
        Details.Coach.Server.lastCombatEndTime = GetTime() + 10
    end

    Details:EndCombat()
end

--profile
function Details.Coach.IsEnabled()
    return Details.coach.enabled
end
--server
function Details.Coach.Server.IsEnabled()
    return Details.Coach.Server.enabled
end
--client
function Details.Coach.Client.IsEnabled()
    return Details.Coach.Client.enabled
end
function Details.Coach.Client.GetLeaderName()
    return Details.Coach.Client.coachName
end

Details.Coach.EventFrame = _G.CreateFrame("frame")
Details.Coach.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
Details.Coach.EventFrame:SetScript("OnEvent", function(event, ...)
    if (event == "GROUP_ROSTER_UPDATE") then
        --check who is raid leader to know if the leader is still the same
        if (Details.Coach.Client.IsEnabled()) then
            if (IsInRaid()) then
                for i = 1, GetNumGroupMembers() do
                    if (UnitIsGroupLeader("raid" .. i)) then
                        local unitName = UnitName("raid" .. i)
                        if (_G.Ambiguate(unitName .. "-" .. GetRealmName(), "none") ~= Details.Coach.Client.coachName) then
                            --the raid leader has changed, finish the coach feature on the client
                            if (_detalhes.debug) then
                                Details:Msg("[|cFFAAFFAADetails! Coach|r] raid leader has changed, coach feature has been disabled.")
                            end
                            Details.Coach.Client.CoachEnd()
                        end
                        break
                    end
                end
            end
        end

        --check if the player is the new raid leader
        if (UnitIsGroupLeader("player")) then
            if (Details.Coach.IsEnabled()) then
                if (not Details.Coach.Server.IsEnabled()) then
                    if (IsInRaid()) then
                        if (not isInRaidZone()) then
                            if (_detalhes.debug) then
                                Details:Msg("[|cFFAAFFAADetails! Coach|r] you're now the coach of the group.")
                            end
                            --delay to set the new leader to give time for SendRaidCoachEndNotify()
                            _G.C_Timer.After(3, Details.Coach.Server.EnableCoach)
                        end
                    end
                end
            end
        else
            --player isn't the raid leader, check if the player is the coach and disable the feature
            if (Details.Coach.IsEnabled()) then
                if (Details.Coach.Server.IsEnabled()) then
                    if (_detalhes.debug) then
                        Details:Msg("[|cFFAAFFAADetails! Coach|r] you're not the raid leader, disabling the coach feature.")
                    end
                    Details.Coach.Disable()
                end
            end
        end
    end
end)

function Details.Coach.Client.SendMyDeath(_, _, _, _, _, _, playerGUID, _, playerFlag, deathTable)
    if (Details.Coach.Client.enabled) then
        if (Details.Coach.Client.coachName) then
            if (Details.in_combat) then
                if (playerGUID == UnitGUID("player")) then
                    Details.Coach.SendDeathToRL({deathTable, playerGUID, playerFlag})
                end
            end
        end
    end
end

function Details.Coach.Server.AddPlayerDeath(playerName, data)
    local currentCombat = Details:GetCurrentCombat()
    local utilityContainer = currentCombat[4]

    local deathLog = data[1]
    local playerGUID = data[2]
    local playerFlag = data[3]

    local utilityActorObject = utilityContainer:GetOrCreateActor(playerGUID, playerName, playerFlag, true)

    if (utilityActorObject) then
        tinsert(currentCombat.last_events_tables, deathLog)
        --tag the misc container as need refresh
        currentCombat[DETAILS_ATTRIBUTE_MISC].need_refresh = true
    end
end

function Details.Coach.WelcomePanel()
    local welcomePanel = _G.DETAILSCOACHPANEL
    if (not welcomePanel) then
		welcomePanel = DetailsFramework:CreateSimplePanel(UIParent)
		welcomePanel:SetSize (400, 280)
		welcomePanel:SetTitle ("Details! Coach")
		welcomePanel:ClearAllPoints()
		welcomePanel:SetPoint ("left", UIParent, "left", 10, 0)
        welcomePanel:Hide()
        DetailsFramework:ApplyStandardBackdrop(welcomePanel)

		local LibWindow = _G.LibStub("LibWindow-1.1")
		welcomePanel:SetScript("OnMouseDown", nil)
		welcomePanel:SetScript("OnMouseUp", nil)
		LibWindow.RegisterConfig(welcomePanel, Details.coach.welcome_panel_pos)
		LibWindow.MakeDraggable(welcomePanel)
        LibWindow.RestorePosition(welcomePanel)

        local imageSize = 26

        local detailsLogo = DetailsFramework:CreateImage(welcomePanel, [[Interface\AddOns\Details\images\logotipo]])
        detailsLogo:SetPoint("topleft", welcomePanel, "topleft", 5, -30)
        detailsLogo:SetSize(200, 50)
        detailsLogo:SetTexCoord(36/512, 380/512, 128/256, 227/256)

        local isLeaderTexture = DetailsFramework:CreateImage(welcomePanel, [[Interface\GLUES\LOADINGSCREENS\DynamicElements]], imageSize, imageSize)
        isLeaderTexture:SetTexCoord(0, 0.5, 0, 0.5)
        isLeaderTexture:SetPoint("topleft", detailsLogo, "topleft", 0, -60)
        local isLeaderText = DetailsFramework:CreateLabel(welcomePanel, "In raid and You're the leader of the group.")
        isLeaderText:SetPoint("left", isLeaderTexture, "right", 10, 0)

        local isOutsideTexture = DetailsFramework:CreateImage(welcomePanel, [[Interface\GLUES\LOADINGSCREENS\DynamicElements]], imageSize, imageSize)
        isOutsideTexture:SetTexCoord(0, 0.5, 0, 0.5)
        isOutsideTexture:SetPoint("topleft", isLeaderTexture, "bottomleft", 0, -5)
        local isOutsideText = DetailsFramework:CreateLabel(welcomePanel, "You're outside of the instance.")
        isOutsideText:SetPoint("left", isOutsideTexture, "right", 10, 0)

        local hasAssistantsTexture = DetailsFramework:CreateImage(welcomePanel, [[Interface\GLUES\LOADINGSCREENS\DynamicElements]], imageSize, imageSize)
        hasAssistantsTexture:SetTexCoord(0, 0.5, 0, 0.5)
        hasAssistantsTexture:SetPoint("topleft", isOutsideTexture, "bottomleft", 0, -5)
        local hasAssistantsText = DetailsFramework:CreateLabel(welcomePanel, "There's an 'raid assistant' inside the raid.")
        hasAssistantsText:SetPoint("left", hasAssistantsTexture, "right", 10, 0)

        local beInGroupSevenTexture = DetailsFramework:CreateImage(welcomePanel, [[Interface\GLUES\LOADINGSCREENS\DynamicElements]], imageSize, imageSize)
        beInGroupSevenTexture:SetTexCoord(0, 0.5, 0, 0.5)
        beInGroupSevenTexture:SetPoint("topleft", hasAssistantsTexture, "bottomleft", 0, -5)
        local beInGroupSevenText = DetailsFramework:CreateLabel(welcomePanel, "Stay in group 7 or 8.")
        beInGroupSevenText:SetPoint("left", beInGroupSevenTexture, "right", 10, 0)

        local allUpdatedTexture = DetailsFramework:CreateImage(welcomePanel, [[Interface\GLUES\LOADINGSCREENS\DynamicElements]], imageSize, imageSize)
        allUpdatedTexture:SetTexCoord(0, 0.5, 0, 0.5)
        allUpdatedTexture:SetPoint("topleft", beInGroupSevenTexture, "bottomleft", 0, -5)
        local allUpdatedText = DetailsFramework:CreateLabel(welcomePanel, "Users with updated Details!.")
        allUpdatedText:SetPoint("left", allUpdatedTexture, "right", 10, 0)

        local startCoachButton = DetailsFramework:CreateButton(welcomePanel, function()
            Details.coach.enabled = true
            Details.Coach.Server.EnableCoach()
            welcomePanel:Hide()
            Details:Msg("welcome aboard commander!")

        end, 80, 20, "Start Coaching!")
        startCoachButton:SetPoint("bottomright", welcomePanel, "bottomright", -10, 10)
        startCoachButton:SetTemplate(DetailsFramework:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))

        function welcomePanel.Update()
            local good = 0

            if (IsInRaid() and UnitIsGroupLeader("player")) then
                isLeaderTexture:SetTexture([[Interface\COMMON\Indicator-Green]])
                isLeaderTexture:SetTexCoord(0, 1, 0, 1)
                good = good + 1
            else
                isLeaderTexture:SetTexture([[Interface\GLUES\LOADINGSCREENS\DynamicElements]])
                isLeaderTexture:SetTexCoord(0, 0.5, 0, 0.5)
            end

            if (not IsInInstance()) then
                isOutsideTexture:SetTexture([[Interface\COMMON\Indicator-Green]])
                isOutsideTexture:SetTexCoord(0, 1, 0, 1)
                good = good + 1
            else
                isOutsideTexture:SetTexture([[Interface\GLUES\LOADINGSCREENS\DynamicElements]])
                isOutsideTexture:SetTexCoord(0, 0.5, 0, 0.5)
            end

            local hasAssistant = false
            for i = 1, GetNumGroupMembers() do
                if (UnitIsGroupAssistant("raid" .. i) and UnitName("raid" .. i) ~= UnitName("player")) then
                    hasAssistant = true
                    break
                end
            end

            if (hasAssistant) then
                hasAssistantsTexture:SetTexture([[Interface\COMMON\Indicator-Green]])
                hasAssistantsTexture:SetTexCoord(0, 1, 0, 1)
                good = good + 1
            else
                hasAssistantsTexture:SetTexture([[Interface\GLUES\LOADINGSCREENS\DynamicElements]])
                hasAssistantsTexture:SetTexCoord(0, 0.5, 0, 0.5)
            end

            local isInCorrectGroup = false
            for i = 1, GetNumGroupMembers() do
                local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
                if (rank == 2) then
                    if (subgroup == 7 or subgroup == 8) then
                        isInCorrectGroup = true
                        break
                    end
                end
            end

            if (isInCorrectGroup) then
                beInGroupSevenTexture:SetTexture([[Interface\COMMON\Indicator-Green]])
                beInGroupSevenTexture:SetTexCoord(0, 1, 0, 1)
                good = good + 1
            else
                beInGroupSevenTexture:SetTexture([[Interface\GLUES\LOADINGSCREENS\DynamicElements]])
                beInGroupSevenTexture:SetTexCoord(0, 0.5, 0, 0.5)
            end

            local allUsersUpdated = false

            local numRaidMembers = GetNumGroupMembers()
            local updatedUsers = 0
            local usersChecked = {}

            for i = 1, #Details.users do
                local thisUser = Details.users[i]
                local userName = thisUser[1]

                if (not usersChecked[userName]) then
                    local version = thisUser[3]
                    local buildCounter = version:match("%w%d%.%d%.%d%.(%d+)")
                    buildCounter = tonumber(buildCounter)

                    if (buildCounter and buildCounter >= Details.build_counter) then
                        updatedUsers = updatedUsers + 1
                    end

                    usersChecked[userName] = true
                end
            end

            if (updatedUsers >= numRaidMembers) then
                allUsersUpdated = true
            end

            if (allUsersUpdated) then
                allUpdatedTexture:SetTexture([[Interface\COMMON\Indicator-Green]])
                allUpdatedTexture:SetTexCoord(0, 1, 0, 1)
                good = good + 1
            else
                allUpdatedTexture:SetTexture([[Interface\GLUES\LOADINGSCREENS\DynamicElements]])
                allUpdatedTexture:SetTexCoord(0, 0.5, 0, 0.5)
            end

            if (good == 5) then
                startCoachButton:Enable()
            else
                startCoachButton:Disable()
            end
        end
    end

    Details.SendHighFive()

    local nextHighFive = 10
    local nextUpdate = 1

    welcomePanel:SetScript("OnUpdate", function(self, deltaTime)
        nextHighFive = nextHighFive - deltaTime
        nextUpdate = nextUpdate - deltaTime

        if (nextHighFive < 0) then
            Details.SendHighFive()
            nextHighFive = 10
        end

        if (nextUpdate < 0) then
            welcomePanel:Update()
            nextUpdate = 1
        end
    end)

    welcomePanel:Show()
end
