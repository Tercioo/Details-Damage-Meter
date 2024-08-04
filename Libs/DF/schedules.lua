
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local C_Timer = _G.C_Timer
local unpack = table.unpack or _G.unpack
local GetTime = GetTime

local CONST_DEBUG_ENABLED = false

--make a namespace for schedules
detailsFramework.Schedules = detailsFramework.Schedules or {}

detailsFramework.Schedules.AfterCombatSchedules = {
    withId = {},
    withoutId = {},
}

---@class df_schedule : table
---@field NewTicker fun(time: number, callback: function, ...: any): timer
---@field NewLooper fun(time: number, callback: function, loopAmount: number, loopEndCallback: function?, checkPointCallback: function?, ...: any): timer
---@field NewTimer fun(time: number, callback: function, ...: any): timer
---@field Cancel fun(ticker: timer)
---@field After fun(time: number, callback: function)
---@field SetName fun(object: timer, name: string)
---@field RunNextTick fun(callback: function)
---@field AfterCombat fun(callback:function, id:any, ...: any)
---@field CancelAfterCombat fun(id: any)
---@field CancelAllAfterCombat fun()
---@field IsAfterCombatScheduled fun(id: any): boolean
---@field LazyExecute fun(callback: function, payload: table?, maxIterations: number?, onEndCallback: function?): table
---@field AfterById fun(time: number, callback: function, id: any, ...: any): timer

---@class df_looper : table
---@field payload table
---@field callback function
---@field loopEndCallback function?
---@field checkPointCallback function?
---@field nextCheckPoint number
---@field lastLoop number
---@field currentLoop number
---@field Cancel fun()
---@field IsCancelled fun(): boolean

local eventFrame = CreateFrame("frame")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function(self, event)
    if (event == "PLAYER_REGEN_ENABLED") then
        for _, schedule in ipairs(detailsFramework.Schedules.AfterCombatSchedules.withoutId) do
            xpcall(schedule.callback, geterrorhandler(), unpack(schedule.payload))
        end

        for _, schedule in pairs(detailsFramework.Schedules.AfterCombatSchedules.withId) do
            xpcall(schedule.callback, geterrorhandler(), unpack(schedule.payload))
        end

        table.wipe(detailsFramework.Schedules.AfterCombatSchedules.withoutId)
        table.wipe(detailsFramework.Schedules.AfterCombatSchedules.withId)
    end
end)

local triggerScheduledLoop = function(tickerObject)
    if (tickerObject:IsCancelled()) then
        return
    end

    local payload = tickerObject.payload
    local callback = tickerObject.callback

    --local result, errortext = pcall(callback, unpack(payload))
    local runOkay, result = xpcall(callback, geterrorhandler(), unpack(payload))
    --if (not result) then
    --    detailsFramework:Msg("error on scheduler: ",tickerObject.path , tickerObject.name, errortext)
    --end

    local checkPointCallback = tickerObject.checkPointCallback
    if (checkPointCallback) then
        if (GetTime() >= tickerObject.nextCheckPoint) then
            local checkPointResult = checkPointCallback(unpack(payload))
            if (not checkPointResult) then
                tickerObject:Cancel()
                if (tickerObject.loopEndCallback) then
                    tickerObject.loopEndCallback()
                end
                return
            end
            tickerObject.nextCheckPoint = GetTime() + 1
        end
    end

    tickerObject.currentLoop = tickerObject.currentLoop + 1

    if (tickerObject.currentLoop == tickerObject.lastLoop) then
        tickerObject:Cancel()
        if (tickerObject.loopEndCallback) then
            tickerObject.loopEndCallback()
        end
    end

    return result
end

---start a loop which will tick @loopAmount of times, then call @loopEndCallback if exists
---checkPointCallback will be called every time the loop ticks, if it returns false, the loop will be cancelled
---@param time number
---@param callback function
---@param loopAmount number
---@param loopEndCallback function?
---@param checkPointCallback function?
---@vararg any
---@return df_looper
function detailsFramework.Schedules.NewLooper(time, callback, loopAmount, loopEndCallback, checkPointCallback, ...)
    local payload = {...}
    ---@type df_looper
    local newLooper = C_Timer.NewTicker(time, triggerScheduledLoop, loopAmount)
    newLooper.payload = payload
    newLooper.callback = callback
    newLooper.loopEndCallback = loopEndCallback
    newLooper.checkPointCallback = checkPointCallback
    newLooper.nextCheckPoint = GetTime() + 1
    newLooper.lastLoop = loopAmount
    newLooper.currentLoop = 1
    return newLooper
end

--run a scheduled function with its payload
local triggerScheduledTick = function(tickerObject)
    local payload = tickerObject.payload
    local callback = tickerObject.callback

    local runOkay, result = xpcall(callback, geterrorhandler(), unpack(payload))
    --local result, errortext = pcall(callback, unpack(payload))
    --if (not result) then
    --    detailsFramework:Msg("error on scheduler: ",tickerObject.path , tickerObject.name, errortext)
    --end
    return result
end

--schedule to repeat a task with an interval of @time, keep ticking until cancelled
function detailsFramework.Schedules.NewTicker(time, callback, ...)
    local payload = {...}
    local newTicker = C_Timer.NewTicker(time, triggerScheduledTick)
    newTicker.payload = payload
    newTicker.callback = callback

    --debug
    newTicker.path = CONST_DEBUG_ENABLED and debugstack() or ""

    return newTicker
end

