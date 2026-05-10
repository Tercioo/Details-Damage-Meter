# DetailsFramework — Time Bar System

## Overview

`timebar.lua` implements a `df_timebar`, a status-bar widget that drives itself forward in real time using `GetTime()` as the min/max values of a WoW `StatusBar`. It solves the problem of displaying timed progress for:

- Spell cooldowns (showing how much time remains before a cooldown is ready)
- Encounter events or boss abilities (showing the remaining time until an ability fires)
- Auto-close countdowns and any UI timer that needs a draining or filling bar

The bar fills or drains automatically on every frame (or on a throttled interval), updates an optional countdown text on the right side, and shows an animated spark that tracks the leading edge of the fill. When the timer expires, an `OnTimerEnd` hook fires automatically.

---

## 1. Entry Point — `CreateTimeBar`

```lua
local timeBar = detailsFramework:CreateTimeBar(
    parent,   -- (frame)                  Parent WoW frame.
    texture,  -- (texturepath|textureid?) Bar fill texture. Defaults to WorldState highlight texture.
    width,    -- (number?)                Bar width in pixels. Default 150.
    height,   -- (number?)                Bar height in pixels. Default 20.
    value,    -- (number?)                Initial StatusBar value (0–100). Default 0.
    member,   -- (string?)                If set, stored as parent[member].
    name,     -- (string?)                Global name for the underlying StatusBar. Auto-generated if nil.
)
-- Returns: df_timebar
```

`$parent` in `name` is resolved to the parent frame's global name.

If `parent` is itself a `df_` framework object (`parent.dframework == true`), the constructor unwraps `parent.widget` before creating the StatusBar.

### Initialization sequence

1. A plain Lua table `{ type = "timebar", dframework = true }` is created as the object.
2. A WoW `StatusBar` (with `BackdropTemplate`) is created and stored as `timeBar.statusBar` and `timeBar.widget`.
3. Internal textures are created as children of the StatusBar:
   - `backgroundTexture` — border-layer solid color fill, slightly dark `(0.1, 0.1, 0.1, 0.6)`.
   - `barTexture` — artwork-layer texture used as `SetStatusBarTexture`.
   - `spark` — overlay-layer spark texture (`Interface\CastingBar\UI-CastingBar-Spark`), blend mode ADD, initially hidden.
   - `icon` — overlay-layer texture for a left-side icon.
   - `leftText` — overlay FontString (`GameFontNormal`) anchored left.
   - `rightText` — overlay FontString (`GameFontNormal`) anchored right, used for countdown display.
4. The StatusBar initial values are `min=0, max=100, value=<value param>`.
5. Script hooks are installed for `OnEnter`, `OnLeave`, `OnHide`, `OnShow`, `OnMouseDown`, `OnMouseUp`.
6. The hook list table is set up with entries for all hookable events.
7. The metatable is set to `TimeBarMetaFunctions`.

---

## 2. Object Structure (`df_timebar`)

### Top-level fields

| Field | Type | Description |
|---|---|---|
| `type` | `"timebar"` | Component type identifier. |
| `dframework` | `true` | Marks this as a framework object. |
| `statusBar` | `df_timebar_statusbar` | The underlying WoW StatusBar widget. |
| `widget` | `statusbar` | Alias for `statusBar`. |
| `direction` | `"right"` or `"left"` | Fill direction. Default `"right"`. |
| `locked` | `boolean` | Initialized to `false`. Not used internally; available for caller use. |
| `HookList` | `table` | Internal hook registry used by `SetHook`/`RunHooksForWidget`. |
| `tooltip` | `string?` | Tooltip text shown via `GameCooltip2` on mouse hover. |

### `statusBar` internal fields (set at runtime)

