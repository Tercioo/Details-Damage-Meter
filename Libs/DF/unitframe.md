# DetailsFramework — Health Bar System

> **Scope**: This document covers only the `df_healthbar` object.  
> Cast bar, power bar, and unit frame are separate objects and are not documented here.

---

## Overview

`unitframe.lua` implements `df_healthbar`, a `StatusBar`-based widget that tracks a WoW unit's health in real time. It:

- Registers the appropriate WoW unit events for health, max-health, healing prediction, and absorbs.
- Drives itself: every event fires one or more internal update functions that pull fresh values from the WoW API and push them into the bar.
- Displays four overlay indicators: incoming heals, heal absorbs, damage absorbs (shields), and a shield-overflow glow.
- Exposes a hook system so callers can react to health changes without subclassing.

The health bar is usable as a **standalone widget** (attach to any frame, call `SetUnit`) or as a sub-component of a `df_unitframe` (`mewUnitFrame.healthBar`).

---

## 1. Entry Point — `CreateHealthBar`

```lua
local healthBar = detailsFramework:CreateHealthBar(
    parent,           -- (frame)   Parent WoW frame.
    name,             -- (string?) Absolute global name for the StatusBar. If nil, uses parent:GetName() .. "HealthBar".
    settingsOverride  -- (table?)  Key/value pairs to override defaults from df_healthbarsettings.
)
-- Returns: df_healthbar
```

**Requirement**: either `name` is provided, or `parent` must have a global name (`parent:GetName()` must be non-nil). Violating this triggers a Lua error.

### Initialization sequence

1. A WoW `StatusBar` (with `BackdropTemplate`) is created as the base frame.
2. Child textures are created in a specific layer order (see §5).
3. Two mixins are applied:
   - `healthBarMetaFunctions` — all health-bar-specific methods.
   - `detailsFramework.StatusBarFunctions` — texture/color/mask helpers shared with cast bar and power bar.
4. A `TextureMask` is created (`CreateTextureMask()`), and `background`, `extraBackground`-equivalent textures are enrolled in the mask automatically.
5. The initial bar texture is set to `Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT` (used as a shape/mask seed; the real texture is set later in `Initialize`).
6. A **private copy** of `healthBarMetaFunctions.Settings` is made and stored as `healthBar.Settings`; any `settingsOverride` keys are merged into it.
7. If `Settings.DontSetStatusBarTexture` is `false` (default), `barTexture` is registered as the StatusBar's status bar texture via `SetStatusBarTexture`. Otherwise `barTexture:SetAllPoints()` is called instead (for a non-standard layout).
8. A **private copy** of `healthBarMetaFunctions.HookList` is stored as `healthBar.HookList`.
9. `healthBar:Initialize()` is called — sets pixel-aligned width/height, applies all initial texture assignments, and calls `SetUnit(nil)` to clear state.

---

## 2. Object Structure (`df_healthbar`)

A `df_healthbar` **is** a WoW `StatusBar` frame with additional fields mixed in — there is no wrapper table. Methods are available directly on the frame object.

### Runtime state fields

| Field | Type | Description |
|---|---|---|
| `WidgetType` | `"healthBar"` | Component type identifier. |
| `unit` | `unit?` | The unit token currently tracked (e.g. `"target"`, `"nameplate1"`). `nil` when unbound. |
| `displayedUnit` | `unit?` | The unit whose health values are read. Usually equals `unit`; may differ when displaying a "raid target as seen from another unit". |
| `oldHealth` | `number` | Previous `currentHealth` value before the last `UpdateHealth` call. |
| `currentHealth` | `number` | Last-known health value (raw, not percentage). |
| `currentHealthMax` | `number` | Last-known maximum health. |
| `currentHealthMissing` | `number` | `currentHealthMax - currentHealth`. Updated by both `UpdateHealth` and `UpdateMaxHealth`. |
| `currentHealthPercent` | `number` | `currentHealth / currentHealthMax * 100`. |
| `currentHealthPercentMissing` | `number` | `100 - currentHealthPercent`. Set only by `UpdateMaxHealth`. |
| `nextShieldHook` | `number?` | `GetTime()` throttle for the `OnAbsorbOverflow` hook (fires at most every 0.2 s). |
| `Settings` | `df_healthbarsettings` | Per-instance settings table (private copy, not shared). |
| `HookList` | `table` | Per-instance hook registry (private copy). |

### Child textures

| Field | Layer | Sub-level | Description |
|---|---|---|---|
| `background` | `"background"` | `-6` | Solid-color backdrop behind the fill. |
| `barTexture` | `"artwork"` | `1` | The fill texture, registered as `SetStatusBarTexture`. |
| `incomingHealIndicator` | `"artwork"` | `5` (draw subLevel `4`) | Green overlay showing incoming healing. |
| `healAbsorbIndicator` | `"artwork"` | `4` (draw subLevel `6`) | Teal overlay showing a debuff absorbing heals. Default vertex color `(0.1, 0.8, 0.8)`. |
| `shieldAbsorbIndicator` | `"artwork"` | `3` (draw subLevel `5`) | Shield fill texture showing damage absorbs. Uses `Settings.ShieldIndicatorTexture`. |
| `shieldAbsorbGlow` | `"artwork"` | `6` (draw subLevel `7`) | ADD-blend glow anchored at the right edge of the bar; only shown when shield overflow occurs. Uses `Settings.ShieldGlowTexture`. |
| `barTextureMask` | mask | — | Created by `CreateTextureMask()`; clips the bar and its child textures to a rounded/custom shape. |
| `barBorderTextureForMask` | `"overlay"` | `7` | Optional border texture that rides the mask. Hidden by default; shown via `SetBorderTexture(texture)`. |

---

## 3. Settings (`df_healthbarsettings`)

The settings table is created per-instance inside `CreateHealthBar`. Override any key via `settingsOverride`.

| Key | Type | Default | Effect |
|---|---|---|---|
| `CanTick` | `boolean` | `false` | When `true`, installs `OnUpdate` calling `healthBar:OnTick(deltaTime)` each frame (stub — must be overridden by caller). |
| `ShowHealingPrediction` | `boolean` | `true` | Shows `incomingHealIndicator` and `healAbsorbIndicator`. When `false`, those textures are permanently hidden and the relevant events are unregistered. |
| `ShowShields` | `boolean` | `true` | Shows `shieldAbsorbIndicator` and `shieldAbsorbGlow`. When `false`, those textures are permanently hidden and `UNIT_ABSORB_AMOUNT_CHANGED` is unregistered. |
| `DontSetStatusBarTexture` | `boolean` | `false` | When `true`, skips `SetStatusBarTexture(barTexture)` and instead calls `barTexture:SetAllPoints()`. Use when the health bar texture is managed manually. |
| `BackgroundColor` | `df_colortable` | `(0.2, 0.2, 0.2, 0.8)` | Background texture solid color. |
| `Texture` | `texturepath\|textureid\|atlasname` | `Interface\RaidFrame\Raid-Bar-Hp-Fill` | Initial fill texture set during `Initialize`. |
| `ShieldIndicatorTexture` | `texturepath\|...` | `Interface\RaidFrame\Shield-Fill` | Texture for `shieldAbsorbIndicator`. |
| `ShieldGlowTexture` | `texturepath\|...` | `Interface\RaidFrame\Shield-Overshield` | Texture for `shieldAbsorbGlow`. |
| `ShieldGlowWidth` | `number` | `16` | Width of the `shieldAbsorbGlow` texture in pixels. |
| `Width` | `number` | `100` | Initial width set by `Initialize` via `PixelUtil.SetWidth`. |
| `Height` | `number` | `20` | Initial height set by `Initialize` via `PixelUtil.SetHeight`. |

---

## 4. Methods

All methods are called on the `df_healthbar` frame object (i.e. `healthBar:MethodName(...)`).

### Unit binding

#### `SetUnit(unit, displayedUnit?)`
```lua
healthBar:SetUnit("target")
healthBar:SetUnit("nameplate1", "nameplate1")
healthBar:SetUnit(nil)  -- unbind
```
- Binds the health bar to a unit. Registers all events in `HealthBarEvents` for that unit. When `unit` is `nil`, unregisters all events, removes all scripts, and hides the bar.
- `displayedUnit` defaults to `unit` when omitted. Health values are always read from `displayedUnit`; events are registered for both `displayedUnit` and `unit`.
- Calling `SetUnit` with the exact same `unit` and `displayedUnit` as the current binding is a **no-op** (deduplication guard).
- After binding, immediately calls `PLAYER_ENTERING_WORLD` to populate initial values.

---

### Health updates

#### `UpdateHealth()`
```lua
healthBar:UpdateHealth()
```
- Reads `UnitHealth(displayedUnit)`.
- Updates `oldHealth`, `currentHealth`, `currentHealthMissing`, `currentHealthPercent`.
- Calls `PixelUtil.SetStatusBarValue(self, health)` to move the bar fill.
- Fires `OnHealthChange` hook (or direct call if `self.OnHealthChange` is set).

#### `UpdateMaxHealth()`
```lua
healthBar:UpdateMaxHealth()
```
- Reads `UnitHealthMax(displayedUnit)`.
- Calls `SetMinMaxValues(0, maxHealth)` on the StatusBar.
- Updates `currentHealthMax`, `currentHealthMissing`, `currentHealthPercent`, `currentHealthPercentMissing`.
- Fires `OnHealthMaxChange` hook.

#### `UpdateHealPrediction()`
```lua
healthBar:UpdateHealPrediction()
```
- Reads incoming heals (`UnitGetIncomingHeals`), heal absorbs (`UnitGetTotalHealAbsorbs`), and damage absorbs (`UnitGetTotalAbsorbs`).
- Positions and sizes the three overlay indicators proportionally to `currentHealth / currentHealthMax` and the bar's pixel width.
- Each indicator's width is clamped: `min(width * pct, abs(healthPercent - 1) * width)` — it never exceeds the empty portion of the bar.
- Fires `OnAbsorbOverflow(self, displayedUnit, overflowFraction)` when `(healthPercent + damageAbsorbPercent) > 1`, throttled to once per 0.2 s. When overflow ends (absorb ≤ health space), fires `OnAbsorbOverflow(self, displayedUnit, 0)`.

---

### Texture and color (from `StatusBarFunctions` mixin)

#### `SetTexture(texture, isTemporary?)`
```lua
healthBar:SetTexture([[Interface\AddOns\MyAddon\bar.tga]])
healthBar:SetTexture([[Interface\AddOns\MyAddon\bar.tga]], true)  -- temporary; doesn't update currentTexture
```
Sets `barTexture`'s texture. If `isTemporary` is falsy, also saves it as `barTexture.currentTexture` for use with `ResetTexture`.

#### `GetTexture()`
```lua
local texturePath = healthBar:GetTexture()
```
Returns the current texture path from `barTexture:GetTexture()`.

#### `ResetTexture()`
```lua
healthBar:ResetTexture()
```
Reverts to `barTexture.currentTexture` (the last non-temporary texture).

#### `SetColor(r, g, b, a)` / `GetColor()`
```lua
healthBar:SetColor(1, 0.2, 0.2, 1)
healthBar:SetColor("red")
healthBar:SetColor({0.8, 0.1, 0.1, 1})
```
Calls `SetStatusBarColor` after parsing via `detailsFramework:ParseColors`. Accepts RGBA numbers, a named color string, or a table. `GetColor()` returns `GetStatusBarColor()`.

#### `SetVertexColor(r, g, b, a)` / `GetVertexColor()`
```lua
healthBar:SetVertexColor(0.5, 1, 0.5, 1)
```
Sets the vertex color of `barTexture` directly (does not affect `SetStatusBarColor`).

#### `SetDesaturated(bool)` / `SetDesaturation(amount)` / `IsDesaturated()`
Controls greyscale desaturation of `barTexture`.

#### `SetAtlas(atlasName)` / `GetAtlas()`
Sets / gets an atlas texture on `barTexture`.

#### `SetTexCoord(L, R, T, B)` / `GetTexCoord()`
Sets / gets texture coordinates on `barTexture`.

#### `SetMaskTexture(...)` / `GetMaskTexture()`
Sets the texture of `barTextureMask`. Requires `CreateTextureMask()` to have been called (already done by the constructor).

#### `SetMaskAtlas(atlasName)` / `GetMaskAtlas()`
Sets the atlas of `barTextureMask`.

#### `AddMaskTexture(textureObject)`
Applies `barTextureMask` to an additional texture object, causing it to be clipped by the same mask as the bar fill.

#### `SetBorderTexture(texture)` / `GetBorderTexture()`
Shows or hides `barBorderTextureForMask` (overlay subLevel 7, `SetAllPoints`). Pass `nil` or `""` to hide.

---

### Tick

#### `OnTick(self, deltaTime)` *(stub)*
```lua
-- Default implementation does nothing.
-- To use it, set Settings.CanTick = true in settingsOverride:
local hb = DF:CreateHealthBar(parent, nil, { CanTick = true })
function hb:OnTick(deltaTime)
    -- runs every frame
end
```
Called by the `OnUpdate` script when `Settings.CanTick == true`. The bar installs the script during `SetUnit` when a unit is bound.

---

### Initialization

#### `Initialize()`
Called automatically at the end of `CreateHealthBar`. Should not normally be called manually. Sets pixel-aligned width/height, applies all texture settings, resets state (`SetUnit(nil)`), and sets `currentHealth = 1, currentHealthMax = 2` as safe initial values.

---

## 5. Hook System

