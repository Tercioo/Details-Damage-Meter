local _detalhes = 		_G._detalhes
--local gump = 			_detalhes.gump

local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
local habilidade_misc = 		_detalhes.habilidade_misc
local container_combatentes =	_detalhes.container_combatentes
local container_misc_target = 	_detalhes.container_type.CONTAINER_MISCTARGET_CLASS

--lua locals
local _
local _setmetatable = setmetatable
local _ipairs = ipairs
--api locals
local _UnitAura = UnitAura

local container_playernpc = _detalhes.container_type.CONTAINER_PLAYERNPC

function habilidade_misc:NovaTabela (id, link, token) --aqui eu não sei que parâmetros passar

	local _newMiscSpell = {
		id = id,
		counter = 0,
		targets = container_combatentes:NovoContainer (container_misc_target)
	}
	
	if (token == "BUFF_UPTIME" or token == "DEBUFF_UPTIME") then
		_newMiscSpell.uptime = 0
		_newMiscSpell.actived = false
		_newMiscSpell.activedamt = 0
	elseif (token == "SPELL_INTERRUPT") then
		_newMiscSpell.interrompeu_oque = {}
	elseif (token == "SPELL_DISPEL" or token == "SPELL_STOLEN") then
		_newMiscSpell.dispell_oque = {}
	elseif (token == "SPELL_AURA_BROKEN" or token == "SPELL_AURA_BROKEN_SPELL") then
		_newMiscSpell.cc_break_oque = {}
	end	

	_setmetatable (_newMiscSpell, habilidade_misc)
	
	if (link) then
		_newMiscSpell.targets.shadow = link.targets
	end
	
	return _newMiscSpell
end

