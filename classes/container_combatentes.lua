-- actor container file

	local _detalhes = 		_G._detalhes
	local _

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _UnitClass = UnitClass --api local
	local _IsInInstance = IsInInstance --api local
	
	local _setmetatable = setmetatable --lua local
	local _getmetatable = getmetatable --lua local
	local _bit_band = bit.band --lua local
	local _table_sort = table.sort --lua local
	local _ipairs = ipairs --lua local
	local _pairs = pairs --lua local
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local combatente =			_detalhes.combatente
	local container_combatentes =	_detalhes.container_combatentes
	local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
	local atributo_damage =		_detalhes.atributo_damage
	local atributo_heal =			_detalhes.atributo_heal
	local atributo_energy =		_detalhes.atributo_energy
	local atributo_misc =			_detalhes.atributo_misc

	local container_playernpc = 	_detalhes.container_type.CONTAINER_PLAYERNPC
	local container_damage =		_detalhes.container_type.CONTAINER_DAMAGE_CLASS
	local container_heal = 		_detalhes.container_type.CONTAINER_HEAL_CLASS
	local container_heal_target = 	_detalhes.container_type.CONTAINER_HEALTARGET_CLASS
	local container_friendlyfire =	_detalhes.container_type.CONTAINER_FRIENDLYFIRE
	local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS
	local container_energy = 		_detalhes.container_type.CONTAINER_ENERGY_CLASS
	local container_energy_target =	_detalhes.container_type.CONTAINER_ENERGYTARGET_CLASS
	local container_misc = 		_detalhes.container_type.CONTAINER_MISC_CLASS
	local container_misc_target = 	_detalhes.container_type.CONTAINER_MISCTARGET_CLASS
	local container_enemydebufftarget_target = _detalhes.container_type.CONTAINER_ENEMYDEBUFFTARGET_CLASS

	--> flags
	local REACTION_HOSTILE	=	0x00000040
	local IS_GROUP_OBJECT 	= 	0x00000007
	local OBJECT_TYPE_MASK =	0x0000FC00
	local OBJECT_TYPE_OBJECT =	0x00004000
	local OBJECT_TYPE_PETGUARDIAN =	0x00003000
	local OBJECT_TYPE_GUARDIAN =	0x00002000
	local OBJECT_TYPE_PET =		0x00001000
	local OBJECT_TYPE_NPC =		0x00000800
	local OBJECT_TYPE_PLAYER =	0x00000400
	local OBJECT_TYPE_PETS = 	OBJECT_TYPE_PET + OBJECT_TYPE_GUARDIAN

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> api functions

	function container_combatentes:GetAmount (actorName, key)
		key = key or "total"
		local index = self._NameIndexTable [actorName]
		if (index) then
			return self._ActorTable [index] [key] or 0
		else
			return 0
		end
	end
	
	function container_combatentes:GetTotal (key)
		local total = 0
		key = key or "total"
		for _, actor in _ipairs (self._ActorTable) do
			total = total + (actor [key] or 0)
		end
		
		return total
	end
	
	function container_combatentes:GetTotalOnRaid (key, combat)
		local total = 0
		key = key or "total"
		local roster = combat.raid_roster
		for _, actor in _ipairs (self._ActorTable) do
			if (roster [actor.nome]) then
				total = total + (actor [key] or 0)
			end
		end
		
		return total
	end

	function container_combatentes:ListActors()
		return _ipairs (self._ActorTable)
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internals

	--> build a new actor container
	function container_combatentes:NovoContainer (tipo_do_container, combat_table, combat_id)
		local _newContainer = {
			funcao_de_criacao = container_combatentes:FuncaoDeCriacao (tipo_do_container),
			
			tipo = tipo_do_container,
			
			combatId = combat_id,
			
			_ActorTable = {},
			_NameIndexTable = {}
		}
		
		_setmetatable (_newContainer, container_combatentes)

		return _newContainer
	end

	--> try to get the actor class from name
	local function get_actor_class (novo_objeto, nome, flag)
		local _, engClass = _UnitClass (nome)

		if (engClass) then
			novo_objeto.classe = engClass
			return
		else	
			if (flag) then
				--> conferir se o jogador é um player
				if (_bit_band (flag, OBJECT_TYPE_PLAYER) ~= 0) then
					novo_objeto.classe = "UNGROUPPLAYER"
					return
				elseif (_bit_band (flag, OBJECT_TYPE_PETGUARDIAN) ~= 0) then
					novo_objeto.classe = "PET"
					return
				end
			end
			novo_objeto.classe = "UNKNOW"
			return
		end
	end

	--> read the actor flag
	local read_actor_flag = function (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome, container_type)

		if (flag) then

			--> é um player
			if (_bit_band (flag, OBJECT_TYPE_PLAYER) ~= 0) then
			
				novo_objeto.displayName = _detalhes:GetNickname (serial, false, true) --> serial, default, silent
				if (not novo_objeto.displayName) then
					if (_IsInInstance() and _detalhes.remove_realm_from_name) then
						novo_objeto.displayName = nome:gsub (("%-.*"), "")
					else
						novo_objeto.displayName = nome
					end
				end
				
				if ( (_bit_band (flag, IS_GROUP_OBJECT) ~= 0 and novo_objeto.classe ~= "UNGROUPPLAYER")) then --> faz parte do grupo
					novo_objeto.grupo = true

					if (shadow_objeto) then
						shadow_objeto.grupo = true
					end
					
					if (_detalhes:IsATank (serial)) then
						novo_objeto.isTank = true
						if (shadow_objeto) then
							shadow_objeto.isTank = true
						end
					end
				end
				
				if (_detalhes.is_in_arena) then
				
					if (novo_objeto.grupo) then --> is ally
						novo_objeto.arena_ally = true
						
					else --> is enemy
						novo_objeto.arena_enemy = true
						
					end
					
					local arena_props = _detalhes.arena_table [nome]

					if (arena_props) then
						novo_objeto.role = arena_props.role
						
						if (arena_props.role == "NONE") then
							local role = UnitGroupRolesAssigned (nome)
							if (role ~= "NONE") then
								novo_objeto.role = role
							end
						end
					else
						local oponentes = GetNumArenaOpponentSpecs()
						local found = false
						for i = 1, oponentes do
							local name = GetUnitName ("arena" .. i, true)
							if (name == nome) then
								local spec = GetArenaOpponentSpec (i)
								if (spec) then
									local id, name, description, icon, background, role, class = GetSpecializationInfoByID (spec)
									novo_objeto.role = role
									novo_objeto.classe = class
									novo_objeto.enemy = true
									novo_objeto.arena_enemy = true
									found = true
								end
							end
						end
						
						local role = UnitGroupRolesAssigned (nome)
						if (role ~= "NONE") then
							novo_objeto.role = role
							found = true
						end
						
						if (not found and nome == _detalhes.playername) then						
							local role = UnitGroupRolesAssigned ("player")
							if (role ~= "NONE") then
								novo_objeto.role = role
							end
						end
						
					end
				
					novo_objeto.grupo = true
				end
			
			--> é um pet
			elseif (dono_do_pet) then 
				novo_objeto.owner = dono_do_pet
				novo_objeto.ownerName = dono_do_pet.nome
				
				if (_IsInInstance() and _detalhes.remove_realm_from_name) then
					novo_objeto.displayName = nome:gsub (("%-.*"), ">")
				else
					novo_objeto.displayName = nome
				end
				
			else
				novo_objeto.displayName = nome
			end
			
			--> é inimigo
			if (_bit_band (flag, 0x00000040) ~= 0) then 
				if (_bit_band (flag, OBJECT_TYPE_PLAYER) == 0 and _bit_band (flag, OBJECT_TYPE_PETGUARDIAN) == 0) then
					novo_objeto.monster = true
				end
			end
		end
		
		novo_objeto.flag_original = flag
		novo_objeto.serial = serial
	end

	function container_combatentes:PegarCombatente (serial, nome, flag, criar, isOwner)

		--> verifica se é um pet, se for confere se tem o nome do dono, se não tiver, precisa por
		local dono_do_pet
		
		--if (flag and _bit_band (flag, OBJECT_TYPE_PETS) ~= 0) then --> é um pet
		if (_detalhes.tabela_pets.pets [serial]) then --> é um pet
			--> aqui ele precisaria achar as tag < > pra saber se o nome passado já não veio com o dono imbutido, se não tiver as tags, terá que ser posto aqui
			if (not nome:find ("<") or not nome:find (">")) then --> find é lento, não teria outra forma de fazer isso?
				local nome_dele, dono_nome, dono_serial, dono_flag = _detalhes.tabela_pets:PegaDono (serial, nome, flag)
				if (nome_dele and dono_nome) then
					nome = nome_dele
					dono_do_pet = self:PegarCombatente (dono_serial, dono_nome, dono_flag, true, nome)
				end
			end
		end

		--> pega o index no mapa
		local index = self._NameIndexTable [nome] 
		--> retorna o actor
		if (index) then
			return self._ActorTable [index], dono_do_pet, nome
		
		--> não achou, criar
		elseif (criar) then

			--> espelho do container no overall
			local shadow = self.shadow 
			local shadow_objeto

			--> se tiver o espelho (não for a tabela overall já)
			if (shadow) then 
				--> apenas verifica se ele existe ou não
				shadow_objeto = shadow:PegarCombatente (_, nome) 
				--> se não existir, cria-lo
				if (not shadow_objeto) then 
					--> tira o nome do pet
					local novo_nome = nome:gsub ((" <.*"), "") 
					--> cria o objeto
					shadow_objeto = shadow:PegarCombatente (serial, novo_nome, flag, true)
				end
			end

			local novo_objeto = self.funcao_de_criacao (_, serial, nome, shadow_objeto) --> shadow_objeto passa para o classe_damage gravar no .targets e .spell_tables, mas não grava nele mesmo
			novo_objeto.nome = nome

		-- tipo do container
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

			if (self.tipo == container_damage) then --> CONTAINER DAMAGE

				get_actor_class (novo_objeto, nome, flag)
				read_actor_flag (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome, "damage")
				
				if (dono_do_pet) then
					dono_do_pet.pets [#dono_do_pet.pets+1] = nome
				end
				
				if (shadow_objeto) then
					novo_objeto.shadow = shadow_objeto
					novo_objeto:CriaLink (shadow_objeto) --> criando o link
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
				
				if (novo_objeto.isTank) then
					novo_objeto.avoidance = _detalhes:CreateActorAvoidanceTable()
				end
				
			elseif (self.tipo == container_heal) then --> CONTAINER HEALING
				
				get_actor_class (novo_objeto, nome, flag)
				read_actor_flag (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome, "heal")
				
				if (dono_do_pet) then
					dono_do_pet.pets [#dono_do_pet.pets+1] = nome
				end
				
				if (shadow_objeto) then
					novo_objeto.shadow = shadow_objeto
					novo_objeto:CriaLink (shadow_objeto)  --> criando o link
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
				
				get_actor_class (novo_objeto, nome, flag)
				read_actor_flag (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome, "energy")
				
				if (dono_do_pet) then
					dono_do_pet.pets [#dono_do_pet.pets+1] = nome
				end
				
				if (shadow_objeto) then
					novo_objeto.shadow = shadow_objeto
					novo_objeto:CriaLink (shadow_objeto)  --> criando o link
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
				
			elseif (self.tipo == container_misc) then --> CONTAINER MISC
				
				get_actor_class (novo_objeto, nome, flag)
				read_actor_flag (novo_objeto, shadow_objeto, dono_do_pet, serial, flag, nome, "misc")
				
				--local teste_classe = 
				
				if (dono_do_pet) then
					dono_do_pet.pets [#dono_do_pet.pets+1] = nome
				end
				
				if (shadow_objeto) then
					novo_objeto.shadow = shadow_objeto
					novo_objeto:CriaLink (shadow_objeto)  --> criando o link
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
			
			elseif (self.tipo == container_damage_target) then --> CONTAINER ALVO DO DAMAGE
			
			elseif (self.tipo == container_energy_target) then --> CONTAINER ALVOS DO ENERGY
			
				novo_objeto.mana = 0
				novo_objeto.e_rage = 0
				novo_objeto.e_energy = 0
				novo_objeto.runepower = 0
				
				if (shadow_objeto) then
					novo_objeto.shadow = shadow_objeto
				end
				
			elseif (self.tipo == container_enemydebufftarget_target) then
				
				novo_objeto.uptime = 0
				novo_objeto.actived = false
				novo_objeto.activedamt = 0
				
				if (shadow_objeto) then
					novo_objeto.shadow = shadow_objeto
				end
				
			elseif (self.tipo == container_misc_target) then --> CONTAINER ALVOS DO MISC

				if (shadow_objeto) then
					novo_objeto.shadow = shadow_objeto
				end
				
			elseif (self.tipo == container_friendlyfire) then --> CONTAINER FRIENDLY FIRE
				
				get_actor_class (novo_objeto, nome)
				
				if (shadow_objeto) then
					novo_objeto.shadow = shadow_objeto
				end
			end
		
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- grava o objeto no mapa do container
			local size = #self._ActorTable+1
			self._ActorTable [size] = novo_objeto --> grava na tabela de indexes
			self._NameIndexTable [nome] = size --> grava no hash map o index deste jogador

			return novo_objeto, dono_do_pet, nome
		else
			return nil, nil, nil
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function container_combatentes:FuncaoDeCriacao (tipo)
		if (tipo == container_damage_target) then
			return alvo_da_habilidade.NovaTabela
			
		elseif (tipo == container_damage) then
			return atributo_damage.NovaTabela
			
		elseif (tipo == container_heal_target) then
			return alvo_da_habilidade.NovaTabela
			
		elseif (tipo == container_heal) then
			return atributo_heal.NovaTabela
			
		elseif (tipo == container_enemydebufftarget_target) then
			return alvo_da_habilidade.NovaTabela
			
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

	--> chama a função para ser executada em todos os atores
	function container_combatentes:ActorCallFunction (funcao, ...)
		for index, actor in _ipairs (self._ActorTable) do
			funcao (nil, actor, ...)
		end
	end

	local bykey
	local sort = function (t1, t2)
		return t1 [bykey] > t2 [bykey]
	end
	
	function container_combatentes:SortByKey (key)
		bykey = key
		_table_sort (self._ActorTable, sort)
		self:remapear()
	end
	
	function container_combatentes:Remap()
		return self:remapear()
	end
	
	function container_combatentes:remapear()
		local mapa = self._NameIndexTable
		local conteudo = self._ActorTable
		for i = 1, #conteudo do
			mapa [conteudo[i].nome] = i
		end
	end

	function _detalhes.refresh:r_container_combatentes (container, shadow)
		--> reconstrói meta e indexes
			_setmetatable (container, _detalhes.container_combatentes)
			container.__index = _detalhes.container_combatentes
			container.funcao_de_criacao = container_combatentes:FuncaoDeCriacao (container.tipo)

		--> repara mapa
			local mapa = {}
			for i = 1, #container._ActorTable do
				mapa [container._ActorTable[i].nome] = i
			end
			container._NameIndexTable = mapa

		--> seta a shadow
			container.shadow = shadow
	end

	function _detalhes.clear:c_container_combatentes (container)
		container.__index = nil
		container.shadow = nil
		container._NameIndexTable = nil
		container.need_refresh = nil
		container.funcao_de_criacao = nil
	end