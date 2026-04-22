# Icon Row System Documentation

## Overview

The icon row system provides a horizontal strip of spell/aura icons with optional cooldown overlays, countdown text, stack counts, and description labels. It is designed for displaying buffs, debuffs, or any spell-based indicators in a compact row that grows left or right.

The system is composed of three parts:

| Component | Purpose |
|---|---|
| `DetailsFramework:CreateIconRow()` | Entry point. Creates and returns a `df_iconrow` instance. |
| `default_icon_row_options` | Local table of default configuration values merged into every icon row instance. |
| `detailsFramework.IconMixin` | Methods mixed into each icon row instance (operate on `self`). |

### Supporting Types

| Type | Description |
|---|---|
| `df_icon` | A button frame representing a single icon in the row. Contains texture, border, cooldown, countdown text, stack text, and description fontstring. |
| `df_iconrow` | The container frame. Holds the icon pool, aura cache, and all mixin methods. |
| `df_icontemplate` | A data table describing an icon's visual properties (not directly consumed by methods, but defined as a class for external use). |

### Lookup Tables

The file defines several lookup tables used for icon layout based on anchor side:

| Table | Purpose |
|---|---|
| `GrowDirectionBySide` | Maps anchor `side` values (1–17) to a grow direction: `1` (right) or `2` (left). |
| `ShouldCenterAlign` | Maps anchor `side` values that should use center alignment (`9`, `10`, `12`). |
| `SideIsCorner` | Maps anchor `side` values that represent corner positions (`1`, `3`, `5`, `7`, `14`, `15`, `16`, `17`). |

---

## Creating an Icon Row

