# Keybind Frame System Documentation

## Overview

The keybind frame system provides a full UI panel for binding keyboard/mouse keys to actions such as spells, unit controls (target/focus/menu), and custom macros. It includes a scrollable list of bindable actions, a keybind listener for capturing key presses, and an edit panel for modifying keybind names, icons, macros, and load conditions.

The system is composed of three parts:

| Component | Purpose |
|---|---|
| `DetailsFramework:CreateKeybindFrame()` | Entry point. Creates and returns a `df_keybindframe` instance. |
| `detailsFramework.KeybindMixin` | Methods mixed into each keybind frame instance. |
| `default_options` | Local table of default configuration values. |

### Key Types

| Type | Description |
|---|---|
| `df_keybindframe` | The main frame. Contains the scroll list, keybind listener, edit panel, header, and all mixin methods. |
| `df_keybind` | A single keybind entry with fields: `name`, `action`, `keybind`, `macro`, `conditions`, `icon`. |
| `df_keybindscroll` | The scroll box listing all bindable actions. |
| `df_editkeybindframe` | The side panel for editing a selected keybind's name, icon, macro text, and load conditions. |
| `df_keybindscrollline` | A single row in the scroll list. Contains icon, name, set-keybind button, clear button, and edit button. |
| `actionidentifier` | A string in the format `"type-id"`, e.g. `"spell-12345"`, `"macro-MyMacro"`, `"system-target"`. |

---

## Creating a Keybind Frame

```lua
local keybindFrame = DetailsFramework:CreateKeybindFrame(parent, name, options, callback, keybindData)
```

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | yes | The parent frame. |
| 2 | `name` | `string` or `nil` | no | Global frame name. |
| 3 | `options` | `table` or `nil` | no | Overrides for default options. |
| 4 | `callback` | `function` or `nil` | no | Called when keybinds are modified, removed, or edited. |
| 5 | `keybindData` | `df_keybind[]` or `nil` | no | Array of existing keybind entries (typically from saved variables). Defaults to `{}`. |

### Returns

A `df_keybindframe` — a `Frame` (with `BackdropTemplate`) that has `KeybindMixin` and `OptionsFunctions` mixed in.

### Initialization Sequence

1. A new `frame` is created with `BackdropTemplate`. `bIsKeybindFrame = true` is set for parent-traversal identification.
2. `OptionsFunctions` and `KeybindMixin` are mixed in.
3. `BuildOptionsTable` merges caller's `options` with defaults.
4. If `width` or `height` differ from defaults, `amount_lines`, `scroll_height`, and `scroll_width` are recalculated automatically.
5. If `edit_height` is `0`, it is set to match `height`.
6. Frame size is set from options.
7. `OnHide` script: stops listening, stops editing, re-enables buttons.
8. `OnShow` script: refreshes the scroll data.
9. Creates the keybind scroll (`CreateKeybindScroll`), keybind listener (`CreateKeybindListener`), and edit panel (`CreateEditPanel`).
10. Sets keybind data and callback.

---

## Default Options

| Option | Default | Description |
|---|---|---|
| `width` | `580` | Width of the keybind frame. |
| `height` | `500` | Height of the keybind frame. |
| `edit_width` | `400` | Width of the edit panel (shown to the right). |
| `edit_height` | `0` | Height of the edit panel. `0` = auto-match to `height`. |
| `scroll_width` | `580` | Width of the scroll box. |
| `scroll_height` | `480` | Height of the scroll box. |
| `amount_lines` | `18` | Number of visible scroll lines. |
| `line_height` | `26` | Height of each scroll line. |
| `show_spells` | `true` | Whether player spells are listed. |
| `show_unitcontrols` | `true` | Whether unit controls (target/focus/menu) are listed. |
| `show_macros` | `true` | Whether macro keybinds are listed. |
| `can_modify_keybind_data` | `true` | If `true`, the system directly modifies the `keybindData` table (insert/remove/update). If `false`, the addon must handle all data changes in the callback. |

---

## Keybind Data (`df_keybind`)

Each keybind entry is a table with these fields:

