# DetailsFramework ElapsedTime Documentation

## Overview

The `df_elapsedtime` widget is a horizontal bar that displays time labels at regular intervals, such as `0:10`, `0:30`, `1:45`, `2:00`, etc. It is designed to sit above or alongside a scrollable timeline and provides visual time markers with optional vertical separator lines. Labels are dynamically created, positioned, and scaled based on the elapsed time and available width.

**Constructor:** `DF:CreateElapsedTimeFrame(parent, name, options)`

---

## Table of Contents

1. [Constructor](#1-constructor)
2. [Data Types](#2-data-types)
   - [df_elapsedtime_options](#21-df_elapsedtime_options)
   - [df_elapsedtime_label](#22-df_elapsedtime_label)
   - [df_elapsedtime](#23-df_elapsedtime)
3. [Methods](#3-methods)
   - [GetLabel](#31-getlabel)
   - [Reset](#32-reset)
   - [SetScrollChild](#33-setscrollchild)
   - [Refresh](#34-refresh)
4. [Mixins](#4-mixins)
5. [Default Options](#5-default-options)
6. [Usage Examples](#6-usage-examples)

---

## 1. Constructor

```lua
local elapsedTimeFrame = DF:CreateElapsedTimeFrame(parent, name, options)
```

Creates a new elapsed time frame widget.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `parent` | `frame` | The parent frame; also used as the initial `scrollChild` |
| `name` | `string?` | Optional global name for the frame |
| `options` | `df_elapsedtime_options?` | Optional table of overrides merged onto the defaults |

**Returns:** `df_elapsedtime` — the elapsed time frame widget

**Notes:**
- The frame is created with the `BackdropTemplate`.
- The backdrop and backdrop color are applied immediately from options.
- Three mixins are applied: `OptionsFunctions`, `LayoutFrame`, and `TimeLineElapsedTimeFunctions`.
- Options are built via `BuildOptionsTable`, merging user overrides onto the defaults.

---

## 2. Data Types

### 2.1 df_elapsedtime_options

Configuration table controlling the appearance and behavior of the elapsed time bar.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `backdrop` | `backdrop` | Tooltip background | Backdrop table passed to `SetBackdrop()` |
| `backdrop_color` | `number[]` | `{0.3, 0.3, 0.3, 0.7}` | RGBA color for `SetBackdropColor()` |
| `text_color` | `number[]` | `{1, 1, 1, 1}` | RGBA color for the time label text |
| `text_size` | `number` | `12` | Font size for the time labels |
| `text_font` | `string` | `"Arial Narrow"` | Font face for the time labels |
| `text_outline` | `outline` | `"NONE"` | Font outline style (`"NONE"`, `"OUTLINE"`, `"THICKOUTLINE"`) |
| `height` | `number` | `20` | Height of the elapsed time bar in pixels |
| `distance` | `number` | `200` | Base distance in pixels between each time label |
| `distance_min` | `number` | `50` | Minimum distance in pixels between labels (floor after scaling) |
| `draw_line` | `boolean` | `true` | Whether to draw vertical separator lines below each label |
| `draw_line_color` | `number[]` | `{1, 1, 1, 0.2}` | RGBA color for the vertical separator lines |
| `draw_line_thickness` | `number` | `1` | Width in pixels of the vertical separator lines |

### 2.2 df_elapsedtime_label

A fontstring with an attached vertical line texture.

| Field | Type | Description |
|-------|------|-------------|
| *(fontstring)* | `fontstring` | The label showing the formatted time text |
| `line` | `texture` | A vertical line texture anchored below the label |

### 2.3 df_elapsedtime

The elapsed time frame widget object.

| Field | Type | Description |
|-------|------|-------------|
| `labels` | `table<number, df_elapsedtime_label>` | Pool of created time labels, indexed by number |
| `scrollChild` | `frame` | The scroll child frame used for line height calculations |
| `options` | `df_elapsedtime_options` | The merged options table |

**Inherits from:** `frame`, `df_elapsedtime_mixin`, `df_optionsmixin`, `BackdropTemplate`

---

## 3. Methods

### 3.1 GetLabel

```lua
local label = elapsedTimeFrame:GetLabel(index)
```

Retrieves or creates a time label at the given index. Newly created labels get a fontstring and an attached vertical line texture. All labels are styled according to the current options on each call.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | The 1-based label index |

**Returns:** `df_elapsedtime_label` — the label fontstring (with `.line` texture)

**Notes:**
- Labels are cached in `self.labels[index]` and reused on subsequent calls.
- The line texture is anchored at `"topleft"` of the label, offset 2 pixels below.
- Font color, size, face, and outline are re-applied every call from `self.options`.
- If `draw_line` is `false`, the line texture is hidden.

---

### 3.2 Reset

```lua
elapsedTimeFrame:Reset()
```

Hides all previously created labels. Call this before a full redraw to clear stale labels.

**Parameters:** None

**Returns:** Nothing

---

### 3.3 SetScrollChild

```lua
elapsedTimeFrame:SetScrollChild(scrollChild)
```

Sets the scroll child frame reference. This frame is stored but the vertical line height is actually derived from `self:GetParent():GetParent():GetHeight()` during `Refresh`.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `scrollChild` | `frame` | The scroll child frame |

**Returns:** Nothing

---

### 3.4 Refresh

```lua
elapsedTimeFrame:Refresh(elapsedTime, scale)
```

Recalculates and positions all time labels based on the total elapsed time and a scale factor. This is the main update function — call it whenever the timeline data or zoom level changes.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `elapsedTime` | `number` | Total elapsed time in seconds that the full width represents |
| `scale` | `number` | Scale factor applied to the label distance (e.g., zoom level) |

**Returns:** Nothing (returns early if `elapsedTime` is `nil`)

**Behavior:**
1. Sets the frame height from `self.options.height`.
2. Calculates `pixelPerSecond` as `elapsedTime / effectiveArea`.
3. Scales the `distance` option by `scale`, clamping to `distance_min`.
4. Calculates the number of segments needed to fill the width.
5. For each segment, positions a label at the correct X offset and sets its text to the formatted time (`DF:IntegerToTimer`).
6. If the label's vertical line is shown, its height is set to the grandparent frame's height.

---

## 4. Mixins

The elapsed time frame receives three mixins at creation:

| Mixin | Source | Purpose |
|-------|--------|---------|
| `OptionsFunctions` | `DF.OptionsFunctions` | Provides `BuildOptionsTable` for merging default and user options |
| `LayoutFrame` | `DF.LayoutFrame` | Layout utilities for frame positioning |
| `TimeLineElapsedTimeFunctions` | `DF.TimeLineElapsedTimeFunctions` | The `GetLabel`, `Reset`, `SetScrollChild`, and `Refresh` methods |

---

## 5. Default Options

```lua
{
    backdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
    backdrop_color = {0.3, 0.3, 0.3, 0.7},
    text_color = {1, 1, 1, 1},
    text_size = 12,
    text_font = "Arial Narrow",
    text_outline = "NONE",
    height = 20,
    distance = 200,
    distance_min = 50,
    draw_line = true,
    draw_line_color = {1, 1, 1, 0.2},
    draw_line_thickness = 1,
}
```

---

## 6. Usage Examples

### 6.1 Basic Creation

```lua
local elapsedTimeBar = DF:CreateElapsedTimeFrame(myScrollFrame, "MyAddonElapsedTime")
elapsedTimeBar:SetPoint("topleft", myScrollFrame, "topleft", 0, 0)
elapsedTimeBar:SetPoint("topright", myScrollFrame, "topright", 0, 0)
```

### 6.2 Creation with Custom Options

```lua
local elapsedTimeBar = DF:CreateElapsedTimeFrame(myScrollFrame, nil, {
    text_size = 10,
    text_font = "Fonts\\FRIZQT__.TTF",
    text_color = {1, 0.82, 0, 1},
    height = 16,
    distance = 150,
    distance_min = 40,
    draw_line = true,
    draw_line_color = {1, 1, 1, 0.3},
    draw_line_thickness = 2,
    backdrop_color = {0.1, 0.1, 0.1, 0.9},
})
```

### 6.3 Refreshing the Timeline

```lua
-- totalTime: total combat duration in seconds
-- zoomScale: current zoom factor (1.0 = no zoom)
elapsedTimeBar:Reset()
elapsedTimeBar:Refresh(totalTime, zoomScale)
```

### 6.4 Updating on Zoom Change

```lua
local function OnZoomChanged(newScale)
    elapsedTimeBar:Reset()
    elapsedTimeBar:Refresh(combatDuration, newScale)
end
```

### 6.5 Setting a Custom Scroll Child

```lua
local scrollChild = myScrollFrame:GetScrollChild()
elapsedTimeBar:SetScrollChild(scrollChild)
```

### 6.6 Disabling Vertical Lines

```lua
local elapsedTimeBar = DF:CreateElapsedTimeFrame(myScrollFrame, nil, {
    draw_line = false,
})
```

### 6.7 Full Timeline Integration

```lua
local function BuildTimeline(scrollFrame, combatDuration, zoomScale)
    local elapsedTimeBar = DF:CreateElapsedTimeFrame(scrollFrame, "MyTimelineHeader", {
        height = 20,
        distance = 200,
        text_size = 11,
    })
    elapsedTimeBar:SetPoint("topleft", scrollFrame, "topleft", 0, 0)
    elapsedTimeBar:SetPoint("topright", scrollFrame, "topright", 0, 0)

    elapsedTimeBar:Refresh(combatDuration, zoomScale)

    return elapsedTimeBar
end
```
