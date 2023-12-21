
local Details = _G.Details
local detailsFramework = _G.DetailsFramework
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
local addonName, Details222 = ...

local bitBand = bit.band

local CONST_OBJECT_TYPE_PLAYER = 0x00000400
local CONST_OBJECT_TYPE_NEUTRAL_OR_ENEMY = 0x00000060

local actorSpellContainers = {
	"debuff", "buff", "spell", "cooldowns", "crowdcontrol", "dispel"
}

Details222.Mixins.ActorMixin = {
	---return a table containing the spellContainers names: 'debuff', 'buff', 'spell', 'cooldowns', 'crowdcontrol'
	---@return string[]
	GetSpellContainerNames = function()
		return actorSpellContainers
	end,

	---return a spellContainer from an actor
	---@param actor actor
	---@param containerType string
	---@return spellcontainer|nil
	GetSpellContainer = function(actor, containerType)
		if (containerType == "debuff") then
			return actor.debuff_uptime_spells

		elseif (containerType == "buff") then
			return actor.buff_uptime_spells

		elseif (containerType == "spell") then
			return actor.spells

		elseif (containerType == "cooldowns") then
			return actor.cooldowns_defensive_spells

		elseif (containerType == "crowdcontrol") then
			---@cast actor actorutility
			return actor.cc_done_spells

		elseif (containerType == "dispel") then
			---@cast actor actorutility
			return actor.dispell_spells

		elseif (containerType == "dispelwhat") then
			---@cast actor actorutility
			return actor.dispell_oque

		elseif (containerType == "interrupt") then
			---@cast actor actorutility
			return actor.interrupt_spells

		elseif (containerType == "interruptwhat") then
			---@cast actor actorutility
			return actor.interrompeu_oque --is intended to be in portuguese

		elseif (containerType == "interrupttargets") then
			---@cast actor actorutility
			return actor.interrupt_targets
		end
	end,

	---return a spellTable from a spellContainer
	---@param actor actor
	---@param spellContainerName string
	---@param spellId number
	---@return spelltable|nil
	GetSpellTableFromContainer = function(actor, spellContainerName, spellId)
		---@type spellcontainer
		local spellContainer = actor[spellContainerName]
		if (spellContainer) then
			---@type spelltable
			local spellTable = spellContainer._ActorTable[spellId]
			return spellTable
		end
	end,

	---return a table containing pet names
	---@param actor actor
	---@return table<number, string>
	GetPets = function(actor)
		return actor.pets
	end,

	---return a table containing the targets of the actor
	---@param actor actor
	---@param key string optional, if not provided, will use the default target table: 'targets'
	---@return targettable
	GetTargets = function(actor, key)
		return actor[key or "targets"]
	end,

	---return a table containing spellTables
	---@param actor actor
	---@return table<number, spelltable>
	GetSpellList = function(actor)
		return actor.spells._ActorTable
	end,

	---this function sums all the targets of all spellTables conteining on a 'spelltableadv'
	---@param actor actor
	---@param bkSpellData spelltableadv
	---@param targetTableName string
	---@return table<string, number>
	BuildSpellTargetFromBreakdownSpellData = function(actor, bkSpellData, targetTableName)
		targetTableName = targetTableName or "targets"

		local spellTables = bkSpellData.spellTables

		---@type table<string, number> store the index of the target name in the result table
		local cacheIndex = {}
		---@type table<string, number> store the result which is returned by this function
		local result = {}

		for i = 1, #spellTables do
			---@type spelltable
			local spellTable = spellTables[i]
			---@type table<string, number>
			local targets = spellTable[targetTableName]

			for targetName, value in pairs(targets) do
				local index = cacheIndex[targetName]
				if (index) then
					result[index][2] = result[index][2] + value
				else
					result[#result+1] = {targetName, value}
					cacheIndex[targetName] = #result
				end
			end
		end

		table.sort(result, function(t1, t2)
			return t1[2] > t2[2]
		end)

		return result
	end,

	---this function receives a key for the name of the target table (usually is 'targets') and return a table containing the targets and the damage done in order of bigger to lower value
	---@param actor actor
	---@param spellTable spelltable
	---@param targetKey string
	---@return table<string, number>
	BuildSpellTargetFromSpellTable = function(actor, spellTable, targetKey)
		targetKey = targetKey or "targets"

		---@type table<string, number>[] store the result which is returned by this function
		local result = {}

		---@type table<string, number>
		local targets = spellTable[targetKey]

		for targetName, value in pairs(targets) do
			---@cast targetName string
			---@cast value number
			result[#result+1] = {targetName, value}
		end

		table.sort(result, function(t1, t2)
			return t1[2] > t2[2]
		end)

		return result
	end,

	---return true if the actor is controlled by a player
	---@param actorObject actor
	---@return boolean
	IsPlayer = function(actorObject)
		if (actorObject.flag_original) then
			if (bitBand(actorObject.flag_original, CONST_OBJECT_TYPE_PLAYER) ~= 0) then
				return true
			end
		end
		return false
	end,

	---return true if the actor is a pet or guardian
	---@param actorObject actor
	---@return boolean
	IsPetOrGuardian = function(actorObject)
		return actorObject.owner and true or false
	end,

	---return true if the actor is or was in the player group
	---@param actorObject table
	---@return boolean
	IsGroupPlayer = function(actorObject)
		return actorObject.grupo and true or false
	end,

	---return true if the actor is an enemy of neutral npc
	---@param actorObject actor
	---@return boolean
	IsNeutralOrEnemy = function(actorObject)
		if (actorObject.flag_original) then
			if (bitBand(actorObject.flag_original, CONST_OBJECT_TYPE_NEUTRAL_OR_ENEMY) ~= 0) then
				local npcId = Details:GetNpcIdFromGuid(actorObject.serial)
				if (Details.IgnoredEnemyNpcsTable[npcId]) then
					return false
				end
				return true
			end
		end
		return false
	end,
}