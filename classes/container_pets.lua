
local Details = 		_G.Details
local container_pets =		Details.container_pets
local _
local addonName, Details222 = ...

local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName
local GetUnitName = _G.GetUnitName
local IsInRaid = _G.IsInRaid
local IsInGroup = _G.IsInGroup
local GetNumGroupMembers = _G.GetNumGroupMembers
local setmetatable = setmetatable
local bitBand = bit.band --lua local
local pairs = pairs

--details locals
local bIsIgnored = Details.pets_ignored

function container_pets:NovoContainer()
	local newPetContainer = {}
	setmetatable(newPetContainer, Details.container_pets)

	---@type petinfo
	local newPetCacheTable = {}
	newPetContainer.pets = newPetCacheTable

	newPetContainer._ActorTable = {}
	return newPetContainer
end

local OBJECT_TYPE_PET = 0x00001000
local OBJECT_IN_GROUP = 0x00000007

function container_pets:PegaDono(petGUID, petName, petFlags)
	--sair se o pet estiver na ignore
	if (bIsIgnored[petGUID]) then
		return
	end

	--buscar pelo pet no container de pets
	local busca = self.pets[petGUID]
	if (busca) then
		--in merging operations, make sure to not add the owner name a second time in the name

		--check if the pet name already has the owner name in, if not, add it
		if (not petName:find("<")) then
			--get the owner name
			local ownerName = busca[1]
			--add the owner name to the pet name
			petName = petName .. " <".. ownerName ..">"
		end

		--return busca[6] or pet_nome, busca[1], busca[2], busca[3] --busca[6] poderia estar causando problemas
		return petName, busca[1], busca[2], busca[3] --[1] dono nome[2] dono serial[3] dono flag
	end

	--buscar pelo pet na raide
	local dono_nome, dono_serial, dono_flags

	if (IsInRaid()) then
		for i = 1, GetNumGroupMembers() do
			if (petGUID == UnitGUID("raidpet"..i)) then
				dono_serial = UnitGUID("raid"..i)
				dono_flags = 0x00000417 --emulate sourceflag flag

				local nome, realm = UnitName("raid"..i)
				if (realm and realm ~= "") then
					nome = nome.."-"..realm
				end
				dono_nome = nome
			end
		end

	elseif (IsInGroup()) then
		for i = 1, GetNumGroupMembers()-1 do
			if (petGUID == UnitGUID("partypet"..i)) then
				dono_serial = UnitGUID("party"..i)
				dono_flags = 0x00000417 --emulate sourceflag flag

				local nome, realm = UnitName("party"..i)
				if (realm and realm ~= "") then
					nome = nome.."-"..realm
				end

				dono_nome = nome
			end
		end
	end

	if (not dono_nome) then
		if (petGUID == UnitGUID("pet")) then
			dono_nome = GetUnitName("player")
			dono_serial = UnitGUID("player")
			if (IsInGroup() or IsInRaid()) then
				dono_flags = 0x00000417 --emulate sourceflag flag
			else
				dono_flags = 0x00000411 --emulate sourceflag flag
			end
		end
	end

	if (dono_nome) then
		self.pets[petGUID] = {dono_nome, dono_serial, dono_flags, Details._tempo, true, petName, petGUID} --adicionada a flag emulada

		if (not petName:find("<")) then
			petName = petName .. " <".. dono_nome ..">"
		end

		return petName, dono_nome, dono_serial, dono_flags
	else

		if (petFlags and bitBand(petFlags, OBJECT_TYPE_PET) ~= 0) then --� um pet
			if (not Details.pets_no_owner[petGUID] and bitBand(petFlags, OBJECT_IN_GROUP) ~= 0) then
				Details.pets_no_owner[petGUID] = {petName, petFlags}
				Details:Msg("couldn't find the owner of the pet:", petName)
			end
		else
			bIsIgnored[petGUID] = true
		end
	end
	return
end

function container_pets:Unpet(...)
	local unitid = ...

	local owner_serial = UnitGUID(unitid)

	if (owner_serial) then
		--tira o pet existente da tabela de pets e do cache do core
		local existing_pet_serial = Details.pets_players[owner_serial]
		if (existing_pet_serial) then
			Details.parser:RevomeActorFromCache(existing_pet_serial)
			container_pets:Remover(existing_pet_serial)
			Details.pets_players[owner_serial] = nil
		end
		--verifica se h� um pet novo deste jogador
		local pet_serial = UnitGUID(unitid .. "pet")
		if (pet_serial) then
			if (not Details.tabela_pets.pets[pet_serial]) then
				local nome, realm = UnitName(unitid)
				if (realm and realm ~= "") then
					nome = nome.."-"..realm
				end
				Details.tabela_pets:Adicionar(pet_serial, UnitName(unitid .. "pet"), 0x1114, owner_serial, nome, 0x514)
			end
			Details.parser:RevomeActorFromCache(pet_serial)
			container_pets:PlayerPet(owner_serial, pet_serial)
		end
	end
