# Scheduling System

## Overview

The `detailsFramework.Schedules` namespace provides timing and execution control for addon code running in the WoW Lua environment. WoW addons run on a single thread — any function that takes too long blocks the game's render loop and causes visible frame drops. This system solves that by offering:

1. **Delayed execution** — run a function after a time delay (`After`, `NewTimer`, `AfterById`, `AfterByIdNoCancel`).
2. **Repeated execution** — run a function on an interval until cancelled (`NewTicker`) or for a fixed number of iterations (`NewLooper`).
3. **Combat-deferred execution** — queue work that cannot run during combat lockdown (`AfterCombat`).
4. **Frame-distributed execution** — split a large task across many frames so each frame only does a small chunk (`LazyExecute`).
5. **Next-frame execution** — defer a function to the next render frame (`RunNextTick`).

All timing functions build on WoW's `C_Timer` API. `LazyExecute` uses `C_Timer.After(0, ...)` internally to schedule one iteration per frame.

---

## Functions

### `After(time, callback)`

Schedule a bare callback to run after a delay. Thin wrapper around `C_Timer.After`.

| Parameter | Type | Description |
|---|---|---|
| `time` | `number` | Delay in seconds. |
| `callback` | `function` | Function to call. |

**Returns:** Nothing.

No cancellation handle is returned. Use `NewTimer` if you need to cancel.

---

### `RunNextTick(callback)`

Schedule a callback to run on the next frame. Equivalent to `After(0, callback)`.

| Parameter | Type | Description |
|---|---|---|
| `callback` | `function` | Function to call on the next frame. |

**Returns:** Nothing.

---

### `NewTimer(time, callback, ...)`

Schedule a one-shot callback with a payload. Returns a timer object that can be cancelled.

| Parameter | Type | Description |
|---|---|---|
| `time` | `number` | Delay in seconds. |
| `callback` | `function` | Called as `callback(...)` after the delay. |
| `...` | `any` | Arguments passed to the callback. |

**Returns:** `timer` — a WoW timer handle with `:Cancel()` and `:IsCancelled()`.

The returned timer also has:

| Field | Type | Description |
|---|---|---|
| `payload` | `table` | The packed varargs. |
| `callback` | `function` | The callback function. |
| `expireAt` | `number` | `GetTime() + time` at creation. |

---

### `NewTicker(time, callback, ...)`

Schedule a repeating callback that ticks every `time` seconds until explicitly cancelled.

| Parameter | Type | Description |
|---|---|---|
| `time` | `number` | Interval in seconds between ticks. |
| `callback` | `function` | Called as `callback(...)` on each tick. |
| `...` | `any` | Arguments passed to the callback. |

**Returns:** `timer` — call `:Cancel()` to stop.

---

### `NewLooper(time, callback, loopAmount, loopEndCallback, checkPointCallback, ...)`

Schedule a repeating callback that runs a fixed number of times, with optional checkpoint validation.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `time` | `number` | Yes | Interval in seconds between ticks. |
| `callback` | `function` | Yes | Called as `callback(...)` on each tick. |
| `loopAmount` | `number` | Yes | Total number of iterations. |
| `loopEndCallback` | `function?` | No | Called (no arguments) when all iterations complete or the checkpoint cancels the loop. |
| `checkPointCallback` | `function?` | No | Called as `checkPointCallback(...)` at most once per second. If it returns `false`, the loop is cancelled and `loopEndCallback` fires. |
| `...` | `any` | No | Arguments passed to `callback` and `checkPointCallback`. |

**Returns:** `df_looper` — a timer handle with `:Cancel()`.

**Checkpoint behavior:** The `checkPointCallback` is rate-limited to once per second (tracked via `nextCheckPoint`). This allows periodic validation (e.g. "is the target frame still visible?") without running the check on every single tick.

---

### `Cancel(tickerObject)`

Cancel an ongoing ticker or timer. Safe to call with `nil`.

