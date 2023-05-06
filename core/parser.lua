-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
	local DetailsFramework = DetailsFramework

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers

	local UnitAffectingCombat = UnitAffectingCombat
	local UnitHealth = UnitHealth
	local UnitHealthMax = UnitHealthMax
	local UnitGUID = UnitGUID
	local IsInGroup = IsInGroup
	local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
	local GetTime = GetTime
	local tonumber = tonumber
	local tinsert = table.insert
	local select = select
	local bitBand = bit.band
	local floor = math.floor
	local ipairs = ipairs
	local type = type

	local meleeString = _G["MELEE"]

	local _UnitGroupRolesAssigned = DetailsFramework.UnitGroupRolesAssigned
	local _GetSpellInfo = _detalhes.getspellinfo
	local isWOTLK = DetailsFramework.IsWotLKWow()
	local _tempo = time()
	local _, Details222 = ...
	_ = nil

	local shield_cache = _detalhes.ShieldCache --details local
	local parser = _detalhes.parser --details local

	local cc_spell_list = DetailsFramework.CrowdControlSpells
	local container_habilidades = _detalhes.container_habilidades --details local

	--localize the cooldown table from the framework
	local defensive_cooldowns = {}

	if (LIB_OPEN_RAID_COOLDOWNS_INFO) then
		--check if the cooldown is type 2 or 3 or 4 and add to the defensive_cooldowns table
		for spellId, spellTable in pairs(LIB_OPEN_RAID_COOLDOWNS_INFO) do
			if (spellTable.type == 2 or spellTable.type == 3 or spellTable.type == 4) then
				defensive_cooldowns[spellId] = spellTable
			end
		end
	end

	--cache the addition functions for each attribute
	local _spell_damage_func = _detalhes.habilidade_dano.Add
	local _spell_damageMiss_func = _detalhes.habilidade_dano.AddMiss
	local _spell_heal_func = _detalhes.habilidade_cura.Add
	local _spell_energy_func = _detalhes.habilidade_e_energy.Add
	local _spell_utility_func = _detalhes.habilidade_misc.Add

	--current combat and overall pointers
		local _current_combat = _detalhes.tabela_vigente or {} --placeholder table

	--total container pointers
		local _current_total = _current_combat.totals
		local _current_gtotal = _current_combat.totals_grupo

	--actors container pointers
		local _current_damage_container = _current_combat [1]
		local _current_heal_container = _current_combat [2]
		local _current_energy_container = _current_combat [3]
		local _current_misc_container = _current_combat [4]

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--cache
		local names_cache = {}
	--damage
		local damage_cache = setmetatable({}, _detalhes.weaktable)
		local damage_cache_pets = setmetatable({}, _detalhes.weaktable)
		local damage_cache_petsOwners = setmetatable({}, _detalhes.weaktable)
	--heaing
		local healing_cache = setmetatable({}, _detalhes.weaktable)
		local banned_healing_spells = {
			[326514] = true, --remove on 10.0 - Forgeborne Reveries - necrolords ability
		}
	--energy
		local energy_cache = setmetatable({}, _detalhes.weaktable)
	--misc
		local misc_cache = setmetatable({}, _detalhes.weaktable)
		local misc_cache_pets = setmetatable({}, _detalhes.weaktable)
		local misc_cache_petsOwners = setmetatable({}, _detalhes.weaktable)
	--party & raid members
		local raid_members_cache = setmetatable({}, _detalhes.weaktable)
	--tanks
		local tanks_members_cache = setmetatable({}, _detalhes.weaktable)
	--auto regen
		local auto_regen_cache = setmetatable({}, _detalhes.weaktable)
	--bitfield swap cache
		local bitfield_swap_cache = {}
	--damage and heal last events
		local last_events_cache = {} --just initialize table (placeholder)
	--hunter pet frenzy cache
		local pet_frenzy_cache = {}
	--npcId cache
		local npcid_cache = {}
	--enemy cast cache
		local enemy_cast_cache = {}
	--shield spellid cache
		local shield_spellid_cache = {}
	--pets
		local container_pets = {} --just initialize table (placeholder)
	--ignore deaths
		local ignore_death_cache = {}
	--cache
		local cacheAnything = {
			arenaHealth = {},
			paladin_vivaldi_blessings = {},
			track_hunter_frenzy = false,
		}

		

	--cache the data for passive trinkets procs
		local _trinket_data_cache = {}

	--spell containers for special cases
		local monk_guard_talent = {} --guard talent for bm monks

	--spell reflection
		local reflection_damage = {} --self-inflicted damage
		local reflection_debuffs = {} --self-inflicted debuffs
		local reflection_events = {} --spell_missed reflected events
		local reflection_auras = {} --active reflecting auras
		local reflection_dispels = {} --active reflecting dispels
		local reflection_spellid = {
			--we can track which spell caused the reflection
			--this is used to credit this aura as the one doing the damage
			[23920] = true, --warrior spell reflection
			[216890] = true, --warrior spell reflection (pvp talent)
			[213915] = true, --warrior mass spell reflection
			[212295] = true, --warlock nether ward
			--check pally legendary
		}
		local reflection_dispelid = {
			--some dispels also reflect, and we can track them
			[122783] = true, --monk diffuse magic

			--[205604] = true, --demon hunter reverse magic
			--this last one is an odd one, like most dh spells is kindy buggy combatlog wise
			--for now it doesn't fire SPELL_DISPEL events even when dispelling stuff (thanks blizzard)
			--maybe someone can figure out something to track it... but for now it doesnt work
		}
		local reflection_ignore = {
			--common self-harm spells that we know weren't reflected
			--this list can be expanded
			[111400] = true, --warlock burning rush
			[124255] = true, --monk stagger
			[196917] = true, --paladin light of the martyr
			[217979] = true, --warlock health funnel
		}

		--army od the dead cache
		local dk_pets_cache = {
			army = {},
			apoc = {},
		}

		local buffs_to_other_players = {
			[10060] = true, --power infusion
		}

		local empower_cache = {}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants
	local container_misc = _detalhes.container_type.CONTAINER_MISC_CLASS

	local OBJECT_TYPE_ENEMY	=	0x00000040
	local OBJECT_TYPE_PLAYER 	=	0x00000400
	local OBJECT_TYPE_PETS 	=	0x00003000
	local AFFILIATION_GROUP 	=	0x00000007
	local REACTION_FRIENDLY 	=	0x00000010

	local ENVIRONMENTAL_FALLING_NAME	= Loc ["STRING_ENVIRONMENTAL_FALLING"]
	local ENVIRONMENTAL_DROWNING_NAME	= Loc ["STRING_ENVIRONMENTAL_DROWNING"]
	local ENVIRONMENTAL_FATIGUE_NAME	= Loc ["STRING_ENVIRONMENTAL_FATIGUE"]
	local ENVIRONMENTAL_FIRE_NAME		= Loc ["STRING_ENVIRONMENTAL_FIRE"]
	local ENVIRONMENTAL_LAVA_NAME		= Loc ["STRING_ENVIRONMENTAL_LAVA"]
	local ENVIRONMENTAL_SLIME_NAME	= Loc ["STRING_ENVIRONMENTAL_SLIME"]

	local RAID_TARGET_FLAGS = {
		[128] = true, --0x80 skull
		[64] = true, --0x40 cross
		[32] = true, --0x20 square
		[16] = true, --0x10 moon
		[8] = true, --0x8 triangle
		[4] = true, --0x4 diamond
		[2] = true, --0x2 circle
		[1] = true, --0x1 star
	}

	--spellIds override
	local override_spellId = {}

	if (isWOTLK) then
		override_spellId = {
			--Scourge Strike
			[55090] = 55271,
			[55265] = 55271,
			[55270] = 55271,
			[70890] = 55271, --shadow

			--Frost Strike
			[49143] = 55268,
			[51416] = 55268,
			[51417] = 55268,
			[51418] = 55268,
			[51419] = 55268,
			[66962] = 55268, --offhand

			--Obliterate
			[49020] = 51425,
			[51423] = 51425,
			[51424] = 51425,
			[66974] = 51425, --offhand

			--Death Strike
			[49998] = 49924,
			[49999] = 49924,
			[45463] = 49924,
			[49923] = 49924,
			[66953] = 49924, --offhand

			--Blood Strike
			[45902] = 49930,
			[49926] = 49930,
			[49927] = 49930,
			[49928] = 49930,
			[49929] = 49930,
			[66979] = 49930, --offhand

			--Rune Strike
			[6621] = 56815, --offhand

			--Plague Strike
			[45462] = 49921,
			[49917] = 49921,
			[49918] = 49921,
			[49919] = 49921,
			[49920] = 49921,
			[66992] = 49921, --offhand

			--Seal of Command
			[20424] = 69403, --53739 and 53733

			--odyn's fury warrior
			[385062] = 385060,
			[385061] = 385060,

			--crushing blow
			[335098] = 335097,
			[335100] = 335097,

			--charge warrior
			[105771] = 126664,

			--elemental stances
			[377458] = 377459,
			[377461] = 377459,
			[382133] = 377459,
		}

	else --retail
		override_spellId = {
			[184707] = 218617, --warrior rampage
			[184709] = 218617, --warrior rampage
			[201364] = 218617, --warrior rampage
			[201363] = 218617, --warrior rampage
			[85384] = 96103, --warrior raging blow
			[85288] = 96103, --warrior raging blow
			[280849] = 5308, --warrior execute
			[163558] = 5308, --warrior execute
			[217955] = 5308, --warrior execute
			[217956] = 5308, --warrior execute
			[217957] = 5308, --warrior execute
			[224253] = 5308, --warrior execute
			[199850] = 199658, --warrior whirlwind
			[190411] = 199658, --warrior whirlwind
			[44949] = 199658, --warrior whirlwind
			[199667] = 199658, --warrior whirlwind
			[199852] = 199658, --warrior whirlwind
			[199851] = 199658, --warrior whirlwind

			[222031] = 199547, --deamonhunter ChaosStrike
			[200685] = 199552, --deamonhunter Blade Dance
			[391378] = 199552, --^
			[391374] = 199552, --^
			[210155] = 210153, --deamonhunter Death Sweep
			[393055] = 210153, --^
			[393054] = 210153, --^
			[393035] = 337819, --demonhunter throw glaive
			[227518] = 201428, --deamonhunter Annihilation
			[187727] = 178741, --deamonhunter Immolation Aura
			[201789] = 201628, --deamonhunter Fury of the Illidari
			[225921] = 225919, --deamonhunter Fracture talent

			[205164] = 205165, --death knight Crystalline Swords

			[193315] = 197834, --rogue Saber Slash
			[202822] = 202823, --rogue greed
			[280720] = 282449, --rogue Secret Technique
			[280719] = 282449, --rogue Secret Technique
			[27576] = 5374, --rogue mutilate

			[233496] = 233490, --warlock Unstable Affliction
			[233497] = 233490, --warlock Unstable Affliction
			[233498] = 233490, --warlock Unstable Affliction
			[233499] = 233490, --warlock Unstable Affliction

			[261947] = 261977, --monk fist of the white tiger talent

			[32175] = 17364, -- shaman Stormstrike (from Turkar on github)
			[32176] = 17364, -- shaman Stormstrike
			[45284] = 188196, --shaman lightining bolt overloaded

			[228361] = 228360, --shadow priest void erruption
		}

		--all totem
		--377461 382133
		--377458 377459

	end

	local bitfield_debuffs = {}
	for _, spellid in ipairs(_detalhes.BitfieldSwapDebuffsIDs) do
		local spellname = GetSpellInfo(spellid)
		if (spellname) then
			bitfield_debuffs[spellname] = true
		else
			bitfield_debuffs[spellid] = true
		end
	end

	for spellId in pairs(_detalhes.BitfieldSwapDebuffsSpellIDs) do
		bitfield_debuffs [spellId] = true
	end

	Details.bitfield_debuffs_table = bitfield_debuffs

	--tbc spell caches
	local TBC_PrayerOfMendingCache = {}
	local TBC_EarthShieldCache = {}
	local TBC_JudgementOfLightCache = {
		_damageCache = {}
	}

	--expose the override spells table to external scripts
	_detalhes.OverridedSpellIds = override_spellId

	--list of ignored npcs by the user
	_detalhes.default_ignored_npcs = {
		--DH Havoc Talent Fodder to the Flame
		[169421] = true,
		[169425] = true,
		[168932] = true,
		[169426] = true,
		[169429] = true,
		[169428] = true,
		[169430] = true,

		--Volatile Spark on razga'reth
		[194999] = true,
	}

	local ignored_npcids = {}

	--ignore soul link (damage from the warlock on his pet - current to demonology only)
	local SPELLID_WARLOCK_SOULLINK = 108446
	--brewmaster monk guard talent
	local SPELLID_MONK_GUARD = 115295

	--shaman earth shield (bcc)
	local SPELLID_SHAMAN_EARTHSHIELD_HEAL = 379
	local SPELLID_SHAMAN_EARTHSHIELD_BUFF_RANK1 = 974
	local SPELLID_SHAMAN_EARTHSHIELD_BUFF_RANK2 = 32593
	local SPELLID_SHAMAN_EARTHSHIELD_BUFF_RANK3 = 32594
	local SHAMAN_EARTHSHIELD_BUFF = {
		[SPELLID_SHAMAN_EARTHSHIELD_BUFF_RANK1] = true,
		[SPELLID_SHAMAN_EARTHSHIELD_BUFF_RANK2] = true,
		[SPELLID_SHAMAN_EARTHSHIELD_BUFF_RANK3] = true,
	}
	--holy priest prayer of mending (bcc)
	local SPELLID_PRIEST_POM_BUFF = 41635
	local SPELLID_PRIEST_POM_HEAL = 33110
	local SPELLID_SANGUINE_HEAL = 226510

	--spells with special treatment
	local special_damage_spells = {
		[98021] = true, --spirit link toten
		[124255] = true, --stagger
		[282449] = true, --akaari's soul rogue
		[196917] = true, --light of the martyr
		[388009] = true, --blessing of spring
		[388012] = true, --blessing of summer		
	}

	--damage spells to ignore
	local damage_spells_to_ignore = {
		--the damage that the warlock apply to its pet through soullink is ignored
		--it is not useful for damage done or friendly fire
		[SPELLID_WARLOCK_SOULLINK] = true,
	}

	--expose the ignore spells table to external scripts
	_detalhes.SpellsToIgnore = damage_spells_to_ignore

	--is parser allowed to replace spellIDs?
		local is_using_spellId_override = false

	--cache data for fast access during parsing
		local _in_combat = false
		local _current_encounter_id
		local _in_resting_zone = false
		local _global_combat_counter = 0

		local _is_activity_time = false

		---amount of events allowed to store in the table which records the latest events that happened to a player before his death, this value can also be retrieved with Details.deadlog_events
		local _amount_of_last_events = 16

		--map type
		local _is_in_instance = false

		--overheal for shields
		local _use_shield_overheal = false

	--hooks
		local _hook_cooldowns = false
		local _hook_deaths = false
		local _hook_battleress = false
		local _hook_interrupt = false

		local _hook_cooldowns_container = _detalhes.hooks ["HOOK_COOLDOWN"]
		local _hook_deaths_container = _detalhes.hooks ["HOOK_DEATH"]
		local _hook_battleress_container = _detalhes.hooks ["HOOK_BATTLERESS"]
		local _hook_interrupt_container = _detalhes.hooks ["HOOK_INTERRUPT"]

	--regen overflow
		local auto_regen_power_specs = {
			[103] = Enum.PowerType.Energy, --druid feral
			[259] = Enum.PowerType.Energy, --rogue ass
			[260] = Enum.PowerType.Energy, --rogue outlaw
			[261] = Enum.PowerType.Energy, --rogue sub
			[254] = Enum.PowerType.Focus, --hunter mm
			[253] = Enum.PowerType.Focus, --hunter bm
			[255] = Enum.PowerType.Focus, --hunter survival
			[268] = Enum.PowerType.Energy, --monk brewmaster
			[269] = Enum.PowerType.Energy, --monk windwalker
		}

		local AUTO_REGEN_PRECISION = 2 --todo: replace the amount of wasted resource by the amount of time the player "sitted" at max power

		--sanguine affix for m+
		Details.SanguineHealActorName = GetSpellInfo(SPELLID_SANGUINE_HEAL)

		--cache a spellName and the value is the spellId
		--the container actor will use this name to create a fake player actor where its name is the spellName and the specIcon is the spellIcon
		Details.SpecialSpellActorsName = {}

		--add sanguine affix
		if (not isWOTLK) then
			if (Details.SanguineHealActorName) then
				Details.SpecialSpellActorsName[Details.SanguineHealActorName] = SPELLID_SANGUINE_HEAL
			end
		end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--internal functions

-----------------------------------------------------------------------------------------------------------------------------------------
	--DAMAGE 	serach key: ~damage											|
