
--[=[
Details API 2.0
This is a high level API for Details! Damage Meter



--]=]

--local helpers
local getCombatObject = function (segmentNumber)
	local combatObject
	
	--select which segment to use, use low level variables for performance
	if (segmentNumber == -1) then
		combatObject = _detalhes.tabela_overall
	elseif (segmentNumber == 0) then
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

local getUnitName = function (unitId)
	local unitName, serverName = UnitName (unitId)
	if (unitName) then
		if (serverName and serverName ~= "") then
			return unitName .. "-" .. serverName
		else
			return unitName
		end
	else
		return unitId
	end
end

--api
Details.API_Description = {}


--[=[
	Details.SegmentElapsedTime (segment)
--=]=]
tinsert (Details.API_Description, {
	name = "SegmentElapsedTime",
	desc = "Return the total elapsed time of a segment.",
	parameters = {
		{
			name = "segment",
			type = "number",
			default = "0",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "segmentElapsedTime",
			type = "number",
			desc = "Number representing the elapsed time of a combat.",
		}
	},
	type = 1, --damage
})

function Details.SegmentElapsedTime (segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	return combatObject:GetCombatTime()
end

--[=[
	Details.UnitDamage (unitId, segment)
--=]=]
tinsert (Details.API_Description, {
	name = "UnitDamage",
	desc = "Query the damage of a unit.",
	parameters = {
		{
			name = "unitId",
			type = "string",
			desc = "The ID of an unit, example: 'player', 'target', 'raid5'. Accept unit names.",
			required = true,
		},
		{
			name = "segment",
			type = "number",
			default = "0",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "unitDamage",
			type = "number",
			desc = "Number representing the unit damage.",
		}
	},
	type = 1, --damage
})

function Details.UnitDamage (unitId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)
	
	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return 0
	end
	
	return floor (playerObject.total or 0)
end


--[=[
	Details.UnitSpellDamage (unitId, spellId, segment)
--=]=]
tinsert (Details.API_Description, {
	name = "UnitSpellDamage",
	desc = "Query the total damage done of a spell casted by the unit.",
	parameters = {
		{
			name = "unitId",
			type = "string",
			desc = "The ID of an unit, example: 'player', 'target', 'raid5'. Accept unit names.",
			required = true,
		},
		{
			name = "spellId",
			type = "number",
			desc = "Id of a spell to query the damage done. Accept spell names.",
			required = true,
		},
		{
			name = "segment",
			default = "0",
			type = "number",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "unitSpellDamage",
			type = "number",
			desc = "Number representing the spell damage done.",
		}
	},
	type = 1, --damage
})

function Details.UnitSpellDamage (unitId, spellId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)

	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)

	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return 0
	end
	
	if (type (spellId) == "string") then
		local newSpellId = select (7, GetSpellInfo (spellId))
		if (not newSpellId) then
			local passedSpellName = spellId:lower()
			for damageSpellId, spellInfo in pairs (playerObject.spells._ActorTable) do
				local spellName = GetSpellInfo (damageSpellId)
				if (spellName:lower() == passedSpellName) then
					spellId = damageSpellId
					break
				end
			end
		else
			spellId = newSpellId
		end
	end
	
	local spell = playerObject.spells._ActorTable [spellId]
	return spell and spell.total or 0
end


--[=[
	Details.UnitSpells (unitId, segment)
--=]=]
tinsert (Details.API_Description, {
	name = "UnitDamageSpells",
	desc = "Return a numeric table with spells IDs used by the unit.",
	parameters = {
		{
			name = "unitId",
			type = "string",
			desc = "The ID of an unit, example: 'player', 'target', 'raid5'. Accept unit names.",
			required = true,
		},
		{
			name = "segment",
			type = "number",
			default = "0",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "unitSpellDamage",
			type = "number",
			desc = "Number representing the spell damage done.",
		}
	},
	type = 1, --damage
})

