
local Details = 		_G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local _
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework

--[[global]] DETAILS_TOTALS_ONLYGROUP = true
--[[global]] DETAILS_SEGMENTID_OVERALL = -1
--[[global]] DETAILS_SEGMENTID_CURRENT = 0

--[[global]] DETAILS_COMBAT_AMOUNT_CONTAINERS = 4

--enum segments type
--[[global]] DETAILS_SEGMENTTYPE_GENERIC = 0

--[[global]] DETAILS_SEGMENTTYPE_OVERALL = 1

--[[global]] DETAILS_SEGMENTTYPE_DUNGEON_TRASH = 5
--[[global]] DETAILS_SEGMENTTYPE_DUNGEON_BOSS = 6

--[[global]] DETAILS_SEGMENTTYPE_RAID_TRASH = 7
--[[global]] DETAILS_SEGMENTTYPE_RAID_BOSS = 8

--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON = 100
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_GENERIC = 10
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH = 11
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL = 12
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASHOVERALL = 13 --not in use at the moment
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS = 14
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH = 15
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE = 16

--[[global]] DETAILS_SEGMENTTYPE_PVP_ARENA = 20
--[[global]] DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND = 21

--[[global]] DETAILS_SEGMENTTYPE_EVENT_VALENTINEDAY = 30

--[[global]] DETAILS_SEGMENTTYPE_TRAININGDUMMY = 40

