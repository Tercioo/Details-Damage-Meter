
---@class detailsframework
local detailsFramework = _G.DetailsFramework
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end


--[=[
    Snap System
    ------------
    Window-snapping behavior between movable frames, similar to UI editors.

    A snap group is created with detailsFramework:CreateSnapGroup(groupName, profileTable, options).
    Frames registered into the same group can snap to each other; frames in different groups never do.

    Public API (see the mixin further down for full docs):
        local snapGroup = detailsFramework:CreateSnapGroup("groupName", profileTable, options)
        snapGroup:RegisterFrame(frame[, id])
        snapGroup:UnregisterFrame(frame)
        snapGroup:Unsnap(frame)
        snapGroup:SetProfileTable(newTable)
        snapGroup:SetOptionsTable(newOptionsTable)
        snapGroup:Reset()

    Behavior summary:
        - The frame must already be movable; RegisterFrame wraps its existing OnDragStart/OnDragStop.
        - While dragging, edges within options.snap_distance of another group frame trigger a live
          glow preview on the two connecting edges (closest candidate wins, with hysteresis so it
          does not jitter).
        - On drop over a valid candidate the frames are anchored together (ClearAllPoints + SetPoint),
          forming a persistent chain. Dragging any member of a chain moves the whole cluster.
        - Snapped relationships and cluster positions persist to profileTable[groupName].
        - Links are only broken by the explicit Unsnap()/UnregisterFrame()/Reset() API.
--]=]

--constants
--the four snappable sides mapped to the side they connect to on the other frame.
--sides are stored lowercase so they can be passed straight to frame:SetPoint without conversion.
local SNAP_OPPOSITE = {left = "right", right = "left", top = "bottom", bottom = "top"}
--which axis each side lives on; the gap between connecting edges is measured along this axis.
local SNAP_AXIS = {left = "x", right = "x", top = "y", bottom = "y"}

--default options for a snap group; merged with the caller's overrides on creation / SetOptionsTable().
--keys use snake_case because this table is exposed to the addon profile as user configuration.
local SNAP_DEFAULT_OPTIONS = {
    snap_distance = 12,         --max screen-pixel gap between two edges to be treated as a snap candidate
    hysteresis = 4,             --a new candidate must be this many pixels closer than the current one to replace it
    update_interval = 0.015,    --seconds between proximity scans while dragging (throttle, avoids per-frame cost)
    glow_thickness = 3,         --thickness in pixels of the edge highlight
    glow_color = {1, 0.82, 0, 0.9},
    enabled_sides = {left = true, right = true, top = true, bottom = true},
}

--builds a fresh options table: a deep-ish copy of the defaults with the caller overrides applied on top.
local snapMergeOptions = function(overrides)
    local options = {}

    for key, value in pairs(SNAP_DEFAULT_OPTIONS) do
        if (type(value) == "table") then
            local copy = {}
            for innerKey, innerValue in pairs(value) do
                copy[innerKey] = innerValue
            end
            options[key] = copy
        else
            options[key] = value
        end
    end

    if (overrides) then
        for key, value in pairs(overrides) do
            options[key] = value
        end
    end

    return options
end

--returns the frame bounds in absolute screen pixels (effective scale applied) as left, bottom, right, top.
--converting to screen pixels lets frames living under parents with different scales be compared directly.
local snapGetScreenRect = function(frame)
    local left = frame:GetLeft()
    local bottom = frame:GetBottom()

    if (not left or not bottom) then
        return nil
    end

    local scale = frame:GetEffectiveScale()
    left = left * scale
    bottom = bottom * scale

    local width = frame:GetWidth() * scale
    local height = frame:GetHeight() * scale
    return left, bottom, left + width, bottom + height
end

--lazily builds (or returns) the 4 edge-highlight textures used to preview a snap on a frame.
--the textures are parented to the frame so they inherit its scale and strata automatically.
local snapGetGlowTextures = function(frame)
    if (frame.__snapGlow) then
        return frame.__snapGlow
    end

    local glow = {}
    for side in pairs(SNAP_OPPOSITE) do
        local texture = frame:CreateTexture(nil, "overlay")
        texture:SetColorTexture(1, 1, 1, 1)
        texture:Hide()
        glow[side] = texture
    end

    frame.__snapGlow = glow
    return glow
end

--shows the highlight texture for a single side (positioned along that edge) and hides the other three.
local snapShowGlow = function(frame, side, options)
    local glow = snapGetGlowTextures(frame)
    local thickness = options.glow_thickness
    local color = options.glow_color

    for thisSide, texture in pairs(glow) do
        if (thisSide == side) then
            texture:ClearAllPoints()
            if (thisSide == "left") then
                texture:SetPoint("topleft", frame, "topleft", 0, 0)
                texture:SetPoint("bottomleft", frame, "bottomleft", 0, 0)
                texture:SetWidth(thickness)

            elseif (thisSide == "right") then
                texture:SetPoint("topright", frame, "topright", 0, 0)
                texture:SetPoint("bottomright", frame, "bottomright", 0, 0)
                texture:SetWidth(thickness)

            elseif (thisSide == "top") then
                texture:SetPoint("topleft", frame, "topleft", 0, 0)
                texture:SetPoint("topright", frame, "topright", 0, 0)
                texture:SetHeight(thickness)

            elseif (thisSide == "bottom") then
                texture:SetPoint("bottomleft", frame, "bottomleft", 0, 0)
                texture:SetPoint("bottomright", frame, "bottomright", 0, 0)
                texture:SetHeight(thickness)
            end

            texture:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
            texture:Show()
        else
            texture:Hide()
        end
    end
end

--hides every highlight texture on a frame (called when there is no candidate or after a drop).
local snapHideGlow = function(frame)
    if (frame.__snapGlow) then
        for side, texture in pairs(frame.__snapGlow) do
            texture:Hide()
        end
    end
end

