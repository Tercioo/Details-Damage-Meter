
local Details = 		_G.Details
local addonName, Details222 = ...
local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
---@framework
local detailsFramework = DetailsFramework
local _

local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = DetailsFramework.UnitGroupRolesAssigned
local GetNumGroupMembers = GetNumGroupMembers
local GetSpellInfo = Details222.GetSpellInfo
local select = select
local floor = floor

local CONST_INSPECT_ACHIEVEMENT_DISTANCE = 1 --Compare Achievements, 28 yards
local CONST_SPELLBOOK_GENERAL_TABID = 1
local CONST_SPELLBOOK_CLASSSPELLS_TABID = 2

local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo

local storageDebug = false --remember to turn this to false!

function Details:UpdateGears()
	Details:UpdateParser()
	Details:UpdateControl()
	Details:UpdateCombat()
end

---@alias raid_difficulty_eng_name_lowercase "normal" | "heroic" | "mythic" | "raidfinder"



------------------------------------------------------------------------------------------------------------

function Details:SetDeathLogLimit(limitAmount)
	if (limitAmount and type(limitAmount) == "number" and limitAmount >= 8) then
		Details.deadlog_events = limitAmount

		local combatObject = Details:GetCurrentCombat()

		for playerName, eventTable in pairs(combatObject.player_last_events) do
			if (limitAmount > #eventTable) then
				for i = #eventTable + 1, limitAmount do
					eventTable [i] = {}
				end
			else
				eventTable.n = 1
				for _, t in ipairs(eventTable) do
					Details:Destroy(t)
				end
			end
		end

		Details:UpdateParserGears()
	end
end

------------------------------------------------------------------------------------------------------------

function Details:TrackSpecsNow(bTrackEverything)
	local specSpellList = Details.SpecSpellList
	---@type combat
	local currentCombat = Details:GetCurrentCombat()

	if (not bTrackEverything) then
		local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE) --DETAILS_ATTRIBUTE_DAMAGE is the integer 1, container 1 store DAMAGER data
		for _, actor in damageContainer:ListActors() do
			---@cast actor actor
			if (actor:IsPlayer()) then
				for spellId, spellTable in pairs(actor:GetSpellList()) do
					if (specSpellList[spellTable.id]) then
						actor:SetSpecId(specSpellList[spellTable.id])
						Details.cached_specs[actor.serial] = actor.spec
						break
					end
				end
			end
		end

		local healContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_HEAL) --DETAILS_ATTRIBUTE_HEAL is the integer 2, container 2 store heal data
		for _, actor in healContainer:ListActors() do
			---@cast actor actor
			if (actor:IsPlayer()) then
				for spellId, spellTable in pairs(actor:GetSpellList()) do
					if (specSpellList[spellTable.id]) then
						actor:SetSpecId(specSpellList[spellTable.id])
						Details.cached_specs[actor.serial] = actor.spec
						break
					end
				end
			end
		end
	else
		---@type combat[]
		local combatList = {}
		---@type combat[]
		local segmentsTable = Details:GetCombatSegments()
		---@type combat
		local combatOverall = Details:GetOverallCombat()

		for _, combat in ipairs(segmentsTable) do
			tinsert(combatList, combat)
		end

		tinsert(combatList, currentCombat)
		tinsert(combatList, combatOverall)

		for _, combatObject in ipairs(combatList) do
			local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
			for _, actor in damageContainer:ListActors() do
				---@cast actor actor
				if (actor:IsPlayer()) then
					for spellId, spellTable in pairs(actor:GetSpellList()) do
						if (specSpellList[spellTable.id]) then
							actor:SetSpecId(specSpellList[spellTable.id])
							Details.cached_specs[actor.serial] = actor.spec
							break
						end
					end
				end
			end

			local healContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_HEAL)
			for _, actor in healContainer:ListActors() do
				---@cast actor actor
				if (actor:IsPlayer()) then
					for spellId, spellTable in pairs(actor:GetSpellList()) do
						if (specSpellList[spellTable.id]) then
							actor:SetSpecId(specSpellList[spellTable.id])
							Details.cached_specs[actor.serial] = actor.spec
							break
						end
					end
				end
			end
		end
	end
end

function Details:ResetSpecCache(forced)
	local bIsInInstance = IsInInstance()

	if (forced or (not bIsInInstance and not Details.in_group)) then
		Details:Destroy(Details.cached_specs)

		if (Details.track_specs) then
			local playerSpec = DetailsFramework.GetSpecialization()
			if (type(playerSpec) == "number") then
				local specId = DetailsFramework.GetSpecializationInfo(playerSpec)
				if (type(specId) == "number") then
					local playerGuid = UnitGUID(Details.playername)
					if (playerGuid) then
						Details.cached_specs[playerGuid] = specId
					end
				end
			end
		end

	elseif (Details.in_group and not bIsInInstance) then
		Details:Destroy(Details.cached_specs)

		if (Details.track_specs) then
			if (IsInRaid()) then
				---@type combat
				local currentCombat = Details:GetCurrentCombat()
				local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
				local healContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_HEAL)
				local unitIdRaidCache = Details222.UnitIdCache.Raid

				for i = 1, GetNumGroupMembers() do
					local unitName = Details:GetFullName(unitIdRaidCache[i])
					local actorObject = damageContainer:GetActor(unitName)
					if (actorObject and actorObject.spec) then
						Details.cached_specs[actorObject.serial] = actorObject.spec
					else
						actorObject = healContainer:GetActor(unitName)
						if (actorObject and actorObject.spec) then
							Details.cached_specs[actorObject.serial] = actorObject.spec
						end
					end
				end
			end
		end
	end

end

local specialserials = {
	["3209-082F39F5"] = true, --quick
}

function Details:RefreshUpdater(intervalAmount)
	local updateInterval = intervalAmount or Details.update_speed

	if (Details.streamer_config.faster_updates) then
		--force 60 updates per second
		updateInterval = 0.016
	end

	if (Details.atualizador) then
		--_detalhes:CancelTimer(_detalhes.atualizador)
		Details.Schedules.Cancel(Details.atualizador)
	end

	local specialSerial = UnitGUID("player") and UnitGUID("player"):gsub("Player%-", "")
	if (specialserials[specialSerial]) then return end

	--_detalhes.atualizador = _detalhes:ScheduleRepeatingTimer("RefreshMainWindow", updateInterval, -1)
	--_detalhes.atualizador = Details.Schedules.NewTicker(updateInterval, Details.RefreshMainWindow, Details, -1)
	Details.atualizador = C_Timer.NewTicker(updateInterval, Details.RefreshAllMainWindowsTemp)
end

---set the amount of time between each update of all windows
---@param newInterval number?
---@param bNoSave boolean?
function Details:SetWindowUpdateSpeed(newInterval, bNoSave)
	if (not newInterval) then
		newInterval = Details.update_speed
	end

	if (type(newInterval) ~= "number") then
		newInterval = Details.update_speed or 0.3
	end

	if (not bNoSave) then
		Details.update_speed = newInterval
	end

	Details:RefreshUpdater(newInterval)
end

function Details:SetUseAnimations(bEnableAnimations, bNoSave)
	if (bEnableAnimations == nil) then
		bEnableAnimations = Details.use_row_animations
	end

	if (not bNoSave) then
		Details.use_row_animations = bEnableAnimations
	end

	Details.is_using_row_animations = bEnableAnimations
end

function Details:HavePerformanceProfileEnabled()
	return Details.performance_profile_enabled
end

Details.PerformanceIcons = {
	["RaidFinder"] = {icon = [[Interface\PvPRankBadges\PvPRank15]], color = {1, 1, 1, 1}},
	["Raid15"] = {icon = [[Interface\PvPRankBadges\PvPRank15]], color = {1, .8, 0, 1}},
	["Raid30"] = {icon = [[Interface\PvPRankBadges\PvPRank15]], color = {1, .8, 0, 1}},
	["Mythic"] = {icon = [[Interface\PvPRankBadges\PvPRank15]], color = {1, .4, 0, 1}},
	["Battleground15"] = {icon = [[Interface\PvPRankBadges\PvPRank07]], color = {1, 1, 1, 1}},
	["Battleground40"] = {icon = [[Interface\PvPRankBadges\PvPRank07]], color = {1, 1, 1, 1}},
	["Arena"] = {icon = [[Interface\PvPRankBadges\PvPRank12]], color = {1, 1, 1, 1}},
	["Dungeon"] = {icon = [[Interface\PvPRankBadges\PvPRank01]], color = {1, 1, 1, 1}},
}

