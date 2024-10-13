-- actor container file
-- group members are the actors which will be shown in the window while in standard view mode, most of the times they are players in the same group as the player

	local Details = _G.Details
	local DF = _G.DetailsFramework
	local _
	local addonName, Details222 = ...

	---@cast Details222 details222

	local bIsDragonflightOrAbove = DetailsFramework.IsDragonflightAndBeyond()
	local CONST_CLIENT_LANGUAGE = DF.ClientLanguage

	local GetSpellTexture = C_Spell.GetSpellTexture or GetSpellTexture

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers

	local _IsInInstance = IsInInstance --api local
	local UnitGUID = UnitGUID --api local
	local setmetatable = setmetatable --lua local
	local bitBand = bit.band --lua local
	local bitBor = bit.bor --lua local
	local tableSort = table.sort --lua local
	local ipairs = ipairs --lua local
	local pairs = pairs --lua local

	local AddUnique = DetailsFramework.table.addunique --framework
	local UnitGroupRolesAssigned = DetailsFramework.UnitGroupRolesAssigned --framework

	local GetNumDeclensionSets = _G.GetNumDeclensionSets
	local DeclineName = _G.DeclineName
	local pet_tooltip_frame = _G.DetailsPetOwnerFinder

	local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants

	local actorContainer =	Details.container_combatentes

	local atributo_damage =		Details.atributo_damage
	local atributo_heal =			Details.atributo_heal
	local atributo_energy =		Details.atributo_energy
	local atributo_misc =			Details.atributo_misc

	local container_damage =		Details.container_type.CONTAINER_DAMAGE_CLASS
	local container_heal = 		Details.container_type.CONTAINER_HEAL_CLASS
	local container_energy = 		Details.container_type.CONTAINER_ENERGY_CLASS
	local container_energy_target =	Details.container_type.CONTAINER_ENERGYTARGET_CLASS
	local container_misc = 		Details.container_type.CONTAINER_MISC_CLASS
	local container_enemydebufftarget_target = Details.container_type.CONTAINER_ENEMYDEBUFFTARGET_CLASS

	---@type petcontainer
	local petContainer = Details222.PetContainer
	---@type table<guid, petdata>
	local petCache = petContainer.Pets

	--flags
	local REACTION_HOSTILE	=	0x00000040
	local IS_GROUP_OBJECT 	= 	0x00000007
	local REACTION_FRIENDLY	=	0x00000010
	local OBJECT_TYPE_MASK =	0x0000FC00
	local OBJECT_TYPE_OBJECT =	0x00004000
	local OBJECT_TYPE_PETGUARDIAN =	0x00003000
	local OBJECT_TYPE_GUARDIAN =	0x00002000
	local OBJECT_TYPE_PET =		0x00001000
	local OBJECT_TYPE_NPC =		0x00000800
	local OBJECT_TYPE_PLAYER =	0x00000400
	local OBJECT_TYPE_PETS = 	OBJECT_TYPE_PET + OBJECT_TYPE_GUARDIAN

	local SPELLID_SANGUINE_HEAL = 226510
	local sanguineActorName = Details222.GetSpellInfo(SPELLID_SANGUINE_HEAL)


---attempt to get the owner of rogue's Akaari's Soul from Secrect Technique
---@param petGUID string
---@return string|any
---@return string|any
---@return number|any
function Details222.Pets.AkaarisSoulOwner(petGUID)
	local tooltipData = C_TooltipInfo.GetHyperlink("unit:" .. petGUID)
	local args = tooltipData.args

	if (not args) then
		do
			local ownerGUID = tooltipData.guid --tooltipData.guid seems to exists on all akari soul tooltips and point to the owner guid
			if (ownerGUID) then
				if (ownerGUID:find("^Pl")) then
					local playerGUID = ownerGUID
					local actorObject = Details:GetActorFromCache(playerGUID) --quick cache only exists during conbat
					if (actorObject) then
						return actorObject.nome, playerGUID, actorObject.flag_original
					end

					local guidCache = Details:GetParserPlayerCache() --cache exists until the next combat starts
					local ownerName = guidCache[playerGUID]
					if (ownerName) then
						return ownerName, playerGUID, 0x514
					end
				end
			end
		end

		do
			if (tooltipData.lines) then
				for i = 1, #tooltipData.lines do
					local lineData = tooltipData.lines[i]
					if (lineData.unitToken) then --unit token seems to exists when the add belongs to the "player"
						local ownerGUID = UnitGUID(lineData.unitToken)
						if (ownerGUID and ownerGUID:find("^Pl")) then
							local playerGUID = ownerGUID
							local actorObject = Details:GetActorFromCache(playerGUID) --quick cache only exists during conbat
							if (actorObject) then
								return actorObject.nome, playerGUID, actorObject.flag_original
							end

							local guidCache = Details:GetParserPlayerCache() --cache exists until the next combat starts
							local ownerName = guidCache[playerGUID]
							if (ownerName) then
								return ownerName, playerGUID, 0x514
							end
						end
					end
				end
			end
		end
	end

	if (not args) then
		--new tooltip data from 10.1.0 seems to not have .args
		return
	end

	local playerGUID
	--iterate among args and find into the value field == guid and it must have guidVal
	for i = 1, #args do --this is erroring in the ptr 10.1.0, as .args doesn't seem to exists on akari soul tooltip
		local arg = args[i]
		if (arg.field == "guid") then
			playerGUID = arg.guidVal
			break
		end
	end

	if (playerGUID) then
		local actorObject = Details:GetActorFromCache(playerGUID) --quick cache only exists during conbat
		if (actorObject) then
			return actorObject.nome, playerGUID, actorObject.flag_original
		end
		local guidCache = Details:GetParserPlayerCache() --cache exists until the next combat starts
		local ownerName = guidCache[playerGUID]
		if (ownerName) then
			return ownerName, playerGUID, 0x514
		end
	end
