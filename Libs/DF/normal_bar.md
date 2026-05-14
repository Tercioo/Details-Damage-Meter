# normal_bar.lua — Single-Texture Status Bar with Built-in Timer

A horizontal `StatusBar` wrapper with one fill texture, two text labels, an icon, a hover spark, and a built-in **countdown timer** that animates the bar from start to end and fires an `OnTimerEnd` hook. The widget is a plain-table wrapper around a `StatusBar` frame with metatable-driven property access, in the same shape as `label.lua` and `split_bar.lua`. The natural consumer is anything that wants "a bar that fills, with a tooltip, that can also be used as a cooldown" — e.g. ability timers, scroll list entries with durations, the Details! per-line bars. There is no canonical consumer in the sibling DF files; this is a general-purpose primitive.

`DF:CreateBar` returns a wrapper Lua table, NOT a Blizzard frame. The underlying UIObject (the Blizzard `StatusBar` frame) is at `wrapper.widget` (or equivalently `wrapper.statusbar`) and is returned by `wrapper:GetUIObject()`. Method calls on the wrapper are fine — the metatable forwards them — but when the wrapper is passed AS AN ARGUMENT to a Blizzard API that expects a frame (SetPoint relative anchor, CreateFrame parent, GameTooltip:SetOwner target, secure-template ref, etc.), it MUST be unwrapped via `wrapper:GetUIObject()` first; the wrapper is a plain Lua table with no frame userdata for the C side to bind to.

---

## Mental model

```
 ┌─────────────────────────────────────────────────────────────────┐
 │ [icon]  lefttext                                    righttext   │  ← height (~14 px)
 │┌────────────────────────────────────────────────────────────────┐│
 ││ _texture (status fill — grows with statusbar:SetValue 0..100)  ││
 │├──────timer_texture (left-anchored)──────●                      ││
 ││           or  timer_textureR (right-anchored, LeftToRight=true)││
 │└────────────────────────────────────────────────────────────────┘│
 │ background (hidden, shown on OnEnter — hover highlight)          │
 └─────────────────────────────────────────────────────────────────┘
                       ↑                              ↑
                       div (spark, mouseover)      div_timer (spark, while timer runs)
```

**The split that matters most**: the **status value** drives `_texture` via the standard `StatusBar:SetValue` mechanism, on a hard-coded `0..100` scale. The **timer** is independent — it uses one of two extra textures (`timer_texture` or `timer_textureR`) whose width is animated each frame by an `OnUpdate` script. The status value and the timer don't talk to each other; you can run both simultaneously, but they paint different parts of the bar.

There are two timer animation modes:

| `BarIsInverse` | `LeftToRight` | Behaviour |
|---|---|---|
| false | false (default) | `timer_texture` (left-anchored) shrinks toward 0 width as time progresses. |
| true | false | `timer_texture` (left-anchored) grows from 0 to full width. |
| false | true | `timer_textureR` (right-anchored) shrinks toward 0 width. |
| true | true | `timer_textureR` (right-anchored) grows from 0 to full width. |

`LeftToRight` flips which texture is active (and consequently which spark is anchored). `BarIsInverse` flips the fill direction. Both are flags set by the consumer on the wrapper before calling `SetTimer`.

Like other DF widgets, the bar uses the **GlobalWidgetControlNames version-cohabitation pattern**: `_G[DF.GlobalWidgetControlNames["normal_bar"]]` holds the shared `BarMetaFunctions` table, merged in place when a newer DF loads over an older one.

---

## Library access

```lua
local DF = _G["DetailsFramework"]
local bar = DF:CreateBar(parent, texture, w, h, value, member, name)
-- or, full form:
local bar = DF:NewBar(parent, container, name, member, w, h, value, texture)
```

---

## Constructors

### `DF:CreateBar` — convenience signature

