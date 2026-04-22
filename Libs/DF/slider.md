# Slider and Switch System

## Overview

This file implements three distinct UI control types that share a common metatable and template system:

| Type | Constructor | Purpose |
|---|---|---|
| **Slider** | `CreateSlider` | Horizontal slider for numeric range selection. |
| **Switch** | `CreateSwitch` | Toggle button with ON/OFF states. |
| **Checkbox** | `CreateSwitch` + `SetAsCheckBox()` | Switch restyled as a checkmark checkbox. |
| **Adjustment Slider** | `CreateAdjustmentSlider` | Three-button joystick control for mouse-drag value adjustment. |

All slider/switch objects use the **wrapper↔widget** pattern: a Lua table (`SliderObject`) wraps a native WoW frame (`SliderObject.slider` or `SliderObject.widget`). The metatable `DFSliderMetaFunctions` provides `__index`, `__newindex`, and `__call` metamethods for property access and value getting/setting.

### Callback Model

- **Slider:** When the value changes, `self.OnValueChanged(self, FixedValue, value)` is called. Hooks registered via `SetHook("OnValueChanged", func)` are also called.
- **Switch:** When toggled, `self.OnSwitch(self, FixedValue, value)` is called. Hooks registered via `SetHook("OnSwitch", func)` are also called.

---

## Slider — `CreateSlider`

### Signature

```lua
DF:CreateSlider(parent, width, height, minValue, maxValue, step, defaultValue, isDecimal, member, name, label, sliderTemplate, labelTemplate)
```

### Parameters

| # | Name | Type | Default | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | — | Parent frame. |
| 2 | `width` | `number?` | `150` | Slider width. |
| 3 | `height` | `number?` | `20` | Slider height. |
| 4 | `minValue` | `number?` | `1` | Minimum value. |
| 5 | `maxValue` | `number?` | `2` | Maximum value. |
| 6 | `step` | `number?` | `1` | Value step increment. Ignored if `isDecimal` is true (uses 0.01). |
| 7 | `defaultValue` | `number?` | `minValue` | Initial value. |
| 8 | `isDecimal` | `boolean?` | `false` | If true, displays values with 2 decimal places and uses 0.01 step. |
| 9 | `member` | `string?` | — | If set, `parent[member] = sliderObject`. |
| 10 | `name` | `string?` | auto | Global frame name. Auto-generated if nil. |
| 11 | `label` | `string?` | — | If set, a `df_label` is created and the slider anchors to its right. |
| 12 | `sliderTemplate` | `string\|table?` | — | Visual template applied via `SetTemplate()`. |
| 13 | `labelTemplate` | `string\|table?` | — | Template for the label. |

### Returns

`df_slider, df_label?` — the slider object, and optionally a label if `label` was provided.

### Construction Details

1. Creates a `SliderObject` table with `type = "slider"`, `dframework = true`.
2. Creates a native `Slider` frame (`BackdropTemplate`) as `SliderObject.slider` / `SliderObject.widget`.
3. Sets `MyObject` back-reference on the native frame.
4. Sets min/max values, step, orientation (horizontal), and default value.
5. Creates a thumb texture, left/right/middle artwork textures.
6. Creates an `amt` fontstring centered on the thumb to display the current value.
7. Copies all native slider API functions into `DFSliderMetaFunctions` (once, on first slider creation).
8. Sets up scripts: `OnEnter`, `OnLeave`, `OnHide`, `OnShow`, `OnValueChanged`, `OnMouseDown`, `OnMouseUp`.
9. Sets the metatable to `DFSliderMetaFunctions`.
10. Sets a default tooltip: "right click to type the value".

### Key Fields on `df_slider`

