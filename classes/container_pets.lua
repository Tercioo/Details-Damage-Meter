
local Details = 		_G.Details
local container_pets =		Details.container_pets
local _
local addonName, Details222 = ...

local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName
local IsInRaid = _G.IsInRaid
local IsInGroup = _G.IsInGroup
local GetNumGroupMembers = _G.GetNumGroupMembers
local setmetatable = setmetatable
local bitBand = bit.band --lua local
local pairs = pairs

local unitIDRaidCache = Details222.UnitIdCache.Raid

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

function container_pets:GetPetOwner(petGUID, petName, petFlags)
	--sair se o pet estiver na ignore
	if (bIsIgnored[petGUID]) then
		return
	end

	--buscar pelo pet no container de pets
	local petInfo = self.pets[petGUID]
	if (petInfo) then
		--in merging operations, make sure to not add the owner name a second time in the name

		--check if the pet name already has the owner name in, if not, add it
		if (not petName:find("<")) then
			--get the owner name
			local ownerName = petInfo[1]
			--add the owner name to the pet name
			petName = petName .. " <".. ownerName ..">"
		end

		return petName, petInfo[1], petInfo[2], petInfo[3] --petName, ownerName, ownerGUID, ownerFlags
	end

	--buscar pelo pet na raide
	local ownerName, ownerGUID, ownerFlags

	if (IsInRaid()) then
		for i = 1, GetNumGroupMembers() do
			if (petGUID == UnitGUID("raidpet"..i)) then
				ownerGUID = UnitGUID(unitIDRaidCache[i])
				ownerFlags = 0x00000417 --emulate sourceflag flag
				local unitName = Details:GetFullName(unitIDRaidCache[i])
				ownerName = unitName
			end
		end

	elseif (IsInGroup()) then
		for i = 1, GetNumGroupMembers()-1 do
			if (petGUID == UnitGUID("partypet"..i)) then
				ownerGUID = UnitGUID("party"..i)
				ownerFlags = 0x00000417 --emulate sourceflag flag
				local unitName = Details:GetFullName("party"..i)
				ownerName = unitName
			end
		end
	end

	if (not ownerName) then
		if (petGUID == UnitGUID("pet")) then
			ownerName = Details:GetFullName("player")
			ownerGUID = UnitGUID("player")
			if (IsInGroup() or IsInRaid()) then
				ownerFlags = 0x00000417 --emulate sourceflag flag
			else
				ownerFlags = 0x00000411 --emulate sourceflag flag
			end
		end
	end

	if (ownerName) then
		local foundTime = Details._tempo
		self.pets[petGUID] = {ownerName, ownerGUID, ownerFlags, foundTime, true, petName, petGUID} --adicionada a flag emulada

		if (not petName:find("<")) then
			petName = petName .. " <".. ownerName ..">"
		end

		return petName, ownerName, ownerGUID, ownerFlags
	else
		if (petFlags and bitBand(petFlags, OBJECT_TYPE_PET) ~= 0) then --is a pet
			if (not Details.pets_no_owner[petGUID] and bitBand(petFlags, OBJECT_IN_GROUP) ~= 0) then
				Details.pets_no_owner[petGUID] = {petName, petFlags}
				Details:Msg("couldn't find the owner of the pet:", petName)
			end
		else
			bIsIgnored[petGUID] = true
		end
	end
end

function container_pets:Unpet(...)
	local unitId = ...
	local ownerGUID = UnitGUID(unitId)

	if (ownerGUID) then
		--remove existing pet from thecache
		do
			local petGUID = Details.pets_players[ownerGUID]
			if (petGUID) then
				Details.parser:RevomeActorFromCache(petGUID)
				container_pets:Remover(petGUID)
				Details.pets_players[ownerGUID] = nil
			end
		end

		--check if the player has a new pet
		do
			local petGUID = UnitGUID(unitId .. "pet")
			if (petGUID) then
				if (not Details.tabela_pets.pets[petGUID]) then
					local unitName = Details:GetFullName(unitId)
					Details.tabela_pets:AddPet(petGUID, UnitName(unitId .. "pet"), 0x1114, ownerGUID, unitName, 0x514)
				end

				Details.parser:RevomeActorFromCache(petGUID)
				container_pets:PlayerPet(ownerGUID, petGUID)
			end
		end
	end
end

function container_pets:PlayerPet(player_serial, pet_serial)
	Details.pets_players[player_serial] = pet_serial
end

function container_pets:BuscarPets()
	if (IsInRaid()) then
		for i = 1, GetNumGroupMembers(), 1 do
			local petGUID = UnitGUID("raidpet" .. i)
			if (petGUID) then
				if (not Details.tabela_pets.pets[petGUID]) then
					local unitName = Details:GetFullName(unitIDRaidCache[i])
					local ownerGUID = UnitGUID(unitIDRaidCache[i])
					Details.tabela_pets:AddPet(petGUID, UnitName("raidpet"..i), 0x1114, ownerGUID, unitName, 0x514)
					Details.parser:RevomeActorFromCache(petGUID)
					container_pets:PlayerPet(ownerGUID, petGUID)
				end
			end
		end

	elseif (IsInGroup()) then
		for i = 1, GetNumGroupMembers()-1, 1 do
			local petGUID = UnitGUID("partypet"..i)
			if (petGUID) then
				if (not Details.tabela_pets.pets[petGUID]) then
					local unitName = Details:GetFullName("party"..i)
					Details.tabela_pets:AddPet(petGUID, UnitName("partypet"..i), 0x1114, UnitGUID("party"..i), unitName, 0x514)
				end
			end
		end

		local petGUID = UnitGUID("pet")
		if (petGUID) then
			if (not Details.tabela_pets.pets[petGUID]) then
				Details.tabela_pets:AddPet(petGUID, UnitName("pet"), 0x1114, UnitGUID("player"), Details.playername, 0x514)
			end
		end

	else
		local petGUID = UnitGUID("pet")
		if (petGUID) then
			if (not Details.tabela_pets.pets[petGUID]) then
				Details.tabela_pets:AddPet(petGUID, UnitName("pet"), 0x1114, UnitGUID("player"), Details.playername, 0x514)
			end
		end
	end
end

function container_pets:Remover(petGUID)
	if (Details.tabela_pets.pets[petGUID]) then
		Details:Destroy(Details.tabela_pets.pets[petGUID])
	end
	Details.tabela_pets.pets[petGUID] = nil
end

function container_pets:AddPet(petGUID, petName, petFlags, ownerGUID, ownerName, ownerFlags)
	if (petFlags and bitBand(petFlags, OBJECT_TYPE_PET) ~= 0 and bitBand(petFlags, OBJECT_IN_GROUP) ~= 0) then
		self.pets[petGUID] = {ownerName, ownerGUID, ownerFlags, Details._tempo, true, petName, petGUID}
	else
		self.pets[petGUID] = {ownerName, ownerGUID, ownerFlags, Details._tempo, false, petName, petGUID}
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

local bHasSchedule = false
function Details:UpdatePets()
	bHasSchedule = false
	return container_pets:BuscarPets()
end

function Details:SchedulePetUpdate(seconds)
	if (bHasSchedule) then
		return
	end
	bHasSchedule = true

	Details.Schedules.NewTimer(seconds or 5, Details.UpdatePets, Details)
end

function Details.refresh:r_container_pets(container)
	setmetatable(container, container_pets)
end