function Details:CheckForPerformanceProfile()
	local performanceType = Details:GetPerformanceRaidType()
	local profile = Details.performance_profiles[performanceType]

	if (profile and profile.enabled) then
		Details:SetWindowUpdateSpeed(profile.update_speed, true)
		Details:SetUseAnimations(profile.use_row_animations, true)
		Details:CaptureSet(profile.damage, "damage")
		Details:CaptureSet(profile.heal, "heal")
		Details:CaptureSet(profile.energy, "energy")
		Details:CaptureSet(profile.miscdata, "miscdata")
		Details:CaptureSet(profile.aura, "aura")

		if (not Details.performance_profile_lastenabled or Details.performance_profile_lastenabled ~= performanceType) then
			Details:InstanceAlert(Loc ["STRING_OPTIONS_PERFORMANCE_PROFILE_LOAD"] .. performanceType, {Details.PerformanceIcons [performanceType].icon, 14, 14, false, 0, 1, 0, 1, unpack(Details.PerformanceIcons [performanceType].color)} , 5, {Details.empty_function})
		end

		Details.performance_profile_enabled = performanceType
		Details.performance_profile_lastenabled = performanceType
	else
		Details:SetWindowUpdateSpeed(Details.update_speed)
		Details:SetUseAnimations(Details.use_row_animations)
		Details:CaptureSet(Details.capture_real ["damage"], "damage")
		Details:CaptureSet(Details.capture_real ["heal"], "heal")
		Details:CaptureSet(Details.capture_real ["energy"], "energy")
		Details:CaptureSet(Details.capture_real ["miscdata"], "miscdata")
		Details:CaptureSet(Details.capture_real ["aura"], "aura")
		Details.performance_profile_enabled = nil
	end

end

function Details:GetPerformanceRaidType()
	local name, instanceType, difficulty, difficultyName, maxPlayers = GetInstanceInfo()

	if (instanceType == "none") then
		return nil
	end

	if (instanceType == "pvp") then
		if (maxPlayers == 40) then
			return "Battleground40"
		elseif (maxPlayers == 15) then
			return "Battleground15"
		else
			return nil
		end
	end

	if (instanceType == "arena") then
		return "Arena"
	end

	if (instanceType == "raid") then
		--mythic
		if (difficulty == 15) then
			return "Mythic"
		end

		--raid finder
		if (difficulty == 7) then
			return "RaidFinder"
		end

		--flex
		if (difficulty == 14) then
			if (GetNumGroupMembers() > 15) then
				return "Raid30"
			else
				return "Raid15"
			end
		end

		--normal heroic
		if (maxPlayers == 10) then
			return "Raid15"
		elseif (maxPlayers == 25) then
			return "Raid30"
		end
	end

	if (instanceType == "party") then
		return "Dungeon"
	end

	return nil
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--background tasks

local backgroundTasks = {}
local taskTimers = {
	["LOW"] = 30,
	["MEDIUM"] = 18,
	["HIGH"] = 10,
}

function Details:RegisterBackgroundTask(name, func, priority, ...)
	if true then return end
	assert(type(self) == "table", "RegisterBackgroundTask 'self' must be a table.")
	assert(type(name) == "string", "RegisterBackgroundTask param #1 must be a string.")
	if (type(func) == "string") then
		assert(type(self[func]) == "function", "RegisterBackgroundTask param #2 function not found on main object.")
	else
		assert(type(func) == "function", "RegisterBackgroundTask param #2 expect a function or function name.")
	end

	priority = priority or "LOW"
	priority = string.upper(priority)

	if (not taskTimers[priority]) then
		priority = "LOW"
	end

	if (backgroundTasks[name]) then
		backgroundTasks[name].func = func
		backgroundTasks[name].priority = priority
		backgroundTasks[name].args = {...}
		backgroundTasks[name].args_amt = select("#", ...)
		backgroundTasks[name].object = self
		return
	else
		backgroundTasks[name] = {func = func, lastexec = time(), priority = priority, nextexec = time() + taskTimers [priority] * 60, args = {...}, args_amt = select("#", ...), object = self}
	end
end

function Details:UnregisterBackgroundTask(name)
	backgroundTasks[name] = nil
end

function Details:DoBackgroundTasks()
	if (Details:GetZoneType() ~= "none" or Details:InGroup()) then
		return
	end

	local t = time()

	for taskName, taskTable in pairs(backgroundTasks) do
		if (t > taskTable.nextexec) then
			if (type(taskTable.func) == "string") then
				taskTable.object[taskTable.func](taskTable.object, unpack(taskTable.args, 1, taskTable.args_amt))
			else
				taskTable.func(unpack(taskTable.args, 1, taskTable.args_amt))
			end

			taskTable.nextexec = math.random(30, 120) + t + (taskTimers[taskTable.priority] * 60)
		end
	end
end

Details.background_tasks_loop = Details:ScheduleRepeatingTimer("DoBackgroundTasks", 120)

------
local hasGroupMemberInCombat = function()
	--iterate over party or raid members and check if any one of them are in combat, if any are return true
	if (IsInRaid()) then
		local amountOfPartyMembers = GetNumGroupMembers()
		for i, unitId in ipairs(Details222.UnitIdCache.Raid) do
			if (i <= amountOfPartyMembers) then
				if (UnitAffectingCombat(unitId)) then
					return true
				end
			else
				break
			end
		end
	else
		local amountOfPartyMembers = GetNumGroupMembers() + 1
		for i, unitId in ipairs(Details222.UnitIdCache.Party) do
			if (i <= amountOfPartyMembers) then
				if (UnitAffectingCombat(unitId)) then
					return true
				end
			else
				break
			end
		end
	end

	return false
end

local checkForGroupCombat_Ticker = function()
	local instanceName, isntanceType = GetInstanceInfo()
	if (isntanceType ~= "none") then
		if (Details222.parser_frame:GetScript("OnEvent") ~= Details222.Parser.OnParserEvent) then
			Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEvent)
		end
		Details222.Parser.EventFrame.ticker:Cancel()
		Details222.Parser.EventFrame.ticker = nil
		return
	end

	if (hasGroupMemberInCombat()) then
		Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEvent)
	else
		Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEventOutOfCombat)
		Details222.Parser.EventFrame.ticker:Cancel()
		Details222.Parser.EventFrame.ticker = nil
	end
end

--~parser
local bConsiderGroupMembers = true
Details222.Parser.Handler = {}
Details222.Parser.EventFrame = CreateFrame("frame")
Details222.Parser.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
Details222.Parser.EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Details222.Parser.EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
Details222.Parser.EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
Details222.Parser.EventFrame:SetScript("OnEvent", function(self, event, ...)
	do return end
	local instanceName, isntanceType = GetInstanceInfo()

	if (isntanceType == "pvp" or isntanceType == "arena") then
		Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEventPVP)
		return
	end

	if (isntanceType ~= "none") then
		if (Details222.parser_frame:GetScript("OnEvent") ~= Details222.Parser.OnParserEvent) then
			Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEvent)
		end
		return
	end

	if (event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA") then
		if (bConsiderGroupMembers) then
			--check if any group member is in combat
			if (hasGroupMemberInCombat()) then
				Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEvent)
				--initiate a ticker to check if a unit in the group is still in combat
				if (not Details222.Parser.EventFrame.ticker) then
					Details222.Parser.EventFrame.ticker = C_Timer.NewTicker(1, checkForGroupCombat_Ticker)
				end
			else
				Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEventOutOfCombat)
			end
		else
			--player is alone
			if (InCombatLockdown()) then
				Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEvent)
			else
				Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEventOutOfCombat)
			end
		end

	elseif (event == "PLAYER_REGEN_DISABLED") then
		Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEvent)

	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (bConsiderGroupMembers) then
			--check if any group member is in combat
			if (hasGroupMemberInCombat()) then
				Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEvent)
				--initiate a ticker to check if a unit in the group is still in combat
				if (not Details222.Parser.EventFrame.ticker) then
					Details222.Parser.EventFrame.ticker = C_Timer.NewTicker(1, checkForGroupCombat_Ticker)
				end
			else
				Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEventOutOfCombat)
			end
		else
			Details222.parser_frame:SetScript("OnEvent", Details222.Parser.OnParserEventOutOfCombat)
		end
	end
