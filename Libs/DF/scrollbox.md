# Scrollbox System

## Overview

A scrollbox is a scrollable container that displays a list of rows (called "lines"). Each line is a WoW frame created by a user-provided function. The scrollbox manages scroll offset, line visibility, and data binding so the caller only needs to provide three things:

1. **A data table** — an indexed array of items to display.
2. **A line creation function** — creates the visual frame for one row.
3. **A refresh function** — populates a line's widgets from a data entry.

The **base scrollbox** (`CreateScrollBox`) uses a `FauxScrollFrameTemplate` to handle scrolling. All other scrollbox types in the system are built on top of it, adding specialized layouts (grid), data formats (auras, bosses), or UI features (search bars, selection).

### Scrollbox Type Hierarchy

```
CreateScrollBox (base)
  ├─ CreateGridScrollBox (grid layout)
  │     └─ CreateMenuWithGridScrollBox (grid + search + selection)
  ├─ CreateAuraScrollBox (spell aura lists)
  ├─ CreateDataScrollFrame (text data with title/date)
  ├─ CreateBossScrollSelectorForInstance (boss list with icons)
  ├─ CreateSimpleListBox (key-value list, not a true scrollbox)
  └─ CreateCanvasScrollBox (free-form scrollable child frame)
```

---

## Base Scrollbox — `CreateScrollBox`

### Signature

```lua
detailsFramework:CreateScrollBox(parent, name, refreshFunc, data, width, height, lineAmount, lineHeight, createLineFunc, autoAmount, noScroll, noBackdrop)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | Yes | Parent frame. |
| 2 | `name` | `string` | Yes | Global name for the scrollframe. |
| 3 | `refreshFunc` | `function` | Yes | Called during `Refresh()` to populate lines from data. |
| 4 | `data` | `table` | Yes | Indexed array of data items. Can be replaced later with `SetData()`. |
| 5 | `width` | `number` | Yes | Width of the scrollbox. |
| 6 | `height` | `number` | Yes | Height of the scrollbox. |
| 7 | `lineAmount` | `number` | Yes | Number of visible lines. |
| 8 | `lineHeight` | `number` | Yes | Height of each line in pixels. |
| 9 | `createLineFunc` | `function?` | No | Default function for `CreateLine()` if none is passed per call. |
| 10 | `autoAmount` | `boolean?` | No | If true, automatically recalculates `lineAmount` on size change based on height / lineHeight. |
| 11 | `noScroll` | `boolean?` | No | If true, hides the scrollbar. |
| 12 | `noBackdrop` | `boolean?` | No | If true, skips `ApplyStandardBackdrop`. |

### Returns

`df_scrollbox` — a WoW `ScrollFrame` using `FauxScrollFrameTemplate` with the `ScrollBoxFunctions` mixin applied.

### Construction

1. Creates a `ScrollFrame` from `FauxScrollFrameTemplate, BackdropTemplate`.
2. Applies `ApplyStandardBackdrop` unless `noBackdrop`.
3. Sets size, stores `LineAmount`, `LineHeight`, `IsFauxScroll = true`, creates empty `Frames` array.
4. Mixes in `SortFunctions` and `ScrollBoxFunctions`.
5. Stores `refresh_func` and `data`.
6. Sets `OnVerticalScroll` and `OnSizeChanged` scripts.
7. Lines are **not** created automatically — the caller must call `CreateLine()` or `CreateLines()` after construction.

### Key Fields on `df_scrollbox`

| Field | Type | Description |
|---|---|---|
| `data` | `table` | Current data array. Set via `SetData()`. |
| `data_original` | `table` | Copy of the last data passed to `SetData()`. |
| `Frames` | `frame[]` | Array of created line frames. |
| `LineAmount` | `number` | Number of visible lines. |
| `LineHeight` | `number` | Height of each line. |
| `IsFauxScroll` | `boolean` | Always `true`. Enables faux scroll offset calculation. |
| `HideScrollBar` | `boolean` | If true, scrollbar is hidden on refresh. |
| `refresh_func` | `function` | The refresh callback. |
| `CreateLineFunc` | `function?` | Default line creation function. |
| `ReajustNumFrames` | `boolean` | If true (`autoAmount`), line count adjusts on resize. |
| `DontHideChildrenOnPreRefresh` | `boolean` | If true, lines are not hidden before refresh. Default `false`. |
| `Header` | `df_headerframe?` | Optional header frame for column alignment. |
| `ScrollBar` | `statusbar` | The scrollbar widget. |
| `pre_refresh_func` | `function?` | Pre-refresh hook set via `SetPreRefreshFunction`. |
| `OnSetData` | `function?` | Post-SetData hook. Called after data is assigned. |
| `dataSelected` | `table?` | Sub-table reference of the currently selected data. Set via `SetDataSelected`. |
| `dataSelectedIndex` | `number?` | Index of the currently selected data within `self.data`. |
| `bArrowKeySelection` | `boolean?` | True when arrow key navigation is enabled via `EnableArrowKeySelection`. |

---

## ScrollBoxFunctions Mixin

All base scrollbox methods. Mixed into every `df_scrollbox`.

### `Refresh()`

The core update cycle:

1. Hides all lines and clears their `_InUse` flag (unless `DontHideChildrenOnPreRefresh`).
2. Calculates scroll offset via `UpdateFaux` / `GetOffsetFaux`.
3. Calls `pre_refresh_func(self, data, offset, lineAmount)` if set.
4. Calls `refresh_func(self, data, offset, lineAmount)`.
5. After the refresh function returns, iterates all lines: shows those flagged `_InUse`, hides the rest.
6. Handles scrollbar visibility.

**Returns:** `self.Frames` — the array of line frames.

### `CreateLine(func)`

Creates a single line frame by calling `func(self, index)` (or `self.CreateLineFunc` if `func` is nil). The returned frame is appended to `self.Frames` with an `.Index` field set.

**Returns:** the new line frame.

### `CreateLines(callback, lineAmount)`

Calls `CreateLine(callback)` in a loop `lineAmount` times.

### `GetLine(lineIndex)`

Returns the line at `self.Frames[lineIndex]` and marks it as `_InUse = true`. Increments `_LinesInUse`. Call line:Show(). This is how the refresh function signals which lines are visible.
Call GetLine only after confirming that the data for that line exists; otherwise, the line will remain empty as the loop code will get the next line as the iteration advances to a new data.
Example:
Wrong:
```lua
local data = dataset[i]
local line = self:GetLine(lineIndex)
if data then
end
```
Correct:
```lua
local data = dataset[i]
if data then
    local line = self:GetLine(lineIndex)