| Field | Type | Description |
|---|---|---|
| `slider` / `widget` | `Slider` | The native WoW slider frame. |
| `thumb` | `Texture` | The draggable thumb texture. |
| `amt` | `FontString` | Displays current value on the thumb. |
| `slider_left` | `Texture` | Left cap artwork. |
| `slider_right` | `Texture` | Right cap artwork. |
| `slider_middle` | `Texture` | Middle track artwork. |
| `useDecimals` | `boolean` | Whether values display with decimals. |
| `ivalue` | `number` | Last set value (internal tracking). |
| `FixedValue` | `any` | Extra parameter passed to callbacks. |
| `OnValueChanged` | `function?` | Callback: `function(self, fixedValue, value)`. |
| `previous_value` | `table` | Last 3 values (ring buffer for TypeValue). |
| `lockdown` | `boolean` | If true, slider is disabled. |
| `fine_tuning` | `number?` | If set, +/- buttons increment by this instead of step. |
| `label` | `df_label?` | The associated label, if created. |
| `NoCallback` | `boolean` | Transient flag to suppress callback on next value change. |
| `IsValueChanging` | `boolean?` | True while mouse is held down on the slider. |

---

## DFSliderMetaFunctions — Slider Methods

### Metamethods

#### `__call(value)`

- **No argument:** Returns the current value. For switches, returns `true` (value=2) or `false` (value=1).
- **With argument:** Sets the value. For switches, accepts `boolean` or numeric (1/2).

#### `__index(key)`

Checks `GetMembers[key]` first (computed properties), then `rawget`, then the metatable itself.

#### `__newindex(key, value)`

Checks `SetMembers[key]` first (property setters), then falls through to `rawset`.

### GetMembers (Read Properties)

| Key | Returns |
|---|---|
| `tooltip` | Current tooltip text. |
| `shown` | Whether the slider is shown. |
| `width` | Width of the native slider. |
| `height` | Height of the native slider. |
| `locked` | Whether `lockdown` is set. |
| `fractional` | Whether `useDecimals` is set. |
| `value` | Current value (via `__call`). |

### SetMembers (Write Properties)

| Key | Effect |
|---|---|
| `tooltip` | Sets tooltip text. |
| `show` | If truthy, shows; if falsy, hides. |
| `hide` | Inverse of `show`. |
| `width` | Sets native slider width. |
| `height` | Sets native slider height. |
| `locked` | If true, calls `Disable()`; if false, calls `Enable()`. |
| `backdrop` | Sets backdrop on native slider. |
| `fractional` | Sets `useDecimals`. |
| `value` | Sets value via `__call`. |

### Methods

#### `SetFixedParameter(value)` / `GetFixedParameter()`

Sets/gets the `FixedValue` field. This value is passed as the second argument to `OnValueChanged` and `OnSwitch` callbacks.

#### `SetValue(value)`

Sets the slider value (delegates to `__call`). Triggers the `OnValueChanged` callback.

#### `SetValueNoCallback(value)`

Sets the value without triggering the callback. Sets `NoCallback = true` before calling `slider:SetValue`.

#### `SetValueChangedFunction(func)`

Replaces the `OnValueChanged` callback function.

#### `SetThumbSize(width, height)`

Sets the thumb texture size. Either parameter can be nil to keep the current dimension.

#### `ClearFocus()`

If the slider has an active TypeValue editbox, clears focus, hides it, and restores the original value.

#### `IsEnabled()` / `Enable()` / `Disable()`

- `IsEnabled()` returns `not lockdown`.
- `Enable()` enables the native slider, hides the lock icon, shows the value text, sets alpha to 1.
- `Disable()` clears focus, disables the native slider, hides the value text, shows a lock icon, sets alpha to 0.4.

#### `TypeValue()`

Opens an inline editbox over the slider for typing a precise value. Triggered by right-clicking the slider.

- **Enter** confirms the typed value.
- **Escape** reverts to the previous value.
- Text changes update the slider value in real-time.

#### `SetTemplate(template)`

Applies a visual template. The template table can contain:

| Template Key | Effect |
|---|---|
| `width`, `height` | Resize the widget. |
| `backdrop` | Set backdrop. |
| `backdropcolor` | Set backdrop color. |
| `backdropbordercolor` | Set border color (also sets `onleave_backdrop_border_color`). |
| `onenterbordercolor` | Border color on mouse enter. |
| `onleavebordercolor` | Border color on mouse leave. |
| `thumbtexture` | Atlas for the thumb. |
| `thumbwidth`, `thumbheight` | Thumb dimensions. |
| `thumbcolor` | Vertex color for the thumb. |
| `slider_left`, `slider_right`, `slider_middle` | Atlas for track artwork. |
| `amount_color`, `amount_outline`, `amount_size` | Style the value fontstring. |
| `enabled_backdropcolor` | Backdrop color for switch ON state. |
| `disabled_backdropcolor` | Backdrop color for switch OFF state. |
| `is_checkbox` | If true, calls `SetAsCheckBox()`. |
| `checked_texture`, `checked_xoffset`, `checked_yoffset`, `checked_size_percent`, `checked_color` | Checkbox checked mark styling. |
| `rounded_corner` | Adds rounded corners. |

### Scripts & Hooks

The slider supports these hook points via `SetHook()`:

| Hook | Arguments | Description |
|---|---|---|
| `OnEnter` | `(slider, object)` | Mouse enters the slider. |
| `OnLeave` | `(slider, object)` | Mouse leaves the slider. |
| `OnHide` | `(slider, object)` | Slider is hidden. |
| `OnShow` | `(slider, object)` | Slider is shown. |
| `OnMouseDown` | `(slider, button, object)` | Mouse button pressed on slider. |
| `OnMouseUp` | `(slider, button, object)` | Mouse button released. |
| `OnValueChanged` | `(slider, fixedValue, value, object)` | Value changed. |
| `OnValueChange` | `(slider, fixedValue, value, object)` | Alias for `OnValueChanged`. |

### OnValueChanged Flow

1. The native `OnValueChanged` script fires.
2. The raw value is read. If not decimal, precision is cleaned via `do_precision`.
3. If `typing_value` is active and not `typing_can_change`, the value is reverted (prevents slider drag while typing).
4. The value is pushed into `previous_value` ring buffer.
5. The `amt` fontstring is updated.
6. If `NoCallback` is true, it is cleared and the function returns (no callback).
7. Hooks for `OnValueChanged` and `OnValueChange` are run.
8. If `self.OnValueChanged` exists, it is called with `(slider, FixedValue, value)`.

### Plus/Minus Buttons

When hovering over a slider, a floating frame with `+` and `-` buttons appears (anchored to the right by default, or left if `bAttachButtonsToLeft` is set). These buttons:

- **Click:** Increment/decrement by `fine_tuning`, or by 0.1 (decimal) / 1 (integer).
- **Hold (>0.4s):** Auto-repeat at 0.1s intervals.

---

## Switch — `CreateSwitch`

### Signature

```lua
DF:CreateSwitch(parent, onSwitch, defaultValue, width, height, leftText, rightText, member, name, colorInverted, switchFunc, returnFunc, withLabel, switch_template, label_template)
```

### Parameters

| # | Name | Type | Default | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | — | Parent frame. |
| 2 | `onSwitch` | `function?` | — | Callback: `function(self, fixedValue, value)`. |
| 3 | `defaultValue` | `boolean?` | — | Initial state. |
| 4 | `width` | `number?` | `60` | Width. |
| 5 | `height` | `number?` | `20` | Height. |
| 6 | `leftText` | `string?` | `"OFF"` | Text shown when off (thumb on left). |
| 7 | `rightText` | `string?` | `"ON"` | Text shown when on (thumb on right). |
| 8 | `member` | `string?` | — | Sets `parent[member] = switch`. |
| 9 | `name` | `string?` | auto | Global name. |
| 10 | `colorInverted` | `boolean?` | — | Stored but not used by default. |
| 11 | `switchFunc` | `function?` | — | Transform function applied to the value before setting: `value = switchFunc(value)`. |
| 12 | `returnFunc` | `function?` | — | Transform applied to the value before passing to the callback. |
| 13 | `withLabel` | `string?` | — | If set, creates a label and anchors the switch to its right. |
| 14 | `switch_template` | `string\|table?` | — | Template applied via `SetTemplate()`. |
| 15 | `label_template` | `string\|table?` | — | Template for the label. |