end)

--create a details listener which registers the combat enter event, create the function to receive the registerted event ad call the Details222.Parser.EventFrame:OnEvent with player_regen_disable
local detailsEnterInCombatListener = Details:CreateEventListener()
detailsEnterInCombatListener:RegisterEvent("COMBAT_PLAYER_ENTER") --COMBAT_PLAYER_ENTER from events.lua, this event is triggered when Details! enter in combat
function detailsEnterInCombatListener:OnEvent()
	if (Details222.Parser.GetState() == "STATE_RESTRICTED") then
		Details222.Parser.EventFrame:GetScript("OnEvent")(Details222.Parser.EventFrame, "PLAYER_REGEN_DISABLED")
	end
end

function Details222.Parser.GetState()
	local parserEngine = Details222.parser_frame:GetScript("OnEvent")
	if (parserEngine == Details222.Parser.OnParserEvent) then
		return "STATE_REGULAR"
	elseif (parserEngine == Details222.Parser.OnParserEventPVP) then
		return "STATE_PVP"
	elseif (parserEngine == Details222.Parser.OnParserEventOutOfCombat) then
		return "STATE_RESTRICTED"
	end
end



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--inspect stuff

Details.ilevel = {}
local ilvl_core = Details:CreateEventListener()
ilvl_core.amt_inspecting = 0
Details.ilevel.core = ilvl_core

ilvl_core:RegisterEvent("GROUP_ONENTER", "OnEnter")
ilvl_core:RegisterEvent("GROUP_ONLEAVE", "OnLeave")
ilvl_core:RegisterEvent("COMBAT_PLAYER_ENTER", "EnterCombat")
ilvl_core:RegisterEvent("COMBAT_PLAYER_LEAVE", "LeaveCombat")
ilvl_core:RegisterEvent("ZONE_TYPE_CHANGED", "ZoneChanged")

local inspecting = {}
ilvl_core.forced_inspects = {}

function ilvl_core:HasQueuedInspec(unitName)
	local guid = UnitGUID(unitName)
	if (guid) then
		return ilvl_core.forced_inspects [guid]
	end
end

local inspect_frame = CreateFrame("frame")
inspect_frame:RegisterEvent("INSPECT_READY")

local two_hand = {
	["INVTYPE_2HWEAPON"] = true,
 	["INVTYPE_RANGED"] = true,
	["INVTYPE_RANGEDRIGHT"] = true,
}

local MAX_INSPECT_AMOUNT = 1
local MIN_ILEVEL_TO_STORE = 50
local LOOP_TIME = 7

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
		Details.item_level_pool[unitGUID] = {name = unitName, ilvl = itemLevel, time = time()}
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

function ilvl_core:CalcItemLevel(unitid, guid, shout)

	if (type(unitid) == "table") then
		shout = unitid [3]
		guid = unitid [2]
		unitid = unitid [1]
	end

	--disable due to changes to CheckInteractDistance()
	if (not InCombatLockdown() and unitid and UnitPlayerControlled(unitid) and CheckInteractDistance(unitid, CONST_INSPECT_ACHIEVEMENT_DISTANCE) and CanInspect(unitid)) then

		--16 = all itens including main and off hand
		local item_amount = 16
		local item_level = 0
		local failed = 0

		for equip_id = 1, 17 do
			if (equip_id ~= 4) then --shirt slot
				local item = GetInventoryItemLink(unitid, equip_id)
				if (item) then
					local _, _, itemRarity, iLevel, _, _, _, _, equipSlot = GetItemInfo(item)
					if (iLevel) then
						item_level = item_level + iLevel

						--16 = main hand 17 = off hand
						-- if using a two-hand, ignore the off hand slot
						if (equip_id == 16 and two_hand [equipSlot]) then
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

			if (average > MIN_ILEVEL_TO_STORE) then
				local unitName = Details:GetFullName(unitid)
				Details.item_level_pool [guid] = {name = unitName, ilvl = average, time = time()}
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
		end

		--------------------------------------------------------------------------------------------------------

		if (ilvl_core.forced_inspects [guid]) then
			if (type(ilvl_core.forced_inspects [guid].callback) == "function") then
				local okey, errortext = pcall(ilvl_core.forced_inspects[guid].callback, guid, unitid, ilvl_core.forced_inspects[guid].param1, ilvl_core.forced_inspects[guid].param2)
				if (not okey) then
					Details:Msg("Error on QueryInspect callback: " .. errortext)
				end
			end
			ilvl_core.forced_inspects [guid] = nil
		end

		--------------------------------------------------------------------------------------------------------

	end
end

Details.ilevel.CalcItemLevel = ilvl_core.CalcItemLevel

inspect_frame:SetScript("OnEvent", function(self, event, ...)
	local guid = select(1, ...)

	if (inspecting [guid]) then
		local unitid, cancel_tread = inspecting [guid] [1], inspecting [guid] [2]
		inspecting [guid] = nil
		ilvl_core.amt_inspecting = ilvl_core.amt_inspecting - 1

		ilvl_core:CancelTimer(cancel_tread)

		--do inspect stuff
		if (unitid) then
			local t = {unitid, guid}
			--ilvl_core:ScheduleTimer("CalcItemLevel", 0.5, t)
			ilvl_core:ScheduleTimer("CalcItemLevel", 0.5, t)
			ilvl_core:ScheduleTimer("CalcItemLevel", 2, t)
			ilvl_core:ScheduleTimer("CalcItemLevel", 4, t)
			ilvl_core:ScheduleTimer("CalcItemLevel", 8, t)
		end
	else
		if (IsInRaid()) then
			--get the unitID
			local serial = ...
			if (serial and type(serial) == "string") then
				for i = 1, GetNumGroupMembers() do
					if (UnitGUID("raid" .. i) == serial) then
						ilvl_core:ScheduleTimer("CalcItemLevel", 2, {"raid" .. i, serial})
						ilvl_core:ScheduleTimer("CalcItemLevel", 4, {"raid" .. i, serial})
					end
				end
			end
		end
	end
end)

function ilvl_core:InspectTimeOut(guid)
	inspecting [guid] = nil
	ilvl_core.amt_inspecting = ilvl_core.amt_inspecting - 1
end

function ilvl_core:ReGetItemLevel(t)
	local unitid, guid, is_forced, try_number = unpack(t)
	return ilvl_core:GetItemLevel(unitid, guid, is_forced, try_number)
end

function ilvl_core:GetItemLevel(unitid, guid, is_forced, try_number)

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
			ilvl_core:ScheduleTimer("ReGetItemLevel", 3, {unitid, guid, is_forced, try_number})
		end
		return
	end

	inspecting [guid] = {unitid, ilvl_core:ScheduleTimer("InspectTimeOut", 12, guid)}
	ilvl_core.amt_inspecting = ilvl_core.amt_inspecting + 1

	--NotifyInspect(unitid)
end

local NotifyInspectHook = function(unitid) --not in use
	local unit = unitid:gsub("%d+", "")

	if ((IsInRaid() or IsInGroup()) and(Details:GetZoneType() == "raid" or Details:GetZoneType() == "party")) then
		local guid = UnitGUID(unitid)
		local name = Details:GetFullName(unitid)
		if (guid and name and not inspecting [guid]) then
			for i = 1, GetNumGroupMembers() do
				if (name == Details:GetFullName(unit .. i)) then
					unitid = unit .. i
					break
				end
			end

			inspecting [guid] = {unitid, ilvl_core:ScheduleTimer("InspectTimeOut", 12, guid)}
			ilvl_core.amt_inspecting = ilvl_core.amt_inspecting + 1
		end
	end
end
--hooksecurefunc("NotifyInspect", NotifyInspectHook)

function ilvl_core:Reset()
	ilvl_core.raid_id = 1
	ilvl_core.amt_inspecting = 0

	for guid, t in pairs(inspecting) do
		ilvl_core:CancelTimer(t[2])
		inspecting [guid] = nil
	end
