# Header System Documentation

## Overview

The header system provides a horizontal (or vertical) bar of labeled, optionally sortable column headers. It is used to organize tabular data — each column has a title, optional icon, alignment, sort arrow, and resizer handle.

The system is composed of four parts:

| Component | Purpose |
|---|---|
| `DetailsFramework:CreateHeader()` | Entry point. Creates and returns a `df_headerframe` instance. |
| `default_header_options` | Local table of default configuration values merged into every header instance. |
| `detailsFramework.HeaderMixin` | Methods mixed into each header instance (operate on `self`). |
| `detailsFramework.HeaderFunctions` | Standalone utilities designed to be mixed into **other** UI elements (scroll lines, rows) so they can align their children with a header. |

---

## Creating a Header

```lua
local headerFrame = DetailsFramework:CreateHeader(parent, headerTable, options, frameName)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | yes | The parent frame the header is parented to. |
| 2 | `headerTable` | `df_headercolumndata[]` | yes | Array of column definitions (see Column Data below). |
| 3 | `options` | `table` or `nil` | no | Overrides for `default_header_options`. Keys not provided use defaults. |
| 4 | `frameName` | `string` or `nil` | no | Global frame name. If omitted a random name is generated. |

### Returns

A `df_headerframe` — a `Frame` (with `BackdropTemplate`) that has `HeaderMixin` and `OptionsFunctions` mixed in.

### Initialization Sequence

1. A new `frame` is created with `BackdropTemplate`.
2. `OptionsFunctions` mixin is applied (provides `BuildOptionsTable`).
3. `HeaderMixin` is applied (all methods listed below).
4. `BuildOptionsTable` merges the caller's `options` with `default_header_options` into `self.options`.
5. Backdrop and backdrop colors are set from `self.options`.
6. `SetHeaderTable(headerTable)` is called, which resets internal counters and calls `Refresh()`.

---

## Column Data (`df_headercolumndata`)

Each entry in the `headerTable` array describes one column.

| Key | Type | Default | Description |
|---|---|---|---|
| `key` | `string` | `"total"` | Sort key identifier. Stored on the column header frame as `columnHeader.key`. |
| `name` | `string` | — | Logical name for the column (used in callbacks and `GetHeaderColumnByName`). |
| `text` | `string` | — | Display text rendered on the column header. |
| `icon` | `string` | — | Texture path for an icon displayed to the left of the text. |
| `texcoord` | `table` | `{0,1,0,1}` | Tex coords applied to the icon. |
| `width` | `number` | `options.header_width` | Column width in pixels. |
| `height` | `number` | `options.header_height` | Column height in pixels. |
| `align` | `string` | `"left"` | Text/column alignment: `"left"`, `"center"`, or `"right"`. |
| `offset` | `number` | `0` | Extra horizontal offset applied when aligning child frames. |
| `canSort` | `boolean` | — | If `true`, clicking the column header toggles sort order (ASC/DESC). |
| `selected` | `boolean` | — | If `true`, this column starts as the selected/sorted column. |
| `columnSpan` | `number` | `0` | Number of subsequent columns to merge into this one (the spanned columns are hidden and their width is added). |

---

## Default Options (`default_header_options`)

These are the defaults. Override any key via the `options` parameter of `CreateHeader`.

### Frame Backdrop

| Option | Default | Description |
|---|---|---|
| `backdrop` | `{edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tileSize = 64, tile = true}` | Backdrop table for the main header frame. |
| `backdrop_color` | `{0, 0, 0, 0.2}` | RGBA backdrop color. |
| `backdrop_border_color` | `{0.1, 0.1, 0.1, 0.2}` | RGBA backdrop border color. |

### Mouse

| Option | Default | Description |
|---|---|---|
| `propagate_clicks` | `false` | Whether the header frame and its column headers propagate mouse clicks to frames beneath them. Set via `PropagateClicks()`. |

### Text

| Option | Default | Description |
|---|---|---|
| `text_color` | `{1, 1, 1, 1}` | RGBA color for column header text. |
| `text_size` | `10` | Font size. |
| `text_shadow` | `false` | Font outline/shadow flag. |

### Layout

| Option | Default | Description |
|---|---|---|
| `grow_direction` | `"RIGHT"` | Direction columns are laid out: `"RIGHT"`, `"LEFT"`, `"TOP"`, `"BOTTOM"`. |
| `padding` | `2` | Pixel gap between adjacent column headers. |

### Column Header Backdrop

| Option | Default | Description |
|---|---|---|
| `header_backdrop` | `{bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tileSize = 64, tile = true}` | Backdrop for each individual column header button. |
| `header_backdrop_color` | `{0, 0, 0, 0.5}` | RGBA backdrop color for unselected column headers. |
| `header_backdrop_color_selected` | `{0.3, 0.3, 0.3, 0.5}` | RGBA backdrop color applied to the currently selected (sorted) column header. |
| `header_backdrop_border_color` | `{0, 0, 0, 0}` | RGBA border color for column headers. |
| `header_width` | `120` | Default width when column data does not specify one. |
| `header_height` | `20` | Default height when column data does not specify one. |

### Sort Arrows

| Option | Default | Description |
|---|---|---|
| `arrow_up_texture` | `"Interface\\Buttons\\Arrow-Up-Down"` | Texture for ascending sort arrow. |
| `arrow_up_texture_coords` | `{0, 1, 6/16, 1}` | Tex coords for ascending arrow. |
| `arrow_up_size` | `{12, 11}` | Width, height of ascending arrow. |
| `arrow_down_texture` | `"Interface\\Buttons\\Arrow-Down-Down"` | Texture for descending sort arrow. |
| `arrow_down_texture_coords` | `{0, 1, 0, 11/16}` | Tex coords for descending arrow. |
| `arrow_down_size` | `{12, 11}` | Width, height of descending arrow. |
| `arrow_alpha` | `0.659` | Alpha of the sort arrow icon. |

### Resizer

| Option | Default | Description |
|---|---|---|
| `reziser_shown` | `false` | Whether column resize handles are visible. |
| `reziser_width` | `2` | Width of the resize handle in pixels. |
| `reziser_color` | `{1, 0.6, 0, 0.6}` | RGBA vertex color of the resize handle texture. |
| `reziser_min_width` | `16` | Minimum column width when resizing (also clamped to text width). |
| `reziser_max_width` | `200` | Maximum column width when resizing. |

### Line Separators

| Option | Default | Description |
|---|---|---|
| `use_line_separators` | `false` | Whether vertical separator lines are drawn between columns (only in `"RIGHT"` grow direction). |
| `line_separator_color` | `{0.1, 0.1, 0.1, 0.6}` | RGBA color of separator lines. |
| `line_separator_width` | `1` | Width of separator lines. |
| `line_separator_height` | `200` | Height of separator lines (can extend beyond the header to span the data area). |
| `line_separator_gap_align` | `false` | If `true`, separator is placed at `topright` of the column with a gap. If `false`, placed at `topright` flush. |

---

## Header Methods (`HeaderMixin`)

These methods exist on every `df_headerframe` instance.

### SetHeaderTable(headerTable)

```lua
header:SetHeaderTable(headerTable)
```

Replaces the header's column definitions. Resets `NextHeader` to 1, `HeaderWidth` and `HeaderHeight` to 0, initializes `columnHeadersCreated` if needed, stores `headerTable` as `self.HeaderTable`, then calls `Refresh()`.

- **headerTable** (`df_headercolumndata[]`): New array of column definitions.

---

### Refresh()

```lua
header:Refresh()
```

Rebuilds the entire header from scratch:

1. Reapplies backdrop from options.
2. Hides and marks all existing column header frames as not in use.
3. Iterates `self.HeaderTable`, calling `GetNextHeader()` and `UpdateColumnHeader()` for each.
4. Positions each column header relative to the previous one based on `grow_direction`.
5. Handles `columnSpan` by hiding spanned columns and adding their width to the spanning column.
6. Handles `use_line_separators` (right grow direction only).
7. Sets `propagate_clicks` on each column header (skipped during combat).
8. Sets the header frame size to `(HeaderWidth, HeaderHeight)`.

---

### GetSelectedColumn()

```lua
local columnIndex, order, key, name = header:GetSelectedColumn()
```

Returns information about the currently selected (sorted) column.

- **Returns:**
  - `columnIndex` (`number`): 1-based index of the selected column.
  - `order` (`string`): `"ASC"` or `"DESC"`.
  - `key` (`string`): The `key` field from the column data.
  - `name` (`string`): The `name` field from the column data.

---

### GetSelectedHeaderColumnData()

```lua
local columnData = header:GetSelectedHeaderColumnData()
```

Returns the raw `df_headercolumndata` table for the currently selected column.

---

### GetHeaderTable()

```lua
local headerTable = header:GetHeaderTable()
```

Returns the full `df_headercolumndata[]` array.

---

### GetHeaderTableByIndex(columnId)

```lua
local columnData = header:GetHeaderTableByIndex(columnId)
```

Returns the `df_headercolumndata` for a specific column by 1-based index.

---

### GetColumnWidth(columnId)

```lua
local width = header:GetColumnWidth(columnId)
```

Returns the configured `width` value from the header table entry at `columnId`. Asserts if the index does not exist.

---

### DoesColumnExists(columnId)

```lua
local exists = header:DoesColumnExists(columnId)
```

Returns `true` if a column definition exists at the given index, `false` otherwise.

---

### SetColumnSettingChangedCallback(func)

```lua
local success = header:SetColumnSettingChangedCallback(func)
```

Registers a callback invoked when a column is resized. The callback signature is:

```lua
function(headerFrame, settingType, columnName, newValue)
```

Currently only `settingType = "width"` is emitted. Pass a non-function value to clear the callback. Returns `true` on success, `false` if cleared.

---

### GetHeaderColumnByName(columnName)

```lua
local columnHeader = header:GetHeaderColumnByName(columnName)
```

Searches `columnHeadersCreated` for a column whose `columnData.name` matches `columnName`. Returns the `df_headercolumnframe` or `nil`.

---

### UpdateColumnHeader(columnHeader, headerIndex)

```lua
header:UpdateColumnHeader(columnHeader, headerIndex)
```

Internal method. Configures a column header frame from the column data at `headerIndex`:

- Sets `key`, icon, text, text alignment, font properties.
- Sets column size from column data (or uses defaults).
- Records `XPosition`, `YPosition`, `columnAlign`, `columnOffset` on the column header.
- Accumulates `HeaderWidth`/`HeaderHeight`.
- Configures sort arrow visibility based on `canSort` and `selected`.
- Shows/hides the resizer handle.
- Marks the column as `bInUse = true` and stores `columnData`.

---

### ClearColumnHeader(columnHeader)

```lua
header:ClearColumnHeader(columnHeader)
```

Internal method. Resets a column header to default state: applies default size from options, resets backdrop, clears icon and text.

---

### ResetColumnHeaderBackdrop(columnHeader)

```lua
header:ResetColumnHeaderBackdrop(columnHeader)
```

Applies `header_backdrop`, `header_backdrop_color`, and `header_backdrop_border_color` from options to the given column header.

---

### SetBackdropColorForSelectedColumnHeader(columnHeader)

```lua
header:SetBackdropColorForSelectedColumnHeader(columnHeader)
```

Applies `header_backdrop_color_selected` to the given column header to visually mark it as the active sort column.

---

### UpdateSortArrow(columnHeader, defaultShown, defaultOrder)

```lua
header:UpdateSortArrow(columnHeader, defaultShown, defaultOrder)
```

Configures the sort arrow icon on a column header.

- If `defaultShown` is not a boolean, the arrow is shown unconditionally.
- If `defaultShown` is a boolean, the arrow is shown/hidden accordingly (and if shown, the column backdrop is highlighted).
- Uses `defaultOrder` if provided, otherwise reads `columnHeader.order`.
- Sets the arrow texture, tex coords, and size from options based on `"ASC"` or `"DESC"`.

---

### GetNextHeader()

```lua
local columnHeader = header:GetNextHeader()
```

Internal method. Returns the next available column header frame, creating one if needed. New column headers are `button` frames with:

- `Icon` (texture), `Text` (fontstring), `Arrow` (texture), `Separator` (texture).
- `resizerButton` — a draggable handle on the right edge for resizing.
- `OnMouseDown`/`OnMouseUp` scripts that track cursor position to distinguish clicks from drags (prevents false clicks when the parent frame is being moved).
- Resize scripts that enforce min/max width and invoke `OnColumnSettingChangeCallback` on resize completion.

After retrieval, the column header is cleared via `ClearColumnHeader` and `NextHeader` is incremented.

---

### PropagateClicks(propagate)

```lua
header:PropagateClicks(true)
```

Sets `options.propagate_clicks` and calls `Refresh()`. When `true`, mouse clicks pass through the header to frames behind it.

---

### Internal State

| Field | Type | Description |
|---|---|---|
| `NextHeader` | `number` | Counter for the next column header slot (reset to 1 on `SetHeaderTable`). |
| `HeaderWidth` | `number` | Accumulated total width of all columns (reset on `SetHeaderTable`). |
| `HeaderHeight` | `number` | Accumulated total height (reset on `SetHeaderTable`). |
| `columnHeadersCreated` | `df_headercolumnframe[]` | Pool of created column header frames (reused across refreshes). |
| `columnSelected` | `number` | Index of the currently selected column. |
| `columnOrder` | `string` | Current sort order (`"ASC"` or `"DESC"`). |
| `HeaderTable` | `df_headercolumndata[]` | The active column definitions. |
| `OnColumnSettingChangeCallback` | `function` or `nil` | Resize callback (see `SetColumnSettingChangedCallback`). |

---

## Reusable Header Functions (`HeaderFunctions`)

These functions are **not** mixed into the header itself. They are designed to be mixed into **row/line frames** (e.g., scroll box lines) so those rows can align their child elements with header columns.

Apply them with:

```lua
DetailsFramework:Mixin(lineFrame, DetailsFramework.HeaderFunctions)
```

### AddFrameToHeaderAlignment(frame)

```lua
line:AddFrameToHeaderAlignment(someWidget)
```

Appends a UI object to the line's `FramesToAlign` list. The order must match the column order in the header table (first call = column 1, second = column 2, etc.).

---

### ResetFramesToHeaderAlignment()

```lua
line:ResetFramesToHeaderAlignment()
```

Hides all frames in `FramesToAlign` and wipes the list.

---

### SetFramesToHeaderAlignment(...)

```lua
line:SetFramesToHeaderAlignment(widget1, widget2, widget3)
```

Replaces `FramesToAlign` with the given frames (vararg). Previous entries are discarded.

---

### GetFramesFromHeaderAlignment()

```lua
local frames = line:GetFramesFromHeaderAlignment()
```

Returns the `FramesToAlign` table.

---

### AlignWithHeader(headerFrame, anchor)

```lua
line:AlignWithHeader(headerFrame, "left")
```

Positions each frame in `FramesToAlign` to match the corresponding column header's position.

- **headerFrame** (`df_headerframe`): The header to align with.
- **anchor** (`string`, default `"topleft"`): The anchor point on the line frame.

For each frame at index `i`:
1. Clears all points.
2. Reads the column header at index `i` from `headerFrame.columnHeadersCreated`.
3. Calculates an offset based on `columnAlign` (`"right"` = full width, `"center"` = half width, `"left"` = 0).
4. If the frame is a `FontString`, sets `JustifyH` to match the column alignment.
5. Sets the point using the column's `XPosition + columnOffset + offset`.
6. Shows the frame.

---

### OnClick(columnHeader, buttonClicked)

```lua
-- Called internally by column header OnMouseUp scripts
DetailsFramework.HeaderFunctions.OnClick(columnHeader, buttonClicked)
```

Handles column header click for sort toggling:

1. Gets the parent `df_headerframe`.
2. Exits if no column is currently selected or the clicked column has `canSort = false`.
3. Resets the previously selected column's backdrop and hides its arrow.
4. Highlights the clicked column.
5. Toggles the sort order if clicking the already-selected column; otherwise keeps the new column's order.
6. Updates `columnSelected` and `columnOrder` on the header.
7. Calls `options.header_click_callback(headerFrame, columnHeader, columnIndex, order)` if defined.

---

### OnMouseDown / OnMouseUp

Empty stub handlers currently present for future use.

---

## Integrating Header Alignment into External Frames

This section describes how to make a row frame (e.g., a scroll box line) align its children with a header. This pattern is used in `window_aura_tracker.lua`.

### Step-by-Step

1. **Create the header:**

```lua
local headerTable = {
    {text = "", width = 20},
    {text = "Name", width = 160},
    {text = "Value", width = 100},
}
local header = DetailsFramework:CreateHeader(parentFrame, headerTable, {padding = 2})
header:SetPoint("topleft", parentFrame, "topleft", 5, -22)
```

2. **Create row frames and mixin `HeaderFunctions`:**

```lua
local line = CreateFrame("frame", nil, scrollBox, "BackdropTemplate")
DetailsFramework:Mixin(line, DetailsFramework.HeaderFunctions)
```

3. **Create child widgets for each column and register them in order:**

```lua
local iconTexture = DetailsFramework:CreateTexture(line, "", 18, 18)
local nameField  = DetailsFramework:CreateTextEntry(line, function() end, header:GetColumnWidth(2), 20)
local valueField = DetailsFramework:CreateTextEntry(line, function() end, header:GetColumnWidth(3), 20)

