
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
        snapGroup:RegisterFrame(frame[, id[, frameOptions]])
        snapGroup:UnregisterFrame(frame)
        snapGroup:IsRegistered(frame)
        snapGroup:StartDrag(frame) / snapGroup:StopDrag(frame) / snapGroup:CancelDrag()
        snapGroup:Link(frame, side, targetFrame) / snapGroup:Unlink(frame, side)
        snapGroup:Unsnap(frame)
        snapGroup:GetLinks(frame) / snapGroup:GetCluster(frame) / snapGroup:GetAxisCluster(frame, axis)
        snapGroup:RefreshCluster(frame) / snapGroup:RefreshAllClusters()
        snapGroup:BeginBatch() / snapGroup:EndBatch()
        snapGroup:SetProfileTable(newTable)
        snapGroup:SetOptionsTable(newOptionsTable)
        snapGroup:Reset()

    Behavior summary:
        - The frame must already be movable. By default RegisterFrame wraps its OnDragStart/OnDragStop; an
          addon that moves its frames from other scripts passes frameOptions.wrap_drag_scripts = false and
          calls StartDrag/StopDrag itself.
        - While dragging, edges within options.snap_distance of another group frame trigger a live
          glow preview on the two connecting edges (closest candidate wins, with hysteresis so it
          does not jitter).
        - On drop over a valid candidate the frames are anchored together (ClearAllPoints + SetPoint),
          forming a persistent chain. Dragging any member of a chain moves the whole cluster.
        - frameOptions.GetInsets lets a frame declare decorations drawn outside of its rect (title bars,
          status bars); detection, glow, anchors and size matching all use the outer rect.
        - Snapped relationships and cluster positions persist to profileTable[groupName].
        - Links are only broken by the explicit Unsnap()/Unlink()/UnregisterFrame()/Reset() API.
--]=]

--constants
--the four snappable sides mapped to the side they connect to on the other frame.
--sides are stored lowercase so they can be passed straight to frame:SetPoint without conversion.
local SNAP_OPPOSITE = {left = "right", right = "left", top = "bottom", bottom = "top"}
--which axis each side lives on; the gap between connecting edges is measured along this axis.
local SNAP_AXIS = {left = "x", right = "x", top = "y", bottom = "y"}
--smallest size a frame is set to when matching sizes, avoids negative sizes from large insets
local SNAP_MIN_SIZE = 1