| Field | Type | Description |
|---|---|---|
| `name` | `string` | Display name for the keybind (spell name, macro name, or action label). |
| `action` | `string` or `number` | What the keybind does. A `number` = spellId, `"target"`/`"focus"`/`"togglemenu"` = system action, `"macro-MacroName"` = macro. |
| `keybind` | `string` | The key combination, e.g. `"CTRL-SHIFT-A"`, `"type1"` (left click), `""` (unset). |
| `macro` | `string` | Macro text (only for macro-type keybinds). |
| `conditions` | `table` | Load conditions table (managed by `DetailsFramework:OpenLoadConditionsPanel`). |
| `icon` | `string` or `number` | Icon texture path or ID. |

---

## Callback

The callback function is called whenever a keybind is modified, removed, or its settings change.

```lua
function callback(keybindFrame, type, keybindTable, keybindPressed, removedIndex, macroText)
```

| Parameter | Type | Description |
|---|---|---|
| `keybindFrame` | `df_keybindframe` | The keybind frame instance. |
| `type` | `string` | One of: `"modified"`, `"removed"`, `"conditions"`, `"name"`, `"icon"`, `"macro"`. |
| `keybindTable` | `df_keybind` or `nil` | The keybind entry involved (nil for `"removed"`). |
| `keybindPressed` | `string` or `nil` | The key combination string (for `"modified"`). |
| `removedIndex` | `number` or `nil` | Index of the removed entry in the keybind data array (for `"removed"`). |
| `macroText` | `string` or `nil` | The macro text (for `"macro"`). |

### `can_modify_keybind_data` Behavior

- When `true` (default): The system directly inserts/removes/updates entries in the keybind data array. The callback is informational.
- When `false`: The system does **not** modify the data table. The callback is responsible for all data mutations. For `"modified"`, the addon must set `keybindTable.keybind = keybindPressed`. For `"removed"`, the addon must call `table.remove(keybindData, removedIndex)`.

---

## Methods (`KeybindMixin`)

### Data Access

#### GetKeybindData()

```lua
local data = keybindFrame:GetKeybindData()
```

Returns the `df_keybind[]` array currently backing the frame.

---

#### SetKeybindData(newData)

```lua
keybindFrame:SetKeybindData(newData)
```

Replaces the keybind data array and refreshes the scroll.

---

#### SetKeybindCallback(callback)

```lua
keybindFrame:SetKeybindCallback(callback)
```

Sets or replaces the callback function. Refreshes the scroll.

---

#### GetKeybindCallback()

```lua
local callback = keybindFrame:GetKeybindCallback()
```

Returns the current callback function.

---

#### CallKeybindChangeCallback(type, keybindTable, keybindPressed, removedIndex, macroText)

```lua
keybindFrame:CallKeybindChangeCallback("modified", keybindTable, "CTRL-A")
```

Invokes the callback via `DetailsFramework:Dispatch`. Parameters match the callback signature.

---

### Listening State

The "listening" state means the frame is waiting for the player to press a key or click a mouse button to assign a keybind.

#### IsListening()

```lua
local bIsListening = keybindFrame:IsListening()
```

Returns `true` if the frame is waiting for a keypress.

---

#### GetListeningActionId()

```lua
local actionId = keybindFrame:GetListeningActionId()
```

Returns the `actionIdentifier` the frame is currently listening for.

---

#### SetListeningState(value, actionIdentifier, button, keybindScrollData)

```lua
keybindFrame:SetListeningState(true, "spell-12345", buttonFrame, scrollData)
```

Sets or clears the listening state. When entering listening mode, disables clear and edit buttons on all scroll lines. When exiting, re-enables them.

---

#### GetListeningState()

```lua
local bIsListening, actionIdentifier, button, keybindScrollData = keybindFrame:GetListeningState()
```

Returns all listening state fields.

---

### Keybind Listener

#### GetKeybindListener()

```lua
local listener = keybindFrame:GetKeybindListener()
```

Returns the tooltip-strata popup frame that shows "Press a keyboard key to bind" instructions.

---

#### CreateKeybindListener()

**Internal method.** Creates the listener popup frame (`200×60`, tooltip strata) with instruction text. Called once during initialization.

---

### Key Processing

#### OnUserClickedToChooseKeybind(button, actionIdentifier, keybindTable)

Called when the player clicks the "set keybind" button on a scroll line.

