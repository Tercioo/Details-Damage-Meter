# loadconditions.lua — Player-State Load Filters and Editor Panel

A pair-and-a-half system for "should this thing be active right now?" gates. Consumers (most notably **Plater Nameplates** — see the `Plater.OpenOptionsPanel()` reference at `loadconditions.lua:407`) define a `loadTable` describing which classes / specs / races / talents / group types / roles / M+ affixes / encounter IDs / map IDs the gated thing should apply to, then ask the framework to (a) re-evaluate that table whenever the player state changes and (b) show an editor panel so the end user can pick the conditions.

The module is purely a player-state filter — it does not know what the consumer is gating. Plater uses it to scope mod / hook / script execution; another consumer could use it to scope WeakAuras-style spawns or addon-config blocks.

---

## Mental model

```
                         ┌──────────────────────────────┐
                         │  loadTable (per consumer)     │
                         │  {class={}, spec={}, race={}, │
                         │   talent={}, pvptalent={},    │
                         │   group={}, role={},          │
                         │   affix={}, encounter_ids={}, │
                         │   map_ids={}}                 │
                         └─────────────┬────────────────┘
                                       │
        ┌──────────────────────────────┼──────────────────────────────┐
        │                              │                              │
   author edits via             event handler                 PassLoadFilters
   OpenLoadConditionsPanel      CreateLoadFilterParser        is called by the
   (UI checkbox grid)           runs callback on changes      consumer to gate
        │                              │                              │
        └──── writes into ─────────────┴───────── reads from ──────────┘
                              the same loadTable
```

**The split that matters most**: each sub-table (`class`, `spec`, `race`, `talent`, `pvptalent`, `group`, `role`, `affix`) is a **set + an `Enabled` flag**. Keys in the set are the allowed values; the flag tells the evaluator whether to apply the check at all. The two list-style sub-tables (`encounter_ids`, `map_ids`) are **arrays + an `Enabled` flag** — populated from a free-text input in the editor.

The framework writes the `Enabled` flag automatically: when at least one key is set the sub-table is considered enabled, when the last key is removed it's auto-disabled. This is done by `loadConditionsFrame.OnRadioStateChanged` which writes:

```lua
subConfigTable.Enabled = nil
subConfigTable.Enabled = next(subConfigTable) and true or nil
```

Consumers reading from the loadTable should not depend on `Enabled` being literally `nil` vs `false` — both are falsy and the evaluator only ever does `if loadTable.<key>.Enabled then`.

### Numeric vs string-key dual lookup

Several sub-tables (`spec`, `talent`, `pvptalent`, `affix`, `group`, `role`) store IDs as **either numbers or numeric strings**, because of a legacy schema change. Every check does both:

```lua
if loadTable.spec[specID] or loadTable.spec[specID .. ""] then ... end
```

If you mutate the loadTable directly from your own code, prefer a consistent type — but be aware the editor's checkbox handler clears the *string* form when a value is unchecked and the *number* form right after (`loadconditions.lua:467`). Reading either form is safe; writing should match what's already there.

---

## Library access

```lua
local DF = _G["DetailsFramework"]
```

The four entry points all live on `DF:` (colon-methods on the framework root):

```lua
DF:CreateLoadFilterParser(callback)
DF:PassLoadFilters(loadTable, encounterID?) -- returns: bool, reasonName?
DF:UpdateLoadConditionsTable(configTable)   -- in-place defaults; returns configTable
DF:OpenLoadConditionsPanel(optionsTable, callback, frameOptions?)
```

---

## The `loadTable` schema — `default_load_conditions`

```lua
{
    class         = {},   -- set keyed by class FileString (e.g. "HUNTER")
    spec          = {},   -- set keyed by spec ID (number or numeric string)
    race          = {},   -- set keyed by race FileString (e.g. "NightElf")
    talent        = {},   -- set keyed by talent ID (number or numeric string)
    pvptalent     = {},   -- set keyed by pvp-talent ID (number or numeric string)
    group         = {},   -- set keyed by group/instance type (e.g. "raid", "party")
    role          = {},   -- set keyed by role ID (e.g. "TANK", "HEALER", "DAMAGER")
    affix         = {},   -- set keyed by M+ affix ID (number or numeric string)
    encounter_ids = {},   -- array of numeric encounter IDs
    map_ids       = {},   -- array of numeric map IDs (zone map ID OR ui map ID)
}
```

