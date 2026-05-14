# scrollbar.lua — Vertical Scrollbar Widgets

This module ships **two** scrollbar widgets with no shared code:

- **`DF:CreateScrollBar2`** — the modern scrollbar. Plain Frame track + Button thumb, proportional thumb sizing, optional step buttons, one-call binding to `df_scrollbox`. **Use this for new code.**
- **`DF:CreateScrollBar`** — legacy scrollbar from years ago. Built on a `Slider` widget, Portuguese-named methods, only customisation knob is `parent.wheel_jump`. **Do not use for new code.**

The two are documented in separate parts of this file.

---

# Part 1 — `CreateScrollBar2` (modern)

## Mental model

```
   ┌──────┐
   │  ▲   │  ← StepUpButton    (optional, top of scrollbar)
   ├──────┤
   │      │
   │ ████ │  ← Thumb            (height = trackHeight * visibleRatio)
   │      │
   │      │  ← Track            (clickable; click jumps thumb to cursor Y)
   │      │
   ├──────┤
   │  ▼   │  ← StepDownButton  (optional, bottom of scrollbar)
   └──────┘
```

The scrollbar is a plain `Frame` containing a `Track` frame (clickable background) and a `Thumb` button (draggable). Optionally adds top/bottom arrow buttons that step on click and auto-repeat on hold.

**No `Slider` widget is involved.** Scroll behaviour is driven by `SetValue` / `SetRange` / `SetVisibleRatio` calls on the wrapper. Cursor input is handled by frame scripts (`OnMouseDown` on the thumb/track/buttons, plus an `OnUpdate` poll while held).

### Why a second scrollbar?

`CreateScrollBar2` was added because WoW's `Slider` widget (used by the legacy scrollbar and `FauxScrollFrameTemplate`) has hard-to-work-around quirks:

- The thumb's hit-test region is cached at `SetThumbTexture` time, so resizing the texture (for proportional sizing) leaves the click area at the old dimensions.
- `SetMinMaxValues` doesn't render the thumb; you need a `SetValue` "kick" afterward.
- External `SetValue` during a drag fights the widget's internal drag state.

These are bypassed by composing the scrollbar from a `Frame` + `Button` instead.

---

## Library access

```lua
local DF = _G["DetailsFramework"]
local scrollBar = DF:CreateScrollBar2(parent, trackHeight, onScrollChange, options)
```

Or — when binding to a `df_scrollbox` (the typical case) — call the scrollbox method:

```lua
local scrollBar = scrollBox:CreateScrollBar2(options)
```

Both return a `df_scrollbar2`.

---

## `DF:CreateScrollBar2` — signature

