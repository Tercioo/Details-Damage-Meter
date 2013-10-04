local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local container_pets =		_detalhes.container_pets

-- api locals
local _UnitGUID = UnitGUID
local _UnitName = UnitName
local _GetUnitName = GetUnitName
local _IsInRaid = IsInRaid
local _IsInGroup = IsInGroup
local _GetNumGroupMembers = GetNumGroupMembers

-- lua locals
local _setmetatable = setmetatable

function container_pets:NovoContainer()
	local esta_tabela = {}
	_setmetatable (esta_tabela, _detalhes.container_pets)
	esta_tabela.pets = {} --> armazena a pool -> uma dictionary com o [serial do pet] -> nome do dono
	esta_tabela._ActorTable = {} --> armazena os 15 ultimos pets do jogador -> [jogador nome] -> {nil, nil, nil, ...}
	return esta_tabela
end

function container_pets:PegaDono (pet_serial, pet_nome, pet_flags)

	local busca = self.pets [pet_serial]
	local dono_nome, dono_serial, dono_flags
	
	if (busca) then
		--debug: print ("achou o pet no container de donos")
		dono_nome, dono_serial, dono_flags = busca[1], busca[2], busca[3]
		return pet_nome .." <"..dono_nome..">", dono_nome, dono_serial, dono_flags
	end
	
	if (_IsInRaid()) then
		--print ("estou em RAIDE")
		for i = 1, _GetNumGroupMembers() do 
			if (pet_serial == _UnitGUID ("raidpet"..i)) then
				dono_serial = _UnitGUID ("raid"..i)
				dono_flags = 0x00000417 --> emulate sourceflag flag
				
				local nome, realm = _UnitName ("raid"..i)
				if (realm and realm ~= "") then
					nome = nome.."-"..realm
					--print ("tem realm: ", realm, nome)
				end
				dono_nome = nome
				
				--print ("Dono encontrado na raide",nome,realm)
			end
		end
		
	elseif (_IsInGroup()) then
		--print ("DEBUG estou em PARTY")
		for i = 1, _GetNumGroupMembers()-1 do 
			if (pet_serial == _UnitGUID ("partypet"..i)) then
				dono_serial = _UnitGUID ("party"..i)
				dono_flags = 0x00000417 --> emulate sourceflag flag
				
				local nome, realm = _UnitName ("party"..i)
				if (realm and realm ~= "") then
					--print ("tem realm: ", realm)
					nome = nome.."-"..realm
				end
				dono_nome = nome
				--print ("Dono encontrado na party",nome,realm)
				--print ("DEBUG Dono encontrado na party")
			end
		end
	end
	
	if (not dono_nome) then
		if (pet_serial == _UnitGUID ("pet")) then
			dono_nome = _GetUnitName ("player")
			dono_serial = _UnitGUID ("player")
			if (_IsInGroup() or _IsInRaid()) then
				dono_flags = 0x00000417 --> emulate sourceflag flag
			else
				dono_flags = 0x00000411 --> emulate sourceflag flag
			end
		end
	end
	
	if (dono_nome) then
		--print ("dono encontrado, adicionando ao cache")
		self.pets [pet_serial] = {dono_nome, dono_serial, dono_flags, _detalhes._tempo} --> adicionada a flag emulada
		return pet_nome .." <"..dono_nome..">", dono_nome, dono_serial, dono_flags
	else
		--if (_GetNumGroupMembers() > 0) then
			--print ("DEBUG: Pet sem dono: "..pet_nome)
		--end
		--print ("DEBUG Nao foi possivel achar o dono de "..pet_nome)
	end
	
	return nil, nil, nil, nil

end

-->  ao ter raid roster update, precisa dar foreach no container de pets e verificar as flags
-->  o mesmo precisa ser feito com as tabelas de combate

function container_pets:BuscarPets()
	if (_IsInRaid()) then
		for i = 1, _GetNumGroupMembers(), 1 do 
			local pet_serial = _UnitGUID ("raidpet"..i)
			if (pet_serial) then
				if (not _detalhes.tabela_pets.pets [pet_serial]) then
					local nome, realm = _UnitName ("raid"..i)
					if (realm and realm ~= "") then
						nome = nome.."-"..realm
						--print ("tem realm: ", realm, nome)
					end
					--print ("bp dono encontrado na raide:",nome, realm)
					_detalhes.tabela_pets:Adicionar (pet_serial, _UnitName ("raidpet"..i), 2600, _UnitGUID ("raid"..i), nome, 0x514, true)
				end
			end
		end
	elseif (_IsInGroup()) then
		for i = 1, _GetNumGroupMembers()-1, 1 do 
			local pet_serial = _UnitGUID ("partypet"..i)
			if (pet_serial) then
				if (not _detalhes.tabela_pets.pets [pet_serial]) then
					local nome, realm = _UnitName ("party"..i)
					if (realm and realm ~= "") then
						nome = nome.."-"..realm
					end
					--print ("bp dono encontrado no grupo:",nome, realm)
					_detalhes.tabela_pets:Adicionar (pet_serial, _UnitName ("partypet"..i), 2600, _UnitGUID ("party"..i), nome, 0x514)
				end
			end
		end
	end
end

function container_pets:Adicionar (pet_serial, pet_nome, pet_flags, dono_serial, dono_nome, dono_flags, fromSearch)
	
	self.pets [pet_serial] = {dono_nome, dono_serial, dono_flags, _detalhes._tempo}
	
	--if (fromSearch) then
	--	local d = self.pets [pet_serial]
		--print ("dono nome:",d[1], "dono serial:", d[2], "dono flags:", d[3], "tempo:", d[4])
	--end
	
	--if (self.pets [dono_serial]) then
		--print ("debug: a owner is a pet, Owner: ", dono_nome, " Pet: ", pet_nome)
	--end

end

function _detalhes.refresh:r_container_pets (container)
	_setmetatable (container, container_pets)
	--container.__index = container_pets
end