--default options for a snap group; merged with the caller's overrides on creation / SetOptionsTable().
--keys use snake_case because this table is exposed to the addon profile as user configuration.
local SNAP_DEFAULT_OPTIONS = {
    snap_distance = 12,         --max screen-pixel gap between two edges to be treated as a snap candidate
    hysteresis = 4,             --a new candidate must be this many pixels closer than the current one to replace it
    update_interval = 0.015,    --seconds between proximity scans while dragging (throttle, avoids per-frame cost)
    glow_thickness = 3,         --thickness in pixels of the edge highlight
    glow_color = {1, 0.82, 0, 0.9},
    enabled_sides = {left = true, right = true, top = true, bottom = true},
    allow_new_snaps = true,     --false keeps existing clusters moving together but no new snap is made
    space_between_horizontal = 0, --UIParent units left empty between two frames snapped side by side
    space_between_vertical = 0, --UIParent units left empty between two frames snapped on top of each other
    restore_size_on_unsnap = true, --unsnapping a frame gives it back the size it had before its first snap
    clamp_cluster = true,       --while dragging a cluster, keep the whole cluster inside the screen
    on_links_changed = nil,     --function(snapGroup) called after links are created or removed
    on_drag_cancelled = nil,    --function(snapGroup, frame) called when a drag ends without StopDrag (frame hidden or unregistered)
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

--returns the decoration insets of a frame in the frame's own units: how far its visible area extends
--past its left, right, top and bottom edges. frames without a GetInsets callback have none.
local snapGetInsets = function(frameData)
    if (frameData.GetInsets) then
        local left, right, top, bottom = frameData.GetInsets(frameData.Frame)
        return left or 0, right or 0, top or 0, bottom or 0
    end
    return 0, 0, 0, 0
end

--returns the outer bounds of a frame (frame rect plus its insets) in absolute screen pixels as left,
--bottom, right, top. converting to screen pixels lets frames living under parents with different scales
--be compared directly.
local snapGetScreenRect = function(frameData)
    local frame = frameData.Frame
    local left = frame:GetLeft()
    local bottom = frame:GetBottom()

    if (not left or not bottom) then
        return nil
    end

    local insetLeft, insetRight, insetTop, insetBottom = snapGetInsets(frameData)
    local scale = frame:GetEffectiveScale()
    local width = frame:GetWidth()
    local height = frame:GetHeight()

    return (left - insetLeft) * scale, (bottom - insetBottom) * scale, (left + width + insetRight) * scale, (bottom + height + insetTop) * scale
end

--returns the configured space between two snapped frames along an axis, in screen pixels.
local snapGetSpaceBetween = function(group, axis)
    local space
    if (axis == "x") then
        space = group.options.space_between_horizontal
    else
        space = group.options.space_between_vertical
    end
    return space * UIParent:GetEffectiveScale()
end

--true when the group is currently allowed to make new snaps.
local snapIsSnappingAllowed = function(group)
    return group.options.allow_new_snaps and group.options.snap_distance > 0
end

--lazily builds (or returns) the 4 edge-highlight textures used to preview a snap on a frame.
--the textures live on frameOptions.GlowParent when given (so they draw above the frame's own content),
--otherwise on the frame itself, inheriting its scale and strata.
local snapGetGlowTextures = function(frameData)
    if (frameData.Glow) then
        return frameData.Glow
    end

    local glowParent = frameData.GlowParent or frameData.Frame
    local glow = {}
    for side in pairs(SNAP_OPPOSITE) do
        local texture = glowParent:CreateTexture(nil, "overlay")
        texture:SetColorTexture(1, 1, 1, 1)
        texture:Hide()
        glow[side] = texture
    end

    frameData.Glow = glow
    return glow
end

--shows the highlight texture for a single side (positioned along that outer edge) and hides the other three.
local snapShowGlow = function(frameData, side, options)
    local frame = frameData.Frame
    local glow = snapGetGlowTextures(frameData)
    local thickness = options.glow_thickness
    local color = options.glow_color
    local insetLeft, insetRight, insetTop, insetBottom = snapGetInsets(frameData)

    for thisSide, texture in pairs(glow) do
        if (thisSide == side) then
            texture:ClearAllPoints()
            if (thisSide == "left") then
                texture:SetPoint("topleft", frame, "topleft", -insetLeft, insetTop)
                texture:SetPoint("bottomleft", frame, "bottomleft", -insetLeft, -insetBottom)
                texture:SetWidth(thickness)

            elseif (thisSide == "right") then
                texture:SetPoint("topright", frame, "topright", insetRight, insetTop)
                texture:SetPoint("bottomright", frame, "bottomright", insetRight, -insetBottom)
                texture:SetWidth(thickness)

            elseif (thisSide == "top") then
                texture:SetPoint("topleft", frame, "topleft", -insetLeft, insetTop)
                texture:SetPoint("topright", frame, "topright", insetRight, insetTop)
                texture:SetHeight(thickness)

            elseif (thisSide == "bottom") then
                texture:SetPoint("bottomleft", frame, "bottomleft", -insetLeft, -insetBottom)
                texture:SetPoint("bottomright", frame, "bottomright", insetRight, -insetBottom)
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
local snapHideGlow = function(frameData)
    if (frameData.Glow) then
        for side, texture in pairs(frameData.Glow) do
            texture:Hide()
        end
    end
end

--evaluates one side pairing: the dragged frame's `side` edge connecting to the other frame's
--opposite edge. returns:
--  primaryGap: screen-pixel distance between where the dragged edge is and where it would be once snapped
--              (used for the snap_distance threshold)
--  perpendicularMisalignment: screen-pixel distance between the two frames' centers along the
--                             perpendicular axis (used as the tiebreaker so that when two candidates
--                             have the same primary gap, the one the dragged frame is more visually
--                             centered on wins -- e.g. dragging below frame A vs below frame B where
--                             A and B share a bottom edge, A wins if the dragged frame is mostly
--                             under A.)
--returns nil when the frames don't overlap enough on the perpendicular axis to be facing each other.
--rects are passed as (left, bottom, right, top) in screen pixels, spaceBetween is in screen pixels.
local snapEvaluatePair = function(draggedLeft, draggedBottom, draggedRight, draggedTop, otherLeft, otherBottom, otherRight, otherTop, side, snapDistance, spaceBetween)
    local axis = SNAP_AXIS[side]
    local primaryGap, perpendicularOverlap, perpendicularMisalignment

    if (axis == "x") then
        --left/right pairings connect along x: measure the horizontal gap between the connecting edges
        if (side == "left") then
            primaryGap = math.abs((draggedLeft - otherRight) - spaceBetween)       --dragged left edge meets other right edge
        else
            primaryGap = math.abs((otherLeft - draggedRight) - spaceBetween)       --dragged right edge meets other left edge
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
            primaryGap = math.abs((draggedBottom - otherTop) - spaceBetween)       --dragged bottom edge meets other top edge
        else
            primaryGap = math.abs((otherBottom - draggedTop) - spaceBetween)       --dragged top edge meets other bottom edge
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

--scores one possible snap of the dragged frame's `side` onto targetData. returns the score (smaller is
--better) or nil when the pairing is not valid right now: target hidden or in the dragged cluster, side
--disabled or already taken on either frame, or edges out of range.
local snapScorePairing = function(group, draggedData, targetData, side)
    local options = group.options
    local targetFrame = targetData.Frame

    if (targetFrame == draggedData.Frame or not targetFrame:IsVisible()) then
        return nil
    end

    local clusterLookup = group.__dragClusterLookup
    if (clusterLookup and clusterLookup[targetFrame]) then
        return nil
    end

    --skip sides that would conflict with a link already attached on either frame.
    --without this, a frame already snapped on its right edge would still be offered
    --as a candidate against its right edge, and dropping there would visually overlap
    --the frame already chained on that side.
    local theirSide = SNAP_OPPOSITE[side]
    if (not options.enabled_sides[side] or draggedData.links[side] or targetData.links[theirSide]) then
        return nil
    end

    local draggedLeft, draggedBottom, draggedRight, draggedTop = snapGetScreenRect(draggedData)
    local otherLeft, otherBottom, otherRight, otherTop = snapGetScreenRect(targetData)
    if (not draggedLeft or not otherLeft) then
        return nil
    end

    local snapDistance = options.snap_distance
    local spaceBetween = snapGetSpaceBetween(group, SNAP_AXIS[side])
    local primaryGap, perpendicularMisalignment = snapEvaluatePair(draggedLeft, draggedBottom, draggedRight, draggedTop, otherLeft, otherBottom, otherRight, otherTop, side, snapDistance, spaceBetween)

    --primaryGap gates validity (snap_distance threshold); the score combines it
    --with the perpendicular misalignment so that, when two candidates have the
    --same primary gap (e.g. two size-matched frames sharing the same bottom edge),
    --the one the dragged frame is more visually centered under wins.
    if (primaryGap and primaryGap <= snapDistance) then
        return primaryGap + perpendicularMisalignment
    end

    return nil
end

--scans every other frame in the group for the closest valid snap candidate to the dragged frame.
--frames belonging to the dragged frame's own cluster are skipped (a frame cannot snap onto its own chain).
--returns a candidate table {TargetFrame, targetData, side, theirSide, score} or nil.
local snapFindCandidate = function(group, draggedData)
    local best, bestScore
    local frames = group.registeredFrames

    for i = 1, #frames do
        local targetData = frames[i]
        for side in pairs(SNAP_OPPOSITE) do
            local score = snapScorePairing(group, draggedData, targetData, side)
            if (score and (not bestScore or score < bestScore)) then
                bestScore = score
                best = best or {}
                best.TargetFrame = targetData.Frame
                best.targetData = targetData
                best.side = side
                best.theirSide = SNAP_OPPOSITE[side]
                best.score = score
            end
        end
    end

    return best
end

--removes the live preview glow from both frames of the current candidate and forgets the candidate.
local snapClearPreview = function(group, draggedData)
    local current = group.currentCandidate
    if (current) then
        snapHideGlow(draggedData)
        snapHideGlow(current.targetData)
        group.currentCandidate = nil
    end
end

--updates the live snap preview while dragging: resolves the nearest candidate, applies hysteresis so
--the chosen edges stay stable instead of flickering, and moves the edge glow to the connecting edges
--of both frames. clears the preview immediately when no candidate exists.
local snapUpdatePreview = function(group, draggedData)
    if (not snapIsSnappingAllowed(group)) then
        snapClearPreview(group, draggedData)
        return
    end

    --re-score the pairing being previewed, it may have gone out of range or its target may be gone
    local current = group.currentCandidate
    if (current) then
        local currentScore = snapScorePairing(group, draggedData, current.targetData, current.side)
        if (currentScore) then
            current.score = currentScore
        else
            snapClearPreview(group, draggedData)
            current = nil
        end
    end

    local newCandidate = snapFindCandidate(group, draggedData)
    if (not newCandidate) then
        return
    end

    if (current) then
        if (current.TargetFrame == newCandidate.TargetFrame and current.side == newCandidate.side) then
            --same pairing as before, the glow is already in place
            return
        end

        if (newCandidate.score >= current.score - group.options.hysteresis) then
            --a different pairing exists but is not meaningfully closer, keep the current preview stable
            return
        end

        snapClearPreview(group, draggedData)
    end

    snapShowGlow(draggedData, newCandidate.side, group.options)
    snapShowGlow(newCandidate.targetData, newCandidate.theirSide, group.options)
    group.currentCandidate = newCandidate
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

--like snapCollectCluster but only follows links of one axis ("x" for left/right, "y" for top/bottom).
--frames in the x-axis cluster share their outer height, frames in the y-axis cluster share their outer width.
local snapCollectAxisCluster = function(frameData, axis)
    local list = {}
    local visited = {[frameData.Frame] = true}
    local queue = {frameData}

    while (#queue > 0) do
        local current = table.remove(queue)
        list[#list+1] = current
        for side, link in pairs(current.links) do
            if (SNAP_AXIS[side] == axis and not visited[link.Target]) then
                visited[link.Target] = true
                queue[#queue+1] = link.targetData
            end
        end
    end

    return list
end

--true when every anchor of the frame points at UIParent (or at its parent with no relative frame given),
--i.e. the frame is placed on the screen and not on another frame
local snapIsAnchoredToScreen = function(frame)
    local numPoints = frame:GetNumPoints()
    if (numPoints == 0) then
        return false
    end

    for i = 1, numPoints do
        local point, relativeTo = frame:GetPoint(i)
        if (relativeTo and relativeTo ~= UIParent) then
            return false
        end
    end
    return true
end

--detaches a frame from whatever it is anchored to and re-pins it to UIParent at the exact same
--on-screen spot, so it can act as the absolute-positioned root of its cluster. a frame already anchored
--to the screen keeps its own anchor: the addon placed it there (e.g. relative to a screen corner) and
--that anchor follows ui scale and resolution changes better than a bottomleft offset would.
local snapMakeAbsolute = function(frame)
    if (snapIsAnchoredToScreen(frame)) then
        return
    end

    local left, bottom = frame:GetLeft(), frame:GetBottom()
    if (not left) then
        return
    end

    --GetLeft/GetBottom and SetPoint offsets are both in the frame's own units, and UIParent's bottomleft
    --is the screen origin, so the frame's own left/bottom keep it exactly where it is at any scale
    frame:ClearAllPoints()
    frame:SetPoint("bottomleft", UIParent, "bottomleft", left, bottom)
end

--module-level re-entrancy guard: above zero while the snap system is changing links, anchors or sizes.
--the size hooks installed by RegisterFrame skip propagation while it is set. this matters because size
--events can fire synchronously in the middle of that work: SetHeight/SetWidth fire the secure hooks, and
--even reading a size (GetWidth) can make the client resolve the layout and fire OnSizeChanged right away.
--a propagation started mid-work would read isRoot flags that are not updated yet, pick the wrong cluster
--root and re-anchor in the opposite direction, creating an anchor cycle ("Cannot anchor to a region
--dependent on it") when the outer SetPoint completes.
local snapGuardDepth = 0

--runs func with the re-entrancy guard raised. an error inside is sent to the error handler and the guard
--is lowered anyway, so a single error can't leave size sync disabled for the rest of the session.
local snapRunGuarded = function(func, ...)
    snapGuardDepth = snapGuardDepth + 1
    local results
    local packResults = function(...)
        results = {n = select("#", ...), ...}
    end
    packResults(xpcall(func, geterrorhandler(), ...))
    snapGuardDepth = snapGuardDepth - 1
    return unpack(results, 2, results.n)
end

--remembers the size a frame had after the snap system last touched it; size hooks compare against this
--to skip work when nothing actually changed (several hooks fire for a single resize).
local snapRecordSize = function(frameData)
    frameData.lastWidth = frameData.Frame:GetWidth()
    frameData.lastHeight = frameData.Frame:GetHeight()
end

--returns the size childData must have so its outer size (frame size plus insets) matches the outer size
--of referenceData. axis "x" (side by side) returns a height, axis "y" (stacked) returns a width.
--computed in screen pixels so frames with different scales still match on screen.
local snapGetMatchedSize = function(childData, referenceData, axis)
    local childScale = childData.Frame:GetEffectiveScale()
    local referenceScale = referenceData.Frame:GetEffectiveScale()
    local referenceLeft, referenceRight, referenceTop, referenceBottom = snapGetInsets(referenceData)
    local childLeft, childRight, childTop, childBottom = snapGetInsets(childData)

    local size
    if (axis == "x") then
        local outerHeight = (referenceData.Frame:GetHeight() + referenceTop + referenceBottom) * referenceScale
        size = outerHeight / childScale - childTop - childBottom
    else
        local outerWidth = (referenceData.Frame:GetWidth() + referenceLeft + referenceRight) * referenceScale
        size = outerWidth / childScale - childLeft - childRight
    end

    return math.max(size, SNAP_MIN_SIZE)
end

--returns the SetPoint offsets (in the child's units) that place the child next to its parent: the outer
--edges touch (plus the configured space between) and the outer rects are centered on each other along
--the shared side.
local snapGetAnchorOffsets = function(group, childData, parentData, childSide)
    local childScale = childData.Frame:GetEffectiveScale()
    local parentScale = parentData.Frame:GetEffectiveScale()
    local parentLeft, parentRight, parentTop, parentBottom = snapGetInsets(parentData)
    local childLeft, childRight, childTop, childBottom = snapGetInsets(childData)
    local spaceBetween = snapGetSpaceBetween(group, SNAP_AXIS[childSide])

    --offsets are computed in screen pixels, then converted to the child's units
    local offsetX, offsetY

    if (childSide == "left") then
        --child sits on the right of the parent
        offsetX = parentRight * parentScale + childLeft * childScale + spaceBetween
        offsetY = ((parentTop - parentBottom) * parentScale - (childTop - childBottom) * childScale) / 2

    elseif (childSide == "right") then
        --child sits on the left of the parent
        offsetX = -(parentLeft * parentScale + childRight * childScale + spaceBetween)
        offsetY = ((parentTop - parentBottom) * parentScale - (childTop - childBottom) * childScale) / 2

    elseif (childSide == "top") then
        --child sits below the parent
        offsetX = ((parentRight - parentLeft) * parentScale - (childRight - childLeft) * childScale) / 2
        offsetY = -(parentBottom * parentScale + childTop * childScale + spaceBetween)

    else
        --child sits above the parent
        offsetX = ((parentRight - parentLeft) * parentScale - (childRight - childLeft) * childScale) / 2
        offsetY = parentTop * parentScale + childBottom * childScale + spaceBetween
    end

    return offsetX / childScale, offsetY / childScale
end

--applies a snap anchor between a child frame and its parent: a single SetPoint at the midpoint of
--the connecting side, plus an explicit SetHeight/SetWidth that matches the child's outer size to the
--parent's along the shared side. used uniformly at rest and during drag, because:
-- (a) Blizzard's StartMoving propagates position reliably with one anchor per child but not two,
--     so the cluster has to stay single-anchored to be draggable as a unit.
-- (b) the explicit size match keeps the connecting edges flush at both ends, giving the two-anchor
--     visual without a second anchor.
-- live resize propagation through the cluster does NOT come from anchors (the owning addon's
-- resize logic often calls ClearAllPoints which breaks any anchor chain); it comes from the size
-- hooks installed by RegisterFrame, see snapPropagateSize below.
local snapApplyAnchor = function(group, childData, parentData, childSide, parentSide)
    local childFrame = childData.Frame
    local parentFrame = parentData.Frame

    childFrame:ClearAllPoints()
    local matchedSize = snapGetMatchedSize(childData, parentData, SNAP_AXIS[childSide])
    if (SNAP_AXIS[childSide] == "x") then
        childFrame:SetHeight(matchedSize)
    else
        childFrame:SetWidth(matchedSize)
    end

    local offsetX, offsetY = snapGetAnchorOffsets(group, childData, parentData, childSide)
    childFrame:SetPoint(childSide, parentFrame, parentSide, offsetX, offsetY)
    snapRecordSize(childData)
end

--re-applies the anchor of every non-root member of rootData's cluster, walking it as a spanning tree.
--the root itself is not touched. links that would close a cycle are ignored for anchoring, which
--guarantees there are never recursive or broken point chains.
local snapAnchorChildren = function(group, rootData)
    local rootFrame = rootData.Frame
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

                childData.isRoot = false

                --find the child's own link pointing back at this parent and use it to anchor the child
                for childSide, childLink in pairs(childData.links) do
                    if (childLink.Target == parentFrame) then
                        snapApplyAnchor(group, childData, parentData, childLink.mySide, childLink.theirSide)
                        break
                    end
                end

                queue[#queue+1] = childData
            end
        end
    end
end

--makes rootData the absolute-positioned root of its cluster and re-chains every other member off it.
local snapRebuildCluster = function(group, rootData)
    --the root holds the cluster's absolute position; make sure it is not anchored to a member
    snapMakeAbsolute(rootData.Frame)
    rootData.isRoot = true
    snapRecordSize(rootData)
    snapAnchorChildren(group, rootData)
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

--called from the size hooks installed by RegisterFrame when a registered frame changes size:
--  1. the frames sharing an axis with the resized frame take its outer size: frames linked side by side
--     (x-axis cluster) take its outer height, frames stacked with it (y-axis cluster) take its outer
--     width. this is done for the axis clusters of the resized frame itself, so a resize anywhere in the
--     cluster sticks, even on a branch whose axis does not reach the cluster root.
--  2. the whole cluster's snap chain is re-applied from the root. this is what KEEPS THE WINDOWS ALIGNED
--     after a resize: the addon owning the frame frequently calls ClearAllPoints or SetPoint inside its
--     own resize handler, wiping our snap anchors.
local snapPropagateSizeGuarded
local snapPropagateSize = function(group, originData)
    if (snapGuardDepth > 0 or group.__batchDepth > 0) then
        return
    end
    snapRunGuarded(snapPropagateSizeGuarded, group, originData)
end

snapPropagateSizeGuarded = function(group, originData)

    local originFrame = originData.Frame
    local newWidth = originFrame:GetWidth()
    local newHeight = originFrame:GetHeight()

    --several hooks fire for a single resize; skip when the size is what the snap system last saw
    if (originData.lastWidth == newWidth and originData.lastHeight == newHeight) then
        return
    end

    if (not next(originData.links)) then
        snapRecordSize(originData)
        return
    end

    --step 1: push the resized frame's outer size onto the frames sharing each axis with it
    local sideBySide = snapCollectAxisCluster(originData, "x")
    for i = 1, #sideBySide do
        local memberData = sideBySide[i]
        if (memberData ~= originData) then
            memberData.Frame:SetHeight(snapGetMatchedSize(memberData, originData, "x"))
        end
    end

    local stacked = snapCollectAxisCluster(originData, "y")
    for i = 1, #stacked do
        local memberData = stacked[i]
        if (memberData ~= originData) then
            memberData.Frame:SetWidth(snapGetMatchedSize(memberData, originData, "y"))
        end
    end

    --step 2: re-apply snap anchors for every non-root cluster member. the root is not re-anchored, so a
    --root being sized by the engine (StartSizing) is not disturbed.
    local rootData = snapGetRoot(originData)
    snapRecordSize(rootData)
    snapAnchorChildren(group, rootData)
    snapRecordSize(originData)
end

--sets or clears the clamp insets of a dragged frame so its whole cluster (outer rects included) stays
--inside the screen while it moves. the frame's own insets are saved and given back when the drag ends.
local snapApplyDragClamp = function(group, frameData, clusterList)
    local frame = frameData.Frame
    if (not group.options.clamp_cluster or not frame:IsClampedToScreen()) then
        return
    end

    local frameLeft, frameBottom = frame:GetLeft(), frame:GetBottom()
    if (not frameLeft) then
        return
    end

    local unionLeft, unionBottom, unionRight, unionTop = snapGetScreenRect(frameData)
    for i = 1, #clusterList do
        local left, bottom, right, top = snapGetScreenRect(clusterList[i])
        if (left) then
            unionLeft = math.min(unionLeft, left)
            unionBottom = math.min(unionBottom, bottom)
            unionRight = math.max(unionRight, right)
            unionTop = math.max(unionTop, top)
        end
    end

    local scale = frame:GetEffectiveScale()
    local frameRight = (frameLeft + frame:GetWidth()) * scale
    local frameTop = (frameBottom + frame:GetHeight()) * scale
    frameLeft = frameLeft * scale
    frameBottom = frameBottom * scale

    frameData.savedClampInsets = {frame:GetClampRectInsets()}
    --negative left/bottom and positive right/top extend the clamp rect past the frame
    frame:SetClampRectInsets(-(frameLeft - unionLeft) / scale, (unionRight - frameRight) / scale, (unionTop - frameTop) / scale, -(frameBottom - unionBottom) / scale)
end

--gives back the clamp insets the dragged frame had before the drag started.
local snapRestoreDragClamp = function(frameData)
    local savedInsets = frameData.savedClampInsets
    if (savedInsets) then
        frameData.Frame:SetClampRectInsets(savedInsets[1], savedInsets[2], savedInsets[3], savedInsets[4])
        frameData.savedClampInsets = nil
    end
end

--snapped frames are anchored at the midpoint of their connecting side AND have their outer perpendicular
--dimension matched to the target's, so the connecting edges line up flush at both ends. the SetPoint
--offsets only carry the insets and the space between frames, they are computed from the current insets
--every time a chain is applied, so the offsetX/offsetY stored on links stay 0.

---@class snaplink : table a directed snap relationship: frame:SetPoint(mySide, Target, theirSide, offsetX, offsetY)
---@field Target frame the frame on the other end of the link
---@field targetData snapframedata the registration data of the target frame
---@field mySide string the side of the owning frame used as the anchor point
---@field theirSide string the side of the target frame the owning frame anchors to
---@field offsetX number kept at 0, offsets are computed from insets when the chain is applied
---@field offsetY number kept at 0, offsets are computed from insets when the chain is applied

---@class snapframeoptions : table optional per-frame settings given to RegisterFrame
---@field wrap_drag_scripts boolean|nil false: do not touch OnDragStart/OnDragStop, the addon calls StartDrag/StopDrag
---@field GetInsets fun(frame: frame): number, number, number, number|nil returns left, right, top, bottom decoration sizes in the frame's units
---@field GlowParent frame|nil frame the preview glow textures are created on

---@class snapframedata : table the per-frame registration record stored by a snap group
---@field Frame frame the registered frame
---@field id string the stable identifier (explicit id or frame name) used for persistence
---@field links table<string, snaplink> directed snap links keyed by the owning frame's side
---@field isRoot boolean true when this frame holds its cluster's absolute UIParent anchor
---@field group snapgroup the owning snap group
---@field wrapsDragScripts boolean true when RegisterFrame replaced the frame's drag scripts
---@field GetInsets function|nil decoration insets callback
---@field GlowParent frame|nil frame holding the glow textures
---@field Glow table<string, texture>|nil the glow textures, created on first use
---@field OrigOnDragStart function|nil the frame's OnDragStart script captured before wrapping
---@field OrigOnDragStop function|nil the frame's OnDragStop script captured before wrapping
---@field originalWidth number|nil pre-snap width captured on the first snap; restored by Unsnap
---@field originalHeight number|nil pre-snap height captured on the first snap; restored by Unsnap
---@field lastWidth number|nil width the snap system last saw, used to skip duplicated size hooks
---@field lastHeight number|nil height the snap system last saw
---@field savedClampInsets table|nil clamp insets the frame had before a cluster drag

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
---@field __hookedFrames table<frame, boolean> frames that already carry this group's size hooks
---@field __batchDepth number how many BeginBatch calls are open
---@field __hasPendingNotify boolean links changed during a batch, notify when it ends
---@field __isResetting boolean true while Reset tears the group down
---@field RegisterFrame fun(self: snapgroup, frame: frame, id: string?, frameOptions: snapframeoptions?)
---@field UnregisterFrame fun(self: snapgroup, frame: frame)
---@field IsRegistered fun(self: snapgroup, frame: frame): boolean
---@field IsDragging fun(self: snapgroup): boolean
---@field StartDrag fun(self: snapgroup, frame: frame): boolean
---@field StopDrag fun(self: snapgroup, frame: frame): boolean
---@field CancelDrag fun(self: snapgroup)
---@field Link fun(self: snapgroup, frame: frame, side: string, targetFrame: frame): boolean
---@field Unlink fun(self: snapgroup, frame: frame, side: string): boolean
---@field Unsnap fun(self: snapgroup, frame: frame)
---@field GetLinks fun(self: snapgroup, frame: frame): table<string, frame>
---@field GetCluster fun(self: snapgroup, frame: frame): frame[]
---@field GetAxisCluster fun(self: snapgroup, frame: frame, axis: string): frame[]
---@field RefreshCluster fun(self: snapgroup, frame: frame)
---@field RefreshAllClusters fun(self: snapgroup)
---@field BeginBatch fun(self: snapgroup)
---@field EndBatch fun(self: snapgroup)
---@field NotifyLinksChanged fun(self: snapgroup)
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
    ---the frame must already be movable (set up via RegisterForDrag/SetMovable). by default its existing
    ---OnDragStart/OnDragStop scripts are wrapped, not replaced; with frameOptions.wrap_drag_scripts = false
    ---they are left alone and the addon calls StartDrag/StopDrag from its own scripts.
    ---@param self snapgroup
    ---@param frame frame the frame (or a DetailsFramework widget wrapping one) to register
    ---@param id string|nil stable identifier; wins over the frame name, required when the frame has no name
    ---@param frameOptions snapframeoptions|nil optional per-frame settings
    RegisterFrame = function(self, frame, id, frameOptions)
        frame = frame.widget or frame
        --resolve the persistent identifier: explicit id first, then the frame name, else error
        id = id or frame:GetName()
        assert(id, "snapGroup:RegisterFrame(frame[, id]): the frame has no name, an 'id' must be provided.")

        if (self.framesByObject[frame]) then
            return
        end

        if (frame.IsMovable and not frame:IsMovable()) then
            detailsFramework:MsgWarning("CreateSnapGroup: RegisterFrame() received a frame that is not movable; snapping needs the frame to be draggable.")
        end

        frameOptions = frameOptions or {}

        ---@type snapframedata
        local frameData = {
            Frame = frame,
            id = id,
            links = {},     --directed snap links keyed by this frame's side -> {Target, targetData, mySide, theirSide}
            isRoot = true,  --a lone frame is the root of its own (single member) cluster
            group = self,
            wrapsDragScripts = frameOptions.wrap_drag_scripts ~= false,
            GetInsets = frameOptions.GetInsets,
            GlowParent = frameOptions.GlowParent,
        }

        self.framesByObject[frame] = frameData
        self.framesById[id] = frameData
        self.registeredFrames[#self.registeredFrames+1] = frameData
        snapRecordSize(frameData)

        if (frameData.wrapsDragScripts) then
            --wrap the frame's current drag scripts so existing behavior is preserved
            frameData.OrigOnDragStart = frame:GetScript("OnDragStart")
            frameData.OrigOnDragStop = frame:GetScript("OnDragStop")

            frame:SetScript("OnDragStart", function(_, ...)
                self:OnFrameDragStart(frameData, ...)
            end)

            frame:SetScript("OnDragStop", function(_, ...)
                self:OnFrameDragStop(frameData, ...)
            end)
        end

        --resize detection uses TWO layers, because either alone isn't reliable enough:
        --  (a) HookScript("OnSizeChanged", …) catches the event the next render frame. cheap, but
        --      can be silently lost if the owning addon later calls SetScript("OnSizeChanged", …)
        --      with its own handler.
        --  (b) hooksecurefunc on SetSize/SetHeight/SetWidth fires synchronously inside the call.
        --      hooksecurefunc hooks CANNOT be removed by anything, so they survive whatever the
        --      addon does to the frame's scripts.
        --hooks can't be removed either, so they are installed once per frame for the life of the group
        --and look up the frame's current registration when they fire; unregistering and registering the
        --same frame again does not stack more hooks.
        if (not self.__hookedFrames[frame]) then
            self.__hookedFrames[frame] = true

            local onSizeChanged = function()
                local currentData = self.framesByObject[frame]
                if (currentData) then
                    snapPropagateSize(self, currentData)
                end
            end

            frame:HookScript("OnSizeChanged", onSizeChanged)
            hooksecurefunc(frame, "SetSize", onSizeChanged)
            hooksecurefunc(frame, "SetHeight", onSizeChanged)
            hooksecurefunc(frame, "SetWidth", onSizeChanged)
        end

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

        if (self.__dragFrameData == frameData) then
            self:CancelDrag()
        end

        --a preview pointing at this frame would be left dangling
        local current = self.currentCandidate
        if (current and current.targetData == frameData and self.__dragFrameData) then
            snapClearPreview(self, self.__dragFrameData)
        end

        --cutting all links keeps the remaining cluster members validly anchored
        self:Unsnap(frame)

        --restore whatever drag scripts the frame had before it was registered
        if (frameData.wrapsDragScripts) then
            frame:SetScript("OnDragStart", frameData.OrigOnDragStart)
            frame:SetScript("OnDragStop", frameData.OrigOnDragStop)
        end
        snapHideGlow(frameData)

        self.framesByObject[frame] = nil
        self.framesById[frameData.id] = nil

        for i = #self.registeredFrames, 1, -1 do
            if (self.registeredFrames[i] == frameData) then
                table.remove(self.registeredFrames, i)
                break
            end
        end
    end,

    ---returns true when the frame is registered in this group.
    ---@param self snapgroup
    ---@param frame frame
    ---@return boolean
    IsRegistered = function(self, frame)
        frame = frame.widget or frame
        return self.framesByObject[frame] ~= nil
    end,

    ---returns true while a frame of this group is being dragged.
    ---@param self snapgroup
    ---@return boolean
    IsDragging = function(self)
        return self.__dragFrameData ~= nil
    end,

    ---starts moving a registered frame (and its cluster) as if its OnDragStart had fired. for addons that
    ---move frames from OnMouseDown or from child frames. returns false when the frame is not registered.
    ---@param self snapgroup
    ---@param frame frame
    ---@return boolean
    StartDrag = function(self, frame)
        frame = frame.widget or frame
        local frameData = self.framesByObject[frame]
        if (not frameData) then
            return false
        end
        self:OnFrameDragStart(frameData)
        return true
    end,

    ---ends the movement started by StartDrag, applying the previewed snap if there is one.
    ---returns false when the frame is not registered.
    ---@param self snapgroup
    ---@param frame frame
    ---@return boolean
    StopDrag = function(self, frame)
        frame = frame.widget or frame
        local frameData = self.framesByObject[frame]
        if (not frameData) then
            return false
        end
        self:OnFrameDragStop(frameData)
        return true
    end,

    ---ends the current drag without snapping, e.g. when the dragged frame is hidden or unregistered.
    ---@param self snapgroup
    CancelDrag = function(self)
        local frameData = self.__dragFrameData
        if (not frameData) then
            return
        end

        self.UpdateFrame:Hide()
        frameData.Frame:StopMovingOrSizing()
        snapRestoreDragClamp(frameData)
        snapClearPreview(self, frameData)

        self.__dragFrameData = nil
        self.__dragClusterLookup = nil

        snapRebuildCluster(self, frameData)
        self:SavePersistent()

        --the addon started the drag and may keep its own moving state, tell it the drag is over
        local callback = self.options.on_drag_cancelled
        if (callback) then
            callback(self, frameData.Frame)
        end
    end,

    ---links two registered frames without a drag: frame's `side` touches targetFrame's opposite side.
    ---the target's cluster keeps its place, frame's cluster moves next to it. returns false (and does
    ---nothing) when a frame is not registered, a side is already taken, or both frames are already in
    ---the same cluster (clusters never form loops).
    ---@param self snapgroup
    ---@param frame frame
    ---@param side string "left", "right", "top" or "bottom"
    ---@param targetFrame frame
    ---@return boolean
    Link = function(self, frame, side, targetFrame)
        frame = frame.widget or frame
        targetFrame = targetFrame.widget or targetFrame

        local frameData = self.framesByObject[frame]
        local targetData = self.framesByObject[targetFrame]
        local theirSide = SNAP_OPPOSITE[side]
        if (not frameData or not targetData or not theirSide or frame == targetFrame) then
            return false
        end

        --the exact same link already exists
        local existingLink = frameData.links[side]
        if (existingLink and existingLink.Target == targetFrame) then
            return true
        end

        if (existingLink or targetData.links[theirSide]) then
            return false
        end

        local clusterList, clusterLookup = snapCollectCluster(frameData)
        if (clusterLookup[targetFrame]) then
            return false
        end

        self:Snap(frameData, {TargetFrame = targetFrame, targetData = targetData, side = side, theirSide = theirSide, score = 0})
        self:SavePersistent()
        self:NotifyLinksChanged()
        return true
    end,

    ---removes the link on one side of a frame (both directions). each side of the cut keeps its own
    ---cluster at its current place. returns false when there was no link on that side.
    ---@param self snapgroup
    ---@param frame frame
    ---@param side string
    ---@return boolean
    Unlink = function(self, frame, side)
        frame = frame.widget or frame
        local frameData = self.framesByObject[frame]
        if (not frameData or not frameData.links[side]) then
            return false
        end

        local otherData = self:RemoveLink(frameData, side)

        --re-chain both sides first: the side that was anchored to the other is pinned where it is, so a
        --size restored below can't drag it along through the anchor that is being cut
        snapRebuildCluster(self, snapGetRoot(frameData))
        snapRebuildCluster(self, snapGetRoot(otherData))

        if (self.options.restore_size_on_unsnap) then
            for index, endData in ipairs({frameData, otherData}) do
                if (endData.originalWidth and next(endData.links) == nil) then
                    endData.Frame:SetSize(endData.originalWidth, endData.originalHeight)
                    endData.originalWidth = nil
                    endData.originalHeight = nil
                    snapRecordSize(endData)
                end
            end
        end

        self:SavePersistent()
        self:NotifyLinksChanged()
        return true
    end,

    ---breaks every snap link of a frame, leaving it free-standing at its current position.
    ---this is the only way (besides Unlink/UnregisterFrame/Reset) to detach a snapped frame.
    ---@param self snapgroup
    ---@param frame frame
    Unsnap = function(self, frame)
        frame = frame.widget or frame

        local frameData = self.framesByObject[frame]
        if (not frameData) then
            return
        end

        if (not next(frameData.links)) then
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

        --pin this frame and every former neighbour's cluster where they are before any size changes, so a
        --restored size can't drag a frame along through an anchor that is being cut
        snapMakeAbsolute(frame)
        frameData.isRoot = true
        for i = 1, #neighbours do
            local neighbourData = neighbours[i]
            if (self.framesByObject[neighbourData.Frame]) then
                snapRebuildCluster(self, snapGetRoot(neighbourData))
            end
        end

        --this frame now stands alone; restore its pre-snap size (captured the first time it snapped)
        --so the visual size match introduced by Snap/snapRebuildCluster is undone here.
        --a neighbour left solo (the link we just cut was its only one) gets its pre-snap size back too,
        --otherwise it would stay stretched to the old cluster's matched size.
        if (self.options.restore_size_on_unsnap) then
            if (frameData.originalWidth) then
                frame:SetSize(frameData.originalWidth, frameData.originalHeight)
                frameData.originalWidth = nil
                frameData.originalHeight = nil
            end

            for i = 1, #neighbours do
                local neighbourData = neighbours[i]
                if (self.framesByObject[neighbourData.Frame] and neighbourData.originalWidth and next(neighbourData.links) == nil) then
                    neighbourData.Frame:SetSize(neighbourData.originalWidth, neighbourData.originalHeight)
                    neighbourData.originalWidth = nil
                    neighbourData.originalHeight = nil
                    snapRecordSize(neighbourData)
                end
            end
        end
        snapRecordSize(frameData)

        self:SavePersistent()
        self:NotifyLinksChanged()
    end,

    ---returns the frames linked to a frame, keyed by the frame's side: {left = otherFrame, ...}.
    ---@param self snapgroup
    ---@param frame frame
    ---@return table<string, frame>
    GetLinks = function(self, frame)
        frame = frame.widget or frame
        local result = {}
        local frameData = self.framesByObject[frame]
        if (frameData) then
            for side, link in pairs(frameData.links) do
                result[side] = link.Target
            end
        end
        return result
    end,

    ---returns every frame of the cluster the frame belongs to, the frame itself included.
    ---@param self snapgroup
    ---@param frame frame
    ---@return frame[]
    GetCluster = function(self, frame)
        frame = frame.widget or frame
        local frameData = self.framesByObject[frame]
        if (not frameData) then
            return {frame}
        end

        local result = {}
        local clusterList = snapCollectCluster(frameData)
        for i = 1, #clusterList do
            result[i] = clusterList[i].Frame
        end
        return result
    end,

    ---returns the frames reachable from a frame through links of one axis, the frame itself included.
    ---axis "x" gives the frames side by side with it (they share height), "y" the frames stacked with it.
    ---@param self snapgroup
    ---@param frame frame
    ---@param axis string "x" or "y"
    ---@return frame[]
    GetAxisCluster = function(self, frame, axis)
        frame = frame.widget or frame
        local frameData = self.framesByObject[frame]
        if (not frameData) then
            return {frame}
        end

        local result = {}
        local axisList = snapCollectAxisCluster(frameData, axis)
        for i = 1, #axisList do
            result[i] = axisList[i].Frame
        end
        return result
    end,

    ---makes the frame the root of its cluster at its current on-screen place and re-chains the other
    ---members from it. use it after the addon positioned the frame by itself or before resizing it.
    ---with keepCurrentRoot the cluster is re-chained from the root it already has (nothing is re-rooted),
    ---use it after the frame's insets or scale changed.
    ---@param self snapgroup
    ---@param frame frame
    ---@param keepCurrentRoot boolean|nil
    RefreshCluster = function(self, frame, keepCurrentRoot)
        frame = frame.widget or frame
        local frameData = self.framesByObject[frame]
        if (not frameData) then
            return
        end

        if (keepCurrentRoot) then
            snapRebuildCluster(self, snapGetRoot(frameData))
        else
            snapRebuildCluster(self, frameData)
        end
    end,

    ---re-chains every cluster of the group from its current root, e.g. after the space between frames
    ---or the insets of many frames changed.
    ---@param self snapgroup
    RefreshAllClusters = function(self)
        local done = {}
        for i = 1, #self.registeredFrames do
            local frameData = self.registeredFrames[i]
            if (not done[frameData] and next(frameData.links)) then
                local clusterList = snapCollectCluster(frameData)
                for j = 1, #clusterList do
                    done[clusterList[j]] = true
                end
                snapRebuildCluster(self, snapGetRoot(frameData))
            end
        end
    end,

    ---starts a batch: until the matching EndBatch, size changes are not propagated through clusters
    ---and link-change notifications are held. use it while the addon restores or resizes many frames.
    ---batches can be nested.
    ---@param self snapgroup
    BeginBatch = function(self)
        self.__batchDepth = self.__batchDepth + 1
    end,

    ---ends a batch: when the last open batch ends, every cluster is re-chained from its root and a
    ---held link-change notification is sent once.
    ---@param self snapgroup
    EndBatch = function(self)
        assert(self.__batchDepth > 0, "snapGroup:EndBatch() called without a matching BeginBatch().")
        self.__batchDepth = self.__batchDepth - 1
        if (self.__batchDepth > 0) then
            return
        end

        self:RefreshAllClusters()
        for i = 1, #self.registeredFrames do
            snapRecordSize(self.registeredFrames[i])
        end

        if (self.__hasPendingNotify) then
            self.__hasPendingNotify = false
            self:NotifyLinksChanged()
        end
    end,

    ---calls options.on_links_changed, or holds the call until the current batch ends.
    ---Internal.
    ---@param self snapgroup
    NotifyLinksChanged = function(self)
        if (self.__isResetting) then
            return
        end

        if (self.__batchDepth > 0) then
            self.__hasPendingNotify = true
            return
        end

        local callback = self.options.on_links_changed
        if (callback) then
            callback(self)
        end
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

    ---swaps the group's profile table at runtime: the links of the old table are dropped (frames stay
    ---where they are, the old table is not written) and the new table's links are restored.
    ---@param self snapgroup
    ---@param newTable table
    SetProfileTable = function(self, newTable)
        for i = 1, #self.registeredFrames do
            local frameData = self.registeredFrames[i]
            if (next(frameData.links)) then
                snapMakeAbsolute(frameData.Frame)
                table.wipe(frameData.links)
            end
            frameData.isRoot = true
            --the pre-snap sizes belong to the old profile, the new one brings its own
            frameData.originalWidth = nil
            frameData.originalHeight = nil
        end

        self.profileTable = newTable
        self:TryRestore()
        self:NotifyLinksChanged()
    end,

    ---swaps the group's options at runtime; the new table is merged on top of the defaults.
    ---@param self snapgroup
    ---@param newOptionsTable table|nil
    SetOptionsTable = function(self, newOptionsTable)
        self.options = snapMergeOptions(newOptionsTable)

        --a drag in progress must not keep showing a preview the new options forbid
        if (self.__dragFrameData and not snapIsSnappingAllowed(self)) then
            snapClearPreview(self, self.__dragFrameData)
        end
    end,

    ---tears the group down to a blank, reusable state: unregisters every frame, drops the profile
    ---and options references and clears the current preview. The data already written into the old
    ---profile table is left untouched (the caller owns it). Use this on addon profile switches.
    ---@param self snapgroup
    Reset = function(self)
        --drop the profile first: unregistering unsnaps frames, and unsnapping would otherwise save the
        --half torn down layout over the caller's saved data
        self.profileTable = nil
        self.__isResetting = true

        for i = #self.registeredFrames, 1, -1 do
            self:UnregisterFrame(self.registeredFrames[i].Frame)
        end

        table.wipe(self.framesByObject)
        table.wipe(self.framesById)
        table.wipe(self.registeredFrames)
        self.options = snapMergeOptions(nil)
        self.currentCandidate = nil
        self.__dragFrameData = nil
        self.__dragClusterLookup = nil
        self.__batchDepth = 0
        self.__hasPendingNotify = false
        self.UpdateFrame:Hide()
        self.__isResetting = false
    end,

    ---starts moving the frame (or its whole cluster) and kicks off the throttled proximity scan.
    ---Internal — installed by RegisterFrame as OnDragStart, or called by StartDrag.
    ---@param self snapgroup
    ---@param frameData snapframedata
    OnFrameDragStart = function(self, frameData, ...)
        if (self.__dragFrameData) then
            --a drag is already running, a second start would leave the first one dangling
            return
        end

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
            snapRebuildCluster(self, frameData)
            snapApplyDragClamp(self, frameData, clusterList)
            frame:StartMoving()

        else
            snapApplyDragClamp(self, frameData, clusterList)
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

    ---stops the movement, then either applies the previewed snap or leaves the frame free-standing at
    ---its dropped position. Internal — installed by RegisterFrame as OnDragStop, or called by StopDrag.
    ---@param self snapgroup
    ---@param frameData snapframedata
    OnFrameDragStop = function(self, frameData, ...)
        if (self.__dragFrameData ~= frameData) then
            --this frame is not the one being dragged (e.g. a stop without a start)
            return
        end

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
        snapRestoreDragClamp(frameData)

        --the preview may be a few milliseconds old; make sure its pairing is still valid at the drop spot
        local candidate = self.currentCandidate
        if (candidate and (not snapIsSnappingAllowed(self) or not snapScorePairing(self, frameData, candidate.targetData, candidate.side))) then
            snapClearPreview(self, frameData)
            candidate = nil
        end

        --clear the preview glow regardless of the outcome
        snapClearPreview(self, frameData)

        self.__dragFrameData = nil
        self.__dragClusterLookup = nil

        if (candidate) then
            --a valid candidate was being previewed: anchor the frames together
            self:Snap(frameData, candidate)
        else
            --no candidate: the grabbed frame is the temp root of its cluster; normalize it to an
            --absolute UIParent anchor at the dropped position and re-chain its cluster.
            snapRebuildCluster(self, frameData)
        end

        self:SavePersistent()

        if (candidate) then
            self:NotifyLinksChanged()
        end
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

        --the dragged frame was hidden mid drag (window closed, ui hidden): stop the drag cleanly
        if (not frameData.Frame:IsVisible()) then
            self:CancelDrag()
            return
        end

        self.__dragElapsed = (self.__dragElapsed or 0) + deltaTime
        if (self.__dragElapsed < self.options.update_interval) then
            return
        end

        self.__dragElapsed = 0
        snapUpdatePreview(self, frameData)
    end,

    ---anchors frameData to a resolved snap candidate, merging the two clusters into one chain.
    ---Internal — called by OnFrameDragStop when a valid preview exists on drop, and by Link.
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

        --offsets stay 0 here; they are computed from the insets each time the chain is applied.
        --store the link in both directions for the chain walk.
        frameData.links[side] = {
            Target = targetFrame, targetData = targetData,
            mySide = side, theirSide = theirSide, offsetX = 0, offsetY = 0,
        }
        targetData.links[theirSide] = {
            Target = draggedFrame, targetData = frameData,
            mySide = theirSide, theirSide = side, offsetX = 0, offsetY = 0,
        }

        --rebuild the merged cluster as a spanning tree rooted at the target side's root
        snapRebuildCluster(self, rootData)

        --any frame orphaned by a replaced link becomes (or rejoins) its own valid cluster
        if (orphanA) then
            snapRebuildCluster(self, snapGetRoot(orphanA))
        end
        if (orphanB) then
            snapRebuildCluster(self, snapGetRoot(orphanB))
        end
    end,

    ---writes the group's current snap links and cluster-root positions into profileTable[groupName].
    ---Internal — called after drops, links, unlinks and unsnaps. No-op when the group has no profile table.
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
    ---once all of its frames have been registered. Saved links are validated: unknown sides, links to
    ---the frame itself, links whose side is already taken and links that would close a loop are skipped.
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

            if (frameData and type(entry.links) == "table") then
                for side, savedLink in pairs(entry.links) do
                    local theirSide = SNAP_OPPOSITE[side]
                    local targetData = type(savedLink) == "table" and self.framesById[savedLink.targetId]
                    local isValidLink = theirSide and targetData and targetData ~= frameData and savedLink.mySide == side and savedLink.theirSide == theirSide

                    if (isValidLink and not frameData.links[side]) then
                        local reciprocalLink = targetData.links[theirSide]
                        local isReciprocalFree = not reciprocalLink or reciprocalLink.Target == frameData.Frame
                        local clusterList, clusterLookup = snapCollectCluster(frameData)
                        local wouldCloseLoop = clusterLookup[targetData.Frame] and not reciprocalLink

                        if (isReciprocalFree and not wouldCloseLoop) then
                            frameData.links[side] = {
                                Target = targetData.Frame, targetData = targetData,
                                mySide = side, theirSide = theirSide, offsetX = 0, offsetY = 0,
                            }
                            targetData.links[theirSide] = {
                                Target = frameData.Frame, targetData = frameData,
                                mySide = theirSide, theirSide = side, offsetX = 0, offsetY = 0,
                            }
                        end
                    end
                end
            end
        end

        --place each saved root at its stored position, then rebuild its cluster so children chain off it
        for id, entry in pairs(data) do
            local frameData = self.framesById[id]
            if (frameData and type(entry.point) == "table") then
                local frame = frameData.Frame
                local scale = UIParent:GetEffectiveScale() / frame:GetEffectiveScale()
                frame:ClearAllPoints()
                frame:SetPoint("bottomleft", UIParent, "bottomleft", entry.point.x * scale, entry.point.y * scale)
                frameData.isRoot = true
                snapRebuildCluster(self, frameData)
            end
        end
    end,
}

--every mixin method which changes links, anchors or sizes runs with the re-entrancy guard raised
local SNAP_GUARDED_METHODS = {
    "RegisterFrame", "UnregisterFrame", "CancelDrag", "Link", "Unlink", "Unsnap", "RefreshCluster",
    "RefreshAllClusters", "EndBatch", "SetProfileTable", "Reset", "OnFrameDragStart", "OnFrameDragStop",
    "Snap", "TryRestore",
}
for index, methodName in ipairs(SNAP_GUARDED_METHODS) do
    local method = snapGroupMixin[methodName]
    snapGroupMixin[methodName] = function(...)
        return snapRunGuarded(method, ...)
    end
end

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
    snapGroup.__hookedFrames = {}
    snapGroup.__batchDepth = 0
    snapGroup.__hasPendingNotify = false
    snapGroup.__isResetting = false

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
        - Edge math uses simple O(1) distance/overlap comparisons per side.
        - Hysteresis (options.hysteresis) keeps the chosen candidate stable, avoiding repeated glow
          texture re-anchoring while the cursor hovers between two edges.
        - Size hooks skip work when the frame's size is what the snap system last saw.
        - For very large groups, a spatial bucket / grid index over frame centers could replace the
          linear scan in snapFindCandidate without changing the public API.

    Extending later:
        - Corner snapping: add diagonal pairings (e.g. TOPLEFT<->TOPLEFT) in SNAP_OPPOSITE/SNAP_AXIS
          and a matching branch in snapEvaluatePair; the preview/anchor pipeline is already generic.
        - Grid snapping: add an optional virtual grid target to snapFindCandidate (snap edges to the
          nearest grid line when no frame candidate is closer), reusing snapGetAnchorOffsets for the math.
        - Two-point flush snap: aligning both endpoints of the connecting side at once would require giving
          up StartMoving for cluster drag, because Blizzard's anchor propagation is unreliable with
          two-point chains. Worth doing only if the stretch behavior is explicitly wanted.
--]=]