end
```

**Returns:** `frame`

### `SetData(data)`

Sets `self.data` and `self.data_original` to the provided table. Calls `self.OnSetData(self, data)` if defined.

### `GetData()`

Returns `self.data`.

### `SetDataSelected(dataOrIndex)`

Marks one entry of `self.data` as the currently selected one. Accepts:
- a `number` — treated as the 1-based index into `self.data`
- a `table` — searched for in `self.data` by reference equality (`data[i] == dataOrIndex`)
- `nil` — clears the selection

Stores `self.dataSelected` (the resolved sub-table) and `self.dataSelectedIndex` (its index). Returns the resolved data sub-table, or `nil` if the index/table was not found in `self.data`.

The base scrollbox does not visually highlight the selected line — the user's refresh function is responsible for comparing each line's data against `:GetDataSelected()` and applying its own highlight (see how `CreateMenuWithGridScrollBox` borders the selected button at scrollbox.lua:526).

### `GetDataSelected()`

Returns the selected data sub-table previously set via `:SetDataSelected()`, or `nil`.

### `GetDataSelectedIndex()`

Returns the index (within `self.data`) of the selected data, or `nil`.

### `SelectNext()` / `SelectPrevious()`

Moves the selection one entry down (`SelectNext`) or up (`SelectPrevious`) in `self.data`. If nothing is selected yet, both select index `1`. The selection clamps at the end and at the beginning. After moving, calls `:ScrollToSelectedData()` and then `:Refresh()`.

### `ScrollToSelectedData()`

If the currently selected data is outside the visible window, sets the scrollbar value so it becomes visible. No-op if there is no selection or no scrollbar.

### `EnableArrowKeySelection(enabled)`

Opt-in arrow key navigation. When enabled and the mouse is over the scrollbox, pressing `UP`/`DOWN` calls `:SelectPrevious()`/`:SelectNext()`. Other keys propagate normally. Implementation:

- `EnableMouse(true)` is set so the scrollbox receives `OnEnter`/`OnLeave`.
- `OnEnter` enables keyboard input on the scrollbox (gated by `bArrowKeySelection`); `OnLeave` disables it. This avoids consuming arrow keys globally — e.g. character movement still works when the cursor is elsewhere.
- `OnKeyDown` consumes only `UP`/`DOWN` (`SetPropagateKeyboardInput(false)`) and propagates everything else.

The user is still responsible for making the selection visible — typically by checking `:GetDataSelected()` inside the refresh function and applying a highlight.

### `GetFrames()` / `GetLines()`

Returns `self.Frames` (aliases of each other).

### `GetNumFramesCreated()`

Returns `#self.Frames`.

### `GetNumFramesShown()`

Returns `self.LineAmount`.

### `SetNumFramesShown(newAmount)`

Updates `LineAmount`. Hides excess lines if `newAmount` is smaller than the current frame count.

### `SetFramesHeight(height)`

Updates `LineHeight`, triggers `OnSizeChanged`, then `Refresh`.

### `OnSizeChanged()`

If `ReajustNumFrames` is true, recalculates how many lines fit (`floor(height / lineHeight)`), creates new lines if needed, hides excess lines, updates `LineAmount`, and refreshes.

### `SetPreRefreshFunction(func)`

Sets a function to run before the refresh function on every `Refresh()` call. Receives the same `(self, data, offset, lineAmount)` arguments.

### Faux Scroll Internals

These methods replicate Blizzard's `FauxScrollFrame` API to avoid taint:

