
	local _detalhes = 		_G.Details
	local _
	local addonName, Details222 = ...

	local habilidade_energy	=	_detalhes.habilidade_e_energy

	function habilidade_energy:NovaTabela (id, link, token)
		local newSpellTable = {
			id = id,
			counter = 0,
			total = 0,
			totalover = 0,
			targets = {}
		}
		return newSpellTable
	end

	function habilidade_energy:Add(serial, nome, flag, amount, who_nome, powertype, overpower)
		self.counter = self.counter + 1
		self.total = self.total + amount
		self.totalover = self.totalover + overpower
		self.targets[nome] = (self.targets[nome] or 0) + amount
	end
