# auras.lua — Aura Lookup, Spell Cache, and Tracking Config Panel

A grab-bag of aura-related utilities: a legacy `UnitAura` wrapper, a lazy-loading spell-ID-to-name cache, a player spellbook helper, an auto-complete adapter, and a sizeable configuration panel (`DF:CreateAuraConfigPanel`) for "what auras should be tracked" addon settings. The panel is the largest surface in this file — its DB schema is what Details! addons consume.

The natural consumer is anything that wants to let the user pick which auras (buffs/debuffs) to watch. Details! itself uses the panel for plugin aura tracking. There's no canonical Plater consumer here.

---

## Mental model

Four sub-systems share the file:

```
1. Aura lookup        →  DF:GetAuraByName(unit, name, isDebuff)
                         Iterates UnitAura indices 1..40 looking for a name match.

2. Spell cache        →  DF:LoadSpellCache(hashMap, indexTable, allSpellsSameName)
                         Lazy fills 3 caller-supplied tables with all spells in
                         IDs 1..500000 across ~200 frames. Used for auto-complete.

3. Spellbook helpers  →  DF:GetAllPlayerSpells(include_lower_case)
                         DF:SetAutoCompleteWithSpells(textentry)

4. Config panel       →  DF:CreateAuraConfigPanel(parent, name, db, callback, options, texts)
                         Builds a 600×600 panel with Automatic and Manual tracking
                         modes. Mutates db.aura_tracker.* in place.
```

The four sub-systems are independent — you can use the spell cache without the panel, or `GetAuraByName` without anything else. The panel happens to use all three of the others.

### Panel DB schema — `db.aura_tracker`

The panel reads and writes this nested table on the consumer's `db`:

```lua
db.aura_tracker = {
    track_method   = 0x1,              -- 0x1 = automatic, 0x2 = manual
    -- Automatic mode (with blacklist/tracklist):
    buff_banned    = {[spellId] = bool},
    debuff_banned  = {[spellId] = bool},
    buff_tracked   = {[spellId] = bool},
    debuff_tracked = {[spellId] = bool},
    -- Manual mode (explicit lists):
    buff           = {spellId, spellId, ...},   -- array
    debuff         = {spellId, spellId, ...},   -- array
}
```

**The value polarity in the four hash sub-tables matters**:

| Value | Meaning |
|---|---|
| `true` | Entry was added "by Name" — the consumer treats it as a name-based match. |
| `false` | Entry was added "by ID" — the consumer treats it as a strict spell-ID match. |

The framework only sets the values; how the consumer interprets them is up to them. Most consumers use the boolean only to track *how* the user added the entry; both `true` and `false` mean "this spell is on the list".

### Track method magic numbers

The two tracking modes are encoded as `0x1` and `0x2`. There is no enum — they appear as bare hex literals throughout. `0x1` always means automatic; `0x2` always means manual.

---

## Library access

```lua
local DF = _G["DetailsFramework"]
local panel = DF:CreateAuraConfigPanel(parent, "MyAuraPanel", db, onChange, options, locTexts)
```

All four sub-systems live on `DF:` as colon-methods.

---

## Aura lookup

### `DF:GetAuraByName(unit, spellName, isDebuff)`

```lua
function DF:GetAuraByName(unit, spellName, isDebuff)
```

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `unit` | `string` | Unit token (`"player"`, `"target"`, …). |
| 2 | `spellName` | `string` | Exact name match (case-sensitive). |
| 3 | `isDebuff` | `boolean?` | If truthy, filters to `"HARMFUL\|PLAYER"`. Otherwise iterates all buffs. |

Iterates `UnitAura(unit, i, filter)` for i = 1..40 looking for `name == spellName`. Returns all 14 of `UnitAura`'s legacy returns when found, or nothing.

**Note**: `UnitAura` is **deprecated** in retail WoW (replaced by `C_UnitAuras.GetAuraDataByIndex`). This function works because Blizzard kept the old global as an alias, but the alias may eventually be removed. New code should use `AuraUtil.FindAuraByName` or `C_UnitAuras.*` directly.

### Return shape (14 values)

```lua
name, texture, count, debuffType, duration, expirationTime, caster,
canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff,
isCastByPlayer, nameplateShowAll
```

