# Snap System

Implementation file: `frame_helpers.lua`

Window-snapping behavior between movable frames, similar to the snapping found in UI editors. Frames are registered into a *snap group*. While a registered frame is being dragged, its edges are continuously checked against every other frame in the same group; when two edges come within a configurable distance, a glow appears on both connecting edges as a live preview. Releasing the drag anchors the frames together (`ClearAllPoints` + `SetPoint`) into a persistent chain — dragging any member of that chain afterwards moves the whole cluster together.

Frames in *different* groups never interact. Each call to `CreateSnapGroup` returns an isolated instance, so an addon may create as many groups as it needs.

Terms: a **group** is the registry of frames that may snap to each other; a **cluster** is a set of frames already snapped together inside a group. Clusters are trees: a frame never snaps onto a frame of its own cluster, so links never form a loop.

---

## Entry Points

### `detailsFramework:CreateSnapGroup(groupName, profileTable, options)`

Creates a new snap group.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `groupName` | `string` | Identifies the group; also the key under which the group stores its data inside `profileTable`. |
| `profileTable` | `table\|nil` | Saved-variables table for persistence. The group's snap data lives at `profileTable[groupName]`. Pass `nil` for an in-memory-only group (the addon then keeps its own layout data and uses `Link`/`GetLinks`). |
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

**Example — Frames moved from mouse handlers, with a title bar drawn outside the frame:**
```lua
local snapGroup = DF:CreateSnapGroup("MyWindows", nil, {space_between_horizontal = 2})

snapGroup:RegisterFrame(window, "window1", {
    wrap_drag_scripts = false,
    GetInsets = function(frame) return 0, 0, 20, 0 end, --left, right, top, bottom
    GlowParent = window.overlayFrame,
})

titleBar:SetScript("OnMouseDown", function() snapGroup:StartDrag(window) end)
titleBar:SetScript("OnMouseUp", function() snapGroup:StopDrag(window) end)
```

---

## Instance Methods

All methods below are available on a `snapgroup` returned by `CreateSnapGroup`.

### `snapGroup:RegisterFrame(frame[, id[, frameOptions]])`

Registers a frame into the group. By default the frame must already be set up for dragging (`SetMovable`, `EnableMouse`, `RegisterForDrag`, and an `OnDragStart` that calls `StartMoving` — `detailsFramework:MakeDraggable(frame)` does all of this); its existing `OnDragStart`/`OnDragStop` scripts are *wrapped*, not replaced.

| Parameter | Type | Description |
|---|---|---|
| `frame` | `frame` | The frame (or a DetailsFramework widget with a `.widget` field) to register. |
| `id` | `string\|nil` | Stable identifier used for persistence. When given it wins over the frame name; required when the frame has no name. |
| `frameOptions` | `table\|nil` | Per-frame settings, see below. |

`frameOptions`:

| Key | Type | Description |
|---|---|---|
| `wrap_drag_scripts` | `boolean` | `false`: the drag scripts are left alone; the addon calls `StartDrag`/`StopDrag` from its own scripts. Default `true`. |
| `GetInsets` | `function(frame)` | Returns `left, right, top, bottom`: how far the frame's visible area reaches past its rect, in the frame's own units (title bars, status bars). Detection, glow, anchor offsets and size matching all use the outer rect. Called each time it is needed, so it can follow settings. |
| `GlowParent` | `frame` | Frame the preview glow textures are created on, so the glow draws above the frame's own content. Defaults to the frame. |

If the frame has no name and no `id` is provided, an assertion fires. If the frame is not movable, a warning is printed.

Size hooks are installed once per frame for the life of the group; unregistering and registering the same frame again does not add more hooks.

After registration, the group attempts to restore any saved snap relationships involving this frame from `profileTable`, so registration order does not matter.

### `snapGroup:UnregisterFrame(frame)`

Removes a frame from the group: cancels its drag if it is being dragged, cuts all of its snap links, restores its original `OnDragStart`/`OnDragStop` scripts (when they were wrapped), and hides any leftover glow textures. The rest of its former cluster stays intact.