function Details.UnitDamageSpells (unitId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)

	if (not combatObject) then
		return {}
	end
	
	local unitName = getUnitName (unitId)

	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return {}
	end
	
	local unitSpells = playerObject.spells._ActorTable
	local resultTable = {}
	for spellId, spellObject in pairs (unitSpells) do
		resultTable [#resultTable + 1] = spellId
	end
	
	return resultTable
end


--[=[
	Details.UnitDamageTaken (unitId, segment)
--=]=]
tinsert (Details.API_Description, {
	name = "UnitDamageTaken",
	desc = "Query the unit damage taken.",
	parameters = {
		{
			name = "unitId",
			type = "string",
			desc = "The ID of an unit, example: 'player', 'target', 'raid5'. Accept unit names.",
			required = true,
		},
		{
			name = "segment",
			type = "number",
			default = "0",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "unitDamageTaken",
			type = "number",
			desc = "Number representing the damage taken by the unit.",
		}
	},
	type = 1, --damage
})

function Details.UnitDamageTaken (unitId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)

	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)

	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return 0
	end
	
	return playerObject.damage_taken
end

--[=[
	Details.UnitDamageOnUnit (unitId, targetUnitId, segment)
--=]=]
tinsert (Details.API_Description, {
	name = "UnitDamageOnUnit",
	desc = "Query the unit damage done on another unit.",
	parameters = {
		{
			name = "unitId",
			type = "string",
			desc = "The ID of an unit, example: 'player', 'target', 'raid5'. Accept unit names.",
			required = true,
		},
		{
			name = "targetUnitId",
			type = "string",
			desc = "Name or ID of an unit, example: 'Thrall', 'Jaina', 'player', 'target', 'raid5'.",
			required = true,
		},
		{
			name = "segment",
			type = "number",
			default = "0",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "unitDamageOnUnit",
			type = "number",
			desc = "Number representing the damage done by the unit on the target unit.",
		}
	},
	type = 1, --damage
})

function Details.UnitDamageOnUnit (unitId, targetUnitId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)
	
	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return 0
	end
	
	local targetName = getUnitName (targetUnitId)
	return playerObject.targets [targetName] or 0
end

--[=[
	Details.UnitDamageTakenFromSpell (unitId, spellId, segment)
--=]=]
tinsert (Details.API_Description, {
	name = "UnitDamageTakenFromSpell",
	desc = "Query the unit damage taken from a spell.",
	parameters = {
		{
			name = "unitId",
			type = "string",
			desc = "The ID of an unit, example: 'player', 'target', 'raid5'. Accept unit names.",
			required = true,
		},
		{
			name = "spellId",
			type = "number",
			desc = "Id of a spell to query its damage to an unit. Accept spell names.",
			required = true,
		},
		{
			name = "segment",
			type = "number",
			default = "0",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "unitDamageTakenFromSpell",
			type = "number",
			desc = "Number representing the damage taken by the unit from a spell.",
		}
	},
	type = 1, --damage
})

function Details.UnitDamageTakenFromSpell (unitId, spellId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)
	local damageContainer = combatObject:GetContainer (DETAILS_ATTRIBUTE_DAMAGE)
	
	local totalDamageTaken = 0
	local spellName = GetSpellInfo (spellId) or spellId
	
	for i = 1, #damageContainer._ActorTable do
		local playerObject = damageContainer._ActorTable [i]
		local unitSpells = playerObject.spells._ActorTable
		
		for spellId, spellObject in pairs (unitSpells) do
			local thisSpellName = GetSpellInfo (spellId)
			if (thisSpellName == spellName) then
				totalDamageTaken = totalDamageTaken + (spellObject.targets [unitName] or 0)
			end
		end
	end
	
	return totalDamageTaken
end

--[=[
	Details.UnitDamageInfo (unitId, segment)
--=]=]
tinsert (Details.API_Description, {
	name = "UnitDamageInfo",
	desc = "Return a table with damage information.",
	parameters = {
		{
			name = "unitId",
			type = "string",
			desc = "The ID of an unit, example: 'player', 'target', 'raid5'. Accept unit names.",
			required = true,
		},
		{
			name = "segment",
			type = "number",
			default = "0",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "damageInfo",
			type = "table",
			desc = "Table containing damage information, keys are: .total, .totalWithoutPet, .damageAbsorbed, .damageTaken, .friendlyFire and .activityTime",
		}
	},
	type = 1, --damage
})