The health bar uses `ScriptHookMixin` (same as other DetailsFramework widgets). Hooks are stored in `healthBar.HookList`, a per-instance private copy.

### Available hook events

| Hook name | Callback signature | Fired when |
|---|---|---|
| `OnHealthChange` | `(healthBar, displayedUnit)` | Health changes (`UpdateHealth` completes). |
| `OnHealthMaxChange` | `(healthBar, displayedUnit)` | Max health changes (`UpdateMaxHealth` completes). |
| `OnAbsorbOverflow` | `(healthBar, displayedUnit, overflowFraction)` | Shield amount exceeds missing health. `overflowFraction` = how far past 100% the shield extends (0.0–1.0+). Fires `0` when overflow ends. Throttled to once per 0.2 s. |
| `OnHide` | `(healthBar)` | Frame is hidden. |
| `OnShow` | `(healthBar)` | Frame is shown. |

### Direct callback override vs `SetHook`

Methods with a hook also support **direct function replacement** for single-callback performance:

```lua
-- Direct override (replaces hook dispatch entirely for this event):
healthBar.OnHealthChange = function(self, unit)
    print("Health changed:", self.currentHealth)
end

-- Additive hook (multiple callbacks can coexist):
healthBar:SetHook("OnHealthChange", function(hb, unit)
    print("Health changed:", hb.currentHealth)
end)
```

Inside `UpdateHealth` and `UpdateMaxHealth`, the code checks `if (self.OnHealthChange) then` first. If a direct function is assigned, it is called directly and the `RunHooksForWidget` path is skipped.

---

## 6. Registered Events

`SetUnit` registers these events. Events flagged `(unit event)` are registered via `RegisterUnitEvent`; others via `RegisterEvent`.

| Event | Unit event? | Handler | Notes |
|---|---|---|---|
| `PLAYER_ENTERING_WORLD` | No | `PLAYER_ENTERING_WORLD` | Calls all three update functions on world load / instance travel. |
| `UNIT_HEALTH` | Yes | `UNIT_HEALTH` | Calls `UpdateHealth` + `UpdateHealPrediction`. |
| `UNIT_MAXHEALTH` | Yes | `UNIT_MAXHEALTH` | Calls `UpdateMaxHealth` + `UpdateHealth` + `UpdateHealPrediction`. |
| `UNIT_HEALTH_FREQUENT` | Yes | `UNIT_HEALTH_FREQUENT` | Classic-only. Calls `UpdateHealth` + `UpdateHealPrediction`. |
| `UNIT_HEAL_PREDICTION` | Yes | `UNIT_HEAL_PREDICTION` | Calls all three updates. |
| `UNIT_ABSORB_AMOUNT_CHANGED` | Yes | `UNIT_ABSORB_AMOUNT_CHANGED` | Mainline/MoP+. Calls all three updates. |
| `UNIT_HEAL_ABSORB_AMOUNT_CHANGED` | Yes | `UNIT_HEAL_ABSORB_AMOUNT_CHANGED` | Mainline/MoP+. Calls all three updates. |

When `Settings.ShowHealingPrediction == false`:
- `UNIT_HEAL_PREDICTION` is unregistered.
- `UNIT_HEAL_ABSORB_AMOUNT_CHANGED` is unregistered (mainline only).

When `Settings.ShowShields == false`:
- `UNIT_ABSORB_AMOUNT_CHANGED` is unregistered (mainline only).

---

## 7. Rendering and Layout

### Frame hierarchy

```
healthBar (StatusBar, BackdropTemplate)
├── background (background layer, subLevel -6)    — solid-color backdrop
├── barTexture (artwork layer, subLevel 1)         — fill texture, registered as StatusBarTexture
├── incomingHealIndicator (artwork, subLevel 5)    — incoming heal overlay
├── healAbsorbIndicator (artwork, subLevel 4)      — heal-absorb debuff overlay
├── shieldAbsorbIndicator (artwork, subLevel 3)    — damage-absorb (shield) overlay
├── shieldAbsorbGlow (artwork, subLevel 6)         — absorb-overflow glow (ADD blend)
├── barTextureMask (mask)                          — clips fill and background to bar shape
└── barBorderTextureForMask (overlay, subLevel 7)  — optional border (hidden by default)
```

### Fill direction

The health bar uses the default left-to-right StatusBar fill. There is no built-in `SetDirection` on the health bar (unlike `df_timebar`). Fill direction can be changed via the native WoW API: `healthBar:SetReverseFill(true)`.

### Indicator positioning

Each overlay indicator is positioned dynamically inside `UpdateHealPrediction`:

```
indicator:SetPoint("topleft",    healthBar, "topleft",    width * healthPercent, 0)
indicator:SetPoint("bottomleft", healthBar, "bottomleft", width * healthPercent, 0)
indicator:SetWidth(clampedWidth)
```

Where `healthPercent = currentHealth / currentHealthMax`. The indicator starts at the right edge of the health fill and extends rightward into the empty portion.

Width is clamped to prevent overflow past the bar boundary:
```
clampedWidth = max(1, min(width * indicatorPercent, abs(healthPercent - 1) * width))
```

### Shield glow

`shieldAbsorbGlow` is anchored to the **right edge** of the bar:
```lua
shieldAbsorbGlow:SetPoint("topright", self, "topright", 8, 0)
shieldAbsorbGlow:SetPoint("bottomright", self, "bottomright", 8, 0)
shieldAbsorbGlow:SetBlendMode("ADD")
```
It is shown only when `healthPercent + damageAbsorbPercent > 1` (i.e., the shield overflows past 100% health), providing a visual "overshield" effect that protrudes beyond the bar's right edge.

---

## 8. Update Flow

```
WoW fires unit event (e.g., UNIT_HEALTH)
        │
        ▼
OnEvent(self, event, ...)
  → looks up self[event]
  → calls eventFunc(self, ...)
        │
        ▼
UNIT_HEALTH(self, unitId)
  → UpdateHealth()
      → UnitHealth(displayedUnit)
      → saves oldHealth, currentHealth, missing, percent
      → PixelUtil.SetStatusBarValue(self, health)
      → fires OnHealthChange hook
  → UpdateHealPrediction()
      → UnitGetIncomingHeals, UnitGetTotalHealAbsorbs, UnitGetTotalAbsorbs
      → repositions/resizes indicator textures
      → fires OnAbsorbOverflow if overflow detected

UNIT_MAXHEALTH(self, unitId)
  → UpdateMaxHealth()
      → UnitHealthMax(displayedUnit)
      → SetMinMaxValues(0, maxHealth)
      → fires OnHealthMaxChange hook
  → UpdateHealth()
  → UpdateHealPrediction()

PLAYER_ENTERING_WORLD(self, unit, displayedUnit)
  → UpdateMaxHealth()
  → UpdateHealth()
  → UpdateHealPrediction()
```

---

## 9. Practical Usage Patterns

### Standalone health bar

```lua
local hb = DF:CreateHealthBar(myParentFrame, "MyAddonHealthBar")
hb:SetPoint("topleft", myParentFrame, "topleft", 4, -4)
hb:SetSize(200, 20)

-- Bind to a unit (starts tracking immediately)
hb:SetUnit("target")

-- Unbind
hb:SetUnit(nil)
```

---

### Health bar with custom texture and color

```lua
local hb = DF:CreateHealthBar(parent, "MyHB", {
    Texture = SharedMedia:Fetch("statusbar", "Smooth"),
    Width   = 180,
    Height  = 16,
})
hb:SetPoint("center", parent, "center")
hb:SetColor(0.2, 0.9, 0.2, 1)  -- bright green
hb:SetUnit("player")
```

---

### Disable healing prediction overlays

```lua
local hb = DF:CreateHealthBar(parent, nil, {
    ShowHealingPrediction = false,
    ShowShields           = false,
})
hb:SetUnit("focus")
```

---

### React to health changes via hook

```lua
local hb = DF:CreateHealthBar(parent, "MyHB")
hb:SetHook("OnHealthChange", function(self, unit)
    if self.currentHealthPercent < 30 then
        self:SetColor(1, 0, 0)   -- red when low
    else
        self:SetColor(0.2, 0.9, 0.2)
    end
end)
hb:SetUnit("target")
```

---

### React to absorb overflow

```lua
local hb = DF:CreateHealthBar(parent, "MyHB")
hb:SetHook("OnAbsorbOverflow", function(self, unit, overflowFraction)
    if overflowFraction > 0 then
        print(unit, "has an overshield covering", overflowFraction * 100, "% extra!")
    end
end)
hb:SetUnit("target")
```

---

### Per-frame tick (for a custom animation or text)

```lua
local hb = DF:CreateHealthBar(parent, "MyHB", { CanTick = true })
function hb:OnTick(deltaTime)
    -- update a custom FontString with live health text every frame
    myText:SetText(self.currentHealth .. " / " .. self.currentHealthMax)
end
hb:SetUnit("player")
```

---

### As part of a unit frame (internal usage)

Inside `CreateUnitFrame`, the health bar is created and stored on the unit frame:

```lua
local healthBar = DF:CreateHealthBar(unitFrame, nil, healthBarSettingsOverride)
healthBar:SetFrameLevel(baseFrameLevel + 1)
unitFrame.healthBar = healthBar
```

From a plugin or callback, access it via:

```lua
unitFrame.healthBar:SetColor(r, g, b)
unitFrame.healthBar:SetTexture(myTexture)
unitFrame.healthBar:SetUnit(unit)  -- called separately from unitFrame:SetUnit()
```

---

## 10. Differences from a Standard StatusBar

| Feature | WoW `StatusBar` | `df_healthbar` |
|---|---|---|
| Value update | Manual (`SetValue`) | Automatic on `UNIT_HEALTH` event |
| Min/max | Arbitrary | Always `0` to `UnitHealthMax` |
| Incoming heal overlay | Not built-in | Built-in (`incomingHealIndicator`) |
| Heal absorb overlay | Not built-in | Built-in (`healAbsorbIndicator`) |
| Shield absorb overlay | Not built-in | Built-in (`shieldAbsorbIndicator` + `shieldAbsorbGlow`) |
| Texture management | `SetStatusBarTexture` | `SetTexture` / `GetTexture` wrappers via `StatusBarFunctions` |
| Color | `SetStatusBarColor` | `SetColor` (wraps `ParseColors` + `SetStatusBarColor`) |
| Masking | Manual | Built-in via `CreateTextureMask()` |
| Event handling | Manual | Automatic via `SetUnit` |
| Callbacks | WoW scripts only | `SetHook` system (`OnHealthChange`, `OnHealthMaxChange`, `OnAbsorbOverflow`, etc.) |

---

---

# DetailsFramework — Cast Bar System

> **Scope**: This section covers only the `df_castbar` object.  
> Health bar, power bar, and unit frame are documented separately.

---

## Overview

`unitframe.lua` implements `df_castbar`, a `StatusBar`-based widget that tracks a WoW unit's active spell casts and channels in real time. It:

- Registers WoW unit events for cast start, stop, interrupt, delay, fail, and interrupt-state changes.
- Advances the bar fill each frame via `OnUpdate` using elapsed or remaining time.
- Supports three cast modes: **regular casting** (fills forward), **channeling** (drains backward), and **empowered channeling** (fills forward with per-stage pip markers).
- Plays configurable fade-in, fade-out, and flash animations on cast state transitions.
- Schedules a brief hide delay after interrupts and failures so the player sees feedback before the bar disappears.
- Exposes a hook for `OnCastStart` and WoW-script-level hooks for `OnHide`/`OnShow`.

The cast bar is usable as a **standalone widget** (attach to any frame, call `SetUnit`) or as a sub-component of a `df_unitframe` (`unitFrame.castBar`).

---

## 1. Entry Point — `CreateCastBar`

```lua
local castBar = detailsFramework:CreateCastBar(
    parent,           -- (frame)   Parent WoW frame.
    name,             -- (string?) Absolute global name for the StatusBar. If nil, uses parent:GetName() .. "CastBar".
    settingsOverride  -- (table?)  Key/value pairs to override defaults from df_castbarsettings.
)
-- Returns: df_castbar
```

**Requirement**: either `name` is provided, or `parent` must have a global name. Violating this triggers a Lua error.

### Initialization sequence

1. A WoW `StatusBar` (with `BackdropTemplate`) is created as the base frame.
2. Child textures and FontStrings are created (see §5 — Frame Hierarchy).
3. Two animation groups are created:
   - `fadeOutAnimation` — alpha 1→0 over `Settings.FadeOutTime`.
   - `fadeInAnimation` — alpha 0→1 over `Settings.FadeInTime`.
4. A flash animation (`flashAnimation`) is created on `flashTexture`: alpha 0→0.8 then 1→0 over two 0.2 s steps. Starts/ends with `flashTexture:Show()`/`flashTexture:Hide()`.
5. Two mixins are applied:
   - `CastFrameFunctions` — all cast-bar-specific methods and event handlers.
   - `detailsFramework.StatusBarFunctions` — texture/color/mask helpers.
6. A `TextureMask` is created; `flashTexture`, `background`, and `extraBackground` are all enrolled in it.
7. A seed texture is set (`Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT`) as the initial status bar texture.
8. A **private copy** of `CastFrameFunctions.Settings` is made and merged with `settingsOverride`, stored as `castBar.Settings`.
9. The Spark's initial anchor is set to `("CENTER", barTexture, "RIGHT", Settings.SparkOffset, 0)`.
10. A **private copy** of `CastFrameFunctions.HookList` is stored as `castBar.HookList`.
11. `castBar:Initialize()` is called — sets pixel-aligned width/height, applies all texture/color/size settings, configures animations, and calls `SetUnit(nil)` to clear state.

