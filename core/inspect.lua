
local Details = 		_G.Details
local addonName, Details222 = ...
local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
---@type detailsframework
local detailsFramework = DetailsFramework
local _

local debug = true
local CONST_CAN_START_LOOP = true
local CONST_USE_NOTIFY_INSPECT = true

local CONST_MAX_INSPECT_AMOUNT = 1
local CONST_MIN_ILEVEL_TO_STORE = 50
local CONST_LOOP_TIME = 7
local CONST_INSPECT_ACHIEVEMENT_DISTANCE = 1 --Compare Achievements, 28 yards

local twoHandSlots = {
	["INVTYPE_2HWEAPON"] = true,
 	["INVTYPE_RANGED"] = true,
	["INVTYPE_RANGEDRIGHT"] = true,
}

local itemLevelCore = Details:CreateEventListener()
itemLevelCore.amt_inspecting = 0
Details.ilevel.core = itemLevelCore

itemLevelCore:RegisterEvent("GROUP_ONENTER", "OnEnter")
itemLevelCore:RegisterEvent("GROUP_ONLEAVE", "OnLeave")
itemLevelCore:RegisterEvent("COMBAT_PLAYER_ENTER", "EnterCombat")
itemLevelCore:RegisterEvent("COMBAT_PLAYER_LEAVE", "LeaveCombat")
itemLevelCore:RegisterEvent("ZONE_TYPE_CHANGED", "ZoneChanged")

local inspecting = {}
itemLevelCore.forced_inspects = {}

function itemLevelCore:HasQueuedInspect(unitName)
	local guid = UnitGUID(unitName)
	if (guid) then
		return itemLevelCore.forced_inspects[guid]
	end
end

function Details:IlvlFromNetwork(unitName, realmName, coreVersion, unitGUID, itemLevel, talentsSelected, currentSpec)
	if (Details.debug and false) then
		local talents = "Invalid Talents"
		if (type(talentsSelected) == "table") then
			talents = ""
			for i = 1, #talentsSelected do
				talents = talents .. talentsSelected [i] .. ","
			end
		end
		Details222.DebugMsg("Received PlayerInfo Data: " ..(unitName or "Invalid Player Name") .. " | " ..(itemLevel or "Invalid Item Level") .. " | " ..(currentSpec or "Invalid Spec") .. " | " .. talents  .. " | " ..(unitGUID or "Invalid Serial"))
	end

	if (not unitName) then
		return
	end

	--older versions of details wont send serial nor talents nor spec
	if (not unitGUID or not itemLevel or not talentsSelected or not currentSpec) then
		--if any data is invalid, abort
		return
	end

	--won't inspect this actor
	Details.trusted_characters[unitGUID] = true

	if (type(unitGUID) ~= "string") then
		return
	end

	--store the item level
	if (type(itemLevel) == "number") then
        Details.ilevel:Add(unitGUID, unitName, itemLevel, time())
	end

	--store talents
	if (type(talentsSelected) == "table") then
		if (talentsSelected[1]) then
			Details.cached_talents[unitGUID] = talentsSelected
		end

	elseif (type(talentsSelected) == "string" and talentsSelected ~= "") then
		Details.cached_talents[unitGUID] = talentsSelected
	end

	--store the spec the player is playing
	if (type(currentSpec) == "number") then
		Details.cached_specs[unitGUID] = currentSpec
	end
end

--test
--/run _detalhes.ilevel:CalcItemLevel("player", UnitGUID("player"), true)
--/run wipe(_detalhes.item_level_pool)

