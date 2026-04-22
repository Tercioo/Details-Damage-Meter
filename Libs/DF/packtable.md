# PackTable System Documentation

## Overview

The packtable system provides functions for serializing Lua tables into comma-separated strings and deserializing them back. All functions are defined on `detailsFramework.table` (aliased as `DetailsFramework.table`).

The system handles four data layouts:

| Layout | Pack | Unpack | Description |
|---|---|---|---|
| Flat array | `pack` | `unpack` | Single indexed table. |
| Array of arrays | `packsub` | `unpacksub` | Multiple indexed subtables, each with its own length prefix. |
| Merged arrays | `packsubmerge` | `unpack` | Multiple subtables flattened into one, single length prefix. |
| Hash map | `packhash` | `unpackhash` | Key-value pairs. |
| Hash with array values | `packhashsubtable` | `unpackhashsubtable` | Keys mapping to indexed subtables. |

All pack functions return strings. All unpack functions accept strings and return tables.

---

## Pack Functions

### pack(table)

Serializes an indexed table into a string. The first value in the output is the table length, followed by all elements.

```lua
local str = DetailsFramework.table.pack(table)
```

| Parameter | Type | Description |
|---|---|---|
| `table` | `table` | An indexed (array) table. |

**Returns**: `string`

**Format**: `"length,value1,value2,...,valueN"`

**Example**:

```lua
local t = {1, 2, 3, 4, 5}
local packed = DetailsFramework.table.pack(t)
-- Result: "5,1,2,3,4,5"
```

---

### packsub(table)

Serializes an array of subtables. Each subtable is packed individually with its own length prefix using `pack`.

```lua
local str = DetailsFramework.table.packsub(table)
```

| Parameter | Type | Description |
|---|---|---|
| `table` | `table` | An array of indexed subtables. |

**Returns**: `string`

**Format**: `"len1,val1a,val1b,...,len2,val2a,val2b,..."`

Each subtable segment starts with its own length.

**Example**:

```lua
local t = { {1, 2, 3}, {4, 5, 6}, {7, 8, 9} }
local packed = DetailsFramework.table.packsub(t)
-- Result: "3,1,2,3,3,4,5,6,3,7,8,9"
```

---

### packsubmerge(table)

Merges all subtables into a single flat sequence with one total length prefix. Subtable boundaries are lost.

```lua
local str = DetailsFramework.table.packsubmerge(table)
```

| Parameter | Type | Description |
|---|---|---|
| `table` | `table` | An array of indexed subtables. |

**Returns**: `string`

**Format**: `"totalLength,val1,val2,...,valN"` — the total count of all values across all subtables, followed by all values in order.

**Example**:

```lua
local t = { {1, 2, 3}, {4, 5, 6}, {7, 8, 9} }
local packed = DetailsFramework.table.packsubmerge(t)
-- Result: "9,1,2,3,4,5,6,7,8,9"
```

---

### packhash(table)

Serializes a key-value table into alternating key,value pairs.

```lua
local str = DetailsFramework.table.packhash(table)
```

| Parameter | Type | Description |
|---|---|---|
| `table` | `table` | A hash table with string/number keys and string/number values. |

**Returns**: `string`

**Format**: `"key1,value1,key2,value2,..."` — no length prefix. Order is non-deterministic (uses `pairs`).

**Example**:

```lua
local t = {["abc"] = 1, ["def"] = 2, ["ghi"] = 3}
local packed = DetailsFramework.table.packhash(t)
-- Result: "abc,1,def,2,ghi,3" (order may vary)
```

---

### packhashsubtable(table)

Serializes a hash table where each value is an indexed subtable. Each entry is: key, subtable length, subtable values.

```lua
local str = DetailsFramework.table.packhashsubtable(table)
```

| Parameter | Type | Description |
|---|---|---|
| `table` | `table` | A hash table where values are indexed tables. |

**Returns**: `string`

**Format**: `"key1,len1,val1a,val1b,...,key2,len2,val2a,..."` — order is non-deterministic.

**Example**:

```lua
local t = {["abc"] = {1, 2, 3}, ["def"] = {4, 5, 6}, ["ghi"] = {7, 8, 9}}
local packed = DetailsFramework.table.packhashsubtable(t)
-- Result: "abc,3,1,2,3,def,3,4,5,6,ghi,3,7,8,9" (order may vary)
```

---

## Unpack Functions

### unpack(data, startIndex)

Deserializes a length-prefixed segment from a string or pre-split table. Reads one segment starting at `startIndex`.

```lua
local result, nextIndex = DetailsFramework.table.unpack(data, startIndex)
```

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `data` | `string` or `table` | yes | — | Comma-separated string, or a pre-split array of string values. |
| `startIndex` | `number` | no | `1` | Position of the length prefix in the data. |

**Returns**:

| # | Type | Description |
|---|---|---|
| 1 | `table` | The unpacked indexed table. Values are converted to numbers where possible, otherwise kept as strings. |
| 2 | `number` | The next index to read from, or `0` if there is no more data. |

**Behavior**:
1. If `data` is a string, splits it by commas into an array.
2. Reads `data[startIndex]` as the segment length.
3. Extracts that many values starting from `startIndex + 1`.
4. Returns the result table and the index of the next segment's length prefix (or `0` if at end).

**Examples**:

```lua
-- Simple unpack
local t, next = DetailsFramework.table.unpack("5,1,2,3,4,5")
-- t = {1, 2, 3, 4, 5}, next = 0

-- Reading from a specific offset (multiple segments in one string)
local t, next = DetailsFramework.table.unpack("5,1,2,3,4,5,2,5,4,3,1,2,3", 7)
-- t = {5, 4}, next = 10
```

