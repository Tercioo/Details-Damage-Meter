local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
local habilidade_energy = 	_detalhes.habilidade_e_energy
local container_combatentes =	_detalhes.container_combatentes
local container_energy_target = _detalhes.container_type.CONTAINER_ENERGYTARGET_CLASS

--lua locals
local _setmetatable = setmetatable
local _ipairs = ipairs
--api locals
local _UnitAura = UnitAura
--local _GetSpellInfo = _detalhes.getspellinfo

local container_playernpc = _detalhes.container_type.CONTAINER_PLAYERNPC

--id, nome, type, miss, dano, cura, overkill, school, resisted, blocked, absorbed, critico, glacing, crushing
function habilidade_energy:NovaTabela (id, link, token) --aqui eu não sei que parâmetros passar
	local esta_tabela = {}
	_setmetatable (esta_tabela, habilidade_energy)

	esta_tabela.quem_sou = "classe_energy_habilidade"
	esta_tabela.id = id
	esta_tabela.counter = 0
	
	esta_tabela.mana = 0
	esta_tabela.e_rage = 0
	esta_tabela.e_energy = 0
	esta_tabela.runepower = 0
	
	esta_tabela.targets = container_combatentes:NovoContainer (container_energy_target)
	
	if (link) then
		esta_tabela.targets.shadow = link.targets
	end
	
	return esta_tabela
end

function habilidade_energy:Add (serial, nome, flag, amount, who_nome, powertype)

	self.counter = self.counter + 1

	--local alvo = self.targets:PegarCombatente (serial, nome, flag, true)
	local alvo = self.targets._NameIndexTable [nome]
	if (not alvo) then
		alvo = self.targets:PegarCombatente (serial, nome, flag, true)
	else
		alvo = self.targets._ActorTable [alvo]
	end

	
	if (powertype == 0) then --> MANA
		self.mana = self.mana + amount
		alvo.mana = alvo.mana + amount
	elseif (powertype == 1) then --> e_rage
		self.e_rage = self.e_rage + amount
		alvo.e_rage = alvo.e_rage + amount
	elseif (powertype == 3) then --> ENERGIA
		self.e_energy = self.e_energy + amount
		alvo.e_energy = alvo.e_energy + amount
	elseif (powertype == 6) then --> RUNEPOWER
		self.runepower = self.runepower + amount
		alvo.runepower = alvo.runepower + amount
	end

	if (self.shadow) then
		return self.shadow:Add (serial, nome, flag, amount, who_nome, powertype)
	end
end

function _detalhes.refresh:r_habilidade_e_energy (habilidade, shadow) --recebeu o container shadow
	_setmetatable (habilidade, habilidade_energy)
	habilidade.__index = habilidade_energy
	
	if (shadow ~= -1) then
		habilidade.shadow = shadow._ActorTable[habilidade.id]
		_detalhes.refresh:r_container_combatentes (habilidade.targets, habilidade.shadow.targets)
	else
		_detalhes.refresh:r_container_combatentes (habilidade.targets, -1)
	end
end

function _detalhes.clear:c_habilidade_e_energy (habilidade)
	habilidade.__index = {}
	habilidade.shadow = nil
	
	_detalhes.clear:c_container_combatentes (habilidade.targets)
end

habilidade_energy.__sub = function (tabela1, tabela2)

	tabela1.mana = tabela1.mana - tabela2.mana
	tabela1.e_rage = tabela1.e_rage - tabela2.e_rage
	tabela1.e_energy = tabela1.e_energy - tabela2.e_energy
	tabela1.runepower = tabela1.runepower - tabela2.runepower
	
	tabela1.counter = tabela1.counter - tabela2.counter

	return tabela1
end
