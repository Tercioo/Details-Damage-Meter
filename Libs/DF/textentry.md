# DetailsFramework — Text Entry System

## Overview

`textentry.lua` implements a family of UI input components built on top of the WoW `EditBox` widget. All components are created through the `DetailsFramework` (`detailsFramework`) global object.

There are four distinct types of input component:

| Type | Constructor | Class |
|---|---|---|
| Standard text entry | `detailsFramework:CreateTextEntry(...)` | `df_textentry` |
| Search box | `detailsFramework:CreateSearchBox(...)` | `df_searchbox` |
| Auto-complete entry | `textEntry:SetAsAutoComplete(...)` | `df_textentry` (modified) |
| Lua editor | `detailsFramework:NewSpecialLuaEditorEntry(...)` | `df_luaeditor` |

---

## 1. Text Entry (`CreateTextEntry`)

### Constructor

```lua
local entry = detailsFramework:CreateTextEntry(
    parent,              -- (frame) parent frame
    textChangedCallback, -- (function) called when Enter is pressed or focus is lost
    width,               -- (number) pixel width
    height,              -- (number) pixel height
    member,              -- (string?) if set, stores the object at parent[member]
    name,                -- (string?) global name for the underlying EditBox; auto-generated if nil
    labelText,           -- (string?) text for the optional left-side label
    textentryTemplate,   -- (table?) template applied via SetTemplate
    labelTemplate        -- (table?) template applied to the label, if labelText is provided
)
-- Returns: df_textentry [, df_label if labelText was given]
```

`CreateTextEntry` is a simplified wrapper around `NewTextEntry`. The `$parent` token in `name` is automatically replaced with the parent frame's global name.

### Object Structure (`df_textentry`)

After construction the returned table has the following fields:

| Field | Type | Description |
|---|---|---|
| `editbox` | EditBox | The underlying WoW EditBox widget. |
| `widget` | EditBox | Alias for `editbox`. |
| `label` | FontString | Label FontString anchored to the left of the editbox. |
| `func` | function | Callback invoked on Enter or focus-lost. |
| `param1` | any | First fixed argument passed to `func`. |
| `param2` | any | Second fixed argument passed to `func`. |
| `next` | df_textentry? | Next entry in the Tab key navigation chain. |
| `tab_on_enter` | boolean | If `true`, pressing Enter also focuses `next` (default `false`). |
| `NoClearFocusOnEnterPressed` | boolean? | Prevent automatic `ClearFocus` after Enter is pressed. |
| `callWithNoText` | boolean? | If `true`, the callback is also fired when the text is empty. |
| `autoSelectAllText` | boolean? | If `true`, all text is highlighted when focus is gained. |
| `ignoreNextCallback` | boolean? | If `true`, the next callback invocation is suppressed once. |
| `ShouldOptimizeAutoComplete` | boolean? | Set by `SetAsAutoComplete`. |
| `AutoComplete_StopOnEnterPress` | boolean? | If `true`, auto-complete clears focus on Enter. |
| `onleave_backdrop` | table | Backdrop color used when the mouse is not over the editbox. |
| `onleave_backdrop_border_color` | table | Border color used when the mouse is not over the editbox. |
| `onenter_backdrop` | table? | Backdrop color used when the mouse enters the editbox (set by template). |
| `onenter_backdrop_border_color` | table? | Border color used when the mouse enters the editbox. |

### Underlying Widget

The editbox is created as `CreateFrame("EditBox", name, parent, "BackdropTemplate")` with:

- Default size: 232 × 20 pixels, adjusted to `width` × `height`.
- Font: `GameFontHighlightSmall`.
- Backdrop: solid dark background (`#333333, alpha 1`) with a 1 px white border.
- Text insets: `5, 3, 0, 0` (left, right, top, bottom).
- Horizontal justify: `"left"`.
- Auto-focus disabled.

The editbox exposes all standard WoW EditBox API methods transparently through the `df_textentry` metatable. Calling any WoW EditBox method directly on the `df_textentry` object is supported.

