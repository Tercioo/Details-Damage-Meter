# iteminfo.lua — Container Item Info Compatibility Shim

A two-function namespace that bridges the pre-Dragonflight `GetContainerItemInfo` global to the modern `C_Container.GetContainerItemInfo` (Dragonflight and beyond). Existing addons reading bag contents can call one entry point and get the legacy 11-return shape no matter which API the running client exposes.

---

## Mental model

The retail WoW client changed how container (bag) item info is fetched in Dragonflight:

- **Pre-DF**: `GetContainerItemInfo(bagIndex, slotIndex)` returned 11 positional values.
- **DF and later**: `C_Container.GetContainerItemInfo(bagIndex, slotIndex)` returns a single table.

`iteminfo.lua` exposes one function — `detailsFramework.Items.GetContainerItemInfo` — that picks the right backend and **always returns the legacy 11-tuple**. Consumers written against the old API keep working without conditionals. It also exposes a thin helper, `IsItemSoulbound`, that pulls just the bound-flag out of the same call.

The version branch is decided **once at load time** via `detailsFramework.IsDragonflightAndBeyond()`:

```
loadtime:  containerAPIVersion = IsDragonflightAndBeyond() and 2 or 1

per call:  if (version == 2 and C_Container.GetContainerItemInfo) then
               table = C_Container.GetContainerItemInfo(...)
               return iconFileID, stackCount, isLocked, quality, isReadable,
                      hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound
           else
               return GetContainerItemInfo(...)   -- legacy global, untouched
           end
```

The 11-return order matches the legacy contract exactly.

---

## Library access

```lua
local DF = _G["DetailsFramework"] -- or LibStub("DetailsFramework-1.0")
local icon, stack, locked, quality, readable, hasLoot, link, filtered, noValue, itemID, bound
    = DF.Items.GetContainerItemInfo(bagIndex, slotIndex)

local bIsBound = DF.Items.IsItemSoulbound(bagIndex, slotIndex)
```

---

## `detailsFramework.Items.GetContainerItemInfo` — signature

```lua
function detailsFramework.Items.GetContainerItemInfo(containerIndex, slotIndex)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `containerIndex` | `number` | Yes | Bag index (`0`–`NUM_BAG_SLOTS`). |
| 2 | `slotIndex` | `number` | Yes | 1-based slot inside the bag. |

### Returns — 11-tuple, in legacy order

| # | Name | Type | From DF table | Description |
|---|---|---|---|---|
| 1 | `iconFileID` | `number?` | `itemInfo.iconFileID` | Icon texture fileID. |
| 2 | `stackCount` | `number?` | `itemInfo.stackCount` | Stack size. |
| 3 | `isLocked` | `boolean?` | `itemInfo.isLocked` | True while the slot is locked by a pending operation. |
| 4 | `quality` | `number?` | `itemInfo.quality` | Item quality (0 = poor … 8 = heirloom). |
| 5 | `isReadable` | `boolean?` | `itemInfo.isReadable` | True for items that open a text reader (books, recipes). |
| 6 | `hasLoot` | `boolean?` | `itemInfo.hasLoot` | True for containers with unopened loot. |
| 7 | `hyperlink` | `string?` | `itemInfo.hyperlink` | Item hyperlink string. |
| 8 | `isFiltered` | `boolean?` | `itemInfo.isFiltered` | True if the item is greyed out by the current bag filter. |
| 9 | `hasNoValue` | `boolean?` | `itemInfo.hasNoValue` | True for non-sellable items (sell price 0). |
| 10 | `itemID` | `number?` | `itemInfo.itemID` | Item ID. |
| 11 | `isBound` | `boolean?` | `itemInfo.isBound` | True if the item is soulbound. |

On the legacy path (`containerAPIVersion == 1` or `C_Container.GetContainerItemInfo` absent), the function tail-calls the old global directly. **Whatever Blizzard's legacy global returns flows through verbatim** — including the legacy quirk that an empty slot returns `nil` for every value.

### Empty slots

Both backends return all-`nil` (or no values) for empty slots. Consumers should null-check at least one trailing field:

```lua
local iconFileID, _, _, quality, _, _, link, _, _, itemID = DF.Items.GetContainerItemInfo(0, 1)
if not itemID then
    return  -- empty slot