Each sub-table grows an `Enabled = true` field once at least one key is set, and the field becomes `nil` when the last key is removed. Use `DF:UpdateLoadConditionsTable(yourTable)` to fill missing sub-tables with empty defaults — useful when migrating older configs that lacked some keys.

---

## `DF:CreateLoadFilterParser` — install the player-state watcher

```lua
function detailsFramework:CreateLoadFilterParser(callback)
```

Creates a hidden `Frame` that registers for a small set of player-state events. On each fired event, your `callback` is invoked. Use this when you want your consumer to re-evaluate `PassLoadFilters` whenever something changes.

### Events registered

| Event | Project | When |
|---|---|---|
| `PLAYER_SPECIALIZATION_CHANGED` | Mainline only | Spec changed. |
| `TRAIT_CONFIG_LIST_UPDATED` | Mainline only | Talent tree changed. |
| `CHALLENGE_MODE_START` | Mainline only | M+ key started. |
| `PLAYER_ENTERING_WORLD` | Non-mainline | World load. |
| `PLAYER_TALENT_UPDATE` | Non-mainline | Talent changed. |
| `PLAYER_ROLES_ASSIGNED` | All | Role assignment updated. |
| `ZONE_CHANGED_NEW_AREA` | All | New zone. |
| `ENCOUNTER_START` | All | Boss pull. **Encounter ID cached for next call.** |
| `PLAYER_REGEN_ENABLED` | All | Out of combat (empty handler). |
| `PLAYER_REGEN_DISABLED` | All | In combat (empty handler). |
| `CHAT_MSG_LOOT` | All | Used to detect the Bronze Timepiece item (see "RACE_START / RACE_STOP" below). |

After processing the event, the callback fires:

```lua
xpcall(callback, geterrorhandler(), filterFrame.EncounterIDCached)
```

— so your callback receives the **last-seen encounter ID** as its sole argument, or `nil` if no encounter has started this session.

### RACE_START / RACE_STOP (Bronze Timepiece — WoW Anniversary)

A special path watches loot messages for **item 191140** (the WoW 20th Anniversary "Bronze Timepiece" race item). When picked up, it fires `callback("RACE_START")` immediately, then schedules a 5-second-deferred ticker that polls the player's bags every second; when the item disappears from the bags, it fires `callback("RACE_STOP")` and cancels the ticker.

This is a hardcoded one-off specifically for the Anniversary event. The string `"RACE_START"` / `"RACE_STOP"` is passed as the FIRST argument to your callback in this path, **replacing** the usual encounterID. Your callback must handle both shapes:

```lua
local callback = function(encounterIDOrSentinel)
    if encounterIDOrSentinel == "RACE_START" then
        ...
    elseif encounterIDOrSentinel == "RACE_STOP" then
        ...
    else
        -- normal event path; encounterIDOrSentinel is a number or nil
    end
end
```

### What it does NOT register

- `ENCOUNTER_END` is referenced in the handler (clears `EncounterIDCached`) but **not registered**. The cached encounter ID persists for the entire session after the first pull. See Pitfalls.

---

## `DF:PassLoadFilters` — evaluate the loadTable against current state

```lua
---@return boolean passed
---@return string? failedCondition
function detailsFramework:PassLoadFilters(loadTable, encounterID)
```

Walks every sub-table that has `Enabled` set and returns `true` only if all enabled checks pass. On failure, returns `false` plus a human-readable name for the failing condition (localised via `_G["CLASS"]`, `_G["SPECIALIZATION"]`, etc.).

### Returns

| Return | Type | When |
|---|---|---|
| `true` | `boolean` | All enabled conditions pass. |
| `false, reason` | `boolean, string` | One condition failed; `reason` names it. |
| `nil` (no value) | — | `encounter_ids` is enabled but the caller did not pass an `encounterID`. **Early return without a reason.** |

The reason strings come from WoW's global localisation table:

| Condition | Reason source |
|---|---|
| `class` | `_G["CLASS"]` |
| `spec` | `_G["SPECIALIZATION"]` |
| `race` | `_G["RACE"]` |
| `talent` | `_G["TALENTS"]` |
| `pvptalent` | `_G["PVP"] .. " " .. _G["TALENTS"]` |
| `group` | `_G["GROUP"]` |
| `role` | `_G["ROLE"]` |
| `affix` | `"M+ Affix"` (hardcoded English) |
| `encounter_ids` | `_G["GUILD_NEWS_FILTER3"]` — "Raid Encounters" |
| `map_ids` | `_G["BATTLEFIELD_MINIMAP"]` — "Zone Map" |

### Class-and-spec interaction

