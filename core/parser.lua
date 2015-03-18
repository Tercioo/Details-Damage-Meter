
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
	local _GetTime = GetTime

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
	local spell_damageMiss_func = _detalhes.habilidade_dano.AddMiss --details local
	local spell_damageFF_func = _detalhes.habilidade_dano.AddFF --details local

	local spell_heal_func = _detalhes.habilidade_cura.Add --details local
	local spell_energy_func = _detalhes.habilidade_e_energy.Add --details local
	local spell_misc_func = _detalhes.habilidade_misc.Add --details local
	
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
	--> damage and heal last events
		local last_events_cache = {} --> placeholder
	--> pets
		local container_pets = {} --> place holder
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS
	local container_misc = _detalhes.container_type.CONTAINER_MISC_CLASS
	
	local OBJECT_TYPE_PLAYER = 0x00000400
	local OBJECT_TYPE_PETS = 0x00003000
	local AFFILIATION_GROUP = 0x00000007
	local REACTION_FRIENDLY = 0x00000010 
	
	local ENVIRONMENTAL_FALLING_NAME = Loc ["STRING_ENVIRONMENTAL_FALLING"]
	local ENVIRONMENTAL_DROWNING_NAME = Loc ["STRING_ENVIRONMENTAL_DROWNING"]
	local ENVIRONMENTAL_FATIGUE_NAME = Loc ["STRING_ENVIRONMENTAL_FATIGUE"]
	local ENVIRONMENTAL_FIRE_NAME = Loc ["STRING_ENVIRONMENTAL_FIRE"]
	local ENVIRONMENTAL_LAVA_NAME = Loc ["STRING_ENVIRONMENTAL_LAVA"]
	local ENVIRONMENTAL_SLIME_NAME = Loc ["STRING_ENVIRONMENTAL_SLIME"]
	
	--> recording data options flags
		local _recording_self_buffs = false
		local _recording_ability_with_buffs = false
		local _recording_healing = false
		local _recording_buffs_and_debuffs = false
	--> in combat flag
		local _in_combat = false
	--> deathlog
		local _death_event_amt = 16
	--> hooks
		local _hook_cooldowns = false
		local _hook_deaths = false
		local _hook_battleress = false
		local _hook_interrupt = false
		
		local _hook_cooldowns_container = _detalhes.hooks ["HOOK_COOLDOWN"]
		local _hook_deaths_container = _detalhes.hooks ["HOOK_DEATH"]
		local _hook_battleress_container = _detalhes.hooks ["HOOK_BATTLERESS"]
		local _hook_interrupt_container = _detalhes.hooks ["HOOK_INTERRUPT"]

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions

-----------------------------------------------------------------------------------------------------------------------------------------
	--> DAMAGE 	serach key: ~damage											|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:swing (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand, multistrike)
		return parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, 1, "Corpo-a-Corpo", 00000001, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand, multistrike) --> localize-me
																		--spellid, spellname, spelltype
	end

	function parser:range (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand, multistrike)
		return parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, 2, "Tiro-Automático", 00000001, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand, multistrike)  --> localize-me
																		--spellid, spellname, spelltype
	end

