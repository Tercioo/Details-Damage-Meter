
--detached instances
--a detached instance is a complete details! window object, with real frames, which was never registered in
--Details.tabela_instancias. it is not counted by Details.instances_amount, it is not written to the profile,
--it does not appear in the instance dropdown and no broadcast which iterates the instance container reaches
--it. it exists so another addon can host a live details! window inside its own panel, as a preview.

local Details = _G.Details
local addonName, Details222 = ...
local detailsFramework = _G.DetailsFramework

local _ = nil

--constants
--detached instances take ids far above the ids a user can reach, because every frame of a window carries its
--id in the global frame name, e.g. DetailsBaseFrame1, and a detached window must never take the name of a
--window the user owns
local DETACHED_INSTANCE_ID_BASE = 90
local DETACHED_INSTANCE_ID_MAX = 120

--every detached instance created during this session, kept so the addon can find them again
Details222.DetachedInstances = Details222.DetachedInstances or {}

--tells whether an instance id is already taken by a registered window or by a detached window
local isInstanceIdInUse = function(instanceId)
	for index, instanceObject in ipairs(Details.tabela_instancias) do
		if (instanceObject:GetId() == instanceId) then
			return true
		end
	end

	for index, instanceObject in ipairs(Details222.DetachedInstances) do
		if (instanceObject:GetId() == instanceId) then
			return true
		end
	end

	--the frames of a previous window with this id may still exist even when the instance is gone
	if (_G["DetailsBaseFrame" .. instanceId]) then
		return true
	end

	return false
end

--finds the first instance id which is free to build a detached window with
local getFreeDetachedInstanceId = function()
	for instanceId = DETACHED_INSTANCE_ID_BASE, DETACHED_INSTANCE_ID_MAX do
		if (not isInstanceIdInUse(instanceId)) then
			return instanceId
		end
	end
	return nil
end