---

## 2. Object Structure (`df_castbar`)

A `df_castbar` **is** a WoW `StatusBar` frame with additional fields mixed in. Methods are available directly on the frame object.

### Cast state fields

| Field | Type | Description |
|---|---|---|
| `WidgetType` | `"castBar"` | Component type identifier. |
| `unit` | `string?` | Unit token currently tracked (e.g. `"target"`). `nil` when unbound. |
| `displayedUnit` | `string?` | Unit whose cast data is read. Equals `unit` unless set differently via `SetUnit`. |
| `casting` | `boolean?` | `true` during a regular (non-channel) cast. |
| `channeling` | `boolean?` | `true` during a channel or empowered channel. |
| `interrupted` | `boolean?` | `true` after `UNIT_SPELLCAST_INTERRUPTED`. |
| `failed` | `boolean?` | `true` after `UNIT_SPELLCAST_FAILED`. |
| `finished` | `boolean?` | `true` after the cast completes, is interrupted, or fails. |
| `canInterrupt` | `boolean?` | `true` if the current cast can be interrupted. |

### Spell info fields

| Field | Type | Description |
|---|---|---|
| `spellID` | `spellid?` | Numeric ID of the current spell. |
| `castID` | `number?` | WoW-assigned unique ID for the specific cast instance. Used to match stop/interrupt events to the correct cast. |
| `spellName` | `string?` | Display name of the current spell. |
| `spellTexture` | `textureid?` | Icon texture ID for the current spell. |
| `spellStartTime` | `number?` | `GetTime()` value when the cast started (converted from ms). |
| `spellEndTime` | `number?` | `GetTime()` value when the cast will end (converted from ms). |

### Progress tracking fields

| Field | Type | Description |
|---|---|---|
| `value` | `number` | Current progress position in the StatusBar's 0–`maxValue` range. Driven by `OnTick`. |
| `maxValue` | `number` | Total duration of the current cast in seconds (`spellEndTime - spellStartTime`). |
| `lazyUpdateCooldown` | `number` | Accumulator for throttling the lazy tick (resets to `Settings.LazyUpdateCooldown`). |
| `scheduledHideTime` | `C_Timer.NewTimer?` | Active hide timer object (used after interrupts/failures). Cleared when the timer fires. |

### Empowered cast fields (mainline only)

| Field | Type | Description |
|---|---|---|
| `empowered` | `boolean?` | `true` if the current channel is an empowered spell. |
| `curStage` | `number?` | Current empowered stage index (1-based). |
| `numStages` | `number?` | Total number of empowered stages. |
| `empStages` | `{start:number, finish:number}[]?` | Per-stage time ranges in seconds relative to cast start. |
| `holdAtMaxTime` | `number?` | Extra hold time (ms) at max empowerment before the spell fires. |
| `stagePips` | `texture[]` | Overlay texture markers for each empowered stage boundary. Created on demand. |
| `reverseChanneling` | `boolean?` | `true` when an empowered channel fills forward instead of draining. |

### Settings and hooks

| Field | Type | Description |
|---|---|---|
| `Settings` | `df_castbarsettings` | Per-instance settings (private copy). |
| `HookList` | `table` | Per-instance hook registry (private copy). |
| `Colors` | `df_castcolors` | Reference to `Settings.Colors` (set during `Initialize`). |

### Child UI elements

| Field | Type | Layer / Sub-level | Description |
|---|---|---|---|
| `background` | `texture` | background, `-6` | Solid-color backdrop. |
| `extraBackground` | `texture` | background, `-5` | Secondary backdrop (also solid color, drawn above `background`). |
| `barTexture` | `texture` | artwork, `-6` | Fill texture, registered as `SetStatusBarTexture`. |
| `Text` | `fontstring` | overlay, `1` | Spell name label, anchored center. Font: `SystemFont_Shadow_Small`. |
| `BorderShield` | `texture` | overlay, `5` | Non-interruptible shield badge at the left edge. Hidden when interruptible. |
| `Icon` | `texture` | overlay, `4` | Spell icon, anchored 2 px from the left edge. |
| `Spark` | `texture` | overlay, `3` | Leading-edge spark (ADD blend), anchored to the right edge of `barTexture`. |
| `percentText` | `fontstring` | overlay, `7` | Countdown text (right-aligned). Shown only when `ShowCastTime` and `CanLazyTick` are both `true`. |
| `flashTexture` | `texture` | overlay, `7` | Full-bar white ADD flash, shown briefly on cast completion. |
| `fadeOutAnimation` | `animationgroup` | — | AnimationGroup playing on cast end/fade-out. |
| `fadeInAnimation` | `animationgroup` | — | AnimationGroup playing on cast start/fade-in. |
| `flashAnimation` | `animationgroup` | — | AnimationGroup driving `flashTexture` on cast completion. |
| `barTextureMask` | mask | — | Clips bar fill and overlays to bar shape. |
| `barBorderTextureForMask` | `texture` | overlay, `7` | Optional border, hidden by default. |

---

## 3. Settings (`df_castbarsettings`)

Override any key via `settingsOverride` in `CreateCastBar`.

| Key | Type | Default | Effect |
|---|---|---|---|
| `NoFadeEffects` | `boolean` | `false` | When `true`, skips fade-in/fade-out animations; uses a brief `ScheduleToHide(0.3)` instead. |
| `ShowTradeSkills` | `boolean` | `false` | When `false`, casts with `isTradeSkill = true` are ignored and the bar stays hidden. |
| `ShowShield` | `boolean` | `true` | When `true`, shows `BorderShield` for non-interruptible casts. |
| `CanTick` | `boolean` | `true` | When `true`, installs `OnUpdate` calling `OnTick(deltaTime)` each frame while a unit is bound. |
| `ShowCastTime` | `boolean` | `true` | When `true` (and `CanLazyTick` is `true`), shows a countdown in `percentText` formatted as `"%.1f"` seconds. |
| `FadeInTime` | `number` | `0.1` | Duration in seconds for the fade-in animation. |
| `FadeOutTime` | `number` | `0.5` | Duration in seconds for the fade-out animation. |
| `CanLazyTick` | `boolean` | `true` | When `true`, enables the lazy tick (runs at most once per `LazyUpdateCooldown` interval). |
| `LazyUpdateCooldown` | `number` | `0.2` | Interval in seconds between lazy ticks. |
| `DontUpdateAlpha` | `boolean` | `false` | When `true`, the cast bar never calls `SetAlpha(1)` during cast start. Useful for custom alpha management. |
| `ShowEmpoweredDuration` | `boolean` | `true` | When `true`, adds the hold-at-max time (`holdAtMaxTime`) to the total cast duration for empowered spells. |
| `FillOnInterrupt` | `boolean` | `true` | When `true`, fills the bar to 100% on `UNIT_SPELLCAST_INTERRUPTED`. |
| `HideSparkOnInterrupt` | `boolean` | `true` | When `true`, hides the spark when the cast is interrupted. |
| `Width` | `number` | `100` | Initial width set by `Initialize`. |
| `Height` | `number` | `20` | Initial height set by `Initialize`. |
| `Colors` | `df_castcolors` | *(see below)* | Color table for each cast stage. |
| `BackgroundColor` | `df_colortable` | `(0.2, 0.2, 0.2, 0.8)` | Color for both background textures. |
| `Texture` | `texturepath\|textureid` | `Interface\TargetingFrame\UI-StatusBar` | Fill texture applied during `Initialize`. |
| `BorderShieldWidth` | `number` | `10` | Width of `BorderShield` texture. |
| `BorderShieldHeight` | `number` | `12` | Height of `BorderShield` texture. |
| `BorderShieldCoords` | `table` | `{0.26, 0.32, 0.53, 0.66}` | TexCoords for `BorderShield`. |
| `BorderShieldTexture` | `textureid` | `1300837` | Texture ID for `BorderShield`. |
| `SpellIconWidth` | `number` | `10` | Initial width of `Icon`. |
| `SpellIconHeight` | `number` | `10` | Initial height of `Icon`. |
| `SparkTexture` | `texturepath` | `Interface\CastingBar\UI-CastingBar-Spark` | Texture for the spark. |
| `SparkWidth` | `number` | `16` | Spark width in pixels. |
| `SparkHeight` | `number` | `16` | Spark height in pixels. |
| `SparkOffset` | `number` | `0` | X offset for the spark relative to the right edge of `barTexture`. |

### Default Colors (`df_castcolors`)

| Key | Default RGBA | Used when |
|---|---|---|
| `Casting` | `(1.0, 0.73, 0.1, 1)` — gold | Regular cast, interruptible |
| `Channeling` | `(1.0, 0.73, 0.1, 1)` — gold | Channeling, interruptible |
| `Empowered` | `(1.0, 0.73, 0.1, 1)` — gold | Empowered channeling |
| `Finished` | `(0.0, 1.0, 0.0, 1)` — green | Cast completed (stop events) |
| `NonInterruptible` | `(0.7, 0.7, 0.7, 1)` — grey | `canInterrupt == false` |
| `Failed` | `(0.4, 0.4, 0.4, 1)` — dark grey | `UNIT_SPELLCAST_FAILED` |
| `Interrupted` | `(0.97, 0.75, 0.15, 1)` — amber | `UNIT_SPELLCAST_INTERRUPTED` |

---

## 4. Methods

All methods are called on the `df_castbar` frame object.

### Unit binding

#### `SetUnit(unit, displayedUnit?)`
```lua
castBar:SetUnit("target")
castBar:SetUnit("nameplate1", "nameplate1")
castBar:SetUnit(nil)  -- unbind
```
- Binds the cast bar to a unit. Registers all events in `CastBarEvents`, sets `OnEvent`, `OnShow`, `OnHide`, and (if `CanTick`) `OnUpdate` scripts.
- When `unit` is `nil`, unregisters all events, removes all scripts, and hides the bar.
- Calls `CancelScheduleToHide()` to clear any pending hide timer.
- After binding, calls `OnEvent("PLAYER_ENTERING_WORLD", unit, unit)` to pick up any cast already in progress.
- Calling `SetUnit` with the exact same `unit` and `displayedUnit` is a **no-op** (deduplication guard).

---

### Color management

#### `SetDefaultColor(colorType, r, g, b, a)`
```lua
castBar:SetDefaultColor("Casting", 0.2, 0.8, 1, 1)     -- RGBA
castBar:SetDefaultColor("Interrupted", "orange")         -- named color
castBar:SetDefaultColor("NonInterruptible", {0.5, 0.5, 0.5, 1})
```
- `colorType` must be one of: `"Casting"`, `"Channeling"`, `"Interrupted"`, `"Failed"`, `"NonInterruptible"`, `"Finished"`, `"Empowered"`.
- Calls `self.Colors[colorType]:SetColor(r, g, b, a)`.
- Does **not** immediately update the bar's current color. Call `UpdateCastColor()` afterward if a cast is active.

#### `GetCastColor()`
```lua
local colorTable = castBar:GetCastColor()
```
Returns the appropriate `df_colortable` from `self.Colors` based on the current cast state. Priority order:
1. `NonInterruptible` — if `canInterrupt == false`
2. `Empowered` — if `empowered == true`
3. `Channeling` — if `channeling == true`
4. `Failed` — if `failed == true`
5. `Interrupted` — if `interrupted == true`
6. `Finished` — if `finished == true`
7. `Casting` — default

#### `UpdateCastColor()`
```lua
castBar:UpdateCastColor()
```
Calls `GetCastColor()` and applies the result via `SetColor`. Use after changing colors mid-cast or after updating the cast state manually.

---

### Cast validation

#### `IsValid(unit, castName, isTradeSkill, ignoreVisibility?)`
```lua
local ok = castBar:IsValid(unit, name, isTradeSkill, true)
```
Internal guard called before processing any cast start. Returns `false` (and prevents the bar from showing) if:
- `ignoreVisibility` is false and the bar is hidden.
- `Settings.ShowTradeSkills == false` and `isTradeSkill == true`.
- `castName` is nil.

---

### Cast state queries

#### `HasScheduledHide()`
```lua
local pending = castBar:HasScheduledHide()  -- boolean
```
Returns `true` if a `C_Timer` hide is scheduled and not yet cancelled.

---

### Animation and hide scheduling

#### `ScheduleToHide(delay)`
```lua
castBar:ScheduleToHide(1)     -- hide after 1 second (used after interrupts/failures)
castBar:ScheduleToHide(0.3)   -- hide after 0.3 s (used with NoFadeEffects)
castBar:ScheduleToHide(false) -- cancel any pending scheduled hide
```
- Schedules a `C_Timer.NewTimer` to hide the cast bar after `delay` seconds.
- When the timer fires (`DoScheduledHide`), the bar is only hidden if it is not actively casting or channeling.
- If `NoFadeEffects` is `false`, `Animation_FadeOut` plays; otherwise `Hide()` is called directly.
- Calling with `false` or no delay cancels any existing scheduled hide.

#### `CancelScheduleToHide()`
```lua
castBar:CancelScheduleToHide()
```
Cancels the pending hide timer if one exists.

#### `Animation_FadeIn()`
Stops any active fade-out, starts the fade-in animation group. Called when a new cast begins and the bar is not yet visible. Calls `CancelScheduleToHide` first.

