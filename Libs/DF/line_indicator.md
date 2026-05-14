# line_indicator.lua — Draggable Vertical Guide Lines

A mixin that adds **vertical guide lines** to a host frame — thin, full-height, optionally draggable, used to mark positions on a timeline, progress bar, or any horizontally-arranged visualisation. Each line is bound to a data entry and represents a value expressed in one of three coordinate systems: `PERCENT`, `TIME`, or `PIXELS`. The framework computes the line's X position from the value; while the user drags it, the value updates back from the cursor position. The likely production consumer is the Details! timeline window (`timeline.lua` has the matching pixel-per-second concept).

---

## Mental model

```
   host frame  ──  containing visualisation (timeline, bar chart, etc.)
   ┌──────────────────────────────────────────────────────────────┐
   │                  │                       │           │       │
   │     content      │   content             │ content   │       │
   │                  ▲                       ▲           ▲       │
   │              line 1                  line 2     line 3       │
   │            value=0.25            value=12.5s  value=320px    │
   │            type=PERCENT          type=TIME    type=PIXELS    │
   └────xOffset───────────────────────────────────────────────────┘
        ↑
        lineIndicatorXOffset — left padding excluded from the
        "effective width" used by PERCENT and TIME math.
```

**The split that matters most**: the user-facing **data** lives in `lineIndicatorData` (an array of `df_lineindicator_data` tables) on the host frame. The **rendered lines** (`df_lineindicator_line`) come from a `df_pool` — they are recycled, never destroyed. Every call to `LineIndicatorRefresh` resets the pool and re-acquires lines from scratch. So:

- Mutating `data.value` in place is fine, but you must call `LineIndicatorRefresh` (or one of the wrappers that does it for you) to re-position the rendered line.
- Holding a reference to a `line` across `LineIndicatorRefresh` calls is unsafe — that exact button may now be bound to a different data entry, or hidden.
- Drag updates the bound `data.value` directly in place, so the data table reflects the live position during a drag.

### Value types

| Type | Domain | Math (X position from value) | Inverse (value from X) |
|---|---|---|---|
| `"PERCENT"` | `[0, 1]` (0 = left, 1 = right) | `x = (targetWidth - xOffset) * value` | `value = (left - xOffset) / (targetWidth - xOffset)` |
| `"TIME"` | seconds | `x = (targetWidth - xOffset) * (value / totalTime)` | During drag: `value += dxPixels / (pixelPerSecond * scale)` |
| `"PIXELS"` | raw px from left edge (post-`xOffset`) | `x = value` (placed at `targetX + xOffset + value`) | `value = left - xOffset` |

`TIME` requires `LineIndicatorSetElapsedTime(total)` to be called first — the math asserts on `totalTime > 0`. `PERCENT` and `PIXELS` have no prerequisites.

---

## Library access

The module is a **mixin**, not a constructor. There is no `DF:CreateLineIndicator`. Apply it to a frame you already own:

```lua
local DF = _G["DetailsFramework"]
DF:Mixin(myFrame, DF.LineIndicatorMixin)
myFrame:LineIndicatorConstructor()      -- mandatory: initialises the pool and defaults
myFrame:LineIndicatorSetTarget(myFrame) -- which frame to draw lines on (defaults to self)
```

The mixin is intended to be applied to a frame that also acts as the "host" — a timeline frame, a graph frame, a status bar overlay. After mixing in and constructing, you push data via `LineIndicatorSetData` / `LineIndicatorAddData` and the lines render automatically.

---

## Setup — required call order

```lua
DF:Mixin(host, DF.LineIndicatorMixin)   -- 1. apply the mixin
host:LineIndicatorConstructor()         -- 2. initialise state (mandatory)
host:LineIndicatorSetTarget(targetFrame)-- 3. (optional) draw lines on a different frame
host:LineIndicatorSetValueType("TIME")  -- 4. (optional) global default for data without valueType
host:LineIndicatorSetElapsedTime(60)    -- 5. REQUIRED for TIME; sets the time scale
host:LineIndicatorSetData(dataArray)    -- 6. push data; rendering happens here
```

`LineIndicatorGetLine` (and most other methods) assert that `LineIndicatorConstructor` was called. Skipping step 2 errors with `"LineIndicatorGetLine(): LineIndicatorConstructor() not called."`.

---

## Class fields — `df_lineindicator`

