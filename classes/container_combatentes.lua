-- actor container file

	local _detalhes = 		_G._detalhes
	local _

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _UnitClass = UnitClass --api local
	local _IsInInstance = IsInInstance --api local
	local _UnitGUID = UnitGUID --api local
	local strsplit = strsplit --api local
	
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

	local container_pets = {}
	
	--> flags
	local REACTION_HOSTILE	=	0x00000040
	local IS_GROUP_OBJECT 	= 	0x00000007
	local REACTION_FRIENDLY	=	0x00000010 
	local OBJECT_TYPE_MASK =	0x0000FC00
	local OBJECT_TYPE_OBJECT =	0x00004000
	local OBJECT_TYPE_PETGUARDIAN =	0x00003000
	local OBJECT_TYPE_GUARDIAN =	0x00002000
	local OBJECT_TYPE_PET =		0x00001000
	local OBJECT_TYPE_NPC =		0x00000800
	local OBJECT_TYPE_PLAYER =	0x00000400
	local OBJECT_TYPE_PETS = 	OBJECT_TYPE_PET + OBJECT_TYPE_GUARDIAN

	local KirinTor = GetFactionInfoByID (1090) or "1"
	local Valarjar = GetFactionInfoByID (1948) or "1"
	local HighmountainTribe = GetFactionInfoByID (1828) or "1"
	local CourtofFarondis = GetFactionInfoByID (1900) or "1"
	local Dreamweavers = GetFactionInfoByID (1883) or "1"
	local TheNightfallen = GetFactionInfoByID (1859) or "1"
	local TheWardens = GetFactionInfoByID (1894) or "1"

	local IsFactionNpc = {
		[KirinTor] = true,
		[Valarjar] = true,
		[HighmountainTribe] = true,
		[CourtofFarondis] = true,
		[Dreamweavers] = true,
		[TheNightfallen] = true,
		[TheWardens] = true,
	}
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> api functions

	function container_combatentes:GetActor (actorName)
		local index = self._NameIndexTable [actorName]
		if (index) then
			return self._ActorTable [index]
		end
	end
	
	function container_combatentes:GetSpellSource (spellid)
		local t = self._ActorTable
		--print ("getting the source", spellid, #t)
		for i = 1, #t do
			if (t[i].spells._ActorTable [spellid]) then
				return t[i].nome
			end
		end
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
	local function get_actor_class (novo_objeto, nome, flag, serial)
		--> get spec
		if (_detalhes.track_specs) then
			local have_cached = _detalhes.cached_specs [serial]
			if (have_cached) then
				novo_objeto.spec = have_cached
				--> check is didn't changed the spec:
				_detalhes:ScheduleTimer ("ReGuessSpec", 15, {novo_objeto, self})
				--print (nome, "spec em cache:", have_cached)
			else
				_detalhes:ScheduleTimer ("GuessSpec", 3, {novo_objeto, self, 1})
				--print (nome, "nao tem")
			end
		end
	
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
	local read_actor_flag = function (novo_objeto, dono_do_pet, serial, flag, nome, container_type)

		if (flag) then

			--> é um player
			if (_bit_band (flag, OBJECT_TYPE_PLAYER) ~= 0) then
			
				if (not _detalhes.ignore_nicktag) then
					novo_objeto.displayName = _detalhes:GetNickname (serial, false, true) --> serial, default, silent
				end
				if (not novo_objeto.displayName) then
				
					if (_IsInInstance() and _detalhes.remove_realm_from_name) then
						novo_objeto.displayName = nome:gsub (("%-.*"), "")
						
					elseif (_detalhes.remove_realm_from_name) then
						novo_objeto.displayName = nome:gsub (("%-.*"), "%*")
						
					else
						novo_objeto.displayName = nome
					end
				end
				
				if ((_bit_band (flag, IS_GROUP_OBJECT) ~= 0 and novo_objeto.classe ~= "UNKNOW" and novo_objeto.classe ~= "UNGROUPPLAYER") or _detalhes:IsInCache (serial)) then
					novo_objeto.grupo = true
					
					if (_detalhes:IsATank (serial)) then
						novo_objeto.isTank = true
					end
				else
					if (_detalhes.pvp_as_group and (_detalhes.tabela_vigente and _detalhes.tabela_vigente.is_pvp) and _detalhes.is_in_battleground) then
						novo_objeto.grupo = true
					end
				end
				
				if (_detalhes.is_in_arena) then
				
					local my_team_color = GetBattlefieldArenaFaction()
				
					if (novo_objeto.grupo) then --> is ally
						novo_objeto.arena_ally = true
						novo_objeto.arena_team = my_team_color
					else --> is enemy
						novo_objeto.arena_enemy = true
						novo_objeto.arena_team = 1 - my_team_color
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
				
				--local pet_npc_template = _detalhes:GetNpcIdFromGuid (serial)
				--if (pet_npc_template == 86933) then --viviane
				--	novo_objeto.grupo = true
				--end
				
			else
				novo_objeto.displayName = nome
			end
			
			--> é inimigo
			if (_bit_band (flag, REACTION_HOSTILE) ~= 0) then 
				if (_bit_band (flag, OBJECT_TYPE_PLAYER) == 0 and _bit_band (flag, OBJECT_TYPE_PETGUARDIAN) == 0) then
					novo_objeto.monster = true
				end
			end
		end

	end

	local pet_blacklist = {}
	local pet_tooltip_frame = _G.DetailsPetOwnerFinder
	local pet_text_object = _G ["DetailsPetOwnerFinderTextLeft2"]
	local follower_text_object = _G ["DetailsPetOwnerFinderTextLeft3"]
	
	local find_pet_owner = function (serial, nome, flag, self)
	
		pet_tooltip_frame:SetOwner (WorldFrame, "ANCHOR_NONE")
		pet_tooltip_frame:SetHyperlink ("unit:" .. serial or "")
		
		local text = pet_text_object:GetText()
		if (text and text ~= "") then
			text = text:gsub ("'s", "") --> enUS
			
			if (IsFactionNpc [text]) then
				text = follower_text_object:GetText()
				if (text) then
					text = text:gsub ("'s", "") --> enUS
				else
					return
				end
			end
			
			for _, ownerName in _ipairs ({strsplit (" ", text)}) do
				local cur_combat = _detalhes.tabela_vigente
				if (cur_combat and cur_combat.raid_roster [ownerName]) then
					local ownerGuid = _UnitGUID (ownerName)
					if (ownerGuid) then
					
						_detalhes.tabela_pets:Adicionar (serial, nome, flag, ownerGuid, ownerName, 0x00000417)
						local nome_dele, dono_nome, dono_serial, dono_flag = _detalhes.tabela_pets:PegaDono (serial, nome, flag)
						
						local dono_do_pet
						if (nome_dele and dono_nome) then
							nome = nome_dele
							dono_do_pet = self:PegarCombatente (dono_serial, dono_nome, dono_flag, true, nome)
						end
						
						--print ("Owner Found:", ownerName, nome)
						return nome, dono_do_pet
					end
				end
			end
		end
	end
	
	function container_combatentes:PegarCombatente (serial, nome, flag, criar)

		--[[statistics]]-- _detalhes.statistics.container_calls = _detalhes.statistics.container_calls + 1
	
		--if (flag and nome:find ("Kastfall") and bit.band (flag, 0x2000) ~= 0) then
			--print ("PET:", nome, _detalhes.tabela_pets.pets [serial], container_pets [serial])
		--else
			--print (nome, flag)
		--end
	
		--> verifica se é um pet, se for confere se tem o nome do dono, se não tiver, precisa por
		local dono_do_pet
		serial = serial or "ns"
		
		if (container_pets [serial]) then --> é um pet reconhecido
			--[[statistics]]-- _detalhes.statistics.container_pet_calls = _detalhes.statistics.container_pet_calls + 1
			
			local nome_dele, dono_nome, dono_serial, dono_flag = _detalhes.tabela_pets:PegaDono (serial, nome, flag)
			if (nome_dele and dono_nome) then
				nome = nome_dele
				dono_do_pet = self:PegarCombatente (dono_serial, dono_nome, dono_flag, true)
			end
			
		elseif (not pet_blacklist [serial]) then --> verifica se é um pet
		
			pet_blacklist [serial] = true
		
			--> try to find the owner
			if (flag and _bit_band (flag, OBJECT_TYPE_PETGUARDIAN) ~= 0) then
			
				--[[statistics]]-- _detalhes.statistics.container_unknow_pet = _detalhes.statistics.container_unknow_pet + 1
				local find_nome, find_owner = find_pet_owner (serial, nome, flag, self)
				if (find_nome and find_owner) then
					nome, dono_do_pet = find_nome, find_owner
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

			local novo_objeto = self.funcao_de_criacao (_, serial, nome)
			novo_objeto.nome = nome
			novo_objeto.flag_original = flag
			novo_objeto.serial = serial
			
			--> seta a classe default para desconhecido, assim nenhum objeto fica com classe nil
			novo_objeto.classe = "UNKNOW"

--8/11 00:57:49.096  SPELL_DAMAGE,
--Creature-0-2084-1220-24968-110715-00002BF677,"Archmage Modera",0x2111,0x0,
--Creature-0-2084-1220-24968-94688-00002BF6A7,"Diseased Grub",0x10a48,0x0,
--220128,"Frost Nova",0x10,Creature-0-2084-1220-24968-94688-00002BF6A7,0000000000000000,63802,311780,0,0,1,0,0,0,4319.26,4710.75,110,10271,-1,16,0,0,0,nil,nil,nil

		-- tipo do container
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

			if (self.tipo == container_damage) then --> CONTAINER DAMAGE

				get_actor_class (novo_objeto, nome, flag, serial)
				read_actor_flag (novo_objeto, dono_do_pet, serial, flag, nome, "damage")
				
				if (dono_do_pet) then
					dono_do_pet.pets [#dono_do_pet.pets+1] = nome
				end
				
				if (self.shadow) then
					if (novo_objeto.grupo and _detalhes.in_combat) then
						_detalhes.cache_damage_group [#_detalhes.cache_damage_group+1] = novo_objeto
					end
				end
				
				if (novo_objeto.classe == "UNGROUPPLAYER") then --> is a player
					if (_bit_band (flag, REACTION_HOSTILE ) ~= 0) then --> is hostile
						novo_objeto.enemy = true 
					end
					
					--> try to guess his class
					if (self.shadow) then --> não executar 2x
						_detalhes:ScheduleTimer ("GuessClass", 1, {novo_objeto, self, 1})
					end
				end
				
				if (novo_objeto.isTank) then
					novo_objeto.avoidance = _detalhes:CreateActorAvoidanceTable()
				end
				
			elseif (self.tipo == container_heal) then --> CONTAINER HEALING
				
				get_actor_class (novo_objeto, nome, flag, serial)
				read_actor_flag (novo_objeto, dono_do_pet, serial, flag, nome, "heal")
				
				if (dono_do_pet) then
					dono_do_pet.pets [#dono_do_pet.pets+1] = nome
				end
				
				if (self.shadow) then
					if (novo_objeto.grupo and _detalhes.in_combat) then
						_detalhes.cache_healing_group [#_detalhes.cache_healing_group+1] = novo_objeto
					end
				end
				
				if (novo_objeto.classe == "UNGROUPPLAYER") then --> is a player
					if (_bit_band (flag, REACTION_HOSTILE ) ~= 0) then --> is hostile
						novo_objeto.enemy = true --print (nome.." EH UM INIMIGO -> " .. engRace)
					end
					
					--> try to guess his class
					if (self.shadow) then --> não executar 2x
						_detalhes:ScheduleTimer ("GuessClass", 1, {novo_objeto, self, 1})
					end
				end
				
				
			elseif (self.tipo == container_energy) then --> CONTAINER ENERGY
				
				get_actor_class (novo_objeto, nome, flag, serial)
				read_actor_flag (novo_objeto, dono_do_pet, serial, flag, nome, "energy")
				
				if (dono_do_pet) then
					dono_do_pet.pets [#dono_do_pet.pets+1] = nome
				end
				
				if (novo_objeto.classe == "UNGROUPPLAYER") then --> is a player
					if (_bit_band (flag, REACTION_HOSTILE ) ~= 0) then --> is hostile
						novo_objeto.enemy = true
					end
					
					--> try to guess his class
					if (self.shadow) then --> não executar 2x
						_detalhes:ScheduleTimer ("GuessClass", 1, {novo_objeto, self, 1})
					end
				end
				
			elseif (self.tipo == container_misc) then --> CONTAINER MISC
				
				get_actor_class (novo_objeto, nome, flag, serial)
				read_actor_flag (novo_objeto, dono_do_pet, serial, flag, nome, "misc")
				
				--local teste_classe = 
				
				if (dono_do_pet) then
					dono_do_pet.pets [#dono_do_pet.pets+1] = nome
				end

				if (novo_objeto.classe == "UNGROUPPLAYER") then --> is a player
					if (_bit_band (flag, REACTION_HOSTILE ) ~= 0) then --> is hostile
						novo_objeto.enemy = true
					end
					
					--> try to guess his class
					if (self.shadow) then --> não executar 2x
						_detalhes:ScheduleTimer ("GuessClass", 1, {novo_objeto, self, 1})
					end
				end
			
			elseif (self.tipo == container_damage_target) then --> CONTAINER ALVO DO DAMAGE
			
			elseif (self.tipo == container_energy_target) then --> CONTAINER ALVOS DO ENERGY
			
				novo_objeto.mana = 0
				novo_objeto.e_rage = 0
				novo_objeto.e_energy = 0
				novo_objeto.runepower = 0

			elseif (self.tipo == container_enemydebufftarget_target) then
				
				novo_objeto.uptime = 0
				novo_objeto.actived = false
				novo_objeto.activedamt = 0

			elseif (self.tipo == container_misc_target) then --> CONTAINER ALVOS DO MISC

				
			elseif (self.tipo == container_friendlyfire) then --> CONTAINER FRIENDLY FIRE
				
				get_actor_class (novo_objeto, nome, serial)

			end
		
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- grava o objeto no mapa do container
			local size = #self._ActorTable+1
			self._ActorTable [size] = novo_objeto --> grava na tabela de indexes
			self._NameIndexTable [nome] = size --> grava no hash map o index deste jogador

			if (_detalhes.is_in_battleground or _detalhes.is_in_arena) then
				novo_objeto.pvp = true
			end
			
			return novo_objeto, dono_do_pet, nome
		else
			return nil, nil, nil
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core
	
	--_detalhes:AddToNpcIdCache (novo_objeto)
	function _detalhes:AddToNpcIdCache (actor)
		if (flag and serial) then
			if (_bit_band (flag, REACTION_HOSTILE) ~= 0 and _bit_band (flag, OBJECT_TYPE_NPC) ~= 0 and _bit_band (flag, OBJECT_TYPE_PETGUARDIAN) == 0) then
				local npc_id = _detalhes:GetNpcIdFromGuid (serial)
				if (npc_id) then
					_detalhes.cache_npc_ids [npc_id] = nome
				end
			end
		end		
	end

	function _detalhes:UpdateContainerCombatentes()
		container_pets = _detalhes.tabela_pets.pets
		_detalhes:UpdatePetsOnParser()
	end
	function _detalhes:ClearCCPetsBlackList()
		table.wipe (pet_blacklist)
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
		return (t1 [bykey] or 0) > (t2 [bykey] or 0)
	end
	
	function container_combatentes:SortByKey (key)
		assert (type (key) == "string", "Container:SortByKey() expects a keyname on parameter 1.")
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
		--container._NameIndexTable = nil
		container.need_refresh = nil
		container.funcao_de_criacao = nil
	end
	function _detalhes.clear:c_container_combatentes_index (container)
		container._NameIndexTable = nil
	end