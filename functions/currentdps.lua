
local Details = _G.Details
local addonName, Details222 = ...

--namespace
Details.CurrentDps = {}

local bIsEnabled = true

---@type combat
local currentCombatObject = nil

---@class details_currentdps_actorcache
---@field totalDamage number
---@field latestDamageAmount number
---@field cache number[]

---@type table<serial, details_currentdps_actorcache>
local currentDPSCache = Details222.CurrentDPS.Cache

---create a new cache table
---@return details_currentdps_actorcache
local createDpsCacheTable = function()
    ---@type details_currentdps_actorcache
    local cache = {
        totalDamage = 0,
        latestDamageAmount = 0,
        cache = {},
    }
    return cache
end

---get the actor cache from the current dps table
---@param serial serial
---@return details_currentdps_actorcache
local getActorDpsCache = function(serial)
    local dpsCache = currentDPSCache[serial]
    if (not dpsCache) then
        dpsCache = createDpsCacheTable()
        currentDPSCache[serial] = dpsCache
    end
    return dpsCache
end

---@type frame
local currentDpsFrame = CreateFrame("frame", "DetailsCurrentDpsUpdaterFrame", UIParent)

--amount of time to wait between each sample collection
local delayTimeBetweenUpdates = 0.10

--sample size in time to use to calculate the current dps
local secondsOfData = 5

--amount of time to wait until next update
local currentDelay = 0

--amount of small ticks that will be stored in the cache
local cacheSize = secondsOfData / delayTimeBetweenUpdates

--the index of the cache that will be removed when the cache is full
local cacheOverflowIndex = cacheSize + 1

---return how many seconds of data is being used to calculate the current dps
---@return number
function Details222.CurrentDPS.GetTimeSample()
    return secondsOfData
end

---on tick function
---@param self frame
---@param deltaTime number time elapsed between frames
currentDpsFrame.OnUpdateFunc = function(self, deltaTime)
    currentDelay = currentDelay + deltaTime
    if (currentDelay < delayTimeBetweenUpdates) then
        return
    end

    ---@type actorcontainer
    local damageContainer = currentCombatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

    for index, actorObject in damageContainer:ListActors() do
        ---@cast actorObject actor

        if (actorObject.grupo) then
            ---@type details_currentdps_actorcache
            local dpsCache = getActorDpsCache(actorObject.serial)

            --get the damage done on this tick
            local totalDamageThisTick = actorObject.total - dpsCache.latestDamageAmount

            --add the damage to the cache
            table.insert(dpsCache.cache, 1, totalDamageThisTick)

            --set the latest damage amount
            dpsCache.latestDamageAmount = actorObject.total

            --sum the total damage the actor inflicted
            dpsCache.totalDamage = dpsCache.totalDamage + totalDamageThisTick

            --cut the damage
            local damageRemoved = table.remove(dpsCache.cache, cacheOverflowIndex)
            if (damageRemoved) then
                dpsCache.totalDamage = dpsCache.totalDamage - damageRemoved
                dpsCache.totalDamage = math.max(0, dpsCache.totalDamage) --safe guard
            end
        end
    end

    currentDelay = 0
end

---return the value of the current dps for the given player
---serial = guid
---@param serial guid
---@return number|nil
function Details.CurrentDps.GetCurrentDps(serial)
    local dpsCache = currentDPSCache[serial]
    if (dpsCache) then
        local dps = dpsCache.totalDamage / secondsOfData
        return math.floor(dps)
    end
end

---return if the window bars can be sorted by real time dps
---@return boolean
function Details.CurrentDps.CanSortByRealTimeDps()
    if (not Details.in_combat) then
        return false
    end

    local bOrderDpsByRealTime = Details.use_realtimedps and Details.realtimedps_order_bars
    if (not bOrderDpsByRealTime) then
        bOrderDpsByRealTime = Details.realtimedps_always_arena and Details.zone_type == "arena"
    end
    return bOrderDpsByRealTime
end

--start the proccess of updating the current dps and hps for each player
function Details.CurrentDps.StartCurrentDpsTracker()
    currentCombatObject = Details:GetCurrentCombat()
    Details:Destroy(currentDPSCache)
    currentDpsFrame:SetScript("OnUpdate", currentDpsFrame.OnUpdateFunc)
end

--stop what the function above started
function Details.CurrentDps.StopCurrentDpsTracker()
    currentDpsFrame:SetScript("OnUpdate", nil)
end

--handle internal details! events
local eventListener = Details:CreateEventListener()

eventListener:RegisterEvent("COMBAT_PLAYER_ENTER", function()
    --check if can start the real time dps tracker
    local bCanStartRealTimeDpsTracker = Details.use_realtimedps or (Details.combat_log.evoker_show_realtimedps and Details.playerspecid == 1473)
    if (not bCanStartRealTimeDpsTracker) then
        bCanStartRealTimeDpsTracker = Details.zone_type == "arena" and Details.realtimedps_always_arena
    end

    if (bCanStartRealTimeDpsTracker) then
	    Details.CurrentDps.StartCurrentDpsTracker()
    end
end)

eventListener:RegisterEvent("COMBAT_PLAYER_LEAVE", function()
    Details.CurrentDps.StopCurrentDpsTracker()
end)