| Field | Type | Description |
|---|---|---|
| `lineIndicatorTotalTime` | `number` | Time span (seconds) for `TIME` math. Set via `LineIndicatorSetElapsedTime`. Initial `0`. |
| `lineIndicatorXOffset` | `number` | Left padding excluded from the "effective width" used by `PERCENT` and `TIME`. Initial `0`. |
| `lineIndicators` | `df_pool` | Pool of `df_lineindicator_line` buttons. Recycled on every `Refresh`. |
| `lineIndicatorData` | `df_lineindicator_data[]` | The source data array. |
| `lineIndicatorValueType` | `"PERCENT"\|"TIME"\|"PIXELS"` | Default value type used when a data entry has no `valueType`. Initial `"PIXELS"`. |
| `lineIndicatorFrameTarget` | `frame?` | Where lines are anchored. Defaults to `self` via `LineIndicatorGetTarget`. |
| `lineIndicatorScale` | `number` | Scale factor for drag-time-to-value conversion (TIME mode only). Initial `1`. |
| `lineIndicatorLineHeight` | `number` | Height applied to every line on refresh. Initial `50`. Special: `-1` → use `GetScreenHeight() * 2`. |
| `lineIndicatorLineWidth` | `number` | Default line width when `data.width` is absent. Initial `3`. |
| `lineIndicatorPixelPerSecond` | `number` | Drag scaling for `TIME`. Initial `20` (each second = 20 px). |
| `lineIndicatorMouseEnabled` | `boolean` | Tracked but **not consumed**; see Pitfalls. Initial `true`. |
| `lineIndicatorColor` | `number[]` | RGB triple. Applied as vertex colour on every line texture during refresh. Initial `{1, 1, 1}`. |
| `lineIndicatorValueFrame` | `frame?` | Lazily created on first drag; the floating value-readout pill. |

---

## Per-line fields — `df_lineindicator_line`

| Field | Type | Description |
|---|---|---|
| `xOffset` | `number` | Computed pixel offset from the anchor. Set during `LineIndicatorSetLinePosition`. |
| `left` | `number` | Cached `:GetLeft()` value. Read by the drag handler for delta math. |
| `index` | `number` | 1-based position in `lineIndicatorData`. Stable across a single refresh; can change after `RemoveData`. |
| `data` | `df_lineindicator_data` | Back-reference to the data entry the line is currently bound to. |
| `Texture` | `Texture` | The line's fill (BACKGROUND layer, 1×1 white texture, vertex-coloured via `lineIndicatorColor`). |

---

## Data entry — `df_lineindicator_data`

| Field | Type | Description |
|---|---|---|
| `value` | `number` | Position. Interpretation depends on `valueType`. Mutated in place during drag. |
| `valueType` | `"PERCENT"\|"TIME"\|"PIXELS"` | Per-data override. Falls back to `lineIndicatorValueType` if nil (assigned during refresh, so subsequent reads see it populated). |
| `width` | `number?` | Per-line width override. Falls back to `lineIndicatorLineWidth`. |
| `color` | `number[]` | Per-line `{r, g, b}` (with optional `[4] = alpha`). Set by `LineIndicatorSetLineColor`. **Not currently read by refresh** — see Pitfalls. |
| `alpha` | `number?` | Per-line alpha. Falls back to `1`. |
| `onClick` / `onEnter` / `onLeave` | `function?` | WoW script handlers — wired directly via `line:SetScript("OnClick", ...)` etc. during refresh. Signature is the normal Button script signature. |

---

## API — every method

