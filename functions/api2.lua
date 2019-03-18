
--[=[
Details API 2.0
This is a high level API for Details! Damage Meter



--]=]

--local helpers
local getCombatObject = function (segmentNumber)
	local combatObject
	
	--select which segment to use, use low level variables for performance
	if (segment == -1) then
		combatObject = _detalhes.tabela_overall
	elseif (segment == 0) then
		combatObject = _detalhes.tabela_vigente
	else
		combatObject = _detalhes.tabela_historico.tabelas [segment]
	end
	
	return combatObject
end

local getActorObjectFromCombat = function (combatObject, containerID, actorName)
	local index = combatObject [containerID]._NameIndexTable [actorName]
	return combatObject [containerID]._ActorTable [index]
end

--api
Details.API_Description = {}

--[=[
	Details:GetPlayerDamage ( playerName, segment = 0 )
	returns the damage of player or npc, must pass the full player name (with realm name if the player is from a different realm), pet names must have the owner name.
	
--=]=]
Details.API_Description.GetPlayerDamage = {
	desc = "Returns the damage of player or npc, must pass the full player name (with realm name if the player is from a different realm), pet names must have the owner name.",
	parameters = {
		{
			name = "playerName",
			desc = "Name of the player, pet, npc. Must be the exactly name with realm included if the player isn't from the same server as you.",
		},
		{
			name = "segment",
			type = "number",
			desc = "Which segment to retrive the player damage, default value is current segment. Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "playerDamage",
			type = "number",
			desc = "Number (float) representing the player damage.",
		}
	},
}

function Details.GetPlayerDamage (playerName, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local playerObject = getActorObjectFromCombat (combatObject, 1, playerName)
	if (not playerObject) then
		return 0
	end
	
	return playerObject.total or 0
end


--[=[
	Details:GetPlayerDamageOnUnit ( playerName, unitName, segment = 0 )
	returns the damage of player or npc in a specific target
	
--=]=]
Details.API_Description.GetPlayerDamageOnUnit = {
	desc = "Returns the damage of player or npc in a specific target.",
	parameters = {
		{
			name = "playerName",
			desc = "Name of the player, pet, npc. Must be the exactly name with realm included if the player isn't from the same server as you.",
		},
		{
			name = "unitName",
			desc = "Name of the unit target.",
		},
		{
			name = "segment",
			type = "number",
			desc = "Which segment to retrive the player damage, default value is current segment. Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "damageOnTarget",
			type = "number",
			desc = "Number (float) representing the player damage on the unit target.",
		}
	},
}

function Details.GetPlayerDamageOnUnit (playerName, unitName, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local playerObject = getActorObjectFromCombat (combatObject, 1, playerName)
	if (not playerObject) then
		return 0
	end

	return playerObject.targets [unitName] or 0
end


--[=[

--=]=]



--[=[

--=]=]



--[=[

--=]=]



--[=[

--=]=]



--[=[

--=]=]



--[=[

--=]=]