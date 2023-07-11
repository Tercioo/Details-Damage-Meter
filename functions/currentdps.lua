
local Details = _G.Details
local addonName, Details222 = ...

local bIsEnabled = true

---@type combat
local currentCombatObject = nil

---@class details_currentdps_actorcache
---@field totalDamage number
---@field currentDps number
---@field latestDamageAmount number
---@field cache number[]

--namespace
Details.CurrentDps = {
    ---@type table<serial, details_currentdps_actorcache>
    Dps = {},
    ---@type table<serial, details_currentdps_actorcache>
    Hps = {},
}

---create a new cache table
---@return details_currentdps_actorcache
local createDpsCacheTable = function()
    ---@type details_currentdps_actorcache
    local cache = {
        totalDamage = 0,
        currentDps = 0,
        latestDamageAmount = 0,
        cache = {},
    }
    return cache
end

---get the actor cache from the current dps table
---@param serial serial
---@return details_currentdps_actorcache
local getActorDpsCache = function(serial)
    local dpsCache = Details.CurrentDps.Dps[serial]
    if (not dpsCache) then
        dpsCache = createDpsCacheTable()
        Details.CurrentDps.Dps[serial] = dpsCache
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

--amount of time in seconds that the cache will hold
local dpsTime = delayTimeBetweenUpdates * cacheSize

--the index of the cache that will be removed when the cache is full
local cacheOverflowIndex = cacheSize + 1

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

        --if (actorObject:IsPlayer()) then
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
        --end
    end

    currentDelay = 0
end

--start the proccess of updating the current dps and hps for each player
function Details.CurrentDps.StartCurrentDpsTracker()
    currentCombatObject = Details:GetCurrentCombat()
    Details:Destroy(Details.CurrentDps.Dps)
    Details:Destroy(Details.CurrentDps.Hps)
    currentDpsFrame:SetScript("OnUpdate", currentDpsFrame.OnUpdateFunc)
end

--stop what the function above started
function Details.CurrentDps.StopCurrentDpsTracker()
    currentDpsFrame:SetScript("OnUpdate", nil)
end

--serial = guid
function Details.CurrentDps.GetCurrentDps(serial)
    local actorTable = Details.CurrentDps.Dps[serial]
    if (actorTable) then
        local currentDps = actorTable.currentDps
        local formatToKFunc = Details:GetCurrentToKFunction()
        --print("returning:", currentDps)
        return formatToKFunc(nil, currentDps)
    end
end

--handle internal details! events
local eventListener = Details:CreateEventListener()

eventListener:RegisterEvent("COMBAT_PLAYER_ENTER", function()
    if (bIsEnabled) then
	    Details.CurrentDps.StartCurrentDpsTracker()
    end
end)

eventListener:RegisterEvent("COMBAT_PLAYER_LEAVE", function()
    if (bIsEnabled) then
	    Details.CurrentDps.StopCurrentDpsTracker()
    end
end)