end

function ilvl_core:QueryInspect(unitName, callback, param1)
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
	elseif (ilvl_core.forced_inspects [guid]) then
		return true
	end

	if (inspecting [guid]) then
		return true
	end

	ilvl_core.forced_inspects [guid] = {callback = callback, param1 = param1}
	ilvl_core:GetItemLevel(unitid, guid, true)

	if (ilvl_core.clear_queued_list) then
		ilvl_core:CancelTimer(ilvl_core.clear_queued_list)
	end
	ilvl_core.clear_queued_list = ilvl_core:ScheduleTimer("ClearQueryInspectQueue", 60)

	return true
end

function ilvl_core:ClearQueryInspectQueue()
	Details:Destroy(ilvl_core.forced_inspects)
	ilvl_core.clear_queued_list = nil
end

function ilvl_core:Loop()
	--disable for timewalk wow ~timewalk
	if (DetailsFramework.IsTimewalkWoW()) then
		return
	end

	if (ilvl_core.amt_inspecting >= MAX_INSPECT_AMOUNT) then
		return
	end

	local members_amt = GetNumGroupMembers()
	if (ilvl_core.raid_id > members_amt) then
		ilvl_core.raid_id = 1
	end

	local unitid
	if (IsInRaid()) then
		unitid = "raid" .. ilvl_core.raid_id
	elseif (IsInGroup()) then
		unitid = "party" .. ilvl_core.raid_id
	else
		return
	end

	local guid = UnitGUID(unitid)
	if (not guid) then
		ilvl_core.raid_id = ilvl_core.raid_id + 1
		return
	end

	--if already inspecting or the actor is in the list of trusted actors
	if (inspecting [guid] or Details.trusted_characters [guid]) then
		return
	end

	local ilvl_table = Details.ilevel:GetIlvl(guid)
	if (ilvl_table and ilvl_table.time + 3600 > time()) then
		ilvl_core.raid_id = ilvl_core.raid_id + 1
		return
	end

	ilvl_core:GetItemLevel(unitid, guid)
	ilvl_core.raid_id = ilvl_core.raid_id + 1
end

function ilvl_core:EnterCombat()
	if (ilvl_core.loop_process) then
		ilvl_core:CancelTimer(ilvl_core.loop_process)
		ilvl_core.loop_process = nil
	end
end

local can_start_loop = function()
	--disable for timewalk wow ~timewalk
	if (DetailsFramework.IsTimewalkWoW()) then
		return false
	end

	if ((Details:GetZoneType() ~= "raid" and Details:GetZoneType() ~= "party") or ilvl_core.loop_process or Details.in_combat or not Details.track_item_level) then
		return false
	end
	return true
end

function ilvl_core:LeaveCombat()
	if (can_start_loop()) then
		ilvl_core:Reset()
		ilvl_core.loop_process = ilvl_core:ScheduleRepeatingTimer("Loop", LOOP_TIME)
	end
end

function ilvl_core:ZoneChanged(zone_type)
	if (can_start_loop()) then
		ilvl_core:Reset()
		ilvl_core.loop_process = ilvl_core:ScheduleRepeatingTimer("Loop", LOOP_TIME)
	end
end

function ilvl_core:OnEnter()
	Details:SendCharacterData()

	if (can_start_loop()) then
		ilvl_core:Reset()
		ilvl_core.loop_process = ilvl_core:ScheduleRepeatingTimer("Loop", LOOP_TIME)
	end
end

function ilvl_core:OnLeave()
	if (ilvl_core.loop_process) then
		ilvl_core:CancelTimer(ilvl_core.loop_process)
		ilvl_core.loop_process = nil
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
				ilvl_core:Reset()
				ilvl_core.loop_process = ilvl_core:ScheduleRepeatingTimer("Loop", LOOP_TIME)
			end
		else
			Details.track_item_level = false
			if (ilvl_core.loop_process) then
				ilvl_core:CancelTimer(ilvl_core.loop_process)
				ilvl_core.loop_process = nil
			end
		end
	end
end

function Details.ilevel:GetPool()
	return Details.item_level_pool
end

function Details:GetItemLevelFromGuid(guid)
	return Details.item_level_pool[guid] and Details.item_level_pool[guid].ilvl or 0
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

function Details:GetTalents(guid)
	return Details.cached_talents [guid]
end

function Details:GetSpecFromSerial(guid)
	return Details.cached_specs [guid]
end

--------------------------------------------------------------------------------------------------------------------------------------------
--compress data

-- ~compress ~zip ~export ~import ~deflate ~serialize
function Details:CompressData(data, dataType)
	local LibDeflate = LibStub:GetLibrary("LibDeflate")
	local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

	--check if there isn't funtions in the data to export
	local dataCopied = DetailsFramework.table.copytocompress({}, data)

	if (LibDeflate and LibAceSerializer) then
		local dataSerialized = LibAceSerializer:Serialize(dataCopied)
		if (dataSerialized) then
			local dataCompressed = LibDeflate:CompressDeflate(dataSerialized, {level = 9})
			if (dataCompressed) then
				if (dataType == "print") then
					local dataEncoded = LibDeflate:EncodeForPrint(dataCompressed)
					return dataEncoded

				elseif (dataType == "comm") then
					local dataEncoded = LibDeflate:EncodeForWoWAddonChannel(dataCompressed)
					return dataEncoded
				end
			end
		end
	end
end

function Details:DecompressData(data, dataType)
	local LibDeflate = LibStub:GetLibrary("LibDeflate")
	local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

	if (LibDeflate and LibAceSerializer) then

		local dataCompressed

		if (dataType == "print") then

			data = DetailsFramework:Trim(data)

			dataCompressed = LibDeflate:DecodeForPrint(data)
			if (not dataCompressed) then
				Details:Msg("couldn't decode the data.")
				return false
			end

		elseif (dataType == "comm") then
			dataCompressed = LibDeflate:DecodeForWoWAddonChannel(data)
			if (not dataCompressed) then
				Details:Msg("couldn't decode the data.")
				return false
			end
		end
		local dataSerialized = LibDeflate:DecompressDeflate(dataCompressed)

		if (not dataSerialized) then
			Details:Msg("couldn't uncompress the data.")
			return false
		end

		local okay, data = LibAceSerializer:Deserialize(dataSerialized)
		if (not okay) then
			Details:Msg("couldn't unserialize the data.")
			return false
		end

		return data
	end
end

Details.specToRole = {
	--DRUID
	[102] = "DAMAGER", --BALANCE
	[103] = "DAMAGER", --FERAL DRUID
	[105] = "HEALER", --RESTORATION

	--HUNTER
	[253] = "DAMAGER", --BM
	[254] = "DAMAGER", --MM
	[255] = "DAMAGER", --SURVIVOR

	--MAGE
	[62] = "DAMAGER", --ARCANE
	[64] = "DAMAGER", --FROST
	[63] = "DAMAGER", ---FIRE

	--PALADIN
	[70] = "DAMAGER", --RET
	[65] = "HEALER", --HOLY
	[66] = "TANK", --PROT

	--PRIEST
	[257] = "HEALER", --HOLY
	[256] = "HEALER", --DISC
	[258] = "DAMAGER", --SHADOW

	--ROGUE
	[259] = "DAMAGER", --ASSASSINATION
	[260] = "DAMAGER", --COMBAT
	[261] = "DAMAGER", --SUB

	--SHAMAN
	[262] = "DAMAGER", --ELEMENTAL
	[263] = "DAMAGER", --ENHAN
	[264] = "HEALER", --RESTO

	--WARLOCK
	[265] = "DAMAGER", --AFF
	[266] = "DAMAGER", --DESTRO
	[267] = "DAMAGER", --DEMO

	--WARRIOR
	[71] = "DAMAGER", --ARMS
	[72] = "DAMAGER", --FURY
	[73] = "TANK", --PROT

	--DK
	[250] = "TANK", --Blood
	[251] = "DAMAGER", --Frost
	[252] = "DAMAGER", --Unholy

	--MONK
	[268] = "TANK", -- Brewmaster Monk
	[269] = "DAMAGER", -- Windwalker Monk
	[270] = "HEALER", -- Mistweaver Monk

	--DH
	[577] = "DAMAGER", -- Havoc Demon Hunter
	[581] = "TANK", -- Vengeance Demon Hunter

	--EVOKER
	[1467] = "DAMAGER", --Devastation Evoker
	[1468] = "HEALER", --Preservation Evoker
	[1473] = "DAMAGER", --Augmentation Evoker
}

