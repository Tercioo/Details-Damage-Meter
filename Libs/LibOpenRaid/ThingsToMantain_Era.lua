local versionString, revision, launchDate, gameVersion = GetBuildInfo()
if (gameVersion >= 20000) then
    return
end

--localization
local gameLanguage = GetLocale()

local L = { --default localization
	["STRING_EXPLOSION"] = "explosion",
	["STRING_MIRROR_IMAGE"] = "Mirror Image",
	["STRING_CRITICAL_ONLY"]  = "critical",
	["STRING_BLOOM"] = "Bloom", --lifebloom 'bloom' healing
	["STRING_GLAIVE"] = "Glaive", --DH glaive toss
	["STRING_MAINTARGET"] = "Main Target",
	["STRING_AOE"] = "AoE", --multi targets
	["STRING_SHADOW"] = "Shadow", --the spell school 'shadow'
	["STRING_PHYSICAL"] = "Physical", --the spell school 'physical'
	["STRING_PASSIVE"] = "Passive", --passive spell
	["STRING_TEMPLAR_VINDCATION"] = "Templar's Vindication", --paladin spell
	["STRING_PROC"] = "proc", --spell proc
	["STRING_TRINKET"] = "Trinket", --trinket
}

if (gameLanguage == "enUS") then
	--default language

elseif (gameLanguage == "deDE") then
	L["STRING_EXPLOSION"] = "Explosion"
	L["STRING_MIRROR_IMAGE"] = "Bilder spiegeln"
	L["STRING_CRITICAL_ONLY"]  = "kritisch"

elseif (gameLanguage == "esES") then
	L["STRING_EXPLOSION"] = "explosión"
	L["STRING_MIRROR_IMAGE"] = "Imagen de espejo"
	L["STRING_CRITICAL_ONLY"]  = "crítico"

elseif (gameLanguage == "esMX") then
	L["STRING_EXPLOSION"] = "explosión"
	L["STRING_MIRROR_IMAGE"] = "Imagen de espejo"
	L["STRING_CRITICAL_ONLY"]  = "crítico"

elseif (gameLanguage == "frFR") then
	L["STRING_EXPLOSION"] = "explosion"
	L["STRING_MIRROR_IMAGE"] = "Effet miroir"
	L["STRING_CRITICAL_ONLY"]  = "critique"

elseif (gameLanguage == "itIT") then
	L["STRING_EXPLOSION"] = "esplosione"
	L["STRING_MIRROR_IMAGE"] = "Immagine Speculare"
	L["STRING_CRITICAL_ONLY"]  = "critico"

elseif (gameLanguage == "koKR") then
	L["STRING_EXPLOSION"] = "폭발"
	L["STRING_MIRROR_IMAGE"] = "미러 이미지"
	L["STRING_CRITICAL_ONLY"]  = "치명타"

elseif (gameLanguage == "ptBR") then
	L["STRING_EXPLOSION"] = "explosão"
	L["STRING_MIRROR_IMAGE"] = "Imagem Espelhada"
	L["STRING_CRITICAL_ONLY"]  = "critico"

elseif (gameLanguage == "ruRU") then
	L["STRING_EXPLOSION"] = "взрыв"
	L["STRING_MIRROR_IMAGE"] = "Зеркальное изображение"
	L["STRING_CRITICAL_ONLY"]  = "критический"

elseif (gameLanguage == "zhCN") then
	L["STRING_EXPLOSION"] = "爆炸"
	L["STRING_MIRROR_IMAGE"] = "镜像"
	L["STRING_CRITICAL_ONLY"]  = "爆击"

elseif (gameLanguage == "zhTW") then
	L["STRING_EXPLOSION"] = "爆炸"
	L["STRING_MIRROR_IMAGE"] = "鏡像"
	L["STRING_CRITICAL_ONLY"]  = "致命"
end

LIB_OPEN_RAID_MANA_POTIONS = {}

LIB_OPEN_RAID_FOOD_BUFF = {} --default
LIB_OPEN_RAID_FLASK_BUFF = {} --default

LIB_OPEN_RAID_BLOODLUST = {
}

--which gear slots can be enchanted on the latest retail version of the game
--when the value is a number, the slot only receives enchants for a specific attribute
LIB_OPEN_RAID_ENCHANT_SLOTS = {
}

LIB_OPEN_RAID_MYTHICKEYSTONE_ITEMID = 180653
LIB_OPEN_RAID_AUGMENTATED_RUNE = 0

LIB_OPEN_RAID_COVENANT_ICONS = {}