### Returns

`df_checkbox, df_label?`

### Construction Details

A switch is built on top of `DF:NewButton` — it is a DF button with switch-specific methods and behavior injected:

1. Creates a `df_button` via `DF:NewButton`.
2. Sets `type = "switch"`, `isSwitch = true`.
3. Injects switch methods: `SetValue`, `GetValue`, `SetFixedParameter`, `GetFixedParameter`, `Disable`, `Enable`, `SetAsCheckBox`, `SetSwitchFunction`, `GetSwitchFunction`, `CreateExtraSpaceToClick`.
4. Creates a thumb texture and a text fontstring for the ON/OFF label.
5. Sets `OnClick` to `SwitchOnClick`.
6. Calls `SetValue(defaultValue)` to initialize visual state.

### State Storage

The switch stores its boolean state directly as `rawget(self, "value")`:
- `true` = ON (thumb right, blue backdrop by default).
- `false` = OFF (thumb left, red backdrop by default).

### SwitchOnClick Flow

1. Checks `lockdown` — if locked, returns.
2. If `forced_value` is true, sets `value` to `not value` (used by `SetValue`).
3. Toggles `value`:
   - **Becoming OFF:** Sets red backdrop (or `backdrop_disabledcolor`), moves thumb left, shows `leftText`.
   - **Becoming ON:** Sets blue backdrop (or `backdrop_enabledcolor`), moves thumb right, shows `rightText`.
4. If checkbox mode: shows/hides the checked texture instead of moving the thumb.
5. If `OnSwitch` callback exists and this is not a forced-value call:
   - Applies `return_func` if defined.
   - Calls `OnSwitch(self, FixedValue, value)`.
   - Runs hooks for `"OnSwitch"`.

### Switch Methods

| Method | Description |
|---|---|
| `SetValue(value, forcedState)` | Sets the switch state. If `forcedState == "RUN_CALLBACK"`, the callback is triggered. Otherwise, only the visual state changes. If `switch_func` is set, the value is transformed first. |
| `GetValue()` | Returns the current boolean state. |
| `SetFixedParameter(value)` | Sets the `FixedValue` passed to callbacks. |
| `GetFixedParameter()` | Gets `FixedValue`. |
| `Enable()` | Unlocks the switch, shows text/thumb, sets alpha to 1. |
| `Disable()` | Locks the switch, hides text, shows lock icon (or hides checkbox texture), sets alpha to 0.4. |
| `SetSwitchFunction(func)` | Replaces `OnSwitch`. |
| `GetSwitchFunction()` | Returns `OnSwitch`. |

---

## Switch as Checkbox — `SetAsCheckBox()`

Calling `switch:SetAsCheckBox()` transforms a switch into a checkbox:

### What Changes

1. Creates a `checked_texture` (checkmark) overlay centered on the button.
2. Hides the thumb and ON/OFF text permanently.
3. Sets `is_checkbox = true`.
4. Aliases `SetChecked` → `SetValue`, `GetChecked` → `GetValue`.
5. Adds `SetCheckedTexture(texture, xOffset, yOffset, sizePercent, color)` for customizing the checkmark appearance.

### Visual Behavior

