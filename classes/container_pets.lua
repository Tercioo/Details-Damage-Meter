
local Details = 		_G.Details
local _
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework

--what is a unit pet? unit pets are persistant pets (with no expiration time) which the player has full control over it.
--the event UNIT_PET is triggered by the client each time a unit pet is summoned or dismissed

local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName
local IsInRaid = _G.IsInRaid
local IsInGroup = _G.IsInGroup
local bitBand = bit.band --lua local
local pairs = pairs

---@class petdata : table
---@field ownerName actorname
---@field ownerGuid guid
---@field ownerFlags number
---@field petName actorname
---@field petGuid guid
---@field petFlags number
---@field bIsFriendly boolean
---@field foundTime number
---@field displayName actorname
---@field hashName string petName + <ownerName-OwnerRealmName>
---@field summonSpellId number?

---@class petcontainer : table
---@field Pets table<guid, petdata>
---@field IgnoredActors table<guid, boolean>
---@field UnitPetCache table<guid, guid>
---@field GetPetInfo fun(petGuid: guid):petdata
---@field AddPet fun(petGuid: guid, petName: actorname?, petFlags: number?, ownerGuid: guid?, ownerName: actorname?, ownerFlags: number?, summonSpellId: number?):petdata
---@field AddPetByTable fun(petData: petdata):petdata
---@field PetScan fun()
---@field Reset fun()
---@field IgnorePet fun(petGuid: guid)
---@field IsPetInCache fun(petGuid: guid):boolean
---@field RemovePet fun(petGuid: guid, bRemoveFromParser: boolean?)
---@field GetOwner fun(petGuid: guid, petName:string):actorname?, actorname?, guid?, number?
---@field SavePetFrom_UNITPET fun(unitGuid: guid, petGuid: guid)
---@field IsPetFrom_UNITPET fun(unitGuid: guid):boolean
---@field GetUnitPetFrom_UNITPET fun(unitGuid: guid):guid
---@field RemovePetFrom_UNITPET fun(unitGuid: guid)
---@field GetPets fun():table<guid, petdata>
---@field DoMaintenance fun()
---@field UNIT_PET fun(unitId: string)

--[=[
["petContainer.PetScan.ENCOUNTER_END"] = "0.000 ms | runs: 2",
["Details:UpdatePets"] = "0.001 ms | runs: 14",
["petContainer.DoMaintenance"] = "0.000 ms | runs: 3",
["petContainer.GetOwner"] = "0.027 ms | runs: 1451",
["petContainer.PetScan.UpdatePets"] = "0.001 ms | runs: 14",
["Total"] = "0.038 ms",
["petContainer.UNIT_PET"] = "0.000 ms | runs: 2",
["petContainer.PetScan.CombatStart"] = "0.000 ms | runs: 4",
["petContainer.AddPet"] = "0.001 ms | runs: 183",
["petContainer.PetScan.GetOwner"] = "0.008 ms | runs: 183",
["petContainer.SetPetData"] = "0.000 ms | runs: 1",
--]=]

local OBJECT_TYPE_PET = 0x00001000
local OBJECT_IN_GROUP = 0x00000007

--details locals
local petContainer = Details222.PetContainer

---copy all pet data from the passed table into the pet cache
---@param petData table<guid, petdata>
function petContainer.SetPetData(petData)
	Details222.Profiling.ProfileStart("petContainer.SetPetData")
	---@type guid, table<guid, petdata>
	for petGuid, thisPetData in pairs(petData) do
		petContainer.Pets[petGuid] = thisPetData
	end
	Details222.Profiling.ProfileStop("petContainer.SetPetData")
end

---return a table where the pet data are stored
function petContainer.GetPets()
	return petContainer.Pets
end

---reset the pet cache, wiping Pets, UnitPetCache and IgnoredActors
function petContainer.Reset()
	table.wipe(petContainer.Pets)
	table.wipe(petContainer.UnitPetCache)
	table.wipe(petContainer.IgnoredActors)
end

function Details.DebugPets()
	local amountPets = 0
	print("amounf of pets:", detailsFramework.table.countkeys(petContainer.Pets))
	local toShow = {petContainer.Pets, petContainer.UnitPetCache, petContainer.IgnoredActors}
	dumpt(toShow)
end

function Details.DebugMyPets()
	local amountPets = 0
	local myPets = {}
	local playerGUID = UnitGUID("player")

	for petGuid, petData in pairs(petContainer.Pets) do
		---@cast petData petdata
		if (petData.ownerGuid == playerGUID) then
			myPets[petGuid] = petData
			amountPets = amountPets + 1
		end
	end

	dumpt(myPets)
end

