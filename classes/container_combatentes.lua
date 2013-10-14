local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local combatente =			_detalhes.combatente
local container_combatentes =	_detalhes.container_combatentes
local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
local atributo_damage =	_detalhes.atributo_damage
local atributo_heal =		_detalhes.atributo_heal
local atributo_energy =		_detalhes.atributo_energy
local atributo_misc =		_detalhes.atributo_misc

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

--api locals
local _UnitClass = UnitClass
local _IsInInstance = IsInInstance
--lua locals
local _setmetatable = setmetatable
local _getmetatable = getmetatable
local _bit_band = bit.band
local _ipairs = ipairs
local _pairs = pairs

local _

--local table_insert = table.insert

--> FLAGS <== qual o tipo do objeto
local OBJECT_TYPE_MASK =		0x0000FC00
local OBJECT_TYPE_OBJECT =	0x00004000
local OBJECT_TYPE_PETGUARDIAN =	0x00003000
local OBJECT_TYPE_GUARDIAN =	0x00002000
local OBJECT_TYPE_PET =		0x00001000
local OBJECT_TYPE_NPC =		0x00000800
local OBJECT_TYPE_PLAYER =	0x00000400
local OBJECT_TYPE_PETS = 		OBJECT_TYPE_PET + OBJECT_TYPE_GUARDIAN

local REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE or 0x00000040

function container_combatentes:NovoContainer (tipo_do_container, combatTable, combatId)

	local _newContainer = {
	
		funcao_de_criacao = container_combatentes:FuncaoDeCriacao (tipo_do_container),
		
		tipo = tipo_do_container,
		
		combatId = combatId,
		
		_ActorTable = {},
		_NameIndexTable = {}
	}
	
	_setmetatable (_newContainer, container_combatentes)

	return _newContainer
end

local function get_class_ (novo_objeto, nome, flag)
	local _, engClass = _UnitClass (nome)

	if (engClass) then
		novo_objeto.classe = engClass
		return
	else	
		if (flag) then
			--print ("tem flag: " .. flag)
			--> conferir se o jogador é um player
			if (_bit_band (flag, OBJECT_TYPE_PLAYER) ~= 0) then
				--print ("eh um player sem grupo: "..novo_objeto.nome)
				novo_objeto.classe = "UNGROUPPLAYER"
				return
			elseif (_bit_band (flag, OBJECT_TYPE_PETGUARDIAN) ~= 0) then
				--print ("eh um pet: "..novo_objeto.nome)
				novo_objeto.classe = "PET"
				return
			end
		end
		novo_objeto.classe = "UNKNOW"
		return
	end
end

local EM_GRUPO = 0x00000007

function container_combatentes:Dupe (who)
	local novo_objeto = {}
	if (_getmetatable (who)) then 
		_setmetatable (novo_objeto, _getmetatable (who))
	end
	
	for cprop, value in _pairs (who) do 
		novo_objeto[cprop] = value
	end
	
	return novo_objeto
end

function container_combatentes:GetAmount (actorName, key)
	key = key or "total"
	local index = self._NameIndexTable [actorName]
	if (index) then
		return self._ActorTable [index] [key] or 0
	else
		return 0
	end
end