local segmentTypeToString = {
	[DETAILS_SEGMENTTYPE_GENERIC] = "Generic",
	[DETAILS_SEGMENTTYPE_OVERALL] = "Overall",
	[DETAILS_SEGMENTTYPE_DUNGEON_TRASH] = "DungeonTrash",
	[DETAILS_SEGMENTTYPE_DUNGEON_BOSS] = "DungeonBoss",
	[DETAILS_SEGMENTTYPE_RAID_TRASH] = "RaidTrash",
	[DETAILS_SEGMENTTYPE_RAID_BOSS] = "RaidBoss",
	[DETAILS_SEGMENTTYPE_MYTHICDUNGEON] = "Category MythicDungeon",
	[DETAILS_SEGMENTTYPE_MYTHICDUNGEON_GENERIC] = "MythicDungeonGeneric _GENERIC",
	[DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH] = "MythicDungeonTrash _TRASH",
	[DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL] = "MythicDungeonOverall",
	[DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASHOVERALL] = "MythicDungeonTrashOverall TRASHOVERALL",
	[DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS] = "MythicDungeonBoss _BOSS",
	[DETAILS_SEGMENTTYPE_PVP_ARENA] = "PvPArena",
	[DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND] = "PvPBattleground",
	[DETAILS_SEGMENTTYPE_EVENT_VALENTINEDAY] = "EventValentineDay",
	[DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH] = "MythicDungeonBossTrash _BOSSTRASH",
	[DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE] = "MythicDungeonBossWipe _BOSSWIPE",
}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers
	local ipairs = ipairs -- lua local
	local pairs = pairs -- lua local
	local bitBand = bit.band -- lua local
	local date = date -- lua local
	local tremove = table.remove -- lua local
	local rawget = rawget
	local max = math.max
	local floor = math.floor
	local GetTime = GetTime

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants

	local classCombat 	=	Details.combate
	local classActorContainer = Details.container_combatentes
	local class_type_dano 	= Details.atributos.dano
	local class_type_cura		= Details.atributos.cura
	local class_type_e_energy 	= Details.atributos.e_energy
	local class_type_misc 	= Details.atributos.misc

	local classTypeDamage = Details.atributos.dano
	local classTypeHeal = Details.atributos.cura
	local classTypeResource = Details.atributos.e_energy
	local classTypeUtility = Details.atributos.misc

	local REACTION_HOSTILE =	0x00000040
	local CONTROL_PLAYER =		0x00000100

	--local _tempo = time()
	local _tempo = GetTime()

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--api functions

	--combat (container type, actor name)
	Details.call_combate = function(self, classType, actorName)
		local container = self[classType]
		local index_mapa = container._NameIndexTable[actorName]
		local actor = container._ActorTable[index_mapa]
		return actor
	end
	classCombat.__call = Details.call_combate

	---get the unique combat identifier
	---@param self combat
	---@return number
	function classCombat:GetCombatUID()
		return self.combat_counter
	end

	--get the start date and end date
	function classCombat:GetDate()
		return self.data_inicio, self.data_fim
	end

	---set the combat date
	---@param started string?
	---@param ended string?
	function classCombat:SetDate(started, ended)
		if (started and type(started) == "string") then
			self.data_inicio = started
		end
		if (ended and type(ended) == "string") then
			self.data_fim = ended
		end
	end

	---Sets the date to the current time.
	---@param bSetStartDate boolean? Whether to set the start date.
	---@param bSetEndDate boolean? Whether to set the end date.
	function classCombat:SetDateToNow(bSetStartDate, bSetEndDate)
		if (bSetStartDate) then
			self.data_inicio = date("%H:%M:%S")
		end
		if (bSetEndDate) then
			self.data_fim = date("%H:%M:%S")
		end
	end

	---return a table representing a chart data
	---@param name string
	---@return number[]
	function classCombat:GetTimeData(name)
		if (self.TimeData) then
			return self.TimeData[name]
		end
		return {max_value = 0}
	end

	---erase a time data if exists
	---@param name string
	function classCombat:EraseTimeData(name)
		if (self.TimeData[name]) then
			self.TimeData[name] = nil
			return true
		end
		return false
	end

	function classCombat:GetContainer(attribute)
		return self [attribute]
	end

	function classCombat:GetRoster()
		return self.raid_roster
	end

	function classCombat:GetInstanceType()
		return rawget(self, "instance_type")
	end

	function classCombat:IsTrash()
		return rawget(self, "is_trash")
	end

	function classCombat:GetDifficulty()
		return self.is_boss and self.is_boss.diff
	end

	function classCombat:GetEncounterCleuID()
		return self.is_boss and self.is_boss.id
	end

	---@param self combat
	---@return bossinfo bossInfo
	function classCombat:GetBossInfo()
		return self.is_boss
	end

	function classCombat:GetPhases()
		return self.PhaseData
	end

	function classCombat:GetPvPInfo()
		return self.is_pvp
	end

	function classCombat:GetMythicDungeonInfo()
		return self.is_mythic_dungeon
	end

	---return if the combat is a mythic dungeon segment and the run id
	---@return boolean
	---@return number
	function classCombat:IsMythicDungeon()
		local bIsMythicPlusSegment = self.is_mythic_dungeon_segment
		local runId = self.is_mythic_dungeon_run_id
		return bIsMythicPlusSegment, runId
	end

	function classCombat:IsMythicDungeonOverall()
		return self.is_mythic_dungeon and self.is_mythic_dungeon.OverallSegment
	end

	function classCombat:GetArenaInfo()
		return self.is_arena
	end

	function classCombat:GetDeaths()
		return self.last_events_tables
	end

	function classCombat:GetPlayerDeaths(deadPlayerName)
		local allDeaths = self:GetDeaths()
		local deaths = {}

		for i = 1, #allDeaths do
			local thisDeath = allDeaths[i]
			local thisPlayerName = thisDeath[3]
			if (deadPlayerName == thisPlayerName) then
				deaths[#deaths+1] = thisDeath
			end
		end

		return deaths
	end

	---Return the encounter name if any
	---@param self combat
	---@return string|number
	function classCombat:GetEncounterName()
		return self.EncounterName or (self.is_boss and self.is_boss.name)
	end

	function classCombat:GetBossImage()
		---@type details_encounterinfo
		local encounterInfo = Details:GetEncounterInfo(self:GetEncounterName())
		if (encounterInfo) then
			return encounterInfo.creatureIcon
		end

		---@type bossinfo
		local bossInfo = self:GetBossInfo()
		if (bossInfo) then
			return bossInfo.bossimage
		end

		return self.bossIcon or ""
	end

	function classCombat:GetCombatId()
		return self.combat_id
	end

	function classCombat:GetCombatNumber()
		return self.combat_counter
	end

	function classCombat:GetAlteranatePower()
		return self.alternate_power
	end

	---return the amount of casts of a spells from an actor
	---@param self combat
	---@param actorName string
	---@param spellName string
	---@return number
	function classCombat:GetSpellCastAmount(actorName, spellName)
		return self.amountCasts[actorName] and self.amountCasts[actorName][spellName] or 0
	end

	---return the cast amount table
	---@param self combat
	---@param actorName string|nil
	---@return table
	function classCombat:GetSpellCastTable(actorName)
		if (actorName) then
			return self.amountCasts[actorName] or {}
		else
			return self.amountCasts
		end
	end

	---delete an actor from the spell casts amount
	---@param self combat
	---@param actorName string
	function classCombat:RemoveActorFromSpellCastTable(actorName)
		self.amountCasts[actorName] = nil
	end

	---return the uptime of a buff from an actor
	---@param actorName string
	---@param spellId number
	---@param auraType string|nil if nil get 'buff'
	---@return number
	function classCombat:GetSpellUptime(actorName, spellId, auraType)
		---@type actorcontainer
		local utilityContainer = self:GetContainer(DETAILS_ATTRIBUTE_MISC)
		---@type actor
		local actorObject = utilityContainer:GetActor(actorName)
		if (actorObject) then
			if (auraType) then
				---@type spellcontainer
				local buffUptimeContainer = actorObject:GetSpellContainer(auraType)
				if (buffUptimeContainer) then
					---@type spelltable
					local spellTable = buffUptimeContainer:GetSpell(spellId)
					if (spellTable) then
						return spellTable.uptime or 0
					end
				end
			else
				do --if not auraType passed, attempt to get the uptime from debuffs first, if it fails, get from buffs
					---@type spellcontainer
					local debuffContainer = actorObject:GetSpellContainer("debuff")
					if (debuffContainer) then
						---@type spelltable
						local spellTable = debuffContainer:GetSpell(spellId)
						if (spellTable) then
							return spellTable.uptime or 0
						end
					end
				end
				do
					---@type spellcontainer
					local buffContainer = actorObject:GetSpellContainer("buff")
					if (buffContainer) then
						---@type spelltable
						local spellTable = buffContainer:GetSpell(spellId)
						if (spellTable) then
							return spellTable.uptime or 0
						end
					end
				end
			end
		end
		return 0
	end

	---Retrieves the slot ID of the current combat segment within the combat segments table.
	---@return number The slot ID of the current combat segment.
	function classCombat:GetSegmentSlotId()
		local segmentsTable = Details:GetCombatSegments()
		for i = 1, #segmentsTable do
			if (segmentsTable[i] == self) then
				return i
			end
		end

		if (Details:GetCurrentCombat() == self) then
			return DETAILS_SEGMENTID_CURRENT
		else
			return DETAILS_SEGMENTID_OVERALL
		end
	end

	---return the atlasinfo for the combat icon
	---@param self combat
	---@return df_atlasinfo segmentIcon
	---@return df_atlasinfo? categoryIcon
	function classCombat:GetCombatIcon()
		local textureAtlas = Details:GetTextureAtlasTable()

		if (not self) then
			return textureAtlas["segment-icon-regular"]
		end

		local combatType = self:GetCombatType()

		if (combatType == DETAILS_SEGMENTTYPE_OVERALL) then
			return textureAtlas["segment-icon-overall"]

		elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON) then
			return textureAtlas["segment-icon-mythicplus"]

		elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
			return textureAtlas["segment-icon-mythicplus-overall"], textureAtlas["segment-icon-mythicplus"]

		elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH) then
			return textureAtlas["segment-icon-broom"], textureAtlas["segment-icon-mythicplus"]

		elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE) then
			return textureAtlas["segment-icon-skull"], textureAtlas["segment-icon-mythicplus"]

		elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS) then
			return textureAtlas["segment-icon-skull"], textureAtlas["segment-icon-mythicplus"]

		elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH) then
			return textureAtlas["segment-icon-broom"], textureAtlas["segment-icon-mythicplus"]

		elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_GENERIC) then
			return textureAtlas["segment-icon-mythicplus"]

		elseif (combatType == DETAILS_SEGMENTTYPE_TRAININGDUMMY) then
			return textureAtlas["segment-icon-training-dummy-zoom"]

		elseif (combatType == DETAILS_SEGMENTTYPE_PVP_ARENA) then
			return textureAtlas["segment-icon-arena"]

		elseif (combatType == DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND) then
			return textureAtlas["segment-icon-arena"]

		elseif (combatType == DETAILS_SEGMENTTYPE_RAID_TRASH) then
			return textureAtlas["segment-icon-broom"]

		elseif (combatType == DETAILS_SEGMENTTYPE_RAID_BOSS) then
			local bossInfo = self:GetBossInfo()
			local difficulty = bossInfo.diff

			if (difficulty == 16) then --mythic
				return textureAtlas["segment-icon-skull"], textureAtlas["segment-icon-mythicraid"]

			elseif (difficulty == 15) then --heroic
				return textureAtlas["segment-icon-skull"], textureAtlas["segment-icon-heroicraid"]

			elseif (difficulty == 14) then --heroic
				return textureAtlas["segment-icon-skull"], textureAtlas["segment-icon-normalraid"]
			end

			return textureAtlas["segment-icon-skull"]

		elseif (combatType == DETAILS_SEGMENTTYPE_EVENT_VALENTINEDAY) then
			return textureAtlas["segment-icon-love-is-in-the-air"]

		elseif (combatType == DETAILS_SEGMENTTYPE_DUNGEON_BOSS) then
			return textureAtlas["segment-icon-skull"]
		end

		return textureAtlas["segment-icon-regular"]
	end

	local partyColor = {170/255, 167/255, 255/255}
	local loveIsInTheAirColor = {1, 0.411765, 0.705882, 1}
	local bossKillColor = "lime"
	local bossWipeColor = "orange"
	local mythicDungeonBossColor = {170/255, 167/255, 255/255, 1}
	local mythicDungeonBossWipeColor = {0.803922, 0.360784, 0.360784, 1}
	local mythicDungeonBossColor2 = {210/255, 200/255, 255/255, 1}

	function classCombat:GetCombatName(bOnlyName, bTryFind)
		if (not self) then
			return Loc["STRING_UNKNOW"]
		end

		local r, g, b
		local combatType, categoryType = self:GetCombatType()

		if (combatType == DETAILS_SEGMENTTYPE_OVERALL) then
			return Loc["STRING_SEGMENT_OVERALL"]
		end

		if (categoryType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON) then
			local mythicDungeonInfo = self:GetMythicDungeonInfo()
			local isMythicOverallSegment, segmentID, mythicLevel, EJID, mapID, zoneName, encounterID, encounterName, startedAt, endedAt, runID = Details:UnpackMythicDungeonInfo(mythicDungeonInfo)

			if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
				if (bOnlyName) then
					return mythicDungeonInfo.SegmentName, unpack(partyColor)
				else
					local overallIconString = detailsFramework:CreateAtlasString(Details.TextureAtlas["segment-icon-mythicplus-overall"])
					return overallIconString .. mythicDungeonInfo.SegmentName .. " (" .. Loc["STRING_SEGMENTS_LIST_OVERALL"] .. ")", unpack(partyColor)
				end
			end

			if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH) then --"Trash #" .. (Details.MythicPlus.SegmentID or 0)
				return mythicDungeonInfo.SegmentName
			end

			if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS) then
				return mythicDungeonInfo.SegmentName, detailsFramework:ParseColors(mythicDungeonBossColor)
			end

			if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE) then
				return mythicDungeonInfo.SegmentName, detailsFramework:ParseColors(mythicDungeonBossWipeColor)
			end

			if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH) then
				return mythicDungeonInfo.SegmentName, unpack(partyColor)
			end

			if (mythicDungeonInfo.SegmentName) then
				if (bOnlyName) then
					return mythicDungeonInfo.SegmentName, unpack(partyColor)
				else
					return mythicDungeonInfo.SegmentName .. " +" .. mythicLevel, unpack(partyColor)
				end
			end

			return "--x--x--"
		end

		if (combatType == DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND) then
			return self.is_pvp.name

		elseif (combatType == DETAILS_SEGMENTTYPE_PVP_ARENA) then
			return self.is_arena.name

		elseif (combatType == DETAILS_SEGMENTTYPE_EVENT_VALENTINEDAY) then
			local bossInfo = self:GetBossInfo()
			r, g, b = detailsFramework:ParseColors(loveIsInTheAirColor)
			return bossInfo.name, r, g, b, 1

		elseif (combatType == DETAILS_SEGMENTTYPE_DUNGEON_BOSS) then
			local bossInfo = self:GetBossInfo()
			local bIsKill = bossInfo.killed
			if (bOnlyName) then
				return bossInfo.name, detailsFramework:ParseColors(bIsKill and bossKillColor or bossWipeColor)
			else
				local segmentId = self:GetSegmentSlotId()
				return bossInfo.name .." (#" .. segmentId .. ")", detailsFramework:ParseColors(bIsKill and bossKillColor or bossWipeColor)
			end

		elseif (combatType == DETAILS_SEGMENTTYPE_RAID_BOSS) then
			local bossInfo = self:GetBossInfo()
			if (bossInfo and bossInfo.name) then
				--bossKillColor
				local bIsKill = bossInfo.killed
				local formattedTime = self:GetFormattedCombatTime()
				local tryNumber = self:GetTryNumber()
				if (tryNumber) then
					if (bOnlyName) then
						return bossInfo.name .." (#" .. tryNumber .. ")", detailsFramework:ParseColors(bIsKill and bossKillColor or bossWipeColor)
					else
						return bossInfo.name .." (#" .. tryNumber .. " " .. formattedTime .. ")", detailsFramework:ParseColors(bIsKill and bossKillColor or bossWipeColor)
					end
				else
					local segmentId = self:GetSegmentSlotId()
					return bossInfo.name .." (#" .. segmentId .. ")", detailsFramework:ParseColors(bIsKill and bossKillColor or bossWipeColor)
				end
			end
		end

		local bossInfo = self:GetBossInfo()
		if (bossInfo and (bossInfo.encounter or bossInfo.name)) then
			return bossInfo.encounter or bossInfo.name
		end

		if (rawget(self, "is_trash")) then
			return Loc ["STRING_SEGMENT_TRASH"]
		end

		if (self.enemy) then
			return self.enemy
		end

		if (bTryFind) then
			local newName = self:FindEnemyName()
			if (newName) then
				self.enemy = newName
				return newName
			end
		end

		local segmentId = self:GetSegmentSlotId()
		return Loc["STRING_FIGHTNUMBER"] .. segmentId
	end

	---debug function to print the combat name
	---@param self combat
	---@return string
	function classCombat:GetCombatTypeName()
		local combatType = self:GetCombatType()
		return segmentTypeToString[combatType] or ("no type found: " .. combatType)
	end

	---@param self combat
	---@return string
	function classCombat:FindEnemyName()
		local zoneName, instanceType = GetInstanceInfo()
		local bIsInInstance = IsInInstance() --garrison returns party as instance type
		if ((instanceType == "party" or instanceType == "raid") and bIsInInstance) then
			if (instanceType == "party") then
				if (Details:GetBossNames(Details.zone_id)) then
					return Loc ["STRING_SEGMENT_TRASH"]
				end
			else
				return Loc ["STRING_SEGMENT_TRASH"]
			end
		end

		local playerActorObject = self:GetActor(DETAILS_ATTRIBUTE_DAMAGE, Details.playername)
		---@cast playerActorObject actordamage

		--search for an enemy name in the player targets
		if (playerActorObject) then
			local targets = playerActorObject.targets
			--check if the player has at least 1 target, this can happen when the player got hit by enemies but didn't hit back
			if (next(targets)) then
				--add the targets to an array, this allow to get the enemy with most damage taken by the player
				---@type table<actorname, number>[]
				local targetsArray = {}
				for targetName, amount in pairs(targets) do
					table.insert(targetsArray, {targetName, amount})
				end

				table.sort(targetsArray, Details.Sort2)

				local targetName = targetsArray[1][1]
				if (targetName) then
					return targetName
				end
			end

			--search for an enemy name in the player damage taken
			local damageTakenFrom = playerActorObject.damage_from
			if (next(damageTakenFrom)) then
				---@type table<actorname, number>[]
				local damageTakenArray = {}
				for damagerName in pairs(damageTakenFrom) do
					--get the actor object for the damager to know how much damage was done to the player
					---@type actordamage
					local damagerActor = self:GetActor(DETAILS_ATTRIBUTE_DAMAGE, damagerName)
					if (damagerActor) then
						table.insert(damageTakenArray, {damagerName, damagerActor.targets[playerActorObject:Name()] or 0})
					end
				end

				table.sort(damageTakenArray, Details.Sort2)

				local targetName = damageTakenArray[1][1]
				if (targetName) then
					return targetName
				end
			end
		end

		--search for an enemy name in the group members targets
		---@type actorcontainer
		local actorContainer = self:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		local actorTable = actorContainer:GetActorTable()
		for i = 1, #actorTable do
			local actorObject = actorTable[i]
			--check if this actor was a group member during the combat
			if (actorObject:IsGroupPlayer()) then
				local targets = actorObject.targets
				if (next(targets)) then
					---@type table<actorname, number>[]
					local targetsArray = {}
					for targetName, amount in pairs(targets) do
						table.insert(targetsArray, {targetName, amount})
					end

					table.sort(targetsArray, Details.Sort2)

					local targetName = targetsArray[1][1]
					if (targetName) then
						return targetName
					end
				end
			end
		end

		return Details222.Unknown
	end

	function classCombat:GetCombatType()
		--mythic dungeon
		local bIsMythicDungeon = self:IsMythicDungeon()
		if (bIsMythicDungeon) then
			local mythicDungeonInfo = self:GetMythicDungeonInfo()

			if (mythicDungeonInfo.SegmentType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH) then
				return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH, DETAILS_SEGMENTTYPE_MYTHICDUNGEON

			elseif (mythicDungeonInfo.SegmentType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
				return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL, DETAILS_SEGMENTTYPE_MYTHICDUNGEON

			elseif (mythicDungeonInfo.SegmentType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS) then
				return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS, DETAILS_SEGMENTTYPE_MYTHICDUNGEON

			elseif (mythicDungeonInfo.SegmentType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE) then
				return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE, DETAILS_SEGMENTTYPE_MYTHICDUNGEON

			elseif (mythicDungeonInfo.SegmentType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH) then
				return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH, DETAILS_SEGMENTTYPE_MYTHICDUNGEON
			end

			return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_GENERIC, DETAILS_SEGMENTTYPE_MYTHICDUNGEON
		end

		if (self.training_dummy) then
			return DETAILS_SEGMENTTYPE_TRAININGDUMMY
		end

		--arena
		local arenaInfo = self.is_arena
		if (arenaInfo) then
			return DETAILS_SEGMENTTYPE_PVP_ARENA
		end

		--battleground
		local battlegroundInfo = self.is_pvp
		if (battlegroundInfo) then
			return DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND
		end

		--dungeon or raid
		local instanceType = self.instance_type

		if (instanceType == "party") then
			local bossInfo =  self:GetBossInfo()

			if (bossInfo) then
				if (bossInfo.mapid == 33 and bossInfo.diff_string == "Event" and bossInfo.id == 2879) then --Shadowfang Keep | The Crown Chemical Co.
					return DETAILS_SEGMENTTYPE_EVENT_VALENTINEDAY
				else
					return DETAILS_SEGMENTTYPE_DUNGEON_BOSS
				end
			else
				return DETAILS_SEGMENTTYPE_DUNGEON_TRASH
			end

		elseif (instanceType == "raid") then
			local bossEncounter =  self.is_boss
			if (bossEncounter) then
				return DETAILS_SEGMENTTYPE_RAID_BOSS
			else
				return DETAILS_SEGMENTTYPE_RAID_TRASH
			end
		end

		--overall data
		if (self == Details.tabela_overall) then
			return DETAILS_SEGMENTTYPE_OVERALL
		end

		return DETAILS_SEGMENTTYPE_GENERIC
	end

	function Details:UnpackMythicDungeonInfo(t)
		return t.OverallSegment, t.SegmentID, t.Level, t.EJID, t.MapID, t.ZoneName, t.EncounterID, t.EncounterName, t.StartedAt, t.EndedAt, t.RunID
	end

	--return a numeric table with all actors on the specific containter
	function classCombat:GetActorList(container)
		return self [container]._ActorTable
	end

	---return an actor object for the given container and actor name
	---@param container number
	---@param name string
	---@return actor|nil
	function classCombat:GetActor(container, name)
		local index = self[container] and self[container]._NameIndexTable[name]
		if (index) then
			return self[container]._ActorTable[index]
		end
		return nil
	end

	---Return a key|value table containing the spellId as key and a table with information about the trinket as value
	---@param self combat
	---@param playerName string
	---@return table<spellid, trinketprocdata>
	function classCombat:GetTrinketProcsForPlayer(playerName)
		local trinketProcs = self.trinketProcs
		return trinketProcs[playerName] or {}
	end

	---return a string with minute and seconds of the combat time separated by a colon
	---@return string
	function classCombat:GetFormattedCombatTime()
		local combatTime = self:GetCombatTime()
		local minute, second = floor(combatTime / 60), floor(combatTime % 60)

		local minuteString = tostring(minute)
		local secondString = tostring(second)

		if (minute < 10) then
			minuteString = "0" .. minuteString
		end

		if (second < 10) then
			secondString = "0" .. secondString
		end

		return minuteString .. ":" .. secondString
	end

	---return two values, one for minute and another for seconds
	---@return number, number
	function classCombat:GetMSTime()
		local combatTime = self:GetCombatTime()
		local minute, second = floor(combatTime / 60), floor(combatTime % 60)
		return minute, second
	end

	---return the amount of time the combat has elapsed
	---@return number
	function classCombat:GetCombatTime()
		if (self.end_time) then
			return max(self.end_time - self.start_time, 0.1)
		elseif (self.start_time and Details.in_combat and self ~= Details.tabela_overall) then
			return max(GetTime() - self.start_time, 0.1)
		else
			return 0.1
		end
	end

	---return the amount of time a mythic plus run has elapsed, if there's no information about the run time, it'll return the combat time
	---@param self combat
	---@return number
	function classCombat:GetRunTime()
		return self.run_time or self:GetCombatTime()
	end

	---return the amount of time a mythic plus run has elapsed, if there's no information about the run time, return nil
	---@param self combat
	---@return number?
	function classCombat:GetRunTimeNoDefault()
		return self.run_time
	end

	---Return the gametime when the combat started
	---Game Time is the result value from the function GetTime()
	---@param self combat
	---@return gametime
	function classCombat:GetStartTime()
		return self.start_time
	end

	---Set the gametime when the combat started
	---Game Time is the result value from the function GetTime()
	---@param self combat
	---@param thisTime gametime
	function classCombat:SetStartTime(thisTime)
		self.start_time = thisTime
	end

	---Return the gametime when the combat ended
	---Game Time is the result value from the function GetTime()
	---@param self combat
	---@return gametime
	function classCombat:GetEndTime()
		return self.end_time
	end

	---Set the gametime when the combat ended
	---Game Time is the result value from the function GetTime()
	---@param self combat
	---@param thisTime gametime
	function classCombat:SetEndTime(thisTime)
		self.end_time = thisTime
	end

	function classCombat:seta_tempo_decorrido() --deprecated march 2024
		--self.end_time = _tempo
		self.end_time = GetTime()
	end

	---Return how many attempts were made for this boss
	---@param self combat
	---@return number|nil
	function classCombat:GetTryNumber()
		---@type bossinfo
		local bossInfo = self:GetBossInfo()
		if (bossInfo) then
			return bossInfo.try_number
		end
	end

	---Return the percentage of the boss health when the combat ended
	---1 = 100% 0.5 = 50%
	---@param self combat
	---@return number
	function classCombat:GetBossHealth()
		return self.boss_hp
	end

	---Return the percentage of the boss as a string, includes a zero on the left side if the number is less than 10
	---@param self combat
	---@return string
	function classCombat:GetBossHealthString()
		local bossHealth = self:GetBossHealth()
		if (bossHealth) then
			bossHealth = math.floor(bossHealth * 100)
			local bossHealthString = tostring(bossHealth)
			if (bossHealth < 10) then
				bossHealthString = "0" .. bossHealthString
			end
			return bossHealthString
		end
		return "00"
	end

	---Get the boss name
	---@param self combat
	---@return string?
	function classCombat:GetBossName()
		return self.bossName
	end

	---Return the current phase of the combat or which phase the combat was when it ended
	---@param self combat
	---@return number
	function classCombat:GetCurrentPhase()
		local phaseData = self.PhaseData
		local lastPhase = #phaseData
		--the phase data has on its first index the ID of the phase and on the second the time when it started
		local lastPhaseId = phaseData[lastPhase][1]
		return lastPhaseId
	end

	---copy deaths from combat2 into combat1
	---if bMythicPlus is true it'll check if the death has mythic plus death time and use it instead of the normal death time
	---@param combat1 combat
	---@param combat2 combat
	---@param bMythicPlus boolean
	function classCombat.CopyDeathsFrom(combat1, combat2, bMythicPlus)
		local deathsTable = combat1:GetDeaths()
		local deathsToCopy = combat2:GetDeaths()

		for i = 1, #deathsToCopy do
			local thisDeath = DetailsFramework.table.copy({}, deathsToCopy[i])

			if (bMythicPlus and thisDeath.mythic_plus) then
				thisDeath[6] = thisDeath.mythic_plus_dead_at_string
				thisDeath.dead_at = thisDeath.mythic_plus_dead_at
			end

			deathsTable[#deathsTable+1] = thisDeath
		end
	end

	--return the total of a specific attribute
	local power_table = {0, 1, 3, 6, 0, "alternatepower"}

	---return the total of a specific attribute, example: total damage, total healing, total resources, etc
	---@param attribute number
	---@param subAttribute number
	---@param onlyGroup boolean?
	---@return number
	function classCombat:GetTotal(attribute, subAttribute, onlyGroup)
		if (attribute == 1 or attribute == 2) then
			if (onlyGroup) then
				return self.totals_grupo [attribute]
			else
				return self.totals [attribute]
			end

		elseif (attribute == 3) then
			if (subAttribute == 5) then --resources
				return self.totals.resources or 0
			end
			if (onlyGroup) then
				return self.totals_grupo [attribute] [power_table [subAttribute]]
			else
				return self.totals [attribute] [power_table [subAttribute]]
			end

		elseif (attribute == 4) then
			local subName = Details:GetInternalSubAttributeName (attribute, subAttribute)
			if (onlyGroup) then
				return self.totals_grupo [attribute] [subName]
			else
				return self.totals [attribute] [subName]
			end
		end

		return 0
	end

	---create an alternate power table for the given actor
	---@param actorName string
	---@return alternatepowertable
	function classCombat:CreateAlternatePowerTable(actorName)
		---@type alternatepowertable
		local alternatePowerTable = {last = 0, total = 0}
		self.alternate_power[actorName] = alternatePowerTable
		return alternatePowerTable
	end

	---transfer talents from Details talent cache to the combat combat
	---@param self combat
	function classCombat:StoreTalents()
		local talentStorage = Details.cached_talents
		local damageContainer = self:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		for idx, actorObject in damageContainer:ListActors() do
			local thisActorTalents = talentStorage[actorObject.serial]
			if (thisActorTalents) then
				local actorName = actorObject:Name()
				self.playerTalents[actorName] = thisActorTalents
			end
		end
	end

	--delete an actor from the combat ~delete ~erase ~remove
	function classCombat:DeleteActor(attribute, actorName, removeDamageTaken, cannotRemap)
		local container = self[attribute]
		if (container) then

			local actorTable = container._ActorTable

			--store the index it was found
			local indexToDelete

			--get the object for the deleted actor
			local deletedActor = self(attribute, actorName)
			if (not deletedActor) then
				return
			else
				for i = 1, #actorTable do
					local actor = actorTable[i]
					if (actor.nome == actorName) then
						--print("Details: found the actor: ", actorName, actor.nome, i)
						indexToDelete = i
						break
					end
				end
			end

			for i = 1, #actorTable do
				--is this not the actor we want to remove?
				if (i ~= indexToDelete) then

					local actor = actorTable[i]
					if (not actor.isTank) then
						--get the damage dealt and remove
						local damageDoneToRemovedActor = (actor.targets[actorName]) or 0
						actor.targets[actorName] = nil
						actor.total = actor.total - damageDoneToRemovedActor
						actor.total_without_pet = actor.total_without_pet - damageDoneToRemovedActor

						--damage taken
						if (removeDamageTaken) then
							local hadDamageTaken = actor.damage_from[actorName]
							if (hadDamageTaken) then
								--query the deleted actor to know how much damage it applied to this actor
								local damageDoneToActor = (deletedActor.targets[actor.nome]) or 0
								actor.damage_taken = actor.damage_taken - damageDoneToActor
							end
						end

						--spells
						local spellsTable = actor.spells._ActorTable
						for spellId, spellTable in pairs(spellsTable) do
							local damageDoneToRemovedActor = (spellTable.targets[actorName]) or 0
							spellTable.targets[actorName] = nil
							spellTable.total = spellTable.total - damageDoneToRemovedActor
						end
					end
				end
			end

			if (indexToDelete) then
				local actorToDelete = self(attribute, actorName)
				local actorToDelete2 = container._ActorTable[indexToDelete]

				if (actorToDelete ~= actorToDelete2) then
					Details:Msg("error 0xDE8745")
				end

				local index = container._NameIndexTable[actorName]
				if (indexToDelete ~= index) then
					Details:Msg("error 0xDE8751")
				end

				--remove actor
				tremove(container._ActorTable, index)

				--remap
				if (not cannotRemap) then
					container:Remap()
				end
				return true
			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--internals

function classCombat:CreateNewCombatTable()
	return classCombat:NovaTabela()
end

local getBossName = function()
	if (UnitExists("boss1") and Details.in_combat) then
		local bossName = UnitName("boss1")
		if (bossName) then
			Details:GetCurrentCombat().bossName = bossName
		end
	end
end

---class constructor
---@param bTimeStarted boolean if true set the start time to now with GetTime
---@param overallCombatObject combat
---@param combatId number
---@param ... unknown
---@return combat
function classCombat:NovaTabela(bTimeStarted, overallCombatObject, combatId, ...) --~init
	---@type combat
	local combatObject = {}

	combatObject[1] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_DAMAGE_CLASS,	combatObject, combatId) --Damage
	combatObject[2] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_HEAL_CLASS,	combatObject, combatId) --Healing
	combatObject[3] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_ENERGY_CLASS,	combatObject, combatId) --Energies
	combatObject[4] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_MISC_CLASS,	combatObject, combatId) --Misc
	combatObject[5] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_DAMAGE_CLASS,	combatObject, combatId) --place holder for customs

	setmetatable(combatObject, classCombat)

	Details.combat_counter = Details.combat_counter + 1
	combatObject.combat_counter = Details.combat_counter

	--combatObject.training_dummy = false

	--try discover if is a pvp combat
	local sourceGUID, sourceName, sourceFlags, targetGUID, targetName, targetFlags = ...

	if (targetGUID) then
		local npcId = Details:GetNpcIdFromGuid(targetGUID)
		if (npcId) then
			if (Details222.TrainingDummiesNpcId[npcId]) then
				combatObject.training_dummy = true
			end
		end
	end

	if (sourceGUID) then --aqui ir� identificar o boss ou o oponente
		if (targetName and bitBand (targetFlags, REACTION_HOSTILE) ~= 0) then --tentando pegar o inimigo pelo alvo
			combatObject.contra = targetName
			if (bitBand (targetFlags, CONTROL_PLAYER) ~= 0) then
				combatObject.pvp = true --o alvo � da fac��o oposta ou foi dado mind control
			end
		elseif (sourceName and bitBand (sourceFlags, REACTION_HOSTILE) ~= 0) then --tentando pegar o inimigo pelo who caso o mob � quem deu o primeiro hit
			combatObject.contra = sourceName
			if (bitBand (sourceFlags, CONTROL_PLAYER) ~= 0) then
				combatObject.pvp = true --o who � da fac��o oposta ou foi dado mind control
			end
		else
			combatObject.pvp = true --se ambos s�o friendly, seria isso um PVP entre jogadores da mesma fac��o?
		end
	end

	--start/end time (duration)
	combatObject.data_fim = 0
	combatObject.data_inicio = 0
	combatObject.tempo_start = _tempo

	combatObject.boss_hp = 1

	C_Timer.After(0.5, getBossName)

	combatObject.bossTimers = {}

	---store trinket procs
	combatObject.trinketProcs = {}

	--store talents of players
	---@type table<actorname, string>
	combatObject.playerTalents = {}

	---store the amount of casts of each player
	---@type table<actorname, table<spellname, number>>
	combatObject.amountCasts = {}

	--record deaths
	combatObject.last_events_tables = {}

	--last events from players
	combatObject.player_last_events = {}

	--players in the raid
	combatObject.raid_roster = {}

	--frags
	combatObject.frags = {}
	combatObject.frags_need_refresh = false

	--alternate power
	combatObject.alternate_power = {}

	--time data container
	combatObject.TimeData = Details:TimeDataCreateChartTables()
	combatObject.PhaseData = {{1, 1}, damage = {}, heal = {}, damage_section = {}, heal_section = {}} --[1] phase number [2] phase started

	--for external plugin usage, these tables are guaranteed to be saved with the combat
	combatObject.spells_cast_timeline = {}
	combatObject.aura_timeline = {}
	combatObject.cleu_timeline = {}

	--cleu events
	combatObject.cleu_events = {
		n = 1 --event counter
	}

	local zoneName, _, _, _, _, _, _, zoneMapID = GetInstanceInfo()
	combatObject.zoneName = zoneName
	combatObject.mapId = zoneMapID

	--a tabela sem o tempo de inicio � a tabela descartavel do inicio do addon
	if (bTimeStarted) then
		--esta_tabela.start_time = _tempo
		combatObject.start_time = GetTime()
		combatObject.end_time = nil
	else
		combatObject.start_time = 0
		combatObject.end_time = nil
	end

	combatObject.is_challenge = Details:IsInMythicPlus()

	-- o container ir� armazenar as classes de dano -- cria um novo container de indexes de seriais de jogadores --par�metro 1 classe armazenada no container, par�metro 2 = flag da classe
	combatObject[1].need_refresh = true
	combatObject[2].need_refresh = true
	combatObject[3].need_refresh = true
	combatObject[4].need_refresh = true
	combatObject[5].need_refresh = true

	combatObject.totals = {
		0, --dano
		0, --cura
		{--e_energy
			[0] = 0, --mana
			[1] = 0, --rage
			[3] = 0, --energy (rogues cat)
			[6] = 0, --runepower (dk)
			alternatepower = 0,
		},
		{--misc
			cc_break = 0, --armazena quantas quebras de CC
			ress = 0, --armazena quantos pessoas ele reviveu
			interrupt = 0, --armazena quantos interrupt a pessoa deu
			dispell = 0, --armazena quantos dispell esta pessoa recebeu
			dead = 0, --armazena quantas vezes essa pessia morreu
			cooldowns_defensive = 0, --armazena quantos cooldowns a raid usou
			buff_uptime = 0, --armazena quantos cooldowns a raid usou
			debuff_uptime = 0 --armazena quantos cooldowns a raid usou
		},

		--avoid using this values bellow, they aren't updated by the parser, only on demand by a user interaction.
			voidzone_damage = 0,
			frags_total = 0,
		--end
	}

	combatObject.totals_grupo = {
		0, --dano
		0, --cura
		{--e_energy
			[0] = 0, --mana
			[1] = 0, --rage
			[3] = 0, --energy (rogues cat)
			[6] = 0, --runepower (dk)
			alternatepower = 0,
		},
		{--misc
			cc_break = 0, --armazena quantas quebras de CC
			ress = 0, --armazena quantos pessoas ele reviveu
			interrupt = 0, --armazena quantos interrupt a pessoa deu
			dispell = 0, --armazena quantos dispell esta pessoa recebeu
			dead = 0, --armazena quantas vezes essa oessia morreu
			cooldowns_defensive = 0, --armazena quantos cooldowns a raid usou
			buff_uptime = 0,
			debuff_uptime = 0
		}
	}

	return combatObject
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core

	---create the table which will contain the latest events of the player while alive
	---@param self combat
	---@param playerName string
	---@return table
	function classCombat:CreateLastEventsTable(playerName)
		local lastEventsTable = {}

		for i = 1, Details.deadlog_events do
			lastEventsTable[i] = {}
		end

		lastEventsTable.n = 1
		self.player_last_events[playerName] = lastEventsTable
		return lastEventsTable
	end

	---pass through all actors and check if the activity time is unlocked, if it is, lock it
	---@param self combat
	function classCombat:LockActivityTime()
		---@cast self combat
		---@type actorcontainer
		local containerDamage = self:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		---@type actorcontainer
		local containerHeal = self:GetContainer(DETAILS_ATTRIBUTE_HEAL)

		for _, actorObject in containerDamage:ListActors() do
			if (actorObject:GetOrChangeActivityStatus()) then --check if the timer is unlocked
				Details222.TimeMachine.StopTime(actorObject)
				actorObject:GetOrChangeActivityStatus(false) --lock the actor timer
			else
				if (actorObject.start_time == 0) then
					actorObject.start_time = _tempo
				end
				if (not actorObject.end_time) then
					actorObject.end_time = _tempo
				end
			end
		end

		for _, actorObject in containerHeal:ListActors() do
			--check if the timer is unlocked
			if (actorObject:GetOrChangeActivityStatus()) then
				--lock the actor timer
				Details222.TimeMachine.StopTime(actorObject)
				--remove the actor from the time machine
				actorObject:GetOrChangeActivityStatus(false)
			else
				if (actorObject.start_time == 0) then
					actorObject.start_time = _tempo
				end
				if (not actorObject.end_time) then
					actorObject.end_time = _tempo
				end
			end
		end
	end

	---set combat metatable and class lookup
	---@self any
	---@param combatObject combat
	function Details.refresh:r_combate(combatObject)
		setmetatable(combatObject, Details.combate)
		combatObject.__index = Details.combate
	end

	---clear combat object
	---@self any
	---@param combatObject combat
	function Details.clear:c_combate(combatObject)
		combatObject.__index = nil
		combatObject.__call = nil
	end

	classCombat.__sub = function(combate1, combate2)

		if (combate1 ~= Details.tabela_overall) then
			return
		end

		--sub dano
			for index, actor_T2 in ipairs(combate2[1]._ActorTable) do
				local actor_T1 = combate1[1]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [1].need_refresh = true

		--sub heal
			for index, actor_T2 in ipairs(combate2[2]._ActorTable) do
				local actor_T1 = combate1[2]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [2].need_refresh = true

		--sub energy
			for index, actor_T2 in ipairs(combate2[3]._ActorTable) do
				local actor_T1 = combate1[3]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [3].need_refresh = true

		--sub misc
			for index, actor_T2 in ipairs(combate2[4]._ActorTable) do
				local actor_T1 = combate1[4]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [4].need_refresh = true

		--reduz o tempo
			combate1.start_time = combate1.start_time + combate2:GetCombatTime()

		--apaga as mortes da luta diminuida
			local amt_mortes =  #combate2.last_events_tables --quantas mortes teve nessa luta
			if (amt_mortes > 0) then
				for i = #combate1.last_events_tables, #combate1.last_events_tables-amt_mortes, -1 do
					tremove(combate1.last_events_tables, #combate1.last_events_tables)
				end
			end

		--frags
			for fragName, fragAmount in pairs(combate2.frags) do
				if (fragAmount) then
					if (combate1.frags [fragName]) then
						combate1.frags [fragName] = combate1.frags [fragName] - fragAmount
					else
						combate1.frags [fragName] = fragAmount
					end
				end
			end
			combate1.frags_need_refresh = true

		--alternate power
			local overallPowerTable = combate1.alternate_power
			for actorName, powerTable in pairs(combate2.alternate_power) do
				local power = overallPowerTable [actorName]
				if (power) then
					power.total = power.total - powerTable.total
				end
				combate2.alternate_power [actorName].last = 0
			end

		return combate1

	end

	---add combatToAdd into combatRecevingTheSum
	---@param combatRecevingTheSum combat
	---@param combatToAdd combat
	---@return combat
	classCombat.__add = function(combatRecevingTheSum, combatToAdd)
		---@type combat
		local customCombat
		if (combatRecevingTheSum ~= Details.tabela_overall) then
			customCombat = combatRecevingTheSum
		end

		local bRefreshActor = false

		for classType = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
			local actorContainer = combatToAdd[classType]
			local actorTable = actorContainer._ActorTable
			for _, actorObject in ipairs(actorTable) do
				---@cast actorObject actor
				---@type actor
				local actorCreatedInTheReceivingCombat

				if (classType == classTypeDamage) then
					actorCreatedInTheReceivingCombat = Details.atributo_damage:AddToCombat(actorObject, bRefreshActor, customCombat)

				elseif (classType == classTypeHeal) then
					actorCreatedInTheReceivingCombat = Details.atributo_heal:AddToCombat(actorObject, bRefreshActor, customCombat)

				elseif (classType == classTypeResource) then
					actorCreatedInTheReceivingCombat = Details.atributo_energy:r_connect_shadow(actorObject, true, customCombat)

				elseif (classType == classTypeUtility) then
					actorCreatedInTheReceivingCombat = Details.atributo_misc:r_connect_shadow(actorObject, true, customCombat)
				end

				actorCreatedInTheReceivingCombat.boss_fight_component = actorObject.boss_fight_component or actorCreatedInTheReceivingCombat.boss_fight_component
				actorCreatedInTheReceivingCombat.fight_component = actorObject.fight_component or actorCreatedInTheReceivingCombat.fight_component
				actorCreatedInTheReceivingCombat.grupo = actorObject.grupo or actorCreatedInTheReceivingCombat.grupo
			end
		end

		--alternate power
		local overallPowerTable = combatRecevingTheSum.alternate_power
		for actorName, powerTable in pairs(combatToAdd.alternate_power) do
			local alternatePowerTable = overallPowerTable[actorName]
			if (not alternatePowerTable) then
				alternatePowerTable = combatRecevingTheSum:CreateAlternatePowerTable(actorName)
			end
			alternatePowerTable.total = alternatePowerTable.total + powerTable.total
			combatToAdd.alternate_power[actorName].last = 0
		end

		--cast amount
		local combat1CastData = combatRecevingTheSum.amountCasts
		for actorName, castData in pairs(combatToAdd.amountCasts) do
			local playerCastTable = combat1CastData[actorName]
			if (not playerCastTable) then
				playerCastTable = {}
				combat1CastData[actorName] = playerCastTable
			end
			for spellName, amountOfCasts in pairs(castData) do
				local spellAmount = playerCastTable[spellName]
				if (not spellAmount) then
					spellAmount = 0
					playerCastTable[spellName] = spellAmount
				end
				playerCastTable[spellName] = spellAmount + amountOfCasts
			end
		end

		return combatRecevingTheSum
	end

	function Details:UpdateCombat()
		_tempo = Details._tempo
	end
