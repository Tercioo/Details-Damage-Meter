# DetailsFramework — Timeline System

## Overview

`timeline.lua` implements a scrollable, zoomable timeline UI used to display time-based events as horizontal rows of blocks. Each row represents a *track* (e.g. a player or a spell), and each event in the track is rendered as a *block* positioned at its exact time offset. Optionally, each block can have an attached *block-length* bar that visualizes a duration (e.g. an aura).

**Problems it solves:**
- Visualizing ordered sequences of timed events across multiple parallel tracks.
- Inspecting cooldown timelines, aura durations, or any time-indexed data.
- Providing scrolling, panning, and zooming so any time range can be inspected.

**Typical use:**
1. Create the timeline frame with `CreateTimeLineFrame`.
2. Feed it a data table with `SetData`.
3. The timeline renders immediately and stays interactive.

---

## 1. Entry Point — `CreateTimeLineFrame`

```lua
local timeline, headerFrame, headerBody = detailsFramework:CreateTimeLineFrame(
    parent,           -- (frame)                  Parent WoW frame.
    name,             -- (string)                 Global name given to the ScrollFrame. "$parent" is resolved.
    timelineOptions,  -- (df_timeline_options?)   Option overrides merged on top of defaults.
    elapsedtimeOptions -- (df_elapsedtime_options?) Passed directly to the elapsed-time bar constructor.
)
```

**Returns:**

| Value | Type | Description |
|---|---|---|
| `timeline` | `df_timeline` | The main timeline object (a ScrollFrame). Always returned. |
| `headerFrame` | `df_timeline_header?` | Only present when `options.header_detached = true`. Separate scrollframe holding row headers. |
| `headerBody` | `frame?` | Scroll child of `headerFrame`. Only present when `header_detached = true`. |

### Initialization sequence

1. A `ScrollFrame` is created and sized to `options.width × options.height`.
2. Mixins are applied: `TimeLineMixin`, `OptionsFunctions`, `LayoutFrame`, `LineIndicatorMixin`.
3. A `frame` body (`df_timeline_body`) is set as the scroll child; initial placeholder size 800 × 800.
4. The options table is merged from `timeline_options` defaults + caller overrides via `BuildOptionsTable`.
5. An elapsed-time bar (`df_elapsedtime`) is created at the top of the body.
6. Three external sliders are created as siblings of `parent` (not children of the timeline):
   - **Horizontal slider** — pans the timeline left/right.
   - **Scale slider** — zooms the timeline (maps to `currentScale`).
   - **Vertical slider** — scrolls rows up/down.
7. Mouse-wheel and drag handlers are installed on the body.
8. A resize grip is created at the bottom-right corner.
9. `RefreshResize()` and `OnSizeChanged()` are called to finalize slider positions.

