containers.lua documentation

=====================================================================
Overview
=====================================================================

- containers.lua implements the DetailsFramework frame container system.
  A frame container is a parent frame that manages the layout, movement,
  and resizing of child frames placed inside it.
- Containers are used to organize multiple panels inside a window. For
  example, the Details breakdown window uses a container to hold player
  list, segment list, spell list, and target panels — each panel can be
  independently resized by dragging its edges.
- The single public entry point is:
      DF:CreateFrameContainer(parent, options, frameName)
- The returned object (df_framecontainer) is a Blizzard frame enriched
  with FrameContainerMixin and OptionsFunctions.
- Child frames are added via RegisterChild(). Once registered, children
  can be resized from their edges and/or dragged to new positions,
  depending on the container's options.


=====================================================================
1) Object architecture
=====================================================================

    df_framecontainer
     ├── FrameContainerMixin    -- all container methods
     ├── OptionsFunctions       -- options table management
     ├── .moverFrame            -- invisible button for dragging
     ├── .cornerResizers[]      -- 4 corner resize grips
     ├── .sideResizers[]        -- 4 side resize bars
     ├── .LeftResizeGrip        -- decorative grip (left)
     ├── .RightResizeGrip       -- decorative grip (right)
     ├── .movableChildren{}     -- set of registered child frames
     ├── .childResizers{}       -- per-child resizer buttons
     └── .childResizerSideOverrides{}  -- per-child side overrides

Key types:
- df_framecontainer: the main container object returned by
  CreateFrameContainer. Manages layout and interaction for all
  registered children.
- framecontainerresizer: a button used as a resize handle (corners
  and sides). Has a .sizingFrom field indicating the resize direction.


=====================================================================
2) DF:CreateFrameContainer — the public constructor
=====================================================================

Signature
    DF:CreateFrameContainer(parent, options, frameName)

Returns
    df_framecontainer — the container frame.

Parameters
    parent     (frame, required)
        The parent frame that owns the container.

    options    (table or nil)
        Configuration table. Keys are merged with defaults. See
        section 3 for all available options.

    frameName  (string or nil)
        Global name for the frame. If nil, a random name is generated.

Construction sequence
    1. Creates a frame with BackdropTemplate.
    2. Initializes tracking tables: components, movableChildren,
       childResizers, childResizerSideOverrides.
    3. Mixes in FrameContainerMixin and OptionsFunctions.
    4. Aliases RegisterChildForDrag → RegisterChild.
    5. Calls CreateResizers() — creates 4 corner + 4 side resizers.
    6. Calls CreateMover() — creates the drag-to-move button.
    7. Builds the options table (defaults merged with user options).
    8. Creates left and right decorative resize grips.
    9. Calls OnInitialize() — sets size, configures resizer scripts,
       positions them, checks lock states, sets resize bounds.
    10. Registers OnSizeChanged handler.
    11. Returns the container.


=====================================================================
3) Options reference
=====================================================================

These keys are set via the options table passed to CreateFrameContainer.
They can also be read or changed at runtime via container.options[key].

Container size:
    width                      (number, default 300)
    height                     (number, default 150)

Lock state:
    is_locked                  (boolean, default true)
        When true, the container itself cannot be resized. Corner and
        side resizers are hidden.

    is_movement_locked         (boolean, default true)
        When true, the container cannot be dragged to a new position.

Child interaction:
    can_move_children          (boolean, default false)
        When true, registered children become draggable via drag-and-
        drop. Children are confined within the container bounds and
        cannot overlap siblings. When this is true, child resizing
        is disabled (moving takes priority).

    can_resize_children        (boolean, default false)
        When true and can_move_children is false, thin resizer bars
        appear on the edges of registered children. Dragging an edge
        resizes the child and any adjacent sibling.

Child resizer sides (global defaults):
    use_top_child_resizer      (boolean, default true)
    use_bottom_child_resizer   (boolean, default true)
    use_left_child_resizer     (boolean, default true)
    use_right_child_resizer    (boolean, default true)
        These control which sides have resize handles for ALL children.
        Individual children can override these via SetChildResizerSides.

Container resizers (for resizing the container itself):
    use_topleft_resizer        (boolean, default false)
    use_topright_resizer       (boolean, default false)
    use_bottomleft_resizer     (boolean, default false)
    use_bottomright_resizer    (boolean, default false)
    use_top_resizer            (boolean, default false)
    use_bottom_resizer         (boolean, default false)
    use_left_resizer           (boolean, default false)
    use_right_resizer          (boolean, default false)
        Enable specific corner/side resize handles for the container
        frame itself. These are separate from child resizers.

    show_resize_grips          (boolean, default false)
        Show decorative resize grip textures at bottom-left and
        bottom-right corners.