**Behavior:**
1. If already listening on the same button, treats the click as a mouse-button keybind assignment (converts click type to `type1`/`type2`/etc.).
2. Otherwise, enters listening mode: stores the action identifier, registers `OnKeyDown` on the frame, and shows the listener popup above the clicked button.
3. If the edit panel is open, closes it.

---

#### OnUserPressedKeybind(keyPressed)

Called when a key is pressed while in listening mode (via `OnKeyDown` script) or from `OnUserClickedToChooseKeybind` for mouse buttons.

**Behavior:**
1. Ignores modifier-only keys (LSHIFT, RSHIFT, LCTRL, RCTRL, LALT, RALT, UNKNOWN).
2. If ESCAPE is pressed, cancels listening and hides the popup.
3. Constructs the keybind string: `modifiers + keyPressed` (e.g. `"CTRL-SHIFT-A"`).
4. Parses the action identifier to get `keybindType` and `actionId`.
5. Looks up the existing `df_keybind` entry via `FindKeybindTable`.
6. If no entry exists, creates a new one based on type:
   - `"spell"`: uses spell name/icon from `GetSpellInfo`.
   - `"system"`: uses name/icon from default mouse keybind table.
   - `"macro"`: creates with name `"New Macro"` and text `"/say hi"`.
7. If `can_modify_keybind_data` is `true`, saves to the data table via `SaveKeybindToKeybindData`.
8. Calls the change callback with `"modified"`.
9. Exits listening mode and refreshes the scroll.

---

#### GetPressedModifiers()

```lua
local mods = keybindFrame.GetPressedModifiers()
```

**Static method.** Returns a string like `"SHIFT-CTRL-ALT-"` based on which modifier keys are currently held.

---

#### GetKeybindModifiers(keybind)

```lua
local mods = keybindFrame.GetKeybindModifiers("CTRL-SHIFT-A")
-- Returns "SHIFT-CTRL-"
```

**Static method.** Extracts the modifier prefix from a keybind string.

---

### Keybind Lookup

#### FindKeybindTable(keybindType, actionId, actionIdentifier)

```lua
local keybindTable, index = keybindFrame:FindKeybindTable("spell", 12345)
local keybindTable, index = keybindFrame:FindKeybindTable("macro", "macro-MyMacro", "macro-MyMacro")
```

Searches the keybind data array for a matching entry.

- For `"spell"` and `"system"` types: matches by `keybindTable.action == actionId`.
- For `"macro"` type: matches by `keybindTable.action == actionIdentifier`.

Returns the `df_keybind` table and its 1-based index, or `nil, nil`.

---

#### GetKeybindTypeAndActionFromIdentifier(actionIdentifier)

```lua
local keybindType, actionId = keybindFrame:GetKeybindTypeAndActionFromIdentifier("spell-12345")
-- Returns "spell", 12345
```

Parses an `actionidentifier` string. For `"spell"` type, converts `actionId` to a number.

---

#### IsKeybindActionMacro(actionId)

```lua
local isMacro = keybindFrame:IsKeybindActionMacro("macro-MyMacro")
-- Returns truthy (match result)
```

Returns truthy if `actionId` is a string starting with `"macro-"`.

---

### Keybind Modification

#### SaveKeybindToKeybindData(keybindTable, pressedKeybind, bKeybindJustCreated)

**Internal method.** If `bKeybindJustCreated` is `true`, inserts the keybind table into the data array. Sets `keybindTable.keybind = pressedKeybind`.

---

#### ClearKeybind(button, actionIdentifier, keybindTable)

Called when the "clear" button is clicked on a scroll line.

**Behavior:**
- For macros: sets `keybindTable.keybind = ""` (keeps the macro entry).
- For spells/system: removes the entry from the data array (if `can_modify_keybind_data`) and calls callback with `"removed"`.
- Stops editing if the edit panel is open.
- Refreshes the scroll.

---

#### DeleteMacro()

```lua
keybindFrame:DeleteMacro()
```

Deletes the macro keybind currently being edited. Only works if the edit panel is active and the keybind is a macro. Removes from data (if `can_modify_keybind_data`), calls callback with `"removed"`, stops editing, and refreshes.

---

### Edit Panel

The edit panel is shown to the right of the scroll list and allows modifying a keybind's name, icon, macro text, and load conditions.

