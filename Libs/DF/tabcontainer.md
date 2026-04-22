# Tab Container System

## Overview

A tab container is a frame that organizes UI content into multiple tabs. Each tab has a **button** (for selection) and a **frame** (for content). Only one tab frame is visible at a time — clicking a tab button hides all others and shows the associated frame.

All tabs are defined at construction time via a `tabList` array. There is no API to add or remove tabs after creation.

### Lifecycle

```
CreateTabContainer(parent, title, frameName, tabList, options)
    │
    ├── Creates the container frame (df_tabcontainer)
    ├── Creates a title fontstring
    ├── For each entry in tabList:
    │     ├── Creates a tab frame (df_tabcontainerframe) — hidden
    │     ├── Creates a tab button (df_tabcontainerbutton) — click selects this tab
    │     ├── Creates underline glow on the button
    │     └── Creates "right click to close/go back" label
    ├── Arranges buttons in rows
    └── Selects tab 1
```

---

## `CreateTabContainer`

### Signature

```lua
detailsFramework:CreateTabContainer(parent, title, frameName, tabList, optionsTable, hookList, languageInfo)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | Yes | Parent frame. The container is created as a child of `parent.widget or parent`. |
| 2 | `title` | `string` | Yes | Main title displayed at the top-left of the container (size 24, white). |
| 3 | `frameName` | `string` | Yes | Global name for the container frame (passed to `CreateFrame`). |
| 4 | `tabList` | `df_tabinfotable[]` | Yes | Array of tab definitions. See below. |
| 5 | `optionsTable` | `df_tabcontaineroptions?` | No | Configuration overrides. See below. |
| 6 | `hookList` | `table?` | No | Hook functions. Currently supports `OnSelectIndex`. |
| 7 | `languageInfo` | `table?` | No | If provided, `language_addonId` is used to register tab text with the DF language system for localization. |

### Tab List Entry (`df_tabinfotable`)

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Internal name. Used as frame name suffix and as a lookup key in `AllFramesByName` / `AllButtonsByName`. |
| `text` | `string` | Yes | Display text on the tab button and tab title. Also used as an alternate lookup key in `AllFramesByName` / `AllButtonsByName`. |
| `createOnDemandFunc` | `function?` | No | If set, called the first time the tab frame is shown: `function(tabFrame, tabContainer, parent)`. The function is nil'd after execution so it only runs once. |

### Options Table (`df_tabcontaineroptions`)

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `750` | Container width. |
| `height` | `number` | `450` | Container height. |
| `button_width` | `number` | `160` | Width of each tab button. |
| `button_height` | `number` | `20` | Height of each tab button. |
| `button_x` | `number` | `230` | Horizontal offset for the first button (relative to the title). |
| `button_y` | `number` | `0` | Vertical offset for the first button row. |
| `button_text_size` | `number` | `10` | Font size for button text. |
| `button_border_color` | `table` | `{0,0,0,0}` | Border color for unselected tab buttons. |
| `button_selected_border_color` | `table` | `{1,1,0,1}` | Border color for the selected tab button. |
| `y_offset` | `number` | `0` | Vertical offset for the title position. |
| `container_width_offset` | `number` | `0` | Additional width adjustment for button row layout calculation. |
| `can_move_parent` | `boolean` | `true` | If true, left-dragging a tab frame moves the highest parent frame. |
| `right_click_interact` | `boolean` | `true` | If true, right-clicking the first tab closes the container; right-clicking other tabs returns to tab 1. If false, right-click does nothing. |
| `rightbutton_always_close` | `boolean` | — | If true, all tabs show "right click to close" instead of only tab 1. |
| `hide_click_label` | `boolean` | — | If true, hides the "right click to close/go back" label on all tabs. |
| `close_text_alpha` | `number` | — | Alpha for the right-click instruction label. |
| `right_click_y` | `number` | `0` | Vertical offset for the right-click label position. |

### Returns

`df_tabcontainer` — the container frame with all tabs created and tab 1 selected.

---

## Container Fields (`df_tabcontainer`)

| Field | Type | Description |
|---|---|---|
| `AllFrames` | `df_tabcontainerframe[]` | Array of all tab frames, ordered by `tabList` index. |
| `AllButtons` | `df_tabcontainerbutton[]` | Array of all tab buttons, ordered by `tabList` index. |
| `AllFramesByName` | `table` | Map of tab frames, keyed by both `name` and `text` from the tab definition. |
| `AllButtonsByName` | `table` | Map of tab buttons, keyed by both `name` and `text` from the tab definition. |
| `CurrentIndex` | `number` | Index of the currently selected tab (1-based). |
| `IsContainer` | `boolean` | Always `true`. |
| `ButtonSelectedBorderColor` | `table` | RGBA color for the selected button's border. |
| `ButtonNotSelectedBorderColor` | `table` | RGBA color for unselected button borders. |
| `CanCloseWithRightClick` | `boolean` | Whether right-click closes/navigates. |
| `hookList` | `table` | Hook functions table. |
| `options` | `df_tabcontaineroptions` | The resolved options table. |

---

## Tab Container Methods (`TabContainerMixin`)

### `SelectTabByIndex(menuIndex)`

Switches to the tab at the given 1-based index:

1. Hides all tab frames.
2. Resets all button border colors to `ButtonNotSelectedBorderColor`.
3. Hides all button underline glows.
4. Shows the target tab frame.
5. Calls `tabFrame:RefreshOptions()` if defined on the frame.
6. Sets the target button's border to `ButtonSelectedBorderColor`.
7. Shows the target button's underline glow.
8. Updates `CurrentIndex`.
9. Calls `hookList.OnSelectIndex(tabContainer, tabButton)` if defined.

### `SelectTabByName(name)`

Looks up the tab in `AllFramesByName` by `name` (matches both the `name` and `text` fields), then delegates to `SelectTabByIndex`. Errors if the name is not found.

### `SetIndex(index)`

Sets `CurrentIndex` without changing visibility. Use when you want to change which tab opens on next `OnShow` without immediately switching.

### `GetTabFrameByIndex(tabIndex)` → `df_tabcontainerframe`

Returns the tab frame at the given index.

### `GetTabFrameByName(name)` → `df_tabcontainerframe`

Returns the tab frame matching `name` (looks up by both `name` and `text` keys).

### `GetTabButtonByIndex(tabIndex)` → `df_tabcontainerbutton`

Returns the tab button at the given index.

### `GetTabButtonByName(name)` → `df_tabcontainerbutton`

Returns the tab button matching `name` (looks up by both `name` and `text` keys).

### `CallOnEachTab(callback, ...)`

Calls `callback(tabFrame, ...)` for every tab frame in `AllFrames`.

### `SetTabFramesBackdrop(backdropTable, backdropColorTable, backdropBorderColorTable)`

Applies backdrop, backdrop color, and/or backdrop border color to all tab frames. Any parameter can be nil to skip that step.

### `OnShow()`

When the container is shown, it calls `SelectTabByIndex(CurrentIndex)` to restore the last selected tab (or tab 1 by default).

---

## Tab Frame Behavior (`TabContainerFrameMixin`)

Each tab frame has `OnMouseDown` and `OnMouseUp` scripts:

### Left-click drag

If `options.can_move_parent` is true, left-clicking and dragging a tab frame moves the highest ancestor frame (found via `DF:FindHighestParent`). The ancestor must be movable (`IsMovable() == true`).

### Right-click

Behavior depends on which tab is active:

- **Tab 1 (front page):** If `CanCloseWithRightClick`, calls `highestParent:CloseFunction()` if it exists, otherwise calls `highestParent:Hide()`.
- **Other tabs:** Right-click navigates back to tab 1 via `SelectTabByIndex(1)`.

The `bIsFrontPage` flag on tab 1 (and on all tabs if `rightbutton_always_close` is set) controls which behavior applies.

---

## Tab Button Details (`df_tabcontainerbutton`)

Each tab button is a `df_button` created with the `OPTIONS_BUTTON_TEMPLATE` (with border color removed). It has:

| Field | Type | Description |
|---|---|---|
| `selectedUnderlineGlow` | `texture` | Yellow gradient glow shown below the button when selected. Created by `CreateUnderlineGlow`. |
| `textsize` | `number` | Set to `button_text_size` from options. |
| `mainFrame` | `df_tabcontainer` | Reference to the parent container. |

Clicking the button calls `tabContainer:SelectTabByIndex(tabIndex)`.

---

## `createOnDemandFunc` — Lazy Tab Initialization

If a tab definition includes `createOnDemandFunc`, the tab frame's content is not built until the tab is first shown. This is useful for expensive UI that the user may never visit.

- The function is set as the tab frame's `OnShow` script.
- On first show, it calls `createOnDemandFunc(tabFrame, tabContainer, parent)` inside `xpcall`.
- After execution, `createOnDemandFunc` is set to `nil` so it never runs again.
- Subsequent shows of the tab frame do nothing special.

If tab 1 has a `createOnDemandFunc`, initial selection is deferred via `C_Timer.After(0, ...)` to allow the frame to fully initialize.

---

## Hook List

The `hookList` table passed to `CreateTabContainer` supports:

| Key | Callback Signature | When Called |
|---|---|---|
| `OnSelectIndex` | `function(tabContainer, tabButton)` | After a tab is selected via `SelectTabByIndex`. |

---

## Button Layout

Buttons are arranged in rows starting at `(button_x, button_y)` relative to the title fontstring. Each button is `button_width` wide with 2px spacing. When buttons exceed the available width (`parentFrameWidth - buttonAnchorX + containerWidthOffset`), they wrap to the next row (`y - buttonHeight - 1`).

---

## Name Lookup

Both `AllFramesByName` and `AllButtonsByName` are keyed by **both** `tabInfo.name` and `tabInfo.text`. This means you can look up a tab using either its internal name or its display text:

```lua
-- These both return the same frame:
tabContainer:GetTabFrameByName("GeneralSettings")  -- by name
tabContainer:GetTabFrameByName("General Settings")  -- by text
```

---

## Usage Examples

### Basic Tab Container

```lua
local tabList = {
    {name = "General", text = "General Settings"},
    {name = "Advanced", text = "Advanced Settings"},
    {name = "About", text = "About"},
}