```lua
local iconRow = DetailsFramework:CreateIconRow(parent, name, options)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | yes | The parent frame the icon row is parented to. |
| 2 | `name` | `string` or `nil` | no | Global frame name. |
| 3 | `options` | `table` or `nil` | no | Overrides for `default_icon_row_options`. Keys not provided use defaults. |

### Returns

A `df_iconrow` — a `Frame` (with `BackdropTemplate`) that has `IconMixin` and `OptionsFunctions` mixed in.

### Initialization Sequence

1. A new `frame` is created with `BackdropTemplate`.
2. Internal state is initialized:
   - `IconPool` = `{}` — reusable pool of `df_icon` frames.
   - `NextIcon` = `1` — index of the next icon slot to use.
   - `AuraCache` = `{}` — tracks which spells/auras are currently displayed (by spellId, spellName, and identifierKey).
   - `shownAmount` = `0` — count of currently visible icons.
3. `IconMixin` is mixed in (all methods listed below).
4. `OptionsFunctions` is mixed in (provides `BuildOptionsTable`).
5. `BuildOptionsTable` merges the caller's `options` with `default_icon_row_options` into `self.options`.
6. Frame size is set to `(icon_width, icon_height + top_padding * 2)`.
7. Backdrop and backdrop colors are applied from options.

---

## Default Options (`default_icon_row_options`)

### Icon Size and Texture

| Option | Default | Description |
|---|---|---|
| `icon_width` | `20` | Width of each icon in pixels. |
| `icon_height` | `20` | Height of each icon in pixels. |
| `texcoord` | `{0.1, 0.9, 0.1, 0.9}` | Texture coordinates applied to each icon texture (crops edges). |

### Countdown Text

| Option | Default | Description |
|---|---|---|
| `show_text` | `true` | Whether the countdown timer text is displayed on icons with a duration. |
| `text_color` | `{1, 1, 1, 1}` | RGBA color of the countdown text. |
| `text_size` | `12` | Font size of the countdown text. |
| `text_font` | `"Arial Narrow"` | Font face for the countdown text. |
| `text_outline` | `"NONE"` | Font outline for the countdown text (e.g. `"NONE"`, `"OUTLINE"`, `"THICKOUTLINE"`). |
| `text_anchor` | `"center"` | Anchor point of the countdown text on the icon frame. |
| `text_rel_anchor` | `"center"` | Relative anchor point on the icon frame for countdown text. |
| `text_x_offset` | `0` | Horizontal offset for countdown text. |
| `text_y_offset` | `0` | Vertical offset for countdown text. |

### Description Text

| Option | Default | Description |
|---|---|---|
| `desc_text` | `true` | Whether description text can be shown (must also be passed via `descText` parameter in `SetIcon`). |
| `desc_text_color` | `{1, 1, 1, 1}` | RGBA color of the description text. |
| `desc_text_size` | `7` | Font size for description text. |
| `desc_text_font` | `"Arial Narrow"` | Font face for description text. |
| `desc_text_outline` | `"NONE"` | Font outline for description text. |
| `desc_text_anchor` | `"bottom"` | Anchor point on the description fontstring. |
| `desc_text_rel_anchor` | `"top"` | Relative anchor point on the icon frame (description is above the icon by default). |
| `desc_text_x_offset` | `0` | Horizontal offset for description text. |
| `desc_text_y_offset` | `2` | Vertical offset for description text. |

### Stack Text

| Option | Default | Description |
|---|---|---|
| `stack_text` | `true` | Whether stack count text is displayed (only shown when count > 1). |
| `stack_text_color` | `{1, 1, 1, 1}` | RGBA color of the stack text. |
| `stack_text_size` | `10` | Font size for stack text. |
| `stack_text_font` | `"Arial Narrow"` | Font face for stack text. |
| `stack_text_outline` | `"NONE"` | Font outline for stack text. |
| `stack_text_anchor` | `"center"` | Anchor point on the stack fontstring. |
| `stack_text_rel_anchor` | `"bottomright"` | Relative anchor point on the icon frame (stack number appears at bottom-right by default). |
| `stack_text_x_offset` | `0` | Horizontal offset for stack text. |
| `stack_text_y_offset` | `0` | Vertical offset for stack text. |

### Layout and Spacing

| Option | Default | Description |
|---|---|---|
| `left_padding` | `1` | Horizontal padding from the icon row edges. Also used as the offset for the first icon. |
| `top_padding` | `1` | Vertical padding from top and bottom edges. Affects the row frame height: `icon_height + top_padding * 2`. |
| `icon_padding` | `1` | Horizontal gap between adjacent icons. |
| `grow_direction` | `1` | Direction icons are placed: `1` = grow to right, `2` = grow to left. |
| `center_alignment` | `false` | If `true`, the icon row width is resized to match the total space used by visible icons after alignment. |
| `anchor` | `{side = 6, x = 2, y = 0}` | Anchor configuration. The `side` value is used by `GetIconGrowDirection()` to look up the grow direction from `GrowDirectionBySide`. |

### Backdrop

| Option | Default | Description |
|---|---|---|
| `backdrop` | `{}` | Backdrop table for the icon row frame. |
| `backdrop_color` | `{0, 0, 0, 0.5}` | RGBA backdrop color. |
| `backdrop_border_color` | `{0, 0, 0, 1}` | RGBA backdrop border color. |

### Cooldown

| Option | Default | Description |
|---|---|---|
| `cooldown_reverse` | `false` | If `true`, the cooldown swipe fills instead of draining. |
| `cooldown_swipe_enabled` | `true` | Whether the cooldown swipe animation is drawn. |
| `cooldown_edge_texture` | `"Interface\\Cooldown\\edge"` | Texture for the cooldown edge glow. |
| `surpress_blizzard_cd_timer` | `false` | If `true`, hides Blizzard's built-in cooldown countdown numbers. |
| `surpress_tulla_omni_cc` | `false` | If `true`, sets `noCooldownCount` on the cooldown frame to suppress OmniCC/tullaCC timers. |
| `on_tick_cooldown_update` | `true` | If `true`, icons with a duration use an `OnUpdate` script to refresh the countdown text every 0.05 seconds. |
| `decimal_timer` | `false` | If `true`, uses decimal format for countdown text (e.g. `"3.2"` instead of `"3"`). |

---

## Icon Row Methods (`IconMixin`)

### CreateIcon(iconName)

```lua
local iconFrame = iconRow:CreateIcon(iconName)
```

**Internal method.** Creates a new `df_icon` button frame with all child elements:

- `Texture` — the spell icon texture, inset 1px from all edges.
- `Border` — a black `ColorTexture` background behind the icon (acts as a border due to texture inset).
- `StackText` — fontstring at bottom-right for stack count, hidden by default.
- `StackTextShadow` — black fontstring behind `StackText` for a shadow effect, hidden by default.
- `Desc` — fontstring above the icon for description text, hidden by default.
- `Cooldown` — a `CooldownFrameTemplate` overlaying the icon.
- `CountdownText` — fontstring at center of the icon for remaining time, hidden by default.

Sets `stacks = 0` and registers an `OnHide` script that cancels any active `cooldownLooper` timer.

**Returns:** `df_icon`

---

### GetIcon()

```lua
local iconFrame = iconRow:GetIcon()
```

**Internal method.** Returns the next available icon from the pool, creating one via `CreateIcon` if needed.

**Behavior:**
1. Looks up `self.IconPool[self.NextIcon]`.
2. If not found, creates a new icon, applies backdrop, configures cooldown suppression options, positions countdown/desc/stack text from options, and stores it in the pool.
3. Clears all points on the icon frame.
4. Positions the icon based on `grow_direction`:
   - Direction `1` (right): first icon anchored `"left"` to the row's `"left"`, subsequent icons anchored `"left"` to previous icon's `"right"`.
   - Direction `2` (left): first icon anchored `"right"` to the row's `"right"`, subsequent icons anchored `"right"` to previous icon's `"left"`.
5. First icon uses `left_padding` as offset; subsequent icons use `icon_padding`.
6. Sets countdown text color from options.
7. Increments `NextIcon`.

**Returns:** `df_icon`

---

### SetIcon(spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate)

```lua
local iconFrame = iconRow:SetIcon(spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate)
```

Adds an icon to the row. This is the primary method for displaying a spell/aura.

**Parameters:**

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `spellId` | `number` | Spell ID. Used to look up the spell name and icon via `GetSpellInfo`. |
| 2 | `borderColor` | `table` or `nil` | RGBA color for the icon border. `nil` = transparent border. |
| 3 | `startTime` | `number` or `nil` | `GetTime()`-based start time of the aura. `nil` = no cooldown. |
| 4 | `duration` | `number` or `nil` | Duration in seconds. |
| 5 | `forceTexture` | `string` or `number` or `nil` | Override texture instead of the spell's icon. |
| 6 | `descText` | `table` or `nil` | Table with `.text`, `.text_color` (optional), `.text_size` (optional) for description label. |
| 7 | `count` | `number` or `nil` | Stack count. Shown only if > 1 and `stack_text` option is `true`. |
| 8 | `debuffType` | `string` or `nil` | Debuff type (e.g. `"Magic"`, `"Curse"`, `""` for enrage). |
| 9 | `caster` | `string` or `nil` | Unit ID of the caster. |
| 10 | `canStealOrPurge` | `boolean` or `nil` | Whether the aura can be stolen/purged. |
| 11 | `spellName` | `string` or `nil` | Override spell name. Falls back to `GetSpellInfo` result. |
| 12 | `isBuff` | `boolean` or `nil` | `true` = buff, `false` = debuff. Used by `ClearIcons` for selective clearing. |
| 13 | `modRate` | `number` or `nil` | Time modification rate (defaults to `1`). Affects countdown calculation. |

**Behavior:**
1. Calls `GetSpellInfo(spellId)` for the icon texture and name.
2. If no texture is found (and no `forceTexture`), returns `nil`.
3. Obtains an icon frame via `GetIcon()`.
4. Sets the icon texture with `texcoord` from options.
5. Applies border color.
6. If `startTime` is provided:
   - Calculates `timeRemaining` and `expirationTime`.
   - Starts the Blizzard cooldown animation via `CooldownFrame_Set`.
   - If `show_text` is enabled, shows countdown text and optionally registers `OnUpdate` for tick-based updates.
   - Configures cooldown visual options (reverse, swipe, edge texture, timer suppression).
7. If `descText` is provided and `desc_text` option is enabled, shows and configures the description fontstring.
8. If `count > 1` and `stack_text` option is enabled, shows the stack text.
9. Sets icon frame size from options.
10. Updates the icon row frame width to fit all icons: `(left_padding * 2) + (icon_padding * (N-1)) + (icon_width * N)`.
11. Stores all aura metadata on the icon frame (`spellId`, `startTime`, `duration`, `count`, `debuffType`, `caster`, `canStealOrPurge`, `isBuff`, `spellName`, `modRate`).
12. Adds `spellId` and `spellName` to `AuraCache`. Also tracks `canStealOrPurge` and `hasEnrage` flags.
13. Shows the icon row frame.

**Returns:** `df_icon` or `nil` if no texture could be resolved.

---

### AddSpecificIcon(identifierKey, spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate)

```lua
iconRow:AddSpecificIcon("myUniqueKey", spellId, borderColor, startTime, duration)
```

Adds an icon only if it is not already in the cache. Uses `identifierKey` as the cache key instead of `spellId`.

**Behavior:**
1. If `identifierKey` is `nil` or `""`, returns immediately.
2. If `self.AuraCache[identifierKey]` already exists, returns (no duplicate).
3. Calls `SetIcon(...)` to create the icon.
4. Stores the `identifierKey` on the icon frame.
5. Marks `identifierKey` as present in `AuraCache`.

This is useful for non-spell icons or when the same spellId can appear multiple times with different keys.

---

### RemoveSpecificIcon(identifierKey)

```lua
iconRow:RemoveSpecificIcon("myUniqueKey")
```

Removes an icon previously added with `AddSpecificIcon`.

**Behavior:**
1. If `identifierKey` is `nil`/`""` or not in `AuraCache`, returns.
2. Removes the key from `AuraCache`.
3. Iterates the icon pool:
   - Hides and clears the icon with the matching `identifierKey`.
   - For remaining visible icons, re-adds their `spellId`/`spellName` and flags to the cache.
4. Calls `AlignAuraIcons()` to re-layout remaining icons.

---

### ClearIcons(resetBuffs, resetDebuffs)

```lua
iconRow:ClearIcons()            -- clears all
iconRow:ClearIcons(true, false) -- clears buffs only
iconRow:ClearIcons(false, true) -- clears debuffs only
```

Removes icons from the row. Both parameters default to `true` if not provided (or `nil`).

**Parameters:**

| # | Name | Type | Default | Description |
|---|---|---|---|---|
| 1 | `resetBuffs` | `boolean` | `true` | Clear icons where `isBuff == true`. |
| 2 | `resetDebuffs` | `boolean` | `true` | Clear icons where `isBuff == false`. |

**Behavior:**
1. Wipes `AuraCache`.
2. Iterates the icon pool up to `NextIcon - 1`:
   - Icons with `isBuff == nil` are always cleared.
   - Buff icons are cleared if `resetBuffs` is true.
   - Debuff icons are cleared if `resetDebuffs` is true.
   - Surviving icons have their data re-added to `AuraCache`.
3. Calls `AlignAuraIcons()` to compact and re-layout remaining icons.

---

### AlignAuraIcons()

```lua
iconRow:AlignAuraIcons()
```

Re-layouts all visible icons, compacting gaps left by removed icons.

**Behavior:**
1. If the pool is empty, hides the icon row.
2. Sorts the icon pool so shown icons come before hidden ones.
3. Counts visible icons (`shownAmount`).
4. Re-anchors each visible icon sequentially based on `grow_direction`:
   - Direction `1` (right): left-to-right anchoring.
   - Direction `2` (left): right-to-left anchoring.
5. Accumulates total width from icon widths (scaled) plus padding.
6. If `center_alignment` is `true`, sets the row width to the accumulated value.
7. Updates `self.shownAmount` and `self.NextIcon` to `countStillShown + 1`.
8. Shows the row if any icons are still visible.

---

### SetStacks(iconFrame, bIsShown, stacksAmount)

```lua
iconRow:SetStacks(iconFrame, true, 5)  -- show "5"
iconRow:SetStacks(iconFrame, false)    -- hide stacks
```

Manually sets or hides the stack text on a specific icon frame.

**Parameters:**

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `iconFrame` | `df_icon` | The icon frame to update. |
| 2 | `bIsShown` | `boolean` | `true` to show stacks, `false` to hide. |
| 3 | `stacksAmount` | `number` or `nil` | Stack count to display (required if `bIsShown` is `true`). |

Updates both `StackText` and `StackTextShadow` fontstrings, and sets `iconFrame.stacks`.

---

### OnIconTick(deltaTime)

```lua
-- Registered internally as an OnUpdate script on icon frames
iconFrame:SetScript("OnUpdate", self.OnIconTick)
```

**Internal method.** Called every frame on icons that have a duration and `on_tick_cooldown_update` is enabled.

**Behavior:**
- Throttled to update every 0.05 seconds.
- Recalculates `timeRemaining` from `expirationTime - GetTime()`, adjusted by `modRate`.
- Updates the `CountdownText` using either `FormatCooldownTime` or `FormatCooldownTimeDecimal` depending on `decimal_timer` option.
- Clears text if time has expired.

---

### FormatCooldownTime(thisTime)

```lua
local formatted = iconRow.FormatCooldownTime(seconds)
```

**Static method** (called without `self`). Formats seconds into a compact string.

| Input Range | Output Format | Example |
|---|---|---|
| >= 3600 | `Xh` | `"2h"` |
| >= 60 | `Xm` | `"5m"` |
| < 60 | `X` (integer) | `"12"` |

---

### FormatCooldownTimeDecimal(formattedTime)

```lua
local formatted = iconRow.FormatCooldownTimeDecimal(seconds)
```

**Static method** (called without `self`). Formats seconds into a more precise string.

| Input Range | Output Format | Example |
|---|---|---|
| < 10 | `X.X` | `"3.2"` |
| < 60 | `X` (integer) | `"45"` |
| < 3600 | `M:SS` | `"2:05"` |
| < 86400 | `Xh XXm` | `"1h 30m"` |
| >= 86400 | `Xd XXh` | `"2d 05h"` |

---

### GetIconGrowDirection()

```lua
local direction = iconRow:GetIconGrowDirection()
```

Returns the grow direction (`1` = right, `2` = left) by looking up `self.options.anchor.side` in `GrowDirectionBySide`.

---

### OnOptionChanged(optionName)

```lua
iconRow:OnOptionChanged(optionName)
```

Called when an option changes (via the `OptionsFunctions` system). Reapplies `backdrop_color` and `backdrop_border_color` from options. The `optionName` parameter is not currently used.

---

## Internal State

| Field | Type | Description |
|---|---|---|
| `IconPool` | `df_icon[]` | Array of created icon frames (pooled and reused). |
| `NextIcon` | `number` | Index of the next icon slot to fill (1-based). After `SetIcon`, equals the count of active icons + 1. |
| `AuraCache` | `table` | Tracks displayed auras. Keys include `spellId` (number), `spellName` (string), `identifierKey` (any), plus flags `canStealOrPurge` (boolean) and `hasEnrage` (boolean). |
| `shownAmount` | `number` | Number of currently visible icons (updated by `AlignAuraIcons`). |

---

## Icon Frame (`df_icon`) Structure

Each icon frame is a `button` with `BackdropTemplate`.

### Child Elements

| Child | Type | Description |
|---|---|---|
| `Texture` | `texture` | The spell icon texture, inset 1px from edges. |
| `Border` | `texture` | Black `ColorTexture` behind the icon (visible border from the 1px inset). |
| `StackText` | `fontstring` | Stack count at bottom-right. |
| `StackTextShadow` | `fontstring` | Black shadow behind `StackText`. |
| `Desc` | `fontstring` | Description text above the icon. |
| `Cooldown` | `cooldown` | Blizzard cooldown frame overlay. |
| `CountdownText` | `fontstring` | Remaining time text at center of icon. |

### Stored Properties

| Property | Type | Description |
|---|---|---|
| `spellId` | `number` | Spell ID of the displayed aura. |
| `spellName` | `string` | Name of the spell. |
| `startTime` | `number` | `GetTime()`-based start time. |
| `duration` | `number` | Aura duration in seconds. |
| `count` | `number` | Stack count. |
| `stacks` | `number` | Current stacks (also set by `SetStacks`). |
| `debuffType` | `string` | Debuff type string. |
| `caster` | `string` | Unit ID of the caster. |
| `canStealOrPurge` | `boolean` | Whether the aura is stealable/purgeable. |
| `isBuff` | `boolean` | `true` = buff, `false` = debuff. |
| `modRate` | `number` | Time rate modifier. |
| `timeRemaining` | `number` | Seconds remaining (updated by `OnIconTick`). |
| `expirationTime` | `number` | Absolute expiration time (`startTime + duration`). |
| `lastUpdateCooldown` | `number` | Timestamp of last `OnIconTick` update. |
| `identifierKey` | `string` or `nil` | Set only when added via `AddSpecificIcon`. |
| `width` | `number` | Icon width from options at time of `SetIcon`. |
| `height` | `number` | Icon height from options at time of `SetIcon`. |
| `textureWidth` | `number` | Actual width of the Texture element. |
| `textureHeight` | `number` | Actual height of the Texture element. |
| `parentIconRow` | `df_iconrow` | Back-reference to the parent icon row. |
| `cooldownLooper` | `timer` or `nil` | Timer handle cancelled on hide. |

---

## Typical Usage Flow

```lua
-- 1. Create the icon row
local iconRow = DetailsFramework:CreateIconRow(parentFrame, "MyAddonIconRow", {
    icon_width = 24,
    icon_height = 24,
    grow_direction = 1,    -- grow right
    show_text = true,
    decimal_timer = true,
    icon_padding = 2,
})
iconRow:SetPoint("topleft", parentFrame, "topleft", 5, -5)