---

## Spell cache

A lazy spell-ID-to-name cache built for auto-complete. The framework does NOT own the storage — it operates on tables you pass in, so consumers can persist the cache across sessions in saved variables.

### Three structures, filled in parallel

| Name | Type | Description |
|---|---|---|
| `hashMap` | `{[lowerName] = spellId}` | Look up "by name → ID". |
| `indexTable` | `string[]` | Sorted array of all lowercase spell names. Used by `SetAsAutoComplete`. |
| `allSpellsSameName` | `{[lowerName] = {spellId, spellId, ...}}` | Reverse multi-map; multiple spells can share a name. |

### `DF:LoadSpellCache(hashMap, indexTable, allSpellsSameName)`

```lua
function DF:LoadSpellCache(hashMap, indexTable, allSpellsSameName)
```

Asserts all three arguments are tables. If the framework's internal cache pointers (`spellsHashMap`, `spellsIndexTable`, `spellsWithSameName`) are already populated, returns them directly — second-call idempotent.

On first call: stores the caller's tables as the framework's cache pointers, then schedules a lazy fill via `detailsFramework.Schedules.LazyExecute(lazyLoadAllSpells, payload, 200)`:

- Each tick processes **2,500 spell IDs**.
- Total iterations: **200**.
- Total spells scanned: **500,000** (`CONST_MAX_SPELLS`).
- Total time: ~200 frames at 60 fps ≈ **3.3 seconds** to fully populate.

**Returns** the three pointers (same as what you passed in).

```lua
local hashMap, indexTable, sameName = {}, {}, {}
DF:LoadSpellCache(hashMap, indexTable, sameName)
-- 3.3 seconds later: hashMap and indexTable are populated.
```

### `DF:UnloadSpellCache()`

`table.wipe`s all three internal tables. The framework still holds references; consumers continuing to hold their own references see the wipe too.

### `DF:GetSpellCaches()`

Returns the three internal pointers — `(hashMap, indexTable, sameName)`. Useful when you don't have access to the originals.

### Spell-book helpers

```lua
local spells = DF:GetAllPlayerSpells(include_lower_case)
DF:SetAutoCompleteWithSpells(textentry)
```

`GetAllPlayerSpells` iterates `GetSpellTabInfo` × `GetSpellBookItemInfo` and returns an array of spell names known by the player. If `include_lower_case` is true, each name appears twice (original and lowercase). Used by `SetAutoCompleteWithSpells` to populate auto-complete on a text entry's `OnEditFocusGained`.

`SetAutoCompleteWithSpells(textentry)` wires the text entry to re-load `playerSpells` every time it gets focus, then calls `:SetAsAutoComplete("WordList")`. The list refreshes per focus, so newly-learned spells appear.

### Polyfills for modern WoW

The file polyfills several deprecated globals at module load:

| Polyfill | Behaviour |
|---|---|
| `GetSpellInfo(spellID)` | Falls back to `C_Spell.GetSpellInfo(spellID)`, returning the same 8 legacy positional values. |
| `GetSpellBookItemInfo(...)` | Falls back to `C_SpellBook.GetSpellBookItemInfo`, mapping `Enum.SpellBookItemType` back to legacy strings. |
| `GetNumSpellTabs` | Falls back to `C_SpellBook.GetNumSpellBookSkillLines`. |
| `GetSpellTabInfo(tab)` | Falls back to `C_SpellBook.GetSpellBookSkillLineInfo`. |
| `SPELLBOOK_BANK_PLAYER` | Falls back to `Enum.SpellBookSpellBank.Player`. |

If a future client retires the legacy globals entirely, the polyfills carry the file through.

---

## `DF:CreateAuraConfigPanel` — the config panel

