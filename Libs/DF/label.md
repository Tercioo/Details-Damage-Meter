# Label System Documentation

## Overview

The label system wraps a WoW `FontString` inside a `df_label` object that provides property-style access (dot syntax for reads and writes), template support, localization integration, and native fontstring method passthrough. There is also a variant, `df_errorlabel`, which adds fade and shake animations for displaying transient error messages.

The system has three components:

| Component | Purpose |
|---|---|
| `LabelMetaFunctions` | Metatable controlling property access, setters/getters, methods, and native fontstring passthrough. |
| `DetailsFramework:CreateLabel()` | Convenience entry point. Reorders parameters and delegates to `NewLabel`. |
| `DetailsFramework:CreateErrorLabel()` | Creates a label pre-configured for animated error messages. |

A label object is a plain Lua table — not a frame. Its `.label` and `.widget` fields both point to the underlying `FontString`.

---

## Creating a Label

### CreateLabel

```lua
local label = DetailsFramework:CreateLabel(parent, text, size, color, font, member, name, layer)
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | yes | The frame that owns the fontstring. |
| 2 | `text` | `string` or `table` | yes | Display text, or a locale table (`locTable`). |
| 3 | `size` | `number`, `string`, `table`, or `nil` | no | Font size (number), template name (string), or template table. |
| 4 | `color` | `any` | no | Text color. Accepts any format supported by `ParseColors` (named color string, `{r,g,b,a}` table, etc.). |
| 5 | `font` | `string` or `nil` | no | Font object name (e.g. `"GameFontNormal"`). Defaults to `"GameFontNormal"`. |
| 6 | `member` | `string` or `nil` | no | If provided, stores the label object as `parent[member]`. |
| 7 | `name` | `string` or `nil` | no | Global name for the fontstring. Supports `$parent` substitution. Auto-generated if nil. |
| 8 | `layer` | `drawlayer` or `nil` | no | Draw layer. Defaults to `"overlay"`. |

Returns a `df_label` or `nil` on error.

`CreateLabel` is a convenience wrapper that calls `NewLabel` internally:

```lua
function detailsFramework:CreateLabel(parent, text, size, color, font, member, name, layer)
    return detailsFramework:NewLabel(parent, parent, name, member, text, font, size, color, layer)
end
```

### NewLabel

```lua
local label = DetailsFramework:NewLabel(parent, container, name, member, text, font, size, color, layer)
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | yes | The frame that owns the fontstring. |
| 2 | `container` | `frame` or `nil` | no | Stored as `labelObject.container`. Defaults to `parent` if nil. |
| 3 | `name` | `string` or `nil` | no | Global fontstring name. Supports `$parent`. Auto-generated if nil. |
| 4 | `member` | `string` or `nil` | no | If provided, stores label as `parent[member]`. |
| 5 | `text` | `string` or `table` | yes | Display text or locale table. |
| 6 | `font` | `string` or `nil` | no | Font object name. Defaults to `"GameFontNormal"`. |
| 7 | `size` | `number`, `string`, `table`, or `nil` | no | Font size, template name, or template table. |
| 8 | `color` | `any` | no | Text color (via `ParseColors`). |
| 9 | `layer` | `drawlayer` or `nil` | no | Draw layer. Defaults to `"overlay"`. |

Note the different parameter order between `CreateLabel` and `NewLabel`. `CreateLabel` uses `(parent, text, size, color, font, member, name, layer)` while `NewLabel` uses `(parent, container, name, member, text, font, size, color, layer)`.

### Initialization Sequence (NewLabel)

1. Creates a plain table `{type = "label", dframework = true}`.
2. If `member` is provided, stores the object as `parent[member]`.
3. Unwraps DF wrapper objects: if `parent.dframework` or `container.dframework`, replaces with `.widget`.
4. Creates a `FontString` via `parent:CreateFontString(name, layer, font)`.
5. Sets `.label` and `.widget` to the fontstring. Sets `.label.MyObject` back-reference.
6. On first label creation only: iterates all native fontstring methods and creates passthrough wrappers in `LabelMetaFunctions` for any method not already defined.
7. Handles `text`: if it's a table and a valid `locTable`, registers it with the language system. Otherwise calls `SetText`.
8. Sets horizontal justification to `"left"`.
9. Applies `color` via `ParseColors` if provided.
10. Applies `size` via `SetFontSize` if it's a number.
11. Initializes `HookList = {}`.
12. Sets the metatable to `LabelMetaFunctions`.
13. If `size` is a table or string, applies it as a template via `SetTemplate`.
14. Returns the label object.

### The `size` Parameter Overloading

The third parameter of `CreateLabel` (seventh of `NewLabel`) accepts three types:

| Type | Behavior |
|---|---|
| `number` | Sets font size directly. |
| `string` | Treated as a template name, parsed and applied via `SetTemplate`. |
| `table` | Treated as a template table, applied via `SetTemplate`. |

---

