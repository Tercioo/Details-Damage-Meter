# math.lua — Math, Range, and Geometry Utilities

A flat namespace of math helpers used throughout the framework: distance and rotation, range mapping and clamping, lerp / bezier, nine-point geometry, plus a small analytics block (percentile / standard deviation / moving average / safe division) added for damage-curve smoothing. No widgets, no mixins — purely functions.

The module exposes two parallel surfaces:

- **`DF.Math.<name>`** — the modern namespace, defined first.
- **`DF:<name>`** (colon, on the framework root) — legacy aliases. The source comment is explicit: *"old calls, keeping for compatibility"* (`math.lua:390`).

Both call sites resolve to identical implementations. New code should use `DF.Math.*`.

---

## Mental model

Most functions fall into one of six clusters:

```
distance / geometry        →  GetUnitDistance, GetPointDistance, GetVectorLength,
                              GetDotProduct, FindLookAtRotation,
                              GetNinePoints, GetClosestPoint, GetObjectCoordinates

range mapping (linear)     →  GetRangePercent, GetRangeValue, LerpNorm,
                              MapRangeClamped, MapRangeUnclamped,
                              MapRangeColor, InvertInRange

interpolation (curves)     →  GetBezierPoint, GetColorRangeValue, LerpLinearColor

clamp / compare            →  Clamp, IsWithin, IsNearlyEqual, IsNearlyZero,
                              PositiveNonZero, Round

random / misc              →  RandomFraction, MultiplyBy, GetSortFractionFromString

statistics                 →  Percentile, StandardDeviation, MovingAverage, SafeDivide
```

**The single argument convention to memorise**: range functions in this file take **`(min, max, value)` in that order** — *not* WoW's built-in `Clamp(value, min, max)` ordering. Mixing them up silently produces wrong numbers. See "Pitfalls".

---

## Library access

```lua
local DF = _G["DetailsFramework"]
local distance = DF.Math.GetPointDistance(0, 0, 3, 4)   -- → 5
-- or, legacy:
local distance = DF:GetDistance_Point(0, 0, 3, 4)
```

There is no constructor. The namespace lives directly on `DF.Math` after the file loads.

---

## Distance and geometry

### `DF.Math.GetUnitDistance(unitId1, unitId2)` — 2D unit distance

```lua
function DF.Math.GetUnitDistance(unitId1, unitId2)
```

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `unitId1` | `string` | First unit token (`"player"`, `"target"`, `"raid1"`, …). |
| 2 | `unitId2` | `string` | Second unit token. |

Returns the planar distance between the two units in yards (the WoW world unit). Uses `UnitPosition`'s first two returns — Y and X swapped per Blizzard's convention, but the swap cancels out for distance. **Vertical (Z) distance is ignored.**

Returns `0` if either unit does not exist.

### `DF.Math.GetPointDistance(x1, y1, x2, y2)` — euclidean

```lua
local d = DF.Math.GetPointDistance(x1, y1, x2, y2)   -- 2D
```

### `DF.Math.GetVectorLength(x, y, z?)` — magnitude

If `z` is omitted, computes 2D length. Pass `z` for 3D.

```lua
DF.Math.GetVectorLength(3, 4)        -- → 5
DF.Math.GetVectorLength(1, 2, 2)     -- → 3
```

### `DF.Math.GetDotProduct(v1, v2)` — 2D dot

```lua
DF.Math.GetDotProduct({x = 1, y = 2}, {x = 3, y = 4})   -- → 11
```

Operands are tables with `.x` / `.y` fields, not arrays. **Z is ignored** even if present.

### `DF.Math.FindLookAtRotation(x1, y1, x2, y2)` — radians

```lua
return atan2(y2 - y1, x2 - x1) + pi
```

Returns the rotation (radians) for an object at `(x1, y1)` to face `(x2, y2)`. The `+ pi` reflects the framework's rotation convention — pointing the object's "front" away from the target. If you need a "look-at" that aims the object's `+X` axis at the target, subtract `pi` from the result.

### `DF.Math.GetObjectCoordinates(object)` — bounding box

Returns an `objectcoordinates` table with:

| Field | Type | Description |
|---|---|---|
| `width` | `number` | `object:GetWidth()`. |
| `height` | `number` | `object:GetHeight()`. |
| `left` / `right` / `top` / `bottom` | `number` | Scalar edge coordinates (`centerX ± halfWidth`, `centerY ± halfHeight`). |
| `center` | `{x, y}` | `object:GetCenter()`. |
| `topleft`, `topright`, `bottomleft`, `bottomright` | `{x, y}` | Corner coordinate tables. |

Errors if the object has no center (the function doesn't, but read further — `GetNinePoints` does the same).

> Note: this function lives on `DF:` (colon-method), not `DF.Math.*`. There is no `DF.Math.GetObjectCoordinates` despite the field appearing in `df_math`'s annotation block.

### `DF.Math.GetNinePoints(object)` — nine anchor points

Returns a `df_ninepoints` array whose entries are coordinates in this order:

| Index | Anchor |
|---|---|
| 1 | topleft |
| 2 | left |
| 3 | bottomleft |
| 4 | bottom |
| 5 | bottomright |
| 6 | right |
| 7 | topright |
| 8 | top |
| 9 | center |

The returned table is **both an array (1..9) and an object** (`.GetClosestPoint` method attached at construction).

Errors if `object:GetCenter()` returns nil (typically because the object has not been positioned).

### `DF.Math.GetClosestPoint(ninePoints, coordinate)` — nearest anchor

```lua
local anchorIndex, offsetX, offsetY, pointX, pointY = DF.Math.GetClosestPoint(ninePoints, {x = mx, y = my})
```

Iterates the nine points and returns the closest one to `coordinate`. Returns five values:

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `anchorIndex` | `1..9` | Index into the nine-point array. |
| 2 | `offsetX` | `number` | `coordinate.x - closestPoint.x`. |
| 3 | `offsetY` | `number` | `coordinate.y - closestPoint.y`. |
| 4 | `pointX` | `number` | Closest point's X. |
| 5 | `pointY` | `number` | Closest point's Y. |

The `df_ninepoints` table also has `:GetClosestPoint(coordinate)` so you can call it method-style.

---

## Range mapping and clamping

The common helpers — used by most range/percent math:

| Function | Signature | Notes |
|---|---|---|
| `GetRangePercent(min, max, value)` | → `[0, 1]` | `(value - min) / max(max - min, SMALL_FLOAT)`. The `SMALL_FLOAT` guard avoids divide-by-zero when min == max. |
| `GetRangeValue(min, max, percent)` | → number | Wraps Blizzard's `Lerp(min, max, percent)`. |
| `LerpNorm(min, max, value)` | → number | Same math as `GetRangeValue` but inlined without the `Lerp` global. Use either. |
| `MapRangeClamped(inX, inY, outX, outY, value)` | → number | Maps `value` from `[inX, inY]` to `[outX, outY]`, clamped to `[outX, outY]`. |
| `MapRangeUnclamped(inX, inY, outX, outY, value)` | → number | Same but no clamp — overshoot allowed. |
| `InvertInRange(min, max, value)` | → number | Mirrors a value within a range. `InvertInRange(0, 100, 75)` → `25`. Works for negative ranges. |
| `Clamp(min, max, value)` | → number | **NOTE: `(min, max, value)` order — NOT WoW's `(value, min, max)`.** See Pitfalls. |
| `IsWithin(min, max, value, isInclusive?)` | → boolean | `isInclusive == true` includes the max edge; else half-open `[min, max)`. |
| `IsNearlyEqual(a, b, tolerance?)` | → boolean | Defaults `tolerance` to `SMALL_FLOAT` (`0.000001`). |
| `IsNearlyZero(value, tolerance?)` | → boolean | Same. |
| `PositiveNonZero(value)` | → number | `max(value, 0.001)` — clamps non-positive values to a small positive number. Useful before dividing. |
| `Round(num, decimalPlaces?)` | → number | Default `decimalPlaces = 0`. Half-away-from-zero rounding. |
| `RandomFraction(min?, max?)` | → number | Defaults `(0, 1)`. Uniform random in `[min, max]`. |
| `MultiplyBy(value, ...)` | → ... | Multiplies all varargs by `value` and unpacks. |

### `MapRangeColor` is not a colour-space mapping

Despite the name, `MapRangeColor(inX, inY, outX, outY, r, g, b)` simply applies `MapRangeClamped` independently to each of `r`, `g`, `b`. There is no perceptual transform. Useful for "scale my [0,1] colour into [0,255]" but nothing more.

---

## Interpolation and curves

### `LerpLinearColor(deltaTime, interpSpeed, r1, g1, b1, r2, g2, b2)` — frame-time eased colour transition

```lua
local r, g, b = DF.Math.LerpLinearColor(elapsed, 4, oldR, oldG, oldB, newR, newG, newB)
```

Returns a colour somewhere between `(r1, g1, b1)` and `(r2, g2, b2)`. The progress factor is `Clamp(deltaTime * interpSpeed, 0, 1)`. The clamp is load-bearing: a long frame (large `deltaTime`) cannot push the colour past the target. Call once per frame inside an `OnUpdate`.

### `GetColorRangeValue(r1, g1, b1, r2, g2, b2, value)` — colour at a normalised position

Same shape, but no time-clamp. `value` is the explicit `[0, 1]` position you want.

### `GetBezierPoint(t, p1, p2, p3)` — quadratic Bezier

Scalar quadratic Bezier (not vector). Compose three calls for 2D or 3D points.

```lua
local bx = DF.Math.GetBezierPoint(t, p1x, p2x, p3x)
local by = DF.Math.GetBezierPoint(t, p1y, p2y, p3y)
```

---

## Statistics block

These were added later for analytics on per-second damage / healing curves. Production consumer is Details!'s reporting / charting code.

### `Percentile(t, p)` — p-th percentile

```lua
local p95 = DF.Math.Percentile(damageSamples, 0.95)
```

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `t` | `number[]` | Input array. **Not mutated** — the function copies and sorts internally. |
| 2 | `p` | `number` | Percentile rank in `[0, 1]`. Clamped if outside. |

Linear interpolation between adjacent ranks (`rank = p * (n - 1) + 1`). Returns `nil` for an empty array, `t[1]` for a single element.

### `StandardDeviation(t)` — population stddev

Returns `0` for empty or single-element input. Two-pass implementation (mean then variance) — not numerically robust for very large samples, but fine for the dataset sizes WoW addons produce.

### `MovingAverage(t, window)` — centred running mean

Returns a **new array** of the same length as `t`, where each entry is the mean of `t[i - half .. i + half]`. At array edges the window is truncated to the available samples, so the first and last entries average over fewer values.

```lua
local smoothed = DF.Math.MovingAverage(perSecondDamage, 5)
```

`window` is `math.floor`-ed and clamped to a minimum of `1`. Passing `0` or negative is safe; you'll just get the input copied.

### `SafeDivide(a, b, fallback?)`

`a / b`, or `fallback` (default `0`) when `b == 0`. Useful at empty-window / no-damage boundaries.

---

## Misc

### `GetSortFractionFromString(str)` — reverse-alphabetical sort tiebreaker

Produces a tiny float derived from the first two characters of `str`, intended to be added to a primary numeric sort key as a deterministic tiebreaker.

The math (`math.lua:140-145`):

```lua
local name = string.upper(str) .. "ZZ"
local byte1 = abs(string.byte(name, 2) - 91) / 1000000
return byte1 + abs(string.byte(name, 1) - 91) / 10000
```

The magic `91` is intentional — it inverts the alphabet so `'A'` has the largest weight (`91 - 65 = 26`) and `'Z'` the smallest (`91 - 90 = 1`). The result is small enough to never overwhelm a primary integer sort key, but distinguishes ties between names. **`"ZZ"` is appended** to ensure `byte(name, 2)` is always defined even for single-character strings.

Use as `primaryValue + GetSortFractionFromString(name)` in a sort key.

### `ScaleBack()`

Empty function. Placeholder. Does nothing.

---

## Globals and constants

| Name | Type | Value | Notes |
|---|---|---|---|
| `SMALL_FLOAT` | global number | `0.000001` | Used by `IsNearlyEqual`, `IsNearlyZero`, `GetRangePercent`. **NOT declared local** — pollutes `_G`. See Pitfalls. |

---

## Pitfalls

### Argument order: `Clamp(min, max, value)` — NOT `Clamp(value, min, max)`

WoW's built-in `Clamp` (used inside this file) takes `(value, min, max)`. The framework's `DF.Math.Clamp` and `DF:Clamp` aliases take **`(min, max, value)`** to match the in-file convention used by `GetRangePercent`, `GetRangeValue`, `IsWithin`, etc. Mixing them up doesn't error — it silently produces wrong numbers.

**Symptom**: `DF.Math.Clamp(value, 0, 100)` produces `100` (or the value, accidentally) instead of clamping into `[0, 100]`.

**Fix**: read the parameter list every time. The convention across this file is min-max-value; remember it.

```lua
DF.Math.Clamp(0, 100, 150)        -- correct → 100
DF.Math.Clamp(150, 0, 100)        -- WRONG order → unexpected result
```

### `SMALL_FLOAT` is a true global

```lua
SMALL_FLOAT = 0.000001
```

No `local`. This writes `_G["SMALL_FLOAT"] = 0.000001`. Any other addon defining its own `SMALL_FLOAT` will be overwritten (or will overwrite the framework's). Low risk in practice — the name is unusual — but the leak is real.

**Fix (if you're maintaining)**: change to `local SMALL_FLOAT = 0.000001` and update consumers if there are any external readers.

### `GetUnitDistance` ignores vertical distance

WoW's `UnitPosition` returns Y, X, Z, instance. This function uses only the first two. Two units stacked vertically (e.g. one on a platform above another) return distance `0`. For raid encounters with stacked phases that matters.

**Fix**: read all three returns from `UnitPosition` and compute the 3D length:

```lua
local y1, x1, z1 = UnitPosition("player")
local y2, x2, z2 = UnitPosition("target")
local dist = ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2) ^ 0.5
```

### `MapRangeColor` is per-channel — not a colourspace transform

The name suggests something like a gradient mapping or a colourspace conversion. It is neither — it's three independent linear maps. If you want a perceptual gradient, use `LerpLinearColor` / `GetColorRangeValue` instead.

### `FindLookAtRotation` adds `+ pi`

The result is the angle from `(x1, y1)` to `(x2, y2)`, **rotated by 180°**. If you're integrating with rotation code that uses a different convention, you'll see things facing backwards. Subtract `pi` (or call `atan2` directly).

### Legacy `DF:<name>` aliases coexist with `DF.Math.<name>`

```lua
DF.Math.GetPointDistance(...)       -- modern
DF:GetDistance_Point(...)            -- legacy, same implementation
```

Both call sites exist throughout the framework. New code should use `DF.Math.*`. The annotations on `df_math` (`math.lua:21-52`) document the modern namespace; the legacy aliases are not annotated and may not be visible to LSP tooling.

### Some methods listed in `df_math` are not actually on `DF.Math`

The annotation block at `math.lua:21-52` declares `GetObjectCoordinates` as a field of `df_math`, but the function is defined on `DF:` (colon-method on the framework root), not `DF.Math`. Trying `DF.Math.GetObjectCoordinates(frame)` returns nil; you must use `DF:GetObjectCoordinates(frame)`.

**Affected**: `GetObjectCoordinates` (definitely). Audit the other entries against the source if you depend on the annotation.

### `Percentile` and `MovingAverage` make a copy

`Percentile` sorts a copy of the input (intentional — preserves caller order). `MovingAverage` allocates a fresh result array of size N. Neither is suitable for hot per-frame paths over large datasets; cache results.

### `StandardDeviation` is population, not sample

The variance is divided by `n`, not `n - 1`. If you need the unbiased sample-stddev estimator, multiply by `sqrt(n / (n - 1))` after calling.

### `Round`'s rounding rule

Half-away-from-zero (the `+ 0.5` trick). So `Round(0.5)` → `1`, `Round(-0.5)` → `0` (because `floor(-0.5 + 0.5) = 0`). If you need banker's rounding or any other rule, write your own.

### `GetSortFractionFromString` weight magnitudes

The first character contributes up to `26 / 10000 = 0.0026`; the second up to `26 / 1000000 = 0.000026`. If your primary sort key is *also* fractional and could collide near these scales, the tiebreaker becomes unreliable. Intended for integer or large-fractional primary keys.

### `ScaleBack` is empty

Don't call it expecting anything to happen. Looks like a placeholder. If you find it referenced from another file, that call site is also a no-op.

---

## Public method reference

### `DF.Math.*` namespace

| Method | Purpose |
|---|---|
| `GetUnitDistance(u1, u2)` | 2D distance between two units, in yards. 0 if either is missing. |
| `GetPointDistance(x1, y1, x2, y2)` | 2D euclidean. |
| `GetVectorLength(x, y, z?)` | 2D or 3D magnitude. |
| `GetDotProduct(v1, v2)` | 2D dot product of `{x, y}` tables. |
| `FindLookAtRotation(x1, y1, x2, y2)` | Radians, with `+pi` framework convention. |
| `GetNinePoints(obj)` | Returns 9-element coordinate array + `GetClosestPoint` method. |
| `GetClosestPoint(ninePoints, coord)` | Returns `(index, dx, dy, px, py)`. |
| `GetRangePercent(min, max, value)` | `(value - min) / max(max - min, SMALL_FLOAT)`. |
| `GetRangeValue(min, max, percent)` | `Lerp(min, max, percent)`. |
| `LerpNorm(min, max, value)` | Inlined Lerp. |
| `MapRangeClamped(...)` | Cross-range map with clamp. |
| `MapRangeUnclamped(...)` | Cross-range map without clamp. |
| `MapRangeColor(...)` | Per-channel `MapRangeClamped` on RGB. |
| `InvertInRange(min, max, value)` | Mirror within range. |
| `Clamp(min, max, value)` | **Note `(min, max, value)` ordering.** |
| `IsWithin(min, max, value, inclusive?)` | Bool. |
| `IsNearlyEqual(a, b, tol?)` | Bool, default `SMALL_FLOAT`. |
| `IsNearlyZero(v, tol?)` | Bool, default `SMALL_FLOAT`. |
| `PositiveNonZero(v)` | `max(v, 0.001)`. |
| `Round(num, places?)` | Half-away-from-zero. |
| `RandomFraction(min?, max?)` | Uniform random in `[min, max]`, default `[0, 1]`. |
| `MultiplyBy(value, ...)` | Multiply varargs and unpack. |
| `GetBezierPoint(t, p1, p2, p3)` | Quadratic Bezier scalar. |
| `LerpLinearColor(dt, speed, r1, g1, b1, r2, g2, b2)` | Frame-time eased colour. |
| `GetColorRangeValue(r1, g1, b1, r2, g2, b2, t)` | Colour at normalised t. |
| `GetSortFractionFromString(s)` | Small float for reverse-alphabetical tie-break. |
| `Percentile(t, p)` | p-th percentile with linear interp; doesn't mutate `t`. |
| `StandardDeviation(t)` | Population stddev; 0 for short inputs. |
| `MovingAverage(t, window)` | New array of centred moving averages. |
| `SafeDivide(a, b, fallback?)` | `a/b` or `fallback` when `b == 0`. |

### Legacy `DF:` aliases (deprecated but kept for compatibility)

| Method | Notes |
|---|---|
| `DF:GetDistance_Unit(u1, u2)` | Alias for `DF.Math.GetUnitDistance`. |
| `DF:GetDistance_Point(x1, y1, x2, y2)` | Alias for `DF.Math.GetPointDistance`. |
| `DF:FindLookAtRotation(...)` | Alias. |
| `DF:MapRangeClamped(...)` / `DF:MapRangeUnclamped(...)` | Aliases. |
| `DF:GetRangePercent(...)` / `DF:GetRangeValue(...)` | Aliases. |
| `DF:GetColorRangeValue(...)` | Alias. |
| `DF:GetDotProduct(...)` | Alias. |
| `DF:GetBezierPoint(...)` | Alias. |
| `DF:GetVectorLength(...)` | Alias. |
| `DF:LerpNorm(...)` / `DF:LerpLinearColor(...)` | Aliases. |
| `DF:IsNearlyEqual(...)` / `DF:IsNearlyZero(...)` / `DF:IsWithin(...)` | Aliases. |
| `DF:Clamp(min, max, value)` | Alias. **Same `(min, max, value)` ordering as the framework convention.** |
| `DF:Round(num, places?)` | Alias. |
| `DF:GetObjectCoordinates(obj)` | **Only exists on `DF:`** — not on `DF.Math`. |
| `DF:ScaleBack()` | Empty stub. |

---

## Usage Examples

### Health-bar colour ramp from green to red

```lua
local DF = _G["DetailsFramework"]

local function healthBarColor(currentHP, maxHP)
    local pct = DF.Math.GetRangePercent(0, maxHP, currentHP)   -- 0..1
    -- green at full, red at empty
    return DF.Math.GetColorRangeValue(1, 0, 0, 0, 1, 0, pct)
end

local r, g, b = healthBarColor(35, 100)   -- → mostly red-orange
```

### Smoothed per-second damage curve

```lua
local DF = _G["DetailsFramework"]

local perSecondDamage = computeDPSPerSecond()             -- e.g. {1200, 1450, 980, ...}
local smoothed       = DF.Math.MovingAverage(perSecondDamage, 5)
local p95            = DF.Math.Percentile(perSecondDamage, 0.95)
local sigma          = DF.Math.StandardDeviation(perSecondDamage)

print(("p95 = %d, sigma = %.1f"):format(p95, sigma))
renderCurve(smoothed)
```

### Snap a dropped widget to the nearest of a 9-point grid

```lua
local DF = _G["DetailsFramework"]

local container = MyContainer
local ninePoints = DF.Math.GetNinePoints(container)
local mouseX, mouseY = GetCursorPosition()
local scale = UIParent:GetEffectiveScale()
mouseX, mouseY = mouseX / scale, mouseY / scale

local idx, dx, dy = ninePoints:GetClosestPoint({x = mouseX, y = mouseY})
-- idx is 1..9 in the order documented above
local point = ({"TOPLEFT", "LEFT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT",
                "RIGHT", "TOPRIGHT", "TOP", "CENTER"})[idx]
widget:ClearAllPoints()
widget:SetPoint(point, container, point, 0, 0)
```

### Eased colour interpolation in an OnUpdate

```lua
frame:SetScript("OnUpdate", function(self, elapsed)
    local r, g, b = DF.Math.LerpLinearColor(elapsed, 4,
        self.currentR, self.currentG, self.currentB,
        self.targetR,  self.targetG,  self.targetB)
    self.tex:SetVertexColor(r, g, b)
    self.currentR, self.currentG, self.currentB = r, g, b
end)
```

---

## Notes for AI readers

1. **Range-function arg order is `(min, max, value)`, not WoW's `(value, min, max)`.** Affects `Clamp`, `GetRangePercent`, `GetRangeValue`, `IsWithin`, `InvertInRange`. Don't conflate with WoW's `Clamp` global.
2. **`GetUnitDistance` is 2D.** If consumer code asks about "distance between two units" in a context where Z matters (vertical separation), recommend reading `UnitPosition` directly and computing 3D.
3. **`MapRangeColor` is per-channel.** Don't recommend it as a "gradient" function — use `GetColorRangeValue` / `LerpLinearColor` for that.
4. **`SMALL_FLOAT` leaks into `_G`.** Don't depend on it being `0.000001`; another addon could rebind it.
5. **The legacy `DF:` aliases exist** but recommend `DF.Math.*` for new code.
6. **`GetObjectCoordinates` lives on `DF:`, not `DF.Math`.** Despite the annotation block listing it. Use `DF:GetObjectCoordinates(frame)`.
7. **`Percentile` and `MovingAverage` allocate.** Don't recommend them inside per-frame hot loops over large datasets without caching.
8. **`StandardDeviation` is population, not sample.** Document this when reporting analytics; otherwise consumers comparing against external (sample-stddev) tools will see a small discrepancy.
9. **`FindLookAtRotation` includes a `+ pi`** — the result is the "back-of-object faces target" angle by convention. If you want "front-faces-target", subtract `pi`.

---

## See also

- `colors.lua` — `DF:ParseColors` and the named-colour table. Most colour outputs from `math.lua` are then handed to `SetVertexColor` / `SetTextColor`; consumers often `ParseColors` first.
- `panel.lua` — `DF:GetObjectCoordinates` lives here in terms of conceptual ownership (frame geometry helpers), even though it's on the framework root.
- `pools.lua` — not directly related, but the analytics block (`Percentile`, `MovingAverage`) is the kind of utility called from line-based scrolling data widgets in `scrollbox.lua`.
- `Lerp` (Blizzard global) — used internally by `GetRangeValue` and `GetBezierPoint`.
