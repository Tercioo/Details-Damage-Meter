# Anchor System
 
This document explains the `anchorsystem` object defined in `anchorsystem.lua`.
It is an object-oriented system for creating independent anchor managers that position, order, and control pooled frames on screen.
 
## What is the Anchor System?
 
The anchor system is a reusable object that lets you create and manage one or more groups of anchored frames.
Each anchor system instance owns its own state, including:
- anchor frame definitions
- anchor frame positions
- frame pools for each anchor
- pointer to profile storage for persistable positions
 
The intended use is for UI elements that need to be displayed in ordered stacks around screen anchors and optionally moved by the user.
This is useful for timers, buff displays, notifications, or any UI component that should attach to a named anchor.
 
## Why use an anchor system object?
 
The system is built as a factory so you can create multiple independent anchor systems without shared state.
That means multiple UI modules can each own their own anchors and frame pools without interfering with one another.
 
The object also centralizes anchor behavior:
- position persistence via a profile table
- unlock/lock dragging behavior for all anchors
- ordered layout of pooled frames
- release/hide routines across all anchors
 
### Multiple independent instances
 
Each call to `detailsFramework:CreateAnchorSystem()` returns a completely isolated instance:
 
```lua
-- Module A: damage display
local damageAnchors = detailsFramework:CreateAnchorSystem()
damageAnchors:SetProfileTable(MyProfile.damageAnchors)
damageAnchors:CreateScreenAnchor({
    anchorKey = "damage",
    frameName = "DamagePivot",
    growDirection = "bottom",
    setupFunction = mySetupFunc,
    sortFunction = mySortFunc,
    frameCreateFunction = myCreateFunc
})
 
-- Module B: healing display
local healingAnchors = detailsFramework:CreateAnchorSystem()
healingAnchors:SetProfileTable(MyProfile.healingAnchors)
healingAnchors:CreateScreenAnchor({
    anchorKey = "healing",
    frameName = "HealingPivot",
    growDirection = "right",
    setupFunction = mySetupFunc,
    sortFunction = mySortFunc,
    frameCreateFunction = myCreateFunc
})
 
-- These two systems do not share frames, anchors, or lock state
```
 
## Creating and using an anchor system
 
Create a new instance using:
 
```lua
local anchorSystem = detailsFramework:CreateAnchorSystem()
```
 
Then configure it:
 
```lua
anchorSystem:SetProfileTable(myProfile.anchorPositions)
```
 
After that, create anchors with `CreateScreenAnchor`.
 
### State management
 
The anchor system tracks whether anchors are locked or unlocked via the `locked` field:
- `UnlockAnchors()` sets `locked = false` and enables drag behavior
- `LockAnchors()` sets `locked = true` and disables drag behavior
- `lineSpacing` is a system-wide spacing value used by `Reorder()` for all anchors (default `1`)
 
## Core methods
 
### `CreateAnchorSystem()`
 
Creates and returns a new `anchorsystem` instance.
Each returned object has isolated state:
- `locked`
- `profileTable`
- `screenAnchors`
 
Example:
 
```lua
local anchorSystem = detailsFramework:CreateAnchorSystem()
anchorSystem:SetProfileTable(MyProfile.anchorPositions)
```
 
### `SetProfileTable(profileTable)`
 
Sets the table used to store anchor positions.
The anchor system reads and writes anchor positions here when anchors are moved.
 
Use this before creating anchors if you want position persistence.
The profile table structure is automatically managed by the anchor system—you do not need to pre-populate it.
 
### `SavePosition(anchorFrame)`
 
Saves an individual anchor frame position into `self.profileTable`.
It converts the frame position into normalized coordinates relative to `UIParent`.
 
This method is used internally when anchors are dragged and released.
 
### `RestorePosition(anchorFrame)`
 
Restores an anchor frame position from `self.profileTable`.
It computes a new position based on the current `UIParent` size and applies it to the anchor frame.
 
If no entry exists in the profile for the anchor, the frame is centered on screen instead.
 
Note: This is called automatically by `CreateScreenAnchor`. If no profile entry exists yet, the anchor will be positioned at screen center and will be saved there when first moved.
 
### `UnlockAnchors()`
 
Allows all anchors managed by this instance to be moved.
It enables mouse input, sets anchors movable, and installs drag scripts.
When dragging stops, the anchor's new position is saved automatically.
 
### `LockAnchors()`
 
Disables movement on all managed anchors.
It removes drag scripts and hides the drag preview texture.
 
### `CreateScreenAnchor(options)`
 
Creates a new screen anchor and registers it with the anchor system.
 