| Parameter | Type | Description |
|---|---|---|
| `tickerObject` | `timer?` | The timer/ticker to cancel. Ignored if `nil`. |

**Returns:** Nothing.

---

### `AfterById(time, callback, id, ...)`

Schedule a delayed callback identified by an ID. If a timer with the same ID already exists, it is **cancelled and replaced**.

| Parameter | Type | Description |
|---|---|---|
| `time` | `number` | Delay in seconds. |
| `callback` | `function` | Called as `callback(...)` after the delay. |
| `id` | `any` | Unique identifier for this schedule. |
| `...` | `any` | Arguments passed to the callback. |

**Returns:** `timer`

**Use case:** Debouncing — when repeated events should only trigger one delayed action (e.g. a resize handler that fires many times but should only execute once after the user stops resizing). Each new call with the same `id` resets the timer.

Internal storage: `detailsFramework.Schedules.ExecuteTimerTable[id]`.

---

### `AfterByIdNoCancel(time, callback, id, ...)`

Schedule a delayed callback identified by an ID. If a timer with the same ID already exists and has not finished, the new call is **ignored** (the existing timer continues).

| Parameter | Type | Description |
|---|---|---|
| `time` | `number` | Delay in seconds. |
| `callback` | `function` | Called as `callback(...)` after the delay. |
| `id` | `any` | Unique identifier for this schedule. |
| `...` | `any` | Arguments passed to the callback. |

**Returns:** `timer` or `nil` (nil if blocked by existing timer).

**Use case:** Throttling — ensure a function runs at most once every `time` seconds regardless of how many times it is requested.

Internal storage: `detailsFramework.Schedules.ExecuteTimerTableNoCancel[id]`. The entry is cleaned up via a separate `C_Timer.After(time, ...)` that sets the slot to `nil`.

---

### `AfterCombat(callback, id, ...)`

Queue a callback to run when the player leaves combat. If the player is **not** currently in combat, the callback runs immediately.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `callback` | `function` | Yes | Called as `callback(...)`. |
| `id` | `any?` | No | If provided, the schedule is keyed by this ID. A new call with the same ID replaces the previous one. If `nil`, the callback is appended to a list (can have duplicates). |
| `...` | `any` | No | Arguments passed to the callback. |

**Returns:** Nothing.

**Execution:** All queued callbacks fire on the `PLAYER_REGEN_ENABLED` event. Callbacks with IDs fire via `pairs` (unordered). Callbacks without IDs fire via `ipairs` (insertion order). Both queues are wiped after execution.

---

### `CancelAfterCombat(id)`

Remove a combat-deferred schedule by its ID.

| Parameter | Type | Description |
|---|---|---|
| `id` | `any` | The ID passed to `AfterCombat`. |

---

### `CancelAllAfterCombat()`

Remove all combat-deferred schedules (both with and without IDs).

---

### `IsAfterCombatScheduled(id)`

Check whether a combat-deferred schedule with the given ID exists.

| Parameter | Type | Description |
|---|---|---|
| `id` | `any` | The ID to check. |

**Returns:** `boolean`

---

### `SetName(object, name)`

Assign a debug name to a timer/ticker object.

| Parameter | Type | Description |
|---|---|---|
| `object` | `timer` | The timer or ticker. |
| `name` | `string` | A name for identification. |

---

## LazyExecute — Deep Dive

### Concept

`LazyExecute` splits a large computation across multiple render frames. Instead of doing all the work in one frame (which would freeze the game), it does one small piece per frame. Each frame, WoW renders, then runs the scheduled chunk, then renders again. The user sees smooth gameplay while the work progresses in the background.

### Signature

```lua
detailsFramework.Schedules.LazyExecute(callback, payload, maxIterations, onEndCallback)
```

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `callback` | `function` | Yes | — | The worker function. Called once per frame. |
| `payload` | `table?` | No | `{}` | A table passed to every invocation of `callback`. The callback reads from and writes to this table to maintain state between frames. |
| `maxIterations` | `number?` | No | `100000` | Upper bound on the number of frames the task may run. Acts as a safety limit. |
| `onEndCallback` | `function?` | No | `nil` | Called when the task finishes (either by the callback returning `true` or by reaching `maxIterations`). Receives `payload` as its argument. |