-----------------------------------------------------------------------------------------------------------------------------------------

	--function parser:swing (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)
	--	return parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, 1, _G["MELEE"], 00000001, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)
																		--spellid, spellname, spelltype
	--end

	--function parser:range       (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)
	--	return parser:spell_dmg (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)
	--end

	local who_aggro = function(self)
		if ((_detalhes.LastPullMsg or 0) + 30 > time()) then
			_detalhes.WhoAggroTimer = nil
			return
		end
		_detalhes.LastPullMsg = time()

		local hitLine = self.HitBy or "|cFFFFBB00First Hit|r: *?*"
		local targetLine = ""

		if (Details.bossTargetAtPull) then
			targetLine = " |cFFFFBB00Boss First Target|r: " .. Details.bossTargetAtPull
		else
			for i = 1, 5 do
				local boss = UnitExists("boss" .. i)
				if (boss) then
					local target = UnitName ("boss" .. i .. "target")
					if (target and type(target) == "string") then
						targetLine = " |cFFFFBB00Boss First Target|r: " .. target
						break
					end
				end
			end
		end

		_detalhes:Msg(hitLine .. targetLine)
		_detalhes.WhoAggroTimer = nil
		Details.bossTargetAtPull = nil
	end

	local lastRecordFound = {id = 0, diff = 0, combatTime = 0}

	_detalhes.PrintEncounterRecord = function(self)
		--this block won't execute if the storage isn't loaded
		--self is a timer reference from C_Timer

		local encounterID = self.Boss
		local diff = self.Diff

		if (diff == 15 or diff == 16) then

			local value, rank, combatTime = 0, 0, 0

			if (encounterID == lastRecordFound.id and diff == lastRecordFound.diff) then
				--is the same encounter, no need to find the value again.
				value, rank, combatTime = lastRecordFound.value, lastRecordFound.rank, lastRecordFound.combatTime
			else
				local db = _detalhes.GetStorage()

				local role = _UnitGroupRolesAssigned("player")
				local isDamage = (role == "DAMAGER") or (role == "TANK") --or true
				local bestRank, encounterTable = _detalhes.storage:GetBestFromPlayer (diff, encounterID, isDamage and "damage" or "healing", _detalhes.playername, true)

				if (bestRank) then
					local playerTable, onEncounter, rankPosition = _detalhes.storage:GetPlayerGuildRank (diff, encounterID, isDamage and "damage" or "healing", _detalhes.playername, true)

					value = bestRank[1] or 0
					rank = rankPosition or 0
					combatTime = encounterTable.elapsed

					--if found the result, cache the values so no need to search again next pull
					lastRecordFound.value = value
					lastRecordFound.rank = rank
					lastRecordFound.id = encounterID
					lastRecordFound.diff = diff
					lastRecordFound.combatTime = combatTime
				else
					--if didn't found, no reason to search again on next pull
					lastRecordFound.value = 0
					lastRecordFound.rank = 0
					lastRecordFound.combatTime = 0
					lastRecordFound.id = encounterID
					lastRecordFound.diff = diff
				end
			end

			if (value and combatTime and value > 0 and combatTime > 0) then
				_detalhes:Msg("|cFFFFBB00Your Best Score|r:", _detalhes:ToK2 ((value) / combatTime) .. " [|cFFFFFF00Guild Rank: " .. rank .. "|r]") --localize-me
			end

			if ((not combatTime or combatTime == 0) and not _detalhes.SyncWarning) then
				_detalhes:Msg("|cFFFF3300you may need sync the rank within the guild, type '|cFFFFFF00/details rank|r'|r") --localize-me
				_detalhes.SyncWarning = true
			end
		end

	end

	function parser:spell_dmg(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetRaidFlags, spellId, spellName, spellType, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand, isreflected)
		--early checks and fixes
		if (sourceSerial == "") then
			if (sourceFlags and bitBand(sourceFlags, OBJECT_TYPE_PETS) ~= 0) then
				--pets must have a serial
				return
			end
		end

		--melee
		if (token == "SWING_DAMAGE") then
			spellId, spellName, spellType, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand = 1, meleeString, 00000001, spellId, spellName, spellType, amount, overkill, school, resisted, blocked, absorbed, critical
		end

		if (not targetName) then
			--no target name, just quit
			return

		elseif (not sourceName) then
			--no actor name, use spell name instead
			sourceName = names_cache[spellName]
			if (not sourceName) then
				sourceName = "[*] " .. spellName
				names_cache[spellName] = sourceName
			end
			sourceFlags = 0xa48
			sourceSerial = ""
		end

		--check if the spell is in the backlist and return if true
		if (damage_spells_to_ignore[spellId]) then
			return
		end

		--spell reflection code by github user @m4tjz
		if (sourceSerial == targetSerial and not reflection_ignore[spellId]) then --~reflect
			--this spell could've been reflected, check it
			if (reflection_events[sourceSerial] and reflection_events[sourceSerial][spellId] and time-reflection_events[sourceSerial][spellId].time > 3.5 and (not reflection_debuffs[sourceSerial] or (reflection_debuffs[sourceSerial] and not reflection_debuffs[sourceSerial][spellId]))) then
				--here we check if we have to filter old reflection data
				--we check for two conditions
				--the first is to see if this is an old reflection
				--if more than 3.5 seconds have past then we can say that it is old... but!
				--the second condition is to see if there is an active debuff with the same spellid
				--if there is one then we ignore the timer and skip this
				--this should be cleared afterwards somehow... don't know how...
				reflection_events[sourceSerial][spellId] = nil
				if (next(reflection_events[sourceSerial]) == nil) then
					--there should be some better way of handling this kind of filtering, any suggestion?
					reflection_events[sourceSerial] = nil
				end
			end

			local reflection = reflection_events[sourceSerial] and reflection_events[sourceSerial][spellId]
			if (reflection) then
				--if we still have the reflection data then we conclude it was reflected

				--extend the duration of the timer to catch the rare channelling spells
				reflection_events[sourceSerial][spellId].time = time

				--crediting the source of the reflection aura
				sourceSerial = reflection.who_serial
				sourceName = reflection.who_name
				sourceFlags = reflection.who_flags

				--data of the aura that caused the reflection
				--print("2", spellid, GetSpellInfo(spellid))
				isreflected = spellId --which spell was reflected
				spellId = reflection.spellid --which spell made the reflection
				spellName = reflection.spellname
				spellType = reflection.spelltype

				return parser:spell_dmg(token,time,sourceSerial,sourceName,sourceFlags,targetSerial,targetName,targetFlags,targetRaidFlags,spellId,spellName,0x400,amount,-1,nil,nil,nil,nil,false,false,false,false, isreflected)
			else
				--saving information about this damage because it may occurred before a reflect event
				reflection_damage[sourceSerial] = reflection_damage[sourceSerial] or {}
				reflection_damage[sourceSerial][spellId] = {
					amount = amount,
					time = time,
				}
			end
		end

		--if the parser are allowed to replace spellIDs
		if (is_using_spellId_override) then
			spellId = override_spellId[spellId] or spellId
		end

		--npcId check for ignored npcs
		local npcId = npcid_cache[targetSerial]

		--target
		if (not npcId) then
			--this string manipulation is running on every event
			npcId = tonumber(select(6, strsplit("-", targetSerial)) or 0)
			npcid_cache[targetSerial] = npcId
		end

		if (ignored_npcids[npcId]) then
			return
		end

		--source
		npcId = npcid_cache[sourceSerial]
		if (not npcId) then
			npcId = tonumber(select(6, strsplit("-", sourceSerial)) or 0)
			npcid_cache[sourceSerial] = npcId
		end

		if (ignored_npcids[npcId]) then
			return
		end

		if (npcId == 24207) then --army of the dead
			--check if this is a army or apoc pet
			if (dk_pets_cache.army[sourceSerial]) then
				local cachedName = names_cache[24207001]
				if (not cachedName) then
					sourceName = sourceName .. "|T237511:0|t"
					names_cache[24207001] = sourceName
				else
					sourceName = cachedName
				end
			else
				local cachedName = names_cache[24207002]
				if (not cachedName) then
					sourceName = sourceName .. "|T1392565:0|t"
					names_cache[24207002] = sourceName
				else
					sourceName = cachedName
				end
			end
		end

		--avoid doing spellID checks on each iteration
		if (special_damage_spells[spellId]) then
			--stagger
			if (spellId == 124255) then
				return parser:MonkStagger_damage(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, spellId, spellName, spellType, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)

			--spirit link toten
			elseif (spellId == 98021) then
				return parser:SLT_damage(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, spellId, spellName, spellType, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)

			--rogue's secret technique | when akari's soul gives damage | dragonflight | --REMOVE ON 11.0 - maybe
			elseif (spellId == 282449) then
				--npcID
				if (npcId == 144961) then
					local ownerName, ownerGUID, ownerFlags = Details222.Pets.AkaarisSoulOwner(sourceSerial, sourceName)
					if (ownerName and ownerGUID) then
						sourceSerial = ownerGUID
						sourceName = ownerName
						sourceFlags = ownerFlags
					end
				end

			--Light of the Martyr - paladin spell which causes damage to the caster it self
			elseif (spellId == 196917) then -- or spellid == 183998 < healing part
				return parser:LOTM_damage(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, spellId, spellName, spellType, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)

			elseif (spellId == 388009 or spellId == 388012) then --damage from the paladin blessings of the seasons
				local blessingSource = cacheAnything.paladin_vivaldi_blessings[sourceSerial]
				if (blessingSource) then
					sourceSerial, sourceName, sourceFlags = unpack(blessingSource)
				end
			end
		end

		--wrath of the lich king
		if (isWOTLK) then
			--is the target an enemy with judgement of light?
			if (TBC_JudgementOfLightCache[targetName] and false) then
				--store the player name which just landed a damage
				TBC_JudgementOfLightCache._damageCache[sourceName] = {time, targetName}
			end
		end

	------------------------------------------------------------------------------------------------
		--check if need start an combat
		if (not _in_combat) then --~startcombat ~combatstart
			if (	token ~= "SPELL_PERIODIC_DAMAGE" and
				(
					(sourceFlags and bitBand(sourceFlags, AFFILIATION_GROUP) ~= 0 and UnitAffectingCombat(sourceName) )
					or
					(targetFlags and bitBand(targetFlags, AFFILIATION_GROUP) ~= 0 and UnitAffectingCombat(targetName) )
					or
					(not _detalhes.in_group and sourceFlags and bitBand(sourceFlags, AFFILIATION_GROUP) ~= 0)
				)
			) then
				--avoid Fel Armor and Undulating Maneuvers to start a combat
				if ((spellId == 387846 or spellId == 352561) and sourceName == _detalhes.playername) then
					return
				end

				if (_detalhes.encounter_table.id and _detalhes.encounter_table["start"] >= GetTime() - 3 and _detalhes.announce_firsthit.enabled) then
					local link
					if (spellId <= 10) then
						link = _GetSpellInfo(spellId)
					else
						link = _GetSpellInfo(spellId)
					end

					if (_detalhes.WhoAggroTimer) then
						_detalhes.WhoAggroTimer:Cancel()
					end

					_detalhes.WhoAggroTimer = C_Timer.NewTimer(0.1, who_aggro)
					_detalhes.WhoAggroTimer.HitBy = "|cFFFFFF00First Hit|r: " .. (link or "") .. " from " .. (sourceName or "Unknown")
					print("debug:", _detalhes.WhoAggroTimer.HitBy)
				end

				_detalhes:EntrarEmCombate(sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags)
			else
				--entrar em combate se for dot e for do jogador e o ultimo combate ter sido a mais de 10 segundos atr�s
				if (token == "SPELL_PERIODIC_DAMAGE" and sourceName == _detalhes.playername) then
					--ignora burning rush se o jogador estiver fora de combate
					--111400 warlock's burning rush
					--368637 is buff from trinket "Scars of Fraternal Strife" which make the player bleed even out-of-combat
					--371070 is "Iced Phial of Corrupting Rage" effect triggers randomly, even out-of-combat
					if (spellId == 111400 or spellId == 371070 or spellId == 368637) then
						return
					end

					--faz o calculo dos 10 segundos
					if (_detalhes.last_combat_time + 10 < _tempo) then
						_detalhes:EntrarEmCombate(sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags)
					end
				end
			end
		end

		--[[statistics]]-- _detalhes.statistics.damage_calls = _detalhes.statistics.damage_calls + 1
		_current_damage_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors

		--source damager
		local sourceActor, ownerActor = damage_cache[sourceSerial] or damage_cache_pets[sourceSerial] or damage_cache[sourceName], damage_cache_petsOwners[sourceSerial]

		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_damage_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)

			if (ownerActor) then --the actor is a pet
				if (sourceSerial ~= "") then
					--insert in the pet cache
					damage_cache_pets[sourceSerial] = sourceActor
					damage_cache_petsOwners[sourceSerial] = ownerActor
				end
				--check if the pet owner is already in the cache
				if (not damage_cache[ownerActor.serial] and ownerActor.serial ~= "") then
					damage_cache[ownerActor.serial] = ownerActor
				end
			else
				--there's no owner actor
				if (sourceFlags) then
					if (sourceSerial ~= "") then
						--insert the sourceActor into the cache
						damage_cache[sourceSerial] = sourceActor
					else
						if (names_cache[spellName]) then --sourceName = "[*] " .. spellName
							damage_cache[sourceName] = sourceActor
							local _, _, spellIcon = _GetSpellInfo(spellId or 1)
							sourceActor.spellicon = spellIcon
						else
							--_detalhes:Msg("Unknown actor with unknown serial ", spellname, who_name)
						end
					end
				end
			end

		elseif (ownerActor) then --has (sourceActor and ownerActor)
			--sourceName is the name of the pet
			local cachedPetName = names_cache[sourceSerial]
			if (not cachedPetName) then
				--add the owner name into the sourceName
				sourceName = sourceName .. " <" .. ownerActor.nome .. ">"
				names_cache[sourceSerial] = sourceName
			else
				sourceName = cachedPetName
			end
		end

		if (not sourceActor) then
			return
		end

		--target
		local targetActor, targetOwner = damage_cache[targetSerial] or damage_cache_pets[targetSerial] or damage_cache[targetName], damage_cache_petsOwners[targetSerial]

		if (not targetActor) then
			targetActor, targetOwner, targetName = _current_damage_container:PegarCombatente(targetSerial, targetName, targetFlags, true)
			if (targetOwner) then
				if (targetSerial ~= "") then
					--insert in the pet cache
					damage_cache_pets[targetSerial] = targetActor
					damage_cache_petsOwners[targetSerial] = targetOwner
				end
				--check if the pet owner is already in the cache
				if (not damage_cache[targetOwner.serial] and targetOwner.serial ~= "") then
					damage_cache[targetOwner.serial] = targetOwner
				end
			else
				if (targetFlags and targetSerial ~= "") then --ter certeza que n�o � um pet
					damage_cache [targetSerial] = targetActor
				end
			end

		elseif (targetOwner) then
			--sourceName is the name of the pet
			local cachedPetName = names_cache[targetSerial]
			if (not cachedPetName) then
				--add the owner name into the sourceName
				targetName = targetName .. " <" .. targetOwner.nome .. ">"
				names_cache[targetSerial] = targetName
			else
				targetName = cachedPetName
			end
		end

		if (not targetActor) then
			local instanceName, _, _, _, _, _, _, instanceId = GetInstanceInfo()
			Details:Msg("D! Report 0x885488", targetName, instanceName, instanceId, damage_cache[targetSerial] and "true")
			return
		end

		--last event
		sourceActor.last_event = _tempo

	------------------------------------------------------------------------------------------------
	--group checks and avoidance

		if (absorbed) then
			amount = absorbed + (amount or 0)
		end

		if (_is_in_instance) then
			if (overkill and overkill > 0) then
				overkill = overkill + 1
				--if enabled it'll cut the amount of overkill from the last hit (which killed the actor)
				--when disabled it'll show the total damage done for the latest hit
				amount = amount - overkill
			end
		end

		if (sourceActor.grupo and not sourceActor.arena_enemy and not sourceActor.enemy and not targetActor.arena_enemy) then --source = friendly player and not an enemy player
			--dano to adversario estava caindo aqui por nao estar checando .enemy
			_current_gtotal[1] = _current_gtotal[1] + amount

		elseif (targetActor.grupo) then --source = arena enemy or friendly player
			if (targetActor.arena_enemy) then
				_current_gtotal[1] = _current_gtotal[1] + amount
			end

			--record avoidance only for tank actors
			if (tanks_members_cache[targetSerial]) then
				--monk's stagger
				if (targetActor.classe == "MONK") then
					if (absorbed) then
						--the absorbed amount was staggered and should not be count as damage taken now
						--this absorbed will hit the player with the stagger debuff
						amount = (amount or 0) - absorbed
					end
				else
					--advanced damage taken
					--if advanced  damage taken is enabled, the damage taken to tanks acts like the monk stuff above
					if (_detalhes.damage_taken_everything) then
						if (absorbed) then
							amount = (amount or 0) - absorbed
						end
					end
				end

				--avoidance
				local avoidance = targetActor.avoidance
				if (not avoidance) then
					targetActor.avoidance = _detalhes:CreateActorAvoidanceTable()
					avoidance = targetActor.avoidance
				end

				local overall = avoidance.overall

				local mob = avoidance [sourceName]
				if (not mob) then --if isn't in the table, build on the fly
					mob =  _detalhes:CreateActorAvoidanceTable (true)
					avoidance [sourceName] = mob
				end

				overall ["ALL"] = overall ["ALL"] + 1  --qualtipo de hit ou absorb
				mob ["ALL"] = mob ["ALL"] + 1  --qualtipo de hit ou absorb

				if (spellId < 3) then
					--overall
					overall ["HITS"] = overall ["HITS"] + 1
					mob ["HITS"] = mob ["HITS"] + 1
				end

				if (blocked and blocked > 0) then
					overall ["BLOCKED_HITS"] = overall ["BLOCKED_HITS"] + 1
					mob ["BLOCKED_HITS"] = mob ["BLOCKED_HITS"] + 1
					overall ["BLOCKED_AMT"] = overall ["BLOCKED_AMT"] + blocked
					mob ["BLOCKED_AMT"] = mob ["BLOCKED_AMT"] + blocked
				end

				--absorbs status
				if (absorbed) then
					--aqui pode ser apenas absorb parcial
					overall ["ABSORB"] = overall ["ABSORB"] + 1
					overall ["PARTIAL_ABSORBED"] = overall ["PARTIAL_ABSORBED"] + 1
					overall ["PARTIAL_ABSORB_AMT"] = overall ["PARTIAL_ABSORB_AMT"] + absorbed
					overall ["ABSORB_AMT"] = overall ["ABSORB_AMT"] + absorbed
					mob ["ABSORB"] = mob ["ABSORB"] + 1
					mob ["PARTIAL_ABSORBED"] = mob ["PARTIAL_ABSORBED"] + 1
					mob ["PARTIAL_ABSORB_AMT"] = mob ["PARTIAL_ABSORB_AMT"] + absorbed
					mob ["ABSORB_AMT"] = mob ["ABSORB_AMT"] + absorbed
				else
					--adicionar aos hits sem absorbs
					overall ["FULL_HIT"] = overall ["FULL_HIT"] + 1
					overall ["FULL_HIT_AMT"] = overall ["FULL_HIT_AMT"] + amount
					mob ["FULL_HIT"] = mob ["FULL_HIT"] + 1
					mob ["FULL_HIT_AMT"] = mob ["FULL_HIT_AMT"] + amount
				end
			end

			--record death log
			local t = last_events_cache[targetName]

			if (not t) then
				t = _current_combat:CreateLastEventsTable(targetName)
			end

			local i = t.n

			local thisEvent = t [i]
			thisEvent[1] = true --true if this is a damage || false for healing
			thisEvent[2] = spellId --spellid || false if this is a battle ress line
			thisEvent[3] = amount --amount of damage or healing
			thisEvent[4] = time --parser time

			--current unit heal
			if (targetActor.arena_enemy) then
				--this is an arena enemy, get the heal with the unit Id
				local unitId = _detalhes.arena_enemies[targetName]
				if (not unitId) then
					unitId = Details:GuessArenaEnemyUnitId(targetName)
				end
				if (unitId) then
					thisEvent[5] = UnitHealth(unitId)
				else
					thisEvent[5] = cacheAnything.arenaHealth[targetName] or 100000
				end

				cacheAnything.arenaHealth[targetName] = thisEvent[5]
			else
				thisEvent[5] = UnitHealth(targetName)
			end

			thisEvent[6] = sourceName --source name
			thisEvent[7] = absorbed
			thisEvent[8] = spellType or school
			thisEvent[9] = false
			thisEvent[10] = overkill
			thisEvent[11] = critical
			thisEvent[12] = crushing

			i = i + 1

			if (i == _amount_of_last_events + 1) then
				t.n = 1
			else
				t.n = i
			end
		end

	------------------------------------------------------------------------------------------------
	--~activity time
		if (not sourceActor.dps_started and _is_activity_time) then
			--register on time machine
			sourceActor:Iniciar(true)

			if (ownerActor and not ownerActor.dps_started) then
				ownerActor:Iniciar(true)
				if (ownerActor.end_time) then
					ownerActor.end_time = nil
				else
					ownerActor.start_time = _tempo
				end
			end

			if (sourceActor.end_time) then
				sourceActor.end_time = nil
			else
				sourceActor.start_time = _tempo
			end

			--'player'
			if (sourceActor.nome == _detalhes.playername and token ~= "SPELL_PERIODIC_DAMAGE") then
				if (UnitAffectingCombat("player")) then
					_detalhes:SendEvent("COMBAT_PLAYER_TIMESTARTED", nil, _current_combat, sourceActor)
				end
			end
		end

	------------------------------------------------------------------------------------------------
	--firendly fire ~friendlyfire
		local is_friendly_fire = false

		if (_is_in_instance) then
			if (bitfield_swap_cache [sourceSerial] or ownerActor and bitfield_swap_cache [ownerActor.serial]) then
				if (targetActor.grupo or targetOwner and targetOwner.grupo) then
					is_friendly_fire = true
				end
			else
				if (bitfield_swap_cache [targetSerial] or targetOwner and bitfield_swap_cache [targetOwner.serial]) then
				else
					--Astral Nova explosion from Astral Bomb (Spectral Invoker - Algeth'ar Academy) should get friend zone here
					if ((targetActor.grupo or targetOwner and targetOwner.grupo) and (sourceActor.grupo or ownerActor and ownerActor.grupo)) then
						is_friendly_fire = true
					end
				end
			end
		else
			if (
				(bitBand(targetFlags, REACTION_FRIENDLY) ~= 0 and bitBand(sourceFlags, REACTION_FRIENDLY) ~= 0) or --ajdt d' brx
				(raid_members_cache [targetSerial] and raid_members_cache [sourceSerial] and targetSerial:find("Player") and sourceSerial:find("Player")) --amrl
			) then
				is_friendly_fire = true
			end
		end

		--double check for Astral Nova explosion (only inside AA dungeon)
		if (spellId == 387848 and not is_friendly_fire) then
			if ((targetActor.grupo or targetOwner and targetOwner.grupo) and (sourceActor.grupo or ownerActor and ownerActor.grupo)) then
				is_friendly_fire = true
			end
		end

		if (is_friendly_fire) then
			if (sourceActor.grupo) then --se tiver ele n�o adiciona o evento l� em cima
				local t = last_events_cache[targetName]

				if (not t) then
					t = _current_combat:CreateLastEventsTable(targetName)
				end

				local i = t.n
				local thisEvent = t [i]

				thisEvent[1] = true --true if this is a damage || false for healing
				thisEvent[2] = spellId --spellid || false if this is a battle ress line
				thisEvent[3] = amount --amount of damage or healing
				thisEvent[4] = time --parser time
				thisEvent[5] = UnitHealth (targetName) --current unit heal
				thisEvent[6] = sourceName --source name
				thisEvent[7] = absorbed
				thisEvent[8] = spellType or school
				thisEvent[9] = true
				thisEvent[10] = overkill
				i = i + 1

				if (i == _amount_of_last_events+1) then
					t.n = 1
				else
					t.n = i
				end
			end

			sourceActor.friendlyfire_total = sourceActor.friendlyfire_total + amount

			local friend = sourceActor.friendlyfire[targetName] or sourceActor:CreateFFTable(targetName)

			friend.total = friend.total + amount
			friend.spells[spellId] = (friend.spells[spellId] or 0) + amount

			------------------------------------------------------------------------------------------------
			--damage taken
			--target
			targetActor.damage_taken = targetActor.damage_taken + amount - (absorbed or 0) --adiciona o dano tomado
			if (not targetActor.damage_from[sourceName]) then --adiciona a pool de dano tomado de quem
				targetActor.damage_from[sourceName] = true
			end

			return true
		else
			_current_total[1] = _current_total[1] + amount

			------------------------------------------------------------------------------------------------
			--damage taken
			--target
			targetActor.damage_taken = targetActor.damage_taken + amount --adiciona o dano tomado
			if (not targetActor.damage_from[sourceName]) then --adiciona a pool de dano tomado de quem
				targetActor.damage_from[sourceName] = true
			end
		end

	------------------------------------------------------------------------------------------------
	--amount add

		--actor owner (if any)
		if (ownerActor) then --se for dano de um Pet
			ownerActor.total = ownerActor.total + amount --e adiciona o dano ao pet

			--add owner targets
			ownerActor.targets [targetName] = (ownerActor.targets [targetName] or 0) + amount

			ownerActor.last_event = _tempo

			if (RAID_TARGET_FLAGS [targetRaidFlags]) then
				--add the amount done for the owner
				ownerActor.raid_targets [targetRaidFlags] = (ownerActor.raid_targets [targetRaidFlags] or 0) + amount
			end
		end

		--raid targets
		if (RAID_TARGET_FLAGS[targetRaidFlags]) then
			sourceActor.raid_targets[targetRaidFlags] = (sourceActor.raid_targets[targetRaidFlags] or 0) + amount
		end

		--actor
		sourceActor.total = sourceActor.total + amount

		--actor without pets
		sourceActor.total_without_pet = sourceActor.total_without_pet + amount

		--actor targets
		sourceActor.targets[targetName] = (sourceActor.targets[targetName] or 0) + amount

		--actor spells table
		local spellTable = sourceActor.spells._ActorTable[spellId]
		if (not spellTable) then
			spellTable = sourceActor.spells:PegaHabilidade(spellId, true, token)
			spellTable.spellschool = spellType or school
			if (_current_combat.is_boss and sourceFlags and bitBand(sourceFlags, OBJECT_TYPE_ENEMY) ~= 0) then
				_detalhes.spell_school_cache[spellName] = spellType or school
			end

			if (isreflected) then
				spellTable.isReflection = true
			end
		end

		--empowerment data
		if (empower_cache[sourceSerial]) then
			local empowerSpellInfo = empower_cache[sourceSerial][spellName]
			if (empowerSpellInfo) then
				if (not empowerSpellInfo.counted_healing) then
					--total of empowerment
					spellTable.e_total = (spellTable.e_total or 0) + empowerSpellInfo.empowerLevel --usado para calcular o average empowerment
					--total amount of empowerment
					spellTable.e_amt = (spellTable.e_amt or 0) + 1 --usado para calcular o average empowerment

					--amount of casts on each level
					spellTable.e_lvl = spellTable.e_lvl or {}
					spellTable.e_lvl[empowerSpellInfo.empowerLevel] = (spellTable.e_lvl[empowerSpellInfo.empowerLevel] or 0) + 1

					empowerSpellInfo.counted_healing = true
				end

				--damage bracket
				spellTable.e_dmg = spellTable.e_dmg or {}
				spellTable.e_dmg[empowerSpellInfo.empowerLevel] = (spellTable.e_dmg[empowerSpellInfo.empowerLevel] or 0) + amount
			end
		end

		if (_trinket_data_cache[spellId] and _in_combat) then
			---@type trinketdata
			local thisData = _trinket_data_cache[spellId]
			if (thisData.lastCombatId == _global_combat_counter) then
				if (thisData.lastPlayerName == sourceName) then
					if (thisData.lastActivation < (time - 40)) then
						local cooldownTime = time - thisData.lastActivation
						thisData.totalCooldownTime = thisData.totalCooldownTime + cooldownTime
						thisData.activations = thisData.activations + 1
						thisData.lastActivation = time

						thisData.averageTime = floor(thisData.totalCooldownTime / thisData.activations)
						if (cooldownTime < thisData.minTime) then
							thisData.minTime = cooldownTime
						end

						if (cooldownTime > thisData.maxTime) then
							thisData.maxTime = cooldownTime
						end
					end
				end
			else
				thisData.lastCombatId = _global_combat_counter
				thisData.lastActivation = time
				thisData.lastPlayerName = sourceName
			end

			if (_current_combat.trinketProcs) then
				local playerTrinketData = _current_combat.trinketProcs[sourceName] or {}
				_current_combat.trinketProcs[sourceName] = playerTrinketData
				local trinketData = playerTrinketData[spellId] or {cooldown = 0, total = 0}
				playerTrinketData[spellId] = trinketData

				if (trinketData.cooldown < time) then
					trinketData.cooldown = time + 20
					trinketData.total = trinketData.total + 1
				end
			end
		end

		return _spell_damage_func(spellTable, targetSerial, targetName, targetFlags, amount, sourceName, resisted, blocked, absorbed, critical, glacing, token, isoffhand, isreflected)
	end

	--special behavior for monk stagger debuff periodic damage
	--using it as a separate function to avoid the overhead of checking if the spell is stagger on every damage event
	function parser:MonkStagger_damage(token, time, sourceSerial, sourceName, sourceFlags, alvo_serial, alvo_name, alvo_flags, spellId, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)
		--tag the container to refresh
		_current_damage_container.need_refresh = true

		--get the monk damage object
		local sourceActor, ownerActor = damage_cache[sourceSerial] or damage_cache_pets[sourceSerial] or damage_cache[sourceName], damage_cache_petsOwners[sourceSerial]

		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_damage_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
			if (ownerActor) then --� um pet
				if (sourceSerial ~= "") then
					damage_cache_pets[sourceSerial] = sourceActor
					damage_cache_petsOwners[sourceSerial] = ownerActor
				end
				--conferir se o dono j� esta no cache
				if (not damage_cache[ownerActor.serial] and ownerActor.serial ~= "") then
					damage_cache[ownerActor.serial] = ownerActor
				end
			else
				if (sourceFlags) then --ter certeza que n�o � um pet
					if (sourceSerial ~= "") then
						damage_cache[sourceSerial] = sourceActor
					else
						if (sourceName:find("%[")) then --need to use the cache here
							damage_cache[sourceName] = sourceActor
							local _, _, icon = _GetSpellInfo(spellId or 1)
							sourceActor.spellicon = icon
						end
					end
				end
			end

		elseif (ownerActor) then --has (sourceActor and ownerActor)
			--sourceName is the name of the pet
			local cachedPetName = names_cache[sourceSerial]
			if (not cachedPetName) then
				--add the owner name into the sourceName
				sourceName = sourceName .. " <" .. ownerActor.nome .. ">"
				names_cache[sourceSerial] = sourceName
			else
				sourceName = cachedPetName
			end
		end

		--last event
		sourceActor.last_event = _tempo

		--amount
		amount = (amount or 0)

		--damage taken
		sourceActor.damage_taken = sourceActor.damage_taken + amount
		if (not sourceActor.damage_from[sourceName]) then
			sourceActor.damage_from[sourceName] = true
		end

		--friendly fire total
		sourceActor.friendlyfire_total = sourceActor.friendlyfire_total + amount
		--friendly fire from who
		local friend = sourceActor.friendlyfire[sourceName] or sourceActor:CreateFFTable(sourceName)
		friend.total = friend.total + amount
		friend.spells[spellId] = (friend.spells[spellId] or 0) + amount

		--record death log
		local t = last_events_cache[sourceName]

		if (not t) then
			t = _current_combat:CreateLastEventsTable(sourceName)
		end

		local i = t.n

		local this_event = t[i]

		if (not this_event) then
			return print("Parser Event Error -> Set to 16 DeathLogs and /reload", i, _amount_of_last_events)
		end

		this_event [1] = true --true if this is a damage || false for healing
		this_event [2] = spellId --spellid || false if this is a battle ress line
		this_event [3] = amount --amount of damage or healing
		this_event [4] = time --parser time
		this_event [5] = UnitHealth (sourceName) --current unit heal
		this_event [6] = sourceName --source name
		this_event [7] = absorbed
		this_event [8] = school
		this_event [9] = true --friendly fire
		this_event [10] = overkill

		i = i + 1

		if (i == _amount_of_last_events+1) then
			t.n = 1
		else
			t.n = i
		end

		--avoidance
		local avoidance = sourceActor.avoidance
		if (not avoidance) then
			sourceActor.avoidance = _detalhes:CreateActorAvoidanceTable()
			avoidance = sourceActor.avoidance
		end

		local overall = avoidance.overall

		local mob = avoidance [sourceName]
		if (not mob) then --if isn't in the table, build on the fly
			mob =  _detalhes:CreateActorAvoidanceTable (true)
			avoidance [sourceName] = mob
		end

		overall ["ALL"] = overall ["ALL"] + 1  --qualtipo de hit ou absorb
		mob ["ALL"] = mob ["ALL"] + 1  --qualtipo de hit ou absorb

		if (blocked and blocked > 0) then
			overall ["BLOCKED_HITS"] = overall ["BLOCKED_HITS"] + 1
			mob ["BLOCKED_HITS"] = mob ["BLOCKED_HITS"] + 1
			overall ["BLOCKED_AMT"] = overall ["BLOCKED_AMT"] + blocked
			mob ["BLOCKED_AMT"] = mob ["BLOCKED_AMT"] + blocked
		end

		--absorbs status
		if (absorbed) then
			--aqui pode ser apenas absorb parcial
			overall ["ABSORB"] = overall ["ABSORB"] + 1
			overall ["PARTIAL_ABSORBED"] = overall ["PARTIAL_ABSORBED"] + 1
			overall ["PARTIAL_ABSORB_AMT"] = overall ["PARTIAL_ABSORB_AMT"] + absorbed
			overall ["ABSORB_AMT"] = overall ["ABSORB_AMT"] + absorbed
			mob ["ABSORB"] = mob ["ABSORB"] + 1
			mob ["PARTIAL_ABSORBED"] = mob ["PARTIAL_ABSORBED"] + 1
			mob ["PARTIAL_ABSORB_AMT"] = mob ["PARTIAL_ABSORB_AMT"] + absorbed
			mob ["ABSORB_AMT"] = mob ["ABSORB_AMT"] + absorbed
		else
			--adicionar aos hits sem absorbs
			overall ["FULL_HIT"] = overall ["FULL_HIT"] + 1
			overall ["FULL_HIT_AMT"] = overall ["FULL_HIT_AMT"] + amount
			mob ["FULL_HIT"] = mob ["FULL_HIT"] + 1
			mob ["FULL_HIT_AMT"] = mob ["FULL_HIT_AMT"] + amount
		end
	end

	--special rule for LOTM
	function parser:LOTM_damage (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)

		if (absorbed) then
			amount = absorbed + (amount or 0)
		end

		local healingActor = healing_cache [who_serial]
		if (healingActor and healingActor.spells) then
			healingActor.total = healingActor.total - (amount or 0)

			local spellTable = healingActor.spells:GetSpell (183998)
			if (spellTable) then
				spellTable.anti_heal = (spellTable.anti_heal or 0) + amount
			end
		end

		local t = last_events_cache [who_name]

		if (not t) then
			t = _current_combat:CreateLastEventsTable (who_name)
		end

		local i = t.n

		local this_event = t [i]

		if (not this_event) then
			return print("Parser Event Error -> Set to 16 DeathLogs and /reload", i, _amount_of_last_events)
		end

		this_event [1] = true --true if this is a damage || false for healing
		this_event [2] = spellid --spellid || false if this is a battle ress line
		this_event [3] = amount --amount of damage or healing
		this_event [4] = time --parser time
		this_event [5] = UnitHealth (who_name) --current unit heal
		this_event [6] = who_name --source name
		this_event [7] = absorbed
		this_event [8] = school
		this_event [9] = true --friendly fire
		this_event [10] = overkill

		i = i + 1

		if (i == _amount_of_last_events+1) then
			t.n = 1
		else
			t.n = i
		end

		local damageActor = damage_cache [who_serial]
		if (damageActor) then
			--damage taken
			damageActor.damage_taken = damageActor.damage_taken + amount
			if (not damageActor.damage_from [who_name]) then --adiciona a pool de dano tomado de quem
				damageActor.damage_from [who_name] = true
			end

			--friendly fire
			damageActor.friendlyfire_total = damageActor.friendlyfire_total + amount
			local friend = damageActor.friendlyfire [who_name] or damageActor:CreateFFTable (who_name)
			friend.total = friend.total + amount
			friend.spells [spellid] = (friend.spells [spellid] or 0) + amount
		end
	end

	--special rule of SLT
	function parser:SLT_damage (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand)

		--damager
		local este_jogador, meu_dono = damage_cache [who_serial] or damage_cache_pets [who_serial] or damage_cache [who_name], damage_cache_petsOwners [who_serial]

		if (not este_jogador) then --pode ser um desconhecido ou um pet

			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)

			if (meu_dono) then --� um pet
				if (who_serial ~= "") then
					damage_cache_pets [who_serial] = este_jogador
					damage_cache_petsOwners [who_serial] = meu_dono
				end
				--conferir se o dono j� esta no cache
				if (not damage_cache [meu_dono.serial] and meu_dono.serial ~= "") then
					damage_cache [meu_dono.serial] = meu_dono
				end
			else
				if (who_flags) then --ter certeza que n�o � um pet
					if (who_serial ~= "") then
						damage_cache [who_serial] = este_jogador
					else
						if (who_name:find("%[")) then
							damage_cache [who_name] = este_jogador
							local _, _, icon = _GetSpellInfo(spellid or 1)
							este_jogador.spellicon = icon
						else
							--_detalhes:Msg("Unknown actor with unknown serial ", spellname, who_name)
						end
					end
				end
			end

		elseif (meu_dono) then
			--� um pet
			who_name = who_name .. " <" .. meu_dono.nome .. ">"
		end

		--his target
		local jogador_alvo, alvo_dono = damage_cache [alvo_serial] or damage_cache_pets [alvo_serial] or damage_cache [alvo_name], damage_cache_petsOwners [alvo_serial]

		if (not jogador_alvo) then

			jogador_alvo, alvo_dono, alvo_name = _current_damage_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)

			if (alvo_dono) then
				if (alvo_serial ~= "") then
					damage_cache_pets [alvo_serial] = jogador_alvo
					damage_cache_petsOwners [alvo_serial] = alvo_dono
				end
				--conferir se o dono j� esta no cache
				if (not damage_cache [alvo_dono.serial] and alvo_dono.serial ~= "") then
					damage_cache [alvo_dono.serial] = alvo_dono
				end
			else
				if (alvo_flags and alvo_serial ~= "") then --ter certeza que n�o � um pet
					damage_cache [alvo_serial] = jogador_alvo
				end
			end

		elseif (alvo_dono) then
			--� um pet
			alvo_name = alvo_name .. " <" .. alvo_dono.nome .. ">"
		end

		--last event
		este_jogador.last_event = _tempo

		--record death log
		local t = last_events_cache [alvo_name]

		if (not t) then
			t = _current_combat:CreateLastEventsTable (alvo_name)
		end

		local i = t.n

		local this_event = t [i]

		if (not this_event) then
			return print("Parser Event Error -> Set to 16 DeathLogs and /reload", i, _amount_of_last_events)
		end

		this_event [1] = true --true if this is a damage || false for healing
		this_event [2] = spellid --spellid || false if this is a battle ress line
		this_event [3] = amount --amount of damage or healing
		this_event [4] = time --parser time
		this_event [5] = UnitHealth (alvo_name) --current unit heal
		this_event [6] = who_name --source name
		this_event [7] = absorbed
		this_event [8] = spelltype or school
		this_event [9] = false
		this_event [10] = overkill

		i = i + 1

		if (i == _amount_of_last_events+1) then
			t.n = 1
		else
			t.n = i
		end
	end

	--extra attacks - disabled
	function parser:spell_dmg_extra_attacks(token, time, who_serial, who_name, who_flags, _, _, _, _, spellid, spellName, spelltype, arg1)
		--print("this is even exists on ingame cleu?")
		local este_jogador = damage_cache [who_serial]
		if (not este_jogador) then
			local meu_dono
			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not este_jogador) then
				return --just return if actor doen't exist yet
			end
		end

		--actor spells table
		local spell = este_jogador.spells._ActorTable[1] --melee damage
		if (not spell) then
			return
		end

		spell.extra["extra_attack"] = (spell.extra["extra_attack"] or 0) + 1
	end

	--function parser:swingmissed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, missType, isOffHand, amountMissed)
	function parser:swingmissed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, missType, isOffHand, amountMissed) --, isOffHand, amountMissed, arg1
		return parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, 1, "Corpo-a-Corpo", 00000001, missType, isOffHand, amountMissed) --, isOffHand, amountMissed, arg1
	end

	function parser:rangemissed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, missType, isOffHand, amountMissed) --, isOffHand, amountMissed, arg1
		return parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, 2, "Tiro-Autom�tico", 00000001, missType, isOffHand, amountMissed) --, isOffHand, amountMissed, arg1
	end

	-- ~miss
	function parser:missed (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, missType, isOffHand, amountMissed, arg1, arg2, arg3)


		--print(spellid, spellname, missType, amountMissed) --MISS

	------------------------------------------------------------------------------------------------
	--early checks and fixes

		if (not alvo_name) then
			--no target name, just quit
			return

		elseif (not who_name) then
			--no actor name, use spell name instead
			who_name = "[*] " .. spellname
			who_flags = 0xa48
			who_serial = ""
		end

	------------------------------------------------------------------------------------------------
	--get actors
		--todo tbc seems to not have misses? need further investigation
		--print("MISS", "|", missType, "|", isOffHand, "|", amountMissed, "|", arg1)
		--print(missType, who_name,  spellname, amountMissed)


		--'misser'
		local este_jogador = damage_cache [who_serial]
		if (not este_jogador) then
			--este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (nil, who_name)
			local meu_dono
			este_jogador, meu_dono, who_name = _current_damage_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not este_jogador) then
				return --just return if actor doen't exist yet
			end
		end

		este_jogador.last_event = _tempo

		if (tanks_members_cache [alvo_serial]) then --only track tanks

			local TargetActor = damage_cache [alvo_serial]
			if (TargetActor) then

				local avoidance = TargetActor.avoidance

				if (not avoidance) then
					TargetActor.avoidance = _detalhes:CreateActorAvoidanceTable()
					avoidance = TargetActor.avoidance
				end

				local missTable = avoidance.overall [missType]

				if (missTable) then
					--overall
					local overall = avoidance.overall
					overall [missType] = missTable + 1 --adicionado a quantidade do miss

					--from this mob
					local mob = avoidance [who_name]
					if (not mob) then --if isn't in the table, build on the fly
						mob = _detalhes:CreateActorAvoidanceTable (true)
						avoidance [who_name] = mob
					end

					mob [missType] = mob [missType] + 1

					if (missType == "ABSORB") then --full absorb
						overall ["ALL"] = overall ["ALL"] + 1 --qualtipo de hit ou absorb
						overall ["FULL_ABSORBED"] = overall ["FULL_ABSORBED"] + 1 --amount
						overall ["ABSORB_AMT"] = overall ["ABSORB_AMT"] + (amountMissed or 0)
						overall ["FULL_ABSORB_AMT"] = overall ["FULL_ABSORB_AMT"] + (amountMissed or 0)

						mob ["ALL"] = mob ["ALL"] + 1  --qualtipo de hit ou absorb
						mob ["FULL_ABSORBED"] = mob ["FULL_ABSORBED"] + 1 --amount
						mob ["ABSORB_AMT"] = mob ["ABSORB_AMT"] + (amountMissed or 0)
						mob ["FULL_ABSORB_AMT"] = mob ["FULL_ABSORB_AMT"] + (amountMissed or 0)
					end

				end

			end
		end

	------------------------------------------------------------------------------------------------
	--amount add

		if (missType == "ABSORB") then
			if (token == "SWING_MISSED") then
				este_jogador.totalabsorbed = este_jogador.totalabsorbed + amountMissed
				--return parser:swing ("SWING_DAMAGE", time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, amountMissed, -1, 1, nil, nil, nil, false, false, false, false)
				return parser:spell_dmg ("SWING_DAMAGE", time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, amountMissed, -1, 1, nil, nil, nil, false, false, false, false)

			elseif (token == "RANGE_MISSED") then
				este_jogador.totalabsorbed = este_jogador.totalabsorbed + amountMissed
				--this can call the spell_dmg directly, no need for this proxy
				--return parser:range ("RANGE_DAMAGE", time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, amountMissed, -1, 1, nil, nil, nil, false, false, false, false)
				return parser:spell_dmg("RANGE_DAMAGE", time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, amountMissed, -1, 1, nil, nil, nil, false, false, false, false)

			else
				este_jogador.totalabsorbed = este_jogador.totalabsorbed + amountMissed
				return parser:spell_dmg(token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, amountMissed, -1, 1, nil, nil, nil, false, false, false, false)
			end

	------------------------------------------------------------------------------------------------
	--spell reflection
		elseif (missType == "REFLECT" and reflection_auras[alvo_serial]) then --~reflect
			--a reflect event and we have the reflecting aura data
			if (reflection_damage[who_serial] and reflection_damage[who_serial][spellid] and time-reflection_damage[who_serial][spellid].time > 3.5 and (not reflection_debuffs[who_serial] or (reflection_debuffs[who_serial] and not reflection_debuffs[who_serial][spellid]))) then
				--here we check if we have to filter old damage data
				--we check for two conditions
				--the first is to see if this is an old damage
				--if more than 3.5 seconds have past then we can say that it is old... but!
				--the second condition is to see if there is an active debuff with the same spellid
				--if there is one then we ignore the timer and skip this
				--this should be cleared afterwards somehow... don't know how...
				reflection_damage[who_serial][spellid] = nil
				if (next(reflection_damage[who_serial]) == nil) then
					--there should be some better way of handling this kind of filtering, any suggestion?
					reflection_damage[who_serial] = nil
				end
			end
			local damage = reflection_damage[who_serial] and reflection_damage[who_serial][spellid]
			local reflection = reflection_auras[alvo_serial]
			if (damage) then
				--damage ocurred first, so we have its data
				local amount = reflection_damage[who_serial][spellid].amount

				local isreflected = spellid --which spell was reflected
				alvo_serial = reflection.who_serial
				alvo_name = reflection.who_name
				alvo_flags = reflection.who_flags
				spellid = reflection.spellid
				spellname = reflection.spellname
				spelltype = reflection.spelltype
				--crediting the source of the aura that caused the reflection
				--also saying that the damage came from the aura that reflected the spell

				reflection_damage[who_serial][spellid] = nil
				if next(reflection_damage[who_serial]) == nil then
					--this is so bad at clearing, there should be a better way of handling this
					reflection_damage[who_serial] = nil
				end

				return parser:spell_dmg(token,time,alvo_serial,alvo_name,alvo_flags,who_serial,who_name,who_flags,nil,spellid,spellname,spelltype,amount,-1,nil,nil,nil,nil,false,false,false,false, isreflected)
			else
				--saving information about this reflect because it occurred before the damage event
				reflection_events[who_serial] = reflection_events[who_serial] or {}
				reflection_events[who_serial][spellid] = reflection
				reflection_events[who_serial][spellid].time = time
			end

		else
			--colocando aqui apenas pois ele confere o override dentro do damage
			if (is_using_spellId_override) then
				spellid = override_spellId [spellid] or spellid
			end

			--actor spells table
			local spell = este_jogador.spells._ActorTable [spellid]
			if (not spell) then
				spell = este_jogador.spells:PegaHabilidade (spellid, true, token)
				spell.spellschool = spelltype
				if (_current_combat.is_boss and who_flags and bitBand(who_flags, OBJECT_TYPE_ENEMY) ~= 0) then
					_detalhes.spell_school_cache [spellname] = spelltype
				end
			end
			return _spell_damageMiss_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, missType)
		end


	end




