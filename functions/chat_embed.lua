
local Details = 		_G.Details
local addonName, Details222 = ...
local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
---@framework
local detailsFramework = DetailsFramework
local _

------------------------------------------------------------------------------------------------------------
--chat hooks

Details.chat_embed = Details:CreateEventListener()
Details.chat_embed.startup = true

Details.chat_embed.hook_settabname = function(frame, name, doNotSave)
    if (not doNotSave) then
        if (Details.chat_tab_embed.enabled and Details.chat_tab_embed.tab_name ~= "") then
            if (Details.chat_tab_embed_onframe == frame) then
                Details.chat_tab_embed.tab_name = name
                Details:DelayOptionsRefresh(Details:GetInstance(1))
            end
        end
    end
end

Details.chat_embed.hook_closetab = function(frame, fallback)
    if (Details.chat_tab_embed.enabled and Details.chat_tab_embed.tab_name ~= "") then
        if (Details.chat_tab_embed_onframe == frame) then
            Details.chat_tab_embed.enabled = false
            Details.chat_tab_embed.tab_name = ""
            Details.chat_tab_embed_onframe = nil
            Details:DelayOptionsRefresh(Details:GetInstance(1))
            Details.chat_embed:ReleaseEmbed()
        end
    end
end

hooksecurefunc("FCF_SetWindowName", Details.chat_embed.hook_settabname)
hooksecurefunc("FCF_Close", Details.chat_embed.hook_closetab)

function Details.chat_embed:SetTabSettings(tab_name, bNewStateEnabled, is_single)
    local current_enabled_state = Details.chat_tab_embed.enabled
    local current_name = Details.chat_tab_embed.tab_name
    local current_is_single = Details.chat_tab_embed.single_window

    tab_name = tab_name or Details.chat_tab_embed.tab_name
    if (bNewStateEnabled == nil) then
        bNewStateEnabled = Details.chat_tab_embed.enabled
    end
    if (is_single == nil) then
        is_single = Details.chat_tab_embed.single_window
    end

    Details.chat_tab_embed.tab_name = tab_name or ""
    Details.chat_tab_embed.enabled = bNewStateEnabled
    Details.chat_tab_embed.single_window = is_single

    if (current_name ~= tab_name) then
        --rename the tab on chat frame
        local ChatFrame = Details.chat_embed:GetTab(current_name)
        if (ChatFrame) then
            FCF_SetWindowName(ChatFrame, tab_name, false)
        end
    end

    if (bNewStateEnabled) then
        --was disabled, so we need to save the current window positions.
        if (not current_enabled_state) then
            local window1 = Details:GetInstance(1)
            if (window1) then
                window1:SaveMainWindowPosition()
                if (window1.libwindow) then
                    local pos = window1:CreatePositionTable()
                    Details.chat_tab_embed.w1_pos = pos
                end
            end

            local window2 = Details:GetInstance(2)
            if (window2) then
                window2:SaveMainWindowPosition()
                if (window2.libwindow) then
                    local pos = window2:CreatePositionTable()
                    Details.chat_tab_embed.w2_pos = pos
                end
            end

        elseif (not is_single and current_is_single) then
            local window2 = Details:GetInstance(2)
            if (window2) then
                window2:SaveMainWindowPosition()
                if (window2.libwindow) then
                    local pos = window2:CreatePositionTable()
                    Details.chat_tab_embed.w2_pos = pos
                end
            end
        end

        --need to make the embed
        Details.chat_embed:DoEmbed()
    else
        --need to release the frame
        if (current_enabled_state) then
            Details.chat_embed:ReleaseEmbed()
        end
    end
end

function Details.chat_embed:CheckChatEmbed(bIsStartup)
    if (Details.chat_tab_embed.enabled) then
        Details.chat_embed:DoEmbed(bIsStartup)
    end
end

--debug
-- 	/run _detalhes.chat_embed:SetTabSettings("Dano", true, false)
-- 	/run _detalhes.chat_embed:SetTabSettings(nil, false, false)
--	/dump _detalhes.chat_tab_embed.tab_name

function Details.chat_embed:DelayedChatEmbed()
    Details.chat_embed.startup = nil
    Details.chat_embed:DoEmbed()
