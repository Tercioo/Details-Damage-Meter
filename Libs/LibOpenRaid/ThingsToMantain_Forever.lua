
do
	local versionString, revision, launchDate, gameVersion = GetBuildInfo()
	if (gameVersion >= 20000 or gameVersion < 16001) then
		return
	end

	if (not LIB_OPEN_RAID_CAN_LOAD) then
		return
	end

    local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

	local loadLibDatabase = function()
        --localization
        local gameLanguage = GetLocale()

        local L = {} --default localization

		if (gameLanguage == "enUS") then
			--default language
		elseif (gameLanguage == "deDE") then
		elseif (gameLanguage == "esES") then
		elseif (gameLanguage == "esMX") then
		elseif (gameLanguage == "frFR") then
		elseif (gameLanguage == "itIT") then
		elseif (gameLanguage == "koKR") then
		elseif (gameLanguage == "ptBR") then
		elseif (gameLanguage == "ruRU") then
		elseif (gameLanguage == "zhCN") then
		elseif (gameLanguage == "zhTW") then
		end

        LIB_OPEN_RAID_FOOD_BUFF = {} --default
		LIB_OPEN_RAID_FLASK_BUFF = {} --default

		LIB_OPEN_RAID_BLOODLUST = {}

		LIB_OPEN_RAID_MYTHICKEYSTONE_ITEMID = 180653
		LIB_OPEN_RAID_AUGMENTATED_RUNE = 0

		LIB_OPEN_RAID_COVENANT_ICONS = {}

        --which gear slots can be enchanted on the latest retail version of the game
		--when the value is a number, the slot only receives enchants for a specific attribute
        -- TODO: Confirm
		LIB_OPEN_RAID_ENCHANT_SLOTS = {}

		-- how to get the enchantId:
		-- local itemLink = GetInventoryItemLink("player", slotId)
		-- local enchandId = select(3, strsplit(":", itemLink))
		-- print("enchantId:", enchandId)
		LIB_OPEN_RAID_ENCHANT_IDS = {}

		LIB_OPEN_RAID_DEATHKNIGHT_RUNEFORGING_ENCHANT_IDS = {}

		--how to get the gemId:
		--local itemLink = GetInventoryItemLink("player", slotId)
		--local gemId = select(4, strsplit(":", itemLink))
		--print("gemId:", gemId)
		LIB_OPEN_RAID_GEM_IDS = {}

		--/dump GetWeaponEnchantInfo()
		LIB_OPEN_RAID_WEAPON_ENCHANT_IDS = {}

		--buff spellId, the value of the food is the tier level
		--use /details auras
        -- TODO: Update for war within
		LIB_OPEN_RAID_FOOD_BUFF = {}

		--buff spell ids
		--use /details auras
		LIB_OPEN_RAID_FLASK_BUFF = {}

        --on use spell ids
		LIB_OPEN_RAID_ALL_POTIONS = {}

		--spellId of healing from potions
		LIB_OPEN_RAID_HEALING_POTIONS = {}

		LIB_OPEN_RAID_MANA_POTIONS = {}

		--end of per expansion content
		--------------------------------------------------------------------------------------------

        -- TODO: Confirm for war within
		LIB_OPEN_RAID_MELEE_SPECS = {
			[103] = "DRUID",
			--[255] = "Survival", --not in the list due to the long interrupt time
			[70] = "PALADIN",
			[259] = "ROGUE",
			[260] = "ROGUE",
			[261] = "ROGUE",
			[263] = "SHAMAN",
			[71] = "WARRIOR",
			[72] = "WARRIOR",
		}

		--tells the duration, requirements and cooldown
		--information about a cooldown is mainly get from tooltips
		--if talent is required, use the command:
		--/dump GetTalentInfo (talentTier, talentColumn, 1)
		--example: to get the second talent of the last talent line, use: /dump GetTalentInfo (7, 2, 1)

		--todo:
		--get cooldown duration from the buff placed on the player or target player
		--spell scanner not getting the spell from the pet spellbook

        -- TODO: Update for war within
		LIB_OPEN_RAID_COOLDOWNS_INFO = {}

		C_Timer.After(0, function()
			for spellId in pairs(LIB_OPEN_RAID_COOLDOWNS_INFO) do
				local spellInfo = C_Spell.GetSpellInfo(spellId)
				if (not spellInfo) then
					LIB_OPEN_RAID_COOLDOWNS_INFO[spellId] = nil
					--print("OpenRaid: Spell " .. spellId .. " not found in spellbook")
				end
			end
		end)

		local ccSpellNameCache = {}
		function openRaidLib.GetCCSpellIdBySpellName(spellName)
			if (ccSpellNameCache[spellName]) then
				return ccSpellNameCache[spellName]
			end

			for spellId in pairs(LIB_OPEN_RAID_CROWDCONTROL) do
				local spellInfo = C_Spell.GetSpellInfo(spellId)
				if (spellInfo) then
					if (spellInfo.name == spellName) then
						ccSpellNameCache[spellName] = spellId
						return spellId
					end
				end
			end

			return nil
		end

		--list of all crowd control spells
		--it is not transmitted to other clients
        -- TODO: Update for war within
		LIB_OPEN_RAID_CROWDCONTROL = {
			[339] = {cooldown = 0,		class = "DRUID"}, --Entangling Roots
			[102359] = {cooldown = 30,	class = "DRUID"}, --Mass Entanglement
			[93985] = {cooldown = 0,	class = "DRUID"}, --Skull Bash
			[2637] = {cooldown = 0,		class = "DRUID"}, --Hibernate
			[5211] = {cooldown = 60,	class = "DRUID"}, --Mighty Bash
			[99] = {cooldown = 30,		class = "DRUID"}, --Incapacitating Roar
			[127797] = {cooldown = 0,	class = "DRUID"}, --Ursol's Vortex
			[203123] = {cooldown = 0,	class = "DRUID"}, --Maim
			[45334] = {cooldown = 0,	class = "DRUID"}, --Immobilized
			[33786] = {cooldown = 0,	class = "DRUID"}, --Cyclone
			[236748] = {cooldown = 30,	class = "DRUID"}, --Intimidating Roar
			[61391] = {cooldown = 0,	class = "DRUID"}, --Typhoon
			[163505] = {cooldown = 0,	class = "DRUID"}, --Rake
			[50259] = {cooldown = 0,	class = "DRUID"}, --Dazed
			[162480] = {cooldown = 0,	class = "HUNTER"}, --Steel Trap
			[187707] = {cooldown = 15,	class = "HUNTER"}, --Muzzle
			[147362] = {cooldown = 24,	class = "HUNTER"}, --Counter Shot
			[190927] = {cooldown = 6,	class = "HUNTER"}, --Harpoon
			[117526] = {cooldown = 45,	class = "HUNTER"}, --Binding Shot
			[24394] = {cooldown = 0,	class = "HUNTER"}, --Intimidation
			[117405] = {cooldown = 0,	class = "HUNTER"}, --Binding Shot
			[19577] = {cooldown = 60,	class = "HUNTER"}, --Intimidation
			[1513] = {cooldown = 0,		class = "HUNTER"}, --Scare Beast
			[3355] = {cooldown = 30,	class = "HUNTER"}, --Freezing Trap
			[203337] = {cooldown = 30,	class = "HUNTER"}, --Freezing trap with diamond ice talent
			[31661] = {cooldown = 45,	class = "MAGE"}, --Dragon's Breath
			[161353] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[277787] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[157981] = {cooldown = 30,	class = "MAGE"}, --Blast Wave
			[82691] = {cooldown = 0,	class = "MAGE"}, --Ring of Frost
			[118] = {cooldown = 0,		class = "MAGE"}, --Polymorph
			[161354] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[157997] = {cooldown = 25,	class = "MAGE"}, --Ice Nova
			[391622] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[28271] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[122] = {cooldown = 0,		class = "MAGE"}, --Frost Nova
			[277792] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[61721] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[126819] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[61305] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[28272] = {cooldown = 0,	class = "MAGE"}, --Polymorph
			[2139] = {cooldown = 24,	class = "MAGE"}, --Counterspell
			[31935] = {cooldown = 15,	class = "PALADIN"}, --Avenger's Shield
			[20066] = {cooldown = 15,	class = "PALADIN"}, --Repentance
			[217824] = {cooldown = 0,	class = "PALADIN"}, --Shield of Virtue
			[105421] = {cooldown = 0,	class = "PALADIN"}, --Blinding Light
			[10326] = {cooldown = 15,	class = "PALADIN"}, --Turn Evil
			[853] = {cooldown = 60,		class = "PALADIN"}, --Hammer of Justice
			[96231] = {cooldown = 15,	class = "PALADIN"}, --Rebuke
			[205364] = {cooldown = 30,	class = "PRIEST"}, --Dominate Mind
			[64044] = {cooldown = 45,	class = "PRIEST"}, --Psychic Horror
			[226943] = {cooldown = 0,	class = "PRIEST"}, --Mind Bomb
			[15487] = {cooldown = 45,	class = "PRIEST"}, --Silence
			[605] = {cooldown = 0,		class = "PRIEST"}, --Mind Control
			[8122] = {cooldown = 45,	class = "PRIEST"}, --Psychic Scream
			[200200] = {cooldown = 60,	class = "PRIEST"}, --Holy Word: Chastise
			[9484] = {cooldown = 0,		class = "PRIEST"}, --Shackle Undead
			[200196] = {cooldown = 60,	class = "PRIEST"}, --Holy Word: Chastise
			[6770] = {cooldown = 0,		class = "ROGUE"}, --Sap
			[2094] = {cooldown = 120,	class = "ROGUE"}, --Blind
			[1766] = {cooldown = 15,	class = "ROGUE"}, --Kick
			[427773] = {cooldown = 0,	class = "ROGUE"}, --Blind
			[408] = {cooldown = 20,		class = "ROGUE"}, --Kidney Shot
			[1776] = {cooldown = 20,	class = "ROGUE"}, --Gouge
			[1833] = {cooldown = 0,		class = "ROGUE"}, --Cheap Shot
			[211015] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[269352] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[277778] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[64695] = {cooldown = 0,	class = "SHAMAN"}, --Earthgrab
			[57994] = {cooldown = 12,	class = "SHAMAN"}, --Wind Shear
			[197214] = {cooldown = 40,	class = "SHAMAN"}, --Sundering
			[118905] = {cooldown = 0,	class = "SHAMAN"}, --Static Charge
			[277784] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[309328] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[211010] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[210873] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[211004] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[51514] = {cooldown = 30,	class = "SHAMAN"}, --Hex
			[305485] = {cooldown = 30,	class = "SHAMAN"}, --Lightning Lasso
			[89766] = {cooldown = 30,	class = "WARLOCK"}, --Axe Toss (pet felguard ability)
			[6789] = {cooldown = 45,	class = "WARLOCK"}, --Mortal Coil
			[118699] = {cooldown = 0,	class = "WARLOCK"}, --Fear
			[710] = {cooldown = 0,		class = "WARLOCK"}, --Banish
			[212619] = {cooldown = 60,	class = "WARLOCK"}, --Call Felhunter
			[19647] = {cooldown = 24,	class = "WARLOCK"}, --Spell Lock
			[30283] = {cooldown = 60,	class = "WARLOCK"}, --Shadowfury
			[5484] = {cooldown = 40,	class = "WARLOCK"}, --Howl of Terror
			[6552] = {cooldown = 15,	class = "WARRIOR"}, --Pummel
			[132168] = {cooldown = 0,	class = "WARRIOR"}, --Shockwave
			[132169] = {cooldown = 0,	class = "WARRIOR"}, --Storm Bolt
			[5246] = {cooldown = 90,	class = "WARRIOR"}, --Intimidating Shout
		}

		--this table store all cooldowns the player currently have available
		LIB_OPEN_RAID_PLAYERCOOLDOWNS = {}

		LIB_OPEN_RAID_COOLDOWNS_BY_SPEC = {}

		--spells or items with a shared cooldown
		--the list is build in the loop below
		--format: table[sharedID] = { [spellID] = type, [spellID] = type, [spellID] = type, ... }
		LIB_OPEN_RAID_COOLDOWNS_SHARED_ID = {}

		for spellID, spellData in pairs(LIB_OPEN_RAID_COOLDOWNS_INFO) do
			for _, specID in ipairs(spellData.specs) do
				LIB_OPEN_RAID_COOLDOWNS_BY_SPEC[specID] = LIB_OPEN_RAID_COOLDOWNS_BY_SPEC[specID] or {}
				LIB_OPEN_RAID_COOLDOWNS_BY_SPEC[specID][spellID] = spellData.type
			end

			if (spellData.shareid) then
				local id = spellData.shareid
				LIB_OPEN_RAID_COOLDOWNS_SHARED_ID[id] = LIB_OPEN_RAID_COOLDOWNS_SHARED_ID[id] or {}
				LIB_OPEN_RAID_COOLDOWNS_SHARED_ID[id][spellID] = spellData.type
			end

			if (spellData.type == 8) then --crowd control
				if (not LIB_OPEN_RAID_CROWDCONTROL[spellID]) then
					local ccTable = {cooldown = spellData.cooldown, class = spellData.class}
					LIB_OPEN_RAID_CROWDCONTROL[spellID] = ccTable
				end
			end
		end


		--[=[
		Spell customizations:
			Many times there's spells with the same name which does different effects
			In here you find a list of spells which has its name changed to give more information to the player
			you may add into the list any other parameter your addon uses declaring for example 'icon = ' or 'texcoord = ' etc.

		Implamentation Example:
			if (LIB_OPEN_RAID_SPELL_CUSTOM_NAMES) then
				for spellId, customTable in pairs(LIB_OPEN_RAID_SPELL_CUSTOM_NAMES) do
					local name = customTable.name
					if (name) then
						MyCustomSpellTable[spellId] = name
					end
				end
			end
		--]=]

		LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {} --default fallback

		if (GetBuildInfo():match ("%d") == "1") then
				LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

		elseif (GetBuildInfo():match ("%d") == "2") then
			LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

		elseif (GetBuildInfo():match ("%d") == "3") then
			LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

		else
			LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}
		end

		--interrupt list using proxy from cooldown list
		--this list should be expansion and combatlog safe
		LIB_OPEN_RAID_SPELL_INTERRUPT = {}

		--iterate on all cooldown spells, check for type == 6 (interrupt) and if the list above doesn't have it, add
		for spellID, spellData in pairs(LIB_OPEN_RAID_COOLDOWNS_INFO) do
			if (spellData.type == 6 and not LIB_OPEN_RAID_SPELL_INTERRUPT[spellID]) then
				LIB_OPEN_RAID_SPELL_INTERRUPT[spellID] = spellData
			end
		end

		--all interrupts a class can have, not separated by spec
		LIB_OPEN_RAID_SPELL_INTERRUPT_BYCLASS = {}
		for spellID, spellData in pairs(LIB_OPEN_RAID_SPELL_INTERRUPT) do
			local class = spellData.class
			if (class) then
				LIB_OPEN_RAID_SPELL_INTERRUPT_BYCLASS[class] = LIB_OPEN_RAID_SPELL_INTERRUPT_BYCLASS[class] or {}
				LIB_OPEN_RAID_SPELL_INTERRUPT_BYCLASS[class][spellID] = spellData
				local spellInfo = C_Spell.GetSpellInfo(spellID)
				if (spellInfo and spellInfo.name and spellInfo.name ~= UNKNOWN) then
					LIB_OPEN_RAID_SPELL_INTERRUPT_BYCLASS[class][spellInfo.name] = spellData
				end
			end
		end

		--override list of spells with more than one effect, example: multiple types of polymorph
		LIB_OPEN_RAID_SPELL_DEFAULT_IDS = {}
		LIB_OPEN_RAID_MULTI_OVERRIDE_SPELLS = {}

		LIB_OPEN_RAID_SPECID_TO_CLASSID = {
			[71] = 1,
			[72] = 1,
			[73] = 1,

			[62] = 8,
			[63] = 8,
			[64] = 8,

			[259] = 4,
			[260] = 4,
			[261] = 4,

			[102] = 11,
			[103] = 11,
			[104] = 11,
			[105] = 11,

			[253] = 3,
			[254] = 3,
			[255] = 3,

			[262] = 7,
			[263] = 7,
			[264] = 7,

			[256] = 5,
			[257] = 5,
			[258] = 5,

			[265] = 9,
			[266] = 9,
			[267] = 9,

			[65] = 2,
			[66] = 2,
			[70] = 2,
		}

		LIB_OPEN_RAID_NPCID_TO_DISPLAYID = {}

		--overwrite values in this table only after PEW event.
		--tickInterval: amount of seconds between each tick, default: 3. lower this to increase precision on when the cooldown ended.
		LIB_OPEN_RAID_COOLDOWNS_CONFIG = {}

		LIB_OPEN_RAID_MYTHIC_PLUS_CURRENT_SEASON = {}

		---@alias teleporter_spellid number
		---@type table<teleporter_spellid, number|boolean>
		LIB_OPEN_RAID_MYTHIC_PLUS_TELEPORT_SPELLS = {}

		--zoneName, challengeMapId, timeLimit, texture, textureBackground, mapId, teleportSpellId
		--keys are challengeMapId
		LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO = {}



		LIB_OPEN_RAID_DATABASE_LOADED = true
    end

    --this will make sure to always have the latest data
	C_Timer.After(0, function()
		if (openRaidLib.__version == LIB_OPEN_RAID_MAX_VERSION) then
			loadLibDatabase()
		end
	end)
	loadLibDatabase()
end