```lua
function DF:CreateAuraConfigPanel(parent, name, db, changeCallback, options, texts)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | Yes | Parent frame. |
| 2 | `name` | `string` | Yes | Global name passed to `CreateFrame`. |
| 3 | `db` | `table` | Yes | Settings table. Must have or get a `db.aura_tracker` sub-table populated by the consumer. **Mutated in place** by every UI action. |
| 4 | `changeCallback` | `function?` | No | Fired (via `DF:QuickDispatch`) on every UI mutation. Use this to save the profile, refresh tracking, etc. |
| 5 | `options` | `table?` | No | Configuration overrides. See below. |
| 6 | `texts` | `table?` | No | Localised strings. See below. |

### Options (`aura_panel_defaultoptions`)

| Key | Type | Default | Purpose |
|---|---|---|---|
| `height` | `number` | `400` | Used as the height of the per-mode scrollboxes. |
| `row_height` | `number` | `18` | Aura scroll row height. |
| `width` | `number` | `230` | Used as the width of the per-mode scrollboxes. |
| `button_text_template` | `string` | `"OPTIONS_FONT_TEMPLATE"` | Font template applied to the panel's buttons. |

### Texts (`defaultTextForAuraFrame`)

| Key | Default English | Purpose |
|---|---|---|
| `AUTOMATIC` | `"Automatic"` | Label next to the Automatic checkbox. |
| `MANUAL` | `"Manual"` | Label next to the Manual checkbox. |
| `METHOD` | `"Aura Tracking Method:"` | Header above the checkbox pair. |
| `BUFFS_IGNORED` | `"Buffs Ignored"` | Title of the buff blacklist scroll. |
| `DEBUFFS_IGNORED` | `"Debuffs Ignored"` | Title of the debuff blacklist scroll. |
| `BUFFS_TRACKED` | `"Buffs Tracked"` | Title of the buff tracklist scroll. |
| `DEBUFFS_TRACKED` | `"Debuffs Tracked"` | Title of the debuff tracklist scroll. |
| `AUTOMATIC_DESC` | (multi-line) | Description shown when Automatic is selected. |
| `MANUAL_DESC` | (multi-line) | Description shown when Manual is selected. |
| `MANUAL_ADD_BLACKLIST_BUFF` | `"Add Buff to Blacklist"` | Label above the blacklist buff text entry. |
| `MANUAL_ADD_BLACKLIST_DEBUFF` | `"Add Debuff to Blacklist"` | Same for debuff. |
| `MANUAL_ADD_TRACKLIST_BUFF` | `"Add Buff to Tracklist"` | Label above the tracklist buff text entry. |
| `MANUAL_ADD_TRACKLIST_DEBUFF` | `"Add Debuff to Tracklist"` | Same for debuff. |

Missing keys are filled in from the defaults via `DF.table.deploy`.

### Returns

The newly created panel frame (a `Frame` with `"BackdropTemplate"`). The frame exposes these fields you may need:

| Field | Type | Description |
|---|---|---|
| `db` | `table` | The settings table you passed in. |
| `OnProfileChanged` | `function` | Call as `panel:OnProfileChanged(newDb)` after a profile swap to re-bind all sub-widgets to the new DB. |
| `LocTexts` | `table` | The merged texts table. |
| `f_auto` / `f_manual` | `frame` | The two mode sub-frames. Only one is visible at a time. |
| `AutomaticTrackingCheckbox` / `ManualTrackingCheckbox` | `df_switch` | The mode toggles. |
| `desc_label` | `df_label` | The right-aligned descriptive text under the mode header. |
| `buff_ignored` / `debuff_ignored` / `buff_tracked` / `debuff_tracked` | `df_aurascrollbox` | The four Automatic-mode scroll lists. |
| `buffs_added` / `debuffs_added` | `df_scrollbox` | The two Manual-mode scroll lists. |

### Panel layout

```
┌───────────────────────────────────────────────────────────────────────────┐
│ Aura Tracking Method:    [☑ Automatic]   <Automatic description text>     │
│                          [☐ Manual   ]                                     │
│                                                                            │
│ ── Automatic mode ── (f_auto, visible when track_method == 0x1) ──        │
│ ┌──Blacklist Add──┐  ┌──Debuff Banned─┐ ┌──Buff Banned─┐ ┌──Debuff Tr─┐  │
│ │ Add Debuff:     │  │ scrollbox list │ │ ...          │ │ ...        │  │
│ │ [name]   [byID] │  │                │ │              │ │            │  │
│ │ Add Buff:       │  └────────────────┘ └──────────────┘ └────────────┘  │
│ │ [name]   [byID] │                                                       │
│ ├──Tracklist Add──┤                                                       │
│ │ ...             │                                                       │
│ └─────────────────┘                                                       │
│                                                                            │
│ ── Manual mode ── (f_manual, visible when track_method == 0x2) ──         │
│ ┌──Buffs Added──┐  ┌──Debuffs Added──┐    [Add Buff   ] [Add]              │
│ │ scrollbox     │  │ scrollbox       │    [Add Debuff ] [Add]              │
│ │ list          │  │ list            │    Multi-spell tip: use ';'         │
│ └───────────────┘  └─────────────────┘    [Export Buffs] [Export Debuffs] │
│                                            [Export Box Text Entry]         │
└───────────────────────────────────────────────────────────────────────────┘
```

### Add-spell text entries

Both modes accept comma-separated batch entry. Manual mode tooltip says:

> Enter the buff name using lower case letters. You can add several spells at once using `;` to separate each spell name.

The entries are wired with `SetAutoComplete` against the `spellsIndexTable` cache **on focus** — meaning if `DF:LoadSpellCache` hasn't finished filling the cache yet, the auto-complete doesn't activate. The framework refuses to attach auto-complete if `next(spellsHashMap)` returns nil (the cache is empty):

```lua
local setAutoCompleteWordList = function(self, capsule)
    if (next(spellsHashMap)) then  -- skip silently if cache not ready
        ...
    end
