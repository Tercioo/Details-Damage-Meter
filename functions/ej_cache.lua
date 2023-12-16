
local Details = _G.Details
local addonName, Details222 = ...
local ipairs = ipairs --lua local
local detailsFramework = DetailsFramework

local ejTable = Details222.EncounterJournalDump


function Details.CreateEncounterJournalDump()
    local data = {}

    ---iterate among all raid instances, by passing true in the second argument of EJ_GetInstanceByIndex, indicates to the API we want to get raid instances
    ---@type boolean
    local bGetRaidInstances = true

    ---returns the number of valid encounter journal tier indices
    ---@type number
    local tierAmount = EJ_GetNumTiers()

    ---returns the currently active encounter journal tier index
    ---@type number
    local currentTier = EJ_GetCurrentTier()

    ---increment this each expansion
    ---@type number
    local currentTierId = 10 --maintenance | 10 is "Dragonflight"

    ---is the id of where it shows the mythic+ dungeons available for the season
    ---can be found in the adventure guide in the dungeons tab > dropdown
    ---@type number
    local currentMythicPlusTierId = 11 --maintenance | 11 is "Current Season"

    ---maximum amount of raid tiers in the expansion
    ---@type number
    local maxAmountOfRaidTiers = 10

    ---maximum amount of dungeons in the expansion
    ---@type number
    local maxAmountOfDungeons = 20

    ---the index of the first raid tier in the expansion, ignoring the first tier as it is open world bosses
    ---@type number
    local raidTierStartIndex = 2

    ---max amount of bosses which a raid tier can have
    ---@type number
    local maxRaidBosses = 20









end