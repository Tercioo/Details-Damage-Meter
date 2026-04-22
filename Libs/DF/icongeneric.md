# Generic Icon Row System Documentation

## Overview

The generic icon row system provides a horizontal strip of spell/aura icons with a custom cooldown visualization system. Unlike the standard icon row (`CreateIconRow`), this variant uses a texture-based horizontal swipe animation for cooldowns, a brightness overlay, and a looper-based tick system instead of `OnUpdate` scripts.

The system is composed of three parts:

| Component | Purpose |
|---|---|
| `DetailsFramework:CreateIconRowGeneric()` | Entry point. Creates and returns a `df_iconrow_generic` instance. |
| `default_iconrow_generic_options` | Local table of default configuration values merged into every instance. |
| `detailsFramework.IconGenericMixin` | Methods mixed into each instance (operate on `self`). |

### Key Differences from Standard Icon Row (`CreateIconRow`)

| Aspect | Standard (`IconMixin`) | Generic (`IconGenericMixin`) |
|---|---|---|
| Icon frame type | `button` | `frame` |
| Cooldown visualization | Blizzard `CooldownFrameTemplate` only | Custom horizontal swipe texture + optional Blizzard cooldown |
| Tick mechanism | `OnUpdate` script per icon | `detailsFramework.Schedules.NewLooper` (timer-based, 0.25s interval) |
| Per-icon settings | Not supported | `iconSettings` table parameter with scale, color, coords, etc. |
| Border | Black `ColorTexture` | Textured border (texture ID `130759`) at `overlay` layer |
| Icon positioning | Done in `GetIcon` | Done in `AlignAuraIcons` |
| `text_anchor` option type | String | `df_anchor` table `{side, x, y}` |
| Default `show_cooldown` | (always on) | `false` |
| Default `show_text` | `true` | `false` |
| Auto-remove on expire | Not supported | `remove_on_finish` option |
| Template methods | None | `SetAuraWithIconTemplate`, `SetSpecificAuraWithIconTemplate`, `AddSpecificIconWithTemplate` |

### Supporting Types

| Type | Description |
|---|---|
| `df_icongeneric` | A frame representing a single icon. Contains Texture, Border, CooldownTexture, CooldownBrightnessTexture, CooldownEdge, Cooldown, CountdownText, StackText, StackTextShadow, and Desc. |
| `df_iconrow_generic` | The container frame. Holds the icon pool, aura cache, and all mixin methods. |
| `df_icontemplate` | A data table for per-icon visual overrides (texture, coords, scale, alpha, color, borderColor, width, height, etc.). |
| `df_iconrow_generic_options` | The options class with all configurable fields. |

---

## Creating a Generic Icon Row

