--[[ 
-------Details! Addon
-------Class Combat
	-------This file control combat class. A combat is a object wich hold combat attributes.
	-------The numeric part of table is compost by 4 indexes: [1] damage, [2] heal, [3] energies and [4] misc
]]

local _detalhes = 		_G._detalhes

--shortcuts
local combate =			_detalhes.combate
local container_combatentes = _detalhes.container_combatentes

--flags
local REACTION_HOSTILE =	0x00000040
local CONTROL_PLAYER =		0x00000100

--locals
local _setmetatable = setmetatable --> lua api
local _ipairs = ipairs --> lua api
local _pairs = pairs --> lua api
local _bit_band = bit.band --> lua api
local _date = date --> lua api
local _table_remove = table.remove

--time hold
local _tempo = time()
local _

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--[[ 	__call function, get an actor from current combat.
	combatTable ( index, actorName )
	index: container number [1] damage, [2] heal, [3] energies and [4] misc
	actorName: name of an actor (player, npc, pet, etc) --]]

_detalhes.call_combate = function (self, class_type, name)
	local container = self[class_type]
	local index_mapa = container._NameIndexTable [name]
	local actor = container._ActorTable [index_mapa]
	return actor
end

combate.__call = _detalhes.call_combate

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--[[ Class Constructor ]]
function combate:NovaTabela (iniciada, _tabela_overall, combatId, ...)

	local esta_tabela = {true, true, true, true, true}
	
	esta_tabela [1] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_DAMAGE_CLASS, esta_tabela, combatId) --> Damage
	esta_tabela [2] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_HEAL_CLASS, esta_tabela, combatId) --> Healing
	esta_tabela [3] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_ENERGY_CLASS, esta_tabela, combatId) --> Energies
	esta_tabela [4] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_MISC_CLASS, esta_tabela, combatId) --> Misc
	esta_tabela [5] = container_combatentes:NovoContainer (_detalhes.container_type.CONTAINER_DAMAGE_CLASS, esta_tabela, combatId) --> place holder for customs
	
	_setmetatable (esta_tabela, combate)
	
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
			esta_tabela.pvp = true --> se ambos são friendly, seria isso um PVP entre jogadores da mesma facções?
		end
	end

	--> start/end time (duration)
	esta_tabela.data_fim = 0
	esta_tabela.data_inicio = 0
	
	--> record last event before dead
	esta_tabela.last_events_tables = {}
	
	--> frags
	esta_tabela.frags = {}
	esta_tabela.frags_need_refresh = false
	
	--> time data container
	esta_tabela.TimeData = _detalhes:TimeDataCreateCombatTables()
	
	--> Skill cache (not used)
	esta_tabela.CombatSkillCache = {}

	-- a tabela sem o tempo de inicio é a tabela descartavel do inicio do addon
	if (iniciada) then
		esta_tabela.start_time = _tempo
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
		esta_tabela[1].shadow = _tabela_overall[1] --> diz ao objeto qual a shadow dele na tabela overall
		esta_tabela[2].shadow = _tabela_overall[2] --> diz ao objeto qual a shadow dele na tabela overall
		esta_tabela[3].shadow = _tabela_overall[3] --> diz ao objeto qual a shadow dele na tabela overall
		esta_tabela[4].shadow = _tabela_overall[4] --> diz ao objeto qual a shadow dele na tabela overall
	end

	-- abriga a tabela contendo o total de cada atributo
	-- esta_tabela.barra_total = barra_total:NovaBarra() 
	--> barra total movido para um simples membro do combate:
	esta_tabela.totals = {
		0, --> dano
		0, --> cura
		{--> e_energy
			mana = 0, --> mana
			e_rage = 0, --> rage
			e_energy = 0, --> energy (rogues cat)
			runepower = 0 --> runepower (dk)
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
		}
	}
	
	esta_tabela.totals_grupo = {
		0, --> dano
		0, --> cura
		{--> e_energy
			mana = 0, --> mana
			e_rage = 0, --> rage
			e_energy = 0, --> energy (rogues cat)
			runepower = 0 --> runepower (dk)
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

function combate:GetTimeData (name)

	return self.TimeData [name]
	
end

function combate:TravarTempos()
	--é necessário travar o tempo em todos os atributos do combate.
	
	if (self [1]) then
		for _, jogador in _ipairs (self [1]._ActorTable) do --> damage
			if (jogador:Iniciar()) then -- retorna se ele esta com o dps ativo
				jogador:TerminarTempo()
				jogador:Iniciar (false) --trava o dps do jogador
				--jogador.last_events_table =  _detalhes:CreateActorLastEventTable()
			end
		end
	else
		--print ("combat [1] doesn't exist.")
	end
	if (self [2]) then
		for _, jogador in _ipairs (self [2]._ActorTable) do --> healing
			if (jogador:Iniciar()) then -- retorna se ele esta com o dps ativo
				jogador:TerminarTempo()
				jogador:Iniciar (false) --trava o dps do jogador
				--print ("travando o tempo de",jogador.nome, jogador.end_time)
				--jogador.last_events_table =  _detalhes:CreateActorLastEventTable()
			end
		end
	else
		--print ("combat [2] doesn't exist.")
	end
end

function combate:UltimaAcao (tempo)
	if (tempo) then
		self.last_event = tempo
	else
		return self.last_event
	end
end

function combate:GetDate()
	return self.data_inicio, self.data_fim
end

function combate:seta_data (tipo)
	if (tipo == _detalhes._detalhes_props.DATA_TYPE_START) then
		self.data_inicio = _date ("%H:%M:%S")
	elseif (tipo == _detalhes._detalhes_props.DATA_TYPE_END) then
		self.data_fim = _date ("%H:%M:%S")
	end
end

function combate:GetActorList (container)
	return self [container]._ActorTable
end

function combate:GetCombatTime()
	if (self.end_time) then
		--print ("tem end time")
		return self.end_time - self.start_time
	elseif (self.start_time and _detalhes.in_combat) then
		--print ("tem start time e esta em combate")
		return _tempo - self.start_time
	else
		--print ("retornando zero")
		return 0
	end
end

--[[global]] DETAILS_TOTALS_ONLYGROUP = true

function combate:GetTotal (attribute, subAttribute, onlyGroup)
	if (attribute == 1 or attribute == 2) then
		if (onlyGroup) then
			return self.totals_grupo [attribute]
		else
			return self.totals [attribute]
		end
		
	elseif (attribute == 3 or attribute == 4) then
		local subName = _detalhes:GetInternalSubAttributeName (attribute, subAttribute)
		if (onlyGroup) then
			return self.totals_grupo [attribute] [subName]
		else
			return self.totals [attribute] [subName]
		end
	end
	return 0
end

function combate:seta_tempo_decorrido()
	self.end_time = _tempo
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

	if (combate1~= _detalhes.tabela_overall) then
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
		combate1.start_time = combate1.start_time + (combate2.end_time - combate2.start_time)
		
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

	if (combate1 == _detalhes.tabela_overall or combate2 == _detalhes.tabela_overall) then
		return
	end

	--> add dano
		for index, actor_T2 in _ipairs (combate2[1]._ActorTable) do
			local actor_T1 = combate1[1]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
			actor_T1 = actor_T1 + actor_T2
			actor_T1:add_total (combate1)
			actor_T1:add_total (_detalhes.tabela_overall)
		end
		combate1 [1].need_refresh = true
		
	--> add heal
		for index, actor_T2 in _ipairs (combate2[2]._ActorTable) do
			local actor_T1 = combate1[2]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
			actor_T1 = actor_T1 + actor_T2
			actor_T1:add_total (combate1)
			actor_T1:add_total (_detalhes.tabela_overall)
		end
		combate1 [2].need_refresh = true
		
	--> add energy
		for index, actor_T2 in _ipairs (combate2[3]._ActorTable) do
			local actor_T1 = combate1[3]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
			actor_T1 = actor_T1 + actor_T2
			actor_T1:add_total (combate1)
			actor_T1:add_total (_detalhes.tabela_overall)
		end
		combate1 [3].need_refresh = true
		
	--> add misc
		for index, actor_T2 in _ipairs (combate2[4]._ActorTable) do
			local actor_T1 = combate1[4]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
			actor_T1 = actor_T1 + actor_T2
			actor_T1:add_total (combate1)
			actor_T1:add_total (_detalhes.tabela_overall)
		end
		combate1 [4].need_refresh = true

	--> aumenta o tempo 
		combate1.start_time = combate1.start_time - (combate2.end_time - combate2.start_time)
	--> frags
		for fragName, fragAmount in pairs (combate2.frags) do 
			if (fragAmount) then
				if (combate1.frags [fragName]) then
					combate1.frags [fragName] = combate1.frags [fragName] + fragAmount
				else
					combate1.frags [fragName] = fragAmount
				end
			end
		end
		combate1.frags_need_refresh = true
		
	return combate1
	
end

function _detalhes:UpdateCombat()
	_tempo = _detalhes._tempo
end