-----------------------------------------------------------------------------------------------------------------------------------------
	--SPELL_EMPOWER
-----------------------------------------------------------------------------------------------------------------------------------------
	function parser:spell_empower(token, time, sourceGUID, sourceName, sourceFlags, targetGUID, targetName, targetFlags, targetRaidFlags, spellId, spellName, spellSchool, empowerLevel)
		--empowerLevel only exists on _END and _INTERRUPT

		if (token == "SPELL_EMPOWER_START" or token == "SPELL_EMPOWER_INTERRUPT") then
			return
		end

		if (not empowerLevel) then
			return
		end

		--early checks
		if (not sourceGUID or not sourceName or not sourceFlags) then
			return
		end

		--source damager, should this only register for Players?
		if (sourceFlags and bitBand(sourceFlags, OBJECT_TYPE_PLAYER) == 0) then
			return
		end

		local sourceObject = damage_cache[sourceGUID] or damage_cache[sourceName]

		if (not sourceObject) then
			sourceObject = _current_damage_container:PegarCombatente(sourceGUID, sourceName, sourceFlags, true)
		end

		if (not sourceObject) then
			return
		end

		empower_cache[sourceGUID] = empower_cache[sourceGUID] or {}
		local empowerTable = {
			spellName = spellName,
			empowerLevel = empowerLevel,
			time = time,
			counted_healing = false,
			counted_damage  = false,
		}
		empower_cache[sourceGUID][spellName] = empowerTable
	end
	--parser.spell_empower
	--10/30 15:32:11.515  SPELL_EMPOWER_START,Player-4184-00242A35,"Isodrak-Valdrakken",0x514,0x0,Player-4184-00242A35,"Isodrak-Valdrakken",0x514,0x0,382266,"Fire Breath",0x4
	--10/30 15:32:12.433  SPELL_EMPOWER_END,Player-4184-00242A35,"Isodrak-Valdrakken",0x514,0x0,0000000000000000,nil,0x80000000,0x80000000,382266,"Fire Breath",0x4,1
	--10/30 15:33:45.970  SPELL_EMPOWER_INTERRUPT,Player-4184-00218B4F,"Minng-Valdrakken",0x512,0x0,0000000000000000,nil,0x80000000,0x80000000,382266,"Fire Breath",0x4,1			

	--10/30 15:34:47.249  SPELL_EMPOWER_START,Player-4184-0048EE5B,"Nezaland-Valdrakken",0x514,0x0,Player-4184-0048EE5B,"Nezaland-Valdrakken",0x514,0x0,382266,"Fire Breath",0x4
	--357209 damage spell is different from the spell cast

-----------------------------------------------------------------------------------------------------------------------------------------
	--SUMMON 	serach key: ~summon										|