#### `Animation_FadeOut()`
Stops any active fade-in, starts the fade-out animation group. Called when a cast ends normally. Calls `ScheduleToHide(false)` first (cancels any pending timer).

#### `Animation_Flash()`
Plays the `flashAnimation` on `flashTexture`, giving a brief full-bar white flash on cast completion.

#### `Animation_StopAllAnimations()`
Stops all three animation groups (`flashAnimation`, `fadeOutAnimation`, `fadeInAnimation`) immediately.

---

### Internal state updaters

These are called by event handlers and should not normally be called directly.

#### `UpdateCastingInfo(unit, ...)`
Processes a regular cast start:
- Calls `CastInfo.UnitCastingInfo(unit)` (WoW API wrapper).
- Converts `startTime`/`endTime` from milliseconds to seconds.
- Sets `casting = true`, clears `channeling`, `interrupted`, `failed`, `finished`.
- Sets `canInterrupt`, `spellID`, `castID`, `spellName`, `spellTexture`.
- Sets `value = GetTime() - spellStartTime` (elapsed time since cast start).
- Sets `maxValue = spellEndTime - spellStartTime` (total cast duration).
- Calls `SetMinMaxValues(0, maxValue)` and `SetValue(value)`.
- Updates `Icon`, `Text`, `Spark`, calls `UpdateCastColor()` and `UpdateInterruptState()`.
- Plays `Animation_FadeIn` if the bar was hidden.

#### `UpdateChannelInfo(unit, ...)`
Processes a channel or empowered channel start:
- Calls `CastInfo.UnitChannelInfo(unit)`.
- Checks `numStages` to determine if empowered.
- For empowered casts: populates `empStages`, `numStages`, `holdAtMaxTime`; adds `holdAtMaxTime` to `endTime` if `ShowEmpoweredDuration` is enabled.
- Sets `channeling = true`, clears `casting`.
- **For regular channels**: `value = spellEndTime - GetTime()` (drains down to 0).
- **For empowered channels**: `value = GetTime() - spellStartTime` (fills up like a cast).
- Sets `reverseChanneling = self.empowered`.
- Calls `CreateOrUpdateEmpoweredPips` to add/update pip markers.
- Updates Icon, Text, Spark, calls `UpdateCastColor()` and `UpdateInterruptState()`.

#### `UpdateInterruptState()`
Shows `BorderShield` when `Settings.ShowShield == true` and `canInterrupt == false`. Hides it otherwise.

#### `CheckCastIsDone(event?, isFinished?)`
Called each frame from `OnTick`. Checks whether `value` has reached the boundary (`>= maxValue` for casting; `<= 0` or `> maxValue` for channeling). When done, calls `UNIT_SPELLCAST_STOP` or `UNIT_SPELLCAST_CHANNEL_STOP` directly. Returns `true` if the cast ended.

---

### Tick functions

#### `OnTick(self, deltaTime)`
Main `OnUpdate` handler, called every frame when `CanTick = true` and a unit is bound. Dispatches to `OnTick_Casting` or `OnTick_Channeling`, then decrements `lazyUpdateCooldown` and calls `OnTick_LazyTick` when it reaches zero.

#### `OnTick_Casting(self, deltaTime)`
Increments `value` by `deltaTime`. Calls `CheckCastIsDone()`. If not done, calls `SetValue(value)`. Returns `true` to allow the lazy tick.

#### `OnTick_Channeling(self, deltaTime)`
- **Regular channel**: decrements `value` by `deltaTime` (drains to 0).
- **Empowered channel**: increments `value` by `deltaTime` (fills to `maxValue`).
- Calls `CheckCastIsDone()`. If not done, calls `SetValue(value)` and `CreateOrUpdateEmpoweredPips()`.
- Returns `true` to allow the lazy tick.

#### `OnTick_LazyTick(self)`
Updates `percentText` countdown display:
- **Casting**: `format("%.1f", abs(value - maxValue))` — time remaining.
- **Channeling (regular)**: `format("%.1f", abs(value))` — remaining channel time.
- **Channeling (empowered)**: `format("%.1f", abs(value - maxValue))` — time remaining to max.
- Values > 999 display as `""`.
- Returns `true` if `CanLazyTick` is set.

---

### Empowered pips

#### `CreateOrUpdateEmpoweredPips(unit?, numStages?, startTime?, endTime?)`
Creates or repositions the `stagePips` texture array. Each pip is:
- Overlay texture, ADD blend, texture `Interface\CastingBar\UI-CastingBar-Spark`, cropped to a 2×`height` vertical marker.
- Positioned at `width * curEndTime / (endTime - startTime) * 1000` pixels from the left.

Called during `UpdateChannelInfo` and each frame from `OnTick_Channeling`.

---

### Texture and color (from `StatusBarFunctions` mixin)

Identical to the health bar (see Health Bar §4). The cast bar exposes the same set of methods:

`SetTexture`, `GetTexture`, `ResetTexture`, `SetColor`, `GetColor`, `SetVertexColor`, `GetVertexColor`, `SetDesaturated`, `SetDesaturation`, `IsDesaturated`, `SetAtlas`, `GetAtlas`, `SetTexCoord`, `GetTexCoord`, `SetMaskTexture`, `GetMaskTexture`, `SetMaskAtlas`, `GetMaskAtlas`, `AddMaskTexture`, `CreateTextureMask`, `HasTextureMask`, `SetBorderTexture`, `GetBorderTexture`.

---

## 5. Hook System

The cast bar uses `ScriptHookMixin`. Hooks are stored in `castBar.HookList` (per-instance private copy).

### Available hook events

| Hook name | Callback signature | Fired when |
|---|---|---|
| `OnCastStart` | `(castBar, unit, eventName)` | `UNIT_SPELLCAST_START` or `UNIT_SPELLCAST_CHANNEL_START` fires and the cast is accepted. `eventName` is the WoW event string. |
| `OnHide` | `(castBar, unit)` | Frame is hidden (WoW script hook via `SetHook`). |
| `OnShow` | `(castBar, unit)` | Frame is shown (WoW script hook via `SetHook`). |

```lua
castBar:SetHook("OnCastStart", function(self, unit, eventName)
    print(unit, "started a cast:", self.spellName, "event:", eventName)
end)
```

---

## 6. Registered Events

`SetUnit` registers these events. Events flagged `(unit event)` are registered via `RegisterUnitEvent`; others via `RegisterEvent`.

| Event | Unit event? | Handler | Notes |
|---|---|---|---|
| `PLAYER_ENTERING_WORLD` | No | `PLAYER_ENTERING_WORLD` | Detects casts already in progress on world enter/instance travel. |
| `UNIT_SPELLCAST_START` | Yes | `UNIT_SPELLCAST_START` → `UpdateCastingInfo` | Begins a regular cast. |
| `UNIT_SPELLCAST_STOP` | Yes | `UNIT_SPELLCAST_STOP` | Ends a regular cast (normal completion). |
| `UNIT_SPELLCAST_FAILED` | Yes | `UNIT_SPELLCAST_FAILED` | Cast failed; schedules hide after 1 s. |
| `UNIT_SPELLCAST_INTERRUPTED` | No | `UNIT_SPELLCAST_INTERRUPTED` | Cast interrupted; schedules hide after 1 s. |
| `UNIT_SPELLCAST_DELAYED` | No | `UNIT_SPELLCAST_DELAYED` | Cast delayed; updates `startTime`/`endTime`. |
| `UNIT_SPELLCAST_CHANNEL_START` | No | `UNIT_SPELLCAST_CHANNEL_START` → `UpdateChannelInfo` | Begins a channel. |
| `UNIT_SPELLCAST_CHANNEL_UPDATE` | No | `UNIT_SPELLCAST_CHANNEL_UPDATE` | Channel timing updated; recalculates `value`/`maxValue`. |
| `UNIT_SPELLCAST_CHANNEL_STOP` | No | `UNIT_SPELLCAST_CHANNEL_STOP` | Channel ended. |
| `UNIT_SPELLCAST_EMPOWER_START` | No | → `UNIT_SPELLCAST_CHANNEL_START` | Mainline only. Delegates to channel start. |
| `UNIT_SPELLCAST_EMPOWER_UPDATE` | No | → `UNIT_SPELLCAST_CHANNEL_UPDATE` | Mainline only. |
| `UNIT_SPELLCAST_EMPOWER_STOP` | No | → `UNIT_SPELLCAST_CHANNEL_STOP` | Mainline only. |
| `UNIT_SPELLCAST_INTERRUPTIBLE` | No | `UNIT_SPELLCAST_INTERRUPTIBLE` | `canInterrupt = true`; updates color + shield. Mainline only. |
| `UNIT_SPELLCAST_NOT_INTERRUPTIBLE` | No | `UNIT_SPELLCAST_NOT_INTERRUPTIBLE` | `canInterrupt = false`; updates color + shield. Mainline only. |

---

## 7. Cast Modes — Casting vs Channeling

### Regular cast (`casting = true`)

| Property | Value |
|---|---|
| `value` initial | `GetTime() - spellStartTime` (elapsed since start) |
| `value` direction | Increments by `deltaTime` each frame |
| Completion | `value >= maxValue` |
| `SetMinMaxValues` | `(0, maxValue)` |
| Bar fill | Left → right (fills as cast progresses) |

### Regular channeling (`channeling = true, empowered = false`)

| Property | Value |
|---|---|
| `value` initial | `spellEndTime - GetTime()` (remaining time) |
| `value` direction | Decrements by `deltaTime` each frame |
| Completion | `value <= 0` or `value > maxValue` |
| `SetMinMaxValues` | `(0, maxValue)` |
| Bar fill | Right → left (drains as channel progresses) |

### Empowered channeling (`channeling = true, empowered = true`)

| Property | Value |
|---|---|
| `value` initial | `GetTime() - spellStartTime` (elapsed) |
| `value` direction | Increments by `deltaTime` (fills like a cast) |
| Completion | `value >= maxValue` |
| `SetMinMaxValues` | `(0, maxValue)` |
| Bar fill | Left → right |
| Extra | Stage pip markers; `holdAtMaxTime` extends duration |

---

## 8. Rendering and Layout

### Frame hierarchy

```
castBar (StatusBar, BackdropTemplate)
├── background (background, -6)            — dark solid color backdrop
├── extraBackground (background, -5)       — secondary solid color backdrop (same color)
├── barTexture (artwork, -6)               — fill texture, registered as StatusBarTexture
├── Text (overlay, 1)                      — spell name label, centered
├── BorderShield (overlay, 5)             — non-interruptible shield badge (hidden when interruptible)
├── Icon (overlay, 4)                      — spell icon at left edge
├── Spark (overlay, 3)                     — leading-edge spark (ADD blend)
├── percentText (overlay, 7)               — countdown text, right-aligned
├── flashTexture (overlay, 7, ADD blend)   — full-bar flash effect
├── stagePips[] (overlay, 2, ADD blend)    — empowered stage markers (mainline only)
├── barTextureMask (mask)                  — clips fill and enrolled textures
└── barBorderTextureForMask (overlay, 7)   — optional border (hidden by default)
```

### Spark positioning

The `Spark` is anchored to the right edge of `barTexture`:
```lua
Spark:SetPoint("CENTER", barTexture, "RIGHT", Settings.SparkOffset, 0)
```
Because `barTexture` is the StatusBar's fill texture, it automatically tracks the fill edge. This anchor is set once during `UpdateCastingInfo` / `UpdateChannelInfo`, and again during `Initialize`.

### Fill direction

- **Regular cast**: the StatusBar fills left-to-right by default. No `SetReverseFill` is called.
- **Regular channel**: the value drains from `maxValue` → 0, so the bar visually drains right-to-left.
- **Empowered channel**: fills like a regular cast (value increases 0 → `maxValue`).

### Cast time text (`percentText`)

Visible only when both `ShowCastTime = true` and `CanLazyTick = true`. Updated during `OnTick_LazyTick`:
- **Casting**: `format("%.1f", maxValue - value)` — seconds remaining.
- **Channeling (regular)**: `format("%.1f", value)` — seconds remaining.
- **Empowered channeling**: `format("%.1f", maxValue - value)` — seconds to max stage.
- Values > 999 display as `""`.

---

## 9. Update Flow