### `snapGroup:IsRegistered(frame)` / `snapGroup:IsDragging()`

`true` when the frame is in the group / while a frame of the group is being dragged.

### `snapGroup:StartDrag(frame)` / `snapGroup:StopDrag(frame)`

Start and end a drag as if the frame's `OnDragStart`/`OnDragStop` had fired: the frame (and its cluster) moves with the cursor, the preview runs, and the previewed snap is applied on stop. A second start while dragging and a stop for a frame that is not being dragged are ignored. Return `false` when the frame is not registered.

### `snapGroup:CancelDrag()`

Ends the current drag without snapping. Called automatically when the dragged frame is hidden or unregistered; `options.on_drag_cancelled` is then called so the addon can clear its own moving state.

### `snapGroup:Link(frame, side, targetFrame)`

Snaps two registered frames without a drag: `frame`'s `side` touches `targetFrame`'s opposite side. The target's cluster keeps its place, `frame`'s cluster moves next to it. Returns `false` (and does nothing) when a frame is not registered, a side is already taken, or both frames are already in the same cluster. Returns `true` when the link exists afterwards.

### `snapGroup:Unlink(frame, side)`

Removes the link on one side of a frame (both directions). Each side of the cut keeps its own cluster where it is. Returns `false` when there was no link on that side.

### `snapGroup:Unsnap(frame)`

Breaks every snap link of `frame`, leaving it free-standing at its current on-screen position. The frame stays registered and can be re-snapped by dragging it again. Snap links never break implicitly during a drag.

### `snapGroup:GetLinks(frame)` / `snapGroup:GetCluster(frame)` / `snapGroup:GetAxisCluster(frame, axis)`

- `GetLinks` returns `{[side] = otherFrame}` for the frame's links.
- `GetCluster` returns every frame of the frame's cluster, the frame included.
- `GetAxisCluster` returns the frames reachable through links of one axis: `"x"` gives the frames side by side with it (they share their outer height), `"y"` the frames stacked with it (they share their outer width).

### `snapGroup:RefreshCluster(frame)` / `snapGroup:RefreshAllClusters()`

`RefreshCluster(frame)` makes the frame the root of its cluster at its current place and re-chains the other members from it. Use it after the addon positioned the frame by itself or before resizing it with `StartSizing`. `RefreshCluster(frame, true)` re-chains the cluster from the root it already has; use it after the frame's insets or scale changed.

A root that is anchored to the screen (every anchor on `UIParent`) keeps its own anchor, e.g. a `topright` anchor placed by the addon; only a root anchored to another frame is re-pinned with a `bottomleft` offset. This keeps clusters in place when the ui scale or the screen size changes after login. `RefreshAllClusters` re-chains every cluster from its current root.

### `snapGroup:BeginBatch()` / `snapGroup:EndBatch()`

Until the last open batch ends, size changes are not propagated through clusters and `on_links_changed` is held. When the batch ends, every cluster is re-chained once and a held notification is sent once. Use it while restoring a layout or resizing many frames by hand.

### `snapGroup:SetProfileTable(newTable)`

Swaps the group's profile table at runtime: the links of the old table are dropped (frames stay where they are, the old table is not written) and the new table's links are restored.

### `snapGroup:SetOptionsTable(newOptionsTable)`

Replaces the group's options. The new table is merged on top of the snap defaults, so partial tables are valid. A running preview is cleared when the new options forbid snapping.

### `snapGroup:Reset()`

Tears the group down to a blank, reusable state: the profile reference is dropped *first* (so the old saved data is not overwritten while frames are unsnapped), every frame is unregistered, options are restored to the defaults and the preview is cleared. The data already written into the old profile table is left untouched.

### `snapGroup:TryRestore()`

Recreates snap links and re-anchors cluster roots from the current `profileTable`. Safe to call repeatedly: links are only created when both frames are registered. Saved links are validated: unknown sides, links to the frame itself, links whose side is taken by another frame, and links that would close a loop are skipped.

### Internal methods

