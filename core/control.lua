--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.

	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _tempo = time()
	
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

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions

	--> try to find the opponent of last fight, can be called during a fight as well
		function _detalhes:FindEnemy()
			
			for _, actor in _ipairs (_detalhes.tabela_vigente[class_type_dano]._ActorTable) do 
				if (not actor.grupo and not actor.owner and not actor.nome:find ("[*]") and _bit_band (actor.flag, 0x00000060) ~= 0) then --> 0x20+0x40 neutral + enemy reaction
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
			
			return Loc ["STRING_UNKNOW"]
		end
	
	-- try get the current encounter name during the encounter
		function _detalhes:ReadBossFrames()
			for index = 1, 5, 1 do 
				if (_UnitExists ("boss"..index)) then 
					local guid = _UnitGUID ("boss"..index)
					if (guid) then
						local serial = tonumber (guid:sub(6, 10), 16)
						
						if (serial) then
						
							local ZoneName, _, _, _, _, _, _, ZoneMapID = _GetInstanceInfo()
						
							local BossIds = _detalhes:GetBossIds (ZoneMapID)
							if (BossIds) then
								local BossIndex = BossIds [serial]

								if (BossIndex) then 
								
									if (_detalhes.in_combat) then
										local bossFunction, bossFunctionType = _detalhes:GetBossFunction (ZoneMapID, BossIndex)
										if (bossFunction) then
											if (_bit_band (bossFunctionType, 0x1) ~= 0) then --realtime
												_detalhes.bossFunction = bossFunction
												local combat = _detalhes:GetCombat ("current")
												combat.bossFunction = _detalhes:ScheduleTimer ("bossFunction", 1)
											end
										end
									end
								
									_detalhes.tabela_vigente.is_boss = {
										index = BossIndex, 
										name = _detalhes:GetBossName (ZoneMapID, BossIndex),
										zone = ZoneName, 
										mapid = ZoneMapID, 
										encounter = _detalhes:GetBossName (ZoneMapID, BossIndex)
										}
									_detalhes:SendEvent ("COMBAT_BOSS_FOUND", nil, _detalhes.tabela_vigente.is_boss.index, _detalhes.tabela_vigente.is_boss.name)
									return _detalhes.tabela_vigente.is_boss
								end
							end
						end
					end
				end
			end
		end	
	
	--try to get the encounter name after the encounter (can be called during the combat as well)
		function _detalhes:FindBoss()

			local ZoneName, _, _, _, _, _, _, ZoneMapID = _GetInstanceInfo()
			local BossIds = _detalhes:GetBossIds (ZoneMapID)
			
			if (BossIds) then	
				local BossIndex = nil
				local ActorsContainer = _detalhes.tabela_vigente [class_type_dano]._ActorTable
				
				if (ActorsContainer) then
					for index, Actor in _ipairs (ActorsContainer) do 
						if (not Actor.grupo) then
							local serial = tonumber (Actor.serial:sub(6, 10), 16)
							if (serial) then
								BossIndex = BossIds [serial]
								if (BossIndex) then
									Actor.boss = true
									Actor.shadow.boss = true
									_detalhes:FlagActorsOnBossFight()
									return {
										index = BossIndex, 
										name =_detalhes:GetBossName (ZoneMapID, BossIndex), 
										zone = ZoneName, 
										mapid = ZoneMapID, 
										encounter = _detalhes:GetBossName (ZoneMapID, BossIndex)}
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

		function _detalhes:EntrarEmCombate (...)

			if (_detalhes.debug) then
				print ("Details started a new combat.")
			end

			--> não tem historico, addon foi resetado, a primeira tabela é descartada -- Erase first table is does not have a firts segment history, this occour after reset or first run
			if (not _detalhes.tabela_historico.tabelas[1]) then 
				--> precisa zerar aqui a tabela overall
				_table_wipe (_detalhes.tabela_overall)
				_table_wipe (_detalhes.tabela_vigente)
				--> aqui ele perdeu o self.showing das instâncias, precisa fazer com que elas atualizem
				_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
				
				_detalhes:InstanciaCallFunction (_detalhes.ResetaGump, _, -1) --> reseta scrollbar, iterators, rodapé, etc
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
			_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (true, _detalhes.tabela_overall, n_combate, ...) --cria uma nova tabela de combate
			
			--> verifica se há alguma instância mostrando o segmento atual -- change segment
			_detalhes:InstanciaCallFunction (_detalhes.TrocaSegmentoAtual)

			_detalhes.tabela_vigente:seta_data (_detalhes._detalhes_props.DATA_TYPE_START) --seta na tabela do combate a data do inicio do combate -- setup time data
			_detalhes.in_combat = true --sinaliza ao addon que há um combate em andamento -- in combat flag up
			
			_detalhes.tabela_vigente.combat_id = n_combate --> grava o número deste combate na tabela atual -- setup combat id on new table
			
			--> é o timer que ve se o jogador ta em combate ou não -- check if any party or raid members are in combat
			_detalhes.tabela_vigente.verifica_combate = _detalhes:ScheduleRepeatingTimer ("EstaEmCombate", 1) 

			_detalhes.container_pets:BuscarPets()
			
			table.wipe (_detalhes.cache_damage_group)
			table.wipe (_detalhes.cache_healing_group)
			_detalhes:UpdateParserGears()
			
			_detalhes.host_of = nil
			_detalhes.host_by = nil
			
			if (_detalhes.in_group and _detalhes.cloud_capture) then
				if (_detalhes:IsInInstance() or _detalhes.debug) then
					if (not _detalhes:CaptureIsAllEnabled()) then
						_detalhes:SendCloudRequest()
						if (_detalhes.debug) then
							_detalhes:Msg ("Details: CloudRequest()")
						end
					end
				else
					if (_detalhes.debug) then
						_detalhes:Msg ("Details: instance", _detalhes:IsInInstance())
					end
				end
			else
				if (_detalhes.debug) then
					_detalhes:Msg ("Details: group and cloud", _detalhes.in_group, _detalhes.cloud_capture)
				end
			end
			
			_detalhes:SendEvent ("COMBAT_PLAYER_ENTER", nil, _detalhes.tabela_vigente)
		end

		function _detalhes:SairDoCombate()

			--> pega a zona do jogador e vê se foi uma luta contra um Boss -- identifica se a luta foi com um boss
			if (not _detalhes.tabela_vigente.is_boss) then 
				_detalhes.tabela_vigente.is_boss = _detalhes:FindBoss()
			else
				_detalhes:FlagActorsOnBossFight()
			end
			
			if (_detalhes.debug) then
				print ("Details ended a combat.")
			end
			
			if (not _detalhes.tabela_vigente.is_boss) then
				local inimigo = _detalhes:FindEnemy()
				if (inimigo) then
					if (_detalhes.debug) then
						print ("Details last fight against: " .. inimigo)
					end
				end
				_detalhes.tabela_vigente.enemy = inimigo
				if (_detalhes.debug) then
					_detalhes:EqualizeActorsSchedule()
				end
			else
			
				if (_detalhes:GetBossDetails (_detalhes.tabela_vigente.is_boss.mapid, _detalhes.tabela_vigente.is_boss.index)) then
					_detalhes.tabela_vigente.enemy = _detalhes.tabela_vigente.is_boss.encounter
					_detalhes:CaptureSet (false, "damage", false, 30)
					_detalhes:CaptureSet (false, "heal", false, 30)
					
					if (_detalhes.debug) then
						print ("Details found a boss on last fight, freezing parser for 30 seconds.")
					end
					
					local bossFunction, bossFunctionType = _detalhes:GetBossFunction (_detalhes.tabela_vigente.is_boss.mapid, _detalhes.tabela_vigente.is_boss.index)
					if (bossFunction) then
						if (_bit_band (bossFunctionType, 0x2) ~= 0) then --end of combat
							bossFunction()
						end
					end
					
					_detalhes:EqualizeActorsSchedule()
				else
					if (_detalhes.debug) then
						_detalhes:EqualizeActorsSchedule()
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

			if (_detalhes.solo) then
				--> debuffs need a checkup, not well functional right now
				_detalhes.CloseSoloDebuffs()
			end
			
			local tempo_do_combate = _detalhes.tabela_vigente.end_time - _detalhes.tabela_vigente.start_time
			
			--if ( tempo_do_combate >= _detalhes.minimum_combat_time) then --> tempo minimo precisa ser 5 segundos pra acrecentar a tabela ao historico
			if ( tempo_do_combate >= 10) then --> tempo minimo precisa ser 5 segundos pra acrecentar a tabela ao historico
				_detalhes.tabela_historico:adicionar (_detalhes.tabela_vigente) --move a tabela atual para dentro do histórico
			else
				--> this is a little bit complicated, need a specific function for combat cancellation
			
				if (_detalhes.tabela_overall.end_time) then --> no inicio do combate o tempo do overall vai pra NIL o.0
					_detalhes.tabela_overall.start_time = _detalhes.tabela_overall.start_time + tempo_do_combate --> assim ele descarta o tempo de combate na tabela do everall
				else
					_detalhes.tabela_overall.start_time = 0 --> tempo inicio igual a zero pois se o end_time é NIL significa que é a primeira vez que ocorre o combate na tabela overall
				end
				
				_detalhes.tabela_overall = _detalhes.tabela_overall - _detalhes.tabela_vigente --> isso aqui é novo, ele vai subtrair da overall qualquer dado adicionado na tabela descardata
				_table_wipe (_detalhes.tabela_vigente) --> descarta ela, não será mais usada
				
				_detalhes.tabela_vigente = _detalhes.tabela_historico.tabelas[1] --> pega a tabela do ultimo combate
				if (not _detalhes.tabela_vigente) then --> provavel foi o primeiro combate após um reset
					_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (false, _detalhes.tabela_overall) --cria uma nova tabela de combate caso não tenha nenhuma no historico
				end
				
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
							_detalhes:RefreshSolo()
						
						else
							_detalhes:RefreshSolo()
							_detalhes.SoloTables.CombatID = nil
						end
					end
				end
				
				_detalhes:NumeroCombate (-1)
				_detalhes:UpdateParserGears()
			end
			
			_detalhes.host_of = nil
			_detalhes.host_by = nil
			
			if (_detalhes.cloud_process) then
				_detalhes:CancelTimer (_detalhes.cloud_process)
			end
			
			_detalhes.in_combat = false --sinaliza ao addon que não há combate no momento
			
			table.wipe (_detalhes.cache_damage_group)
			table.wipe (_detalhes.cache_healing_group)
			_detalhes:UpdateParserGears()
			
			_detalhes:SendEvent ("COMBAT_PLAYER_LEAVE", nil, _detalhes.tabela_vigente)
		end

		function _detalhes:MakeEqualizeOnActor (player, realm, receivedActor)
		
			local damage, heal, energy, misc = _detalhes:GetAllActors ("current", player)
			
			if (not damage and not heal) then
				--> add server name
				damage, heal, energy, misc = _detalhes:GetAllActors ("current", player.."-"..realm)
			end
			
			local combat = _detalhes:GetCombat ("current")
			combat[1].need_refresh = true
			combat[2].need_refresh = true
			combat[3].need_refresh = true
			combat[4].need_refresh = true
			
			if (damage) then
				if (damage.total < receivedActor [1][1]) then
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
		
		function _detalhes:EqualizeActorsSchedule()
			--> check for pets without owner
			for _, actor in _ipairs (_detalhes.tabela_vigente[1]._ActorTable) do 
				--> have flag and the flag tell us he is a pet
				if (actor.flag_original and bit.band (actor.flag_original, OBJECT_TYPE_PETS) ~= 0) then
					--> do not have owner and he isn't on owner container
					if (not actor.owner and not _detalhes.container_pets.pets [actor.serial]) then
						_detalhes:SendPetOwnerRequest (actor.serial, actor.nome)
					end
				end
			end
			_detalhes:ScheduleTimer ("EqualizeActors", 2)
		end
		
		function _detalhes:EqualizeActors()
		
			local damage, heal, energy, misc = _detalhes:GetAllActors ("current", UnitName ("player"))
			
			if (damage) then
				damage = {damage.total, damage.damage_taken, damage.friendlyfire_total}
			else
				damage = {0, 0, 0}
			end
			
			if (heal) then
				heal = {heal.total, heal.totalover, heal.healing_taken}
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
			
			_detalhes:SendRaidData ("equalize_actors", data)
			
		end
		
		function _detalhes:FlagActorsOnBossFight()
			for class_type, container in _ipairs (_detalhes.tabela_vigente) do 
				for _, actor in _ipairs (container._ActorTable) do 
					if (not actor.grupo and not actor.boss) then 
						if (_bit_band (actor.flag, _detalhes.flags.friend) == 0) then 
							actor.boss_fight_component = true
							local shadow = _detalhes.tabela_overall (class_type, actor.nome)
							if (shadow) then 
								shadow.boss_fight_component = true
							else
								print ("Nao achou a shadow em FlagActorsOnBossFight()")
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

	--> tooltip fork
		function _detalhes:MontaTooltip (qual_barra)

			local esta_barra = self.barras [qual_barra] --> barra que o mouse passou em cima e irá mostrar o tooltip
			local objeto = esta_barra.minha_tabela --> pega a referencia da tabela --> retorna a classe_damage ou classe_heal
			if (not objeto) then --> a barra não possui um objeto
				return false
			end
			_detalhes.popup:Close()
			
			--verifica por tooltips especiais:
			if (objeto.dead) then --> é uma barra de dead
				return _detalhes:ToolTipDead (self, objeto, esta_barra) --> instância, [morte], barra
			end
			
			return objeto:ToolTip (self, qual_barra, esta_barra) --> instância, nº barra, objeto barra
		end


		function _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing)
			_detalhes:EsconderBarrasNaoUsadas (instancia, showing)
		end
		
		function _detalhes:EsconderBarrasNaoUsadas (instancia, showing)
			--> primeira atualização após uma mudança de segmento -->  verifica se há mais barras sendo mostradas do que o necessário	
			--------------------
				if (instancia.v_barras) then
					for barra_numero = instancia.barrasInfo.mostrando+1, instancia.barrasInfo.criadas do
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

			if (not tabela_do_combate[self.atributo].need_refresh and not forcar) then
				return --> não precisa de refresh
			else
				tabela_do_combate[self.atributo].need_refresh = false
			end
			
			if (self.atributo == 1) then --> damage
				
				return atributo_damage:RefreshWindow (self, tabela_do_combate, forcar)
			elseif (self.atributo == 2) then --> heal
				return atributo_heal:RefreshWindow (self, tabela_do_combate, forcar)
			elseif (self.atributo == 3) then --> energy
				return atributo_energy:RefreshWindow (self, tabela_do_combate, forcar)
			elseif (self.atributo == 4) then --> outros
				return atributo_misc:RefreshWindow (self, tabela_do_combate, forcar)
			elseif (self.atributo == 5) then --> ocustom
				return atributo_custom:RefreshWindow (self, tabela_do_combate, forcar)
			end

		end

		function _detalhes:AtualizaGumpPrincipal (instancia, forcar)
			
			if (not instancia or type (instancia) == "boolean") then --> o primeiro parâmetro não foi uma instância ou ALL
				forcar = instancia
				instancia = self
			end
			
			if (instancia == -1) then
				
				local refresh_poll = {}
				
				for _, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
					
					if (esta_instancia.ativa) then
						if (esta_instancia.modo == modo_GROUP or esta_instancia.modo == modo_ALL) then
							local atributo = esta_instancia:AtualizarALL (forcar)

							if (atributo) then
								refresh_poll [#refresh_poll+1] = atributo
							end
						end
					end
					
				end
				
				for _, atributo in _ipairs (refresh_poll) do 
					atributo.need_refresh = false
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