function Details.UnitDamageInfo (unitId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)
	
	local damageInfo = {
		total = 0,
		totalWithoutPet = 0,
		damageAbsorbed = 0,
		damageTaken = 0,
		friendlyFire = 0,
		activityTime = 0,
	}
	
	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return damageInfo
	end
	
	damageInfo.total = floor (playerObject.total)
	damageInfo.totalWithoutPet = floor (playerObject.total_without_pet)
	damageInfo.damageAbsorbed = floor (playerObject.totalabsorbed)
	damageInfo.damageTaken = floor (playerObject.damage_taken)
	damageInfo.friendlyFire = playerObject.friendlyfire_total
	damageInfo.activityTime = playerObject:Tempo()
	
	return damageInfo
end


--[=[
	Details.UnitSpellInfo (unitId, spellId, segment)
--=]=]
tinsert (Details.API_Description, {
	name = "UnitDamageSpellInfo",
	desc = "Return a table with the spell damage information.",
	parameters = {
		{
			name = "unitId",
			type = "string",
			desc = "The ID of an unit, example: 'player', 'target', 'raid5'. Accept unit names.",
			required = true,
		},
		{
			name = "spellId",
			type = "number",
			desc = "Id of a spell to query its damage to an unit. Accept spell names.",
			required = true,
		},
		{
			name = "segment",
			type = "number",
			default = "0",
			desc = "Which segment to retrive data, default value is zero (current segment). Use -1 for overall data or value from 1 to 25 for other segments.",
		},
	},
	returnValues = {
		{
			name = "spellDamageInfo",
			type = "table",
			desc = "Table containing damage information, keys are: '.total', '.spellId', '.count', '.name', '.casted', '.regularMin', '.regularMax', '.regularAmount', '.regularDamage', '.criticalMin', '.criticalMax', '.criticalAmount', '.criticalDamage'",
		}
	},
	type = 1, --damage
})

function Details.UnitDamageSpellInfo (unitId, spellId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)
	
	local spellInfo = {
		total = 0,
		spellId = 0,
		count = 0,
		name = "",
		casted = 0,
		regularMin = 0,
		regularMax = 0,
		regularAmount = 0,
		regularDamage = 0,
		criticalMin = 0,
		criticalMax = 0,
		criticalAmount = 0,
		criticalDamage = 0,
	}
	
	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return spellInfo
	end
	
	local miscPlayerObject = getActorObjectFromCombat (combatObject, 4, unitName)
	
	local spellName = GetSpellInfo (spellId) or spellId
	local spellObject
	
	for thisSpellId, thisSpellObject in pairs (playerObject.spells._ActorTable) do
		local thisSpellName = GetSpellInfo (thisSpellId)
		if (thisSpellName == spellName) then
			spellObject = thisSpellObject
			spellId = thisSpellId
			
			if (miscPlayerObject) then
				local castedAmount = miscPlayerObject.spell_cast and miscPlayerObject.spell_cast [spellId]
				if (castedAmount) then
					spellInfo.casted = castedAmount
				else
					for castedSpellId, castedAmount in pairs (miscPlayerObject.spell_cast) do
						local castedSpellName = GetSpellInfo (castedSpellId)
						if (castedSpellName == spellName) then
							spellInfo.casted = castedAmount
						end
					end
				end
			end
			break
		end
	end

	spellInfo.total = spellObject.total
	spellInfo.count = spellObject.counter
	spellInfo.spellId = spellId
	spellInfo.name = spellName
	spellInfo.regularMin = spellObject.n_min
	spellInfo.regularMax = spellObject.n_max
	spellInfo.regularAmount = spellObject.n_amt
	spellInfo.regularDamage = spellObject.n_dmg
	spellInfo.criticalMin = spellObject.c_min
	spellInfo.criticalMax = spellObject.c_max
	spellInfo.criticalAmount = spellObject.c_amt
	spellInfo.criticalDamage = spellObject.c_dmg

	return spellInfo
end

--stop auto complete: doo ende endp elsez 