-----------------------------------------------------------------------------------------------------------------------------------------
	function parser:summon(token, time, sourceSerial, sourceName, sourceFlags, petSerial, petName, petFlags, petRaidFlags, spellId, spellName)
		--[[statistics]]-- _detalhes.statistics.pets_summons = _detalhes.statistics.pets_summons + 1

		if (not sourceName) then
			sourceName = "[*] " .. spellName
		end


		local npcId = tonumber(select(6, strsplit("-", petSerial)) or 0)

		--differenciate army and apoc pets for DK
		if (spellId == 42651) then --army of the dead
			dk_pets_cache.army[petSerial] = sourceName
		end

		--If fire elemental totem on Wrath, then ignore the summon of the fire elemental totem itself and instead create the Greater Fire Elemental early.
		--Greater Fire Elemental and Fire Elemental Totem have the same serial besides the npc id.
		--There are cases where the Greater Fire Elemental could attack and the SWING_DAMAGE event happens before the spell_summon for it. Same frame.
		--[[12/14 21:14:44.545  SPELL_SUMMON,Player-4384-03852552,"Toekruh-Mankrik",0x512,0x0,Creature-0-4391-615-3107-15439-00001A8313,"Fire Elemental Totem",0xa28,0x0,2894,"Fire Elemental Totem",0x1
			12/14 21:14:44.545  SWING_DAMAGE,Creature-0-4391-615-3107-15438-00001A8313,"Greater Fire Elemental",0x2112,0x0,Creature-0-4391-615-3107-28860-00001A8258,"Sartharion",0xa48,0x0,Creature-0-4391-615-3107-15438-00001A8313,Creature-0-4391-615-3107-15439-00001A8313,4274,4274,0,0,0,-1,0,0,0,3261.68,530.04,155,3.3324,208,188,187,-1,4,0,0,0,nil,nil,nil
			12/14 21:14:44.545  SPELL_CAST_SUCCESS,Creature-0-4391-615-3107-15438-00001A8313,"Greater Fire Elemental",0x2112,0x0,Creature-0-4391-615-3107-28860-00001A8258,"Sartharion",0xa48,0x0,57984,"Fire Blast",0x4,Creature-0-4391-615-3107-15438-00001A8313,Creature-0-4391-615-3107-15439-00001A8313,4274,4274,0,0,0,-1,0,0,0,3261.68,530.04,155,3.3324,208
			12/14 21:14:44.545  SPELL_CAST_SUCCESS,Creature-0-4391-615-3107-15439-00001A8313,"Fire Elemental Totem",0x2112,0x0,0000000000000000,nil,0x80000000,0x80000000,32982,"Fire Elemental Totem",0x1,Creature-0-4391-615-3107-15439-00001A8313,Player-4384-03852552,3888,3888,0,0,0,-1,0,0,0,3257.01,531.82,155,5.1330,208
			12/14 21:14:44.545  SPELL_SUMMON,Creature-0-4391-615-3107-15439-00001A8313,"Fire Elemental Totem",0x2112,0x0,Creature-0-4391-615-3107-15438-00001A8313,"Greater Fire Elemental",0x2112,0x0,32982,"Fire Elemental Totem",0x1
			]]

		if (isWOTLK) then
			if (npcId == 15439) then
				_detalhes.tabela_pets:Adicionar(petSerial:gsub("%-15439%-", "%-15438%-"), "Greater Fire Elemental", petFlags, sourceSerial, sourceName, sourceFlags)
			elseif (npcId == 15438) then
				return
			end
		end

		--pet summon another pet
		local petTable = container_pets[sourceSerial]
		if (petTable) then
			sourceName, sourceSerial, sourceFlags = petTable[1], petTable[2], petTable[3]
		end

		petTable = container_pets[petSerial]
		if (petTable) then
			sourceName, sourceSerial, sourceFlags = petTable[1], petTable[2], petTable[3]
		end

		_detalhes.tabela_pets:Adicionar(petSerial, petName, petFlags, sourceSerial, sourceName, sourceFlags)
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--HEALING 	serach key: ~healing											|
-----------------------------------------------------------------------------------------------------------------------------------------

	local ignored_shields = {
		[142862] = true, -- Ancient Barrier (Malkorok)
		[114556] = true, -- Purgatory (DK)
		[115069] = true, -- Stance of the Sturdy Ox (Monk)
		[20711] = true, -- Spirit of Redemption (Priest)
		[184553]  = true, --Soul Capacitor
	}

	local ignored_overheal = { --during refresh, some shield does not replace the old value for the new one
		[47753] = true, -- Divine Aegis
		[86273] = true, -- Illuminated Healing
		[114908] = true, --Spirit Shell
		[152118] = true, --Clarity of Will
	}

	function parser:heal_denied (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellidAbsorb, spellnameAbsorb, spellschoolAbsorb, serialHealer, nameHealer, flagsHealer, flags2Healer, spellidHeal, spellnameHeal, typeHeal, amountDenied)

		if (not _in_combat) then
			return
		end

		--check invalid serial against pets
		if (who_serial == "") then
			if (who_flags and bitBand(who_flags, OBJECT_TYPE_PETS) ~= 0) then --� um pet
				return
			end
		end

		--no name, use spellname
		if (not who_name) then
			who_name = "[*] " .. (spellnameHeal or "--unknown spell--")
		end

		--no target, just ignore
		if (not alvo_name) then
			return
		end

		--if no spellid
		if (not spellidAbsorb) then
			spellidAbsorb = 1
			spellnameAbsorb = "unknown"
			spellschoolAbsorb = 1
		end

		if (is_using_spellId_override) then
			spellidAbsorb = override_spellId [spellidAbsorb] or spellidAbsorb
			spellidHeal = override_spellId [spellidHeal] or spellidHeal
		end

	------------------------------------------------------------------------------------------------
	--get actors

		local este_jogador, meu_dono = healing_cache [who_serial]
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_heal_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono and who_flags and who_serial ~= "") then --se n�o for um pet, adicionar no cache
				healing_cache [who_serial] = este_jogador
			end
		end

		local jogador_alvo, alvo_dono = healing_cache [alvo_serial]
		if (not jogador_alvo) then
			jogador_alvo, alvo_dono, alvo_name = _current_heal_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			if (not alvo_dono and alvo_flags and also_serial ~= "") then
				healing_cache [alvo_serial] = jogador_alvo
			end
		end

		este_jogador.last_event = _tempo

		------------------------------------------------

		este_jogador.totaldenied = este_jogador.totaldenied + amountDenied

		--actor spells table
		local spell = este_jogador.spells._ActorTable [spellidAbsorb]
		if (not spell) then
			spell = este_jogador.spells:PegaHabilidade (spellidAbsorb, true, token)
			if (_current_combat.is_boss and who_flags and bitBand(who_flags, OBJECT_TYPE_ENEMY) ~= 0) then
				_detalhes.spell_school_cache [spellnameAbsorb] = spellschoolAbsorb or 1
			end
		end

		--return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing)
		return _spell_heal_func(spell, alvo_serial, alvo_name, alvo_flags, amountDenied, spellidHeal, token, nameHealer, overhealing)

	end

	function parser:heal_absorb(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellSchool, shieldOwnerSerial, shieldOwnerName, shieldOwnerFlags, shieldOwnerFlags2, shieldSpellId, shieldName, shieldType, amount)
		if (isWOTLK) then
			if (not amount) then
				--melee
				shieldOwnerSerial, shieldOwnerName, shieldOwnerFlags, shieldOwnerFlags2, shieldSpellId, shieldName, shieldType, amount = spellId, spellName, spellSchool, shieldOwnerSerial, shieldOwnerName, shieldOwnerFlags, shieldOwnerFlags2, shieldSpellId
			end
			return parser:heal(token, time, shieldOwnerSerial, shieldOwnerName, shieldOwnerFlags, targetSerial, targetName, targetFlags, targetFlags2, shieldSpellId, shieldName, shieldType, amount, 0, 0, nil, true)
		else
			--retail
			if (type(shieldName) == "boolean") then
				shieldOwnerSerial, shieldOwnerName, shieldOwnerFlags, shieldOwnerFlags2, shieldSpellId, shieldName, shieldType, amount = spellId, spellName, spellSchool, shieldOwnerSerial, shieldOwnerName, shieldOwnerFlags, shieldOwnerFlags2, shieldSpellId
			end
		end

		if (ignored_shields[shieldSpellId]) then
			return

		elseif (shieldSpellId == 110913) then
			--dark bargain
			local max_health = UnitHealthMax(shieldOwnerName)
			if ((amount or 0) > (max_health or 1) * 4) then
				return
			end
		end

		--diminuir o escudo nas tabelas de ShieldCache
		if (_use_shield_overheal) then
			local shieldsOnTarget = shield_cache[targetName]
			if (shieldsOnTarget) then
				local shieldsBySpellId = shieldsOnTarget[shieldSpellId]
				if (shieldsBySpellId) then
					local shieldAmount = shieldsBySpellId[shieldOwnerName]
					if (shieldAmount) then
						shieldsBySpellId[shieldOwnerName] = shieldAmount - amount
					end
				end
			end
			shield_spellid_cache[shieldSpellId] = true
		end

		--chamar a fun��o de cura pra contar a cura
		return parser:heal(token, time, shieldOwnerSerial, shieldOwnerName, shieldOwnerFlags, targetSerial, targetName, targetFlags, targetFlags2, shieldSpellId, shieldName, shieldType, amount, 0, 0, nil, true)
	end

	function parser:heal(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellType, amount, overHealing, absorbed, critical, bIsShield)
		--only capture heal if is in combat
		if (not _in_combat) then
			if (not _in_resting_zone) then --and not in a resting zone
				return
			end
		end

		--check invalid serial against pets
		if (sourceSerial == "") then
			if (sourceFlags and bitBand(sourceFlags, OBJECT_TYPE_PETS) ~= 0) then
				--it's a pet without a serial number, ignore
				return
			end
		end

		--no target, no heal
		if (not targetName) then
			return
		end

		--check for banned spells
		if (banned_healing_spells[spellId]) then
			return
		end

		if (not sourceName) then
			--no actor name, use spell name instead
			sourceName = names_cache[spellName]
			if (not sourceName) then
				sourceName = "[*] " .. spellName
				--cache the string manipulation
				names_cache[spellName] = sourceName
			end
		end

		if (spellId == 98021) then --spirit link toten
			return parser:SLT_healing(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, spellId, spellName, spellType, amount, overHealing, absorbed, critical, bIsShield)
		end

		if (is_using_spellId_override) then
			spellId = override_spellId[spellId] or spellId
		end

		--sanguine ichor mythic dungeon affix (heal enemies)
		if (spellId == SPELLID_SANGUINE_HEAL) then
			sourceName = Details.SanguineHealActorName
			sourceFlags = 0x518
			sourceSerial = "Creature-0-3134-2289-28065-" .. SPELLID_SANGUINE_HEAL .. "-000164C698"
		end

		local effectiveHeal = absorbed
		if (bIsShield) then
			--shield has the correct amount of 'healing done'
			effectiveHeal = amount
		else
			effectiveHeal = effectiveHeal + amount - overHealing
		end

		if (isWOTLK) then
			--earth shield
			if (spellId == SPELLID_SHAMAN_EARTHSHIELD_HEAL) then
				--get the information of who placed the buff into this actor
				local sourceData = TBC_EarthShieldCache[sourceName]
				if (sourceData) then
					sourceSerial, sourceName, sourceFlags = unpack(sourceData)
				end

			--prayer of mending
			elseif (spellId == SPELLID_PRIEST_POM_HEAL) then
				local sourceData = TBC_PrayerOfMendingCache[sourceName]
				if (sourceData) then
					sourceSerial, sourceName, sourceFlags = unpack(sourceData)
					TBC_PrayerOfMendingCache[sourceName] = nil
				end

			elseif (spellId == 27163 and false) then --Judgement of Light (paladin) --disabled on 25 September 2022
				--check if the hit was landed in the same cleu tick

				local hitCache = TBC_JudgementOfLightCache._damageCache[sourceName]
				if (hitCache) then
					local timeLanded = hitCache[1]
					local targetHit = hitCache[2]

					if (timeLanded and timeLanded == time) then
						local sourceData = TBC_JudgementOfLightCache[targetHit]
						if (sourceData) then
							--change the source of the healing
							sourceSerial, sourceName, sourceFlags = unpack(sourceData)
							--erase the hit time information
							TBC_JudgementOfLightCache._damageCache[sourceName] = nil
						end
					end
				end
			end
		end

		_current_heal_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors

		--healer
		local sourceActor, ownerActor = healing_cache[sourceSerial], nil
		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_heal_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
			if (not ownerActor and sourceFlags and sourceSerial ~= "") then --if isn't a pet, add to the cache
				healing_cache[sourceSerial] = sourceActor
			end
		end

		--target
		local targetActor, targetOwner = healing_cache[targetSerial], nil
		if (not targetActor) then
			targetActor, targetOwner, targetName = _current_heal_container:PegarCombatente(targetSerial, targetName, targetFlags, true)
			if (not targetOwner and targetFlags and targetSerial ~= "") then --if isn't a pet, add to the cache
				healing_cache[targetSerial] = targetActor
			end
		end

		sourceActor.last_event = _tempo

	------------------------------------------------------------------------------------------------
	--an enemy healing enemy or an player actor healing a enemy
		if (spellId == SPELLID_SANGUINE_HEAL) then --sanguine ichor (heal enemies)
			sourceActor.grupo = true

		elseif (bitBand(targetFlags, REACTION_FRIENDLY) == 0 and not _detalhes.is_in_arena and not _detalhes.is_in_battleground) then
			if (not sourceActor.heal_enemy[spellId]) then
				sourceActor.heal_enemy[spellId] = effectiveHeal
			else
				sourceActor.heal_enemy[spellId] = sourceActor.heal_enemy[spellId] + effectiveHeal
			end

			sourceActor.heal_enemy_amt = sourceActor.heal_enemy_amt + effectiveHeal
			return true
		end

		--check if this is a mythic dungeon run
		if (false) then
			if (Details222.MythicPlus.IsMythicPlus()) then
				if (bitBand(targetFlags, REACTION_FRIENDLY) == 0 and bitBand(sourceFlags, REACTION_FRIENDLY) == 0) then
					--this is a enemy healing another enemy
					--create or get an actor which the actor name is the spell name
					local actorName = GetSpellInfo(spellId)
					local spellActor = _current_heal_container:PegarCombatente(spellId, actorName, 0x514, true)
					spellActor.grupo = true
					spellActor.last_event = _tempo
					spellActor.total = spellActor.total + effectiveHeal
					spellActor.spellicon = GetSpellTexture(spellId)
					spellActor.customColor = {0.5, 0.953, 0.082}
				end
			end
		end

	------------------------------------------------------------------------------------------------
	--group checks
		if (sourceActor.grupo and not targetActor.arena_enemy) then
			_current_gtotal[2] = _current_gtotal[2] + effectiveHeal
		end

		if (targetActor.grupo) then
			local t = last_events_cache[targetName]

			if (not t) then
				t = _current_combat:CreateLastEventsTable(targetName)
			end

			local i = t.n

			local thisEvent = t[i]

			thisEvent[1] = false --true if this is a damage || false for healing
			thisEvent[2] = spellId --spellid || false if this is a battle ress line
			thisEvent[3] = amount --amount of damage or healing
			thisEvent[4] = time --parser time

			--current unit heal
			if (targetActor.arena_enemy) then
				--this is an arena enemy, get the heal with the unit Id
				local unitId = _detalhes.arena_enemies[targetName]
				if (not unitId) then
					unitId = Details:GuessArenaEnemyUnitId(targetName)
				end
				if (unitId) then
					thisEvent[5] = UnitHealth(unitId)
				else
					thisEvent[5] = 0
				end
			else
				thisEvent[5] = UnitHealth(targetName)
			end

			thisEvent[6] = sourceName
			thisEvent[7] = bIsShield
			thisEvent[8] = absorbed

			i = i + 1

			if (i == _amount_of_last_events + 1) then
				t.n = 1
			else
				t.n = i
			end
		end

	------------------------------------------------------------------------------------------------
	--~activity time
		if (not sourceActor.iniciar_hps and _is_activity_time) then
			sourceActor:Iniciar (true) --inicia o hps do jogador

			if (ownerActor and not ownerActor.iniciar_hps) then
				ownerActor:Iniciar (true)
				if (ownerActor.end_time) then
					ownerActor.end_time = nil
				else
					--meu_dono:IniciarTempo (_tempo)
					ownerActor.start_time = _tempo
				end
			end

			if (sourceActor.end_time) then --o combate terminou, reabrir o tempo
				sourceActor.end_time = nil
			else
				--este_jogador:IniciarTempo (_tempo)
				sourceActor.start_time = _tempo
			end
		end

	------------------------------------------------------------------------------------------------
	--add amount

		--actor target
		if (effectiveHeal > 0) then
			--combat total
			_current_total[2] = _current_total[2] + effectiveHeal

			--actor healing amount
			sourceActor.total = sourceActor.total + effectiveHeal
			sourceActor.total_without_pet = sourceActor.total_without_pet + effectiveHeal

			--healing taken
			targetActor.healing_taken = targetActor.healing_taken + effectiveHeal --adiciona o dano tomado
			if (not targetActor.healing_from[sourceName]) then --adiciona a pool de dano tomado de quem
				targetActor.healing_from[sourceName] = true
			end

			if (bIsShield) then
				sourceActor.totalabsorb = sourceActor.totalabsorb + effectiveHeal
				sourceActor.targets_absorbs[targetName] = (sourceActor.targets_absorbs[targetName] or 0) + effectiveHeal
			end

			--pet
			if (ownerActor) then
				ownerActor.total = ownerActor.total + effectiveHeal --heal do pet
				ownerActor.targets[targetName] = (ownerActor.targets[targetName] or 0) + effectiveHeal
			end

			--target amount
			sourceActor.targets[targetName] = (sourceActor.targets[targetName] or 0) + effectiveHeal
		end

		if (ownerActor) then
			ownerActor.last_event = _tempo
		end

		if (overHealing > 0) then
			sourceActor.totalover = sourceActor.totalover + overHealing
			sourceActor.targets_overheal[targetName] = (sourceActor.targets_overheal[targetName] or 0) + overHealing

			if (ownerActor) then
				ownerActor.totalover = ownerActor.totalover + overHealing
			end
		end

		--actor spells table
		local spellTable = sourceActor.spells._ActorTable[spellId]
		if (not spellTable) then
			spellTable = sourceActor.spells:PegaHabilidade(spellId, true, token)
			if (bIsShield) then
				spellTable.is_shield = true
			end

			spellTable.spellschool = spellType

			if (_current_combat.is_boss and sourceFlags and bitBand(sourceFlags, OBJECT_TYPE_ENEMY) ~= 0) then
				_detalhes.spell_school_cache[spellName] = spellType
			end
		end

		--empowerment data
		if (empower_cache[sourceSerial]) then
			local empowerSpellInfo = empower_cache[sourceSerial][spellName]
			if (empowerSpellInfo) then
				if (not empowerSpellInfo.counted_damage) then
					--total of empowerment
					spellTable.e_total = (spellTable.e_total or 0) + empowerSpellInfo.empowerLevel --used to calculate the average empowerment
					--total amount of empowerment
					spellTable.e_amt = (spellTable.e_amt or 0) + 1 --used to calculate the average empowerment

					--amount of casts on each level
					spellTable.e_lvl = spellTable.e_lvl or {}
					spellTable.e_lvl[empowerSpellInfo.empowerLevel] = (spellTable.e_lvl[empowerSpellInfo.empowerLevel] or 0) + 1

					empowerSpellInfo.counted_damage = true
				end

				--healing bracket
				spellTable.e_heal = spellTable.e_heal or {}
				spellTable.e_heal[empowerSpellInfo.empowerLevel] = (spellTable.e_heal[empowerSpellInfo.empowerLevel] or 0) + effectiveHeal
			end
		end

		if (bIsShield) then
			return _spell_heal_func(spellTable, targetSerial, targetName, targetFlags, effectiveHeal, sourceName, 0, 		  nil, 	 overHealing, true)
		else
			return _spell_heal_func(spellTable, targetSerial, targetName, targetFlags, effectiveHeal, sourceName, absorbed, critical, overHealing)
		end
	end

	function parser:SLT_healing (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spelltype, amount, overhealing, absorbed, critical, is_shield)

	--get actors
		local este_jogador, meu_dono = healing_cache [who_serial]
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_heal_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono and who_flags and who_serial ~= "") then --se n�o for um pet, adicionar no cache
				healing_cache [who_serial] = este_jogador
			end
		end

		local jogador_alvo, alvo_dono = healing_cache [alvo_serial]
		if (not jogador_alvo) then
			jogador_alvo, alvo_dono, alvo_name = _current_heal_container:PegarCombatente (alvo_serial, alvo_name, alvo_flags, true)
			if (not alvo_dono and alvo_flags and alvo_serial ~= "") then
				healing_cache [alvo_serial] = jogador_alvo
			end
		end

		este_jogador.last_event = _tempo

		local t = last_events_cache [alvo_name]

		if (not t) then
			t = _current_combat:CreateLastEventsTable (alvo_name)
		end

		local i = t.n

		local this_event = t [i]

		this_event [1] = false --true if this is a damage || false for healing
		this_event [2] = spellid --spellid || false if this is a battle ress line
		this_event [3] = amount --amount of damage or healing
		this_event [4] = time --parser time
		this_event [5] = UnitHealth (alvo_name) --current unit heal
		this_event [6] = who_name --source name
		this_event [7] = is_shield
		this_event [8] = absorbed

		i = i + 1

		if (i == _amount_of_last_events+1) then
			t.n = 1
		else
			t.n = i
		end

		local spell = este_jogador.spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.spells:PegaHabilidade (spellid, true, token)
			spell.neutral = true
		end

		return _spell_heal_func (spell, alvo_serial, alvo_name, alvo_flags, absorbed + amount - overhealing, who_name, absorbed, critical, overhealing, nil)
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--BUFFS & DEBUFFS 	search key: ~buff ~aura ~shield								|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:buff(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellschool, auraType, amount, arg1, arg2, arg3)
		--not yet well know about unnamed buff casters
		if (not targetName) then
			targetName = "[*] Unknown shield target"

		elseif (not sourceName) then
			sourceName = names_cache[spellName]
			if (not sourceName) then
				sourceName = "[*] " .. spellName
				names_cache[spellName] = sourceName
			end
			sourceFlags = 0xa48
			sourceSerial = ""
		end

	------------------------------------------------------------------------------------------------
	--spell reflection
		if (reflection_spellid[spellId]) then --~reflect
			--this is a spell reflect aura
			--we save the info on who received this aura and from whom
			--this will be used to credit this spell as the one doing the damage
			reflection_auras[targetSerial] = {
				who_serial = sourceSerial,
				who_name = sourceName,
				who_flags = sourceFlags,
				spellid = spellId,
				spellname = spellName,
				spelltype = spellschool,
			}
		end

		if (auraType == "BUFF") then
			if (LIB_OPEN_RAID_BLOODLUST[spellId]) then --~bloodlust
				if (_detalhes.playername == targetName) then
					_current_combat.bloodlust = _current_combat.bloodlust or {}
					_current_combat.bloodlust[#_current_combat.bloodlust+1] = _current_combat:GetCombatTime()
				end
			end

			if (spellId == 388007 or spellId == 388011) then --buff: bleesing of the summer and winter
				cacheAnything.paladin_vivaldi_blessings[targetSerial] = {sourceSerial, sourceName, sourceFlags}

			elseif (spellId == 27827) then --spirit of redemption (holy ~priest) ~spirit
				local deathLog = last_events_cache[targetName]
				if (not deathLog) then
					deathLog = _current_combat:CreateLastEventsTable(targetName)
				end

				local i = deathLog.n
				local thisEvent = deathLog[i]

				if (not thisEvent) then
					return print("Parser Event Error -> Set to 16 DeathLogs and /reload", i, _amount_of_last_events)
				end

				thisEvent[1] = 5 --5 = buff aplication
				thisEvent[2] = spellId --spellid
				thisEvent[3] = 1
				thisEvent[4] = time --parser time
				thisEvent[5] = UnitHealth(targetName) --current unit heal
				thisEvent[6] = sourceName --source name
				thisEvent[7] = false
				thisEvent[8] = false
				thisEvent[9] = false
				thisEvent[10] = false

				i = i + 1

				if (i == _amount_of_last_events+1) then
					deathLog.n = 1
				else
					deathLog.n = i
				end

				C_Timer.After(0.05, function() --25/12/2022: enabled the delay to wait the combatlog dump damage events which will happen after the buff is applied
					parser:dead("UNIT_DIED", time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags)
					ignore_death_cache [sourceName] = true
				end)
				return

			elseif (spellId == SPELLID_MONK_GUARD) then
				--BfA monk talent
				monk_guard_talent [sourceSerial] = amount

			elseif (spellId == 272790 and cacheAnything.track_hunter_frenzy) then --hunter pet Frenzy quick fix for show the Frenzy uptime
				if (pet_frenzy_cache[sourceName]) then
					if (DetailsFramework:IsNearlyEqual(pet_frenzy_cache[sourceName], time, 0.2)) then
						return
					end
				end

				if (not _detalhes.in_combat) then
					C_Timer.After(1, function()
						if (_detalhes.in_combat) then
							if (pet_frenzy_cache[sourceName]) then
								if (DetailsFramework:IsNearlyEqual(pet_frenzy_cache[sourceName], time, 0.2)) then
									return
								end
							end
							return parser:add_buff_uptime(token, time, sourceSerial, sourceName, sourceFlags, sourceSerial, sourceName, sourceFlags, 0x0, spellId, spellName, "BUFF_UPTIME_IN")
						end
					end)
					return
				end

				pet_frenzy_cache[sourceName] = time --when the buffIN happened
				return parser:add_buff_uptime(token, time, sourceSerial, sourceName, sourceFlags, sourceSerial, sourceName, sourceFlags, 0x0, spellId, spellName, "BUFF_UPTIME_IN")
			end

			if (isWOTLK) then
				if (SHAMAN_EARTHSHIELD_BUFF[spellId]) then
					TBC_EarthShieldCache[targetName] = {sourceSerial, sourceName, sourceFlags}

				elseif (spellId == SPELLID_PRIEST_POM_BUFF) then
					TBC_PrayerOfMendingCache [targetName] = {sourceSerial, sourceName, sourceFlags}

				elseif (spellId == 27163 and false) then --Judgement Of Light
					TBC_JudgementOfLightCache[targetName] = {sourceSerial, sourceName, sourceFlags}
				end
			end

			if (sourceName == targetName and raid_members_cache[sourceSerial] and _in_combat) then
				--player itself
				parser:add_buff_uptime(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, "BUFF_UPTIME_IN")

			elseif (container_pets[sourceSerial] and container_pets[sourceSerial][2] == targetSerial) then
				--pet putting an aura on its owner
				parser:add_buff_uptime(token, time, targetSerial, targetName, targetFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, "BUFF_UPTIME_IN")

			elseif (buffs_to_other_players[spellId]) then
				--e.g. power infusion
				parser:add_buff_uptime(token, time, targetSerial, targetName, targetFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, "BUFF_UPTIME_IN")
			end

			--healing done absorbs
			if (_use_shield_overheal) then
				if (shield_spellid_cache[spellId] and amount) then
					if (not shield_cache[targetName]) then
						shield_cache[targetName] = {}
						shield_cache[targetName][spellId] = {}
						shield_cache[targetName][spellId][sourceName] = amount

					elseif (not shield_cache[targetName][spellId]) then
						shield_cache[targetName][spellId] = {}
						shield_cache[targetName][spellId][sourceName] = amount

					else
						shield_cache[targetName][spellId][sourceName] = amount
					end
				end
			end

	------------------------------------------------------------------------------------------------
	--recording debuffs applied by player

		elseif (auraType == "DEBUFF") then
			if (isWOTLK) then --buff applied
				if (spellId == 27162 and false) then --Judgement Of Light
					--which player applied the judgement of light on this mob
					TBC_JudgementOfLightCache[targetName] = {sourceSerial, sourceName, sourceFlags}
				end
			end

		------------------------------------------------------------------------------------------------
		--spell reflection
			if (sourceSerial == targetSerial and not reflection_ignore[spellId]) then
				--self-inflicted debuff that could've been reflected
				--just saving it as a boolean to check for reflections
				reflection_debuffs[sourceSerial] = reflection_debuffs[sourceSerial] or {}
				reflection_debuffs[sourceSerial][spellId] = true
			end

			if (_in_combat) then
				------------------------------------------------------------------------------------------------
				--buff uptime
				if (cc_spell_list [spellId]) then
					parser:add_cc_done (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName)
				end

				if ((bitfield_debuffs[spellName] or bitfield_debuffs[spellId]) and raid_members_cache[targetSerial]) then
					bitfield_swap_cache[targetSerial] = true
				end

				if (raid_members_cache [sourceSerial]) then
					--call record debuffs uptime
					parser:add_debuff_uptime (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, "DEBUFF_UPTIME_IN")

				elseif (raid_members_cache [targetSerial] and not raid_members_cache [sourceSerial]) then --alvo � da raide e who � alguem de fora da raide
					parser:add_bad_debuff_uptime (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellschool, "DEBUFF_UPTIME_IN")
				end
			end
		end
	end

	-- ~crowd control ~ccdone
	function parser:add_cc_done(token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname)

	------------------------------------------------------------------------------------------------
	--early checks and fixes

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors

		--main actor
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --se n�o for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly

		if (not este_jogador.cc_done) then
			este_jogador.cc_done = _detalhes:GetOrderNumber()
			este_jogador.cc_done_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.cc_done_targets = {}
		end

	------------------------------------------------------------------------------------------------
	--add amount

		--update last event
		este_jogador.last_event = _tempo

		--add amount
		este_jogador.cc_done = este_jogador.cc_done + 1
		este_jogador.cc_done_targets [alvo_name] = (este_jogador.cc_done_targets [alvo_name] or 0) + 1

		--actor spells table
		local spell = este_jogador.cc_done_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.cc_done_spells:PegaHabilidade (spellid, true)
		end

		spell.targets [alvo_name] = (spell.targets [alvo_name] or 0) + 1
		spell.counter = spell.counter + 1

		--add the crowd control for the pet owner
		if (meu_dono) then

			if (not meu_dono.cc_done) then
				meu_dono.cc_done = _detalhes:GetOrderNumber()
				meu_dono.cc_done_spells = container_habilidades:NovoContainer (container_misc)
				meu_dono.cc_done_targets = {}
			end

			--add amount
			meu_dono.cc_done = meu_dono.cc_done + 1
			meu_dono.cc_done_targets [alvo_name] = (meu_dono.cc_done_targets [alvo_name] or 0) + 1

			--actor spells table
			local spell = meu_dono.cc_done_spells._ActorTable [spellid]
			if (not spell) then
				spell = meu_dono.cc_done_spells:PegaHabilidade (spellid, true)
			end

			spell.targets [alvo_name] = (spell.targets [alvo_name] or 0) + 1
			spell.counter = spell.counter + 1
		end

		--verifica a classe
		if (who_flags and bitBand(who_flags, OBJECT_TYPE_PLAYER) ~= 0) then
			if (este_jogador.classe == "UNKNOW" or este_jogador.classe == "UNGROUPPLAYER") then
				local damager_object = damage_cache [who_serial]
				if (damager_object and (damager_object.classe ~= "UNKNOW" and damager_object.classe ~= "UNGROUPPLAYER")) then
					este_jogador.classe = damager_object.classe
				else
					local healing_object = healing_cache [who_serial]
					if (healing_object and (healing_object.classe ~= "UNKNOW" and healing_object.classe ~= "UNGROUPPLAYER")) then
						este_jogador.classe = healing_object.classe
					end
				end
			end
		end
	end

	function parser:buff_refresh(token, time, sourceSerial, sourceName, sourceFlags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellName, spellschool, tipo, amount)
		if (not sourceName) then
			sourceName = names_cache[spellName]
			if (not sourceName) then
				sourceName = "[*] " .. spellName
				names_cache[spellName] = sourceName
			end
			sourceFlags = 0xa48
			sourceSerial = ""
		end

		if (tipo == "BUFF") then
			if (spellid == 272790 and cacheAnything.track_hunter_frenzy) then --hunter pet Frenzy spellid
				local miscActorObject = misc_cache[sourceName]
				if (miscActorObject) then
					--fastest way to query utility spell data
					local spellTable = miscActorObject.buff_uptime_spells and miscActorObject.buff_uptime_spells._ActorTable[spellid]
					if (spellTable) then
						if (spellTable.actived and pet_frenzy_cache[sourceName]) then
							if (DetailsFramework:IsNearlyEqual(pet_frenzy_cache[sourceName], time, 0.2)) then
								return
							end
						end
					end
				end

				parser:add_buff_uptime(token, time, sourceSerial, sourceName, sourceFlags, sourceSerial, sourceName, sourceFlags, 0x0, spellid, spellName, "BUFF_UPTIME_REFRESH")
				pet_frenzy_cache[sourceName] = time
				return
			end

			if (sourceName == alvo_name and raid_members_cache [sourceSerial] and _in_combat) then
				--call record buffs uptime
				parser:add_buff_uptime (token, time, sourceSerial, sourceName, sourceFlags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellName, "BUFF_UPTIME_REFRESH")

			elseif (container_pets [sourceSerial] and container_pets [sourceSerial][2] == alvo_serial) then
				--um pet colocando uma aura do dono
				parser:add_buff_uptime (token, time, alvo_serial, alvo_name, alvo_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellName, "BUFF_UPTIME_REFRESH")

			elseif (buffs_to_other_players[spellid]) then
				parser:add_buff_uptime(token, time, alvo_serial, alvo_name, alvo_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellName, "BUFF_UPTIME_REFRESH")
			end

			if (_use_shield_overheal) then
				if (shield_spellid_cache[spellid] and amount) then
					if (shield_cache[alvo_name] and shield_cache[alvo_name][spellid] and shield_cache[alvo_name][spellid][sourceName]) then
						if (ignored_overheal[spellid]) then
							shield_cache[alvo_name][spellid][sourceName] = amount --refresh gives the updated amount
							return
						end

						--get the shield overheal
						local overhealAmount = shield_cache[alvo_name][spellid][sourceName]
						--set the new shield amount
						shield_cache[alvo_name][spellid][sourceName] = amount

						if (overhealAmount > 0) then
							return parser:heal(token, time, sourceSerial, sourceName, sourceFlags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellName, nil, 0, ceil (overhealAmount), 0, nil, true)
						end
					end
				end
			end

	------------------------------------------------------------------------------------------------
	--recording debuffs applied by player

		elseif (tipo == "DEBUFF") then
			if (isWOTLK) then --buff refresh
				if (spellid == 27162 and false) then --Judgement Of Light
					--which player applied the judgement of light on this mob
					TBC_JudgementOfLightCache[alvo_name] = {sourceSerial, sourceName, sourceFlags}
				end
			end

			if (_in_combat) then
				------------------------------------------------------------------------------------------------
				--buff uptime
				if (raid_members_cache [sourceSerial]) then
					--call record debuffs uptime
					parser:add_debuff_uptime (token, time, sourceSerial, sourceName, sourceFlags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellName, "DEBUFF_UPTIME_REFRESH")
				elseif (raid_members_cache [alvo_serial] and not raid_members_cache [sourceSerial]) then --alvo � da raide e o caster � inimigo
					parser:add_bad_debuff_uptime (token, time, sourceSerial, sourceName, sourceFlags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellName, spellschool, "DEBUFF_UPTIME_REFRESH", amount)
				end
			end
		end
	end

	-- ~unbuff
	function parser:unbuff(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, alvo_flags2, spellid, spellName, spellSchool, tipo, amount)
		if (not sourceName) then
			sourceName = names_cache[spellName]
			if (not sourceName) then
				sourceName = "[*] " .. spellName
				names_cache[spellName] = sourceName
			end
			sourceFlags = 0xa48
			sourceSerial = ""
		end

		if (tipo == "BUFF") then
				if (spellid == 272790 and cacheAnything.track_hunter_frenzy) then --hunter pet Frenzy spellid
					if (not pet_frenzy_cache[sourceName]) then
						return
					end
					parser:add_buff_uptime(token, time, sourceSerial, sourceName, sourceFlags, sourceSerial, sourceName, sourceFlags, 0x0, spellid, spellName, "BUFF_UPTIME_OUT")
					pet_frenzy_cache[sourceName] = nil
					return
				end

				if (sourceName == targetName and raid_members_cache [sourceSerial] and _in_combat) then
					--call record buffs uptime
					parser:add_buff_uptime (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, alvo_flags2, spellid, spellName, "BUFF_UPTIME_OUT")
				elseif (container_pets [sourceSerial] and container_pets [sourceSerial][2] == targetSerial) then
					--um pet colocando uma aura do dono
					parser:add_buff_uptime (token, time, targetSerial, targetName, targetFlags, targetSerial, targetName, targetFlags, alvo_flags2, spellid, spellName, "BUFF_UPTIME_OUT")

				elseif (buffs_to_other_players[spellid]) then
					parser:add_buff_uptime(token, time, targetSerial, targetName, targetFlags, targetSerial, targetName, targetFlags, alvo_flags2, spellid, spellName, "BUFF_UPTIME_OUT")
				end

				if (spellid == SPELLID_MONK_GUARD) then
					--BfA monk talent
					if (monk_guard_talent [sourceSerial]) then
						local damage_prevented = monk_guard_talent [sourceSerial] - (amount or 0)
						parser:heal (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, alvo_flags2, spellid, spellName, spellSchool, damage_prevented, ceil (amount or 0), 0, 0, true)
					end

				elseif (spellid == 388007 or spellid == 388011) then --buff: bleesing of the summer
					cacheAnything.paladin_vivaldi_blessings[targetSerial] = nil
				end

			------------------------------------------------------------------------------------------------
			--shield overheal
			if (_use_shield_overheal) then
				if (shield_spellid_cache[spellid]) then
					if (shield_cache [targetName] and shield_cache [targetName][spellid] and shield_cache [targetName][spellid][sourceName]) then
						if (amount) then
							-- o amount � o que sobrou do escudo
							--local overheal = escudo [alvo_name][spellid][who_name] --usando o 'amount' passado pela função
							--overheal não esta dando refresh quando um valor é adicionado ao escudo
							shield_cache [targetName][spellid][sourceName] = 0

							--can't use monk guard since its overheal is computed inside the unbuff
							if (amount > 0 and spellid ~= SPELLID_MONK_GUARD) then
								--removing the nil at the end before true for is_shield, I have no documentation change about it, not sure the reason why it was addded
								return parser:heal (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, alvo_flags2, spellid, spellName, nil, 0, ceil (amount), 0, 0, true) --0, 0, nil, true
							else
								return
							end
						end

						shield_cache [targetName][spellid][sourceName] = 0
					end
				end
			end

	------------------------------------------------------------------------------------------------
	--recording debuffs applied by player
		elseif (tipo == "DEBUFF") then
			if (isWOTLK) then --buff removed
				if (spellid == 27162 and false) then --Judgement Of Light
					TBC_JudgementOfLightCache[targetName] = nil
				end
			end

		------------------------------------------------------------------------------------------------
		--spell reflection
			if (reflection_dispels[targetSerial] and reflection_dispels[targetSerial][spellid]) then
				--debuff was dispelled by a reflecting dispel and could've been reflected
				--save the data about whom dispelled who and the spell that was dispelled
				local reflection = reflection_dispels[targetSerial][spellid]
				reflection_events[sourceSerial] = reflection_events[sourceSerial] or {}
				reflection_events[sourceSerial][spellid] = {
					who_serial = reflection.who_serial,
					who_name = reflection.who_name,
					who_flags = reflection.who_flags,
					spellid = reflection.spellid,
					spellname = reflection.spellname,
					spelltype = reflection.spelltype,
					time = time,
				}
				reflection_dispels[targetSerial][spellid] = nil
				if (next(reflection_dispels[targetSerial]) == nil) then
					--suggestion on how to make this better?
					reflection_dispels[targetSerial] = nil
				end
			end

		------------------------------------------------------------------------------------------------
		--spell reflection
			if (reflection_debuffs[sourceSerial] and reflection_debuffs[sourceSerial][spellid]) then
				--self-inflicted debuff was removed, so we just clear this data
				reflection_debuffs[sourceSerial][spellid] = nil
				if (next(reflection_debuffs[sourceSerial]) == nil) then
					--better way of doing this? accepting suggestions
					reflection_debuffs[sourceSerial] = nil
				end
			end

			if (_in_combat) then
			------------------------------------------------------------------------------------------------
			--buff uptime
				if (raid_members_cache [sourceSerial]) then
					--call record debuffs uptime
					parser:add_debuff_uptime (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, alvo_flags2, spellid, spellName, "DEBUFF_UPTIME_OUT")
				elseif (raid_members_cache [targetSerial] and not raid_members_cache [sourceSerial]) then --alvo � da raide e o caster � inimigo
					parser:add_bad_debuff_uptime (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, alvo_flags2, spellid, spellName, spellSchool, "DEBUFF_UPTIME_OUT")
				end

				if ((bitfield_debuffs[spellName] or bitfield_debuffs[spellid]) and targetSerial) then
					bitfield_swap_cache[targetSerial] = nil
				end
			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--MISC 	search key: ~buffuptime ~buffsuptime									|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:add_bad_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spellschool, in_out, stack_amount)

		if (not alvo_name) then
			--no target name, just quit
			return
		elseif (not who_name) then
			--no actor name, use spell name instead
			who_name = "[*] "..spellname
		end

		------------------------------------------------------------------------------------------------
		--get actors
			--nome do debuff ser� usado para armazenar o nome do ator
			local este_jogador = misc_cache [spellname]
			if (not este_jogador) then --pode ser um desconhecido ou um pet
				este_jogador = _current_misc_container:PegarCombatente (who_serial, spellname, who_flags, true)
				misc_cache [spellname] = este_jogador
			end

		------------------------------------------------------------------------------------------------
		--build containers on the fly

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
		--add amount

			--update last event
			este_jogador.last_event = _tempo

			--actor target
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

				--death log
					--record death log
					local t = last_events_cache [alvo_name]

					if (not t) then
						t = _current_combat:CreateLastEventsTable (alvo_name)
					end

					local i = t.n

					local this_event = t [i]

					if (not this_event) then
						return print("Parser Event Error -> Set to 16 DeathLogs and /reload", i, _amount_of_last_events)
					end

					this_event [1] = 4 --4 = debuff aplication
					this_event [2] = spellid --spellid
					this_event [3] = 1
					this_event [4] = time --parser time
					this_event [5] = UnitHealth (alvo_name) --current unit heal
					this_event [6] = who_name --source name
					this_event [7] = false
					this_event [8] = false
					this_event [9] = false
					this_event [10] = false

					i = i + 1

					if (i == _amount_of_last_events+1) then
						t.n = 1
					else
						t.n = i
					end

			elseif (in_out == "DEBUFF_UPTIME_REFRESH") then
				if (este_alvo.actived_at and este_alvo.actived) then
					este_alvo.uptime = este_alvo.uptime + _tempo - este_alvo.actived_at
					este_jogador.debuff_uptime = este_jogador.debuff_uptime + _tempo - este_alvo.actived_at
				end
				este_alvo.actived_at = _tempo
				este_alvo.actived = true

				--death log

					--local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura (alvo_name, spellname, nil, "HARMFUL")
					--UnitAura ("Kastfall", "Gulp Frog Toxin", nil, "HARMFUL")

					--record death log
					local t = last_events_cache [alvo_name]

					if (not t) then
						t = _current_combat:CreateLastEventsTable (alvo_name)
					end

					local i = t.n

					local this_event = t [i]

					if (not this_event) then
						return print("Parser Event Error -> Set to 16 DeathLogs and /reload", i, _amount_of_last_events)
					end

					this_event [1] = 4 --4 = debuff aplication
					this_event [2] = spellid --spellid
					this_event [3] = stack_amount or 1
					this_event [4] = time --parser time
					this_event [5] = UnitHealth (alvo_name) --current unit heal
					this_event [6] = who_name --source name
					this_event [7] = false
					this_event [8] = false
					this_event [9] = false
					this_event [10] = false

					i = i + 1

					if (i == _amount_of_last_events+1) then
						t.n = 1
					else
						t.n = i
					end

			elseif (in_out == "DEBUFF_UPTIME_OUT") then
				if (este_alvo.actived_at and este_alvo.actived) then
					este_alvo.uptime = este_alvo.uptime + _detalhes._tempo - este_alvo.actived_at
					este_jogador.debuff_uptime = este_jogador.debuff_uptime + _tempo - este_alvo.actived_at --token = actor misc object
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
	function parser:add_debuff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, in_out)
	------------------------------------------------------------------------------------------------
	--early checks and fixes

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors
		local este_jogador = misc_cache [who_name]
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			misc_cache [who_name] = este_jogador
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly

		if (not este_jogador.debuff_uptime) then
			este_jogador.debuff_uptime = 0
			este_jogador.debuff_uptime_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.debuff_uptime_targets = {}
		end

	------------------------------------------------------------------------------------------------
	--add amount

		--update last event
		este_jogador.last_event = _tempo

		--actor spells table
		local spell = este_jogador.debuff_uptime_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.debuff_uptime_spells:PegaHabilidade (spellid, true, "DEBUFF_UPTIME")
		end
		return _spell_utility_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, este_jogador, "BUFF_OR_DEBUFF", in_out)

	end

	function parser:add_buff_uptime (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, in_out)

	------------------------------------------------------------------------------------------------
	--early checks and fixes

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors
		local este_jogador = misc_cache [who_name]
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			misc_cache [who_name] = este_jogador
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly

		if (not este_jogador.buff_uptime) then
			este_jogador.buff_uptime = 0
			este_jogador.buff_uptime_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.buff_uptime_targets = {}
		end

	------------------------------------------------------------------------------------------------
	--add amount

		--update last event
		este_jogador.last_event = _tempo

		--actor spells table
		local spell = este_jogador.buff_uptime_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.buff_uptime_spells:PegaHabilidade (spellid, true, "BUFF_UPTIME")
		end
		return _spell_utility_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, este_jogador, "BUFF_OR_DEBUFF", in_out)

	end

-----------------------------------------------------------------------------------------------------------------------------------------
	--ENERGY	serach key: ~energy												|
-----------------------------------------------------------------------------------------------------------------------------------------

local PowerEnum = Enum and Enum.PowerType

