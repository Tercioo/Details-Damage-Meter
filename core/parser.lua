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

	local _UnitAffectingCombat = UnitAffectingCombat --wow api local
	local _UnitHealth = UnitHealth --wow api local
	local _UnitHealthMax = UnitHealthMax --wow api local
	local _UnitIsFeignDeath = UnitIsFeignDeath --wow api local
	local _GetInstanceInfo = GetInstanceInfo --wow api local

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

	local escudo = _detalhes.escudos --details local
	local parser = _detalhes.parser --details local
	local absorb_spell_list = _detalhes.AbsorbSpells --details local
	local cc_spell_list = _detalhes.CrowdControlSpells --details local
	local container_combatentes = _detalhes.container_combatentes --details local
	local container_habilidades = _detalhes.container_habilidades --details local
	
	--> current combat and overall pointers
		local _current_combat = _detalhes.tabela_vigente or {} --> placeholder table
		local _overall_combat = _detalhes.tabela_overall or {} --> placeholder table
	--> total container pointers
		local _current_total = _current_combat.totals
		local _current_gtotal = _current_combat.totals_grupo
		local _overall_total = _overall_combat.totals
		local _overall_gtotal = _overall_combat.totals_grupo
	--> actors container pointers
		local _current_damage_container = _current_combat [1]
		local _overall_damage_container = _overall_combat [1]
		local _current_heal_container = _current_combat [2]
		local _overall_heal_container = _overall_combat [2]
		local _current_energy_container = _current_combat [3]
		local _overall_energy_container = _overall_combat [3]
		local _current_misc_container = _current_combat [4]
		local _overall_misc_container = _overall_combat [4]

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> cache
	--> damage
		local damage_cache = {}
	--> heaing
		local healing_cache = {}
	--> energy
		local energy_cache = {}
	--> misc
		local misc_cache = {}
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS
	local container_misc = _detalhes.container_type.CONTAINER_MISC_CLASS

	local OBJECT_TYPE_PLAYER = 0x00000400
	local OBJECT_TYPE_PETS = 0x00003000
	local AFFILIATION_GROUP = 0x00000007
	local REACTION_FRIENDLY = 0x00000010 
	
	--> recording data options shortcuts
		local _recording_self_buffs = false
		local _recording_ability_with_buffs = false
		local _recording_took_damage = false
	--> in combat shortcut
		local _in_combat = false
	


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
			if (		token ~= "SPELL_PERIODIC_DAMAGE" and 
				( 
					( _bit_band (who_flags, AFFILIATION_GROUP) ~= 0 and _UnitAffectingCombat (who_name) )
					or 
					(_bit_band (alvo_flags, AFFILIATION_GROUP) ~= 0 and _UnitAffectingCombat (alvo_name) ) 
				)) then 
				
				--> não entra em combate se for DOT
				_detalhes:EntrarEmCombate (who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags)
			end
		end
		
		_current_damage_container.need_refresh = true
		_overall_damage_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors
	
		--> damager
		local este_jogador, meu_dono = damage_cache [who_name]
		
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
		
			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
			
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				--> fazer: precisa ser com cache
				local search = _detalhes.tabela_pets.pets [who_serial]
				if (not search) then --> make sure isn't a pet
					damage_cache [who_name] = este_jogador
				end
			end
		end
		
		--> his target
		local jogador_alvo, alvo_dono = damage_cache [alvo_name]
		if (not jogador_alvo) then
			jogador_alvo, alvo_dono, alvo_name = _current_damage_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			--> fazer: precisa ser com cache
			if (not alvo_dono and not _detalhes.tabela_pets.pets [alvo_serial]) then
				damage_cache [alvo_name] = jogador_alvo
			end
		end
		
		--> damager shadow
		local shadow = este_jogador.shadow
		local shadow_of_target = jogador_alvo.shadow
		
		--> last event
		este_jogador.last_event = _tempo
		shadow.last_event = _tempo	
		
	------------------------------------------------------------------------------------------------
	--> group checks and avoidance

		if (este_jogador.grupo) then 
			_current_gtotal [1] = _current_gtotal [1]+amount
			_overall_gtotal [1] = _overall_gtotal [1]+amount
			
		elseif (jogador_alvo.grupo) then
		
			--> record death log
			local t = jogador_alvo.last_events_table
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
			if (spellid < 3) then --> autoshot melee
				jogador_alvo.avoidance ["HITS"] = jogador_alvo.avoidance ["HITS"] + 1
			end
		end
		
	------------------------------------------------------------------------------------------------
	--> damage taken 

		--> target
		jogador_alvo.damage_taken = jogador_alvo.damage_taken + amount --> adiciona o dano tomado
		if (not jogador_alvo.damage_from [who_name]) then --> adiciona a pool de dano tomado de quem
			jogador_alvo.damage_from [who_name] = true
		end
		
		--> his shadow
		shadow_of_target.damage_taken = shadow_of_target.damage_taken + amount --> adiciona o dano tomado
		if (not shadow_of_target.damage_from [who_name]) then --> adiciona a pool de dano tomado de quem
			shadow_of_target.damage_from [who_name] = true
		end
		
	------------------------------------------------------------------------------------------------
	--> time start 

		if (not este_jogador.dps_started) then
		
			este_jogador:Iniciar (true)
			
			if (meu_dono and not meu_dono.dps_started) then
				meu_dono:Iniciar (true)
				if (meu_dono.end_time) then
					meu_dono.end_time = nil
					meu_dono.shadow.end_time = nil
				else
					meu_dono:IniciarTempo (_tempo-3.0, meu_dono.shadow)
				end
			end
			
			if (este_jogador.end_time) then
				este_jogador.end_time = nil
				shadow.end_time = nil
			else
				este_jogador:IniciarTempo (_tempo-3.0, shadow)
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

		if (_bit_band (who_flags, REACTION_FRIENDLY) ~= 0 and _bit_band (alvo_flags, REACTION_FRIENDLY) ~= 0) then
		
			--> investigation about mind control and reaction switch done 
			--> details will do count mind control and reaction switch as normal damage.
			--> reaction switch normally came as 0x548 flag on players and 0x1148 for pets.
		
			este_jogador.friendlyfire_total = este_jogador.friendlyfire_total + amount
			shadow.friendlyfire_total = shadow.friendlyfire_total + amount
			
			local amigo = este_jogador.friendlyfire._NameIndexTable [alvo_name]
			if (not amigo) then
				amigo = este_jogador.friendlyfire:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			else
				amigo = este_jogador.friendlyfire._ActorTable [amigo]
			end

			amigo.total = amigo.total + amount
			amigo.shadow.total = amigo.shadow.total + amount

			local spell = amigo.spell_tables._ActorTable [spellid]
			if (not spell) then
				spell = amigo.spell_tables:PegaHabilidade (spellid, true, token)
			end

			return spell:AddFF (amount) --adiciona a classe da habilidade, a classe da habilidade se encarrega de adicionar aos alvos dela
		else
			_current_total [1] = _current_total [1]+amount
			_overall_total [1] = _overall_total [1]+amount
			
		end
		
	------------------------------------------------------------------------------------------------
	--> amount add
		
		--> actor owner (if any)
		if (meu_dono) then --> se for dano de um Pet
			meu_dono.total = meu_dono.total + amount --> e adiciona o dano ao pet
			meu_dono.shadow.total = meu_dono.shadow.total + amount --> e adiciona o dano ao pet
		end

		--> actor
		este_jogador.total = este_jogador.total + amount
		shadow.total = shadow.total + amount
		
		--> actor without pets
		este_jogador.total_without_pet = este_jogador.total_without_pet + amount
		shadow.total_without_pet = shadow.total_without_pet + amount

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
		
		return spell:Add (alvo_serial, alvo_name, alvo_flags, amount, who_name, resisted, blocked, absorbed, critical, glacing, token)
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
			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (_, who_name)
			if (not este_jogador) then
				return --> just return if actor doen't exist yet
			end
		end

		--> 'avoider'
		--> using this method means avoidance of pets will not be tracked
		local TargetActor = damage_cache [alvo_name]
		if (TargetActor) then
			local missTable = TargetActor.avoidance [missType]
			if (missTable) then
				TargetActor.avoidance [missType] = missTable +1
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

		local sou_pet = _detalhes.tabela_pets.pets [who_serial]
		if (sou_pet) then --> okey, ja é um pet
			--print ("PET sumonando PET: who_name -> " .. who_name .. " meu dono -> "..sou_pet[1])
			who_name, who_serial, who_flags = sou_pet[1], sou_pet[2], sou_pet[3]
		end
		
		local alvo_pet = _detalhes.tabela_pets.pets [alvo_serial]
		if (alvo_pet) then
			--print ("PET ALVO sumonando PET ALVO: who_name -> " .. who_name .. " meu dono -> "..sou_pet[1])
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
		
		--> checking shield and overheals
		local cura_efetiva = absorbed
		if (is_shield) then 
			cura_efetiva = amount
		else
			cura_efetiva = amount - overhealing
		end
		
		_current_heal_container.need_refresh = true
		_overall_heal_container.need_refresh = true
		
	------------------------------------------------------------------------------------------------
	--> get actors

		local este_jogador, meu_dono = healing_cache [who_name]
		if (not este_jogador) then --> pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_heal_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --> se não for um pet, adicionar no cache
				healing_cache [who_name] = este_jogador
			end
		end

		local jogador_alvo, alvo_dono = healing_cache [alvo_name]
		if (not jogador_alvo) then
			jogador_alvo, alvo_dono, alvo_name = _current_heal_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			if (not alvo_dono) then
				healing_cache [alvo_name] = jogador_alvo
			end
		end
		
		local shadow = este_jogador.shadow
		local shadow_of_target = jogador_alvo.shadow
		
		este_jogador.last_event = _tempo
		shadow.last_event = _tempo

	------------------------------------------------------------------------------------------------
	--> an enemy healing enemy or an player actor healing a enemy

		if (_bit_band (alvo_flags, REACTION_FRIENDLY) == 0) then
			if (not este_jogador.heal_enemy [spellid]) then 
				este_jogador.heal_enemy [spellid] = cura_efetiva
			else
				este_jogador.heal_enemy [spellid] = este_jogador.heal_enemy [spellid] + cura_efetiva
			end
			
			if (not este_jogador.shadow.heal_enemy [spellid]) then 
				este_jogador.shadow.heal_enemy [spellid] = cura_efetiva
			else
				este_jogador.shadow.heal_enemy [spellid] = este_jogador.shadow.heal_enemy [spellid] + cura_efetiva
			end
			
			return
		end	
		
	------------------------------------------------------------------------------------------------
	--> group checks

		if (este_jogador.grupo) then 
			_current_combat.totals_grupo[2] = _current_combat.totals_grupo[2]+amount
			_overall_combat.totals_grupo[2] = _overall_combat.totals_grupo[2]+amount	
		end
		
		if (jogador_alvo.grupo) then
		
			local t = jogador_alvo.last_events_table
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
				shadow.end_time = nil --> não tenho certeza se isso aqui não pode dar merda
			else
				este_jogador:IniciarTempo (_tempo-3.0, shadow)
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
			_overall_total [2] = _overall_total [2] + cura_efetiva
		
			--> healing taken 
			jogador_alvo.healing_taken = jogador_alvo.healing_taken + cura_efetiva --> adiciona o dano tomado
			if (not jogador_alvo.healing_from [who_name]) then --> adiciona a pool de dano tomado de quem
				jogador_alvo.healing_from [who_name] = true
			end
			
			--> healing taken shadow
			shadow_of_target.healing_taken = shadow_of_target.healing_taken+cura_efetiva --> adiciona o dano tomado
			if (not shadow_of_target.healing_from [who_name]) then --> adiciona a pool de dano tomado de quem
				shadow_of_target.healing_from [who_name] = true
			end
			
			--> actor healing amount
			este_jogador.total = este_jogador.total + cura_efetiva
			shadow.total = shadow.total + cura_efetiva

			este_jogador.total_without_pet = este_jogador.total_without_pet + cura_efetiva
			shadow.total_without_pet = shadow.total_without_pet + cura_efetiva
			
			--> pet
			if (meu_dono) then
				meu_dono.total = meu_dono.total + cura_efetiva --> e adiciona o dano ao pet
				meu_dono.shadow.total = meu_dono.shadow.total + cura_efetiva --> e adiciona o dano ao pet
			end
			
			--> target amount
			este_alvo.total = este_alvo.total + cura_efetiva
		end
		
		if (overhealing > 0) then
			este_jogador.totalover = este_jogador.totalover + overhealing
			shadow.totalover = shadow.totalover + overhealing
			este_alvo.overheal = este_alvo.overheal + overhealing
			if (meu_dono) then
				meu_dono.totalover = meu_dono.totalover + overhealing
				meu_dono.shadow.totalover = meu_dono.shadow.totalover + overhealing
			end
		end

		--> actor spells table
		local spell = este_jogador.spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spell_tables:PegaHabilidade (spellid, true, token)
		end
		
		if (is_shield) then
			return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, 0, 		  nil, 	     overhealing, true)
		else
			return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing)
		end
	end


	
