--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _tempo = time()
	local _
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _UnitAffectingCombat = UnitAffectingCombat --wow api local
	local _UnitHealth = UnitHealth --wow api local
	local _UnitHealthMax = UnitHealthMax --wow api local
	local _UnitIsFeignDeath = UnitIsFeignDeath --wow api local
	local _UnitGUID = UnitGUID --wow api local
	local _GetUnitName = GetUnitName --wow api local
	local _GetInstanceInfo = GetInstanceInfo --wow api local
	local _IsInRaid = IsInRaid --wow api local
	local _IsInGroup = IsInGroup --wow api local
	local _GetNumGroupMembers = GetNumGroupMembers --wow api local
	local _UnitGroupRolesAssigned = UnitGroupRolesAssigned --wow api local

	local _cstr = string.format --lua local
	local _table_insert = table.insert --lua local
	local _select = select --lua local
	local _bit_band = bit.band --lua local
	local _math_floor = math.floor --lua local
	local _table_remove = table.remove --lua local
	local _ipairs = ipairs --lua local
	local _pairs = pairs --lua local
	local _table_sort = table.sort --lua local
	local _type = type --lua local
	local _math_ceil = math.ceil --lua local
	local _table_wipe = table.wipe --lua local

	local _GetSpellInfo = _detalhes.getspellinfo --details api
	local escudo = _detalhes.escudos --details local
	local parser = _detalhes.parser --details local
	local absorb_spell_list = _detalhes.AbsorbSpells --details local
	local defensive_cooldown_spell_list = _detalhes.DefensiveCooldownSpells --details local
	local defensive_cooldown_spell_list_no_buff = _detalhes.DefensiveCooldownSpellsNoBuff --details local
	local cc_spell_list = _detalhes.CrowdControlSpells --details local
	local container_combatentes = _detalhes.container_combatentes --details local
	local container_habilidades = _detalhes.container_habilidades --details local
	
	local spell_damage_func = _detalhes.habilidade_dano.Add --details local
	local spell_heal_func = _detalhes.habilidade_cura.Add --details local
	local spell_energy_func = _detalhes.habilidade_e_energy.Add --details local
	
	--> current combat and overall pointers
		local _current_combat = _detalhes.tabela_vigente or {} --> placeholder table
	--> total container pointers
		local _current_total = _current_combat.totals
		local _current_gtotal = _current_combat.totals_grupo
	--> actors container pointers
		local _current_damage_container = _current_combat [1]
		local _current_heal_container = _current_combat [2]
		local _current_energy_container = _current_combat [3]
		local _current_misc_container = _current_combat [4]

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> cache
	--> damage
		local damage_cache = setmetatable ({}, _detalhes.weaktable)
		local damage_cache_pets = setmetatable ({}, _detalhes.weaktable)
		local damage_cache_petsOwners = setmetatable ({}, _detalhes.weaktable)
	--> heaing
		local healing_cache = setmetatable ({}, _detalhes.weaktable)
	--> energy
		local energy_cache = setmetatable ({}, _detalhes.weaktable)
	--> misc
		local misc_cache = setmetatable ({}, _detalhes.weaktable)
	--> party & raid members
		local raid_members_cache = setmetatable ({}, _detalhes.weaktable)
	--> tanks
		local tanks_members_cache = setmetatable ({}, _detalhes.weaktable)
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS
	local container_misc = _detalhes.container_type.CONTAINER_MISC_CLASS
	local container_enemydebufftarget_target = _detalhes.container_type.CONTAINER_ENEMYDEBUFFTARGET_CLASS
	
	local OBJECT_TYPE_PLAYER = 0x00000400
	local OBJECT_TYPE_PETS = 0x00003000
	local AFFILIATION_GROUP = 0x00000007
	local REACTION_FRIENDLY = 0x00000010 
	
	--> recording data options shortcuts
		local _recording_self_buffs = false
		local _recording_ability_with_buffs = false
		--local _recording_took_damage = false
		local _recording_healing = false
		local _recording_buffs_and_debuffs = false
	--> in combat shortcut
		local _in_combat = false
	--> hooks
		local _hook_cooldowns = false
		local _hook_deaths = false
		local _hook_battleress = false
		local _hook_buffs = false --[[REMOVED]]
		local _hook_cooldowns_container = _detalhes.hooks ["HOOK_COOLDOWN"]
		local _hook_deaths_container = _detalhes.hooks ["HOOK_DEATH"]
		local _hook_battleress_container = _detalhes.hooks ["HOOK_BATTLERESS"]
		local _hook_buffs_container = _detalhes.hooks ["HOOK_BUFF"] --[[REMOVED]]
	


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions

-----------------------------------------------------------------------------------------------------------------------------------------
	--> DAMAGE 	serach key: ~damage											|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:swing (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing)
		return parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, 1, "Corpo-a-Corpo", 00000001, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing) --> localize-me
																		--spellid, spellname, spelltype
	end

	function parser:range (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing)
		return parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, 2, "Tiro-Automático", 00000001, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing)  --> localize-me
																		--spellid, spellname, spelltype
	end

	function parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes
	
		if (who_serial == "0x0000000000000000") then
			if (who_flags and _bit_band (who_flags, OBJECT_TYPE_PETS) ~= 0) then --> é um pet
				--> pets must have an serial
				return
			end
			who_serial = nil
		end

		if (not alvo_name) then
			--> no target name, just quit
			return
		elseif (not who_name) then
			--> no actor name, use spell name instead
			who_name = "[*] "..spellname
		end

	------------------------------------------------------------------------------------------------	
	--> check if need start an combat

		if (not _in_combat) then
			if (	token ~= "SPELL_PERIODIC_DAMAGE" and 
				( 
					(who_flags and _bit_band (who_flags, AFFILIATION_GROUP) ~= 0 and _UnitAffectingCombat (who_name) )
					or 
					(alvo_flags and _bit_band (alvo_flags, AFFILIATION_GROUP) ~= 0 and _UnitAffectingCombat (alvo_name) ) 
					or
					(not _detalhes.in_group and who_flags and _bit_band (who_flags, AFFILIATION_GROUP) ~= 0)
				)
			) then 
				--> não entra em combate se for DOT
				_detalhes:EntrarEmCombate (who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags)
			end
		end
		
		_current_damage_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors
	
		--> damager
		local este_jogador, meu_dono = damage_cache [who_name] or damage_cache_pets [who_serial], damage_cache_petsOwners [who_serial]
		
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
		
			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
			
			if (meu_dono) then --> é um pet
				damage_cache_pets [who_serial] = este_jogador
				damage_cache_petsOwners [who_serial] = meu_dono
				--conferir se o dono já esta no cache
				if (not damage_cache [meu_dono.nome]) then
					damage_cache [meu_dono.nome] = meu_dono
				end
			else
				if (who_flags) then --> ter certeza que não é um pet
					damage_cache [who_name] = este_jogador
					--> se for spell actor
					if (who_name:find ("[*]")) then
						local _, _, icon = _GetSpellInfo (spellid or 1)
						este_jogador.spellicon = icon
						--print ("spell actor:", who_name, "icon:", icon)
					end
				end
			end
			
		end
		
		--> his target
		local jogador_alvo, alvo_dono = damage_cache [alvo_name] or damage_cache_pets [alvo_serial], damage_cache_petsOwners [alvo_serial]
		
		if (not jogador_alvo) then
		
			jogador_alvo, alvo_dono, alvo_name = _current_damage_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			
			if (alvo_dono) then
				damage_cache_pets [alvo_serial] = jogador_alvo
				damage_cache_petsOwners [alvo_serial] = alvo_dono
				--conferir se o dono já esta no cache
				if (not damage_cache [alvo_dono.nome]) then
					damage_cache [alvo_dono.nome] = alvo_dono
				end
			else
				if (alvo_flags) then --> ter certeza que não é um pet
					damage_cache [alvo_name] = jogador_alvo
				end
			end
			
		end
		
		--> last event
		este_jogador.last_event = _tempo
		
	------------------------------------------------------------------------------------------------
	--> group checks and avoidance

		if (este_jogador.grupo) then 
			_current_gtotal [1] = _current_gtotal [1]+amount
			
		elseif (jogador_alvo.grupo) then
		
			--> record death log
			local t = jogador_alvo.last_events_table
			
			if (not t) then
				jogador_alvo.last_events_table = _detalhes:CreateActorLastEventTable()
				t = jogador_alvo.last_events_table
			end
			
			local i = t.n

			t.n = i + 1
			
			t = t [i]
			
			t [1] = true --> true if this is a damage || false for healing
			t [2] = spellid --> spellid || false if this is a battle ress line
			t [3] = amount --> amount of damage or healing
			t [4] = time --> parser time
			t [5] = _UnitHealth (alvo_name) --> current unit heal
			t [6] = who_name --> source name
			
			i = i + 1
			if (i == 9) then
				jogador_alvo.last_events_table.n = 1
			end
			
			--> record avoidance only for player actors
			
			if (tanks_members_cache [alvo_serial]) then --> autoshot or melee hit
				--> avoidance
				local avoidance = jogador_alvo.avoidance
				local overall = avoidance.overall
				
				local mob = avoidance [who_name]
				if (not mob) then --> if isn't in the table, build on the fly
					mob =  _detalhes:CreateActorAvoidanceTable (true)
					avoidance [who_name] = mob
				end				
				
				overall ["ALL"] = overall ["ALL"] + 1  --> qualtipo de hit ou absorb
				mob ["ALL"] = mob ["ALL"] + 1  --> qualtipo de hit ou absorb
				
				if (spellid < 3) then
					--> overall
					overall ["HITS"] = overall ["HITS"] + 1
					mob ["HITS"] = mob ["HITS"] + 1
				end
				
				--> absorbs status
				if (absorbed) then
					--> aqui pode ser apenas absorb parcial
					overall ["ABSORB"] = overall ["ABSORB"] + 1
					overall ["PARTIAL_ABSORBED"] = overall ["PARTIAL_ABSORBED"] + 1
					overall ["PARTIAL_ABSORB_AMT"] = overall ["PARTIAL_ABSORB_AMT"] + absorbed
					overall ["ABSORB_AMT"] = overall ["ABSORB_AMT"] + absorbed
					mob ["ABSORB"] = mob ["ABSORB"] + 1
					mob ["PARTIAL_ABSORBED"] = mob ["PARTIAL_ABSORBED"] + 1
					mob ["PARTIAL_ABSORB_AMT"] = mob ["PARTIAL_ABSORB_AMT"] + absorbed
					mob ["ABSORB_AMT"] = mob ["ABSORB_AMT"] + absorbed
				else
					--> adicionar aos hits sem absorbs
					overall ["FULL_HIT"] = overall ["FULL_HIT"] + 1
					overall ["FULL_HIT_AMT"] = overall ["FULL_HIT_AMT"] + amount
					mob ["FULL_HIT"] = mob ["FULL_HIT"] + 1
					mob ["FULL_HIT_AMT"] = mob ["FULL_HIT_AMT"] + amount
				end
			end
		end
		
	------------------------------------------------------------------------------------------------
	--> damage taken 

		--> target
		jogador_alvo.damage_taken = jogador_alvo.damage_taken + amount --> adiciona o dano tomado
		if (not jogador_alvo.damage_from [who_name]) then --> adiciona a pool de dano tomado de quem
			jogador_alvo.damage_from [who_name] = true
		end
		
	------------------------------------------------------------------------------------------------
	--> time start 

		if (not este_jogador.dps_started) then
		
			este_jogador:Iniciar (true)
			
			if (meu_dono and not meu_dono.dps_started) then
				meu_dono:Iniciar (true)
				if (meu_dono.end_time) then
					meu_dono.end_time = nil
				else
					meu_dono:IniciarTempo (_tempo-2.5, meu_dono.shadow)
				end
			end
			
			if (este_jogador.end_time) then
				este_jogador.end_time = nil
			else
				este_jogador:IniciarTempo (_tempo-2.5, este_jogador.shadow)
			end

			if (este_jogador.nome == _detalhes.playername and token ~= "SPELL_PERIODIC_DAMAGE") then --> iniciando o dps do "PLAYER"
				if (_detalhes.solo) then
					--> save solo attributes
					_detalhes:UpdateSolo()
				end

				if (_UnitAffectingCombat ("player")) then
					_detalhes:SendEvent ("COMBAT_PLAYER_TIMESTARTED", nil, _current_combat, este_jogador)
				end
			end
		end
		
	------------------------------------------------------------------------------------------------
	--> firendly fire

		--if (_bit_band (who_flags, REACTION_FRIENDLY) ~= 0 and _bit_band (alvo_flags, REACTION_FRIENDLY) ~= 0) then (old friendly check)
		if (raid_members_cache [who_serial] and raid_members_cache [alvo_serial]) then

			--> record death log
			local t = jogador_alvo.last_events_table
			if (not t) then
				jogador_alvo.last_events_table = _detalhes:CreateActorLastEventTable()
				t = jogador_alvo.last_events_table
			end
			
			local i = t.n

			t.n = i + 1
			
			t = t [i]
			
			t [1] = true --> true if this is a damage || false for healing
			t [2] = spellid --> spellid || false if this is a battle ress line
			t [3] = amount --> amount of damage or healing
			t [4] = time --> parser time
			t [5] = _UnitHealth (alvo_name) --> current unit heal
			t [6] = who_name --> source name
			
			i = i + 1
			if (i == 9) then
				jogador_alvo.last_events_table.n = 1
			end
		
			--> faz a adução do friendly fire
			este_jogador.friendlyfire_total = este_jogador.friendlyfire_total + amount
			
			local amigo = este_jogador.friendlyfire._NameIndexTable [alvo_name]
			if (not amigo) then
				amigo = este_jogador.friendlyfire:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			else
				amigo = este_jogador.friendlyfire._ActorTable [amigo]
			end

			amigo.total = amigo.total + amount

			local spell = amigo.spell_tables._ActorTable [spellid]
			if (not spell) then
				spell = amigo.spell_tables:PegaHabilidade (spellid, true, token)
			end

			return spell:AddFF (amount) --adiciona a classe da habilidade, a classe da habilidade se encarrega de adicionar aos alvos dela
		else
			_current_total [1] = _current_total [1]+amount
			
		end
		
	------------------------------------------------------------------------------------------------
	--> amount add

		--> actor owner (if any)
		if (meu_dono) then --> se for dano de um Pet
			meu_dono.total = meu_dono.total + amount --> e adiciona o dano ao pet
			
			--> add owner targets
			local owner_target = meu_dono.targets._NameIndexTable [alvo_name]
			if (not owner_target) then
				owner_target = meu_dono.targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true) --retorna o objeto classe_target -> ALVO_DA_HABILIDADE:NovaTabela()
			else
				owner_target = meu_dono.targets._ActorTable [owner_target]
			end
			owner_target.total = owner_target.total + amount
			
			meu_dono.last_event = _tempo
		end

		--> actor
		este_jogador.total = este_jogador.total + amount
		
		--> actor without pets
		este_jogador.total_without_pet = este_jogador.total_without_pet + amount

		--> actor targets
		local este_alvo = este_jogador.targets._NameIndexTable [alvo_name]
		if (not este_alvo) then
			este_alvo = este_jogador.targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true) --retorna o objeto classe_target -> ALVO_DA_HABILIDADE:NovaTabela()
		else
			este_alvo = este_jogador.targets._ActorTable [este_alvo]
		end
		este_alvo.total = este_alvo.total + amount

		--> actor spells table
		local spell = este_jogador.spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spell_tables:PegaHabilidade (spellid, true, token)
		end
		
		return spell_damage_func (spell, alvo_serial, alvo_name, alvo_flags, amount, who_name, resisted, blocked, absorbed, critical, glacing, token)
	end

	function parser:swingmissed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, missType, isOffHand, amountMissed)
		return parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, 1, "Corpo-a-Corpo", 00000001, missType, isOffHand, amountMissed)
	end

	function parser:rangemissed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, missType, isOffHand, amountMissed)
		return parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, 2, "Tiro-Automático", 00000001, missType, isOffHand, amountMissed)
	end

	function parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, missType, isOffHand, amountMissed)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (not who_name or not alvo_name) then
			return --> just return
		end

	------------------------------------------------------------------------------------------------
	--> get actors
		
		--> 'misser'
		local este_jogador = damage_cache [who_name]
		if (not este_jogador) then
			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (nil, who_name)
			if (not este_jogador) then
				return --> just return if actor doen't exist yet
			end
		end

		if (tanks_members_cache [alvo_serial]) then --> only track tanks
			local TargetActor = damage_cache [alvo_name]
			if (TargetActor) then
			
				local avoidance = TargetActor.avoidance
				local missTable = avoidance.overall [missType]
				
				if (missTable) then
					--> overall
					local overall = avoidance.overall
					overall [missType] = missTable + 1 --> adicionado a quantidade do miss

					--> from this mob
					local mob = avoidance [who_name]
					if (not mob) then --> if isn't in the table, build on the fly
						mob = _detalhes:CreateActorAvoidanceTable (true)
						avoidance [who_name] = mob
					end
					
					mob [missType] = mob [missType] + 1
					
					if (missType == "ABSORB") then --full absorb
						overall ["ALL"] = overall ["ALL"] + 1 --> qualtipo de hit ou absorb
						overall ["FULL_ABSORBED"] = overall ["FULL_ABSORBED"] + 1 --amount
						overall ["ABSORB_AMT"] = overall ["ABSORB_AMT"] + amountMissed
						overall ["FULL_ABSORB_AMT"] = overall ["FULL_ABSORB_AMT"] + amountMissed
						
						mob ["ALL"] = mob ["ALL"] + 1  --> qualtipo de hit ou absorb
						mob ["FULL_ABSORBED"] = mob ["FULL_ABSORBED"] + 1 --amount
						mob ["ABSORB_AMT"] = mob ["ABSORB_AMT"] + amountMissed
						mob ["FULL_ABSORB_AMT"] = mob ["FULL_ABSORB_AMT"] + amountMissed
					end
					
				end

			end
		end
		
	------------------------------------------------------------------------------------------------
	--> amount add
		
		--> actor spells table
		local spell = este_jogador.spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spell_tables:PegaHabilidade (spellid, true, token)
		end
		return spell:AddMiss (alvo_serial, alvo_name, alvo_flags, who_name, missType)
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------
	--> SUMMON 	serach key: ~summon										|
