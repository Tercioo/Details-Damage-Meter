
---@type details
local Details = Details
local addonName, Details222 = ...
---@cast Details222 details222
---@type detailsframework
local detailsFramework = DetailsFramework
local _

local debug = false

---@type bparser
local bParser = Details222.BParser

---@type damagemeter
local damageMeter = DamageMeter
local displayMap

--map mainDisplay to blizzard damage meter data
if detailsFramework.IsAddonApocalypseWow() then
    displayMap = {
        [1] = {
            Enum.DamageMeterType.DamageDone, --damage done
            Enum.DamageMeterType.Dps, --dps
            Enum.DamageMeterType.DamageTaken, --damage taken
            100, --friendly fire (not supported)
            100, --frags (not supported)
            100, --enemies (not supported)
            100, --void zones (not supported)
            100, --damage taken by spells (not supported)
        },
        [2] = {
            Enum.DamageMeterType.HealingDone, --healing done
            Enum.DamageMeterType.Hps, --hps
            Enum.DamageMeterType.Absorbs, --absorbs
            100, --overhealing (not supported)
            100, --healing taken (not supported)
            100, --healing enemy (not supported)
            100, --healing prevented (not supported)
            Enum.DamageMeterType.Absorbs, --healing absorbed
        },
        [3] = {
            100, --resources (not supported)
            100, --mana gained (not supported)
            100, --rage gained (not supported)
            100, --energy gained (not supported)
            100, --runes gained (not supported)
            100, --alternate power gained (not supported)
        },
        [4] = {
            100, --cc breaks
            100, --ress (not supported)
            Enum.DamageMeterType.Interrupts, --interrupts
            Enum.DamageMeterType.Dispels, --dispels
            100, --deaths (not supported)
            100, --dcooldowns (not supported)
            100, --buff uptime (not supported)
            100, --debuff uptime (not supported)

        },
    }
else
    displayMap = {}
end

function bParser.GetDamageMeterTypeFromDisplay(mainDisplay, subDisplay)
    local displayType = displayMap[mainDisplay] and displayMap[mainDisplay][subDisplay]
    return displayType
end

local swappedFrame = CreateFrame("frame")
swappedFrame:SetPoint("topleft", UIParent, "topleft", 0, 0)
swappedFrame:SetSize(1, 1)
swappedFrame:EnableMouse(false)

local updateCombatElapsedTime = function(self)
    local elapsedTime = self:GetFormattedTimeForTitleBar()
end

local onEvent = function(event, instance, ...)
    ---@cast instance instance
    if event == "DETAILS_INSTANCE_CHANGEATTRIBUTE" then
        local mainDisplay, subDisplay = ...
        if bParser.IsDamageMeterSwapped() then
            local damageMeterType = bParser.GetDamageMeterTypeFromDisplay(mainDisplay, subDisplay)
            if damageMeterType < 100 then
                if instance.blzWindow then
                    instance.blzWindow:SetDamageMeterType(damageMeterType)
                end
            end
        end

    elseif event == "DETAILS_INSTANCE_CHANGESEGMENT" then
        local segmentId = ...
        if bParser.IsDamageMeterSwapped() then
            if instance.blzWindow then
                if segmentId == DETAILS_SEGMENTID_OVERALL then
                    instance.blzWindow:SetSession(Enum.DamageMeterSessionType.Overall, 0)

                elseif segmentId == DETAILS_SEGMENTID_CURRENT then
                    instance.blzWindow:SetSession(Enum.DamageMeterSessionType.Current, 0)

                else
                    instance.blzWindow:SetSession(Enum.DamageMeterSessionType.Expired, segmentId)
                end

                instance.blzWindow:RefreshLayout()
            end
        end

    elseif event == "DETAILS_OPTIONS_MODIFIED" then
        if detailsFramework.IsAddonApocalypseWow() then
            if bParser.IsDamageMeterSwapped() then
                bParser.UpdateAllDamageMeterWindowsAppearance()
            end
        end
    end
end

local swapListener = Details:CreateEventListener()
swapListener:RegisterEvent("DETAILS_INSTANCE_CHANGEATTRIBUTE", onEvent)
swapListener:RegisterEvent("DETAILS_INSTANCE_CHANGESEGMENT", onEvent)
swapListener:RegisterEvent("DETAILS_OPTIONS_MODIFIED", onEvent)

function bParser.ChangeSegment(blzWindow, sessionType, sessionId)
    if sessionType == Enum.DamageMeterSessionType.Overall then
        blzWindow:GetDamageMeterOwner():SetSessionWindowSessionID(blzWindow, Enum.DamageMeterSessionType.Overall)

    elseif sessionType == Enum.DamageMeterSessionType.Current then
        blzWindow:GetDamageMeterOwner():SetSessionWindowSessionID(blzWindow, Enum.DamageMeterSessionType.Current)

    else
        blzWindow:GetDamageMeterOwner():SetSessionWindowSessionID(blzWindow, nil, sessionId)
    end
