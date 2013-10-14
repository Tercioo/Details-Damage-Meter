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
		_rawset (_detalhes.spellcache, 1, {Loc ["STRING_MELEE"], 1, "Interface\\AddOns\\Details\\images\\melee.tga"})
		_rawset (_detalhes.spellcache, 2, {Loc ["STRING_AUTOSHOT"], 1, "Interface\\AddOns\\Details\\images\\autoshot.tga"})
		
		--> built-in overwrites
		for spellId, spellTable in pairs (_detalhes.SpellOverwrite) do
			local name, _, icon = _GetSpellInfo (spellId)
			_rawset (_detalhes.spellcache, spellId, {spellTable.name or name, 1, spellTable.icon or icon})
		end
		
		--> user overwrites
		for spellId, spellTable in pairs (_detalhes.SpellOverwriteUser) do
			local name, _, icon = _GetSpellInfo (spellId)
			_rawset (_detalhes.spellcache, spellId, {spellTable.name or name, 1, spellTable.icon or icon})
		end
	end

	--> initialize spell cache
	_detalhes:ClearSpellCache() 

	--> overwrite for API GetSpellInfo function 
	_detalhes.getspellinfo = function (spellid) return _unpack (_detalhes.spellcache[spellid]) end 

	--> overwrite SpellInfo if spell is a Dot, so GetSpellInfo will return the name modified
	function _detalhes:SpellIsDot (spellid)
		local nome, rank, icone = _GetSpellInfo (spellid)
		_rawset (_detalhes.spellcache, spellid, {nome .. Loc ["STRING_DOT"], rank, icone})
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Cache All Spells
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