=====================================================================
4) User-callable methods
=====================================================================

The following methods are the ones you call directly when using
containers. Internal methods are documented in section 5.

RegisterChild(child)
.....................................................................
Signature
    container:RegisterChild(child)

Purpose
    Registers a frame as a managed child of the container. After
    registration, the child becomes eligible for resizing and/or
    movement depending on the container's options.

Parameters
    child  (frame, required)
        The frame to register. Must be a child of the container in the
        frame hierarchy.

Behavior
    1. Adds child to movableChildren set.
    2. Sets the child's frame strata and level to match the container
       (children are drawn 10 levels above the container).
    3. Creates child resizer buttons (top, bottom, left, right).
    4. Calls RefreshChildrenState() to apply the current interaction
       mode (move vs resize).

Example
    container:RegisterChild(leftPanel)
    container:RegisterChild(rightPanel)


UnregisterChild(child)
.....................................................................
Signature
    container:UnregisterChild(child)

Purpose
    Removes a child from the container's management. Hides its
    resizers and removes all tracking data.

Parameters
    child  (frame, required)

Behavior
    1. Hides child resizer buttons.
    2. Removes child from childResizers, childResizerSideOverrides,
       and movableChildren.
    3. Calls RefreshChildrenState().


SetChildResizerSides(child, sideSettings)
.....................................................................
Signature
    container:SetChildResizerSides(child, sideSettings)

Purpose
    Overrides which edges of a specific child can be resized. By
    default, all children inherit the global use_*_child_resizer
    options. This method lets you customize per-child.

Parameters
    child         (frame, required)
        Must be a frame already registered via RegisterChild.

    sideSettings  (table, required)
        A table with any combination of these boolean keys:
            left    = true/false
            right   = true/false
            top     = true/false
            bottom  = true/false
        You can also use the option-style names:
            use_left_child_resizer   = true/false
            use_right_child_resizer  = true/false
            use_top_child_resizer    = true/false
            use_bottom_child_resizer = true/false
        Omitted keys fall back to the container's global setting.

Example
    -- Only allow resizing from the right edge
    container:SetChildResizerSides(leftPanel, {
        left = false,
        right = true,
        top = false,
        bottom = false,
    })

    -- Disable all resizing for this child
    container:SetChildResizerSides(comparePanel, {
        left = false,
        right = false,
        top = false,
        bottom = false,
    })


SetResizeLocked(isLocked)
.....................................................................
Signature
    container:SetResizeLocked(isLocked)

Purpose
    Locks or unlocks the container's own resizing. When locked, all
    container corner and side resizers are hidden and the frame cannot
    be resized.

Parameters
    isLocked  (boolean, required)
        true to lock, false to unlock.

Behavior
    1. Sets options.is_locked.
    2. Fires the settingChangedCallback with ("is_locked", isLocked).
    3. Calls CheckResizeLockedState() to show/hide resizers.


SetMovableLocked(isLocked)
.....................................................................
Signature
    container:SetMovableLocked(isLocked)

Purpose
    Locks or unlocks the container's drag-to-move functionality.

Parameters
    isLocked  (boolean, required)
        true to lock, false to unlock.

Behavior
    1. Sets options.is_movement_locked.
    2. Fires the settingChangedCallback with ("is_movement_locked",
       isLocked).
    3. Calls CheckMovableLockedState() to show/hide the mover frame.


SetSettingChangedCallback(callback)
.....................................................................
Signature
    container:SetSettingChangedCallback(callback)

Purpose
    Registers a function to be called whenever a container setting
    changes (resize locked, movement locked, size changed).

Parameters
    callback  (function, required)
        Called as: callback(frameContainer, settingName, settingValue)
        Setting names: "is_locked", "is_movement_locked", "width",
        "height".

Example
    container:SetSettingChangedCallback(function(c, name, value)
        print("Setting changed:", name, value)
    end)


=====================================================================
5) Internal methods
=====================================================================

These methods are called automatically by the container. They are
listed here for completeness and understanding.

OnResizerMouseDown(resizerButton, mouseButton)
    Handles left-click on a container resizer. Starts Blizzard's
    built-in frame sizing from the resizer's sizingFrom direction.