-----------------------------------------------------------------------------------------------------------------------------------------
	--> BUFFS & DEBUFFS 	serach key: ~buff										|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:buff (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, _, tipo, amount)

	--> not yet well know about unnamed buff casters
		if (not alvo_name) then
			alvo_name = "[*] Unknow shield target"
		elseif (not who_name) then 
			who_name = "[*] Unknow shield caster"
		end 

	------------------------------------------------------------------------------------------------
	--> handle shields

		if (tipo == "BUFF") then
			if (absorb_spell_list [spellid] and amount) then
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
			if (_recording_ability_with_buffs and _in_combat) then
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

	function parser:buff_refresh (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, _, tipo, amount)

	------------------------------------------------------------------------------------------------
	--> handle shields

		if (tipo == "BUFF") then
			if (absorb_spell_list [spellid] and amount) then
				
				if (escudo [alvo_name] and escudo [alvo_name][spellid] and escudo [alvo_name][spellid][who_name]) then
					local absorb = escudo [alvo_name][spellid][who_name] - amount
					escudo [alvo_name][spellid][who_name] = amount
					
					if (absorb > 0) then
						return parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, _, _math_ceil (absorb), 0, 0, 0, true)
					end
				else
					--> should apply aura if not found in already applied buff list?
				end

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
			if (_recording_ability_with_buffs and _in_combat) then
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

	function parser:unbuff (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, _, tipo, amount)

	------------------------------------------------------------------------------------------------
	--> handle shields

		if (tipo == "BUFF") then
			if (absorb_spell_list [spellid]) then
				if (escudo [alvo_name] and escudo [alvo_name][spellid] and escudo [alvo_name][spellid][who_name]) then
					if (amount) then
						local escudo_antigo = escudo [alvo_name][spellid][who_name]
						if (escudo_antigo and escudo_antigo > amount) then 
							local absorb = escudo_antigo - amount
							escudo [alvo_name][spellid][who_name] = nil
							return parser:heal (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, _, _math_ceil (absorb), _math_ceil (escudo_antigo), 0, 0, true) --> último parametro IS_SHIELD
						end
					end
					escudo [alvo_name][spellid][who_name] = nil
				end
				
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
			if (_recording_ability_with_buffs and _in_combat) then
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
		_overall_energy_container.need_refresh = true
		
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
		
		local shadow = este_jogador.shadow
		local shadow_of_target = jogador_alvo.shadow
		
		este_jogador.last_event = _tempo
		shadow.last_event = _tempo

	------------------------------------------------------------------------------------------------
	--> amount add
		
		--> combat total
		_current_total [3] [key_regenType] = _current_total [3] [key_regenType] + amount
		_overall_total [3] [key_regenType] = _overall_total [3] [key_regenType] + amount
		
		if (este_jogador.grupo) then 
			_current_gtotal [3] [key_regenType] = _current_gtotal [3] [key_regenType] + amount
			_overall_gtotal [3] [key_regenType] = _overall_gtotal [3] [key_regenType] + amount
		end

		--> regen produced amount
		este_jogador [key_regenType] = este_jogador [key_regenType] + amount
		shadow [key_regenType] = shadow [key_regenType] + amount
		este_alvo [key_regenType] = este_alvo [key_regenType] + amount
		
		--> target regenerated amount
		jogador_alvo [key_regenDone] = jogador_alvo [key_regenDone] + amount
		shadow_of_target [key_regenDone] = shadow_of_target [key_regenDone] + amount
		
		--> regen from
		if (not jogador_alvo [key_regenFrom] [who_name]) then
			jogador_alvo [key_regenFrom] [who_name] = true
		end
		if (not shadow_of_target [key_regenFrom] [who_name]) then
			shadow_of_target [key_regenFrom] [who_name] = true
		end
		
		--> owner
		if (meu_dono) then
			meu_dono [key_regenType] = meu_dono [key_regenType] + amount --> e adiciona o dano ao pet
			meu_dono.shadow [key_regenType] = meu_dono.shadow [key_regenType] + amount --> e adiciona o dano ao pet
		end

		--> actor spells table
		local spell = este_jogador.spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spell_tables:PegaHabilidade (spellid, true, token)
		end
		
		return spell:Add (alvo_serial, alvo_name, alvo_flags, amount, who_name, powertype)
	end


	
