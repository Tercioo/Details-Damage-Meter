
do
	local Details = 	_G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
	local addonName, Details222 = ...
	local _
	local rawget = rawget
	local rawset = rawset
	local setmetatable = setmetatable
	local unpack = unpack
	local tinsert = table.insert
	local tremove = table.remove
	local C_Timer = C_Timer

	--is this a timewalking exp?
	local bIsClassicWow = DetailsFramework.IsClassicWow()
    local bIsWarWow = DetailsFramework.IsWarWow()

    local GetSpellInfo = Details222.GetSpellInfo

	--default spell cache container
	Details.spellcache = {}
	local unknowSpell = {Loc ["STRING_UNKNOWSPELL"], _, "Interface\\Icons\\Ability_Druid_Eclipse"}

	local allSpellNames

	--check if this is running in classic wow and build a cache with spell names poiting to their icons
	if (bIsClassicWow) then
		allSpellNames = {}
		local maxSpellIdInClassic = 60000

		for i = 1, maxSpellIdInClassic do
			local spellName, _, spellIcon = GetSpellInfo(i)
			if spellName and spellIcon and spellIcon ~= 136235 and not allSpellNames[spellName] then
				allSpellNames[spellName] = spellIcon
			end
		end
	end

	local GetSpellInfoClassic = function(spell)
		local spellName, _, spellIcon

		if (spell == 0) then
			spellName = ATTACK or "It's Blizzard Fault!"
			spellIcon = [[Interface\ICONS\INV_Sword_04]]

		elseif (spell == "!Melee" or spell == 1) then
			spellName = ATTACK or "It's Blizzard Fault!"
			spellIcon = [[Interface\ICONS\INV_Sword_04]]

		elseif (spell == "!Autoshot" or spell == 2) then
			spellName = Loc ["STRING_AUTOSHOT"]
			spellIcon = [[Interface\ICONS\INV_Weapon_Bow_07]]

		else
			spellName, _, spellIcon = GetSpellInfo(spell)
		end

		if (not spellName) then
			return spell, _, (allSpellNames[spell] or [[Interface\ICONS\INV_Sword_04]])
		end

		return spellName, _, (allSpellNames[spell] or spellIcon)
	end

	--reset spell cache, called from the loaddata.lua and when the segments container get cleared
	function Details:ClearSpellCache()
		Details.spellcache = setmetatable({},
			{__index = function(spellCache, key)
				if (key) then
					do
						--check if the spell is already in the cache, if so, return it
						local spellInfo = rawget(spellCache, key)
						if (spellInfo) then
							return spellInfo
						end
					end

					local spellInfo
					if (bIsClassicWow) then
						spellInfo = {GetSpellInfoClassic(key)}
					else
						spellInfo = {GetSpellInfo(key)}
					end

					spellCache[key] = spellInfo
					return spellInfo
				else
					return unknowSpell
				end
			end}
		)

		--built-in overwrites
		for spellId, spellTable in pairs(Details.SpellOverwrite) do
			local spellName, _, spellIcon = GetSpellInfo(spellId)
			rawset(Details.spellcache, spellId, {spellTable.name or spellName, 1, spellTable.icon or spellIcon})
		end

		--user overwrites
		-- [1] spellid [2] spellname [3] spellicon
		for index, spellTable in ipairs(Details.savedCustomSpells) do
			rawset(Details.spellcache, spellTable[1], {spellTable[2], 1, spellTable[3]})
		end
	end

	local lightOfTheMartyr_Name, _, lightOfTheMartyr_Icon = GetSpellInfo(196917)
	lightOfTheMartyr_Name = lightOfTheMartyr_Name or "Deprecated Spell - Light of the Martyr"
	lightOfTheMartyr_Icon = lightOfTheMartyr_Icon or ""

	---@type table<number, customspellinfo>
	local defaultSpellCustomization = {}

	---@type table<number, customiteminfo>
	local customItemList = {}
	Details222.CustomItemList = customItemList

	local iconSize = 14
	local coords = {0.14, 0.86, 0.14, 0.86}

	---@param itemId number
	---@return string
	local formatTextForItem = function(itemId)
		local result = ""

		local itemIcon = C_Item.GetItemIconByID(itemId)
		local itemName = C_Item.GetItemNameByID(itemId)

		if (itemIcon and itemName) then
			--limit the amount of characters of the item name
			if (GetLocale() == "zhCN" or GetLocale() == "zhTW" or GetLocale() == "koKR") then
				if (#itemName > 56) then
					itemName = string.sub(itemName, 1, 56)
				end
			else
				if (#itemName > 20) then
					itemName = string.sub(itemName, 1, 20)
				end
			end
			result = "" .. CreateTextureMarkup(itemIcon, iconSize, iconSize, iconSize, iconSize, unpack(coords)) .. " " .. itemName .. ""
		end

		return result
	end

	if (DetailsFramework.IsClassicWow()) then
		defaultSpellCustomization = {
			[1] = {name = Loc ["STRING_MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
			[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
			[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
			[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
			[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
			[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
			[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
			[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},
		}

	elseif (DetailsFramework.IsTBCWow()) then
		defaultSpellCustomization = {
			[1] = {name = _G["MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
			[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
			[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
			[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
			[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
			[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
			[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
			[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},
		}

	elseif (DetailsFramework.IsWotLKWow()) then
		defaultSpellCustomization = {
			[1] = {name = _G["MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
			[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
			[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
			[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
			[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
			[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
			[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
			[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},
		}

	elseif (DetailsFramework.IsCataWow()) then
		defaultSpellCustomization = {
			[1] = {name = _G["MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
			[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
			[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
			[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
			[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
			[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
			[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
			[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},
		}

	elseif (DetailsFramework.IsShadowlandsWow()) then
		defaultSpellCustomization = {
			[1] = {name = Loc ["STRING_MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
			[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
			[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
			[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
			[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
			[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
			[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
			[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},
			[98021] = {name = Loc ["STRING_SPIRIT_LINK_TOTEM"]},
			[108271] = {name = GetSpellInfo(108271), icon = "Interface\\Addons\\Details\\images\\icon_astral_shift"},
			[196917] = {name = lightOfTheMartyr_Name .. " (" .. Loc ["STRING_DAMAGE"] .. ")", icon = lightOfTheMartyr_Icon},
			[77535] = {name = GetSpellInfo(77535), icon = "Interface\\Addons\\Details\\images\\icon_blood_shield"},

			--bfa trinkets (deprecated)
			[278155] = {name = GetSpellInfo(278155) .. " (Trinket)"}, --[Twitching Tentacle of Xalzaix]
			[279664] = {name = GetSpellInfo(279664) .. " (Trinket)"}, --[Vanquished Tendril of G'huun]
			[278227] = {name = GetSpellInfo(278227) .. " (Trinket)"}, --[T'zane's Barkspines]
			[278383] = {name = GetSpellInfo(278383) .. " (Trinket)"}, --[Azurethos' Singed Plumage]
			[278862] = {name = GetSpellInfo(278862) .. " (Trinket)"}, --[Drust-Runed Icicle]
			[278359] = {name = GetSpellInfo(278359) .. " (Trinket)"}, --[Doom's Hatred]
			[278812] = {name = GetSpellInfo(278812) .. " (Trinket)"}, --[Lion's Grace]
			[270827] = {name = GetSpellInfo(270827) .. " (Trinket)"}, --[Vessel of Skittering Shadows]
			[271071] = {name = GetSpellInfo(271071) .. " (Trinket)"}, --[Conch of Dark Whispers]
			[270925] = {name = GetSpellInfo(270925) .. " (Trinket)"}, --[Hadal's Nautilus]
			[271115] = {name = GetSpellInfo(271115) .. " (Trinket)"}, --[Ignition Mage's Fuse]
			[271462] = {name = GetSpellInfo(271462) .. " (Trinket)"}, --[Rotcrusted Voodoo Doll]
			[271465] = {name = GetSpellInfo(271465) .. " (Trinket)"}, --[Rotcrusted Voodoo Doll]
			[268998] = {name = GetSpellInfo(268998) .. " (Trinket)"}, --[Balefire Branch]
			[271671] = {name = GetSpellInfo(271671) .. " (Trinket)"}, --[Lady Waycrest's Music Box]
			[277179] = {name = GetSpellInfo(277179) .. " (Trinket)"}, --[Dread Gladiator's Medallion]
			[277187] = {name = GetSpellInfo(277187) .. " (Trinket)"}, --[Dread Gladiator's Emblem]
			[277181] = {name = GetSpellInfo(277181) .. " (Trinket)"}, --[Dread Gladiator's Insignia]
			[277185] = {name = GetSpellInfo(277185) .. " (Trinket)"}, --[Dread Gladiator's Badge]
			[278057] = {name = GetSpellInfo(278057) .. " (Trinket)"}, --[Vigilant's Bloodshaper]
		}

	elseif (DetailsFramework.IsTWWWow()) then
		defaultSpellCustomization = {
			[1] = {name = Loc ["STRING_MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
			[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
			[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
			[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
			[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
			[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
			[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
			[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},

			--v11 all good:
			[98021] = {name = Loc ["STRING_SPIRIT_LINK_TOTEM"]},
			[108271] = {name = GetSpellInfo(108271), icon = "Interface\\Addons\\Details\\images\\icon_astral_shift"},
			[196917] = {name = lightOfTheMartyr_Name .. " (" .. Loc ["STRING_DAMAGE"] .. ")", icon = lightOfTheMartyr_Icon},
			[77535] = {name = GetSpellInfo(77535), icon = "Interface\\Addons\\Details\\images\\icon_blood_shield"},
			[395296] = {name = GetSpellInfo(395296) .. " (on your self)", icon = "Interface\\Addons\\Details\\images\\ebon_might"},
			[424428] = {name = (GetSpellInfo(424428) or "none") .. " (4P)", icon = "Interface\\Addons\\Details\\images\\spells\\eruption_tier4.jpg", defaultName = GetSpellInfo(424428), breakdownCanStack = true}, --augmentation 4pc tier 10.2
			[422779] = {name = (GetSpellInfo(422779) or "none") .. " (4P)", icon = "Interface\\Addons\\Details\\images\\spells\\burning_frenzy_tier4.jpg", defaultName = GetSpellInfo(422779)}, --feral 4pc tier 10.2
		}

		--item data v11 with labels
		customItemList[443539] = {itemId = 219313, isPassive = false, onUse = true, castId = 450561, defaultName = GetSpellInfo(427113), aura1 = 443539, aura2 = 450551} --[Mereldar's Toll]
		customItemList[443124] = {itemId = 212454, isPassive = false, onUse = true, castId = 443124, defaultName = GetSpellInfo(443124), aura1 = 446067, aura2 = nil} --[Mad Queen's Mandate]
		customItemList[451866] = {itemId = 212451, isPassive = true, onUse = true, castId = 445619, defaultName = GetSpellInfo(451866), aura1 = 451895, aura2 = 445619} --[Aberrant Spellforge] 451895 = passive
		customItemList[451292] = {itemId = 219317, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(451292), aura1 = 451303, aura2 = nil} --[Harvester's Edict]
		customItemList[452310] = {itemId = 219295, isSummon = true, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(452310), aura1 = nil, aura2 = nil} --[Sigil of Algari Concordance]
		customItemList[450921] = {itemId = 219303, isPassive = false, onUse = true, castId = 443415, defaultName = GetSpellInfo(450921), aura1 = 451248, aura2 = nil} --[High Speaker's Accretion]
		customItemList[452032] = {itemId = 219307, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(452032), aura1 = 451369, aura2 = nil} --[Remnant of Darkness]
		customItemList[449386] = {itemId = 219299, isSummon = false, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(449386), aura1 = nil, aura2 = nil} --[Synergistic Brewterializer] | damage
		customItemList[449490] = {itemId = 219299, isSummon = true, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(449490), aura1 = nil, aura2 = nil} --[Synergistic Brewterializer] | summon
		customItemList[443531] = {itemId = 219308, isPassive = false, onUse = true, castId = 443531, defaultName = GetSpellInfo(443531), aura1 = 443531, aura2 = nil} --[Signet of the Priory] | aura
		customItemList[449954] = {itemId = 221023, isPassive = true, onUse = false, castId = 449946, defaultName = GetSpellInfo(449954), aura1 = 449954, aura2 = nil} --[Treacherous Transmitter] | aura | when get a dose, use castId
		customItemList[449275] = {itemId = 219312, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(449275), aura1 = 449275, aura2 = nil} --[Empowering Crystal of Anub'ikkaj]
		customItemList[452229] = {itemId = 219314, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(452229), aura1 = 452226, aura2 = nil} --[Ara-Kara Sacbrood]
		customItemList[451367] = {itemId = 219305, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(451367), aura1 = 451367, aura2 = nil} --[Carved Blazikon Wax]
		customItemList[452337] = {itemId = 219321, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(452337), aura1 = 452337, aura2 = nil} --[Cirral Concoctory]
		customItemList[449254] = {itemId = 219296, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(449254), aura1 = 449254, aura2 = nil} --[Entropic Skardyn Core]
		customItemList[455910] = {itemId = 221032, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(455910), aura1 = 456652, aura2 = nil} --[Voltaic Stormcaller]
		customItemList[457928] = {itemId = 225578, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(457928), aura1 = 457925, aura2 = 457928} --[Seal of the Poisoned Pact] ring, first aura: player buff, second aura: dot debuff on enemy
		customItemList[457684] = {itemId = 225577, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(457684), aura1 = 457684, aura2 = nil} --[Sureki Zealot's Insignia] neck
		customItemList[446811] = {itemId = 219301, isPassive = false, onUse = true, castId = 443411, defaultName = GetSpellInfo(446811), aura1 = 450453, aura2 = nil} --[Overclocked Gear-A-Rang Launcher]
		customItemList[449828] = {itemId = 219301, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(449828), nameExtra = "(additional)", aura1 = nil, aura2 = nil} --[Overclocked Gear-A-Rang Launcher] extra attack
		customItemList[450429] = {itemId = 219304, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(450429), aura1 = nil, aura2 = nil} --[Conductor's Wax Whistle]
		customItemList[448909] = {itemId = 219298, isPassive = false, onUse = true, castId = 448904, defaultName = GetSpellInfo(448909), aura1 = nil, aura2 = nil} --[Ravenous Honey Buzzer]
		customItemList[448892] = {itemId = 219294, isPassive = false, onUse = true, castId = 443337, defaultName = GetSpellInfo(448892), aura1 = nil, aura2 = nil} --[Charged Stormrook Plume]
		customItemList[448669] = {itemId = 212456, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(448669), aura1 = nil, aura2 = nil} --[Void Reaper's Contract]
		customItemList[445434] = {itemId = 212449, isPassive = false, onUse = true, castId = nil, defaultName = GetSpellInfo(445434), aura1 = 447962, aura2 = 445434, aura3 = 447978, aura4 = 448436} --[Sikran's Endless Arsenal] Surekian Flourish
		customItemList[445475] = {itemId = 212449, isPassive = false, onUse = true, castId = nil, defaultName = GetSpellInfo(445475), aura1 = 447962, aura2 = 445434, aura3 = 447978, aura4 = 448436, aura5 = 448433} --[Sikran's Endless Arsenal] Surekian Barrage
		customItemList[455821] = {itemId = 221159, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(455821), aura1 = nil, aura2 = nil} --[Harvester's Interdiction]
		customItemList[457533] = {itemId = 225574, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(457533), aura1 = 457533, aura2 = nil} --[Wings of Shattered Sorrow]
		customItemList[447093] = {itemId = 212450, isPassive = true, onUse = true, castId = 444301, defaultName = GetSpellInfo(447093), aura1 = 444301, aura2 = 447134} --[Swarmlord's Authority]
		customItemList[447471] = {itemId = 212453, isPassive = false, onUse = true, castId = 444489, defaultName = GetSpellInfo(447471), aura1 = 447471, aura2 = nil} --[Skyterror's Corrosive Organ]
		customItemList[444264] = {itemId = 219915, isPassive = false, onUse = true, castId = 444264, defaultName = GetSpellInfo(444264), aura1 = 444264, aura2 = nil} --[Foul Behemoth's Chelicera] damage
		customItemList[446805] = {itemId = 219915, isPassive = false, onUse = true, castId = 444264, defaultName = GetSpellInfo(446805), aura1 = 444264, aura2 = nil} --[Foul Behemoth's Chelicera] heal
		customItemList[451015] = {itemId = 219318, isPassive = false, onUse = true, castId = 443552, defaultName = GetSpellInfo(451015), aura1 = 451011, aura2 = 443552} --[Oppressive Orator's Larynx]
		customItemList[450969] = {itemId = 219316, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(450969), aura1 = 450969, aura2 = nil} --[Ceaseless Swarmgland]
		customItemList[450706] = {itemId = 219309, isPassive = true, onUse = true, castId = 443535, defaultName = GetSpellInfo(450706), aura1 = 450706, aura2 = nil} --[Tome of Light's Devotion]
		customItemList[450696] = {itemId = 219309, isPassive = true, onUse = true, castId = 443535, defaultName = GetSpellInfo(450696), aura1 = 450696, aura2 = nil} --[Tome of Light's Devotion]
		customItemList[450719] = {itemId = 219309, isPassive = true, onUse = true, castId = 443535, defaultName = GetSpellInfo(450719), aura1 = 450719, aura2 = nil} --[Tome of Light's Devotion]
		customItemList[443407] = {itemId = 219300, isPassive = false, onUse = true, castId = 443407, defaultName = GetSpellInfo(443407), aura1 = 443407, aura2 = nil} --[Skarmorak Shard]
		customItemList[451568] = {itemId = 219315, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(451568), aura1 = 451568, aura2 = nil} --[Refracting Aggression Module]
		customItemList[443381] = {itemId = 219297, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(443381), aura1 = 443381, aura2 = nil} --[Cinderbrew Stein]
		customItemList[450960] = {itemId = 219311, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(450960), aura1 = 450962, aura2 = nil} --[Void Pactstone] death effect has the same spellId --start|SPELL_DAMAGE|450960|"Void Pulse"|end

		--11.2
		customItemList[1234219] = {itemId = 242867, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(1234219), aura1 = nil, aura2 = nil} --[Automatic Footbomb Dispenser]
		customItemList[1245376] = {itemId = 246939, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(1245376), aura1 = 1245376, aura2 = nil} --[Essence-Hunter's Eyeglass]
		customItemList[1242875] = {itemId = 242399, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(1242875), aura1 = nil, aura2 = nil} --[Screams of a Forgotten Sky]
		customItemList[1239221] = {itemId = 242392, isPassive = true, onUse = false, castId = nil, defaultName = GetSpellInfo(1239221), aura1 = 1239221, aura2 = nil} --[Diamantine Voidcore]
		customItemList[1244448] = {itemId = 242403, isPassive = false, onUse = true, castId = 1244448, defaultName = GetSpellInfo(1244448), aura1 = nil, aura2 = nil} --
		customItemList[343393] = {itemId = 178826, isPassive = false, onUse = true, castId = 343393, defaultName = GetSpellInfo(343393), aura1 = nil, aura2 = nil} --[Sunblood Amethyst]



		--customItemList[] = {itemId = , isPassive = , onUse = , castId = , defaultName = GetSpellInfo(), aura1 = , aura2 = } --

		--[Ovinax's Mercurial Egg] couldn't detect the buffId

	elseif (DetailsFramework.IsPandaWow()) then
		defaultSpellCustomization = {
			[1] = {name = Loc ["STRING_MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
			[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
			[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
			[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
			[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
			[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
			[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
			[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},
		}

	else --retail (dragonflight)
		defaultSpellCustomization = {
			[1] = {name = Loc ["STRING_MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
			[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
			[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
			[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
			[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
			[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
			[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
			[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},
			[98021] = {name = Loc ["STRING_SPIRIT_LINK_TOTEM"]},
			[108271] = {name = GetSpellInfo(108271), icon = "Interface\\Addons\\Details\\images\\icon_astral_shift"},
			[196917] = {name = lightOfTheMartyr_Name .. " (" .. Loc ["STRING_DAMAGE"] .. ")", icon = lightOfTheMartyr_Icon},
			[77535] = {name = GetSpellInfo(77535), icon = "Interface\\Addons\\Details\\images\\icon_blood_shield"},
			[395296] = {name = GetSpellInfo(395296) .. " (on your self)", icon = "Interface\\Addons\\Details\\images\\ebon_might"},

			[424428] = {name = (GetSpellInfo(424428) or "none") .. " (4P)", icon = "Interface\\Addons\\Details\\images\\spells\\eruption_tier4.jpg", defaultName = GetSpellInfo(424428), breakdownCanStack = true}, --augmentation 4pc tier 10.2
			[422779] = {name = (GetSpellInfo(422779) or "none") .. " (4P)", icon = "Interface\\Addons\\Details\\images\\spells\\burning_frenzy_tier4.jpg", defaultName = GetSpellInfo(422779)}, --feral 4pc tier 10.2
		}

		customItemList[394453] = {itemId = 195480, isPassive = true} --ring: Seal of Diurna's Chosen
		customItemList[382135] = {itemId = 194308} --trinket: Manic Grieftorch
		customItemList[382058] = {itemId = 194299} --trinket: Decoration of Flame (shield)
		customItemList[382056] = {itemId = 194299} --trinket: Decoration of Flame
		customItemList[382090] = {itemId = 194302} --trinket: Storm-Eater's Boon
		customItemList[381967] = {itemId = 194305} --trinket: Controlled Current Technique
		customItemList[382426] = {itemId = 194309, isPassive = true} --trinket: Spiteful Storm
		customItemList[377455] = {itemId = 194304} --trinket: Iceblood Deathsnare
		customItemList[377451] = {itemId = 194300} --trinket: Conjured Chillglobe
		customItemList[382097] = {itemId = 194303} --trinket: Rumbling Ruby
		customItemList[385903] = {itemId = 193639, isPassive = true} --trinket: Umbrelskul's Fractured Heart
		customItemList[381475] = {itemId = 193769} --trinket: Erupting Spear Fragment
		customItemList[388739] = {itemId = 193660, isPassive = true} --trinket: Idol of Pure Decay
		customItemList[388855] = {itemId = 193678} --trinket: Miniature Singing Stone
		customItemList[388755] = {itemId = 193677, isPassive = true} --trinket: Furious Ragefeather
		customItemList[383934] = {itemId = 193736} --trinket: Water's Beating Heart
		customItemList[214052] = {itemId = 133641, isPassive = true} --trinket: Eye of Skovald
		customItemList[214200] = {itemId = 133646} --trinket: Mote of Sanctification
		customItemList[387036] = {itemId = 193748} --trinket: Kyrakka's Searing Embers (heal)
		customItemList[397376] = {itemId = 193748, isPassive = true} --trinket: Kyrakka's Searing Embers (damage)
		customItemList[214985] = {itemId = 137486} --trinket: Windscar Whetstone
		customItemList[384004] = {itemId = 193815} --trinket: Homeland Raid Horn
		customItemList[377459] = {itemId = 194306} --trinket: All-Totem of the Master Fire Damage
		customItemList[377461] = {itemId = 194306} --trinket: All-Totem of the Master Air Damage
		customItemList[382133] = {itemId = 194306} --trinket: All-Totem of the Master Ice Damage
		customItemList[377458] = {itemId = 194306} --trinket: All-Totem of the Master Earth Damage
		customItemList[408815] = {itemId = 202569} --weapon: Djaruun, Pillar of the Elder Flame
		customItemList[407961] = {itemId = 203996, isPassive = true} --trinket: Igneous Flowstone
		customItemList[408682] = {itemId = 202610} --trinket: Dragonfire Bomb Dispenser
		customItemList[401324] = {itemId = 202617, isPassive = true} --trinket: Elementium Pocket Anvil
		customItemList[401306] = {itemId = 202617} --trinket: Elementium Pocket Anvil (use)
		customItemList[402583] = {itemId = 203963} --trinket: Beacon to the Beyond
		customItemList[384325] = {itemId = 193672, isPassive = true} --trinket: Frenzying Signoll Flare
		customItemList[384290] = {itemId = 193672, isPassive = true} --trinket: Frenzying Signoll Flare (dot)
		customItemList[388948] = {itemId = 193732} --trinket: Globe of Jagged Ice
		customItemList[381760] = {itemId = 193786, isPassive = true} --trinket: Mutated Magmammoth Scale (melee)
		customItemList[389839] = {itemId = 193757, isPassive = true} --trinket: Ruby Whelp Shell
		customItemList[401428] = {itemId = 202615, isPassive = true} --trinket: Vessel of Searing Shadow

		--10.2
		customItemList[426672] = {itemId = 207168, isPassive = true, nameExtra = "(vers)", icon = [[Interface\AddOns\Details\images\spells\spell_druid_bearhug_blackwhite.jpg]]} --trinket: Pip's Emerald Friendship Badge urctos
		customItemList[426674] = {itemId = 207168, isPassive = true, nameExtra = "(*vers*)", icon = 571585} --trinket: Pip's Emerald Friendship Badge urctos
		customItemList[426676] = {itemId = 207168, isPassive = true, nameExtra = "(crit)", icon = [[Interface\AddOns\Details\images\spells\elf_face_right.jpg]]} --trinket: Pip's Emerald Friendship Badge aerwynn
		customItemList[426677] = {itemId = 207168, isPassive = true, nameExtra = "(*crit*)", icon = 2403539} --trinket: Pip's Emerald Friendship Badge aerwynn
		customItemList[426647] = {itemId = 207168, isPassive = true, nameExtra = "(mast)", icon = [[Interface\AddOns\Details\images\spells\lil_dragon_left.jpg]]} --trinket: Pip's Emerald Friendship Badge pip
		customItemList[426648] = {itemId = 207168, isPassive = true, nameExtra = "(*mast*)", icon = 5342919} --trinket: Pip's Emerald Friendship Badge pip

		customItemList[426431] = {itemId = 210494, isPassive = true} --enchant: Incandescent Essence (ranged dps)
		customItemList[426486] = {itemId = 210494, isPassive = true} --enchant: Incandescent Essence (ranged dps)
		customItemList[424965] = {itemId = 207784, isPassive = true} --weapon: Thorncaller Claw
		customItemList[425181] = {itemId = 207784, isPassive = true, nameExtra = "(*aoe*)"} --weapon: Thorncaller Claw
		customItemList[425127] = {itemId = 207783, isPassive = true} --weapon: Cruel Dreamcarver (heal)

		customItemList[423611] = {itemId = 207167, isPassive = true, nameExtra = "*proc*"} --trinket: Ashes of the Embersoul (extra proc)
		customItemList[426553] = {itemId = 208614, isPassive = true} --trinket: Augury of the Primal Flame
		customItemList[426564] = {itemId = 208614, isPassive = true} --trinket: Augury of the Primal Flame (damage)
		customItemList[425154] = {itemId = 207166, isPassive = true} --trinket: Cataclysmic Signet Brand
		customItemList[427037] = {itemId = 207175, isPassive = true} --trinket: Coiled Serpent Idol
		customItemList[421996] = {itemId = 207173, isPassive = true} --trinket: Gift of Ursine Vengeance
		customItemList[421994] = {itemId = 207173, isPassive = true} --trinket: Gift of Ursine Vengeance (buff)
		customItemList[422441] = {itemId = 207169, isPassive = true} --trinket: Branch of the Tormented Ancient (buff)
		customItemList[417458] = {itemId = 207566, isPassive = true} --trinket: Accelerating Sandglass
		customItemList[417452] = {itemId = 207566, isPassive = true} --trinket: Accelerating Sandglass (buff)
		customItemList[214169] = {itemId = 136715, isPassive = true} --trinket: Spiked Counterweight
		customItemList[92174] = {itemId = 133192, isPassive = true} --trinket: Porcelain Crab
		customItemList[429262] = {itemId = 109999, isPassive = true} --trinket: Witherbark's Branch (buff)
		customItemList[418527] = {itemId = 207581, isPassive = true} --trinket: Mirror of Fractured Tomorrows (buff)
		customItemList[214342] = {itemId = 137312, isPassive = true} --trinket: Nightmare Egg Shell
		customItemList[429246] = {itemId = 110004, isPassive = true} --trinket: Coagulated Genesaur Blood
		customItemList[214350] = {itemId = 137306, isPassive = true} --trinket: Oakheart's Gnarled Root
		customItemList[429221] = {itemId = 133201, isPassive = true} --trinket: Sea Star
		customItemList[215270] = {itemId = 136714, isPassive = true} --trinket: Amalgam's Seventh Spine
		customItemList[417534] = {itemId = 207579, isPassive = true} --trinket: Time-Thief's Gambit
		customItemList[270827] = {itemId = 159610, isPassive = true} --trinket: Vessel of Skittering Shadows
		customItemList[271671] = {itemId = 159631, isPassive = true} --trinket: Lady Waycrest's Music Box
		customItemList[215407] = {itemId = 136716, isPassive = true} --trinket: Caged Horror
		customItemList[213786] = {itemId = 137301, isPassive = true} --trinket: Corrupted Starlight

		customItemList[427209] = {itemId = 208616, onUse = true, castId = 427113, defaultName = GetSpellInfo(427113)} --weapon: Dreambinder, Loom of the Great Cycle
		customItemList[427161] = {itemId = 208615, onUse = true, castId = 422956, defaultName = GetSpellInfo(422956)} --trinket: Nymue's Unraveling Spindle
		customItemList[425701] = {itemId = 207174, onUse = true, castId = 422750, defaultName = GetSpellInfo(422750)} --trinket: Fyrakk's Tainted Rageheart
		customItemList[425509] = {itemId = 207169, onUse = true, castId = 422441, defaultName = GetSpellInfo(422441)} --trinket: Branch of the Tormented Ancient
		customItemList[422146] = {itemId = 207172, onUse = true, castId = 422146, defaultName = GetSpellInfo(422146)} --trinket: Belor'relos, the Sunstone
		customItemList[265953] = {itemId = 158319, onUse = true, castId = 265954, defaultName = GetSpellInfo(265953)} --trinket: My'das Talisman
		customItemList[429257] = {itemId = 109999, onUse = true, castId = 429257, defaultName = GetSpellInfo(429257)} --trinket: Witherbark's Branch (no damage)
		customItemList[427430] = {itemId = 207165, onUse = true, castId = 422146, defaultName = GetSpellInfo(422303), nameExtra = "*return*"} --trinket: Bandolier of Twisted Blades
		customItemList[422303] = {itemId = 207165, onUse = true, castId = 422146, defaultName = GetSpellInfo(422303), nameExtra = "*throw*"} --trinket: Bandolier of Twisted Blades
		customItemList[426898] = {itemId = 207167, onUse = true, castId = 423611, nameExtra = "*on use*", defaultName = GetSpellInfo(423611)} --trinket: Ashes of the Embersoul
		customItemList[429271] = {itemId = 110009, onUse = true, castId = 429271, defaultName = GetSpellInfo(429271)} --trinket: Leaf of the Ancient Protectors
		customItemList[429272] = {itemId = 110009, onUse = true, castId = 429271, nameExtra = "(*vers*)", defaultName = GetSpellInfo(429271)} --trinket: Leaf of the Ancient Protectors
		customItemList[433522] = {itemId = 212684, isPassive = true} -- trinket: Umbrelskul's Fractured Heart dot
		customItemList[433549] = {itemId = 212684, isPassive = true} -- trinket: Umbrelskul's Fractured Heart execute

		--11.1
		customItemList[1213434] = {itemId = 234217, onUse = true, castId = 1213432, defaultName = GetSpellInfo(1213434)} -- trinket: Funhouse Lens
		customItemList[1213436] = {itemId = 234218, onUse = true, castId = 1213437, defaultName = GetSpellInfo(1213436)} -- trinket: Goo-blin Grenade
		customItemList[1215195] = {itemId = 234717, onUse = true, castId = 1214941, defaultName = GetSpellInfo(1215195)} -- trinket: Blastmaster3000
		customItemList[1221151] = {itemId = 232543, onUse = true, castId = 1219102, defaultName = GetSpellInfo(1221151)} -- trinket: [Ringing Ritual Mud] damage
		customItemList[1219102] = {itemId = 232543, onUse = true, castId = 1219102, defaultName = GetSpellInfo(1219102)} -- trinket: [Ringing Ritual Mud] aura
		customItemList[1219104] = {itemId = 232542, onUse = true, castId = 1220488, defaultName = GetSpellInfo(1219104)} -- trinket: [Darkfuse Medichopper] aura
		customItemList[471383] = {itemId = 228844, onUse = true, castId = 471383, defaultName = GetSpellInfo(471383)} -- cloak: Test Pilot's Go-Pack
		customItemList[1219299] = {itemId = 235984, onUse = true, castId = 1219294, defaultName = GetSpellInfo(1219299)} -- trinket: Garbagemancer's Last Resort
		customItemList[1219158] = {itemId = 230027, onUse = true, castId = 466681, defaultName = GetSpellInfo(1219158)} -- trinket: [House of Cards]
		customItemList[466681] = {itemId = 230027, onUse = true, castId = 466681, defaultName = GetSpellInfo(466681)} -- trinket: [House of Cards]
		customItemList[472030] = {itemId = 230197, onUse = true, castId = 471059, defaultName = GetSpellInfo(472030)} -- trinket: [Geargrinder's Spare Keys]
		customItemList[300612] = {itemId = 168973, onUse = true, castId = 300612, defaultName = GetSpellInfo(300612)} -- trinket: Enhance Synapses
		customItemList[473147] = {itemId = 230191, onUse = true, castId = 471142, defaultName = GetSpellInfo(473147)} -- trinket: Flarendo's Pilot Light buff
		customItemList[473219] = {itemId = 230191, onUse = true, castId = 471142, defaultName = GetSpellInfo(473219)} -- trinket: Flarendo's Pilot Light damage
		customItemList[443531] = {itemId = 219308, onUse = true, castId = 443531, defaultName = GetSpellInfo(443531)} -- trinket: [Signet of the Priory]
		customItemList[345804] = {itemId = 178809, onUse = true, castId = 345801, defaultName = GetSpellInfo(345804)} -- trinket: [Soulletting Ruby] heal
		customItemList[345805] = {itemId = 178809, onUse = true, castId = 345801, defaultName = GetSpellInfo(345805), nameExtra = "(*crit*)",} -- trinket: [Soulletting Ruby] crit
		customItemList[470675] = {itemId = 232486, onUse = true, castId = 470675, defaultName = GetSpellInfo(470675)} -- trinket: [Noggenfogger Ultimate Deluxe]
		customItemList[1216606] = {itemId = 235359, onUse = true, castId = 1216605, defaultName = GetSpellInfo(1216606)} -- trinket: [Ratfang Toxin]
		customItemList[448892] = {itemId = 219294, onUse = true, castId = 443337, defaultName = GetSpellInfo(448892)} -- trinket: [Charged Stormrook Plume]
		customItemList[448909] = {itemId = 219298, onUse = true, castId = 448904, defaultName = GetSpellInfo(448909)} -- trinket: [Ravenous Honey Buzzer]
		customItemList[345739] = {itemId = 178811, onUse = true, castId = 345739, defaultName = GetSpellInfo(345739)} -- trinket: [Grim Codex]
		customItemList[1219662] = {itemId = 230189, onUse = true, castId = 471212, defaultName = GetSpellInfo(1219662)} -- trinket: [Junkmaestro's Mega Magnet] 
		customItemList[1213760] = {itemId = 234326, onUse = true, castId = 1213760, defaultName = GetSpellInfo(1213760)} -- trinket: [Core Recycling Unit] big heal
		customItemList[1214741] = {itemId = 234326, onUse = true, castId = 1213760, defaultName = GetSpellInfo(1214741)} -- trinket: [Core Recycling Unit] periodic heal
		customItemList[299869] = {itemId = 168965, onUse = true, castId = 299869, defaultName = GetSpellInfo(299869)} -- trinket:[Modular Platinum Plating]
		customItemList[271376] = {itemId = 159611, onUse = true, castId = 271374, defaultName = GetSpellInfo(271376)} -- trinket: [Razdunk's Big Red Button] 
		customItemList[1213865] = {itemId = 230019, onUse = true, castId = 466652, defaultName = GetSpellInfo(1213865)} -- trinket: [Vexie's Pit Whistle] 
		customItemList[450721] = {itemId = 219309, onUse = true, castId = 443535, defaultName = GetSpellInfo(450721)} -- trinket: [Tome of Light's Devotion]
		customItemList[1217184] = {itemId = 230029, onUse = true, castId = 466810, defaultName = GetSpellInfo(1217184)} -- trinket: [Chromebustible Bomb Suit] damage
		customItemList[466810] = {itemId = 230029, onUse = true, castId = 466810, defaultName = GetSpellInfo(466810)} -- trinket: [Chromebustible Bomb Suit] heal
		customItemList[472784] = {itemId = 230190, onUse = true, castId = 470286, defaultName = GetSpellInfo(472784)} -- trinket: [Torq's Big Red Button] damage
		customItemList[470286] = {itemId = 230190, onUse = true, castId = 470286, defaultName = GetSpellInfo(470286)} -- trinket: [Torq's Big Red Button] str buff
		customItemList[300612] = {itemId = 168973, onUse = true, castId = 300612, defaultName = GetSpellInfo(300612)} -- trinket: [Neural Synapse Enhancer] 
		customItemList[1216772] = {itemId = 235373, onUse = true, castId = 1216712, defaultName = GetSpellInfo(1216772)} -- trinket: [Abyssal Volt]
		customItemList[1216770] = {itemId = 235373, onUse = true, castId = 1216712, defaultName = GetSpellInfo(1216770)} -- trinket: [Abyssal Volt]
		customItemList[450926] = {itemId = 219310, onUse = true, castId = 443536, defaultName = GetSpellInfo(450926)} -- trinket: [Bursting Lightshard]

		--customItemList[] = {itemId = , onUse = true, castId = , defaultName = GetSpellInfo()} -- trinket: 
		--customItemList[] = {itemId = , onUse = true, castId = , defaultName = GetSpellInfo()} -- trinket: 

		customItemList[1216424] = {itemId = 235283, isPassive = true} -- trinket: [Bashful Book]
		customItemList[1220419] = {itemId = 232545, isPassive = true} -- trinket: [Gigazap's Zap-Cap]
		customItemList[472184] = {itemId = 232891, isPassive = true, nameExtra = "*haste*"} -- trinket: [Amorphous Relic] miniature
		customItemList[472185] = {itemId = 232891, isPassive = true, nameExtra = "*int*"} -- trinket: [Amorphous Relic] miniature
		customItemList[1216212] = {itemId = 230194, isPassive = true} -- trinket: [Reverb Radio]
		customItemList[474285] = {itemId = 230192, isPassive = true} -- trinket: [Mug's Moxie Jug]
		customItemList[469889] = {itemId = 230198, isPassive = true} -- trinket: [Eye of Kezan]
		customItemList[1216593] = {itemId = 230198, isPassive = true} -- trinket: [Eye of Kezan]
		customItemList[1215690] = {itemId = 230193, isPassive = true} -- trinket: [Mister Lock-N-Stalk] small damage
		customItemList[1215733] = {itemId = 230193, isPassive = true} -- trinket: [Mister Lock-N-Stalk] mass destruction
		customItemList[451369] = {itemId = 219307, isPassive = true} -- trinket: [Remnant of Darkness] intellect
		customItemList[451367] = {itemId = 219305, isPassive = true} -- trinket: [Carved Blazikon Wax]
		customItemList[449386] = {itemId = 219299, isPassive = true} -- trinket: [Synergistic Brewterializer] barril blow
		customItemList[1216650] = {itemId = 235363, isPassive = true} -- trinket: [Suspicious Energy Drink]
		customItemList[472127] = {itemId = 232883, isPassive = true} -- trinket: [Turbo-Drain 5000]
		customItemList[449254] = {itemId = 219296, isPassive = true} -- trinket: [Entropic Skardyn Core]
		customItemList[455910] = {itemId = 221032, isPassive = true} -- trinket: [Voltaic Stormcaller] damage
		customItemList[456652] = {itemId = 221032, isPassive = true} -- trinket: [Voltaic Stormcaller] haste
		customItemList[473602] = {itemId = 228893, isPassive = true} -- trinket: ["Tiny Pal"] 
		customItemList[1214807] = {itemId = 232485, isPassive = true, nameExtra = "*major*"} -- trinket: [Mechano-Core Amplifier] 
		customItemList[1214808] = {itemId = 232485, isPassive = true, nameExtra = "*minor*"} -- trinket: [Mechano-Core Amplifier]
		customItemList[450429] = {itemId = 219304, isPassive = true} -- trinket: [Conductor's Wax Whistle]
		customItemList[1215321] = {itemId = 234821, isPassive = true} -- trinket: [Papa's Prized Putter] 
		customItemList[268439] = {itemId = 159612, isPassive = true} -- trinket: [Azerokk's Resonating Heart] 
		customItemList[442268] = {itemId = 218126, isPassive = true} -- trinket: [Befouler's Syringe] 
		customItemList[1218713] = {itemId = 232541, isPassive = true} -- trinket: [Improvised Seaforium Pacemaker] 
		customItemList[1218469] = {itemId = 235813, isPassive = true} -- weapon: [Machine Gob's Iron Grin]
		customItemList[1218471] = {itemId = 235813, isPassive = true} -- weapon: [Machine Gob's Iron Grin]
		customItemList[1218463] = {itemId = 235813, isPassive = true} -- weapon: [Machine Gob's Iron Grin]
		customItemList[345698] = {itemId = 178808, isPassive = true} -- trinket: [Viscera of Coalesced Hatred] damage
		customItemList[455471] = {itemId = 225653, isPassive = true} -- trinket: [Siphoning Lightbrand] damage
		customItemList[455468] = {itemId = 225653, isPassive = true} -- trinket: [Siphoning Lightbrand] heal
		customItemList[473626] = {itemId = 232804, isPassive = true} -- trinket: [Capo's Molten Knuckles] 
		customItemList[473602] = {itemId = 228889, isPassive = true} -- trinket: [Titan of Industry]
		customItemList[472167] = {itemId = 230026, isPassive = true} -- trinket: [Scrapfield 9001] Scrapfield 9001 Overload
		customItemList[472172] = {itemId = 230026, isPassive = true} -- trinket: [Scrapfield 9001] Scrapfield 9001 Imminent Overload
		customItemList[473492] = {itemId = 232526, isPassive = true} -- trinket: [Best-in-Slots]
		customItemList[451924] = {itemId = 219306, isPassive = true} -- trinket: [Burin of the Candle King] is on use but no castId
		customItemList[345701] = {itemId = 178810, isPassive = true} -- trinket: [Vial of Spectral Essence] is on use but is passive heal
		customItemList[455486] = {itemId = 225656, isPassive = true} -- trinket: [Goldenglow Censer] is on use but is passive heal
		customItemList[1216884] = {itemId = 230188, isPassive = true} -- trinket: [Gallagio Bottle Service] is on use but is passive heal
		customItemList[1213424] = {itemId = 234185, isPassive = true} -- trinket: [Dr. Scrapheal] 
		customItemList[1213764] = {itemId = 234185, isPassive = true, nameExtra = "*35%*"} -- trinket: [Dr. Scrapheal] emergency heal bot
		customItemList[474463] = {itemId = 230186, isPassive = true} -- trinket: [Mister Pick-Me-Up] heal
		customItemList[467251] = {itemId = 230186, isPassive = true} -- trinket: [Mister Pick-Me-Up] buff

		--customItemList[] = {itemId = , isPassive = true} -- trinket: 



--[=[
		customItemList[] = {itemId = , isPassive = true} -- trinket: 
		customItemList[] = {itemId = , onUse = true, castId = , defaultName = GetSpellInfo()} -- trinket:
--]=]
	end

	---@param petName petname
	---@param spellId spellid
	---@param npcId npcid?
	---@return petname
	function Details222.Pets.GetPetNameFromCustomSpells(petName, spellId, npcId)
		---@type customiteminfo
		local customItem = Details222.CustomItemList[spellId]
		if (customItem and customItem.isSummon) then
			local defaultName = customItem.defaultName
			if (defaultName) then
				petName = defaultName
				if (customItem.nameExtra) then
					petName = petName .. " " .. customItem.nameExtra
				end

				return petName
			end
		end

		return petName
	end

	if (LIB_OPEN_RAID_SPELL_CUSTOM_NAMES) then
		for spellId, customTable in pairs(LIB_OPEN_RAID_SPELL_CUSTOM_NAMES) do
			local customName = customTable.name
			if (customName) then
				defaultSpellCustomization[spellId] = customName
			end
		end
	end

	function Details:GetDefaultCustomSpellsList()
		return defaultSpellCustomization
	end

	function Details:GetDefaultCustomItemList()
		return customItemList
	end

	function Details:UserCustomSpellUpdate(index, spellName, spellIcon) --called from the options panel > rename spells
		---@type savedspelldata
		local savedSpellData = Details.savedCustomSpells[index]
		if (savedSpellData) then
			local spellId = savedSpellData[1]
			savedSpellData[2], savedSpellData[3] = spellName or savedSpellData[2], spellIcon or savedSpellData[3]
			rawset(Details.spellcache, spellId, {savedSpellData[2], 1, savedSpellData[3]})
			Details.userCustomSpells[spellId] = true
			return true
		else
			return false
		end
	end

	function Details:UserCustomSpellReset(index)
		---@type savedspelldata
		local savedSpellData = Details.savedCustomSpells[index]
		if (savedSpellData) then
			local spellId = savedSpellData [1]
			local spellName, _, spellIcon = GetSpellInfo(spellId)

			if (defaultSpellCustomization[spellId]) then
				spellName = defaultSpellCustomization[spellId].name
				spellIcon = defaultSpellCustomization[spellId].icon or spellIcon or [[Interface\InventoryItems\WoWUnknownItem01]]
			end

			if (not spellName) then
				spellName = "Unknown"
			end
			if (not spellIcon) then
				spellIcon = [[Interface\InventoryItems\WoWUnknownItem01]]
			end

			rawset(Details.spellcache, spellId, {spellName, 1, spellIcon})

			savedSpellData[2] = spellName
			savedSpellData[3] = spellIcon
		end
	end

	function Details:FillUserCustomSpells()
		for spellId, spellTable in pairs(defaultSpellCustomization) do
			local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
			Details:UserCustomSpellAdd(spellId, spellTable.name or spellName or "Unknown", spellTable.icon or spellIcon or [[Interface\InventoryItems\WoWUnknownItem01]])
		end

		--itens
		--[381760] = {name = formatTextForItem(193786), isPassive = true, itemId = 193786, nameExtra = ""|nil},
		---@type number, customiteminfo
		for spellId, itemInfo in pairs(customItemList) do
			local bIsPassive = itemInfo.isPassive
			local itemId = itemInfo.itemId
			local nameExtra = itemInfo.nameExtra
			local spellName, _, spellIcon = GetSpellInfo(spellId)

			spellIcon = itemInfo.icon or spellIcon or [[Interface\InventoryItems\WoWUnknownItem01]]

			local itemName = formatTextForItem(itemId)
			if (itemName ~= "") then
				if (nameExtra) then
					itemName = itemName .. " " .. nameExtra
				end
				Details:UserCustomSpellAdd(spellId, itemName, spellIcon or [[Interface\InventoryItems\WoWUnknownItem01]])
			else
				if (not Details.UpdateIconsTimer or Details.UpdateIconsTimer:IsCancelled()) then
					Details.UpdateIconsTimer = C_Timer.NewTimer(3, Details.FillUserCustomSpells)
				end
			end
		end

		for i = #Details.savedCustomSpells, 1, -1 do
			---@type savedspelldata
			local savedSpellData = Details.savedCustomSpells[i]
			local spellId = savedSpellData[1]
			if (spellId > 10) then
				local doesSpellExists = GetSpellInfo(spellId)
				if (not doesSpellExists) then
					tremove(Details.savedCustomSpells, i)
				end
			end
		end
	end

	function Details:UserCustomSpellAdd(spellId, spellName, spellIcon, bAddedByUser)
		if (Details.userCustomSpells[spellId]) then
			if (not bAddedByUser) then
				return
			end
		end

		local isOverwrite = false
		for index, savedSpellData in ipairs(Details.savedCustomSpells) do
			if (savedSpellData[1] == spellId) then
				savedSpellData[2] = spellName
				savedSpellData[3] = spellIcon
				isOverwrite = true
				break
			end
		end

		if (not isOverwrite) then
			tinsert(Details.savedCustomSpells, {spellId, spellName, spellIcon})
		end

		rawset(Details.spellcache, spellId, {spellName, 1, spellIcon})

		if (bAddedByUser) then
			Details.userCustomSpells[spellId] = true
		end
	end

	function Details:UserCustomSpellRemove(index)
		---@type savedspelldata
		local savedSpellData = Details.savedCustomSpells[index]
		if (savedSpellData) then
			local spellId = savedSpellData[1]
			local spellName, _, spellIcon = GetSpellInfo(spellId)
			if (spellName) then
				rawset(Details.spellcache, spellId, {spellName, 1, spellIcon})
			end
			return tremove(Details.savedCustomSpells, index)
		end

		return false
	end

	--overwrite for API GetSpellInfo function
	Details.getspellinfo = function(spellId)
		return unpack(Details.spellcache[spellId]) --won't be nil due to the __index metatable in the spellcache table
	end
	Details.GetSpellInfo = Details.getspellinfo

	function Details.GetCustomSpellInfo(spellId)
		local spellName, _, spellIcon = Details.GetSpellInfo(spellId)

		local customInfo = defaultSpellCustomization[spellId]
		if (customInfo) then
			local defaultName, bCanStack = customInfo.defaultName, customInfo.breakdownCanStack
			return spellName, _, spellIcon, defaultName, bCanStack
		end

		return spellName, _, spellIcon
	end

	function Details.GetItemSpellInfo(spellId)
		local spellInfo = customItemList[spellId]
		if (spellInfo) then
			local defaultSpellName, castSpellId, itemId, bIsPassive, bOnUse, nameExtra = spellInfo.defaultName, spellInfo.castId, spellInfo.itemId, spellInfo.onUse, spellInfo.isPassive, spellInfo.nameExtra
			return defaultSpellName, castSpellId, itemId, bIsPassive, bOnUse, nameExtra
		end
	end

	--overwrite SpellInfo if the spell is a DoT, so Details.GetSpellInfo will return the name modified
	function Details:SetAsDotSpell(spellId)
		--do nothing if this spell already has a customization
		if (defaultSpellCustomization[spellId]) then
			return
		end

		--do nothing if the spell is already cached
		local spellInfo = rawget(Details.spellcache, spellId)
		if (spellInfo) then
			return
		end

		local spellName, rank, spellIcon = Details.GetSpellInfo(spellId)
		if (not spellName) then
			spellName, rank, spellIcon = GetSpellInfo(spellId)
		end

		if (spellName) then
			rawset(Details.spellcache, spellId, {spellName .. Loc ["STRING_DOT"], rank, spellIcon})
		else
			rawset(Details.spellcache, spellId, {"Unknown DoT Spell? " .. Loc ["STRING_DOT"], rank, [[Interface\InventoryItems\WoWUnknownItem01]]})
		end
	end
end