| Field | Type | Description |
|---|---|---|
| `MyObject` | `df_timebar` | Back-reference to the owning `df_timebar`. |
| `hasTimer` | `boolean?` | `true` while a timer is running; `nil` when stopped. |
| `startTime` | `number` | `GetTime()` value when the current timer started. |
| `endTime` | `number` | `GetTime()` value when the timer will end. |
| `timeLeft1` | `number?` | Dedup key for explicit `(currentValue, minValue, maxValue)` form. |
| `timeLeft2` | `number?` | Dedup key for simple `(seconds, true)` form. |
| `throttle` | `number` | Accumulated delta time for throttle tracking. |
| `isUsingThrottle` | `boolean?` | Whether throttle is active. |
| `amountThrottle` | `number?` | Throttle interval in seconds. |
| `showTimer` | `boolean?` | Whether to show countdown text in `rightText`. |
| `dontShowSpark` | `boolean?` | When `true`, the spark is never shown. |
| `sparkAlpha` | `number?` | Alpha override for the spark texture. |
| `sparkColorR/G/B` | `number?` | Color override for the spark vertex color. |
| `direction` | `string` | Copied from `timeBar.direction` when a timer starts. |
| `spark` | `texture` | The spark texture. |
| `icon` | `texture` | Left-side icon texture. |
| `leftText` | `fontstring` | Left-side label text. |
| `rightText` | `fontstring` | Right-side text, used for the countdown display. |
| `backgroundTexture` | `texture` | Bar background texture (border layer). |
| `barTexture` | `texture` | Bar fill texture (artwork layer, set as StatusBarTexture). |

---

## 3. Methods

All methods are called on the `df_timebar` object.

### Timer control

#### `SetTimer(currentTime, startTime, endTime)`

The primary timer API. Has three calling forms:

**Form 1 — Stop the timer:**
```lua
timeBar:SetTimer()
timeBar:SetTimer(0)
timeBar:SetTimer(nil)
```
Calls `StopTimer()`.

---

**Form 2 — Simple countdown from now:**
```lua
timeBar:SetTimer(seconds, true)
```
- `seconds` — duration of the countdown in seconds.
- Second argument must be the boolean `true`.
- Internally sets `startTime = GetTime()`, `endTime = GetTime() + seconds`.
- Deduplication: if `hasTimer` is already active and `currentTime == timeLeft2`, the call is ignored (same timer). Pass `true` as `startTime` to force a restart.

**Form 3 — Explicit GetTime() range:**
```lua
timeBar:SetTimer(currentValue, minValue, maxValue)
```
- All three values are `GetTime()`-based numbers (e.g., from a cooldown library).
- `currentValue` is used as the dedup key (`timeLeft1`). If `hasTimer` is active and `currentValue == timeLeft1`, the call is ignored.
- The StatusBar's `min/max` are set to `minValue/maxValue`.

**In all non-stop forms:**
- StatusBar fill direction is set via `SetReverseFill` based on `direction`.
- `OnUpdate` is installed on `statusBar`.
- The spark is shown and configured (alpha, color, size = `statusBar:GetHeight() + 26`).
- `hasTimer` is set to `true`.
- The `OnTimerStart` hook fires.

---

#### `StopTimer()`
```lua
timeBar:StopTimer()
```
- Clears `hasTimer`.
- Removes the `OnUpdate` script.
- Resets StatusBar to `min=0, max=100, value=100`.
- Clears `rightText`.
- Hides the spark.
- Fires the `OnTimerEnd` hook.

Calling `StopTimer` when no timer is running is safe (does nothing).

---

#### `HasTimer()`
```lua
local isActive = timeBar:HasTimer()  -- boolean?
```
Returns `statusBar.hasTimer`. `true` while a timer is running, `nil` (falsy) when stopped.

---

### Visuals

#### `SetTexture(texture)`
```lua
timeBar:SetTexture("Interface\\AddOns\\MyAddon\\bar.tga")
```
Sets the texture of `barTexture` (the fill texture). Does not affect the background.

---

