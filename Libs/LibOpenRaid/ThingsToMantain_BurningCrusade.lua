

--data for the burning crusade expansion

local versionString, revision, launchDate, gameVersion = GetBuildInfo()
if (gameVersion >= 30000 or gameVersion < 20000) then
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
	[2825] = true, --bloodlust
	[32182] = true, --heroism
	[80353] = true, --timewarp
	[90355] = true, --ancient hysteria
	[309658] = true, --current exp drums
}

--which gear slots can be enchanted on the latest retail version of the game
--when the value is a number, the slot only receives enchants for a specific attribute
LIB_OPEN_RAID_ENCHANT_SLOTS = {
	--[INVSLOT_NECK] = true,
	[INVSLOT_BACK] = true, --for all
	[INVSLOT_CHEST] = true, --for all
	[INVSLOT_FINGER1] = true, --for all
	[INVSLOT_FINGER2] = true, --for all
	[INVSLOT_MAINHAND] = true, --for all

	[INVSLOT_FEET] = 2, --agility only
	[INVSLOT_WRIST] = 1, --intellect only
	[INVSLOT_HAND] = 3, --strenth only
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
	[33447] = true, --Runic Healing Potion
	[41166] = true, --Runic Healing Injector
	[47875] = true, --Warlock's Healthstone (0/2 Talent)
	[47867] = true, --Warlock's Healthstone (1/2 Talent)
	[47877] = true, --Warlock's Healthstone (2/2 Talent)
}

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