> **Important:** The three sliders are created as children of `parent` (the caller's frame), not of the timeline ScrollFrame itself. They must be positioned manually if they need to appear adjacent to the timeline.

---

## 2. Timeline Object (`df_timeline`)

### Key fields

| Field | Type | Description |
|---|---|---|
| `type` | `"timeline"` | Component type identifier. |
| `body` | `df_timeline_body` | The scroll child frame. All rows and blocks live inside it. |
| `lines` | `df_timeline_line[]` | Cached array of row objects. Created lazily by `GetLine`. |
| `data` | `df_timeline_scrolldata` | Currently loaded data table (set by `SetData`). |
| `options` | `df_timeline_options` | Merged options table. |
| `currentScale` | `number` | Active zoom multiplier (default `0.5`). |
| `oldScale` | `number` | Previous scale value, stored before a zoom change. |
| `pixelPerSecond` | `number` | Cached `options.pixels_per_second` value (unscaled). |
| `totalLength` | `number` | Total timeline duration in seconds, from `data.length`. |
| `headerWidth` | `number` | Effective header width in pixels (0 when `header_detached`). |
| `defaultColor` | `table` | RGBA color fallback for blocks, from `data.defaultColor`. |
| `scrolledWidth` | `number` | Last recorded horizontal scroll delta (used by body). |
| `elapsedTimeFrame` | `df_elapsedtime` | The time-ruler bar drawn at the top of the body. |
| `horizontalSlider` | `slider` | External horizontal pan control. |
| `scaleSlider` | `slider` | External zoom control. |
| `verticalSlider` | `slider` | External vertical scroll control. |
| `resizeButton` | `button` | The bottom-right resize grip. |
| `headerFrame` | `df_timeline_header?` | Present only when `header_detached = true`. |
| `headerBody` | `frame?` | Present only when `header_detached = true`. |
| `delayButtonRefreshTimer` | `timer` | Debounce timer for per-pixel button refresh. |
| `onClickCallback` | `function` | Stored callback for per-pixel button clicks. |
| `onClickCallbackArgs` | `any[]` | Extra args forwarded to the click callback. |

---

## 3. Options (`df_timeline_options`)

All fields are optional overrides. Defaults are listed below.

### Dimensions

| Field | Default | Description |
|---|---|---|
| `width` | `400` | Timeline frame width in pixels. |
| `height` | `700` | Timeline frame height in pixels. |
| `line_height` | `20` | Pixel height of each row. |
| `line_padding` | `1` | Vertical gap between rows in pixels. |
| `auto_height` | `false` | If `true`, the timeline height is auto-set to `(line_height + line_padding) * #lines + 40`. |
| `header_width` | `150` | Width of the left-side header column (label + icon area). |
| `header_detached` | `false` | If `true`, row headers are placed in a separate scrollframe (`headerFrame`). |
| `elapsed_timeline_height` | `20` | Height of the time ruler bar at the top. |
| `show_elapsed_timeline` | `true` | Whether to reserve vertical space for the elapsed time bar. |

### Scaling and zoom

| Field | Default | Description |
|---|---|---|
| `pixels_per_second` | `20` | Base pixel density: how many pixels represent one second before scaling. |
| `scale_min` | `0.15` | Minimum allowed zoom level (scale slider lower bound). |
| `scale_max` | `1` | Maximum allowed zoom level (scale slider upper bound). |
| `zoom_out_zero` | `false` | If `true`, zooming out via mouse wheel snaps the scale to `0` instead of `scale_min`. |
| `can_resize` | `false` | Whether the resize grip is active. |

### Per-pixel buttons

| Field | Default | Description |
|---|---|---|
| `use_perpixel_buttons` | `false` | If `true`, creates one invisible clickable button per second across the body. Used for click-by-second interaction via `SetOnClickCallback`. |

### Visuals

| Field | Default | Description |
|---|---|---|
| `backdrop` | Tooltip border style | Row backdrop table. |
| `backdrop_color` | `{0, 0, 0, 0.2}` | Default row background color. |
| `backdrop_color_highlight` | `{0.2, 0.2, 0.2, 0.4}` | Row background color on mouse hover. |
| `backdrop_border_color` | `{0.1, 0.1, 0.1, 0.2}` | Row border color. |
| `slider_backdrop` | Tooltip border style | Slider frame backdrop table. |
| `slider_backdrop_color` | `{0, 0, 0, 0.2}` | Slider background color. |
| `slider_backdrop_border_color` | `{0.1, 0.1, 0.1, 0.2}` | Slider border color. |
| `title_template` | `"ORANGE_FONT_TEMPLATE"` | Font template for the row label. |
| `text_tempate` | `"OPTIONS_FONT_TEMPLATE"` | (Typo in source.) Secondary text font template. |

### Callbacks

All callbacks are optional. They are stored in the options table and called at specific lifecycle points.

#### Row-level callbacks

| Field | Signature | When called |
|---|---|---|
| `on_enter` | `fun(line: df_timeline_line)` | Mouse enters a row. Default: sets highlight backdrop color. |
| `on_leave` | `fun(line: df_timeline_line)` | Mouse leaves a row. Default: restores normal backdrop color. |
| `on_create_line` | `fun(line: df_timeline_line)` | Called once when a row frame is first created (lazy). |
| `on_refresh_line` | `fun(line: df_timeline_line)` | Called after every `SetBlocksFromData` for a row during `RefreshTimeLine`. |

#### Block-level callbacks

| Field | Signature | When called |
|---|---|---|
| `block_on_create` | `fun(block: df_timeline_line_block)` | Called once when a block button is first created. |
| `block_on_set_data` | `fun(block: df_timeline_line_block, data: df_timeline_block_data)` | Called every refresh after block positioning/sizing. Use to apply custom visuals. |
| `block_on_enter` | `fun(block: df_timeline_line_block)` | Mouse enters a block. Set as the block's `OnEnter` script at creation time. |
| `block_on_leave` | `fun(block: df_timeline_line_block)` | Mouse leaves a block. |
| `block_on_click` | `fun(block: df_timeline_line_block)` | Block is clicked. Enables `SetMouseClickEnabled(true)` on the block when set. |

#### Block-length (aura duration bar) callbacks

The `_auralength` names take priority over `_blocklength` names when both are defined.

| Field | Signature | When called |
|---|---|---|
| `block_on_create_auralength` / `block_on_create_blocklength` | `fun(blockLength: df_timeline_line_blocklength)` | Called once when a block-length frame is created. |
| `block_on_enter_auralength` / `block_on_enter_blocklength` | `fun(blockLength: df_timeline_line_blocklength)` | Mouse enters the duration bar. |
| `block_on_leave_auralength` / `block_on_leave_blocklength` | `fun(blockLength: df_timeline_line_blocklength)` | Mouse leaves the duration bar. |
| `block_on_click_auralength` / `block_on_click_blocklength` | `fun(blockLength: df_timeline_line_blocklength, button: string)` | Duration bar is clicked. |

---

## 4. Data Model

### `df_timeline_scrolldata` — top-level data table

```lua
{
    length        = number,          -- Total duration in seconds (defines the body width).
    defaultColor  = {r, g, b, a},   -- Fallback RGBA for block rendering.
    useIconOnBlocks = boolean,       -- If true, blocks are rendered as square icons.
    lines         = df_timeline_linedata[], -- Array of row definitions.
}
```

### `df_timeline_linedata` — per-row data

```lua
{
    spellId    = number,            -- Spell ID used as the default icon source for blocks.
    icon       = string|number,     -- Texture path or ID for the row header icon.
    coords     = {l,r,t,b}?,       -- Optional tex-coord override for the header icon.
    text       = string?,           -- Row label text.
    lineHeight = number?,           -- Per-row height override; falls back to options.line_height.
    disabled   = boolean?,          -- If true, mouse interaction is disabled for this row.
    type       = string|number?,    -- User-defined identifier for the row (not used internally).
    timeline   = df_timeline_block_data[], -- Array of event entries for this row.
}
```

### `df_timeline_block_data` — per-event data

Events are defined as indexed + named tables. Indexed fields are positional:

```lua
{
    [1] = number,    -- timeInSeconds: when the event starts.
    [2] = number,    -- length: visual width of the block in seconds (when not using icons).
    [3] = boolean?,  -- isAura: if true, the blockLength duration bar is shown.
    [4] = number?,   -- auraDuration: length of the aura bar in seconds.
    [5] = number?,   -- blockSpellId: overrides the row spellId for icon lookup on this block.

    -- Named optional fields:
    payload        = any,    -- Arbitrary caller data stored in block.info.payload.
    customIcon     = any,    -- Overrides the block icon texture.
    customName     = string, -- Overrides the block label text.
    isIconRow      = boolean?, -- If true, this block is placed to the right of the previous block.
    showRightIcon  = boolean?, -- If true, the icon is shown at the right edge of the aura bar.
    auraLengthColor = any,    -- RGBA or color spec for the aura bar color (default white 50%).
    auraLengthTexture = string?, -- Texture for the aura bar (tiled horizontally).
    auraHeight     = number?, -- Height override for the aura bar.
    auraYOffset    = number?, -- Y offset for the aura bar relative to the block icon.
}
```

**Minimal event (no icon):**
```lua
{ 10, 5 }  -- starts at 10 seconds, 5 seconds wide
```

**Event with aura:**
```lua
{ 10, 0, true, 30 }  -- starts at 10s, isAura=true, 30-second aura bar
```

---

## 5. Methods

All methods are called on the `df_timeline` object returned by `CreateTimeLineFrame`.

### Data

#### `SetData(data)`
```lua
timeline:SetData(data: df_timeline_scrolldata)
```
Stores `data` on the timeline and calls `RefreshTimeLine()`. This is the primary way to populate the timeline. All existing lines are reset before the new data is rendered.

---

#### `GetData()`
```lua
local data = timeline:GetData()  -- returns df_timeline_scrolldata
```
Returns the currently stored data table.

---

### Rendering

#### `RefreshTimeLine(bDelayButtonRefresh?, bFromScale?)`
```lua
timeline:RefreshTimeLine()
timeline:RefreshTimeLine(true, false)  -- delay per-pixel button refresh by 0.1s
timeline:RefreshTimeLine(true, true)   -- delay buttons, anchor horizontal scroll to time under mouse
```
Recalculates and redraws the entire timeline:
1. Computes `bodyWidth = data.length × pixels_per_second × currentScale`.
2. Sets body width and adjusts horizontal slider max value.
3. Calculates body height: `(line_height + line_padding) × #lines + 40`.
4. Resets all lines, then calls `SetBlocksFromData` for each.
5. Refreshes the elapsed-time bar and line indicator overlay.
6. If `use_perpixel_buttons` is true, refreshes per-second clickable buttons (optionally debounced by 0.1 s when `bDelayButtonRefresh = true`).
7. If `bFromScale = true`, the horizontal scroll position is anchored to the time currently under the mouse cursor.

Call this whenever data changes, the window is resized, or visual options change.

---

#### `ResetAllLines()`
```lua
timeline:ResetAllLines()
```
Hides all row frames and their blocks. Does not destroy them; they are reused on the next refresh.

---

#### `RefreshPerPixelButtons()`
```lua
timeline:RefreshPerPixelButtons()
```
Creates or resizes per-second button buttons across the body. Only meaningful when `use_perpixel_buttons = true`. Called automatically by `RefreshTimeLine`.

---

#### `RefreshResize()`
```lua
timeline:RefreshResize()
```
Reads `options.can_resize` and either shows or hides the resize grip button, enables or disables frame resizing, and hooks or unhooks `OnSizeChanged`.

---

#### `OnSizeChanged()`
```lua
timeline:OnSizeChanged()
```
Repositions and resizes the three sliders to match the current timeline dimensions, then calls `RefreshTimeLine` if data is loaded. Called automatically when the frame is resized.

---

### Scale and zoom

#### `GetScale()`
```lua
local scale = timeline:GetScale()  -- number
```
Returns `currentScale`.

---

#### `SetScale(scale)`
```lua
timeline:SetScale(0.5)
```
Clamps `scale` to `[scale_min, scale_max]`, sets the scale slider value, and calls `RefreshTimeLine`. This is the programmatic zoom API.

---

#### `SetCanResize(bCanResize)`
```lua
timeline:SetCanResize(true)
```
Updates `options.can_resize` and calls `RefreshResize`.

---

### Scrolling

#### `GetHorizontalScrolledWidth()`
```lua
local delta = timeline:GetHorizontalScrolledWidth()  -- number
```
Returns the last recorded horizontal scroll delta (set during mouse-wheel events).

---

#### `HideVerticalScroll()`
```lua
timeline:HideVerticalScroll()
```
Hides the vertical slider frame.

---

### Per-pixel click callbacks

#### `SetOnClickCallback(callback, ...)`
```lua
timeline:SetOnClickCallback(function(second, ...)
    -- second: 0-based integer second that was clicked
end, extraArg1, extraArg2)
```
Only meaningful when `use_perpixel_buttons = true`. Stores the callback and applies it to all existing per-pixel buttons via `UpdateOnClickCallback`. The callback receives `(second - 1, ...)` where `second` is the 1-based button index.

---

#### `UpdateOnClickCallback(button?)`
```lua
timeline:UpdateOnClickCallback()         -- re-applies to all visible buttons
timeline:UpdateOnClickCallback(button)   -- applies to a single button
```
Assigns the stored click callback to per-pixel buttons.

---

### Spatial queries

#### `GetLine(index)`
```lua
local line = timeline:GetLine(1)  -- df_timeline_line
```
Returns the row at `index`. Creates it lazily if it does not yet exist.

---

#### `GetAllLines()`
```lua
local lines = timeline:GetAllLines()  -- df_timeline_line[]
```
Returns the internal `lines` array. May contain `nil` holes for unvisited indices.

---

#### `GetLineUnderMouse()`
```lua
local line = timeline:GetLineUnderMouse()  -- df_timeline_line?
```
Iterates all lines and returns the first one currently under the cursor, or `nil`.

---

#### `GetBlockUnderMouse()`
```lua
local block = timeline:GetBlockUnderMouse()  -- df_timeline_line_block?
```
Iterates all lines and blocks and returns the first visible block under the cursor, or `nil`.

---

#### `GetBlockOrLengthUnderMouse()`
```lua
local element = timeline:GetBlockOrLengthUnderMouse()  -- df_timeline_line_block|df_timeline_line_blocklength?
```
Like `GetBlockUnderMouse`, but also checks the aura/duration bar child of each block. Returns the block-length frame if the cursor is over a duration bar.

---

#### `GetBlocksAtTime(time?)`
```lua
local blocks = timeline:GetBlocksAtTime(15.5)  -- df_timeline_line_block[]
local blocks = timeline:GetBlocksAtTime()       -- uses GetTimeUnderMouse()
```
Returns all visible blocks whose time range `[block.info.time, block.info.time + blockWidth/pixelsPerSecond]` contains `time`. If `time` is `nil`, uses the current cursor position.

---

#### `GetTimeUnderMouse()`
```lua
local seconds = timeline:GetTimeUnderMouse()  -- number
```
Converts the cursor's X position relative to the body's left edge into a time value in seconds, accounting for the current scale:
```
time = (cursorX - body.left) / (pixelPerSecond × currentScale)
```
Returns `0` if `pixelPerSecond` is not yet set.

---

#### `GetBodyWidthUnderMouse()`
```lua
local pixels = timeline:GetBodyWidthUnderMouse()  -- number
```
Returns the raw pixel distance from the body's left edge to the cursor.

---

#### `GetEffectivePixelPerSecond()`
```lua
local pps = timeline:GetEffectivePixelPerSecond()  -- number
```
Returns `pixelPerSecond × currentScale` — the actual pixel density at the current zoom level.

---

## 6. Row Object (`df_timeline_line`)

Rows are created lazily by `GetLine(index)` and stored in `timeline.lines`.

### Key fields

| Field | Type | Description |
|---|---|---|
| `type` | `"line"` | Component type. |
| `index` | `number` | Position in `timeline.lines`. |
| `dataIndex` | `number` | Index into `data.lines` for the current refresh cycle. |
| `spellId` | `number` | Copied from `lineData.spellId`. |
| `lineData` | `df_timeline_linedata` | Reference to the current line data. |
| `icon` | `df_image` | Icon widget in the row header. |
| `text` | `df_label` | Text label in the row header. |
| `lineHeader` | `frame` | The header sub-frame (either a child of the line or of `headerBody`). |
| `blocks` | `df_timeline_line_block[]` | Cached block frames for this row. |
| `enabled` | `boolean` | Whether mouse interaction is enabled. |
| `backdrop_color` | `table` | Normal RGBA color for this row. |
| `backdrop_color_highlight` | `table` | Hover RGBA color for this row. |

### Row methods (from `TimeLine_LineMixin`)

#### `GetAllBlocks()`
Returns `self.blocks` — all created block frames for this row (may contain hidden ones).

#### `GetBlock(index)`
Returns the block at `index`. Creates it lazily via `CreateBlock` if it does not exist.

#### `SetBlocksFromData()`
The main refresh function for a row. Called by `RefreshTimeLine` for each row. Reads from `timeline.data.lines[self.dataIndex]` and:
1. Sets row height (from `lineData.lineHeight` or `options.line_height`).
2. Sets header icon and label text.
3. Alternates backdrop color (odd rows: transparent; even rows: `backdrop_color`).
4. Iterates `lineData.timeline` and positions/sizes each block.
5. Calls `block_on_set_data` for each block if defined.

#### `Reset()`
Hides all blocks in this row, then hides the row frame and its header. Blocks are not destroyed.

---

## 7. Block Object (`df_timeline_line_block`)

Blocks are WoW Button frames created by `CreateBlock`. Each represents one event entry.

### Key fields

| Field | Type | Description |
|---|---|---|
| `type` | `"block"` | Component type. |
| `icon` | `texture` | Icon texture (artwork layer). |
| `text` | `fontstring` | Label text (artwork layer, `GameFontNormal`, outlined). |
| `background` | `texture` | Solid color fill (background layer). |
| `backgroundBorder` | `border_frame` | 1 px pixel-perfect border frame. |
| `blockLength` | `df_timeline_line_blocklength` | The aura/duration bar child frame. |
| `info` | `df_timeline_line_blockinfo` | Runtime info: `time`, `duration`, `spellId`, `payload`, `customIcon`, `customName`. |
| `blockData` | `df_timeline_block_data` | Reference to the raw data table for this block. |
| `timeline` | `df_timeline` | Back-reference to the parent timeline. |

### Positioning

When `useIconOnBlocks = true`:
- The block is square: `line_height × line_height` pixels.
- X position: `headerWidth + pixelPerSecond × timeInSeconds`.
- If `isIconRow = true`, the block is placed immediately to the right of the previous block (`left` of `prevBlock.right + 2`).

When `useIconOnBlocks = false`:
- Block width: `max(pixelPerSecond × blockData[2], 16)` pixels.
- Block height: `line_height`.

Negative time values (`timeInSeconds < -0.2`) are compressed: `xOffset = xOffset / 2.5` and the icon is desaturated.

---

## 8. Block-Length Object (`df_timeline_line_blocklength`)

Created as a child of each block by `CreateBlockLength`. Represents the duration bar of an aura or effect.

### Key fields

| Field | Type | Description |
|---|---|---|
| `type` | `"length"` | Component type. |
| `Texture` | `texture` | Solid color or tiled texture filling the bar. |
| `RightIcon` | `texture` | Optional icon at the right edge of the bar. |
| `block` | `df_timeline_line_block` | Back-reference to the parent block. |
| `timeline` | `df_timeline` | Back-reference to the timeline. |
| `isMoving` | `boolean` | Drag state (drag code exists but is disabled with `do return end`). |

### Sizing

- Width: `pixelPerSecond × clamp(auraDuration, 0, data.length - timeInSeconds)`.
- Height: `blockData.auraHeight` if set, otherwise `block:GetHeight()`.
- Anchored at `bottomleft` of the parent block icon (or `rowStartBlock` icon for icon-row blocks).
- Frame level is one below its parent block.

### Visibility

The block-length frame is shown only when `blockData[3] = true` (`isAura`). Otherwise it is hidden.

---

## 9. Rendering and Layout

### Coordinate system

```
body (frame, wide scroll child)
├── elapsedTimeFrame (at top, spans from headerWidth to body right)
│
├── line[1] (button, y = -elapsed_timeline_height - 2 - 10)
│   ├── lineHeader (leftmost header_width pixels)
│   │   ├── icon  (df_image, left-anchored)
│   │   └── text  (df_label, right of icon)
│   ├── block[1]  (button, x = headerWidth + pixelPerSecond * time * scale)
│   │   └── blockLength (button, anchored to block icon bottomleft)
│   └── block[2] ...
│
├── line[2] (anchored to bottomleft of line[1])
│   └── ...
```

### Body width formula

```
bodyWidth = data.length × options.pixels_per_second × currentScale + effectiveHeaderWidth
```

where `effectiveHeaderWidth` is `0` when `header_detached = true`, otherwise `options.header_width`.

### Block X position formula

```
xOffset = options.pixels_per_second × currentScale × blockData[1]
block.left = body.left + effectiveHeaderWidth + xOffset
```

### Block width formula (non-icon mode)

```
blockWidth = max(options.pixels_per_second × currentScale × blockData[2], 16)
```

### Body height formula

```
bodyHeight = (options.line_height + options.line_padding) × #data.lines + 40
```

### Zoom range

- `scale_min` to `scale_max` map to the scale slider range `[0, 1]`.
- Default initial scale: `0.5` (midpoint).
- The `MapRangeClamped` utility is used to convert between scale values and slider positions.

### Even/odd row shading

Odd-indexed rows (1, 3, 5, …) have a transparent background `(0,0,0,0)`. Even-indexed rows use `options.backdrop_color`.

---

## 10. User Interaction

### Mouse wheel (on the timeline frame)

| Modifier | Direction | Action |
|---|---|---|
| None | Down | Pan right (1/20 of body width per step). |
| None | Up | Pan left (1/20 of body width per step). |
| Shift | Down | Scroll down vertically. |
| Shift | Up | Scroll up vertically. |
| Ctrl | Up | Zoom in (+0.1 to scale slider). |
| Ctrl | Down | Zoom out (−0.1, or snap to 0 if `zoom_out_zero = true`). |

### Mouse drag (on the body)

Click and drag on the body frame pans the timeline horizontally. Holding Shift doubles the pan speed; holding Alt halves it.

### Resize grip

The button at the bottom-right corner calls `StartSizing("bottomright")` on mouse down. `OnSizeChanged` fires automatically and repositions sliders + refreshes the layout.

### Per-pixel buttons (`use_perpixel_buttons = true`)

One invisible full-height button is created per integer second in the timeline. Clicking a button fires `onClickCallbackFunc(button)`, which calls:
```lua
callback(button.index - 1, unpack(onClickCallbackArgs))
```

---

## 11. Detached Header Mode

When `options.header_detached = true`:
- `CreateTimeLineFrame` returns `headerFrame` and `headerBody` as its second and third return values.
- Row header sub-frames are parented to `headerBody` instead of the row frame itself.
- `headerFrame` has its own `verticalSlider` that is kept in sync with the main vertical slider.
- The header vertical scroll fires `frameCanvas.headerFrame.verticalSlider:SetValue(value)` whenever the main vertical slider changes.
- The main body uses `effectiveHeaderWidth = 0` for block positioning (blocks start at x=0 relative to content area).
- `headerFrame:SetWidth(options.header_width)` — caller must position this frame adjacent to the timeline.

---

## 12. Data Flow

```
Caller creates options table
        │
        ▼
CreateTimeLineFrame(parent, name, options)
  → builds ScrollFrame, body, sliders, elapsed bar
  → returns df_timeline
        │
        ▼
timeline:SetData(scrollData)
  → stores scrollData as timeline.data
  → calls RefreshTimeLine()
        │
        ▼
RefreshTimeLine()
  → computes body dimensions from data.length × pixels_per_second × currentScale
  → adjusts horizontal slider max value
  → resets all lines (hides blocks)
  → for each line in data.lines:
      GetLine(i) → creates row lazily
      line:SetBlocksFromData()
          → reads lineData.timeline array
          → for each event { t, len, isAura, auraDur, spellId, ... }:
              GetBlock(j) → creates block lazily
              positions block at x = headerWidth + pps × scale × t
              sizes block
              shows/hides blockLength based on isAura
              calls block_on_set_data(block, data) if set
  → refreshes elapsedTimeFrame
  → refreshes LineIndicator overlay
        │
        ▼
User interaction (scroll, zoom, drag, hover)
  → adjusts slider values
  → triggers SetHorizontalScroll / SetVerticalScroll on the ScrollFrame
  → zoom changes currentScale → calls RefreshTimeLine(true, true)
```

---

## 13. Example Usage

Based on `timeline.exemples.lua`:

```lua
local DF = DetailsFramework

-- 1. Create a container frame
local timelineFrame = CreateFrame("frame", "MyTimelineFrame", UIParent, "BackdropTemplate")
timelineFrame:SetPoint("center")
timelineFrame:SetSize(900, 420)
timelineFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true, tileSize = 16,
    insets = {left = 1, right = 1, top = 0, bottom = 1}
})

-- 2. Create the timeline (880×400 inside the 900×420 container)
local scroll = DF:CreateTimeLineFrame(timelineFrame, "$parentTimeLine", {width = 880, height = 400})
scroll:SetPoint("topleft", timelineFrame, "topleft", 0, 0)

-- 3. Feed data
scroll:SetData({
    length = 360,               -- 360-second timeline
    defaultColor = {1, 1, 1, 1},
    useIconOnBlocks = true,     -- render blocks as square icons

    lines = {
        {
            spellId = 17,
            text = "player 1",
            icon = [[Interface\ICONS\10Prof_PortableTable_Engineering01]],
            timeline = {
                -- {timeInSeconds, length [, isAura, auraDuration, blockSpellId]}
                {1, 10}, {13, 11}, {25, 7}, {36, 5},
                {55, 18}, {76, 30}, {105, 20}, {130, 11},
            }
        },
        {
            spellId = 116,
            text = "player 2",
            icon = [[Interface\ICONS\10Prof_Table_Alchemy01]],
            timeline = {
                {5, 10}, {20, 11}, {35, 7}, {40, 5},
                {55, 18}, {70, 30}, {80, 20}, {90, 11},
            }
        },
    },
})
```

### What this produces

- A 880×400 scrollable panel with two horizontal rows.
- Each row has an icon and label on the left (using the default `header_width = 150`).
- Each event in `.timeline` is rendered as a square icon button positioned at its time offset.
- The elapsed-time ruler is drawn at the top.
- Three sliders are created as children of `timelineFrame` for panning, zooming, and vertical scrolling.

---

## 14. Practical Patterns

### Adding hover tooltips to blocks

```lua
local timeline = DF:CreateTimeLineFrame(parent, "MyTL", {
    width = 800, height = 400,
    block_on_enter = function(block)
        local info = block.info
        GameTooltip:SetOwner(block, "ANCHOR_RIGHT")
        GameTooltip:AddLine(info.customName or "Event")
        GameTooltip:AddLine(string.format("Time: %.1f s", info.time))
        if info.spellId and info.spellId > 0 then
            GameTooltip:SetSpellByID(info.spellId)
        end
        GameTooltip:Show()
    end,
    block_on_leave = function(block)
        GameTooltip:Hide()
    end,
})
```

### Storing arbitrary data on blocks via `payload`

```lua
-- In the data table:
{ 30, 5, false, nil, nil, payload = { damage = 12345, source = "Player-1" } }

-- In the callback:
block_on_enter = function(block)
    local payload = block.info.payload
    if payload then
        print("Damage:", payload.damage)
    end
end
```

### Rendering aura duration bars

```lua
-- isAura=true, auraDuration=20, custom color
{ 10, 0, true, 20, 12345, auraLengthColor = {0.2, 0.8, 1, 0.6} }
```

### Programmatic zoom

```lua
timeline:SetScale(0.3)  -- zoom out
timeline:SetScale(1.0)  -- maximum zoom
```

### Updating data without recreating the timeline

```lua
-- Just call SetData again — all existing lines and blocks are reused.
timeline:SetData(newDataTable)
```

### Per-second click detection

```lua
local timeline = DF:CreateTimeLineFrame(parent, "MyTL", {
    width = 800, height = 400,
    use_perpixel_buttons = true,
})
timeline:SetData(data)
timeline:SetOnClickCallback(function(second)
    print("Clicked second:", second)
end)
```

### Disabling interaction on specific rows

```lua
-- In the line data:
{ spellId = 0, text = "Header row", icon = nil, disabled = true, timeline = {} }
```

### Custom per-row height

```lua
{ spellId = 17, text = "Tall row", icon = ..., lineHeight = 40, timeline = { ... } }
```

### Icon-row chaining (placing multiple icons in a sequence without time-based positioning)

```lua
-- Block N with isIconRow=true will be placed to the right of block N-1.
-- Useful for grouping related events visually.
{ 30, 0, false, nil, 100 },                     -- block at t=30s
{ 0, 0, false, nil, 200, isIconRow = true },     -- immediately right of previous
{ 0, 0, false, nil, 300, isIconRow = true },     -- immediately right of that
```
