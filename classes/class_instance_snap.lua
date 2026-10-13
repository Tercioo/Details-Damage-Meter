
--window snapping
--details! windows snap to each other through the snap group of the details framework (Libs/DF/frame_helpers.lua).
--the framework owns the live links and anchors while windows are on the screen; the saved layout stays in
--instance.snap ({[side] = windowId}), which is what the profile, the character config and the skin export
--already store. this file is the bridge between the two: it registers the windows, copies the saved links
--into the framework when a layout loads and copies the framework links back into instance.snap whenever
--they change.
--side codes in instance.snap: 1 = window on my left, 2 = window below me, 3 = window on my right, 4 = window above me

local Details = _G.Details
local addonName, Details222 = ...
local detailsFramework = _G.DetailsFramework
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")

local _ = nil

---@class windowsnap : table
local windowSnap = {}
Details222.WindowSnap = windowSnap

--constants
--screen pixels between two window edges for them to snap
local SNAP_DISTANCE = 12
--height of the title bar drawn above (or below) the window frame
local TITLE_BAR_HEIGHT = 20
--height of the status bar drawn below the window frame
local STATUS_BAR_HEIGHT = 14
--side codes of instance.snap mapped to the side names used by the framework
local SIDE_NAME = {[1] = "left", [2] = "bottom", [3] = "right", [4] = "top"}
local SIDE_CODE = {left = 1, bottom = 2, right = 3, top = 4}
--the side code a neighbor uses to point back at a window
local OPPOSITE_CODE = {[1] = 3, [2] = 4, [3] = 1, [4] = 2}
windowSnap.OPPOSITE_CODE = OPPOSITE_CODE

--the framework snap group holding every window on the screen
local snapGroup

--while above zero, framework link changes are not copied back into instance.snap
local writeBackSuspended = 0

--true while the module itself changes window scales after a snap, so SetWindowScale doesn't re-align
--the group on its own in the middle of it
local isSyncingScale = false

--returns how far the title bar and the status bar of a window reach past its frame, as left, right, top, bottom
---@param baseFrame frame
---@return number, number, number, number
local getWindowInsets = function(baseFrame)
	local instance = baseFrame.instance
	local top = 0
	local bottom = 0

	if (instance.toolbar_side == 1) then
		top = TITLE_BAR_HEIGHT
	else
		bottom = TITLE_BAR_HEIGHT
	end

	if (instance.show_statusbar) then
		bottom = bottom + STATUS_BAR_HEIGHT
	end

	return 0, 0, top, bottom
end

--tells whether a window's frame is in the snap group
---@param instance instance
---@return boolean
local isRegistered = function(instance)
	return instance.baseframe ~= nil and snapGroup:IsRegistered(instance.baseframe)
end

--returns the window that owns a registered frame
---@param frame frame
---@return instance
local getInstanceFromFrame = function(frame)
	return frame.instance
end

