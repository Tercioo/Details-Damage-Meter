# Snap System

Implementation file: `frame_helpers.lua`

Window-snapping behavior between movable frames, similar to the snapping found in UI editors. Frames are registered into a *snap group*. While a registered frame is being dragged, its edges are continuously checked against every other frame in the same group; when two edges come within a configurable distance, a glow appears on both connecting edges as a live preview. Releasing the drag anchors the frames together (`ClearAllPoints` + `SetPoint`) into a persistent chain — dragging any member of that chain afterwards moves the whole cluster together.

Frames in *different* groups never interact. Each call to `CreateSnapGroup` returns an isolated instance, so an addon may create as many groups as it needs.

---

## Entry Points

### `detailsFramework:CreateSnapGroup(groupName, profileTable, options)`

Creates a new snap group.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `groupName` | `string` | Identifies the group; also the key under which the group stores its data inside `profileTable`. |
| `profileTable` | `table\|nil` | Saved-variables table for persistence. The group's snap data lives at `profileTable[groupName]`. Pass `nil` for an in-memory-only group. |
| `options` | `table\|nil` | Overrides merged on top of the defaults (see Options Table below). |

**Returns:** `snapgroup` — A new isolated snap group instance.

**Example — Two draggable frames snapping together:**
```lua
local DF = DetailsFramework

local snapGroup = DF:CreateSnapGroup("MyWindows", MyAddonDB.snap, {snap_distance = 14})

local function makeWindow(name)
    local frame = CreateFrame("frame", name, UIParent, "BackdropTemplate")
    frame:SetSize(200, 150)
    frame:SetPoint("center")
    frame:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]})
    DF:MakeDraggable(frame)        --frame must be draggable BEFORE registering
    snapGroup:RegisterFrame(frame)
    return frame
end

local windowA = makeWindow("MyAddonWindowA")
local windowB = makeWindow("MyAddonWindowB")
```

Drag `windowB` close to `windowA`'s right edge: both edges glow gold. Release inside the preview range to snap them together. Drag `windowA` afterwards and `windowB` follows.

---

## Instance Methods

All methods below are available on a `snapgroup` returned by `CreateSnapGroup`.

### `snapGroup:RegisterFrame(frame[, id])`

Registers a frame into the group. The frame must already be set up for dragging (`SetMovable`, `EnableMouse`, `RegisterForDrag`, and an `OnDragStart` that calls `StartMoving` — `detailsFramework:MakeDraggable(frame)` does all of this). Its existing `OnDragStart`/`OnDragStop` scripts are *wrapped*, not replaced.

| Parameter | Type | Description |
|---|---|---|
| `frame` | `frame` | The frame (or a DetailsFramework widget with a `.widget` field) to register. |
| `id` | `string\|nil` | Stable identifier used for persistence. Required only when the frame has no name; if both a name and an `id` are present, the name wins. |

If the frame has no name and no `id` is provided, an assertion fires. If the frame is not movable, a warning is printed (snapping requires drag scripts to fire).

After registration, the group automatically attempts to restore any saved snap relationships involving this frame from `profileTable`, so registration order does not matter.

### `snapGroup:UnregisterFrame(frame)`

Removes a frame from the group: cuts all of its snap links, restores its original `OnDragStart`/`OnDragStop` scripts, and hides any leftover glow textures. The rest of its former cluster stays intact (each former neighbour becomes the root of whatever remains of its sub-cluster).

### `snapGroup:Unsnap(frame)`

Breaks every snap link of `frame`, leaving it free-standing at its current on-screen position. The frame stays registered in the group and can be re-snapped by dragging it again. This is the **only** way (besides `UnregisterFrame` / `Reset`) to detach a snapped frame — snap links never break implicitly during a drag.

### `snapGroup:SetProfileTable(newTable)`

Swaps the group's profile table at runtime and re-runs `TryRestore` against the new table. Use this when the addon switches between profiles that should share the same frame registrations.

### `snapGroup:SetOptionsTable(newOptionsTable)`

Replaces the group's options. The new table is merged on top of the snap defaults, so partial tables are valid.

### `snapGroup:Reset()`

Tears the group down to a blank, reusable state:
- every registered frame is unregistered (drag scripts restored, links cut, glow hidden);
- `profileTable` and `options` references are dropped (options are restored to the defaults);
- the current snap preview is cleared.

The data already written into the old profile table is **left untouched** — the caller owns that table. After `Reset`, the same `snapgroup` instance can be repopulated by calling `SetProfileTable`, `SetOptionsTable` and `RegisterFrame` again, which is what makes it appropriate for addon profile switches.