end

function Details.chat_embed:DoEmbed(bIsStartup)
    if (Details.chat_embed.startup and not bIsStartup) then
        if (Details.AddOnStartTime + 5 < GetTime()) then
            Details.chat_embed.startup = nil
        else
            return
        end
    end

    if (bIsStartup) then
        return Details.chat_embed:ScheduleTimer("DelayedChatEmbed", 5)
    end

    local tabname = Details.chat_tab_embed.tab_name

    if (Details.chat_tab_embed.enabled and tabname ~= "") then
        local chatFrame, chatFrameTab, chatFrameBackground = Details.chat_embed:GetTab(tabname)

        if (not chatFrame) then
            FCF_OpenNewWindow(tabname)
            chatFrame, chatFrameTab, chatFrameBackground = Details.chat_embed:GetTab(tabname)
        end

        if (chatFrame) then
            for index, t in pairs(chatFrame.messageTypeList) do
                ChatFrame_RemoveMessageGroup(chatFrame, t)
                chatFrame.messageTypeList [index] = nil
            end

            Details.chat_tab_embed_onframe = chatFrame

            if (Details.chat_tab_embed.single_window) then
                --only one window
                local window1 = Details:GetInstance(1)

                window1:UngroupInstance()
                window1.baseframe:ClearAllPoints()

                window1.baseframe:SetParent(chatFrame)

                window1.rowframe:SetParent(window1.baseframe)
                window1.rowframe:ClearAllPoints()
                window1.rowframe:SetAllPoints()

                window1.windowSwitchButton:SetParent(window1.baseframe)
                window1.windowSwitchButton:ClearAllPoints()
                window1.windowSwitchButton:SetAllPoints()

                local topOffset = window1.toolbar_side == 1 and -20 or 0
                local bottomOffset =(window1.show_statusbar and 14 or 0) + (window1.toolbar_side == 2 and 20 or 0)

                window1.baseframe:SetPoint("topleft", chatFrameBackground, "topleft", 0, topOffset + Details.chat_tab_embed.y_offset)
                window1.baseframe:SetPoint("bottomright", chatFrameBackground, "bottomright", Details.chat_tab_embed.x_offset, bottomOffset)

                window1:LockInstance(true)
                window1:SaveMainWindowPosition()

                local window2 = Details:GetInstance(2)
                if (window2 and window2.baseframe) then
                    if (window2.baseframe:GetParent() == chatFrame) then
                        --need to detach
                        Details.chat_embed:ReleaseEmbed(true)
                    end
                end
            else
                --window #1 and #2
                local window1 = Details:GetInstance(1)
                local window2 = Details:GetInstance(2)
                if (not window2) then
                    window2 = Details:CriarInstancia()
                end

                window1:UngroupInstance()
                window2:UngroupInstance()
                window1.baseframe:ClearAllPoints()
                window2.baseframe:ClearAllPoints()

                window1.baseframe:SetParent(chatFrame)
                window2.baseframe:SetParent(chatFrame)
                window1.rowframe:SetParent(window1.baseframe)
                window2.rowframe:SetParent(window2.baseframe)

                window1.windowSwitchButton:SetParent(window1.baseframe)
                window1.windowSwitchButton:ClearAllPoints()
                window1.windowSwitchButton:SetAllPoints()
                window2.windowSwitchButton:SetParent(window2.baseframe)
                window2.windowSwitchButton:ClearAllPoints()
                window2.windowSwitchButton:SetAllPoints()

                window1:LockInstance(true)
                window2:LockInstance(true)

                local statusbar_enabled1 = window1.show_statusbar
                local statusbar_enabled2 = window2.show_statusbar

                Details:Destroy(window1.snap)
                Details:Destroy(window2.snap)
                window1.snap[3] = 2; window2.snap[1] = 1;
                window1.horizontalSnap = true; window2.horizontalSnap = true

                local topOffset = window1.toolbar_side == 1 and -20 or 0
                local bottomOffset = (window1.show_statusbar and 14 or 0) + (window1.toolbar_side == 2 and 20 or 0)

                local width = chatFrameBackground:GetWidth() / 2
                local height = chatFrameBackground:GetHeight() - bottomOffset + topOffset

                window1.baseframe:SetSize(width +(Details.chat_tab_embed.x_offset/2), height + Details.chat_tab_embed.y_offset)
                window2.baseframe:SetSize(width +(Details.chat_tab_embed.x_offset/2), height + Details.chat_tab_embed.y_offset)

                window1.baseframe:SetPoint("topleft", chatFrameBackground, "topleft", 0, topOffset + Details.chat_tab_embed.y_offset)
                window2.baseframe:SetPoint("topright", chatFrameBackground, "topright", Details.chat_tab_embed.x_offset, topOffset + Details.chat_tab_embed.y_offset)

                window1:SaveMainWindowPosition()
                window2:SaveMainWindowPosition()

                --/dump ChatFrame3Background:GetSize()
            end
        end
    end
