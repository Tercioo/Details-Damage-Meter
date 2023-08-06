-- misc ability file
	local _detalhes = 		_G.Details
	local _
	local addonName, Details222 = ...
	local classUtility		=	_detalhes.habilidade_misc

	function classUtility:NovaTabela(id, link, token)
		local spellTable = {
			id = id,
			counter = 0,
			targets = {}
		}

		if (token == "BUFF_UPTIME" or token == "DEBUFF_UPTIME") then
			spellTable.uptime = 0
			spellTable.actived = false
			spellTable.activedamt = 0 --amount of active auras
			spellTable.refreshamt = 0
			spellTable.appliedamt = 0

		elseif (token == "SPELL_INTERRUPT") then
			spellTable.interrompeu_oque = {}

		elseif (token == "SPELL_DISPEL" or token == "SPELL_STOLEN") then
			spellTable.dispell_oque = {}

		elseif (token == "SPELL_AURA_BROKEN" or token == "SPELL_AURA_BROKEN_SPELL") then
			spellTable.cc_break_oque = {}
		end

		return spellTable
	end

	---@param self spelltable
	---@param targetName string
	---@param targetFlags number
	---@param sourceName string
	---@param token string|actor
	---@param spellId number
	---@param spellName string
	function classUtility:Add(targetSerial, targetName, targetFlags, sourceName, token, spellId, spellName)
		--as the passed parameters for aura are different from the reset of the abilities, this should be a different function
		if (spellId == "BUFF_OR_DEBUFF") then
			local actorUtilityObject = token
			local parserToken = spellName

			if (parserToken == "COOLDOWN") then
				self.counter = self.counter + 1
				self.targets[targetName] = (self.targets[targetName] or 0) + 1

			elseif (parserToken == "BUFF_UPTIME_REFRESH") then
				if (self.actived_at and self.actived) then
					self.uptime = self.uptime + (_detalhes._tempo - self.actived_at)
					self.refreshamt = self.refreshamt + 1
					actorUtilityObject.buff_uptime = actorUtilityObject.buff_uptime + (_detalhes._tempo - self.actived_at)
				end

				self.actived_at = _detalhes._tempo
				self.actived = true

			elseif (parserToken == "BUFF_UPTIME_OUT") then
				if (self.actived_at and self.actived) then
					self.uptime = self.uptime + (_detalhes._tempo - self.actived_at)
					actorUtilityObject.buff_uptime = actorUtilityObject.buff_uptime + (_detalhes._tempo - self.actived_at)
				end

				self.actived = false
				self.actived_at = nil

			elseif (parserToken == "BUFF_UPTIME_IN" or parserToken == "DEBUFF_UPTIME_IN") then
				--aura applied
				self.actived = true
				self.activedamt = self.activedamt + 1
				self.appliedamt = self.appliedamt + 1

				if (self.actived_at and self.actived and parserToken == "DEBUFF_UPTIME_IN") then
					--ja esta ativo em outro mob e jogou num novo
					self.uptime = self.uptime + (_detalhes._tempo - self.actived_at)
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_detalhes._tempo - self.actived_at)
				end

				self.actived_at = _detalhes._tempo

				if (not self.uptime) then
					self.uptime = 0
				end

			elseif (parserToken == "DEBUFF_UPTIME_REFRESH") then
				if (self.actived_at and self.actived) then
					self.uptime = self.uptime + (_detalhes._tempo - self.actived_at)
					self.refreshamt = self.refreshamt + 1
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_detalhes._tempo - self.actived_at)
				end

				self.actived_at = _detalhes._tempo
				self.actived = true

			elseif (parserToken == "DEBUFF_UPTIME_OUT") then
				if (self.actived_at and self.actived) then
					self.uptime = self.uptime + (_detalhes._tempo - self.actived_at)
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_detalhes._tempo - self.actived_at)
				end

				self.activedamt = self.activedamt - 1

				if (self.activedamt == 0) then
					self.actived = false
					self.actived_at = nil
				else
					self.actived_at = _detalhes._tempo
				end
			end

		elseif (token == "SPELL_INTERRUPT") then
			self.counter = self.counter + 1

			if (not self.interrompeu_oque[spellId]) then
				self.interrompeu_oque[spellId] = 1
			else
				self.interrompeu_oque[spellId] = self.interrompeu_oque[spellId] + 1
			end

			--target
			self.targets[targetName] = (self.targets[targetName] or 0) + 1

		elseif (token == "SPELL_RESURRECT") then
			self.ress = (self.ress or 0) + 1
			--target
			self.targets[targetName] = (self.targets[targetName] or 0) + 1

		elseif (token == "SPELL_DISPEL" or token == "SPELL_STOLEN") then
			self.dispell = (self.dispell or 0) + 1

			if (not self.dispell_oque[spellId]) then
				self.dispell_oque[spellId] = 1
			else
				self.dispell_oque[spellId] = self.dispell_oque[spellId] + 1
			end

			--target
			self.targets[targetName] = (self.targets[targetName] or 0) + 1

		elseif (token == "SPELL_AURA_BROKEN_SPELL" or token == "SPELL_AURA_BROKEN") then
			self.cc_break = (self.cc_break or 0) + 1

			if (not self.cc_break_oque[spellId]) then
				self.cc_break_oque[spellId] = 1
			else
				self.cc_break_oque[spellId] = self.cc_break_oque[spellId] + 1
			end

			--target
			self.targets[targetName] = (self.targets[targetName] or 0) + 1
		end
	end