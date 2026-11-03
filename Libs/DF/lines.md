# DetailsFramework Lines Documentation

## Overview

`DF:CreateLine` draws a line between two ends. Each end is either a point of a frame (the line follows the frame when it moves) or a fixed position. The line can be:

| `line_type` | Shape |
|---|---|
| `"line"` | A straight line. |
| `"rope"` | A rope hanging between the two ends. The curve is recalculated each time an end moves. |
| `"physics"` | A rope simulated with gravity. It swings when an end moves and settles by itself. |

Any of the three can be solid or dashed. A dotted line is a dashed line whose dash length equals its thickness.

Every shape is a path of points drawn with one Blizzard `Line` region per straight piece. Regions are created on demand and reused, never destroyed. The math lives in [physics.md](physics.md).

**Constructor:** `DF:CreateLine(parent, name, options)`

**Examples:** [lines.examples.lua](lines.examples.lua)

---

## 1. Constructor

```lua
local line = DF:CreateLine(parent, name, options)
```

| Name | Type | Description |
|---|---|---|
| `parent` | `frame` | The line frame is created as a child of `parent` and covers it (`SetAllPoints`). |
| `name` | `string?` | Optional global name for the line frame. |
| `options` | `df_line_options?` | Overrides merged onto the defaults below. |

**Returns:** `df_line`, a frame with the `df_linemixin` and `OptionsFunctions` methods.

The line draws nothing until both ends are set. The line frame does not take mouse input, so clicks pass through it.

---

## 2. Options (`df_line_options`)

| Option | Default | Description |
|---|---|---|
| `line_type` | `"line"` | `"line"`, `"rope"` or `"physics"`. |
| `thickness` | `2` | Thickness of the line. |
| `color` | `{1, 1, 1, 1}` | Any color format `DF:ParseColors` accepts. |
| `texture` | `Interface\Buttons\WHITE8X8` | Texture drawn along each piece, tinted by `color`. |
| `draw_layer` | `"overlay"` | Draw layer of the line regions. |
| `sub_level` | `0` | Sub level inside the draw layer. |
| `dash_length` | `0` | Length of each dash in pixels. `0` draws a solid line. |
| `gap_length` | `0` | Space between two dashes in pixels. `0` draws a solid line. |
| `segments` | `24` | Rope only: amount of straight pieces the curve is drawn with. |
| `slack` | `1.25` | Rope and physics: rope length as a multiple of the distance between the two ends. Used when `rope_length` is `0`. |
| `extra_length` | `0` | Rope and physics: pixels added to the slack length. With `slack = 1`, a near and a far rope hang by a similar amount instead of the far one dropping much lower. |
| `rope_length` | `0` | Rope and physics: fixed rope length in pixels. `0` uses `slack` and `extra_length`. |
| `simulation_points` | `16` | Physics only: amount of points simulated along the rope. |
| `smoothing` | `3` | Physics only: pieces drawn between two simulated points. |
| `gravity` | `-1200` | Physics only: pixels per second squared. Negative pulls down. |
| `damping` | `0.98` | Physics only: fraction of the velocity kept each step. Lower settles faster. |
| `stiffness` | `20` | Physics only: passes per step that pull the rope back to its length. Lower makes it stretchy. |
| `impulse_variation` | `0` | Physics only: `0` to `1`, how different each push from `ApplyImpulse` is. `0` makes every push swing the same. |
| `auto_update` | `true` | Follow anchored frames every frame. When `false`, call `Refresh()` after moving them. A physics rope always updates. |

**Slack or fixed length.** With `slack` (plus `extra_length`), the rope grows and shrinks with the distance between its ends, so it always looks the same. With `rope_length`, the rope behaves like a real one: pulling the ends further apart than its length makes it tight.

---

## 3. Methods

### Ends