end


---Determine if the inputted pet string contains any declension variation of the given player name.
---@param tooltipString string
---@param playerName string
---@return boolean hasDeclension
--check pet owner name with correct declension for ruRU locale (from user 'denis-kam' on github)
local find_name_declension = function(tooltipString, playerName)
	--2 - male, 3 - female
	for gender = 3, 2, -1 do
		for declensionSet = 1, GetNumDeclensionSets(playerName, gender) do
			--check genitive case of player name
			local genitive = DeclineName(playerName, gender, declensionSet)
			if tooltipString:find(genitive) then
				--print("found genitive: ", gender, declensionSet, playerName, petTooltip:find(genitive))
				return true
			end
		end
	end
	return false
end

local unitNameTitles = {
    UNITNAME_TITLE_PET,
    UNITNAME_TITLE_COMPANION,
    UNITNAME_TITLE_GUARDIAN,
    UNITNAME_TITLE_MINION,
    UNITNAME_TITLE_CHARM,
    UNITNAME_TITLE_CREATION,
    UNITNAME_TITLE_SQUIRE
}
for i=1, #unitNameTitles do
    unitNameTitles[i] = unitNameTitles[i]:gsub('%%s', '(.*)')
end

--Add Demon to the list, attempt to localize it. There is no UNITNAME_TITLE_DEMON sadly, but I can try to swap out the word "Pet" for "Demon" using the localized names.
unitNameTitles[#unitNameTitles+1] = unitNameTitles[1]:gsub(PET_TYPE_PET, PET_TYPE_DEMON)

---attempt to the owner of a pet using tooltip scan, if the owner isn't found, return nil
---@param petGUID string
---@param petName string
---@return string|nil ownerName
---@return string|nil ownerGUID
---@return integer|nil ownerFlags
	function Details222.Pets.GetPetOwner(petGUID, petName) --this is under the Pets namespace, the new pet system is under the PetContainer namespace

        local ownerGUID, ownerName, lineText

        local cbMode = tonumber(GetCVar("colorblindMode")) or 0
        if (bIsDragonflightOrAbove) then
            local tooltipData = C_TooltipInfo.GetHyperlink('unit:'.. petGUID)
            if (tooltipData) then
                if (tooltipData.lines[1].leftText == '') then -- Assume this is an Akaari's soul / Storm Earth Fire tooltip
                    ownerGUID = tooltipData.guid
                elseif (tooltipData.lines[1].leftText == petName) then
                    local lineTwo = tooltipData.lines[2 + cbMode]
                    if (not lineTwo) then
                        if (Details222.Debug.DebugPets or Details222.Debug.DebugPlayerPets) then
					        Details:Msg("DebugPets|ActorContainer|Tooltip No LineTwo|PetName:", petName, "PetGUID:", petGUID, "ColorblindMode:", cbMode)
                        end
                        return
                    elseif (lineTwo.type == 16 and lineTwo.guid) then
                        ownerGUID = lineTwo.guid
                    else
                        lineText = lineTwo.leftText
                    end
                end
            end
        else
            pet_tooltip_frame:SetOwner(WorldFrame, "ANCHOR_NONE")
            pet_tooltip_frame:SetHyperlink(("unit:" .. petGUID) or "")

            local line = _G['DetailsPetOwnerFinderTextLeft' .. (2 + cbMode)]
            lineText = line and line:GetText()

            if (not lineText or lineText == '') then
                line = _G['DetailsPetOwnerFinderTextLeft1']
                lineText = line and line:GetText()
            end
        end

        if (lineText) then
            for i=1, #unitNameTitles do
                ownerName = lineText:match(unitNameTitles[i])
                if (ownerName) then
                    break
                end
            end

            if (not ownerName) then
                return
            end

            ---@type combat
            local currentCombat = Details:GetCurrentCombat()

            if (not currentCombat) then
                return
            end

            local isInRaid = currentCombat.raid_roster[ownerName]
            if (isInRaid) then
                return ownerName, UnitGUID(ownerName), 0x514
            end
        elseif (ownerGUID and ownerGUID:sub(1,6) == 'Player') then
            local playerGUID = ownerGUID
            local actorObject = Details:GetActorFromCache(playerGUID) --quick cache only exists during conbat
            if (actorObject) then
                return actorObject.nome, playerGUID, actorObject.flag_original
            end

            local guidCache = Details:GetParserPlayerCache() --cache exists until the next combat starts
            ownerName = guidCache[playerGUID]
            if (ownerName) then
                return ownerName, playerGUID, 0x514
            end

            if(Details.zone_type == 'arena') then --Attempt to find enemy pet owner
                for enemyName, enemyToken in pairs(Details.arena_enemies) do
                    if(UnitGUID(enemyToken) == ownerGUID) then
                        return enemyName, ownerGUID, 0x548
                    end
                end
            end
        end

        if true then return end

		pet_tooltip_frame:SetOwner(WorldFrame, "ANCHOR_NONE")
		pet_tooltip_frame:SetHyperlink(("unit:" .. petGUID) or "")

		--C_TooltipInfo.GetHyperlink

		if (bIsDragonflightOrAbove) then
			local tooltipData = pet_tooltip_frame:GetTooltipData() --is pet tooltip reliable with the new tooltips changes?
			if (tooltipData) then
				if (not tooltipData.args and tooltipData.lines[1].leftText == '') then --Assume this unit acts like Akaari's soul, where it returns the tooltip for the player instead, with line 1 blank.
					do
						local ownerGUID = tooltipData.guid --tooltipData.guid points to the player attributed to this tooltip.
						if (ownerGUID) then --If we have an owner GUID, then we should make sure it starts with a P for Player and then attempt to find the owner object from the caches.
							if (ownerGUID:find("^Pl")) then
								local playerGUID = ownerGUID
								local actorObject = Details:GetActorFromCache(playerGUID) --quick cache only exists during conbat
								if (actorObject) then
									return actorObject.nome, playerGUID, actorObject.flag_original
								end

								local guidCache = Details:GetParserPlayerCache() --cache exists until the next combat starts
								local ownerName = guidCache[playerGUID]
								if (ownerName) then
									return ownerName, playerGUID, 0x514
								end

								if(Details.zone_type == 'arena') then --Attempt to find enemy pet owner
									for enemyName, enemyToken in pairs(Details.arena_enemies) do
										if(UnitGUID(enemyToken) == ownerGUID) then
											return enemyName, ownerGUID, 0x548
										end
									end
								end
							end
						end
					end
					do
						if (tooltipData.lines) then
							for i = 1, #tooltipData.lines do
								local lineData = tooltipData.lines[i]
								if (lineData.unitToken) then --unit token seems to exists when the add belongs to the "player"
									local ownerGUID = UnitGUID(lineData.unitToken)
									if (ownerGUID and ownerGUID:find("^Pl")) then
										local playerGUID = ownerGUID
										local actorObject = Details:GetActorFromCache(playerGUID) --quick cache only exists during conbat
										if (actorObject) then
											return actorObject.nome, playerGUID, actorObject.flag_original
										end

										local guidCache = Details:GetParserPlayerCache() --cache exists until the next combat starts
										local ownerName = guidCache[playerGUID]
										if (ownerName) then
											return ownerName, playerGUID, 0x514
										end

										if(Details.zone_type == 'arena') then --Attempt to find enemy pet owner
											for enemyName, enemyToken in pairs(Details.arena_enemies) do
												if(UnitGUID(enemyToken) == ownerGUID) then
													return enemyName, ownerGUID, 0x548
												end
											end
										end
									end
								end
							end
						end
					end
				end

				local tooltipLines = tooltipData.lines
				for lineIndex = 1, #tooltipLines do
					local thisLine = tooltipLines[lineIndex]
					--get the type of information this line is showing
					local lineType = thisLine.type --type 0 = 'friendly' type 2 = 'name' type 16 = controller guid

					--parse the different types of information
					if (lineType == 2) then --unit name
						if (thisLine.leftText ~= petName) then
							--tooltip isn't showing our pet
							return
						end

					elseif (lineType == 16) then --controller guid
						--assuming the unit name always comes before the controller guid
						local guid = thisLine.guid
						--very fast way to get an actorObject, this cache only lives while in combat
						local actorObject = Details:GetActorFromCache(guid)
						if (actorObject) then
							--Details:Msg("(debug) pet found (1)", petName, "owner:", actorObject.nome)
							return actorObject.nome, guid, actorObject.flag_original
						else
							--return the actor name for a guid, this cache lives for current combat until next segment
							local guidCache = Details:GetParserPlayerCache()
							local ownerName = guidCache[guid]
							if (ownerName) then
								--Details:Msg("(debug) pet found (2)", petName, "owner:", ownerName)
								return ownerName, guid, 0x514
							end

							if(Details.zone_type == 'arena') then --Attempt to find enemy pet owner
								for enemyName, enemyToken in pairs(Details.arena_enemies) do
									if(UnitGUID(enemyToken) == guid) then
										return enemyName, guid, 0x548
									end
								end
							end
						end
					end
				end
			end
		end

		---@type combat
		local currentCombat = Details:GetCurrentCombat()

		local ownerName, ownerGUID, ownerFlags
		if (not currentCombat) then return end --Should exist at all times but load. Just in case.

		for i=1,3 do --Loop through the 3 texts on the PetOwnerFinder tooltip
			local actorNameString = _G["DetailsPetOwnerFinderTextLeft"..i]
			if (actorNameString and not ownerName) then --Tooltip line exists and we haven't found a valid match yes.
				local actorName = actorNameString:GetText()
				if (actorName and type(actorName) == "string") then
					local isInRaid = currentCombat.raid_roster[actorName]
					if (isInRaid) then
						ownerGUID = UnitGUID(actorName)
						ownerName = actorName
						ownerFlags = 0x514
					else
						if (CONST_CLIENT_LANGUAGE == "ruRU") then --If russian client, then test for declensions in the string of text.
							for playerName, _ in pairs(currentCombat.raid_roster) do
								local pName = playerName
								playerName = playerName:gsub("%-.*", "") --remove realm name
								if (find_name_declension(actorName, playerName)) then
									ownerGUID = UnitGUID(pName)
									ownerName = pName
									ownerFlags = 0x514
									break
								end
							end
						else
							for playerName in actorName:gmatch("([^%s]+)") do
								playerName = playerName:gsub(",", "")
                                playerName = playerName:gsub("'s$", "")
								local playerIsOnRaidCache = currentCombat.raid_roster[playerName]
								if (playerIsOnRaidCache) then
									ownerGUID = UnitGUID(playerName)
									ownerName = playerName
									ownerFlags = 0x514
									break
								end
							end
						end
					end
				end
			end
		end

		if (ownerGUID) then
			return ownerName, ownerGUID, ownerFlags
		end
	end

	---return the actor type which is containing on this container
	---@self actorcontainer
	---@return number
	function actorContainer:GetType()
		return self.tipo
	end

	---return the actor object for a given actor name
	---@param actorName string
	---@return table|nil
	function actorContainer:GetActor(actorName)
		local index = self._NameIndexTable[actorName]
		if (index) then
			return self._ActorTable[index]
		end
	end

	---return an actor name which used the spell passed 'spellId'
	---@param spellId number
	---@return string|nil
	function actorContainer:GetSpellSource(spellId)
		local t = self._ActorTable
		for i = 1, #t do
			if (t[i].spells._ActorTable[spellId]) then
				return t[i].nome
			end
		end
	end

	---return the value stored in the 'key' for an actor, the key can be any value stored in the actor table such like 'total', 'damage_taken', 'heal', 'interrupt', etc
	---@param actorName string
	---@param key string
	---@return number
	function actorContainer:GetAmount(actorName, key)
		key = key or "total"
		local index = self._NameIndexTable[actorName]
		if (index) then
			return self._ActorTable[index][key] or 0
		else
			return 0
		end
	end

	---return the total value stored in the 'key' for all actors, the key can be any value stored in the actor table such like 'total', 'damage_taken', 'heal', 'interrupt', etc
	---@param key string
	---@return number
	function actorContainer:GetTotal(key)
		local total = 0
		key = key or "total"
		for _, actor in ipairs(self._ActorTable) do
			total = total + (actor[key] or 0)
		end
		return total
	end

	function actorContainer:GetTotalOnRaid(key, combat)
		local total = 0
		key = key or "total"
		local roster = combat.raid_roster
		for _, actor in ipairs(self._ActorTable) do
			if (roster [actor.nome]) then
				total = total + (actor[key] or 0)
			end
		end
		return total
	end

	---return an ipairs iterator for all actors stored in this Container
	---usage: for index, actorObject in container:ListActors() do
	---@return function
	function actorContainer:ListActors()
		return ipairs(self._ActorTable)
	end

	---return a table with actor[] for all actors stored in this container
	---@return table
	function actorContainer:GetActorTable()
		return self._ActorTable
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--internals

	---create a new actor container, can be a damage container, heal container, resource container or utility container
	---actors can be added by using the method newContainer:GetOrCreateActor(actorGuid, actorName, actorFlags, bShouldCreateActor)
	---actors can be retrieved using the same function above
	---@param containerType number
	---@param combatObject table
	---@param combatId number
	---@return table
	function actorContainer:NovoContainer(containerType, combatObject, combatId)
		local newContainer = {
			funcao_de_criacao = actorContainer:FuncaoDeCriacao(containerType),
			tipo = containerType,
			combatId = combatId,
			---@type actor[]
			_ActorTable = {},
			---@type table<string, number>
			_NameIndexTable = {}
		}

		setmetatable(newContainer, actorContainer)
		return newContainer
	end

	--try to get the actor class from name
	local getActorClass = function(actorObject, actorName, actorFlags, actorSerial)
		--get spec
		local specId = Details.cached_specs[actorSerial]
		if (specId) then
			actorObject:SetSpecId(specId)
		end

		if (not specId and Details.track_specs) then
			local newTimer = Details:ScheduleTimer("GuessSpec", 3, {actorObject, nil, 1})
			Details222.GuessSpecSchedules.Schedules[#Details222.GuessSpecSchedules.Schedules+1] = newTimer
		end

		local engClass = Details:GetUnitClass(actorName or "")

		if (engClass) then
			actorObject.classe = engClass
			return
		end

		if (actorObject.serial and actorObject.serial ~= "") then
			local a, b = pcall(function()
				local _, englishClass = GetPlayerInfoByGUID(actorObject.serial)
				if (englishClass) then
					actorObject.classe = englishClass
					return
				end
			end)
		end

		if (actorFlags) then
			if (bitBand(actorFlags, OBJECT_TYPE_PETGUARDIAN) ~= 0) then
				actorObject.classe = "PET"
				return
			end
		end

		if (specId) then
			local specId, specName, specDescription, specIcon, specRole, specClass = DetailsFramework.GetSpecializationInfoByID(specId)
			if (specClass) then
				actorObject.classe = specClass
				return
			end
		end

		if (actorFlags) then
			--check if the actor is a player
			if (bitBand(actorFlags, OBJECT_TYPE_PLAYER) ~= 0) then
				actorObject.classe = "UNGROUPPLAYER"
				return
			end
		end

		actorObject.classe = "UNKNOW" --it's a typo, can't be changed at this point

		return true
	end

	--check if the nickname fit some minimal rules to be presented to other players
	local checkValidNickname = function(nickname, playerName)
		if (nickname and type(nickname) == "string") then
			nickname = nickname:trim()

			if (nickname == "" or nickname:len() < 2) then
				return false
			end

			if (nickname:len() > 20) then
				return false
			end

			if (not UnitIsInMyGuild(playerName) and playerName ~= Details.playername) then
				return false
			end
		else
			return false
		end

		return true
	end

	local dungeonFollowersNpcs = {}

	--read the actor flag
	local readActorFlag = function(actorObject, ownerActorObject, actorSerial, actorFlags, actorName)
		if (actorFlags) then
			local _, zoneType, instanceDifficultyId = GetInstanceInfo()

			--if the actor is a player
			if (bitBand(actorFlags, OBJECT_TYPE_PLAYER) ~= 0) then

                    if (not Details.ignore_nicktag) then
                        local actorNameAmbiguated = Ambiguate(actorName, "none")
                        local nickname = Details:GetNickname(actorNameAmbiguated, false, true)
                        if nickname then
                            if checkValidNickname(nickname, actorName) then
                                actorObject.displayName = nickname --defaults to player name
                            end
                        end
                    end

					--the actor does not have a nickname, use the character name instead
					if (not actorObject.displayName) then
						if (Details.remove_realm_from_name) then
							actorObject.displayName = actorName:gsub(("%-.*"), "")
						else
							actorObject.displayName = actorName
						end
					end

				--group attributions
					if (zoneType ~= "arena" and (Details.all_players_are_group or Details.immersion_enabled)) then
						actorObject.grupo = true
					end

					--special spells that Details! converted them in actor, add them to the group view. the list of these spells are set within the parser.lua file
					--they are added into the group view as they are considered important imformation
					local spellId = Details.SpecialSpellActorsName[actorObject.nome]
					if (spellId) then
						actorObject.grupo = true
						actorObject.spellicon = GetSpellTexture(spellId)
					end

					--check if this actor can be flagged as a unit in the player's group
					local bIsValidGroupMember = bitBand(actorFlags, IS_GROUP_OBJECT) ~= 0 and actorObject.classe ~= "UNKNOW" and actorObject.classe ~= "UNGROUPPLAYER"
					if (bIsValidGroupMember or Details:IsInCache(actorSerial)) then
						actorObject.grupo = true

						--/dump Details:GetCurrentCombat():GetActor(1, "Captain Garrick").grupo
						if (instanceDifficultyId == 205) then
							dungeonFollowersNpcs[actorName] = true
						end

						--check if this actor is a tank (player)
						if (Details:IsATank(actorSerial)) then
							actorObject.isTank = true
						end
					else
						--if this is a pvp combat and the option to show pvp players as group is enabled
						local currentCombat = Details:GetCurrentCombat()
						if (Details.pvp_as_group and currentCombat.is_pvp and Details.is_in_battleground) then
							actorObject.grupo = true
						end
					end

					--pvp duel - this functionality needs more development, the goal is to show the duel players as group members
					if (Details.duel_candidates[actorSerial]) then
						--check if is recent
						if (Details.duel_candidates[actorSerial]+20 > GetTime()) then
							actorObject.grupo = true
							actorObject.enemy = true
						end
					end

					if (zoneType == "arena") then
						--local my_team_color = GetBattlefieldArenaFaction and GetBattlefieldArenaFaction() or 0

						--my team
						if (actorObject.grupo) then
							actorObject.arena_ally = true
							actorObject.arena_team = 0 -- former my_team_color | forcing the player team to always be the same color

						--enemy team
						else
							actorObject.enemy = true
							actorObject.arena_enemy = true
							actorObject.arena_team = 1 -- former my_team_color

							Details:GuessArenaEnemyUnitId(actorName)
						end

						local playerArenaInfo = Details.arena_table[actorName]

						if (playerArenaInfo) then
							actorObject.role = playerArenaInfo.role
							if (playerArenaInfo.role == "NONE") then
								local role = UnitGroupRolesAssigned and UnitGroupRolesAssigned(actorName)
								if (role and role ~= "NONE") then
									actorObject.role = role
								end
							end
						else
							local amountOpponents = GetNumArenaOpponentSpecs and GetNumArenaOpponentSpecs() or 5
							local found = false
							for i = 1, amountOpponents do
								local name = Details:GetFullName("arena" .. i)
								if (name == actorName) then
									local spec = GetArenaOpponentSpec and GetArenaOpponentSpec(i)
									if (spec) then
										local id, name, description, icon, role, class = DetailsFramework.GetSpecializationInfoByID(spec) --thanks pas06
										actorObject.role = role
										actorObject.classe = class
										actorObject.enemy = true
										actorObject.arena_enemy = true
										found = true
									end
								end
							end

							local role = UnitGroupRolesAssigned and UnitGroupRolesAssigned(actorName)
							if (role and role ~= "NONE") then
								actorObject.role = role
								found = true
							end

							if (not found and actorName == Details.playername) then
								local role = UnitGroupRolesAssigned("player")
								if (role and role ~= "NONE") then
									actorObject.role = role
								end
							end
						end

						actorObject.grupo = true
					end

				--player custom bar color
				--at this position in the code, the color will replace colors from arena matches
				if (Details.use_self_color) then
					if (actorName == Details.playername) then
						actorObject.customColor = Details.class_colors.SELF
					end
				end

			--does this actor has an owner? (a.k.a. is a pet)
			elseif (ownerActorObject) then
				local npcID = Details:GetNpcIdFromGuid(actorSerial)
				actorObject.owner = ownerActorObject
				actorObject.ownerName = ownerActorObject.nome

				if (_IsInInstance() and Details.remove_realm_from_name) then
					actorObject.displayName = actorName:gsub(("%-.*"), ">")
				else
					actorObject.displayName = actorName
				end

				--local npcId = Details:GetNpcIdFromGuid(actorSerial)
				--local petCustomname = Details222.Pets.GetPetNameFromCustomSpells(actorObject.displayName, spellId, npcId)
			else
				--anything else that isn't a player or a pet
				actorObject.displayName = actorName
				local npcID = Details:GetNpcIdFromGuid(actorSerial)
				if (npcID) then
					if (npcID == 210759 or npcID == 216287) then --210759 --flag 0x2111
						actorObject.grupo = true
					end
				end
			end

			--check if is hostile
			if (bitBand(actorFlags, REACTION_HOSTILE) ~= 0) then
				if (bitBand(actorFlags, OBJECT_TYPE_PLAYER) == 0) then
					--is hostile and isn't a player
					if (bitBand(actorFlags, OBJECT_TYPE_PETGUARDIAN) == 0) then
						--isn't a pet or guardian
						actorObject.monster = true
					end

					if (actorSerial and type(actorSerial) == "string") then
						local npcID = Details:GetNpcIdFromGuid(actorSerial)
						if (npcID and not Details.npcid_pool[npcID] and type(npcID) == "number") then
							Details.npcid_pool [npcID] = actorName
						end
					end
				end
			end

			if (instanceDifficultyId == 205) then
				if (dungeonFollowersNpcs[actorName]) then
					actorObject.grupo = true
				end
			end
		end
	end

	--pet black list locally for this file
	local petBlackList = {}

	local petOwnerFound = function(ownerName, petGuid, petName, petFlags, self, ownerGuid, ownerFlags)
		local ownerGuid = ownerGuid or UnitGUID(ownerName)
		if (ownerGuid) then
			-- 0xA00 is the flag for NPC controlled, NPC unit. 0x500 is the flag for Player Controlled, Player Unit.
			-- Or those together with the last 2 hex bits for reaction/affiliation to 'guess' the correct flags.
			if not ownerFlags then
				local npcControlled = bitBand(petFlags, 0x200) ~= 0
				ownerFlags = bitBor(npcControlled and 0xA00 or 0x500, bitBand(petFlags, 0xFF))
			end

			petContainer.AddPet(petGuid, petName, petFlags, ownerGuid, ownerName, ownerFlags)
			--hashName is "petName <ownerName>"
			local hashName, ownerName, ownerGUID, ownerFlags = petContainer.GetOwner(petGuid, petName)

			local petOwnerActorObject

			if (hashName and ownerName) then
				petName = hashName
				petOwnerActorObject = self:PegarCombatente(ownerGUID, ownerName, ownerFlags, true)
			end

			return petName, petOwnerActorObject
		end
	end

	---get an actor from the container, if the actor doesn't exists, and the bShouldCreateActor is true, create a new actor
	---this function is an alias for PegarCombatente which is the function name is in portuguese
	---@param actorSerial string
	---@param actorName string
	---@param actorFlags number
	---@param bShouldCreateActor boolean
	---@return actor|nil, actor|nil, actorname|nil
	function actorContainer:PegarCombatente(actorSerial, actorName, actorFlags, bShouldCreateActor)
		return self:GetOrCreateActor(actorSerial, actorName, actorFlags, bShouldCreateActor)
	end

	---@param actorSerial string
	---@param actorName string
	---@param actorFlags number
	---@param bShouldCreateActor boolean
	---@return actor|nil, actor|nil, actorname|nil
	function actorContainer:GetOrCreateActor(actorSerial, actorName, actorFlags, bShouldCreateActor)
		--need to check if the actor is a pet
		local petOwnerObject
		actorSerial = actorSerial or "ns"

		--check if this actor is a pet and the pet is in the pet cache
		if (petContainer.IsPetInCache(actorSerial)) then --this is a registered pet
			--hashName is "petName <ownerName>"
			--actorSerial: petGuid, actorName: petName
			local hashName, ownerName, ownerGuid, ownerFlag = petContainer.GetOwner(actorSerial, actorName) --hashName, ownerName, ownerGuid, ownerFlags

			if (hashName and ownerName and ownerGuid and ownerGuid ~= actorSerial and ownerFlag) then
				actorName = hashName
				petOwnerObject = self:PegarCombatente(ownerGuid, ownerName, ownerFlag, true)
			end

			if (Details222.Debug.DebugPets or Details222.Debug.DebugPlayerPets) then
				Details:Msg("DebugPets|ActorContainer|petContainer.IsPetInCache(actorSerial) = true")
				if (hashName) then
					Details:Msg("DebugPets|ActorContainer|Owner Found In Pet Cache|OwnerName:", ownerName, "Actor Hash:", hashName, "petOwnerObject:", petOwnerObject)
				else
					Details:Msg("DebugPets|ActorContainer|Pet Is Orphan|petContainer.GetOwner(", actorSerial, actorName, ") == nil")
				end
			end

		--this actor isn't in the pet cache
		elseif (not petBlackList[actorSerial]) then --check if is a pet
			--try to find the owner
			if (actorFlags and bitBand(actorFlags, OBJECT_TYPE_PETGUARDIAN) ~= 0) then
				--hashName is "petName <ownerName>"
				local hashName, ownerName, ownerGuid, ownerFlags = petContainer.GetOwner(actorSerial, actorName) --hashName, ownerName, ownerGuid, ownerFlags
				if (ownerName and ownerGuid) then
					--don't pass ownerFlags just in case the cached owner happens to be an enemy from last combat, but ally now.
					local newPetName, ownerObject = petOwnerFound(ownerName, actorSerial, actorName, actorFlags, self, ownerGuid)
					if (newPetName and ownerObject) then
						actorName, petOwnerObject = newPetName, ownerObject
					end
				end
			end

			petBlackList[actorSerial] = true
		end

		--get the actor index in the hash map
		local actorIndex = self._NameIndexTable[actorName]
		if (actorIndex) then
			return self._ActorTable[actorIndex], petOwnerObject, actorName
		end

		if (not bShouldCreateActor) then
			return
		end

		---@type actor
		local newActor = self.funcao_de_criacao(_, actorSerial, actorName)
		newActor.nome = actorName
		newActor.flag_original = actorFlags
		newActor.serial = actorSerial
		newActor.classe = "UNKNOW"

		local forceClass

		--get the aID (actor id)
		if (actorSerial:match("^C")) then
			newActor.aID = tostring(Details:GetNpcIdFromGuid(actorSerial))

			--immersion stuff
			if (Details.immersion_special_units) then
				local shouldBeInGroup, class = Details.Immersion.IsNpcInteresting(newActor.aID)
				newActor.grupo = shouldBeInGroup
				if (class) then
					newActor.classe = class
					forceClass = newActor.classe
				end
			end

		elseif (actorSerial:match("^Pl")) then
			newActor.aID = actorSerial:gsub("Player%-", "")

		else
			newActor.aID = ""
		end

		--check ownership
		if (petOwnerObject and Details.immersion_pets_on_solo_play) then
			if (Details.playername == petOwnerObject.nome) then
				if (not Details.in_group) then
					newActor.grupo = true
				end
			end
		end

		if (self.tipo == container_damage) then --containerType damage
			local shouldScanOnce = getActorClass(newActor, actorName, actorFlags, actorSerial)
			readActorFlag(newActor, petOwnerObject, actorSerial, actorFlags, actorName)

			if (petOwnerObject) then
				AddUnique(petOwnerObject.pets, actorName)
			end

			if (newActor.grupo and Details.in_combat) then
				Details.cache_damage_group[#Details.cache_damage_group+1] = newActor
			end

			if (newActor.isTank) then
				newActor.avoidance = Details:CreateActorAvoidanceTable()
			end

		elseif (self.tipo == container_heal) then --containerType healing
			local shouldScanOnce = getActorClass(newActor, actorName, actorFlags, actorSerial)
			readActorFlag(newActor, petOwnerObject, actorSerial, actorFlags, actorName)

			if (petOwnerObject) then
				AddUnique(petOwnerObject.pets, actorName)
			end

			if (newActor.grupo and Details.in_combat) then
				Details.cache_healing_group[#Details.cache_healing_group+1] = newActor
			end

		elseif (self.tipo == container_energy) then --containerType resources
			local shouldScanOnce = getActorClass(newActor, actorName, actorFlags, actorSerial)
			readActorFlag(newActor, petOwnerObject, actorSerial, actorFlags, actorName)

			if (petOwnerObject) then
				AddUnique(petOwnerObject.pets, actorName)
			end

		elseif (self.tipo == container_misc) then --containerType utility
			local shouldScanOnce = getActorClass(newActor, actorName, actorFlags, actorSerial)
			readActorFlag(newActor, petOwnerObject, actorSerial, actorFlags, actorName)

			if (petOwnerObject) then
				AddUnique(petOwnerObject.pets, actorName)
			end
		end

		--sanguine affix
		if (actorName == sanguineActorName) then
			newActor.grupo = true
		end

		--enemy player
		if (Details.zone_type == "pvp") then
			if (bitBand(actorFlags, REACTION_HOSTILE) ~= 0) then --is hostile
				newActor.enemy = true
			end
		end

		if (newActor.classe == "UNGROUPPLAYER") then --is a player
			if (bitBand(actorFlags, REACTION_HOSTILE) ~= 0) then --is hostile
				newActor.enemy = true
			end
		end

		--battleground
		if (Details.is_in_battleground or Details.is_in_arena) then
			newActor.pvp = true
		end

		local nextActorIndex = #self._ActorTable+1
		self._ActorTable[nextActorIndex] = newActor
		self._NameIndexTable[actorName] = nextActorIndex

		--only happens with npcs from immersion feature
		if (forceClass) then
			newActor.classe = forceClass
		end

		return newActor, petOwnerObject, actorName
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core
	function Details:AddToNpcIdCache(actor) --not called anywhere
		if (flag and serial) then
			if (bitBand (flag, REACTION_HOSTILE) ~= 0 and bitBand (flag, OBJECT_TYPE_NPC) ~= 0 and bitBand (flag, OBJECT_TYPE_PETGUARDIAN) == 0) then
				local npc_id = Details:GetNpcIdFromGuid (serial)
				if (npc_id) then
					Details.cache_npc_ids [npc_id] = nome
				end
			end
		end
	end

	function Details:ClearCCPetsBlackList()
		Details:Destroy(petBlackList)
	end

	function actorContainer:FuncaoDeCriacao(tipo)
		if (tipo == container_damage) then
			return atributo_damage.NovaTabela

		elseif (tipo == container_heal) then
			return atributo_heal.NovaTabela

		elseif (tipo == container_energy) then
			return atributo_energy.NovaTabela

		elseif (tipo == container_misc) then
			return atributo_misc.NovaTabela
		end
	end

	local bykey
	local sort = function(t1, t2)
		return (t1 [bykey] or 0) > (t2 [bykey] or 0)
	end

	function actorContainer:SortByKey(key)
		assert(type(key) == "string", "Container:SortByKey() expects a keyname on parameter 1.")
		bykey = key
		tableSort(self._ActorTable, sort)
		self:remapear()
	end

	---remove an actor from the container, by removing this way, the container does not need to be remapped
	---@param self actorcontainer
	---@param actorObject actor
	function actorContainer:RemoveActor(actorObject)
		local nameMap = self._NameIndexTable
		local actorList = self._ActorTable

		local actorName = actorObject.nome
		if (actorName) then
			local actorIndex = nameMap[actorObject.nome]
			nameMap[actorObject.nome] = nil
			if (actorObject == actorList[actorIndex]) then
				table.remove(actorList, actorIndex)
			end
		end

		self:Remap()
	end

	---remove all destroyed actors from the container, must to be called after a possible DestroyActor() call
	function actorContainer:Cleanup()
		local actorList = self._ActorTable
		for i = #actorList, 1, -1 do
			local actorObject = actorList[i]
			if (actorObject.__destroyed) then
				table.remove(actorList, i)
			end
		end
		self:Remap()
	end

	function actorContainer:Remap() --alias
		return self:remapear()
	end

	function actorContainer:remapear()
		local namingMap = self._NameIndexTable or {}
		Details:Destroy(namingMap)

		local actorList = self._ActorTable
		for i = 1, #actorList do
			local playerName = actorList[i].nome
			if (playerName) then
				namingMap[playerName] = i
			else
				Details:Msg("actorContainer:Remap() found an actor without a name, playerName:", playerName, "__destroyed:", actorList[i].__destroyed)
			end
		end

		self._NameIndexTable = namingMap
	end

	function Details.refresh:r_container_combatentes(container) --runs on login from meta.lua
		--set the metatable, __index and the function which will create new actors in the container
		setmetatable(container, Details.container_combatentes)
		container.__index = Details.container_combatentes
		container.funcao_de_criacao = actorContainer:FuncaoDeCriacao(container.tipo)

		--rebuild the actor map
		container:Remap()
	end

	function Details.clear:c_container_combatentes(container)
		container.__index = nil
		container.need_refresh = nil
		container.funcao_de_criacao = nil
	end

	function Details.clear:c_container_combatentes_index(container)
		container._NameIndexTable = nil
	end