#### GetEditPanel()

```lua
local editFrame = keybindFrame:GetEditPanel()
```

Returns the `df_editkeybindframe`.

---

#### IsEditingKeybindSettings()

```lua
local bIsEditing, actionIdentifier, keybindTable = keybindFrame:IsEditingKeybindSettings()
```

Returns whether the edit panel is active, and if so, which keybind is being edited.

---

#### StartEditingKeybindSettings(button, actionIdentifier, keybindTable)

Opens the edit panel for the given keybind.

**Behavior:**
1. If currently listening, returns without opening.
2. Enables all edit panel controls.
3. Populates name, icon, and macro text from the keybind table.
4. Disables macro editing and delete button for non-macro keybinds.
5. Stores `actionIdentifier`, `keybindTable`, and sets `bIsEditing = true`.

---

#### StopEditingKeybindSettings()

Clears and disables all edit panel controls. Sets `bIsEditing = false`.

---

#### CreateEditPanel()

**Internal method.** Creates the edit panel frame with:
- **Name** text entry — editable keybind name.
- **Icon** picker button — opens `DetailsFramework:IconPick`.
- **Macro** editor — a Lua editor (`NewSpecialLuaEditorEntry`) for macro text.
- **Save** button — applies name, icon, and macro changes. For macros with default names (`@Macro`), auto-detects spell names/icons from macro text.
- **Cancel** button — stops editing without saving.
- **Conditions** button — opens `DetailsFramework:OpenLoadConditionsPanel` for configuring load conditions.
- **Delete Macro** button — deletes the current macro keybind.
- **Conditions fail text** — shows why a keybind can't load (from `PassLoadFilters`).

---

### Edit Callbacks

#### OnKeybindNameChange(newName)

Updates `keybindTable.name`. For macros, also updates `keybindTable.action` to `"macro-newName"`. Calls callback with `"name"`.

---

#### OnKeybindMacroChange(macroText)

Updates `keybindTable.macro` (if `can_modify_keybind_data`). Calls callback with `"macro"`.

---

#### OnKeybindIconChange(texture)

Updates `keybindTable.icon`. Calls callback with `"icon"`.

---

### Scroll Management

#### GetKeybindScroll()

```lua
local scroll = keybindFrame:GetKeybindScroll()
```

Returns the `df_keybindscroll` scroll box.

---

#### CreateKeybindScroll()

**Internal method.** Creates the scroll system:

1. Creates a header with 5 columns: icon (34px), name (200px), keybind (260px), clear (40px), edit (40px).
2. Creates a "Create Macro Keybind" button at the top.
3. Creates a scroll box with `RefreshKeybindScroll` as the refresh function.
4. Creates scroll lines via `CreateKeybindScrollLine`.
5. Defines `UpdateScroll()` which:
   - Reads keybind data and parses it into lookup tables.
   - Builds scroll data sections: **Regular Actions** (target/focus/menu), **Macros**, **Spells** (from `GetAvailableSpells`).
   - Sorts spells by: has keybind → is available → alphabetical.
   - Appends "Not Available" sections for macros/spells that fail load conditions.
   - Sets the scroll data and refreshes.

---

#### RefreshKeybindScroll(scrollData, offset, totalLines)

**Internal method.** Called by the scroll box to render visible lines.

**Behavior for each line:**
- If `actionName == "@separator"`: shows as a section divider with title text.
- Otherwise: shows icon, action name, keybind text (with mouse button names localized), clear button, edit button.
- Unavailable actions are grayed out and desaturated.
- Duplicate keybinds are highlighted with an orange border on the keybind button.

---

#### CreateKeybindScrollLine(keybindScroll, index)

**Internal method.** Creates a scroll line frame with:
- Alternating background colors.
- Highlight texture on hover.
- `HeaderFunctions` mixin for alignment with the header.
- Spell icon, action name fontstring, set-keybind button (rounded corners), clear button (X icon), edit button (note icon).
- `OnEnter`: shows highlight; previews macro text in edit panel if not editing; shows load condition failure reason.
- `OnLeave`: hides highlight; clears macro preview.

---

#### SetClearButtonsEnabled(bIsEnabled) / SetEditButtonsEnabled(bIsEnabled)

