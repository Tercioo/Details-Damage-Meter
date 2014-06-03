-- heal ability file

	local _detalhes = 		_G._detalhes
	local _

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _setmetatable = setmetatable --lua local
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local alvo_da_habilidade	=	_detalhes.alvo_da_habilidade
	local habilidade_cura		=	_detalhes.habilidade_cura
	local container_combatentes =	_detalhes.container_combatentes
	local container_heal_target	=	_detalhes.container_type.CONTAINER_HEALTARGET_CLASS
	local container_playernpc	=	_detalhes.container_type.CONTAINER_PLAYERNPC

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internals

	function habilidade_cura:NovaTabela (id, link)

		local _newHealSpell = {
		
			total = 0, 
			totalabsorb = 0,
			counter = 0,
			id = id,

			--> normal hits		
			n_min = 0,
			n_max = 0,
			n_amt = 0,
			n_curado = 0,
			
			--> critical hits 		
			c_min = 0,
			c_max = 0,
			c_amt = 0,
			c_curado = 0,

			absorbed = 0,
			overheal = 0,
			
			targets = container_combatentes:NovoContainer (container_heal_target)
		}
		
		_setmetatable (_newHealSpell, habilidade_cura)
		
		if (link) then
			_newHealSpell.targets.shadow = link.targets
		end
		
		return _newHealSpell
	end

	function habilidade_cura:Add (serial, nome, flag, amount, who_nome, absorbed, critical, overhealing, is_shield)

		self.counter = self.counter + 1

		local alvo = self.targets._NameIndexTable [nome]
		if (not alvo) then
			alvo = self.targets:PegarCombatente (serial, nome, flag, true)
		else
			alvo = self.targets._ActorTable [alvo]
		end

		if (absorbed and absorbed > 0) then
			self.absorbed = self.absorbed + absorbed
			alvo.absorbed = alvo.absorbed + absorbed
		end
		
		if (overhealing and overhealing > 0) then
			self.overheal = self.overheal + overhealing
			alvo.overheal = alvo.overheal + overhealing
		end
		
		if (amount and amount > 0) then

			self.total = self.total + amount
			alvo.total = alvo.total + amount
			
			if (is_shield) then
				self.totalabsorb = self.totalabsorb + amount
			end

			if (critical) then
				self.c_curado = self.c_curado+amount --> amount é o total de dano
				self.c_amt = self.c_amt+1 --> amount é o total de dano
				if (amount > self.c_max) then
					self.c_max = amount
				end
				if (self.c_min > amount or self.c_min == 0) then
					self.c_min = amount
				end
			else
				self.n_curado = self.n_curado+amount
				self.n_amt = self.n_amt+1
				if (amount > self.n_max) then
					self.n_max = amount
				end
				if (self.n_min > amount or self.n_min == 0) then
					self.n_min = amount
				end
			end
		end

	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function _detalhes.refresh:r_habilidade_cura (habilidade, shadow)
		_setmetatable (habilidade, habilidade_cura)
		habilidade.__index = habilidade_cura
		
		if (shadow ~= -1) then
			habilidade.shadow = shadow._ActorTable[habilidade.id]
			_detalhes.refresh:r_container_combatentes (habilidade.targets, habilidade.shadow.targets)
		else
			_detalhes.refresh:r_container_combatentes (habilidade.targets, -1)
		end
	end

	function _detalhes.clear:c_habilidade_cura (habilidade)
		--habilidade.__index = {}
		habilidade.__index = nil
		habilidade.shadow = nil
		
		_detalhes.clear:c_container_combatentes (habilidade.targets)
	end

	habilidade_cura.__sub = function (tabela1, tabela2)
		tabela1.total = tabela1.total - tabela2.total
		tabela1.totalabsorb = tabela1.totalabsorb - tabela2.totalabsorb
		tabela1.counter = tabela1.counter - tabela2.counter

		tabela1.n_min = tabela1.n_min - tabela2.n_min
		tabela1.n_max = tabela1.n_max - tabela2.n_max
		tabela1.n_amt = tabela1.n_amt - tabela2.n_amt
		tabela1.n_curado = tabela1.n_curado - tabela2.n_curado

		tabela1.c_min = tabela1.c_min - tabela2.c_min
		tabela1.c_max = tabela1.c_max - tabela2.c_max
		tabela1.c_amt = tabela1.c_amt - tabela2.c_amt
		tabela1.c_curado = tabela1.c_curado - tabela2.c_curado

		tabela1.absorbed = tabela1.absorbed - tabela2.absorbed
		tabela1.overheal = tabela1.overheal - tabela2.overheal
		
		return tabela1
	end