function itemLevelCore:CalcItemLevel(unitid, guid, shout)
	if (type(unitid) == "table") then
		shout = unitid [3]
		guid = unitid [2]
		unitid = unitid [1]
	end

	--print("Inspector checks: (1) ", InCombatLockdown(), " (2) ", unitid, " (3) ", UnitPlayerControlled(unitid), " (4) ", CheckInteractDistance(unitid, CONST_INSPECT_ACHIEVEMENT_DISTANCE), " (5) ", CanInspect(unitid))
	--disable due to changes to CheckInteractDistance()
	if (not InCombatLockdown() and unitid and UnitPlayerControlled(unitid) and CheckInteractDistance(unitid, CONST_INSPECT_ACHIEVEMENT_DISTANCE) and CanInspect(unitid)) then
		--print("Inspector: all check has passed, inspecting", UnitName(unitid))
		--16 = all itens including main and off hand
		local item_amount = 16
		local item_level = 0
		local failed = 0

		for equip_id = 1, 17 do
			if (equip_id ~= 4) then --shirt slot
				local item = GetInventoryItemLink(unitid, equip_id)
				if (item) then
					local _, _, itemRarity, iLevel, _, _, _, _, equipSlot = C_Item.GetItemInfo(item)
					if (iLevel) then
						item_level = item_level + iLevel
						--16 = main hand 17 = off hand
						-- if using a two-hand, ignore the off hand slot
						if (equip_id == 16 and twoHandSlots [equipSlot]) then
							item_amount = 15
							break
						end
					end
				else
					failed = failed + 1
					if (failed > 2) then
						break
					end
				end
			end
		end

		local average = item_level / item_amount

		--register
		if (average > 0) then
			if (shout) then
				Details:Msg(UnitName(unitid) .. " item level: " .. average)
			end

			if (average > CONST_MIN_ILEVEL_TO_STORE) then
				local unitName = Details:GetFullName(unitid)
				Details.ilevel:Add(guid, unitName, average, time())
				--print("Inspector:", unitName, " item level: ", average)
			end
		end

		local spec
		local talents = {}

		if (not DetailsFramework.IsTimewalkWoW()) then
			spec = GetInspectSpecialization(unitid)
			if (spec and spec ~= 0) then
				Details.cached_specs [guid] = spec
				Details:SendEvent("UNIT_SPEC", nil, unitid, spec, guid)
			end

			--------------------------------------------------------------------------------------------------------

			--[=[
			for i = 1, 7 do
				for o = 1, 3 do
					--need to review this in classic
					local talentID, name, texture, selected, available = GetTalentInfo(i, o, 1, true, unitid)
					if (selected) then
						tinsert(talents, talentID)
						break
					end
				end
			end

			if (talents [1]) then
				Details.cached_talents [guid] = talents
				Details:SendEvent("UNIT_TALENTS", nil, unitid, talents, guid)
			end
			--]=]
		end

		--------------------------------------------------------------------------------------------------------

		if (itemLevelCore.forced_inspects [guid]) then
			if (type(itemLevelCore.forced_inspects [guid].callback) == "function") then
				local okey, errortext = pcall(itemLevelCore.forced_inspects[guid].callback, guid, unitid, itemLevelCore.forced_inspects[guid].param1, itemLevelCore.forced_inspects[guid].param2)
				if (not okey) then
					Details:Msg("Error on QueryInspect callback: " .. errortext)
				end
			end
			itemLevelCore.forced_inspects [guid] = nil
		end

		--------------------------------------------------------------------------------------------------------

	end
end

Details.ilevel.CalcItemLevel = itemLevelCore.CalcItemLevel


local inspectEventFrame = CreateFrame("frame")
inspectEventFrame:RegisterEvent("INSPECT_READY")
if not detailsFramework.IsAddonApocalypseWow() then
end

inspectEventFrame:SetScript("OnEvent", function(self, event, ...)
	local guid = select(1, ...)

	if detailsFramework.IsAddonApocalypseWow() then
		if issecretvalue(guid) then
			return
		end

		if InCombatLockdown() then
			return
		end
	end

	if (inspecting [guid]) then
		local unitid, cancel_tread = inspecting [guid] [1], inspecting [guid] [2]
		inspecting [guid] = nil
		itemLevelCore.amt_inspecting = itemLevelCore.amt_inspecting - 1

		itemLevelCore:CancelTimer(cancel_tread)

		--do inspect stuff
		if (unitid) then
			local t = {unitid, guid}
			--ilvl_core:ScheduleTimer("CalcItemLevel", 0.5, t)
			itemLevelCore:ScheduleTimer("CalcItemLevel", 0.5, t)
			itemLevelCore:ScheduleTimer("CalcItemLevel", 2, t)
			itemLevelCore:ScheduleTimer("CalcItemLevel", 4, t)
			itemLevelCore:ScheduleTimer("CalcItemLevel", 8, t)
		end
	else
		if (IsInRaid()) then
			--get the unitID
			local serial = ...
			if (serial and type(serial) == "string") then
				for i = 1, GetNumGroupMembers() do
					if (UnitGUID("raid" .. i) == serial) then
						itemLevelCore:ScheduleTimer("CalcItemLevel", 2, {"raid" .. i, serial})
						itemLevelCore:ScheduleTimer("CalcItemLevel", 4, {"raid" .. i, serial})
					end
				end
			end

		elseif (IsInGroup()) then
			--get the unitID
			local serial = ...
			if (serial and type(serial) == "string") then
				for i = 1, GetNumGroupMembers()-1 do
					if (UnitGUID("party" .. i) == serial) then
						itemLevelCore:ScheduleTimer("CalcItemLevel", 2, {"party" .. i, serial})
						itemLevelCore:ScheduleTimer("CalcItemLevel", 4, {"party" .. i, serial})
					end
				end
			end
		end
	end
end)