```
WoW fires UNIT_SPELLCAST_START
        │
        ▼
OnEvent(self, "UNIT_SPELLCAST_START", unit, unitID, castID, spellID)
  → arg1 check: skip if arg1 ~= self.unit
  → calls UNIT_SPELLCAST_START(self, unit, ...)
        │
        ▼
UNIT_SPELLCAST_START
  → UpdateCastingInfo(unit, unitID, castID, spellID)
      → UnitCastingInfo(unit): name, text, texture, startTime, endTime, ...
      → converts ms → seconds (/ 1000)
      → IsValid() check (trade skill, name, visibility)
      → clears empowered state + pips
      → sets casting=true, channeling=nil, interrupted/failed/finished=nil
      → sets spellID, castID, spellName, spellTexture, spellStartTime, spellEndTime
      → value = GetTime() - spellStartTime
      → maxValue = spellEndTime - spellStartTime
      → SetMinMaxValues(0, maxValue); SetValue(value)
      → Icon:SetTexture(texture); Icon:Show()
      → Text:SetText(name)
      → Animation_StopAllAnimations(); Animation_FadeIn() (if hidden)
      → Spark:Show(); Spark:SetPoint(...)
      → Show(); UpdateCastColor(); UpdateInterruptState()
  → RunHooksForWidget("OnCastStart", self, unit, "UNIT_SPELLCAST_START")

        │
        ▼
Every frame (OnUpdate → OnTick(deltaTime)):
  → casting == true:
      → OnTick_Casting: value += deltaTime; CheckCastIsDone(); SetValue(value)
      → lazyUpdateCooldown -= deltaTime
      → if lazyUpdateCooldown <= 0: OnTick_LazyTick() (update percentText); reset cooldown

        │
        ├── cast not done: continue
        │
        └── cast done (value >= maxValue):
              CheckCastIsDone() → UNIT_SPELLCAST_STOP(self, unit, unit, castID, spellID)
                → castID match check
                → Spark:Hide(); percentText:Hide()
                → SetValue(maxValue)
                → casting=nil; channeling=nil; finished=true; castID=nil
                → if not HasScheduledHide():
                    if not visible:    Hide()
                    if NoFadeEffects:  ScheduleToHide(0.3)
                    else:              Animation_Flash(); Animation_FadeOut()
                → UpdateCastColor()

        │
        ▼  (interrupt path)
WoW fires UNIT_SPELLCAST_INTERRUPTED
  → casting/channeling check + castID match
  → casting=nil; channeling=nil; interrupted=true; finished=true; castID=nil
  → if FillOnInterrupt: SetValue(maxValue)
  → if HideSparkOnInterrupt: Spark:Hide()
  → UpdateCastColor(); percentText:Hide()
  → Text:SetText(INTERRUPTED)
  → ScheduleToHide(1)

        │
        ▼  (failure path)
WoW fires UNIT_SPELLCAST_FAILED
  → casting/channeling check + castID match
  → casting=nil; channeling=nil; failed=true; finished=true; castID=nil
  → SetValue(maxValue)
  → UpdateCastColor(); Spark:Hide(); percentText:Hide()
  → Text:SetText(FAILED)
  → ScheduleToHide(1)
```

---

## 10. Practical Usage Patterns

### Standalone cast bar for "target"

```lua
local cb = DF:CreateCastBar(myFrame, "MyAddonCastBar")
cb:SetPoint("bottomleft", myFrame, "bottomleft", 4, 4)
cb:SetSize(200, 18)
cb:SetUnit("target")
```

---

### Custom colors and no fade effects

```lua
local cb = DF:CreateCastBar(parent, "MyHUDCastBar", {
    NoFadeEffects  = true,
    FillOnInterrupt = false,
    DontUpdateAlpha = true,
    Colors = {
        Casting         = detailsFramework:CreateColorTable(0.2, 0.6, 1, 1),
        Channeling      = detailsFramework:CreateColorTable(0.2, 1, 0.4, 1),
        NonInterruptible= detailsFramework:CreateColorTable(0.5, 0.5, 0.5, 1),
        Interrupted     = detailsFramework:CreateColorTable(1, 0.2, 0.2, 1),
        Failed          = detailsFramework:CreateColorTable(0.4, 0.4, 0.4, 1),
        Finished        = detailsFramework:CreateColorTable(0, 1, 0, 1),
        Empowered       = detailsFramework:CreateColorTable(0.8, 0.4, 1, 1),
    },
})
cb:SetUnit("player")
```

---

### Change a single color at runtime

```lua
cb:SetDefaultColor("Casting", 0, 0.8, 1, 1)
cb:UpdateCastColor()  -- apply immediately if a cast is active
```

---

### React to cast start via hook

```lua
cb:SetHook("OnCastStart", function(self, unit, eventName)
    if eventName == "UNIT_SPELLCAST_CHANNEL_START" then
        print(unit, "started channeling:", self.spellName)
    else
        print(unit, "started casting:", self.spellName, "(", self.maxValue, "s )")
    end
end)
```

---

### Hiding spell text and icon (display bar only)

```lua
local cb = DF:CreateCastBar(parent, "MyBarOnly", {
    DontUpdateAlpha = true,
    NoFadeEffects   = true,
})
cb:SetUnit("player")
cb.Text:Hide()
cb.Icon:Hide()
cb.Spark:SetHeight(40)  -- oversized spark effect
```

---

### Filtering trade skills

```lua
-- Default: ShowTradeSkills = false (crafting bars are ignored)
-- To enable crafting cast display:
local cb = DF:CreateCastBar(parent, "MyCraftBar", { ShowTradeSkills = true })
cb:SetUnit("player")
```

---

### As part of a unit frame (internal usage)

Inside `CreateUnitFrame`, the cast bar is created and stored on the unit frame:

```lua
local castBar = DF:CreateCastBar(unitFrame, nil, castBarSettingsOverride)
castBar:SetFrameLevel(baseFrameLevel + 3)
unitFrame.castBar = castBar
```

`SetUnit` is called independently on `unitFrame.castBar` when the unit frame's unit changes:

```lua
unitFrame.castBar:SetUnit(unit, displayedUnit)
```

---

## 11. Differences from a Standard StatusBar

| Feature | WoW `StatusBar` | `df_castbar` |
|---|---|---|
| Value update | Manual (`SetValue`) | Automatic via `OnUpdate` / `OnTick` |
| Min/max | Arbitrary | Always `0` to `spellEndTime - spellStartTime` |
| Cast detection | Manual event handling | Automatic via `SetUnit` + registered events |
| Channeling support | None | Built-in (drains from `maxValue` → 0) |
| Empowered support | None | Built-in with stage pip markers (mainline) |
| Interrupt/fail feedback | None | Built-in: color change + `ScheduleToHide(1)` |
| Fade animations | None | Built-in fade-in / fade-out / flash |
| Spark | None | Built-in, tracks fill edge via `barTexture` anchor |
| Countdown text | None | Built-in via `percentText` (lazy-ticked) |
| Non-interruptible shield | None | Built-in `BorderShield` |
| Spell icon | None | Built-in `Icon` |
| Color by cast type | None | `Colors` table + `GetCastColor()` priority logic |
| Trade skill filtering | None | Controlled by `ShowTradeSkills` setting |

---

---

# DetailsFramework — Power Bar System

> **Scope**: This section covers only the `df_powerbar` object.  
> Health bar, cast bar, and unit frame are documented separately.

---

## Overview

`unitframe.lua` implements `df_powerbar`, a `StatusBar`-based widget that tracks a WoW unit's active power resource in real time. It:

- Registers WoW unit events for power updates, max-power changes, power-type changes, and alternate-power show/hide.
- Automatically selects which power type to display: on mainline WoW when a unit has an active alternate-power bar visible in raids, it shows that instead of the unit's primary resource.
- Colors itself automatically to match the power type (mana = blue, rage = red, energy = yellow, etc.) using the global `PowerBarColor` table.
- Optionally shows a percentage text overlay.
- Hides itself when `UnitPowerMax` returns 0 and `HideIfNoPower` is `true`.

The power bar is usable as a **standalone widget** (attach to any frame, call `SetUnit`) or as a sub-component of a `df_unitframe` (`unitFrame.powerBar`).

---

## 1. Entry Point — `CreatePowerBar`

```lua
local powerBar = detailsFramework:CreatePowerBar(
    parent,           -- (frame)   Parent WoW frame.
    name,             -- (string?) Absolute global name for the StatusBar. If nil, uses parent:GetName() .. "PowerBar".
    settingsOverride  -- (table?)  Key/value pairs to override defaults from df_powerbarsettings.
)
-- Returns: df_powerbar
```

**Requirement**: either `name` is provided, or `parent` must have a global name. Violating this triggers a Lua error.

### Initialization sequence

1. A WoW `StatusBar` (with `BackdropTemplate`) is created as the base frame.
2. Child textures and FontStrings are created (see §5 — Frame Hierarchy).
3. Two mixins are applied:
   - `PowerFrameFunctions` — all power-bar-specific methods and event handlers.
   - `detailsFramework.StatusBarFunctions` — texture/color/mask helpers.
4. A `TextureMask` is created via `CreateTextureMask()`.
5. A seed texture is set (`Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT`).
6. A **private copy** of `PowerFrameFunctions.Settings` is made and merged with `settingsOverride`, stored as `powerBar.Settings`.
7. A **private copy** of `PowerFrameFunctions.HookList` is stored as `powerBar.HookList`.
8. `powerBar:Initialize()` is called — sets pixel-aligned width/height, applies the fill texture, configures `background`, sets up `percentText` visibility and position, and calls `SetUnit(nil)` to clear state.

---

## 2. Object Structure (`df_powerbar`)

A `df_powerbar` **is** a WoW `StatusBar` frame with additional fields mixed in. Methods are available directly on the frame object.

### Runtime state fields

| Field | Type | Description |
|---|---|---|
| `WidgetType` | `"powerBar"` | Component type identifier. |
| `unit` | `unit?` | Unit token currently tracked (e.g. `"target"`). `nil` when unbound. |
| `displayedUnit` | `unit?` | Unit whose power values are read. Equals `unit` unless set differently via `SetUnit`. |
| `currentPower` | `number` | Last-known power value (raw, not percentage). |
| `currentPowerMax` | `number` | Last-known maximum power. |
| `powerType` | `number` | Numeric power type currently displayed. Set by `UpdatePowerInfo`. Uses `ALTERNATE_POWER_INDEX` when showing an alternate power bar. |
| `minPower` | `number` | Minimum power value (normally `0`; set to `barInfo.minPower` for alternate power). |
| `Settings` | `df_powerbarsettings` | Per-instance settings table (private copy). |
| `HookList` | `table` | Per-instance hook registry (private copy). |

### Child UI elements

| Field | Type | Layer / Sub-level | Description |
|---|---|---|---|
| `background` | `texture` | background, `-6` | Solid-color backdrop, `SetAllPoints`. |
| `barTexture` | `texture` | artwork | Fill texture, registered as `SetStatusBarTexture`. |
| `percentText` | `fontstring` | overlay | Centered percentage text. Font: `GameFontNormal`, size 9, white, `OUTLINE`. Hidden when `ShowPercentText = false`. |
| `barTextureMask` | mask | — | Created by `CreateTextureMask()`; clips fill to bar shape. |
| `barBorderTextureForMask` | `texture` | overlay, `7` | Optional border texture, hidden by default. |

---

## 3. Settings (`df_powerbarsettings`)

Override any key via `settingsOverride` in `CreatePowerBar`.

| Key | Type | Default | Effect |
|---|---|---|---|
| `ShowAlternatePower` | `boolean` | `true` | **Mainline only.** When `true`, checks for an active alternate-power bar (`UnitPowerBarID`) and displays it instead of the primary resource when the unit is in a raid and `barInfo.showOnRaid` is set. |
| `ShowPercentText` | `boolean` | `true` | When `true`, shows `percentText` centered on the bar, displaying `floor(currentPower / currentPowerMax * 100) .. "%"`. |
| `HideIfNoPower` | `boolean` | `true` | When `true`, calls `self:Hide()` inside `UpdateMaxPower` if `UnitPowerMax` returns `0`. |
| `CanTick` | `boolean` | `false` | When `true`, installs `OnUpdate` calling `powerBar:OnTick(deltaTime)` each frame while a unit is bound. |
| `BackgroundColor` | `df_colortable` | `(0.2, 0.2, 0.2, 0.8)` | Background texture solid color. |
| `Texture` | `texturepath\|textureid\|atlasname` | `Interface\RaidFrame\Raid-Bar-Resource-Fill` | Fill texture applied during `Initialize`. |
| `Width` | `number` | `100` | Initial width set by `Initialize` via `PixelUtil.SetWidth`. |
| `Height` | `number` | `20` | Initial height set by `Initialize` via `PixelUtil.SetHeight`. |

---

## 4. Methods

All methods are called on the `df_powerbar` frame object.

### Unit binding

#### `SetUnit(unit, displayedUnit?)`
```lua
powerBar:SetUnit("target")
powerBar:SetUnit("nameplate1", "nameplate1")
powerBar:SetUnit(nil)  -- unbind
```
- Binds the power bar to a unit. Registers all events in `PowerBarEvents` for that unit. Installs `OnEvent` script; installs `OnUpdate` if `CanTick = true`.
- After binding, calls `Show()` then `UpdatePowerBar()` immediately.
- When `unit` is `nil`: unregisters all events, removes scripts, calls `Hide()`.
- Calling `SetUnit` with the exact same `unit` and `displayedUnit` is a **no-op** (deduplication guard).

---

### Power update methods

#### `UpdatePowerBar()`
```lua
powerBar:UpdatePowerBar()
```
Master update function. Calls all four subordinate update methods in order:
1. `UpdatePowerInfo()` — determine which power type to show.
2. `UpdateMaxPower()` — update `currentPowerMax` and StatusBar min/max.
3. `UpdatePower()` — update `currentPower` and bar fill value.
4. `UpdatePowerColor()` — tint the bar to match the power type.

---

#### `UpdatePowerInfo()`
```lua
powerBar:UpdatePowerInfo()
```
Determines which power type (`powerType`) and minimum value (`minPower`) to use:

1. **Alternate power (mainline only, `ShowAlternatePower = true`)**: calls `UnitPowerBarID(displayedUnit)` and `GetUnitPowerBarInfoByID(barID)`. If the returned `barInfo` has `showOnRaid = true` and the player is in a group (`IsInGroup()`), sets `powerType = ALTERNATE_POWER_INDEX` and `minPower = barInfo.minPower`.
2. **Primary power (fallback)**: calls `UnitPowerType(displayedUnit)`, sets `powerType` to the returned numeric type index and `minPower = 0`.