--oldschool talent tree
if (DetailsFramework.IsWotLKWow() or DetailsFramework.IsCataWow()) then
	local talentWatchClassic = CreateFrame("frame")
	talentWatchClassic:RegisterEvent("CHARACTER_POINTS_CHANGED")
	talentWatchClassic:RegisterEvent("SPELLS_CHANGED")
	talentWatchClassic:RegisterEvent("PLAYER_ENTERING_WORLD")
	talentWatchClassic:RegisterEvent("GROUP_ROSTER_UPDATE")

	talentWatchClassic.cooldown = 0

	C_Timer.NewTicker(600, function()
		Details:GetOldSchoolTalentInformation()
	end)

	talentWatchClassic:SetScript("OnEvent", function(self, event, ...)
		if (talentWatchClassic.delayedUpdate and not talentWatchClassic.delayedUpdate:IsCancelled()) then
			return
		else
			talentWatchClassic.delayedUpdate = C_Timer.NewTimer(5, Details.GetOldSchoolTalentInformation)
		end
	end)

	function Details.GetOldSchoolTalentInformation()
		--cancel any schedule
		if (talentWatchClassic.delayedUpdate and not talentWatchClassic.delayedUpdate:IsCancelled()) then
			talentWatchClassic.delayedUpdate:Cancel()
		end
		talentWatchClassic.delayedUpdate = nil

		--amount of tabs existing
		local numTabs = GetNumTalentTabs() or 3

		--store the background textures for each tab
		local pointsPerSpec = {}
		local talentsSelected = {}

		for i = 1,(MAX_TALENT_TABS or 3) do
			if (i <= numTabs) then
				--tab information
				local id, name, description, iconTexture, pointsSpent, fileName = GetTalentTabInfo(i)

				if (name) then
					tinsert(pointsPerSpec, {name, pointsSpent, fileName})
				end

				--talents information
				local numTalents = GetNumTalents(i) or 20
				local MAX_NUM_TALENTS = MAX_NUM_TALENTS or 20

				for talentIndex = 1, MAX_NUM_TALENTS do
					if (talentIndex <= numTalents) then
						local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(i, talentIndex)
						if (name and rank and type(rank) == "number") then
							--send the specID instead of the specName
							local specID = Details.textureToSpec [fileName]
							tinsert(talentsSelected, {iconTexture, rank, tier, column, i, specID, maxRank})
						end
					end
				end
			end
		end

		local MIN_SPECS = 4

		--put the spec with more talent point to the top
		table.sort(pointsPerSpec, function(t1, t2) return t1[2] > t2[2] end)

		--get the spec with more points spent
		local spec = pointsPerSpec[1]
		if (spec and spec[2] >= MIN_SPECS) then
			local specTexture = spec[3]

			--add the spec into the spec cache
			Details.playerClassicSpec = {}
			Details.playerClassicSpec.specs = Details.GetClassicSpecByTalentTexture(specTexture)
			Details.playerClassicSpec.talents = talentsSelected

			--cache the player specId
			Details.cached_specs [UnitGUID("player")] = Details.playerClassicSpec.specs
			--cache the player talents
			Details.cached_talents [UnitGUID("player")] = talentsSelected

			local role = Details:GetRoleFromSpec(Details.playerClassicSpec.specs, UnitGUID("player"))

			if (Details.playerClassicSpec.specs == 103) then
				if (role == "TANK") then
					Details.playerClassicSpec.specs = 104
					Details.cached_specs [UnitGUID("player")] = Details.playerClassicSpec.specs
				end
			end

			Details.cached_roles[UnitGUID("player")] = role

			--gear status
			local item_amount = 16
			local item_level = 0
			local failed = 0

			local two_hand = {
				["INVTYPE_2HWEAPON"] = true,
				["INVTYPE_RANGED"] = true,
				["INVTYPE_RANGEDRIGHT"] = true,
			}

			for equip_id = 1, 17 do
				if (equip_id ~= 4) then --shirt slot, trinkets
					local item = GetInventoryItemLink("player", equip_id)
					if (item) then
						local _, _, itemRarity, iLevel, _, _, _, _, equipSlot = GetItemInfo(item)
						if (iLevel) then
							item_level = item_level + iLevel

							--16 = main hand 17 = off hand
							-- if using a two-hand, ignore the off hand slot
							if (equip_id == 16 and two_hand [equipSlot]) then
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

    		local itemLevel = floor(item_level / item_amount)
			local dataToShare = {role or "NONE", Details.playerClassicSpec.specs or 0, itemLevel or 0, talentsSelected, UnitGUID("player")}
			--local serialized = _detalhes:Serialize(dataToShare)
			local compressedData = Details:CompressData(dataToShare, "comm")

			if (IsInRaid()) then
				Details:SendRaidData(DETAILS_PREFIX_TBC_DATA, compressedData)
				if (Details.debug) then
					Details:Msg("(debug) sent talents data to Raid")
				end

			elseif (IsInGroup()) then
				Details:SendPartyData(DETAILS_PREFIX_TBC_DATA, compressedData)
				if (Details.debug) then
					Details:Msg("(debug) sent talents data to Party")
				end
			end
		end
	end

	function Details:GetRoleFromSpec(specId, unitGUID)
		if (specId == 103) then --feral druid
			local talents = Details.cached_talents [unitGUID]
			if (talents) then
				local tankTalents = 0
				for i = 1, #talents do
					local iconTexture, rank, tier, column = unpack(talents [i])
					if (tier == 2) then
						if (column == 1 and rank == 5) then
							tankTalents = tankTalents + 5
						end
						if (column == 3 and rank == 5) then
							tankTalents = tankTalents + 5
						end

						if (tankTalents >= 10) then
							return "TANK"
						end
					end
				end
			end
		end

		return Details.specToRole [specId] or "NONE"
	end

	Details.validSpecIds = {
		[250] = true,
		[252] = true,
		[251] = true,
		[102] = true,
		[103] = true,
		[104] = true,
		[105] = true,
		[253] = true,
		[254] = true,
		[255] = true,
		[62] = true,
		[63] = true,
		[64] = true,
		[70] = true,
		[65] = true,
		[66] = true,
		[257] = true,
		[256] = true,
		[258] = true,
		[259] = true,
		[260] = true,
		[261] = true,
		[262] = true,
		[263] = true,
		[264] = true,
		[265] = true,
		[266] = true,
		[267] = true,
		[71] = true,
		[72] = true,
		[73] = true,
	}

	Details.textureToSpec = {

		DruidBalance = 102,
		DruidFeralCombat = 103,
		DruidRestoration = 105,

		HunterBeastMastery = 253,
		HunterMarksmanship = 254,
		HunterSurvival = 255,

		MageArcane = 62,
		MageFrost = 64,
		MageFire = 63,

		PaladinCombat = 70,
		PaladinHoly = 65,
		PaladinProtection = 66,

		PriestHoly = 257,
		PriestDiscipline = 256,
		PriestShadow = 258,

		RogueAssassination = 259,
		RogueCombat = 260,
		RogueSubtlety = 261,

		ShamanElementalCombat = 262,
		ShamanEnhancement = 263,
		ShamanRestoration = 264,

		WarlockCurses = 265, --affliction
		WarlockSummoning = 266, --demo
		WarlockDestruction = 267, --destruction

		--WarriorArm = 71,
		WarriorArms = 71,
		WarriorFury = 72,
		WarriorProtection = 73,

		DeathKnightBlood = 250,
		DeathKnightFrost = 251,
		DeathKnightUnholy = 252,
	}


	Details.specToTexture = {
		[102] = "DruidBalance",
		[103] = "DruidFeralCombat",
		[105] = "DruidRestoration",

		[253] = "HunterBeastMastery",
		[254] = "HunterMarksmanship",
		[255] = "HunterSurvival",

		[62] = "MageArcane",
		[64] = "MageFrost",
		[63] = "MageFire",

		[70] = "PaladinCombat",
		[65] = "PaladinHoly",
		[66] = "PaladinProtection",

		[257] = "PriestHoly",
		[256] = "PriestDiscipline",
		[258] = "PriestShadow",

		[259] = "RogueAssassination",
		[260] = "RogueCombat",
		[261] = "RogueSubtlety",

		[262] = "ShamanElementalCombat",
		[263] = "ShamanEnhancement",
		[264] = "ShamanRestoration",

		[265] = "WarlockCurses",
		[266] = "WarlockDestruction",
		[267] = "WarlockSummoning",

		--[71] = "WarriorArm",
		[71] = "WarriorArms",
		[72] = "WarriorFury",
		[73] = "WarriorProtection",

		[250] = "DeathKnightBlood",
		[251] = "DeathKnightFrost",
		[252] = "DeathKnightUnholy",
	}

	function Details.IsValidSpecId(specId)
		return Details.validSpecIds [specId]
	end

	function Details.GetClassicSpecByTalentTexture(talentTexture)
		return Details.textureToSpec [talentTexture] or nil
	end