end

function bParser.ToggleDamageMeterSwap()
    Details.damage_meter_type = math.abs(Details.damage_meter_type - 1)
    return bParser.IsDamageMeterSwapped()
end

function bParser.IsDamageMeterSwapped()
    return Details.damage_meter_type ~= 0
end

---@param blzWindow blzwindow
---@param instance instance
local posses = function(blzWindow, instance)
    local anchor1, refFrame, anchor2, x, y = blzWindow:GetPoint(1)
    local refFrameName = refFrame and refFrame:GetName() or "UIParent"
    Details.damage_meter_position[blzWindow.sessionWindowIndex] = {anchor1, refFrameName, anchor2, x, y}

    local scrollBox = blzWindow.ScrollBox
    scrollBox:ClearAllPoints()
    scrollBox:SetPoint("topleft", instance.baseframe, "topleft", 0, 0)
    scrollBox:SetPoint("bottomright", instance.baseframe, "bottomright", 0, 0)

    blzWindow:ClearAllPoints()
    blzWindow:SetPoint("topleft", instance.baseframe, "topleft", 0, 0)
    blzWindow:SetPoint("bottomright", instance.baseframe, "bottomright", 0, 0)

    bParser.UpdateDamageMeterAppearance(blzWindow)

    for k,v in pairs(blzWindow) do
        if k ~= "ScrollBox" then
            if type(v) == "table" and v.Hide then
                v:Hide()
            end
        end
    end
end

---@param blzWindow blzwindow
local unposses = function(blzWindow)
    local position = Details.damage_meter_position[blzWindow.sessionWindowIndex]
    if position then
        local anchor1, refFrameName, anchor2, x, y = unpack(position)
        local refFrame = _G[refFrameName]
        if refFrame then
            blzWindow:ClearAllPoints()
            blzWindow:SetPoint(anchor1, refFrame, anchor2, x, y)
        end
    end
end

--bugs:
--for some reason the blizzard window 1, opened after a /reload, with details showing
--clicked to show blizzard dm, all bars desappear... none show even selecting a new segment
--clicked to swap back to details, the first bar doesn't show, it is hidden.

--CVarCallbackRegistry:RegisterCallback("damageMeterEnabled", function(...)
--    print("cvar changed", ...)
--end)

function bParser.UpdateAllDamageMeterWindowsAppearance()
    damageMeter:ForEachSessionWindow(function(blzWindow)
        bParser.UpdateDamageMeterAppearance(blzWindow)
    end)
end

function bParser.UpdateDamageMeterAppearance(blzWindow)
    local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
    if not SharedMedia then
        return
    end

    local instanceId = Details:GetLowerInstanceNumber()
    if instanceId then
        local instance = Details:GetInstance(instanceId)
        if instance then
            --texture
            local textureFile = SharedMedia:Fetch("statusbar", instance.row_info.texture)
            local textureFile2 = SharedMedia:Fetch("statusbar", instance.row_info.texture_background)
            local left_text_outline = instance.row_info.textL_outline
            local right_text_outline = instance.row_info.textR_outline
            local textL_outline_small = instance.row_info.textL_outline_small
            local textL_outline_small_color = instance.row_info.textL_outline_small_color
            local textR_outline_small = instance.row_info.textR_outline_small
            local textR_outline_small_color = instance.row_info.textR_outline_small_color

            local fontSize = instance.row_info.font_size

            --texture color values
            local bUseClassColor = instance.row_info.texture_class_colors
            local height = instance.row_info.height
            local spacing = instance.row_info.space.between

            --alpha
            local alpha = instance.row_info.alpha
            local bShowIcon = not instance.row_info.no_icon

            --font face
            instance.row_info.font_face_file = SharedMedia:Fetch("font", instance.row_info.font_face)

            blzWindow:ForEachEntryFrame(function(line)
                local statusBar = line:GetStatusBar()
                local background = line:GetBackground()
                local name = line:GetName()
                local value = line:GetValue()

                C_Timer.After(0, function()
                    local anchor1, relativeFrame, anchor2, x, y =  statusBar:GetPoint(3)
                    if anchor1 == "BOTTOMRIGHT" and detailsFramework.Math.IsNearlyEqual(-4, x, SMALL_NUMBER) then
                        statusBar:SetPoint(anchor1, relativeFrame, anchor2, -1, y)
                    end
                end)

                statusBar:SetStatusBarTexture(textureFile)
                statusBar.BackgroundEdge:SetTexture("")
                background:SetTexture(textureFile2)

                if left_text_outline then
                    detailsFramework:SetFontOutline(name, left_text_outline)
                    detailsFramework:SetFontOutline(name, left_text_outline)
                else
                    detailsFramework:SetFontOutline(name, nil)
                    detailsFramework:SetFontOutline(name, nil)
                end

                if right_text_outline then
                    detailsFramework:SetFontOutline(value, right_text_outline)
                    detailsFramework:SetFontOutline(value, right_text_outline)
                else
                    detailsFramework:SetFontOutline(value, nil)
                    detailsFramework:SetFontOutline(value, nil)
                end

                detailsFramework:SetFontFace(name, instance.row_info.font_face_file or "GameFontHighlight")
                detailsFramework:SetFontFace(value, instance.row_info.font_face_file or "GameFontHighlight")

                detailsFramework:SetFontSize(name, fontSize)
                detailsFramework:SetFontSize(value, fontSize)

                --small outline
                if (textL_outline_small) then
                    local color = textL_outline_small_color
                    name:SetShadowColor(color[1], color[2], color[3], color[4])
                    name:SetShadowOffset(1, -1)
                else
                    name:SetShadowColor(0, 0, 0, 0)
                end

                if (textR_outline_small) then
                    local color = textR_outline_small_color
                    value:SetShadowColor(color[1], color[2], color[3], color[4])
                    value:SetShadowOffset(1, -1)
                else
                    value:SetShadowColor(0, 0, 0, 0)
                end

                damageMeter:SetUseClassColor(bUseClassColor)
                damageMeter:SetBarHeight(height)
                damageMeter:SetBarSpacing(spacing)
                damageMeter:SetShowBarIcons(bShowIcon)
            end)
            blzWindow:RefreshLayout()
        end
    end
