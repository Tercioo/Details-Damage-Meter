
local DF = _G["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return
end

local C_Timer = _G.C_Timer
local unpack = table.unpack or _G.unpack

--make a namespace for schedules
DF.Schedules = DF.Schedules or {}

---@class df_schedule : table
---@field NewTicker fun(time: number, callback: function, ...: any): timer
---@field NewLooper fun(time: number, callback: function, loopAmount: number, loopEndCallback: function?, checkPointCallback: function?, ...: any): timer
---@field NewTimer fun(time: number, callback: function, ...: any): timer
---@field Cancel fun(ticker: timer)
---@field After fun(time: number, callback: function)
---@field SetName fun(object: timer, name: string)
---@field RunNextTick fun(callback: function)

local triggerScheduledLoop = function(tickerObject)
    if (tickerObject:IsCancelled()) then
        return
    end

    local payload = tickerObject.payload
    local callback = tickerObject.callback

    local result, errortext = pcall(callback, unpack(payload))
    if (not result) then
        DF:Msg("error on scheduler: ",tickerObject.path , tickerObject.name, errortext)
    end

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
function DF.Schedules.NewLooper(time, callback, loopAmount, loopEndCallback, checkPointCallback, ...)
    local payload = {...}
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

    local result, errortext = pcall(callback, unpack(payload))
    if (not result) then
        DF:Msg("error on scheduler: ",tickerObject.path , tickerObject.name, errortext)
    end
    return result
end

--schedule to repeat a task with an interval of @time, keep ticking until cancelled
function DF.Schedules.NewTicker(time, callback, ...)
    local payload = {...}
    local newTicker = C_Timer.NewTicker(time, triggerScheduledTick)
    newTicker.payload = payload
    newTicker.callback = callback

    --debug
    newTicker.path = debugstack()
    --
    return newTicker
end

--schedule a task with an interval of @time
function DF.Schedules.NewTimer(time, callback, ...)
    local payload = {...}
    local newTimer = C_Timer.NewTimer(time, triggerScheduledTick)
    newTimer.payload = payload
    newTimer.callback = callback
    newTimer.expireAt = GetTime() + time

    --debug
    newTimer.path = debugstack()
    --

    return newTimer
end

--cancel an ongoing ticker, the native call tickerObject:Cancel() also works with no problem
function DF.Schedules.Cancel(tickerObject)
    --ignore if there's no ticker object
    if (tickerObject) then
        return tickerObject:Cancel()
    end
end

--schedule a task with an interval of @time without payload
function DF.Schedules.After(time, callback)
    C_Timer.After(time, callback)
end

function DF.Schedules.SetName(object, name)
    object.name = name
end

function DF.Schedules.RunNextTick(callback)
    return DF.Schedules.After(0, callback)
end