function habilidade_misc:Add (serial, nome, flag, who_nome, token, spellID, spellName)

	--alvo:AddQuantidade (1)
	if (spellID == "BUFF_OR_DEBUFF") then
		
		if (spellName == "COOLDOWN") then
			self.counter = self.counter + 1
			
			--> alvo
			local alvo = self.targets._NameIndexTable [nome]
			if (not alvo) then
				alvo = self.targets:PegarCombatente (serial, nome, flag, true)
			else
				alvo = self.targets._ActorTable [alvo]
			end
			alvo.total = alvo.total + 1
			
		elseif (spellName == "BUFF_UPTIME_REFRESH") then
			if (self.actived_at and self.actived) then
				self.uptime = self.uptime + _detalhes._tempo - self.actived_at
				token.buff_uptime = token.buff_uptime + _detalhes._tempo - self.actived_at --> token = actor misc object
				
			end
			self.actived_at = _detalhes._tempo
			self.actived = true
			
			if (self.shadow) then
				return self.shadow:Add (serial, nome, flag, who_nome, token.shadow, spellID, spellName)
			end
			
		elseif (spellName == "BUFF_UPTIME_OUT") then	
			if (self.actived_at and self.actived) then
				self.uptime = self.uptime + _detalhes._tempo - self.actived_at
				token.buff_uptime = token.buff_uptime + _detalhes._tempo - self.actived_at --> token = actor misc object
			end
			self.actived = false
			self.actived_at = nil
			
			if (self.shadow) then
				return self.shadow:Add (serial, nome, flag, who_nome, token.shadow, spellID, spellName)
			end
			
		elseif (spellName == "BUFF_UPTIME_IN" or spellName == "DEBUFF_UPTIME_IN") then
			self.actived = true
			self.activedamt = self.activedamt + 1
			
			if (self.actived_at and self.actived and spellName == "DEBUFF_UPTIME_IN") then
				--> ja esta ativo em outro mob e jogou num novo
				self.uptime = self.uptime + _detalhes._tempo - self.actived_at
				token.debuff_uptime = token.debuff_uptime + _detalhes._tempo - self.actived_at
			end
			
			self.actived_at = _detalhes._tempo
			
			if (self.shadow) then
				return self.shadow:Add (serial, nome, flag, who_nome, token.shadow, spellID, spellName)
			end
			
		elseif (spellName == "DEBUFF_UPTIME_REFRESH") then
			if (self.actived_at and self.actived) then
				self.uptime = self.uptime + _detalhes._tempo - self.actived_at
				token.debuff_uptime = token.debuff_uptime + _detalhes._tempo - self.actived_at
			end
			self.actived_at = _detalhes._tempo
			self.actived = true
			
			if (self.shadow) then
				return self.shadow:Add (serial, nome, flag, who_nome, token.shadow, spellID, spellName)
			end

		elseif (spellName == "DEBUFF_UPTIME_OUT") then	
			if (self.actived_at and self.actived) then
				self.uptime = self.uptime + _detalhes._tempo - self.actived_at
				token.debuff_uptime = token.debuff_uptime + _detalhes._tempo - self.actived_at --> token = actor misc object
			end
			
			self.activedamt = self.activedamt - 1
			
			if (self.activedamt == 0) then
				self.actived = false
				self.actived_at = nil
			else
				self.actived_at = _detalhes._tempo
			end
			
			if (self.shadow) then
				return self.shadow:Add (serial, nome, flag, who_nome, token.shadow, spellID, spellName)
			end

		end
		
	elseif (token == "SPELL_INTERRUPT") then
		self.counter = self.counter + 1

		if (not self.interrompeu_oque [spellID]) then --> interrompeu_oque a NIL value
			self.interrompeu_oque [spellID] = 1
		else
			self.interrompeu_oque [spellID] = self.interrompeu_oque [spellID] + 1
		end
		
		--alvo
		local alvo = self.targets._NameIndexTable [nome]
		if (not alvo) then
			alvo = self.targets:PegarCombatente (serial, nome, flag, true)
		else
			alvo = self.targets._ActorTable [alvo]
		end
		alvo.total = alvo.total + 1		
	
	elseif (token == "SPELL_RESURRECT") then
		if (not self.ress) then
			self.ress = 1
		else
			self.ress = self.ress + 1
		end
		
		--alvo
		local alvo = self.targets._NameIndexTable [nome]
		if (not alvo) then
			alvo = self.targets:PegarCombatente (serial, nome, flag, true)
		else
			alvo = self.targets._ActorTable [alvo]
		end
		alvo.total = alvo.total + 1		
		
		
	elseif (token == "SPELL_DISPEL" or token == "SPELL_STOLEN") then
		if (not self.dispell) then
			self.dispell = 1
		else
			self.dispell = self.dispell + 1
		end
		
		if (not self.dispell_oque [spellID]) then
			self.dispell_oque [spellID] = 1
		else
			self.dispell_oque [spellID] = self.dispell_oque [spellID] + 1
		end

		--alvo
		local alvo = self.targets._NameIndexTable [nome]
		if (not alvo) then
			alvo = self.targets:PegarCombatente (serial, nome, flag, true)
		else
			alvo = self.targets._ActorTable [alvo]
		end
		alvo.total = alvo.total + 1		
		
		
	elseif (token == "SPELL_AURA_BROKEN_SPELL" or token == "SPELL_AURA_BROKEN") then
	
		if (not self.cc_break) then
			self.cc_break = 1
		else
			self.cc_break = self.cc_break + 1
		end
		
		if (not self.cc_break_oque [spellID]) then
			self.cc_break_oque [spellID] = 1
		else
			self.cc_break_oque [spellID] = self.cc_break_oque [spellID] + 1
		end
		
		--alvo
		local alvo = self.targets._NameIndexTable [nome]
		if (not alvo) then
			alvo = self.targets:PegarCombatente (serial, nome, flag, true)
		else
			alvo = self.targets._ActorTable [alvo]
		end
		alvo.total = alvo.total + 1
	end

	if (self.shadow) then
		return self.shadow:Add (serial, nome, flag, who_nome, token, spellID, spellName)
	end
	
end

--> habilidade atual e o container de habilidades da shadow
function _detalhes.refresh:r_habilidade_misc (habilidade, shadow) --recebeu o container shadow
	_setmetatable (habilidade, habilidade_misc)
	habilidade.__index = habilidade_misc
	
	if (shadow ~= -1) then
		habilidade.shadow = shadow._ActorTable[habilidade.id]
		_detalhes.refresh:r_container_combatentes (habilidade.targets, habilidade.shadow.targets)
	else
		_detalhes.refresh:r_container_combatentes (habilidade.targets, -1)
	end
end

function _detalhes.clear:c_habilidade_misc (habilidade)
	--habilidade.__index = {}
	habilidade.__index = nil
	habilidade.shadow = nil
	
	_detalhes.clear:c_container_combatentes (habilidade.targets)
end

habilidade_misc.__sub = function (tabela1, tabela2)

	--interrupts & cooldowns
	tabela1.counter = tabela1.counter - tabela2.counter
	
	--buff uptime ou debuff uptime
	if (tabela1.uptime and tabela2.uptime) then
		tabela1.uptime = tabela1.uptime - tabela2.uptime
	end
	
	--ressesrs
	if (tabela1.ress and tabela2.ress) then
		tabela1.ress = tabela1.ress - tabela2.ress
	end
	
	--dispells
	if (tabela1.dispell and tabela2.dispell) then
		tabela1.dispell = tabela1.dispell - tabela2.dispell
	end
	
	--cc_breaks
	if (tabela1.cc_break and tabela2.cc_break) then
		tabela1.cc_break = tabela1.cc_break - tabela2.cc_break
	end

	return tabela1
end