```lua
function detailsFramework:CreateScrollBar2(parent, trackHeight, onScrollChange, options)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | Yes | Parent frame for the scrollbar. |
| 2 | `trackHeight` | `number` | Yes | Initial scrollbar height. Usually overridden by caller anchors. |
| 3 | `onScrollChange` | `function?` | No | Fired on every value change. Signature `function(scrollBar, value)`. |
| 4 | `options` | `df_scrollbar2_options?` | No | Configuration table (see below). |

**Returns:** `df_scrollbar2` — the wrapper frame.

---

## Options — `df_scrollbar2_options`

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `16` | Scrollbar width in pixels. |
| `backdrop_color` | `number[]` | `{0.1, 0.1, 0.1, 1.0}` | Track backdrop color `{r, g, b, a}`. |
| `border_color` | `number[]` | `{0, 0, 0, 0.3}` | Track border color. |
| `thumb_color` | `number[]` | `{0.5, 0.5, 0.5, 0.95}` | Thumb fill color (normal). |
| `thumb_hover_color` | `number[]` | `{0.7, 0.7, 0.7, 0.95}` | Thumb fill color (mouseover). |
| `wheel_step` | `number` | `20` | Value units per mouse-wheel tick. Set to `1` for line-based scrolling. |
| `min_thumb_height` | `number` | `12` | Floor for the proportional thumb height. |
| `show_step_buttons` | `boolean` | `true` | Create top/bottom arrow step buttons. |
| `step_amount` | `number` | `1` | Value units per arrow click. |
| `step_repeat_initial_delay` | `number` | `0.3` | Seconds before hold-scroll begins repeating. |
| `step_repeat_rate` | `number` | `0.05` | Seconds between hold-scroll repeats (~20 Hz). |
| `step_button_height` | `number` | `16` | Height of each arrow button. |

The `scrollBox:CreateScrollBar2(options)` helper additionally defaults `wheel_step = 1` (line-based) before merging caller options.

---

## Mixin methods — `df_scrollbar2_mixin`

All methods are called on the returned scrollbar via colon syntax. The mixin is applied through `detailsFramework:Mixin` inside the constructor.

### Value & range

#### `scrollBar:SetRange(maxValue)`

Sets the maximum scrollable value. Caller drives this from `(total content) - (visible)`. Clamps `currentValue` if it now exceeds the max and fires `OnScrollChange` on that clamp.

#### `scrollBar:GetRange()` → `number`

Returns the current `maxValue`.

#### `scrollBar:SetValue(value)`

Sets the current value, clamped to `[0, maxValue]`. Fires `OnScrollChange` if the value actually changed. Repositions the thumb and updates step-button disabled states.

#### `scrollBar:GetValue()` → `number`

Returns the current value.

### Visual ratio

#### `scrollBar:SetVisibleRatio(ratio)`

Sets the visible-to-total ratio (0..1). Drives the thumb height: `thumbHeight = trackHeight * ratio` clamped by `min_thumb_height` floor and `trackHeight` ceiling.

#### `scrollBar:GetVisibleRatio()` → `number`

Returns the current ratio.

### Callback & input

#### `scrollBar:SetOnScrollChange(callback)`

Replaces the callback set at construction. Signature: `function(scrollBar, value)`.

#### `scrollBar:EnableMouseWheelOn(frame)`

Wires the given frame's mouse wheel to step the scrollbar by `wheel_step * delta` per tick.

### Stepping

#### `scrollBar:Step(direction)`

Scrolls by one step in `direction` (`-1` = up, `+1` = down). Routes through `SetValue` so the thumb position, callback, and step-button disabled state all stay in sync. This is what the step buttons call.

### Internal helpers (rarely called directly)

| Method | Purpose |
|---|---|
| `UpdateThumbHeight()` | Recompute thumb height from track height × visible ratio. |
| `UpdateThumbPosition()` | Reposition thumb from `currentValue / maxValue`. |
| `UpdateStepButtonStates()` | Enable/disable step buttons based on `currentValue` vs `[0, maxValue]`. |
| `StartDrag(mouseButton)` / `HandleDragUpdate()` / `StopDrag()` | Thumb-drag lifecycle wired to the Thumb's mouse scripts. |
| `JumpToCursor(mouseButton)` | Track-click handler — maps cursor Y to a scroll percentage. |

All four `Update…` methods are called automatically by the public setters and by the track's `OnSizeChanged`; they're exposed for callers that want explicit recalc.

---

## Instance fields

| Field | Type | Description |
|---|---|---|
| `Track` | `frame` | Clickable background frame. |
| `Thumb` | `button` | Draggable thumb button. |
| `StepUpButton` | `button?` | Top arrow. `nil` when `show_step_buttons = false`. |
| `StepDownButton` | `button?` | Bottom arrow. `nil` when `show_step_buttons = false`. |
| `Options` | `df_scrollbar2_options` | Merged defaults + caller options. |
| `OnScrollChange` | `function?` | The callback. Can be replaced via `SetOnScrollChange`. |
| `maxValue` | `number` | Current max. Read via `GetRange`; write via `SetRange`. |
| `currentValue` | `number` | Current value. Read via `GetValue`; write via `SetValue`. |
| `visibleRatio` | `number` | Current visible/total ratio. |

---

## Step buttons

When `show_step_buttons = true` (the default):

- Two arrow buttons are created above and below the track, each `step_button_height` tall, using stock Blizzard textures (`Arrow-Up-Up` / `Arrow-Up-Down` / `Arrow-Up-Disabled`, etc.) plus a `UI-Common-MouseHilight` ADD-blend hover overlay.
- Single click: steps by `step_amount` in the corresponding direction.
- Click and hold: after `step_repeat_initial_delay` seconds, value steps every `step_repeat_rate` seconds until release. Matches WoW's native scrollbar cadence.
- Buttons auto-disable when scrolling that direction is impossible (up at value 0, down at value max).
- Release detection uses both `OnMouseUp` and an `OnUpdate` poll of `IsMouseButtonDown`, so releases off-button still stop the hold immediately.

To disable: pass `{show_step_buttons = false}`. The track then occupies the full scrollbar frame via `SetAllPoints(scrollBar)`.

---

## `df_scrollbox` integration — `scrollBox:CreateScrollBar2`

```lua
local scrollBar = scrollBox:CreateScrollBar2(options)
```

Binds a `CreateScrollBar2` widget to a `df_scrollbox` and handles every piece of wiring:

1. `scrollBox.HideScrollBar = true` — suppresses the legacy `FauxScrollFrame` slider.
2. `scrollBox.IsFauxScroll = false` — bypasses `UpdateFaux`; offset is driven by the callback.
3. `scrollBox.offset = 0` — initial offset.
4. Defaults `wheel_step = 1` (line-based) unless caller overrides.
5. Calls `DF:CreateScrollBar2(self, 100, callback, mergedOptions)` with a callback that writes `scrollBox.offset = floor(value + 0.5)` and calls `scrollBox:Refresh()`.
6. Anchors the scrollbar at `topright/bottomright` of the scrollbox with `(-2, -16)` / `(-2, 16)` offsets, frame level `+5`, mouse wheel enabled on the scrollbox.
7. Stores the scrollbar at `scrollBox.CustomScrollBar`.
8. Wraps `scrollBox.Refresh` (instance-level only) so `SyncCustomScrollBar` is called after every refresh — the scrollbar's `SetRange` / `SetVisibleRatio` auto-update as data and visible-line counts change.

**Returns** the created scrollbar. Idempotent: subsequent calls return the existing scrollbar without rewiring.

### `scrollBox:SyncCustomScrollBar()`

No-op when no scrollbar is bound. Otherwise reads `#self.data` and `self.LineAmount` and pushes them into the bound scrollbar:

- `numItems > numToDisplay`: `SetRange(numItems - numToDisplay)`, `SetVisibleRatio(numToDisplay / numItems)`, `Show()`.
- Otherwise: `SetRange(0)`, `SetVisibleRatio(1)`, `Hide()`.

Called automatically inside the wrapped `Refresh`. Safe to call manually for explicit syncs.

### Fields written on the scrollbox

| Field | Type | Description |
|---|---|---|
| `CustomScrollBar` | `df_scrollbar2?` | The bound scrollbar (or `nil` before `CreateScrollBar2` is called). |
| `offset` | `number` | Current line offset, written by the scrollbar callback and read in `Refresh`. |
| `HideScrollBar` | `boolean` | Set to `true` — suppresses the legacy slider. |
| `IsFauxScroll` | `boolean` | Set to `false` — skips `UpdateFaux`, uses `self.offset` directly. |

---

## Usage examples

### Bound to a `df_scrollbox` (typical)

```lua
local scrollBox = DF:CreateScrollBox(parent, "MyList", refreshFunc, data, 300, 200, 10, 22)
scrollBox:SetPoint("topleft", parent, "topleft", 0, 0)
scrollBox:SetPoint("bottomright", parent, "bottomright", 0, 0)

-- one call wires everything: scrollbar visible, anchored, wheel, auto-sync.
scrollBox:CreateScrollBar2()

scrollBox:SetData(myData)
scrollBox:Refresh()  -- scrollbar's range and ratio update automatically here.
```

### Customising step buttons

```lua
scrollBox:CreateScrollBar2({
    step_amount = 3,           -- 3 lines per arrow click
    step_repeat_rate = 0.1,    -- slower auto-repeat
})
```

### Disabling step buttons

```lua
scrollBox:CreateScrollBar2({show_step_buttons = false})
```

### Standalone (no scrollbox)

```lua
local scrollBar = DF:CreateScrollBar2(parent, 200, function(_, value)
    -- value is 0..maxValue; map to whatever your content needs
    content:SetVerticalScroll(value)
end, {
    wheel_step = 30,
})
scrollBar:SetPoint("topright", parent, "topright", 0, 0)
scrollBar:SetPoint("bottomright", parent, "bottomright", 0, 0)
scrollBar:SetRange(contentHeight - viewportHeight)
scrollBar:SetVisibleRatio(viewportHeight / contentHeight)
scrollBar:EnableMouseWheelOn(parent)
```

---

## Pitfalls (CreateScrollBar2)

### Standalone callers own the `SetRange`/`SetVisibleRatio` updates