local read_flag_ = function (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome)
	-- converte a flag do wow em flag do details
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
	
	--> pega afiliação
	local details_flag = 0x00000000

	if (flag) then
		--print ("tem flag")
		
		if (_bit_band (flag, 0x00000400) ~= 0) then --> é um player
			details_flag = details_flag+0x00000001
			
			novo_objeto.displayName = _detalhes:GetNickname (serial, false, true) --> serial, default, silent
			if (not novo_objeto.displayName) then
				if (_IsInInstance() and _detalhes.remove_realm_from_name) then
					novo_objeto.displayName = nome:gsub (("%-.*"), "")
					--print (novo_objeto.displayName)
				else
					novo_objeto.displayName = nome
				end
			end
			
			if (_bit_band (flag, EM_GRUPO) ~= 0) then --> faz parte do grupo
				details_flag = details_flag+0x00000100
				novo_objeto.grupo = true
				if (shadow_objeto) then
					shadow_objeto.grupo = true
				end
			end
			
		elseif (dono_do_pet) then --> é um pet
		
			details_flag = details_flag+0x00000002
			novo_objeto.owner = dono_do_pet
			novo_objeto.ownerName = dono_do_pet.nome
			
			if (_IsInInstance() and _detalhes.remove_realm_from_name) then
				novo_objeto.displayName = nome:gsub (("%-.*"), ">")
			else
				novo_objeto.displayName = nome
			end
			
			--if (not novo_objeto.displayName:find (">")) then
			--	novo_objeto.displayName = novo_objeto.displayName .. ">"
			--end
			
			--print ("pet -> " .. nome)
		else
			novo_objeto.displayName = nome
		end
		
		-- 0x00000060 --> inimigo neutro
		if (_bit_band (flag, 0x00000010) ~= 0) then --> é amigo
			details_flag = details_flag+0x00000010
		elseif (_bit_band (flag, 0x00000020) ~= 0) then --> é neutro
			details_flag = details_flag+0x00000020
			--print ("neutro -> " .. nome)
		elseif (_bit_band (flag, 0x00000040) ~= 0) then --> é inimigo
			details_flag = details_flag+0x00000040
			--print ("inimigos -> " .. nome)
		end
	else
		--print (flag)
	end
	
	novo_objeto.flag = details_flag
	novo_objeto.flag_original = flag
	novo_objeto.serial = serial
end

