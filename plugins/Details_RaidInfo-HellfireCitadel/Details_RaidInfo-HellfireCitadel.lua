
do

	function Details:InstallHellfireCitadelEncounter()

		--load encounter journal
		if (not EJ_GetEncounterInfoByIndex (1, 669)) then
			EJ_SelectInstance (669)
		end
		EJ_SelectInstance (669)

		local InstanceName = EJ_GetInstanceInfo (669)

		local boss_1_name = EJ_GetEncounterInfoByIndex (1, 669)
		local boss_2_name = EJ_GetEncounterInfoByIndex (2, 669)
		local boss_3_name = EJ_GetEncounterInfoByIndex (3, 669)
		local boss_4_name = EJ_GetEncounterInfoByIndex (4, 669)
		local boss_5_name = EJ_GetEncounterInfoByIndex (5, 669)
		local boss_6_name = EJ_GetEncounterInfoByIndex (6, 669)
		local boss_7_name = EJ_GetEncounterInfoByIndex (7, 669)
		local boss_8_name = EJ_GetEncounterInfoByIndex (8, 669)
		local boss_9_name = EJ_GetEncounterInfoByIndex (9, 669)
		local boss_10_name = EJ_GetEncounterInfoByIndex (10, 669)
		local boss_11_name = EJ_GetEncounterInfoByIndex (11, 669)
		local boss_12_name = EJ_GetEncounterInfoByIndex (12, 669)
		local boss_13_name = EJ_GetEncounterInfoByIndex (13, 669)

		_detalhes:InstallEncounter ({
			
			id = 1448, --map id
			ej_id = 669, --encounter journal id
			name = InstanceName,
			icons = [[Interface\AddOns\Details_RaidInfo-HellfireCitadel\boss_faces]],
			icon = [[Interface\AddOns\Details_RaidInfo-HellfireCitadel\icon256x128]],
			is_raid = true,
			backgroundFile = {file = [[Interface\Glues\LOADINGSCREENS\LoadScreen_HellfireRaid]], coords = {0, 1, 296/1024, 880/1024}},
			backgroundEJ = [[Interface\EncounterJournal\UI-EJ-LOREBG-HellfireRaid]],
			-- 
			boss_names = { 
				boss_1_name, --"Hellfire Assault"
				boss_2_name, --"Iron Reaver"
				boss_3_name, --"Kormrok"
				boss_4_name, --"Hellfire High Council"
				boss_5_name, --"Kilrogg Deadeye"
				boss_6_name, --"Gorefiend"
				boss_7_name, --"Shadow-Lord Iskar"
				boss_8_name, --"Socrethar the Eternal"
				boss_9_name, --"Fel Lord Zakuun"
				boss_10_name, --"Xhul'horac"
				boss_11_name, --"Tyrant Velhari"
				boss_12_name, --"Mannoroth"
				boss_13_name, --"Archimonde"
			},
			
			encounter_ids = { --encounter journal encounter id
				1426,1425,1392,1432,1396,1372,1433,1427,1391,1447,1394,1395,1438,
				[1426] = 1,
				[1425] = 2,
				[1392] = 3,
				[1432] = 4,
				[1396] = 5,
				[1372] = 6,
				[1433] = 7,
				[1427] = 8,
				[1391] = 9,
				[1447] = 10,
				[1394] = 11,
				[1395] = 12,
				[1438] = 13,
			},
			
			encounter_ids2 = { --combatlog encounter id
				[1778] = 1, --"Hellfire Assault"
				[1785] = 2, --"Iron Reaver"
				[1787] = 3, --"Kormrok"
				[1798] = 4, --"Hellfire High Council"
				[1786] = 5, --"Kilrogg Deadeye"
				[1783] = 6, --"Gorefiend"
				[1788] = 7, --"Shadow-Lord Iskar"
				[1794] = 8, --"Socrethar the Eternal"
				[1777] = 9, --"Fel Lord Zakuun"
				[1800] = 10, --"Xhul'horac"
				[1784] = 11, --"Tyrant Velhari"
				[1795] = 12, --"Mannoroth"
				[1799] = 13, --"Archimonde"
			},
			
			boss_ids = { --npc ids
				
			},
			encounters = {
				[1] = {
					boss = boss_1_name, --"Hellfire Assault"
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-hellfireassault]],
				},
				[2] = {
					boss = boss_2_name, --"Iron Reaver",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-felreaver]],
				},
				[3] = {
					boss = boss_3_name, --"Kormrok",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-kormok]],
				},
				[4] = {
					boss = boss_4_name, --"Hellfire High Council",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-gurtoggbloodboil]],
				},
				[5] = {
					boss = boss_5_name, --"Kilrogg Deadeye",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-kilroggdeadeye]],
				},
				[6] = {
					boss = boss_6_name, --"Gorefiend",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-gorefiend]],
				},
				[7] = {
					boss = boss_7_name, --"Shadow-Lord Iskar",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-shadowlordiskar]],
				},
				[8] = {
					boss = boss_8_name, --"Socrethar the Eternal",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-soulboundconstruct]],
				},
				[9] = {
					boss = boss_9_name, --"Fel Lord Zakuun",
					portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-FelLordZakuun]],
				},
				[10] = {
					boss = boss_10_name, --"Xhul'horac",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-xhulhorac]],
				},
				[11] = {
					boss = boss_11_name, --"Tyrant Velhari",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-tyrantvelhari]],
				},
				[12] = {
					boss = boss_12_name, --"Mannoroth",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-mannorothwod]],
				},
				[13] = {
					boss = boss_13_name, --"Archimonde",
					portrait = [[Interface\ENCOUNTERJOURNAL\ui-ej-boss-archimondewod]],
				},
			},
		})
		
		Details.InstallHellfireCitadelEncounter = nil
		
	end
	
	Details:ScheduleTimer ("InstallHellfireCitadelEncounter", 2)
	