`CreateScrollBar2` doesn't introspect your data. After any data or layout change, call `SetRange((total - visible))` and `SetVisibleRatio(visible / total)`. The `scrollBox:CreateScrollBar2` helper handles this for you via the `Refresh` hook; bare `DF:CreateScrollBar2` callers must call them by hand.

### `wheel_step` units = scroll-value units

If your range is line-based (`maxValue = numItems - numVisible`), set `wheel_step = 1`. If it's pixel-based, the default `20` is appropriate. A `wheel_step` larger than `maxValue` turns the wheel into a two-state toggle (clamped to min or max on every tick).

### `scrollBox:CreateScrollBar2` is idempotent

A second call returns the existing scrollbar without applying the new options. To reconfigure, mutate the returned scrollbar's `Options` table or recreate the scrollbox.

### `Refresh` is wrapped on the instance, not the mixin

The auto-sync hook is installed on the specific scrollbox instance — other scrollboxes are unaffected. The original mixin `Refresh` is captured by upvalue and called through, so the contract (return value, side effects) is preserved.

### `undefined-field` warnings on WoW Button methods

The Lua linter doesn't fully model WoW's `Button` type, so it warns on `SetNormalTexture`, `SetPushedTexture`, `RegisterForClicks`, `Enable`, `Disable`, etc. These are real WoW API methods. Per the project's `.context/coding-standards.md`, `undefined-field` warnings on WoW APIs are intentionally left visible — do not suppress them.

---

# Part 2 — `CreateScrollBar` (legacy)

> **Legacy notice — verbatim from the source (`scrollbar.lua:7`):**
> *"this scroll bar is using legacy code and shouldn't be used on creating new stuff"*

A bespoke vertical scrollbar built from a `Slider` frame plus two `Button` arrows, wired to scroll a parent frame's `VerticalScroll`. Predates the framework's modern scrollbox system. Documented here for the benefit of anyone maintaining existing call sites — for new code use `CreateScrollBar2` above, or `df_scrollbox` (`scrollbox.lua`) with `scrollBox:CreateScrollBar2()`.

There is no canonical consumer left in the framework's sibling files — this module exists for backward compatibility with addon code written years ago.

---

## Mental model

```
   parent  (consumer-supplied; this frame is what gets scrolled
   ┌─────────────────────────────┬──┐
   │                             │▲ │  ← upButton    (parent.cima)
   │                             ├──┤
   │  parent:SetVerticalScroll   │░ │  ← slider thumb
   │  is driven by slider value  │░ │     (parent.slider)
   │                             │░ │
   │                             ├──┤
   │                             │▼ │  ← downButton  (parent.baixo)
   └─────────────────────────────┴──┘
```

The scrollbar **attaches three sibling widgets to `parent`**: a vertical `Slider` plus an up arrow and a down arrow button. None of them are children of each other — they're all children of `parent`. The slider's `OnValueChanged` calls `parent:SetVerticalScroll(current)`, so `parent` is expected to be a `ScrollFrame` (or any frame that meaningfully responds to `SetVerticalScroll`).

**The split that matters most**: the scroll **range** is stored on the slider as `scrollMax` (initial `560`), and is **only recomputed when you call `slider:Update()`**. Until then the slider operates on its initial 0–560 range regardless of how tall your scroll content actually is.

### Portuguese terminology in the source

The framework was originally written in Brazilian Portuguese. Several methods and fields kept their Portuguese names:

| Source name | English |
|---|---|
| `ativo` | active (slider currently enabled) |
| `precionado` | pressed (button held) |
| `cima` / `cimaPoint` | up / up-button anchor |
| `baixo` / `baixoPoint` | down / down-button anchor |
| `Altura` | Height |
| `desativar` | disable (bool flag to `Update`) |
| `ultimo` | last (initial value cache on slider) |

These names appear on the returned slider and on `parent` — if you grep an addon's code for `parent.cima` or `slider:Altura()` you're looking at this module.

---

## Library access

```lua
local DF = _G["DetailsFramework"]
local slider = DF:CreateScrollBar(parent, scrollContainer, x, y)
-- or, identical:
local slider = DF:NewSplitBar(parent, scrollContainer, x, y)   -- alias
```

Both functions are byte-for-byte equivalent. `CreateScrollBar` tail-calls `NewScrollBar`.

---

## `DF:CreateScrollBar` / `DF:NewScrollBar` — signature