---creates a details! window inside the frame passed, without registering it as one of the user's windows
---@param parent table the frame the window frames are built inside of
---@return instance|nil detachedInstance
function Details:CreateDetachedInstance(parent)
	local instanceId = getFreeDetachedInstanceId()

	if (not instanceId) then
		Details:Msg("no free instance id available for a detached window.")
		return nil
	end

	local detachedInstance = Details:CreateNewInstance(instanceId, parent, true)

	--a detached window is driven by whoever hosts it, it must not fade itself out because the player is
	--sitting in a city or because a window somewhere else changed the context
	detachedInstance.baseframe:SetAlpha(1)
	detachedInstance.rowframe:SetAlpha(1)
	detachedInstance.baseframe:Show()
	detachedInstance.rowframe:Show()

	Details222.DetachedInstances[#Details222.DetachedInstances+1] = detachedInstance

	return detachedInstance
end

---returns every detached instance created during this session
---@return table detachedInstances
function Details:GetDetachedInstances()
	return Details222.DetachedInstances
end

---hides a detached instance and forgets about it
---the frames are not destroyed, the wow client cannot destroy frames, they are hidden and unparented
---@param detachedInstance instance
function Details:DestroyDetachedInstance(detachedInstance)
	for index, instanceObject in ipairs(Details222.DetachedInstances) do
		if (instanceObject == detachedInstance) then
			table.remove(Details222.DetachedInstances, index)
			break
		end
	end

	detachedInstance.ativa = false

	local baseFrame = detachedInstance.baseframe
	baseFrame:Hide()
	detachedInstance.rowframe:Hide()
	detachedInstance.windowSwitchButton:Hide()
	baseFrame.anti_menu_overlap:Hide()
end

--------------------------------------------------------------------------------------------------------------
--feeding a detached instance with data

--a session is the shape the game client hands to the addon on the apocalypse data path, and the shape
--Details:RefreshWindowAddOnApocalypse renders into a single window without touching any combat object
local TEST_SESSION_DURATION = 10

local TEST_SESSION_SOURCES = {
	{name = "Spiro", classFilename = "EVOKER", totalAmount = 100000},
	{name = "Ragnaros", classFilename = "MAGE", totalAmount = 86000},
	{name = "The Lich King", classFilename = "DEATHKNIGHT", totalAmount = 71000},
	{name = "Your Neighbor", classFilename = "SHAMAN", totalAmount = 67000},
	{name = "Huffer", classFilename = "HUNTER", totalAmount = 56000},
	{name = "Mr. President", classFilename = "WARRIOR", totalAmount = 41000},
	{name = "Antonidas", classFilename = "MAGE", totalAmount = 33000},
	{name = "A Drunk Dwarf", classFilename = "MONK", totalAmount = 21000},
}

---builds a fake session which can be rendered into a single window
---@return table session
function Details:CreateTestSession()
	local combatSources = {}
	local totalAmount = 0
	local maxAmount = 0

	for index, sourceInfo in ipairs(TEST_SESSION_SOURCES) do
		combatSources[index] = {
			name = sourceInfo.name,
			classFilename = sourceInfo.classFilename,
			totalAmount = sourceInfo.totalAmount,
			amountPerSecond = sourceInfo.totalAmount / TEST_SESSION_DURATION,
		}

		totalAmount = totalAmount + sourceInfo.totalAmount

		if (sourceInfo.totalAmount > maxAmount) then
			maxAmount = sourceInfo.totalAmount
		end
	end

	return {
		combatSources = combatSources,
		maxAmount = maxAmount,
		totalAmount = totalAmount,
		durationSeconds = TEST_SESSION_DURATION,
	}
end

---pins a window to a session and renders it, the user's own windows are not touched
---the window keeps showing this data through every refresh until it is unpinned, which is what a settings
---preview needs: changing an option refreshes the window, and a one shot render would be wiped by it
---@param instanceObject instance
---@param session table|nil defaults to the test session
function Details:FeedInstanceWithSession(instanceObject, session)
	session = session or Details:CreateTestSession()
	instanceObject:SetApocalypseSourceType(Details222.Apocalypse.TypeGame)
	instanceObject:SetPinnedSession(session)
	Details:RefreshWindowAddOnApocalypse(instanceObject, session, session.durationSeconds)
end

---releases a window back to live data
---@param instanceObject instance
function Details:StopFeedingInstance(instanceObject)
	instanceObject:SetPinnedSession(nil)
end

--------------------------------------------------------------------------------------------------------------
--feeding a detached instance on the classic versions

--the classic versions draw a window from a combat object, through the same path every window of the user
--takes, not from a session. a preview drawn from a session there would ignore every setting only that path
--reads, the aligned text columns for example, so it is fed a combat of its own instead.
--the classes are the ones every classic version has
local TEST_COMBAT_DURATION = 10

local TEST_COMBAT_SOURCES = {
	{name = "Spiro", classFilename = "DRUID", totalAmount = 100000},
	{name = "Ragnaros", classFilename = "MAGE", totalAmount = 86000},
	{name = "The Lich King", classFilename = "PALADIN", totalAmount = 71000},
	{name = "Your Neighbor", classFilename = "SHAMAN", totalAmount = 67000},
	{name = "Huffer", classFilename = "HUNTER", totalAmount = 56000},
	{name = "Mr. President", classFilename = "WARRIOR", totalAmount = 41000},
	{name = "Antonidas", classFilename = "WARLOCK", totalAmount = 33000},
	{name = "A Drunk Dwarf", classFilename = "PRIEST", totalAmount = 21000},
}

--the segment a window fed with a test combat claims to show. it only has to be something other than the
--current segment: a window in group mode showing the current segment reads the parser's live group cache while
--the player is in combat, instead of the combat it was given
local TEST_COMBAT_SEGMENT_ID = 1

---builds a combat object with fake players, which is never added to the segments list: no window of the user
---shows it, no overall data is summed from it and nothing saves it
---@return combat combatObject
function Details:CreateTestCombat()
	local combatObject = Details.combate:NovaTabela()
	local damageContainer = combatObject[1]
	local totalAmount = 0

	for index, sourceInfo in ipairs(TEST_COMBAT_SOURCES) do
		local actorObject = damageContainer:PegarCombatente("0x0000-0000-0000", sourceInfo.name, 0x114, true)
		actorObject.grupo = true
		actorObject.testBar = true
		actorObject.classe = sourceInfo.classFilename
		actorObject.total = sourceInfo.totalAmount

		totalAmount = totalAmount + sourceInfo.totalAmount
	end

	combatObject.start_time = GetTime() - TEST_COMBAT_DURATION
	combatObject.end_time = GetTime()
	combatObject.totals[1] = totalAmount
	combatObject.totals_grupo[1] = totalAmount
	damageContainer.need_refresh = true

	return combatObject
end

---makes a window show a combat of its own and renders it, the user's own windows are not touched.
---the combat is held in the slot a restored saved segment uses, which is the one slot every refresh of the
---window reads before looking at the segments list, so it survives the refresh every settings change triggers
---@param instanceObject instance
---@param combatObject combat|nil defaults to a test combat
function Details:FeedInstanceWithCombat(instanceObject, combatObject)
	combatObject = combatObject or Details:CreateTestCombat()

	instanceObject:SetPinnedSession(nil)
	instanceObject:SetApocalypseSourceType(Details222.Apocalypse.TypeDetails)
	instanceObject.segmento = TEST_COMBAT_SEGMENT_ID
	instanceObject.savedSegmentCombat = combatObject
	instanceObject.showing = combatObject

	--a window which had nothing to show before it was fed is frozen, and a frozen window draws no bars
	if (instanceObject.freezed) then
		instanceObject:UnFreeze()
	end

	Details:RefreshInstanceWindow(instanceObject, true)
end

---feeds a window with sample data drawn the way this game version draws the user's windows: a session on
---retail, a combat on the classic versions
---@param instanceObject instance
function Details:FeedInstanceWithSampleData(instanceObject)
	if (detailsFramework.IsAddonApocalypseWow()) then
		Details:FeedInstanceWithSession(instanceObject)
	else
		Details:FeedInstanceWithCombat(instanceObject)
	end
end
