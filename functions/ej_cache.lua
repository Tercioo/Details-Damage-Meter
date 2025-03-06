
local Details = _G.Details
local addonName, Details222 = ...
local ipairs = ipairs --lua local
local detailsFramework = DetailsFramework

local ejTable = Details222.EncounterJournalDump

--maybe also cache old expansions and perhaps current expansion dungeons that aren't in the current mythic+ season

---@return details_encounterinfo?
function Details:GetEncounterInfo(id)
    if (not Details222.EJCache.CacheCreated) then
        Details222.EJCache.CreateEncounterJournalDump()
    end

    ---@type details_encounterinfo
    local encounterData = Details222.EJCache.CacheEncountersBy_EncounterId[id]
    if (encounterData) then
        return encounterData
    end

    encounterData = Details222.EJCache.CacheEncountersBy_EncounterName[id]
    if (encounterData) then
        return encounterData
    end

    encounterData = Details222.EJCache.CacheEncountersBy_JournalEncounterId[id]
    if (encounterData) then
        return encounterData
    end
end

---@param id instanceid|instancename|mapid
---@return details_instanceinfo?
function Details:GetInstanceInfo(id)
    if (not id) then
        return
    end

    if (not Details222.EJCache.CacheCreated) then
        Details222.EJCache.CreateEncounterJournalDump()
    end

    if (id == 463) then --fall
        id = 1209
    end

    ---@type details_instanceinfo
    local instanceData = Details222.EJCache.CacheRaidData_ByInstanceId[id]
    if (instanceData) then
        return instanceData
    end

    instanceData = Details222.EJCache.CacheRaidData_ByInstanceName[id]
    if (instanceData) then
        return instanceData
    end

    instanceData = Details222.EJCache.CacheRaidData_ByMapId[id]
    if (instanceData) then
        return instanceData
    end
end

function Details:GetInstances()

end

function Details:DumpInstanceInfo()
    dumpt(Details222.EJCache.CacheRaidData_ByInstanceId)
end

function Details:GetInstanceEJID(...)
    for i = 1, select("#", ...) do
        local id = select(i, ...)
        local EJID = Details222.EJCache.Id_To_JournalInstanceID[id]
        if (EJID) then
            return EJID
        end
    end
end

function Details222.EJCache.IsCurrentContent(id)
    return Details222.EJCache.CurrentContent[id]
end