If `class.Enabled` AND the player's class IS in the allowed set, the function then checks whether any of `spec`'s allowed IDs belong to that class. If none do (i.e. the user picked specs from a different class), spec checking is **skipped entirely** (`canCheckTalents = false`) — the assumption is "they want this for any spec of this class". This is intentional but non-obvious; it means a `loadTable` with `class = {HUNTER}` and `spec = {<warlock spec IDs>}` will always pass spec (because no Hunter specs are in the spec set).

---

## `DF:UpdateLoadConditionsTable` — fill in missing sub-tables

```lua
function detailsFramework:UpdateLoadConditionsTable(configTable)
```

In-place defaults: walks the prototype `default_load_conditions` and copies any missing sub-tables onto `configTable`. Returns the same table. Use this when migrating older saved configs that didn't have all the keys (e.g. older Plater versions before `pvptalent` or `affix` were added).

```lua
local mySettings = MyAddonDB.loadConditions or {}
DF:UpdateLoadConditionsTable(mySettings)
-- now guaranteed to have every sub-table, even if empty
```

---

## `DF:OpenLoadConditionsPanel` — the editor UI

```lua
function detailsFramework:OpenLoadConditionsPanel(optionsTable, callback, frameOptions)
```

Opens a 1024×640 modal panel with the full grid of checkboxes and text entries.

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `optionsTable` | `table` | Yes | The `loadTable` to edit. Defaults are filled in via `UpdateLoadConditionsTable`. Mutated in place. |
| 2 | `callback` | `function` | Yes | Fired every time a checkbox or text entry changes. Use this to apply the change (e.g. re-evaluate, save profile, refresh UI). |
| 3 | `frameOptions` | `table?` | No | Per-open options. Merged into `default_load_conditions_frame_options`. See below. |

### `frameOptions` keys

| Key | Type | Default | Purpose |
|---|---|---|---|
| `title` | `string` | `"Details! Framework: Load Conditions"` | The panel title bar text. |
| `name` | `string` | `"Object"` | The "Load Conditions For: ..." sub-label. Use this to identify what the loadTable belongs to (e.g. `"My Trinket Mod"`). |

### Layout

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Load Conditions                                                  [X]    │
│                                                                          │
│ Load Conditions For: <frameOptions.name>                                │
│                                                                          │
│ ┌──── Character Class ────┐    ┌──── Character PvP Talents ─────┐      │
│ │  ☐ Warrior  ☐ Hunter ... │    │  ☐ ...                          │      │
│ └──────────────────────────┘    └─────────────────────────────────┘      │
│ ┌──── Character Spec ─────┐    ┌──── Group Types ───────────────┐      │
│ │  ☐ ...                   │    │  ☐ raid  ☐ party  ☐ none ...    │      │
│ └──────────────────────────┘    └─────────────────────────────────┘      │
│ ┌──── Character Race ─────┐    ┌──── M+ Affixes ────────────────┐      │
│ │  ☐ Human  ☐ Orc  ☐ ...   │    │  ☐ Fortified  ☐ Tyrannical ... │      │
│ └──────────────────────────┘    └─────────────────────────────────┘      │
│ ┌──── Role Types ─────────┐    ┌─ Encounter ID ─┐ ┌─ Map ID ────┐      │
│ │  ☐ Tank  ☐ Healer  ...   │    │ [ 123 456    ] │ │ [ 22 33  ]  │      │
│ └──────────────────────────┘    └────────────────┘ └─────────────┘      │
│ ┌──── Character Talents ──┐                                              │
│ │  ☐ ☐ ☐ ☐ ☐ ... (icons)   │                                             │
│ └──────────────────────────┘                                              │
└─────────────────────────────────────────────────────────────────────────┘
```

The class / spec / race / talent / pvp-talent / affix / group / role groups are `DF:CreateCheckboxGroup` instances. Encounter and Map IDs are `DF:CreateTextEntry` widgets that accept space-separated numeric IDs (e.g. `"35 45 95"`).

### Singleton

The panel is constructed once (`if not loadConditionsFrame then ...`) and reused on subsequent opens. **A single panel exists per framework instance.** Calling `OpenLoadConditionsPanel` again with a different `optionsTable` re-points the existing panel at the new table — the previous editor session's changes have already been persisted (they were applied in-place to the previous `optionsTable`), so this is safe, but you can't have two load-condition editors visible at once.

---

## Deprecated affixes

The file maintains a `deprecatedAffixes` table (`loadconditions.lua:83-126`) of M+ affix IDs that should NOT appear in the affix checkbox grid (Volcanic, Necrotic, Bursting, Tormented, Encrypted, etc. — the entire rotation of removed seasonal affixes). When the affix grid is built, the iteration `for i = 2, 1000 do` queries `C_ChallengeMode.GetAffixInfo(i)` and skips any ID in this set. **Current affixes are NOT in the deprecated list** (Fortified ID 10, Tyrannical ID 9, and the current Xal'atath's Bargain trio).

When Blizzard adds a new affix, the framework's `deprecatedAffixes` table needs to be updated to *not* include it. Otherwise it'll appear silently — but if Blizzard later removes one (e.g. retires Frenzied), it's a one-line addition to the deprecated set.

---

## Pitfalls

### `ENCOUNTER_END` is referenced but never registered

The event handler has a branch for `ENCOUNTER_END` that clears `filterFrame.EncounterIDCached`, but the event is **not registered** (`loadconditions.lua:148` only registers `ENCOUNTER_START`). The cached encounter ID persists for the entire session after the first pull — `PassLoadFilters` will treat the player as "still in encounter X" until they `/reload`.

**Symptom**: `encounter_ids` conditions evaluate against the *first* boss the player pulled this session, regardless of where they are now.

**Fix (consumer side)**: if you depend on this, register `ENCOUNTER_END` yourself and clear `EncounterIDCached` on the filter frame:

```lua
local filterFrame = DF:CreateLoadFilterParser(myCallback)
filterFrame:RegisterEvent("ENCOUNTER_END")
hooksecurefunc(filterFrame:GetScript("OnEvent"), function(self, event, ...)
    if event == "ENCOUNTER_END" then self.EncounterIDCached = nil end
end)
```

(Or just patch the framework — `loadconditions.lua:148` is missing the registration.)

### `PassLoadFilters` returns `nil` (no values) when `encounter_ids.Enabled` but no `encounterID` is passed

```lua
if (loadTable.encounter_ids.Enabled) then
    if (not encounterID) then
        return                  -- returns nothing
    end
    ...