### Callback Signature

```lua
local callback = function(param1, param2, text, editboxWidget, byScript)
    -- param1, param2  Fixed parameters set at creation or via SetParameters/SetEnterFunction.
    -- text            The trimmed text string (leading/trailing whitespace removed).
    -- editboxWidget   The underlying WoW EditBox widget.
    -- byScript        The widget itself when triggered programmatically (PressEnter),
    --                 or nil when triggered by natural focus loss.
end
```

The callback is invoked:
- When Enter is pressed (and the text is non-empty, or `callWithNoText` is set).
- When the editbox loses focus naturally (click outside or Tab), provided `focuslost` was not set by a script-side ClearFocus.

When the text is empty on Enter or focus-lost, the editbox text is reset to `""` and the callback is **only** fired if `callWithNoText == true`.

---

## 2. Methods (`TextEntryMetaFunctions`)

All methods are called on the `df_textentry` object.

### Property-style Access

Several properties can be read or written directly as table fields via `__index` / `__newindex`:

**Readable properties:**

| Key | Returns |
|---|---|
| `tooltip` | Current tooltip value. |
| `shown` | `true` if the editbox is shown. |
| `width` | Width of the editbox in pixels. |
| `height` | Height of the editbox in pixels. |
| `text` | Current text of the editbox. |
| `hasfocus` | `true` if the editbox has keyboard focus. |

**Writable properties:**

| Key | Effect |
|---|---|
| `tooltip` | Sets the tooltip text. |
| `show` | Truthy → `Show()`, falsy → `Hide()`. |
| `hide` | Falsy → `Show()`, truthy → `Hide()`. |
| `width` | Sets the editbox width. |
| `height` | Sets the editbox height. |
| `text` | Sets the editbox text. |
| `multiline` | Truthy → `SetMultiLine(true)`, falsy → `SetMultiLine(false)`. |
| `align` | Sets horizontal justification (`"left"`, `"right"`, `"center"`). |
| `fontsize` / `textsize` | Sets the editbox font size. |

### Explicit Methods

#### `SetEnterFunction(func, param1, param2)`
Sets the callback function and optionally updates `param1` / `param2`. Passing `nil` for `func` replaces it with an empty no-op. Parameters are only updated when their argument is non-nil.

---

#### `SetCommitFunction(func)`
Alternative way to set the callback. Only accepts a function; does nothing if `func` is not a function.

---

#### `SetParameters(param1, param2)`
Updates the fixed parameters passed to the callback. Either argument can be omitted (nil skips that parameter).

---

#### `SetText(text)`
Sets the editbox text directly. Does **not** fire the callback.

---

#### `GetText()`
Returns the current raw text from the editbox (not trimmed).

---

#### `SelectAll()`
Highlights all text in the editbox (`HighlightText()`).

---

#### `SetAutoSelectTextOnFocus(value)`
If `value` is truthy, all text is automatically highlighted every time the editbox gains focus.

---

#### `SetLabelText(text)`
Sets the text of the `label` FontString that appears to the left of the editbox.

---

#### `SetNext(nextbox)`
Sets `nextbox` as the next entry in the Tab key navigation chain. When Tab is pressed, Enter is processed for the current entry and focus moves to `nextbox`. When `tab_on_enter` is `true`, pressing Enter also advances to `nextbox`.

---

#### `Blink()`
Briefly draws attention to the entry by setting the label text color to bright red `(1, 0.2, 0.2, 1)`.

---

#### `Enable()`
Re-enables the editbox if currently disabled. Restores the border color, backdrop color, and text color saved by the last call to `Disable()`.

---

#### `Disable()`
Disables the editbox. Saves the current border, backdrop, and text colors, then applies a gray-out appearance:
- Border color: `(0, 0, 0, 1)`
- Backdrop color: `(0.1, 0.1, 0.1, 0.834)`
- Text color: `(0.5, 0.5, 0.5, 0.5)`

---