end
```

### Profile swap

```lua
panel:OnProfileChanged(newDb)
```

Rebinds the four Automatic scrollboxes and the two Manual scrollboxes to the new DB's `aura_tracker.*` sub-tables, refreshes them, and applies the active track method's UI state. Call this from your addon's profile-changed callback to keep the panel in sync.

---

## Pitfalls

### Spell cache is async — auto-complete fails silently until populated

`DF:LoadSpellCache` schedules a 3.3-second-ish lazy fill. During that time, `next(spellsHashMap)` returns nil and `setAutoCompleteWordList` short-circuits. The user sees a text entry that doesn't suggest anything; no error, no warning.

**Fix**: load the cache early in your addon (e.g. at `PLAYER_LOGIN`) so it's ready by the time the panel opens. Or, if you save the three tables in your SavedVariables, the next session starts with a populated cache and `LoadSpellCache` returns immediately.

```lua
-- saved-variable backed cache:
MyAddonDB.spellHashMap   = MyAddonDB.spellHashMap   or {}
MyAddonDB.spellIndexTbl  = MyAddonDB.spellIndexTbl  or {}
MyAddonDB.spellSameName  = MyAddonDB.spellSameName  or {}
DF:LoadSpellCache(MyAddonDB.spellHashMap, MyAddonDB.spellIndexTbl, MyAddonDB.spellSameName)
```

### "By Name" vs "By ID" polarity in the blacklist hash is inverted

```lua
db.aura_tracker.buff_banned[spellId] = true   -- added "By Name"
db.aura_tracker.buff_banned[spellId] = false  -- added "By ID"
```

Consumers iterating the blacklist must know that **both `true` and `false` mean "this spell is on the list"**. Only `nil` means "absent". If you `for k, v in pairs(buff_banned) do if v then ... end`, you'll skip every `false`-valued entry, which is the entries the user added "by ID".

**Fix**: iterate keys, not values:

```lua
for spellId in pairs(buff_banned) do
    -- spellId is on the blacklist