--schedule a function/callback/ to run after 'time' with a payload passed in the varargs
--return an object that can be used to cancel the scheduled task
--difference from Schedules.After is that this function returns an object that can be used to cancel the scheduled task and also pass a payload to the callback
--prompt example: schedule 'function variable name' to run after 'time' amount of seconds with payload 'variable name, variable name...'
--prompt example: run 'function name' after 'time' leaving an object as reference
function detailsFramework.Schedules.NewTimer(time, callback, ...)
    local payload = {...}
    local newTimer = C_Timer.NewTimer(time, triggerScheduledTick)
    newTimer.payload = payload
    newTimer.callback = callback
    newTimer.expireAt = GetTime() + time

    --debug
    newTimer.path = CONST_DEBUG_ENABLED and debugstack() or ""

    return newTimer
end

--cancel an ongoing ticker or timer, the native call tickerObject:Cancel() also works
---prompt example: cancel schedule 'variable name'
---@param tickerObject timer
function detailsFramework.Schedules.Cancel(tickerObject)
    --ignore if there's no ticker object
    if (tickerObject) then
        return tickerObject:Cancel()
    end
end

--schedule a task to be executed when the player leaves combat
function detailsFramework.Schedules.AfterCombat(callback, id, ...)
    local bInCombatLockdown = UnitAffectingCombat("player") or InCombatLockdown()

    if (not bInCombatLockdown) then
        xpcall(callback, geterrorhandler(), ...)
        return
    end

    local payload = {...}

    if (id) then
        detailsFramework.Schedules.AfterCombatSchedules.withId[id] = {
            callback = callback,
            payload = payload,
            id = id,
        }
    else
        table.insert(detailsFramework.Schedules.AfterCombatSchedules.withoutId, {
            callback = callback,
            payload = payload,
        })
    end
end

function detailsFramework.Schedules.CancelAfterCombat(id)
    detailsFramework.Schedules.AfterCombatSchedules.withId[id] = nil
end

function detailsFramework.Schedules.CancelAllAfterCombat()
    table.wipe(detailsFramework.Schedules.AfterCombatSchedules.withId)
    table.wipe(detailsFramework.Schedules.AfterCombatSchedules.withoutId)
end

function detailsFramework.Schedules.IsAfterCombatScheduled(id)
    return detailsFramework.Schedules.AfterCombatSchedules.withId[id] ~= nil
end

---execute each frame a small portion of a big task
---the callback function receives a payload, the current iteration index and the max iterations
---if the callback function return true, the task is finished
---callback function signature: fun(payload: table, iterationCount:number, maxIterations:number):boolean return true if the task is finished
---payload table is the same table passed as argument to LazyExecute()
---@param callback function
---@param payload table?
---@param maxIterations number?
---@param onEndCallback function? execute when the task is finished or when maxIterations is reached
function detailsFramework.Schedules.LazyExecute(callback, payload, maxIterations, onEndCallback)
    assert(type(callback) == "function", "DetailsFramework.Schedules.LazyExecute() param #1 'callback' must be a function.")
    maxIterations = maxIterations or 100000
    payload = payload or {}
    local iterationIndex = 1

    local function wrapFunc()
        local bIsFinished = callback(payload, iterationIndex, maxIterations)
        if (not bIsFinished) then
            iterationIndex = iterationIndex + 1
            if (iterationIndex > maxIterations) then
                if (onEndCallback) then
                    detailsFramework:QuickDispatch(onEndCallback, payload)
                end
                return
            end
            C_Timer.After(0, function() wrapFunc() end)
        else
            if (onEndCallback) then
                detailsFramework:QuickDispatch(onEndCallback, payload)
            end
            return
        end
    end

    wrapFunc()

    return payload
end

--Schedules a callback function to be executed after a specified time delay.
--It uniquely identifies each scheduled task by an ID, cancel and replace any existing schedules with the same ID.
function detailsFramework.Schedules.AfterById(time, callback, id, ...)
    if (not detailsFramework.Schedules.ExecuteTimerTable) then
        detailsFramework.Schedules.ExecuteTimerTable = {}
    end

    local alreadyHaveTimer = detailsFramework.Schedules.ExecuteTimerTable[id]
    if (alreadyHaveTimer) then
        alreadyHaveTimer:Cancel()
    end

    local newTimer = detailsFramework.Schedules.NewTimer(time, callback, ...)
    detailsFramework.Schedules.ExecuteTimerTable[id] = newTimer

    return newTimer
end

--Schedules a callback function to be executed after a specified time delay.
--It uniquely identifies each scheduled task by an ID, if another schedule with the same id is made, it will be ignore until the previous one is finished.
function detailsFramework.Schedules.AfterByIdNoCancel(time, callback, id, ...)
    if (not detailsFramework.Schedules.ExecuteTimerTableNoCancel) then
        detailsFramework.Schedules.ExecuteTimerTableNoCancel = {}
    end

    local alreadyHaveTimer = detailsFramework.Schedules.ExecuteTimerTableNoCancel[id]
    if (alreadyHaveTimer) then
        return
    end

    local newTimer = detailsFramework.Schedules.NewTimer(time, callback, ...)
    detailsFramework.Schedules.ExecuteTimerTableNoCancel[id] = newTimer

    C_Timer.After(time, function()
        detailsFramework.Schedules.ExecuteTimerTableNoCancel[id] = nil
    end)

    return newTimer
end

--schedule a function to be called after 'time'
--prompt example: create a schedule that runs the function 'variable name' after 'time' amount of seconds
function detailsFramework.Schedules.After(time, callback)
    C_Timer.After(time, callback)
end

--schedule a function to be called on the next frame
--prompt example: run 'function name' on next tick
---@param callback function
function detailsFramework.Schedules.RunNextTick(callback)
    return detailsFramework.Schedules.After(0, callback)
end

--set a name to a scheduled object
---@param object timer
---@param name string
function detailsFramework.Schedules.SetName(object, name)
    object.name = name
end