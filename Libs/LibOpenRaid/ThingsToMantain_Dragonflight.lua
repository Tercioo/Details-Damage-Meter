
--data for dragonflight expansion
do
	local versionString, revision, launchDate, gameVersion = GetBuildInfo()
	if (gameVersion >= 110000 or gameVersion < 100000) then
		return
	end

	if (not LIB_OPEN_RAID_CAN_LOAD) then
		return
	end

	local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

	local loadLibDatabase = function()
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

		LIB_OPEN_RAID_FOOD_BUFF = {} --default
		LIB_OPEN_RAID_FLASK_BUFF = {} --default

		LIB_OPEN_RAID_BLOODLUST = {
			[2825] = true, --bloodlust (shaman)
			[32182] = true, --heroism (shaman)
			[80353] = true, --timewarp (mage)
			[90355] = true, --ancient hysteria (hunter)
			[309658] = true, --current exp drums (letherwork)
			[264667] = true, --primal rage (hunter)
			[390386] = true, --fury of the aspects
		}

		LIB_OPEN_RAID_MYTHICKEYSTONE_ITEMID = 180653
		LIB_OPEN_RAID_AUGMENTATED_RUNE = 0 --need to update to dragonflight

		LIB_OPEN_RAID_COVENANT_ICONS = {
			--need to get the icon for the new 4 covanants in dragonflight
			--"Interface\\ICONS\\UI_Sigil_Kyrian", --kyrian
			--"Interface\\ICONS\\UI_Sigil_Venthyr", --venthyr
			--"Interface\\ICONS\\UI_Sigil_NightFae", --nightfae
			--"Interface\\ICONS\\UI_Sigil_Necrolord", --necrolords
		}

		--which gear slots can be enchanted on the latest retail version of the game
		--when the value is a number, the slot only receives enchants for a specific attribute
		LIB_OPEN_RAID_ENCHANT_SLOTS = {
			--[INVSLOT_NECK] = true,
			[INVSLOT_BACK] = true,
			[INVSLOT_CHEST] = true,
			[INVSLOT_FINGER1] = true,
			[INVSLOT_FINGER2] = true,
			[INVSLOT_MAINHAND] = true,
			[INVSLOT_FEET] = true,
			[INVSLOT_WRIST] = true,
			[INVSLOT_LEGS] = true,
			[INVSLOT_HAND] = true,
		}

		-- how to get the enchantId:
		-- local itemLink = GetInventoryItemLink("player", slotId)
		-- local enchandId = select(3, strsplit(":", itemLink))
		-- print("enchantId:", enchandId)
		LIB_OPEN_RAID_ENCHANT_IDS = {
			--empty as the lib now get the enchant id and compare with expansion enchantId number space
		}

		LIB_OPEN_RAID_DEATHKNIGHT_RUNEFORGING_ENCHANT_IDS = {
			[6243] = INVSLOT_MAINHAND, --[Runeforging: Rune of Hysteria]
			[3370] = INVSLOT_MAINHAND, --[Runeforging: Rune of Razorice]
			[6241] = INVSLOT_MAINHAND, --[Runeforging: Rune of Sanguination]
			[6242] = INVSLOT_MAINHAND, --[Runeforging: Rune of Spellwarding]
			[6245] = INVSLOT_MAINHAND, --[Runeforging: Rune of the Apocalypse]
			[3368] = INVSLOT_MAINHAND, --[Runeforging: Rune of the Fallen Crusader]
			[3847] = INVSLOT_MAINHAND, --[Runeforging: Rune of the Stoneskin Gargoyle]
			[6244] = INVSLOT_MAINHAND, --[Runeforging: Rune of Unending Thirst]
		}

		--how to get the gemId:
		--local itemLink = GetInventoryItemLink("player", slotId)
		--local gemId = select(4, strsplit(":", itemLink))
		--print("gemId:", gemId)
		LIB_OPEN_RAID_GEM_IDS = {
			--need update to dragonflight
		}

		--/dump GetWeaponEnchantInfo()
		LIB_OPEN_RAID_WEAPON_ENCHANT_IDS = {
			[5401] = {spell=33757}, -- Windfury
			[5400] = {spell=318038}, -- Flametongue
			[6498] = {spell=382021}, -- Earthliving
			-- Runes, whetstones, weightstones
			[6512] = {tier = 1, item=194823},
			[6513] = {tier = 2, item=194823},
			[6514] = {tier = 3, item=194823},

			[6515] = {tier = 1, item=194826},
			[6694] = {tier = 2, item=194826},
			[6695] = {tier = 3, item=194826},

			[6516] = {tier = 1, item=194820},
			[6517] = {tier = 2, item=194820},
			[6518] = {tier = 3, item=194820},

			[6529] = {tier = 1, item=198162},
			[6530] = {tier = 2, item=198162},
			[6531] = {tier = 3, item=198162},

			[6379] = {tier = 1, item=191940},
			[6380] = {tier = 2, item=191940},
			[6381] = {tier = 3, item=191940},

			[6696] = {tier = 1, item=191945},
			[6697] = {tier = 2, item=191945},
			[6698] = {tier = 3, item=191945},
		}

		--buff spellId, the value of the food is the tier level
		--use /details auras
		LIB_OPEN_RAID_FOOD_BUFF = {
			[382145] = {tier = {[220] = 1}, status = {"haste"}, localized = {STAT_HASTE}}, --Well Fed haste 220
			[382146] = {tier = {[220] = 1}, status = {"critical"}, localized = {STAT_CRITICAL_STRIKE}}, --Well Fed crit 220
			[382149] = {tier = {[220] = 1}, status = {"versatility"}, localized = {STAT_VERSATILITY}}, --Well Fed vers 220
			[382150] = {tier = {[220] = 1}, status = {"mastery"}, localized = {STAT_MASTERY}}, --Well Fed mastery 220
			[382152] = {tier = {[130] = 1}, status = {"haste", "critical"}, localized = {STAT_HASTE, STAT_CRITICAL_STRIKE}}, --Well Fed haste + crit 130
			[382153] = {tier = {[130] = 1}, status = {"haste", "versatility"}, localized = {STAT_HASTE, STAT_VERSATILITY}}, --Well Fed haste + vers 130
			[382154] = {tier = {[130] = 1}, status = {"haste", "mastery"}, localized = {STAT_HASTE, STAT_MASTERY}}, --Well Fed haste + mastery 130
			[382155] = {tier = {[130] = 1}, status = {"critical", "versatility"}, localized = {STAT_CRITICAL_STRIKE, STAT_VERSATILITY}}, --Well Fed crit + vers 130
			[382156] = {tier = {[130] = 1}, status = {"critical", "mastery"}, localized = {STAT_CRITICAL_STRIKE, STAT_MASTERY}}, --Well Fed crit + mastery 130
			[382157] = {tier = {[130] = 1}, status = {"mastery", "versatility"}, localized = {STAT_MASTERY, STAT_VERSATILITY}}, --Well Fed vers + mastery 130
		}

		--use /details auras
		LIB_OPEN_RAID_FLASK_BUFF = {
			--phials
			[371354] = {tier = {[131] = 1, [151] = 2, [174] = 3}}, --Phial of the Eye in the Storm
			[370652] = {tier = {[470] = 1, [541] = 2, [622] = 3}}, --Phial of Static Empowerment
			[371172] = {tier = {[236] = 1, [257] = 2, [279] = 3}}, --Phial of Tepid Versatility
			[371204] = {tier = {[8125] = 1, [9344] = 2, [10746] = 3}}, --Phial of Still Air
			[371036] = {tier = {[-4] = 1, [-5] = 2, [-6] = 3}}, --Phial of Icy Preservation
			[374000] = {tier = {[690] = 1, [752] = 2, [814] = 3}}, --Iced Phial of Corrupting Rage
			[371386] = {tier = {[432] = 1, [497] = 2, [572] = 3}}, --Phial of Charged Isolation
			[373257] = {tier = {[4603] = 2, [3949] = 1, [5365] = 3}}, --Phial of Glacial Fury
			[393700] = {tier = {[45] = 3, [38] = 2, [32] = 1}}, --Aerated Phial of Deftness
			[393717] = {tier = {[45] = 3, [38] = 2, [32] = 1}}, --Steaming Phial of Finesse
			[371186] = {tier = {[558] = 3, [473] = 1, [515] = 2}}, --Charged Phial of Alacrity
			[393714] = {tier = {[45] = 3, [38] = 2, [32] = 1}}, --Crystalline Phial of Perception
			[371339] = {tier = {[562] = 3, [476] = 1, [519] = 2}}, --Phial of Elemental Chaos
		}

		LIB_OPEN_RAID_ALL_POTIONS = {
			[415569] = 1, --Dreamwalker's Healing Potion
			[370511] = 1, --Refreshing Healing Potion
			[371039] = 1, --Potion of Withering Vitality
			[370607] = 1, --Aerated Mana Potion
			[371024] = 1, --Elemental Potion of Power --querying cooldown with GetSpellCooldown(371024) gives the cooldown of both potions
			[371028] = 1, --Elemental Potion of Ultimate Power
			[371033] = 1, --Potion of Frozen Focus
			[371125] = 1, --Potion of the Hushed Zephyr
			[371052] = 1, --Potion of Chilled Clarity
		}

		--spellId of healing from potions
		LIB_OPEN_RAID_HEALING_POTIONS = {
			[415569] = 1, --Dreamwalker's Healing Potion
			[370511] = 1, --Refreshing Healing Potion
			[371039] = 1, --Potion of Withering Vitality
			[6262] = 1, --Warlock's Healthstone
		}

		LIB_OPEN_RAID_MANA_POTIONS = {
			[370607] = 1, --Aerated Mana Potion -- CAST_SUCCESS | ENERGIZE
		}


		--end of per expansion content
		--------------------------------------------------------------------------------------------


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

		--todo:
		--get cooldown duration from the buff placed on the player or target player
		--spell scanner not getting the spell from the pet spellbook

		LIB_OPEN_RAID_COOLDOWNS_INFO = {

			-- Filter Types:
			-- 1 attack cooldown
			-- 2 personal defensive cooldown
			-- 3 targetted defensive cooldown
			-- 4 raid defensive cooldown
			-- 5 personal utility cooldown
			-- 6 interrupt
			-- 7 dispel
			-- 8 crowd control
			-- 9 racials
			-- 10 item heal
			-- 11 item power
			-- 12 item utility

			--defensive potions
			[6262] = {cooldown = 60,	duration = 0,	specs = {},	talent = false,	charges = 1, class = "", type = 10}, --Healthstone
			[370511] = {cooldown = 300,	duration = 0,	specs = {},	talent = false,	charges = 1, class = "", type = 10, shareid = 101}, --Refreshing Healing Potion
			[415569] = {cooldown = 300, duration = 0, specs = {}, talent = false, charges = 1, class = "", type = 10, sharedid = 101}, -- Dreamwalker's Healing Potion

			--attack potions
			[371024] = {cooldown = 300,	duration = 30,	specs = {},	talent = false,	charges = 1, class = "", type = 11, shareid = 101}, --Elemental Potion of Power

			--utility potions
			[371124] = {cooldown = 300,	duration = 0,	specs = {},	talent = false,	charges = 1, class = "", type = 12, shareid = 101}, --exp9 invisibility potion

			--racials 
			--maintanance: login into the new race and type /run Details.GenerateRacialSpellList()
			--this command give a formated line to paste here

			[312411] = {cooldown = 90,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[35] = true}, race = "Vulpera",	class = "",	type = 9}, --Bag of Tricks (Vulpera)
			--[312370] = {cooldown = 600,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[35] = true}, race = "Vulpera",	class = "",	type = 9}, --Make Camp (Vulpera)
			--[312372] = {cooldown = 3600,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[35] = true}, race = "Vulpera",	class = "",	type = 9}, --Return to Camp (Vulpera)
			--[312425] = {cooldown = 300,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[35] = true}, race = "Vulpera",	class = "",	type = 9}, --Rummage Your Bag (Vulpera)
			[274738] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[36] = true}, race = "MagharOrc",	class = "",	type = 9}, --Ancestral Call (MagharOrc)
			--[292752] = {cooldown = 432000,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[31] = true}, race = "ZandalariTroll",	class = "",	type = 9}, --Embrace of the Loa (ZandalariTroll)
			--[281954] = {cooldown = 900,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[31] = true}, race = "ZandalariTroll",	class = "",	type = 9}, --Pterrordax Swoop (ZandalariTroll)
			[291944] = {cooldown = 150,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[31] = true}, race = "ZandalariTroll",	class = "",	type = 9}, --Regeneratin' (ZandalariTroll)
			[255654] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[28] = true}, race = "HighmountainTauren",	class = "",	type = 9}, --Bull Rush (HighmountainTauren)
			[260364] = {cooldown = 180,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[27] = true}, race = "Nightborne",	class = "",	type = 9}, --Arcane Pulse (Nightborne)
			--[255661] = {cooldown = 600,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[27] = true}, race = "Nightborne",	class = "",	type = 9}, --Cantrips (Nightborne)
			--[69046] = {cooldown = 1800,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[9] = true}, race = "Goblin",	class = "",	type = 9}, --Pack Hobgoblin (Goblin)
			[69041] = {cooldown = 90,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[9] = true}, race = "Goblin",	class = "",	type = 9}, --Rocket Barrage (Goblin)
			[69070] = {cooldown = 90,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[9] = true}, race = "Goblin",	class = "",	type = 9}, --Rocket Jump (Goblin)
			[20549] = {cooldown = 90,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[6] = true}, race = "Tauren",	class = "",	type = 9}, --War Stomp (Tauren)
			--[20577] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[5] = true}, race = "Scourge",	class = "",	type = 9}, --Cannibalize (Scourge)
			[7744] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[5] = true}, race = "Scourge",	class = "",	type = 9}, --Will of the Forsaken (Scourge)
			[20572] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[2] = true}, race = "Orc",	class = "",	type = 9}, --Blood Fury (Orc)
			[312924] = {cooldown = 180,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[37] = true}, race = "Mechagnome",	class = "",	type = 9}, --Hyper Organic Light Originator (Mechagnome)
			--[312890] = {cooldown = 0,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[37] = true}, race = "Mechagnome",	class = "",	type = 9}, --Skeleton Pinkie (Mechagnome)
			[287712] = {cooldown = 150,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[32] = true}, race = "KulTiran",	class = "",	type = 9}, --Haymaker (KulTiran)
			[265221] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[34] = true}, race = "DarkIronDwarf",	class = "",	type = 9}, --Fireblood (DarkIronDwarf)
			--[265225] = {cooldown = 1800,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[34] = true}, race = "DarkIronDwarf",	class = "",	type = 9}, --Mole Machine (DarkIronDwarf)
			--[259930] = {cooldown = 900,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[30] = true}, race = "LightforgedDraenei",	class = "",	type = 9}, --Forge of Light (LightforgedDraenei)
			[255647] = {cooldown = 150,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[30] = true}, race = "LightforgedDraenei",	class = "",	type = 9}, --Light's Judgment (LightforgedDraenei)
			[256948] = {cooldown = 180,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[29] = true}, race = "VoidElf",	class = "",	type = 9}, --Spatial Rift (VoidElf)
			--[358733] = {cooldown = 1,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[52] = true, [70] = true}, race = "Dracthyr",	class = "",	type = 9}, --Glide (Dracthyr)
			[368970] = {cooldown = 90,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[52] = true, [70] = true}, race = "Dracthyr",	class = "",	type = 9}, --Tail Swipe (Dracthyr)
			[357214] = {cooldown = 90,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[52] = true, [70] = true}, race = "Dracthyr",	class = "",	type = 9}, --Wing Buffet (Dracthyr)
			[107079] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[25] = true, [24] = true, [26] = true}, race = "Pandaren",	class = "",	type = 9}, --Quaking Palm (Pandaren)
			[68992] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[22] = true}, race = "Worgen",	class = "",	type = 9}, --Darkflight (Worgen)
			--[68996] = {cooldown = 1,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[22] = true}, race = "Worgen",	class = "",	type = 9}, --Two Forms (Worgen)
			[26297] = {cooldown = 180,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[8] = true}, race = "Troll",	class = "",	type = 9}, --Berserking (Troll)
			[20589] = {cooldown = 60,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[7] = true}, race = "Gnome",	class = "",	type = 9}, --Escape Artist (Gnome)
			[232633] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[10] = true}, race = "BloodElf",	class = "",	type = 9}, --Arcane Torrent (BloodElf)
			[59752] = {cooldown = 180,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[1] = true}, race = "Human",	class = "",	type = 9}, --Will to Survive (Human)
			[20594] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[3] = true}, race = "Dwarf",	class = "",	type = 9}, --Stoneform (Dwarf)
			[58984] = {cooldown = 120,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[4] = true}, race = "NightElf",	class = "",	type = 9}, --Shadowmeld (NightElf)
			[59542] = {cooldown = 180,	duration = 0,	specs = {},			talent = false,	charges = 1, raceid = {[11] = true}, race = "Draenei",	class = "",	type = 9}, --Gift of the Naaru (Draenei)

			--interrupts
			[6552] =	{duration = 0, class = "WARRIOR",	specs = {71, 72, 73}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Pummel
			[2139] =	{duration = 0, class = "MAGE",	specs = {62, 63, 64}, cooldown = 24, silence = 6, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Counterspell
			[15487] =	{duration = 0, class = "PRIEST",	specs = {258}, cooldown = 45, silence = 4, talent = false, cooldownWithTalent = 30, cooldownTalentId = 23137, type = 6, charges = 1}, --Silence (shadow) Last Word Talent to reduce cooldown in 15 seconds
			[1766] =	{duration = 0, class = "ROGUE",	specs = {259, 260, 261}, cooldown = 15, silence = 5, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Kick
			[96231] =	{duration = 0, class = "PALADIN",	specs = {66, 70}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Rebuke (protection and retribution)
			[116705] =	{duration = 0, class = "MONK",	specs = {268, 269}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Spear Hand Strike (brewmaster and windwalker)
			[57994] =	{duration = 0, class = "SHAMAN",	specs = {262, 263, 264}, cooldown = 12, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Wind Shear
			[47528] =	{duration = 0, class = "DEATHKNIGHT",	specs = {250, 251, 252}, cooldown = 15, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Mind Freeze
			[106839] =	{duration = 0, class = "DRUID",	specs = {103, 104}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Skull Bash (feral, guardian)
			[78675] =	{duration = 0, class = "DRUID",	specs = {102}, cooldown = 60, silence = 8, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Solar Beam (balance)
			[147362] =	{duration = 0, class = "HUNTER",	specs = {253, 254}, cooldown = 24, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Counter Shot (beast mastery, marksmanship)
			[187707] =	{duration = 0, class = "HUNTER",	specs = {255}, cooldown = 15, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Muzzle (survival)
			[183752] =	{duration = 0, class = "DEMONHUNTER",	specs = {577, 581}, cooldown = 15, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Disrupt
			[19647] =	{duration = 0, class = "WARLOCK",	specs = {265, 266, 267}, cooldown = 24, silence = 6, talent = false, cooldownWithTalent = false, cooldownTalentId = false, pet = 417, type = 6, charges = 1}, --Spell Lock (pet felhunter ability)
			[132409] =	{duration = 0, class = "WARLOCK",	specs = {}, cooldown = 24, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Spell Lock with felhunter Sacrified by Grimeoire of Sacrifice
			[89766] =	{duration = 0, class = "WARLOCK",	specs = {266}, cooldown = 30, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, pet = 17252, type = 6, charges = 1}, --Axe Toss (pet felguard ability)
			[351338] =	{duration = 0, class = "EVOKER",	specs = {1467, 1468}, cooldown = 40,	silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false,	charges = 1, type = 6}, --Quell (Evoker)

			--~paladin
			-- 65 - Holy
			-- 66 - Protection
			-- 70 - Retribution
			[31850] = {cooldown = 120,	duration = 8,	specs = {66},				talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Ardent Defender
			[31821] = {cooldown = 180,	duration = 8,	specs = {65},				talent = false,	charges = 1,	class = "PALADIN",	type = 4}, --Aura Mastery
			[216331] = {cooldown = 120,	duration = 20,	specs = {65},				talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Avenging Crusader
			[31884] = {cooldown = 120,	duration = 20,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Avenging Wrath
			[1044] = {cooldown = 25,	duration = 8,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 5}, --Blessing of Freedom
			[1022] = {cooldown = 300,	duration = 10,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 3, shareid = 1022}, --Blessing of Protection
			[6940] = {cooldown = 120,	duration = 12,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 3}, --Blessing of Sacrifice
			[204018] = {cooldown = 180,	duration = 10,	specs = {66},				talent = false,	charges = 1,	class = "PALADIN",	type = 3, shareid = 1022}, --Blessing of Spellwarding
			[115750] = {cooldown = 90,	duration = 6,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 8}, --Blinding Light
			[231895] = {cooldown = 120,	duration = 25,	specs = {70},				talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Crusade
			[498] = {cooldown = 60,	duration = 8,	specs = {65},				talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Divine Protection
			[403876] = {cooldown = 60,	duration = 8,	specs = {65},				talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Divine Protection Retribution
			[642] = {cooldown = 300,	duration = 8,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Divine Shield
			[205191] = {cooldown = 60,	duration = 10,	specs = {70},				talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Eye for an Eye
			[86659] = {cooldown = 300,	duration = 8,	specs = {66},				talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Guardian of Ancient Kings
			[853] = {cooldown = 60,	duration = 6,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 8}, --Hammer of Justice
			[105809] = {cooldown = 90,	duration = 20,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Holy Avenger
			[633] = {cooldown = 600,	duration = 0,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 3}, --Lay on Hands
			[327193] = {cooldown = 90,	duration = 15,	specs = {66},				talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Moment of Glory
			[152262] = {cooldown = 45,	duration = 15,	specs = {65, 66, 70},	talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Seraphim
			[184662] = {cooldown = 120,	duration = 15,	specs = {70},				talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Shield of Vengeance
			--[384376] = {cooldown = 0,	duration = 0,	specs = {},			talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Avenging Wrath (different spellId)
			--[384442] = {cooldown = 0,	duration = 0,	specs = {},			talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Avenging Wrath: Might (doesn't have a use, it maybe change the spellId)
			[375576] = {cooldown = 60,	duration = 0,	specs = {66, 65, 70},			talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Divine Toll
			--[343527] = {cooldown = 1 min cooldown,	duration = 0,	specs = {},			talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Execution Sentence
			[343721] = {cooldown = 60,	duration = 8,	specs = {70},			talent = false,	charges = 1,	class = "PALADIN",	type = 1}, --Final Reckoning
			--[391054] = {cooldown = 10 min cooldown,	duration = 0,	specs = {},			talent = false,	charges = 1,	class = "PALADIN",	type = 5}, --Intercession (battle ress)
			[20066] = {cooldown = 15,	duration = 0,	specs = {},			talent = false,	charges = 1,	class = "PALADIN",	type = 8}, --Repentance
			[4987] = {cooldown = 8,	duration = 0,		specs = {65},				talent = false,	charges = 1,	class = "PALADIN",	type = 7}, --Cleanse
			[213644] = {cooldown = 8,	duration = 0,	specs = {66,70},			talent = false,	charges = 1,	class = "PALADIN",	type = 7}, --Cleanse Toxins
			[389539] = {cooldown = 120,	duration = 20,	specs = {66},			talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Sentinel
			[31935] = {cooldown = 13,	duration = 0,	specs = {66},			talent = false,	charges = 1,	class = "PALADIN",	type = 6}, --Avenger's Shield
			[387174] = {cooldown = 60,	duration = 9,	specs = {66},			talent = false,	charges = 1,	class = "PALADIN",	type = 2}, --Eye of Tyr

			--~warrior
			-- 71 - Arms
			-- 72 - Fury
			-- 73 - Protection
			[107574] = {cooldown = 90,	duration = 20,	specs = {71, 73},			talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Avatar
			[227847] = {cooldown = 90,	duration = 5,	specs = {71},				talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Bladestorm
			[46924] = {cooldown = 60,	duration = 4,	specs = {72},				talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Bladestorm
			[118038] = {cooldown = 180,	duration = 8,	specs = {71},				talent = false,	charges = 1,	class = "WARRIOR",	type = 2}, --Die by the Sword
			[184364] = {cooldown = 120,	duration = 8,	specs = {72},				talent = false,	charges = 1,	class = "WARRIOR",	type = 2}, --Enraged Regeneration
			[5246] = {cooldown = 90,	duration = 8,	specs = {71, 72, 73},		talent = false,	charges = 1,	class = "WARRIOR",	type = 8}, --Intimidating Shout
			[12975] = {cooldown = 180,	duration = 15,	specs = {73},				talent = false,	charges = 1,	class = "WARRIOR",	type = 2}, --Last Stand
			[97462] = {cooldown = 180,	duration = 10,	specs = {71, 72, 73},		talent = false,	charges = 1,	class = "WARRIOR",	type = 4}, --Rallying Cry
			[152277] = {cooldown = 60,	duration = 6,	specs = {71},				talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Ravager
			[228920] = {cooldown = 60,	duration = 6,	specs = {73},				talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Ravager
			[1719] = {cooldown = 90,	duration = 10,	specs = {72},				talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Recklessness
			[64382] = {cooldown = 180,	duration = 0,	specs = {71, 72, 73},		talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Shattering Throw
			[871] = {cooldown = 8,	duration = 240,		specs = {73},				talent = false,	charges = 1,	class = "WARRIOR",	type = 2}, --Shield Wall
			[383762] = {cooldown = 180,	duration = 0,	specs = {71, 72, 73},		talent = false,	charges = 1,	class = "WARRIOR",	type = 2}, --Bitter Immunity
			[1161] = {cooldown = 120,	duration = 0,	specs = {73},				talent = false,	charges = 1,	class = "WARRIOR",	type = 5}, --Challenging Shout
			[376079] = {cooldown = 90,	duration = 4,	specs = {},					talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Spear of Bastion
			[392966] = {cooldown = 90, 	duration = 20,	specs = {73},				talent = false,	charges = 1,	class = "WARRIOR",	type = 2}, --Spell Block
			[384318] = {cooldown = 90,	duration = 0,	specs = {71, 72, 73},		talent = false,	charges = 1,	class = "WARRIOR",	type = 1}, --Thunderous Roar
			[46968] = {cooldown = 40,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "WARRIOR",	type = 8}, --Shockwave
			[107570] = {cooldown = 30,	duration = 4,	specs = {},					talent = false,	charges = 1,	class = "WARRIOR",	type = 8}, --Storm Bolt
			[23920] = {cooldown = 25, duration = 0, 	specs = {}, 				talent = false,	charges = 1,	class = "WARRIOR",	type = 5}, --Spell Refleciton
			[385060] = {cooldown = 45, duration = 0, 	specs = {}, 				talent = false,	charges = 1,	class = "WARRIOR",	type = 5}, --Odyn's Fury (can remove root with Avatar)
			[3411] = {cooldown = 30, duration = 6, 		specs = {73}, 				talent = false,	charges = 1,	class = "WARRIOR",	type = 3}, --Intervene
			[386071] = {cooldown = 90, duration = 6, 	specs = {73}, 				talent = false,	charges = 1,	class = "WARRIOR",	type = 8}, --Disrupting Shout
			[385952] = {cooldown = 45, duration = 4, 	specs = {73}, 				talent = false,	charges = 1,	class = "WARRIOR",	type = 5}, --Shield Charge
			[1160] = {cooldown = 45, duration = 8, 		specs = {73}, 				talent = false,	charges = 1,	class = "WARRIOR",	type = 2}, --Demoralizing Shout

			--~warlock
			-- 265 - Affliction
			-- 266 - Demonology
			-- 267 - Destruction
			[108416] = {cooldown = 60,	duration = 20,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 2}, --Dark Pact
			[113858] = {cooldown = 120,	duration = 20,	specs = {267},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Dark Soul: Instability
			[113860] = {cooldown = 120,	duration = 20,	specs = {265},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Dark Soul: Misery
			[267171] = {cooldown = 60,	duration = 0,	specs = {266},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Demonic Strength
			[333889] = {cooldown = 180,	duration = 15,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 5}, --Fel Domination
			[111898] = {cooldown = 120,	duration = 15,	specs = {266},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Grimoire: Felguard
			[5484] = {cooldown = 40,	duration = 20,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 8}, --Howl of Terror
			[267217] = {cooldown = 180,	duration = 20,	specs = {266},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Nether Portal
			[30283] = {cooldown = 60,	duration = 3,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 8}, --Shadowfury
			[205180] = {cooldown = 180,	duration = 20,	specs = {265},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Summon Darkglare
			[265187] = {cooldown = 90,	duration = 15,	specs = {266},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Summon Demonic Tyrant
			[1122] = {cooldown = 180,	duration = 30,	specs = {267},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Summon Infernal
			[104773] = {cooldown = 180,	duration = 8,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 2}, --Unending Resolve
			[48020] = {cooldown = 30,	duration = 0,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 5}, --Demonic Circle: Teleport
			[386997] = {cooldown = 60,	duration = 8,	specs = {265},				talent = false,	charges = 1,	class = "WARLOCK",	type = 1}, --Soul Rot
			[6789] = {cooldown = 45,	duration = 0,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 8}, --Mortal Coil
			[89808] = {cooldown = 15,	duration = 0,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 7, pet = 416}, --Singe Magic
			[132411] = {cooldown = 15,	duration = 0,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 7,}, --Singe Magic (sacrifice)
			[17767] = {cooldown = 120,	duration = 20,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 2, pet = 1860}, --Shadow Bulwark
			[132413] = {cooldown = 120,	duration = 20,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 2,}, --Shadow Bulwark (sacrifice)
			[6358] = {cooldown = 30,	duration = 30,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 8, pet = 184600}, --Seduction
			[261589] = {cooldown = 30,	duration = 30,	specs = {265, 266, 267},	talent = false,	charges = 1,	class = "WARLOCK",	type = 8}, --Seduction (Sacrifice)

			--~shaman
			-- 262 - Elemental
			-- 263 - Enchancment
			-- 264 - Restoration
			[108281] = {cooldown = 120,	duration = 10,	specs = {262, 263},			talent = false,	charges = 1,	class = "SHAMAN",	type = 4}, --Ancestral Guidance
			[207399] = {cooldown = 240,	duration = 30,	specs = {264},				talent = false,	charges = 1,	class = "SHAMAN",	type = 4}, --Ancestral Protection Totem
			[114051] = {cooldown = 180,	duration = 15,	specs = {263},				talent = false,	charges = 1,	class = "SHAMAN",	type = 1}, --Ascendance
			[114050] = {cooldown = 180,	duration = 15,	specs = {262},				talent = false,	charges = 1,	class = "SHAMAN",	type = 1}, --Ascendance
			[114052] = {cooldown = 180,	duration = 15,	specs = {264},				talent = false,	charges = 1,	class = "SHAMAN",	type = 4}, --Ascendance
			[108271] = {cooldown = 90,	duration = 8,	specs = {262, 263, 264},	talent = false,	charges = 1,	class = "SHAMAN",	type = 2}, --Astral Shift
			[198103] = {cooldown = 300,	duration = 60,	specs = {262, 263, 264},	talent = false,	charges = 1,	class = "SHAMAN",	type = 2}, --Earth Elemental
			[51533] = {cooldown = 120,	duration = 15,	specs = {263},				talent = false,	charges = 1,	class = "SHAMAN",	type = 1}, --Feral Spirit
			[198067] = {cooldown = 150,	duration = 30,	specs = {262},				talent = false,	charges = 1,	class = "SHAMAN",	type = 1}, --Fire Elemental
			[108280] = {cooldown = 180,	duration = 10,	specs = {264},				talent = false,	charges = 1,	class = "SHAMAN",	type = 4}, --Healing Tide Totem
			[16191] = {cooldown = 180,	duration = 8,	specs = {264},				talent = false,	charges = 1,	class = "SHAMAN",	type = 5}, --Mana Tide Totem
			[98008] = {cooldown = 180,	duration = 6,	specs = {264},				talent = false,	charges = 1,	class = "SHAMAN",	type = 4}, --Spirit Link Totem
			[192249] = {cooldown = 150,	duration = 30,	specs = {262},				talent = false,	charges = 1,	class = "SHAMAN",	type = 1}, --Storm Elemental
			[8143] = {cooldown = 60,	duration = 10,	specs = {262, 263, 264},	talent = false,	charges = 1,	class = "SHAMAN",	type = 5}, --Tremor Totem
			[192077] = {cooldown = 120,	duration = 15,	specs = {262, 263, 264},	talent = false,	charges = 1,	class = "SHAMAN",	type = 5}, --Wind Rush Totem
			[198838] = {cooldown = 60,	duration = 15,	specs = {264},				talent = false,	charges = 1,	class = "SHAMAN",	type = 4}, --Earthen Wall Totem
			[383017] = {cooldown = 30,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "SHAMAN",	type = 4}, --Stoneskin Totem
			[192058] = {cooldown = 60,	duration = 0,	specs = {262, 263, 264},	talent = false,	charges = 1,	class = "SHAMAN",	type = 8}, --Capacitor Totem
			[51485] = {cooldown = 60,	duration = 20,	specs = {262, 263, 264},	talent = false,	charges = 1,	class = "SHAMAN",	type = 8}, --Earthgrab Totem
			[51514] = {cooldown = 30,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "SHAMAN",	type = 8}, --Hex
			[51490] = {cooldown = 30,   duration = 5,   specs = {262, 263, 264},    talent = false, charges = 1,    class = "SHAMAN",   type = 8}, --Thunderstorm
			[383009] = {cooldown = 60,   duration = 0,   specs = {264}, 		   	talent = false, charges = 1,    class = "SHAMAN",   type = 1}, --Stormkeeper (resto)
			[191634] = {cooldown = 60,   duration = 0,   specs = {262},    			talent = false, charges = 2,    class = "SHAMAN",   type = 1}, --Stormkeeper (Ele)
			[77130] = {cooldown = 8,   duration = 0,   specs = {264},    			talent = false, charges = 1,    class = "SHAMAN",   type = 7}, --Purify Spirit
			[51886] = {cooldown = 8,   duration = 0,   specs = {263,262},    		talent = false, charges = 1,    class = "SHAMAN",   type = 7}, --Cleanse Spirit
			[2484] = {cooldown = 30,   duration = 20,   specs = {262, 263, 264},   	talent = false, charges = 1,    class = "SHAMAN",   type = 8}, --Earthbind Totem
			[79206] = {cooldown = 120,   duration = 15,   specs = {262, 263, 264},  talent = false, charges = 1,    class = "SHAMAN",   type = 5}, --Spiritwalker's Grace
			[383013] = {cooldown = 45,   duration = 6,   specs = {262, 263, 264},  	talent = false, charges = 1,    class = "SHAMAN",   type = 7}, --Poison Cleansing Totem
			[305483] = {cooldown = 45,   duration = 5,   specs = {262, 263, 264},  	talent = false, charges = 1,    class = "SHAMAN",   type = 8}, --Lightning Lasso
			[197214] = {cooldown = 40,   duration = 2,   specs = {262},  			talent = false, charges = 1,    class = "SHAMAN",   type = 8}, --Sundering

			--~monk
			-- 268 - Brewmaster
			-- 269 - Windwalker
			-- 270 - Restoration
			[115399] = {cooldown = 120,	duration = 0,	specs = {268},				talent = false,	charges = 1,	class = "MONK",	type = 2}, --Black Ox Brew
			[122278] = {cooldown = 120,	duration = 10,	specs = {268, 269, 270},	talent = false,	charges = 1,	class = "MONK",	type = 2}, --Dampen Harm
			[122783] = {cooldown = 90,	duration = 6,	specs = {269, 270},			talent = false,	charges = 1,	class = "MONK",	type = 2}, --Diffuse Magic
			[243435] = {cooldown = 90,	duration = 15,	specs = {269, 270},			talent = false,	charges = 1,	class = "MONK",	type = 2}, --Fortifying Brew
			[115203] = {cooldown = 420,	duration = 15,	specs = {268},				talent = false,	charges = 1,	class = "MONK",	type = 2}, --Fortifying Brew
			[132578] = {cooldown = 180,	duration = 25,	specs = {268},				talent = false,	charges = 1,	class = "MONK",	type = 1}, --Invoke Niuzao, the Black Ox
			[123904] = {cooldown = 120,	duration = 24,	specs = {269},				talent = false,	charges = 1,	class = "MONK",	type = 1}, --Invoke Xuen, the White Tiger
			[322118] = {cooldown = 180,	duration = 25,	specs = {270},				talent = false,	charges = 1,	class = "MONK",	type = 4}, --Invoke Yu'lon, the Jade Serpent
			[325197] = {cooldown = 180,	duration = 25,	specs = {270},				talent = false,	charges = 1,	class = "MONK",	type = 4}, --Invoke Chi-Ji, the Red Crane
			[119381] = {cooldown = 50,	duration = 3,	specs = {268, 269, 270},	talent = false,	charges = 1,	class = "MONK",	type = 8}, --Leg Sweep
			[116849] = {cooldown = 120,	duration = 12,	specs = {270},				talent = false,	charges = 1,	class = "MONK",	type = 3}, --Life Cocoon
			[197908] = {cooldown = 90,	duration = 10,	specs = {270},				talent = false,	charges = 1,	class = "MONK",	type = 5}, --Mana Tea
			[115310] = {cooldown = 180,	duration = 0,	specs = {270},				talent = false,	charges = 1,	class = "MONK",	type = 4}, --Revival
			[388615] = {cooldown = 180,	duration = 0,	specs = {270},				talent = false,	charges = 1,	class = "MONK",	type = 4}, --Restoral
			[116844] = {cooldown = 45,	duration = 5,	specs = {268, 269, 270},	talent = false,	charges = 1,	class = "MONK",	type = 8}, --Ring of Peace
			[152173] = {cooldown = 90,	duration = 12,	specs = {269},				talent = false,	charges = 1,	class = "MONK",	type = 1}, --Serenity
			[137639] = {cooldown = 90,	duration = 15,	specs = {269},				talent = false,	charges = 1,	class = "MONK",	type = 1}, --Storm, Earth, and Fire
			[115080] = {cooldown = 180,	duration = 0,	specs = {268, 269, 270},	talent = false,	charges = 1,	class = "MONK",	type = 1}, --Touch of Death
			[122470] = {cooldown = 90,	duration = 6,	specs = {269},				talent = false,	charges = 1,	class = "MONK",	type = 2}, --Touch of Karma
			[115176] = {cooldown = 300,	duration = 8,	specs = {268},				talent = false,	charges = 1,	class = "MONK",	type = 2}, --Zen Meditation
			[388686] = {cooldown = 120,	duration = 30,	specs = {268, 269, 270},	talent = false,	charges = 1,	class = "MONK",	type = 1}, --Summon White Tiger Statue
			--[322109] = {cooldown = 180,	duration = 0,	specs = {268, 269, 270},	talent = false,	charges = 1,	class = "MONK",	type = 1}, --Touch of Death
			[116841] = {cooldown = 30,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "MONK",	type = 5}, --Tiger's Lust
			[386276] = {cooldown = 60,	duration = 10,	specs = {268, 269},			talent = false,	charges = 1,	class = "MONK",	type = 5}, --Bonedust Brew
			[115450] = {cooldown = 8,	duration = 0,	specs = {270},				talent = false,	charges = 1,	class = "MONK",	type = 7}, --Detox (healer)
			[218164] = {cooldown = 8,	duration = 0,	specs = {269,268},			talent = false,	charges = 1,	class = "MONK",	type = 7}, --Detox (DPS/Tank)
			[325153] = {cooldown = 60,	duration = 3,	specs = {268},				talent = false,	charges = 1,	class = "MONK",	type = 2}, --Exploding Keg
			[115078] = {cooldown = 45,	duration = 60,	specs = {268, 269, 270},	talent = false,	charges = 1,	class = "MONK",	type = 8}, --Paralysis


			--~hunter
			-- 253 - Beast Mastery
			-- 254 - Marksmenship
			-- 255 - Survival
			[186257] = {cooldown = 144,	duration = 14,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 2}, --Aspect of the Cheetah
			[186289] = {cooldown = 72,	duration = 15,	specs = {255},				talent = false,	charges = 1,	class = "HUNTER",	type = 1}, --Aspect of the Eagle
			[186265] = {cooldown = 180,	duration = 8,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 2}, --Aspect of the Turtle
			[193530] = {cooldown = 120,	duration = 20,	specs = {253},				talent = false,	charges = 1,	class = "HUNTER",	type = 1}, --Aspect of the Wild
			[19574] = {cooldown = 90,	duration = 12,	specs = {253},				talent = false,	charges = 1,	class = "HUNTER",	type = 1}, --Bestial Wrath
			[109248] = {cooldown = 45,	duration = 10,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 8}, --Binding Shot
			[199483] = {cooldown = 60,	duration = 60,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 2}, --Camouflage
			[266779] = {cooldown = 120,	duration = 20,	specs = {255},				talent = false,	charges = 1,	class = "HUNTER",	type = 1}, --Coordinated Assault
			[109304] = {cooldown = 120,	duration = 8, 	durationSpellId = 385540,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 2}, --Exhilaration
			[187650] = {cooldown = 25,	duration = 60,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 8}, --Freezing Trap
			[19577] = {cooldown = 60,	duration = 5,	specs = {253, 255},			talent = false,	charges = 1,	class = "HUNTER",	type = 8}, --Intimidation
			[201430] = {cooldown = 180,	duration = 12,	specs = {253},				talent = false,	charges = 1,	class = "HUNTER",	type = 1}, --Stampede
			--[281195] = {cooldown = 180,	duration = 6,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 2}, --Survival of the Fittest
			[288613] = {cooldown = 180,	duration = 15,	specs = {254},				talent = false,	charges = 1,	class = "HUNTER",	type = 1}, --Trueshot
			[264735] = {cooldown = 180,	duration = 0,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 2}, --Survival of the Fittest
			[187698] = {cooldown = 30,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "HUNTER",	type = 8}, --Tar Trap
			[392060] = {cooldown = 60,	duration = 3,	specs = {},					talent = false,	charges = 1,	class = "HUNTER",	type = 8}, --Wailing Arrow
			[781] =	{cooldown = 20,	duration = 0,		specs = {},					talent = false,	charges = 1,	class = "HUNTER",	type = 5}, --Disengage
			[5384] = {cooldown = 30, duration = 0, 		specs = {}, 				talent = false, charges = 1, 	class = "HUNTER", 	type = 5}, --Feign Death
			[186387] = {cooldown = 30, duration = 6, 	specs = {},		 			talent = false, charges = 1, 	class = "HUNTER", 	type = 8}, --Bursting Shot
			[236776] = {cooldown = 40, duration = 0, 	specs = {253, 254, 255},	talent = false, charges = 1, 	class = "HUNTER", 	type = 8}, --High Explosive Trap
			[272682] = {cooldown = 45,	duration = 4,	specs = {253, 254, 255},	talent = false,	charges = 1,	class = "HUNTER",	type = 7}, --Master's Call
			[359844] = {cooldown = 120, duration = 20,  specs = {253}, 				talent = true, charges = 1, 	class = "HUNTER", 	type = 1}, -- Call of the Wild
			--Boar nil 62305 Master's Call
			--Boar Tiranaa 54216 Master's Call
			--Tiranaa Tiranaa 272682 Master's Call

			--~druid
			-- 102 - Balance
			-- 103 - Feral
			-- 104 - Guardian
			-- 105 - Restoration
			[22812] = {cooldown = 60,	duration = 12,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 2}, --Barkskin
			[106951] = {cooldown = 180,	duration = 15,	specs = {103, 104},			talent = false,	charges = 1,	class = "DRUID",	type = 1}, --Berserk
			[194223] = {cooldown = 180,	duration = 20,	specs = {102},				talent = false,	charges = 1,	class = "DRUID",	type = 1}, --Celestial Alignment
			[391528] = {cooldown = 120,	duration = 4,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 1}, --Convoke the Spirits
			[197721] = {cooldown = 90,	duration = 8,	specs = {105},				talent = false,	charges = 1,	class = "DRUID",	type = 4}, --Flourish
			[319454] = {cooldown = 300,	duration = 45,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 1}, --Heart of the Wild
			[99] = {cooldown = 30,	duration = 3,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 8}, --Incapacitating Roar
			[102543] = {cooldown = 30,	duration = 180,	specs = {103},				talent = false,	charges = 1,	class = "DRUID",	type = 1}, --Incarnation: Avatar of Ashamane
			[102560] = {cooldown = 180,	duration = 30,	specs = {102},				talent = false,	charges = 1,	class = "DRUID",	type = 1}, --Incarnation: Chosen of Elune
			[102558] = {cooldown = 180,	duration = 30,	specs = {104},				talent = false,	charges = 1,	class = "DRUID",	type = 2}, --Incarnation: Guardian of Ursoc
			[33891] = {cooldown = 180,	duration = 30,	specs = {105},				talent = false,	charges = 1,	class = "DRUID",	type = 4}, --Incarnation: Tree of Life
			[29166] = {cooldown = 180,	duration = 12,	specs = {102, 105},			talent = false,	charges = 1,	class = "DRUID",	type = 5}, --Innervate
			[102342] = {cooldown = 60,	duration = 12,	specs = {105},				talent = false,	charges = 1,	class = "DRUID",	type = 3}, --Ironbark
			[203651] = {cooldown = 60,	duration = 0,	specs = {105},				talent = false,	charges = 1,	class = "DRUID",	type = 3}, --Overgrowth
			[20484] = {cooldown = 600,	duration = 0,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 5}, --Rebirth
			[108238] = {cooldown = 90,	duration = 0,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 2}, --Renewal
			[61336] = {cooldown = 120,	duration = 6,	specs = {103, 104},			talent = false,	charges = 1,	class = "DRUID",	type = 2}, --Survival Instincts
			[740] = {cooldown = 180,	duration = 8,	specs = {105},				talent = false,	charges = 1,	class = "DRUID",	type = 4}, --Tranquility
			[132469] = {cooldown = 30,	duration = 0,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 8}, --Typhoon
			[102793] = {cooldown = 60,	duration = 10,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 8}, --Ursol's Vortex
			[124974] = {cooldown = 90,	duration = 0,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 4}, --Nature's Vigil
			[77761] = {cooldown = 120,	duration = 8,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 5}, --Stampeding Roar
			--[106898] = {cooldown = 120,	duration = 8,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 5}, --Stampeding Roar
			--[77764] = {cooldown = 120,	duration = 8,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 5}, --Stampeding Roar
			[5211] = {cooldown = 60,	duration = 0,	specs = {},			talent = false,	charges = 1,	class = "DRUID",	type = 8}, --Mighty Bash
			[22570] = {cooldown = 20,	duration = 5,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 8}, --Maim
			[88423] = {cooldown = 8,	duration = 0,	specs = {105},				talent = false,	charges = 1,	class = "DRUID",	type = 7}, --Nature's Cure
			[2782] = {cooldown = 8,	duration = 0,		specs = {102, 103, 104},	talent = false,	charges = 1,	class = "DRUID",	type = 7}, --Remove Corruption
			[102359] = {cooldown = 30,	duration = 30,	specs = {102, 103, 104, 105},	talent = false,	charges = 1,	class = "DRUID",	type = 8}, --Mass Entanglement
			[205636] = {cooldown = 60,	duration = 10,	specs = {102},				talent = false,	charges = 1,	class = "DRUID",	type = 5}, --Force of Nature
			[200851] = {cooldown = 60,	duration = 10,	specs = {104},				talent = false,	charges = 1,	class = "DRUID",	type = 2}, --Rage of the Sleeper

			--~death knight
			-- 252 - Unholy
			-- 251 - Frost
			-- 252 - Blood
			[383269] = {cooldown = 120,	duration = 12,	specs = {250, 251, 252},	talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Abomination Limb
			[48707] = {cooldown = 60,	duration = 10,	specs = {250, 251, 252},	talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 2}, --Anti-Magic Shell
			[51052] = {cooldown = 120,	duration = 10,	specs = {250, 251, 252},	talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 4}, --Anti-Magic Zone
			[275699] = {cooldown = 90,	duration = 15,	specs = {252},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Apocalypse
			[42650] = {cooldown = 480,	duration = 30,	specs = {252},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Army of the Dead
			[221562] = {cooldown = 45,	duration = 5,	specs = {250},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 8}, --Asphyxiate
			[108194] = {cooldown = 45,	duration = 4,	specs = {251, 252},			talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 8}, --Asphyxiate
			[207167] = {cooldown = 60,	duration = 5,	specs = {251},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 8}, --Blinding Sleet
			[152279] = {cooldown = 120,	duration = 5,	specs = {251},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Breath of Sindragosa
			[49028] = {cooldown = 120,	duration = 8,	specs = {250},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Dancing Rune Weapon
			[48743] = {cooldown = 120,	duration = 15,	specs = {250, 251, 252},	talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 2}, --Death Pact
			[47568] = {cooldown = 120,	duration = 20,	specs = {251},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Empower Rune Weapon
			[279302] = {cooldown = 120,	duration = 10,	specs = {251},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Frostwyrm's Fury
			[108199] = {cooldown = 120,	duration = 0,	specs = {250},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 5}, --Gorefiend's Grasp
			[48792] = {cooldown = 120,	duration = 8,	specs = {250, 251, 252},	talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 2}, --Icebound Fortitude
			[46585] = {cooldown = 120,	duration = 60,	specs = {250, 251, 252},	talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Raise Dead
			[49206] = {cooldown = 180,	duration = 30,	specs = {252},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Summon Gargoyle
			[207349] = {cooldown = 180,	duration = 30,	specs = {252},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Summon Dark Arbiter (replaces Gargoyle)
			[219809] = {cooldown = 60,	duration = 8,	specs = {250},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 2}, --Tombstone
			[207289] = {cooldown = 78,	duration = 12,	specs = {252},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Unholy Assault
			[55233] = {cooldown = 90,	duration = 10,	specs = {250},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 2}, --Vampiric Blood
			[212552] = {cooldown = 60,	duration = 4,	specs = {250, 251, 252},	talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 2}, --Wraith Walk
			[49576] = {cooldown = 25,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 8}, --Death Grip
			[49039] = {cooldown = 120,	duration = 10,	specs = {250, 251, 252},	talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 2}, --Lichborne
			[194679] = {cooldown = 25,	duration = 4,	specs = {252},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 2}, --Rune Tap
			[194844] = {cooldown = 60,	duration = 0,	specs = {251},				talent = false,	charges = 1,	class = "DEATHKNIGHT",	type = 1}, --Bonestorm

			--~demon hunter
			-- 577 - Havoc
			-- 581 - Vengance
			[198589] = {cooldown = 60,	duration = 10,	specs = {577},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 2}, --Blur
			[320341] = {cooldown = 90,	duration = 0,	specs = {581},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 2}, --Bulk Extraction
			[179057] = {cooldown = 60,	duration = 2,	specs = {577},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 8}, --Chaos Nova
			[196718] = {cooldown = 180,	duration = 8,	specs = {577},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 4}, --Darkness
			[211881] = {cooldown = 30,	duration = 4,	specs = {577},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 5}, --Fel Eruption
			[204021] = {cooldown = 60,	duration = 10,	specs = {581},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 2}, --Fiery Brand
			[217832] = {cooldown = 45,	duration = 0,	specs = {577, 581},			talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 8}, --Imprison
			[187827] = {cooldown = 180,	duration = 15,	specs = {581},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 2}, --Metamorphosis
			[191427] = {cooldown = 240,	duration = 30,	specs = {577},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 1}, --Metamorphosis
			[196555] = {cooldown = 120,	duration = 5,	specs = {577},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 2}, --Netherwalk
			[202138] = {cooldown = 90,	duration = 6,	specs = {581},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 8}, --Sigil of Chains
			[207684] = {cooldown = 90,	duration = 12,	specs = {581},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 8}, --Sigil of Misery
			[202137] = {cooldown = 60,	duration = 8,	specs = {581},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 6}, --Sigil of Silence
			[263648] = {cooldown = 30,	duration = 12,	specs = {581},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 2}, --Soul Barrier
			[188501] = {cooldown = 30,	duration = 10,	specs = {577, 581},			talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 5}, --Spectral Sight
			[370965] = {cooldown = 90,	duration = 0,	specs = {577, 581},			talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 1}, --The Hunt
			[212084] = {cooldown = 60,	duration = 2,	specs = {581},				talent = false,	charges = 1,	class = "DEMONHUNTER",	type = 2}, --Fel Devastation
			[203720] = {cooldown = 20,	duration = 6,	specs = {581},				talent = false,	charges = 2,	class = "DEMONHUNTER",	type = 2}, --Demon Spikes

			--~mage
			-- 62 - Arcane
			-- 63 - Fire
			-- 64 - Frost
			[365350] = {cooldown = 90,	duration = 15,	specs = {62},				talent = false,	charges = 1,	class = "MAGE",	type = 1}, --Arcane Surge
			[12042] = {cooldown = 90,	duration = 10,	specs = {62},				talent = false,	charges = 1,	class = "MAGE",	type = 1}, --Arcane Power
			[235313] = {cooldown = 25,	duration = 60,	specs = {63},				talent = false,	charges = 1,	class = "MAGE",	type = 5}, --Blazing Barrier
			[235219] = {cooldown = 300,	duration = 0,	specs = {64},				talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Cold Snap
			[190319] = {cooldown = 120,	duration = 10,	specs = {63},				talent = false,	charges = 1,	class = "MAGE",	type = 1}, --Combustion
			[12051] = {cooldown = 90,	duration = 6,	specs = {62},				talent = false,	charges = 1,	class = "MAGE",	type = 1}, --Evocation
			--[110960] = {cooldown = 120,	duration = 20,	specs = {62},				talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Greater Invisibility | 110959
			[110959] = {cooldown = 120,	duration = 20,	specs = {62},				talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Greater Invisibility | 110959
			[11426] = {cooldown = 25,	duration = 60,	specs = {64},				talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Ice Barrier
			[45438] = {cooldown = 240,	duration = 10,	specs = {62, 63, 64},		talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Ice Block
			[414658] = {cooldown = 180,	duration = 6,	specs = {62, 63, 64},		talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Ice Cold
			[12472] = {cooldown = 180,	duration = 20,	specs = {64},				talent = false,	charges = 1,	class = "MAGE",	type = 1}, --Icy Veins
			[66] = {cooldown = 300,		duration = 20,	specs = {63, 64},			talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Invisibility
			[383121] = {cooldown = 60,	duration = 0,	specs = {62, 63, 64},		talent = false,	charges = 1,	class = "MAGE",	type = 8}, --Mass Polymorph
			[55342] = {cooldown = 120,	duration = 40,	specs = {62, 63, 64},		talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Mirror Image
			[235450] = {cooldown = 25,	duration = 60,	specs = {62},				talent = false,	charges = 1,	class = "MAGE",	type = 5}, --Prismatic Barrier
			[205021] = {cooldown = 78,	duration = 5,	specs = {64},				talent = false,	charges = 1,	class = "MAGE",	type = 1}, --Ray of Frost
			[113724] = {cooldown = 45,	duration = 10,	specs = {62, 63, 64},		talent = false,	charges = 1,	class = "MAGE",	type = 8}, --Ring of Frost
			[31661] = {cooldown = 45,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "MAGE",	type = 8}, --Dragon's Breath
			[1953] = {cooldown = 15,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "MAGE",	type = 5}, --Blink
			[157981] = {cooldown = 30,	duration = 6,	specs = {63},				talent = false,	charges = 1,	class = "MAGE",	type = 8}, --Blast Wave
			[475] = {cooldown = 8,	duration = 0,	specs = {63, 64, 62},			talent = false,	charges = 1,	class = "MAGE",	type = 7}, --Remove Curse
			[122] = {cooldown = 30,	duration = 6,	specs = {63, 64, 62},			talent = false,	charges = 1,	class = "MAGE",	type = 8}, --Frost Nova
			[157980] = {cooldown = 25,	duration = 0,	specs = {62},				talent = false,	charges = 1,	class = "MAGE",	type = 8}, --Supernova
			[414660] = {cooldown = 120,	duration = 60,	specs = {63, 64, 62},		talent = false,	charges = 1,	class = "MAGE",	type = 4}, --Mass Barrier
			[414664] = {cooldown = 300,	duration = 12,	specs = {63, 64, 62},		talent = false,	charges = 1,	class = "MAGE",	type = 5}, --Mass Invisibility (only out of combat)

			-- This needs more work to actually function
			--[342245] = {cooldown = 60,	duration = 0,	specs = {},					talent = false,	charges = 1,	class = "MAGE",	type = 2}, --Alter Time

			--~priest
			-- 256 - Discipline
			-- 257 - Holy
			-- 258 - Shadow
			[200183] = {cooldown = 120,	duration = 20,	specs = {257},				talent = false,	charges = 1,	class = "PRIEST",	type = 2}, --Apotheosis
			[19236] = {cooldown = 90,	duration = 10,	specs = {256, 257, 258},	talent = false,	charges = 1,	class = "PRIEST",	type = 2}, --Desperate Prayer
			[47585] = {cooldown = 120,	duration = 6,	specs = {258},				talent = false,	charges = 1,	class = "PRIEST",	type = 2}, --Dispersion
			[64843] = {cooldown = 180,	duration = 8,	specs = {257},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Divine Hymn
			[246287] = {cooldown = 90,	duration = 0,	specs = {256},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Evangelism
			[47788] = {cooldown = 180,	duration = 10,	specs = {257},				talent = false,	charges = 1,	class = "PRIEST",	type = 3}, --Guardian Spirit
			[265202] = {cooldown = 720,	duration = 0,	specs = {257},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Holy Word: Salvation
			[372835] = {cooldown = 180,	duration = 0,	specs = {257},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Lightwell
			[73325] = {cooldown = 90,	duration = 0,	specs = {256, 257, 258},	talent = false,	charges = 1,	class = "PRIEST",	type = 5}, --Leap of Faith
			[271466] = {cooldown = 180,	duration = 10,	specs = {256},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Luminous Barrier
			[205369] = {cooldown = 30,	duration = 6,	specs = {258},				talent = false,	charges = 1,	class = "PRIEST",	type = 5}, --Mind Bomb
			[200174] = {cooldown = 60,	duration = 15,	specs = {258},				talent = false,	charges = 1,	class = "PRIEST",	type = 1}, --Mindbender spec 258
			[123040] = {cooldown = 60,	duration = 12,	specs = {256},				talent = false,	charges = 1,	class = "PRIEST",	type = 1}, --Mindbender spec 256
			[33206] = {cooldown = 180,	duration = 8,	specs = {256},				talent = false,	charges = 1,	class = "PRIEST",	type = 3}, --Pain Suppression
			[10060] = {cooldown = 120,	duration = 20,	specs = {256, 257, 258},	talent = false,	charges = 1,	class = "PRIEST",	type = 1}, --Power Infusion
			[62618] = {cooldown = 180,	duration = 10,	specs = {256},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Power Word: Barrier
			[64044] = {cooldown = 45,	duration = 4,	specs = {258},				talent = false,	charges = 1,	class = "PRIEST",	type = 8}, --Psychic Horror
			[8122] = {cooldown = 60,	duration = 8,	specs = {256, 257, 258},	talent = false,	charges = 1,	class = "PRIEST",	type = 8}, --Psychic Scream
			[47536] = {cooldown = 90,	duration = 10,	specs = {256},				talent = false,	charges = 1,	class = "PRIEST",	type = 5}, --Rapture
			[34433] = {cooldown = 180,	duration = 15,	specs = {256, 258},			talent = false,	charges = 1,	class = "PRIEST",	type = 1}, --Shadowfiend
			[109964] = {cooldown = 60,	duration = 12,	specs = {256},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Spirit Shell
			[64901] = {cooldown = 300,	duration = 6,	specs = {257},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Symbol of Hope
			[15286] = {cooldown = 120,	duration = 15,	specs = {258},				talent = false,	charges = 1,	class = "PRIEST",	type = 4}, --Vampiric Embrace
			[228260] = {cooldown = 90,	duration = 15,	specs = {258},				talent = false,	charges = 1,	class = "PRIEST",	type = 1}, --Void Eruption
			[32375] = {cooldown = 45,	duration= 0,	specs = {},					talent = false,	charges = 1,	class = "PRIEST",	type = 7}, --Mass Dispell
			[586] = {cooldown = 30,	duration= 0,	specs = {},					talent = false,	charges = 1,	class = "PRIEST",	type = 2}, --Fade
			[108968] = {cooldown = 5*60,duration = 0,	specs = {},					talent = false,	charges = 1,	class = "PRIEST",	type = 3}, --Void Shift
			[391109] = {cooldown = 60,	duration = 20,	specs = {258},				talent = false,	charges = 1,	class = "PRIEST",	type = 1}, --Dark Ascension
			[527] = {cooldown = 8,	duration = 0,	specs = {256,257},				talent = false,	charges = 1,	class = "PRIEST",	type = 7}, --Purify 
			[213634] = {cooldown = 8,	duration = 0,	specs = {258},				talent = false,	charges = 1,	class = "PRIEST",	type = 7}, --Purify Disease 
			[108920] = {cooldown = 60,	duration = 20,	specs = {256, 257, 258},	talent = false,	charges = 1,	class = "PRIEST",	type = 8}, --Void Tendrils


			--~rogue
			-- 259 - Assasination
			-- 260 - Outlaw
			-- 261 - Subtlety
			[13750] = {cooldown = 180,	duration = 20,	specs = {260},				talent = false,	charges = 1,	class = "ROGUE",	type = 1}, --Adrenaline Rush
			[2094] = {cooldown = 120,	duration = 60,	specs = {259, 260, 261},	talent = false,	charges = 1,	class = "ROGUE",	type = 8}, --Blind
			[31224] = {cooldown = 120,	duration = 5,	specs = {259, 260, 261},	talent = false,	charges = 1,	class = "ROGUE",	type = 2}, --Cloak of Shadows
			[185311] = {cooldown = 30,	duration = 15,	specs = {259, 260, 261},	talent = false,	charges = 1,	class = "ROGUE",	type = 2}, --Crimson Vial
			[343142] = {cooldown = 90,	duration = 10,	specs = {260},				talent = false,	charges = 1,	class = "ROGUE",	type = 1}, --Dreadblades
			[5277] = {cooldown = 120,	duration = 10,	specs = {259, 260, 261},	talent = false,	charges = 1,	class = "ROGUE",	type = 2}, --Evasion
			[51690] = {cooldown = 120,	duration = 2,	specs = {260},				talent = false,	charges = 1,	class = "ROGUE",	type = 1}, --Killing Spree
			[199754] = {cooldown = 120,	duration = 10,	specs = {260},				talent = false,	charges = 1,	class = "ROGUE",	type = 2}, --Riposte
			[121471] = {cooldown = 180,	duration = 20,	specs = {261},				talent = false,	charges = 1,	class = "ROGUE",	type = 1}, --Shadow Blades
			[114018] = {cooldown = 360,	duration = 15,	specs = {259, 260, 261},	talent = false,	charges = 1,	class = "ROGUE",	type = 5}, --Shroud of Concealment
			[1856] = {cooldown = 120,	duration = 3,	specs = {259, 260, 261},	talent = false,	charges = 1,	class = "ROGUE",	type = 1}, --Vanish
			[79140] = {cooldown = 120,	duration = 20,	specs = {259},				talent = false,	charges = 1,	class = "ROGUE",	type = 1}, --Vendetta
			[1776] = {cooldown = 20,	duration = 0,	specs = {},			talent = false,	charges = 1,	class = "ROGUE",	type = 8}, --Gouge
			[408] = {cooldown = 20,		duration = 0,	specs = {},			talent = false,	charges = 1,	class = "ROGUE",	type = 8}, --Kidney Shot
			[1966] = {cooldown = 15,	duration = 0,	specs = {},			talent = false,	charges = 1,	class = "ROGUE",	type = 2}, --Feint
			[384631] = {cooldown = 90,	duration = 12,	specs = {261},				talent = false,	charges = 1,	class = "ROGUE",	type = 1}, --Flagellation
			[277925] = {cooldown = 60,	duration = 4,	specs = {261},				talent = false,	charges = 1,	class = "ROGUE",	type = 1}, --Shuriken Tornado
			[360194] = {cooldown = 120, duration = 16,  specs = {259}, 				talent = true, charges = 1, 	class = "ROGUE", 	type = 1}, -- Deathmark

			--~evoker
			-- 1467 - Devastation
			-- 1468 - Preservation
			-- 1473 - Augmentation
			[374251] = {cooldown = 60,	duration = 0,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 7}, --Cauterizing Flame
			[365585] = {cooldown = 8,	duration = 0,	specs = {1467},					talent = false,	charges = 1,	class = "EVOKER",	type = 7}, --Expunge
			[360823] = {cooldown = 8,	duration = 0,	specs = {1468},					talent = false,	charges = 1,	class = "EVOKER",	type = 7}, --Naturalize
			[357210] = {cooldown = 120,	duration = 0,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 1}, --Deep Breath
			[375087] = {cooldown = 120,	duration = 0,	specs = {1467},					talent = false,	charges = 1,	class = "EVOKER",	type = 1}, --Dragonrage
			[359816] = {cooldown = 120,	duration = 15,	specs = {1468},					talent = false,	charges = 1,	class = "EVOKER",	type = 4}, --Dream Flight
			[370960] = {cooldown = 180,	duration = 4.4,	specs = {1468},					talent = false,	charges = 1,	class = "EVOKER",	type = 2}, --Emerald Communion

			[358385] = {cooldown = 90,	duration = 0,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 8}, --Landslide
			[372048] = {cooldown = 120,	duration = 10,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 8}, --Oppressing Roar
			[363916] = {cooldown = 90,	duration = 12,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 2}, --Obsidian Scales
			[374348] = {cooldown = 90,	duration = 8,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 2}, --Renewing Blaze

			[370665] = {cooldown = 60,	duration = 0,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 5}, --Rescue
			[363534] = {cooldown = 240,	duration = 5,	specs = {1468},					talent = false,	charges = 1,	class = "EVOKER",	type = 4}, --Rewind
			[370537] = {cooldown = 90,	duration = 30,	specs = {1468},				talent = false,	charges = 1,	class = "EVOKER",	type = 4}, --Stasis
			[357170] = {cooldown = 60,	duration = 8,	specs = {1468},					talent = false,	charges = 1,	class = "EVOKER",	type = 3}, --Time Dilation
			[374968] = {cooldown = 120,	duration = 10,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 5}, --Time Spiral
			[374227] = {cooldown = 120,	duration = 8,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 4}, --Zephyr
			[360806] = {cooldown = 15,	duration = 20,	specs = {1467, 1468},			talent = false,	charges = 1,	class = "EVOKER",	type = 8}, --Sleep Walk

			[360827] = {cooldown = 30,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 3}, --Blistering Scales
			[395152] = {cooldown = 30,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 1}, --Ebon Might
			--[395160] = {cooldown = 0,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 0}, --Eruption
			[396286] = {cooldown = 40,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 1}, --Upheaval
			--[403208] = {cooldown = 0,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 0}, --Draconic Attunements
			--[403264] = {cooldown = 3,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 0}, --Black Attunement
			--[403265] = {cooldown = 3,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 0}, --Bronze Attunement
			[403631] = {cooldown = 120,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 1}, --Breath of Eons
			[404977] = {cooldown = 180,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 1}, --Time Skip
			[406732] = {cooldown = 120,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 3}, --Spatial Paradox
			[408233] = {cooldown = 60,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 5}, --Bestow Weyrnstone
			[409311] = {cooldown = 12,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 1}, --Prescience
			--[412710] = {cooldown = 0,	duration = 0,	specs = {1473},			talent = false,	charges = 1,	class = "EVOKER",	type = 0}, --Timelessness
		}

		--list of all crowd control spells
		--it is not transmitted to other clients
		LIB_OPEN_RAID_CROWDCONTROL = {
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
			[200196] = {cooldown = 60,	class = "PRIEST"}, --Holy Word: Chastise
			[9484] = {cooldown = 0,		class = "PRIEST"}, --Shackle Undead
			[114404] = {cooldown = 20,	class = "PRIEST"}, --Void Tendril's Grasp
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
			LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {
				[44461] = {name = GetSpellInfo(44461) .. " (" .. L["STRING_EXPLOSION"] .. ")"}, --Living Bomb (explosion)
				[59638] = {name = GetSpellInfo(59638) .. " (" .. L["STRING_MIRROR_IMAGE"] .. ")"}, --Mirror Image's Frost Bolt (mage)
				[88082] = {name = GetSpellInfo(88082) .. " (" .. L["STRING_MIRROR_IMAGE"] .. ")"}, --Mirror Image's Fireball (mage)
				[94472] = {name = GetSpellInfo(94472) .. " (" .. L["STRING_CRITICAL_ONLY"] .. ")"}, --Atonement critical hit (priest)
				[33778] = {name = GetSpellInfo(33778) .. " (" .. L["STRING_BLOOM"] .. ")"}, --lifebloom (bloom)
				[121414] = {name = GetSpellInfo(121414) .. " (" .. L["STRING_GLAIVE"] .. " #1)"}, --glaive toss (hunter)
				[120761] = {name = GetSpellInfo(120761) .. " (" .. L["STRING_GLAIVE"] .. " #2)"}, --glaive toss (hunter)
				[212739] = {name = GetSpellInfo(212739) .. " (" .. L["STRING_MAINTARGET"] .. ")"}, --DK Epidemic
				[215969] = {name = GetSpellInfo(215969) .. " (" .. L["STRING_AOE"] .. ")"}, --DK Epidemic
				[70890] = {name = GetSpellInfo(70890) .. " (" .. L["STRING_SHADOW"] .. ")"}, --DK Scourge Strike
				[55090] = {name = GetSpellInfo(55090) .. " (" .. L["STRING_PHYSICAL"] .. ")"}, --DK Scourge Strike
				[49184] = {name = GetSpellInfo(49184) .. " (" .. L["STRING_MAINTARGET"] .. ")"}, --DK Howling Blast
				[237680] = {name = GetSpellInfo(237680) .. " (" .. L["STRING_AOE"] .. ")"}, --DK Howling Blast
				[228649] = {name = GetSpellInfo(228649) .. " (" .. L["STRING_PASSIVE"] .. ")"}, --Monk Mistweaver Blackout kick - Passive Teachings of the Monastery
				[339538] = {name = GetSpellInfo(224266) .. " (" .. L["STRING_TEMPLAR_VINDCATION"] .. ")"}, --
				[343355] = {name = GetSpellInfo(343355)  .. " (" .. L["STRING_PROC"] .. ")"}, --shadow priest's void bold proc

				--shadowlands trinkets
				[345020] = {name = GetSpellInfo(345020) .. " ("  .. L["STRING_TRINKET"] .. ")"},
			}
		end

		--interrupt list using proxy from cooldown list
		--this list should be expansion and combatlog safe
		LIB_OPEN_RAID_SPELL_INTERRUPT = {
			[6552] = LIB_OPEN_RAID_COOLDOWNS_INFO[6552], --Pummel

			[2139] = LIB_OPEN_RAID_COOLDOWNS_INFO[2139], --Counterspell

			[15487] = LIB_OPEN_RAID_COOLDOWNS_INFO[15487], --Silence (shadow) Last Word Talent to reduce cooldown in 15 seconds

			[1766] = LIB_OPEN_RAID_COOLDOWNS_INFO[1766], --Kick

			[96231] = LIB_OPEN_RAID_COOLDOWNS_INFO[96231], --Rebuke (protection and retribution)

			[116705] = LIB_OPEN_RAID_COOLDOWNS_INFO[116705], --Spear Hand Strike (brewmaster and windwalker)

			[57994] = LIB_OPEN_RAID_COOLDOWNS_INFO[57994], --Wind Shear

			[47528] = LIB_OPEN_RAID_COOLDOWNS_INFO[47528], --Mind Freeze

			[106839] = LIB_OPEN_RAID_COOLDOWNS_INFO[106839], --Skull Bash (feral, guardian)
			[78675] = LIB_OPEN_RAID_COOLDOWNS_INFO[78675], --Solar Beam (balance)

			[147362] = LIB_OPEN_RAID_COOLDOWNS_INFO[147362], --Counter Shot (beast mastery, marksmanship)
			[187707] = LIB_OPEN_RAID_COOLDOWNS_INFO[187707], --Muzzle (survival)

			[183752] = LIB_OPEN_RAID_COOLDOWNS_INFO[183752], --Disrupt

			[19647] = LIB_OPEN_RAID_COOLDOWNS_INFO[19647], --Spell Lock (pet felhunter ability)
			[89766] = LIB_OPEN_RAID_COOLDOWNS_INFO[89766], --Axe Toss (pet felguard ability)
		}

		--override list of spells with more than one effect, example: multiple types of polymorph
		LIB_OPEN_RAID_SPELL_DEFAULT_IDS = {
			--stampeding roar (druid)
			[106898] = 77761,
			[77764] = 77761, --"Uncategorized" on wowhead, need to test if still exists
			--spell lock (warlock pet)
			[119910] = 19647, --"Uncategorized" on wowhead
			[132409] = 19647, --"Uncategorized" on wowhead
			--[115781] = 19647, --optical blast used by old talent observer, still a thing?
			--[251523] = 19647, --wowhead list this spell as sibling spell
			--[251922] = 19647, --wowhead list this spell as sibling spell
			--axe toss (warlock pet)
			[119905] = 89808, -- Singe Magic (warlock Imp) cast by Command Demon
			[119907] = 17767, -- Shadow Bulwark (warlock Voidwalker) cast by Command Demon
			[119914] = 89766, --"Uncategorized" on wowhead
			[347008] = 89766, --"Uncategorized" on wowhead
			--hex (shaman)
			[210873] = 51514, --Compy
			[211004] = 51514, --Spider
			[211010] = 51514, --Snake
			[211015] = 51514, --Cockroach
			[269352] = 51514, --Skeletal Hatchling
			[277778] = 51514, --Zandalari Tendonripper
			[277784] = 51514, --Wicker Mongrel
			[309328] = 51514, --Living Honey
			--typhoon
			--[61391] = 132469,
			--metamorphosis
			[191427] = 200166,
			--187827 vengeance need to test these spellIds
			--191427 havoc
			[370564] = 370537, -- Evoker Stasis
			--[414658] = 45438, -- Ice Block with the talent Ice Cold
			--[414658] = 45438, -- Ice Block with the talent IceCold
		}
		LIB_OPEN_RAID_MULTI_OVERRIDE_SPELLS = {
			[106898] = {106898,77764,77761},
			[77764] = {106898,77764,77761},
			[77761] = {106898,77764,77761},
			[232633] = {155145, 28730, 25046, 80483, 129597, 69179, 50613, 202719, 232633}, --Arcane Torrent
		}

		LIB_OPEN_RAID_SPECID_TO_CLASSID = {
			[577] = 12,
			[581] = 12,

			[250] = 6,
			[251] = 6,
			[252] = 6,

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

			[268] = 10,
			[269] = 10,
			[270] = 10,

			[1467] = 13,
			[1468] = 13,
			[1473] = 13,
		}

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


--[=[ code used to build the crowd control list
for spellId, spellInfo in pairs(LIB_OPEN_RAID_COOLDOWNS_INFO) do
	if (spellInfo.type == 8) then
		LIB_OPEN_RAID_CROWDCONTROL[spellId] = spellInfo
	end
end

LIB_OPEN_RAID_CROWDCONTROL = {}

C_Timer.After(5, function()
	--for debugging, compares which crowd control spells are in the details framework that are not in the lib
	local notInLib = {}

	local DF_CrowdControlSpells = DetailsFramework.CrowdControlSpells
	for spellId, className in pairs(DF_CrowdControlSpells) do
		local spellName = GetSpellInfo(spellId)
		if (spellName) then -- and not LIB_OPEN_RAID_CROWDCONTROL[spellId]
			local spellCooldown = math.floor(GetSpellBaseCooldown(spellId)/1000)
			notInLib[#notInLib+1] = {spellId, spellName, spellCooldown, className}
		end
	end

	table.sort(notInLib, function(t1, t2) return t1[4] < t2[4] end)

	--make a string like the one above
	local result = ""
	for i = 1, #notInLib do
		local spellId, spellName, spellCooldown, className = unpack(notInLib[i])
		result = result .. "["..spellId.."] =\t{cooldown = "..spellCooldown..",\t\tclass = \"" .. className .. "\"}, --" .. spellName .. "\n"
	end

	dumpt(result)
end)
--]=]