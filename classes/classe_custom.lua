local _detalhes = 		_G._detalhes
local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ( "Details" )

--lua locals
local _cstr = string.format
local _math_floor = math.floor
local _table_sort = table.sort
local _table_insert = table.insert
local _table_size = table.getn
local _setmetatable = setmetatable
local _ipairs = ipairs
local _pairs = pairs
local _rawget= rawget
local _math_min = math.min
local _math_max = math.max
local _bit_band = bit.band
local _unpack = unpack
local _type = type

--api locals
local _GetSpellInfo = _detalhes.getspellinfo
local _IsInRaid = IsInRaid
local _IsInGroup = IsInGroup
local _GetNumGroupMembers = GetNumGroupMembers
local _GetNumPartyMembers = GetNumPartyMembers or GetNumSubgroupMembers
local _GetNumRaidMembers = GetNumRaidMembers or GetNumGroupMembers
local _GetUnitName = GetUnitName

local gump = 			_detalhes.gump

local atributo_custom = _detalhes.atributo_custom

function atributo_custom:RefreshWindow (instancia, _combat, forcar, exportar)

	--> partir do principio que:
	-- sempre vai ter um SPELLID
	-- não vai ter target ou input output
	--> instancia.sub_atributo armazena o index da tabela de custons
	
	local CustomObject = _detalhes.custom [instancia.sub_atributo]

	_combat.totals [CustomObject.name] = 0
	instancia.customName = CustomObject.name
	
	--print (CustomObject)
	--print (CustomObject.source)
	--print ("source: " .. CustomObject.source)
	
	if (not CustomObject.source) then 
		print ("Sem Source")
		return
	elseif (CustomObject.source == "") then
		print ("Source esta em branco")
		return
	end
	
	--print ("atributo " .. CustomObject.attribute)
	
	if (CustomObject.source == "[raid]") then
		if (_IsInRaid()) then
			for i = 1, _GetNumGroupMembers(), 1 do
				local nome = _GetUnitName ("raid"..i, true):gsub (("%s+"), "")
				local Actor = _combat (CustomObject.attribute, nome)
				if (Actor) then 
					Actor:Custom (CustomObject.name, _combat, CustomObject.sattribute, CustomObject.spell, CustomObject.target)
				end
			end
		elseif (_IsInGroup()) then
			for i = 1, _GetNumGroupMembers()-1, 1 do
				local nome = _GetUnitName ("party"..i, true):gsub (("%s+"), "")
				local Actor = _combat (CustomObject.attribute, nome)			
				if (Actor) then 
					Actor:Custom (CustomObject.name, _combat, CustomObject.sattribute, CustomObject.spell, CustomObject.target)
				end
			end
			local Actor = _combat (CustomObject.attribute, _detalhes.playername)
			if (Actor) then 
				Actor:Custom (CustomObject.name, _combat, CustomObject.sattribute, CustomObject.spell, CustomObject.target)
			end
		else
			local Actor = _combat (CustomObject.attribute, _detalhes.playername)
			if (Actor) then
				Actor:Custom (CustomObject.name, _combat, CustomObject.sattribute, CustomObject.spell, CustomObject.target)
			end
		end

	elseif (CustomObject.source == "[all]") then
		for _, Actor in _ipairs (_combat [CustomObject.attribute]._ActorTable) do 
			Actor:Custom (CustomObject.name, _combat, CustomObject.sattribute, CustomObject.spell, CustomObject.target)
		end
	
	elseif (CustomObject.source == "[player]") then
		local Actor = _combat (CustomObject.attribute, _detalhes.playername)
		if (Actor) then 
			Actor:Custom (CustomObject.name, _combat, CustomObject.sattribute, CustomObject.spell, CustomObject.target)
		end
		
	else
		local _thisActor = _combat (CustomObject.attribute, CustomObject.source)
		if (_thisActor) then 
			_thisActor:Custom (CustomObject.name, _combat, CustomObject.sattribute, CustomObject.spell, CustomObject.target)
		end
	end
	
	--> agora result tem os atores que usaram a habilidade
	if (CustomObject.attribute == 1) then 
		return _detalhes.atributo_damage:RefreshWindow (instancia, _combat, forcar, exportar)
	elseif (CustomObject.attribute == 2) then 
		_detalhes.atributo_heal:RefreshWindow (instancia, _combat, forcar, exportar)
	end
	
	--> aqui precisa fazer algo para retornar algo pro report reconhecer a tabela

end





















