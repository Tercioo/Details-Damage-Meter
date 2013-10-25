local _detalhes = 		_G._detalhes
--local AceLocale = LibStub ("AceLocale-3.0")
--local Loc = AceLocale:GetLocale ( "Details" )

local gump = 			_detalhes.gump

local _setmetatable = setmetatable
local _

local container_playernpc = _detalhes.container_type.CONTAINER_PLAYERNPC
local container_damage = _detalhes.container_type.CONTAINER_DAMAGE_CLASS
local container_heal = _detalhes.container_type.CONTAINER_HEAL_CLASS
local container_heal_target = _detalhes.container_type.CONTAINER_HEALTARGET_CLASS
local container_friendlyfire = _detalhes.container_type.CONTAINER_FRIENDLYFIRE
local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS
local container_energy = _detalhes.container_type.CONTAINER_ENERGY_CLASS
local container_energy_target = _detalhes.container_type.CONTAINER_ENERGYTARGET_CLASS
local container_misc = _detalhes.container_type.CONTAINER_MISC_CLASS
local container_misc_target = _detalhes.container_type.CONTAINER_MISCTARGET_CLASS

local habilidade_dano = 	_detalhes.habilidade_dano
local habilidade_cura = 		_detalhes.habilidade_cura
local habilidade_e_energy = 	_detalhes.habilidade_e_energy
local habilidade_misc = 		_detalhes.habilidade_misc

local container_habilidades = 	_detalhes.container_habilidades

function container_habilidades:NovoContainer (tipo_do_container)

	local _newContainer = {
		funcao_de_criacao = container_habilidades:FuncaoDeCriacao (tipo_do_container),
		tipo = tipo_do_container,
		_ActorTable = {}
	}
	
	_setmetatable (_newContainer, container_habilidades)
	
	return _newContainer
end

function container_habilidades:Dupe (who)
	local novo_objeto = {}
	if (_getmetatable (who)) then 
		_setmetatable (novo_objeto, _getmetatable (who))
	end
	
	for cprop, value in _pairs (who) do 
		novo_objeto[cprop] = value
	end
	
	return novo_objeto
end

function container_habilidades:GetSpell (id)
	return self._ActorTable [id]
end

function container_habilidades:PegaHabilidade (id, criar, token, cria_shadow)
	local esta_habilidade = self._ActorTable [id]
	if (esta_habilidade) then
		return esta_habilidade
	else
		if (criar) then
		
			if (cria_shadow) then 
				local novo_objeto = self.funcao_de_criacao (nil, id, nil, "")
				self._ActorTable [id] = novo_objeto
				return novo_objeto
			end
			
			local shadow = self.shadow --> retorna o container semelhante a esta na tabela overall
			local shadow_objeto = nil
			
			if (shadow) then --> talvez possa mandar todos os parâmetros de criação logo no inicio
				shadow_objeto = shadow:PegaHabilidade (id) --> apenas verifica se ele existe ou não
				if (not shadow_objeto) then --> se não existir, cria-lo
					shadow_objeto = shadow:PegaHabilidade (id, true, token)
				end
			end
			
			--local novo_objeto = habilidade_dano:NovaTabela (id, shadow_objeto)
			local novo_objeto = self.funcao_de_criacao (nil, id, shadow_objeto, token)
			
			if (shadow_objeto) then --> link é esta mesma tabela mas no container do overall
				novo_objeto.shadow = shadow_objeto --> diz ao objeto qual a shadow dele na tabela overall
				--novo_objeto:CriaLink (shadow_objeto) --> cria o link entre o objeto e a sua shadow
			end
		
			self._ActorTable [id] = novo_objeto
			
			return novo_objeto
		else
			return nil
		end
	end
end

function container_habilidades:FuncaoDeCriacao (tipo)
	if (tipo == container_damage) then
		return habilidade_dano.NovaTabela
		
	elseif (tipo == container_heal) then
		return habilidade_cura.NovaTabela

	elseif (tipo == container_energy) then
		return habilidade_e_energy.NovaTabela
		
	elseif (tipo == container_misc) then
		return habilidade_misc.NovaTabela
		
	end
end

function _detalhes.refresh:r_container_habilidades (container, shadow)
	_setmetatable (container, _detalhes.container_habilidades)
	container.__index = _detalhes.container_habilidades
	local func_criacao = container_habilidades:FuncaoDeCriacao (container.tipo)
	container.funcao_de_criacao = func_criacao
	
	if (shadow ~= -1) then
		container.shadow = shadow
	end
end

function _detalhes.clear:c_container_habilidades (container)
	--container.__index = {}
	container.__index = nil
	container.shadow = nil
	container.funcao_de_criacao = nil
end