`Snap`, `RemoveLink`, `SavePersistent`, `NotifyLinksChanged`, `OnFrameDragStart`, `OnFrameDragStop`, `OnDragUpdate` appear on the mixin but are internal. `SavePersistent` runs after drops, `Link`, `Unlink`, `Unsnap` and cancelled drags (not after `RegisterFrame`).

---

## Options Table

Used with `CreateSnapGroup` (and `SetOptionsTable`). Any field not provided falls back to the default value. Keys use `snake_case` because the table is exposed to the addon profile as user configuration.

| Key | Type | Default | Description |
|---|---|---|---|
| `snap_distance` | `number` | `12` | Maximum screen-pixel gap between two edges for them to be considered a snap candidate. `0` or less disables new snaps. |
| `hysteresis` | `number` | `4` | A different candidate must be at least this many pixels closer than the currently previewed one to replace it. |
| `update_interval` | `number` | `0.015` | Seconds between proximity scans while a drag is active. |
| `glow_thickness` | `number` | `3` | Thickness (in pixels) of the edge highlight texture. |
| `glow_color` | `table` | `{1, 0.82, 0, 0.9}` | Edge highlight color as `{r, g, b, a}`. |
| `enabled_sides` | `table` | `{left=true, right=true, top=true, bottom=true}` | Which dragged-frame sides are allowed to snap. Replaces the whole table when given. |
| `allow_new_snaps` | `boolean` | `true` | `false` stops new snaps (exact edge contact included) while existing clusters keep moving together. |
| `space_between_horizontal` | `number` | `0` | UIParent units left empty between two frames snapped side by side. |
| `space_between_vertical` | `number` | `0` | UIParent units left empty between two frames snapped on top of each other. |
| `restore_size_on_unsnap` | `boolean` | `true` | Unsnapping gives a frame back the size it had before its first snap. |
| `clamp_cluster` | `boolean` | `true` | While a frame clamped to the screen is dragged, its clamp rect covers its whole cluster (outer rects included); the frame's own clamp insets are given back on drop. |
| `on_links_changed` | `function(snapGroup)` | `nil` | Called after links are created or removed (drop, `Link`, `Unlink`, `Unsnap`, `SetProfileTable`). Held during batches. |
| `on_drag_cancelled` | `function(snapGroup, frame)` | `nil` | Called when a drag ends without `StopDrag` (the dragged frame was hidden or unregistered). |

---

## Side Pairings

Sides are stored lowercase (`"left"`, `"right"`, `"top"`, `"bottom"`) so they can be passed straight to `frame:SetPoint` without conversion. The connecting axis is implicit:

| Dragged side | Target side | Connecting axis |
|---|---|---|
| `"left"` | `"right"` | x (horizontal touch) |
| `"right"` | `"left"` | x (horizontal touch) |
| `"top"` | `"bottom"` | y (vertical touch) |
| `"bottom"` | `"top"` | y (vertical touch) |

A snap pins the dragged frame at the midpoint of its connecting side with a single `SetPoint`, plus an explicit `SetHeight`/`SetWidth` that matches its **outer** perpendicular size (frame size plus insets) to the target's, computed in screen pixels so frames with different scales match on screen. The `SetPoint` offsets carry the insets of both frames and the configured space between them; with no insets and no space this is:

```lua
draggedFrame:SetHeight(targetFrame:GetHeight())
draggedFrame:SetPoint("right", targetFrame, "left", 0, 0)
```

Single-anchor children are what makes `StartMoving` cluster drag work reliably; two-anchor children fail to propagate during a `StartMoving` drag.

**Resize propagation** doesn't rely on anchor resolution. `RegisterFrame` installs four hooks on each frame (once per frame for the life of the group):

- `HookScript("OnSizeChanged", …)` — catches the event next render frame.
- `hooksecurefunc(frame, "SetSize"/"SetHeight"/"SetWidth", …)` — fires synchronously inside the resize call and can't be removed.

All four feed into the same handler, which skips work when the frame's size is what the snap system last saw, and while the snap system itself is changing links, anchors or sizes (size events can fire synchronously in the middle of that work, even from reading a size, and reacting then would anchor frames in a loop). The handler:

1. **Gives the resized frame's outer size to the frames sharing an axis with it**: the frames reachable through x-axis links take its outer height, the frames reachable through y-axis links take its outer width. This is computed from the resized frame itself, so a resize anywhere in a cluster sticks, even on a branch whose axis does not reach the cluster root.
2. **Re-applies the snap chain** from the root (the root itself is not re-anchored, so a root being sized with `StartSizing` is not disturbed). Anchors the owning addon may have wiped during its own resize logic are restored every time.

Make the frame being resized the root first (`RefreshCluster(frame)`) when resizing with `StartSizing`.

When `restore_size_on_unsnap` is on, the dragged frame's original size is captured the first time it snaps (and persisted across `/reload`); `Unsnap` / `Unlink` / `UnregisterFrame` restore it, also for a frame that becomes solo as a side effect.

---

## Persisted Format

When a `profileTable` is supplied, the group writes its data to `profileTable[groupName]`:

```lua
profileTable[groupName] = {
    [frameId] = {
        --present only when this frame is the root of its cluster
        point = {x = number, y = number},   --absolute position in UIParent coordinate space

        --present only for frames that have been snapped at least once; restored by Unsnap
        originalWidth = number,
        originalHeight = number,

        --directed snap links emitted by this frame
        links = {
            [side] = {
                targetId = string,              --id of the frame on the other end
                mySide = string,                --this frame's side ("left"/"right"/"top"/"bottom")
                theirSide = string,             --target frame's side
                offsetX = number,               --always 0, offsets are computed from insets when anchoring
                offsetY = number,               --always 0
            },
            ...
        },
    },
    ...
}
```

Each link is stored in both directions (once on each frame). Current frame sizes are not stored; the addon keeps its own. `Reset` does **not** wipe this table.

---

## How It Works

1. **Registration** — `RegisterFrame` wraps the frame's drag scripts (or leaves them alone with `wrap_drag_scripts = false`) and installs the size hooks.
2. **Proximity scan** — While a drag is in progress, a dedicated per-group `UpdateFrame` runs `OnUpdate` throttled by `options.update_interval`. Each tick, every other visible frame in the group is evaluated against the dragged frame, using outer rects converted to screen pixels. Only the grabbed frame's edges are tested. Pairings where either frame's connecting side is already taken are skipped. Candidates are ranked by `edge gap + perpendicular center misalignment`.
3. **Preview** — Two thin colored textures are positioned on the connecting outer edges of both frames. The previewed pairing is re-scored every tick: it is dropped as soon as it goes out of range, and replaced only when another pairing is closer by more than `options.hysteresis`.
4. **Drop** — The previewed pairing is checked once more at the drop spot; if still valid, the link is added and the merged cluster is rebuilt from the target's root.
5. **Clusters** — A cluster is a spanning tree rooted at the one member anchored to `UIParent`. When a member is grabbed, the cluster is re-rooted on it so the whole tree follows through `StartMoving` anchor propagation, and its clamp rect is extended over the whole cluster.
6. **Live resize propagation** — see Side Pairings above.
7. **Persistence** — After drops, links, unlinks and unsnaps the group writes its link graph and root positions to `profileTable[groupName]`. `TryRestore` runs after every `RegisterFrame` and idempotently creates validated links whose two frames are both registered.

---

## Performance Notes

- Proximity scans run **only while a drag is active** and are throttled by `options.update_interval`.
- Each scan iterates only the frames registered in the same group.
- Edge math uses simple O(1) distance and overlap comparisons.
- Hysteresis keeps the chosen candidate stable, avoiding repeated glow re-anchoring.
- Size hooks skip work when nothing changed, and batches suspend propagation during bulk changes.
- For very large groups, a spatial bucket / grid index over frame centers could replace the linear scan without changing the public API.

---

## Extensibility

- **Corner snapping** — Add diagonal pairings (e.g. `topleft ↔ topleft`) to `SNAP_OPPOSITE` and `SNAP_AXIS`, plus a matching branch in the edge evaluator.
- **Grid snapping** — Add an optional virtual grid target to the candidate finder; a grid hit can reuse the anchor offset helper.