--evaluates one side pairing: the dragged frame's `side` edge connecting to the other frame's
--opposite edge. returns:
--  primaryGap: screen-pixel gap between the connecting edges (used for the snap_distance threshold)
--  perpendicularMisalignment: screen-pixel distance between the two frames' centers along the
--                             perpendicular axis (used as the tiebreaker so that when two candidates
--                             have the same primary gap, the one the dragged frame is more visually
--                             centered on wins -- e.g. dragging below frame A vs below frame B where
--                             A and B share a bottom edge, A wins if the dragged frame is mostly
--                             under A.)
--returns nil when the frames don't overlap enough on the perpendicular axis to be facing each other.
--rects are passed as (left, bottom, right, top) in screen pixels.
local snapEvaluatePair = function(draggedLeft, draggedBottom, draggedRight, draggedTop, otherLeft, otherBottom, otherRight, otherTop, side, snapDistance)
    local axis = SNAP_AXIS[side]
    local primaryGap, perpendicularOverlap, perpendicularMisalignment

    if (axis == "x") then
        --left/right pairings connect along x: measure the horizontal gap between the connecting edges
        if (side == "left") then
            primaryGap = math.abs(draggedLeft - otherRight)       --dragged left edge meets other right edge
        else
            primaryGap = math.abs(draggedRight - otherLeft)       --dragged right edge meets other left edge
        end
        --the perpendicular axis is vertical: how much the two frames share vertically (overlap)
        --and how far their vertical centers are from each other (misalignment, for tiebreaking)
        perpendicularOverlap = math.min(draggedTop, otherTop) - math.max(draggedBottom, otherBottom)
        local draggedMidY = (draggedTop + draggedBottom) / 2
        local otherMidY = (otherTop + otherBottom) / 2
        perpendicularMisalignment = math.abs(draggedMidY - otherMidY)

    else
        --top/bottom pairings connect along y: measure the vertical gap between the connecting edges
        if (side == "bottom") then
            primaryGap = math.abs(draggedBottom - otherTop)       --dragged bottom edge meets other top edge
        else
            primaryGap = math.abs(draggedTop - otherBottom)       --dragged top edge meets other bottom edge
        end
        --the perpendicular axis is horizontal
        perpendicularOverlap = math.min(draggedRight, otherRight) - math.max(draggedLeft, otherLeft)
        local draggedMidX = (draggedLeft + draggedRight) / 2
        local otherMidX = (otherLeft + otherRight) / 2
        perpendicularMisalignment = math.abs(draggedMidX - otherMidX)
    end

    --require the frames to be roughly facing each other. a small negative overlap is tolerated
    --(within snapDistance) so frames approaching corner-first still register as candidates.
    if (perpendicularOverlap < -snapDistance) then
        return nil
    end

    return primaryGap, perpendicularMisalignment
end

--scans every other frame in the group for the closest valid snap candidate to draggedFrame.
--frames belonging to draggedFrame's own cluster are skipped (a frame cannot snap onto its own chain).
--returns a candidate table {targetFrame, targetData, side, theirSide, gap} or nil.
local snapFindCandidate = function(group, draggedFrame)
    local options = group.options
    local snapDistance = options.snap_distance
    local enabledSides = options.enabled_sides

    local draggedLeft, draggedBottom, draggedRight, draggedTop = snapGetScreenRect(draggedFrame)
    if (not draggedLeft) then
        return nil
    end

    --frames that belong to the cluster currently being dragged are invalid targets
    local clusterLookup = group.__dragClusterLookup
    --the dragged frame's own existing links: any side already in use can't host a second snap.
    --during cluster drag the grabbed frame is the temp root and may already link to its children,
    --so this is what prevents the chain from being clobbered by an outward snap on the same side.
    local draggedData = group.__dragFrameData

    local best, bestScore
    local frames = group.registeredFrames
    for i = 1, #frames do
        local frameData = frames[i]
        local otherFrame = frameData.Frame
        if (otherFrame ~= draggedFrame and otherFrame:IsVisible() and not (clusterLookup and clusterLookup[otherFrame])) then
            local otherLeft, otherBottom, otherRight, otherTop = snapGetScreenRect(otherFrame)
            if (otherLeft) then
                for side in pairs(SNAP_OPPOSITE) do
                    local theirSide = SNAP_OPPOSITE[side]
                    --skip sides that would conflict with a link already attached on either frame.
                    --without this, a frame already snapped on its right edge would still be offered
                    --as a candidate against its right edge, and dropping there would visually overlap
                    --the frame already chained on that side.
                    local sideFree = (not draggedData or not draggedData.links[side]) and not frameData.links[theirSide]
                    if (enabledSides[side] and sideFree) then
                        local primaryGap, perpendicularMisalignment = snapEvaluatePair(draggedLeft, draggedBottom, draggedRight, draggedTop, otherLeft, otherBottom, otherRight, otherTop, side, snapDistance)
                        --primaryGap gates validity (snap_distance threshold); the score combines it
                        --with the perpendicular misalignment so that, when two candidates have the
                        --same primary gap (e.g. two size-matched frames sharing the same bottom edge),
                        --the one the dragged frame is more visually centered under wins.
                        if (primaryGap and primaryGap <= snapDistance) then
                            local score = primaryGap + perpendicularMisalignment
                            if (not bestScore or score < bestScore) then
                                bestScore = score
                                best = best or {}
                                best.TargetFrame = otherFrame
                                best.targetData = frameData
                                best.side = side
                                best.theirSide = theirSide
                                best.score = score
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