end
```

Three-way return: `true`, `false, reason`, or **nothing at all**. Consumer code doing `local passed, reason = DF:PassLoadFilters(...)` will see `passed = nil` (falsy) but `reason = nil` (no explanation).

**Fix (consumer side)**: pass an `encounterID` (real or fake) when `encounter_ids` may be enabled, OR pre-check `loadTable.encounter_ids.Enabled` and refuse to evaluate without an ID.

### CHAT_MSG_LOOT spawns a new ticker per loot event

The Bronze Timepiece path:

```lua
elseif (event == "CHAT_MSG_LOOT") then
    ...
    if (itemId == 191140) then
        xpcall(callback, geterrorhandler(), "RACE_START")
        C_Timer.After(5, function()
            filterFrame.FindBackpackItem = C_Timer.NewTicker(1, function()
                ...
            end)
        end)
    end
end
```

If the player loots the item multiple times (e.g. a buyback or a refund), each `CHAT_MSG_LOOT` fires `RACE_START` and replaces `filterFrame.FindBackpackItem` with a new ticker — but the old ticker is **not cancelled**. Tickers accumulate; each polls bags once per second. After a few duplicates, the bag scan runs N times per second.

**Fix**: before assigning the new ticker, cancel the existing one:

```lua
if filterFrame.FindBackpackItem then filterFrame.FindBackpackItem:Cancel() end
filterFrame.FindBackpackItem = C_Timer.NewTicker(...)
```

This is in framework code, not consumer code; flag it if you maintain DF.

### Class-and-spec short-circuit can silently skip spec checks

If you configure `class = {HUNTER}` and `spec = {<some warlock spec IDs>}`, the spec check is **silently skipped** because none of the spec IDs belong to Hunter. The user thought they were narrowing to "Hunter and these specific Warlock specs"; the framework reads it as "Hunter, any spec, because no Hunter specs are in the spec set so spec isn't a constraint for this class".

This is intentional (to support "any spec of this class") but undocumented in the UI. If you give users access to the editor and they tick multi-class specs by mistake, the result is surprising.

**Fix**: educate users, or filter the spec checkbox list to only show specs belonging to the currently-enabled classes.

### Numeric/string-key dual storage is asymmetric across mutators

Every read does `loadTable.foo[id] or loadTable.foo[id .. ""]`. Writes from the editor (`OnRadioCheckboxClick`) do:

```lua
loadConditionsFrame.OptionsTable[DBKey][key and key .. ""] = value and true or nil
if not value then
    loadConditionsFrame.OptionsTable[DBKey][key] = nil
