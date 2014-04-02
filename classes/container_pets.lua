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
local _bit_band = bit.band --lua local
local _pairs = pairs
local _ipairs = ipairs
local _table_wipe = table.wipe

--details locals
local is_ignored = _detalhes.pets_ignored

function container_pets:NovoContainer()
	local esta_tabela = {}
	_setmetatable (esta_tabela, _detalhes.container_pets)
	esta_tabela.pets = {} --> armazena a pool -> uma dictionary com o [serial do pet] -> nome do dono
	esta_tabela._ActorTable = {} --> armazena os 15 ultimos pets do jogador -> [jogador nome] -> {nil, nil, nil, ...}
	return esta_tabela
end

local OBJECT_TYPE_PET = 0x00001000
local EM_GRUPO = 0x00000007
local PET_EM_GRUPO = 0x00001007

function container_pets:PegaDono (pet_serial, pet_nome, pet_flags)

	--> sair se o pet estiver na ignore
	if (is_ignored [pet_serial]) then
		return
	end

	--> buscar pelo pet no container de pets
	local busca = self.pets [pet_serial]
	if (busca) then
		return pet_nome .." <"..busca[1]..">", busca[1], busca[2], busca[3] --> [1] dono nome [2] dono serial [3] dono flag
	end
	
	--> buscar pelo pet na raide
	local dono_nome, dono_serial, dono_flags
	
	if (_IsInRaid()) then
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
				
				--if (nome:find ("Unknown")) then
					--print ("owner name with Unknown: ", nome)
				--end
				
				--print ("Dono encontrado na raide",nome,realm)
			end
		end
		
	elseif (_IsInGroup()) then
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
		self.pets [pet_serial] = {dono_nome, dono_serial, dono_flags, _detalhes._tempo, true} --> adicionada a flag emulada
		return pet_nome .." <"..dono_nome..">", dono_nome, dono_serial, dono_flags
	else
		--if (_GetNumGroupMembers() > 0) then
			--print ("DEBUG: Pet sem dono: "..pet_nome)
		--end
		--print ("DEBUG Nao foi possivel achar o dono de "..pet_nome)
		
		if (pet_flags and _bit_band (pet_flags, OBJECT_TYPE_PET) ~= 0) then --> é um pet
			if (not _detalhes.pets_no_owner [pet_serial] and _bit_band (pet_flags, EM_GRUPO) ~= 0) then
				_detalhes.pets_no_owner [pet_serial] = {pet_nome, pet_flags}
				_detalhes:Msg ("couldn't find the owner of the pet:", pet_nome)
			end
		else
			is_ignored [pet_serial] = true
		end
	end
	
	--> não pode encontrar o dono do pet, coloca-lo na ignore
	
	return
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
					if (nome == "Unknown Entity") then
						_detalhes:SchedulePetUpdate (1)
						--print ("unknown owner name, rescheduling...")
					else
						if (realm and realm ~= "") then
							nome = nome.."-"..realm
							--print ("tem realm: ", realm, nome)
						end
						--print ("pet found: ", nome)
						--print ("bp dono encontrado na raide:",nome, realm)
						_detalhes.tabela_pets:Adicionar (pet_serial, _UnitName ("raidpet"..i), 0x1114, _UnitGUID ("raid"..i), nome, 0x514)
					end
				end
			end
		end
	elseif (_IsInGroup()) then
		for i = 1, _GetNumGroupMembers()-1, 1 do 
			local pet_serial = _UnitGUID ("partypet"..i)
			if (pet_serial) then
				if (not _detalhes.tabela_pets.pets [pet_serial]) then
					local nome, realm = _UnitName ("party"..i)
					if (nome == "Unknown Entity") then
						_detalhes:SchedulePetUpdate (1)
						--print ("unknown owner name, rescheduling...")
					else
						if (realm and realm ~= "") then
							nome = nome.."-"..realm
						end
						--print ("pet found: ", nome)
						--print ("bp dono encontrado no grupo:",nome, realm)
						_detalhes.tabela_pets:Adicionar (pet_serial, _UnitName ("partypet"..i), 0x1114, _UnitGUID ("party"..i), nome, 0x514) 
					end
				end
			end
		end
	end
end

-- 4372 = 1114 -> pet control player -> friendly -> aff raid

function container_pets:Adicionar (pet_serial, pet_nome, pet_flags, dono_serial, dono_nome, dono_flags)

	--if (pet_nome == "Guardian of Ancient Kings") then --remover
	--	print ("Summon GAK 2", dono_nome)
	--end
	
	if (pet_flags and _bit_band (pet_flags, OBJECT_TYPE_PET) ~= 0 and _bit_band (pet_flags, EM_GRUPO) ~= 0) then
		self.pets [pet_serial] = {dono_nome, dono_serial, dono_flags, _detalhes._tempo, true}
		--if (pet_nome == "Guardian of Ancient Kings") then --remover
		--	print ("Summon GAK 3 - TRUE", dono_nome)
		--end
	else
		self.pets [pet_serial] = {dono_nome, dono_serial, dono_flags, _detalhes._tempo}
		--if (pet_nome == "Guardian of Ancient Kings") then --remover
		--	print ("Summon GAK 3 - FALSE", dono_nome)
		--end
	end
	
	--if (fromSearch) then
	--	local d = self.pets [pet_serial]
		--print ("dono nome:",d[1], "dono serial:", d[2], "dono flags:", d[3], "tempo:", d[4])
	--end
	
	--if (self.pets [dono_serial]) then
		--print ("debug: a owner is a pet, Owner: ", dono_nome, " Pet: ", pet_nome)
	--end

end

function _detalhes:WipePets()
	return _table_wipe (_detalhes.tabela_pets.pets)
end

function _detalhes:LimparPets()
	--> elimina pets antigos
	local _new_PetTable = {}
	for PetSerial, PetTable in _pairs (_detalhes.tabela_pets.pets) do 
		if ( (PetTable[4] + _detalhes.intervalo_coleta > _detalhes._tempo + 1) or (PetTable[5] and PetTable[4] + 43200 > _detalhes._tempo) ) then
			_new_PetTable [PetSerial] = PetTable
		end
	end
	--a tabela antiga será descartada pelo garbage collector.
	--_table_wipe (_detalhes.tabela_pets.pets)
	_detalhes.tabela_pets.pets = _new_PetTable
end

local have_schedule = false
function _detalhes:UpdatePets()
	have_schedule = false
	return container_pets:BuscarPets()
end
function _detalhes:SchedulePetUpdate (seconds)
	if (have_schedule) then
		return
	end
	have_schedule = true
	_detalhes:ScheduleTimer ("UpdatePets", seconds or 5)
end

function _detalhes.refresh:r_container_pets (container)
	_setmetatable (container, container_pets)
	--container.__index = container_pets
end

