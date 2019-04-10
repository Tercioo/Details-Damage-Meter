
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

--return the spell object and the spellId
local getSpellObject = function (playerObject, spellId, isLiteral)
	local parameterType = type (spellId)
	
	if (parameterType == "number" and isLiteral) then
		--is the id of a spell and literal, directly get the spell object
		return playerObject.spells._ActorTable [spellId], spellId
		
	else
		local passedSpellName
		if (parameterType == "string") then
			--passed a spell name, make the spell be in lower case
			passedSpellName = spellId:lower()
			
		elseif (parameterType == "number") then
			--passed a number but with literal off, transform the spellId into a spell name
			local spellName = GetSpellInfo (spellid)
			if (spellName) then
				passedSpellName = spellName:lower()
			end
		end
		
		if (passedSpellName) then
			for thisSpellId, spellObject in pairs (playerObject.spells._ActorTable) do
				local spellName = Details.GetSpellInfo (thisSpellId)
				if (spellName) then
					if (spellName:lower() == passedSpellName) then
						return spellObject, thisSpellId
					end
				end
			end
		end
	end
end

--api
Details.API_Description = {
	addon = "Details! Damage Meter",
	namespaces = {
		{
			name = "Details",
			order = 1,
			api = {},
		}
	},
}


--[=[
	Details.SegmentElapsedTime (segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
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
	Details.SegmentOffensiveUnits (segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
	name = "SegmentOffensiveUnits",
	desc = "Return a numeric (ipairs) table with name of units that inflicted damage on the segment.",
	parameters = {
		{
			name = "includePlayerUnits",
			type = "boolean",
			default = "true",
			desc = "Include names of player units, e.g. name of players in your dungeon or raid group.",
		},
		{
			name = "includeEnemyUnits",
			type = "boolean",
			default = "false",
			desc = "Include names of enemy units, e.g. name of a boss and their adds.",
		},
		{
			name = "includeFriendlyPetUnits",
			type = "boolean",
			default = "false",
			desc = "Include names of player pets.",
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
			name = "unitNames",
			type = "table",
			desc = "A table with unit names.",
		}
	},
	type = 1, --damage
})

function Details.SegmentOffensiveUnits (includePlayerUnits, includeEnemyUnits, includeFriendlyPetUnits, segment)
	segment = segment or 0
	if (type (includePlayerUnits) ~= "boolean") then
		includePlayerUnits = true
	end
	
	local combatObject = getCombatObject (segment)
	
	local units = {}
	local nextIndex = 1
	
	if (not combatObject) then
		return units
	end
	
	local damageContainer = combatObject:GetContainer (DETAILS_ATTRIBUTE_DAMAGE)
	for i = 1, #damageContainer._ActorTable do
		local playerObject = damageContainer._ActorTable [i]
		
		if (includePlayerUnits and playerObject.grupo) then
			units [nextIndex] = playerObject:GetName()
			nextIndex = nextIndex + 1
		
		elseif (includeEnemyUnits and playerObject:IsEnemy()) then
			units [nextIndex] = playerObject:GetName()
			nextIndex = nextIndex + 1
			
		elseif (includeFriendlyPetUnits and playerObject:IsPetOrGuardian()) then
			units [nextIndex] = playerObject:GetName()
			nextIndex = nextIndex + 1
		end
	end
	
	return units
end

--[=[
	Details.UnitDamage (unitId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
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
	Details.UnitDamageInfo (unitId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
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
	Details.UnitDamageBySpell (unitId, spellId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
	name = "UnitDamageBySpell",
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
			name = "isLiteral",
			type = "boolean",
			default = "true",
			desc = "Search for the spell without transforming the spellId into a spell name before the search.",
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

function Details.UnitDamageBySpell (unitId, spellId, isLiteral, segment)
	if (type (isLiteral) ~= "boolean") then
		isLiteral = true
	end
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
	
	local spellObject, spellId = getSpellObject (playerObject, spellId, isLiteral)
	print (spellObject, spellId, isLiteral)
	if (spellObject) then
		return spellObject.total
	else
		return 0
	end
end


--[=[
	Details.UnitDamageSpellInfo (unitId, spellId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
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
			name = "isLiteral",
			type = "boolean",
			default = "true",
			desc = "Search for the spell without transforming the spellId into a spell name before the search.",
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

function Details.UnitDamageSpellInfo (unitId, spellId, isLiteral, segment)
	if (type (isLiteral) ~= "boolean") then
		isLiteral = true
	end
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
	
	local spellObject, spellId = getSpellObject (playerObject, spellId, isLiteral)
	if (not spellObject) then
		return spellInfo
	end

	local miscPlayerObject = getActorObjectFromCombat (combatObject, 4, unitName)
	if (miscPlayerObject) then
		local spellName = GetSpellInfo (spellId)
		local castedAmount = miscPlayerObject.spell_cast and miscPlayerObject.spell_cast [spellId]
		
		if (castedAmount) then
			spellInfo.casted = castedAmount
		else
			for castedSpellId, castedAmount in pairs (miscPlayerObject.spell_cast) do
				local castedSpellName = GetSpellInfo (castedSpellId)
				if (castedSpellName == spellName) then
					spellInfo.casted = castedAmount
					break
				end
			end
		end
	end
	
	if (spellObject) then
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
	end
	
	return spellInfo
end

--[=[
	Details.UnitDamageSpellOnUnit (unitId, spellId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
	name = "UnitDamageSpellOnUnit",
	desc = "Query the damage done of a spell into a specific target.",
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
			name = "targetUnitId",
			type = "string",
			desc = "Name or ID of an unit, example: 'Thrall', 'Jaina', 'player', 'target', 'raid5'.",
			required = true,
		},
		{
			name = "isLiteral",
			type = "boolean",
			default = "true",
			desc = "Search for the spell without transforming the spellId into a spell name before the search.",
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
			name = "unitDamageSpellOnUnit",
			type = "number",
			desc = "Damage done by the spell into the target.",
		}
	},
	type = 1, --damage
})

function Details.UnitDamageSpellOnUnit (unitId, spellId, targetUnitId, isLiteral, segment)
	if (type (isLiteral) ~= "boolean") then
		isLiteral = true
	end
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
	
	local spellObject, spellId = getSpellObject (playerObject, spellId, isLiteral)
	if (spellObject) then
		local targetName = getUnitName (targetUnitId)
		return spellObject.targets [targetName] or 0
	else
		return 0
	end
end

--[=[
	Details.UnitDamageTaken (unitId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
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
tinsert (Details.API_Description.namespaces[1].api, {
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
tinsert (Details.API_Description.namespaces[1].api, {
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

function Details.UnitDamageTakenFromSpell (unitId, spellId, isLiteral, segment)
	segment = segment or 0
	if (type (isLiteral) ~= "boolean") then
		isLiteral = true
	end
	
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)
	local damageContainer = combatObject:GetContainer (DETAILS_ATTRIBUTE_DAMAGE)
	
	local totalDamageTaken = 0
	if (isLiteral and type (spellId) == "number") then
		for i = 1, #damageContainer._ActorTable do
			for thisSpellId, spellObject in pairs (damageContainer._ActorTable [i].spells._ActorTable) do
				if (thisSpellId == spellId) then
					totalDamageTaken = totalDamageTaken + (spellObject.targets [unitName] or 0)
				end
			end
		end
	else
		local spellName = GetSpellInfo (spellId) or spellId
		for i = 1, #damageContainer._ActorTable do
			for thisSpellId, spellObject in pairs (damageContainer._ActorTable [i].spells._ActorTable) do
				local thisSpellName = GetSpellInfo (thisSpellId)
				if (thisSpellName == spellName) then
					totalDamageTaken = totalDamageTaken + (spellObject.targets [unitName] or 0)
				end
			end
		end
	end

	return totalDamageTaken
end


--[=[
	Details.UnitOffensiveSpells (unitId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
	name = "UnitOffensiveSpells",
	desc = "Return a numeric (ipairs) table with spells IDs used by the unit.",
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

function Details.UnitOffensiveSpells (unitId, segment)
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
	Details.UnitOffensiveTargets (unitId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
	name = "UnitOffensiveTargets",
	desc = "Return a numeric (ipairs) table with names of targets the unit inflicted damage. You may query the amount of damage with Details.UnitDamageOnUnit( unitId, targetName ).",
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
			name = "offensiveTargetNames",
			type = "table",
			desc = "Table containing names of all offensive targets of the unit.",
		}
	},
	type = 1, --damage
})

function Details.UnitOffensiveTargets (unitId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)
	local offensiveTargetNames = {}
	
	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return offensiveTargetNames
	end
	
	for targetName, _ in pairs (playerObject.targets) do
		offensiveTargetNames [#offensiveTargetNames + 1] = targetName
	end
	
	return offensiveTargetNames
end


--[=[
	Details.UnitOffensivePets (unitId, segment)
--=]=]
tinsert (Details.API_Description.namespaces[1].api, {
	name = "UnitOffensivePets",
	desc = "Return a numeric (ipairs) table with all pet names the unit has. Individual pet information can be queried with Details.UnitDamage( petName ).",
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
			name = "petNames",
			type = "table",
			desc = "Table containing names of all pets the unit has.",
		}
	},
	type = 1, --damage
})

function Details.UnitOffensivePets (unitId, segment)
	segment = segment or 0
	local combatObject = getCombatObject (segment)
	
	if (not combatObject) then
		return 0
	end
	
	local unitName = getUnitName (unitId)
	local petNames = {}
	
	local playerObject = getActorObjectFromCombat (combatObject, 1, unitName)
	if (not playerObject) then
		return petNames
	end
	
	for i = 1, #playerObject.pets do
		petNames [#petNames + 1] = playerObject.pets [i]
	end
	
	return petNames
end




--stop auto complete: doo ende endp elsez 