function itemLevelCore:InspectTimeOut(guid)
	inspecting [guid] = nil
	itemLevelCore.amt_inspecting = itemLevelCore.amt_inspecting - 1
end

function itemLevelCore:ReGetItemLevel(t)
	local unitid, guid, is_forced, try_number = unpack(t)
	return itemLevelCore:GetItemLevel(unitid, guid, is_forced, try_number)
end

function itemLevelCore:GetItemLevel(unitid, guid, is_forced, try_number)
	--disable for timewalk wow ~timewalk
	if (DetailsFramework.IsTimewalkWoW()) then
		return
	end

	--ddouble check
	if (not is_forced and(UnitAffectingCombat("player") or InCombatLockdown())) then
		return
	end

	if (InCombatLockdown() or not unitid or not CanInspect(unitid) or not UnitPlayerControlled(unitid) or not CheckInteractDistance(unitid, CONST_INSPECT_ACHIEVEMENT_DISTANCE)) then
		if (is_forced) then
			try_number = try_number or 0
			if (try_number > 18) then
				return
			else
				try_number = try_number + 1
			end
			itemLevelCore:ScheduleTimer("ReGetItemLevel", 3, {unitid, guid, is_forced, try_number})
		end
		return
	end

	inspecting [guid] = {unitid, itemLevelCore:ScheduleTimer("InspectTimeOut", 12, guid)}
	itemLevelCore.amt_inspecting = itemLevelCore.amt_inspecting + 1

	--NotifyInspect(unitid)
end

local NotifyInspectHook = function(unitId) --not in use, or is?
    --print("NotifyInspectHook -> unitId is secret?", unitId, issecretvalue and issecretvalue(unitId))

    if issecretvalue and issecretvalue(unitId) then
        return
    end

	if InCombatLockdown() then
		return
	end

	local unit = unitId:gsub("%d+", "")

	local isInGroup = IsInRaid() or IsInGroup()
	local isInInstance = Details:GetZoneType() == "raid" or Details:GetZoneType() == "party"

	if (isInGroup and isInInstance) then
		local guid = UnitGUID(unitId)
		if not guid or inspecting[guid] then
			return
		end

		local name = Details:GetFullName(unitId)
		if (name) then
			for i = 1, GetNumGroupMembers() do
				if (name == Details:GetFullName(unit .. i)) then
					unitId = unit .. i
					break
				end
			end

			inspecting [guid] = {unitId, itemLevelCore:ScheduleTimer("InspectTimeOut", 12, guid)}
			itemLevelCore.amt_inspecting = itemLevelCore.amt_inspecting + 1
		end
	end
end

if CONST_USE_NOTIFY_INSPECT then
    hooksecurefunc(_G, "NotifyInspect", NotifyInspectHook)
end

function itemLevelCore:Reset()
	itemLevelCore.raid_id = 1
	itemLevelCore.amt_inspecting = 0

	for guid, t in pairs(inspecting) do
		itemLevelCore:CancelTimer(t[2])
		inspecting [guid] = nil
	end
end

function itemLevelCore:QueryInspect(unitName, callback, param1)
	--disable for timewalk wow ~timewalk
	if (DetailsFramework.IsTimewalkWoW()) then
		return
	end

	local unitid

	if (IsInRaid()) then
		for i = 1, GetNumGroupMembers() do
			if (Details:GetFullName("raid" .. i, "none") == unitName) then
				unitid = "raid" .. i
				break
			end
		end
	elseif (IsInGroup()) then
		for i = 1, GetNumGroupMembers()-1 do
			if (Details:GetFullName("party" .. i, "none") == unitName) then
				unitid = "party" .. i
				break
			end
		end
	else
		unitid = unitName
	end

	if (not unitid) then
		return false
	end

	local guid = UnitGUID(unitid)
	if (not guid) then
		return false
	elseif (itemLevelCore.forced_inspects [guid]) then
		return true
	end

	if (inspecting [guid]) then
		return true
	end

	itemLevelCore.forced_inspects [guid] = {callback = callback, param1 = param1}
	itemLevelCore:GetItemLevel(unitid, guid, true)

	if (itemLevelCore.clear_queued_list) then
		itemLevelCore:CancelTimer(itemLevelCore.clear_queued_list)
	end
	itemLevelCore.clear_queued_list = itemLevelCore:ScheduleTimer("ClearQueryInspectQueue", 60)

	return true
end

function itemLevelCore:ClearQueryInspectQueue()
	Details:Destroy(itemLevelCore.forced_inspects)
	itemLevelCore.clear_queued_list = nil
end