---add a pet guid into the ignored list, when a pet is ignored the system will not try to find its owner as it already failed to find it once
---@param petGuid guid
function petContainer.IgnorePet(petGuid)
	petContainer.IgnoredActors[petGuid] = true
end

---remove a pet from the cache
---@param petGuid guid
---@param bRemoveFromParser boolean?
function petContainer.RemovePet(petGuid, bRemoveFromParser)
	if (bRemoveFromParser) then
		Details.parser:RevomeActorFromCache(petGuid)
	end
	petContainer.RemovePetFrom_UNITPET(petGuid)
	petContainer.Pets[petGuid] = nil
end

---return the pet data from the cache by passing the pet guid
---@param petGuid guid
---@return petdata?
function petContainer.GetPetInfo(petGuid)
	return petContainer.Pets[petGuid]
end

---return tue if the pet guid is inside the pet cache
---@param petGuid guid
---@return boolean
function petContainer.IsPetInCache(petGuid)
	return petContainer.Pets[petGuid] ~= nil
end

---@param petData petdata
function petContainer.AddPetByTable(petData)
	local newPetData = petContainer.AddPet(petData.petGuid, petData.petName, petData.petFlags, petData.ownerGuid, petData.ownerName, petData.ownerFlags, petData.summonSpellId)
	return newPetData
end

---@param petGuid guid
---@param petName actorname
---@param petFlags number
---@param ownerGuid guid
---@param ownerName actorname
---@param ownerFlags number
---@param summonSpellId number
---@return petdata
function petContainer.AddPet(petGuid, petName, petFlags, ownerGuid, ownerName, ownerFlags, summonSpellId)
	Details222.Profiling.ProfileStart("petContainer.AddPet")
	local bIsFriendly = petFlags and bitBand(petFlags, OBJECT_TYPE_PET) ~= 0 and bitBand(petFlags, OBJECT_IN_GROUP) ~= 0

	if (not ownerName) then
		--print("NO OWNER NAME",petGuid, petName, petFlags, ownerGuid, ownerName, ownerFlags, summonSpellId)
		--NO OWNER NAME Creature-0-4218-2549-4490-61056-00006A5157 Primal Earth Elemental 2600 nil nil nil 118323 --spellId 118323: Earth Elemental
		--NO OWNER NAME Pet-0-4218-2549-4490-26125-0102D77C2C Casketmuncher 4648 nil nil nil 52150 --spellId: 52150 raise dead
		--NO OWNER NAME Creature-0-4214-2569-1456-202167-00006B35A1 Ray of Anguish 2632 nil nil nil 402191 --spellId: 402191 Ray of Anguish
		--NO OWNER NAME Creature-0-2085-2657-26413-98035-00006C9B11 Dreadstalker 8466 nil nil nil 193332 --Call Dreadstalkers
		--NO OWNER NAME Creature-0-2085-2657-26413-98035-0000EC9B11 Dreadstalker 8466 nil nil nil 193331 --Call Dreadstalkers
		--NO OWNER NAME Creature-0-2085-2657-26894-54983-00006C9EB4 Treant 8466 nil nil nil 102693 --Grove Guardians
		Details222.Profiling.ProfileStop("petContainer.AddPet")
		---@diagnostic disable-next-line: missing-return-value
		return
	end

	if (Details222.Debug.DebugPets) then
		Details:Msg("petContainer.AddPet", petGuid, petName, petFlags, ownerGuid, ownerName, ownerFlags, summonSpellId)

	elseif (Details222.Debug.DebugPlayerPets and ownerName == Details.playername) then
		Details:Msg("petContainer.AddPet", petGuid, petName, petFlags, ownerGuid, ownerName, ownerFlags, summonSpellId)
	end

	--print("====================================")
	--print(petName)
	--print(debugstack())

	---@type petdata
	local petData = {
		ownerName = ownerName,
		ownerGuid = ownerGuid,
		ownerFlags = ownerFlags,
		petName = petName,
		petGuid = petGuid,
		petFlags = petFlags,
		bIsFriendly = bIsFriendly,
		summonSpellId = summonSpellId,
		foundTime = Details._tempo,
		displayName = petName,
		hashName = petName .. " <" .. ownerName .. ">"
	}

	petContainer.Pets[petGuid] = petData
    petContainer.IgnoredActors[petGuid] = nil
	Details222.Profiling.ProfileStop("petContainer.AddPet")
	return petData
end