**Parameters:**
- `options`: an [`anchor_options`](#anchor_options-table) table containing all configuration for the anchor
 
The returned anchor frame is also stored in `self.screenAnchors`.
 
#### `anchor_options` Table
 
The `options` parameter is a table with the following fields:
 
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `anchorKey` | string | Yes | Unique key used to identify this anchor in the profile table |
| `frameName` | string | Yes | The frame name passed to `CreateFrame` |
| `growDirection` | string | Yes | The direction frames grow from the anchor ("top", "bottom", "left", "right") |
| `setupFunction` | function | Yes | Called for each frame when it is acquired from the pool |
| `sortFunction` | function | Yes | Used to order frames inside this anchor |
| `frameCreateFunction` | function | Yes | Factory used by the frame pool to create new child frames |
| `anchorLabel` | string | No | Text to display on the anchor when unlocked (defaults to `anchorKey`) |
 
**Example:**
```lua
anchorSystem:CreateScreenAnchor({
    anchorKey = "damage",
    frameName = "DamageAnchor",
    growDirection = "bottom",
    setupFunction = setupDamageFrame,
    sortFunction = sortByTimestamp,
    frameCreateFunction = createDamageFrame,
    anchorLabel = "Damage"  -- optional
})
```
 
#### Grow Direction Behavior
 
The grow direction determines how frames stack relative to the anchor:
- `"top"`: Frames grow upward from the anchor center
- `"bottom"`: Frames grow downward from the anchor center
- `"left"`: Frames grow leftward from the anchor center
- `"right"`: Frames grow rightward from the anchor center
 
### `GetScreenAnchor(anchorName)`
 
Returns the anchor frame with the given `anchorName` from this anchor system.
If no anchor exists for that name, the method returns `nil`.
 
### `SetLineSpacing(spacing)`
 
Sets the system-wide spacing used when reordering frames across all anchors managed by this anchor system.
This replaces per-anchor spacing and affects every anchor in the system immediately when reordering occurs.
 
Parameters:
- `spacing`: the spacing between frames when `Reorder()` positions them.
### `SetGrowDirection(anchorName, growDirection)`
 
Sets the grow direction for a specific anchor and immediately reorders its frames.
This allows you to dynamically change how frames stack from an anchor without recreating it.
 
Parameters:
- `anchorName`: the name of the anchor whose grow direction to change.
- `growDirection`: the new direction ("top", "bottom", "left", "right").
 
Example:
 
```lua
-- Initially frames grow downward from the anchor
anchorSystem:CreateScreenAnchor({
    anchorKey = "buffs",
    frameName = "BuffAnchor",
    growDirection = "bottom",
    setupFunction = setupFunc,
    sortFunction = sortFunc,
    frameCreateFunction = createFunc
})
 
-- Later, change to growing upward
anchorSystem:SetGrowDirection("buffs", "top")
```
 
### `HideAll()`
 
 
Hides and releases all pooled frames from all anchors managed by this object.
 
### `Reorder(anchorFrame)`
 
Reorders pooled frames inside the given anchor frame.
It uses the anchor's sort function and then sets each frame position in a stacked layout based on the grow direction.
 
#### Positioning logic
 
**First frame** (no previous frame):
- Attaches to the center of the anchor frame in the grow direction
 
**Subsequent frames**:
- Attach to the previous frame in the grow direction
- Spacing is taken from the anchor system's `lineSpacing` value (default `1`)
 
### `ShowFrame(anchorName, ...)`
 
Acquires a frame from the pool for the specified anchor and calls the anchor's `setupFunction`.
All additional arguments are forwarded to the setup function.
 
Returns the acquired frame.
 
Example:
 
```lua
anchorSystem:ShowFrame("buffAnchor", cooldown, spellId, owner)
```
 
The anchor's `setupFunction` should accept:
- the anchor frame
- the pooled frame
- any extra arguments passed via `...`
**Frame Parenting**: Each acquired frame is automatically parented to the anchor frame. You can change the parent in your setup function if needed using `frame:SetParent(newParent)`.
After setup, the frame is automatically positioned and reordered on the anchor.
 
### `HideFrame(frame)`
 
Searches all anchors for the given frame and releases it back to its pool.
If found, it also reorders the anchor.
 
The frame is not destroyed—it is returned to the frame pool for reuse when `ShowFrame` is called again.
 
Frames are compared by object identity, so you must pass the exact frame object returned by `ShowFrame`.
 
## Example usage
 
### Basic Setup
 
```lua
local anchorSystem = detailsFramework:CreateAnchorSystem()
anchorSystem:SetProfileTable(MyProfile.anchorPositions)
 
local function createBuffFrame(parent)
    local f = CreateFrame("frame", nil, parent)
    f:SetSize(180, 22)
    return f
end
 
local function setupBuffFrame(anchorFrame, frame, buffData)
    frame.buffData = buffData
    frame.text = frame.text or frame:CreateFontString(nil, "overlay", "GameFontNormal")
    frame.text:SetPoint("left", frame, "left", 4, 0)
    frame.text:SetText(buffData.name)
    frame:Show()
end

local function sortBuffs(a, b)
    return a.buffData.expirationTime < b.buffData.expirationTime
end
 
anchorSystem:CreateScreenAnchor({
    anchorKey = "buffAnchor",
    frameName = "DetailsBuffAnchor",
    growDirection = "bottom",
    setupFunction = setupBuffFrame,
    sortFunction = sortBuffs,
    frameCreateFunction = createBuffFrame
})
 
-- later...
local frame = anchorSystem:ShowFrame("buffAnchor", buffData)
 
-- hide it later
anchorSystem:HideFrame(frame)
```
 
### Frame Lifecycle
 
1. **Creation**: The first time `ShowFrame` is called for an anchor, the frame pool creates a frame using `frameCreateFunction`.
2. **Acquisition**: Each subsequent `ShowFrame` reuses frames from the pool. If no unused frames exist, a new one is created.
3. **Setup**: The anchor's `setupFunction` is called to configure the frame with user data.
4. **Layout**: The anchor reorders all visible frames, positioning them in a stack.
5. **Release**: When `HideFrame` is called, the frame is released back to the pool. Its `StopTimer` and `Hide` callbacks are invoked.
6. **Reuse**: The released frame can be acquired again by a future `ShowFrame` call.
 
This pooling system avoids frame creation overhead and keeps memory usage constant.
 
## When to use this system
 
Use the anchor system when you need:
- ordered stacks of frames attached to named screen positions
- frame pooling for reuse instead of recreating frames
- movable anchors with position persistence
- multiple independent anchor sets in the same add-on
 
If your UI only needs a single static frame, this object-based anchor system may be more than necessary. It is most valuable when you need flexible, reusable anchor groups with pooled content.
 
## Important Implementation Details
 
### Frame Creation and Parenting
 
Frames created by your `frameCreateFunction` should be plain frames. They will be automatically parented to the anchor frame when acquired via `ShowFrame`.
 
If you need a different parent, you can change it in your setup function:
 
```lua
function setupMyFrame(anchorFrame, frame, data)
    frame.data = data
    frame:SetText(data.name)
    
    -- Optional: change parent if needed
    -- frame:SetParent(someOtherFrame)
    
    frame:Show()
end
```
 
### Sort Functions
 
The sort function receives two frames and should return `true` if the first frame should appear before the second in layout order (top to bottom).
 
Example: Sort by expiration time (earliest expiration first):
 
```lua
function sortByExpiration(frameA, frameB)
    return frameA.data.expirationTime < frameB.data.expirationTime
end
```
 
### Profile Table Structure
 
The anchor system automatically manages the profile table. Each anchor key stores:
 
```lua
{
    leftPercent = <0-1>,      -- x position as fraction of UIParent width
    bottomPercent = <0-1>,    -- y position as fraction of UIParent height
    uiParentWidth = <number>, -- UIParent width when position was saved
    uiParentHeight = <number>, -- UIParent height when position was saved
    scale = 1,                -- reserved for future use
}
```
 
Positions are normalized to screen size so they scale correctly if the game window resizes.
 
## Understanding Grow Directions
 
The grow direction system simplifies anchor positioning by specifying a cardinal direction.
 
### How it works
 
1. **Anchor position**: The anchor frame is placed at its saved position on screen.
2. **First frame**: Attaches to the anchor frame's center, extending in the grow direction.
3. **Subsequent frames**: Stack in the grow direction, each attaching to the previous frame's edge.
 
### Direction examples
 
**`"top"`**: Frames grow upward
```
     [Frame 2]
     [Frame 1]
      [Anchor]
```
 
**`"bottom"`**: Frames grow downward
```
      [Anchor]
     [Frame 1]
     [Frame 2]
```
 
**`"left"`**: Frames grow leftward
```
[Frame 2] [Frame 1] [Anchor]
```
 
**`"right"`**: Frames grow rightward
```
[Anchor] [Frame 1] [Frame 2]
```
 
## Common Patterns
 
### Choosing a grow direction
 
Select a grow direction based on where you want frames to appear relative to the anchor:
- Use `"bottom"` for buff/debuff displays that grow downward from the anchor
- Use `"top"` for overhead threat/aggro indicators that grow upward
- Use `"right"` for damage meters that grow rightward from a side anchor
- Use `"left"` for healing meters that grow leftward from a side anchor
 
### Hiding all frames at once
 
To clear all displayed content across all anchors:
 
```lua
anchorSystem:HideAll()
```
 
This releases every pooled frame back to their pools and triggers cleanup callbacks.
 
### Toggling between locked and unlocked
 
Allow users to move anchors:
 
```lua
if anchorSystem.locked then
    anchorSystem:UnlockAnchors()
    print("Anchors unlocked. Drag to reposition.")
else
    anchorSystem:LockAnchors()
    print("Anchors locked.")
end
```
 
## Error Conditions
 
- **`GetScreenAnchor` returns nil**: If you call `GetScreenAnchor` with a name that was never created, it returns `nil`. Always check the result or ensure anchors are created before accessing them.
- **`ShowFrame` on invalid anchor**: Calling `ShowFrame` with an anchor name that doesn't exist will error when trying to access `anchorFrame`. Verify anchors are created first.
- **Invalid grow direction**: If you pass an invalid grow direction (not one of "top", "bottom", "left", "right"), the `Reorder` method will not position frames correctly. Always use one of the four valid directions.