This method is called before `UpdateMaxPower` and `UpdatePower` to ensure the correct power resource is queried.

---

#### `UpdateMaxPower()`
```lua
powerBar:UpdateMaxPower()
```
- Calls `UnitPowerMax(displayedUnit, powerType)` to get the new maximum.
- Updates `currentPowerMax`.
- Calls `SetMinMaxValues(minPower, currentPowerMax)`.
- If `currentPowerMax == 0` and `Settings.HideIfNoPower`, calls `self:Hide()`.

---

#### `UpdatePower()`
```lua
powerBar:UpdatePower()
```
- Calls `UnitPower(displayedUnit, powerType)`.
- Updates `currentPower`.
- Calls `PixelUtil.SetStatusBarValue(self, currentPower)` to move the fill.
- If `Settings.ShowPercentText`, updates `percentText` to `floor(currentPower / currentPowerMax * 100) .. "%"`.

> **Note**: `UpdatePower` does not guard against `currentPowerMax == 0`. If you call it before `UpdateMaxPower` sets a valid max, the percent text will show `inf%` or error. Always call `UpdateMaxPower` first (which `UpdatePowerBar` ensures).

---

#### `UpdatePowerColor()`
```lua
powerBar:UpdatePowerColor()
```
Sets the StatusBar fill color based on the current `powerType`. Priority order:

