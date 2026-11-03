# DetailsFramework Physics Documentation

## Overview

`DF.Physics` holds curve and simulation helpers. They work on plain numbers and do not touch any frame, so they can be used for anything that needs a curve or a rope. [lines.md](lines.md) builds its rope shapes on them.

| Function | Returns | Description |
|---|---|---|
| `DF.Physics.GetQuadraticBezierPoint(t, startX, startY, controlX, controlY, endX, endY)` | `x, y` | The point at `t` (0 to 1) of a quadratic bezier curve. |
| `DF.Physics.GetCatmullRomPoint(t, x0, y0, x1, y1, x2, y2, x3, y3)` | `x, y` | The point at `t` (0 to 1) between the second and third points of a Catmull-Rom spline. The curve passes through every point it is given; the first and fourth only shape the bend. |
| `DF.Physics.GetRopeSag(distance, ropeLength)` | `number` | How far below the middle of its two ends a hanging rope dips. `0` when the rope is not longer than the distance. |
| `DF.Physics.GetRopeControlPoint(startX, startY, endX, endY, ropeLength)` | `x, y` | The quadratic bezier control point that draws a hanging rope between two points. |
| `DF.Physics.CreateRope(amountOfPoints)` | `df_physicsrope` | A rope simulation with `amountOfPoints` points (at least 2), both ends pinned. |

The Catmull-Rom helper does the same math as Blizzard's `CatmullRom_Calculate2DPointOnCurve` (`Blizzard_SharedXML/Spline.lua`). It is kept here so it takes plain numbers without a spline object and does not depend on that file on every client.

**About the sag.** `GetRopeSag` matches a parabola for a nearly tight rope and a rope folded in half when both ends meet. Against a true hanging chain, a rope of 250 pixels over a span of 200 dips 65 pixels with this formula and 66 for the chain.

---

## Rope simulation (`df_physicsrope`)

The rope is a chain of points moved with Verlet integration: each point keeps the velocity it had on the last step, gravity is added, then every pair of neighbour points is pulled back to the segment length a number of times (`iterations`). More passes make a stiffer rope.

- **Fixed step.** The simulation always advances in steps of 1/60 of a second, whatever the frame rate. Time beyond 4 steps in a single update is dropped, so a frame hitch never makes it snowball.
- **Sleep.** After 30 steps in a row with no point moving more than 0.02 pixels, the rope sleeps and `Update` returns `false` at no cost. Moving an anchor or changing a setting wakes it.
- **Coordinates.** Any 2D space. With frames, use pixels with y going up, so gravity is negative.

### Methods

| Method | Description |
|---|---|
| `Reset(startX, startY, endX, endY, controlX, controlY)` | Place every point at rest along a quadratic bezier. Pair with `GetRopeControlPoint` to start in the shape of a hanging rope. |
| `SetAnchors(startX, startY, endX, endY)` | Where the two ends are held. Wakes the rope if they moved. Call it every frame with the current positions. |
| `SetSegmentLength(segmentLength)` | Distance each pair of neighbour points keeps: rope length divided by `amountOfPoints - 1`. |
| `SetGravity(gravityX, gravityY)` | Pixels per second squared. Default `0, -1200`. |
| `SetDamping(damping)` | Fraction of the velocity kept each step. Default `0.98`. |
| `SetIterations(iterations)` | Passes per step. Default `20`. |
| `SetPinned(isStartPinned, isEndPinned)` | Which ends follow the anchors. A free end hangs. |
| `ApplyImpulse(impulseX, impulseY, variation)` | Push every point, in pixels per step. `variation` (`0` to `1`, default `0`) randomizes each push: strength by up to half, a lean that pushes one end harder than the other, and a sideways drift of up to half the push. |
| `Update(deltaTime)` | Advance the simulation. Returns `true` if it stepped. |
| `IsSleeping()` / `Wake()` | |
| `GetAmountOfPoints()` / `GetPoint(index)` | Read the points after `Update`. |

### Usage

```lua
local DF = DetailsFramework

local rope = DF.Physics.CreateRope(12)
local ropeLength = 300
local controlX, controlY = DF.Physics.GetRopeControlPoint(0, 0, 200, 0, ropeLength)
rope:Reset(0, 0, 200, 0, controlX, controlY)
rope:SetSegmentLength(ropeLength / 11)

frame:SetScript("OnUpdate", function(self, deltaTime)
	rope:SetAnchors(startX, startY, endX, endY)
	if (rope:Update(deltaTime)) then
		for i = 1, rope:GetAmountOfPoints() do
			local x, y = rope:GetPoint(i)
			--draw or place something at x, y
		end
	end
end)
```
