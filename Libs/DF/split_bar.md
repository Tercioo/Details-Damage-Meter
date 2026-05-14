# split_bar.lua — Two-Tone Split Status Bar

A horizontal status bar with two independently coloured halves — a "left" texture that grows from the left edge to the current value and a "right" texture that fills the remainder — plus a spark at the boundary, optional icons / text labels on either end, and a separately-coloured background. The widget is a plain-table wrapper around a `StatusBar` frame with metatable-driven property access in the same shape as `label.lua` and `button.lua`. There is no clean canonical consumer in the sibling DF files; treat it as a building block used by addons that want a "you / them" or "current / max" visual where both halves carry meaning.

`DF:CreateSplitBar` returns a wrapper Lua table, NOT a Blizzard frame. The underlying UIObject (the Blizzard `StatusBar` frame) is at `wrapper.widget` (or equivalently `wrapper.statusbar`) and is returned by `wrapper:GetUIObject()`. Method calls on the wrapper are fine — the metatable forwards them — but when the wrapper is passed AS AN ARGUMENT to a Blizzard API that expects a frame (SetPoint relative anchor, CreateFrame parent, GameTooltip:SetOwner target, secure-template ref, etc.), it MUST be unwrapped via `wrapper:GetUIObject()` first; the wrapper has no frame userdata for the C side to bind to.

---

## Mental model

```
 ┌─────────────────────────────────────────────────────────────┐
 │  [iconleft] lefttext            statusbar                   │  ← height (~14 px)
 │ ┌─────────────────────┬─────────────────────────────────┐   │
 │ │ texture (left fill) │ rightTexture (remainder)        │   │  ← both are
 │ │ colored via         │ colored via                     │   │     ARTWORK
 │ │ SetLeftColor()      │ SetRightColor()                 │   │     textures
 │ └─────────────────────┴─────────────────────────────────┘   │
 │                       ↑                              righttext [iconright]
 │                       spark (overlay)                       │
 │  (background texture sits below both halves on BACKGROUND)  │
 └─────────────────────────────────────────────────────────────┘
        value = 0..100  (left half width = value% of total)
```

**The split that matters most**: this is not a `StatusBar` with two children — it's a `StatusBar` whose status texture is `texture` (the left half), plus a separate `rightTexture` ARTWORK texture anchored to the right edge that visually represents the remainder. The boundary between them is computed from the status value; the spark snaps to that boundary. So:

- Setting the **value** changes the visible width of the left half.
- Setting the **left colour** writes vertex colours on `texture` (the status bar's status texture).
- Setting the **right colour** writes vertex colours on `rightTexture` (the standalone ARTWORK texture).
- Setting the **background colour** writes vertex colours on `background` (BACKGROUND layer, sized to the whole bar).

The split bar is one of the framework widgets that uses the **GlobalWidgetControlNames version-cohabitation pattern**: `_G[DF.GlobalWidgetControlNames["split_bar"]]` holds a single shared `SplitBarMetaFunctions` table. Loading a newer DF on top of an older one merges the newer functions into the existing table in place, so existing widget instances keep working.

---

## Library access

```lua
local DF = _G["DetailsFramework"] -- or LibStub("DetailsFramework-1.0")
local bar = DF:CreateSplitBar(parent, width, height, member, name)
-- or, full form:
local bar = DF:NewSplitBar(parent, container, name, member, width, height)
```

---

## Constructors

### `DF:CreateSplitBar` — convenience signature

```lua
function DF:CreateSplitBar(parent, width, height, member, name)
    return DF:NewSplitBar(parent, nil, name, member, width, height)
end
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | Yes | Parent frame. Errors if nil. If `parent.dframework` is true, the underlying `parent.widget` is used. |
| 2 | `width` | `number?` | No | Initial width. Defaults to `14` if nil (see "Default size is backwards" in Pitfalls). |
| 3 | `height` | `number?` | No | Initial height. Defaults to `200` if nil (see "Default size is backwards" in Pitfalls). |
| 4 | `member` | `string?` | No | If provided, stores the wrapper as `parent[member]`. |
| 5 | `name` | `string?` | No | Global name for the underlying `StatusBar`. `$parent` is substituted via `DF:GetParentName(parent)`. Auto-generated as `"DetailsFrameworkSplitbar" .. DF.SplitBarCounter` if nil; the counter increments. |

**Returns:** a `split_bar` wrapper (a plain Lua table with `SplitBarMetaFunctions` as metatable).

### `DF:NewSplitBar` — full signature

```lua
function DF:NewSplitBar(parent, container, name, member, w, h)
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | Yes | Parent frame. Errors if nil. |
| 2 | `container` | `frame?` | No | Defaults to `parent`. Stored on `SplitBarObject.container` and used by the drag handlers (`OnMouseDown` / `OnMouseUp` call `container:StartMoving` / `StopMovingOrSizing`). |
| 3 | `name` | `string?` | No | See above. |
| 4 | `member` | `string?` | No | See above. |
| 5 | `w` | `number?` | No | Initial width. |
| 6 | `h` | `number?` | No | Initial height. |

**Returns:** `SplitBarObject` — `{ type = "barsplit", dframework = true, ... }` with the statusbar wired up, textures/fontstrings/icons created, hook list initialised, scripts attached, and metatable set.

### Built sub-widgets

After construction, the wrapper carries:

| Field | Type | Description |
|---|---|---|
| `statusbar` | `StatusBar` | The underlying status bar. Also aliased as `widget`. |
| `widget` | `StatusBar` | Same as `statusbar`. |
| `background` | `Texture` | BACKGROUND layer texture covering the whole bar. Initial colour `(.3, .3, .3, 1)`, initial texture is `Interface\PaperDollInfoFrame\UI-Character-Skills-Bar`. |
| `texture` | `Texture` | ARTWORK sub-layer 1. Used as the status bar's status texture (set via `SetStatusBarTexture`). Initial `original_colors = {1, 1, 1, 1}`. |
| `rightTexture` | `Texture` | ARTWORK sub-layer 2. Sized as `barWidth - texture:GetWidth()` and anchored to the right edge. Initial `original_colors = {.5, .5, .5, 1}`, initial vertex colour `(1, 0, 0)`. |
| `lefticon` | `Texture` | OVERLAY texture, 14×14, anchored to the bar's LEFT. |
| `righticon` | `Texture` | OVERLAY texture, 14×14, anchored to the bar's RIGHT. |
| `iconleft` | `Texture` | Alias resolved via `_G[name .. "_IconLeft"]`. Same widget as `lefticon`. |
| `iconright` | `Texture` | Alias resolved via `_G[name .. "_IconRight"]`. Same widget as `righticon`. |
| `spark` | `Texture` | OVERLAY texture, 32×32, `Interface\CastingBar\UI-CastingBar-Spark`, ADD blend. Positioned at the value boundary; the resting X offset is `value * width/100 - 18`. |
| `lefttext` | `FontString` | OVERLAY `GameFontHighlight`, size 10, anchored to `lefticon`'s RIGHT. |
| `righttext` | `FontString` | OVERLAY `GameFontHighlight`, size 10, anchored to `righticon`'s LEFT. |
| `textleft` | `FontString` | Alias resolved via `_G[name .. "_TextLeft"]`. Same widget as `lefttext`. |
| `textright` | `FontString` | Alias resolved via `_G[name .. "_TextRight"]`. Same widget as `righttext`. |
| `container` | `frame` | The frame the drag scripts call `StartMoving` on. Defaults to `parent`. |
| `currentValue` | `number` | Animation state. Initialised to `0.5`. Used by `SetValueWithAnimation`. |
| `locked` | `boolean` | Initialised to `false`. Not read inside the file — used by consumers to gate something externally. |
| `HookList` | `table` | Script-hook registry. Keys: `OnEnter`, `OnLeave`, `OnHide`, `OnShow`, `OnMouseDown`, `OnMouseUp`, `OnSizeChanged`. |

### Minimal example

```lua
local bar = DF:CreateSplitBar(UIParent, 300, 14, "myBar", "MyAddonSplitBar")
bar:SetPoint("center", UIParent, "center", 0, 0)
bar:SetSplit(60)              -- left half = 60%, right half = 40%
bar:SetLeftColor(0.2, 0.8, 0.2, 1)
bar:SetRightColor(0.8, 0.2, 0.2, 1)
bar:SetLeftText("Friendly")
bar:SetRightText("Enemy")
```

---

## Property system — `__index` / `__newindex` member dispatch

`SplitBarMetaFunctions` defines `GetMembers` (read) and `SetMembers` (write) tables. Reading `bar.foo` dispatches via `__index`:

```lua
__index = function(t, key)
    local getter = GetMembers[key]
    if getter then return getter(t, key) end
    return rawget(t, key) or SplitBarMetaFunctions[key]
end
```

Writing `bar.foo = value` dispatches via `__newindex`:

```lua
__newindex = function(t, key, value)
    local setter = SetMembers[key]
    if setter then return setter(t, value) end
    return rawset(t, key, value)
end
```

### Readable properties (`GetMembers`)

| Property | Aliases | Returns | Source |
|---|---|---|---|
| `tooltip` | — | `any` | `self:GetTooltip()` (the `have_tooltip` raw field). |
| `shown` | — | `boolean` | `self.statusbar:IsShown()`. |
| `width` | — | `number` | `self.statusbar:GetWidth()`. |
| `height` | — | `number` | `self.statusbar:GetHeight()`. |
| `value` | — | `number` | `self.statusbar:GetValue()`. |
| `righttext` | — | `string` | `self.textright:GetText()`. |
| `lefttext` | — | `string` | `self.textleft:GetText()`. |
| `rightcolor` | — | `{r,g,b,a}` | `self.rightTexture.original_colors`. |
| `leftcolor` | — | `{r,g,b,a}` | `self.texture.original_colors`. |
| `righticon` | — | `texture path` | `self.iconright:GetTexture()`. |
| `lefticon` | — | `texture path` | `self.iconleft:GetTexture()`. |
| `texture` | — | `texture path` | `self.texture:GetTexture()`. |
| `fontsize` | `textsize` | `number` | second return of `textleft:GetFont()`. |
| `fontface` | `textfont` | `string` | first return of `textleft:GetFont()`. |
| `fontcolor` | `textcolor` | `r, g, b, a` | `textleft:GetTextColor()`. |

### Writable properties (`SetMembers`)

| Property | Aliases | Accepts | Effect |
|---|---|---|---|
| `tooltip` | — | `string?` | `rawset(self, "have_tooltip", value)` via `SetTooltip`. |
| `shown` | — | `boolean` | True → `self:Show()`, false → `self:Hide()`. |
| `width` | — | `number` | `statusbar:SetWidth(value)`. |
| `height` | — | `number` | `statusbar:SetHeight(value)`. |
| `value` | — | `number` | Sets bar value AND repositions the spark to `value * width/100 - 18`. |
| `righttext` | — | `string` | `textright:SetText(value)`. |
| `lefttext` | — | `string` | `textleft:SetText(value)`. |
| `rightcolor` | — | colour | `ParseColors` then `rightTexture:SetVertexColor`. Mirrors into `rightTexture.original_colors`. |
| `leftcolor` | — | colour | `ParseColors` then `statusbar:SetStatusBarColor` AND `texture:SetVertexColor`. Mirrors into `texture.original_colors`. |
| `righticon` | — | `texture` or `{texture, {l,r,u,d}}` | Sets texture; if a table is passed, also applies tex coords. |
| `lefticon` | — | `texture` or `{texture, {l,r,u,d}}` | Same. |
| `texture` | — | `texture` or `{texture, {l,r,u,d}}` | Applies to BOTH `texture` and `rightTexture`. |
| `fontsize` | `textsize` | `number` | `DF:SetFontSize` on both `textleft` and `textright`. |
| `fontface` | `textfont` | `string` | `DF:SetFontFace` on both `textleft` and `textright`. |
| `fontcolor` | `textcolor` | colour | `ParseColors` then `SetTextColor` on both. |

There is also a file-local `smember_hide` defined but **never registered** in `SetMembers`. Trying `bar.hide = true` does not hide the bar — it falls through `rawset` and creates a raw field. Use `bar.shown = false` or `bar:Hide()` instead.

---

## Operators

| Operator | Form | Effect |
|---|---|---|
| `__call` | `bar()` or `bar(value)` | No arg returns `statusbar:GetValue()`. With arg, repositions the spark and sets the bar value. |
| `__add` | `bar + n` or `n + bar` | Adds `n` to the current value, repositions the spark, sets the new value. Returns nothing. |
| `__sub` | `bar - n` or `n - bar` | Subtracts. Same shape as `__add` but read carefully — `n - bar` computes `current - n`, not `n - current`. |

```lua
bar(75)        -- set value to 75
local v = bar()  -- get value
bar = bar + 5  -- value += 5
bar = bar - 3  -- value -= 3 (regardless of operand order; see Pitfalls)
```

None of these clamp. None validate `0..100` range. Use `SetSplit` if you want range enforcement.

---

## Methods

### Sizing and positioning

```lua
bar:SetPoint(anchorOrPoint, ...)   -- runs DF:CheckPoints to normalise args, then statusbar:SetPoint
bar:SetSize(w, h)                  -- each dim optional; only applies the ones you pass
bar:GetFrameLevel()                -- statusbar:GetFrameLevel()
bar:SetFrameLevel(level, frame?)   -- if frame, sets to frame:GetFrameLevel() + level
bar:SetFrameStrata(strata)         -- strata may be a string or a frame; if a frame, inherits its strata
```

`SetPoint` prints `"Invalid parameter for SetPoint"` and returns silently if `DF:CheckPoints` rejects the input. No error, no return value.

### Value

```lua
bar:SetSplit(value)   -- value in [0, 100]. Out of range → silently does nothing. nil → re-reads current.
```

`SetSplit` is the safe entry point. The `value` member setter and the `__call` operator do the same thing without range validation.

### Text

```lua
bar:SetLeftText(text)
bar:SetRightText(text)
```

### Colour

```lua
bar:SetLeftColor(r, g, b, a)    -- ParseColors, then texture:SetVertexColor, mirrors into texture.original_colors
bar:SetRightColor(r, g, b, a)   -- same on rightTexture
bar:SetBackgroundColor(r, g, b, a)
bar:GetLeftColor()              -- texture:GetVertexColor()
bar:GetRightColor()              -- rightTexture:GetVertexColor()
```

`ParseColors` accepts named strings (`"red"`), tables (`{r,g,b,a}`), or four scalars — see `colors.lua`. The methods mirror the post-parse RGBA into `original_colors` so consumers can read the *applied* colour back later. Note that `SetLeftColor` only updates `texture`, not the status bar's stored colour — unlike the `leftcolor` member setter, which also calls `statusbar:SetStatusBarColor`. The discrepancy is documented further in Pitfalls.

### Icons

```lua
bar:SetLeftIcon(texture)
bar:SetLeftIcon(texture, {L, R, U, D})    -- with tex coords as a varargs table
bar:SetRightIcon(texture)
bar:SetRightIcon(texture, {L, R, U, D})
```

### Texture

```lua
bar:SetTexture(texture)           -- applies to BOTH halves
bar:SetBackgroundTexture(texture) -- applies to the background only
```

### Tooltip

```lua
bar:SetTooltip("Hello")   -- shown via GameCooltip2 on hover; nil clears
bar:GetTooltip()
```

The tooltip is shown by the built-in `OnEnter` script (via `GameCooltip2:ShowCooltip(frame, "tooltip")`). See "Hover hide-path is asymmetric" in Pitfalls.

### Visibility

```lua
bar:Show()
bar:Hide()
```

Both forward to `statusbar:Show` / `Hide`. The wrapper is a plain Lua table and has no visibility of its own — you can't "hide the wrapper while leaving the statusbar visible".

---

## Animation — `SetValueWithAnimation`

The bar has an optional eased animation from `currentValue` to a `targetValue`, written for a "health bar" feel. The animation lives in an `OnUpdate` script that the wrapper hot-attaches.

```lua
bar:SetValueWithAnimation(value)   -- starts the animation toward `value`
bar:DisableAnimations()            -- clears OnUpdate immediately
bar:EnableAnimations()             -- NO-OP; see Pitfalls
```

When started, `SetValueWithAnimation` also:

- Calls `statusbar:SetMinMaxValues(0, 1)` — switching the value scale **from 0–100 to 0–1** for the duration of animations. This is a permanent side effect; the bar stays on the 0–1 scale until you reset it.
- Clears the spark's anchors and resizes it to `self:GetHeight() * 2.6`, alpha 0.4.

Each tick chooses between `animateLeftWithAccel` (target below current) and `animateRightWithAccel` (target above current). Both:

1. Compute progress as `DF:GetRangePercent(start, target, current)` → clamp to `[0.5, 0.9]`.
2. Scale by `sin(p * π)` to get an animation multiplier — fast start, slow end.
3. Move `currentValue` by `step * dt * multiplier` toward `targetValue`.
4. Clamp to `[0, maxStatusBarValue]` where `maxStatusBarValue = 100000000`.
5. Set the bar value and resize `rightTexture` to `barWidth - barWidth*currentValue`.
6. Move the spark.
7. When `|currentValue - targetValue| <= 0.001`, snap, hide the spark (unless `SparkAlwaysShow`), and clear `OnUpdate`.

The animation always sets the spark to *centred on* the boundary, while the static path positions it via `x = value * width/100 - 18` (left-edge with a -18 offset). The two systems do not agree on spark geometry — see Pitfalls.

---

## Script hooks

All scripts go through `RunHooksForWidget` (from `ScriptHookMixin`). Each handler invokes the consumer's hooks first; if a hook returns truthy ("kill"), the built-in behaviour is skipped.

| Script | Default behaviour |
|---|---|
| `OnEnter` | Shows `GameCooltip2` with `have_tooltip` text, anchored to the frame, mode `"tooltip"`. |
| `OnLeave` | Calls `DF.popup:ShowMe(false)` — note: not `GameCooltip2:Hide()`. See "Hover hide-path is asymmetric" below. |
| `OnHide` | Hook only. |
| `OnShow` | Hook only. |
| `OnMouseDown` | If `container` is not locked and movable, sets `container.isMoving = true` and calls `container:StartMoving()`. |
| `OnMouseUp` | If `container.isMoving`, calls `container:StopMovingOrSizing()` and clears the flag. |
| `OnSizeChanged` | Repositions the spark and resizes `rightTexture` to `barWidth - texture:GetWidth()`. |

To install a hook:

```lua
bar:HookScript("OnMouseDown", function(_, _, button, capsule)
    if button == "RightButton" then
        capsule:SetSplit(50)   -- snap to middle
    end
end)
```

`HookScript` is provided by `ScriptHookMixin` — see `mixins.lua`.

---

## Pitfalls

### Value scale flips after `SetValueWithAnimation`

The static path uses `SetMinMaxValues(1, 100)` (set inside `build_statusbar`); spark positioning uses `value * width/100`. `SetValueWithAnimation` re-runs `SetMinMaxValues(0, 1)`. Once you have animated the bar even once, all subsequent **static** writes (`bar:SetSplit(60)`, `bar(60)`, `bar.value = 60`) operate on a 0–1 scale internally — meaning `60` clamps to `1`, the spark math lands at `60 * width/100 - 18` which doesn't match the now-0-to-1 visual fill, and the right texture sizing breaks because `rightTexture:SetWidth(barWidth - barWidth*currentValue)` assumes `currentValue ∈ [0,1]` but `SetSplit` writes 0–100.

**Symptom**: after one animation, calling `bar:SetSplit(50)` paints the bar full and pins the spark to the right edge.

**Fix**: pick a mode and stay there. If you use animation, replace `SetSplit` calls with `SetValueWithAnimation` (target in `[0, 1]`). If you mix, restore the range after animations end:

```lua
function bar:ResetToStaticScale()
    self.widget:SetScript("OnUpdate", nil)
    self.statusbar:SetMinMaxValues(1, 100)
end
```

### Default size is height-tall, width-thin

`DF:NewSplitBar`'s defaults are `h or 200` and `w or 14` — a 14-wide, 200-tall vertical sliver. The widget visually is a horizontal bar (`build_statusbar` sets 300×14 first and the spark math assumes width >> height). If you call `DF:CreateSplitBar(parent)` with no size args, the bar arrives backwards.

**Fix**: always pass width and height explicitly. `DF:CreateSplitBar(parent, 300, 14, ...)`.

### `loadstring` fallback for StatusBar methods

`NewSplitBar` does a one-time scan of `getmetatable(statusbar).__index`. For each StatusBar method missing from `SplitBarMetaFunctions`, it generates a wrapper via `loadstring` that calls the named method on `_G[statusbar:GetName()]`.

**Mechanism**: this means any unhandled StatusBar API (e.g. `bar:SetReverseFill(true)`) tries to find the bar in `_G` by name. If you ever rename or unparent the statusbar so its global registration changes, those wrappers break. The scan happens **once per session** — guarded by `APISplitBarFunctions`. Late additions to `SplitBarMetaFunctions` after the first `NewSplitBar` call are missed by the wrapper layer (though they still resolve via `__index` if you call them directly).

**Fix**: don't rely on bar method dispatch outside the named set above. If you need a StatusBar method, call it on `bar.statusbar` directly.

```lua
bar.statusbar:SetReverseFill(true)   -- safe: bypasses the wrapper
```

### Globals named by `name`

Construction stores six widgets in `_G`: `<name>_TextLeft`, `<name>_TextRight`, `<name>_IconLeft`, `<name>_IconRight`, `<name>_StatusBarBackground`, `<name>_StatusBarTexture`, `<name>_StatusBarTextureRight`. The wrapper then re-fetches them by global lookup to populate its fields.

**Symptom**: creating two bars with the same explicit `name` makes the second bar's wrapper alias the first bar's sub-widgets. Editing one bar visually moves the other.

**Fix**: pass a unique name, or omit `name` to let `SplitBarCounter` generate one (`DetailsFrameworkSplitbar1`, `…2`, …).

### `__sub` does not respect operand order

```lua
bar - 5       -- value = current - 5
5 - bar       -- ALSO value = current - 5  (not 5 - current)
```

`__sub` always subtracts the scalar from the bar's current value, regardless of which operand is the bar. Symmetric with `__add` (which is commutative anyway, so it doesn't matter there). Don't lean on the natural-language reading of `5 - bar`.