LIB_OPEN_RAID_COOLDOWNS_INFO = {

	-- Filter Types:
	-- 1 attack cooldown
	-- 2 personal defensive cooldown
	-- 3 targetted defensive cooldown
	-- 4 raid defensive cooldown
	-- 5 personal utility cooldown
	-- 6 interrupt

	--interrupts
	[6552] = {class = "WARRIOR", specs = {71, 72, 73}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Pummel
	[2139] = {class = "MAGE", specs = {62, 63, 64}, cooldown = 24, silence = 6, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Counterspell
	[15487] = {class = "PRIEST", specs = {258}, cooldown = 45, silence = 4, talent = false, cooldownWithTalent = 30, cooldownTalentId = 23137, type = 6, charges = 1}, --Silence (shadow) Last Word Talent to reduce cooldown in 15 seconds
	[1766] = {class = "ROGUE", specs = {259, 260, 261}, cooldown = 15, silence = 5, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Kick
	[16979] = {class = "DRUID", specs = {103, 104}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Feral Charge
	[5211] = {class = "DRUID", specs = {103, 104}, cooldown = 60, silence = 2, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Mighty Bash
	[8042] = {class = "SHAMAN", specs = {262, 263, 264}, cooldown = 8, silence = 2, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Earth Shock
	[28730] = {class = "RACIAL", specs = {0}, cooldown = 120, silence = 2, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Arcane Torrent (Blood Elf)
	[19647] = {class = "WARLOCK", specs = {265, 266, 267}, cooldown = 24, silence = 6, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Spell Lock (Felhunter)

	--paladin
	-- 65 - Holy
	-- 66 - Protection
	-- 70 - Retribution

	[31884] = 	{cooldown = 120, 	duration = 20, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 1}, --Avenging Wrath
	[216331] = 	{cooldown = 120, 	duration = 20, 		specs = {65}, 			talent =22190, charges = 1, class = "PALADIN", type = 1}, --Avenging Crusader (talent)
	[498] = 	{cooldown = 60, 	duration = 8, 		specs = {65}, 			talent =false, charges = 1, class = "PALADIN", type = 2}, --Divine Protection
	[642] = 	{cooldown = 300, 	duration = 8, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 2}, --Divine Shield
	[105809] = 	{cooldown = 90, 	duration = 20, 		specs = {65,66,70}, 	talent =22164, charges = 1, class = "PALADIN", type = 2}, --Holy Avenger (talent)
	[152262] = 	{cooldown = 45, 	duration = 15, 		specs = {65,66,70},		talent =17601, charges = 1, class = "PALADIN", type = 2}, --Seraphim
	[633] = 	{cooldown = 600, 	duration = false, 	specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 3}, --Lay on Hands
	[1022] = 	{cooldown = 300, 	duration = 10, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 3}, --Blessing of Protection
	[6940] = 	{cooldown = 120, 	duration = 12, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 3}, --Blessing of Sacrifice
	[31821] = 	{cooldown = 180, 	duration = 8, 		specs = {65},		 	talent =false, charges = 1, class = "PALADIN", type = 4}, --Aura Mastery
	[1044] = 	{cooldown = 25, 	duration = 8, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 5}, --Blessing of Freedom
	[853] = 	{cooldown = 60, 	duration = 6, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 5}, --Hammer of Justice
	[115750] = 	{cooldown = 90, 	duration = 6, 		specs = {65,66,70}, 	talent =21811, charges = 1, class = "PALADIN", type = 5}, --Blinding Light(talent)
	[327193] = 	{cooldown = 90, 	duration = 15, 		specs = {66}, 			talent =23468, charges = 1, class = "PALADIN", type = 1}, --Moment of Glory (talent)
	[31850] = 	{cooldown = 120, 	duration = 8, 		specs = {66}, 			talent =false, charges = 1, class = "PALADIN", type = 2}, --Ardent Defender
	[86659] = 	{cooldown = 300, 	duration = 8, 		specs = {66}, 			talent =false, charges = 1, class = "PALADIN", type = 2}, --Guardian of Ancient Kings
	[204018] = 	{cooldown = 180, 	duration = 10, 		specs = {66}, 			talent =22435, charges = 1, class = "PALADIN", type = 3}, --Blessing of Spellwarding (talent)
	[231895] = 	{cooldown = 120, 	duration = 25, 		specs = {70}, 			talent =22215, charges = 1, class = "PALADIN", type = 1}, --Crusade (talent)
	[205191] = 	{cooldown = 60, 	duration = 10, 		specs = {70}, 			talent =22183, charges = 1, class = "PALADIN", type = 2}, --Eye for an Eye (talent)
	[184662] = 	{cooldown = 120, 	duration = 15, 		specs = {70}, 			talent =false, charges = 1, class = "PALADIN", type = 2}, --Shield of Vengeance

	--warrior
	-- 71 - Arms
	-- 72 - Fury
	-- 73 - Protection

	[107574] = 	{cooldown = 90, 	duration = 20, 		specs = {71,73}, 		talent =22397, charges = 1, class = "WARRIOR", type = 1}, --Avatar
	[227847] = 	{cooldown = 90, 	duration = 5, 		specs = {71},	 		talent =false, charges = 1, class = "WARRIOR", type = 1}, --Bladestorm
	[46924] = 	{cooldown = 60, 	duration = 4, 		specs = {72},		 	talent =22400, charges = 1, class = "WARRIOR", type = 1}, --Bladestorm (talent)
	[152277] = 	{cooldown = 60, 	duration = 6, 		specs = {71},			talent =21667, charges = 1, class = "WARRIOR", type = 1}, --Ravager (talent)
	[228920] = 	{cooldown = 60, 	duration = 6, 		specs = {73}, 			talent =23099, charges = 1, class = "WARRIOR", type = 1}, --Ravager (talent)
	[118038] = 	{cooldown = 180, 	duration = 8, 		specs = {71},		 	talent =false, charges = 1, class = "WARRIOR", type = 2}, --Die by the Sword
	[97462] = 	{cooldown = 180, 	duration = 10, 		specs = {71,72,73}, 	talent =false, charges = 1, class = "WARRIOR", type = 4}, --Rallying Cry
	[1719] = 	{cooldown = 90, 	duration = 10, 		specs = {72},		 	talent =false, charges = 1, class = "WARRIOR", type = 1}, --Recklessness
	[184364] = 	{cooldown = 120, 	duration = 8, 		specs = {72},		 	talent =false, charges = 1, class = "WARRIOR", type = 2}, --Enraged Regeneration
	[12975] = 	{cooldown = 180, 	duration = 15, 		specs = {73}, 			talent =false, charges = 1, class = "WARRIOR", type = 2}, --Last Stand
	[871] = 	{cooldown = 8, 		duration = 240, 	specs = {73}, 			talent =false, charges = 1, class = "WARRIOR", type = 2}, --Shield Wall
	[64382]  = 	{cooldown = 180, 	duration = false, 	specs = {71,72,73}, 	talent =false, charges = 1, class = "WARRIOR", type = 5}, --Shattering Throw
	[5246]  = 	{cooldown = 90, 	duration = 8, 		specs = {71,72,73}, 	talent =false, charges = 1, class = "WARRIOR", type = 5}, --Intimidating Shout

	--warlock
	-- 265 - Affliction
	-- 266 - Demonology
	-- 267 - Destruction

	[205180] = 	{cooldown = 180, 	duration = 20, 		specs = {265}, 			talent =false, charges = 1, class = "WARLOCK", type = 1}, --Summon Darkglare
	--[342601] = {cooldown = 3600, 	duration = false, 	specs = {}, 	talent =false, charges = 1, class = "WARLOCK", type = 1}, --Ritual of Doom
	[113860] = 	{cooldown = 120, 	duration = 20, 		specs = {265}, 			talent =19293, charges = 1, class = "WARLOCK", type = 1}, --Dark Soul: Misery (talent)
	[104773] = 	{cooldown = 180, 	duration = 8, 		specs = {265,266,267}, 	talent =false, charges = 1, class = "WARLOCK", type = 2}, --Unending Resolve
	[108416] = 	{cooldown = 60, 	duration = 20, 		specs = {265,266,267}, 	talent =19286, charges = 1, class = "WARLOCK", type = 2}, --Dark Pact (talent)
	[265187] = 	{cooldown = 90, 	duration = 15, 		specs = {266}, 			talent =false, charges = 1, class = "WARLOCK", type = 1}, --Summon Demonic Tyrant
	[111898] = 	{cooldown = 120, 	duration = 15, 		specs = {266}, 			talent =21717, charges = 1, class = "WARLOCK", type = 1}, --Grimoire: Felguard (talent)
	[267171] = 	{cooldown = 60, 	duration = false, 	specs = {266}, 			talent =23138, charges = 1, class = "WARLOCK", type = 1}, --Demonic Strength (talent)
	[267217] = 	{cooldown = 180, 	duration = 20, 		specs = {266}, 			talent =23091, charges = 1, class = "WARLOCK", type = 1}, --Nether Portal
	[1122] = 	{cooldown = 180, 	duration = 30, 		specs = {267}, 			talent =false, charges = 1, class = "WARLOCK", type = 1}, --Summon Infernal
	[113858] = 	{cooldown = 120, 	duration = 20, 		specs = {267}, 			talent =23092, charges = 1, class = "WARLOCK", type = 1}, --Dark Soul: Instability (talent)
	[30283] = 	{cooldown = 60, 	duration = 3, 		specs = {265,266,267}, 	talent =false, charges = 1, class = "WARLOCK", type = 5}, --Shadowfury
	[333889] = 	{cooldown = 180, 	duration = 15, 		specs = {265,266,267}, 	talent =false, charges = 1, class = "WARLOCK", type = 5}, --Fel Domination
	[5484] = 	{cooldown = 40, 	duration = 20, 		specs = {265,266,267}, 	talent =23465, charges = 1, class = "WARLOCK", type = 5}, --Howl of Terror (talent)

	--shaman
	-- 262 - Elemental
	-- 263 - Enchancment
	-- 264 - Restoration

	[198067] = 	{cooldown = 150, 	duration = 30, 		specs = {262}, 			talent =false, charges = 1, class = "SHAMAN", type = 1}, --Fire Elemental
	[192249] = 	{cooldown = 150, 	duration = 30, 		specs = {262}, 			talent =19272, charges = 1, class = "SHAMAN", type = 1}, --Storm Elemental (talent)
	[108271] = 	{cooldown = 90, 	duration = 8, 		specs = {262,263,264}, 	talent =false, charges = 1, class = "SHAMAN", type = 2}, --Astral Shift
	[108281] = 	{cooldown = 120, 	duration = 10, 		specs = {262,263}, 		talent =22172, charges = 1, class = "SHAMAN", type = 4}, --Ancestral Guidance (talent)
	[51533] = 	{cooldown = 120, 	duration = 15, 		specs = {263}, 			talent =false, charges = 1, class = "SHAMAN", type = 1}, --Feral Spirit
	[114050] = 	{cooldown = 180, 	duration = 15, 		specs = {262}, 			talent =21675, charges = 1, class = "SHAMAN", type = 1}, --Ascendance (talent)
	[114051] = 	{cooldown = 180, 	duration = 15, 		specs = {263}, 			talent =21972, charges = 1, class = "SHAMAN", type = 1}, --Ascendance (talent)
	[114052] = 	{cooldown = 180, 	duration = 15, 		specs = {264}, 			talent =22359, charges = 1, class = "SHAMAN", type = 4}, --Ascendance (talent)
	[98008] = 	{cooldown = 180, 	duration = 6, 		specs = {264}, 			talent =false, charges = 1, class = "SHAMAN", type = 4}, --Spirit Link Totem
	[108280] = 	{cooldown = 180, 	duration = 10, 		specs = {264}, 			talent =false, charges = 1, class = "SHAMAN", type = 4}, --Healing Tide Totem
	[207399] = 	{cooldown = 240, 	duration = 30, 		specs = {264}, 			talent =22323, charges = 1, class = "SHAMAN", type = 4}, --Ancestral Protection Totem (talent)
	[16191] = 	{cooldown = 180, 	duration = 8, 		specs = {264}, 			talent =false, charges = 1, class = "SHAMAN", type = 4}, --Mana Tide Totem
	[198103] = 	{cooldown = 300, 	duration = 60, 		specs = {262,263,264}, 	talent =false, charges = 1, class = "SHAMAN", type = 2}, --Earth Elemental
	[192058] = 	{cooldown = 60, 	duration = false, 	specs = {262,263,264}, 	talent =false, charges = 1, class = "SHAMAN", type = 5}, --Capacitor Totem
	[8143] = 	{cooldown = 60, 	duration = 10, 		specs = {262,263,264}, 	talent =false, charges = 1, class = "SHAMAN", type = 5}, --Tremor Totem
	[192077] = 	{cooldown = 120, 	duration = 15, 		specs = {262,263,264}, 	talent =21966, charges = 1, class = "SHAMAN", type = 5}, --Wind Rush Totem (talent)
	
	--hunter
	-- 253 - Beast Mastery
	-- 254 - Marksmenship
	-- 255 - Survival

	[193530] = 	{cooldown = 120, 	duration = 20, 		specs = {253},		 	talent =false, charges = 1, class = "HUNTER", type = 1}, --Aspect of the Wild
	[19574] = 	{cooldown = 90, 	duration = 12, 		specs = {253}, 			talent =false, charges = 1, class = "HUNTER", type = 1}, --Bestial Wrath
	[201430] = 	{cooldown = 180, 	duration = 12, 		specs = {253}, 			talent =23044, charges = 1, class = "HUNTER", type = 1}, --Stampede (talent)
	[288613] = 	{cooldown = 180, 	duration = 15, 		specs = {254}, 			talent =false, charges = 1, class = "HUNTER", type = 1}, --Trueshot
	[199483] = 	{cooldown = 60, 	duration = 60, 		specs = {253,254,255}, 	talent =23100, charges = 1, class = "HUNTER", type = 2}, --Camouflage (talent)
	[281195] = 	{cooldown = 180, 	duration = 6, 		specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 2}, --Survival of the Fittest
	[266779] = 	{cooldown = 120, 	duration = 20, 		specs = {255}, 			talent =false, charges = 1, class = "HUNTER", type = 1}, --Coordinated Assault
	[186265] = 	{cooldown = 180, 	duration = 8, 		specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 2}, --Aspect of the Turtle
	[109304] = 	{cooldown = 120, 	duration = false, 	specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 2}, --Exhilaration
	[186257] = 	{cooldown = 144, 	duration = 14, 		specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 5}, --Aspect of the cheetah
	[19577] = 	{cooldown = 60, 	duration = 5, 		specs = {253,255}, 		talent =false, charges = 1, class = "HUNTER", type = 5}, --Intimidation
	[109248] = 	{cooldown = 45, 	duration = 10, 		specs = {253,254,255}, 	talent =22499, charges = 1, class = "HUNTER", type = 5}, --Binding Shot (talent)
	[187650] = 	{cooldown = 25, 	duration = 60, 		specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 5}, --Freezing Trap
	[186289] = 	{cooldown = 72, 	duration = 15, 		specs = {255}, 			talent =false, charges = 1, class = "HUNTER", type = 5}, --Aspect of the eagle

	--druid
	-- 102 - Balance
	-- 103 - Feral
	-- 104 - Guardian
	-- 105 - Restoration

	[77761] = 	{cooldown = 120, 	duration = 8, 		specs = {102,103,104,105}, 	talent =false, charges = 1, class = "DRUID", type = 4}, --Stampeding Roar
	[194223] = 	{cooldown = 180, 	duration = 20, 		specs = {102}, 				talent =false, charges = 1, class = "DRUID", type = 1}, --Celestial Alignment
	[102560] = 	{cooldown = 180, 	duration = 30, 		specs = {102}, 				talent =21702, charges = 1, class = "DRUID", type = 1}, --Incarnation: Chosen of Elune (talent)
	[22812] = 	{cooldown = 60, 	duration = 12, 		specs = {102,103,104,105}, 	talent =false, charges = 1, class = "DRUID", type = 2}, --Barkskin
	[108238] = 	{cooldown = 90, 	duration = false, 	specs = {102,103,104,105}, 	talent =18570, charges = 1, class = "DRUID", type = 2}, --Renewal (talent)
	[29166] = 	{cooldown = 180, 	duration = 12, 		specs = {102,105}, 			talent =false, charges = 1, class = "DRUID", type = 3}, --Innervate
	[106951] = 	{cooldown = 180, 	duration = 15, 		specs = {103,104}, 			talent =false, charges = 1, class = "DRUID", type = 1}, --Berserk
	[102543] = 	{cooldown = 30, 	duration = 180, 	specs = {103}, 				talent =21704, charges = 1, class = "DRUID", type = 1}, --Incarnation: King of the Jungle (talent)
	[61336] = 	{cooldown = 120, 	duration = 6, 		specs = {103,104}, 			talent =false, charges = 2, class = "DRUID", type = 2}, --Survival Instincts (2min feral 4min guardian, same spellid)
	[102558] = 	{cooldown = 180, 	duration = 30, 		specs = {104}, 				talent =22388, charges = 1, class = "DRUID", type = 2}, --Incarnation: Guardian of Ursoc (talent)
	[33891] = 	{cooldown = 180, 	duration = 30, 		specs = {105}, 				talent =22421, charges = 1, class = "DRUID", type = 2}, --Incarnation: Tree of Life (talent)
	[102342] = 	{cooldown = 60, 	duration = 12, 		specs = {105}, 				talent =false, charges = 1, class = "DRUID", type = 3}, --Ironbark
	[203651] = 	{cooldown = 60, 	duration = false, 	specs = {105}, 				talent =22422, charges = 1, class = "DRUID", type = 3}, --Overgrowth (talent)
	[740] = 	{cooldown = 180, 	duration = 8, 		specs = {105}, 				talent =false, charges = 1, class = "DRUID", type = 4}, --Tranquility
	[197721] = 	{cooldown = 90, 	duration = 8, 		specs = {105}, 				talent =22404, charges = 1, class = "DRUID", type = 4}, --Flourish (talent)
	[132469] = 	{cooldown = 30, 	duration = false, 	specs = {102,103,104,105}, 	talent =false, charges = 1, class = "DRUID", type = 5}, --Typhoon
	[319454] = 	{cooldown = 300, 	duration = 45, 		specs = {102,103,104,105}, 	talent =18577, charges = 1, class = "DRUID", type = 5}, --Heart of the Wild (talent)
	[102793] = 	{cooldown = 60, 	duration = 10, 		specs = {102,103,104,105}, 	talent =false, charges = 1, class = "DRUID", type = 5}, --Ursol's Vortex

	--demon hunter
	-- 577 - Havoc
	-- 581 - Vengance

	--mage
	-- 62 - Arcane
	-- 63 - Fire
	-- 64 - Frost

	[12042] = 	{cooldown = 90, 	duration = 10, 		specs = {62}, 			talent =false, charges = 1, class = "MAGE", type = 1},  --Arcane Power
	[12051] = 	{cooldown = 90, 	duration = 6, 		specs = {62}, 			talent =false, charges = 1, class = "MAGE", type = 1},  --Evocation
	[110960] = 	{cooldown = 120, 	duration = 20, 		specs = {62}, 			talent =false, charges = 1, class = "MAGE", type = 2},  --Greater Invisibility
	[235450] = 	{cooldown = 25, 	duration = 60, 		specs = {62}, 			talent =false, charges = 1, class = "MAGE", type = 5},  --Prismatic Barrier
	[235313] = 	{cooldown = 25, 	duration = 60, 		specs = {63}, 			talent =false, charges = 1, class = "MAGE", type = 5},  --Blazing Barrier
	[11426] = 	{cooldown = 25, 	duration = 60, 		specs = {64}, 			talent =false, charges = 1, class = "MAGE", type = 5},  --Ice Barrier
	[190319] = 	{cooldown = 120, 	duration = 10, 		specs = {63}, 			talent =false, charges = 1, class = "MAGE", type = 1},  --Combustion
	[55342] = 	{cooldown = 120, 	duration = 40, 		specs = {62,63,64}, 	talent =22445, charges = 1, class = "MAGE", type = 1},  --Mirror Image
	[66] = 		{cooldown = 300, 	duration = 20, 		specs = {63,64}, 		talent =false, charges = 1, class = "MAGE", type = 2},  --Invisibility
	[12472] = 	{cooldown = 180, 	duration = 20, 		specs = {64}, 			talent =false, charges = 1, class = "MAGE", type = 1},  --Icy Veins
	[205021] = 	{cooldown = 78, 	duration = 5, 		specs = {64}, 			talent =22309, charges = 1, class = "MAGE", type = 1},  --Ray of Frost (talent)
	[45438] = 	{cooldown = 240, 	duration = 10, 		specs = {62,63,64}, 	talent =false, charges = 1, class = "MAGE", type = 2},  --Ice Block
	[235219] = 	{cooldown = 300, 	duration = false, 	specs = {64}, 			talent =false, charges = 1, class = "MAGE", type = 5},  --Cold Snap
	[113724] = 	{cooldown = 45, 	duration = 10, 		specs = {62,63,64}, 	talent =22471, charges = 1, class = "MAGE", type = 5},  --Ring of Frost (talent)

	--priest
	-- 256 - Discipline
	-- 257 - Holy
	-- 258 - Shadow

	[10060] = 	{cooldown = 120, 	duration = 20, 		specs = {256,257,258}, 	talent =false, charges = 1, class = "PRIEST", type = 1},  --Power Infusion
	[34433] = 	{cooldown = 180, 	duration = 15, 		specs = {256,258}, 		talent =false, charges = 1, class = "PRIEST", type = 1, ignoredIfTalent = 21719},  --Shadowfiend
	[200174] = 	{cooldown = 60, 	duration = 15, 		specs = {258}, 			talent =21719, charges = 1, class = "PRIEST", type = 1},  --Mindbender (talent)
	[123040] = 	{cooldown = 60, 	duration = 12, 		specs = {256}, 			talent =22094, charges = 1, class = "PRIEST", type = 1},  --Mindbender (talent)
	[33206] = 	{cooldown = 180, 	duration = 8, 		specs = {256}, 			talent =false, charges = 1, class = "PRIEST", type = 3},  --Pain Suppression
	[62618] = 	{cooldown = 180, 	duration = 10, 		specs = {256}, 			talent =false, charges = 1, class = "PRIEST", type = 4},  --Power Word: Barrier
	[271466] = 	{cooldown = 180, 	duration = 10, 		specs = {256}, 			talent =21184, charges = 1, class = "PRIEST", type = 4},  --Luminous Barrier (talent)
	[47536] = 	{cooldown = 90, 	duration = 10, 		specs = {256}, 			talent =false, charges = 1, class = "PRIEST", type = 5},  --Rapture
	[19236] = 	{cooldown = 90, 	duration = 10, 		specs = {256,257,258}, 	talent =false, charges = 1, class = "PRIEST", type = 5},  --Desperate Prayer
	[200183] = 	{cooldown = 120, 	duration = 20, 		specs = {257}, 			talent =21644, charges = 1, class = "PRIEST", type = 2},  --Apotheosis (talent)
	[47788] = 	{cooldown = 180, 	duration = 10, 		specs = {257}, 			talent =false, charges = 1, class = "PRIEST", type = 3},  --Guardian Spirit
	[64843] = 	{cooldown = 180, 	duration = 8, 		specs = {257}, 			talent =false, charges = 1, class = "PRIEST", type = 4},  --Divine Hymn
	[64901] = 	{cooldown = 300, 	duration = 6, 		specs = {257}, 			talent =false, charges = 1, class = "PRIEST", type = 4},  --Symbol of Hope
	[265202] = 	{cooldown = 720, 	duration = false, 	specs = {257}, 			talent =23145, charges = 1, class = "PRIEST", type = 4},  --Holy Word: Salvation (talent)
	[109964] = 	{cooldown = 60, 	duration = 12, 		specs = {256}, 			talent =21184, charges = 1, class = "PRIEST", type = 4},  --Spirit Shell (talent)
	[8122] = 	{cooldown = 60, 	duration = 8, 		specs = {256,257,258}, 	talent =false, charges = 1, class = "PRIEST", type = 5},  --Psychic Scream
	[193223] = 	{cooldown = 240, 	duration = 60, 		specs = {258}, 			talent =21979, charges = 1, class = "PRIEST", type = 1},  --Surrender to Madness (talent)
	[47585] = 	{cooldown = 120, 	duration = 6, 		specs = {258}, 			talent =false, charges = 1, class = "PRIEST", type = 2},  --Dispersion
	[15286] = 	{cooldown = 120, 	duration = 15, 		specs = {258}, 			talent =false, charges = 1, class = "PRIEST", type = 4},  --Vampiric Embrace
	[64044] = 	{cooldown = 45, 	duration = 4, 		specs = {258}, 			talent =21752, charges = 1, class = "PRIEST", type = 5}, --Psychic Horror
	[205369] = 	{cooldown = 30, 	duration = 6, 		specs = {258}, 			talent =23375, charges = 1, class = "PRIEST", type = 5}, --Mind Bomb
	[228260] = 	{cooldown = 90, 	duration = 15, 		specs = {258}, 			talent =false, charges = 1, class = "PRIEST", type = 1}, --Void Erruption
	[73325] = 	{cooldown = 90, 	duration = false, 	specs = {256,257,258}, 	talent =false, charges = 1, class = "PRIEST", type = 5}, --Leap of Faith

	--rogue
	-- 259 - Assasination
	-- 260 - Outlaw
	-- 261 - Subtlety

	[79140] = 	{cooldown = 120, 	duration = 20, 		specs = {259}, 			talent =false, charges = 1, class = "ROGUE", type = 1},  --Vendetta
	[1856] = 	{cooldown = 120, 	duration = 3, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 2},  --Vanish
	[5277] = 	{cooldown = 120, 	duration = 10, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 2},  --Evasion
	[31224] = 	{cooldown = 120, 	duration = 5, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 2},  --Cloak of Shadows
	[2094] = 	{cooldown = 120, 	duration = 60, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 5},  --Blind
	[114018] = 	{cooldown = 360, 	duration = 15, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 5},  --Shroud of Concealment
	[185311] = 	{cooldown = 30, 	duration = 15, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 5},  --Crimson Vial
	[13750] = 	{cooldown = 180, 	duration = 20, 		specs = {260}, 			talent =false, charges = 1, class = "ROGUE", type = 1},  --Adrenaline Rush
	[51690] = 	{cooldown = 120, 	duration = 2, 		specs = {260}, 			talent =23175, charges = 1, class = "ROGUE", type = 1},  --Killing Spree (talent)
	[199754] = 	{cooldown = 120, 	duration = 10, 		specs = {260}, 			talent =false, charges = 1, class = "ROGUE", type = 2},  --Riposte
	[343142] = 	{cooldown = 90, 	duration = 10, 		specs = {260}, 			talent =19250, charges = 1, class = "ROGUE", type = 5},  --Dreadblades
	[121471] = 	{cooldown = 180, 	duration = 20, 		specs = {261}, 			talent =false, charges = 1, class = "ROGUE", type = 1},  --Shadow Blades
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

--list of all crowd control spells
--it is not transmitted to other clients
LIB_OPEN_RAID_CROWDCONTROL = {
	[339] = {cooldown = 0,		class = "DRUID"}, --Entangling Roots
	[2637] = {cooldown = 0,		class = "DRUID"}, --Hibernate
	[33786] = {cooldown = 0,	class = "DRUID"}, --Cyclone
	[22570] = {cooldown = 0,	class = "DRUID"}, --Maim
	[5211] = {cooldown = 60,	class = "DRUID"}, --Mighty Bash
	[9005] = {cooldown = 0,		class = "DRUID"}, --Pounce
	[45334] = {cooldown = 0,	class = "DRUID"}, --Immobilized
	[1513] = {cooldown = 0,		class = "HUNTER"}, --Scare Beast
	[3355] = {cooldown = 30,	class = "HUNTER"}, --Freezing Trap
	[19386] = {cooldown = 30,	class = "HUNTER"}, --Wyvern Sting
	[118] = {cooldown = 0,		class = "MAGE"}, --Polymorph
	[28271] = {cooldown = 0,	class = "MAGE"}, --Polymorph (Pig)
	[28272] = {cooldown = 0,	class = "MAGE"}, --Polymorph (Turtle)
	[122] = {cooldown = 0,		class = "MAGE"}, --Frost Nova
	[33395] = {cooldown = 25,	class = "MAGE"}, --Freeze (Water Elemental)
	[31661] = {cooldown = 45,	class = "MAGE"}, --Dragon's Breath
	[853] = {cooldown = 60,		class = "PALADIN"}, --Hammer of Justice
	[20066] = {cooldown = 15,	class = "PALADIN"}, --Repentance
	[605] = {cooldown = 0,		class = "PRIEST"}, --Mind Control
	[8122] = {cooldown = 45,	class = "PRIEST"}, --Psychic Scream
	[9484] = {cooldown = 0,		class = "PRIEST"}, --Shackle Undead
	[6770] = {cooldown = 0,		class = "ROGUE"}, --Sap
	[2094] = {cooldown = 120,	class = "ROGUE"}, --Blind
	[408] = {cooldown = 20,		class = "ROGUE"}, --Kidney Shot
	[8643] = {cooldown = 20,	class = "ROGUE"}, --Kidney Shot
	[1776] = {cooldown = 20,	class = "ROGUE"}, --Gouge
	[1833] = {cooldown = 0,		class = "ROGUE"}, --Cheap Shot
	[5484] = {cooldown = 40,	class = "WARLOCK"}, --Howl of Terror
	[5782] = {cooldown = 0,		class = "WARLOCK"}, --Fear
	[710] = {cooldown = 0,		class = "WARLOCK"}, --Banish
	[6789] = {cooldown = 45,	class = "WARLOCK"}, --Death Coil
	[19647] = {cooldown = 24,	class = "WARLOCK"}, --Spell Lock (Felhunter)
	[30283] = {cooldown = 60,	class = "WARLOCK"}, --Shadowfury
	[5246] = {cooldown = 90,	class = "WARRIOR"}, --Intimidating Shout
	[5530] = {cooldown = 0,		class = "WARRIOR"}, --Mace Stun Effect
	[34510] = {cooldown = 0,	class = "GENERAL"}, --Stun (Deep Thunder)
	[20549] = {cooldown = 120,	class = "RACIAL"}, --War Stomp (Tauren)
}

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
	LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {
		[33778] = {name = GetSpellInfo(33778) .. " (" .. L["STRING_BLOOM"] .. ")"}, --lifebloom (bloom)
	}
end

--interrupt list using proxy from cooldown list
--this list should be expansion and combatlog safe
LIB_OPEN_RAID_SPELL_INTERRUPT = {
	[6552] = LIB_OPEN_RAID_COOLDOWNS_INFO[6552], --Pummel (Warrior)

	[2139] = LIB_OPEN_RAID_COOLDOWNS_INFO[2139], --Counterspell (Mage)

	[15487] = LIB_OPEN_RAID_COOLDOWNS_INFO[15487], --Silence (Priest shadow)

	[1766] = LIB_OPEN_RAID_COOLDOWNS_INFO[1766], --Kick (Rogue)

	[16979] = LIB_OPEN_RAID_COOLDOWNS_INFO[16979], --Feral Charge (Druid feral)

	[8042] = LIB_OPEN_RAID_COOLDOWNS_INFO[8042], --Earth Shock (Shaman)

	[28730] = LIB_OPEN_RAID_COOLDOWNS_INFO[28730], --Arcane Torrent (Blood Elf racial)

	[19647] = LIB_OPEN_RAID_COOLDOWNS_INFO[19647], --Spell Lock (Felhunter)
}

--override list of spells with more than one effect, example: multiple types of polymorph
LIB_OPEN_RAID_SPELL_DEFAULT_IDS = {
}
--need to add mass dispell (32375)

LIB_OPEN_RAID_DATABASE_LOADED = true