-----------------------------------------------------------------------------------------------------------------------------------------
	function parser:summon (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellName)
	
		--> pet summon another pet
		local sou_pet = _detalhes.tabela_pets.pets [who_serial]
		if (sou_pet) then --> okey, ja é um pet
			who_name, who_serial, who_flags = sou_pet[1], sou_pet[2], sou_pet[3]
		end
		
		local alvo_pet = _detalhes.tabela_pets.pets [alvo_serial]
		if (alvo_pet) then
			who_name, who_serial, who_flags = alvo_pet[1], alvo_pet[2], alvo_pet[3]
		end

		return _detalhes.tabela_pets:Adicionar (alvo_serial, alvo_name, alvo_flags, who_serial, who_name, who_flags)
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--> HEALING 	serach key: ~heal											|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overhealing, absorbed, critical, is_shield)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		--> only capture heal if is in combat
		if (not _in_combat) then
			return
		end
	
		--> check nil serial against pets
		if (who_serial == "0x0000000000000000") then
			if (who_flags and _bit_band (who_flags, OBJECT_TYPE_PETS) ~= 0) then --> é um pet
				return
			end
			who_serial = nil
		end

		--> no name, use spellname
		if (not who_name) then
			who_name = "[*] "..spellname
		end

		--> no target, just ignore
		if (not alvo_name) then
			return
		end
		
		local cura_efetiva = absorbed
		if (is_shield) then 
			--> o shield ja passa o numero exato da cura e o overheal
			cura_efetiva = amount
		else
			--cura_efetiva = absorbed + amount - overhealing
			cura_efetiva = cura_efetiva + amount - overhealing
		end
		
		_current_heal_container.need_refresh = true
	
	------------------------------------------------------------------------------------------------
	--> get actors

		local este_jogador, meu_dono = healing_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_heal_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono and who_flags) then --> se não for um pet, adicionar no cache
				healing_cache [who_name] = este_jogador
			end
		end

		local jogador_alvo, alvo_dono = healing_cache [alvo_name]
		if (not jogador_alvo) then
			jogador_alvo, alvo_dono, alvo_name = _current_heal_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			if (not alvo_dono and alvo_flags) then
				healing_cache [alvo_name] = jogador_alvo
			end
		end
		
		este_jogador.last_event = _tempo

	------------------------------------------------------------------------------------------------
	--> an enemy healing enemy or an player actor healing a enemy

		if (_bit_band (alvo_flags, REACTION_FRIENDLY) == 0 and not _detalhes.is_in_arena) then
			if (not este_jogador.heal_enemy [spellid]) then 
				este_jogador.heal_enemy [spellid] = cura_efetiva
			else
				este_jogador.heal_enemy [spellid] = este_jogador.heal_enemy [spellid] + cura_efetiva
			end
			
			este_jogador.heal_enemy_amt = este_jogador.heal_enemy_amt + cura_efetiva
			
			return
		end	
		
	------------------------------------------------------------------------------------------------
	--> group checks

		if (este_jogador.grupo) then 
			_current_combat.totals_grupo[2] = _current_combat.totals_grupo[2] + cura_efetiva
		end
		
		if (jogador_alvo.grupo) then
		
			local t = jogador_alvo.last_events_table
			if (not t) then
				jogador_alvo.last_events_table = _detalhes:CreateActorLastEventTable()
				t = jogador_alvo.last_events_table
			end
			
			local i = t.n
			t.n = i + 1

			t = t [i]
			
			t [1] = false --> true if this is a damage || false for healing
			t [2] = spellid --> spellid || false if this is a battle ress line
			t [3] = amount --> amount of damage or healing
			t [4] = time --> parser time
			t [5] = _UnitHealth (alvo_name) --> current unit heal
			t [6] = who_name --> source name
			
			i = i + 1
			if (i == 9) then
				jogador_alvo.last_events_table.n = 1
			end
		end

	------------------------------------------------------------------------------------------------
	--> timer
		
		if (not este_jogador.iniciar_hps) then
			este_jogador:Iniciar (true) --inicia o dps do jogador
			if (este_jogador.end_time) then --> o combate terminou, reabrir o tempo
				este_jogador.end_time = nil
				este_jogador.shadow.end_time = nil --> não tenho certeza se isso aqui não pode dar merda
			else
				este_jogador:IniciarTempo (_tempo-3.0, este_jogador.shadow)
			end
		end

	------------------------------------------------------------------------------------------------
	--> add amount
		
		--> actor target
		local este_alvo = este_jogador.targets._NameIndexTable [alvo_name]
		if (not este_alvo) then
			este_alvo = este_jogador.targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
		else
			este_alvo = este_jogador.targets._ActorTable [este_alvo]
		end
		
		if (cura_efetiva > 0) then
		
			--> combat total
			_current_total [2] = _current_total [2] + cura_efetiva
		
			--> healing taken 
			jogador_alvo.healing_taken = jogador_alvo.healing_taken + cura_efetiva --> adiciona o dano tomado
			if (not jogador_alvo.healing_from [who_name]) then --> adiciona a pool de dano tomado de quem
				jogador_alvo.healing_from [who_name] = true
			end
			
			--> actor healing amount
			este_jogador.total = este_jogador.total + cura_efetiva
			
			if (is_shield) then
				este_jogador.totalabsorb = este_jogador.totalabsorb + cura_efetiva
			end

			este_jogador.total_without_pet = este_jogador.total_without_pet + cura_efetiva
			
			--> pet
			if (meu_dono) then
				meu_dono.total = meu_dono.total + cura_efetiva --> heal do pet
				
				local owner_target = meu_dono.targets._NameIndexTable [alvo_name]
				if (not owner_target) then
					owner_target = meu_dono.targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true) --retorna o objeto classe_target -> ALVO_DA_HABILIDADE:NovaTabela()
				else
					owner_target = meu_dono.targets._ActorTable [owner_target]
				end
				owner_target.total = owner_target.total + amount
			end
			
			--> target amount
			este_alvo.total = este_alvo.total + cura_efetiva
		end
		
		if (overhealing > 0) then
			este_jogador.totalover = este_jogador.totalover + overhealing
			este_alvo.overheal = este_alvo.overheal + overhealing
			if (meu_dono) then
				meu_dono.totalover = meu_dono.totalover + overhealing
			end
		end

		--> actor spells table
		local spell = este_jogador.spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spell_tables:PegaHabilidade (spellid, true, token)
		end
		
		if (is_shield) then
			--return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, 0, 		  nil, 	     overhealing, true)
			return spell_heal_func (spell, alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, 0, 		  nil, 	     overhealing, true)
		else
			--return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing)
			return spell_heal_func (spell, alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing)
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--> BUFFS & DEBUFFS 	serach key: ~buff ~aura ~shield								|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:buff (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)

	--> not yet well know about unnamed buff casters
		if (not alvo_name) then
			alvo_name = "[*] Unknow shield target"
		elseif (not who_name) then 
			who_name = "[*] Unknow shield caster"
		end 

	------------------------------------------------------------------------------------------------
	--> handle shields

		if (tipo == "BUFF") then
			------------------------------------------------------------------------------------------------
			--> buff uptime
				if (_recording_buffs_and_debuffs) then
					-- jade spirit doesn't send who_name, that's a shame. 
					if (who_name == alvo_name and raid_members_cache [who_serial] and _in_combat) then
						--> call record buffs uptime
	--[[not tail call, need to fix this]]	parser:add_buff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "BUFF_UPTIME_IN")
					end
				end
		
			------------------------------------------------------------------------------------------------
			--> healing done absorbs
				if (absorb_spell_list [spellid] and _recording_healing and amount) then
					if (not escudo [alvo_name]) then 
						escudo [alvo_name] = {}
						escudo [alvo_name] [spellid] = {}
						escudo [alvo_name] [spellid] [who_name] = amount
					elseif (not escudo [alvo_name] [spellid]) then 
						escudo [alvo_name] [spellid] = {}
						escudo [alvo_name] [spellid] [who_name] = amount
					else
						escudo [alvo_name] [spellid] [who_name] = amount
					end
			
			------------------------------------------------------------------------------------------------
			--> defensive cooldowns
				elseif (defensive_cooldown_spell_list [spellid]) then
					--> usou cooldown
					return parser:add_defensive_cooldown (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
				
			------------------------------------------------------------------------------------------------
			--> recording buffs
				elseif (_recording_self_buffs) then
					--> or alvo_name needded, seems jade spirit not send who_name correctly
					if (who_name == _detalhes.playername or alvo_name == _detalhes.playername) then
						local bufftable = _detalhes.Buffs.BuffsTable [spellname]
						if (bufftable) then
							return bufftable:UpdateBuff ("new")
						else
							return false
						end
					end

			end

	------------------------------------------------------------------------------------------------
	--> recording debuffs applied by player

		elseif (tipo == "DEBUFF") then
			
			if (_in_combat) then
			
			------------------------------------------------------------------------------------------------
			--> buff uptime
				if (_recording_buffs_and_debuffs) then
					if (raid_members_cache [who_serial]) then
						--> call record debuffs uptime
	--[[not tail call, need to fix this]]	parser:add_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "DEBUFF_UPTIME_IN")
	
					elseif (raid_members_cache [alvo_serial] and not raid_members_cache [who_serial]) then --> alvo é da raide é alguem de fora da raide
	--[[not tail call, need to fix this]]	parser:add_bad_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, "DEBUFF_UPTIME_IN")
					end
				end
			
				if (_recording_ability_with_buffs) then
					if (who_name == _detalhes.playername) then

						--> record debuff uptime
						local SoloDebuffUptime = _current_combat.SoloDebuffUptime
						if (not SoloDebuffUptime) then
							SoloDebuffUptime = {}
							_current_combat.SoloDebuffUptime = SoloDebuffUptime
						end
						
						local ThisDebuff = SoloDebuffUptime [spellid]
						
						if (not ThisDebuff) then
							ThisDebuff = {name = spellname, duration = 0, start = _tempo, castedAmt = 1, refreshAmt = 0, droppedAmt = 0, Active = true}
							SoloDebuffUptime [spellid] = ThisDebuff
						else
							ThisDebuff.castedAmt = ThisDebuff.castedAmt + 1
							ThisDebuff.start = _tempo
							ThisDebuff.Active = true
						end
						
						--> record debuff spell and attack power
						local SoloDebuffPower = _current_combat.SoloDebuffPower
						if (not SoloDebuffPower) then
							SoloDebuffPower = {}
							_current_combat.SoloDebuffPower = SoloDebuffPower
						end
						
						local ThisDebuff = SoloDebuffPower [spellid]
						if (not ThisDebuff) then
							ThisDebuff = {}
							SoloDebuffPower [spellid] = ThisDebuff
						end
					
						local ThisDebuffOnTarget = ThisDebuff [alvo_serial]
						
						local base, posBuff, negBuff = UnitAttackPower ("player")
						local AttackPower = base+posBuff+negBuff
						local base, posBuff, negBuff = UnitRangedAttackPower ("player")
						local RangedAttackPower = base+posBuff+negBuff
						local SpellPower = GetSpellBonusDamage (3)
						
						--> record buffs active on player when the debuff was applied
						local BuffsOn = {}
						for BuffName, BuffTable in _pairs (_detalhes.Buffs.BuffsTable) do
							if (BuffTable.active) then
								BuffsOn [#BuffsOn+1] = BuffName
							end
						end
						
						if (not ThisDebuffOnTarget) then --> apply
							ThisDebuff [alvo_serial] = {power = math.max (AttackPower, RangedAttackPower, SpellPower), onTarget = true, buffs = BuffsOn}
						else --> re applying
							ThisDebuff [alvo_serial].power = math.max (AttackPower, RangedAttackPower, SpellPower)
							ThisDebuff [alvo_serial].buffs = BuffsOn
							ThisDebuff [alvo_serial].onTarget = true
						end
						
						--> send event for plugins
						_detalhes:SendEvent ("BUFF_UPDATE_DEBUFFPOWER")
						
					end
				end
			end
		end
	end

	function parser:buff_refresh (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)

	------------------------------------------------------------------------------------------------
	--> handle shields

		if (tipo == "BUFF") then
		
			------------------------------------------------------------------------------------------------
			--> buff uptime
				if (_recording_buffs_and_debuffs) then
					if (who_name == alvo_name and raid_members_cache [who_serial] and _in_combat) then
						--> call record buffs uptime
	--[[not tail call, need to fix this]]	parser:add_buff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "BUFF_UPTIME_REFRESH")
					end
				end
		
			------------------------------------------------------------------------------------------------
			--> healing done (shields)
				if (absorb_spell_list [spellid] and _recording_healing and amount) then
					
					if (escudo [alvo_name] and escudo [alvo_name][spellid] and escudo [alvo_name][spellid][who_name]) then
					
						local absorb = escudo [alvo_name][spellid][who_name] - amount
						local overheal = amount - absorb
						escudo [alvo_name][spellid][who_name] = amount
						
						--if (absorb > 0) then
							return parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, nil, _math_ceil (absorb), _math_ceil (overheal), 0, 0, true)
						--end
					else
						--> should apply aura if not found in already applied buff list?
					end

			------------------------------------------------------------------------------------------------
			--> defensive cooldowns
				elseif (defensive_cooldown_spell_list [spellid]) then
					--> usou cooldown
					return parser:add_defensive_cooldown (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
					
			------------------------------------------------------------------------------------------------
			--> recording buffs

				elseif (_recording_self_buffs) then
					if (who_name == _detalhes.playername or alvo_name == _detalhes.playername) then --> foi colocado pelo player
					
						local bufftable = _detalhes.Buffs.BuffsTable [spellname]
						if (bufftable) then
							return bufftable:UpdateBuff ("refresh")
						else
							return false
						end
					end
				end

	------------------------------------------------------------------------------------------------
	--> recording debuffs applied by player

		elseif (tipo == "DEBUFF") then
		
			if (_in_combat) then
			------------------------------------------------------------------------------------------------
			--> buff uptime
				if (_recording_buffs_and_debuffs) then
					if (raid_members_cache [who_serial]) then
						--> call record debuffs uptime
	--[[not tail call, need to fix this]]	parser:add_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "DEBUFF_UPTIME_REFRESH")
					elseif (raid_members_cache [alvo_serial] and not raid_members_cache [who_serial]) then --> alvo é da raide e o caster é inimigo
	--[[not tail call, need to fix this]]	parser:add_bad_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, "DEBUFF_UPTIME_REFRESH")
					end
				end
		
				if (_recording_ability_with_buffs) then
					if (who_name == _detalhes.playername) then
					
						--> record debuff uptime
						local SoloDebuffUptime = _current_combat.SoloDebuffUptime
						if (SoloDebuffUptime) then
							local ThisDebuff = SoloDebuffUptime [spellid]
							if (ThisDebuff and ThisDebuff.Active) then
								ThisDebuff.refreshAmt = ThisDebuff.refreshAmt + 1
								ThisDebuff.duration = ThisDebuff.duration + (_tempo - ThisDebuff.start)
								ThisDebuff.start = _tempo
								
								--> send event for plugins
								_detalhes:SendEvent ("BUFF_UPDATE_DEBUFFPOWER")
							end
						end
						
						--> record debuff spell and attack power
						local SoloDebuffPower = _current_combat.SoloDebuffPower
						if (SoloDebuffPower) then
							local ThisDebuff = SoloDebuffPower [spellid]
							if (ThisDebuff) then
								local ThisDebuffOnTarget = ThisDebuff [alvo_serial]
								if (ThisDebuffOnTarget) then
									local base, posBuff, negBuff = UnitAttackPower ("player")
									local AttackPower = base+posBuff+negBuff
									local base, posBuff, negBuff = UnitRangedAttackPower ("player")
									local RangedAttackPower = base+posBuff+negBuff
									local SpellPower = GetSpellBonusDamage (3)
									
									local BuffsOn = {}
									for BuffName, BuffTable in _pairs (_detalhes.Buffs.BuffsTable) do
										if (BuffTable.active) then
											BuffsOn [#BuffsOn+1] = BuffName
										end
									end
									
									ThisDebuff [alvo_serial].power = math.max (AttackPower, RangedAttackPower, SpellPower)
									ThisDebuff [alvo_serial].buffs = BuffsOn
									
									--> send event for plugins
									_detalhes:SendEvent ("BUFF_UPDATE_DEBUFFPOWER")
								end
							end
						end
						
					end
				end
			end
		end
	end

	function parser:unbuff (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)

	------------------------------------------------------------------------------------------------
	--> handle shields

		if (tipo == "BUFF") then
		
			------------------------------------------------------------------------------------------------
			--> buff uptime
				if (_recording_buffs_and_debuffs) then
					if (who_name == alvo_name and raid_members_cache [who_serial] and _in_combat) then
						--> call record buffs uptime
	--[[not tail call, need to fix this]]	parser:add_buff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "BUFF_UPTIME_OUT")
					end
				end
		
			------------------------------------------------------------------------------------------------
			--> healing done (shields)
				if (absorb_spell_list [spellid] and _recording_healing) then
					if (escudo [alvo_name] and escudo [alvo_name][spellid] and escudo [alvo_name][spellid][who_name]) then
						if (amount) then
							-- o amount é o que sobrou do escudo
							local escudo_antigo = escudo [alvo_name][spellid][who_name] --> quantidade total do escudo que foi colocado
							
							local absorb = escudo_antigo - amount
							local overheal = escudo_antigo - absorb
							
							escudo [alvo_name][spellid][who_name] = nil
							
							return parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, nil, _math_ceil (absorb), _math_ceil (overheal), 0, 0, true) --> último parametro IS_SHIELD
						end
						escudo [alvo_name][spellid][who_name] = nil
					end
				--end
				
			------------------------------------------------------------------------------------------------
			--> recording buffs
				elseif (_recording_self_buffs) then
					if (who_name == _detalhes.playername or alvo_name == _detalhes.playername) then --> foi colocado pelo player
					
						local bufftable = _detalhes.Buffs.BuffsTable [spellname]
						if (bufftable) then
							return bufftable:UpdateBuff ("remove")
						else
							return false
						end			
					end			
				end

	------------------------------------------------------------------------------------------------
	--> recording debuffs applied by player
		elseif (tipo == "DEBUFF") then
		
			if (_in_combat) then
			------------------------------------------------------------------------------------------------
			--> buff uptime
				if (_recording_buffs_and_debuffs) then
					if (raid_members_cache [who_serial]) then
						--> call record debuffs uptime
	--[[not tail call, need to fix this]]	parser:add_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "DEBUFF_UPTIME_OUT")
					elseif (raid_members_cache [alvo_serial] and not raid_members_cache [who_serial]) then --> alvo é da raide e o caster é inimigo
	--[[not tail call, need to fix this]]	parser:add_bad_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, "DEBUFF_UPTIME_OUT")
					end
				end
			
				if (_recording_ability_with_buffs) then
			
					if (who_name == _detalhes.playername) then
					
						--> record debuff uptime
						local SoloDebuffUptime = _current_combat.SoloDebuffUptime
						local sendevent = false
						if (SoloDebuffUptime) then
							local ThisDebuff = SoloDebuffUptime [spellid]
							if (ThisDebuff and ThisDebuff.Active) then
								ThisDebuff.duration = ThisDebuff.duration + (_tempo - ThisDebuff.start)
								ThisDebuff.droppedAmt = ThisDebuff.droppedAmt + 1
								ThisDebuff.start = nil
								ThisDebuff.Active = false
								sendevent = true
							end
						end
						
						--> record debuff spell and attack power
						local SoloDebuffPower = _current_combat.SoloDebuffPower
						if (SoloDebuffPower) then
							local ThisDebuff = SoloDebuffPower [spellid]
							if (ThisDebuff) then
								ThisDebuff [alvo_serial] = nil
								sendevent = true
							end
						end
						
						if (sendevent) then
							_detalhes:SendEvent ("BUFF_UPDATE_DEBUFFPOWER")
						end
					end
				end
			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--> MISC 	search key: ~buffuptime ~buffsuptime									|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:add_bad_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, in_out)
		
		if (not alvo_name) then
			--> no target name, just quit
			return
		elseif (not who_name) then
			--> no actor name, use spell name instead
			who_name = "[*] "..spellname
		end
		
		------------------------------------------------------------------------------------------------
		--> get actors
			--> nome do debuff será usado para armazenar o nome do ator
			local este_jogador = misc_cache [spellname]
			if (not este_jogador) then --> pode ser um desconhecido ou um pet
				este_jogador = _current_misc_container:PegarCombatente (who_serial, spellname, who_flags, true)
				misc_cache [spellname] = este_jogador
			end
		
		------------------------------------------------------------------------------------------------
		--> build containers on the fly
			
			if (not este_jogador.debuff_uptime) then
				este_jogador.boss_debuff = true
				este_jogador.damage_twin = who_name
				este_jogador.spellschool = spellschool
				este_jogador.damage_spellid = spellid
				este_jogador.debuff_uptime = 0
				este_jogador.debuff_uptime_spell_tables = container_habilidades:NovoContainer (container_misc)
				este_jogador.debuff_uptime_targets = container_combatentes:NovoContainer (container_enemydebufftarget_target)
				
				if (not este_jogador.shadow.debuff_uptime_targets) then
					este_jogador.shadow.boss_debuff = true
					este_jogador.shadow.damage_twin = who_name
					este_jogador.shadow.spellschool = spellschool
					este_jogador.shadow.damage_spellid = spellid
					este_jogador.shadow.debuff_uptime = 0
					este_jogador.shadow.debuff_uptime_spell_tables = container_habilidades:NovoContainer (container_misc)
					este_jogador.shadow.debuff_uptime_targets = container_combatentes:NovoContainer (container_enemydebufftarget_target)
				end
				
				este_jogador.debuff_uptime_targets.shadow = este_jogador.shadow.debuff_uptime_targets
				este_jogador.debuff_uptime_spell_tables.shadow = este_jogador.shadow.debuff_uptime_spell_tables
				
			end
		
		------------------------------------------------------------------------------------------------
		--> add amount
			
			--> update last event
			este_jogador.last_event = _tempo
			
			--> actor target
			local este_alvo = este_jogador.debuff_uptime_targets._NameIndexTable [alvo_name]
			if (not este_alvo) then
				este_alvo = este_jogador.debuff_uptime_targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			else
				este_alvo = este_jogador.debuff_uptime_targets._ActorTable [este_alvo]
			end
			
			if (in_out == "DEBUFF_UPTIME_IN") then
				este_alvo.actived = true
				este_alvo.activedamt = este_alvo.activedamt + 1
				if (este_alvo.actived_at and este_alvo.actived) then
					este_alvo.uptime = este_alvo.uptime + _tempo - este_alvo.actived_at
					este_jogador.debuff_uptime = este_jogador.debuff_uptime + _tempo - este_alvo.actived_at
				end
				este_alvo.actived_at = _tempo
				
			elseif (in_out == "DEBUFF_UPTIME_REFRESH") then
				if (este_alvo.actived_at and este_alvo.actived) then
					este_alvo.uptime = este_alvo.uptime + _tempo - este_alvo.actived_at
					este_jogador.debuff_uptime = este_jogador.debuff_uptime + _tempo - este_alvo.actived_at
				end
				este_alvo.actived_at = _tempo
				este_alvo.actived = true
				
			elseif (in_out == "DEBUFF_UPTIME_OUT") then
				if (este_alvo.actived_at and este_alvo.actived) then
					este_alvo.uptime = este_alvo.uptime + _detalhes._tempo - este_alvo.actived_at
					este_jogador.debuff_uptime = este_jogador.debuff_uptime + _tempo - este_alvo.actived_at --> token = actor misc object
				end
				
				este_alvo.activedamt = este_alvo.activedamt - 1
				
				if (este_alvo.activedamt == 0) then
					este_alvo.actived = false
					este_alvo.actived_at = nil
				else
					este_alvo.actived_at = _tempo
				end
			end
	end

	function parser:add_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, in_out)
	------------------------------------------------------------------------------------------------
	--> early checks and fixes
		
		_current_misc_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors
		local este_jogador = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			misc_cache [who_name] = este_jogador
		end
		
	------------------------------------------------------------------------------------------------
	--> build containers on the fly
		
		if (not este_jogador.debuff_uptime) then
			este_jogador.debuff_uptime = 0
			este_jogador.debuff_uptime_spell_tables = container_habilidades:NovoContainer (container_misc)
			este_jogador.debuff_uptime_targets = container_combatentes:NovoContainer (container_damage_target)
			
			if (not este_jogador.shadow.debuff_uptime_targets) then
				este_jogador.shadow.debuff_uptime = 0
				este_jogador.shadow.debuff_uptime_spell_tables = container_habilidades:NovoContainer (container_misc)
				este_jogador.shadow.debuff_uptime_targets = container_combatentes:NovoContainer (container_damage_target)
			end
			
			este_jogador.debuff_uptime_targets.shadow = este_jogador.shadow.debuff_uptime_targets
			este_jogador.debuff_uptime_spell_tables.shadow = este_jogador.shadow.debuff_uptime_spell_tables
		end
	
	------------------------------------------------------------------------------------------------
	--> add amount
		
		--> update last event
		este_jogador.last_event = _tempo

		--> actor spells table
		local spell = este_jogador.debuff_uptime_spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.debuff_uptime_spell_tables:PegaHabilidade (spellid, true, "DEBUFF_UPTIME")
		end
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, este_jogador, "BUFF_OR_DEBUFF", in_out)
		
	end

	function parser:add_buff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, in_out)
	
	------------------------------------------------------------------------------------------------
	--> early checks and fixes
		
		_current_misc_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors
		local este_jogador = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			misc_cache [who_name] = este_jogador
		end
		
	------------------------------------------------------------------------------------------------
	--> build containers on the fly
		
		if (not este_jogador.buff_uptime) then
			este_jogador.buff_uptime = 0
			este_jogador.buff_uptime_spell_tables = container_habilidades:NovoContainer (container_misc)
			este_jogador.buff_uptime_targets = container_combatentes:NovoContainer (container_damage_target)
			
			if (not este_jogador.shadow.buff_uptime_targets) then
				este_jogador.shadow.buff_uptime = 0
				este_jogador.shadow.buff_uptime_spell_tables = container_habilidades:NovoContainer (container_misc)
				este_jogador.shadow.buff_uptime_targets = container_combatentes:NovoContainer (container_damage_target)
			end
			
			este_jogador.buff_uptime_targets.shadow = este_jogador.shadow.buff_uptime_targets
			este_jogador.buff_uptime_spell_tables.shadow = este_jogador.shadow.buff_uptime_spell_tables
		end	

	------------------------------------------------------------------------------------------------
	--> hook
	
		if (_hook_buffs) then
			--> send event to registred functions
			for _, func in _ipairs (_hook_buffs_container) do 
				func (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, in_out)
			end
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount
		
		--> update last event
		este_jogador.last_event = _tempo

		--> actor spells table
		local spell = este_jogador.buff_uptime_spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.buff_uptime_spell_tables:PegaHabilidade (spellid, true, "BUFF_UPTIME")
		end
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, este_jogador, "BUFF_OR_DEBUFF", in_out)
		
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--> ENERGY	serach key: ~energy												|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:energize (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, powertype, p6, p7)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (not who_name) then
			who_name = "[*] "..spellname
		elseif (not alvo_name) then
			return
		end

	------------------------------------------------------------------------------------------------
	--> get regen key name
		
		local key_regenDone
		local key_regenFrom 
		local key_regenType
		
		if (powertype == 0) then --> MANA
			key_regenDone = "mana_r"
			key_regenFrom = "mana_from"
			key_regenType = "mana"
		elseif (powertype == 1) then --> RAGE
			key_regenDone = "e_rage_r"
			key_regenFrom = "e_rage_from"
			key_regenType = "e_rage"
		elseif (powertype == 3) then --> ENERGY
			key_regenDone = "e_energy_r"
			key_regenFrom = "e_energy_from"
			key_regenType = "e_energy"
		elseif (powertype == 6) then --> RUNEPOWER
			key_regenDone = "runepower_r"
			key_regenFrom = "runepower_from"
			key_regenType = "runepower"
		else
			--> not tracking this regen type
			return
		end
		
		_current_energy_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors

		--> main actor
		local este_jogador, meu_dono = energy_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_energy_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				energy_cache [who_name] = este_jogador
			end
		end
		
		--> target
		local jogador_alvo, alvo_dono = energy_cache [alvo_name]
		if (not jogador_alvo) then
			jogador_alvo, alvo_dono, alvo_name = _current_energy_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			if (not alvo_dono) then
				energy_cache [alvo_name] = jogador_alvo
			end
		end
		
		--> actor targets
		local este_alvo = este_jogador.targets._NameIndexTable [alvo_name]
		if (not este_alvo) then
			este_alvo = este_jogador.targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true) --retorna o objeto classe_target -> ALVO_DA_HABILIDADE:NovaTabela()
		else
			este_alvo = este_jogador.targets._ActorTable [este_alvo]
		end
		
		este_jogador.last_event = _tempo

	------------------------------------------------------------------------------------------------
	--> amount add
		
		--> combat total
		_current_total [3] [key_regenType] = _current_total [3] [key_regenType] + amount
		
		if (este_jogador.grupo) then 
			_current_gtotal [3] [key_regenType] = _current_gtotal [3] [key_regenType] + amount
		end

		--> regen produced amount
		este_jogador [key_regenType] = este_jogador [key_regenType] + amount
		este_alvo [key_regenType] = este_alvo [key_regenType] + amount
		
		--> target regenerated amount
		jogador_alvo [key_regenDone] = jogador_alvo [key_regenDone] + amount
		
		--> regen from
		if (not jogador_alvo [key_regenFrom] [who_name]) then
			jogador_alvo [key_regenFrom] [who_name] = true
		end
		
		--> owner
		if (meu_dono) then
			meu_dono [key_regenType] = meu_dono [key_regenType] + amount --> e adiciona o dano ao pet
		end

		--> actor spells table
		local spell = este_jogador.spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spell_tables:PegaHabilidade (spellid, true, token)
		end
		
		--return spell:Add (alvo_serial, alvo_name, alvo_flags, amount, who_name, powertype)
		return spell_energy_func (spell, alvo_serial, alvo_name, alvo_flags, amount, who_name, powertype)
	end


	
