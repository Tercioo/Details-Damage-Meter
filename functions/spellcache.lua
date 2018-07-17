--[[ Spell Cache store all spells shown on frames and make able to change spells name, icons, etc... ]]

do 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> On The Fly SpellCache

	local _detalhes = 	_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	local _rawget	=	rawget
	local _rawset	=	rawset
	local _setmetatable =	setmetatable
	local _GetSpellInfo =	GetSpellInfo
	local _unpack	=	unpack

	--> default container
	_detalhes.spellcache =	{}
	local unknowSpell = {Loc ["STRING_UNKNOWSPELL"], _, "Interface\\Icons\\Ability_Druid_Eclipse"} --> localize-me
	
	--> reset spell cache
	function _detalhes:ClearSpellCache()
		_detalhes.spellcache = _setmetatable ({}, 
				{__index = function (tabela, valor) 
					local esta_magia = _rawget (tabela, valor)
					if (esta_magia) then
						return esta_magia
					end

					--> should save only icon and name, other values are not used
					if (valor) then --> check if spell is valid before
						local cache = {_GetSpellInfo (valor)}
						tabela [valor] = cache
						return cache
					else
						return unknowSpell
					end
					
				end})

		--> default overwrites
		--_rawset (_detalhes.spellcache, 1, {Loc ["STRING_MELEE"], 1, "Interface\\AddOns\\Details\\images\\melee.tga"})
		--_rawset (_detalhes.spellcache, 2, {Loc ["STRING_AUTOSHOT"], 1, "Interface\\AddOns\\Details\\images\\autoshot.tga"})
		
		--> built-in overwrites
		for spellId, spellTable in pairs (_detalhes.SpellOverwrite) do
			local name, _, icon = _GetSpellInfo (spellId)
			_rawset (_detalhes.spellcache, spellId, {spellTable.name or name, 1, spellTable.icon or icon})
		end
		
		--> user overwrites
		-- [1] spellid [2] spellname [3] spellicon
		for index, spellTable in ipairs (_detalhes.savedCustomSpells) do
			_rawset (_detalhes.spellcache, spellTable [1], {spellTable [2], 1, spellTable [3]})
		end
	end
	
	--[1] = {name = Loc ["STRING_MELEE"], icon = [[Interface\AddOns\Details\images\melee.tga]]},
	--[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\AddOns\Details\images\autoshot.tga]]},
	
	local default_user_spells = {
		[1] = {name = Loc ["STRING_MELEE"], icon = [[Interface\ICONS\INV_Sword_04]]},
		[2] = {name = Loc ["STRING_AUTOSHOT"], icon = [[Interface\ICONS\INV_Weapon_Bow_07]]},
		[3] = {name = Loc ["STRING_ENVIRONMENTAL_FALLING"], icon = [[Interface\ICONS\Spell_Magic_FeatherFall]]},
		[4] = {name = Loc ["STRING_ENVIRONMENTAL_DROWNING"], icon = [[Interface\ICONS\Ability_Suffocate]]},
		[5] = {name = Loc ["STRING_ENVIRONMENTAL_FATIGUE"], icon = [[Interface\ICONS\Spell_Arcane_MindMastery]]},
		[6] = {name = Loc ["STRING_ENVIRONMENTAL_FIRE"], icon = [[Interface\ICONS\INV_SummerFest_FireSpirit]]},
		[7] = {name = Loc ["STRING_ENVIRONMENTAL_LAVA"], icon = [[Interface\ICONS\Ability_Rhyolith_Volcano]]},
		[8] = {name = Loc ["STRING_ENVIRONMENTAL_SLIME"], icon = [[Interface\ICONS\Ability_Creature_Poison_02]]},
		
		[98021] = {name = Loc ["STRING_SPIRIT_LINK_TOTEM"]},
		
		[44461] = {name = GetSpellInfo (44461) .. " (" .. Loc ["STRING_EXPLOSION"] .. ")"}, --> Living Bomb (explosion)
		
		[161576] = {name = GetSpellInfo (161576) .. " (" .. Loc ["STRING_EXPLOSION"] .. ")"}, --> Ko'ragh's Overflowing Energy (explosion)
		[161612] = {name = GetSpellInfo (161576) .. " (" .. Loc ["STRING_CAUGHT"] .. ")"}, --> Ko'ragh's Overflowing Energy (caught)
		
		[158336] = {name = GetSpellInfo (158336) .. " (" .. Loc ["STRING_WAVE"] .. " #1)"}, --> Twins Ogron Pulverize waves.
		[158417] = {name = GetSpellInfo (158417) .. " (" .. Loc ["STRING_WAVE"] .. " #2)"}, --> Twins Ogron Pulverize waves.
		[158420] = {name = GetSpellInfo (158420) .. " (" .. Loc ["STRING_WAVE"] .. " #3)"}, --> Twins Ogron Pulverize waves.
		
		[59638] = {name = GetSpellInfo (59638) .. " (" .. Loc ["STRING_MIRROR_IMAGE"] .. ")"}, --> Mirror Image's Frost Bolt (mage)
		[88082] = {name = GetSpellInfo (88082) .. " (" .. Loc ["STRING_MIRROR_IMAGE"] .. ")"}, --> Mirror Image's Fireball (mage)
		
		[94472] = {name = GetSpellInfo (94472) .. " (" .. Loc ["STRING_CRITICAL_ONLY"] .. ")"}, --> Atonement critical hit (priest)
		
		[33778] = {name = GetSpellInfo (33778) .. " (bloom)"}, --lifebloom (bloom)
		
		[121414] = {name = GetSpellInfo (121414) .. " (Glaive #1)"}, --> glaive toss (hunter)
		[120761] = {name = GetSpellInfo (120761) .. " (Glaive #2)"}, --> glaive toss (hunter)
		
		[213786] = {name = GetSpellInfo (213786) .. " (trinket)"},
		[214350] = {name = GetSpellInfo (214350) .. " (trinket)"},
		[224078] = {name = GetSpellInfo (224078) .. " (trinket)"},

	}
	
	function _detalhes:UserCustomSpellUpdate (index, name, icon)
		local t = _detalhes.savedCustomSpells [index]
		if (t) then
			t [2], t [3] = name or t [2], icon or t [3]
			return _rawset (_detalhes.spellcache, t [1], {t [2], 1, t [3]})
		else
			return false
		end
	end
	
	function _detalhes:UserCustomSpellReset (index)
		local t = _detalhes.savedCustomSpells [index]
		if (t) then
			local spellid = t [1]
			local name, _, icon = _GetSpellInfo (spellid)
			
			if (default_user_spells [spellid]) then
				name = default_user_spells [spellid].name
				icon = default_user_spells [spellid].icon or icon or [[Interface\InventoryItems\WoWUnknownItem01]]
			end
			
			if (not name) then
				name = "Unknown"
			end
			if (not icon) then
				icon = [[Interface\InventoryItems\WoWUnknownItem01]]
			end
			
			_rawset (_detalhes.spellcache, spellid, {name, 1, icon})
			
			t[2] = name
			t[3] = icon
		end
	end
	
	function _detalhes:FillUserCustomSpells()
		for spellid, t in pairs (default_user_spells) do 
		
			local already_have
			for index, spelltable in ipairs (_detalhes.savedCustomSpells) do 
				if (spelltable [1] == spellid) then
					already_have = spelltable
				end
			end
		
			if (not already_have) then
				local name, _, icon = GetSpellInfo (spellid)
				_detalhes:UserCustomSpellAdd (spellid, t.name or name or "Unknown", t.icon or icon or [[Interface\InventoryItems\WoWUnknownItem01]])	
			end
			
		end
		
		for i = #_detalhes.savedCustomSpells, 1, -1 do
			local spelltable = _detalhes.savedCustomSpells [i]
			local spellid = spelltable [1]
			if (spellid > 10) then
				local exists = _GetSpellInfo (spellid)
				if (not exists) then
					tremove (_detalhes.savedCustomSpells, i)
				end
			end
		end
	end
	
	function _detalhes:UserCustomSpellAdd (spellid, name, icon)
		local is_overwrite = false
		for index, t in ipairs (_detalhes.savedCustomSpells) do 
			if (t [1] == spellid) then
				t[2] = name
				t[3] = icon
				is_overwrite = true
				break
			end
		end
		if (not is_overwrite) then
			tinsert (_detalhes.savedCustomSpells, {spellid, name, icon})
		end
		return _rawset (_detalhes.spellcache, spellid, {name, 1, icon})
	end
	
	function _detalhes:UserCustomSpellRemove (index)
		local t = _detalhes.savedCustomSpells [index]
		if (t) then
			local spellid = t [1]
			local name, _, icon = _GetSpellInfo (spellid)
			_rawset (_detalhes.spellcache, spellid, {name, 1, icon})
			return tremove (_detalhes.savedCustomSpells, index)
		end
		
		return false
	end
	
	--> overwrite for API GetSpellInfo function 
	_detalhes.getspellinfo = function (spellid) return _unpack (_detalhes.spellcache[spellid]) end 
	_detalhes.GetSpellInfo = _detalhes.getspellinfo

	--> overwrite SpellInfo if spell is a Dot, so GetSpellInfo will return the name modified
	function _detalhes:SpellIsDot (spellid)
		local nome, rank, icone = _GetSpellInfo (spellid)
		_rawset (_detalhes.spellcache, spellid, {nome .. Loc ["STRING_DOT"], rank, icone})
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Cache All Spells

	function _detalhes:BuildSpellListSlow()

		local load_frame = _G.DetailsLoadSpellCache
		if (load_frame and (load_frame.completed or load_frame.inprogress)) then
			return false
		end
	
		local step = 1
		local max = 160000
		
		if (not load_frame) then
			load_frame = CreateFrame ("frame", "DetailsLoadSpellCache", UIParent)
			load_frame:SetFrameStrata ("DIALOG")
			
			local progress_label = load_frame:CreateFontString ("DetailsLoadSpellCacheProgress", "overlay", "GameFontHighlightSmall")
			progress_label:SetText ("Loading Spells: 0%")
			function _detalhes:BuildSpellListSlowTick()
				progress_label:SetText ("Loading Spells: " .. load_frame:GetProgress() .. "%")
			end
			load_frame.tick = _detalhes:ScheduleRepeatingTimer ("BuildSpellListSlowTick", 1)
			
			function load_frame:GetProgress()
				return math.floor (step / max * 100)
			end
		end
		
		local SpellCache = {a={}, b={}, c={}, d={}, e={}, f={}, g={}, h={}, i={}, j={}, k={}, l={}, m={}, n={}, o={}, p={}, q={}, r={}, s={}, t={}, u={}, v={}, w={}, x={}, y={}, z={}}
		local _string_lower = string.lower
		local _string_sub = string.sub
		local blizzGetSpellInfo = GetSpellInfo
		
		load_frame.inprogress = true
		
		_detalhes.spellcachefull = SpellCache

		load_frame:SetScript ("OnUpdate", function()
			for spellid = step, step+500 do
				local name, _, icon = blizzGetSpellInfo (spellid)
				if (name) then
					local LetterIndex = _string_lower (_string_sub (name, 1, 1)) --> get the first letter
					local CachedIndex = SpellCache [LetterIndex]
					if (CachedIndex) then
						CachedIndex [spellid] = {name, icon}
					end
				end
			end
			
			step = step + 500
			
			if (step > max) then
				step = max
				_G.DetailsLoadSpellCache.completed = true
				_G.DetailsLoadSpellCache.inprogress = false
				_detalhes:CancelTimer (_G.DetailsLoadSpellCache.tick)
				DetailsLoadSpellCacheProgress:Hide()
				load_frame:SetScript ("OnUpdate", nil)
			end
			
		end)
		

		
		return true
	end

	function _detalhes:BuildSpellList()
	
		local SpellCache = {a={}, b={}, c={}, d={}, e={}, f={}, g={}, h={}, i={}, j={}, k={}, l={}, m={}, n={}, o={}, p={}, q={}, r={}, s={}, t={}, u={}, v={}, w={}, x={}, y={}, z={}}
		local _string_lower = string.lower
		local _string_sub = string.sub
		local blizzGetSpellInfo = GetSpellInfo

		for spellid = 1, 160000 do
			local name, rank, icon = blizzGetSpellInfo (spellid)
			if (name) then
				local index = _string_lower (_string_sub (name, 1, 1))
				local CachedIndex = SpellCache [index]
				if (CachedIndex) then
					CachedIndex [spellid] = {name, icon, rank}
				end
			end
		end

		_detalhes.spellcachefull = SpellCache
		return true
	end
	
	function _detalhes:ClearSpellList()
		_detalhes.spellcachefull = nil
		collectgarbage()
	end
	

	
end