local tabContainer = DF:CreateTabContainer(parent, "My Options", "MyOptionsFrame", tabList, {
    width = 750,
    height = 450,
    button_width = 160,
})
tabContainer:SetPoint("center", UIParent, "center")
tabContainer:Show()
```

### Adding Content to Tabs

```lua
local generalFrame = tabContainer:GetTabFrameByIndex(1)
-- Create widgets inside generalFrame:
local label = DF:CreateLabel(generalFrame, "Hello from General tab")
label:SetPoint("center")
```

### Programmatic Tab Switching

```lua
-- By index
tabContainer:SelectTabByIndex(2)

-- By name or text
tabContainer:SelectTabByName("Advanced")
tabContainer:SelectTabByName("Advanced Settings")
```

### Lazy Tab with `createOnDemandFunc`

```lua
local tabList = {
    {name = "Main", text = "Main"},
    {name = "Heavy", text = "Heavy Tab", createOnDemandFunc = function(tabFrame, tabContainer, parent)
        -- This runs only the first time the tab is shown
        local label = DF:CreateLabel(tabFrame, "Loaded on demand")
        label:SetPoint("center")
    end},
}
```

### Styling Tab Frame Backgrounds

```lua
local backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
    bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true}
tabContainer:SetTabFramesBackdrop(backdrop, {0, 0, 0, 0.8}, {0, 0, 0, 1})
```

### Using the `OnSelectIndex` Hook

```lua
local hookList = {
    OnSelectIndex = function(tabContainer, tabButton)
        print("Switched to tab:", tabContainer.CurrentIndex)
    end,
}

local tabContainer = DF:CreateTabContainer(parent, "Title", "Frame", tabList, {}, hookList)
```