--updates the live snap preview while dragging: resolves the nearest candidate, applies hysteresis so
--the chosen edges stay stable instead of flickering, and moves the edge glow to the connecting edges
--of both frames. clears the preview immediately when no candidate exists.
local snapUpdatePreview = function(group, draggedFrame)
    local newCandidate = snapFindCandidate(group, draggedFrame)
    local current = group.currentCandidate

    if (newCandidate) then
        if (current and current.TargetFrame == newCandidate.TargetFrame and current.side == newCandidate.side) then
            --same pairing as last frame: just refresh the measured score, the glow is already in place
            current.score = newCandidate.score
            return
        end

        if (current and newCandidate.score >= current.score - group.options.hysteresis) then
            --a different pairing exists but is not meaningfully closer, keep the current preview stable
            return
        end

        --switch the preview to the new (closer) candidate
        if (current) then
            snapHideGlow(draggedFrame)
            snapHideGlow(current.TargetFrame)
        end

        snapShowGlow(draggedFrame, newCandidate.side, group.options)
        snapShowGlow(newCandidate.TargetFrame, newCandidate.theirSide, group.options)

        group.currentCandidate = newCandidate

    elseif (current) then
        --no candidate anymore: remove the preview right away
        snapHideGlow(draggedFrame)
        snapHideGlow(current.TargetFrame)
        group.currentCandidate = nil
    end
end

