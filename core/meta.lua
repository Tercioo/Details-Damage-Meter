--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local _tempo = time()
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

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
	local DFLAG_pet = _detalhes.flags.pet

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	local function ReconstroiMapa (tabela)
		local mapa = {}
		for i = 1, #tabela._ActorTable do
			mapa [tabela._ActorTable[i].nome] = i
		end
		tabela._NameIndexTable = mapa
	end

	local function ReduzTotal (_actor, _combate)
		if (_actor.tipo == class_type_dano) then
			_combate.totals [class_type_dano] = _combate.totals [class_type_dano] - _actor.total
			if (_actor.grupo) then
				_combate.totals_grupo [class_type_dano] = _combate.totals_grupo [class_type_dano] - _actor.total
			end
			
		elseif (_actor.tipo == class_type_cura) then 
			_combate.totals [class_type_cura] = _combate.totals [class_type_cura] - _actor.total
			if (_actor.grupo) then
				_combate.totals_grupo [class_type_cura] = _combate.totals_grupo [class_type_cura] - _actor.total
			end
			
		elseif (_actor.tipo == class_type_e_energy) then
			_combate.totals [_actor.tipo] ["mana"] = _combate.totals [_actor.tipo] ["mana"] - _actor.mana
			_combate.totals [_actor.tipo] ["e_rage"] = _combate.totals [_actor.tipo] ["e_rage"] - _actor.e_rage
			_combate.totals [_actor.tipo] ["e_energy"] = _combate.totals [_actor.tipo] ["e_energy"] - _actor.e_energy
			_combate.totals [_actor.tipo] ["runepower"] = _combate.totals [_actor.tipo] ["runepower"] - _actor.runepower

			if (_actor.grupo) then
				_combate.totals_grupo [_actor.tipo] ["runepower"] = _combate.totals_grupo [_actor.tipo] ["runepower"] - _actor.runepower
				_combate.totals_grupo [_actor.tipo] ["e_energy"] = _combate.totals_grupo [_actor.tipo] ["e_energy"] - _actor.e_energy
				_combate.totals_grupo [_actor.tipo] ["e_rage"] = _combate.totals_grupo [_actor.tipo] ["e_rage"] - _actor.e_rage
				_combate.totals_grupo [_actor.tipo] ["mana"] = _combate.totals_grupo [_actor.tipo] ["mana"] - _actor.mana
			end
			
		elseif (_actor.tipo == class_type_misc) then
			if (_actor.cc_break) then 
				_combate.totals [_actor.tipo] ["cc_break"] = _combate.totals [_actor.tipo] ["cc_break"] - _actor.cc_break 
				if (_actor.grupo) then
					_combate.totals_grupo [_actor.tipo] ["cc_break"] = _combate.totals_grupo [_actor.tipo] ["cc_break"] - _actor.cc_break 
				end
			end
			if (_actor.ress) then 
				_combate.totals [_actor.tipo] ["ress"] = _combate.totals [_actor.tipo] ["ress"] - _actor.ress 
				if (_actor.grupo) then
					_combate.totals_grupo [_actor.tipo] ["ress"] = _combate.totals_grupo [_actor.tipo] ["ress"] - _actor.ress 
				end
			end
			if (_actor.interrupt) then 
				_combate.totals [_actor.tipo] ["interrupt"] = _combate.totals [_actor.tipo] ["interrupt"] - _actor.interrupt 
				if (_actor.grupo) then
					_combate.totals_grupo [_actor.tipo] ["interrupt"] = _combate.totals_grupo [_actor.tipo] ["interrupt"] - _actor.interrupt 
				end
			end
			if (_actor.dispell) then 
				_combate.totals [_actor.tipo] ["dispell"] = _combate.totals [_actor.tipo] ["dispell"] - _actor.dispell 
				if (_actor.grupo) then
					_combate.totals_grupo [_actor.tipo] ["dispell"] = _combate.totals_grupo [_actor.tipo] ["dispell"] - _actor.dispell 
				end
			end
			if (_actor.dead) then 
				_combate.totals [_actor.tipo] ["dead"] = _combate.totals [_actor.tipo] ["dead"] - _actor.dead 
				if (_actor.grupo) then
					_combate.totals_grupo [_actor.tipo] ["dead"] = _combate.totals_grupo [_actor.tipo] ["dead"] - _actor.dead 
				end
			end
		end
	end

	function _detalhes:RestauraMetaTables()
		
	----------------------------//containers principais
		_detalhes.refresh:r_container_pets (_detalhes.tabela_pets)
		_detalhes.refresh:r_historico (_detalhes.tabela_historico)

	----------------------------//combates

		local tabela_overall = _detalhes.tabela_overall

		local overall_dano = tabela_overall [class_type_dano]
		local overall_cura = tabela_overall [class_type_cura]
		local overall_energy = tabela_overall [class_type_e_energy]
		local overall_misc = tabela_overall [class_type_misc]
		
		local tabelas_de_combate = {}
		for _, _tabela in _ipairs (_detalhes.tabela_historico.tabelas) do
			tabelas_de_combate [#tabelas_de_combate+1] = _tabela
			_tabela.__call = _detalhes.call_combate
		end

		tabela_overall.end_time = _tempo
		tabela_overall.start_time = _tempo
		
		if (#tabelas_de_combate > 0) then
			for index, combate in _ipairs (tabelas_de_combate) do
				
				if (combate.end_time and combate.start_time) then 
					tabela_overall.start_time = tabela_overall.start_time - (combate.end_time - combate.start_time)
				end
			
				_detalhes.refresh:r_combate (combate, tabela_overall)
			
				_detalhes.refresh:r_container_combatentes (combate [class_type_dano], overall_dano)
				_detalhes.refresh:r_container_combatentes (combate [class_type_cura], overall_cura)
				_detalhes.refresh:r_container_combatentes (combate [class_type_e_energy], overall_energy)
				_detalhes.refresh:r_container_combatentes (combate [class_type_misc], overall_misc)
				
				local todos_atributos = {combate [class_type_dano]._ActorTable,
								 combate [class_type_cura]._ActorTable,
								 combate [class_type_e_energy]._ActorTable,
								 combate [class_type_misc]._ActorTable}

				for class_type, atributo in _ipairs (todos_atributos) do
					for _, esta_classe in _ipairs (atributo) do
					
						local nome = esta_classe.nome
						esta_classe.displayName = nome:gsub (("%-.*"), "")
						
						local shadow

						if (class_type == class_type_dano) then
						
							shadow = overall_dano._ActorTable [overall_dano._NameIndexTable[nome]]
							if (not shadow) then 
								--shadow = overall_dano:CriarShadow (esta_classe)
								shadow = overall_dano:PegarCombatente (esta_classe.serial, esta_classe.nome, esta_classe.flag_original, true)
								shadow.classe = esta_classe.classe
								shadow.start_time = _tempo
								shadow.end_time = _tempo
							end
							-- Reconstruir o container do friendly fire shadow aqui
							for index, friendlyfire in _ipairs (esta_classe.friendlyfire._ActorTable) do 
								--> criando o objeto do friendly fire na shadow
								local ff_shadow = shadow.friendlyfire:PegarCombatente (friendlyfire.serial, friendlyfire.nome, friendlyfire.flag_original, true)
								friendlyfire.shadow = ff_shadow

							end
							_detalhes.refresh:r_atributo_damage (esta_classe, shadow)
							shadow = shadow + esta_classe

						elseif (class_type == class_type_cura) then
							shadow = overall_cura._ActorTable [overall_cura._NameIndexTable[nome]]
							if (not shadow) then 
								--shadow = overall_cura:CriarShadow (esta_classe)
								shadow = overall_cura:PegarCombatente (esta_classe.serial, esta_classe.nome, esta_classe.flag_original, true)
								shadow.classe = esta_classe.classe
								shadow.start_time = _tempo
								shadow.end_time = _tempo
							end
							_detalhes.refresh:r_atributo_heal (esta_classe, shadow)
							shadow = shadow + esta_classe
							
						elseif (class_type == class_type_e_energy) then
							shadow = overall_energy._ActorTable [overall_energy._NameIndexTable[nome]]
							if (not shadow) then 
								--shadow = overall_energy:CriarShadow (esta_classe)
								shadow = overall_energy:PegarCombatente (esta_classe.serial, esta_classe.nome, esta_classe.flag_original, true)
								shadow.classe = esta_classe.classe
							end
							_detalhes.refresh:r_atributo_energy (esta_classe, shadow)
							shadow = shadow + esta_classe
							
						elseif (class_type == class_type_misc) then
						
						-- o problema ta na habilidade do interrupt, aqui ele só ta recriando os containers no Actor principal e não esta itinerando nas habilidades
						
							shadow = overall_misc._ActorTable [overall_misc._NameIndexTable[nome]]
							
							if (not shadow) then 
								--shadow = overall_misc:CriarShadow (esta_classe)
								shadow = overall_misc:PegarCombatente (esta_classe.serial, esta_classe.nome, esta_classe.flag_original, true)
								shadow.classe = esta_classe.classe
							end

							if (esta_classe.interrupt) then
								if (not shadow.interrupt_targets) then
									shadow.interrupt = 0
									shadow.interrupt_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
									shadow.interrupt_spell_tables = container_habilidades:NovoContainer (_detalhes.container_type.CONTAINER_MISC_CLASS) --> cria o container das habilidades usadas para interromper
									shadow.interrompeu_oque = {}
								end
							end
							
							if (esta_classe.ress) then
								if (not shadow.ress_targets) then
									shadow.ress = 0
									shadow.ress_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
									shadow.ress_spell_tables = container_habilidades:NovoContainer (_detalhes.container_type.CONTAINER_MISC_CLASS) --> cria o container das habilidades usadas para interromper
								end
							end
							
							if (esta_classe.dispell) then
								if (not shadow.dispell_targets) then
									shadow.dispell = 0
									shadow.dispell_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
									shadow.dispell_spell_tables = container_habilidades:NovoContainer (_detalhes.container_type.CONTAINER_MISC_CLASS) --> cria o container das habilidades usadas para interromper
									shadow.dispell_oque = {}
								end
							end
							
							if (esta_classe.cc_break) then
								if (not shadow.cc_break) then
									shadow.cc_break = 0
									shadow.cc_break_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
									shadow.cc_break_spell_tables = container_habilidades:NovoContainer (_detalhes.container_type.CONTAINER_MISC_CLASS) --> cria o container das habilidades usadas para interromper
									shadow.cc_break_oque = {}
								end
							end
							
							_detalhes.refresh:r_atributo_misc (esta_classe, shadow)
							shadow = shadow + esta_classe
							
							if (esta_classe.interrupt) then
								for _, este_alvo in _ipairs (esta_classe.interrupt_targets._ActorTable) do
									_detalhes.refresh:r_alvo_da_habilidade (este_alvo, shadow.interrupt_targets)
								end
							end
							if (esta_classe.ress) then
								for _, este_alvo in _ipairs (esta_classe.ress_targets._ActorTable) do
									_detalhes.refresh:r_alvo_da_habilidade (este_alvo, shadow.ress_targets)
								end
							end
							if (esta_classe.dispell) then
								for _, este_alvo in _ipairs (esta_classe.dispell_targets._ActorTable) do
									_detalhes.refresh:r_alvo_da_habilidade (este_alvo, shadow.dispell_targets)
								end
							end
							if (esta_classe.cc_break) then
								for _, este_alvo in _ipairs (esta_classe.cc_break_targets._ActorTable) do
									_detalhes.refresh:r_alvo_da_habilidade (este_alvo, shadow.cc_break_targets)
								end
							end
						end

						shadow:FazLinkagem (esta_classe)

						if (class_type ~= class_type_misc) then
							for _, este_alvo in _ipairs (esta_classe.targets._ActorTable) do
								_detalhes.refresh:r_alvo_da_habilidade (este_alvo, shadow.targets)
							end
							
							for _, habilidade in _pairs (esta_classe.spell_tables._ActorTable) do
								if (class_type == class_type_dano) then
									_detalhes.refresh:r_habilidade_dano (habilidade, shadow.spell_tables) --> passando o container de habilidades
								elseif (class_type == class_type_cura) then
									_detalhes.refresh:r_habilidade_cura (habilidade, shadow.spell_tables)
								elseif (class_type == class_type_e_energy) then
									_detalhes.refresh:r_habilidade_e_energy (habilidade, shadow.spell_tables)
								end

								for _, este_alvo in _ipairs (habilidade.targets._ActorTable) do
									_detalhes.refresh:r_alvo_da_habilidade (este_alvo, habilidade.targets.shadow)
								end
							end
						else
							if (esta_classe.interrupt) then
								for _, habilidade in _pairs (esta_classe.interrupt_spell_tables._ActorTable) do
									_detalhes.refresh:r_habilidade_misc (habilidade, shadow.interrupt_spell_tables)
									
									for _, este_alvo in _ipairs (habilidade.targets._ActorTable) do
										_detalhes.refresh:r_alvo_da_habilidade (este_alvo, habilidade.targets.shadow)
									end
								end
							end
							
							if (esta_classe.ress) then
								for _, habilidade in _pairs (esta_classe.ress_spell_tables._ActorTable) do
									_detalhes.refresh:r_habilidade_misc (habilidade, shadow.ress_spell_tables)
									
									for _, este_alvo in _ipairs (habilidade.targets._ActorTable) do
										_detalhes.refresh:r_alvo_da_habilidade (este_alvo, habilidade.targets.shadow)
									end
								end
							end
							
							if (esta_classe.dispell) then
								for _, habilidade in _pairs (esta_classe.dispell_spell_tables._ActorTable) do
									_detalhes.refresh:r_habilidade_misc (habilidade, shadow.dispell_spell_tables)
									
									for _, este_alvo in _ipairs (habilidade.targets._ActorTable) do
										_detalhes.refresh:r_alvo_da_habilidade (este_alvo, habilidade.targets.shadow)
									end
								end
							end
							
							if (esta_classe.cc_break) then
								for _, habilidade in _pairs (esta_classe.cc_break_spell_tables._ActorTable) do
									_detalhes.refresh:r_habilidade_misc (habilidade, shadow.cc_break_spell_tables)
									
									for _, este_alvo in _ipairs (habilidade.targets._ActorTable) do
										_detalhes.refresh:r_alvo_da_habilidade (este_alvo, habilidade.targets.shadow)
									end
								end
							end
							
						end
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
		end
	end


	function _detalhes:PrepareTablesForSave()

	----------------------------//overall

		local tabelas_de_combate = {}
		
		local historico_tabelas = _detalhes.tabela_historico.tabelas or {}
		
		if (_detalhes.segments_amount_to_save and _detalhes.segments_amount_to_save < _detalhes.segments_amount) then
			for i = _detalhes.segments_amount, _detalhes.segments_amount_to_save+1, -1  do
				if (_detalhes.tabela_historico.tabelas [i]) then
					_detalhes.tabela_historico.tabelas [i] = nil
				end
			end
		end
		
		--local tabela_overall = _detalhes.tabela_overall
		_detalhes.tabela_overall = nil
		
		local tabela_atual = _detalhes.tabela_vigente or {}
		
		for _, _tabela in _ipairs (historico_tabelas) do
			tabelas_de_combate [#tabelas_de_combate+1] = _tabela
		end
		
		tabelas_de_combate [#tabelas_de_combate+1] = tabela_atual
		--tabelas_de_combate [#tabelas_de_combate+1] = tabela_overall

		--> make sure details database exists
		_detalhes_database = _detalhes_database or {}
		
		for tabela_index, _combate in _ipairs (tabelas_de_combate) do

			--> limpa a tabela do grafico -- clear graphic table
			if (_detalhes.clear_graphic) then 
				_combate.TimeData = {}
			end
		
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
										can_erase = false
									end
								end
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
			if (_detalhes.segments_panic_mode and _detalhes.in_combat) then
				if (_detalhes.tabela_vigente.is_boss) then
					_detalhes.tabela_historico = _detalhes.historico:NovoHistorico()
				end
			end
		
		
		--> Limpa instâncias
		for _, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
			--> detona a janela do Solo Mode

			esta_instancia.barras = nil
			esta_instancia.showing = nil
			
			--> apaga os frames
			esta_instancia.scroll = nil
			esta_instancia.baseframe = nil
			esta_instancia.bgframe = nil
			esta_instancia.bgdisplay = nil
			esta_instancia.freeze_icon = nil
			esta_instancia.freeze_texto = nil
			
			esta_instancia.agrupada_a = nil
			esta_instancia.grupada_pos = nil
			esta_instancia.agrupado = nil
			
			if (esta_instancia.StatusBar.left) then
				esta_instancia.StatusBarSaved = {
					["left"] = esta_instancia.StatusBar.left.real_name or "NONE",
					["center"] = esta_instancia.StatusBar.center.real_name or "NONE",
					["right"] = esta_instancia.StatusBar.right.real_name or "NONE",
					["options"] = esta_instancia.StatusBar.options
				}
			end
			
			esta_instancia.StatusBar = nil
			
		end

	end

	function _detalhes:reset_window (instancia)
		if (instancia.segmento == -1) then
			instancia.showing[instancia.atributo].need_refresh = true
			instancia.v_barras = true
			instancia:ResetaGump()
			instancia:AtualizaGumpPrincipal (true)
		end
	end



	function _detalhes:IniciarColetaDeLixo()

		if (_detalhes.ultima_coleta + _detalhes.intervalo_coleta > _detalhes._tempo + 1)  then
			return
		elseif (_detalhes.in_combat or _InCombatLockdown() or _detalhes:IsInInstance()) then 
			_detalhes:ScheduleTimer ("IniciarColetaDeLixo", 5) 
			return
		end

		_detalhes:ClearParserCache()
		
		local limpados = atributo_damage:ColetarLixo() + atributo_heal:ColetarLixo() + atributo_energy:ColetarLixo() + atributo_misc:ColetarLixo()
		
		if (limpados > 0) then
			_detalhes:InstanciaCallFunction (_detalhes.reset_window)
		end

		--print ("coletados: " .. limpados)
		
		_detalhes.ultima_coleta = _detalhes._tempo
		
	end



	local function FazColeta (_combate, tipo)
		
		local conteudo = _combate [tipo]._ActorTable
		local _iter = {index = 1, data = conteudo[1], cleaned = 0}
		local _tempo  = _time()
		
		while (_iter.data) do
		
			local _actor = _iter.data
			local can_garbage = false
			
			if (not _actor.grupo and not _actor.boss and not _actor.boss_fight_component and _actor.last_event + _detalhes.intervalo_coleta < _tempo) then 
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
					ReduzTotal (_actor, _combate)
				end
			
				--> fix para a weak table
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
			
				_iter.cleaned = _iter.cleaned+1
				_table_remove (conteudo, _iter.index)
				_iter.data = conteudo [_iter.index]
			else
				_iter.index = _iter.index + 1
				_iter.data = conteudo [_iter.index]
			end
		
		end
		
		if (_iter.cleaned > 0) then
			ReconstroiMapa (_combate [tipo])
			_combate [tipo].need_refresh = true
		end
		
		return _iter.cleaned
	end

	function _detalhes:ColetarLixo (tipo)

		for index, instancia in _ipairs (_detalhes.tabela_instancias) do 
			if (instancia:IsAtiva()) then
				for i, barra in _ipairs (instancia.barras) do 
					if (not barra:IsShown()) then
						barra.minha_tabela = nil
					end
				end
			end
		end

		local _tempo  = _time()
		local limpados = 0

		local tabelas_de_combate = {}
		for _, _tabela in _ipairs (_detalhes.tabela_historico.tabelas) do
			if (_tabela ~= _detalhes.tabela_vigente) then
				tabelas_de_combate [#tabelas_de_combate+1] = _tabela
			end
		end
		tabelas_de_combate [#tabelas_de_combate+1] = _detalhes.tabela_vigente
		
		for _, _combate in _ipairs (tabelas_de_combate) do 
			limpados = limpados + FazColeta (_combate, tipo)
		end

		--> clear shadow tables
		local _overall_combat = _detalhes.tabela_overall	
		local conteudo = _overall_combat [tipo]._ActorTable
		_iter = {index = 1, data = conteudo[1], cleaned = 0} --> ._ActorTable[1] para pegar o primeiro index
		
		collectgarbage()
		
		while (_iter.data) do
		
			local _actor = _iter.data
		
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
			
			if (tipo == 1 and #new_weak_table > 0) then
			--	print (can_garbage, _actor.nome)
			end
			
			
			if (can_garbage or not meus_links) then --> não há referências a este objeto
				
				if (not _actor.owner) then --> pet
					ReduzTotal (_actor, _overall_combat)
				end

				--> apaga a referência deste jogador na tabela overall
				_iter.cleaned = _iter.cleaned+1
				_table_remove (conteudo, _iter.index)
				_iter.data = conteudo [_iter.index]
			else
				_actor.links = new_weak_table
				_iter.index = _iter.index + 1
				_iter.data = conteudo [_iter.index]
			end

		end
		
		--> elimina pets antigos
		local _new_PetTable = {}
		for PetSerial, PetTable in _pairs (_detalhes.tabela_pets.pets) do 
			if (PetTable[4] + _detalhes.intervalo_coleta > _detalhes._tempo + 1) then
				_new_PetTable [PetSerial] = PetTable
			end
		end
		
		_table_wipe (_detalhes.tabela_pets.pets)
		_detalhes.tabela_pets.pets = _new_PetTable
		
		--> wipa container de escudos
		_table_wipe (_detalhes.escudos)
		
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
