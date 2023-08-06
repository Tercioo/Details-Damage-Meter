
do
	local Details = 	_G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
	local addonName, Details222 = ...
	local _
	local rawget = rawget
	local rawset = rawset
	local setmetatable = setmetatable
	local GetSpellInfo = GetSpellInfo
	local unpack = unpack
	local tinsert = tinsert
	local tremove = tremove
	local C_Timer = C_Timer

	--is this a timewalking exp?
	local bIsClassicWow = DetailsFramework.IsClassicWow()

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

	local iconSize = 14
	local coords = {0.14, 0.86, 0.14, 0.86}

	---@param itemId number
	---@return string
	local formatTextForItem = function(itemId)
		local result = ""

		local itemIcon = C_Item.GetItemIconByID(itemId)
		local itemName = C_Item.GetItemNameByID(itemId)

		if (itemIcon and itemName) then
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
	else --retail
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
			[395296] = {name = GetSpellInfo(395296), icon = "Interface\\Addons\\Details\\images\\ebon_might"},
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
		customItemList[377459] = {itemId = 194306} --trinket: All-Totem of the Master
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

	function Details:UserCustomSpellUpdate(index, spellName, spellIcon)
		---@type savedspelldata
		local savedSpellData = Details.savedCustomSpells[index]
		if (savedSpellData) then
			savedSpellData[2], savedSpellData[3] = spellName or savedSpellData[2], spellIcon or savedSpellData[3]
			return rawset(Details.spellcache, savedSpellData[1], {savedSpellData[2], 1, savedSpellData[3]})
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
		--[381760] = {name = formatTextForItem(193786), isPassive = true, itemId = 193786},
		---@type number, customiteminfo
		for spellId, itemInfo in pairs(customItemList) do
			local bIsPassive = itemInfo.isPassive
			local itemId = itemInfo.itemId
			local spellName, _, spellIcon = GetSpellInfo(spellId)

			local itemName = formatTextForItem(itemId)
			if (itemName ~= "") then
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

	function Details:UserCustomSpellAdd(spellId, spellName, spellIcon)
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

		return rawset(Details.spellcache, spellId, {spellName, 1, spellIcon})
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