function itemLevelCore:Loop()
	--disable for timewalk wow ~timewalk
	if (DetailsFramework.IsTimewalkWoW()) then
		return
	end

	if (itemLevelCore.amt_inspecting >= CONST_MAX_INSPECT_AMOUNT) then
		return
	end

	local members_amt = GetNumGroupMembers()
	if (itemLevelCore.raid_id > members_amt) then
		itemLevelCore.raid_id = 1
	end

	local unitid
	if (IsInRaid()) then
		unitid = "raid" .. itemLevelCore.raid_id
	elseif (IsInGroup()) then
		unitid = "party" .. itemLevelCore.raid_id
	else
		return
	end

	local guid = UnitGUID(unitid)

    if detailsFramework.IsAddonApocalypseWow() then
        if issecretvalue(guid) then
            --print("itemLevelCore:Loop() -> guid is secret, skipping", guid)
            return
        end
    end

	if (guid == nil) then
		itemLevelCore.raid_id = itemLevelCore.raid_id + 1
		return
	end

	--if already inspecting or the actor is in the list of trusted actors
	if (inspecting[guid] or Details.trusted_characters[guid]) then
		return
	end

	local ilvlTable = Details.ilevel:GetIlvl(guid)
	if (ilvlTable and ilvlTable.time + 3600 > time()) then
		itemLevelCore.raid_id = itemLevelCore.raid_id + 1
		return
	end

	itemLevelCore:GetItemLevel(unitid, guid)
	itemLevelCore.raid_id = itemLevelCore.raid_id + 1
end

function itemLevelCore:EnterCombat()
	if (itemLevelCore.loop_process) then
		itemLevelCore:CancelTimer(itemLevelCore.loop_process)
		itemLevelCore.loop_process = nil
	end
end

local can_start_loop = function()
	--disable for timewalk wow ~timewalk
	if (DetailsFramework.IsTimewalkWoW()) then
		return false
	end

    if not CONST_CAN_START_LOOP then
        return false
    end

    Details.track_item_level = true

	if ((Details:GetZoneType() ~= "raid" and Details:GetZoneType() ~= "party") or itemLevelCore.loop_process or Details.in_combat or not Details.track_item_level) then
        if (debug) then
            --print("can_start_loop -> false")
        end
		return false
	end

    if (debug) then
        --print("can_start_loop -> true")
    end

	return true
end

function itemLevelCore:LeaveCombat()
	if (can_start_loop()) then
		itemLevelCore:Reset()
		itemLevelCore.loop_process = itemLevelCore:ScheduleRepeatingTimer("Loop", CONST_LOOP_TIME)
	end
end

function itemLevelCore:ZoneChanged(zone_type)
	if (can_start_loop()) then
		itemLevelCore:Reset()
		itemLevelCore.loop_process = itemLevelCore:ScheduleRepeatingTimer("Loop", CONST_LOOP_TIME)
	end
end

function itemLevelCore:OnEnter()
	Details:SendCharacterData()

	if (can_start_loop()) then
		itemLevelCore:Reset()
		itemLevelCore.loop_process = itemLevelCore:ScheduleRepeatingTimer("Loop", CONST_LOOP_TIME)
	end
end

function itemLevelCore:OnLeave()
	if (itemLevelCore.loop_process) then
		itemLevelCore:CancelTimer(itemLevelCore.loop_process)
		itemLevelCore.loop_process = nil
	end
end

--ilvl API
function Details.ilevel:IsTrackerEnabled()
	return Details.track_item_level
end

function Details.ilevel:TrackItemLevel(bool)
	if (type(bool) == "boolean") then
		if (bool) then
			Details.track_item_level = true
			if (can_start_loop()) then
				itemLevelCore:Reset()
				itemLevelCore.loop_process = itemLevelCore:ScheduleRepeatingTimer("Loop", CONST_LOOP_TIME)
			end
		else
			Details.track_item_level = false
			if (itemLevelCore.loop_process) then
				itemLevelCore:CancelTimer(itemLevelCore.loop_process)
				itemLevelCore.loop_process = nil
			end
		end
	end
end

function Details.ilevel:Add(unitGUID, unitName, itemLevel, time)
	Details.item_level_pool[unitGUID] = {name = unitName, ilvl = itemLevel, time = time}
end

function Details.ilevel:GetPool()
	return Details.item_level_pool
end

function Details.ilevel:GetIlvl(guid)
	return Details.item_level_pool[guid]
end

function Details.ilevel:GetInOrder()
	local order = {}

	for guid, t in pairs(Details.item_level_pool) do
		order[#order+1] = {t.name, t.ilvl or 0, t.time}
	end

	table.sort(order, Details.Sort2)

	return order
end

function Details.ilevel:ClearIlvl(guid)
	Details.item_level_pool[guid] = nil
end