OnResizerMouseUp(resizerButton, mouseButton)
    Stops the container resize operation.

HideResizer()
    Hides all 8 container resizers (4 corners + 4 sides).

ShowResizer()
    Shows container resizers based on which use_* options are enabled.

CheckResizeLockedState()
    Reads is_locked and shows/hides resizers accordingly. Also sets
    the frame's Resizable property.

CheckMovableLockedState()
    Reads is_movement_locked and shows/hides the mover frame. Sets
    the frame's Movable property.

ShowResizeGrips() / HideResizeGrips()
    Shows or hides the decorative resize grip textures.

CreateMover()
    Creates an invisible button overlaying the container that handles
    drag-to-move via OnMouseDown/OnMouseUp scripts.

CreateResizers()
    Creates 4 corner resizers (bottomleft, bottomright, topleft,
    topright) and 4 side resizers (top, bottom, left, right). All are
    initially hidden.

OnInitialize()
    Runs after construction. Sets the container size, configures all
    resizer scripts, positions corner and side resizers, checks lock
    states, and sets resize bounds (50×50 min, 1920×1440 max).

OnSizeChanged()
    Fires when the container is resized. Proportionally scales and
    repositions all non-component children to maintain their relative
    layout. Fires settingChangedCallback for "width" and "height".

GetChildRelativeRect(child)
    Returns a table with the child's position and size relative to
    the container: { left, top, right, bottom, width, height }.
    Returns nil if positions cannot be determined.

SetChildRelativeRect(child, left, top, width, height)
    Positions and sizes a child relative to the container's top-left
    corner. Used internally during resize operations.

GetChildrenForResize(child, resizeSide)
    Finds sibling children adjacent to the given child on the
    specified side. Returns the nearest neighbors that should be
    resized in tandem. Uses range overlap detection to identify
    siblings sharing the same edge.

CreateChildResizers(child)
    Creates 4 resizer buttons (top, bottom, left, right) for a child
    frame. Each is a thin bar (4px) positioned along the child's edge.
    Resizers are created hidden and shown by RefreshChildrenState.

IsChildResizerSideEnabled(child, resizeSide)
    Checks if a specific side's resizer is enabled for a child. First
    checks per-child overrides (from SetChildResizerSides), then falls
    back to the container's global option.

SetChildResizersShown(child, shouldShow)
    Shows or hides all resizer buttons for a child, respecting the
    per-side enabled state.

OnChildResizerMouseDown(resizerButton, mouseButton)
    Handles left-click on a child resizer bar. Captures the initial
    cursor position and child geometry, finds neighbor children on the
    resize side, then starts an OnUpdate script that:
    - Tracks the cursor delta.
    - Calculates the new child size, clamped to minimum 20px and
      bounded by neighbors and container edges.
    - Resizes adjacent siblings in tandem (e.g., dragging the right
      edge of one panel shrinks the left edge of its neighbor).

OnChildResizerMouseUp(resizerButton, mouseButton)
    Stops the child resize OnUpdate and clears the active resize state.

OnChildDragStart(child)
    Handles drag start for a child in move mode. Captures cursor offset,
    starts an OnUpdate that moves the child within container bounds
    while preventing overlap with siblings.

OnChildDragStop(child)
    Stops the child drag-and-drop movement.

RefreshChildrenState()
    Applies the current interaction mode to all registered children:
    - If can_move_children: enables dragging, hides child resizers.
    - If can_resize_children (and not can_move_children): shows child
      resizers, disables dragging.
    - Otherwise: disables both.

SendSettingChangedCallback(key, value)
    Dispatches the registered settingChangedCallback if one exists.


=====================================================================
6) Child resize behavior
=====================================================================

When can_resize_children is true and can_move_children is false:

    1. Each registered child frame gets thin resizer bars on its
       enabled edges (4px wide).

    2. When the user drags an edge of a child:
       a. The container finds adjacent siblings on that side using
          GetChildrenForResize (range overlap detection).
       b. The child is resized in the drag direction.
       c. Adjacent siblings are resized inversely — if you make one
          panel wider, the neighbor panel shrinks by the same amount.
       d. All children are clamped to a minimum size of 20px.
       e. Children cannot exceed container bounds.

    3. Only one resize operation can be active at a time.

This creates a split-panel behavior similar to IDE editor splits or
spreadsheet column resizing.


=====================================================================
7) Field reference
=====================================================================