function petContainer.PetScan(from)
	Details222.Profiling.ProfileStart("petContainer.PetScan." .. from)
	if (IsInRaid()) then
		local unitIds = Details222.UnitIdCache.Raid
		for i = 1, #unitIds do
			local ownerUnitId = unitIds[i]

			if (UnitExists(ownerUnitId)) then
				local petUnitId = Details222.UnitIdCache.RaidPet[i]
				local petGuid = UnitGUID(petUnitId)

				if (petGuid) then
					if (not petContainer.IsPetInCache(petGuid)) then
						local petName = UnitName(petUnitId)
						local ownerFullName = Details:GetFullName(ownerUnitId)
						---@type petdata
						local petData = {
							ownerName = ownerFullName,
							ownerGuid = UnitGUID(ownerUnitId),
							ownerFlags = 0x514,
							petName = petName,
							petGuid = petGuid,
							petFlags = 0x1114,
							bIsFriendly = true,
							foundTime = Details._tempo,
							displayName = petName,
							hashName = petName .. " <" .. ownerFullName .. ">"
						}

						petContainer.AddPetByTable(petData)
					end
				end
			end
		end

	elseif (IsInGroup()) then
		local unitIds = Details222.UnitIdCache.Party
		for i = 1, #unitIds do
			local ownerUnitId = unitIds[i]
			if (UnitExists(ownerUnitId)) then
				local petUnitId = Details222.UnitIdCache.PartyPet[i]
				local petGuid = UnitGUID(petUnitId)

				if (petGuid) then
					if (not petContainer.IsPetInCache(petGuid)) then
						local petName = UnitName(petUnitId)
						local ownerFullName = Details:GetFullName(ownerUnitId)
						---@type petdata
						local petData = {
							ownerName = ownerFullName,
							ownerGuid = UnitGUID(ownerUnitId),
							ownerFlags = 0x514,
							petName = petName,
							petGuid = petGuid,
							petFlags = 0x1114,
							bIsFriendly = true,
							foundTime = Details._tempo,
							displayName = petName,
							hashName = petName .. " <" .. ownerFullName .. ">"
						}

						petContainer.AddPetByTable(petData)
					end
				end
			end
		end
	else
		local petGuid = UnitGUID("pet")
		if (petGuid) then
			if (not petContainer.IsPetInCache(petGuid)) then
				local petName = UnitName("pet")
				local ownerFullName = Details:GetFullName("player")
				---@type petdata
				local petData = {
					ownerName = ownerFullName,
					ownerGuid = UnitGUID("player"),
					ownerFlags = 0x514,
					petName = petName,
					petGuid = petGuid,
					petFlags = 0x1114,
					bIsFriendly = true,
					foundTime = Details._tempo,
					displayName = petName,
					hashName = petName .. " <" .. ownerFullName .. ">"
				}

				petContainer.AddPetByTable(petData)
			end
		end
	end
	Details222.Profiling.ProfileStop("petContainer.PetScan." .. from)
end

---@param petGuid guid
---@param petName actorname
---@return actorname? petNameWithOwner
---@return actorname? ownerName
---@return guid? ownerGuid
---@return number? ownerFlags
function petContainer.GetOwner(petGuid, petName)
	Details222.Profiling.ProfileStart("petContainer.GetOwner")

	--check if this pet is being ignored
	if (petContainer.IgnoredActors[petGuid]) then
		Details222.Profiling.ProfileStop("petContainer.GetOwner")
		return
	end

	--check if the pet is already in the cache
	local petInfo = petContainer.GetPetInfo(petGuid)
	if (petInfo) then
		Details222.Profiling.ProfileStop("petContainer.GetOwner")
		return petInfo.hashName, petInfo.ownerName, petInfo.ownerGuid, petInfo.ownerFlags
	end

	--attempt to find the pet owner by searching the party, raid or the player pet
	--pet scan already adds the pet into the cache
	petContainer.PetScan("GetOwner")

	--check if the pet scan found the pet owner
	local petInfo = petContainer.GetPetInfo(petGuid)
	if (petInfo) then
		Details222.Profiling.ProfileStop("petContainer.GetOwner")
		return petInfo.hashName, petInfo.ownerName, petInfo.ownerGuid, petInfo.ownerFlags
	end

	--attempt to get the pet owner by tooltip scan
	local ownerName, ownerGuid, ownerFlags = Details222.Pets.GetPetOwner(petGuid, petName)

	--if the tooltip scan worked, add the pet into the cache
	if (ownerName) then
		---@type petdata
		local petData = {
			ownerName = ownerName,
			ownerGuid = ownerGuid,
			ownerFlags = ownerFlags,
			petName = petName,
			petGuid = petGuid,
			petFlags = 0x1114,
			bIsFriendly = false,
			foundTime = Details._tempo,
			displayName = petName,
			hashName = petName .. " <" .. ownerName .. ">"
		}

		petContainer.AddPetByTable(petData)
		Details222.Profiling.ProfileStop("petContainer.GetOwner")
		return petData.hashName, petData.ownerName, petData.ownerGuid, petData.ownerFlags
	end

	--couldn't find the pet owner, ignore this pet
	petContainer.IgnorePet(petGuid)
	Details222.Profiling.ProfileStop("petContainer.GetOwner")
	return nil