-----------------------------------------------------------------------------------------------------------------------------------------
	--> MISC 	search key: ~cooldown											|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:add_defensive_cooldown (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
	
	------------------------------------------------------------------------------------------------
	--> early checks and fixes
		
		_current_misc_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors
	
		--> main actor
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end
		
	------------------------------------------------------------------------------------------------
	--> build containers on the fly

		if (not este_jogador.cooldowns_defensive) then
			este_jogador.cooldowns_defensive = _detalhes:GetAlphabeticalOrderNumber (who_name)
			este_jogador.cooldowns_defensive_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
			este_jogador.cooldowns_defensive_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades
			
			if (not este_jogador.shadow.cooldowns_defensive_targets) then
				este_jogador.shadow.cooldowns_defensive = _detalhes:GetAlphabeticalOrderNumber (who_name)
				este_jogador.shadow.cooldowns_defensive_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
				este_jogador.shadow.cooldowns_defensive_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas
			end

			este_jogador.cooldowns_defensive_targets.shadow = este_jogador.shadow.cooldowns_defensive_targets
			este_jogador.cooldowns_defensive_spell_tables.shadow = este_jogador.shadow.cooldowns_defensive_spell_tables
		end	
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> actor cooldowns used
		este_jogador.cooldowns_defensive = este_jogador.cooldowns_defensive + 1

		--> combat totals
		_current_total [4].cooldowns_defensive = _current_total [4].cooldowns_defensive + 1
		
		if (este_jogador.grupo) then
			_current_gtotal [4].cooldowns_defensive = _current_gtotal [4].cooldowns_defensive + 1
			
			if (who_name == alvo_name) then
			
				local damage_actor = damage_cache [who_name]
				if (not damage_actor) then --> pode ser um desconhecido ou um pet
					damage_actor = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
					if (who_flags) then --> se não for um pet, adicionar no cache
						damage_cache [who_name] = damage_actor
					end
				end

				local t = damage_actor.last_events_table
				
				if (not t) then
					damage_actor.last_events_table = _detalhes:CreateActorLastEventTable()
					t = damage_actor.last_events_table
				end
			
				local i = t.n
				t.n = i + 1

				t = t [i]
				
				t [1] = 1 --> true if this is a damage || false for healing || 1 for cooldown
				t [2] = spellid --> spellid || false if this is a battle ress line
				t [3] = 1 --> amount of damage or healing
				t [4] = time --> parser time
				t [5] = _UnitHealth (who_name) --> current unit heal
				t [6] = who_name --> source name
				
				i = i + 1
				if (i == 9) then
					damage_actor.last_events_table.n = 1
				end
				
				este_jogador.last_cooldown = {time, spellid}
				
			end
			
		end
		
		--> update last event
		este_jogador.last_event = _tempo
		
		--> actor targets
		local este_alvo = este_jogador.cooldowns_defensive_targets._NameIndexTable [alvo_name]
		if (not este_alvo) then
			este_alvo = este_jogador.cooldowns_defensive_targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
		else
			este_alvo = este_jogador.cooldowns_defensive_targets._ActorTable [este_alvo]
		end
		este_alvo.total = este_alvo.total + 1

		--> actor spells table
		local spell = este_jogador.cooldowns_defensive_spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.cooldowns_defensive_spell_tables:PegaHabilidade (spellid, true, token)
		end
		
		if (_hook_cooldowns) then
			--> send event to registred functions
			for _, func in _ipairs (_hook_cooldowns_container) do 
				func (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
			end
		end
		
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token, "BUFF_OR_DEBUFF", "COOLDOWN")
		
	end

	
	--serach key: ~interrupt
	function parser:interrupt (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (not who_name) then
			who_name = "[*] "..spellname
		elseif (not alvo_name) then
			return
		end
		
		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--> get actors

		--> main actor
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end
		
	------------------------------------------------------------------------------------------------
	--> build containers on the fly
		
		if (not este_jogador.interrupt) then
			este_jogador.interrupt = 0
			este_jogador.interrupt_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
			este_jogador.interrupt_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
			este_jogador.interrompeu_oque = {}
			
			if (not este_jogador.shadow.interrupt_targets) then
				este_jogador.shadow.interrupt = 0
				este_jogador.shadow.interrupt_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
				este_jogador.shadow.interrupt_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
				este_jogador.shadow.interrompeu_oque = {}
			end

			este_jogador.interrupt_targets.shadow = este_jogador.shadow.interrupt_targets
			este_jogador.interrupt_spell_tables.shadow = este_jogador.shadow.interrupt_spell_tables
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> actor interrupt amount
		este_jogador.interrupt = este_jogador.interrupt + 1

		--> combat totals
		_current_total [4].interrupt = _current_total [4].interrupt + 1
		
		if (este_jogador.grupo) then
			_current_gtotal [4].interrupt = _current_gtotal [4].interrupt + 1
		end

		--> update last event
		este_jogador.last_event = _tempo
		--shadow.last_event = _tempo
		
		--> spells interrupted
		if (not este_jogador.interrompeu_oque [extraSpellID]) then
			este_jogador.interrompeu_oque [extraSpellID] = 1
		else
			este_jogador.interrompeu_oque [extraSpellID] = este_jogador.interrompeu_oque [extraSpellID] + 1
		end
		
		--> actor targets
		local este_alvo = este_jogador.interrupt_targets._NameIndexTable [alvo_name]
		if (not este_alvo) then
			este_alvo = este_jogador.interrupt_targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
		else
			este_alvo = este_jogador.interrupt_targets._ActorTable [este_alvo]
		end
		este_alvo.total = este_alvo.total + 1

		--> actor spells table
		local spell = este_jogador.interrupt_spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.interrupt_spell_tables:PegaHabilidade (spellid, true, token)
		end
		spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
		
		--> verifica se tem dono e adiciona o interrupt para o dono
		if (meu_dono) then
			
			if (not meu_dono.interrupt) then
				meu_dono.interrupt = 0
				meu_dono.interrupt_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
				meu_dono.interrupt_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
				meu_dono.interrompeu_oque = {}
				
				if (not meu_dono.shadow.interrupt_targets) then
					meu_dono.shadow.interrupt = 0
					meu_dono.shadow.interrupt_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
					meu_dono.shadow.interrupt_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
					meu_dono.shadow.interrompeu_oque = {}
				end

				meu_dono.interrupt_targets.shadow = meu_dono.shadow.interrupt_targets
				meu_dono.interrupt_spell_tables.shadow = meu_dono.shadow.interrupt_spell_tables
			end
			
			-- adiciona ao total
			meu_dono.interrupt = meu_dono.interrupt + 1
			
			-- adiciona aos alvos
			local este_alvo = meu_dono.interrupt_targets._NameIndexTable [alvo_name]
			if (not este_alvo) then
				este_alvo = meu_dono.interrupt_targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			else
				este_alvo = meu_dono.interrupt_targets._ActorTable [este_alvo]
			end
			este_alvo.total = este_alvo.total + 1
			
			-- update last event
			meu_dono.last_event = _tempo
			
			-- spells interrupted
			if (not meu_dono.interrompeu_oque [extraSpellID]) then
				meu_dono.interrompeu_oque [extraSpellID] = 1
			else
				meu_dono.interrompeu_oque [extraSpellID] = meu_dono.interrompeu_oque [extraSpellID] + 1
			end
		end

	end
	
	--> search key: ~spellcast ~castspell ~cast
	function parser:spellcast (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype)
	
		--print (token, time, "WHO:",who_serial, who_name, who_flags, "TARGET:",alvo_serial, alvo_name, alvo_flags, "SPELL:",spellid, spellname, spelltype)

	------------------------------------------------------------------------------------------------
	--> record cooldowns cast which can't track with buff applyed.
	
		--> foi um jogador que castou
		if (raid_members_cache [who_serial]) then
			--> check if is a cooldown :D
			if (defensive_cooldown_spell_list_no_buff [spellid]) then
				--> usou cooldown
				if (not alvo_name) then
					if (defensive_cooldown_spell_list_no_buff [spellid][3] == 1) then
						alvo_name = who_name
					else
						alvo_name = Loc ["STRING_RAID_WIDE"]
					end
				end
				return parser:add_defensive_cooldown (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
			else
				return
			end
		else
			--> successful casts (not interrupted)
			if (_bit_band (who_flags, 0x00000040) ~= 0 and who_name) then --> byte 2 = 4 (enemy)
				--> damager
				local este_jogador = damage_cache [who_name]
				if (not este_jogador) then
					este_jogador = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
				end
				--> actor spells table
				local spell = este_jogador.spell_tables._ActorTable [spellid]
				if (not spell) then
					spell = este_jogador.spell_tables:PegaHabilidade (spellid, true, token)
				end
				spell.successful_casted = spell.successful_casted + 1
				--print ("cast success", who_name, spellname)
			end
			return
		end
		
		
	-- para aqui --
	------------------------------------------------------------------------------------------------
	--> record how many times the spell has been casted successfully

		if (not who_name) then
			who_name = "[*] ".. spellname
		end
		
		if (not alvo_name) then
			alvo_name = "[*] ".. spellid
		end
		
		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--> get actors

		--> main actor

		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end
		local shadow = este_jogador.shadow

	------------------------------------------------------------------------------------------------
	--> build containers on the fly

		if (not este_jogador.spellcast) then
			--> constrói aqui a tabela dele
			este_jogador.spellcast = 0
			este_jogador.spellcast_spell_tables = container_habilidades:NovoContainer (container_misc)

			if (not este_jogador.shadow.spellcast_targets) then
				este_jogador.shadow.spellcast = 0
				este_jogador.shadow.spellcast_spell_tables = container_habilidades:NovoContainer (container_misc)
			end

			este_jogador.spellcast_targets.shadow = este_jogador.shadow.spellcast_targets
			este_jogador.spellcast_spell_tables.shadow = este_jogador.shadow.spellcast_spell_tables
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> last event update
		este_jogador.last_event = _tempo

		--> actor dispell amount
		este_jogador.spellcast = este_jogador.spellcast + 1
		shadow.spellcast = shadow.spellcast + 1
		
		--> actor spells table
		local spell = este_jogador.spellcast_spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spellcast_spell_tables:PegaHabilidade (spellid, true, token)
		end
		
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token)
	end


	--serach key: ~dispell
	function parser:dispell (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool, auraType)
		
	------------------------------------------------------------------------------------------------
	--> early checks and fixes
		
		--> esta dando erro onde o nome é NIL, fazendo um fix para isso
		if (not who_name) then
			who_name = "[*] "..extraSpellName
		end
		if (not alvo_name) then
			alvo_name = "[*] "..spellid
		end
		
		_current_misc_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors

		--> main actor
		--> debug - no cache
		--[[
		local este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
		--]]
		--[
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end
		--]]

	------------------------------------------------------------------------------------------------
	--> build containers on the fly

		if (not este_jogador.dispell) then
			--> constrói aqui a tabela dele
			este_jogador.dispell = 0
			este_jogador.dispell_targets = container_combatentes:NovoContainer (container_damage_target)
			este_jogador.dispell_spell_tables = container_habilidades:NovoContainer (container_misc)
			este_jogador.dispell_oque = {}
			
			if (not este_jogador.shadow.dispell_targets) then
				este_jogador.shadow.dispell = 0
				este_jogador.shadow.dispell_targets = container_combatentes:NovoContainer (container_damage_target)
				este_jogador.shadow.dispell_spell_tables = container_habilidades:NovoContainer (container_misc)
				este_jogador.shadow.dispell_oque = {}
			end

			este_jogador.dispell_targets.shadow = este_jogador.shadow.dispell_targets
			este_jogador.dispell_spell_tables.shadow = este_jogador.shadow.dispell_spell_tables
		end

	------------------------------------------------------------------------------------------------
	--> add amount

		--> last event update
		este_jogador.last_event = _tempo
		--shadow.last_event = _tempo

		--> total dispells in combat
		_current_total [4].dispell = _current_total [4].dispell + 1
		
		if (este_jogador.grupo) then
			_current_gtotal [4].dispell = _current_gtotal [4].dispell + 1
		end

		--> actor dispell amount
		este_jogador.dispell = este_jogador.dispell + 1
		
		--> dispell what
		if (extraSpellID) then
			if (not este_jogador.dispell_oque [extraSpellID]) then
				este_jogador.dispell_oque [extraSpellID] = 1
			else
				este_jogador.dispell_oque [extraSpellID] = este_jogador.dispell_oque [extraSpellID] + 1
			end
		end
		
		--> actor targets
		local este_alvo = este_jogador.dispell_targets._NameIndexTable [alvo_name]
		if (not este_alvo) then
			este_alvo = este_jogador.dispell_targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
		else
			este_alvo = este_jogador.dispell_targets._ActorTable [este_alvo]
		end
		este_alvo.total = este_alvo.total + 1

		--> actor spells table
		local spell = este_jogador.dispell_spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.dispell_spell_tables:PegaHabilidade (spellid, true, token)
		end
		spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
		
		--> verifica se tem dono e adiciona o interrupt para o dono
		if (meu_dono) then
			
			if (not meu_dono.dispell) then
				--> constrói aqui a tabela dele
				meu_dono.dispell = 0
				meu_dono.dispell_targets = container_combatentes:NovoContainer (container_damage_target)
				meu_dono.dispell_spell_tables = container_habilidades:NovoContainer (container_misc)
				meu_dono.dispell_oque = {}
				
				if (not meu_dono.shadow.dispell_targets) then
					meu_dono.shadow.dispell = 0
					meu_dono.shadow.dispell_targets = container_combatentes:NovoContainer (container_damage_target)
					meu_dono.shadow.dispell_spell_tables = container_habilidades:NovoContainer (container_misc)
					meu_dono.shadow.dispell_oque = {}
				end

				meu_dono.dispell_targets.shadow = meu_dono.shadow.dispell_targets
				meu_dono.dispell_spell_tables.shadow = meu_dono.shadow.dispell_spell_tables
			end
			
			-- adiciona ao total
			meu_dono.dispell = meu_dono.dispell + 1
			
			-- adiciona aos alvos
			local este_alvo = meu_dono.dispell_targets._NameIndexTable [alvo_name]
			if (not este_alvo) then
				este_alvo = meu_dono.dispell_targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			else
				este_alvo = meu_dono.dispell_targets._ActorTable [este_alvo]
			end
			este_alvo.total = este_alvo.total + 1
			
			-- update last event
			meu_dono.last_event = _tempo
			
			-- spells interrupted
			if (not meu_dono.dispell_oque [extraSpellID]) then
				meu_dono.dispell_oque [extraSpellID] = 1
			else
				meu_dono.dispell_oque [extraSpellID] = meu_dono.dispell_oque [extraSpellID] + 1
			end
		end		
		
	end

	--serach key: ~ress
	function parser:ress (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (_bit_band (who_flags, AFFILIATION_GROUP) == 0) then
			return
		end
		
		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--> get actors

		--> main actor
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end

	------------------------------------------------------------------------------------------------
	--> build containers on the fly

		if (not este_jogador.ress) then
			--> constrói aqui a tabela dele
			este_jogador.ress = 0
			este_jogador.ress_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
			este_jogador.ress_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
			
			if (not este_jogador.shadow.ress_targets) then
				este_jogador.shadow.ress = 0
				este_jogador.shadow.ress_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
				este_jogador.shadow.ress_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
			end

			este_jogador.ress_targets.shadow = este_jogador.shadow.ress_targets
			este_jogador.ress_spell_tables.shadow = este_jogador.shadow.ress_spell_tables
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> update last event
		este_jogador.last_event = _tempo
		--shadow.last_event = _tempo

		--> combat ress total
		_current_total [4].ress = _current_total [4].ress + 1
		
		if (este_jogador.grupo) then
			_current_combat.totals_grupo[4].ress = _current_combat.totals_grupo[4].ress+1
		end	

		--> add ress amount
		este_jogador.ress = este_jogador.ress + 1
		
		--> add battle ress
		if (_UnitAffectingCombat (who_name)) then 
			--> procura a última morte do alvo na tabela do combate:
			for i = 1, #_current_combat.last_events_tables do 
				if (_current_combat.last_events_tables [i] [3] == alvo_name) then

					local deadLog = _current_combat.last_events_tables [i] [1]
					local jaTem = false
					for _, evento in _ipairs (deadLog) do 
						if (evento [1] and not evento[3]) then
							jaTem = true
						end
					end
					
					if (not jaTem) then 
						_table_insert (_current_combat.last_events_tables [i] [1], 1, {true, spellid, false, time, _UnitHealth (alvo_name), who_name })
						break
					end
				end
			end
			
			if (_hook_battleress) then
				for _, func in _ipairs (_hook_battleress_container) do 
					func (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
				end
			end
			
		end	
		
		--> actor targets
		local este_alvo = este_jogador.ress_targets._NameIndexTable [alvo_name]
		if (not este_alvo) then
			este_alvo = este_jogador.ress_targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
		else
			este_alvo = este_jogador.ress_targets._ActorTable [este_alvo]
		end
		este_alvo.total = este_alvo.total + 1

		--> actor spells table
		local spell = este_jogador.ress_spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.ress_spell_tables:PegaHabilidade (spellid, true, token)
		end
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
	end

	--serach key: ~cc
	function parser:break_cc (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool, auraType)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes
		if (not cc_spell_list [spellid]) then
			--return print ("nao ta na lista")
		end

		if (_bit_band (who_flags, AFFILIATION_GROUP) == 0) then
			return
		end
		
		if (not spellname) then
			spellname = "Melee"
		end	

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--> get actors

		--> main actor
		--> debug - no cache
		--[[
		local este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
		--]]
		--[
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end
		--]]
		
	------------------------------------------------------------------------------------------------
	--> build containers on the fly
		
		if (not este_jogador.cc_break) then
			--> constrói aqui a tabela dele
			este_jogador.cc_break = 0
			este_jogador.cc_break_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
			este_jogador.cc_break_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
			este_jogador.cc_break_oque = {}
			
			if (not este_jogador.shadow.cc_break) then
				este_jogador.shadow.cc_break = 0
				este_jogador.shadow.cc_break_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
				este_jogador.shadow.cc_break_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
				este_jogador.shadow.cc_break_oque = {}
			end

			este_jogador.cc_break_targets.shadow = este_jogador.shadow.cc_break_targets
			este_jogador.cc_break_spell_tables.shadow = este_jogador.shadow.cc_break_spell_tables
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> update last event
		este_jogador.last_event = _tempo
		--shadow.last_event = _tempo
		
		--> combat cc break total
		_current_total [4].cc_break = _current_total [4].cc_break + 1

		if (este_jogador.grupo) then
			_current_combat.totals_grupo[4].cc_break = _current_combat.totals_grupo[4].cc_break+1
		end	
		
		--> add amount
		este_jogador.cc_break = este_jogador.cc_break + 1
		
		--> broke what
		if (not este_jogador.cc_break_oque [spellid]) then
			este_jogador.cc_break_oque [spellid] = 1
		else
			este_jogador.cc_break_oque [spellid] = este_jogador.cc_break_oque [spellid] + 1
		end
		
		--> actor targets
		local este_alvo = este_jogador.cc_break_targets._NameIndexTable [alvo_name]
		if (not este_alvo) then
			este_alvo = este_jogador.cc_break_targets:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
		else
			este_alvo = este_jogador.cc_break_targets._ActorTable [este_alvo]
		end
		este_alvo.total = este_alvo.total + 1

		--> actor spells table
		local spell = este_jogador.cc_break_spell_tables._ActorTable [extraSpellID]
		if (not spell) then
			spell = este_jogador.cc_break_spell_tables:PegaHabilidade (extraSpellID, true, token)
		end
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token, spellid, spellname)
	end

	--serach key: ~dead ~death ~morte
	function parser:dead (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags)

	--> not yet well cleaned, need more improvements

	------------------------------------------------------------------------------------------------
	--> early checks and fixes
	
		if (not alvo_name) then
			return
		end

	------------------------------------------------------------------------------------------------
	--> build dead
		
		
		if (_in_combat and alvo_flags and _bit_band (alvo_flags, 0x00000008) ~= 0) then -- and _in_combat --byte 1 = 8 (AFFILIATION_OUTSIDER)
			--> outsider death while in combat
			
			--> frags
			
				if (_detalhes.only_pvp_frags and (_bit_band (alvo_flags, 0x00000400) == 0 or (_bit_band (alvo_flags, 0x00000040) == 0 and _bit_band (alvo_flags, 0x00000020) == 0))) then --byte 2 = 4 (HOSTILE) byte 3 = 4 (OBJECT_TYPE_PLAYER)
					return
				end
			
				if (not _current_combat.frags [alvo_name]) then
					_current_combat.frags [alvo_name] = 1
				else
					_current_combat.frags [alvo_name] = _current_combat.frags [alvo_name] + 1
				end
				
				_current_combat.frags_need_refresh = true
				
			--> detect dungeon boss
				--if (_detalhes.zone_type == "party") then
				--	local npcID = tonumber (alvo_serial:sub (6, 10), 16)
				--	local boss_ids = _detalhes:GetBossIds (_detalhes.zone_id)
					
				--	if (boss_ids) then
				--		if (_detalhes.zone_id [npcID]) then
							
				--		end
				--	end
				--end

		--> player death
		elseif (not _UnitIsFeignDeath (alvo_name)) then
			if (
				--> player in your group
				_bit_band (alvo_flags, AFFILIATION_GROUP) ~= 0 and 
				--> must be a player
				_bit_band (alvo_flags, OBJECT_TYPE_PLAYER) ~= 0 and 
				--> must be in combat
				_in_combat
			) then
			
				--> true dead was a attempt to get the last hit because parser sometimes send the dead token before send the hit wich really killed the actor
				--> but unfortunately seems parser not send at all any damage after actor dead
				--_detalhes:ScheduleTimer ("TrueDead", 1, {time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags}) 
				
				_current_misc_container.need_refresh = true
				
				--> combat totals
				_current_total [4].dead = _current_total [4].dead + 1
				_current_gtotal [4].dead = _current_gtotal [4].dead + 1
				
				--> main actor no container de misc que irá armazenar a morte
				local este_jogador, meu_dono = misc_cache [alvo_name]
				if (not este_jogador) then --> pode ser um desconhecido ou um pet
					este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
					if (not meu_dono) then --> se não for um pet, adicionar no cache
						misc_cache [alvo_name] = este_jogador
					end
				end
				
				--> monta a estrutura da morte pegando a tabela de dano e a tabela de cura
				local dano = _current_combat[1]:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true) --> container do dano
				local cura = _current_combat[2]:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true) --> container da cura
				--> objeto da morte
				local esta_morte = {}
				
				--> adiciona a tabela da morte apenas os DANOS recentes
				for index, tabela in _ipairs (dano.last_events_table) do 
					if (tabela [4]) then
						if (tabela [4] + 12 > time) then --> mostra apenas eventos recentes
							esta_morte [#esta_morte+1] = tabela
						end
					end
				end
				
				--> adiciona a tabela da morte apenas as CURAS recentes
				if (cura.last_events_table) then
					for index, tabela in _ipairs (cura.last_events_table) do 
						if (tabela [4]) then
							if (tabela [4] + 12 > time) then
								esta_morte [#esta_morte+1] = tabela
							end
						end
					end
				end

				_table_sort (esta_morte, _detalhes.Sort4)
				--[[
				_table_sort (esta_morte, function (table1, table2)
					if (not table1) then 
						print (1)
						return false 
						
					elseif (not table2) then 
						print (2)
						return false
						
					elseif (table1 [4] == table2 [4]) then --> os 2 tem o mesmo tempo
						if (type (table1 [1]) == "boolean" and table1 [1] and type (table2 [1]) == "boolean" and table2) then --> ambos sao dano
							print (3)
							return table1 [5] > table2 [5] --> joga pra cima quem tem mais vida
						elseif (type (table1 [1]) == "boolean" and not table1 [1] and type (table2 [1]) == "boolean" and not table2) then --> ambos sao cura
							print (4)
							return table1 [5] < table2 [5] --> joga pra cima quem tem menos vida
						else
							if (type (table1 [1]) == "boolean" and table1 and type (table2 [1]) == "boolean" and table2) then --> primeiro é dano e segundo é heal
								print (5)
								return true --> passa o dano pra frente
							elseif (type (table2 [1]) == "boolean" and table2 and type (table1 [1]) == "boolean" and table1) then --> primeiro é heal e o segundo é dano
								print (6)
								return false --> passa o heal pra frente
							else
								print (7)
								return table1 [5] < table2 [5] --> passa quem tem menos vida
							end
						end
					else
						print (8)
						return table1 [4] < table2 [4]
					end
				end)
				--]]
				
				if (_hook_deaths) then
					--> send event to registred functions
					local death_at = _tempo - _current_combat.start_time
					local max_health = _UnitHealthMax (alvo_name)
					
					local new_death_table = {}
					for index, t in _ipairs (esta_morte) do 
						new_death_table [index] = t
					end
					for _, func in _ipairs (_hook_deaths_container) do 
						func (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, new_death_table, este_jogador.last_cooldown, death_at, max_health)
					end
				end				
				
				if (_detalhes.deadlog_limit and #esta_morte > _detalhes.deadlog_limit) then 
					for i = #esta_morte, _detalhes.deadlog_limit+1, -1 do
						_table_remove (esta_morte, i)
					end
				end
				
				if (este_jogador.last_cooldown) then
					local t = {}
					t [1] = 2 --> true if this is a damage || false for healing || 1 for cooldown usage || 2 for last cooldown
					t [2] = este_jogador.last_cooldown[2] --> spellid || false if this is a battle ress line
					t [3] = 1 --> amount of damage or healing
					t [4] = este_jogador.last_cooldown[1] --> parser time
					t [5] = 0 --> current unit heal
					t [6] = alvo_name --> source name
					esta_morte [#esta_morte+1] = t
				else
					local t = {}
					t [1] = 2 --> true if this is a damage || false for healing || 1 for cooldown usage || 2 for last cooldown
					t [2] = 0 --> spellid || false if this is a battle ress line
					t [3] = 0 --> amount of damage or healing
					t [4] = 0 --> parser time
					t [5] = 0 --> current unit heal
					t [6] = alvo_name --> source name
					esta_morte [#esta_morte+1] = t
				end
				
				local decorrido = _tempo - _current_combat.start_time
				local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
				
				local t = {esta_morte, time, este_jogador.nome, este_jogador.classe, _UnitHealthMax (alvo_name), minutos.."m "..segundos.."s",  ["dead"] = true}
				
				_table_insert (_current_combat.last_events_tables, #_current_combat.last_events_tables+1, t)

				--> reseta a pool
				dano.last_events_table =  _detalhes:CreateActorLastEventTable()
				cura.last_events_table =  _detalhes:CreateActorLastEventTable()

			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	local token_list = {
		-- neutral
		["SPELL_SUMMON"] = parser.summon,
		--["SPELL_CAST_FAILED"] = parser.spell_fail
	}

	--serach key: ~capture

	_detalhes.capture_types = {"damage", "heal", "energy", "miscdata", "aura", "spellcast"}

	function _detalhes:CaptureIsAllEnabled()
		for _, _thisType in _ipairs (_detalhes.capture_types) do 
			if (not _detalhes.capture_real [_thisType]) then
				return false
			end
		end
		return true
	end
	
	function _detalhes:CaptureIsEnabled (capture)
		if (_detalhes.capture_real [capture]) then
			return true
		end
		return false
	end
	
	function _detalhes:CaptureRefresh()
		for _, _thisType in _ipairs (_detalhes.capture_types) do 
			if (_detalhes.capture_current [_thisType]) then
				_detalhes:CaptureEnable (_thisType)
			else
				_detalhes:CaptureDisable (_thisType)
			end
		end
	end
	
	function _detalhes:CaptureGet (capture_type)
		return _detalhes.capture_real [capture_type]
	end

	function _detalhes:CaptureSet (on_off, capture_type, real, time)

		if (real) then
			--> hard switch
			_detalhes.capture_real [capture_type] = on_off
			_detalhes.capture_current [capture_type] = on_off
		else
			--> soft switch
			_detalhes.capture_current [capture_type] = on_off
			if (time) then
				_detalhes:ScheduleTimer ("CaptureTimeout", time, capture_type)
			end
		end
		
		_detalhes:CaptureRefresh()
	end

	function _detalhes:CaptureTimeout (capture_type)
		_detalhes.capture_current [capture_type] = _detalhes.capture_real [capture_type]
		_detalhes:CaptureRefresh()
	end

	function _detalhes:CaptureDisable (capture_type)

		capture_type = string.lower (capture_type)
		
		if (capture_type == "damage") then
			token_list ["SPELL_PERIODIC_DAMAGE"] = nil
			token_list ["SPELL_EXTRA_ATTACKS"] = nil
			token_list ["SPELL_DAMAGE"] = nil
			token_list ["SWING_DAMAGE"] = nil
			token_list ["RANGE_DAMAGE"] = nil
			token_list ["DAMAGE_SHIELD"] = nil
			token_list ["DAMAGE_SPLIT"] = nil
			token_list ["RANGE_MISSED"] = nil
			token_list ["SWING_MISSED"] = nil
			token_list ["SPELL_MISSED"] = nil
		
		elseif (capture_type == "heal") then
			token_list ["SPELL_HEAL"] = nil
			token_list ["SPELL_PERIODIC_HEAL"] = nil
			_recording_healing = false
		
		elseif (capture_type == "aura") then
			token_list ["SPELL_AURA_APPLIED"] = parser.buff
			token_list ["SPELL_AURA_REMOVED"] = parser.unbuff
			token_list ["SPELL_AURA_REFRESH"] = parser.buff_refresh
			_recording_buffs_and_debuffs = false
		
		elseif (capture_type == "energy") then
			token_list ["SPELL_ENERGIZE"] = nil
			token_list ["SPELL_PERIODIC_ENERGIZE"] = nil
		
		elseif (capture_type == "spellcast") then
			token_list ["SPELL_CAST_SUCCESS"] = nil
		
		elseif (capture_type == "miscdata") then
			-- dispell
			token_list ["SPELL_DISPEL"] = nil
			token_list ["SPELL_STOLEN"] = nil
			-- cc broke
			token_list ["SPELL_AURA_BROKEN"] = nil
			token_list ["SPELL_AURA_BROKEN_SPELL"] = nil
			-- ress
			token_list ["SPELL_RESURRECT"] = nil
			-- interrupt
			token_list ["SPELL_INTERRUPT"] = nil
			-- dead
			token_list ["UNIT_DIED"] = nil
			token_list ["UNIT_DESTROYED"] = nil
		
		end
	end

	--"ENVIRONMENTAL_DAMAGE" --> damage aplied by enviorement like lava.
	--SPELL_PERIODIC_MISSED --> need research
	--DAMAGE_SHIELD_MISSED --> need research
	--SPELL_EXTRA_ATTACKS --> need research
	--SPELL_DRAIN --> need research
	--SPELL_LEECH --> need research
	--SPELL_PERIODIC_DRAIN --> need research
	--SPELL_PERIODIC_LEECH --> need research
	--SPELL_DISPEL_FAILED --> need research
	
	function _detalhes:CaptureEnable (capture_type)

		capture_type = string.lower (capture_type)
		
		if (capture_type == "damage") then
			token_list ["SPELL_PERIODIC_DAMAGE"] = parser.spell_dmg
			token_list ["SPELL_EXTRA_ATTACKS"] = parser.spell_dmg
			token_list ["SPELL_DAMAGE"] = parser.spell_dmg
			token_list ["SWING_DAMAGE"] = parser.swing
			token_list ["RANGE_DAMAGE"] = parser.range
			token_list ["DAMAGE_SHIELD"] = parser.spell_dmg
			token_list ["DAMAGE_SPLIT"] = parser.spell_dmg
			token_list ["RANGE_MISSED"] = parser.rangemissed
			token_list ["SWING_MISSED"] = parser.swingmissed
			token_list ["SPELL_MISSED"] = parser.missed

		elseif (capture_type == "heal") then
			token_list ["SPELL_HEAL"] = parser.heal
			token_list ["SPELL_PERIODIC_HEAL"] = parser.heal
			_recording_healing = true

		elseif (capture_type == "aura") then
			token_list ["SPELL_AURA_APPLIED"] = parser.buff
			token_list ["SPELL_AURA_REMOVED"] = parser.unbuff
			token_list ["SPELL_AURA_REFRESH"] = parser.buff_refresh
			_recording_buffs_and_debuffs = true

		elseif (capture_type == "energy") then
			token_list ["SPELL_ENERGIZE"] = parser.energize
			token_list ["SPELL_PERIODIC_ENERGIZE"] = parser.energize

		elseif (capture_type == "spellcast") then
			token_list ["SPELL_CAST_SUCCESS"] = parser.spellcast

		elseif (capture_type == "miscdata") then
			-- dispell
			token_list ["SPELL_DISPEL"] = parser.dispell
			token_list ["SPELL_STOLEN"] = parser.dispell
			-- cc broke
			token_list ["SPELL_AURA_BROKEN"] = parser.break_cc
			token_list ["SPELL_AURA_BROKEN_SPELL"] = parser.break_cc
			-- ress
			token_list ["SPELL_RESURRECT"] = parser.ress
			-- interrupt
			token_list ["SPELL_INTERRUPT"] = parser.interrupt
			-- dead
			token_list ["UNIT_DIED"] = parser.dead
			token_list ["UNIT_DESTROYED"] = parser.dead
			
		end
	end

	-- PARSER
	--serach key: ~parser ~event ~start ~inicio
	function _detalhes:GetZoneType()
		return _detalhes.zone_type
	end
	function _detalhes.parser_functions:ZONE_CHANGED_NEW_AREA (...)
		local zoneName, zoneType, _, _, _, _, _, zoneMapID = _GetInstanceInfo()
		
		if (_detalhes.last_zone_type ~= zoneType) then
			_detalhes:SendEvent ("ZONE_TYPE_CHANGED", nil, zoneType)
			_detalhes.last_zone_type = zoneType
		end
		
		_detalhes.zone_type = zoneType
		_detalhes.zone_id = zoneMapID
		_detalhes.zone_name = zoneName
		
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) zone change:", _detalhes.zone_name, "is a", _detalhes.zone_type, "zone.")
		end
		
		if (_detalhes.is_in_arena and zoneType ~= "arena") then
			_detalhes:LeftArena()
		end
		
		if (zoneType == "pvp") then
			if (not _current_combat.pvp) then
			
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) battleground found, starting new combat table.")
				end
				
				_detalhes:EntrarEmCombate()
				--> sinaliza que esse combate é pvp
				_current_combat.pvp = true
				_current_combat.is_pvp = {name = zoneName, zone = ZoneName, mapid = ZoneMapID}
				_detalhes.listener:RegisterEvent ("CHAT_MSG_BG_SYSTEM_NEUTRAL")
			end
		
		elseif (zoneType == "arena") then
		
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) zone type is arena.")
			end
		
			_detalhes.is_in_arena = true
			_detalhes:EnteredInArena()
			
		else
			if (_detalhes:IsInInstance()) then
				_detalhes.last_instance = zoneMapID
			end
			
			if (_current_combat.pvp) then 
				_current_combat.pvp = false
			end
		end
		
		_detalhes:SchedulePetUpdate (7)
		_detalhes:CheckForPerformanceProfile()
	end
	
	function _detalhes.parser_functions:PLAYER_ENTERING_WORLD (...)
		return _detalhes.parser_functions:ZONE_CHANGED_NEW_AREA (...)
	end
	
	function _detalhes.parser_functions:ENCOUNTER_START (...)
		_table_wipe (_detalhes.encounter_table)
		
		local encounterID, encounterName, difficultyID, raidSize = _select (1, ...)
		local zoneName, _, _, _, _, _, _, zoneMapID = _GetInstanceInfo()
		
		--print (encounterID, encounterName, difficultyID, raidSize)
		
		_detalhes.encounter_table ["start"] = time()
		_detalhes.encounter_table ["end"] = nil
		
		_detalhes.encounter_table.id = encounterID
		_detalhes.encounter_table.name = encounterName
		_detalhes.encounter_table.diff = difficultyID
		_detalhes.encounter_table.size = raidSize
		_detalhes.encounter_table.zone = zoneName
		_detalhes.encounter_table.mapid = zoneMapID
		
		local encounter_start_table = _detalhes:GetEncounterStartInfo (zoneMapID, encounterID)
		if (encounter_start_table) then
			if (encounter_start_table.delay) then
				if (type (encounter_start_table.delay) == "function") then
					local delay = encounter_start_table.delay()
					if (delay) then
						_detalhes.encounter_table ["start"] = time() + delay
					end
				else
					_detalhes.encounter_table ["start"] = time() + encounter_start_table.delay
				end
			end
			if (encounter_start_table.func) then
				encounter_start_table:func()
			end
		end

		local encounter_table, boss_index = _detalhes:GetBossEncounterDetailsFromEncounterId (zoneMapID, encounterID)
		if (encounter_table) then
			_detalhes.encounter_table.index = boss_index
		end
		
	end
	
	function _detalhes.parser_functions:ENCOUNTER_END (...)
	
		if (not _detalhes.encounter_table.start) then
			return
		end
		
		_detalhes.latest_ENCOUNTER_END = _detalhes.latest_ENCOUNTER_END or 0
		if (_detalhes.latest_ENCOUNTER_END + 15 > _detalhes._tempo) then
			return
		end
		_detalhes.latest_ENCOUNTER_END = _detalhes._tempo
		
		_detalhes.encounter_table ["end"] = time() - 0.4
		
		local encounterID, encounterName, difficultyID, raidSize, endStatus = _select (1, ...)
		local _, _, _, _, _, _, _, zoneMapID = _GetInstanceInfo()
		
		if (_in_combat) then
			if (endStatus == 1) then
				_detalhes.encounter_table.kill = true
				_detalhes:SairDoCombate (true, true) --killed
			else
				_detalhes.encounter_table.kill = false
				_detalhes:SairDoCombate (false, true) --wipe
			end
		else
			if (_detalhes.tabela_vigente.end_time + 2 >= _detalhes.encounter_table ["end"]) then
				--_detalhes.tabela_vigente.start_time = _detalhes.encounter_table ["start"]
				_detalhes.tabela_vigente.end_time = _detalhes.encounter_table ["end"]
				_detalhes:AtualizaGumpPrincipal (-1, true)
			end
		end

		_table_wipe (_detalhes.encounter_table)
	end
	
	function _detalhes.parser_functions:CHAT_MSG_BG_SYSTEM_NEUTRAL (...)
		local frase = _select (1, ...)
		--> reset combat timer
		if ( (frase:find ("The battle") and frase:find ("has begun!") ) and _current_combat.pvp) then
			local tempo_do_combate = _tempo - _current_combat.start_time
			_detalhes.tabela_overall.start_time = _detalhes.tabela_overall.start_time + tempo_do_combate
			_current_combat.start_time = _tempo
			_detalhes.listener:UnregisterEvent ("CHAT_MSG_BG_SYSTEM_NEUTRAL")
		end
	end
	
	function _detalhes.parser_functions:UNIT_PET (...)
		_detalhes:SchedulePetUpdate (1)
	end

	function _detalhes.parser_functions:PLAYER_REGEN_DISABLED (...)
		if (_detalhes.EncounterInformation [_detalhes.zone_id]) then 
			_detalhes:ScheduleTimer ("ReadBossFrames", 1)
			_detalhes:ScheduleTimer ("ReadBossFrames", 30)
		end
		
		if (not _detalhes:CaptureGet ("damage")) then
			_detalhes:EntrarEmCombate()
		end

		--> essa parte do solo mode ainda sera usada?
		if (_detalhes.solo and _detalhes.PluginCount.SOLO > 0) then --> solo mode
			local esta_instancia = _detalhes.tabela_instancias[_detalhes.solo]
			esta_instancia.atualizando = true
		end
		
		for index, instancia in ipairs (_detalhes.tabela_instancias) do 
			if (instancia.ativa) then
				instancia:SetCombatAlpha (nil, nil, true)
			end
		end
	end

	function _detalhes.parser_functions:PLAYER_REGEN_ENABLED (...)
	
		--> playing alone, just finish the combat right now
		if (not _IsInGroup() and not IsInRaid()) then	
			_detalhes.tabela_vigente.playing_solo = true
			_detalhes:SairDoCombate()
		end
		
		--> aqui, tentativa de fazer o timer da janela do Solo funcionar corretamente:
		if (_detalhes.solo and _detalhes.PluginCount.SOLO > 0) then
			if (_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].Stop) then
				_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].Stop()
			end
		end
		
		if (_detalhes.schedule_flag_boss_components) then
			_detalhes.schedule_flag_boss_components = false
			_detalhes:FlagActorsOnBossFight()
		end

		if (_detalhes.schedule_remove_overall) then
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) found schedule overall data deletion.")
			end
			_detalhes.schedule_remove_overall = false
			_detalhes.tabela_historico:resetar_overall()
		end
		
		if (_detalhes.schedule_add_to_overall) then
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) found schedule overall data addition.")
			end
			_detalhes.schedule_add_to_overall = false

			_detalhes.historico:adicionar_overall (_detalhes.tabela_vigente)
		end
		
		for index, instancia in ipairs (_detalhes.tabela_instancias) do 
			if (instancia.ativa) then
				instancia:SetCombatAlpha (nil, nil, true)
			end
		end

	end

	function _detalhes.parser_functions:ROLE_CHANGED_INFORM (...)
		if (_detalhes.last_assigned_role ~= _UnitGroupRolesAssigned ("player")) then
			_detalhes:CheckSwitchOnLogon (true)
			_detalhes.last_assigned_role = _UnitGroupRolesAssigned ("player")
		end
	end
	
	function _detalhes.parser_functions:PLAYER_ROLES_ASSIGNED (...)
		if (_detalhes.last_assigned_role ~= _UnitGroupRolesAssigned ("player")) then
			_detalhes:CheckSwitchOnLogon (true)
			_detalhes.last_assigned_role = _UnitGroupRolesAssigned ("player")
		end
	end
	
	function _detalhes:InGroup()
		return _detalhes.in_group
	end
	function _detalhes.parser_functions:GROUP_ROSTER_UPDATE (...)
		if (not _detalhes.in_group) then
			_detalhes.in_group = IsInGroup() or IsInRaid()
			if (_detalhes.in_group) then
				--> entrou num grupo
				_detalhes:IniciarColetaDeLixo (true)
				_detalhes:WipePets()
				_detalhes:SchedulePetUpdate (1)
				_detalhes:InstanceCall (_detalhes.SetCombatAlpha, nil, nil, true)
				_detalhes:CheckSwitchOnLogon()
				_detalhes:CheckVersion()
				_detalhes:SendEvent ("GROUP_ONENTER")
			end
		else
			_detalhes.in_group = IsInGroup() or IsInRaid()
			if (not _detalhes.in_group) then
				--> saiu do grupo
				_detalhes:IniciarColetaDeLixo (true)
				_detalhes:WipePets()
				_detalhes:SchedulePetUpdate (1)
				_table_wipe (_detalhes.details_users)
				_detalhes:InstanceCall (_detalhes.SetCombatAlpha, nil, nil, true)
				_detalhes:CheckSwitchOnLogon()
				_detalhes:SendEvent ("GROUP_ONLEAVE")
			else
				_detalhes:SchedulePetUpdate (2)
			end
		end
		
		_detalhes:SchedulePetUpdate (6)
	end

	function _detalhes.parser_functions:START_TIMER (...)
	
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) found a timer.")
		end
	
		if (C_Scenario.IsChallengeMode() and _detalhes.overall_clear_newchallenge) then
			_detalhes.historico:resetar_overall()
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) timer is a challenge mode start.")
			end
			
		elseif (_detalhes.is_in_arena) then
			_detalhes:StartArenaSegment (...)
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) timer is a arena countdown.")
			end
		end
	end

	function _detalhes.parser_functions:ADDON_LOADED (...)
	
		local addon_name = _select (1, ...)
		
		if (addon_name == "Details") then
		
			--> cooltip
			if (not _G.GameCooltip) then
				_detalhes.popup = DetailsCreateCoolTip()
			else
				_detalhes.popup = _G.GameCooltip
			end
		
			--> check group
			_detalhes.in_group = IsInGroup() or IsInRaid()
		
			--> write into details object all basic keys
			_detalhes:ApplyBasicKeys()
			--> check if is first run
			_detalhes:LoadGlobalAndCharacterData()
			--> load all the saved combats
			_detalhes:LoadCombatTables()
			--> load the profiles
			_detalhes:LoadConfig()

			_detalhes:UpdateParserGears()
			_detalhes:Start()
		end	
	end
	
	function _detalhes.parser_functions:PET_BATTLE_OPENING_START (...)
		_detalhes.pet_battle = true
		for index, instance in _ipairs (_detalhes.tabela_instancias) do
			if (instance.ativa) then
				instance:SetWindowAlphaForCombat (true, true)
			end
		end
	end
	
	function _detalhes.parser_functions:PET_BATTLE_CLOSE (...)
		_detalhes.pet_battle = false
		for index, instance in _ipairs (_detalhes.tabela_instancias) do
			if (instance.ativa) then
				instance:SetWindowAlphaForCombat()
			end
		end
	end
	
	function _detalhes.parser_functions:UNIT_NAME_UPDATE (...)
		_detalhes:SchedulePetUpdate (5)
	end
	
	local parser_functions = _detalhes.parser_functions
	
	function _detalhes:OnEvent (evento, ...)
		local func = parser_functions [evento]
		if (func) then
			return func (nil, ...)
		end
	end

	_detalhes.listener:SetScript ("OnEvent", _detalhes.OnEvent)
	
	--> protected logout function
		function _detalhes:PLAYER_LOGOUT (...)
		
			--> close info window
				if (_detalhes.FechaJanelaInfo) then
					_detalhes:FechaJanelaInfo()
				end

			--> leave combat start save tables
				if (_detalhes.in_combat and _detalhes.tabela_vigente) then 
					_detalhes:SairDoCombate()
					_detalhes.can_panic_mode = true
				end
				
				if (_detalhes.CheckSwitchOnLogon and _detalhes.tabela_instancias[1] and getmetatable (_detalhes.tabela_instancias[1])) then
					_detalhes:CheckSwitchOnLogon()
				end
				
				if (_detalhes.wipe_full_config) then
					_detalhes_global = nil
					_detalhes_database = nil
					return
				end
			
			--> save the config
				_detalhes:SaveConfig()
				_detalhes:SaveProfile()

			--> save the nicktag cache
				_detalhes_database.nick_tag_cache = table_deepcopy (_detalhes_database.nick_tag_cache)
		end
		
		local saver = CreateFrame ("frame", "_detalhes_saver_frame", UIParent)
		saver:RegisterEvent ("PLAYER_LOGOUT")
		saver:SetScript ("OnEvent", _detalhes.PLAYER_LOGOUT)
		
	--> end

	function _detalhes:OnParserEvent (evento, time, token, hidding, who_serial, who_name, who_flags, who_flags2, alvo_serial, alvo_name, alvo_flags, alvo_flags2, ...)
		local funcao = token_list [token]
		
		--print (token, ...)
		
		if (funcao) then
			return funcao (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, ... )
		else
			return
		end
	end
	_detalhes.parser_frame:SetScript ("OnEvent", _detalhes.OnParserEvent)

	function _detalhes:UpdateParser()
		_tempo = _detalhes._tempo
	end

	function _detalhes:PrintParserCacheIndexes()
	
		local amount = 0
		for n, nn in pairs (damage_cache) do 
			amount = amount + 1
		end
		print ("parser damage_cache", amount)
		
		amount = 0
		for n, nn in pairs (damage_cache_pets) do 
			amount = amount + 1
		end
		print ("parser damage_cache_pets", amount)
		
		amount = 0
		for n, nn in pairs (damage_cache_petsOwners) do 
			amount = amount + 1
		end
		print ("parser damage_cache_petsOwners", amount)
		
		amount = 0
		for n, nn in pairs (healing_cache) do 
			amount = amount + 1
		end
		print ("parser healing_cache", amount)
		
		amount = 0
		for n, nn in pairs (energy_cache) do 
			amount = amount + 1
		end
		print ("parser energy_cache", amount)

		amount = 0
		for n, nn in pairs (misc_cache) do 
			amount = amount + 1
		end
		print ("parser misc_cache", amount)
		
		print ("group damage", #_detalhes.cache_damage_group)
		print ("group damage", #_detalhes.cache_healing_group)
	end
	
	function _detalhes:GetActorsOnDamageCache()
		return _detalhes.cache_damage_group
	end
	function _detalhes:GetActorsOnHealingCache()
		return _detalhes.cache_healing_group
	end
	
	function _detalhes:ClearParserCache()
		
		--> clear cache | not sure if replacing the old table is the best approach
	
		_table_wipe (damage_cache)
		_table_wipe (damage_cache_pets)
		_table_wipe (damage_cache_petsOwners)
		_table_wipe (healing_cache)
		_table_wipe (energy_cache)
		_table_wipe (misc_cache)
	
		damage_cache = setmetatable ({}, _detalhes.weaktable)
		damage_cache_pets = setmetatable ({}, _detalhes.weaktable)
		damage_cache_petsOwners = setmetatable ({}, _detalhes.weaktable)
		
		healing_cache = setmetatable ({}, _detalhes.weaktable)
		
		energy_cache = setmetatable ({}, _detalhes.weaktable)
		
		misc_cache = setmetatable ({}, _detalhes.weaktable)
		
	end

	function _detalhes:UptadeRaidMembersCache()
	
		_table_wipe (raid_members_cache)
		_table_wipe (tanks_members_cache)
		
		local roster = _detalhes.tabela_vigente.raid_roster
		
		if (_IsInRaid()) then
			for i = 1, _GetNumGroupMembers() do 
				local name = _GetUnitName ("raid"..i, true)
				
				raid_members_cache [_UnitGUID ("raid"..i)] = true
				roster [name] = true
				
				local role = _UnitGroupRolesAssigned (name)
				if (role == "TANK") then
					tanks_members_cache [_UnitGUID ("raid"..i)] = true
				end
			end
			
		elseif (_IsInGroup()) then
			--party
			for i = 1, _GetNumGroupMembers()-1 do 
				local name = _GetUnitName ("party"..i, true)
				
				raid_members_cache [_UnitGUID ("party"..i)] = true
				roster [name] = true
				
				local role = _UnitGroupRolesAssigned (name)
				if (role == "TANK") then
					tanks_members_cache [_UnitGUID ("party"..i)] = true
				end
			end
			
			--player
			local name = GetUnitName ("player", true)
			
			raid_members_cache [_UnitGUID ("player")] = true
			roster [name] = true
			
			local role = _UnitGroupRolesAssigned (name)
			if (role == "TANK") then
				tanks_members_cache [_UnitGUID ("player")] = true
			end
		else
			local name = GetUnitName ("player", true)
			
			raid_members_cache [_UnitGUID ("player")] = true
			roster [name] = true
			
			local role = _UnitGroupRolesAssigned (name)
			if (role == "TANK") then
				tanks_members_cache [_UnitGUID ("player")] = true
			end
		end
	end

	function _detalhes:IsATank (playerguid)
		return tanks_members_cache [playerguid]
	end
	
	function _detalhes:IsInCache (playerguid)
		return raid_members_cache [playerguid]
	end
	function _detalhes:GetParserPlayerCache()
		return raid_members_cache
	end
	
	--serach key: ~cache
	function _detalhes:UpdateParserGears()

		--> refresh combat tables
		_current_combat = _detalhes.tabela_vigente

		--> refresh total containers
		_current_total = _current_combat.totals
		_current_gtotal = _current_combat.totals_grupo
		
		--> refresh actors containers
		_current_damage_container = _current_combat [1]

		_current_heal_container = _current_combat [2]
		_current_energy_container = _current_combat [3]
		_current_misc_container = _current_combat [4]
		
		--> refresh data capture options
		_recording_self_buffs = _detalhes.RecordPlayerSelfBuffs
		--_recording_healing = _detalhes.RecordHealingDone
		--_recording_took_damage = _detalhes.RecordRealTimeTookDamage
		_recording_ability_with_buffs = _detalhes.RecordPlayerAbilityWithBuffs
		_in_combat = _detalhes.in_combat
		
		if (_detalhes.hooks ["HOOK_COOLDOWN"].enabled) then
			_hook_cooldowns = true
		else
			_hook_cooldowns = false
		end
		
		if (_detalhes.hooks ["HOOK_DEATH"].enabled) then
			_hook_deaths = true
		else
			_hook_deaths = false
		end
		
		if (_detalhes.hooks ["HOOK_BUFF"].enabled) then --[[REMOVED]]
			_hook_buffs = true
		else
			_hook_buffs = false
		end
		
		if (_detalhes.hooks ["HOOK_BATTLERESS"].enabled) then
			_hook_battleress = true
		else
			_hook_battleress = false
		end

		return _detalhes:ClearParserCache()
	end
	
	
	
--serach key: ~api
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions

	--> number of combat
	function  _detalhes:GetCombatId()
		return _detalhes.combat_id
	end

	--> if in combat
	function _detalhes:IsInCombat()
		return _in_combat
	end

	--> get combat
	function _detalhes:GetCombat (_combat)
		if (not _combat) then
			return _current_combat
		elseif (_type (_combat) == "number") then
			if (_combat == -1) then --> overall
				return _overall_combat
			elseif (_combat == 0) then --> current
				return _current_combat
			else
				return _detalhes.tabela_historico.tabelas [_combat]
			end
		elseif (_type (_combat) == "string") then
			if (_combat == "overall") then
				return _overall_combat
			elseif (_combat == "current") then
				return _current_combat
			end
		end
		
		return nil
	end

	function _detalhes:GetAllActors (_combat, _actorname)
		return _detalhes:GetActor (_combat, 1, _actorname), _detalhes:GetActor (_combat, 2, _actorname), _detalhes:GetActor (_combat, 3, _actorname), _detalhes:GetActor (_combat, 4, _actorname)
	end
	
	--> get an actor
	function _detalhes:GetActor (_combat, _attribute, _actorname)

		if (not _combat) then
			_combat = "current" --> current combat
		end
		
		if (not _attribute) then
			_attribute = 1 --> damage
		end
		
		if (not _actorname) then
			_actorname = _detalhes.playername
		end
		
		if (_combat == 0 or _combat == "current") then
			local actor = _detalhes.tabela_vigente (_attribute, _actorname)
			if (actor) then
				return actor
			else
				return nil --_detalhes:NewError ("Current combat doesn't have an actor called ".. _actorname)
			end
			
		elseif (_combat == -1 or _combat == "overall") then
			local actor = _detalhes.tabela_overall (_attribute, _actorname)
			if (actor) then
				return actor
			else
				return nil --_detalhes:NewError ("Combat overall doesn't have an actor called ".. _actorname)
			end
			
		elseif (type (_combat) == "number") then
			local _combatOnHistoryTables = _detalhes.tabela_historico.tabelas [_combat]
			if (_combatOnHistoryTables) then
				local actor = _combatOnHistoryTables (_attribute, _actorname)
				if (actor) then
					return actor
				else
					return nil --_detalhes:NewError ("Combat ".. _combat .." doesn't have an actor called ".. _actorname)
				end
			else
				return nil --_detalhes:NewError ("Combat ".._combat.." not found.")
			end
		else
			return nil --_detalhes:NewError ("Couldn't find a combat object for passed parameters")
		end
	end
	