end
```

### "By ID" buttons accept spell names too

The "By ID" button's first check is `if not tonumber(text) then DetailsFramework.Msg(..., "Invalid Spell-ID") end` — but it does **not return**. It falls through to `getSpellIDFromSpellName(text)`, which DOES handle names. So a "By ID" button with a name in the text entry prints an error AND successfully adds the spell. Confusing UX.

**Fix**: this is in framework code. If you maintain DF, add `return` after the error message. As a consumer, you can hook the button or override `getSpellIDFromSpellName`.

### Manual mode uses arrays; Automatic mode uses hash tables

The two modes have **different DB shapes**:

```lua
db.aura_tracker.buff           = {123, 456, 789}        -- manual (array)
db.aura_tracker.buff_tracked   = {[123] = true, ...}    -- auto-tracklist (hash)
```

When migrating an addon from one mode to the other, you must convert between shapes. The framework does not do this for you.

### `UnitAura` is deprecated

`DF:GetAuraByName` uses `UnitAura(unit, i, filter)`. Modern retail clients have moved to `C_UnitAuras.GetAuraDataByIndex` (returns a table) and `AuraUtil.FindAuraByName`. `UnitAura` still works via Blizzard's compatibility shim but may be removed in a future expansion. If you need to call this in performance-sensitive code (e.g. every frame on many units), use the modern API directly.

### Track method is a magic number

`track_method = 0x1` (auto) vs `0x2` (manual). No enum, no constant. Hardcoded throughout the file. Don't refactor consumer code to use any other value — the framework checks literal `0x1` and `0x2`.

### Lazy cache `iterations` argument is hardcoded to 200

```lua
local iterations = 200
```

No way to tune. A faster machine can't finish faster; a slower machine can't get more granularity. For most clients the 3.3-second fill is fine.

### Spell cache iteration ceiling is `CONST_MAX_SPELLS = 500000`

Spells with IDs ≥ 500,000 are NOT in the cache. WoW retail's spell ID counter is in the 1.4M+ range as of TWW. The cache is **incomplete** by design — it only catches spells in the first 500k IDs.

**Fix (consumer side)**: if you need higher IDs, build your own pass. Or fetch them on-demand at lookup time via `GetSpellInfo`.

### The aura_tracker meta prototype is a stub

The GlobalWidgetControlNames version-cohabitation pattern at the top of the file (`auras.lua:137-159`) creates a metatable with only a `WidgetType` and `dversion`, plus the `ScriptHookMixin`. **No widget actually uses this metatable** — there's no constructor that does `setmetatable(obj, AuraTrackerMetaFunctions)`. The structure is there for future extension.

### Print statements vs `DetailsFramework.Msg`

The blacklist/tracklist buttons use `DetailsFramework.Msg(...)` for error feedback, but the Manual-mode "Add Buff" / "Add Debuff" buttons use bare `print(...)`. The error format differs (Msg formats with the framework prefix, print does not). Cosmetic; flag if you care about output consistency.

### Auto-complete tables are not destroyed on UnloadSpellCache

`UnloadSpellCache` wipes the three caches but does not detach them from already-installed text entries. A text entry that has `:SetAsAutoComplete("SpellAutoCompleteList")` will still have its `SpellAutoCompleteList` field pointing at the same (now-empty) table. Auto-complete silently stops working but the field is still set.

**Fix**: re-call `setAutoCompleteWordList` on the relevant entries after `LoadSpellCache` re-fills.

### `OnProfileChanged` resets visual state but not text-entry contents

If the user typed something in an add-spell entry, then triggered a profile switch, the entry's text remains. Save your profile state before swapping if that matters.

---

## Public method reference

| Method | Purpose |
|---|---|
| `DF:GetAuraByName(unit, name, isDebuff?)` | Find an aura by name. Returns the 14 `UnitAura` legacy returns or nothing. |
| `DF:GetSpellCaches()` | Return `(hashMap, indexTable, sameName)` — the internal cache pointers. |
| `DF:LoadSpellCache(hashMap, indexTable, sameName)` | Begin a 3.3 s lazy fill of the three tables with all spells in IDs 1..500000. |
| `DF:UnloadSpellCache()` | `table.wipe` all three caches. |
| `DF:GetAllPlayerSpells(include_lower_case?)` | Return an array of spell names from the spell book. |
| `DF:SetAutoCompleteWithSpells(textentry)` | Wire a text entry to refresh its auto-complete from the player's spell book on focus. |
| `DF:CreateAuraConfigPanel(parent, name, db, callback?, options?, texts?)` | Build the Automatic / Manual aura tracking panel. Mutates `db.aura_tracker.*` in place. |

The panel also exposes `panel:OnProfileChanged(newDb)` as an instance method.

---

## Usage Examples

### Basic aura lookup

```lua
local DF = _G["DetailsFramework"]

local name, _, _, _, duration, expirationTime = DF:GetAuraByName("player", "Power Word: Shield")
if name then
    local remaining = expirationTime - GetTime()
    print(("Shield: %.1fs left"):format(remaining))
end
```

### Persistent spell cache

```lua
local DF = _G["DetailsFramework"]