| Method | Description |
|---|---|
| `GetOffsetFaux()` | Returns `self.offset` (current scroll offset in lines). |
| `OnVerticalScrollFaux(value, lineHeight, updateFunction)` | Sets scrollbar value, calculates `self.offset`, calls update function. |
| `GetChildFramesFaux()` | Returns scrollbar and child frame references by name or direct reference. |
| `UpdateFaux(numItems, numToDisplay, buttonHeight, ...)` | Calculates scrollbar range, enables/disables up/down buttons, shows/hides scrollbar based on data size vs visible lines. |

---

## SortFunctions Mixin

Mixed into every base scrollbox. Provides:

### `Sort(table, memberName, isReverse)`

Sorts an external table by a named member (field). Does **not** sort the scrollbox's own data — the caller passes the table to sort.

---

## Refresh Function Contract

The refresh function provided to `CreateScrollBox` must follow this signature:

```lua
function refreshFunc(self, data, offset, totalLines)
```

| Parameter | Type | Description |
|---|---|---|
| `self` | `df_scrollbox` | The scrollbox instance. |
| `data` | `table` | The current data table (may differ from original if filtered). |
| `offset` | `number` | Number of data items scrolled past. Add to loop index to get data index. |
| `totalLines` | `number` | Number of visible lines (`LineAmount`). |

**Inside the loop:**

```lua
for i = 1, totalLines do
    local index = i + offset
    local thisData = data[index]
    if (thisData) then
        local line = self:GetLine(i)  -- marks line as in-use
        -- populate line widgets from thisData
    end
end
```

Calling `self:GetLine(i)` is required to make the line visible. Lines not fetched via `GetLine` are hidden after the refresh function returns.

---

## Line Creation Function Contract

```lua
function createLineFunc(self, index)
```

| Parameter | Type | Description |
|---|---|---|
| `self` | `df_scrollbox` | The scrollbox instance. |
| `index` | `number` | 1-based line index. |

**Must return** the created frame. The frame should be positioned relative to the scrollbox (typically using `index` to calculate vertical offset) and sized to match `lineHeight`.

---

## Grid Scrollbox — `CreateGridScrollBox`

### Purpose

Displays data in a grid layout with multiple columns per row. Useful for menus, icon grids, or any list where items are arranged in a matrix.

### Signature

```lua
detailsFramework:CreateGridScrollBox(parent, name, refreshFunc, data, createColumnFrameFunc, options)
```

### Parameters

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `parent` | `frame` | Parent frame. |
| 2 | `name` | `string` | Global name. |
| 3 | `refreshFunc` | `function` | Called per-cell as `refreshFunc(columnFrame, dataItem)`. |
| 4 | `data` | `table` | Flat indexed array of data items (not pre-grouped into rows). |
| 5 | `createColumnFrameFunc` | `function` | Creates one cell frame: `function(line, lineIndex, columnIndex) → frame`. |
| 6 | `options` | `df_gridscrollbox_options?` | Configuration table. |

### Options

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `600` | Total width. |
| `height` | `number` | `400` | Total height. |
| `line_amount` | `number` | `10` | Number of visible rows. |
| `line_height` | `number` | `30` | Height of each row. |
| `columns_per_line` | `number` | `4` | Columns per row. |
| `no_scroll` | `boolean` | `false` | Hide scrollbar. |
| `vertical_padding` | `number` | `1` | Vertical gap between rows. |
| `horizontal_padding` | `number` | `1` | Horizontal gap between columns. |
| `no_backdrop` | `boolean` | `false` | Skip backdrop. |
| `auto_amount` | `boolean` | — | Auto-calculate line count from height. |

### How It Differs from Base

- **Data regrouping:** On `SetData`, the flat data array is chunked into groups of `columns_per_line`. Each group becomes one row of data. The scrollbox operates on rows, not individual items.
- **Automatic line creation:** Lines and column frames are created during construction.
- **Refresh dispatch:** The internal refresh function iterates columns per row and dispatches `refreshFunc(columnFrame, dataItem)` for each populated cell. Empty cells are hidden.
- **Column layout:** Each column frame is positioned horizontally within its row at `(columnIndex-1) * (width/columnsPerLine)` plus horizontal padding.

**Returns:** `df_gridscrollbox`

---

## Menu with Grid Scrollbox — `CreateMenuWithGridScrollBox`

### Purpose

A grid scrollbox enhanced with a search bar and selection tracking. Used for browsable, clickable menus (e.g. spell selection lists).

### Signature

```lua
detailsFramework:CreateMenuWithGridScrollBox(parent, name, refreshMeFunc, refreshButtonFunc, clickFunc, onCreateButton, gridScrollBoxOptions)
```

### Parameters

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `parent` | `frame` | Parent frame. |
| 2 | `name` | `string?` | Global name. |
| 3 | `refreshMeFunc` | `function` | Called as `refreshMeFunc(gridScrollBox, searchText)` to rebuild data (typically filters data then calls `SetData` + `Refresh`). |
| 4 | `refreshButtonFunc` | `function` | Called as `refreshButtonFunc(button, data)` to populate each button. |
| 5 | `clickFunc` | `function` | Called as `clickFunc(button, data)` when a button is clicked. |
| 6 | `onCreateButton` | `function` | Called as `onCreateButton(button, lineIndex, columnIndex)` during button creation for custom setup. |
| 7 | `gridScrollBoxOptions` | `df_gridscrollbox_options` | Must also include `roundedFramePreset` for border styling. |