- **Checked (value=true):** `checked_texture` is shown, backdrop uses `backdrop_enabledcolor`.
- **Unchecked (value=false):** `checked_texture` is hidden, backdrop uses `backdrop_disabledcolor`.
- Clicking toggles the state — same `SwitchOnClick` flow, but instead of moving a thumb, it shows/hides the checkmark.

### `SetCheckedTexture(texture, xOffset, yOffset, sizePercent, color)`

| Parameter | Type | Description |
|---|---|---|
| `texture` | `string?` | Texture path. |
| `xOffset` | `number?` | Horizontal offset (default -1). |
| `yOffset` | `number?` | Vertical offset (default -1). |
| `sizePercent` | `number?` | Size as percentage of widget width. |
| `color` | `any?` | Vertex color for the checkmark. |

### `CreateExtraSpaceToClick(label, widgetWidth, highlight)`

Creates an invisible button spanning the label area so clicking the label also toggles the checkbox. Returns `(extraSpaceFrame, highlightTexture?)`.

| Parameter | Type | Description |
|---|---|---|
| `label` | `df_label` | The label widget to extend the click area over. |
| `widgetWidth` | `number?` | Width of the clickable area (default 140). |
| `highlight` | `any?` | If truthy, creates a highlight texture. If `true`, uses white color; if string, uses as texture path. |

---

## Adjustment Slider — `CreateAdjustmentSlider`

### Purpose

A three-button control for drag-based value adjustment. Unlike a regular slider, it has no track — instead, the user clicks and drags to adjust values relative to mouse movement. The center button supports 2D adjustment (horizontal and vertical axes).

### Signature

```lua
DF:CreateAdjustmentSlider(parent, callback, options, name, ...)
```

### Parameters

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `parent` | `frame` | Parent frame. |
| 2 | `callback` | `function` | Called as `callback(self, valueX, valueY, isLiteral, ...)`. |
| 3 | `options` | `table?` | Configuration overrides. |
| 4 | `name` | `string?` | Global name. Auto-generated if nil. |
| 5 | `...` | `any` | Payload arguments passed to callbacks. |

### Default Options

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `70` | Total width. |
| `height` | `number` | `20` | Total height. |
| `scale_factor` | `number` | `1` | Multiplier applied to all callback values. |

### Construction

1. Creates a parent frame with `OptionsFunctions`, `AdjustmentSliderFunctions`, `PayloadMixin`, and `SetPointMixin`.
2. Creates three `df_button` instances: `leftButton`, `centerButton`, `rightButton`.
3. Left button has a left-arrow icon, right button a right-arrow icon, center button a drag icon.
4. All buttons hook `OnMouseDown` and `OnMouseUp` for drag tracking.
5. Stores `callback` and optional payload via `SetPayload(...)`.

### How Interaction Works

#### Click (no drag)

- **Left button click:** Calls `callback(self, -1 * scaleFactor, 0, true, ...)`.
- **Right button click:** Calls `callback(self, 1 * scaleFactor, 0, true, ...)`.
- A click is detected when the mouse position hasn't changed and the button was held for less than 0.5 seconds.

#### Hold (>0.5s, left/right buttons)

- Fires the same click callback repeatedly at the polling rate (every 0.05s).

#### Center button drag

- On mouse down, records the initial mouse position.
- An `OnUpdate` handler polls mouse position every 0.05 seconds.
- Mouse movement delta is mapped from pixel range `[-20, 20]` to normalized range `[-1, 1]` using `DF:MapRangeClamped`.
- Both X and Y axes are reported: `callback(self, horizontalValue * scaleFactor, verticalValue * scaleFactor, false, ...)`.
- The center arrow artwork visually follows the mouse direction during the drag.
- While dragging, `DF:DisableOnEnterScripts()` blocks hover tooltips on other frames.

#### `isLiteral` parameter

The callback receives `isLiteral`:
- `true` — the value is a discrete click (`-1` or `+1`). Add directly to the current value.
- `false` — the value is a continuous normalized delta from mouse movement. Scale as needed.