| Method | Purpose |
|---|---|
| `LineIndicatorConstructor()` | Initialise pool + defaults. **Must be called once before any other method.** |
| `LineIndicatorSetTarget(frame)` | Set the frame lines are anchored to. Defaults to `self` (the mixin host). |
| `LineIndicatorGetTarget()` | Returns the target frame, or `self` if unset. |
| `LineIndicatorsReset()` | Hide all rendered lines (returns them to the pool); zero `totalTime`. Does NOT clear `lineIndicatorData`. |
| `LineIndicatorCreateLine(self)` | Pool factory. Don't call directly — the pool calls it on `Acquire`. |
| `LineIndicatorGetLine()` | Acquire one line from the pool. Returns the button. |
| `LineIndicatorSetElapsedTime(total)` | Set `totalTime` for `TIME`-mode math. **Must be > 0 before any `TIME` line is positioned.** |
| `LineIndicatorSetLinePosition(line, value, valueType)` | Place a line at a value. Used internally by `AddLine`. |
| `LineIndicatorSetValueType(type)` | Set the default `valueType`. Asserts the value is one of the three. |
| `LineIndicatorAddData(data)` | Append one data entry and refresh. |
| `LineIndicatorSetData(dataArray)` | Replace the whole data array and refresh. |
| `LineIndicatorRemoveData(dataIdOrTable)` | Remove a data entry by index or by reference; refresh. |
| `LineIndicatorAddLine(value, valueType)` | Acquire a line, position it, show it. Returns the line. |
| `LineIndicatorSetXOffset(offset)` | Set the left padding excluded from `PERCENT` / `TIME` math. |
| `LineIndicatorSetScale(scale)` | Scale the drag-time conversion (TIME only). |
| `LineIndicatorRefresh()` | Reset pool, re-acquire and re-position every line from `lineIndicatorData`. Called by every mutator. |
| `LineIndicatorSetAllLinesWidth(w)` | Update `lineIndicatorLineWidth` and refresh. |
| `LineIndicatorSetAllLinesHeight(h)` | Update `lineIndicatorLineHeight` and refresh. Pass `-1` for "two screens tall". |
| `LineIndicatorSetAllLinesColor(color, g, b)` | Update `lineIndicatorColor` (via `ParseColors`) and refresh. |
| `LineIndicatorSetLineWidth(dataIdOrTable, width)` | Set `data.width` for one entry; refresh. |
| `LineIndicatorSetLineColor(dataIdOrTable, color, g, b)` | Set `data.color` for one entry; refresh. (Note: refresh does NOT consume `data.color` — see Pitfalls.) |
| `LineIndicatorSetLineAlpha(dataIdOrTable, alpha)` | Set `data.alpha` for one entry; refresh. |
| `LineIndicatorSetPixelsPerSecond(pps)` | Set the drag-time scale (TIME only). |

The `dataIdOrTable` style — many setters accept either a `number` (index into `lineIndicatorData`) or the actual data `table` (reference equality search). The handlers all `assert` that you passed one of those two types.

---

## Drag behaviour

Each line is a `Button` with `SetMovable(true)` and `RegisterForDrag("LeftButton")`. The flow:

1. **OnMouseDown** caches `indicator.left = indicator:GetLeft()`.
2. **OnDragStart**:
   - Calls `StartMoving()`.
   - Lazily creates `self.lineIndicatorValueFrame` (a small floating frame with a black-backdrop fontstring) on the first drag ever.
   - Shows the value frame and installs an `OnUpdate` that:
     - Computes `leftDiff = newLeft - prevLeft`.
     - Calls `lineIndicator_GetValueForMoving(self, indicator, leftDiff)` to compute the new `data.value`.
     - Re-anchors the value frame to `topleft, topleft, newLeft + 2, -2` on the target.
     - Formats the value into the fontstring (`IntegerToTimer` for TIME, `%.2f%%` for PERCENT, raw number for PIXELS).
3. **OnDragStop**:
   - Hides the value frame, clears `OnUpdate`, `StopMovingOrSizing()`.
   - Calls `LineIndicatorRefresh()` — which **resets the pool** and rebinds every line. The just-dragged line is destroyed-and-recreated as part of this; its identity changes but the data entry's `value` is preserved.

For `TIME`-type drags, the value-delta math uses `pixelPerSecond * lineIndicatorScale`. For `PERCENT` and `PIXELS`, the math reads the line's `left` directly (no scale factor).

---

## Pitfalls

### `LineIndicatorConstructor` must be called manually

Mixing in `LineIndicatorMixin` is not enough — the pool, the defaults, and every state field are initialised inside `LineIndicatorConstructor`. Forgetting to call it after `Mixin` results in an assertion failure on the first `LineIndicatorGetLine`:

```
LineIndicatorGetLine(): LineIndicatorConstructor() not called.
```

**Fix**: always pair `DF:Mixin(host, DF.LineIndicatorMixin)` with `host:LineIndicatorConstructor()` on the next line.

### `TIME` mode silently breaks if `totalTime` is 0

`LineIndicatorSetLinePosition` asserts `self.lineIndicatorTotalTime > 0` for `TIME` lines. Calling `LineIndicatorSetData` or `AddData` with `valueType = "TIME"` before `LineIndicatorSetElapsedTime` errors with:

```
LineIndicatorSetElapsedTime(self, totalTime) must be called before SetLineIndicatorPosition() with valueType TIME.
```

**Fix**: call `LineIndicatorSetElapsedTime(duration)` first. Repeated calls are cheap.

### `LineIndicatorSetLinePosition` overrides height for `TIME` lines

In the `TIME` branch (`line_indicator.lua:276`):

```lua
line:SetHeight(GetScreenHeight())
```