| Method | Description |
|---|---|
| `SetStartAnchor(frame, point, offsetX, offsetY)` | Attach the start to a point of a frame. `point` defaults to `"center"`, any case. Offsets are in the frame's own units, like `SetPoint`. |
| `SetEndAnchor(frame, point, offsetX, offsetY)` | Same for the end. |
| `SetStartPosition(x, y)` | Fix the start at a position, in pixels from the bottom left corner of the line frame (which is the parent's bottom left). |
| `SetEndPosition(x, y)` | Same for the end. |

An anchor frame and the line frame can have different scales; the point is converted. While an anchor frame has no position (never laid out), the line hides and comes back when it gets one.

### Shape and look

| Method | Description |
|---|---|
| `SetLineType(lineType)` | Switch between `"line"`, `"rope"` and `"physics"`. Switching to physics starts the rope at rest. |
| `GetLineType()` | Return the current line type. |
| `SetThickness(thickness)` | |
| `SetColor(r, g, b, a)` | Any color format `DF:ParseColors` accepts. |
| `SetTexture(texture)` | |
| `SetLineDrawLayer(drawLayer, subLevel)` | Draw layer of the line pieces. |
| `SetDashes(dashLength, gapLength)` | `0` for either draws a solid line. |
| `SetSegments(segments)` | Rope only. |
| `SetSlack(slack)` / `SetExtraLength(extraLength)` / `SetRopeLength(ropeLength)` | See the options table. |
| `SetAutoUpdate(isEnabled)` | |
| `Refresh()` | Redraw now. Needed only when `auto_update` is off and an anchored frame moved. |

### Physics

| Method | Description |
|---|---|
| `SetGravity(gravity)` | Pixels per second squared, negative pulls down. |
| `SetDamping(damping)` | |
| `SetStiffness(stiffness)` | |
| `SetSimulationPoints(amountOfPoints)` | Rebuilds the simulation; the rope starts at rest again. |
| `SetSmoothing(smoothing)` | |
| `ApplyImpulse(impulseX, impulseY, variation)` | Push the rope, in pixels per step. `ApplyImpulse(0, 8)` makes it jump. `variation` (`0` to `1`, defaults to the `impulse_variation` option) gives each push a random strength, a lean toward one end and a small sideways drift, so repeated pushes do not swing the same. A rope that was about to restart at rest (just shown, or just moved to another frame) restarts first, so the push is not lost. |
| `SetImpulseVariation(variation)` | Default `variation` for `ApplyImpulse`. |

---

## 4. Behaviour notes

- **Updating.** The line frame runs an `OnUpdate` while `auto_update` is on or the line is a physics rope. A straight line or a hanging rope only redraws when one of its ends moved. A physics rope goes to sleep once it stops moving and wakes when an end moves or a setting changes, so a resting rope costs a position check per frame.
- **Hidden and shown again.** The `OnUpdate` stops while the line frame is hidden. A physics rope that is shown again starts at rest instead of simulating the time it was hidden.
- **Moving an end to another frame.** `SetStartAnchor` / `SetEndAnchor` with a different frame start a physics rope at rest, instead of swinging it across from the old frame. A frame that moves makes the rope swing as usual.
- **Joints.** Each solid piece is stretched by half the thickness into the next one, which covers the notch a thick line shows on a bend. With a color whose alpha is below 1, the overlap shows as slightly darker spots at the joints.
- **Dashes on curves.** The dash pattern is measured along the path, so dashes keep their length on a rope. A dash crossing a joint is drawn in two pieces.
- **Region count.** A straight solid line uses 1 region, a rope uses `segments`, a physics rope uses `(simulation_points - 1) * smoothing`. Dashes add one region per dash.
- **Secret positions.** The ends are read with `GetRect()` and the line does arithmetic on them. A frame whose rect comes back as secret values on the Midnight client cannot be used as an anchor.

---

## 5. Usage

```lua
local DF = DetailsFramework

--a cable hanging from a knob to an arrow, like the patch cables of a synth
local cable = DF:CreateLine(panel, nil, {line_type = "rope", thickness = 2, slack = 1.3, color = {0.6, 0.9, 0.3, 1}})
cable:SetStartAnchor(knob, "bottom")
cable:SetEndAnchor(arrow, "top")

--the same cable with physics, it swings when the knob is dragged
cable:SetLineType("physics")

--a dotted guide line between two fixed points
local guide = DF:CreateLine(panel, nil, {thickness = 2, dash_length = 2, gap_length = 4})
guide:SetStartPosition(10, 10)
guide:SetEndPosition(200, 10)
```