1. **Disconnected unit**: `SetStatusBarColor(0.5, 0.5, 0.5)` — grey.
2. **Alternate power** (`powerType == ALTERNATE_POWER_INDEX`): `SetStatusBarColor(0.7, 0.7, 0.6)` — off-white/tan (matches the game's `CompactUnitFrame.lua`).
3. **`PowerBarColor[powerType]`**: uses the global WoW `PowerBarColor` table (contains entries for all standard resources). Sets `(powerColor.r, powerColor.g, powerColor.b)`.
4. **`UnitPowerType(displayedUnit)`** return values `r, g, b`: uses the color returned by the API directly.
5. **Fallback**: uses `PowerBarColor["ENERGY"]` — yellow.

---

### Tick

#### `OnTick(self, deltaTime)` *(stub)*
```lua
-- Default implementation does nothing.
-- To use, set CanTick = true in settingsOverride:
local pb = DF:CreatePowerBar(parent, nil, { CanTick = true })
function pb:OnTick(deltaTime)
    -- runs every frame while unit is bound
end
```
Called by `OnUpdate` when `Settings.CanTick == true` and a unit is bound.

---

### Initialization

#### `Initialize()`
Called automatically at the end of `CreatePowerBar`. Sets width/height, texture, background color, `percentText` visibility and position, then calls `SetUnit(nil)`. Should not be called manually.

---

### Texture and color (from `StatusBarFunctions` mixin)

The power bar exposes the same texture/color/mask methods as the health bar and cast bar:

`SetTexture`, `GetTexture`, `ResetTexture`, `SetColor`, `GetColor`, `SetVertexColor`, `GetVertexColor`, `SetDesaturated`, `SetDesaturation`, `IsDesaturated`, `SetAtlas`, `GetAtlas`, `SetTexCoord`, `GetTexCoord`, `SetMaskTexture`, `GetMaskTexture`, `SetMaskAtlas`, `GetMaskAtlas`, `AddMaskTexture`, `CreateTextureMask`, `HasTextureMask`, `SetBorderTexture`, `GetBorderTexture`.

> **Note**: `UpdatePowerColor` calls `SetStatusBarColor` directly (native WoW API), not `SetColor`. Calling `powerBar:SetColor(...)` afterward will override the auto-color until the next `UpdatePowerColor` call.

---

## 5. Hook System

The power bar uses `ScriptHookMixin`. Hooks are stored in `powerBar.HookList` (per-instance private copy).

### Available hook events

| Hook name | Callback signature | Fired when |
|---|---|---|
| `OnHide` | `(powerBar)` | Frame is hidden. |
| `OnShow` | `(powerBar)` | Frame is shown. |

The power bar has **no custom content hooks** (no `OnPowerChange` etc.). To react to power changes, use `SetUnit` deduplication to call your own logic, or override the event methods directly:

```lua
local origUpdatePower = powerBar.UpdatePower
powerBar.UpdatePower = function(self)
    origUpdatePower(self)
    -- custom logic here, e.g.:
    print(self.currentPower, "/", self.currentPowerMax)
end
```

---

## 6. Registered Events

`SetUnit` registers these events. Events flagged `(unit event)` are registered via `RegisterUnitEvent`; others via `RegisterEvent`.

| Event | Unit event? | Handler | Notes |
|---|---|---|---|
| `PLAYER_ENTERING_WORLD` | No | `PLAYER_ENTERING_WORLD` | Calls `UpdatePowerBar()` — full refresh on world enter / instance travel. |
| `UNIT_DISPLAYPOWER` | Yes | `UNIT_DISPLAYPOWER` | Power type changed (e.g. entering a vehicle). Calls `UpdatePowerBar()`. |
| `UNIT_POWER_BAR_SHOW` | Yes | `UNIT_POWER_BAR_SHOW` | An alternate-power bar became active. Calls `UpdatePowerBar()`. |
| `UNIT_POWER_BAR_HIDE` | Yes | `UNIT_POWER_BAR_HIDE` | An alternate-power bar was removed. Calls `UpdatePowerBar()`. |
| `UNIT_MAXPOWER` | Yes | `UNIT_MAXPOWER` | Maximum power changed. Calls `UpdateMaxPower()` + `UpdatePower()`. |
| `UNIT_POWER_UPDATE` | Yes | `UNIT_POWER_UPDATE` | Power value changed. Calls `UpdatePower()` only. |
| `UNIT_POWER_FREQUENT` | Yes | `UNIT_POWER_FREQUENT` | High-frequency power update. Calls `UpdatePower()` only. |

---

## 7. Power Type and Color Logic

### Power type selection

`UpdatePowerInfo` runs before every value read to pick `powerType`:

```
ShowAlternatePower == true AND IS_WOW_PROJECT_MAINLINE?
    → UnitPowerBarID(displayedUnit) → GetUnitPowerBarInfoByID(barID)
    → barInfo.showOnRaid AND IsInGroup()?
        YES → powerType = ALTERNATE_POWER_INDEX, minPower = barInfo.minPower
        NO  → powerType = UnitPowerType(displayedUnit), minPower = 0
    → (barInfo is nil or showOnRaid is false)
        → powerType = UnitPowerType(displayedUnit), minPower = 0

ShowAlternatePower == false OR classic WoW:
    → powerType = UnitPowerType(displayedUnit), minPower = 0
```

### Color resolution (UpdatePowerColor)

```
UnitIsConnected(unit) == false?
    → grey (0.5, 0.5, 0.5)

powerType == ALTERNATE_POWER_INDEX?
    → tan (0.7, 0.7, 0.6)

PowerBarColor[powerType] exists?
    → (powerColor.r, powerColor.g, powerColor.b)

UnitPowerType(displayedUnit) returns r, g, b?
    → (r, g, b)

fallback:
    → PowerBarColor["ENERGY"] (yellow)
```

### Common power type colors (from global `PowerBarColor`)

| Power Type | Resource | Typical color |
|---|---|---|
| `0` | Mana | Blue |
| `1` | Rage | Red |
| `2` | Focus | Orange |
| `3` | Energy | Yellow |
| `6` | Runic Power | Light blue |
| `7` | Soul Shards | Purple |
| `ALTERNATE_POWER_INDEX` | Alternate | Tan `(0.7, 0.7, 0.6)` |

---

## 8. Rendering and Layout

### Frame hierarchy

```
powerBar (StatusBar, BackdropTemplate)
├── background (background layer, -6)  — solid-color backdrop, SetAllPoints
├── barTexture (artwork layer)          — fill texture, registered as StatusBarTexture
├── percentText (overlay layer)         — centered percentage string
├── barTextureMask (mask)               — clips fill to bar shape
└── barBorderTextureForMask (overlay, 7) — optional border (hidden by default)
```

### Fill direction

The power bar uses the default left-to-right StatusBar fill. No `SetDirection` or `SetReverseFill` is used. The bar fills proportionally from `minPower` to `currentPowerMax`.

### Percent text

When `ShowPercentText = true`:
- Anchored at center of the power bar.
- Font: `GameFontNormal`, size 9, color white, outline `"OUTLINE"`.
- Text: `floor(currentPower / currentPowerMax * 100) .. "%"`.
- Updated on every `UpdatePower()` call.

---

## 9. Update Flow

```
WoW fires UNIT_POWER_UPDATE (or UNIT_POWER_FREQUENT)
        │
        ▼
OnEvent(self, "UNIT_POWER_UPDATE", ...)
  → looks up self["UNIT_POWER_UPDATE"]
  → calls UNIT_POWER_UPDATE(self, ...)
        │
        ▼
UNIT_POWER_UPDATE(self, ...)
  → UpdatePower()
      → UnitPower(displayedUnit, powerType)
      → currentPower = result
      → PixelUtil.SetStatusBarValue(self, currentPower)
      → [if ShowPercentText] percentText:SetText(floor(pct) .. "%")

WoW fires UNIT_MAXPOWER
        │
        ▼
UNIT_MAXPOWER(self, ...)
  → UpdateMaxPower()
      → UnitPowerMax(displayedUnit, powerType)
      → currentPowerMax = result
      → SetMinMaxValues(minPower, currentPowerMax)
      → [if HideIfNoPower and max==0] Hide()
  → UpdatePower()

WoW fires UNIT_DISPLAYPOWER (power type changed)
        │
        ▼
UNIT_DISPLAYPOWER(self, ...)
  → UpdatePowerBar()
      → UpdatePowerInfo()  ← re-evaluates powerType and minPower
      → UpdateMaxPower()   ← queries new max for the new power type
      → UpdatePower()      ← queries new current value
      → UpdatePowerColor() ← re-tints bar for the new power type

WoW fires PLAYER_ENTERING_WORLD / UNIT_POWER_BAR_SHOW / UNIT_POWER_BAR_HIDE
  → UpdatePowerBar() (same full refresh path as above)
```

---

## 10. Practical Usage Patterns

### Standalone power bar for "target"

```lua
local pb = DF:CreatePowerBar(myFrame, "MyAddonPowerBar")
pb:SetPoint("topleft", myFrame, "topleft", 4, -4)
pb:SetSize(200, 10)
pb:SetUnit("target")
```

---

### Power bar without percent text or alternate power

```lua
local pb = DF:CreatePowerBar(parent, "MyPB", {
    ShowPercentText    = false,
    ShowAlternatePower = false,
    HideIfNoPower      = true,
    Width              = 180,
    Height             = 8,
})
pb:SetUnit("player")
```

---

### Custom texture and background

```lua
local pb = DF:CreatePowerBar(parent, "MyPB", {
    Texture         = SharedMedia:Fetch("statusbar", "Smooth"),
    BackgroundColor = {0.05, 0.05, 0.05, 1},
})
pb:SetUnit("focus")
```

---

### Override auto-color with a fixed color

```lua
local pb = DF:CreatePowerBar(parent, "MyPB")
pb:SetUnit("player")

-- After SetUnit the bar is colored by power type.
-- Override it permanently:
pb.UpdatePowerColor = function(self)
    self:SetStatusBarColor(0.2, 0.6, 1, 1)  -- always blue
end
```

---

### React to power changes (method override)

```lua
local pb = DF:CreatePowerBar(parent, "MyPB")
local origUpdatePower = pb.UpdatePower

pb.UpdatePower = function(self)
    origUpdatePower(self)
    if self.currentPowerMax > 0 then
        local pct = self.currentPower / self.currentPowerMax
        if pct < 0.2 then
            self:SetStatusBarColor(1, 0.2, 0.2)  -- red at low energy
        end
    end
end

pb:SetUnit("player")
```

---

### Per-frame tick

```lua
local pb = DF:CreatePowerBar(parent, "MyPB", { CanTick = true })
function pb:OnTick(deltaTime)
    -- custom per-frame logic, e.g. smooth interpolation
end
pb:SetUnit("target")
```

---

### As part of a unit frame (internal usage)

Inside `CreateUnitFrame`, the power bar is created and stored on the unit frame:

```lua
local powerBar = DF:CreatePowerBar(unitFrame, nil, powerBarSettingsOverride)
powerBar:SetFrameLevel(baseFrameLevel + 2)
unitFrame.powerBar = powerBar
```

`SetUnit` is called independently on `unitFrame.powerBar` when the unit frame's unit changes:

```lua
unitFrame.powerBar:SetUnit(unit, displayedUnit)
```

---

## 11. Differences from a Standard StatusBar

| Feature | WoW `StatusBar` | `df_powerbar` |
|---|---|---|
| Value update | Manual (`SetValue`) | Automatic on `UNIT_POWER_UPDATE` / `UNIT_POWER_FREQUENT` |
| Power type detection | None | Automatic via `UnitPowerType` + alternate-power logic |
| Color | Manual | Automatic via `PowerBarColor` table + fallback chain |
| Min/max | Arbitrary | Always `minPower` to `UnitPowerMax` |
| Alternate power support | None | Built-in (`ShowAlternatePower` setting, mainline only) |
| Percent text | None | Built-in `percentText` overlay |
| Auto-hide when no power | None | Built-in (`HideIfNoPower` setting) |
| Masking | Manual | Built-in via `CreateTextureMask()` |
| Event handling | Manual | Automatic via `SetUnit` |
| Per-frame tick | None | Optional via `CanTick` + `OnTick` stub |

---

---

# DetailsFramework — Unit Frame System

> **Scope**: This section covers only the `df_unitframe` object.  
> Health bar, cast bar, and power bar are each documented in their own sections above.

---

## Overview

`unitframe.lua` implements `df_unitframe`, a **composition** widget that bundles a `df_healthbar`, a `df_castbar`, and a `df_powerbar` into one managed unit frame. It:

- Creates and owns all three child bars internally; callers never construct them separately.
- Registers a set of unit events on the main frame (separate from the events registered on each child bar) to drive name updates, health color, target overlay, vehicle possession detection, and aggro coloring.
- Applies automatic health bar coloring by class, faction, aggro, tap-denied state, or a fixed override — all controlled by settings flags.
- Tracks vehicle possession: when the tracked unit enters a vehicle, `displayedUnit` switches to the vehicle token so all child bars show vehicle data.
- Exposes a single `SetUnit` call that cascades to all child bars.

The unit frame is the **top-level entry point** when you want a complete health + power + cast display for a unit.

---

## 1. Entry Point — `CreateUnitFrame`

```lua
local unitFrame = detailsFramework:CreateUnitFrame(
    parent,                      -- (frame)   Parent WoW frame.
    name,                        -- (string?) Global name for the Button frame. If nil, generates a random name.
    unitFrameSettingsOverride,   -- (table?)  Overrides for df_unitframesettings.
    healthBarSettingsOverride,   -- (table?)  Overrides forwarded to CreateHealthBar.
    castBarSettingsOverride,     -- (table?)  Overrides forwarded to CreateCastBar.
    powerBarSettingsOverride     -- (table?)  Overrides forwarded to CreatePowerBar.
)
-- Returns: df_unitframe
```

**Note**: `name` is optional. When `nil`, a random name like `"DetailsFrameworkUnitFrame42857361"` is generated. Unlike the child bars, there is no requirement for the parent to have a name.

### Initialization sequence

1. A WoW `Button` (with `BackdropTemplate`) is created as the root frame.
2. A **monotonically increasing** global frame level is assigned (`globalBaseFrameLevel`, incremented by 10 per unit frame created). This ensures each new unit frame has higher frame levels than all previously created ones.
3. Child components are created in this order and stored on the frame:

   | Step | Component | Field | Frame level offset |
   |---|---|---|---|
   | 1 | `df_healthbar` | `healthBar` | base + 1 |
   | 2 | `df_powerbar` | `powerBar` | base + 2 |
   | 3 | `df_castbar` | `castBar` | base + 3 |
   | 4 | border frame (`CreateBorderFrame`) | `border` | base + 5 |
   | 5 | overlay frame (`CreateFrame "frame"`) | `overlayFrame` | base + 6 |

4. Two unit-frame-level UI elements are created:
   - `unitName` — a FontString (`GameFontHighlightSmall`, artwork layer) anchored `topleft` of `healthBar` with a 2 px inset.
   - `targetOverlay` — a texture on `overlayFrame` set `allpoints` over `healthBar`, ADD blend, alpha 0.5, using the health bar's current fill texture.
5. `UnitFrameFunctions` is mixed into the root frame.
6. A **private copy** of `UnitFrameFunctions.Settings` is created, merged with `unitFrameSettingsOverride`, and stored as `unitFrame.Settings`.
7. `unitFrame:Initialize()` is called:
   - Sets border color from `Settings.BorderColor`.
   - Sets root frame pixel-aligned width/height.
   - Positions `powerBar`: anchored `bottomleft`/`bottomright` to root, height = `Settings.PowerBarHeight`.
   - Positions `castBar`: also anchored `bottomleft`/`bottomright` to root, height = `Settings.CastBarHeight`. The cast bar **overlaps** the power bar at the bottom (same anchor points, same height zone).

---

## 2. Object Structure (`df_unitframe`)

A `df_unitframe` **is** a WoW `Button` frame (with `BackdropTemplate`) with additional fields mixed in. The base type is `Button`, not `StatusBar`.

### Runtime state fields

| Field | Type | Description |
|---|---|---|
| `WidgetType` | `"unitFrame"` | Component type identifier. |
| `unit` | `string?` | Absolute unit token (e.g. `"party1"`, `"target"`). Set by `SetUnit`. |
| `displayedUnit` | `string?` | Unit whose data is shown. Equals `unit` normally; switches to a vehicle token when the unit is in a vehicle. |
| `guid` | `guid?` | GUID of the current unit, set during `SetUnit`. |
| `class` | `class?` | English class name (e.g. `"WARRIOR"`), set during `SetUnit`. |
| `name` | `actorname?` | Unit display name, set during `SetUnit`. |
| `unitInVehicle` | `boolean?` | `true` when `displayedUnit` differs from `unit` due to vehicle possession. |
| `Settings` | `df_unitframesettings` | Per-instance settings (private copy). |

### Child component fields

| Field | Type | Description |
|---|---|---|
| `healthBar` | `df_healthbar` | The health bar sub-widget. Fully functional standalone; access all its methods directly. |
| `powerBar` | `df_powerbar` | The power bar sub-widget. |
| `castBar` | `df_castbar` | The cast bar sub-widget. |
| `border` | frame | Border frame created by `DF:CreateBorderFrame`. |
| `overlayFrame` | frame | Transparent overlay frame, used to host elements that must float above all other bar layers. |
| `unitName` | `fontstring` | Unit name label, parented to the root frame (artwork layer). |
| `targetOverlay` | `texture` | ADD-blended highlight texture over `healthBar`, shown when `displayedUnit` is the player's current target. |

---

## 3. Settings (`df_unitframesettings`)

Override any key via the third argument (`unitFrameSettingsOverride`) in `CreateUnitFrame`.

| Key | Type | Default | Effect |
|---|---|---|---|
| `ClearUnitOnHide` | `boolean` | `true` | When `true`, calls `SetUnit(nil)` when the unit frame is hidden (via `OnHide` script). |
| `ShowCastBar` | `boolean` | `true` | When `false`, calls `castBar:SetUnit(nil)` and never binds the cast bar to the unit. |
| `ShowPowerBar` | `boolean` | `true` | When `false`, calls `powerBar:SetUnit(nil)` and never binds the power bar to the unit. |
| `ShowUnitName` | `boolean` | `true` | When `false`, `unitName` is never shown, even after `SetUnit`. |
| `ShowBorder` | `boolean` | `true` | When `true`, shows `border`; when `false`, hides it. Evaluated on each `SetUnit` call. |
| `CanModifyHealhBarColor` | `boolean` | `true` | When `false`, `UpdateHealthColor` is a no-op. Disables all automatic health bar coloring. |
| `ColorByAggro` | `boolean` | `false` | When `true`, colors health bar red when `UnitDetailedThreatSituation("player", unit)` returns a threat status. Also registers `UNIT_THREAT_LIST_UPDATE` for the unit. |
| `FixedHealthColor` | `boolean\|table` | `false` | When a table `{r, g, b}`, overrides the health bar color with that fixed value on every `UpdateHealthColor` call, regardless of class or faction. |
| `UseFriendlyClassColor` | `boolean` | `true` | When `true`, colors the health bar with `RAID_CLASS_COLORS[className]` for friendly players. |
| `UseEnemyClassColor` | `boolean` | `true` | When `true`, colors the health bar with `RAID_CLASS_COLORS[className]` for enemy players. |
| `ShowTargetOverlay` | `boolean` | `true` | When `true`, shows `targetOverlay` when `displayedUnit` matches the player's current target. |
| `BorderColor` | `df_colortable` | `(0, 0, 0, 1)` — opaque black | Color passed to `border:SetBorderColor` during `Initialize`. Set alpha to 0 for invisible border. |
| `CanTick` | `boolean` | `false` | When `true`, installs `OnUpdate` calling `unitFrame:OnTick(deltaTime)` each frame while a unit is bound. |
| `Width` | `number` | `100` | Root frame pixel width set during `Initialize`. |
| `Height` | `number` | `20` | Root frame pixel height set during `Initialize`. |
| `PowerBarHeight` | `number` | `4` | Height of `powerBar` in pixels, set during `Initialize`. |
| `CastBarHeight` | `number` | `8` | Height of `castBar` in pixels, set during `Initialize`. |

---

## 4. Layout

The unit frame uses a stacked layout. All child bars stretch the full width of the root frame. Heights are set during `Initialize` and are not automatically recalculated if settings change later.

```
unitFrame (Button, width × height)
├── healthBar           — fills entire root frame (SetAllPoints implicitly via healthbar init)
├── powerBar            — anchored bottomleft/bottomright to root, height = PowerBarHeight
├── castBar             — anchored bottomleft/bottomright to root, height = CastBarHeight
│                         (overlaps powerBar; appears above it due to higher frame level)
├── border              — wraps the root frame
├── overlayFrame        — full-area transparent overlay, topmost
│   └── targetOverlay   — SET_ALL_POINTS over healthBar, ADD blend (shown when unit is target)
└── unitName            — artwork FontString, topleft of healthBar, 2 px inset
```

### Frame level stack

| Component | Frame level |
|---|---|
| Root frame (`mewUnitFrame`) | `globalBaseFrameLevel` (auto-incremented) |
| `healthBar` | base + 1 |
| `powerBar` | base + 2 |
| `castBar` | base + 3 |
| `border` | base + 5 |
| `overlayFrame` | base + 6 |

> **Note**: The `globalBaseFrameLevel` counter is a module-level upvalue incremented by 10 per `CreateUnitFrame` call. Each new unit frame is guaranteed to occupy a higher z-band than all previously created ones.

### Cast bar vs. power bar overlap

Both `castBar` and `powerBar` are anchored to the same `bottomleft`/`bottomright` points of the root frame. The cast bar and power bar occupy the same pixel region at the bottom. The cast bar has a higher frame level, so it renders on top. The cast bar hides itself when no cast is active, revealing the power bar underneath.

---

## 5. Methods

All methods are called on the `df_unitframe` object.

### Unit binding

#### `SetUnit(unit)`
```lua
unitFrame:SetUnit("target")
unitFrame:SetUnit(nil)  -- unbind
```
The master binding call. When `unit` changes:

1. Sets `self.unit = unit`, `self.displayedUnit = unit`, `self.unitInVehicle = nil`.
2. If `unit ~= nil`:
   - Calls `RegisterEvents()` — registers all `UnitFrameEvents` (unit and global), sets `OnEvent` and `OnHide` scripts, optionally sets `OnUpdate` if `CanTick`.
   - Stores `guid`, `class`, `name` from the WoW API.
   - Calls `healthBar:SetUnit(unit, displayedUnit)`.
   - If `ShowCastBar`: `castBar:SetUnit(unit, displayedUnit)`, else `castBar:SetUnit(nil)`.
   - If `ShowPowerBar`: `powerBar:SetUnit(unit, displayedUnit)`, else `powerBar:SetUnit(nil)`.
   - Shows/hides `border` and `unitName` per settings.
3. If `unit == nil`:
   - Calls `UnregisterEvents()`.
   - Calls `healthBar:SetUnit(nil)`, `castBar:SetUnit(nil)`, `powerBar:SetUnit(nil)`.
4. Calls `UpdateUnitFrame()`.

Calling `SetUnit` with the same unit that is already bound is a **no-op** (deduplication guard: `if unit ~= self.unit or unit == nil`).

---

### Health bar color

#### `SetHealthBarColor(r, g, b, a?)`
```lua
unitFrame:SetHealthBarColor(1, 0, 0, 1)
unitFrame:SetHealthBarColor("red")
```
Delegates to `healthBar:SetColor(r, g, b, a)`. Accepts the same color formats as `SetColor` (numbers, named string, or table).

#### `UpdateHealthColor(r?, g?, b?)`
```lua
unitFrame:UpdateHealthColor()           -- auto-determine color from unit state
unitFrame:UpdateHealthColor(0.8, 0.2, 0.2)  -- force a specific color
unitFrame:UpdateHealthColor("green")    -- named color
```
Applies the health bar color using this priority chain (requires `CanModifyHealhBarColor = true`):

1. If `r` is provided → parse and apply directly.
2. If `Settings.FixedHealthColor` is a table → apply that fixed color.
3. If `UnitIsPlayer(displayedUnit)`:
   - Disconnected → grey `(0.5, 0.5, 0.5)`.
   - Friendly + `UseFriendlyClassColor` → `RAID_CLASS_COLORS[className]`.
   - Friendly without class color → green `(0, 1, 0)`.
   - Enemy + `UseEnemyClassColor` → `RAID_CLASS_COLORS[className]`.
   - Enemy without class color → red `(1, 0, 0)`.
4. Tap-denied NPC → grey `(0.6, 0.6, 0.6)`.
5. `ColorByAggro` active and player has threat → red `(1, 0, 0)`.
6. Default → `UnitSelectionColor(unit)` (WoW's built-in selection color by reaction/hostility).

---

### Unit name

#### `UpdateName()`
```lua
unitFrame:UpdateName()
```
Calls `UnitName(self.unit)` and sets `unitName:SetText`. Shows `unitName`. No-op if `Settings.ShowUnitName == false`.

---

### Target overlay

#### `UpdateTargetOverlay()`
```lua
unitFrame:UpdateTargetOverlay()
```
Shows `targetOverlay` if `UnitIsUnit(displayedUnit, "target")`, hides it otherwise. No-op if `Settings.ShowTargetOverlay == false`.

---

### Update methods

#### `UpdateUnitFrame()`
```lua
unitFrame:UpdateUnitFrame()
```
Calls `CheckVehiclePossession()`. If no vehicle swap happened (returns falsy), calls `UpdateAllWidgets()`.

#### `UpdateAllWidgets()`
```lua
unitFrame:UpdateAllWidgets()
```
If `UnitExists(displayedUnit)`:
1. Calls `SetUnit(unit, displayedUnit)` to re-bind if needed.
2. Re-binds `castBar` and `powerBar` if their respective settings flags are `true`.
3. Calls `UpdateName()`, `UpdateTargetOverlay()`, `UpdateHealthColor()`.

#### `CheckVehiclePossession()`
```lua
local inVehicle = unitFrame:CheckVehiclePossession()
```
Checks whether `unit` is controlling a vehicle (mainline: `UnitHasVehicleUI`). If so, resolves the vehicle's unit token and sets `displayedUnit` to it, then calls `RegisterEvents()` and `UpdateAllWidgets()`. When the vehicle exits, restores `displayedUnit = unit`. Returns `true` if a vehicle swap occurred (so the caller can skip a redundant `UpdateAllWidgets`).

---

### Event registration

#### `RegisterEvents()`
Internal — called by `SetUnit` when binding to a unit. Registers all entries in `UnitFrameEvents`. Installs `OnEvent`, `OnHide`, and optionally `OnUpdate` scripts. Unregisters `UNIT_THREAT_LIST_UPDATE` immediately if `ColorByAggro == false`.

#### `UnregisterEvents()`
Internal — called by `SetUnit(nil)` or `OnHide`. Unregisters all `UnitFrameEvents` and removes all scripts.

---

### Tick

#### `OnTick(self, deltaTime)` *(stub)*
```lua
-- Default: does nothing.
-- Enable with CanTick = true:
local uf = DF:CreateUnitFrame(parent, nil, { CanTick = true })
function uf:OnTick(deltaTime)
    -- custom per-frame logic
end
```

---

### Initialization

#### `Initialize()`
Called automatically at the end of `CreateUnitFrame`. Sets border color, root frame size, and positions/sizes the `powerBar` and `castBar`. Should not be called manually.

---

## 6. Registered Events

`RegisterEvents` registers these on the root frame. Events marked `(unit event)` use `RegisterUnitEvent`.

| Event | Unit event? | Handler | Notes |
|---|---|---|---|
| `PLAYER_ENTERING_WORLD` | No | `PLAYER_ENTERING_WORLD` | Full `UpdateUnitFrame()` refresh. |
| `PARTY_MEMBER_DISABLE` | No | *(none — no handler defined)* | Registered but has no handler in `UnitFrameFunctions`. |
| `PARTY_MEMBER_ENABLE` | No | `PARTY_MEMBER_ENABLE` | Calls `UpdateName()` if unit is connected. |
| `PLAYER_TARGET_CHANGED` | No | `PLAYER_TARGET_CHANGED` | Calls `UpdateTargetOverlay()`. |
| `UNIT_NAME_UPDATE` | Yes | `UNIT_NAME_UPDATE` | Calls `UpdateName()`. |
| `UNIT_CONNECTION` | Yes | `UNIT_CONNECTION` | Calls `UpdateUnitFrame()` if unit is now connected. |
| `UNIT_ENTERED_VEHICLE` | Yes | `UNIT_ENTERED_VEHICLE` | Calls `UpdateUnitFrame()` (triggers vehicle possession check). |
| `UNIT_EXITED_VEHICLE` | Yes | `UNIT_EXITED_VEHICLE` | Calls `UpdateUnitFrame()` (clears vehicle state). |
| `UNIT_PET` | Yes | `UNIT_PET` | Calls `UpdateUnitFrame()`. |
| `UNIT_THREAT_LIST_UPDATE` | Yes | `UNIT_THREAT_LIST_UPDATE` | Calls `UpdateHealthColor()` if `ColorByAggro == true`. **Unregistered automatically if `ColorByAggro == false`.** |

> **These events are separate from the events on the child bars.** Each child bar (`healthBar`, `castBar`, `powerBar`) registers its own independent events via its own `SetUnit` call.

---

## 7. Data Flow

```
caller calls unitFrame:SetUnit("target")
    │
    ├─→ unitFrame registers its own events (name, connection, vehicle, aggro, target-changed)
    │
    ├─→ healthBar:SetUnit("target", "target")   → healthBar registers UNIT_HEALTH, UNIT_MAXHEALTH, …
    ├─→ castBar:SetUnit("target", "target")     → castBar registers UNIT_SPELLCAST_*, …
    └─→ powerBar:SetUnit("target", "target")   → powerBar registers UNIT_POWER_UPDATE, …

--- At runtime ---

WoW fires UNIT_HEALTH → healthBar handles independently (no unitFrame involvement)
WoW fires UNIT_POWER_UPDATE → powerBar handles independently
WoW fires UNIT_SPELLCAST_START → castBar handles independently

WoW fires PLAYER_TARGET_CHANGED
    → unitFrame.OnEvent → PLAYER_TARGET_CHANGED(self)
        → UpdateTargetOverlay()   ← only unitFrame acts; child bars unaffected

WoW fires UNIT_THREAT_LIST_UPDATE (if ColorByAggro = true)
    → unitFrame.OnEvent → UNIT_THREAT_LIST_UPDATE(self)
        → UpdateHealthColor()
            → SetHealthBarColor(r, g, b)
                → healthBar:SetColor(r, g, b)

unit enters vehicle (UNIT_ENTERED_VEHICLE)
    → unitFrame.OnEvent → UNIT_ENTERED_VEHICLE(self)
        → UpdateUnitFrame()
            → CheckVehiclePossession()
                → sets displayedUnit = "vehicle" (or pet token)
                → RegisterEvents() with new displayedUnit
                → UpdateAllWidgets()
                    → healthBar:SetUnit(unit, "vehicle")
                    → castBar:SetUnit(unit, "vehicle")
                    → powerBar:SetUnit(unit, "vehicle")
```

**Key principle**: The unit frame and each child bar operate independently. The unit frame drives **name, target overlay, health color, and vehicle detection**; the child bars drive their own values (health, power, casts) directly from WoW events.

---

## 8. Rendering and Layout

### Visual structure (top-down)

```
unitFrame root (Button, Width × Height)
│
│  [ overlayFrame — frame level base+6 ]
│      └── targetOverlay  (ADD blend, allpoints over healthBar, alpha 0.5)
│
│  [ border — frame level base+5 ]
│      └── wraps the entire root frame
│
│  [ castBar — frame level base+3 ]
│      anchored bottomleft/bottomright of root, height = CastBarHeight
│      → shown while a spell is being cast; hides itself otherwise
│
│  [ powerBar — frame level base+2 ]
│      anchored bottomleft/bottomright of root, height = PowerBarHeight
│      → always visible while unit is bound and has power
│
│  [ healthBar — frame level base+1 ]
│      allpoints (fills entire root frame)
│
│  [ unitName — artwork FontString ]
│      topleft of healthBar, 2 px inset
```

### Layout rules

- The **health bar fills the full root frame**. The power bar and cast bar cut into the visual bottom of the health bar from below, since they overlay the same space.
- **Health bar `Height` controls the total frame height**. Since `healthBar` fills all points, the root `Height` setting drives the health bar's height. The power and cast bars are positioned *within* the bottom of that space.
- There is no automatic padding or spacing logic. If `PowerBarHeight + CastBarHeight > Height`, bars will overlap each other fully.
- Bar widths are always 100% of the root frame width (both are anchored `bottomleft` to `bottomright`).

---

## 9. Update Flow

```
unitFrame:SetUnit(unit)
    │
    └─→ UpdateUnitFrame()
            → CheckVehiclePossession()        [adjusts displayedUnit if in vehicle]
            → UpdateAllWidgets()
                    → UpdateName()            [sets unitName text]
                    → UpdateTargetOverlay()   [shows/hides targetOverlay]
                    → UpdateHealthColor()     [tints healthBar]

WoW event → unitFrame OnEvent dispatch:
    PLAYER_ENTERING_WORLD      → UpdateUnitFrame()
    PLAYER_TARGET_CHANGED      → UpdateTargetOverlay()
    UNIT_NAME_UPDATE           → UpdateName()
    UNIT_CONNECTION            → UpdateUnitFrame() (if connected)
    UNIT_ENTERED_VEHICLE       → UpdateUnitFrame()
    UNIT_EXITED_VEHICLE        → UpdateUnitFrame()
    UNIT_PET                   → UpdateUnitFrame()
    UNIT_THREAT_LIST_UPDATE    → UpdateHealthColor() (if ColorByAggro)
    PARTY_MEMBER_ENABLE        → UpdateName() (if connected)
```

---

## 10. Practical Usage Patterns

### Minimal unit frame

```lua
local uf = DF:CreateUnitFrame(myParentFrame, "MyAddonUnitFrame")
uf:SetPoint("topleft", myParentFrame, "topleft", 4, -4)
uf:SetUnit("target")
```

---

### Custom size with no cast bar and no power bar

```lua
local uf = DF:CreateUnitFrame(parent, "MyUF", {
    ShowCastBar  = false,
    ShowPowerBar = false,
    Width        = 200,
    Height       = 24,
})
uf:SetPoint("center", parent, "center")
uf:SetUnit("player")
```

---

### Disable automatic health color (manage it yourself)

```lua
local uf = DF:CreateUnitFrame(parent, "MyUF", {
    CanModifyHealhBarColor = false,
})
uf:SetUnit("target")
uf:SetHealthBarColor(0.2, 0.8, 0.4)  -- always green
```

---

### Fixed health color override

```lua
local uf = DF:CreateUnitFrame(parent, "MyUF", {
    FixedHealthColor = { r = 1, g = 0.2, b = 0.2 },  -- always red
})
uf:SetUnit("focus")
```

---

### Aggro coloring

```lua
local uf = DF:CreateUnitFrame(parent, "MyUF", {
    ColorByAggro           = true,
    UseFriendlyClassColor  = false,
    UseEnemyClassColor     = false,
})
uf:SetUnit("target")
-- health bar turns red when the unit is targeting the player
```

---

### Custom settings for each child bar

```lua
local uf = DF:CreateUnitFrame(
    parent,
    "MyUF",
    -- unit frame settings
    { Width = 200, Height = 30, PowerBarHeight = 6, CastBarHeight = 10, ShowBorder = false },
    -- health bar settings
    { ShowHealingPrediction = false, ShowShields = false },
    -- cast bar settings
    { FadeOutTime = 0.3, NoFadeEffects = false, SparkHeight = 10 },
    -- power bar settings
    { ShowAlternatePower = false, ShowPercentText = false }
)
uf:SetPoint("topleft", parent, "topleft")
uf:SetUnit("player")
```

---

### Accessing child bars directly

All child bar methods are accessible via `unitFrame.healthBar`, `unitFrame.castBar`, and `unitFrame.powerBar`:

```lua
-- Custom health bar texture
uf.healthBar:SetTexture([[Interface\AddOns\MyAddon\bar.tga]])

-- React to health changes
uf.healthBar:SetHook("OnHealthChange", function(hb, unit)
    print("HP:", hb.currentHealth, "/", hb.currentHealthMax)
end)

-- Override cast bar fade time
uf.castBar.Settings.FadeOutTime = 0.2

-- Force power bar color
uf.powerBar.UpdatePowerColor = function(self)
    self:SetStatusBarColor(0.1, 0.5, 1)
end

-- Add a custom texture to the health bar's overlay
local icon = uf.healthBar:CreateTexture(nil, "overlay")
icon:SetPoint("topleft", uf.healthBar, "topleft", 5, -5)
icon:SetSize(14, 14)
```

---

### Hide the unit frame and prevent the unit from being cleared

```lua
local uf = DF:CreateUnitFrame(parent, "MyUF", { ClearUnitOnHide = false })
uf:SetUnit("player")
uf:Hide()  -- unit stays bound; re-showing will restore the display immediately
```

---

### Per-frame tick on the unit frame

```lua
local uf = DF:CreateUnitFrame(parent, "MyUF", { CanTick = true })
function uf:OnTick(deltaTime)
    -- custom animation or text update
end
uf:SetUnit("target")
```

---

## 11. Differences from Using Child Bars Individually

| Concern | Manual composition | `df_unitframe` |
|---|---|---|
| Creation | Three separate `CreateHealthBar` / `CreateCastBar` / `CreatePowerBar` calls | Single `CreateUnitFrame` call |
| Frame levels | Must be managed manually to avoid z-fighting | Handled automatically via global counter |
| Unit binding | Must call `SetUnit` on each bar separately | Single `unitFrame:SetUnit()` cascades to all three |
| Vehicle possession | Must implement manually | Built-in (`CheckVehiclePossession`, switches `displayedUnit`) |
| Health coloring | Must implement logic manually | Built-in (`UpdateHealthColor` with class/faction/aggro/tap chain) |
| Target overlay | Must implement manually | Built-in (`targetOverlay` texture, `PLAYER_TARGET_CHANGED` event) |
| Name label | Must implement manually | Built-in (`unitName` FontString, `UpdateName`) |
| Border | Must implement manually | Built-in (`CreateBorderFrame`, `ShowBorder` setting) |
| Component access | Direct references | All accessible via `uf.healthBar`, `uf.castBar`, `uf.powerBar` |
| Event cleanup on hide | Must implement manually | Automatic via `ClearUnitOnHide` setting and `OnHide` script |