-- 2. Before updating, clear previous icons
iconRow:ClearIcons()

-- 3. Add icons (e.g., from aura iteration)
for each aura do
    iconRow:SetIcon(
        aura.spellId,
        borderColor,        -- or nil
        aura.startTime,     -- or nil for no cooldown
        aura.duration,
        nil,                -- forceTexture
        nil,                -- descText
        aura.applications,  -- stack count
        aura.debuffType,
        aura.sourceUnit,
        aura.isStealable,
        aura.name,
        aura.isHelpful      -- true = buff
    )
end

-- 4. To add a unique/keyed icon that won't duplicate
iconRow:AddSpecificIcon("special_marker", spellId, {1, 0, 0, 1})

-- 5. To remove a keyed icon later
iconRow:RemoveSpecificIcon("special_marker")

-- 6. Selective clearing
iconRow:ClearIcons(true, false)  -- clear buffs only, keep debuffs
```

### AuraCache Usage

The `AuraCache` table serves as a fast lookup for whether a spell is currently displayed. It is keyed by both `spellId` and `spellName`, and also stores aggregate flags:

- `AuraCache[spellId]` = `true` — the spell is shown.
- `AuraCache[spellName]` = `true` — the spell is shown (by name).
- `AuraCache[identifierKey]` = `true` — a specific-keyed icon is shown.
- `AuraCache.canStealOrPurge` = `true` — at least one shown aura is stealable/purgeable.
- `AuraCache.hasEnrage` = `true` — at least one shown aura is an enrage (empty-string debuffType).

External code can check `iconRow.AuraCache[spellId]` to avoid redundant `SetIcon` calls without needing `AddSpecificIcon`.