#### `IgnoreNextCallback()`
Marks a flag so the very next callback invocation (from Enter press or focus loss) is silently skipped. The flag is cleared on the next tick via `RunNextTick`.

---

#### `PressEnter(byScript)`
Programmatically triggers the `OnEnterPressed` handler. `byScript` is passed as the fifth argument to the callback (the same slot normally used by the editbox widget reference).

---

#### `SetHook(hookName, func)`
Registers an additional handler for one of the built-in script events. Multiple hooks per event are supported; they run in registration order. If a hook returns a truthy value, subsequent hooks and the default behavior for that event are suppressed.

Valid hook names:
`"OnEnter"`, `"OnLeave"`, `"OnHide"`, `"OnShow"`, `"OnEnterPressed"`, `"OnEscapePressed"`, `"OnSpacePressed"`, `"OnEditFocusLost"`, `"OnEditFocusGained"`, `"OnChar"`, `"OnTextChanged"`, `"OnTabPressed"`.

---

#### `SetAsSearchBox()`
Converts this text entry into a search box in-place. Can only be applied once. See §3 for the full description.

---

#### `SetAsAutoComplete(poolName, poolTable, shouldOptimize)`
Enables auto-complete behavior on this entry. See §4 for the full description.

---

#### `SetTemplate(template)`
Applies a style table to the text entry. Recognised keys in `template`:

| Key | Effect |
|---|---|
| `multiline` | Truthy → enables multi-line mode. |
| `width` | Sets editbox width. |
| `height` | Sets editbox height. |
| `backdrop` | Sets the editbox backdrop table. |
| `backdropcolor` | Sets backdrop RGBA color; stored in `onleave_backdrop`. |
| `backdropbordercolor` | Sets border color; stored in `onleave_backdrop_border_color`. |
| `onentercolor` | Sets backdrop color on mouse-enter; hooks `OnEnter`. |
| `onleavecolor` | Sets backdrop color on mouse-leave; hooks `OnLeave`. |
| `onenterbordercolor` | Sets border color on mouse-enter; hooks `OnEnter` if not already hooked. |
| `onleavebordercolor` | Sets border color on mouse-leave; hooks `OnLeave` if not already hooked. |

---

### Built-in Script Behavior

| Script | Default Behavior |
|---|---|
| `OnEnter` | Shows tooltip; tints border white `(1,1,1,0.6)` or the color from `onenter_backdrop_border_color`. |
| `OnLeave` | Hides tooltip; restores saved border color. |
| `OnEnterPressed` | Trims text; fires callback; calls `ClearFocus` (unless `NoClearFocusOnEnterPressed`). If `tab_on_enter` and `next` is set, also focuses `next`. |
| `OnEscapePressed` | Calls `ClearFocus`. |
| `OnEditFocusLost` | Fires callback on natural focus loss (skipped when focus was cleared by script). Resets label color to `(0.8,0.8,0.8,1)`. |
| `OnEditFocusGained` | Sets label color to white. Selects all text if `autoSelectAllText` is set. |
| `OnTabPressed` | If `next` is set: processes Enter for current entry, then focuses `next`. |
| `OnChar` | Hookable; no default logic beyond running hooks. |
| `OnTextChanged` | Hookable; no default logic beyond running hooks. |
| `OnSpacePressed` | Hookable; no default logic beyond running hooks. |

---

## 3. Search Box (`CreateSearchBox`)

### Constructor

```lua
local searchBox = detailsFramework:CreateSearchBox(
    parent,   -- (frame) parent frame
    callback  -- (function) called when text changes or Enter is pressed
)
-- Returns: df_searchbox
```

The callback is called differently depending on the trigger:
- **Text change** (`OnTextChanged` hook): `callback()` — no arguments.
- **Enter pressed**: wrapped internally as `callback(searchBox)`, where the first argument is the searchBox itself.

### Additional Fields