end
```

---

## `detailsFramework.Items.IsItemSoulbound` — signature

```lua
function detailsFramework.Items.IsItemSoulbound(containerIndex, slotIndex)
```

A one-liner that wraps `GetContainerItemInfo` and returns only the 11th value (`isBound`).

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `containerIndex` | `number` | Yes | Bag index. |
| 2 | `slotIndex` | `number` | Yes | Slot inside the bag. |

**Returns:** `boolean?` — `true` if the item is bound. `nil` for empty slots (because the wrapped 11-tuple is all-nil there).

---

## Pitfalls

### Empty slots return all-nil, not "false" or "no item"

Code like `if DF.Items.IsItemSoulbound(0, 1) then ...` will be false for both *non-bound items* and *empty slots* — fine if you only care about "is this slot definitely bound". If you need to distinguish empty from unbound, check `itemID` (10th return) explicitly:

```lua
local _, _, _, _, _, _, _, _, _, itemID, isBound = DF.Items.GetContainerItemInfo(bag, slot)
if itemID == nil then
    -- empty slot
elseif isBound then
    -- bound item
else
    -- unbound item
end
```

### `containerAPIVersion` is decided once at file load

`containerAPIVersion = detailsFramework.IsDragonflightAndBeyond() and 2 or 1` runs at module load. If a client edge case fires `IsDragonflightAndBeyond()` returning the wrong value at load (which is not normal — the function checks build constants — but is conceivable during world-rev transitions), the wrong backend is locked in for the session. The runtime guard `C_Container and C_Container.GetContainerItemInfo` saves you on classic clients where the table is missing, but won't save you on a retail client that mis-detects DF.

**Fix**: re-evaluate the version check inside the function if your addon ships across all client builds and you've seen mis-detection. The cost is one extra branch per call.

### The 11-return order is fragile

`GetContainerItemInfo`'s legacy positional return order is encoded inline in the function body. If Blizzard adds a 12th field to `itemInfo` (e.g. `itemInfo.questId`, `itemInfo.classID`), this shim won't expose it — you'd need to call `C_Container.GetContainerItemInfo` directly to read newer fields.

### `Items` is not a class; it's a flat namespace

```lua
detailsFramework.Items = {}
```

There's no constructor, no instance, no metatable. Don't try `DF.Items:new()` or `DF:CreateItems()`. The two functions are static.

---

## Public method reference

| Method | Purpose |
|---|---|
| `detailsFramework.Items.GetContainerItemInfo(bag, slot)` | Cross-API container item lookup. Returns the legacy 11-tuple. |
| `detailsFramework.Items.IsItemSoulbound(bag, slot)` | Convenience for "is the item in this slot bound?". Returns `boolean?`. |

---

## Usage Examples

### Basic

```lua
local DF = _G["DetailsFramework"]

for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
        local _, count, _, quality, _, _, link, _, _, itemID = DF.Items.GetContainerItemInfo(bag, slot)
        if itemID then
            print(("[%d,%d] x%d %s"):format(bag, slot, count or 1, link))
        end
    end
end
```

### Walk every bound item

```lua
local DF = _G["DetailsFramework"]

local function forEachBoundItem(callback)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            if DF.Items.IsItemSoulbound(bag, slot) then
                local _, _, _, _, _, _, link = DF.Items.GetContainerItemInfo(bag, slot)
                callback(bag, slot, link)
            end
        end
    end
end

forEachBoundItem(function(bag, slot, link)
    print(("Bound: %s in [%d,%d]"):format(link, bag, slot))
end)
```

---

## Notes for AI readers

1. **This is a compatibility shim, not a model.** The legacy 11-return tuple is the contract. Don't introduce table-returning helpers and expect them to interop with consumer code written against the legacy globals.
2. **All-nil on empty slots is load-bearing behaviour** that consumers depend on. Returning a sentinel table for empty slots would break callers.
3. **The version branch is one-time.** If you wrap or rewrite this file, preserve the `IsDragonflightAndBeyond()` check at load time AND the runtime `C_Container and C_Container.GetContainerItemInfo` guard — they protect different scenarios.
4. **Don't pass `nil`** for either argument; the legacy global errors on nil bag index, and the modern `C_Container` call returns nil silently. Neither outcome is what consumers expect.

---

## See also

- `auras.lua` — sibling compatibility shim for aura APIs (similar pattern of legacy-vs-`C_*` branching).
- `loadconditions.lua` — uses `IsDragonflightAndBeyond` and related build-detection helpers; lives in the same family of cross-version compatibility code.