end

local enableDamageMeter = function()
    local isDamageMeterEnabled = C_CVar.GetCVarBool("damageMeterEnabled")
    if not isDamageMeterEnabled then
        C_CVar.SetCVar("damageMeterEnabled", "1")
    end
    damageMeter:Show()
end

---@type table<blzwindow, boolean>
local isBeingUseAsOverlay = {}

function bParser.MakeAsOverlay()
    if not bParser.IsDamageMeterSwapped() then
        local windowUsed = {}

        local makeAsOverlay = function(instance)
            enableDamageMeter()

            local blzWindow
            local lines = instance.barras

            damageMeter:ForEachSessionWindow(function(thisWindow)
                if not blzWindow and thisWindow and not windowUsed[thisWindow] then
                    windowUsed[thisWindow] = true
                    blzWindow = thisWindow
                end
            end)

            if not blzWindow then
                damageMeter:ShowNewSessionWindow()
                damageMeter:ForEachSessionWindow(function(thisWindow)
                    if not blzWindow and thisWindow and not windowUsed[thisWindow] then
                        windowUsed[thisWindow] = true
                        blzWindow = thisWindow
                    end
                end)
            end

            if blzWindow then
                blzWindow:Show()
                local i = 1
                blzWindow:ForEachEntryFrame(function(line)
                    if lines[i] then
                        line:SetAlpha(0)
                        line:ClearAllPoints()
                        line:SetPoint("topleft", lines[i], "topleft", 0, 0)
                        line:SetPoint("bottomright", lines[i], "bottomright", 0, 0)
                        i = i + 1
                    end
                end)

                isBeingUseAsOverlay[blzWindow] = true
            end
        end

        Details:InstanceCall(makeAsOverlay)
    end
end

function bParser.UnmakeAsOverlay()
    damageMeter:ForEachSessionWindow(function(blzWindow)
        if isBeingUseAsOverlay[blzWindow] then
            blzWindow:Refresh(ScrollBoxConstants.DiscardScrollPosition)
            blzWindow:Hide()
        end
    end)
end

local debugSwap = false