### `SetLeftColor` method vs `leftcolor` member setter — not identical

```lua
bar:SetLeftColor(r, g, b, a)    -- writes texture:SetVertexColor only
bar.leftcolor = {r, g, b, a}     -- writes statusbar:SetStatusBarColor AND texture:SetVertexColor
```

The member setter is more thorough (it updates the status bar's stored colour, which Blizzard uses internally for some effects). The method writes only the texture vertex colour. They both update `texture.original_colors`. For most consumers the visual is identical; if you do anything that re-reads the bar's status colour (e.g. via `:GetStatusBarColor()`), prefer the member setter.

### `EnableAnimations` is a stub; animations enable themselves implicitly

```lua
function SplitBarMetaFunctions:EnableAnimations()
    return
end
```

Calling `EnableAnimations()` does nothing. Animations are enabled by `SetValueWithAnimation` (which installs `OnUpdate` if it isn't already). `DisableAnimations` does work — it clears `OnUpdate`. The asymmetry is a footgun: code that does `bar:DisableAnimations(); ...; bar:EnableAnimations()` silently leaves animations disabled.

**Fix**: call `bar:SetValueWithAnimation(targetValue)` directly when you want animation to resume; do not rely on `EnableAnimations` as a toggle.

### Hover hide-path is asymmetric

`OnEnter` shows the tooltip via `GameCooltip2:ShowCooltip(frame, "tooltip")`. `OnLeave` does **not** call `GameCooltip2:Hide()` — it calls `DF.popup:ShowMe(false)`, which is a different system (the framework's modal popup helper). The tooltip will fade only because GameCooltip2 has its own auto-hide on cursor-leave; if a future framework change tightens that, tooltips will start lingering.

**Fix (defensive)**: install a HookScript on `OnLeave` that explicitly hides GameCooltip2 if you care about predictable cleanup.

```lua
bar:HookScript("OnLeave", function() GameCooltip2:Hide() end)
```

### Drag uses `container`, not the bar

`OnMouseDown` calls `container:StartMoving()`. If you pass `parent ≠ container` and the container isn't movable, dragging silently does nothing. If the container is `UIParent` (the default when you pass nil for container and your parent IS UIParent), `IsMovable()` returns false and drags don't work either.

**Fix**: explicitly set up the drag target before expecting drag to function.

```lua
local frame = CreateFrame("frame", nil, UIParent)
frame:SetMovable(true)
local bar = DF:NewSplitBar(frame, frame, "MyBar", nil, 300, 14)
```

### `DetailsFrameworkSplitlBar_OnCreate` has a typo

The internal init function is named `DetailsFrameworkSplitlBar_OnCreate` (extra `l` between `Split` and `Bar`). It lives on `_G` and is called from `build_statusbar`. Don't grep for `DetailsFrameworkSplitBar_OnCreate` — you'll miss it. This name is load-bearing; renaming it without updating the call site at the bottom of `build_statusbar` will break construction.

### Spark resting position embeds a `-18` magic number

The spark's static X is `value * width/100 - 18`. The `-18` is a centre offset because the spark texture is 32 wide and sits "centred on the boundary" via a `LEFT` anchor with negative offset. There is no constant or option to change it — at small bar widths, this offset can push the spark off the visible bar.

**Fix**: if you need a custom spark offset, override `OnSizeChanged` and `smember_value` (the `value` setter), or call `bar.spark:SetPoint(...)` directly after every value write.

### `SetSplit` silently ignores out-of-range

```lua
bar:SetSplit(150)   -- no error, no warning, no change
bar:SetSplit(-1)    -- ditto
```

`SetSplit` returns early with no return value if `value < 0 or value > 100`. The bar stays at whatever it was. The `value` setter and `__call` do NOT validate — they happily apply 150 (which the underlying StatusBar clamps to its max, currently 100 unless animation has flipped the range).

### `gmember_textcolor` returns four scalars; `textcolor` setter accepts colour formats

```lua
local r, g, b, a = bar.textcolor   -- four-scalar unpacking
bar.textcolor = "red"               -- accepts string / table / four-arg via ParseColors
```

Reading via the member shorthand returns four values, which means assigning the read back into the setter as `bar.textcolor = bar.textcolor` only writes the first scalar (the others become extra args, dropped). Round-trip the value through a table if you want to copy a colour between bars:

```lua
bar2.textcolor = {bar1.textcolor}   -- correct round-trip
```

### `original_colors` is read by consumers but the framework doesn't read it back

Each colour setter mirrors `{r, g, b, a}` into `<widget>.original_colors`. The framework itself never reads this field — it's there for consumers who want to detect "what colour did I last set, regardless of any visual highlight overlay". If you mutate `bar.texture.original_colors` directly without also calling `SetVertexColor`, you've desynced the cached value from the rendered colour.

---

## Public method reference

| Method | Purpose |
|---|---|
| `Show()` / `Hide()` | Forward to `statusbar:Show / Hide`. |
| `SetSplit(value)` | Set the bar value with `[0, 100]` validation (out-of-range no-ops; nil reuses current). |
| `SetPoint(anchor, ...)` | Anchor the statusbar after running `DF:CheckPoints`. Prints on invalid args. |
| `SetSize(w, h)` | Resize statusbar; each dim independently optional. |
| `SetTexture(texture)` | Apply to both halves (`texture` and `rightTexture`). |
| `SetBackgroundTexture(texture)` | Apply to the background only. |
| `SetLeftText(text)` / `SetRightText(text)` | Set fontstring text on each side. |
| `SetLeftColor(r, g, b, a)` / `SetRightColor(...)` / `SetBackgroundColor(...)` | Colour the corresponding texture via `ParseColors`. Mirrors into `original_colors`. |
| `GetLeftColor()` / `GetRightColor()` | Returns current vertex colour (r, g, b, a). |
| `SetLeftIcon(texture, ...)` / `SetRightIcon(...)` | Set icon texture and optional `{L, R, U, D}` tex coords. |
| `SetTooltip(text)` / `GetTooltip()` | Set / read the `have_tooltip` field. |
| `GetFrameLevel()` | `statusbar:GetFrameLevel()`. |
| `SetFrameLevel(level, frame?)` | Direct or relative-to-another-frame level. |
| `SetFrameStrata(strata)` | String or another frame (inherits its strata). |
| `EnableAnimations()` | No-op stub. See Pitfalls. |
| `DisableAnimations()` | Clears `OnUpdate`. |
| `SetValueWithAnimation(value)` | Eased animation to `value`. Flips bar to 0–1 scale (see Pitfalls). |

---

## Usage Examples

### Basic — static you-vs-them bar

```lua
local DF = _G["DetailsFramework"]

local bar = DF:CreateSplitBar(UIParent, 300, 14, "duelBar", "DuelSplitBar")
bar:SetPoint("center", UIParent, "center", 0, 0)
bar:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
bar:SetLeftColor(0.2, 0.8, 0.2, 1)
bar:SetRightColor(0.8, 0.2, 0.2, 1)
bar:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)
bar:SetLeftText("You: 60%")
bar:SetRightText("Foe: 40%")
bar:SetSplit(60)
```

### Richer — property syntax, tooltip, drag

```lua
local DF = _G["DetailsFramework"]

-- A movable container the bar drags
local frame = CreateFrame("frame", "MyDuelFrame", UIParent)
frame:SetSize(310, 24)
frame:SetPoint("center")
frame:SetMovable(true)

local bar = DF:NewSplitBar(frame, frame, "DuelBar", nil, 300, 14)
bar:SetPoint("center", frame, "center", 0, 0)

-- property-style access
bar.texture     = [[Interface\TargetingFrame\UI-StatusBar]]
bar.leftcolor   = {0.2, 0.8, 0.2, 1}    -- also updates statusbar status colour
bar.rightcolor  = "red"
bar.textsize    = 11
bar.textcolor   = "white"
bar.tooltip     = "Right-click to reset"

bar:SetSplit(75)

-- script hook: right-click resets to 50/50, kills default drag
bar:HookScript("OnMouseDown", function(_, _, button, capsule)
    if button == "RightButton" then
        capsule:SetSplit(50)
        return true   -- "kill" — prevents default drag handling
    end
end)
```

### Animation — eased transition

```lua
-- One animation: 30 → 80 with the built-in sine easing
bar:SetSplit(30)
C_Timer.After(1, function()
    bar:SetValueWithAnimation(0.80)   -- NOTE: 0..1 scale, not 0..100
end)

-- After animations, restore 0..100 scale if you also use SetSplit elsewhere
local function restoreStaticScale(b)
    b.widget:SetScript("OnUpdate", nil)
    b.statusbar:SetMinMaxValues(1, 100)
end
```

### Refreshing colour from a profile

```lua
local function applyProfile(bar, profile)
    bar.leftcolor      = profile.your_color
    bar.rightcolor     = profile.their_color
    bar.texture        = profile.bar_texture
    bar:SetSplit(profile.last_value or 50)
end

applyProfile(bar, MyAddonDB.profile)
```

---

## Notes for AI readers

1. **The value scale is 0–100 for static use, 0–1 after `SetValueWithAnimation`.** Don't recommend mixing `SetSplit` and `SetValueWithAnimation` without explicitly restoring `SetMinMaxValues(1, 100)` between them.
2. **`EnableAnimations` is a stub.** Generated code that toggles animations with the symmetric pair will leak: only `SetValueWithAnimation` re-arms the OnUpdate.
3. **Constructor defaults give a vertical sliver.** Always pass explicit width and height when wrapping `DF:CreateSplitBar`.
4. **Names create globals.** Two bars with the same explicit name share sub-widgets via `_G[name .. "_..."]` lookups. Recommend leaving `name` nil to let the counter generate one, or pass uniquely-derived names.
5. **`original_colors` is a consumer-readable mirror only.** Mutating it without also calling `SetVertexColor` desyncs visual from cache.
6. **Colour setters accept any `ParseColors` input** — named strings, `{r, g, b, a}` tables, or four scalars. Reading via `bar.fontcolor` returns four scalars (not a table); use `{bar.fontcolor}` for round-trip.
7. **Drag wires onto `container`, not the bar.** If `container` is non-movable (typical for `UIParent`), dragging silently does nothing.
8. **The `loadstring` fallback layer** for StatusBar methods only runs once per session. New additions to `SplitBarMetaFunctions` after the first `NewSplitBar` won't get wrappers. Call `bar.statusbar:Method(...)` directly for methods outside the documented set.
9. **`SetSplit` silently ignores out-of-range; `__call` does not.** Recommend `SetSplit` for any consumer code that takes user input.
10. **Hooks fire BEFORE built-in behaviour and can suppress it.** Hook returning truthy skips the default — useful for overriding drag, tooltip, etc. See `ScriptHookMixin` in `mixins.lua`.

---

## See also

- `label.lua` / `label.md` — closest sibling using the same metatable-property-access shape. The split bar's `GetMembers` / `SetMembers` pattern is identical.
- `mixins.lua` — `ScriptHookMixin` (mixed in at the top of the file); `HookScript` / `RunHooksForWidget` live there.
- `colors.lua` — `DF:ParseColors` (called by every colour setter on this widget).
- `normal_bar.lua` — the single-texture status bar; choose this when you don't need the split / right-half visualisation.
- `timebar.lua` — countdown status bar; another sibling in the bar family.
- `panel.lua` — `DF:CheckPoints` (used by `SetPoint`) and `DF:GetParentName` (used for `$parent` substitution in `name`).
