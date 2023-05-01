
	local _detalhes = _G.Details
	local Details = _detalhes
	local tocName, Details222 = ...

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers
	local _
	local pairs = pairs --lua local
	local ipairs = ipairs --lua local
	local rawget = rawget --lua local
	local setmetatable = setmetatable --lua local
	local _table_remove = table.remove --lua local
	local _bit_band = bit.band --lua local
	local wipe = table.wipe --lua local
	local _time = time --lua local

	local _InCombatLockdown = InCombatLockdown --wow api local

	local classDamage =	_detalhes.atributo_damage --details local
	local classHeal =		_detalhes.atributo_heal --details local
	local classEnergy =		_detalhes.atributo_energy --details local
	local classUtility =		_detalhes.atributo_misc --details local
	local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade --details local
	local habilidade_dano = 	_detalhes.habilidade_dano --details local
	local habilidade_cura = 		_detalhes.habilidade_cura --details local
	local container_habilidades = 	_detalhes.container_habilidades --details local
	local container_combatentes = _detalhes.container_combatentes --details local

	local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants

	local class_type_dano = _detalhes.atributos.dano
	local class_type_cura = _detalhes.atributos.cura
	local class_type_e_energy = _detalhes.atributos.e_energy
	local class_type_misc = _detalhes.atributos.misc

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core

	---wipe the naming list and rebuild it
	---@param actorContainer actorcontainer
	local fullRemap = function(actorContainer)
		local namingMap = actorContainer._NameIndexTable
		wipe(namingMap)
		for i = 1, #actorContainer._ActorTable do
			local actorName = actorContainer._ActorTable[i].nome
			namingMap[actorName] = i
		end
	end

	--reaplica as tabelas no overall
		function _detalhes:RestauraOverallMetaTables()

			local is_in_instance = select(1, IsInInstance())

			local combate = _detalhes.tabela_overall
			combate.overall_refreshed = true
			combate.hasSaved = true

			combate.__call = _detalhes.call_combate

			_detalhes.refresh:r_combate (combate)

			_detalhes.refresh:r_container_combatentes (combate [class_type_dano])
			_detalhes.refresh:r_container_combatentes (combate [class_type_cura])
			_detalhes.refresh:r_container_combatentes (combate [class_type_e_energy])
			_detalhes.refresh:r_container_combatentes (combate [class_type_misc])

			_detalhes.refresh:r_container_combatentes (combate [5]) --ghost container

			local todos_atributos = {combate [class_type_dano]._ActorTable, combate [class_type_cura]._ActorTable, combate [class_type_e_energy]._ActorTable, combate [class_type_misc]._ActorTable}

			for class_type, atributo in ipairs(todos_atributos) do
				for _, esta_classe in ipairs(atributo) do

					local nome = esta_classe.nome

					if (is_in_instance and _detalhes.remove_realm_from_name) then
						esta_classe.displayName = nome:gsub(("%-.*"), "")
					elseif (_detalhes.remove_realm_from_name) then
						esta_classe.displayName = nome:gsub(("%-.*"), "") --"%*"
					else
						esta_classe.displayName = nome
					end

					if (class_type == class_type_dano) then
						_detalhes.refresh:r_atributo_damage (esta_classe)

					elseif (class_type == class_type_cura) then
						_detalhes.refresh:r_atributo_heal (esta_classe)

					elseif (class_type == class_type_e_energy) then
						_detalhes.refresh:r_atributo_energy (esta_classe)

					elseif (class_type == class_type_misc) then
						_detalhes.refresh:r_atributo_misc (esta_classe)

					end

				end
			end

			for class_type, atributo in ipairs(todos_atributos) do
				for _, esta_classe in ipairs(atributo) do
					if (esta_classe.ownerName) then --nome do owner
						esta_classe.owner = combate (class_type, esta_classe.ownerName)
					end
				end
			end

		end

	--reaplica indexes e metatables
		function _detalhes:RestauraMetaTables()

				_detalhes.refresh:r_atributo_custom()

			--container de pets e hist�rico
				_detalhes.refresh:r_container_pets (_detalhes.tabela_pets)
				_detalhes.refresh:r_historico (_detalhes.tabela_historico)

			--tabelas dos combates
				local combate_overall = _detalhes.tabela_overall
				local overall_dano = combate_overall [class_type_dano] --damage atalho
				local overall_cura = combate_overall [class_type_cura] --heal atalho
				local overall_energy = combate_overall [class_type_e_energy] --energy atalho
				local overall_misc = combate_overall [class_type_misc] --misc atalho

				local tabelas_do_historico = _detalhes.tabela_historico.tabelas --atalho

			--recupera meta function
				for _, combat_table in ipairs(tabelas_do_historico) do
					combat_table.__call = _detalhes.call_combate
				end

				for i = #tabelas_do_historico-1, 1, -1 do
					local combat = tabelas_do_historico [i]
					combat.previous_combat = tabelas_do_historico [i+1]
				end

			--tempo padrao do overall

				local overall_saved = combate_overall.overall_refreshed

				if (not overall_saved) then
					combate_overall.start_time = GetTime()
					combate_overall.end_time = GetTime()
				end

				local is_in_instance = select(1, IsInInstance())

			--inicia a recupera��o das tabelas e montagem do overall
				if (#tabelas_do_historico > 0) then
					for index, combate in ipairs(tabelas_do_historico) do

						combate.hasSaved = true

						--recupera a meta e indexes da tabela do combate
						_detalhes.refresh:r_combate (combate, combate_overall)

						--aumenta o tempo do combate do overall, seta as datas e os combates armazenados
						if (not overall_saved and combate.overall_added) then

							if (combate.end_time and combate.start_time) then
								combate_overall.start_time = combate_overall.start_time - (combate.end_time - combate.start_time)
							end
							--
							if (combate_overall.data_inicio == 0) then
								combate_overall.data_inicio = combate.data_inicio or 0
							end
							combate_overall.data_fim = combate.data_fim or combate_overall.data_fim
							--
							if (not _detalhes.tabela_overall.overall_enemy_name) then
								_detalhes.tabela_overall.overall_enemy_name = combate.is_boss and combate.is_boss.name or combate.enemy
							else
								if (_detalhes.tabela_overall.overall_enemy_name ~= (combate.is_boss and combate.is_boss.name or combate.enemy)) then
									_detalhes.tabela_overall.overall_enemy_name = "-- x -- x --"
								end
							end

							combate_overall.segments_added =combate_overall.segments_added or {}
							local date_start, date_end = combate:GetDate()
							tinsert(combate_overall.segments_added, {name = combate:GetCombatName(true), elapsed = combate:GetCombatTime(), clock = date_start})

						end

						--recupera a meta e indexes dos 4 container
						_detalhes.refresh:r_container_combatentes (combate [class_type_dano], overall_dano)
						_detalhes.refresh:r_container_combatentes (combate [class_type_cura], overall_cura)
						_detalhes.refresh:r_container_combatentes (combate [class_type_e_energy], overall_energy)
						_detalhes.refresh:r_container_combatentes (combate [class_type_misc], overall_misc)

						--ghost container
						if (combate[5]) then
							_detalhes.refresh:r_container_combatentes (combate [5], combate_overall [5])
						end

						--tabela com os 4 tabelas de jogadores
						local todos_atributos = {combate [class_type_dano]._ActorTable, combate [class_type_cura]._ActorTable, combate [class_type_e_energy]._ActorTable, combate [class_type_misc]._ActorTable}

						for class_type, atributo in ipairs(todos_atributos) do
							for _, esta_classe in ipairs(atributo) do

								local nome = esta_classe.nome

								if (is_in_instance and _detalhes.remove_realm_from_name) then
									esta_classe.displayName = nome:gsub(("%-.*"), "")
								elseif (_detalhes.remove_realm_from_name) then
									esta_classe.displayName = nome:gsub(("%-.*"), "") --%*
								else
									esta_classe.displayName = nome
								end

								local shadow

								if (class_type == class_type_dano) then
									if (combate.overall_added and not overall_saved) then
										shadow = classDamage:r_connect_shadow (esta_classe)
									else
										shadow = classDamage:r_onlyrefresh_shadow (esta_classe)
									end

								elseif (class_type == class_type_cura) then
									if (combate.overall_added and not overall_saved) then
										shadow = classHeal:r_connect_shadow (esta_classe)
									else
										shadow = classHeal:r_onlyrefresh_shadow (esta_classe)
									end

								elseif (class_type == class_type_e_energy) then
									if (combate.overall_added and not overall_saved) then
										shadow = classEnergy:r_connect_shadow (esta_classe)
									else
										shadow = classEnergy:r_onlyrefresh_shadow (esta_classe)
									end

								elseif (class_type == class_type_misc) then
									if (combate.overall_added and not overall_saved) then
										shadow = classUtility:r_connect_shadow (esta_classe)
									else
										shadow = classUtility:r_onlyrefresh_shadow (esta_classe)
									end
								end

							end
						end

						--reconstr�i a tabela dos pets
						for class_type, atributo in ipairs(todos_atributos) do
							for _, esta_classe in ipairs(atributo) do
								if (esta_classe.ownerName) then --nome do owner
									esta_classe.owner = combate (class_type, esta_classe.ownerName)
								end
							end
						end

					end
				--fim
				end

			--restaura last_events_table
				local primeiro_combate = tabelas_do_historico [1] --primeiro combate
				if (primeiro_combate) then
					primeiro_combate [1]:ActorCallFunction (classDamage.r_last_events_table)
					primeiro_combate [2]:ActorCallFunction (classHeal.r_last_events_table)
				end

				local segundo_combate = tabelas_do_historico [2] --segundo combate
				if (segundo_combate) then
					segundo_combate [1]:ActorCallFunction (classDamage.r_last_events_table)
					segundo_combate [2]:ActorCallFunction (classHeal.r_last_events_table)
				end

		end

	function _detalhes:DoInstanceCleanup()

		--normal instances
		for _, esta_instancia in ipairs(_detalhes.tabela_instancias) do

			if (esta_instancia.StatusBar.left) then
				esta_instancia.StatusBarSaved = {
					["left"] = esta_instancia.StatusBar.left.real_name or "NONE",
					["center"] = esta_instancia.StatusBar.center.real_name or "NONE",
					["right"] = esta_instancia.StatusBar.right.real_name or "NONE",
				}
				esta_instancia.StatusBarSaved.options = {
					[esta_instancia.StatusBarSaved.left] = esta_instancia.StatusBar.left.options,
					[esta_instancia.StatusBarSaved.center] = esta_instancia.StatusBar.center.options,
					[esta_instancia.StatusBarSaved.right] = esta_instancia.StatusBar.right.options
				}
			end

			--erase all widgets frames

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
			esta_instancia.firstIcon = nil

			esta_instancia.menu_attribute_string = nil

			esta_instancia.wait_for_plugin_created = nil
			esta_instancia.waiting_raid_plugin = nil
			esta_instancia.waiting_pid = nil

		end

		--unused instances
		for _, esta_instancia in ipairs(_detalhes.unused_instances) do

			if (esta_instancia.StatusBar.left) then
				esta_instancia.StatusBarSaved = {
					["left"] = esta_instancia.StatusBar.left.real_name or "NONE",
					["center"] = esta_instancia.StatusBar.center.real_name or "NONE",
					["right"] = esta_instancia.StatusBar.right.real_name or "NONE",
				}
				esta_instancia.StatusBarSaved.options = {
					[esta_instancia.StatusBarSaved.left] = esta_instancia.StatusBar.left.options,
					[esta_instancia.StatusBarSaved.center] = esta_instancia.StatusBar.center.options,
					[esta_instancia.StatusBarSaved.right] = esta_instancia.StatusBar.right.options
				}
			end

			--erase all widgets frames
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
			esta_instancia.firstIcon = nil

			esta_instancia.menu_attribute_string = nil

			esta_instancia.wait_for_plugin_created = nil
			esta_instancia.waiting_raid_plugin = nil
			esta_instancia.waiting_pid = nil
		end
	end

	function _detalhes:DoOwnerCleanup()
		local combats = _detalhes.tabela_historico.tabelas or {}
		local overall_added
		if (not _detalhes.overall_clear_logout) then
			tinsert(combats, _detalhes.tabela_overall)
			overall_added = true
		end

		for index, combat in ipairs(combats) do
			for index, container in ipairs(combat) do
				for index, esta_classe in ipairs(container._ActorTable) do
					esta_classe.owner = nil
				end
			end
		end

		if (overall_added) then
			tremove(combats, #combats)
		end
	end

	function _detalhes:DoClassesCleanup()
		local combats = _detalhes.tabela_historico.tabelas or {}
		local overall_added
		if (not _detalhes.overall_clear_logout) then
			tinsert(combats, _detalhes.tabela_overall)
			overall_added = true
		end

		for index, combat in ipairs(combats) do
			for class_type, container in ipairs(combat) do
				for index, esta_classe in ipairs(container._ActorTable) do

					esta_classe.displayName = nil
					esta_classe.minha_barra = nil

					if (class_type == class_type_dano) then
						_detalhes.clear:c_atributo_damage (esta_classe)
					elseif (class_type == class_type_cura) then
						_detalhes.clear:c_atributo_heal (esta_classe)
					elseif (class_type == class_type_e_energy) then
						_detalhes.clear:c_atributo_energy (esta_classe)
					elseif (class_type == class_type_misc) then
						_detalhes.clear:c_atributo_misc (esta_classe)
					end

				end
			end
		end

		if (overall_added) then
			tremove(combats, #combats)
		end
	end

	function _detalhes:DoContainerCleanup()
		local combats = _detalhes.tabela_historico.tabelas or {}
		local overall_added
		if (not _detalhes.overall_clear_logout) then
			tinsert(combats, _detalhes.tabela_overall)
			overall_added = true
		end

		for index, combat in ipairs(combats) do
			_detalhes.clear:c_combate (combat)
			for index, container in ipairs(combat) do
				_detalhes.clear:c_container_combatentes (container)
			end
		end

		if (overall_added) then
			tremove(combats, #combats)
		end
	end

	function _detalhes:DoContainerIndexCleanup()
		local combats = _detalhes.tabela_historico.tabelas or {}
		local overall_added
		if (not _detalhes.overall_clear_logout) then
			tinsert(combats, _detalhes.tabela_overall)
			overall_added = true
		end

		for index, combat in ipairs(combats) do
			for index, container in ipairs(combat) do
				_detalhes.clear:c_container_combatentes_index (container)
			end
		end

		if (overall_added) then
			tremove(combats, #combats)
		end
	end

	--limpa indexes, metatables e shadows
		function _detalhes:PrepareTablesForSave()

		_detalhes.clear_ungrouped = true

		--clear instances
			_detalhes:DoInstanceCleanup()
			_detalhes:DoClassesCleanup() --aumentou 1 combat
			_detalhes:DoContainerCleanup() --aumentou 1 combat

		--clear combats
			local tabelas_de_combate = {}
			local historico_tabelas = _detalhes.tabela_historico.tabelas or {}

			--remove os segmentos de trash
			for i = #historico_tabelas, 1, -1  do
				local combate = historico_tabelas [i]
				if (combate:IsTrash()) then
					table.remove (historico_tabelas, i)
				end
			end

			--remove os segmentos > que o limite permitido para salvar
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
			if (_detalhes.overall_clear_logout) then
				_detalhes.tabela_overall = nil
				_detalhes_database.tabela_overall = nil
			else
				local _combate = _detalhes.tabela_overall

				_combate.previous_combat = nil
				local todos_atributos = {_combate [class_type_dano] or {}, _combate [class_type_cura] or {}, _combate [class_type_e_energy] or {}, _combate [class_type_misc] or {}}

				for class_type, _tabela in ipairs(todos_atributos) do
					local conteudo = _tabela._ActorTable

					--Limpa tabelas que n�o estejam em grupo
					if (conteudo) then
						if (_detalhes.clear_ungrouped) then
						--if (not _detalhes.clear_ungrouped) then
							local _iter = {index = 1, data = conteudo[1], cleaned = 0} --._ActorTable[1] para pegar o primeiro index

							while (_iter.data) do --search key: ~deletar ~apagar
								local can_erase = true

								if (_iter.data.grupo or _iter.data.boss or _iter.data.boss_fight_component or _iter.data.pvp_component or _iter.data.fight_component) then
									can_erase = false
								else

									local owner = _iter.data.owner
									if (owner) then
										local owner_actor = _combate [class_type]._NameIndexTable [owner.nome]
										if (owner_actor) then
											local owner_actor = _combate [class_type]._ActorTable [owner_actor]
											if (owner_actor) then
												if (owner.grupo or owner.boss or owner.boss_fight_component or owner.fight_component) then
													can_erase = false
												end
											end
										end
									end
								end

								if (can_erase) then
									_table_remove(conteudo, _iter.index)
									_iter.cleaned = _iter.cleaned + 1
									_iter.data = conteudo [_iter.index]
								else
									_iter.index = _iter.index + 1
									_iter.data = conteudo [_iter.index]
								end
							end

							if (_iter.cleaned > 0) then
								fullRemap(_tabela)
							end
						end
					end
				end
			end

			for _, _tabela in ipairs(historico_tabelas) do
				tabelas_de_combate [#tabelas_de_combate+1] = _tabela
			end

			for tabela_index, _combate in ipairs(tabelas_de_combate) do

				--limpa a tabela do grafico
				if (_detalhes.clear_graphic) then
					_combate.TimeData = {}
				end

				--limpa a referencia do ultimo combate
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

				if (not _combate.is_mythic_dungeon_segment) then
					for class_type, _tabela in ipairs(todos_atributos) do

						local conteudo = _tabela._ActorTable

						--Limpa tabelas que n�o estejam em grupo
						if (conteudo) then

							if (_detalhes.clear_ungrouped) then
							--n�o deleta dummies e actors de fora do grupo
							--if (not _detalhes.clear_ungrouped) then

								local _iter = {index = 1, data = conteudo[1], cleaned = 0} --._ActorTable[1] para pegar o primeiro index

								while (_iter.data) do --search key: ~deletar ~apagar
									local can_erase = true

									if (_iter.data.grupo or _iter.data.boss or _iter.data.boss_fight_component or IsBossEncounter or _iter.data.pvp_component or _iter.data.fight_component) then
										can_erase = false
									else
										local owner = _iter.data.owner
										if (owner) then
											local owner_actor = _combate [class_type]._NameIndexTable [owner.nome]
											if (owner_actor) then
												local owner_actor = _combate [class_type]._ActorTable [owner_actor]
												if (owner_actor) then
													if (owner.grupo or owner.boss or owner.boss_fight_component or owner.fight_component) then
														can_erase = false
													end
												end
											end
										end
									end

									if (can_erase) then

										if (not _iter.data.owner) then --pet
											local myself = _iter.data

											if (myself.tipo == class_type_dano or myself.tipo == class_type_cura and _combate.totals [myself.tipo] and myself.total) then
												_combate.totals [myself.tipo] = _combate.totals [myself.tipo] - (myself.total or 0)
												if (myself.grupo) then
													_combate.totals_grupo [myself.tipo] = _combate.totals_grupo [myself.tipo] - (myself.total or 0)
												end

											elseif (myself.tipo == class_type_e_energy and _combate.totals [myself.tipo] and _combate.totals [myself.tipo] [myself.powertype] and myself.total) then
												_combate.totals [myself.tipo] [myself.powertype] = _combate.totals [myself.tipo] [myself.powertype] - (myself.total or 0)
												if (myself.grupo) then
													_combate.totals_grupo [myself.tipo] [myself.powertype] = _combate.totals_grupo [myself.tipo] [myself.powertype] - (myself.total or 0)
												end

											elseif (myself.tipo == class_type_misc) then
												if (myself.cc_break and _combate.totals[myself.tipo] and _combate.totals [myself.tipo] and _combate.totals [myself.tipo] ["cc_break"]) then
													_combate.totals [myself.tipo] ["cc_break"] = _combate.totals [myself.tipo] ["cc_break"] - (myself.cc_break or 0)
													if (myself.grupo) then
														_combate.totals_grupo [myself.tipo] ["cc_break"] = _combate.totals_grupo [myself.tipo] ["cc_break"] - (myself.cc_break or 0)
													end
												end
												if (myself.ress and _combate.totals [myself.tipo] and _combate.totals [myself.tipo] ["ress"]) then
													_combate.totals [myself.tipo] ["ress"] = _combate.totals [myself.tipo] ["ress"] - (myself.ress or 0)
													if (myself.grupo) then
														_combate.totals_grupo [myself.tipo] ["ress"] = _combate.totals_grupo [myself.tipo] ["ress"] - (myself.ress or 0)
													end
												end
												--n�o precisa diminuir o total dos buffs e debuffs
												if (myself.cooldowns_defensive and _combate.totals [myself.tipo] and _combate.totals [myself.tipo] ["cooldowns_defensive"]) then
													_combate.totals [myself.tipo] ["cooldowns_defensive"] = _combate.totals [myself.tipo] ["cooldowns_defensive"] - (myself.cooldowns_defensive or 0)
													if (myself.grupo) then
														_combate.totals_grupo [myself.tipo] ["cooldowns_defensive"] = _combate.totals_grupo [myself.tipo] ["cooldowns_defensive"] - (myself.cooldowns_defensive or 0)
													end
												end
												if (myself.interrupt and _combate.totals [myself.tipo] and _combate.totals [myself.tipo] ["interrupt"]) then
													_combate.totals [myself.tipo] ["interrupt"] = _combate.totals [myself.tipo] ["interrupt"] - (myself.interrupt or 0)
													if (myself.grupo) then
														_combate.totals_grupo [myself.tipo] ["interrupt"] = _combate.totals_grupo [myself.tipo] ["interrupt"] - (myself.interrupt or 0)
													end
												end
												if (myself.dispell and _combate.totals [myself.tipo] and _combate.totals [myself.tipo] ["dispell"]) then
													_combate.totals [myself.tipo] ["dispell"] = _combate.totals [myself.tipo] ["dispell"] - (myself.dispell or 0)
													if (myself.grupo) then
														_combate.totals_grupo [myself.tipo] ["dispell"] = _combate.totals_grupo [myself.tipo] ["dispell"] - (myself.dispell or 0)
													end
												end
												if (myself.dead and _combate.totals [myself.tipo] and _combate.totals [myself.tipo] ["dead"]) then
													_combate.totals [myself.tipo] ["dead"] = _combate.totals [myself.tipo] ["dead"] - (myself.dead or 0)
													if (myself.grupo) then
														_combate.totals_grupo [myself.tipo] ["dead"] = _combate.totals_grupo [myself.tipo] ["dead"] - (myself.dead or 0)
													end
												end
											end
										end

										_table_remove(conteudo, _iter.index)
										_iter.cleaned = _iter.cleaned + 1
										_iter.data = conteudo [_iter.index]
									else
										_iter.index = _iter.index + 1
										_iter.data = conteudo [_iter.index]
									end
								end

								if (_iter.cleaned > 0) then
									fullRemap(_tabela)
								end

							end
						end

					end

				end --end is mythic dungeon segment
			end

			--panic mode
				if (_detalhes.segments_panic_mode and _detalhes.can_panic_mode) then
					if (_detalhes.tabela_vigente.is_boss) then
						_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
					end
				end

			--clear all segments on logoff
				if (_detalhes.data_cleanup_logout) then
					_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
					_detalhes.tabela_overall = nil
					_detalhes_database.tabela_overall = nil
				end

			--clear customs
				_detalhes.clear:c_atributo_custom()

			--clear owners
				_detalhes:DoOwnerCleanup()

			--cleaer container indexes
				_detalhes:DoContainerIndexCleanup()
		end

	function _detalhes:reset_window(instancia)
		if (instancia.segmento == -1) then
			instancia.showing[instancia.atributo].need_refresh = true
			instancia.v_barras = true
			instancia:ResetaGump()
			instancia:RefreshMainWindow(true)
		end
	end

	---start/restart the internal garbage collector runtime
	---@param bShouldForceCollect boolean if true, the garbage collector will run regardless of the time interval
	---@param lastEvent unixtime no call is passing lastEvent at the moment
	function Details222.GarbageCollector.RestartInternalGarbageCollector(bShouldForceCollect, lastEvent)
		--print("d! debug: running garbage collector...")
		if (not bShouldForceCollect) then
			local thisTime = Details222.GarbageCollector.lastCollectTime + Details222.GarbageCollector.intervalTime
			if (thisTime > Details._tempo + 1)  then
				return

			elseif (Details.in_combat or _InCombatLockdown() or Details:IsInInstance()) then
				Details.Schedules.After(5, Details222.GarbageCollector.RestartInternalGarbageCollector, false, lastEvent)
				return
			end
		else
			if (type(bShouldForceCollect) ~= "boolean") then
				if (bShouldForceCollect == 1) then
					if (Details.in_combat or _InCombatLockdown()) then
						Details.Schedules.After(5, Details222.GarbageCollector.RestartInternalGarbageCollector, bShouldForceCollect, lastEvent)
						return
					end
				end
			end
		end

		if (Details.debug) then
			if (bShouldForceCollect) then
				Details:Msg("(debug) collecting garbage with forced state:", bShouldForceCollect)
			else
				Details:Msg("(debug) collecting garbage.")
			end
		end

		--cleanup all the parser caches
		Details:ClearParserCache()

		--cleanup lines which isn't shown but has an actor attached to
		for instanceId, instanceObject in Details:ListInstances() do
			if (instanceObject.barras and instanceObject.barras[1]) then
				for i, lineRow in ipairs(instanceObject.barras) do
					if (not lineRow:IsShown()) then
						lineRow.minha_tabela = nil
					end
				end
			end
		end

		--print("d! debug: RunGarbageCollector() Start")
		---@type number
		local amountActorRemoved = Details222.GarbageCollector.RunGarbageCollector(lastEvent)
		--print("d! debug: RunGarbageCollector() Ended, cleanup:", amountActorRemoved, "actors.") --139 actor removed, but don't remove anything (/reload it remove again)
		--UpdateAddOnMemoryUsage()
		--local memoryUsage = GetAddOnMemoryUsage("Details")
		--print("Memory:", floor(memoryUsage)/1000, "MBytes")

		--refresh nas janelas
		if (amountActorRemoved > 0) then
			Details:InstanciaCallFunction(Details.reset_window)
		end

		Details:TimeMachineMaintenance()

		--cleanup backlisted pets within the handler of actor containers
		Details:PetContainerCleanup()
		Details:ClearCCPetsBlackList()

		--cleanup spec cache
		Details:ResetSpecCache()

		--cleanup the shield cache
		wipe(Details.ShieldCache)

		--set the time of the last run
		Details222.GarbageCollector.lastCollectTime = Details._tempo

		if (Details.debug) then
			Details:Msg("(debug) executing: collectgarbage().")
			collectgarbage()
		end
	end

	---check all the actors and remove the ones which are not in use
	---@param combatObject combat
	---@param overriteInterval unixtime
	---@return integer
	local collectGarbage = function(combatObject, overriteInterval)
		--amount of actors removed
		local amountCleaned = 0

		--do not collect things in a mythic+ dungeon segment
		if (combatObject.is_mythic_dungeon_trash or combatObject.is_mythic_dungeon_run_id or combatObject.is_mythic_dungeon_segment) then
			return amountCleaned
		end

		---@type number
		local _tempo = _time()

		---@type number
		for containerId = 1, 4 do
			---@type actorcontainer
			local actorContainer = combatObject:GetContainer(containerId)
			---@type table<number, actor>
			local actorList = actorContainer:GetActorTable()

			for actorIndex = #actorList, 1, -1 do
				---@type actor
				local actorObject = actorList[actorIndex]

				if (not actorObject.grupo and not actorObject.boss and not actorObject.fight_component and not actorObject.boss_fight_component) then
					local canCollect = false

					--check the time of the last seen event coming from the actor
					---@type unixtime
					local lastSeenEventTime = actorObject.last_event

					---@type number
					local nextGarbageCollection

					if (overriteInterval) then
						nextGarbageCollection = lastSeenEventTime + overriteInterval
					else
						nextGarbageCollection = lastSeenEventTime + Details222.GarbageCollector.intervalTime
					end

					if (nextGarbageCollection - 1 < _tempo) then
						local owner = actorObject.owner --is the name or object?
						if (owner) then
							--local owner_actor = combatObject (tipo, owner.nome)
							if (not owner.grupo and not owner.boss and not owner.boss_fight_component) then
								canCollect = true
							end
						else
							canCollect = true
						end
					end

					if (canCollect) then
						local actorName = actorObject:Name()
						combatObject:RemoveActorFromSpellCastTable(actorName)

						if (not actorObject.owner) then --not a pet
							actorObject:subtract_total(combatObject)
						end

						amountCleaned = amountCleaned + 1

						if (containerId == 1 or containerId == 2) then --damage or healing
							Details.timeMachine:UnregisterActor(actorObject)
						end

						--remove the actor from the container
						tremove(actorList, actorIndex)
					end
				end
			end

			if (amountCleaned > 0) then
				fullRemap(combatObject[containerId])
				combatObject[containerId].need_refresh = true
				--print(beforeCleanupAmountOfActors, "before cleanup, after:", #combatObject[1]._ActorTable)
			end
		end

		return amountCleaned
	end

	---run the garbage collector
	---@param overriteLastEvent unixtime
	function Details222.GarbageCollector.RunGarbageCollector(overriteLastEvent)
		---@type number
		local amountRemoved = 0

		--create a list of all combats except the current one
		---@type table<number, combat>
		local allSegments = Details:GetCombatSegments()
		---@type table
		local segmentsList = {}

		---@type combat
		local currentCombat = Details:GetCurrentCombat()

		for _, combatObject in ipairs(allSegments) do
			if (combatObject ~= currentCombat) then
				segmentsList[#segmentsList+1] = combatObject
			end
		end

		--add the current segment at the end of the list
		segmentsList[#segmentsList+1] = currentCombat

		--collect the garbage
		for i, combatObject in ipairs(segmentsList) do
			local removedActors = collectGarbage(combatObject, overriteLastEvent)
			if (i == #segmentsList) then
				--print("current segment removed:", removedActors, "actors.")
			end
			amountRemoved = amountRemoved + removedActors
		end

		---@type combat
		local overallCombatObject = Details.tabela_overall
		amountRemoved = amountRemoved + collectGarbage(overallCombatObject, overriteLastEvent)

		if (amountRemoved > 0) then
			Details:InstanciaCallFunction(Details.ScheduleUpdate)
			Details:RefreshMainWindow(-1)
		end

		return amountRemoved
	end