### AdjustmentSliderFunctions

| Method | Description |
|---|---|
| `SetScaleFactor(scalar)` | Sets the multiplier applied to all output values. |
| `GetScaleFactor()` | Returns the current scale factor. |
| `SetCallback(func)` | Replaces the callback function. |
| `SetPayload(...)` | Stores extra arguments passed after the main callback parameters. |
| `RunCallback(valueX, valueY, isLiteral)` | Executes the callback with error handling. |
| `Enable()` | Enables all three buttons. |
| `Disable()` | Disables all three buttons. |

### Key Fields

| Field | Type | Description |
|---|---|---|
| `leftButton` | `df_button` | The left (-) button. |
| `rightButton` | `df_button` | The right (+) button. |
| `centerButton` | `df_button` | The center (drag) button. |
| `centerArrowArtwork` | `Texture` | Arrow icon that follows mouse during drag. |
| `callback` | `function` | The value change callback. |
| `options` | `table` | Options table with `scale_factor`, `width`, `height`. |

**Returns:** the adjustment slider frame.

---

## Utility Functions

### `DF:DisableOnEnterScripts()` / `DF:EnableOnEnterScripts()`

Creates (or shows/hides) a full-screen transparent frame at the `TOOLTIP` strata that captures all mouse events, effectively blocking `OnEnter` scripts on frames beneath it. Used by the adjustment slider during center-button drags.

### `DF.TextToFloor(text)`

Parses a string like `"12.50"` into a number with proper decimal handling. Used by the TypeValue editbox.

---

## Usage Patterns

### Creating a Slider

```lua
local slider = DF:CreateSlider(parent, 120, 14, 0.6, 1.6, 0.1, 1.0, true)
slider.OnValueChanged = function(self, fixedValue, value)
    -- handle value change
end
```

### Creating a Switch (Toggle)

```lua
local switch = DF:CreateSwitch(parent, function(self, fixedValue, value)
    -- value is true or false
    savedVariable.enabled = value
end, savedVariable.enabled)
```

### Creating a Checkbox

```lua
local checkbox = DF:CreateSwitch(parent, onToggle, defaultValue, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
checkbox:SetAsCheckBox()
```

### Real-World: Checkbox with Label (window_scrolldamage.lua)

```lua
local onToggleAutoOpen = function(_, _, state)
    Details.damage_scroll_auto_open = state
end

local autoOpenCheckbox = DF:CreateSwitch(statusBar, onToggleAutoOpen, Details.auto_open_news_window,
    _, _, _, _, "AutoOpenCheckbox", _, _, _, _, _,
    DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
autoOpenCheckbox:SetAsCheckBox()
autoOpenCheckbox:SetPoint("left", statusBar, "left", 5, 0)
```

### Real-World: Scale Bar Slider (panel.lua)

```lua
local scaleBar = DF:CreateSlider(frame, 120, 14, 0.6, 1.6, 0.1, config.scale, true,
    "ScaleBar", nil, "Scale:",
    DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE"),
    DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))

scaleBar.OnValueChanged = function(_, _, value)
    if (scaleBar.mouseDown) then
        config.scale = value
    end
end
```

---

## Component Comparison

| Feature | Slider | Switch | Checkbox | Adjustment Slider |
|---|---|---|---|---|
| Value type | `number` | `boolean` | `boolean` | normalized `number` |
| Visual | Track + thumb | Thumb slides left/right | Checkmark | Three buttons |
| Callback | `OnValueChanged` | `OnSwitch` | `OnSwitch` | `callback` |
| FixedParameter | Yes | Yes | Yes | Via payload |
| Template support | Yes | Yes | Yes | No |
| Right-click type | Yes (editbox) | No | No | No |
| Disable/Enable | Yes (lock icon) | Yes (lock icon) | Yes (hides check) | Yes |
| Label support | Yes | Yes | Yes | No |