LIB_OPEN_RAID_ENCHANT_IDS = {}

LIB_OPEN_RAID_GEM_IDS = {}

LIB_OPEN_RAID_WEAPON_ENCHANT_IDS = {}

LIB_OPEN_RAID_FOOD_BUFF = {}

LIB_OPEN_RAID_FLASK_BUFF = {}

LIB_OPEN_RAID_ALL_POTIONS = {}

LIB_OPEN_RAID_HEALING_POTIONS = {
}

LIB_OPEN_RAID_MELEE_SPECS = {
	[251] = "DEATHKNIGHT",
	[252] = "DEATHKNIGHT",
	[577] = "DEMONHUNTER",
	[103] = "DRUID",
	--[255] = "Survival", --not in the list due to the long interrupt time
	[269] = "MONK",
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

LIB_OPEN_RAID_COOLDOWNS_INFO = {

}

LIB_OPEN_RAID_COOLDOWNS_BY_SPEC = {};
for spellID,spellData in pairs(LIB_OPEN_RAID_COOLDOWNS_INFO) do
	for _,specID in ipairs(spellData.specs) do
		LIB_OPEN_RAID_COOLDOWNS_BY_SPEC[specID] = LIB_OPEN_RAID_COOLDOWNS_BY_SPEC[specID] or {};
		LIB_OPEN_RAID_COOLDOWNS_BY_SPEC[specID][spellID] = spellData.type;
	end
end

-- DF Evoker
LIB_OPEN_RAID_COOLDOWNS_BY_SPEC[1467] = {};
LIB_OPEN_RAID_COOLDOWNS_BY_SPEC[1468] = {};

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

--list of all crowd control spells
--it is not transmitted to other clients
LIB_OPEN_RAID_CROWDCONTROL = { --copied from retail
	[331866] = {cooldown = 0,	class = "COVENANT|VENTHYR"}, --Agent of Chaos
	[334693] = {cooldown = 0,	class = "DEAHTKNIGHT"}, --Absolute Zero
	[221562] = {cooldown = 45,	class = "DEATHKNIGHT"}, --Asphyxiate
	[47528] = {cooldown = 15,	class = "DEATHKNIGHT"}, --Mind Freeze
	[207167] = {cooldown = 60,	class = "DEATHKNIGHT"}, --Blinding Sleet
	[91807] = {cooldown = 0,	class = "DEATHKNIGHT"}, --Shambling Rush
	[108194] = {cooldown = 45,	class = "DEATHKNIGHT"}, --Asphyxiate
	[211881] = {cooldown = 30,	class = "DEMONHUNTER"}, --Fel Eruption
	[200166] = {cooldown = 0,	class = "DEMONHUNTER"}, --Metamorphosis
	[217832] = {cooldown = 45,	class = "DEMONHUNTER"}, --Imprison
	[183752] = {cooldown = 15,	class = "DEMONHUNTER"}, --Disrupt
	[207685] = {cooldown = 0,	class = "DEMONHUNTER"}, --Sigil of Misery
	[179057] = {cooldown = 45,	class = "DEMONHUNTER"}, --Chaos Nova
	[221527] = {cooldown = 45,	class = "DEMONHUNTER"}, --Imprison with detainment talent
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
	[372245] = {cooldown = 0,	class = "EVOKER"}, --Terror of the Skies
	[360806] = {cooldown = 15,	class = "EVOKER"}, --Sleep Walk
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
	[198909] = {cooldown = 0,	class = "MONK"}, --Song of Chi-Ji
	[119381] = {cooldown = 60,	class = "MONK"}, --Leg Sweep
	[107079] = {cooldown = 120,	class = "MONK"}, --Quaking Palm
	[116706] = {cooldown = 0,	class = "MONK"}, --Disable
	[115078] = {cooldown = 45,	class = "MONK"}, --Paralysis
	[116705] = {cooldown = 15,	class = "MONK"}, --Spear Hand Strike
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

LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {} --default fallback

if (GetBuildInfo():match ("%d") == "1") then
		LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

elseif (GetBuildInfo():match ("%d") == "2") then
	LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

elseif (GetBuildInfo():match ("%d") == "3") then
	LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

else
	LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {
		
	}
end

--interrupt list using proxy from cooldown list
--this list should be expansion and combatlog safe
LIB_OPEN_RAID_SPELL_INTERRUPT = {
}

--override list of spells with more than one effect, example: multiple types of polymorph
LIB_OPEN_RAID_SPELL_DEFAULT_IDS = {

}

LIB_OPEN_RAID_DATABASE_LOADED = true