--	/run local f=CreateFrame("frame");f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");f:SetScript("OnEvent", function(self, ...)print (...);end)
	
	function parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand, multistrike)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (who_serial == "") then
			if (who_flags and _bit_band (who_flags, OBJECT_TYPE_PETS) ~= 0) then --> é um pet
				--> pets must have a serial
				return
			end
			--who_serial = nil
		end

		if (not alvo_name) then
			--> no target name, just quit
			return
			
		elseif (not who_name) then
			--> no actor name, use spell name instead
			who_name = "[*] " .. spellname
			who_flags = 0xa48
			who_serial = ""
		end
		
		--> Fix for mage prismatic crystal
		--local npcId = _detalhes:GetNpcIdFromGuid (alvo_serial)
		--if (npcId == 76933) then
		--	return
		--end
		
		--using pattern, calling API is too slow here
		if (alvo_serial:match ("^Creature%-0%-%d+%-%d+%-%d+%-76933%-%w+$")) then
			return
		end
		
		--> Second try with :find
		-- it's 20% faster when comparing Npcs serials, but very slow when comparing other things.
		--if (alvo_serial:find ("-76933-")) then
		--	return
		--end
		
		--> spirit link toten
		if (spellid == 98021) then
			return
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
				if (_detalhes.encounter_table.id and _detalhes.encounter_table ["start"] >= _GetTime() - 3 and _detalhes.announce_firsthit.enabled) then
					local link
					if (spellid <= 10) then
						link = _GetSpellInfo (spellid)
					else
						link = GetSpellLink (spellid)
					end
					_detalhes:Msg ("First hit: " .. (link or "") .. " from " .. (who_name or "Unknown"))
				end
				_detalhes:EntrarEmCombate (who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags)
			else
				--> entrar em combate se for dot e for do jogador e o ultimo combate ter sido a mais de 10 segundos atrás
				if (token == "SPELL_PERIODIC_DAMAGE" and who_name == _detalhes.playername) then
					if (_detalhes.last_combat_time+10 < _tempo) then
						_detalhes:EntrarEmCombate (who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags)
					end
				end
			end
		end
		
		--[[statistics]]-- _detalhes.statistics.damage_calls = _detalhes.statistics.damage_calls + 1
		
		_current_damage_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors
	
		--> damager
		local este_jogador, meu_dono = damage_cache [who_serial] or damage_cache_pets [who_serial], damage_cache_petsOwners [who_serial]
		
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
		
			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
			
			if (meu_dono) then --> é um pet
				damage_cache_pets [who_serial] = este_jogador
				damage_cache_petsOwners [who_serial] = meu_dono
				--conferir se o dono já esta no cache
				if (not damage_cache [meu_dono.serial]) then
					damage_cache [meu_dono.serial] = meu_dono
				end
			else
				if (who_flags) then --> ter certeza que não é um pet
					if (who_serial ~= "") then
						damage_cache [who_serial] = este_jogador
					else
						if (who_name:find ("%[")) then
							local _, _, icon = _GetSpellInfo (spellid or 1)
							este_jogador.spellicon = icon
							--print ("Spell Actor:", who_name)
						else
							--print ("No Serial Actor:", who_name)
						end
					end
				end
			end
			
		elseif (meu_dono) then
			--> é um pet
			who_name = who_name .. " <" .. meu_dono.nome .. ">"
		end
		
		--> his target
		local jogador_alvo, alvo_dono = damage_cache [alvo_serial] or damage_cache_pets [alvo_serial], damage_cache_petsOwners [alvo_serial]
		
		if (not jogador_alvo) then
		
			jogador_alvo, alvo_dono, alvo_name = _current_damage_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			
			if (alvo_dono) then
				damage_cache_pets [alvo_serial] = jogador_alvo
				damage_cache_petsOwners [alvo_serial] = alvo_dono
				--conferir se o dono já esta no cache
				if (not damage_cache [alvo_dono.serial]) then
					damage_cache [alvo_dono.serial] = alvo_dono
				end
			else
				if (alvo_flags) then --> ter certeza que não é um pet
					damage_cache [alvo_serial] = jogador_alvo
				end
			end
		
		elseif (alvo_dono) then
			--> é um pet
			alvo_name = alvo_name .. " <" .. alvo_dono.nome .. ">"
		
		end
		
		--> last event
		este_jogador.last_event = _tempo
		
	------------------------------------------------------------------------------------------------
	--> group checks and avoidance

		if (absorbed) then
			amount = absorbed + (amount or 0)
		end	
	
		if (este_jogador.grupo) then 
			_current_gtotal [1] = _current_gtotal [1]+amount
			
		elseif (jogador_alvo.grupo) then

			--> record avoidance only for tank actors
			if (tanks_members_cache [alvo_serial]) then --> autoshot or melee hit
				--> monk's stagger
				--[
				if (jogador_alvo.classe == "MONK") then
					if (absorbed) then
						amount = (amount or 0) - absorbed
					end
				end
				--]]
				
				--> avoidance
				local avoidance = jogador_alvo.avoidance
				if (not avoidance) then
					jogador_alvo.avoidance = _detalhes:CreateActorAvoidanceTable()
					avoidance = jogador_alvo.avoidance
				end
				
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
			
			--> record death log
			local t = last_events_cache [alvo_name]
			
			if (not t) then
				t = _current_combat:CreateLastEventsTable (alvo_name)
			end
			
			local i = t.n
			
			local this_event = t [i]
			
			if (not this_event) then
				print ("Parser Event Error -> Set to 16 DeathLogs and /reload", i, _death_event_amt)
			end
			
			this_event [1] = true --> true if this is a damage || false for healing
			this_event [2] = spellid --> spellid || false if this is a battle ress line
			this_event [3] = amount --> amount of damage or healing
			this_event [4] = time --> parser time
			this_event [5] = _UnitHealth (alvo_name) --> current unit heal
			this_event [6] = who_name --> source name
			this_event [7] = absorbed
			this_event [8] = school
			this_event [9] = false
			this_event [10] = overkill
			
			i = i + 1
			
			if (i == _death_event_amt+1) then
				t.n = 1
			else
				t.n = i
			end
			
		end
		
	------------------------------------------------------------------------------------------------
	--> time start 

		if (not este_jogador.dps_started) then
		
			este_jogador:Iniciar (true) --registra na timemachine
			
			if (meu_dono and not meu_dono.dps_started) then
				meu_dono:Iniciar (true)
				if (meu_dono.end_time) then
					meu_dono.end_time = nil
				else
					--meu_dono:IniciarTempo (_tempo)
					meu_dono.start_time = _tempo
				end
			end
			
			if (este_jogador.end_time) then
				este_jogador.end_time = nil
			else
				--este_jogador:IniciarTempo (_tempo)
				este_jogador.start_time = _tempo
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

		if (
			(
				(_bit_band (alvo_flags, REACTION_FRIENDLY) ~= 0 and _bit_band (who_flags, REACTION_FRIENDLY) ~= 0) or --ajdt d' brx
				(raid_members_cache [who_serial] and raid_members_cache [alvo_serial]) --amrl
			) 
			and 
				--spellid ~= 124255 --stagger
				spellid ~= 999997 --stagger
		) then
		
			--> record death log
			if (este_jogador.grupo) then --> se tiver ele não adiciona o evento lá em cima
				local t = last_events_cache [alvo_name]
				
				if (not t) then
					t = _current_combat:CreateLastEventsTable (alvo_name)
				end
				
				local i = t.n

				local this_event = t [i]
				
				this_event [1] = true --> true if this is a damage || false for healing
				this_event [2] = spellid --> spellid || false if this is a battle ress line
				this_event [3] = amount --> amount of damage or healing
				this_event [4] = time --> parser time
				this_event [5] = _UnitHealth (alvo_name) --> current unit heal
				this_event [6] = who_name --> source name
				this_event [7] = absorbed
				this_event [8] = school
				this_event [9] = true
				this_event [10] = overkill
				i = i + 1
				
				if (i == _death_event_amt+1) then
					t.n = 1
				else
					t.n = i
				end
			end
		
			--> faz a adição do friendly fire
			este_jogador.friendlyfire_total = este_jogador.friendlyfire_total + amount
			
			local friend = este_jogador.friendlyfire [alvo_name] or este_jogador:CreateFFTable (alvo_name)

			friend.total = friend.total + amount
			friend.spells [spellid] = (friend.spells [spellid] or 0) + amount
			
			------------------------------------------------------------------------------------------------
			--> damage taken 

				--> target
				jogador_alvo.damage_taken = jogador_alvo.damage_taken + amount - (absorbed or 0) --> adiciona o dano tomado
				if (not jogador_alvo.damage_from [who_name]) then --> adiciona a pool de dano tomado de quem
					jogador_alvo.damage_from [who_name] = true
				end

			return true
		else
			_current_total [1] = _current_total [1]+amount
			
			------------------------------------------------------------------------------------------------
			--> damage taken 

				--> target
				jogador_alvo.damage_taken = jogador_alvo.damage_taken + amount --> adiciona o dano tomado
				if (not jogador_alvo.damage_from [who_name]) then --> adiciona a pool de dano tomado de quem
					jogador_alvo.damage_from [who_name] = true
				end
		end
		
	------------------------------------------------------------------------------------------------
	--> amount add

		--> actor owner (if any)
		if (meu_dono) then --> se for dano de um Pet
			meu_dono.total = meu_dono.total + amount --> e adiciona o dano ao pet
			
			--> add owner targets
			meu_dono.targets [alvo_name] = (meu_dono.targets [alvo_name] or 0) + amount

			meu_dono.last_event = _tempo
		end

		--> actor
		este_jogador.total = este_jogador.total + amount
		
		--> actor without pets
		este_jogador.total_without_pet = este_jogador.total_without_pet + amount

		--> actor targets
		este_jogador.targets [alvo_name] = (este_jogador.targets [alvo_name] or 0) + amount
		
		--> actor spells table
		local spell = este_jogador.spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spells:PegaHabilidade (spellid, true, token)
			spell.spellschool = school
		end
		
		return spell_damage_func (spell, alvo_serial, alvo_name, alvo_flags, amount, who_name, resisted, blocked, absorbed, critical, glacing, token, multistrike, isoffhand)
	end

	--function parser:swingmissed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, missType, isOffHand, amountMissed)
	function parser:swingmissed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, missType, isOffHand, multistrike, amountMissed) --, isOffHand, multistrike, amountMissed, arg1
		return parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, 1, "Corpo-a-Corpo", 00000001, missType, isOffHand, multistrike, amountMissed) --, isOffHand, multistrike, amountMissed, arg1
	end

	function parser:rangemissed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, missType, isOffHand, multistrike, amountMissed) --, isOffHand, multistrike, amountMissed, arg1
		return parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, 2, "Tiro-Automático", 00000001, missType, isOffHand, multistrike, amountMissed) --, isOffHand, multistrike, amountMissed, arg1
	end

	-- ~miss
	function parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, missType, isOffHand, multistrike, amountMissed, arg1)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (not who_name) then
			--> no actor name, use spell name instead
			who_name = "[*] " .. spellname
		elseif (not who_name or not alvo_name) then
			return --> just return
		end

	------------------------------------------------------------------------------------------------
	--> get actors
		--print ("MISS", "|", missType, "|", isOffHand, "|", multistrike, "|", amountMissed, "|", arg1)
		
		--> 'misser'
		local este_jogador = damage_cache [who_serial]
		if (not este_jogador) then
			--este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (nil, who_name)
			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not este_jogador) then
				return --> just return if actor doen't exist yet
			end
		end

		if (tanks_members_cache [alvo_serial]) then --> only track tanks
		
			local TargetActor = damage_cache [alvo_serial]
			if (TargetActor) then
			
				local avoidance = TargetActor.avoidance
				
				if (not avoidance) then
					TargetActor.avoidance = _detalhes:CreateActorAvoidanceTable()
					avoidance = TargetActor.avoidance
				end

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
						overall ["ABSORB_AMT"] = overall ["ABSORB_AMT"] + (amountMissed or 0)
						overall ["FULL_ABSORB_AMT"] = overall ["FULL_ABSORB_AMT"] + (amountMissed or 0)
						
						mob ["ALL"] = mob ["ALL"] + 1  --> qualtipo de hit ou absorb
						mob ["FULL_ABSORBED"] = mob ["FULL_ABSORBED"] + 1 --amount
						mob ["ABSORB_AMT"] = mob ["ABSORB_AMT"] + (amountMissed or 0)
						mob ["FULL_ABSORB_AMT"] = mob ["FULL_ABSORB_AMT"] + (amountMissed or 0)
					end
					
				end

			end
		end
		
	------------------------------------------------------------------------------------------------
	--> amount add
		
		if (missType == "ABSORB") then
		
			if (token == "SWING_MISSED") then
				return parser:swing ("SWING_DAMAGE", time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, amountMissed, -1, 1, nil, nil, nil, false, false, false, false, multistrike)
				
			elseif (token == "RANGE_MISSED") then
				return parser:range ("RANGE_DAMAGE", time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amountMissed, -1, 1, nil, nil, nil, false, false, false, false, multistrike)
				
			else
				return parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amountMissed, -1, 1, nil, nil, nil, false, false, false, false, multistrike)
				
			end
		
		else
			--> actor spells table
			local spell = este_jogador.spells._ActorTable [spellid]
			if (not spell) then
				spell = este_jogador.spells:PegaHabilidade (spellid, true, token)
			end
			return spell_damageMiss_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, missType)		
		end
		

	end
	