function Details222.EJCache.CreateEncounterJournalDump()
    --if the cache has been already created, then return
    if (Details222.EJCache.CacheCreated) then
        return
    else
        Details222.EJCache.CacheCreated = true
    end

    --this table store ids which indicates the bossId, encounterId or mapId is a content from the current expansion
    Details222.EJCache.CurrentContent = {}

    Details222.EJCache.CacheRaidData_ByInstanceId = {}
    Details222.EJCache.CacheRaidData_ByInstanceName = {} --this is localized name
    Details222.EJCache.CacheRaidData_ByMapId = {} --retrivied from GetInstanceInfo()
    Details222.EJCache.CacheEncountersByEncounterName = {}
    Details222.EJCache.CacheEncountersBy_EncounterName = {}
    Details222.EJCache.CacheEncountersBy_EncounterId = {}
    Details222.EJCache.CacheEncountersBy_JournalEncounterId = {}

    ---cahe the uiMapID pointing to the instanceID
    ---this replace the need to call EJ_GetInstanceForMap to get the journalInstanceID
    ---@type table
    local id_to_journalInstanceID = {}
    Details222.EJCache.Id_To_JournalInstanceID = id_to_journalInstanceID

    --if the expansion does not support the encounter journal, then return
    if (not EncounterJournal_LoadUI) then
        return
    end

    --if true then return end

    local ejCacheSaved = Details.encounter_journal_cache

    local data = {}

    ---returns the number of valid encounter journal tier indices
    ---@type number
    local tierAmount = EJ_GetNumTiers() --return 11 for dragonisles, is returning 11 for wow11 as well

    ---returns the currently active encounter journal tier index
    ---could also be tierAmount - 1
    ---because the tier is "current season"
    ---@type number
    local currentTierId = tierAmount --EJ_GetCurrentTier(), for some unknown reason, this function is returning 3 on retail

    ---maximum amount of dungeons in the expansion
    ---@type number
    local maxAmountOfDungeons = 20

    ---the index of the first raid tier in the expansion, ignoring the first tier as it is open world bosses
    ---@type number
    local raidTierStartIndex = 2

    ---max amount of bosses which a raid tier can have
    ---@type number
    local maxRaidBosses = 20

    ---two iterations are required, one for dungeons and another for raids
    ---this table store two booleans that are passed to EJ_GetInstanceByIndex second argument, to indicate if we want to get dungeons or raids
    local tGetDungeonsOrRaids = {false, true}

    do --get raid instances data
        for i = 1, #tGetDungeonsOrRaids do
            local bIsRaid = tGetDungeonsOrRaids[i]

            --select the tier, use current tier - 1 for raids, as the currentTier only shows the latest release raid
            --use current tier for dungeons, as the current tier shows the dungeons used for the current season of Mythic+
            local startIndex, endIndex
            if (bIsRaid) then
                if (detailsFramework.IsCataWow()) then
                    if (currentTierId == 1) then --Cata has only one tier. Looking up tier 0 errors. ~CATA
                        break
                    end
                end

                EJ_SelectTier(currentTierId) --print("tier selected:", currentTierId - 1, "raids") --debug: was (currentTierId - 1), but was selecting wow10 content
                startIndex = raidTierStartIndex
                endIndex = 20
            else
                EJ_SelectTier(currentTierId) --print("tier selected:", currentTierId, "dungeons", "currentTierId:", currentTierId) --debug
                startIndex = 1
                endIndex = maxAmountOfDungeons
            end

            for instanceIndex = endIndex, startIndex, -1 do
                --instanceID: number - the unique ID of the instance, also returned by GetInstanceInfo() 8th return value
                --journalInstanceID: number - the ID used by the Encounter Journal API
                --dungeonUiMapID: number - the ID used by the world map API
                --dungeonEncounterID: number - same ID passed by the ENCOUNTER_STAR and ENCOUNTER_END events
                local journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonUiMapID, journalLink, shouldDisplayDifficulty, instanceID = EJ_GetInstanceByIndex(instanceIndex, bIsRaid)

                if (journalInstanceID) then
                    id_to_journalInstanceID[dungeonUiMapID] = journalInstanceID
                    id_to_journalInstanceID[instanceName] = journalInstanceID
                    id_to_journalInstanceID[instanceID] = journalInstanceID

                    Details222.EJCache.CurrentContent[journalInstanceID] = true
                    Details222.EJCache.CurrentContent[dungeonUiMapID] = true
                    Details222.EJCache.CurrentContent[instanceID] = true
                    Details222.EJCache.CurrentContent[instanceName] = true

                    --select the raid instance, this allow to retrieve data about the encounters of the instance
                    EJ_SelectInstance(journalInstanceID)

                    --build a table with data of the raid instance
                    local instanceData = {
                        name = instanceName,
                        bgImage = bgImage,
                        mapId = dungeonUiMapID,
                        instanceId = instanceID,
                        journalInstanceId = journalInstanceID,

                        encountersArray = {},
                        encountersByName = {},
                        encountersByDungeonEncounterId = {},
                        encountersByJournalEncounterId = {},

                        icon = buttonImage1,
                        iconSize = {70, 36},
                        iconCoords = {0.01, .67, 0.025, .725},

                        iconLore = loreImage,
                        iconLoreSize = {70, 36},
                        iconLoreCoords = {0, 1, 0, 0.95},

                        iconTexture = buttonImage2,
                        iconTextureSize = {70, 36},
                        iconTextureCoords = {0, 1, 0, 0.95},
                    }

                    --cache the raidData, in different tables, using different keys
                    Details222.EJCache.CacheRaidData_ByInstanceId[journalInstanceID] = instanceData
                    Details222.EJCache.CacheRaidData_ByInstanceId[instanceID] = instanceData
                    Details222.EJCache.CacheRaidData_ByInstanceName[instanceName] = instanceData
                    Details222.EJCache.CacheRaidData_ByMapId[dungeonUiMapID] = instanceData

                    --get information about the bosses in the raid
                    for encounterIndex = 1, maxRaidBosses do
                        local encounterName, encounterDescription, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(encounterIndex, journalInstanceID)

                        if (encounterName) then
                            local encounterData = {
                                name = encounterName,
                                mapId = dungeonUiMapID,
                                instanceId = instanceID,
                                dungeonEncounterId = dungeonEncounterID,
                                journalEncounterId = journalEncounterID,
                                journalInstanceId = journalInstanceID,
                            }

                            Details222.EJCache.CurrentContent[encounterName] = true
                            Details222.EJCache.CurrentContent[journalEncounterID] = true
                            Details222.EJCache.CurrentContent[dungeonEncounterID] = true

                            local journalEncounterCreatureId, creatureName, creatureDescription, creatureDisplayID, iconImage, uiModelSceneID = EJ_GetCreatureInfo(1, journalEncounterID)
                            if (journalEncounterCreatureId) then
                                encounterData.creatureName = creatureName
                                encounterData.creatureIcon = iconImage
                                encounterData.creatureId = journalEncounterCreatureId
                                encounterData.creatureDisplayId = creatureDisplayID
                                encounterData.creatureUIModelSceneId = uiModelSceneID
                            end

                            instanceData.encountersArray[#instanceData.encountersArray+1] = encounterData
                            instanceData.encountersByName[encounterName] = encounterData
                            --print(instanceName, encounterName, journalEncounterID, journalInstanceID, dungeonEncounterID, instanceID)
                            instanceData.encountersByDungeonEncounterId[dungeonEncounterID] = encounterData
                            instanceData.encountersByJournalEncounterId[journalEncounterID] = encounterData
                            Details222.EJCache.CacheEncountersBy_EncounterName[encounterName] = encounterData
                            Details222.EJCache.CacheEncountersBy_EncounterId[dungeonEncounterID] = encounterData
                            Details222.EJCache.CacheEncountersBy_JournalEncounterId[journalEncounterID] = encounterData

                            id_to_journalInstanceID[encounterName] = journalInstanceID
                            id_to_journalInstanceID[dungeonEncounterID] = journalInstanceID
                            id_to_journalInstanceID[journalEncounterID] = journalInstanceID
                        end
                    end
                end
            end
        end --end loop of raid or dungeon
    end
end