end


--dragonflight talents, return {[spellId] = true}
function Details.GetDragonflightTalentsAsHashTable()
	local allTalents = {}
	local configId = C_ClassTalents.GetActiveConfigID()
	if (not configId) then
		return allTalents
	end

	local configInfo = C_Traits.GetConfigInfo(configId)

	for treeIndex, treeId in ipairs(configInfo.treeIDs) do
		local treeNodes = C_Traits.GetTreeNodes(treeId)

		for nodeIdIndex, treeNodeID in ipairs(treeNodes) do
			local traitNodeInfo = C_Traits.GetNodeInfo(configId, treeNodeID)

			if (traitNodeInfo) then
				local activeEntry = traitNodeInfo.activeEntry
				if (activeEntry) then
					local entryId = activeEntry.entryID
					local rank = activeEntry.rank
					if (rank > 0) then
						--get the entry info
						local traitEntryInfo = C_Traits.GetEntryInfo(configId, entryId)
						local definitionId = traitEntryInfo.definitionID

						--definition info
						local traitDefinitionInfo = C_Traits.GetDefinitionInfo(definitionId)
						local spellId = traitDefinitionInfo.overriddenSpellID or traitDefinitionInfo.spellID
						local spellName, _, spellTexture = GetSpellInfo(spellId)
						if (spellName) then
							allTalents[spellId] = true
						end
					end
				end
			end
		end
	end

	return allTalents
end


--called from inside the function Details.GenerateSpecSpellList()
local getSpellList = function(specIndex, completeListOfSpells, sharedSpellsBetweenSpecs, specNames)

	local specId, specName, _, specIconTexture = GetSpecializationInfo(specIndex)
	completeListOfSpells[specId] = {}
	specNames[specId] = specName

	--get spells from talents
	local configId = C_ClassTalents.GetActiveConfigID()
	if (not configId) then
		return completeListOfSpells
	end

	local configInfo = C_Traits.GetConfigInfo(configId)
	--get the spells from the SPEC from talents
	for treeIndex, treeId in ipairs(configInfo.treeIDs) do
		local treeNodes = C_Traits.GetTreeNodes(treeId)
		for nodeIdIndex, treeNodeID in ipairs(treeNodes) do
			local traitNodeInfo = C_Traits.GetNodeInfo(configId, treeNodeID)
			if (traitNodeInfo and traitNodeInfo.posX > 9000) then
				local entryIds = traitNodeInfo.entryIDs
				for i = 1, #entryIds do
					local entryId = entryIds[i] --number
					local traitEntryInfo = C_Traits.GetEntryInfo(configId, entryId)
					local borderTypes = Enum.TraitNodeEntryType
					if (traitEntryInfo.type == borderTypes.SpendSquare) then
						local definitionId = traitEntryInfo.definitionID
						local traitDefinitionInfo = C_Traits.GetDefinitionInfo(definitionId)
						local spellId = traitDefinitionInfo.overriddenSpellID or traitDefinitionInfo.spellID
						local spellName, _, spellTexture = GetSpellInfo(spellId)
						if (spellName) then
							completeListOfSpells[specId][spellId] = specId
						end
					end
				end
			end
		end
	end

    --get spells of the SPEC from the spell book
    for i = 1, GetNumSpellTabs() do
        local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(i)
        if (tabTexture == specIconTexture) then
            offset = offset + 1
            local tabEnd = offset + numSpells
            for entryOffset = offset, tabEnd - 1 do
                local spellType, spellId = GetSpellBookItemInfo(entryOffset, "player")
                if (spellId) then
                    if (spellType == "SPELL") then
                        spellId = C_SpellBook.GetOverrideSpell(spellId)
                        local spellName = GetSpellInfo(spellId)
                        local isPassive = IsPassiveSpell(entryOffset, "player")
                        if (spellName and not isPassive) then
                            completeListOfSpells[specId][spellId] = specId
                        end
                    end
                end
            end
        end
    end

    --get shared spells from the spell book
    local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(CONST_SPELLBOOK_CLASSSPELLS_TABID)
    offset = offset + 1
    local tabEnd = offset + numSpells
    for entryOffset = offset, tabEnd - 1 do
        local spellType, spellId = GetSpellBookItemInfo(entryOffset, "player")
        if (spellId) then
            if (spellType == "SPELL") then
                spellId = C_SpellBook.GetOverrideSpell(spellId)
                local spellName = GetSpellInfo(spellId)
                local isPassive = IsPassiveSpell(entryOffset, "player")
                if (spellName and not isPassive) then
                    sharedSpellsBetweenSpecs[spellId] = true
                end
            end
        end
    end

	local classNameLoc = UnitClass("player")
    print(specName .. " " .. classNameLoc .. " spells recorded.")
	return completeListOfSpells, sharedSpellsBetweenSpecs, specNames
end

function Details.GenerateSpecSpellList()
    local dumpSpellTable = 1

    local specId, specName, _, specIconTexture = GetSpecializationInfo(GetSpecialization())
    local classNameLoc, className, classId = UnitClass("player")

	local completeListOfSpells = {}
	local sharedSpellsBetweenSpecs = {}
	local specNames = {}

	local amountSpecs = GetNumSpecializationsForClassID(classId)

	local totalTimeToWait = 0
	DetailsFramework.Schedules.NewTimer(0, function() SetSpecialization(1) end)
	DetailsFramework.Schedules.NewTimer(6, getSpellList, 1, completeListOfSpells, sharedSpellsBetweenSpecs, specNames)
	totalTimeToWait = 7
	DetailsFramework.Schedules.NewTimer(7, function() SetSpecialization(2) end)
	DetailsFramework.Schedules.NewTimer(13, getSpellList, 2, completeListOfSpells, sharedSpellsBetweenSpecs, specNames)
	totalTimeToWait = 14

	if (amountSpecs >= 3) then
		DetailsFramework.Schedules.NewTimer(14, function() SetSpecialization(3) end)
		DetailsFramework.Schedules.NewTimer(20, getSpellList, 3, completeListOfSpells, sharedSpellsBetweenSpecs, specNames)
		totalTimeToWait = 21
	end

	if (amountSpecs >= 4) then
		DetailsFramework.Schedules.NewTimer(21, function() SetSpecialization(4) end)
		DetailsFramework.Schedules.NewTimer(28, getSpellList, 4, completeListOfSpells, sharedSpellsBetweenSpecs, specNames)
		totalTimeToWait = 29
	end

	print("Total Time to Wait:", totalTimeToWait)
	DetailsFramework.Schedules.NewTimer(totalTimeToWait, function()
		if (dumpSpellTable) then
			local parsedSpells = {}
			local sharedSpells = sharedSpellsBetweenSpecs

			for specId, spellTable in pairs(completeListOfSpells) do
				parsedSpells[specId] = {}

				--create a list of spells which is in use in the other spec talent tree
				local spellsInUse = {}
				for specId2, spellTable2 in pairs(completeListOfSpells) do
					if (specId2 ~= specId) then
						for spellId in pairs(spellTable2) do
							spellsInUse[spellId] = true
						end
					end
				end
				for spellId in pairs(sharedSpells) do
					spellsInUse[spellId] = true
				end

				--build the list of spells for this spec
				for spellId in pairs(spellTable) do
					if (not spellsInUse[spellId]) then
						parsedSpells[specId][spellId] = true
					end
				end
			end

			local result = ""
			for specId, spellsTable in pairs(parsedSpells) do
				local specName = specNames[specId]
				result = result .. "\n--" .. specName .. " " .. classNameLoc .. ":\n"
				for spellId in pairs(spellsTable) do
					local spellName = GetSpellInfo(spellId)
					result = result .. "[" .. spellId .. "] = " .. specId .. ", --" .. spellName .. "\n"
				end
			end

			Details:Dump({result})
		end
	end)