### How It Differs from Grid Scrollbox

- **Search box:** A `df_searchbox` is created and anchored above the grid. Typing triggers `refreshMeFunc`.
- **Selection state:** Tracks `dataSelected`. The selected button gets highlighted borders.
- **Button creation:** Each cell is a `df_button` with rounded corners, hover tooltip support, and click handling.
- **`Select(value, key)`:** Programmatically selects a data entry by matching `data[key] == value`.
- **`RefreshMe()`:** Calls `refreshMeFunc(gridScrollBox, searchText)`. The caller is responsible for filtering data and calling `SetData`/`Refresh`.

### Additional Fields

| Field | Type | Description |
|---|---|---|
| `searchBox` | `df_searchbox` | The search bar widget. |
| `data_original` | `table` | The unfiltered data. |

**Returns:** `df_gridscrollbox_menu`

---

## Aura Scrollbox — `CreateAuraScrollBox`

### Purpose

Displays a list of WoW spell auras (buffs/debuffs). Each row shows a spell icon, spell name, and a remove button. Designed for aura tracking configuration panels.

### Signature

```lua
detailsFramework:CreateAuraScrollBox(parent, name, data, onAuraRemoveCallback, options, onSetupAuraClick)
```

### Parameters

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `parent` | `frame` | Parent frame. |
| 2 | `name` | `string?` | Global name. Auto-generated if nil. |
| 3 | `data` | `table?` | A table keyed by spell ID → boolean. Can be set later. |
| 4 | `onAuraRemoveCallback` | `function?` | Called with `(spellId)` when an aura is removed. |
| 5 | `options` | `df_aurascrollbox_options?` | Configuration. |
| 6 | `onSetupAuraClick` | `function?` | If provided, each line gets a wrench icon button and "click to setup" text. |

### Options

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `300` | Width. |
| `height` | `number` | `500` | Height. |
| `line_height` | `number` | `18` | Height per row. |
| `line_amount` | `number` | `18` | Visible rows. |
| `vertical_padding` | `number` | `1` | Gap between rows. |
| `show_spell_tooltip` | `boolean` | `false` | Show GameTooltip on hover. |
| `remove_icon_border` | `boolean` | `true` | Crop icon borders via texcoords. |
| `no_scroll` | `boolean` | `false` | Hide scrollbar. |
| `no_backdrop` | `boolean` | `false` | Skip backdrop. |
| `backdrop_onenter` | `number[]` | `{.8,.8,.8,0.4}` | Backdrop color on mouse enter. |
| `backdrop_onleave` | `number[]` | `{.8,.8,.8,0.2}` | Backdrop color on mouse leave. |
| `font_size` | `number` | `12` | Spell name font size. |
| `title_text` | `string` | `""` | Title label text. |

### How It Differs from Base

- **Data format:** Input data is `{[spellId] = bAddedBySpellName, ...}`. Internally, `TransformAuraData()` converts this to a sorted array of `{spellId, spellName, spellIcon, lowerSpellName, bAddedBySpellName}` tuples.
- **Overridden `SetData`:** Stores original data in `data_original`, then transforms.
- **Overridden `Refresh`:** Calls `TransformAuraData()` before the base refresh.
- **Line contents:** Each line has an icon texture, spell name fontstring, remove button (X), and optional setup button (wrench).
- **Hover behavior:** Shows spell tooltip (optional) and GameCooltip with same-name spell variants if the spell was added by name.
- **Remove button:** Removes the spell ID from `data_original`, re-transforms, refreshes, and calls `onAuraRemoveCallback`.
- **Title label:** A fontstring anchored above the scrollbox, accessible via `GetTitleFontString()`.

**Returns:** `df_aurascrollbox`

---

## Data Scroll — `CreateDataScrollFrame`

### Purpose

Displays structured text entries. Each line has a title, date, and text body. Supports text filtering and alphabetical sorting. Useful for log viewers, changelog displays, or message lists.

### Signature

```lua
detailsFramework:CreateDataScrollFrame(parent, name, options)
```

### Parameters

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `parent` | `frame` | Parent frame. |
| 2 | `name` | `string` | Global name. |
| 3 | `options` | `table?` | Overrides for `default_datascroll_options`. |

### Default Options

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `400` | Width. |
| `height` | `number` | `700` | Height. |
| `line_amount` | `number` | `10` | Visible lines. |
| `line_height` | `number` | `20` | Line height. |
| `show_title` | `boolean` | `true` | Show title/date row above text. |
| `backdrop` | `table` | edge + bg | Backdrop definition. |
| `backdrop_color` | `table` | `{0,0,0,0.2}` | Default backdrop. |
| `backdrop_color_highlight` | `table` | `{.2,.2,.2,0.4}` | Hover backdrop. |
| `backdrop_border_color` | `table` | `{0.1,0.1,0.1,.2}` | Border color. |
| `title_template` | `string` | `"ORANGE_FONT_TEMPLATE"` | Font template for title/date. |
| `text_tempate` | `string` | `"OPTIONS_FONT_TEMPLATE"` | Font template for body text. |
| `create_line_func` | `function` | `DataScrollFunctions.CreateLine` | Line creation. |
| `update_line_func` | `function` | `DataScrollFunctions.UpdateLine` | Line update per row. |
| `refresh_func` | `function` | `DataScrollFunctions.RefreshScroll` | Refresh logic. |
| `on_enter` | `function` | `DataScrollFunctions.LineOnEnter` | Mouse enter handler. |
| `on_leave` | `function` | `DataScrollFunctions.LineOnLeave` | Mouse leave handler. |
| `on_click` | `function` | `DataScrollFunctions.OnClick` | Click handler (empty by default). |
| `data` | `table` | `{}` | Initial data. |