--walks the snap-link graph starting from frameData and returns a flat list of every frameData in the
--same cluster, plus a lookup table {frame = frameData}. used to move clusters as a unit and to
--forbid a frame from snapping onto a frame already in its own chain.
local snapCollectCluster = function(frameData)
    local list = {}
    local lookup = {}
    local queue = {frameData}
    lookup[frameData.Frame] = frameData

    while (#queue > 0) do
        local current = table.remove(queue)
        list[#list+1] = current
        for side, link in pairs(current.links) do
            if (not lookup[link.Target]) then
                lookup[link.Target] = link.targetData
                queue[#queue+1] = link.targetData
            end
        end
    end

    return list, lookup
end

--detaches a frame from whatever it is anchored to and re-pins it to UIParent at the exact same
--on-screen spot, so it can act as the absolute-positioned root of its cluster.
local snapMakeAbsolute = function(frame)
    local left, bottom = frame:GetLeft(), frame:GetBottom()
    if (not left) then
        return
    end

    --convert the frame's own-space left/bottom into UIParent space so the SetPoint is pixel-exact
    local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    frame:ClearAllPoints()
    frame:SetPoint("bottomleft", UIParent, "bottomleft", left * scale, bottom * scale)
end

--module-level re-entrancy guard: TRUE while we're inside snapApplyAnchor (i.e. doing our own
--ClearAllPoints/SetHeight/SetPoint to wire up the chain). the resize hooks installed by
--RegisterFrame check this flag and skip propagation when set, because the SetHeight/SetWidth
--triggered synchronously by hooksecurefunc inside snapApplyAnchor MUST NOT trigger a recursive
--snapPropagateSize -- doing so would call snapGetRoot before the cluster's isRoot flags have been
--updated, pick the wrong root, and re-anchor in the opposite direction, creating an anchor cycle
--("Cannot anchor to a region dependent on it") when the outer SetPoint then tries to complete.
local snapInternalChain = false

--applies a snap anchor between a child frame and its parent: a single SetPoint at the midpoint of
--the connecting side, plus an explicit SetHeight/SetWidth that matches the perpendicular dimension
--to the parent's. used uniformly at rest and during drag, because:
-- (a) Blizzard's StartMoving propagates position reliably with one anchor per child but not two,
--     so the cluster has to stay single-anchored to be draggable as a unit.
-- (b) the explicit SetSize keeps the connecting edges flush at both ends, giving the two-anchor
--     visual without a second anchor.
-- live resize propagation through the cluster does NOT come from anchors (the owning addon's
-- resize logic often calls ClearAllPoints which breaks any anchor chain); it comes from an
-- OnSizeChanged hook installed by RegisterFrame, see snapPropagateSize below.
local snapApplyAnchor = function(childFrame, parentFrame, childSide, parentSide)
    snapInternalChain = true

    childFrame:ClearAllPoints()
    if (SNAP_AXIS[childSide] == "x") then
        childFrame:SetHeight(parentFrame:GetHeight())
    else
        childFrame:SetWidth(parentFrame:GetWidth())
    end
    childFrame:SetPoint(childSide, parentFrame, parentSide, 0, 0)

    snapInternalChain = false
end

--re-applies the SetPoint chain for an entire cluster as a spanning tree rooted at rootData. every
--non-root member gets the single-anchor + SetSize-matched form. links that would close a cycle
--are ignored for anchoring, which guarantees there are never recursive or broken point chains.
local snapRebuildCluster = function(rootData)
    local rootFrame = rootData.Frame

    --the root holds the cluster's absolute position; make sure it is not anchored to a member
    snapMakeAbsolute(rootFrame)
    rootData.isRoot = true

    local visited = {[rootFrame] = true}
    local queue = {rootData}

    while (#queue > 0) do
        local parentData = table.remove(queue, 1)
        local parentFrame = parentData.Frame

        for side, link in pairs(parentData.links) do
            local childData = link.targetData
            local childFrame = link.Target

            if (not visited[childFrame]) then
                visited[childFrame] = true

                --find the child's own link pointing back at this parent and use it to anchor the child
                for childSide, childLink in pairs(childData.links) do
                    if (childLink.Target == parentFrame) then
                        snapApplyAnchor(childFrame, parentFrame, childLink.mySide, childLink.theirSide)
                        break
                    end
                end

                childData.isRoot = false
                queue[#queue+1] = childData
            end
        end
    end
end

--returns the current root frameData of frameData's cluster, falling back to frameData itself when
--none of the members is flagged as root (e.g. right after links were cut).
local snapGetRoot = function(frameData)
    local list = snapCollectCluster(frameData)
    for i = 1, #list do
        if (list[i].isRoot) then
            return list[i]
        end
    end
    return frameData
end

--BFS from originData restricted to links of a single axis ("x" or "y"); returns true when targetData
--is reachable through the axis-only path. used by snapPropagateSize to decide whether the resized
--frame's new dimension should be pushed onto the cluster root.
local snapReachesByAxis = function(originData, targetData, axis)
    if (originData == targetData) then
        return true
    end
    local visited = {[originData.Frame] = true}
    local queue = {originData}
    while (#queue > 0) do
        local current = table.remove(queue, 1)
        for side, link in pairs(current.links) do
            if (SNAP_AXIS[link.mySide] == axis and not visited[link.Target]) then
                if (link.targetData == targetData) then
                    return true
                end
                visited[link.Target] = true
                queue[#queue+1] = link.targetData
            end
        end
    end
    return false
end

--called from the SetSize/SetHeight/SetWidth/OnSizeChanged hooks installed by RegisterFrame. it does
--TWO things, in this order:
--  1. propagates the resized frame's new dimension to the cluster root, if the resized frame can
--     reach the root through links of the matching axis (height through x-axis, width through y).
--     this is what lets the user resize ANY group member, not just the root.
--  2. rebuilds the whole cluster's snap chain via snapApplyAnchor on every non-root member. this is
--     what KEEPS THE WINDOWS ALIGNED after a resize: the addon owning the frame frequently calls
--     ClearAllPoints or SetPoint inside its own resize handler, wiping our snap anchors. just
--     pushing SetSize without re-anchoring leaves the children floating wherever the addon put them.
--     re-running snapApplyAnchor re-pins each child at its connecting-side midpoint with the parent
--     and resets the perpendicular SetSize from the parent's now-current value, so the row/column
--     stays a coherent layout.
--
--axis partition for propagation:
--   * horizontal group = frames reachable from origin via x-axis (left/right) links; height syncs.
--   * vertical group   = frames reachable from origin via y-axis (top/bottom) links; width syncs.
-- a frame can belong to both groups independently.
local snapPropagateSize = function(group, originData)
    --suppress propagation when we're inside our own anchor work. SetHeight/SetWidth in
    --snapApplyAnchor fire hooksecurefunc synchronously; re-entering here mid-rebuild picks the
    --wrong cluster root (because isRoot flags haven't been updated yet) and creates an anchor cycle.
    if (snapInternalChain) then
        return
    end
    if (group.__syncingSize) then
        return
    end
    --silently no-op if the frame is no longer in the group (hooksecurefunc and HookScript can't be
    --removed at UnregisterFrame, so they keep firing for the rest of the frame's lifetime).
    if (not group.framesByObject[originData.Frame]) then
        return
    end

    group.__syncingSize = true

    local originFrame = originData.Frame
    local newHeight = originFrame:GetHeight()
    local newWidth = originFrame:GetWidth()

    --step 1: push origin's new dimension onto the root if origin is in the matching-axis chain.
    --otherwise the chain rebuild in step 2 would revert origin back to root's old dimension.
    local rootData = snapGetRoot(originData)
    local rootFrame = rootData.Frame
    if (originData ~= rootData) then
        if (snapReachesByAxis(originData, rootData, "x") and math.abs(rootFrame:GetHeight() - newHeight) > 0.5) then
            rootFrame:SetHeight(newHeight)
        end
        if (snapReachesByAxis(originData, rootData, "y") and math.abs(rootFrame:GetWidth() - newWidth) > 0.5) then
            rootFrame:SetWidth(newWidth)
        end
    end

    --step 2: re-apply snap anchors for every non-root cluster member. snapApplyAnchor's built-in
    --SetHeight/SetWidth to parent's value naturally propagates root's (now-updated) dimension to
    --x-axis siblings as height and to y-axis siblings as width, in a single BFS pass.
    local visited = {[rootFrame] = true}
    local queue = {rootData}
    while (#queue > 0) do
        local parentData = table.remove(queue, 1)
        local parentFrame = parentData.Frame
        for side, link in pairs(parentData.links) do
            if (not visited[link.Target]) then
                visited[link.Target] = true
                local childData = link.targetData
                local childFrame = link.Target
                for childSide, childLink in pairs(childData.links) do
                    if (childLink.Target == parentFrame) then
                        snapApplyAnchor(childFrame, parentFrame, childLink.mySide, childLink.theirSide)
                        break
                    end
                end
                queue[#queue+1] = childData
            end
        end
    end

    group.__syncingSize = false
end

--snapped frames are anchored at the midpoint of their connecting side AND have their perpendicular
--dimension matched to the target's, so the connecting edges line up flush at both ends. that means
--the SetPoint offsets are always (0, 0) -- there is no separate offset computation step. an earlier
--implementation computed perpendicular offsets dynamically; it was removed once the perpendicular
--SetHeight/SetWidth in snapRebuildCluster made those offsets always zero.

---@class snaplink : table a directed snap relationship: frame:SetPoint(mySide, Target, theirSide, offsetX, offsetY)
---@field Target frame the frame on the other end of the link
---@field targetData snapframedata the registration data of the target frame
---@field mySide string the side of the owning frame used as the anchor point
---@field theirSide string the side of the target frame the owning frame anchors to
---@field offsetX number x offset of the SetPoint, in the owning frame's coordinate space
---@field offsetY number y offset of the SetPoint, in the owning frame's coordinate space

---@class snapframedata : table the per-frame registration record stored by a snap group
---@field Frame frame the registered frame
---@field id string the stable identifier (frame name or explicit id) used for persistence
---@field links table<string, snaplink> directed snap links keyed by the owning frame's side
---@field isRoot boolean true when this frame holds its cluster's absolute UIParent anchor
---@field group snapgroup the owning snap group
---@field OrigOnDragStart function|nil the frame's OnDragStart script captured before wrapping
---@field OrigOnDragStop function|nil the frame's OnDragStop script captured before wrapping
---@field originalWidth number|nil pre-snap width captured on the first snap; restored by Unsnap
---@field originalHeight number|nil pre-snap height captured on the first snap; restored by Unsnap

---@class snapcandidate : table a resolved snap target evaluated while dragging
---@field TargetFrame frame the frame the dragged frame would snap to
---@field targetData snapframedata the registration data of the target frame
---@field side string the dragged frame's side that would connect
---@field theirSide string the target frame's side that would connect
---@field score number combined snap distance: primary edge gap + perpendicular center misalignment; smaller is better, used for both candidate ranking and hysteresis

---@class snapgroup : table an isolated snap group created by detailsFramework:CreateSnapGroup()
---@field groupName string identifies the group and keys its data inside profileTable
---@field profileTable table|nil saved-variables table for persistence (data at profileTable[groupName])
---@field options table the active options (snap defaults merged with caller overrides)
---@field registeredFrames snapframedata[] every frame currently registered into the group
---@field framesByObject table<frame, snapframedata> registration lookup keyed by frame object
---@field framesById table<string, snapframedata> registration lookup keyed by persistent id
---@field currentCandidate snapcandidate|nil the snap candidate currently being previewed, if any
---@field UpdateFrame frame drives the throttled proximity scan while a drag is active
---@field __dragFrameData snapframedata|nil the frame being dragged right now, if any
---@field __dragClusterLookup table|nil lookup of the cluster being dragged (excluded from candidates)
---@field __dragElapsed number time accumulator for throttling the proximity scan
---@field __syncingSize boolean re-entrancy guard for snapPropagateSize OnSizeChanged cascades
---@field RegisterFrame fun(self: snapgroup, frame: frame, id: string?)
---@field UnregisterFrame fun(self: snapgroup, frame: frame)
---@field Unsnap fun(self: snapgroup, frame: frame)
---@field RemoveLink fun(self: snapgroup, frameData: snapframedata, side: string): snapframedata|nil
---@field SetProfileTable fun(self: snapgroup, newTable: table)
---@field SetOptionsTable fun(self: snapgroup, newOptionsTable: table?)
---@field Reset fun(self: snapgroup)
---@field OnFrameDragStart fun(self: snapgroup, frameData: snapframedata, ...: any)
---@field OnFrameDragStop fun(self: snapgroup, frameData: snapframedata, ...: any)
---@field OnDragUpdate fun(self: snapgroup, deltaTime: number)
---@field Snap fun(self: snapgroup, frameData: snapframedata, candidate: snapcandidate)
---@field SavePersistent fun(self: snapgroup)
---@field TryRestore fun(self: snapgroup)

--the mixin holding every public (and a few internal) snap group methods; applied to each group
--instance returned by detailsFramework:CreateSnapGroup().
local snapGroupMixin = {
    ---registers a frame into the group so it can snap to (and be snapped by) other group frames.
    ---the frame must already be movable (set up via RegisterForDrag/SetMovable); its existing
    ---OnDragStart/OnDragStop scripts are wrapped, not replaced.
    ---@param self snapgroup
    ---@param frame frame the frame (or a DetailsFramework widget wrapping one) to register
    ---@param id string|nil stable identifier; required only when the frame has no name
    RegisterFrame = function(self, frame, id)
        frame = frame.widget or frame
        --resolve the persistent identifier: frame name first, then the explicit id, else error
        id = frame:GetName() or id
        assert(id, "snapGroup:RegisterFrame(frame[, id]): the frame has no name, an 'id' must be provided.")

        if (self.framesByObject[frame]) then
            return
        end

        if (frame.IsMovable and not frame:IsMovable()) then
            detailsFramework:MsgWarning("CreateSnapGroup: RegisterFrame() received a frame that is not movable; snapping needs the frame to be draggable.")
        end

        ---@type snapframedata
        local frameData = {
            Frame = frame,
            id = id,
            links = {},     --directed snap links keyed by this frame's side -> {Target, targetData, mySide, theirSide}
            isRoot = true,  --a lone frame is the root of its own (single member) cluster
            group = self,
        }

        self.framesByObject[frame] = frameData
        self.framesById[id] = frameData
        self.registeredFrames[#self.registeredFrames+1] = frameData

        --wrap the frame's current drag scripts so existing behavior is preserved
        frameData.OrigOnDragStart = frame:GetScript("OnDragStart")
        frameData.OrigOnDragStop = frame:GetScript("OnDragStop")

        frame:SetScript("OnDragStart", function(_, ...)
            self:OnFrameDragStart(frameData, ...)
        end)

        frame:SetScript("OnDragStop", function(_, ...)
            self:OnFrameDragStop(frameData, ...)
        end)

        --resize detection uses TWO layers, because either alone isn't reliable enough:
        --  (a) HookScript("OnSizeChanged", …) catches the event the next render frame. cheap, but
        --      can be silently lost if the owning addon later calls SetScript("OnSizeChanged", …)
        --      with its own handler.
        --  (b) hooksecurefunc on SetSize/SetHeight/SetWidth fires synchronously inside the call.
        --      hooksecurefunc hooks CANNOT be removed by anything, so they survive whatever the
        --      addon does to the frame's scripts.
        --both call snapPropagateSize; the __syncingSize guard in snapPropagateSize coalesces them
        --so the cluster rebuild only runs once per resize even when both fire.
        frame:HookScript("OnSizeChanged", function()
            snapPropagateSize(self, frameData)
        end)
        hooksecurefunc(frame, "SetSize", function()
            snapPropagateSize(self, frameData)
        end)
        hooksecurefunc(frame, "SetHeight", function()
            snapPropagateSize(self, frameData)
        end)
        hooksecurefunc(frame, "SetWidth", function()
            snapPropagateSize(self, frameData)
        end)

        --a newly registered frame may complete a relationship described by the saved profile
        self:TryRestore()
    end,

    ---removes a frame from the group: cuts its snap links, restores its original drag scripts and
    ---hides any leftover glow. The rest of its former cluster stays intact.
    ---@param self snapgroup
    ---@param frame frame
    UnregisterFrame = function(self, frame)
        frame = frame.widget or frame
        local frameData = self.framesByObject[frame]
        if (not frameData) then
            return
        end

        --cutting all links keeps the remaining cluster members validly anchored
        self:Unsnap(frame)

        --restore whatever drag scripts the frame had before it was registered
        frame:SetScript("OnDragStart", frameData.OrigOnDragStart)
        frame:SetScript("OnDragStop", frameData.OrigOnDragStop)
        snapHideGlow(frame)

        self.framesByObject[frame] = nil
        self.framesById[frameData.id] = nil

        for i = #self.registeredFrames, 1, -1 do
            if (self.registeredFrames[i] == frameData) then
                table.remove(self.registeredFrames, i)
                break
            end
        end
    end,

    ---breaks every snap link of a frame, leaving it free-standing at its current position.
    ---this is the only way (besides UnregisterFrame/Reset) to detach a snapped frame.
    ---@param self snapgroup
    ---@param frame frame
    Unsnap = function(self, frame)
        frame = frame.widget or frame

        local frameData = self.framesByObject[frame]
        if (not frameData) then
            return
        end

        --remember the neighbours before cutting so their clusters can be rebuilt afterwards
        local neighbours = {}
        for side, link in pairs(frameData.links) do
            neighbours[#neighbours+1] = link.targetData
        end

        --cut every link on this frame (both directions are removed by RemoveLink)
        for side in pairs(frameData.links) do
            self:RemoveLink(frameData, side)
        end

        --this frame now stands alone; restore its pre-snap size (captured the first time it snapped)
        --so the visual size match introduced by Snap/snapRebuildCluster is undone here.
        if (frameData.originalWidth) then
            frame:SetSize(frameData.originalWidth, frameData.originalHeight)
            frameData.originalWidth = nil
            frameData.originalHeight = nil
        end
        snapMakeAbsolute(frame)
        frameData.isRoot = true

        --each former neighbour may now head its own cluster; rebuild from a fresh root.
        --if a neighbour is now itself solo (the link we just cut was its only one), restore its
        --pre-snap size too -- otherwise it would stay stretched to the old cluster's matched size.
        for i = 1, #neighbours do
            local neighbourData = neighbours[i]
            if (self.framesByObject[neighbourData.Frame]) then
                if (neighbourData.originalWidth and next(neighbourData.links) == nil) then
                    neighbourData.Frame:SetSize(neighbourData.originalWidth, neighbourData.originalHeight)
                    neighbourData.originalWidth = nil
                    neighbourData.originalHeight = nil
                end
                snapRebuildCluster(snapGetRoot(neighbourData))
            end
        end

        self:SavePersistent()
    end,

    ---removes a single directed link (and its reciprocal) from frameData on the given side.
    ---internal helper; returns the frameData that was on the other end of the link, if any.
    ---@param self snapgroup
    ---@param frameData snapframedata
    ---@param side string
    ---@return snapframedata|nil
    RemoveLink = function(self, frameData, side)
        local link = frameData.links[side]
        if (not link) then
            return nil
        end

        local otherData = link.targetData
        frameData.links[side] = nil

        --remove the matching reciprocal link stored on the other frame
        for otherSide, otherLink in pairs(otherData.links) do
            if (otherLink.Target == frameData.Frame) then
                otherData.links[otherSide] = nil
            end
        end

        return otherData
    end,

    ---swaps the group's profile table at runtime and re-attempts a restore from it.
    ---@param self snapgroup
    ---@param newTable table
    SetProfileTable = function(self, newTable)
        self.profileTable = newTable
        self:TryRestore()
    end,

    ---swaps the group's options at runtime; the new table is merged on top of the defaults.
    ---@param self snapgroup
    ---@param newOptionsTable table|nil
    SetOptionsTable = function(self, newOptionsTable)
        self.options = snapMergeOptions(newOptionsTable)
    end,

    ---tears the group down to a blank, reusable state: unregisters every frame, drops the profile
    ---and options references and clears the current preview. The data already written into the old
    ---profile table is left untouched (the caller owns it). Use this on addon profile switches.
    ---@param self snapgroup
    Reset = function(self)
        for i = #self.registeredFrames, 1, -1 do
            self:UnregisterFrame(self.registeredFrames[i].Frame)
        end

        table.wipe(self.framesByObject)
        table.wipe(self.framesById)
        table.wipe(self.registeredFrames)
        self.profileTable = nil
        self.options = snapMergeOptions(nil)
        self.currentCandidate = nil
        self.__dragFrameData = nil
        self.__dragClusterLookup = nil
        self.UpdateFrame:Hide()
    end,

    ---wrapped OnDragStart handler. Starts moving the frame (or its whole cluster) and kicks off the
    ---throttled proximity scan. Internal — installed by RegisterFrame.
    ---@param self snapgroup
    ---@param frameData snapframedata
    OnFrameDragStart = function(self, frameData, ...)
        local frame = frameData.Frame
        --discover the cluster being grabbed: it must move as a unit and be excluded from candidates
        local clusterList, clusterLookup = snapCollectCluster(frameData)
        self.__dragFrameData = frameData
        self.__dragClusterLookup = clusterLookup
        self.currentCandidate = nil

        if (#clusterList > 1) then
            --multi-frame cluster: re-root the chain on the grabbed frame so the whole cluster is
            --single-point chained to it, then StartMoving it -> the entire cluster follows the
            --cursor via Blizzard's anchor propagation (single-anchor children propagate reliably).
            snapRebuildCluster(frameData)
            frame:StartMoving()

        else
            --solo frame: run its own original OnDragStart (StartMoving plus any custom state)
            if (frameData.OrigOnDragStart) then
                frameData.OrigOnDragStart(frame, ...)
            else
                frame:StartMoving()
            end
        end

        --begin the throttled proximity scan (the OnUpdate script is installed on the group's updateFrame)
        self.__dragElapsed = 0
        self.UpdateFrame:Show()
    end,

    ---wrapped OnDragStop handler. Stops the movement, then either applies the previewed snap or
    ---leaves the frame free-standing at its dropped position. Internal — installed by RegisterFrame.
    ---@param self snapgroup
    ---@param frameData snapframedata
    OnFrameDragStop = function(self, frameData, ...)
        local frame = frameData.Frame
        self.UpdateFrame:Hide()

        --end the movement through the path that started it
        local clusterList = snapCollectCluster(frameData)
        if (#clusterList > 1) then
            frame:StopMovingOrSizing()
        else
            if (frameData.OrigOnDragStop) then
                frameData.OrigOnDragStop(frame, ...)
            else
                frame:StopMovingOrSizing()
            end
        end

        local candidate = self.currentCandidate

        --clear the preview glow regardless of the outcome
        snapHideGlow(frame)
        if (candidate) then
            snapHideGlow(candidate.TargetFrame)
        end

        self.currentCandidate = nil
        self.__dragFrameData = nil
        self.__dragClusterLookup = nil

        if (candidate) then
            --a valid candidate was being previewed: anchor the frames together
            self:Snap(frameData, candidate)
        else
            --no candidate: the grabbed frame is the temp root of its cluster; normalize it to an
            --absolute UIParent anchor at the dropped position and re-chain its cluster.
            snapRebuildCluster(frameData)
        end

        self:SavePersistent()
    end,

    ---throttled per-frame proximity scan, driven by the group's updateFrame OnUpdate while dragging.
    ---Internal.
    ---@param self snapgroup
    ---@param deltaTime number
    OnDragUpdate = function(self, deltaTime)
        local frameData = self.__dragFrameData
        if (not frameData) then
            return
        end

        self.__dragElapsed = (self.__dragElapsed or 0) + deltaTime
        if (self.__dragElapsed < self.options.update_interval) then
            return
        end

        self.__dragElapsed = 0
        snapUpdatePreview(self, frameData.Frame)
    end,

    ---anchors frameData to a resolved snap candidate, merging the two clusters into one chain.
    ---Internal — called by OnFrameDragStop when a valid preview exists on drop.
    ---@param self snapgroup
    ---@param frameData snapframedata
    ---@param candidate snapcandidate
    Snap = function(self, frameData, candidate)
        local draggedFrame = frameData.Frame
        local targetData = candidate.targetData
        local targetFrame = candidate.TargetFrame
        local side = candidate.side
        local theirSide = candidate.theirSide

        --capture the target side's existing root BEFORE adding the link; it stays the merged
        --cluster's root, so the target's chain (and on-screen position) is the stable anchor.
        local rootData = snapGetRoot(targetData)

        --drop any link already occupying the sides about to be reused, to avoid conflicting points
        local orphanA = self:RemoveLink(frameData, side)
        local orphanB = self:RemoveLink(targetData, theirSide)

        --capture the dragged frame's pre-snap size so Unsnap can restore it. only the first snap
        --captures; subsequent snaps reuse the value, so re-snapping after a manual SetSize doesn't
        --overwrite the truly-original dimensions. saved across sessions via SavePersistent so the
        --unsnap-restore still works after /reload.
        if (not frameData.originalWidth) then
            frameData.originalWidth = draggedFrame:GetWidth()
            frameData.originalHeight = draggedFrame:GetHeight()
        end

        --offsets are always (0, 0); the perpendicular SetHeight/SetWidth in snapRebuildCluster
        --takes care of the visual flush. store the link in both directions for the chain walk.
        frameData.links[side] = {
            Target = targetFrame, targetData = targetData,
            mySide = side, theirSide = theirSide, offsetX = 0, offsetY = 0,
        }
        targetData.links[theirSide] = {
            Target = draggedFrame, targetData = frameData,
            mySide = theirSide, theirSide = side, offsetX = 0, offsetY = 0,
        }

        --rebuild the merged cluster as a spanning tree rooted at the target side's root
        snapRebuildCluster(rootData)

        --any frame orphaned by a replaced link becomes (or rejoins) its own valid cluster
        if (orphanA) then
            snapRebuildCluster(snapGetRoot(orphanA))
        end
        if (orphanB) then
            snapRebuildCluster(snapGetRoot(orphanB))
        end
    end,

    ---writes the group's current snap links and cluster-root positions into profileTable[groupName].
    ---Internal — called after every structural change. No-op when the group has no profile table.
    ---@param self snapgroup
    SavePersistent = function(self)
        if (not self.profileTable) then
            return
        end

        --everything for this group lives under one key so a single table can host many groups
        local data = {}
        self.profileTable[self.groupName] = data

        local frames = self.registeredFrames
        for i = 1, #frames do
            local frameData = frames[i]
            local entry = {links = {}}

            for side, link in pairs(frameData.links) do
                entry.links[side] = {
                    targetId = link.targetData.id,
                    mySide = link.mySide, theirSide = link.theirSide,
                    offsetX = link.offsetX, offsetY = link.offsetY,
                }
            end

            --cluster roots also persist their absolute screen position so the cluster reappears in place
            if (frameData.isRoot) then
                local frame = frameData.Frame
                local left, bottom = frame:GetLeft(), frame:GetBottom()
                if (left) then
                    local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
                    entry.point = {x = left * scale, y = bottom * scale}
                end
            end

            --pre-snap dimensions so Unsnap can restore the original size across /reload sessions
            if (frameData.originalWidth) then
                entry.originalWidth = frameData.originalWidth
                entry.originalHeight = frameData.originalHeight
            end

            data[frameData.id] = entry
        end
    end,

    ---rebuilds snap links and cluster positions from the profile table. Safe to call repeatedly:
    ---it only creates links whose two frames are both registered, so it can be re-run as more
    ---frames register (RegisterFrame calls it automatically). The addon may also call it explicitly
    ---once all of its frames have been registered.
    ---@param self snapgroup
    TryRestore = function(self)
        if (not self.profileTable) then
            return
        end

        local data = self.profileTable[self.groupName]
        if (not data) then
            return
        end

        --recreate links, but only between frames that are both currently registered
        for id, entry in pairs(data) do
            local frameData = self.framesById[id]
            if (frameData) then
                --restore the pre-snap size record first so Unsnap (or a later TryRestore round) has it
                if (entry.originalWidth and not frameData.originalWidth) then
                    frameData.originalWidth = entry.originalWidth
                    frameData.originalHeight = entry.originalHeight
                end
            end
            if (frameData and entry.links) then
                for side, savedLink in pairs(entry.links) do
                    local targetData = self.framesById[savedLink.targetId]
                    if (targetData and not frameData.links[side]) then
                        frameData.links[side] = {
                            Target = targetData.Frame, targetData = targetData,
                            mySide = savedLink.mySide, theirSide = savedLink.theirSide,
                            offsetX = savedLink.offsetX, offsetY = savedLink.offsetY,
                        }
                    end
                end
            end
        end

        --place each saved root at its stored position, then rebuild its cluster so children chain off it
        for id, entry in pairs(data) do
            local frameData = self.framesById[id]
            if (frameData and entry.point) then
                local frame = frameData.Frame
                local scale = UIParent:GetEffectiveScale() / frame:GetEffectiveScale()
                frame:ClearAllPoints()
                frame:SetPoint("bottomleft", UIParent, "bottomleft", entry.point.x * scale, entry.point.y * scale)
                frameData.isRoot = true
                snapRebuildCluster(frameData)
            end
        end
    end,
}

---creates a new snap group. Frames registered into the same group can snap to each other; frames
---in different groups never interact. Each call returns an isolated instance (DetailsFramework
---mixin pattern), so create as many groups as the addon needs.
---@param groupName string identifies the group; also the key the group's data is stored under inside profileTable
---@param profileTable table|nil saved-variables table for persistence; this group's data lives at profileTable[groupName]
---@param options table|nil overrides merged on top of the snap defaults (snap_distance, hysteresis, ...)
---@return snapgroup
function detailsFramework:CreateSnapGroup(groupName, profileTable, options)
    assert(type(groupName) == "string", "detailsFramework:CreateSnapGroup(groupName): groupName must be a string.")

    ---@type snapgroup
    ---@diagnostic disable-next-line: missing-fields
    local snapGroup = {}
    snapGroup.groupName = groupName
    snapGroup.profileTable = profileTable
    snapGroup.options = snapMergeOptions(options)
    snapGroup.registeredFrames = {}
    snapGroup.framesByObject = {}
    snapGroup.framesById = {}
    snapGroup.currentCandidate = nil
    snapGroup.__dragElapsed = 0

    --a dedicated frame drives the throttled proximity scan; shown only while a drag is in progress
    snapGroup.UpdateFrame = CreateFrame("frame", nil, UIParent)
    snapGroup.UpdateFrame:Hide()
    snapGroup.UpdateFrame:SetScript("OnUpdate", function(_, deltaTime)
        snapGroup:OnDragUpdate(deltaTime)
    end)

    detailsFramework:Mixin(snapGroup, snapGroupMixin)

    --if a profile table was supplied, restore whatever relationships it already describes
    snapGroup:TryRestore()

    return snapGroup
end

--[=[
    minimal working example: two draggable frames that snap to each other.
    guarded by the EXAMPLE_ENABLED constant so it stays inert in production; flip it to true to try it live.

    drag one frame near the other's edge -> the two touching edges glow; release to snap them into a
    chain. moving either frame afterwards moves the whole cluster together. snapGroup:Unsnap(frame)
    detaches a frame again.
--]=]
--constants
local EXAMPLE_ENABLED = false

C_Timer.After(1, function()
    if (not EXAMPLE_ENABLED) then
        return
    end

    --create a snap group with an in-memory profile table; in real usage pass the addon's saved vars
    local exampleProfile = {}
    local snapGroup = detailsFramework:CreateSnapGroup("SnapExample", exampleProfile, {snap_distance = 16})

    --builds one demo frame, makes it draggable and registers it into the snap group above.
    local createDemoFrame = function(name, red, green, blue)
        local frame = CreateFrame("frame", name, UIParent, "BackdropTemplate")
        frame:SetSize(160, 120)
        frame:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]})
        frame:SetBackdropColor(red, green, blue, 1)

        --the frame must already be draggable before being registered; RegisterFrame wraps these hooks
        detailsFramework:MakeDraggable(frame)
        snapGroup:RegisterFrame(frame)
        return frame
    end

    local frameA = createDemoFrame("DFSnapExampleA", 0.2, 0.4, 0.7)
    local frameB = createDemoFrame("DFSnapExampleB", 0.7, 0.3, 0.2)
    
    frameA:SetPoint("center", UIParent, "center", -120, 0)
    frameB:SetPoint("center", UIParent, "center", 120, 0)
end)

--[=[
    Optimization strategies (already applied / easy to extend):
        - Proximity scans run only while a drag is active and are throttled by options.update_interval,
          never every frame and never when idle.
        - Each scan is group-scoped: it iterates only the frames registered in that group, not a
          full-screen sweep. Splitting frames into several smaller groups further cuts the cost.
        - Edge math uses simple O(1) distance/overlap comparisons per side; no allocations in the hot
          path except the single reused candidate table.
        - Hysteresis (options.hysteresis) keeps the chosen candidate stable, avoiding repeated glow
          texture re-anchoring while the cursor hovers between two edges.
        - For very large groups, a spatial bucket / grid index over frame centers could replace the
          linear scan in snapFindCandidate without changing the public API.

    Extending later:
        - Corner snapping: add diagonal pairings (e.g. TOPLEFT<->TOPLEFT) in SNAP_OPPOSITE/SNAP_AXIS
          and a matching branch in snapEvaluatePair; the preview/anchor pipeline is already generic.
        - Grid snapping: add an optional virtual grid target to snapFindCandidate (snap edges to the
          nearest grid line when no frame candidate is closer), reusing snapComputeOffset for the math.
        - Two-point flush snap: aligning both endpoints of the connecting side at once (so the dragged
          frame stretches to match the target's perpendicular dimension) would require giving up
          StartMoving for cluster drag, because Blizzard's anchor propagation is unreliable with
          two-point chains. Worth doing only if the stretch behavior is explicitly wanted.
--]=]