Enables or disables all clear/edit buttons across all scroll lines. Buttons are only enabled if the line has a non-empty keybind.

---

### Misc

#### OnSpecChanged(button, newSpecId)

Stub for spec-change handling. Currently contains only commented-out code for refreshing the scroll.

---

## Mouse Button Mapping

Mouse clicks are converted to keybind strings:

| Button | Keybind String |
|---|---|
| LeftButton | `type1` |
| RightButton | `type2` |
| MiddleButton | `type3` |
| Button4–Button16 | `type4`–`type16` |

These are displayed as localized names (e.g. "Left Button", "Right Button") in the scroll list.

---

## Default System Actions

Three system actions are built-in:

| Action | Default Keybind | Name | Description |
|---|---|---|---|
| `target` | `type1` (left click) | Target | Target the unit. |
| `togglemenu` | `type2` (right click) | Menu | Toggle context menu. |
| `focus` | `type3` (middle click) | Focus | Set focus target. |

---

## Scroll Data Structure

Each entry in the scroll data is an array:

| Index | Content | Description |
|---|---|---|
| 1 | `actionName` | Display name, or `"@separator"` for section headers. |
| 2 | `iconTexture` | Texture path/ID for the icon column. For separators, this is the section title text. |
| 3 | `actionId` | Spell ID, system action string, or macro action identifier. |
| 4 | `keybindTable` or `false` | The `df_keybind` entry, or `false` if no keybind is set. |
| 5 | `bIsAvailable` | Whether the action is currently usable (spell is in active spec, conditions pass). |
| 6 | `sortNumber` | Sort priority (lower = higher in list). |
| 7 | `actionIdentifier` | String like `"spell-12345"`, `"system-target"`, `"macro-MacroName"`. |

---

## Example Usage

Based on `keybind.examples.lua`:

```lua
local detailsFramework = DetailsFramework

-- Keybind data table (typically from addon saved variables)
local keybindings = {}

-- Callback: called when keybinds change
local callback = function(keybindFrame, type, keybindTable, keybindPressed, removedIndex, macroText)
    if (not keybindFrame.options.can_modify_keybind_data) then
        -- Manual data management mode
        if (type == "modified") then
            keybindTable.keybind = keybindPressed
        elseif (type == "macro") then
            keybindTable.macro = macroText
        elseif (type == "removed") then
            table.remove(keybindings, removedIndex)
        end
    end
    -- When can_modify_keybind_data is true, the data is already updated
end

-- Options
local options = {
    can_modify_keybind_data = true,  -- system manages data directly

    -- Layout (all optional, values shown are defaults)
    width = 580,
    height = 500,
    edit_width = 400,
    edit_height = 0,              -- 0 = match height
    scroll_width = 580,
    scroll_height = 480,
    amount_lines = 18,
    line_height = 26,

    -- Content visibility
    show_spells = true,           -- show player spells
    show_unitcontrols = true,     -- show target/focus/menu
    show_macros = true,           -- show macro keybinds
}

-- Create the keybind frame
local keybindFrame = detailsFramework:CreateKeybindFrame(
    UIParent,       -- parent
    "MyKeybindFrame", -- name
    options,        -- options
    callback,       -- callback
    keybindings     -- keybind data array
)
keybindFrame:SetPoint("topleft", UIParent, "topleft", 10, -10)
```

### Typical Workflow

1. **Frame shown**: `OnShow` triggers `UpdateScroll()`, which reads player spells, system actions, and macro entries from keybind data and populates the scroll list.
2. **Setting a keybind**: Player clicks a keybind button in the scroll list → listener popup appears → player presses a key or clicks a mouse button → keybind is saved → callback fires with `"modified"`.
3. **Clearing a keybind**: Player clicks the clear (X) button → keybind is removed from data → callback fires with `"removed"`.
4. **Editing settings**: Player clicks the edit button → edit panel opens on the right → player can change name, icon, macro text, and load conditions → Save button applies changes → callbacks fire for each changed property.
5. **Creating a macro**: Player clicks "Create Macro Keybind" at the top → a new macro entry is created → edit panel opens for the new macro → player writes macro text and sets a keybind.
6. **Deleting a macro**: While editing a macro, player clicks "Delete This Macro" → macro entry is removed → callback fires with `"removed"`.