### Data Format

Each data entry is an indexed array: `{key, title, date, text}` where:
- `[1]` — sort/filter key
- `[2]` — title text (shown if `show_title`)
- `[3]` — date text (shown if `show_title`)
- `[4]` — body text (or `[2]` if `show_title` is false)

### DataScrollFunctions Mixin

| Method | Description |
|---|---|
| `RefreshScroll` | Filters data by `self.Filter` (substring match on any column), sorts alphabetically if `self.SortAlphabetical` is true, then populates lines. |
| `CreateLine` | Creates a line with Title, Date, and Text fontstrings, backdrop, and enter/leave/click scripts. |
| `UpdateLine` | Sets Title, Date, Text from the data entry. Calls `OnUpdateLineHook` if set. |
| `LineOnEnter` | Sets highlight backdrop color. |
| `LineOnLeave` | Restores normal backdrop color. |
| `OnClick` | Empty — override via options. |

### Additional Mixins

`OptionsFunctions` and `LayoutFrame` are mixed in for options management and layout.

**Returns:** `df_scrollbox` with data scroll configuration.

---

## Boss Scroll Selector — `CreateBossScrollSelectorForInstance`

### Purpose

Displays a scrollable list of raid/dungeon bosses from a specific instance. Each line shows a boss icon, boss name, and raid name. Clicking a boss triggers a callback.

### Signature

```lua
detailsFramework:CreateBossScrollSelectorForInstance(instanceId, parent, name, options, callback, ...)
```

### Parameters

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `instanceId` | `any` | Instance ID, EJ instance ID, or instance name. |
| 2 | `parent` | `frame` | Parent frame. |
| 3 | `name` | `string?` | Global name. |
| 4 | `options` | `df_bossscrollselector_options?` | Configuration. |
| 5 | `callback` | `function?` | Called as `callback(bossIndex, ...)` when a boss line is clicked. |
| 6 | `...` | `any` | Extra arguments passed to the callback. |

### Default Options

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `200` | Width. |
| `height` | `number` | `400` | Height. |
| `line_height` | `number` | `40` | Line height. |
| `line_amount` | `number` | `10` | Visible lines. |
| `show_icon` | `boolean` | `true` | Show boss icon. |
| `icon_coords` | `table` | `{0,1,0,1}` | Icon texture coordinates. |
| `icon_size` | `table` | `{70,36}` | Icon width and height. |
| `show_name` | `boolean` | `false` | Show boss name (always shown regardless of this flag in current code). |
| `name_size` | `number` | `10` | Boss name font size. |
| `name_color` | `any` | `"wheat"` | Boss name color. |

### BossScrollSelectorMixin

| Method | Description |
|---|---|
| `CreateLine(index)` | Creates a line with boss icon, boss name fontstring, raid name fontstring, highlight texture, and selected indicator. |
| `Refresh(data, offset, totalLines)` | Populates lines from `df_encounterinfo` data. Looks up instance info for raid name. Sets icon, name, truncated text. |
| `SetCallback(callback, ...)` | Sets the click callback on all existing lines. Stores `callback` and `callback_args`. |

### Data Source

Data is loaded automatically via `detailsFramework.Ejc.GetAllEncountersFromInstance(instanceId)` during construction. Returns `df_encounterinfo[]`.

**Returns:** `df_bossscrollselector`

---

## Simple List Box — `CreateSimpleListBox`

### Purpose

Displays a simple list of values from a key-value table. Each entry is a `df_button` with optional icon and X (remove) button. **Not built on `CreateScrollBox`** — it is a plain frame that creates buttons dynamically.

### Signature

```lua
detailsFramework:CreateSimpleListBox(parent, name, title, emptyText, listTable, onClick, options)
```

### Parameters

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `parent` | `frame` | Parent frame. |
| 2 | `name` | `string` | Global name. |
| 3 | `title` | `string` | Title text displayed above the list. |
| 4 | `emptyText` | `string` | Text shown when the list is empty. |
| 5 | `listTable` | `table` | A table whose keys are iterated as values. |
| 6 | `onClick` | `function` | Called with `(value)` when an entry is clicked. |
| 7 | `options` | `table?` | Overrides for `simplelistbox_default_options`. |

### Default Options