```lua
function detailsFramework:CreateScrollBar(master, scrollContainer, x, y)
    return detailsFramework:NewScrollBar(master, scrollContainer, x, y)
end

function detailsFramework:NewScrollBar(parent, scrollContainer, x, y)
```

> Note: `CreateScrollBar`'s first parameter is named `master` and `NewScrollBar`'s is named `parent`. They mean the same frame — the alias is a bare wrapper.

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` / `master` | `frame` | Yes | The scroll frame to drive. Must support `SetVerticalScroll` and `EnableMouseWheel`. The slider and both arrow buttons are parented to this frame. |
| 2 | `scrollContainer` | `frame` | Yes | The (taller) inner content frame whose height is used to compute scroll range via `scrollContainer:GetHeight() - parent:GetHeight()`. Only read by `slider:Update()`. |
| 3 | `x` | `number` | Yes | X offset for the slider's anchor (relative to `parent`'s `TOPRIGHT`). |
| 4 | `y` | `number` | Yes | Y offset for the slider. |

**Returns:** the slider frame — a `Slider` with `BackdropTemplate`, vertical orientation, the standard Blizzard scroll knob thumb, and the four methods `Altura`, `Update`, `cimaPoint`, `baixoPoint`.

### Fields written on the slider

| Field | Type | Description |
|---|---|---|
| `scrollMax` | `number` | Range upper bound. Initial `560`; recomputed by `Update`. |
| `ativo` | `boolean` | Whether the slider is currently enabled and accepting scroll input. Toggled by `Update`. |
| `ultimo` | `number` | Initial value cache. Set to `0` at construction and never updated by the framework — present for legacy consumers that wrote to it. |
| `bg` | `Texture` | BACKGROUND texture covering the slider area (transparent — `SetTexture(0, 0, 0, 0)`). |
| `thumb` | `Texture` | Knob texture (`Interface\Buttons\UI-ScrollBar-Knob`, 29×30). |

### Fields written on `parent`

| Field | Type | Description |
|---|---|---|
| `slider` | `Slider` | The created scrollbar. |
| `cima` | `Button` | Up arrow. |
| `baixo` | `Button` | Down arrow. |
| `wheel_jump` | `number?` | Optional, written by the consumer. Step size for each mouse-wheel tick. Defaults to `20` when nil. **This is the only externally tunable knob in the whole module.** |

---

## Step sizes (hard-coded)

| Action | Step | Repeat rate |
|---|---|---|
| Arrow click (initial) | `±5` | one-shot |
| Arrow hold (continuous) | `±2` per tick | every `0.03` seconds while held (after a `-0.3` second initial delay) |
| Mouse wheel tick | `± (parent.wheel_jump or 20)` | per wheel event |

The initial `last_up = -0.3` delays the auto-repeat start by 0.33 seconds (`0.3 + 0.03`) — pressing and releasing inside that window results in a single click step of 5, no repeats.

---

## Slider methods

### `slider:Altura(height)`

Renames `SetHeight`. Equivalent to `slider:SetHeight(height)`.

### `slider:Update(desativar)`

Idempotent. Recomputes `scrollMax` and toggles slider availability based on whether the content overflows the viewport.

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `desativar` | `boolean?` | No | If truthy, force-disable: set value to 0, mark inactive, disable mouse wheel on parent, return. |

When `desativar` is falsy:

1. `scrollMax = scrollContainer:GetHeight() - parent:GetHeight()`.
2. If `scrollMax > 0` (content overflows): `SetMinMaxValues(0, scrollMax)`, enable slider if not already, enable mouse wheel on parent.
3. Otherwise (content fits): disable slider, snap to 0, disable mouse wheel.

You must call `Update()` after any content height change. It is not automatic.

### `slider:cimaPoint(x, y)`

Re-anchors the up button: `upButton:SetPoint("BOTTOM", slider, "TOP", x, y - 12)`. The `-12` is baked into the formula — passing `y = 0` results in a -12 vertical offset.

### `slider:baixoPoint(x, y)`

Re-anchors the down button: `downButton:SetPoint("TOP", slider, "BOTTOM", x, y + 12)`. Symmetric `+12`.

---

## Scripts wired by construction

| Frame | Script | Behaviour |
|---|---|---|
| upButton | `OnMouseDown` | Step `-5`, then auto-repeat `-2` every 30 ms after a 330 ms delay. |
| upButton | `OnMouseUp` | Cancels `OnUpdate`. |
| upButton | `OnEnable` | If slider value is 0, immediately re-disables itself. |
| downButton | `OnMouseDown` | Symmetric to upButton, but `+5` and `+2`. |
| downButton | `OnMouseUp` | Cancels `OnUpdate`. |
| slider | `OnValueChanged` | `parent:SetVerticalScroll(value)`, plus auto-enable/disable the arrows when reaching the ends. |
| slider | `OnShow` | Shows both arrows. |
| slider | `OnDisable` | Disables both arrows. |
| slider | `OnEnable` | Enables both arrows (but `upButton.OnEnable` may immediately re-disable up). |
| parent | `OnMouseWheel` | Mouse-wheel scroll using `parent.wheel_jump or 20`. |

---

## Pitfalls

### The module is legacy — use `df_scrollbox` instead

This is repeated from the top because it's the single most important thing to know. New code should:

- Use `DF:CreateScrollBox` / `CreateCanvasScrollBox` for scrolling lists or free-form content (`scrollbox.lua`).
- Use the `reskin_slider` option on canvas scrollboxes to get the modern look on the built-in scrollbar.
- Avoid the Portuguese-named API surface entirely.

Reading or maintaining old code that calls `CreateScrollBar`? Continue. Writing new code? Stop and use the modern alternative.

### Mouse-wheel scroll-up branch is buggy

```lua
elseif (delta > 0) then
    if (current + (parent.wheel_jump or 20) > 0) then       -- <- WRONG SIDE
        newSlider:SetValue(current - (parent.wheel_jump or 20))
    else
        newSlider:SetValue(0)
    end
