-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local Details = _G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
	local detailsFramework = DetailsFramework

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

	local _UnitGroupRolesAssigned = detailsFramework.UnitGroupRolesAssigned
	local _GetSpellInfo = Details.getspellinfo
	local isWOTLK = detailsFramework.IsWotLKWow()
	local isERA = detailsFramework.IsClassicWow()
	local _tempo = time()
	local _, Details222 = ...
	_ = nil

	local shield_cache = Details.ShieldCache --details local
	local parser = Details.parser --details local

	local cc_spell_list = detailsFramework.CrowdControlSpells
	local container_habilidades = Details.container_habilidades --details local

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
	local _spell_damage_func = Details.habilidade_dano.Add
	local _spell_damageMiss_func = Details.habilidade_dano.AddMiss
	local _spell_heal_func = Details.habilidade_cura.Add
	local _spell_energy_func = Details.habilidade_e_energy.Add
	local _spell_utility_func = Details.habilidade_misc.Add

	--current combat and overall pointers
		local _current_combat = Details.tabela_vigente or {} --placeholder table

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
		local damage_cache = setmetatable({}, Details.weaktable)
		local damage_cache_pets = setmetatable({}, Details.weaktable)
		local damage_cache_petsOwners = setmetatable({}, Details.weaktable)
	--heaing
		local healing_cache = setmetatable({}, Details.weaktable)
		local banned_healing_spells = {
			[326514] = true, --remove on 10.0 - Forgeborne Reveries - necrolords ability
		}
	--energy
		local energy_cache = setmetatable({}, Details.weaktable)
	--misc
		local misc_cache = setmetatable({}, Details.weaktable)
		local misc_cache_pets = setmetatable({}, Details.weaktable)
		local misc_cache_petsOwners = setmetatable({}, Details.weaktable)
	--party & raid members
		local raid_members_cache = setmetatable({}, Details.weaktable)
	--tanks
		local tanks_members_cache = setmetatable({}, Details.weaktable)
	--auto regen
		local auto_regen_cache = setmetatable({}, Details.weaktable)
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
			rampage_cast_amount = {},
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
			[413426] = true, --rippling anthem (trinket 10.1)
			[405734] = true, --spore tender
			[406785] = true, --invigorating spore cloud
		}

		local empower_cache = {}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants
	local container_misc = Details.container_type.CONTAINER_MISC_CLASS

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

			[401422] = 401428, --vessel of searing shadow (trinket)
		}

		--all totem
		--377461 382133
		--377458 377459
	end

	local bitfield_debuffs = {}
	for _, spellid in ipairs(Details.BitfieldSwapDebuffsIDs) do
		local spellname = GetSpellInfo(spellid)
		if (spellname) then
			bitfield_debuffs[spellname] = true
		else
			bitfield_debuffs[spellid] = true
		end
	end

	for spellId in pairs(Details.BitfieldSwapDebuffsSpellIDs) do
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
	Details.OverridedSpellIds = override_spellId

	--list of ignored npcs by the user
	Details.default_ignored_npcs = {
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
	Details.SpellsToIgnore = damage_spells_to_ignore

	--is parser allowed to replace spellIDs?
		local is_using_spellId_override = false

	--cache data for fast access during parsing
		local _in_combat = false
		local _current_encounter_id
		local _in_resting_zone = false
		local _global_combat_counter = 0

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

		local _hook_cooldowns_container = Details.hooks ["HOOK_COOLDOWN"]
		local _hook_deaths_container = Details.hooks ["HOOK_DEATH"]
		local _hook_battleress_container = Details.hooks ["HOOK_BATTLERESS"]
		local _hook_interrupt_container = Details.hooks ["HOOK_INTERRUPT"]

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
		if ((Details.LastPullMsg or 0) + 30 > time()) then
			Details.WhoAggroTimer = nil
			return
		end
		Details.LastPullMsg = time()

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

		Details:Msg(hitLine .. targetLine)
		Details.WhoAggroTimer = nil
		Details.bossTargetAtPull = nil
	end

	local lastRecordFound = {id = 0, diff = 0, combatTime = 0}

	Details.PrintEncounterRecord = function(self)
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
				local db = Details.GetStorage()

				local role = _UnitGroupRolesAssigned("player")
				local isDamage = (role == "DAMAGER") or (role == "TANK") --or true
				local bestRank, encounterTable = Details.storage:GetBestFromPlayer (diff, encounterID, isDamage and "damage" or "healing", Details.playername, true)

				if (bestRank) then
					local playerTable, onEncounter, rankPosition = Details.storage:GetPlayerGuildRank (diff, encounterID, isDamage and "damage" or "healing", Details.playername, true)

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
				Details:Msg("|cFFFFBB00Your Best Score|r:", Details:ToK2 ((value) / combatTime) .. " [|cFFFFFF00Guild Rank: " .. rank .. "|r]") --localize-me
			end

			if ((not combatTime or combatTime == 0) and not Details.SyncWarning) then
				Details:Msg("|cFFFF3300you may need sync the rank within the guild, type '|cFFFFFF00/details rank|r'|r") --localize-me
				Details.SyncWarning = true
			end
		end

	end

	--~spell ~spelldamage
	function parser:spell_dmg(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetRaidFlags, spellId, spellName, spellType, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand, isreflected, A1, A2, A3)
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
					(not Details.in_group and sourceFlags and bitBand(sourceFlags, AFFILIATION_GROUP) ~= 0)
				)
			) then
				--avoid Fel Armor and Undulating Maneuvers from starting a combat.
				if ((spellId == 387846 or spellId == 352561) and sourceName == Details.playername) then
					return
				end

				if (Details.encounter_table.id and Details.encounter_table["start"] >= GetTime() - 3 and Details.announce_firsthit.enabled) then
					local link
					if (spellId <= 10) then
						link = _GetSpellInfo(spellId)
					else
						link = _GetSpellInfo(spellId)
					end

					if (Details.WhoAggroTimer) then
						Details.WhoAggroTimer:Cancel()
					end

					Details.WhoAggroTimer = C_Timer.NewTimer(0.1, who_aggro)
					Details.WhoAggroTimer.HitBy = "|cFFFFFF00First Hit|r: " .. (link or "") .. " from " .. (sourceName or "Unknown")
					print("debug:", Details.WhoAggroTimer.HitBy)
				end

				Details:EntrarEmCombate(sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags)
			else
				--entrar em combate se for dot e for do jogador e o ultimo combate ter sido a mais de 10 segundos atr�s
				if (token == "SPELL_PERIODIC_DAMAGE" and sourceName == Details.playername) then
					--ignora burning rush se o jogador estiver fora de combate
					--111400 warlock's burning rush
					--368637 is buff from trinket "Scars of Fraternal Strife" which make the player bleed even out-of-combat
					--371070 is "Iced Phial of Corrupting Rage" effect triggers randomly, even out-of-combat
					--401394 is "Vessel of Seared Shadows" trinket
					if (spellId == 111400 or spellId == 371070 or spellId == 368637 or spellId == 401394) then
						return
					end

					--warlock corruption dot that never expires
					if (spellId == 146739) then
						return
					end

					--faz o calculo dos 10 segundos
					if (Details.last_combat_time + 10 < _tempo) then
						Details:EntrarEmCombate(sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags)
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
					if (Details.damage_taken_everything) then
						if (absorbed) then
							amount = (amount or 0) - absorbed
						end
					end
				end

				--avoidance
				local avoidance = targetActor.avoidance
				if (not avoidance) then
					targetActor.avoidance = Details:CreateActorAvoidanceTable()
					avoidance = targetActor.avoidance
				end

				local overall = avoidance.overall

				local mob = avoidance [sourceName]
				if (not mob) then --if isn't in the table, build on the fly
					mob =  Details:CreateActorAvoidanceTable (true)
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
					--add aos hits sem absorbs
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
				local unitId = Details.arena_enemies[targetName]
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
		if (not sourceActor.dps_started) then
			--register on time machine
			sourceActor:GetOrChangeActivityStatus(true)

			if (ownerActor and not ownerActor.dps_started) then
				ownerActor:GetOrChangeActivityStatus(true)
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
			if (sourceActor.nome == Details.playername and token ~= "SPELL_PERIODIC_DAMAGE") then
				if (UnitAffectingCombat("player")) then
					Details:SendEvent("COMBAT_PLAYER_TIMESTARTED", nil, _current_combat, sourceActor)
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
	--amount add ~roskash
		if (Details222.Roskash[sourceSerial]) then
			local rSourceSerial, rSourceName, rSourceFlags = unpack(Details222.Roskash[sourceSerial])
			local roskashActor = damage_cache[rSourceSerial]

			if (not roskashActor) then
				roskashActor = _current_damage_container:PegarCombatente(rSourceSerial, rSourceName, rSourceFlags, true)
			end

			if (roskashActor) then
				roskashActor.extra_bar = roskashActor.extra_bar + (amount * 0.14)
			end
		end

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
				Details.spell_school_cache[spellName] = spellType or school
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
			sourceActor.avoidance = Details:CreateActorAvoidanceTable()
			avoidance = sourceActor.avoidance
		end

		local overall = avoidance.overall

		local mob = avoidance [sourceName]
		if (not mob) then --if isn't in the table, build on the fly
			mob =  Details:CreateActorAvoidanceTable (true)
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
			--add aos hits sem absorbs
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
					TargetActor.avoidance = Details:CreateActorAvoidanceTable()
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
						mob = Details:CreateActorAvoidanceTable (true)
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
					Details.spell_school_cache [spellname] = spelltype
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
				Details.tabela_pets:Adicionar(petSerial:gsub("%-15439%-", "%-15438%-"), "Greater Fire Elemental", petFlags, sourceSerial, sourceName, sourceFlags)
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

		Details.tabela_pets:Adicionar(petSerial, petName, petFlags, sourceSerial, sourceName, sourceFlags)
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
			if (not meu_dono and who_flags and who_serial ~= "") then --se n�o for um pet, add no cache
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

		------------------------------------------------

		este_jogador.totaldenied = este_jogador.totaldenied + amountDenied

		--actor spells table
		local spell = este_jogador.spells._ActorTable [spellidAbsorb]
		if (not spell) then
			spell = este_jogador.spells:PegaHabilidade (spellidAbsorb, true, token)
			if (_current_combat.is_boss and who_flags and bitBand(who_flags, OBJECT_TYPE_ENEMY) ~= 0) then
				Details.spell_school_cache [spellnameAbsorb] = spellschoolAbsorb or 1
			end
		end

		--return spell:Add (alvo_serial, alvo_name, alvo_flags, cura_efetiva, who_name, absorbed, critical, overhealing)
		return _spell_heal_func(spell, alvo_serial, alvo_name, alvo_flags, amountDenied, spellidHeal, token, nameHealer, overhealing)

	end

	function parser:heal_absorb(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellSchool, shieldOwnerSerial, shieldOwnerName, shieldOwnerFlags, shieldOwnerFlags2, shieldSpellId, shieldName, shieldType, amount)
		if (isWOTLK or isERA) then
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

		elseif (bitBand(targetFlags, REACTION_FRIENDLY) == 0 and not Details.is_in_arena and not Details.is_in_battleground) then
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
				local unitId = Details.arena_enemies[targetName]
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
		if (not sourceActor.iniciar_hps) then
			sourceActor:GetOrChangeActivityStatus (true) --inicia o hps do jogador

			if (ownerActor and not ownerActor.iniciar_hps) then
				ownerActor:GetOrChangeActivityStatus (true)
				if (ownerActor.end_time) then
					ownerActor.end_time = nil
				else
					ownerActor.start_time = _tempo
				end
			end

			if (sourceActor.end_time) then --o combate terminou, reabrir o tempo
				sourceActor.end_time = nil
			else
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
				Details.spell_school_cache[spellName] = spellType
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
			if (not meu_dono and who_flags and who_serial ~= "") then --se n�o for um pet, add no cache
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

		if (spellId == 395152) then --~roskash
			Details222.Roskash[targetSerial] = {sourceSerial, sourceName, sourceFlags}
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
				if (Details.playername == targetName) then
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
					if (detailsFramework:IsNearlyEqual(pet_frenzy_cache[sourceName], time, 0.2)) then
						return
					end
				end

				if (not Details.in_combat) then
					C_Timer.After(1, function()
						if (Details.in_combat) then
							if (pet_frenzy_cache[sourceName]) then
								if (detailsFramework:IsNearlyEqual(pet_frenzy_cache[sourceName], time, 0.2)) then
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

	--~crowd control ~ccdone
	function parser:add_cc_done(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName)
		_current_misc_container.need_refresh = true

		---@type actor
		local sourceActor, ownerActor = misc_cache[sourceName]
		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_misc_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
			if (not ownerActor) then
				misc_cache[sourceName] = sourceActor
			end
		end

		sourceActor.last_event = _tempo

		if (not sourceActor.cc_done) then
			sourceActor.cc_done = Details:GetOrderNumber()
			sourceActor.cc_done_spells = container_habilidades:NovoContainer(container_misc)
			sourceActor.cc_done_targets = {}
		end

		--add amount
		sourceActor.cc_done = sourceActor.cc_done + 1
		sourceActor.cc_done_targets[targetName] = (sourceActor.cc_done_targets[targetName] or 0) + 1

		--actor spells table
		local spellTable = sourceActor.cc_done_spells._ActorTable[spellId]
		if (not spellTable) then
			spellTable = sourceActor.cc_done_spells:PegaHabilidade(spellId, true)
		end
		spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1
		spellTable.counter = spellTable.counter + 1

		--add the crowd control for the pet owner
		if (ownerActor) then
			if (not ownerActor.cc_done) then
				ownerActor.cc_done = Details:GetOrderNumber()
				ownerActor.cc_done_spells = container_habilidades:NovoContainer(container_misc)
				ownerActor.cc_done_targets = {}
			end

			--add amount
			ownerActor.cc_done = ownerActor.cc_done + 1
			ownerActor.cc_done_targets[targetName] = (ownerActor.cc_done_targets[targetName] or 0) + 1

			--actor spells table
			local ownerSpellTable = ownerActor.cc_done_spells._ActorTable[spellId]
			if (not ownerSpellTable) then
				ownerSpellTable = ownerActor.cc_done_spells:PegaHabilidade(spellId, true)
			end

			ownerSpellTable.targets[targetName] = (ownerSpellTable.targets[targetName] or 0) + 1
			ownerSpellTable.counter = ownerSpellTable.counter + 1
		end

		if (not sourceActor.classe) then
			if (sourceFlags and bitBand(sourceFlags, OBJECT_TYPE_PLAYER) ~= 0) then
				if (sourceActor.classe == "UNKNOW" or sourceActor.classe == "UNGROUPPLAYER") then
					---@type actor
					local damageActor = damage_cache [sourceSerial]
					if (damageActor and (damageActor.classe ~= "UNKNOW" and damageActor.classe ~= "UNGROUPPLAYER")) then
						sourceActor.classe = damageActor.classe
					else
						---@type actor
						local healingActor = healing_cache[sourceSerial]
						if (healingActor and (healingActor.classe ~= "UNKNOW" and healingActor.classe ~= "UNGROUPPLAYER")) then
							sourceActor.classe = healingActor.classe
						end
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
							if (detailsFramework:IsNearlyEqual(pet_frenzy_cache[sourceName], time, 0.2)) then
								return
							end
						end
					end
				end

				parser:add_buff_uptime(token, time, sourceSerial, sourceName, sourceFlags, sourceSerial, sourceName, sourceFlags, 0x0, spellid, spellName, "BUFF_UPTIME_REFRESH")
				pet_frenzy_cache[sourceName] = time
				return
			end

			if (spellid == 395152) then --~roskash
				Details222.Roskash[alvo_serial] = {sourceSerial, sourceName, sourceFlags}
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
			if (spellid == 395152) then --~roskash
				Details222.Roskash[targetSerial] = nil
			end

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
				este_alvo = Details.atributo_misc:CreateBuffTargetObject()
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
					este_alvo.uptime = este_alvo.uptime + Details._tempo - este_alvo.actived_at
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

	local resourcePowerType = {
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

	Details.resource_strings = {
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

	Details.resource_icons = {
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
			local actorName = Details:GetCLName(unitID)
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
	function parser:energize (token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellType, amount, overpower, powerType, altpower)
		if (not sourceName) then
			sourceName = "[*] " .. spellName
		elseif (not targetName) then
			return
		end

		--get resource type
		local bIsResource, resourceAmount, resourceId = resourcePowerType[powerType], amount, powerType

		--check if is valid
		if (not energy_types[powerType] and not bIsResource) then
			return

		elseif (bIsResource) then
			powerType = bIsResource
			amount = 0
		end

		overpower = overpower or 0
		_current_energy_container.need_refresh = true

		--get actors
		---@type actor
		local sourceActor = energy_cache[sourceName]
		local ownerActor

		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_energy_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
			sourceActor.powertype = powerType
			if (ownerActor) then
				ownerActor.powertype = powerType
			end
			if (not ownerActor) then
				energy_cache[sourceName] = sourceActor
			end
		end

		if (not sourceActor.powertype) then
			sourceActor.powertype = powerType
		end

		---@type actor
		local targetActor = energy_cache[targetName]
		local ownerTarget
		if (not targetActor) then
			targetActor, ownerTarget, targetName = _current_energy_container:PegarCombatente(targetSerial, targetName, targetFlags, true)
			targetActor.powertype = powerType
			if (ownerTarget) then
				ownerTarget.powertype = powerType
			end
			if (not ownerTarget) then
				energy_cache[targetName] = targetActor
			end
		end

		if (targetActor.powertype ~= sourceActor.powertype) then
			return
		end

		sourceActor.last_event = _tempo

		--amount add

		if (not bIsResource) then
			--add to targets
			sourceActor.targets[targetName] = (sourceActor.targets[targetName] or 0) + amount

			--add to combat total
			_current_total[3][powerType] = _current_total[3][powerType] + amount

			if (sourceActor.grupo) then
				_current_gtotal [3] [powerType] = _current_gtotal [3] [powerType] + amount
			end

			--regen produced amount
			sourceActor.total = sourceActor.total + amount
			sourceActor.totalover = sourceActor.totalover + overpower

			--target regenerated amount
			targetActor.received = targetActor.received + amount

			--owner
			if (ownerActor) then
				ownerActor.total = ownerActor.total + amount
			end

			--actor spells table
			local spellTable = sourceActor.spells._ActorTable[spellId]
			if (not spellTable) then
				spellTable = sourceActor.spells:PegaHabilidade(spellId, true, token)
			end

			--return spell:Add (alvo_serial, alvo_name, alvo_flags, amount, who_name, powertype)
			return _spell_energy_func (spellTable, targetSerial, targetName, targetFlags, amount, sourceName, powerType, overpower)
		else
			--is a resource
			sourceActor.resource = sourceActor.resource + resourceAmount
			sourceActor.resource_type = resourceId
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
			sourceActor.cooldowns_defensive = Details:GetOrderNumber(sourceName)
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
					Details:Msg("error occurred on a cooldown hook function:", errorText)
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
		---@type actorutility, actorutility
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
			sourceActor.interrupt = Details:GetOrderNumber()
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
				ownerActor.interrupt = Details:GetOrderNumber(sourceName)
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

		--rampage cast spam
		if (spellId == 184367 or spellId == 184707 or spellId == 201364) then --rampage spellIds (IDs from Retail - wow patch 10.1.0)
			local latestRampageCastByPlayer = (cacheAnything.rampage_cast_amount[sourceName] or 0)
			if (latestRampageCastByPlayer > time - 0.8) then
				return
			end
			cacheAnything.rampage_cast_amount[sourceName] = time
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


	--serach key: ~dispel
	---@param token string
	---@param time unixtime
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
	function parser:dispell(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellType, extraSpellID, extraSpellName, extraSchool, auraType)
		if (not sourceName) then
			sourceName = "[*] " .. extraSpellName
		end
		if (not targetName) then
			targetName = "[*] " .. spellId
		end

		_current_misc_container.need_refresh = true

		---@type actor, actor
		local sourceActor, ownerActor = misc_cache[sourceName]
		if (not sourceActor) then
			sourceActor, ownerActor, sourceName = _current_misc_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
			if (not ownerActor) then
				misc_cache[sourceName] = sourceActor
			end
		end

		--build containers on the fly
		if (not sourceActor.dispell) then
			---@type number
			sourceActor.dispell = Details:GetOrderNumber(sourceName)

			---@type table<actorname, number>
			sourceActor.dispell_targets = {}

			---@type spellcontainer
			sourceActor.dispell_spells = container_habilidades:NovoContainer(container_misc)

			---@type table<spellid, number>
			sourceActor.dispell_oque = {}
		end

		--spell reflection
		if (reflection_dispelid[spellId]) then
			--this aura could've been reflected to the caster after the dispel
			--save data about whom was dispelled by who and what spell it was
			reflection_dispels[targetSerial] = reflection_dispels[targetSerial] or {}
			reflection_dispels[targetSerial][extraSpellID] = {
				who_serial = sourceSerial,
				who_name = sourceName,
				who_flags = sourceFlags,
				spellid = spellId,
				spellname = spellName,
				spelltype = spellType,
			}
		end

		--last event update
		sourceActor.last_event = _tempo

		--total dispells in combat
		_current_total[4].dispell = _current_total[4].dispell + 1

		if (sourceActor.grupo) then
			_current_gtotal[4].dispell = _current_gtotal[4].dispell + 1
		end

		--actor dispell amount
		sourceActor.dispell = sourceActor.dispell + 1

		--dispelled what
		if (extraSpellID) then
			sourceActor.dispell_oque[extraSpellID] = (sourceActor.dispell_oque[extraSpellID] or 0) + 1
		end

		--actor targets
		sourceActor.dispell_targets[targetName] = (sourceActor.dispell_targets[targetName] or 0) + 1

		--actor spells table
		---@type spelltable
		local spellTable = sourceActor.dispell_spells._ActorTable[spellId]
		if (not spellTable) then
			spellTable = sourceActor.dispell_spells:PegaHabilidade(spellId, true, token)
		end
		_spell_utility_func(spellTable, targetSerial, targetName, targetFlags, sourceName, token, extraSpellID, extraSpellName)

		--is has an owner, add the dispel to the owner as well
		if (ownerActor) then
			if (not ownerActor.dispell) then
				ownerActor.dispell = Details:GetOrderNumber(sourceName)
				ownerActor.dispell_targets = {}
				ownerActor.dispell_spells = container_habilidades:NovoContainer(container_misc)
				ownerActor.dispell_oque = {}
			end

			ownerActor.dispell = ownerActor.dispell + 1
			ownerActor.dispell_targets[targetName] = (ownerActor.dispell_targets[targetName] or 0) + 1
			ownerActor.last_event = _tempo

			if (extraSpellID) then
				ownerActor.dispell_oque[extraSpellID] = (ownerActor.dispell_oque[extraSpellID] or 0) + 1
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
			if (not meu_dono) then --se n�o for um pet, add no cache
				misc_cache [who_name] = este_jogador
			end
		end

	------------------------------------------------------------------------------------------------
	--build containers on the fly

		if (not este_jogador.ress) then
			este_jogador.ress = Details:GetOrderNumber(who_name)
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
	function parser:break_cc(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellType, extraSpellID, extraSpellName, extraSchool, auraType)
		if (not cc_spell_list[spellId]) then
			return

		elseif (bitBand(sourceFlags, AFFILIATION_GROUP) == 0) then
			return

		elseif (not targetName) then
			return --no target name, just quit
		end

		if (not spellName) then
			spellName = "Melee"
		end

		if (not sourceName) then
			sourceName = "[*] " .. spellName --if there's no sourceName, use spellName instead
			sourceFlags = 0xa48
			sourceSerial = ""
		end

		_current_misc_container.need_refresh = true

		---@type actorutility, actorutility
		local sourceActor, ownerActor = misc_cache[sourceName], nil
		if (not sourceActor) then --unknown if is a pet or player
			sourceActor, ownerActor, sourceName = _current_misc_container:PegarCombatente(sourceSerial, sourceName, sourceFlags, true)
			if (not ownerActor) then --not a pet: add to cache
				misc_cache[sourceName] = sourceActor
			end
		end

		--create the spell container on the fly
		if (not sourceActor.cc_break) then
			sourceActor.cc_break = Details:GetOrderNumber()
			sourceActor.cc_break_targets = {}
			sourceActor.cc_break_oque = {}
			---@type spellcontainer
			sourceActor.cc_break_spells = container_habilidades:NovoContainer(container_misc)
		end

		sourceActor.last_event = _tempo

		--add amount
		_current_total[4].cc_break = _current_total[4].cc_break + 1
		if (sourceActor.grupo) then
			_current_combat.totals_grupo[4].cc_break = _current_combat.totals_grupo[4].cc_break + 1
		end

		--add amount
		sourceActor.cc_break = sourceActor.cc_break + 1

		--broke what
		sourceActor.cc_break_oque[spellId] = (sourceActor.cc_break_oque[spellId] or 0) + 1

		--actor targets
		sourceActor.cc_break_targets[targetName] = (sourceActor.cc_break_targets[targetName] or 0) + 1

		---@type spelltable
		local spellTable = sourceActor.cc_break_spells._ActorTable[extraSpellID]
		if (not spellTable) then
			spellTable = sourceActor.cc_break_spells:PegaHabilidade(extraSpellID, true, token)
		end
		return _spell_utility_func(spellTable, targetSerial, targetName, targetFlags, sourceName, token, spellId, spellName)
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
	function parser:dead(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags)
		--early checks and fixes
		if (not targetName) then
			return
		end

		---@type actordamage
		local damageActor = _current_damage_container:GetActor(targetName)
		--check if the dead actor is an actor outside the player group, for instance a pvp player or a npc
		if (_in_combat and targetFlags and (not damageActor or (bitBand(targetFlags, 0x00000008) ~= 0 and not damageActor.grupo))) then
			--frags
			if (Details.only_pvp_frags and (bitBand(targetFlags, 0x00000400) == 0 or (bitBand(targetFlags, 0x00000040) == 0 and bitBand(targetFlags, 0x00000020) == 0))) then --byte 2 = 4 (HOSTILE) byte 3 = 4 (OBJECT_TYPE_PLAYER)
				return
			end

			if (not _current_combat.frags[targetName]) then
				_current_combat.frags[targetName] = 1
			else
				_current_combat.frags[targetName] = _current_combat.frags[targetName] + 1
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
				_current_total[4].dead = _current_total[4].dead + 1
				_current_gtotal[4].dead = _current_gtotal[4].dead + 1

				--main actor no container de misc que ir� armazenar a morte
				local thisPlayer, meu_dono = misc_cache [targetName]
				if (not thisPlayer) then --pode ser um desconhecido ou um pet
					thisPlayer, meu_dono, sourceName = _current_misc_container:PegarCombatente (targetSerial, targetName, targetFlags, true)
					if (not meu_dono) then --se n�o for um pet, add no cache
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
					eventTable[1] = 3 --event type
					eventTable[2] = 0 --spellId
					eventTable[3] = 0 --amount of damage or healing but in this case is 0
					eventTable[4] = 0 --when the event happened using unix time
					eventTable[5] = 0 --player health when the event happened
					eventTable[6] = targetName --source name
					eventsBeforePlayerDeath[#eventsBeforePlayerDeath+1] = eventTable
				end

				local maxHealth
				if (thisPlayer.arena_enemy) then
					--this is an arena enemy, get the heal with the unit Id
					local unitId = Details.arena_enemies[thisPlayer.nome]
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
						["spec"] = thisPlayer.spec,
					}
				end

				tinsert(_current_combat.last_events_tables, #_current_combat.last_events_tables+1, playerDeathTable)

				--check if this is a mythic+ run for overall deaths
				if (bIsMythicRun) then
					--more checks for integrity
					if (Details.tabela_overall and Details.tabela_overall.last_events_tables) then
						--this is a mythic dungeon run, add the death to overall data
						--need to adjust the time of death, since this will show all deaths in the mythic run
						--first copy the table
						local overallDeathTable = detailsFramework.table.copy({}, playerDeathTable)

						--get the elapsed time
						local mythicPlusElapsedTime = GetTime() - Details.tabela_overall:GetStartTime()
						local minutes, seconds = floor(mythicPlusElapsedTime/60), floor(mythicPlusElapsedTime % 60)

						overallDeathTable[6] = minutes .. "m " .. seconds .. "s"
						overallDeathTable.dead_at = mythicPlusElapsedTime

						--save data about the mythic run in the deathTable which goes in the regular segment
						--confused? 'playerDeathTable' is added into the '_current_combat.last_events_tables' ~20 above on a tinsert
						playerDeathTable["mythic_plus"] = true
						playerDeathTable["mythic_plus_dead_at"] = mythicPlusElapsedTime
						playerDeathTable["mythic_plus_dead_at_string"] = overallDeathTable[6]

						--now add the death table into the overall data (this is the regular overall data, not the mythic plus overall data)
						tinsert(Details.tabela_overall.last_events_tables, #Details.tabela_overall.last_events_tables + 1, overallDeathTable)
					end
				end

				if (_hook_deaths) then
					--send event to registred functions
					for _, func in ipairs(_hook_deaths_container) do
						local successful, errortext = pcall(func, nil, token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, playerDeathTable, thisPlayer.last_cooldown, combatElapsedTime, maxHealth, playerDeathTable["mythic_plus_dead_at"] or 0)
						if (not successful) then
							Details:Msg("error occurred on a death hook function:", errortext)
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
		Details:Destroy(monk_guard_talent)
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

	Details.capture_types = {"damage", "heal", "energy", "miscdata", "aura", "spellcast"}
	Details.capture_schedules = {}

	function Details:CaptureIsAllEnabled()
		for _, thisType in ipairs(Details.capture_types) do
			if (not Details.capture_real[thisType]) then
				return false
			end
		end
		return true
	end

	function Details:CaptureIsEnabled(capture)
		if (Details.capture_real[capture]) then
			return true
		end
		return false
	end

	function Details:CaptureRefresh()
		for _, thisType in ipairs(Details.capture_types) do
			if (Details.capture_current[thisType]) then
				Details:CaptureEnable(thisType)
			else
				Details:CaptureDisable(thisType)
			end
		end
	end

	function Details:CaptureGet(captureType)
		return Details.capture_real[captureType]
	end

	function Details:CaptureSet(onOff, captureType, real, time)
		if (onOff == nil) then
			onOff = Details.capture_real[captureType]
		end

		if (real) then
			--hard switch
			Details.capture_real[captureType] = onOff
			Details.capture_current[captureType] = onOff
		else
			--soft switch
			Details.capture_current[captureType] = onOff
			if (time) then
				local scheduleId = math.random(1, 10000000)
				local new_schedule = Details:ScheduleTimer("CaptureTimeout", time, {captureType, scheduleId}) --todo: use Details.Schedule
				tinsert(Details.capture_schedules, {new_schedule, scheduleId})
			end
		end

		Details:CaptureRefresh()
	end

	function Details:CancelAllCaptureSchedules()
		for i = 1, #Details.capture_schedules do
			local schedule_table, schedule_id = unpack(Details.capture_schedules[i])
			Details:CancelTimer(schedule_table)
		end
		Details:Destroy(Details.capture_schedules)
	end

	function Details:CaptureTimeout (table)
		local capture_type, schedule_id = unpack(table)
		Details.capture_current [capture_type] = Details.capture_real [capture_type]
		Details:CaptureRefresh()

		for index, table in ipairs(Details.capture_schedules) do
			local id = table [2]
			if (schedule_id == id) then
				tremove(Details.capture_schedules, index)
				break
			end
		end
	end

	function Details:CaptureDisable (capture_type)

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


	function Details:CaptureEnable (capture_type)

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
			return Details:Msg("Invalid Token for SetParserFunction.")
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

	function Details:CallWipe (from_slash)
		Details:Msg("Wipe has been called by your raid leader.")

		if (Details.wipe_called) then
			if (from_slash) then
				return Details:Msg(Loc ["STRING_WIPE_ERROR1"])
			else
				return
			end
		elseif (not Details.encounter_table.id) then
			if (from_slash) then
				return Details:Msg(Loc ["STRING_WIPE_ERROR2"])
			else
				return
			end
		end

		local eTable = Details.encounter_table

		--finish the encounter
		local successful_ended = Details.parser_functions:ENCOUNTER_END (eTable.id, eTable.name, eTable.diff, eTable.size, 0)

		if (successful_ended) then
			--we wiped
			Details.wipe_called = true

			--cancel the on going captures schedules
			Details:CancelAllCaptureSchedules()

			--disable it
			Details:CaptureSet (false, "damage", false)
			Details:CaptureSet (false, "energy", false)
			Details:CaptureSet (false, "aura", false)
			Details:CaptureSet (false, "energy", false)
			Details:CaptureSet (false, "spellcast", false)

			if (from_slash) then
				if (UnitIsGroupLeader ("player")) then
					Details:SendHomeRaidData ("WI")
				end
			end

			local lower_instance = Details:GetLowerInstanceNumber()
			if (lower_instance) then
				lower_instance = Details:GetInstance(lower_instance)
				lower_instance:InstanceAlert (Loc ["STRING_WIPE_ALERT"], {[[Interface\CHARACTERFRAME\UI-StateIcon]], 18, 18, false, 0.5, 1, 0, 0.5}, 4)
			end
		else
			if (from_slash) then
				return Details:Msg(Loc ["STRING_WIPE_ERROR3"])
			else
				return
			end
		end

	end

	-- PARSER
	--serach key: ~parser ~events ~start ~inicio
	function Details:FlagNewCombat_PVPState()
		if (Details.is_in_battleground) then
			Details.tabela_vigente.pvp = true
			Details.tabela_vigente.is_pvp = {name = Details.zone_name, mapid = Details.zone_id}

		elseif (Details.is_in_arena) then
			Details.tabela_vigente.arena = true
			Details.tabela_vigente.is_arena = {name = Details.zone_name, zone = Details.zone_name, mapid = Details.zone_id}
		end
	end

	function Details:GetZoneType()
		return Details.zone_type
	end

	function Details.parser_functions:ZONE_CHANGED_NEW_AREA(...)
		return Details.Schedules.After(1, Details.Check_ZONE_CHANGED_NEW_AREA)
	end

	--~zone ~area
	function Details:Check_ZONE_CHANGED_NEW_AREA()
		local zoneName, zoneType, _, _, _, _, _, zoneMapID = GetInstanceInfo()

		Details.zone_type = zoneType
		Details.zone_id = zoneMapID
		Details.zone_name = zoneName

		_in_resting_zone = IsResting()

		parser:WipeSourceCache()

		_is_in_instance = false

		if (zoneType == "party" or zoneType == "raid") then
			_is_in_instance = true
		end

		if (Details.last_zone_type ~= zoneType) then
			Details:SendEvent("ZONE_TYPE_CHANGED", nil, zoneType)
			Details.last_zone_type = zoneType

			for index, instancia in ipairs(Details.tabela_instancias) do
				if (instancia.ativa) then
					instancia:AdjustAlphaByContext(true)
				end
			end
		end

		Details.time_type = Details.time_type_original

		if (Details.debug) then
			Details:Msg("(debug) zone change:", Details.zone_name, "is a", Details.zone_type, "zone.")
		end

		if (Details.is_in_arena and zoneType ~= "arena") then
			Details:LeftArena()
		end

		--check if the player left a battleground
		if (Details.is_in_battleground and zoneType ~= "pvp") then
			Details.pvp_parser_frame:StopBgUpdater()
			Details.is_in_battleground = nil
			Details.time_type = Details.time_type_original
		end

		if (zoneType == "pvp") then --battlegrounds
			if (Details.debug) then
				Details:Msg("(debug) zone type is now 'pvp'.")
			end

			if(not Details.is_in_battleground and Details.overall_clear_pvp) then
				Details.tabela_historico:ResetOverallData()
			end

			Details.is_in_battleground = true

			if (_in_combat and not _current_combat.pvp) then
				Details:SairDoCombate()
			end

			if (not _in_combat) then
				Details:EntrarEmCombate()
			end

			_current_combat.pvp = true
			_current_combat.is_pvp = {name = zoneName, mapid = zoneMapID}

			if (Details.use_battleground_server_parser) then
				if (Details.time_type == 1) then
					Details.time_type_original = 1
					Details.time_type = 2
				end
				Details.pvp_parser_frame:StartBgUpdater()
			else
				if (Details.force_activity_time_pvp) then
					Details.time_type_original = Details.time_type
					Details.time_type = 1
				end
			end

			Details.lastBattlegroundStartTime = GetTime()

		elseif (zoneType == "arena") then
			if (Details.debug) then
				Details:Msg("(debug) zone type is now 'arena'.")
			end

			if (Details.force_activity_time_pvp) then
				Details.time_type_original = Details.time_type
				Details.time_type = 1
			end

			if (not Details.is_in_arena) then
				if (Details.overall_clear_pvp) then
					Details.tabela_historico:ResetOverallData()
				end
				--reset spec cache if broadcaster requested
				if (Details.streamer_config.reset_spec_cache) then
					Details:Destroy(Details.cached_specs)
				end
			end

			Details.is_in_arena = true
			Details:EnteredInArena()

		else
			local inInstance = IsInInstance()
			if ((zoneType == "raid" or zoneType == "party") and inInstance) then
				Details:CheckForAutoErase (zoneMapID)

				--if the current raid is current tier raid, pre-load the storage database
				if (zoneType == "raid") then
					if (Details.InstancesToStoreData [zoneMapID]) then
						Details.ScheduleLoadStorage()
					end
				end
			end

			if (Details:IsInInstance()) then
				Details.last_instance = zoneMapID
			end

			--if (_current_combat.pvp) then
			--	_current_combat.pvp = false
			--end
		end

		Details222.AutoRunCode.DispatchAutoRunCode("on_zonechanged")
		Details:SchedulePetUpdate(7)
		Details:CheckForPerformanceProfile()
	end

	function Details.parser_functions:PLAYER_ENTERING_WORLD ()
		return Details.parser_functions:ZONE_CHANGED_NEW_AREA()
	end

	-- ~encounter
	--ENCOUNTER START
	function Details.parser_functions:ENCOUNTER_START(...)
		if (Details.debug) then
			Details:Msg("(debug) |cFFFFFF00ENCOUNTER_START|r event triggered.")
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

		Details.latest_ENCOUNTER_END = Details.latest_ENCOUNTER_END or 0
		if (Details.latest_ENCOUNTER_END + 10 > GetTime()) then
			return
		end

		--leave the current combat when the encounter start, if is doing a mythic plus dungeons, check if the options allows to create a dedicated segment for the boss fight
		if ((_in_combat and not Details.tabela_vigente.is_boss) and (not Details.MythicPlus.Started or Details.mythic_plus.boss_dedicated_segment)) then
			Details:SairDoCombate()
		end

		local encounterID, encounterName, difficultyID, raidSize = select(1, ...)
		local zoneName, _, _, _, _, _, _, zoneMapID = GetInstanceInfo()

		if (Details.InstancesToStoreData[zoneMapID]) then
			Details.current_exp_raid_encounters[encounterID] = true
		end

		if (not Details.WhoAggroTimer and Details.announce_firsthit.enabled) then
			Details.WhoAggroTimer = C_Timer.NewTimer(0.1, who_aggro)
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

		if (IsInGuild() and IsInRaid() and Details.announce_damagerecord.enabled and Details.StorageLoaded) then
			Details.TellDamageRecord = C_Timer.NewTimer(0.6, Details.PrintEncounterRecord)
			Details.TellDamageRecord.Boss = encounterID
			Details.TellDamageRecord.Diff = difficultyID
		end

		_current_encounter_id = encounterID
		Details.boss1_health_percent = 1

		local dbm_mod, dbm_time = Details.encounter_table.DBM_Mod, Details.encounter_table.DBM_ModTime
		Details:Destroy(Details.encounter_table)

		Details.encounter_table.phase = 1

		--store the encounter time inside the encounter table for the encounter plugin
		Details.encounter_table.start = GetTime()
		Details.encounter_table ["end"] = nil
--		local encounterID = Details.encounter_table.id
		Details.encounter_table.id = encounterID
		Details.encounter_table.name = encounterName
		Details.encounter_table.diff = difficultyID
		Details.encounter_table.size = raidSize
		Details.encounter_table.zone = zoneName
		Details.encounter_table.mapid = zoneMapID

		if (dbm_mod and dbm_time == time()) then --pode ser time() � usado no start pra saber se foi no mesmo segundo.
			Details.encounter_table.DBM_Mod = dbm_mod
		end

		local encounter_start_table = Details:GetEncounterStartInfo (zoneMapID, encounterID)
		if (encounter_start_table) then
			if (encounter_start_table.delay) then
				if (type(encounter_start_table.delay) == "function") then
					local delay = encounter_start_table.delay()
					if (delay) then
						--_detalhes.encounter_table ["start"] = time() + delay
						Details.encounter_table ["start"] = GetTime() + delay
					end
				else
					--_detalhes.encounter_table ["start"] = time() + encounter_start_table.delay
					Details.encounter_table ["start"] = GetTime() + encounter_start_table.delay
				end
			end
			if (encounter_start_table.func) then
				encounter_start_table:func()
			end
		end

		local encounter_table, boss_index = Details:GetBossEncounterDetailsFromEncounterId (zoneMapID, encounterID)
		if (encounter_table) then
			Details.encounter_table.index = boss_index
		end

		Details:SendEvent("COMBAT_ENCOUNTER_START", nil, ...)
	end



	--ENCOUNRTER_END
	function Details.parser_functions:ENCOUNTER_END(...)
		if (Details.debug) then
			Details:Msg("(debug) |cFFFFFF00ENCOUNTER_END|r event triggered.")
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
		if (Details.zone_type == "party" or instanceType == "party") then
			if (Details.debug) then
				Details:Msg("(debug) the zone type is 'party', ignoring ENCOUNTER_END.")
			end
		end

		local encounterID, encounterName, difficultyID, raidSize, endStatus = select(1, ...)

		if (not Details.encounter_table.start) then
			Details:Msg("encounter table without start time.")
			return
		end

		Details.latest_ENCOUNTER_END = Details.latest_ENCOUNTER_END or 0
		if (Details.latest_ENCOUNTER_END + 15 > GetTime()) then
			return
		end

		Details.latest_ENCOUNTER_END = GetTime()
		Details.encounter_table ["end"] = GetTime() -- 0.351

		local _, _, _, _, _, _, _, zoneMapID = GetInstanceInfo()

		local bossIcon = Details:GetBossEncounterTexture(encounterName)
		_current_combat.bossIcon = bossIcon

		if (_in_combat) then
			if (endStatus == 1) then
				Details.encounter_table.kill = true
				Details:SairDoCombate (true, {encounterID, encounterName, difficultyID, raidSize, endStatus}) --killed
			else
				Details.encounter_table.kill = false
				Details:SairDoCombate (false, {encounterID, encounterName, difficultyID, raidSize, endStatus}) --wipe
			end
		else
			if ((Details.tabela_vigente:GetEndTime() or 0) + 2 >= Details.encounter_table ["end"]) then
				Details.tabela_vigente:SetStartTime (Details.encounter_table ["start"])
				Details.tabela_vigente:SetEndTime (Details.encounter_table ["end"])
				Details:RefreshMainWindow(-1, true)
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

		Details:SendEvent("COMBAT_ENCOUNTER_END", nil, ...)

		Details:Destroy(Details.encounter_table)
		Details:Destroy(dk_pets_cache.army)
		Details:Destroy(dk_pets_cache.apoc)
		Details:Destroy(empower_cache)

		return true
	end

	function Details.parser_functions:UNIT_PET(...)
		Details.container_pets:Unpet(...)
		Details:SchedulePetUpdate(1)
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


	function Details.parser_functions:PLAYER_REGEN_DISABLED(...)
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

		if (Details.zone_type == "pvp" and not Details.use_battleground_server_parser) then
			if (_in_combat) then
				Details:SairDoCombate()
			end
			Details:EntrarEmCombate()
		end

		if (not Details:CaptureGet("damage")) then
			Details:EntrarEmCombate()
		end

		--essa parte do solo mode ainda sera usada?
		if (Details.solo and Details.PluginCount.SOLO > 0) then --solo mode
			local esta_instancia = Details.tabela_instancias[Details.solo]
			esta_instancia.atualizando = true
		end

		for index, instancia in ipairs(Details.tabela_instancias) do
			if (instancia.ativa) then --1 = none, we doesn't need to call
				instancia:AdjustAlphaByContext(true)
			end
		end

		Details222.AutoRunCode.DispatchAutoRunCode("on_entercombat")

		Details.tabela_vigente.CombatStartedAt = GetTime()
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
	function Details:RunScheduledEventsAfterCombat(OnRegenEnabled)
		if (Details.debug) then
			Details:Msg("(debug) running scheduled events after combat end.")
		end

		TBC_JudgementOfLightCache = {
			_damageCache = {}
		}

		--when the user requested data from the storage but is in combat lockdown
		if (Details.schedule_storage_load) then
			Details.schedule_storage_load = nil
			Details.ScheduleLoadStorage()
		end

		--store a boss encounter when out of combat since it might need to load the storage
		if (Details.schedule_store_boss_encounter) then
			if (not Details.logoff_saving_data) then
				local successful, errortext = pcall(Details.Database.StoreEncounter)
				if (not successful) then
					Details:Msg("error occurred on Details.Database.StoreEncounter():", errortext)
				end
			end
			Details.schedule_store_boss_encounter = nil
		end

		if (Details.schedule_store_boss_encounter_wipe) then
			if (not Details.logoff_saving_data) then
				local successful, errortext = pcall(Details.Database.StoreWipe)
				if (not successful) then
					Details:Msg("error occurred on Details.Database.StoreWipe():", errortext)
				end
			end
			Details.schedule_store_boss_encounter_wipe = nil
		end

		--when a large amount of data has been removed and the player is in combat, schedule to run the hard garbage collector (the blizzard one, not the details! internal)
		if (Details.schedule_hard_garbage_collect) then
			if (Details.debug) then
				Details:Msg("(debug) found schedule collectgarbage().")
			end
			Details.schedule_hard_garbage_collect = false
			collectgarbage()
		end

		for index, instancia in ipairs(Details.tabela_instancias) do
			if (instancia.ativa) then --1 = none, we doesn't need to call
				instancia:AdjustAlphaByContext(true)
			end
		end

		if (not OnRegenEnabled) then
			Details:Destroy(bitfield_swap_cache)
			Details:Destroy(empower_cache)
			Details222.AutoRunCode.DispatchAutoRunCode("on_leavecombat")
		end

		if (Details.solo and Details.PluginCount.SOLO > 0) then --code too old and I don't have documentation for it
			if (Details.SoloTables.Plugins [Details.SoloTables.Mode].Stop) then
				Details.SoloTables.Plugins [Details.SoloTables.Mode].Stop()
			end
		end
	end

	function Details.parser_functions:CHALLENGE_MODE_START(...)
		--send mythic dungeon start event
		if (Details.debug) then
			print("parser event", "CHALLENGE_MODE_START", ...)
		end

		local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
		if (difficultyID == 8) then
			Details:SendEvent("COMBAT_MYTHICDUNGEON_START")
		end
	end

	function Details.parser_functions:CHALLENGE_MODE_COMPLETED(...)
		--send mythic dungeon end event
		local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
		if (difficultyID == 8) then
			Details:SendEvent("COMBAT_MYTHICDUNGEON_END")
		end

		local okay, errorText = pcall(function()
			local mapChallengeModeID, mythicLevel, time, onTime, keystoneUpgradeLevels, practiceRun, oldOverallDungeonScore, newOverallDungeonScore, IsMapRecord, IsAffixRecord, PrimaryAffix, isEligibleForScore, members = C_ChallengeMode.GetCompletionInfo()
			if (mapChallengeModeID) then
				local statName = "mythicdungeoncompletedDF2"
				local mythicDungeonRuns = Details222.PlayerStats:GetStat(statName)
				mythicDungeonRuns = mythicDungeonRuns or {}

				mythicDungeonRuns[mapChallengeModeID] = mythicDungeonRuns[mapChallengeModeID] or {}
				mythicDungeonRuns[mapChallengeModeID][mythicLevel] = mythicDungeonRuns[mapChallengeModeID][mythicLevel] or {}

				local currentRun = mythicDungeonRuns[mapChallengeModeID][mythicLevel]
				currentRun.completed = (currentRun.completed or 0) + 1
				currentRun.totalTime = (currentRun.totalTime or 0) + time
				if (not currentRun.minTime or time < currentRun.minTime) then
					currentRun.minTime = time
				end

				currentRun.history = currentRun.history or {}
				local day, month, year = tonumber(date("%d")), tonumber(date("%m")), tonumber(date("%Y"))
				local amountDeaths = C_ChallengeMode.GetDeathCount() or 0
				tinsert(currentRun.history, {day = day, month = month, year = year, runTime = time, onTime = onTime, deaths = amountDeaths, affix = PrimaryAffix})

				Details222.PlayerStats:SetStat("mythicdungeoncompletedDF2", mythicDungeonRuns)
			end
		end)

		if (not okay) then
			Details:Msg("something went wrong (0x7878):", errorText)
		end
	end

	function Details.parser_functions:PLAYER_REGEN_ENABLED(...)
		if (Details.debug) then
			Details:Msg("(debug) |cFFFFFF00PLAYER_REGEN_ENABLED|r event triggered.")

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

	function Details.parser_functions:PLAYER_TALENT_UPDATE()
		if (IsInGroup() or IsInRaid()) then
			if (Details.SendTalentTimer and not Details.SendTalentTimer:IsCancelled()) then
				Details.SendTalentTimer:Cancel()
			end
			Details.SendTalentTimer = C_Timer.NewTimer(11, function()
				Details:SendCharacterData()
			end)
		end
	end

	function Details:RefreshPlayerSpecialization()
		local specIndex = detailsFramework.GetSpecialization()
		if (specIndex) then
			local specID = detailsFramework.GetSpecializationInfo(specIndex)
			if (specID and specID ~= 0) then
				local guid = UnitGUID("player")
				if (guid) then
					Details.cached_specs[guid] = specID
					Details.playerspecid = specID
				end
			end
		end
	end

	function Details.parser_functions:PLAYER_SPECIALIZATION_CHANGED()
		--some parts of details! does call this function, check first for past expansions
		if (detailsFramework.IsTimewalkWoW()) then
			return
		end

		Details:RefreshPlayerSpecialization()

		if (IsInGroup() or IsInRaid()) then
			if (Details.SendTalentTimer and not Details.SendTalentTimer:IsCancelled()) then
				Details.SendTalentTimer:Cancel()
			end
			Details.SendTalentTimer = C_Timer.NewTimer(11, function()
				Details:SendCharacterData()
			end)
		end
	end

	--this is mostly triggered when the player enters in a dual against another player
	function Details.parser_functions:UNIT_FACTION(unit)
		if (true) then
			--disable until figure out how to make this work properlly
			--at the moment this event is firing at bgs, arenas, etc making horde icons to show at random
			return
		end

		--check if outdoors
		--unit was nil, nameplate might bug here, it should track after the event
		if (Details.zone_type == "none" and unit) then
			local serial = UnitGUID(unit)
			--the serial is valid and isn't THE player and the serial is from a player?
			if (serial and serial ~= UnitGUID("player") and serial:find("Player")) then
				Details.duel_candidates[serial] = GetTime()

				local playerName = Details:GetCLName(unit)

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

	function Details.parser_functions:ROLE_CHANGED_INFORM(...)
		if (Details.last_assigned_role ~= _UnitGroupRolesAssigned("player")) then
			Details:CheckSwitchOnLogon (true)
			Details.last_assigned_role = _UnitGroupRolesAssigned("player")
		end
	end

	function Details.parser_functions:PLAYER_ROLES_ASSIGNED(...)
		if (Details.last_assigned_role ~= _UnitGroupRolesAssigned("player")) then
			Details:CheckSwitchOnLogon (true)
			Details.last_assigned_role = _UnitGroupRolesAssigned("player")
		end
	end

	function Details:InGroup()
		return Details.in_group
	end

	function Details.parser_functions:GROUP_ROSTER_UPDATE(...)
		if (not Details.in_group) then
			Details.in_group = IsInGroup() or IsInRaid()

			if (Details.in_group) then
				--player entered in a group, cleanup and set the new enviromnent
				Details222.GarbageCollector.RestartInternalGarbageCollector(true)
				Details:WipePets()
				Details:SchedulePetUpdate(1)
				Details:InstanceCall(Details.AdjustAlphaByContext)

				Details:CheckSwitchOnLogon()
				Details:CheckVersion()
				Details:SendEvent("GROUP_ONENTER")

				Details222.AutoRunCode.DispatchAutoRunCode("on_groupchange")

				Details:Destroy(Details.trusted_characters)
				C_Timer.After(5, Details.ScheduleSyncPlayerActorData)
			end

		else
			Details.in_group = IsInGroup() or IsInRaid()

			if (not Details.in_group) then
				--player left the group, run routines to cleanup the environment
				Details222.GarbageCollector.RestartInternalGarbageCollector(true)
				Details:WipePets()
				Details:SchedulePetUpdate(1)
				Details:Destroy(Details.details_users)
				Details:InstanceCall(Details.AdjustAlphaByContext)
				Details:CheckSwitchOnLogon()
				Details:SendEvent("GROUP_ONLEAVE")
				Details222.AutoRunCode.DispatchAutoRunCode("on_groupchange")
				Details:Destroy(Details.trusted_characters)
			else
				--player is still in a group
				Details:SchedulePetUpdate(2)

				--send char data
				if (Details.SendCharDataOnGroupChange and not Details.SendCharDataOnGroupChange:IsCancelled()) then
					return
				end

				Details.SendCharDataOnGroupChange = C_Timer.NewTimer(11, function()
					Details:SendCharacterData()
					Details.SendCharDataOnGroupChange = nil
				end)
			end
		end

		Details:SchedulePetUpdate(6)
	end

	function Details.parser_functions:START_TIMER(...) --~timer
		if (Details.debug) then
			Details:Msg("(debug) found a timer.")
		end

		local _, zoneType = GetInstanceInfo()

		--check if the player is inside an arena
		if (zoneType == "arena") then
			if (Details.debug) then
				Details:Msg("(debug) timer is an arena countdown.")
			end

			Details:StartArenaSegment(...)

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
			Details222.discardSegment = true
			Details:EndCombat()
		end

		Details.lastBattlegroundStartTime = GetTime()
		Details:StartCombat()

		if (Details.debug) then
			Details:Msg("(debug) a battleground has started.")
		end
	end

	--~load
	local TurnTheSpeakersOn = function()
		if (not Details.gump) then
			--failed to load the framework
			if (not Details.instance_load_failed) then
				Details:CreatePanicWarning()
			end
			Details.instance_load_failed.text:SetText("Framework for Details! isn't loaded.\nIf you just updated the addon, please reboot the game client.\nWe apologize for the inconvenience and thank you for your comprehension.")
			return
		end

		Details222.AutoRunCode.Code = {}

		Details.popup = _G.GameCooltip
		Details.in_group = IsInGroup() or IsInRaid()
		Details.temp_table1 = {}
		Details.encounter = {}
		Details.in_combat = false
		Details.combat_id = 0
		Details.opened_windows = 0
		Details.playername = UnitName("player")

		--player faction and enemy faction
		Details.faction = UnitFactionGroup("player")
		if (Details.faction == PLAYER_FACTION_GROUP[0]) then --player is horde
			Details.faction_against = PLAYER_FACTION_GROUP[1] --ally
			Details.faction_id = 0

		elseif (Details.faction == PLAYER_FACTION_GROUP[1]) then --player is alliance
			Details.faction_against = PLAYER_FACTION_GROUP[0] --horde
			Details.faction_id = 1
		end

		--this function applies the Details.default_profile to Details object, this isn't yet the player profile which will load later
		Details222.LoadSavedVariables.DefaultProfile()

		--load up data from savedvariables for the character
		Details222.LoadSavedVariables.CharacterData()

		--load up data from saved variables for the account (shared among all the players' characters; this is not the Blizzard account, lol).
		Details222.LoadSavedVariables.SharedData()

		--load data of the segments saved from latest game session
		Details222.LoadSavedVariables.CombatSegments()

		--load the profiles
		Details:LoadConfig()

		Details:UpdateParserGears()

		--load auto run code
		Details222.AutoRunCode.StartAutoRun()

		Details.isLoaded = true
	end

	function Details.IsLoaded()
		return Details.isLoaded
	end

	function Details.parser_functions:ADDON_LOADED(...)
		local addonName = select(1, ...)
		if (addonName == "Details") then
			TurnTheSpeakersOn()
		end
	end

	local playerLogin = CreateFrame("frame")
	playerLogin:RegisterEvent("PLAYER_LOGIN")
	playerLogin:SetScript("OnEvent", function()
		Details:StartMeUp()
	end)

	function Details.parser_functions:PET_BATTLE_OPENING_START(...)
		Details.pet_battle = true
		for index, instance in ipairs(Details.tabela_instancias) do
			if (instance.ativa) then
				if (Details.debug) then
					Details:Msg("(debug) hidding windows for Pet Battle.")
				end
				instance:SetWindowAlphaForCombat(true, true, 0)
			end
		end
	end

	function Details.parser_functions:PET_BATTLE_CLOSE(...)
		Details.pet_battle = false
		for index, instance in ipairs(Details.tabela_instancias) do
			if (instance.ativa) then
				if (Details.debug) then
					Details:Msg("(debug) Pet Battle finished, calling AdjustAlphaByContext().")
				end
				instance:AdjustAlphaByContext(true)
			end
		end
	end

	function Details.parser_functions:UNIT_NAME_UPDATE(...)
		Details:SchedulePetUpdate(5)
	end

	function Details.parser_functions:PLAYER_TARGET_CHANGED(...)
		Details:SendEvent("PLAYER_TARGET")
	end

	local parser_functions = Details.parser_functions

	function Details:OnEvent(event, ...)
		local func = parser_functions[event]
		if (func) then
			return func(nil, ...)
		end
	end

	Details.listener:SetScript("OnEvent", Details.OnEvent)

	---return the backup table with regular logs, error and backups /dumpt __details_backup._general_logs
	function Details222.SaveVariables.GetBackupLogs()
		---@type {_general_logs: table, _exit_error: table, _instance_backup: table}
		local backupTable = __details_backup
		if (not backupTable) then
			__details_backup = { --[[GLOBAL]]
				_general_logs = {},
				_exit_error = {},
				_instance_backup = {},
			}
			return __details_backup
		end

		backupTable._general_logs = backupTable._general_logs or {}
		backupTable._exit_error = backupTable._exit_error or {}
		backupTable._instance_backup = backupTable._instance_backup or {}

		return backupTable
	end

	function Details222.SaveVariables.LogEvent(...)
		local args = {...}
		local newArgs = {}
		for index, value in ipairs(args) do
			if (type(value) == "string" or type(value) == "number" or type(value) == "boolean") then
				newArgs[index] = tostring(value)
			end
		end

		local currentDate = Details222.Date.GetDateForLogs()
		local text = currentDate .. " | " .. table.concat(newArgs, ", ")

		local backupLogs = Details222.SaveVariables.GetBackupLogs()
		table.insert(backupLogs._general_logs, 1, text)
		table.remove(backupLogs._general_logs, 30)
	end

	--logout function ~save ~logout ~savedata
	---@type frame
	local databaseSaver = CreateFrame("frame")
	databaseSaver:RegisterEvent("PLAYER_LOGOUT")
	databaseSaver:SetScript("OnEvent", function(...)
		--maximum amount of exit errors to be logged, new error are always added to the top of the list (index 1)
		local exitErrorsMaxSize = 10

		--safe guard logs and user settings
		local backupLogs = Details222.SaveVariables.GetBackupLogs()

		---@type table
		local exitErrors = backupLogs._exit_error

		---@param text string the error to be logged
		local addToExitErrors = function(text)
			table.insert(exitErrors, 1, Details222.Date.GetDateForLogs() .. " | " .. text)
			table.remove(exitErrors, 11)
		end

		---@type string current step of the logout process, used to log which is the current step when an error happens
		local currentStep = ""

		--save the time played on this class, run protected
		local savePlayTimeClass, savePlayTimeErrorText = pcall(function() Details.SavePlayTimeOnClass() end)

		if (not savePlayTimeClass) then
			addToExitErrors("Saving Play Time: " .. savePlayTimeErrorText)
		end

		---@type table record a log of events that happened during the logout process
		_detalhes_global.exit_log = {}

		---@type table record errors that happened during the logout process
		_detalhes_global.exit_errors = _detalhes_global.exit_errors or {}

		currentStep = "Checking the framework integrity"

		if (not Details.gump) then
			--failed to load the framework
			tinsert(_detalhes_global.exit_log, "The framework wasn't in Details member 'gump'.")
			tinsert(_detalhes_global.exit_errors, 1, currentStep .. " | " .. Details222.Date.GetDateForLogs() .. " | " .. Details.GetVersionString() .. " | Framework wasn't loaded |")
			return
		end

		local logSaverError = function(errortext)
			local writeLog = function()
				_detalhes_global = _detalhes_global or {}
				tinsert(_detalhes_global.exit_errors, 1, currentStep .. " | " .. Details222.Date.GetDateForLogs() .. " | " .. Details.GetVersionString() .. " | " .. errortext .. " | " .. debugstack())
				tremove(_detalhes_global.exit_errors, exitErrorsMaxSize)
				addToExitErrors(currentStep .. " | " .. Details222.Date.GetDateForLogs() .. " | " .. Details.GetVersionString() .. " | " .. errortext .. " | " .. debugstack())
			end
			xpcall(writeLog, addToExitErrors)
		end

		Details.saver_error_func = logSaverError
		Details.logoff_saving_data = true

		--close breakdown window
		if (Details.CloseBreakdownWindow) then
			tinsert(_detalhes_global.exit_log, "1 - Closing Breakdown Window.")
			currentStep = "Closing Breakdown Window"
			xpcall(Details.CloseBreakdownWindow, logSaverError)
		end

		--do not save window pos
		if (Details.tabela_instancias) then
			local clearInstances = function()
				currentStep = "Dealing With Instances"
				tinsert(_detalhes_global.exit_log, "2 - Clearing user placed position from instance windows.")
				for id, instance in Details:ListInstances() do
					if (id) then
						tinsert(_detalhes_global.exit_log, "  - " .. id .. " has baseFrame: " .. (instance.baseframe and "yes" or "no") .. ".")
						if (instance.baseframe) then
							instance.baseframe:SetUserPlaced(false)
							instance.baseframe:SetDontSavePosition(true)
						end
					end
				end
			end
			xpcall(clearInstances, logSaverError)
		else
			tinsert(_detalhes_global.exit_errors, 1, "not _detalhes.tabela_instancias")
			tremove(_detalhes_global.exit_errors, exitErrorsMaxSize)
			addToExitErrors("not _detalhes.tabela_instancias | " .. Details.GetVersionString())
		end

		--if is in combat during the logout, stop the combat
		if (Details.in_combat and Details.tabela_vigente) then
			tinsert(_detalhes_global.exit_log, "3 - Leaving current combat.")
			currentStep = "Leaving Current Combat"
			xpcall(Details.SairDoCombate, logSaverError)
			Details.can_panic_mode = true
		end

		--switch back to default, settings changed by automation
		if (Details.CheckSwitchOnLogon and Details.tabela_instancias and Details.tabela_instancias[1] and getmetatable(Details.tabela_instancias[1])) then
			tinsert(_detalhes_global.exit_log, "4 - Reversing switches.")
			currentStep = "Check Switch on Logon"
			xpcall(Details.CheckSwitchOnLogon, logSaverError)
		end

		--user requested a wipe of the full configuration
		if (Details.wipe_full_config) then
			tinsert(_detalhes_global.exit_log, "5 - Is a full config wipe.")
			addToExitErrors("true: _detalhes.wipe_full_config | " .. Details.GetVersionString())
			_detalhes_global = nil
			_detalhes_database = nil
			return
		end

		--save the config
		tinsert(_detalhes_global.exit_log, "6 - Saving Config.")
		currentStep = "Saving Config"
		xpcall(Details.SaveConfig, logSaverError)

		tinsert(_detalhes_global.exit_log, "7 - Saving Profiles.")
		currentStep = "Saving Profile"
		xpcall(Details.SaveProfile, logSaverError)

		--save the nicktag cache
		tinsert(_detalhes_global.exit_log, "8 - Saving nicktag cache.")

		local saveNicktabCache = function()
			_detalhes_database.nick_tag_cache = Details.CopyTable(_detalhes_database.nick_tag_cache)
		end
		xpcall(saveNicktabCache, logSaverError)

		--save auto run code data
		tinsert(_detalhes_global.exit_log, "9 - Saving Auto Run Code.")
		local saveAutoRunCode = function()
			Details222.AutoRunCode.OnLogout()
		end
		xpcall(saveAutoRunCode, logSaverError)
	end) --end of saving data



	local eraNamedSpellsToID = {}

	-- ~parserstart ~startparser ~cleu ~parser
	function Details.OnParserEvent()
		local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()

		local func = token_list[token]
		if (func) then
			return func(nil, token, time, who_serial, who_name, who_flags, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12)
		end
	end

	local parserDebug = {}
	function Details.OnParserEventDebug()																											    --buffs: spellschool, auraType, amount, arg1, arg2, arg3
		local time, token, hidding, sourceSerial, sourceName, sourceFlags, who_flags2, targetSerial, targetName, targetFlags, target_flags2, spellId, spellName, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, unknown1, unknown2, unknown3, unknown4, unknown5 = CombatLogGetCurrentEventInfo()

		if (not parserDebug[token]) then
			parserDebug[token] = true
			print(token)
		end

		if ( spellId == 409632 ) then
			--print(who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellId, spellName, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, unknown1, unknown2, unknown3, unknown4, unknown5)
		elseif( spellId == 395160 )  then
			--print(who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellId, spellName, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, unknown1, unknown2, unknown3, unknown4, unknown5)
		end

		if (token == "SPELL_DAMAGE") then
			if (A13 ~= nil or unknown1 ~= nil or unknown2 ~= nil or unknown3 ~= nil or unknown4 ~= nil or unknown5) then
				--print(time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellId, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18)	
			end
			--print(time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellId, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18)

			if (spellName == "Fate Mirror") then
				--print(time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellId, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18)
			end
		end

		if (token == "SPELL_AURA_APPLIED") then
			--print(spellName)
		end

		--local func = token_list[token]
		--if (func) then
		--	return func(nil, token, time, who_serial, who_name, who_flags, target_serial, target_name, target_flags, target_flags2, spellId, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12)
		--end

		--[=[ getspellinfo
			["1"] = "Spatial Paradox", buff
			["3"] = 5199645,
			["4"] = 0,
			["5"] = 0,
			["6"] = 100,
			["7"] = 406789,
			["8"] = 5199645,

			["1"] = "Spatial Paradox", buff
			["3"] = 5199645,
			["4"] = 0,
			["5"] = 0,
			["6"] = 60,
			["7"] = 406732,
			["8"] = 5199645,

			["1"] = "Ebon Might", --spell cast start
			["3"] = 5061347,
			["4"] = 1473,
			["5"] = 0,
			["6"] = 0,
			["7"] = 395152,
			["8"] = 5061347,			
		--]=]

		if (sourceSerial == UnitGUID("player")) then
			GLOB = GLOB or {}
			--table.insert(GLOB, {time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellId, spellName, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18})
			--print(time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellId, spellName, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18)	
		end

		--two spells triggering _support
		--404908,"Fate Mirror"
		--395152,"Ebon Might"

		--SPELL_DAMAGE_SUPPORT on spellId 395152 spellname "Ebon Might", only seens to exists in the offline version of the combat log

		if (spellId == 395152) then --Ebon Might "cast start" and "buff applyed"
			--print(time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellId, spellName, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, unknown1, unknown2, unknown3, unknown4, unknown5)
		end

		if (spellName == "Ebon Might") then
			--6/30 14:19:19.299  SPELL_AURA_REMOVED,Player-5764-00018FF1,"Termøhead-Iridikron",0x518,0x0,Player-5764-0001977A,"Drgndeesnutz-Fyrakk",0x518,0x0,395152,"Ebon Might",0xc,BUFF
			local spellschool, auraType, amount = A3, A4, A5
			print(token, spellName, sourceName, targetName, spellschool, auraType, amount, A6, A7, A8, A9, A10)
		end

		if (token == "SPELL_CAST_START") then
			if (sourceSerial == UnitGUID("player")) then
			--print(token, spellName, spellId)
			end
		end

		--Prescience, Fate Mirror, Ebon Might, Breath of Eons, Shifting Sands

		--offline cleu:
		--6/30 14:25:28.988  SPELL_DAMAGE,Player-5764-0001609B,"Mikito-Fyrakk",0x518,0x0,Creature-0-5770-2444-8-198594-00009DF6EF,"Cleave Training Dummy",0x30a28,0x0,44425,"Arcane Barrage",0x40,0000000000000000,0000000000000000,0,0,0,0,0,0,-1,0,0,0,0.00,0.00,2112,0.0000,0,18252,18251,-1,64,0,0,0,nil,nil,nil
		--6/30 14:25:28.988  SPELL_DAMAGE_SUPPORT,Player-5764-0001609B,"Mikito-Fyrakk",0x518,0x0,Creature-0-5770-2444-8-198594-00009DF6EF,"Cleave Training Dummy",0x30a28,0x0,395152,"Ebon Might",0xc,0000000000000000,0000000000000000,0,0,0,0,0,0,-1,0,0,0,0.00,0.00,2112,0.0000,0,2572,2571,-1,64,0,0,0,nil,nil,nil,Player-5764-0001FACE
	end

	function Details.OnParserEventClassicEra()
		local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()

		local func = token_list[token]
		if (func) then
			if(eraNamedSpellsToID[token]) then
				A1 = A2
			end
			return func(nil, token, time, who_serial, who_name, who_flags, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12)
		end
	end

	if(isERA) then
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
		Details.parser_frame:SetScript("OnEvent", Details.OnParserEventClassicEra)
	else
		if (false and "I'm debugging something") then
			Details.parser_frame:SetScript("OnEvent", Details.OnParserEventDebug)
		else
			Details.parser_frame:SetScript("OnEvent", Details.OnParserEvent)
		end
	end

	function Details:UpdateParser()
		_tempo = Details._tempo
	end

	function Details:UpdatePetsOnParser()
		container_pets = Details.tabela_pets.pets
	end

	function Details:GetActorFromCache(value)
		return damage_cache[value] or damage_cache_pets[value] or damage_cache_petsOwners[value]
	end

	---return tables containing the cache of actors
	---@return table damageCache, table damageCachePets, table damageCachePetOwners, table healingCache
	function Details222.Cache.GetParserCacheTables()
		return damage_cache, damage_cache_pets, damage_cache_petsOwners, healing_cache
	end

	function Details:PrintParserCacheIndexes()
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
		print("group damage", #Details.cache_damage_group)
		print("group damage", #Details.cache_healing_group)
	end

	function Details:GetActorsOnDamageCache()
		return Details.cache_damage_group
	end

	function Details:GetActorsOnHealingCache()
		return Details.cache_healing_group
	end

	function Details:ClearParserCache() --~wipe
		Details:Destroy(damage_cache)
		Details:Destroy(damage_cache_pets)
		Details:Destroy(damage_cache_petsOwners)
		Details:Destroy(healing_cache)
		Details:Destroy(energy_cache)
		Details:Destroy(misc_cache)
		Details:Destroy(misc_cache_pets)
		Details:Destroy(misc_cache_petsOwners)
		Details:Destroy(npcid_cache)
		Details:Destroy(enemy_cast_cache)
		Details:Destroy(empower_cache)

		Details:Destroy(ignore_death_cache)

		Details:Destroy(reflection_damage)
		Details:Destroy(reflection_debuffs)
		Details:Destroy(reflection_events)
		Details:Destroy(reflection_auras)
		Details:Destroy(reflection_dispels)

		Details:Destroy(dk_pets_cache.army)
		Details:Destroy(dk_pets_cache.apoc)

		Details:Destroy(cacheAnything.paladin_vivaldi_blessings)
		Details:Destroy(cacheAnything.rampage_cast_amount)
		Details:Destroy(Details222.Roskash) --~roskash

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


		damage_cache = setmetatable({}, Details.weaktable)
		damage_cache_pets = setmetatable({}, Details.weaktable)
		damage_cache_petsOwners = setmetatable({}, Details.weaktable)

		healing_cache = setmetatable({}, Details.weaktable)

		energy_cache = setmetatable({}, Details.weaktable)

		misc_cache = setmetatable({}, Details.weaktable)
		misc_cache_pets = setmetatable({}, Details.weaktable)
		misc_cache_petsOwners = setmetatable({}, Details.weaktable)
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

	function Details:UptadeRaidMembersCache()
		Details:Destroy(raid_members_cache)
		Details:Destroy(tanks_members_cache)
		Details:Destroy(auto_regen_cache)
		Details:Destroy(bitfield_swap_cache)
		Details:Destroy(empower_cache)

		local groupRoster = Details.tabela_vigente.raid_roster

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

				if (auto_regen_power_specs[Details.cached_specs[unitGUID]]) then
					auto_regen_cache[unitName] = auto_regen_power_specs[Details.cached_specs[unitGUID]]
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

				if (auto_regen_power_specs[Details.cached_specs[unitGUID]]) then
					auto_regen_cache[unitName] = auto_regen_power_specs[Details.cached_specs[unitGUID]]
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

			if (auto_regen_power_specs[Details.cached_specs[playerGUID]]) then
				auto_regen_cache[playerName] = auto_regen_power_specs[Details.cached_specs[playerGUID]]
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
				local spec = detailsFramework.GetSpecialization()
				if (spec and spec ~= 0) then
					if (detailsFramework.GetSpecializationRole (spec) == "TANK") then
						tanks_members_cache[playerGUID] = true
					end
				end
			end

			if (auto_regen_power_specs[Details.cached_specs[playerGUID]]) then
				auto_regen_cache[playerName] = auto_regen_power_specs[Details.cached_specs[playerGUID]]
			end
		end

		local orderNames = {}
		for playerName in pairs(groupRoster) do
			orderNames[#orderNames+1] = playerName
		end
		table.sort(orderNames, function(name1, name2)
			return string.len(name1) > string.len(name2)
		end)
		Details.tabela_vigente.raid_roster_indexed = orderNames

		if (Details.iam_a_tank) then
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
	function Details:UpdateParserGears()
		--refresh combat tables
		_current_combat = Details.tabela_vigente

		--last events pointer
		last_events_cache = _current_combat.player_last_events
		_amount_of_last_events = Details.deadlog_events

		_use_shield_overheal = Details.parser_options.shield_overheal
		shield_spellid_cache = Details.shield_spellid_cache

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
		_in_combat = Details.in_combat

		Details:Destroy(ignored_npcids)

		--fill it with the default npcs ignored
		for npcId in pairs(Details.default_ignored_npcs) do
			ignored_npcids[npcId] = true
		end

		--fill it with the npcs the user ignored
		for npcId in pairs(Details.npcid_ignored) do
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

		if (Details.hooks["HOOK_COOLDOWN"].enabled) then
			_hook_cooldowns = true
		else
			_hook_cooldowns = false
		end

		if (Details.hooks["HOOK_DEATH"].enabled) then
			_hook_deaths = true
		else
			_hook_deaths = false
		end

		if (Details.hooks["HOOK_BATTLERESS"].enabled) then
			_hook_battleress = true
		else
			_hook_battleress = false
		end

		if (Details.hooks["HOOK_INTERRUPT"].enabled) then
			_hook_interrupt = true
		else
			_hook_interrupt = false
		end

		is_using_spellId_override = Details.override_spellids

		return Details:ClearParserCache()
	end

	function Details.DumpIgnoredNpcs()
		return ignored_npcids
	end



--serach key: ~api
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--details api functions

	--number of combat
	function  Details:GetCombatId()
		return Details.combat_id
	end

	---return true if in combat
	---@return boolean bIsInCombat
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
	function Details:GetActor(combatId, attribute, actorName)
		if (not combatId) then
			combatId = "current" --current combat
		end

		if (not attribute) then
			attribute = 1 --damage
		end

		if (not actorName) then
			actorName = Details.playername
		end

		if (combatId == 0 or combatId == "current") then
			local actor = Details.tabela_vigente(attribute, actorName)
			if (actor) then
				return actor
			else
				return nil
			end

		elseif (combatId == -1 or combatId == "overall") then
			local actor = Details.tabela_overall(attribute, actorName)
			if (actor) then
				return actor
			else
				return nil
			end

		elseif (type(combatId) == "number") then
			local segmentsTable = Details:GetCombatSegments()
			---@type combat
			local combatObject = segmentsTable[combatId]

			if (combatObject) then
				---@type actor
				local actorObject = combatObject(attribute, actorName)
				if (actorObject) then
					return actorObject
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


	function Details:GetUnitId(unitName)
		unitName = unitName or self.nome
		local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
		if (openRaidLib) then
			local unitId = openRaidLib.GetUnitID(unitName)
			if (unitId) then
				return unitId
			end
		end

		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				local unitId = "raid" .. i
				if (GetUnitName(unitId, true) == unitName) then
					return unitId
				end
			end

		elseif (IsInGroup()) then
			for i = 1, GetNumGroupMembers() -1 do
				local unitId = "party" .. i
				if (GetUnitName(unitId, true) == unitName) then
					return unitId
				end
			end
			if (UnitName("player") == unitName) then
				return "player"
			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--battleground parser

	Details.pvp_parser_frame:SetScript("OnEvent", function(self, event)
		self:ReadPvPData()
	end)

	function Details:BgScoreUpdate()
		RequestBattlefieldScoreData()
	end

	--start the virtual parser
	function Details.pvp_parser_frame:StartBgUpdater()
		Details.pvp_parser_frame:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

		if (Details.pvp_parser_frame.ticker) then
			Details.Schedules.Cancel(Details.pvp_parser_frame.ticker)
		end

		Details.pvp_parser_frame.ticker = Details.Schedules.NewTicker(10, Details.BgScoreUpdate)
		Details.Schedules.SetName(Details.pvp_parser_frame.ticker, "Battleground Updater")
	end

	--stop the virtual parser
	function Details.pvp_parser_frame:StopBgUpdater()
		Details.pvp_parser_frame:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
		Details.Schedules.Cancel(Details.pvp_parser_frame.ticker)
		Details.pvp_parser_frame.ticker = nil
	end

	function Details.pvp_parser_frame:ReadPvPData()
		local players = GetNumBattlefieldScores()

		for i = 1, players do
			local name, killingBlows, honorableKills, deaths, honorGained, faction, race, rank, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec
			if (isWOTLK) then
				name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i)
			else
				name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i)
			end

			--damage done
			local actor = Details.tabela_vigente(1, name)
			if (actor) then
				if (damageDone == 0) then
					damageDone = damageDone + Details:GetOrderNumber()
				end
				actor.total = damageDone
				actor.classe = classToken or "UNKNOW"

			elseif (name ~= "Unknown" and type(name) == "string" and string.len(name) > 1) then
				local guid = UnitGUID(name)
				if (guid) then
					local flag
					if (Details.faction_id == faction) then --is from the same faction
						flag = 0x514
					else
						flag = 0x548
					end

					actor = _current_damage_container:PegarCombatente (guid, name, flag, true)
					actor.total = Details:GetOrderNumber()
					actor.classe = classToken or "UNKNOW"

					if (flag == 0x548) then
						--oponent
						actor.enemy = true
					end
				end
			end

			--healing done
			local actor = Details.tabela_vigente(2, name)
			if (actor) then
				if (healingDone == 0) then
					healingDone = healingDone + Details:GetOrderNumber()
				end
				actor.total = healingDone
				actor.classe = classToken or "UNKNOW"

			elseif (name ~= "Unknown" and type(name) == "string" and string.len(name) > 1) then
				local guid = UnitGUID(name)
				if (guid) then
					local flag
					if (Details.faction_id == faction) then --is from the same faction
						flag = 0x514
					else
						flag = 0x548
					end

					actor = _current_heal_container:PegarCombatente (guid, name, flag, true)
					actor.total = Details:GetOrderNumber()
					actor.classe = classToken or "UNKNOW"

					if (flag == 0x548) then
						--oponent
						actor.enemy = true
					end
				end
			end
		end
	end