end

---store in a cache the pet from UNIT_PET
---@param unitGuid guid
---@param petGuid guid
function petContainer.SavePetFrom_UNITPET(unitGuid, petGuid)
	petContainer.UnitPetCache[unitGuid] = petGuid
end

---returns true if the petGuid passed is a pet from the UNIT_PET event
---@param unitGuid guid
---@return boolean
function petContainer.IsPetFrom_UNITPET(unitGuid)
	return petContainer.UnitPetCache[unitGuid] ~= nil
end

---returns the petGuid from the UNIT_PET event
---@param unitGuid guid
---@return guid
function petContainer.GetUnitPetFrom_UNITPET(unitGuid)
	return petContainer.UnitPetCache[unitGuid]
end

---remove a pet guid from the unit pet cache
---@param unitGuid guid
function petContainer.RemovePetFrom_UNITPET(unitGuid)
	petContainer.UnitPetCache[unitGuid] = nil
end

function petContainer.UNIT_PET(unitId)
	Details222.Profiling.ProfileStart("petContainer.UNIT_PET")
	local ownerGuid = UnitGUID(unitId)
	--print("owner guid:", ownerGuid)

	if (ownerGuid) then
		do
			--check if the player had a pet and remove it from the cache
			--this guarantees that the pet is not in the cache when the new pet is added
			--is the UNIT_PET event was triggered by a pet being dismissed
			local petGuid = petContainer.GetUnitPetFrom_UNITPET(ownerGuid)
			if (petGuid) then
				--print("pet existed!")
				petContainer.RemovePet(petGuid, true)
			end
		end

		do
			local petUnitId = unitId .. "pet"
			--print("pet unitId", petUnitId)
			if (UnitExists(petUnitId)) then
				--print("player pet exists!")
				--add the new pet into the pet cache
				local petGuid = UnitGUID(petUnitId)
				if (petGuid) then
					if (not petContainer.IsPetInCache(petGuid)) then
						local ownerFullName = Details:GetFullName(unitId)
						local petName = UnitName(petUnitId)

						---@type petdata
						local petData = {
							ownerName = ownerFullName,
							ownerGuid = ownerGuid,
							ownerFlags = 0x514,
							petName = petName,
							petGuid = petGuid,
							petFlags = 0x1114,
							bIsFriendly = true,
							foundTime = Details._tempo,
							displayName = petName,
							hashName = petName .. " <" .. ownerFullName .. ">"
						}

						--print(petData.petName, petData.hashName)

						petContainer.AddPetByTable(petData)

						petContainer.SavePetFrom_UNITPET(ownerGuid, petGuid)
					else
						--print("pet already in cache! ALREADY ALREADT")
					end
				end
			else
				--print("player pet does not exist!NOPNOPNOPNOP")
			end
		end
	end

	Details222.Profiling.ProfileStop("petContainer.UNIT_PET")
end

function petContainer.DoMaintenance()
	Details222.Profiling.ProfileStart("petContainer.DoMaintenance")
	local petCache = petContainer.Pets

	for petGuid, petData in pairs(petCache) do
		local petInfo = petContainer.GetPetInfo(petGuid)

		--check if the pet is a unit pet, unit pets are persistant, never timeout
		local bIsUnitPet = petContainer.IsPetFrom_UNITPET(petGuid)
		if (bIsUnitPet) then
			if (not petInfo or not UnitExists(petInfo.ownerGuid) or not UnitExists(petInfo.ownerName)) then
				petContainer.RemovePet(petGuid, true)
			end
		else
			local expirationTime = petData.foundTime + 1800
			if (expirationTime < Details._tempo + 1) then
				petContainer.RemovePet(petGuid, true)
			end
		end
	end
	Details222.Profiling.ProfileStop("petContainer.DoMaintenance")
end

local bHasSchedule = false
function Details:UpdatePets()
	Details222.Profiling.ProfileStart("Details:UpdatePets")
	bHasSchedule = false
	petContainer.PetScan("UpdatePets")
	Details222.Profiling.ProfileStop("Details:UpdatePets")
end

function Details:SchedulePetUpdate(seconds)
	if (bHasSchedule) then
		return
	end

	bHasSchedule = true
	seconds = seconds or 5

	Details.Schedules.NewTimer(seconds, Details.UpdatePets, Details)
end

function Details:GetPetInfo(petGuid)
	return petContainer.GetPetInfo(petGuid)
end