end
```

— so the **string form is always written**, and the **number form is only cleared on uncheck**. If you wrote a number-key from your own code earlier (e.g. an older version of the addon), it persists until the user toggles the matching checkbox off.

**Fix (consumer side)**: when migrating older configs, normalize all numeric keys to string keys:

```lua
for k, v in pairs(loadTable.spec) do
    if type(k) == "number" then
        loadTable.spec[k .. ""] = v
        loadTable.spec[k] = nil
    end
end
```

### Talent and PvP-talent UI helpers (`if (false)` blocks) are dead code

`loadconditions.lua:555-636` and `loadconditions.lua:658-740` contain UI for "warning when you have talents selected from other specs or characters" — wrapped in `if (false) then ... end`. They're disabled. The supporting functions (`CanShowTalentWarning`, `CanShowPvPTalentWarning`) are also commented out at the call sites in `Refresh`.

If you're maintaining this code, **do not delete those blocks** without understanding why they were disabled — the surrounding `Refresh` function still has commented-out call sites suggesting it might be revived.

### `loadConditionsFrame` is a module-local singleton

The frame is created once and stored at module scope (`loadconditions.lua:30`). Calling `OpenLoadConditionsPanel` with different `optionsTable`s reuses the same frame. **Two consumers cannot have the editor open simultaneously.** If consumer A opens the panel for their loadTable, then consumer B opens it for theirs, A's editor session is silently transferred to B's table.

**Fix**: nothing built-in. Consumers either coordinate (only one shows the editor at a time) or don't share the framework's panel and roll their own.

### Empty event branches

`PLAYER_REGEN_ENABLED` and `PLAYER_REGEN_DISABLED` have empty bodies in the handler. Registering for them only matters because they trigger the post-handler `xpcall(callback, ...)` — so the callback fires on combat transitions. This is intentional (some consumers want to re-evaluate on combat enter/exit), but the empty branches read like leftover code.

### M+ affix iteration goes to ID 1000

```lua
for i = 2, 1000 do
    local affixName, desc, texture = GetAffixInfo(i)
    ...
end
```

This iterates 999 IDs every time the panel opens. With current affix IDs in the low 100s–160s, this is overkill but harmless. If `GetAffixInfo` ever throws on unknown IDs (it currently returns nil), this would error. Worth knowing if Blizzard changes the API.

### `IS_WOW_PROJECT_MIDNIGHT` gates `issecretvalue`

`issecretvalue` is a function available only in WoW Apocalypse (Midnight). The Bronze Timepiece path guards with `IS_WOW_PROJECT_MIDNIGHT and issecretvalue(message)` — on non-Midnight clients the branch is skipped, which means the message is parsed even if it contains a secret value. Low risk in practice (only relevant for Midnight); flagged for completeness.

### `getSpecIDs` returns IDs that need string fallback

The spec list iterator at `loadconditions.lua:495` calls `GetSpecializationInfoByID(specID)` — but only for specs of the **player's current class**. If a saved config has spec IDs from other classes (e.g. shared between alts), those don't appear in the editor; the only way to remove them is via the disabled-by-default "other talents" warning UI or by editing the saved config directly.

---

## Public method reference

| Method | Purpose |
|---|---|
| `DF:CreateLoadFilterParser(callback)` | Install a hidden event watcher. Callback fires on spec change, role change, zone change, encounter start, combat enter/exit, and the Bronze Timepiece loot event. |
| `DF:PassLoadFilters(loadTable, encounterID?)` | Evaluate the loadTable against current player state. Returns `true` / `false, reason` / no value (when `encounter_ids` is enabled and no `encounterID` was passed). |
| `DF:UpdateLoadConditionsTable(configTable)` | In-place fill of missing sub-tables from `default_load_conditions`. Returns the same table. |
| `DF:OpenLoadConditionsPanel(optionsTable, callback, frameOptions?)` | Open the editor. Singleton panel; reuses the frame on subsequent opens. |

---

## Usage Examples

### Plater-style integration

```lua
local DF = _G["DetailsFramework"]

local myMod = {
    loadConditions = {},        -- will be populated by the editor
    enabled        = false,
}

DF:UpdateLoadConditionsTable(myMod.loadConditions)

-- Re-evaluate the gate whenever player state changes
DF:CreateLoadFilterParser(function(encounterID)
    local passed, reason = DF:PassLoadFilters(myMod.loadConditions, encounterID)
    if myMod.enabled ~= passed then
        myMod.enabled = passed
        myMod:OnLoadStateChanged(passed, reason)
    end
end)