#### `SetColor(color, green, blue, alpha)`
```lua
timeBar:SetColor(1, 0.2, 0.2, 1)       -- RGBA
timeBar:SetColor("red")                  -- named color (parsed by detailsFramework)
timeBar:SetColor({0.8, 0.1, 0.1, 1})    -- table
```
Sets the vertex color of `barTexture`. Accepts any color format supported by `detailsFramework:ParseColors`.

---

#### `SetBackgroundColor(color, green, blue, alpha)`
```lua
timeBar:SetBackgroundColor(0, 0, 0, 0.8)
```
Sets the vertex color of `backgroundTexture`. Same color format as `SetColor`.

---

#### `SetIconPosition(position)`
```lua
timeBar:SetIconPosition(DF_TIMEBAR_ICON_POSITIONS_OUTSIDE)
```
Sets the icon to be show within the statubar or outside.
If called without parameter, a refresh with the already set position is performed.
Accept parameters:
- nil (just refresh)
- DF_TIMEBAR_ICON_POSITIONS_INSIDE (default when the timebar is created)
- DF_TIMEBAR_ICON_POSITIONS_OUTSIDE

---

#### `SetDirection(direction)`
```lua
timeBar:SetDirection("right")  -- bar fills left → right (default)
timeBar:SetDirection("left")   -- bar fills right → left
timeBar:SetDirection(nil)      -- defaults to "right"
```
Sets `self.direction`. The direction is applied to the StatusBar via `SetReverseFill` the next time `SetTimer` is called. Changing direction while a timer is running has no immediate effect until the next `SetTimer` call.

---

#### `ShowSpark(state, alpha, color)`
```lua
timeBar:ShowSpark(true)                          -- enable spark (default)
timeBar:ShowSpark(false)                         -- disable spark permanently
timeBar:ShowSpark(true, 0.5)                     -- spark at 50% alpha
timeBar:ShowSpark(true, nil, "yellow")           -- spark with color
timeBar:ShowSpark(true, 0.8, {1, 0.8, 0})       -- spark with alpha and color
```
- `state = false` sets `dontShowSpark = true`; any other value clears the flag.
- `alpha` overrides spark alpha; `nil` resets to default (1.0).
- `color` overrides spark vertex color; `nil` resets to white `(1, 1, 1)`.

Settings are applied the next time `SetTimer` starts a timer.

---

#### `ShowTimer(bShowTimer)`
```lua
timeBar:ShowTimer(true)   -- enables countdown text in rightText
timeBar:ShowTimer(false)  -- disables countdown text
```
When enabled, the `rightText` FontString displays the remaining time as a formatted string (`mm:ss` or similar via `detailsFramework:IntegerToTimer`) on every update tick.

---

#### `SetIcon(texture, L, R, T, B)`
```lua
timeBar:SetIcon("Interface\\Icons\\Spell_Fire_Fireball")
timeBar:SetIcon("Interface\\Icons\\Spell_Fire_Fireball", 0.1, 0.9, 0.1, 0.9)  -- with tex coords
timeBar:SetIcon(nil)  -- hides the icon
```
- When `texture` is provided: shows the `icon` texture, anchors it 2 px from the left of the bar, sizes it to `height - 2` square, and moves `leftText` to the right of the icon.
- When `texture` is `nil`: hides the icon, re-anchors `leftText` to the left of the bar.
- `L, R, T, B` are optional tex-coord overrides.

---

#### `GetIcon()`
```lua
local iconTexture = timeBar:GetIcon()  -- texture
```
Returns the `icon` texture object.

---

#### `SetIconSize(width, height)`
```lua
timeBar:SetIconSize(24, 24)
timeBar:SetIconSize(24, nil)   -- width only
timeBar:SetIconSize(nil, 24)   -- height only
```
Sets the pixel dimensions of the icon texture.

---

#### `SetLeftText(text)`
```lua
timeBar:SetLeftText("Fire Blast")
```
Sets the text of `leftText`.

---