| Key | Type | Default | Description |
|---|---|---|---|
| `height` | `number` | `400` | Height. |
| `row_height` | `number` | `16` | Height per row. |
| `width` | `number` | `230` | Width. |
| `icon` | `any` | `false` | Icon path/function or false. |
| `text` | `any` | `""` | Text string or function returning text. |
| `text_size` | `number` | `10` | Font size. |
| `textcolor` | `any` | `"wheat"` | Text color. |
| `backdrop_color` | `table` | `{1,1,1,.5}` | Button backdrop color. |
| `panel_border_color` | `table` | `{0,0,0,0.5}` | Border color. |
| `show_x_button` | `boolean` | — | If true, show remove (X) button per row. |
| `x_button_func` | `function` | — | Called with `(value)` when X is clicked. |

### How It Works

- Does **not** use faux scrolling. All entries are rendered at once.
- Data is a table iterated with `pairs()` (unordered).
- `Refresh()` calls `ResetWidgets()` (hides all), then creates/reuses buttons via `GetOrCreateWidget()`.
- Each button shows the value as text (or via `options.text` function), optional icon, and optional X button.
- `SetData(t)` replaces the list table.

**Returns:** a frame with `Refresh`, `SetData`, `ResetWidgets`, `GetOrCreateWidget` methods.

---

## Canvas Scrollbox — `CreateCanvasScrollBox`

### Purpose

A free-form scrollable viewport. Instead of line-based data display, it scrolls a single child frame that can be any size. If the child is taller than the canvas, vertical scrolling is enabled. Used for scrolling large settings panels, text blocks, or custom layouts.

### Signature

```lua
detailsFramework:CreateCanvasScrollBox(parent, child, name, options)
```

### Parameters

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `parent` | `frame` | Parent frame. |
| 2 | `child` | `frame?` | The frame to scroll. Created automatically if nil. |
| 3 | `name` | `string?` | Global name. Auto-generated if nil. |
| 4 | `options` | `table?` | Configuration overrides. |

### Default Options

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `600` | Viewport width. |
| `height` | `number` | `400` | Viewport height. |
| `reskin_slider` | `boolean` | `true` | Apply `ReskinSlider` to the scrollbar. |
| `smooth_scrolling` | `boolean` | `false` | Animate scroll position on mouse wheel instead of snapping. |
| `smooth_scrolling_speed` | `number` | `12` | Easing rate for smooth scrolling. Higher = faster convergence on the target. |
| `smooth_scrolling_acceleration` | `boolean` | `false` | When `true`, rapid wheel ticks scale up the scroll step (velocity-based acceleration). Applies to both smooth scrolling and momentum modes. |
| `smooth_scrolling_acceleration_factor` | `number` | `4` | Maximum step multiplier applied during rapid wheel input. |
| `use_momentum` | `boolean` | `false` | When `true`, the OnUpdate handler uses momentum/inertia: each wheel tick adds velocity, which decays exponentially over time (phone-style flick scrolling). Takes priority over `smooth_scrolling`. |
| `momentum_friction` | `number` | `4` | Decay rate for momentum velocity. Higher = stops sooner; lower = longer glide. With `4`, ~98% of velocity is lost in 1 second. |
| `use_drag_scroll` | `boolean` | `false` | When `true`, holding the left mouse button on the scrollframe and dragging up/down scrolls the content 1:1 with the cursor (touchscreen-style). Releasing while moving hands off to momentum if `use_momentum` is also enabled. |

### How It Differs from Base

- Uses `UIPanelScrollFrameTemplate` instead of `FauxScrollFrameTemplate`.
- **No line system** — scrolls a single child frame via `SetScrollChild`.
- Mouse wheel scrolling moves the viewport by `scrollStep` pixels (default 20).
- No data table, refresh function, or line creation.

### CanvasScrollBoxMixin

| Method | Description |
|---|---|
| `SetScrollSpeed(speed)` | Set pixels scrolled per mouse wheel tick. |
| `GetScrollSpeed()` | Get current scroll speed. |
| `SetSmoothScrolling(enabled)` | Enable or disable smooth (animated) scrolling. Disabling cancels any in-flight animation. |
| `GetSmoothScrolling()` | Returns whether smooth scrolling is enabled. |
| `SetSmoothScrollSpeed(speed)` | Set the easing rate used while smooth scrolling. Higher = faster convergence. |
| `SetSmoothScrollingAcceleration(enabled)` | Enable or disable velocity-based step scaling. Applied while either smooth scrolling or momentum is on. |
| `GetSmoothScrollingAcceleration()` | Returns whether smooth scrolling acceleration is enabled. |
| `SetSmoothScrollingAccelerationFactor(factor)` | Set the maximum step multiplier reached at very fast wheel rates. |
| `SetUseMomentum(enabled)` | Enable or disable momentum (inertia) scrolling. Toggling clears any in-flight motion. |
| `GetUseMomentum()` | Returns whether momentum scrolling is enabled. |
| `SetMomentumFriction(friction)` | Set the velocity decay rate. Higher = stops sooner. |
| `SetUseDragScroll(enabled)` | Enable or disable click-and-drag scrolling. Calls `EnableMouse(enabled)` so the scrollframe receives `OnMouseDown`/`OnMouseUp`. |
| `GetUseDragScroll()` | Returns whether drag scrolling is enabled. |
| `OnVerticalScroll(delta)` | Handles mouse wheel. Dispatches to momentum (if `useMomentum`), smooth easing (if `smoothScrolling`), or instant snap. |

