
local Details = _G.Details
local tocName, Details222 = ...

local _
local pairs = pairs --lua local
local ipairs = ipairs --lua local
local rawget = rawget --lua local
local setmetatable = setmetatable --lua local
local _table_remove = table.remove --lua local
local _bit_band = bit.band --lua local
local _time = time --lua local

local InCombatLockdown = InCombatLockdown --wow api local

local classDamage =	Details.atributo_damage --details local
local classHeal =		Details.atributo_heal --details local
local classEnergy =		Details.atributo_energy --details local
local classUtility =		Details.atributo_misc --details local

local classTypeDamage = Details.atributos.dano
local classTypeHeal = Details.atributos.cura
local classTypeEnergy = Details.atributos.e_energy
local classTypeUtility = Details.atributos.misc

	--restore actor containers indexes e metatables
	function Details:RestoreOverallMetatables()
		local bIsInInstance = select(1, IsInInstance())

		---@type combat
		local combatObjectOverall = Details.tabela_overall
		combatObjectOverall.overall_refreshed = true
		combatObjectOverall.__call = Details.call_combate

		Details.refresh:r_combate(combatObjectOverall)

		Details.refresh:r_container_combatentes(combatObjectOverall[classTypeDamage])
		Details.refresh:r_container_combatentes(combatObjectOverall[classTypeHeal])
		Details.refresh:r_container_combatentes(combatObjectOverall[classTypeEnergy])
		Details.refresh:r_container_combatentes(combatObjectOverall[classTypeUtility])
		Details.refresh:r_container_combatentes(combatObjectOverall[5]) --ghost container

		local todos_atributos = {
			combatObjectOverall[classTypeDamage]._ActorTable,
			combatObjectOverall[classTypeHeal]._ActorTable,
			combatObjectOverall[classTypeEnergy]._ActorTable,
			combatObjectOverall[classTypeUtility]._ActorTable
		}

		for classType = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
			local actorContainer = combatObjectOverall[classType]
			local actorTable = actorContainer._ActorTable
			for i = 1, #actorTable do
				---@type actor
				local thisActor = actorTable[i]
				local actorName = thisActor.nome

				if (bIsInInstance and Details.remove_realm_from_name) then
					thisActor.displayName = actorName:gsub(("%-.*"), "")
				elseif (Details.remove_realm_from_name) then
					thisActor.displayName = actorName:gsub(("%-.*"), "") --"%*"
				else
					thisActor.displayName = actorName
				end

				if (classType == classTypeDamage) then
					Details.refresh:r_atributo_damage(thisActor)

				elseif (classType == classTypeHeal) then
					Details.refresh:r_atributo_heal(thisActor)

				elseif (classType == classTypeEnergy) then
					Details.refresh:r_atributo_energy(thisActor)

				elseif (classType == classTypeUtility) then
					Details.refresh:r_atributo_misc(thisActor)
				end

				if (thisActor.ownerName) then
					thisActor.owner = combatObjectOverall(classType, thisActor.ownerName)
					if (not thisActor.owner) then
						Details:Msg("found orphan pet (overall), owner not found: ", thisActor.ownerName, " - ", thisActor.nome)
					end
				end
			end
		end
	end

	function Details:RestoreMetatables() --called from Details222.LoadSavedVariables.CombatSegments() --restore actor containers indexes e metatables
		--segment container
		setmetatable(Details.tabela_historico, Details.historico)

		---@type combat
		local overallCombatObject = Details.tabela_overall

		---@type combat[]
		local segmentsTable = Details:GetCombatSegments()

		--retore the call "combat()" functionality
		for _, combatObject in ipairs(segmentsTable) do
			combatObject.__call = Details.call_combate
		end

		--true if the overall data was saved and restored
		local bHadOverallDataSaved = overallCombatObject.overall_refreshed

		if (not bHadOverallDataSaved) then
			overallCombatObject.start_time = GetTime()
			overallCombatObject.end_time = GetTime()
		end

		overallCombatObject.segments_added = overallCombatObject.segments_added or {}

		local bIsInInstance = IsInInstance()

		--inicia a recupera��o das tabelas e montagem do overall
		if (#segmentsTable > 0) then
			for index, thisCombatObject in ipairs(segmentsTable) do
				---@cast thisCombatObject combat

				--set the metatable, __call and __index
				Details.refresh:r_combate(thisCombatObject)

				--related to overall data
				if (not bHadOverallDataSaved and thisCombatObject.overall_added) then
					--overall data endTime
					if (thisCombatObject.end_time and thisCombatObject.start_time) then
						overallCombatObject.start_time = overallCombatObject.start_time - (thisCombatObject.end_time - thisCombatObject.start_time)
					end

					--overall data startTime
					if (overallCombatObject:GetDate() == 0) then
						overallCombatObject:SetDate(thisCombatObject:GetDate() or 0)
					end

					--overall data finished time
					local thisCombatDateStart, thisCombaDateEnd = thisCombatObject:GetDate()
					local overallDateStart, overallDateEnd = overallCombatObject:GetDate()
					overallCombatObject:SetDate(nil, thisCombaDateEnd or overallDateEnd)

					--overall data enemy name
					if (not Details.tabela_overall.overall_enemy_name) then
						Details.tabela_overall.overall_enemy_name = thisCombatObject.is_boss and thisCombatObject.is_boss.name or thisCombatObject.enemy
					else
						if (Details.tabela_overall.overall_enemy_name ~= (thisCombatObject.is_boss and thisCombatObject.is_boss.name or thisCombatObject.enemy)) then
							Details.tabela_overall.overall_enemy_name = "-- x -- x --"
						end
					end

					--overall data segments added
					local dateStart, dateEnd = thisCombatObject:GetDate()
					table.insert(overallCombatObject.segments_added, {name = thisCombatObject:GetCombatName(false, true), elapsed = thisCombatObject:GetCombatTime(), clock = dateStart})
				end

				--ghost container (container for custom displays, this is not a real container)
				if (thisCombatObject[5]) then
					Details.refresh:r_container_combatentes(thisCombatObject[5])
				end

				local damageActorContainer = thisCombatObject[classTypeDamage]
				local healActorContainer = thisCombatObject[classTypeHeal]
				local resourcesActorContainer = thisCombatObject[classTypeEnergy]
				local utilityActorContainer = thisCombatObject[classTypeUtility]

				--recupera a meta e indexes dos 4 container
				Details.refresh:r_container_combatentes(damageActorContainer)
				Details.refresh:r_container_combatentes(healActorContainer)
				Details.refresh:r_container_combatentes(resourcesActorContainer)
				Details.refresh:r_container_combatentes(utilityActorContainer)

				for classType = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
					local actorContainer = thisCombatObject[classType]
					local actorTable = actorContainer._ActorTable
					for i = 1, #actorTable do
						---@type actor
						local actorObject = actorTable[i]
						local actorName = actorObject.nome

						--set back the display name (isn't saved with the object)
						if (bIsInInstance and Details.remove_realm_from_name) then
							actorObject.displayName = actorName:gsub(("%-.*"), "")
						elseif (Details.remove_realm_from_name) then
							actorObject.displayName = actorName:gsub(("%-.*"), "")
						else
							actorObject.displayName = actorName
						end

						if (classType == classTypeDamage) then
							if (thisCombatObject.overall_added and not bHadOverallDataSaved) then
								--add the actorObject into another combat, if does not exists there, create it, if exists sum the values
								local bRefreshActor = true
								classDamage:AddToCombat(actorObject, bRefreshActor, overallCombatObject)
							else
								Details.refresh:r_atributo_damage(actorObject)
							end

						elseif (classType == classTypeHeal) then
							if (thisCombatObject.overall_added and not bHadOverallDataSaved) then
								local bRefreshActor = true
								classHeal:AddToCombat(actorObject, bRefreshActor, overallCombatObject)
							else
								Details.refresh:r_atributo_heal(actorObject)
							end

						elseif (classType == classTypeEnergy) then
							if (thisCombatObject.overall_added and not bHadOverallDataSaved) then
								classEnergy:r_connect_shadow (actorObject)
							else
								classEnergy:r_onlyrefresh_shadow (actorObject)
							end

						elseif (classType == classTypeUtility) then
							if (thisCombatObject.overall_added and not bHadOverallDataSaved) then
								classUtility:r_connect_shadow (actorObject)
							else
								classUtility:r_onlyrefresh_shadow (actorObject)
							end
						end
					end
				end

				--link pets to owners
				for class_type = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
					local actorContainer = thisCombatObject[class_type]
					local actorTable = actorContainer._ActorTable
					for i = 1, #actorTable do
						---@type actor
						local actorObject = actorTable[i]
						if (actorObject.ownerName) then --name of the pet owner
							actorObject.owner = thisCombatObject(class_type, actorObject.ownerName)
							--technically, if the owner isn't found, this is an orphan and it could be removed from the combat
						end
					end
				end
			end
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

	---remove all .owner references from actors, this unlink pets from owners but still leave the actor.ownerName member to rebuild later
	function Details:RemoveOwnerFromPets()
		---@type combat[]
		local segmentsTable = Details:GetCombatSegments() or {}

		local bOverallAdded
		if (not Details.overall_clear_logout) then
			table.insert(segmentsTable, Details.tabela_overall)
			bOverallAdded = true
		end

		for _, combatObject in ipairs(segmentsTable) do
			---@cast combatObject combat
			for _, actorContainer in ipairs(combatObject) do
				---@cast actorContainer actorcontainer
				for _, actorObject in ipairs(actorContainer._ActorTable) do
					---@cast actorObject actor
					actorObject.owner = nil
				end
			end
		end

		if (bOverallAdded) then
			table.remove(segmentsTable, #segmentsTable)
		end
	end

	function Details:DoClassesCleanup()
		---@type combat[]
		local segmentsTable = Details:GetCombatSegments() or {}
		local bOverallAdded = false
		if (not Details.overall_clear_logout) then
			--add the overall segment to the cleanup within the other segments
			--it is removed after the cleanup
			table.insert(segmentsTable, Details.tabela_overall)
			bOverallAdded = true
		end

		for index, combatObject in ipairs(segmentsTable) do
			---@cast combatObject combat
			for classType, actorContainer in ipairs(combatObject) do
				---@cast actorContainer actorcontainer
				for _, actorObject in ipairs(actorContainer._ActorTable) do --low level loop for performance
					---@cast actorObject actor

					actorObject.displayName = nil
					actorObject.minha_barra = nil

					if (classType == classTypeDamage) then
						Details.clear:c_atributo_damage(actorObject)

					elseif (classType == classTypeHeal) then
						Details.clear:c_atributo_heal(actorObject)

					elseif (classType == classTypeEnergy) then
						Details.clear:c_atributo_energy(actorObject)

					elseif (classType == classTypeUtility) then
						Details.clear:c_atributo_misc(actorObject)
					end
				end
			end
		end

		if (bOverallAdded) then
			--remove the overall segment from the regular segments
			table.remove(segmentsTable, #segmentsTable)
		end
	end

	function Details:DoContainerCleanup()
		---@type combat[]
		local segmentsTable = Details:GetCombatSegments() or {}
		local bOverallAdded
		if (not Details.overall_clear_logout) then
			table.insert(segmentsTable, Details.tabela_overall)
			bOverallAdded = true
		end

		for _, combatObject in ipairs(segmentsTable) do
			---@cast combatObject combat
			Details.clear:c_combate(combatObject)
			for _, actorContainer in ipairs(combatObject) do
				---@cast actorContainer actorcontainer
				Details.clear:c_container_combatentes(actorContainer)
			end
		end

		if (bOverallAdded) then
			table.remove(segmentsTable, #segmentsTable)
		end
	end

	function Details:DoContainerIndexCleanup()
		---@type combat[]
		local segmentsTable = Details:GetCombatSegments() or {}
		local bOverallAdded
		if (not Details.overall_clear_logout) then
			table.insert(segmentsTable, Details.tabela_overall)
			bOverallAdded = true
		end

		for _, combatObject in ipairs(segmentsTable) do
			for _, actorContainer in ipairs(combatObject) do
				Details.clear:c_container_combatentes_index(actorContainer)
			end
		end

		if (bOverallAdded) then
			table.remove(segmentsTable, #segmentsTable)
		end
	end

	--limpa indexes e metatables
	function Details:PrepareTablesForSave()
		Details.clear_ungrouped = true

		--clear instances
		Details:DoInstanceCleanup()
		Details:DoClassesCleanup()
		Details:DoContainerCleanup()

		--clear combats
		---@type combat[]
		local combatTables = {}
		---@type combat[]
		local segmentsTable = Details:GetCombatSegments() or {}

		for i = #segmentsTable, 1, -1  do
			---@type combat
			local combatObject = segmentsTable[i]
			if (combatObject.__destroyed) then
				table.remove(segmentsTable, i)
			end
		end

		--remove segments marked as 'trash'
		for i = #segmentsTable, 1, -1  do
			---@type combat
			local combatObject = segmentsTable[i]
			if (combatObject:IsTrash()) then
				table.remove(segmentsTable, i)
			end
		end

		segmentsTable = Details:GetCombatSegments() or {}

		--remove segments > of the segment limit to save
		if (Details.segments_amount_to_save and Details.segments_amount_to_save < Details.segments_amount) then
			for i = Details.segments_amount, Details.segments_amount_to_save + 1, -1  do
				if (segmentsTable[i]) then
					table.remove(segmentsTable, i)
				end
			end
		end

		--clear overall segment
		if (Details.overall_clear_logout) then
			Details.tabela_overall = nil
			_detalhes_database.tabela_overall = nil
		else
			---@type combat
			local overallCombatObject = Details.tabela_overall

			--this is a cleanup for overall data (overall)
			if (Details.clear_ungrouped) then
				--deal with actor which could potentially be removed from the database
				for containerId = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
					local actorContainer = overallCombatObject:GetContainer(containerId)
					local actorTable = actorContainer:GetActorTable()
					for actorIndex = #actorTable, 1, -1 do
						---@type actor
						local actorObject = actorTable[actorIndex]

						for funcName in pairs(Details222.Mixins.ActorMixin) do
							actorObject[funcName] = nil
						end

						if (Details222.Actors.IsDisposable(actorObject) and not actorObject.owner) then
							Details222.SaveVariables.LogEvent("actor removed " .. actorObject.nome .. " (disposable)")
							Details:DestroyActor(actorObject, actorContainer, overallCombatObject)
						end
					end

					actorContainer:Cleanup()
				end
			end

			--find orphans, finding orphans should be done when deleting an actor, it should iterate among the actor pets and delete them as well
			--now deal with pets without owners (overall)
			for containerId = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
				local actorContainer = overallCombatObject:GetContainer(containerId)
				local actorTable = actorContainer:GetActorTable()
				for actorIndex = #actorTable, 1, -1 do
					---@type actor
					local actorObject = actorTable[actorIndex]
					if (actorObject.owner) then
						--does this pet owner got removed from the database?
						if (not actorObject.owner.serial) then
							Details222.SaveVariables.LogEvent("actor removed " .. actorObject.nome .. " (owner not found)")
							Details:DestroyActor(actorObject, actorContainer, overallCombatObject)
						end
					end
				end

				actorContainer:Cleanup()
			end
		end

		for i, combatObject in ipairs(segmentsTable) do
			---@cast combatObject combat
			combatTables[#combatTables+1] = combatObject
		end

		--this is a cleanup for combat stored in the segment list
		for combatIndex, combatObject in ipairs(combatTables) do
			---@cast combatObject combat

			--clear the time data (chart data) - if the option to cleanup on logout is enabled
			if (Details.clear_graphic) then
				Details:Destroy(combatObject.TimeData)
				combatObject.TimeData = {}
			end

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
							---@type actor
							local actorObject = actorTable[o]

							for funcName in pairs(Details222.Mixins.ActorMixin) do
								actorObject[funcName] = nil
							end

							if (not actorObject.owner and not actorObject.grupo and not actorObject.boss and not actorObject.boss_fight_component and not bIsBossEncounter and not actorObject.pvp_component and not actorObject.fight_component) then
								Details222.SaveVariables.LogEvent("actor removed " .. actorObject.nome .. " (ungrouped)")
								Details:DestroyActor(actorObject, actorContainer, combatObject)
							end
						end
						actorContainer:Cleanup()

						--find orphans
						for o = #actorTable, 1, -1 do
							---@type actor
							local actorObject = actorTable[o]
							if (actorObject.owner) then
								--does this pet owner got removed from the database?
								if (not actorObject.owner.serial) then
									Details222.SaveVariables.LogEvent("actor removed " .. actorObject.nome .. " (orphan)")
									Details:DestroyActor(actorObject, actorContainer, combatObject)
								end
							end
						end

						actorContainer:Cleanup()
					end
				end
			else
				if (combatObject.is_mythic_dungeon_segment) then
					for i = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
						---@type actorcontainer
						local actorContainer = combatObject:GetContainer(i)
						if (actorContainer) then
							local actorTable = actorContainer:GetActorTable()
							for o = #actorTable, 1, -1 do
								---@type actor
								local actorObject = actorTable[o]
								for funcName in pairs(Details222.Mixins.ActorMixin) do
									actorObject[funcName] = nil
								end
							end
						end
					end
				end
			end
		end

		--panic mode (in case the player disconnets during a boss encounter, drop all tables to speedup the login and login back process)
		if (Details.segments_panic_mode and Details.can_panic_mode) then
			if (Details.tabela_vigente.is_boss) then
				Details.tabela_historico = Details.historico:CreateNewSegmentDatabase()
			end
		end

		--clear all segments on logoff
		if (Details.data_cleanup_logout) then
			Details.tabela_historico = Details.historico:CreateNewSegmentDatabase()
			Details.tabela_overall = nil
			_detalhes_database.tabela_overall = nil
		end

		--clear customs
		Details.clear:c_atributo_custom()

		--clear owners
		Details:RemoveOwnerFromPets()

		--clear container indexes
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

	---start/restart the internal garbage collector runtime ~garbage
	---@param bShouldForceCollect boolean if true, the garbage collector will run regardless of the time interval
	---@param lastEvent unixtime no call is passing lastEvent at the moment
	function Details222.GarbageCollector.RestartInternalGarbageCollector(bShouldForceCollect, lastEvent)
		--print("d! debug: running garbage collector...")
		if (not bShouldForceCollect) then
			local thisTime = Details222.GarbageCollector.lastCollectTime + Details222.GarbageCollector.intervalTime
			if (thisTime > Details._tempo + 1)  then
				return

			elseif (Details.in_combat or InCombatLockdown() or Details:IsInInstance()) then
				Details.Schedules.After(5, Details222.GarbageCollector.RestartInternalGarbageCollector, false, lastEvent)
				return
			end
		else
			if (type(bShouldForceCollect) ~= "boolean") then
				if (bShouldForceCollect == 1) then
					if (Details.in_combat or InCombatLockdown()) then
						Details.Schedules.After(5, Details222.GarbageCollector.RestartInternalGarbageCollector, bShouldForceCollect, lastEvent)
						return
					end
				end
			end
		end

		if (Details.debug) then
			if (bShouldForceCollect) then
				--Details:Msg("(debug) collecting garbage with forced state:", bShouldForceCollect)
			else
				--Details:Msg("(debug) collecting garbage.")
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
			Details:InstanceCallDetailsFunc(Details.reset_window)
		end

		--cleanup backlisted pets within the handler of actor containers
		Details222.PetContainer.DoMaintenance()
		Details:ClearCCPetsBlackList()

		--cleanup spec cache
		Details:ResetSpecCache()

		--cleanup the shield cache
		Details:Destroy(Details.ShieldCache)

		--set the time of the last run
		Details222.GarbageCollector.lastCollectTime = Details._tempo

		if (Details.debug) then
			--Details:Msg("(debug) executing: collectgarbage().")
			--collectgarbage()
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
		if (combatObject.is_mythic_dungeon_run_id or combatObject.is_mythic_dungeon_segment) then
			return amountCleaned
		end

		if (combatObject.__destroyed) then
			Details:Msg("a deleted combat object was found on g2.collector, please report this bug on discord:")
			Details:Msg("combat destroyed by:", combatObject.__destroyedBy)
			return 0
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

				if (Details222.Actors.IsDisposable(actorObject) and not actorObject.owner) then
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
						canCollect = true
					end

					if (canCollect) then
						amountCleaned = amountCleaned + 1

						if (containerId == 1 or containerId == 2) then --damage or healing
							Details222.TimeMachine.RemoveActor(actorObject)
						end

						--remove the actor from the container
						Details:DestroyActor(actorObject, actorContainer, combatObject) --a window showing 'Auras & Void Zones' did not refreshed and had an actor pointing to here
					end
				end
			end

			actorContainer:Cleanup()

			if (amountCleaned > 0) then
				--destroy orphans
				local orphansCleaned = 0
				for actorIndex = #actorList, 1, -1 do
					---@type actor
					local actorObject = actorList[actorIndex]
					if (actorObject.owner and not actorObject.owner.serial) then
						Details:DestroyActor(actorObject, actorContainer, combatObject)
						orphansCleaned = orphansCleaned + 1
					end
				end

				actorContainer:Cleanup()

				--refresh the breakdown window
				if (Details.BreakdownWindowFrame:IsShown()) then
					Details222.BreakdownWindow.RefreshPlayerScroll()
				end
			end

			actorContainer.need_refresh = true
		end --end of containerId loop

		return amountCleaned
	end --end of collectGarbage function

	---run the garbage collector
	---@param overriteLastEvent unixtime
	function Details222.GarbageCollector.RunGarbageCollector(overriteLastEvent)
		---@type number
		local amountRemoved = 0

		---@type combat
		local currentCombat = Details:GetCurrentCombat()

		--create a list of all combats except the current one
		---@type table<number, combat>
		local segmentsTable = Details:GetCombatSegments()

		--collect destroyed combat objects
		local bGotSegmentsRemoved = false
		for i = #segmentsTable, 1, -1 do
			local combatObject = segmentsTable[i]
			if (combatObject ~= currentCombat) then
				if (combatObject.__destroyed) then
					table.remove(segmentsTable, i)
					bGotSegmentsRemoved = true
				end
			end
		end

		if (bGotSegmentsRemoved) then
			Details:SendEvent("DETAILS_DATA_SEGMENTREMOVED")
		end

		---@type table
		local segmentsList = {}

		--add all segments except the current one
		for _, combatObject in ipairs(segmentsTable) do
			if (combatObject ~= currentCombat) then
				segmentsList[#segmentsList+1] = combatObject
			end
		end
		--add the current segment at the end of the list
		segmentsList[#segmentsList+1] = currentCombat

		--collect the garbage
		for i, combatObject in ipairs(segmentsList) do
			if (combatObject.__destroyed) then
				Details:Msg("a deleted combat object was found by the g.collector, please report this bug on discord:")
				Details:Msg("combat destroyed by:", combatObject.__destroyedBy)
			end

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
			Details:InstanceCallDetailsFunc(Details.ScheduleUpdate)
			Details:RefreshMainWindow(-1)
		end

		return amountRemoved
	end

	---return true if the actor is disposable, in other words, if it can be removed from the combat without affecting the results
	---@param actor actor
	---@return boolean
	function Details222.Actors.IsDisposable(actor)
		if (not actor.grupo and not actor.boss and not actor.boss_fight_component and not actor.fight_component and not actor.pvp_component and not actor.arena_enemy and not actor.enemy) then
			return true
		else
			return false
		end
	end