end
```

The guard adds `wheel_jump` instead of subtracting it before comparing to 0. The intent is "don't subtract past 0"; the actual check is "is `current + wheel_jump` greater than zero", which is almost always true. The effect is that scrolling up tries to set `current - wheel_jump` even when that goes negative; the slider then clamps to 0 (because of `SetMinMaxValues`). It works visually but doesn't behave the way the code reads.

**Fix (if you're maintaining)**: change the guard to `if (current - (parent.wheel_jump or 20) > 0)`. Symmetric with the down branch. Not worth fixing in production unless you've observed a real symptom; the auto-clamp covers it.

### `upButton:OnEnable` fights `slider:OnEnable`

When the slider is re-enabled (via `slider:Update()` after content grows), it fires `OnEnable` → enables both arrows. But if `slider:GetValue()` is `0` at that moment (typical right after Update enables), `upButton`'s own `OnEnable` script immediately re-disables itself. Net effect: after `Update`, the up button is correctly disabled at the top. Symptom: none normally, but if you hook `OnEnable` on either arrow, expect it to fire and revert.

### `parent.cima` / `parent.baixo` / `parent.slider` are written without nil-check

If you call `CreateScrollBar` on the same `parent` twice, the second call overwrites the first scrollbar's references on the parent. The first scrollbar still exists as a frame, but you've lost the handle and the new scripts on `parent` (`OnMouseWheel`) only drive the second slider.

**Fix**: don't attach two scrollbars to the same parent. Use distinct scroll frames.

### `parent.wheel_jump` is the only customisation point

There are no options table, no template parameter, no custom textures — all step sizes, the thumb texture, the arrow textures, the slider width (16), the arrow size (29×32), and the gap between slider and arrows (12 px) are hard-coded. Set `parent.wheel_jump = 30` before scrolling to change the wheel step; everything else requires post-construction mutation:

```lua
local slider = DF:CreateScrollBar(scrollFrame, contentFrame, 0, -20)
scrollFrame.wheel_jump = 50          -- only documented tuning knob
slider:SetWidth(20)                   -- ad-hoc width change
slider.thumb:SetTexture(...)         -- ad-hoc thumb texture change
```

### `scrollMax` initial value `560` is meaningless

The slider's range is `0..560` until you call `slider:Update()`. If you call `slider:SetValue(300)` before `Update`, it sets value 300 on a 0..560 range and propagates to `parent:SetVerticalScroll(300)` — even if the actual content is only 100 px tall. Always call `Update()` after the content is sized.

### `slider:Update()` ignores horizontal scrolling entirely

This is a vertical-only scrollbar. There is no horizontal counterpart. The script attached to `OnMouseWheel` only handles vertical delta. If you need horizontal scrolling, use a different widget.

### Typo: `downDutton` (capital D mid-word)

The down button is named `downDutton` (a typo of `downButton`) throughout the file. Doesn't affect runtime — it's a local — but if you grep the source for `downButton`, you'll miss it.

### Static `BackdropTemplate` with no backdrop applied

Both the slider and the arrow buttons are created with `"BackdropTemplate"` but `SetBackdrop` is never called. The template inclusion is a no-op for visuals; it's likely a copy-paste artefact. Adding a backdrop later is possible, just not done by the constructor.

---

## Public method reference

| Method | Purpose |
|---|---|
| `DF:CreateScrollBar(parent, scrollContainer, x, y)` | Construct the scrollbar. Tail-calls `NewScrollBar`. |
| `DF:NewScrollBar(parent, scrollContainer, x, y)` | Same as above. |
| `slider:Altura(h)` | Alias for `SetHeight`. |
| `slider:Update(desativar)` | Recompute range from container height; optionally force-disable. |
| `slider:cimaPoint(x, y)` | Re-anchor the up button (offset includes a built-in -12 Y). |
| `slider:baixoPoint(x, y)` | Re-anchor the down button (offset includes a built-in +12 Y). |

---

## Usage Examples

### Maintaining an existing call site

```lua
local DF = _G["DetailsFramework"]