## Creating an Error Label

```lua
local errorLabel = DetailsFramework:CreateErrorLabel(parent, text, size, color, layer, name)
```

| # | Name | Type | Required | Default |
|---|---|---|---|---|
| 1 | `parent` | `frame` | yes | — |
| 2 | `text` | `string` or `nil` | no | `""` |
| 3 | `size` | `number` or `nil` | no | `13` |
| 4 | `color` | `any` | no | `"orangered"` |
| 5 | `layer` | `drawlayer` or `nil` | no | `"overlay"` |
| 6 | `name` | `string` or `nil` | no | auto-generated |

Returns a `df_errorlabel` (extends `df_label`).

### Differences from CreateLabel

| Aspect | `CreateLabel` | `CreateErrorLabel` |
|---|---|---|
| Default color | none | `"orangered"` |
| Default size | none | `13` |
| Horizontal align | `"left"` | `"center"` |
| Initial alpha | `1` (visible) | `0` (invisible) |
| Animations | none | Fade-in (0.1s), fade-out (2s), shake (0.4s, amplitude 6, frequency 20) |
| Extra method | — | `ShowErrorMsg(text)` |
| Auto-hide | no | yes, after 4 seconds |

### ShowErrorMsg(text)

```lua
errorLabel:ShowErrorMsg("Something went wrong!")
```

1. If a hide timer is already active, returns immediately (prevents overlapping).
2. Plays the fade-in animation (0.1s, alpha 0→1).
3. Sets the display text if `text` is provided.
4. Plays the shake animation.
5. After 4 seconds, plays the fade-out animation (2s, alpha 1→0) and clears the timer.

---

## Metatable Property System

`LabelMetaFunctions` uses `__index`, `__newindex`, and `__call` metamethods to provide property-style access on label objects.

### __call

```lua
label("Hello World")
```

Equivalent to `label.label:SetText("Hello World")`. Allows calling the label object directly to set text.

### __index (Reading Properties)

```lua
local value = label.text
```

Lookup order:

1. Check `LabelMetaFunctions.GetMembers[key]` — if a getter function exists, call it and return the result.
2. Check `rawget(object, key)` — return raw table fields (e.g. `.label`, `.widget`, `.container`).
3. Fall through to `LabelMetaFunctions[key]` — return methods or constants.

### __newindex (Writing Properties)

```lua
label.text = "Hello"
```

1. Check `LabelMetaFunctions.SetMembers[key]` — if a setter function exists, call it with the value.
2. Otherwise, `rawset(object, key, value)` — store as a raw table field.

---

## Readable Properties (GetMembers)

| Property | Aliases | Returns | Source |
|---|---|---|---|
| `text` | — | `string` | `fontstring:GetText()` |
| `width` | — | `number` | `fontstring:GetStringWidth()` |
| `height` | — | `number` | `fontstring:GetStringHeight()` |
| `fontcolor` | `textcolor` | `r, g, b, a` | `fontstring:GetTextColor()` |
| `fontface` | `textfont` | `string` | `fontstring:GetFont()` (first return value) |
| `fontsize` | `textsize` | `number` | `fontstring:GetFont()` (second return value) |

Inherited getters from `LayeredRegionMetaFunctionsGet` and `DefaultMetaFunctionsGet` are also available (mixed in at load time).

---

## Writable Properties (SetMembers)

| Property | Aliases | Accepts | Effect |
|---|---|---|---|
| `text` | — | `string` or locale `table` | Sets text via `SetText`, or registers a locale table for automatic localization. |
| `width` | — | `number` | `fontstring:SetWidth(value)` |
| `height` | — | `number` | `fontstring:SetHeight(value)` |
| `fontcolor` | `textcolor`, `color` | any color format | `fontstring:SetTextColor(r, g, b, a)` via `ParseColors`. |
| `fontface` | `textfont` | `string` | `SetFontFace(fontstring, value)` |
| `fontsize` | `textsize` | `number` | `SetFontSize(fontstring, value)` |
| `align` | — | `string` | `fontstring:SetJustifyH(value)`. Accepts shorthands: `"<"` = `"left"`, `">"` = `"right"`, `"\|"` = `"center"`. |
| `valign` | — | `string` | `fontstring:SetJustifyV(value)`. Accepts shorthands: `"^"` = `"top"`, `"_"` = `"bottom"`, `"\|"` = `"middle"`. |
| `shadow` | `outline` | `fontflags` | `SetFontOutline(fontstring, value)` |
| `rotation` | — | `number` (degrees) | Creates a rotation animation on the fontstring. Uses a paused `Animation` with infinite `EndDelay` to hold the rotation. Only applies if the value is a number. |

Inherited setters from `LayeredRegionMetaFunctionsSet` and `DefaultMetaFunctionsSet` are also available.

---

## Methods

### SetText(text)

```lua
label:SetText("Hello")
label:SetText(locTable)
```

