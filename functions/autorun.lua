local Details = _G.Details
local detailsFramework = _G.DetailsFramework
local C_Timer = _G.C_Timer
local addonName, Details222 = ...
local load = loadstring

--auto run scripts
local functionCache = {}

--compile and store code
function Details222.AutoRunCode.RecompileAutoRunCode()
    for codeKey, code in pairs(Details222.AutoRunCode.CodeTable) do
        local func, errorText = load(code)
        if (func) then
            detailsFramework:SetEnvironment(func)
            functionCache[codeKey] = func
        else
            --if the code didn't pass, create a dummy function for it without triggering errors
            functionCache[codeKey] = function() end
        end
    end
end

--function to dispatch events
function Details222.AutoRunCode.DispatchAutoRunCode(codeKey)
    local func = functionCache[codeKey]

	if (type(func) ~= "function") then
        Details:Msg("error running function for auto run script", codeKey)
		return
	end

	local okay, errortext = pcall(func)

	if (not okay) then
        Details:Msg("error running auto run script: ", codeKey, errortext)
		return
	end
end

--auto run frame to dispatch scrtips for some events that details! doesn't handle
local autoRunCodeEventFrame = CreateFrame("frame")

if (not detailsFramework.IsTimewalkWoW()) then
    autoRunCodeEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
end

autoRunCodeEventFrame.OnEventFunc = function(self, event)
    --ignore events triggered more than once in a small time window
    if (autoRunCodeEventFrame[event] and not autoRunCodeEventFrame[event]:IsCancelled()) then
        return
    end

    if (event == "PLAYER_SPECIALIZATION_CHANGED") then
        --create a trigger for the event, many times it is triggered more than once
        --so if the event is triggered a second time, it will be ignored
        local newTimer = C_Timer.NewTimer(1, function()
            Details222.AutoRunCode.DispatchAutoRunCode("on_specchanged")

            --clear and invalidate the timer
            autoRunCodeEventFrame[event]:Cancel()
            autoRunCodeEventFrame[event] = nil
        end)

        --store the trigger
        autoRunCodeEventFrame[event] = newTimer
    end
end

autoRunCodeEventFrame:SetScript("OnEvent", autoRunCodeEventFrame.OnEventFunc)

--dispatch scripts at startup
C_Timer.After(2, function()
    Details222.AutoRunCode.DispatchAutoRunCode("on_init")
    Details222.AutoRunCode.DispatchAutoRunCode("on_specchanged")
    Details222.AutoRunCode.DispatchAutoRunCode("on_zonechanged")

    if (_G.InCombatLockdown()) then
        Details222.AutoRunCode.DispatchAutoRunCode("on_entercombat")
    else
        Details222.AutoRunCode.DispatchAutoRunCode("on_leavecombat")
    end

    Details222.AutoRunCode.DispatchAutoRunCode("on_groupchange")
end)

function Details222.AutoRunCode.StartAutoRun()
    local newData = detailsFramework.table.copy({}, Details.run_code)
    Details.run_code = nil
    Details222.AutoRunCode.CodeTable = newData
    Details222.AutoRunCode.RecompileAutoRunCode()
end

function Details222.AutoRunCode.OnLogout()
    _detalhes_global.run_code = Details222.AutoRunCode.CodeTable
end