# DetailsFramework Encounter Journal (Ejc) Documentation

## Overview

The `DetailsFramework.Ejc` module provides a cached wrapper around the World of Warcraft Encounter Journal API. It loads encounter and instance data once on first access, then serves all subsequent lookups from memory. The module supports lookups by multiple key types (name, instanceId, mapId, dungeonEncounterId, journalEncounterId) and tracks which content belongs to the current expansion.

**Access:** `DF.Ejc` (where `DF` is `DetailsFramework`)

---

## Table of Contents

1. [Data Types](#1-data-types)
   - [df_encounterinfo](#11-df_encounterinfo)
   - [df_instanceinfo](#12-df_instanceinfo)
   - [df_ejspell](#13-df_ejspell)
2. [Functions](#2-functions)
   - [Ejc.Load](#21-ejcload)
   - [Ejc.CreateEncounterJournalDump](#22-ejccreateencounterjournaldump)
   - [Ejc.GetEncounterInfo](#23-ejcgetencounterinfo)
   - [Ejc.GetInstanceInfo](#24-ejcgetinstanceinfo)
   - [Ejc.GetInstanceEJID](#25-ejcgetinstanceejid)
   - [Ejc.IsCurrentContent](#26-ejciscurrentcontent)
   - [Ejc.GetAllEncountersFromInstance](#27-ejcgetallencountersfrominstance)
   - [Ejc.GetAllRaidInstances](#28-ejcgetallraidinstances)
   - [Ejc.GetAllDungeonInstances](#29-ejcgetalldungeoninstances)
   - [Ejc.GetEncounterSpells](#210-ejcgetencounterspells)
3. [Cache Tables](#3-cache-tables)
4. [Lazy Loading Behavior](#4-lazy-loading-behavior)
5. [Usage Examples](#5-usage-examples)

---

## 1. Data Types

### 1.1 df_encounterinfo

Represents a single boss encounter within an instance.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Localized encounter/boss name |
| `mapId` | `number` | The UI map ID of the instance containing this encounter |
| `instanceId` | `number` | The instance ID (same as returned by `GetInstanceInfo()`) |
| `dungeonEncounterId` | `number` | The encounter ID used by `ENCOUNTER_START` and `ENCOUNTER_END` events |
| `journalEncounterId` | `number` | The encounter ID used by the Encounter Journal API |
| `journalInstanceId` | `number` | The journal instance ID containing this encounter |
| `creatureName` | `string` | Name of the primary creature for the encounter |
| `creatureIcon` | `string` | Texture path/ID for the creature's portrait icon |
| `creatureIconCoords` | `table` | Tex coords `{left, right, top, bottom}` — default `{0, 1, 0, 0.95}` |
| `creatureId` | `number` | The journal encounter creature ID |
| `creatureDisplayId` | `number` | The creature's display ID for 3D model rendering |
| `creatureUIModelSceneId` | `number` | The UI model scene ID for positioning the creature model |

### 1.2 df_instanceinfo

Represents a dungeon or raid instance.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Localized instance name |
| `bgImage` | `string` | Background image texture for the instance |
| `mapId` | `number` | The UI map ID of the instance |
| `instanceId` | `number` | The instance ID from `GetInstanceInfo()` |
| `journalInstanceId` | `number` | The ID used by Encounter Journal API functions |
| `isRaid` | `boolean` | `true` if the instance is a raid, `false` for dungeons |
| `encountersArray` | `df_encounterinfo[]` | Ordered array of all encounters in the instance |
| `encountersByName` | `table<string, df_encounterinfo>` | Encounters indexed by localized name |
| `encountersByDungeonEncounterId` | `table<number, df_encounterinfo>` | Encounters indexed by dungeon encounter ID |
| `encountersByJournalEncounterId` | `table<number, df_encounterinfo>` | Encounters indexed by journal encounter ID |
| `icon` | `string` | Button image texture (primary) |
| `iconSize` | `table` | `{70, 36}` — default icon dimensions |
| `iconCoords` | `table` | `{0.01, 0.67, 0.025, 0.725}` — tex coords for the icon |
| `iconLore` | `string` | Lore image texture |
| `iconLoreSize` | `table` | `{70, 36}` — default lore icon dimensions |
| `iconLoreCoords` | `table` | `{0, 1, 0, 0.95}` — tex coords for the lore icon |
| `iconTexture` | `string` | Secondary button image texture |
| `iconTextureSize` | `table` | `{70, 36}` — default secondary icon dimensions |
| `iconTextureCoords` | `table` | `{0, 1, 0, 0.95}` — tex coords for the secondary icon |

### 1.3 df_ejspell

Represents a spell or ability listed in the Encounter Journal for a boss.

| Field | Type | Description |
|-------|------|-------------|
| `spellID` | `number` | The spell ID |
| `title` | `string` | Header name as shown in the Encounter Journal |
| `abilityIcon` | `number` | Journal spell icon texture ID |

The spell table returned by `GetEncounterSpells` also contains all fields from `C_EncounterJournal.GetSectionInfo()` plus two extra fields: `spellName` (from `C_Spell.GetSpellInfo`) and `spellIcon` (the spell's icon ID).

---

## 2. Functions

### 2.1 Ejc.Load

```lua
Ejc.Load()
```

Explicitly triggers the encounter journal cache build. This is equivalent to calling `Ejc.CreateEncounterJournalDump()`.

**Parameters:** None

**Returns:** Nothing

**Notes:**
- Most other functions call this automatically on first use (lazy loading).
- Call this at addon load time if you want to pre-populate the cache.

---

### 2.2 Ejc.CreateEncounterJournalDump

```lua
Ejc.CreateEncounterJournalDump()
```

Builds the full encounter journal cache by iterating over all current-expansion tiers for both dungeons and raids. Populates all `Cache*` tables and the `CurrentContent` and `Id_To_JournalInstanceID` lookup tables.

**Parameters:** None

**Returns:** Nothing

**Notes:**
- Only runs once; subsequent calls return immediately (guarded by `bHasLoaded` flag).
- Requires `EncounterJournal_LoadUI` to exist; on clients without encounter journal support, the function exits early.
- Iterates instances in reverse order (highest index first).
- Selects the current tier (`EJ_GetNumTiers() - 1`) for both raids and dungeons.
- For each instance, iterates up to 20 encounters and retrieves creature info for the first creature of each encounter.
- Special case: instance ID 463 is remapped to 1209 in `GetInstanceInfo`.

---

### 2.3 Ejc.GetEncounterInfo

```lua
local encounterData = Ejc.GetEncounterInfo(id)
```

Looks up encounter data by any of three key types, checked in order:
1. `dungeonEncounterId` (number) — the ID from `ENCOUNTER_START`/`ENCOUNTER_END` events
2. `encounterName` (string) — localized boss name
3. `journalEncounterId` (number) — the Encounter Journal API ID

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` or `string` | A dungeon encounter ID, encounter name, or journal encounter ID |

**Returns:** `df_encounterinfo?` — the encounter data table, or `nil` if not found

---

### 2.4 Ejc.GetInstanceInfo

```lua
local instanceData = Ejc.GetInstanceInfo(id)
```

Looks up instance data by any of three key types, checked in order:
1. `instanceId` (number) — from WoW's `GetInstanceInfo()` or the journal instance ID
2. `instanceName` (string) — localized instance name
3. `mapId` (number) — the UI map ID

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` or `string` | An instance ID, journal instance ID, instance name, or map ID |

**Returns:** `df_instanceinfo?` — the instance data table, or `nil` if not found

**Notes:**
- Returns `nil` if `id` is `nil`.
- Instance ID 463 is internally remapped to 1209 before lookup.

---

### 2.5 Ejc.GetInstanceEJID

```lua
local journalInstanceId = Ejc.GetInstanceEJID(id1, id2, ...)
```

Resolves any number of IDs (instance ID, map ID, encounter name, dungeon encounter ID, journal encounter ID) to a journal instance ID. Returns the first match found.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `...` | `number` or `string` (vararg) | One or more IDs to try resolving |

**Returns:** `number?` — the journal instance ID, or `nil` if none matched

**Notes:**
- Looks up each argument in the `Id_To_JournalInstanceID` table.
- Stops at the first successful match.

---

### 2.6 Ejc.IsCurrentContent

```lua
local isCurrent = Ejc.IsCurrentContent(id)
```

Checks whether a given ID (instance, encounter, map, or name) belongs to the current expansion's content.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` or `string` | Any cached ID or name |

**Returns:** `boolean?` — `true` if the ID is current content, `nil` otherwise

**Notes:**
- Does not trigger lazy loading; if the cache hasn't been built, always returns `nil`.

---

### 2.7 Ejc.GetAllEncountersFromInstance

```lua
local encounters = Ejc.GetAllEncountersFromInstance(id)
```

Returns all encounters for a given instance.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` or `string` | Any valid instance identifier (see `GetInstanceInfo`) |

**Returns:** `df_encounterinfo[]?` — ordered array of encounter data, or `nil` if instance not found

---

### 2.8 Ejc.GetAllRaidInstances

```lua
local raids = Ejc.GetAllRaidInstances()
```

Returns all cached raid instances for the current expansion.

**Parameters:** None

**Returns:** `df_instanceinfo[]` — array of raid instance data tables

---

### 2.9 Ejc.GetAllDungeonInstances

```lua
local dungeons = Ejc.GetAllDungeonInstances()
```

Returns all cached dungeon instances for the current expansion.

**Parameters:** None

**Returns:** `df_instanceinfo[]` — array of dungeon instance data tables

---

### 2.10 Ejc.GetEncounterSpells

```lua
local spells = Ejc.GetEncounterSpells(journalInstanceId, journalEncounterId, difficulty)
```

Retrieves all spells/abilities listed in the Encounter Journal for a specific encounter at a given difficulty.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `journalInstanceId` | `number` | The journal instance ID |
| `journalEncounterId` | `number` | The journal encounter ID |
| `difficulty` | `number?` | Difficulty ID (default: `16` = Mythic) |

**Returns:** `df_ejspell[]` — a mixed table that is:
- An **array** of spell section info entries (ordered by journal position)
- Also **indexed by** `spellID` (number), `spellName` (string), and `title` (string) for direct lookup

Each entry contains all fields from `C_EncounterJournal.GetSectionInfo()` plus:
- `spellName` — resolved spell name from `C_Spell.GetSpellInfo`
- `spellIcon` — resolved spell icon ID from `C_Spell.GetSpellInfo`

**Notes:**
- Calls `EJ_SetDifficulty`, `EJ_SelectInstance`, and `EJ_SelectEncounter` internally — this modifies the global Encounter Journal state.
- Traverses the entire section tree (siblings and children) using a stack-based depth-first search.
- Does **not** trigger the main cache build (`CreateEncounterJournalDump`).

---

## 3. Cache Tables

All cache tables are populated by `CreateEncounterJournalDump()` and live on the `Ejc` object.

| Table | Key Type | Value Type | Description |
|-------|----------|------------|-------------|
| `CacheRaidData_ByInstanceId` | `number` | `df_instanceinfo` | Keyed by both `instanceId` and `journalInstanceId` |
| `CacheRaidData_ByInstanceName` | `string` | `df_instanceinfo` | Keyed by localized instance name |
| `CacheRaidData_ByMapId` | `number` | `df_instanceinfo` | Keyed by UI map ID |
| `CacheRaidData_OnlyRaidInstances` | `number` (array) | `df_instanceinfo` | Array of all raid instances |
| `CacheRaidData_OnlyDungeonInstances` | `number` (array) | `df_instanceinfo` | Array of all dungeon instances |
| `CacheEncountersBy_EncounterName` | `string` | `df_encounterinfo` | Keyed by localized encounter name |
| `CacheEncountersBy_EncounterId` | `number` | `df_encounterinfo` | Keyed by dungeon encounter ID |
| `CacheEncountersBy_JournalEncounterId` | `number` | `df_encounterinfo` | Keyed by journal encounter ID |
| `Id_To_JournalInstanceID` | `number` or `string` | `number` | Maps any known ID or name to its journal instance ID |
| `CurrentContent` | `number` or `string` | `boolean` | `true` for IDs/names belonging to the current expansion |

**Note:** `CacheEncountersByEncounterName` is also initialized (without underscores) but encounter data is only written to `CacheEncountersBy_EncounterName` (with underscores). The non-underscore variant remains empty.

---

## 4. Lazy Loading Behavior

Most getter functions check an internal `bHasLoaded` flag and call `CreateEncounterJournalDump()` automatically on first access. The following functions trigger lazy loading:

- `GetEncounterInfo`
- `GetInstanceInfo`
- `GetAllEncountersFromInstance`
- `GetAllRaidInstances`
- `GetAllDungeonInstances`

The following functions do **not** trigger lazy loading:

- `IsCurrentContent` — returns `nil` if cache is not yet built
- `GetInstanceEJID` — returns `nil` if cache is not yet built
- `GetEncounterSpells` — operates independently via the WoW EJ API directly

---

## 5. Usage Examples

### 5.1 Getting Encounter Info by Dungeon Encounter ID

```lua
-- The dungeonEncounterId is the ID from ENCOUNTER_START / ENCOUNTER_END events
local encounterData = DF.Ejc.GetEncounterInfo(2820)
if encounterData then
    print(encounterData.name)
    print(encounterData.creatureIcon)
    print(encounterData.dungeonEncounterId)
end
```

### 5.2 Getting Encounter Info by Name

```lua
local encounterData = DF.Ejc.GetEncounterInfo("Sikran")
if encounterData then
    print("Journal Encounter ID:", encounterData.journalEncounterId)
    print("Instance ID:", encounterData.instanceId)
end
```

### 5.3 Getting Instance Info

```lua
-- By instance ID
local instance = DF.Ejc.GetInstanceInfo(2657)
if instance then
    print(instance.name, instance.isRaid)
    print("Encounters:", #instance.encountersArray)
end

-- By localized name
local instance = DF.Ejc.GetInstanceInfo("Nerub-ar Palace")
if instance then
    for i, encounter in ipairs(instance.encountersArray) do
        print(i, encounter.name)
    end
end
```

### 5.4 Listing All Current Raid Instances

```lua
local raids = DF.Ejc.GetAllRaidInstances()
for i, raidData in ipairs(raids) do
    print(raidData.name, "- Bosses:", #raidData.encountersArray)
end
```

### 5.5 Listing All Current Dungeon Instances

```lua
local dungeons = DF.Ejc.GetAllDungeonInstances()
for i, dungeonData in ipairs(dungeons) do
    print(dungeonData.name, "MapID:", dungeonData.mapId)
end
```

### 5.6 Resolving a Journal Instance ID

```lua
-- Pass multiple IDs; returns the first that resolves
local ejid = DF.Ejc.GetInstanceEJID(mapId, instanceId, encounterName)
if ejid then
    print("Journal Instance ID:", ejid)
end
```

### 5.7 Checking if Content is Current

```lua
if DF.Ejc.IsCurrentContent(2657) then
    print("This instance is from the current expansion")
end
```

### 5.8 Getting All Encounters from an Instance

```lua
local encounters = DF.Ejc.GetAllEncountersFromInstance(2657)
if encounters then
    for i, enc in ipairs(encounters) do
        print(enc.name, enc.dungeonEncounterId)
    end
end
```

### 5.9 Getting Encounter Spells

```lua
-- Get spells for an encounter on Mythic difficulty (16)
local spells = DF.Ejc.GetEncounterSpells(1273, 2902, 16)
for i, spell in ipairs(spells) do
    print(spell.title, spell.spellID, spell.spellName)
end

-- Look up a specific spell by ID or name
local spellInfo = spells[401324]
if spellInfo then
    print(spellInfo.title, spellInfo.spellIcon)
end
```

### 5.10 Explicitly Pre-loading the Cache

```lua
-- Pre-load at addon init instead of waiting for first access
DF.Ejc.Load()
```

### 5.11 Looking Up an Encounter from a Combat Log Event

```lua
local function OnEncounterStart(event, encounterID, encounterName, difficultyID, groupSize)
    local encounterData = DF.Ejc.GetEncounterInfo(encounterID)
    if encounterData then
        local icon = encounterData.creatureIcon
        local coords = encounterData.creatureIconCoords
        myFrame.bossIcon:SetTexture(icon)
        myFrame.bossIcon:SetTexCoord(unpack(coords))
    end
end
```

### 5.12 Building a Dropdown of Raid Bosses

```lua
local function buildBossOptions()
    local instance = DF.Ejc.GetInstanceInfo(2657)
    if not instance then return {} end

    local options = {}
    for i, encounter in ipairs(instance.encountersArray) do
        options[#options + 1] = {
            value = encounter.dungeonEncounterId,
            label = encounter.name,
            icon = encounter.creatureIcon,
            texcoord = encounter.creatureIconCoords,
            onclick = function(dd, fp, v)
                myAddon:SelectBoss(v)
            end
        }
    end
    return options
end
```

### 5.13 Instance Data Lookup by Map ID

```lua
-- Useful when you have a map ID from C_Map
local instance = DF.Ejc.GetInstanceInfo(mapId)
if instance then
    print("Instance:", instance.name)
    print("Journal ID:", instance.journalInstanceId)
    print("Is Raid:", instance.isRaid)
end
```

### 5.14 Iterating Encounter Spells with Lookup

```lua
local spells = DF.Ejc.GetEncounterSpells(1273, 2902, 16)

-- Array iteration for ordered list
for i, spell in ipairs(spells) do
    print(i, spell.title, spell.spellID)
end

-- Direct lookup by spell name
local blazeInfo = spells["Blazing Blast"]
if blazeInfo then
    print("Found:", blazeInfo.spellID)
end
```