end

function Details.GenerateRacialSpellList()
	local racialsSpells = "|n"
	local locClassName, unitClass = UnitClass("player")
	local locPlayerRace, playerRace, playerRaceId = UnitRace("player")
    --get general spells from the spell book
    local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(CONST_SPELLBOOK_GENERAL_TABID)
    offset = offset + 1
    local tabEnd = offset + numSpells
    for entryOffset = offset, tabEnd - 1 do
        local spellType, spellId = GetSpellBookItemInfo(entryOffset, "player")
        if (spellId) then
			local spell = Spell:CreateFromSpellID(spellId)
			local subSpellName = spell:GetSpellSubtext()
            if (subSpellName == "Racial") then
                spellId = C_SpellBook.GetOverrideSpell(spellId)
                local spellName = GetSpellInfo(spellId)
                local isPassive = IsPassiveSpell(entryOffset, "player")
                if (spellName and not isPassive) then
					local cooldownTime = floor(GetSpellBaseCooldown(spellId) / 1000)
                    racialsSpells = racialsSpells .. "[" .. spellId .. "] = {cooldown = " .. cooldownTime .. ",	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = " .. playerRaceId .. ", race = \"".. playerRace .."\",	class = \"\",	type = 9}, --" .. spellName .. "(" .. playerRace .. ")|n"
                end
            end
        end
    end

	racialsSpells = racialsSpells .. "|n"
	dumpt(racialsSpells)
end

--fill the passed table with spells from talents and spellbook, affect only the active spec
function Details.FillTableWithPlayerSpells(completeListOfSpells)
	local GetItemStats = C_Item.GetItemStats
	local GetSpellInfo = GetSpellInfo or function(spellID)
		if not spellID then return nil end

		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if spellInfo then
			return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange,
					spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
		end
	end
	local GetSpellTabInfo = GetSpellTabInfo or (function(tabLine)
		if not tabLine then return nil end
		local skillLine = C_SpellBook.GetSpellBookSkillLineInfo(tabLine)
		if skillLine then
			return skillLine.name, skillLine.iconID, skillLine.itemIndexOffset,
			skillLine.numSpellBookItems, skillLine.isGuild, skillLine.specID
		end
	end)

	local GetSpellBookItemInfo = C_SpellBook and C_SpellBook.GetSpellBookItemType or GetSpellBookItemInfo
	local IsPassiveSpell = C_SpellBook and C_SpellBook.IsSpellBookItemPassive or IsPassiveSpell
	local GetNumSpellTabs = C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines or GetNumSpellTabs
	local spellBookPlayerEnum = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or "player"
	local HasPetSpells = C_SpellBook and C_SpellBook.HasPetSpells or HasPetSpells
	local GetOverrideSpell = C_Spell and  C_Spell.GetOverrideSpell or C_SpellBook.GetOverrideSpell
	local GetSpellBookItemName = C_SpellBook and C_SpellBook.GetSpellBookItemName or GetSpellBookItemName 
	local spellBookPetEnum = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet or "pet"

	local GetSpellCharges = GetSpellCharges or function(spellId)
		local chargesInfo = C_Spell.GetSpellCharges(spellId)
		if (chargesInfo) then
			return chargesInfo.currentCharges, chargesInfo.maxCharges, chargesInfo.cooldownStartTime, chargesInfo.cooldownDuration, chargesInfo.chargeModRate
		end
	end

    local specId, specName, _, specIconTexture = GetSpecializationInfo(GetSpecialization())
    local locPlayerRace, playerRace, playerRaceId = UnitRace("player")
    local generalIndex = Enum.SpellBookSkillLineIndex and Enum.SpellBookSkillLineIndex.General or CONST_SPELLBOOK_GENERAL_TABID
    local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(generalIndex) --CONST_SPELLBOOK_GENERAL_TABID

    if (not offset) then
        return completeListOfSpells
    end

    offset = offset + 1

	--get spells from the Spec spellbook
    for i = 1, GetNumSpellTabs() do --called "lines" in new v11 api
        local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(i)
		--print(tabName)
        --if (tabTexture == specIconTexture) then
            offset = offset + 1
            local tabEnd = offset + numSpells
            for entryOffset = offset, tabEnd - 1 do
                local spellType, spellId = GetSpellBookItemInfo(entryOffset, spellBookPlayerEnum)
                if (spellId) then
					--print(GetSpellInfo(spellId))
                    if (spellType == "SPELL" or spellType == 1) then
                        --print(tabName, tabTexture == specIconTexture, offset, tabEnd,spellType, spellId)
                        spellId = GetOverrideSpell(spellId)
                        local spellName = GetSpellInfo(spellId)
                        local bIsPassive = IsPassiveSpell(entryOffset, spellBookPlayerEnum)
                        if (spellName and not bIsPassive) then
                            completeListOfSpells[spellId] = true
                        end
                    end
                end
            end
        --end
    end

    --get class shared spells from the spell book
    local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(CONST_SPELLBOOK_CLASSSPELLS_TABID)
    offset = offset + 1
    local tabEnd = offset + numSpells
    for entryOffset = offset, tabEnd - 1 do
        local spellType, spellId = GetSpellBookItemInfo(entryOffset, spellBookPlayerEnum)
        if (spellId) then
            if (spellType == "SPELL" or spellType == 1) then
                spellId = GetOverrideSpell(spellId)
                local spellName = GetSpellInfo(spellId)
                local bIsPassive = IsPassiveSpell(entryOffset, spellBookPlayerEnum)

                if (spellName and not bIsPassive) then
                    completeListOfSpells[spellId] = true
                end
            end
        end
    end

    local getNumPetSpells = function()
        --'HasPetSpells' contradicts the name and return the amount of pet spells available instead of a boolean
        return HasPetSpells()
    end

    --get pet spells from the pet spellbook
    local numPetSpells = getNumPetSpells()
    if (numPetSpells) then
        for i = 1, numPetSpells do
            local spellName, _, unmaskedSpellId = GetSpellBookItemName(i, spellBookPetEnum)
            if (unmaskedSpellId) then
                unmaskedSpellId = GetOverrideSpell(unmaskedSpellId)
                local bIsPassive = IsPassiveSpell(i, spellBookPetEnum)
                if (spellName and not bIsPassive) then
                    completeListOfSpells[unmaskedSpellId] = true
                end
            end
        end
    end

    --dumpt(completeListOfSpells)
    return completeListOfSpells
end

function Details.SavePlayTimeOnClass()
	local className = select(2, UnitClass("player"))
	if (className) then
		--played time by  expansion
		local expansionLevel = GetExpansionLevel()

		local expansionTable = Details.class_time_played[expansionLevel]
		if (not expansionTable) then
			expansionTable = {}
			Details.class_time_played[expansionLevel] = expansionTable
		end

		local playedTime = expansionTable[className] or 0
		expansionTable[className] = playedTime + GetTime() - Details.GetStartupTime()
	end
end

function Details.GetPlayTimeOnClass()
	local className = select(2, UnitClass("player"))
	if (className) then
		--played time by  expansion
		local expansionLevel = GetExpansionLevel()

		local expansionTable = Details.class_time_played[expansionLevel]
		if (not expansionTable) then
			expansionTable = {}
			Details.class_time_played[expansionLevel] = expansionTable
		end

		local playedTime = expansionTable[className]
		if (playedTime) then
			playedTime = playedTime +(GetTime() - Details.GetStartupTime())
			return playedTime
		end
	end
	return 0
end