```lua
local iconRow = DetailsFramework:CreateIconRowGeneric(parent, name, options)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | yes | The parent frame. |
| 2 | `name` | `string` or `nil` | no | Global frame name. |
| 3 | `options` | `table` or `nil` | no | Overrides for `default_iconrow_generic_options`. |

### Returns

A `df_iconrow_generic` — a `Frame` (with `BackdropTemplate`) that has `IconGenericMixin` and `OptionsFunctions` mixed in.

### Initialization Sequence

1. A new `frame` is created with `BackdropTemplate`.
2. Internal state is initialized:
   - `IconPool` = `{}` — reusable pool of `df_icongeneric` frames.
   - `NextIcon` = `1` — index of the next icon slot to use.
   - `AuraCache` = `{}` — tracks displayed spells/auras.
   - `shownAmount` = `0` — count of visible icons.
3. `IconGenericMixin` is mixed in.
4. `OptionsFunctions` is mixed in (provides `BuildOptionsTable`).
5. `BuildOptionsTable` merges the caller's `options` with `default_iconrow_generic_options` into `self.options`.
6. Frame size is set to `(1, 1)` — the frame resizes dynamically as icons are added.
7. Backdrop and backdrop colors are applied from options.

---

## Default Options (`default_iconrow_generic_options`)

### Icon Size and Texture

| Option | Default | Description |
|---|---|---|
| `icon_width` | `20` | Width of each icon in pixels. |
| `icon_height` | `20` | Height of each icon in pixels. |
| `texcoord` | `{0.1, 0.9, 0.1, 0.9}` | Default texture coordinates for icon textures (crops edges). |

### Countdown Text

| Option | Default | Description |
|---|---|---|
| `show_text` | `false` | Whether countdown timer text is displayed on icons with a duration. |
| `text_color` | `{1, 1, 1, 1}` | RGBA color of the countdown text. |
| `text_size` | `12` | Font size. |
| `text_font` | `"Arial Narrow"` | Font face. |
| `text_outline` | `"NONE"` | Font outline style. |
| `text_anchor` | `{side = 9, x = 0, y = 0}` | Anchor for the countdown text. Uses `df_anchor` format (positioned via `DetailsFramework:SetAnchor`). Side `9` = center. |
| `text_alpha_by_percent` | `false` | If `true`, the countdown text alpha scales with the cooldown progress (fades in as cooldown progresses). |

### Description Text

| Option | Default | Description |
|---|---|---|
| `desc_text` | `true` | Whether description text can be shown. |
| `desc_text_color` | `{1, 1, 1, 1}` | RGBA color. |
| `desc_text_size` | `7` | Font size. |
| `desc_text_font` | `"Arial Narrow"` | Font face. |
| `desc_text_outline` | `"NONE"` | Font outline. |
| `desc_text_anchor` | `"bottom"` | Anchor point on the description fontstring. |
| `desc_text_rel_anchor` | `"top"` | Relative anchor on the icon frame. |
| `desc_text_x_offset` | `0` | Horizontal offset. |
| `desc_text_y_offset` | `2` | Vertical offset. |

### Stack Text

| Option | Default | Description |
|---|---|---|
| `stack_text` | `true` | Whether stack count is displayed (only shown when count > 1). |
| `stack_text_color` | `{1, 1, 1, 1}` | RGBA color. |
| `stack_text_size` | `10` | Font size. |
| `stack_text_font` | `"Arial Narrow"` | Font face. |
| `stack_text_outline` | `"NONE"` | Font outline. |
| `stack_text_anchor` | `"center"` | Anchor point on the stack fontstring. |
| `stack_text_rel_anchor` | `"bottomright"` | Relative anchor on the icon frame. |
| `stack_text_x_offset` | `0` | Horizontal offset. |
| `stack_text_y_offset` | `0` | Vertical offset. |

### Layout and Spacing

| Option | Default | Description |
|---|---|---|
| `left_padding` | `1` | Horizontal padding from edges and for the first icon offset. |
| `top_padding` | `1` | Vertical padding. |
| `icon_padding` | `1` | Horizontal gap between adjacent icons. |
| `grow_direction` | `1` | `1` = grow right, `2` = grow left. |
| `center_alignment` | `false` | If `true`, the row width is set to match total icon width after alignment. |
| `anchor` | `{side = 6, x = 2, y = 0}` | Anchor configuration. The `side` value determines grow direction via `GrowDirectionBySide`. |
| `first_icon_use_anchor` | `false` | If `true`, the first icon uses `DetailsFramework:SetAnchor` with the `anchor` option instead of the default side-based positioning. |

### Backdrop

| Option | Default | Description |
|---|---|---|
| `backdrop` | `{}` | Backdrop table. |
| `backdrop_color` | `{0, 0, 0, 0.5}` | RGBA backdrop color. |
| `backdrop_border_color` | `{0, 0, 0, 1}` | RGBA backdrop border color. |

### Blizzard Cooldown Frame

| Option | Default | Description |
|---|---|---|
| `show_cooldown` | `false` | Whether to show the Blizzard `CooldownFrameTemplate` animation. |
| `cooldown_reverse` | `false` | If `true`, the Blizzard cooldown swipe fills instead of draining. |
| `cooldown_swipe_enabled` | `true` | Whether the Blizzard cooldown swipe animation is drawn. |
| `cooldown_edge_texture` | `"Interface\\Cooldown\\edge"` | Edge texture for the Blizzard cooldown animation. |
| `surpress_blizzard_cd_timer` | `false` | Hides Blizzard's built-in countdown numbers. When `false`, the Blizzard countdown text is styled with `text_color`, `text_size`, `text_font`, `text_outline`. |
| `surpress_tulla_omni_cc` | `false` | Sets `noCooldownCount` to suppress OmniCC/tullaCC timers. |
| `cooldown_max_brightness` | `0.7` | Maximum alpha for the brightness overlay when `show_cooldown` is enabled. The brightness and swipe darkness increase as the cooldown progresses. |
| `on_tick_cooldown_update` | `true` | Not currently used by this system (noted as "nop" in source). |
| `decimal_timer` | `false` | Not currently used by this system (noted as "nop" in source). |

### Horizontal Swipe (Custom Cooldown Visualization)

| Option | Default | Description |
|---|---|---|
| `show_horizontal_swipe` | `true` | Whether to show the custom horizontal swipe animation. A colored bar grows upward from the bottom of the icon as the cooldown progresses. |
| `swipe_alpha` | `0.5` | Alpha of the `CooldownTexture` (the dark overlay that grows upward). |
| `swipe_brightness` | `0.5` | Alpha of the `CooldownBrightnessTexture` (the additive blend overlay above the swipe). |
| `swipe_color` | `{0, 0, 0}` | RGB color of the swipe overlay and edge when `swipe_progressive_color` is `false`. |
| `swipe_progressive_color` | `true` | If `true`, the edge color interpolates from `swipe_color_start` to `swipe_color_end` as the cooldown progresses. |
| `swipe_color_start` | `{0, 1, 0}` | RGB start color (green) for progressive color interpolation. |
| `swipe_color_end` | `{1, 0, 0}` | RGB end color (red) for progressive color interpolation. |

### Behavior

| Option | Default | Description |
|---|---|---|
| `remove_on_finish` | `false` | If `true`, icons are automatically removed when their cooldown expires. Only works for icons added with an `identifierKey` (via `AddSpecificIcon`). |

---

## Methods (`IconGenericMixin`)

### CreateIcon(iconName)

```lua
local iconFrame = iconRow:CreateIcon(iconName)
```

**Internal method.** Creates a new `df_icongeneric` frame with all child elements:

- `Texture` — the spell icon texture, inset 1px from edges.
- `CooldownBrightnessTexture` — additive-blend copy of the icon texture, used for the brightness effect during cooldowns. Layered above `Texture` (sublevel 2).
- `Border` — black `ColorTexture` background (acts as a border due to the 1px texture inset).
- `StackText` — fontstring at bottom-right for stack count, hidden by default.
- `StackTextShadow` — black fontstring behind `StackText`, hidden by default.
- `Desc` — fontstring above the icon for description text, hidden by default.
- `CooldownTexture` — a 2px-high texture at the bottom of the icon that grows upward to represent cooldown progress. Uses `GreyscaleRamp64` texture.
- `CooldownEdge` — a texture placed at the top edge of the `CooldownTexture` swipe.
- `CountdownText` — fontstring at center for remaining time, hidden by default.
- `Cooldown` — a `CooldownFrameTemplate` overlaying the icon (used when `show_cooldown` is enabled).

Sets `stacks = 0` and registers an `OnHide` script that cancels any active `cooldownLooper` timer.

**Returns:** `df_icongeneric`

---

### GetIcon()

```lua
local iconFrame = iconRow:GetIcon()
```

**Internal method.** Returns the next available icon from the pool, creating one via `CreateIcon` if needed.

**Behavior:**
1. Looks up `self.IconPool[self.NextIcon]`.
2. If not found, creates a new icon:
   - Sets `parentIconRow` back-reference.
   - Hides `Desc`.
   - Sets default texcoord `{0.1, 0.9, 0.1, 0.9}`.
   - Configures `Border` with texture ID `130759` (a WoW border texture) at `overlay` layer 7.
   - Applies stack text font, size, color, outline, and position from options.
   - Stores in pool.
3. Increments `NextIcon`.

**Note:** Unlike the standard icon row, `GetIcon` does **not** position the icon. Positioning happens in `AlignAuraIcons`.

**Returns:** `df_icongeneric`

---

### SetIcon(spellId, borderColor, startTime, duration, iconTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate, iconSettings, expirationTime)

```lua
local iconFrame = iconRow:SetIcon(spellId, borderColor, startTime, duration, iconTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate, iconSettings, expirationTime)
```

Primary method for adding an icon to the row.

**Parameters:**

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `spellId` | `number` | Spell ID. Used to look up name and icon via `GetSpellInfo`. |
| 2 | `borderColor` | `table` or `nil` | RGBA color for the border. `nil` = use `iconSettings.borderColor` or hide border. |
| 3 | `startTime` | `number` or `nil` | `GetTime()`-based start time. `nil` = no cooldown. |
| 4 | `duration` | `number` or `nil` | Duration in seconds. |
| 5 | `iconTexture` | `string`/`number` or `nil` | Override texture. |
| 6 | `descText` | `table` or `nil` | Not used in this implementation (desc text logic not present in SetIcon). |
| 7 | `count` | `number` or `nil` | Stack count. Shown only if > 1 and `stack_text` is enabled. |
| 8 | `debuffType` | `string` or `nil` | Debuff type string. |
| 9 | `caster` | `string` or `nil` | Unit ID of the caster. |
| 10 | `canStealOrPurge` | `boolean` or `nil` | Whether the aura is stealable/purgeable. |
| 11 | `spellName` | `string` or `nil` | Override spell name. |
| 12 | `isBuff` | `boolean` or `nil` | `true` = buff, `false` = debuff. |
| 13 | `modRate` | `number` or `nil` | Time modification rate (defaults to `1`). |
| 14 | `iconSettings` | `table` or `nil` | Per-icon visual overrides (see below). Defaults to empty table. |
| 15 | `expirationTime` | `number` or `nil` | Absolute expiration time. Stored on the icon frame. |

**`iconSettings` Fields (per-icon overrides):**

| Key | Type | Description |
|---|---|---|
| `width` | `number` | Override icon width. |
| `height` | `number` | Override icon height. |
| `scale` | `number` | Scale multiplier applied to width and height (default `1`). |
| `texture` | `string`/`number` | Fallback texture if `GetSpellInfo` returns none. |
| `overrideTexture` | `string`/`number` | Forces this texture regardless of spell icon. |
| `coords` | `table` | Texture coordinates `{left, right, top, bottom}`. |
| `points` | `table` | Array of `{anchor, relAnchor, xOfs, yOfs}` tables for custom texture positioning. |
| `textureFilter` | `string` | Texture filtering mode (default `"LINEAR"`). |
| `color` | `table` | Vertex color for the texture. When set, the icon ignores parent alpha. |
| `alpha` | `number` | Alpha for the texture. |
| `borderColor` | `table` | RGBA border color (used when `borderColor` parameter is nil). |
| `borderTexture` | `string`/`number` | Border texture override (default `130759`). |

**Behavior:**
1. Resolves spell icon from cache or `GetSpellInfo`. Applies `iconTexture`, `iconSettings.texture`, or `iconSettings.overrideTexture` overrides.
2. If no icon can be resolved, returns `nil`.
3. Obtains an icon frame via `GetIcon()`. Updates `shownAmount`.
4. Stores `expirationTime` on the frame.
5. Calculates size from `iconSettings.width/height` or options, multiplied by `iconSettings.scale`.
6. Sets texture with caching — only updates if the texture or coords have changed.
7. Applies vertex color and alpha from `iconSettings`.
8. Configures border visibility and color.
9. Shows/hides stack text based on count.
10. Sets up `CooldownBrightnessTexture` (copies the icon texture and coords for the additive blend overlay).
11. Stores all aura metadata on the icon frame.
12. If `startTime` and `duration > 0` and the aura hasn't expired, calls `SetCooldown(iconFrame)`.
13. Adds to `AuraCache` (by `spellId`, `spellName`, plus aggregate flags).
14. Shows the icon row frame.

**Returns:** `df_icongeneric` or `nil`

---

### SetCooldown(iconFrame)

```lua
iconRow:SetCooldown(iconFrame)
```

Configures and starts the cooldown visualization on an icon.

**Behavior:**
1. Cancels any existing `cooldownLooper` on the icon.
2. **Horizontal swipe** (if `show_horizontal_swipe` is enabled):
   - Shows `CooldownEdge`, `CooldownTexture`, and `CooldownBrightnessTexture`.
   - Applies `swipe_brightness` alpha to the brightness overlay and `swipe_alpha` to the cooldown texture.
   - Sets `swipe_color` on the cooldown texture.
3. **Countdown text** (if `show_text` is enabled):
   - Styles the countdown fontstring with `text_color`, `text_size`, `text_font`, `text_outline`.
   - Positions using `text_anchor` via `DetailsFramework:SetAnchor`.
4. **Blizzard cooldown** (if `show_cooldown` is enabled):
   - Shows and configures the `Cooldown` frame with reverse, swipe, edge texture, and timer suppression options.
   - If Blizzard timer is not suppressed, styles the Blizzard countdown text.
   - Calls `CooldownFrame_Set` with `startTime`, `duration`, and `modRate`.
5. Calls `OnIconTick(iconFrame)` immediately for the first update.
6. Creates a looper via `detailsFramework.Schedules.NewLooper`:
   - Interval: `0.25` seconds.
   - Iterations: `math.floor(duration / 0.25)` (plus 1 if `remove_on_finish`).
   - Calls `OnIconTick` each iteration.
   - Stores the looper handle as `iconFrame.cooldownLooper`.

---

### OnIconTick(iconFrame)

```lua
-- Called by the looper, not directly
IconGenericMixin.OnIconTick(iconFrame)
```

**Static method** (called with `iconFrame` as the argument, not `self`). Updates the cooldown visualization each tick.

**Behavior:**
1. Calculates `percent` = progress from 0 (start) to 1 (expired), adjusted by `modRate`.
2. Calculates `timeRemaining`.
3. If `percent >= 1`:
   - If `remove_on_finish`, calls `iconFrame:GetParent():RemoveSpecificIcon(iconFrame.identifierKey)` and returns.
   - Otherwise clamps to 1.
4. **Horizontal swipe update** (if `show_horizontal_swipe`):
   - Sets `CooldownTexture` height proportional to `percent` (grows upward from bottom).
   - Adjusts `CooldownBrightnessTexture` position and texcoords so the bright area shrinks from top down.
   - If `swipe_progressive_color`: interpolates edge color from `swipe_color_start` to `swipe_color_end` using linear interpolation; also increases edge alpha with progress.
   - If not progressive: uses solid `swipe_color`.
5. **Blizzard cooldown update** (if `show_cooldown` with `cooldown_max_brightness`):
   - Increases `CooldownBrightnessTexture` alpha linearly with percent.
   - Applies an exponential curve to the swipe color alpha for increasing darkness.
6. **Countdown text update** (if `show_text`):
   - Formats time with `FormatCooldownTime`.
   - If `text_alpha_by_percent`, text alpha scales with progress.

---

### FormatCooldownTime(thisTime)

```lua
local formatted = iconRow.FormatCooldownTime(seconds)
```

**Static method.** Formats seconds into a compact string.

| Input Range | Output | Example |
|---|---|---|
| >= 3600 | `Xh` | `"2h"` |
| >= 60 | `Xm` | `"5m"` |
| < 60 | `X` (integer) | `"12"` |

---

### FormatCooldownTimeDecimal(formattedTime)

```lua
local formatted = iconRow.FormatCooldownTimeDecimal(seconds)
```

**Static method.** Formats seconds with more precision.

| Input Range | Output | Example |
|---|---|---|
| < 10 | `X.X` | `"3.2"` |
| < 60 | `X` | `"45"` |
| < 3600 | `M:SS` | `"2:05"` |
| < 86400 | `Xh XXm` | `"1h 30m"` |
| >= 86400 | `Xd XXh` | `"2d 05h"` |

Note: Not currently invoked by `OnIconTick` (the `decimal_timer` option is marked "nop").

---

### AddSpecificIcon(identifierKey, spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate, iconSettings)

```lua
iconRow:AddSpecificIcon("myKey", spellId, nil, startTime, duration, nil, nil, nil, nil, nil, nil, nil, nil, nil, iconSettings)
```

Adds an icon only if not already present in the cache.

**Behavior:**
1. Returns immediately if `identifierKey` is `nil` or `""`.
2. If `self.AuraCache[identifierKey]` exists, skips (no duplicate).
3. Calls `SetIcon(...)` with all parameters including `iconSettings`.
4. Stores `identifierKey` on the icon frame and in `AuraCache`.

---

### AddSpecificIconWithTemplate(iconTemplateTable)

```lua
iconRow:AddSpecificIconWithTemplate({
    id = "uniqueKey",
    texture = "Interface\\Icons\\Spell_Nature_Rejuvenation",
    startTime = GetTime(),
    duration = 10,
    count = 3,
})
```

Convenience method. Calls `AddSpecificIcon` using fields from the template table:

- `identifierKey` = `iconTemplateTable.id`
- `spellId` = `iconTemplateTable.id`
- `startTime` = `iconTemplateTable.startTime`
- `duration` = `iconTemplateTable.duration`
- `count` = `iconTemplateTable.count`
- `iconSettings` = `iconTemplateTable` (the entire table is passed as per-icon settings)

All other parameters (`borderColor`, `forceTexture`, `descText`, etc.) are passed as `nil`.

---

### IsIconShown(identifierKey)

```lua
local isShown = iconRow:IsIconShown("myKey")
```

Returns `true` if an icon with the given `identifierKey` exists in `AuraCache`, `nil` otherwise.

---

### SetAuraWithIconTemplate(auraInfo, iconTemplateTable)

```lua
local iconFrame = iconRow:SetAuraWithIconTemplate(auraInfo, iconTemplateTable)
```

Convenience method for adding an icon from WoW aura data combined with a visual template.

**Parameters:**

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `auraInfo` | `aurainfo` | WoW aura data (from `C_UnitAuras`). Must have `expirationTime`, `duration`, `spellId`, `icon`, `applications`, `dispelName`, `sourceUnit`, `isStealable`, `name`, `isHelpful`, `timeMod`. |
| 2 | `iconTemplateTable` | `df_icontemplate` | Per-icon visual overrides (passed as `iconSettings`). |

**Behavior:**
- Derives `startTime` = `auraInfo.expirationTime - auraInfo.duration`.
- Calls `SetIcon` with aura fields mapped to the appropriate parameters and passes `auraInfo.expirationTime` as the `expirationTime` parameter.

**Returns:** `df_icongeneric`

---

### SetSpecificAuraWithIconTemplate(identifierKey, auraInfo, iconTemplateTable)

```lua
iconRow:SetSpecificAuraWithIconTemplate("myKey", auraInfo, iconTemplateTable)
```

Combines `AddSpecificIcon` deduplication with `SetAuraWithIconTemplate`. Only adds if `identifierKey` is not already in the cache.

**Behavior:**
1. Returns if `identifierKey` is `nil` or `""`.
2. If not in cache, calls `SetAuraWithIconTemplate(auraInfo, iconTemplateTable)`.
3. Stores `identifierKey` on the icon and in `AuraCache`.

---

### RemoveSpecificIcon(identifierKey)

```lua
iconRow:RemoveSpecificIcon("myKey")
```

Removes an icon previously added with an `identifierKey`.

**Behavior:**
1. Returns if `identifierKey` is `nil`/`""` or not in `AuraCache`.
2. Removes key from `AuraCache`.
3. Iterates the icon pool — hides the icon with the matching key; for remaining visible icons, re-adds their data to `AuraCache`.
4. Calls `AlignAuraIcons()` to compact and re-layout.

---

### ClearIcons(resetBuffs, resetDebuffs)

```lua
iconRow:ClearIcons()            -- clears all
iconRow:ClearIcons(true, false) -- clears buffs only
iconRow:ClearIcons(false, true) -- clears debuffs only
```

**Parameters:**

| # | Name | Type | Default | Description |
|---|---|---|---|---|
| 1 | `resetBuffs` | `boolean` | `true` | Clear icons where `isBuff == true`. |
| 2 | `resetDebuffs` | `boolean` | `true` | Clear icons where `isBuff == false`. |

**Behavior:**
1. Wipes `AuraCache`.
2. Iterates the pool — hides matching icons; surviving icons re-add their data to `AuraCache`.
3. Calls `AlignAuraIcons()`.

---

### SetStacks(iconFrame, bIsShown, stacksAmount)

```lua
iconRow:SetStacks(iconFrame, true, 5)
iconRow:SetStacks(iconFrame, false)
```

Shows or hides the stack text (and shadow) on a specific icon frame. Updates `iconFrame.stacks`.

---

### AlignAuraIcons()

```lua
iconRow:AlignAuraIcons()
```

Re-layouts all visible icons, compacting gaps from removed icons.

**Behavior:**
1. If pool is empty, hides the row.
2. Sorts the pool so shown icons come first (stable sort by visibility).
3. Counts visible icons.
4. Determines grow direction from `self.options.anchor.side` via `GrowDirectionBySide`.
5. Checks `ShouldCenterAlign` for the anchor side.
6. For each visible icon:
   - **First icon positioning:**
     - If `first_icon_use_anchor` is `true`: positions via `DetailsFramework:SetAnchor` using `self.options.anchor`.
     - Else if `ShouldCenterAlign[side]`: anchors at `"center"`.
     - Else if side is not a corner (`SideIsCorner`): anchors at `"left"` (grow right) or `"right"` (grow left).
     - Else: anchors at `"bottomleft"` or `"bottomright"`.
   - **Subsequent icons:** anchored relative to the previous icon with `icon_padding` (negated for grow-left).
7. Accumulates total width.
8. If `ShouldCenterAlign[side]` is `true`, sets the row width to the accumulated value.
9. Updates `shownAmount`, `NextIcon`, and shows the row if any icons remain.

---

### GetIconGrowDirection()

```lua
local direction = iconRow:GetIconGrowDirection()
```

Returns `1` (right) or `2` (left) by looking up `self.options.anchor.side` in `GrowDirectionBySide`.

---

### OnOptionChanged(optionName)

```lua
iconRow:OnOptionChanged(optionName)
```

Called when an option changes. Reapplies `backdrop_color` and `backdrop_border_color` from options. The `optionName` parameter is not currently used.

---

## Internal State

| Field | Type | Description |
|---|---|---|
| `IconPool` | `df_icongeneric[]` | Array of created icon frames (pooled and reused). |
| `NextIcon` | `number` | Next icon slot index (1-based). After adding icons, equals active count + 1. |
| `AuraCache` | `table` | Tracks displayed auras by `spellId`, `spellName`, `identifierKey`, plus flags `canStealOrPurge` and `hasEnrage`. |
| `shownAmount` | `number` | Number of currently visible icons. |

---

## Icon Frame (`df_icongeneric`) Structure

### Child Elements

| Child | Type | Sublevel | Description |
|---|---|---|---|
| `Texture` | `texture` | artwork 1 | Spell icon, inset 1px from edges. |
| `CooldownBrightnessTexture` | `texture` | artwork 2 | Additive-blend copy of the icon texture. Shrinks from top as cooldown progresses. |
| `Border` | `texture` | background | Black `ColorTexture` behind the icon. Reconfigured in `GetIcon` to use texture 130759 at overlay layer 7. |
| `CooldownTexture` | `texture` | overlay 6 | Horizontal bar that grows upward from bottom to show cooldown progress. |
| `CooldownEdge` | `texture` | overlay 7 | Colored edge at the top of the `CooldownTexture`. |
| `Cooldown` | `cooldown` | (frame) | Blizzard `CooldownFrameTemplate` (optional, controlled by `show_cooldown`). |
| `CountdownText` | `fontstring` | overlay | Remaining time text. |
| `StackText` | `fontstring` | overlay | Stack count. |
| `StackTextShadow` | `fontstring` | artwork | Shadow behind `StackText`. |
| `Desc` | `fontstring` | overlay | Description text above the icon. |

### Stored Properties

| Property | Type | Description |
|---|---|---|
| `spellId` | `number` | Spell ID. |
| `spellName` | `string` | Spell name. |
| `startTime` | `number` | Cooldown start time. |
| `duration` | `number` | Cooldown duration. |
| `endTime` | `number` | `startTime + duration` (or `0`). |
| `expirationTime` | `number` | Absolute expiration time (passed separately). |
| `timeRemaining` | `number` | Seconds remaining (updated by `OnIconTick`). |
| `count` | `number` | Stack count. |
| `stacks` | `number` | Current stacks. |
| `debuffType` | `string` | Debuff type string. |
| `caster` | `string` | Caster unit ID. |
| `canStealOrPurge` | `boolean` | Stealable/purgeable flag. |
| `isBuff` | `boolean` | `true` = buff, `false` = debuff. |
| `modRate` | `number` | Time rate modifier. |
| `identifierKey` | `any` or `nil` | Set by `AddSpecificIcon` / `SetSpecificAuraWithIconTemplate`. |
| `width` | `number` | Cached icon width (after scale). |
| `height` | `number` | Cached icon height (after scale). |
| `textureWidth` | `number` | Width of the Texture element. |
| `textureHeight` | `number` | Height of the Texture element. |
| `parentIconRow` | `df_iconrow_generic` | Back-reference to the parent icon row. |
| `options` | `table` | Reference to `self.options` from the parent icon row. |
| `cooldownLooper` | `timer` or `nil` | Looper handle, cancelled on hide or removal. |
| `currentCoords` | `table` | Last-applied texture coordinates (for caching). |

---

## Horizontal Swipe Visualization

The custom horizontal swipe is the distinguishing feature of the generic icon row. It works as follows:

1. `CooldownTexture` is a dark overlay anchored at the bottom of the icon. Its height grows from 0 to the full icon height as the cooldown progresses (0% → 100%).
2. `CooldownBrightnessTexture` is an additive-blend copy of the icon texture anchored from the top. Its bottom edge moves upward as the swipe grows, creating a "bright remaining / dark elapsed" effect.
3. `CooldownEdge` sits at the top edge of `CooldownTexture` (the boundary between elapsed and remaining time). Its color can interpolate from green to red if `swipe_progressive_color` is enabled.

This creates a visual where the icon progressively darkens from bottom to top with a colored edge line marking the current progress.

---

## Typical Usage Flow

```lua
-- 1. Create the generic icon row
local iconRow = DetailsFramework:CreateIconRowGeneric(parentFrame, "MyIconRow", {
    icon_width = 24,
    icon_height = 24,
    show_horizontal_swipe = true,
    show_text = true,
    swipe_progressive_color = true,
    show_cooldown = false,
})
iconRow:SetPoint("topleft", parentFrame, "topleft", 5, -5)

-- 2. Clear previous icons before updating
iconRow:ClearIcons()

-- 3. Add icons from aura data with a visual template
local iconTemplate = {width = 24, height = 24, scale = 1}
for _, auraInfo in ipairs(auras) do
    iconRow:SetAuraWithIconTemplate(auraInfo, iconTemplate)
end

-- 4. Or add keyed icons that won't duplicate
iconRow:AddSpecificIcon("buff_123", 123, nil, GetTime(), 30)

-- 5. Check if a keyed icon exists
if iconRow:IsIconShown("buff_123") then
    -- already displayed
end

-- 6. Remove a keyed icon
iconRow:RemoveSpecificIcon("buff_123")

-- 7. Icons with remove_on_finish auto-remove when expired
local autoRow = DetailsFramework:CreateIconRowGeneric(parentFrame, nil, {
    remove_on_finish = true,
})
autoRow:AddSpecificIcon("temp_buff", spellId, nil, GetTime(), 10)
-- After 10 seconds, the icon removes itself
```