| Field | Type | Description |
|---|---|---|
| `ClearSearchButton` | Button | The × button on the right; shown at alpha 0.3 when visible. |
| `MagnifyingGlassTexture` | Texture | Magnifying glass icon on the left (alpha 0.5). |
| `SearchFontString` | FontString | "search" placeholder text (alpha 0.3). |
| `BottomLineTexture` | Texture | Decorative horizontal line below the editbox using atlas `"common-slider-track"`. |

### Differences from Standard Text Entry

- **No backdrop**: the editbox backdrop is set to `nil`, giving a borderless appearance.
- **Bottom line decoration**: a horizontal texture is drawn under the editbox.
- **Magnifying glass**: atlas icon `"common-search-magnifyingglass"` on the left.
- **Placeholder text**: the word "search" fades in when the box is empty and unfocused; it hides as soon as text is typed or focus is gained.
- **Clear button**: appears when the editbox has focus (or always, depending on text). Clicking it sets text to `""`, calls `PressEnter()`, and clears focus.
- **Text insets**: `25, 5, 0, 0` to leave room for the magnifying glass and clear button.
- **Font size**: 12 pt.
- **Width / Height**: default 220 × 26 pixels.

### Visibility Logic

| State | `SearchFontString` | `ClearSearchButton` |
|---|---|---|
| Empty + unfocused | Shown | Hidden |
| Focused | Hidden | Shown |
| Text typed (any focus state) | Hidden | (unchanged — shown if focused) |

---

## 4. Auto-complete (`SetAsAutoComplete`)

### Enabling Auto-complete

```lua
textEntry:SetAsAutoComplete(
    poolName,       -- (string) key used to access the word list on the textEntry object
    poolTable,      -- (table?) initial array of completion candidates (optional)
    shouldOptimize  -- (boolean?) enable first-character index for large lists
)
```

After calling this method the `textEntry` object has:

| New Field | Description |
|---|---|
| `lastword` | The word fragment being built (string, initially `""`). |
| `characters_count` | Character count from the last `OnTextChanged` cycle. |
| `poolName` | The string key provided. |
| `GetLastWord()` | Re-reads `lastword` from the editbox cursor position backwards. |
| `NoClearFocusOnEnterPressed` | Set to `true`; prevents the standard clear-focus-on-Enter behavior. |
| `ShouldOptimizeAutoComplete` | The value of `shouldOptimize`. |
| `[poolName]` | The word list table (set when `poolTable` is provided). |

The word list can be updated at any time by assigning a new table:
```lua
textEntry[textEntry.poolName] = newWordListTable
```

### Word List Format

The word list is a plain array of strings:
```lua
local words = { "function", "local", "return", "if", "then", "end" }
textEntry:SetAsAutoComplete("myWords", words)
```

### Optimization Mode

When `shouldOptimize = true`, the first time the list is consulted it is partitioned into a sub-table per first character:

```lua
-- Internal structure after optimization:
wordList.Optimized = {
    ["f"] = { "function", "for" },
    ["l"] = { "local" },
    ...
}
```

Recommended for lists larger than a few hundred entries.

### Completion Behavior

1. Every character typed appends to `lastword` if it is a letter (`%a`). A space clears `lastword` unless `lastword` is already empty.
2. Once `lastword` reaches 2 or more characters, the word list is searched for the **first** entry whose lowercase form starts with `lastword` (case-insensitive prefix match via `^` pattern).
3. If a match is found:
   - The remainder of the matched word is inserted after the cursor.
   - The inserted remainder is highlighted (selected).
   - `end_selection` is set to the cursor position after the inserted text.
4. While a suggestion is highlighted:
   - **Enter**: commits the suggestion (cursor moves to end of selection, highlight cleared, `lastword` reset).
   - **Escape**: cancels the suggestion (`end_selection` cleared).
   - **Continue typing**: the selection is discarded and a new search begins with the updated `lastword`.
5. On focus gain, `GetLastWord()` is called to rebuild `lastword` from existing text.

### Compatibility

`SetAsAutoComplete` supports two calling contexts:

- **`df_textentry` object** (standard usage): hooks are registered via `SetHook` and `HookScript`.
- **Raw WoW EditBox** (legacy path): hooks are registered directly via `HookScript` / `SetScript`. In this case the editbox's `editbox` field is set to itself for framework compatibility.

---

## 5. Lua Editor Entry (`NewSpecialLuaEditorEntry`)

### Constructor

```lua
local editor = detailsFramework:NewSpecialLuaEditorEntry(
    parent,          -- (frame) parent frame
    width,           -- (number) pixel width
    height,          -- (number) pixel height
    member,          -- (string?) stores the object at parent[member]
    name,            -- (string?) global name prefix for child frames
    nointent,        -- (boolean?) if true, disables IndentationLib (no syntax coloring)
    showLineNumbers, -- (boolean?) if true, shows a left-side line number column
    bNoName          -- (boolean?) if true, all frames are anonymous (no global names)
)
-- Returns: df_luaeditor
```

### Object Structure (`df_luaeditor`)

| Field | Type | Description |
|---|---|---|
| `editbox` | EditBox | The main multi-line editing EditBox (child of `scroll`). |
| `scroll` | ScrollFrame | ScrollFrame wrapping `editbox`. |
| `scrollnumberlines` | ScrollFrame? | ScrollFrame for the line number column (only when `showLineNumbers = true`). |
| `editboxlines` | EditBox? | Disabled EditBox that renders line numbers (only when `showLineNumbers = true`). |

### Methods

| Method | Signature | Description |
|---|---|---|
| `GetText` | `(): string` | Returns text from `editbox`. |
| `SetText` | `(text: string)` | Sets text in `editbox`. |
| `SetFocus` | `()` | Focuses `editbox`. |
| `ClearFocus` | `()` | Clears focus from `editbox`. |
| `SetTextSize` | `(size: number)` | Sets font size on both `editbox` and `editboxlines`. |
| `HighlightText` | `()` | Highlights all text in `editbox`. |
| `Enable` | `()` | From `TextEntryMetaFunctions`; restores saved colors. |
| `Disable` | `()` | From `TextEntryMetaFunctions`; grays out the border frame. |
| `SetTemplate` | `(template: table)` | From `TextEntryMetaFunctions`; applies a style table to the border frame. |
| `SetAsAutoComplete` | `(poolName, poolTable, shouldOptimize)` | From `TextEntryMetaFunctions`; enables auto-complete. |

### Physical Layout

The `df_luaeditor` is a `Frame` (the "border frame") that contains:

```
borderframe (Frame)
├── scrollframe (ScrollFrame)          ← main editing area
│   └── editbox (EditBox, multiline)
└── scrollframeNumberLines (ScrollFrame)  ← only when showLineNumbers=true
    └── editboxlines (EditBox, disabled)
```

**Without `showLineNumbers`**: both scroll frames are positioned with 10 px insets on all sides; the number lines scroll frame is hidden.

**With `showLineNumbers`**: the code scroll frame is offset 30 px from the left edge; the line number column occupies the first 30 px. The number column is pre-populated with lines 1–1000. When the code content changes, a debounced timer (0.25 s) recalculates line wrapping and re-renders the number column.

### Editbox Limits

- `SetMaxBytes(1024000)` — approximately 1 MB.
- `SetMaxLetters(128000)` — 128 000 characters.

### Indentation and Syntax Highlighting

When `nointent` is `false` (the default), `IndentationLib.enable(editbox, nil, 4)` is called, which provides:
- Automatic indentation with 4-space tab stops.
- Lua syntax color highlighting.

Pass `nointent = true` to disable this, resulting in a plain multi-line EditBox.

### Backdrop

The border frame uses a tooltip-style backdrop:
- Background: `Interface\Tooltips\UI-Tooltip-Background`, dark blue `(0.09, 0.09, 0.19, 1)`.
- Border: `Interface\Tooltips\UI-Tooltip-Border`, 16 px edge, white `(1, 1, 1, 0.7)`.

---

## 6. Differences Between Object Types