### Smooth Scrolling

When enabled, mouse wheel events update a `targetScroll` value (computed from the previous target, so rapid wheel ticks accumulate correctly), and an `OnUpdate` script eases `GetVerticalScroll()` toward it each frame using exponential smoothing: `current + (target - current) * min(elapsed * smoothScrollSpeed, 1)`. The `OnUpdate` script unhooks itself once the position is within 0.5 px of the target.

#### Velocity-Based Acceleration

When `smooth_scrolling_acceleration` is enabled, the time between consecutive wheel ticks is measured. If ticks arrive rapidly, the per-tick `scrollStep` is multiplied by a boost factor:

```
boost = min(0.15 / dt, smoothScrollingAccelerationFactor)
```

- A wheel tick 150 ms or more after the previous one → boost = 1 (no change).
- Faster ticks → larger boost, capped at `smoothScrollingAccelerationFactor`.
- Acceleration applies to both smooth scrolling and momentum modes (it scales the per-tick step, which becomes the velocity kick under momentum).

### Momentum Scrolling

When `use_momentum` is enabled, the `OnUpdate` algorithm switches from target-easing to velocity-based motion (phone-style flick scrolling). It takes priority over `smooth_scrolling`.

Each wheel tick adds a velocity kick:

```
kick = scrollStep * momentumFriction
```

The relationship is chosen so that under no further input, one isolated tick travels approximately `scrollStep` total pixels (the integral of the decaying velocity).

Per frame, position integrates from velocity and velocity decays exponentially:

```
position(t+dt) = position(t) + velocity * dt
velocity(t+dt) = velocity(t) * exp(-momentumFriction * dt)
```

- Velocity below 1 px/sec is treated as stopped; the `OnUpdate` script unhooks itself.
- Hitting top or bottom (`0` or `verticalScrollRange`) clamps the position and zeroes velocity (no bounce).
- Reversing direction mid-glide drops the existing velocity instead of fighting it.
- Disabling momentum (or smooth scrolling) clears `scrollVelocity`, `targetScroll`, and `lastWheelTime`.

### Drag Scrolling

When `use_drag_scroll` is enabled, holding the left mouse button on the scrollframe lets the user drag the content like a touchscreen.

**How it works:**