```lua
function DF:CreateBar(parent, texture, w, h, value, member, name)
    return DF:NewBar(parent, parent, name, member, w, h, value, texture)
end
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | Yes | Parent frame. Errors if nil. |
| 2 | `texture` | `string?` | No | Status texture path or LibSharedMedia name. Resolved via `SharedMedia:Fetch("statusbar", ...)` if it has no path separator. |
| 3 | `w` | `number?` | No | Width. Defaults to `150`. |
| 4 | `h` | `number?` | No | Height. Defaults to `14`. |
| 5 | `value` | `number?` | No | Initial bar value (0–100). Defaults to `0` (sub-default `50` if `value` is omitted entirely; see source). |
| 6 | `member` | `string?` | No | If set, stores the wrapper as `parent[member]`. |
| 7 | `name` | `string?` | No | Global name for the underlying `StatusBar`. Auto-generated as `"DetailsFrameworkBarNumber" .. DF.BarNameCounter` if nil. `$parent` is substituted via `DF:GetParentName(parent)`. |

### `DF:NewBar` — full signature

```lua
function DF:NewBar(parent, container, name, member, w, h, value, texture_name)
```

Same as `CreateBar` but with explicit `container` (used by the drag handlers via `StartMoving / StopMovingOrSizing`). `container` defaults to `parent` when nil.

**Returns:** `BarObject` — `{ type = "bar", dframework = true, ... }` with the statusbar wired up, textures/fontstrings/icon created, hook list initialised, scripts attached, and metatable set.

### Built sub-widgets

| Field | Type | Description |
|---|---|---|
| `statusbar` | `StatusBar` | The underlying status bar (min/max `0, 100`). Also aliased as `widget`. |
| `widget` | `StatusBar` | Same as `statusbar`. |
| `_texture` | `Texture` | The fill texture. Used as the status texture (`SetStatusBarTexture`). Initial `original_colors = {1, 1, 1, 1}`. |
| `background` | `Texture` | BACKGROUND layer texture across the whole bar. Hidden by default; auto-shown on mouseover (`OnEnter`). Initial colour `(.3, .3, .3, .3)`. |
| `timer_texture` | `Texture` | Left-anchored ARTWORK texture used for the timer fill when `LeftToRight = false`. Hidden when no timer is active. |
| `timer_textureR` | `Texture` | Right-anchored ARTWORK texture used when `LeftToRight = true`. Hidden otherwise. |
| `_icon` | `Texture` | OVERLAY 14×14 texture anchored to the bar's LEFT. |
| `div` | `Texture` | The mouseover spark (32×32, ADD blend, `Interface\CastingBar\UI-CastingBar-Spark`). Positioned at `value * width/100 - 16`. |
| `div_timer` | `Texture` | The timer spark. Repositioned by `SetTimer` to the leading edge of the active timer texture. |
| `textleft` | `FontString` | OVERLAY `GameFontHighlight`, size 10, anchored to `_icon`'s RIGHT. |
| `textright` | `FontString` | OVERLAY `GameFontHighlight`, size 10, anchored to bar's RIGHT (-3 px inset). |
| `container` | `frame` | The frame the drag scripts call `StartMoving` on. Defaults to `parent`. |
| `locked` | `boolean` | Initialised to `false`. Not consumed by the framework — present for consumers to use. |
| `HookList` | `table` | Script-hook registry: `OnEnter`, `OnLeave`, `OnHide`, `OnShow`, `OnMouseDown`, `OnMouseUp`, `OnTimerEnd`. |
| `HasTimer` | `boolean?` | True while a timer is running. Cleared by `OnTimerEnd`. |
| `timer` | `boolean?` | Also "true while a timer is running" — see Pitfalls; redundant with `HasTimer`. |
| `TimerScheduled` | `cbHandle?` | Reserved for a scheduled callback; not currently populated by the framework. Used by `CancelTimerBar` as a cancellation handle. |
| `LeftToRight` | `boolean?` | Consumer-set flag. Controls which timer texture is used. |
| `BarIsInverse` | `boolean?` | Consumer-set flag. Inverts timer fill direction. |
| `RightTextIsTimer` | `boolean?` | If true, the timer's `OnUpdate` formats `remaining` via `DF:IntegerToTimer` (e.g. `"1:23"`) into `righttext`. Otherwise floors to whole seconds. |

### Minimal example

```lua
local bar = DF:CreateBar(UIParent, "Blizzard", 200, 18, 50, "myBar", "MyAddonBar")
bar:SetPoint("center")
bar:SetColor(0.2, 0.8, 0.2, 1)
bar:SetLeftText("HP")
bar:SetRightText("50/100")
```

---

## Property system — `__index` / `__newindex` member dispatch

`BarMetaFunctions` defines `GetMembers` (read) and `SetMembers` (write) tables. Reading `bar.foo` and writing `bar.foo = value` dispatch through them. The pattern is identical to `label.lua` and `split_bar.lua` — see `label.md` for the metatable mechanics overview.

### Readable properties (`GetMembers`)

| Property | Aliases | Returns | Source |
|---|---|---|---|
| `tooltip` | — | `any` | `self:GetTooltip()` (the `have_tooltip` raw field). |
| `shown` | — | `boolean` | `self.statusbar:IsShown()`. |
| `width` | — | `number` | `self.statusbar:GetWidth()`. |
| `height` | — | `number` | `self.statusbar:GetHeight()`. |
| `value` | — | `number` | `self.statusbar:GetValue()`. |
| `lefttext` | — | `string` | `self.textleft:GetText()`. |
| `righttext` | — | `string` | `self.textright:GetText()`. |
| `color` | — | `r, g, b, a` | `self._texture:GetVertexColor()`. |
| `icon` | — | `texture` | `self._icon:GetTexture()`. |
| `texture` | — | `texture` | `self._texture:GetTexture()`. |
| `fontsize` | `textsize` | `number` | Second return of `textleft:GetFont()`. |
| `fontface` | `textfont` | `string` | First return of `textleft:GetFont()`. |
| `fontcolor` | `textcolor` | `r, g, b, a` | `textleft:GetTextColor()`. |
| `alpha` | — | `number` | `self:GetAlpha()`. |

### Writable properties (`SetMembers`)

| Property | Aliases | Accepts | Effect |
|---|---|---|---|
| `tooltip` | — | `string?` | `rawset(self, "have_tooltip", value)`. |
| `shown` | — | `boolean` | True → `Show`; false → `Hide`. |
| `width` / `height` | — | `number` | `statusbar:SetWidth / SetHeight`. |
| `value` | — | `number` | Sets bar value AND repositions `div` (mouseover spark) to `value * width/100 - 16`. |
| `lefttext` / `righttext` | — | `string` | Sets fontstring text. |
| `color` | — | colour | `ParseColors`, then propagates to: `statusbar:SetStatusBarColor`, `_texture.original_colors`, `_texture:SetVertexColor`, `timer_texture:SetVertexColor`, `timer_textureR:SetVertexColor`. **Affects ALL fill textures.** |
| `backgroundcolor` | — | colour | `ParseColors`, then `background:SetVertexColor`. |
| `icon` | — | `texture` or `{texture, {l,r,u,d}}` | Sets texture; if a table is passed, also applies tex coords. |
| `texture` | — | `texture` or `{texture, {l,r,u,d}}` or LSM name | Applies to `_texture`, `timer_texture`, and `timer_textureR`. If a path-less string is passed, tries `SharedMedia:Fetch("statusbar", value)` first; falls back to passing the value directly. |
| `backgroundtexture` | — | `texture` or LSM name | Same LSM-fallback resolution but applies only to `background`. |
| `fontsize` | `textsize` | `number` | `DF:SetFontSize` on both fontstrings. |
| `fontface` | `textfont` | `string` | `DF:SetFontFace` on both. |
| `fontcolor` | `textcolor` | colour | `ParseColors`, then `SetTextColor` on both. |
| `shadow` | `outline` | `fontflags` | `DF:SetFontOutline` on both. |
| `alpha` | — | `number` | `self:SetAlpha(value)`. |

A file-local `smember_hide` is defined but **never registered** in `SetMembers`. Writing `bar.hide = true` does nothing (it falls through to `rawset`). Use `bar.shown = false` or `bar:Hide()`.

---

## Operators

| Operator | Form | Effect |
|---|---|---|
| `__call` | `bar()` or `bar(value)` | No arg returns `statusbar:GetValue()`. With arg, sets the bar value. **Does not reposition `div`** (only the `value` member setter does that). |
| `__add` | `bar + n` or `n + bar` | Adds `n` to the current value. |
| `__sub` | `bar - n` or `n - bar` | Subtracts `n` from the current value, regardless of operand order. |

Like in `split_bar.lua`, `__sub` ignores operand order — `5 - bar` does `current - 5`, not `5 - current`.

---

## Methods

### Visibility

```lua
bar:Show()
bar:Hide()
```

Forward to `statusbar:Show / Hide`.

### Value

```lua
bar:SetValue(value)   -- sets value AND repositions div. nil → 0.
```

### Sizing and positioning

```lua
bar:SetPoint(anchor, ...)        -- runs DF:CheckPoints first; prints on invalid args.
bar:SetSize(w, h)                -- each dim independently optional. See "SetSize doesn't propagate" in Pitfalls.
bar:GetFrameLevel()
bar:SetFrameLevel(level, frame?)
bar:GetFrameStrata()
bar:SetFrameStrata(strata)       -- strata may be a string or a frame (inherits its strata).
bar:SetContainer(container)      -- swap the drag-target frame.
```

### Texture and colour

```lua
bar:SetTexture(texture)           -- ONLY updates _texture. Use the `texture` member setter to update all three.
bar:SetColor(r, g, b, a)          -- propagates to statusbar status colour + _texture + sets original_colors.
                                  -- DOES NOT update timer_texture/timer_textureR (the member setter does).