This unconditionally resizes the line to the full screen height, regardless of `lineIndicatorLineHeight`. The other two branches (`PERCENT`, `PIXELS`) don't touch height — they rely on `Refresh` to apply `lineIndicatorLineHeight`. Net effect: `TIME` lines end up full-screen-tall while `PERCENT`/`PIXELS` lines respect the configured height.

**Fix (if you need consistent heights across types)**: hook or replace `LineIndicatorSetLinePosition`, or call `line:SetHeight(self.lineIndicatorLineHeight)` after the framework call.

### `data.color` is set but not consumed during refresh

`LineIndicatorSetLineColor(dataId, color, ...)` writes `data.color = {r, g, b}` on the data entry. But the refresh loop (`line_indicator.lua:312`) reads only the *global* `self.lineIndicatorColor`:

```lua
line.Texture:SetVertexColor(unpack(self.lineIndicatorColor))
```

So per-line colours **don't render**. You can set them — they persist on the data — but every line is painted with the host-wide colour. This appears to be incomplete implementation rather than intentional.

**Fix (if you want per-line colour)**: change the refresh loop to prefer `data.color` over `lineIndicatorColor`:

```lua
line.Texture:SetVertexColor(unpack(data.color or self.lineIndicatorColor))
```

### `LineIndicatorSetLinePosition`'s `PIXELS` branch has an undefined variable

At `line_indicator.lua:284`:

```lua
elseif (valueType == "PIXELS") then
    line:ClearAllPoints()
    line:SetPoint("topleft", targetFrame, "topleft", self.lineIndicatorXOffset + value, 0)
    line.xOffset = x        -- 'x' is nil in this branch
end
```

`x` is only defined in the `PERCENT` branch. In `PIXELS`, `x` is undefined → `line.xOffset = nil`. The line still renders correctly (its X comes from `value`, not `x`), but any downstream code reading `line.xOffset` will get nil for `PIXELS` lines.

**Fix**: change to `line.xOffset = value`.

### `lineIndicatorMouseEnabled` is tracked but never consumed

The field is set to `true` in the constructor and there's a `LineIndicatorRefresh` branch that reads it:

```lua
if (self.lineIndicatorMouseEnabled) then

end
```

The branch is **empty**. The flag has no effect. Lines are always mouse-enabled (via `RegisterForDrag` and the script handlers). If you set it to `false`, expecting drag to be disabled, nothing happens.

**Fix**: there's no clean workaround inside the mixin. Disable mouse on each line after `Refresh`:

```lua
for _, line in ipairs({...iterate the pool...}) do
    line:EnableMouse(false)
end
```

Or hook `LineIndicatorCreateLine` to skip the script bindings.

### Every mutator triggers a full pool refresh

`LineIndicatorAddData`, `RemoveData`, `SetData`, `SetAllLines*`, `SetLine*` all call `LineIndicatorRefresh`, which calls `lineIndicators:Reset()` and re-acquires every line. For small N this is fine. For N in the hundreds, every per-line setter pays O(N) cost.

**Fix**: batch your mutations on the data array directly and call `LineIndicatorRefresh` once at the end. Most mutators just write to `data.<field>` and then call refresh — you can do the same yourself and skip the intermediate refreshes:

```lua
for i, data in ipairs(host.lineIndicatorData) do
    data.alpha = computeAlpha(i)
end
host:LineIndicatorRefresh()
```

### `LineIndicatorsReset` does not clear `lineIndicatorData`

The name is suggestive — but `LineIndicatorsReset` only resets the pool (hides all lines) and zeroes `totalTime`. The underlying `lineIndicatorData` array remains. The next `Refresh` will redraw all the hidden lines from the still-present data.

**Fix**: to actually clear the data, set the array to empty and refresh:

```lua
host.lineIndicatorData = {}
host:LineIndicatorRefresh()
-- or equivalently:
host:LineIndicatorSetData({})
```

### The drag value frame leaks across hosts