MyAddonDB = MyAddonDB or {}
MyAddonDB.spellHashMap  = MyAddonDB.spellHashMap  or {}
MyAddonDB.spellIndexTbl = MyAddonDB.spellIndexTbl or {}
MyAddonDB.spellSameName = MyAddonDB.spellSameName or {}

DF:LoadSpellCache(MyAddonDB.spellHashMap, MyAddonDB.spellIndexTbl, MyAddonDB.spellSameName)
-- Subsequent sessions get the cache from saved variables — no 3.3 s fill.
```

### Aura tracking panel

```lua
local DF = _G["DetailsFramework"]

-- Ensure the DB has the expected shape:
MyAddonDB.aura_tracker = MyAddonDB.aura_tracker or {
    track_method   = 0x1,
    buff_banned    = {},
    debuff_banned  = {},
    buff_tracked   = {},
    debuff_tracked = {},
    buff           = {},
    debuff         = {},
}

local panel = DF:CreateAuraConfigPanel(
    parentFrame,
    "MyAuraSettings",
    MyAddonDB,
    function()
        -- Called on every change. Re-evaluate, refresh visuals, etc.
        myAddon:RefreshAuraTracking()
    end,
    { width = 230, height = 400, row_height = 18 },
    {
        AUTOMATIC = "Auto",
        MANUAL    = "Manual",
        METHOD    = "Tracking Mode:",
    }
)
panel:SetPoint("topleft", parentFrame, "topleft", 10, -10)
panel:SetSize(900, 600)
```

### Reading the blacklist

```lua
-- Iterate keys (NOT values — both true and false mean "on the list").
for spellId in pairs(MyAddonDB.aura_tracker.buff_banned) do
    print("Banned buff:", GetSpellInfo(spellId))
end
```

### Profile swap

```lua
-- When the user changes profile:
panel:OnProfileChanged(MyAddonDB)   -- re-binds the panel to the new db.aura_tracker.* tables
```

---

## Notes for AI readers

1. **`UnitAura` is deprecated.** Don't recommend `DF:GetAuraByName` for new code; suggest `AuraUtil.FindAuraByName` instead.
2. **`track_method` is `0x1` (auto) or `0x2` (manual).** Magic numbers, no enum. Don't try other values.
3. **Blacklist/tracklist value polarity is `true` (by name) vs `false` (by ID).** Iterate keys, not values, when checking membership.
4. **The spell cache is async — 3.3 seconds to fill** unless backed by saved variables. Pre-load early.
5. **Spell IDs ≥ 500,000 are NOT in the cache.** Hardcoded ceiling.
6. **Manual mode uses arrays; automatic mode uses hash tables.** Different DB shapes — be explicit when writing migration code.
7. **`OnProfileChanged` is on the panel instance**, not the framework root. Call as `panel:OnProfileChanged(newDb)`.
8. **The panel constructor is large** — a full panel layout is ~1000 lines. Don't try to reimplement it; use the framework's panel and customise via `texts` and `options`.
9. **"By ID" buttons accept names too** due to the missing `return` after the validation. This is a UI quirk; document it for users if your addon exposes the buttons.
10. **The `aura_tracker` GlobalWidgetControlNames meta is a stub** — no widget instantiates from it. Don't reference it expecting methods.

---

## See also

- `iteminfo.lua` / `iteminfo.md` — sibling compatibility shim for container item info. Same legacy-vs-`C_*` pattern.
- `scrollbox.lua` / `scrollbox.md` — `CreateAuraScrollBox` lives there; this file consumes it for the four Automatic-mode lists.
- `loadconditions.lua` / `loadconditions.md` — uses similar UI patterns (`CreateCheckboxGroup`, `CreateTextEntry`, multi-mode panels).
- `dropdown.lua` — auto-complete on text entries is implemented in the dropdown / text-entry module; `SetAsAutoComplete` lives there.
- `schedules.lua` — `detailsFramework.Schedules.LazyExecute`, used to lazy-fill the spell cache over 200 frames.
- `panel.lua` — `CreateLabel`, `CreateButton`, `CreateTextEntry`, `CreateSwitch`, `ApplyStandardBackdrop`. The base widgets the panel composes.