local SPELL_POWER_MANA = SPELL_POWER_MANA or (PowerEnum and PowerEnum.Mana) or 0
local SPELL_POWER_RAGE = SPELL_POWER_RAGE or (PowerEnum and PowerEnum.Rage) or 1
local SPELL_POWER_FOCUS = SPELL_POWER_FOCUS or (PowerEnum and PowerEnum.Focus) or 2
local SPELL_POWER_ENERGY = SPELL_POWER_ENERGY or (PowerEnum and PowerEnum.Energy) or 3
local SPELL_POWER_COMBO_POINTS2 = SPELL_POWER_COMBO_POINTS or (PowerEnum and PowerEnum.ComboPoints) or 4
local SPELL_POWER_RUNES = SPELL_POWER_RUNES or (PowerEnum and PowerEnum.Runes) or 5
local SPELL_POWER_RUNIC_POWER = SPELL_POWER_RUNIC_POWER or (PowerEnum and PowerEnum.RunicPower) or 6
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS or (PowerEnum and PowerEnum.SoulShards) or 7
local SPELL_POWER_LUNAR_POWER = SPELL_POWER_LUNAR_POWER or (PowerEnum and PowerEnum.LunarPower) or 8
local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER  or (PowerEnum and PowerEnum.HolyPower) or 9
local SPELL_POWER_ALTERNATE_POWER = SPELL_POWER_ALTERNATE_POWER or (PowerEnum and PowerEnum.Alternate) or 10
local SPELL_POWER_MAELSTROM = SPELL_POWER_MAELSTROM or (PowerEnum and PowerEnum.Maelstrom) or 11
local SPELL_POWER_CHI = SPELL_POWER_CHI or (PowerEnum and PowerEnum.Chi) or 12
local SPELL_POWER_INSANITY = SPELL_POWER_INSANITY or (PowerEnum and PowerEnum.Insanity) or 13
local SPELL_POWER_OBSOLETE = SPELL_POWER_OBSOLETE or (PowerEnum and PowerEnum.Obsolete) or 14
local SPELL_POWER_OBSOLETE2 = SPELL_POWER_OBSOLETE2 or (PowerEnum and PowerEnum.Obsolete2) or 15
local SPELL_POWER_ARCANE_CHARGES = SPELL_POWER_ARCANE_CHARGES or (PowerEnum and PowerEnum.ArcaneCharges) or 16
local SPELL_POWER_FURY = SPELL_POWER_FURY or (PowerEnum and PowerEnum.Fury) or 17
local SPELL_POWER_PAIN = SPELL_POWER_PAIN or (PowerEnum and PowerEnum.Pain) or 18

	local energy_types = {
		[SPELL_POWER_MANA] = true,
		[SPELL_POWER_RAGE] = true,
		[SPELL_POWER_ENERGY] = true,
		[SPELL_POWER_RUNIC_POWER] = true,
	}

	local resource_types = {
		[SPELL_POWER_INSANITY] = true, --shadow priest
		[SPELL_POWER_CHI] = true, --monk
		[SPELL_POWER_HOLY_POWER] = true, --paladins
		[SPELL_POWER_LUNAR_POWER] = true, --balance druids
		[SPELL_POWER_SOUL_SHARDS] = true, --warlock affliction
		[SPELL_POWER_COMBO_POINTS2] = true, --combo points
		[SPELL_POWER_MAELSTROM] = true, --shamans
		[SPELL_POWER_PAIN] = true, --demonhunter tank
		[SPELL_POWER_RUNES] = true, --dk
		[SPELL_POWER_ARCANE_CHARGES] = true, --mage
		[SPELL_POWER_FURY] = true, --warrior demonhunter dps
	}

	local resource_power_type = {
		[SPELL_POWER_COMBO_POINTS2] = SPELL_POWER_ENERGY, --combo points
		[SPELL_POWER_SOUL_SHARDS] = SPELL_POWER_MANA, --warlock
		[SPELL_POWER_LUNAR_POWER] = SPELL_POWER_MANA, --druid
		[SPELL_POWER_HOLY_POWER] = SPELL_POWER_MANA, --paladin
		[SPELL_POWER_INSANITY] = SPELL_POWER_MANA, --shadowpriest
		[SPELL_POWER_MAELSTROM] = SPELL_POWER_MANA, --shaman
		[SPELL_POWER_CHI] = SPELL_POWER_MANA, --monk
		[SPELL_POWER_PAIN] = SPELL_POWER_ENERGY, --demonhuinter
		[SPELL_POWER_RUNES] = SPELL_POWER_RUNIC_POWER, --dk
		[SPELL_POWER_ARCANE_CHARGES] = SPELL_POWER_MANA, --mage
		[SPELL_POWER_FURY] = SPELL_POWER_RAGE, --warrior
	}

	_detalhes.resource_strings = {
		[SPELL_POWER_COMBO_POINTS2] = "Combo Point",
		[SPELL_POWER_SOUL_SHARDS] = "Soul Shard",
		[SPELL_POWER_LUNAR_POWER] = "Lunar Power",
		[SPELL_POWER_HOLY_POWER] = "Holy Power",
		[SPELL_POWER_INSANITY] = "Insanity",
		[SPELL_POWER_MAELSTROM] = "Maelstrom",
		[SPELL_POWER_CHI] = "Chi",
		[SPELL_POWER_PAIN] = "Pain",
		[SPELL_POWER_RUNES] = "Runes",
		[SPELL_POWER_ARCANE_CHARGES] = "Arcane Charge",
		[SPELL_POWER_FURY] = "Rage",
	}

	_detalhes.resource_icons = {
		[SPELL_POWER_COMBO_POINTS2] = {file = [[Interface\PLAYERFRAME\ClassOverlayComboPoints]], coords = {58/128, 74/128, 25/64, 39/64}},
		[SPELL_POWER_SOUL_SHARDS] = {file = [[Interface\PLAYERFRAME\UI-WARLOCKSHARD]], coords = {3/64, 17/64, 2/128, 16/128}},
		[SPELL_POWER_LUNAR_POWER] = {file = [[Interface\PLAYERFRAME\DruidEclipse]], coords = {117/256, 140/256, 83/128, 115/128}},
		[SPELL_POWER_HOLY_POWER] = {file = [[Interface\PLAYERFRAME\PALADINPOWERTEXTURES]], coords = {75/256, 94/256, 87/128, 100/128}},
		[SPELL_POWER_INSANITY] = {file = [[Interface\PLAYERFRAME\Priest-ShadowUI]], coords = {119/256, 150/256, 61/128, 94/128}},
		[SPELL_POWER_MAELSTROM] = {file = [[Interface\PLAYERFRAME\MonkNoPower]], coords = {0, 1, 0, 1}},
		[SPELL_POWER_CHI] = {file = [[Interface\PLAYERFRAME\MonkLightPower]], coords = {0, 1, 0, 1}},
		[SPELL_POWER_PAIN] = {file = [[Interface\PLAYERFRAME\Deathknight-Energize-Blood]], coords = {0, 1, 0, 1}},
		[SPELL_POWER_RUNES] = {file = [[Interface\PLAYERFRAME\UI-PlayerFrame-Deathknight-SingleRune]], coords = {0, 1, 0, 1}},
		[SPELL_POWER_ARCANE_CHARGES] = {file = [[Interface\PLAYERFRAME\MageArcaneCharges]], coords = {68/256, 90/256, 68/128, 91/128}},
		[SPELL_POWER_FURY] = {file = [[Interface\PLAYERFRAME\UI-PlayerFrame-Deathknight-Blood-On]], coords = {0, 1, 0, 1}},
	}

	local alternatePowerEnableFrame = CreateFrame("frame")
	local alternatePowerMonitorFrame = CreateFrame("frame")
	alternatePowerEnableFrame:RegisterEvent("UNIT_POWER_BAR_SHOW")
	alternatePowerEnableFrame:RegisterEvent("ENCOUNTER_END")
	alternatePowerEnableFrame.IsRunning = false

	--alternate power will only run when the encounter has a alternate power bar
	alternatePowerEnableFrame:SetScript("OnEvent", function(self, event)
		if (event == "UNIT_POWER_BAR_SHOW") then
			alternatePowerMonitorFrame:RegisterEvent("UNIT_POWER_UPDATE") -- 8.0
			alternatePowerEnableFrame.IsRunning = true

		elseif (alternatePowerEnableFrame.IsRunning and (event == "ENCOUNTER_END" or event == "PLAYER_REGEN_ENABLED")) then
			alternatePowerMonitorFrame:UnregisterEvent("UNIT_POWER_UPDATE")
			alternatePowerEnableFrame.IsRunning = false
		end
	end)

	local onUnitPowerUpdate = function(self, event, unitID, powerType)
		if (powerType == "ALTERNATE") then
			local actorName = _detalhes:GetCLName(unitID)
			if (actorName) then
				local power = _current_combat.alternate_power[actorName]
				if (not power) then
					power = _current_combat:CreateAlternatePowerTable(actorName)
				end

				local currentPower = UnitPower(unitID, 10)
				if (currentPower and currentPower > power.last) then
					local addPower = currentPower - power.last
					power.total = power.total + addPower

					--main actor
					local actorObject = energy_cache[actorName]
					if (not actorObject) then
						--as alternate power bars does not trigger for pets, this is guaranteed to be a player actor
						actorObject = _current_energy_container:PegarCombatente(UnitGUID(unitID), actorName, 0x514, true)
						energy_cache[actorName] = actorObject
					end

					actorObject.alternatepower = actorObject.alternatepower + addPower
					_current_energy_container.need_refresh = true
				end

				power.last = currentPower or 0
			end
		end
	end

	alternatePowerMonitorFrame:SetScript("OnEvent", onUnitPowerUpdate)

	---this function captures when the energy of a unit is at its max capacity on classes which auto regenerates it's power such like Rogues
	---staying at max capacity prevents it to generate more energy and causes a power overflow
	local regen_power_overflow_check = function()
		if (not _in_combat) then
			return
		end

		for playerName, powerType in pairs(auto_regen_cache) do
			local currentPower = UnitPower(playerName, powerType) or 0
			local maxPower = UnitPowerMax(playerName, powerType) or 1

			if (currentPower == maxPower) then
				--power overflow
				local energyObject = energy_cache[playerName]
				if (energyObject) then
					energyObject.passiveover = energyObject.passiveover + AUTO_REGEN_PRECISION
				end
			end
		end
	end

	-- ~energy ~resource
	function parser:energize (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, amount, overpower, powertype, altpower)

	------------------------------------------------------------------------------------------------
	--early checks and fixes
		if (not who_name) then
			who_name = "[*] "..spellname
		elseif (not alvo_name) then
			return
		end

	------------------------------------------------------------------------------------------------
	--check if is energy or resource

		--Details:Dump({token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, amount, overpower, powertype, altpower})

		--get resource type
		local is_resource, resource_amount, resource_id = resource_power_type [powertype], amount, powertype

		--check if is valid
		if (not energy_types [powertype] and not is_resource) then
			return

		elseif (is_resource) then
			powertype = is_resource
			amount = 0
		end

		overpower = overpower or 0

		--[[statistics]]-- _detalhes.statistics.energy_calls = _detalhes.statistics.energy_calls + 1

		_current_energy_container.need_refresh = true

------------------------------------------------------------------------------------------------
	--get actors

		--main actor
		local este_jogador, meu_dono = energy_cache [who_name] --meu_dono is always nil
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_energy_container:PegarCombatente (who_serial, who_name, who_flags, true)
			este_jogador.powertype = powertype
			if (meu_dono) then
				meu_dono.powertype = powertype
			end
			if (not meu_dono) then --se n�o for um pet, adicionar no cache
				--does pet generates energy to its owner in any circustance?
				energy_cache [who_name] = este_jogador
			end
		end

		if (not este_jogador.powertype) then
			este_jogador.powertype = powertype
		end

		--target
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
			--print("error: different power types: who -> ", este_jogador.powertype, " target -> ", jogador_alvo.powertype)
			return
		end

		este_jogador.last_event = _tempo

	------------------------------------------------------------------------------------------------
	--amount add

		if (not is_resource) then

			--amount = amount - overpower

			--add to targets
			este_jogador.targets [alvo_name] = (este_jogador.targets [alvo_name] or 0) + amount

			--add to combat total
			_current_total [3] [powertype] = _current_total [3] [powertype] + amount

			if (este_jogador.grupo) then
				_current_gtotal [3] [powertype] = _current_gtotal [3] [powertype] + amount
			end

			--regen produced amount
			este_jogador.total = este_jogador.total + amount
			este_jogador.totalover = este_jogador.totalover + overpower

			--target regenerated amount
			jogador_alvo.received = jogador_alvo.received + amount

			--owner
			if (meu_dono) then
				meu_dono.total = meu_dono.total + amount
			end

			--actor spells table
			local spellTable = este_jogador.spells._ActorTable[spellid]
			if (not spellTable) then
				spellTable = este_jogador.spells:PegaHabilidade(spellid, true, token)
			end

			--return spell:Add (alvo_serial, alvo_name, alvo_flags, amount, who_name, powertype)
			return _spell_energy_func (spellTable, alvo_serial, alvo_name, alvo_flags, amount, who_name, powertype, overpower)
		else
			--is a resource
			este_jogador.resource = este_jogador.resource + resource_amount
			este_jogador.resource_type = resource_id
		end
	end



-----------------------------------------------------------------------------------------------------------------------------------------
	--MISC 	search key: ~cooldown											|