`lineIndicatorValueFrame` is lazily created on the host (`self.lineIndicatorValueFrame`) on the first drag. If multiple host frames share state (unusual but possible if you mix the same mixin into a parent and a child and don't separate them), the per-host frames are independent — but they're never destroyed, just `Hide()`'d on `OnDragStop`. This is fine for normal use.

### `line.left` is read by `OnMouseDown`, written by drag

The `OnMouseDown` script caches `indicator.left = indicator:GetLeft()` so the `OnDragStart` closure can compute deltas. If your consumer code reads or writes `line.left` between drags, you'll fight the drag handler. Don't shadow this field — pick a different name (e.g. `userLeft`) if you need to track your own state on the line.

### Refresh re-wires `OnClick`/`OnEnter`/`OnLeave` from data every time

The refresh loop unconditionally calls `line:SetScript("OnClick", data.onClick)`. If `data.onClick` is nil, the script is cleared. So mutating `data.onClick = nil` and calling refresh removes the click handler. This is intentional but easy to miss when debugging "why did clicks stop working?".

---

## Usage Examples

### Basic — three percent marks on a status bar overlay

```lua
local DF = _G["DetailsFramework"]

local overlay = CreateFrame("frame", "MyOverlay", parentBar)
overlay:SetAllPoints()
DF:Mixin(overlay, DF.LineIndicatorMixin)
overlay:LineIndicatorConstructor()

overlay:LineIndicatorSetData({
    { value = 0.25, valueType = "PERCENT" },
    { value = 0.50, valueType = "PERCENT" },
    { value = 0.75, valueType = "PERCENT" },
})

overlay:LineIndicatorSetAllLinesHeight(parentBar:GetHeight())
overlay:LineIndicatorSetAllLinesColor("yellow")
```

### Time markers on a 60-second timeline

```lua
local DF = _G["DetailsFramework"]

DF:Mixin(timelineFrame, DF.LineIndicatorMixin)
timelineFrame:LineIndicatorConstructor()
timelineFrame:LineIndicatorSetElapsedTime(60)     -- MANDATORY for TIME
timelineFrame:LineIndicatorSetPixelsPerSecond(20) -- 20 px = 1 second

-- Add an event marker at 12 seconds, draggable, that prints when clicked
timelineFrame:LineIndicatorAddData({
    value     = 12,
    valueType = "TIME",
    onClick   = function(line)
        print(("Clicked event at %s"):format(DF:IntegerToTimer(line.data.value)))
    end,
    onEnter   = function(line)
        GameTooltip:SetOwner(line, "ANCHOR_TOP")
        GameTooltip:SetText("Drag to reschedule")
        GameTooltip:Show()
    end,
    onLeave   = function() GameTooltip:Hide() end,
})
```

### Reading dragged value back

```lua
-- The drag handler mutates data.value in place during the drag.
-- The drag-stop refresh re-renders, but the data table is the source of truth.
local marker = timelineFrame.lineIndicatorData[1]
hooksecurefunc(timelineFrame, "LineIndicatorRefresh", function()
    print(("Marker now at %.1fs"):format(marker.value))
end)
```

### Pre-set XOffset (skip a label area on the left)

```lua
-- The target frame has a 50px label gutter on the left.
-- All PERCENT/TIME math should treat x=50 as the left edge.
overlay:LineIndicatorSetXOffset(50)
overlay:LineIndicatorSetData({ {value = 0.5, valueType = "PERCENT"} })
-- The line lands at: 50 + (width - 50) * 0.5
```

---

## Notes for AI readers

1. **There is no constructor.** The pattern is `DF:Mixin(host, DF.LineIndicatorMixin)` followed by `host:LineIndicatorConstructor()`. Skipping the constructor errors at first use.
2. **`TIME` mode requires `LineIndicatorSetElapsedTime` first.** Asserts; doesn't fall back.
3. **Per-line colour does not render.** Don't recommend `LineIndicatorSetLineColor` as a way to recolour individual lines — the refresh loop only consumes the host-wide `lineIndicatorColor`. The data field is set, just not read.
4. **Per-line height is overridden for `TIME` lines** (forced to screen height). If you need short TIME lines, override `LineIndicatorSetLinePosition` or post-process.
5. **The `PIXELS` branch writes `line.xOffset = nil` due to an undefined `x` reference.** If consumer code reads `line.xOffset`, guard for nil for PIXELS lines.
6. **Every mutator refreshes.** For batch updates, mutate `lineIndicatorData` in place and call `LineIndicatorRefresh` once.
7. **`LineIndicatorsReset` clears the pool, not the data.** To remove markers, set `lineIndicatorData = {}` and refresh.
8. **Lines are recycled — line references aren't stable across refresh.** Always read positions from `lineIndicatorData[i]`, not from `line.data` references you've cached.

---

## See also

- `timeline.lua` / `timeline.md` — the most likely host for `TIME`-mode line indicators; uses the same pixel-per-second concept.
- `panel.lua` — `DF:Mixin` lives here.
- `colors.lua` — `DF:ParseColors`, called by `LineIndicatorSetAllLinesColor` and `LineIndicatorSetLineColor`.
- `pools.lua` — `df_pool` (`DF:CreatePool`), the recycling pool the mixin uses for lines.
- `elapsedtime.lua` — `DF:IntegerToTimer`, used by the drag-time readout.