-----------------------------------------------------------------------------------------------------------------------------------------
	--> MISC															|
-----------------------------------------------------------------------------------------------------------------------------------------

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
		_overall_misc_container.need_refresh = true

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
		
		if (not este_jogador.interrupt) then
			este_jogador.interrupt = 0
			este_jogador.interrupt_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
			este_jogador.interrupt_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
			este_jogador.interrompeu_oque = {}

			if (not shadow.interrupt_targets) then
				shadow.interrupt = 0
				shadow.interrupt_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
				shadow.interrupt_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
				shadow.interrompeu_oque = {}
			end

			este_jogador.interrupt_targets.shadow = shadow.interrupt_targets
			este_jogador.interrupt_spell_tables.shadow = shadow.interrupt_spell_tables
		end	
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> actor interrupt amount
		este_jogador.interrupt = este_jogador.interrupt + 1
		shadow.interrupt = shadow.interrupt + 1

		--> combat totals
		_current_total [4].interrupt = _current_total [4].interrupt + 1
		_overall_total [4].interrupt = _overall_total [4].interrupt + 1
		
		if (este_jogador.grupo) then
			_current_gtotal [4].interrupt = _current_gtotal [4].interrupt + 1
			_overall_gtotal [4].interrupt = _overall_gtotal [4].interrupt + 1
		end

		--> update last event
		este_jogador.last_event = _tempo
		shadow.last_event = _tempo
		
		--> spells interrupted
		if (not este_jogador.interrompeu_oque [extraSpellID]) then
			este_jogador.interrompeu_oque [extraSpellID] = 1
		else
			este_jogador.interrompeu_oque [extraSpellID] = este_jogador.interrompeu_oque [extraSpellID] + 1
		end
		
		if (not shadow.interrompeu_oque [extraSpellID]) then
			shadow.interrompeu_oque [extraSpellID] = 1
		else
			shadow.interrompeu_oque [extraSpellID] = shadow.interrompeu_oque [extraSpellID] + 1
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
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)

	end

	--serach key: ~dispell
	function parser:dispell (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool, auraType)
		
	------------------------------------------------------------------------------------------------
	--> early checks and fixes
		
		--> esta dando erro onde o nome é NIL, fazendo um fix para isso
		if (not who_name) then
			print ( "DISPELL sem who_name: [*] "..extraSpellName )
			print (alvo_name)
			print (spellname)
			who_name = "[*] "..extraSpellName
		end
		if (not alvo_name) then
			print ("DISPELL sem alvo_name: [*] "..extraSpellName)
			print (who_name)
			print (spellname)
			alvo_name = "[*] "..spellid
		end
		
		_current_misc_container.need_refresh = true
		_overall_misc_container.need_refresh = true
		
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

		if (not este_jogador.dispell) then
			--> constrói aqui a tabela dele
			este_jogador.dispell = 0
			este_jogador.dispell_targets = container_combatentes:NovoContainer (container_damage_target)
			este_jogador.dispell_spell_tables = container_habilidades:NovoContainer (container_misc)
			este_jogador.dispell_oque = {}

			if (not shadow.dispell_targets) then
				shadow.dispell = 0
				shadow.dispell_targets = container_combatentes:NovoContainer (container_damage_target)
				shadow.dispell_spell_tables = container_habilidades:NovoContainer (container_misc)
				shadow.dispell_oque = {}
			end

			este_jogador.dispell_targets.shadow = shadow.dispell_targets
			este_jogador.dispell_spell_tables.shadow = shadow.dispell_spell_tables
		end

	------------------------------------------------------------------------------------------------
	--> add amount

		--> last event update
		este_jogador.last_event = _tempo
		shadow.last_event = _tempo

		--> total dispells in combat
		_current_total [4].dispell = _current_total [4].dispell + 1
		_overall_total [4].dispell = _overall_total [4].dispell + 1
		
		if (este_jogador.grupo) then
			_current_gtotal [4].dispell = _current_gtotal [4].dispell + 1
			_overall_gtotal [4].dispell = _overall_gtotal [4].dispell + 1
		end

		--> actor dispell amount
		este_jogador.dispell = este_jogador.dispell + 1
		shadow.dispell = shadow.dispell + 1
		
		--> dispell what
		if (not este_jogador.dispell_oque [spellid]) then
			este_jogador.dispell_oque [spellid] = 1
		else
			este_jogador.dispell_oque [spellid] = este_jogador.dispell_oque [spellid] + 1
		end
		
		if (not shadow.dispell_oque [spellid]) then
			shadow.dispell_oque [spellid] = 1
		else
			shadow.dispell_oque [spellid] = shadow.dispell_oque [spellid] + 1
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
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
	end

	--serach key: ~ress
	function parser:ress (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)

	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (_bit_band (who_flags, AFFILIATION_GROUP) == 0) then
			return
		end
		
		_current_misc_container.need_refresh = true
		_overall_misc_container.need_refresh = true

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

		if (not este_jogador.ress) then
			--> constrói aqui a tabela dele
			este_jogador.ress = 0
			este_jogador.ress_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
			este_jogador.ress_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper

			if (not shadow.ress_targets) then
				shadow.ress = 0
				shadow.ress_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
				shadow.ress_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
			end

			este_jogador.ress_targets.shadow = shadow.ress_targets
			este_jogador.ress_spell_tables.shadow = shadow.ress_spell_tables
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> update last event
		este_jogador.last_event = _tempo
		shadow.last_event = _tempo

		--> combat ress total
		_current_total [4].ress = _current_total [4].ress + 1
		_overall_total [4].ress = _overall_total [4].ress + 1
		
		if (este_jogador.grupo) then
			_current_combat.totals_grupo[4].ress = _current_combat.totals_grupo[4].ress+1
			_overall_combat.totals_grupo[4].ress = _overall_combat.totals_grupo[4].ress+1
		end	

		--> add ress amount
		este_jogador.ress = este_jogador.ress + 1
		shadow.ress = shadow.ress + 1
		
		--> add battle ress
		if (_UnitAffectingCombat (who_name)) then 
			--> procura a última morte do alvo na tabela do combate:
			for i = 1, #_current_combat.last_events_tables do 
				if (_current_combat.last_events_tables [i] [3] == alvo_name) then
					--print ("Adicionando Bres para "..alvo_name)
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

	--print ("CCBREAK: ",spellid, spellname,extraSpellID, extraSpellName, auraType)
	
	------------------------------------------------------------------------------------------------
	--> early checks and fixes

		if (not cc_spell_list [extraSpellID]) then
			return
		end

		if (_bit_band (who_flags, AFFILIATION_GROUP) == 0) then
			return
		end
		
		if (not spellname) then
			spellname = "Melee"
		end	

		_current_misc_container.need_refresh = true
		_overall_misc_container.need_refresh = true

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
		
		if (not este_jogador.cc_break) then
			--> constrói aqui a tabela dele
			este_jogador.cc_break = 0
			este_jogador.cc_break_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
			este_jogador.cc_break_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
			este_jogador.cc_break_oque = {}
			
			if (not shadow.cc_break) then
				shadow.cc_break = 0
				shadow.cc_break_targets = container_combatentes:NovoContainer (container_damage_target) --> pode ser um container de alvo de dano, pois irá usar apenas o .total
				shadow.cc_break_spell_tables = container_habilidades:NovoContainer (container_misc) --> cria o container das habilidades usadas para interromper
				shadow.cc_break_oque = {}
			end

			este_jogador.cc_break_targets.shadow = shadow.cc_break_targets
			este_jogador.cc_break_spell_tables.shadow = shadow.cc_break_spell_tables
		end
		
	------------------------------------------------------------------------------------------------
	--> add amount

		--> update last event
		este_jogador.last_event = _tempo
		shadow.last_event = _tempo
		
		--> combat cc break total
		_current_total [4].cc_break = _current_total [4].cc_break + 1
		_overall_total [4].cc_break = _overall_total [4].cc_break + 1

		if (este_jogador.grupo) then
			_current_combat.totals_grupo[4].cc_break = _current_combat.totals_grupo[4].cc_break+1
			_overall_combat.totals_grupo[4].cc_break = _overall_combat.totals_grupo[4].cc_break+1
		end	
		
		--> add amount
		este_jogador.cc_break = este_jogador.cc_break + 1
		shadow.cc_break = shadow.cc_break + 1
		
		--> broke what
		if (not este_jogador.cc_break_oque [extraSpellID]) then
			este_jogador.cc_break_oque [extraSpellID] = 1
		else
			este_jogador.cc_break_oque [extraSpellID] = este_jogador.cc_break_oque [extraSpellID] + 1
		end
		
		if (not shadow.cc_break_oque [extraSpellID]) then
			shadow.cc_break_oque [extraSpellID] = 1
		else
			shadow.cc_break_oque [extraSpellID] = shadow.cc_break_oque [extraSpellID] + 1
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
		local spell = este_jogador.cc_break_spell_tables._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.cc_break_spell_tables:PegaHabilidade (spellid, true, token)
		end
		return spell:Add (alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
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
		
		if (not _UnitIsFeignDeath (alvo_name)) then
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
				_overall_misc_container.need_refresh = true
				
				--> combat totals
				_current_total [4].dead = _current_total [4].dead + 1
				_overall_total [4].dead = _overall_total [4].dead + 1
				_current_gtotal [4].dead = _current_gtotal [4].dead + 1
				_overall_gtotal [4].dead = _overall_gtotal [4].dead + 1
				
				--> main actor no container de misc que irá armazenar a morte
				local este_jogador, meu_dono = misc_cache [alvo_name]
				if (not este_jogador) then --> pode ser um desconhecido ou um pet
					este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
					if (not meu_dono) then --> se não for um pet, adicionar no cache
						misc_cache [alvo_name] = este_jogador
					end
				end

				--[[
				if (dano.last_events_table) then
				
					local novaTabela = {}
					local counter = 1
					
					--> junta os danos iguais
					for i = 1, #dano.last_events_table, 1 do 
					
						local este_dano = dano.last_events_table[i]
						local proximo_dano = dano.last_events_table[counter+1]
						
						if (este_dano and proximo_dano) then 
						
							local spellId_this =  este_dano[2]
							local tempo_this =  este_dano[4]
							
							local spellId_next =  proximo_dano[2]
							local tempo_next =  proximo_dano[4]
							
							if (spellId_this == spellId_next and _cstr ("%.1f", tempo_this) == _cstr ("%.1f", tempo_next)) then 
								este_dano[3] = este_dano[3] + proximo_dano[3]
								if (not este_dano [7]) then
									este_dano[7] = 2
								else
									este_dano[7] = este_dano[7] + 1
								end
								_table_remove (dano.last_events_table, counter+1)
							end
							
						end
						
						counter = counter + 1
						
					end
				end
				--]]
				
				--> monta a estrutura da morte pegando a tabela de dano e a tabela de cura
				local dano = _current_combat[1]:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true) --> container do dano
				local cura = _current_combat[2]:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true) --> container da cura
				--> objeto da morte
				local esta_morte = {}
				
				--> adiciona a tabela da morte apenas os DANOS recentes
				for index, tabela in _ipairs (dano.last_events_table) do 
					--print ("PARSER 3 dano", unpack (tabela))
					if (tabela [4]) then
						if (tabela [4] + 12 > time) then --> mostra apenas eventos recentes
							esta_morte [#esta_morte+1] = tabela
						end
					end
				end
				
				--> adiciona a tabela da morte apenas as CURAS recentes
				if (cura.last_events_table) then
					for index, tabela in _ipairs (cura.last_events_table) do 
						--print ("PARSER 3 cura", unpack (tabela))
						if (tabela [4]) then
							if (tabela [4] + 12 > time) then
								esta_morte [#esta_morte+1] = tabela
							end
						end
					end
				end

				_table_sort (esta_morte, _detalhes.Sort4)
				
				if (_detalhes.deadlog_limit and #esta_morte > _detalhes.deadlog_limit) then 
					for i = #esta_morte, _detalhes.deadlog_limit+1, -1 do
						_table_remove (esta_morte, i)
					end
				end

				local decorrido = _tempo - _current_combat.start_time
				local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
				
				local t = {esta_morte, time, este_jogador.nome, este_jogador.classe, _UnitHealthMax (alvo_name), minutos.."m "..segundos.."s",  ["dead"] = true}
				
				--print ("A morte teve "..#esta_morte.." eventos")
				
				_table_insert (_current_combat.last_events_tables, #_current_combat.last_events_tables+1, t)
				_table_insert (_overall_combat.last_events_tables, #_current_combat.last_events_tables+1, t)

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
	}

	--serach key: ~capture

	_detalhes.capture_types = {"damage", "heal", "energy", "miscdata", "aura"}

	function _detalhes:CaptureRefresh()
		for _, _thisType in _ipairs (_detalhes.capture_types) do 
			if (_detalhes.capture_current [_thisType]) then
				_detalhes:CaptureEnable (_thisType)
			else
				_detalhes:CaptureDisable (_thisType)
			end
		end
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
		
		elseif (capture_type == "aura") then
			token_list ["SPELL_AURA_APPLIED"] = nil
			token_list ["SPELL_AURA_REMOVED"] = nil
			token_list ["SPELL_AURA_REFRESH"] = nil
		
		elseif (capture_type == "energy") then
			token_list ["SPELL_ENERGIZE"] = nil
			token_list ["SPELL_PERIODIC_ENERGIZE"] = nil
		
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
		
		end
	end

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
		
		elseif (capture_type == "aura") then
			token_list ["SPELL_AURA_APPLIED"] = parser.buff
			token_list ["SPELL_AURA_REMOVED"] = parser.unbuff
			token_list ["SPELL_AURA_REFRESH"] = parser.buff_refresh
			
		elseif (capture_type == "energy") then
			token_list ["SPELL_ENERGIZE"] = parser.energize
			token_list ["SPELL_PERIODIC_ENERGIZE"] = parser.energize
		
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
			
		end
	end


	-- PARSER
	--serach key: ~parser
	function parser:do_parser (time, token, hidding, who_serial, who_name, who_flags, who_flags2, alvo_serial, alvo_name, alvo_flags, alvo_flags2, ...)

		--print (token)

		-- DEBUG
		
		--[[
		if (who_name == "Ditador") then
			if (token:find ("CAST")) then
			
				if (token == "SPELL_CAST_START") then
					_detalhes.castStart = time
				end
			
				if (token == "SPELL_CAST_SUCCESS") then
					local tempoGasto = time - _detalhes.castStart
					local default_cast_time = 2500 -- 2.5 sec
					print (tempoGasto)
					
					local arg1, arg2, arg3, arg4, arg5 = select (1, ...)
					local cd = GetSpellCooldown (arg1)
					print (cd)
				end
				--local arg1, arg2, arg3, arg4, arg5 = select (1, ...)
				--print (token, arg1, arg2, arg3, arg4, arg5)
				--local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo (arg1)
				--print (castTime)
			end
		end
		--]]
		
		local funcao = token_list [token]
		if (funcao) then
			return funcao (_, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, ... )
		else
			return
		end
	end

	--serach key: ~event
	function _detalhes:OnEvent (evento, ...)
		
		if (evento == "COMBAT_LOG_EVENT_UNFILTERED") then
			return parser:do_parser (...)
			
		elseif (evento == "ZONE_CHANGED_NEW_AREA" or evento == "PLAYER_ENTERING_WORLD") then
		
			local zoneName, zoneType, _, _, _, _, _, zoneMapID = _GetInstanceInfo()
			
			_detalhes.zone_type = zoneType
			_detalhes.zone_id = zoneMapID
			_detalhes.zone_name = zoneName
			
			if (zoneType == "pvp") then
				if (not _current_combat.pvp) then
					--print ("Battleground found, starting new combat table")
					_detalhes:EntrarEmCombate()
					--> sinaliza que esse combate é pvp
					_current_combat.pvp = true
					_current_combat.is_boss = {index = 0, name = zoneName, zone = ZoneName, mapid = ZoneMapID, encounter = zoneType} 
					_detalhes.listener:RegisterEvent ("CHAT_MSG_BG_SYSTEM_NEUTRAL")
				end
			else
				if (_current_combat.pvp) then 
					_current_combat.pvp = false
				end
			end

			return
			
		elseif (evento == "CHAT_MSG_BG_SYSTEM_NEUTRAL") then
			local frase = _select (1, ...)

			--> reset combat timer
			if ( (frase:find ("The battle") and frase:find ("has begun!") ) and _current_combat.pvp) then
				local tempo_do_combate = _tempo - _current_combat.start_time
				_detalhes.tabela_overall.start_time = _detalhes.tabela_overall.start_time + tempo_do_combate
				_current_combat.start_time = _tempo
				_detalhes.listener:UnregisterEvent ("CHAT_MSG_BG_SYSTEM_NEUTRAL")
			end
			
			return
			
		elseif (evento == "PLAYER_REGEN_DISABLED") then -- Entrou em Combate
			--> inicia um timer para pegar qual é a luta:
			
			if (_detalhes.EncounterInformation [_detalhes.zone_id]) then 
				_detalhes:ScheduleTimer ("ReadBossFrames", 1)
			end

			--> essa parte do solo mode ainda sera usada?
			if (_detalhes.solo and _detalhes.PluginCount.SOLO > 0) then --> solo mode
				local esta_instancia = _detalhes.tabela_instancias[_detalhes.solo]
				esta_instancia.atualizando = true
			end
			
			return
			
		elseif (evento == "PLAYER_REGEN_ENABLED") then
			--> essa parte do solo mode ainda sera usada?
			if (_detalhes.solo and _detalhes.PluginCount.SOLO > 0) then --> aqui, tentativa de fazer o timer da janela do Solo funcionar corretamente:
				if (_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].Stop) then
					_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].Stop()
				end
			end
			return
			
		elseif (evento == "RAID_ROSTER_UPDATE") then
			_detalhes.container_pets:BuscarPets()
			return

		elseif (evento == "PARTY_MEMBERS_CHANGED") then
			--> Nothing to do here
			return
			
		elseif (evento == "PARTY_CONVERTED_TO_RAID") then
			--> Nothing to do here
			return
			
		elseif (evento == "INSTANCE_ENCOUNTER_ENGAGE_UNIT") then
			--> Nothing to do here
			return 
			
		elseif (evento == "PLAYER_LOGOUT") then
			
			--> close info window
				_detalhes:FechaJanelaInfo()

			--> leave combat start save tables
				if (_detalhes.in_combat) then 
					_detalhes:SairDoCombate()
				end
				
				return _detalhes:SaveData()
				
		elseif (evento == "ADDON_LOADED") then
		
			local addon_name = _select (1, ...)
			
			if (addon_name == "Details") then
				_detalhes:LoadData()
				_detalhes:UpdateParserGears()
				_detalhes:Start()
			end
			
			return
			
		end
	end

	_detalhes.listener:SetScript ("OnEvent", _detalhes.OnEvent)

	function _detalhes:UpdateParser()
		_tempo = _detalhes._tempo
	end

	function _detalhes:ClearParserCache()
		damage_cache = {}
		healing_cache = {}
		energy_cache = {}
		misc_cache = {}
	end

	--serach key: ~cache
	function _detalhes:UpdateParserGears()

		--> refresh combat tables
		_current_combat = _detalhes.tabela_vigente
		_overall_combat = _detalhes.tabela_overall

		--> refresh total containers
		_current_total = _current_combat.totals
		_current_gtotal = _current_combat.totals_grupo
		_overall_total = _overall_combat.totals
		_overall_gtotal = _overall_combat.totals_grupo
		
		--> refresh actors containers
		_current_damage_container = _current_combat [1]
		_overall_damage_container = _overall_combat [1]	
		_current_heal_container = _current_combat [2]
		_overall_heal_container = _overall_combat [2]
		_current_energy_container = _current_combat [3]
		_overall_energy_container = _overall_combat [3]
		_current_misc_container = _current_combat [4]
		_overall_misc_container = _overall_combat [4]
		
		--> refresh data capture options
		_recording_self_buffs = _detalhes.RecordPlayerSelfBuffs
		_recording_took_damage = _detalhes.RecordRealTimeTookDamage
		_recording_ability_with_buffs = _detalhes.RecordPlayerAbilityWithBuffs
		_in_combat = _detalhes.in_combat
		
		--> clear cache
		damage_cache = {}
		healing_cache = {}
		energy_cache = {}
		misc_cache = {}
		
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

	--> get an actor
	function _detalhes:GetActor (_combat, _attribute, _actorname)

		if (not _combat) then
			_combat = "current" --> current combat
		end
		
		if (not _attribute) then
			_attribute = 1 --> damage
		end
		
		if (not _actorname) then
			_actorname = UnitName ("player")
		end
		
		if (_combat == 0 or _combat == "current") then
			local actor = _current_combat (_attribute, _actorname)
			if (actor) then
				return actor
			else
				return nil --_detalhes:NewError ("Current combat doesn't have an actor called ".. _actorname)
			end		
		elseif (_combat == -1 or _combat == "overall") then
			local actor = _overall_combat (_attribute, _actorname)
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
	

