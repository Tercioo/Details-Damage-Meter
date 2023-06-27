
local Details = 		_G.Details
local _
local addonName, Details222 = ...
local classDamageSpellTable 	= 	Details.habilidade_dano

function Details222.DamageSpells.CreateSpellTable(spellId, cleuToken)
	return classDamageSpellTable:NovaTabela(spellId, nil, cleuToken)
end

--cleu token is used to check if the spell is a dot
function Details.CreateSpellTable(spellId, cleuToken)
	return classDamageSpellTable:NovaTabela(spellId, nil, cleuToken)
end

---create a spelltable to store the damage of a spell
---@param self any
---@param spellId number
---@param link nil
---@param token string
---@return spelltable
function classDamageSpellTable:NovaTabela(spellId, link, token)
	---@type spelltable
	local spellTable = {
		total = 0, --total damage
		counter = 0, --counter
		id = spellId, --spellid
		successful_casted = 0, --successful casted times (only for enemies)

		--min damage made by normal hits
		n_min = 0,
		--max damage made by normal hits
		n_max = 0,
		--amount normal hits
		n_amt = 0,
		--total damage of normal hits
		n_total = 0,

		--critical hits
		c_min = 0,
		c_max = 0,
		c_amt = 0,
		c_total = 0,

		--glacing hits
		g_amt = 0,
		g_dmg = 0,

		--resisted
		r_amt = 0,
		r_dmg = 0,

		--blocked
		b_amt = 0,
		b_dmg = 0,

		--obsorved
		a_amt = 0,
		a_dmg = 0,

		targets = {},
		extra = {}
	}

	if (token == "SPELL_PERIODIC_DAMAGE") then
		Details:SetAsDotSpell(spellId)
	end

	return spellTable
end

function classDamageSpellTable:AddMiss(serial, targetName, targetFlags, sourceName, missType)
	self.counter = self.counter + 1
	self[missType] = (self[missType] or 0) + 1
	self.targets[targetName] = self.targets[targetName] or 0
end

function classDamageSpellTable:Add(targetSerial, targetName, targetFlags, amount, sourceName, resisted, blocked, absorbed, critical, glacing, token, bIsOffhand, bIsReflected)
	self.total = self.total + amount

	--when reflected add the spellId into the extra table to show which spells has reflected
	if (bIsReflected) then
		self.extra[bIsReflected] = (self.extra[bIsReflected] or 0) + amount
	end

	self.targets[targetName] = (self.targets[targetName] or 0) + amount
	self.counter = self.counter + 1

	if (resisted and resisted > 0) then
		self.r_dmg = self.r_dmg + amount
		self.r_amt = self.r_amt + 1
	end

	if (blocked and blocked > 0) then
		self.b_dmg = self.b_dmg + amount
		self.b_amt = self.b_amt + 1
	end

	if (absorbed and absorbed > 0) then
		self.a_dmg = self.a_dmg + amount
		self.a_amt = self.a_amt + 1
	end

	if (glacing) then
		self.g_dmg = self.g_dmg + amount
		self.g_amt = self.g_amt + 1

	elseif (critical) then
		self.c_total = self.c_total + amount
		self.c_amt = self.c_amt + 1
		if (amount > self.c_max) then
			self.c_max = amount
		end
		if (self.c_min > amount or self.c_min == 0) then
			self.c_min = amount
		end

	else
		self.n_total = self.n_total + amount
		self.n_amt = self.n_amt + 1
		if (amount > self.n_max) then
			self.n_max = amount
		end
		if (self.n_min > amount or self.n_min == 0) then
			self.n_min = amount
		end
	end
end