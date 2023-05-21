
	local Details = _G.Details
	local Details = Details
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

	local classDamage =	Details.atributo_damage --details local
	local classHeal =		Details.atributo_heal --details local
	local classEnergy =		Details.atributo_energy --details local
	local classUtility =		Details.atributo_misc --details local
	local alvo_da_habilidade = 	Details.alvo_da_habilidade --details local
	local habilidade_dano = 	Details.habilidade_dano --details local
	local habilidade_cura = 		Details.habilidade_cura --details local
	local container_habilidades = 	Details.container_habilidades --details local
	local container_combatentes = Details.container_combatentes --details local

	local container_damage_target = Details.container_type.CONTAINER_DAMAGETARGET_CLASS

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants

	local class_type_dano = Details.atributos.dano
	local class_type_cura = Details.atributos.cura
	local class_type_e_energy = Details.atributos.e_energy
	local class_type_misc = Details.atributos.misc

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
		function Details:RestoreOverallMetatables()
			local is_in_instance = select(1, IsInInstance())

			local combate = Details.tabela_overall
			combate.overall_refreshed = true
			combate.hasSaved = true

			combate.__call = Details.call_combate

			Details.refresh:r_combate (combate)

			Details.refresh:r_container_combatentes (combate [class_type_dano])
			Details.refresh:r_container_combatentes (combate [class_type_cura])
			Details.refresh:r_container_combatentes (combate [class_type_e_energy])
			Details.refresh:r_container_combatentes (combate [class_type_misc])

			Details.refresh:r_container_combatentes (combate [5]) --ghost container

			local todos_atributos = {combate [class_type_dano]._ActorTable, combate [class_type_cura]._ActorTable, combate [class_type_e_energy]._ActorTable, combate [class_type_misc]._ActorTable}

			for class_type, atributo in ipairs(todos_atributos) do
				for _, esta_classe in ipairs(atributo) do
					local nome = esta_classe.nome

					if (is_in_instance and Details.remove_realm_from_name) then
						esta_classe.displayName = nome:gsub(("%-.*"), "")
					elseif (Details.remove_realm_from_name) then
						esta_classe.displayName = nome:gsub(("%-.*"), "") --"%*"
					else
						esta_classe.displayName = nome
					end

					if (class_type == class_type_dano) then
						Details.refresh:r_atributo_damage (esta_classe)

					elseif (class_type == class_type_cura) then
						Details.refresh:r_atributo_heal (esta_classe)

					elseif (class_type == class_type_e_energy) then
						Details.refresh:r_atributo_energy (esta_classe)

					elseif (class_type == class_type_misc) then
						Details.refresh:r_atributo_misc (esta_classe)
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
		function Details:RestoreMetatables()

				Details.refresh:r_atributo_custom()

			--container de pets e hist�rico
				Details.refresh:r_container_pets (Details.tabela_pets)
				Details.refresh:r_historico (Details.tabela_historico)

			--tabelas dos combates
				local combate_overall = Details.tabela_overall
				local overall_dano = combate_overall [class_type_dano] --damage atalho
				local overall_cura = combate_overall [class_type_cura] --heal atalho
				local overall_energy = combate_overall [class_type_e_energy] --energy atalho
				local overall_misc = combate_overall [class_type_misc] --misc atalho

				local tabelas_do_historico = Details.tabela_historico.tabelas --atalho

			--recupera meta function
				for _, combat_table in ipairs(tabelas_do_historico) do
					combat_table.__call = Details.call_combate
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
						Details.refresh:r_combate (combate, combate_overall)

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
							if (not Details.tabela_overall.overall_enemy_name) then
								Details.tabela_overall.overall_enemy_name = combate.is_boss and combate.is_boss.name or combate.enemy
							else
								if (Details.tabela_overall.overall_enemy_name ~= (combate.is_boss and combate.is_boss.name or combate.enemy)) then
									Details.tabela_overall.overall_enemy_name = "-- x -- x --"
								end
							end

							combate_overall.segments_added =combate_overall.segments_added or {}
							local date_start, date_end = combate:GetDate()
							tinsert(combate_overall.segments_added, {name = combate:GetCombatName(true), elapsed = combate:GetCombatTime(), clock = date_start})

						end

						--recupera a meta e indexes dos 4 container
						Details.refresh:r_container_combatentes (combate [class_type_dano], overall_dano)
						Details.refresh:r_container_combatentes (combate [class_type_cura], overall_cura)
						Details.refresh:r_container_combatentes (combate [class_type_e_energy], overall_energy)
						Details.refresh:r_container_combatentes (combate [class_type_misc], overall_misc)

						--ghost container
						if (combate[5]) then
							Details.refresh:r_container_combatentes (combate [5], combate_overall [5])
						end

						--tabela com os 4 tabelas de jogadores
						local todos_atributos = {combate [class_type_dano]._ActorTable, combate [class_type_cura]._ActorTable, combate [class_type_e_energy]._ActorTable, combate [class_type_misc]._ActorTable}

						for class_type, atributo in ipairs(todos_atributos) do
							for _, esta_classe in ipairs(atributo) do

								local nome = esta_classe.nome

								if (is_in_instance and Details.remove_realm_from_name) then
									esta_classe.displayName = nome:gsub(("%-.*"), "")
								elseif (Details.remove_realm_from_name) then
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

	function Details:DoInstanceCleanup()
		for _, instanceObject in ipairs(Details.tabela_instancias) do
			---@cast instanceObject instance

			if (instanceObject.StatusBar.left) then
				instanceObject.StatusBarSaved = {
					["left"] = instanceObject.StatusBar.left.real_name or "NONE",
					["center"] = instanceObject.StatusBar.center.real_name or "NONE",
					["right"] = instanceObject.StatusBar.right.real_name or "NONE",
				}
				instanceObject.StatusBarSaved.options = {
					[instanceObject.StatusBarSaved.left] = instanceObject.StatusBar.left.options,
					[instanceObject.StatusBarSaved.center] = instanceObject.StatusBar.center.options,
					[instanceObject.StatusBarSaved.right] = instanceObject.StatusBar.right.options
				}
			end

			--erase all widgets frames
			instanceObject.scroll = nil
			instanceObject.baseframe = nil
			instanceObject.bgframe = nil
			instanceObject.bgdisplay = nil
			instanceObject.freeze_icon = nil
			instanceObject.freeze_texto = nil
			instanceObject.barras = nil
			instanceObject.showing = nil
			instanceObject.agrupada_a = nil
			instanceObject.grupada_pos = nil
			instanceObject.agrupado = nil
			instanceObject._version = nil
			instanceObject.h_baixo = nil
			instanceObject.h_esquerda = nil
			instanceObject.h_direita = nil
			instanceObject.h_cima = nil
			instanceObject.break_snap_button = nil
			instanceObject.alert = nil
			instanceObject.StatusBar = nil
			instanceObject.consolidateFrame = nil
			instanceObject.consolidateButtonTexture = nil
			instanceObject.consolidateButton = nil
			instanceObject.lastIcon = nil
			instanceObject.firstIcon = nil
			instanceObject.menu_attribute_string = nil
			instanceObject.wait_for_plugin_created = nil
			instanceObject.waiting_raid_plugin = nil
			instanceObject.waiting_pid = nil
		end

		--unused instances
		for _, instanceObject in ipairs(Details.unused_instances) do
			---@cast instanceObject instance

			if (instanceObject.StatusBar.left) then
				instanceObject.StatusBarSaved = {
					["left"] = instanceObject.StatusBar.left.real_name or "NONE",
					["center"] = instanceObject.StatusBar.center.real_name or "NONE",
					["right"] = instanceObject.StatusBar.right.real_name or "NONE",
				}
				instanceObject.StatusBarSaved.options = {
					[instanceObject.StatusBarSaved.left] = instanceObject.StatusBar.left.options,
					[instanceObject.StatusBarSaved.center] = instanceObject.StatusBar.center.options,
					[instanceObject.StatusBarSaved.right] = instanceObject.StatusBar.right.options
				}
			end

			--erase all widgets frames
			instanceObject.scroll = nil
			instanceObject.baseframe = nil
			instanceObject.bgframe = nil
			instanceObject.bgdisplay = nil
			instanceObject.freeze_icon = nil
			instanceObject.freeze_texto = nil
			instanceObject.barras = nil
			instanceObject.showing = nil
			instanceObject.agrupada_a = nil
			instanceObject.grupada_pos = nil
			instanceObject.agrupado = nil
			instanceObject._version = nil
			instanceObject.h_baixo = nil
			instanceObject.h_esquerda = nil
			instanceObject.h_direita = nil
			instanceObject.h_cima = nil
			instanceObject.break_snap_button = nil
			instanceObject.alert = nil
			instanceObject.StatusBar = nil
			instanceObject.consolidateFrame = nil
			instanceObject.consolidateButtonTexture = nil
			instanceObject.consolidateButton = nil
			instanceObject.lastIcon = nil
			instanceObject.firstIcon = nil
			instanceObject.menu_attribute_string = nil
			instanceObject.wait_for_plugin_created = nil
			instanceObject.waiting_raid_plugin = nil
			instanceObject.waiting_pid = nil
		end
	end

	function Details:DoOwnerCleanup()
		---@type combat[]
		local combats = Details.tabela_historico.tabelas or {}
		local bOverallAdded
		if (not Details.overall_clear_logout) then
			tinsert(combats, Details.tabela_overall)
			bOverallAdded = true
		end

		for index, combat in ipairs(combats) do
			---@cast combat combat
			for index, actorContainer in ipairs(combat) do
				---@cast actorContainer actorcontainer
				for index, actorObject in ipairs(actorContainer._ActorTable) do
					---@cast actorObject actor
					actorObject.owner = nil
				end
			end
		end

		if (bOverallAdded) then
			tremove(combats, #combats)
		end
	end

	function Details:DoClassesCleanup()
		---@type combat[]
		local combats = Details.tabela_historico.tabelas or {}
		local bOverallAdded
		if (not Details.overall_clear_logout) then
			tinsert(combats, Details.tabela_overall)
			bOverallAdded = true
		end

		for index, combatObject in ipairs(combats) do
			for classType, actorContainer in ipairs(combatObject) do
				---@cast actorContainer actorcontainer
				for index, actorObject in ipairs(actorContainer._ActorTable) do
					---@cast actorObject actor

					actorObject.displayName = nil
					actorObject.minha_barra = nil

					if (classType == class_type_dano) then
						Details.clear:c_atributo_damage(actorObject)

					elseif (classType == class_type_cura) then
						Details.clear:c_atributo_heal(actorObject)

					elseif (classType == class_type_e_energy) then
						Details.clear:c_atributo_energy(actorObject)

					elseif (classType == class_type_misc) then
						Details.clear:c_atributo_misc(actorObject)
					end
				end
			end
		end

		if (bOverallAdded) then
			tremove(combats, #combats)
		end
	end

	function Details:DoContainerCleanup()
		---@type combat[]
		local combats = Details.tabela_historico.tabelas or {}
		local bOverallAdded
		if (not Details.overall_clear_logout) then
			tinsert(combats, Details.tabela_overall)
			bOverallAdded = true
		end

		for index, combat in ipairs(combats) do
			Details.clear:c_combate(combat)
			for index, container in ipairs(combat) do
				Details.clear:c_container_combatentes(container)
			end
		end

		if (bOverallAdded) then
			tremove(combats, #combats)
		end
	end

	function Details:DoContainerIndexCleanup()
		---@type combat[]
		local combats = Details.tabela_historico.tabelas or {}
		local bOverallAdded
		if (not Details.overall_clear_logout) then
			tinsert(combats, Details.tabela_overall)
			bOverallAdded = true
		end

		for index, combat in ipairs(combats) do
			for index, container in ipairs(combat) do
				Details.clear:c_container_combatentes_index(container)
			end
		end

		if (bOverallAdded) then
			tremove(combats, #combats)
		end
	end

	--limpa indexes, metatables e shadows
		function Details:PrepareTablesForSave()
			Details.clear_ungrouped = true

		--clear instances
			Details:DoInstanceCleanup()
			Details:DoClassesCleanup() --aumentou 1 combat
			Details:DoContainerCleanup() --aumentou 1 combat

		--clear combats
			local combatTables = {}
			---@type combat[]
			local combatHistoryTable = Details.tabela_historico.tabelas or {}

			--remove os segmentos de trash
			for i = #combatHistoryTable, 1, -1  do
				---@type combat
				local combateObject = combatHistoryTable[i]
				if (combateObject:IsTrash()) then
					table.remove(combatHistoryTable, i)
					Details:Destroy(combatHistoryTable)
				end
			end

			--remove os segmentos > que o limite permitido para salvar
			if (Details.segments_amount_to_save and Details.segments_amount_to_save < Details.segments_amount) then
				for i = Details.segments_amount, Details.segments_amount_to_save+1, -1  do
					if (Details.tabela_historico.tabelas[i]) then
						---@type combat
						local combatObject = Details.tabela_historico.tabelas[i]
						table.remove(Details.tabela_historico.tabelas, i)
						Details:Destroy(combatObject)
					end
				end
			end

			--limpa a tabela overall
			if (Details.overall_clear_logout) then
				Details.tabela_overall = nil
				_detalhes_database.tabela_overall = nil
			else
				---@type combat
				local overallCombatObject = Details.tabela_overall

				overallCombatObject.previous_combat = nil
				---@type actorcontainer[]
				local allAttributes = {
					overallCombatObject[class_type_dano],
					overallCombatObject[class_type_cura],
					overallCombatObject[class_type_e_energy],
					overallCombatObject[class_type_misc]
				}

				--this is a cleanup for overall data
				if (Details.clear_ungrouped) then
					--deal with actor which could potentially be removed from the database
					for classType, actorContainer in ipairs(allAttributes) do
						--get the actor table from the container, this table can be used
						local actorTable = actorContainer:GetActorTable()
						for i = #actorTable, 1, -1 do
							---@type actor
							local actorObject = actorTable[i]
							if (actorObject.grupo and not actorObject.boss and not actorObject.boss_fight_component and not actorObject.fight_component and not actorObject.pvp_component and not actorObject.arena_enemy and not actorObject.enemy) then
								--remove the actor from the container
								table.remove(actorTable, i)
								Details:DestroyActor(actorTable, overallCombatObject)
							end
						end
						fullRemap(actorContainer)
					end
				end

				--now deal with pets without owners
				for classType, actorContainer in ipairs(allAttributes) do
					--get the actor table from the container, this table can be used
					local actorTable = actorContainer:GetActorTable()
					for i = #actorTable, 1, -1 do
						---@type actor
						local actorObject = actorTable[i]

						if (actorObject.owner) then
							if (not actorObject.owner.serial) then
								Details:DestroyActor(actorObject, overallCombatObject)
								table.remove(actorTable, i)
							end
						end
					end
					fullRemap(actorContainer)
				end
			end

			for i, combatObject in ipairs(combatHistoryTable) do
				---@cast combatObject combat
				combatTables[#combatTables+1] = combatObject
			end

			--this is a cleanup for combat stored in the segment list
			for combatIndex, combatObject in ipairs(combatTables) do
				--limpa a tabela do grafico
				if (Details.clear_graphic) then
					combatObject.TimeData = {}
				end

				--limpa a referencia do ultimo combate
				combatObject.previous_combat = nil

				local bIsBossEncounter = combatObject.is_boss
				if (bIsBossEncounter) then
					if (combatObject.pvp) then
						bIsBossEncounter = false
					end
				end

				if (not combatObject.is_mythic_dungeon_segment and Details.clear_ungrouped) then
					for i = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
						---@type actorcontainer
						local actorContainer = combatObject:GetContainer(i)
						if (actorContainer) then
							local actorTable = actorContainer:GetActorTable()
							for o = #actorTable, 1, -1 do
								local actorObject = actorTable[o]
								if (not actorObject.grupo and not actorObject.boss and not actorObject.boss_fight_component and not bIsBossEncounter and not actorObject.pvp_component and not actorObject.fight_component) then
									Details:DestroyActor(actorObject, combatObject)
									table.remove(actorTable, o)
								end
							end
							fullRemap(actorContainer)

							for o = #actorTable, 1, -1 do
								---@type actor
								local actorObject = actorTable[o]
								if (actorObject.owner) then
									if (not actorObject.owner.serial) then
										Details:DestroyActor(actorObject, combatObject)
										table.remove(actorTable, i)
									end
								end
							end
							fullRemap(actorContainer)
						end
					end
				end
			end

			--panic mode (in case the play disconnets during a boss encounter, drop all tables to speedup the login and login back process)
			if (Details.segments_panic_mode and Details.can_panic_mode) then
				if (Details.tabela_vigente.is_boss) then
					Details.tabela_historico = Details.historico:NovoHistorico()
				end
			end

			--clear all segments on logoff
			if (Details.data_cleanup_logout) then
				Details.tabela_historico = Details.historico:NovoHistorico()
				Details.tabela_overall = nil
				_detalhes_database.tabela_overall = nil
			end

			--clear customs
			Details.clear:c_atributo_custom()

			--clear owners
			Details:DoOwnerCleanup()

			--cleer container indexes
			Details:DoContainerIndexCleanup()
		end

	function Details:reset_window(instancia)
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