function container_combatentes:PegarCombatente (serial, nome, flag, criar, isOwner)

	--> antes de mais nada, vamos verificar se é um pet
	local dono_do_pet
	if (flag and _bit_band (flag, OBJECT_TYPE_PETS) ~= 0) then --> é um pet
	
		--> aqui ele precisaria achar as tag < > pra saber se o nome passado já não veio com o dono imbutido
		--> se não tiver as tags, terá que ser posto aqui
		if (not nome:find ("<") or not nome:find (">")) then --> find é lento, não teria outra forma de fazer isso?
		
			local nome_dele, dono_nome, dono_serial, dono_flag = _detalhes.tabela_pets:PegaDono (serial, nome, flag)
			
			if (nome_dele) then
			
				nome = nome_dele
				--if (_detalhes.debug) then
				--	print ("creating actor for pet:", nome, "owner:", dono_nome)
				--end
				
				--> e se olharmos no cache do parser antes de tentar cria-lo?
				
				dono_do_pet = self:PegarCombatente (dono_serial, dono_nome, dono_flag, true, nome)
				
			end
		end
	end

	local index = self._NameIndexTable [nome] --> pega o index no mapa
	if (index) then
		return self._ActorTable [index], dono_do_pet, nome
		
	elseif (criar) then

	-- rotinas de criação do objeto shadow
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local shadow = self.shadow --> espelho do container no overall
		local shadow_objeto

		if (shadow) then --> se tiver o espelho (não for a tabela overall já)
			shadow_objeto = shadow:PegarCombatente (_, nome) --> apenas verifica se ele existe ou não
			if (not shadow_objeto) then --> se não existir, cria-lo
				local novo_nome = nome:gsub ((" <.*"), "") --> tira o nome do pet
				shadow_objeto = shadow:PegarCombatente (serial, novo_nome, flag, true)
			end
		end

		local novo_objeto = self.funcao_de_criacao (_, serial, nome, shadow_objeto) --> shadow_objeto passa para o classe_damage gravar no .targets e .spell_tables, mas não grava nele mesmo
		
		novo_objeto.nome = nome
		--print (nome)
		
	-- tipo do container
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

		--if (self.tipo == container_playernpc) then --> CONTAINER COMUM
		
		if (self.tipo == container_damage) then --> CONTAINER DAMAGE

			get_class_ (novo_objeto, nome, flag)
			read_flag_ (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome)
			
			if (dono_do_pet) then
				dono_do_pet.pets [#dono_do_pet.pets+1] = nome
			end
			
			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				novo_objeto:CriaLink (shadow_objeto) --> criando o link
				shadow_objeto.flag = details_flag
				if (novo_objeto.grupo and _detalhes.in_combat) then
					_detalhes.cache_damage_group [#_detalhes.cache_damage_group+1] = novo_objeto
				end
			end
			
			if (novo_objeto.classe == "UNGROUPPLAYER") then --> is a player
				if (_bit_band (flag, REACTION_HOSTILE ) ~= 0) then --> is hostile
					novo_objeto.enemy = true 
				end
				
				--> try to guess his class
				if (shadow) then --> não executar 2x
					_detalhes:ScheduleTimer ("GuessClass", 1, {novo_objeto, self, 1})
				end
			end
			
			
		elseif (self.tipo == container_heal) then --> CONTAINER HEALING
			
			get_class_ (novo_objeto, nome, flag)
			read_flag_ (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome)
			
			if (dono_do_pet) then
				dono_do_pet.pets [#dono_do_pet.pets+1] = nome
			end
			
			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				novo_objeto:CriaLink (shadow_objeto)  --> criando o link
				shadow_objeto.flag = details_flag
				if (novo_objeto.grupo and _detalhes.in_combat) then
					_detalhes.cache_healing_group [#_detalhes.cache_healing_group+1] = novo_objeto
				end
			end
			
			if (novo_objeto.classe == "UNGROUPPLAYER") then --> is a player
				if (_bit_band (flag, REACTION_HOSTILE ) ~= 0) then --> is hostile
					novo_objeto.enemy = true --print (nome.." EH UM INIMIGO -> " .. engRace)
				end
				
				--> try to guess his class
				if (shadow) then --> não executar 2x
					_detalhes:ScheduleTimer ("GuessClass", 1, {novo_objeto, self, 1})
				end
			end
			
			
		elseif (self.tipo == container_energy) then --> CONTAINER ENERGY
			
			get_class_ (novo_objeto, nome, flag)
			read_flag_ (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome)
			
			if (dono_do_pet) then
				dono_do_pet.pets [#dono_do_pet.pets+1] = nome
			end
			
			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				novo_objeto:CriaLink (shadow_objeto)  --> criando o link
				shadow_objeto.flag = details_flag
			end
			
			if (novo_objeto.classe == "UNGROUPPLAYER") then --> is a player
				if (_bit_band (flag, REACTION_HOSTILE ) ~= 0) then --> is hostile
					novo_objeto.enemy = true --print (nome.." EH UM INIMIGO -> " .. engRace)
				end
				
				--> try to guess his class
				if (shadow) then --> não executar 2x
					_detalhes:ScheduleTimer ("GuessClass", 1, {novo_objeto, self, 1})
				end
			end
			
		elseif (self.tipo == container_misc) then --> CONTAINER MISC
			
			get_class_ (novo_objeto, nome, flag)
			read_flag_ (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome)
			
			--local teste_classe = 
			
			if (dono_do_pet) then
				dono_do_pet.pets [#dono_do_pet.pets+1] = nome
			end
			
			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				novo_objeto:CriaLink (shadow_objeto)  --> criando o link
				shadow_objeto.flag = details_flag
			end
			
			if (novo_objeto.classe == "UNGROUPPLAYER") then --> is a player
				if (_bit_band (flag, REACTION_HOSTILE ) ~= 0) then --> is hostile
					novo_objeto.enemy = true --print (nome.." EH UM INIMIGO -> " .. engRace)
				end
				
				--> try to guess his class
				if (shadow) then --> não executar 2x
					_detalhes:ScheduleTimer ("GuessClass", 1, {novo_objeto, self, 1})
				end
			end
		
		elseif (self.tipo == container_damage_target) then --> CONTAINER ALVO DO DAMAGE
			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				--shadow_objeto.flag = details_flag
			end
		
		elseif (self.tipo == container_heal_target) then --> CONTAINER ALVOS DO HEALING
			novo_objeto.overheal = 0
			novo_objeto.absorbed = 0
			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				--shadow_objeto.flag = details_flag
			end
			
		elseif (self.tipo == container_energy_target) then --> CONTAINER ALVOS DO ENERGY
		
			novo_objeto.mana = 0
			novo_objeto.e_rage = 0
			novo_objeto.e_energy = 0
			novo_objeto.runepower = 0
			
			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				--shadow_objeto.flag = details_flag
			end
			
		elseif (self.tipo == container_misc_target) then --> CONTAINER ALVOS DO MISC

			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				--shadow_objeto.flag = details_flag
			end
			
		elseif (self.tipo == container_friendlyfire) then --> CONTAINER FRIENDLY FIRE
			
			get_class_ (novo_objeto, nome)
			
			if (shadow_objeto) then
				novo_objeto.shadow = shadow_objeto
				shadow_objeto.flag = details_flag
			end
		end
	
	-- grava o objeto no mapa do container
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

		--[[
		if (self.tipo == container_damage) then
			if (nome:find ("Lyl")) then
				if (nome:find ("-"))  then
					print ("nome FIM com -", isOwner)
				else
					--print ("nome FIM okey", isOwner)
				end
			end
		end
		--]]

		local size = #self._ActorTable+1
		self._ActorTable [size] = novo_objeto --> grava na tabela de indexes
		self._NameIndexTable [nome] = size --> grava no hash map o index deste jogador

		return novo_objeto, dono_do_pet, nome
	else
		return nil, nil, nil
	end
end

function container_combatentes:FuncaoDeCriacao (tipo)
	if (tipo == container_damage_target) then
		return alvo_da_habilidade.NovaTabela
		
	elseif (tipo == container_damage) then
		return atributo_damage.NovaTabela
		
	elseif (tipo == container_heal_target) then
		return alvo_da_habilidade.NovaTabela
		
	elseif (tipo == container_heal) then
		return atributo_heal.NovaTabela
		
	elseif (tipo == container_friendlyfire) then
		return atributo_damage.FF_funcao_de_criacao
		
	elseif (tipo == container_energy) then
		return atributo_energy.NovaTabela
		
	elseif (tipo == container_energy_target) then
		return alvo_da_habilidade.NovaTabela
		
	elseif (tipo == container_misc) then
		return atributo_misc.NovaTabela
		
	elseif (tipo == container_misc_target) then
		return alvo_da_habilidade.NovaTabela
		
	end
end

function container_combatentes:remapear()
	local mapa = self._NameIndexTable
	local conteudo = self._ActorTable
	for i = 1, #conteudo do
		mapa [conteudo[i].nome] = i
	end
end

local function ReparaMapa (tabela)
	local mapa = {}
	for i = 1, #tabela._ActorTable do
		mapa [tabela._ActorTable[i].nome] = i
	end
	tabela._NameIndexTable = mapa
end

function _detalhes.refresh:r_container_combatentes (container, shadow)
	_setmetatable (container, _detalhes.container_combatentes)
	container.__index = _detalhes.container_combatentes
	container.funcao_de_criacao = container_combatentes:FuncaoDeCriacao (container.tipo)
	ReparaMapa (container)
	
	if (shadow ~= -1) then
		container.shadow = shadow
	end
end

function _detalhes.clear:c_container_combatentes (container)
	container.__index = {}
	container.shadow = nil
	container._NameIndexTable = nil
	container.need_refresh = nil
	container.funcao_de_criacao = nil
end