end

function container_pets:PlayerPet(player_serial, pet_serial)
	Details.pets_players[player_serial] = pet_serial
end

function container_pets:BuscarPets()
	if (IsInRaid()) then
		for i = 1, GetNumGroupMembers(), 1 do
			local pet_serial = UnitGUID("raidpet"..i)
			if (pet_serial) then
				if (not Details.tabela_pets.pets[pet_serial]) then
					local nome, realm = UnitName("raid"..i)
					if (realm and realm ~= "") then
						nome = nome.."-"..realm
					end
					local owner_serial = UnitGUID("raid"..i)
					Details.tabela_pets:Adicionar(pet_serial, UnitName("raidpet"..i), 0x1114, owner_serial, nome, 0x514)
					Details.parser:RevomeActorFromCache(pet_serial)
					container_pets:PlayerPet(owner_serial, pet_serial)
				end
			end
		end

	elseif (IsInGroup()) then
		for i = 1, GetNumGroupMembers()-1, 1 do
			local pet_serial = UnitGUID("partypet"..i)
			if (pet_serial) then
				if (not Details.tabela_pets.pets[pet_serial]) then
					local nome, realm = UnitName("party"..i)

					if (realm and realm ~= "") then
						nome = nome.."-"..realm
					end
					Details.tabela_pets:Adicionar(pet_serial, UnitName("partypet"..i), 0x1114, UnitGUID("party"..i), nome, 0x514)

				end
			end
		end

		local pet_serial = UnitGUID("pet")
		if (pet_serial) then
			if (not Details.tabela_pets.pets[pet_serial]) then
				Details.tabela_pets:Adicionar(pet_serial, UnitName("pet"), 0x1114, UnitGUID("player"), Details.playername, 0x514)
			end
		end

	else
		local pet_serial = UnitGUID("pet")
		if (pet_serial) then
			if (not Details.tabela_pets.pets[pet_serial]) then
				Details.tabela_pets:Adicionar(pet_serial, UnitName("pet"), 0x1114, UnitGUID("player"), Details.playername, 0x514)
			end
		end
	end
end

function container_pets:Remover(pet_serial)
	if (Details.tabela_pets.pets[pet_serial]) then
		Details:Destroy(Details.tabela_pets.pets[pet_serial])
	end
	Details.tabela_pets.pets[pet_serial] = nil
end

function container_pets:Adicionar(pet_serial, pet_nome, pet_flags, dono_serial, dono_nome, dono_flags)
	if (pet_flags and bitBand(pet_flags, OBJECT_TYPE_PET) ~= 0 and bitBand(pet_flags, OBJECT_IN_GROUP) ~= 0) then
		self.pets[pet_serial] = {dono_nome, dono_serial, dono_flags, Details._tempo, true, pet_nome, pet_serial}
	else
		self.pets[pet_serial] = {dono_nome, dono_serial, dono_flags, Details._tempo, false, pet_nome, pet_serial}
	end
end

function Details:WipePets()
	return Details:Destroy(Details.tabela_pets.pets)
end

function Details222.Pets.PetContainerCleanup()
	--erase old pet table by creating a new one
	local newPetTable = {}

	--minimum of 90 minutes to clean a pet from the pet table data
	for petGUID, petTable in pairs(Details.tabela_pets.pets) do
		if ((petTable[4] + 5400 > Details._tempo + 1) or (petTable[5] and petTable[4] + 43200 > Details._tempo)) then
			newPetTable[petGUID] = petTable
		end
	end

	Details.tabela_pets.pets = newPetTable
	Details:UpdatePetCache()
end

local have_schedule = false
function Details:UpdatePets()
	have_schedule = false
	return container_pets:BuscarPets()
end
function Details:SchedulePetUpdate(seconds)
	if (have_schedule) then
		return
	end
	have_schedule = true

	--_detalhes:ScheduleTimer("UpdatePets", seconds or 5)
	Details.Schedules.NewTimer(seconds or 5, Details.UpdatePets, Details)
end

function Details.refresh:r_container_pets(container)
	setmetatable(container, container_pets)
end

