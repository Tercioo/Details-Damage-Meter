-- combat class object

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	
--[[global]] DETAILS_TOTALS_ONLYGROUP = true

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _setmetatable = setmetatable -- lua local
	local _ipairs = ipairs -- lua local
	local _pairs = pairs -- lua local
	local _bit_band = bit.band -- lua local
	local _date = date -- lua local
	local _table_remove = table.remove -- lua local
	local _rawget = rawget
	local _math_max = math.max
	local _math_floor = math.floor
	local _GetTime = GetTime

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local combate 	=	_detalhes.combate
	local container_combatentes = _detalhes.container_combatentes
	local class_type_dano 	= _detalhes.atributos.dano
	local class_type_cura		= _detalhes.atributos.cura
	local class_type_e_energy 	= _detalhes.atributos.e_energy
	local class_type_misc 	= _detalhes.atributos.misc
	
	local REACTION_HOSTILE =	0x00000040
	local CONTROL_PLAYER =		0x00000100

	--local _tempo = time()
	local _tempo = _GetTime()
	
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> api functions

	--combat (container type, actor name)
	_detalhes.call_combate = function (self, class_type, name)
		local container = self[class_type]
		local index_mapa = container._NameIndexTable [name]
		local actor = container._ActorTable [index_mapa]
		return actor
	end
	combate.__call = _detalhes.call_combate

	--get the start date and end date
	function combate:GetDate()
		return self.data_inicio, self.data_fim
	end
	
	--return data for charts
	function combate:GetTimeData (name)
		return self.TimeData [name]
	end
	
	function combate:GetContainer (attribute)
		return self [attribute]
	end
	
	function combate:GetRoster()
		return self.raid_roster
	end
	
	function combate:InstanceType()
		return _rawget (self, "instance_type")
	end
	
	function combate:IsTrash()
		return _rawget (self, "is_trash")
	end
	
	function combate:GetDifficulty()
		return self.is_boss and self.is_boss.diff
	end
	
	function combate:GetBossInfo()
		return self.is_boss
	end
	
	function combate:GetPvPInfo()
		return self.is_pvp
	end
	
	function combate:GetArenaInfo()
		return self.is_arena
	end
	
	function combate:GetDeaths()
		return self.last_events_tables
	end
	
	function combate:GetCombatNumber()
		return self.combat_counter
	end
	
	--return the name of the encounter or enemy
	function combate:GetCombatName (try_find)
		if (self.is_pvp) then
			return self.is_pvp.name
		elseif (self.is_boss) then
			return self.is_boss.encounter
		elseif (_rawget (self, "is_trash")) then
			return Loc ["STRING_SEGMENT_TRASH"]
		else
			if (self.enemy) then
				return self.enemy
			end
			if (try_find) then
				return _detalhes:FindEnemy()
			end
		end
		return Loc ["STRING_UNKNOW"]
	end

	--return a numeric table with all actors on the specific containter
	function combate:GetActorList (container)
		return self [container]._ActorTable
	end

	function combate:GetActor (container, name)
		local index = self [container] and self [container]._NameIndexTable [name]
		if (index) then
			return self [container]._ActorTable [index]
		end
		return nil
	end
	
	--return the combat time in seconds
	function combate:GetFormatedCombatTime()
		local time = self:GetCombatTime()
		local m, s = _math_floor (time/60), _math_floor (time%60)
		return m, s
	end
	
	function combate:GetCombatTime()
		if (self.end_time) then
			return _math_max (self.end_time - self.start_time, 0.1)
		elseif (self.start_time and _detalhes.in_combat and self ~= _detalhes.tabela_overall) then
			return _math_max (_GetTime() - self.start_time, 0.1)
		else
			return 0.1
		end
	end
	
	function combate:GetStartTime()
		return self.start_time
	end
	function combate:SetStartTime (t)
		self.start_time = t
	end
	
	function combate:GetEndTime()
		return self.end_time
	end
	function combate:SetEndTime (t)
		self.end_time = t
	end

	--return the total of a specific attribute
	local power_table = {0, 1, 3, 6}
	
	function combate:GetTotal (attribute, subAttribute, onlyGroup)
		if (attribute == 1 or attribute == 2) then
			if (onlyGroup) then
				return self.totals_grupo [attribute]
			else
				return self.totals [attribute]
			end
			
		elseif (attribute == 3) then
			if (subAttribute == 5) then --> resources
				return self.totals.resources or 0
			end
			if (onlyGroup) then
				return self.totals_grupo [attribute] [power_table [subAttribute]]
			else
				return self.totals [attribute] [power_table [subAttribute]]
			end
			
		elseif (attribute == 4) then
			local subName = _detalhes:GetInternalSubAttributeName (attribute, subAttribute)
			if (onlyGroup) then
				return self.totals_grupo [attribute] [subName]
			else
				return self.totals [attribute] [subName]
			end
		end
		
		return 0
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internals

	--class constructor
	function combate:NovaTabela (iniciada, _tabela_overall, combatId, ...)

		local esta_tabela = {true, true, true, true, true}
		
		esta_tabela [1] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_DAMAGE_CLASS, esta_tabela, combatId) --> Damage
		esta_tabela [2] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_HEAL_CLASS, esta_tabela, combatId) --> Healing
		esta_tabela [3] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_ENERGY_CLASS, esta_tabela, combatId) --> Energies
		esta_tabela [4] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_MISC_CLASS, esta_tabela, combatId) --> Misc
		esta_tabela [5] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_DAMAGE_CLASS, esta_tabela, combatId) --> place holder for customs
		
		_setmetatable (esta_tabela, combate)
		
		_detalhes.combat_counter = _detalhes.combat_counter + 1
		esta_tabela.combat_counter = _detalhes.combat_counter
		
		--> try discover if is a pvp combat
		local who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags = ...
		if (who_serial) then --> aqui irá identificar o boss ou o oponente
			if (alvo_name and _bit_band (alvo_flags, REACTION_HOSTILE) ~= 0) then --> tentando pegar o inimigo pelo alvo
				esta_tabela.contra = alvo_name
				if (_bit_band (alvo_flags, CONTROL_PLAYER) ~= 0) then
					esta_tabela.pvp = true --> o alvo é da facção oposta ou foi dado mind control
				end
			elseif (who_name and _bit_band (who_flags, REACTION_HOSTILE) ~= 0) then --> tentando pegar o inimigo pelo who caso o mob é quem deu o primeiro hit
				esta_tabela.contra = who_name
				if (_bit_band (who_flags, CONTROL_PLAYER) ~= 0) then
					esta_tabela.pvp = true --> o who é da facção oposta ou foi dado mind control
				end
			else
				esta_tabela.pvp = true --> se ambos são friendly, seria isso um PVP entre jogadores da mesma facção?
			end
		end

		--> start/end time (duration)
		esta_tabela.data_fim = 0
		esta_tabela.data_inicio = 0
		
		--> record deaths
		esta_tabela.last_events_tables = {}
		
		--> last events from players
		esta_tabela.player_last_events = {}
		
		--> players in the raid
		esta_tabela.raid_roster = {}
		
		--> frags
		esta_tabela.frags = {}
		esta_tabela.frags_need_refresh = false
		
		--> time data container
		esta_tabela.TimeData = _detalhes:TimeDataCreateCombatTables()
		esta_tabela.PhaseData = {{1, 1}, damage = {}, heal = {}, damage_section = {}, heal_section = {}} --[1] phase number [2] phase started
		
		--> Skill cache (not used)
		esta_tabela.CombatSkillCache = {}

		-- a tabela sem o tempo de inicio é a tabela descartavel do inicio do addon
		if (iniciada) then
			--esta_tabela.start_time = _tempo
			esta_tabela.start_time = _GetTime()
			esta_tabela.end_time = nil
		else
			esta_tabela.start_time = 0
			esta_tabela.end_time = nil
		end

		-- o container irá armazenar as classes de dano -- cria um novo container de indexes de seriais de jogadores --parâmetro 1 classe armazenada no container, parâmetro 2 = flag da classe
		esta_tabela[1].need_refresh = true
		esta_tabela[2].need_refresh = true
		esta_tabela[3].need_refresh = true
		esta_tabela[4].need_refresh = true
		esta_tabela[5].need_refresh = true
		
		if (_tabela_overall) then --> link é a tabela de combate do overall
			esta_tabela[1].shadow = _tabela_overall[1]
			esta_tabela[2].shadow = _tabela_overall[2]
			esta_tabela[3].shadow = _tabela_overall[3]
			esta_tabela[4].shadow = _tabela_overall[4]
		end

		esta_tabela.totals = {
			0, --> dano
			0, --> cura
			{--> e_energy
				[0] = 0, --> mana
				[1] = 0, --> rage
				[3] = 0, --> energy (rogues cat)
				[6] = 0 --> runepower (dk)
			},
			{--> misc
				cc_break = 0, --> armazena quantas quebras de CC
				ress = 0, --> armazena quantos pessoas ele reviveu
				interrupt = 0, --> armazena quantos interrupt a pessoa deu
				dispell = 0, --> armazena quantos dispell esta pessoa recebeu
				dead = 0, --> armazena quantas vezes essa pessia morreu
				cooldowns_defensive = 0, --> armazena quantos cooldowns a raid usou
				buff_uptime = 0, --> armazena quantos cooldowns a raid usou
				debuff_uptime = 0 --> armazena quantos cooldowns a raid usou
			},
			
			--> avoid using this values bellow, they aren't updated by the parser, only on demand by a user interaction.
				voidzone_damage = 0,
				frags_total = 0,
			--> end
		}
		
		esta_tabela.totals_grupo = {
			0, --> dano
			0, --> cura
			{--> e_energy
				[0] = 0, --> mana
				[1] = 0, --> rage
				[3] = 0, --> energy (rogues cat)
				[6] = 0 --> runepower (dk)
			}, 
			{--> misc
				cc_break = 0, --> armazena quantas quebras de CC
				ress = 0, --> armazena quantos pessoas ele reviveu
				interrupt = 0, --> armazena quantos interrupt a pessoa deu
				dispell = 0, --> armazena quantos dispell esta pessoa recebeu
				dead = 0, --> armazena quantas vezes essa oessia morreu		
				cooldowns_defensive = 0, --> armazena quantos cooldowns a raid usou
				buff_uptime = 0,
				debuff_uptime = 0
			}
		}

		return esta_tabela
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function combate:CreateLastEventsTable (player_name)
		local t = {}
		for i = 1, _detalhes.deadlog_events do
			t [i] = {}
		end
		t.n = 1
		self.player_last_events [player_name] = t
		return t
	end

	--trava o tempo dos jogadores após o término do combate.
	function combate:TravarTempos()
		if (self [1]) then
			for _, jogador in _ipairs (self [1]._ActorTable) do --> damage
				if (jogador:Iniciar()) then -- retorna se ele esta com o dps ativo
					jogador:TerminarTempo()
					jogador:Iniciar (false) --trava o dps do jogador
				else
					if (jogador.start_time == 0) then
						jogador.start_time = _tempo
					end
					if (not jogador.end_time) then
						jogador.end_time = _tempo
					end
				end
			end
		end
		if (self [2]) then
			for _, jogador in _ipairs (self [2]._ActorTable) do --> healing
				if (jogador:Iniciar()) then -- retorna se ele esta com o dps ativo
					jogador:TerminarTempo()
					jogador:Iniciar (false) --trava o dps do jogador
				else
					if (jogador.start_time == 0) then
						jogador.start_time = _tempo
					end
					if (not jogador.end_time) then
						jogador.end_time = _tempo
					end
				end
			end
		end
	end

	function combate:seta_data (tipo)
		if (tipo == _detalhes._detalhes_props.DATA_TYPE_START) then
			self.data_inicio = _date ("%H:%M:%S")
		elseif (tipo == _detalhes._detalhes_props.DATA_TYPE_END) then
			self.data_fim = _date ("%H:%M:%S")
		end
	end

	function combate:seta_tempo_decorrido()
		--self.end_time = _tempo
		self.end_time = _GetTime()
	end

	function _detalhes.refresh:r_combate (tabela_combate, shadow)
		_setmetatable (tabela_combate, _detalhes.combate)
		tabela_combate.__index = _detalhes.combate
		tabela_combate.shadow = shadow
	end

	function _detalhes.clear:c_combate (tabela_combate)
		--tabela_combate.__index = {}
		tabela_combate.__index = nil
		tabela_combate.__call = {}
		tabela_combate._combat_table = nil
		tabela_combate.shadow = nil
	end

	combate.__sub = function (combate1, combate2)

		if (combate1 ~= _detalhes.tabela_overall) then
			return
		end

		--> sub dano
			for index, actor_T2 in _ipairs (combate2[1]._ActorTable) do
				local actor_T1 = combate1[1]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [1].need_refresh = true
			
		--> sub heal
			for index, actor_T2 in _ipairs (combate2[2]._ActorTable) do
				local actor_T1 = combate1[2]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [2].need_refresh = true
			
		--> sub energy
			for index, actor_T2 in _ipairs (combate2[3]._ActorTable) do
				local actor_T1 = combate1[3]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [3].need_refresh = true
			
		--> sub misc
			for index, actor_T2 in _ipairs (combate2[4]._ActorTable) do
				local actor_T1 = combate1[4]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [4].need_refresh = true

		--> reduz o tempo 
			combate1.start_time = combate1.start_time + combate2:GetCombatTime()
			
		--> apaga as mortes da luta diminuida
			local amt_mortes =  #combate2.last_events_tables --> quantas mortes teve nessa luta
			if (amt_mortes > 0) then
				for i = #combate1.last_events_tables, #combate1.last_events_tables-amt_mortes, -1 do 
					_table_remove (combate1.last_events_tables, #combate1.last_events_tables)
				end
			end
			
		--> frags
			for fragName, fragAmount in pairs (combate2.frags) do 
				if (fragAmount) then
					if (combate1.frags [fragName]) then
						combate1.frags [fragName] = combate1.frags [fragName] - fragAmount
					else
						combate1.frags [fragName] = fragAmount
					end
				end
			end
			combate1.frags_need_refresh = true
			
		return combate1
		
	end

	combate.__add = function (combate1, combate2)

		local all_containers = {combate2 [class_type_dano]._ActorTable, combate2 [class_type_cura]._ActorTable, combate2 [class_type_e_energy]._ActorTable, combate2 [class_type_misc]._ActorTable}
		
		for class_type, actor_container in ipairs (all_containers) do
			for _, actor in ipairs (actor_container) do
				local shadow
				
				if (class_type == class_type_dano) then
					shadow = _detalhes.atributo_damage:r_connect_shadow (actor, true)
				elseif (class_type == class_type_cura) then
					shadow = _detalhes.atributo_heal:r_connect_shadow (actor, true)
				elseif (class_type == class_type_e_energy) then
					shadow = _detalhes.atributo_energy:r_connect_shadow (actor, true)
				elseif (class_type == class_type_misc) then
					shadow = _detalhes.atributo_misc:r_connect_shadow (actor, true)
				end
				
				shadow.boss_fight_component = actor.boss_fight_component
				shadow.fight_component = actor.fight_component
				shadow.grupo = actor.grupo
			end
		end

		return combate1
	end

	function _detalhes:UpdateCombat()
		_tempo = _detalhes._tempo
	end
