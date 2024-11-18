
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local defaultCreatureIconCoords = {0, 1, 0, 0.95}

---@class df_encounterinfo : table
---@field name string
---@field mapId number
---@field instanceId number
---@field dungeonEncounterId number
---@field journalEncounterId number
---@field journalInstanceId number
---@field creatureName string
---@field creatureIcon string
---@field creatureIconCoords table<number, number, number, number>
---@field creatureId number
---@field creatureDisplayId number
---@field creatureUIModelSceneId number

---@class df_instanceinfo : table
---@field name string
---@field bgImage string
---@field mapId number
---@field instanceId number
---@field journalInstanceId number
---@field isRaid boolean
---@field encountersArray df_encounterinfo[]
---@field encountersByName table<string, df_encounterinfo>
---@field encountersByDungeonEncounterId table<number, df_encounterinfo>
---@field encountersByJournalEncounterId table<number, df_encounterinfo>
---@field icon string
---@field iconSize table<number, number>
---@field iconCoords table<number, number, number, number>
---@field iconLore string
---@field iconLoreSize table<number, number>
---@field iconLoreCoords table<number, number, number, number>
---@field iconTexture string
---@field iconTextureSize table<number, number>
---@field iconTextureCoords table<number, number, number, number>

---@class df_ejc : table
---@field GetEncounterInfo fun(id:number):df_encounterinfo
---@field GetInstanceInfo fun(id:instanceid|instancename|mapid):df_instanceinfo
---@field GetInstanceEJID fun(...):number
---@field IsCurrentContent fun(id:number):boolean
---@field GetAllEncountersFromInstance fun(id:any):df_encounterinfo[]
---@field CreateEncounterJournalDump fun()
---@field GetAllRaidInstances fun():df_instanceinfo[]
---@field GetAllDungeonInstances fun():df_instanceinfo[]
---@field GetEncounterSpells fun(journalInstanceId:number, journalEncounterId:number, difficulty:number):df_ejspell[]
---@field CacheRaidData_OnlyRaidInstances table<number, df_instanceinfo[]>
---@field CacheRaidData_OnlyDungeonInstances table<number, df_instanceinfo[]>
---@field CacheRaidData_ByInstanceId table<number, df_instanceinfo>
---@field CacheRaidData_ByInstanceName table<string, df_instanceinfo>
---@field CacheRaidData_ByMapId table<number, df_instanceinfo>
---@field CacheEncountersByEncounterName table<string, df_encounterinfo>
---@field CacheEncountersBy_EncounterName table<string, df_encounterinfo>
---@field CacheEncountersBy_EncounterId table<number, df_encounterinfo>
---@field CacheEncountersBy_JournalEncounterId table<number, df_encounterinfo>
---@field Id_To_JournalInstanceID table<number, number>
---@field CurrentContent table<number, boolean>

local bHasLoaded = false

if (detailsFramework.Ejc) then
    wipe(detailsFramework.Ejc)
end

detailsFramework.Ejc = {}
local Ejc = detailsFramework.Ejc

---@return df_encounterinfo?
function Ejc.GetEncounterInfo(id)
    if (not bHasLoaded) then
        Ejc.CreateEncounterJournalDump()
    end

    ---@type df_encounterinfo
    local encounterData = Ejc.CacheEncountersBy_EncounterId[id]
    if (encounterData) then
        return encounterData
    end

    encounterData = Ejc.CacheEncountersBy_EncounterName[id]
    if (encounterData) then
        return encounterData
    end

    encounterData = Ejc.CacheEncountersBy_JournalEncounterId[id]
    if (encounterData) then
        return encounterData
    end
end

function Ejc.Load()
    Ejc.CreateEncounterJournalDump()
end

---@param id instanceid|instancename|mapid
---@return df_instanceinfo?
function Ejc.GetInstanceInfo(id)
    if (not id) then
        return
    end

    if (not bHasLoaded) then
        Ejc.CreateEncounterJournalDump()
    end

    if (id == 463) then --fall
        id = 1209
    end

    ---@type df_instanceinfo
    local instanceData = Ejc.CacheRaidData_ByInstanceId[id]
    if (instanceData) then
        return instanceData
    end

    instanceData = Ejc.CacheRaidData_ByInstanceName[id]
    if (instanceData) then
        return instanceData
    end

    instanceData = Ejc.CacheRaidData_ByMapId[id]
    if (instanceData) then
        return instanceData
    end
end

function Ejc.GetInstanceEJID(...)
    for i = 1, select("#", ...) do
        local id = select(i, ...)
        local EJID = Ejc.Id_To_JournalInstanceID[id]
        if (EJID) then
            return EJID
        end
    end
end

function Ejc.IsCurrentContent(id)
    return Ejc.CurrentContent[id]
end

function Ejc.GetAllEncountersFromInstance(id)
    if (not bHasLoaded) then
        Ejc.CreateEncounterJournalDump()
    end

    local instanceData = Ejc.GetInstanceInfo(id)
    if (instanceData) then
        return instanceData.encountersArray
    end
end

function Ejc.GetAllRaidInstances()
    if (not bHasLoaded) then
        Ejc.CreateEncounterJournalDump()
    end
    return Ejc.CacheRaidData_OnlyRaidInstances
end

function Ejc.GetAllDungeonInstances()
    if (not bHasLoaded) then
        Ejc.CreateEncounterJournalDump()
    end
    return Ejc.CacheRaidData_OnlyDungeonInstances
end

---@class df_ejspell : table
---@field spellID number
---@field title string header name in the encounter journal
---@field abilityIcon number journal spell icon