### `snapGroup:TryRestore()`

Recreates snap links and re-anchors cluster roots from the current `profileTable`. Safe to call repeatedly: links are only created when both frames involved are currently registered. `RegisterFrame` calls this automatically, but the addon may also call it explicitly once all of its frames have finished registering, for example after a delayed UI build.

### `snapGroup:Snap(frameData, candidate)` *(internal)*

Anchors `frameData` to a previewed candidate, merging the two clusters into one chain. Called by the wrapped `OnDragStop` when a valid preview exists on drop. Documented here because it appears as a method on the mixin; addons should not call it directly.

### `snapGroup:RemoveLink(frameData, side)` *(internal)*

Removes a single directed link (and its reciprocal on the other frame) on the given side. Returns the `snapframedata` of the frame that was on the other end of the removed link, or `nil` when there was no link. Use `Unsnap` from external code instead.

### `snapGroup:SavePersistent()` *(internal)*

Writes the group's current link graph and cluster-root positions into `profileTable[groupName]`. Called automatically after every structural change (snap, unsnap, register, unregister). No-op when the group has no profile table.

---

## Options Table

Used with `CreateSnapGroup` (and `SetOptionsTable`). Any field not provided falls back to the default value. Keys use `snake_case` because the table is exposed to the addon profile as user configuration.

| Key | Type | Default | Description |
|---|---|---|---|
| `snap_distance` | `number` | `12` | Maximum screen-pixel gap between two edges for them to be considered a snap candidate. |
| `hysteresis` | `number` | `4` | A different candidate must be at least this many pixels closer than the currently previewed one to replace it. Prevents jitter when the cursor hovers between two edges. |
| `update_interval` | `number` | `0.015` | Seconds between proximity scans while a drag is active. Lower is more responsive but more CPU. |
| `glow_thickness` | `number` | `3` | Thickness (in pixels) of the edge highlight texture. |
| `glow_color` | `table` | `{1, 0.82, 0, 0.9}` | Edge highlight color as `{r, g, b, a}`. |
| `enabled_sides` | `table` | `{left=true, right=true, top=true, bottom=true}` | Which dragged-frame sides are allowed to snap. Disable individual sides to constrain how frames may attach. |

---

## Side Pairings

Sides are stored lowercase (`"left"`, `"right"`, `"top"`, `"bottom"`) so they can be passed straight to `frame:SetPoint` without conversion. The connecting axis is implicit:

| Dragged side | Target side | Connecting axis |
|---|---|---|
| `"left"` | `"right"` | x (horizontal touch) |
| `"right"` | `"left"` | x (horizontal touch) |
| `"top"` | `"bottom"` | y (vertical touch) |
| `"bottom"` | `"top"` | y (vertical touch) |

A snap pins the dragged frame at the midpoint of its connecting side **and** explicitly matches its perpendicular dimension to the target's. The dragged frame stretches (or shrinks) so its height (for left/right snaps) or width (for top/bottom snaps) equals the target's. For a `right ↔ left` snap (dragged frame's right side meeting the target's left side):

```lua
draggedFrame:SetHeight(targetFrame:GetHeight())            -- match perpendicular dimension
draggedFrame:SetPoint("right", targetFrame, "left", 0, 0)  -- single midpoint anchor
```