#### `SetRightText(text)`
```lua
timeBar:SetRightText("12s")
```
Sets the text of `rightText` directly. Note: this is overwritten on every update tick when `ShowTimer(true)` is active.

---

#### `SetFont(font, size, color, outline, shadowColor, shadowX, shadowY)`
```lua
timeBar:SetFont("Fonts\\FRIZQT__.TTF", 12, "white", "OUTLINE")
timeBar:SetFont(nil, 11, nil, false, "black", 1, -1)
```
Applies font settings to **both** `leftText` and `rightText`. All parameters are optional; pass `nil` to skip a parameter.

| Parameter | Type | Effect |
|---|---|---|
| `font` | `string?` | Font face path. |
| `size` | `number?` | Font size in points. |
| `color` | `any?` | Font color (any format parsed by `detailsFramework`). |
| `outline` | `string|boolean?` | Outline style (e.g. `"OUTLINE"`, `"THICKOUTLINE"`). |
| `shadowColor` | `any?` | Shadow color. |
| `shadowX` | `number?` | Shadow X offset. |
| `shadowY` | `number?` | Shadow Y offset. |

---

#### `SetThrottle(seconds)`
```lua
timeBar:SetThrottle(0.1)   -- update at most every 0.1 seconds
timeBar:SetThrottle(nil)   -- disable throttle (update every frame)
timeBar:SetThrottle(0)     -- disable throttle
```
When `seconds > 0`, the `OnUpdate` handler accumulates delta time and skips updates until the accumulated time reaches `seconds`, then resets. This reduces CPU usage for timers where per-frame precision is not required.

---

### Hooks

#### `SetHook(hookName, func)` (from `ScriptHookMixin`)
```lua
timeBar:SetHook("OnTimerEnd", function(statusBar, timebar)
    print("Timer finished!")
end)

timeBar:SetHook("OnTimerStart", function(statusBar, timebar)
    print("Timer started!")
end)

timeBar:SetHook("OnUpdate", function(statusBar, timebar, deltaTime)
    -- called every update tick (subject to throttle)
end)
```
Registers an additional handler for a script event. Multiple hooks per event are supported; they run in registration order. If a hook returns a truthy value, subsequent hooks and the default behavior are suppressed.

**Available hook names:**

| Hook | Arguments | When called |
|---|---|---|
| `OnEnter` | `statusBar, timebar` | Mouse enters the bar. |
| `OnLeave` | `statusBar, timebar` | Mouse leaves the bar. |
| `OnHide` | `statusBar, timebar` | Bar is hidden. |
| `OnShow` | `statusBar, timebar` | Bar is shown. |
| `OnUpdate` | `statusBar, timebar, deltaTime` | Every frame (or throttled interval) while a timer is running. |
| `OnMouseDown` | `statusBar, timebar` | Mouse button pressed on the bar. |
| `OnMouseUp` | `statusBar, timebar` | Mouse button released. |
| `OnTimerStart` | `statusBar, timebar` | `SetTimer` successfully starts a new timer. |
| `OnTimerEnd` | `statusBar, timebar` | Timer expires naturally or `StopTimer` is called. |

---

## 4. Timer Logic

### Internal representation

The StatusBar's native `min/max` values are set to `GetTime()` timestamps:

```
statusBar:SetMinMaxValues(startTime_GetTime, endTime_GetTime)
```

On every `OnUpdate` tick:

```lua
local timeNow = GetTime()
statusBar:SetValue(timeNow)
```

Because `timeNow` starts at `startTime` and grows toward `endTime`, the bar fills naturally. When `direction == "right"`, `SetReverseFill(false)` is used (fills left to right). When `direction == "left"`, `SetReverseFill(true)` is used (fills right to left).

### Completion check

At the end of every `OnUpdate`:
```lua
if timeNow >= endTime then
    self.MyObject:StopTimer()
end
```

### Spark positioning