--returns every window of the instance container which has its frame in the snap group
---@return instance[]
local getRegisteredInstances = function()
	local result = {}
	for index, instance in Details:ListInstances() do
		if (isRegistered(instance)) then
			result[#result+1] = instance
		end
	end
	return result
end

--sorts windows by their id, so walks over groups always visit them in the same order
---@param instanceList instance[]
local sortById = function(instanceList)
	table.sort(instanceList, function(instance1, instance2)
		return instance1:GetId() < instance2:GetId()
	end)
end

--the options handed to the framework snap group, built from the profile
---@return table
local buildSnapOptions = function()
	return {
		snap_distance = SNAP_DISTANCE,
		allow_new_snaps = not Details.disable_window_groups,
		space_between_horizontal = tonumber(Details.grouping_horizontal_gap) or 0,
		space_between_vertical = 0,
		restore_size_on_unsnap = false,
		on_links_changed = function()
			windowSnap.ExportLinks()
		end,
		on_drag_cancelled = function(group, frame)
			windowSnap.ClearMovingState(getInstanceFromFrame(frame))
		end,
	}
end

--shows or hides the ungroup button of a window to match its links
---@param instance instance
local refreshUngroupButton = function(instance)
	local ungroupButton = instance.break_snap_button
	if (not ungroupButton) then
		return
	end

	if (not windowSnap.IsGrouped(instance)) then
		ungroupButton:SetAlpha(0)

	elseif (instance:IsInteracting() and not Details.disable_lock_ungroup_buttons) then
		ungroupButton:SetAlpha(1)
	end
end

--removes the links of instance.snap pointing at a window which is no longer there or at a side that is not valid
--and makes every link exist in both directions
local normalizeSavedLinks = function()
	for index, instance in Details:ListInstances() do
		instance.snap = instance.snap or {}
		for sideCode, neighborId in pairs(instance.snap) do
			local neighbor = type(neighborId) == "number" and Details:GetInstance(neighborId)
			local isValidSide = OPPOSITE_CODE[sideCode] ~= nil
			if (not isValidSide or not neighbor or neighbor == instance) then
				instance.snap[sideCode] = nil
			else
				neighbor.snap = neighbor.snap or {}
				local backSide = OPPOSITE_CODE[sideCode]
				local backId = neighbor.snap[backSide]
				if (backId == nil) then
					neighbor.snap[backSide] = instance:GetId()
				elseif (backId ~= instance:GetId()) then
					--the neighbor's side is taken by another window, the link can't be kept
					instance.snap[sideCode] = nil
				end
			end
		end
	end
end

--writes the cached row/column flags from the links, nothing reads them for logic anymore but older code
--and other addons may
---@param instance instance
local updateAxisFlags = function(instance)
	local snap = instance.snap
	instance.horizontalSnap = (snap[1] or snap[3]) and true or false
	instance.verticalSnap = (snap[2] or snap[4]) and true or false
end

--creates the snap group, runs once while details! loads, before the windows are created
function windowSnap.Initialize()
	snapGroup = detailsFramework:CreateSnapGroup("DetailsWindows", nil, buildSnapOptions())
end

--pushes the profile settings (grouping disabled, space between windows) into the snap group and
--re-aligns every group of windows
function windowSnap.RefreshOptions()
	snapGroup:SetOptionsTable(buildSnapOptions())
	snapGroup:RefreshAllClusters()
	windowSnap.SaveAllPositions()
end

---tells whether a window can be part of the snap group: a normal window on the screen, not a detached
---window, not built inside another frame and not moved into another frame (chat embed)
---@param instance instance
---@return boolean
function windowSnap.IsEligible(instance)
	local baseFrame = instance.baseframe
	if (not baseFrame or instance:IsDetached() or instance:IsHostedInsideFrame()) then
		return false
	end

	if (baseFrame:GetParent() ~= UIParent) then
		return false
	end

	return Details:GetInstance(instance:GetId()) == instance
end

---puts a window into the snap group, does nothing for a window that can't snap or is already in
---@param instance instance
function windowSnap.RegisterInstance(instance)
	if (not windowSnap.IsEligible(instance) or isRegistered(instance)) then
		return
	end

	snapGroup:RegisterFrame(instance.baseframe, "DetailsWindow" .. instance:GetId(), {
		wrap_drag_scripts = false,
		GetInsets = getWindowInsets,
		GlowParent = instance.floatingframe,
	})
end

---takes a window out of the snap group
---@param instance instance
function windowSnap.UnregisterInstance(instance)
	if (not isRegistered(instance)) then
		return
	end

	snapGroup:UnregisterFrame(instance.baseframe)
end

---drops every link the snap group holds, the windows stay where they are and instance.snap is not touched.
---used before a profile places the windows again: hidden windows keep their links, and the groups of the
---old profile would otherwise move and resize the windows while they are restored
function windowSnap.ReleaseAll()
	writeBackSuspended = writeBackSuspended + 1
	for index, instance in ipairs(getRegisteredInstances()) do
		snapGroup:Unsnap(instance.baseframe)
	end
	writeBackSuspended = writeBackSuspended - 1
end

---tells whether a window is grouped with at least one other window
---@param instance instance
---@return boolean
function windowSnap.IsGrouped(instance)
	return next(instance.snap) ~= nil
end

---copies the links of the framework into instance.snap of every window in the snap group.
---links to windows outside the snap group are kept as they are
function windowSnap.ExportLinks()
	if (writeBackSuspended > 0) then
		return
	end

	for index, instance in ipairs(getRegisteredInstances()) do
		local newSnap = {}

		--keep links to windows the framework doesn't know about
		for sideCode, neighborId in pairs(instance.snap) do
			local neighbor = Details:GetInstance(neighborId)
			if (neighbor and not isRegistered(neighbor)) then
				newSnap[sideCode] = neighborId
			end
		end

		for sideName, neighborFrame in pairs(snapGroup:GetLinks(instance.baseframe)) do
			newSnap[SIDE_CODE[sideName]] = getInstanceFromFrame(neighborFrame):GetId()
		end

		instance.snap = newSnap
		updateAxisFlags(instance)
		refreshUngroupButton(instance)
	end

	Details:DelayOptionsRefresh()
end

---loads the links stored in instance.snap into the snap group. used after a profile or the character
---layout was applied: every window already sits at its saved spot, the groups are rebuilt around the
---window with the lowest id of each group so nothing moves
function windowSnap.ImportLayout()
	snapGroup:SetOptionsTable(buildSnapOptions())
	normalizeSavedLinks()

	writeBackSuspended = writeBackSuspended + 1
	windowSnap.RunBatch(function()
		local registeredInstances = getRegisteredInstances()

		--drop whatever the framework still holds from the previous layout
		for index, instance in ipairs(registeredInstances) do
			snapGroup:Unsnap(instance.baseframe)
		end

		--each link moves one cluster next to the other; the cluster moved is always the one whose lowest
		--window id is the higher, so the lowest id window of every group never moves and stays the anchor of
		--its group, on the screen anchor details! restored it to
		for index, instance in ipairs(registeredInstances) do
			for sideCode, neighborId in pairs(instance.snap) do
				local neighbor = Details:GetInstance(neighborId)
				if (neighbor and isRegistered(neighbor)) then
					local instanceLowestId = windowSnap.GetClusterInstances(instance)[1]:GetId()
					local neighborLowestId = windowSnap.GetClusterInstances(neighbor)[1]:GetId()
					if (instanceLowestId > neighborLowestId) then
						snapGroup:Link(instance.baseframe, SIDE_NAME[sideCode], neighbor.baseframe)
					elseif (instanceLowestId < neighborLowestId) then
						snapGroup:Link(neighbor.baseframe, SIDE_NAME[OPPOSITE_CODE[sideCode]], instance.baseframe)
					end
				end
			end
		end
	end)
	writeBackSuspended = writeBackSuspended - 1

	windowSnap.ExportLinks()
	windowSnap.SaveAllPositions()
end

--saves the screen position of windows; skipped while details! is loading, the ui scale and the screen size
--may not be final yet and the positions just restored from the saved variables are the right ones
---@param instanceList instance[]
local saveWindowPositions = function(instanceList)
	if (Details.initializing) then
		return
	end

	for index, instance in ipairs(instanceList) do
		if (instance:IsEnabled()) then
			instance:SaveMainWindowPosition()
		end
	end
end

---saves the screen position of every window in the snap group
function windowSnap.SaveAllPositions()
	saveWindowPositions(getRegisteredInstances())
end

---returns the windows physically snapped together with a window (the window included), sorted by id.
---for a window outside the snap group, the window alone
---@param instance instance
---@return instance[]
function windowSnap.GetClusterInstances(instance)
	if (not isRegistered(instance)) then
		return {instance}
	end

	local result = {}
	for index, frame in ipairs(snapGroup:GetCluster(instance.baseframe)) do
		result[#result+1] = getInstanceFromFrame(frame)
	end
	sortById(result)
	return result
end

---returns the windows sharing an axis with a window, the window excluded: axis "x" are the windows side
---by side with it (same height), axis "y" the windows stacked with it (same width)
---@param instance instance
---@param axis string "x" or "y"
---@return instance[]
function windowSnap.GetAxisNeighbors(instance, axis)
	local result = {}

	if (isRegistered(instance)) then
		for index, frame in ipairs(snapGroup:GetAxisCluster(instance.baseframe, axis)) do
			local axisInstance = getInstanceFromFrame(frame)
			if (axisInstance ~= instance) then
				result[#result+1] = axisInstance
			end
		end
		sortById(result)
	end

	return result
end

---returns the windows grouped with a window through the saved links (the window included, then the
---other open windows of the group sorted by id). works for windows outside the snap group too, which
---is what lets the options "edit group" reach the windows embedded in the chat
---@param instance instance
---@return instance[]
function windowSnap.GetLogicalGroup(instance)
	local result = {instance}
	local isVisited = {[instance] = true}
	local queue = {instance}

	while (#queue > 0) do
		local current = table.remove(queue, 1)
		for sideCode, neighborId in pairs(current.snap) do
			local neighbor = Details:GetInstance(neighborId)
			if (neighbor and not isVisited[neighbor]) then
				isVisited[neighbor] = true
				queue[#queue+1] = neighbor
				if (neighbor:IsEnabled()) then
					result[#result+1] = neighbor
				end
			end
		end
	end

	local others = {}
	for i = 2, #result do
		others[#others+1] = result[i]
	end
	sortById(others)

	local sortedResult = {instance}
	for index, other in ipairs(others) do
		sortedResult[#sortedResult+1] = other
	end
	return sortedResult
end

---groups a window with others; sides is {left, bottom, right, top} holding the id of the window that
---goes on that side of this window, or false. the first window linked keeps its place and this window
---(with its group) moves next to it; each window linked after that moves (with its group) next to this
---window, so a link never pulls away a window linked before it.
---returns false when a side could not be linked: the side is taken, or the two windows are already in
---the same group through other windows (a group never forms a loop)
---@param instance instance
---@param sides table
---@return boolean
function windowSnap.MakeGroup(instance, sides)
	local isEverySideLinked = true
	local hasMoved = false

	for sideCode = 1, 4 do
		local neighborId = sides[sideCode]
		local neighbor = neighborId and Details:GetInstance(neighborId)
		if (neighbor and neighbor ~= instance) then
			local isLinked
			if (isRegistered(instance) and isRegistered(neighbor)) then
				if (not hasMoved) then
					isLinked = snapGroup:Link(instance.baseframe, SIDE_NAME[sideCode], neighbor.baseframe)
					hasMoved = isLinked
				else
					isLinked = snapGroup:Link(neighbor.baseframe, SIDE_NAME[OPPOSITE_CODE[sideCode]], instance.baseframe)
				end
			else
				--a window outside the snap group only gets the saved link, and only when both sides are free
				local isSideFree = instance.snap[sideCode] == nil or instance.snap[sideCode] == neighbor:GetId()
				local isNeighborSideFree = neighbor.snap[OPPOSITE_CODE[sideCode]] == nil or neighbor.snap[OPPOSITE_CODE[sideCode]] == instance:GetId()
				isLinked = isSideFree and isNeighborSideFree
				if (isLinked) then
					instance.snap[sideCode] = neighbor:GetId()
					neighbor.snap[OPPOSITE_CODE[sideCode]] = instance:GetId()
					updateAxisFlags(instance)
					updateAxisFlags(neighbor)
				end
			end

			if (not isLinked) then
				isEverySideLinked = false
			end
		end
	end

	--linking moved this window (and its group) next to the others
	saveWindowPositions(windowSnap.GetClusterInstances(instance))
	return isEverySideLinked
end

--removes the saved link of a window on one side, on both windows
---@param instance instance
---@param sideCode number
local removeSavedLink = function(instance, sideCode)
	local neighbor = Details:GetInstance(instance.snap[sideCode])
	instance.snap[sideCode] = nil

	if (neighbor and neighbor.snap[OPPOSITE_CODE[sideCode]] == instance:GetId()) then
		neighbor.snap[OPPOSITE_CODE[sideCode]] = nil
		updateAxisFlags(neighbor)
	end

	updateAxisFlags(instance)
end

---takes a window out of its group, it stays where it is and keeps its size
---@param instance instance
function windowSnap.Ungroup(instance)
	--cutting links in the snap group copies them back (ExportLinks), which already refreshes the options
	local hasFrameworkLinks = isRegistered(instance) and next(snapGroup:GetLinks(instance.baseframe)) ~= nil
	if (hasFrameworkLinks) then
		snapGroup:Unsnap(instance.baseframe)
	end

	--links to windows outside the snap group
	for sideCode in pairs(instance.snap) do
		removeSavedLink(instance, sideCode)
	end

	refreshUngroupButton(instance)
	if (not hasFrameworkLinks) then
		Details:DelayOptionsRefresh(nil, true)
	end
end

---removes the link on one side of a window
---@param instance instance
---@param sideCode number
function windowSnap.UngroupSide(instance, sideCode)
	if (not instance.snap[sideCode]) then
		return
	end

	--cutting a link in the snap group copies the links back (ExportLinks), which already refreshes the options
	local isUnlinked = isRegistered(instance) and snapGroup:Unlink(instance.baseframe, SIDE_NAME[sideCode])

	if (instance.snap[sideCode]) then
		removeSavedLink(instance, sideCode)
	end

	refreshUngroupButton(instance)
	if (not isUnlinked) then
		Details:DelayOptionsRefresh(nil, true)
	end
end

---re-aligns the group of a window, around that window. used after its title bar side, status bar or
---scale changed
---@param instance instance
function windowSnap.RefreshGeometry(instance)
	if (isSyncingScale or not isRegistered(instance) or not windowSnap.IsGrouped(instance)) then
		return
	end

	--re-chained from the window the group is already anchored on, the group doesn't move around this window
	snapGroup:RefreshCluster(instance.baseframe, true)
	saveWindowPositions(windowSnap.GetClusterInstances(instance))
end

---re-aligns the group of a window after the window was placed by code: the window becomes the anchor of
---its group, keeps its new spot and the windows grouped with it follow it
---@param instance instance
function windowSnap.MoveGroupWith(instance)
	if (not isRegistered(instance) or not windowSnap.IsGrouped(instance)) then
		return
	end

	snapGroup:RefreshCluster(instance.baseframe)
	saveWindowPositions(windowSnap.GetClusterInstances(instance))
end

---starts moving a window with the mouse, its group moves along
---@param instance instance
function windowSnap.BeginMove(instance)
	local baseFrame = instance.baseframe
	if (baseFrame.isMoving) then
		return
	end

	baseFrame.isMoving = true
	instance.linksBeforeMove = 0
	for sideCode in pairs(instance.snap) do
		instance.linksBeforeMove = instance.linksBeforeMove + 1
	end

	for index, clusterInstance in ipairs(windowSnap.GetClusterInstances(instance)) do
		clusterInstance.isMoving = true
	end

	if (not snapGroup:StartDrag(baseFrame)) then
		baseFrame:StartMoving()
	end
end

---forgets that a window and its group are being moved, used when the framework ends a drag on its own
---(the window was hidden while being dragged)
---@param instance instance
function windowSnap.ClearMovingState(instance)
	instance.baseframe.isMoving = false
	instance.linksBeforeMove = nil
	for index, clusterInstance in ipairs(windowSnap.GetClusterInstances(instance)) do
		clusterInstance.isMoving = false
	end
end

---shows the tutorials explaining groups the first times the user makes one
---@param instance instance the window that was dropped
---@param neighbor instance a window it snapped to
local showGroupTutorials = function(instance, neighbor)
	if (not Details:GetTutorialCVar("WINDOW_GROUP_MAKING1")) then
		Details:SetTutorialCVar("WINDOW_GROUP_MAKING1", true)

		local groupTutorial = CreateFrame("frame", "DetailsWindowGroupPopUp1", instance.baseframe, "DetailsHelpBoxTemplate")
		groupTutorial.ArrowUP:Show()
		groupTutorial.ArrowGlowUP:Show()
		groupTutorial.Text:SetText(Loc["STRING_MINITUTORIAL_WINDOWS1"])
		groupTutorial:SetPoint("bottom", neighbor.break_snap_button, "top", 0, 24)
		groupTutorial:Show()
		Details.OnEnterMainWindow(neighbor)
	end

	if (Details.tutorial.unlock_button < 4) then
		Details.temp_table1.IconSize = 32
		Details.temp_table1.TextHeightMod = -6
		Details.popup:ShowMe(instance.break_snap_button, "tooltip", "Interface\\Buttons\\LockButton-Unlocked-Up", Loc["STRING_UNLOCK"], 150, Details.temp_table1)
		Details.tutorial.unlock_button = Details.tutorial.unlock_button + 1
	end
end

---ends moving a window: snaps it if a snap was previewed and saves the position of its group
---@param instance instance
function windowSnap.EndMove(instance)
	local baseFrame = instance.baseframe
	if (not baseFrame.isMoving) then
		return
	end

	local movedInstances = windowSnap.GetClusterInstances(instance)

	if (not snapGroup:StopDrag(baseFrame)) then
		baseFrame:StopMovingOrSizing()
	end
	baseFrame.isMoving = false

	for index, movedInstance in ipairs(movedInstances) do
		movedInstance.isMoving = false
	end

	--a snap was made: the moved windows take the scale of the window they snapped to
	local linkAmount = 0
	for sideCode in pairs(instance.snap) do
		linkAmount = linkAmount + 1
	end

	if (linkAmount > (instance.linksBeforeMove or 0)) then
		local neighbor
		for sideCode, neighborId in pairs(instance.snap) do
			local thisNeighbor = Details:GetInstance(neighborId)
			if (thisNeighbor and not tContains(movedInstances, thisNeighbor)) then
				neighbor = thisNeighbor
				break
			end
		end

		if (neighbor) then
			--SetWindowScale would re-align the group around each moved window, resizing the window it
			--snapped to; the group is re-aligned once afterwards from its current anchor instead, which is on
			--the side of the window snapped to, so that side keeps its size and the moved windows adapt
			isSyncingScale = true
			local isScaleChanged = false
			for index, movedInstance in ipairs(movedInstances) do
				if (movedInstance.window_scale ~= neighbor.window_scale) then
					movedInstance:SetWindowScale(neighbor.window_scale)
					isScaleChanged = true
				end
			end
			isSyncingScale = false

			if (isScaleChanged) then
				snapGroup:RefreshCluster(neighbor.baseframe, true)
			end

			showGroupTutorials(instance, neighbor)
		end
	end
	instance.linksBeforeMove = nil

	local clusterInstances = windowSnap.GetClusterInstances(instance)
	for index, clusterInstance in ipairs(clusterInstances) do
		clusterInstance.baseframe:SetUserPlaced(false)
	end
	saveWindowPositions(clusterInstances)
end

---prepares the group of a window for a resize made with the mouse: the window becomes the anchor of its
---group so the resize does not fight the anchors, the other windows follow its new size
---@param instance instance
function windowSnap.BeginResize(instance)
	if (isRegistered(instance) and windowSnap.IsGrouped(instance)) then
		snapGroup:RefreshCluster(instance.baseframe)
	end
end

---stretching a window: the windows side by side with it stretch along, the windows stacked on the side
---it grows toward stay where they are (the stretched window is drawn over them) instead of being pushed
---away. their links are cut for the duration of the stretch, instance.snap is left as it is
---@param instance instance
---@param direction string "top" or "bottom", the side the window grows toward
function windowSnap.BeginStretch(instance, direction)
	--a stretch that never got its end (the mouse was released somewhere else) gives its links back first
	if (instance.stretchCutLinks) then
		windowSnap.EndStretch(instance)
	end

	if (not isRegistered(instance) or not windowSnap.IsGrouped(instance)) then
		return
	end

	local cutLinks = {}
	writeBackSuspended = writeBackSuspended + 1
	for index, rowFrame in ipairs(snapGroup:GetAxisCluster(instance.baseframe, "x")) do
		local stackedFrame = snapGroup:GetLinks(rowFrame)[direction]
		if (stackedFrame) then
			cutLinks[#cutLinks+1] = {rowFrame = rowFrame, stackedFrame = stackedFrame}
			snapGroup:Unlink(rowFrame, direction)
		end
	end
	writeBackSuspended = writeBackSuspended - 1

	instance.stretchCutLinks = cutLinks
	instance.stretchDirection = direction

	--the stretched window becomes the anchor of what is left of its group, so the resize doesn't fight the anchors
	snapGroup:RefreshCluster(instance.baseframe)
end

---ends a stretch: links back the windows cut by BeginStretch, call it after the window got its size back
---@param instance instance
function windowSnap.EndStretch(instance)
	local cutLinks = instance.stretchCutLinks
	local direction = instance.stretchDirection
	instance.stretchCutLinks = nil
	instance.stretchDirection = nil

	if (cutLinks) then
		local oppositeSide = SIDE_NAME[OPPOSITE_CODE[SIDE_CODE[direction]]]
		for index, cutLink in ipairs(cutLinks) do
			if (snapGroup:IsRegistered(cutLink.rowFrame) and snapGroup:IsRegistered(cutLink.stackedFrame)) then
				--the stacked window (with its group) goes back next to the row, which has its size back
				snapGroup:Link(cutLink.stackedFrame, oppositeSide, cutLink.rowFrame)
			end
		end
	end

	saveWindowPositions(windowSnap.GetClusterInstances(instance))
end

---runs a function while sizes are not synced between grouped windows, then re-aligns every group.
---an error inside the function is reported and the groups still get synced again afterwards
---@param func function
---@param ... any
function windowSnap.RunBatch(func, ...)
	snapGroup:BeginBatch()
	xpcall(func, geterrorhandler(), ...)
	snapGroup:EndBatch()
end

---a window is about to be deleted: takes it out of every group and shifts the ids stored in the links of
---the windows after it, which take the id one lower
---@param deletedId number
function windowSnap.OnInstanceDeleted(deletedId)
	local deletedInstance = Details:GetInstance(deletedId)
	windowSnap.Ungroup(deletedInstance)
	windowSnap.UnregisterInstance(deletedInstance)

	for index, instance in Details:ListInstances() do
		local newSnap = {}
		for sideCode, neighborId in pairs(instance.snap) do
			if (neighborId > deletedId) then
				newSnap[sideCode] = neighborId - 1
			elseif (neighborId < deletedId) then
				newSnap[sideCode] = neighborId
			end
		end
		instance.snap = newSnap
		updateAxisFlags(instance)
	end
end