function bParser.UpdateDamageMeterSwap()
    if debugSwap then
        print("[DS] is swapped:", bParser.IsDamageMeterSwapped())
    end

    if bParser.IsDamageMeterSwapped() then
        --bParser.UnmakeAsOverlay()

        --show blizzard
        enableDamageMeter()

        local hideLines = function(instance)
            local allInstanceLines = instance.barras
            for i = 1, #allInstanceLines do
                allInstanceLines[i]:Hide()
            end
        end
        swappedFrame:SetScript("OnUpdate", function(self, elapsed)
            Details:InstanceCall(hideLines)
            if not damageMeter:IsShown() then
                damageMeter:Show()
            end
        end)

        local windowUsed = {}

        local swapToBlz = function(instance)
            local blzWindow

            damageMeter:ForEachSessionWindow(function(thisWindow)
                if not blzWindow and thisWindow and not windowUsed[thisWindow] then
                    windowUsed[thisWindow] = true
                    blzWindow = thisWindow
                    if debugSwap then
                        print("[DS] IC, has blzWindow: ", blzWindow, "shown:", blzWindow and blzWindow:IsShown())
                    end
                end
            end)

            if not blzWindow then
                if debugSwap then
                    print("[DS] blzWindow bit found, creating a new one")
                end

                damageMeter:ShowNewSessionWindow()

                damageMeter:ForEachSessionWindow(function(thisWindow)
                    if not blzWindow and thisWindow and not windowUsed[thisWindow] then
                        windowUsed[thisWindow] = true
                        blzWindow = thisWindow
                        if debugSwap then
                            print("[DS] IC, has blzWindow: ", blzWindow, "shown:", blzWindow and blzWindow:IsShown())
                        end
                    end
                end)
            end

            if blzWindow then
                blzWindow:Show()
                posses(blzWindow, instance)

                DAMAGE_METER_DEFAULT_BAR_HEIGHT = instance.row_info.height
                DAMAGE_METER_DEFAULT_BAR_SPACING = instance.row_info.spacing

                local mainDisplay, subDisplay = instance:GetDisplay()
                local damageMeterType = bParser.GetDamageMeterTypeFromDisplay(mainDisplay, subDisplay)
                if damageMeterType < 100 then
                    blzWindow:SetDamageMeterType(damageMeterType)
                end

                instance.blzWindow = blzWindow
                blzWindow:Refresh()

                if debugSwap then
                    print("[DS] blzWindow", blzWindow, "swapped correctly")
                end
            else
                if debugSwap then
                    print("[DS] blzWindow not found, period")
                end
            end
        end

        Details:InstanceCall(swapToBlz)

    else
        --show details
        local isDamageMeterEnabled = C_CVar.GetCVarBool("damageMeterEnabled")
        if isDamageMeterEnabled then
            C_CVar.SetCVar("damageMeterEnabled", "0")
        end
        damageMeter:Hide()

        swappedFrame:SetScript("OnUpdate", nil)

        damageMeter:ForEachSessionWindow(function(thisWindow)
            if thisWindow then
                unposses(thisWindow)
                thisWindow:GetDamageMeterOwner():HideSessionWindow(thisWindow)
            end
        end)

        --show details
        for i = 1, 10 do
            --damageMeter
            ---@type blzwindow
            local blzWindow = _G["DamageMeterSessionWindow" .. i]
            if blzWindow then
                --print("blizz window hide", i)
                blzWindow:GetDamageMeterOwner():HideSessionWindow(blzWindow)
            end
        end

        --update all windows
        Details:InstanceCallDetailsFunc(Details.FadeHandler.Fader, "IN", nil, "barras")
        Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse)
        Details:InstanceCallDetailsFunc(Details.AtualizaSoloMode_AfertReset)
        Details:InstanceCallDetailsFunc(Details.ResetaGump)
        Details:RefreshMainWindow(-1, true)

    end
end

function DetailsActionButtonTemplate_OnLoad(self)
    self:RegisterForClicks("AnyUp")


end

do return end

local secureButtons = {}

for i = 1, 5 do
    local b = CreateFrame("button", "DetailsTestBar" .. i, UIParent, "xml_DetailsActionButtonTemplate")
    b:SetPoint("left", UIParent, "left", 2, 200 + (-(i - 1) * 22))

    b.leftText = b:CreateFontString(nil, "overlay", "GameFontNormal")
    b.leftText:SetPoint("left", b, "left", 2, 0)
    b.leftText:SetText(i)

    b.rightText = b:CreateFontString(nil, "overlay", "GameFontNormal")
    b.rightText:SetPoint("right", b, "right", -2, 0)

    local initializationCode = [[
        self:SetAttribute("secureOnEnter", [====[
            self:RunFor(self, print('On Entered'))
        ]====])
        self:SetAttribute("secureOnLeave", [====[
            self:RunFor(self, print('On Left'))
        ]====])
    ]]

    b:SetAttribute("initialConfigFunction", initializationCode)

    --b:Run([[print("Button Loaded")]])
    --print(b.CallMethod)

    secureButtons[i] = b

    b:Hide()
end

local f = CreateFrame("frame")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        for i = 1, 5 do
            local b = secureButtons[i]
            b:Run([[self:RunFor(self, print("In Combat"))]])
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        --for i = 1, 5 do
        --    local b = secureButtons[i]
        --    b:Run([[self:RunFor(self, print("Out of Combat"))]])
        --end
    end
end)