line:AddFrameToHeaderAlignment(iconTexture)
line:AddFrameToHeaderAlignment(nameField)
line:AddFrameToHeaderAlignment(valueField)
```

Note: Use `header:GetColumnWidth(columnIndex)` to size each widget to match its column.

4. **Align:**

```lua
line:AlignWithHeader(header, "left")
```

This positions each widget horizontally to match the corresponding column header.

5. **Store references for data binding:**

```lua
line.Icon = iconTexture
line.Name = nameField
line.Value = valueField
```

6. **On refresh/scroll, populate line data:**

```lua
line.Icon.texture = data.icon
line.Name.text = data.name
line.Value.text = data.value
```

### Key Points

- The number and order of `AddFrameToHeaderAlignment` calls must match the column order in the header table.
- `AlignWithHeader` uses each column header's `XPosition`, `columnAlign`, and `columnOffset` to position child widgets — the children do not need manual `SetPoint` calls for horizontal positioning.
- Column width from `header:GetColumnWidth(i)` ensures child widgets match their column size.
- `ResetFramesToHeaderAlignment()` can be called to clear and rebuild the alignment list when line content changes.

---

## Column Header Frame (`df_headercolumnframe`)

Each column in the header is a `button` frame with these child elements:

| Child | Type | Description |
|---|---|---|
| `Icon` | `texture` | Optional icon displayed at the left of the column. |
| `Text` | `fontstring` | Column title text. |
| `Arrow` | `texture` | Sort direction arrow (up/down), shown when the column is selected. |
| `Separator` | `texture` | Vertical line separator (visible only when `use_line_separators` is enabled). |
| `resizerButton` | `df_headerresizer` (button) | Draggable resize handle on the right edge. |

### Stored Properties

| Property | Type | Description |
|---|---|---|
| `columnIndex` | `number` | 1-based index of this column. |
| `key` | `string` | Sort key from column data. |
| `order` | `string` | Current sort order: `"ASC"` or `"DESC"`. |
| `columnAlign` | `string` | Alignment: `"left"`, `"center"`, or `"right"`. |
| `columnOffset` | `number` | Extra horizontal offset. |
| `XPosition` | `number` | Cumulative X offset from the header origin. |
| `YPosition` | `number` | Cumulative Y offset from the header origin. |
| `bInUse` | `boolean` | Whether this column header is currently active. |
| `bIsRezising` | `boolean` | Whether the column is currently being resized. |
| `columnData` | `df_headercolumndata` | Reference to the source column definition. |

---

## Sort Click Callback

To respond to column header clicks for sorting:

```lua
local options = {
    header_click_callback = function(headerFrame, columnHeader, columnIndex, order)
        -- columnIndex: 1-based column that was clicked
        -- order: "ASC" or "DESC"
        -- Re-sort your data and refresh your scroll box here
    end,
}
local header = DetailsFramework:CreateHeader(parent, headerTable, options)
```

The callback is only invoked for columns that have `canSort = true`.

---

## Full Example (from `window_aura_tracker.lua`)

```lua
-- Define columns
local headerTable = {
    {text = "", width = 20},
    {text = "Aura Name", width = 162},
    {text = "Spell Id", width = 100},
    {text = "Lua Table", width = 200},
    {text = "Payload (Points)", width = 296},
    {text = "Last Cast", width = 100},
}
local headerOptions = {padding = 2}