df_framecontainer
    .bIsSizing                  boolean — currently resizing?
    .options                    table — all option keys (see section 3)
    .currentWidth               number — cached width
    .currentHeight              number — cached height
    .moverFrame                 frame — invisible drag button
    .components                 table<frame, boolean> — non-child parts
    .movableChildren            table<frame, boolean> — registered children
    .childResizers              table<frame, {left, right, top, bottom}>
    .childResizerSideOverrides  table<frame, {side → boolean}>
    .activeChildResizeState     table|nil — current resize operation

    Container resizers:
    .bottomLeftResizer          framecontainerresizer
    .bottomRightResizer         framecontainerresizer
    .topLeftResizer             framecontainerresizer
    .topRightResizer            framecontainerresizer
    .topResizer                 framecontainerresizer
    .bottomResizer              framecontainerresizer
    .leftResizer                framecontainerresizer
    .rightResizer               framecontainerresizer
    .cornerResizers             framecontainerresizer[] (4 entries)
    .sideResizers               framecontainerresizer[] (4 entries)

    Decorative grips:
    .LeftResizeGrip             df_resizergrip
    .RightResizeGrip            df_resizergrip

    Callback:
    .settingChangedCallback     function|nil

framecontainerresizer
    .sizingFrom                 string — "topleft", "top", "right", etc.


=====================================================================
8) Usage examples
=====================================================================

Basic container with resizable children:

    local options = {
        width = 800,
        height = 600,
        is_locked = true,
        is_movement_locked = true,
        can_move_children = false,
        can_resize_children = true,
    }

    local container = DF:CreateFrameContainer(parentFrame, options, "MyContainer")
    container:SetPoint("CENTER")

    -- Create child panels
    local leftPanel = CreateFrame("Frame", "LeftPanel", container)
    leftPanel:SetPoint("topleft", container, "topleft", 0, 0)
    leftPanel:SetSize(200, 600)

    local rightPanel = CreateFrame("Frame", "RightPanel", container)
    rightPanel:SetPoint("topleft", leftPanel, "topright", 0, 0)
    rightPanel:SetSize(600, 600)

    -- Register children
    container:RegisterChild(leftPanel)
    container:RegisterChild(rightPanel)

    -- Left panel can only resize from the right edge
    container:SetChildResizerSides(leftPanel, {
        left = false, right = true,
        top = false, bottom = false,
    })

    -- Right panel has no resize edges (it follows the left panel)
    container:SetChildResizerSides(rightPanel, {
        left = false, right = false,
        top = false, bottom = false,
    })


Real-world example (from breakdown_sections.lua):

    local options = {
        width = contentWidth,
        height = contentHeight,
        is_movement_locked = true,
        can_move_children = false,
        can_resize_children = true,
        use_top_child_resizer = true,
        use_bottom_child_resizer = true,
        use_left_child_resizer = true,
        use_right_child_resizer = true,
        is_locked = true,
    }

    local container = DF:CreateFrameContainer(parent, options, name)

    -- Player list: only resizable from bottom
    local playerPanel = CreateFrame("Frame", nil, container)
    container:RegisterChild(playerPanel)
    container:SetChildResizerSides(playerPanel, {
        left = false, right = false,
        top = false, bottom = true,
    })

    -- Spell list: resizable from left and right
    local spellPanel = CreateFrame("Frame", nil, container)
    container:RegisterChild(spellPanel)
    container:SetChildResizerSides(spellPanel, {
        left = true, right = true,
        top = false, bottom = false,
    })

    -- Comparison panel: no resizing at all
    local comparePanel = CreateFrame("Frame", nil, container)
    container:RegisterChild(comparePanel)
    container:SetChildResizerSides(comparePanel, {
        left = false, right = false,
        top = false, bottom = false,
    })


Movable children (drag-and-drop mode):

    local container = DF:CreateFrameContainer(parentFrame, {
        width = 400,
        height = 400,
        can_move_children = true,
        can_resize_children = false,
    })

    container:RegisterChild(panel1)
    container:RegisterChild(panel2)
    -- Children can now be dragged within the container


Listening for setting changes:

    container:SetSettingChangedCallback(function(c, name, value)
        if name == "width" or name == "height" then
            SaveContainerSize(c:GetWidth(), c:GetHeight())
        end
    end)


Toggling lock state at runtime:

    container:SetResizeLocked(false)  -- unlock container resizing
    container:SetMovableLocked(false) -- allow container movement


=====================================================================
End of documentation
=====================================================================