While the spark is enabled:
```lua
local pct = 1 - abs((timeNow - endTime) / (endTime - startTime))
-- for "right" direction: spark placed at (barWidth * pct) - 16 pixels from left
-- for "left" direction: pct = 1 - pct; sparkOffset = -14
spark:SetPoint("left", self, "left", (barWidth * pct) + sparkOffset, 0)
```

### Throttle

When `isUsingThrottle` is `true`:
1. `throttle = throttle + deltaTime` each frame.
2. If `throttle < amountThrottle`, skip the update.
3. When `throttle >= amountThrottle`, process the update and reset `throttle = 0`.

### Deduplication

`SetTimer` silently ignores calls that would restart the exact same timer:
- **Explicit form** `(currentTime, minValue, maxValue)`: ignored if `hasTimer` is active and `currentTime == timeLeft1`.
- **Simple form** `(seconds, nil)`: ignored if `hasTimer` is active and `seconds == timeLeft2`. Pass `true` as the second argument to force a restart.

---

## 5. Rendering and Layout

### Frame hierarchy

```
statusBar (StatusBar, BackdropTemplate)
├── backgroundTexture (border layer)   — full-area dark background
├── barTexture (artwork layer)         — the fill texture, set as StatusBarTexture
├── spark (overlay layer, subLevel 7)  — animated leading-edge spark
├── icon (overlay layer, subLevel 5)   — optional left-side icon
├── leftText (overlay layer, subLevel 4) — left-aligned label
└── rightText (overlay layer, subLevel 4) — right-aligned countdown or custom text
```

### Default visual defaults

| Element | Default |
|---|---|
| Background | `(0.1, 0.1, 0.1, 0.6)` dark fill |
| Fill texture | `Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT` |
| Spark texture | `Interface\CastingBar\UI-CastingBar-Spark`, blend mode ADD |
| Spark initial state | Hidden (shown only when `SetTimer` is called) |
| Icon initial state | Shown at left, no texture |
| Font | `GameFontNormal` for both left and right text |
| Mouse interaction | Disabled (`EnableMouse(false)`) |

### Countdown text format

When `ShowTimer(true)` is active, the right text is set to `detailsFramework:IntegerToTimer(floor(endTime - GetTime()) + 1)`, which produces `"mm:ss"` formatted strings.

---

## 6. Data Flow

```
Caller creates options
        │
        ▼
CreateTimeBar(parent, texture, width, height, value, member, name)
  → creates statusBar (WoW StatusBar)
  → creates child textures (background, bar, spark, icon)
  → creates child FontStrings (leftText, rightText)
  → installs script hooks
  → returns df_timebar
        │
        ▼
(Optional setup)
  timeBar:SetColor(...)
  timeBar:SetIcon(...)
  timeBar:SetFont(...)
  timeBar:ShowSpark(true, alpha, color)
  timeBar:ShowTimer(true)
  timeBar:SetThrottle(0.1)
  timeBar:SetDirection("right")
        │
        ▼
timeBar:SetTimer(seconds, true)   -- or (currentValue, minValue, maxValue)
  → validates not duplicate
  → sets statusBar min/max to GetTime() timestamps
  → configures SetReverseFill based on direction
  → shows and configures spark
  → sets hasTimer = true
  → installs OnUpdate on statusBar
  → fires OnTimerStart hook
        │
        ▼
Every frame (OnUpdate on statusBar):
  → [throttle check — skip if not enough time elapsed]
  → statusBar:SetValue(GetTime())
  → reposition spark
  → [if ShowTimer] update rightText countdown
  → check if GetTime() >= endTime
        │
        ├── not yet expired: continue
        │
        └── expired:
              timeBar:StopTimer()
                → clears hasTimer
                → removes OnUpdate script
                → resets min=0, max=100, value=100
                → clears rightText
                → hides spark
                → fires OnTimerEnd hook
```

---

## 7. Practical Usage Patterns

### Simple countdown bar