-- Configure-button handler
local function openEditor()
    DF:OpenLoadConditionsPanel(
        myMod.loadConditions,
        function() saveProfile() end,                 -- callback on every change
        { title = "My Mod Load Conditions",
          name  = myMod.name }                         -- shown in the "Load Conditions For:" label
    )
end
```

### Read the gate without registering for events

```lua
local DF = _G["DetailsFramework"]

local function shouldShowMyFrame()
    local passed = DF:PassLoadFilters(MyAddonDB.loadConditions)
    return passed == true
end
```

### Handle the Bronze Timepiece special path

```lua
DF:CreateLoadFilterParser(function(encounterIDOrSentinel)
    if encounterIDOrSentinel == "RACE_START" then
        startMyRaceModeUI()
    elseif encounterIDOrSentinel == "RACE_STOP" then
        stopMyRaceModeUI()
    else
        -- normal: encounterIDOrSentinel is a number or nil
        reevaluateGate(encounterIDOrSentinel)
    end
end)
```

### Programmatic editing of the loadTable

```lua
-- Allow only Hunters in raid:
myMod.loadConditions.class["HUNTER"] = true
myMod.loadConditions.class.Enabled = true
myMod.loadConditions.group["raid"] = true
myMod.loadConditions.group.Enabled = true

-- Add specific encounter IDs (Sanctum of Domination boss 1):
myMod.loadConditions.encounter_ids[#myMod.loadConditions.encounter_ids+1] = 2422
myMod.loadConditions.encounter_ids.Enabled = true

-- Then re-evaluate:
local passed = DF:PassLoadFilters(myMod.loadConditions, currentEncounterID)
```

---

## Notes for AI readers

1. **`PassLoadFilters` has three return shapes** — `true`, `false, reason`, and *nothing at all* (when `encounter_ids` is enabled but no `encounterID` arg was passed). Generated consumer code must handle the no-value case explicitly.
2. **Numeric IDs may be stored as numbers OR strings.** Reads use `t[id] or t[id .. ""]`; writes from the editor prefer the string form. When generating code that writes to the loadTable, prefer the string form for consistency.
3. **`Enabled` is a derived flag.** The editor sets it from `next(t)`. If you write to the loadTable directly, also set `Enabled = true` — the evaluator skips sub-tables with no `Enabled` flag, even if they contain keys.
4. **The editor panel is a singleton.** Don't recommend opening the panel for two different `optionsTable`s at the same time.
5. **`ENCOUNTER_END` is not registered.** Code that depends on encounter scope clearing at end-of-fight must either reload or self-register the event.
6. **The Bronze Timepiece RACE_START / RACE_STOP path is hardcoded.** Don't try to abstract it; it's intentionally specific to WoW Anniversary item 191140.
7. **Class-and-spec interact**: if `class.Enabled` AND the player's class is in the set AND no spec in the spec set belongs to that class, the spec check is silently skipped.
8. **The `if (false)` blocks at lines 555–636 and 658–740 are intentionally disabled** — don't suggest deleting them.
9. **`PLAYER_ROLES_ASSIGNED` falls back to spec-derived role** if `UnitGroupRolesAssigned` returns `"NONE"`. Generated code should call the same helpers (`DetailsFramework.GetSpecialization`, `GetSpecializationRole`) when manually deriving the role.
10. **Affix ID 1000 is the iteration ceiling.** If Blizzard ever assigns affix IDs above this, the affix UI will silently miss them.

---

## See also

- `auras.lua` / `iteminfo.lua` — sibling cross-version compatibility shims (similar `IS_WOW_PROJECT_*` branching). `loadconditions.lua` is the largest example of this pattern in DF.
- `definitions.lua` — `detailsFramework:GetClassList`, `GetCharacterRaceList`, `GetGroupTypes`, `GetRoleTypes`, `GetCLEncounterIDs`. The static metadata the panel iterates.
- `definitions.lua` / framework root — `GetClassSpecIDs`, `GetCharacterTalents`, `GetCharacterPvPTalents`, `GetAllTalents`, `GetSpecializationInfoByID`.
- `panel.lua` — `CreateSimplePanel` (the panel host), `CreateCheckboxGroup`, `CreateTextEntry`, `CreateLabel`.
- `Plater Nameplates` — the canonical consumer; see `Plater.OpenOptionsPanel()` and search for `LoadConditions` in Plater source.