Sets the label text. If `text` is a locale table (validated by `Language.IsLocTable`), registers the widget for automatic localization via `Language.RegisterObjectWithLocTable`. Otherwise calls `fontstring:SetText(text)`.

---

### SetTextTruncated(text, maxWidth)

```lua
label:SetTextTruncated("A very long string", 100)
```

Sets the text, then truncates it with an ellipsis if its rendered width exceeds `maxWidth`. Uses `DetailsFramework:TruncateText`.

| Parameter | Type | Description |
|---|---|---|
| `text` | `string` | The full text to display. |
| `maxWidth` | `number` | Maximum pixel width before truncation. |

---

### SetTextColor(red, green, blue, alpha)

```lua
label:SetTextColor(1, 0, 0, 1)
label:SetTextColor("red")
label:SetTextColor({1, 0, 0, 1})
```

Sets the fontstring text color. All arguments are passed through `ParseColors`, so named colors, tables, and raw RGBA values are all accepted.

---

### SetTemplate(template)

```lua
label:SetTemplate("MY_TEMPLATE")
label:SetTemplate({ size = 14, color = "white", font = "MyFont" })
```

Applies a visual template to the label. If `template` is a string, it is parsed via `ParseTemplate`. The template table may contain:

| Field | Effect |
|---|---|
| `size` | Sets font size via `SetFontSize`. |
| `color` | Sets text color via `ParseColors` + `SetTextColor`. |
| `font` | Fetches the font path from `LibSharedMedia-3.0` and applies via `SetFontFace`. |

---

### Native FontString Methods (Passthrough)

On the first label creation, all methods from the native `FontString` metatable are scanned. Any method not already defined in `LabelMetaFunctions` is added as a passthrough wrapper. This means all standard WoW `FontString` API methods (e.g. `GetFont`, `SetFont`, `SetJustifyH`, `GetStringWidth`, `SetAlpha`, `GetName`, `SetPoint`, `Show`, `Hide`, etc.) are available directly on the label object.

```lua
label:SetJustifyH("center")
label:SetAlpha(0.5)
label:GetName()
```

Additionally, `SetPointMixin` and `ScriptHookMixin` are mixed into `LabelMetaFunctions`, providing `SetPoint` and script hook functionality.

---

## Internal Object Structure

A `df_label` object is a table with these raw fields:

| Field | Type | Description |
|---|---|---|
| `type` | `string` | Always `"label"`. |
| `dframework` | `boolean` | Always `true`. Marks this as a DF wrapper object. |
| `label` | `FontString` | The underlying WoW fontstring. |
| `widget` | `FontString` | Same reference as `label`. |
| `container` | `frame` | The container frame (from `NewLabel`'s second parameter). |
| `HookList` | `table` | Script hook storage (from `ScriptHookMixin`). |

The fontstring has a `.MyObject` back-reference to the label object.

---

## Version Management

`LabelMetaFunctions` is stored in a global variable keyed by `detailsFramework.GlobalWidgetControlNames["label"]`. On load:

1. If the global already exists and its `dversion` is older than the current `detailsFramework.dversion`, all new functions are copied over the old metatable (in-place upgrade).
2. If the global does not exist, the new metatable is assigned.

This allows multiple versions of the framework to coexist, with the newest version's methods winning.

---

## Example Usage

### Basic Label

```lua
local label = DetailsFramework:CreateLabel(myFrame, "Hello World", 14, "white")
label:SetPoint("center", myFrame, "center", 0, 0)
```

### Property Access via Dot Syntax

```lua
-- Writing properties
label.text = "Updated Text"
label.fontsize = 16
label.textcolor = "yellow"
label.align = "center"
label.rotation = 45

-- Reading properties
print(label.text)       -- "Updated Text"
print(label.fontsize)   -- 16
print(label.width)      -- rendered text width in pixels
print(label.height)     -- rendered text height in pixels

-- Callable shorthand
label("Quick text set")
```

### Localization

```lua
local locTable = DetailsFramework.Language.CreateLocTable("Hello")
label.text = locTable  -- registers for automatic localization updates
```

### Using a Template

```lua
label:SetTemplate({
    size = 12,
    color = {1, 0.8, 0, 1},
    font = "Friz Quadrata TT",
})
```

### Truncated Text

```lua
label:SetTextTruncated("This is a very long piece of text that should be clipped", 120)
```

### Error Label

```lua
local errorLabel = DetailsFramework:CreateErrorLabel(myFrame)
errorLabel:SetPoint("bottom", myFrame, "bottom", 0, 10)

-- Later, when an error occurs:
errorLabel:ShowErrorMsg("Invalid input!")
-- Label fades in, shakes, displays for 4 seconds, then fades out.
```

### Member Shortcut

```lua
-- Creates the label and stores it as myFrame.titleLabel
DetailsFramework:CreateLabel(myFrame, "Title", 16, "gold", nil, "titleLabel")
-- Now accessible as:
myFrame.titleLabel.text = "New Title"
```
