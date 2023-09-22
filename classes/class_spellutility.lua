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

	---@param spellTable spelltable
	---@param targetName string
	---@param token string|actor
	---@param spellId number
	---@param parserToken string
	function classUtility.Add(spellTable, targetName, token, spellId, parserToken, tempoOverrided)
		--as the passed parameters for aura are different from the reset of the abilities, this should be a different function
		if (spellId == "BUFF_OR_DEBUFF") then
			local actorUtilityObject = token
			local _tempo = tempoOverrided or _detalhes._tempo

			if (parserToken == "COOLDOWN") then
				spellTable.counter = spellTable.counter + 1
				spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1

			elseif (parserToken == "BUFF_UPTIME_REFRESH") then
				if (spellTable.actived_at and spellTable.actived) then
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					spellTable.refreshamt = spellTable.refreshamt + 1
					actorUtilityObject.buff_uptime = actorUtilityObject.buff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.actived_at = _tempo
				spellTable.actived = true

			elseif (parserToken == "BUFF_UPTIME_OUT") then
				if (spellTable.actived_at and spellTable.actived) then
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					actorUtilityObject.buff_uptime = actorUtilityObject.buff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.actived = false
				spellTable.actived_at = nil

			elseif (parserToken == "BUFF_UPTIME_IN" or parserToken == "DEBUFF_UPTIME_IN") then
				--aura applied
				spellTable.actived = true
				spellTable.activedamt = spellTable.activedamt + 1
				spellTable.appliedamt = spellTable.appliedamt + 1

				if (spellTable.actived_at and spellTable.actived and parserToken == "DEBUFF_UPTIME_IN") then
					--ja esta ativo em outro mob e jogou num novo
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.actived_at = _tempo

				if (not spellTable.uptime) then
					spellTable.uptime = 0
				end

			elseif (parserToken == "DEBUFF_UPTIME_REFRESH") then
				if (spellTable.actived_at and spellTable.actived) then
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					spellTable.refreshamt = spellTable.refreshamt + 1
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.actived_at = _tempo
				spellTable.actived = true

			elseif (parserToken == "DEBUFF_UPTIME_OUT") then
				if (spellTable.actived_at and spellTable.actived) then
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.activedamt = spellTable.activedamt - 1

				if (spellTable.activedamt == 0) then
					spellTable.actived = false
					spellTable.actived_at = nil
				else
					spellTable.actived_at = _tempo
				end
			end

		elseif (token == "SPELL_INTERRUPT") then
			spellTable.counter = spellTable.counter + 1

			if (not spellTable.interrompeu_oque[spellId]) then
				spellTable.interrompeu_oque[spellId] = 1
			else
				spellTable.interrompeu_oque[spellId] = spellTable.interrompeu_oque[spellId] + 1
			end

			--target
			spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1

		elseif (token == "SPELL_RESURRECT") then
			spellTable.ress = (spellTable.ress or 0) + 1
			--target
			spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1

		elseif (token == "SPELL_DISPEL" or token == "SPELL_STOLEN") then
			spellTable.dispell = (spellTable.dispell or 0) + 1

			if (not spellTable.dispell_oque[spellId]) then
				spellTable.dispell_oque[spellId] = 1
			else
				spellTable.dispell_oque[spellId] = spellTable.dispell_oque[spellId] + 1
			end

			--target
			spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1

		elseif (token == "SPELL_AURA_BROKEN_SPELL" or token == "SPELL_AURA_BROKEN") then
			spellTable.cc_break = (spellTable.cc_break or 0) + 1

			if (not spellTable.cc_break_oque[spellId]) then
				spellTable.cc_break_oque[spellId] = 1
			else
				spellTable.cc_break_oque[spellId] = spellTable.cc_break_oque[spellId] + 1
			end

			--target
			spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1
		end
	end