function Details.GetPlayTimeOnClassString()
    local playedTime = Details.GetPlayTimeOnClass()
    local days = floor(playedTime / 86400) .. " days"
    playedTime = playedTime % 86400
    local hours = floor(playedTime / 3600) .. " hours"
    playedTime = playedTime % 3600
    local minutes = floor(playedTime / 60) .. " minutes"

	local expansionLevel = GetExpansionLevel()
	local expansionName = _G["EXPANSION_NAME" .. GetExpansionLevel()]

    return "|cffffff00Time played this class(" .. expansionName .. "): " .. days .. " " .. hours .. " " .. minutes
end

hooksecurefunc("ChatFrame_DisplayTimePlayed", function()
	if (Details.played_class_time) then
		C_Timer.After(0, function()
			local expansionName = _G["EXPANSION_NAME" .. GetExpansionLevel()]
			for fontString in ChatFrame1.fontStringPool:EnumerateActive() do
				if (fontString:GetText() and fontString:GetText():find(expansionName)) then
					return
				end
			end

			local levelText = TIME_PLAYED_LEVEL and TIME_PLAYED_LEVEL:gsub("%%s", "") or ""
			for fontString in ChatFrame1.fontStringPool:EnumerateActive() do
				if (fontString:GetText() and fontString:GetText():find(levelText)) then
					print(Details.GetPlayTimeOnClassString() .. " \ncommand: /details playedclass")
					break
				end
			end
		end)
	end
end)

--game freeze prevention, there are people calling UpdateAddOnMemoryUsage() making the game client on the end user to freeze, this is bad, really bad.
--Details! replace the function call with one that do the same thing, but warns the player if the function freezes the client too many times.
--this feature is disabled by default, to enable it, type /run Details.check_stuttering = true and reload the game
local stutterCounter = 0
local bigStutterCounter = 0
local UpdateAddOnMemoryUsage_Original = _G.UpdateAddOnMemoryUsage
Details.UpdateAddOnMemoryUsage_Original = _G.UpdateAddOnMemoryUsage

Details.UpdateAddOnMemoryUsage_Custom = function()
	local currentTime = debugprofilestop()
	UpdateAddOnMemoryUsage_Original()
	local deltaTime = debugprofilestop() - currentTime

	if (deltaTime > 16) then
		local callStack = debugstack(2, 0, 4)
		--ignore if is coming from the micro menu tooltip
		if (callStack:find("MainMenuBarPerformanceBarFrame_OnEnter")) then
			return
		end

		if (deltaTime >= 500) then
			bigStutterCounter = bigStutterCounter + 1
			if (bigStutterCounter >= 6) then
				Details:Msg("an addon made your game freeze for more than a half second, use '/details perf' to know more.")
				bigStutterCounter = -10000 --make this msg appear only once
			end
		end

		stutterCounter = stutterCounter + 1
		local stutterDegree = 0
		if (stutterCounter > 60) then
			if (deltaTime < 48) then
				Details:Msg("some addon may be causing small framerate stuttering, use '/details perf' to know more.")
				stutterDegree = 1

			elseif (deltaTime <= 100) then
				Details:Msg("some addon may be causing framerate drops, use '/details perf' to know more.")
				stutterDegree = 2

			else
				Details:Msg("some addon might be causing performance issues, use '/details perf' to know more.")
				stutterDegree = 3
			end

			stutterCounter = -10000  --make this msg appear only once
		end

		Details.performanceData = {
			deltaTime = deltaTime,
			callStack = callStack,
			culpritFunc = "_G.UpdateAddOnMemoryUsage()",
			culpritDesc = "Calculates memory usage of addons",
		}
	end
end

Details.performanceData = {
	deltaTime = 0,
	callStack = "",
	culpritFunc = "",
	culpritDesc = "",
}

function Details:HandleRogueCombatSpecIconByGameVersion()
	local _, _, _, patchVersion = GetBuildInfo()
	if (patchVersion >= 70000) then --Legion
		--rogue combat is a rogue outlaw
		local rogueCombatCoords = Details.class_specs_coords[260]
		rogueCombatCoords[1] = 0
		rogueCombatCoords[2] = 64 / 512
		rogueCombatCoords[3] = 384 / 512
		rogueCombatCoords[4] = 448 / 512

		--new versions of the game has a different icon for assassination
		local rogueAssassinationCoords = Details.class_specs_coords[259]
		rogueAssassinationCoords[1] = 64 / 512
		rogueAssassinationCoords[2] = 128 / 512
		rogueAssassinationCoords[3] = 384 / 512
		rogueAssassinationCoords[4] = 448 / 512
	end
end

function CopyText(text) --[[GLOBAL]]
	if (not Details.CopyTextField) then
		Details.CopyTextField = CreateFrame("Frame", "DetailsCopyText", UIParent, "BackdropTemplate")
		Details.CopyTextField:SetHeight(14)
		Details.CopyTextField:SetWidth(120)
		Details.CopyTextField:SetPoint("center", UIParent, "center")
		Details.CopyTextField:SetBackdrop(backdrop)

		DetailsFramework:ApplyStandardBackdrop(Details.CopyTextField)

		tinsert(UISpecialFrames, "DetailsCopyText")

		Details.CopyTextField.textField = CreateFrame("editbox", nil, Details.CopyTextField, "BackdropTemplate")
		Details.CopyTextField.textField:SetPoint("topleft", Details.CopyTextField, "topleft")
		Details.CopyTextField.textField:SetAutoFocus(false)
		Details.CopyTextField.textField:SetFontObject("GameFontHighlightSmall")
		Details.CopyTextField.textField:SetAllPoints()
		Details.CopyTextField.textField:EnableMouse(true)

		Details.CopyTextField.textField:SetScript("OnEnterPressed", function()
			Details.CopyTextField.textField:ClearFocus()
			Details.CopyTextField:Hide()
		end)

		Details.CopyTextField.textField:SetScript("OnEscapePressed", function()
			Details.CopyTextField.textField:ClearFocus()
			Details.CopyTextField:Hide()
		end)

		Details.CopyTextField.textField:SetScript("OnChar", function()
			Details.CopyTextField.textField:ClearFocus()
			Details.CopyTextField:Hide()
		end)
	end

	C_Timer.After(0.1, function()
		Details.CopyTextField:Show()
		Details.CopyTextField.textField:SetFocus()
		Details.CopyTextField.textField:SetText(text)
		Details.CopyTextField.textField:HighlightText()
	end)
end


-------------------------------------------------------------------------
--> cache maintenance

function Details222.Cache.DoMaintenance()
	local currentTime = time()
	local delay = (86400 * 2) --2 days

	if (currentTime > Details.latest_spell_pool_access + delay) then
		local spellIdPoolBackup = DetailsFramework.table.copy({}, Details.spell_pool)

		Details:Destroy(Details.spell_pool)

		--preserve ignored spells spellId
		for spellId in pairs(Details.spellid_ignored) do
			Details.spell_pool[spellId] = spellIdPoolBackup[spellId]
		end

		Details.latest_spell_pool_access = currentTime
		Details:Destroy(spellIdPoolBackup)
	end

	if (currentTime > Details.latest_npcid_pool_access + delay) then
		local npcIdPoolBackup = DetailsFramework.table.copy({}, Details.npcid_pool)

		Details:Destroy(Details.npcid_pool)

		--preserve ignored npcs npcId
		for npcId in pairs(Details.npcid_ignored) do
			Details.npcid_pool[npcId] = npcIdPoolBackup[npcId]
		end
		Details.latest_npcid_pool_access = currentTime
		Details:Destroy(npcIdPoolBackup)
	end

	if (currentTime > Details.latest_encounter_spell_pool_access + delay) then
		Details:Destroy(Details.encounter_spell_pool)
		Details.latest_encounter_spell_pool_access = currentTime
	end

	if (Details.boss_mods_timers and Details.boss_mods_timers.latest_boss_mods_access) then
		if (currentTime > Details.boss_mods_timers.latest_boss_mods_access + delay) then
			Details:Destroy(Details.boss_mods_timers.encounter_timers_bw)
			Details:Destroy(Details.boss_mods_timers.encounter_timers_dbm)
			Details.boss_mods_timers.latest_boss_mods_access = currentTime
		end
	end

	--latest_shield_spellid_cache_access
	--shield_spellid_cache
end