Because the heights are equal and the anchor is at the vertical midpoint, the top and bottom edges line up flush automatically — you get the "two-anchor flush" visual using only one anchor, which is what keeps cluster drag through `StartMoving` reliable (multi-anchor children don't propagate during a StartMoving drag).

The dragged frame's original size is captured the first time it snaps (and persisted across `/reload`); `Unsnap` / `UnregisterFrame` / `Reset` restore it.

---

## Persisted Format

When a `profileTable` is supplied, the group writes its data to `profileTable[groupName]`. The structure is documented here so the addon may inspect, migrate or hand-edit it if needed (but typically the addon never touches it directly):

```lua
profileTable[groupName] = {
    [frameId] = {
        --present only when this frame is the root of its cluster
        point = {x = number, y = number},   --absolute position in UIParent coordinate space

        --present only for frames that have been snapped at least once; restored by Unsnap
        originalWidth = number,             --pre-snap width captured the first time the frame snapped
        originalHeight = number,            --pre-snap height captured the first time the frame snapped

        --directed snap links emitted by this frame
        links = {
            [side] = {
                targetId = string,              --id of the frame on the other end
                mySide = string,                --this frame's side ("left"/"right"/"top"/"bottom")
                theirSide = string,             --target frame's side
                offsetX = number,               --SetPoint offset, always 0 (kept for forward compatibility)
                offsetY = number,               --SetPoint offset, always 0
            },
            ...
        },
    },
    ...
}
```

Each link is stored in both directions (once on each frame). Offsets are always `0` because the perpendicular-dimension SetSize match takes care of the alignment. `Reset` does **not** wipe this table — it only drops the group's reference to it.

---

## How It Works

1. **Registration** — `RegisterFrame` wraps the frame's existing `OnDragStart`/`OnDragStop` scripts so the group can observe every drag without replacing the addon's own drag logic.
2. **Proximity scan** — While a drag is in progress, a dedicated per-group `UpdateFrame` runs `OnUpdate` throttled by `options.update_interval`. Each tick, every other frame in the group is evaluated against the dragged frame using simple O(1) edge-distance math. All measurements are converted to screen pixels via `GetEffectiveScale()`, so frames living under parents with different scales still compare correctly. Pairings where either frame's connecting side is already occupied by an existing snap link are skipped — that way the scanner never suggests a snap that would overlap a frame already chained on the same edge. Candidates within the primary `snap_distance` are ranked by `primary_gap + perpendicular_center_misalignment` (lower is better), so when two targets share the same connecting edge (e.g. two size-matched frames already snapped side by side), the dragged frame snaps to whichever one its perpendicular center is closer to.
3. **Preview** — When a candidate is found, two thin colored textures are positioned on the connecting edges of both frames. The preview stays on the same candidate from frame to frame unless another pairing becomes meaningfully closer (`options.hysteresis`), avoiding flicker. When no candidate exists, the glow is cleared immediately.
4. **Drop** — On `OnDragStop` with an active preview, the dragged frame's perpendicular dimension is matched to the target's via `SetHeight` (for left/right snaps) or `SetWidth` (for top/bottom snaps), and it is anchored at the midpoint of its connecting side via a single `SetPoint` with zero offset. The connecting edges line up flush at both ends. The dragged frame's pre-snap size is captured into its `frameData` (and persisted) so `Unsnap` can restore it later.
5. **Clusters** — A cluster is the connected component of frames joined by snap links, viewed as a spanning tree rooted at the one member anchored to `UIParent`. When a member is dragged, that member is temporarily promoted to the root for the duration of the drag, so the whole cluster follows the cursor through Blizzard's `StartMoving` and single-point anchor propagation. On drop the cluster is rebuilt; links that would close a cycle are ignored for anchoring, which guarantees there are never recursive or broken point chains.
6. **Persistence** — After any structural change (snap, unsnap, register, unregister) the group writes its link graph and root positions to `profileTable[groupName]`. `TryRestore` runs after every `RegisterFrame` and idempotently creates links whose two frames are both currently registered, so the saved layout reassembles correctly regardless of registration order.

---

## Performance Notes

- Proximity scans run **only while a drag is active** and are throttled by `options.update_interval` — there is zero cost when no frame is being dragged.
- Each scan iterates only the frames registered in the same group, never a full-screen sweep. Splitting frames into several smaller groups further cuts the cost.
- Edge math uses simple O(1) distance and overlap comparisons; no allocations occur in the hot path beyond a single reused candidate table.
- Hysteresis keeps the chosen candidate stable, avoiding repeated glow texture re-anchoring while the cursor hovers between two edges.
- For very large groups, a spatial bucket / grid index over frame centers could replace the linear scan in the candidate-finder without changing the public API.

---

## Extensibility

The architecture is built so the snapping vocabulary can grow without disturbing existing behavior:

- **Corner snapping** — Add diagonal pairings (e.g. `topleft ↔ topleft`) to `SNAP_OPPOSITE` and `SNAP_AXIS`, plus a matching branch in the edge evaluator. The preview, anchor and persistence pipeline is already generic over side names.
- **Grid snapping** — Add an optional virtual grid target to the candidate finder (snap edges to the nearest grid line when no frame candidate is closer); a grid hit can be anchored by treating the grid line as a synthetic target side and reusing the two-point anchor helper.
- **Single-point (midpoint) anchoring** — Today every side snap stretches the dragged frame's perpendicular dimension to match the target. An alternate code path in `snapApplyTwoPointAnchor`, guarded by a new option flag, could fall back to a single-point anchor that preserves the dragged frame's original size at the cost of edge alignment.