| Feature | `df_textentry` | `df_searchbox` | Auto-complete entry | `df_luaeditor` |
|---|---|---|---|---|
| Base type | EditBox (single-line) | EditBox (single-line) | EditBox | Multi-line EditBox in ScrollFrame |
| Multi-line | Optional (`multiline` prop) | No | Optional | Yes (always) |
| Backdrop | Dark + border | None | Dark + border | Dark blue tooltip style |
| Label | Left-side FontString | No | Left-side FontString | No |
| Search UI | No | Yes | No | No |
| Auto-complete | Via `SetAsAutoComplete` | Via `SetAsAutoComplete` | Built-in | Via `SetAsAutoComplete` |
| Syntax highlighting | No | No | No | Yes (via `IndentationLib`, optional) |
| Line numbers | No | No | No | Optional |
| Clear-focus on Enter | Yes (default) | Yes | No (`NoClearFocusOnEnterPressed`) | No |
| Callback model | `func(p1, p2, text, widget, byScript)` | `callback(self)` or `callback()` | N/A (Enter commits suggestion) | N/A |
| Max text size | Unlimited | Unlimited | Unlimited | 128 000 letters / 1 MB |

---

## 7. Practical Usage Patterns

### Basic text entry with callback

```lua
local function onCommit(param1, param2, text, widget, byScript)
    print("Entered:", text, "param1:", param1)
end

local entry = detailsFramework:CreateTextEntry(myFrame, onCommit, 200, 22)
entry:SetParameters("myParam", nil)
entry:SetText("default text")
```

### Reacting to every keystroke with a hook

```lua
entry:SetHook("OnTextChanged", function(widget, byUser, capsule)
    -- widget    = the EditBox widget
    -- byUser    = true if the user typed; false if set by code
    -- capsule   = the df_textentry object
    print("Current text:", capsule:GetText())
end)
```

### Tab key navigation chain

```lua
local entryA = detailsFramework:CreateTextEntry(parent, cb, 200, 22)
local entryB = detailsFramework:CreateTextEntry(parent, cb, 200, 22)
entryA:SetNext(entryB)  -- Tab from A → focuses B
```

### Search box

```lua
local function onSearch(searchBox)
    -- called with (self) when Enter is pressed
    -- called with () on every keystroke
    local text = searchBox and searchBox:GetText() or mySearchBox:GetText()
    FilterList(text)
end

local mySearchBox = detailsFramework:CreateSearchBox(myFrame, onSearch)
mySearchBox.widget:SetPoint("topleft", myFrame, "topleft", 10, -10)
```

### Auto-complete on a standard text entry

```lua
local words = { "Arcane", "ArcaneBolt", "ArcaneBlast", "Fire", "Fireball" }

local entry = detailsFramework:CreateTextEntry(parent, callback, 300, 22)
entry:SetAsAutoComplete("spellList", words, true)  -- optimized = true

-- Update the word list later:
entry.spellList = newWordTable
```

### Lua editor

```lua
local editor = detailsFramework:NewSpecialLuaEditorEntry(
    parent,  -- parent frame
    500,     -- width
    300,     -- height
    "luaEditor",   -- parent.luaEditor = editor
    nil,           -- auto-name
    false,         -- enable IndentationLib
    true,          -- show line numbers
    false          -- use global name
)

editor:SetText([[
local x = 1
return x + 2
]])

local code = editor:GetText()
editor:SetTextSize(13)
```

### Applying a visual template

```lua
entry:SetTemplate({
    backdropcolor       = {0.05, 0.05, 0.05, 1},
    backdropbordercolor = {0.5, 0.5, 0.5, 1},
    onenterbordercolor  = {1, 0.8, 0, 1},   -- golden border on hover
    onleavebordercolor  = {0.5, 0.5, 0.5, 1},
})
```

### Suppressing the next callback (e.g. programmatic text update)

```lua
entry:IgnoreNextCallback()
entry:SetText("updated by code")
entry:PressEnter(true)   -- fires OnEnterPressed, but callback is skipped once
```