-----------------------------------------------------------------------------------------------------------------------------------------
	--> SUMMON 	serach key: ~summon										|
-----------------------------------------------------------------------------------------------------------------------------------------
	function parser:summon (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellName)
	
		--[[statistics]]-- _detalhes.statistics.pets_summons = _detalhes.statistics.pets_summons + 1

		if (not _detalhes.capture_real ["damage"] and not _detalhes.capture_real ["heal"]) then
			return
		end
		
		if (not who_name) then
			who_name = "[*] " .. spellName
		end
	
		--> pet summon another pet
		local sou_pet = container_pets [who_serial]
		if (sou_pet) then --> okey, ja é um pet
			who_name, who_serial, who_flags = sou_pet[1], sou_pet[2], sou_pet[3]
		end
		
		local alvo_pet = container_pets [alvo_serial]
		if (alvo_pet) then
			who_name, who_serial, who_flags = alvo_pet[1], alvo_pet[2], alvo_pet[3]
		end
		
		--print ()

		_detalhes.tabela_pets:Adicionar (alvo_serial, alvo_name, alvo_flags, who_serial, who_name, who_flags)
		
		--print ("SUMMON", alvo_name, _detalhes.tabela_pets.pets, _detalhes.tabela_pets.pets [alvo_serial], alvo_serial)
		
		return
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--> HEALING 	serach key: ~heal											|
-----------------------------------------------------------------------------------------------------------------------------------------


	local gotit = {
		[140468]=true, --Flameglow Mage
		[122470]=true, --touch of karma Monk
		[114556]=true, --purgatory DK
		[152280]=true, --defile DK
		[20711]=true, --spirit of redeption priest
		[155783]=true, --Primal Tenacity Druid
		[135597]=true, --Tooth and Claw Druid
		[152261]=true, --Holy Shield Paladin
		[158708]=true, --Earthen Barrier boss?
	}

	local ignored_shields = {
		[142862] = true, -- Ancient Barrier (Malkorok)
		[114556] = true, -- Purgatory (DK)
		[115069] = true, -- Stance of the Sturdy Ox (Monk)
		[20711] = true, -- Spirit of Redemption (Priest)
	}
	
	local ignored_overheal = {
		[47753] = true, -- Divine Aegis
		[86273] = true, -- Illuminated Healing
		[114908] = true, --Spirit Shell
		[152118] = true, --Clarity of Will
	}
	
	function parser:heal_absorb (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, owner_serial, owner_name, owner_flags, owner_flags2, shieldid, shieldname, shieldtype, amount)
		
		--[[statistics]]-- _detalhes.statistics.absorbs_calls = _detalhes.statistics.absorbs_calls + 1
		
		if (not shieldname) then
			owner_serial, owner_name, owner_flags, owner_flags2, shieldid, shieldname, shieldtype, amount = spellid, spellname, spellschool, owner_serial, owner_name, owner_flags, owner_flags2, shieldid
		end
		
		if (ignored_shields [shieldid]) then
			return
		
		elseif (shieldid == 110913) then
			--dark bargain
			local max_health = _UnitHealthMax (owner_name)
			if ((amount or 0) > (max_health or 1) * 4) then
				return
			end
		end
		
		--if (not absorb_spell_list [shieldid] and not gotit[shieldid]) then
		--	local _, class = UnitClass (owner_name)
			--print ("Shield Not Registered:", shieldid, shieldname, class)
		--end
		
		--> diminuir o escudo nas tabelas de escudos
		local shields_on_target = escudo [alvo_name]
		if (shields_on_target) then
			local shields_by_spell = shields_on_target [shieldid]
			if (shields_by_spell) then
				local owner_shield = shields_by_spell [owner_name]
				if (owner_shield) then
					--print ("amt: ", owner_shield, owner_shield - amount, amount)
					shields_by_spell [owner_name] = owner_shield - amount
				end
			end
		end
		
		--> chamar a função de cura pra contar a cura
		return parser:heal (token, time, owner_serial, owner_name, owner_flags, alvo_serial, alvo_name, alvo_flags, shieldid, shieldname, shieldtype, amount, 0, 0, nil, nil, true)
		
	end

	function parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overhealing, absorbed, critical, multistrike, is_shield)
	
	------------------------------------------------------------------------------------------------
	--> early checks and fixes
	
		--> only capture heal if is in combat
		if (not _in_combat) then
			return
		end
	
		--> check invalid serial against pets
		if (who_serial == "") then
			if (who_flags and _bit_band (who_flags, OBJECT_TYPE_PETS) ~= 0) then --> é um pet
				return
			end
			--who_serial = nil
		end

		--> no name, use spellname
		if (not who_name) then
			who_name = "[*] "..spellname
		end

		--> no target, just ignore
		if (not alvo_name) then
			return
		end
		
		--> spirit link toten
		if (spellid == 98021) then
			return
		end
		
		--[[statistics]]-- _detalhes.statistics.heal_calls = _detalhes.statistics.heal_calls + 1
		
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
			--_current_combat.totals_grupo[2] = _current_combat.totals_grupo[2] + cura_efetiva
			_current_gtotal [2] = _current_gtotal [2] + cura_efetiva
		end
		
		if (jogador_alvo.grupo) then
		
			local t = last_events_cache [alvo_name]
			
			if (not t) then
				t = _current_combat:CreateLastEventsTable (alvo_name)
			end
			
			local i = t.n
			
			local this_event = t [i]
			
			this_event [1] = false --> true if this is a damage || false for healing
			this_event [2] = spellid --> spellid || false if this is a battle ress line
			this_event [3] = amount --> amount of damage or healing
			this_event [4] = time --> parser time
			this_event [5] = _UnitHealth (alvo_name) --> current unit heal
			this_event [6] = who_name --> source name
			this_event [7] = is_shield
			this_event [8] = absorbed
			
			i = i + 1
			
			if (i == _death_event_amt+1) then
				t.n = 1
			else
				t.n = i
			end
			
		end

	------------------------------------------------------------------------------------------------
	--> timer
		
		if (not este_jogador.iniciar_hps) then
		
			este_jogador:Iniciar (true) --inicia o hps do jogador
			
			if (meu_dono and not meu_dono.iniciar_hps) then
				meu_dono:Iniciar (true)
				if (meu_dono.end_time) then
					meu_dono.end_time = nil
				else
					--meu_dono:IniciarTempo (_tempo)
					meu_dono.start_time = _tempo
				end
			end
			
			if (este_jogador.end_time) then --> o combate terminou, reabrir o tempo
				este_jogador.end_time = nil
			else
				--este_jogador:IniciarTempo (_tempo)
				este_jogador.start_time = _tempo
			end
		end

	------------------------------------------------------------------------------------------------
	--> add amount
		
		--> actor target
	
		if (cura_efetiva > 0) then
		
			--> combat total
			_current_total [2] = _current_total [2] + cura_efetiva
			
			--> actor healing amount
			este_jogador.total = este_jogador.total + cura_efetiva	
			este_jogador.total_without_pet = este_jogador.total_without_pet + cura_efetiva
			
			--> healing taken 
			jogador_alvo.healing_taken = jogador_alvo.healing_taken + cura_efetiva --> adiciona o dano tomado
			if (not jogador_alvo.healing_from [who_name]) then --> adiciona a pool de dano tomado de quem
				jogador_alvo.healing_from [who_name] = true
			end

			if (is_shield) then
				este_jogador.totalabsorb = este_jogador.totalabsorb + cura_efetiva
				este_jogador.targets_absorbs [alvo_name] = (este_jogador.targets_absorbs [alvo_name] or 0) + cura_efetiva
			end

			--> pet
			if (meu_dono) then
				meu_dono.total = meu_dono.total + cura_efetiva --> heal do pet
				meu_dono.targets [alvo_name] = (meu_dono.targets [alvo_name] or 0) + amount
			end
			
			--> target amount
			este_jogador.targets [alvo_name] = (este_jogador.targets [alvo_name] or 0) + amount
		end
		
		if (meu_dono) then
			meu_dono.last_event = _tempo
		end
		
		if (overhealing > 0) then
			este_jogador.totalover = este_jogador.totalover + overhealing
			este_jogador.targets_overheal [alvo_name] = (este_jogador.targets_overheal [alvo_name] or 0) + overhealing
			
			if (meu_dono) then
				meu_dono.totalover = meu_dono.totalover + overhealing
			end
		end

		--> actor spells table
		local spell = este_jogador.spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spells:PegaHabilidade (spellid, true, token)
			if (is_shield) then
				spell.is_shield = true
			end
		end
		
		if (is_shield) then
			--return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, 0, 		  nil, 	     overhealing, true)
			return spell_heal_func (spell, alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, 0, 		  nil, 	     overhealing, true, multistrike)
		else
			--return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing)
			return spell_heal_func (spell, alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing, nil, multistrike)
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--> BUFFS & DEBUFFS 	serach key: ~buff ~aura ~shield								|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:buff (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount, arg1, arg2, arg3)

	--> not yet well know about unnamed buff casters
		if (not alvo_name) then
			alvo_name = "[*] Unknown shield target"
		elseif (not who_name) then 
			who_name = "[*] " .. spellname
		end 

	------------------------------------------------------------------------------------------------
	--> handle shields

		if (tipo == "BUFF") then
		
			--if (who_name == _detalhes.playername) then
			--	print (spellid, spellname)
			--end
			------------------------------------------------------------------------------------------------
			--> buff uptime
			
			--if (arg1 or arg2 or arg3) then
			--	print (spellname, arg1, arg2, arg3)
			--end
			
				if (_recording_buffs_and_debuffs) then
					-- jade spirit doesn't send who_name, that's a shame. 
					if (who_name == alvo_name and raid_members_cache [who_serial] and _in_combat) then
						--> call record buffs uptime
						parser:add_buff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "BUFF_UPTIME_IN")
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
				
					if (cc_spell_list [spellid]) then
						parser:add_cc_done (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
					end
				
					if (raid_members_cache [who_serial]) then
						--> call record debuffs uptime
						parser:add_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "DEBUFF_UPTIME_IN")
	
					elseif (raid_members_cache [alvo_serial] and not raid_members_cache [who_serial]) then --> alvo é da raide e who é alguem de fora da raide
						parser:add_bad_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, "DEBUFF_UPTIME_IN")
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
	
	function parser:add_cc_done (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
	
	------------------------------------------------------------------------------------------------
	--> early checks and fixes
		
		_current_misc_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors
		local este_jogador = misc_cache [who_name]
		if (not este_jogador) then
			este_jogador = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			misc_cache [who_name] = este_jogador
		end
		
	------------------------------------------------------------------------------------------------
	--> build containers on the fly
		
		if (not este_jogador.cc_done) then
			este_jogador.cc_done = _detalhes:GetOrderNumber()
			este_jogador.cc_done_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.cc_done_targets = {}
		end	

	------------------------------------------------------------------------------------------------
	--> add amount
		
		--> update last event
		este_jogador.last_event = _tempo
		
		--> add amount
		este_jogador.cc_done = este_jogador.cc_done + 1
		este_jogador.cc_done_targets [alvo_name] = (este_jogador.cc_done_targets [alvo_name] or 0) + 1
		
		--> actor spells table
		local spell = este_jogador.cc_done_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.cc_done_spells:PegaHabilidade (spellid, true)
		end
		
		spell.targets [alvo_name] = (spell.targets [alvo_name] or 0) + 1
		spell.counter = spell.counter + 1
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
						parser:add_buff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "BUFF_UPTIME_REFRESH")
					end
				end
		
			------------------------------------------------------------------------------------------------
			--> healing done (shields)
				if (absorb_spell_list [spellid] and _recording_healing and amount) then
					
					if (escudo [alvo_name] and escudo [alvo_name][spellid] and escudo [alvo_name][spellid][who_name]) then

						if (ignored_overheal [spellid]) then
							escudo [alvo_name][spellid][who_name] = amount -- refresh já vem o valor atualizado
							return
						end
						
						--escudo antigo é dropado, novo é posto
						local overheal = escudo [alvo_name][spellid][who_name]
						escudo [alvo_name][spellid][who_name] = amount
						
						if (overheal > 0) then
							return parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, nil, 0, _math_ceil (overheal), 0, 0, nil, true)
						end
					
						--local absorb = escudo [alvo_name][spellid][who_name] - amount
						--local overheal = amount - absorb
						--escudo [alvo_name][spellid][who_name] = amount
						
						--if (absorb > 0) then
							--return parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, nil, _math_ceil (absorb), _math_ceil (overheal), 0, 0, nil, true)
						--end
					else
						-- escudo não encontrado :(
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
						parser:add_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "DEBUFF_UPTIME_REFRESH")
					elseif (raid_members_cache [alvo_serial] and not raid_members_cache [who_serial]) then --> alvo é da raide e o caster é inimigo
						parser:add_bad_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, "DEBUFF_UPTIME_REFRESH")
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
						parser:add_buff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "BUFF_UPTIME_OUT")
					end
				end
		
			------------------------------------------------------------------------------------------------
			--> healing done (shields)
				if (absorb_spell_list [spellid] and _recording_healing) then
					if (escudo [alvo_name] and escudo [alvo_name][spellid] and escudo [alvo_name][spellid][who_name]) then
						if (amount) then
							-- o amount é o que sobrou do escudo
							
							local overheal = escudo [alvo_name][spellid][who_name]
							escudo [alvo_name][spellid][who_name] = 0

							if (overheal and overheal > 0) then
								return parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, nil, 0, _math_ceil (overheal), 0, 0, nil, true)
							else
								return
							end
							
						--- pre 6.0
							--local escudo_antigo = escudo [alvo_name][spellid][who_name] --> quantidade total do escudo que foi colocado
							
							--local absorb = escudo_antigo - amount
							--local overheal = escudo_antigo - absorb
							
							--escudo [alvo_name][spellid][who_name] = nil
							
							--return parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, nil, _math_ceil (absorb), _math_ceil (overheal), 0, 0, nil, true) --> último parametro IS_SHIELD
						end
						escudo [alvo_name][spellid][who_name] = 0
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
						parser:add_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, "DEBUFF_UPTIME_OUT")
					elseif (raid_members_cache [alvo_serial] and not raid_members_cache [who_serial]) then --> alvo é da raide e o caster é inimigo
						parser:add_bad_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, "DEBUFF_UPTIME_OUT")
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
				este_jogador.debuff_uptime_spells = container_habilidades:NovoContainer (container_misc)
				este_jogador.debuff_uptime_targets = {}
			end
		
		------------------------------------------------------------------------------------------------
		--> add amount
			
			--> update last event
			este_jogador.last_event = _tempo
			
			--> actor target
			local este_alvo = este_jogador.debuff_uptime_targets [alvo_name]
			if (not este_alvo) then
				este_alvo = _detalhes.atributo_misc:CreateBuffTargetObject()
				este_jogador.debuff_uptime_targets [alvo_name] = este_alvo
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

	-- ~debuff
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
			este_jogador.debuff_uptime_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.debuff_uptime_targets = {}
		end
	
	------------------------------------------------------------------------------------------------
	--> add amount
		
		--> update last event
		este_jogador.last_event = _tempo

		--> actor spells table
		local spell = este_jogador.debuff_uptime_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.debuff_uptime_spells:PegaHabilidade (spellid, true, "DEBUFF_UPTIME")
		end
		return spell_misc_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, este_jogador, "BUFF_OR_DEBUFF", in_out)
		
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
			este_jogador.buff_uptime_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.buff_uptime_targets = {}
		end	

	------------------------------------------------------------------------------------------------
	--> add amount
		
		--> update last event
		este_jogador.last_event = _tempo

		--> actor spells table
		local spell = este_jogador.buff_uptime_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.buff_uptime_spells:PegaHabilidade (spellid, true, "BUFF_UPTIME")
		end
		return spell_misc_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, este_jogador, "BUFF_OR_DEBUFF", in_out)
		
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--> ENERGY	serach key: ~energy												|
-----------------------------------------------------------------------------------------------------------------------------------------

	local energy_types = {
		[SPELL_POWER_MANA] = true,
		[SPELL_POWER_RAGE] = true,
		[SPELL_POWER_ENERGY] = true,
		[SPELL_POWER_RUNIC_POWER] = true,
	}
	
	local resource_types = {
		[SPELL_POWER_DEMONIC_FURY] = true, --warlock demonology
		[SPELL_POWER_BURNING_EMBERS] = true, --warlock destruction
		[SPELL_POWER_SHADOW_ORBS] = true, --shadow priest
		[SPELL_POWER_CHI] = true, --monk
		[SPELL_POWER_HOLY_POWER] = true, --paladins
		[SPELL_POWER_ECLIPSE] = true, --balance druids
		[SPELL_POWER_SOUL_SHARDS] = true, --warlock affliction
		[4] = true, --combo points
	}
	
	local resource_power_type = {
		[4] = SPELL_POWER_ENERGY, --combo points
		[SPELL_POWER_SOUL_SHARDS] = SPELL_POWER_MANA,
		[SPELL_POWER_ECLIPSE] = SPELL_POWER_MANA,
		[SPELL_POWER_HOLY_POWER] = SPELL_POWER_MANA,
		[SPELL_POWER_SHADOW_ORBS] = SPELL_POWER_MANA,
		[SPELL_POWER_DEMONIC_FURY] = SPELL_POWER_MANA,
		[SPELL_POWER_BURNING_EMBERS] = SPELL_POWER_MANA,
	}
	
	_detalhes.resource_strings = {
		[4] = "Combo Point",
		[SPELL_POWER_SOUL_SHARDS] = "Soul Shard",
		[SPELL_POWER_ECLIPSE] = "Eclipse",
		[SPELL_POWER_HOLY_POWER] = "Holy Power",
		[SPELL_POWER_SHADOW_ORBS] = "Shadow Orb",
		[SPELL_POWER_DEMONIC_FURY] = "Demonic Fury",
		[SPELL_POWER_BURNING_EMBERS] = "Burning Embers",
	}
	
	_detalhes.resource_icons = {
		[4] = {file = [[Interface\CHARACTERFRAME\ComboPoint]], coords = {1/32, 18/32, 1/16, 14/16}},
		[SPELL_POWER_SOUL_SHARDS] = {file = [[Interface\PLAYERFRAME\UI-WARLOCKSHARD]], coords = {2/64, 2/64, 17/128, 16/128}},
		[SPELL_POWER_ECLIPSE] = {file = [[Interface\PLAYERFRAME\DruidEclipse]], coords = {117/256, 138/256, 72/128, 113/128}},
		[SPELL_POWER_HOLY_POWER] = {file = [[Interface\PLAYERFRAME\PALADINPOWERTEXTURES]], coords = {75/256, 94/256, 87/128, 100/128}},
		[SPELL_POWER_SHADOW_ORBS] = {file = [[Interface\PLAYERFRAME\Priest-ShadowUI]], coords = {119/256, 150/256, 61/128, 94/128}},
		[SPELL_POWER_DEMONIC_FURY] = {file = [[Interface\PLAYERFRAME\Warlock-DemonologyUI]], coords = {76/256, 109/256, 90/256, 104/256}},
		[SPELL_POWER_BURNING_EMBERS] = {file = [[Interface\PLAYERFRAME\Warlock-DestructionUI]], coords = {3/256, 33/256, 23/64, 52/64}}
		}

	function parser:energize (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, powertype, p6, p7)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (not who_name) then
			who_name = "[*] "..spellname
		elseif (not alvo_name) then
			return
		end

	------------------------------------------------------------------------------------------------
	--> check if is energy or resource
	
		--> get resource type
		local is_resource, resource_amount, resource_id = resource_power_type [powertype], amount, powertype
	
		--> check if is valid
		if (not energy_types [powertype] and not is_resource) then
			return
		elseif (is_resource) then
			powertype = is_resource
			amount = 0
		end
		
		--[[statistics]]-- _detalhes.statistics.energy_calls = _detalhes.statistics.energy_calls + 1

		_current_energy_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors

		--> main actor
		local este_jogador, meu_dono = energy_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_energy_container:PegarCombatente (who_serial, who_name, who_flags, true)
			este_jogador.powertype = powertype
			if (meu_dono) then
				meu_dono.powertype = powertype
			end
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				energy_cache [who_name] = este_jogador
			end
		end
		
		--> target
		local jogador_alvo, alvo_dono = energy_cache [alvo_name]
		if (not jogador_alvo) then
			jogador_alvo, alvo_dono, alvo_name = _current_energy_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			jogador_alvo.powertype = powertype
			if (alvo_dono) then
				alvo_dono.powertype = powertype
			end
			if (not alvo_dono) then
				energy_cache [alvo_name] = jogador_alvo
			end
		end
		
		if (jogador_alvo.powertype ~= este_jogador.powertype) then
			--print ("error: different power types: who -> ", este_jogador.powertype, " target -> ", jogador_alvo.powertype)
			return
		end
		
		este_jogador.last_event = _tempo
		
	------------------------------------------------------------------------------------------------
	--> amount add
	
		if (not is_resource) then
		
			--> add to targets
			este_jogador.targets [alvo_name] = (este_jogador.targets [alvo_name] or 0) + amount
		
			--> add to combat total
			_current_total [3] [powertype] = _current_total [3] [powertype] + amount
		
			if (este_jogador.grupo) then 
				_current_gtotal [3] [powertype] = _current_gtotal [3] [powertype] + amount
			end

			--> regen produced amount
			este_jogador.total = este_jogador.total + amount
	
			--> target regenerated amount
			jogador_alvo.received = jogador_alvo.received + amount
		
			--> owner
			if (meu_dono) then
				meu_dono.total = meu_dono.total + amount
			end

			--> actor spells table
			local spell = este_jogador.spells._ActorTable [spellid]
			if (not spell) then
				spell = este_jogador.spells:PegaHabilidade (spellid, true, token)
			end
		
			--return spell:Add (alvo_serial, alvo_name, alvo_flags, amount, who_name, powertype)
			return spell_energy_func (spell, alvo_serial, alvo_name, alvo_flags, amount, who_name, powertype)
			
		else
			--> is a resource
			este_jogador.resource = este_jogador.resource + resource_amount
			este_jogador.resource_type = resource_id
		end
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
			este_jogador.cooldowns_defensive = _detalhes:GetOrderNumber (who_name)
			este_jogador.cooldowns_defensive_targets = {}
			este_jogador.cooldowns_defensive_spells = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades
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
			
				local damage_actor = damage_cache [who_serial]
				if (not damage_actor) then --> pode ser um desconhecido ou um pet
					damage_actor = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
					if (who_flags) then --> se não for um pet, adicionar no cache
						damage_cache [who_serial] = damage_actor
					end
				end

				--> last events
				local t = last_events_cache [who_name]
				
				if (not t) then
					t = _current_combat:CreateLastEventsTable (who_name)
				end
			
				local i = t.n
				local this_event = t [i]
				
				this_event [1] = 1 --> true if this is a damage || false for healing || 1 for cooldown
				this_event [2] = spellid --> spellid || false if this is a battle ress line
				this_event [3] = 1 --> amount of damage or healing
				this_event [4] = time --> parser time
				this_event [5] = _UnitHealth (who_name) --> current unit heal
				this_event [6] = who_name --> source name
				
				i = i + 1
				if (i == _death_event_amt+1) then
					t.n = 1
				else
					t.n = i
				end
				
				este_jogador.last_cooldown = {time, spellid}
				
			end
			
		end
		
		--> update last event
		este_jogador.last_event = _tempo
		
		--> actor targets
		este_jogador.cooldowns_defensive_targets [alvo_name] = (este_jogador.cooldowns_defensive_targets [alvo_name] or 0) + 1

		--> actor spells table
		local spell = este_jogador.cooldowns_defensive_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.cooldowns_defensive_spells:PegaHabilidade (spellid, true, token)
		end
		
		if (_hook_cooldowns) then
			--> send event to registred functions
			for _, func in _ipairs (_hook_cooldowns_container) do 
				func (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
			end
		end
		
		return spell_misc_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, token, "BUFF_OR_DEBUFF", "COOLDOWN")
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
			este_jogador.interrupt = _detalhes:GetOrderNumber (who_name)
			este_jogador.interrupt_targets = {}
			este_jogador.interrupt_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.interrompeu_oque = {}
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

		--> spells interrupted
		este_jogador.interrompeu_oque [extraSpellID] = (este_jogador.interrompeu_oque [extraSpellID] or 0) + 1

		--> actor targets
		este_jogador.interrupt_targets [alvo_name] = (este_jogador.interrupt_targets [alvo_name] or 0) + 1

		--> actor spells table
		local spell = este_jogador.interrupt_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.interrupt_spells:PegaHabilidade (spellid, true, token)
		end
		spell_misc_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
		
		--> verifica se tem dono e adiciona o interrupt para o dono
		if (meu_dono) then
			
			if (not meu_dono.interrupt) then
				meu_dono.interrupt = _detalhes:GetOrderNumber (who_name)
				meu_dono.interrupt_targets = {}
				meu_dono.interrupt_spells = container_habilidades:NovoContainer (container_misc)
				meu_dono.interrompeu_oque = {}
			end
			
			-- adiciona ao total
			meu_dono.interrupt = meu_dono.interrupt + 1
			
			-- adiciona aos alvos
			meu_dono.interrupt_targets [alvo_name] = (meu_dono.interrupt_targets [alvo_name] or 0) + 1
			
			-- update last event
			meu_dono.last_event = _tempo
			
			-- spells interrupted
			meu_dono.interrompeu_oque [extraSpellID] = (meu_dono.interrompeu_oque [extraSpellID] or 0) + 1
			
			--> pet interrupt
			if (_hook_interrupt) then
				for _, func in _ipairs (_hook_interrupt_container) do 
					func (nil, token, time, meu_dono.serial, meu_dono.nome, meu_dono.flag_original, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool)
				end
			end
		else
			--> player interrupt
			if (_hook_interrupt) then
				for _, func in _ipairs (_hook_interrupt_container) do 
					func (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool)
				end
			end
		end

	end
	
	--> search key: ~spellcast ~castspell ~cast
	function parser:spellcast (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype)

		--if (spellname == "Shield Block") then
		--	print (who_name, spellid, spellname)
		--end

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
			--> enemy successful casts (not interrupted)
			if (_bit_band (who_flags, 0x00000040) ~= 0 and who_name) then --> byte 2 = 4 (enemy)
				--> damager
				local este_jogador = damage_cache [who_serial]
				if (not este_jogador) then
					este_jogador = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
				end
				--> actor spells table
				local spell = este_jogador.spells._ActorTable [spellid]
				if (not spell) then
					spell = este_jogador.spells:PegaHabilidade (spellid, true, token)
				end
				spell.successful_casted = spell.successful_casted + 1
			end
			return
		end
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
	--> get actors]
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end

	------------------------------------------------------------------------------------------------
	--> build containers on the fly

		if (not este_jogador.dispell) then
			--> constrói aqui a tabela dele
			este_jogador.dispell = _detalhes:GetOrderNumber (who_name)
			este_jogador.dispell_targets = {}
			este_jogador.dispell_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.dispell_oque = {}
		end

	------------------------------------------------------------------------------------------------
	--> add amount

		--> last event update
		este_jogador.last_event = _tempo

		--> total dispells in combat
		_current_total [4].dispell = _current_total [4].dispell + 1
		
		if (este_jogador.grupo) then
			_current_gtotal [4].dispell = _current_gtotal [4].dispell + 1
		end

		--> actor dispell amount
		este_jogador.dispell = este_jogador.dispell + 1
		
		--> dispell what
		if (extraSpellID) then
			este_jogador.dispell_oque [extraSpellID] = (este_jogador.dispell_oque [extraSpellID] or 0) + 1
		end
		
		--> actor targets
		este_jogador.dispell_targets [alvo_name] = (este_jogador.dispell_targets [alvo_name] or 0) + 1

		--> actor spells table
		local spell = este_jogador.dispell_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.dispell_spells:PegaHabilidade (spellid, true, token)
		end
		spell_misc_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
		
		--> verifica se tem dono e adiciona o interrupt para o dono
		if (meu_dono) then
			if (not meu_dono.dispell) then
				meu_dono.dispell = _detalhes:GetOrderNumber (who_name)
				meu_dono.dispell_targets = {}
				meu_dono.dispell_spells = container_habilidades:NovoContainer (container_misc)
				meu_dono.dispell_oque = {}
			end
			
			meu_dono.dispell = meu_dono.dispell + 1

			meu_dono.dispell_targets [alvo_name] = (meu_dono.dispell_targets [alvo_name] or 0) + 1

			meu_dono.last_event = _tempo

			if (extraSpellID) then
				meu_dono.dispell_oque [extraSpellID] = (meu_dono.dispell_oque [extraSpellID] or 0) + 1
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
			este_jogador.ress = _detalhes:GetOrderNumber (who_name)
			este_jogador.ress_targets = {}
			este_jogador.ress_spells = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> update last event
		este_jogador.last_event = _tempo

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
						_table_insert (_current_combat.last_events_tables [i] [1], 1, {
							2,
							spellid, 
							1, 
							time, 
							_UnitHealth (alvo_name), 
							who_name 
						})
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
		este_jogador.ress_targets [alvo_name] = (este_jogador.ress_targets [alvo_name] or 0) + 1

		--> actor spells table
		local spell = este_jogador.ress_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.ress_spells:PegaHabilidade (spellid, true, token)
		end
		return spell_misc_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
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

		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end
		
	------------------------------------------------------------------------------------------------
	--> build containers on the fly
		
		if (not este_jogador.cc_break) then
			--> constrói aqui a tabela dele
			este_jogador.cc_break = _detalhes:GetOrderNumber (who_name)
			este_jogador.cc_break_targets = {}
			este_jogador.cc_break_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.cc_break_oque = {}
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> update last event
		este_jogador.last_event = _tempo

		--> combat cc break total
		_current_total [4].cc_break = _current_total [4].cc_break + 1

		if (este_jogador.grupo) then
			_current_combat.totals_grupo[4].cc_break = _current_combat.totals_grupo[4].cc_break+1
		end	

		--> add amount
		este_jogador.cc_break = este_jogador.cc_break + 1

		--> broke what
		este_jogador.cc_break_oque [spellid] = (este_jogador.cc_break_oque [spellid] or 0) + 1

		--> actor targets
		este_jogador.cc_break_targets [alvo_name] = (este_jogador.cc_break_targets [alvo_name] or 0) + 1

		--> actor spells table
		local spell = este_jogador.cc_break_spells._ActorTable [extraSpellID]
		if (not spell) then
			spell = este_jogador.cc_break_spells:PegaHabilidade (extraSpellID, true, token)
		end
		return spell_misc_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, token, spellid, spellname)
	end

	--serach key: ~dead ~death ~morte
	function parser:dead (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags)

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
				
				--> objeto da morte
				local esta_morte = {}
				
				--> add events
				local t = last_events_cache [alvo_name]
				if (not t) then
					t = _current_combat:CreateLastEventsTable (alvo_name)
				end
				
				--lesses index = older / higher index = newer
				
				local last_index = t.n --or 'next index'
				if (last_index < _death_event_amt+1 and not t[last_index][4]) then
					for i = 1, last_index-1 do
						if (t[i][4] and t[i][4]+_death_event_amt > time) then
							_table_insert (esta_morte, t[i])
						end
					end
				else
					for i = last_index, _death_event_amt do --next index to 16
						if (t[i][4] and t[i][4]+_death_event_amt > time) then
							_table_insert (esta_morte, t[i])
						end
					end
					for i = 1, last_index-1 do --1 to latest index
						if (t[i][4] and t[i][4]+_death_event_amt > time) then
							_table_insert (esta_morte, t[i])
						end
					end
				end

				if (_hook_deaths) then
					--> send event to registred functions
					local death_at = _GetTime() - _current_combat:GetStartTime()
					local max_health = _UnitHealthMax (alvo_name)

					for _, func in _ipairs (_hook_deaths_container) do 
						local new_death_table = table_deepcopy (esta_morte)
						func (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, new_death_table, este_jogador.last_cooldown, death_at, max_health)
					end
				end
				
				--if (_detalhes.deadlog_limit and #esta_morte > _detalhes.deadlog_limit) then
				--	while (#esta_morte > _detalhes.deadlog_limit) do
				--		_table_remove (esta_morte, 1)
				--	end
				--end
				
				if (este_jogador.last_cooldown) then
					local t = {}
					t [1] = 3 --> true if this is a damage || false for healing || 1 for cooldown usage || 2 for last cooldown
					t [2] = este_jogador.last_cooldown[2] --> spellid || false if this is a battle ress line
					t [3] = 1 --> amount of damage or healing
					t [4] = este_jogador.last_cooldown[1] --> parser time
					t [5] = 0 --> current unit heal
					t [6] = alvo_name --> source name
					esta_morte [#esta_morte+1] = t
				else
					local t = {}
					t [1] = 3 --> true if this is a damage || false for healing || 1 for cooldown usage || 2 for last cooldown
					t [2] = 0 --> spellid || false if this is a battle ress line
					t [3] = 0 --> amount of damage or healing
					t [4] = 0 --> parser time
					t [5] = 0 --> current unit heal
					t [6] = alvo_name --> source name
					esta_morte [#esta_morte+1] = t
				end
				
				local decorrido = _GetTime() - _current_combat:GetStartTime()
				local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
				
				local t = {esta_morte, time, este_jogador.nome, este_jogador.classe, _UnitHealthMax (alvo_name), minutos.."m "..segundos.."s",  ["dead"] = true, ["last_cooldown"] = este_jogador.last_cooldown, ["dead_at"] = decorrido}
				
				_table_insert (_current_combat.last_events_tables, #_current_combat.last_events_tables+1, t)

				--> reseta a pool
				last_events_cache [alvo_name] = nil
			end
		end
	end

	function parser:environment (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, env_type, amount)
	
		local spelid
	
		if (env_type == "Falling") then
			who_name = ENVIRONMENTAL_FALLING_NAME
			spelid = 3
		elseif (env_type == "Drowning") then
			who_name = ENVIRONMENTAL_DROWNING_NAME
			spelid = 4
		elseif (env_type == "Fatigue") then
			who_name = ENVIRONMENTAL_FATIGUE_NAME
			spelid = 5
		elseif (env_type == "Fire") then
			who_name = ENVIRONMENTAL_FIRE_NAME
			spelid = 6
		elseif (env_type == "Lava") then
			who_name = ENVIRONMENTAL_LAVA_NAME
			spelid = 7
		elseif (env_type == "Slime") then
			who_name = ENVIRONMENTAL_SLIME_NAME
			spelid = 8
		end
	
		return parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spelid or 1, env_type, 00000003, amount, -1, 1) --> localize-me
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
			token_list ["SPELL_BUILDING_MISSED"] = nil
			token_list ["SPELL_PERIODIC_MISSED"] = nil
			token_list ["DAMAGE_SHIELD_MISSED"] = nil
			token_list ["ENVIRONMENTAL_DAMAGE"] = nil
			token_list ["SPELL_BUILDING_DAMAGE"] = nil
		
		elseif (capture_type == "heal") then
			token_list ["SPELL_HEAL"] = nil
			token_list ["SPELL_PERIODIC_HEAL"] = nil
			token_list ["SPELL_ABSORBED"] = nil
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

	--SPELL_DRAIN --> need research
	--SPELL_LEECH --> need research
	--SPELL_PERIODIC_DRAIN --> need research
	--SPELL_PERIODIC_LEECH --> need research
	--SPELL_DISPEL_FAILED --> need research
	--SPELL_BUILDING_HEAL --> need research
	
	function _detalhes:CaptureEnable (capture_type)

		capture_type = string.lower (capture_type)
		
		if (capture_type == "damage") then
			token_list ["SPELL_PERIODIC_DAMAGE"] = parser.spell_dmg
			token_list ["SPELL_EXTRA_ATTACKS"] = parser.spell_dmg
			token_list ["SPELL_DAMAGE"] = parser.spell_dmg
			token_list ["SPELL_BUILDING_DAMAGE"] = parser.spell_dmg
			token_list ["SWING_DAMAGE"] = parser.swing
			token_list ["RANGE_DAMAGE"] = parser.range
			token_list ["DAMAGE_SHIELD"] = parser.spell_dmg
			token_list ["DAMAGE_SPLIT"] = parser.spell_dmg
			token_list ["RANGE_MISSED"] = parser.rangemissed
			token_list ["SWING_MISSED"] = parser.swingmissed
			token_list ["SPELL_MISSED"] = parser.missed
			token_list ["SPELL_PERIODIC_MISSED"] = parser.missed
			token_list ["SPELL_BUILDING_MISSED"] = parser.missed
			token_list ["DAMAGE_SHIELD_MISSED"] = parser.missed
			token_list ["ENVIRONMENTAL_DAMAGE"] = parser.environment

		elseif (capture_type == "heal") then
			token_list ["SPELL_HEAL"] = parser.heal
			token_list ["SPELL_PERIODIC_HEAL"] = parser.heal
			token_list ["SPELL_ABSORBED"] = parser.heal_absorb
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
		
		_detalhes.zone_type = zoneType
		_detalhes.zone_id = zoneMapID
		_detalhes.zone_name = zoneName
		
		if (_detalhes.last_zone_type ~= zoneType) then
			_detalhes:SendEvent ("ZONE_TYPE_CHANGED", nil, zoneType)
			_detalhes.last_zone_type = zoneType
		end
		
		_detalhes:CheckChatOnZoneChange (zoneType)
		
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) zone change:", _detalhes.zone_name, "is a", _detalhes.zone_type, "zone.")
		end
		
		if (_detalhes.is_in_arena and zoneType ~= "arena") then
			_detalhes:LeftArena()
		end
		if (_detalhes.is_in_battleground and zoneType ~= "pvp") then
			_detalhes.is_in_battleground = nil
		end
		
		if (zoneType == "pvp") then

			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) battleground found.")
			end
			
			_detalhes.is_in_battleground = true
			
			if (_in_combat and not _current_combat.pvp) then
				_detalhes:SairDoCombate()
			end
			
			if (not _in_combat) then
				_detalhes:EntrarEmCombate()
				_current_combat.pvp = true
				_current_combat.is_pvp = {name = zoneName, mapid = ZoneMapID}
			end
		
		elseif (zoneType == "arena") then
		
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) zone type is arena.")
			end
		
			_detalhes.is_in_arena = true
			_detalhes:EnteredInArena()
			
		else
			if ((zoneType == "raid" or zoneType == "party") and select (1, IsInInstance())) then
				_detalhes:CheckForAutoErase (zoneMapID)
			end
		
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
	
	-- ~encounter
	function _detalhes.parser_functions:ENCOUNTER_START (...)
	
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) ENCOUNTER_START event triggered.")
		end
	
		_detalhes.latest_ENCOUNTER_END = _detalhes.latest_ENCOUNTER_END or 0
		if (_detalhes.latest_ENCOUNTER_END + 10 > _GetTime()) then
			return
		end
	
		local encounterID, encounterName, difficultyID, raidSize = _select (1, ...)
	
		if (_in_combat and not _detalhes.tabela_vigente.is_boss) then
			_detalhes:SairDoCombate()
			--_detalhes:Msg ("encounter against|cFFFFFF00", encounterName, "|rbegan, GL HF!")
		else
			--_detalhes:Msg ("encounter against|cFFFFC000", encounterName, "|rbegan, GL HF!")
		end
	
		local dbm_mod, dbm_time = _detalhes.encounter_table.DBM_Mod, _detalhes.encounter_table.DBM_ModTime
		_table_wipe (_detalhes.encounter_table)
		
		local encounterID, encounterName, difficultyID, raidSize = _select (1, ...)
		local zoneName, _, _, _, _, _, _, zoneMapID = _GetInstanceInfo()
		
		--print (encounterID, encounterName, difficultyID, raidSize)
		_detalhes.encounter_table.phase = 1
		
		--_detalhes.encounter_table ["start"] = time()
		_detalhes.encounter_table ["start"] = _GetTime()
		_detalhes.encounter_table ["end"] = nil
		
		_detalhes.encounter_table.id = encounterID
		_detalhes.encounter_table.name = encounterName
		_detalhes.encounter_table.diff = difficultyID
		_detalhes.encounter_table.size = raidSize
		_detalhes.encounter_table.zone = zoneName
		_detalhes.encounter_table.mapid = zoneMapID
		
		if (dbm_mod and dbm_time == time()) then --pode ser time() é usado no start pra saber se foi no mesmo segundo.
			_detalhes.encounter_table.DBM_Mod = dbm_mod
		end
		
		local encounter_start_table = _detalhes:GetEncounterStartInfo (zoneMapID, encounterID)
		if (encounter_start_table) then
			if (encounter_start_table.delay) then
				if (type (encounter_start_table.delay) == "function") then
					local delay = encounter_start_table.delay()
					if (delay) then
						--_detalhes.encounter_table ["start"] = time() + delay
						_detalhes.encounter_table ["start"] = _GetTime() + delay
					end
				else
					--_detalhes.encounter_table ["start"] = time() + encounter_start_table.delay
					_detalhes.encounter_table ["start"] = _GetTime() + encounter_start_table.delay
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
	
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) ENCOUNTER_END event triggered.")
		end
	
		local encounterID, encounterName, difficultyID, raidSize, endStatus = _select (1, ...)
	
		--_detalhes:Msg ("encounter against|cFFFFC000", encounterName, "|rended.")
	
		if (not _detalhes.encounter_table.start) then
			return
		end
		
		_detalhes.latest_ENCOUNTER_END = _detalhes.latest_ENCOUNTER_END or 0
		if (_detalhes.latest_ENCOUNTER_END + 15 > _GetTime()) then
			return
		end
		--_detalhes.latest_ENCOUNTER_END = _detalhes._tempo
		_detalhes.latest_ENCOUNTER_END = _GetTime()
		
		--_detalhes.encounter_table ["end"] = time() - 0.4
		_detalhes.encounter_table ["end"] = _GetTime() -- 0.351
		
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
			if ((_detalhes.tabela_vigente:GetEndTime() or 0) + 2 >= _detalhes.encounter_table ["end"]) then
				_detalhes.tabela_vigente:SetEndTime (_detalhes.encounter_table ["end"])
				_detalhes:AtualizaGumpPrincipal (-1, true)
			end
		end

		_table_wipe (_detalhes.encounter_table)
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
		
		if (_detalhes.schedule_store_boss_encounter) then
			if (not _detalhes.logoff_saving_data) then
				--_detalhes.StoreEncounter()
				local successful, errortext = pcall (_detalhes.StoreEncounter)
				if (not successful) then
					_detalhes:Msg ("error occurred on StoreEncounter():", errortext)
				end
			end
			_detalhes.schedule_store_boss_encounter = nil
		end
		
		if (_detalhes.schedule_boss_function_run) then
			if (not _detalhes.logoff_saving_data) then
				local successful, errortext = pcall (_detalhes.schedule_boss_function_run, _detalhes.tabela_vigente)
				if (not successful) then
					_detalhes:Msg ("error occurred on Encounter Boss Function:", errortext)
				end
			end
			_detalhes.schedule_boss_function_run = nil
		end
		
		if (_detalhes.schedule_hard_garbage_collect) then
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) found schedule collectgarbage().")
			end
			_detalhes.schedule_hard_garbage_collect = false
			collectgarbage()
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
		
		elseif (_detalhes.is_in_battleground) then
			
			local timerType, timeSeconds, totalTime = select (1, ...)
			
			if (_detalhes.start_battleground) then
				_detalhes:CancelTimer (_detalhes.start_battleground, true)
			end
			
			_detalhes.start_battleground = _detalhes:ScheduleTimer ("CreateBattlegroundSegment", timeSeconds)

		end
	end
	
	function _detalhes:CreateBattlegroundSegment()
		_current_combat:SetStartTime (_GetTime())
		print ("Battleground has begun.")
	end

	-- ~load
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
		
			--> write into details object all basic keys and default profile
			_detalhes:ApplyBasicKeys()
			--> check if is first run, update keys for character and global data
			_detalhes:LoadGlobalAndCharacterData()
			
			--> details updated and not reopened the game client
			if (_detalhes.FILEBROKEN) then
				return
			end
			
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

	--> logout function ~save ~logout
	
	local saver = CreateFrame ("frame", nil, UIParent)
	saver:RegisterEvent ("PLAYER_LOGOUT")
	saver:SetScript ("OnEvent", function (...)
		
		local saver_error = function (errortext)
			_detalhes_global = _detalhes_global or {}
			_detalhes_global.exit_errors = _detalhes_global.exit_errors or {}
			
			tinsert (_detalhes_global.exit_errors, 1, _detalhes.userversion .. " " .. errortext)
			tremove (_detalhes_global.exit_errors, 6)
		end
		
		_detalhes_global.exit_log = {}
		
		_detalhes.saver_error_func = saver_error
		
		_detalhes.logoff_saving_data = true
	
		--> close info window
			if (_detalhes.FechaJanelaInfo) then
				tinsert (_detalhes_global.exit_log, "1 - Closing Janela Info.")
				xpcall (_detalhes.FechaJanelaInfo, saver_error)
			end
			
		--> do not save window pos
			if (_detalhes.tabela_instancias) then
				tinsert (_detalhes_global.exit_log, "2 - Clearing user place from instances.")
				for id, instance in _detalhes:ListInstances() do
					if (instance.baseframe) then
						instance.baseframe:SetUserPlaced (false)
						instance.baseframe:SetDontSavePosition (true)
					end
				end
			end

		--> leave combat start save tables
			if (_detalhes.in_combat and _detalhes.tabela_vigente) then 
				tinsert (_detalhes_global.exit_log, "3 - Leaving current combat.")
				xpcall (_detalhes.SairDoCombate, saver_error)
				_detalhes.can_panic_mode = true
			end
			
			if (_detalhes.CheckSwitchOnLogon and _detalhes.tabela_instancias[1] and _detalhes.tabela_instancias and getmetatable (_detalhes.tabela_instancias[1])) then
				tinsert (_detalhes_global.exit_log, "4 - Reversing switches.")
				xpcall (_detalhes.CheckSwitchOnLogon, saver_error)
			end
			
			if (_detalhes.wipe_full_config) then
				tinsert (_detalhes_global.exit_log, "5 - Is a full config wipe.")
				_detalhes_global = nil
				_detalhes_database = nil
				return
			end
		
		--> save the config
			tinsert (_detalhes_global.exit_log, "6 - Saving Config.")
			xpcall (_detalhes.SaveConfig, saver_error)
			tinsert (_detalhes_global.exit_log, "7 - Saving Profiles.")
			xpcall (_detalhes.SaveProfile, saver_error)

		--> save the nicktag cache
			tinsert (_detalhes_global.exit_log, "8 - Saving nicktag cache.")
			_detalhes_database.nick_tag_cache = table_deepcopy (_detalhes_database.nick_tag_cache)
	end)
		
	--> end
	
	-- ~parserstart ~startparser
	function _detalhes:OnParserEvent (evento, time, token, hidding, who_serial, who_name, who_flags, who_flags2, alvo_serial, alvo_name, alvo_flags, alvo_flags2, ...)
		local funcao = token_list [token]

		if (funcao) then
			--if (token ~= "SPELL_AURA_REFRESH" and token ~= "SPELL_AURA_REMOVED" and token ~= "SPELL_AURA_APPLIED") then
			--	print ("running func:", token)
			--end
			return funcao (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, ... )
		else
			return
		end
		
	end
	_detalhes.parser_frame:SetScript ("OnEvent", _detalhes.OnParserEvent)

	function _detalhes:UpdateParser()
		_tempo = _detalhes._tempo
	end
	function _detalhes:UpdatePetsOnParser()
		container_pets = _detalhes.tabela_pets.pets
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
		
		--> last events pointer
		last_events_cache = _current_combat.player_last_events
		_death_event_amt = _detalhes.deadlog_events

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
		
		if (_detalhes.hooks ["HOOK_BATTLERESS"].enabled) then
			_hook_battleress = true
		else
			_hook_battleress = false
		end
		
		if (_detalhes.hooks ["HOOK_INTERRUPT"].enabled) then
			_hook_interrupt = true
		else
			_hook_interrupt = false
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
