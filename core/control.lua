--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.

	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
	local _tempo = time()
	local _
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers
	
	local _math_floor = math.floor --lua local
	local _ipairs = ipairs --lua local
	local _pairs = pairs --lua local
	local _table_wipe = table.wipe --lua local
	local _bit_band = bit.band --lua local
	
	local _GetInstanceInfo = GetInstanceInfo --wow api local
	local _UnitExists = UnitExists --wow api local
	local _UnitGUID = UnitGUID --wow api local
	local _UnitName = UnitName --wow api local

	local _IsAltKeyDown = IsAltKeyDown
	local _IsShiftKeyDown = IsShiftKeyDown
	local _IsControlKeyDown = IsControlKeyDown
	
	local atributo_damage = _detalhes.atributo_damage --details local
	local atributo_heal = _detalhes.atributo_heal --details local
	local atributo_energy = _detalhes.atributo_energy --details local
	local atributo_misc = _detalhes.atributo_misc --details local
	local atributo_custom = _detalhes.atributo_custom --details local
	local info = _detalhes.janela_info --details local
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants
	
	local modo_GROUP = _detalhes.modos.group
	local modo_ALL = _detalhes.modos.all
	local class_type_dano = _detalhes.atributos.dano
	local OBJECT_TYPE_PETS = 0x00003000
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions

	--> try to find the opponent of last fight, can be called during a fight as well
		function _detalhes:FindEnemy()
			
			local ZoneName, InstanceType, DifficultyID, _, _, _, _, ZoneMapID = _GetInstanceInfo()
			if (InstanceType == "party" or InstanceType == "raid") then
				return Loc ["STRING_SEGMENT_TRASH"]
			end
			
			for _, actor in _ipairs (_detalhes.tabela_vigente[class_type_dano]._ActorTable) do 
			
				if (not actor.grupo and not actor.owner and not actor.nome:find ("[*]") and _bit_band (actor.flag_original, 0x00000060) ~= 0) then --> 0x20+0x40 neutral + enemy reaction
					for name, _ in _pairs (actor.targets._NameIndexTable) do
						if (name == _detalhes.playername) then
							return actor.nome
						else
							local _target_actor = _detalhes.tabela_vigente (class_type_dano, name)
							if (_target_actor and _target_actor.grupo) then 
								return actor.nome
							end
						end
					end
				end
				
			end
			
			for _, actor in _ipairs (_detalhes.tabela_vigente[class_type_dano]._ActorTable) do 
			
				if (actor.grupo and not actor.owner) then
					for index, target in _ipairs (actor.targets._ActorTable) do 
						return target.nome
					end
				end
				
			end
			
			return Loc ["STRING_UNKNOW"]
		end
	
	-- try get the current encounter name during the encounter
	
		local boss_found = function (index, name, zone, mapid, diff)
			local boss_table = {
				index = index,
				name = name,
				encounter = name,
				zone = zone,
				mapid = mapid,
				diff = diff,
				diff_string = select (4, GetInstanceInfo()),
				ej_instance_id = EJ_GetCurrentInstance(),
			}
			
			_detalhes.tabela_vigente.is_boss = boss_table
			
			if (_detalhes.in_combat and not _detalhes.leaving_combat) then
			
				--> catch boss function if any
				local bossFunction, bossFunctionType = _detalhes:GetBossFunction (ZoneMapID, BossIndex)
				if (bossFunction) then
					if (_bit_band (bossFunctionType, 0x1) ~= 0) then --realtime
						_detalhes.bossFunction = bossFunction
						_detalhes.tabela_vigente.bossFunction = _detalhes:ScheduleTimer ("bossFunction", 1)
					end
				end
				
				if (_detalhes.zone_type ~= "raid") then
					local endType, endData = _detalhes:GetEncounterEnd (ZoneMapID, BossIndex)
					if (endType and endData) then
					
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) setting boss end type to:", endType)
						end
					
						_detalhes.encounter_end_table.type = endType
						_detalhes.encounter_end_table.killed = {}
						_detalhes.encounter_end_table.data = {}
						
						if (type (endData) == "table") then
							if (_detalhes.debug) then
								_detalhes:Msg ("(debug) boss type is table:", endType)
							end
							if (endType == 1 or endType == 2) then
								for _, npcID in ipairs (endData) do 
									_detalhes.encounter_end_table.data [npcID] = false
								end
							end
						else
							if (endType == 1 or endType == 2) then
								_detalhes.encounter_end_table.data [endData] = false
							end
						end
					end
				end
			end
			
			_detalhes:SendEvent ("COMBAT_BOSS_FOUND", nil, index, name)
			
			return boss_table
		end
	
		function _detalhes:ReadBossFrames()
		
			if (_detalhes.tabela_vigente.is_boss) then
				return --no need to check
			end
		
			if (_detalhes.encounter_table.name) then
				local encounter_table = _detalhes.encounter_table
				return boss_found (encounter_table.index, encounter_table.name, encounter_table.zone, encounter_table.mapid, encounter_table.diff)
			end
		
			for index = 1, 5, 1 do 
				if (_UnitExists ("boss"..index)) then 
					local guid = _UnitGUID ("boss"..index)
					if (guid) then
						local serial = tonumber (guid:sub(6, 10), 16)
						
						if (serial) then
						
							local ZoneName, _, DifficultyID, _, _, _, _, ZoneMapID = _GetInstanceInfo()
						
							local BossIds = _detalhes:GetBossIds (ZoneMapID)
							if (BossIds) then
								local BossIndex = BossIds [serial]

								if (BossIndex) then 
									if (_detalhes.debug) then
										_detalhes:Msg ("(debug) boss found:",_detalhes:GetBossName (ZoneMapID, BossIndex))
									end
									
									return boss_found (BossIndex, _detalhes:GetBossName (ZoneMapID, BossIndex), ZoneName, ZoneMapID, DifficultyID)
								end
							end
						end
					end
				end
			end
		end	
	
	--try to get the encounter name after the encounter (can be called during the combat as well)
		function _detalhes:FindBoss()

			if (_detalhes.encounter_table.name) then
				local encounter_table = _detalhes.encounter_table
				return boss_found (encounter_table.index, encounter_table.name, encounter_table.zone, encounter_table.mapid, encounter_table.diff)
			end
		
			local ZoneName, InstanceType, DifficultyID, _, _, _, _, ZoneMapID = _GetInstanceInfo()
			local BossIds = _detalhes:GetBossIds (ZoneMapID)
			
			if (BossIds) then
				local BossIndex = nil
				local ActorsContainer = _detalhes.tabela_vigente [class_type_dano]._ActorTable
				
				if (ActorsContainer) then
					for index, Actor in _ipairs (ActorsContainer) do 
						if (not Actor.grupo) then
							local serial = tonumber (Actor.serial:sub (6, 10), 16)
							if (serial) then
								BossIndex = BossIds [serial]
								if (BossIndex) then
									Actor.boss = true
									Actor.shadow.boss = true
									return boss_found (BossIndex, _detalhes:GetBossName (ZoneMapID, BossIndex), ZoneName, ZoneMapID, DifficultyID)
								end
							end
						end
					end
				end
			end
			
			return false
		end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions

		-- ~start
		function _detalhes:EntrarEmCombate (...)

			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) started a new combat.")
			end

			--> não tem historico, addon foi resetado, a primeira tabela é descartada -- Erase first table is do es not have a firts segment history, this occour after reset or first run
			if (not _detalhes.tabela_historico.tabelas[1]) then 
				--> precisa zerar aqui a tabela overall
				_table_wipe (_detalhes.tabela_overall)
				_table_wipe (_detalhes.tabela_vigente)
				--> aqui ele perdeu o self.showing das instâncias, precisa fazer com que elas atualizem
				_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
				
				_detalhes:InstanciaCallFunction (_detalhes.ResetaGump, nil, -1) --> reseta scrollbar, iterators, rodapé, etc
				_detalhes:InstanciaCallFunction (_detalhes.InstanciaFadeBarras, -1) --> esconde todas as barras
				_detalhes:InstanciaCallFunction (_detalhes.AtualizaSegmentos) --> atualiza o showing
			end

			--> conta o tempo na tabela overall -- start time at overall table
			if (_detalhes.tabela_overall.end_time) then
				_detalhes.tabela_overall.start_time = _tempo - (_detalhes.tabela_overall.end_time - _detalhes.tabela_overall.start_time)
				_detalhes.tabela_overall.end_time = nil
			else
				_detalhes.tabela_overall.start_time = _tempo
			end

			--> re-lock nos tempos da tabela passada -- lock again last table times
			_detalhes.tabela_vigente:TravarTempos() --> lá em cima é feito wipe, não deveria ta dando merda nisso aqui? ou ela puxa da __index e da zero jogadores no mapa e container
			
			local n_combate = _detalhes:NumeroCombate (1) --aumenta o contador de combates -- combat number up
			
			--> cria a nova tabela de combates -- create new table
			local ultimo_combate = _detalhes.tabela_vigente
			_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (true, _detalhes.tabela_overall, n_combate, ...) --cria uma nova tabela de combate
			_detalhes.tabela_vigente.previous_combat = ultimo_combate
			
			--> verifica se há alguma instância mostrando o segmento atual -- change segment
			_detalhes:InstanciaCallFunction (_detalhes.TrocaSegmentoAtual)

			_detalhes.tabela_vigente:seta_data (_detalhes._detalhes_props.DATA_TYPE_START) --seta na tabela do combate a data do inicio do combate -- setup time data
			_detalhes.in_combat = true --sinaliza ao addon que há um combate em andamento -- in combat flag up
			
			_detalhes.tabela_vigente.combat_id = n_combate --> grava o número deste combate na tabela atual -- setup combat id on new table
			
			--> é o timer que ve se o jogador ta em combate ou não -- check if any party or raid members are in combat
			_detalhes.tabela_vigente.verifica_combate = _detalhes:ScheduleRepeatingTimer ("EstaEmCombate", 1) 

			_table_wipe (_detalhes.encounter_end_table)
			
			_table_wipe (_detalhes.pets_ignored)
			_table_wipe (_detalhes.pets_no_owner)
			_detalhes.container_pets:BuscarPets()
			
			_table_wipe (_detalhes.cache_damage_group)
			_table_wipe (_detalhes.cache_healing_group)
			_detalhes:UpdateParserGears()
			
			_detalhes.host_of = nil
			_detalhes.host_by = nil
			
			if (_detalhes.in_group and _detalhes.cloud_capture) then
				if (_detalhes:IsInInstance() or _detalhes.debug) then
					if (not _detalhes:CaptureIsAllEnabled()) then
						_detalhes:ScheduleSendCloudRequest()
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) requesting a cloud server.")
						end
					end
				else
					if (_detalhes.debug) then
						_detalhes:Msg ("(debug) isn't inside a registred instance", _detalhes:IsInInstance())
					end
				end
			else
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) isn't in group or cloud is turned off", _detalhes.in_group, _detalhes.cloud_capture)
				end
			end
			
			_detalhes:CatchRaidBuffUptime ("BUFF_UPTIME_IN")
			_detalhes:CatchRaidDebuffUptime ("DEBUFF_UPTIME_IN")
			_detalhes:UptadeRaidMembersCache()
			
			--> hide / alpha / switch in combat
			for index, instancia in ipairs (_detalhes.tabela_instancias) do 
				if (instancia.ativa) then
					--instancia:SetCombatAlpha (nil, nil, true) --passado para o regen disable
					instancia:CheckSwitchOnCombatStart (true)
				end
			end
			
			_detalhes:SendEvent ("COMBAT_PLAYER_ENTER", nil, _detalhes.tabela_vigente)
			_detalhes:HaveOneCurrentInstance()
			
		end
		
		function _detalhes:DelayedSyncAlert()
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (lower_instance) then
				lower_instance = _detalhes:GetInstance (lower_instance)
				if (lower_instance) then
					if (not lower_instance:HaveInstanceAlert()) then
						lower_instance:InstanceAlert (Loc ["STRING_EQUILIZING"], {[[Interface\COMMON\StreamCircle]], 22, 22, true}, 5, {function() end})
					end
				end
			end
		end
		
		-- ~end
		function _detalhes:SairDoCombate (bossKilled, from_encounter_end)
		
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) ended a combat.")
			end
			
			_detalhes.leaving_combat = true
			
			if (_detalhes.schedule_remove_overall and not from_encounter_end and not InCombatLockdown()) then
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) found schedule overall data deletion.")
				end
				_detalhes.schedule_remove_overall = false
				_detalhes.tabela_historico:resetar_overall()
			end
			
			_detalhes:CatchRaidBuffUptime ("BUFF_UPTIME_OUT")
			_detalhes:CatchRaidDebuffUptime ("DEBUFF_UPTIME_OUT")
			_detalhes:CloseEnemyDebuffsUptime()
			
			--> ugly fix for warlocks soul link, need to rewrite friendly fire code.
			for index, actor in pairs (_detalhes.tabela_vigente[1]._ActorTable) do
				if (actor.classe == "WARLOCK") then
					local soullink = actor.spell_tables._ActorTable [108446]
					if (soullink) then
						actor.total = actor.total - soullink.total
						actor.total_without_pet = actor.total_without_pet - soullink.total
						soullink.total = 0
					end
				end
			end
			
			--> pega a zona do jogador e vê se foi uma luta contra um Boss -- identifica se a luta foi com um boss
			if (not _detalhes.tabela_vigente.is_boss) then 
		
				--> function which runs after a boss encounter to try recognize a encounter
				_detalhes:FindBoss()
				
				if (not _detalhes.tabela_vigente.is_boss) then
					local ZoneName, _, DifficultyID, _, _, _, _, ZoneMapID = _GetInstanceInfo()
					local findboss = _detalhes:GetRaidBossFindFunction (ZoneMapID)
					if (findboss) then
						local BossIndex = findboss()
						if (BossIndex) then
							boss_found (BossIndex, _detalhes:GetBossName (ZoneMapID, BossIndex), ZoneName, ZoneMapID, DifficultyID)
						end
					end
				end
			end
			
			if (_detalhes.tabela_vigente.bossFunction) then
				_detalhes:CancelTimer (_detalhes.tabela_vigente.bossFunction)
				_detalhes.bossFunction = nil
			end

			--> finaliza a checagem se esta ou não no combate -- finish combat check
			if (_detalhes.tabela_vigente.verifica_combate) then 
				_detalhes:CancelTimer (_detalhes.tabela_vigente.verifica_combate)
				_detalhes.tabela_vigente.verifica_combate = nil
			end

			--> lock timers
			_detalhes.tabela_vigente:TravarTempos() 
			
			_detalhes.tabela_vigente:seta_data (_detalhes._detalhes_props.DATA_TYPE_END) --> salva hora, minuto, segundo do fim da luta
			_detalhes.tabela_overall:seta_data (_detalhes._detalhes_props.DATA_TYPE_END) --> salva hora, minuto, segundo do fim da luta
			_detalhes.tabela_vigente:seta_tempo_decorrido() --> salva o end_time
			_detalhes.tabela_overall:seta_tempo_decorrido() --seta o end_time
			
			--> drop last events table to garbage collector
			_detalhes.tabela_vigente.player_last_events = {}
			
			--> flag instance type
			local _, InstanceType = _GetInstanceInfo()
			_detalhes.tabela_vigente.instance_type = InstanceType
			
			if (not _detalhes.tabela_vigente.is_boss) then

				if (InstanceType == "party" or InstanceType == "raid") then
					_detalhes.tabela_vigente.is_trash = true
				end
				
				if (not _detalhes.tabela_vigente.enemy) then
					local enemy = _detalhes:FindEnemy()
					
					if (enemy and _detalhes.debug) then
						_detalhes:Msg ("(debug) enemy found", enemy)
					end
					
					_detalhes.tabela_vigente.enemy = enemy
				end
				
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) forcing equalize actors behavior.")
					_detalhes:EqualizeActorsSchedule (_detalhes.host_of)
				end
				
				--> verifica memoria
				_detalhes:FlagActorsOnCommonFight() --fight_component
				_detalhes:CheckMemoryAfterCombat()
				
			else
			
				if (not InCombatLockdown() and not UnitAffectingCombat ("player")) then
					_detalhes:FlagActorsOnBossFight()
				else
					_detalhes.schedule_flag_boss_components = true
				end

				if (_detalhes:GetBossDetails (_detalhes.tabela_vigente.is_boss.mapid, _detalhes.tabela_vigente.is_boss.index)) then
					
					_detalhes.tabela_vigente.enemy = _detalhes.tabela_vigente.is_boss.encounter

					if (_detalhes.tabela_vigente.instance_type == "raid") then
					
						_detalhes.last_encounter2 = _detalhes.last_encounter
						_detalhes.last_encounter = _detalhes.tabela_vigente.is_boss.name

						if (_detalhes.pre_pot_used and _detalhes.announce_prepots.enabled) then
							_detalhes:Msg (_detalhes.pre_pot_used or "")
							_detalhes.pre_pot_used = nil
						end
					end
					
					if (bossKilled) then
						_detalhes.tabela_vigente.is_boss.killed = true
					end
					
					if (from_encounter_end) then
						_detalhes.tabela_vigente.end_time = _detalhes.encounter_table ["end"]
					end

					--> encounter boss function
					local bossFunction, bossFunctionType = _detalhes:GetBossFunction (_detalhes.tabela_vigente.is_boss.mapid, _detalhes.tabela_vigente.is_boss.index)
					if (bossFunction) then
						if (_bit_band (bossFunctionType, 0x2) ~= 0) then --end of combat
							bossFunction()
						end
					end
					
					if (_detalhes.tabela_vigente.instance_type == "raid") then
						--> schedule captures off
						
						_detalhes:CaptureSet (false, "damage", false, 15)
						_detalhes:CaptureSet (false, "energy", false, 15)
						_detalhes:CaptureSet (false, "aura", false, 15)
						_detalhes:CaptureSet (false, "energy", false, 15)
						_detalhes:CaptureSet (false, "spellcast", false, 15)
						
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) freezing parser for 15 seconds.")
						end
					end
					
					--> schedule sync
					_detalhes:EqualizeActorsSchedule (_detalhes.host_of)
					if (_detalhes:GetEncounterEqualize (_detalhes.tabela_vigente.is_boss.mapid, _detalhes.tabela_vigente.is_boss.index)) then
						_detalhes:ScheduleTimer ("DelayedSyncAlert", 3)
					end
					
				else
					if (_detalhes.debug) then
						_detalhes:EqualizeActorsSchedule (_detalhes.host_of)
					end
				end
			end

			if (_detalhes.solo) then
				--> debuffs need a checkup, not well functional right now
				_detalhes.CloseSoloDebuffs()
			end
			
			local tempo_do_combate = _detalhes.tabela_vigente.end_time - _detalhes.tabela_vigente.start_time
			
			--if ( tempo_do_combate >= _detalhes.minimum_combat_time) then --> tempo minimo precisa ser 5 segundos pra acrecentar a tabela ao historico
			if ( tempo_do_combate >= 5 or not _detalhes.tabela_historico.tabelas[1]) then --> tempo minimo precisa ser 5 segundos pra acrecentar a tabela ao historico
				_detalhes.tabela_historico:adicionar (_detalhes.tabela_vigente) --move a tabela atual para dentro do histórico
			else
				--> this is a little bit complicated, need a specific function for combat cancellation
			
				--_table_wipe (_detalhes.tabela_vigente) --> descarta ela, não será mais usada
				_detalhes.tabela_vigente = _detalhes.tabela_historico.tabelas[1] --> pega a tabela do ultimo combate

				if (_detalhes.tabela_vigente.start_time == 0) then
					_detalhes.tabela_vigente.start_time = _detalhes._tempo
					_detalhes.tabela_vigente.end_time = _detalhes._tempo
				end
				
				_detalhes.tabela_vigente.resincked = true
				
				--> tabela foi descartada, precisa atualizar os baseframes // precisa atualizer todos ou apenas o overall?
				_detalhes:InstanciaCallFunction (_detalhes.AtualizarJanela)
				
				if (_detalhes.solo) then
					local esta_instancia = _detalhes.tabela_instancias[_detalhes.solo]
					if (_detalhes.SoloTables.CombatID == _detalhes:NumeroCombate()) then --> significa que o solo mode validou o combate, como matar um bixo muito low level com uma só porrada
						if (_detalhes.SoloTables.CombatIDLast and _detalhes.SoloTables.CombatIDLast ~= 0) then --> volta os dados da luta anterior
						
							_detalhes.SoloTables.CombatID = _detalhes.SoloTables.CombatIDLast
						
						else
							if (_detalhes.RefreshSolo) then
								_detalhes:RefreshSolo()
							end
							_detalhes.SoloTables.CombatID = nil
						end
					end
				end
				
				_detalhes:NumeroCombate (-1)
			end
			
			_detalhes.host_of = nil
			_detalhes.host_by = nil
			
			if (_detalhes.cloud_process) then
				_detalhes:CancelTimer (_detalhes.cloud_process)
			end
			
			_detalhes.in_combat = false --sinaliza ao addon que não há combate no momento
			_detalhes.leaving_combat = false --sinaliza que não esta mais saindo do combate
			
			_table_wipe (_detalhes.cache_damage_group)
			_table_wipe (_detalhes.cache_healing_group)
			
			_detalhes:UpdateParserGears()
			
			--> hide / alpha in combat
			for index, instancia in ipairs (_detalhes.tabela_instancias) do 
				if (instancia.ativa) then
					--instancia:SetCombatAlpha (nil, nil, true) --passado para o regen enabled
					if (instancia.auto_switch_to_old) then
						instancia:CheckSwitchOnCombatEnd()
					end
				end
			end
			
			_detalhes.pre_pot_used = nil
			_table_wipe (_detalhes.encounter_table)
			
			_detalhes:SendEvent ("COMBAT_PLAYER_LEAVE", nil, _detalhes.tabela_vigente)
		end

		function _detalhes:GetPlayersInArena()
			local aliados = GetNumGroupMembers (LE_PARTY_CATEGORY_HOME)
			for i = 1, aliados-1 do
				local role = UnitGroupRolesAssigned ("party" .. i)
				if (role ~= "NONE") then
					local name = GetUnitName ("party" .. i, true)
					_detalhes.arena_table [name] = {role = role}
				end
			end
			
			local role = UnitGroupRolesAssigned ("player")
			if (role ~= "NONE") then
				local name = GetUnitName ("player", true)
				_detalhes.arena_table [name] = {role = role}
			end
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) Found", oponentes, "enemies and", aliados, "allies")
			end
		end
		
		function _detalhes:CreateArenaSegment()
		
			_detalhes:GetPlayersInArena()
		
			_detalhes.arena_begun = true
			_detalhes.start_arena = nil
		
			if (_detalhes.in_combat) then
				_detalhes:SairDoCombate()
			end
		
			--> inicia um novo combate
			_detalhes:EntrarEmCombate()
		
			--> sinaliza que esse combate é arena
			_detalhes.tabela_vigente.arena = true
			_detalhes.tabela_vigente.is_arena = {name = _detalhes.zone_name, zone = _detalhes.zone_name, mapid = _detalhes.zone_id}
		end
		
		function _detalhes:StartArenaSegment (...)
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) starting a new arena segment.")
			end
			
			local timerType, timeSeconds, totalTime = select (1, ...)
			
			if (_detalhes.start_arena) then
				_detalhes:CancelTimer (_detalhes.start_arena, true)
			end
			_detalhes.start_arena = _detalhes:ScheduleTimer ("CreateArenaSegment", timeSeconds)
			_detalhes:GetPlayersInArena()
		end

		function _detalhes:EnteredInArena()

			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) arena detected.")
			end
		
			_detalhes.arena_begun = false

			_detalhes:GetPlayersInArena()
		end
		
		function _detalhes:LeftArena()
		
			_detalhes.is_in_arena = false
			_detalhes.arena_begun = false
		
			if (_detalhes.start_arena) then
				_detalhes:CancelTimer (_detalhes.start_arena, true)
			end
		end
		
		function _detalhes:MakeEqualizeOnActor (player, realm, receivedActor)
		
			local combat = _detalhes:GetCombat ("current")
			local damage, heal, energy, misc = _detalhes:GetAllActors ("current", player)
			
			if (not damage and not heal and not energy and not misc) then
			
				--> try adding server name
				damage, heal, energy, misc = _detalhes:GetAllActors ("current", player.."-"..realm)
				
				if (not damage and not heal and not energy and not misc) then
					--> not found any actor object, so we need to create
					
					local actorName
					
					if (realm ~= GetRealmName()) then
						actorName = player.."-"..realm
					else
						actorName = player
					end
					
					local guid = _detalhes:FindGUIDFromName (player)
					
					-- 0x512 normal party
					-- 0x514 normal raid
					
					if (guid) then
						damage = combat [1]:PegarCombatente (guid, actorName, 0x514, true)
						heal = combat [2]:PegarCombatente (guid, actorName, 0x514, true)
						energy = combat [3]:PegarCombatente (guid, actorName, 0x514, true)
						misc = combat [4]:PegarCombatente (guid, actorName, 0x514, true)
						
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) equalize received actor:", actorName, damage, heal)
						end
					else
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) equalize couldn't get guid for player ",player)
						end
					end
				end
			end
			
			combat[1].need_refresh = true
			combat[2].need_refresh = true
			combat[3].need_refresh = true
			combat[4].need_refresh = true
			
			if (damage) then
				if (damage.total < receivedActor [1][1]) then
					if (_detalhes.debug) then
						_detalhes:Msg (player .. " damage before: " .. damage.total .. " damage received: " .. receivedActor [1][1])
					end
					damage.total = receivedActor [1][1]
				end
				if (damage.damage_taken < receivedActor [1][2]) then
					damage.damage_taken = receivedActor [1][2]
				end
				if (damage.friendlyfire_total < receivedActor [1][3]) then
					damage.friendlyfire_total = receivedActor [1][3]
				end
			end
			
			if (heal) then
				if (heal.total < receivedActor [2][1]) then
					heal.total = receivedActor [2][1]
				end
				if (heal.totalover < receivedActor [2][2]) then
					heal.totalover = receivedActor [2][2]
				end
				if (heal.healing_taken < receivedActor [2][3]) then
					heal.healing_taken = receivedActor [2][3]
				end
			end
			
			if (energy) then
				if (energy.mana and (receivedActor [3][1] > 0 and energy.mana < receivedActor [3][1])) then
					energy.mana = receivedActor [3][1]
				end
				if (energy.e_rage and (receivedActor [3][2] > 0 and energy.e_rage < receivedActor [3][2])) then
					energy.e_rage = receivedActor [3][2]
				end
				if (energy.e_energy and (receivedActor [3][3] > 0 and energy.e_energy < receivedActor [3][3])) then
					energy.e_energy = receivedActor [3][3]
				end
				if (energy.runepower and (receivedActor [3][4] > 0 and energy.runepower < receivedActor [3][4])) then
					energy.runepower = receivedActor [3][4]
				end
			end
			
			if (misc) then
				if (misc.interrupt and (receivedActor [4][1] > 0 and misc.interrupt < receivedActor [4][1])) then
					misc.interrupt = receivedActor [4][1]
				end
				if (misc.dispell and (receivedActor [4][2] > 0 and misc.dispell < receivedActor [4][2])) then
					misc.dispell = receivedActor [4][2]
				end
			end
		end
		
		function _detalhes:EqualizePets()
			--> check for pets without owner
			for _, actor in _ipairs (_detalhes.tabela_vigente[1]._ActorTable) do 
				--> have flag and the flag tell us he is a pet
				if (actor.flag_original and bit.band (actor.flag_original, OBJECT_TYPE_PETS) ~= 0) then
					--> do not have owner and he isn't on owner container
					if (not actor.owner and not _detalhes.tabela_pets.pets [actor.serial]) then
						_detalhes:SendPetOwnerRequest (actor.serial, actor.nome)
					end
				end
			end
		end
		
		function _detalhes:EqualizeActorsSchedule (host_of)
		
			--> store pets sent through 'needpetowner'
			_detalhes.sent_pets = _detalhes.sent_pets or {n = time()}
			if (_detalhes.sent_pets.n+20 < time()) then
				_table_wipe (_detalhes.sent_pets)
				_detalhes.sent_pets.n = time()
			end
			
			--> pet equilize disabled on details 1.4.0
			--_detalhes:ScheduleTimer ("EqualizePets", 1+math.random())

			--> do not equilize if there is any disabled capture
			--if (_detalhes:CaptureIsAllEnabled()) then
				_detalhes:ScheduleTimer ("EqualizeActors", 2+math.random()+math.random() , host_of)
			--end
		end
		
		function _detalhes:EqualizeActors (host_of)
		
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) sending equilize actor data")
			end
		
			local damage, heal, energy, misc
		
			if (host_of) then
				damage, heal, energy, misc = _detalhes:GetAllActors ("current", host_of)
			else
				damage, heal, energy, misc = _detalhes:GetAllActors ("current", _detalhes.playername)
			end
			
			if (damage) then
				damage = {damage.total or 0, damage.damage_taken or 0, damage.friendlyfire_total or 0}
			else
				damage = {0, 0, 0}
			end
			
			if (heal) then
				heal = {heal.total or 0, heal.totalover or 0, heal.healing_taken or 0}
			else
				heal = {0, 0, 0}
			end
			
			if (energy) then
				energy = {energy.mana or 0, energy.e_rage or 0, energy.e_energy or 0, energy.runepower or 0}
			else
				energy = {0, 0, 0, 0}
			end
			
			if (misc) then
				misc = {misc.interrupt or 0, misc.dispell or 0}
			else
				misc = {0, 0}
			end
			
			local data = {damage, heal, energy, misc}

			--> envia os dados do proprio host pra ele antes
			if (host_of) then
				_detalhes:SendRaidDataAs (_detalhes.network.ids.CLOUD_EQUALIZE, host_of, nil, data)
				_detalhes:EqualizeActors()
			else
				_detalhes:SendRaidData (_detalhes.network.ids.CLOUD_EQUALIZE, data)
			end
			
		end
		
		function _detalhes:FlagActorsOnBossFight()
			for class_type, container in _ipairs (_detalhes.tabela_vigente) do 
				for _, actor in _ipairs (container._ActorTable) do 
					actor.boss_fight_component = true
					if (actor.shadow) then 
						actor.shadow.boss_fight_component = true
					end
				end
			end
		end
		
		local fight_component = function (energy_container, misc_container, name)
			local on_energy = energy_container._ActorTable [energy_container._NameIndexTable [name]]
			if (on_energy) then
				on_energy.fight_component = true
				if (on_energy.shadow) then
					on_energy.shadow.fight_component = true
				end
			end
			local on_misc = misc_container._ActorTable [misc_container._NameIndexTable [name]]
			if (on_misc) then
				on_misc.fight_component = true
				if (on_misc.shadow) then
					on_misc.shadow.fight_component = true
				end
			end
		end
		
		function _detalhes:FlagActorsOnCommonFight()
		
			local damage_container = _detalhes.tabela_vigente [1]
			local healing_container = _detalhes.tabela_vigente [2]
			local energy_container = _detalhes.tabela_vigente [3]
			local misc_container = _detalhes.tabela_vigente [4]
			
			for class_type, container in _ipairs ({damage_container, healing_container}) do 
			
				for _, actor in _ipairs (container._ActorTable) do 
					if (actor.grupo) then
						if (class_type == 1 or class_type == 2) then
							for _, target_actor in _ipairs (actor.targets._ActorTable) do 
								local target_object = container._ActorTable [container._NameIndexTable [target_actor.nome]]
								if (target_object) then
									target_object.fight_component = true
									if (target_object.shadow) then
										target_object.shadow.fight_component = true
									end
									fight_component (energy_container, misc_container, target_actor.nome)
								end
							end
							if (class_type == 1) then
								for damager_actor, _ in _pairs (actor.damage_from) do 
									local target_object = container._ActorTable [container._NameIndexTable [damager_actor]]
									if (target_object) then
										target_object.fight_component = true
										if (target_object.shadow) then
											target_object.shadow.fight_component = true
										end
										fight_component (energy_container, misc_container, damager_actor)
									end
								end
							elseif (class_type == 2) then
								for healer_actor, _ in _pairs (actor.healing_from) do 
									local target_object = container._ActorTable [container._NameIndexTable [healer_actor]]
									if (target_object) then
										target_object.fight_component = true
										if (target_object.shadow) then
											target_object.shadow.fight_component = true
										end
										fight_component (energy_container, misc_container, healer_actor)
									end
								end
							end
						end
					end
				end
				
			end
		end

		function _detalhes:AtualizarJanela (instancia, _segmento)
			if (_segmento) then --> apenas atualizar janelas que estejam mostrando o segmento solicitado
				if (_segmento == instancia.segmento) then
					instancia:TrocaTabela (instancia, instancia.segmento, instancia.atributo, instancia.sub_atributo, true)
				end
			else
				if (instancia.modo == modo_GROUP or instancia.modo == modo_ALL) then
					instancia:TrocaTabela (instancia, instancia.segmento, instancia.atributo, instancia.sub_atributo, true)
				end
			end
		end

		function _detalhes:TrocaSegmentoAtual (instancia)
			if (instancia.segmento == 0) then --> esta mostrando a tabela Atual
				instancia.showing =_detalhes.tabela_vigente
				instancia:ResetaGump()
				_detalhes.gump:Fade (instancia, "in", nil, "barras")
			end
		end

	--> internal GetCombatId() version
		function _detalhes:NumeroCombate (flag)
			if (flag == 0) then
				_detalhes.combat_id = 0
			elseif (flag) then
				_detalhes.combat_id = _detalhes.combat_id + flag
			end
			return _detalhes.combat_id
		end

	--> tooltip fork / search key: ~tooltip
		local avatarPoint = {"bottomleft", "topleft", -3, -4}
		local backgroundPoint = {{"bottomleft", "topleft", 0, -3}, {"bottomright", "topright", 0, -3}}
		local textPoint = {"left", "right", -11, -5}
		local avatarTexCoord = {0, 1, 0, 1}
		
		function _detalhes:AddTooltipBackgroundStatusbar()
			GameCooltip:AddStatusBar (100, 1, unpack (_detalhes.tooltip.background))
		end
		
		function _detalhes:AddTooltipSpellHeaderText (headerText, headerColor, r, g, b, amount)
			if (_detalhes.tooltip.show_amount) then
				GameCooltip:AddLine (headerText, "x" .. amount .. "", nil, headerColor, r, g, b, .2, 12)
			else
				GameCooltip:AddLine (headerText, nil, nil, headerColor, nil, 12)
			end
		end
		
		function _detalhes:MontaTooltip (frame, qual_barra, keydown)
			
			local GameCooltip = GameCooltip
			GameCooltip:Reset()
			GameCooltip:SetType ("tooltip")
			
			GameCooltip:SetOption ("TextSize", _detalhes.tooltip.fontsize)
			GameCooltip:SetOption ("TextFont",  _detalhes.tooltip.fontface)
			GameCooltip:SetOption ("TextColor", _detalhes.tooltip.fontcolor)
			GameCooltip:SetOption ("TextShadow", _detalhes.tooltip.fontshadow and "OUTLINE")
			
			GameCooltip:SetOption ("LeftBorderSize", -5)
			GameCooltip:SetOption ("RightBorderSize", 5)
			GameCooltip:SetOption ("MinWidth", 180)
			GameCooltip:SetOption ("StatusBarTexture", [[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]]) --[[Interface\Addons\Details\images\bar_flat]]
			
			local myPoint = _detalhes.tooltip.anchor_point
			local anchorPoint = _detalhes.tooltip.anchor_relative
			local x_Offset = _detalhes.tooltip.anchor_offset[1]
			local y_Offset = _detalhes.tooltip.anchor_offset[2]
			
			if (_detalhes.tooltip.anchored_to == 1) then
				GameCooltip:SetHost (frame, myPoint, anchorPoint, x_Offset, y_Offset)
			else
				GameCooltip:SetHost (DetailsTooltipAnchor, myPoint, anchorPoint, x_Offset, y_Offset)
			end
			
			local esta_barra = self.barras [qual_barra] --> barra que o mouse passou em cima e irá mostrar o tooltip
			local objeto = esta_barra.minha_tabela --> pega a referencia da tabela --> retorna a classe_damage ou classe_heal
			if (not objeto) then --> a barra não possui um objeto
				return false
			end

			--verifica por tooltips especiais:
			if (objeto.dead) then --> é uma barra de dead
				return _detalhes:ToolTipDead (self, objeto, esta_barra, keydown) --> instância, [morte], barra
			elseif (objeto.frags) then
				return _detalhes:ToolTipFrags (self, objeto, esta_barra, keydown)
			elseif (objeto.boss_debuff) then
				return _detalhes:ToolTipVoidZones (self, objeto, esta_barra, keydown)
			end
			
			local t = objeto:ToolTip (self, qual_barra, esta_barra, keydown) --> instância, nº barra, objeto barra, keydown
			
			if (t) then
			
				if (esta_barra.minha_tabela.serial and esta_barra.minha_tabela.serial ~= "") then
					local avatar = NickTag:GetNicknameTable (esta_barra.minha_tabela.serial)
					if (avatar) then
						if (avatar [2] and avatar [4] and avatar [1]) then
							GameCooltip:SetBannerImage (1, avatar [2], 80, 40, avatarPoint, avatarTexCoord, nil) --> overlay [2] avatar path
							GameCooltip:SetBannerImage (2, avatar [4], 200, 55, backgroundPoint, avatar [5], avatar [6]) --> background
							GameCooltip:SetBannerText (1, avatar [1], textPoint) --> text [1] nickname
						end
					end
				end

				GameCooltip:ShowCooltip()
			end
		end
		
		function _detalhes.gump:UpdateTooltip (qual_barra, esta_barra, instancia)
			if (_IsShiftKeyDown()) then
				return instancia:MontaTooltip (esta_barra, qual_barra, "shift")
			elseif (_IsControlKeyDown()) then
				return instancia:MontaTooltip (esta_barra, qual_barra, "ctrl")
			elseif (_IsAltKeyDown()) then
				return instancia:MontaTooltip (esta_barra, qual_barra, "alt")
			else
				return instancia:MontaTooltip (esta_barra, qual_barra)
			end
		end

		function _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing)
			_detalhes:EsconderBarrasNaoUsadas (instancia, showing)
		end
		
		function _detalhes:EsconderBarrasNaoUsadas (instancia, showing)
			--> primeira atualização após uma mudança de segmento -->  verifica se há mais barras sendo mostradas do que o necessário	
			--------------------
				if (instancia.v_barras) then
					for barra_numero = instancia.rows_showing+1, instancia.rows_created do
						_detalhes.gump:Fade (instancia.barras[barra_numero], "in")
					end
					instancia.v_barras = false
				end

			return showing
		end

	--> call update functions
		function _detalhes:AtualizarALL (forcar)

			local tabela_do_combate = self.showing

			--> confere se a instância possui uma tabela válida
			if (not tabela_do_combate) then
				if (not self.freezed) then
					return self:Freeze()
				end
				return
			end

			local need_refresh = tabela_do_combate[self.atributo].need_refresh
			if (not need_refresh and not forcar) then
				return --> não precisa de refresh
			--else
				--tabela_do_combate[self.atributo].need_refresh = false
			end
			
			if (self.atributo == 1) then --> damage
				return atributo_damage:RefreshWindow (self, tabela_do_combate, forcar, nil, need_refresh)
			elseif (self.atributo == 2) then --> heal
				return atributo_heal:RefreshWindow (self, tabela_do_combate, forcar, nil, need_refresh)
			elseif (self.atributo == 3) then --> energy
				return atributo_energy:RefreshWindow (self, tabela_do_combate, forcar, nil, need_refresh)
			elseif (self.atributo == 4) then --> outros
				return atributo_misc:RefreshWindow (self, tabela_do_combate, forcar, nil, need_refresh)
			elseif (self.atributo == 5) then --> ocustom
				return atributo_custom:RefreshWindow (self, tabela_do_combate, forcar, nil, need_refresh)
			end

		end

		function _detalhes:AtualizaGumpPrincipal (instancia, forcar)
			
			if (not instancia or type (instancia) == "boolean") then --> o primeiro parâmetro não foi uma instância ou ALL
				forcar = instancia
				instancia = self
			end
			
			if (instancia == -1) then
	
				--> update
				for index, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
					if (esta_instancia.ativa) then
						if (esta_instancia.modo == modo_GROUP or esta_instancia.modo == modo_ALL) then
							esta_instancia:AtualizarALL (forcar)
						end
					end
				end
				
				--> marcar que não precisa ser atualizada
				for index, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
					if (esta_instancia.ativa and esta_instancia.showing) then
						if (esta_instancia.modo == modo_GROUP or esta_instancia.modo == modo_ALL) then
							if (esta_instancia.atributo <= 4) then
								esta_instancia.showing [esta_instancia.atributo].need_refresh = false
							end
						end
					end
				end

				if (not forcar) then --atualizar o gump de detalhes também se ele estiver aberto
					if (info.ativo) then
						return info.jogador:MontaInfo()
					end
				end
				
				return
				
			else
				if (not instancia.ativa) then
					return
				end
			end
			
			if (instancia.modo == modo_ALL or instancia.modo == modo_GROUP) then
				return instancia:AtualizarALL (forcar)
			end
		end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function _detalhes:UpdateControl()
		_tempo = _detalhes._tempo
	end			