-- Create header
local header = DetailsFramework:CreateHeader(parentFrame, headerTable, headerOptions)
header:SetPoint("topleft", parentFrame, "topleft", 5, -22)

-- Create scroll box
local scroll = DetailsFramework:CreateScrollBox(parentFrame, "$parentScrollBox",
    refreshFunction, data, width, height, lineCount, lineHeight)
scroll:CreateLines(createLineFunction, lineCount)
scroll:SetPoint("topleft", header, "bottomleft", 0, -2)

-- In the line creation function:
function createLineFunction(self, lineId)
    local line = CreateFrame("frame", "$parentLine" .. lineId, self, "BackdropTemplate")
    -- ... size and position the line ...

    -- Apply HeaderFunctions mixin
    DetailsFramework:Mixin(line, DetailsFramework.HeaderFunctions)

    local header = self:GetParent().Header

    -- Create one widget per column
    local icon = DetailsFramework:CreateTexture(line, "", 18, 18)
    local name = DetailsFramework:CreateTextEntry(line, function() end, header:GetColumnWidth(2), 20)
    local spellId = DetailsFramework:CreateTextEntry(line, function() end, header:GetColumnWidth(3), 20)
    local luaTable = DetailsFramework:CreateTextEntry(line, function() end, header:GetColumnWidth(4), 20)
    local points = DetailsFramework:CreateTextEntry(line, function() end, header:GetColumnWidth(5), 20)
    local lastCast = DetailsFramework:CreateTextEntry(line, function() end, header:GetColumnWidth(6), 20)

    -- Register in column order
    line:AddFrameToHeaderAlignment(icon)
    line:AddFrameToHeaderAlignment(name)
    line:AddFrameToHeaderAlignment(spellId)
    line:AddFrameToHeaderAlignment(luaTable)
    line:AddFrameToHeaderAlignment(points)
    line:AddFrameToHeaderAlignment(lastCast)

    -- Align all widgets with the header
    line:AlignWithHeader(header, "left")

    return line
end
```