**Returns:** `table` — the `payload` table (same reference passed in or the auto-created `{}`).

### Callback Signature

```lua
function callback(payload, iterationCount, maxIterations)
    -- payload:        the shared state table
    -- iterationCount: 1-based frame number (1 on first call, 2 on second, etc.)
    -- maxIterations:  the max iterations cap
    -- return true to signal completion (stops scheduling further frames)
    -- return false/nil to continue on the next frame
end
```

### Internal Mechanism

```
Frame 1:  wrapFunc() called synchronously
            → callback(payload, 1, maxIterations)
            → if callback returns true  → call onEndCallback(payload), stop
            → if callback returns false → increment iterationIndex
                                        → C_Timer.After(0, wrapFunc)  [schedule next frame]

Frame 2:  wrapFunc() fires (from C_Timer)
            → callback(payload, 2, maxIterations)
            → same logic...

Frame N:  iterationIndex > maxIterations
            → call onEndCallback(payload), stop  [safety bailout]

  OR

Frame K:  callback returns true
            → call onEndCallback(payload), stop  [normal completion]
```

Key implementation details:

1. **One iteration = one frame.** Each call to `C_Timer.After(0, ...)` defers to the next frame. The callback runs exactly once per frame.
2. **The first iteration is synchronous.** `wrapFunc()` is called immediately, not deferred. Frame 1 work happens in the same frame as the `LazyExecute` call.
3. **The callback controls how much work per frame.** The system calls the callback once per frame, but the callback itself may contain a loop that processes many items. The callback decides its own batch size (e.g. 50 data points, 2500 spell IDs).
4. **State lives in `payload`.** The payload table persists across all frames. The callback reads mutable state (like `currentDataIndex`) from it and writes updated state back.
5. **`maxIterations` is a frame count limit, not a work-item limit.** It bounds the number of frames, not the number of items processed. The callback's internal loop determines items-per-frame.
6. **`onEndCallback` fires in both completion paths** — whether the callback returned `true` (work done) or `maxIterations` was reached (safety limit hit).

### Execution Flow Diagram

```
LazyExecute(callback, payload, max, onEnd)
     │
     ▼
  ┌──────────────────┐
  │ assert callback   │
  │ payload = {} if   │
  │   nil             │
  │ iterationIndex = 1│
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────────────────┐
  │ wrapFunc()                   │◄──────────────────┐
  │  result = callback(payload,  │                   │
  │           iterationIndex,    │                   │
  │           maxIterations)     │                   │
  └────────┬─────────────────────┘                   │
           │                                         │
     ┌─────┴─────┐                                   │
     │ result?   │                                   │
     ▼           ▼                                   │
   true       false/nil                              │
     │           │                                   │
     │     iterationIndex++                          │
     │           │                                   │
     │     ┌─────┴──────────┐                        │
     │     │ > maxIter?     │                        │
     │     ▼                ▼                        │
     │    yes              no                        │
     │     │         C_Timer.After(0, wrapFunc) ─────┘
     │     │
     ▼     ▼
  onEndCallback(payload)
     │
     ▼
   (done)
```

### What the Callback Should Do

The callback is responsible for:

1. **Reading its progress state** from `payload` (e.g. `payload.currentDataIndex`).
2. **Doing a batch of work** — looping through a fixed number of items per frame.
3. **Writing updated state** back to `payload` (e.g. incrementing `payload.currentDataIndex`).
4. **Returning `true`** when all work is done, or **returning `false`/`nil`** to continue.

The callback must manage its own concept of "how much work per frame." The `LazyExecute` system only guarantees that the callback is invoked once per frame.

### Performance Implications