function Ejc.GetEncounterSpells(journalInstanceId, journalEncounterId, difficulty)
    EJ_SetDifficulty(difficulty or 16)
    EJ_SelectInstance(journalInstanceId)
    EJ_SelectEncounter(journalEncounterId)

    local encounterName, encounterDescription, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfo(journalEncounterId)
    local sectionStack = {}
    local currentSectionId = rootSectionID

    local spells = {}

    repeat
        local sectionInfo = C_EncounterJournal.GetSectionInfo(currentSectionId)
        if (not sectionInfo) then
            break
        end

        if (sectionInfo.spellID) then
            local spellInfo = C_Spell.GetSpellInfo(sectionInfo.spellID)
            sectionInfo.spellName = spellInfo and spellInfo.name
            sectionInfo.spellIcon = spellInfo and spellInfo.iconID

            table.insert(spells, sectionInfo)

            spells[sectionInfo.spellID] = sectionInfo
            if (sectionInfo.spellName) then
                spells[sectionInfo.spellName] = sectionInfo
            end
            if (sectionInfo.title) then
                spells[sectionInfo.title] = sectionInfo
            end
        end

        if (sectionInfo.siblingSectionID) then
            table.insert(sectionStack, sectionInfo.siblingSectionID)
        end

        if (sectionInfo.firstChildSectionID) then
            table.insert(sectionStack, sectionInfo.firstChildSectionID)
        end

        currentSectionId = table.remove(sectionStack)
    until not currentSectionId
end

function Ejc.CreateEncounterJournalDump()
    --if the cache has been already created, then return
    if (bHasLoaded) then
        return
    else
        bHasLoaded = true
    end

    --this table store ids which indicates the bossId, encounterId or mapId is a content from the current expansion
    Ejc.CurrentContent = {}

    Ejc.CacheRaidData_ByInstanceId = {}
    Ejc.CacheRaidData_ByInstanceName = {} --this is localized name
    Ejc.CacheRaidData_ByMapId = {} --retrivied from GetInstanceInfo()
    Ejc.CacheEncountersByEncounterName = {}
    Ejc.CacheEncountersBy_EncounterName = {}
    Ejc.CacheEncountersBy_EncounterId = {}
    Ejc.CacheEncountersBy_JournalEncounterId = {}
    Ejc.CacheRaidData_OnlyRaidInstances = {}
    Ejc.CacheRaidData_OnlyDungeonInstances = {}

    ---cahe the uiMapID pointing to the instanceID
    ---this replace the need to call EJ_GetInstanceForMap to get the journalInstanceID
    ---@type table
    local id_to_journalInstanceID = {}
    Ejc.Id_To_JournalInstanceID = id_to_journalInstanceID

    --if the expansion does not support the encounter journal, then return
    if (not EncounterJournal_LoadUI) then
        return
    end

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

                    Ejc.CurrentContent[journalInstanceID] = true
                    Ejc.CurrentContent[dungeonUiMapID] = true
                    Ejc.CurrentContent[instanceID] = true
                    Ejc.CurrentContent[instanceName] = true

                    --select the raid instance, this allow to retrieve data about the encounters of the instance
                    EJ_SelectInstance(journalInstanceID)

                    --build a table with data of the raid instance
                    local instanceData = {
                        name = instanceName,
                        bgImage = bgImage,
                        mapId = dungeonUiMapID,
                        instanceId = instanceID,
                        journalInstanceId = journalInstanceID,
                        isRaid = bIsRaid,

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
                    Ejc.CacheRaidData_ByInstanceId[journalInstanceID] = instanceData
                    Ejc.CacheRaidData_ByInstanceId[instanceID] = instanceData
                    Ejc.CacheRaidData_ByInstanceName[instanceName] = instanceData
                    Ejc.CacheRaidData_ByMapId[dungeonUiMapID] = instanceData

                    if (bIsRaid) then
                        Ejc.CacheRaidData_OnlyRaidInstances[#Ejc.CacheRaidData_OnlyRaidInstances+1] = instanceData
                    else
                        Ejc.CacheRaidData_OnlyDungeonInstances[#Ejc.CacheRaidData_OnlyDungeonInstances+1] = instanceData
                    end

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

                            Ejc.CurrentContent[encounterName] = true
                            Ejc.CurrentContent[journalEncounterID] = true
                            Ejc.CurrentContent[dungeonEncounterID] = true

                            local journalEncounterCreatureId, creatureName, creatureDescription, creatureDisplayID, iconImage, uiModelSceneID = EJ_GetCreatureInfo(1, journalEncounterID)
                            if (journalEncounterCreatureId) then
                                encounterData.creatureName = creatureName
                                encounterData.creatureIcon = iconImage
                                encounterData.creatureIconCoords = defaultCreatureIconCoords
                                encounterData.creatureId = journalEncounterCreatureId
                                encounterData.creatureDisplayId = creatureDisplayID
                                encounterData.creatureUIModelSceneId = uiModelSceneID
                            end

                            instanceData.encountersArray[#instanceData.encountersArray+1] = encounterData
                            instanceData.encountersByName[encounterName] = encounterData
                            --print(instanceName, encounterName, journalEncounterID, journalInstanceID, dungeonEncounterID, instanceID)
                            instanceData.encountersByDungeonEncounterId[dungeonEncounterID] = encounterData
                            instanceData.encountersByJournalEncounterId[journalEncounterID] = encounterData
                            Ejc.CacheEncountersBy_EncounterName[encounterName] = encounterData
                            Ejc.CacheEncountersBy_EncounterId[dungeonEncounterID] = encounterData
                            Ejc.CacheEncountersBy_JournalEncounterId[journalEncounterID] = encounterData

                            id_to_journalInstanceID[encounterName] = journalInstanceID
                            id_to_journalInstanceID[dungeonEncounterID] = journalInstanceID
                            id_to_journalInstanceID[journalEncounterID] = journalInstanceID
                        end
                    end
                end
            end
        end
    end
end