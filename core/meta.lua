--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local _tempo = time()
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers
	local _
	local _pairs = pairs --lua local
	local _ipairs = ipairs --lua local
	local _rawget = rawget --lua local
	local _setmetatable = setmetatable --lua local
	local _table_remove = table.remove --lua local
	local _bit_band = bit.band --lua local
	local _table_wipe = table.wipe --lua local
	local _time = time --lua local
	
	local _InCombatLockdown = InCombatLockdown --wow api local
	
	local atributo_damage =	_detalhes.atributo_damage --details local
	local atributo_heal =		_detalhes.atributo_heal --details local
	local atributo_energy =		_detalhes.atributo_energy --details local
	local atributo_misc =		_detalhes.atributo_misc --details local
	local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade --details local
	local habilidade_dano = 	_detalhes.habilidade_dano --details local
	local habilidade_cura = 		_detalhes.habilidade_cura --details local
	local container_habilidades = 	_detalhes.container_habilidades --details local
	local container_combatentes = _detalhes.container_combatentes --details local

	local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local class_type_dano = _detalhes.atributos.dano
	local class_type_cura = _detalhes.atributos.cura
	local class_type_e_energy = _detalhes.atributos.e_energy
	local class_type_misc = _detalhes.atributos.misc

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	--> reconstrói o mapa do container
		local function ReconstroiMapa (tabela)
			local mapa = {}
			for i = 1, #tabela._ActorTable do
				mapa [tabela._ActorTable[i].nome] = i
			end
			tabela._NameIndexTable = mapa
		end
		
	--> reaplica indexes e metatables
		function _detalhes:RestauraMetaTables()
			
				_detalhes.refresh:r_atributo_custom()
			
			--> container de pets e histórico
				_detalhes.refresh:r_container_pets (_detalhes.tabela_pets)
				_detalhes.refresh:r_historico (_detalhes.tabela_historico)

			--> tabelas dos combates
				local combate_overall = _detalhes.tabela_overall
				local overall_dano = combate_overall [class_type_dano] --> damage atalho
				local overall_cura = combate_overall [class_type_cura] --> heal atalho
				local overall_energy = combate_overall [class_type_e_energy] --> energy atalho
				local overall_misc = combate_overall [class_type_misc] --> misc atalho
			
				local tabelas_do_historico = _detalhes.tabela_historico.tabelas --> atalho

			--> recupera meta function
				for _, combat_table in _ipairs (tabelas_do_historico) do
					combat_table.__call = _detalhes.call_combate
				end
				
				for i = #tabelas_do_historico-1, 1, -1 do
					local combat = tabelas_do_historico [i]
					combat.previous_combat = tabelas_do_historico [i+1]
				end
	
			--> tempo padrao do overall
				combate_overall.start_time = _tempo
				combate_overall.end_time = _tempo
			
			--> inicia a recuperação das tabelas e montagem do overall
				if (#tabelas_do_historico > 0) then
					for index, combate in _ipairs (tabelas_do_historico) do
						
						combate.hasSaved = true
						
						--> aumenta o tempo do combate do overall
						if (combate.end_time and combate.start_time) then 
							combate_overall.start_time = combate_overall.start_time - (combate.end_time - combate.start_time)
						end
					
						--> recupera a meta e indexes da tabela do combate
						_detalhes.refresh:r_combate (combate, combate_overall)
						
						--> recupera a meta e indexes dos 4 container
						_detalhes.refresh:r_container_combatentes (combate [class_type_dano], overall_dano)
						_detalhes.refresh:r_container_combatentes (combate [class_type_cura], overall_cura)
						_detalhes.refresh:r_container_combatentes (combate [class_type_e_energy], overall_energy)
						_detalhes.refresh:r_container_combatentes (combate [class_type_misc], overall_misc)
						
						--> tabela com os 4 tabelas de jogadores
						local todos_atributos = {combate [class_type_dano]._ActorTable, combate [class_type_cura]._ActorTable, combate [class_type_e_energy]._ActorTable, combate [class_type_misc]._ActorTable}

						for class_type, atributo in _ipairs (todos_atributos) do
							for _, esta_classe in _ipairs (atributo) do
							
								local nome = esta_classe.nome
								esta_classe.displayName = nome:gsub (("%-.*"), "")
								
								local shadow

								if (class_type == class_type_dano) then
									if (combate.overall_added) then
										shadow = atributo_damage:r_connect_shadow (esta_classe)
									else
										shadow = atributo_damage:r_onlyrefresh_shadow (esta_classe)
									end

								elseif (class_type == class_type_cura) then
									if (combate.overall_added) then
										shadow = atributo_heal:r_connect_shadow (esta_classe)
									else
										shadow = atributo_heal:r_onlyrefresh_shadow (esta_classe)
									end
									
								elseif (class_type == class_type_e_energy) then
									if (combate.overall_added) then
										shadow = atributo_energy:r_connect_shadow (esta_classe)
									else
										shadow = atributo_energy:r_onlyrefresh_shadow (esta_classe)
									end
									
								elseif (class_type == class_type_misc) then
									if (combate.overall_added) then
										shadow = atributo_misc:r_connect_shadow (esta_classe)
									else
										shadow = atributo_misc:r_onlyrefresh_shadow (esta_classe)
									end
								end

								--shadow:FazLinkagem (esta_classe)

							end
						end
						
						--> reconstrói a tabela dos pets
						for class_type, atributo in _ipairs (todos_atributos) do
							for _, esta_classe in _ipairs (atributo) do
								if (esta_classe.ownerName) then --> nome do owner
									esta_classe.owner = combate (class_type, esta_classe.ownerName)
								end
							end
						end
						
					end
				--fim
				end
			
			--> restaura last_events_table
				local primeiro_combate = tabelas_do_historico [1] --> primeiro combate
				if (primeiro_combate) then
					primeiro_combate [1]:ActorCallFunction (atributo_damage.r_last_events_table)
					primeiro_combate [2]:ActorCallFunction (atributo_heal.r_last_events_table)
				end
				
				local segundo_combate = tabelas_do_historico [2] --> segundo combate
				if (segundo_combate) then
					segundo_combate [1]:ActorCallFunction (atributo_damage.r_last_events_table)
					segundo_combate [2]:ActorCallFunction (atributo_heal.r_last_events_table)
				end
			
		end


	--> limpa indexes, metatables e shadows
		function _detalhes:PrepareTablesForSave()

		----------------------------//overall

			local tabelas_de_combate = {}
			
			local historico_tabelas = _detalhes.tabela_historico.tabelas or {}
			
			if (_detalhes.segments_amount_to_save and _detalhes.segments_amount_to_save < _detalhes.segments_amount) then
				for i = _detalhes.segments_amount, _detalhes.segments_amount_to_save+1, -1  do
					if (_detalhes.tabela_historico.tabelas [i]) then
						table.remove (_detalhes.tabela_historico.tabelas, i)
					end
				end
			end
			
			--tabela do combate atual
			local tabela_atual = _detalhes.tabela_vigente or _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
			
			--limpa a tabela overall
			_detalhes.tabela_overall = nil			
			
			for _, _tabela in _ipairs (historico_tabelas) do
				tabelas_de_combate [#tabelas_de_combate+1] = _tabela
			end

			--verifica se a database existe mesmo
			_detalhes_database = _detalhes_database or {}
			
			for tabela_index, _combate in _ipairs (tabelas_de_combate) do

				--> limpa a tabela do grafico -- clear graphic table
				if (_detalhes.clear_graphic) then 
					_combate.TimeData = {}
				end
				
				--> limpa a referencia do ultimo combate
				_combate.previous_combat = nil
			
				local container_dano = _combate [class_type_dano] or {}
				local container_cura = _combate [class_type_cura] or {}
				local container_e_energy = _combate [class_type_e_energy] or {}
				local container_misc = _combate [class_type_misc] or {}

				local todos_atributos = {container_dano, container_cura, container_e_energy, container_misc}
				
				local IsBossEncounter = _combate.is_boss
				if (IsBossEncounter) then
					if (_combate.pvp) then
						IsBossEncounter = false
					end
				end
				
				for class_type, _tabela in _ipairs (todos_atributos) do
				
					local conteudo = _tabela._ActorTable

					--> Limpa tabelas que não estejam em grupo
					
					_detalhes.clear_ungrouped = true
					
					if (_detalhes.clear_ungrouped) then
					
						local _iter = {index = 1, data = conteudo[1], cleaned = 0} --> ._ActorTable[1] para pegar o primeiro index

						while (_iter.data) do --serach key: deletar apagar
							local can_erase = true
							
							if (_iter.data.grupo or _iter.data.boss or _iter.data.boss_fight_component or IsBossEncounter) then
								can_erase = false
							else
								local owner = _iter.data.owner
								if (owner) then 
									local owner_actor = _combate (class_type, owner.nome)
									if (owner_actor) then 
										if (owner.grupo or owner.boss or owner.boss_fight_component) then
											--if (class_type == 1) then
											--	print ("SAVE",  _iter.data.nome, "| owner:",_iter.data.owner.nome, tabela_index)
											--end
											can_erase = false
										end
									end
								else
									--if (class_type == 1) then
									--	print ("DELETANDO",  _iter.data.nome, tabela_index)
									--end
								end
							end
							
							if (can_erase) then 
								
								if (not _iter.data.owner) then --> pet (not a pet?)
									local myself = _iter.data
								
									if (myself.tipo == class_type_dano or myself.tipo == class_type_cura) then
										_combate.totals [myself.tipo] = _combate.totals [myself.tipo] - myself.total
										if (myself.grupo) then
											_combate.totals_grupo [myself.tipo] = _combate.totals_grupo [myself.tipo] - myself.total
										end
									elseif (myself.tipo == class_type_e_energy) then
										_combate.totals [myself.tipo] ["mana"] = _combate.totals [myself.tipo] ["mana"] - myself.mana
										_combate.totals [myself.tipo] ["e_rage"] = _combate.totals [myself.tipo] ["e_rage"] - myself.e_rage
										_combate.totals [myself.tipo] ["e_energy"] = _combate.totals [myself.tipo] ["e_energy"] - myself.e_energy
										_combate.totals [myself.tipo] ["runepower"] = _combate.totals [myself.tipo] ["runepower"] - myself.runepower
										if (myself.grupo) then
											_combate.totals_grupo [myself.tipo] ["mana"] = _combate.totals_grupo [myself.tipo] ["mana"] - myself.mana
											_combate.totals_grupo [myself.tipo] ["e_rage"] = _combate.totals_grupo [myself.tipo] ["e_rage"] - myself.e_rage
											_combate.totals_grupo [myself.tipo] ["e_energy"] = _combate.totals_grupo [myself.tipo] ["e_energy"] - myself.e_energy
											_combate.totals_grupo [myself.tipo] ["runepower"] = _combate.totals_grupo [myself.tipo] ["runepower"] - myself.runepower
										end
									elseif (myself.tipo == class_type_misc) then
										if (myself.cc_break) then 
											_combate.totals [myself.tipo] ["cc_break"] = _combate.totals [myself.tipo] ["cc_break"] - myself.cc_break 
											if (myself.grupo) then
												_combate.totals_grupo [myself.tipo] ["cc_break"] = _combate.totals_grupo [myself.tipo] ["cc_break"] - myself.cc_break 
											end
										end
										if (myself.ress) then 
											_combate.totals [myself.tipo] ["ress"] = _combate.totals [myself.tipo] ["ress"] - myself.ress
											if (myself.grupo) then
												_combate.totals_grupo [myself.tipo] ["ress"] = _combate.totals_grupo [myself.tipo] ["ress"] - myself.ress
											end
										end
										--> não precisa diminuir o total dos buffs e debuffs
										if (myself.cooldowns_defensive) then 
											_combate.totals [myself.tipo] ["cooldowns_defensive"] = _combate.totals [myself.tipo] ["cooldowns_defensive"] - myself.cooldowns_defensive 
											if (myself.grupo) then
												_combate.totals_grupo [myself.tipo] ["cooldowns_defensive"] = _combate.totals_grupo [myself.tipo] ["cooldowns_defensive"] - myself.cooldowns_defensive 
											end
										end
										if (myself.interrupt) then 
											_combate.totals [myself.tipo] ["interrupt"] = _combate.totals [myself.tipo] ["interrupt"] - myself.interrupt 
											if (myself.grupo) then
												_combate.totals_grupo [myself.tipo] ["interrupt"] = _combate.totals_grupo [myself.tipo] ["interrupt"] - myself.interrupt 
											end
										end
										if (myself.dispell) then 
											_combate.totals [myself.tipo] ["dispell"] = _combate.totals [myself.tipo] ["dispell"] - myself.dispell 
											if (myself.grupo) then
												_combate.totals_grupo [myself.tipo] ["dispell"] = _combate.totals_grupo [myself.tipo] ["dispell"] - myself.dispell 
											end
										end
										if (myself.dead) then 
											_combate.totals [myself.tipo] ["dead"] = _combate.totals [myself.tipo] ["dead"] - myself.dead 
											if (myself.grupo) then
												_combate.totals_grupo [myself.tipo] ["dead"] = _combate.totals_grupo [myself.tipo] ["dead"] - myself.dead 
											end
										end
									end						
								end

								_table_remove (conteudo, _iter.index)
								_iter.cleaned = _iter.cleaned + 1
								_iter.data = conteudo [_iter.index]
							else
								_iter.index = _iter.index + 1
								_iter.data = conteudo [_iter.index]
							end
						end
						
						if (_iter.cleaned > 0) then --> desencargo de consciência, reconstruir o mapa depois de excluir
							ReconstroiMapa (_tabela)
						end
						
					end

					for _, esta_classe in _ipairs (conteudo) do 
					
						--> limpa o displayName, não precisa salvar
						esta_classe.displayName = nil
						esta_classe.owner = nil
						
						if (class_type == class_type_dano) then
							_detalhes.clear:c_atributo_damage (esta_classe)
						elseif (class_type == class_type_cura) then
							_detalhes.clear:c_atributo_heal (esta_classe)
						elseif (class_type == class_type_e_energy) then
							_detalhes.clear:c_atributo_energy (esta_classe)
						elseif (class_type == class_type_misc) then
							_detalhes.clear:c_atributo_misc (esta_classe)
							
							if (esta_classe.interrupt) then
								for _, _alvo in _ipairs (esta_classe.interrupt_targets._ActorTable) do 
									_detalhes.clear:c_alvo_da_habilidade (_alvo)
								end
							end
							
							if (esta_classe.buff_uptime) then
								for _, _alvo in _ipairs (esta_classe.buff_uptime_targets._ActorTable) do 
									_detalhes.clear:c_alvo_da_habilidade (_alvo)
								end
							end
							
							if (esta_classe.debuff_uptime) then
								for _, _alvo in _ipairs (esta_classe.debuff_uptime_targets._ActorTable) do 
									_detalhes.clear:c_alvo_da_habilidade (_alvo)
								end
							end
							
							if (esta_classe.cooldowns_defensive) then
								for _, _alvo in _ipairs (esta_classe.cooldowns_defensive_targets._ActorTable) do 
									_detalhes.clear:c_alvo_da_habilidade (_alvo)
								end
							end
							
							if (esta_classe.ress) then
								for _, _alvo in _ipairs (esta_classe.ress_targets._ActorTable) do 
									_detalhes.clear:c_alvo_da_habilidade (_alvo)
								end
							end
							
							if (esta_classe.dispell) then
								for _, _alvo in _ipairs (esta_classe.dispell_targets._ActorTable) do 
									_detalhes.clear:c_alvo_da_habilidade (_alvo)
								end
							end
							
							if (esta_classe.cc_break) then
								for _, _alvo in _ipairs (esta_classe.cc_break_targets._ActorTable) do 
									_detalhes.clear:c_alvo_da_habilidade (_alvo)
								end
							end
						end
						
						if (class_type ~= class_type_misc) then
							for _, _alvo in _ipairs (esta_classe.targets._ActorTable) do 
								_detalhes.clear:c_alvo_da_habilidade (_alvo)
							end
							
							for _, habilidade in _pairs (esta_classe.spell_tables._ActorTable) do
								if (class_type == class_type_dano) then
									_detalhes.clear:c_habilidade_dano (habilidade)
								elseif (class_type == class_type_cura) then
									_detalhes.clear:c_habilidade_cura (habilidade)
								elseif (class_type == class_type_e_energy) then
									_detalhes.clear:c_habilidade_e_energy (habilidade)
								end
								
								for _, _alvo in ipairs (habilidade.targets._ActorTable) do
									_detalhes.clear:c_alvo_da_habilidade (_alvo)
								end
							end
						else
							if (esta_classe.interrupt) then
								for _, habilidade in _pairs (esta_classe.interrupt_spell_tables._ActorTable) do
									_detalhes.clear:c_habilidade_misc (habilidade)
									
									for _, _alvo in ipairs (habilidade.targets._ActorTable) do
										_detalhes.clear:c_alvo_da_habilidade (_alvo)
									end
								end
							end
							
							if (esta_classe.buff_uptime) then
								for _, habilidade in _pairs (esta_classe.buff_uptime_spell_tables._ActorTable) do
									_detalhes.clear:c_habilidade_misc (habilidade)
									
									for _, _alvo in ipairs (habilidade.targets._ActorTable) do
										_detalhes.clear:c_alvo_da_habilidade (_alvo)
									end
								end
							end
							
							if (esta_classe.debuff_uptime) then
								for _, habilidade in _pairs (esta_classe.debuff_uptime_spell_tables._ActorTable) do
									_detalhes.clear:c_habilidade_misc (habilidade)
									
									for _, _alvo in ipairs (habilidade.targets._ActorTable) do
										_detalhes.clear:c_alvo_da_habilidade (_alvo)
									end
								end
							end
							
							if (esta_classe.cooldowns_defensive) then
								for _, habilidade in _pairs (esta_classe.cooldowns_defensive_spell_tables._ActorTable) do
									_detalhes.clear:c_habilidade_misc (habilidade)
									
									for _, _alvo in ipairs (habilidade.targets._ActorTable) do
										_detalhes.clear:c_alvo_da_habilidade (_alvo)
									end
								end
							end
							
							if (esta_classe.ress) then
								for _, habilidade in _pairs (esta_classe.ress_spell_tables._ActorTable) do
									_detalhes.clear:c_habilidade_misc (habilidade)
									
									for _, _alvo in ipairs (habilidade.targets._ActorTable) do
										_detalhes.clear:c_alvo_da_habilidade (_alvo)
									end
								end
							end
							
							if (esta_classe.dispell) then
								for _, habilidade in _pairs (esta_classe.dispell_spell_tables._ActorTable) do
									_detalhes.clear:c_habilidade_misc (habilidade)
									
									for _, _alvo in ipairs (habilidade.targets._ActorTable) do
										_detalhes.clear:c_alvo_da_habilidade (_alvo)
									end
								end
							end
							
							if (esta_classe.cc_break) then
								for _, habilidade in _pairs (esta_classe.cc_break_spell_tables._ActorTable) do
									_detalhes.clear:c_habilidade_misc (habilidade)
									
									for _, _alvo in ipairs (habilidade.targets._ActorTable) do
										_detalhes.clear:c_alvo_da_habilidade (_alvo)
									end
								end
							end
						end
						
					end
				end

			end
			
			--> Clear Containers
				for tabela_index, _combate in _ipairs (tabelas_de_combate) do
					local container_dano = _combate [class_type_dano]
					local container_cura = _combate [class_type_cura]
					local container_e_energy = _combate [class_type_e_energy]
					local container_misc = _combate [class_type_misc]

					local todos_atributos = {container_dano, container_cura, container_e_energy, container_misc}
					
					for class_type, _tabela in _ipairs (todos_atributos) do
						_detalhes.clear:c_combate (_combate)
						_detalhes.clear:c_container_combatentes (container_dano)
						_detalhes.clear:c_container_combatentes (container_cura)
						_detalhes.clear:c_container_combatentes (container_e_energy)
						_detalhes.clear:c_container_combatentes (container_misc)
					end
				end	
			
			
			--> panic mode
				if (_detalhes.segments_panic_mode and _detalhes.can_panic_mode) then
					if (_detalhes.tabela_vigente.is_boss) then
						_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
					end
				end
			
			--> Limpa instâncias
			for _, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
				--> detona a janela do Solo Mode

				if (esta_instancia.StatusBar.left) then
					esta_instancia.StatusBarSaved = {
						["left"] = esta_instancia.StatusBar.left.real_name or "NONE",
						["center"] = esta_instancia.StatusBar.center.real_name or "NONE",
						["right"] = esta_instancia.StatusBar.right.real_name or "NONE",
						--["options"] = esta_instancia.StatusBar.options
					}
					esta_instancia.StatusBarSaved.options = {
						[esta_instancia.StatusBarSaved.left] = esta_instancia.StatusBar.left.options,
						[esta_instancia.StatusBarSaved.center] = esta_instancia.StatusBar.center.options,
						[esta_instancia.StatusBarSaved.right] = esta_instancia.StatusBar.right.options
					}
				end

				--> erase all widgets frames
				
				esta_instancia.scroll = nil
				esta_instancia.baseframe = nil
				esta_instancia.bgframe = nil
				esta_instancia.bgdisplay = nil
				esta_instancia.freeze_icon = nil
				esta_instancia.freeze_texto = nil
				esta_instancia.barras = nil
				esta_instancia.showing = nil
				esta_instancia.agrupada_a = nil
				esta_instancia.grupada_pos = nil
				esta_instancia.agrupado = nil
				esta_instancia._version = nil
				
				esta_instancia.h_baixo = nil
				esta_instancia.h_esquerda = nil
				esta_instancia.h_direita = nil
				esta_instancia.h_cima = nil
				esta_instancia.break_snap_button = nil
				esta_instancia.alert = nil
				
				esta_instancia.StatusBar = nil
				esta_instancia.consolidateFrame = nil
				esta_instancia.consolidateButtonTexture = nil
				esta_instancia.consolidateButton = nil
				esta_instancia.lastIcon = nil
				
				esta_instancia.menu_attribute_string = nil
				
				esta_instancia.wait_for_plugin_created = nil
				esta_instancia.waiting_raid_plugin = nil
				esta_instancia.waiting_pid = nil

			end
			
			_detalhes.clear:c_atributo_custom()

		end
	
	function _detalhes:reset_window (instancia)
		if (instancia.segmento == -1) then
			instancia.showing[instancia.atributo].need_refresh = true
			instancia.v_barras = true
			instancia:ResetaGump()
			instancia:AtualizaGumpPrincipal (true)
		end
	end

	function _detalhes:CheckMemoryAfterCombat()
		if (_detalhes.next_memory_check < time()) then
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) checking memory after combat.")
			end
			_detalhes.next_memory_check = time()+_detalhes.intervalo_memoria
			UpdateAddOnMemoryUsage()
			local memory = GetAddOnMemoryUsage ("Details")
			if (memory > _detalhes.memory_ram) then
				_detalhes:IniciarColetaDeLixo (true, 60) --> sending true doesn't check anythink
			end
		end
	end
	function _detalhes:CheckMemoryPeriodically()
		if (_detalhes.next_memory_check <= time() and not _InCombatLockdown() and not _detalhes.in_combat) then
			_detalhes.next_memory_check = time() + _detalhes.intervalo_memoria - 3
			UpdateAddOnMemoryUsage()
			local memory = GetAddOnMemoryUsage ("Details")
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) checking memory periodically. Using: ",math.floor (memory), "of", _detalhes.memory_ram * 1000)
			end
			if (memory > _detalhes.memory_ram * 1000) then
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) Memory is too high, starting garbage collector")
				end
				_detalhes:IniciarColetaDeLixo (1, 60) --> sending 1 only check for combat and ignore garbage collect cooldown
			end
		end
	end

	function _detalhes:IniciarColetaDeLixo (forcar, lastevent)

		if (not forcar) then
			if (_detalhes.ultima_coleta + _detalhes.intervalo_coleta > _detalhes._tempo + 1)  then
				return
			elseif (_detalhes.in_combat or _InCombatLockdown() or _detalhes:IsInInstance()) then 
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) garbage collect queued due combatlockdown (forced false)")
				end
				_detalhes:ScheduleTimer ("IniciarColetaDeLixo", 5) 
				return
			end
		else
			if (type (forcar) ~= "boolean") then
				if (forcar == 1) then
					if (_detalhes.in_combat or _InCombatLockdown()) then
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) garbage collect queued due combatlockdown (forced 1)")
						end
						_detalhes:ScheduleTimer ("IniciarColetaDeLixo", 5, forcar) 
						return
					end
				end
			end
		end

		if (_detalhes.debug) then
			if (forcar) then
				_detalhes:Msg ("(debug) collecting garbage with forced state: ", forcar)
			else
				_detalhes:Msg ("(debug) collecting garbage.")
			end
		end
		
		local memory = GetAddOnMemoryUsage ("Details")
		
		--> reseta o cache do parser
		_detalhes:ClearParserCache()
		
		--> limpa barras que não estão sendo usadas nas instâncias.
		for index, instancia in _ipairs (_detalhes.tabela_instancias) do 
			if (instancia.barras and instancia.barras [1]) then
				for i, barra in _ipairs (instancia.barras) do 
					if (not barra:IsShown()) then
						barra.minha_tabela = nil
					end
				end
			end
		end
		
		--> faz a coleta nos 4 atributos
		local damage = atributo_damage:ColetarLixo (lastevent)
		local heal = atributo_heal:ColetarLixo (lastevent)
		local energy = atributo_energy:ColetarLixo (lastevent)
		local misc = atributo_misc:ColetarLixo (lastevent)

		local limpados = damage + heal + energy + misc
		
		--> refresh nas janelas
		if (limpados > 0) then
			_detalhes:InstanciaCallFunction (_detalhes.reset_window)
		end

		_detalhes:ManutencaoTimeMachine()
		
		--> print cache states
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) removed: damage "..damage.." heal "..heal.." energy "..energy.." misc "..misc)
		end
		
		--> elimina pets antigos
		_detalhes:LimparPets()
		
		--> wipa container de escudos
		_table_wipe (_detalhes.escudos)

		_detalhes.ultima_coleta = _detalhes._tempo

		if (_detalhes.debug) then
			collectgarbage()
			UpdateAddOnMemoryUsage()
			local memory2 = GetAddOnMemoryUsage ("Details")
			_detalhes:Msg ("(debug) memory before: "..memory.." memory after: "..memory2)
		end
		
	end

	--> combates Normais
	local function FazColeta (_combate, tipo, intervalo_overwrite)
		
		local conteudo = _combate [tipo]._ActorTable
		local _iter = {index = 1, data = conteudo[1], cleaned = 0}
		local _tempo  = _time()
		
		--local links_removed = 0
		
		while (_iter.data) do
		
			local _actor = _iter.data
			local can_garbage = false
			
			local t
			if (intervalo_overwrite) then 
				t =  _actor.last_event + intervalo_overwrite
			else
				t = _actor.last_event + _detalhes.intervalo_coleta
			end
			
			if (t < _tempo and not _actor.grupo and not _actor.boss and not _actor.fight_component and not _actor.boss_fight_component) then 
				local owner = _actor.owner
				if (owner) then 
					local owner_actor = _combate (tipo, owner.nome)
					if (not owner.grupo and not owner.boss and not owner.boss_fight_component) then
						can_garbage = true
					end
				else
					can_garbage = true
				end
			end

			if (can_garbage) then
				if (not _actor.owner) then --> pet
					_actor:subtract_total (_combate)
				end
			
				--> fix para a weak table
				--[[
				local shadow = _actor.shadow
				local _it = {index = 1, link = shadow.links [1]}
				while (_it.link) do
					if (_it.link == _actor) then
						_table_remove (shadow.links, _it.index)
						_it.link = shadow.links [_it.index]
					else
						_it.index = _it.index+1
						_it.link = shadow.links [_it.index]
					end
				end
				--]]
				
				_iter.cleaned = _iter.cleaned+1
				
				if (_actor.tipo == 1 or _actor.tipo == 2) then
					_actor:DesregistrarNaTimeMachine()
				end				
				
				_table_remove (conteudo, _iter.index)
				_iter.data = conteudo [_iter.index]
			else
				_iter.index = _iter.index + 1
				_iter.data = conteudo [_iter.index]
			end
		
		end
		
		if (_detalhes.debug) then
			-- _detalhes:Msg ("- garbage collect:", tipo, "actors removed:",_iter.cleaned)
		end
		
		if (_iter.cleaned > 0) then
			ReconstroiMapa (_combate [tipo])
			_combate [tipo].need_refresh = true
		end
		
		return _iter.cleaned
	end

	--> Combate overall
	function _detalhes:ColetarLixo (tipo, lastevent)

		--print ("fazendo coleta...")
	
		local _tempo  = _time()
		local limpados = 0

		--> monta a lista de combates
		local tabelas_de_combate = {}
		for _, _tabela in _ipairs (_detalhes.tabela_historico.tabelas) do
			if (_tabela ~= _detalhes.tabela_vigente) then
				tabelas_de_combate [#tabelas_de_combate+1] = _tabela
			end
		end
		tabelas_de_combate [#tabelas_de_combate+1] = _detalhes.tabela_vigente
		
		--> faz a coleta em todos os combates para este atributo
		for _, _combate in _ipairs (tabelas_de_combate) do 
			limpados = limpados + FazColeta (_combate, tipo, lastevent)
		end

		--> limpa a tabela overall para o atributo atual (limpa para os 4, um de cada vez através do ipairs)
		local _overall_combat = _detalhes.tabela_overall	
		local conteudo = _overall_combat [tipo]._ActorTable
		local _iter = {index = 1, data = conteudo[1], cleaned = 0} --> ._ActorTable[1] para pegar o primeiro index

		while (_iter.data) do
		
			local _actor = _iter.data
		
		--[[
			local meus_links = _rawget (_actor, "links")
			local can_garbage = true
			local new_weak_table = _setmetatable ({}, _detalhes.weaktable) --> precisa da nova weak table para remover os NILS da tabela antiga
			
			if (meus_links) then
				for _, ref in _pairs (meus_links) do --> trocando pairs por _ipairs
					if (ref) then
						can_garbage = false
						new_weak_table [#new_weak_table+1] = ref
					end
				end
				_table_wipe (meus_links)
			end
		--]]
		
			local can_garbage = false
			if (not _actor.grupo and not _actor.owner and not _actor.boss_fight_component and not _actor.fight_component) then
				can_garbage = true
			end
		
			--if (can_garbage or not meus_links) then --> não há referências a este objeto
			if (can_garbage) then --> não há referências a este objeto
				
				--print ("garbaged:", _actor.nome)
				
				if (not _actor.owner) then --> pet
					_actor:subtract_total (_overall_combat)
				end

				--> apaga a referência deste jogador na tabela overall
				_iter.cleaned = _iter.cleaned+1
				
				--if (_detalhes.debug) then
				--	if (#_actor.links > 0) then
				--		_detalhes:Msg ("(debug) " .. _actor.nome, " has been garbaged but have links: ", #_actor.links)
				--	end
				--end
				
				if (_actor.tipo == 1 or _actor.tipo == 2) then
					_actor:DesregistrarNaTimeMachine()
				end
				_table_remove (conteudo, _iter.index)

				_iter.data = conteudo [_iter.index]
			else
				--_actor.links = new_weak_table
				_iter.index = _iter.index + 1
				_iter.data = conteudo [_iter.index]
			end

		end

		--> termina o coletor de lixo
		if (_iter.cleaned > 0) then
			_overall_combat[tipo].need_refresh = true
			ReconstroiMapa (_overall_combat [tipo])
			limpados = limpados + _iter.cleaned
		end
		
		if (limpados > 0) then
			_detalhes:InstanciaCallFunction (_detalhes.ScheduleUpdate)
			_detalhes:AtualizaGumpPrincipal (-1)
		end

		return limpados
	end