**Why it improves performance:**
Each frame in WoW has a limited time budget (e.g. ~16ms at 60 FPS). A task that processes 500,000 spell IDs would take hundreds of milliseconds synchronously, freezing the game for multiple frames. By doing 2,500 IDs per frame across 200 frames, each frame only spends a fraction of a millisecond on the task.

**When to use it:**
- Iterating over large data sets (thousands of items).
- Computing aggregations or transformations that touch many data points.
- Building caches that don't need to be ready immediately.

**When NOT to use it:**
- Small tasks that complete in under a millisecond — the overhead of `C_Timer.After` and closure creation is not justified.
- Tasks where the result is needed immediately/synchronously — `LazyExecute` is asynchronous; the result is only available after all frames have processed.
- Time-critical operations where even one frame of delay is unacceptable.

### Edge Cases

**Callback returns `true` on the first frame:**
The task completes immediately. `onEndCallback` fires in the same frame. No `C_Timer.After` is scheduled.

**Callback never returns `true`:**
The task runs for `maxIterations` frames, then stops. `onEndCallback` fires. Without an explicit max, this defaults to 100,000 frames (~28 minutes at 60 FPS).

**`maxIterations` reached before work is done:**
`onEndCallback` fires with whatever state is in `payload`. The callback is not called again. The caller should set `maxIterations` high enough to cover the expected workload, or the `onEndCallback` should handle partial completion.

**`payload` is `nil`:**
An empty table `{}` is created and used. The callback can still write state to it.

**Multiple `LazyExecute` calls:**
Each call creates its own independent closure with its own `iterationIndex` and `payload`. Multiple lazy tasks run concurrently (one iteration of each per frame). They do not interfere with each other, but they do share the frame's time budget.

**Error in callback:**
The callback is **not** wrapped in `xpcall` by `LazyExecute`. If the callback throws an error, the chain breaks — no further frames are scheduled and `onEndCallback` does not fire. Callers who need error resilience should wrap their callback logic in `pcall` or `xpcall` internally.

---

## Real-World Usage Patterns

### Pattern 1: Spell Cache Loading (auras.lua)

**Problem:** Building a lookup table of all ~500,000 spell IDs would freeze the game.

**Solution:** Process 2,500 spell IDs per frame across 200 frames.

```lua
local lazyLoadAllSpells = function(payload, iterationCount, maxIterations)
    local startPoint = payload.nextIndex
    local endPoint = startPoint + 2500
    payload.nextIndex = endPoint

    local i = startPoint + 1
    while (i < endPoint) do
        local spellName = GetSpellInfo(i)
        if (spellName) then
            spellName = toLowerCase(spellName)
            payload.hashMap[spellName] = i
            payload.indexTable[#payload.indexTable + 1] = spellName

            local t = payload.allSpellsSameName[spellName]
            if (not t) then
                t = {}
                payload.allSpellsSameName[spellName] = t
            end
            t[#t + 1] = i
        end
        i = i + 1
    end
    -- never returns true: relies on maxIterations (200) to stop
end

local payload = {
    nextIndex = 0,
    hashMap = hashMap,
    indexTable = indexTable,
    allSpellsSameName = allSpellsSameName,
}

detailsFramework.Schedules.LazyExecute(lazyLoadAllSpells, payload, 200)
```

**Key observations:**
- The callback processes a fixed batch (2,500 items) per frame by using an internal `while` loop.
- `payload.nextIndex` tracks progress between frames.
- The callback **never returns `true`** — it relies entirely on `maxIterations = 200` to stop after 200 frames (200 × 2,500 = 500,000 IDs).
- No `onEndCallback` is used; the cache tables are populated in-place via references in the payload.

### Pattern 2: Chart Line Drawing (charts.lua — Plot)

**Problem:** A chart with thousands of data points would take too long to draw lines for in a single frame.

**Solution:** Draw 50 lines per frame until all data is plotted.