local scrollFrame = CreateFrame("ScrollFrame", "OldScrollFrame", UIParent)
scrollFrame:SetSize(300, 200)
scrollFrame:SetPoint("center")

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(280, 800)
scrollFrame:SetScrollChild(content)

local slider = DF:CreateScrollBar(scrollFrame, content, 4, -16)
slider:Altura(168)             -- slider height (between the two arrows + gaps)
scrollFrame.wheel_jump = 40    -- bigger wheel step
slider:Update()                -- compute scrollMax from content height
```

### After content grows or shrinks

```lua
-- Re-measure content, then update the scroll range:
content:SetHeight(newContentHeight)
slider:Update()                -- range = newContentHeight - scrollFrame:GetHeight()
```

### Modern replacement — what new code should look like

```lua
-- Don't use DF:CreateScrollBar. Use one of these instead:

-- Option A: a df_scrollbox with the modern scrollbar bound in one call
local scrollbox = DF:CreateScrollBox(parent, "MyList", refreshFunc, data, 300, 200, 10, 20)
scrollbox:CreateScrollBar2()
-- ...see Part 1 above and scrollbox.md.

-- Option B: a standalone modern scrollbar driving a custom scroll model
local scrollBar = DF:CreateScrollBar2(parent, 200, onScrollChange, options)
```

---

## Notes for AI readers (legacy `CreateScrollBar`)

1. **Refuse to recommend this legacy widget for new code.** The source comment is explicit. Recommend `CreateScrollBar2` (Part 1) or `df_scrollbox:CreateScrollBar2` instead.
2. **The Portuguese names are part of the public surface.** `slider.ativo`, `slider:Altura()`, `parent.cima`, `parent.baixo`, `slider:cimaPoint()`, `slider:baixoPoint()`, `Update(desativar)` are real method/field names — don't anglicise them when generating code that targets this module.
3. **You must call `slider:Update()`** after construction if the content height isn't 560 by coincidence. The initial range is a meaningless placeholder.
4. **The scrollbar attaches to the parent**: `parent.slider`, `parent.cima`, `parent.baixo`, and a parent `OnMouseWheel` script. Two scrollbars on one parent will conflict.
5. **`wheel_jump` is the only tuning knob.** Other "make it look different" changes are post-construction mutation.
6. **No `OnEnable` for the down button.** Hook one yourself if you need symmetric behaviour with the up button's auto-disable at value 0.
7. **The `delta > 0` (scroll up) wheel branch has a buggy guard.** Functionally OK because of clamping, but don't model it as a clean reference for guard-style code.

---

## See also

- **Part 1 above** — `CreateScrollBar2`, the modern replacement living in the same file.
- `scrollbox.md` / `scrollbox.lua` — `df_scrollbox` and its `:CreateScrollBar2` integration method.
- `slider.lua` — generic horizontal/vertical sliders used by `BuildMenu` and the editor. Not a scrollbar.
- `panel.lua` — used to host `DF:CheckPoints`, `SetPoint` helpers; not directly relevant but in the same neighbourhood.