end

--> replacement for healing function:
local Details = Details
local _bit_band = bit.band
local OBJECT_TYPE_PETS = 0x00003000
local REACTION_FRIENDLY = 0x00000010
local OBJECT_TYPE_ENEMY = 0x00000040
local UnitDebuff = UnitDebuff
local ptime = time

local Aura_of_Contempt = GetSpellInfo (179987)
if (not Aura_of_Contempt) then
	return Detais:Msg ("Fail to get Aura of Contempt spellname from spell 179987.")
end

local function parser_heal (_, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overhealing, absorbed, critical, multistrike, is_shield)

-----------------------------------------------------------------------------------------------
--> early checks and fixes

	--> only capture heal if is in combat
	if (not Details.in_combat) then
		return
	end

	--> check invalid serial against pets
	if (who_serial == "") then
		if (who_flags and _bit_band (who_flags, OBJECT_TYPE_PETS) ~= 0) then --> é um pet
			return
		end
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
		return Details.parser:SLT_healing (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overhealing, absorbed, critical, multistrike, is_shield)
	end
	
	local cura_efetiva
	local aura_of_contempt_overheal
	overhealing = overhealing or 0
	amount = amount or 0
	absorbed = absorbed or 0
	
	if (is_shield) then
		cura_efetiva = amount
	else
		if (UnitDebuff (alvo_name, Aura_of_Contempt)) then
			cura_efetiva = amount
			aura_of_contempt_overheal = absorbed
			cura_efetiva = cura_efetiva - overhealing
			overhealing = overhealing + absorbed
		else
			cura_efetiva = absorbed
			cura_efetiva = cura_efetiva + amount - overhealing
		end
	end

	Details.tabela_vigente[2].need_refresh = true

------------------------------------------------------------------------------------------------
--> get actors

	local este_jogador, meu_dono, who_name = Details.tabela_vigente[2]:PegarCombatente (who_serial, who_name, who_flags, true)
	local jogador_alvo, alvo_dono, alvo_name = Details.tabela_vigente[2]:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
	
	este_jogador.last_event = ptime()

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
		Details.tabela_vigente.totals_grupo [2] = Details.tabela_vigente.totals_grupo [2] + cura_efetiva
	end
	
	if (jogador_alvo.grupo) then
	
		local t = Details.tabela_vigente.player_last_events [alvo_name]
		
		if (not t) then
			t = Details.tabela_vigente:CreateLastEventsTable (alvo_name)
		end
		
		local i = t.n
		
		local this_event = t [i]
		
		this_event [1] = false --> true if this is a damage || false for healing
		this_event [2] = spellid --> spellid || false if this is a battle ress line
		this_event [3] = amount --> amount of damage or healing
		this_event [4] = time --> parser time
		this_event [5] = UnitHealth (alvo_name) --> current unit heal
		this_event [6] = who_name --> source name
		this_event [7] = is_shield
		this_event [8] = absorbed
		
		i = i + 1
		
		if (i == Details.deadlog_events+1) then
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
				meu_dono.start_time = ptime()
			end
		end
		
		if (este_jogador.end_time) then --> o combate terminou, reabrir o tempo
			este_jogador.end_time = nil
		else
			este_jogador.start_time = ptime()
		end
	end

------------------------------------------------------------------------------------------------
--> add amount
	
	--> actor target

	if (cura_efetiva > 0) then
	
		--> combat total
		Details.tabela_vigente.totals [2] = Details.tabela_vigente.totals [2] + cura_efetiva
		
		--> actor healing amount
		este_jogador.total = este_jogador.total + cura_efetiva	
		este_jogador.total_without_pet = este_jogador.total_without_pet + cura_efetiva
		
		if (aura_of_contempt_overheal) then
			este_jogador.aura_of_contempt_overheal = (este_jogador.aura_of_contempt_overheal or 0) + aura_of_contempt_overheal
		end
		
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
		meu_dono.last_event = ptime()
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
		if (Details.tabela_vigente.is_boss and who_flags and _bit_band (who_flags, OBJECT_TYPE_ENEMY) ~= 0) then
			_detalhes.spell_school_cache [spellname] = spelltype or school
		end
	end
	
	if (is_shield) then
		--return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, 0, 		  nil, 	     overhealing, true)
		return _detalhes.habilidade_cura.Add (spell, alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, 0, 		  nil, 	     overhealing, true, multistrike)
	else
		--return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing)
		return _detalhes.habilidade_cura.Add (spell, alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing, nil, multistrike)
	end
end

local listener = CreateFrame ("frame")
listener:RegisterEvent ("ENCOUNTER_START")
listener:RegisterEvent ("ENCOUNTER_END")

listener:SetScript ("OnEvent", function (self, event, ...)
	
	local encounterID, encounterName, difficultyID, raidSize, endStatus = select (1, ...)
	
	-- if (encounterID == 1721) then --kargath for testing
	if (encounterID == 1784) then--"Tyrant Velhari"
		if (event == "ENCOUNTER_START") then
			--> replacing the healing done func
			--Details.parser:SetParserFunction ("heal", parser_heal)
		else
			--> restoring the func
			--Details.parser:SetParserFunction ("heal", nil)
		end
	end
	
end)
