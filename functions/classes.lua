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

	function Details:GetOnlyName(string)
		if (string) then
			return string:gsub(("%-.*"), "")
		end
		return self.nome:gsub(("%-.*"), "")
	end

	function Details:RemoveOwnerName(string)
		if (string) then
			return string:gsub((" <.*"), "")
		end
		return self.nome:gsub((" <.*"), "")
	end

	function Details:GetCLName(id)
		local name, realm = UnitName(id)
		if (name) then
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

		if (spec) then
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