- `EnableMouse(true)` is set so the scrollframe receives `OnMouseDown`/`OnMouseUp`. Children with their own mouse handling (buttons, sliders, etc.) still consume their clicks first — drag only initiates from non-interactive areas of the child.
- `OnMouseDown` (left button) starts a drag: clears any in-flight motion, records the cursor Y, and hooks `OnUpdate`.
- Each frame while dragging, `SetVerticalScroll(currentScroll + (cursorY - lastCursorY))` keeps the content under the cursor 1:1. Cursor positions are normalized through `GetEffectiveScale()`. Cursor samples (timestamp + Y) from the last 100 ms are kept for release-velocity computation.
- The drag also runs while the cursor is outside the frame as long as the left button is held. Releases that happen off-frame (where `OnMouseUp` doesn't fire on the scrollframe) are caught by polling `IsMouseButtonDown("LeftButton")` from inside the drag `OnUpdate`.
- On release: if `use_momentum` is also enabled, the average cursor velocity over the last 100 ms is seeded into `scrollVelocity` and momentum takes over (so a flick-and-release glides). Otherwise scrolling stops immediately.
- Mouse wheel still works while drag scrolling is enabled.

### Key Fields

| Field | Type | Description |
|---|---|---|
| `child` | `frame` | The scroll child frame. |
| `scrollStep` | `number` | Pixels per scroll tick (default 20). |
| `minValue` | `number` | Minimum scroll value (always 0). |
| `smoothScrolling` | `boolean` | Whether smooth scrolling is active. |
| `smoothScrollSpeed` | `number` | Easing rate for smooth scrolling. |
| `smoothScrollingAcceleration` | `boolean` | Whether velocity-based acceleration is active. |
| `smoothScrollingAccelerationFactor` | `number` | Maximum step multiplier under rapid wheel input. |
| `useMomentum` | `boolean` | Whether momentum/inertia scrolling is active. Takes priority over `smoothScrolling`. |
| `momentumFriction` | `number` | Velocity decay rate for momentum scrolling. |
| `useDragScroll` | `boolean` | Whether click-and-drag scrolling is active. |
| `isDragging` | `boolean?` | True while the left button is held down for a drag. |
| `dragLastY` | `number?` | Cursor Y from the previous drag frame, used to compute per-frame deltas. |
| `dragSamples` | `table?` | Recent `{time, cursorY}` samples (last 100 ms) used to compute release velocity. |
| `scrollVelocity` | `number?` | Current scroll velocity (px/sec) under momentum mode. `nil` or `0` when stopped. Negative = up, positive = down. |
| `targetScroll` | `number?` | The scroll position the smooth animation is easing toward. `nil` when no animation is in flight. |
| `lastWheelTime` | `number?` | Timestamp of the last wheel tick. Used to compute the velocity boost. |

**Returns:** `df_canvasscrollbox`

---

## The `RefreshMe` Pattern

Several scrollbox types support a `RefreshMe` method. This is a **virtual method** — the base scrollbox declares it in its class definition but does not implement it. The caller is expected to define it on the scrollbox instance when the data needs to be filtered, transformed, or fetched before display.

Convention:

```lua
function scrollBox:RefreshMe()
    -- manipulate / filter / fetch data
    local newData = getFilteredData()
    self:SetData(newData)
    self:Refresh()
end
```

This keeps data manipulation colocated with the scrollbox that displays it.

---

## Usage Examples

### Basic Scrollbox

```lua
local lineHeight = 20
local lineAmount = 10

local refreshFunc = function(self, data, offset, totalLines)
    for i = 1, totalLines do
        local index = i + offset
        local thisData = data[index]
        if (thisData) then
            local line = self:GetLine(i)
            line.NameText:SetText(thisData.name)
        end
    end
end

local createLineFunc = function(self, index)
    local line = CreateFrame("button", "$parentLine" .. index, self)
    line:SetPoint("topleft", self, "topleft", 0, -lineHeight * (index - 1))
    line:SetSize(200, lineHeight)
    line.NameText = line:CreateFontString(nil, "overlay", "GameFontNormal")
    line.NameText:SetPoint("left", line, "left", 2, 0)
    return line
end

local data = {{name = "Alpha"}, {name = "Beta"}, {name = "Gamma"}}

local scrollBox = DetailsFramework:CreateScrollBox(parent, "MyScrollBox", refreshFunc, data, 200, 200, lineAmount, lineHeight)

for i = 1, lineAmount do
    scrollBox:CreateLine(createLineFunc)
end

scrollBox:Refresh()
```

### Updating Data and Refreshing

```lua
local newData = {{name = "Delta"}, {name = "Epsilon"}}
scrollBox:SetData(newData)
scrollBox:Refresh()
```

### Grid Scrollbox

```lua
local refreshFunc = function(button, data)
    button.text:SetText(data.label)
    button:Show()
end

local createColumnFunc = function(line, lineIndex, columnIndex)
    local btn = CreateFrame("button", "$parentCol" .. columnIndex, line)
    btn:SetSize(100, 30)
    btn.text = btn:CreateFontString(nil, "overlay", "GameFontNormal")
    btn.text:SetPoint("center")
    DetailsFramework:ApplyStandardBackdrop(btn)
    return btn
end

local data = {{label="A"}, {label="B"}, {label="C"}, {label="D"}, {label="E"}}

local grid = DetailsFramework:CreateGridScrollBox(parent, "MyGrid", refreshFunc, data, createColumnFunc, {
    width = 400, height = 200,
    line_amount = 5, columns_per_line = 3, line_height = 30,
})
grid:SetPoint("center")
grid:Refresh()
```

### Canvas Scrollbox

```lua
local content = CreateFrame("frame", nil, nil, "BackdropTemplate")
content:SetSize(400, 1200) -- taller than the viewport

local canvas = DetailsFramework:CreateCanvasScrollBox(parent, content, "MyCanvas")
canvas:SetSize(400, 300) -- viewport
canvas:SetPoint("center")
```

### Real-World Pattern — Damage Log (window_scrolldamage.lua)

```lua
-- 1. Create scrollbox with empty data
local damageScroll = DF:CreateScrollBox(parent, "$parentSpellScroll", refreshFunc, data, 395, 340, 16, 20)

-- 2. Create lines
for i = 1, 16 do
    damageScroll:CreateLine(createLineFunc)
end

-- 3. Data arrives in real-time (combat log events)
table.insert(data, 1, {time, token, ..., spellID, spellName, amount, isCritical})

-- 4. Custom RefreshScroll filters by search text, then calls SetData + Refresh
function damageScroll:RefreshScroll()
    if (searchText and searchText ~= "") then
        local filtered = {}
        for _, entry in ipairs(allData) do
            if (entry.spellName:lower():find(searchText)) then
                filtered[#filtered+1] = entry
            end
        end
        damageScroll:SetData(filtered)
    else
        damageScroll:SetData(allData)
    end
    damageScroll:Refresh()
end
```

---

## Choosing a Scrollbox Type

| Need | Type | Why |
|---|---|---|
| Simple list of rows | `CreateScrollBox` | Full control over line layout and refresh. |
| Grid of cells | `CreateGridScrollBox` | Handles column layout and data chunking. |
| Searchable grid with selection | `CreateMenuWithGridScrollBox` | Adds search bar, click selection, and border highlighting. |
| Spell/aura list | `CreateAuraScrollBox` | Handles spell ID → name resolution, icons, remove buttons, tooltips. |
| Text log with title/date | `CreateDataScrollFrame` | Built-in filtering, sorting, title/date/body layout. |
| Boss/encounter list | `CreateBossScrollSelectorForInstance` | Auto-loads boss data from instance, shows icons and raid names. |
| Key-value display (small) | `CreateSimpleListBox` | No scrolling — all items rendered. Good for short lists. |
| Free-form scrolling | `CreateCanvasScrollBox` | Scrolls a single child frame of any size. No line system. |