-----------------------------------------------------------------------------------------------------------------------------------------

	function parser:add_defensive_cooldown(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName)
	------------------------------------------------------------------------------------------------
	--early checks and fixes

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors

		--main actor
		local sourceActor, ownerActor = misc_cache[sourceName], nil
		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_misc_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
			if (not ownerActor) then
				misc_cache[sourceName] = sourceActor
			end
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly
		if (not sourceActor.cooldowns_defensive) then
			sourceActor.cooldowns_defensive = _detalhes:GetOrderNumber(sourceName)
			sourceActor.cooldowns_defensive_targets = {}
			sourceActor.cooldowns_defensive_spells = container_habilidades:NovoContainer(container_misc)
		end

		--local targetActor, targetOwner = damage_cache[targetSerial] or damage_cache_pets[targetSerial] or damage_cache[targetName], damage_cache_petsOwners[targetSerial]
		--sourceActor, ownerActor, sourceName

	------------------------------------------------------------------------------------------------
	--add amount

		--actor cooldowns used
		sourceActor.cooldowns_defensive = sourceActor.cooldowns_defensive + 1

		--combat totals
		_current_total[4].cooldowns_defensive = _current_total[4].cooldowns_defensive + 1

		if (sourceActor.grupo) then
			_current_gtotal[4].cooldowns_defensive = _current_gtotal[4].cooldowns_defensive + 1

			if (sourceName == targetName) then
				--[=[
				local damage_actor = damage_cache[sourceSerial]
				if (not damage_actor) then
					damage_actor = _current_damage_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
					if (sourceFlags) then
						damage_cache[sourceSerial] = damage_actor
					end
				end
				--]=]

				--last events
				local t = last_events_cache[sourceName]

				if (not t) then
					t = _current_combat:CreateLastEventsTable(sourceName)
				end

				local i = t.n
				local thisEvent = t [i]

				thisEvent[1] = 1 --true if this is a damage || false for healing || 1 for cooldown
				thisEvent[2] = spellId --spellid || false if this is a battle ress line
				thisEvent[3] = 1 --amount of damage or healing
				thisEvent[4] = time
				thisEvent[5] = UnitHealth(sourceName)
				thisEvent[6] = sourceName

				i = i + 1
				if (i == _amount_of_last_events+1) then
					t.n = 1
				else
					t.n = i
				end

				sourceActor.last_cooldown = {time, spellId}
			end
		end

		--update last event
		sourceActor.last_event = _tempo

		--actor targets
		sourceActor.cooldowns_defensive_targets[targetName] = (sourceActor.cooldowns_defensive_targets [targetName] or 0) + 1

		--actor spells table
		local spellTable = sourceActor.cooldowns_defensive_spells._ActorTable[spellId]
		if (not spellTable) then
			spellTable = sourceActor.cooldowns_defensive_spells:PegaHabilidade(spellId, true, token)
		end

		if (_hook_cooldowns) then
			--send event to registred functions
			for i = 1, #_hook_cooldowns_container do
				local successful, errorText = pcall(_hook_cooldowns_container[i], nil, token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, spellId, spellName)
				if (not successful) then
					_detalhes:Msg("error occurred on a cooldown hook function:", errorText)
				end
			end
		end

		return _spell_utility_func(spellTable, targetSerial, targetName, targetFlags, sourceName, token, "BUFF_OR_DEBUFF", "COOLDOWN")
	end

	--serach key: ~interrupts
	---comment: this function is called when a spell is interrupted
	---@param token string
	---@param time number
	---@param sourceSerial string
	---@param sourceName string
	---@param sourceFlags number
	---@param targetSerial string
	---@param targetName string
	---@param targetFlags number
	---@param targetFlags2 number
	---@param spellId number
	---@param spellName string
	---@param spellType number
	---@param extraSpellID number
	---@param extraSpellName string
	---@param extraSchool number
	function parser:interrupt(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellType, extraSpellID, extraSpellName, extraSchool)
		--quake affix from mythic+
		if (spellId == 240448) then
			return
		end

		if (not sourceName) then
			sourceName = "[*] "..spellName

		elseif (not targetName) then
			return
		end

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors
		--main actor
		local sourceActor, ownerActor = misc_cache[sourceName], nil
		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_misc_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
			if (not ownerActor) then
				misc_cache[sourceName] = sourceActor
			end
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly
		if (not sourceActor.interrupt) then
			sourceActor.interrupt = _detalhes:GetOrderNumber(sourceName)
			sourceActor.interrupt_targets = {}
			sourceActor.interrupt_spells = container_habilidades:NovoContainer(container_misc)
			sourceActor.interrompeu_oque = {}
		end

	------------------------------------------------------------------------------------------------
	--add amount

		--actor interrupt amount
		sourceActor.interrupt = sourceActor.interrupt + 1

		--combat totals
		_current_total[4].interrupt = _current_total[4].interrupt + 1

		if (sourceActor.grupo) then
			_current_gtotal[4].interrupt = _current_gtotal[4].interrupt + 1
		end

		--update last event
		sourceActor.last_event = _tempo

		--spells interrupted
		sourceActor.interrompeu_oque[extraSpellID] = (sourceActor.interrompeu_oque[extraSpellID] or 0) + 1

		--actor targets
		sourceActor.interrupt_targets[targetName] = (sourceActor.interrupt_targets[targetName] or 0) + 1

		--actor spells table
		local spell = sourceActor.interrupt_spells._ActorTable[spellId]
		if (not spell) then
			spell = sourceActor.interrupt_spells:PegaHabilidade(spellId, true, token)
		end
		_spell_utility_func(spell, targetSerial, targetName, targetFlags, sourceName, token, extraSpellID, extraSpellName)

		--verifica se tem dono e adiciona o interrupt para o dono
		if (ownerActor) then
			if (not ownerActor.interrupt) then
				ownerActor.interrupt = _detalhes:GetOrderNumber(sourceName)
				ownerActor.interrupt_targets = {}
				ownerActor.interrupt_spells = container_habilidades:NovoContainer(container_misc)
				ownerActor.interrompeu_oque = {}
			end

			-- adiciona ao total
			ownerActor.interrupt = ownerActor.interrupt + 1

			-- adiciona aos alvos
			ownerActor.interrupt_targets[targetName] = (ownerActor.interrupt_targets[targetName] or 0) + 1

			-- update last event
			ownerActor.last_event = _tempo

			-- spells interrupted
			ownerActor.interrompeu_oque[extraSpellID] = (ownerActor.interrompeu_oque[extraSpellID] or 0) + 1

			--pet interrupt
			if (_hook_interrupt) then
				for _, func in ipairs(_hook_interrupt_container) do
					func(nil, token, time, ownerActor.serial, ownerActor.nome, ownerActor.flag_original, targetSerial, targetName, targetFlags, spellId, spellName, spellType, extraSpellID, extraSpellName, extraSchool)
				end
			end
		else
			--player interrupt
			if (_hook_interrupt) then
				for _, func in ipairs(_hook_interrupt_container) do
					func(nil, token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, spellId, spellName, spellType, extraSpellID, extraSpellName, extraSchool)
				end
			end
		end
	end

	---search key: ~spellcast ~castspell ~cast
	---comment: this function is called when a spell is casted
	---@param token string
	---@param time number
	---@param sourceSerial string
	---@param sourceName string
	---@param sourceFlags number
	---@param targetSerial string
	---@param targetName string
	---@param targetFlags number
	---@param targetRaidFlags number
	---@param spellId number
	---@param spellName string
	---@param spellType number
	function parser:spellcast(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetRaidFlags, spellId, spellName, spellType)
		--only capture if is in combat
		if (not _in_combat) then
			return
		end

		if (not sourceName) then
			sourceName = "[*] " .. spellName
		end

		---@type actor, actor
		local sourceActor, ownerActor = misc_cache[sourceSerial] or misc_cache_pets[sourceSerial] or misc_cache[sourceName], misc_cache_petsOwners[sourceSerial]
		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_misc_container:PegarCombatente (sourceSerial, sourceName, sourceFlags, true)
			if (ownerActor) then
				if (sourceSerial ~= "") then
					misc_cache_pets [sourceSerial] = sourceActor
					misc_cache_petsOwners [sourceSerial] = ownerActor
				end
				if (not misc_cache[ownerActor.serial] and ownerActor.serial ~= "") then
					misc_cache[ownerActor.serial] = ownerActor
				end
			else
				if (sourceFlags) then
					misc_cache[sourceName] = sourceActor
				end
			end
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly
		--amount of casts by actors ~casts
		local castsByPlayer = _current_combat.amountCasts[sourceName]
		if (not castsByPlayer) then
			castsByPlayer = {}
			_current_combat.amountCasts[sourceName] = castsByPlayer
		end
		local amountOfCasts = _current_combat.amountCasts[sourceName][spellName] or 0
		amountOfCasts = amountOfCasts + 1
		_current_combat.amountCasts[sourceName][spellName] = amountOfCasts

		--if (sourceSerial == UnitGUID("player")) then
		--	print(sourceName, spellName, amountOfCasts)
		--end

	------------------------------------------------------------------------------------------------
	--record cooldowns cast which can't track with buff applyed
		--a player is the caster
		if (raid_members_cache[sourceSerial]) then
			--check if is a cooldown
			local cooldownInfo = defensive_cooldowns[spellId]
			if (cooldownInfo) then
				if (not targetName) then
					if (cooldownInfo.type == 2 or cooldownInfo.type == 3) then
						targetName = sourceName
					elseif (cooldownInfo.type == 4) then
						targetName = Loc ["STRING_RAID_WIDE"]
					else
						targetName = "--x--x--"
					end
				end
				return parser:add_defensive_cooldown(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetRaidFlags, spellId, spellName)
			end
		else
			--enemy successful casts (not interrupted)
			if (bitBand(sourceFlags, 0x00000040) ~= 0 and sourceName) then --byte 2 = 4 (enemy)
				--damager
				---@type actor
				local enemyActorObject = damage_cache[sourceSerial]
				if (not enemyActorObject) then
					enemyActorObject = _current_damage_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
				end

				if (enemyActorObject) then
					--actor spells table
					---@type spelltable
					local spellTable = enemyActorObject.spells._ActorTable[spellId]
					if (not spellTable) then
						spellTable = enemyActorObject.spells:PegaHabilidade(spellId, true, token)
					end
					spellTable.successful_casted = spellTable.successful_casted + 1
				end

				--add the spellId in the enemy_cast_cache table to store the time the enemy successfully cast a spell
				--check if the spell is in the table
				local enemyName = sourceName

				if (not enemy_cast_cache[time]) then
					enemy_cast_cache[time] = {enemyName, spellId, 1}
				else
					enemy_cast_cache[time][3] = enemy_cast_cache[time][3] + 1
				end
			end
		end
	end


	--serach key: ~dispell
	function parser:dispell (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool, auraType)

	------------------------------------------------------------------------------------------------
	--early checks and fixes

		--esta dando erro onde o nome � NIL, fazendo um fix para isso
		if (not who_name) then
			who_name = "[*] "..extraSpellName
		end
		if (not alvo_name) then
			alvo_name = "[*] "..spellid
		end

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors]
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --se n�o for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly

		if (not este_jogador.dispell) then
			--constr�i aqui a tabela dele
			este_jogador.dispell = _detalhes:GetOrderNumber(who_name)
			este_jogador.dispell_targets = {}
			este_jogador.dispell_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.dispell_oque = {}
		end

	------------------------------------------------------------------------------------------------
	--spell reflection
		if (reflection_dispelid[spellid]) then
			--this aura could've been reflected to the caster after the dispel
			--save data about whom was dispelled by who and what spell it was
			reflection_dispels[alvo_serial] = reflection_dispels[alvo_serial] or {}
			reflection_dispels[alvo_serial][extraSpellID] = {
				who_serial = who_serial,
				who_name = who_name,
				who_flags = who_flags,
				spellid = spellid,
				spellname = spellname,
				spelltype = spelltype,
			}
		end

	------------------------------------------------------------------------------------------------
	--add amount

		--last event update
		este_jogador.last_event = _tempo

		--total dispells in combat
		_current_total [4].dispell = _current_total [4].dispell + 1

		if (este_jogador.grupo) then
			_current_gtotal [4].dispell = _current_gtotal [4].dispell + 1
		end

		--actor dispell amount
		este_jogador.dispell = este_jogador.dispell + 1

		--dispell what
		if (extraSpellID) then
			este_jogador.dispell_oque [extraSpellID] = (este_jogador.dispell_oque [extraSpellID] or 0) + 1
		end

		--actor targets
		este_jogador.dispell_targets [alvo_name] = (este_jogador.dispell_targets [alvo_name] or 0) + 1

		--actor spells table
		local spell = este_jogador.dispell_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.dispell_spells:PegaHabilidade (spellid, true, token)
		end
		_spell_utility_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)

		--verifica se tem dono e adiciona o interrupt para o dono
		if (meu_dono) then
			if (not meu_dono.dispell) then
				meu_dono.dispell = _detalhes:GetOrderNumber(who_name)
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
	function parser:ress (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname)

	------------------------------------------------------------------------------------------------
	--early checks and fixes

		if (bitBand(who_flags, AFFILIATION_GROUP) == 0) then
			return
		end

		--do not register ress if not in combat
		if (not Details.in_combat) then
			return
		end

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors

		--main actor
		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --se n�o for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly

		if (not este_jogador.ress) then
			este_jogador.ress = _detalhes:GetOrderNumber(who_name)
			este_jogador.ress_targets = {}
			este_jogador.ress_spells = container_habilidades:NovoContainer (container_misc) --cria o container das habilidades usadas para interromper
		end

	------------------------------------------------------------------------------------------------
	--add amount

		--update last event
		este_jogador.last_event = _tempo

		--combat ress total
		_current_total [4].ress = _current_total [4].ress + 1

		if (este_jogador.grupo) then
			_current_combat.totals_grupo[4].ress = _current_combat.totals_grupo[4].ress+1
		end

		--add ress amount
		este_jogador.ress = este_jogador.ress + 1

		--add battle ress
		if (UnitAffectingCombat(who_name)) then
			--procura a �ltima morte do alvo na tabela do combate:
			for i = 1, #_current_combat.last_events_tables do
				if (_current_combat.last_events_tables [i] [3] == alvo_name) then

					local deadLog = _current_combat.last_events_tables [i] [1]
					local jaTem = false
					for _, evento in ipairs(deadLog) do
						if (evento [1] and not evento[3]) then
							jaTem = true
						end
					end

					if (not jaTem) then
						tinsert(_current_combat.last_events_tables [i] [1], 1, {
							2,
							spellid,
							1,
							time,
							UnitHealth (alvo_name),
							who_name
						})
						break
					end
				end
			end

			if (_hook_battleress) then
				for _, func in ipairs(_hook_battleress_container) do
					func (nil, token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname)
				end
			end

		end

		--actor targets
		este_jogador.ress_targets [alvo_name] = (este_jogador.ress_targets [alvo_name] or 0) + 1

		--actor spells table
		local spell = este_jogador.ress_spells._ActorTable [spellid]
		if (not spell) then
			spell = este_jogador.ress_spells:PegaHabilidade (spellid, true, token)
		end
		return _spell_utility_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, token, extraSpellID, extraSpellName)
	end

	--serach key: ~cc
	function parser:break_cc (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool, auraType)

	------------------------------------------------------------------------------------------------
	--early checks and fixes
		if (not cc_spell_list [spellid]) then
			return
			--print("NO CC:", spellid, spellname, extraSpellID, extraSpellName)
		end

		if (bitBand(who_flags, AFFILIATION_GROUP) == 0) then
			return
		end

		if (not spellname) then
			spellname = "Melee"
		end

		if (not alvo_name) then
			--no target name, just quit
			return

		elseif (not who_name) then
			--no actor name, use spell name instead
			who_name = "[*] " .. spellname
			who_flags = 0xa48
			who_serial = ""
		end

		_current_misc_container.need_refresh = true

	------------------------------------------------------------------------------------------------
	--get actors

		local este_jogador, meu_dono = misc_cache [who_name]
		if (not este_jogador) then --pode ser um desconhecido ou um pet
			este_jogador, meu_dono, who_name = _current_misc_container:PegarCombatente (who_serial, who_name, who_flags, true)
			if (not meu_dono) then --se n�o for um pet, adicionar no cache
				misc_cache [who_name] = este_jogador
			end
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly

		if (not este_jogador.cc_break) then
			--constr�i aqui a tabela dele
			este_jogador.cc_break = _detalhes:GetOrderNumber(who_name)
			este_jogador.cc_break_targets = {}
			este_jogador.cc_break_spells = container_habilidades:NovoContainer (container_misc)
			este_jogador.cc_break_oque = {}
		end

	------------------------------------------------------------------------------------------------
	--add amount

		--update last event
		este_jogador.last_event = _tempo

		--combat cc break total
		_current_total [4].cc_break = _current_total [4].cc_break + 1

		if (este_jogador.grupo) then
			_current_combat.totals_grupo[4].cc_break = _current_combat.totals_grupo[4].cc_break+1
		end

		--add amount
		este_jogador.cc_break = este_jogador.cc_break + 1

		--broke what
		este_jogador.cc_break_oque [spellid] = (este_jogador.cc_break_oque [spellid] or 0) + 1

		--actor targets
		este_jogador.cc_break_targets [alvo_name] = (este_jogador.cc_break_targets [alvo_name] or 0) + 1

		--actor spells table
		local spell = este_jogador.cc_break_spells._ActorTable [extraSpellID]
		if (not spell) then
			spell = este_jogador.cc_break_spells:PegaHabilidade (extraSpellID, true, token)
		end
		return _spell_utility_func (spell, alvo_serial, alvo_name, alvo_flags, who_name, token, spellid, spellname)
	end

	--serach key: ~dead ~death ~morte
	---when a player dies, save the events that lead to his death
	---this is used to show the last events before the player died under the Deaths display
	---the first index of the table which hold a single event tells the type of event happened, there are the types:
	---boolean true: the player took damage
	---boolean false: the player received heal from someone
	---number 1: the player used a cooldown
	---number 2: the player received a battle res
	---number 3: tell which was the latest cooldown used by the player
	---number 4: debuff the player received
	---number 5: buff the player received
	---number 6: emeny casted a spell
	---@param token string
	---@param time number
	---@param sourceSerial string
	---@param sourceName string
	---@param sourceFlags number
	---@param targetSerial string
	---@param targetName string
	---@param targetFlags number
	function parser:dead (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags)
	--early checks and fixes
		if (not targetName) then
			return
		end

	------------------------------------------------------------------------------------------------
	--build dead

		local damageActor = _current_damage_container:GetActor(targetName)
		--check for outsiders
		if (_in_combat and targetFlags and (not damageActor or (bitBand(targetFlags, 0x00000008) ~= 0 and not damageActor.grupo))) then
			--frags
				if (_detalhes.only_pvp_frags and (bitBand(targetFlags, 0x00000400) == 0 or (bitBand(targetFlags, 0x00000040) == 0 and bitBand(targetFlags, 0x00000020) == 0))) then --byte 2 = 4 (HOSTILE) byte 3 = 4 (OBJECT_TYPE_PLAYER)
					return
				end

				if (not _current_combat.frags [targetName]) then
					_current_combat.frags [targetName] = 1
				else
					_current_combat.frags [targetName] = _current_combat.frags [targetName] + 1
				end

				_current_combat.frags_need_refresh = true

		--player death
		elseif (not UnitIsFeignDeath(targetName)) then
			if (
				--player in your group
				(bitBand(targetFlags, AFFILIATION_GROUP) ~= 0 or (damageActor and damageActor.grupo)) and
				--must be a player
				bitBand(targetFlags, OBJECT_TYPE_PLAYER) ~= 0 and
				--must be in combat
				_in_combat
			) then
				if (ignore_death_cache[targetName]) then
					ignore_death_cache[targetName] = nil
					return
				end

				local bIsMythicRun = false
				--check if this is a mythic+ run for overall deaths
				local mythicLevel = C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo() --classic wow doesn't not have C_ChallengeMode API
				if (mythicLevel and type(mythicLevel) == "number" and mythicLevel >= 2) then --several checks to be future proof
					bIsMythicRun = true
				end

				_current_misc_container.need_refresh = true

				--combat totals
				_current_total [4].dead = _current_total [4].dead + 1
				_current_gtotal [4].dead = _current_gtotal [4].dead + 1

				--main actor no container de misc que ir� armazenar a morte
				local thisPlayer, meu_dono = misc_cache [targetName]
				if (not thisPlayer) then --pode ser um desconhecido ou um pet
					thisPlayer, meu_dono, sourceName = _current_misc_container:PegarCombatente (targetSerial, targetName, targetFlags, true)
					if (not meu_dono) then --se n�o for um pet, adicionar no cache
						misc_cache [targetName] = thisPlayer
					end
				end

				--table where the events will be placed in order, other events will also be added, for example, the last cooldown used by the player
				local eventsBeforePlayerDeath = {}

				--get the table where is registered the last events before the player died
				local recordedEvents = last_events_cache[targetName]
				if (not recordedEvents) then
					recordedEvents = _current_combat:CreateLastEventsTable(targetName)
				end

				--during a regular combat, 99.9% of the events aren't used by the death log
				--hence the process of getting data for the death log is made as fast as it can be
				--when a death occurs, the death log data is then parsed and built, the next 200 lines does this processing

				--lesses index = older / higher index = newer

				--[=[
					eventTable [1] = type of the event
					eventTable [2] = spellId --spellid or false if this is a battle ress event
					eventTable [3] = amount --amount of damage or healing
					eventTable [4] = time --unix time
					eventTable [5] = player health when the event happened
					eventTable [6] = name of the actor which caused this event
					eventTable [7] = absorbed
					eventTable [8] = spell school
					eventTable [9] = friendly fire
					eventTable [10] = amount of overkill damage
				--]=]

				--get the index of the last event recorded
				local lastIndex = recordedEvents.n

				if (lastIndex < _amount_of_last_events+1 and not recordedEvents[lastIndex][4]) then
					--the last events table amount of indexes is less than the amount of events to store
					for i = 1, lastIndex-1 do
						if (recordedEvents[i][4] and recordedEvents[i][4]+_amount_of_last_events > time) then
							tinsert(eventsBeforePlayerDeath, recordedEvents[i])
						end
					end
				else
					--go from the index where the last event was stored to the end of the table
					for i = lastIndex, _amount_of_last_events do
						if (recordedEvents[i][4] and recordedEvents[i][4]+_amount_of_last_events > time) then
							tinsert(eventsBeforePlayerDeath, recordedEvents[i])
						end
					end

					--go from the start of the table to the index where the last event minus 1 was stored
					for i = 1, lastIndex-1 do
						if (recordedEvents[i][4] and recordedEvents[i][4]+_amount_of_last_events > time) then
							tinsert(eventsBeforePlayerDeath, recordedEvents[i])
						end
					end
				end

				local bHadDeathEvent = false
				local firstEventTime
				local lastEventTime

				if (eventsBeforePlayerDeath[1]) then
					bHadDeathEvent = true
					firstEventTime = eventsBeforePlayerDeath[1][4]
					lastEventTime = eventsBeforePlayerDeath[#eventsBeforePlayerDeath][4]
				end

				--enemy_cast_cache store the time of the event as key and a table as value
				--the value has [1] = enemyName, [2] = spellid, [3] = amount of casts on that time (in case many enemies casted the same spell at the same time)
				--enemy_cast_cache[time] = {enemyName, spellId, 1}
				local enemyCastCache = enemy_cast_cache

				--as multiple enemies can have casted the same spell at the same time, iterate over the enemyCastCache and merge the casts that happened really close to each other
				--transfer the casts that happened within the the events window of the player death to a new indexed table
				local enemyCastCacheIndexed = {}
				if (bHadDeathEvent) then
					for time, enemyCastTable in pairs(enemyCastCache) do
						if (time >= firstEventTime and time <= lastEventTime) then
							enemyCastCacheIndexed[#enemyCastCacheIndexed+1] = {time, unpack(enemyCastTable)} --time, enemyName, spellId, amount of casts
						end
					end
				end

				--sort enemy casts events to place earlier casts in the first indexes of the table
				table.sort(enemyCastCacheIndexed, function(t1, t2) return t1[1] < t2[1] end)

				--iterate among the enemy cast events and remove cast events that are too close to each other
				for i = #enemyCastCacheIndexed, 1, -1 do
					local previousEnemyCastEvent = enemyCastCacheIndexed[i-1]
					if (previousEnemyCastEvent) then
						local nextEnemyCastEvent = enemyCastCacheIndexed[i]
						if (previousEnemyCastEvent[1]+0.1 > nextEnemyCastEvent[1]) then
							if (previousEnemyCastEvent[3] == nextEnemyCastEvent[3]) then
								enemyCastCacheIndexed[i] = nil
								--as the event got removed, add a cast event to the previous event
								previousEnemyCastEvent[4] = previousEnemyCastEvent[4] + 1
							end
						end
					end
				end

				--iterage among eventsBeforePlayerDeath and add the enemy casts events that happened within the last events time window
				local currentEnemyCastIndex = 1
				for i = 1, #eventsBeforePlayerDeath do
					local eventTable = eventsBeforePlayerDeath[i]
					local eventTime = eventTable[4]

					for enemyCastEventIndex = currentEnemyCastIndex, #enemyCastCacheIndexed do
						local enemyCastEvent = enemyCastCacheIndexed[enemyCastEventIndex]
						if (enemyCastEvent) then
							local enemyCastTime = enemyCastEvent[1]
							local enemyName = enemyCastEvent[2]
							local spellId = enemyCastEvent[3]
							local castAmount = enemyCastEvent[4]

							if (enemyCastTime+0.1 > eventTime and enemyCastTime+0.1 - eventTime < 0.3) then
								--create a new event to show the cast and add it to the list of events before death
								local eventType = 6 --cast
								local newEventTable = {}
								newEventTable[1] = eventType
								newEventTable[2] = spellId --spellId
								newEventTable[3] = castAmount --amount of casts
								newEventTable[4] = enemyCastTime --when the event happened using unix time
								newEventTable[5] = 0 --player health when the event happened
								newEventTable[6] = enemyName --source name
								--print("addin enemy cast event", alvo_name, i, enemyCastTime+0.1, ">", eventTime)
								tinsert(eventsBeforePlayerDeath, i, newEventTable)
								currentEnemyCastIndex = enemyCastEventIndex + 1
								break
							end
						end
					end
				end

				if (thisPlayer.last_cooldown) then
					--create a new event to show the latest cooldown the player used before death and add it to the list of events before death
					local eventType = 3 --last cooldown used
					local eventTable = {}
					eventTable[1] = eventType
					eventTable[2] = thisPlayer.last_cooldown[2] --spellId
					eventTable[3] = 0 --amount of damage or healing but in this case is 0
					eventTable[4] = thisPlayer.last_cooldown[1] --when the event happened using unix time
					eventTable[5] = 0 --player health when the event happened
					eventTable[6] = targetName --source name
					eventsBeforePlayerDeath[#eventsBeforePlayerDeath+1] = eventTable
				else
					--no last cooldown found so just add a last cooldown used event with no spellId and time 0
					local eventTable = {}
					eventTable [1] = 3 --true if this is a damage || false for healing || 1 for cooldown usage || 2 for last cooldown
					eventTable [2] = 0 --spellId
					eventTable [3] = 0 --amount of damage or healing but in this case is 0
					eventTable [4] = 0 --when the event happened using unix time
					eventTable [5] = 0 --player health when the event happened
					eventTable [6] = targetName --source name
					eventsBeforePlayerDeath[#eventsBeforePlayerDeath+1] = eventTable
				end

				local maxHealth
				if (thisPlayer.arena_enemy) then
					--this is an arena enemy, get the heal with the unit Id
					local unitId = _detalhes.arena_enemies[thisPlayer.nome]
					if (not unitId) then
						unitId = Details:GuessArenaEnemyUnitId(thisPlayer.nome)
					end
					if (unitId) then
						maxHealth = UnitHealthMax(unitId)
					end

					if (not maxHealth) then
						maxHealth = 0
					end
				else
					maxHealth = UnitHealthMax(thisPlayer.nome)
				end

				local playerDeathTable
				local combatElapsedTime = GetTime() - _current_combat:GetStartTime()

				do
					local minutes, seconds = floor(combatElapsedTime /  60), floor(combatElapsedTime % 60)

					playerDeathTable = {
						eventsBeforePlayerDeath, --table
						time, --number unix time
						thisPlayer.nome, --string player name
						thisPlayer.classe, --string player class
						maxHealth, --number max health
						minutes .. "m " .. seconds .. "s", --time of death as string
						["dead"] = true,
						["last_cooldown"] = thisPlayer.last_cooldown,
						["dead_at"] = combatElapsedTime,
					}
				end

				tinsert(_current_combat.last_events_tables, #_current_combat.last_events_tables+1, playerDeathTable)

				--check if this is a mythic+ run for overall deaths
				if (bIsMythicRun) then
					--more checks for integrity
					if (_detalhes.tabela_overall and _detalhes.tabela_overall.last_events_tables) then
						--this is a mythic dungeon run, add the death to overall data
						--need to adjust the time of death, since this will show all deaths in the mythic run
						--first copy the table
						local overallDeathTable = DetailsFramework.table.copy({}, playerDeathTable)

						--get the elapsed time
						local mythicPlusElapsedTime = GetTime() - _detalhes.tabela_overall:GetStartTime()
						local minutes, seconds = floor(mythicPlusElapsedTime/60), floor(mythicPlusElapsedTime % 60)

						overallDeathTable[6] = minutes .. "m " .. seconds .. "s"
						overallDeathTable.dead_at = mythicPlusElapsedTime

						--save data about the mythic run in the deathTable which goes in the regular segment
						--confused? 'playerDeathTable' is added into the '_current_combat.last_events_tables' ~20 above on a tinsert
						playerDeathTable["mythic_plus"] = true
						playerDeathTable["mythic_plus_dead_at"] = mythicPlusElapsedTime
						playerDeathTable["mythic_plus_dead_at_string"] = overallDeathTable[6]

						--now add the death table into the overall data (this is the regular overall data, not the mythic plus overall data)
						tinsert(_detalhes.tabela_overall.last_events_tables, #_detalhes.tabela_overall.last_events_tables + 1, overallDeathTable)
					end
				end

				if (_hook_deaths) then
					--send event to registred functions
					for _, func in ipairs(_hook_deaths_container) do
						local successful, errortext = pcall(func, nil, token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, playerDeathTable, thisPlayer.last_cooldown, combatElapsedTime, maxHealth, playerDeathTable["mythic_plus_dead_at"] or 0)
						if (not successful) then
							_detalhes:Msg("error occurred on a death hook function:", errortext)
						end
					end
				end

				--remove the player death events from the cache
				last_events_cache[targetName] = nil
			end
		end
	end

	function parser:environment(token, time, sourceSerial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, env_type, amount)
		local spelId

		if (env_type == "Falling") then
			who_name = ENVIRONMENTAL_FALLING_NAME
			spelId = 3
		elseif (env_type == "Drowning") then
			who_name = ENVIRONMENTAL_DROWNING_NAME
			spelId = 4
		elseif (env_type == "Fatigue") then
			who_name = ENVIRONMENTAL_FATIGUE_NAME
			spelId = 5
		elseif (env_type == "Fire") then
			who_name = ENVIRONMENTAL_FIRE_NAME
			spelId = 6
		elseif (env_type == "Lava") then
			who_name = ENVIRONMENTAL_LAVA_NAME
			spelId = 7
		elseif (env_type == "Slime") then
			who_name = ENVIRONMENTAL_SLIME_NAME
			spelId = 8
		end

		return parser:spell_dmg(token, time, sourceSerial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spelId or 1, env_type, 00000003, amount, -1, 1)
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core

	function parser:WipeSourceCache()
		wipe (monk_guard_talent)
	end

	local token_list = {
		-- neutral
		["SPELL_SUMMON"] = parser.summon,
		--["SPELL_CAST_FAILED"] = parser.spell_fail
	}

	--@debug@ 
	Details.token_list = token_list
	--@end-debug@

	--serach key: ~capture

	_detalhes.capture_types = {"damage", "heal", "energy", "miscdata", "aura", "spellcast"}
	_detalhes.capture_schedules = {}

	function _detalhes:CaptureIsAllEnabled()
		for _, _thisType in ipairs(_detalhes.capture_types) do
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
		for _, _thisType in ipairs(_detalhes.capture_types) do
			if (_detalhes.capture_current [_thisType]) then
				_detalhes:CaptureEnable (_thisType)
			else
				_detalhes:CaptureDisable (_thisType)
			end
		end
	end

	function _detalhes:CaptureGet(capture_type)
		return _detalhes.capture_real [capture_type]
	end

	function _detalhes:CaptureSet (on_off, capture_type, real, time)

		if (on_off == nil) then
			on_off = _detalhes.capture_real [capture_type]
		end

		if (real) then
			--hard switch
			_detalhes.capture_real [capture_type] = on_off
			_detalhes.capture_current [capture_type] = on_off
		else
			--soft switch
			_detalhes.capture_current [capture_type] = on_off
			if (time) then
				local schedule_id = math.random(1, 10000000)
				local new_schedule = _detalhes:ScheduleTimer("CaptureTimeout", time, {capture_type, schedule_id})
				tinsert(_detalhes.capture_schedules, {new_schedule, schedule_id})
			end
		end

		_detalhes:CaptureRefresh()
	end

	function _detalhes:CancelAllCaptureSchedules()
		for i = 1, #_detalhes.capture_schedules do
			local schedule_table, schedule_id = unpack(_detalhes.capture_schedules[i])
			_detalhes:CancelTimer(schedule_table)
		end
		wipe(_detalhes.capture_schedules)
	end

	function _detalhes:CaptureTimeout (table)
		local capture_type, schedule_id = unpack(table)
		_detalhes.capture_current [capture_type] = _detalhes.capture_real [capture_type]
		_detalhes:CaptureRefresh()

		for index, table in ipairs(_detalhes.capture_schedules) do
			local id = table [2]
			if (schedule_id == id) then
				tremove(_detalhes.capture_schedules, index)
				break
			end
		end
	end

	function _detalhes:CaptureDisable (capture_type)

		capture_type = string.lower(capture_type)

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
			token_list ["SPELL_EMPOWER_START"] = nil
			token_list ["SPELL_EMPOWER_END"] = nil
			token_list ["SPELL_EMPOWER_INTERRUPT"] = nil

		elseif (capture_type == "heal") then
			token_list ["SPELL_HEAL"] = nil
			token_list ["SPELL_PERIODIC_HEAL"] = nil
			token_list ["SPELL_HEAL_ABSORBED"] = nil
			token_list ["SPELL_ABSORBED"] = nil

		elseif (capture_type == "aura") then
			token_list ["SPELL_AURA_APPLIED"] = parser.buff
			token_list ["SPELL_AURA_REMOVED"] = parser.unbuff
			token_list ["SPELL_AURA_REFRESH"] = parser.buff_refresh
			token_list ["SPELL_AURA_APPLIED_DOSE"] = parser.buff_refresh

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

	--SPELL_DRAIN --need research
	--SPELL_LEECH --need research
	--SPELL_PERIODIC_DRAIN --need research
	--SPELL_PERIODIC_LEECH --need research
	--SPELL_DISPEL_FAILED --need research
	--SPELL_BUILDING_HEAL --need research


	function _detalhes:CaptureEnable (capture_type)

		capture_type = string.lower(capture_type)
		--retail
		if (capture_type == "damage") then
			token_list ["SPELL_PERIODIC_DAMAGE"] = parser.spell_dmg
			token_list ["SPELL_EXTRA_ATTACKS"] = nil --parser.spell_dmg_extra_attacks
			token_list ["SPELL_DAMAGE"] = parser.spell_dmg
			token_list ["SPELL_BUILDING_DAMAGE"] = parser.spell_dmg
			token_list ["SWING_DAMAGE"] = parser.spell_dmg --parser.swing
			token_list ["RANGE_DAMAGE"] = parser.spell_dmg --parser.range
			token_list ["DAMAGE_SHIELD"] = parser.spell_dmg
			token_list ["DAMAGE_SPLIT"] = parser.spell_dmg
			token_list ["RANGE_MISSED"] = parser.rangemissed
			token_list ["SWING_MISSED"] = parser.swingmissed
			token_list ["SPELL_MISSED"] = parser.missed
			token_list ["SPELL_PERIODIC_MISSED"] = parser.missed
			token_list ["SPELL_BUILDING_MISSED"] = parser.missed
			token_list ["DAMAGE_SHIELD_MISSED"] = parser.missed
			token_list ["ENVIRONMENTAL_DAMAGE"] = parser.environment

			token_list ["SPELL_EMPOWER_START"] = parser.spell_empower --evoker only
			token_list ["SPELL_EMPOWER_END"] = parser.spell_empower --evoker only
			token_list ["SPELL_EMPOWER_INTERRUPT"] = parser.spell_empower --evoker only

		elseif (capture_type == "heal") then
			token_list ["SPELL_HEAL"] = parser.heal
			token_list ["SPELL_PERIODIC_HEAL"] = parser.heal
			token_list ["SPELL_HEAL_ABSORBED"] = parser.heal_denied
			token_list ["SPELL_ABSORBED"] = parser.heal_absorb

		elseif (capture_type == "aura") then
			token_list ["SPELL_AURA_APPLIED"] = parser.buff
			token_list ["SPELL_AURA_REMOVED"] = parser.unbuff
			token_list ["SPELL_AURA_REFRESH"] = parser.buff_refresh
			token_list ["SPELL_AURA_APPLIED_DOSE"] = parser.buff_refresh

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

	parser.original_functions = {
		["spell_dmg"] = parser.spell_dmg,
		["spell_dmg_extra_attacks"] = nil, --parser.spell_dmg_extra_attacks,
		["swing"] = parser.spell_dmg, --parser.swing,
		["range"] = parser.spell_dmg, --parser.range,
		["rangemissed"] = parser.rangemissed,
		["swingmissed"] = parser.swingmissed,
		["missed"] = parser.missed,
		["environment"] = parser.environment,
		["heal"] = parser.heal,
		["heal_absorb"] = parser.heal_absorb,
		["heal_denied"] = parser.heal_denied,
		["buff"] = parser.buff,
		["unbuff"] = parser.unbuff,
		["buff_refresh"] = parser.buff_refresh,
		["energize"] = parser.energize,
		["spellcast"] = parser.spellcast,
		["dispell"] = parser.dispell,
		["break_cc"] = parser.break_cc,
		["ress"] = parser.ress,
		["interrupt"] = parser.interrupt,
		["dead"] = parser.dead,
		["spell_empower"] = parser.spell_empower,
	}

	function parser:SetParserFunction (token, func)
		if (parser.original_functions [token]) then
			if (type(func) == "function") then
				parser [token] = func
			else
				parser [token] = parser.original_functions [token]
			end
			parser:RefreshFunctions()
		else
			return _detalhes:Msg("Invalid Token for SetParserFunction.")
		end
	end

	local all_parser_tokens = {
		["SPELL_PERIODIC_DAMAGE"] = "spell_dmg",
		["SPELL_EXTRA_ATTACKS"] = nil, --"spell_dmg_extra_attacks",
		["SPELL_DAMAGE"] = "spell_dmg",
		["SPELL_BUILDING_DAMAGE"] = "spell_dmg",
		["SWING_DAMAGE"] = "spell_dmg", --"swing"
		["RANGE_DAMAGE"] = "spell_dmg", --"range",
		["DAMAGE_SHIELD"] = "spell_dmg",
		["DAMAGE_SPLIT"] = "spell_dmg",
		["RANGE_MISSED"] = "rangemissed",
		["SWING_MISSED"] = "swingmissed",
		["SPELL_MISSED"] = "missed",
		["SPELL_PERIODIC_MISSED"] = "missed",
		["SPELL_BUILDING_MISSED"] = "missed",
		["DAMAGE_SHIELD_MISSED"] = "missed",
		["ENVIRONMENTAL_DAMAGE"] = "environment",

		["SPELL_HEAL"] = "heal",
		["SPELL_PERIODIC_HEAL"] = "heal",
		["SPELL_HEAL_ABSORBED"] = "heal_denied",
		["SPELL_ABSORBED"] = "heal_absorb",

		["SPELL_AURA_APPLIED"] = "buff",
		["SPELL_AURA_REMOVED"] = "unbuff",
		["SPELL_AURA_REFRESH"] = "buff_refresh",
		["SPELL_AURA_APPLIED_DOSE"] = "buff_refresh",
		["SPELL_ENERGIZE"] = "energize",
		["SPELL_PERIODIC_ENERGIZE"] = "energize",

		["SPELL_CAST_SUCCESS"] = "spellcast",
		["SPELL_DISPEL"] = "dispell",
		["SPELL_STOLEN"] = "dispell",
		["SPELL_AURA_BROKEN"] = "break_cc",
		["SPELL_AURA_BROKEN_SPELL"] = "break_cc",
		["SPELL_RESURRECT"] = "ress",
		["SPELL_INTERRUPT"] = "interrupt",
		["UNIT_DIED"] = "dead",
		["UNIT_DESTROYED"] = "dead",
	}

	function parser:RefreshFunctions()
		for CLUE_ID, token in pairs(all_parser_tokens) do
			if (token_list [CLUE_ID]) then --not disabled
				token_list [CLUE_ID] = parser [token]
			end
		end
	end

	function _detalhes:CallWipe (from_slash)
		Details:Msg("Wipe has been called by your raid leader.")

		if (_detalhes.wipe_called) then
			if (from_slash) then
				return _detalhes:Msg(Loc ["STRING_WIPE_ERROR1"])
			else
				return
			end
		elseif (not _detalhes.encounter_table.id) then
			if (from_slash) then
				return _detalhes:Msg(Loc ["STRING_WIPE_ERROR2"])
			else
				return
			end
		end

		local eTable = _detalhes.encounter_table

		--finish the encounter
		local successful_ended = _detalhes.parser_functions:ENCOUNTER_END (eTable.id, eTable.name, eTable.diff, eTable.size, 0)

		if (successful_ended) then
			--we wiped
			_detalhes.wipe_called = true

			--cancel the on going captures schedules
			_detalhes:CancelAllCaptureSchedules()

			--disable it
			_detalhes:CaptureSet (false, "damage", false)
			_detalhes:CaptureSet (false, "energy", false)
			_detalhes:CaptureSet (false, "aura", false)
			_detalhes:CaptureSet (false, "energy", false)
			_detalhes:CaptureSet (false, "spellcast", false)

			if (from_slash) then
				if (UnitIsGroupLeader ("player")) then
					_detalhes:SendHomeRaidData ("WI")
				end
			end

			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (lower_instance) then
				lower_instance = _detalhes:GetInstance(lower_instance)
				lower_instance:InstanceAlert (Loc ["STRING_WIPE_ALERT"], {[[Interface\CHARACTERFRAME\UI-StateIcon]], 18, 18, false, 0.5, 1, 0, 0.5}, 4)
			end
		else
			if (from_slash) then
				return _detalhes:Msg(Loc ["STRING_WIPE_ERROR3"])
			else
				return
			end
		end

	end

	-- PARSER
	--serach key: ~parser ~events ~start ~inicio
	function _detalhes:FlagCurrentCombat()
		if (_detalhes.is_in_battleground) then
			_detalhes.tabela_vigente.pvp = true
			_detalhes.tabela_vigente.is_pvp = {name = _detalhes.zone_name, mapid = _detalhes.zone_id}

		elseif (_detalhes.is_in_arena) then
			_detalhes.tabela_vigente.arena = true
			_detalhes.tabela_vigente.is_arena = {name = _detalhes.zone_name, zone = _detalhes.zone_name, mapid = _detalhes.zone_id}
		end
	end

	function _detalhes:GetZoneType()
		return _detalhes.zone_type
	end

	function _detalhes.parser_functions:ZONE_CHANGED_NEW_AREA(...)
		return Details.Schedules.After(1, Details.Check_ZONE_CHANGED_NEW_AREA)
	end

	--~zone ~area
	function _detalhes:Check_ZONE_CHANGED_NEW_AREA()
		local zoneName, zoneType, _, _, _, _, _, zoneMapID = GetInstanceInfo()

		_detalhes.zone_type = zoneType
		_detalhes.zone_id = zoneMapID
		_detalhes.zone_name = zoneName

		_in_resting_zone = IsResting()

		parser:WipeSourceCache()

		_is_in_instance = false

		if (zoneType == "party" or zoneType == "raid") then
			_is_in_instance = true
		end

		if (_detalhes.last_zone_type ~= zoneType) then
			_detalhes:SendEvent("ZONE_TYPE_CHANGED", nil, zoneType)
			_detalhes.last_zone_type = zoneType

			for index, instancia in ipairs(_detalhes.tabela_instancias) do
				if (instancia.ativa) then
					instancia:AdjustAlphaByContext(true)
				end
			end
		end

		_detalhes.time_type = _detalhes.time_type_original

		if (_detalhes.debug) then
			_detalhes:Msg("(debug) zone change:", _detalhes.zone_name, "is a", _detalhes.zone_type, "zone.")
		end

		if (_detalhes.is_in_arena and zoneType ~= "arena") then
			_detalhes:LeftArena()
		end

		--check if the player left a battleground
		if (_detalhes.is_in_battleground and zoneType ~= "pvp") then
			_detalhes.pvp_parser_frame:StopBgUpdater()
			_detalhes.is_in_battleground = nil
			_detalhes.time_type = _detalhes.time_type_original
		end

		if (zoneType == "pvp") then --battlegrounds
			if (_detalhes.debug) then
				_detalhes:Msg("(debug) zone type is now 'pvp'.")
			end

			if(not _detalhes.is_in_battleground and _detalhes.overall_clear_pvp) then
				_detalhes.tabela_historico:resetar_overall()
			end

			_detalhes.is_in_battleground = true

			if (_in_combat and not _current_combat.pvp) then
				_detalhes:SairDoCombate()
			end

			if (not _in_combat) then
				_detalhes:EntrarEmCombate()
			end

			_current_combat.pvp = true
			_current_combat.is_pvp = {name = zoneName, mapid = zoneMapID}

			if (_detalhes.use_battleground_server_parser) then
				if (_detalhes.time_type == 1) then
					_detalhes.time_type_original = 1
					_detalhes.time_type = 2
				end
				_detalhes.pvp_parser_frame:StartBgUpdater()
			else
				if (_detalhes.force_activity_time_pvp) then
					_detalhes.time_type_original = _detalhes.time_type
					_detalhes.time_type = 1
				end
			end

			Details.lastBattlegroundStartTime = GetTime()

		elseif (zoneType == "arena") then
			if (_detalhes.debug) then
				_detalhes:Msg("(debug) zone type is now 'arena'.")
			end

			if (_detalhes.force_activity_time_pvp) then
				_detalhes.time_type_original = _detalhes.time_type
				_detalhes.time_type = 1
			end

			if (not _detalhes.is_in_arena) then
				if (_detalhes.overall_clear_pvp) then
					_detalhes.tabela_historico:resetar_overall()
				end
				--reset spec cache if broadcaster requested
				if (_detalhes.streamer_config.reset_spec_cache) then
					wipe (_detalhes.cached_specs)
				end
			end

			_detalhes.is_in_arena = true
			_detalhes:EnteredInArena()

		else
			local inInstance = IsInInstance()
			if ((zoneType == "raid" or zoneType == "party") and inInstance) then
				_detalhes:CheckForAutoErase (zoneMapID)

				--if the current raid is current tier raid, pre-load the storage database
				if (zoneType == "raid") then
					if (_detalhes.InstancesToStoreData [zoneMapID]) then
						_detalhes.ScheduleLoadStorage()
					end
				end
			end

			if (_detalhes:IsInInstance()) then
				_detalhes.last_instance = zoneMapID
			end

			--if (_current_combat.pvp) then
			--	_current_combat.pvp = false
			--end
		end

		_is_activity_time = _detalhes.time_type == 1

		_detalhes:DispatchAutoRunCode("on_zonechanged")
		_detalhes:SchedulePetUpdate(7)
		_detalhes:CheckForPerformanceProfile()
	end

	function _detalhes.parser_functions:PLAYER_ENTERING_WORLD ()
		return _detalhes.parser_functions:ZONE_CHANGED_NEW_AREA()
	end

	-- ~encounter
	--ENCOUNTER START
	function _detalhes.parser_functions:ENCOUNTER_START(...)
		if (_detalhes.debug) then
			_detalhes:Msg("(debug) |cFFFFFF00ENCOUNTER_START|r event triggered.")
		end

		if (not isWOTLK) then
			C_Timer.After(1, function()
				if (Details.show_warning_id1) then
					if (Details.show_warning_id1_amount < 2) then
						Details.show_warning_id1_amount = Details.show_warning_id1_amount + 1
						--Details:Msg("|cFFFFFF00you might find differences on damage done, this is due to a bug in the game client, nothing related to Details! itself (" .. Details.show_warning_id1_amount .. " / 10).")
					end
				end
			end)
		end

		Details222.Perf.WindowUpdate = 0
		Details222.Perf.WindowUpdateC = true

		_detalhes.latest_ENCOUNTER_END = _detalhes.latest_ENCOUNTER_END or 0
		if (_detalhes.latest_ENCOUNTER_END + 10 > GetTime()) then
			return
		end

		--leave the current combat when the encounter start, if is doing a mythic plus dungeons, check if the options allows to create a dedicated segment for the boss fight
		if ((_in_combat and not _detalhes.tabela_vigente.is_boss) and (not _detalhes.MythicPlus.Started or _detalhes.mythic_plus.boss_dedicated_segment)) then
			_detalhes:SairDoCombate()
		end

		local encounterID, encounterName, difficultyID, raidSize = select(1, ...)
		local zoneName, _, _, _, _, _, _, zoneMapID = GetInstanceInfo()

		if (_detalhes.InstancesToStoreData[zoneMapID]) then
			Details.current_exp_raid_encounters[encounterID] = true
		end

		if (not _detalhes.WhoAggroTimer and _detalhes.announce_firsthit.enabled) then
			_detalhes.WhoAggroTimer = C_Timer.NewTimer(0.1, who_aggro)
			for i = 1, 5 do
				local boss = UnitExists("boss" .. i)
				if (boss) then
					local targetName = UnitName ("boss" .. i .. "target")
					if (targetName and type(targetName) == "string") then
						Details.bossTargetAtPull = targetName
						break
					end
				end
			end
		end

		if (IsInGuild() and IsInRaid() and _detalhes.announce_damagerecord.enabled and _detalhes.StorageLoaded) then
			_detalhes.TellDamageRecord = C_Timer.NewTimer(0.6, _detalhes.PrintEncounterRecord)
			_detalhes.TellDamageRecord.Boss = encounterID
			_detalhes.TellDamageRecord.Diff = difficultyID
		end

		_current_encounter_id = encounterID
		_detalhes.boss1_health_percent = 1

		local dbm_mod, dbm_time = _detalhes.encounter_table.DBM_Mod, _detalhes.encounter_table.DBM_ModTime
		wipe(_detalhes.encounter_table)

		_detalhes.encounter_table.phase = 1

		--store the encounter time inside the encounter table for the encounter plugin
		_detalhes.encounter_table.start = GetTime()
		_detalhes.encounter_table ["end"] = nil
--		local encounterID = Details.encounter_table.id
		_detalhes.encounter_table.id = encounterID
		_detalhes.encounter_table.name = encounterName
		_detalhes.encounter_table.diff = difficultyID
		_detalhes.encounter_table.size = raidSize
		_detalhes.encounter_table.zone = zoneName
		_detalhes.encounter_table.mapid = zoneMapID

		if (dbm_mod and dbm_time == time()) then --pode ser time() � usado no start pra saber se foi no mesmo segundo.
			_detalhes.encounter_table.DBM_Mod = dbm_mod
		end

		local encounter_start_table = _detalhes:GetEncounterStartInfo (zoneMapID, encounterID)
		if (encounter_start_table) then
			if (encounter_start_table.delay) then
				if (type(encounter_start_table.delay) == "function") then
					local delay = encounter_start_table.delay()
					if (delay) then
						--_detalhes.encounter_table ["start"] = time() + delay
						_detalhes.encounter_table ["start"] = GetTime() + delay
					end
				else
					--_detalhes.encounter_table ["start"] = time() + encounter_start_table.delay
					_detalhes.encounter_table ["start"] = GetTime() + encounter_start_table.delay
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

		_detalhes:SendEvent("COMBAT_ENCOUNTER_START", nil, ...)
	end



	--ENCOUNRTER_END
	function _detalhes.parser_functions:ENCOUNTER_END(...)
		if (_detalhes.debug) then
			_detalhes:Msg("(debug) |cFFFFFF00ENCOUNTER_END|r event triggered.")
		end

		Details222.Perf.WindowUpdateC = false

		if (not isWOTLK) then
			C_Timer.After(1, function()
				if (Details.show_warning_id1) then
					if (Details.show_warning_id1_amount < 2) then
						Details.show_warning_id1_amount = Details.show_warning_id1_amount + 1
						--Details:Msg("|cFFFFFF00you may find differences on damage done, this is due to a bug in the game client, nothing related to Details! itself (" .. Details.show_warning_id1_amount .. " / 10).")
					end
				end
			end)
		end

		_current_encounter_id = nil

		local _, instanceType = GetInstanceInfo() --let's make sure it isn't a dungeon
		if (_detalhes.zone_type == "party" or instanceType == "party") then
			if (_detalhes.debug) then
				_detalhes:Msg("(debug) the zone type is 'party', ignoring ENCOUNTER_END.")
			end
		end

		local encounterID, encounterName, difficultyID, raidSize, endStatus = select(1, ...)

		if (not _detalhes.encounter_table.start) then
			Details:Msg("encounter table without start time.")
			return
		end

		_detalhes.latest_ENCOUNTER_END = _detalhes.latest_ENCOUNTER_END or 0
		if (_detalhes.latest_ENCOUNTER_END + 15 > GetTime()) then
			return
		end

		_detalhes.latest_ENCOUNTER_END = GetTime()
		_detalhes.encounter_table ["end"] = GetTime() -- 0.351

		local _, _, _, _, _, _, _, zoneMapID = GetInstanceInfo()

		if (_in_combat) then
			if (endStatus == 1) then
				_detalhes.encounter_table.kill = true
				_detalhes:SairDoCombate (true, {encounterID, encounterName, difficultyID, raidSize, endStatus}) --killed
			else
				_detalhes.encounter_table.kill = false
				_detalhes:SairDoCombate (false, {encounterID, encounterName, difficultyID, raidSize, endStatus}) --wipe
			end
		else
			if ((_detalhes.tabela_vigente:GetEndTime() or 0) + 2 >= _detalhes.encounter_table ["end"]) then
				_detalhes.tabela_vigente:SetStartTime (_detalhes.encounter_table ["start"])
				_detalhes.tabela_vigente:SetEndTime (_detalhes.encounter_table ["end"])
				_detalhes:RefreshMainWindow(-1, true)
			end
		end

		--tag item level of all players
		local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
		local allPlayersGear = openRaidLib and openRaidLib.GetAllUnitsGear()

		local status = xpcall(function()
			for actorIndex, actorObject in Details:GetCurrentCombat():GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
				local gearInfo = allPlayersGear and allPlayersGear[actorObject:Name()]
				if (gearInfo) then
					actorObject.ilvl = gearInfo.ilevel
				end
			end
		end, geterrorhandler())

		if (not status) then
			Details:Msg("ilvl error:", status)
		end

		_detalhes:SendEvent("COMBAT_ENCOUNTER_END", nil, ...)

		wipe(_detalhes.encounter_table)
		wipe(dk_pets_cache.army)
		wipe(dk_pets_cache.apoc)
		wipe(empower_cache)

		return true
	end

	function _detalhes.parser_functions:UNIT_PET(...)
		_detalhes.container_pets:Unpet(...)
		_detalhes:SchedulePetUpdate(1)
	end

	local autoSwapDynamicOverallData = function(instance, inCombat)
		local mainDisplayGroup, subDisplay = instance:GetDisplay()
		local customDisplayAttributeId = 5

		--entering in combat, swap to dynamic overall damage
		if (inCombat) then
			if (mainDisplayGroup == DETAILS_ATTRIBUTE_DAMAGE and subDisplay == DETAILS_SUBATTRIBUTE_DAMAGEDONE) then
				local segment = instance:GetSegment()
				if (segment == DETAILS_SEGMENTID_OVERALL) then
					local dynamicOverallDataCustomID = Details222.GetCustomDisplayIDByName(Loc["STRING_CUSTOM_DYNAMICOVERAL"])
					instance:SetDisplay(segment, customDisplayAttributeId, dynamicOverallDataCustomID)
				end
			end
		else
			--leaving combat
			if (mainDisplayGroup == customDisplayAttributeId) then
				local dynamicOverallDataCustomID = Details222.GetCustomDisplayIDByName(Loc["STRING_CUSTOM_DYNAMICOVERAL"])
				if (subDisplay == dynamicOverallDataCustomID) then
					local segment = instance:GetSegment()
					if (segment == DETAILS_SEGMENTID_OVERALL) then
						instance:SetDisplay(true, DETAILS_ATTRIBUTE_DAMAGE, DETAILS_SUBATTRIBUTE_DAMAGEDONE)
					end
				end
			end

		end
	end


	function _detalhes.parser_functions:PLAYER_REGEN_DISABLED(...)
		C_Timer.After(0, function()
			if (not Details.bossTargetAtPull) then
				if (UnitExists("boss1")) then
					local bossTarget = UnitName("boss1target")
					if (bossTarget) then
						Details.bossTargetAtPull = bossTarget
					end
				end
			end
		end)

		if (Details.auto_swap_to_dynamic_overall) then
			Details:InstanceCall(autoSwapDynamicOverallData, true)
		end

		Details.combat_id_global = Details.combat_id_global + 1
		_global_combat_counter = Details.combat_id_global

		_trinket_data_cache = Details:GetTrinketData()

		if (_detalhes.zone_type == "pvp" and not _detalhes.use_battleground_server_parser) then
			if (_in_combat) then
				_detalhes:SairDoCombate()
			end
			_detalhes:EntrarEmCombate()
		end

		if (not _detalhes:CaptureGet("damage")) then
			_detalhes:EntrarEmCombate()
		end

		--essa parte do solo mode ainda sera usada?
		if (_detalhes.solo and _detalhes.PluginCount.SOLO > 0) then --solo mode
			local esta_instancia = _detalhes.tabela_instancias[_detalhes.solo]
			esta_instancia.atualizando = true
		end

		for index, instancia in ipairs(_detalhes.tabela_instancias) do
			if (instancia.ativa) then --1 = none, we doesn't need to call
				instancia:AdjustAlphaByContext(true)
			end
		end

		_detalhes:DispatchAutoRunCode("on_entercombat")

		_detalhes.tabela_vigente.CombatStartedAt = GetTime()
	end

	--in case the player left the raid during the encounter
	--this function clear the encounter_id from the cache
	local checkIfEncounterIsDone = function()
		if (not _current_encounter_id) then
			return
		end

		if (IsInRaid()) then
			--raid
			local inCombat = false
			for i = 1, GetNumGroupMembers() do
				if (UnitAffectingCombat("raid" .. i)) then
					inCombat = true
					break
				end
			end

			if (not inCombat) then
				_current_encounter_id = nil
			end

		elseif (IsInGroup()) then
			--party (dungeon)
			local inCombat = false
			for i = 1, GetNumGroupMembers() -1 do
				if (UnitAffectingCombat("party" .. i)) then
					inCombat = true
					break
				end
			end

			if (not inCombat) then
				_current_encounter_id = nil
			end

		else
			_current_encounter_id = nil
		end
	end

	--this function is guaranteed to run after a combat is done
	--can also run when the player leaves combat state (regen enabled)
	function _detalhes:RunScheduledEventsAfterCombat(OnRegenEnabled)
		if (_detalhes.debug) then
			_detalhes:Msg("(debug) running scheduled events after combat end.")
		end

		TBC_JudgementOfLightCache = {
			_damageCache = {}
		}

		--when the user requested data from the storage but is in combat lockdown
		if (_detalhes.schedule_storage_load) then
			_detalhes.schedule_storage_load = nil
			_detalhes.ScheduleLoadStorage()
		end

		--store a boss encounter when out of combat since it might need to load the storage
		if (_detalhes.schedule_store_boss_encounter) then
			if (not _detalhes.logoff_saving_data) then
				local successful, errortext = pcall(Details.Database.StoreEncounter)
				if (not successful) then
					_detalhes:Msg("error occurred on Details.Database.StoreEncounter():", errortext)
				end
			end
			_detalhes.schedule_store_boss_encounter = nil
		end

		if (Details.schedule_store_boss_encounter_wipe) then
			if (not _detalhes.logoff_saving_data) then
				local successful, errortext = pcall(Details.Database.StoreWipe)
				if (not successful) then
					_detalhes:Msg("error occurred on Details.Database.StoreWipe():", errortext)
				end
			end
			Details.schedule_store_boss_encounter_wipe = nil
		end

		--when a large amount of data has been removed and the player is in combat, schedule to run the hard garbage collector (the blizzard one, not the details! internal)
		if (_detalhes.schedule_hard_garbage_collect) then
			if (_detalhes.debug) then
				_detalhes:Msg("(debug) found schedule collectgarbage().")
			end
			_detalhes.schedule_hard_garbage_collect = false
			collectgarbage()
		end

		for index, instancia in ipairs(_detalhes.tabela_instancias) do
			if (instancia.ativa) then --1 = none, we doesn't need to call
				instancia:AdjustAlphaByContext(true)
			end
		end

		if (not OnRegenEnabled) then
			wipe(bitfield_swap_cache)
			wipe(empower_cache)
			_detalhes:DispatchAutoRunCode("on_leavecombat")
		end

		if (_detalhes.solo and _detalhes.PluginCount.SOLO > 0) then --code too old and I don't have documentation for it
			if (_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].Stop) then
				_detalhes.SoloTables.Plugins [_detalhes.SoloTables.Mode].Stop()
			end
		end

		--[=[ code maintenance: disabled deprecated code Feb 2022

		--deprecated shcedules
		do
			if (_detalhes.schedule_add_to_overall and #_detalhes.schedule_add_to_overall > 0) then --deprecated (combat are now added immediatelly since there's no script run too long)
				if (_detalhes.debug) then
					_detalhes:Msg("(debug) adding ", #_detalhes.schedule_add_to_overall, "combats in queue to overall data.")
				end

				for i = #_detalhes.schedule_add_to_overall, 1, -1 do
					local CombatToAdd = tremove(_detalhes.schedule_add_to_overall, i)
					if (CombatToAdd) then
						_detalhes.historico:adicionar_overall (CombatToAdd)
					end
				end
			end

			if (_detalhes.schedule_mythicdungeon_trash_merge) then --deprecated (combat are now added immediatelly since there's no script run too long)
				_detalhes.schedule_mythicdungeon_trash_merge = nil
				DetailsMythicPlusFrame.MergeTrashCleanup (true)
			end

			if (_detalhes.schedule_mythicdungeon_endtrash_merge) then --deprecated (combat are now added immediatelly since there's no script run too long)
				_detalhes.schedule_mythicdungeon_endtrash_merge = nil
				DetailsMythicPlusFrame.MergeRemainingTrashAfterAllBossesDone()
			end

			if (_detalhes.schedule_mythicdungeon_overallrun_merge) then --deprecated (combat are now added immediatelly since there's no script run too long)
				_detalhes.schedule_mythicdungeon_overallrun_merge = nil
				DetailsMythicPlusFrame.MergeSegmentsOnEnd()
			end

			if (_detalhes.schedule_flag_boss_components) then --deprecated (combat are now added immediatelly since there's no script run too long)
				_detalhes.schedule_flag_boss_components = false
				_detalhes:FlagActorsOnBossFight()
			end

			if (_detalhes.schedule_remove_overall) then --deprecated (combat are now added immediatelly since there's no script run too long)
				if (_detalhes.debug) then
					_detalhes:Msg("(debug) found schedule overall data clean up.")
				end
				_detalhes.schedule_remove_overall = false
				_detalhes.tabela_historico:resetar_overall()
			end

			if (_detalhes.wipe_called and false) then --disabled
				_detalhes.wipe_called = nil
				_detalhes:CaptureSet (nil, "damage", true)
				_detalhes:CaptureSet (nil, "energy", true)
				_detalhes:CaptureSet (nil, "aura", true)
				_detalhes:CaptureSet (nil, "energy", true)
				_detalhes:CaptureSet (nil, "spellcast", true)

				_detalhes:CaptureSet (false, "damage", false, 10)
				_detalhes:CaptureSet (false, "energy", false, 10)
				_detalhes:CaptureSet (false, "aura", false, 10)
				_detalhes:CaptureSet (false, "energy", false, 10)
				_detalhes:CaptureSet (false, "spellcast", false, 10)
			end
		end

		--]=]


	end

	function _detalhes.parser_functions:CHALLENGE_MODE_START(...)
		--send mythic dungeon start event
		if (_detalhes.debug) then
			print("parser event", "CHALLENGE_MODE_START", ...)
		end

		local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
		if (difficultyID == 8) then
			_detalhes:SendEvent("COMBAT_MYTHICDUNGEON_START")
		end
	end

	function _detalhes.parser_functions:CHALLENGE_MODE_COMPLETED(...)
		--send mythic dungeon end event
		local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
		if (difficultyID == 8) then
			_detalhes:SendEvent("COMBAT_MYTHICDUNGEON_END")
		end
	end

	function _detalhes.parser_functions:PLAYER_REGEN_ENABLED(...)
		if (_detalhes.debug) then
			_detalhes:Msg("(debug) |cFFFFFF00PLAYER_REGEN_ENABLED|r event triggered.")

			--print("combat lockdown:", InCombatLockdown())
			--print("affecting combat:", UnitAffectingCombat("player"))

			--if (_current_encounter_id and IsInInstance()) then
				--print("has a encounter ID")
				--print("player is dead:", UnitHealth ("player") < 1)
			--end
		end

		if (Details.auto_swap_to_dynamic_overall) then
			Details:InstanceCall(autoSwapDynamicOverallData, false)
		end

		--elapsed combat time
		Details.LatestCombatDone = GetTime()

		local currentCombat = Details:GetCurrentCombat()
		currentCombat.CombatEndedAt = GetTime()
		currentCombat.TotalElapsedCombatTime = currentCombat.CombatEndedAt - (currentCombat.CombatStartedAt or 0)

		C_Timer.After(10, checkIfEncounterIsDone)

		--playing alone, just finish the combat right now
		if (not IsInGroup() and not IsInRaid()) then
			currentCombat.playing_solo = true
			Details:SairDoCombate()
		else
			--is in a raid or party group
			C_Timer.After(1, function()
				if (IsInRaid()) then
					local inCombat = false
					for i = 1, GetNumGroupMembers() do
						if (UnitAffectingCombat("raid" .. i)) then
							inCombat = true
							break
						end
					end

					if (not inCombat) then
						Details:RunScheduledEventsAfterCombat(true)
					end

				elseif (IsInGroup()) then
					local inCombat = false
					for i = 1, GetNumGroupMembers() -1 do
						if (UnitAffectingCombat("party" .. i)) then
							inCombat = true
							break
						end
					end

					if (not inCombat) then
						Details:RunScheduledEventsAfterCombat(true)
					end
				end
			end)
		end
	end

	function _detalhes.parser_functions:PLAYER_TALENT_UPDATE()
		if (IsInGroup() or IsInRaid()) then
			if (_detalhes.SendTalentTimer and not _detalhes.SendTalentTimer:IsCancelled()) then
				_detalhes.SendTalentTimer:Cancel()
			end
			_detalhes.SendTalentTimer = C_Timer.NewTimer(11, function()
				_detalhes:SendCharacterData()
			end)
		end
	end

	function _detalhes.parser_functions:PLAYER_SPECIALIZATION_CHANGED()
		--some parts of details! does call this function, check first for past expansions
		if (DetailsFramework.IsTimewalkWoW()) then
			return
		end

		local specIndex = DetailsFramework.GetSpecialization()
		if (specIndex) then
			local specID = DetailsFramework.GetSpecializationInfo(specIndex)
			if (specID and specID ~= 0) then
				local guid = UnitGUID("player")
				if (guid) then
					_detalhes.cached_specs [guid] = specID
				end
			end
		end

		if (IsInGroup() or IsInRaid()) then
			if (_detalhes.SendTalentTimer and not _detalhes.SendTalentTimer:IsCancelled()) then
				_detalhes.SendTalentTimer:Cancel()
			end
			_detalhes.SendTalentTimer = C_Timer.NewTimer(11, function()
				_detalhes:SendCharacterData()
			end)
		end
	end

	--this is mostly triggered when the player enters in a dual against another player
	function _detalhes.parser_functions:UNIT_FACTION(unit)
		if (true) then
			--disable until figure out how to make this work properlly
			--at the moment this event is firing at bgs, arenas, etc making horde icons to show at random
			return
		end

		--check if outdoors
		--unit was nil, nameplate might bug here, it should track after the event
		if (_detalhes.zone_type == "none" and unit) then
			local serial = UnitGUID(unit)
			--the serial is valid and isn't THE player and the serial is from a player?
			if (serial and serial ~= UnitGUID("player") and serial:find("Player")) then
				_detalhes.duel_candidates[serial] = GetTime()

				local playerName = _detalhes:GetCLName(unit)

				--check if the player is inside the current combat and flag the objects
				if (playerName and _current_combat) then
					local enemyPlayer1 = _current_combat:GetActor(1, playerName)
					local enemyPlayer2 = _current_combat:GetActor(2, playerName)
					local enemyPlayer3 = _current_combat:GetActor(3, playerName)
					local enemyPlayer4 = _current_combat:GetActor(4, playerName)
					if (enemyPlayer1) then
						--set to show when the player is solo play
						enemyPlayer1.grupo = true
						enemyPlayer1.enemy = true

						if (IsInGroup()) then
							--broadcast the enemy to group members so they can "watch" the damage
						end
					end

					if (enemyPlayer2) then
						enemyPlayer2.grupo = true
						enemyPlayer2.enemy = true
					end

					if (enemyPlayer3) then
						enemyPlayer3.grupo = true
						enemyPlayer3.enemy = true
					end

					if (enemyPlayer4) then
						enemyPlayer4.grupo = true
						enemyPlayer4.enemy = true
					end
				end
			end
		end
	end

	function _detalhes.parser_functions:ROLE_CHANGED_INFORM(...)
		if (_detalhes.last_assigned_role ~= _UnitGroupRolesAssigned("player")) then
			_detalhes:CheckSwitchOnLogon (true)
			_detalhes.last_assigned_role = _UnitGroupRolesAssigned("player")
		end
	end

	function _detalhes.parser_functions:PLAYER_ROLES_ASSIGNED(...)
		if (_detalhes.last_assigned_role ~= _UnitGroupRolesAssigned("player")) then
			_detalhes:CheckSwitchOnLogon (true)
			_detalhes.last_assigned_role = _UnitGroupRolesAssigned("player")
		end
	end

	function _detalhes:InGroup()
		return _detalhes.in_group
	end

	function _detalhes.parser_functions:GROUP_ROSTER_UPDATE(...)
		if (not _detalhes.in_group) then
			_detalhes.in_group = IsInGroup() or IsInRaid()

			if (_detalhes.in_group) then
				--player entered in a group, cleanup and set the new enviromnent
				Details222.GarbageCollector.RestartInternalGarbageCollector(true)
				Details:WipePets()
				Details:SchedulePetUpdate(1)
				Details:InstanceCall(Details.AdjustAlphaByContext)

				Details:CheckSwitchOnLogon()
				Details:CheckVersion()
				Details:SendEvent("GROUP_ONENTER")

				Details:DispatchAutoRunCode("on_groupchange")

				wipe (Details.trusted_characters)
				C_Timer.After(5, Details.ScheduleSyncPlayerActorData)
			end

		else
			_detalhes.in_group = IsInGroup() or IsInRaid()

			if (not _detalhes.in_group) then
				--player left the group, run routines to cleanup the environment
				Details222.GarbageCollector.RestartInternalGarbageCollector(true)
				Details:WipePets()
				Details:SchedulePetUpdate(1)
				wipe(Details.details_users)
				Details:InstanceCall(Details.AdjustAlphaByContext)
				Details:CheckSwitchOnLogon()
				Details:SendEvent("GROUP_ONLEAVE")
				Details:DispatchAutoRunCode("on_groupchange")
				wipe(Details.trusted_characters)
			else
				--player is still in a group
				_detalhes:SchedulePetUpdate(2)

				--send char data
				if (_detalhes.SendCharDataOnGroupChange and not _detalhes.SendCharDataOnGroupChange:IsCancelled()) then
					return
				end

				_detalhes.SendCharDataOnGroupChange = C_Timer.NewTimer(11, function()
					_detalhes:SendCharacterData()
					_detalhes.SendCharDataOnGroupChange = nil
				end)
			end
		end

		_detalhes:SchedulePetUpdate(6)
	end

	function _detalhes.parser_functions:START_TIMER(...) --~timer
		if (_detalhes.debug) then
			_detalhes:Msg("(debug) found a timer.")
		end

		local _, zoneType = GetInstanceInfo()

		--check if the player is inside an arena
		if (zoneType == "arena") then
			if (_detalhes.debug) then
				_detalhes:Msg("(debug) timer is an arena countdown.")
			end

			_detalhes:StartArenaSegment(...)

		--check if the player is inside a battleground
		elseif (zoneType == "battleground") then
			if (Details.debug) then
				Details:Msg("(debug) timer is a battleground countdown.")
			end

			local _, timeSeconds = select(1, ...)

			if (Details.start_battleground) then
				Details.Schedules.Cancel(Details.start_battleground)
			end

			--create new schedule
			Details.start_battleground = Details.Schedules.NewTimer(timeSeconds, Details.CreateBattlegroundSegment)
			Details.Schedules.SetName(Details.start_battleground, "Battleground Start Timer")
		end
	end

	function Details:CreateBattlegroundSegment()
		if (_in_combat) then
			_detalhes.tabela_vigente.discard_segment = true
			Details:EndCombat()
		end

		Details.lastBattlegroundStartTime = GetTime()
		Details:StartCombat()

		if (Details.debug) then
			Details:Msg("(debug) a battleground has started.")
		end
	end

	--~load
	local start_details = function()
		if (not _detalhes.gump) then
			--failed to load the framework

			if (not _detalhes.instance_load_failed) then
				_detalhes:CreatePanicWarning()
			end
			_detalhes.instance_load_failed.text:SetText("Framework for Details! isn't loaded.\nIf you just updated the addon, please reboot the game client.\nWe apologize for the inconvenience and thank you for your comprehension.")

			return
		end

		--cooltip
		if (not _G.GameCooltip) then
			_detalhes.popup = _G.GameCooltip
		else
			_detalhes.popup = _G.GameCooltip
		end

		--check group
		_detalhes.in_group = IsInGroup() or IsInRaid()

		--write into details object all basic keys and default profile
		_detalhes:ApplyBasicKeys()
		--check if is first run, update keys for character and global data
		_detalhes:LoadGlobalAndCharacterData()

		--details updated and not reopened the game client
		if (_detalhes.FILEBROKEN) then
			return
		end

		--load all the saved combats
		_detalhes:LoadCombatTables()

		--load the profiles
		_detalhes:LoadConfig()

		_detalhes:UpdateParserGears()

		--load auto run code
		Details:StartAutoRun()

		Details.isLoaded = true
	end

	function Details.IsLoaded()
		return Details.isLoaded
	end

	function _detalhes.parser_functions:ADDON_LOADED(...)
		local addon_name = select(1, ...)
		if (addon_name == "Details") then
			start_details()
		end
	end

	local playerLogin = CreateFrame("frame")
	playerLogin:RegisterEvent("PLAYER_LOGIN")
	playerLogin:SetScript("OnEvent", function()
		Details:StartMeUp()
	end)

	function _detalhes.parser_functions:PET_BATTLE_OPENING_START(...)
		_detalhes.pet_battle = true
		for index, instance in ipairs(_detalhes.tabela_instancias) do
			if (instance.ativa) then
				if (_detalhes.debug) then
					_detalhes:Msg("(debug) hidding windows for Pet Battle.")
				end
				instance:SetWindowAlphaForCombat(true, true, 0)
			end
		end
	end

	function _detalhes.parser_functions:PET_BATTLE_CLOSE(...)
		_detalhes.pet_battle = false
		for index, instance in ipairs(_detalhes.tabela_instancias) do
			if (instance.ativa) then
				if (_detalhes.debug) then
					_detalhes:Msg("(debug) Pet Battle finished, calling AdjustAlphaByContext().")
				end
				instance:AdjustAlphaByContext(true)
			end
		end
	end

	function _detalhes.parser_functions:UNIT_NAME_UPDATE(...)
		_detalhes:SchedulePetUpdate(5)
	end

	function Details.parser_functions:PLAYER_TARGET_CHANGED(...)
		Details:SendEvent("PLAYER_TARGET")
	end

	local parser_functions = _detalhes.parser_functions

	function _detalhes:OnEvent(event, ...)
		local func = parser_functions[event]
		if (func) then
			return func(nil, ...)
		end
	end

	_detalhes.listener:SetScript("OnEvent", _detalhes.OnEvent)

	--logout function ~save ~logout
	local saver = CreateFrame("frame", nil, UIParent)
	saver:RegisterEvent("PLAYER_LOGOUT")
	saver:SetScript("OnEvent", function(...)
		__details_backup = __details_backup or {
			_exit_error = {},
			_instance_backup = {},
		}
		local exitErrors = __details_backup._exit_error

		local addToExitErrors = function(text)
			table.insert(exitErrors, 1, date() .. "|" .. text)
			table.remove(exitErrors, 10)
		end

		local currentStep = ""

		--save the time played on this class, run protected
		local savePlayTimeClass, savePlayTimeError = pcall(function()
			Details.SavePlayTimeOnClass()
		end)

		if (not savePlayTimeClass) then
			addToExitErrors("Saving Play Time: " .. savePlayTimeError)
		end

		--SAVINGDATA = true
		_detalhes_global.exit_log = {}
		_detalhes_global.exit_errors = _detalhes_global.exit_errors or {}

		currentStep = "Checking the framework integrity"

		if (not _detalhes.gump) then
			--failed to load the framework
			tinsert(_detalhes_global.exit_log, "The framework wasn't in Details member 'gump'.")
			tinsert(_detalhes_global.exit_errors, 1, currentStep .. "|" .. date() .. "|" .. _detalhes.userversion .. "|Framework wasn't loaded|")
			return
		end

		local saver_error = function(errortext)
			--if the error log cause an error?
			local writeLog = function()
				_detalhes_global = _detalhes_global or {}
				tinsert(_detalhes_global.exit_errors, 1, currentStep .. "|" .. date() .. "|" .. _detalhes.userversion .. "|" .. errortext .. "|" .. debugstack())
				tremove(_detalhes_global.exit_errors, 6)
				addToExitErrors(currentStep .. "|" .. date() .. "|" .. _detalhes.userversion .. "|" .. errortext .. "|" .. debugstack())
			end
			xpcall(writeLog, addToExitErrors)
		end

		_detalhes.saver_error_func = saver_error
		_detalhes.logoff_saving_data = true

		--close info window
		if (_detalhes.CloseBreakdownWindow) then
			tinsert(_detalhes_global.exit_log, "1 - Closing Janela Info.")
			currentStep = "Fecha Janela Info"
			xpcall(_detalhes.CloseBreakdownWindow, saver_error)
		end

		--do not save window pos
		if (_detalhes.tabela_instancias) then
			local clearInstances = function()
				currentStep = "Dealing With Instances"
				tinsert(_detalhes_global.exit_log, "2 - Clearing user place from instances.")
				for id, instance in _detalhes:ListInstances() do
					if (id) then
						tinsert(_detalhes_global.exit_log, "  - " .. id .. " has baseFrame: " .. (instance.baseframe and "yes" or "no") .. ".")
						if (instance.baseframe) then
							instance.baseframe:SetUserPlaced (false)
							instance.baseframe:SetDontSavePosition (true)
						end
					end
				end
			end
			xpcall(clearInstances, saver_error)
		else
			tinsert(_detalhes_global.exit_errors, 1, "not _detalhes.tabela_instancias")
			tremove(_detalhes_global.exit_errors, 6)
			addToExitErrors("not _detalhes.tabela_instancias")
		end

		--leave combat start save tables
		if (_detalhes.in_combat and _detalhes.tabela_vigente) then
			tinsert(_detalhes_global.exit_log, "3 - Leaving current combat.")
			currentStep = "Leaving Current Combat"
			xpcall(_detalhes.SairDoCombate, saver_error)
			_detalhes.can_panic_mode = true
		end

		if (_detalhes.CheckSwitchOnLogon and _detalhes.tabela_instancias and _detalhes.tabela_instancias[1] and getmetatable(_detalhes.tabela_instancias[1])) then
			tinsert(_detalhes_global.exit_log, "4 - Reversing switches.")
			currentStep = "Check Switch on Logon"
			xpcall(_detalhes.CheckSwitchOnLogon, saver_error)
		end

		if (_detalhes.wipe_full_config) then
			tinsert(_detalhes_global.exit_log, "5 - Is a full config wipe.")
			addToExitErrors("true: _detalhes.wipe_full_config")
			_detalhes_global = nil
			_detalhes_database = nil
			return
		end

	--save the config
		tinsert(_detalhes_global.exit_log, "6 - Saving Config.")
		currentStep = "Saving Config"
		xpcall(_detalhes.SaveConfig, saver_error)

		tinsert(_detalhes_global.exit_log, "7 - Saving Profiles.")
		currentStep = "Saving Profile"
		xpcall(_detalhes.SaveProfile, saver_error)

	--save the nicktag cache
		tinsert(_detalhes_global.exit_log, "8 - Saving nicktag cache.")

		local saveNicktabCache = function()
			_detalhes_database.nick_tag_cache = Details.CopyTable(_detalhes_database.nick_tag_cache)
		end
		xpcall(saveNicktabCache, saver_error)
	end)

	local eraNamedSpellsToID = {}

	

	-- ~parserstart ~startparser ~cleu ~parser
	function _detalhes.OnParserEvent()
		local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()

		local func = token_list[token]
		if (func) then
			return func(nil, token, time, who_serial, who_name, who_flags, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12)
		end
	end

	function _detalhes.OnParserEventClassicEra()
		local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()

		local func = token_list[token]
		if (func) then
			if(eraNamedSpellsToID[token]) then
				A1 = A2
			end
			return func(nil, token, time, who_serial, who_name, who_flags, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12)
		end
	end

	if(DetailsFramework.IsClassicWow()) then
		eraNamedSpellsToID = {
		["SPELL_PERIODIC_DAMAGE"] = true,
		["SPELL_DAMAGE"] = true,
		["SPELL_BUILDING_DAMAGE"] = true,
		["DAMAGE_SHIELD"] = true,
		["DAMAGE_SPLIT"] = true,
		["SPELL_MISSED"] = true,
		["SPELL_PERIODIC_MISSED"] = true,
		["SPELL_BUILDING_MISSED"] = true,
		["DAMAGE_SHIELD_MISSED"] = true,

		["SPELL_HEAL"] = true,
		["SPELL_PERIODIC_HEAL"] = true,
		["SPELL_HEAL_ABSORBED"] = true,
		["SPELL_ABSORBED"] = true,

		["SPELL_AURA_APPLIED"] = true,
		["SPELL_AURA_REMOVED"] = true,
		["SPELL_AURA_REFRESH"] = true,
		["SPELL_AURA_APPLIED_DOSE"] = true,
		["SPELL_ENERGIZE"] = true,
		["SPELL_PERIODIC_ENERGIZE"] = true,

		["SPELL_CAST_SUCCESS"] = true,
		["SPELL_DISPEL"] = true,
		["SPELL_STOLEN"] = true,
		["SPELL_AURA_BROKEN"] = true,
		["SPELL_AURA_BROKEN_SPELL"] = true,
		["SPELL_RESURRECT"] = true,
		["SPELL_INTERRUPT"] = true,
		}
		_detalhes.parser_frame:SetScript("OnEvent", _detalhes.OnParserEventClassicEra)
	else
		_detalhes.parser_frame:SetScript("OnEvent", _detalhes.OnParserEvent)
	end

	function _detalhes:UpdateParser()
		_tempo = _detalhes._tempo
	end

	function _detalhes:UpdatePetsOnParser()
		container_pets = _detalhes.tabela_pets.pets
	end

	function Details:GetActorFromCache(value)
		return damage_cache[value] or damage_cache_pets[value] or damage_cache_petsOwners[value]
	end

	function _detalhes:PrintParserCacheIndexes()
		local amount = 0
		for n, nn in pairs(damage_cache) do
			amount = amount + 1
		end
		print("parser damage_cache", amount)

		amount = 0
		for n, nn in pairs(damage_cache_pets) do
			amount = amount + 1
		end
		print("parser damage_cache_pets", amount)

		amount = 0
		for n, nn in pairs(damage_cache_petsOwners) do
			amount = amount + 1
		end
		print("parser damage_cache_petsOwners", amount)

		amount = 0
		for n, nn in pairs(healing_cache) do
			amount = amount + 1
		end
		print("parser healing_cache", amount)

		amount = 0
		for n, nn in pairs(energy_cache) do
			amount = amount + 1
		end
		print("parser energy_cache", amount)

		amount = 0
		for n, nn in pairs(misc_cache) do
			amount = amount + 1
		end
		print("parser misc_cache", amount)
		print("group damage", #_detalhes.cache_damage_group)
		print("group damage", #_detalhes.cache_healing_group)
	end

	function _detalhes:GetActorsOnDamageCache()
		return _detalhes.cache_damage_group
	end

	function _detalhes:GetActorsOnHealingCache()
		return _detalhes.cache_healing_group
	end

	function _detalhes:ClearParserCache() --~wipe
		wipe(damage_cache)
		wipe(damage_cache_pets)
		wipe(damage_cache_petsOwners)
		wipe(healing_cache)
		wipe(energy_cache)
		wipe(misc_cache)
		wipe(misc_cache_pets)
		wipe(misc_cache_petsOwners)
		wipe(npcid_cache)
		wipe(enemy_cast_cache)
		wipe(empower_cache)

		wipe(ignore_death_cache)

		wipe(reflection_damage)
		wipe(reflection_debuffs)
		wipe(reflection_events)
		wipe(reflection_auras)
		wipe(reflection_dispels)

		wipe(dk_pets_cache.army)
		wipe(dk_pets_cache.apoc)

		wipe(cacheAnything.paladin_vivaldi_blessings)

		cacheAnything.track_hunter_frenzy = Details.combat_log.track_hunter_frenzy

		if (Details.combat_log.merge_gemstones_1007) then
			--ring powers merged, https://gist.github.com/ljosberinn/65abe150133ff3a08cd70f840f7dd019 (by Gerrit Alex - WCL)
			override_spellId[403225] = 404884 --Flame Licked Stone
			override_spellId[404974] = 404884 --Shining Obsidian Stone
			override_spellId[405220] = 404884 --Pestilent Plague Stone
			override_spellId[405221] = 404884 --Pestilent Plague Stone
			override_spellId[405209] = 404884 --Humming Arcane Stone
			override_spellId[403391] = 404884 --Freezing Ice Stone
			override_spellId[404911] = 404884 --Desirous Blood Stone
			override_spellId[404941] = 404884 --Shining Obsidian Stone
			override_spellId[403087] = 404884 --Storm Infused Stone
			override_spellId[403273] = 404884 --Fel Flame via Entropic Fel Stone
			override_spellId[403171] = 404884 --Uncontainable Charge via Echoing Thunder Stone
			override_spellId[405235] = 404884 --Wild Spirit Stone
			override_spellId[403381] = 404884 --Deluging Water Stone
			override_spellId[405118] = 404884 --Exuding Steam Stone
			override_spellId[403408] = 404884 --Exuding Steam Stone
			override_spellId[403336] = 404884 --Indomitable Earth Stone
			override_spellId[403392] = 404884 --Cold Frost Stone
			override_spellId[403376] = 404884 --Gleaming Iron Stone
			override_spellId[403253] = 404884 --Raging Magma Stone
			override_spellId[403257] = 404884 --Searing Smokey Stone
		else
			override_spellId[403225] = nil --Flame Licked Stone
			override_spellId[404974] = nil --Shining Obsidian Stone
			override_spellId[405220] = nil --Pestilent Plague Stone
			override_spellId[405221] = nil --Pestilent Plague Stone
			override_spellId[405209] = nil --Humming Arcane Stone
			override_spellId[403391] = nil --Freezing Ice Stone
			override_spellId[404911] = nil --Desirous Blood Stone
			override_spellId[404941] = nil --Shining Obsidian Stone
			override_spellId[403087] = nil --Storm Infused Stone
			override_spellId[403273] = nil --Fel Flame via Entropic Fel Stone
			override_spellId[403171] = nil --Uncontainable Charge via Echoing Thunder Stone
			override_spellId[405235] = nil --Wild Spirit Stone
			override_spellId[403381] = nil --Deluging Water Stone
			override_spellId[405118] = nil --Exuding Steam Stone
			override_spellId[403408] = nil --Exuding Steam Stone
			override_spellId[403336] = nil --Indomitable Earth Stone
			override_spellId[403392] = nil --Cold Frost Stone
			override_spellId[403376] = nil --Gleaming Iron Stone
			override_spellId[403253] = nil --Raging Magma Stone
			override_spellId[403257] = nil --Searing Smokey Stone
		end

		if (Details.combat_log.merge_critical_heals) then
			override_spellId[94472] = 81751 --disc priest attonement and crit. Crits use separate id.
			override_spellId[281469] = 270501 --disc priest contrition attonement and crit. Crits use separate id.
			override_spellId[388025] = 388024 --MW monk Ancient Teachings, heals from damage, crit and normal are separate.
			override_spellId[389325] = 389328 --MW monk Awakened Faeline, ^
		else
			override_spellId[94472] = nil --disc priest attonement and crit. Crits use separate id.
			override_spellId[281469] = nil --disc priest contrition attonement and crit. Crits use separate id.
			override_spellId[388025] = nil --MW monk Ancient Teachings, heals from damage, crit and normal are separate.
			override_spellId[389325] = nil --MW monk Awakened Faeline, ^
		end


		damage_cache = setmetatable({}, _detalhes.weaktable)
		damage_cache_pets = setmetatable({}, _detalhes.weaktable)
		damage_cache_petsOwners = setmetatable({}, _detalhes.weaktable)

		healing_cache = setmetatable({}, _detalhes.weaktable)

		energy_cache = setmetatable({}, _detalhes.weaktable)

		misc_cache = setmetatable({}, _detalhes.weaktable)
		misc_cache_pets = setmetatable({}, _detalhes.weaktable)
		misc_cache_petsOwners = setmetatable({}, _detalhes.weaktable)
	end

	function parser:RevomeActorFromCache(actor_serial, actor_name)
		if (actor_name) then
			damage_cache[actor_name] = nil
			damage_cache_pets[actor_name] = nil
			damage_cache_petsOwners[actor_name] = nil
			healing_cache[actor_serial] = nil
			energy_cache[actor_name] = nil
			misc_cache[actor_name] = nil
			misc_cache_pets[actor_name] = nil
			misc_cache_petsOwners[actor_name] = nil
		end

		if (actor_serial) then
			damage_cache[actor_serial] = nil
			damage_cache_pets[actor_serial] = nil
			damage_cache_petsOwners[actor_serial] = nil
			healing_cache[actor_serial] = nil
			energy_cache[actor_serial] = nil
			misc_cache[actor_serial] = nil
			misc_cache_pets[actor_serial] = nil
			misc_cache_petsOwners[actor_serial] = nil
		end
	end

	function _detalhes:UptadeRaidMembersCache()
		wipe(raid_members_cache)
		wipe(tanks_members_cache)
		wipe(auto_regen_cache)
		wipe(bitfield_swap_cache)
		wipe(empower_cache)

		local groupRoster = _detalhes.tabela_vigente.raid_roster

		if (IsInRaid()) then
			local unitIdCache = Details222.UnitIdCache.Raid

			for i = 1, GetNumGroupMembers() do
				local unitId = unitIdCache[i]
				local unitName = GetUnitName(unitId, true)
				local unitGUID = UnitGUID(unitId)

				local _, unitClass = UnitClass(unitId)
				Details222.ClassCache.ByName[unitName] = unitClass
				Details222.ClassCache.ByGUID[unitGUID] = unitClass

				raid_members_cache[unitGUID] = unitName
				groupRoster[unitName] = unitGUID

				local role = _UnitGroupRolesAssigned(unitName)
				if (role == "TANK") then
					tanks_members_cache[unitGUID] = true
				end

				if (auto_regen_power_specs[_detalhes.cached_specs[unitGUID]]) then
					auto_regen_cache[unitName] = auto_regen_power_specs[_detalhes.cached_specs[unitGUID]]
				end
			end

		elseif (IsInGroup()) then
			local unitIdCache = Details222.UnitIdCache.Party
			for i = 1, GetNumGroupMembers()-1 do
				local unitId = unitIdCache[i]

				local unitName = GetUnitName(unitId, true)
				local unitGUID = UnitGUID(unitId)

				raid_members_cache[unitGUID] = unitName
				groupRoster[unitName] = unitGUID

				local role = _UnitGroupRolesAssigned(unitName)
				if (role == "TANK") then
					tanks_members_cache[unitGUID] = true
				end

				if (auto_regen_power_specs[_detalhes.cached_specs[unitGUID]]) then
					auto_regen_cache[unitName] = auto_regen_power_specs[_detalhes.cached_specs[unitGUID]]
				end
			end

			--player
			local playerName = GetUnitName("player", true)
			local playerGUID = UnitGUID("player")

			raid_members_cache[playerGUID] = playerName
			groupRoster[playerName] = playerGUID

			local role = _UnitGroupRolesAssigned(playerName)
			if (role == "TANK") then
				tanks_members_cache[playerGUID] = true
			end

			if (auto_regen_power_specs[_detalhes.cached_specs[playerGUID]]) then
				auto_regen_cache[playerName] = auto_regen_power_specs[_detalhes.cached_specs[playerGUID]]
			end
		else
			local playerName = GetUnitName("player", true)
			local playerGUID = UnitGUID("player")

			raid_members_cache[playerGUID] = playerName
			groupRoster[playerName] = playerGUID

			local role = _UnitGroupRolesAssigned(playerName)
			if (role == "TANK") then
				tanks_members_cache[playerGUID] = true
			else
				local spec = DetailsFramework.GetSpecialization()
				if (spec and spec ~= 0) then
					if (DetailsFramework.GetSpecializationRole (spec) == "TANK") then
						tanks_members_cache[playerGUID] = true
					end
				end
			end

			if (auto_regen_power_specs[_detalhes.cached_specs[playerGUID]]) then
				auto_regen_cache[playerName] = auto_regen_power_specs[_detalhes.cached_specs[playerGUID]]
			end
		end

		local orderNames = {}
		for playerName in pairs(groupRoster) do
			orderNames[#orderNames+1] = playerName
		end
		table.sort(orderNames, function(name1, name2)
			return string.len(name1) > string.len(name2)
		end)
		_detalhes.tabela_vigente.raid_roster_indexed = orderNames

		if (_detalhes.iam_a_tank) then
			tanks_members_cache[UnitGUID("player")] = true
		end
	end

	---return true or false
	---@param unitGUID string
	---@return boolean
	function Details:IsATank(unitGUID)
		return tanks_members_cache[unitGUID] or false
	end

	---returns the unit name
	---@param unitGUID string
	---@return string
	function Details:IsInCache(unitGUID)
		return raid_members_cache[unitGUID]
	end

	---return the internal raid members cache, containing the unitGUID as key and the unitName as value
	---@return table
	function Details:GetParserPlayerCache()
		return raid_members_cache
	end

	--serach key: ~cache
	function _detalhes:UpdateParserGears()
		--refresh combat tables
		_current_combat = _detalhes.tabela_vigente

		--last events pointer
		last_events_cache = _current_combat.player_last_events
		_amount_of_last_events = _detalhes.deadlog_events

		_use_shield_overheal = _detalhes.parser_options.shield_overheal
		_is_activity_time  = _detalhes.time_type == 1
		shield_spellid_cache = _detalhes.shield_spellid_cache

		--refresh total containers
		_current_total = _current_combat.totals
		_current_gtotal = _current_combat.totals_grupo

		--refresh actors containers
		_current_damage_container = _current_combat[1]
		_current_heal_container = _current_combat[2]
		_current_energy_container = _current_combat[3]
		_current_misc_container = _current_combat[4]

		--refresh data capture options
		--_recording_self_buffs = _detalhes.RecordPlayerSelfBuffs --can be deprecated
		--_recording_healing = _detalhes.RecordHealingDone --can be deprecated
		--_recording_took_damage = _detalhes.RecordRealTimeTookDamage
		--_recording_ability_with_buffs = _detalhes.RecordPlayerAbilityWithBuffs --can be deprecated
		_in_combat = _detalhes.in_combat

		wipe(ignored_npcids)

		--fill it with the default npcs ignored
		for npcId in pairs(_detalhes.default_ignored_npcs) do
			ignored_npcids[npcId] = true
		end

		--fill it with the npcs the user ignored
		for npcId in pairs(_detalhes.npcid_ignored) do
			ignored_npcids[npcId] = true
		end
		ignored_npcids[0] = nil

		if (_in_combat) then
			if (Details.parser_options.energy_overflow) then
				if (not Details.AutoRegenThread or Details.AutoRegenThread:IsCancelled()) then
					Details.AutoRegenThread = C_Timer.NewTicker(AUTO_REGEN_PRECISION / 10, regen_power_overflow_check) --at the moment, runs 5 times per second
				end
			end
		else
			if (Details.AutoRegenThread and not Details.AutoRegenThread:IsCancelled()) then
				Details.AutoRegenThread:Cancel()
				Details.AutoRegenThread = nil
			end
		end

		if (_detalhes.hooks["HOOK_COOLDOWN"].enabled) then
			_hook_cooldowns = true
		else
			_hook_cooldowns = false
		end

		if (_detalhes.hooks["HOOK_DEATH"].enabled) then
			_hook_deaths = true
		else
			_hook_deaths = false
		end

		if (_detalhes.hooks["HOOK_BATTLERESS"].enabled) then
			_hook_battleress = true
		else
			_hook_battleress = false
		end

		if (_detalhes.hooks["HOOK_INTERRUPT"].enabled) then
			_hook_interrupt = true
		else
			_hook_interrupt = false
		end

		is_using_spellId_override = _detalhes.override_spellids

		return _detalhes:ClearParserCache()
	end

	function _detalhes.DumpIgnoredNpcs()
		return ignored_npcids
	end



--serach key: ~api
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--details api functions

	--number of combat
	function  Details:GetCombatId()
		return Details.combat_id
	end

	--if in combat
	function Details:IsInCombat()
		return _in_combat
	end

	function Details:IsInEncounter()
		return Details.encounter_table.id and true or false
	end

	function Details:GetAllActors(_combat, _actorname)
		return Details:GetActor(_combat, 1, _actorname), Details:GetActor(_combat, 2, _actorname), Details:GetActor(_combat, 3, _actorname), Details:GetActor(_combat, 4, _actorname)
	end

	--get player
	function Details:GetPlayer(_actorname, _combat, _attribute)
		return Details:GetActor(_combat, _attribute, _actorname)
	end

	--get an actor
	function Details:GetActor(combat, attribute, actorName)
		if (not combat) then
			combat = "current" --current combat
		end

		if (not attribute) then
			attribute = 1 --damage
		end

		if (not actorName) then
			actorName = Details.playername
		end

		if (combat == 0 or combat == "current") then
			local actor = Details.tabela_vigente(attribute, actorName)
			if (actor) then
				return actor
			else
				return nil
			end

		elseif (combat == -1 or combat == "overall") then
			local actor = Details.tabela_overall(attribute, actorName)
			if (actor) then
				return actor
			else
				return nil
			end

		elseif (type(combat) == "number") then
			local combatTables = Details.tabela_historico.tabelas[combat]
			if (combatTables) then
				local actor = combatTables(attribute, actorName)
				if (actor) then
					return actor
				else
					return nil
				end
			else
				return nil
			end
		else
			return nil
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--battleground parser

	_detalhes.pvp_parser_frame:SetScript("OnEvent", function(self, event)
		self:ReadPvPData()
	end)

	function _detalhes:BgScoreUpdate()
		RequestBattlefieldScoreData()
	end

	--start the virtual parser
	function _detalhes.pvp_parser_frame:StartBgUpdater()
		_detalhes.pvp_parser_frame:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

		if (_detalhes.pvp_parser_frame.ticker) then
			Details.Schedules.Cancel(_detalhes.pvp_parser_frame.ticker)
		end

		_detalhes.pvp_parser_frame.ticker = Details.Schedules.NewTicker(10, Details.BgScoreUpdate)
		Details.Schedules.SetName(_detalhes.pvp_parser_frame.ticker, "Battleground Updater")
	end

	--stop the virtual parser
	function _detalhes.pvp_parser_frame:StopBgUpdater()
		_detalhes.pvp_parser_frame:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
		Details.Schedules.Cancel(_detalhes.pvp_parser_frame.ticker)
		_detalhes.pvp_parser_frame.ticker = nil
	end

	function _detalhes.pvp_parser_frame:ReadPvPData()
		local players = GetNumBattlefieldScores()

		for i = 1, players do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, rank, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec
			if (isWOTLK) then
				name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i)
			else
				name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i)
			end

			--damage done
			local actor = _detalhes.tabela_vigente(1, name)
			if (actor) then
				if (damageDone == 0) then
					damageDone = damageDone + _detalhes:GetOrderNumber()
				end
				actor.total = damageDone
				actor.classe = classToken or "UNKNOW"

			elseif (name ~= "Unknown" and type(name) == "string" and string.len(name) > 1) then
				local guid = UnitGUID(name)
				if (guid) then
					local flag
					if (_detalhes.faction_id == faction) then --is from the same faction
						flag = 0x514
					else
						flag = 0x548
					end

					actor = _current_damage_container:PegarCombatente (guid, name, flag, true)
					actor.total = _detalhes:GetOrderNumber()
					actor.classe = classToken or "UNKNOW"

					if (flag == 0x548) then
						--oponent
						actor.enemy = true
					end
				end
			end

			--healing done
			local actor = _detalhes.tabela_vigente(2, name)
			if (actor) then
				if (healingDone == 0) then
					healingDone = healingDone + _detalhes:GetOrderNumber()
				end
				actor.total = healingDone
				actor.classe = classToken or "UNKNOW"

			elseif (name ~= "Unknown" and type(name) == "string" and string.len(name) > 1) then
				local guid = UnitGUID(name)
				if (guid) then
					local flag
					if (_detalhes.faction_id == faction) then --is from the same faction
						flag = 0x514
					else
						flag = 0x548
					end

					actor = _current_heal_container:PegarCombatente (guid, name, flag, true)
					actor.total = _detalhes:GetOrderNumber()
					actor.classe = classToken or "UNKNOW"

					if (flag == 0x548) then
						--oponent
						actor.enemy = true
					end
				end
			end
		end
	end
