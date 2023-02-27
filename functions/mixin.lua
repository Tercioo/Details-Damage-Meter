
local Details = _G.Details
local detailsFramework = _G.DetailsFramework
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
local addonName, Details222 = ...


Details222.Mixins.ActorMixin = {
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
}