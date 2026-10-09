--[[ Declare all Details classes and container indexes ]]

do
	---@type details
	local Details = 	_G.Details
	local addonName, Details222 = ...
	local setmetatable = setmetatable

	-------- time machine controla o tempo em combate dos jogadores
		Details.timeMachine = {}
		Details.timeMachine.__index = Details.timeMachine
		setmetatable(Details.timeMachine, Details)

	-------- classe da tabela que armazenar� todos os combates efetuados
		Details.historico = {}
		Details.historico.__index = Details.historico
		setmetatable(Details.historico, Details)

	---------------- classe da tabela onde ser�o armazenados cada combate efetuado
			Details.combate = {}
			Details.combate.__index = Details.combate
			setmetatable(Details.combate, Details.historico)

	------------------------ armazenas classes de jogadores ou outros derivados
				Details.container_combatentes = {}
				Details.container_combatentes.__index = Details.container_combatentes
				setmetatable(Details.container_combatentes, Details.combate)

	-------------------------------- dano das habilidades.
					Details.atributo_damage = {}
					Details.atributo_damage.__index = Details.atributo_damage
					setmetatable(Details.atributo_damage, Details.container_combatentes)

	-------------------------------- cura das habilidades.
					Details.atributo_heal = {}
					Details.atributo_heal.__index = Details.atributo_heal
					setmetatable(Details.atributo_heal, Details.container_combatentes)

	-------------------------------- e_energy ganha
					Details.atributo_energy = {}
					Details.atributo_energy.__index = Details.atributo_energy
					setmetatable(Details.atributo_energy, Details.container_combatentes)

	-------------------------------- outros atributos
					Details.atributo_misc = {}
					Details.atributo_misc.__index = Details.atributo_misc
					setmetatable(Details.atributo_misc, Details.container_combatentes)

	-------------------------------- atributos customizados
					Details.atributo_custom = {}
					Details.atributo_custom.__index = Details.atributo_custom
					setmetatable(Details.atributo_custom, Details.container_combatentes)

	-------------------------------- armazena as classes de habilidades usadas pelo combatente
					Details.container_habilidades = {}
					Details.container_habilidades.__index = Details.container_habilidades
					setmetatable(Details.container_habilidades, Details.combate)

	---------------------------------------- classe das habilidades que d�o cura
						Details.habilidade_cura = {}
						Details.habilidade_cura.__index = Details.habilidade_cura
						setmetatable(Details.habilidade_cura, Details.container_habilidades)

	---------------------------------------- classe das habilidades que d�o danos
						Details.habilidade_dano = {}
						Details.habilidade_dano.__index = Details.habilidade_dano
						setmetatable(Details.habilidade_dano, Details.container_habilidades)

	---------------------------------------- classe das habilidades que d�o e_energy
						Details.habilidade_e_energy = {}
						Details.habilidade_e_energy.__index = Details.habilidade_e_energy
						setmetatable(Details.habilidade_e_energy, Details.container_habilidades)

	---------------------------------------- classe das habilidades variadas
						Details.habilidade_misc = {}
						Details.habilidade_misc.__index = Details.habilidade_misc
						setmetatable(Details.habilidade_misc, Details.container_habilidades)

		---------------------------------------- classe dos alvos das habilidads
							Details.alvo_da_habilidade = {}
							Details.alvo_da_habilidade.__index = Details.alvo_da_habilidade
							setmetatable(Details.alvo_da_habilidade, Details.container_combatentes)

	---return the class object for the given displayId (attributeId)
	---@param displayId attributeid
	---@return table
	function Details:GetDisplayClassByDisplayId(displayId)
		if (displayId == DETAILS_ATTRIBUTE_DAMAGE) then
			return Details.atributo_damage
		elseif (displayId == DETAILS_ATTRIBUTE_HEAL) then
			return Details.atributo_heal
		elseif (displayId == DETAILS_ATTRIBUTE_ENERGY) then
			return Details.atributo_energy
		elseif (displayId == DETAILS_ATTRIBUTE_MISC) then
			return Details.atributo_misc
		elseif (displayId == DETAILS_ATTRIBUTE_CUSTOM) then
			return Details.atributo_custom
		end
		return {}
	end

	--[[ Armazena os diferentes tipos de containers ]] --[[ Container Types ]]
	Details.container_type = {
		CONTAINER_PLAYERNPC = 1,
		CONTAINER_DAMAGE_CLASS = 2,
		CONTAINER_HEAL_CLASS = 3,
		CONTAINER_HEALTARGET_CLASS = 4,
		CONTAINER_FRIENDLYFIRE = 5,
		CONTAINER_DAMAGETARGET_CLASS = 6,
		CONTAINER_ENERGY_CLASS = 7,
		CONTAINER_ENERGYTARGET_CLASS = 8,
		CONTAINER_MISC_CLASS = 9,
		CONTAINER_MISCTARGET_CLASS = 10,
		CONTAINER_ENEMYDEBUFFTARGET_CLASS = 11
	}


	local UnitName = UnitName
	local GetRealmName = GetRealmName

	local initialSpecListOverride = {
		[1455] = 251, --dk
		[1456] = 577, --demon hunter
		[1447] = 102, --druid
		[1465] = 1467, --evoker
		[1448] = 253, --hunter
		[1449] = 63, --mage
		[1450] = 269, --monk
		[1451] = 70, --paladin
		[1452] = 258, --priest
		[1453] = 260, --rogue
		[1444] = 262, --shaman
		[1454] = 266, --warlock
		[1446] = 71, --warrior
	}

	---@param self actor
	---@param specId number
	function Details:SetSpecId(specId)
		self.spec = initialSpecListOverride[specId] or specId
	end

	---@param self details|actor
	---@param actor actor?
	function Details:Name(actor)
		return self.nome or actor and actor.nome
	end
	---Retrieves the name of the actor.
	---If the name is not available in the current object (self), it checks the provided actor object.
	---@param actor (optional) The actor object to retrieve the name from.
	---@return The name of the actor.
	function Details:GetName(actor)
		return self.nome or actor and actor.nome
	end

	---Retrieves the name of the actor without the realm information.
	---If the name is not available in the current object (self), it checks the provided actor object.
	---@param actor (optional) The actor object to retrieve the name from.
	---@return The name of the actor without the realm information.
	function Details:GetNameNoRealm(actor)
		local name = self.nome or actor and actor.nome
		return Details:GetOnlyName(name)
	end

	---Retrieves the display name of the actor.
	---If the display name is not available in the current object (self), it checks the provided actor object.
	---@param actor actor The actor object to retrieve the display name from.
	---@return string displayName display name of the actor.
	function Details:GetDisplayName(actor)
		return self.displayName or actor and actor.displayName
	end

	---Sets the display name of the actor.
	---If the new display name is not provided, it sets the display name of the current object (self) to the provided actor object.
	---@param actor actor The actor object to set the display name for.
	---@param newDisplayName string The new display name to set.
	function Details:SetDisplayName(actor, newDisplayName)
		if (not newDisplayName) then
			local thisActor = self
			---@cast thisActor actor
			local displayName = tostring(actor)
			thisActor.displayName = displayName
		else
			actor.displayName = newDisplayName
		end
	end

	--wow forever: a character has a first name and a surname, e.g. "Charles Netherwing"
	--UnitName() gives the surname where the other clients give the realm name: "Charles", "Netherwing"
	--the damage meter api gives the full name, and during combat that name is a secret string which can be shown but not trimmed
	local bClientHasSurnames = DetailsFramework.IsForeverWow and DetailsFramework.IsForeverWow() or false
	local surnameSeparator = Constants and Constants.CharacterNameSeparatorConsts and Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR
	if (type(surnameSeparator) ~= "string" or surnameSeparator == "") then
		surnameSeparator = " "
	end
	local isSecretValue = issecretvalue or function() return false end
	local pcall = pcall
	local format = string.format

	--full name of the players seen in the group or in the damage meter and their first names: ["Charles Netherwing"] = "Charles"
	--a creature can also have a space in its name, this table tells if a name with a space belongs to a player
	local playerFirstNames = {}

	function Details:GetOnlyName(string)
		local name, amountReplaced
		if (string) then
			name, amountReplaced = string:gsub(("%-.*"), "")
		else
			name, amountReplaced = self.nome:gsub(("%-.*"), "")
		end

		--wow forever: if this is the full name of a player, remove the surname too when the option is enabled
		if (bClientHasSurnames and Details.remove_surname_from_name and not isSecretValue(name)) then
			local firstName = playerFirstNames[name]
			if (firstName) then
				return firstName, amountReplaced
			end
		end

		return name, amountReplaced
	end

	function Details:RemoveOwnerName(string)
		if (string) then
			return string:gsub((" <.*"), "")
		end
		return self.nome:gsub((" <.*"), "")
	end

	--wow forever: keep the full name of the players in the group, see playerFirstNames
	if (bClientHasSurnames) then
		local registerUnit = function(unitId)
			local firstName, surname = UnitName(unitId)
			if (isSecretValue(firstName) or isSecretValue(surname)) then
				return
			end
			if (type(firstName) == "string" and firstName ~= "" and type(surname) == "string" and surname ~= "") then
				playerFirstNames[firstName .. surnameSeparator .. surname] = firstName
			end
		end

		local rosterFrame = CreateFrame("frame")
		rosterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		rosterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
		rosterFrame:SetScript("OnEvent", function()
			--UnitName() returns nil for the units that don't exist
			registerUnit("player")
			for i = 1, 4 do
				registerUnit("party" .. i)
			end
			for i = 1, 40 do
				registerUnit("raid" .. i)
			end
		end)
	end

	---return true if the client has surnames and the option to not show them is enabled
	---@return boolean
	function Details:IsRemovingSurnames()
		return bClientHasSurnames and Details.remove_surname_from_name and true or false
	end

	---remove the surname from the full name of a player: "Charles Netherwing" -> "Charles"
	---does nothing if the option is disabled, if the client has no surnames or if the name is a secret
	---only use with player names, the name of a creature also has spaces
	---@param name string
	---@return string
	function Details:RemoveSurname(name)
		if (not bClientHasSurnames or not Details.remove_surname_from_name) then
			return name
		end

		if (isSecretValue(name) or type(name) ~= "string") then
			return name
		end

		local separatorStart = name:find(surnameSeparator, 2, true)
		if (separatorStart) then
			return name:sub(1, separatorStart - 1)
		end

		return name
	end

	---return the name to show for a source of the blizzard damage meter without the surname of the player
	---displayName is the name that would be shown if the surname stays, it is returned when there's nothing to remove
	---@param source damagemeter_combat_source
	---@param displayName string
	---@return string
	function Details:GetSourceNameNoSurname(source, displayName)
		if (not bClientHasSurnames or not Details.remove_surname_from_name or not source) then
			return displayName
		end

		--classFilename is never secret, creatures have an empty class and the spaces in their names aren't surnames
		local classFilename = source.classFilename
		if (isSecretValue(classFilename) or not classFilename or classFilename == "") then
			return displayName
		end

		if (not isSecretValue(displayName)) then
			--out of combat the name is a regular string
			local creatureId = source.sourceCreatureID
			if (isSecretValue(creatureId) or (creatureId and creatureId ~= 0)) then
				return displayName
			end

			local firstName = Details:RemoveSurname(displayName)
			if (type(displayName) == "string" and firstName ~= displayName) then
				--remember this is a player, GetOnlyName() also removes the surname of known players
				playerFirstNames[displayName] = firstName
			end
			return firstName
		end

		--in combat the name is a secret: it cannot be read, compared or trimmed
		--ask the game for the name of the unit instead, the first value returned is the first name
		local isLocalPlayer = source.isLocalPlayer
		if (not isSecretValue(isLocalPlayer) and isLocalPlayer) then
			local playerFirstName = UnitName("player")
			if (not isSecretValue(playerFirstName) and type(playerFirstName) == "string" and playerFirstName ~= "") then
				return Details:RemoveSurname(playerFirstName)
			end
		end

		local getNameFromGUID = UnitNameFromGUID
		if (getNameFromGUID) then
			local bOkay, firstName = pcall(getNameFromGUID, source.sourceGUID)
			if (bOkay) then
				if (isSecretValue(firstName)) then
					--a secret can't be compared with nil or with an empty string, but format() fails when it isn't a string
					local bIsString, nameText = pcall(format, "%s", firstName)
					if (bIsString) then
						return nameText
					end

				elseif (type(firstName) == "string" and firstName ~= "" and firstName ~= UNKNOWNOBJECT) then
					return Details:RemoveSurname(firstName)
				end
			end
		end

		return displayName
	end

	function Details:GetCLName(id)
		local name, realm = UnitName(id)
		if (name) then
			if issecretvalue and issecretvalue(realm) then
				--return GetUnitName(id, true)
			end
			if (realm and realm ~= "") then
				name = name .. "-" .. realm
			end
			return name
		end
	end

	local _, _, _, toc = GetBuildInfo() --check game version to know which version of GetFullName to use

	---return the class file name of the unit passed
	local getFromCache = Details222.ClassCache.GetClassFromCache
	local Ambiguate = Ambiguate
	local UnitClass = UnitClass
	function Details:GetUnitClass(unitId)
		local class, classFileName = getFromCache(unitId)

		if (not classFileName) then
			unitId = Ambiguate(unitId, "none")
			classFileName = select(2, UnitClass(unitId))
		end

		return classFileName
	end

	function Details:Ambiguate(unitName)
		--if (toc >= 100200) then
			unitName = Ambiguate(unitName, "none")
		--end
		return unitName
	end

	---return the class name, class file name and class id of the unit passed
	function Details:GetUnitClassFull(unitId)
		unitId = Ambiguate(unitId, "none")
		local locClassName, classFileName, classId = UnitClass(unitId)
		return locClassName, classFileName, classId
	end

	local UnitFullName = UnitFullName
	--Details:GetCurrentCombat():GetActor(DETAILS_ATTRIBUTE_DAMAGE, Details:GetFullName("player")):GetSpell(1)

	---create a CLEU compatible name of the unit passed
	---return string is in the format "playerName-realmName"
	---the string will also be ambiguated using the ambiguateString passed
	---@param unitId any
	---@param ambiguateString any
	function Details:GetFullName(unitId, ambiguateString) --not in use, get replace by Details.GetCLName a few lines below
		--UnitFullName is guarantee to return the realm name of the unit queried
		local playerName, realmName = UnitFullName(unitId)
		if (playerName) then
			if (not realmName) then
				realmName = GetRealmName()
			end
			realmName = realmName:gsub("[%s-]", "")

			playerName = playerName .. "-" .. realmName

			if (ambiguateString) then
				playerName = Ambiguate(playerName, ambiguateString)
			end

			return playerName
		end
	end

	function Details:GetUnitNameForAPI(unitId)
		return Details:GetFullName(unitId, "none")
	end

	--if (toc < 100200) then
		Details.GetFullName = Details.GetCLName
	--end

	function Details:IsValidActor(actor)
		return actor and actor.classe and actor.nome and actor.flag_original and true
	end

	function Details:Class(actor)
		return self.classe or actor and actor.classe
	end

	function Details:GetActorClass(actor)
		return self.classe or actor and actor.classe
	end

	function Details:GetGUID(actor)
		return self.serial or actor and actor.serial
	end

	function Details:GetFlag(actor)
		return self.flag_original or actor and actor.flag_original
	end

	function Details:GetSpells()
		return self.spells._ActorTable
	end

	function Details:GetActorSpells()
		return self.spells._ActorTable
	end

	function Details:GetSpell(spellid)
		return self.spells._ActorTable [spellid]
	end

	---return an array of pet names
	---@return table
	function Details:GetPets()
		return self.pets
	end

	---return an array of pet names
	---@return table
	function Details:Pets()
		return self.pets
	end

	function Details:GetSpec(actor)
		return self.spec or actor and actor.spec
	end

	function Details:Spec(actor)
		return self.spec or actor and actor.spec
	end

	---add the class color to the string passed
	---@param thisString string
	---@param class string
	---@return string
	function Details:AddColorString(thisString, class)
		--check if the class colors exists
		local classColors = _G["RAID_CLASS_COLORS"]
		if (classColors) then
			local color = classColors[class]
			--check if the player name is valid
			if (type(thisString) == "string" and color) then
				thisString = "|c" .. color.colorStr .. thisString .. "|r"
				return thisString
			end
		end

		--if failed, return the string without modifications
		return thisString
	end

	---add the role icon to the string passed
	---@param thisString string
	---@param role string
	---@param size number|nil default is 14
	---@return string
	function Details:AddRoleIcon(thisString, role, size)
		--check if is a valid role
		local roleIcon = Details.role_texcoord [role]
		if (type(thisString) == "string" and roleIcon and role ~= "NONE") then
			--add the role icon
			size = size or 14
			thisString = "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. size .. ":" .. size .. ":0:0:256:256:" .. roleIcon .. "|t " .. thisString
			return thisString
		end

		--if failed, return the string without modifications
		return thisString
	end

	---add the spec icon or class icon to the string passed
	---@param thisString string
	---@param class string|nil
	---@param spec number|nil
	---@param iconSize number|nil default is 16
	---@param useAlphaIcons boolean|nil default is false
	---@return string
	function Details:AddClassOrSpecIcon(thisString, class, spec, iconSize, useAlphaIcons)
		iconSize = iconSize or 16

		if (spec and Details.class_specs_coords[spec]) then
			local specString = ""
			local L, R, T, B = unpack(Details.class_specs_coords[spec])
			if (L) then
				if (useAlphaIcons) then
					specString = "|TInterface\\AddOns\\Details\\images\\spec_icons_normal_alpha:" .. iconSize .. ":" .. iconSize .. ":0:0:512:512:" .. (L * 512) .. ":" .. (R * 512) .. ":" .. (T * 512) .. ":" .. (B * 512) .. "|t"
				else
					specString = "|TInterface\\AddOns\\Details\\images\\spec_icons_normal:" .. iconSize .. ":" .. iconSize .. ":0:0:512:512:" .. (L * 512) .. ":" .. (R * 512) .. ":" .. (T * 512) .. ":" .. (B * 512) .. "|t"
				end
				return specString .. " " .. thisString
			end
		end

		if (class) then
			local classString = ""
			local L, R, T, B = unpack(Details.class_coords[class])
			if (L) then
				local imageSize = 128
				if (useAlphaIcons) then
					classString = "|TInterface\\AddOns\\Details\\images\\classes_small_alpha:" .. iconSize .. ":" .. iconSize .. ":0:0:" .. imageSize .. ":" .. imageSize .. ":" .. (L * imageSize) .. ":" .. (R * imageSize) .. ":" .. (T * imageSize) .. ":" .. (B * imageSize) .. "|t"
				else
					classString = "|TInterface\\AddOns\\Details\\images\\classes_small:" .. iconSize .. ":" .. iconSize .. ":0:0:" .. imageSize .. ":" .. imageSize .. ":" .. (L * imageSize) .. ":" .. (R * imageSize) .. ":" .. (T * imageSize) .. ":" .. (B * imageSize) .. "|t"
				end
				return classString .. " " .. thisString
			end
		end

		return thisString
	end

	--inherits to all actors without placing it on _detalhes namespace.
	Details.container_combatentes.guid = Details.GetGUID
	Details.container_combatentes.name = Details.GetName
	Details.container_combatentes.class = Details.GetActorClass
	Details.container_combatentes.flag = Details.GetFlag

end