bar:GetVertexColor()              -- _texture:GetVertexColor()
```

There's an asymmetry between methods and member setters worth knowing: the `texture` / `color` **member setters** propagate to all the fill textures; the `SetTexture` / `SetColor` **methods** only touch `_texture` (and, for color, `statusbar:SetStatusBarColor`). When you have an active timer, prefer the member setters.

### Text and icon

```lua
bar:SetLeftText(text)
bar:SetRightText(text)
bar:SetIcon(texture)
bar:SetIcon(texture, {L, R, U, D})   -- with tex coords (passed as a single table via varargs)
bar:ShowDiv(true/false)              -- toggle the mouseover spark (independent of hover state)
```

### Tooltip

```lua
bar:SetTooltip("Hello")        -- shown via GameCooltip2 on hover; nil clears
bar:GetTooltip()
```

`OnEnter` shows the tooltip and the background highlight. `OnLeave` hides both. The tooltip is shown via `GameCooltip2:ShowCooltip(frame, "tooltip")` and hidden via `GameCooltip2:ShowMe(false)`. Symmetric — unlike `split_bar.lua` which mixes `GameCooltip2` and `DF.popup`.

---

## Timer — countdown bars

A `normal_bar` can act as a countdown timer. The mechanism uses one of two timer textures (`timer_texture` or `timer_textureR`) animated per frame.

### `SetTimer(tempo, end_at)`

```lua
bar:SetTimer(10)            -- 10-second timer starting now
bar:SetTimer(2, endAt)      -- 2 seconds remaining of a timer that ends at `endAt`
```

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `tempo` | `number` | If `end_at` is nil: total duration (seconds). If `end_at` is set: remaining time (seconds). |
| 2 | `end_at` | `number?` | Absolute end time. When provided, `tempo` is treated as remaining; total duration becomes `end_at - tempo`. |

Behaviour:

1. Computes total duration, remaining time, and end-time on `statusbar`.
2. Picks the timer texture and spark anchor based on `self.LeftToRight`.
3. Sets the initial width based on `self.BarIsInverse` (0 if inverse, full if not).
4. Shows the timer texture, the timer spark (`div_timer`), and the background.
5. Sets `HasTimer = true` and `timer = true`.
6. Schedules `DF:StartTimeBarAnimation(self)` via `C_Timer.After(0.1, ...)` — a **100 ms delay before the animation starts**.

The `OnUpdate` ticks every frame:

- Computes `pct = abs(end_timer - GetTime() - tempo) / tempo` (normalised 0..1).
- Sets the active timer texture's width to `total_size * pct` (if inverse) or `total_size * (1 - pct)`.
- Updates `righttext` with the remaining time, formatted via `DF:IntegerToTimer` if `RightTextIsTimer` is true, else `math.floor`-ed.
- At `pct >= 1`: clears the text, removes the `OnUpdate`, clears `HasTimer`, and calls `OnTimerEnd`.

### `CancelTimerBar(no_timer_end)`

```lua
bar:CancelTimerBar()              -- cancel the timer AND fire OnTimerEnd
bar:CancelTimerBar(true)          -- cancel WITHOUT firing OnTimerEnd
```

No-op if `HasTimer` is falsy. Clears `TimerScheduled` (if set) or the `OnUpdate`, clears `righttext`, hides both timer textures, and (unless `no_timer_end` is truthy) calls `self:OnTimerEnd()`.

### `OnTimerEnd()`

Fires the `OnTimerEnd` hook list. If no hook returns "kill":

1. Hides both timer textures and the timer spark.
2. Calls `self:Hide()` — **the whole bar is hidden when the timer ends.**
3. Sets `self.timer = false`.

This auto-hide is intentional for timer-bar use cases (an expired cooldown shouldn't linger), but surprises consumers using the same bar as both a value display and a cooldown.

---

## Script hooks

| Script | Default behaviour |
|---|---|
| `OnEnter` | Shows `background` (hover highlight) and the tooltip (if `have_tooltip` is set). |
| `OnLeave` | Hides `background` and the tooltip. |
| `OnHide` | Hook only. |
| `OnShow` | Hook only. |
| `OnMouseDown` | If `container` is movable and not locked, calls `container:StartMoving()`. |
| `OnMouseUp` | If `container.isMoving`, calls `container:StopMovingOrSizing()`. |
| `OnTimerEnd` | Hides timer textures + spark, hides the bar, sets `timer = false`. |

To install a hook:

```lua
bar:HookScript("OnTimerEnd", function(_, _, capsule)
    -- ran when the timer reaches 0
end)
```

`HookScript` is provided by `ScriptHookMixin` (in `mixins.lua`).

---

## Pitfalls

### Value scale is hard-coded to 0..100

The constructor calls `statusbar:SetMinMaxValues(0, 100)`. The spark math (`value * width/100 - 16`) and the `value` member setter both bake `100` into the formulas. Using values outside 0..100 either clamps (status bar) or places the spark off-screen. Don't try `bar:SetValue(0.5)` expecting half — it'll place the spark off the left edge.

**Fix**: scale your data into 0–100 before passing. Or reach into `bar.statusbar:SetMinMaxValues(...)` directly and accept that the spark positions will be wrong.

### `SetTexture` / `SetColor` methods vs `.texture` / `.color` member setters

These do different things:

| Call | Updates _texture | Updates timer_texture | Updates timer_textureR | Updates statusbar colour |
|---|---|---|---|---|
| `bar:SetTexture(t)` | yes | NO | NO | n/a |
| `bar.texture = t` | yes | yes | yes | n/a |
| `bar:SetColor(r,g,b,a)` | yes | NO | NO | yes |
| `bar.color = {r,g,b,a}` | yes | yes | yes | yes |

If the timer is active and you call the method form, the timer texture will keep its old colour/texture. Prefer the member setters when you intend "everything".

### `SetSize` does NOT resize the timer textures

`SetSize(w, h)` updates `statusbar:SetWidth/SetHeight` but the timer textures are sized at construction (`SetWidth(w)` once in `NewBar`). After a resize, `timer_texture` and `timer_textureR` keep their old size, leading to a stretched or short timer fill.

**Fix**: resize the timer textures yourself after `SetSize`:

```lua
bar:SetSize(newW, newH)
bar.timer_texture:SetWidth(newW); bar.timer_texture:SetHeight(newH)
bar.timer_textureR:SetWidth(newW); bar.timer_textureR:SetHeight(newH)
```

### Two flags mean the same thing: `HasTimer` and `timer`

```lua
self.HasTimer = true     -- set by SetTimer
self.timer    = true     -- set by SetTimer
self.timer    = false    -- cleared by OnTimerEnd
-- but HasTimer is cleared earlier, by the OnUpdate when pct >= 1
```

`HasTimer` is what `CancelTimerBar` checks. `timer` is what consumers tend to read (lowercase, friendly). They're not always in lockstep — there's a brief window between "OnUpdate detects pct >= 1" and "OnTimerEnd runs" where `HasTimer` is nil but `timer` is still true.

**Fix**: check `HasTimer` for "is a timer scheduled" and `timer` for "is the timer animation visually running"; or just check one and treat them as redundant.

### `OnTimerEnd` hides the entire bar

```lua
self.timer_texture:Hide()
self.timer_textureR:Hide()
self.div_timer:Hide()
self:Hide()              -- ← hides the bar itself
self.timer = false
```

If you use the bar as a *value* display and only sometimes as a timer, the bar disappears whenever a timer expires. Consumers expecting "show forever, only the timer disappears" will be surprised.

**Fix**: hook `OnTimerEnd` and return "kill" to suppress the default, then handle the visuals yourself:

```lua
bar:HookScript("OnTimerEnd", function(_, _, capsule)
    capsule.timer_texture:Hide()
    capsule.timer_textureR:Hide()
    capsule.div_timer:Hide()
    capsule.timer = false
    return true   -- "kill" — prevents bar:Hide()
end)
```

### Timer animation has a 100 ms startup delay

```lua
C_Timer.After(0.1, function()
    DF:StartTimeBarAnimation(self)
end)
```

`SetTimer` does NOT begin animating immediately. There's a 100 ms delay before the `OnUpdate` is installed. For short timers (under 1 s) this is visually noticeable — the bar shows the initial frame for 100 ms before any progress.

**Fix**: not exposed. If you need precise timing, call `DF:StartTimeBarAnimation(bar)` yourself after `SetTimer`.

### `value` setter repositions `div`; `__call` does not

```lua
bar.value = 75    -- positions div at 75% AND sets bar value
bar(75)            -- sets bar value only; div stays where it was
```

The function-call form is faster (one method call) but inconsistent. The member-setter form is more thorough.

### `CancelTimerBar` clears `righttext`

```lua
self.righttext = ""
```

If you were using `righttext` for something other than the timer (e.g. a percentage display), it gets blanked. Always restore your text after cancelling a timer.

### Global name collisions (same as `split_bar.lua`)

The constructor populates `_G` with seven names: `<name>_background`, `<name>_timerTexture`, `<name>_timerTextureR`, `<name>_statusbarTexture`, `<name>_icon`, `<name>_sparkMouseover`, `<name>_sparkTimer`, plus the fontstrings. Two bars with the same explicit `name` will alias each other's textures. Use unique names or let the auto-counter pick one.

### `loadstring` fallback for StatusBar methods (same as `split_bar.lua`)

A one-time scan generates wrappers (via `loadstring`) for every `StatusBar` method missing from `BarMetaFunctions`. The wrappers re-fetch the bar from `_G` by name. If you rename or unparent the statusbar so its global registration changes, those wrappers break. The scan runs **once per session**.

**Fix**: call `bar.statusbar:Method(...)` directly for any StatusBar method outside the documented set.

### `BarObject.locked` is set but never read

```lua
BarObject.locked = false
```

The framework doesn't consume `locked`. The drag handlers check `container.isLocked` (note the `is` prefix) and `frame.isLocked`, not the bar wrapper's `locked` field. If you set `bar.locked = true` expecting drag to be disabled, nothing happens.

**Fix**: set `bar.container.isLocked = true` or `bar.statusbar.isLocked = true` (the drag scripts check both).

### `OnEnter` shows the background; consumers using `background` for something else will fight it

The background texture is repurposed as a hover indicator. Setting it via `bar.backgroundtexture = "MyBg"` and `bar.backgroundcolor = "white"` works for *appearance* but the hide-on-leave still fires. If you want a permanent background:

```lua
bar:HookScript("OnLeave", function(_, _, capsule)
    capsule.background:Show()    -- keep the background visible after leave
    return true                   -- skip default OnLeave (would hide it again)
end)
-- and ensure OnEnter doesn't return early:
bar.background:Show()              -- show on construction
```

### `OnEnter`/`OnLeave` tooltip uses `GameCooltip2`, not `GameTooltip`

If your addon doesn't pull in `GameCooltip2` (a separate library), the tooltip path errors. `GameCooltip2` is shipped with Details!; addons embedding only DF may not have it.

---

## Public method reference

| Method | Purpose |
|---|---|
| `Show()` / `Hide()` | Forward to `statusbar:Show / Hide`. |
| `SetValue(value)` | Set value (nil → 0). Repositions `div`. |
| `SetPoint(anchor, ...)` | Anchor the statusbar after `DF:CheckPoints`. |
| `SetSize(w, h)` | Resize statusbar (timer textures are NOT resized — see Pitfalls). |
| `SetTexture(texture)` | Set `_texture` only. Use the `texture` member setter to update all three. |
| `SetLeftText(text)` / `SetRightText(text)` | Set fontstring text. |
| `SetColor(r, g, b, a)` | Set `_texture` and statusbar status colour. Use the `color` member setter to also update timer textures. |
| `GetVertexColor()` | `_texture:GetVertexColor()`. |
| `SetIcon(texture, ...)` | Set icon texture and optional `{L, R, U, D}` tex coords. |
| `ShowDiv(bool)` | Toggle the mouseover spark explicitly. |
| `SetTooltip(text)` / `GetTooltip()` | Set / read `have_tooltip`. |
| `GetFrameLevel()` / `SetFrameLevel(level, frame?)` | Direct or relative-to-another-frame level. |
| `GetFrameStrata()` / `SetFrameStrata(strata)` | String or another frame (inherits its strata). |
| `SetContainer(container)` | Swap the drag target. |
| `SetTimer(tempo, end_at?)` | Start a countdown. 100 ms startup delay; `OnTimerEnd` hides the bar by default. |
| `CancelTimerBar(no_timer_end?)` | Stop the timer. Clears `righttext` unconditionally. |
| `OnTimerEnd()` | Fires the `OnTimerEnd` hook list; hides the bar and timer textures by default. |
| `DF:StartTimeBarAnimation(timebar)` | Module-level helper. Installs the timer `OnUpdate` script. Called automatically by `SetTimer`. |

---

## Usage Examples

### Basic value bar

```lua
local DF = _G["DetailsFramework"]

