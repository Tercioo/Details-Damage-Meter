
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@type details_allinonewindow
local AllInOneWindow = Details222.AllInOneWindow

local eventsAlreadyRegistered = false

--called from startup.lua
function AllInOneWindow:RegisterEvents()
    if (eventsAlreadyRegistered) then
        return
    end
    eventsAlreadyRegistered = true

    --event listener
    local eventListener = Details:CreateEventListener()

    eventListener:RegisterEvent("COMBAT_PLAYER_ENTER", function()
        if (not AllInOneWindow:HasOpenWindow()) then
            return
        end

        --first, clean up all windows, doing the fade out animation on all lines.
        --this code here is just for debug, hide all scroll lines:
        local allWindows = AllInOneWindow:GetAllWindows()
        for i = 1, #allWindows do
            local windowFrame = allWindows[i]
            if (windowFrame:IsOpen()) then
                local scrollFrame = windowFrame:GetScrollFrame()
                scrollFrame:SetData({})
                scrollFrame:Refresh()
            end
        end

        --second, start a refresher to update the lines with the information provided.
        AllInOneWindow:StartRefresher() --this will start the refresher
    end)

    eventListener:RegisterEvent("COMBAT_PLAYER_LEAVE", function()
        if (not AllInOneWindow:HasOpenWindow()) then
            return
        end

        AllInOneWindow:StopRefresher()
    end)

    eventListener:RegisterEvent("COMBAT_INVALID", function()
        if (not AllInOneWindow:HasOpenWindow()) then
            return
        end

        C_Timer.After(0.1, function()
            AllInOneWindow:ExecuteOnAllOpenedWindows("ValidateSegment")
        end)
    end)

    eventListener:RegisterEvent("DETAILS_DATA_RESET", function()
        if (not AllInOneWindow:HasOpenWindow()) then
            return
        end

        AllInOneWindow:ExecuteOnAllOpenedWindows("ValidateSegment")
    end)

end