---

### unpacksub(data, startIndex)

Deserializes a string containing multiple length-prefixed segments (produced by `packsub`). Repeatedly calls `unpack` until all segments are consumed.

```lua
local result = DetailsFramework.table.unpacksub(data, startIndex)
```

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `data` | `string` | yes | — | Comma-separated string with multiple length-prefixed segments. |
| `startIndex` | `number` | no | `1` | Position to start reading. |

**Returns**: `table` — an array of tables, one per segment.

**Example**:

```lua
local tables = DetailsFramework.table.unpacksub("3,1,2,3,3,4,5,6,3,7,8,9")
-- tables = { {1, 2, 3}, {4, 5, 6}, {7, 8, 9} }
```

---

### unpackhash(data)

Deserializes alternating key-value pairs (produced by `packhash`).

```lua
local result = DetailsFramework.table.unpackhash(data)
```

| Parameter | Type | Description |
|---|---|---|
| `data` | `string` | Comma-separated key-value pairs. |

**Returns**: `table` — a hash table. All keys and values remain as strings (no number conversion).

**Example**:

```lua
local t = DetailsFramework.table.unpackhash("abc,1,def,2,ghi,3")
-- t = {abc = "1", def = "2", ghi = "3"}
```

**Note**: Unlike `unpack`, `unpackhash` does **not** convert values to numbers. All values are strings.

---

### unpackhashsubtable(data)

Deserializes a string where each segment is: key, subtable length, subtable values (produced by `packhashsubtable`).

```lua
local result = DetailsFramework.table.unpackhashsubtable(data)
```

| Parameter | Type | Description |
|---|---|---|
| `data` | `string` | Comma-separated hash-with-subtable data. |

**Returns**: `table` — a hash table where each value is an indexed array of strings. Values within subtables are **not** converted to numbers.

**Example**:

```lua
local t = DetailsFramework.table.unpackhashsubtable("abc,2,1,2,def,5,4,5,6,9,2,ghi,3,7,8,9")
-- t = {abc = {"1", "2"}, def = {"4", "5", "6", "9", "2"}, ghi = {"7", "8", "9"}}
```

---

## Pack/Unpack Pairs

| Pack Function | Unpack Function | Data Shape |
|---|---|---|
| `pack` | `unpack` | `{v1, v2, ...}` |
| `packsub` | `unpacksub` | `{ {v1a, ...}, {v2a, ...}, ... }` |
| `packsubmerge` | `unpack` | `{ {v1a, ...}, {v2a, ...} }` → flattened to `{v1a, ..., v2a, ...}` |
| `packhash` | `unpackhash` | `{k1 = v1, k2 = v2}` |
| `packhashsubtable` | `unpackhashsubtable` | `{k1 = {v1a, ...}, k2 = {v2a, ...}}` |

### packsubmerge vs packsub

- `packsub` preserves subtable boundaries (each subtable has its own length prefix). Use `unpacksub` to recover the original subtables.
- `packsubmerge` discards subtable boundaries (one combined length prefix). Use `unpack` to recover a single flat array.

---

## Number Conversion Behavior

| Function | Converts to numbers? |
|---|---|
| `unpack` | Yes — each value is tested with `tonumber`; numbers are stored as numbers, non-numeric strings stay as strings. |
| `unpacksub` | Yes — delegates to `unpack`. |
| `unpackhash` | No — all keys and values are strings. |
| `unpackhashsubtable` | No — all keys and subtable values are strings. |

---

## Table Mutation

All pack functions are **read-only** — they do not modify the input table.

All unpack functions create and return **new tables**. They do not mutate input data. When `unpack` receives a string, it creates an intermediate split table internally.

`unpack` accepts a pre-split table as its first argument. This is used internally by `unpacksub` to avoid re-splitting the string for each segment.

---

## Workflows

### Flat array round-trip

```lua
local original = {10, 20, 30}
local packed = DetailsFramework.table.pack(original)
-- "3,10,20,30"
local restored, _ = DetailsFramework.table.unpack(packed)
-- {10, 20, 30}
```

### Subtable round-trip

```lua
local original = { {1, 2}, {3, 4, 5} }
local packed = DetailsFramework.table.packsub(original)
-- "2,1,2,3,3,4,5"
local restored = DetailsFramework.table.unpacksub(packed)
-- { {1, 2}, {3, 4, 5} }
```

### Hash round-trip

```lua
local original = {hp = 100, mp = 50}
local packed = DetailsFramework.table.packhash(original)
-- "hp,100,mp,50" (order may vary)
local restored = DetailsFramework.table.unpackhash(packed)
-- {hp = "100", mp = "50"}  (values are strings)
```

### Hash with subtable round-trip

```lua
local original = {skills = {1, 2, 3}, buffs = {7, 8}}
local packed = DetailsFramework.table.packhashsubtable(original)
-- "skills,3,1,2,3,buffs,2,7,8" (order may vary)
local restored = DetailsFramework.table.unpackhashsubtable(packed)
-- {skills = {"1", "2", "3"}, buffs = {"7", "8"}}  (values are strings)
```

### Sequential reading with unpack

`unpack` returns a `nextIndex` that can be used to read multiple segments from a single string or table without re-parsing:

```lua
local data = "5,1,2,3,4,5,2,5,4,3,1,2,3"
local t1, nextIdx = DetailsFramework.table.unpack(data, 1)
-- t1 = {1, 2, 3, 4, 5}, nextIdx = 7
local t2, nextIdx = DetailsFramework.table.unpack(data, nextIdx)
-- t2 = {5, 4}, nextIdx = 10
```