end

function Details.chat_embed:ReleaseEmbed(bSecondWindow)
    --release
    local window1 = Details:GetInstance(1)
    local window2 = Details:GetInstance(2)

    if (bSecondWindow) then
        window2:UngroupInstance()
        window2.baseframe:ClearAllPoints()
        window2.baseframe:SetParent(UIParent)
        window2.rowframe:SetParent(UIParent)
        window2.rowframe:ClearAllPoints()
        window2.windowSwitchButton:SetParent(UIParent)
        window2.baseframe:SetPoint("center", UIParent, "center", 200, 0)
        window2.rowframe:SetPoint("center", UIParent, "center", 200, 0)
        window2:LockInstance(false)
        window2:SaveMainWindowPosition()

        local previous_pos = Details.chat_tab_embed.w2_pos
        if (previous_pos) then
            window2:RestorePositionFromPositionTable(previous_pos)
        end
        return
    end
    window1:UngroupInstance();
    window1.baseframe:ClearAllPoints()
    window1.baseframe:SetParent(UIParent)
    window1.rowframe:SetParent(UIParent)
    window1.windowSwitchButton:SetParent(UIParent)
    window1.baseframe:SetPoint("center", UIParent, "center")
    window1.rowframe:SetPoint("center", UIParent, "center")
    window1:LockInstance(false)
    window1:SaveMainWindowPosition()

    local previous_pos = Details.chat_tab_embed.w1_pos
    if (previous_pos) then
        window1:RestorePositionFromPositionTable(previous_pos)
    end

    if (not Details.chat_tab_embed.single_window and window2) then
        window2:UngroupInstance()
        window2.baseframe:ClearAllPoints()
        window2.baseframe:SetParent(UIParent)
        window2.rowframe:SetParent(UIParent)
        window2.windowSwitchButton:SetParent(UIParent);
        window2.baseframe:SetPoint("center", UIParent, "center", 200, 0)
        window2.rowframe:SetPoint("center", UIParent, "center", 200, 0)
        window2:LockInstance(false)
        window2:SaveMainWindowPosition()

        local previousPos = Details.chat_tab_embed.w2_pos
        if (previousPos) then
            window2:RestorePositionFromPositionTable(previousPos)
        end
    end
end

function Details.chat_embed:GetTab(tabname)
    tabname = tabname or Details.chat_tab_embed.tab_name
    for i = 1, 20 do
        local tabtext = _G ["ChatFrame" .. i .. "Tab"]
        if (tabtext) then
            if (tabtext:GetText() == tabname) then
                return _G ["ChatFrame" .. i], _G ["ChatFrame" .. i .. "Tab"], _G ["ChatFrame" .. i .. "Background"], i
            end
        end
    end
end

--[[
--create a tab on chat
--FCF_OpenNewWindow(name)
--rename it? perhaps need to hook
--FCF_SetWindowName(chatFrame, name, true)    --FCF_SetWindowName(3, "DDD", true)
--/run local chatFrame = _G["ChatFrame3"]; FCF_SetWindowName(chatFrame, "DDD", true)

--FCF_SetWindowName(frame, name, doNotSave)
--API SetChatWindowName(frame:GetID(), name); -- set when doNotSave is false

-- need to store the chat frame reference
-- hook set window name and check if the rename was on our window

--FCF_Close
-- ^ when the window is closed
--]]