```lua
local bar = DF:CreateTimeBar(myFrame, [[Interface\AddOns\MyAddon\bar.tga]], 200, 20)
bar:SetPoint("topleft", myFrame, "topleft", 5, -5)

-- Start a 30-second countdown
bar:SetTimer(30, true)

-- Stop it early
bar:StopTimer()
```

---

### Countdown with display text and hook

```lua
local bar = DF:CreateTimeBar(parent, texture, 200, 20)
bar:ShowTimer(true)    -- show "mm:ss" on the right
bar:SetThrottle(0.25)  -- update 4 times per second

bar:SetHook("OnTimerEnd", function(statusBar, timebar)
    print("Cooldown ready!")
end)

bar:SetTimer(120, true)  -- 2-minute countdown
```

---

### Using explicit GetTime() values (from a cooldown library)

```lua
-- isReady, normalizedPercent, timeLeft, charges, minValue, maxValue, currentValue
--   = cooldownLib.GetCooldownStatus(cooldownInfo)

if not isReady then
    cooldownLine:SetTimer(currentValue, minValue, maxValue)
else
    cooldownLine:SetTimer()  -- stop / show as ready
end
```

This pattern (from the cooldown tracker) passes raw `GetTime()` timestamps directly. The bar automatically fills from `minValue` to `maxValue` over time.

---

### Bar with icon, label, and custom spark

```lua
local bar = DF:CreateTimeBar(parent, texture, 220, 24)
bar:SetIcon("Interface\\Icons\\Spell_Fire_Fireball02", 0.1, 0.9, 0.1, 0.9)
bar:SetLeftText("Fire Blast")
bar:SetColor(1, 0.4, 0.1, 1)           -- orange-red fill
bar:SetBackgroundColor(0, 0, 0, 0.8)
bar:ShowSpark(true, 0.9, {1, 0.8, 0.2})  -- golden spark at 90% alpha
bar:ShowTimer(true)

bar:SetTimer(30, true)
```

---

### Left-draining bar (right-to-left fill)

```lua
local bar = DF:CreateTimeBar(parent, texture, 200, 20)
bar:SetDirection("left")   -- drains from right to left
bar:SetTimer(15, true)
```

---

### Auto-close countdown (mythic+ pattern)

```lua
-- From window_end_of_run.lua:
local autoCloseTimeBar = detailsFramework:CreateTimeBar(
    contentFrame,
    [[Interface\AddOns\Details\images\bar_serenity]]
)

-- Later, when showing the panel:
autoCloseTimeBar:SetTimer(Details.mythic_plus.autoclose_time, true)

autoCloseTimeBar:SetHook("OnTimerEnd", function()
    readyFrame:Hide()
end)
```

---

### Updating a bar without restarting it (dedup)

```lua
-- Calling SetTimer with the same value while the timer is running is a no-op.
-- This is safe to call on every game event without causing resets:
bar:SetTimer(currentValue, minValue, maxValue)

-- To force a restart of the same duration, pass `true` as startTime:
bar:SetTimer(30, true)   -- always starts fresh
```

---

## 8. Differences from a Standard StatusBar

| Feature | WoW `StatusBar` | `df_timebar` |
|---|---|---|
| Value update | Manual (`SetValue`) | Automatic via `OnUpdate` using `GetTime()` |
| Min/Max semantics | Arbitrary | Set to `GetTime()` timestamps during a timer |
| Spark | Not built-in | Built-in, auto-positioned |
| Countdown text | Not built-in | Optional via `ShowTimer(true)` |
| Direction | Via `SetFillStyle` / `SetReverseFill` | Via `SetDirection("left"|"right")` |
| Throttle | Not built-in | Optional via `SetThrottle(seconds)` |
| Callbacks | WoW scripts only | Hook system (`OnTimerStart`, `OnTimerEnd`, `OnUpdate`, etc.) |
| Deduplication | None | Ignores redundant `SetTimer` calls |