```lua
local lazyChartUpdate = function(payload, iterationCount, maxIterations)
    -- ... read state from payload ...
    for i = 1, payload.executionsPerFrame do
        local value, dataIndex = self:GetDataNextValue()
        if (not value) then
            -- no more data points
            return true  -- signal completion
        end
        -- create line, set points, handle fill...
    end
    -- update payload with current position
    payload.currentXPoint = currentXPoint
    payload.currentYPoint = currentYPoint
    -- return nil to continue next frame
end

local payload = {
    executionsPerFrame = 50,
    self = chartObject,
    currentDataIndex = 1,
    -- ... other state ...
}

detailsFramework.Schedules.LazyExecute(lazyChartUpdate, payload)
```

**Key observations:**
- `payload.executionsPerFrame = 50` controls the batch size within the callback's `for` loop.
- The callback returns `true` when `GetDataNextValue()` returns `nil` (data exhausted) — this is early completion.
- Default `maxIterations` (100,000) is used as a safety net.
- No `onEndCallback` — chart rendering is self-contained in the callback.

### Pattern 3: Statistical Smoothing (charts.lua — LOESS/SMA)

**Problem:** Computing a LOESS or SMA smooth over a large data set is CPU-intensive.

**Solution:** Process 100 data points per frame, then update the chart when done.

```lua
local lazyLOESSUpdate = function(payload, iterationCount, maxIterations)
    -- process payload.executionsPerFrame data points
    for i = currentDataIndex, currentDataIndex + payload.executionsPerFrame do
        -- compute weighted regression for point i
        if (i == lastDataIndex) then
            return true  -- all points processed
        end
    end
    -- does NOT return true here: continues next frame
end

local onEndLazyExecution = function(payload)
    chartFrame:SetDataRaw(payload.result)
    chartFrame.average = payload.sumTotal / dataSize
    -- update chart min/max, clear old lines, update UI state
    mainFrame:SetBackgroundProcessState(false)
end

mainFrame:SetBackgroundProcessState(true)
schedules.LazyExecute(lazyLOESSUpdate, payload, 999, onEndLazyExecution)
```

**Key observations:**
- `onEndCallback` is used to apply results to the chart after all computation finishes.
- `SetBackgroundProcessState(true/false)` is called before and after to provide a visual loading indicator.
- `maxIterations = 999` is set high enough that the callback will return `true` before hitting the limit.
- The callback returns `true` from inside the loop when it reaches the last data point.

---

## Common Conventions

### Payload Structure Convention

All observed usages follow the same pattern for the payload table:

| Key | Purpose |
|---|---|
| `currentDataIndex` or `nextIndex` | Tracks where the callback left off. |
| `executionsPerFrame` | Batch size per frame (how many items the callback's inner loop processes). |
| Data references (tables) | Output tables that are populated in-place. |
| Scalar state | Values like `currentXPoint`, `sum`, etc. that carry over between frames. |

### Batch Size Guidelines

From observed usage:

| Workload | Items Per Frame | Frames |
|---|---|---|
| Spell ID lookup (`GetSpellInfo`) | 2,500 | 200 |
| Chart line creation (draw calls) | 50 | depends on data size |
| Statistical computation (LOESS/SMA) | 100 | depends on data size |

Heavier per-item work (draw calls, math) uses smaller batches. Lighter work (simple hash lookups) uses larger batches.

### Choosing `maxIterations`

- If the total work is predictable (e.g. 500,000 IDs ÷ 2,500 per frame = 200 frames), set `maxIterations` to the exact frame count.
- If the total work is data-dependent, set `maxIterations` to a generous upper bound (e.g. 999) and have the callback return `true` when done.
- The default of 100,000 is almost never appropriate for real use. Always set an explicit value.

### Completion Signaling

Two approaches are used:

1. **Return `true` from callback** — the callback detects "no more data" and returns `true`. Used when the data size is not known ahead of time or when early exit is possible.
2. **Rely on `maxIterations`** — the callback never returns `true` and processes a fixed total amount. Used when the work is a fixed scan (e.g. all spell IDs from 1 to 500,000).

Both approaches trigger `onEndCallback` if one is provided.