local bar = DF:CreateBar(UIParent, "Blizzard", 300, 18, 75, nil, "MyHPBar")
bar:SetPoint("center")
bar:SetColor(0.2, 0.8, 0.2, 1)
bar:SetLeftText("Player")
bar:SetRightText("75 / 100")
```

### Cooldown timer

```lua
local DF = _G["DetailsFramework"]

local bar = DF:CreateBar(UIParent, "Aluminum", 250, 16, 100, nil, "MyCDBar")
bar:SetPoint("center", UIParent, "center", 0, -100)
bar:SetIcon(135774)            -- spell icon
bar:SetLeftText("Recharging")
bar.RightTextIsTimer = true     -- format remaining as 1:23 instead of raw seconds
bar.LeftToRight     = false     -- shrink from the right (default)

-- Hook into the end event before starting
bar:HookScript("OnTimerEnd", function(_, _, capsule)
    print("Ability ready!")
end)

bar:SetTimer(12)   -- 12-second cooldown
```

### Inverse "filling-up" timer

```lua
local bar = DF:CreateBar(UIParent, "Aluminum", 250, 16, 0, nil, "ChargeBar")
bar:SetPoint("center")
bar.BarIsInverse = true        -- grow from 0 to full
bar.LeftToRight  = false
bar:SetColor(0.9, 0.6, 0.0)
bar:SetTimer(5)
```

### Property-style configuration

```lua
local bar = DF:NewBar(parent, parent, "MyPropBar", "myBar", 300, 14, 50, nil)
bar.texture     = "Blizzard"          -- LSM lookup; falls back to literal if not registered
bar.color       = "yellow"
bar.textsize    = 11
bar.textcolor   = {1, 1, 1, 1}
bar.tooltip     = "Right-click to lock"
bar.shadow      = "OUTLINE"
bar.lefttext    = "Charges"
bar.righttext   = "3/5"
```

### Cancelling a timer without hiding the bar

```lua
-- The default OnTimerEnd hides the bar. Override with a hook that returns "kill".
bar:HookScript("OnTimerEnd", function(_, _, capsule)
    capsule.timer_texture:Hide()
    capsule.timer_textureR:Hide()
    capsule.div_timer:Hide()
    capsule.timer = false
    capsule.righttext = "Ready"
    return true   -- prevents the default :Hide()
end)
```

---

## Notes for AI readers

1. **Value scale is hard-coded 0..100.** Don't recommend fractional values like `0.75`; pass `75`.
2. **`SetColor` and `SetTexture` methods do not update timer textures.** When a timer is active, prefer the member setters (`bar.color = ...`, `bar.texture = ...`).
3. **`SetSize` does not resize the timer textures.** Resize them yourself after.
4. **`OnTimerEnd` hides the whole bar by default.** Hook it and return truthy to suppress.
5. **`SetTimer` has a 100 ms startup delay.** Short timers will appear to stall briefly.
6. **Two flags track "timer running": `HasTimer` and `timer`.** They're not strictly synchronized. Prefer `HasTimer` for control flow.
7. **`BarObject.locked` is unused by the framework.** Setting it does not lock anything. To lock dragging, set `bar.container.isLocked = true`.
8. **`background` is a hover-indicator texture by default** — shown on OnEnter, hidden on OnLeave. Consumers using it for a permanent backdrop must override the leave path.
9. **`LeftToRight` and `BarIsInverse` interact** — read the truth table in "Mental model" before recommending one without the other.
10. **The `loadstring` fallback for `StatusBar` methods runs once per session.** For methods outside the documented set, call `bar.statusbar:Method(...)` directly.

---

## See also

- `split_bar.lua` / `split_bar.md` — the two-tone sibling. Same metatable shape, no built-in timer.
- `timebar.lua` — purpose-built countdown widget. If your use case is *only* a timer, prefer this.
- `label.lua` / `label.md` — the closest reference for the metatable-property-access pattern (`GetMembers` / `SetMembers`).
- `mixins.lua` — `ScriptHookMixin` (mixed in at load); `HookScript` / `RunHooksForWidget` live there.
- `colors.lua` — `DF:ParseColors`.
- `panel.lua` — `DF:CheckPoints`, `DF:GetParentName`.
- `LibSharedMedia-3.0` — texture name lookup used by `texture` and `backgroundtexture` member setters.
